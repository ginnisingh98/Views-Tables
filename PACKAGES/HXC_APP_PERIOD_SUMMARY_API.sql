--------------------------------------------------------
--  DDL for Package HXC_APP_PERIOD_SUMMARY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APP_PERIOD_SUMMARY_API" AUTHID CURRENT_USER as
/* $Header: hxcapsumapi.pkh 120.1.12010000.1 2008/07/28 11:04:43 appldev ship $ */

TYPE valid_period_rec IS RECORD (
  start_time      hxc_time_building_blocks.start_time%TYPE
 ,stop_time       hxc_time_building_blocks.stop_time%TYPE
);

TYPE valid_period_tab IS TABLE OF valid_period_rec INDEX BY BINARY_INTEGER;

procedure app_period_create
            (p_application_period_id  in hxc_app_period_summary.application_period_id%type
            ,p_mode in varchar2 default hxc_timecard_summary_pkg.c_normal_mode);


procedure app_period_create
            (p_application_period_id  in hxc_app_period_summary.application_period_id%type
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
            ,p_approval_item_key      in hxc_app_period_summary.approval_item_key%type default null
            );

procedure app_period_delete
            (p_application_period_id in hxc_app_period_summary.application_period_id%type);


PROCEDURE get_valid_periods(
  p_resource_id       IN hxc_time_building_blocks.resource_id%TYPE
 ,p_time_recipient_id IN hxc_time_recipients.time_recipient_id%TYPE
 ,p_start_date        IN DATE
 ,p_stop_date         IN DATE
 ,p_valid_status      IN VARCHAR2
 ,p_valid_periods    OUT NOCOPY valid_period_tab
);

end hxc_app_period_summary_api;

/
