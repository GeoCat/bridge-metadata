<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
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

    <xsl:output method="xml" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />
    
    <!-- Match any gmd:credit elements, and if they are present, add a project entry with funding fields -->
    <xsl:template name="project">
        <xsl:param name = "doc" />
        <xsl:variable name="awardCount" select="count(./gmd:identificationInfo/gmd:MD_DataIdentification/gmd:credit)" />
        <!-- Add funding elements -->
        <xsl:if test="$awardCount &gt; 0">
            <project>
                <!-- Add the project title -->
                <title><xsl:value-of select="normalize-space(./gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title[1]/gco:CharacterString)"/></title>

                <!-- Add the project abstract -->
                <xsl:if test='./gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract[1]/gco:CharacterString != ""'>
                    <abstract><xsl:value-of select="normalize-space(./gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract[1]/gco:CharacterString)"/></abstract>
                </xsl:if>

                <!-- Add personnel from the PI list or the author list -->
                <xsl:choose>
                    <!-- Select PIs from the citation -->
                    <xsl:when test='$doc/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="principalInvestigator" or @codeListValue="coPrincipalInvestigator" or @codeListValue="collaboratingPrincipalInvestigator"]]!=""'>
                        <xsl:for-each select='gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="principalInvestigator" or @codeListValue="coPrincipalInvestigator" or @codeListValue="collaboratingPrincipalInvestigator"]]'>
                            <personnel>
                                <xsl:call-template name="party">
                                    <xsl:with-param name="party" select = "." />
                                </xsl:call-template>
                                <role>principalInvestigator</role>
                            </personnel>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- Alternatively, select PIs from anywhere in the doc -->
                    <xsl:when test='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="principalInvestigator" or @codeListValue="coPrincipalInvestigator" or @codeListValue="collaboratingPrincipalInvestigator"]] != ""'>
                        <xsl:for-each select='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="principalInvestigator" or @codeListValue="coPrincipalInvestigator" or @codeListValue="collaboratingPrincipalInvestigator"]]'>
                            <personnel>
                                <xsl:call-template name="party">
                                    <xsl:with-param name="party" select = "." />
                                </xsl:call-template>
                                <role>principalInvestigator</role>
                            </personnel>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- Otherwise, select the author anywhere in the document -->
                    <xsl:otherwise>
                        <xsl:for-each select='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="author"]]'>
                            <personnel>
                                <xsl:call-template name="party">
                                    <xsl:with-param name="party" select = "." />
                                </xsl:call-template>
                                <role>principalInvestigator</role>
                            </personnel>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- Add all of the funding from gmd:credit -->
                <funding>
                    <xsl:for-each select="./gmd:identificationInfo/gmd:MD_DataIdentification/gmd:credit">
                        <para><xsl:value-of select="."/></para>
                    </xsl:for-each>
                </funding>
            </project>
        </xsl:if>
            
    </xsl:template>
        
</xsl:stylesheet>
