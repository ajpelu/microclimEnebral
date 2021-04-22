<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="rights" match="/">


 <h4>Intellectual Rights</h4>
  <p>
    <p><strong><xsl:value-of select="//dataset/intellectualRights/section[1]/title" /></strong></p> 
    <xsl:value-of select="//dataset/intellectualRights/section[1]/para" />
    
    <p style="padding-top:6px"><strong><xsl:value-of select="//dataset/intellectualRights/section[2]/title" /></strong></p> 
    <xsl:value-of select="//dataset/intellectualRights/section[2]/para" />
    
    <p style="padding-top:6px"><strong><xsl:value-of select="//dataset/intellectualRights/section[3]/title" /></strong></p> 
    <xsl:value-of select="//dataset/intellectualRights/section[3]/para" />
  </p>
    
</xsl:template>
</xsl:stylesheet>
  
  