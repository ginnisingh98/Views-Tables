--------------------------------------------------------
--  DDL for Package Body AK_ATTRIBUTE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_ATTRIBUTE_GRP" as
/* $Header: akdgattb.pls 120.2 2005/09/15 22:26:30 tshort ship $ */

--=======================================================
--  Procedure   CREATE_ATTRIBUTE
--
--  Usage       Group API for creating an attribute
--
--  Desc        Calls the private API to creates an attribute
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute columns
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
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_attribute_label_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_value_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_bold                     IN      VARCHAR2,
p_italic                   IN      VARCHAR2,
p_vertical_alignment       IN      VARCHAR2,
p_horizontal_alignment     IN      VARCHAR2,
p_data_type                IN      VARCHAR2,
p_upper_case_flag          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_item_style               IN      VARCHAR2,
p_display_height	     IN	     NUMBER := FND_API.G_MISS_NUM,
p_css_class_name           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_viewobject       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_display_attr     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_value_attr       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_css_label_class_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_precision		     IN      NUMBER := FND_API.G_MISS_NUM,
p_expansion		     IN	     NUMBER := FND_API.G_MISS_NUM,
p_als_max_length	     IN	     NUMBER := FND_API.G_MISS_NUM,
p_name                     IN      VARCHAR2,
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Attribute';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
/* Check API version number */
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

