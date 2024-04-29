--------------------------------------------------------
--  DDL for Package Body AK_REGION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_REGION_PVT" as
/* $Header: akdvregb.pls 120.6 2006/11/30 23:27:31 tshort ship $ */

/*
--=======================================================
--  Function    VALIDATE_GRAPH
--
--  Usage       Private API for validating a region graph. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a region graph record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Region graph columns
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
function VALIDATE_GRAPH (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_graph_number	     IN	     NUMBER := FND_API.G_MISS_NUM,
p_graph_style		     IN      NUMBER := FND_API.G_MISS_NUM,
p_display_flag	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_depth_radius	     IN      NUMBER := FND_API.G_MISS_NUM,
p_graph_title		     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_y_axis_label	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller		     IN      VARCHAR2,
p_pass		     IN	     NUMBER := 2
) return BOOLEAN is
cursor l_check_region_csr is
select  region_style
from    AK_REGIONS
where   region_application_id = p_region_application_id
and     region_code = p_region_code;

l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Validate_Graph';
l_dummy                   NUMBER;
l_reg_style		    VARCHAR2(30);
l_error                   BOOLEAN;
l_return_status           VARCHAR2(1);
l_validation_level	    NUMBER := FND_API.G_VALID_LEVEL_NONE;

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
if ((p_region_application_id is null) or
(p_region_application_id = FND_API.G_MISS_NUM)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_region_code is null) or
(p_region_code = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_CODE');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_graph_number is null) or
(p_graph_number =  FND_API.G_MISS_NUM)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
FND_MSG_PUB.Add;
end if;
end if;

-- - Check that the parent region exists and retrieve the
--   database object name referenced by the parent region
open l_check_region_csr;
fetch l_check_region_csr into l_reg_style;
if (l_check_region_csr%notfound) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_REGION_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code );
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Parent region does not exist!');
end if;
if (l_reg_style <> 'GRAPH_DATA') then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_REGION_STYLE');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code );
FND_MSG_PUB.Add;
end if;
end if;
close l_check_region_csr;

--** check that required columns are not null and, unless calling  **
--** from UPDATE procedure, the columns are not missing            **

if ((p_graph_style is null) or
(p_graph_style = FND_API.G_MISS_NUM and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'GRAPH_STYLE');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_display_flag is null) or
(p_display_flag = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'DISPLAY_FLAG');
FND_MSG_PUB.Add;
end if;
end if;

-- === Validate columns ===
--
-- display_flag
--
if (p_display_flag <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_YES_NO(p_display_flag)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_VALUE_NOT_YES_NO');
FND_MESSAGE.SET_TOKEN('COLUMN','DISPLAY_FLAG');
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

end VALIDATE_GRAPH;
*/

--=======================================================
--  Function    VALIDATE_ITEM
--
--  Usage       Private API for validating a region item. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a region item record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Region item columns
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
function VALIDATE_ITEM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_display_sequence         IN      NUMBER := FND_API.G_MISS_NUM,
p_node_display_flag        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_node_query_flag          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_display_value_length     IN      NUMBER := FND_API.G_MISS_NUM,
p_bold                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_italic                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_vertical_alignment       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_horizontal_alignment     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_item_style               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_object_attribute_flag    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_icx_custom_call          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_update_flag              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_required_flag            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_security_code            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
p_nested_region_appl_id IN     NUMBER := FND_API.G_MISS_NUM,
p_nested_region_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_foreign_key_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_attribute_application_id IN  NUMBER := FND_API.G_MISS_NUM,
p_lov_attribute_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_default_flag         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_defaulting_api_pkg IN     VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_defaulting_api_proc IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_validation_api_pkg IN     VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_validation_api_proc IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_order_sequence           IN      NUMBER := FND_API.G_MISS_NUM,
p_order_direction          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_menu_name		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_application_id IN      NUMBER   := FND_API.G_MISS_NUM,
p_tabular_function_code    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_type                 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_application_id   IN      NUMBER   := FND_API.G_MISS_NUM,
p_flex_segment_list        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_entity_id                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_anchor                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_view_usage_name  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_user_customizable	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_sortby_view_attribute_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_invoke_function_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_expansion		     IN      NUMBER := FND_API.G_MISS_NUM,
p_als_max_length	     IN      NUMBER := FND_API.G_MISS_NUM,
p_initial_sort_sequence    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_application_id IN  NUMBER := FND_API.G_MISS_NUM,
p_customization_code	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN is
cursor l_check_region_csr is
select  database_object_name
from    AK_REGIONS
where   region_application_id = p_region_application_id
and     region_code = p_region_code;
cursor l_check_seq_csr is
select  1
from    AK_REGION_ITEMS
where   region_application_id = p_region_application_id
and     region_code = p_region_code
and     display_sequence = p_display_sequence
and     ( (attribute_application_id <> p_attribute_application_id)
or        (attribute_code <> p_attribute_code) );
cursor l_check_menu_name (param_menu_name varchar2) is
select 1
from FND_MENUS_VL
where menu_name = param_menu_name;
cursor l_check_flexfield_name (param_flexfield_name varchar2,
param_flexfield_application_id number) is
select 1
from  FND_DESCRIPTIVE_FLEXS FLEX
where FLEX.DESCRIPTIVE_FLEXFIELD_NAME not like '$SRS$.%'
and   FLEX.DESCRIPTIVE_FLEXFIELD_NAME = param_flexfield_name
and   FLEX.APPLICATION_ID = param_flexfield_application_id
union
select 1
from  FND_ID_FLEXS FLEX
where FLEX.ID_FLEX_CODE = param_flexfield_name
and   FLEX.APPLICATION_ID = param_flexfield_application_id;

cursor l_check_message_name (param_message_name varchar2,
param_message_application_id number) is
select 1
from  FND_NEW_MESSAGES MSG
where MSG.MESSAGE_NAME = param_message_name
and   MSG.APPLICATION_ID = param_message_application_id;

cursor l_check_entity_id (param_entity_id varchar2) is
select 1
from FND_DOCUMENT_ENTITIES
where data_object_code = param_entity_id;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Validate_Item';
l_database_object_name    VARCHAR2(30);
l_dummy                   NUMBER;
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
if ((p_region_application_id is null) or
(p_region_application_id = FND_API.G_MISS_NUM)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_region_code is null) or
(p_region_code = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_CODE');
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

-- - Check that the parent region exists and retrieve the
--   database object name referenced by the parent region
open l_check_region_csr;
fetch l_check_region_csr into l_database_object_name;
if (l_check_region_csr%notfound) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_REGION_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code );
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Parent region does not exist!');
end if;
close l_check_region_csr;

--
--   Check that the attribute or object attribute referenced exists
--
if (p_object_attribute_flag = 'Y') then
if (NOT AK_OBJECT_PVT.ATTRIBUTE_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => l_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) ) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_OA_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', l_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
RAISE FND_API.G_EXC_ERROR;
--dbms_output.put_line('Object Attribute referenced does not exist!');
end if;
else
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
RAISE FND_API.G_EXC_ERROR;
-- dbms_output.put_line('Attribute referenced does not exist!');
end if;
end if;

--** check that required columns are not null and, unless calling  **
--** from UPDATE procedure, the columns are not missing            **

if ((p_display_sequence is null) or
(p_display_sequence = FND_API.G_MISS_NUM and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'DISPLAY_SEQUENCE');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_node_display_flag is null) or
(p_node_display_flag = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'NODE_DISPLAY_FLAG');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_node_query_flag is null) or
(p_node_query_flag = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'NODE_QUERY_FLAG');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_label_length is null) or
(p_attribute_label_length = FND_API.G_MISS_NUM and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_LABEL_LENGTH');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_display_value_length is null) or
(p_display_value_length = FND_API.G_MISS_NUM and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
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
FND_MESSAGE.SET_TOKEN('COLUMN','ITALIC');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_vertical_alignment is null) or
(p_vertical_alignment = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'VERTICAL_ALIGNMENT');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_horizontal_alignment is null) or
(p_horizontal_alignment = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'HORIZONTAL_ALIGNMENT');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_item_style is null) or
(p_item_style = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ITEM_SYTLE');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_object_attribute_flag is null) or
(p_object_attribute_flag = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'OBJECT_ATTRIBUTE_FLAG');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_update_flag is null) or
(p_update_flag = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'UPDATE_FLAG');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_required_flag is null) or
(p_required_flag = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'REQUIRED_FLAG');
FND_MSG_PUB.Add;
end if;
end if;

-- === Validate columns ===
--
-- display_sequence
--
if (p_display_sequence <> FND_API.G_MISS_NUM) then
open l_check_seq_csr;
fetch l_check_seq_csr into l_dummy;
if (l_check_seq_csr%found) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_DISPLAY_SEQUENCE');
FND_MSG_PUB.Add;
end if;
end if;
close l_check_seq_csr;
end if;

-- - node_display_flag
if (p_node_display_flag <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_YES_NO(p_node_display_flag)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_VALUE_NOT_YES_NO');
FND_MESSAGE.SET_TOKEN('COLUMN','NODE_DISPLAY_FLAG');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - node_query_flag
if (p_node_query_flag <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_YES_NO(p_node_query_flag)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_VALUE_NOT_YES_NO');
FND_MESSAGE.SET_TOKEN('COLUMN','NODE_QUERY_FLAG');
FND_MSG_PUB.Add;
end if;
end if;
end if;

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

-- - vertical alignment
if (p_vertical_alignment <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_lookup_type  => 'VERTICAL_ALIGNMENT',
p_lookup_code => p_vertical_alignment)) then
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
p_lookup_type  => 'HORIZONTAL_ALIGNMENT',
p_lookup_code => p_horizontal_alignment)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','HORIZONTAL_ALIGNMENT');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - item style
if (p_item_style <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_lookup_type  => 'ITEM_STYLE',
p_lookup_code => p_item_style)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','ITEM_STYLE');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - object attribute flag
if (p_object_attribute_flag <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_YES_NO(p_object_attribute_flag)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_VALUE_NOT_YES_NO');
FND_MESSAGE.SET_TOKEN('COLUMN','OBJECT_ATTRIBUTE_FLAG');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - update_flag
if (p_update_flag <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_YES_NO(p_update_flag)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_VALUE_NOT_YES_NO');
FND_MESSAGE.SET_TOKEN('COLUMN','UPDATE_FLAG');
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

-- - nested_region_application_id and nested_region_code
if ( (p_nested_region_appl_id <> FND_API.G_MISS_NUM) and
(p_nested_region_appl_id is not null) ) or
( (p_nested_region_code <> FND_API.G_MISS_CHAR) and
(p_nested_region_code is not null) )then
if (NOT AK_REGION_PVT.REGION_EXISTS(
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_nested_region_appl_id,
p_region_code => p_nested_region_code)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_NST_REG_DOES_NOT_EXIST');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_nested_region_appl_id) || ' ' || p_nested_region_code);
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
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_lov_region_application_id) || ' ' || p_lov_region_code);
FND_MSG_PUB.Add;
end if;
end if;
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
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id)||' '||p_region_code||' '||
to_char(p_attribute_application_id) ||' ' || p_attribute_code);
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
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - lov_default_flag
if (p_lov_default_flag <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_lookup_type  => 'LOV_DEFAULT_FLAG',
p_lookup_code => p_lov_default_flag)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','LOV_DEFAULT_FLAG');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - order_direction
if (p_order_direction <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_lookup_type  => 'ORDER_DIRECTION',
p_lookup_code => p_order_direction)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','ORDER_DIRECTION');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - menu_name
if (p_menu_name <> FND_API.G_MISS_CHAR and p_menu_name is not null) then
open l_check_menu_name(p_menu_name);
fetch l_check_menu_name into l_dummy;
if ( l_check_menu_name%notfound) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','MENU_NAME');
FND_MSG_PUB.Add;
end if;
end if;
close l_check_menu_name;
end if;

-- - flexfield_name
if (p_flexfield_name <> FND_API.G_MISS_CHAR and p_flexfield_name is not null) then
open l_check_flexfield_name(p_flexfield_name, p_flexfield_application_id);
fetch l_check_flexfield_name into l_dummy;
if ( l_check_flexfield_name%notfound) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','FLEXFIELD_NAME');
FND_MSG_PUB.Add;
end if;
end if;
close l_check_flexfield_name;
end if;

-- tip message
if (p_tip_message_name <> FND_API.G_MISS_CHAR and p_tip_message_name is not null) then
open l_check_message_name(p_tip_message_name, p_tip_message_application_id);
fetch l_check_message_name into l_dummy;
if ( l_check_message_name%notfound) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','TIP_MESSAGE_NAME');
FND_MSG_PUB.Add;
end if;
end if;
close l_check_message_name;
end if;

-- entity id
if (p_entity_id <> FND_API.G_MISS_CHAR and p_entity_id is not null) then
open l_check_entity_id(p_entity_id);
fetch l_check_entity_id into l_dummy;
if ( l_check_entity_id%notfound) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','ENTITY_ID');
FND_MSG_PUB.Add;
end if;
end if;
close l_check_entity_id;
end if;

-- initial_sort_sequence
if (p_initial_sort_sequence <> FND_API.G_MISS_CHAR and
p_initial_sort_sequence is not null) then
if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_lookup_type  => 'INIT_SORT_TYPE',
p_lookup_code => p_initial_sort_sequence)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass =
2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','INITIAL_SORT_SEQUENCE');
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

end VALIDATE_ITEM;

