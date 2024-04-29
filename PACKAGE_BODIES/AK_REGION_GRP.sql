--------------------------------------------------------
--  DDL for Package Body AK_REGION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_REGION_GRP" as
/* $Header: akdgregb.pls 120.2 2005/09/15 22:26:40 tshort ship $ */

--=======================================================
--  Procedure   CREATE_ITEM
--
--  Usage       Group API for creating a region item
--
--  Desc        Calls the private API to creates a region item
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
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
p_attribute_application_id IN     NUMBER,
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
p_display_height			 IN		 NUMBER := FND_API.G_MISS_NUM,
p_submit					 IN		 VARCHAR2,
p_encrypt					 IN		 VARCHAR2,
p_css_class_name			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_flex_segment_list  			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_entity_id					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_anchor					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_view_usage_name  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_user_customizable	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_sortby_view_attribute_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_admin_customizable		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_invoke_function_name	IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_expansion			IN      NUMBER   := FND_API.G_MISS_NUM,
p_als_max_length		IN      NUMBER   := FND_API.G_MISS_NUM,
p_initial_sort_sequence       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_application_id   IN   NUMBER   := FND_API.G_MISS_NUM,
p_customization_code	 	   IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_long     IN      VARCHAR2,
p_attribute_label_short    IN      VARCHAR2,
p_description				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Item';
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

savepoint start_create_item;

-- Call private procedure to create a region item
AK_REGION_PVT.CREATE_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
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
p_tip_message_name          => p_tip_message_name,
p_tip_message_application_id  => p_tip_message_application_id ,
p_flex_segment_list			=> p_flex_segment_list,
p_entity_id					=> p_entity_id,
p_anchor					=> p_anchor,
p_poplist_view_usage_name   => p_poplist_view_usage_name,
p_user_customizable	    => p_user_customizable,
p_sortby_view_attribute_name => p_sortby_view_attribute_name,
p_admin_customizable => p_admin_customizable,
p_invoke_function_name => p_invoke_function_name,
p_expansion => p_expansion,
p_als_max_length => p_als_max_length,
p_initial_sort_sequence => p_initial_sort_sequence,
p_customization_application_id => p_customization_application_id,
p_customization_code => p_customization_code,
p_attribute_label_long => p_attribute_label_long,
p_attribute_label_short => p_attribute_label_short,
p_description => p_description,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Create_Item failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_item;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_ITEM;

--=======================================================
--  Procedure   CREATE_REGION
--
--  Usage       Group API for creating a region
--
--  Desc        Calls the private API to create a region
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
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
p_appmodule_object_type	 IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_num_rows_display		 IN    NUMBER := FND_API.G_MISS_NUM,
p_region_object_type		 IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_image_file_name			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_isform_flag				 IN		 VARCHAR2,
p_help_target              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_style_sheet_filename     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_version                  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_applicationmodule_usage_name IN  VARCHAR2 := FND_API.G_MISS_CHAR,
p_add_indexed_children     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_stateful_flag	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_function_name            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_children_view_usage_name IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_search_panel	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_advanced_search_panel    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customize_panel          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_search_panel     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_results_based_search     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_display_graph_table      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_disable_header	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_standalone		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_auto_customization_criteria IN   VARCHAR2 := FND_API.G_MISS_CHAR,
p_name                     IN      VARCHAR2,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Region';
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

savepoint start_create_region;

-- Call private procedure to create a region
AK_REGION_PVT.CREATE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
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
p_name => p_name,
p_description => p_description,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Create_Region failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_region;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_REGION;

--=======================================================
--  Procedure   DELETE_ITEM
--
--  Usage       Group API for deleting a region item
--
--  Desc        Calls the private API to delete a region item
--              with the given key value.
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
--                  Key value of the region item to be deleted
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
p_delete_cascade           IN      VARCHAR2 := 'N'
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Item';
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

savepoint start_delete_item;

-- Call private procedure to create a region
AK_REGION_PVT.DELETE_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
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
rollback to start_delete_item;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end DELETE_ITEM;

--=======================================================
--  Procedure   DELETE_REGION
--
--  Usage       Group API for deleting a region
--
--  Desc        Calls the private API to delete a region
--              with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the region to be deleted
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
p_delete_cascade           IN      VARCHAR2 := 'N'
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Region';
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

savepoint start_delete_region;

-- Call private procedure to create a region
AK_REGION_PVT.DELETE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
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
rollback to start_delete_region;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end DELETE_REGION;

