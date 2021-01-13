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

<xsl:output method="xml" encoding="UTF-8" indent="yes" />
<xsl:strip-space elements="*" />

<!-- Some useful reference resources:
     CI_ResponsibleParty: https://wiki.earthdata.nasa.gov/display/NASAISO/Individuals,+Organizations,+and+Roles
     CI_RoleCode: https://geo-ide.noaa.gov/wiki/index.php?title=ISO_19115_and_19115-2_CodeList_Dictionaries#CI_RoleCode
-->

<!-- Handle eml-party fields -->    
<xsl:template name="party">
    <xsl:param name = "party" />
    <xsl:apply-templates />   
    <xsl:if test="$party//gmd:voice/gco:CharacterString!=''">
        <phone><xsl:value-of select="normalize-space($party//gmd:voice/gco:CharacterString)"/></phone>
    </xsl:if>
    <xsl:if test="$party//gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString!=''">
        <electronicMailAddress><xsl:value-of select="normalize-space($party//gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString)"/></electronicMailAddress>
    </xsl:if>
    <xsl:if test="$party//gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL!=''">
        <onlineUrl><xsl:value-of select="normalize-space($party//gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL)"/></onlineUrl>
    </xsl:if>
</xsl:template>

<!-- Add an individualName -->
<xsl:template match="gmd:individualName">
    <individualName>
        <surName><xsl:value-of select="normalize-space(gco:CharacterString)"/></surName>
    </individualName>
</xsl:template>

<!-- Add an organizationName -->
<xsl:template match="gmd:organisationName">
    <organizationName><xsl:value-of select="normalize-space(gco:CharacterString)"/></organizationName>
</xsl:template>

<!-- Add a positionName -->
<xsl:template match="gmd:positionName">
    <positionName><xsl:value-of select="normalize-space(gco:CharacterString)"/></positionName>
</xsl:template>

<!-- voice, email, and role are all noops so they can be reordered correctly -->
<xsl:template match="gmd:voice" />
<xsl:template match="gmd:electronicMailAddress" />
<xsl:template match="gmd:role" />
<xsl:template match="gmd:onlineResource" />

<!-- Add an Address -->
<xsl:template match="gmd:CI_Address"> 
    <xsl:if test="gmd:deliveryPoint/gco:CharacterString!='' or gmd:city/gco:CharacterString!='' or gmd:administrativeArea/gco:CharacterString!='' or gmd:postalCode/gco:CharacterString!='' or gmd:country/gco:CharacterString!=''">
    <address>
        <xsl:if test="gmd:deliveryPoint/gco:CharacterString!=''">
            <deliveryPoint><xsl:value-of select="normalize-space(gmd:deliveryPoint/gco:CharacterString)"/></deliveryPoint>
        </xsl:if>
        <xsl:if test="gmd:city/gco:CharacterString!=''">
            <city><xsl:value-of select="normalize-space(gmd:city/gco:CharacterString)"/></city>
        </xsl:if>
        <xsl:if test="gmd:administrativeArea/gco:CharacterString!=''">
            <administrativeArea><xsl:value-of select="normalize-space(gmd:administrativeArea/gco:CharacterString)"/></administrativeArea>
        </xsl:if>
        <xsl:if test="gmd:postalCode/gco:CharacterString!=''">
            <postalCode><xsl:value-of select="normalize-space(gmd:postalCode/gco:CharacterString)"/></postalCode>
        </xsl:if>
        <xsl:if test="gmd:country/gco:CharacterString!=''">
            <country><xsl:value-of select="normalize-space(gmd:country/gco:CharacterString)"/></country>
        </xsl:if>
    </address>
    </xsl:if>
</xsl:template>

<!-- Add creator -->
<xsl:template name="creators">
    <xsl:param name = "doc" />
    <xsl:choose>
        <!-- First add any authors from the gmd:citation -->
        <xsl:when test='$doc/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="author"]]!=""'>
            <xsl:for-each select='gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="author"]]'>
                <creator>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                </creator>
            </xsl:for-each>
        </xsl:when>
        <!-- Alternatively, add authors from anywhere in the document -->
        <xsl:when test='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="author"]] != "" '>
            <xsl:for-each select='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="author"]]'>
                <creator>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                </creator>
            </xsl:for-each>
        </xsl:when>
        <!-- Alternatively, add principalInvestigators from anywhere in the document -->
        <xsl:when test='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="principalInvestigator"]] != "" '>
            <xsl:for-each select='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="principalInvestigator"]]'>
                <creator>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                </creator>
            </xsl:for-each>
        </xsl:when>
        <!-- Alternatively, add pointOfContact from the citation in the document -->
        <xsl:when test='$doc/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="pointOfContact"]] != "" '>
            <xsl:for-each select='$doc/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="pointOfContact"]]'>
                <creator>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                </creator>
            </xsl:for-each>
        </xsl:when>
        <!-- Alternatively, add pointOfContact from anywhere in the document -->
        <xsl:when test='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="pointOfContact"]] != "" '>
            <xsl:for-each select='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="pointOfContact"]]'>
                <creator>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                </creator>
            </xsl:for-each>
        </xsl:when>
        <!-- Finally, if all else fails, add the Arctic Data Center -->
        <xsl:otherwise>
            <creator>
                <organizationName>NSF Arctic Data Center</organizationName>
            </creator>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
        
