--------------------------------------------------------
--  DDL for Package Body FND_SECURITY_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SECURITY_GROUPS_API" as
/* $Header: AFSCGPAB.pls 115.4 99/07/16 23:28:29 porting sh $ */

--
-- Generic_Error (Internal)
--
-- Set error message and raise exception for unexpected sql errors.
--
procedure Generic_Error(
  routine in varchar2,
  errcode in number,
  errmsg in varchar2)
is
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    app_exception.raise_exception;
end;

--
-- Id_Exists
--   Check if security group with given id exists
-- IN
--   security_group_id - Id number of security group
-- RETURN
--   TRUE if security group exists with given name
--
function Id_Exists(
  security_group_id in number)
return boolean
is
  dummy number;
begin
  select count(1)
  into dummy
  from FND_SECURITY_GROUPS
  where SECURITY_GROUP_ID = Id_Exists.security_group_id;

  return(TRUE);
exception
  when no_data_found then
    return(FALSE);
  when others then
    Generic_Error('FND_SECURITY_GROUPS_API.ID_EXISTS',
        sqlcode, sqlerrm);
end Id_Exists;

--
-- Key_Exists
--   Check if security group with given key exists
-- IN
--   security_group_key - internal name of security group
-- RETURN
--   TRUE if security group exists with given name
--
function Key_Exists(
  security_group_key in varchar2)
return boolean
is
  dummy number;
begin
  select 1
  into dummy
  from FND_SECURITY_GROUPS
  where SECURITY_GROUP_KEY = Key_Exists.security_group_key;

  return(TRUE);
exception
  when no_data_found then
    return(FALSE);
  when others then
    Generic_Error('FND_SECURITY_GROUPS_API.KEY_EXISTS',
        sqlcode, sqlerrm);
end Key_Exists;

--
-- Name_Exists
--   Check if security group with given username exists
-- IN
--   security_group_name - user name of security group
-- RETURN
--   TRUE if security group exists with given username
--
function Name_Exists(
  security_group_name in varchar2)
return boolean
is
  dummy number;
begin
  select 1
  into dummy
  from FND_SECURITY_GROUPS_VL
  where SECURITY_GROUP_NAME = Name_Exists.security_group_name;

  return(TRUE);
exception
  when no_data_found then
    return(FALSE);
  when others then
    Generic_Error('FND_SECURITY_GROUPS_API.NAME_EXISTS',
        sqlcode, sqlerrm);
end Name_Exists;

--
-- Create_Group
--   Create a new security group
-- IN
--   security_group_key - internal name of security group
--   security_group_name - user name of security group
--   description - security group description
-- RETURNS
--   security_group_id of new security group created
--   Raise exception if any errors encountered.
--
function Create_Group(
  security_group_key in varchar2,
  security_group_name in varchar2,
  description in varchar2)
return number
is
  security_group_id number;
  row_id varchar2(64);
begin
  -- Pull of a new id from sequence
  select FND_SECURITY_GROUPS_S.NEXTVAL
  into security_group_id
  from SYS.DUAL;

  -- Insert new row in security groups
  Fnd_Security_Groups_Pkg.Insert_Row(
    row_id,
    security_group_id,
    security_group_key,
    security_group_name,
    description,
    sysdate,
    Fnd_Global.User_Id,
    sysdate,
    Fnd_Global.User_Id,
    Fnd_Global.Login_Id);

  return security_group_id;
exception
  when others then
    Generic_Error('FND_SECURITY_GROUPS_API.CREATE_GROUP',
        sqlcode, sqlerrm);
end Create_Group;

--
-- Update_Group
--   Update values in existing security group
-- IN
--   security_group_key -  internal name of security group to update
--   security_group_name - NEW user name of security group
--   description - NEW security group description
--
procedure Update_Group(
  security_group_key in varchar2,
  security_group_name in varchar2,
  description in varchar2)
is
  security_group_id number;
begin
  -- Get id of group.
  -- Allow no_data_found error to trickle up.
  select FSG.SECURITY_GROUP_ID
  into security_group_id
  from FND_SECURITY_GROUPS FSG
  where FSG.SECURITY_GROUP_KEY = Update_Group.security_group_key;

  Fnd_Security_Groups_Pkg.Update_Row(
    security_group_id,
    security_group_key,
    security_group_name,
    description,
    sysdate,
    Fnd_Global.User_Id,
    Fnd_Global.Login_Id);
exception
  when others then
    Generic_Error('FND_SECURITY_GROUPS_API.UPDATE_GROUP',
        sqlcode, sqlerrm);
end Update_Group;

end Fnd_Security_Groups_Api;

/
