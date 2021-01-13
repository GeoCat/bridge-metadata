<?xml version="1.0" encoding="UTF-8"?> <xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:eml="eml://ecoinformatics.org/eml-2.1.1" 
    xmlns:stmml="http://www.xml-cml.org/schema/stmml" 
    xmlns:sw="eml://ecoinformatics.org/software-2.1.1" 
    xmlns:cit="eml://ecoinformatics.org/literature-2.1.1" 
    xmlns:ds="eml://ecoinformatics.org/dataset-2.1.1" 
    xmlns:prot="eml://ecoinformatics.org/protocol-2.1.1" 
    xmlns:doc="eml://ecoinformatics.org/documentation-2.1.1" 
    xmlns:res="eml://ecoinformatics.org/resource-2.1.1" 
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

<xsl:import href="iso2eml-party.xsl"/>
<xsl:import href="iso2eml-coverage.xsl"/>
<xsl:import href="iso2eml-project.xsl"/>

<xsl:output method="xml" encoding="UTF-8" indent="yes" />
<xsl:strip-space elements="*" />

<xsl:template match="/gmd:MD_Metadata">
<eml:eml>
    <xsl:attribute name="xsi:schemaLocation">eml://ecoinformatics.org/eml-2.1.1 ~/development/eml/eml.xsd</xsl:attribute>
    <!-- Add the packageId -->
    <xsl:attribute name="packageId"><xsl:value-of select="normalize-space(gmd:fileIdentifier/gco:CharacterString)"/></xsl:attribute>
    <xsl:attribute name="system"><xsl:value-of select="'knb'"/></xsl:attribute>
    <xsl:attribute name="scope"><xsl:value-of select="'system'"/></xsl:attribute>
    <dataset>
        <!-- Add the title -->
        <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString">
            <title><xsl:value-of select="normalize-space(.)"/></title>
        </xsl:for-each>
        
        <!-- Add creators -->
        <xsl:call-template name="creators">
            <xsl:with-param name="doc" select="." />
        </xsl:call-template>

        <!-- Add additional parties -->
        <xsl:call-template name="additional-parties">
            <xsl:with-param name="doc" select="." />
        </xsl:call-template>

        <!-- Add the pubDate if available -->
        <xsl:if test="gmd:dateStamp/gco:DateTime != ''">
            <pubDate>
                <xsl:choose>
                    <xsl:when test="contains(gmd:dateStamp/gco:DateTime, 'T')">
                        <xsl:value-of select="normalize-space(substring-before(gmd:dateStamp/gco:DateTime, 'T'))" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(gmd:dateStamp/gco:DateTime)" />
                    </xsl:otherwise>
                </xsl:choose>
            </pubDate>
        </xsl:if>
            
        <!-- Add the language -->
        <xsl:if test="gmd:language/gco:CharacterString != ''">
            <language><xsl:value-of select="normalize-space(gmd:language/gco:CharacterString)" /></language>           
        </xsl:if>
        
        <!-- Add the abstract -->
        <abstract>
            <para><xsl:value-of select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gco:CharacterString)" /></para>
        </abstract>
        
        <!-- Add keywords -->
        <xsl:if test="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords != ''">
            <xsl:call-template name="keywords">
                <xsl:with-param name="keys" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords" />
            </xsl:call-template>
        </xsl:if>

        <!-- Add any gmd:topicCategory fields as keywords too -->
        <xsl:if test="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory != ''">
            <xsl:call-template name="topics">
                <xsl:with-param name="topics" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory" />
            </xsl:call-template>
        </xsl:if>

        <!-- Add intellectual rights -->
        <!-- 
            Note these rules are specific to the arcticdata.io content, 
            and will need to be generalized
        -->
        <xsl:choose>
            <xsl:when test="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_Constraints/gmd:useLimitation">
                <!-- Transfer MD_Constraints/useLimitation directly -->
                <intellectualRights>
                    <para>
                        <xsl:value-of select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_Constraints/gmd:useLimitation/gco:CharacterString)" />
                    </para>
                </intellectualRights>
            </xsl:when>
            <xsl:otherwise>
                
                <!-- Assign a CC-BY license -->
                <intellectualRights>
                    <para>
                        <xsl:text>This work is licensed under the Creative Commons Attribution 4.0 International License.To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/.</xsl:text>
                    </para>
                </intellectualRights>
                
            </xsl:otherwise>
        </xsl:choose>

        <!-- Add distribution -->

        <!-- Add coverage -->
        <xsl:call-template name="coverage" />
            
        <!-- Add contacts -->
        <xsl:call-template name="contacts">
            <xsl:with-param name="doc" select="." />
        </xsl:call-template>

        
        <!-- Add the publisher -->
        <xsl:call-template name="publishers">
            <xsl:with-param name="doc" select="." />
        </xsl:call-template>

        
        <!-- Add the pubPlace  -->
        
        <!-- Add the methods   -->
        
        <!-- Add the project   -->
        <xsl:call-template name="project">
            <xsl:with-param name="doc" select="." />
        </xsl:call-template>
        
        <!-- Add entities      -->
        
    </dataset>
</eml:eml>
</xsl:template>

<!-- Process Keywords and associated thesuarus entries -->
<xsl:template name="keywords">
    <xsl:param name = "keys" />
    <xsl:for-each select="$keys">
        <xsl:variable name="kw-type" select="./gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue" />
        <keywordSet>    
            <xsl:for-each select="./gmd:MD_Keywords/gmd:keyword/gco:CharacterString">
                <keyword>
                    <!-- ISO: discipline, place, stratum, temporal, theme -->
                    <!-- EML:             place, stratum, temporal, theme, taxonomic -->
                    <xsl:if test="$kw-type != '' and (
                        $kw-type = 'place' or $kw-type = 'stratum' or 
                        $kw-type = 'temporal' or $kw-type = 'theme')">
                        <xsl:attribute name="keywordType"><xsl:value-of select="normalize-space($kw-type)"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(.)" />
                </keyword>
            </xsl:for-each>
            <xsl:if test="./gmd:MD_Keywords/gmd:thesaurusName != ''">
                <xsl:choose>
                    <xsl:when test="./gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:collectiveTitle != ''">
                        <keywordThesaurus>
                            <xsl:value-of select="normalize-space(./gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:collectiveTitle/gco:CharacterString)" />
                        </keywordThesaurus>
                    </xsl:when>
                    <xsl:otherwise>
                        <keywordThesaurus>
                            <xsl:value-of select="normalize-space(./gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)" />
                        </keywordThesaurus>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </keywordSet>
    </xsl:for-each>
</xsl:template>

<!-- Process Topics -->
<xsl:template name="topics">
    <xsl:param name = "topics" />
    <xsl:for-each select="$topics">
        <keywordSet>    
            <xsl:for-each select="./gmd:MD_TopicCategoryCode">
                <keyword>
                    <xsl:value-of select="normalize-space(.)" />
                </keyword>
            </xsl:for-each>
            <keywordThesaurus>ISO 19115:2003 MD_TopicCategoryCode</keywordThesaurus>
        </keywordSet>
    </xsl:for-each>
</xsl:template>
</xsl:stylesheet>
