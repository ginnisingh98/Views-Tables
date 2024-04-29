--------------------------------------------------------
--  DDL for Package WF_EVENT_HTML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_EVENT_HTML" AUTHID CURRENT_USER as
/* $Header: wfehtms.pls 120.2 2005/09/01 09:54:18 aiqbal ship $ */

--
-- Types
--

-- hex representation of guid identifiers from web page
type hguid_array is table of varchar2(32) index by binary_integer;

--
-- isDeletable
--   Find out if a particular entity is deletable or not
-- IN
--   x_guid - global unique id for that entity
--   x_type - type of such entity 'EVENT|GROUP|SYSTEM|AGENT|SUBSCRIP'
-- RET
--   True if it is ok to delete.
--   False otherwise.
--
function isDeletable (
  x_guid in raw,
  x_type in varchar2
) return boolean;

-- isAccessible
--   Determines if a screen is accessible depending on data
-- IN
--   x_type - SYSTEM, AGENTS, EVENTS, SUBSCRIPTIONS
--
procedure isAccessible (
  x_type in varchar2
);

--
-- ListEvents
--   List events
-- NOTE
--
procedure ListEvents (
  h_display_name in varchar2 default null,
  h_name in varchar2 default null,
  h_status in varchar2 default '*',
  h_type in varchar2 default '*',
  resetcookie in varchar2 default 'F'
);

--
-- ListSystems
--   List systems
-- NOTE
--
procedure ListSystems (
  h_display_name in varchar2 default null,
  h_name in varchar2 default null,
  display_master in varchar2 default null,
  h_master_guid  in varchar2 default null,
  resetcookie in varchar2 default 'F'
);

--
-- ListAgents
--   List agents
-- NOTE
--
procedure ListAgents (
  h_name in varchar2 default null,
  h_protocol in varchar2 default null,
  h_address in varchar2 default null,
  display_system in varchar2 default null,
  h_system_guid in varchar2 default null,
  h_direction in varchar2 default '*',
  h_status in varchar2 default '*',
  use_guid_only in varchar2 default 'F',
  resetcookie in varchar2 default 'F'
);

--
-- ListSubscriptions
--   List subscriptions
-- NOTE
--
procedure ListSubscriptions (
  display_event in varchar2 default null,
  h_event_guid in varchar2 default null,
  h_source_type in varchar2 default '*',
  display_system in varchar2 default null,
  h_system_guid in varchar2 default null,
  h_status in varchar2 default '*',
  use_guid_only in varchar2 default 'F',
  resetcookie in varchar2 default 'F'
);

--
-- EditEvent
--   Create/Update an event
-- IN
--   h_guid - Global unique id for an event
-- NOTE
--
procedure EditEvent(
  h_guid in raw default null,
  h_type in varchar2 default 'EVENT'
);

--
-- EditGroup
--   Delete/Add events from/to group
-- IN
--   h_guid - Global unique id for an event
--   h_func - DELETE|ADD
-- NOTE
--
procedure EditGroup(
  h_guid in raw,
  h_func in varchar2 default 'DELETE',
  h_display_name in varchar2 default null,
  h_name in varchar2 default null,
  h_status in varchar2 default '*',
  h_type in varchar2 default '*'
);

--
-- EditSystem
--   Create/Update an event
-- IN
--   h_guid - Global unique id for a system
-- NOTE
--
procedure EditSystem(
  h_guid in raw default null);

--
-- EditAgent
--   Create/Update an agent
-- IN
--   h_guid - Global unique id for an agent
-- NOTE
--
procedure EditAgent(
  h_guid in raw default null);

--
-- EditSubscription
--   Create/Update a subscription
-- IN
--   h_guid - Global unique id for a subscription
-- NOTE
--
procedure EditSubscription(
  h_guid in raw default null,
  h_sguid in raw default null,
  h_eguid in raw default null);

