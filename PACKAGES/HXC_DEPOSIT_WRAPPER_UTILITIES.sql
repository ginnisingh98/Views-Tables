--------------------------------------------------------
--  DDL for Package HXC_DEPOSIT_WRAPPER_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DEPOSIT_WRAPPER_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: hxcdpwrut.pkh 120.0 2005/05/29 05:28:50 appldev noship $ */

TYPE t_simple_table
IS TABLE OF
HXC_TIME_BUILDING_BLOCKS.COMMENT_TEXT%TYPE
INDEX BY BINARY_INTEGER;

TYPE dupdff_code_name_rec IS RECORD(
dupDFF_CODE FND_DESCR_FLEX_CONTEXTS_VL.DESCRIPTIVE_FLEX_CONTEXT_CODE%TYPE,
dupDFF_NAME FND_DESCR_FLEX_CONTEXTS_VL.DESCRIPTIVE_FLEX_CONTEXT_NAME%TYPE
);

TYPE  dupdff_code_name_TABLE IS TABLE OF dupdff_code_name_rec INDEX BY BINARY_INTEGER;

g_code_name_tab dupdff_code_name_TABLE;

TYPE r_transaction IS RECORD (
        txd_id          hxc_transaction_details.transaction_detail_id%TYPE
,	tbb_id		hxc_time_building_blocks.time_building_block_id%TYPE
,	tbb_ovn		hxc_time_building_blocks.object_version_number%TYPE
,	status		hxc_transaction_details.status%TYPE
,	exception_desc	hxc_transaction_details.exception_description%TYPE );

TYPE t_transaction IS TABLE OF r_transaction INDEX BY BINARY_INTEGER;

PROCEDURE build_context_string
            (p_context_codes     in            varchar2
            ,p_system_linkage    in            varchar2
            ,p_expenditure_type  in            varchar2
            ,p_pa_alias_value_id in            varchar2
            ,p_context_string       out nocopy varchar2
            );

PROCEDURE get_preferences
           (p_resource_id in number
           ,p_preference_string in varchar2
           ,p_include_pp in varchar2
           ,p_preference_date in varchar2
           ,p_preference_end_date in varchar2
           ,p_timecard_id in number
           ,p_preference_returns out nocopy varchar2
           );

FUNCTION blocks_to_string
           (p_blocks IN hxc_self_service_time_deposit.timecard_info)
           RETURN VARCHAR2;

FUNCTION string_to_blocks
           (p_block_string IN varchar2)
           RETURN hxc_self_service_time_deposit.timecard_info;

FUNCTION attributes_to_string
           (p_attributes IN hxc_self_service_time_deposit.app_attributes_info)
           RETURN VARCHAR2;

FUNCTION string_to_attributes
           (p_attribute_string IN varchar2)
           RETURN hxc_self_service_time_deposit.app_attributes_info;

FUNCTION string_to_bld_blk_attributes
           (p_attribute_string IN varchar2)
           RETURN hxc_self_service_time_deposit.building_block_attribute_info;

FUNCTION messages_to_string
           (p_messages IN hxc_self_service_time_deposit.message_table)
           RETURN VARCHAR2;

FUNCTION string_to_messages
           (p_message_string IN varchar2)
           RETURN hxc_self_service_time_deposit.message_table;


FUNCTION attributes_to_string(
  p_attributes IN hxc_self_service_time_deposit.building_block_attribute_info
)
RETURN VARCHAR2;

PROCEDURE STRING_TO_TABLE(p_separator  IN VARCHAR2,
                          p_string     IN VARCHAR2,
                          p_table     OUT NOCOPY t_simple_table);

procedure audit_transaction
  (p_effective_date         in date
  ,p_transaction_type       in varchar2
  ,p_transaction_process_id in number
  ,p_overall_status         in varchar2
  ,p_transaction_tab        in out nocopy t_transaction
  );

----
-- Function returning a list of hours types and ids for use on the timecard
----

function timecard_hours_type_list( p_resource_id          in varchar2,
                                    p_start_time          in varchar2,
                                    p_stop_time           in varchar2,
                                    p_alias_or_element_id in varchar2) return varchar2;




FUNCTION array_to_attributes(
  p_attribute_array IN HXC_ATTRIBUTE_TABLE_TYPE
)
RETURN hxc_self_service_time_deposit.building_block_attribute_info;

FUNCTION attributes_to_array(
  p_attributes IN hxc_self_service_time_deposit.building_block_attribute_info
)
RETURN HXC_ATTRIBUTE_TABLE_TYPE;

FUNCTION array_to_blocks(
  p_block_array     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
)
RETURN hxc_self_service_time_deposit.timecard_info;

FUNCTION blocks_to_array(
  p_blocks IN hxc_self_service_time_deposit.timecard_info
)
RETURN HXC_BLOCK_TABLE_TYPE;

FUNCTION get_dupdff_code(p_dupdff_name IN VARCHAR2) return varchar2;

FUNCTION get_dupdff_name(p_dupdff_code IN VARCHAR2) return varchar2;

function timecard_hours_type_list(  p_resource_id         in varchar2,
                                    p_start_time          in varchar2,
                                    p_stop_time           in varchar2,
                                    p_alias_or_element_id in varchar2,
				    p_aliases in VARCHAR2,
				    p_public_template in varchar2) return varchar2;

procedure replace_resource_id(p_blocks     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
				 p_resource_id IN hxc_time_building_blocks.resource_id%type);

END hxc_deposit_wrapper_utilities;

 

/
