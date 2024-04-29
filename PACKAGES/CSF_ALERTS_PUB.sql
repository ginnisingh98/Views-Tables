--------------------------------------------------------
--  DDL for Package CSF_ALERTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_ALERTS_PUB" AUTHID CURRENT_USER AS
/*$Header: csfAlerts.pls 120.0.12000000.5 2007/07/24 09:35:49 htank noship $*/

-- to store task detail for notification content
type task_asgn_record is record
(
  task_number     jtf_tasks_b.task_number%type,
  task_name       jtf_tasks_vl.task_name%type,
  task_desc       jtf_tasks_vl.description%type,
  sch_st_date     jtf_tasks_b.scheduled_start_date%type,
  old_sch_st_date     jtf_tasks_b.scheduled_start_date%type,
  sch_end_date    jtf_tasks_b.scheduled_end_date%type,
  old_sch_end_date    jtf_tasks_b.scheduled_end_date%type,
  planned_effort  varchar2(100),
  priority        jtf_task_priorities_vl.name%type,
  asgm_sts_name   jtf_task_statuses_vl.name%type,
  sr_number       cs_incidents_all_b.incident_number%type,
  sr_summary      cs_incidents_all_b.summary%type,
  product_nr      mtl_system_items_vl.concatenated_segments%type,
  item_serial     cs_customer_products_all.current_serial_number%type,
  item_description  mtl_system_items_vl.description%type,
  cust_name       hz_parties.party_name%type,
  cust_address    varchar2(1000),
  contact_name    varchar2(100),
  contact_phone   varchar2(100),
  contact_email   varchar2(250)
);

-- to store contact details for notification content
type contact_record is record
(
  contact_name    varchar2(100),
  contact_phone   varchar2(100),
  contact_email   varchar2(250)
);

-- procedure to check event type
procedure checkEvent (itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2);

-- procedure to check task precondition
-- before generating reminder notification
procedure check_again (itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2);

-- check CSF: Alert Auto Reject profile is set or not
procedure check_auto_reject (itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2);

-- Procedure to change task assignment status to default Accepted profile
procedure accept_assgn (itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2);

-- Procedure to change task assignment status to default Rejected profile
procedure cancel_assgn (itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2);

-- subscription function for oracle.apps.csf.alerts.sendNotification event
function sendNotification (p_subscription_guid in raw,
                           p_event in out nocopy WF_EVENT_T) return varchar2;

-- generates Send Date for CSF event based on profile values
function getSendDate (p_resource_id number,
                      p_resource_type_code varchar2,
                      p_scheduled_start_date date,
                      p_scheduled_end_date date) return date;

-- Returns user_id for a given ersource
function getUserId (p_resource_id number,
                    p_resource_type varchar2) return number;

-- Returns user_name for a given resource
function getUserName (p_resource_id number,
                    p_resource_type varchar2) return varchar2;

-- Returns Category type for resource type
function category_type ( p_rs_category varchar2 ) return varchar2;

-- Generated item_key for workflow
function getItemKey (p_event_type varchar2,
                    p_resource_id number,
                    p_resource_type_code varchar2,
                    p_task_assignment_id varchar2,
                    p_old_event_id varchar2) return varchar2;

-- Check profile for a given resource
function checkAlertsEnabled(p_resource_id number,
                              p_resource_type_code varchar2) return boolean;

-- Generates Assigned notification content
procedure getAssignedMessage(document_id varchar2,
                            display_type varchar2,
                            document in out nocopy varchar2,
                            document_type in out nocopy varchar2);

-- Generates Reminder notification content
procedure getReminderMessage(document_id varchar2,
                            display_type varchar2,
                            document in out nocopy varchar2,
                            document_type in out nocopy varchar2);

-- Generates Cancelled notification content
procedure getDeleteMessage(document_id varchar2,
                            display_type varchar2,
                            document in out nocopy varchar2,
                            document_type in out nocopy varchar2);

-- Generates Rescheduled notification content
procedure getRescheduleMessage(document_id varchar2,
                            display_type varchar2,
                            document in out nocopy varchar2,
                            document_type in out nocopy varchar2);

-- Returns contact details for SR
function getContactDetail(p_incident_id number,
                            p_contact_type varchar2,
                            p_party_id number) return contact_record;

-- Returns all the required task details to generate notification content
function getTaskDetails(p_task_id number,
                            p_task_asgn_id number,
                            p_task_audit_id number) return task_asgn_record;

-- Subscription function for task assignemnt events
function checkForAlerts (p_subscription_guid in raw,
                           p_event in out nocopy WF_EVENT_T) return varchar2;

-- Returns date in client timezone
function getClientTime (p_server_time date, p_user_id number) return date;

-- Returns translated prompt
function getPrompt (p_name varchar2) return varchar2;

-- Returns WF ROLE NAME
function getWFRole (p_resource_id number) return varchar2;

END csf_alerts_pub;

 

/
