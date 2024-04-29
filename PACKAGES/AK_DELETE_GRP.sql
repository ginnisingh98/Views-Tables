--------------------------------------------------------
--  DDL for Package AK_DELETE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_DELETE_GRP" AUTHID CURRENT_USER as
/* $Header: akgdelds.pls 120.2 2005/09/15 22:27:05 tshort noship $ */

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_DELETE_GRP';
G_WRITE_HEADER  BOOLEAN;
G_DOWNLOAD_ATTR VARCHAR2(1);

procedure DELETE (
p_business_object  IN  VARCHAR2,
p_appl_short_name  IN  VARCHAR2,
p_primary_key      IN  VARCHAR2:= FND_API.G_MISS_CHAR,
p_return_status   OUT NOCOPY VARCHAR2,
p_delete_cascade   IN  VARCHAR2 := 'Y'
);

end AK_DELETE_GRP;

 

/
