--------------------------------------------------------
--  DDL for Package Body AK_OBJECT2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_OBJECT2_PVT" as
/* $Header: akdvob2b.pls 120.4 2005/09/26 20:14:33 tshort ship $ */

--=======================================================
--  Procedure   WRITE_NAVIGATION_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing all attribute navigation
--              records for the given object attribute to
--              the output file. Not designed to be called
--              from outside this package.
--
--  Desc        This procedure retrieves all Attribute Navigation
--              record for the given object attribute from the
--              database, and writes them to the output file
--              in loader file format.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_database_object_name : IN required
--              p_attribute_application_id : IN required
--              p_attribute_code : IN required
--                  Key value of the Object Attribute record
--                  whose Attribute Values records are to be
--                  extracted to the loader file.
--=======================================================
procedure WRITE_NAVIGATION_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2
) is
cursor l_get_navigation_csr is
select *
from   AK_OBJECT_ATTRIBUTE_NAVIGATION
where  DATABASE_OBJECT_NAME = p_database_object_name
and    ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and    ATTRIBUTE_CODE = p_attribute_code;
l_api_name           CONSTANT varchar2(30) := 'Write_Navigation_to_buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_navigation_rec     AK_OBJECT_ATTRIBUTE_NAVIGATION%ROWTYPE;
l_return_status      varchar2(1);
begin
-- Find out where the next buffer entry to be written to
l_index := 1;

-- Retrieve all attribute values for this object attributes from the
-- database

open l_get_navigation_csr;
loop
fetch l_get_navigation_csr into l_navigation_rec;
exit when l_get_navigation_csr%notfound;
-- write this object attribute navigation record if it is valid
if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
not AK_OBJECT_PVT.VALIDATE_ATTRIBUTE_NAVIGATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_value_varchar2 => l_navigation_rec.value_varchar2,
p_value_date => l_navigation_rec.value_date,
p_value_number => l_navigation_rec.value_number,
p_to_region_appl_id => l_navigation_rec.to_region_appl_id,
p_to_region_code => l_navigation_rec.to_region_code,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD )
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_NAV_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
l_navigation_rec.value_varchar2 ||
to_char(l_navigation_rec.value_date) ||
to_char(l_navigation_rec.value_number) );
FND_MSG_PUB.Add;
close l_get_navigation_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

