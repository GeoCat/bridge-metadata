# bridge metadata
A library to convert between GIS metadata formats.
Uses commonly available XSLT sheets, see license for individual sheets in relevant files.

Use as library

```python
from bridgemetadata import convert

```

Use from command line (converts a iso19139 to QGIS QML format)

```
md2md example.xml out.xml QGIS
```

Currently supported conversions:
- QGIS to ISO19139
- ISO19139 to QGIS
- FGDC to ISO19139
- ISO19115 to ISO19139
- ISO19139 to SCHEMA (application/ld+json)
- ISO19139 to DCAT (application/rdf+xml)
- ISO19139 to DATASITE (application/json)

Note that you can chain 2 conversions, src=FGDC dst=DCAT (via ISO19139)
