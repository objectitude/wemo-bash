<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:strip-space elements="*" />
	<xsl:output method="text" encoding="UTF-8" />
	<xsl:template match="/">
		<xsl:value-of select="//BinaryState" />
		<xsl:value-of select="//FriendlyName" />
		<xsl:value-of select="//SignalStrength" />
	</xsl:template>
</xsl:stylesheet>
