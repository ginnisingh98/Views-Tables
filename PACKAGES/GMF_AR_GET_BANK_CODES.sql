--------------------------------------------------------
--  DDL for Package GMF_AR_GET_BANK_CODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_BANK_CODES" AUTHID CURRENT_USER AS
/* $Header: gmfbancs.pls 115.0 99/07/16 04:14:42 porting shi $ */
    PROCEDURE ap_get_bank_codes(  startdate in date,
                      enddate in date,
                      sobname in out varchar2,
                      bankaccountname out varchar2,
                      bankaccountnum out varchar2,
                      currencycode out varchar2,
                       descrip out varchar2,
                      maxcheckamount out number,
                      mincheckamount out number,
                      bankaccounttype out varchar2,
                      multicurrencyflag out varchar2,
                      inactivedate out date,
                      row_to_fetch in out number,
                      statuscode out number);
 END GMF_AR_GET_BANK_CODES;

 

/
