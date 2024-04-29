--------------------------------------------------------
--  DDL for Package Body AK_OBJECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_OBJECT_PVT" as
/* $Header: akdvobjb.pls 120.3 2005/09/26 20:14:34 tshort ship $ */

--=======================================================
--  Function    VALID_TO_REGION (local)
--
--  Usage       Local function. Not designed to be called
--              from outside this package.
--
--  Desc        This function check that the to_region exists and
--              that the to_region references the object specified.
--
--  Results     Returns TRUE if the to_region exists and is
--              referencing the object specified, or FALSE otherwise.
--
--  Parameters  p_region_appl_id : IN required
--                  Application ID for the to_region
--              p_region_code : IN required
--                  Region Code for the to_region
--              p_database_object_name : IN required
--                  Database object name that the to_region should
--                  be referencing
--=======================================================
function VALID_TO_REGION (
p_region_appl_id            IN NUMBER,
p_region_code               IN VARCHAR2,
p_database_object_name      IN VARCHAR2
) return BOOLEAN is
cursor l_check_region_csr is
select 1
from  AK_REGIONS
where region_application_id = p_region_appl_id
and   region_code = p_region_code
and   database_object_name = p_database_object_name;
l_dummy number;
begin
open l_check_region_csr;
fetch l_check_region_csr into l_dummy;
if (l_check_region_csr%notfound) then
close l_check_region_csr;
return FALSE;
else
close l_check_region_csr;
return TRUE;
end if;
end VALID_TO_REGION;

--=======================================================
--  Function    VALID_PRIMARY_KEY_NAME (local)
--
--  Usage       Local function. Not designed to be called
--              from outside this package.
--
--  Desc        This function check for the existence of
--              a unique key, and that the unique key is a
--              unique key of the given object.
--
--  Results     Returns TRUE if the given unique key exists
--              for the given object, FALSE otherwise.
--
--  Parameters  p_database_object_name : IN required
--                  Object that the unique key should be
--                  referencing
--              p_primary_key_name : IN required
--                  Name of the unique key to be checked.
--=======================================================
function VALID_PRIMARY_KEY_NAME (
p_database_object_name      IN VARCHAR2,
p_primary_key_name          IN VARCHAR2
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_UNIQUE_KEYS
where database_object_name = p_database_object_name
and   unique_key_name = p_primary_key_name;
l_dummy number;
begin
open l_check_csr;
fetch l_check_csr into l_dummy;
if (l_check_csr%notfound) then
close l_check_csr;
return FALSE;
else
close l_check_csr;
return TRUE;
end if;
end VALID_PRIMARY_KEY_NAME;

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
) return BOOLEAN is
cursor l_check_user_column_csr is
select 1
from  USER_TAB_COLUMNS a
where a.table_name = p_table_name
and   a.column_name = p_column_name;
cursor l_check_fnd_column_csr is
select 1
from	FND_VIEW_COLUMNS fvc, FND_VIEWS fv
where	fvc.column_name = p_column_name
and		fv.view_name = p_table_name
and		fvc.view_id = fv.view_id;
cursor l_check_all_column_csr(oracle_schema varchar2) is
select 1
from	ALL_TAB_COLUMNS a
where a.table_name = p_table_name
and a.column_name = p_column_name
and a.owner = oracle_schema;
cursor l_find_appl_short_name is
select a.application_short_name
from fnd_tables t, fnd_application a
where table_name = p_table_name
and t.application_id = a.application_id;
l_dummy number;
-- Local variables to use the fnd_installation.get_app_info
   lv_status   VARCHAR2(5);
   lv_industry VARCHAR2(5);
   lv_schema   VARCHAR2(30);
   lv_return   BOOLEAN;
   l_temp      VARCHAR2(50);
begin
-- Check USER_TAB_COLUMNS
open l_check_user_column_csr;
fetch l_check_user_column_csr into l_dummy;
if (l_check_user_column_csr%notfound) then
close l_check_user_column_csr;
-- Check FND_VIEW_COLUMNS
open l_check_fnd_column_csr;
fetch l_check_fnd_column_csr into l_dummy;
if ( l_check_fnd_column_csr%notfound) then
close l_check_fnd_column_csr;
-- Check ALL_TAB_COLUMNS
open l_find_appl_short_name;
fetch l_find_appl_short_name into l_temp;
if (l_find_appl_short_name%notfound) then
close l_find_appl_short_name;
return FALSE;
else
  lv_return := fnd_installation.get_app_info(l_temp,lv_status,lv_industry,lv_schema);
end if;
close l_find_appl_short_name;
open l_check_all_column_csr(lv_schema);
fetch l_check_all_column_csr into l_dummy;
if (l_check_all_column_csr%notfound) then
close l_check_all_column_csr;
return FALSE;
else
close l_check_all_column_csr;
return TRUE;
end if;
else
close l_check_fnd_column_csr;
return TRUE;
end if;
else
close l_check_user_column_csr;
return TRUE;
end if;
end VALID_COLUMN_NAME;

--=======================================================
--  Function    VALID_TABLE_NAME (local)
--
--  Usage       Local function. Not designed to be called
--              from outside this package.
--
--  Desc        This function check for the existence of
--              a given table.
--
--  Results     Returns TRUE if the table exists, or FALSE otherwise.
--
--  Parameters  p_table_name : IN required
--                  Name of the table to be checked
--=======================================================
function VALID_TABLE_NAME (
p_table_name                IN VARCHAR2
) return BOOLEAN is
cursor l_check_table_csr(oracle_schema varchar2) is
select 1
from  ALL_TABLES
where table_name = p_table_name
and owner = oracle_schema;
cursor l_find_appl_short_name is
select a.application_short_name
from fnd_tables t, fnd_application a
where table_name = p_table_name
and t.application_id = a.application_id;
l_dummy number;
-- Local variables to use the fnd_installation.get_app_info
   lv_status   VARCHAR2(5);
   lv_industry VARCHAR2(5);
   lv_schema   VARCHAR2(30);
   lv_return   BOOLEAN;
   l_temp      VARCHAR2(50);
begin
open l_find_appl_short_name;
fetch l_find_appl_short_name into l_temp;
if (l_find_appl_short_name%notfound) then
close l_find_appl_short_name;
return FALSE;
else
  lv_return := fnd_installation.get_app_info(l_temp,lv_status,lv_industry,lv_schema);
end if;
close l_find_appl_short_name;
open l_check_table_csr(lv_schema);
fetch l_check_table_csr into l_dummy;
if (l_check_table_csr%notfound) then
close l_check_table_csr;
return FALSE;
else
close l_check_table_csr;
return TRUE;
end if;
end VALID_TABLE_NAME;

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
) return BOOLEAN is
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Validate_Attribute';
l_error                   BOOLEAN;
l_return_status           VARCHAR2(1);
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

l_error := FALSE;

--** if validation level is none, no validation is necessary
if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;


--** check that key columns are not null and not missing **
if ((p_database_object_name is null) or
(p_database_object_name = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'DATABASE_OBJECT_NAME');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_application_id is null) or
(p_attribute_application_id = FND_API.G_MISS_NUM)) then
l_error := TRUE;
-- dbms_output.put_line('Attribute Application ID cannot be null');
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_code is null) or
(p_attribute_code = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
-- dbms_output.put_line('Attribute Code cannot be null');
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
FND_MSG_PUB.Add;
end if;
end if;

-- - Check that the parent object exists
--* (This check is not necessary during download because the download
--*  procedure has retrieved the parent object before retrieving its
--*  object attributes.)

if (p_caller <> AK_ON_OBJECTS_PVT.G_DOWNLOAD) then
if (NOT AK_OBJECT_PVT.OBJECT_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_OBJECT_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name);
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Parent object does not exist!');
end if;
end if;

-- - Check that the attribute referenced exists
if (NOT AK_ATTRIBUTE_PVT.ATTRIBUTE_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) ) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_ATTR_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Attribute referenced does not exist!');
end if;

--** check that required columns are not null and, unless calling  **
--** from UPDATE procedure, the columns are not missing            **

if ((p_data_source_type is null) or
(p_data_source_type = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'DATA_SOURCE_TYPE');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_required_flag is null) or
(p_required_flag = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'REQUIRED_FLAG');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_label_length is null) or
(p_attribute_label_length = FND_API.G_MISS_NUM and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_LABEL_LENGTH');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_display_value_length is null) or
(p_display_value_length = FND_API.G_MISS_NUM and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'DISPLAY_VALUE_LENGTH');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_bold is null) or
(p_bold = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'BOLD');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_italic is null) or
(p_italic = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ITALIC');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_vertical_alignment is null) or
(p_vertical_alignment = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'VERTICAL_ALIGNMENT');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_horizontal_alignment is null) or
(p_horizontal_alignment = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'HORIZONTAL_ALIGNMENT');
FND_MSG_PUB.Add;
end if;
end if;

--** Validate columns **

