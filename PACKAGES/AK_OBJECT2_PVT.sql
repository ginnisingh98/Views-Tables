--------------------------------------------------------
--  DDL for Package AK_OBJECT2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_OBJECT2_PVT" AUTHID CURRENT_USER as
/* $Header: akdvob2s.pls 115.2 99/07/17 15:20:49 porting s $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_OBJECT2_PVT';

-- PL/SQL table for holding records that need to be processed
-- the second time in UPLOAD
G_OBJECT_REDO_TBL           AK_OBJECT_PUB.Object_Tbl_Type;
G_OBJECT_ATTR_REDO_TBL      AK_OBJECT_PUB.Object_Attribute_Tbl_Type;
G_ATTR_NAV_REDO_TBL         AK_OBJECT_PUB.Attribute_Nav_Tbl_Type;
G_UNIQUE_KEY_REDO_TBL       AK_KEY_PUB.Unique_Key_Tbl_Type;
G_UNIQUE_KEY_COL_REDO_TBL   AK_KEY_PUB.Unique_Key_Column_Tbl_Type;
G_FOREIGN_KEY_REDO_TBL      AK_KEY_PUB.Foreign_Key_Tbl_Type;
G_FOREIGN_KEY_COL_REDO_TBL  AK_KEY_PUB.Foreign_Key_Column_Tbl_Type;

--
-- Pointer to redo tables
G_OBJECT_REDO_INDEX         NUMBER := 0;
G_OBJECT_ATTR_REDO_INDEX    NUMBER := 0;
G_ATTR_NAV_REDO_INDEX       NUMBER := 0;
G_UNIQUE_KEY_REDO_INDEX     NUMBER := 0;
G_UNIQUE_KEY_COL_REDO_INDEX NUMBER := 0;
G_FOREIGN_KEY_REDO_INDEX    NUMBER := 0;
G_FOREIGN_KEY_COL_REDO_INDEX NUMBER := 0;

--=======================================================
--  Procedure   DOWNLOAD_OBJECT
--
--  Usage       Private API for downloading objects. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API will extract the objects selected
--              by application ID or by key values from the
--              database to the output file.
--              If an object is selected for writing to the loader
--              file, all its children records (including object
--              attributes, foreign and unique key definitions,
--              attribute values, attribute navigation, and regions
--              that references this object, depending on the
--              value of p_get_region_flag) will also be written.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_attribute_pk_tbl : IN optional
--                  If given, attributes whose key values are
--                  included in this table will be extracted and
--                  written to the output file. This is used for
--                  extracting additional attributes, for instance,
--                  attributes that are referenced by the region items
--                  whose regions are referencing this object when
--                  this API is called by the DOWNLOAD_REGION API.
--              p_get_region_flag : IN required
--                  Call DOWNLOAD_REGION API to extract regions that
--                  are referencing the objects that will be extracted
--                  by this API if this parameter is 'Y'.
--              p_nls_language : IN optional
--                  NLS language for database. If none if given,
--                  the current NLS language will be used.
--
--              One of the following parameters must be provided:
--
--              p_application_id : IN optional
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--                  p_application_id will be ignored if a table is
--                  given in p_object_pk_tbl.
--              p_object_pk_tbl : IN optional
--                  If given, only objects whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_OBJECT (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT     VARCHAR2,
  p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
  p_object_pk_tbl            IN      AK_OBJECT_PUB.Object_PK_Tbl_Type
                                    := AK_OBJECT_PUB.G_MISS_OBJECT_PK_TBL,
  p_attribute_pk_tbl         IN      AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type
                                   := AK_ATTRIBUTE_PUB.G_MISS_ATTRIBUTE_PK_TBL,
  p_nls_language             IN      VARCHAR2,
  p_get_region_flag          IN      VARCHAR2
);

--=======================================================
--  Procedure   UPLOAD_OBJECT_SECOND
--
--  Usage       Private API for loading objects that were
--              failed during its first pass
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the object data from PL/SQL table
--              that was prepared during 1st pass, then processes
--              the data, and loads them to the database. The tables
--              are updated with the timestamp passed. This API
--              will process the file until the EOF is reached,
--              a parse error is encountered, or when data for
--              a different business object is read from the file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_validation_level : IN required
--                  validation level
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPLOAD_OBJECT_SECOND (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT     VARCHAR2,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER := 2
);

end AK_OBJECT2_PVT;

 

/
