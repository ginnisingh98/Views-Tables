--------------------------------------------------------
--  DDL for Package Body XTR_TRANS_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_TRANS_INTERFACE" AS
/* $Header: xtrtrinb.pls 120.3 2005/06/29 07:58:26 rjose ship $ */

--
 CURSOR FIND_USER (fnd_user_id in number) is
  select dealer_code
  from xtr_dealer_codes_v
  where user_id = fnd_user_id;

--
 CURSOR IMP_SOURCE is
  select distinct e.SOURCE
   from  XTR_EXT_IMPORT_INTERFACE_V e
   where e.SELECT_FOR_TRANSFER = 'Y'
   and e.TRANSFER_BY = x_user;
--
 CURSOR SOURCE_DET is
  select s.SOURCE,s.TRANSFER_TRAILER_YN,s.REVERSE_ON_TRANSFER_YN,
         s.VERIFY_TRAILER_TOTALS,s.CURRENCY,s.ACCOUNT_NUMBER,
         s.COMPANY_CODE,s.IMPORT_INCLUDES_DECIMAL
   from XTR_SOURCE_OF_IMPORTS_V s
   where s.SOURCE = l_imp_source;
--
 CURSOR TSFR_DATES is
  select distinct CREATION_DATE
   from XTR_EXT_IMPORT_INTERFACE_V
   where SELECT_FOR_TRANSFER = 'Y'
   and TRANSFER_BY = x_user
   and SOURCE = l_source
   and CURRENCY = l_ccy;
--
 CURSOR VERIFY_DR is
  select sum(b.AMOUNT / l_divisor),count(b.TRANSACTION_CODE)
   from XTR_EXT_IMPORT_INTERFACE_V b
   where b.SOURCE = l_source
   and b.CURRENCY = l_ccy
   and b.CREATION_DATE = l_cre_date
   and to_number(b.TRANSACTION_CODE) <= 49
   and b.RECORD_TYPE IN ('1','01');
--
 CURSOR VERIFY_CR is
  select sum(b.AMOUNT / l_divisor),count(b.TRANSACTION_CODE)
   from XTR_EXT_IMPORT_INTERFACE_V b
   where b.SOURCE = l_source
   and b.CURRENCY = l_ccy
   and b.CREATION_DATE = l_cre_date
   and to_number(b.TRANSACTION_CODE) >= 50
   and b.RECORD_TYPE IN ('1','01');
--
 CURSOR TRAILER_TOT is
  select nvl(a.AMOUNT,0) / l_divisor,nvl(a.DEBIT_AMOUNT,0) / l_divisor,
         nvl(a.CREDIT_AMOUNT,0) / l_divisor,
         nvl(a.NUMBER_OF_TRANSACTIONS,0)
   from XTR_EXT_IMPORT_INTERFACE_V a
   where a.SOURCE = l_source
   and a.CURRENCY = l_ccy
   and a.CREATION_DATE = l_cre_date
   and a.RECORD_TYPE IN ('2','02');
--
 CURSOR GET_ACCT is
  select a.ACCOUNT_NUMBER
   from  XTR_EXT_IMPORT_INTERFACE_V a
   where a.SOURCE = l_source
   and a.CURRENCY = l_ccy
   and a.CREATION_DATE = l_cre_date
   and a.RECORD_TYPE IN ('0','00','2','02')
   order by a.RECORD_TYPE asc;
--
 CURSOR CHK_ACCT is
  select 1
   from XTR_BANK_ACCOUNTS_V
   where PARTY_CODE = l_company
   and CURRENCY = l_ccy;
--
 CURSOR TSFR is
  select *
   from XTR_EXT_IMPORT_INTERFACE_V
   where SELECT_FOR_TRANSFER = 'Y'
   and TRANSFER_BY = x_user
   and SOURCE = l_source
   and CREATION_DATE = l_cre_date
   and CURRENCY = l_ccy
   order by SOURCE,RECORD_TYPE
   for update of CREATION_DATE;
--
 CURSOR IMP_NUM is
  select XTR_DEAL_DATE_AMOUNTS_S.NEXTVAL
   from  DUAL;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       transfer_from_interface                                         |
|                                                                       |
|  DESCRIPTION                                                          |
|       Procedure to Transfer Records from the External Interface Table |
|       the interface tables or reconcile a previously imported state-  |
|       ment.                                                           |
|                                                                       |
|  REQUIRES                                                             |
|                                                                       |
|  RETURNS                                                              |
|       errbuf                                                          |
|       retcode                                                         |
|                                                                       |
|  HISTORY                                                              |
 --------------------------------------------------------------------- */