--=======================================================
--  Function    VALIDATE_REGION
--
--  Usage       Private API for validating a region. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a region record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Region columns
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
function VALIDATE_REGION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_database_object_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_style             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_icx_custom_call          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_num_columns              IN      NUMBER := FND_API.G_MISS_NUM,
p_region_defaulting_api_pkg IN     VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_defaulting_api_proc IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_validation_api_pkg IN     VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_validation_api_proc IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Validate_Region';
l_error              BOOLEAN;
l_return_status      varchar2(1);
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
if ((p_region_application_id is null) or
(p_region_application_id = FND_API.G_MISS_NUM)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_region_code is null) or
(p_region_code = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_CODE');
FND_MSG_PUB.Add;
end if;
end if;

--** check that required columns are not null and, unless calling  **
--** from UPDATE procedure, the columns are not missing            **
if ((p_database_object_name is null) or
(p_database_object_name = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'DATABASE_OBJECT_NAME');
FND_MSG_PUB.Add;
end if;
end if;

if (p_region_style is null) or
((p_region_style = FND_API.G_MISS_CHAR) and
(p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'REGION_STYLE');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_name is null) or
(p_name = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'NAME');
FND_MSG_PUB.Add;
end if;
end if;

--** Validate columns **
-- - Database object name
if (p_database_object_name <> FND_API.G_MISS_CHAR) then
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
--dbms_output.put_line(l_api_name || ' Invalid database object name');
end if;
end if;

-- - Region style
if (p_region_style <> FND_API.G_MISS_CHAR) then
if (NOT AK_ON_OBJECTS_PVT.VALID_LOOKUP_CODE (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_lookup_type => 'REGION_STYLE',
p_lookup_code => p_region_style)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','REGION_STYLE');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || ' Invalid region style');
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

end VALIDATE_REGION;

/*
--=======================================================
--  Procedure   WRITE_GRAPH_COL_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given region
--              graph column records to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure writes graph_columns to output file
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the Category Usage to be extracted to the loader
--                  file.
--              p_attribute_application_id : IN required
--                  Key value of the Category Usage to be extracted to the loader
--                  file.
--              p_attribute_code : IN required
--                  Key value of the Category Usage to be extracted to the loader
--                  file.
--              p_category_id : IN required
--                  Key value of the Category Usage to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_GRAPH_COL_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_graph_number	     IN      NUMBER
) is
cursor l_get_graph_columns_csr is
select *
from AK_REGION_GRAPH_COLUMNS
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   GRAPH_NUMBER = p_graph_number;
l_api_name           CONSTANT varchar2(50) := 'Write_Graph_Col_to_Buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_graph_columns_rec   AK_REGION_GRAPH_COLUMNS%ROWTYPE;
l_return_status      varchar2(1);
begin
-- Retrieve region information from the database

open l_get_graph_columns_csr;
loop
fetch l_get_graph_columns_csr into l_graph_columns_rec;
exit when l_get_graph_columns_csr%notfound;

-- Region graph column must be validated before it is written to the file

if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_REGION2_PVT.VALIDATE_GRAPH_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => l_graph_columns_rec.region_application_id,
p_region_code => l_graph_columns_rec.region_code,
p_attribute_application_id => l_graph_columns_rec.attribute_application_id,
p_attribute_code => l_graph_columns_rec.attribute_code,
p_graph_number => l_graph_columns_rec.graph_number,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_GRAPH_COLUMN_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
p_region_code);
FND_MSG_PUB.Add;
end if;
close l_get_graph_columns_csr;
raise FND_API.G_EXC_ERROR;
end if; -- if AK_REGION2_PVT.VALIDATE_GRAPH_COLUMN
end if; -- if p_validation_level

-- Write region lov relation into buffer
-- write a blank line after region item
l_index := 1;
l_databuffer_tbl(l_index) := ' ';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    BEGIN REGION_GRAPH_COLUMN "' ||
nvl(to_char(l_graph_columns_rec.attribute_application_id), '')
|| '" "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_graph_columns_rec.attribute_code) || '" ';
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CREATED_BY = "' ||
nvl(to_char(l_graph_columns_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CREATION_DATE = "' ||
to_char(l_graph_columns_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATED_BY = "' ||
nvl(to_char(l_graph_columns_rec.last_updated_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATE_DATE = "' ||
to_char(l_graph_columns_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_graph_columns_rec.last_update_login),'') || '"';

l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    END REGION_GRAPH_COLUMN';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';

-- - Write the 'END REGION_GRAPH_COLUMN' to the specified file
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);
-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_graph_columns_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

end loop;
close l_get_graph_columns_csr;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_GRAPH_COLUMN_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
p_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_GRAPH_COLUMN_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
p_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end WRITE_GRAPH_COL_TO_BUFFER;
*/

--=======================================================
--  Procedure   WRITE_CAT_USAGES_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given region
--              item category usages records to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure writes category_usages to output file
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the Category Usage to be extracted to the loader
--                  file.
--              p_attribute_application_id : IN required
--                  Key value of the Category Usage to be extracted to the loader
--                  file.
--              p_attribute_code : IN required
--                  Key value of the Category Usage to be extracted to the loader
--                  file.
--              p_category_id : IN required
--                  Key value of the Category Usage to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_CAT_USAGES_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN		 NUMBER,
p_attribute_code           IN      VARCHAR2
) is
cursor l_get_category_usages_csr is
select *
from  AK_CATEGORY_USAGES
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code;
l_api_name           CONSTANT varchar2(50) := 'Write_category_usages_to_buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_category_usage_rec   AK_CATEGORY_USAGES%ROWTYPE;
l_return_status      varchar2(1);
begin
-- Retrieve region information from the database

open l_get_category_usages_csr;
loop
fetch l_get_category_usages_csr into l_category_usage_rec;
exit when l_get_category_usages_csr%notfound;

-- Region lov relation must be validated before it is written to the file
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_REGION2_PVT.VALIDATE_CATEGORY_USAGE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => l_category_usage_rec.region_application_id,
p_region_code => l_category_usage_rec.region_code,
p_attribute_application_id => l_category_usage_rec.attribute_application_id,
p_attribute_code => l_category_usage_rec.attribute_code,
p_category_name => l_category_usage_rec.category_name,
p_category_id => l_category_usage_rec.category_id,
p_application_id => l_category_usage_rec.application_id,
p_show_all => l_category_usage_rec.show_all,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CATEGORY_USAGE_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
p_region_code||' '||to_char(p_attribute_application_id)||
' '||p_attribute_code);
FND_MSG_PUB.Add;
end if;
close l_get_category_usages_csr;
raise FND_API.G_EXC_ERROR;
end if; /* if AK_REGION2_PVT.VALIDATE_CATEGORY_USAGE */
end if; /* if p_validation_level */

-- Write category_usage into buffer
-- write a blank line after region item
l_index := 1;
l_databuffer_tbl(l_index) := ' ';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    BEGIN CATEGORY_USAGE "' ||
nvl(to_char(l_category_usage_rec.category_id),'') || '"';
if ((l_category_usage_rec.application_id IS NOT NULL) and
(l_category_usage_rec.application_id <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      APPLICATION_ID = "' ||
nvl(to_char(l_category_usage_rec.application_id),'') || '"';
end if;
if ((l_category_usage_rec.category_id IS NOT NULL) and
(l_category_usage_rec.category_id <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CATEGORY_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_category_usage_rec.category_name)|| '"';
end if;
if ((l_category_usage_rec.show_all IS NOT NULL) and
(l_category_usage_rec.show_all <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      SHOW_ALL = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_category_usage_rec.show_all)|| '"';
end if;
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CREATED_BY = "' ||
nvl(to_char(l_category_usage_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CREATION_DATE = "' ||
to_char(l_category_usage_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
-- l_databuffer_tbl(l_index) := '      LAST_UPDATED_BY = "' ||
-- nvl(to_char(l_category_usage_rec.last_updated_by),'') || '"';
l_databuffer_tbl(l_index) := '      OWNER = "' ||
FND_LOAD_UTIL.OWNER_NAME(l_category_usage_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATE_DATE = "' ||
to_char(l_category_usage_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_category_usage_rec.last_update_login),'') || '"';

l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    END CATEGORY_USAGE';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';

-- - Write the 'END CATEGORY_USAGE' to the specified file
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);
-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_category_usages_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

end loop;
close l_get_category_usages_csr;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_CATEGORY_USAGE_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
p_region_code||' '||to_char(p_attribute_application_id)||
' '||p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_CATEGORY_USAGE_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
p_region_code||' '||to_char(p_attribute_application_id)||
' '||p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end WRITE_CAT_USAGES_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_LOV_RELATION_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given region
--              lov relation records to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure first retreives and writes the given
--              region to the loader file. Then it calls other local
--              procedure to write all its region items to the same output
--              file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the Region to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_LOV_RELATION_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN		 NUMBER,
p_attribute_code           IN      VARCHAR2,
p_lov_region_appl_id		 IN		 NUMBER,
p_lov_region_code			 IN		 VARCHAR2
) is
cursor l_get_lov_relations_csr is
select *
from  AK_REGION_LOV_RELATIONS
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code;
l_api_name           CONSTANT varchar2(30) := 'Write_lov_relation_to_buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_lov_relation_rec   AK_REGION_LOV_RELATIONS%ROWTYPE;
l_return_status      varchar2(1);
begin
-- Retrieve region information from the database

open l_get_lov_relations_csr;
loop
fetch l_get_lov_relations_csr into l_lov_relation_rec;
exit when l_get_lov_relations_csr%notfound;

-- Region lov relation must be validated before it is written to the file
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_REGION2_PVT.VALIDATE_LOV_RELATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => l_lov_relation_rec.region_application_id,
p_region_code => l_lov_relation_rec.region_code,
p_attribute_application_id => l_lov_relation_rec.attribute_application_id,
p_attribute_code => l_lov_relation_rec.attribute_code,
p_lov_region_appl_id => l_lov_relation_rec.lov_region_appl_id,
p_lov_region_code => l_lov_relation_rec.lov_region_code,
p_lov_attribute_appl_id => l_lov_relation_rec.lov_attribute_appl_id,
p_lov_attribute_code => l_lov_relation_rec.lov_attribute_code,
p_base_attribute_appl_id => l_lov_relation_rec.base_attribute_appl_id,
p_base_attribute_code => l_lov_relation_rec.base_attribute_code,
p_direction_flag => l_lov_relation_rec.direction_flag,
p_base_region_appl_id => l_lov_relation_rec.base_region_appl_id,
p_base_region_code => l_lov_relation_rec.base_region_code,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_LOV_RELATION_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
p_region_code);
FND_MSG_PUB.Add;
end if;
close l_get_lov_relations_csr;
raise FND_API.G_EXC_ERROR;
end if; /* if AK_REGION2_PVT.VALIDATE_LOV_RELATION */
end if; /* if p_validation_level */

-- Write region lov relation into buffer
-- write a blank line after region item
l_index := 1;
l_databuffer_tbl(l_index) := ' ';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    BEGIN REGION_LOV_RELATION "' ||
nvl(to_char(l_lov_relation_rec.lov_region_appl_id), '') || '" "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_lov_relation_rec.lov_region_code) || '" "'||
nvl(to_char(l_lov_relation_rec.lov_attribute_appl_id), '') || '" "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_lov_relation_rec.lov_attribute_code) || '" "'||
nvl(to_char(l_lov_relation_rec.base_attribute_appl_id), '') || '" "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_lov_relation_rec.base_attribute_code)|| '" "'||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_lov_relation_rec.direction_flag)|| '"';
if ((l_lov_relation_rec.base_region_appl_id IS NOT NULL) and
(l_lov_relation_rec.base_region_appl_id <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      BASE_REGION_APPL_ID = "' ||
nvl(to_char(l_lov_relation_rec.base_region_appl_id), '') || '"';
end if;
if ((l_lov_relation_rec.base_region_code IS NOT NULL) and
(l_lov_relation_rec.base_region_code <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      BASE_REGION_CODE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_lov_relation_rec.base_region_code) || '"';
end if;
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      REQUIRED_FLAG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_lov_relation_rec.required_flag) ||
'"';
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CREATED_BY = "' ||
nvl(to_char(l_lov_relation_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      CREATION_DATE = "' ||
to_char(l_lov_relation_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
-- l_databuffer_tbl(l_index) := '      LAST_UPDATED_BY = "' ||
-- nvl(to_char(l_lov_relation_rec.last_updated_by),'') || '"';
l_databuffer_tbl(l_index) := '      OWNER = "' ||
FND_LOAD_UTIL.OWNER_NAME(l_lov_relation_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATE_DATE = "' ||
to_char(l_lov_relation_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '      LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_lov_relation_rec.last_update_login),'') || '"';

l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    END REGION_LOV_RELATION';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';

-- - Write the 'END REGION_LOV_RELATION' to the specified file
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);
-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_lov_relations_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

end loop;
close l_get_lov_relations_csr;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_LOV_REGION_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
p_region_code||' '||to_char(p_attribute_application_id)||
' '||p_attribute_code||' '||to_char(p_lov_region_appl_id)||
' '||p_lov_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_LOV_RELATION_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
p_region_code||' '||to_char(p_attribute_application_id)||
' '||p_attribute_code||' '||to_char(p_lov_region_appl_id)||
' '||p_lov_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end WRITE_LOV_RELATION_TO_BUFFER;

/*
--=======================================================
--  Procedure   WRITE_GRAPH_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing all region graphs
--              for the given region to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure retrieves all Region Graphs
--              that belongs to the given region from the database,
--              and writes them to the output file
--              in loader file format.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the Region record whose region
--                  items are to be extracted to the loader file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_GRAPH_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_nls_language             IN      VARCHAR2
) is
cursor l_get_graphs_csr is
select *
from   AK_REGION_GRAPHS
where  REGION_APPLICATION_ID = p_region_application_id
and    REGION_CODE = p_region_code;
cursor l_get_graph_tl_csr (graph_number number) is
select *
from   AK_REGION_GRAPHS_TL
where  REGION_APPLICATION_ID = p_region_application_id
and    REGION_CODE = p_region_code
and    GRAPH_NUMBER = graph_number
and    LANGUAGE = p_nls_language;
cursor l_column_exists_csr ( region_appl_id_param number,
region_code_param varchar2,
graph_number_param number) is
select 1
from ak_region_graph_columns
where region_application_id = region_appl_id_param
and region_code = region_code_param
and graph_number = graph_number_param;

l_api_name           CONSTANT varchar2(30) := 'Write_Graph_to_buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_graphs_rec	       AK_REGION_GRAPHS%ROWTYPE;
l_graphs_tl_rec       AK_REGION_GRAPHS_TL%ROWTYPE;
l_return_status      varchar2(1);
l_write_column_flag boolean := false;
begin
-- Find out where the next buffer element to be written to
l_index := 1;

-- Retrieve region graph and its TL information from the database

open l_get_graphs_csr;
loop
fetch l_get_graphs_csr into l_graphs_rec;
exit when l_get_graphs_csr%notfound;
open l_get_graph_tl_csr(l_graphs_rec.graph_number);
fetch l_get_graph_tl_csr into l_graphs_tl_rec;
if l_get_graph_tl_csr%found then
-- write this region graph if it is validated
if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
not AK_REGION_PVT.VALIDATE_GRAPH (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => l_graphs_rec.region_application_id,
p_region_code => l_graphs_rec.region_code,
p_graph_number => l_graphs_rec.graph_number,
p_graph_style => l_graphs_Rec.graph_style,
p_display_flag => l_graphs_rec.display_flag,
p_depth_radius => l_graphs_rec.depth_radius,
p_graph_title => l_graphs_tl_rec.graph_title,
p_y_axis_label => l_graphs_tl_rec.y_axis_label,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(l_graphs_rec.graph_number));
FND_MSG_PUB.Add;
close l_get_graph_tl_csr;
close l_get_graphs_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

else
l_databuffer_tbl(l_index) := ' ';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  BEGIN REGION_GRAPH "' ||
l_graphs_rec.graph_number || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    GRAPH_STYLE = "' ||
nvl(to_char(l_graphs_rec.graph_style),'') || '"';
if ((l_graphs_rec.display_flag IS NOT NULL) and
(l_graphs_rec.display_flag <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DISPLAY_FLAG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_graphs_rec.display_flag)||
'"';
end if;
if ((l_graphs_rec.depth_radius IS NOT NULL) and
(l_graphs_rec.depth_radius <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DEPTH_RADIUS = "' ||
nvl(to_char(l_graphs_rec.depth_radius),'') || '"';
end if;
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CREATED_BY = "' ||
nvl(to_char(l_graphs_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CREATION_DATE = "' ||
to_char(l_graphs_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LAST_UPDATED_BY = "' ||
nvl(to_char(l_graphs_rec.last_updated_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LAST_UPDATE_DATE = "' ||
to_char(l_graphs_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_graphs_rec.last_update_login),'') || '"';

if ((l_graphs_tl_rec.graph_title IS NOT NULL) and
(l_graphs_tl_rec.graph_title <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    GRAPH_TITLE = "'||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_graphs_tl_rec.graph_title)||
'"';
end if;
if ((l_graphs_tl_rec.y_axis_label IS NOT NULL) and
(l_graphs_tl_rec.graph_title <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    Y_AXIS_LABEL = "'||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_graphs_tl_rec.y_axis_label)||
'"';
end if;

-- - Write the region graph data to the specified file
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);
-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_graph_tl_csr;
close l_get_graphs_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

l_databuffer_tbl.delete;

for l_chk_columns in l_column_exists_csr (p_region_application_id,
p_region_code, l_graphs_rec.graph_number) loop
l_write_column_flag := true;
end loop;
if l_write_column_flag then
WRITE_GRAPH_COL_TO_BUFFER(
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_graph_number => l_graphs_rec.graph_number
);
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_GRAPH_COL_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
-- RAISE FND_API.G_EXC_ERROR;
end if; -- end if l_write_column_flag

--
-- Download aborts if validation fails in WRITE_GRAPH_COL_TO_BUFFER
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

-- finish up region items
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  END REGION_GRAPH';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';
end if; -- validation OK

end if; -- if TL record found
close l_get_graph_tl_csr;

end loop;
close l_get_graphs_csr;

-- - Write region item data out to the specified file
--   don't call write_file if there are no items for this region

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
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || l_graphs_rec.graph_number);
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
end WRITE_GRAPH_TO_BUFFER;
*/

--=======================================================
--  Procedure   WRITE_ITEM_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing all region items
--              for the given region to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure retrieves all Region Items
--              that belongs to the given region from the database,
--              and writes them to the output file
--              in loader file format.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the Region record whose region
--                  items are to be extracted to the loader file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_ITEM_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_nls_language             IN      VARCHAR2
) is
cursor l_get_items_csr is
select *
from   AK_REGION_ITEMS
where  REGION_APPLICATION_ID = p_region_application_id
and    REGION_CODE = p_region_code;
cursor l_get_item_tl_csr (attribute_appl_id_param number,
attribute_code_param varchar2) is
select *
from   AK_REGION_ITEMS_TL
where  REGION_APPLICATION_ID = p_region_application_id
and    REGION_CODE = p_region_code
and    ATTRIBUTE_APPLICATION_ID = attribute_appl_id_param
and    ATTRIBUTE_CODE = attribute_code_param
and    LANGUAGE = p_nls_language;
cursor l_relation_exists_csr ( region_appl_id_param number,
region_code_param varchar2,
attribute_appl_id_param number,
attribute_code_param varchar2,
lov_region_appl_id_param number,
lov_region_code_param varchar2 ) is
select 1
from ak_region_lov_relations
where region_application_id = region_appl_id_param
and region_code = region_code_param
and attribute_application_id = attribute_appl_id_param
and attribute_code = attribute_code_param
and lov_region_appl_id = lov_region_appl_id_param
and lov_region_code = lov_region_code_param;
cursor l_category_usages_csr( region_appl_id_param number,
region_code_param varchar2,
attribute_appl_id_param number,
attribute_code_param varchar2) is
select 1
from ak_category_usages acu, ak_region_items ari
where acu.region_code = region_code_param
and acu.region_application_id = region_appl_id_param
and acu.attribute_code = attribute_code_param
and acu.attribute_application_id = attribute_appl_id_param
and ari.region_code = acu.region_code
and ari.region_application_id = acu.region_application_id
and ari.attribute_code = acu.attribute_code
and ari.attribute_application_id = acu.attribute_application_id
and ( ari.item_style = 'ATTACHMENT_IMAGE'
or ari.item_style = 'ATTACHMENT_LINK');

l_api_name           CONSTANT varchar2(30) := 'Write_Item_to_buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_items_rec          AK_REGION_ITEMS%ROWTYPE;
l_items_tl_rec       AK_REGION_ITEMS_TL%ROWTYPE;
l_return_status      varchar2(1);
l_write_relation_flag boolean := false;
l_write_category_usages_flag boolean := false;
begin
-- Find out where the next buffer element to be written to
l_index := 1;

-- Retrieve region item and its TL information from the database

open l_get_items_csr;
loop
fetch l_get_items_csr into l_items_rec;
exit when l_get_items_csr%notfound;
open l_get_item_tl_csr(l_items_rec.attribute_application_id,
l_items_rec.attribute_code);
fetch l_get_item_tl_csr into l_items_tl_rec;
if l_get_item_tl_csr%found then
-- write this region item if it is validated
if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) and
not AK_REGION_PVT.VALIDATE_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => l_items_rec.region_application_id,
p_region_code => l_items_rec.region_code,
p_attribute_application_id => l_items_rec.attribute_application_id,
p_attribute_code => l_items_rec.attribute_code,
p_display_sequence => l_items_rec.display_sequence,
p_node_display_flag => l_items_rec.node_display_flag,
p_node_query_flag => l_items_rec.node_query_flag,
p_attribute_label_length => l_items_rec.attribute_label_length,
p_display_value_length => l_items_rec.display_value_length,
p_bold => l_items_rec.bold,
p_italic => l_items_rec.italic,
p_vertical_alignment => l_items_rec.vertical_alignment,
p_horizontal_alignment => l_items_rec.horizontal_alignment,
p_item_style => l_items_rec.item_style,
p_object_attribute_flag => l_items_rec.object_attribute_flag,
p_icx_custom_call => l_items_rec.icx_custom_call,
p_update_flag => l_items_rec.update_flag,
p_required_flag => l_items_rec.required_flag,
p_security_code => l_items_rec.security_code,
p_default_value_varchar2 => l_items_rec.default_value_varchar2,
p_default_value_number => l_items_rec.default_value_number,
p_default_value_date => l_items_rec.default_value_date,
p_nested_region_appl_id => l_items_rec.nested_region_application_id,
p_nested_region_code => l_items_rec.nested_region_code,
p_lov_region_application_id =>
l_items_rec.lov_region_application_id,
p_lov_region_code => l_items_rec.lov_region_code,
p_lov_foreign_key_name => l_items_rec.lov_foreign_key_name,
p_lov_attribute_application_id =>
l_items_rec.lov_attribute_application_id,
p_lov_attribute_code => l_items_rec.lov_attribute_code,
p_lov_default_flag => l_items_rec.lov_default_flag,
p_region_defaulting_api_pkg =>
l_items_rec.region_defaulting_api_pkg,
p_region_defaulting_api_proc =>
l_items_rec.region_defaulting_api_proc,
p_region_validation_api_pkg =>
l_items_rec.region_validation_api_pkg,
p_region_validation_api_proc =>
l_items_rec.region_validation_api_proc,
p_order_sequence => l_items_rec.order_sequence,
p_order_direction => l_items_rec.order_direction,
p_menu_name => l_items_rec.menu_name,
p_flexfield_name => l_items_rec.flexfield_name,
p_flexfield_application_id => l_items_rec.flexfield_application_id,
p_tabular_function_code    => l_items_rec.tabular_function_code,
p_tip_type                 => l_items_rec.tip_type,
p_tip_message_name         => l_items_rec.tip_message_name,
p_tip_message_application_id  => l_items_rec.tip_message_application_id ,
p_flex_segment_list        => l_items_rec.flex_segment_list,
p_entity_id  => l_items_rec.entity_id ,
p_anchor     => l_items_rec.anchor,
p_poplist_view_usage_name => l_items_rec.poplist_view_usage_name,
p_user_customizable => l_items_rec.user_customizable,
p_sortby_view_attribute_name => l_items_rec.sortby_view_attribute_name,
p_invoke_function_name => l_items_rec.invoke_function_name,
p_expansion => l_items_rec.expansion,
p_als_max_length => l_items_rec.als_max_length,
p_initial_sort_sequence => l_items_rec.initial_sort_sequence,
p_customization_application_id => l_items_rec.customization_application_id,
p_customization_code => l_items_rec.customization_code,
p_attribute_label_long => l_items_tl_rec.attribute_label_long,
p_attribute_label_short => l_items_tl_rec.attribute_label_short,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(l_items_rec.attribute_application_id) ||
' ' || l_items_rec.attribute_code);
FND_MSG_PUB.Add;
close l_get_item_tl_csr;
close l_get_items_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

else
l_databuffer_tbl(l_index) := ' ';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  BEGIN REGION_ITEM "' ||
l_items_rec.attribute_application_id || '" "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_items_rec.attribute_code) ||
'"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DISPLAY_SEQUENCE = "' ||
nvl(to_char(l_items_rec.display_sequence),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    NODE_DISPLAY_FLAG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_items_rec.node_display_flag)||
'"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    NODE_QUERY_FLAG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_items_rec.node_query_flag) ||
'"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE_LABEL_LENGTH = "' ||
nvl(to_char(l_items_rec.attribute_label_length),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DISPLAY_VALUE_LENGTH = "' ||
nvl(to_char(l_items_rec.display_value_length),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    BOLD = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_items_rec.bold) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ITALIC = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_items_rec.italic) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    VERTICAL_ALIGNMENT = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_items_rec.vertical_alignment)
|| '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    HORIZONTAL_ALIGNMENT = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.horizontal_alignment)|| '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ITEM_STYLE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_items_rec.item_style) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    OBJECT_ATTRIBUTE_FLAG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.object_attribute_flag) || '"';

if ((l_items_rec.icx_custom_call IS NOT NULL) and
(l_items_rec.icx_custom_call <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ICX_CUSTOM_CALL = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.icx_custom_call) || '"';
end if;

l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    UPDATE_FLAG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.update_flag) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    REQUIRED_FLAG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.required_flag) || '"';
if ((l_items_rec.security_code IS NOT NULL) and
(l_items_rec.security_code <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    SECURITY_CODE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.security_code) || '"';
end if;
if ((l_items_rec.default_value_varchar2 IS NOT NULL) and
(l_items_rec.default_value_varchar2 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DEFAULT_VALUE_VARCHAR2 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.default_value_varchar2) || '"';
end if;
if ((l_items_rec.default_value_number IS NOT NULL) and
(l_items_rec.default_value_number <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DEFAULT_VALUE_NUMBER = "' ||
nvl(to_char(l_items_rec.default_value_number),'') || '"';
end if;
if ((l_items_rec.default_value_date IS NOT NULL) and
(l_items_rec.default_value_date <> FND_API.G_MISS_DATE)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DEFAULT_VALUE_DATE = "' ||
to_char(l_items_rec.default_value_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
end if;
if ((l_items_rec.lov_region_application_id IS NOT NULL) and
(l_items_rec.lov_region_application_id <> FND_API.G_MISS_NUM) and
(l_items_rec.lov_region_code IS NOT NULL) and
(l_items_rec.lov_region_code <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LOV_REGION = "' ||
nvl(to_char(l_items_rec.lov_region_application_id),'')||'" "'||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.lov_region_code)|| '"';
end if;
if ((l_items_rec.lov_foreign_key_name IS NOT NULL) and
(l_items_rec.lov_foreign_key_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LOV_FOREIGN_KEY_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.lov_foreign_key_name)|| '"';
end if;
if ((l_items_rec.lov_attribute_application_id IS NOT NULL) and
(l_items_rec.lov_attribute_application_id <> FND_API.G_MISS_NUM) and
(l_items_rec.lov_attribute_code IS NOT NULL) and
(l_items_rec.lov_attribute_code <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LOV_ATTRIBUTE = "' ||
nvl(to_char(l_items_rec.lov_attribute_application_id),'')||'" "'||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.lov_attribute_code)|| '"';
end if;
if ((l_items_rec.lov_default_flag IS NOT NULL) and
(l_items_rec.lov_default_flag <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LOV_DEFAULT_FLAG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.lov_default_flag)|| '"';
end if;
if ((l_items_rec.region_defaulting_api_pkg IS NOT NULL) and
(l_items_rec.region_defaulting_api_pkg <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    REGION_DEFAULTING_API_PKG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.region_defaulting_api_pkg)|| '"';
end if;
if ((l_items_rec.region_defaulting_api_proc IS NOT NULL) and
(l_items_rec.region_defaulting_api_proc <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    REGION_DEFAULTING_API_PROC = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.region_defaulting_api_proc)|| '"';
end if;
if ((l_items_rec.region_validation_api_pkg IS NOT NULL) and
(l_items_rec.region_validation_api_pkg <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    REGION_VALIDATION_API_PKG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.region_validation_api_pkg)|| '"';
end if;
if ((l_items_rec.region_validation_api_proc IS NOT NULL) and
(l_items_rec.region_validation_api_proc <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    REGION_VALIDATION_API_PROC = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.region_validation_api_proc) || '"';
end if;
if ((l_items_rec.order_sequence IS NOT NULL) and
(l_items_rec.order_sequence <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ORDER_SEQUENCE = "' ||
nvl(to_char(l_items_rec.order_sequence),'') || '"';
end if;
if ((l_items_rec.order_direction IS NOT NULL) and
(l_items_rec.order_direction <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ORDER_DIRECTION = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.order_direction)|| '"';
end if;

-- new columns for JSP renderer
if ((l_items_rec.display_height IS NOT NULL) and
(l_items_rec.display_height <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DISPLAY_HEIGHT = "' ||
nvl(to_char(l_items_rec.display_height),'') || '"';
end if;
if ((l_items_rec.submit IS NOT NULL) and
(l_items_rec.submit <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    SUBMIT = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.submit)|| '"';
end if;
if ((l_items_rec.encrypt IS NOT NULL) and
(l_items_rec.encrypt <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ENCRYPT = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.encrypt)|| '"';
end if;
if ((l_items_rec.css_class_name IS NOT NULL) and
(l_items_rec.css_class_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CSS_CLASS_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.css_class_name)|| '"';
end if;
if ((l_items_rec.view_usage_name IS NOT NULL) and
(l_items_rec.view_usage_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    VIEW_USAGE_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.view_usage_name)|| '"';
end if;
if ((l_items_rec.view_attribute_name IS NOT NULL) and
(l_items_rec.view_attribute_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    VIEW_ATTRIBUTE_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.view_attribute_name)|| '"';
end if;
if ((l_items_rec.nested_region_application_id IS NOT NULL) and
(l_items_rec.nested_region_application_id <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    NESTED_REGION_APPLICATION_ID = "' ||
nvl(to_char(l_items_rec.nested_region_application_id),'') || '"';
end if;
if ((l_items_rec.nested_region_code IS NOT NULL) and
(l_items_rec.nested_region_code <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    NESTED_REGION_CODE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.nested_region_code)|| '"';
end if;
if ((l_items_rec.url IS NOT NULL) and
(l_items_rec.url <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    URL = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.url)|| '"';
end if;
if ((l_items_rec.poplist_viewobject IS NOT NULL) and
(l_items_rec.poplist_viewobject <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    POPLIST_VIEWOBJECT = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.poplist_viewobject)|| '"';
end if;
if ((l_items_rec.poplist_display_attribute IS NOT NULL) and
(l_items_rec.poplist_display_attribute <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    POPLIST_DISPLAY_ATTRIBUTE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.poplist_display_attribute)|| '"';
end if;
if ((l_items_rec.poplist_value_attribute IS NOT NULL) and
(l_items_rec.poplist_value_attribute <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    POPLIST_VALUE_ATTRIBUTE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.poplist_value_attribute)|| '"';
end if;
if ((l_items_rec.image_file_name IS NOT NULL) and
(l_items_rec.image_file_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    IMAGE_FILE_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.image_file_name)|| '"';
end if;
if ((l_items_rec.item_name IS NOT NULL) and
(l_items_rec.item_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ITEM_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.item_name)|| '"';
end if;
if ((l_items_rec.css_label_class_name IS NOT NULL) and
(l_items_rec.css_label_class_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CSS_LABEL_CLASS_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.css_label_class_name)|| '"';
end if;
if ((l_items_rec.menu_name IS NOT NULL) and
(l_items_rec.menu_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    MENU_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.menu_name)|| '"';
end if;
-- Flexfield References for region items that point at flex definitions
if ((l_items_rec.flexfield_name IS NOT NULL) and
(l_items_rec.flexfield_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    FLEXFIELD_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.flexfield_name)|| '"';
end if;
if ((l_items_rec.flexfield_application_id IS NOT NULL) and
(l_items_rec.flexfield_application_id <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    FLEXFIELD_APPLICATION_ID = "' ||
nvl(to_char(l_items_rec.flexfield_application_id),'') || '"';
end if;

-- Tabular Function Code
if ((l_items_rec.tabular_function_code IS NOT NULL) and
(l_items_rec.tabular_function_code <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    TABULAR_FUNCTION_CODE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.tabular_function_code)|| '"';
end if;

-- Tip Type
if ((l_items_rec.tip_type IS NOT NULL) and
(l_items_rec.tip_type <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    TIP_TYPE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.tip_type)|| '"';
end if;

-- Tip Message
if ((l_items_rec.tip_message_name IS NOT NULL) and
(l_items_rec.tip_message_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    TIP_MESSAGE_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.tip_message_name)|| '"';
end if;
if ((l_items_rec.tip_message_application_id IS NOT NULL) and
(l_items_rec.tip_message_application_id <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    TIP_MESSAGE_APPLICATION_ID = "' ||
nvl(to_char(l_items_rec.tip_message_application_id),'') || '"';
end if;

-- Flex segment_list
if ((l_items_rec.flex_segment_list IS NOT NULL) and
(l_items_rec.flex_segment_list <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    FLEX_SEGMENT_LIST = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.flex_segment_list)|| '"';
end if;

-- Entity Id
if ((l_items_rec.entity_id IS NOT NULL) and
(l_items_rec.entity_id <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ENTITY_ID = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.entity_id)|| '"';
end if;

-- Anchor
if ((l_items_rec.anchor IS NOT NULL) and
(l_items_rec.anchor <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ANCHOR = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.anchor)|| '"';
end if;

-- Poplist view usage name
if ((l_items_rec.poplist_view_usage_name IS NOT NULL) and
(l_items_rec.poplist_view_usage_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    POPLIST_VIEW_USAGE_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.poplist_view_usage_name)|| '"';
end if;

-- User Customizable
if ((l_items_rec.user_customizable IS NOT NULL) and
(l_items_rec.user_customizable <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    USER_CUSTOMIZABLE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.user_customizable)|| '"';
end if;

-- Sortby view attribute name
if ((l_items_rec.sortby_view_attribute_name IS NOT NULL) and
(l_items_rec.sortby_view_attribute_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    SORTBY_VIEW_ATTRIBUTE_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.sortby_view_attribute_name)|| '"';
end if;

-- Admin Customizable
if ((l_items_rec.admin_customizable IS NOT NULL) and
(l_items_rec.admin_customizable <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ADMIN_CUSTOMIZABLE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.admin_customizable)|| '"';
end if;

-- Invoke Function Name
if ((l_items_rec.invoke_function_name IS NOT NULL) and
(l_items_rec.invoke_function_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    INVOKE_FUNCTION_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.invoke_function_name)|| '"';
end if;

-- Expansion
if ((l_items_rec.expansion IS NOT NULL) and
(l_items_rec.expansion <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    EXPANSION = "' ||
nvl(to_char(l_items_rec.expansion),'') || '"';
end if;

-- ALS Max Length
if ((l_items_rec.als_max_length IS NOT NULL) and
(l_items_rec.als_max_length <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ALS_MAX_LENGTH = "' ||
nvl(to_char(l_items_rec.als_max_length),'') || '"';
end if;

-- INITIAL_SORT_SEQUENCE
if ((l_items_rec.initial_sort_sequence IS NOT NULL) and
(l_items_rec.initial_sort_sequence <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    INITIAL_SORT_SEQUENCE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.initial_sort_sequence)|| '"';
end if;

-- CUSTOMIZATION_APPLICATION_ID
if ((l_items_rec.customization_application_id IS NOT NULL) and
(l_items_rec.customization_application_id <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CUSTOMIZATION_APPLICATION_ID = "' ||
nvl(to_char(l_items_rec.customization_application_id),'') || '"';
end if;

-- CUSTOMIZATION_CODE
if ((l_items_rec.customization_code IS NOT NULL) and
(l_items_rec.customization_code <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CUSTOMIZATION_CODE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.customization_code)|| '"';
end if;


-- Flex Field Columns
--
if ((l_items_rec.attribute_category IS NOT NULL) and
(l_items_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE_CATEGORY = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute_category) || '"';
end if;
if ((l_items_rec.attribute1 IS NOT NULL) and
(l_items_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE1 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute1) || '"';
end if;
if ((l_items_rec.attribute2 IS NOT NULL) and
(l_items_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE2 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute2) || '"';
end if;
if ((l_items_rec.attribute3 IS NOT NULL) and
(l_items_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE3 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute3) || '"';
end if;
if ((l_items_rec.attribute4 IS NOT NULL) and
(l_items_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE4 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute4) || '"';
end if;
if ((l_items_rec.attribute5 IS NOT NULL) and
(l_items_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE5 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute5) || '"';
end if;
if ((l_items_rec.attribute6 IS NOT NULL) and
(l_items_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE6 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute6) || '"';
end if;
if ((l_items_rec.attribute7 IS NOT NULL) and
(l_items_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE7 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute7) || '"';
end if;
if ((l_items_rec.attribute8 IS NOT NULL) and
(l_items_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE8 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute8) || '"';
end if;
if ((l_items_rec.attribute9 IS NOT NULL) and
(l_items_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE9 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute9) || '"';
end if;
if ((l_items_rec.attribute10 IS NOT NULL) and
(l_items_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE10 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute10) || '"';
end if;
if ((l_items_rec.attribute11 IS NOT NULL) and
(l_items_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE11 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute11) || '"';
end if;
if ((l_items_rec.attribute12 IS NOT NULL) and
(l_items_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE12 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute12) || '"';
end if;
if ((l_items_rec.attribute13 IS NOT NULL) and
(l_items_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE13 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute13) || '"';
end if;
if ((l_items_rec.attribute14 IS NOT NULL) and
(l_items_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE14 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute14) || '"';
end if;
if ((l_items_rec.attribute15 IS NOT NULL) and
(l_items_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE15 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_rec.attribute15) || '"';
end if;
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CREATED_BY = "' ||
nvl(to_char(l_items_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    CREATION_DATE = "' ||
to_char(l_items_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--l_databuffer_tbl(l_index) := '    LAST_UPDATED_BY = "' ||
--nvl(to_char(l_items_rec.last_updated_by),'') || '"';
l_databuffer_tbl(l_index) := '    OWNER = "' ||
FND_LOAD_UTIL.OWNER_NAME(l_items_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LAST_UPDATE_DATE = "' ||
to_char(l_items_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_items_rec.last_update_login),'') || '"';

-- TL table entries
if ((l_items_tl_rec.attribute_label_long IS NOT NULL) and
(l_items_tl_rec.attribute_label_long <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE_LABEL_LONG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_tl_rec.attribute_label_long)|| '"';
end if;
if ((l_items_tl_rec.attribute_label_short IS NOT NULL) and
(l_items_tl_rec.attribute_label_short <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    ATTRIBUTE_LABEL_SHORT = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_tl_rec.attribute_label_short)|| '"';
end if;
if ((l_items_tl_rec.description IS NOT NULL) and
(l_items_tl_rec.description <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '    DESCRIPTION = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_items_tl_rec.description)|| '"';
end if;

-- - Write the region item data to the specified file
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);
-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_item_tl_csr;
close l_get_items_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

l_databuffer_tbl.delete;

if ( l_items_rec.lov_region_application_id is not null and
l_items_rec.lov_region_code is not null ) then
for l_chk_relation_csr in l_relation_exists_csr (p_region_application_id, p_region_code, l_items_rec.attribute_application_id, l_items_rec.attribute_code, l_items_rec.lov_region_application_id, l_items_rec.lov_region_code ) loop
l_write_relation_flag := true;
end loop;
if l_write_relation_flag then
WRITE_LOV_RELATION_TO_BUFFER(
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => l_items_rec.attribute_application_id,
p_attribute_code => l_items_rec.attribute_code,
p_lov_region_appl_id => l_items_rec.lov_region_application_id,
p_lov_region_code => l_items_rec.lov_region_code
);
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_LOV_RELATION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
-- RAISE FND_API.G_EXC_ERROR;
end if; -- end if l_write_relation_flag
end if;

for l_chk_category_usages in l_category_usages_csr (p_region_application_id, p_region_code, l_items_rec.attribute_application_id, l_items_rec.attribute_code) loop
l_write_category_usages_flag := true;
end loop;
if l_write_category_usages_flag then
WRITE_CAT_USAGES_TO_BUFFER(
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => l_items_rec.attribute_application_id,
p_attribute_code => l_items_rec.attribute_code
);
end if; -- end if l_write_category_usages_flag

--
-- Download aborts if validation fails in WRITE_CAT_USAGES_TO_BUFFER
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_item_tl_csr;
close l_get_items_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

-- finish up region items
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  END REGION_ITEM';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';
end if; -- validation OK

end if; -- if TL record found
close l_get_item_tl_csr;

end loop;
close l_get_items_csr;

-- - Write region item data out to the specified file
--   don't call write_file if there are no items for this region

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
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(l_items_rec.attribute_application_id) ||
' ' || l_items_rec.attribute_code);
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
end WRITE_ITEM_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given region
--              and all its children records to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure first retreives and writes the given
--              region to the loader file. Then it calls other local
--              procedure to write all its region items to the same output
--              file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the Region to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_nls_language             IN      VARCHAR2
) is
cursor l_get_region_csr is
select *
from  AK_REGIONS
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code;
cursor l_get_region_tl_csr is
select *
from  AK_REGIONS_TL
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   LANGUAGE = p_nls_language;
l_api_name           CONSTANT varchar2(30) := 'Write_to_buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_regions_rec        AK_REGIONS%ROWTYPE;
l_regions_tl_rec     AK_REGIONS_TL%ROWTYPE;
l_return_status      varchar2(1);
begin
-- Retrieve region information from the database

open l_get_region_csr;
fetch l_get_region_csr into l_regions_rec;
if (l_get_region_csr%notfound) then
close l_get_region_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REGION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Cannot find region '||p_region_code);
RAISE FND_API.G_EXC_ERROR;
end if;
close l_get_region_csr;

-- Retrieve region TL information from the database

open l_get_region_tl_csr;
fetch l_get_region_tl_csr into l_regions_tl_rec;
if (l_get_region_tl_csr%notfound) then
close l_get_region_tl_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REGION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Cannot find region TL '||p_region_code);
RAISE FND_API.G_EXC_ERROR;
end if;
close l_get_region_tl_csr;

-- Region must be validated before it is written to the file
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_REGION_PVT.VALIDATE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => l_regions_rec.region_application_id,
p_region_code => l_regions_rec.region_code,
p_database_object_name => l_regions_rec.database_object_name,
p_region_style => l_regions_rec.region_style,
p_icx_custom_call => l_regions_rec.icx_custom_call,
p_num_columns => l_regions_rec.num_columns,
p_region_defaulting_api_pkg => l_regions_rec.region_defaulting_api_pkg,
p_region_defaulting_api_proc =>
l_regions_rec.region_defaulting_api_proc,
p_region_validation_api_pkg => l_regions_rec.region_validation_api_pkg,
p_region_validation_api_proc =>
l_regions_rec.region_validation_api_proc,
p_name => l_regions_tl_rec.name,
p_description => l_regions_tl_rec.description,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
then
--  dbms_output.put_line('Region ' || p_region_code
--  || ' not downloaded due to validation error');
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REGION_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||' '||
p_region_code);
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if; /* if AK_REGION_PVT.VALIDATE_REGION */
end if; /* if p_validation_level */

-- Write region into buffer
l_index := 1;

l_databuffer_tbl(l_index) := 'BEGIN REGION "' ||
nvl(to_char(p_region_application_id), '') || '" "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(p_region_code) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  DATABASE_OBJECT_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_regions_rec.database_object_name)
|| '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  REGION_STYLE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_regions_rec.region_style) || '"';
if ((l_regions_rec.num_columns IS NOT NULL) and
(l_regions_rec.num_columns <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  NUM_COLUMNS = "' ||
nvl(to_char(l_regions_rec.num_columns), '') || '"';
end if;
if ((l_regions_rec.icx_custom_call IS NOT NULL) and
(l_regions_rec.icx_custom_call <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ICX_CUSTOM_CALL = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_regions_rec.icx_custom_call)||'"';
end if;
if ((l_regions_rec.region_defaulting_api_pkg IS NOT NULL) and
(l_regions_rec.region_defaulting_api_pkg <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  REGION_DEFAULTING_API_PKG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.region_defaulting_api_pkg)|| '"';
end if;
if ((l_regions_rec.region_defaulting_api_proc IS NOT NULL) and
(l_regions_rec.region_defaulting_api_proc <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  REGION_DEFAULTING_API_PROC = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.region_defaulting_api_proc)|| '"';
end if;
if ((l_regions_rec.region_validation_api_pkg IS NOT NULL) and
(l_regions_rec.region_validation_api_pkg <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  REGION_VALIDATION_API_PKG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.region_validation_api_pkg)|| '"';
end if;
if ((l_regions_rec.region_validation_api_proc IS NOT NULL) and
(l_regions_rec.region_validation_api_proc <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  REGION_VALIDATION_API_PROC = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.region_validation_api_proc)|| '"';
end if;
if ((l_regions_rec.applicationmodule_object_type IS NOT NULL) and
(l_regions_rec.applicationmodule_object_type <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  APPLICATIONMODULE_OBJECT_TYPE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.applicationmodule_object_type)|| '"';
end if;
if ((l_regions_rec.num_rows_display IS NOT NULL) and
(l_regions_rec.num_rows_display <> FND_API.G_MISS_NUM)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  NUM_ROWS_DISPLAY = "' ||
nvl(to_char(l_regions_rec.num_rows_display), '') || '"';
end if;
if ((l_regions_rec.region_object_type IS NOT NULL) and
(l_regions_rec.region_object_type <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  REGION_OBJECT_TYPE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.region_object_type)|| '"';
end if;
if ((l_regions_rec.image_file_name IS NOT NULL) and
(l_regions_rec.image_file_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  IMAGE_FILE_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.image_file_name)|| '"';
end if;
if ((l_regions_rec.isform_flag IS NOT NULL) and
(l_regions_rec.isform_flag <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ISFORM_FLAG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.isform_flag)|| '"';
end if;
if ((l_regions_rec.help_target IS NOT NULL) and
(l_regions_rec.help_target <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  HELP_TARGET = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.help_target)|| '"';
end if;
if ((l_regions_rec.style_sheet_filename IS NOT NULL) and
(l_regions_rec.style_sheet_filename <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  STYLE_SHEET_FILENAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.style_sheet_filename)|| '"';
end if;
if ((l_regions_rec.version IS NOT NULL) and
(l_regions_rec.version <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  VERSION = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.version)|| '"';
end if;
if ((l_regions_rec.applicationmodule_usage_name IS NOT NULL) and
(l_regions_rec.applicationmodule_usage_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  APPLICATIONMODULE_USAGE_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.applicationmodule_usage_name)|| '"';
end if;
if ((l_regions_rec.add_indexed_children IS NOT NULL) and
(l_regions_rec.add_indexed_children <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ADD_INDEXED_CHILDREN = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.add_indexed_children)|| '"';
end if;
if ((l_regions_rec.stateful_flag IS NOT NULL) and
(l_regions_rec.stateful_flag <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  STATEFUL_FLAG = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.stateful_flag)|| '"';
end if;
if ((l_regions_rec.function_name IS NOT NULL) and
(l_regions_rec.function_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  FUNCTION_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.function_name)|| '"';
end if;
if ((l_regions_rec.children_view_usage_name IS NOT NULL) and
(l_regions_rec.children_view_usage_name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  CHILDREN_VIEW_USAGE_NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.children_view_usage_name)|| '"';
end if;
if ((l_regions_rec.search_panel IS NOT NULL) and
(l_regions_rec.search_panel <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  SEARCH_PANEL = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.search_panel)|| '"';
end if;
if ((l_regions_rec.advanced_search_panel IS NOT NULL) and
(l_regions_rec.advanced_search_panel <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ADVANCED_SEARCH_PANEL = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.advanced_search_panel)|| '"';
end if;
if ((l_regions_rec.customize_panel IS NOT NULL) and
(l_regions_rec.customize_panel <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  CUSTOMIZE_PANEL = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.customize_panel)|| '"';
end if;
if ((l_regions_rec.default_search_panel IS NOT NULL) and
(l_regions_rec.default_search_panel <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  DEFAULT_SEARCH_PANEL = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.default_search_panel)|| '"';
end if;
if ((l_regions_rec.results_based_search IS NOT NULL) and
(l_regions_rec.results_based_search <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  RESULTS_BASED_SEARCH = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.results_based_search)|| '"';
end if;
if ((l_regions_rec.display_graph_table IS NOT NULL) and
(l_regions_rec.display_graph_table <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  DISPLAY_GRAPH_TABLE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.display_graph_table)|| '"';
end if;
if ((l_regions_rec.disable_header IS NOT NULL) and
(l_regions_rec.disable_header <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  DISABLE_HEADER = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.disable_header)|| '"';
end if;
if ((l_regions_rec.standalone IS NOT NULL) and
(l_regions_rec.standalone <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  STANDALONE = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.standalone)|| '"';
end if;
if ((l_regions_rec.auto_customization_criteria IS NOT NULL) and
(l_regions_rec.auto_customization_criteria <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  AUTO_CUSTOMIZATION_CRITERIA = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.auto_customization_criteria)|| '"';
end if;

-- Flex Fields
--
if ((l_regions_rec.attribute_category IS NOT NULL) and
(l_regions_rec.attribute_category <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE_CATEGORY = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute_category) || '"';
end if;
if ((l_regions_rec.attribute1 IS NOT NULL) and
(l_regions_rec.attribute1 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE1 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute1) || '"';
end if;
if ((l_regions_rec.attribute2 IS NOT NULL) and
(l_regions_rec.attribute2 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE2 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute2) || '"';
end if;
if ((l_regions_rec.attribute3 IS NOT NULL) and
(l_regions_rec.attribute3 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE3 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute3) || '"';
end if;
if ((l_regions_rec.attribute4 IS NOT NULL) and
(l_regions_rec.attribute4 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE4 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute4) || '"';
end if;
if ((l_regions_rec.attribute5 IS NOT NULL) and
(l_regions_rec.attribute5 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE5 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute5) || '"';
end if;
if ((l_regions_rec.attribute6 IS NOT NULL) and
(l_regions_rec.attribute6 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE6 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute6) || '"';
end if;
if ((l_regions_rec.attribute7 IS NOT NULL) and
(l_regions_rec.attribute7 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE7 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute7) || '"';
end if;
if ((l_regions_rec.attribute8 IS NOT NULL) and
(l_regions_rec.attribute8 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE8 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute8) || '"';
end if;
if ((l_regions_rec.attribute9 IS NOT NULL) and
(l_regions_rec.attribute9 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE9 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute9) || '"';
end if;
if ((l_regions_rec.attribute10 IS NOT NULL) and
(l_regions_rec.attribute10 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE10 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute10) || '"';
end if;
if ((l_regions_rec.attribute11 IS NOT NULL) and
(l_regions_rec.attribute11 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE11 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute11) || '"';
end if;
if ((l_regions_rec.attribute12 IS NOT NULL) and
(l_regions_rec.attribute12 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE12 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute12) || '"';
end if;
if ((l_regions_rec.attribute13 IS NOT NULL) and
(l_regions_rec.attribute13 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE13 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute13) || '"';
end if;
if ((l_regions_rec.attribute14 IS NOT NULL) and
(l_regions_rec.attribute14 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE14 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute14) || '"';
end if;
if ((l_regions_rec.attribute15 IS NOT NULL) and
(l_regions_rec.attribute15 <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  ATTRIBUTE15 = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
l_regions_rec.attribute15) || '"';
end if;
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  CREATED_BY = "' ||
nvl(to_char(l_regions_rec.created_by),'') || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  CREATION_DATE = "' ||
to_char(l_regions_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
-- l_databuffer_tbl(l_index) := '  LAST_UPDATED_BY = "' ||
-- nvl(to_char(l_regions_rec.last_updated_by),'') || '"';
l_databuffer_tbl(l_index) := '  OWNER = "' ||
FND_LOAD_UTIL.OWNER_NAME(l_regions_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  LAST_UPDATE_DATE = "' ||
to_char(l_regions_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  LAST_UPDATE_LOGIN = "' ||
nvl(to_char(l_regions_rec.last_update_login),'') || '"';

-- translation columns
--
if ((l_regions_tl_rec.name IS NOT NULL) and
(l_regions_tl_rec.name <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  NAME = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_regions_tl_rec.name)||'"';
end if;
if ((l_regions_tl_rec.description IS NOT NULL) and
(l_regions_tl_rec.description <> FND_API.G_MISS_CHAR)) then
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  DESCRIPTION = "' ||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_regions_tl_rec.description)||'"';
end if;

-- - Write the region data to the specified file
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

WRITE_ITEM_TO_BUFFER (
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_region_application_id => l_regions_rec.region_application_id,
p_region_code => l_regions_rec.region_code,
p_nls_language => p_nls_language
);
--
-- Download aborts if validation fails in WRITE_ITEM_TO_BUFFER
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

/*
WRITE_GRAPH_TO_BUFFER (
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_region_application_id => l_regions_rec.region_application_id,
p_region_code => l_regions_rec.region_code,
p_nls_language => p_nls_language
);
*/

if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

l_index := 1;
l_databuffer_tbl(l_index) := 'END REGION';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';

-- - Write the 'END REGION' to the specified file
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
FND_MESSAGE.SET_NAME('AK','AK_REGION_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REGION_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end WRITE_TO_BUFFER;

/*
--=======================================================
--  Procedure   CREATE_GRAPH
--
--  Usage       Private API for creating a region graph. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region graph using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_GRAPH (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_graph_number	     IN	     NUMBER := FND_API.G_MISS_NUM,
p_graph_style		     IN      NUMBER := FND_API.G_MISS_NUM,
p_display_flag	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_depth_radius	     IN      NUMBER := FND_API.G_MISS_NUM,
p_graph_title		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_y_axis_label	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
l_api_name                CONSTANT varchar2(30) := 'Create_Graph';
l_created_by			NUMBER;
l_creation_date		DATE;
l_last_update_date		DATE;
l_last_update_login		NUMBER;
l_last_updated_by		NUMBER;
l_y_axis_label		VARCHAR2(80);
l_graph_title			VARCHAR2(240);
l_depth_radius		NUMBER(15);
l_display_flag		VARCHAR2(1);
l_graph_style			NUMBER(15);
l_graph_number		NUMBER(15);
l_return_status		VARCHAR2(1);
l_lang			VARCHAR2(30);
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

savepoint start_create_graph;

--** check to see if row already exists **
if AK_REGION_PVT.GRAPH_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_graph_number => p_graph_number) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_EXISTS');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || 'Error - row already exists');
raise FND_API.G_EXC_ERROR;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not VALIDATE_GRAPH (
p_validation_level => p_validation_level,
p_api_version_number => p_api_version_number,
p_return_status => p_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_graph_number => p_graph_number,
p_graph_style => p_graph_style,
p_display_flag => p_display_flag,
p_depth_radius => p_depth_radius,
p_graph_title => p_graph_title,
p_y_axis_label => p_y_axis_label,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

--** Load non-required columns if their values are given **
if (p_depth_radius <> FND_API.G_MISS_NUM) then
l_depth_radius := p_depth_radius;
end if;

if (p_graph_title <> FND_API.G_MISS_CHAR) then
l_graph_title := p_graph_title;
end if;

if (p_y_axis_label <> FND_API.G_MISS_CHAR) then
l_y_axis_label := p_y_axis_label;
end if;

-- Create record if no validation error was found

-- Set WHO columns
AK_UPLOAD_GRP.G_UPLOAD_DATE := p_last_update_date;
AK_ON_OBJECTS_PVT.SET_WHO (
p_return_status => l_return_status,
p_loader_timestamp => p_loader_timestamp,
p_created_by => l_created_by,
p_creation_date => l_creation_date,
p_last_updated_by => l_last_updated_by,
p_last_update_date => l_last_update_date,
p_last_update_login => l_last_update_login);

  if (AK_UPLOAD_GRP.G_NON_SEED_DATA) then
        l_created_by := p_created_by;
        l_last_updated_by := p_last_updated_by;
        l_last_update_login := p_last_update_login;
  end if;

select userenv('LANG') into l_lang
from dual;

insert into AK_REGION_GRAPHS (
REGION_APPLICATION_ID,
REGION_CODE,
GRAPH_NUMBER,
GRAPH_STYLE,
DISPLAY_FLAG,
DEPTH_RADIUS,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN
) values (
p_region_application_id,
p_region_code,
p_graph_number,
p_graph_style,
p_display_flag,
l_depth_radius,
l_creation_date,
l_created_by,
l_last_update_date,
l_last_updated_by,
l_last_update_login
);

--** row should exists before inserting rows for other languages **
if NOT AK_REGION_PVT.GRAPH_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_graph_number => p_graph_number) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_INSERT_REG_GRAPH_FAILED');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || 'Error - row already exists');
raise FND_API.G_EXC_ERROR;
end if;

insert into AK_REGION_GRAPHS_TL (
REGION_APPLICATION_ID,
REGION_CODE,
GRAPH_NUMBER,
LANGUAGE,
GRAPH_TITLE,
Y_AXIS_LABEL,
SOURCE_LANG,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN
) select
p_region_application_id,
p_region_code,
p_graph_number,
L.LANGUAGE_CODE,
l_graph_title,
l_y_axis_label,
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
from AK_REGION_GRAPHS_TL T
where T.REGION_APPLICATION_ID = p_region_application_id
and T.REGION_CODE = p_region_code
and T.GRAPH_NUMBER = p_graph_number
and T.LANGUAGE = L.LANGUAGE_CODE);

--  ** commit the insert **
commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_CREATED');
FND_MESSAGE.SET_TOKEN('OBJECT', 'AK_LC_REGION_GRAPH',TRUE);
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || p_graph_number);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || p_graph_number);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_graph;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || p_graph_number);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_graph;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_graph;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_GRAPH;
*/

--=======================================================
--  Procedure   CREATE_ITEM
--
--  Usage       Private API for creating a region item. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region item using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_ITEM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_display_sequence         IN      NUMBER,
p_node_display_flag        IN      VARCHAR2,
p_node_query_flag          IN      VARCHAR2,
p_attribute_label_length   IN      NUMBER,
p_display_value_length     IN      NUMBER,
p_bold                     IN      VARCHAR2,
p_italic                   IN      VARCHAR2,
p_vertical_alignment       IN      VARCHAR2,
p_horizontal_alignment     IN      VARCHAR2,
p_item_style               IN      VARCHAR2,
p_object_attribute_flag    IN      VARCHAR2,
p_icx_custom_call          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_update_flag              IN      VARCHAR2,
p_required_flag            IN      VARCHAR2,
p_security_code            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_foreign_key_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_attribute_application_id IN  NUMBER := FND_API.G_MISS_NUM,
p_lov_attribute_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_default_flag         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_defaulting_api_pkg IN     VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_defaulting_api_proc IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_validation_api_pkg IN     VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_validation_api_proc IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_order_sequence           IN      NUMBER := FND_API.G_MISS_NUM,
p_order_direction          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_display_height		IN	NUMBER := FND_API.G_MISS_NUM,
p_submit			IN		 VARCHAR2,
p_encrypt			IN		 VARCHAR2,
p_css_class_name				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_view_usage_name			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_view_attribute_name		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_nested_region_appl_id	 IN		 NUMBER := FND_API.G_MISS_NUM,
p_nested_region_code		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_url						 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_viewobject		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_display_attr   	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_value_attr		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_image_file_name			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_item_name				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_css_label_class_name	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_menu_name		     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_name	     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_application_id IN	     NUMBER   := FND_API.G_MISS_NUM,
p_tabular_function_code    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_type                 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_application_id   IN      NUMBER   := FND_API.G_MISS_NUM,
p_flex_segment_list            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_entity_id                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_anchor                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_view_usage_name  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_user_customizable	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_sortby_view_attribute_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_admin_customizable	     IN	     VARCHAR2,
p_invoke_function_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_expansion		     IN      NUMBER   := FND_API.G_MISS_NUM,
p_als_max_length	     IN      NUMBER   := FND_API.G_MISS_NUM,
p_initial_sort_sequence    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_application_id IN  NUMBER   := FND_API.G_MISS_NUM,
p_customization_code	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_description			     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
l_api_name                CONSTANT varchar2(30) := 'Create_Item';
l_attribute_label_long    VARCHAR2(80);
l_attribute_label_short   VARCHAR2(40);
l_description				VARCHAR2(2000);
l_created_by              number;
l_creation_date           date;
l_error                   boolean;
l_icx_custom_call         VARCHAR2(80) := null;
l_default_value_varchar2  VARCHAR2(240) := null;
l_default_value_number    number;
l_default_value_date      date;
l_lang                    varchar2(30);
l_last_update_date        date;
l_last_update_login       number;
l_last_updated_by         number;
l_lov_attribute_appl_id   NUMBER;
l_lov_attribute_code      VARCHAR2(30);
l_lov_foreign_key_name    VARCHAR2(30);
l_lov_region_appl_id      NUMBER;
l_lov_region_code         VARCHAR2(30);
l_lov_default_flag        VARCHAR2(1);
l_order_sequence          NUMBER;
l_order_direction         VARCHAR2(30);
l_region_defaulting_api_pkg      VARCHAR2(30);
l_region_defaulting_api_proc     VARCHAR2(30);
l_region_validation_api_pkg      VARCHAR2(30);
l_region_validation_api_proc     VARCHAR2(30);
l_display_height			NUMBER;
l_submit					VARCHAR2(1) := 'N';
l_encrypt					VARCHAR2(1) := 'N';
l_css_class_name				VARCHAR2(80);
l_view_usage_name			VARCHAR2(80);
l_view_attribute_name		VARCHAR2(80);
l_nested_region_appl_id	NUMBER;
l_nested_region_code		VARCHAR2(30);
l_url						VARCHAR2(2000);
l_poplist_viewobject		VARCHAR2(240);
l_poplist_display_attr	VARCHAR2(80);
l_poplist_value_attr		VARCHAR2(80);
l_image_file_name			VARCHAR2(80);
l_item_name				VARCHAR2(30);
l_css_label_class_name	VARCHAR2(80);
l_menu_name				VARCHAR2(30);
l_flexfield_name			VARCHAR2(40);
l_flexfield_application_id		NUMBER;
l_tabular_function_code          VARCHAR2(30);
l_tip_type                       VARCHAR2(30);
l_tip_message_name               VARCHAR2(30);
l_tip_message_application_id     NUMBER;
l_flex_segment_list                    VARCHAR2(4000);
l_entity_id               VARCHAR2(30);
l_anchor                  VARCHAR2(1);
l_poplist_view_usage_name VARCHAR2(80);
l_user_customizable	    VARCHAR2(1);
l_sortby_view_attribute_name VARCHAR2(80);
l_admin_customizable	    VARCHAR2(1) := 'Y';
l_invoke_function_name    VARCHAR2(30);
l_expansion		    NUMBER;
l_als_max_length	    NUMBER;
l_initial_sort_sequence   VARCHAR2(30);
l_customization_application_id	NUMBER;
l_customization_code	    VARCHAR2(30);
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
l_security_code           VARCHAR2(30);
l_update_flag             VARCHAR2(1) := 'Y';
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

savepoint start_create_item;

/* TSHORT - 5665840 - new logic to avoid unique constraint error */
/* now if we hit that error the exception handling calls update_item */
/* --** check to see if row already exists **
if AK_REGION_PVT.ITEM_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_EXISTS');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || 'Error - row already exists');
raise FND_API.G_EXC_ERROR;
end if; */

if (p_display_sequence IS NOT NULL) and
(p_display_sequence <> FND_API.G_MISS_NUM) then
--** Check the given display sequence number
AK_REGION2_PVT.CHECK_DISPLAY_SEQUENCE (  p_validation_level => p_validation_level,
p_region_code => p_region_code,
p_region_application_id => p_region_application_id,
p_attribute_code => p_attribute_code,
p_attribute_application_id => p_attribute_application_id,
p_display_sequence => p_display_sequence,
p_return_status => l_return_status,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_pass => p_pass,
p_copy_redo_flag => p_copy_redo_flag);

--** Check the return status and act accordingly
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
raise FND_API.G_EXC_ERROR;
end if;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_REGION_PVT.VALIDATE_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_display_sequence => p_display_sequence,
p_node_display_flag => p_node_display_flag,
p_node_query_flag => p_node_query_flag,
p_attribute_label_length => p_attribute_label_length,
p_display_value_length => p_display_value_length,
p_bold => p_bold,
p_italic => p_italic,
p_vertical_alignment => p_vertical_alignment,
p_horizontal_alignment => p_horizontal_alignment,
p_item_style => p_item_style,
p_object_attribute_flag => p_object_attribute_flag,
p_icx_custom_call => p_icx_custom_call,
p_update_flag => p_update_flag,
p_required_flag => p_required_flag,
p_security_code => p_security_code,
p_default_value_varchar2 => p_default_value_varchar2,
p_default_value_number => p_default_value_number,
p_default_value_date => p_default_value_date,
p_nested_region_appl_id => p_nested_region_appl_id,
p_nested_region_code => p_nested_region_code,
p_lov_region_application_id => p_lov_region_application_id,
p_lov_region_code => p_lov_region_code,
p_lov_foreign_key_name => p_lov_foreign_key_name,
p_lov_attribute_application_id => p_lov_attribute_application_id,
p_lov_attribute_code => p_lov_attribute_code,
p_lov_default_flag => p_lov_default_flag,
p_region_defaulting_api_pkg => p_region_defaulting_api_pkg,
p_region_defaulting_api_proc => p_region_defaulting_api_proc,
p_region_validation_api_pkg => p_region_validation_api_pkg,
p_region_validation_api_proc => p_region_validation_api_proc,
p_order_sequence => p_order_sequence,
p_order_direction => p_order_direction,
p_menu_name => p_menu_name,
p_flexfield_name => p_flexfield_name,
p_flexfield_application_id => p_flexfield_application_id,
p_tabular_function_code    => p_tabular_function_code,
p_tip_type                 => p_tip_type,
p_tip_message_name         => p_tip_message_name,
p_tip_message_application_id  => p_tip_message_application_id ,
p_flex_segment_list        => p_flex_segment_list,
p_entity_id                => p_entity_id,
p_anchor                   => p_anchor,
p_poplist_view_usage_name  => p_poplist_view_usage_name,
p_user_customizable	       => p_user_customizable,
p_sortby_view_attribute_name => p_sortby_view_attribute_name,
p_invoke_function_name => p_invoke_function_name,
p_expansion => p_expansion,
p_als_max_length => p_als_max_length,
p_initial_sort_sequence => p_initial_sort_sequence,
p_customization_application_id => p_customization_application_id,
p_customization_code => p_customization_code,
p_attribute_label_long => p_attribute_label_long,
p_attribute_label_short => p_attribute_label_short,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

--
-- special logic for handling update_flag, bug#2054285
-- set update_flag to 'Y'
-- do not change update_flag to 'Y' if FILE_FORMAT_VERSION > 115.14
--
l_update_flag := p_update_flag;
if ( ( AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER1 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER2 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER3 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER4 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER5 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER6 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER7 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER8 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER9 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER11 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER12 ) and
( p_item_style = 'CHECKBOX' or p_item_style = 'DESCRIPTIVE_FLEX' or
p_item_style = 'KEY_FLEX' or p_item_style = 'FILE' or
p_item_style = 'FORM_PARAMETER_BEAN' or p_item_style = 'RADIO_BUTTON' or
p_item_style  = 'POPLIST' or p_item_style = 'HIDDEN' or
p_item_style = 'TEXT_INPUT' or p_item_style = 'RADIO_GROUP' ) and
INSTR(p_region_code,'POR') <> 1 ) then
l_update_flag := 'Y';
end if;

-- default a value for submit and encrypt columns if no value is given
if ( p_submit <> FND_API.G_MISS_CHAR and p_submit is not null ) then
l_submit := p_submit;
end if;
if ( p_encrypt <> FND_API.G_MISS_CHAR and p_encrypt is not null ) then
l_encrypt := p_encrypt;
end if;
if ( p_admin_customizable <> FND_API.G_MISS_CHAR and p_admin_customizable is not null ) then
l_admin_customizable := p_admin_customizable;
end if;

--** Load non-required columns if their values are given **
if (p_icx_custom_call <> FND_API.G_MISS_CHAR) then
l_icx_custom_call := p_icx_custom_call;
end if;

if (p_security_code <> FND_API.G_MISS_CHAR) then
l_security_code := p_security_code;
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

if (p_lov_region_application_id <> FND_API.G_MISS_NUM) then
l_lov_region_appl_id := p_lov_region_application_id;
end if;

if (p_lov_region_code <> FND_API.G_MISS_CHAR) then
l_lov_region_code := p_lov_region_code;
end if;

if (p_lov_foreign_key_name <> FND_API.G_MISS_CHAR) then
l_lov_foreign_key_name := p_lov_foreign_key_name;
end if;

if (p_lov_attribute_application_id <> FND_API.G_MISS_NUM) then
l_lov_attribute_appl_id := p_lov_attribute_application_id;
end if;

if (p_lov_attribute_code <> FND_API.G_MISS_CHAR) then
l_lov_attribute_code := p_lov_attribute_code;
end if;

if (p_lov_default_flag <> FND_API.G_MISS_CHAR) then
l_lov_default_flag := p_lov_default_flag;
end if;

if (p_region_defaulting_api_pkg <> FND_API.G_MISS_CHAR) then
l_region_defaulting_api_pkg := p_region_defaulting_api_pkg;
end if;

if (p_region_defaulting_api_proc <> FND_API.G_MISS_CHAR) then
l_region_defaulting_api_proc := p_region_defaulting_api_proc;
end if;

if (p_region_validation_api_pkg <> FND_API.G_MISS_CHAR) then
l_region_validation_api_pkg := p_region_validation_api_pkg;
end if;

if (p_region_validation_api_proc <> FND_API.G_MISS_CHAR) then
l_region_validation_api_proc := p_region_validation_api_proc;
end if;

if (p_order_sequence <> FND_API.G_MISS_NUM) then
l_order_sequence := p_order_sequence;
end if;

if (p_order_direction <> FND_API.G_MISS_CHAR) then
l_order_direction := p_order_direction;
end if;

if (p_display_height <> FND_API.G_MISS_NUM) then
l_display_height := p_display_height;
end if;

if (p_css_class_name <> FND_API.G_MISS_CHAR) then
l_css_class_name := p_css_class_name;
end if;

if (p_view_usage_name <> FND_API.G_MISS_CHAR) then
l_view_usage_name := p_view_usage_name;
end if;

if (p_view_attribute_name <> FND_API.G_MISS_CHAR) then
l_view_attribute_name := p_view_attribute_name;
end if;

if (p_nested_region_appl_id <> FND_API.G_MISS_NUM) then
l_nested_region_appl_id := p_nested_region_appl_id;
end if;

if (p_nested_region_code <> FND_API.G_MISS_CHAR) then
l_nested_region_code := p_nested_region_code;
end if;

if (p_url <> FND_API.G_MISS_CHAR) then
l_url := p_url;
end if;

if (p_poplist_viewobject <> FND_API.G_MISS_CHAR) then
l_poplist_viewobject := p_poplist_viewobject;
end if;

if (p_poplist_display_attr <> FND_API.G_MISS_CHAR) then
l_poplist_display_attr := p_poplist_display_attr;
end if;

if (p_poplist_value_attr <> FND_API.G_MISS_CHAR) then
l_poplist_value_attr := p_poplist_value_attr;
end if;

if (p_image_file_name <> FND_API.G_MISS_CHAR) then
l_image_file_name := p_image_file_name;
end if;

if (p_item_name <> FND_API.G_MISS_CHAR) then
l_item_name := p_item_name;
end if;

if (p_css_label_class_name <> FND_API.G_MISS_CHAR) then
l_css_label_class_name := p_css_label_class_name;
end if;

if (p_menu_name <> FND_API.G_MISS_CHAR) then
l_menu_name := p_menu_name;
end if;

if (p_flexfield_name <> FND_API.G_MISS_CHAR) then
l_flexfield_name := p_flexfield_name;
end if;

if (p_flexfield_application_id <> FND_API.G_MISS_NUM) then
l_flexfield_application_id := p_flexfield_application_id;
end if;

if (p_tabular_function_code <> FND_API.G_MISS_CHAR) then
l_tabular_function_code := p_tabular_function_code;
end if;

if (p_tip_type <> FND_API.G_MISS_CHAR) then
l_tip_type := p_tip_type;
end if;

if (p_tip_message_name <> FND_API.G_MISS_CHAR) then
l_tip_message_name := p_tip_message_name;
end if;

if (p_tip_message_application_id <> FND_API.G_MISS_NUM) then
l_tip_message_application_id := p_tip_message_application_id;
end if;

if (p_flex_segment_list <> FND_API.G_MISS_CHAR) then
l_flex_segment_list := p_flex_segment_list;
end if;

if (p_entity_id <> FND_API.G_MISS_CHAR) then
l_entity_id := p_entity_id;
end if;

if (p_anchor <> FND_API.G_MISS_CHAR) then
l_anchor := p_anchor;
end if;

if (p_poplist_view_usage_name <> FND_API.G_MISS_CHAR) then
l_poplist_view_usage_name:= p_poplist_view_usage_name;
end if;

if (p_user_customizable <> FND_API.G_MISS_CHAR) then
l_user_customizable:= p_user_customizable;
end if;

if (p_sortby_view_attribute_name <> FND_API.G_MISS_CHAR) then
l_sortby_view_attribute_name:= p_sortby_view_attribute_name;
end if;

if (p_invoke_function_name <> FND_API.G_MISS_CHAR) then
l_invoke_function_name:= p_invoke_function_name;
end if;

if (p_expansion <> FND_API.G_MISS_NUM) then
l_expansion := p_expansion;
end if;

if (p_als_max_length <> FND_API.G_MISS_NUM) then
l_als_max_length := p_als_max_length;
end if;

if (p_initial_sort_sequence<> FND_API.G_MISS_CHAR) then
l_initial_sort_sequence := p_initial_sort_sequence;
end if;

if (p_customization_application_id <> FND_API.G_MISS_NUM) then
l_customization_application_id := p_customization_application_id;
end if;

if (p_customization_code <> FND_API.G_MISS_CHAR) then
l_customization_code := p_customization_code;
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

if (p_attribute_label_long <> FND_API.G_MISS_CHAR) then
l_attribute_label_long := p_attribute_label_long;
end if;

if (p_attribute_label_short <> FND_API.G_MISS_CHAR) then
l_attribute_label_short := p_attribute_label_short;
end if;

if (p_description <> FND_API.G_MISS_CHAR) then
l_description := p_description;
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

insert into AK_REGION_ITEMS (
REGION_APPLICATION_ID,
REGION_CODE,
ATTRIBUTE_APPLICATION_ID,
ATTRIBUTE_CODE,
DISPLAY_SEQUENCE,
NODE_DISPLAY_FLAG,
NODE_QUERY_FLAG,
ATTRIBUTE_LABEL_LENGTH,
DISPLAY_VALUE_LENGTH,
BOLD,
ITALIC,
VERTICAL_ALIGNMENT,
HORIZONTAL_ALIGNMENT,
ITEM_STYLE,
OBJECT_ATTRIBUTE_FLAG,
ICX_CUSTOM_CALL,
UPDATE_FLAG,
REQUIRED_FLAG,
SECURITY_CODE,
DEFAULT_VALUE_VARCHAR2,
DEFAULT_VALUE_NUMBER,
DEFAULT_VALUE_DATE,
LOV_REGION_APPLICATION_ID,
LOV_REGION_CODE,
LOV_FOREIGN_KEY_NAME,
LOV_ATTRIBUTE_APPLICATION_ID,
LOV_ATTRIBUTE_CODE,
LOV_DEFAULT_FLAG,
REGION_DEFAULTING_API_PKG,
REGION_DEFAULTING_API_PROC,
REGION_VALIDATION_API_PKG,
REGION_VALIDATION_API_PROC,
ORDER_SEQUENCE,
ORDER_DIRECTION,
DISPLAY_HEIGHT,
SUBMIT,
ENCRYPT,
CSS_CLASS_NAME,
VIEW_USAGE_NAME,
VIEW_ATTRIBUTE_NAME,
NESTED_REGION_APPLICATION_ID,
NESTED_REGION_CODE,
URL,
POPLIST_VIEWOBJECT,
POPLIST_DISPLAY_ATTRIBUTE,
POPLIST_VALUE_ATTRIBUTE,
IMAGE_FILE_NAME,
ITEM_NAME,
CSS_LABEL_CLASS_NAME,
MENU_NAME,
FLEXFIELD_NAME,
FLEXFIELD_APPLICATION_ID,
TABULAR_FUNCTION_CODE,
TIP_TYPE,
TIP_MESSAGE_NAME,
TIP_MESSAGE_APPLICATION_ID,
FLEX_SEGMENT_LIST,
ENTITY_ID,
ANCHOR,
POPLIST_VIEW_USAGE_NAME,
USER_CUSTOMIZABLE,
SORTBY_VIEW_ATTRIBUTE_NAME,
ADMIN_CUSTOMIZABLE,
INVOKE_FUNCTION_NAME,
EXPANSION,
ALS_MAX_LENGTH,
INITIAL_SORT_SEQUENCE,
CUSTOMIZATION_APPLICATION_ID,
CUSTOMIZATION_CODE,
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
p_region_application_id,
p_region_code,
p_attribute_application_id,
p_attribute_code,
p_display_sequence,
p_node_display_flag,
p_node_query_flag,
p_attribute_label_length,
p_display_value_length,
p_bold,
p_italic,
p_vertical_alignment,
p_horizontal_alignment,
p_item_style,
p_object_attribute_flag,
l_icx_custom_call,
l_update_flag,
p_required_flag,
l_security_code,
l_default_value_varchar2,
l_default_value_number,
l_default_value_date,
l_lov_region_appl_id,
l_lov_region_code,
l_lov_foreign_key_name,
l_lov_attribute_appl_id,
l_lov_attribute_code,
l_lov_default_flag,
l_region_defaulting_api_pkg,
l_region_defaulting_api_proc,
l_region_validation_api_pkg,
l_region_validation_api_proc,
l_order_sequence,
l_order_direction,
l_display_height,
l_submit,
l_encrypt,
l_css_class_name,
l_view_usage_name,
l_view_attribute_name,
l_nested_region_appl_id,
l_nested_region_code,
l_url,
l_poplist_viewobject,
l_poplist_display_attr,
l_poplist_value_attr,
l_image_file_name,
l_item_name,
l_css_label_class_name,
l_menu_name,
l_flexfield_name,
l_flexfield_application_id,
l_tabular_function_code,
l_tip_type,
l_tip_message_name,
l_tip_message_application_id,
l_flex_segment_list,
l_entity_id,
l_anchor,
l_poplist_view_usage_name,
l_user_customizable,
l_sortby_view_attribute_name,
l_admin_customizable,
l_invoke_function_name,
l_expansion,
l_als_max_length,
l_initial_sort_sequence,
l_customization_application_id,
l_customization_code,
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
if NOT AK_REGION_PVT.ITEM_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_INSERT_REG_ITEM_FAILED');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || 'Error - row already exists');
raise FND_API.G_EXC_ERROR;
end if;

insert into AK_REGION_ITEMS_TL (
REGION_APPLICATION_ID,
REGION_CODE,
ATTRIBUTE_APPLICATION_ID,
ATTRIBUTE_CODE,
LANGUAGE,
ATTRIBUTE_LABEL_LONG,
ATTRIBUTE_LABEL_SHORT,
DESCRIPTION,
SOURCE_LANG,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN
) select
p_region_application_id,
p_region_code,
p_attribute_application_id,
p_attribute_code,
L.LANGUAGE_CODE,
l_attribute_label_long,
l_attribute_label_short,
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
from AK_REGION_ITEMS_TL T
where T.REGION_APPLICATION_ID = p_region_application_id
and T.REGION_CODE = p_region_code
and T.ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and T.ATTRIBUTE_CODE = p_attribute_code
and T.LANGUAGE = L.LANGUAGE_CODE);

--  /** commit the insert **/
 commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_CREATED');
FND_MESSAGE.SET_TOKEN('OBJECT', 'AK_LC_REGION_ITEM',TRUE);
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
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
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_item;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_item;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
    if (SQLCODE = -1) then
        rollback to start_create_item;
        AK_REGION_PVT.UPDATE_ITEM (
          p_validation_level => p_validation_level,
          p_api_version_number => 1.0,
          p_msg_count => p_msg_count,
          p_msg_data => p_msg_data,
          p_return_status => p_return_status,
          p_region_application_id => p_region_application_id,
          p_region_code => p_region_code,
          p_attribute_application_id => p_attribute_application_id,
          p_attribute_code => p_attribute_code,
          p_display_sequence => p_display_sequence,
          p_node_display_flag => p_node_display_flag,
          p_node_query_flag => p_node_query_flag,
          p_attribute_label_length => p_attribute_label_length,
          p_display_value_length => p_display_value_length,
          p_bold => p_bold,
          p_italic => p_italic,
          p_vertical_alignment => p_vertical_alignment,
          p_horizontal_alignment => p_horizontal_alignment,
          p_item_style => p_item_style,
          p_object_attribute_flag => p_object_attribute_flag,
          p_icx_custom_call => p_icx_custom_call,
          p_update_flag => p_update_flag,
          p_required_flag => p_required_flag,
          p_security_code => p_security_code,
          p_default_value_varchar2 => p_default_value_varchar2,
          p_default_value_number => p_default_value_number,
          p_default_value_date => p_default_value_date,
          p_lov_region_application_id => p_lov_region_application_id,
          p_lov_region_code => p_lov_region_code,
          p_lov_foreign_key_name => p_lov_foreign_key_name,
          p_lov_attribute_application_id => p_lov_attribute_application_id,
          p_lov_attribute_code => p_lov_attribute_code,
          p_lov_default_flag => p_lov_default_flag,
          p_region_defaulting_api_pkg => p_region_defaulting_api_pkg,
          p_region_defaulting_api_proc => p_region_defaulting_api_proc,
          p_region_validation_api_pkg => p_region_validation_api_pkg,
          p_region_validation_api_proc => p_region_validation_api_proc,
          p_order_sequence => p_order_sequence,
          p_order_direction => p_order_direction,
          p_display_height => p_display_height,
          p_submit => p_submit,
          p_encrypt => p_encrypt,
          p_css_class_name => p_css_class_name,
          p_view_usage_name => p_view_usage_name,
          p_view_attribute_name => p_view_attribute_name,
          p_nested_region_appl_id => p_nested_region_appl_id,
          p_nested_region_code => p_nested_region_code,
          p_url => p_url,
          p_poplist_viewobject => p_poplist_viewobject,
          p_poplist_display_attr => p_poplist_display_attr,
          p_poplist_value_attr => p_poplist_value_attr,
          p_image_file_name => p_image_file_name,
          p_item_name => p_item_name,
          p_css_label_class_name => p_css_label_class_name,
          p_menu_name => p_menu_name,
          p_flexfield_name => p_flexfield_name,
          p_flexfield_application_id => p_flexfield_application_id,
          p_tabular_function_code    => p_tabular_function_code,
          p_tip_type                 => p_tip_type,
          p_tip_message_name         => p_tip_message_name,
          p_tip_message_application_id  => p_tip_message_application_id ,
          p_flex_segment_list        => p_flex_segment_list,
          p_entity_id  => p_entity_id,
          p_anchor     => p_anchor,
          p_poplist_view_usage_name => p_poplist_view_usage_name,
          p_user_customizable => p_user_customizable,
          p_sortby_view_attribute_name => p_sortby_view_attribute_name,
          p_admin_customizable => p_admin_customizable,
          p_invoke_function_name => p_invoke_function_name,
          p_expansion => p_expansion,
          p_als_max_length => p_als_max_length,
          p_initial_sort_sequence => p_initial_sort_sequence,
          p_customization_application_id => p_customization_application_id,
          p_customization_code => p_customization_code,
          p_attribute_category => p_attribute_category,
          p_attribute1 => p_attribute1,
          p_attribute2 => p_attribute2,
          p_attribute3 => p_attribute3,
          p_attribute4 => p_attribute4,
          p_attribute5 => p_attribute5,
          p_attribute6 => p_attribute6,
          p_attribute7 => p_attribute7,
          p_attribute8 => p_attribute8,
          p_attribute9 => p_attribute9,
          p_attribute10 => p_attribute10,
          p_attribute11 => p_attribute11,
          p_attribute12 => p_attribute12,
          p_attribute13 => p_attribute13,
          p_attribute14 => p_attribute14,
          p_attribute15 => p_attribute15,
          p_attribute_label_long => p_attribute_label_long,
          p_attribute_label_short => p_attribute_label_short,
          p_description => p_description,
          p_created_by => p_created_by,
          p_creation_date => p_creation_date,
          p_last_updated_by => p_last_updated_by,
          p_last_update_date => p_last_update_date,
          p_last_update_login => p_last_update_login,
          p_loader_timestamp => p_loader_timestamp,
          p_pass => p_pass,
          p_copy_redo_flag => p_copy_redo_flag
          );
       else
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end if;
end CREATE_ITEM;

--=======================================================
--  Procedure   CREATE_REGION
--
--  Usage       Private API for creating a region. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_REGION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_region_style             IN      VARCHAR2,
p_icx_custom_call          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_num_columns              IN      NUMBER := FND_API.G_MISS_NUM,
p_region_defaulting_api_pkg IN     VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_defaulting_api_proc IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_validation_api_pkg IN     VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_validation_api_proc IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_appmodule_object_type	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_num_rows_display		 IN		 NUMBER := FND_API.G_MISS_NUM,
p_region_object_type		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_image_file_name			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_isform_flag				 IN		 VARCHAR2,
p_help_target 			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_style_sheet_filename	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_version                  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_applicationmodule_usage_name IN  VARCHAR2 := FND_API.G_MISS_CHAR,
p_add_indexed_children     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_stateful_flag	     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_function_name            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_children_view_usage_name IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_search_panel	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_advanced_search_panel    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customize_panel	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_search_panel     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_results_based_search     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_display_graph_table      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_disable_header	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_standalone		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_auto_customization_criteria IN   VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_name                     IN      VARCHAR2,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
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
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Region';
l_created_by         number;
l_creation_date      date;
l_description        VARCHAR2(2000) := null;
l_icx_custom_call    VARCHAR2(80) := null;
l_lang               varchar2(30);
l_last_update_date   date;
l_last_update_login  number;
l_last_updated_by    number;
l_num_columns        NUMBER := null;
l_region_defaulting_api_pkg      VARCHAR2(30);
l_region_defaulting_api_proc     VARCHAR2(30);
l_region_validation_api_pkg      VARCHAR2(30);
l_region_validation_api_proc     VARCHAR2(30);
l_appmodule_object_type			VARCHAR2(240);
l_num_rows_display				NUMBER;
l_region_object_type				VARCHAR2(240);
l_image_file_name					VARCHAR2(80);
l_isform_flag						VARCHAR2(1) := 'N';
l_help_target						VARCHAR2(240);
l_style_sheet_filename			VARCHAR2(240);
l_version							VARCHAR2(30);
l_appmodule_usage_name	        VARCHAR2(80);
l_add_indexed_children	        VARCHAR2(1);
l_stateful_flag			VARCHAR2(1);
l_function_name			VARCHAR2(30);
l_children_view_usage_name		VARCHAR2(80);
l_search_panel			VARCHAR2(1);
l_advanced_search_panel		VARCHAR2(1);
l_customize_panel			VARCHAR2(1);
l_default_search_panel		VARCHAR2(30);
l_results_based_search		VARCHAR2(1);
l_display_graph_table			VARCHAR2(1);
l_disable_header			VARCHAR2(1);
l_standalone				VARCHAR2(1);
l_auto_customization_criteria		VARCHAR2(1);
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

savepoint start_create_region;

--** check to see if row already exists **
if AK_REGION_PVT.REGION_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REGION_EXISTS');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line(G_PKG_NAME || 'Error - Row already exists');
raise FND_API.G_EXC_ERROR;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_REGION_PVT.VALIDATE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_database_object_name => p_database_object_name,
p_region_style => p_region_style,
p_icx_custom_call => p_icx_custom_call,
p_num_columns => p_num_columns,
p_region_defaulting_api_pkg => p_region_defaulting_api_pkg,
p_region_defaulting_api_proc => p_region_defaulting_api_proc,
p_region_validation_api_pkg => p_region_validation_api_pkg,
p_region_validation_api_proc => p_region_validation_api_proc,
p_name => p_name,
p_description => p_description,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

--** Load non-required columns if their values are given **
if (p_description <> FND_API.G_MISS_CHAR) then
l_description := p_description;
end if;

if (p_icx_custom_call <> FND_API.G_MISS_CHAR) then
l_icx_custom_call := p_icx_custom_call;
end if;

if (p_num_columns <> FND_API.G_MISS_NUM) then
l_num_columns := p_num_columns;
end if;

if (p_region_defaulting_api_pkg <> FND_API.G_MISS_CHAR) then
l_region_defaulting_api_pkg := p_region_defaulting_api_pkg;
end if;

if (p_region_defaulting_api_proc <> FND_API.G_MISS_CHAR) then
l_region_defaulting_api_proc := p_region_defaulting_api_proc;
end if;

if (p_region_validation_api_pkg <> FND_API.G_MISS_CHAR) then
l_region_validation_api_pkg := p_region_validation_api_pkg;
end if;

if (p_region_validation_api_proc <> FND_API.G_MISS_CHAR) then
l_region_validation_api_proc := p_region_validation_api_proc;
end if;

if (p_appmodule_object_type <> FND_API.G_MISS_CHAR) then
l_appmodule_object_type := p_appmodule_object_type;
end if;

if (p_num_rows_display <> FND_API.G_MISS_NUM) then
l_num_rows_display := p_num_rows_display;
end if;

if (p_region_object_type <> FND_API.G_MISS_CHAR) then
l_region_object_type := p_region_object_type;
end if;

if (p_image_file_name <> FND_API.G_MISS_CHAR) then
l_image_file_name := p_image_file_name;
end if;

if (p_isform_flag <> FND_API.G_MISS_CHAR) then
l_isform_flag := p_isform_flag;
end if;

if (p_help_target <> FND_API.G_MISS_CHAR) then
l_help_target := p_help_target;
end if;

if (p_style_sheet_filename <> FND_API.G_MISS_CHAR) then
l_style_sheet_filename := p_style_sheet_filename;
end if;

if (p_version <> FND_API.G_MISS_CHAR) then
l_version := p_version;
end if;

if (p_applicationmodule_usage_name <> FND_API.G_MISS_CHAR) then
l_appmodule_usage_name := p_applicationmodule_usage_name;
end if;

if (p_add_indexed_children <> FND_API.G_MISS_CHAR) then
l_add_indexed_children := p_add_indexed_children;
end if;

if (p_stateful_flag <> FND_API.G_MISS_CHAR) then
l_stateful_flag := p_stateful_flag;
end if;

if (p_function_name <> FND_API.G_MISS_CHAR) then
l_function_name := p_function_name;
end if;

if (p_children_view_usage_name <> FND_API.G_MISS_CHAR) then
l_children_view_usage_name := p_children_view_usage_name;
end if;

if (p_search_panel <> FND_API.G_MISS_CHAR) then
l_search_panel := p_search_panel;
end if;

if (p_advanced_search_panel <> FND_API.G_MISS_CHAR) then
l_advanced_search_panel := p_advanced_search_panel;
end if;

if (p_customize_panel <> FND_API.G_MISS_CHAR) then
l_customize_panel := p_customize_panel;
end if;

if (p_default_search_panel <> FND_API.G_MISS_CHAR) then
l_default_search_panel := p_default_search_panel;
end if;

if (p_results_based_search <> FND_API.G_MISS_CHAR) then
l_results_based_search := p_results_based_search;
end if;

if (p_display_graph_table <> FND_API.G_MISS_CHAR) then
l_display_graph_table := p_display_graph_table;
end if;

if (p_disable_header <> FND_API.G_MISS_CHAR) then
l_disable_header := p_disable_header;
end if;

-- standalone is now a non-null column and it should have default value sets to 'Y'
if (p_standalone <> FND_API.G_MISS_CHAR and p_standalone is not null) then
l_standalone := p_standalone;
else
l_standalone := 'Y';
end if;

if (p_auto_customization_criteria <> FND_API.G_MISS_CHAR) then
l_auto_customization_criteria := p_auto_customization_criteria;
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

insert into AK_REGIONS (
REGION_APPLICATION_ID,
REGION_CODE,
DATABASE_OBJECT_NAME,
REGION_STYLE,
ICX_CUSTOM_CALL,
NUM_COLUMNS,
REGION_DEFAULTING_API_PKG,
REGION_DEFAULTING_API_PROC,
REGION_VALIDATION_API_PKG,
REGION_VALIDATION_API_PROC,
APPLICATIONMODULE_OBJECT_TYPE,
NUM_ROWS_DISPLAY,
REGION_OBJECT_TYPE,
IMAGE_FILE_NAME,
ISFORM_FLAG,
HELP_TARGET,
STYLE_SHEET_FILENAME,
VERSION,
APPLICATIONMODULE_USAGE_NAME,
ADD_INDEXED_CHILDREN,
STATEFUL_FLAG,
FUNCTION_NAME,
CHILDREN_VIEW_USAGE_NAME,
SEARCH_PANEL,
ADVANCED_SEARCH_PANEL,
CUSTOMIZE_PANEL,
DEFAULT_SEARCH_PANEL,
RESULTS_BASED_SEARCH,
DISPLAY_GRAPH_TABLE,
DISABLE_HEADER,
STANDALONE,
AUTO_CUSTOMIZATION_CRITERIA,
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
p_region_application_id,
p_region_code,
p_database_object_name,
p_region_style,
l_icx_custom_call,
l_num_columns,
l_region_defaulting_api_pkg,
l_region_defaulting_api_proc,
l_region_validation_api_pkg,
l_region_validation_api_proc,
l_appmodule_object_type,
l_num_rows_display,
l_region_object_type,
l_image_file_name,
l_isform_flag,
l_help_target,
l_style_sheet_filename,
l_version,
l_appmodule_usage_name,
l_add_indexed_children,
l_stateful_flag,
l_function_name,
l_children_view_usage_name,
l_search_panel,
l_advanced_search_panel,
l_customize_panel,
l_default_search_panel,
l_results_based_search,
l_display_graph_table,
l_disable_header,
l_standalone,
l_auto_customization_criteria,
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
if NOT AK_REGION_PVT.REGION_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_INSERT_REGION_FAILED');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line(G_PKG_NAME || 'Error - First insert failed');
raise FND_API.G_EXC_ERROR;
end if;

insert into AK_REGIONS_TL (
REGION_APPLICATION_ID,
REGION_CODE,
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
p_region_application_id,
p_region_code,
L.LANGUAGE_CODE,
p_name,
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
from AK_REGIONS_TL T
where T.REGION_APPLICATION_ID = p_region_application_id
and T.REGION_CODE = p_region_code
and T.LANGUAGE = L.LANGUAGE_CODE);

--  /** commit the insert **/
 commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_REGION_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REGION_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240));
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_region;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REGION_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_region;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
     if (SQLCODE = -1) then
        rollback to start_create_region;
         AK_REGION_PVT.UPDATE_REGION(
           p_validation_level => p_validation_level,
           p_api_version_number => 1.0,
           p_msg_count => p_msg_count,
           p_msg_data => p_msg_data,
           p_return_status => p_return_status,
           p_region_application_id => p_region_application_id,
           p_region_code => p_region_code,
           p_database_object_name =>p_database_object_name,
           p_region_style => p_region_style,
           p_num_columns => p_num_columns,
           p_icx_custom_call => p_icx_custom_call,
           p_region_defaulting_api_pkg => p_region_defaulting_api_pkg,
           p_region_defaulting_api_proc => p_region_defaulting_api_proc,
           p_region_validation_api_pkg => p_region_validation_api_pkg,
           p_region_validation_api_proc => p_region_validation_api_proc,
           p_appmodule_object_type => p_appmodule_object_type,
           p_num_rows_display => p_num_rows_display,
           p_region_object_type => p_region_object_type,
           p_image_file_name => p_image_file_name,
           p_isform_flag => p_isform_flag,
           p_help_target => p_help_target,
           p_style_sheet_filename => p_style_sheet_filename,
           p_version => p_version,
           p_applicationmodule_usage_name => p_applicationmodule_usage_name,
           p_add_indexed_children => p_add_indexed_children,
           p_stateful_flag => p_stateful_flag,
           p_function_name => p_function_name,
           p_children_view_usage_name => p_children_view_usage_name,
          p_search_panel => p_search_panel,
          p_advanced_search_panel => p_advanced_search_panel,
          p_customize_panel => p_customize_panel,
          p_default_search_panel => p_default_search_panel,
          p_results_based_search => p_results_based_search,
          p_display_graph_table => p_display_graph_table,
          p_disable_header => p_disable_header,
          p_standalone => p_standalone,
          p_auto_customization_criteria => p_auto_customization_criteria,
           p_attribute_category => p_attribute_category,
           p_attribute1 => p_attribute1,
           p_attribute2 => p_attribute2,
           p_attribute3 => p_attribute3,
           p_attribute4 => p_attribute4,
           p_attribute5 => p_attribute5,
           p_attribute6 => p_attribute6,
           p_attribute7 => p_attribute7,
           p_attribute8 => p_attribute8,
           p_attribute9 => p_attribute9,
           p_attribute10 => p_attribute10,
           p_attribute11 => p_attribute11,
           p_attribute12 => p_attribute12,
           p_attribute13 => p_attribute13,
           p_attribute14 => p_attribute14,
           p_attribute15 => p_attribute15,
           p_name => p_name,
           p_description => p_description,
           p_created_by => p_created_by,
           p_creation_date => p_creation_date,
           p_last_updated_by => p_last_updated_by,
           p_last_update_date => p_last_update_date,
           p_last_update_login => p_last_update_login,
           p_loader_timestamp => p_loader_timestamp,
           p_pass => p_pass,
           p_copy_redo_flag => p_copy_redo_flag
           );
else
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end if;
end CREATE_REGION;

/*
--=======================================================
--  Procedure   DELETE_GRAPH
--
--  Usage       Private API for deleting a region graph. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes a region item with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_region_application_id : IN required
--              p_region_code : IN required
--              p_attribute_application_id : IN required
--              p_attribute_code : IN required
--                  Key value of the region item to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_GRAPH (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_graph_number	     IN	     NUMBER,
p_delete_cascade           IN      VARCHAR2
) is
cursor l_get_graph_column_csr is
select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
from AK_REGION_GRAPH_COLUMNS
where region_application_id = p_region_application_id
and region_code = p_region_code
and graph_number = p_graph_number;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_Item';
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_attribute_application_id	NUMBER;
l_attribute_code		VARCHAR2(30);
l_return_status		VARCHAR2(1);
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

savepoint start_delete_graph;

--
-- error if region item to be deleted does not exists
--
if NOT AK_REGION_PVT.GRAPH_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_graph_number => p_graph_number) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the region item if it is being referenced in any of
-- following tables.
--
-- AK_REGION_GRAPH_COLUMNS
--
open l_get_graph_column_csr;
fetch l_get_graph_column_csr into l_attribute_application_id,
l_attribute_code;
if l_get_graph_column_csr%found then
close l_get_graph_column_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_REG_RI');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_graph_column_csr;
--  else
end if;
--
-- Otherwise, delete all referencing rows in other tables
--
-- AK_REGION_GRAPH_COLUMNS
-- LOOK AT AK_FLOW_PVT.DELETE_PAGE_REGION_ITEM to write this code
--    open l_get_graph_column_csr;
--    loop
--      fetch l_get_graph_column_csr into l_attribute_application_id,
--					l_attribute_code;
--      exit when l_get_graph_column_csr%notfound;
--      AK_REGION2_PVT.DELETE_GRAPH_COLUMN(
--        p_validation_level => p_validation_level,
--        p_api_version_number => 1.0,
--        p_msg_count => l_msg_count,
--        p_msg_data => l_msg_data,
--        p_return_status => l_return_status,
--        p_region_application_id => p_region_application_id,
--        p_region_code => p_region_code,
--	p_graph_number => p_graph_number,
--	p_attribute_application_id => l_attribute_application_id,
--        p_attribute_code => l_attribute_code
--      );
--      if (l_return_status = FND_API.G_RET_STS_ERROR) or
--         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
--        close l_get_graph_column_csr;
--        raise FND_API.G_EXC_ERROR;
--      end if;
--    end loop;
--    close l_get_graph_column_csr;
--  end if;

--
-- delete region graph once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_region_graphs
where region_application_id = p_region_application_id
and    region_code = p_region_code
and    graph_number = p_graph_number;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

delete from ak_region_graphs_tl
where  region_application_id = p_region_application_id
and    region_code = p_region_code
and    graph_number = p_graph_number;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || p_graph_number);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || p_graph_number);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_graph;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_graph;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_GRAPH;
*/

--=======================================================
--  Procedure   DELETE_ITEM
--
--  Usage       Private API for deleting a region item. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes a region item with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_region_application_id : IN required
--              p_region_code : IN required
--              p_attribute_application_id : IN required
--              p_attribute_code : IN required
--                  Key value of the region item to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_ITEM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
) is
cursor l_get_lov_relations_csr is
select LOV_REGION_APPL_ID, LOV_REGION_CODE, LOV_ATTRIBUTE_APPL_ID,
LOV_ATTRIBUTE_CODE, BASE_ATTRIBUTE_APPL_ID, BASE_ATTRIBUTE_CODE,
DIRECTION_FLAG, BASE_REGION_APPL_ID, BASE_REGION_CODE
from AK_REGION_LOV_RELATIONS
where region_application_id = p_region_application_id
and   region_code = p_region_code
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
cursor l_get_category_usages_csr is
select CATEGORY_ID
from  AK_CATEGORY_USAGES
where region_application_id = p_region_application_id
and   region_code = p_region_code
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
cursor l_get_page_region_item_csr is
select FLOW_APPLICATION_ID, FLOW_CODE, PAGE_APPLICATION_ID, PAGE_CODE
from  AK_FLOW_PAGE_REGION_ITEMS
where region_application_id = p_region_application_id
and   region_code = p_region_code
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_Item';
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_flow_application_id   NUMBER;
l_flow_code             VARCHAR2(30);
l_page_application_id   NUMBER;
l_page_code             VARCHAR2(30);
l_lov_region_appl_id    NUMBER;
l_lov_region_code       VARCHAR2(30);
l_base_attribute_appl_id NUMBER;
l_base_attribute_code   VARCHAR2(30);
l_direction_flag        VARCHAR2(30);
l_base_region_appl_id	  NUMBER;
l_base_region_code	  VARCHAR2(30);
l_lov_attribute_appl_id NUMBER;
l_lov_attribute_code    VARCHAR2(30);
l_category_id	 	  NUMBER;
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

savepoint start_delete_item;

--
-- error if region item to be deleted does not exists
--
if NOT AK_REGION_PVT.ITEM_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the region item if it is being referenced in any of
-- following tables.
--
-- AK_FLOW_PAGE_REGION_ITEMS
--
open l_get_page_region_item_csr;
fetch l_get_page_region_item_csr into l_flow_application_id, l_flow_code,
l_page_application_id, l_page_code;
if l_get_page_region_item_csr%found then
close l_get_page_region_item_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_REG_RI');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_page_region_item_csr;
else
--
-- Otherwise, delete all referencing rows in other tables
--
-- AK_REGION_LOV_RELATIONS
--
open l_get_lov_relations_csr;
loop
fetch l_get_lov_relations_csr into l_lov_region_appl_id,
l_lov_region_code, l_lov_attribute_appl_id, l_lov_attribute_code,
l_base_attribute_appl_id, l_base_attribute_code, l_direction_flag,
l_base_region_appl_id, l_base_region_code;
exit when l_get_lov_relations_csr%notfound;
delete from ak_region_lov_relations
where  region_application_id = p_region_application_id
and    region_code = p_region_code
and    attribute_application_id = p_attribute_application_id
and    attribute_code = p_attribute_code
and    lov_region_appl_id = l_lov_region_appl_id
and    lov_region_code = l_lov_region_code
and    lov_attribute_appl_id = l_lov_attribute_appl_id
and    lov_attribute_code = l_lov_attribute_code
and    base_attribute_appl_id = l_base_attribute_appl_id
and    base_attribute_code = l_base_attribute_code
and    direction_flag = l_direction_flag
and    base_region_appl_id = l_base_region_appl_id
and    base_region_code = l_base_region_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_LOV_REL_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
close l_get_lov_relations_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_lov_relations_csr;

--
-- AK_CATEGORY_USAGES
--
open l_get_category_usages_csr;
loop
fetch l_get_category_usages_csr into l_category_id;
exit when l_get_category_usages_csr%notfound;
delete from ak_category_usages
where  region_application_id = p_region_application_id
and    region_code = p_region_code
and    attribute_application_id = p_attribute_application_id
and    attribute_code = p_attribute_code
and    category_id = l_category_id;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CAT_USAGE_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
close l_get_category_usages_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_category_usages_csr;

--
-- AK_FLOW_PAGE_REGION_ITEMS
--
--    open l_get_page_region_item_csr;
--    loop
--      fetch l_get_page_region_item_csr into l_flow_application_id, l_flow_code,
--                                        l_page_application_id, l_page_code;
--      exit when l_get_page_region_item_csr%notfound;
--      AK_FLOW_PVT.DELETE_PAGE_REGION_ITEM (
--        p_validation_level => p_validation_level,
--        p_api_version_number => 1.0,
--        p_msg_count => l_msg_count,
--        p_msg_data => l_msg_data,
--        p_return_status => l_return_status,
--        p_flow_application_id => l_flow_application_id,
--        p_flow_code => l_flow_code,
--        p_page_application_id => l_page_application_id,
--        p_page_code => l_page_code,
--        p_region_application_id => p_region_application_id,
--        p_region_code => p_region_code,
--        p_attribute_application_id => p_attribute_application_id,
--        p_attribute_code => p_attribute_code,
--        p_delete_cascade => p_delete_cascade
--      );
--      if (l_return_status = FND_API.G_RET_STS_ERROR) or
--         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
--        close l_get_page_region_item_csr;
--        raise FND_API.G_EXC_ERROR;
--      end if;
--    end loop;
--    close l_get_page_region_item_csr;
end if;

--
-- delete region item once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_region_items
where  region_application_id = p_region_application_id
and    region_code = p_region_code
and    attribute_application_id = p_attribute_application_id
and    attribute_code = p_attribute_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

delete from ak_region_items_tl
where  region_application_id = p_region_application_id
and    region_code = p_region_code
and    attribute_application_id = p_attribute_application_id
and    attribute_code = p_attribute_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
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
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_item;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_ITEM;

--=======================================================
--  Procedure   DELETE_REGION
--
--  Usage       Private API for deleting a region. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes a region with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the region to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_REGION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
) is
cursor l_is_region_a_child_csr is
select region_code, region_application_id
from AK_REGION_ITEMS
where region_code <> p_region_code
and   region_application_id <> p_region_application_id
and   (lov_region_code = p_region_code
and   lov_region_application_id = p_region_application_id)
or    (nested_region_code = p_region_code
and   nested_region_application_id = p_region_application_id);
cursor l_get_page_region_csr is
select FLOW_APPLICATION_ID, FLOW_CODE, PAGE_APPLICATION_ID, PAGE_CODE
from  AK_FLOW_PAGE_REGIONS
where region_application_id = p_region_application_id
and   region_code = p_region_code;
cursor l_get_items_csr is
select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
from  AK_REGION_ITEMS
where region_application_id = p_region_application_id
and   region_code = p_region_code;
cursor l_get_navigations_csr is
select DATABASE_OBJECT_NAME, ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE,
VALUE_VARCHAR2, VALUE_DATE, VALUE_NUMBER
from  AK_OBJECT_ATTRIBUTE_NAVIGATION
where to_region_appl_id = p_region_application_id
and   to_region_code = p_region_code;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_Region';
l_attribute_application_id NUMBER;
l_attribute_code        VARCHAR2(30);
l_database_object_name  VARCHAR2(30);
l_flow_application_id   NUMBER;
l_flow_code             VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_page_application_id   NUMBER;
l_page_code             VARCHAR2(30);
l_region_code 	  VARCHAR2(30);
l_region_application_id NUMBER;
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

savepoint start_delete_region;

/** do not raise exception when region does not exist,
* and do not print out warning message
--
-- error if primary key to be deleted does not exists
--
if NOT AK_REGION_PVT.REGION_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REGION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
**/

if AK_REGION_PVT.REGION_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code) then

open l_is_region_a_child_csr;
fetch l_is_region_a_child_csr into l_region_code, l_region_application_id;
if l_is_region_a_child_csr%found then
close l_is_region_a_child_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REGION_IS_CHILD');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_is_region_a_child_csr;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the region if it is being referenced in any of
-- following tables.
--
-- AK_REGION_ITEMS
--
open l_get_items_csr;
fetch l_get_items_csr into l_attribute_application_id, l_attribute_code;
if l_get_items_csr%found then
close l_get_items_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_REG_RI');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_items_csr;
--
-- AK_FLOW_PAGE_REGIONS
--
open l_get_page_region_csr;
fetch l_get_page_region_csr into l_flow_application_id, l_flow_code,
l_page_application_id, l_page_code;
if l_get_page_region_csr%found then
close l_get_page_region_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_REG_PGREG');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_page_region_csr;
--
-- AK_OBJECT_ATTRIBUTE_NAVIGATION
--
open l_get_navigations_csr;
fetch l_get_navigations_csr into l_database_object_name,
l_attribute_application_id, l_attribute_code,
l_value_varchar2, l_value_date, l_value_number;
if l_get_navigations_csr%found then
close l_get_navigations_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_REG_NAV');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_navigations_csr;
else
--
-- Otherwise, delete all referencing rows in other tables
--
-- AK_REGION_TIEMS
--
open l_get_items_csr;
loop
fetch l_get_items_csr into l_attribute_application_id, l_attribute_code;
exit when l_get_items_csr%notfound;
AK_REGION_PVT.DELETE_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => l_attribute_application_id,
p_attribute_code => l_attribute_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_items_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_items_csr;
--
-- AK_FLOW_PAGE_REGIONS
--
--    open l_get_page_region_csr;
--    loop
--      fetch l_get_page_region_csr into l_flow_application_id, l_flow_code,
--                                   l_page_application_id, l_page_code;
--      exit when l_get_page_region_csr%notfound;
--      AK_FLOW_PVT.DELETE_PAGE_REGION (
--        p_validation_level => p_validation_level,
--        p_api_version_number => 1.0,
--        p_msg_count => l_msg_count,
--        p_msg_data => l_msg_data,
--        p_return_status => l_return_status,
--        p_flow_application_id => l_flow_application_id,
--        p_flow_code => l_flow_code,
--        p_page_application_id => l_page_application_id,
--        p_page_code => l_page_code,
--        p_region_application_id => p_region_application_id,
--        p_region_code => p_region_code,
--        p_delete_cascade => p_delete_cascade
--      );
--      if (l_return_status = FND_API.G_RET_STS_ERROR) or
--         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
--        close l_get_page_region_csr;
--        raise FND_API.G_EXC_ERROR;
--      end if;
--    end loop;
--    close l_get_page_region_csr;
--
-- AK_OBJECT_ATTRIBUTE_NAVIGATION
--
--    open l_get_navigations_csr;
--    loop
--      fetch l_get_navigations_csr into l_database_object_name,
--                       l_attribute_application_id, l_attribute_code,
--                       l_value_varchar2, l_value_date, l_value_number;
--      exit when l_get_navigations_csr%notfound;
--      AK_OBJECT_PVT.DELETE_ATTRIBUTE_NAVIGATION (
--        p_validation_level => p_validation_level,
--        p_api_version_number => 1.0,
--        p_msg_count => l_msg_count,
--        p_msg_data => l_msg_data,
--        p_return_status => l_return_status,
--        p_database_object_name => l_database_object_name,
--        p_attribute_application_id => l_attribute_application_id,
--        p_attribute_code => l_attribute_code,
--        p_value_varchar2 => l_value_varchar2,
--        p_value_date => l_value_date,
--        p_value_number => l_value_number,
--        p_delete_cascade => p_delete_cascade
--      );
--      if (l_return_status = FND_API.G_RET_STS_ERROR) or
--         (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
--        close l_get_navigations_csr;
--        raise FND_API.G_EXC_ERROR;
--      end if;
--    end loop;
--    close l_get_navigations_csr;

end if;

--
-- delete region item once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_regions
where  region_application_id = p_region_application_id
and    region_code = p_region_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REGION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

delete from ak_regions_tl
where  region_application_id = p_region_application_id
and    region_code = p_region_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REGION_DOES_NOT_EXIST');
FND_MESSAGE.SET_TOKEN('OBJECT', 'AK_LC_REGION',TRUE);
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_REGION_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;
end if; -- region exists

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REGION_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_region;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_REGION;

--=======================================================
--  Procedure   DOWNLOAD_REGION
--
--  Usage       Private API for downloading regions. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API will extract the regions selected
--              by application ID or by key values from the
--              database to the output file.
--              If a region is selected for writing to the loader
--              file, all its children records (including region items)
--              will also be written.
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
--              p_get_object_flag : IN required
--                  Call DOWNLOAD_OBJECT API to extract objects that
--                  are referenced by the regions that will be extracted
--                  by this API if this parameter is 'Y'.
--
--              One of the following parameters must be provided:
--
--              p_application_id : IN optional
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--                  p_application_id will be ignored if a table is
--                  given in p_region_pk_tbl.
--              p_region_pk_tbl : IN optional
--                  If given, only regions whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_REGION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_region_pk_tbl            IN OUT NOCOPY     AK_REGION_PUB.Region_PK_Tbl_Type,
p_nls_language             IN      VARCHAR2,
p_get_object_flag          IN      VARCHAR2
) is
cursor l_get_region_list_csr (application_id number) is
select region_application_id, region_code
from   AK_REGIONS
where  REGION_APPLICATION_ID = application_id;
cursor l_get_region_items_csr (region_appl_id_param number,
region_code_param varchar2) is
select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
from   AK_REGION_ITEMS
where  region_application_id = region_appl_id_param
and    region_code = region_code_param
and    object_attribute_flag = 'N';
cursor l_get_target_regions_csr (region_appl_id_param number,
region_code_param varchar2) is
select distinct to_region_appl_id, to_region_code
from   AK_OBJECT_ATTRIBUTE_NAVIGATION aoan, AK_REGIONS ar
where  ar.region_application_id = region_appl_id_param
and    ar.region_code = region_code_param
and    aoan.database_object_name = ar.database_object_name;
cursor l_get_database_object_name_csr (region_appl_id_param number,
region_code_param varchar2) is
select DATABASE_OBJECT_NAME
from   AK_REGIONS
where  region_application_id = region_appl_id_param
and    region_code = region_code_param;
cursor l_get_ri_lov_regions_csr (region_appl_id_param number,
region_code_param varchar2) is
select distinct lov_region_application_id, lov_region_code
from   AK_REGION_ITEMS
where  region_application_id = region_appl_id_param
and    region_code = region_code_param
and    lov_region_application_id is not null
and    lov_region_code is not null;
cursor l_get_oa_lov_regions_csr (region_appl_id_param number,
region_code_param varchar2) is
select distinct aoa.lov_region_application_id, aoa.lov_region_code
from   AK_REGIONS ar, AK_OBJECT_ATTRIBUTES aoa
where  ar.region_application_id = region_appl_id_param
and    ar.region_code = region_code_param
and    ar.database_object_name = aoa.database_object_name
and    aoa.lov_region_application_id is not null
and    aoa.lov_region_code is not null;
cursor l_get_attr_lov_regions_csr (region_appl_id_param number,
region_code_param varchar2) is
select distinct aa.lov_region_application_id, aa.lov_region_code
from   AK_REGION_ITEMS ar, AK_ATTRIBUTES aa
where  ar.region_application_id = region_appl_id_param
and    ar.region_code = region_code_param
and    ar.object_attribute_flag = 'N'
and    ar.attribute_application_id = aa.attribute_application_id
and    ar.attribute_code = aa.attribute_code
and    aa.lov_region_application_id is not null
and    aa.lov_region_code is not null;
cursor l_get_lov_region_items_csr (region_appl_id_param number,
region_code_param varchar2) is
select region_application_id, region_code, attribute_application_id,
attribute_code
from   ak_region_items
where  region_application_id = region_appl_id_param
and    region_code = region_code_param
and    object_attribute_flag = 'N'
and    lov_region_application_id is not null
and    lov_region_code is not null;
cursor l_get_relation_lov_regions_csr (region_appl_id_param number,
region_code_param varchar2,
attribute_appl_id_param number,
attribute_code_param varchar2) is
select distinct lov_region_appl_id, lov_region_code
from   ak_region_lov_relations
where  region_application_id = region_appl_id_param
and    region_code = region_code_param
and    attribute_application_id = attribute_appl_id_param
and    attribute_code = attribute_code_param;

l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Download_Region';
l_attribute_pk_tbl   AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type;
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_object_pk_tbl      AK_OBJECT_PUB.Object_PK_Tbl_Type;
l_index              NUMBER;
l_region_pk_tbl      AK_REGION_PUB.Region_PK_Tbl_Type;
l_return_status      varchar2(1);
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

-- Check that one of the following selection criteria is given:
-- - p_application_id alone, or
-- - a list of region_application_id and region_code in p_object_PK_tbl
if (p_application_id = FND_API.G_MISS_NUM) then
if (p_region_PK_tbl.count = 0) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_NO_SELECTION');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
else
if (p_region_PK_tbl.count > 0) then
-- both application ID and a list of regions to be extracted are
-- given, issue a warning that we will ignore the application ID
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_APPL_ID_IGNORED');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- If selecting by application ID, first load a region primary key tabl
-- with the primary key of all regions for the given application ID.
-- If selecting by a list of regions, simply copy the region primary key
-- table with the parameter
if (p_region_PK_tbl.count > 0) then
l_region_pk_tbl := p_region_pk_tbl;
else
l_index := 1;
open l_get_region_list_csr(p_application_id);
loop
fetch l_get_region_list_csr into
l_region_pk_tbl(l_index).region_appl_id,
l_region_pk_tbl(l_index).region_code;
exit when l_get_region_list_csr%notfound;
l_index := l_index + 1;
end loop;
close l_get_region_list_csr;
end if;

-- Build a list of objects and attributes referenced by all the regions
-- to be extracted from the database. Also add LOV regions and target
-- regions of some object attribute navigation records to the list
-- of regions to be extracted.
--
l_index := l_region_pk_tbl.FIRST;

while (l_index is not null) loop
-- Include regions that are the target regions of some object attribute
-- navigation records of objects that will be extracted along with the
-- given list of regions
for l_region_rec in l_get_target_regions_csr (
l_region_pk_tbl(l_index).region_appl_id,
l_region_pk_tbl(l_index).region_code) LOOP
ak_region_pvt.insert_region_pk_table(
p_return_status => l_return_status,
p_region_application_id => l_region_rec.to_region_appl_id,
p_region_code => l_region_rec.to_region_code,
p_region_pk_tbl => l_region_pk_tbl);
end loop;

-- If the download object flag is 'Y', add
-- the database object referenced by this region to the object
-- list, which will be used to download those objects.
--
if (p_get_object_flag = 'Y')  then
--
-- Add the object referenced by this region to the object list
--
for l_object_rec in l_get_database_object_name_csr(
l_region_pk_tbl(l_index).region_appl_id,
l_region_pk_tbl(l_index).region_code) LOOP
AK_OBJECT_PVT.INSERT_OBJECT_PK_TABLE (
p_return_status => l_return_status,
p_database_object_name => l_object_rec.database_object_name,
p_object_pk_tbl => l_object_pk_tbl);
end loop;

if (AK_DOWNLOAD_GRP.G_DOWNLOAD_ATTR = 'Y') then
-- Get all attributes referenced by all region items in this region
-- and add them to the attribute list
for l_attribute_rec in l_get_region_items_csr (
l_region_pk_tbl(l_index).region_appl_id,
l_region_pk_tbl(l_index).region_code) LOOP
AK_ATTRIBUTE_PVT.INSERT_ATTRIBUTE_PK_TABLE (
p_return_status => l_return_status,
p_attribute_application_id =>
l_attribute_rec.attribute_application_id,
p_attribute_code => l_attribute_rec.attribute_code,
p_attribute_pk_tbl => l_attribute_pk_tbl);
end loop;
end if;

-- Add LOV Region used by all region items in this region
-- to the list of regions to be downloaded
for l_region_rec in l_get_ri_lov_regions_csr (
l_region_pk_tbl(l_index).region_appl_id,
l_region_pk_tbl(l_index).region_code) LOOP
AK_REGION_PVT.INSERT_REGION_PK_TABLE (
p_return_status => l_return_status,
p_region_application_id =>
l_region_rec.lov_region_application_id,
p_region_code => l_region_rec.lov_region_code,
p_region_pk_tbl => l_region_pk_tbl);
end loop;

-- Add LOV Region used by all object attributes in the object
-- referenced by this region to the list of regions to be downloaded
for l_region_rec in l_get_oa_lov_regions_csr (
l_region_pk_tbl(l_index).region_appl_id,
l_region_pk_tbl(l_index).region_code) LOOP
AK_REGION_PVT.INSERT_REGION_PK_TABLE (
p_return_status => l_return_status,
p_region_application_id =>
l_region_rec.lov_region_application_id,
p_region_code => l_region_rec.lov_region_code,
p_region_pk_tbl => l_region_pk_tbl);
end loop;

-- Add LOV Region used by all attributes referenced by any
-- region item to the list of regions to be downloaded
for l_region_rec in l_get_attr_lov_regions_csr (
l_region_pk_tbl(l_index).region_appl_id,
l_region_pk_tbl(l_index).region_code) LOOP
AK_REGION_PVT.INSERT_REGION_PK_TABLE (
p_return_status => l_return_status,
p_region_application_id =>
l_region_rec.lov_region_application_id,
p_region_code => l_region_rec.lov_region_code,
p_region_pk_tbl => l_region_pk_tbl);
end loop;

for l_region_attr_rec in l_get_lov_region_items_csr(
l_region_pk_tbl(l_index).region_appl_id,
l_region_pk_tbl(l_index).region_code) LOOP
for l_region_rec in l_get_relation_lov_regions_csr (
l_region_attr_rec.region_application_id,
l_region_attr_rec.region_code,
l_region_attr_rec.attribute_application_id,
l_region_attr_rec.attribute_code) loop
AK_REGION_PVT.INSERT_REGION_PK_TABLE (
p_return_status => l_return_status,
p_region_application_id =>
l_region_rec.lov_region_appl_id,
p_region_code => l_region_rec.lov_region_code,
p_region_pk_tbl => l_region_pk_tbl);
end loop;
end loop;

-- Add Nested Region used by all region items in this region
-- to the list of regions to be downloaded
AK_REGION_PVT.ADD_NESTED_REG_TO_REG_PK (
p_region_application_id =>
l_region_pk_tbl(l_index).region_appl_id,
p_region_code => l_region_pk_tbl(l_index).region_code,
p_region_pk_tbl => l_region_pk_tbl);


end if; /* if p_get_object_flag = 'Y' */

-- Ready to download the next region in the list
l_index := l_region_pk_tbl.NEXT(l_index);
end loop;

-- set l_index to the last index number in the region table
l_index := l_region_pk_tbl.LAST;

--
-- If the get object flag is 'Y', call download_object to retrieve
-- all objects and attributes referenced by any of the selected regions.
if (p_get_object_flag = 'Y') then
if (l_object_pk_tbl.count > 0)  then
AK_OBJECT2_PVT.DOWNLOAD_OBJECT (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_object_pk_tbl => l_object_pk_tbl,
p_attribute_pk_tbl => l_attribute_pk_tbl,
p_nls_language => p_nls_language,
p_get_region_flag => 'N'
);

if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
-- dbms_output.put_line(l_api_name || ' Error downloading objects');
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

if (AK_DOWNLOAD_GRP.G_DOWNLOAD_REG = 'Y') then
-- Write details for each selected region, including its items, to a
-- buffer to be passed back to the calling procedure.
l_index := l_region_pk_tbl.FIRST;

while (l_index is not null) loop
--
-- Write region information from the database
--
--dbms_output.put_line('writing region #'||to_char(l_index) || ':' ||
--                      l_region_pk_tbl(l_index).region_code);

if ( (l_region_pk_tbl(l_index).region_appl_id <> FND_API.G_MISS_NUM) and
(l_region_pk_tbl(l_index).region_appl_id is not null) and
(l_region_pk_tbl(l_index).region_code <> FND_API.G_MISS_CHAR) and
(l_region_pk_tbl(l_index).region_code is not null) ) then
WRITE_TO_BUFFER(
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_region_application_id => l_region_pk_tbl(l_index).region_appl_id,
p_region_code => l_region_pk_tbl(l_index).region_code,
p_nls_language => p_nls_language
);
end if;

if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

-- Ready to download the next region in the list
l_index := l_region_pk_tbl.NEXT(l_index);
end loop;
end if; /*G_DOWNLOAD_REG*/

p_region_pk_tbl := l_region_pk_tbl;
p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REGION_PK_VALUE_ERROR');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Value error occurred - check your region list.');
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
--dbms_output.put_line(SUBSTR(SQLERRM,1,240));
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end DOWNLOAD_REGION;

--=======================================================
--  Procedure   INSERT_REGION_PK_TABLE
--
--  Usage       Private API for inserting the given region's
--              primary key value into the given object
--              table.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API inserts the given region's primary
--              key value into a given region table
--              (of type Object_PK_Tbl_Type) only if the
--              primary key does not already exist in the table.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the region to be inserted to the
--                  table.
--              p_region_pk_tbl : IN OUT
--                  Region table to be updated.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure INSERT_REGION_PK_TABLE (
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_region_pk_tbl            IN OUT NOCOPY  AK_REGION_PUB.Region_PK_Tbl_Type
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Insert_Region_PK_Table';
l_index         NUMBER;
begin
--
-- if table is empty, just insert the region primary key into it
--
if (p_region_pk_tbl.count = 0) then
--dbms_output.put_line('Inserted region: ' || p_region_code ||
--                     ' into element #1');
p_region_pk_tbl(1).region_appl_id := p_region_application_id;
p_region_pk_tbl(1).region_code := p_region_code;
return;
end if;

--
-- otherwise, insert the region to the end of the table if it is
-- not already in the table. If it is already in the table, return
-- without changing the table.
--
for l_index in p_region_pk_tbl.FIRST .. p_region_pk_tbl.LAST loop
if (p_region_pk_tbl.exists(l_index)) then
if (p_region_pk_tbl(l_index).region_appl_id = p_region_application_id)
and
(p_region_pk_tbl(l_index).region_code = p_region_code) then
return;
end if;
end if;
end loop;

--dbms_output.put_line('Inserted region: ' || p_region_code ||
--                     ' into element #' || to_char(p_region_pk_tbl.LAST + 1));
l_index := p_region_pk_tbl.LAST + 1;
p_region_pk_tbl(l_index).region_appl_id := p_region_application_id;
p_region_pk_tbl(l_index).region_code := p_region_code;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end INSERT_REGION_PK_TABLE;

/*
--=======================================================
--  Function    GRAPH_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region graph with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region graph record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Graph key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function GRAPH_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_graph_number	     IN	     NUMBER
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_REGION_GRAPHS
where region_application_id = p_region_application_id
and   region_code = p_region_code
and   graph_number = p_graph_number;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Item_Exists';
l_dummy              number;
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

open l_check_csr;
fetch l_check_csr into l_dummy;
if (l_check_csr%notfound) then
close l_check_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_check_csr;
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

end GRAPH_EXISTS;
*/

--=======================================================
--  Function    ITEM_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region item with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region item record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Item key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function ITEM_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_REGION_ITEMS
where region_application_id = p_region_application_id
and   region_code = p_region_code
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Item_Exists';
l_dummy              number;
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

open l_check_csr;
fetch l_check_csr into l_dummy;
if (l_check_csr%notfound) then
close l_check_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_check_csr;
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

end ITEM_EXISTS;

--=======================================================
--  Function    REGION_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function REGION_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2
) return BOOLEAN is
cursor l_check_region_csr is
select 1
from  AK_REGIONS
where region_application_id = p_region_application_id
and   region_code = p_region_code;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Region_Exists';
l_dummy              number;
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

open l_check_region_csr;
fetch l_check_region_csr into l_dummy;
if (l_check_region_csr%notfound) then
close l_check_region_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_check_region_csr;
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
end REGION_EXISTS;

/*
--=======================================================
--  Procedure   UPDATE_GRAPH
--
--  Usage       Private API for updating a region graph.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region graph using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Graph columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_GRAPH (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_graph_number	     IN      NUMBER,
p_graph_style		     IN      NUMBER := FND_API.G_MISS_NUM,
p_display_flag	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_depth_radius	     IN      NUMBER := FND_API.G_MISS_NUM,
p_graph_title		     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_y_axis_label	     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
cursor l_get_row_csr is
select *
from  AK_REGION_GRAPHS
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   GRAPH_NUMBER = p_graph_number
for update of GRAPH_STYLE;
cursor l_get_tl_row_csr (lang_parm varchar2) is
select *
from  AK_REGION_GRAPHS_TL
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   GRAPH_NUMBER = p_graph_number
and   LANGUAGE = lang_parm
for update of GRAPH_TITLE;
l_api_version_number     CONSTANT number := 1.0;
l_api_name               CONSTANT varchar2(30) := 'Update_Graph';
l_created_by             number;
l_creation_date          date;
l_graphs_rec              ak_region_graphs%ROWTYPE;
l_graphs_tl_rec           ak_region_graphs_tl%ROWTYPE;
l_error                  boolean;
l_lang                   varchar2(30);
l_last_update_date       date;
l_last_update_login      number;
l_last_updated_by        number;
l_return_status          varchar2(1);
l_submit                                      varchar2(1) := 'N';
l_encrypt                                     varchar2(1) := 'N';
l_admin_customizable	 			varchar2(1) := 'Y';
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

savepoint start_update_graph;

select userenv('LANG') into l_lang
from dual;

--** retrieve ak_region_graphs row if it exists **
open l_get_row_csr;
fetch l_get_row_csr into l_graphs_rec;
if (l_get_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || 'Error - Row does not exist');
close l_get_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_row_csr;

--** retrieve ak_region_graphss_tl row if it exists **
open l_get_tl_row_csr(l_lang);
fetch l_get_tl_row_csr into l_graphs_tl_rec;
if (l_get_tl_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line(l_api_name || 'Error - TL Row does not exist');
close l_get_tl_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_tl_row_csr;

--
-- validate table columns passed in
--
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not VALIDATE_GRAPH (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_graph_number => p_graph_number,
p_graph_style => p_graph_style,
p_display_flag => p_display_flag,
p_depth_radius => p_depth_radius,
p_graph_title => p_graph_title,
p_y_axis_label => p_y_axis_label,
p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
p_pass => p_pass
) then
--dbms_output.put_line(l_api_name || ' validation failed');
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

--** Load record to be updated to the database **
--** - first load nullable columns **

if (p_display_flag <> FND_API.G_MISS_CHAR) or
(p_display_flag is null) then
l_graphs_rec.display_flag := p_display_flag;
end if;

if (p_depth_radius <> FND_API.G_MISS_NUM) or
(p_depth_radius is null) then
l_graphs_rec.depth_radius := p_depth_radius;
end if;

if (p_graph_title <> FND_API.G_MISS_CHAR) or
(p_graph_title is null) then
l_graphs_tl_rec.graph_title := p_graph_title;
end if;

if (p_y_axis_label <> FND_API.G_MISS_CHAR) or
(p_y_axis_label is null) then
l_graphs_tl_rec.y_axis_label := p_y_axis_label;
end if;

--** - next, load non-null columns **

if (p_graph_style <> FND_API.G_MISS_NUM) then
l_graphs_rec.graph_style := p_graph_style;
end if;

-- Set WHO columns
AK_UPLOAD_GRP.G_UPLOAD_DATE := p_last_update_date;
AK_ON_OBJECTS_PVT.SET_WHO (
p_return_status => l_return_status,
p_loader_timestamp => p_loader_timestamp,
p_created_by => l_created_by,
p_creation_date => l_creation_date,
p_last_updated_by => l_last_updated_by,
p_last_update_date => l_last_update_date,
p_last_update_login => l_last_update_login);

  if (AK_UPLOAD_GRP.G_NON_SEED_DATA) then
        l_created_by := p_created_by;
        l_last_updated_by := p_last_updated_by;
        l_last_update_login := p_last_update_login;
  end if;

update AK_REGION_GRAPHS set
GRAPH_STYLE = l_graphs_rec.graph_style,
DISPLAY_FLAG = l_graphs_rec.display_flag,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   GRAPH_NUMBER = p_graph_number;
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line(l_api_name || 'Row does not exist during update');
raise FND_API.G_EXC_ERROR;
end if;

update AK_REGION_GRAPHS_TL set
GRAPH_TITLE = l_graphs_tl_rec.graph_title,
Y_AXIS_LABEL = l_graphs_tl_rec.y_axis_label,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATE_LOGIN = l_last_update_login,
SOURCE_LANG = l_lang
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   GRAPH_NUMBER = p_graph_number
and   l_lang in (LANGUAGE, SOURCE_LANG);
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || 'TL Row does not exist during update');
raise FND_API.G_EXC_ERROR;
end if;

--  ** commit the update **
commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || p_graph_number);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || p_graph_number);
FND_MSG_PUB.Add;
end if;
rollback to start_update_graph;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_GRAPH_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || p_graph_number);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_graph;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end UPDATE_GRAPH;
*/

--=======================================================
--  Procedure   UPDATE_ITEM
--
--  Usage       Private API for updating a region item.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region item using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_ITEM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_display_sequence         IN      NUMBER := FND_API.G_MISS_NUM,
p_node_display_flag        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_node_query_flag          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_display_value_length     IN      NUMBER := FND_API.G_MISS_NUM,
p_bold                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_italic                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_vertical_alignment       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_horizontal_alignment     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_item_style               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_object_attribute_flag    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_icx_custom_call          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_update_flag              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_required_flag            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_security_code            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_foreign_key_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_attribute_application_id IN  NUMBER := FND_API.G_MISS_NUM,
p_lov_attribute_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_default_flag         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_defaulting_api_pkg IN     VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_defaulting_api_proc IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_validation_api_pkg IN     VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_validation_api_proc IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_order_sequence           IN      NUMBER := FND_API.G_MISS_NUM,
p_order_direction          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_display_height			 IN		 NUMBER := FND_API.G_MISS_NUM,
p_submit					 IN		 VARCHAR2,
p_encrypt					 IN		 VARCHAR2,
p_css_class_name				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_view_usage_name			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_view_attribute_name		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_nested_region_appl_id	 IN		 NUMBER := FND_API.G_MISS_NUM,
p_nested_region_code		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_url						 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_viewobject		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_display_attr	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_value_attr		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_image_file_name			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_item_name				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_css_label_class_name	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_menu_name		     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_name	     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_application_id IN	     NUMBER   := FND_API.G_MISS_NUM,
p_tabular_function_code    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_type                 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_application_id   IN      NUMBER   := FND_API.G_MISS_NUM,
p_flex_segment_list        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_entity_id                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_anchor                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_view_usage_name  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_user_customizable	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_sortby_view_attribute_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_admin_customizable		IN	VARCHAR2,
p_invoke_function_name	IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_expansion		     IN      NUMBER   := FND_API.G_MISS_NUM,
p_als_max_length	     IN      NUMBER   := FND_API.G_MISS_NUM,
p_initial_sort_sequence    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_application_id IN  NUMBER   := FND_API.G_MISS_NUM,
p_customization_code	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_description				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
cursor l_get_row_csr is
select *
from  AK_REGION_ITEMS
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code
for   update of DISPLAY_SEQUENCE;
cursor l_get_tl_row_csr (lang_parm varchar2) is
select *
from  AK_REGION_ITEMS_TL
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code
and   LANGUAGE = lang_parm
for update of ATTRIBUTE_LABEL_LONG;
l_api_version_number     CONSTANT number := 1.0;
l_api_name               CONSTANT varchar2(30) := 'Update_Item';
l_created_by             number;
l_creation_date          date;
l_items_rec              ak_region_items%ROWTYPE;
l_items_tl_rec           ak_region_items_tl%ROWTYPE;
l_error                  boolean;
l_lang                   varchar2(30);
l_last_update_date       date;
l_last_update_login      number;
l_last_updated_by        number;
l_object_attribute_flag  VARCHAR2(1);
l_return_status          varchar2(1);
l_submit					varchar2(1) := 'N';
l_encrypt					varchar2(1) := 'N';
l_admin_customizable				varchar2(1) := 'Y';
l_file_version	number;
l_create_or_update       VARCHAR2(10);
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

savepoint start_update_item;

select userenv('LANG') into l_lang
from dual;

--** retrieve ak_region_items row if it exists **
open l_get_row_csr;
fetch l_get_row_csr into l_items_rec;
if (l_get_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || 'Error - Row does not exist');
close l_get_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_row_csr;

--** retrieve ak_region_items_tl row if it exists **
open l_get_tl_row_csr(l_lang);
fetch l_get_tl_row_csr into l_items_tl_rec;
if (l_get_tl_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line(l_api_name || 'Error - TL Row does not exist');
close l_get_tl_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_tl_row_csr;

--
-- If the object_attribute_flag is missing, pass the value in the
-- database to the validate_item procedure. This is done such that
-- the validate_item procedure can check the validity of attribute
-- key fields against ak_attributes or ak_object_attributes.
--
if (p_object_attribute_flag = FND_API.G_MISS_CHAR) then
l_object_attribute_flag := l_items_rec.object_attribute_flag;
else
l_object_attribute_flag := p_object_attribute_flag;
end if;

if (p_display_sequence IS NOT NULL) and
(p_display_sequence <> FND_API.G_MISS_NUM) then
--** Check the given display sequence number
AK_REGION2_PVT.CHECK_DISPLAY_SEQUENCE (  p_validation_level => p_validation_level,
p_region_code => p_region_code,
p_region_application_id => p_region_application_id,
p_attribute_code => p_attribute_code,
p_attribute_application_id => p_attribute_application_id,
p_display_sequence => p_display_sequence,
p_return_status => l_return_status,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_pass => p_pass,
p_copy_redo_flag => p_copy_redo_flag);
end if;

--
-- validate table columns passed in
-- ** Note the special processing for object_attribute_flag **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_REGION_PVT.VALIDATE_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_display_sequence => p_display_sequence,
p_node_display_flag => p_node_display_flag,
p_node_query_flag => p_node_query_flag,
p_attribute_label_length => p_attribute_label_length,
p_display_value_length => p_display_value_length,
p_bold => p_bold,
p_italic => p_italic,
p_vertical_alignment => p_vertical_alignment,
p_horizontal_alignment => p_horizontal_alignment,
p_item_style => p_item_style,
p_object_attribute_flag => l_object_attribute_flag,
p_icx_custom_call => p_icx_custom_call,
p_update_flag => p_update_flag,
p_required_flag => p_required_flag,
p_security_code => p_security_code,
p_default_value_varchar2 => p_default_value_varchar2,
p_default_value_number => p_default_value_number,
p_default_value_date => p_default_value_date,
p_nested_region_appl_id => p_nested_region_appl_id,
p_nested_region_code => p_nested_region_code,
p_lov_region_application_id => p_lov_region_application_id,
p_lov_region_code => p_lov_region_code,
p_lov_foreign_key_name => p_lov_foreign_key_name,
p_lov_attribute_application_id => p_lov_attribute_application_id,
p_lov_attribute_code => p_lov_attribute_code,
p_lov_default_flag => p_lov_default_flag,
p_region_defaulting_api_pkg => p_region_defaulting_api_pkg,
p_region_defaulting_api_proc => p_region_defaulting_api_proc,
p_region_validation_api_pkg => p_region_validation_api_pkg,
p_region_validation_api_proc => p_region_validation_api_proc,
p_order_sequence => p_order_sequence,
p_order_direction => p_order_direction,
p_menu_name => p_menu_name,
p_flexfield_name => p_flexfield_name,
p_flexfield_application_id => p_flexfield_application_id,
p_tabular_function_code    => p_tabular_function_code,
p_tip_type                 => p_tip_type,
p_tip_message_name          => p_tip_message_name,
p_tip_message_application_id  => p_tip_message_application_id ,
p_flex_segment_list        => p_flex_segment_list,
p_entity_id                => p_entity_id,
p_anchor                   => p_anchor,
p_poplist_view_usage_name  => p_poplist_view_usage_name,
p_user_customizable	       => p_user_customizable,
p_sortby_view_attribute_name => p_sortby_view_attribute_name,
p_invoke_function_name	=> p_invoke_function_name,
p_expansion			=> p_expansion,
p_als_max_length		=> p_als_max_length,
p_initial_sort_sequence     => p_initial_sort_sequence,
p_customization_application_id => p_customization_application_id,
p_customization_code => p_customization_application_id,
p_attribute_label_long => p_attribute_label_long,
p_attribute_label_short => p_attribute_label_short,
p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
p_pass => p_pass
) then
--dbms_output.put_line(l_api_name || ' validation failed');
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

--** Load record to be updated to the database **
--** - first load nullable columns **

if (p_icx_custom_call <> FND_API.G_MISS_CHAR) or
(p_icx_custom_call is null) then
l_items_rec.icx_custom_call := p_icx_custom_call;
end if;

if (p_security_code <> FND_API.G_MISS_CHAR) or
(p_security_code is null) then
l_items_rec.security_code := p_security_code;
end if;

if (p_default_value_varchar2 <> FND_API.G_MISS_CHAR) or
(p_default_value_varchar2 is null) then
l_items_rec.default_value_varchar2 := p_default_value_varchar2;
end if;

if (p_default_value_number <> FND_API.G_MISS_NUM) or
(p_default_value_number is null) then
l_items_rec.default_value_number := p_default_value_number;
end if;

if (p_default_value_date <> FND_API.G_MISS_DATE) or
(p_default_value_date is null) then
l_items_rec.default_value_date := p_default_value_date;
end if;

if (p_lov_region_application_id <> FND_API.G_MISS_NUM) or
(p_lov_region_application_id is null) then
l_items_rec.lov_region_application_id := p_lov_region_application_id;
end if;

if (p_lov_region_code <> FND_API.G_MISS_CHAR) or
(p_lov_region_code is null) then
l_items_rec.lov_region_code := p_lov_region_code;
end if;

if (p_lov_foreign_key_name <> FND_API.G_MISS_CHAR) or
(p_lov_foreign_key_name is null) then
l_items_rec.lov_foreign_key_name := p_lov_foreign_key_name;
end if;

if (p_lov_attribute_application_id <> FND_API.G_MISS_NUM) or
(p_lov_attribute_application_id is null) then
l_items_rec.lov_attribute_application_id := p_lov_attribute_application_id;
end if;

if (p_lov_attribute_code <> FND_API.G_MISS_CHAR) or
(p_lov_attribute_code is null) then
l_items_rec.lov_attribute_code := p_lov_attribute_code;
end if;

if (p_lov_default_flag <> FND_API.G_MISS_CHAR) or
(p_lov_default_flag is null) then
l_items_rec.lov_default_flag := p_lov_default_flag;
end if;

if (p_region_defaulting_api_pkg <> FND_API.G_MISS_CHAR) or
(p_region_defaulting_api_pkg is null) then
l_items_rec.region_defaulting_api_pkg := p_region_defaulting_api_pkg;
end if;

if (p_region_defaulting_api_proc <> FND_API.G_MISS_CHAR) or
(p_region_defaulting_api_proc is null) then
l_items_rec.region_defaulting_api_proc := p_region_defaulting_api_proc;
end if;

if (p_region_validation_api_pkg <> FND_API.G_MISS_CHAR) or
(p_region_validation_api_pkg is null) then
l_items_rec.region_validation_api_pkg := p_region_validation_api_pkg;
end if;

if (p_region_validation_api_proc <> FND_API.G_MISS_CHAR) or
(p_region_validation_api_proc is null) then
l_items_rec.region_validation_api_proc := p_region_validation_api_proc;
end if;

if (p_order_sequence <> FND_API.G_MISS_NUM) or
(p_order_sequence is null) then
l_items_rec.order_sequence := p_order_sequence;
end if;

if (p_order_direction <> FND_API.G_MISS_CHAR) or
(p_order_direction is null) then
l_items_rec.order_direction := p_order_direction;
end if;

if (p_display_height <> FND_API.G_MISS_NUM) then
l_items_rec.display_height := p_display_height;
end if;

if (p_css_class_name <> FND_API.G_MISS_CHAR) or
(p_css_class_name is null) then
l_items_rec.css_class_name := p_css_class_name;
end if;

if (p_view_usage_name <> FND_API.G_MISS_CHAR) or
(p_view_usage_name is null) then
l_items_rec.view_usage_name := p_view_usage_name;
end if;

if (p_view_attribute_name <> FND_API.G_MISS_CHAR) or
(p_view_attribute_name is null) then
l_items_rec.view_attribute_name := p_view_attribute_name;
end if;

if (p_nested_region_appl_id <> FND_API.G_MISS_NUM) or
(p_nested_region_appl_id is null) then
l_items_rec.nested_region_application_id := p_nested_region_appl_id;
end if;

if (p_nested_region_code <> FND_API.G_MISS_CHAR) or
(p_nested_region_code is null) then
l_items_rec.nested_region_code := p_nested_region_code;
end if;

if (p_url <> FND_API.G_MISS_CHAR) or
(p_url is null) then
l_items_rec.url := p_url;
end if;

if (p_poplist_viewobject <> FND_API.G_MISS_CHAR) or
(p_poplist_viewobject is null) then
l_items_rec.poplist_viewobject := p_poplist_viewobject;
end if;

if (p_poplist_display_attr <> FND_API.G_MISS_CHAR) or
(p_poplist_display_attr is null) then
l_items_rec.poplist_display_attribute := p_poplist_display_attr;
end if;

if (p_poplist_value_attr <> FND_API.G_MISS_CHAR) or
(p_poplist_value_attr is null) then
l_items_rec.poplist_value_attribute := p_poplist_value_attr;
end if;

if (p_image_file_name <> FND_API.G_MISS_CHAR) or
(p_image_file_name is null) then
l_items_rec.image_file_name := p_image_file_name;
end if;

if (p_item_name <> FND_API.G_MISS_CHAR) or
(p_item_name is null) then
l_items_rec.item_name := p_item_name;
end if;

if (p_css_label_class_name <> FND_API.G_MISS_CHAR) or
(p_css_label_class_name is null) then
l_items_rec.css_label_class_name := p_css_label_class_name;
end if;

if (p_menu_name <> FND_API.G_MISS_CHAR) or
(p_menu_name is null) then
l_items_rec.menu_name := p_menu_name;
end if;

if (p_flexfield_name <> FND_API.G_MISS_CHAR) or
(p_flexfield_name is null) then
l_items_rec.flexfield_name := p_flexfield_name;
end if;

if (p_flexfield_application_id <> FND_API.G_MISS_NUM) or
(p_flexfield_application_id is null) then
l_items_rec.flexfield_application_id := p_flexfield_application_id;
end if;

if (p_tabular_function_code <> FND_API.G_MISS_CHAR) or
(p_tabular_function_code is null) then
l_items_rec.tabular_function_code := p_tabular_function_code;
end if;

if (p_tip_type <> FND_API.G_MISS_CHAR) or
(p_tip_type is null) then
l_items_rec.tip_type := p_tip_type;
end if;

if (p_tip_message_name <> FND_API.G_MISS_CHAR) or
(p_tip_message_name is null) then
l_items_rec.tip_message_name := p_tip_message_name;
end if;

if (p_tip_message_application_id <> FND_API.G_MISS_NUM) or
(p_tip_message_application_id is null) then
l_items_rec.tip_message_application_id := p_tip_message_application_id;
end if;

if (p_flex_segment_list <> FND_API.G_MISS_CHAR) or
(p_flex_segment_list is null) then
l_items_rec.flex_segment_list := p_flex_segment_list;
end if;

if (p_entity_id <> FND_API.G_MISS_CHAR) or
(p_entity_id is null) then
l_items_rec.entity_id := p_entity_id;
end if;

if (p_anchor <> FND_API.G_MISS_CHAR or p_anchor is null) then
l_items_rec.anchor := p_anchor;
end if;

if (p_poplist_view_usage_name <> FND_API.G_MISS_CHAR) or
(p_poplist_view_usage_name is null) then
l_items_rec.poplist_view_usage_name := p_poplist_view_usage_name;
end if;

if (p_user_customizable <> FND_API.G_MISS_CHAR) or
(p_user_customizable is null) then
l_items_rec.user_customizable := p_user_customizable;
end if;

if (p_sortby_view_attribute_name <> FND_API.G_MISS_CHAR) or
(p_sortby_view_attribute_name is null) then
l_items_rec.sortby_view_attribute_name := p_sortby_view_attribute_name;
end if;

if (p_invoke_function_name <> FND_API.G_MISS_CHAR) or
(p_invoke_function_name is null) then
l_items_rec.invoke_function_name := p_invoke_function_name;
end if;

if (p_expansion <> FND_API.G_MISS_NUM) or
(p_expansion is null) then
l_items_rec.expansion := p_expansion;
end if;

if (p_als_max_length <> FND_API.G_MISS_NUM) or
(p_als_max_length is null) then
l_items_rec.als_max_length := p_als_max_length;
end if;

if (p_initial_sort_sequence <> FND_API.G_MISS_CHAR) or
(p_initial_sort_sequence is null) then
l_items_rec.initial_sort_sequence := p_initial_sort_sequence;
end if;

if (p_customization_application_id <> FND_API.G_MISS_NUM) or
(p_customization_application_id is null) then
l_items_rec.customization_application_id := p_customization_application_id;
end if;

if (p_customization_code <> FND_API.G_MISS_CHAR) or
(p_customization_code is null) then
l_items_rec.customization_code := p_customization_code;
end if;

if (p_attribute_category <> FND_API.G_MISS_CHAR) or
(p_attribute_category is null) then
l_items_rec.attribute_category := p_attribute_category;
end if;
if (p_attribute1 <> FND_API.G_MISS_CHAR) or
(p_attribute1 is null) then
l_items_rec.attribute1 := p_attribute1;
end if;
if (p_attribute2 <> FND_API.G_MISS_CHAR) or
(p_attribute2 is null) then
l_items_rec.attribute2 := p_attribute2;
end if;
if (p_attribute3 <> FND_API.G_MISS_CHAR) or
(p_attribute3 is null) then
l_items_rec.attribute3 := p_attribute3;
end if;
if (p_attribute4 <> FND_API.G_MISS_CHAR) or
(p_attribute4 is null) then
l_items_rec.attribute4 := p_attribute4;
end if;
if (p_attribute5 <> FND_API.G_MISS_CHAR) or
(p_attribute5 is null) then
l_items_rec.attribute5 := p_attribute5;
end if;
if (p_attribute6 <> FND_API.G_MISS_CHAR) or
(p_attribute6 is null) then
l_items_rec.attribute6 := p_attribute6;
end if;
if (p_attribute7 <> FND_API.G_MISS_CHAR) or
(p_attribute7 is null) then
l_items_rec.attribute7 := p_attribute7;
end if;
if (p_attribute8 <> FND_API.G_MISS_CHAR) or
(p_attribute8 is null) then
l_items_rec.attribute8 := p_attribute8;
end if;
if (p_attribute9 <> FND_API.G_MISS_CHAR) or
(p_attribute9 is null) then
l_items_rec.attribute9 := p_attribute9;
end if;
if (p_attribute10 <> FND_API.G_MISS_CHAR) or
(p_attribute10 is null) then
l_items_rec.attribute10 := p_attribute10;
end if;
if (p_attribute11 <> FND_API.G_MISS_CHAR) or
(p_attribute11 is null) then
l_items_rec.attribute11 := p_attribute11;
end if;
if (p_attribute12 <> FND_API.G_MISS_CHAR) or
(p_attribute12 is null) then
l_items_rec.attribute12 := p_attribute12;
end if;
if (p_attribute13 <> FND_API.G_MISS_CHAR) or
(p_attribute13 is null) then
l_items_rec.attribute13 := p_attribute13;
end if;

if (p_attribute14 <> FND_API.G_MISS_CHAR) or
(p_attribute14 is null) then
l_items_rec.attribute14 := p_attribute14;
end if;

if (p_attribute15 <> FND_API.G_MISS_CHAR) or
(p_attribute15 is null) then
l_items_rec.attribute15 := p_attribute15;
end if;

if (p_attribute_label_long <> FND_API.G_MISS_CHAR) or
(p_attribute_label_long is null) then
l_items_tl_rec.attribute_label_long := p_attribute_label_long;
end if;

if (p_attribute_label_short <> FND_API.G_MISS_CHAR) or
(p_attribute_label_short is null) then
l_items_tl_rec.attribute_label_short := p_attribute_label_short;
end if;

if (p_description <> FND_API.G_MISS_CHAR) or
(p_description is null) then
l_items_tl_rec.description := p_description;
end if;

--** - next, load non-null columns **

if (p_display_sequence<> FND_API.G_MISS_NUM) then
l_items_rec.display_sequence := p_display_sequence;
end if;
if (p_node_display_flag <> FND_API.G_MISS_CHAR) then
l_items_rec.node_display_flag := p_node_display_flag;
end if;
if (p_node_query_flag <> FND_API.G_MISS_CHAR) then
l_items_rec.node_query_flag := p_node_query_flag;
end if;
if (p_attribute_label_length <> FND_API.G_MISS_NUM) then
l_items_rec.attribute_label_length := p_attribute_label_length;
end if;
if (p_display_value_length <> FND_API.G_MISS_NUM) then
l_items_rec.display_value_length := p_display_value_length;
end if;
if (p_bold <> FND_API.G_MISS_CHAR) then
l_items_rec.bold := p_bold;
end if;
if (p_italic <> FND_API.G_MISS_CHAR) then
l_items_rec.italic := p_italic;
end if;
if (p_vertical_alignment <> FND_API.G_MISS_CHAR) then
l_items_rec.vertical_alignment := p_vertical_alignment;
end if;
if (p_horizontal_alignment <> FND_API.G_MISS_CHAR) then
l_items_rec.horizontal_alignment := p_horizontal_alignment;
end if;
if (p_item_style <> FND_API.G_MISS_CHAR) then
l_items_rec.item_style := p_item_style;
end if;
if (p_object_attribute_flag <> FND_API.G_MISS_CHAR) then
l_items_rec.object_attribute_flag := p_object_attribute_flag;
end if;
if (p_update_flag <> FND_API.G_MISS_CHAR) then
l_items_rec.update_flag := p_update_flag;
end if;
--
-- special logic for handling update_flag, bug#2054285
-- set update_flag to 'Y'
-- do not change update_flag to 'Y' if FILE_FORMAT_VERSION > 115.14
--
if ( ( AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER1 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER2 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER3 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER4 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER5 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER6 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER7 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER8 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER9 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER11 or
AK_ON_OBJECTS_PUB.G_UPLOAD_FILE_VERSION = AK_ON_OBJECTS_PUB.G_OLD_FILE_FORMAT_VER12 ) and
( p_item_style = 'CHECKBOX' or p_item_style = 'DESCRIPTIVE_FLEX' or
p_item_style = 'KEY_FLEX' or p_item_style = 'FILE' or
p_item_style = 'FORM_PARAMETER_BEAN' or p_item_style = 'RADIO_BUTTON' or
p_item_style  = 'POPLIST' or p_item_style = 'HIDDEN' or
p_item_style = 'TEXT_INPUT' or p_item_style = 'RADIO_GROUP') and
INSTR(p_region_code,'POR') <> 1 ) then
l_items_rec.update_flag := 'Y';
end if;


if (p_required_flag <> FND_API.G_MISS_CHAR) then
l_items_rec.required_flag := p_required_flag;
end if;
if (p_submit <> FND_API.G_MISS_CHAR and p_submit is not null) then
l_items_rec.submit := p_submit;
else
l_items_rec.submit := l_submit;
end if;
if (p_encrypt <> FND_API.G_MISS_CHAR and p_encrypt is not null) then
l_items_rec.encrypt := p_encrypt;
else
l_items_rec.encrypt := l_encrypt;
end if;
if (p_admin_customizable <> FND_API.G_MISS_CHAR and p_admin_customizable is not null) then
l_items_rec.admin_customizable := p_admin_customizable;
else
l_items_rec.admin_customizable := l_admin_customizable;
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

  /* 5452422 - if display_sequence has been raised then force update */
  if (p_display_sequence >= 1000000) then
	l_create_or_update := 'FORCE';
  else
	l_create_or_update := 'UPDATE';
  end if;

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_items_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_items_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => l_create_or_update) then

update AK_REGION_ITEMS set
DISPLAY_SEQUENCE = l_items_rec.display_sequence,
NODE_DISPLAY_FLAG = l_items_rec.node_display_flag,
NODE_QUERY_FLAG = l_items_rec.node_query_flag,
ATTRIBUTE_LABEL_LENGTH = l_items_rec.attribute_label_length,
DISPLAY_VALUE_LENGTH = l_items_rec.display_value_length,
BOLD = l_items_rec.bold,
ITALIC = l_items_rec.italic,
VERTICAL_ALIGNMENT = l_items_rec.vertical_alignment,
HORIZONTAL_ALIGNMENT = l_items_rec.horizontal_alignment,
ITEM_STYLE = l_items_rec.item_style,
OBJECT_ATTRIBUTE_FLAG = l_items_rec.object_attribute_flag,
ICX_CUSTOM_CALL = l_items_rec.icx_custom_call,
UPDATE_FLAG = l_items_rec.update_flag,
REQUIRED_FLAG = l_items_rec.required_flag,
SECURITY_CODE = l_items_rec.security_code,
DEFAULT_VALUE_VARCHAR2 = l_items_rec.default_value_varchar2,
DEFAULT_VALUE_NUMBER = l_items_rec.default_value_number,
DEFAULT_VALUE_DATE = l_items_rec.default_value_date,
LOV_REGION_APPLICATION_ID = l_items_rec.lov_region_application_id,
LOV_REGION_CODE = l_items_rec.lov_region_code,
LOV_FOREIGN_KEY_NAME = l_items_rec.lov_foreign_key_name,
LOV_ATTRIBUTE_APPLICATION_ID =
l_items_rec.lov_attribute_application_id,
LOV_ATTRIBUTE_CODE = l_items_rec.lov_attribute_code,
LOV_DEFAULT_FLAG = l_items_rec.lov_default_flag,
REGION_DEFAULTING_API_PKG = l_items_rec.region_defaulting_api_pkg,
REGION_DEFAULTING_API_PROC = l_items_rec.region_defaulting_api_proc,
REGION_VALIDATION_API_PKG = l_items_rec.region_validation_api_pkg,
REGION_VALIDATION_API_PROC = l_items_rec.region_validation_api_proc,
ORDER_SEQUENCE = l_items_rec.order_sequence,
ORDER_DIRECTION = l_items_rec.order_direction,
DISPLAY_HEIGHT = l_items_rec.display_height,
SUBMIT = l_items_rec.submit,
ENCRYPT = l_items_rec.encrypt,
css_class_name = l_items_rec.css_class_name,
VIEW_USAGE_NAME = l_items_rec.view_usage_name,
VIEW_ATTRIBUTE_NAME = l_items_rec.view_attribute_name,
NESTED_REGION_APPLICATION_ID = l_items_rec.nested_region_application_id,
NESTED_REGION_CODE = l_items_rec.nested_region_code,
URL = l_items_rec.url,
POPLIST_VIEWOBJECT = l_items_rec.poplist_viewobject,
POPLIST_DISPLAY_ATTRIBUTE = l_items_rec.poplist_display_attribute,
POPLIST_VALUE_ATTRIBUTE = l_Items_rec.poplist_value_attribute,
IMAGE_FILE_NAME = l_items_rec.image_file_name,
ITEM_NAME = l_items_rec.item_name,
CSS_LABEL_CLASS_NAME = l_items_rec.css_label_class_name,
MENU_NAME = l_items_rec.menu_name,
FLEXFIELD_NAME = l_items_rec.flexfield_name,
FLEXFIELD_APPLICATION_ID = l_items_rec.flexfield_application_id,
TABULAR_FUNCTION_CODE = l_items_rec.tabular_function_code,
TIP_TYPE  = l_items_rec.tip_type,
TIP_MESSAGE_NAME = l_items_rec.tip_message_name,
TIP_MESSAGE_APPLICATION_ID = l_items_rec.tip_message_application_id,
FLEX_SEGMENT_LIST = l_items_rec.flex_segment_list,
ENTITY_ID = l_items_rec.entity_id,
ANCHOR = l_items_rec.anchor,
POPLIST_VIEW_USAGE_NAME = l_items_rec.poplist_view_usage_name,
USER_CUSTOMIZABLE = l_items_rec.user_customizable,
SORTBY_VIEW_ATTRIBUTE_NAME = l_items_rec.sortby_view_attribute_name,
ADMIN_CUSTOMIZABLE = l_items_rec.admin_customizable,
INVOKE_FUNCTION_NAME = l_items_rec.invoke_function_name,
EXPANSION = l_items_rec.expansion,
ALS_MAX_LENGTH = l_items_rec.als_max_length,
INITIAL_SORT_SEQUENCE = l_items_rec.initial_sort_sequence,
CUSTOMIZATION_APPLICATION_ID = l_items_rec.customization_application_id,
CUSTOMIZATION_CODE = l_items_rec.customization_code,
ATTRIBUTE_CATEGORY = l_items_rec.attribute_category,
ATTRIBUTE1 = l_items_rec.attribute1,
ATTRIBUTE2 = l_items_rec.attribute2,
ATTRIBUTE3 = l_items_rec.attribute3,
ATTRIBUTE4 = l_items_rec.attribute4,
ATTRIBUTE5 = l_items_rec.attribute5,
ATTRIBUTE6 = l_items_rec.attribute6,
ATTRIBUTE7 = l_items_rec.attribute7,
ATTRIBUTE8 = l_items_rec.attribute8,
ATTRIBUTE9 = l_items_rec.attribute9,
ATTRIBUTE10 = l_items_rec.attribute10,
ATTRIBUTE11 = l_items_rec.attribute11,
ATTRIBUTE12 = l_items_rec.attribute12,
ATTRIBUTE13 = l_items_rec.attribute13,
ATTRIBUTE14 = l_items_rec.attribute14,
ATTRIBUTE15 = l_items_rec.attribute15,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line(l_api_name || 'Row does not exist during update');
raise FND_API.G_EXC_ERROR;
end if;

update AK_REGION_ITEMS_TL set
ATTRIBUTE_LABEL_LONG = l_items_tl_rec.attribute_label_long,
ATTRIBUTE_LABEL_SHORT = l_items_tl_rec.attribute_label_short,
DESCRIPTION = l_items_tl_rec.description,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATE_LOGIN = l_last_update_login,
SOURCE_LANG = l_lang
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code
and   l_lang in (LANGUAGE, SOURCE_LANG);
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || 'TL Row does not exist during update');
raise FND_API.G_EXC_ERROR;
end if;

--  /** commit the update **/
 commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;

end if;
p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
rollback to start_update_item;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_item;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MESSAGE.SET_NAME('AK','AK_REG_ITEM_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end UPDATE_ITEM;

--=======================================================
--  Procedure   UPDATE_REGION
--
--  Usage       Private API for updating a region.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_REGION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_database_object_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_style             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_icx_custom_call          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_num_columns              IN      NUMBER := FND_API.G_MISS_NUM,
p_region_defaulting_api_pkg IN     VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_defaulting_api_proc IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_validation_api_pkg IN     VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_validation_api_proc IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_appmodule_object_type	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_num_rows_display		 IN		 NUMBER := FND_API.G_MISS_NUM,
p_region_object_type		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_image_file_name			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_isform_flag				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_help_target				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_style_sheet_filename	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_version                  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_applicationmodule_usage_name IN  VARCHAR2 := FND_API.G_MISS_CHAR,
p_add_indexed_children     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_stateful_flag	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_function_name            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_children_view_usage_name IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_search_panel	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_advanced_search_panel    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customize_panel	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_search_panel     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_results_based_search     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_display_graph_table	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_disable_header	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_standalone		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_auto_customization_criteria IN   VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
cursor l_get_row_csr is
select *
from  AK_REGIONS
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
for update of REGION_STYLE;
cursor l_get_tl_row_csr (lang_parm varchar2) is
select *
from  AK_REGIONS_TL
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   LANGUAGE = lang_parm
for update of NAME;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Update_Region';
l_created_by              number;
l_creation_date           date;
l_regions_rec             AK_REGIONS%ROWTYPE;
l_regions_tl_rec          AK_REGIONS_TL%ROWTYPE;
l_isform_flag				VARCHAR2(1) := 'N';
l_lang                    varchar2(30);
l_last_update_date        date;
l_last_update_login       number;
l_last_updated_by         number;
l_return_status           varchar2(1);
l_file_version	number;
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

savepoint start_update_region;

select userenv('LANG') into l_lang
from dual;

--** retrieve ak_regions row if it exists **
open l_get_row_csr;
fetch l_get_row_csr into l_regions_rec;
if (l_get_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REGION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || 'Error - Row does not exist');
close l_get_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_row_csr;

--** retrieve ak_regions_tl row if it exists **
open l_get_tl_row_csr(l_lang);
fetch l_get_tl_row_csr into l_regions_tl_rec;
if (l_get_tl_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_REGION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || 'Error - TL Row does not exist');
close l_get_tl_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_tl_row_csr;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_REGION_PVT.VALIDATE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_database_object_name => p_database_object_name,
p_region_style => p_region_style,
p_icx_custom_call => p_icx_custom_call,
p_num_columns => p_num_columns,
p_region_defaulting_api_pkg => p_region_defaulting_api_pkg,
p_region_defaulting_api_proc => p_region_defaulting_api_proc,
p_region_validation_api_pkg => p_region_validation_api_pkg,
p_region_validation_api_proc => p_region_validation_api_proc,
p_name => p_name,
p_description => p_description,
p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
p_pass => p_pass
) then
--dbms_output.put_line(l_api_name || 'validation failed');
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if; -- /* if p_pass */
end if;
end if;

--** Load record to be updated to the database **
--** - first load nullable columns **

if (p_icx_custom_call  <> FND_API.G_MISS_CHAR) or
(p_icx_custom_call is null) then
l_regions_rec.icx_custom_call := p_icx_custom_call;
end if;

if (p_description <> FND_API.G_MISS_CHAR) or
(p_description is null) then
l_regions_tl_rec.description := p_description;
end if;
if (p_num_columns <> FND_API.G_MISS_NUM) or
(p_num_columns is null) then
l_regions_rec.num_columns := p_num_columns;
end if;
if (p_region_defaulting_api_pkg <> FND_API.G_MISS_CHAR) then
l_regions_rec.region_defaulting_api_pkg := p_region_defaulting_api_pkg;
end if;
if (p_region_defaulting_api_proc <> FND_API.G_MISS_CHAR) then
l_regions_rec.region_defaulting_api_proc := p_region_defaulting_api_proc;
end if;
if (p_region_validation_api_pkg <> FND_API.G_MISS_CHAR) then
l_regions_rec.region_validation_api_pkg := p_region_validation_api_pkg;
end if;
if (p_region_validation_api_proc <> FND_API.G_MISS_CHAR) then
l_regions_rec.region_validation_api_proc := p_region_validation_api_proc;
end if;
-- * new jsp columns * --
if (p_appmodule_object_type  <> FND_API.G_MISS_CHAR) or
(p_appmodule_object_type is null) then
l_regions_rec.applicationmodule_object_type := p_appmodule_object_type;
end if;
if (p_num_rows_display  <> FND_API.G_MISS_NUM) or
(p_num_rows_display is null) then
l_regions_rec.num_rows_display := p_num_rows_display;
end if;
if (p_region_object_type  <> FND_API.G_MISS_CHAR) or
(p_region_object_type is null) then
l_regions_rec.region_object_type := p_region_object_type;
end if;
if (p_image_file_name  <> FND_API.G_MISS_CHAR) or
(p_image_file_name is null) then
l_regions_rec.image_file_name := p_image_file_name;
end if;
if (p_isform_flag  <> FND_API.G_MISS_CHAR) and (p_isform_flag is not null) then
l_regions_rec.isform_flag := p_isform_flag;
else
l_regions_rec.isform_flag := l_isform_flag;
end if;
if (p_help_target  <> FND_API.G_MISS_CHAR) or
(p_help_target is null) then
l_regions_rec.help_target := p_help_target;
end if;
if (p_style_sheet_filename  <> FND_API.G_MISS_CHAR) or
(p_style_sheet_filename is null) then
l_regions_rec.style_sheet_filename := p_style_sheet_filename;
end if;
if (p_version  <> FND_API.G_MISS_CHAR) or
(p_version is null) then
l_regions_rec.version := p_version;
end if;
if (p_applicationmodule_usage_name  <> FND_API.G_MISS_CHAR) or
(p_applicationmodule_usage_name is null) then
l_regions_rec.applicationmodule_usage_name := p_applicationmodule_usage_name;
end if;
if (p_add_indexed_children  <> FND_API.G_MISS_CHAR) or
(p_add_indexed_children is null) then
l_regions_rec.add_indexed_children := p_add_indexed_children;
end if;
if (p_stateful_flag  <> FND_API.G_MISS_CHAR) or
(p_stateful_flag is null) then
l_regions_rec.stateful_flag := p_stateful_flag;
end if;
if (p_function_name  <> FND_API.G_MISS_CHAR) or
(p_function_name is null) then
l_regions_rec.function_name := p_function_name;
end if;
if (p_children_view_usage_name  <> FND_API.G_MISS_CHAR) or
(p_children_view_usage_name is null) then
l_regions_rec.children_view_usage_name := p_children_view_usage_name;
end if;
if (p_search_panel <> FND_API.G_MISS_CHAR) or
(p_search_panel is null) then
l_regions_rec.search_panel := p_search_panel;
end if;
if (p_advanced_search_panel <> FND_API.G_MISS_CHAR) or
(p_advanced_search_panel is null) then
l_regions_rec.advanced_search_panel := p_advanced_search_panel;
end if;
if (p_customize_panel <> FND_API.G_MISS_CHAR) or
(p_customize_panel is null) then
l_regions_rec.customize_panel := p_customize_panel;
end if;
if (p_default_search_panel <> FND_API.G_MISS_CHAR) or
(p_default_search_panel is null) then
l_regions_rec.default_search_panel := p_default_search_panel;
end if;
if (p_results_based_search <> FND_API.G_MISS_CHAR) or
(p_results_based_search is null) then
l_regions_rec.results_based_search := p_results_based_search;
end if;
if (p_display_graph_table <> FND_API.G_MISS_CHAR) or
(p_display_graph_table is null) then
l_regions_rec.display_graph_table := p_display_graph_table;
end if;
if (p_disable_header <> FND_API.G_MISS_CHAR) or
(p_disable_header is null) then
l_regions_rec.disable_header := p_disable_header;
end if;
if (p_auto_customization_criteria <> FND_API.G_MISS_CHAR) or
(p_auto_customization_criteria is null) then
l_regions_rec.auto_customization_criteria := p_auto_customization_criteria;
end if;

--** non-null, non-key columns **
if (p_standalone <> FND_API.G_MISS_CHAR) or
(p_standalone is not null) then
l_regions_rec.standalone := p_standalone;
else
l_regions_rec.standalone := 'Y';
end if;


-- * flex field columns * --
if (p_attribute_category <> FND_API.G_MISS_CHAR) or
(p_attribute_category is null) then
l_regions_rec.attribute_category := p_attribute_category;
end if;
if (p_attribute1 <> FND_API.G_MISS_CHAR) or
(p_attribute1 is null) then
l_regions_rec.attribute1 := p_attribute1;
end if;
if (p_attribute2 <> FND_API.G_MISS_CHAR) or
(p_attribute2 is null) then
l_regions_rec.attribute2 := p_attribute2;
end if;
if (p_attribute3 <> FND_API.G_MISS_CHAR) or
(p_attribute3 is null) then
l_regions_rec.attribute3 := p_attribute3;
end if;
if (p_attribute4 <> FND_API.G_MISS_CHAR) or
(p_attribute4 is null) then
l_regions_rec.attribute4 := p_attribute4;
end if;
if (p_attribute5 <> FND_API.G_MISS_CHAR) or
(p_attribute5 is null) then
l_regions_rec.attribute5 := p_attribute5;
end if;
if (p_attribute6 <> FND_API.G_MISS_CHAR) or
(p_attribute6 is null) then
l_regions_rec.attribute6 := p_attribute6;
end if;
if (p_attribute7 <> FND_API.G_MISS_CHAR) or
(p_attribute7 is null) then
l_regions_rec.attribute7 := p_attribute7;
end if;
if (p_attribute8 <> FND_API.G_MISS_CHAR) or
(p_attribute8 is null) then
l_regions_rec.attribute8 := p_attribute8;
end if;
if (p_attribute9 <> FND_API.G_MISS_CHAR) or
(p_attribute9 is null) then
l_regions_rec.attribute9 := p_attribute9;
end if;
if (p_attribute10 <> FND_API.G_MISS_CHAR) or
(p_attribute10 is null) then
l_regions_rec.attribute10 := p_attribute10;
end if;
if (p_attribute11 <> FND_API.G_MISS_CHAR) or
(p_attribute11 is null) then
l_regions_rec.attribute11 := p_attribute11;
end if;
if (p_attribute12 <> FND_API.G_MISS_CHAR) or
(p_attribute12 is null) then
l_regions_rec.attribute12 := p_attribute12;
end if;
if (p_attribute13 <> FND_API.G_MISS_CHAR) or
(p_attribute13 is null) then
l_regions_rec.attribute13 := p_attribute13;
end if;
if (p_attribute14 <> FND_API.G_MISS_CHAR) or
(p_attribute14 is null) then
l_regions_rec.attribute14 := p_attribute14;
end if;
if (p_attribute15 <> FND_API.G_MISS_CHAR) or
(p_attribute15 is null) then
l_regions_rec.attribute15 := p_attribute15;
end if;

--** - next, load non-null, non-key columns **

if (p_database_object_name <> FND_API.G_MISS_CHAR) then
l_regions_rec.database_object_name := p_database_object_name;
end if;
if (p_region_style <> FND_API.G_MISS_CHAR) then
l_regions_rec.region_style := p_region_style;
end if;
if (p_name <> FND_API.G_MISS_CHAR) then
l_regions_tl_rec.name := p_name;
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

-- Set WHO columns

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_regions_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_regions_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

update AK_REGIONS set
DATABASE_OBJECT_NAME = l_regions_rec.database_object_name,
REGION_STYLE = l_regions_rec.region_style,
ICX_CUSTOM_CALL = l_regions_rec.icx_custom_call,
NUM_COLUMNS = l_regions_rec.num_columns,
REGION_DEFAULTING_API_PKG = l_regions_rec.region_defaulting_api_pkg,
REGION_DEFAULTING_API_PROC = l_regions_rec.region_defaulting_api_proc,
REGION_VALIDATION_API_PKG = l_regions_rec.region_validation_api_pkg,
REGION_VALIDATION_API_PROC = l_regions_rec.region_validation_api_proc,
APPLICATIONMODULE_OBJECT_TYPE = l_regions_rec.applicationmodule_object_type,
NUM_ROWS_DISPLAY = l_regions_rec.num_rows_display,
REGION_OBJECT_TYPE = l_regions_rec.region_object_type,
IMAGE_FILE_NAME = l_regions_rec.image_file_name,
ISFORM_FLAG = l_regions_rec.isform_flag,
HELP_TARGET = l_regions_rec.help_target,
STYLE_SHEET_FILENAME = l_regions_rec.style_sheet_filename,
VERSION = l_regions_rec.version,
APPLICATIONMODULE_USAGE_NAME = l_regions_rec.applicationmodule_usage_name,
ADD_INDEXED_CHILDREN = l_regions_rec.add_indexed_children,
STATEFUL_FLAG = l_regions_rec.stateful_flag,
FUNCTION_NAME = l_regions_rec.function_name,
CHILDREN_VIEW_USAGE_NAME = l_regions_rec.children_view_usage_name,
SEARCH_PANEL = l_regions_rec.search_panel,
ADVANCED_SEARCH_PANEL = l_regions_rec.advanced_search_panel,
CUSTOMIZE_PANEL = l_regions_rec.customize_panel,
DEFAULT_SEARCH_PANEL = l_regions_rec.default_search_panel,
RESULTS_BASED_SEARCH = l_regions_rec.results_based_search,
DISPLAY_GRAPH_TABLE = l_regions_rec.display_graph_table,
DISABLE_HEADER = l_regions_rec.disable_header,
STANDALONE = l_regions_rec.standalone,
AUTO_CUSTOMIZATION_CRITERIA = l_regions_rec.auto_customization_criteria,
ATTRIBUTE_CATEGORY = l_regions_rec.attribute_category,
ATTRIBUTE1 = l_regions_rec.attribute1,
ATTRIBUTE2 = l_regions_rec.attribute2,
ATTRIBUTE3 = l_regions_rec.attribute3,
ATTRIBUTE4 = l_regions_rec.attribute4,
ATTRIBUTE5 = l_regions_rec.attribute5,
ATTRIBUTE6 = l_regions_rec.attribute6,
ATTRIBUTE7 = l_regions_rec.attribute7,
ATTRIBUTE8 = l_regions_rec.attribute8,
ATTRIBUTE9 = l_regions_rec.attribute9,
ATTRIBUTE10 = l_regions_rec.attribute10,
ATTRIBUTE11 = l_regions_rec.attribute11,
ATTRIBUTE12 = l_regions_rec.attribute12,
ATTRIBUTE13 = l_regions_rec.attribute13,
ATTRIBUTE14 = l_regions_rec.attribute14,
ATTRIBUTE15 = l_regions_rec.attribute15,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code;
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REGION_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

update AK_REGIONS_TL set
NAME = l_regions_tl_rec.name,
DESCRIPTION = l_regions_tl_rec.description,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login,
SOURCE_LANG = l_lang
where REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   l_lang in (LANGUAGE, SOURCE_LANG);

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REGION_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--  /** commit the update **/
 commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_REGION_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;

end if;
p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REGION_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240));
FND_MSG_PUB.Add;

end if;
rollback to start_update_region;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_REGION_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_region;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end UPDATE_REGION;

Function REGION_KEY_EXISTS (
p_region_application_id	in	number,
p_region_code				in	varchar2,
p_region_pk_tbl			in 	ak_region_pub.region_pk_tbl_type
) return boolean is

l_exist	boolean := true;

begin
if (p_region_pk_tbl.count = 0) then
l_exist := false;
end if;

for l_index in p_region_pk_tbl.FIRST .. p_region_pk_tbl.LAST loop
if (p_region_pk_tbl.exists(l_index)) then
if (p_region_pk_tbl(l_index).region_appl_id = p_region_application_id)
and
(p_region_pk_tbl(l_index).region_code = p_region_code) then
l_exist := true;
exit;
end if;
end if;
end loop;
return l_exist;
end;

Procedure ADD_NESTED_REG_TO_REG_PK (
p_region_application_id	IN	number,
p_region_code		IN	varchar2,
p_region_pk_tbl		IN OUT NOCOPY  AK_REGION_PUB.Region_PK_Tbl_Type
) IS
cursor l_get_ri_nested_regions_csr (region_appl_id_param number,
region_code_param varchar2) is
select distinct nested_region_application_id, nested_region_code
from   AK_REGION_ITEMS
where  region_application_id = region_appl_id_param
and    region_code = region_code_param
and    nested_region_application_id is not null
and    nested_region_code is not null;
cursor l_get_non_train_region_csr(region_appl_id_param number,
region_code_param varchar2) is
select region_application_id, region_code
from ak_regions_vl
where region_application_id = region_appl_id_param
and region_code = region_code_param
and region_style <> 'TRAIN';
l_return_status	varchar2(1);
begin
for l_region_rec in l_get_ri_nested_regions_csr (
p_region_application_id, p_region_code) loop
for l_non_train_region_rec in l_get_non_train_region_csr(l_region_rec.nested_region_application_id, l_region_rec.nested_region_code) loop
if ( NOT REGION_KEY_EXISTS(l_region_rec.nested_region_application_id, l_region_rec.nested_region_code, p_region_pk_tbl) ) then
-- drilling into the nested levels
AK_REGION_PVT.ADD_NESTED_REG_TO_REG_PK(
l_region_rec.nested_region_application_id,
l_region_rec.nested_region_code,
p_region_pk_tbl);
end if;
end loop; -- end l_get_non_train_region_csr
AK_REGION_PVT.INSERT_REGION_PK_TABLE (
p_return_status => l_return_status,
p_region_application_id =>
l_region_rec.nested_region_application_id,
p_region_code => l_region_rec.nested_region_code,
p_region_pk_tbl => p_region_pk_tbl);
end loop;

end ADD_NESTED_REG_TO_REG_PK;


end AK_REGION_PVT;

/
