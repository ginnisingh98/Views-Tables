--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_SUMMARY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_SUMMARY_API" AUTHID CURRENT_USER as
/* $Header: hxctcsumapi.pkh 120.0 2005/05/29 06:14:22 appldev noship $ */

 Procedure delete_timecard
	    (p_blocks in hxc_block_table_type
            ,p_timecard_id in number
            ,p_mode        in varchar2 default hxc_timecard_summary_pkg.c_normal_mode
            );

 Procedure delete_timecard
	    (p_timecard_id in hxc_timecard_summary.timecard_id%type
            ,p_mode        in varchar2 default hxc_timecard_summary_pkg.c_normal_mode
            );

procedure timecard_deposit
            (p_blocks in hxc_block_table_type
            ,p_mode   in varchar2 default hxc_timecard_summary_pkg.c_normal_mode
   	    ,p_approval_item_type    in varchar2
	    ,p_approval_process_name in varchar2
	    ,p_approval_item_key     in varchar2
   	    ,p_tk_audit_item_type    in varchar2
	    ,p_tk_audit_process_name in varchar2
	    ,p_tk_audit_item_key     in varchar2
	    );

procedure timecard_deposit
            (p_timecard_id in hxc_timecard_summary.timecard_id%type
            ,p_mode   in varchar2 default hxc_timecard_summary_pkg.c_normal_mode
   	    ,p_approval_item_type    in varchar2
	    ,p_approval_process_name in varchar2
	    ,p_approval_item_key     in varchar2
   	    ,p_tk_audit_item_type    in varchar2
	    ,p_tk_audit_process_name in varchar2
	    ,p_tk_audit_item_key     in varchar2
	    );

procedure timecard_delete
            (p_blocks in hxc_block_table_type);

procedure timecard_delete
            (p_timecard_id in hxc_timecard_summary.timecard_id%type);

procedure reevaluate_timecard_statuses
            (p_application_period_id in hxc_app_period_summary.application_period_id%type);

end hxc_timecard_summary_api;

 

/
