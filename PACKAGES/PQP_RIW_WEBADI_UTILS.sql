--------------------------------------------------------
--  DDL for Package PQP_RIW_WEBADI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_RIW_WEBADI_UTILS" AUTHID CURRENT_USER as
/* $Header: pqpriwadiutl.pkh 120.2.12010000.5 2009/07/22 14:40:19 psengupt ship $ */

g_proc_name   Varchar2(200) :='PQP_RIW_WEBADI_UTILS.';
g_seq_numbers Varchar2(2000);

-- =============================================================================
-- Record : r_riw_data
-- to get riw data
-- =============================================================================
TYPE r_riw_data IS RECORD(
        sequence       NUMBER
       ,interface_seq  NUMBER
       ,xml_tag        VARCHAR2(200)
       ,default_type   VARCHAR2(10)
       ,default_value  VARCHAR2(2000)
       ,placement      VARCHAR2(10)
       ,group_name     VARCHAR2(30)
       ,read_only      VARCHAR2(30)
     );

TYPE t_riw_data is Table OF r_riw_data
      INDEX BY BINARY_INTEGER;

g_riw_data                 t_riw_data;
g_temp_riw_data            t_riw_data;

-- =============================================================================
-- Record : r_delim_contxt
-- to get dff delimiter and context
-- =============================================================================
TYPE r_delim_contxt IS RECORD(
        con_seg_delim   fnd_descriptive_flexs.concatenated_segment_delimiter%TYPE
       ,con_col_name    fnd_descriptive_flexs.context_column_name%TYPE
     );

-- =============================================================================
-- Record : r_delim_contxt
-- to get dff delimiter and context
-- =============================================================================
TYPE r_segment_list IS RECORD(
        seg_name        fnd_descr_flex_column_usages.application_column_name%TYPE
   );

-- =============================================================================
-- This procedure creates RIW Webadi Setup
-- =============================================================================
PROCEDURE Create_RIW_Webadi_Setup
              (p_application_id       IN NUMBER
              ,p_data_source          IN VARCHAR2
              ,p_user_function_name   IN VARCHAR2
              ,p_menu_id              IN NUMBER
              ,p_seq_params           IN VARCHAR2
              ,p_intrfce_seq_params   IN VARCHAR2
              ,p_xml_tag_params       IN pqp_prompt_array_tab
              ,p_defalut_type_params  IN VARCHAR2
              ,p_defalut_value_params IN pqp_default_array_tab
              ,p_placement_params     IN VARCHAR2
              ,p_group_params         IN VARCHAR2
	      ,p_read_only_params     IN VARCHAR2
              ,p_action_type          IN VARCHAR2
              ,p_upd_layout_code      IN VARCHAR2
              ,p_upd_interface_code   IN VARCHAR2
              ,p_upd_mapping_code     IN VARCHAR2
              ,p_ins_upd_datapmp_flag IN VARCHAR2
              ,p_entity_name          IN VARCHAR2 DEFAULT NULL
              ,p_return_status        OUT NOCOPY VARCHAR2);

-- =============================================================================
-- This procedure creates RIW XML Tags
-- =============================================================================
PROCEDURE Create_RIW_XML_Tags
              (p_field_id             IN NUMBER
              ,p_xml_tag_id           IN NUMBER
              ,p_xml_tag_name         IN VARCHAR2
              ,p_business_group_id    IN VARCHAR2 );

-- =============================================================================
-- This procedure Deletes RIW Webadi Setup
-- =============================================================================
PROCEDURE Delete_RIW_Webadi_Setup
              (p_function_id          IN NUMBER
              ,p_menu_id              IN NUMBER);

-- =============================================================================
-- This procedure deletes RIW XML Tags
-- =============================================================================
PROCEDURE Delete_RIW_XML_Tag
              (p_xml_tag_id           IN NUMBER
              ,p_business_group_id    IN NUMBER) ;

-- =============================================================================
-- ~ Get Concatenated Exception for the linked batch lines:
-- =============================================================================
FUNCTION Get_concatenated_exception(p_batch_id in number,p_batch_link in number)
return varchar2;

-- =============================================================================
-- ~ Get Descriptive Flexfield concatanated data:
-- =============================================================================
FUNCTION Get_Concatanated_DFF_Segments
              (p_dff_name       IN VARCHAR2
              ,p_app_id         IN NUMBER
	      ,p_context        IN VARCHAR2
              ,p_effective_date IN DATE
	      ,p_entity         IN VARCHAR2
	      ,p_entity_id      IN NUMBER
              ,p_table_name     IN VARCHAR2 default null
              ,p_column         IN VARCHAR2 default null) RETURN Varchar2;




END PQP_RIW_WEBADI_UTILS;

/
