--------------------------------------------------------
--  DDL for Package WF_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_LOAD" AUTHID CURRENT_USER as
/* $Header: wfldrs.pls 120.4 2006/02/22 16:43:36 rwunderl ship $ */

-- Variables
logbuf  varchar2(32000) := '';  -- special log messages that got past back

--
-- UPLOAD_ITEM_TYPE
--
procedure UPLOAD_ITEM_TYPE (
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_wf_selector in varchar2,
  x_read_role in varchar2,
  x_write_role in varchar2,
  x_execute_role in varchar2,
  x_persistence_type in varchar2,
  x_persistence_days in varchar2,
  x_level_error out NOCOPY number
);

--
-- UPLOAD_ITEM_ATTRIBUTE
--
procedure UPLOAD_ITEM_ATTRIBUTE (
  x_item_type in varchar2,
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_sequence in number,
  x_type in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_subtype in varchar2,
  x_format in varchar2,
  x_default in varchar2,
  x_level_error out NOCOPY number
);

--
-- UPLOAD_LOOKUP_TYPE
--
procedure UPLOAD_LOOKUP_TYPE (
  x_lookup_type in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_item_type in varchar2,
  x_level_error out NOCOPY number
);

--
-- UPLOAD_LOOKUP
--
procedure UPLOAD_LOOKUP (
  x_lookup_type in varchar2,
  x_lookup_code in varchar2,
  x_meaning in varchar2,
  x_description in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_level_error out NOCOPY number
);

--
-- UPLOAD_MESSAGE
--
procedure UPLOAD_MESSAGE (
  x_type in varchar2,
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_subject in varchar2,
  x_body in varchar2,
  x_html_body in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_default_priority in number,
  x_read_role in varchar2,
  x_write_role in varchar2,
  x_level_error out NOCOPY number
);

--
-- UPLOAD_MESSAGE_ATTRIBUTE
--
procedure UPLOAD_MESSAGE_ATTRIBUTE (
  x_message_type in varchar2,
  x_message_name in varchar2,
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_sequence in number,
  x_type in varchar2,
  x_subtype in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_format in varchar2,
  x_default in varchar2,
  x_value_type in varchar2,
  x_attach  in varchar2,
  x_level_error out NOCOPY number
);

--
-- UPLOAD_ACTIVITY
--
procedure UPLOAD_ACTIVITY (
  x_item_type in varchar2,
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_type in varchar2,
  x_rerun in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_effective_date in date,
  x_function in varchar2,
  x_function_type in varchar2,
  x_result_type in varchar2,
  x_cost in number,
  x_read_role in varchar2,
  x_write_role in varchar2,
  x_execute_role in varchar2,
  x_icon_name in varchar2,
  x_message in varchar2,
  x_error_process in varchar2,
  x_expand_role in varchar2,
  x_error_item_type in varchar2,
  x_runnable_flag in varchar2,
  x_event_filter in varchar2 default null,
  x_event_type in varchar2 default null,
  x_log_message out NOCOPY varchar2,
  x_version out NOCOPY number,
  x_level_error out NOCOPY number
);

--
-- provide the old 2.5 version of signature for forward compatibility
-- this is used by other product teams
--
procedure UPLOAD_ACTIVITY (
  x_item_type in varchar2,
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_type in varchar2,
  x_rerun in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_effective_date in date,
  x_function in varchar2,
  x_function_type in varchar2,
  x_result_type in varchar2,
  x_cost in number,
  x_read_role in varchar2,
  x_write_role in varchar2,
  x_execute_role in varchar2,
  x_icon_name in varchar2,
  x_message in varchar2,
  x_error_process in varchar2,
  x_expand_role in varchar2,
  x_error_item_type in varchar2,
  x_runnable_flag in varchar2,
  x_version out NOCOPY number,
  x_level_error out NOCOPY number
);

--
-- UPLOAD_ACTIVITY_ATTRIBUTE
--
procedure UPLOAD_ACTIVITY_ATTRIBUTE (
  x_activity_item_type in varchar2,
  x_activity_name in varchar2,
  x_activity_version in number,
  x_name in varchar2,
  x_display_name in varchar2,
  x_description in varchar2,
  x_sequence in number,
  x_type in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_subtype in varchar2,
  x_format in varchar2,
  x_default in varchar2,
  x_value_type in varchar2,
  x_level_error out NOCOPY number
);

