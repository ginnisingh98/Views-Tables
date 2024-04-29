--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_BANK_CODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_BANK_CODES" AS
/* $Header: gmfbancb.pls 115.0 99/07/16 04:14:38 porting shi $ */

    CURSOR bank_codes(  startdate date,
                  enddate date,
                  sobname varchar2)  IS
       SELECT    gsob.name    ,
              aba.bank_account_name  ,
              aba.bank_account_num  ,
              aba.currency_code  ,
              aba.description    ,
              aba.max_check_amount  ,
              aba.min_check_amount  ,
              aba.bank_account_type  ,
              aba.multi_currency_flag  ,
              aba.inactive_date
       FROM      ap_bank_accounts_all aba,
              gl_sets_of_books gsob
       WHERE      aba.set_of_books_id =
              gsob.set_of_books_id  AND
               gsob.name like sobname  AND
              aba.creation_date  BETWEEN
              nvl(startdate,aba.creation_date)  AND
              nvl(enddate,aba.creation_date);

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
                      statuscode out number) IS

  BEGIN
    IF NOT bank_codes%ISOPEN THEN
      OPEN bank_codes(startdate,enddate,sobname);
    END IF;
    FETCH bank_codes
    INTO   sobname ,
        bankaccountname ,
        bankaccountnum ,
        currencycode ,
        descrip ,
        maxcheckamount ,
        mincheckamount ,
        bankaccounttype ,
        multicurrencyflag ,
        inactivedate;
    IF bank_codes%NOTFOUND or row_to_fetch = 1 THEN
      CLOSE bank_codes;
      if bank_codes%NOTFOUND then
         statuscode := 100;
         end if;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        statuscode := SQLCODE;
   END ap_get_bank_codes;
END GMF_AR_GET_BANK_CODES;

/
