--------------------------------------------------------
--  DDL for Package HXC_TEMPLATE_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TEMPLATE_SUMMARY_PKG" AUTHID CURRENT_USER AS
/* $Header: hxctempsumpkg.pkh 120.0 2005/05/29 06:23:14 appldev noship $ */

PROCEDURE INSERT_SUMMARY_ROW
		(p_template_id in hxc_time_building_blocks.time_building_block_id%type,
		 p_template_ovn in hxc_time_building_blocks.OBJECT_VERSION_NUMBER%type,
		 p_template_name in hxc_template_summary.TEMPLATE_NAME%type,
		 p_description in hxc_template_summary.DESCRIPTION%type,
		 p_template_type in hxc_template_summary.TEMPLATE_TYPE%type,
		 p_layout_id in hxc_template_summary.LAYOUT_ID%type,
		 p_recurring_period_id in hxc_template_summary.RECURRING_PERIOD_ID%type,
		 p_business_group_id in hxc_template_summary.BUSINESS_GROUP_ID%type,
		 p_resource_id in hxc_template_summary.RESOURCE_ID%type
		);

PROCEDURE UPDATE_SUMMARY_ROW(p_template_id in hxc_time_building_blocks.time_building_block_id%type);

PROCEDURE DELETE_SUMMARY_ROW(p_template_id in hxc_time_building_blocks.time_building_block_id%type);

END HXC_TEMPLATE_SUMMARY_PKG;

 

/