--
-- UPLOAD_PROCESS_ACTIVITY
--
procedure UPLOAD_PROCESS_ACTIVITY (
  x_process_item_type in varchar2,
  x_process_name in varchar2,
  x_process_version in number,
  x_activity_item_type in varchar2,
  x_activity_name in varchar2,
  x_instance_id in out NOCOPY number,
  x_instance_label in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_start_end in varchar2,
  x_default_result in varchar2,
  x_icon_geometry in varchar2,
  x_perform_role in varchar2,
  x_perform_role_type in varchar2,
  x_user_comment in varchar2,
  x_level_error out NOCOPY number
);

--
-- UPLOAD_ACTIVITY_ATTR_VALUE
--
procedure UPLOAD_ACTIVITY_ATTR_VALUE (
  x_process_activity_id in number,
  x_name in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_value in varchar2,
  x_value_type in varchar2,
  x_effective_date in date,
  x_level_error out NOCOPY number
);

--
-- UPLOAD_ACTIVITY_TRANSITION
--
procedure UPLOAD_ACTIVITY_TRANSITION (
  x_from_process_activity in number,
  x_result_code in varchar2,
  x_to_process_activity in number,
  x_protect_level in number,
  x_custom_level in number,
  x_arrow_geometry in varchar2,
  x_level_error out NOCOPY number
);

--
-- UPLOAD_RESOURCE
--
procedure UPLOAD_RESOURCE (
  x_type in varchar2,
  x_name in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_id in number,
  x_text in varchar2,
  x_level_error out NOCOPY number
);

--
-- DELETE_LOOKUP_TYPE
--
procedure DELETE_LOOKUP_TYPE(
  x_lookup_type in varchar2,
  x_level_error out NOCOPY number
);

--
-- DELETE_LOOKUP
--
procedure DELETE_LOOKUP(
  x_lookup_type in varchar2,
  x_lookup_code in varchar2,
  x_level_error out NOCOPY number
);

--
-- DELETE_LOOKUPS
--
procedure DELETE_LOOKUPS(
  x_lookup_type in varchar2,
  x_level_error out NOCOPY number
);

--
-- DELETE_ITEM_TYPE
--
procedure DELETE_ITEM_TYPE(
  x_name in varchar2,
  x_level_error out NOCOPY number
);

--
-- DELETE_ITEM_ATTRIBUTE
--
procedure DELETE_ITEM_ATTRIBUTE(
  x_item_type in varchar2,
  x_name in varchar2,
  x_level_error out NOCOPY number
);

--
-- DELETE_ITEM_ATTRIBUTES
--
procedure DELETE_ITEM_ATTRIBUTES(
  x_item_type in varchar2,
  x_level_error out NOCOPY number
);

--
-- DELETE_MESSAGE
--
procedure DELETE_MESSAGE(
  x_type in varchar2,
  x_name in varchar2,
  x_level_error out NOCOPY number
);

--
-- DELETE_MESSAGE_ATTRIBUTE
--
procedure DELETE_MESSAGE_ATTRIBUTE(
  x_message_type in varchar2,
  x_message_name in varchar2,
  x_name in varchar2,
  x_level_error out NOCOPY number
);

--
-- DELETE_MESSAGE_ATTRIBUTES
--
procedure DELETE_MESSAGE_ATTRIBUTES(
  x_message_type in varchar2,
  x_message_name in varchar2,
  x_level_error out NOCOPY number
);

--
-- DELETE_ACTIVITY
--
procedure DELETE_ACTIVITY(
  x_item_type in varchar2,
  x_name in varchar2,
  x_level_error out NOCOPY number
);


--
-- WebDB Integration
--

--
-- Delete_Transition
-- IN
--   p_previous_step - instance id of the FROM process activity
--   p_next_step     - instance id of the TO process activity
--   P_result_code   - result code of this transition
-- NOTE
--   It is possible to leave an invalid Workflow definition after this
-- call.
--   Ignores the criteria with a null arguement.
--   p_previous_step and p_next_step cannot be both null.
procedure Delete_Transition(
  p_previous_step in number default null,
  p_next_step     in number default null,
  p_result_code   in varchar2 default null);

