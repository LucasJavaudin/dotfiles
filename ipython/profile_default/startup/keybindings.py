from prompt_toolkit.clipboard import ClipboardData
import IPython
from prompt_toolkit.filters import is_read_only
from prompt_toolkit.filters.app import vi_navigation_mode, vi_selection_mode
from prompt_toolkit.key_binding.vi_state import CharacterFind, InputMode
from prompt_toolkit.keys import Keys
from prompt_toolkit.selection import SelectionType
from prompt_toolkit.key_binding.bindings.vi import (
    create_operator_decorator,
    TextObject,
    create_text_object_decorator,
    TextObjectType,
)

ip = IPython.get_ipython()

if ip is not None:
    bindings = ip.pt_app.key_bindings

    @bindings.add("s", filter=vi_selection_mode)
    def _(event):
        event.current_buffer.cursor_up(count=event.arg)


    @bindings.add("t", filter=vi_selection_mode)
    def _(event):
        event.current_buffer.cursor_down(count=event.arg)


    @bindings.add("s", filter=vi_navigation_mode)
    def _(event):
        event.current_buffer.auto_up(count=event.arg, go_to_start_of_line_if_history_changes=True)


    @bindings.add("t", filter=vi_navigation_mode)
    def _(event):
        event.current_buffer.auto_down(count=event.arg, go_to_start_of_line_if_history_changes=True)


    @bindings.add("L", filter=vi_navigation_mode & ~is_read_only)
    def _(event):
        buffer = event.current_buffer
        deleted = buffer.delete(count=buffer.document.get_end_of_line_position())
        event.app.clipboard.set_text(deleted)
        event.app.vi_state.input_mode = InputMode.INSERT


    @bindings.add("l", "l", filter=vi_navigation_mode & ~is_read_only)
    @bindings.add("K", filter=vi_navigation_mode & ~is_read_only)
    def _(event):
        buffer = event.current_buffer
        # We copy the whole line.
        data = ClipboardData(buffer.document.current_line, SelectionType.LINES)
        event.app.clipboard.set_data(data)
        # But we delete after the whitespace
        buffer.cursor_position += buffer.document.get_start_of_line_position(after_whitespace=True)
        buffer.delete(count=buffer.document.get_end_of_line_position())
        event.app.vi_state.input_mode = InputMode.INSERT


    @bindings.add("T", filter=vi_navigation_mode & ~is_read_only)
    def _(event):
        for _ in range(event.arg):
            event.current_buffer.join_next_line()


    @bindings.add("g", "T", filter=vi_navigation_mode & ~is_read_only)
    def _(event):
        """
        Join lines without space.
        """
        for _ in range(event.arg):
            event.current_buffer.join_next_line(separator="")


    @bindings.add("T", filter=vi_selection_mode & ~is_read_only)
    def _(event):
        """
        Join selected lines.
        """
        event.current_buffer.join_selected_lines()


    @bindings.add("g", "T", filter=vi_selection_mode & ~is_read_only)
    def _(event):
        """
        Join selected lines without space.
        """
        event.current_buffer.join_selected_lines(separator="")


    @bindings.add("h", filter=vi_navigation_mode)
    def _(event):
        """
        Go to 'replace-single'-mode.
        """
        event.app.vi_state.input_mode = InputMode.REPLACE_SINGLE


    @bindings.add("H", filter=vi_navigation_mode)
    def _(event):
        """
        Go to 'replace'-mode.
        """
        event.app.vi_state.input_mode = InputMode.REPLACE


    @bindings.add("k", filter=vi_navigation_mode & ~is_read_only)
    def _(event):
        """
        Substitute with new text
        (Delete character(s) and go to insert mode.)
        """
        text = event.current_buffer.delete(count=event.arg)
        event.app.clipboard.set_text(text)
        event.app.vi_state.input_mode = InputMode.INSERT


    operator = create_operator_decorator(bindings)
    text_object = create_text_object_decorator(bindings)

    @operator("l", filter=~is_read_only)
    def _(event, text_object):
        clipboard_data = None
        buff = event.current_buffer
        if text_object:
            new_document, clipboard_data = text_object.cut(buff)
            buff.document = new_document
        # Set deleted/changed text to clipboard or named register.
        if clipboard_data and clipboard_data.text:
            event.app.clipboard.set_data(clipboard_data)
        event.app.vi_state.input_mode = InputMode.INSERT

#
# *** Text objects ***
#


    @text_object("é")
    def _(event):
        """
        'word' forward.
        """
        return TextObject(
            event.current_buffer.document.find_next_word_beginning(count=event.arg)
            or event.current_buffer.document.get_end_of_document_position()
        )


    @text_object("É")
    def _(event):
        """
        'WORD' forward.
        """
        return TextObject(
            event.current_buffer.document.find_next_word_beginning(count=event.arg, WORD=True)
            or event.current_buffer.document.get_end_of_document_position()
        )


    @text_object("j", Keys.Any)
    def _(event):
        """
        Move right to the next occurrence of c, then one char backward.
        """
        event.app.vi_state.last_character_find = CharacterFind(event.data, False)
        match = event.current_buffer.document.find(event.data, in_current_line=True, count=event.arg)
        if match:
            return TextObject(match - 1, type=TextObjectType.INCLUSIVE)
        else:
            return TextObject(0)


    @text_object("J", Keys.Any)
    def _(event):
        """
        Move left to the previous occurrence of c, then one char forward.
        """
        event.app.vi_state.last_character_find = CharacterFind(event.data, True)
        match = event.current_buffer.document.find_backwards(
            event.data, in_current_line=True, count=event.arg
        )
        return TextObject(match + 1 if match else 0)


    @text_object("c")
    def _(event):
        """
        Implements 'ch', 'dh', 'h': Cursor left.
        """
        return TextObject(event.current_buffer.document.get_cursor_left_position(count=event.arg))


    @text_object("t", no_move_handler=True, no_selection_handler=True)
# Note: We also need `no_selection_handler`, because we in
#       selection mode, we prefer the other 'j' binding that keeps
#       `buffer.preferred_column`.
    def _(event):
        """
        Implements 'cj', 'dj', 'j', ... Cursor up.
        """
        return TextObject(
            event.current_buffer.document.get_cursor_down_position(count=event.arg),
            type=TextObjectType.LINEWISE,
        )


    @text_object("s", no_move_handler=True, no_selection_handler=True)
    def _(event):
        """
        Implements 'ck', 'dk', 'k', ... Cursor up.
        """
        return TextObject(
            event.current_buffer.document.get_cursor_up_position(count=event.arg),
            type=TextObjectType.LINEWISE,
        )


    @text_object("r")
    def _(event):
        """
        Implements 'cl', 'dl', 'l', 'c ', 'd ', ' '. Cursor right.
        """
        return TextObject(event.current_buffer.document.get_cursor_right_position(count=event.arg))