-- - data_source_type
if (p_data_source_type <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_lookup_type => 'DATA_SOURCE_TYPE',
p_lookup_code =>  p_data_source_type)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','DATA_SOURCE_TYPE');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - data_storage_type
if (p_data_storage_type <> FND_API.G_MISS_CHAR) and
(p_data_storage_type is not null) then
if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_lookup_type => 'DATA_STORAGE_TYPE',
p_lookup_code =>  p_data_storage_type)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','DATA_STORAGE_TYPE');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - table_name
if (p_table_name <> FND_API.G_MISS_CHAR) and
(p_table_name is not null) then
if (NOT VALID_TABLE_NAME (p_table_name)) then
-- flag an error only during download
if ( AK_ON_OBJECTS_PUB.G_LOAD_MODE = 'DOWNLOAD' or p_pass = 1) then
l_error := TRUE;
end if;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','TABLE_NAME');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - base_table_column_name
if (p_base_table_column_name <> FND_API.G_MISS_CHAR) and
(p_base_table_column_name is not null) then
if (NOT VALID_COLUMN_NAME (p_table_name, p_base_table_column_name)) then
-- flag an error only during download
if ( AK_ON_OBJECTS_PUB.G_LOAD_MODE = 'DOWNLOAD' or p_pass = 1 ) then
l_error := TRUE;
end if;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','BASE_TABLE_COLUMN_NAME');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - required_flag
if (p_required_flag <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_YES_NO(p_required_flag)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_VALUE_NOT_YES_NO');
FND_MESSAGE.SET_TOKEN('COLUMN','REQUIRED_FLAG');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - lov_region_application_id and lov_region_code
if ( (p_lov_region_application_id <> FND_API.G_MISS_NUM) and
(p_lov_region_application_id is not null) ) or
( (p_lov_region_code <> FND_API.G_MISS_CHAR) and
(p_lov_region_code is not null) )then
if (NOT AK_REGION_PVT.REGION_EXISTS(
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_lov_region_application_id,
p_region_code => p_lov_region_code)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_LOV_REG_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
end if; /* if REGION_EXISTS */
end if;

-- - lov_attribute_application_id and lov_attribute_code
if ( (p_lov_attribute_application_id <> FND_API.G_MISS_NUM) and
(p_lov_attribute_application_id is not null) ) or
( (p_lov_attribute_code <> FND_API.G_MISS_CHAR) and
(p_lov_attribute_code is not null) )then
if (NOT AK_REGION_PVT.ITEM_EXISTS(
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_lov_region_application_id,
p_region_code => p_lov_region_code,
p_attribute_application_id => p_lov_attribute_application_id,
p_attribute_code => p_lov_attribute_code)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_LOV_ITEM_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_lov_attribute_application_id) ||
' ' || p_lov_attribute_code);
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - lov_foreign_key
if (p_lov_foreign_key_name <> FND_API.G_MISS_CHAR) and
(p_lov_foreign_key_name is not null) then
if (NOT AK_KEY_PVT.FOREIGN_KEY_EXISTS(
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name => p_lov_foreign_key_name)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_LOV_FK_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', p_lov_foreign_key_name);
FND_MSG_PUB.Add;
end if;
end if;
end if; /* if p_lov_foreign_key_name */

-- - bold
if (p_bold <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_YES_NO(p_bold)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_VALUE_NOT_YES_NO');
FND_MESSAGE.SET_TOKEN('COLUMN','BOLD');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - italic
if (p_italic <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_YES_NO(p_italic)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_VALUE_NOT_YES_NO');
FND_MESSAGE.SET_TOKEN('COLUMN','ITALIC');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - column name
if (p_column_name <> FND_API.G_MISS_CHAR) then
if (NOT AK_OBJECT_PVT.VALID_COLUMN_NAME (
p_table_name => p_database_object_name,
p_column_name => p_column_name) ) then
if ( AK_ON_OBJECTS_PUB.G_LOAD_MODE = 'DOWNLOAD' or p_pass = 1 ) then
l_error := TRUE;
end if;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN');
FND_MESSAGE.SET_TOKEN('COLUMN',p_column_name);
FND_MESSAGE.SET_TOKEN('OBJECT',p_database_object_name);
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Column name not in this database object');
end if;
end if;

-- - vertical alignment
if (p_vertical_alignment <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_lookup_type => 'VERTICAL_ALIGNMENT',
p_lookup_code =>  p_vertical_alignment)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','VERTICAL_ALIGNMENT');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - horizontal alignment
if (p_horizontal_alignment <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_lookup_type => 'HORIZONTAL_ALIGNMENT',
p_lookup_code => p_horizontal_alignment)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','HORIZONTAL_ALIGNMENT');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- return true if no error, false otherwise
p_return_status := FND_API.G_RET_STS_SUCCESS;
return (not l_error);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;

end VALIDATE_ATTRIBUTE;

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
) return BOOLEAN is
cursor l_check_objattr_csr is
select null
from  AK_OBJECT_ATTRIBUTES
where database_object_name = p_database_object_name
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
cursor l_check_datatype_csr is
select data_type
from  AK_ATTRIBUTES
where attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Validate_Attribute_Nav';
l_count                   number;
l_data_type               VARCHAR2(30);
l_dummy                   NUMBER;
l_error                   BOOLEAN;
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

l_error := FALSE;

--** if validation level is none, no validation is necessary
if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;


--** check that key columns are not null and not missing **
--** One and only one of VALUE_VARCHAR2, VALUE_DATE, and
--** VALUE_NUMBER must be non-null.
if ((p_database_object_name is null) or
(p_database_object_name = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'DATABASE_OBJECT_NAME');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_application_id is null) or
(p_attribute_application_id = FND_API.G_MISS_NUM)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_code is null) or
(p_attribute_code = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
FND_MSG_PUB.Add;
end if;
end if;

l_count := 0;
if ((p_value_varchar2 is not null) and
(p_value_varchar2 <> FND_API.G_MISS_CHAR)) then
l_count := l_count + 1;
end if;
if ((p_value_date is not null) and
(p_value_date <> FND_API.G_MISS_DATE)) then
l_count := l_count + 1;
end if;
if ((p_value_number is not null) and
(p_value_number <> FND_API.G_MISS_NUM)) then
l_count := l_count + 1;
end if;
if (l_count <> 1) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_ONE_VALUE_ONLY');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('One and only one of value_vachar2, value_number' ||
--                     ' and value_date must be non-null');
end if;

-- - Check that the parent object attribute exists and that the
--   value columns other than the one corresponding to the data
--   type of the parent object attribute must be null
open l_check_objattr_csr;
fetch l_check_objattr_csr into l_dummy;
if (l_check_objattr_csr%notfound) then
close l_check_objattr_csr;
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_OA_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Parent object attribute does not exist!');
else
close l_check_objattr_csr;
l_data_type := null;
open l_check_datatype_csr;
fetch l_check_datatype_csr into l_data_type;
close l_check_datatype_csr;
if (upper(l_data_type) = 'VARCHAR2') then
if (p_value_date is not null) or (p_value_number is not null) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_MUST_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'VALUE_DATE');
FND_MSG_PUB.Add;
FND_MESSAGE.SET_NAME('AK','AK_MUST_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'VALUE_NUMBER');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('value_date and value_number must be null');
end if;
elsif (upper(l_data_type) = 'NUMBER') then
if (p_value_date is not null) or (p_value_varchar2 is not null) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_MUST_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'VALUE_DATE');
FND_MSG_PUB.Add;
FND_MESSAGE.SET_NAME('AK','AK_MUST_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'VALUE_VARCHAR2');
FND_MSG_PUB.Add;
end if;
--  dbms_output.put_line('value_date and value_varchar2 must be null');
end if;
elsif ( (upper(l_data_type) = 'DATE') or
(upper(l_data_type) = 'DATETIME') )then
if (p_value_number is not null) or (p_value_varchar2 is not null) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_MUST_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'VALUE_NUMBER');
FND_MSG_PUB.Add;
FND_MESSAGE.SET_NAME('AK','AK_MUST_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'VALUE_VARCHAR2');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('value_number and value_varchar2 must be null');
end if;
end if;
end if;

--** check that required columns are not null and, unless calling  **
--** from UPDATE procedure, the columns are not missing            **
if ((p_to_region_appl_id is null) or
(p_to_region_appl_id = FND_API.G_MISS_NUM and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_REGION_APPL_ID');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_to_region_code is null) or
(p_to_region_code = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_REGION_CODE');
FND_MSG_PUB.Add;
end if;
end if;

--** Validate columns **
-- - A region with to_region_appl_id and to_region_code must exist
--   and the region must be for the same database object as the
--   current attribute navigation record
if (p_to_region_appl_id <> FND_API.G_MISS_NUM) or
(p_to_region_code <> FND_API.G_MISS_CHAR) then
if (NOT valid_to_region (p_to_region_appl_id,
p_to_region_code,
p_database_object_name) ) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_TO_REGION');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_to_region_appl_id) ||
' ' || p_to_region_code);
FND_MESSAGE.SET_TOKEN('OBJECT', p_database_object_name );
FND_MSG_PUB.Add;
end if;
end if;
end if; /* if p_to_region_appl_id */

-- return true if no error, false otherwise
p_return_status := FND_API.G_RET_STS_SUCCESS;
return (not l_error);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;

end VALIDATE_ATTRIBUTE_NAVIGATION;

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
) return BOOLEAN is
cursor l_check_objattr_csr is
select null
from  AK_OBJECT_ATTRIBUTES
where database_object_name = p_database_object_name
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
cursor l_check_datatype_csr is
select data_type
from  AK_ATTRIBUTES
where attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Validate_Attribute_Value';
l_data_type               VARCHAR2(30);
l_dummy                   NUMBER;
l_error                   BOOLEAN;
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

l_error := FALSE;

--** if validation level is none, no validation is necessary
if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

--** check that key columns are not null and not missing **
--** note that key_value2 thru key_value10 can be null and
--** so they are not checked here
if ((p_database_object_name is null) or
(p_database_object_name = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'DATABASE_OBJECT_NAME');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_application_id is null) or
(p_attribute_application_id = FND_API.G_MISS_NUM)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_code is null) or
(p_attribute_code = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_key_value1 is null) or
(p_key_value1 = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'KEY_VALUE1');
FND_MSG_PUB.Add;
end if;
end if;

-- - Check that the parent object attribute exists and that the
--   value columns other than the one corresponding to the data
--   type of the parent object attribute must be null
open l_check_objattr_csr;
fetch l_check_objattr_csr into l_dummy;
if (l_check_objattr_csr%notfound) then
close l_check_objattr_csr;
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_OA_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Parent object attribute does not exist!');
else
close l_check_objattr_csr;
l_data_type := null;
open l_check_datatype_csr;
fetch l_check_datatype_csr into l_data_type;
close l_check_datatype_csr;
-- value_varchar2 is not null, error if data type is not varchar2
if (p_value_varchar2 is not null) and
(p_value_varchar2 <> FND_API.G_MISS_CHAR) then
if (upper(l_data_type) <>  'VARCHAR2') then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_MUST_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'VALUE_VARCHAR2');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('value_varchar2 must be null for this attribute');
end if;
end if;
-- value_number is not null, error if data type is not number
if (p_value_number is not null) and
(p_value_number <> FND_API.G_MISS_NUM) then
if (upper(l_data_type) <>  'NUMBER') then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_MUST_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'VALUE_NUMBER');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('value_number must be null for this attribute');
end if;
end if;
-- value_date is not null, error if data type is not date or datetime
if (p_value_date is not null) and
(p_value_date <> FND_API.G_MISS_DATE) then
if (upper(l_data_type) <>  'DATE') and
(upper(l_data_type) <> 'DATETIME') then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_MUST_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'VALUE_DATE');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('value_date must be null for this attribute');
end if;
end if;
end if;

-- return true if no error, false otherwise
p_return_status := FND_API.G_RET_STS_SUCCESS;
return (not l_error);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;

end VALIDATE_ATTRIBUTE_VALUE;


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
) return BOOLEAN is
cursor l_check_object_csr (p_view_owner varchar2) is
select 1
from   ALL_VIEWS
where  view_name = p_database_object_name
and owner = p_view_owner
union all
select 1
from   FND_VIEWS
where  view_name = p_database_object_name;
cursor l_get_apps_universal_usr is
select oracle_username
from fnd_oracle_userid
where read_only_flag='U';

l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Validate_Object';
l_dummy                   number;
l_view_owner		  VARCHAR2(30);
l_error                   BOOLEAN;
l_return_status           VARCHAR2(1);
begin

IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

l_error := FALSE;

--** if validation level is none, no validation is necessary
if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

