--------------------------------------------------------
--  DDL for Package QP_JAVA_ENGINE_SUPPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_JAVA_ENGINE_SUPPORT_PVT" AUTHID CURRENT_USER as
/* $Header: QPXSUPPS.pls 120.0 2005/06/02 01:02:27 appldev noship $ */

g_lock_type varchar2(10);
function request_lock(p_lock_name in varchar2, p_lock_mode in number, p_timeout in number, p_release_on_commit in boolean) return number;
function request_lock(p_lock_name in varchar2, p_lock_mode in number, p_timeout in number, p_release_on_commit in number) return number;
function release_lock(p_lock_name in varchar2) return number;

end QP_JAVA_ENGINE_SUPPORT_PVT;

 

/
