--------------------------------------------------------
--  DDL for Package WF_ROUTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ROUTE" AUTHID CURRENT_USER AS
/* $Header: wfrtgs.pls 120.2 2006/04/06 09:29:13 rwunderl ship $ */

--
-- Types
--
-- Complex name#type identifiers from the web page
type name_array is table of varchar2(240) index by binary_integer;

-- Values from the web page.
type value_array is table of varchar2(4000) index by binary_integer;


--
-- DeleteRule
--   Delete rule with ruleid
-- IN
--   ruleid - Rule id
--
procedure DeleteRule(
  user in varchar2 default null,
  ruleid in varchar2);

-- SubmitUpdate
--   Process rule update page
-- IN
--   ruleid - Rule id
--   action - Rule action
--   action_argument - Forward to if forward
--   begin_date - Begin date
--   end_date - End date
--   rule_comment - Rule comment
--   h_fnames - array of attr field names
--   h_fvalues - array of attr field values
--   h_fdocnames - array of document name values
--   h_counter - number of fields passed in fnames and fvalues
--   update_button - Update button flag
--   delete_button - Delete button flag
--
procedure SubmitUpdate(
  rule_id in varchar2,
  action in varchar2,
  fmode  in varchar2 default null,
  action_argument in varchar2 default null,
  display_action_argument in varchar2 default null,
  begin_date in varchar2 default null,
  end_date in varchar2 default null,
  rule_comment in varchar2 default null,
  h_fnames in Name_Array,
  h_fvalues in Value_Array,
  h_fdocnames in Value_Array,
  h_counter in varchar2,
  delete_button in varchar2 default null,
  update_button in varchar2 default null);

--
-- UpdateRule
--   Update values for existing rule
-- IN
--   rule_id - Rule id number
--
procedure UpdateRule(
  ruleid in varchar2);

--
-- SubmitCreate
--   Process CreateRule request
-- IN
--   user - role owning rule
--   msg_type - message type
--   msg_name - message name
--   begin_date - Start date
--   end_date - End date
--   action - action
--   fmode  - forward mode: 'FORWARD', 'TRANSFER'
--   action_argument - reassign to if forward
--   h_fnames - Name array
--   h_fvalues - Value array
--   h_fdocnames - array of document name values
--   h_counter - count of array element
--   rule_comment - comments included in notification
--   delete_button - cancel operation flag
--   done_button - done button flag
--
procedure SubmitCreate(
  user in varchar2,
  msg_type in varchar2,
  msg_name in varchar2 default null,
  begin_date in varchar2 default null,
  end_date in varchar2 default null,
  action in varchar2,
  fmode  in varchar2 default null,
  action_argument in varchar2 default null,
  display_action_argument in varchar2 default null,
  h_fnames in Name_Array,
  h_fvalues in Value_Array,
  h_fdocnames in Value_Array,
  h_counter in varchar2,
  rule_comment in varchar2 default null,
  delete_button in varchar2 default null,
  done_button in varchar2 default null);

/*
--
-- CreateRule1
--   Create a new routing rule
-- IN
--   user - User to query rules for.  If null use current user.
--          Nore: only WF_ADMIN_ROLE can create rules for other users
--   create_button - create button flag
--
procedure CreateRule1(
  user in varchar2 default null,
  create_button in varchar2 default null);
*/

--
-- CreateRule2
--   Create a new routing rule
-- IN
--   user - User to query rules for.  If null use current user.
--          Nore: only WF_ADMIN_ROLE can create rules for other users
--   create_button - create button flag
--
procedure CreateRule2(
  user in varchar2 default null,
  msg_type in varchar2 default null,
  insert_button in varchar2 default null,
  cancel_button in varchar2 default null);

--
-- CreateRule3
--   Create a new routing rule
-- IN
--   user - User to query rules for.  If null use current user.
--          Nore: only WF_ADMIN_ROLE can create rules for other users
--   create_button - create button flag
--
procedure CreateRule3(
  user in varchar2 default null,
  msg_type in varchar2 default null,
  msg_name in varchar2 default null,
  insert_button in varchar2 default null,
  cancel_button in varchar2 default null);

--
-- CreateRule
--   Create a new routing rule
-- IN
--   user - User to query rules for.  If null use current user.
--          Nore: only WF_ADMIN_ROLE can create rules for other users
--   create_button - create button flag
--
procedure CreateRule(
  user in varchar2 default null,
  create_button in varchar2 default null);

/*
--
-- ListFrame
--   Produce Frame to display List
-- IN
--   user - User to query rules for.  If null use current user.
--          Note: only WF_ADMIN_ROLE can query other than the current user.
--
procedure ListFrame (
  user in varchar2 default null);
*/

--
-- List
--   Produce list of routing rules for user
-- IN
--   user - User to query rules for.  If null use current user.
--          Nore: only WF_ADMIN_ROLE can query other than the current user.
--
procedure List (
  user in varchar2 default null,
  display_user in varchar2 default null
);

/*
--
-- ListButton
--
procedure ListButton (
  user in varchar2 default null,
  username varchar2 default null);
*/

--
-- Find
--  Find routing rules for given user
--  Note: only WF_ADMIN_ROLE can query other than the current user.
--
procedure Find;

--
-- ChangeMessageName
--  Changes the message name on any defined rule(s).
--
procedure ChangeMessageName (p_itemType in varchar2,
                             p_oldMessageName in varchar2,
                             p_newMessageName in varchar2);


END WF_ROUTE;

 

/
