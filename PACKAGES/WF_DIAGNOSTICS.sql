--------------------------------------------------------
--  DDL for Package WF_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_DIAGNOSTICS" AUTHID CURRENT_USER as
/* $Header: WFDIAGPS.pls 120.3.12010000.1 2008/07/25 14:28:19 appldev ship $ */

-- Table cell
type tdType is table of varchar2(4005) index by binary_integer;

--
-- Get_Ntf_Item_Info
--   Returns a HTML table of Notification Information from wf_notifications table.
--
function Get_Ntf_Item_Info(p_nid in number)
return varchar2;

--
-- Get_Ntf_Role_Users
--   Returns a HTML table of users who belong to the notification recipient
--   table, if the recipient role has more than one user associated
--
function Get_Ntf_Role_Users(p_nid in number)
return varchar2;


--
-- Get_Summary_Ntf_Role_Users
--   Returns a HTML table of users who belong to the given role
--   , if the recipient role has more than one user associated
--
function Get_Summary_Ntf_Role_Users(p_role  in varchar2)
return varchar2;

--
-- Get_Ntf_Role_Info
--    Returns a HTML table of the recipient role's information as in wf_roles
--
function Get_Ntf_Role_Info(p_nid in number)
return varchar2;

--
-- Get_Summary_Ntf_Role_Info
--    Returns a HTML table of the recipient role's information as in wf_roles
--
function Get_Summary_Ntf_Role_Info(p_role in varchar2)
return varchar2;

--
-- Get_Routing_Rules
--    Returns a HTML table of the routing rules for the notfication's recipient
--    role
--
function Get_Routing_Rules(p_nid in number)
return varchar2;

--
-- Get_Ntf_More_Info
--   Returns a HTML table of the More info role's information as in wf_roles
--
function Get_Ntf_More_Info(p_nid in number)
return varchar2;

--
-- Get_Ntf_Msg_Attrs
--   Returns a HTML table of all the Message Attributes associated with the
--   Notification message
--
procedure Get_Ntf_Msg_Attrs(p_nid   in  number,
                            p_value in out nocopy clob);

--
-- Get_Ntf_Attrs
--   Returns a HTML table of all the Notification Attributes associated with the
--   Notification message
procedure Get_Ntf_Attrs(p_nid   in  number,
                        p_value in out nocopy clob);

--
-- Get_User_Comments
--   Returns a HTML table of all the User Comments exchanged in Question/Answer modes
--
procedure Get_User_Comments(p_nid   in number,
                            p_value in out nocopy clob);

--
-- Get_Event_Queue_Status
--   Returns a HTML table of the status of an event from a specified BES queue with the
--   matching event key provided.
--
function Get_Event_Queue_Status(p_queue_name in varchar2,
                                p_event_name in varchar2,
                                p_event_key  in varchar2)
return varchar2;

--
-- Get_JMS_Queue_Status
--   Returns a HTML table of the status of an event message from a specified JMS
--   queue with the matching event key provided.
--
function Get_JMS_Queue_Status(p_queue_name in varchar2,
                              p_event_name in varchar2,
                              p_event_key  in varchar2)
return varchar2;

--
-- Get_JMS_Queue_Status
--   Returns a HTML table of the status of an event message from a specified JMS
--   queue with the matching event key, name, and corr_id provided.
--
function Get_JMS_Queue_Status(p_queue_name in varchar2,
                              p_event_name in varchar2,
                              p_event_key  in varchar2,
			      p_corr_id    in varchar2)
return varchar2;


--
-- Get_Ntf_Templates
--   Returns HTML table of the email templates and the Notification Message body
--   for HTML as well as Text formatting
--
procedure Get_Ntf_Templates(p_nid   in number,
                            p_value in out nocopy clob);


--
-- get_Summary_Templates
--   Returns HTML table of the Summary (email)templates and the Notification Message body
--   for HTML as well as Text formatting
--
procedure get_Summary_Templates(p_role in varchar2,
 	                        p_ntf_pref in varchar2,
 	                        p_value in out nocopy clob);

--
-- Get_Ntf_Message
--   Returns a HTML table of the Notification Message source as it is generated for
--   the mailer
--
procedure Get_Ntf_Message(p_nid   in number,
                          p_value in out nocopy clob);



-- Get_Summary_Ntf_Message
-- Get the XML for oracle.apps.wf.notification.summary.send event
-- Output of WF_XML.generate function
--
procedure Get_Summary_Ntf_Message(p_role   in varchar2,
                                  p_value in out nocopy clob);

--
-- Get_Ntf_Msg_From_Out
-- Returns PAYLOAD from WF_NOTIFICATION_OUT AQ for a given nid / event key
--
procedure Get_Ntf_Msg_From_Out(p_nid   in number,
                               p_value in out nocopy clob);