--** check that key columns are not null and not missing **
if ((p_database_object_name is null) or
(p_database_object_name = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'DATABASE_OBJECT_NAME');
FND_MSG_PUB.Add;
end if;
end if;

-- - Check that the database object name is the name of a
--   view in the database
if (p_primary_key_name <> FND_API.G_MISS_CHAR) and
(p_primary_key_name is not null) then
open l_get_apps_universal_usr;
fetch l_get_apps_universal_usr into l_view_owner;
close l_get_apps_universal_usr;
open l_check_object_csr(l_view_owner);
fetch l_check_object_csr into l_dummy;
if (l_check_object_csr%notfound) then
-- flag an error only during download
if ( AK_ON_OBJECTS_PUB.G_LOAD_MODE = 'DOWNLOAD' or p_pass = 1 ) then
l_error := TRUE;
end if;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_VIEW_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name);
FND_MSG_PUB.Add;
end if;
end if;
close l_check_object_csr;
end if; -- if p_primary_key_name

--** check that required columns are not null and, unless calling  **
--** from UPDATE procedure, the columns are not missing            **
if ((p_application_id is null) or
(p_application_id = FND_API.G_MISS_NUM and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;

--** Validate columns **

-- - application ID
if (p_application_id <> FND_API.G_MISS_NUM) then
if (NOT AK_ON_OBJECTS_PVT.VALID_APPLICATION_ID (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => p_application_id)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Invalid application ID');
end if;
end if;

-- - primary_key_name
if (p_primary_key_name <> FND_API.G_MISS_CHAR) and
(p_primary_key_name is not null)  then
if (NOT VALID_PRIMARY_KEY_NAME (
p_database_object_name => p_database_object_name,
p_primary_key_name => p_primary_key_name)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','PRIMARY_KEY_NAME');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- return true if no error, false otherwise
p_return_status := FND_API.G_RET_STS_SUCCESS;
return (not l_error);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;

end VALIDATE_OBJECT;


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
) is
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Append_Object_PK_Tables';
l_from_index              NUMBER;
l_return_status           VARCHAR2(1);
l_to_index                NUMBER;
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- if from table is empty, return without doing anything else
if (p_from_table.count = 0) then
p_return_status := FND_API.G_RET_STS_SUCCESS;
return;
end if;

for l_from_index in p_from_table.FIRST .. p_from_table.LAST LOOP
if (p_from_table.EXISTS(l_from_index)) then
AK_OBJECT_PVT.INSERT_OBJECT_PK_TABLE (
p_return_status => l_return_status,
p_database_object_name => p_from_table(l_from_index),
p_object_pk_tbl => p_to_table);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_INSERT_OBJECT_PK_FAILED');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line(l_api_name || 'Error inserting object PK table');
raise FND_API.G_EXC_ERROR;
end if;
end if;
end loop;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end APPEND_OBJECT_PK_TABLES;

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
) return BOOLEAN is
cursor l_check_objattr_csr is
select 1
from  AK_OBJECT_ATTRIBUTES
where database_object_name = p_database_object_name
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Attribute_Exists';
l_dummy              number;
begin

IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

open l_check_objattr_csr;
fetch l_check_objattr_csr into l_dummy;
if (l_check_objattr_csr%notfound) then
close l_check_objattr_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_check_objattr_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;
end ATTRIBUTE_EXISTS;

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
) return BOOLEAN is
cursor l_checkexist_1_csr is
select 1
from  AK_OBJECT_ATTRIBUTE_NAVIGATION
where DATABASE_OBJECT_NAME = p_database_object_name
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code
and   VALUE_VARCHAR2 = p_value_varchar2
and   VALUE_DATE is null
and   VALUE_NUMBER is null;
cursor l_checkexist_2_csr is
select 1
from  AK_OBJECT_ATTRIBUTE_NAVIGATION
where DATABASE_OBJECT_NAME = p_database_object_name
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code
and   VALUE_VARCHAR2 is null
and   VALUE_DATE = p_value_date
and   VALUE_NUMBER is null;
cursor l_checkexist_3_csr is
select 1
from  AK_OBJECT_ATTRIBUTE_NAVIGATION
where DATABASE_OBJECT_NAME = p_database_object_name
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code
and   VALUE_VARCHAR2 is null
and   VALUE_DATE is null
and   VALUE_NUMBER = p_value_number;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Attribute_Navigation_Exists';
l_dummy              number;
begin

IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

--** check to see if row already exists, using the appropriate  **
--** cursor depending on which is the non-null value            **
if (p_value_varchar2 is not null) then
open l_checkexist_1_csr;
fetch l_checkexist_1_csr into l_dummy;
if (l_checkexist_1_csr%notfound) then
close l_checkexist_1_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_checkexist_1_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;
elsif (p_value_date is not null) then
open l_checkexist_2_csr;
fetch l_checkexist_2_csr into l_dummy;
if (l_checkexist_2_csr%notfound) then
close l_checkexist_2_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_checkexist_2_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;
elsif (p_value_number is not null) then
open l_checkexist_3_csr;
fetch l_checkexist_3_csr into l_dummy;
if (l_checkexist_3_csr%notfound) then
close l_checkexist_3_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_checkexist_3_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;
end if;

-- none of the above - all value columns are null
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;
end ATTRIBUTE_NAVIGATION_EXISTS;

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
) return BOOLEAN is
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30) := 'Attribute_Value_Exists';
l_dummy                 number;
l_key_value2            VARCHAR2(100);
l_key_value3            VARCHAR2(100);
l_key_value4            VARCHAR2(100);
l_key_value5            VARCHAR2(100);
l_key_value6            VARCHAR2(100);
l_key_value7            VARCHAR2(100);
l_key_value8            VARCHAR2(100);
l_key_value9            VARCHAR2(100);
l_key_value10           VARCHAR2(100);
l_sql_csr               integer;
l_sql_stmt              varchar2(1000);
l_where_clause          varchar2(1000);
begin

IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

-- load the optional key values to be used to query the database.
--
if (p_key_value2 is not null and p_key_value2 <> FND_API.G_MISS_CHAR) then
l_key_value2 := p_key_value2;
end if;
if (p_key_value3 is not null and p_key_value3 <> FND_API.G_MISS_CHAR) then
l_key_value3 := p_key_value3;
end if;
if (p_key_value4 is not null and p_key_value4 <> FND_API.G_MISS_CHAR) then
l_key_value4 := p_key_value4;
end if;
if (p_key_value5 is not null and p_key_value5 <> FND_API.G_MISS_CHAR) then
l_key_value5 := p_key_value5;
end if;
if (p_key_value6 is not null and p_key_value6 <> FND_API.G_MISS_CHAR) then
l_key_value6 := p_key_value6;
end if;
if (p_key_value7 is not null and p_key_value7 <> FND_API.G_MISS_CHAR) then
l_key_value7 := p_key_value7;
end if;
if (p_key_value8 is not null and p_key_value8 <> FND_API.G_MISS_CHAR) then
l_key_value8 := p_key_value8;
end if;
if (p_key_value9 is not null and p_key_value9 <> FND_API.G_MISS_CHAR) then
l_key_value9 := p_key_value9;
end if;
if (p_key_value10 is not null and p_key_value10 <> FND_API.G_MISS_CHAR) then
l_key_value10 := p_key_value10;
end if;

--
-- build where clause
--
l_where_clause := 'where database_object_name = :database_object_name ' ||
'and attribute_application_id = :attribute_application_id '||
'and attribute_code = :attribute_code ' ||
'and key_value1 = :key_value1 ';
if (l_key_value2 is null) then
l_where_clause := l_where_clause || 'and key_value2 is null ';
else
l_where_clause := l_where_clause || 'and key_value2 = :key_value2 ';
end if;
if (l_key_value3 is null) then
l_where_clause := l_where_clause || 'and key_value3 is null ';
else
l_where_clause := l_where_clause || 'and key_value3 = :key_value3 ';
end if;
if (l_key_value4 is null) then
l_where_clause := l_where_clause || 'and key_value4 is null ';
else
l_where_clause := l_where_clause || 'and key_value4 = :key_value4 ';
end if;
if (l_key_value5 is null) then
l_where_clause := l_where_clause || 'and key_value5 is null ';
else
l_where_clause := l_where_clause || 'and key_value5 = :key_value5 ';
end if;
if (l_key_value6 is null) then
l_where_clause := l_where_clause || 'and key_value6 is null ';
else
l_where_clause := l_where_clause || 'and key_value6 = :key_value6 ';
end if;
if (l_key_value7 is null) then
l_where_clause := l_where_clause || 'and key_value7 is null ';
else
l_where_clause := l_where_clause || 'and key_value7 = :key_value7 ';
end if;
if (l_key_value8 is null) then
l_where_clause := l_where_clause || 'and key_value8 is null ';
else
l_where_clause := l_where_clause || 'and key_value8 = :key_value8 ';
end if;
if (l_key_value9 is null) then
l_where_clause := l_where_clause || 'and key_value9 is null ';
else
l_where_clause := l_where_clause || 'and key_value9 = :key_value9 ';
end if;
if (l_key_value10 is null) then
l_where_clause := l_where_clause || 'and key_value10 is null ';
else
l_where_clause := l_where_clause || 'and key_value10 = :key_value10 ';
end if;

--
-- check to see if row already exists
--
l_sql_stmt := 'select 1 ' ||
'from ak_inst_attribute_values ' || l_where_clause;
l_sql_csr := dbms_sql.open_cursor;
dbms_sql.parse(l_sql_csr, l_sql_stmt, DBMS_SQL.V7);
dbms_sql.define_column(l_sql_csr, 1, l_dummy);