PROCEDURE TRANSFER_FROM_INTERFACE (errbuf       OUT    NOCOPY VARCHAR2,
                                   retcode      OUT    NOCOPY NUMBER,
				   p_source	       VARCHAR2,
                                   p_creation_date     VARCHAR2,
                                   p_currency          VARCHAR2) IS
 row_det        TSFR%rowtype;
 dummy		NUMBER;
 error_msg      VARCHAR2(255);
--
BEGIN

 --
 -- set parameters
 --
 G_source := p_source;
 G_creation_date := to_date(p_creation_date, 'YYYY/MM/DD HH24:MI:SS');
 G_currency := p_currency;

 --
 -- Find the dealer code
 --
 fnd_user_id := FND_GLOBAL.USER_ID;
 open FIND_USER(fnd_user_id);
   fetch FIND_USER into x_user;
 close FIND_USER;

 --
 -- Set value of 'Y' to column 'SELECT_FOR_TRANSFER'
 --    In Table XTR_EXT_IMPORT_INTERFACE_V
 --
   UPDATE XTR_EXT_IMPORT_INTERFACE
    set SELECT_FOR_TRANSFER = 'Y',
        TRANSFER_BY = X_user
    where CREATION_DATE = NVL(G_creation_date, creation_date)
    	and SOURCE = NVL(G_source, source)
        and CURRENCY = NVL(G_currency, currency);


--
-- Transfer
--

 l_error := 0;
 l_count := 0;
 open IMP_SOURCE;
 LOOP
  fetch IMP_SOURCE INTO l_imp_source;
 EXIT WHEN IMP_SOURCE%NOTFOUND;
 open SOURCE_DET;
 LOOP
  fetch SOURCE_DET INTO l_source,l_tsfr_trailer,l_rev_trailer,
                        l_verify_total,l_ccy,l_acct,l_company,l_div;
EXIT WHEN SOURCE_DET%NOTFOUND;
  if l_div = 'Y' then
   l_divisor := 1;
  else
   l_divisor := 100;
  end if;
  open TSFR_DATES;
  LOOP
   fetch TSFR_DATES INTO l_cre_date;
  EXIT WHEN TSFR_DATES%NOTFOUND;
   open GET_ACCT;
    fetch GET_ACCT into l_batch_acct;
   WHILE l_batch_acct is NULL and GET_ACCT%FOUND LOOP
    fetch GET_ACCT into l_batch_acct;
   END LOOP;
   close GET_ACCT;
   if l_batch_acct is NOT NULL then
    open CHK_ACCT;
     fetch CHK_ACCT INTO dummy;
    if CHK_ACCT%NOTFOUND then
     close CHK_ACCT;
     FND_MESSAGE.SET_NAME('XTR','XTR_997');
     error_msg := FND_MESSAGE.GET;
     insert into XTR_IMPORT_TRANSFER_ERRORS_V
      (SOURCE,CREATION_DATE,CURRENCY,NET_AMOUNT,NET_DEBIT_AMOUNT,
       NET_CREDIT_AMOUNT,NET_TRANS_NOS,TRANSFER_ON,TRANSFER_BY,COMMENTS)
     values
     (l_source,l_cre_date,l_ccy,NULL,NULL,NULL,NULL, sysdate, x_user,error_msg);
      l_error := nvl(l_error,0) + 1;

---add
   update XTR_EXT_IMPORT_INTERFACE_V
    set SELECT_FOR_TRANSFER = NULL
    where CREATION_DATE = l_cre_date
    and SOURCE = l_source
    and CURRENCY = l_ccy
    and TRANSFER_BY = x_user;
---
    goto NEXT_TRANSFER;
    end if;
    close CHK_ACCT;
   else
    -- No Batch A/c has been specified
    FND_MESSAGE.SET_NAME('XTR','XTR_998');
    error_msg := FND_MESSAGE.GET;
    insert into XTR_IMPORT_TRANSFER_ERRORS_V
     (SOURCE,CREATION_DATE,CURRENCY,NET_AMOUNT,NET_DEBIT_AMOUNT,
      NET_CREDIT_AMOUNT,NET_TRANS_NOS,TRANSFER_ON,TRANSFER_BY,COMMENTS)
    values
     (l_source,l_cre_date,l_ccy,NULL,NULL,NULL,NULL, sysdate, x_user,error_msg);
      l_error := nvl(l_error,0) + 1;

---add
   update XTR_EXT_IMPORT_INTERFACE_V
    set SELECT_FOR_TRANSFER = NULL
    where CREATION_DATE = l_cre_date
    and SOURCE = l_source
    and CURRENCY = l_ccy
    and TRANSFER_BY = x_user;