--
-- Get_Process_Activity
-- IN
--   p_activity_instance - instance id of a process activity
-- OUT
--   p_xcor          - X coordinate of the icon geometry
--   p_ycor          - Y coordinate of the icon geometry
--   p_activity_name - internal name of this process activity
-- NOTE
--
procedure Get_Process_Activity(
  p_activity_instance in  number,
  p_xcor              out NOCOPY number,
  p_ycor              out NOCOPY number,
  p_activity_name     out NOCOPY varchar2,
  p_instance_label    out NOCOPY varchar2);

--
-- Update_Message
-- IN
--   p_type  - item type of message
--   p_name  - message name
--   p_subject  - message subject
--   p_body  - text body
--   p_html_body  - html formated body
-- OUT
--   x_level_error - the output of error level
-- NOTE
--   It first selects the values related to the message
--   and then calls UPLOAD_MESSAGE to update the value.
--
procedure UPDATE_MESSAGE (
  p_type in varchar2,
  p_name in varchar2,
  p_subject in varchar2,
  p_body in varchar2,
  p_html_body in varchar2,
  p_level_error out NOCOPY number
);


--
-- Get_MESSAGE
-- IN
--   p_type  - message item type
--   p_name  - message name
-- OUT
--   p_protect_level -
--   p_custom_level  -
--   p_default_priority -
--   p_display_name  - 80
--   p_description   - 240
--   p_subject       - 240
--   p_body          - 4000
--   p_html_body     - 4000
--
procedure GET_MESSAGE (
  p_type             in  varchar2,
  p_name             in  varchar2,
  p_protect_level    out NOCOPY number,
  p_custom_level     out NOCOPY number,
  p_default_priority out NOCOPY number,
  p_display_name     out NOCOPY varchar2,
  p_description      out NOCOPY varchar2,
  p_subject          out NOCOPY varchar2,
  p_body             out NOCOPY varchar2,
  p_html_body        out NOCOPY varchar2
);

--
-- COPY_ITEM_TYPE
-- IN
--   p_item_type            - item type to copy from.
--   p_destination_item_type- new item type.
--   p_new_suffix           - suffix to use append to internal names
--                            of new entities.
-- NOTE
--
procedure COPY_ITEM_TYPE(
  p_item_type             in  varchar2,
  p_destination_item_type in  varchar2,
  p_new_suffix            in  varchar2);

-- Delete_Process_Activity
-- IN
--   p_item_type - item type of this process activity (used in making
--                 sure the process activity has not been run).
--                 No need to have this.
--   p_step - instance id of the process activity
-- NOTE
--   It is possible to leave an invalid Workflow definition after this
-- call.
--   Make sure it does not exist in wf_item_activity_statuses, ie. has
-- not been run.
--   It needs to make sure all transitions are cleaned up first.
--   It also needs to clean up all activity attribute values.
procedure Delete_Process_Activity(
  p_step in number);

--
-- Get_Activity_Attr_Val
-- IN
--   p_process_instance_id  - instance id of the process activity
--   p_attribute_name       - name of the attribute
-- OUT
--   p_attribute_value_type - value type like 'CONSTANT' or 'ITEMATTR'
--   p_attribute_value      - value of the attribute
--
procedure GET_ACTIVITY_ATTR_VAL(
  p_process_instance_id  in  number,
  p_attribute_name       in  varchar2,
  p_attribute_value_type out NOCOPY varchar2,
  p_attribute_value      out NOCOPY varchar2);

--
-- Get_Item_Attribute
-- IN
--   p_item_type            - item type
--   p_attribute_name       - name of the attribute
-- OUT
--   p_attribute_type       - type like 'NUMBER', 'TEXT' and so on
--   p_attribute_value      - value of the attribute
--
procedure GET_ITEM_ATTRIBUTE(
  p_item_type            in  varchar2,
  p_attribute_name       in  varchar2,
  p_attribute_type       out NOCOPY varchar2,
  p_attribute_value      out NOCOPY varchar2);