else
l_databuffer_tbl(l_index) := ' ';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    BEGIN ATTRIBUTE_NAVIGATION "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_navigation_rec.value_varchar2)
|| '"  "' ||
to_char(l_navigation_rec.value_date, AK_ON_OBJECTS_PUB.G_DATE_FORMAT)
|| '" "' ||
nvl(to_char(l_navigation_rec.value_number),'') || '"';
if ((l_navigation_rec.to_region_appl_id IS NOT NULL) and
(l_navigation_rec.to_region_appl_id <> FND_API.G_MISS_NUM) and
(l_navigation_rec.to_region_code IS NOT NULL) and
(l_navigation_rec.to_region_code <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      TO_REGION = "' ||
nvl(to_char(l_navigation_rec.to_region_appl_id),'')||'" "'||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_navigation_rec.to_region_code)
|| '"';
end if;
-- Flex Fields
--
if ((l_navigation_rec.attribute_category IS NOT NULL) and
(l_navigation_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE_CATEGORY = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute_category) || '"';
end if;
if ((l_navigation_rec.attribute1 IS NOT NULL) and
(l_navigation_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE1 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute1) || '"';
end if;
if ((l_navigation_rec.attribute2 IS NOT NULL) and
(l_navigation_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE2 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute2) || '"';
end if;
if ((l_navigation_rec.attribute3 IS NOT NULL) and
(l_navigation_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE3 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute3) || '"';
end if;
if ((l_navigation_rec.attribute4 IS NOT NULL) and
(l_navigation_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE4 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute4) || '"';
end if;
if ((l_navigation_rec.attribute5 IS NOT NULL) and
(l_navigation_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE5 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute5) || '"';
end if;
if ((l_navigation_rec.attribute6 IS NOT NULL) and
(l_navigation_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE6 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute6) || '"';
end if;
if ((l_navigation_rec.attribute7 IS NOT NULL) and
(l_navigation_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE7 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute7) || '"';
end if;
if ((l_navigation_rec.attribute8 IS NOT NULL) and
(l_navigation_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE8 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute8) || '"';
end if;
if ((l_navigation_rec.attribute9 IS NOT NULL) and
(l_navigation_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE9 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute9) || '"';
end if;
if ((l_navigation_rec.attribute10 IS NOT NULL) and
(l_navigation_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE10 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute10) || '"';
end if;
if ((l_navigation_rec.attribute11 IS NOT NULL) and
(l_navigation_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE11 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute11) || '"';
end if;
if ((l_navigation_rec.attribute12 IS NOT NULL) and
(l_navigation_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE12 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute12) || '"';
end if;
if ((l_navigation_rec.attribute13 IS NOT NULL) and
(l_navigation_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE13 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute13) || '"';
end if;
if ((l_navigation_rec.attribute14 IS NOT NULL) and
(l_navigation_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE14 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute14) || '"';
end if;
if ((l_navigation_rec.attribute15 IS NOT NULL) and
(l_navigation_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE15 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_navigation_rec.attribute15) || '"';
end if;
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CREATED_BY = "' ||
nvl(to_char(l_navigation_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CREATION_DATE = "' ||
to_char(l_navigation_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--l_databuffer_tbl(l_index) := '      LAST_UPDATED_BY = "' ||
--nvl(to_char(l_navigation_rec.last_updated_by),'') || '"';
l_databuffer_tbl(l_index) := '      OWNER = "' ||
FND_LOAD_UTIL.OWNER_NAME(l_navigation_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATE_DATE = "' ||
to_char(l_navigation_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_navigation_rec.last_update_login),'') || '"';

-- finish up object attribute navigation
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    END ATTRIBUTE_NAVIGATION';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';
end if; -- validation OK

end loop;
close l_get_navigation_csr;

-- write attribute navigation data to file
--   don't call write_file if there is no data to be written
if (l_databuffer_tbl.count > 0) then
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);
-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_NAV_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
l_navigation_rec.value_varchar2 ||
to_char(l_navigation_rec.value_date) ||
to_char(l_navigation_rec.value_number) );
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end WRITE_NAVIGATION_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_ATTRIBUTE_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing all object attributes
--              and their children records for the given object
--              to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure retrieves all Object Attributes
--              that belongs to the given object from the database,
--              as well as all Attribute Values and Attribute
--              Navigation records for these object attributes,
--              and writes them to the output file
--              in loader file format.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_database_object_name : IN required
--                  Key value of the Object record whose Object
--                  Attributes are to be extracted to the loader file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_ATTRIBUTE_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_nls_language             IN      VARCHAR2
) is
cursor l_get_attributes_csr is
select *
from   AK_OBJECT_ATTRIBUTES
where  DATABASE_OBJECT_NAME = p_database_object_name;
cursor l_get_attribute_tl_csr (attribute_appl_id_param number,
attribute_code_param varchar2) is
select *
from   AK_OBJECT_ATTRIBUTES_TL
where  DATABASE_OBJECT_NAME = p_database_object_name
and    ATTRIBUTE_APPLICATION_ID = attribute_appl_id_param
and    ATTRIBUTE_CODE = attribute_code_param
and    LANGUAGE = p_nls_language;
l_api_name           CONSTANT varchar2(30) := 'Write_Attribute_to_buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_attributes_rec     AK_OBJECT_ATTRIBUTES%ROWTYPE;
l_attributes_tl_rec  AK_OBJECT_ATTRIBUTES_TL%ROWTYPE;
l_return_status      varchar2(1);
begin
-- Find out where the next buffer entry to be written to
l_index := 1;

-- Retrieve object attribute and its TL information from the database

open l_get_attributes_csr;
loop
fetch l_get_attributes_csr into l_attributes_rec;
exit when l_get_attributes_csr%notfound;
open l_get_attribute_tl_csr(l_attributes_rec.attribute_application_id,
l_attributes_rec.attribute_code);
fetch l_get_attribute_tl_csr into l_attributes_tl_rec;
if l_get_attribute_tl_csr%found then
-- write this object attribute if it is validated
if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
not AK_OBJECT_PVT.VALIDATE_ATTRIBUTE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => l_attributes_rec.attribute_application_id,
p_attribute_code => l_attributes_rec.attribute_code,
p_column_name => l_attributes_rec.column_name,
p_attribute_label_length => l_attributes_rec.attribute_label_length,
p_display_value_length => l_attributes_rec.display_value_length,
p_bold => l_attributes_rec.bold,
p_italic => l_attributes_rec.italic,
p_vertical_alignment => l_attributes_rec.vertical_alignment,
p_horizontal_alignment => l_attributes_rec.horizontal_alignment,
p_data_source_type => l_attributes_rec.data_source_type,
p_data_storage_type => l_attributes_rec.data_storage_type,
p_table_name => l_attributes_rec.table_name,
p_base_table_column_name =>
l_attributes_rec.base_table_column_name,
p_required_flag => l_attributes_rec.required_flag,
p_default_value_varchar2 => l_attributes_rec.default_value_varchar2,
p_default_value_number => l_attributes_rec.default_value_number,
p_default_value_date => l_attributes_rec.default_value_date,
p_lov_region_application_id =>
l_attributes_rec.lov_region_application_id,
p_lov_region_code => l_attributes_rec.lov_region_code,
p_lov_foreign_key_name => l_attributes_rec.lov_foreign_key_name,
p_lov_attribute_application_id =>
l_attributes_rec.lov_attribute_application_id,
p_lov_attribute_code => l_attributes_rec.lov_attribute_code,
p_defaulting_api_pkg => l_attributes_rec.defaulting_api_pkg,
p_defaulting_api_proc => l_attributes_rec.defaulting_api_proc,
p_validation_api_pkg => l_attributes_rec.validation_api_pkg,
p_validation_api_proc => l_attributes_rec.validation_api_proc,
p_attribute_label_long => l_attributes_tl_rec.attribute_label_long,
p_attribute_label_short=>l_attributes_tl_rec.attribute_label_short,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(l_attributes_rec.attribute_application_id) ||
' ' || l_attributes_rec.attribute_code );
FND_MSG_PUB.Add;
end if;
close l_get_attribute_tl_csr;
close l_get_attributes_csr;
RAISE FND_API.G_EXC_ERROR;
else

l_databuffer_tbl(l_index) := ' ';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  BEGIN OBJECT_ATTRIBUTE "' ||
l_attributes_rec.attribute_application_id || '" "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_attributes_rec.attribute_code)
|| '"';
--
-- check if all non-required columns are null or not, do not write out
-- those that are null
--
if ((l_attributes_rec.column_name IS NOT NULL) and
(l_attributes_rec.column_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    COLUMN_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_attributes_rec.column_name)
|| '"';
end if;
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE_LABEL_LENGTH = "' ||
nvl(to_char(l_attributes_rec.attribute_label_length),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DISPLAY_VALUE_LENGTH = "' ||
nvl(to_char(l_attributes_rec.display_value_length),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    BOLD = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_attributes_rec.bold) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ITALIC = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_attributes_rec.italic) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    VERTICAL_ALIGNMENT = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.vertical_alignment)|| '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    HORIZONTAL_ALIGNMENT = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.horizontal_alignment)|| '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DATA_SOURCE_TYPE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.data_source_type)|| '"';
l_index := l_index + 1;
if ((l_attributes_rec.data_storage_type IS NOT NULL) and
(l_attributes_rec.data_storage_type <> FND_API.G_MISS_CHAR)) then
l_databuffer_tbl(l_index) := '    DATA_STORAGE_TYPE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.data_storage_type)|| '"';
end if;
if ((l_attributes_rec.table_name IS NOT NULL) and
(l_attributes_rec.table_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    TABLE_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.table_name)|| '"';
end if;
if ((l_attributes_rec.base_table_column_name IS NOT NULL) and
(l_attributes_rec.base_table_column_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    BASE_TABLE_COLUMN_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.base_table_column_name)|| '"';
end if;
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    REQUIRED_FLAG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.required_flag)|| '"';
if ((l_attributes_rec.default_value_varchar2 IS NOT NULL) and
(l_attributes_rec.default_value_varchar2 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DEFAULT_VALUE_VARCHAR2 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.default_value_varchar2) || '"';
end if;
if ((l_attributes_rec.default_value_number IS NOT NULL) and
(l_attributes_rec.default_value_number <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DEFAULT_VALUE_NUMBER = "' ||
nvl(to_char(l_attributes_rec.default_value_number),'') || '"';
end if;
if ((l_attributes_rec.default_value_date IS NOT NULL) and
(l_attributes_rec.default_value_date <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DEFAULT_VALUE_DATE = "' ||
to_char(l_attributes_rec.default_value_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
end if;

-- Flex Fields
--
if ((l_attributes_rec.attribute_category IS NOT NULL) and
(l_attributes_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE_CATEGORY = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute_category) || '"';
end if;
if ((l_attributes_rec.attribute1 IS NOT NULL) and
(l_attributes_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE1 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute1) || '"';
end if;
if ((l_attributes_rec.attribute2 IS NOT NULL) and
(l_attributes_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE2 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute2) || '"';
end if;
if ((l_attributes_rec.attribute3 IS NOT NULL) and
(l_attributes_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE3 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute3) || '"';
end if;
if ((l_attributes_rec.attribute4 IS NOT NULL) and
(l_attributes_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE4 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute4) || '"';
end if;
if ((l_attributes_rec.attribute5 IS NOT NULL) and
(l_attributes_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE5 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute5) || '"';
end if;
if ((l_attributes_rec.attribute6 IS NOT NULL) and
(l_attributes_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE6 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute6) || '"';
end if;
if ((l_attributes_rec.attribute7 IS NOT NULL) and
(l_attributes_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE7 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute7) || '"';
end if;
if ((l_attributes_rec.attribute8 IS NOT NULL) and
(l_attributes_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE8 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute8) || '"';
end if;
if ((l_attributes_rec.attribute9 IS NOT NULL) and
(l_attributes_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE9 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute9) || '"';
end if;
if ((l_attributes_rec.attribute10 IS NOT NULL) and
(l_attributes_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE10 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute10) || '"';
end if;
if ((l_attributes_rec.attribute11 IS NOT NULL) and
(l_attributes_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE11 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute11) || '"';
end if;
if ((l_attributes_rec.attribute12 IS NOT NULL) and
(l_attributes_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE12 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute12) || '"';
end if;
if ((l_attributes_rec.attribute13 IS NOT NULL) and
(l_attributes_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE13 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute13) || '"';
end if;
if ((l_attributes_rec.attribute14 IS NOT NULL) and
(l_attributes_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE14 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute14) || '"';
end if;
if ((l_attributes_rec.attribute15 IS NOT NULL) and
(l_attributes_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE15 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.attribute15) || '"';
end if;
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CREATED_BY = "' ||
nvl(to_char(l_attributes_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CREATION_DATE = "' ||
to_char(l_attributes_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--l_databuffer_tbl(l_index) := '    LAST_UPDATED_BY = "' ||
--nvl(to_char(l_attributes_rec.last_updated_by),'') || '"';
l_databuffer_tbl(l_index) := '    OWNER = "' ||
FND_LOAD_UTIL.OWNER_NAME(l_attributes_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LAST_UPDATE_DATE = "' ||
to_char(l_attributes_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_attributes_rec.last_update_login),'') || '"';

-- translation columns
--
if ((l_attributes_rec.lov_region_application_id IS NOT NULL) and
(l_attributes_rec.lov_region_application_id <> FND_API.G_MISS_NUM) and
(l_attributes_rec.lov_region_code IS NOT NULL) and
(l_attributes_rec.lov_region_code <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LOV_REGION = "' ||
nvl(to_char(l_attributes_rec.lov_region_application_id),'')||'" "'||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.lov_region_code)|| '"';
end if;
if ((l_attributes_rec.lov_foreign_key_name IS NOT NULL) and
(l_attributes_rec.lov_foreign_key_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LOV_FOREIGN_KEY_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.lov_foreign_key_name)|| '"';
end if;
if ((l_attributes_rec.lov_attribute_application_id IS NOT NULL) and
(l_attributes_rec.lov_attribute_application_id <> FND_API.G_MISS_NUM) and
(l_attributes_rec.lov_attribute_code IS NOT NULL) and
(l_attributes_rec.lov_attribute_code <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LOV_ATTRIBUTE = "' ||
nvl(to_char(l_attributes_rec.lov_attribute_application_id),'')||'" "'||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.lov_attribute_code)|| '"';
end if;
if ((l_attributes_rec.base_table_column_name IS NOT NULL) and
(l_attributes_rec.base_table_column_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DEFAULTING_API_PKG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.defaulting_api_pkg)|| '"';
end if;
if ((l_attributes_rec.defaulting_api_proc IS NOT NULL) and
(l_attributes_rec.defaulting_api_proc <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DEFAULTING_API_PROC = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.defaulting_api_proc)|| '"';
end if;
if ((l_attributes_rec.validation_api_pkg IS NOT NULL) and
(l_attributes_rec.validation_api_pkg <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    VALIDATION_API_PKG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.validation_api_pkg)|| '"';
end if;
if ((l_attributes_rec.validation_api_proc IS NOT NULL) and
(l_attributes_rec.validation_api_proc <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    VALIDATION_API_PROC = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_rec.validation_api_proc)|| '"';
end if;

-- TL table entries
if ((l_attributes_tl_rec.attribute_label_long IS NOT NULL) and
(l_attributes_tl_rec.attribute_label_long <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE_LABEL_LONG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_tl_rec.attribute_label_long)||'"';
end if;
if ((l_attributes_tl_rec.attribute_label_short IS NOT NULL) and
(l_attributes_tl_rec.attribute_label_short <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE_LABEL_SHORT = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_attributes_tl_rec.attribute_label_short)||'"';
end if;

-- write object attribute data to file
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);
-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_attribute_tl_csr;
close l_get_attributes_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

l_databuffer_tbl.delete;

WRITE_NAVIGATION_TO_BUFFER (
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_attribute_application_id => l_attributes_rec.attribute_application_id,
p_attribute_code => l_attributes_rec.attribute_code
);

if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_attribute_tl_csr;
close l_get_attributes_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

-- finish up object attributes
l_index := 1;
l_databuffer_tbl(l_index) := '  END OBJECT_ATTRIBUTE';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';
end if; -- validation OK

-- write object attribute ending lines to file
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);
-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_attribute_tl_csr;
close l_get_attributes_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

l_databuffer_tbl.delete;
end if; -- if TL record found
close l_get_attribute_tl_csr;

end loop;
close l_get_attributes_csr;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
' ' || to_char(l_attributes_rec.attribute_application_id) ||
' ' || l_attributes_rec.attribute_code );
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end WRITE_ATTRIBUTE_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_FOREIGN_KEY_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing all foreign key definitions
--              and their children records for the given object
--              to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure retrieves all Foriegn Key definitions
--              that belongs to the given object from the database,
--              as well as all foreign key column definitions
--              for these foreign keys, and writes them to the output file
--              in loader file format.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_database_object_name : IN required
--                  Key value of the Object record whose foreign key
--                  definitions are to be extracted to the loader file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_FOREIGN_KEY_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_nls_language             IN      VARCHAR2
) is
cursor l_get_foreign_keys_csr is
select *
from   AK_FOREIGN_KEYS
where  DATABASE_OBJECT_NAME = p_database_object_name;
cursor l_get_foreign_key_tl_csr (foreign_key_name_param varchar2) is
select *
from   AK_FOREIGN_KEYS_TL
where  FOREIGN_KEY_NAME = foreign_key_name_param
and    LANGUAGE = p_nls_language;
cursor l_get_key_columns_csr (foreign_key_name_param varchar2) is
select *
from   AK_FOREIGN_KEY_COLUMNS
where  FOREIGN_KEY_NAME = foreign_key_name_param;
l_api_name            CONSTANT varchar2(30) := 'Write_Foreign_key_to_buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index               NUMBER;
l_foreign_keys_rec    AK_FOREIGN_KEYS%ROWTYPE;
l_foreign_keys_tl_rec AK_FOREIGN_KEYS_TL%ROWTYPE;
l_key_columns_rec     AK_FOREIGN_KEY_COLUMNS%ROWTYPE;
l_return_status       varchar2(1);
begin
-- Find out where the next buffer entry to be written to
l_index := 1;

-- Retrieve foreign key and its column and TL definitions from the
-- database

open l_get_foreign_keys_csr;
loop
fetch l_get_foreign_keys_csr into l_foreign_keys_rec;
exit when l_get_foreign_keys_csr%notfound;
open l_get_foreign_key_tl_csr (l_foreign_keys_rec.foreign_key_name);
fetch l_get_foreign_key_tl_csr into l_foreign_keys_tl_rec;
if (l_get_foreign_key_tl_csr%found) then
-- write this foreign key to buffer if it is valid
if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
not AK_KEY_PVT.VALIDATE_FOREIGN_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name => l_foreign_keys_rec.foreign_key_name,
p_database_object_name => l_foreign_keys_rec.database_object_name,
p_unique_key_name => l_foreign_keys_rec.unique_key_name,
p_application_id => l_foreign_keys_rec.application_id,
p_from_to_name => l_foreign_keys_tl_rec.from_to_name,
p_from_to_description => l_foreign_keys_tl_rec.from_to_description,
p_to_from_name => l_foreign_keys_tl_rec.to_from_name,
p_to_from_description => l_foreign_keys_tl_rec.to_from_description,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD )
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', l_foreign_keys_rec.foreign_key_name);
FND_MSG_PUB.Add;
end if;
else
l_databuffer_tbl(l_index) := ' ';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  BEGIN FOREIGN_KEY "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_foreign_keys_rec.foreign_key_name)|| '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    UNIQUE_KEY_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_foreign_keys_rec.unique_key_name)|| '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    APPLICATION_ID = "' ||
nvl(to_char(l_foreign_keys_rec.application_id),'') || '"';
-- Flex Fields
--
if ((l_foreign_keys_rec.attribute_category IS NOT NULL) and
(l_foreign_keys_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE_CATEGORY = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute_category) || '"';
end if;
if ((l_foreign_keys_rec.attribute1 IS NOT NULL) and
(l_foreign_keys_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE1 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute1) || '"';
end if;
if ((l_foreign_keys_rec.attribute2 IS NOT NULL) and
(l_foreign_keys_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE2 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute2) || '"';
end if;
if ((l_foreign_keys_rec.attribute3 IS NOT NULL) and
(l_foreign_keys_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE3 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute3) || '"';
end if;
if ((l_foreign_keys_rec.attribute4 IS NOT NULL) and
(l_foreign_keys_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE4 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute4) || '"';
end if;
if ((l_foreign_keys_rec.attribute5 IS NOT NULL) and
(l_foreign_keys_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE5 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute5) || '"';
end if;
if ((l_foreign_keys_rec.attribute6 IS NOT NULL) and
(l_foreign_keys_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE6 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute6) || '"';
end if;
if ((l_foreign_keys_rec.attribute7 IS NOT NULL) and
(l_foreign_keys_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE7 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute7) || '"';
end if;
if ((l_foreign_keys_rec.attribute8 IS NOT NULL) and
(l_foreign_keys_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE8 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute8) || '"';
end if;
if ((l_foreign_keys_rec.attribute9 IS NOT NULL) and
(l_foreign_keys_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE9 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute9) || '"';
end if;
if ((l_foreign_keys_rec.attribute10 IS NOT NULL) and
(l_foreign_keys_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE10 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute10) || '"';
end if;
if ((l_foreign_keys_rec.attribute11 IS NOT NULL) and
(l_foreign_keys_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE11 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute11) || '"';
end if;
if ((l_foreign_keys_rec.attribute12 IS NOT NULL) and
(l_foreign_keys_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE12 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute12) || '"';
end if;
if ((l_foreign_keys_rec.attribute13 IS NOT NULL) and
(l_foreign_keys_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE13 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute13) || '"';
end if;
if ((l_foreign_keys_rec.attribute14 IS NOT NULL) and
(l_foreign_keys_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE14 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute14) || '"';
end if;
if ((l_foreign_keys_rec.attribute15 IS NOT NULL) and
(l_foreign_keys_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE15 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_foreign_keys_rec.attribute15) || '"';
end if;
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CREATED_BY = "' ||
nvl(to_char(l_foreign_keys_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CREATION_DATE = "' ||
to_char(l_foreign_keys_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--l_databuffer_tbl(l_index) := '    LAST_UPDATED_BY = "' ||
--nvl(to_char(l_foreign_keys_rec.last_updated_by),'') || '"';
l_databuffer_tbl(l_index) := '    OWNER = "' ||
FND_LOAD_UTIL.OWNER_NAME(l_foreign_keys_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LAST_UPDATE_DATE = "' ||
to_char(l_foreign_keys_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_foreign_keys_rec.last_update_login),'') || '"';

-- Foreign key TL info
if ((l_foreign_keys_tl_rec.from_to_name IS NOT NULL) and
(l_foreign_keys_tl_rec.from_to_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    FROM_TO_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_foreign_keys_tl_rec.from_to_name)|| '"';
end if;
if ((l_foreign_keys_tl_rec.from_to_description IS NOT NULL) and
(l_foreign_keys_tl_rec.from_to_description <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    FROM_TO_DESCRIPTION = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_foreign_keys_tl_rec.from_to_description)|| '"';
end if;
if ((l_foreign_keys_tl_rec.to_from_name IS NOT NULL) and
(l_foreign_keys_tl_rec.to_from_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    TO_FROM_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_foreign_keys_tl_rec.to_from_name)|| '"';
end if;
if ((l_foreign_keys_tl_rec.to_from_description IS NOT NULL) and
(l_foreign_keys_tl_rec.to_from_description <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    TO_FROM_DESCRIPTION = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_foreign_keys_tl_rec.to_from_description)|| '"';
end if;

-- Foreign Key columns
open l_get_key_columns_csr(l_foreign_keys_rec.foreign_key_name);
loop
fetch l_get_key_columns_csr into l_key_columns_rec;
exit when l_get_key_columns_csr%notfound;
-- Write foreign key column if it is valid
if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
not AK_KEY_PVT.VALIDATE_FOREIGN_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name => l_key_columns_rec.foreign_key_name,
p_attribute_application_id =>
l_key_columns_rec.attribute_application_id,
p_attribute_code => l_key_columns_rec.attribute_code,
p_foreign_key_sequence => l_key_columns_rec.foreign_key_sequence,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD )
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', l_key_columns_rec.foreign_key_name ||
' ' ||
to_char(l_key_columns_rec.attribute_application_id) ||
' ' || l_key_columns_rec.attribute_code);
FND_MSG_PUB.Add;
end if;
close l_get_key_columns_csr;
close l_get_foreign_key_tl_csr;
close l_get_foreign_keys_csr;
RAISE FND_API.G_EXC_ERROR;
else
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    BEGIN FOREIGN_KEY_COLUMN "' ||
nvl(to_char(l_key_columns_rec.attribute_application_id),'') ||
'" "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute_code) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      FOREIGN_KEY_SEQUENCE = "' ||
nvl(to_char(l_key_columns_rec.foreign_key_sequence),'') || '"';
-- Flex Fields
--
if ((l_key_columns_rec.attribute_category IS NOT NULL) and
(l_key_columns_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE_CATEGORY = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute_category) || '"';
end if;
if ((l_key_columns_rec.attribute1 IS NOT NULL) and
(l_key_columns_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE1 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute1) || '"';
end if;
if ((l_key_columns_rec.attribute2 IS NOT NULL) and
(l_key_columns_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE2 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute2) || '"';
end if;
if ((l_key_columns_rec.attribute3 IS NOT NULL) and
(l_key_columns_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE3 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute3) || '"';
end if;
if ((l_key_columns_rec.attribute4 IS NOT NULL) and
(l_key_columns_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE4 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute4) || '"';
end if;
if ((l_key_columns_rec.attribute5 IS NOT NULL) and
(l_key_columns_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE5 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute5) || '"';
end if;
if ((l_key_columns_rec.attribute6 IS NOT NULL) and
(l_key_columns_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE6 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute6) || '"';
end if;
if ((l_key_columns_rec.attribute7 IS NOT NULL) and
(l_key_columns_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE7 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute7) || '"';
end if;
if ((l_key_columns_rec.attribute8 IS NOT NULL) and
(l_key_columns_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE8 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute8) || '"';
end if;
if ((l_key_columns_rec.attribute9 IS NOT NULL) and
(l_key_columns_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE9 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute9) || '"';
end if;
if ((l_key_columns_rec.attribute10 IS NOT NULL) and
(l_key_columns_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE10 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute10) || '"';
end if;
if ((l_key_columns_rec.attribute11 IS NOT NULL) and
(l_key_columns_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE11 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute11) || '"';
end if;
if ((l_key_columns_rec.attribute12 IS NOT NULL) and
(l_key_columns_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE12 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute12) || '"';
end if;
if ((l_key_columns_rec.attribute13 IS NOT NULL) and
(l_key_columns_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE13 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute13) || '"';
end if;
if ((l_key_columns_rec.attribute14 IS NOT NULL) and
(l_key_columns_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE14 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute14) || '"';
end if;
if ((l_key_columns_rec.attribute15 IS NOT NULL) and
(l_key_columns_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE15 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute15) || '"';
end if;
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CREATED_BY = "' ||
nvl(to_char(l_key_columns_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CREATION_DATE = "' ||
to_char(l_key_columns_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--l_databuffer_tbl(l_index) := '      LAST_UPDATED_BY = "' ||
--nvl(to_char(l_key_columns_rec.last_updated_by),'') || '"';
l_databuffer_tbl(l_index) := '      OWNER = "' ||
FND_LOAD_UTIL.OWNER_NAME(l_key_columns_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATE_DATE = "' ||
to_char(l_key_columns_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_key_columns_rec.last_update_login),'') || '"';

l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    END FOREIGN_KEY_COLUMN';
end if; -- foreign key column validation OK
end loop;
close l_get_key_columns_csr;

-- finish up foreign key
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  END FOREIGN_KEY';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';
end if;

end if; -- foreign key validation OK

close l_get_foreign_key_tl_csr;

end loop;
close l_get_foreign_keys_csr;

-- - Write foreign key data out to the specified file
--   don't call write_file if there is no data to be written
if (l_databuffer_tbl.count > 0) then
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);
-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', l_foreign_keys_rec.foreign_key_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
if l_get_key_columns_csr%ISOPEN then
close l_get_key_columns_csr;
end if;
if l_get_foreign_key_tl_csr%ISOPEN then
close l_get_foreign_key_tl_csr;
end if;
if l_get_foreign_keys_csr%ISOPEN then
close l_get_foreign_keys_csr;
end if;
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
if l_get_key_columns_csr%ISOPEN then
close l_get_key_columns_csr;
end if;
if l_get_foreign_key_tl_csr%ISOPEN then
close l_get_foreign_key_tl_csr;
end if;
if l_get_foreign_keys_csr%ISOPEN then
close l_get_foreign_keys_csr;
end if;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
if l_get_key_columns_csr%ISOPEN then
close l_get_key_columns_csr;
end if;
if l_get_foreign_key_tl_csr%ISOPEN then
close l_get_foreign_key_tl_csr;
end if;
if l_get_foreign_keys_csr%ISOPEN then
close l_get_foreign_keys_csr;
end if;

end WRITE_FOREIGN_KEY_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_UNIQUE_KEY_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing all unique key definitions
--              and their children records for the given object
--              to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure retrieves all Unique Key definitions
--              that belongs to the given object from the database,
--              as well as all unique key column definitions
--              for these unique keys, and writes them to the output file
--              in loader file format.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_database_object_name : IN required
--                  Key value of the Object record whose unique key
--                  definitions are to be extracted to the loader file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_UNIQUE_KEY_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2
) is
cursor l_get_unique_keys_csr is
select *
from   AK_UNIQUE_KEYS
where  DATABASE_OBJECT_NAME = p_database_object_name;
cursor l_get_key_columns_csr (unique_key_name_param varchar2) is
select *
from   AK_UNIQUE_KEY_COLUMNS
where  UNIQUE_KEY_NAME = unique_key_name_param;
l_api_name           CONSTANT varchar2(30) := 'write_unique_key_to_buffer';
l_index              NUMBER;
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_unique_keys_rec   AK_UNIQUE_KEYS%ROWTYPE;
l_key_columns_rec    AK_UNIQUE_KEY_COLUMNS%ROWTYPE;
l_return_status      varchar2(1);
begin
-- Find out where the next buffer entry to be written to
l_index := 1;

-- Retrieve unique key and key columns information from the database

open l_get_unique_keys_csr;
loop
fetch l_get_unique_keys_csr into l_unique_keys_rec;
exit when l_get_unique_keys_csr%notfound;
-- write this unique key to buffer if it is valid
if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
not AK_KEY_PVT.VALIDATE_UNIQUE_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name => l_unique_keys_rec.unique_key_name,
p_database_object_name => l_unique_keys_rec.database_object_name,
p_application_id => l_unique_keys_rec.application_id,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD )
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', l_unique_keys_rec.unique_key_name);
FND_MSG_PUB.Add;
end if;
else
l_databuffer_tbl(l_index) := ' ';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  BEGIN UNIQUE_KEY "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_unique_keys_rec.unique_key_name)|| '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    APPLICATION_ID = "' ||
nvl(to_char(l_unique_keys_rec.application_id),'') || '"';
-- Flex Fields
--
if ((l_unique_keys_rec.attribute_category IS NOT NULL) and
(l_unique_keys_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE_CATEGORY = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute_category) || '"';
end if;
if ((l_unique_keys_rec.attribute1 IS NOT NULL) and
(l_unique_keys_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE1 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute1) || '"';
end if;
if ((l_unique_keys_rec.attribute2 IS NOT NULL) and
(l_unique_keys_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE2 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute2) || '"';
end if;
if ((l_unique_keys_rec.attribute3 IS NOT NULL) and
(l_unique_keys_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE3 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute3) || '"';
end if;
if ((l_unique_keys_rec.attribute4 IS NOT NULL) and
(l_unique_keys_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE4 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute4) || '"';
end if;
if ((l_unique_keys_rec.attribute5 IS NOT NULL) and
(l_unique_keys_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE5 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute5) || '"';
end if;
if ((l_unique_keys_rec.attribute6 IS NOT NULL) and
(l_unique_keys_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE6 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute6) || '"';
end if;
if ((l_unique_keys_rec.attribute7 IS NOT NULL) and
(l_unique_keys_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE7 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute7) || '"';
end if;
if ((l_unique_keys_rec.attribute8 IS NOT NULL) and
(l_unique_keys_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE8 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute8) || '"';
end if;
if ((l_unique_keys_rec.attribute9 IS NOT NULL) and
(l_unique_keys_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE9 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute9) || '"';
end if;
if ((l_unique_keys_rec.attribute10 IS NOT NULL) and
(l_unique_keys_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE10 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute10) || '"';
end if;
if ((l_unique_keys_rec.attribute11 IS NOT NULL) and
(l_unique_keys_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE11 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute11) || '"';
end if;
if ((l_unique_keys_rec.attribute12 IS NOT NULL) and
(l_unique_keys_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE12 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute12) || '"';
end if;
if ((l_unique_keys_rec.attribute13 IS NOT NULL) and
(l_unique_keys_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE13 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute13) || '"';
end if;
if ((l_unique_keys_rec.attribute14 IS NOT NULL) and
(l_unique_keys_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE14 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute14) || '"';
end if;
if ((l_unique_keys_rec.attribute15 IS NOT NULL) and
(l_unique_keys_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE15 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_unique_keys_rec.attribute15) || '"';
end if;
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CREATED_BY = "' ||
nvl(to_char(l_unique_keys_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CREATION_DATE = "' ||
to_char(l_unique_keys_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--l_databuffer_tbl(l_index) := '    LAST_UPDATED_BY = "' ||
--nvl(to_char(l_unique_keys_rec.last_updated_by),'') || '"';
l_databuffer_tbl(l_index) := '    OWNER = "' ||
FND_LOAD_UTIL.OWNER_NAME(l_unique_keys_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LAST_UPDATE_DATE = "' ||
to_char(l_unique_keys_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_unique_keys_rec.last_update_login),'') || '"';


-- Unique Key columns
open l_get_key_columns_csr(l_unique_keys_rec.unique_key_name);
loop
fetch l_get_key_columns_csr into l_key_columns_rec;
exit when l_get_key_columns_csr%notfound;
if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
not AK_KEY_PVT.VALIDATE_UNIQUE_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name => l_key_columns_rec.unique_key_name,
p_attribute_application_id =>
l_key_columns_rec.attribute_application_id,
p_attribute_code => l_key_columns_rec.attribute_code,
p_unique_key_sequence => l_key_columns_rec.unique_key_sequence,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD )
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', l_key_columns_rec.unique_key_name ||
' ' ||
to_char(l_key_columns_rec.attribute_application_id) ||
' ' || l_key_columns_rec.attribute_code);
FND_MSG_PUB.Add;
end if;
close l_get_key_columns_csr;
close l_get_unique_keys_csr;
RAISE FND_API.G_EXC_ERROR;
else
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    BEGIN UNIQUE_KEY_COLUMN "' ||
nvl(to_char(l_key_columns_rec.attribute_application_id),'') ||
'" "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute_code) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      UNIQUE_KEY_SEQUENCE = "' ||
nvl(to_char(l_key_columns_rec.unique_key_sequence),'') || '"';
-- Flex Fields
--
if ((l_key_columns_rec.attribute_category IS NOT NULL) and
(l_key_columns_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE_CATEGORY = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute_category) || '"';
end if;
if ((l_key_columns_rec.attribute1 IS NOT NULL) and
(l_key_columns_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE1 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute1) || '"';
end if;
if ((l_key_columns_rec.attribute2 IS NOT NULL) and
(l_key_columns_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE2 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute2) || '"';
end if;
if ((l_key_columns_rec.attribute3 IS NOT NULL) and
(l_key_columns_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE3 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute3) || '"';
end if;
if ((l_key_columns_rec.attribute4 IS NOT NULL) and
(l_key_columns_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE4 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute4) || '"';
end if;
if ((l_key_columns_rec.attribute5 IS NOT NULL) and
(l_key_columns_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE5 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute5) || '"';
end if;
if ((l_key_columns_rec.attribute6 IS NOT NULL) and
(l_key_columns_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE6 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute6) || '"';
end if;
if ((l_key_columns_rec.attribute7 IS NOT NULL) and
(l_key_columns_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE7 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute7) || '"';
end if;
if ((l_key_columns_rec.attribute8 IS NOT NULL) and
(l_key_columns_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE8 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute8) || '"';
end if;
if ((l_key_columns_rec.attribute9 IS NOT NULL) and
(l_key_columns_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE9 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute9) || '"';
end if;
if ((l_key_columns_rec.attribute10 IS NOT NULL) and
(l_key_columns_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE10 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute10) || '"';
end if;
if ((l_key_columns_rec.attribute11 IS NOT NULL) and
(l_key_columns_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE11 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute11) || '"';
end if;
if ((l_key_columns_rec.attribute12 IS NOT NULL) and
(l_key_columns_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE12 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute12) || '"';
end if;
if ((l_key_columns_rec.attribute13 IS NOT NULL) and
(l_key_columns_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE13 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute13) || '"';
end if;
if ((l_key_columns_rec.attribute14 IS NOT NULL) and
(l_key_columns_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE14 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute14) || '"';
end if;
if ((l_key_columns_rec.attribute15 IS NOT NULL) and
(l_key_columns_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      ATTRIBUTE15 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_key_columns_rec.attribute15) || '"';
end if;
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CREATED_BY = "' ||
nvl(to_char(l_key_columns_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CREATION_DATE = "' ||
to_char(l_key_columns_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--l_databuffer_tbl(l_index) := '      LAST_UPDATED_BY = "' ||
--nvl(to_char(l_key_columns_rec.last_updated_by),'') || '"';
l_databuffer_tbl(l_index) := '      OWNER = "' ||
FND_LOAD_UTIL.OWNER_NAME(l_key_columns_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATE_DATE = "' ||
to_char(l_key_columns_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_key_columns_rec.last_update_login),'') || '"';

l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    END UNIQUE_KEY_COLUMN';
end if; -- unique key column validation OK
end loop;
close l_get_key_columns_csr;

-- finish up unique key
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  END UNIQUE_KEY';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';
end if; -- unique key validation OK

end loop;
close l_get_unique_keys_csr;

-- - Write unique key data out to the specified file
--   don't call write_file if there is no data to be written
if (l_databuffer_tbl.count > 0) then
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);
-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', l_unique_keys_rec.unique_key_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end WRITE_UNIQUE_KEY_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given object
--              and all its children records to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure first retrieves and writes the given
--              object to the loader file. Then it calls other local
--              procedures to write all its object attributes and
--              foriegn and unique key definitions to the same output
--              file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_database_object_name : IN required
--                  Key value of the Object to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_nls_language             IN      VARCHAR2
) is
cursor l_get_object_csr is
select *
from AK_OBJECTS
where DATABASE_OBJECT_NAME = p_database_object_name;
cursor l_get_object_tl_csr is
select *
from AK_OBJECTS_TL
where database_object_name = p_database_object_name
and   language = p_nls_language;
l_api_name           CONSTANT varchar2(30) := 'Write_to_buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_objects_rec        AK_OBJECTS%ROWTYPE;
l_objects_tl_rec     AK_OBJECTS_TL%ROWTYPE;
l_return_status      varchar2(1);
begin
-- Retrieve object information from the database

open l_get_object_csr;
fetch l_get_object_csr into l_objects_rec;
if (l_get_object_csr%notfound) then
close l_get_object_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Cannot find object '||p_database_object_name);
RAISE FND_API.G_EXC_ERROR;
end if;
close l_get_object_csr;

open l_get_object_tl_csr;
fetch l_get_object_tl_csr into l_objects_tl_rec;
if (l_get_object_tl_csr%notfound) then
close l_get_object_tl_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Cannot find object in ak_objects_tl '||p_database_object_name);
RAISE FND_API.G_EXC_ERROR;
end if;
close l_get_object_tl_csr;

-- Object must be validated before it is written to the file
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_OBJECT_PVT.VALIDATE_OBJECT (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_name => l_objects_tl_rec.name,
p_description => l_objects_tl_rec.description,
p_application_id => l_objects_rec.application_id,
p_primary_key_name => l_objects_rec.primary_key_name,
p_defaulting_api_pkg => l_objects_rec.defaulting_api_pkg,
p_defaulting_api_proc => l_objects_rec.defaulting_api_proc,
p_validation_api_pkg => l_objects_rec.validation_api_pkg,
p_validation_api_proc => l_objects_rec.validation_api_proc,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name);
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Object ' || p_database_object_name
--			|| ' not downloaded due to validation error');
--raise FND_API.G_EXC_ERROR;
end if;
end if;

-- Write object into buffer
l_index := 1;

l_databuffer_tbl(l_index) := 'BEGIN OBJECT "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_objects_rec.database_object_name) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  APPLICATION_ID = "' ||
nvl(to_char(l_objects_rec.application_id),'') || '"';
if ((l_objects_rec.primary_key_name IS NOT NULL) and
(l_objects_rec.primary_key_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  PRIMARY_KEY_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_objects_rec.primary_key_name) ||
'"';
end if;
if ((l_objects_rec.defaulting_api_pkg IS NOT NULL) and
(l_objects_rec.defaulting_api_pkg <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  DEFAULTING_API_PKG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_objects_rec.defaulting_api_pkg)
|| '"';
end if;
if ((l_objects_rec.defaulting_api_proc IS NOT NULL) and
(l_objects_rec.defaulting_api_proc <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  DEFAULTING_API_PROC = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_objects_rec.defaulting_api_proc)
|| '"';
end if;
if ((l_objects_rec.validation_api_pkg IS NOT NULL) and
(l_objects_rec.validation_api_pkg <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  VALIDATION_API_PKG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_objects_rec.validation_api_pkg)
|| '"';
end if;
if ((l_objects_rec.validation_api_proc IS NOT NULL) and
(l_objects_rec.validation_api_proc <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  VALIDATION_API_PROC = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_objects_rec.validation_api_proc)
|| '"';
end if;
-- Flex Fields
--
if ((l_objects_rec.attribute_category IS NOT NULL) and
(l_objects_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE_CATEGORY = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute_category) || '"';
end if;
if ((l_objects_rec.attribute1 IS NOT NULL) and
(l_objects_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE1 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute1) || '"';
end if;
if ((l_objects_rec.attribute2 IS NOT NULL) and
(l_objects_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE2 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute2) || '"';
end if;
if ((l_objects_rec.attribute3 IS NOT NULL) and
(l_objects_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE3 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute3) || '"';
end if;
if ((l_objects_rec.attribute4 IS NOT NULL) and
(l_objects_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE4 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute4) || '"';
end if;
if ((l_objects_rec.attribute5 IS NOT NULL) and
(l_objects_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE5 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute5) || '"';
end if;
if ((l_objects_rec.attribute6 IS NOT NULL) and
(l_objects_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE6 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute6) || '"';
end if;
if ((l_objects_rec.attribute7 IS NOT NULL) and
(l_objects_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE7 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute7) || '"';
end if;
if ((l_objects_rec.attribute8 IS NOT NULL) and
(l_objects_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE8 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute8) || '"';
end if;
if ((l_objects_rec.attribute9 IS NOT NULL) and
(l_objects_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE9 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute9) || '"';
end if;
if ((l_objects_rec.attribute10 IS NOT NULL) and
(l_objects_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE10 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute10) || '"';
end if;
if ((l_objects_rec.attribute11 IS NOT NULL) and
(l_objects_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE11 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute11) || '"';
end if;
if ((l_objects_rec.attribute12 IS NOT NULL) and
(l_objects_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE12 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute12) || '"';
end if;
if ((l_objects_rec.attribute13 IS NOT NULL) and
(l_objects_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE13 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute13) || '"';
end if;
if ((l_objects_rec.attribute14 IS NOT NULL) and
(l_objects_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE14 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute14) || '"';
end if;
if ((l_objects_rec.attribute15 IS NOT NULL) and
(l_objects_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE15 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_objects_rec.attribute15) || '"';
end if;
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  CREATED_BY = "' ||
nvl(to_char(l_objects_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  CREATION_DATE = "' ||
to_char(l_objects_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--l_databuffer_tbl(l_index) := '  LAST_UPDATED_BY = "' ||
--nvl(to_char(l_objects_rec.last_updated_by),'') || '"';
l_databuffer_tbl(l_index) := '  OWNER  = "' ||
FND_LOAD_UTIL.OWNER_NAME(l_objects_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  LAST_UPDATE_DATE = "' ||
to_char(l_objects_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_objects_rec.last_update_login),'') || '"';

-- translation columns
--
if ((l_objects_tl_rec.name IS NOT NULL) and
(l_objects_tl_rec.name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_objects_tl_rec.name) || '"';
end if;
if ((l_objects_tl_rec.description IS NOT NULL) and
(l_objects_tl_rec.description <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  DESCRIPTION = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_objects_tl_rec.description) ||
'"';
end if;

-- - Write object data out to the specified file
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);
-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

l_databuffer_tbl.delete;

WRITE_ATTRIBUTE_TO_BUFFER (
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_nls_language => p_nls_language
);
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

WRITE_UNIQUE_KEY_TO_BUFFER (
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name
);
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

WRITE_FOREIGN_KEY_TO_BUFFER (
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name,
p_nls_language => p_nls_language
);
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

l_index := 1;
l_databuffer_tbl(l_index) := 'END OBJECT';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';

-- - Finish up writing object data out to the specified file
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end WRITE_TO_BUFFER;

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
--              p_nls_language : IN optional
--                  NLS language for database. If none if given,
--                  the current NLS language will be used.
--              p_get_region_flag : IN required
--                  Call DOWNLOAD_REGION API to extract regions that
--                  are referencing the objects that will be extracted
--                  by this API if this parameter is 'Y'.
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
p_return_status            OUT NOCOPY     VARCHAR2,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_object_pk_tbl            IN      AK_OBJECT_PUB.Object_PK_Tbl_Type
:= AK_OBJECT_PUB.G_MISS_OBJECT_PK_TBL,
p_attribute_pk_tbl         IN      AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type
:= AK_ATTRIBUTE_PUB.G_MISS_ATTRIBUTE_PK_TBL,
p_nls_language             IN      VARCHAR2,
p_get_region_flag          IN      VARCHAR2
) is
cursor l_get_object_list_csr (appl_id_parm number) is
select database_object_name
from AK_OBJECTS
where APPLICATION_ID = appl_id_parm;
cursor l_get_regions_csr (database_object_name_param varchar2) is
select REGION_APPLICATION_ID, REGION_CODE
from   AK_REGIONS
where  DATABASE_OBJECT_NAME = database_object_name_param;
cursor l_get_attributes_csr (database_object_name_param varchar2) is
select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
from   AK_OBJECT_ATTRIBUTES
where  DATABASE_OBJECT_NAME = database_object_name_param;
cursor l_get_region_items_csr (region_appl_id_param number,
region_code_param varchar2) is
select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
from   AK_REGION_ITEMS
where  REGION_APPLICATION_ID = region_appl_id_param
and    REGION_CODE = region_code_param;
cursor l_get_fk_objects_csr (database_object_name_param varchar2) is
select uk.DATABASE_OBJECT_NAME
from   AK_UNIQUE_KEYS uk, AK_FOREIGN_KEYS fk
where  uk.UNIQUE_KEY_NAME = fk.UNIQUE_KEY_NAME
and    fk.DATABASE_OBJECT_NAME = database_object_name_param;
cursor l_get_attr_lov_regions_csr (database_object_name_param varchar2) is
select aa.lov_region_application_id, aa.lov_region_code
from   ak_attributes aa, ak_object_attributes aoa
where  aa.attribute_application_id = aoa.attribute_application_id
and    aa.attribute_code = aoa.attribute_code
and    aoa.database_object_name = database_object_name_param
and    aa.lov_region_code is not null;
cursor l_get_objattr_lov_regions_csr (database_object_name_param varchar2) is
select lov_region_application_id, lov_region_code
from   ak_object_attributes
where  database_object_name = database_object_name_param
and    lov_region_code is not null;
cursor l_get_region_lov_regions_csr (region_appl_id_param number,
region_code_param varchar2) is
select lov_region_application_id, lov_region_code
from   AK_REGION_ITEMS
where  REGION_APPLICATION_ID = region_appl_id_param
and    REGION_CODE = region_code_param
and    lov_region_code is not null;
cursor l_get_region_object_csr (region_appl_id_param number,
region_code_param varchar2) is
select database_object_name
from   AK_REGIONS
where  REGION_APPLICATION_ID = region_appl_id_param
and    REGION_CODE = region_code_param;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Download_Object';
l_attribute_appl_id  NUMBER;
l_attribute_code     VARCHAR2(30);
l_attribute_pk_tbl   AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type;
l_database_object_name VARCHAR2(30);
l_index              NUMBER;
l_last_orig_index    NUMBER;
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_object_pk_tbl      AK_OBJECT_PUB.Object_PK_Tbl_Type;
l_region_appl_id     NUMBER;
l_region_code        VARCHAR2(30);
l_region_index       NUMBER;
l_region_tbl_last    NUMBER;
l_region_pk_tbl      AK_REGION_PUB.Region_PK_Tbl_Type;
l_return_status      varchar2(1);
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
-- dbms_output.put_line('API error in AK_OBJECTS2_PVT');
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Check that one of the following selection criteria is given:
-- - p_application_id alone, or
-- - object names in p_object_PK_tbl

if (p_application_id = FND_API.G_MISS_NUM) or (p_application_id is null) then
if (p_object_PK_tbl.count = 0) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_NO_SELECTION');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
else
if (p_object_PK_tbl.count > 0) then
-- both application ID and a list of objects to be extracted are
-- given, issue a warning that we will ignore the application ID
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_APPL_ID_IGNORED');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- If selecting by application ID, first load a object unique key table
-- with the unique key of all objects for the given application ID.
-- If selecting by a list of objects, simply copy the object unique key
-- table with the parameter
if (p_object_PK_tbl.count > 0) then
l_object_pk_tbl := p_object_pk_tbl;
else
l_index := 1;
open l_get_object_list_csr(p_application_id);
loop
fetch l_get_object_list_csr into l_object_pk_tbl(l_index);
exit when l_get_object_list_csr%notfound;
l_index := l_index + 1;
end loop;
close l_get_object_list_csr;
end if;

-- Save the index of the last entry in the table. This marks the
-- last object in the selection criteria.
l_last_orig_index := l_object_pk_tbl.LAST;
--dbms_output.put_line('l_last_orig_index is :' || to_char(l_last_orig_index));

-- Initialize region table index
l_region_index := 1;

-- Initialize attribute table with parameter
l_attribute_pk_tbl := p_attribute_pk_tbl;

-- Build list of regions and attributes that are needed by the
-- list of objects that we are about to extract from the database.
-- Also add additional objects that are referenced by any foreign
-- keys to the object list to be extracted.
--
l_index := l_object_pk_tbl.FIRST;

while (l_index is not null) loop
--
-- if the download region flag is 'Y':
--
if (p_get_region_flag = 'Y') then
--
-- Remember the last element in the region table. This will
-- be used to determine which regions are added to the table
-- in this pass of the loop.
--
l_region_tbl_last := l_region_pk_tbl.last;
--
-- Add regions that refrences this object to the region list
--
open l_get_regions_csr(l_object_pk_tbl(l_index));
loop
fetch l_get_regions_csr into l_region_appl_id, l_region_code;
exit when (l_get_regions_csr%notfound);
AK_REGION_PVT.INSERT_REGION_PK_TABLE (
p_return_status => l_return_status,
p_region_application_id => l_region_appl_id,
p_region_code => l_region_code,
p_region_pk_tbl => l_region_pk_tbl);
end loop;
close l_get_regions_csr;
--
-- Add LOV Regions that are referenced by any object attribute
-- or attribute that belongs to the current object.
--
open l_get_attr_lov_regions_csr(l_object_pk_tbl(l_index));
loop
fetch l_get_attr_lov_regions_csr into l_region_appl_id, l_region_code;
exit when (l_get_attr_lov_regions_csr%notfound);
AK_REGION_PVT.INSERT_REGION_PK_TABLE (
p_return_status => l_return_status,
p_region_application_id => l_region_appl_id,
p_region_code => l_region_code,
p_region_pk_tbl => l_region_pk_tbl);
end loop;
close l_get_attr_lov_regions_csr;

open l_get_objattr_lov_regions_csr(l_object_pk_tbl(l_index));
loop
fetch l_get_objattr_lov_regions_csr into l_region_appl_id,l_region_code;
exit when (l_get_objattr_lov_regions_csr%notfound);
AK_REGION_PVT.INSERT_REGION_PK_TABLE (
p_return_status => l_return_status,
p_region_application_id => l_region_appl_id,
p_region_code => l_region_code,
p_region_pk_tbl => l_region_pk_tbl);
end loop;
close l_get_objattr_lov_regions_csr;

--
-- For each new region or LOV region added:
--
l_region_index := l_region_pk_tbl.next(l_region_tbl_last);
while (l_region_index is not null) loop
--
-- 1. If there is any LOV region referenced by some of its
--    region item, add these LOV regions to the region list
--
open l_get_region_lov_regions_csr(
l_region_pk_tbl(l_region_index).region_appl_id,
l_region_pk_tbl(l_region_index).region_code);
loop
fetch l_get_region_lov_regions_csr into l_region_appl_id,
l_region_code;
exit when (l_get_region_lov_regions_csr%notfound);
AK_REGION_PVT.INSERT_REGION_PK_TABLE (
p_return_status => l_return_status,
p_region_application_id => l_region_appl_id,
p_region_code => l_region_code,
p_region_pk_tbl => l_region_pk_tbl);
end loop;
close l_get_region_lov_regions_csr;
--
-- 2. Build a list of attributes that we need to extract
--    because they are referenced by some region items in this
--    region.
--
if (AK_DOWNLOAD_GRP.G_DOWNLOAD_ATTR = 'Y') then
open l_get_region_items_csr (
l_region_pk_tbl(l_region_index).region_appl_id,
l_region_pk_tbl(l_region_index).region_code);
loop
fetch l_get_region_items_csr into l_attribute_appl_id,
l_attribute_code;
exit when (l_get_region_items_csr%notfound);
AK_ATTRIBUTE_PVT.INSERT_ATTRIBUTE_PK_TABLE (
p_return_status => l_return_status,
p_attribute_application_id => l_attribute_appl_id,
p_attribute_code => l_attribute_code,
p_attribute_pk_tbl => l_attribute_pk_tbl);
end loop;
close l_get_region_items_csr;
end if;
--
-- 3. Finally, add the object referenced by this region to
--    the object list so that the object will also be downloded.
--
open l_get_region_object_csr (
l_region_pk_tbl(l_region_index).region_appl_id,
l_region_pk_tbl(l_region_index).region_code);
loop
fetch l_get_region_object_csr into l_database_object_name;
exit when (l_get_region_object_csr%notfound);
AK_OBJECT_PVT.INSERT_OBJECT_PK_TABLE (
p_return_status => l_return_status,
p_database_object_name => l_database_object_name,
p_object_pk_tbl => l_object_pk_tbl);
end loop;
close l_get_region_object_csr;
--
-- 4. Increment index counter for processing of the next new
--    region.
l_region_index := l_region_pk_tbl.next(l_region_index);

end loop; /* while l_region_index is not null */
end if; /* p_get_region_flag = 'Y' */

-- Build list of attributes that are referenced in object attributes
-- for this object.
if (AK_DOWNLOAD_GRP.G_DOWNLOAD_ATTR = 'Y') then
open l_get_attributes_csr (l_object_pk_tbl(l_index));
loop
fetch l_get_attributes_csr into l_attribute_appl_id, l_attribute_code;
exit when (l_get_attributes_csr%notfound);
AK_ATTRIBUTE_PVT.INSERT_ATTRIBUTE_PK_TABLE (
p_return_status => l_return_status,
p_attribute_application_id => l_attribute_appl_id,
p_attribute_code => l_attribute_code,
p_attribute_pk_tbl => l_attribute_pk_tbl);
end loop;
close l_get_attributes_csr;
end if;

-- Add objects that contain unique keys which were referenced by
-- any of the foreign keys of the object currently being downloaded
open l_get_fk_objects_csr (l_object_pk_tbl(l_index));
loop
fetch l_get_fk_objects_csr into l_database_object_name;
exit when (l_get_fk_objects_csr%notfound);
AK_OBJECT_PVT.INSERT_OBJECT_PK_TABLE (
p_return_status => l_return_status,
p_database_object_name => l_database_object_name,
p_object_pk_tbl => l_object_pk_tbl);
end loop;
close l_get_fk_objects_csr;

-- Ready to download the next object in the list
l_index := l_object_pk_tbl.NEXT(l_index);

end loop; /* while l_index is not null */

-- set l_index to the last index number in the object table
-- l_index := l_object_pk_tbl.LAST;

-- Download attributes that are in the attribute list.
-- These are attributes that needs to be extracted since they were
-- referenced by the object attributes or region items that were
-- being extracted from the database.

if (AK_DOWNLOAD_GRP.G_DOWNLOAD_ATTR = 'Y') then
if (l_attribute_pk_tbl.count > 0) then
AK_ATTRIBUTE_PVT.DOWNLOAD_ATTRIBUTE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_attribute_pk_tbl => l_attribute_pk_tbl,
p_nls_language => p_nls_language
);


if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
-- dbms_output.put_line(l_api_name || ' Error downloading attributes');
raise FND_API.G_EXC_ERROR;
end if;

end if;
end if;

if (AK_DOWNLOAD_GRP.G_DOWNLOAD_REG = 'Y') then
-- Write details for each selected object, including its object
-- attributes, unique and foreign key definitions, etc. to a
-- buffer to be passed back to the calling procedure.
--
l_index := l_object_pk_tbl.FIRST;

while (l_index is not null) loop
-- Write object information from the database

--dbms_output.put_line('writing object #'||to_char(l_index) || ':' ||
--                      l_object_pk_tbl(l_index));

WRITE_TO_BUFFER(
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_database_object_name => l_object_pk_tbl(l_index),
p_nls_language => p_nls_language
);
-- Download aborts if any of the validation fails
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

-- Ready to download the next object in the list
l_index := l_object_pk_tbl.NEXT(l_index);

end loop;
end if; /*G_DOWNLOAD_REG*/

-- Download region information for regions that were based on any
-- of the extracted objects.

/*
for l_region_index in l_region_pk_tbl.FIRST .. l_region_pk_tbl.LAST LOOP
if l_region_pk_tbl.exists(l_region_index) then
-- dbms_output.put_line('Region list #' || to_char(l_region_index) || ' ' ||
--                    l_region_pk_tbl(l_region_index).region_code);
end if;
end loop;
*/

if (l_region_pk_tbl.count > 0) then
AK_REGION_PVT.DOWNLOAD_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_pk_tbl => l_region_pk_tbl,
p_nls_language => p_nls_language,
p_get_object_flag => 'N'    -- No need to get objects for regions
);
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

-- dbms_output.put_line('returning from ak_object_pvt.download_object: ' ||
--                        to_char(sysdate, 'MON-DD HH24:MI:SS'));

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_PK_VALUE_ERROR');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Value error occurred in download- check your object list.');
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
end DOWNLOAD_OBJECT;

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
p_return_status            OUT NOCOPY     VARCHAR2,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER := 2
) is
l_api_name                 CONSTANT varchar2(30) := 'Upload_Object_Second';
l_rec_index                NUMBER;
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(240);
l_copy_redo_flag           BOOLEAN := FALSE;
begin
--
-- Insert or update all objects to the database
--
if (G_OBJECT_REDO_INDEX > 0) then
for l_index in G_OBJECT_REDO_TBL.FIRST .. G_OBJECT_REDO_TBL.LAST loop
if (G_OBJECT_REDO_TBL.exists(l_index)) then
if AK_OBJECT_PVT.OBJECT_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name =>
G_OBJECT_REDO_TBL(l_index).database_object_name) then
AK_OBJECT3_PVT.UPDATE_OBJECT (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_database_object_name =>
G_OBJECT_REDO_TBL(l_index).database_object_name,
p_name => G_OBJECT_REDO_TBL(l_index).name,
p_description => G_OBJECT_REDO_TBL(l_index).description,
p_application_id => G_OBJECT_REDO_TBL(l_index).application_id,
p_primary_key_name => G_OBJECT_REDO_TBL(l_index).primary_key_name,
p_defaulting_api_pkg => G_OBJECT_REDO_TBL(l_index).defaulting_api_pkg,
p_defaulting_api_proc => G_OBJECT_REDO_TBL(l_index).defaulting_api_proc,
p_validation_api_pkg => G_OBJECT_REDO_TBL(l_index).validation_api_pkg,
p_validation_api_proc => G_OBJECT_REDO_TBL(l_index).validation_api_proc,
p_attribute_category => G_OBJECT_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_OBJECT_REDO_TBL(l_index).attribute1,
p_attribute2 => G_OBJECT_REDO_TBL(l_index).attribute2,
p_attribute3 => G_OBJECT_REDO_TBL(l_index).attribute3,
p_attribute4 => G_OBJECT_REDO_TBL(l_index).attribute4,
p_attribute5 => G_OBJECT_REDO_TBL(l_index).attribute5,
p_attribute6 => G_OBJECT_REDO_TBL(l_index).attribute6,
p_attribute7 => G_OBJECT_REDO_TBL(l_index).attribute7,
p_attribute8 => G_OBJECT_REDO_TBL(l_index).attribute8,
p_attribute9 => G_OBJECT_REDO_TBL(l_index).attribute9,
p_attribute10 => G_OBJECT_REDO_TBL(l_index).attribute10,
p_attribute11 => G_OBJECT_REDO_TBL(l_index).attribute11,
p_attribute12 => G_OBJECT_REDO_TBL(l_index).attribute12,
p_attribute13 => G_OBJECT_REDO_TBL(l_index).attribute13,
p_attribute14 => G_OBJECT_REDO_TBL(l_index).attribute14,
p_attribute15 => G_OBJECT_REDO_TBL(l_index).attribute15,
p_created_by => G_OBJECT_REDO_TBL(l_index).created_by,
p_creation_date => G_OBJECT_REDO_TBL(l_index).creation_date,
p_last_updated_by => G_OBJECT_REDO_TBL(l_index).last_updated_by,
p_last_update_date => G_OBJECT_REDO_TBL(l_index).last_update_date,
p_last_update_login => G_OBJECT_REDO_TBL(l_index).last_update_login,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
else
AK_OBJECT_PVT.CREATE_OBJECT (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_database_object_name =>
G_OBJECT_REDO_TBL(l_index).database_object_name,
p_name => G_OBJECT_REDO_TBL(l_index).name,
p_description => G_OBJECT_REDO_TBL(l_index).description,
p_application_id => G_OBJECT_REDO_TBL(l_index).application_id,
p_primary_key_name => G_OBJECT_REDO_TBL(l_index).primary_key_name,
p_defaulting_api_pkg => G_OBJECT_REDO_TBL(l_index).defaulting_api_pkg,
p_defaulting_api_proc => G_OBJECT_REDO_TBL(l_index).defaulting_api_proc,
p_validation_api_pkg => G_OBJECT_REDO_TBL(l_index).validation_api_pkg,
p_validation_api_proc => G_OBJECT_REDO_TBL(l_index).validation_api_proc,
p_attribute_category => G_OBJECT_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_OBJECT_REDO_TBL(l_index).attribute1,
p_attribute2 => G_OBJECT_REDO_TBL(l_index).attribute2,
p_attribute3 => G_OBJECT_REDO_TBL(l_index).attribute3,
p_attribute4 => G_OBJECT_REDO_TBL(l_index).attribute4,
p_attribute5 => G_OBJECT_REDO_TBL(l_index).attribute5,
p_attribute6 => G_OBJECT_REDO_TBL(l_index).attribute6,
p_attribute7 => G_OBJECT_REDO_TBL(l_index).attribute7,
p_attribute8 => G_OBJECT_REDO_TBL(l_index).attribute8,
p_attribute9 => G_OBJECT_REDO_TBL(l_index).attribute9,
p_attribute10 => G_OBJECT_REDO_TBL(l_index).attribute10,
p_attribute11 => G_OBJECT_REDO_TBL(l_index).attribute11,
p_attribute12 => G_OBJECT_REDO_TBL(l_index).attribute12,
p_attribute13 => G_OBJECT_REDO_TBL(l_index).attribute13,
p_attribute14 => G_OBJECT_REDO_TBL(l_index).attribute14,
p_attribute15 => G_OBJECT_REDO_TBL(l_index).attribute15,
p_created_by => G_OBJECT_REDO_TBL(l_index).created_by,
p_creation_date => G_OBJECT_REDO_TBL(l_index).creation_date,
p_last_updated_by => G_OBJECT_REDO_TBL(l_index).last_updated_by,
p_last_update_date => G_OBJECT_REDO_TBL(l_index).last_update_date,
p_last_update_login => G_OBJECT_REDO_TBL(l_index).last_update_login,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
end if; -- /* if OBJECT_EXISTS */
--
-- If API call returns with an error status, upload aborts
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
-- dbms_output.put_line('Object key = '||G_OBJECT_REDO_TBL(l_index).database_object_name);
RAISE FND_API.G_EXC_ERROR;
end if; -- /* if l_return_status */
end if;
end loop; -- /* for loop */
end if;

--
-- Insert or update all object attributes to the database
--
if (G_OBJECT_ATTR_REDO_INDEX > 0) then
for l_index in G_OBJECT_ATTR_REDO_TBL.FIRST .. G_OBJECT_ATTR_REDO_TBL.LAST loop
if (G_OBJECT_ATTR_REDO_TBL.exists(l_index)) then
if AK_OBJECT_PVT.ATTRIBUTE_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name =>
G_OBJECT_ATTR_REDO_TBL(l_index).database_object_name,
p_attribute_application_id =>
G_OBJECT_ATTR_REDO_TBL(l_index).attribute_appl_id,
p_attribute_code =>
G_OBJECT_ATTR_REDO_TBL(l_index).attribute_code) then
AK_OBJECT3_PVT.UPDATE_ATTRIBUTE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_database_object_name =>
G_OBJECT_ATTR_REDO_TBL(l_index).database_object_name,
p_attribute_application_id =>
G_OBJECT_ATTR_REDO_TBL(l_index).attribute_appl_id,
p_attribute_code => G_OBJECT_ATTR_REDO_TBL(l_index).attribute_code,
p_column_name => G_OBJECT_ATTR_REDO_TBL(l_index).column_name,
p_attribute_label_length =>
G_OBJECT_ATTR_REDO_TBL(l_index).attribute_label_length,
p_display_value_length =>
G_OBJECT_ATTR_REDO_TBL(l_index).display_value_length,
p_bold => G_OBJECT_ATTR_REDO_TBL(l_index).bold,
p_italic => G_OBJECT_ATTR_REDO_TBL(l_index).italic,
p_vertical_alignment =>
G_OBJECT_ATTR_REDO_TBL(l_index).vertical_alignment,
p_horizontal_alignment =>
G_OBJECT_ATTR_REDO_TBL(l_index).horizontal_alignment,
p_data_source_type => G_OBJECT_ATTR_REDO_TBL(l_index).data_source_type,
p_data_storage_type => G_OBJECT_ATTR_REDO_TBL(l_index).data_storage_type,
p_table_name => G_OBJECT_ATTR_REDO_TBL(l_index).table_name,
p_base_table_column_name =>
G_OBJECT_ATTR_REDO_TBL(l_index).base_table_column_name,
p_required_flag => G_OBJECT_ATTR_REDO_TBL(l_index).required_flag,
p_default_value_varchar2 =>
G_OBJECT_ATTR_REDO_TBL(l_index).default_value_varchar2,
p_default_value_number =>
G_OBJECT_ATTR_REDO_TBL(l_index).default_value_number,
p_default_value_date =>
G_OBJECT_ATTR_REDO_TBL(l_index).default_value_date,
p_lov_region_application_id =>
G_OBJECT_ATTR_REDO_TBL(l_index).lov_region_application_id,
p_lov_region_code => G_OBJECT_ATTR_REDO_TBL(l_index).lov_region_code,
p_lov_foreign_key_name =>
G_OBJECT_ATTR_REDO_TBL(l_index).lov_foreign_key_name,
p_lov_attribute_application_id =>
G_OBJECT_ATTR_REDO_TBL(l_index).lov_attribute_application_id,
p_lov_attribute_code =>
G_OBJECT_ATTR_REDO_TBL(l_index).lov_attribute_code,
p_defaulting_api_pkg =>
G_OBJECT_ATTR_REDO_TBL(l_index).defaulting_api_pkg,
p_defaulting_api_proc =>
G_OBJECT_ATTR_REDO_TBL(l_index).defaulting_api_proc,
p_validation_api_pkg =>G_OBJECT_ATTR_REDO_TBL(l_index).validation_api_pkg,
p_validation_api_proc =>
G_OBJECT_ATTR_REDO_TBL(l_index).validation_api_proc,
p_attribute_category => G_OBJECT_ATTR_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute1,
p_attribute2 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute2,
p_attribute3 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute3,
p_attribute4 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute4,
p_attribute5 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute5,
p_attribute6 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute6,
p_attribute7 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute7,
p_attribute8 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute8,
p_attribute9 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute9,
p_attribute10 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute10,
p_attribute11 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute11,
p_attribute12 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute12,
p_attribute13 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute13,
p_attribute14 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute14,
p_attribute15 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute15,
p_attribute_label_long =>
G_OBJECT_ATTR_REDO_TBL(l_index).attribute_label_long,
p_attribute_label_short =>
G_OBJECT_ATTR_REDO_TBL(l_index).attribute_label_short,
p_created_by => G_OBJECT_ATTR_REDO_TBL(l_index).created_by,
p_creation_date => G_OBJECT_ATTR_REDO_TBL(l_index).creation_date,
p_last_updated_by => G_OBJECT_ATTR_REDO_TBL(l_index).last_updated_by,
p_last_update_date => G_OBJECT_ATTR_REDO_TBL(l_index).last_update_date,
p_last_update_login => G_OBJECT_ATTR_REDO_TBL(l_index).last_update_login,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
else
AK_OBJECT_PVT.CREATE_ATTRIBUTE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_database_object_name =>
G_OBJECT_ATTR_REDO_TBL(l_index).database_object_name,
p_attribute_application_id =>
G_OBJECT_ATTR_REDO_TBL(l_index).attribute_appl_id,
p_attribute_code => G_OBJECT_ATTR_REDO_TBL(l_index).attribute_code,
p_column_name => G_OBJECT_ATTR_REDO_TBL(l_index).column_name,
p_attribute_label_length =>
G_OBJECT_ATTR_REDO_TBL(l_index).attribute_label_length,
p_display_value_length =>
G_OBJECT_ATTR_REDO_TBL(l_index).display_value_length,
p_bold => G_OBJECT_ATTR_REDO_TBL(l_index).bold,
p_italic => G_OBJECT_ATTR_REDO_TBL(l_index).italic,
p_vertical_alignment =>
G_OBJECT_ATTR_REDO_TBL(l_index).vertical_alignment,
p_horizontal_alignment =>
G_OBJECT_ATTR_REDO_TBL(l_index).horizontal_alignment,
p_data_source_type => G_OBJECT_ATTR_REDO_TBL(l_index).data_source_type,
p_data_storage_type => G_OBJECT_ATTR_REDO_TBL(l_index).data_storage_type,
p_table_name => G_OBJECT_ATTR_REDO_TBL(l_index).table_name,
p_base_table_column_name =>
G_OBJECT_ATTR_REDO_TBL(l_index).base_table_column_name,
p_required_flag => G_OBJECT_ATTR_REDO_TBL(l_index).required_flag,
p_default_value_varchar2 =>
G_OBJECT_ATTR_REDO_TBL(l_index).default_value_varchar2,
p_default_value_number =>
G_OBJECT_ATTR_REDO_TBL(l_index).default_value_number,
p_default_value_date =>
G_OBJECT_ATTR_REDO_TBL(l_index).default_value_date,
p_lov_region_application_id =>
G_OBJECT_ATTR_REDO_TBL(l_index).lov_region_application_id,
p_lov_region_code => G_OBJECT_ATTR_REDO_TBL(l_index).lov_region_code,
p_lov_foreign_key_name =>
G_OBJECT_ATTR_REDO_TBL(l_index).lov_foreign_key_name,
p_lov_attribute_application_id =>
G_OBJECT_ATTR_REDO_TBL(l_index).lov_attribute_application_id,
p_lov_attribute_code =>
G_OBJECT_ATTR_REDO_TBL(l_index).lov_attribute_code,
p_defaulting_api_pkg =>
G_OBJECT_ATTR_REDO_TBL(l_index).defaulting_api_pkg,
p_defaulting_api_proc =>
G_OBJECT_ATTR_REDO_TBL(l_index).defaulting_api_proc,
p_validation_api_pkg =>G_OBJECT_ATTR_REDO_TBL(l_index).validation_api_pkg,
p_validation_api_proc =>
G_OBJECT_ATTR_REDO_TBL(l_index).validation_api_proc,
p_attribute_category => G_OBJECT_ATTR_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute1,
p_attribute2 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute2,
p_attribute3 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute3,
p_attribute4 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute4,
p_attribute5 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute5,
p_attribute6 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute6,
p_attribute7 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute7,
p_attribute8 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute8,
p_attribute9 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute9,
p_attribute10 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute10,
p_attribute11 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute11,
p_attribute12 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute12,
p_attribute13 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute13,
p_attribute14 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute14,
p_attribute15 => G_OBJECT_ATTR_REDO_TBL(l_index).attribute15,
p_attribute_label_long =>
G_OBJECT_ATTR_REDO_TBL(l_index).attribute_label_long,
p_attribute_label_short =>
G_OBJECT_ATTR_REDO_TBL(l_index).attribute_label_short,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
end if; -- /* if ATTRIBUTE_EXISTS */
--
-- If API call returns with an error status, upload aborts
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if; -- /* if l_return_status */
end if;
end loop;
end if;

--
-- Insert or update all object attribute navigation to the database
--
if (G_ATTR_NAV_REDO_INDEX > 0) then
for l_index in G_ATTR_NAV_REDO_TBL.FIRST .. G_ATTR_NAV_REDO_TBL.LAST loop
if (G_ATTR_NAV_REDO_TBL.exists(l_index)) then
if  AK_OBJECT_PVT.ATTRIBUTE_NAVIGATION_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name =>
G_ATTR_NAV_REDO_TBL(l_index).database_object_name,
p_attribute_application_id =>
G_ATTR_NAV_REDO_TBL(l_index).attribute_appl_id,
p_attribute_code => G_ATTR_NAV_REDO_TBL(l_index).attribute_code,
p_value_varchar2 => G_ATTR_NAV_REDO_TBL(l_index).value_varchar2,
p_value_date => G_ATTR_NAV_REDO_TBL(l_index).value_date,
p_value_number => G_ATTR_NAV_REDO_TBL(l_index).value_number) then
AK_OBJECT3_PVT.UPDATE_ATTRIBUTE_NAVIGATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_database_object_name =>
G_ATTR_NAV_REDO_TBL(l_index).database_object_name,
p_attribute_application_id =>
G_ATTR_NAV_REDO_TBL(l_index).attribute_appl_id,
p_attribute_code => G_ATTR_NAV_REDO_TBL(l_index).attribute_code,
p_value_varchar2 => G_ATTR_NAV_REDO_TBL(l_index).value_varchar2,
p_value_date => G_ATTR_NAV_REDO_TBL(l_index).value_date,
p_value_number => G_ATTR_NAV_REDO_TBL(l_index).value_number,
p_to_region_appl_id => G_ATTR_NAV_REDO_TBL(l_index).to_region_appl_id,
p_to_region_code => G_ATTR_NAV_REDO_TBL(l_index).to_region_code,
p_attribute_category => G_ATTR_NAV_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_ATTR_NAV_REDO_TBL(l_index).attribute1,
p_attribute2 => G_ATTR_NAV_REDO_TBL(l_index).attribute2,
p_attribute3 => G_ATTR_NAV_REDO_TBL(l_index).attribute3,
p_attribute4 => G_ATTR_NAV_REDO_TBL(l_index).attribute4,
p_attribute5 => G_ATTR_NAV_REDO_TBL(l_index).attribute5,
p_attribute6 => G_ATTR_NAV_REDO_TBL(l_index).attribute6,
p_attribute7 => G_ATTR_NAV_REDO_TBL(l_index).attribute7,
p_attribute8 => G_ATTR_NAV_REDO_TBL(l_index).attribute8,
p_attribute9 => G_ATTR_NAV_REDO_TBL(l_index).attribute9,
p_attribute10 => G_ATTR_NAV_REDO_TBL(l_index).attribute10,
p_attribute11 => G_ATTR_NAV_REDO_TBL(l_index).attribute11,
p_attribute12 => G_ATTR_NAV_REDO_TBL(l_index).attribute12,
p_attribute13 => G_ATTR_NAV_REDO_TBL(l_index).attribute13,
p_attribute14 => G_ATTR_NAV_REDO_TBL(l_index).attribute14,
p_attribute15 => G_ATTR_NAV_REDO_TBL(l_index).attribute15,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
else
AK_OBJECT_PVT.CREATE_ATTRIBUTE_NAVIGATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_database_object_name =>
G_ATTR_NAV_REDO_TBL(l_index).database_object_name,
p_attribute_application_id =>
G_ATTR_NAV_REDO_TBL(l_index).attribute_appl_id,
p_attribute_code => G_ATTR_NAV_REDO_TBL(l_index).attribute_code,
p_value_varchar2 => G_ATTR_NAV_REDO_TBL(l_index).value_varchar2,
p_value_date => G_ATTR_NAV_REDO_TBL(l_index).value_date,
p_value_number => G_ATTR_NAV_REDO_TBL(l_index).value_number,
p_to_region_appl_id =>
G_ATTR_NAV_REDO_TBL(l_index).to_region_appl_id,
p_to_region_code => G_ATTR_NAV_REDO_TBL(l_index).to_region_code,
p_attribute_category => G_ATTR_NAV_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_ATTR_NAV_REDO_TBL(l_index).attribute1,
p_attribute2 => G_ATTR_NAV_REDO_TBL(l_index).attribute2,
p_attribute3 => G_ATTR_NAV_REDO_TBL(l_index).attribute3,
p_attribute4 => G_ATTR_NAV_REDO_TBL(l_index).attribute4,
p_attribute5 => G_ATTR_NAV_REDO_TBL(l_index).attribute5,
p_attribute6 => G_ATTR_NAV_REDO_TBL(l_index).attribute6,
p_attribute7 => G_ATTR_NAV_REDO_TBL(l_index).attribute7,
p_attribute8 => G_ATTR_NAV_REDO_TBL(l_index).attribute8,
p_attribute9 => G_ATTR_NAV_REDO_TBL(l_index).attribute9,
p_attribute10 => G_ATTR_NAV_REDO_TBL(l_index).attribute10,
p_attribute11 => G_ATTR_NAV_REDO_TBL(l_index).attribute11,
p_attribute12 => G_ATTR_NAV_REDO_TBL(l_index).attribute12,
p_attribute13 => G_ATTR_NAV_REDO_TBL(l_index).attribute13,
p_attribute14 => G_ATTR_NAV_REDO_TBL(l_index).attribute14,
p_attribute15 => G_ATTR_NAV_REDO_TBL(l_index).attribute15,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
end if; -- /* if ATTRIBUTE_NAVIGATION_EXISTS */
--
-- If API call returns with an error status, upload aborts
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
-- dbms_output.put_line('Attr Nav key: '||G_ATTR_NAV_REDO_TBL(l_index).database_object_name||
--                       ' '||G_ATTR_NAV_REDO_TBL(l_index).attribute_code||' '||
--						to_char(G_ATTR_NAV_REDO_TBL(l_index).attribute_appl_id));
RAISE FND_API.G_EXC_ERROR;
end if; -- /* if l_return_status */
end if;
end loop;
end if;

--
-- Insert or update all unique keys to the database
--
if (G_UNIQUE_KEY_REDO_INDEX > 0) then
for l_index in G_UNIQUE_KEY_REDO_TBL.FIRST .. G_UNIQUE_KEY_REDO_TBL.LAST loop
if (G_UNIQUE_KEY_REDO_TBL.exists(l_index)) then
if  AK_KEY_PVT.UNIQUE_KEY_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name =>
G_UNIQUE_KEY_REDO_TBL(l_index).unique_key_name) then
AK_KEY_PVT.UPDATE_UNIQUE_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_unique_key_name =>
G_UNIQUE_KEY_REDO_TBL(l_index).unique_key_name,
p_database_object_name =>
G_UNIQUE_KEY_REDO_TBL(l_index).database_object_name,
p_application_id => G_UNIQUE_KEY_REDO_TBL(l_index).application_id,
p_attribute_category => G_UNIQUE_KEY_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute1,
p_attribute2 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute2,
p_attribute3 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute3,
p_attribute4 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute4,
p_attribute5 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute5,
p_attribute6 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute6,
p_attribute7 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute7,
p_attribute8 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute8,
p_attribute9 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute9,
p_attribute10 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute10,
p_attribute11 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute11,
p_attribute12 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute12,
p_attribute13 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute13,
p_attribute14 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute14,
p_attribute15 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute15,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
else
AK_KEY_PVT.CREATE_UNIQUE_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_unique_key_name =>
G_UNIQUE_KEY_REDO_TBL(l_index).unique_key_name,
p_database_object_name =>
G_UNIQUE_KEY_REDO_TBL(l_index).database_object_name,
p_application_id => G_UNIQUE_KEY_REDO_TBL(l_index).application_id,
p_attribute_category => G_UNIQUE_KEY_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute1,
p_attribute2 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute2,
p_attribute3 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute3,
p_attribute4 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute4,
p_attribute5 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute5,
p_attribute6 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute6,
p_attribute7 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute7,
p_attribute8 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute8,
p_attribute9 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute9,
p_attribute10 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute10,
p_attribute11 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute11,
p_attribute12 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute12,
p_attribute13 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute13,
p_attribute14 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute14,
p_attribute15 => G_UNIQUE_KEY_REDO_TBL(l_index).attribute15,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
end if; -- /* if UNIQUE_KEY_EXISTS */
--
-- If API call returns with an error status, upload aborts
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
-- dbms_output.put_line('Unique_key: '||G_UNIQUE_KEY_REDO_TBL(l_index).unique_key_name||
--                     ' '||G_UNIQUE_KEY_REDO_TBL(l_index).database_object_name);
RAISE FND_API.G_EXC_ERROR;
end if; -- /* if l_return_status */
end if;
end loop;
end if;

--
-- Insert or update all unique key columns to the database
--
if (G_UNIQUE_KEY_COL_REDO_INDEX > 0) then
for l_index in G_UNIQUE_KEY_COL_REDO_TBL.FIRST .. G_UNIQUE_KEY_COL_REDO_TBL.LAST loop
if (G_UNIQUE_KEY_COL_REDO_TBL.exists(l_index)) then
if  AK_KEY_PVT.UNIQUE_KEY_COLUMN_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name =>
G_UNIQUE_KEY_COL_REDO_TBL(l_index).unique_key_name,
p_attribute_application_id =>
G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute_application_id,
p_attribute_code =>
G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute_code) then
AK_KEY_PVT.UPDATE_UNIQUE_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_unique_key_name =>
G_UNIQUE_KEY_COL_REDO_TBL(l_index).unique_key_name,
p_attribute_application_id =>
G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute_application_id,
p_attribute_code =>
G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute_code,
p_unique_key_sequence =>
G_UNIQUE_KEY_COL_REDO_TBL(l_index).unique_key_sequence,
p_attribute_category => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute1,
p_attribute2 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute2,
p_attribute3 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute3,
p_attribute4 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute4,
p_attribute5 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute5,
p_attribute6 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute6,
p_attribute7 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute7,
p_attribute8 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute8,
p_attribute9 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute9,
p_attribute10 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute10,
p_attribute11 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute11,
p_attribute12 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute12,
p_attribute13 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute13,
p_attribute14 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute14,
p_attribute15 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute15,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
else
AK_KEY_PVT.CREATE_UNIQUE_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_unique_key_name =>
G_UNIQUE_KEY_COL_REDO_TBL(l_index).unique_key_name,
p_attribute_application_id =>
G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute_application_id,
p_attribute_code =>
G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute_code,
p_unique_key_sequence =>
G_UNIQUE_KEY_COL_REDO_TBL(l_index).unique_key_sequence,
p_attribute_category => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute1,
p_attribute2 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute2,
p_attribute3 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute3,
p_attribute4 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute4,
p_attribute5 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute5,
p_attribute6 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute6,
p_attribute7 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute7,
p_attribute8 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute8,
p_attribute9 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute9,
p_attribute10 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute10,
p_attribute11 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute11,
p_attribute12 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute12,
p_attribute13 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute13,
p_attribute14 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute14,
p_attribute15 => G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute15,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
end if; -- /* if UNIQUE_KEY_COLUMN_EXISTS */
--
-- If API call returns with an error status, upload aborts
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
-- dbms_output.put_line('Unique key col: '||G_UNIQUE_KEY_COL_REDO_TBL(l_index).unique_key_name||
--                     ' '||G_UNIQUE_KEY_COL_REDO_TBL(l_index).attribute_code);
RAISE FND_API.G_EXC_ERROR;
end if; -- /* if l_return_status */
end if;
end loop;
end if;

--
-- Insert or update all foreign keys to the database
--
if (G_FOREIGN_KEY_REDO_INDEX > 0) then
for l_index in G_FOREIGN_KEY_REDO_TBL.FIRST .. G_FOREIGN_KEY_REDO_TBL.LAST loop
if (G_FOREIGN_KEY_REDO_TBL.exists(l_index)) then
if  AK_KEY_PVT.FOREIGN_KEY_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name =>
G_FOREIGN_KEY_REDO_TBL(l_index).foreign_key_name) then
AK_KEY_PVT.UPDATE_FOREIGN_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_foreign_key_name =>
G_FOREIGN_KEY_REDO_TBL(l_index).foreign_key_name,
p_database_object_name =>
G_FOREIGN_KEY_REDO_TBL(l_index).database_object_name,
p_unique_key_name =>
G_FOREIGN_KEY_REDO_TBL(l_index).unique_key_name,
p_application_id => G_FOREIGN_KEY_REDO_TBL(l_index).application_id,
p_attribute_category => G_FOREIGN_KEY_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute1,
p_attribute2 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute2,
p_attribute3 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute3,
p_attribute4 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute4,
p_attribute5 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute5,
p_attribute6 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute6,
p_attribute7 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute7,
p_attribute8 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute8,
p_attribute9 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute9,
p_attribute10 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute10,
p_attribute11 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute11,
p_attribute12 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute12,
p_attribute13 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute13,
p_attribute14 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute14,
p_attribute15 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute15,
p_from_to_name => G_FOREIGN_KEY_REDO_TBL(l_index).from_to_name,
p_from_to_description =>
G_FOREIGN_KEY_REDO_TBL(l_index).from_to_description,
p_to_from_name => G_FOREIGN_KEY_REDO_TBL(l_index).to_from_name,
p_to_from_description =>
G_FOREIGN_KEY_REDO_TBL(l_index).to_from_description,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
else
AK_KEY_PVT.CREATE_FOREIGN_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_foreign_key_name =>
G_FOREIGN_KEY_REDO_TBL(l_index).foreign_key_name,
p_database_object_name =>
G_FOREIGN_KEY_REDO_TBL(l_index).database_object_name,
p_unique_key_name =>
G_FOREIGN_KEY_REDO_TBL(l_index).unique_key_name,
p_application_id => G_FOREIGN_KEY_REDO_TBL(l_index).application_id,
p_attribute_category => G_FOREIGN_KEY_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute1,
p_attribute2 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute2,
p_attribute3 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute3,
p_attribute4 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute4,
p_attribute5 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute5,
p_attribute6 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute6,
p_attribute7 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute7,
p_attribute8 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute8,
p_attribute9 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute9,
p_attribute10 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute10,
p_attribute11 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute11,
p_attribute12 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute12,
p_attribute13 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute13,
p_attribute14 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute14,
p_attribute15 => G_FOREIGN_KEY_REDO_TBL(l_index).attribute15,
p_from_to_name => G_FOREIGN_KEY_REDO_TBL(l_index).from_to_name,
p_from_to_description =>
G_FOREIGN_KEY_REDO_TBL(l_index).from_to_description,
p_to_from_name => G_FOREIGN_KEY_REDO_TBL(l_index).to_from_name,
p_to_from_description =>
G_FOREIGN_KEY_REDO_TBL(l_index).to_from_description,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
end if; -- /* if FOREIGN_KEY_EXISTS */
--
-- If API call returns with an error status, upload aborts
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
-- dbms_output.put_line('Foreign key: '||G_FOREIGN_KEY_REDO_TBL(l_index).foreign_key_name||
--                     ' '||G_FOREIGN_KEY_REDO_TBL(l_index).database_object_name);
RAISE FND_API.G_EXC_ERROR;
end if; -- /* if l_return_status */
end if;
end loop;
end if;

--
-- Insert or update all foreign key columns to the database
--
if (G_FOREIGN_KEY_COL_REDO_INDEX > 0) then
for l_index in G_FOREIGN_KEY_COL_REDO_TBL.FIRST .. G_FOREIGN_KEY_COL_REDO_TBL.LAST loop
if (G_FOREIGN_KEY_COL_REDO_TBL.exists(l_index)) then
if  AK_KEY_PVT.FOREIGN_KEY_COLUMN_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name =>
G_FOREIGN_KEY_COL_REDO_TBL(l_index).foreign_key_name,
p_attribute_application_id =>
G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute_application_id,
p_attribute_code =>
G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute_code) then
AK_KEY_PVT.UPDATE_FOREIGN_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_foreign_key_name =>
G_FOREIGN_KEY_COL_REDO_TBL(l_index).foreign_key_name,
p_attribute_application_id =>
G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute_application_id,
p_attribute_code =>
G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute_code,
p_foreign_key_sequence =>
G_FOREIGN_KEY_COL_REDO_TBL(l_index).foreign_key_sequence,
p_attribute_category => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute1,
p_attribute2 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute2,
p_attribute3 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute3,
p_attribute4 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute4,
p_attribute5 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute5,
p_attribute6 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute6,
p_attribute7 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute7,
p_attribute8 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute8,
p_attribute9 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute9,
p_attribute10 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute10,
p_attribute11 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute11,
p_attribute12 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute12,
p_attribute13 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute13,
p_attribute14 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute14,
p_attribute15 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute15,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
else
AK_KEY_PVT.CREATE_FOREIGN_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_foreign_key_name =>
G_FOREIGN_KEY_COL_REDO_TBL(l_index).foreign_key_name,
p_attribute_application_id =>
G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute_application_id,
p_attribute_code =>
G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute_code,
p_foreign_key_sequence =>
G_FOREIGN_KEY_COL_REDO_TBL(l_index).foreign_key_sequence,
p_attribute_category => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute_category,
p_attribute1 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute1,
p_attribute2 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute2,
p_attribute3 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute3,
p_attribute4 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute4,
p_attribute5 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute5,
p_attribute6 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute6,
p_attribute7 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute7,
p_attribute8 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute8,
p_attribute9 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute9,
p_attribute10 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute10,
p_attribute11 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute11,
p_attribute12 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute12,
p_attribute13 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute13,
p_attribute14 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute14,
p_attribute15 => G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute15,
p_loader_timestamp => p_loader_timestamp,
p_pass => p_pass,
p_copy_redo_flag => l_copy_redo_flag
);
end if; -- /* if FOREIGN_KEY_COLUMN_EXISTS */
--
-- If API call returns with an error status, upload aborts
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
-- dbms_output.put_line('Foreign Key col: '||G_FOREIGN_KEY_COL_REDO_TBL(l_index).foreign_key_name||
--                     ' '||G_FOREIGN_KEY_COL_REDO_TBL(l_index).attribute_code);
RAISE FND_API.G_EXC_ERROR;
end if; -- /* if l_return_status */
end if;
end loop;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => l_msg_count,
p_data => l_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Count_And_Get (
p_count => l_msg_count,
p_data => l_msg_data);

end UPLOAD_OBJECT_SECOND;

end AK_OBJECT2_PVT;

/
