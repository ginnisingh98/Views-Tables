--------------------------------------------------------
--  DDL for Package FND_FUNCTION_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FUNCTION_SECURITY" AUTHID CURRENT_USER as
/* $Header: AFSCFUNS.pls 115.6 2003/12/04 19:10:41 pdeluna ship $ */


--
-- RESPONSIBILITY_EXISTS
--   Check if responsibility exists.
-- IN
--   responsibility_key (REQUIRED, KEY) - responsibility key
-- RETURNS
--   TRUE if responsibility exists
-- NOTES:
-- 1. The responsibility_id in the script must match the id in the tape
--    database.  To get the id, first create the responsibility in tape,
--    then query the id using either examine in the form or sqlplus.
--
function RESPONSIBILITY_EXISTS(
  responsibility_key in varchar2)
return boolean;

--
-- FORM_FUNCTION_EXISTS
--   Check if function exists.
-- IN
--   function_name (KEY, REQUIRED) - Function developer key name
-- RETURNS
--   TRUE if function exists
--
function FORM_FUNCTION_EXISTS(
  function_name in varchar2)
return boolean;

--
-- MENU_EXISTS
--   Check if menu exists.
-- IN
--   menu_name (KEY, REQUIRED) - Menu developer key name
-- RETURNS
--   TRUE if menu exists
--
function MENU_EXISTS(
  menu_name in varchar2)
return boolean;

--
-- MENU_ENTRY_EXISTS
--   Check if menu entry exists.
-- IN
--   menu_name (KEY, REQUIRED) - Menu developer key name
--   sub_menu_name (KEY) - Developer key name of submenu
--   function_name (KEY) - Developer key name of function
-- RETURNS
--   TRUE if menu entry exists
--
function MENU_ENTRY_EXISTS(
  menu_name in varchar2,
  sub_menu_name in varchar2,
  function_name in varchar2)
return boolean;

--
-- SECURITY_RULE_EXISTS
--   Check if security rule exists.
-- IN
--   responsibility_key (KEY, REQUIRED) - Key of responsibility owning rule
--   rule_type (KEY, REQUIRED) - Rule type
--     'F' = Function exclusion
--     'M' = Menu exclusion
--   rule_name (KEY, REQUIRED) - Rule name
--     Function developer key name (if rule_type = 'F')
--     Menu developer key name (if rule_type = 'M')
-- RETURNS
--   TRUE if security rule exists
--
function SECURITY_RULE_EXISTS(
  responsibility_key in varchar2,
  rule_type in varchar2 default 'F',  -- F = Function, M = Menu
  rule_name in varchar2)              -- Function_name or menu_name
return boolean;

--
-- RESPONSIBILITY
--   Insert/update/delete a GUI responsibility (not 2.3 responsibilities).
--
-- IN:
--   responsibility_id (REQUIRED, KEY) - Responsibility id (see note 1)
--   responsibility_key (REQUIRED, KEY) - Responsibility key
--   responsibility_name (REQUIRED) - Responsibility name
--   application_name (REQUIRED) - Application short name
--   description - Description
--   start_date (REQUIRED) - Effective Date From
--   end_date - Effective Date To
--   data_group_name (REQUIRED) - Data Group Name
--   data_group_application (REQUIRED) - Data group application short name
--   menu_name (REQUIRED) - Menu developer key name
--   request_group_name - Request group name
--   request_group_application - Request group application short name
--   version - '4' for Forms Resp, 'W' for Web Resp
--   web_host_name - Web Host Name (for Web Resp)
--   web_agent_name - Web Agent Name (for Web Resp)
--   delete_flag (REQUIRED) - Delete mode (see package comments)
--
-- CHILD REFERENCES: (Delete is cascaded to ...)
--   (none - see note 2)
-- FOREIGN REFERENCES: (Delete prevented if referenced in ...)
--   (none - see note 2)
--
-- NOTES:
-- 1. The responsibility_id in the script must match the id in the tape
--    database.  To get the id, first create the responsibility in tape,
--    then query the id using either examine in the form or sqlplus.
-- 2. Responsibilities are never deleted.  If this procedure is called
--    with delete_flag = 'Y' or 'F', the end_date will be set to sysdate
--    to effectively disable the responsibility.
--
procedure RESPONSIBILITY (
    responsibility_id in number,
    responsibility_key in varchar2,
    responsibility_name in varchar2,
    application in varchar2,
    description in varchar2 default '',
    start_date in date,
    end_date in date default '',
    data_group_name in varchar2,
    data_group_application in varchar2,
    menu_name in varchar2,
    request_group_name in varchar2 default '',
    request_group_application in varchar2 default '',
    version in varchar2 default '4',
    web_host_name in varchar2 default null,
    web_agent_name in varchar2 default null,
    delete_flag in varchar2 default 'N'
);

