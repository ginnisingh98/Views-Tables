--------------------------------------------------------
--  DDL for Package FND_SECURITY_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SECURITY_GROUPS_API" AUTHID CURRENT_USER as
/* $Header: AFSCGPAS.pls 115.2 99/07/16 23:28:35 porting sh $ */
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
return boolean;

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
return boolean;

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
return boolean;

--
-- Create_Group
--   Create a new security group
-- IN
--   security_group_key - internal name of security group
--   security_group_name - user name of security group
--   description - security group description
-- RETURNS
--   Security_Group_Id of new security group created
--   Raise exception if any errors encountered.
--
function Create_Group(
  security_group_key in varchar2,
  security_group_name in varchar2,
  description in varchar2)
return number;

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
  description in varchar2);

end Fnd_Security_Groups_Api;

 

/
