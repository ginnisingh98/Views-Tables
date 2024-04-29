--------------------------------------------------------
--  DDL for Package GMF_AP_GET_PAYMENT_TERMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AP_GET_PAYMENT_TERMS" AUTHID CURRENT_USER AS
/* $Header: gmfpayrs.pls 115.0 99/07/16 04:21:55 porting shi $ */
     PROCEDURE ap_get_payment_terms (  startdate  in date,
                          enddate  in date,
                          name1 in out varchar2,
                          descr out varchar2,
                          startdateactive  out date,
                          enddateactive  out date,
                          duepercent out number,
                          dueamount out number,
                          duedays out number,
                          duedayofmonth out number,
                          duemonthsforward out number,
                          discountpercent out number,
                          discountdays out number,
                          discountdayofmonth out number,
                          discountmonthforward out number,
                          discountpercent2 out number,
                          discountdays2 out number,
                          discountdayofmonth2 out number,
                          discountmonthsforward2 out number,
                          discountpercent3 out number,
                          discountdays3 out number,
                          discountdayofmonth3 out number,
                          discountmonthsforward3 out number,
                          creation_date out date,
                          created_by out number,
                          last_update_date out date,
                          last_updated_by out number,
                          row_to_fetch in out number,
                          statuscode out number);
/*          ad_by number; */
/*           mod_by number; */
END GMF_AP_GET_PAYMENT_TERMS;

 

/