dbms_sql.bind_variable(l_sql_csr, 'database_object_name',
p_database_object_name);
dbms_sql.bind_variable(l_sql_csr, 'attribute_application_id',
p_attribute_application_id);
dbms_sql.bind_variable(l_sql_csr, 'attribute_code',p_attribute_code);
dbms_sql.bind_variable(l_sql_csr, 'key_value1', p_key_value1);
if (l_key_value2 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value2', l_key_value2);
end if;
if (l_key_value3 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value3', l_key_value3);
end if;
if (l_key_value4 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value4', l_key_value4);
end if;
if (l_key_value5 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value5', l_key_value5);
end if;
if (l_key_value6 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value6', l_key_value6);
end if;
if (l_key_value7 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value7', l_key_value7);
end if;
if (l_key_value8 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value8', l_key_value8);
end if;
if (l_key_value9 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value9', l_key_value9);
end if;
if (l_key_value10 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value10', l_key_value10);
end if;

if (dbms_sql.execute_and_fetch(l_sql_csr) = 0) then
dbms_sql.close_cursor(l_sql_csr);
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
dbms_sql.close_cursor(l_sql_csr);
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;
end ATTRIBUTE_VALUE_EXISTS;

-- CREATE comes back in here

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
) return BOOLEAN is
cursor l_checklov_csr is
select 1
from  AK_OBJECTS
where database_object_name = p_database_object_name;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Object_Exists';
l_dummy number;
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

open l_checklov_csr;
fetch l_checklov_csr into l_dummy;
if (l_checklov_csr%notfound) then
close l_checklov_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_checklov_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
return FALSE;
end OBJECT_EXISTS;

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
) is
cursor l_get_attr_values_csr is
select key_value1, key_value2, key_value3, key_value4, key_value5,
key_value6, key_value7, key_value8, key_value9, key_value10
from   AK_INST_ATTRIBUTE_VALUES
where  database_object_name = p_database_object_name
and    attribute_application_id = p_attribute_application_id
and    attribute_code = p_attribute_code;
cursor l_get_navigations_csr is
select value_varchar2, value_date, value_number
from   AK_OBJECT_ATTRIBUTE_NAVIGATION
where  database_object_name = p_database_object_name
and    attribute_application_id = p_attribute_application_id
and    attribute_code = p_attribute_code;
cursor l_get_region_item_csr is
select ari.REGION_APPLICATION_ID, ari.REGION_CODE
from   AK_REGION_ITEMS ari, AK_REGIONS ar
where  ar.database_object_name = p_database_object_name
and    ar.region_application_id = ari.region_application_id
and    ar.region_code = ari.region_code
and    ari.attribute_application_id = p_attribute_application_id
and    ari.attribute_code = p_attribute_code
and    ari.OBJECT_ATTRIBUTE_FLAG = 'Y';
cursor l_get_page_region_item_csr is
select afpri.FLOW_APPLICATION_ID, afpri.FLOW_CODE,
afpri.PAGE_APPLICATION_ID, afpri.PAGE_CODE,
afpri.REGION_APPLICATION_ID, afpri.REGION_CODE
from   AK_FLOW_PAGE_REGION_ITEMS afpri, AK_REGIONS ar
where  ar.region_application_id = afpri.region_application_id
and    ar.region_code = afpri.region_code
and    ar.database_object_name = p_database_object_name
and    afpri.to_url_attribute_appl_id = p_attribute_application_id
and    afpri.to_url_attribute_code = p_attribute_code;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30) := 'Delete_Attribute';
l_flow_application_id   NUMBER;
l_flow_code             VARCHAR2(30);
l_key_value1            VARCHAR2(100);
l_key_value2            VARCHAR2(100);
l_key_value3            VARCHAR2(100);
l_key_value4            VARCHAR2(100);
l_key_value5            VARCHAR2(100);
l_key_value6            VARCHAR2(100);
l_key_value7            VARCHAR2(100);
l_key_value8            VARCHAR2(100);
l_key_value9            VARCHAR2(100);
l_key_value10           VARCHAR2(100);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_page_application_id   NUMBER;
l_page_code             VARCHAR2(30);
l_region_application_id NUMBER;
l_region_code           VARCHAR2(30);
l_return_status         varchar2(1);
l_value_date            DATE;
l_value_number          NUMBER;
l_value_varchar2        VARCHAR2(240);
begin

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

--
-- error if object attribute to be deleted does not exists
--
if NOT AK_OBJECT_PVT.ATTRIBUTE_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the object attribute if it is being referenced in any of
-- following tables.
--
-- AK_OBJECT_ATTRIBUTE_NAVIGATION
--
open l_get_navigations_csr;
fetch l_get_navigations_csr into l_value_varchar2, l_value_date,
l_value_number;
if l_get_navigations_csr%found then
close l_get_navigations_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_OA_NAV');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_navigations_csr;
--
-- AK_INST_ATTRIBUTE_VALUES
--
open l_get_attr_values_csr;
fetch l_get_attr_values_csr into
l_key_value1, l_key_value2, l_key_value3, l_key_value4, l_key_value5,
l_key_value6, l_key_value7, l_key_value8, l_key_value9, l_key_value10;
if l_get_attr_values_csr%found then
close l_get_attr_values_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DELETE_REFERENCE');
FND_MESSAGE.SET_TOKEN('OBJECT', 'AK_OBJECT_ATTRIBUTES',TRUE);
FND_MESSAGE.SET_TOKEN('REF_OBJECT', 'AK_ATTRIBUTE_VALUE',TRUE);
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_attr_values_csr;
--
-- AK_REGION_ITEMS
--
open l_get_region_item_csr;
fetch l_get_region_item_csr into l_region_application_id, l_region_code;
if l_get_region_item_csr%found then
close l_get_region_item_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_OA_ITEM');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_region_item_csr;
--
-- AK_FLOW_PAGE_REGION_ITEMS
--
open l_get_page_region_item_csr;
fetch l_get_page_region_item_csr into l_flow_application_id, l_flow_code,
l_page_application_id, l_page_code,
l_region_application_id, l_region_code;
if l_get_page_region_item_csr%found then
close l_get_page_region_item_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_OA_PREGIM');
FND_MESSAGE.SET_TOKEN('OBJECT', 'AK_OBJECT_ATTRIBUTES',TRUE);
FND_MESSAGE.SET_TOKEN('REF_OBJECT', 'AK_REGION_ITEMS',TRUE);
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_page_region_item_csr;

else
--
-- Otherwise, delete all referencing rows in other tables
--
-- AK_OBJECT_ATTRIBUTE_NAVIGATION
--
open l_get_navigations_csr;
loop
fetch l_get_navigations_csr into l_value_varchar2, l_value_date,
l_value_number;
exit when l_get_navigations_csr%notfound;
AK_OBJECT_PVT.DELETE_ATTRIBUTE_NAVIGATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_value_varchar2 => l_value_varchar2,
p_value_date => l_value_date,
p_value_number => l_value_number,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_navigations_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_navigations_csr;
--
-- AK_INST_ATTRIBUTE_VALUES
--
open l_get_attr_values_csr;
loop
fetch l_get_attr_values_csr into
l_key_value1, l_key_value2, l_key_value3, l_key_value4, l_key_value5,
l_key_value6, l_key_value7, l_key_value8, l_key_value9, l_key_value10;
exit when l_get_attr_values_csr%notfound;
AK_OBJECT_PVT.DELETE_ATTRIBUTE_VALUE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_key_value1 => l_key_value1,
p_key_value2 => l_key_value2,
p_key_value3 => l_key_value3,
p_key_value4 => l_key_value4,
p_key_value5 => l_key_value5,
p_key_value6 => l_key_value6,
p_key_value7 => l_key_value7,
p_key_value8 => l_key_value8,
p_key_value9 => l_key_value9,
p_key_value10 => l_key_value10,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_attr_values_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_attr_values_csr;
--
-- AK_REGION_ITEMS
--
open l_get_region_item_csr;
loop
fetch l_get_region_item_csr into l_region_application_id, l_region_code;
exit when l_get_region_item_csr%notfound;
AK_REGION_PVT.DELETE_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_region_application_id => l_region_application_id,
p_region_code => l_region_code,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_region_item_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_region_item_csr;
--
-- AK_FLOW_PAGE_REGION_ITEMS
--
open l_get_page_region_item_csr;
loop
fetch l_get_page_region_item_csr into l_flow_application_id, l_flow_code,
l_page_application_id, l_page_code,
l_region_application_id, l_region_code;
exit when l_get_page_region_item_csr%notfound;

AK_FLOW_PVT.DELETE_PAGE_REGION_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => l_flow_application_id,
p_flow_code => l_flow_code,
p_page_application_id => l_page_application_id,
p_page_code => l_page_code,
p_region_application_id => l_region_application_id,
p_region_code => l_region_code,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_delete_cascade => p_delete_cascade
);

if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_page_region_item_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_page_region_item_csr;

end if;

--
-- delete object attribute once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_object_attributes
where  database_object_name = p_database_object_name
and    attribute_application_id = p_attribute_application_id
and    attribute_code = p_attribute_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

delete from ak_object_attributes_tl
where  database_object_name = p_database_object_name
and    attribute_application_id = p_attribute_application_id
and    attribute_code = p_attribute_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_attribute;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_attribute;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_ATTRIBUTE;

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
p_delete_cascade           IN      VARCHAR2
) is
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30) := 'Delete_Attribute_Navigation';
l_return_status         varchar2(1);
begin

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

--
-- error if object attribute navigation record to be deleted does not exists
--
if NOT AK_OBJECT_PVT.ATTRIBUTE_NAVIGATION_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_value_varchar2 => p_value_varchar2,
p_value_date => p_value_date,
p_value_number => p_value_number) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_NAV_DOES_NOT_EXIST');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_NAVIGATION', TRUE);
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the object attribute navigation record if it is being
-- referenced in any of following tables.
--
-- (currently none)
--
null;
else
--
-- Otherwise, delete all referencing rows in other tables
--
-- (currently none)
--
null;
end if;

--
-- delete object attribute navigation record once we checked that there
-- are no references to it, or all references have been deleted.
--
if (p_value_varchar2 is not null) then
delete from ak_object_attribute_navigation
where database_object_name = p_database_object_name
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code
and   value_varchar2 = p_value_varchar2
and   value_date is null
and   value_number is null;
elsif (p_value_date is not null) then
delete from ak_object_attribute_navigation
where database_object_name = p_database_object_name
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code
and   value_varchar2 is null
and   value_date = p_value_date
and   value_number is null;
elsif (p_value_number is not null) then
delete from ak_object_attribute_navigation
where database_object_name = p_database_object_name
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code
and   value_varchar2 is null
and   value_date is null
and   value_number = p_value_number;
end if;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_NAV_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_NAV_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code ||
' ' || p_value_varchar2 ||
to_char(p_value_date) ||
to_char(p_value_number) );
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_NAV_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_NAVIGATION', TRUE);
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id)||
' ' || p_attribute_code ||
' ' ||  p_value_varchar2 ||
to_char(p_value_date) ||
to_char(p_value_number) );
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_navigation;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_navigation;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

end DELETE_ATTRIBUTE_NAVIGATION;

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
) is
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30) := 'Delete_Attribute_Value';
l_key_value2            VARCHAR2(100);
l_key_value3            VARCHAR2(100);
l_key_value4            VARCHAR2(100);
l_key_value5            VARCHAR2(100);
l_key_value6            VARCHAR2(100);
l_key_value7            VARCHAR2(100);
l_key_value8            VARCHAR2(100);
l_key_value9            VARCHAR2(100);
l_key_value10           VARCHAR2(100);
l_return_status         varchar2(1);
l_sql_csr               integer;
l_sql_stmt              varchar2(1000);
l_where_clause          varchar2(1000);
begin

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

