--------------------------------------------------------
--  DDL for Package GMF_AP_INVOICE_CHECKS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AP_INVOICE_CHECKS_INFO" AUTHID CURRENT_USER AS
/* $Header: gmfchkns.pls 115.0 99/07/16 04:15:17 porting shi $ */
  PROCEDURE get_invoice_checks_info(  startdate in date,
                          enddate in date,
                          checkid   in out number,
                          amount     out number,
                          bankaccountnum  out varchar2,
                          banknum    out varchar2,
                          bankaccounttype  out varchar2,
                                       checkcurrency     out varchar2,
                          checkstatus       out varchar2,
                          t_stopped_at      in  out varchar2,
                          t_released_at     in  out varchar2,
                          status              out varchar2,
                          row_to_fetch in out number,
                          statuscode out number);
END GMF_AP_INVOICE_CHECKS_INFO;

 

/
