--------------------------------------------------------
--  DDL for Package BIV_BIN_ESC_RSC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_BIN_ESC_RSC_PKG" AUTHID CURRENT_USER as
/* $Header: bivbescs.pls 115.4 2002/11/15 16:27:42 smisra noship $ */
  procedure sr_esc_bin   (p_param_str varchar2)   ;
  procedure resource_bin (p_param_str varchar2)   ;
  procedure tsk_summry_rep(p_param_str varchar2);
  procedure rltd_task_rep(p_sr_id varchar2);
  procedure get_resource_where_clause (p_from_list    out nocopy varchar2,
                                       p_where_clause out nocopy varchar2);
end ;

 

/
