--------------------------------------------------------
--  DDL for Package Body GMF_AR_CHECK_CREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_CHECK_CREDIT" as
/* $Header: gmfcrhib.pls 115.1 2002/11/11 00:34:42 rseshadr ship $ */
     cursor cur_ar_check_credit ( st_date date,
                                  en_date date,
                                  cust_id number ) is
            select CREDIT_HISTORY_ID, LAST_UPDATE_DATE,
                   LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                   CREATION_DATE, CREATED_BY, CUSTOMER_ID,
                   ON_HOLD, HOLD_DATE, CREDIT_LIMIT, CREDIT_RATING,
                   RISK_CODE, OUTSTANDING_BALANCE, SITE_USE_ID
              FROM AR_CREDIT_HISTORIES
            WHERE  CUSTOMER_ID = nvl(cust_id, CUSTOMER_ID)
              AND creation_date between nvl(st_date, creation_date)
              AND nvl(en_date, creation_date);

   procedure proc_ar_check_credit(st_date        in out NOCOPY date,
                                  en_date        in out NOCOPY date,
                                  cust_id        in out NOCOPY number,
                                  cr_hist_id     out    NOCOPY number,
                                  lst_updt_dt    out    NOCOPY date,
                                  lst_updt_by    out    NOCOPY number,
                                  lst_updt_login out    NOCOPY number,
                                  create_dat     out    NOCOPY date,
                                  create_by      out    NOCOPY number,
                                  on_hld         out    NOCOPY varchar2,
                                  hld_dt         out    NOCOPY date,
                                  cr_lmt         out    NOCOPY number,
                                  cr_rating      out    NOCOPY varchar2,
                                  risk_cd        out    NOCOPY varchar2,
                                  os_bal         out    NOCOPY number,
                                  sit_use_id     out    NOCOPY number,
                                  row_to_fetch   in out NOCOPY number,
                                  error_status   out    NOCOPY number) is

   begin

    IF NOT cur_ar_check_credit%ISOPEN THEN
      OPEN cur_ar_check_credit(st_date, en_date, cust_id);
    END IF;

    FETCH cur_ar_check_credit
            into cr_hist_id,
               lst_updt_dt, lst_updt_by,
            lst_updt_login,
            create_dat, create_by, cust_id,
            on_hld, hld_dt, cr_lmt,
            cr_rating, risk_cd, os_bal,
            sit_use_id;

    if cur_ar_check_credit%NOTFOUND or row_to_fetch = 1 THEN
      CLOSE cur_ar_check_credit;
      if cur_ar_check_credit%NOTFOUND then
      error_status:=100;
      end if;
      end if;

      exception

          when others then
            error_status := SQLCODE;

  END;  /* End of procedure proc_ar_check_credit*/

END GMF_AR_CHECK_CREDIT;  /* END GMF_AR_CHECK_CREDIT*/

/
