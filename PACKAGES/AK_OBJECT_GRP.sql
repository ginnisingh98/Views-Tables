--------------------------------------------------------
--  DDL for Package AK_OBJECT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_OBJECT_GRP" AUTHID CURRENT_USER as
/* $Header: akdgobjs.pls 120.3 2005/09/15 22:26:37 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_OBJECT_GRP';

/* Procedure specs */

--=======================================================
--  Procedure   CREATE_ATTRIBUTE
--
--  Usage       Group API for creating an object attribute
--
--  Desc        Calls the private API to create an object attribute
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Object Attribute columns
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
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

--=======================================================
--  Procedure   CREATE_ATTRIBUTE_NAVIGATION
--
--  Usage       Group API for creating an attribute
--              navigation record.
--
--  Desc        Calls the private API to create an attribute
--              navigation record using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute Navigation columns
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
p_value_varchar2           IN      VARCHAR2 :=  FND_API.G_MISS_CHAR,
p_value_date               IN      DATE,
p_value_number             IN      NUMBER,
p_to_region_appl_id        IN      NUMBER,
p_to_region_code           IN      VARCHAR2,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

--=======================================================
--  Procedure   CREATE_ATTRIBUTE_VALUE
--
--  Usage       Group API for creating an attribute value
--              record
--
--  Desc        Calls the private API to create an attribute
--              value record using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute Value columns
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
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

--=======================================================
--  Procedure   CREATE_OBJECT
--
--  Usage       Group API for creating an object
--
--  Desc        Calls the private API to create an object
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Object columns
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
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

--=======================================================
--  Procedure   DELETE_ATTRIBUTE
--
--  Usage       Group API for deleting an object attribute
--
--  Desc        Calls the private API to delete an object attribute
--              with the given key value.
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
p_delete_cascade           IN      VARCHAR2 := 'N'
);

--=======================================================
--  Procedure   DELETE_ATTRIBUTE_NAVIGATION
--
--  Usage       Group API for deleting an attribute navigation
--              record
--
--  Desc        Calls the private API to delete an attribute
--              navigation record with the given key value.
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
--  Usage       Group API for deleting an attribute value
--              record
--
--  Desc        Calls the private API to delete an attribute
--              value record with the given key value.
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
--  Usage       Group API for deleting an object
--
--  Desc        Calls the private API to delete an object
--              with the given key value.
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
--                  rows in other tables that references this object.
--                  Otherwise, this object will not be deleted if there
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

--===========================================================
--  Procedure   DOWNLOAD_OBJECT
--
--  Usage       Group API for downloading objects
--
--  Desc        This API first write out standard loader
--              file header for objects to a flat file.
--              Then it calls the private API to extract the
--              objects selected by application ID or by
--              key values from the database to the output file.
--              If an object is selected for writing to the loader
--              file, all its children records (including object
--              attributes, foreign and unique key definitions,
--              attribute values, attribute navigation, and regions
--              that references this object) will also be written.
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
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--              p_application_short_name : IN optional
--                  If given, all attributes for this application short
--                  name will be written to the output file.
--                  Application short name will be ignored if an
--                  application ID is given.
--              p_object_pk_tbl : IN optional
--                  If given, only objects whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--===========================================================
procedure DOWNLOAD_OBJECT (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_nls_language             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_application_short_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_object_pk_tbl            IN      AK_OBJECT_PUB.Object_PK_Tbl_Type
:= AK_OBJECT_PUB.G_MISS_OBJECT_PK_TBL
);

--=======================================================
--  Procedure   UPDATE_ATTRIBUTE
--
--  Usage       Group API for updating an object attribute
--
--  Desc        This API calls the private API to update
--              an object attribute using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Object Attribute columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_ATTRIBUTE (
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
p_attribute_value_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

--=======================================================
--  Procedure   UPDATE_ATTRIBUTE_NAVIGATION
--
--  Usage       Group API for updating an attribute navigation
--              record
--
--  Desc        This API calls the private API to update
--              an attribute naviation record using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute Navigation columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_ATTRIBUTE_NAVIGATION (
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
p_to_region_appl_id        IN      NUMBER := FND_API.G_MISS_NUM,
p_to_region_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

--=======================================================
--  Procedure   UPDATE_ATTRIBUTE_VALUE
--
--  Usage       Group API for updating an attribute value
--              record
--
--  Desc        This API calls the private API to update
--              an attribute value record using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute Value columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_ATTRIBUTE_VALUE (
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
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

--=======================================================
--  Procedure   UPDATE_OBJECT
--
--  Usage       Group API for updating an object
--
--  Desc        This API calls the private API to update
--              an object using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Object columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_OBJECT (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
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
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

end AK_OBJECT_GRP;

 

/
