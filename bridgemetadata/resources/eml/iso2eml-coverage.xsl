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
	
	<!-- Match any geographic or temporal coverage elements -->
	<xsl:template name="coverage" match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent">
		<!-- Add EML geographic and temporal coverages, if available -->
			<!-- Add geographic coverages -->
            <xsl:variable name="bboxCount" select="count(.//gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox)" />
            <xsl:variable name="temporalCount" select="count(.//gmd:EX_Extent/gmd:temporalElement)" />
            <xsl:variable name="descriptionCount" select="count(.//gmd:EX_Extent/gmd:description)" />
            <xsl:variable name="exDescCount" select="count(.//gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicDescription)" />
            <xsl:if test="$temporalCount + $bboxCount &gt; 0">
        		<coverage>
                    <xsl:choose>
                        <xsl:when test="($descriptionCount + $exDescCount) &gt;= $bboxCount">

                            <xsl:variable name="descriptions" >
                                <xsl:if test="//gmd:EX_Extent/gmd:description">
                                    <xsl:for-each select=".//gmd:EX_Extent">
                                        <xsl:copy-of select="gmd:description" />
                                        <xsl:value-of select="'. '" />                                                           
                                    </xsl:for-each>                            
                                </xsl:if>
                            </xsl:variable>

                            <xsl:variable name="codeDescriptions" >
                                <xsl:for-each select=".//gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicDescription">
                                    <xsl:value-of select="gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString" />
                                        <xsl:if test="count(//gmd:EX_GeographicDescription) &gt; 1">
                                            <xsl:value-of select="', '" />
                                        </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            			
                            <xsl:apply-templates select=".//gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
                			    <xsl:with-param name="allDescriptions" select="concat($descriptions, $codeDescriptions)" />
                			</xsl:apply-templates> 
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:comment>No geographic description provided</xsl:comment>
                            <xsl:apply-templates select=".//gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
                			    <xsl:with-param name="allDescriptions" select="'No geographic description provided.'" />
                			</xsl:apply-templates> 
                        </xsl:otherwise>                
                    </xsl:choose>
			
        			<!-- Add temporal coverages -->
        			<xsl:apply-templates select=".//gmd:EX_Extent/gmd:temporalElement" />                
        		</coverage>
            </xsl:if>
			
	</xsl:template>
		
	<!-- Handle geographic bounding boxes -->
	<xsl:template match="gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
        <xsl:param name="allDescriptions" />
		<xsl:comment>Geographic coverage</xsl:comment>
		<!-- Handle geographic description -->
		<xsl:choose>
			<xsl:when test="$allDescriptions != ''">
				
        		<geographicCoverage>
        			<geographicDescription>
        				<xsl:value-of select="$allDescriptions" />
        			</geographicDescription>
        			<xsl:apply-templates select="../gmd:geographicElement/gmd:EX_GeographicBoundingBox" />
            		<!-- Add bounding coordinates -->
            		<boundingCoordinates>
            			<westBoundingCoordinate>
            				<xsl:value-of select="normalize-space(gmd:westBoundLongitude/gco:Decimal)" />
            			</westBoundingCoordinate>
            			<eastBoundingCoordinate>
            				<xsl:value-of select="normalize-space(gmd:eastBoundLongitude/gco:Decimal)" />
            			</eastBoundingCoordinate>
            			<northBoundingCoordinate>
            				<xsl:value-of select="normalize-space(gmd:northBoundLatitude/gco:Decimal)" />
            			</northBoundingCoordinate>
            			<southBoundingCoordinate>
            				<xsl:value-of select="normalize-space(gmd:southBoundLatitude/gco:Decimal)" />
            			</southBoundingCoordinate>
            		</boundingCoordinates>
        		</geographicCoverage>
				
			</xsl:when>
			<xsl:otherwise>
				
				<!-- Make up a description from the bounding box -->
				<xsl:if test=".//gmd:EX_GeographicBoundingBox">
					
					<geographicCoverage>
						<geographicDescription>
							<xsl:text>This research took place in the area bounded by: </xsl:text>
							<xsl:value-of select="normalize-space(gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal)" />
							<xsl:text> West,</xsl:text>
							<xsl:value-of select="normalize-space(gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal)" />
							<xsl:text> East,</xsl:text>
							<xsl:value-of select="normalize-space(gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal)" />
							<xsl:text> North,</xsl:text>
							<xsl:value-of select="normalize-space(gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal)" />
							<xsl:text> South.</xsl:text>
						</geographicDescription>
                		<!-- Add bounding coordinates -->
                		<boundingCoordinates>
                			<westBoundingCoordinate>
                				<xsl:value-of select="normalize-space(gmd:westBoundLongitude/gco:Decimal)" />
                			</westBoundingCoordinate>
                			<eastBoundingCoordinate>
                				<xsl:value-of select="normalize-space(gmd:eastBoundLongitude/gco:Decimal)" />
                			</eastBoundingCoordinate>
                			<northBoundingCoordinate>
                				<xsl:value-of select="normalize-space(gmd:northBoundLatitude/gco:Decimal)" />
                			</northBoundingCoordinate>
                			<southBoundingCoordinate>
                				<xsl:value-of select="normalize-space(gmd:southBoundLatitude/gco:Decimal)" />
                			</southBoundingCoordinate>
                		</boundingCoordinates>
					</geographicCoverage>
					
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	<!-- Handle temporal coverage elements -->
	<xsl:template name="temporalCoverage" match="gmd:EX_Extent/gmd:temporalElement">
		<xsl:comment>Temporal coverage</xsl:comment>
		<xsl:choose>
			<xsl:when test="gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod">
				
				<!-- We have a period, use rangeOfDates -->
				<temporalCoverage>
					<rangeOfDates>
						<beginDate>
							<xsl:choose>
								<xsl:when test="contains(gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition, 'T')">
									<calendarDate>
										<xsl:value-of select="normalize-space(substring-before(gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition, 'T'))" />
									</calendarDate>
									<time>
										<xsl:value-of select="normalize-space(substring-after(gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition, 'T'))" />									
									</time>								
								</xsl:when>
								<xsl:otherwise>
									<calendarDate>
										<xsl:value-of select="normalize-space(gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition)" />
									</calendarDate>								
								</xsl:otherwise>
							</xsl:choose>
						</beginDate>
						<endDate>
							<xsl:choose>
								<xsl:when test="contains(gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition, 'T')">
									<calendarDate>
										<xsl:value-of select="normalize-space(substring-before(gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition, 'T'))" />
									</calendarDate>
									<time>
										<xsl:value-of select="normalize-space(substring-after(gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition, 'T'))" />									
									</time>								
								</xsl:when>
								<xsl:otherwise>
									<calendarDate>
										<xsl:value-of select="normalize-space(gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition)" />
									</calendarDate>								
								</xsl:otherwise>
							</xsl:choose>
						</endDate>
					</rangeOfDates>
				</temporalCoverage>
			</xsl:when>
			<xsl:otherwise>
				
				<!-- No time period, look for time instant -->
				<xsl:if test="gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant">
					
					<temporalCoverage>
						<singleDateTime>
							<calendarDate>
								<xsl:value-of select="normalize-space(gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition)" />
							</calendarDate>
						</singleDateTime>
					</temporalCoverage>
					
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
