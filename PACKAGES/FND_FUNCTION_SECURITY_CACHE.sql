--------------------------------------------------------
--  DDL for Package FND_FUNCTION_SECURITY_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FUNCTION_SECURITY_CACHE" AUTHID CURRENT_USER as
/* $Header: AFFSCIS.pls 120.1 2005/07/02 04:07:24 appldev ship $ */

--
-- Invoked when the specified function has been deleted.
--
procedure delete_function(p_function_id in number);

--
-- Invoked when the specified function has been inserted.
--
procedure insert_function(p_function_id in number);

--
-- Invoked when the specified function has been updated.
--
procedure update_function(p_function_id in number);

--
-- Invoked when the specified grant has been deleted.
--
procedure delete_grant(p_grant_guid in raw, p_grantee_type in varchar2,
  p_grantee_key in varchar2);

--
-- Invoked when the specified grant has been inserted.
--
procedure insert_grant(p_grant_guid in raw, p_grantee_type in varchar2,
  p_grantee_key in varchar2);

--
-- Invoked when the specified grant has been updated.
--
procedure update_grant(p_grant_guid in raw, p_grantee_type in varchar2,
  p_grantee_key in varchar2);

--
-- Invoked when the specified menu has been deleted.
--
procedure delete_menu(p_menu_id in number);

--
-- Invoked when the specified menu has been inserted.
--
procedure insert_menu(p_menu_id in number);

--
-- Invoked when the specified menu has been updated.
--
procedure update_menu(p_menu_id in number);

--
-- Invoked when the specified menu entry has been deleted.
--
procedure delete_menu_entry(p_menu_id in number, p_sub_menu_id in number,
  p_function_id in number);

--
-- Invoked when the specified menu entry has been inserted.
--
procedure insert_menu_entry(p_menu_id in number, p_sub_menu_id in number,
  p_function_id in number);

--
-- Invoked when the specified menu entry has been updated.
--
procedure update_menu_entry(p_menu_id in number, p_sub_menu_id in number,
  p_function_id in number);

--
-- Invoked when the specified responsibility has been deleted.
--
procedure delete_resp(p_resp_id in number, p_resp_appl_id in number);

--
-- Invoked when the specified responsibility has been inserted.
--
procedure insert_resp(p_resp_id in number, p_resp_appl_id in number);

--
-- Invoked when the specified responsibility has been updated.
--
procedure update_resp(p_resp_id in number, p_resp_appl_id in number);

--
-- Invoked when the specified security group has been deleted.
--
procedure delete_secgrp(p_security_group_id in number);

--
-- Invoked when the specified security group has been inserted.
--
procedure insert_secgrp(p_security_group_id in number);

--
-- Invoked when the specified security group has been updated.
--
procedure update_secgrp(p_security_group_id in number);

--
-- Invoked when the specified user has been deleted.
--
procedure delete_user(p_user_id in number);

--
-- Invoked when the specified user has been inserted.
--
procedure insert_user(p_user_id in number);

--
-- Invoked when the specified user has been updated.
--
procedure update_user(p_user_id in number);

--
-- This API is obsolete and should not be used for new code.
-- Invoked when the specified user responsibility assignment has been deleted.
--
procedure delete_user_resp(p_user_id in number, p_resp_id in number,
  p_resp_appl_id in number);

--
-- This API is obsolete and should not be used for new code.
-- Invoked when the specified user responsibility assignment has been inserted.
--
procedure insert_user_resp(p_user_id in number, p_resp_id in number,
  p_resp_appl_id in number);

--
-- This API is obsolete and should not be used for new code.
-- Invoked when the specified user responsibility assignment has been updated.
--
procedure update_user_resp(p_user_id in number, p_resp_id in number,
  p_resp_appl_id in number);

--
-- Invoked when the specified user role assignment has been deleted.
--
procedure delete_user_role(p_user_id in number, p_role_name in varchar2);

--
-- Invoked when the specified user role assignment has been inserted.
--
procedure insert_user_role(p_user_id in number, p_role_name in varchar2);

--
-- Invoked when the specified user role assignment has been updated.
--
procedure update_user_role(p_user_id in number, p_role_name in varchar2);

end FND_FUNCTION_SECURITY_CACHE;

 

/