--
-- load the optional key values to be used to query the database.
--
if (p_key_value2 is not null and p_key_value2 <> FND_API.G_MISS_CHAR) then
l_key_value2 := p_key_value2;
end if;
if (p_key_value3 is not null and p_key_value3 <> FND_API.G_MISS_CHAR) then
l_key_value3 := p_key_value3;
end if;
if (p_key_value4 is not null and p_key_value4 <> FND_API.G_MISS_CHAR) then
l_key_value4 := p_key_value4;
end if;
if (p_key_value5 is not null and p_key_value5 <> FND_API.G_MISS_CHAR) then
l_key_value5 := p_key_value5;
end if;
if (p_key_value6 is not null and p_key_value6 <> FND_API.G_MISS_CHAR) then
l_key_value6 := p_key_value6;
end if;
if (p_key_value7 is not null and p_key_value7 <> FND_API.G_MISS_CHAR) then
l_key_value7 := p_key_value7;
end if;
if (p_key_value8 is not null and p_key_value8 <> FND_API.G_MISS_CHAR) then
l_key_value8 := p_key_value8;
end if;
if (p_key_value9 is not null and p_key_value9 <> FND_API.G_MISS_CHAR) then
l_key_value9 := p_key_value9;
end if;
if (p_key_value10 is not null and p_key_value10 <> FND_API.G_MISS_CHAR) then
l_key_value10 := p_key_value10;
end if;

--
-- error if attribute value record to be deleted does not exists
--
if NOT AK_OBJECT_PVT.ATTRIBUTE_VALUE_EXISTS (
p_api_version_number => 1.0,
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
p_key_value10 => p_key_value10) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_DOES_NOT_EXIST');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the attribute value if it is being referenced in any of
-- following tables.
--
-- (currently none)
--
null;
else
--
-- Otherwise, delete all referencing rows in other tables
--
-- (currently none)
--
null;
end if;

--
-- delete attribute value record once we checked that there
-- are no references to it, or all references have been deleted.
--
-- build where clause
--
l_where_clause := 'where database_object_name = :database_object_name ' ||
'and attribute_application_id = :attribute_application_id '||
'and attribute_code = :attribute_code ' ||
'and key_value1 = :key_value1 ';
if (l_key_value2 is null) then
l_where_clause := l_where_clause || 'and key_value2 is null ';
else
l_where_clause := l_where_clause || 'and key_value2 = :key_value2 ';
end if;
if (l_key_value3 is null) then
l_where_clause := l_where_clause || 'and key_value3 is null ';
else
l_where_clause := l_where_clause || 'and key_value3 = :key_value3 ';
end if;
if (l_key_value4 is null) then
l_where_clause := l_where_clause || 'and key_value4 is null ';
else
l_where_clause := l_where_clause || 'and key_value4 = :key_value4 ';
end if;
if (l_key_value5 is null) then
l_where_clause := l_where_clause || 'and key_value5 is null ';
else
l_where_clause := l_where_clause || 'and key_value5 = :key_value5 ';
end if;
if (l_key_value6 is null) then
l_where_clause := l_where_clause || 'and key_value6 is null ';
else
l_where_clause := l_where_clause || 'and key_value6 = :key_value6 ';
end if;
if (l_key_value7 is null) then
l_where_clause := l_where_clause || 'and key_value7 is null ';
else
l_where_clause := l_where_clause || 'and key_value7 = :key_value7 ';
end if;
if (l_key_value8 is null) then
l_where_clause := l_where_clause || 'and key_value8 is null ';
else
l_where_clause := l_where_clause || 'and key_value8 = :key_value8 ';
end if;
if (l_key_value9 is null) then
l_where_clause := l_where_clause || 'and key_value9 is null ';
else
l_where_clause := l_where_clause || 'and key_value9 = :key_value9 ';
end if;
if (l_key_value10 is null) then
l_where_clause := l_where_clause || 'and key_value10 is null ';
else
l_where_clause := l_where_clause || 'and key_value10 = :key_value10 ';
end if;

l_sql_stmt := 'delete from ak_inst_attribute_values ' || l_where_clause;
l_sql_csr := dbms_sql.open_cursor;
dbms_sql.parse(l_sql_csr, l_sql_stmt, DBMS_SQL.V7);

