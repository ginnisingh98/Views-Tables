--------------------------------------------------------
--  DDL for Package HXC_APP_PERIOD_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APP_PERIOD_SUMMARY_PKG" AUTHID CURRENT_USER as
/* $Header: hxcapsum.pkh 120.0 2005/05/29 04:54:59 appldev noship $ */

procedure insert_summary_row
            (p_application_period_id in hxc_app_period_summary.application_period_id%type
            ,p_application_period_ovn in hxc_app_period_summary.application_period_ovn%type
            ,p_approval_status        in hxc_app_period_summary.approval_status%type
            ,p_time_recipient_id      in hxc_app_period_summary.time_recipient_id%type
            ,p_time_category_id       in hxc_app_period_summary.time_category_id%type
            ,p_start_time             in hxc_app_period_summary.start_time%type
            ,p_stop_time              in hxc_app_period_summary.stop_time%type
            ,p_resource_id            in hxc_app_period_summary.resource_id%type
            ,p_recipient_sequence     in hxc_app_period_summary.recipient_sequence%type
            ,p_category_sequence      in hxc_app_period_summary.category_sequence%type
            ,p_creation_date          in hxc_app_period_summary.creation_date%type
            ,p_notification_status    in hxc_app_period_summary.notification_status%type
            ,p_approver_id            in hxc_app_period_summary.approver_id%type
            ,p_approval_comp_id       in hxc_app_period_summary.approval_comp_id%type
	    ,p_approval_item_type     in hxc_app_period_summary.approval_item_type%type
	    ,p_approval_process_name  in hxc_app_period_summary.approval_process_name%type
	    ,p_approval_item_key      in hxc_app_period_summary.approval_item_key%type
	    ,p_data_set_id            in hxc_app_period_summary.data_set_id%type
            );

procedure insert_summary_row
            (p_app_period_id in hxc_time_building_blocks.time_building_block_id%type
	    ,p_approval_item_type     in hxc_app_period_summary.approval_item_type%type
	    ,p_approval_process_name  in hxc_app_period_summary.approval_process_name%type
	    ,p_approval_item_key      in hxc_app_period_summary.approval_item_key%type);

procedure update_summary_row(p_app_period_id in hxc_time_building_blocks.time_building_block_id%type
			    ,p_approval_item_type     in hxc_app_period_summary.approval_item_type%type
			    ,p_approval_process_name  in hxc_app_period_summary.approval_process_name%type
			    ,p_approval_item_key      in hxc_app_period_summary.approval_item_key%type
) ;


procedure delete_summary_row(p_app_period_id in hxc_time_building_blocks.time_building_block_id%type);

end hxc_app_period_summary_pkg;

 

/
