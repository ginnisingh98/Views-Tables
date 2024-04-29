--------------------------------------------------------
--  DDL for Package HXC_AP_DETAIL_LINKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_AP_DETAIL_LINKS_PKG" AUTHID CURRENT_USER as
/* $Header: hxcadtsum.pkh 120.0 2005/05/29 05:22:09 appldev noship $ */

g_package  varchar2(33)	:= ' hxc_ap_detail_links_pkg.';  -- Global package name

procedure insert_summary_row(p_application_period_id   in hxc_time_building_blocks.time_building_block_id%type
                            ,p_time_building_block_id  in hxc_time_building_blocks.time_building_block_id%type
                            ,p_time_building_block_ovn in hxc_time_building_blocks.object_version_number%type);

procedure delete_summary_row(p_application_period_id   in hxc_time_building_blocks.time_building_block_id%type
                            ,p_time_building_block_id  in hxc_time_building_blocks.time_building_block_id%type
                            ,p_time_building_block_ovn in hxc_time_building_blocks.object_version_number%type);

procedure delete_ap_detail_links(p_application_period_id in hxc_time_building_blocks.time_building_block_id%type);

procedure delete_ap_detail_links(p_timecard_id in  number
                                ,p_blocks      in  hxc_block_table_type);

procedure create_ap_detail_links(p_application_period_id in hxc_time_building_blocks.time_building_block_id%type);

end hxc_ap_detail_links_pkg;

 

/
