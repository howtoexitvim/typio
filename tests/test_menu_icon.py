"""Check the shipped icon's alpha mask, which macOS uses for all template tints."""
import unittest
import plistlib
from pathlib import Path
from PIL import Image

ICON = Path(__file__).resolve().parents[1] / 'resources/images/Typio.tiff'

class MenuIconTests(unittest.TestCase):
    def test_circular_plate_with_transparent_T_at_both_scales(self):
        with Image.open(ICON) as image:
            self.assertEqual(image.n_frames, 2)
            for frame, scale in enumerate((1, 2)):
                with self.subTest(scale=scale):
                    image.seek(frame)
                    rgba = image.convert('RGBA')
                    self.assertEqual(rgba.size, (22 * scale, 16 * scale))
                    alpha = rgba.getchannel('A')
                    # A 16 pt circle centered on the 22 pt canvas leaves side margins.
                    for point in ((0, 8), (21, 8), (4, 1), (17, 1)):
                        self.assertLess(alpha.getpixel(tuple(v * scale for v in point)), 20)
                    # The circle encloses the transparent T stem.
                    self.assertGreater(alpha.getpixel((4 * scale, 8 * scale)), 230)
                    self.assertLess(alpha.getpixel((11 * scale, 8 * scale)), 55)
                    self.assertEqual(rgba.convert('RGB').getextrema(), ((0, 0),) * 3)

    def test_single_source_uses_the_shared_template_icon(self):
        with (ICON.parents[1] / 'Info.plist').open('rb') as file:
            info = plistlib.load(file)
        self.assertNotIn('ComponentInputModeDict', info)
        self.assertEqual(info['tsInputMethodIconFileKey'], ICON.name)
        self.assertTrue(info['TISIconIsTemplate'])

if __name__ == '__main__':
    unittest.main()