--
-- Get_Activity
-- IN
--   p_item_type -
--   p_name -
-- OUT
--   p_display_name -
--   p_description -
--   p_type -
--   p_rerun -
--   p_protect_level -
--   p_custom_level -
--   p_begin_date -
--   p_function -
--   p_function_type -
--   p_result_type -
--   p_cost      -
--   p_read_role -
--   p_write_role -
--   p_excute_role -
--   p_icon_name -
--   p_message -
--   p_error_process -
--   p_expand_role -
--   p_error_item_type -
--   p_runnable_flag -
--   p_version -
procedure GET_ACTIVITY (
  p_item_type     in     varchar2,
  p_name          in     varchar2,
  p_display_name  out    NOCOPY varchar2,
  p_description   out    NOCOPY varchar2,
  p_type          out    NOCOPY varchar2,
  p_rerun         out    NOCOPY varchar2,
  p_protect_level out    NOCOPY number,
  p_custom_level  out    NOCOPY number,
  p_begin_date    out    NOCOPY date,
  p_function      out    NOCOPY varchar2,
  p_function_type out    NOCOPY varchar2,
  p_result_type   out    NOCOPY varchar2,
  p_cost          out    NOCOPY number,
  p_read_role     out    NOCOPY varchar2,
  p_write_role    out    NOCOPY varchar2,
  p_execute_role  out    NOCOPY varchar2,
  p_icon_name     out    NOCOPY varchar2,
  p_message       out    NOCOPY varchar2,
  p_error_process out    NOCOPY varchar2,
  p_expand_role   out    NOCOPY varchar2,
  p_error_item_type out  NOCOPY varchar2,
  p_runnable_flag out    NOCOPY varchar2,
  p_version       out    NOCOPY number
);

--
-- Update_Activity
-- IN
--   p_item_type  - item type of the activity
--   p_name  - activity name
--   p_display_name - activity display name
--   p_description  - activity description
--   p_expand_role  - flag to indicate expand role or not
-- OUT
--   p_level_error - the output of error level
-- NOTE
--   It first selects the values related to the activity
--   and then calls UPLOAD_ACTIVITY to update the value.
--
procedure UPDATE_ACTIVITY (
  p_item_type in varchar2,
  p_name in varchar2,
  p_display_name in varchar2 default null,
  p_description in varchar2 default null,
  p_expand_role in varchar2 default null,
  p_level_error out NOCOPY number);

--
-- Get_Activity_Instance
--   Return the instance id for an activity based on its label of a
-- given process and activity
-- IN
--   p_process_item_type  -
--   p_process_name       -
--   p_process_version    -
--   p_activity_item_type -
--   p_activity_name      -
--   p_instance_label     -
function Get_Activity_Instance(
    p_process_item_type          in varchar2,
    p_process_name               in varchar2,
    p_process_version            in number default 1,
    p_activity_item_type         in varchar2 default null,
    p_activity_name              in varchar2 default null,
    p_instance_label             in varchar2 default null)
  return number;

/* ### Get_Process_Activity include this function
--
-- GetActNameFromInstId
-- IN
--   p_instance_id - instance id of an activity
-- RET
--   Name of the activity in varchar2
--
function GetActNameFromInstId (
  p_instance_id    in  number)
return varchar2;
*/

type t_instanceidTab is table of number index by binary_integer;
type t_nameTab is table of varchar2(30) index by binary_integer;
type t_resultcodeTab is table of varchar2(30) index by binary_integer;

--
-- Get_Activity_Transition
-- IN
--   p_from_activity    -
--   p_to_activity      -
--   p_result_code      -
-- OUT
--   p_result_codes     - table of all matched result codes
--   p_activities       - table of all matched activity instance ids
-- NOTE
--   Depend on what the parameter given return the appropriate result
--   p_from_activity + p_to_activity => p_result_codes
--   p_from_activity + p_result_code => p_activities (of to activity)
--   p_to_activity   + p_result_code => p_activities (of from activity)
--   p_from_activity => p_result_codes + p_activities (of to activity)
--   p_to_activity   => p_result_codes + p_activities (of from activity)
procedure Get_Activity_Transition (
    p_from_activity  in     number   default null,
    p_to_activity    in     number   default null,
    p_result_code    in     varchar2 default null,
    p_activities     out    NOCOPY t_instanceidTab,
    p_result_codes   out    NOCOPY t_resultcodeTab);

--
-- Get_Item_Attribute_Names
--   select all the item attributes that match the specified suffix
-- IN
--   p_item_type - item type of the item attributes
--   p_suffix    - suffix that the internal names of item attributes endded in
-- OUT
--   p_names     - table of internal names that returned
--
procedure Get_Item_Attribute_Names(
  p_item_type    in  varchar2,
  p_suffix       in  varchar2,
  p_names        out NOCOPY t_nameTab
);

--
-- Get_Notif_Activity_Names
--   select all the notification activities that match the specified suffix
-- IN
--   p_item_type - item type of the activities
--   p_suffix    - suffix that the internal names of activities endded in
-- OUT
--   p_names     - table of internal names that returned
--
procedure Get_Notif_Activity_Names(
  p_item_type    in  varchar2,
  p_suffix       in  varchar2,
  p_names        out NOCOPY t_nameTab
);

