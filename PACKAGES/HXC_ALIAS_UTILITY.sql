--------------------------------------------------------
--  DDL for Package HXC_ALIAS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_UTILITY" AUTHID CURRENT_USER AS
/* $Header: hxcaltutl.pkh 120.1 2005/06/15 17:37:27 jdupont noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< STATIC VARIABLE         >--------------------|
-- ----------------------------------------------------------------------------
ALIAS_SEPARATOR		VARCHAR2(80) := 'ALIAS_SEPARATOR';


-- ----------------------------------------------------------------------------
-- |---------------------------< TYPE DECLARATION         >--------------------|
-- ----------------------------------------------------------------------------
--
TYPE r_alias_def_item IS RECORD
(ALIAS_DEFINITION_ID		HXC_ALIAS_DEFINITIONS.ALIAS_DEFINITION_ID%TYPE
,ITEM_ATTRIBUTE_CATEGORY	VARCHAR2(80)
,RESOURCE_ID			NUMBER
,LAYOUT_ID			NUMBER
,ALIAS_LABEL			VARCHAR2(80)
,PREF_START_DATE		DATE
,PREF_END_DATE			DATE
);

TYPE t_alias_def_item IS TABLE OF
r_alias_def_item
INDEX BY BINARY_INTEGER;
--
--
TYPE r_tbb_id_ref is RECORD
(ATTRIBUTE_INDEX	VARCHAR2(2000),
 NUMBER_ALIAS		NUMBER
);

TYPE t_tbb_id_reference is TABLE OF
r_tbb_id_ref
INDEX BY BINARY_INTEGER;
--
--

TYPE r_tbb_date_ref is RECORD
(START_TIME		DATE,
 STOP_TIME		DATE
);

TYPE t_tbb_date_reference_table is TABLE OF
r_tbb_date_ref
INDEX BY BINARY_INTEGER;
--
--
TYPE r_alias_val_att_to_match is RECORD
(BLD_BLK_INFO_TYPE     hxc_bld_blk_info_types.bld_blk_info_type%TYPE
,ATTRIBUTE_CATEGORY    hxc_bld_blk_info_types.bld_blk_info_type%TYPE
,ATTRIBUTE1            hxc_time_attributes.attribute1%TYPE
,ATTRIBUTE2            hxc_time_attributes.attribute2%TYPE
,ATTRIBUTE3            hxc_time_attributes.attribute3%TYPE
,ATTRIBUTE4            hxc_time_attributes.attribute4%TYPE
,ATTRIBUTE5            hxc_time_attributes.attribute5%TYPE
,ATTRIBUTE6            hxc_time_attributes.attribute6%TYPE
,ATTRIBUTE7            hxc_time_attributes.attribute7%TYPE
,ATTRIBUTE8            hxc_time_attributes.attribute8%TYPE
,ATTRIBUTE9            hxc_time_attributes.attribute9%TYPE
,ATTRIBUTE10           hxc_time_attributes.attribute10%TYPE
,ATTRIBUTE11           hxc_time_attributes.attribute11%TYPE
,ATTRIBUTE12           hxc_time_attributes.attribute12%TYPE
,ATTRIBUTE13           hxc_time_attributes.attribute13%TYPE
,ATTRIBUTE14           hxc_time_attributes.attribute14%TYPE
,ATTRIBUTE15           hxc_time_attributes.attribute15%TYPE
,ATTRIBUTE16           hxc_time_attributes.attribute16%TYPE
,ATTRIBUTE17           hxc_time_attributes.attribute17%TYPE
,ATTRIBUTE18           hxc_time_attributes.attribute18%TYPE
,ATTRIBUTE19           hxc_time_attributes.attribute19%TYPE
,ATTRIBUTE20           hxc_time_attributes.attribute20%TYPE
,ATTRIBUTE21           hxc_time_attributes.attribute21%TYPE
,ATTRIBUTE22           hxc_time_attributes.attribute22%TYPE
,ATTRIBUTE23           hxc_time_attributes.attribute23%TYPE
,ATTRIBUTE24           hxc_time_attributes.attribute24%TYPE
,ATTRIBUTE25           hxc_time_attributes.attribute25%TYPE
,ATTRIBUTE26           hxc_time_attributes.attribute26%TYPE
,ATTRIBUTE27           hxc_time_attributes.attribute27%TYPE
,ATTRIBUTE28           hxc_time_attributes.attribute28%TYPE
,ATTRIBUTE29           hxc_time_attributes.attribute29%TYPE
,ATTRIBUTE30           hxc_time_attributes.attribute30%TYPE
,BLD_BLK_INFO_TYPE_ID  hxc_time_attributes.bld_blk_info_type_id%TYPE
,COMPONENT_TYPE	       hxc_alias_type_components.component_type%TYPE
,COMPONENT_NAME	       hxc_alias_type_components.component_name%TYPE
,REFERENCE_OBJECT      hxc_alias_types.reference_object%TYPE
,MAPPING_ATT_CAT       hxc_bld_blk_info_type_usages.building_block_category%TYPE
,SEGMENT	       VARCHAR2(80)
);

TYPE t_alias_val_att_to_match is TABLE OF
r_alias_val_att_to_match
INDEX BY BINARY_INTEGER;

--
--
TYPE r_alias_val_att_rec is RECORD
(START_INDEX	       NUMBER
,END_INDEX	       NUMBER
);

TYPE t_alias_val_att_rec is TABLE OF
r_alias_val_att_rec
INDEX BY BINARY_INTEGER;

--
--
TYPE r_alias_definition_info IS RECORD
(ALIAS_TYPE		hxc_alias_types.alias_type%type,
 REFERENCE_OBJECT	hxc_alias_types.reference_object%type,
 PROMPT			hxc_alias_definitions_tl.prompt%type);

TYPE t_alias_definition_info is TABLE OF
r_alias_definition_info
INDEX BY BINARY_INTEGER;
--
--
TYPE r_alias_att_info IS RECORD
(TIMEKEEPER_ID		NUMBER,
 ALIAS_DEFINITION_ID	VARCHAR2(80),
 ALIAS_TYPE		hxc_alias_types.alias_type%TYPE);
-- BLD_BLK_INFO_TYPE_ID   NUMBER,
-- BLD_BLK_INFO_TYPE	VARCHAR2(80));

TYPE t_alias_att_info is TABLE OF
r_alias_att_info
INDEX BY BINARY_INTEGER;

--
--
TYPE r_alias_apps_tab_info IS RECORD
(APPS_TAB_NAME		VARCHAR2(240));

TYPE t_alias_apps_tab_info is TABLE OF
r_alias_apps_tab_info
INDEX BY BINARY_INTEGER;
--
--
TYPE t_alias_att_ref_rec IS RECORD
(ATTRIBUTE_INDEX	NUMBER,
 OTL_ALIAS_TYPE		VARCHAR2(80),
 OTL_ALIAS_ATT          VARCHAR2(80));

TYPE t_alias_att_ref_table is TABLE OF
t_alias_att_ref_rec
INDEX BY BINARY_INTEGER;


-- ----------------------------------------------------------------------------
-- |---------------------------< VARIABLE      >--------------------|
-- ----------------------------------------------------------------------------
c_tk_processing			VARCHAR2(80) := 'TIMEKEEPER_PROCESSING';
c_ss_processing			VARCHAR2(80) := 'SS_PROCESSING';


-- ----------------------------------------------------------------------------
-- |---------------------------< GLOBAL DECLARATION      >--------------------|
-- ----------------------------------------------------------------------------
g_alias_def_item		t_alias_def_item;
g_comp_label			t_alias_val_att_to_match;
g_alias_val_att_to_match	t_alias_val_att_to_match;
g_alias_def_att_to_match	t_alias_val_att_to_match;
g_alias_def_att_rec		t_alias_val_att_rec;
g_alias_def_val_att_rec		t_alias_val_att_rec;
g_alias_definition_info		t_alias_definition_info;
g_alias_att_info		t_alias_att_info;
g_alias_apps_tab_info		t_alias_apps_tab_info;

g_layout_attribute		HXC_ATTRIBUTE_TABLE_TYPE;


-- ----------------------------------------------------------------------------
-- |--------------------< PROCEDURE/FUNCTION DECLARATION  >--------------------|
-- ----------------------------------------------------------------------------
--
-- initialize the global variable
--
PROCEDURE initialize;

-- -----------------------------------------------------------------------------|
-- |------------------------< process_attribute          >---------------------|
-- -----------------------------------------------------------------------------|

FUNCTION process_attribute(p_attribute HXC_ATTRIBUTE_TYPE)
RETURN BOOLEAN;

-- ----------------------------------------------------------------------------
-- |------------------------< get_alias_att_info          >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_alias_att_info
  (p_timekeeper_id	IN	NUMBER,
   p_alias_att_info	IN OUT  NOCOPY	t_alias_att_info);

-- ----------------------------------------------------------------------------
-- |----------------------< get_next_negative_attribute_id>--------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_next_negative_attribute_id(
  p_attributes IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE--hxc_self_service_time_deposit.building_block_attribute_info
)
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |--------------------------< set_attribute_information>--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_attribute_information
  (p_attributes 		IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,--hxc_self_service_time_deposit.building_block_attribute_info,
   p_index_in_table		IN  NUMBER,
   p_attribute_to_set		IN  VARCHAR2,
   p_value_to_set		IN  VARCHAR2);

-- ----------------------------------------------------------------------------
-- |--------------------------< get_attribute_information>--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_attribute_information
  (p_attributes 		IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,--hxc_self_service_time_deposit.building_block_attribute_info,
   p_index_in_table		IN  NUMBER,
   p_attribute_to_get		IN  VARCHAR2,
   p_get_value		 OUT NOCOPY  VARCHAR2);



-- ----------------------------------------------------------------------------
-- |--------------------------< get_attribute_to_match_info --------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_attribute_to_match_info
  (p_attribute_to_match		IN OUT NOCOPY t_alias_val_att_to_match,
   p_index_in_table		IN  NUMBER,
   p_attribute_to_get		IN  VARCHAR2,
   p_get_value		 OUT NOCOPY  VARCHAR2);

-- ----------------------------------------------------------------------------
-- |--------------------------< set_attribute_to_match_info>--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_attribute_to_match_info
  (p_attribute_to_match		IN OUT NOCOPY t_alias_val_att_to_match,
   p_index_in_table		IN   NUMBER,
   p_attribute_to_set		IN   VARCHAR2,
   p_bld_blk_info_type		IN   VARCHAR2,
   p_mapping_att_cat		IN   VARCHAR2,
   p_value_to_set		IN   VARCHAR2);


-- ----------------------------------------------------------------------------
-- |------------------------< attribute_check>		   --------------------|
-- ----------------------------------------------------------------------------
PROCEDURE attribute_check
           (p_bld_blk_info_type_id	IN NUMBER
           ,p_time_building_block_id 	IN hxc_time_building_blocks.time_building_block_id%TYPE
           ,p_attributes 		IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE--hxc_self_service_time_deposit.building_block_attribute_info
           ,p_tbb_id_reference_table 	IN OUT NOCOPY t_tbb_id_reference
           ,p_attribute_index	   	IN OUT NOCOPY NUMBER
           ,p_attribute_found	   	IN OUT NOCOPY BOOLEAN);

-- ----------------------------------------------------------------------------
-- |------------------------< get_alias_val_att_to_match>--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_alias_val_att_to_match
  (p_alias_definition_id	IN NUMBER,
   p_alias_value_id		IN NUMBER,
   p_alias_val_att_to_match	IN OUT NOCOPY t_alias_val_att_to_match);

-- ----------------------------------------------------------------------------
-- |------------------------< get_alias_val_att_to_match>--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_alias_val_att_to_match
  (p_alias_definition_id	IN NUMBER,
   p_alias_val_att_to_match	IN OUT NOCOPY 	t_alias_val_att_to_match);

-- ----------------------------------------------------------------------------
-- |--------------------------< get_tbb_id_reference_table>--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_tbb_id_reference_table
  (p_attributes 		IN OUT NOCOPY 	HXC_ATTRIBUTE_TABLE_TYPE,--hxc_self_service_time_deposit.building_block_attribute_info,
   p_tbb_id_reference_table	IN OUT NOCOPY 	t_tbb_id_reference);

-- ----------------------------------------------------------------------------
-- |--------------------------< get_tbb_date_reference_table>--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_tbb_date_reference_table
  (p_blocks	 		IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,--hxc_self_service_time_deposit.timecard_info,
   p_tbb_date_reference_table	IN OUT NOCOPY t_tbb_date_reference_table,
   p_timecard_start_time	OUT    NOCOPY DATE,
   p_timecard_stop_time		OUT    NOCOPY DATE);


-- ----------------------------------------------------------------------------
-- |------------------------< get_alias_def_item    for SS >--------------------|
-- ----------------------------------------------------------------------------
-- |  This procedure returns by looking on the preference of the timekeeper    |
-- |  a pl/sql table that contains the alias attribute information	       |
--------------------------------------------------------------------------------
PROCEDURE get_alias_def_item
    		(p_resource_id 		IN NUMBER,
    		 p_attributes	IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,--hxc_self_service_time_deposit.building_block_attribute_info,
    		 p_alias_def_item	IN OUT NOCOPY 	t_alias_def_item,
    		 p_start_time		IN DATE,
    		 p_stop_time		IN DATE,
    		 p_cache_label 		IN BOOLEAN DEFAULT FALSE);

-- ----------------------------------------------------------------------------
-- |---------------------------< get_alias_def_item	 >--------------------|
-- ----------------------------------------------------------------------------
--
-- This function return the alias defintion item information

PROCEDURE get_alias_def_item
(p_timekeeper_id 		in 	NUMBER
,p_alias_def_item		IN OUT NOCOPY 	t_alias_def_item);


-- ----------------------------------------------------------------------------
-- |---------------------------< get_alias_definition_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- This function return the alias defintion information

PROCEDURE get_alias_definition_info
 (p_alias_definition_id 	in  number,
  p_alias_type 		 out nocopy varchar2,
  p_reference_object	 out nocopy varchar2,
  p_prompt		 out nocopy varchar2);

-- ----------------------------------------------------------------------------
-- |---------------------------< get_alias_def_from_value >--------------------|
-- ----------------------------------------------------------------------------
--
-- This function return the alias defintion id from an alias value id

FUNCTION get_alias_def_from_value
 (p_alias_value_id 	in  number)
 RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |---------------------------< get_vset_table_type_select >--------------------|
-- ----------------------------------------------------------------------------
--
-- This function return the SQL associate to a specifiy alternate name definition
-- with VALUE_SET_TABLE Type

PROCEDURE get_vset_table_type_select
 (p_alias_definition_id		IN	NUMBER,
  x_select 		 OUT NOCOPY VARCHAR2,
  p_id_type		 OUT NOCOPY VARCHAR2);

-- ----------------------------------------------------------------------------
-- |---------------------------< get_vset_table_type_select >--------------------|
-- ----------------------------------------------------------------------------
--
-- This function return the SQL associate to a specifiy alternate name definition
-- with VALUE_SET_INDEPENDENT Type
PROCEDURE get_vset_indep_type_select
 (p_alias_definition_id		IN	NUMBER,
  x_select 		 OUT NOCOPY VARCHAR2);

-- ----------------------------------------------------------------------------
-- |------------------------< get_vset_none_type_property >--------------------|
-- ----------------------------------------------------------------------------
--
-- This function return the property associate to a specifiy alternate name definition
-- with VALUE_SET_NONE Type
--
PROCEDURE get_vset_none_type_property
 (p_alias_definition_id		IN	NUMBER,
  p_format_type		 OUT NOCOPY VARCHAR2,
  p_maximum_size	 OUT NOCOPY NUMBER,
  p_minimum_value	 OUT NOCOPY 	NUMBER,
  p_maximum_value	 OUT NOCOPY NUMBER,
  p_number_precision	 OUT NOCOPY NUMBER
  );
-- ----------------------------------------------------------------------------
-- |--------------------< get_otl_an_context_type_select >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_otl_an_context_type_select
 (p_alias_definition_id		IN	NUMBER,
  p_timekeeper_person_type	IN	VARCHAR2 DEFAULT NULL,
  x_select 		 OUT NOCOPY VARCHAR2);

-- ----------------------------------------------------------------------------
-- |--------------------< get_value_from_index            >--------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_value_from_index
   (p_str    VARCHAR2
   ,p_index  NUMBER
   )
RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |--------------------< query_invoice                   >--------------------|
-- ----------------------------------------------------------------------------
FUNCTION query_invoice(p_select IN  VARCHAR2)
	RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |--------------------< get_apps_table_from_type        >--------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_apps_table_from_type(p_alias_definition_id IN VARCHAR2)
	RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |--------------------< get_alias_att_to_match_to_dep   >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_alias_att_to_match_to_dep(p_alias_definition_id 		NUMBER
     				       ,p_alias_old_value_id  		NUMBER
     				       ,p_alias_type			VARCHAR2
     				       ,p_original_value		VARCHAR2
     				       ,p_alias_val_att_to_match OUT NOCOPY t_alias_val_att_to_match
     				       ,p_att_to_delete		 OUT NOCOPY BOOLEAN);

-- ----------------------------------------------------------------------------
-- |---------------------------< remove_empty_attribute   >--------------------|
-- ----------------------------------------------------------------------------
/*
PROCEDURE remove_empty_attribute
        (p_attributes in out NOCOPY hxc_self_service_time_deposit.building_block_attribute_info);
*/
-- ----------------------------------------------------------------------------
-- |---------------------------< get_sfl_from_alias_value >--------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_sfl_from_alias_value(p_alias_value_id IN VARCHAR2)
	RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |---------------------------< time_entry_rules_segment_trans >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE time_entry_rules_segment_trans
             (p_timecard_id	IN NUMBER
             ,p_timecard_ovn	IN NUMBER
             ,p_start_time	IN DATE
             ,p_stop_time	IN DATE
             ,p_resource_id	IN NUMBER
             ,p_attr_change_table IN OUT NOCOPY hxc_time_entry_rules_utils_pkg.t_change_att_tab);


