--------------------------------------------------------
--  DDL for Package HXC_TIME_APPROVAL_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_APPROVAL_INFO" AUTHID CURRENT_USER AS
/* $Header: hxctcapinfo.pkh 115.2 2004/07/05 02:36:37 dragarwa noship $ */

c_pay constant varchar2(7)  := 'Payroll';
c_per constant varchar2(15) := 'Human Resources';
c_pa  constant varchar2(8)  := 'Projects';
c_po  constant varchar2(10) := 'Purchasing';

type timecard_info is record
   (timecard_id hxc_timecard_summary.timecard_id%type,
    approval_status hxc_timecard_summary.approval_status%type,
    approval_date hxc_timecard_summary.submission_date%type,
    recorded_hours hxc_timecard_summary.recorded_hours%type,
    audit_data_exists hxc_timecard_summary.has_reasons%type,
    submission_date hxc_timecard_summary.submission_date%type
    );

type application_info is record
   (time_recipient_id hxc_app_period_summary.time_recipient_id%type,
    approval_status hxc_app_period_summary.approval_status%type,
    creation_date hxc_app_period_summary.creation_date%type,
    notification_status hxc_app_period_summary.notification_status%type,
    approver varchar2(360)
    );

type application_info_table is table of application_info
    index by binary_integer;

function get_timecard_approval_status
(p_timecard_id in hxc_timecard_summary.timecard_id%type)
return hxc_timecard_summary.approval_status%type;

function get_timecard_approval_status
(p_resource_id in hxc_timecard_summary.resource_id%type,
 p_start_time in hxc_timecard_summary.start_time%type,
 p_stop_time in hxc_timecard_summary.stop_time%type)
return hxc_timecard_summary.approval_status%type;

function get_timecard_approval_date
(p_timecard_id in hxc_timecard_summary.timecard_id%type)
return hxc_timecard_summary.submission_date%type;

function get_timecard_approval_date
(p_resource_id in hxc_timecard_summary.resource_id%type,
 p_start_time in hxc_timecard_summary.start_time%type,
 p_stop_time in hxc_timecard_summary.stop_time%type)
return hxc_timecard_summary.submission_date%type;

function get_timecard_recorded_hours
(p_timecard_id in hxc_timecard_summary.timecard_id%type)
return hxc_timecard_summary.recorded_hours%type;

function get_timecard_recorded_hours
(p_resource_id in hxc_timecard_summary.resource_id%type,
 p_start_time in hxc_timecard_summary.start_time%type,
 p_stop_time in hxc_timecard_summary.stop_time%type)
return hxc_timecard_summary.recorded_hours%type;

function get_timecard_audit_data_exists
(p_timecard_id in hxc_timecard_summary.timecard_id%type)
return hxc_timecard_summary.has_reasons%type;

function get_timecard_audit_data_exists
(p_resource_id in hxc_timecard_summary.resource_id%type,
 p_start_time in hxc_timecard_summary.start_time%type,
 p_stop_time in hxc_timecard_summary.stop_time%type)
return hxc_timecard_summary.has_reasons%type;

function get_timecard_submission_date
(p_timecard_id in hxc_timecard_summary.timecard_id%type)
return hxc_timecard_summary.submission_date%type;

function get_timecard_submission_date
(p_resource_id in hxc_timecard_summary.resource_id%type,
 p_start_time in hxc_timecard_summary.start_time%type,
 p_stop_time in hxc_timecard_summary.stop_time%type)
return hxc_timecard_summary.submission_date%type;

function get_app_approval_status
   (p_application_period_id in hxc_app_period_summary.application_period_id%type)
return hxc_app_period_summary.approval_status%type;

function get_app_approval_status
  (p_resource_id in hxc_app_period_summary.resource_id%type,
   p_start_time in hxc_app_period_summary.start_time%type,
   p_stop_time in hxc_app_period_summary.stop_time%type,
   p_application_name in hxc_time_recipients.name%type
   )
return hxc_app_period_summary.approval_status%type;

function get_app_approval_status
  (p_resource_id in hxc_app_period_summary.resource_id%type,
   p_start_time in hxc_app_period_summary.start_time%type,
   p_stop_time in hxc_app_period_summary.stop_time%type,
   p_application_name in hxc_time_recipients.name%type,
   p_time_category_name in hxc_time_categories.time_category_name%type
   )
return hxc_app_period_summary.approval_status%type;

function get_app_creation_date
  (p_application_period_id in hxc_app_period_summary.application_period_id%type)
return hxc_app_period_summary.creation_date%type;

function get_app_creation_date
  (p_resource_id in hxc_app_period_summary.resource_id%type,
   p_start_time in hxc_app_period_summary.start_time%type,
   p_stop_time in hxc_app_period_summary.stop_time%type,
   p_application_name in hxc_time_recipients.name%type
   )
return hxc_app_period_summary.creation_date%type;

function get_app_creation_date
  (p_resource_id in hxc_app_period_summary.resource_id%type,
   p_start_time in hxc_app_period_summary.start_time%type,
   p_stop_time in hxc_app_period_summary.stop_time%type,
   p_application_name in hxc_time_recipients.name%type,
   p_time_category_name in hxc_time_categories.time_category_name%type
   )
return hxc_app_period_summary.creation_date%type;

function get_app_approver
   (p_application_period_id in hxc_app_period_summary.application_period_id%type)
return varchar2;

function get_app_approver
  (p_resource_id in hxc_app_period_summary.resource_id%type,
   p_start_time in hxc_app_period_summary.start_time%type,
   p_stop_time in hxc_app_period_summary.stop_time%type,
   p_application_name in hxc_time_recipients.name%type
   )
return varchar2;

function get_app_approver
  (p_resource_id in hxc_app_period_summary.resource_id%type,
   p_start_time in hxc_app_period_summary.start_time%type,
   p_stop_time in hxc_app_period_summary.stop_time%type,
   p_application_name in hxc_time_recipients.name%type,
   p_time_category_name in hxc_time_categories.time_category_name%type
   )
return varchar2;

END hxc_time_approval_info;

 

/
