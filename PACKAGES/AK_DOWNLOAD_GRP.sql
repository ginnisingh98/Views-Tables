--------------------------------------------------------
--  DDL for Package AK_DOWNLOAD_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_DOWNLOAD_GRP" AUTHID CURRENT_USER as
/* $Header: akgdlods.pls 120.2 2005/09/15 22:27:07 tshort ship $ */

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_DOWNLOAD_GRP';
G_WRITE_HEADER  BOOLEAN;
G_DOWNLOAD_ATTR VARCHAR2(1);
G_DOWNLOAD_REG  VARCHAR2(1);

procedure DOWNLOAD (
p_business_object  IN  VARCHAR2,
p_appl_short_name  IN  VARCHAR2,
p_primary_key      IN  VARCHAR2:= FND_API.G_MISS_CHAR,
p_return_status   OUT NOCOPY VARCHAR2,
p_level	     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
p_levelpk	     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
p_download_attr    IN  VARCHAR2 := 'Y',
p_download_reg	   IN  VARCHAR2 := 'Y'
);

end AK_DOWNLOAD_GRP;

 

/
