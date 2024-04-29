--------------------------------------------------------
--  DDL for Package HXC_APP_ATTRIBUTE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APP_ATTRIBUTE_UTILS" AUTHID CURRENT_USER as
/* $Header: hxcappattut.pkh 120.1 2006/03/31 19:48:41 arundell noship $ */

Type mapping_component is Record
 (segment               fnd_descr_flex_column_usages.application_column_name%type
 ,field_name            hxc_mapping_components.field_name%type
 ,category              hxc_bld_blk_info_type_usages.building_block_category%type
 ,info_type             hxc_bld_blk_info_types.bld_blk_info_type%type
 ,retrieval_process_id  hxc_retrieval_processes.retrieval_process_id%type
 ,deposit_process_id    hxc_deposit_processes.deposit_process_id%type
 ,mapping_component_id  hxc_mapping_components.mapping_component_id%type
 );

Type mappings is table of mapping_component index by binary_integer;

Type mapping_idxs is Record
  (start_index number
  ,stop_index  number
  );

Type mapping_info is table of mapping_idxs index by binary_integer;

type appset_recipient is record
  (recipient1 number
  ,recipient2 number
  ,recipient3 number
  ,recipient4 number
  ,recipient5 number
  ,recipient6 number
  ,recipient7 number
  ,recipient8 number
  ,recipient9 number
  ,recipient10 number
  ,recipient11 number
  ,recipient12 number
  ,recipient13 number
  ,recipient14 number
  ,recipient15 number
  );

type appset_recipient_table is table of appset_recipient index by binary_integer;

Procedure cache_mappings;

   Procedure clear_mapping_cache;

Function findSegmentFromFieldName
          (p_field_name           in hxc_mapping_components.field_name%type
          ) return varchar2;

Function create_app_attributes
           (p_attributes           in     hxc_attribute_table_type
           ,p_retrieval_process_id in     hxc_retrieval_processes.retrieval_process_id%type
           ,p_deposit_process_id   in     hxc_deposit_processes.deposit_process_id%type
           ) return hxc_self_service_time_deposit.app_attributes_info;

Function create_app_attributes
           (p_blocks               in     hxc_block_table_type
           ,p_attributes           in     hxc_attribute_table_type
           ,p_retrieval_process_id in     hxc_retrieval_processes.retrieval_process_id%type
           ,p_deposit_process_id   in     hxc_deposit_processes.deposit_process_id%type
           ,p_recipients           in     hxc_timecard_validation.recipient_application_table
           ) return hxc_self_service_time_deposit.app_attributes_info;

Procedure update_attributes
           (p_attributes     in out nocopy hxc_attribute_table_type
           ,p_app_attributes in out nocopy hxc_self_service_time_deposit.app_attributes_info
           );

end hxc_app_attribute_utils;

 

/
