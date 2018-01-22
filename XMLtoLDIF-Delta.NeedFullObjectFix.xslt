<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:a="http://www.microsoft.com/mms/mmsml/v2" xmlns:data="http://example.com/data">
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
  <xsl:output media-type="text" omit-xml-declaration="yes"  encoding="ISO-8859-1" />
  <!-- The following is an explicit collection of objects and attributes which you want to use in your IAFs for the Replay MA - this is in order to avoid "need-full-object" discovery errors -->
  <data:objecttypes xmlns="">
    <value>Person</value>
    <value>Group</value>
  </data:objecttypes>
  <data:attributes xmlns="">
    <value>MVObjectID</value>
    <value>Email</value>
    <value>ObjectSID</value>
    <value>ObjectID</value>
    <value>PreferredName</value>
    <value>OfficeLocation</value>
    <value>Email</value>
    <value>DisplayName</value>
    <value>AccountName</value>
    <value>Domain</value>
    <value>Description</value>
    <value>EmployeeID</value>
    <value>DisplayedOwnerOf</value>
    <value>ManagerOf</value>
    <value>MemberOf</value>
    <value>OwnerOf</value>
    <value>ListOwnersOf</value>
    <value>groupAdministratorsOf</value>
  </data:attributes>
  <xsl:variable name="objecttypes" select="document('')/xsl:stylesheet/data:objecttypes/value"/>
  <xsl:variable name="attributes" select="document('')/xsl:stylesheet/data:attributes/value"/>
  <xsl:template match="/">
    <xsl:text xml:space="preserve">version: 1.0
</xsl:text>
    <xsl:for-each select="a:mmsml/a:directory-entries">
      <xsl:sort select="a:delta/@dn"/>
      <xsl:apply-templates />
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="a:delta">
    <xsl:if test="a:primary-objectclass=$objecttypes">
      <xsl:if test="a:attr/@name=$attributes">
        <xsl:choose>
          <xsl:when test="@operation = 'delete'">
            <xsl:text xml:space="preserve">
dn: uid=</xsl:text>
            <xsl:value-of select="@dn" />
            <xsl:text xml:space="preserve">changetype: delete
</xsl:text>
          </xsl:when>
          <xsl:when test="@operation = 'add'">
            <xsl:text xml:space="preserve">
dn: uid=</xsl:text>
            <xsl:value-of select="@dn" />
            <xsl:text xml:space="preserve">
changetype: add
objectClass: </xsl:text>
            <xsl:value-of select="a:objectclass/a:oc-value/text()" disable-output-escaping="yes" />
            <xsl:text xml:space="preserve">
</xsl:text>
            <xsl:for-each select="a:attr">
              <xsl:choose>
                <xsl:when test="@name=$attributes">
                  <xsl:for-each select="a:value">
                    <xsl:value-of select="../@name" />: <xsl:value-of select="text()" disable-output-escaping="yes" /><xsl:text>
</xsl:text>
                  </xsl:for-each>
                </xsl:when>
              </xsl:choose>
            </xsl:for-each>
            <xsl:for-each select="a:dn-attr">
              <xsl:choose>
                <xsl:when test="@name=$attributes">
                  <xsl:for-each select="a:dn-value">
                    <xsl:value-of select="../@name" />: <xsl:if test="../@name != 'ObjectID'">
                      <xsl:text xml:space="preserve">uid=</xsl:text>
                    </xsl:if><xsl:value-of select="a:dn/text()" disable-output-escaping="yes"/><xsl:text>
</xsl:text>
                  </xsl:for-each>
                </xsl:when>
              </xsl:choose>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="count(./a:attr/a:value) > 0">
              <xsl:text xml:space="preserve">
dn: uid=</xsl:text>
              <xsl:value-of select="@dn" />
              <xsl:text xml:space="preserve">
changetype: modify
</xsl:text>
              <xsl:for-each select="a:attr">
                <xsl:choose>
                  <xsl:when test="@name=$attributes">
                    <xsl:choose>
                      <xsl:when test="@multivalued = 'true'">
                        <xsl:value-of select="a:value/@operation"/>
                        <xsl:text xml:space="preserve">: </xsl:text>
                        <xsl:value-of select="@name" />
                        <xsl:text>
</xsl:text>
                        <xsl:for-each select="a:value" >
                          <xsl:value-of select="../@name" />
                          <xsl:text xml:space="preserve">: </xsl:text>
                          <xsl:value-of select="text()" disable-output-escaping="yes" />
                          <xsl:text>
</xsl:text>
                        </xsl:for-each>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:choose>
                          <xsl:when test="count(./a:value) = 0">
                          </xsl:when>
                          <xsl:when test="count(./a:value) = 1">
                            <xsl:value-of select="a:value/@operation"/>
                            <xsl:text xml:space="preserve">: </xsl:text>
                            <xsl:value-of select="@name" />
                            <xsl:text xml:space="preserve">
</xsl:text>
                            <xsl:value-of select="@name" />
                            <xsl:text xml:space="preserve">: </xsl:text>
                            <xsl:value-of select="a:value/text()" disable-output-escaping="yes" />
                            <xsl:text xml:space="preserve">
-
</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text xml:space="preserve">replace: </xsl:text>
                            <xsl:value-of select="@name" />
                            <xsl:text xml:space="preserve">
</xsl:text>
                            <xsl:value-of select="@name" />
                            <xsl:text xml:space="preserve">: </xsl:text>
                            <xsl:value-of select="a:value[@operation = 'add']/text()" disable-output-escaping="yes" />
                            <xsl:text xml:space="preserve">
-
</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                </xsl:choose>
              </xsl:for-each>
              <xsl:for-each select="a:dn-attr">
                <xsl:choose>
                  <xsl:when test="@name=$attributes">
                    <xsl:choose>
                      <xsl:when test="@multivalued='true'">
                        <xsl:value-of select="a:dn-value/@operation" />
                        <xsl:text xml:space="preserve">: </xsl:text>
                        <xsl:value-of select="./@name" />
                        <xsl:text xml:space="preserve">
</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:choose>
                          <xsl:when test="@operation = 'add'">
                            <xsl:text xml:space="preserve">add: </xsl:text>
                            <xsl:value-of select="./@name" />
                            <xsl:text xml:space="preserve">
</xsl:text>
                          </xsl:when>
                          <xsl:when test="@operation='delete'">
                            <xsl:text xml:space="preserve">delete: </xsl:text>
                            <xsl:value-of select="./@name" />
                            <xsl:text xml:space="preserve">
</xsl:text>
                          </xsl:when>
                          <xsl:when test="@operation='update'">
                            <xsl:text xml:space="preserve">replace: </xsl:text>
                            <xsl:value-of select="./@name" />
                            <xsl:text xml:space="preserve">
</xsl:text>
                          </xsl:when>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:for-each select="a:dn-value">
                      <xsl:value-of select="../@name" />
                      <xsl:text xml:space="preserve">: </xsl:text>
                      <xsl:if test="../@name != 'ObjectID'">
                        <xsl:text xml:space="preserve">uid=</xsl:text>
                      </xsl:if>
                      <xsl:value-of select="a:dn/text()" disable-output-escaping="yes"/>
                      <xsl:text xml:space="preserve">
</xsl:text>
                    </xsl:for-each>
                    <xsl:text xml:space="preserve">
-
</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:for-each>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>