--------------------------------------------------------
--  DDL for Package BIV_HS_ESC_ACTVTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_HS_ESC_ACTVTY_PKG" AUTHID CURRENT_USER as
/* $Header: bivhacts.pls 115.3 2002/11/15 17:46:02 smisra noship $ */
  procedure sr_activity    (p_param_str varchar2);
  procedure sr_escalation  (p_param_str varchar2);
  procedure escalation_view(p_param_str varchar2);
  function  col_heading_10 (p_param_str varchar2) return varchar2;
end;

 

/
