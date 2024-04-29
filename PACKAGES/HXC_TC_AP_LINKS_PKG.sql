--------------------------------------------------------
--  DDL for Package HXC_TC_AP_LINKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TC_AP_LINKS_PKG" AUTHID CURRENT_USER as
/* $Header: hxctalsum.pkh 115.0 2003/07/15 09:49:28 arundell noship $ */

procedure insert_summary_row(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type
                            ,p_application_period_id in hxc_time_building_blocks.time_building_block_id%type);

procedure delete_summary_row(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type
                            ,p_application_period_id in hxc_time_building_blocks.time_building_block_id%type);

procedure remove_timecard_links(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type);

procedure create_timecard_links(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type);

procedure remove_app_period_links
            (p_application_period_id in hxc_tc_ap_links.application_period_id%type);

procedure create_app_period_links
            (p_application_period_id in hxc_tc_ap_links.application_period_id%type);

end hxc_tc_ap_links_pkg;

 

/
