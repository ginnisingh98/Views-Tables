--------------------------------------------------------
--  DDL for Package FND_SEC_BULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SEC_BULK" AUTHID CURRENT_USER as
/* $Header: AFSCBLKS.pls 115.8 2003/12/04 19:10:07 pdeluna noship $ */


--------------------------------------------------------------------------
-- AddRespUserGroup
--   Assign a responsibility key to a group of users.
--   The group of users is defined in x_user_group_clause.
--   You can optionally supply description, start_date and end_date.
--   The return value is the number of users processed.
--
-- Usage Example
--   declare
--     user_clause varchar2(2000);
--     cnt number;
--   begin
--     user_clause := fnd_sec_bulk.UserAssignResp('FND',
--                                                'SYSTEM_ADMINISTRATOR',
--                                                'STANDARD');
--     cnt:= fnd_sec_bulk.AddRespUserGroup(user_clause,
--                                   'FND',
--                                   'SYSTEM_ADMINISTRATOR_GUI',
--                                   '',
--                                   'New SYSADMIN responsibility');
-- OR  cnt:= fnd_sec_bulk.AddRespUserGroup(user_clause,
--                                   'FND',
--                                   'SYSTEM_ADMINISTRATOR_GUI');
--   end;
--
-- Input Arguments
--   x_user_group_clause:  A sql statement returns all user's user_id
--                         For example, "select user_id from fnd_user where..."
--   x_resp_application:   Responsibility application short name
--   x_responsibility:     Responsibility key
--   x_security_group:     Security Group. Default is null.
--                         If x_user_group_clause is provided from calling
--                         UserAssignResp(), then DO NOT pass in
--                         x_security_group.
--                         If x_user_group_clause is provided by yourself,
--                         then you SHOULD input the x_security_group.
--   x_description:        Description
--   x_start_date:         Start date
--   x_end_date:           End date

function AddRespUserGroup(
  x_user_group_clause          in varchar2,
  x_resp_application           in varchar2,
  x_responsibility             in varchar2,
  x_security_group             in varchar2 default '',
  x_description                in varchar2 default '',
  x_start_date                 in date default sysdate,
  x_end_date                   in date default null) return number;

--------------------------------------------------------------------------
-- AddRespIdUserGroup
--   Assign a responsibility which identified by ID to a group of users.
--   The group of users is defined in x_user_group_clause.
--   You can optionally supply description, start_date and end_date.
--   The return value is the number of users processed.
--
-- Usage Example
--   declare
--     user_clause varchar2(2000);
--   begin
--     user_clause := fnd_sec_bulk.UserAssignRespId(0, 101, 'STANDARD');
--     cnt :=  fnd_sec_bulk.AddRespIdUserGroup(user_clause, 0, 20420);
--   end;
--
-- Input Arguments
--   x_user_group_clause:  A sql statement returns all user's user_id
--                         For example, "select user_id from fnd_user where..."
--   x_resp_application_id:Responsibility application id
--   x_responsibility_id:  Responsibility id
--   x_security_group:     Security Group. Default is null.
--                         If x_user_group_clause is provided from calling
--                         UserAssignRespId(), then DO NOT pass in
--                         x_security_group.
--                         If x_user_group_clause is provided by yourself,
--                         then you SHOULD input the x_security_group.
--   x_description:        Description
--   x_start_date:         Start date
--   x_end_date:           End date

function AddRespIdUserGroup(
  x_user_group_clause          in varchar2,
  x_resp_application_id        in number,
  x_responsibility_id          in number,
  x_security_group             in varchar2 default '',
  x_description                in varchar2 default '',
  x_start_date                 in date default sysdate,
  x_end_date                   in date default null) return number;