--
-- SubmitEvent
--   Submit an event to database
-- IN
--   h_guids - Global unique id for an event (2nd element)
--   h_name - Event name
--   h_type - Event type: EVENT|GROUP
--   h_status - Event status: ENABLED|DISABLED
--   h_generate_function - Event function
--   h_owner_name
--   h_owner_tag
--   h_display_name
--   h_description
--   h_custom_level
-- NOTE
--
procedure SubmitEvent(
  h_guid              in varchar2,
  h_name              in varchar2,
  h_display_name      in varchar2,
  h_description       in varchar2,
  h_type              in varchar2,
  h_status            in varchar2,
  h_generate_function in varchar2,
  h_owner_name        in varchar2,
  h_owner_tag         in varchar2,
  h_custom_level      in varchar2,
  url                 in varchar2);

--
-- SubmitSelectedGEvents
--   Process selected events from group for deletion or addition
-- IN
--   h_gguid - Global unique id for the group event
--   h_guids - Array of global unique id of events
--   action  - DELETE|ADD|FIND
-- NOTE
--
procedure SubmitSelectedGEvents(
  h_gguid in raw,
  h_guids in hguid_array,
  action  in varchar2,
  url     in varchar2);

--
-- SubmitSystem
--   Submit an system to database
-- IN
--   h_guid - Global unique id for system
--   h_name - System name
--   h_display_name
--   h_description
-- NOTE
--
procedure SubmitSystem(
  h_guid              in varchar2,
  h_name              in varchar2,
  h_display_name      in varchar2,
  h_description       in varchar2,
  display_master      in varchar2,
  h_master_guid       in varchar2,
  url                 in varchar2);

--
-- SubmitAgent
--   Submit an agent to database
-- IN
--   h_guid - Global unique id for an agent
--   h_name
--   h_display_name
--   h_description
--   h_protocol
--   h_address
--   display_system
--   h_qhandler
--   h_qname
--   h_system_guid
--   h_direction
--   h_status - Agent status: ENABLED|DISABLED
-- NOTE
--
procedure SubmitAgent(
  h_guid              in varchar2,
  h_name              in varchar2,
  h_display_name      in varchar2,
  h_description       in varchar2,
  h_protocol          in varchar2,
  h_address           in varchar2,
  display_system      in varchar2,
  h_system_guid       in varchar2,
  h_qhandler          in varchar2,
  h_qname             in varchar2,
  h_direction         in varchar2,
  h_status            in varchar2,
  url                 in varchar2);

--
-- SubmitSubscription
--   Submit a subscription to database
-- IN
--   h_guid - Global unique id for an agent
--   h_display_name
--   h_description
--   h_protocol
--   h_address
--   h_system_guid
--   h_direction
--   h_status - Agent status: ENABLED|DISABLED
-- NOTE
--
procedure SubmitSubscription(
  h_guid              in varchar2,
  h_description       in varchar2,
  display_system      in varchar2,
  h_system_guid       in varchar2,
  h_source_type       in varchar2,
  display_source_agent in varchar2,
  h_source_agent_guid in varchar2,
  display_event       in varchar2,
  h_event_guid        in varchar2,
  h_phase             in varchar2,
  h_status            in varchar2,
  h_owner_name        in varchar2,
  h_owner_tag         in varchar2,
  h_rule_data         in varchar2,
  h_rule_function     in varchar2,
  display_out_agent   in varchar2,
  h_out_agent_guid    in varchar2,
  display_to_agent    in varchar2,
  h_to_agent_guid     in varchar2,
  h_priority          in varchar2,
  h_wfptype           in varchar2,
  h_wfptype_dname     in varchar2,
  h_wfpname           in varchar2,
  h_wfptn             in varchar2,
  h_parameters        in varchar2,
  h_custom_level      in varchar2,
  url                 in varchar2);


--
-- FindEvent
--   Filter page to find events
--
procedure FindEvent (
  x_gguid in raw default null,
  h_guid in raw default null,
  h_display_name in varchar2 default null,
  h_name in varchar2 default null,
  h_status in varchar2 default '*'
);

--
-- FindSystem
--   Filter page to find systems
--
procedure FindSystem;

--
-- FindAgent
--   Filter page to find agents
--
procedure FindAgent;

--
-- FindSubscription
--   Filter page to find subscriptions
--
procedure FindSubscription;

--
-- DeleteEvent
--   Delete an event
-- IN
--   h_guid - Global unique id for an event
-- NOTE
--
procedure DeleteEvent(
  h_guid in raw default null);

