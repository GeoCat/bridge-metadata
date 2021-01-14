<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:geonet="http://www.fao.org/geonetwork"
            xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <sch:ns prefix="gml320" uri="http://www.opengis.net/gml"/>
  <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
  <sch:ns prefix="srv" uri="http://www.isotc211.org/2005/srv"/>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="gmx" uri="http://www.isotc211.org/2005/gmx"/>
  <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
  <sch:ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <sch:ns prefix="ns2" uri="http://www.w3.org/2004/02/skos/core#"/>
  <sch:ns prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>

  <sch:let name="schema" value="'iso19139.ca.HNAP'"/>
  <sch:let name="mainLanguage" value="'eng'"/>                            
  <sch:let name="mainLanguageId" value="//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale[gmd:languageCode/*/@codeListValue = $mainLanguage]/@id"/>
  <sch:let name="mainLanguageText" value="'English'"/>
  <sch:let name="mainLanguage2char" value="'en'"/>

  <!--- Metadata pattern -->
  <sch:pattern>
    <!-- HierarchyLevel -->
    <sch:rule context="//gmd:hierarchyLevel">
      <sch:let name="missing" value="not(string(gmd:MD_ScopeCode/@codeListValue)) or (@gco:nilReason)" />
      <sch:let name="hierarchyLevelCodelistLabel" value="@codeListValue"/>
      <sch:let name="isValid" value="($hierarchyLevelCodelistLabel != '') and ($hierarchyLevelCodelistLabel != gmd:MD_ScopeCode/@codeListValue)"/>
      <sch:assert test="not($missing)">HierarchyLevel</sch:assert>
      <sch:assert test="$isValid or $missing">InvalidHierarchyLevel</sch:assert>
    </sch:rule>


    <!-- referenceSystemInfo -->
    <!-- Mandatory, if spatialRepresentionType in Data Identification is "vector," "grid" or "tin”. -->
    <sch:rule context="/gmd:MD_Metadata">
      <sch:let name="missing" value="not(gmd:referenceSystemInfo)
                " />

      <sch:let name="sRequireRefSystemInfo" value="count(//gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode[@codeListValue= 'RI_635']) +
                                                     count(//gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode[@codeListValue= 'RI_636']) +
                                                     count(//gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode[@codeListValue= 'RI_638'])" />

      <sch:assert
        test="(($sRequireRefSystemInfo > 0) and not($missing)) or $sRequireRefSystemInfo = 0">ReferenceSystemInfo</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code">
      <sch:let name="missing" value="not(string(gco:CharacterString))" />
      <sch:assert test="not($missing)">ReferenceSystemInfoCode</sch:assert>
    </sch:rule>

    <!-- Contact - Role 
    <sch:rule context="//gmd:contact/*/gmd:role">
      <sch:let name="roleCodelistLabel" value="gmd:CI_RoleCode/@codeListValue"/>
      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue)) or (@gco:nilReason)" />
      <sch:assert test="not($missing)">MissingContactRole</sch:assert>
      <sch:let name="isValid" value="($roleCodelistLabel != '') and ($roleCodelistLabel != gmd:CI_RoleCode/@codeListValue)"/>

      <sch:assert  test="$isValid or $missing">InvalidContactRole</sch:assert>

    </sch:rule>-->
  </sch:pattern>


  <!--- Data Identification pattern -->
  <sch:pattern>

    <!-- Status 
    <sch:rule context="//gmd:identificationInfo/*/gmd:status
                     |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:status
                     |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:status">

      <sch:let name="missing" value="not(string(gmd:MD_ProgressCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:assert test="not($missing)">Status</sch:assert>

      <sch:let name="statusCodelistLabel" value="gmd:MD_ProgressCode/@codeListValue"/>

      <sch:let name="isValid" value="($statusCodelistLabel != '') and ($statusCodelistLabel != gmd:MD_ProgressCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >InvalidStatusCode</sch:assert>

    </sch:rule>-->


    <!-- Topic Category -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:topicCategory
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:topicCategory
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:topicCategory">

      <sch:let name="missing" value="not(string(gmd:MD_TopicCategoryCode))
                " />

      <sch:assert
        test="not($missing)"
      >TopicCategory</sch:assert>
    </sch:rule>


    <!-- Spatial Representation Type 
    <sch:rule context="//gmd:identificationInfo/*/gmd:spatialRepresentationType
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:spatialRepresentationType
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:spatialRepresentationType">

      <sch:let name="missing" value="not(string(gmd:MD_SpatialRepresentationTypeCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >SpatialRepresentation</sch:assert>


      <sch:let name="spatialRepresentationTypeCodelistLabel"
               value="gmd:MD_SpatialRepresentationTypeCode/@codeListValue"/>

      <sch:let name="isValid" value="($spatialRepresentationTypeCodelistLabel != '') and ($spatialRepresentationTypeCodelistLabel != gmd:MD_SpatialRepresentationTypeCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >InvalidSpatialRepresentationType</sch:assert>
    </sch:rule>-->


    <!-- Creation/revision dates 
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation">

      <sch:let name="missingPublication" value="count(gmd:date[gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_367']) = 0" />

      <sch:assert
        test="not($missingPublication)"
      >PublicationDate</sch:assert>

      <sch:let name="missingCreation" value="count(gmd:date[gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_366']) = 0" />

      <sch:assert
        test="not($missingCreation)"
      >CreationDate</sch:assert>

    </sch:rule>-->

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date">

      <sch:let name="missing" value="not(string(gco:Date)) and not(string(gco:DateTime))
                    " />

      <sch:assert
        test="not($missing)"
      >MissingDate</sch:assert>
    </sch:rule>


    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType">

      <sch:let name="dateTypeCodelistLabel"
               value="gmd:CI_DateTypeCode/@codeListValue"/>

      <sch:let name="missing" value="not(string(gmd:CI_DateTypeCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:let name="isValid" value="($dateTypeCodelistLabel != '') and ($dateTypeCodelistLabel != gmd:CI_DateTypeCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >InvalidDateTypeCode</sch:assert>

    </sch:rule>

    <!-- Begin position 
    <sch:rule context="//gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement">

      <sch:let name="beginPosition" value="gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod//gml:beginPosition" />
      <sch:let name="missingBeginPosition" value="not(string($beginPosition))" />

      <sch:assert test="not($missingBeginPosition)">BeginDate</sch:assert>
      <sch:assert test="$missingBeginPosition or $beginPosition &gt; 0)">BeginPositionFormat</sch:assert>


      <sch:let name="endPosition" value="gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod//gml:endPosition" />
      <sch:let name="missingEndPosition" value="not(string($endPosition))" />

      <sch:assert test="$missingBeginPosition or $missingEndPosition or $endPosition &gt;= 0)">EndPosition</sch:assert>
    </sch:rule>-->


    <!-- Dataset language -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:language
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:language
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:language">

      <sch:let name="missing" value="not(string(gco:CharacterString))
               or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >DataLanguage</sch:assert>
    </sch:rule>

    <!-- Maintenance and frequency 
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">

      <sch:let name="missing" value="not(string(gmd:MD_MaintenanceFrequencyCode/@codeListValue))
               or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >MaintenanceFrequency</sch:assert>


      <sch:let name="maintenanceFrequencyCodelistLabel"
               value="gmd:MD_MaintenanceFrequencyCode/@codeListValue"/>

      <sch:let name="isValid" value="($maintenanceFrequencyCodelistLabel != '') and ($maintenanceFrequencyCodelistLabel != gmd:MD_MaintenanceFrequencyCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >InvalidMaintenanceFrequency</sch:assert>
    </sch:rule>-->


    <!-- Cited Responsible Party - Role 
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role
      |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role">

      <sch:let name="roleCodelistLabel"
               value="gmd:CI_RoleCode/@codeListValue"/>

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
        or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >MissingCitedResponsibleRole</sch:assert>

      <sch:let name="isValid" value="($roleCodelistLabel != '') and ($roleCodelistLabel != gmd:CI_RoleCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >InvalidCitedResponsibleRole</sch:assert>

    </sch:rule>-->


    <!-- Core Subject Thesaurus 
    <sch:rule context="//gmd:identificationInfo/gmd:MD_DataIdentification
            |//*[@gco:isoType='gmd:MD_DataIdentification']
            |//*[@gco:isoType='srv:SV_ServiceIdentification']">

<sch:let name="coreSubjectThesaurusExists"
               value="count(gmd:descriptiveKeywords[*/gmd:thesaurusName/*/gmd:title/*/text() = 'Government of Canada Core Subject Thesaurus' or
              */gmd:thesaurusName/*/gmd:title/*/text() = 'Thésaurus des sujets de base du gouvernement du Canada']) > 0" />

      <sch:assert test="$coreSubjectThesaurusExists">CoreSubjectThesaurusMissing</sch:assert>
    </sch:rule>-->

    <!-- Access constraints 
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints">

      <sch:let name="missing" value="not(string(gmd:MD_RestrictionCode/@codeListValue))" />

      <sch:assert
        test="not($missing)"
      >MissingAccessConstraints</sch:assert>

      <sch:let name="accessConstraintsCodelistLabel"
               value="gmd:MD_RestrictionCode/@codeListValue"/>

      <sch:let name="isValid" value="($accessConstraintsCodelistLabel != '') and ($accessConstraintsCodelistLabel != gmd:MD_RestrictionCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >InvalidAccessConstraints</sch:assert>
    </sch:rule>-->

    <!-- Use constraints 
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints">

      <sch:let name="missing" value="not(string(gmd:MD_RestrictionCode/@codeListValue))" />

      <sch:assert
        test="not($missing)"
      >MissingUseConstraints</sch:assert>

      <sch:let name="useConstraintsCodelistLabel"
               value="gmd:MD_RestrictionCode/@codeListValue"/>

      <sch:let name="isValid" value="($useConstraintsCodelistLabel != '') and ($useConstraintsCodelistLabel != gmd:MD_RestrictionCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >InvalidUseConstraints</sch:assert>
    </sch:rule>-->
  </sch:pattern>


  
  <sch:pattern>
