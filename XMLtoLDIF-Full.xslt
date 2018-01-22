<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:a="http://www.microsoft.com/mms/mmsml/v2">
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
  <xsl:output media-type="text" omit-xml-declaration="yes"  encoding="ISO-8859-1" indent="no" />
  <xsl:template match="/">
    <xsl:text xml:space="preserve">
version: 1.0

</xsl:text>
    <xsl:apply-templates select="a:mmsml/a:directory-entries" />
  </xsl:template>
  <!-- Identity records -->
  <xsl:template match="a:delta">
    <xsl:variable name="oid" select="a:dn-attr[@name='ObjectID']/a:dn-value/a:dn"/>
    <xsl:choose>
      <xsl:when test="a:primary-objectclass='SynchronizationRule'">
      </xsl:when>
      <xsl:when test="a:primary-objectclass='DetectedRuleEntry'">
      </xsl:when>
      <xsl:when test="a:primary-objectclass='ExpectedRuleEntry'">
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>dn: uid=</xsl:text>
        <xsl:value-of select="$oid" />
        <xsl:text xml:space="preserve">
objectClass: </xsl:text>
        <xsl:value-of select="a:objectclass/a:oc-value" />
        <xsl:text>
</xsl:text>
        <xsl:apply-templates select="a:attr/a:value"/>
        <xsl:apply-templates select="a:dn-attr/a:dn-value">
          <xsl:with-param name="suffix" select="''" />
        </xsl:apply-templates>
        <!-- Derive Inverse DNs -->
        <!--<xsl:apply-templates select="../a:delta[@dn!=$oid]/a:dn-attr[a:dn-value/a:dn/text()=$oid]" />-->
        <xsl:text xml:space="preserve">
</xsl:text>
        <xsl:text>&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Read Inverse DNs -->
  <xsl:template match="a:dn-attr">
    <xsl:variable name="derivedName">
      <xsl:choose>
        <xsl:when test="@name='Creator'"/>
        <xsl:when test="@name='Manager' 
                  or @name='Member' 
                  or @name='Owner' 
                  or @name='DisplayedOwner' 
                  or @name='ListOwners' 
                  or @name='groupAdministrators'">
          <xsl:value-of select="@name"/>
          <xsl:text>Of</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@name" />
          <xsl:text>_inverse</xsl:text>
          <!--
          -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$derivedName!=''">
      <xsl:call-template name="writeDN">
        <xsl:with-param name="name" select="$derivedName"/>
        <xsl:with-param name="value" select="../@dn"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <!-- Read DN attributes -->
  <xsl:template match="a:dn-value">
    <xsl:call-template name="writeDN">
      <xsl:with-param name="name" select="../@name"/>
      <xsl:with-param name="value" select="a:dn"/>
    </xsl:call-template>
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
  <!-- Write Non-DN attributes -->
  <xsl:template match="a:value">
    <xsl:variable name="value" select="text()"/>
    <xsl:value-of select="../@name" />
    <xsl:text>: </xsl:text>
    <xsl:call-template name="handleCRLF">
      <xsl:with-param name="val" select="."/>
    </xsl:call-template>
    <xsl:text xml:space="preserve">
</xsl:text>
  </xsl:template>
  <xsl:template name="handleCRLF">
    <xsl:param name="val"/>
    <xsl:choose>
      <xsl:when test="contains($val,'&#10;')">
        <xsl:value-of select="substring-before($val,'&#10;')" disable-output-escaping="yes"/>
        <xsl:text>&#10; </xsl:text>
        <xsl:call-template name="handleCRLF">
          <xsl:with-param name="val" select="substring-after($val,'&#10;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$val" disable-output-escaping="yes" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>