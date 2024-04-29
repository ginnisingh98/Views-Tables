--------------------------------------------------------
--  DDL for Package AK_QUERYOBJ_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_QUERYOBJ_GRP" AUTHID CURRENT_USER as
/* $Header: akdgqrys.pls 120.2 2005/09/15 22:26:40 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_QUERYOBJ_GRP';
--
-- Procedure specs
--
--=======================================================
--  Procedure   CREATE_QUERY_OBJECT
--
--  Usage       Group API for creating a query objec
--
--  Desc        Calls the private API to creates a query object
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Query object columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_QUERY_OBJECT (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_query_code				 IN      VARCHAR2,
p_application_id			 IN      NUMBER,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

--=======================================================
--  Procedure   CREATE_QUERY_OBJECT_LINE
--
--  Usage       Group API for creating a query object line
--
--  Desc        Calls the private API to creates a query object line
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Query object line columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_QUERY_OBJECT_LINE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_query_code				 IN      VARCHAR2,
p_seq_num					 IN      NUMBER,
p_query_line_type			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_query_line				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_linked_parameter		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

--========================================================
--  Procedure   DOWNLOAD_QUERY_OBJECT
--
--  Usage       Group API for downloading query objects
--
--  Desc        This API first write out standard loader
--              file header for attributes to a flat file.
--              Then it calls the private API to extract the
--              attributes selected by application ID or by
--              key values from the database to the output file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_nls_language : IN optional
--                  NLS language for database. If none if given,
--                  the current NLS language will be used.
--
--              One of the following three parameters must be given:
--
--              p_application_id : IN optional
--                  If given, all query objects for this application ID
--                  will be written to the output file.
--              p_application_short_name : IN optional
--                  If given, all query objects for this application short
--                  name will be written to the output file.
--                  Application short name will be ignored if an
--                  application ID is given.
--              p_queryobj_pk_tbl : IN optional
--                  If given, only query objects whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_QUERY_OBJECT (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_nls_language             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_application_short_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_queryobj_pk_tbl          IN      AK_QUERYOBJ_PUB.queryobj_PK_Tbl_Type :=
AK_QUERYOBJ_PUB.G_MISS_QUERYOBJ_PK_TBL
);

end AK_QUERYOBJ_GRP;

 

/