dbms_sql.bind_variable(l_sql_csr, 'database_object_name',
p_database_object_name);
dbms_sql.bind_variable(l_sql_csr, 'attribute_application_id',
p_attribute_application_id);
dbms_sql.bind_variable(l_sql_csr, 'attribute_code',p_attribute_code);
dbms_sql.bind_variable(l_sql_csr, 'key_value1', p_key_value1);
if (l_key_value2 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value2', l_key_value2);
end if;
if (l_key_value3 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value3', l_key_value3);
end if;
if (l_key_value4 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value4', l_key_value4);
end if;
if (l_key_value5 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value5', l_key_value5);
end if;
if (l_key_value6 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value6', l_key_value6);
end if;
if (l_key_value7 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value7', l_key_value7);
end if;
if (l_key_value8 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value8', l_key_value8);
end if;
if (l_key_value9 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value9', l_key_value9);
end if;
if (l_key_value10 is not null) then
dbms_sql.bind_variable(l_sql_csr, 'key_value10', l_key_value10);
end if;

if (dbms_sql.execute(l_sql_csr) = 0) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_DOES_NOT_EXIST');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
FND_MSG_PUB.Add;
end if;
dbms_sql.close_cursor(l_sql_csr);
raise FND_API.G_EXC_ERROR;
end if;

dbms_sql.close_cursor(l_sql_csr);
--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_DELETED');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code ||
' ' || p_key_value1 ||
' ' || l_key_value2 ||
' ' || l_key_value3 ||
' ' || l_key_value4 ||
' ' || l_key_value5 ||
' ' || l_key_value6 ||
' ' || l_key_value7 ||
' ' || l_key_value8 ||
' ' || l_key_value9 ||
' ' || l_key_value10);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code ||
' ' || p_key_value1 ||
' ' || l_key_value2 ||
' ' || l_key_value3 ||
' ' || l_key_value4 ||
' ' || l_key_value5 ||
' ' || l_key_value6 ||
' ' || l_key_value7 ||
' ' || l_key_value8 ||
' ' || l_key_value9 ||
' ' || l_key_value10);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_value;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_value;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

end DELETE_ATTRIBUTE_VALUE;

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
) is
cursor l_get_obj_attributes_csr is
select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
from  AK_OBJECT_ATTRIBUTES
where database_object_name = p_database_object_name;
cursor l_get_foreign_keys_csr is
select foreign_key_name
from  AK_FOREIGN_KEYS
where database_object_name = p_database_object_name;
cursor l_get_unique_keys_csr is
select unique_key_name
from  AK_UNIQUE_KEYS
where database_object_name = p_database_object_name;
cursor l_get_regions_csr is
select REGION_APPLICATION_ID, REGION_CODE
from  AK_REGIONS
where database_object_name = p_database_object_name;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_object';
l_attribute_application_id NUMBER;
l_attribute_code        VARCHAR2(30);
l_database_object_name  VARCHAR2(30);
l_foreign_key_name      VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_region_application_id NUMBER;
l_region_code           VARCHAR2(30);
l_return_status         varchar2(1);
l_unique_key_name       VARCHAR2(30);
begin
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

--
-- error if object to be deleted does not exists
--
if NOT AK_OBJECT_PVT.OBJECT_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the object if it is being referenced in any of
-- following tables.
--
-- AK_OBJECT_ATTRIBUTES (parent-child relations)
--
open l_get_obj_attributes_csr;
fetch l_get_obj_attributes_csr into
l_attribute_application_id, l_attribute_code;
if l_get_obj_attributes_csr%found then
close l_get_obj_attributes_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_OBJ_OA');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_obj_attributes_csr;
--
-- AK_UNIQUE_KEYS
--
open l_get_unique_keys_csr;
fetch l_get_unique_keys_csr into l_unique_key_name;
if l_get_unique_keys_csr%found then
close l_get_unique_keys_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_OBJ_UK');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_unique_keys_csr;
--
-- AK_FOREIGN_KEYS
--
open l_get_foreign_keys_csr;
fetch l_get_foreign_keys_csr into l_foreign_key_name;
if l_get_foreign_keys_csr%found then
close l_get_foreign_keys_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_OBJ_FK');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_foreign_keys_csr;
--
-- AK_REGIONS
--
open l_get_regions_csr;
fetch l_get_regions_csr into l_region_application_id, l_region_code;
if l_get_regions_csr%found then
close l_get_regions_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_OBJ_REG');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_regions_csr;

else
--
-- Otherwise, delete all referencing rows in other tables, except
-- for records that are referencing this object as an lov object,
-- in which case these records will be updated with a null lov object.
--
-- AK_OBJECT_ATTRIBUTES (parent-child relations)
--
open l_get_obj_attributes_csr;
loop
fetch l_get_obj_attributes_csr into
l_attribute_application_id, l_attribute_code;
exit when l_get_obj_attributes_csr%notfound;
AK_OBJECT_PVT.DELETE_ATTRIBUTE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => l_attribute_application_id,
p_attribute_code => l_attribute_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_obj_attributes_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_obj_attributes_csr;
--
-- AK_UNIQUE_KEYS
--
open l_get_unique_keys_csr;
loop
fetch l_get_unique_keys_csr into l_unique_key_name;
exit when l_get_unique_keys_csr%notfound;
AK_KEY_PVT.DELETE_UNIQUE_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_unique_key_name => l_unique_key_name,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_unique_keys_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_unique_keys_csr;
--
-- AK_FOREIGN_KEYS
--
open l_get_foreign_keys_csr;
loop
fetch l_get_foreign_keys_csr into l_foreign_key_name;
exit when l_get_foreign_keys_csr%notfound;
AK_KEY_PVT.DELETE_FOREIGN_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_foreign_key_name => l_foreign_key_name,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_foreign_keys_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_foreign_keys_csr;
--
-- AK_REGIONS
--
open l_get_regions_csr;
loop
fetch l_get_regions_csr into l_region_application_id, l_region_code;
exit when l_get_regions_csr%notfound;
AK_REGION_PVT.DELETE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_region_application_id => l_region_application_id,
p_region_code => l_region_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_regions_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_regions_csr;

end if;

--
-- delete object once we checked that there are no references
-- to it, or all references have been deleted or blanked out.
--
delete from ak_objects
where  database_object_name = p_database_object_name;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_object;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_object;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

end DELETE_OBJECT;

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
) is
l_api_name           CONSTANT varchar2(30) := 'Insert_Object_PK_Table';
l_index              NUMBER;
begin
-- if table is empty, just insert the database object name into it
if (p_object_pk_tbl.count = 0) then
p_object_pk_tbl(1) := p_database_object_name;
return;
end if;

-- otherwise, insert the database object name to the end of the
-- table if it is not already in the table.
for l_index in p_object_pk_tbl.FIRST .. p_object_pk_tbl.LAST loop
if (p_object_pk_tbl.exists(l_index)) then
if (p_object_pk_tbl(l_index) = p_database_object_name) then
return;
end if;
end if;
end loop;

l_index := p_object_pk_tbl.LAST + 1;
p_object_pk_tbl(l_index) := p_database_object_name;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end INSERT_OBJECT_PK_TABLE;

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
) is
l_api_version_number  CONSTANT number := 1.0;
l_api_name            CONSTANT varchar2(30) := 'Create_Object';
l_created_by          number;
l_creation_date       date;
l_defaulting_api_pkg  varchar2(30);
l_defaulting_api_proc varchar2(30);
l_description         varchar2(2000) := null;
l_lang                varchar2(30);
l_last_update_date    date;
l_last_update_login   number;
l_last_updated_by     number;
l_name                varchar2(30) := null;
l_primary_key_name    varchar2(30);
l_return_status       varchar2(1);
l_validation_api_pkg  varchar2(30);
l_validation_api_proc varchar2(30);
l_attribute_category  VARCHAR2(30);
l_attribute1          VARCHAR2(150);
l_attribute2          VARCHAR2(150);
l_attribute3          VARCHAR2(150);
l_attribute4          VARCHAR2(150);
l_attribute5          VARCHAR2(150);
l_attribute6          VARCHAR2(150);
l_attribute7          VARCHAR2(150);
l_attribute8          VARCHAR2(150);
l_attribute9          VARCHAR2(150);
l_attribute10         VARCHAR2(150);
l_attribute11         VARCHAR2(150);
l_attribute12         VARCHAR2(150);
l_attribute13         VARCHAR2(150);
l_attribute14         VARCHAR2(150);
l_attribute15         VARCHAR2(150);
begin

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

--** check to see if row already exists **
if (AK_OBJECT_PVT.OBJECT_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name)) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_EXISTS');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line(G_PKG_NAME || 'Error - Row already exists');
raise FND_API.G_EXC_ERROR;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_OBJECT_PVT.VALIDATE_OBJECT(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
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
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if; -- /* if p_pass */
end if; -- /* if not VALIDATE_OBJECT */
end if;

--** Load non-required columns if their values are given **
--   (l_primary_key_name is already loaded)

if (p_name <> FND_API.G_MISS_CHAR) then
l_name := p_name;
end if;

if (p_description <> FND_API.G_MISS_CHAR) then
l_description := p_description;
end if;

if (p_defaulting_api_pkg <> FND_API.G_MISS_CHAR) then
l_defaulting_api_pkg := p_defaulting_api_pkg;
end if;

if (p_defaulting_api_proc <> FND_API.G_MISS_CHAR) then
l_defaulting_api_proc := p_defaulting_api_proc;
end if;

if (p_validation_api_pkg <> FND_API.G_MISS_CHAR) then
l_validation_api_pkg := p_validation_api_pkg;
end if;

if (p_validation_api_proc <> FND_API.G_MISS_CHAR) then
l_validation_api_proc := p_validation_api_proc;
end if;

if (p_attribute_category <> FND_API.G_MISS_CHAR) then
l_attribute_category := p_attribute_category;
end if;

if (p_attribute1 <> FND_API.G_MISS_CHAR) then
l_attribute1 := p_attribute1;
end if;

if (p_attribute2 <> FND_API.G_MISS_CHAR) then
l_attribute2 := p_attribute2;
end if;

if (p_attribute3 <> FND_API.G_MISS_CHAR) then
l_attribute3 := p_attribute3;
end if;

if (p_attribute4 <> FND_API.G_MISS_CHAR) then
l_attribute4 := p_attribute4;
end if;

if (p_attribute5 <> FND_API.G_MISS_CHAR) then
l_attribute5 := p_attribute5;
end if;

if (p_attribute6 <> FND_API.G_MISS_CHAR) then
l_attribute6 := p_attribute6;
end if;

if (p_attribute7 <> FND_API.G_MISS_CHAR) then
l_attribute7:= p_attribute7;
end if;

if (p_attribute8 <> FND_API.G_MISS_CHAR) then
l_attribute8 := p_attribute8;
end if;

if (p_attribute9 <> FND_API.G_MISS_CHAR) then
l_attribute9 := p_attribute9;
end if;

if (p_attribute10 <> FND_API.G_MISS_CHAR) then
l_attribute10 := p_attribute10;
end if;

if (p_attribute11 <> FND_API.G_MISS_CHAR) then
l_attribute11 := p_attribute11;
end if;

if (p_attribute12 <> FND_API.G_MISS_CHAR) then
l_attribute12 := p_attribute12;
end if;

if (p_attribute13 <> FND_API.G_MISS_CHAR) then
l_attribute13 := p_attribute13;
end if;

if (p_attribute14 <> FND_API.G_MISS_CHAR) then
l_attribute14 := p_attribute14;
end if;

if (p_attribute15 <> FND_API.G_MISS_CHAR) then
l_attribute15 := p_attribute15;
end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;

  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;

  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;

  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;

  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

-- Create record if no validation error was found
  --  NOTE - Calling IS_UPDATEABLE for backward compatibility
  --  old jlt files didn't have who columns and IS_UPDATEABLE
  --  calls SET_WHO which populates those columns, for later
  --  jlt files IS_UPDATEABLE will always return TRUE for CREATE

if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => null,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => null,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'CREATE') then
     null;
  end if;

select userenv('LANG') into l_lang
from dual;

insert into AK_OBJECTS (
DATABASE_OBJECT_NAME,
APPLICATION_ID,
PRIMARY_KEY_NAME,
DEFAULTING_API_PKG,
DEFAULTING_API_PROC,
VALIDATION_API_PKG,
VALIDATION_API_PROC,
ATTRIBUTE_CATEGORY,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
ATTRIBUTE11,
ATTRIBUTE12,
ATTRIBUTE13,
ATTRIBUTE14,
ATTRIBUTE15,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN
) values (
p_database_object_name,
p_application_id,
p_primary_key_name,
l_defaulting_api_pkg,
l_defaulting_api_proc,
l_validation_api_pkg,
l_validation_api_proc,
l_attribute_category,
l_attribute1,
l_attribute2,
l_attribute3,
l_attribute4,
l_attribute5,
l_attribute6,
l_attribute7,
l_attribute8,
l_attribute9,
l_attribute10,
l_attribute11,
l_attribute12,
l_attribute13,
l_attribute14,
l_attribute15,
l_creation_date,
l_created_by,
l_last_update_date,
l_last_updated_by,
l_last_update_login
);

--  /** commit the insert **/
--  commit;

--** row should exists before inserting rows for other languages **
if (NOT AK_OBJECT_PVT.OBJECT_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name)) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_INSERT_OBJECT_FAILED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

insert into AK_OBJECTS_TL (
DATABASE_OBJECT_NAME,
LANGUAGE,
NAME,
DESCRIPTION,
SOURCE_LANG,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN
) select
p_database_object_name,
L.LANGUAGE_CODE,
l_name,
l_description,
decode(L.LANGUAGE_CODE, l_lang, L.LANGUAGE_CODE, l_lang),
l_created_by,
l_creation_date,
l_last_updated_by,
l_last_update_date,
l_last_update_login
from FND_LANGUAGES L
where L.INSTALLED_FLAG in ('I', 'B')
and not exists
(select NULL
from AK_OBJECTS_TL T
where T.DATABASE_OBJECT_NAME = p_database_object_name
and T.LANGUAGE = L.LANGUAGE_CODE);

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',p_database_object_name);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name);
FND_MSG_PUB.Add;
end if;
rollback to start_create_object;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',p_database_object_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_object;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_object;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_OBJECT;

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
) is
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Create_Attribute';
l_attribute_label_long    VARCHAR2(80);
l_attribute_label_short   VARCHAR2(40);
l_base_table_column_name  VARCHAR2(30);
l_column_name             VARCHAR2(30);
l_created_by              number;
l_creation_date           date;
l_data_storage_type       VARCHAR2(30);
l_default_value_varchar2  VARCHAR2(240) := null;
l_default_value_number    number;
l_default_value_date      date;
l_defaulting_api_pkg      VARCHAR2(30);
l_defaulting_api_proc     VARCHAR2(30);
l_validation_api_pkg      VARCHAR2(30);
l_validation_api_proc     VARCHAR2(30);
l_error                   boolean;
l_lang                    varchar2(30);
l_last_update_date        date;
l_last_update_login       number;
l_last_updated_by         number;
l_lov_attribute_appl_id   NUMBER;
l_lov_attribute_code      VARCHAR2(30);
l_lov_foreign_key_name    VARCHAR2(30);
l_lov_region_appl_id      NUMBER;
l_lov_region_code         VARCHAR2(30);
l_attribute_category      VARCHAR2(30);
l_attribute1              VARCHAR2(150);
l_attribute2              VARCHAR2(150);
l_attribute3              VARCHAR2(150);
l_attribute4              VARCHAR2(150);
l_attribute5              VARCHAR2(150);
l_attribute6              VARCHAR2(150);
l_attribute7              VARCHAR2(150);
l_attribute8              VARCHAR2(150);
l_attribute9              VARCHAR2(150);
l_attribute10             VARCHAR2(150);
l_attribute11             VARCHAR2(150);
l_attribute12             VARCHAR2(150);
l_attribute13             VARCHAR2(150);
l_attribute14             VARCHAR2(150);
l_attribute15             VARCHAR2(150);
l_return_status           varchar2(1);
l_table_name              VARCHAR2(30);
begin

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

--** check to see if row already exists **
if (AK_OBJECT_PVT.ATTRIBUTE_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) ) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_EXISTS');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('OA Key: '||p_database_object_name ||
--                     ' ' || to_char(p_attribute_application_id) ||
--					 ' ' || p_attribute_code );
raise FND_API.G_EXC_ERROR;
end if;

--** create with blank lov region application id, lov region code, and
--** foreign key name if calling from the loader **
--   (this is because no foreign key or region records have been loaded
--    at the time when the loader is creating object attributes)
if (p_loader_timestamp <> FND_API.G_MISS_DATE) then
l_lov_region_appl_id := null;
l_lov_region_code := null;
l_lov_foreign_key_name := null;
else
if (p_lov_region_application_id <> FND_API.G_MISS_NUM) then
l_lov_region_appl_id := p_lov_region_application_id;
end if;
if (p_lov_region_code <> FND_API.G_MISS_CHAR) then
l_lov_region_code := p_lov_region_code;
end if;
if (p_lov_foreign_key_name <> FND_API.G_MISS_CHAR) then
l_lov_foreign_key_name := p_lov_foreign_key_name;
end if;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_OBJECT_PVT.VALIDATE_ATTRIBUTE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
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
p_lov_region_application_id => l_lov_region_appl_id,
p_lov_region_code => l_lov_region_code,
p_lov_foreign_key_name => l_lov_foreign_key_name,
p_lov_attribute_application_id => p_lov_attribute_application_id,
p_lov_attribute_code => p_lov_attribute_code,
p_defaulting_api_pkg => p_defaulting_api_pkg,
p_defaulting_api_proc => p_defaulting_api_proc,
p_validation_api_pkg => p_validation_api_pkg,
p_validation_api_proc => p_validation_api_proc,
p_attribute_label_long => p_attribute_label_long,
p_attribute_label_short => p_attribute_label_short,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
-- dbms_output.put_line(l_api_name || 'validation failed');
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
-- dbms_output.put_line('OA Key: '||p_database_object_name ||
--                     ' ' || to_char(p_attribute_application_id) ||
--					 ' ' || p_attribute_code );
raise FND_API.G_EXC_ERROR;
end if; -- /* if p_pass */
end if;
end if;

