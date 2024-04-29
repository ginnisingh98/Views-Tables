--------------------------------------------------------
--  DDL for Package Body QP_JAVA_ENGINE_SUPPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_JAVA_ENGINE_SUPPORT_PVT" as
/* $Header: QPXSUPPB.pls 120.0 2005/06/02 01:26:11 appldev noship $ */

function request_lock(p_lock_name in varchar2, p_lock_mode in number, p_timeout in number, p_release_on_commit in number) return number is
pragma autonomous_transaction;

l_release_on_commit boolean;
begin
  if (p_release_on_commit = 1) then
  	l_release_on_commit := true;
  else
  	l_release_on_commit := false;
  end if;
  return request_lock(p_lock_name, p_lock_mode, p_timeout, l_release_on_commit);
end request_lock;

function request_lock(p_lock_name in varchar2, p_lock_mode in number, p_timeout in number, p_release_on_commit in boolean) return number is
pragma autonomous_transaction;

l_lock_handle varchar2(128);
l_status number;
begin
  dbms_lock.allocate_unique(p_lock_name, l_lock_handle);
  l_status := dbms_lock.request(l_lock_handle, p_lock_mode, p_timeout, p_release_on_commit);
  return l_status;
end request_lock;

function release_lock(p_lock_name in varchar2) return number is

l_lock_handle varchar2(128);
l_status number;
begin
  dbms_lock.allocate_unique(p_lock_name, l_lock_handle);
  l_status := dbms_lock.release(l_lock_handle);
  return l_status;
end release_lock;

end QP_JAVA_ENGINE_SUPPORT_PVT;

/
