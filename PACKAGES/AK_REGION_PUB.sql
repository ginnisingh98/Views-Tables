--------------------------------------------------------
--  DDL for Package AK_REGION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_REGION_PUB" AUTHID CURRENT_USER as
/* $Header: akdpregs.pls 115.32 2003/10/15 20:39:53 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_REGION_PUB';

-- Type definitions

-- Region primary key record

TYPE Region_PK_Rec_Type IS RECORD (
  region_appl_id           NUMBER                    := FND_API.G_MISS_NUM,
  region_code              VARCHAR2(30)              := FND_API.G_MISS_CHAR
);

-- Region Record

TYPE Region_Rec_Type IS RECORD (
  region_application_id    NUMBER                    := NULL,
  region_code              VARCHAR2(30)              := NULL,
  database_object_name     VARCHAR2(30)              := NULL,
  region_style             VARCHAR2(30)              := NULL,
  icx_custom_call          VARCHAR2(80)              := NULL,
  num_columns              NUMBER                    := NULL,
  region_defaulting_api_pkg VARCHAR2(30)             := NULL,
  region_defaulting_api_proc VARCHAR2(30)            := NULL,
  region_validation_api_pkg VARCHAR2(30)             := NULL,
  region_validation_api_proc VARCHAR2(30)            := NULL,
  applicationmodule_object_type VARCHAR2(240)		 := NULL,
  num_rows_display		   NUMBER					 := NULL,
  region_object_type	   VARCHAR2(240)			 := NULL,
  image_file_name	   VARCHAR2(80)		     := NULL,
  isform_flag		   VARCHAR2(1)		     := NULL,
  help_target              VARCHAR2(240)             := NULL,
  style_sheet_filename     VARCHAR2(240)             := NULL,
  version                  VARCHAR2(30)              := NULL,
  applicationmodule_usage_name VARCHAR2(80)          := NULL,
  add_indexed_children     VARCHAR2(1)               := NULL,
  stateful_flag		   VARCHAR2(1)		     := NULL,
  function_name		   VARCHAR2(30)		     := NULL,
  children_view_usage_name VARCHAR2(80)		     := NULL,
  search_panel		   VARCHAR2(1)		     := NULL,
  advanced_search_panel    VARCHAR2(1)		     := NULL,
  customize_panel	   VARCHAR2(1)		     := NULL,
  default_search_panel	   VARCHAR2(30)		     := NULL,
  results_based_search	   VARCHAR2(1)		     := NULL,
  display_graph_table	   VARCHAR2(1)		     := NULL,
  disable_header	   VARCHAR2(1)		     := NULL,
  standalone		   VARCHAR2(1)		     := NULL,
  auto_customization_criteria	VARCHAR2(1)	     := NULL,
  attribute_category       VARCHAR2(30)              := NULL,
  attribute1               VARCHAR2(150)             := NULL,
  attribute2               VARCHAR2(150)             := NULL,
  attribute3               VARCHAR2(150)             := NULL,
  attribute4               VARCHAR2(150)             := NULL,
  attribute5               VARCHAR2(150)             := NULL,
  attribute6               VARCHAR2(150)             := NULL,
  attribute7               VARCHAR2(150)             := NULL,
  attribute8               VARCHAR2(150)             := NULL,
  attribute9               VARCHAR2(150)             := NULL,
  attribute10              VARCHAR2(150)             := NULL,
  attribute11              VARCHAR2(150)             := NULL,
  attribute12              VARCHAR2(150)             := NULL,
  attribute13              VARCHAR2(150)             := NULL,
  attribute14              VARCHAR2(150)             := NULL,
  attribute15              VARCHAR2(150)             := NULL,
  name                     VARCHAR2(80)              := NULL,
  description              VARCHAR2(2000)            := NULL,
  created_by		   NUMBER		     := NULL,
  creation_date		   DATE			     := NULL,
  last_updated_by	   NUMBER                    := NULL,
  last_update_date	   DATE                      := NULL,
  last_update_login        NUMBER                    := NULL
);

/*  AK_REGION_GRAPHS has been obsoleted
-- Region Graph Record

TYPE Graph_Rec_Type is RECORD (
  region_application_id		NUMBER		:=NULL,
  region_code			VARCHAR2(30)	:=NULL,
  graph_number			NUMBER		:=NULL,
  graph_style			NUMBER		:=NULL,
  display_flag			VARCHAR2(1)	:=NULL,
  depth_radius			NUMBER		:=NULL,
  graph_title			VARCHAR2(240)	:=NULL,
  y_axis_label			VARCHAR2(80)	:=NULL,
  created_by               NUMBER                    := NULL,
  creation_date            DATE                      := NULL,
  last_updated_by          NUMBER                    := NULL,
  last_update_date         DATE                      := NULL,
  last_update_login        NUMBER                    := NULL
);
*/
-- Region Item Record