<!-- Add contacts -->
<xsl:template name="contacts">
    <xsl:param name = "doc" />
    <xsl:choose>
        <!-- Add contacts from the citation in the document -->
        <xsl:when test='$doc/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="pointOfContact"]]!=""'>
            <xsl:for-each select='gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="pointOfContact"]]'>
                <contact>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                </contact>
            </xsl:for-each>
        </xsl:when>
        <!-- Alternatively, add contacts from anywhere in the document -->
        <xsl:when test='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="pointOfContact"]] != "" '>
            <xsl:for-each select='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="pointOfContact"]]'>
                <contact>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                </contact>
            </xsl:for-each>
        </xsl:when>
        <!-- Alternatively, add the first author as a contact -->
        <!--
        <xsl:when test='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="author"]] != "" '>
            <contact>
                <xsl:call-template name="party">
                    <xsl:with-param name="party" select = '$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="author"]][1]' />
                </xsl:call-template>
            </contact>
        </xsl:when>
        -->
        <!-- Finally, if all else fails, add the Arctic Data Center -->
        <xsl:otherwise>
            <contact>
                <organizationName>NSF Arctic Data Center</organizationName>
            </contact>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Add publishers
    First, check to see if publishers are listed in the gmd:citation, and if so, use them;
    If not, then search the whole document and use any found.  This avoids duplication.
-->
<xsl:template name="publishers">
    <xsl:param name = "doc" />
    <!-- publisher -->
    <xsl:choose>
        <xsl:when test='$doc/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="publisher"]]!=""'>
            <xsl:for-each select='gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="publisher"]]'>
                <publisher>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                </publisher>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:for-each select='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="publisher"]]'>
                <publisher>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                </publisher>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Add associatedParty: principalInvestigator
    First, check to see if principalInvestigators are listed in the gmd:citation, and if so, use them;
    If not, then search the whole document and use any found.  This avoids duplication.
-->
<xsl:template name="additional-parties">
    <xsl:param name = "doc" />
    <!-- Roles to be handled: originator|principalInvestigator|resourceProvider|distributor -->

    <!-- principalInvestigators -->
    <xsl:choose>
        <xsl:when test='$doc/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="principalInvestigator"]]!=""'>
            <xsl:for-each select='gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="principalInvestigator"]]'>
                <associatedParty>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                    <role>principalInvestigator</role>
                </associatedParty>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:for-each select='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="principalInvestigator"]]'>
                <associatedParty>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                    <role>principalInvestigator</role>
                </associatedParty>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>

    <!-- coPrincipalInvestigator -->
    <xsl:choose>
        <xsl:when test='$doc/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="coPrincipalInvestigator"]]!=""'>
            <xsl:for-each select='gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="coPrincipalInvestigator"]]'>
                <associatedParty>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                    <role>coPrincipalInvestigator</role>
                </associatedParty>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:for-each select='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="coPrincipalInvestigator"]]'>
                <associatedParty>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                    <role>coPrincipalInvestigator</role>
                </associatedParty>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>

    <!-- collaboratingPrincipalInvestigator -->
    <xsl:choose>
        <xsl:when test='$doc/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="collaboratingPrincipalInvestigator"]]!=""'>
            <xsl:for-each select='gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="collaboratingPrincipalInvestigator"]]'>
                <associatedParty>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                    <role>collaboratingPrincipalInvestigator</role>
                </associatedParty>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:for-each select='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="collaboratingPrincipalInvestigator"]]'>
                <associatedParty>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                    <role>collaboratingPrincipalInvestigator</role>
                </associatedParty>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>

    <!-- originators -->
    <xsl:choose>
        <xsl:when test='$doc/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="originator"]]!=""'>
            <xsl:for-each select='gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="originator"]]'>
                <associatedParty>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                    <role>originator</role>
                </associatedParty>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:for-each select='$doc//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode[@codeListValue="originator"]]'>
                <associatedParty>
                    <xsl:call-template name="party">
                        <xsl:with-param name="party" select = "." />
                    </xsl:call-template>
                    <role>originator</role>
                </associatedParty>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