<!-- Distribution - Resources 
    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">

      <sch:let name="missing" value="not(string(.)) and not(string(../../../../gmd:onLine[@xlink:role!=../../../@xlink:role and @xlink:title=../../../@xlink:title]/gmd:CI_OnlineResource/gmd:linkage/gmd:URL))
                and (string(../../gmd:protocol/gco:CharacterString) or
                string(../../gmd:name/gco:CharacterString) or
                string(../../../../gmd:onLine[@xlink:role!=../../../@xlink:role and @xlink:title=../../../@xlink:title]/gmd:CI_OnlineResource/gmd:name/gco:CharacterString) or
                string(../../../../gmd:onLine[@xlink:role!=../../../@xlink:role and @xlink:title=../../../@xlink:title]/gmd:CI_OnlineResource/gmd:description/gco:CharacterString) or
                string(../../gmd:description/gco:CharacterString))"
      />

      <sch:assert
        test="not($missing)"
      >OnlineResourceUrl</sch:assert>

    </sch:rule>-->


    <!-- Online resource: MapResourcesREST, MapResourcesWMS
    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution">
      <sch:let name="smallcase" value="'abcdefghijklmnopqrstuvwxyz'" />
      <sch:let name="uppercase" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

      <sch:let name="mapRESTCount" value="count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'esri rest: map service']) +
                count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:fra-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'esri rest: map service'])" />

      <sch:assert test="$mapRESTCount &lt;= 2">MapResourcesRESTNumber</sch:assert>
      <sch:assert test="$mapRESTCount = 0 or $mapRESTCount = 2 or $mapRESTCount &gt; 2">MapResourcesREST</sch:assert>

      <sch:let name="mapWMSCount" value="count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'ogc:wms']) +
                count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:fra-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'ogc:wms'])" />

      <sch:assert test="$mapWMSCount &lt;= 2">MapResourcesWMSNumber</sch:assert>
      <sch:assert test="$mapWMSCount = 0 or $mapWMSCount = 2 or $mapWMSCount &gt; 2">MapResourcesWMS</sch:assert>
    </sch:rule>-->

    <!-- Distribution - Format 
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:name">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >DistributionFormatName</sch:assert>

      <sch:let name="distribution-formats" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Resource_Formats.rdf'), '\\', '/')))"/>

      <sch:let name="distributionFormat" value="gco:CharacterString" />

      <sch:assert test="($missing) or (string($distribution-formats//rdf:Description[normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char]) = $distributionFormat]))">DistributionFormatInvalid</sch:assert>

    </sch:rule>


    <sch:rule context="//gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:version">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >DistributionFormatVersion</sch:assert>

    </sch:rule>-->

    <!-- Distributor - Role 
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:role">

      <sch:let name="roleCodelistLabel"
               value="gmd:CI_RoleCode/@codeListValue"/>

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
        or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >MissingDistributorRole</sch:assert>

      <sch:let name="isValid" value="($roleCodelistLabel != '') and ($roleCodelistLabel != gmd:CI_RoleCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >InvalidDistributorRole</sch:assert>
    </sch:rule>-->
  </sch:pattern>
</sch:schema>
