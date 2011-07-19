<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Benjamin Erb -->
<!DOCTYPE stylesheet [
<!ENTITY space "<xsl:text> </xsl:text>">
<!ENTITY tab "<xsl:text>	</xsl:text>">
<!ENTITY cr "<xsl:text>
</xsl:text>">
]>

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:api="http://www.ioexception.de/rest-api-doc">

<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

	<xsl:variable name="baseURI"><xsl:value-of select="api:api/api:baseuri"></xsl:value-of></xsl:variable>

	<xsl:template match="*">
	</xsl:template>

	<xsl:template match="api:api">
        <xsl:text>= </xsl:text><xsl:value-of select="api:name"/><xsl:text> API Documentation =</xsl:text>&cr;
        <xsl:text>This page has been auto generated, please don't edit!</xsl:text>&cr;&cr;
		<xsl:text>Version: </xsl:text><xsl:apply-templates select="api:version" />&cr;&cr;
		<xsl:text>Base URI: </xsl:text><xsl:apply-templates select="api:baseuri" />&cr;&cr;
		<xsl:text>Authentication: </xsl:text><xsl:apply-templates select="api:authentication" />&cr;
		&cr;
        <xsl:text>== Description ==</xsl:text>&cr;
        <xsl:apply-templates select="api:description" />&cr;
        &cr;
        <xsl:text>== Resources ==</xsl:text>&cr;
		<xsl:for-each select="//api:resource">
			<xsl:sort select="api:name"/>
            <xsl:apply-templates select="." />&cr;			
		</xsl:for-each>		
	</xsl:template>
	
	<xsl:template match="api:resource">
        <xsl:text>=== </xsl:text><xsl:value-of select="api:name"/><xsl:text> ===</xsl:text>&cr;
        <xsl:apply-templates select="api:description" />&cr;
        &cr;
		<xsl:for-each select="api:operation">
		    <xsl:sort select="api:name"/>
		    <xsl:apply-templates select="." />&cr;
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="api:operation">
        <xsl:variable name="resourceURI">
           <xsl:for-each select="api:path/node()">
		       <xsl:choose>
        			<xsl:when test="@description">
						<xsl:text>{</xsl:text>
							<xsl:value-of select="." />
						<xsl:text>}</xsl:text>
					</xsl:when>
					<xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
				</xsl:choose>
            </xsl:for-each>
        </xsl:variable>			    
	    
        <xsl:text>==== </xsl:text>
        <xsl:value-of select="api:request/api:method"/>&space;
        <xsl:value-of select="$resourceURI" />
        <xsl:text> ====</xsl:text>&cr;

        <xsl:text>{| class="wikitable"</xsl:text>&cr;
        
        <xsl:text>|-</xsl:text>&cr;
        <xsl:text>! Description</xsl:text>&cr;
        <xsl:text>| </xsl:text><xsl:apply-templates select="api:description" />&cr;
        
        <xsl:text>|-</xsl:text>&cr;
        <xsl:text>! URL parameters</xsl:text>&cr;
		<xsl:choose>
			<xsl:when test="count(api:path/api:param/@description) > 0">
                <xsl:for-each select="api:path/api:param">
        	        <xsl:text>| </xsl:text>        			    
					<xsl:value-of select="." />
					<xsl:text>: </xsl:text>
    				<xsl:value-of select="@description" />&cr;
                </xsl:for-each> 			        

			</xsl:when>
			<xsl:otherwise>
			    <xsl:text>| none</xsl:text>&cr;
			</xsl:otherwise>
		</xsl:choose>

        <xsl:text>|-</xsl:text>&cr;
        <xsl:text>! Request parameters</xsl:text>&cr;
		<xsl:choose>
			<xsl:when test="count(api:request/api:params/api:param) > 0">
                <xsl:text>| </xsl:text>&cr;
                <xsl:for-each select="api:request/api:params/api:param">
            	    <xsl:text>* </xsl:text>
            	    <xsl:value-of select="@name" /> 
            	    <xsl:text> (</xsl:text>
            	    <xsl:if test="@list = 'true'">
            	        <xsl:text>array of </xsl:text>
            	    </xsl:if>
            	    <xsl:value-of select="@type" />
            	    <xsl:text>): </xsl:text>
            	    <xsl:apply-templates select="api:description"/>&cr;
                </xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
			    <xsl:text>| none</xsl:text>&cr;
			</xsl:otherwise>
		</xsl:choose>
        
        <xsl:text>|-</xsl:text>&cr;
        <xsl:text>! Authentication</xsl:text>&cr;
        <xsl:text>| </xsl:text><xsl:apply-templates select="api:request/api:authentication" />&cr;   			        	
        
        <xsl:text>|-</xsl:text>&cr;
        <xsl:text>! Caching</xsl:text>&cr;
        <xsl:text>| </xsl:text><xsl:apply-templates select="api:caching" />&cr;

        <xsl:text>|-</xsl:text>&cr;
        <xsl:text>! Response status codes</xsl:text>&cr;
		<xsl:text>| &cr;</xsl:text>
		<xsl:for-each select="api:response/api:responses/api:answer">
			<xsl:call-template name="statuscode">
				<xsl:with-param name="code"><xsl:value-of select="@code" /></xsl:with-param>
			</xsl:call-template>			
			<xsl:value-of select="." />&cr;
		</xsl:for-each>

        <xsl:text>|-</xsl:text>&cr;
        <xsl:text>! Response formats</xsl:text>&cr;
        <xsl:for-each select="api:formats/api:format">
        	<xsl:text>| </xsl:text><xsl:apply-templates select="." />&cr;   			        	
        </xsl:for-each>

		<xsl:if test="count(api:response/api:entities/api:entity) > 0">
            <xsl:text>|-</xsl:text>&cr;
            <xsl:text>! Response entities</xsl:text>&cr;
            <xsl:text>| </xsl:text>&cr;
			<xsl:for-each select="api:response/api:entities/api:entity">
                <xsl:text>* </xsl:text>
                <xsl:apply-templates select="api:description" />&cr;
			    <xsl:apply-templates select="api:code" />&cr;
			</xsl:for-each>
        </xsl:if>
		        
        <xsl:text>|}</xsl:text>&cr;
	        
        <xsl:apply-templates select="api:request" />&cr;
        <xsl:apply-templates select="api:response" />&cr;	    
	</xsl:template>

	<xsl:template match="api:name">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="api:author">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="api:version">
		<xsl:apply-templates />
	</xsl:template>	
	
	<xsl:template match="api:baseuri">
		<xsl:apply-templates />
	</xsl:template>	
	
	<xsl:template match="api:description">
		<xsl:apply-templates />
	</xsl:template>	
	
	<xsl:template match="api:method">
		<xsl:apply-templates />		
	</xsl:template>

	<xsl:template match="api:authentication">
	    <xsl:choose>
    		<xsl:when test="@mandatory = 'true'">
    			<xsl:text>required</xsl:text>
    		</xsl:when>
    		<xsl:otherwise>
    		    <xsl:text>not required</xsl:text>
    		</xsl:otherwise>
    	</xsl:choose>
	</xsl:template>

	<xsl:template match="api:mandatory">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="api:type">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="api:responses">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="api:answer">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="api:entity">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="api:code">
        <xsl:text>&lt;source lang="</xsl:text><xsl:value-of select="@language" /><xsl:text>"&gt;</xsl:text>
		<xsl:apply-templates />&cr;
        <xsl:text>&lt;/source&gt;</xsl:text>&cr;
	</xsl:template>

	<xsl:template match="api:formats">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="api:format">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="api:path">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="api:param">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="api:b">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="api:it">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="api:tt">
		<xsl:apply-templates />
	</xsl:template>
		
	<xsl:template name="statuscode">
        <xsl:text>* </xsl:text>
		<xsl:param name="code" />
		
		<xsl:value-of select="$code" /><xsl:text> ("</xsl:text>
		<xsl:choose>
			<xsl:when test="$code = '100'">Continue</xsl:when>
			<xsl:when test="$code = '101'">Switching Protocols</xsl:when>
			<xsl:when test="$code = '200'">OK</xsl:when>
			<xsl:when test="$code = '201'">Created</xsl:when>
			<xsl:when test="$code = '202'">Accepted</xsl:when>
			<xsl:when test="$code = '203'">Non-Authoritative Information</xsl:when>
			<xsl:when test="$code = '204'">No Content</xsl:when>
			<xsl:when test="$code = '205'">Reset Content</xsl:when>
			<xsl:when test="$code = '206'">Partial Content</xsl:when>
			<xsl:when test="$code = '300'">Multiple Choices</xsl:when>
			<xsl:when test="$code = '301'">Moved Permanently</xsl:when>
			<xsl:when test="$code = '302'">Found</xsl:when>
			<xsl:when test="$code = '303'">See Other</xsl:when>
			<xsl:when test="$code = '304'">Not Modified</xsl:when>
			<xsl:when test="$code = '305'">Use Proxy</xsl:when>
			<xsl:when test="$code = '306'">Switch Proxy</xsl:when>
			<xsl:when test="$code = '307'">Temporary Redirect </xsl:when>
			<xsl:when test="$code = '400'">Bad Request</xsl:when>
			<xsl:when test="$code = '401'">Unauthorized</xsl:when>
			<xsl:when test="$code = '402'">Payment Required</xsl:when>
			<xsl:when test="$code = '403'">Forbidden</xsl:when>
			<xsl:when test="$code = '404'">Not Found</xsl:when>
			<xsl:when test="$code = '405'">Method Not Allowed</xsl:when>
			<xsl:when test="$code = '406'">Not Acceptable</xsl:when>
			<xsl:when test="$code = '407'">Proxy Authentication Required</xsl:when>
			<xsl:when test="$code = '408'">Request Timeout</xsl:when>
			<xsl:when test="$code = '409'">Conflict</xsl:when>
			<xsl:when test="$code = '410'">Gone</xsl:when>
			<xsl:when test="$code = '411'">Length Required</xsl:when>
			<xsl:when test="$code = '412'">Precondition Failed</xsl:when>
			<xsl:when test="$code = '413'">Request Entity Too Large</xsl:when>
			<xsl:when test="$code = '414'">Request-URI Too Long</xsl:when>
			<xsl:when test="$code = '415'">Unsupported Media Type</xsl:when>
			<xsl:when test="$code = '416'">Requested Range Not Satisfiable</xsl:when>
			<xsl:when test="$code = '417'">Expectation Failed</xsl:when>
			<xsl:when test="$code = '500'">Internal Server Error</xsl:when>
			<xsl:when test="$code = '501'">Not Implemented</xsl:when>
			<xsl:when test="$code = '502'">Bad Gateway</xsl:when>
			<xsl:when test="$code = '503'">Service Unavailable</xsl:when>
			<xsl:when test="$code = '504'">Gateway Timeout</xsl:when>
			<xsl:when test="$code = '505'">HTTP Version Not Supported</xsl:when>
			<xsl:otherwise>custom</xsl:otherwise>
		</xsl:choose> 
		<xsl:text>"):  </xsl:text>
	</xsl:template>
	
	<xsl:template match="api:api/api:authentication">
    	<xsl:value-of select="api:type" />
		<xsl:for-each select="api:type[position() > 1]">
    		<xsl:text>, </xsl:text><xsl:value-of select="." />
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
