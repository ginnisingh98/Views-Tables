--------------------------------------------------------
--  DDL for Package Body GMF_AP_GET_PAYMENT_TERMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AP_GET_PAYMENT_TERMS" AS
/* $Header: gmfpayrb.pls 115.0 99/07/16 04:21:51 porting shi $ */
  CURSOR payment_terms(startdate date, enddate date, name1 varchar2) IS
      SELECT   apt.name,
            apt.description,
            apt.start_date_active,
            apt.end_date_active,
            apt1.creation_date,
            apt1.last_update_date,
            apt1.created_by,
            apt1.last_updated_by,
            apt1.due_percent,
            nvl(apt1.due_amount,0),
            nvl(apt1.due_days,0),
            apt1.due_day_of_month,
            apt1.due_months_forward,
            nvl(apt1.discount_percent,0),
            nvl(apt1.discount_days,0),
            apt1.discount_day_of_month,
            apt1.discount_months_forward,
            apt1.discount_percent_2,
            apt1.discount_days_2,
            apt1.discount_day_of_month_2,
            apt1.discount_months_forward_2,
            apt1.discount_percent_3,
            apt1.discount_days_3,
            apt1.discount_day_of_month_3,
            apt1.discount_months_forward_3
    FROM      ap_terms apt,ap_terms_lines apt1
    WHERE      apt.name like name1       AND
            apt.term_id = apt1.term_id  AND
            apt1.sequence_num = 1     AND
            apt.last_update_date  BETWEEN
              nvl(startdate,apt.last_update_date)  AND
              nvl(enddate,apt.last_update_date);

     PROCEDURE ap_get_payment_terms (  startdate  in date,
                          enddate  in date,
                          name1 in out varchar2,
                          descr out varchar2,
                          startdateactive  out date,
                          enddateactive  out date,
                          duepercent out number,
                          dueamount out number,
                          duedays out number,
                          duedayofmonth out  number,
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
                          statuscode out  number) IS
    BEGIN
        IF NOT payment_terms%ISOPEN THEN
          OPEN payment_terms(startdate,enddate,name1);
        END IF;
        FETCH   payment_terms
        INTO    name1 ,
              descr ,
              startdateactive  ,
              enddateactive  ,
              creation_date,
              last_update_date,
              created_by,
              last_updated_by  ,
              duepercent ,
              dueamount ,
              duedays ,
              duedayofmonth ,
              duemonthsforward ,
              discountpercent ,
              discountdays ,
              discountdayofmonth ,
              discountmonthforward ,
              discountpercent2 ,
              discountdays2 ,
              discountdayofmonth2 ,
              discountmonthsforward2 ,
              discountpercent3 ,
              discountdays3 ,
              discountdayofmonth3 ,
              discountmonthsforward3;
 /*          added_by := pkg_gl_get_currencies.get_name(ad_by); */
 /*          modified_by := pkg_gl_get_currencies.get_name(mod_by); */
          if payment_terms%NOTFOUND then
             statuscode := 100;
               end if;
        IF payment_terms%NOTFOUND or row_to_fetch = 1 THEN
           CLOSE payment_terms;
        END IF;
        EXCEPTION
          WHEN OTHERS THEN
            statuscode := SQLCODE;
      END;
END GMF_AP_GET_PAYMENT_TERMS;

/
