import os
import context
from convert import convert, Format
import unittest


def resourcePath(name):
    return os.path.join(os.path.dirname(__file__), "data", name)

def equalsOutputFile(s, filename):
    with open(resourcePath(filename)) as f:
        reference = f.read()
    return reference == s

class BridgeMetadataTest(unittest.TestCase):

    def testQgisToIso19139(self):
        iso = convert(resourcePath("test.qmd"), Format.ISO19139, Format.QGIS)
        self.assertTrue(equalsOutputFile(iso, "iso19139.xml"))

    def testQgisToIso19139Autodetect(self):
        iso = convert(resourcePath("test.qmd"), Format.ISO19139)
        self.assertTrue(equalsOutputFile(iso, "iso19139.xml"))
            
if __name__ == '__main__':
    unittest.main()