-- Get_Ntf_Msg_From_Out
-- Returns PAYLOAD from WF_NOTIFICATION_OUT AQ for a given nid / event key
--
procedure Get_Ntf_Msg_From_Out(p_nid   in VARCHAR2,
                               p_corr_id in varchar2,
                               p_value in out nocopy clob);

--
-- Get_Ntf_Msg_From_In
-- Returns PAYLOAD from WF_NOTIFICATION_IN AQ for a given nid / event key
--
procedure Get_Ntf_Msg_From_In(p_nid   in number,
                               p_value in out nocopy clob);

-- Get_Ntf_Msg_From_In
-- Returns PAYLOAD from WF_NOTIFICATION_In AQ for a given nid / event key
--
procedure Get_Ntf_Msg_From_In(p_nid   in varchar2,
                               p_corr_id in varchar2,
                               p_value in out nocopy clob);

-- Get_Summary_Msg_From_Out
-- Returns PAYLOAD from WF_NOTIFICATION_OUT AQ for a given role
--
procedure Get_Summary_Msg_From_Out(p_role   in varchar2,
 	                           p_value in out nocopy clob);


--
-- Get_GSC_Comp_Parameters
--    Returns a HTML table of all the Service Components and their parameters given the
--    Component type and/or the component name.
--
procedure Get_GSC_Comp_Parameters(p_comp_type in varchar2,
                                  p_comp_name in varchar2 default null,
                                  p_value     in out nocopy clob);



--
-- Get_GSC_Comp_ScheduledEvents -
--
-- Returns scheduled events for a given component
-- Out
--  p_value
--    Returns a HTML table of all the Service Components
--    and their scheduled events for a  given
--    Component type and/or the component name.
--
procedure Get_GSC_Comp_ScheduledEvents(p_comp_type in varchar2,
                                  p_comp_name in varchar2 default null,
                                  p_value     in out nocopy clob);

--
-- Get_Mailer_Tags
--    Returns a HTML table of all the Mailer Tag information
--
function Get_Mailer_Tags return varchar2;

--
-- GetTOC
--    Generates the Table of Contents for the Mailer Debug Information.
--
function Get_Mailer_TOC(p_nid in number)
return varchar2;

--
-- Get_Mailer_Debug
--    Returns a complete HTML document of the Mailer Debug information
--
procedure Get_Mailer_Debug(p_nid   in number,
                           p_value out nocopy clob);

--
-- Check the GSC Control Queue Status Info
--    Returns the basic information about Control Queue Status

procedure Get_Control_Queue_Status(p_value out nocopy clob);

--
-- Check the Migration Status Info
--    Returns the basic information about Migration Status
procedure Get_BES_Clone_Status (p_value out nocopy clob);

--
-- Show
--   Given a varchar2 string, the value is written to the console using
--   dbms_output.put_line
procedure Show(p_value     in varchar2);

--
-- Show
--   Given a CLOB string, the value is written to the console using
--   dbms_output.put_line
procedure Show(p_value     in CLOB);

--
-- CheckObjectsValidity
--   Checks if the WF/ECX Objects in the database are valid and gives a
--   result back to the caller
procedure CheckObjectsValidity(p_status   out nocopy varchar2,
                               p_report   out nocopy varchar2);

--
-- CheckXMLParserStatus
--   Checks the installation status of XML Parser.
procedure CheckXMLParserStatus(p_status   out nocopy varchar2,
                               p_report   out nocopy varchar2);

--
-- CheckAgentsAQStatus
--   Checks the validity of the Agents, AQs associated with the Agents, rules
--   and AQ subscribers
procedure CheckAgentsAQStatus(p_status   out nocopy varchar2,
                              p_report   out nocopy CLOB);

--
-- GetXMLParserVersion
--   Gets the XML Parser version in the database. This function is modeled
--   after ECX_UTILS.XMLVersion for use within Standalone Workflow
function GetXMLParserVersion return varchar2;

--
-- Get_Bes_Debug
--    Returns a complete HTML document of the BES Debug information
--
procedure Get_Bes_Debug(p_event_name   in varchar2,
                        p_event_key    in varchar2,
                        p_value        out nocopy clob);


--
-- Get_Mailer_Summary_Ntf_Debug
--  Returns information about summary notification for a role
procedure Get_Summary_Mailer_Debug(p_role in varchar2,
                                   p_content out nocopy clob);


--
--  Get_Mailer_Alert_Debug
--  Returns information about Alert for a module with id string
procedure Get_Mailer_Alert_Debug(p_module   in varchar2,
				 p_idstring in varchar2,
                                 p_content  out nocopy clob);



end WF_DIAGNOSTICS;

/
