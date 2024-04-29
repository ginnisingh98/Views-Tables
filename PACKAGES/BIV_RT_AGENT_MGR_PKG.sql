--------------------------------------------------------
--  DDL for Package BIV_RT_AGENT_MGR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_RT_AGENT_MGR_PKG" AUTHID CURRENT_USER as
/* $Header: bivrmgrs.pls 115.2 2002/11/15 17:47:33 smisra noship $ */
  procedure agent_report(p_param_str varchar2);
  procedure manager_report(p_param_str varchar2);
end;

 

/