--
-- DeleteSystem
--   Delete a system
-- IN
--   h_guid - Global unique id for a system
-- NOTE
--
procedure DeleteSystem(
  h_guid in raw default null);

--
-- DeleteAgent
--   Delete an agent
-- IN
--   h_guid - Global unique id for an agent
-- NOTE
--
procedure DeleteAgent(
  h_guid in raw default null);

--
-- DeleteSubscription
--   Delete a subscription
-- IN
--   h_guid - Global unique id for a subscription
-- NOTE
--
procedure DeleteSubscription(
  h_guid in raw default null);

--
-- wf_event_val
--   Create the lov content for our event lov.  This function
--   is called by the generic lov function
-- IN
-- RETURNS
--
procedure wf_event_val (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out nocopy varchar2,
p_display_value  in out nocopy varchar2,
p_result         out nocopy number);

--
-- wf_system_val
--   Create the lov content for our system lov.  This function
--   is called by the generic lov function
-- IN
-- RETURNS
--
procedure wf_system_val (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out nocopy varchar2,
p_display_value  in out nocopy varchar2,
p_result         out nocopy number);

--
-- wf_agent_val
--   Create the lov content for our agent lov.  This function
--   is called by the generic lov function
-- IN
-- RETURNS
--
procedure wf_agent_val (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out nocopy varchar2,
p_display_value  in out nocopy varchar2,
p_result         out nocopy number,
p_param1         in varchar2 default null,
p_param2         in varchar2 default null);

--
-- wf_itemtype_val
--   Create the lov content for wf item type lov.  This function
--   is called by the generic lov function
-- IN
-- RETURNS
--
procedure wf_itemtype_val (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out nocopy varchar2,
p_display_value  in out nocopy varchar2,
p_result         out nocopy number);

--
-- wf_processname_val
--   Create the lov content for wf process name lov.  This function
--   is called by the generic lov function
-- IN
-- RETURNS
--
procedure wf_processname_val (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out nocopy varchar2,
p_display_value  in out nocopy varchar2,
p_result         out nocopy number,
p_param1         in varchar2 default null);

--
-- Validate_Event_Name
--   Find out if there is an unique match.  Return if all fine, otherwise
-- raise an error.
-- NOTE
--   p_name has precedence over p_guid in matching.
--
procedure validate_event_name (
p_name in varchar2,
p_guid in out nocopy raw);

--
-- Validate_System_Name
--   Find out if there is an unique match.  Return if all fine, otherwise
-- raise an error.
-- NOTE
--   p_name has precedence over p_guid in matching.
--
procedure validate_system_name (
p_name in varchar2,
p_guid in out nocopy raw);

--
-- Validate_Agent_Name
--   Find out if there is an unique match.  Return if all fine, otherwise
-- raise an error.
-- NOTE
--   p_name has precedence over p_guid in matching.
--
procedure validate_agent_name (
p_name in varchar2,
p_guid in out nocopy raw);

--
-- AddSelectedGEvents
--   Add selected events to group
-- IN
--   h_gguid - Global unique id for the group event
--   h_guids - Array of global unique id of events
-- NOTE
--
procedure AddSelectedGEvents(
  h_gguid in raw,
  h_guids in hguid_array);

--
-- DeleteSelectedGEvents
--   Delete selected events from group
-- IN
--   h_gguid - Global unique id for the group event
--   h_guids - Array of global unique id of events
-- NOTE
--
procedure DeleteSelectedGEvents(
  h_gguid in raw,
  h_guids in hguid_array);

-- EnterEventDetails
--   Enter Event Name, Event Key, Event Data to raise business event
-- IN
--   p_event_name - event name or part thereof
procedure EnterEventDetails(
 P_EVENT_NAME   in      varchar2 default '%'
);

-- RaiseEvent
--   Called from EnterEventDetails, calls wf_event.raise
-- IN
--   p_event_name - event name
--   p_event_key  - event key
--   p_event_data - event data
procedure RaiseEvent(
  P_EVENT_NAME  in      varchar2 default null,
  P_EVENT_KEY   in      varchar2 default null,
  P_EVENT_DATA  in      varchar2 default null
);