--
-- Call private procedure to create an attribute
--
AK_ATTRIBUTE_PVT.CREATE_ATTRIBUTE(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_attribute_label_length => p_attribute_label_length,
p_attribute_value_length => p_attribute_value_length,
p_bold => p_bold,
p_italic => p_italic,
p_vertical_alignment => p_vertical_alignment,
p_horizontal_alignment => p_horizontal_alignment,
p_data_type => p_data_type,
p_upper_case_flag => p_upper_case_flag,
p_default_value_varchar2 => p_default_value_varchar2,
p_default_value_number => p_default_value_number,
p_default_value_date => p_default_value_date,
p_lov_region_application_id => p_lov_region_application_id,
p_lov_region_code => p_lov_region_code,
p_item_style => p_item_style,
p_display_height => p_display_height,
p_css_class_name => p_css_class_name,
p_poplist_viewobject => p_poplist_viewobject,
p_poplist_display_attr => p_poplist_display_attr,
p_poplist_value_attr => p_poplist_value_attr,
p_css_label_class_name => p_css_label_class_name,
p_precision => p_precision,
p_expansion => p_expansion,
p_als_max_length => p_als_max_length,
p_name => p_name,
p_attribute_label_long => p_attribute_label_long,
p_attribute_label_short => p_attribute_label_short,
p_description => p_description,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

--
-- If API call returns with an error status...
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
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
--  Procedure   DELETE_ATTRIBUTE
--
--  Usage       Group API for deleting an attribute
--
--  Desc        Calls the private API to deletes an attribute
--              with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_attribute_application_id : IN required
--              p_attribute_code : IN required
--                  Key value of the attribute to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this attribute.
--                  Otherwise, this attribute will not be deleted if there
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
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2 := 'N'
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Attribute';
l_return_status      VARCHAR2(1);
begin
--
-- Check API version number
--
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
-- Call private procedure to create an attribute
--
AK_ATTRIBUTE_PVT.DELETE_ATTRIBUTE(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_delete_cascade => p_delete_cascade
);

--
-- If API call returns with an error status...
--
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
--  Procedure   DOWNLOAD_ATTRIBUTE
--
--  Usage       Group API for downloading attributes
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
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--              p_application_short_name : IN optional
--                  If given, all attributes for this application short
--                  name will be written to the output file.
--                  Application short name will be ignored if an
--                  application ID is given.
--              p_attribute_pk_tbl : IN optional
--                  If given, only attributes whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_ATTRIBUTE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_nls_language             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_application_short_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_pk_tbl         IN      AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type :=
AK_ATTRIBUTE_PUB.G_MISS_ATTRIBUTE_PK_TBL
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Download';
l_application_id     number;
l_index              NUMBER;
l_index_out          NUMBER;
l_nls_language       VARCHAR2(30);
l_return_status      varchar2(1);
l_dum                NUMBER;
begin
--
-- Check verion number
--
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
--
-- Call private download procedure to verify parameters,
-- load application ID, and write header information such
-- as nls_language and codeset to data file.
--
AK_ON_OBJECTS_PVT.download_header(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_nls_language => p_nls_language,
p_application_id => p_application_id,
p_application_short_name => p_application_short_name,
p_table_size => p_attribute_pk_tbl.count,
p_download_by_object => AK_ON_OBJECTS_PVT.G_ATTRIBUTE,
p_nls_language_out => l_nls_language,
p_application_id_out => l_application_id
);
else
l_application_id := p_application_id;
select userenv('LANG') into l_nls_language
from dual;
end if;
--
-- If API call returns with an error status...
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

--
-- - call the download procedure for attributes to retrieve the
--   selected attributes from the database into a table of type
--   AK_ON_OBJECTS_PUB.Buffer_Tbl_Type.
--
AK_ATTRIBUTE_PVT.DOWNLOAD_ATTRIBUTE(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => l_application_id,
p_attribute_pk_tbl => p_attribute_pk_tbl,
p_nls_language => l_nls_language
);

--
-- If download call returns with an error status or
-- download failed to retrieve any information from the database..
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

end DOWNLOAD_ATTRIBUTE;

--=======================================================
--  Procedure   UPDATE_ATTRIBUTE
--
--  Usage       Group API for updating an attribute
--
--  Desc        This API calls the private API to update
--              an attribute using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute columns
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
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_attribute_label_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_value_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_bold                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_italic                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_vertical_alignment       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_horizontal_alignment     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_data_type                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_upper_case_flag          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_item_style               IN      VARCHAR2,
p_display_height           IN      NUMBER := FND_API.G_MISS_NUM,
p_css_class_name           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_viewobject       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_display_attr     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_value_attr       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_css_label_class_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_precision		     IN      NUMBER := FND_API.G_MISS_NUM,
p_expansion		     IN      NUMBER := FND_API.G_MISS_NUM,
p_als_max_length	     IN	     NUMBER := FND_API.G_MISS_NUM,
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Attribute';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
--
-- Check API version number
--
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

--
-- Call private procedure to create an attribute
--
AK_ATTRIBUTE_PVT.UPDATE_ATTRIBUTE(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_attribute_label_length => p_attribute_label_length,
p_attribute_value_length => p_attribute_value_length,
p_bold => p_bold,
p_italic => p_italic,
p_vertical_alignment => p_vertical_alignment,
p_horizontal_alignment => p_horizontal_alignment,
p_data_type => p_data_type,
p_upper_case_flag => p_upper_case_flag,
p_default_value_varchar2 => p_default_value_varchar2,
p_default_value_number => p_default_value_number,
p_default_value_date => p_default_value_date,
p_lov_region_application_id => p_lov_region_application_id,
p_lov_region_code => p_lov_region_code,
p_item_style => p_item_style,
p_display_height => p_display_height,
p_css_class_name => p_css_class_name,
p_poplist_viewobject => p_poplist_viewobject,
p_poplist_display_attr => p_poplist_display_attr,
p_poplist_value_attr => p_poplist_value_attr,
p_css_label_class_name => p_css_label_class_name,
p_precision => p_precision,
p_expansion => p_expansion,
p_als_max_length => p_als_max_length,
p_name => p_name,
p_attribute_label_long => p_attribute_label_long,
p_attribute_label_short => p_attribute_label_short,
p_description => p_description,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

--
-- If API call returns with an error status...
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line('Update_Attribute failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_attribute;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
rollback to start_update_attribute;
end UPDATE_ATTRIBUTE;

end AK_Attribute_grp;

/
