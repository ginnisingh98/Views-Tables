--------------------------------------------------------
--  DDL for Package GMF_AP_GET_PAYMENT_METHODS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AP_GET_PAYMENT_METHODS" AUTHID CURRENT_USER AS
/* $Header: gmfpayms.pls 115.0 99/07/16 04:21:38 porting shi $ */
   PROCEDURE ap_get_payment_methods (    startdate in date,
                            enddate in date,
                            payment_method in varchar2,
                            lookupcode out varchar2,
                            descr  out varchar2,
                            row_to_fetch in out number,
                            statuscode out number);
END GMF_AP_GET_PAYMENT_METHODS;

 

/
