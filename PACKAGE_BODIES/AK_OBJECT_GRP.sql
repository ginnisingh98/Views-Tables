--------------------------------------------------------
--  DDL for Package Body AK_OBJECT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_OBJECT_GRP" as
/* $Header: akdgobjb.pls 120.2 2005/09/15 22:26:36 tshort ship $ */

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Attribute';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint start_create_attribute;

-- Call private procedure to create an attribute
AK_OBJECT_PVT.CREATE_ATTRIBUTE(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_column_name => p_column_name,
p_attribute_label_length => p_attribute_label_length,
p_display_value_length => p_display_value_length,
p_bold => p_bold,
p_italic => p_italic,
p_vertical_alignment => p_vertical_alignment,
p_horizontal_alignment => p_horizontal_alignment,
p_data_source_type => p_data_source_type,
p_data_storage_type => p_data_storage_type,
p_table_name => p_table_name,
p_base_table_column_name => p_base_table_column_name,
p_required_flag => p_required_flag,
p_default_value_varchar2 => p_default_value_varchar2,
p_default_value_number => p_default_value_number,
p_default_value_date => p_default_value_date,
p_lov_region_application_id => p_lov_region_application_id,
p_lov_region_code => p_lov_region_code,
p_lov_foreign_key_name => p_lov_foreign_key_name,
p_lov_attribute_application_id => p_lov_attribute_application_id,
p_lov_attribute_code => p_lov_attribute_code,
p_defaulting_api_pkg => p_defaulting_api_pkg,
p_defaulting_api_proc => p_defaulting_api_proc,
p_validation_api_pkg => p_validation_api_pkg,
p_validation_api_proc => p_validation_api_proc,
p_attribute_label_long => p_attribute_label_long,
p_attribute_label_short => p_attribute_label_short,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
-- dbms_output.put_line(l_api_name || ' Create_Attribute failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_attribute;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
rollback to start_create_attribute;
end CREATE_ATTRIBUTE;

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
p_value_varchar2           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_date               IN      DATE     ,
p_value_number             IN      NUMBER,
p_to_region_appl_id        IN      NUMBER,
p_to_region_code           IN      VARCHAR2,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Attribute_Navigation';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint start_create_navigation;

-- Call private procedure to create an attribute navigation row
AK_OBJECT_PVT.CREATE_ATTRIBUTE_NAVIGATION(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_value_varchar2 => p_value_varchar2,
p_value_date => p_value_date,
p_value_number => p_value_number,
p_to_region_appl_id => p_to_region_appl_id,
p_to_region_code => p_to_region_code,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Create_Attribute_Navigation failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_navigation;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_navigation;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_ATTRIBUTE_NAVIGATION;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Attribute_Value';
l_return_status      VARCHAR2(1);
begin
-- Check API version number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint start_create_value;

-- Call private procedure to create an attribute value row
AK_OBJECT_PVT.CREATE_ATTRIBUTE_VALUE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_key_value1 => p_key_value1,
p_key_value2 => p_key_value2,
p_key_value3 => p_key_value3,
p_key_value4 => p_key_value4,
p_key_value5 => p_key_value5,
p_key_value6 => p_key_value6,
p_key_value7 => p_key_value7,
p_key_value8 => p_key_value8,
p_key_value9 => p_key_value9,
p_key_value10 => p_key_value10,
p_value_varchar2 => p_value_varchar2,
p_value_date => p_value_date,
p_value_number => p_value_number,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Create_Attribute_Value failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_value;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_value;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_ATTRIBUTE_VALUE;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Object';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint start_create_object;

-- Call private procedure to create an object
AK_OBJECT_PVT.CREATE_OBJECT (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_name => p_name,
p_description => p_description,
p_application_id => p_application_id,
p_primary_key_name => p_primary_key_name,
p_defaulting_api_pkg => p_defaulting_api_pkg,
p_defaulting_api_proc => p_defaulting_api_proc,
p_validation_api_pkg => p_validation_api_pkg,
p_validation_api_proc => p_validation_api_proc,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Create_Object failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_object;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
rollback to start_create_object;
end CREATE_OBJECT;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Attribute';
l_return_status      VARCHAR2(1);
begin
-- Check API version number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint start_delete_attribute;

-- Call private procedure to delete an object attribute
AK_OBJECT_PVT.DELETE_ATTRIBUTE(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_delete_cascade => p_delete_cascade
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_attribute;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
rollback to start_delete_attribute;
end DELETE_ATTRIBUTE;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Attribute_Navigation';
l_return_status      VARCHAR2(1);
begin
-- Check API version number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint start_delete_navigation;

-- Call private procedure to delete an attribute navigation record
AK_OBJECT_PVT.DELETE_ATTRIBUTE_NAVIGATION(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_value_varchar2 => p_value_varchar2,
p_value_date => p_value_date,
p_value_number => p_value_number,
p_delete_cascade => p_delete_cascade
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_navigation;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
rollback to start_delete_navigation;
end DELETE_ATTRIBUTE_NAVIGATION;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Attribute_Value';
l_return_status      VARCHAR2(1);
begin
-- Check API version number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint start_delete_value;

-- Call private procedure to delete an attribute value record
AK_OBJECT_PVT.DELETE_ATTRIBUTE_VALUE(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_key_value1 => p_key_value1,
p_key_value2 => p_key_value2,
p_key_value3 => p_key_value3,
p_key_value4 => p_key_value4,
p_key_value5 => p_key_value5,
p_key_value6 => p_key_value6,
p_key_value7 => p_key_value7,
p_key_value8 => p_key_value8,
p_key_value9 => p_key_value9,
p_key_value10 => p_key_value10,
p_delete_cascade => p_delete_cascade
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_value;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
rollback to start_delete_value;
end DELETE_ATTRIBUTE_VALUE;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Object';
l_return_status      VARCHAR2(1);
begin
-- Check API version number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint start_delete_object;

-- Call private procedure to delete an object
AK_OBJECT_PVT.DELETE_OBJECT(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_delete_cascade => p_delete_cascade
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_object;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
rollback to start_delete_object;
end DELETE_OBJECT;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Download';
l_application_id     number;
l_buffer_tbl         AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_index_out          NUMBER;
l_nls_language       VARCHAR2(30);
l_return_status      varchar2(1);
begin

-- Check verion number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint Start_download;

if (AK_DOWNLOAD_GRP.G_WRITE_HEADER) then
-- Call private download procedure to verify parameters,
-- load application ID, and write header information such
-- as nls_language and codeset to data file.
AK_ON_OBJECTS_PVT.download_header(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_nls_language => p_nls_language,
p_application_id => p_application_id,
p_application_short_name => p_application_short_name,
p_table_size => p_object_pk_tbl.count,
p_download_by_object => AK_ON_OBJECTS_PVT.G_OBJECT,
p_nls_language_out => l_nls_language,
p_application_id_out => l_application_id
);
else
l_application_id := p_application_id;
select userenv('LANG') into l_nls_language
from dual;

end if;

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
-- dbms_output.put_line(G_PKG_NAME || ' download_header failed');
RAISE FND_API.G_EXC_ERROR;
end if;

-- dbms_output.put_line('about to call download_object: ' ||
--                        to_char(sysdate, 'MON-DD HH24:MI:SS'));
-- - call the download procedure for attributes to retrieve the
--   selected attributes from the database into a table of type
--   AK_ON_OBJECTS_PUB.Buffer_Tbl_Type.
AK_OBJECT2_PVT.DOWNLOAD_OBJECT(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => l_application_id,
p_object_pk_tbl => p_object_pk_tbl,
p_nls_language => l_nls_language,
p_get_region_flag => 'Y'
);
-- dbms_output.put_line('finished calling download_object: ' ||
--                        to_char(sysdate, 'MON-DD HH24:MI:SS'));

-- If download call returns with an error status or
-- download failed to retrieve any information from the database..
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
-- dbms_output.put_line(G_PKG_NAME || 'download failed');
RAISE FND_API.G_EXC_ERROR;
end if;

--dbms_output.put_line('got ' || to_char(l_buffer_tbl.count) || ' lines');

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
-- dbms_output.put_line('Procedure DOWNLOAD_OBJECT EXCEPTION FND_API.G_EXC_ERROR');
-- rollback to Start_download;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

WHEN OTHERS THEN
-- dbms_output.put_line('Procedure DOWNLOAD_OBJECT EXCEPTION FND_API.G_EXC_ERROR');
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
-- rollback to Start_download;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

end DOWNLOAD_OBJECT;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Attribute';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint start_update_attribute;

-- Call private procedure to update an object attribute
AK_OBJECT3_PVT.UPDATE_ATTRIBUTE(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_column_name => p_column_name,
p_attribute_label_length => p_attribute_label_length,
p_display_value_length => p_display_value_length,
p_bold => p_bold,
p_italic => p_italic,
p_vertical_alignment => p_vertical_alignment,
p_horizontal_alignment => p_horizontal_alignment,
p_data_source_type => p_data_source_type,
p_data_storage_type => p_data_storage_type,
p_table_name => p_table_name,
p_base_table_column_name => p_base_table_column_name,
p_required_flag => p_required_flag,
p_default_value_varchar2 => p_default_value_varchar2,
p_default_value_number => p_default_value_number,
p_default_value_date => p_default_value_date,
p_lov_region_application_id => p_lov_region_application_id,
p_lov_region_code => p_lov_region_code,
p_lov_foreign_key_name => p_lov_foreign_key_name,
p_lov_attribute_application_id => p_lov_attribute_application_id,
p_lov_attribute_code => p_lov_attribute_code,
p_defaulting_api_pkg => p_defaulting_api_pkg,
p_defaulting_api_proc => p_defaulting_api_proc,
p_validation_api_pkg => p_validation_api_pkg,
p_validation_api_proc => p_validation_api_proc,
p_attribute_label_long => p_attribute_label_long,
p_attribute_label_short => p_attribute_label_short,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Update_Attribute failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_attribute;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_attribute;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_ATTRIBUTE;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Attribute_Navigation';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint start_update_navigation;

-- Call private procedure to update an attribute navigation row
AK_OBJECT3_PVT.UPDATE_ATTRIBUTE_NAVIGATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_value_varchar2 => p_value_varchar2,
p_value_date => p_value_date,
p_value_number => p_value_number,
p_to_region_appl_id => p_to_region_appl_id,
p_to_region_code => p_to_region_code,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Update_Attribute_Navigation failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_navigation;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_navigation;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_ATTRIBUTE_NAVIGATION;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Attribute_Value';
l_return_status      VARCHAR2(1);
begin
-- Check API version number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint start_update_value;

-- Call private procedure to update an attribute value
AK_OBJECT3_PVT.UPDATE_ATTRIBUTE_VALUE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_key_value1 => p_key_value1,
p_key_value2 => p_key_value2,
p_key_value3 => p_key_value3,
p_key_value4 => p_key_value4,
p_key_value5 => p_key_value5,
p_key_value6 => p_key_value6,
p_key_value7 => p_key_value7,
p_key_value8 => p_key_value8,
p_key_value9 => p_key_value9,
p_key_value10 => p_key_value10,
p_value_varchar2 => p_value_varchar2,
p_value_date => p_value_date,
p_value_number => p_value_number,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Update_Attribute_Value failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_value;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_value;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_ATTRIBUTE_VALUE;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Object';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Initialize the message table if requested.

if p_init_msg_tbl then
FND_MSG_PUB.initialize;
end if;

savepoint start_update_object;

-- Call private procedure to update an object
AK_OBJECT3_PVT.UPDATE_OBJECT (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_name => p_name,
p_description => p_description,
p_application_id => p_application_id,
p_primary_key_name => p_primary_key_name,
p_defaulting_api_pkg => p_defaulting_api_pkg,
p_defaulting_api_proc => p_defaulting_api_proc,
p_validation_api_pkg => p_validation_api_pkg,
p_validation_api_proc => p_validation_api_proc,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Update_Object failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_object;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
rollback to start_update_object;
end UPDATE_OBJECT;

end AK_OBJECT_GRP;

/
