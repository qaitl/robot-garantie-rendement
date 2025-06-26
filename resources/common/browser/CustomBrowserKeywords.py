
from robot.libraries.BuiltIn import BuiltIn
import re
from datetime import timedelta
import time

class CustomBrowserKeywords:
    @property
    def _browser(self):
        return BuiltIn().get_library_instance('Browser')
    # not a regular Platwright object, but all keywords are accessibles
    
    def type_with_keys(
        self,
        selector: str,
        text: str,
        delay: timedelta = timedelta(seconds=0),
        clear: bool = True,):
        """Type Text with support for specials keys
        
        Types the given ``txt`` into the text field found by ``selector``.

        Sends a ``keydown``, ``keypress/input``, and ``keyup`` event for each
        character in the text.

        Specials keys can be thyped using this syntax:
        | =Syntax= | =Example= | =Description |
        | {Key}    | {Enter}, {F1}, ... | Press special key  (TBD)|
        | {{ or }} |                    | A single { or }    (TBD) |
        | {wait:n} | {wait:3s}          | wait for the given time (TBD) | 

        | =Arguments= | =Description= |
        | ``selector`` | Selector of the text field. See the `Finding elements` section for details about the selectors. |
        | ``txt`` | Text for the text field. |
        | ``delay`` | Delay between the single key strokes. It may be either a number or a Robot Framework time string. Time strings are fully explained in an appendix of Robot Framework User Guide. Defaults to ``0 ms``. Example: ``50 ms`` |
        | ``clear`` | Set to false, if the field shall not be cleared before typing. Defaults to true. |

        Keyword uses strict mode, see `Finding elements` for more details about strict mode.

        See `Fill Text` for direct filling of the full text at once.

        Example
        | `Type Text`    input#username_field    user
        | `Type Text`    input#username_field    user    delay=10 ms    clear=No


        """        
        if clear:
            self._browser.clear_text(selector) # To test

        parts = re.split(r'(\{.*?\})', text) # todo: handle {{ and }} + wait (exemple: unicode private zone (U+E000 à U+F8FF).)
        for part in parts:
            if part.startswith('{') and part.endswith('}'):
                special_sequence = part[1:-1]
                special_sequence = special_sequence.capitalize().replace("Return", "Enter")
                if special_sequence[0]=='W':
                    raise Exception("Not yet implemented")
                if special_sequence[0] in ['{','}']:
                    raise Exception("Not yet implemented")
                self._browser.press_keys(selector, special_sequence) #rename var
                time.sleep(int(self._browser.get_timeout(delay)/1000))
            elif part: # exclude empty
                self._browser.press_keys(selector, *list(part)) #todo: retirer delay

                
        # # press key
        # self._browser.press_keys(selector, "F7")
        # # press array of keys
        # self._browser.press_keys(selector, *["F7", "F7"])
        # # todo: rewrite function from nrbehave
    
    def get_field_after():
        ...

    def get_zone(col, row):
        ...