--------------------------------------------------------------------------
-- UserAssignResp
--   Find all the users that have this given responsibility key and
--   security group pair.
--   Construct a full qualified sql statement to return all the user_ids.
--   So that this kind of sql statement can be used when calling
--   AddRespUserGroup().
-- Usage Example
--   declare
--     user_clause varchar2(2000);
--     cnt number;
--   begin
--     user_clause := fnd_sec_bulk.UserAssignResp('FND',
--                                                'SYSTEM_ADMINISTRATOR',
--                                                'STANDARD');
--     cnt := fnd_sec_bulk.AddRespUserGroup(user_clause,
--                                   'FND',
--                                   'SYSTEM_ADMINISTRATOR_GUI');
--   end;
-- Input Arguments
--   x_resp_application:   Responsibility application short name
--   x_responsibility:     Responsibility key
--   x_security_group:     Responsibility security group name

function UserAssignResp(
  x_resp_application          in varchar2,
  x_responsibility            in varchar2,
  x_security_group            in varchar2 default 'STANDARD')
  return varchar2;

--------------------------------------------------------------------------
-- UserAssignRespId
--   Find all the users that have this given responsibility identified by ID
--   and security group pair.
--   Construct a full qualified sql statement to return all the user_ids.
--   So that this kind of sql statement can be used when calling
--   AddRespUserGroup().
-- Usage Example
--   declare
--     user_clause varchar2(2000);
--     cnt number;
--   begin
--     user_clause := fnd_sec_bulk.UserAssignRespId(0,101, 'STANDARD');
--
--     cnt := fnd_sec_bulk.AddRespIdUserGroup(user_clause, 0, 20420);
--   end;
-- Input Arguments
--   x_resp_application_id:Responsibility application id
--   x_responsibility_id:  Responsibility id
--   x_security_group:     Responsibility security group name

function UserAssignRespId(
  x_resp_application_id       in number,
  x_responsibility_id         in number,
  x_security_group            in varchar2 default 'STANDARD')
  return varchar2;


--------------------------------------------------------------------------
-- UpdateUserGroup
--   Update some of user attributes for a group of users.
--   Non-specified attribute is treated as taking the current
--   default value.
--   The group of users is defined in x_user_group_clause which is a full
--   qualified "select" sql statement.
--
-- Input Arguments
--   x_user_group_clause:  A sql statement returns all user's user_id
--                         For example, "select user_id from fnd_user where..."
--   x_start_date:         Start date
--   x_end_date:           End date
--   x_description:        User Description
--   x_password_lifespan_access: To control password expiration
--   x_password_lifespan_days:  To  control password expiration
--   x_email_address:      User email address
--   x_fax:                User fax number

procedure UpdateUserGroup(
  x_user_group_clause          in varchar2,
  x_start_date                 in date default null,
  x_end_date                   in date default null,
  x_description                in varchar2 default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_email_address              in varchar2 default null,
  x_fax	                       in varchar2 default null);


--------------------------------------------------------------------------
-- UpdateUserGroupTemplate
--   Update a group of users to have the same privileges as the given
--   template user. Supported privileges are user attributes, assigned
--   responsibilities and profiles.
--   The group of users is defined in x_user_group_clause.
--   You can optionally choose to clone all user attributes, all
--   responsibilities or all profile options.
--
-- Usage Example
--   declare
--     user_clause varchar2(2000);
--   begin
--     user_clause := fnd_sec_bulk.UserAssignResp('FND',
--                                             'ASSISTANT_SYSTEM_ADMINISTRATOR',
--                                                'STANDARD');
--     /* This will give all users SYSADMIN's's profile but not */
--     /* responsibilities and other attributes. */
--     fnd_sec_bulk.UpdateUserGroupTemplate(user_clause,
--                                          'SYSADMIN',
--                                          FALSE, FALSE, TRUE);
--   end;
--
-- Input Arguments
--   x_user_group_clause:  A select sql statement returns all user's user_id
--                         For example, "select user_id from fnd_user where..."
--   x_template_user:      The user name that you are going to clone from
--   x_attribute_flag:     Whether to clone user attributes
--   x_responsibility_flag:Whether to clone responsibility
--   x_profile_flag:       Whether to clone profile

procedure UpdateUserGroupTemplate(
  x_user_group_clause    in varchar2,
  x_template_user              in varchar2,
  x_attribute_flag             in boolean default TRUE,
  x_responsibility_flag        in boolean default TRUE,
  x_profile_flag               in boolean default TRUE);


end FND_SEC_BULK;

 

/
