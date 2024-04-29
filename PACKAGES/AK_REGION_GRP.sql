--------------------------------------------------------
--  DDL for Package AK_REGION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_REGION_GRP" AUTHID CURRENT_USER as
/* $Header: akdgregs.pls 120.2 2005/09/15 22:26:41 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_REGION_GRP';

/* Procedure specs */

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
p_display_height		 IN	 NUMBER := FND_API.G_MISS_NUM,
p_submit			 IN	 VARCHAR2,
p_encrypt			 IN	 VARCHAR2,
p_css_class_name		 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_view_usage_name		 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_view_attribute_name		 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_nested_region_appl_id	 IN	 NUMBER := FND_API.G_MISS_NUM,
p_nested_region_code		 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_url				 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_viewobject		 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_display_attr	 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_value_attr		 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_image_file_name		 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_item_name			 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_css_label_class_name	 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_menu_name			 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_name		 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_application_id     IN	 NUMBER   := FND_API.G_MISS_NUM,
p_tabular_function_code        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_type                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_name             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_application_id   IN      NUMBER   := FND_API.G_MISS_NUM,
p_flex_segment_list 			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_entity_id					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_anchor					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_view_usage_name  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_user_customizable	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_sortby_view_attribute_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_admin_customizable		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_invoke_function_name	IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_expansion 			IN      NUMBER   := FND_API.G_MISS_NUM,
p_als_max_length		IN      NUMBER   := FND_API.G_MISS_NUM,
p_initial_sort_sequence	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_application_id  IN	NUMBER   := FND_API.G_MISS_NUM,
p_customization_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_long	 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR
);

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
p_help_target			IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_style_sheet_filename	 IN	VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_name                     IN      VARCHAR2,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR
);

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
);

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
);


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
);

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
p_menu_name		     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_name	     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_application_id IN	     NUMBER   := FND_API.G_MISS_NUM,
p_tabular_function_code    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_type                 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_application_id   IN      NUMBER   := FND_API.G_MISS_NUM,
p_flex_segment_list			 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_entity_id					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_anchor					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_view_usage_name  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_user_customizable	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_sortby_view_attribute_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_admin_customizable		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_invoke_function_name	IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_expansion			IN      NUMBER   := FND_API.G_MISS_NUM,
p_als_max_length		IN      NUMBER   := FND_API.G_MISS_NUM,
p_initial_sort_sequence	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_application_id  IN	NUMBER   := FND_API.G_MISS_NUM,
p_customization_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR
);

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
p_appmodule_object_type	 IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_num_rows_display		 IN    NUMBER := FND_API.G_MISS_NUM,
p_region_object_type		 IN    VARCHAR2 := FND_API.G_MISS_CHAR,
p_image_file_name			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_isform_flag				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_help_target			IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_style_sheet_filename        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_version                  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_applicationmodule_usage_name IN  VARCHAR2 := FND_API.G_MISS_CHAR,
p_add_indexed_children     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_stateful_flag	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_function_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR
);

end AK_REGION_GRP;

 

/