-- ----------------------------------------------------------------------------
-- |---------------------------< debug procedure         >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE dump_alias_val_att_to_match (p_alias_val_att_to_match IN OUT NOCOPY t_alias_val_att_to_match);
PROCEDURE dump_bb_attribute_info
        (p_attributes in out NOCOPY HXC_ATTRIBUTE_TABLE_TYPE);--hxc_self_service_time_deposit.building_block_attribute_info);
PROCEDURE dump_alias_def_item (p_alias_def_item IN OUT NOCOPY t_alias_def_item);


----------------------------------------------------------------------------------
--- TEMPORARY FUNCTION
----------------------------------------------------------------------------------

-- USE IN SS
PROCEDURE alias_def_comma_list(p_alias_type IN VARCHAR2
        	              ,p_start_time IN VARCHAR2
	                      ,p_stop_time  IN VARCHAR2
			      ,p_resource_id IN NUMBER
			      ,p_alias_def_comma OUT NOCOPY VARCHAR2);
-- USE IN DEPOSIT WRAPPER UTILITIES
FUNCTION get_list_alias_id(p_alias_type IN VARCHAR2
                    	  ,p_start_time IN VARCHAR2
                     	  ,p_stop_time  IN VARCHAR2
                     	  ,p_resource_id IN NUMBER) RETURN t_alias_def_item;

FUNCTION get_bld_blk_type_id(p_type IN varchar2) RETURN NUMBER;

/*
Function convert_attribute_to_type
          (p_attributes in HXC_SELF_SERVICE_TIME_DEPOSIT.building_block_attribute_info)
          return HXC_ATTRIBUTE_TABLE_TYPE;

Function convert_timecard_to_type
          (p_blocks in HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info)
          return HXC_BLOCK_TABLE_TYPE;
*/
-- ----------------------------------------------------------------------------
-- |---------------------------< get_translated_detail >--------------------|
-- ----------------------------------------------------------------------------

-- use in the extract
PROCEDURE get_translated_detail (p_detail_bb_id  in NUMBER,
                                 p_detail_bb_ovn in NUMBER,
                                 p_resource_id   in NUMBER,
                                 p_attributes OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,
                                 p_messages   IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE );


END HXC_ALIAS_UTILITY;

 

/