---
    goto NEXT_TRANSFER;
   end if;

   if nvl(l_verify_total,'N') = 'Y' then
    open TRAILER_TOT;
     fetch TRAILER_TOT INTO l_total,l_db_total,l_cr_total,l_num_trans;
    if TRAILER_TOT%FOUND then
     -- Control Total exists
     open VERIFY_DR;
      fetch VERIFY_DR INTO l_net_debit,l_dr_trans;
     close VERIFY_DR;
     open VERIFY_CR;
      fetch VERIFY_CR INTO l_net_credit,l_cr_trans;
     close VERIFY_CR;
     l_net_amount := nvl(l_net_debit,0) + nvl(l_net_credit,0);
     l_net_trans  := nvl(l_dr_trans,0) + nvl(l_cr_trans,0);
     if nvl(l_total,0) <> 0 then
      if nvl(l_net_amount,0) <> nvl(l_total,0) then
       l_error := nvl(l_error,0) + 1;
        FND_MESSAGE.SET_NAME('XTR','XTR_999');
        error_msg := FND_MESSAGE.GET;
       insert into XTR_IMPORT_TRANSFER_ERRORS_V
        (SOURCE,CREATION_DATE,CURRENCY,NET_AMOUNT,NET_DEBIT_AMOUNT,
        NET_CREDIT_AMOUNT,NET_TRANS_NOS,TRANSFER_ON,TRANSFER_BY,COMMENTS)
       values
        (l_source,l_cre_date,l_ccy,nvl(l_net_amount,0) - nvl(l_total,0),
         NULL,NULL,NULL, sysdate, x_user,error_msg);

---add
   update XTR_EXT_IMPORT_INTERFACE_V
    set SELECT_FOR_TRANSFER = NULL
    where CREATION_DATE = l_cre_date
    and SOURCE = l_source
    and CURRENCY = l_ccy
    and TRANSFER_BY = x_user;
---
      end if;
     end if;
     if nvl(l_net_debit,0)  <> nvl(l_db_total,0) or
        nvl(l_net_credit,0) <> nvl(l_cr_total,0) or
        nvl(l_net_trans,0)  <> nvl(l_num_trans,0) then
      -- Contains Errors
      FND_MESSAGE.SET_NAME('XTR','XTR_1000');
      error_msg := FND_MESSAGE.GET;
      insert into XTR_IMPORT_TRANSFER_ERRORS_V
       (SOURCE,CREATION_DATE,CURRENCY,NET_AMOUNT,NET_DEBIT_AMOUNT,
        NET_CREDIT_AMOUNT,NET_TRANS_NOS,TRANSFER_ON,TRANSFER_BY,COMMENTS)
      values
       (l_source,l_cre_date,l_ccy,NULL,
        nvl(l_net_debit,0)  - nvl(l_db_total,0),
        nvl(l_net_credit,0) - nvl(l_cr_total,0),
        nvl(l_net_trans,0)  - nvl(l_num_trans,0),
        sysdate, x_user,error_msg);
      l_error := nvl(l_error,0) + 1;

---add
   update XTR_EXT_IMPORT_INTERFACE_V
    set SELECT_FOR_TRANSFER = NULL
    where CREATION_DATE = l_cre_date
    and SOURCE = l_source
    and CURRENCY = l_ccy
    and TRANSFER_BY = x_user;
---

      close TRAILER_TOT;
      goto NEXT_TRANSFER;
     else
     -- No errors in verification therefore do the transfer
      close TRAILER_TOT;
      goto DO_TRANSFER;
     end if;

    else
     -- Verification Reqd but control record (Trailer does not exist).
     l_error := nvl(l_error,0) + 1;
     FND_MESSAGE.SET_NAME('XTR','XTR_1001');
     error_msg := FND_MESSAGE.GET;
     insert into XTR_IMPORT_TRANSFER_ERRORS_V
      (SOURCE,CREATION_DATE,CURRENCY,NET_AMOUNT,NET_DEBIT_AMOUNT,
       NET_CREDIT_AMOUNT,NET_TRANS_NOS,TRANSFER_ON,TRANSFER_BY,COMMENTS)
     values
     (l_source,l_cre_date,l_ccy,NULL,NULL,NULL,NULL, sysdate,
       x_user,error_msg);
     close TRAILER_TOT;
---add
   update XTR_EXT_IMPORT_INTERFACE_V
    set SELECT_FOR_TRANSFER = NULL
    where CREATION_DATE = l_cre_date
    and SOURCE = l_source
    and CURRENCY = l_ccy
    and TRANSFER_BY = x_user;
