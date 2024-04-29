--------------------------------------------------------
--  DDL for Package HXC_ALIAS_TRANSLATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_TRANSLATOR" AUTHID CURRENT_USER AS
/* $Header: hxcalttlr.pkh 120.1.12010000.2 2008/08/05 11:59:28 ubhat ship $ */


g_attribute_id  NUMBER := -1;


-- Bug No : 6943339
-- Created the below associative array to hold the value set formats across
-- the alias translation procedures. Used an associative array because
-- we need to use this only if Alt name is based on value set - none
-- and we need it to be indexed with the reference object's ( the flex_
-- _value_set ) id.
-- Used VARCHAR2 as the type because an INTEGER index would give only
-- upto 10 digits while the reference object id could be as big as 15.

TYPE assoc_array  IS TABLE OF VARCHAR2(5) INDEX BY VARCHAR2(20);
g_vset_fmt  assoc_array;


PROCEDURE do_deposit_translation
         (p_attributes  IN OUT 	NOCOPY HXC_ATTRIBUTE_TABLE_TYPE--hxc_self_service_time_deposit.building_block_attribute_info);
         ,p_messages	        IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE);

PROCEDURE do_retrieval_translation
         (p_attributes	IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE--hxc_self_service_time_deposit.building_block_attribute_info
         ,p_blocks	IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE--hxc_self_service_time_deposit.timecard_info
         ,p_start_time  	IN DATE DEFAULT sysdate
         ,p_stop_time   	IN DATE DEFAULT hr_general.end_of_time
         ,p_resource_id 	IN NUMBER -- timekeeper or resource
         ,p_processing_mode	IN VARCHAR2 DEFAULT hxc_alias_utility.c_ss_processing
         ,p_add_alias_display_value     IN BOOLEAN DEFAULT FALSE
         ,p_add_alias_ref_object        IN BOOLEAN DEFAULT FALSE
         ,p_messages	        	IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         );

END HXC_ALIAS_TRANSLATOR;

/
