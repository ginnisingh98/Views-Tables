--------------------------------------------------------
--  DDL for Package APP_SESSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."APP_SESSION" AUTHID CURRENT_USER as
/* $Header: AFSCSESS.pls 120.2 2005/10/11 18:38:09 sdstratt noship $ */

--
-- Exceptions
--
SSO_USER_UNKNOWN         exception;
SESSION_CREATION_FAILED  exception;
SESSION_DOES_NOT_EXIST   exception;
SESSION_NOT_VALID        exception;
SESSION_EXPIRED          exception;
SECURITY_CONTEXT_INVALID exception;

--
-- Types
--
type Apps_User_Type is record (
  user_id        fnd_user.user_id%type,    -- Apps User ID
  user_name      fnd_user.user_name%type,  -- Apps User Name
  default_user   varchar2(1)               -- Y/N default user for GUID
);

type Apps_User_Table is table of Apps_User_Type
    index by binary_integer;

--
-- Initialize
--   Initialize session in apps schema
--
procedure Initialize;

--
-- Get_Icx_Cookie_Name
--   Get the name of the cookie containing the icx_session_id
-- RETURNS
--   Cookie Name
--
function Get_Icx_Cookie_Name return varchar2;

--
-- Create_Icx_Session
--   Create or re-establish an ICX session for the identified user.
-- IN
--   p_sso_guid - the user's SSO guid (required)
--   p_old_icx_cookie_value - the user's previous cookie value, if
--     trying to re-establish an existing session (optional)
--   p_resp_appl_short_name - the application short name of the responsibility
--   p_responsibility_key - the responsibility key
--   p_security_group_key - the security group key
-- OUT
--   p_icx_cookie_value - the new ICX session cookie value
-- RAISES
--   SSO_USER_UNKNOWN - if there is no user corresponding to the SSO guid
--   SESSION_CREATION_FAILED - if a session could not be created
--   SECURITY_CONTEXT_INVALID - if the user, responsibility application
--     short name, responsibility, and security group do not form a valid
--     security context
--
procedure Create_Icx_Session(
  p_sso_guid             in         varchar2,
  p_old_icx_cookie_value in         varchar2 default null,
  p_resp_appl_short_name in         varchar2 default null,
  p_responsibility_key   in         varchar2 default null,
  p_security_group_key   in         varchar2 default null,
  p_icx_cookie_value     out nocopy varchar2);

--
-- Validate_Icx_Session
--   Validates an ICX session.
-- IN
--   p_icx_cookie_value - the ICX session cookie value
-- RETURNS
--  Nothing.  No exception means session is valid.
-- RAISES
--   SESSION_DOES_NOT_EXIST
--   SESSION_NOT_VALID
--   SESSION_EXPIRED
--
procedure Validate_Icx_Session(
  p_icx_cookie_value in varchar2);

--
-- Get_All_Linked_Users
--   Return a list of all FND users linked to an SSO guid
-- IN
--   p_sso_guid - the user's SSO guid (required)
-- RETURNS
--   An array of users linked to this guid
-- RAISES
--   SSO_USER_UNKNOWN - if no users are linked to this GUID
--
function Get_All_Linked_Users(
  p_sso_guid in varchar2)
return Apps_User_Table;

--
-- Get_Default_User
--   Get the default FND user linked to an SSO guid
-- IN
--   p_sso_guid - the user's SSO guid (required)
-- RETURNS
--   A record for default user linked to this guid
-- RAISES
--   SSO_USER_UNKNOWN - if no users are linked to this GUID
--
function Get_Default_User(
  p_sso_guid in varchar2)
return Apps_User_Type;

end APP_SESSION;

 

/