---
     goto NEXT_TRANSFER;
    end if;
    close TRAILER_TOT;
   end if;
    <<DO_TRANSFER>>
    -- Fetch Unique Import Reference Number for this Import Transfer
    open IMP_NUM;
     fetch IMP_NUM INTO l_import_nos;
    close IMP_NUM;
    -- Transfer Records from Import to Reconciliation Table
    open TSFR;
     LOOP
      fetch TSFR INTO row_det;
     EXIT WHEN TSFR%NOTFOUND;
      if row_det.RECORD_TYPE IN ('0','00') then
       -- Do nothing (Header Record)
        NULL;
      elsif row_det.RECORD_TYPE IN ('1','01') then
       -- Transfer individual Rows
       if to_number(row_det.TRANSACTION_CODE) < 49 then
        row_det.DEBIT_AMOUNT  := row_det.AMOUNT / l_divisor;
        row_det.CREDIT_AMOUNT := NULL;
       else
        row_det.CREDIT_AMOUNT := row_det.AMOUNT / l_divisor;
        row_det.DEBIT_AMOUNT  := NULL;
       end if;
       l_count := l_count + 1;
       insert into XTR_PAY_REC_RECONCILIATION_V
        (IMPORT_REFERENCE,VALUE_DATE,PARTY_NAME,PARTICULARS,
         SERIAL_REFERENCE,RECORD_TYPE,DEBIT_AMOUNT,CREDIT_AMOUNT,
         COMMENTS)
       values
        (l_import_nos,row_det.VALUE_DATE,row_det.PARTY_NAME,
         row_det.PARTICULARS,row_det.SERIAL_REFERENCE,
         row_det.RECORD_TYPE,row_det.DEBIT_AMOUNT,
         row_det.CREDIT_AMOUNT,row_det.COMMENTS);
      elsif row_det.RECORD_TYPE IN ('2','02') then
       -- Insert Trailer Record for later reference
       insert into XTR_IMPORT_TRAILER_DETAILS_V
        (SOURCE,IMPORT_REFERENCE,ACCOUNT_NUMBER,CURRENCY,CREATION_DATE)
       values
       (l_source,l_import_nos,nvl(l_batch_acct,l_acct),l_ccy,l_cre_date);
       -- Transfer Trailer Record if Required
       -- (As specified in the Source Setup).
       if row_det.RECORD_TYPE in('2','02') and  upper(nvl(l_tsfr_trailer,'N')) =
         'Y' then
        -- Reverse Trailer Record if Required
        -- (As specified in the Source Setup).
        if upper(nvl(l_rev_trailer,'N')) = 'Y' then
         l_debit := row_det.DEBIT_AMOUNT / l_divisor;
         row_det.DEBIT_AMOUNT  := row_det.CREDIT_AMOUNT / l_divisor;
         row_det.CREDIT_AMOUNT := l_debit;
        end if;
         if  row_det.DEBIT_AMOUNT=0 then
             row_det.DEBIT_AMOUNT :=NULL;
         end if;
         if  row_det.CREDIT_AMOUNT=0 then
             row_det.CREDIT_AMOUNT :=NULL;
         end if;
        -- Insert Trailer Record for into Reconciliation table
        l_count := l_count + 1;
        insert into XTR_PAY_REC_RECONCILIATION_V
         (IMPORT_REFERENCE,VALUE_DATE,PARTY_NAME,PARTICULARS,
          SERIAL_REFERENCE,RECORD_TYPE,DEBIT_AMOUNT,CREDIT_AMOUNT,
          COMMENTS)
        values
         (l_import_nos,row_det.VALUE_DATE,row_det.PARTY_NAME,
          row_det.PARTICULARS,row_det.SERIAL_REFERENCE,
          row_det.RECORD_TYPE,row_det.DEBIT_AMOUNT,
          row_det.CREDIT_AMOUNT,row_det.COMMENTS);
       end if;
  end if;
    /* Do Not Delete for Test purposes*/
      -- Delete Successful transfer from Interface Table
      delete from XTR_EXT_IMPORT_INTERFACE_V
       where SELECT_FOR_TRANSFER = 'Y'
       and CREATION_DATE = row_det.CREATION_DATE
       and SOURCE = row_det.SOURCE
       and TRANSFER_BY = row_det.TRANSFER_BY;
     END LOOP;
     close TSFR;
   <<NEXT_TRANSFER>>
   NULL;
  END LOOP;
  close TSFR_DATES;
 END LOOP;
 close SOURCE_DET;
 END LOOP;
 close IMP_SOURCE;

/*
 if nvl(l_error,0) = 0 then
  ---DISP_WARN(982);-- Processing Complete without errors
  --alert_message(3,'Processing Complete without errors.');
  DISP_WARN('XTR_1547');
 else
  bell;
  --alert_message(3,'APP-983 Processing Complete WITH '||to_char(l_error)||
  --        ' ERROR(s).');
  DISP_WARN('XTR_1548');
 end if;
*/

EXCEPTION
  WHEN OTHERS THEN
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('EXCEPTION: XTR_TRANS_INTERFACE.transfer_from_interface');
    END IF;
    RAISE;
END TRANSFER_FROM_INTERFACE;

END XTR_TRANS_INTERFACE;

/