TYPE Item_Rec_Type IS RECORD (
  region_application_id    NUMBER                    := NULL,
  region_code              VARCHAR2(30)              := NULL,
  attribute_application_id NUMBER                    := NULL,
  attribute_code           VARCHAR2(30)              := NULL,
  display_sequence         NUMBER                    := NULL,
  node_display_flag        VARCHAR2(1)               := NULL,
  node_query_flag          VARCHAR2(1)               := NULL,
  attribute_label_length   NUMBER                    := NULL,
  display_value_length     NUMBER                    := NULL,
  bold                     VARCHAR2(1)               := NULL,
  italic                   VARCHAR2(1)               := NULL,
  vertical_alignment       VARCHAR2(30)              := NULL,
  horizontal_alignment     VARCHAR2(30)              := NULL,
  item_style               VARCHAR2(30)              := NULL,
  object_attribute_flag    VARCHAR2(1)               := NULL,
  icx_custom_call          VARCHAR2(80)              := NULL,
  update_flag              VARCHAR2(1)               := NULL,
  required_flag            VARCHAR2(1)               := NULL,
  security_code            VARCHAR2(30)              := NULL,
  default_value_varchar2   VARCHAR2(240)             := NULL,
  default_value_number     NUMBER                    := NULL,
  default_value_date       DATE                      := NULL,
  lov_region_application_id NUMBER                   := NULL,
  lov_region_code          VARCHAR2(30)              := NULL,
  lov_foreign_key_name     VARCHAR2(30)              := NULL,
  lov_attribute_application_id NUMBER                := NULL,
  lov_attribute_code       VARCHAR2(30)              := NULL,
  lov_default_flag         VARCHAR2(1)               := NULL,
  region_defaulting_api_pkg VARCHAR2(30)             := NULL,
  region_defaulting_api_proc VARCHAR2(30)            := NULL,
  region_validation_api_pkg VARCHAR2(30)             := NULL,
  region_validation_api_proc VARCHAR2(30)            := NULL,
  order_sequence           NUMBER                    := NULL,
  order_direction          VARCHAR2(30)              := NULL,
  display_height	NUMBER				:= NULL,
  submit			VARCHAR2(1)		:= NULL,
  encrypt			VARCHAR2(1)		:= NULL,
  css_class_name			VARCHAR2(80)		:= NULL,
  view_usage_name		VARCHAR2(80)		:= NULL,
  view_attribute_name		VARCHAR2(80)		:= NULL,
  nested_region_application_id		NUMBER			:= NULL,
  nested_region_code		VARCHAR2(30)		:= NULL,
  url				VARCHAR2(2000)		:= NULL,
  poplist_viewobject		VARCHAR2(240)		:= NULL,
  poplist_display_attr		VARCHAR2(80)		:= NULL,
  poplist_value_attr		VARCHAR2(80)		:= NULL,
  image_file_name		VARCHAR2(80)		:= NULL,
  item_name			VARCHAR2(30)		:= NULL,
  css_label_class_name		VARCHAR2(80)			:= NULL,
  menu_name			VARCHAR2(30)		:=NULL,
  flexfield_name		VARCHAR2(40)		:=NULL,
  flexfield_application_id	NUMBER  		:=NULL,
  tabular_function_code         VARCHAR2(30)         :=NULL,
  tip_type                      VARCHAR2(30)         :=NULL,
  tip_message_name              VARCHAR2(30)         :=NULL,
  tip_message_application_id    NUMBER               :=NULL,
  flex_segment_list             VARCHAR2(4000)       :=NULL,
  entity_id                     VARCHAR2(30)         :=NULL,
  anchor                        VARCHAR2(1)          := NULL,
  poplist_view_usage_name       VARCHAR2(80)         := NULL,
  user_customizable		VARCHAR2(1)	     := NULL,
  sortby_view_attribute_name    VARCHAR2(80)         := NULL,
  admin_customizable		VARCHAR2(1)	     := NULL,
  invoke_function_name		VARCHAR2(30)          := NULL,
  expansion			NUMBER			:= NULL,
  als_max_length		NUMBER			:= NULL,
  initial_sort_sequence		VARCHAR(30)		:= NULL,
  customization_application_id	NUMBER			:= NULL,
  customization_code	 	VARCHAR2(30)		:= NULL,
  attribute_category       VARCHAR2(30)              := NULL,
  attribute1               VARCHAR2(150)             := NULL,
  attribute2               VARCHAR2(150)             := NULL,
  attribute3               VARCHAR2(150)             := NULL,
  attribute4               VARCHAR2(150)             := NULL,
  attribute5               VARCHAR2(150)             := NULL,
  attribute6               VARCHAR2(150)             := NULL,
  attribute7               VARCHAR2(150)             := NULL,
  attribute8               VARCHAR2(150)             := NULL,
  attribute9               VARCHAR2(150)             := NULL,
  attribute10              VARCHAR2(150)             := NULL,
  attribute11              VARCHAR2(150)             := NULL,
  attribute12              VARCHAR2(150)             := NULL,
  attribute13              VARCHAR2(150)             := NULL,
  attribute14              VARCHAR2(150)             := NULL,
  attribute15              VARCHAR2(150)             := NULL,
  attribute_label_long     VARCHAR2(80)              := NULL,
  attribute_label_short    VARCHAR2(40)              := NULL,
  description			VARCHAR2(2000)		:= NULL,
  created_by               NUMBER                    := NULL,
  creation_date            DATE                      := NULL,
  last_updated_by          NUMBER                    := NULL,
  last_update_date         DATE                      := NULL,
  last_update_login        NUMBER                    := NULL
);