--
-- FORM_FUNCTION
--   Insert/update/delete a function.
--
-- IN:
--   function_name (KEY, REQUIRED) - Function developer key name
--   form_name - Name of form attached to function
--               (Use the actual form name, not the user name or title.)
--   parameters - Parameter string for the form
--   type - Type flag of the function
--   user_function_name (REQUIRED) - User name of function
--                                   (in current language)
--   description - Description of function
--   delete_flag (REQUIRED) - Delete mode (see package comments)
--
-- CHILD REFERENCES: (Delete is cascaded to ...)
--   Function Security Exclusion Rules
--
-- FOREIGN REFERENCES: (Delete prevented if referenced in ...)
--   GUI Menu Entry
--   Attachments
--   2.3 Menu Entry
--
procedure FORM_FUNCTION (
    function_name in varchar2,
    form_name in varchar2 default '',
    parameters in varchar2 default '',
    type in varchar2 default '',
    user_function_name in varchar2 default '',
    description in varchar2 default '',
    delete_flag in varchar2 default 'N');

--
-- MENU
--   Insert/update/delete a menu.
--
-- IN:
--   menu_name (KEY, REQUIRED) - Menu developer key
--   user_menu_name (REQUIRED) - Menu user name (in current language)
--   description - Menu description (in current language)
--   delete_flag (REQUIRED) - Delete mode (see package comments)
--
-- CHILD REFERENCES: (Delete is cascaded to ...)
--   Menu Entry (entries of this menu)
--   Function Security Exclusion Rules
--
-- FOREIGN REFERENCES: (Delete prevented if referenced in ...)
--   Menu Entry (as a submenu of another menu) (see note)
--   Responsibility (as the main menu of a responsibility)
--
-- NOTE:
--   To delete an entire menu tree, delete the top level menu of the tree
-- first, then work down to the leaves one level at a time to avoid
-- invalidating foreign references along the way.
--
procedure MENU(
    menu_name in varchar2,
    user_menu_name in varchar2 default '',
    description in varchar2 default '',
    delete_flag in varchar2 default 'N');

--
-- MENU_ENTRY
--   Insert/update/delete an individual menu entry.
--
-- IN:
--   menu_name (KEY, REQUIRED) - Menu developer key
--   entry_sequence - Sequence number (see note below)
--   prompt - Entry prompt (in current language)
--   sub_menu_name (KEY) - Developer key name of submenu
--   function_name (KEY) - Developer key name of function
--   description - Entry description (in current language)
--   delete_flag (REQUIRED) - Delete mode (see package comments)
--
-- CHILD REFERENCES: (Delete is cascaded to ...)
--   (none)
-- FOREIGN REFERENCES: (Delete prevented if referenced in ...)
--   (none)
--
-- NOTE:
--   Menu entries are identified by the triple of menu_name, sub_menu_name,
-- and function_name, not by entry_sequence.  The entry_sequence argument is
-- used only when inserting a new entry.
--
procedure MENU_ENTRY (
    menu_name in varchar2,
    entry_sequence in number,
    prompt in varchar2 default '',
    sub_menu_name in varchar2 default '',
    function_name in varchar2 default '',
    description in varchar2 default '',
    delete_flag in varchar2 default 'N');

--
-- SECURITY_RULE
--   Insert/update/delete a function security exclusion rule.
--
-- IN:
--   responsibility_key (KEY, REQUIRED) - Key of responsibility owning rule
--   rule_type (KEY, REQUIRED) - Rule type
--     'F' = Function exclusion
--     'M' = Menu exclusion
--   rule_name (KEY, REQUIRED) - Rule name
--     Function developer key name (if rule_type = 'F')
--     Menu developer key name (if rule_type = 'M')
--   delete_flag (REQUIRED) - Delete mode (see package comments)
--
-- CHILD REFERENCES: (Delete is cascaded to ...)
--   (none)
-- FOREIGN REFERENCES: (Delete prevented if referenced in ...)
--   (none)
--
procedure SECURITY_RULE (
    responsibility_key in varchar2,
    rule_type in varchar2 default 'F',
    rule_name in varchar2,
    delete_flag in varchar2 default 'N');

--
-- UPDATE_FUNCTION_NAME
--   This procedure updates the developer key of an existing function.
-- The function with name oldname is located, and the name updated to newname.
-- If a function already exists with name newname, it is deleted in favor of
-- the updated row with oldname.
--
-- IN:
--   oldname (REQUIRED) - old function developer name
--   newname (REQUIRED) - new function developer name
--
-- NOTES:
--   The user is responsible for making sure all references to the
-- function in forms, code, etc, are updated to the new name.
--   Under normal circumstances developer keys should never be changed.  This
-- procedure should only be used for new functions not in general use, or to
-- fix bugs caused by inconsistent data created in previous patches.
--
procedure UPDATE_FUNCTION_NAME(
    oldname in varchar2,
    newname in varchar2);

--
-- UPDATE_MENU_NAME
--   This procedure updates the developer key of an existing menu.
-- The menu with name oldname is located, and the name updated to newname.
-- If a menu already exists with name newname, it is deleted in favor of
-- the updated row with oldname.
--
-- IN:
--   oldname (REQUIRED) - old menu developer name
--   newname (REQUIRED) - new menu developer name
--
-- NOTES:
--   The user is responsible for making sure all references to the
-- menu in forms, code, etc, are updated to the new name.
--   Under normal circumstances developer keys should never be changed.  This
-- procedure should only be used for new menus not in general use, or to
-- fix bugs caused by inconsistent data created in previous patches.
--
procedure UPDATE_MENU_NAME(
    oldname in varchar2,
    newname in varchar2);

end FND_FUNCTION_SECURITY;

 

/
