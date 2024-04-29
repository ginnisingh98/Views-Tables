--------------------------------------------------------
--  DDL for Package BIV_RT_TASK_BLOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_RT_TASK_BLOG_PKG" AUTHID CURRENT_USER as
/* $Header: bivrtsks.pls 115.6 2002/11/15 17:48:50 smisra noship $ */
  procedure sr_backlog(p_param_str varchar2);
  procedure task_activity(p_param_str varchar2);
  procedure open_tasks   (p_param_str varchar2);
  procedure service_requests(p_param_str varchar2);
  procedure service_requests_task(p_param_str varchar2);
  function  status_descr1 (p_param_str varchar2) return varchar2;
  function  status_descr2 (p_param_str varchar2) return varchar2;
  function  status_descr3 (p_param_str varchar2) return varchar2;
  function  status_descr(p_sts_id varchar2)  return varchar2;
end;

 

/