-- Region primary key table

TYPE Item_Tbl_Type IS TABLE OF Item_Rec_Type
	INDEX BY BINARY_INTEGER;

TYPE Region_PK_Tbl_Type IS TABLE OF Region_PK_Rec_Type
	INDEX BY BINARY_INTEGER;

TYPE Region_Tbl_Type IS TABLE OF Region_Rec_Type
	INDEX BY BINARY_INTEGER;

TYPE Lov_Relation_Tbl_Type IS TABLE OF AK_REGION_LOV_RELATIONS%ROWTYPE
	INDEX BY BINARY_INTEGER;

TYPE Category_Usages_Tbl_Type IS TABLE OF AK_CATEGORY_USAGES%ROWTYPE
	INDEX BY BINARY_INTEGER;
/*
TYPE Graph_Tbl_Type is TABLE OF Graph_Rec_Type
	INDEX BY BINARY_INTEGER;

TYPE Graph_Column_Tbl_Type is TABLE OF AK_REGION_GRAPH_COLUMNS%ROWTYPE
	INDEX BY BINARY_INTEGER;
*/
/* Constants for missing data types */
G_MISS_ITEM_REC              Item_Rec_Type;
G_MISS_ITEM_TBL              Item_Tbl_Type;
G_MISS_REGION_PK_REC         Region_PK_Rec_Type;
G_MISS_REGION_PK_TBL         Region_PK_Tbl_Type;
G_MISS_REGION_REC            Region_Rec_Type;
G_MISS_REGION_TBL            Region_Tbl_Type;
G_MISS_LOV_RELATION_REC		Lov_Relation_Tbl_Type;
G_MISS_CATEGORY_USAGES_REC	Category_Usages_Tbl_Type;
--G_MISS_GRAPH_REC		Graph_Tbl_Type;
--G_MISS_GRAPH_COLUMN_REC		Graph_Column_Tbl_Type;

end AK_REGION_PUB;

 

/
