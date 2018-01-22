<?xml version="1.0"?>
<!--
Copyright (c) 2012, Unify Solutions Pty Ltd
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:a="http://www.microsoft.com/mms/mmsml/v2">
  <xsl:output media-type="text" omit-xml-declaration="yes"  encoding="ISO-8859-1" indent="no" />
  <xsl:template match="/">
    <xsl:text>
version: 1.0
    </xsl:text>
    <xsl:apply-templates select="a:mmsml/a:directory-entries/a:delta">
      <xsl:sort select="@dn"/>
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template match="a:delta">
    <xsl:choose>
      <xsl:when test="a:primary-objectclass='SynchronizationRule'">
      </xsl:when>
      <xsl:when test="a:primary-objectclass='DetectedRuleEntry'">
      </xsl:when>
      <xsl:when test="a:primary-objectclass='ExpectedRuleEntry'">
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <!-- DELETE -->
          <xsl:when test="@operation = 'delete'">
            <xsl:text>
dn: uid=</xsl:text>
            <xsl:value-of select="@dn" />
            <xsl:text>
changetype: delete 
</xsl:text>
          </xsl:when>
          <!-- ADD -->
          <xsl:when test="@operation = 'add'">
            <xsl:text>
dn: uid=</xsl:text>
            <xsl:value-of select="@dn" />
            <xsl:text>
changetype: add
objectClass: </xsl:text>
            <xsl:value-of select="a:objectclass/a:oc-value" />
            <xsl:text>
</xsl:text>
            <xsl:apply-templates select="a:attr/a:value" mode="add" />
            <xsl:apply-templates select="a:dn-attr/a:dn-value" mode="add" />
          </xsl:when>
          <!-- MODIFY -->
          <xsl:otherwise>
			<xsl:if test="count(a:attr/a:value) > 0">		  
				<xsl:apply-templates select="a:attr[@multivalued = 'true']/a:value" mode="multiValue" />
				<xsl:apply-templates select="a:dn-attr[@multivalued='true']/a:dn-value" mode="multiValue" />
				<xsl:if test="count(a:attr[@multivalued='false']) > 0 or count(a:dn-attr[@multivalued='false']) > 0">
				  <xsl:text>
dn: uid=</xsl:text>
				  <xsl:value-of select="@dn" />
				  <xsl:text>
changetype: modify</xsl:text>
				</xsl:if>
				<xsl:text>
</xsl:text>
				<xsl:apply-templates select="a:attr[@multivalued='false']" mode="singleValue" />
				<xsl:apply-templates select="a:dn-attr[@multivalued='false']" mode="singleValue" />
			</xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Read Non-DN values (ADD) -->
  <xsl:template match="a:value" mode="add">
    <xsl:call-template name="writeNonDN">
      <xsl:with-param name="name" select="../@name"/>
      <xsl:with-param name="value" select="normalize-space(.)"/>
    </xsl:call-template>
  </xsl:template>
  <!-- Read DN values (ADD) -->
  <xsl:template match="a:dn-value" mode="add">
    <xsl:call-template name="writeDN">
      <xsl:with-param name="name" select="../@name"/>
      <xsl:with-param name="value" select="normalize-space(a:dn)"/>
    </xsl:call-template>
  </xsl:template>
  <!-- Read Non-DN values (MV) -->
  <xsl:template match="a:value" mode="multiValue">
    <xsl:text>
dn: uid=</xsl:text>
    <xsl:value-of select="../../@dn" />
    <xsl:text>
changetype: modify
</xsl:text>
    <xsl:call-template name="writeNonDN">
      <xsl:with-param name="name" select="@operation"/>
      <xsl:with-param name="value" select="../@name"/>
    </xsl:call-template>
    <xsl:call-template name="writeNonDN">
      <xsl:with-param name="name" select="../@name"/>
      <xsl:with-param name="value" select="normalize-space(.)"/>
    </xsl:call-template>
    <xsl:text>-
</xsl:text>
  </xsl:template>
  <!-- Read DN values (MV) -->
  <xsl:template match="a:dn-value" mode="multiValue">
    <xsl:text>
dn: uid=</xsl:text>
    <xsl:value-of select="../../@dn" />
    <xsl:text>
changetype: modify
</xsl:text>
    <xsl:call-template name="writeNonDN">
      <xsl:with-param name="name" select="@operation"/>
      <xsl:with-param name="value" select="../@name"/>
    </xsl:call-template>
    <xsl:call-template name="writeDN">
      <xsl:with-param name="name" select="../@name"/>
      <xsl:with-param name="value" select="normalize-space(a:dn)"/>
    </xsl:call-template>
    <xsl:text>-
</xsl:text>
  </xsl:template>
  <!-- Read Non-DN attributes (SV) -->
  <xsl:template match="a:attr" mode="singleValue">
    <xsl:choose>
      <xsl:when test="count(./a:value) = 1">
        <xsl:call-template name="writeNonDN">
          <xsl:with-param name="name" select="a:value/@operation"/>
          <xsl:with-param name="value" select="@name"/>
        </xsl:call-template>
        <xsl:call-template name="writeNonDN">
          <xsl:with-param name="name" select="@name"/>
          <xsl:with-param name="value" select="normalize-space(a:value)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>replace: </xsl:text>
        <xsl:value-of select="@name" />
        <xsl:text>
</xsl:text>
        <xsl:call-template name="writeNonDN">
          <xsl:with-param name="name" select="@name"/>
          <xsl:with-param name="value" select="normalize-space(a:value[@operation = 'add'])"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>-
</xsl:text>
  </xsl:template>
  <!-- Read DN values (SV) -->
  <xsl:template match="a:dn-attr" mode="singleValue">
    <xsl:call-template name="writeNonDN">
      <xsl:with-param name="name">
        <xsl:choose>
          <xsl:when test="@operation='update'">
            <xsl:text>replace</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@operation"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="value" select="./@name"/>
    </xsl:call-template>
    <xsl:apply-templates select="a:dn-value" mode="singleValue" />
    <xsl:text>-
</xsl:text>
  </xsl:template>
  <!-- Read DN values (SV) -->
  <xsl:template match="a:dn-value" mode="singleValue">
    <xsl:choose>
      <xsl:when test="../@operation='update' and ./@operation='delete'"></xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="writeDN">
          <xsl:with-param name="name" select="../@name"/>
          <xsl:with-param name="value" select="normalize-space(a:dn)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Write Non-DN attributes -->
  <xsl:template name="writeNonDN">
    <xsl:param name="name" />
    <xsl:param name="value" />
    <xsl:value-of select="$name" />
    <xsl:text>: </xsl:text>
    <xsl:value-of select="$value" disable-output-escaping="yes" />
    <xsl:text>
</xsl:text>
  </xsl:template>
  <!-- Write DN attributes -->
  <xsl:template name="writeDN">
    <xsl:param name="name" />
    <xsl:param name="value" />
    <xsl:value-of select="$name" />
    <xsl:text>: </xsl:text>
    <xsl:if test="$name != 'ObjectID'">
      <xsl:text>uid=</xsl:text>
    </xsl:if>
    <xsl:value-of select="$value"/>
    <xsl:text xml:space="preserve">
</xsl:text>
  </xsl:template>
</xsl:stylesheet>