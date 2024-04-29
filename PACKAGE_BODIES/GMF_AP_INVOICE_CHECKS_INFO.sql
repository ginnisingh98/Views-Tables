--------------------------------------------------------
--  DDL for Package Body GMF_AP_INVOICE_CHECKS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AP_INVOICE_CHECKS_INFO" AS
/* $Header: gmfchknb.pls 115.0 99/07/16 04:15:13 porting shi $ */
  CURSOR invoice_checks(  startdate date,
                  enddate date,
                  checkid number) IS
    SELECT   ach.amount,
          ach.bank_account_num,
          ach.bank_num,
          ach.bank_account_type,
          ach.currency_code,
          ach.status_lookup_code,
          ach.stopped_at,
          ach.released_at,
          ach.void_date
    FROM     AP_CHECKS_ALL ach
    WHERE     ach.check_id = NVL(checkid,ach.check_id)   AND
          ach.creation_date  BETWEEN
              nvl(startdate,ach.creation_date)  AND
              nvl(enddate,ach.creation_date);

/*    SELECT   aip.amount,
          aip.bank_account_num,
          aip.bank_num,
          aip.bank_account_type,
          ach.currency_code,
          ach.status_lookup_code
    FROM     AP_INVOICE_PAYMENTS_ALL aip,
          AP_CHECKS_ALL ach
    WHERE     aip.check_id = NVL(checkid,aip.check_id)   AND
          aip.creation_date  BETWEEN
              nvl(startdate,aip.creation_date)  AND
              nvl(enddate,aip.creation_date)
        AND    ach.check_id = aip.check_id;

The above statement is chaged on final edition based on DLX request */

  PROCEDURE get_invoice_checks_info(  startdate in date,
                          enddate in date,
                          checkid    in   out number,
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
                          statuscode out number) IS
  wcheck_status   varchar2(250);
  disp_status  varchar2(250);
  void_date  date;
  Begin
    IF NOT invoice_checks%ISOPEN THEN
      OPEN invoice_checks(  startdate,enddate,checkid);
    END IF;
    FETCH invoice_checks
    INTO    amount,
          bankaccountnum,
          banknum  ,
          bankaccounttype,
          checkcurrency,
          wcheck_status,
          t_stopped_at,
          t_released_at,
          void_date;


    select displayed_field into checkstatus
    from ap_lookup_codes
    where lookup_type = 'CHECK STATE'
    and   lookup_code = wcheck_status;

    if void_date is not null then
      select displayed_field into status
      from ap_lookup_codes
      where lookup_type = 'CHECK STATE'
      and   lookup_code = 'VOID';
    elsif t_stopped_at is null then
      status := NULL;
               elsif t_released_at is null and t_stopped_at is not null then
      select displayed_field into status
      from ap_lookup_codes
      where lookup_type = 'STOP PAYMENT STATUS'
      and   lookup_code = 'STOPPED';
    else
      select displayed_field into status
      from ap_lookup_codes
      where lookup_type = 'STOP PAYMENT STATUS'
      and   lookup_code = 'RELEASED';
               end if;


      if invoice_checks%NOTFOUND then
      statuscode :=  100;
      end if;
    IF invoice_checks%NOTFOUND  or row_to_fetch = 1 THEN
      CLOSE invoice_checks;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        statuscode := SQLCODE;
  End;  /* End of procedure get_invoice_checks*/
END GMF_AP_INVOICE_CHECKS_INFO;

/
