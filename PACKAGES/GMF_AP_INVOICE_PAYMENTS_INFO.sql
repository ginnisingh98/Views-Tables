--------------------------------------------------------
--  DDL for Package GMF_AP_INVOICE_PAYMENTS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AP_INVOICE_PAYMENTS_INFO" AUTHID CURRENT_USER AS
/* $Header: gmfpayns.pls 115.0 99/07/16 04:21:46 porting shi $ */
  PROCEDURE get_invoice_payments_info(  startdate in date,
                            enddate in date,
                            invoiceid   in out number,
                            paymentnum   in out number,
                            checkid    out number,
                            invoicepaymentid in out number,
                            amount     out number,
                            lastupdatedate   out date,
                            setofbooksid   out number,
                            postedflag   out varchar2,
                            accountingdate   out date,
                            periodname   out varchar2,
                            checknumber     out number,
                            checkdate       out date,
                            paymentlookupcode out varchar2,
                            row_to_fetch in out number,
                            statuscode out number);
END GMF_AP_INVOICE_PAYMENTS_INFO;

 

/