-- RaiseEventSuccess
--  Called from RaiseEvent to confirm submission
procedure RaiseEventConfirm(
  P_EVENT_NAME  in      varchar2 default null,
  P_EVENT_KEY   in      varchar2 default null
);

-- GetSystemIdentifier
--   Returns xml document which contains Local System and In Agent details
procedure GetSystemIdentifier;

-- Event Queue Display
--   Shows all event queues and message count that use WF_EVENT_QH queue
--   handler
procedure EventQueueDisplay;

-- FindQueueMessage
--   Filter Screen over Queue Messages
-- IN
--   Queue Name - used if called from EventQueueDisplay
procedure FindQueueMessage (
  P_QUEUE_NAME  in      varchar2 default null,
  P_TYPE  	in      varchar2 default null
);
-- FindECXMSGQueueMessage
--   Filter Screen over Queue Messages
-- IN
--   Queue Name - used if called from EventQueueDisplay
procedure FindECXMSGQueueMessage (
  P_QUEUE_NAME  in      varchar2 default null,
  P_TYPE  	in      varchar2 default null
);
-- FindECX_INENGOBJQueueMessage
--   Filter Screen over Queue Messages
-- IN
--   Queue Name - used if called from EventQueueDisplay
procedure FindECX_INENGOBJQueueMessage (
  P_QUEUE_NAME  in      varchar2 default null,
  P_TYPE        in      varchar2 default null
);


-- ListQueueMessages
--   Queue Messages after Filter applied
-- IN
--  Queue Name
--  Event Name
--  Event Key
--  Message Status
procedure ListQueueMessages (
  P_QUEUE_NAME  in      varchar2 default null,
  P_EVENT_NAME  in      varchar2 default null,
  P_EVENT_KEY   in      varchar2 default null,
  P_MESSAGE_STATUS in   varchar2 default 'ANY',
  P_MESSAGE_ID  in      varchar2 default null
);
-- EventDataContents
--   Shows clob contents in XML format
-- IN
--  Message ID
--  Queue Table
procedure EventDataContents (
  P_MESSAGE_ID  in      varchar2 default null,
  P_QUEUE_TABLE in      varchar2 default null,
  P_MIMETYPE    in      varchar2 default 'text/xml'
);
-- EventData
--   Called by the  Error Process, outputs EventData XML Clob
-- IN
--   EventAttribute - Event Item Attribute
--   itemtype  - item type
--   itemkey   - item key
--   mimetype  - mime type
procedure EventDataContents     (
  P_EVENTATTRIBUTE  in      varchar2,
  P_ITEMTYPE        in      varchar2,
  P_ITEMKEY         in      varchar2,
  P_MIME_TYPE       in      varchar2 default 'text/xml');


-- getFWKEvtSubscriptionUrl
--   This procudere takes the Event Subscription GUID as input and returns
--   the URL to the FWK Edit Subscritpion Page in the RF.jsp format.

PROCEDURE getFWKEvtSubscriptionUrl(guid in varchar2 default null,
			   l_lurl out nocopy varchar2);


-- updateToFWKEvtSubscriptionUrl
--   This procudere takes an old Event Subscription URL of the form
--   host:port/pls/<sid>/Wf_Event_Html.EditSubscription?<params> as
--   input and returns the URL to the FWK Edit Subscritpion Page in
--   the RF.jsp format.
--   Returns following error codes
--	   0 - Success
--	   1 - failure

PROCEDURE updateToFWKEvtSubscriptionUrl(oldUrl in varchar2,
                    newUrl out nocopy varchar2,
  		    errorCode out nocopy pls_integer);


-- updateToFWKEvtDataUrl
--   This procudere takes an old Event Data URL of the form
--   host:port/pls/<sid>/Wf_Event_Html.EventDataContents?<params> as
--   input and returns the URL to the FWK Event Data Page in
--   the RF.jsp format.
--   Returns following error codes
--	   0 - Success
--	   1 - failure

PROCEDURE updateToFWKEvtDataUrl(oldUrl in varchar2,
                    newUrl out nocopy varchar2,
  		    errorCode out nocopy pls_integer);


end WF_EVENT_HTML;

 

/
