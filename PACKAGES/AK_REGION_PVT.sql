--------------------------------------------------------
--  DDL for Package AK_REGION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_REGION_PVT" AUTHID CURRENT_USER as
/* $Header: akdvregs.pls 120.2 2005/09/15 22:27:02 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_REGION_PVT';

-- Procedure specs

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
p_msg_count                OUT NOCOPY NUMBER,
p_msg_data                 OUT NOCOPY VARCHAR2,
p_return_status            OUT NOCOPY VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_graph_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_graph_style              IN      NUMBER := FND_API.G_MISS_NUM,
p_display_flag             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_depth_radius             IN      NUMBER := FND_API.G_MISS_NUM,
p_graph_title              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_y_axis_label             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY BOOLEAN
);
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
p_msg_count                OUT NOCOPY NUMBER,
p_msg_data                 OUT NOCOPY VARCHAR2,
p_return_status            OUT NOCOPY VARCHAR2,
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
p_flex_segment_list					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_entity_id				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_anchor					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_view_usage_name  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_user_customizable	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_sortby_view_attribute_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_admin_customizable		IN	VARCHAR2,
p_invoke_function_name	IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_expansion			IN      NUMBER   := FND_API.G_MISS_NUM,
p_als_max_length		IN      NUMBER   := FND_API.G_MISS_NUM,
p_initial_sort_sequence       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_application_id  IN    NUMBER   := FND_API.G_MISS_NUM,
p_customization_code		IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_description				 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY BOOLEAN
);

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
p_msg_count                OUT NOCOPY NUMBER,
p_msg_data                 OUT NOCOPY VARCHAR2,
p_return_status            OUT NOCOPY VARCHAR2,
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
p_style_sheet_filename 	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_copy_redo_flag           IN OUT NOCOPY BOOLEAN
);

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
p_msg_count                OUT NOCOPY NUMBER,
p_msg_data                 OUT NOCOPY VARCHAR2,
p_return_status            OUT NOCOPY VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_graph_number             IN      NUMBER,
p_delete_cascade           IN      VARCHAR2
);
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
p_msg_count                OUT NOCOPY NUMBER,
p_msg_data                 OUT NOCOPY VARCHAR2,
p_return_status            OUT NOCOPY VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
);

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
p_msg_count                OUT NOCOPY NUMBER,
p_msg_data                 OUT NOCOPY VARCHAR2,
p_return_status            OUT NOCOPY VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
);

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
p_return_status            OUT NOCOPY VARCHAR2,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_region_pk_tbl            IN OUT NOCOPY AK_REGION_PUB.Region_PK_Tbl_Type,
p_nls_language             IN      VARCHAR2,
p_get_object_flag          IN      VARCHAR2
);

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
p_return_status            OUT NOCOPY VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_region_pk_tbl            IN OUT NOCOPY AK_REGION_PUB.Region_PK_Tbl_Type
);

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
p_return_status            OUT NOCOPY VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_graph_number             IN      NUMBER
) return BOOLEAN;
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
p_return_status            OUT NOCOPY VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2
) return BOOLEAN;

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
p_return_status            OUT NOCOPY VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2
) return BOOLEAN;

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
p_msg_count                OUT NOCOPY NUMBER,
p_msg_data                 OUT NOCOPY VARCHAR2,
p_return_status            OUT NOCOPY VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_graph_number             IN      NUMBER,
p_graph_style              IN      NUMBER := FND_API.G_MISS_NUM,
p_display_flag             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_depth_radius             IN      NUMBER := FND_API.G_MISS_NUM,
p_graph_title              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_y_axis_label             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY BOOLEAN
);
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
p_msg_count                OUT NOCOPY NUMBER,
p_msg_data                 OUT NOCOPY VARCHAR2,
p_return_status            OUT NOCOPY VARCHAR2,
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
p_css_class_name 			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_flex_segment_list					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_entity_id					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_anchor					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_view_usage_name  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_user_customizable	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_sortby_view_attribute_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_admin_customizable		IN	VARCHAR2,
p_invoke_function_name	IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_expansion			IN      NUMBER   := FND_API.G_MISS_NUM,
p_als_max_length		IN      NUMBER   := FND_API.G_MISS_NUM,
p_initial_sort_sequence       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_application_id  IN	NUMBER   := FND_API.G_MISS_NUM,
p_customization_code		IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_copy_redo_flag           IN OUT NOCOPY BOOLEAN
);

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
p_msg_count                OUT NOCOPY NUMBER,
p_msg_data                 OUT NOCOPY VARCHAR2,
p_return_status            OUT NOCOPY VARCHAR2,
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
p_help_target 			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_style_sheet_filename  	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_version                  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_applicationmodule_usage_name IN  VARCHAR2 := FND_API.G_MISS_CHAR,
p_add_indexed_children     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_stateful_flag	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_function_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_children_view_usage_name IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_search_panel             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_advanced_search_panel    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customize_panel          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY BOOLEAN
);

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
p_return_status            OUT NOCOPY VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_graph_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_graph_style              IN      NUMBER := FND_API.G_MISS_NUM,
p_display_flag             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_depth_radius             IN      NUMBER := FND_API.G_MISS_NUM,
p_graph_title              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_y_axis_label             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN;
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
p_return_status            OUT NOCOPY VARCHAR2,
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
p_nested_region_appl_id	IN	NUMBER := FND_API.G_MISS_NUM,
p_nested_region_code	   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_menu_name		     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_name	     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_flexfield_application_id IN	     NUMBER   := FND_API.G_MISS_NUM,
p_tabular_function_code    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_type                 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_tip_message_application_id   IN      NUMBER   := FND_API.G_MISS_NUM,
p_flex_segment_list					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_entity_id					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_anchor					 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_view_usage_name  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_user_customizable	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_sortby_view_attribute_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_invoke_function_name	IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_expansion			IN      NUMBER   := FND_API.G_MISS_NUM,
p_als_max_length		IN      NUMBER   := FND_API.G_MISS_NUM,
p_initial_sort_sequence       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_application_id  IN	NUMBER   := FND_API.G_MISS_NUM,
p_customization_code		IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return boolean;

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
p_return_status            OUT NOCOPY VARCHAR2,
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
) return boolean;

Procedure ADD_NESTED_REG_TO_REG_PK (
p_region_application_id	IN	NUMBER,
p_region_code		IN	VARCHAR2,
p_region_pk_tbl         IN OUT NOCOPY AK_REGION_PUB.Region_PK_Tbl_Type
);

end AK_REGION_PVT;

 

/
