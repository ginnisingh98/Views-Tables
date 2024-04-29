--------------------------------------------------------
--  DDL for Package XDO_DGF_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDO_DGF_REQUESTS_PKG" AUTHID CURRENT_USER as
/* $Header: XDODGFRQS.pls 120.0 2008/01/19 00:14:11 bgkim noship $ */

   TYPE request_parameters_table IS TABLE OF varchar2(256) INDEX BY BINARY_INTEGER;

   FUNCTION submit_request
     ( application IN varchar2,
       program     IN varchar2,
       params      IN request_parameters_table
       )
     RETURN  number;

   FUNCTION submit_request(p_report_code        in varchar2,
                           p_all_parameter_list xdo_dgf_RPT_PKG.PARAM_TABLE_TYPE)
   RETURN number;

   FUNCTION submit_request(p_report_code        in varchar2,
                           p_all_parameter_list xdo_dgf_PARAM_TABLE_TYPE)
   RETURN number;

   FUNCTION submit_request
     ( application IN varchar2,
       program     IN varchar2,
       param1      IN varchar2,
       param2      IN varchar2 default ''
       )
     RETURN  number;

END xdo_dgf_requests_pkg;

/