--=======================================================
--  Procedure   DOWNLOAD_REGION
--
--  Usage       Group API for downloading regions
--
--  Desc        This API first write out standard loader
--              file header for regions to a flat file.
--              Then it calls the private API to extract the
--              regions selected by application ID or by
--              key values from the database to the output file.
--              If a region is selected for writing to the loader
--              file, all its children records (including region
--              items) will also be written.
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
--                  If given, all regions for this application ID
--                  will be written to the output file.
--              p_application_short_name : IN optional
--                  If given, all regions for this application short
--                  name will be written to the output file.
--                  Application short name will be ignored if an
--                  application ID is given.
--              p_oregion_pk_tbl : IN optional
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
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_nls_language             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_application_short_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_region_pk_tbl            IN      AK_REGION_PUB.Region_PK_Tbl_Type
:= AK_REGION_PUB.G_MISS_REGION_PK_TBL
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Download_Region';
l_application_id     number;
l_buffer_tbl         AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_index_out          NUMBER;
l_nls_language       VARCHAR2(30);
l_return_status      varchar2(1);
l_region_pk_tbl      AK_REGION_PUB.Region_PK_Tbl_Type;
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

l_region_pk_tbl := p_region_pk_tbl;

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
p_table_size => p_region_pk_tbl.count,
p_download_by_object => AK_ON_OBJECTS_PVT.G_REGION,
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
--dbms_output.put_line(G_PKG_NAME || ' download_header failed');
RAISE FND_API.G_EXC_ERROR;
end if;

-- - call the download procedure for regions to retrieve the
--   selected regions and their referenced objects and attributes
--   from the database into a table of buffer.
AK_REGION_PVT.DOWNLOAD_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => l_application_id,
p_region_pk_tbl => l_region_pk_tbl,
p_nls_language => l_nls_language,
p_get_object_flag => 'Y'
);

-- If download call returns with an error status or
-- download failed to retrieve any information from the database..
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(G_PKG_NAME || 'download failed');
RAISE FND_API.G_EXC_ERROR;
end if;

--dbms_output.put_line('got ' || to_char(l_buffer_tbl.count) || ' lines');

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
rollback to Start_download;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to Start_download;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

end DOWNLOAD_REGION;

--=======================================================
--  Procedure   UPDATE_ITEM
--
--  Usage       Group API for updating a region item
--
--  Desc        This API calls the private API to update
--              a region item using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region item columns
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
p_menu_name                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_name           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_application_id IN      NUMBER   := FND_API.G_MISS_NUM,
p_tabular_function_code    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_type                 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_application_id   IN      NUMBER   := FND_API.G_MISS_NUM,
p_flex_segment_list 			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_entity_id					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_anchor					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_view_usage_name  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_user_customizable	     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_sortby_view_attribute_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_admin_customizable		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_invoke_function_name	IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_expansion			IN      NUMBER   := FND_API.G_MISS_NUM,
p_als_max_length		IN      NUMBER   := FND_API.G_MISS_NUM,
p_initial_sort_sequence       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_application_id  IN	NUMBER   := FND_API.G_MISS_NUM,
p_customization_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Item';
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

savepoint start_update_item;

-- Call private procedure to update a region item
AK_REGION_PVT.UPDATE_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
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
p_tip_message_name          => p_tip_message_name,
p_tip_message_application_id  => p_tip_message_application_id ,
p_flex_segment_list	 		=> p_flex_segment_list,
p_entity_id					=> p_entity_id,
p_anchor					=> p_anchor,
p_poplist_view_usage_name   => p_poplist_view_usage_name,
p_user_customizable	    => p_user_customizable,
p_sortby_view_attribute_name => p_sortby_view_attribute_name,
p_admin_customizable	=> p_admin_customizable,
p_invoke_function_name  => p_invoke_function_name,
p_expansion => p_expansion,
p_als_max_length => p_als_max_length,
p_initial_sort_sequence => p_initial_sort_sequence,
p_customization_application_id => p_customization_application_id,
p_customization_code => p_customization_code,
p_attribute_label_long => p_attribute_label_long,
p_attribute_label_short => p_attribute_label_short,
p_description => p_description,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Update_Item failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_item;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_ITEM;

--=======================================================
--  Procedure   UPDATE_REGION
--
--  Usage       Group API for updating a region
--
--  Desc        This API calls the private API to update
--              a region using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
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
p_appmodule_object_type    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_num_rows_display         IN      NUMBER := FND_API.G_MISS_NUM,
p_region_object_type       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_image_file_name			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_isform_flag				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_help_target              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_style_sheet_filename     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_version                  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_applicationmodule_usage_name IN  VARCHAR2 := FND_API.G_MISS_CHAR,
p_add_indexed_children     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_stateful_flag	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_function_name            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_children_view_usage_name IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_search_panel  	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_advanced_search_panel    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customize_panel	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_search_panel     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_results_based_search     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_display_graph_table      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_disable_header	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_standalone		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_auto_customization_criteria IN   VARCHAR2 := FND_API.G_MISS_CHAR,
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Region';
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

savepoint start_update_region;

-- Call private procedure to update a region
AK_REGION_PVT.UPDATE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
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
p_name => p_name,
p_description => p_description,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Update_Region failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_region;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_REGION;

end AK_REGION_GRP;

/
