--------------------------------------------------------
--  DDL for Package BIV_RT_ESC_CUS_BLOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_RT_ESC_CUS_BLOG_PKG" AUTHID CURRENT_USER AS
	-- $Header: bivecbgs.pls 115.6 2002/11/15 17:42:32 smisra noship $ */
	-- customer backlog and esclated SR report
-- for real time reporting
   function severity_label(p_param_str in varchar2 default null) return varchar2;
   function base_column_label(p_param_str in varchar2 default null) return varchar2 ;
   function inc_status_1_label(p_param_str in varchar2 default null) return varchar2 ;
   function inc_status_2_label(p_param_str in varchar2 default null)return varchar2 ;
   function inc_status_3_label(p_param_str in varchar2 default null)  return varchar2 ;
   procedure customer_backlog ( p_param_str  in varchar2);
   procedure escalated_sr_backlog ( p_param_str  in varchar2);
   procedure  customer_backlog_dd ( p_param_str  in varchar2 ) ;
end; -- package spec

 

/
