--------------------------------------------------------
--  DDL for Package Body GMF_AP_INVOICE_PAYMENTS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AP_INVOICE_PAYMENTS_INFO" AS
/* $Header: gmfpaynb.pls 115.0 99/07/16 04:21:42 porting shi $ */
  CURSOR invoice_payments(  startdate date,
                    enddate date,
                    invoiceid number,
                       paymentnum number,
                       invoicepaymentid number) IS
    SELECT aip.invoice_id,
        aip.payment_num,
        aip.check_id,
        aip.invoice_payment_id,
        aip.amount,
        aip.last_update_date,
        aip.set_of_books_id,
        aip.posted_flag,
        aip.accounting_date,
        aip.period_name,
        ach.check_number,
        ach.check_date,
        ach.payment_method_lookup_code
    FROM   AP_INVOICE_PAYMENTS_ALL aip,
        AP_CHECKS_ALL ach
    WHERE aip.invoice_id   =  NVL(invoiceid,aip.invoice_id)
        AND aip.payment_num  =  NVL(paymentnum,aip.payment_num)
        AND  aip.invoice_payment_id=NVL(invoicepaymentid,aip.invoice_payment_id)
        AND aip.creation_date  BETWEEN
            nvl(startdate,aip.creation_date)  AND
            nvl(enddate,aip.creation_date)
        AND ach.check_id = aip.check_id;

  PROCEDURE get_invoice_payments_info(  startdate in date,
                            enddate in date,
                            invoiceid in out number,
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
                            statuscode out number)  IS
  Begin
    IF NOT invoice_payments%ISOPEN THEN
      OPEN invoice_payments(  startdate,
                      enddate,
                      invoiceid,
                      paymentnum,
                      invoicepaymentid);
    END IF;
    FETCH   invoice_payments
    INTO    invoiceid,
          paymentnum,
          checkid  ,
          invoicepaymentid ,
          amount ,
          lastupdatedate,
          setofbooksid,
          postedflag ,
          accountingdate,
          periodname,
          checknumber,
          checkdate,
          paymentlookupcode;

      if invoice_payments%NOTFOUND then
      statuscode := 100;
      end if;
    IF invoice_payments%NOTFOUND  or row_to_fetch = 1 THEN
      CLOSE invoice_payments;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        statuscode := SQLCODE;
  End;  /* End of procedure get_invoice_payment_info */
END GMF_AP_INVOICE_PAYMENTS_INFO;

/