--** Load non-required columns if their values are given **
--   (except lov_region_code, lov_region_application_id and
--    lov_foreign_key_name which are already loaded)
--
if (p_column_name <> FND_API.G_MISS_CHAR) then
l_column_name := p_column_name;
end if;

if (p_data_storage_type <> FND_API.G_MISS_CHAR) then
l_data_storage_type := p_data_storage_type;
end if;

if (p_table_name <> FND_API.G_MISS_CHAR) then
l_table_name := p_table_name;
end if;

if (p_base_table_column_name <> FND_API.G_MISS_CHAR) then
l_base_table_column_name := p_base_table_column_name;
end if;

if (p_default_value_varchar2 <> FND_API.G_MISS_CHAR) then
l_default_value_varchar2 := p_default_value_varchar2;
end if;

if (p_default_value_number <> FND_API.G_MISS_NUM) then
l_default_value_number := p_default_value_number;
end if;

if (p_default_value_date <> FND_API.G_MISS_DATE) then
l_default_value_date := p_default_value_date;
end if;

if (p_lov_attribute_application_id <> FND_API.G_MISS_NUM) then
l_lov_attribute_appl_id := p_lov_attribute_application_id;
end if;

if (p_lov_attribute_code <> FND_API.G_MISS_CHAR) then
l_lov_attribute_code := p_lov_attribute_code;
end if;

if (p_defaulting_api_pkg <> FND_API.G_MISS_CHAR) then
l_defaulting_api_pkg := p_defaulting_api_pkg;
end if;

if (p_defaulting_api_proc <> FND_API.G_MISS_CHAR) then
l_defaulting_api_proc := p_defaulting_api_proc;
end if;

if (p_validation_api_pkg <> FND_API.G_MISS_CHAR) then
l_validation_api_pkg := p_validation_api_pkg;
end if;

if (p_validation_api_proc <> FND_API.G_MISS_CHAR) then
l_validation_api_proc := p_validation_api_proc;
end if;

if (p_attribute_label_long <> FND_API.G_MISS_CHAR) then
l_attribute_label_long := p_attribute_label_long;
end if;

if (p_attribute_label_short <> FND_API.G_MISS_CHAR) then
l_attribute_label_short := p_attribute_label_short;
end if;

if (p_attribute_category <> FND_API.G_MISS_CHAR) then
l_attribute_category := p_attribute_category;
end if;

if (p_attribute1 <> FND_API.G_MISS_CHAR) then
l_attribute1 := p_attribute1;
end if;

if (p_attribute2 <> FND_API.G_MISS_CHAR) then
l_attribute2 := p_attribute2;
end if;

if (p_attribute3 <> FND_API.G_MISS_CHAR) then
l_attribute3 := p_attribute3;
end if;

if (p_attribute4 <> FND_API.G_MISS_CHAR) then
l_attribute4 := p_attribute4;
end if;

if (p_attribute5 <> FND_API.G_MISS_CHAR) then
l_attribute5 := p_attribute5;
end if;

if (p_attribute6 <> FND_API.G_MISS_CHAR) then
l_attribute6 := p_attribute6;
end if;

if (p_attribute7 <> FND_API.G_MISS_CHAR) then
l_attribute7:= p_attribute7;
end if;

if (p_attribute8 <> FND_API.G_MISS_CHAR) then
l_attribute8 := p_attribute8;
end if;

if (p_attribute9 <> FND_API.G_MISS_CHAR) then
l_attribute9 := p_attribute9;
end if;

if (p_attribute10 <> FND_API.G_MISS_CHAR) then
l_attribute10 := p_attribute10;
end if;

if (p_attribute11 <> FND_API.G_MISS_CHAR) then
l_attribute11 := p_attribute11;
end if;

if (p_attribute12 <> FND_API.G_MISS_CHAR) then
l_attribute12 := p_attribute12;
end if;

if (p_attribute13 <> FND_API.G_MISS_CHAR) then
l_attribute13 := p_attribute13;
end if;

if (p_attribute14 <> FND_API.G_MISS_CHAR) then
l_attribute14 := p_attribute14;
end if;

if (p_attribute15 <> FND_API.G_MISS_CHAR) then
l_attribute15 := p_attribute15;
end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;

  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;

  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;

  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;

  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

-- Create record if no validation error was found
  --  NOTE - Calling IS_UPDATEABLE for backward compatibility
  --  old jlt files didn't have who columns and IS_UPDATEABLE
  --  calls SET_WHO which populates those columns, for later
  --  jlt files IS_UPDATEABLE will always return TRUE for CREATE

if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => null,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => null,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'CREATE') then
     null;
  end if;

select userenv('LANG') into l_lang
from dual;

insert into AK_OBJECT_ATTRIBUTES (
DATABASE_OBJECT_NAME,
ATTRIBUTE_APPLICATION_ID,
ATTRIBUTE_CODE,
COLUMN_NAME,
ATTRIBUTE_LABEL_LENGTH,
DISPLAY_VALUE_LENGTH,
BOLD,
ITALIC,
VERTICAL_ALIGNMENT,
HORIZONTAL_ALIGNMENT,
DATA_SOURCE_TYPE,
DATA_STORAGE_TYPE,
TABLE_NAME,
BASE_TABLE_COLUMN_NAME,
REQUIRED_FLAG,
DEFAULT_VALUE_VARCHAR2,
DEFAULT_VALUE_NUMBER,
DEFAULT_VALUE_DATE,
LOV_REGION_APPLICATION_ID,
LOV_REGION_CODE,
LOV_FOREIGN_KEY_NAME,
LOV_ATTRIBUTE_APPLICATION_ID,
LOV_ATTRIBUTE_CODE,
DEFAULTING_API_PKG,
DEFAULTING_API_PROC,
VALIDATION_API_PKG,
VALIDATION_API_PROC,
ATTRIBUTE_CATEGORY,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
ATTRIBUTE11,
ATTRIBUTE12,
ATTRIBUTE13,
ATTRIBUTE14,
ATTRIBUTE15,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN
) values (
p_database_object_name,
p_attribute_application_id,
p_attribute_code,
l_column_name,
p_attribute_label_length,
p_display_value_length,
p_bold,
p_italic,
p_vertical_alignment,
p_horizontal_alignment,
p_data_source_type,
l_data_storage_type,
l_table_name,
l_base_table_column_name,
p_required_flag,
l_default_value_varchar2,
l_default_value_number,
l_default_value_date,
l_lov_region_appl_id,
l_lov_region_code,
l_lov_foreign_key_name,
l_lov_attribute_appl_id,
l_lov_attribute_code,
l_defaulting_api_pkg,
l_defaulting_api_proc,
l_validation_api_pkg,
l_validation_api_proc,
l_attribute_category,
l_attribute1,
l_attribute2,
l_attribute3,
l_attribute4,
l_attribute5,
l_attribute6,
l_attribute7,
l_attribute8,
l_attribute9,
l_attribute10,
l_attribute11,
l_attribute12,
l_attribute13,
l_attribute14,
l_attribute15,
l_creation_date,
l_created_by,
l_last_update_date,
l_last_updated_by,
l_last_update_login
);

--** row should exists before inserting rows for other languages **
if (NOT AK_OBJECT_PVT.ATTRIBUTE_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) ) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_INSERT_OBJECT_ATTR_FAILED');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line(G_PKG_NAME || 'Error - First insert failed');
raise FND_API.G_EXC_ERROR;
end if;

insert into AK_OBJECT_ATTRIBUTES_TL (
DATABASE_OBJECT_NAME,
ATTRIBUTE_APPLICATION_ID,
ATTRIBUTE_CODE,
LANGUAGE,
ATTRIBUTE_LABEL_LONG,
ATTRIBUTE_LABEL_SHORT,
SOURCE_LANG,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN
) select
p_database_object_name,
p_attribute_application_id,
p_attribute_code,
L.LANGUAGE_CODE,
l_attribute_label_long,
l_attribute_label_short,
decode(L.LANGUAGE_CODE, l_lang, L.LANGUAGE_CODE, l_lang),
l_created_by,
l_creation_date,
l_last_updated_by,
l_last_update_date,
l_last_update_login
from FND_LANGUAGES L
where L.INSTALLED_FLAG in ('I', 'B')
and not exists
(select NULL
from AK_OBJECT_ATTRIBUTES_TL T
where T.DATABASE_OBJECT_NAME = p_database_object_name
and   T.ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   T.ATTRIBUTE_CODE = p_attribute_code
and   T.LANGUAGE = L.LANGUAGE_CODE);

--  /** commit the insert **/
--  commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code );
FND_MSG_PUB.Add;
end if;
rollback to start_create_attribute;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('OA Key: '||p_database_object_name ||
--                     ' ' || to_char(p_attribute_application_id) ||
--					 ' ' || p_attribute_code );
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_attribute;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
--dbms_output.put_line('OA Key: '||p_database_object_name ||
--                     ' ' || to_char(p_attribute_application_id) ||
--					 ' ' || p_attribute_code );
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_attribute;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_ATTRIBUTE;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Attribute_Navigation';
l_count              number;
l_created_by         number;
l_creation_date      date;
l_dummy              number;
l_error              boolean;
l_last_update_date   date;
l_last_update_login  number;
l_last_updated_by    number;
l_attribute_category VARCHAR2(30);
l_attribute1         VARCHAR2(150);
l_attribute2         VARCHAR2(150);
l_attribute3         VARCHAR2(150);
l_attribute4         VARCHAR2(150);
l_attribute5         VARCHAR2(150);
l_attribute6         VARCHAR2(150);
l_attribute7         VARCHAR2(150);
l_attribute8         VARCHAR2(150);
l_attribute9         VARCHAR2(150);
l_attribute10        VARCHAR2(150);
l_attribute11        VARCHAR2(150);
l_attribute12        VARCHAR2(150);
l_attribute13        VARCHAR2(150);
l_attribute14        VARCHAR2(150);
l_attribute15        VARCHAR2(150);
l_return_status      varchar2(1);
begin

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

