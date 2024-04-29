--------------------------------------------------------
--  DDL for Package FND_USER_RESP_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_USER_RESP_GROUPS_API" AUTHID CURRENT_USER as
/* $Header: AFSCURGS.pls 120.6 2006/02/27 12:48:13 tmorrow ship $ */
/*#
* Table Handler to insert or update data in FND_USER_RESP_GROUPS table.
* @rep:scope public
* @rep:product FND
* @rep:displayname User Responsibility Group
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_USER
*/

--
-- Assignment_Exists
--   Check if user/resp/group assignment exists.  This API does not check
--   start or end dates on the user, repsonsibility, or responsibility
--   assignment.
-- IN
--   user_id - User to get assignment
--   responsibility_id - Responsibility to be assigned
--   responsibility_application_id - Resp Application to be assigned
--   security_group_id - Security Group to be assigned (default to current)
--   direct_flag- 'Y', 'N', or 'E' (default) determines whether this checks
--                indirect assignments from wf_role_hierarchy or just
--                direct assignments.
--     'Y'= Direct only.     Dates can be updated.
--     'N'= Indirect only.   Dates cannot be updated on these assignments.
--     'E'= Either Direct or Indirect. (this is the default)
-- RETURNS
--   TRUE if assignment is found
--
function Assignment_Exists(
  user_id in number,
  responsibility_id in number,
  responsibility_application_id in number,
  security_group_id in number default null,
  direct_flag in varchar2 default null /* null means 'E': Direct or Indirect*/
  )
return boolean;

--
-- Validates the security context to determine if the given user has access
-- to the given responsibility.  This API checks start and end dates on
-- the user, responsibility, and responsibility assignment.
-- IN
--   p_user_id - the user id
--   p_resp_appl_id - the application id of the responsibility
--   p_responsibility_id - the responsibility id
--   p_security_group_id - the security group id
-- OU
--  x_status:
--    'N' if the security context is not valid
--    'Y' if the security context is valid
--
procedure validate_security_context(
  p_user_id            in  number,
  p_resp_appl_id       in  number,
  p_responsibility_id  in  number,
  p_security_group_id  in  number,
  x_status             out nocopy varchar2);


--
-- Assignment_Check (INTERNAL routine only)
--
-- Check whether a particular assignment of a user to a role exists,
-- regardless of start/end date.  This is different from
-- wf_directory.IsPerformer which only operates for current sysdate.
-- In: username- user name
-- In: rolename- role name
--
function Assignment_Check(username in varchar2,
                          rolename in varchar2,
                       direct_flag in varchar2 /* 'D', 'I', or 'E'*/)
return boolean;

--
-- Role_Name_from_Resp
--
-- Returns role name in the format FND_RESP|APPSNAME|RESPKEY|SECGRPKEY
-- from the security group and resp passed in.  This is generally only used
-- by FND internal code upgrading old data.
--
function Role_Name_from_Resp(
  x_resp_id in number,
  x_resp_appl_id in number,
  x_secgrp_id in number) return varchar2;

--
-- Role_Name_from_Resp_No_Exc
--
-- This is a version of role_name_from_resp which won't raise exceptions,
-- to be used when calling from somewhere that errors can't be trapped
-- like inline inside a SQL select statement.  Again only used by internal
-- FND code.
function Role_Name_from_Resp_No_Exc(
  x_resp_id in number,
  x_resp_appl_id in number,
  x_secgrp_id in number) return varchar2;

--
-- Lock_Assignment
--   Lock the row for an assignment (used by a UI)
-- IN
--   user_id - User
--   responsibility_id - Responsibility
--   responsibility_application_id - Resp Application
--   security_group_id - Security Group
--   start_date - Start date of assignment
--   end_date - End date of assignment
-- EXCEPTION
--
--
procedure Lock_Assignment(
  x_user_id in number,
  x_responsibility_id in number,
  x_resp_application_id in number,
  x_security_group_id in number,
  x_start_date in date,
  x_end_date in date,
  x_description in varchar2);

--
-- Insert_Assignment
--   Insert a new user/resp/group assignment
-- IN
--   user_id - User to get assignment
--   responsibility_id - Responsibility to be assigned
--   responsibility_application_id - Resp Application to be assigned
--   security_group_id - Security Group to be assigned
--   start_date - Start date of assignment
--   end_date - End date of assignment
--   description - Optional comment
-- EXCEPTION
--   If user/resp/group assignment already exists
--
procedure Insert_Assignment(
  user_id in number,
  responsibility_id in number,
  responsibility_application_id in number,
  security_group_id in number default null,
  start_date in date,
  end_date in date,
  description in varchar2);

