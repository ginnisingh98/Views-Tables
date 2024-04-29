--------------------------------------------------------
--  DDL for Package Body GMF_AP_GET_PAYMENT_METHODS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AP_GET_PAYMENT_METHODS" AS
/* $Header: gmfpaymb.pls 115.0 99/07/16 04:21:34 porting shi $ */
    CURSOR payment_methods(  startdate date,
                    enddate date,
                    payment_method varchar2) IS
         SELECT    lookup_code,
                description
         FROM    AP_LOOKUP_CODES
         WHERE    lookup_type like nvl(payment_method, lookup_type);
     PROCEDURE ap_get_payment_methods(  startdate in date,
                            enddate in date,
                            payment_method in varchar2,
                            lookupcode out varchar2,
                            descr out varchar2,
                            row_to_fetch in out number,
                            statuscode out number) IS
     BEGIN

        IF NOT payment_methods%ISOPEN THEN
          OPEN payment_methods(startdate,enddate,payment_method);
        END IF;
        FETCH payment_methods
        INTO   lookupcode,
            descr;
        IF payment_methods%NOTFOUND or row_to_fetch = 1 THEN
          CLOSE payment_methods;
          if payment_methods%NOTFOUND then
             statuscode := 100;
          end if;
        END IF;
        EXCEPTION
          WHEN OTHERS THEN
            statuscode := SQLCODE;
    END ap_get_payment_methods;
END GMF_AP_GET_PAYMENT_METHODS;

/