--** check that one and only one value field can be non-null **
l_count := 0;
if (p_value_varchar2 is not null) then
l_count := l_count + 1;
end if;
if (p_value_date is not null) then
l_count := l_count + 1;
end if;
if (p_value_number is not null) then
l_count := l_count + 1;
end if;
if (l_count <> 1) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_ONE_VALUE_ONLY');
FND_MSG_PUB.Add;
end if;
--  dbms_output.put_line('One and only one value field must be non-null');
raise FND_API.G_EXC_ERROR;
end if;

--** check to see if row already exists                         **
if AK_OBJECT_PVT.ATTRIBUTE_NAVIGATION_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_value_varchar2 => p_value_varchar2,
p_value_date => p_value_date,
p_value_number => p_value_number) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_NAV_EXISTS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_OBJECT_PVT.VALIDATE_ATTRIBUTE_NAVIGATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_value_varchar2 => p_value_varchar2,
p_value_date => p_value_date,
p_value_number => p_value_number,
p_to_region_appl_id => p_to_region_appl_id,
p_to_region_code => p_to_region_code,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if; -- /* if p_pass */
end if;
end if;

--** Load non-required columns if their values are given **

if (p_attribute_category <> FND_API.G_MISS_CHAR) then
l_attribute_category := p_attribute_category;
end if;

if (p_attribute1 <> FND_API.G_MISS_CHAR) then
l_attribute1 := p_attribute1;
end if;

if (p_attribute2 <> FND_API.G_MISS_CHAR) then
l_attribute2 := p_attribute2;
end if;

if (p_attribute3 <> FND_API.G_MISS_CHAR) then
l_attribute3 := p_attribute3;
end if;

if (p_attribute4 <> FND_API.G_MISS_CHAR) then
l_attribute4 := p_attribute4;
end if;

if (p_attribute5 <> FND_API.G_MISS_CHAR) then
l_attribute5 := p_attribute5;
end if;

if (p_attribute6 <> FND_API.G_MISS_CHAR) then
l_attribute6 := p_attribute6;
end if;

if (p_attribute7 <> FND_API.G_MISS_CHAR) then
l_attribute7:= p_attribute7;
end if;

if (p_attribute8 <> FND_API.G_MISS_CHAR) then
l_attribute8 := p_attribute8;
end if;

if (p_attribute9 <> FND_API.G_MISS_CHAR) then
l_attribute9 := p_attribute9;
end if;

if (p_attribute10 <> FND_API.G_MISS_CHAR) then
l_attribute10 := p_attribute10;
end if;

if (p_attribute11 <> FND_API.G_MISS_CHAR) then
l_attribute11 := p_attribute11;
end if;

if (p_attribute12 <> FND_API.G_MISS_CHAR) then
l_attribute12 := p_attribute12;
end if;

if (p_attribute13 <> FND_API.G_MISS_CHAR) then
l_attribute13 := p_attribute13;
end if;

if (p_attribute14 <> FND_API.G_MISS_CHAR) then
l_attribute14 := p_attribute14;
end if;

if (p_attribute15 <> FND_API.G_MISS_CHAR) then
l_attribute15 := p_attribute15;
end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;

  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;

  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;

  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;

  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

-- Create record if no validation error was found
  --  NOTE - Calling IS_UPDATEABLE for backward compatibility
  --  old jlt files didn't have who columns and IS_UPDATEABLE
  --  calls SET_WHO which populates those columns, for later
  --  jlt files IS_UPDATEABLE will always return TRUE for CREATE

if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => null,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => null,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'CREATE') then
     null;
  end if;

insert into AK_OBJECT_ATTRIBUTE_NAVIGATION (
DATABASE_OBJECT_NAME,
ATTRIBUTE_APPLICATION_ID,
ATTRIBUTE_CODE,
VALUE_VARCHAR2,
VALUE_DATE,
VALUE_NUMBER,
TO_REGION_APPL_ID,
TO_REGION_CODE,
ATTRIBUTE_CATEGORY,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
ATTRIBUTE11,
ATTRIBUTE12,
ATTRIBUTE13,
ATTRIBUTE14,
ATTRIBUTE15,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN
) values (
p_database_object_name,
p_attribute_application_id,
p_attribute_code,
p_value_varchar2,
p_value_date,
p_value_number,
p_to_region_appl_id,
p_to_region_code,
l_attribute_category,
l_attribute1,
l_attribute2,
l_attribute3,
l_attribute4,
l_attribute5,
l_attribute6,
l_attribute7,
l_attribute8,
l_attribute9,
l_attribute10,
l_attribute11,
l_attribute12,
l_attribute13,
l_attribute14,
l_attribute15,
l_creation_date,
l_created_by,
l_last_update_date,
l_last_updated_by,
l_last_update_login
);

--  /** commit the insert **/
--  commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_NAV_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code || ' ' ||
p_value_varchar2 ||
to_char(p_value_date) ||
to_char(p_value_number) );
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_NAV_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id)
|| ' ' || p_attribute_code || ' ' ||
p_value_varchar2 ||
to_char(p_value_date) ||
to_char(p_value_number) );
FND_MSG_PUB.Add;
end if;
rollback to start_create_navigation;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_NAV_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id)
|| ' ' || p_attribute_code || ' ' ||
p_value_varchar2 ||
to_char(p_value_date) ||
to_char(p_value_number) );
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_navigation;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_navigation;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_ATTRIBUTE_NAVIGATION;

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
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Attribute_Value';
l_created_by         number;
l_creation_date      date;
l_error              boolean;
l_key_value2         VARCHAR2(100) := null;
l_key_value3         VARCHAR2(100) := null;
l_key_value4         VARCHAR2(100) := null;
l_key_value5         VARCHAR2(100) := null;
l_key_value6         VARCHAR2(100) := null;
l_key_value7         VARCHAR2(100) := null;
l_key_value8         VARCHAR2(100) := null;
l_key_value9         VARCHAR2(100) := null;
l_key_value10        VARCHAR2(100) := null;
l_last_update_date   date;
l_last_update_login  number;
l_last_updated_by    number;
l_return_status      varchar2(1);
l_value_date         DATE := null;
l_value_number       NUMBER := null;
l_value_varchar2     VARCHAR2(240) := null;
begin

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

--** check to see if row already exists **
if  AK_OBJECT_PVT.ATTRIBUTE_VALUE_EXISTS (
p_api_version_number => 1.0,
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
p_key_value10 => p_key_value10
) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_EXISTS');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line(l_api_name || 'Error - Row already exists');
raise FND_API.G_EXC_ERROR;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_OBJECT_PVT.VALIDATE_ATTRIBUTE_VALUE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
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
p_caller => AK_ON_OBJECTS_PVT.G_CREATE
) then
-- dbms_output.put_line('validation failed');
raise FND_API.G_EXC_ERROR;
end if;
end if;

--** Load non-required columns if their values are given **
if (p_key_value2 <> FND_API.G_MISS_CHAR) then
l_key_value2 := p_key_value2;
end if;

if (p_key_value3 <> FND_API.G_MISS_CHAR) then
l_key_value3 := p_key_value3;
end if;

if (p_key_value4 <> FND_API.G_MISS_CHAR) then
l_key_value4 := p_key_value4;
end if;

if (p_key_value5 <> FND_API.G_MISS_CHAR) then
l_key_value5 := p_key_value5;
end if;

if (p_key_value6 <> FND_API.G_MISS_CHAR) then
l_key_value6 := p_key_value6;
end if;

if (p_key_value7 <> FND_API.G_MISS_CHAR) then
l_key_value7 := p_key_value7;
end if;

if (p_key_value8 <> FND_API.G_MISS_CHAR) then
l_key_value8 := p_key_value8;
end if;

if (p_key_value9 <> FND_API.G_MISS_CHAR) then
l_key_value9 := p_key_value9;
end if;

if (p_key_value10 <> FND_API.G_MISS_CHAR) then
l_key_value10 := p_key_value10;
end if;

if (p_value_varchar2 <> FND_API.G_MISS_CHAR) then
l_value_varchar2 := p_value_varchar2;
end if;

if (p_value_date <> FND_API.G_MISS_DATE) then
l_value_date := p_value_date;
end if;

if (p_value_number <> FND_API.G_MISS_NUM) then
l_value_number := p_value_number;
end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;

  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;

  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;

  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;

  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

-- Create record if no validation error was found
  --  NOTE - Calling IS_UPDATEABLE for backward compatibility
  --  old jlt files didn't have who columns and IS_UPDATEABLE
  --  calls SET_WHO which populates those columns, for later
  --  jlt files IS_UPDATEABLE will always return TRUE for CREATE

if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => null,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => null,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'CREATE') then
     null;
  end if;

insert into AK_INST_ATTRIBUTE_VALUES (
DATABASE_OBJECT_NAME,
ATTRIBUTE_APPLICATION_ID,
ATTRIBUTE_CODE,
KEY_VALUE1,
KEY_VALUE2,
KEY_VALUE3,
KEY_VALUE4,
KEY_VALUE5,
KEY_VALUE6,
KEY_VALUE7,
KEY_VALUE8,
KEY_VALUE9,
KEY_VALUE10,
VALUE_VARCHAR2,
VALUE_DATE,
VALUE_NUMBER,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN
) values (
p_database_object_name,
p_attribute_application_id,
p_attribute_code,
p_key_value1,
l_key_value2,
l_key_value3,
l_key_value4,
l_key_value5,
l_key_value6,
l_key_value7,
l_key_value8,
l_key_value9,
l_key_value10,
l_value_varchar2,
l_value_date,
l_value_number,
l_creation_date,
l_created_by,
l_last_update_date,
l_last_updated_by,
l_last_update_login
);

--  /** commit the insert **/
--  commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_CREATED');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code ||
' ' || p_key_value1 ||
' ' || l_key_value2 ||
' ' || l_key_value3 ||
' ' || l_key_value4 ||
' ' || l_key_value5 ||
' ' || l_key_value6 ||
' ' || l_key_value7 ||
' ' || l_key_value8 ||
' ' || l_key_value9 ||
' ' || l_key_value10);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code ||
' ' || p_key_value1 ||
' ' || l_key_value2 ||
' ' || l_key_value3 ||
' ' || l_key_value4 ||
' ' || l_key_value5 ||
' ' || l_key_value6 ||
' ' || l_key_value7 ||
' ' || l_key_value8 ||
' ' || l_key_value9 ||
' ' || l_key_value10);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_value;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code ||
' ' || p_key_value1 ||
' ' || l_key_value2 ||
' ' || l_key_value3 ||
' ' || l_key_value4 ||
' ' || l_key_value5 ||
' ' || l_key_value6 ||
' ' || l_key_value7 ||
' ' || l_key_value8 ||
' ' || l_key_value9 ||
' ' || l_key_value10);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_value;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_value;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_ATTRIBUTE_VALUE;

end AK_OBJECT_PVT;

/
