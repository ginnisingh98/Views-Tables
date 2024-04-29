--------------------------------------------------------
--  DDL for Package AK_OBJECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_OBJECT_PVT" AUTHID CURRENT_USER as
/* $Header: akdvobjs.pls 120.2 2005/09/15 22:26:58 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_OBJECT_PVT';

-- Procedure specs

--=======================================================
--  Procedure   APPEND_OBJECT_PK_TABLE
--
--  Usage       Private API for merging two object tables.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API inserts each object in the from table
--              to the end of the to table if the object does
--              not exist in the to table.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_from_table : IN required
--                  Object table to be merged into the to table
--              p_to_table : IN OUT
--                  Object table to which objects in the from table
--                  will be inserted into
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure APPEND_OBJECT_PK_TABLES (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_from_table               IN      AK_OBJECT_PUB.Object_PK_Tbl_Type,
p_to_table                 IN OUT NOCOPY  AK_OBJECT_PUB.Object_PK_Tbl_Type
);

--=======================================================
--  Function    ATTRIBUTE_EXISTS
--
--  Usage       Private API for checking for the existence of
--              an object attribute with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if an object attribute record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Object Attribute key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function ATTRIBUTE_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2
) return BOOLEAN;

--=======================================================
--  Function    ATTRIBUTE_NAVIGATION_EXISTS
--
--  Usage       Private API for checking for the existence of
--              an attribute navigation record with the given key values.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if an attribute navigation record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an attribute
--              navigation record exists, or FALSE otherwise.
--  Parameters  Attribute Navigation key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function ATTRIBUTE_NAVIGATION_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_value_varchar2           IN      VARCHAR2,
p_value_date               IN      DATE,
p_value_number             IN      NUMBER
) return BOOLEAN;

--=======================================================
--  Function    ATTRIBUTE_VALUE_EXISTS
--
--  Usage       Private API for checking for the existence of
--              an attribute value record with the given key values.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if an attribute value record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an attribute
--              value record exists, or FALSE otherwise.
--  Parameters  Attribute Value key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function ATTRIBUTE_VALUE_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_key_value1               IN      VARCHAR2,
p_key_value2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value10              IN      VARCHAR2 := FND_API.G_MISS_CHAR
) return BOOLEAN;

-- CREATE came back to here
--
--=======================================================
--  Procedure   INSERT_OBJECT_PK_TABLE
--
--  Usage       Private API for inserting the given object's
--              primary key value into the given object
--              table.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API inserts the given object primary
--              key value into a given object table
--              (of type Object_PK_Tbl_Type) only if the
--              primary key does not already exist in the table.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_database_object_name : IN required
--                  Key value of the object to be inserted to the
--                  table.
--              p_object_pk_tbl : IN OUT
--                  Object table to be updated.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure INSERT_OBJECT_PK_TABLE (
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_object_pk_tbl            IN OUT NOCOPY  AK_OBJECT_PUB.Object_PK_Tbl_Type
);

--=======================================================
--  Function    OBJECT_EXISTS
--
--  Usage       Private API for checking for the existence of
--              an object with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if an object
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              exists, or FALSE otherwise.
--  Parameters  Object key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function OBJECT_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2
) return BOOLEAN;

--=======================================================
--  Procedure   DELETE_ATTRIBUTE
--
--  Usage       Private API for deleting an object attribute. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes an object attribute with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_database_object_name : IN required
--              p_attribute_application_id : IN required
--              p_attribute_code : IN required
--                  Key value of the object attribute to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_ATTRIBUTE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
);

--=======================================================
--  Procedure   DELETE_ATTRIBUTE_NAVIGATION
--
--  Usage       Private API for deleting an attribute navigation
--              record. This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        Deletes an attribute navigation record with the
--              given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_database_object_name : IN required
--              p_attribute_application_id : IN required
--              p_attribute_code : IN required
--              p_value_varchar2 : IN required (can be null)
--              p_value_date : IN required (can be null)
--              p_value_number : IN required (can be null)
--                  Key value of the attribute navigation record
--                  to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_ATTRIBUTE_NAVIGATION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_value_varchar2           IN      VARCHAR2,
p_value_date               IN      DATE,
p_value_number             IN      NUMBER,
p_delete_cascade           IN      VARCHAR2 := 'N'
);

--=======================================================
--  Procedure   DELETE_ATTRIBUTE_VALUE
--
--  Usage       Private API for deleting an attribute value record.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes an attribute value record with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_database_object_name : IN required
--              p_attribute_application_id : IN required
--              p_attribute_code : IN required
--              p_key_value1 : IN required
--              p_key_value2 thru p_key_value10 : IN optional
--                  Key value of the attribute value record
--                  to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_ATTRIBUTE_VALUE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_key_value1               IN      VARCHAR2,
p_key_value2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value10              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_delete_cascade           IN      VARCHAR2 := 'N'
);

--=======================================================
--  Procedure   DELETE_OBJECT
--
--  Usage       Private API for deleting an object. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes an object with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_database_object_name : IN required
--                  database object name of the object to be deleted
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this attribute.
--                  Otherwise, this attribute will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_OBJECT (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2 := 'N'
);

--=======================================================
--  Function    VALIDATE_ATTRIBUTE
--
--  Usage       Private API for validating an object attribute. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on an object attribute record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Object Attribute columns
--              p_caller : IN required
--                  Must be one of the following values defined
--                  in package AK_ON_OBJECTS_PVT:
--                  - G_CREATE   (if calling from the Create API)
--                  - G_DOWNLOAD (if calling from the Download API)
--                  - G_UPDATE   (if calling from the Update API)
--
--  Note        This API is intended for performing record-level
--              validation. It is not designed for item-level
--              validation.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function VALIDATE_ATTRIBUTE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_column_name              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_display_value_length     IN      NUMBER := FND_API.G_MISS_NUM,
p_bold                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_italic                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_vertical_alignment       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_horizontal_alignment     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_data_source_type         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_data_storage_type        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_table_name               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_base_table_column_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_required_flag            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_foreign_key_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_attribute_application_id IN  NUMBER := FND_API.G_MISS_NUM,
p_lov_attribute_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_defaulting_api_pkg       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_defaulting_api_proc      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_validation_api_pkg       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_validation_api_proc      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN;

--==========================================================
--  Function    VALIDATE_ATTRIBUTE_NAVIGATION
--
--  Usage       Private API for validating an attribute navigation.
--              record.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on an attribute navigation record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Attribute Navigation columns
--              p_caller : IN required
--                  Must be one of the following values defined
--                  in package AK_ON_OBJECTS_PVT:
--                  - G_CREATE   (if calling from the Create API)
--                  - G_DOWNLOAD (if calling from the Download API)
--                  - G_UPDATE   (if calling from the Update API)
--
--  Note        This API is intended for performing record-level
--              validation. It is not designed for item-level
--              validation.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--==========================================================
function VALIDATE_ATTRIBUTE_NAVIGATION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_value_varchar2           IN      VARCHAR2,
p_value_date               IN      DATE,
p_value_number             IN      NUMBER,
p_to_region_appl_id        IN      NUMBER := FND_API.G_MISS_NUM,
p_to_region_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN;

--=======================================================
--  Function    VALIDATE_ATTRIBUTE_VALUE
--
--  Usage       Private API for validating an attribute value record.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on an attribute value record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Attribute Value columns
--              p_caller : IN required
--                  Must be one of the following values defined
--                  in package AK_ON_OBJECTS_PVT:
--                  - G_CREATE   (if calling from the Create API)
--                  - G_DOWNLOAD (if calling from the Download API)
--                  - G_UPDATE   (if calling from the Update API)
--
--  Note        This API is intended for performing record-level
--              validation. It is not designed for item-level
--              validation.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function VALIDATE_ATTRIBUTE_VALUE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_key_value1               IN      VARCHAR2,
p_key_value2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value10              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_varchar2           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_date               IN      DATE := FND_API.G_MISS_DATE,
p_value_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_caller                   IN      VARCHAR2
) return BOOLEAN;

--=======================================================
--  Function    VALIDATE_OBJECT
--
--  Usage       Private API for validating an object record.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on an object record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Object columns
--              p_caller : IN required
--                  Must be one of the following values defined
--                  in package AK_ON_OBJECTS_PVT:
--                  - G_CREATE   (if calling from the Create API)
--                  - G_DOWNLOAD (if calling from the Download API)
--                  - G_UPDATE   (if calling from the Update API)
--
--  Note        This API is intended for performing record-level
--              validation. It is not designed for item-level
--              validation.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function VALIDATE_OBJECT (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_primary_key_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_defaulting_api_pkg       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_defaulting_api_proc      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_validation_api_pkg       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_validation_api_proc      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN;

--=======================================================
--  Procedure   CREATE_ATTRIBUTE
--
--  Usage       Private API for creating an object attribute. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates an object attribute using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Object Attribute columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_ATTRIBUTE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_column_name              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_length   IN      NUMBER,
p_display_value_length     IN      NUMBER,
p_bold                     IN      VARCHAR2,
p_italic                   IN      VARCHAR2,
p_vertical_alignment       IN      VARCHAR2,
p_horizontal_alignment     IN      VARCHAR2,
p_data_source_type         IN      VARCHAR2,
p_data_storage_type        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_table_name               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_base_table_column_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_required_flag            IN      VARCHAR2,
p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_foreign_key_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_attribute_application_id IN  NUMBER := FND_API.G_MISS_NUM,
p_lov_attribute_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_defaulting_api_pkg       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_defaulting_api_proc      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_validation_api_pkg       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_validation_api_proc      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_category       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute1               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute10              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute11              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute12              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute13              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute14              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute15              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
);

--=======================================================
--  Procedure   CREATE_ATTRIBUTE_NAVIGATION
--
--  Usage       Private API for creating an attribute navigation
--              record. This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        Creates an attribute navigation record using the given
--              info. This API should only be called by other APIs that
--              are owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute Navigation columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_ATTRIBUTE_NAVIGATION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_value_varchar2           IN      VARCHAR2,
p_value_date               IN      DATE,
p_value_number             IN      NUMBER,
p_to_region_appl_id        IN      NUMBER,
p_to_region_code           IN      VARCHAR2,
p_attribute_category       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute1               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute10              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute11              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute12              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute13              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute14              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute15              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
);

--=======================================================
--  Procedure   CREATE_ATTRIBUTE_VALUE
--
--  Usage       Private API for creating an attribute value record.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates an attribute value record using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute Value columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_ATTRIBUTE_VALUE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_key_value1               IN      VARCHAR2,
p_key_value2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_key_value10              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_varchar2           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_date               IN      DATE := FND_API.G_MISS_DATE,
p_value_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE
);

--=======================================================
--  Procedure   CREATE_OBJECT
--
--  Usage       Private API for creating an object. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates an object using the given info. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Object columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_OBJECT (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER,
p_primary_key_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_defaulting_api_pkg       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_defaulting_api_proc      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_validation_api_pkg       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_validation_api_proc      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_category       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute1               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute10              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute11              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute12              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute13              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute14              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute15              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
);

--=======================================================
--  Function    VALID_COLUMN_NAME
--
--  Desc        This function check for the existence of
--              a column within a given table.
--
--  Results     Returns TRUE if the column exists in
--              the given table, or FALSE otherwise.
--
--  Parameters  p_table_name : IN required
--                  Name of the table that contains the column
--              p_column_name : IN required
--                  Name of the column to be checked.
--=======================================================

function VALID_COLUMN_NAME (
p_table_name                IN VARCHAR2,
p_column_name               IN VARCHAR2
) return BOOLEAN;

end AK_OBJECT_PVT;

 

/
