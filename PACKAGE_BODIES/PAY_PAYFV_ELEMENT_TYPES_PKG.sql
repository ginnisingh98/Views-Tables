--------------------------------------------------------
--  DDL for Package Body PAY_PAYFV_ELEMENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYFV_ELEMENT_TYPES_PKG" as
/* $Header: payfvetp.pkb 115.0 2003/01/13 14:19:33 scchakra noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 2002 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved                            |
+==============================================================================+

Name
        Supporting functions for BIS view PAYFV_ELEMENT_TYPES_PKG.
Purpose
        To return non-id table information where needed to enhance the
        performance of the view.
History

rem
rem Version Date        Author         Comment
rem -------+-----------+--------------+----------------------------------------
rem 115.0   13-JAN-2003 Scchakra       Date Created
rem ==========================================================================
*/
--------------------------------------------------------------------------------
FUNCTION get_applsys_user (p_user_id IN NUMBER) RETURN VARCHAR2 IS
--
l_user_name  fnd_user.user_name%type;
--
  cursor c_get_user
  is
    select user_name
      from fnd_user usr
     where usr.user_id = p_user_id;
--
begin
  --
  open c_get_user;
  fetch c_get_user into l_user_name;
  close c_get_user;
  --
  return l_user_name;
  --
end get_applsys_user;
--------------------------------------------------------------------------------
FUNCTION get_event_group_name (p_event_group_id IN NUMBER) RETURN VARCHAR2 IS
--
l_event_group_name  varchar2(240);
--
  cursor c_get_event_group_name
  is
    select event_group_name
      from pay_event_groups peg
     where peg.event_group_id = p_event_group_id;
--
begin
  --
  open c_get_event_group_name;
  fetch c_get_event_group_name into l_event_group_name;
  close c_get_event_group_name;
  --
  return l_event_group_name;
  --
end;

end PAY_PAYFV_ELEMENT_TYPES_PKG;

/