--
-- Update_Assignment
--   Update an existing user/resp/group assignment
-- IN
-- KEY VALUES:  These columns identify row to update
--   user_id - User to get assignment
--   responsibility_id - Responsibility to be assigned
--   responsibility_application_id - Resp Application to be assigned
--   security_group_id - Security Group to be assigned (default to current)
-- UPDATE VALUES: These columns identify values to update
--   start_date - Start date of assignment
--   end_date - End date of assignment
--   description - Optional comment
-- FLAGS
--   update_who_columns- pass 'Y' or 'N' ('Y' is default if not passed)
--     'N' = leave old who vals.  'Y'= update who cols to current user/date
-- EXCEPTION
--   If user/resp/group assignment does not exist
--
procedure Update_Assignment(
  user_id in number,
  responsibility_id in number,
  responsibility_application_id in number,
  security_group_id in number default null,
  start_date in date,
  end_date in date,
  description in varchar2,
  update_who_columns in varchar2 default null
     /* 'N' = leave old who vals.  'Y' (default) = update who to current*/);

--
-- Upload_Assignment
--   Update user/resp/group assignment if it exists,
--   otherwise insert new assignment.
-- IN
--   user_id - User to get assignment
--   responsibility_id - Responsibility to be assigned
--   responsibility_application_id - Resp Application to be assigned
--   security_group_id - Security Group to be assigned (default to current)
--   start_date - Start date of assignment
--   end_date - End date of assignment
--   description - Optional comment
--   update_who_columns in varchar2 default null
--    'N' = leave old who vals.  'Y' (default) = update who to current
--
procedure Upload_Assignment(
  user_id in number,
  responsibility_id in number,
  responsibility_application_id in number,
  security_group_id in number default null,
  start_date in date,
  end_date in date,
  description in varchar2,
  update_who_columns in varchar2 default null
     /* 'N' = leave old who vals.  'Y' (default) = update who to current*/);

--
--  FNDLOAD-friendly cover for Upload_Assignment above
--
    /*#
     * Creates or updates User-Responsibility Group information as appropriate.
     * @param x_user_name User Name
     * @param x_resp_key Responsibility Key
     * @param x_app_short_name Application Short Name
     * @param x_security_group Security Group Name
     * @param x_owner Owner Name
     * @param x_start_date Effective Start Date
     * @param x_end_date Effective End Date
     * @param x_description Description
     * @param x_last_update_date Insert/Update Date
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Create/Update User Responsibility Group
     * @rep:compatibility S
     */
procedure LOAD_ROW (
  X_USER_NAME		in	VARCHAR2,
  X_RESP_KEY		in	VARCHAR2,
  X_APP_SHORT_NAME	in	VARCHAR2,
  X_SECURITY_GROUP	in	VARCHAR2,
  X_OWNER               in	VARCHAR2,
  X_START_DATE		in	VARCHAR2,
  X_END_DATE		in	VARCHAR2,
  X_DESCRIPTION		in	VARCHAR2,
  X_LAST_UPDATE_DATE    in      DATE default sysdate);


--
-- Makes a role for this resp/secgrp.
--
procedure sync_roles_one_resp_secgrp(
                   respid in number,
                   appid in number,
                   respkey in varchar2,
                   secgrpid in number,
                   secgrpkey in varchar2,
                   startdate in date,
                   enddate in date);

--
-- Makes roles for all security groups for a particular resp.
-- This should be called when a resp is created/deleted.
--
procedure sync_roles_all_secgrps(
                   respid in number,
                   appid in number,
                   respkey in varchar2,
                   startdate in date,
                   enddate in date);

--
-- Makes roles for all resps for a particular security group.
-- This should be called when a security group is created/deleted.
--
procedure sync_roles_all_resps(
                  secgrpid in varchar2,
                  secgrpkey in varchar2);


--
-- Makes roles for all resps for all security groups.
-- This routine is generally called once by an upgrade script which
-- converts from the old resp roles to the new resp roles.
-- Bug4349774 added sync_all_flag to enable original functionality when
-- set to TRUE.

    /*#
     * Creates roles for all responsibility and security group combinations.
     * @param sync_all_flag Insert/Update All
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Creates all responsibility/security group roles.
     * @rep:compatibility S
     */

procedure sync_roles_all_resp_secgrps(sync_all_flag in boolean default FALSE);

--
-- Moves old data from fnd_user_resp_groups table to new workflow tables.
-- This routine is no longer used because this is now done in the
-- bulk sync.  But it remains exposed just in case in an emergency
-- it might be useful to resolve something.
procedure one_time_furg_to_wf_upgrade;

-- Converts role names from FND_RESPX:Y format to FND_RESP_SEC|A|B|C format
 -- if necessary. Returns upgraded role name or original if it is in any
 -- other format.
function upgrade_resp_role(respid in number,
                            appid in number) return varchar2;



-- sync_roles_all_secgrps_int
--
--  Bug4322412
--   For a given resp, sync roles for all security groups if the role
--   does not already exist.
--
--   NOTE:This routine does not update existing roles. To update existing roles
--   the routine sync_roles_all_secgrps should be used.
--
procedure sync_roles_all_secgrps_int(
                   respid in number,
                   appid in number,
                   respkey in varchar2,
                   startdate in date,
                   enddate in date);


end fnd_user_resp_groups_api;

 

/