-- Get_Message_Names
--   select all the messages that match the specified suffix
-- IN
--   p_item_type - item type of the messages
--   p_suffix    - suffix that the internal names of messages endded in
-- OUT
--   p_names     - table of internal names that returned
--
procedure Get_Message_Names(
  p_item_type    in  varchar2,
  p_suffix       in  varchar2,
  p_names        out NOCOPY t_nameTab
);

-- Get_Process_Activity_Instances
--   select all the process activities of activity of type process
-- IN
--   p_process_item_type - item type of the process which includes these
--                         activities.
--   p_process_name      - process name
--   p_process_version   - process version which defaults to 1
-- OUT
--   p_instance_ids      - table of instance ids that returned
--
procedure Get_Process_Activity_Instances(
  p_process_item_type  in  varchar2,
  p_process_name       in  varchar2,
  p_process_version    in  number default 1,
  p_instance_ids       out NOCOPY t_instanceidTab
);

--
-- GET_LOOKUP
--   Get the Lookup definition
-- IN
--   x_lookup_type   - item type of lookup
--   x_lookup_code   - internal name of lookup code
-- OUT
--   x_meaning       - display name of lookup code
--   x_description   - description of lookup code
--   x_protect_level -
--   x_custom_level  -
--
procedure Get_Lookup(
  x_lookup_type       in varchar2,
  x_lookup_code       in varchar2,
  x_meaning           out NOCOPY varchar2,
  x_description       out NOCOPY varchar2,
  x_protect_level     out NOCOPY number,
  x_custom_level      out NOCOPY number
);

--
-- UPDATE_LOOKUP
--   Update the provided fields for Lookup
-- IN
--   x_lookup_type   - item type of lookup
--   x_lookup_code   - internal name of lookup code
--   x_meaning       - display name of lookup code
--   x_description   - description of lookup code
--   x_protect_level -
--   x_custom_level  -
-- OUT
--   x_level_error   - level of error returned from UPLOAD_LOOKUP
-- NOTE
--   Calls GET_LOOKUP to get the default value before calling
-- UPLOAD_LOOKUP.
--
procedure UPDATE_LOOKUP(
  x_lookup_type       in varchar2,
  x_lookup_code       in varchar2,
  x_meaning           in varchar2 default null,
  x_description       in varchar2 default null,
  x_protect_level     in number default null,
  x_custom_level      in number default null,
  x_level_error       out NOCOPY number
);

--
-- GET_LOOKUP_Codes
--   Get lookup codes for a lookup type
-- IN
--   p_lookup_type   - item type of lookup
-- OUT
--   p_lookup_codes  - table of lookup codes
--
procedure Get_Lookup_Codes(
p_lookup_type in varchar2,
p_lookup_codes out NOCOPY t_resultcodeTab);


--
-- Activity_Exist_In_Process (Deprecated, use WF_ENGINE.Activity_Exist instead)
--   Check if an activity exist in a process
-- IN
--   p_process_item_type
--   p_process_name
--   p_activity_item_type
--   p_anctivity_name
--   active_date
--   iteration  - maximum 8 level deep (0-7)
-- RET
--   TRUE if activity exist, FALSE otherwise
--
function Activity_Exist_In_Process (
  p_process_item_type  in  varchar2,
  p_process_name       in  varchar2,
  p_activity_item_type in  varchar2 default null,
  p_activity_name      in  varchar2,
  active_date          in  date default sysdate,
  iteration            in  number default 0)
return boolean;

--
-- BeginTransaction
-- (PRIVATE)
--  Calls WF_CACHE.BeginTransaction() to control the calls to WF_CACHE.Reset()
--  so there is not unnecessary locking or update to WFCACHE_META_UPD.
--  Calling this api mandates that EndTransaction is called BEFORE control is
--  returned.
   PROCEDURE BeginTransaction;

--
-- EndTransaction
-- (PRIVATE)
-- Calls WF_CACHE.EndTransaction() to signal the end of the transaction and to
-- call WF_CACHE.Reset() which will update WFCACHE_META_UPD.
-- WARNING: THIS API WILL ISSUE A COMMIT!
   PROCEDURE EndTransaction;


end WF_LOAD;

 

/
