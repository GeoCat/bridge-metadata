import os
from enum import Enum, auto
import lxml.etree as ET
from xml.etree.ElementTree import Element, SubElement
from xml.etree import ElementTree
from xml.dom import minidom

class UnimplementedConversionException(Exception):
    pass

class UnknownFormatException(Exception):
    pass    

class Format(Enum):

    QGIS = auto()
    ISO19139 = auto()
    ISO19115 = auto()
    WRAPPING_ISO19115 = auto()
    FGDC = range(5)


def _resource(f):
    return os.path.join(os.path.dirname(__file__), "resources", f) 

TO, FROM = range(2)

QMD_TO_ISO19139_XSLT = _resource("qgis-to-iso19139.xsl")
ISO19139_TO_QMD_XSLT = _resource("iso19139-to-qgis.xsl")
ISO19115_TO_ISO19139_XSLT = _resource("iso19115-to-iso19139.xsl")
WRAPPING_ISO19115_TO_ISO19139_XSLT = _resource("iso19115-wrapping-to-iso19139.xsl")
FGDC_TO_ISO19115 = _resource("fgdc-to-iso19115.xsl")

conversion = {Format.QGIS: {TO: [ISO19139_TO_QMD_XSLT], FROM: [QMD_TO_ISO19139_XSLT]},
              Format.ISO19139: {TO: [], FROM: []},
              Format.ISO19115: {TO: None, FROM: [ISO19115_TO_ISO19139_XSLT]},
              Format.WRAPPING_ISO19115: {TO: None, FROM: [WRAPPING_ISO19115_TO_ISO19139_XSLT]},
              Format.FGDC: {TO: None, FROM: [FGDC_TO_ISO19115, ISO19115_TO_ISO19139_XSLT]}
             }

def convert(src, dstformat, srcformat=None, dstfile=None):

    if os.path.exists(src):
        dom = ET.parse(src)
    else:
        dom = ET.fromstring(src)

    if srcformat is None:
        srcformat = _detect_format(dom)

    if srcformat is None:
        raise UnknownFormatException()

    print(srcformat)
    
    to_conversion = conversion.get(dstformat)[TO]
    from_conversion = conversion.get(srcformat)[FROM]

    if None in [to_conversion, from_conversion]:
        raise UnimplementedConversionException()

    transforms = to_conversion + from_conversion

    print(transforms)

    for t in transforms:
        xslt = ET.parse(t)        
        transform = ET.XSLT(xslt)
        dom = transform(dom)

    s = ET.tostring(dom, pretty_print=True).decode()
    if dstfile is not None:        
        with open(dstfile, "w") as f:
            f.write('<?xml version="1.0" encoding="UTF-8"?>\n' + s)

    return s
    

def _detect_format(dom):
    root = dom.getroot()

    def _hasTag(tag):
        return bool(len(list(root.xpath(f"//{tag}"))))

    if _hasTag("qgis"):
        return Format.QGIS
    elif _hasTag("esri"):
        if _hasTag("gmd:MD_Metadata"):
            return Format.WRAPPING_ISO19115
        else:
            return Format.ISO19115
    elif _hasTag("MD_Metadata") or _hasTag("MD_Metadata"):
        return Format.ISO19139
    elif _hasTag("metadata/mdStanName"):
        schemaName = list(root.iterfind("..//metadata/mdStanName"))[0].text
        if "FGDC-STD" in schemaName:
            return Format.FGDC
        elif "19115" in schemaName:
            return Format.ISO19139
    else:
        return Format.FGDC
