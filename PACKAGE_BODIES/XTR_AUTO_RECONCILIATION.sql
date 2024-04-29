--------------------------------------------------------
--  DDL for Package Body XTR_AUTO_RECONCILIATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_AUTO_RECONCILIATION" AS
/* $Header: xtrarecb.pls 120.11.12010000.5 2009/11/04 21:40:20 srsampat ship $ */

--
 CURSOR IMREF IS
  select sim.verification_method,
         are.import_reference,
         itr.currency,
         itr.account_number
  from xtr_source_of_imports_v sim,
       xtr_available_for_recon_v are,
       xtr_import_trailer_details_v itr
  where sim.source = itr.source
        AND are.import_reference = itr.import_reference
        AND are.import_reference >= NVL(G_import_reference_from, are.import_reference)
        AND are.import_reference <= NVL(G_import_reference_to, are.import_reference);


 CURSOR ACCT_INFO IS
  select distinct sim.verification_method,
         are.import_reference,
         itr.currency,
         itr.account_number
  from xtr_source_of_imports_v sim,
       xtr_available_for_recon_v are,
       xtr_import_trailer_details_v itr,
       XTR_PAY_REC_RECONCILIATION_V prr
  where sim.source = itr.source
        AND are.import_reference = itr.import_reference
        AND prr.import_reference = are.import_reference
        AND prr.import_reference = itr.import_reference
        AND itr.account_number = NVL(G_acct_num, itr.account_number)
        AND sim.source = NVL(G_source, sim.source)
--* bug#2464159, rravunny
--* changed the condition
        AND prr.value_date between
            least(nvl(date_from,prr.value_date),nvl(date_to,prr.value_date))
            and
            greatest(nvl(date_from,prr.value_date),nvl(date_to,prr.value_date));
--        AND to_char(prr.value_date, 'DD/MM/RRRR') >= NVL(date_from, to_char(prr.value_date, 'DD/MM/RRRR'))
--        AND to_char(prr.value_date, 'DD/MM/RRRR') <= NVL(date_to, to_char(prr.value_date, 'DD/MM/RRRR'));


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       auto_reconciliation                                             |
|                                                                       |
|  DESCRIPTION                                                          |
|       Procedure to Automatically Reconcile Statements		        |
|                                                                       |
|  REQUIRES                                                             |
|       import reference from						|
|       import_reference_to						|
|	acct_num							|
|	source   							|
|	value_date_from							|
|	value_date_to							|
|	incl_rtm							|
|									|
|  RETURNS                                                              |
|       errbuf                                                          |
|       retcode                                                         |
|                                                                       |
|  HISTORY                                                              |
 --------------------------------------------------------------------- */



PROCEDURE AUTO_RECONCILIATION  (errbuf       OUT  NOCOPY  VARCHAR2,
                                retcode      OUT  NOCOPY NUMBER,
                                p_source            VARCHAR2,
                                p_acct_num          VARCHAR2,
                                p_value_date_from   VARCHAR2,
                                p_value_date_to     VARCHAR2,
                                p_import_reference_from NUMBER,
                                p_import_reference_to   NUMBER,
                                p_incl_rtm          VARCHAR2 ) IS

x_pass_code		VARCHAR2(20);
x_record_in_process 	NUMBER;
x_party_name		VARCHAR2(20);
x_serial_reference	VARCHAR2(12);
x_debit_amount		NUMBER;
x_credit_amount		NUMBER;
x_reconciled_YN		VARCHAR2(1);
x_min_rec_nos		NUMBER;
x_max_rec_nos		NUMBER;
x_rec_num		NUMBER;
x_tot_recon		NUMBER;

--
BEGIN
 -- cep_standard.enable_debug;
 IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
    xtr_debug_pkg.debug('>XTR_AUTO_RECONCILIATION.auto_reconciliation');
    xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '>set parameters...');
 END IF;
 --
 -- set parameters
 --
 G_import_reference_from := p_import_reference_from;
 G_import_reference_to := p_import_reference_to;
 G_source := p_source;
 G_acct_num := p_acct_num;
 G_value_date_from := to_date(p_value_date_from, 'YYYY/MM/DD HH24:MI:SS');
 G_value_date_to := to_date(p_value_date_to, 'YYYY/MM/DD HH24:MI:SS');
 date_from := to_date(G_value_date_from, 'DD/MM/RRRR');
 date_to := to_date(G_value_date_to, 'DD/MM/RRRR');
 G_incl_rtm := p_incl_rtm;

 IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
    xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_import_reference_from = ' || to_char(G_import_reference_from));
    xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_import_reference_to = ' || to_char(G_import_reference_to));
    xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_source = ' || G_source);
    xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_acct_num = ' || G_acct_num);
    xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_value_date_from = ' || G_value_date_from);
    xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_value_date_to = ' || G_value_date_to);
    xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_incl_rtm = ' || G_incl_rtm);
 END IF;

 IF (G_import_reference_to IS NOT NULL
	OR G_import_reference_from IS NOT NULL) THEN
	--
	-- if user specify import reference number
	--   as auto reconciliation drive and not account information
	--
 	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
 	   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '>OPEN CURSOR IMREF');
 	END IF;

  	OPEN IMREF;

	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '>> LOOP ');
	END IF;
 	LOOP
  	   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
  	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '>>FETCH CURSOR IMREF');
  	   END IF;
 	   Fetch IMREF into G_verification_method,
			    G_import_reference,
			    G_currency,
			    G_account_number;
 	   EXIT WHEN IMREF%NOTFOUND;

	   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	      xtr_debug_pkg.debug('>>call XTR_AUTO_RECONCILIATION.P_RECONCILE...');
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '>>pass in -----------> ');
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_verfication_method ' || G_verification_method);
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_import_reference ' || to_char(G_import_reference));
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_currency ' || G_currency);
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_account_number ' || G_account_number);
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_incl_rtm ' || G_incl_rtm);
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '----------------> end pass in parameters');
	   END IF;

           XTR_AUTO_RECONCILIATION.P_RECONCILE ( G_verification_method,
				    x_pass_code,
				    G_import_reference,
				    G_currency,
				    sysdate,
				    G_account_number,
				    x_record_in_process,
				    x_party_name,
				    x_serial_reference,
				    x_debit_amount,
				    x_credit_amount,
				    x_reconciled_YN,
				    x_min_rec_nos,
				    x_max_rec_nos,
				    x_rec_num,
			   	    x_tot_recon,
				    G_incl_rtm);

       	 	IF (x_rec_num IS NOT NULL AND NVL(G_incl_rtm, 'Y') = 'Y') THEN

			IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
			   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '>> call UPDATE_ROLL_TRANS -------->');
			   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'x_min_rec_nos = ' || to_char(x_min_rec_nos));
			   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'x_max_rec_nos = ' || to_char(x_max_rec_nos));
			END IF;

		 	UPDATE_ROLL_TRANS( G_verification_method,
					   x_min_rec_nos,
					   x_max_rec_nos,
					   'AUTO');
		END IF;

	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '> END LOOP ');
	END IF;
	END LOOP;
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '> CLOSE CURSOR IMREF ');
	END IF;
        CLOSE IMREF;
 ELSE --
      -- if user specify account information
      --   and not by import reference #
      --
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '> OPEN CURSOR ACCT_INFO ');
	END IF;
  	OPEN ACCT_INFO;

	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '>> LOOP ');
	END IF;
 	LOOP
	   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '>> FETCH CURSOR ACCT_INFO ');
	   END IF;
  	   Fetch ACCT_INFO into G_verification_method,
			    G_import_reference,
			    G_currency,
			    G_account_number;
 	   EXIT WHEN ACCT_INFO%NOTFOUND;

	   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	      xtr_debug_pkg.debug('>>call XTR_AUTO_RECONCILIATION.P_RECONCILE...');
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '>>pass in -----------> ');
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_verfication_method ' || G_verification_method);
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_import_reference ' || to_char(G_import_reference));
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_currency ' || G_currency);
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_account_number ' || G_account_number);
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'G_incl_rtm ' || G_incl_rtm);
	      xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '----------------> end pass in parameters');
	   END IF;

           XTR_AUTO_RECONCILIATION.P_RECONCILE ( G_verification_method,
				    x_pass_code,
				    G_import_reference,
				    G_currency,
				    sysdate,
				    G_account_number,
				    x_record_in_process,
				    x_party_name,
				    x_serial_reference,
				    x_debit_amount,
				    x_credit_amount,
				    x_reconciled_YN,
				    x_min_rec_nos,
				    x_max_rec_nos,
				    x_rec_num,
			   	    x_tot_recon,
				    G_incl_rtm);

       	 	IF (x_rec_num IS NOT NULL AND NVL(G_incl_rtm, 'Y') = 'Y') THEN

			IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
			   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '>> call UPDATE_ROLL_TRANS -------->');
			   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'x_min_rec_nos = ' || to_char(x_min_rec_nos));
			   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || 'x_max_rec_nos = ' || to_char(x_max_rec_nos));
			END IF;

		 	UPDATE_ROLL_TRANS( G_verification_method,
					   x_min_rec_nos,
					   x_max_rec_nos,
					   'AUTO');
		END IF;

	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '> END LOOOP ');
	END IF;
	END LOOP;
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('AUTO_RECONCILIATION: ' || '> CLOSE CURSOR ACCT_INFO');
	END IF;
        CLOSE ACCT_INFO;

 END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('EXCEPTION: XTR_AUTO_RECONCILIATION.auto_reconciliation');
    END IF;
    RAISE;
END AUTO_RECONCILIATION;

-- ER 7601596 Start Added procedure REVERSE_ROLL_TRANS_RTMM and UPDATE_ROLL_TRANS_RTMM

PROCEDURE REVERSE_ROLL_TRANS_RTMM (p_verification_method	VARCHAR2,
			     p_min_rec_nos		NUMBER,
			     p_max_rec_nos		NUMBER,
			     p_calling_method           VARCHAR2,
			     p_val_date DATE) IS

		    --
       l_subtype      VARCHAR2(7);
       l_date         DATE;
       l_count        NUMBER;
       l_ccy          VARCHAR2(15);
       l_start_date   DATE;
       l_deal_no      NUMBER;
       l_trans_no     NUMBER;
       l_amount       NUMBER;
       old_deal_no    NUMBER;
--
       l_rec_ref    NUMBER;
       l_rec_pass   varchar2(2);
       old_rec_ref    NUMBER;
       old_rec_pass   varchar2(2);
       old_trans_no     NUMBER;
--
       l_lowest_start DATE;
      --
       cursor DDA_REC_ROW is
        select DEAL_NUMBER,TRANSACTION_NUMBER,AMOUNT,AMOUNT_DATE,
               RECONCILED_REFERENCE,RECONCILED_PASS_CODE --reset -- AW 1/6/2000 Bug 1139396
         from XTR_DEAL_DATE_AMOUNTS_V
         where RECONCILED_REFERENCE between
          to_number(nvl(p_min_rec_nos,9999999)) and
          to_number(nvl(p_max_rec_nos,0))
---         and AMOUNT_TYPE = 'PRINFLW'
         and DATE_TYPE = 'SETTLE'
         and nvl(amount,0) <> 0
         order by DEAL_NUMBER,TRANSACTION_NUMBER;
      --
       cursor S_DATE is
        select START_DATE,CURRENCY,DEAL_SUBTYPE
         from XTR_ROLLOVER_TRANSACTIONS_V
         where DEAL_NUMBER = l_deal_no
         and TRANSACTION_NUMBER = l_trans_no;
      --
      begin


       open DDA_REC_ROW;
       l_count := 0;
       LOOP
        fetch DDA_REC_ROW INTO l_deal_no,l_trans_no,l_amount,l_date,l_rec_ref,l_rec_pass;
       EXIT WHEN DDA_REC_ROW%NOTFOUND;
        l_count := l_count + 1;
        if l_count <> 1 then
         if old_deal_no <> l_deal_no then
          -- Reconciled Deal has changed therefore recalc rollover records
          -- using the old deal no, update rows where the start date >=
          -- the lowest start date for this deal
          --RECALC_ROLL_DETAILS(old_deal_no,l_subtype,l_lowest_start,l_ccy,old_trans_no,old_rec_ref,old_rec_pass);
	  XTR_AUTO_RECONCILIATION.recalc_roll_details(old_deal_no,
							l_subtype,
							l_lowest_start,
							l_ccy,
							old_trans_no,
							old_rec_ref,
							old_rec_pass);
          l_lowest_start := NULL;
         end if;
        end if;
        update XTR_DEAL_DATE_AMOUNTS_V
         set AMOUNT = 0,
             CASHFLOW_AMOUNT = 0,
             DATE_TYPE = 'FORCAST' -- AW 1/6/2000 Bug 1139396
         where DEAL_NUMBER = l_deal_no
         and TRANSACTION_NUMBER = l_trans_no
         and nvl(ACTION_CODE,'@#@') <>'INCRSE'
         and DATE_TYPE = 'SETTLE'; -- AW 1/6/2000 Bug 1139396
        --
        update XTR_ROLLOVER_TRANSACTIONS_V
         set PI_AMOUNT_RECEIVED = NULL,
             SETTLE_DATE = NULL
         where DEAL_NUMBER = l_deal_no
         and TRANSACTION_NUMBER = l_trans_no;
/*
         and SETTLE_DATE = l_date
         and PI_AMOUNT_RECEIVED = l_amount;
*/

        -- Ensure only record the lowest start date for this deal
        open S_DATE;
         fetch S_DATE INTO l_start_date,l_ccy,l_subtype;
        close S_DATE;
        if l_lowest_start is NULL then
         l_lowest_start := l_start_date;
        elsif l_start_date < l_lowest_start then
         l_lowest_start := l_start_date;
        end if;
        -- Store previous deal to compare with the fetch for the next deal
        old_deal_no := l_deal_no;
        old_trans_no := l_trans_no;
        old_rec_ref :=l_rec_ref;
        old_rec_pass :=l_rec_pass;

       END LOOP;

-- add
       if old_deal_no is not null then
       -- Recalc Rollover Transactions for the Last deal fetched
       -- ie the recalc did not occur within the LOOP
       XTR_AUTO_RECONCILIATION.RECALC_ROLL_DETAILS(old_deal_no,
						   l_subtype,
						   l_lowest_start,
						   l_ccy,
						   old_trans_no,
						   old_rec_ref,
						   old_rec_pass);
       end if;

       close DDA_REC_ROW;
        end;

PROCEDURE UPDATE_ROLL_TRANS_RTMM (p_verification_method	VARCHAR2,
			     p_min_rec_nos		NUMBER,
			     p_max_rec_nos		NUMBER,
			     p_calling_method           VARCHAR2,
			     p_val_date DATE) IS
--
       l_min_rec_nos  NUMBER;
       l_max_rec_nos  NUMBER;
--
       l_subtype      VARCHAR2(7);
       l_date         DATE;
       l_settle_date  DATE;
       l_count        NUMBER;
       l_ccy          VARCHAR2(15);
       l_start_date   DATE;
       l_deal_no      NUMBER;
       l_trans_no     NUMBER;
       l_amount       NUMBER;
       old_deal_no    NUMBER;
--
       l_rec_ref      NUMBER;
       l_rec_pass     VARCHAR2(2);
       old_rec_ref    NUMBER;
       old_rec_pass   VARCHAR2(2);
       old_trans_no   NUMBER;
--
       l_lowest_start DATE;

---------
       CURSOR DDA_REC_ROW is
        select dda.DEAL_NUMBER, dda.TRANSACTION_NUMBER, dda.AMOUNT, dda.AMOUNT_DATE,
               dda.RECONCILED_REFERENCE,substr(dda.RECONCILED_PASS_CODE,2) ---reset
         from XTR_DEAL_DATE_AMOUNTS_V dda
         where dda.RECONCILED_REFERENCE between
               nvl(L_MIN_REC_NOS,9999999) and  nvl(L_MAX_REC_NOS,0)
         and  dda.DEAL_TYPE = 'RTMM'
         and  nvl(dda.amount,0) <>0
	 and  dda.DATE_TYPE <> 'COMENCE'  -- bug 3045394
--         and  substr( nvl(dda.RECONCILED_PASS_CODE, '@'), 1, 1) = '^'
  	 and  ( nvl(p_calling_method, 'AUTO') = 'MANUAL' OR
	        exists(select 'anyrow'
		 from   XTR_RECONCILIATION_PROCESS rp
		 where  rp.VERIFICATION_METHOD = nvl(p_verification_method,rp.VERIFICATION_METHOD)
		 and    rp.RECONCILED_PASS_CODE = substr(dda.RECONCILED_PASS_CODE,2)
		 and 	nvl(rp.PROCESS_TYPE, 'M') = 'A'))
         order by DEAL_NUMBER,TRANSACTION_NUMBER;
      --
       CURSOR S_DATE is
        select START_DATE,CURRENCY,DEAL_SUBTYPE
         from XTR_ROLLOVER_TRANSACTIONS_V
         where DEAL_NUMBER = l_deal_no
         and TRANSACTION_NUMBER = l_trans_no;
    -- Created cursor Bug 4226409
       CURSOR SETTLE_DATE(p_rec_ref NUMBER) is
       SELECT effective_date FROM ce_statement_lines WHERE  statement_line_id IN (
SELECT statement_line_id FROM ce_statement_reconcils_all WHERE reference_id in
(SELECT settlement_summary_id FROM xtr_settlement_summary WHERE settlement_number
IN (SELECT settlement_number FROM xtr_deal_date_amounts WHERE reconciled_reference = p_rec_ref  )));
/*	select VALUE_DATE
        from XTR_PAY_REC_RECONCILIATION_V
        where RECONCILED_REFERENCE = p_rec_ref ; */
      --
BEGIN
       -- set parameters
       --
       l_min_rec_nos := p_min_rec_nos;
       l_max_rec_nos := p_max_rec_nos;


       OPEN DDA_REC_ROW;

       l_count := 0;
       LOOP

	FETCH DDA_REC_ROW INTO l_deal_no,l_trans_no,l_amount,l_date,l_rec_ref,l_rec_pass;

        EXIT WHEN DDA_REC_ROW%NOTFOUND;

        l_count := l_count + 1;
        IF l_count <> 1 then
	  IF old_deal_no <> l_deal_no THEN
            -- Reconciled Deal has changed therefore recalc rollover records
            -- using the old deal no, update rows where the start date >=
            -- the lowest start date for this deal


	    XTR_AUTO_RECONCILIATION.RECALC_ROLL_DETAILS(old_deal_no,
				l_subtype,
				l_lowest_start,
				l_ccy,
				old_trans_no,
				old_rec_ref,
				old_rec_pass);
            l_lowest_start := NULL;
         END IF;
        END IF;

-- Modified Bug 4226409
l_settle_date := p_val_date;


	UPDATE XTR_ROLLOVER_TRANSACTIONS_V
         SET PI_AMOUNT_RECEIVED = l_amount,
             MATURITY_DATE = l_date,
             SETTLE_DATE = l_settle_date
         WHERE DEAL_NUMBER = l_deal_no
         	and TRANSACTION_NUMBER = l_trans_no;

        -- Ensure only record the lowest start date for this deal
        OPEN S_DATE;
         FETCH S_DATE INTO l_start_date,l_ccy,l_subtype;
        CLOSE S_DATE;
        IF l_lowest_start is NULL then
         l_lowest_start := l_start_date;
        ELSIF l_start_date < l_lowest_start then
         l_lowest_start := l_start_date;
        END IF;

	-- Store previous deal to compare with the fetch for the next deal
IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   xtr_debug_pkg.debug('UPDATE_ROLL_TRANS: ' || 'old_rec_ref = ' ||to_char(l_rec_ref));
END IF;
        old_deal_no := l_deal_no;
        old_trans_no := l_trans_no;
        old_rec_ref :=l_rec_ref;
        old_rec_pass :=l_rec_pass;

       END LOOP;
-- add
       IF old_deal_no is not null then
         -- Recalc Rollover Transactions for the Last deal fetched
         -- ie the recalc did not occur within the LOOP


	 XTR_AUTO_RECONCILIATION.RECALC_ROLL_DETAILS(   old_deal_no,
				l_subtype,
				l_lowest_start,
				l_ccy,
				old_trans_no,
				old_rec_ref,
				old_rec_pass);

      END IF;
--
      CLOSE DDA_REC_ROW;
EXCEPTION
  WHEN OTHERS THEN
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('EXCEPTION: XTR_AUTO_RECONCILIATION.update_roll_trans');
    END IF;
    RAISE;
END UPDATE_ROLL_TRANS_RTMM;

-- ER 7601596 End

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       update_roll_trans                                               |
|                                                                       |
|  DESCRIPTION                                                          |
|       Updates Rollover Transaction Table                              |
|                                                                       |
|  REQUIRES                                                             |
|	p_min_rec_nos							|
|       p_max_rec_nos							|
|									|
|  RETURNS                                                              |
|                                                                       |
|  HISTORY                                                              |
 --------------------------------------------------------------------- */
PROCEDURE UPDATE_ROLL_TRANS (p_verification_method	VARCHAR2,
			     p_min_rec_nos		NUMBER,
			     p_max_rec_nos		NUMBER,
			     p_calling_method           VARCHAR2) IS
--
       l_min_rec_nos  NUMBER;
       l_max_rec_nos  NUMBER;
--
       l_subtype      VARCHAR2(7);
       l_date         DATE;
       l_settle_date  DATE;
       l_count        NUMBER;
       l_ccy          VARCHAR2(15);
       l_start_date   DATE;
       l_deal_no      NUMBER;
       l_trans_no     NUMBER;
       l_amount       NUMBER;
       old_deal_no    NUMBER;
--
       l_rec_ref      NUMBER;
       l_rec_pass     VARCHAR2(2);
       old_rec_ref    NUMBER;
       old_rec_pass   VARCHAR2(2);
       old_trans_no   NUMBER;
--
       l_lowest_start DATE;

---------
       CURSOR DDA_REC_ROW is
        select dda.DEAL_NUMBER, dda.TRANSACTION_NUMBER, dda.AMOUNT, dda.AMOUNT_DATE,
               dda.RECONCILED_REFERENCE,substr(dda.RECONCILED_PASS_CODE,2) ---reset
         from XTR_DEAL_DATE_AMOUNTS_V dda
         where dda.RECONCILED_REFERENCE between
               nvl(L_MIN_REC_NOS,9999999) and  nvl(L_MAX_REC_NOS,0)
         and  dda.DEAL_TYPE = 'RTMM'
         and  nvl(dda.amount,0) <>0
	 and  dda.DATE_TYPE <> 'COMENCE'  -- bug 3045394
--         and  substr( nvl(dda.RECONCILED_PASS_CODE, '@'), 1, 1) = '^'
  	 and  ( nvl(p_calling_method, 'AUTO') = 'MANUAL' OR
	        exists(select 'anyrow'
		 from   XTR_RECONCILIATION_PROCESS rp
		 where  rp.VERIFICATION_METHOD = nvl(p_verification_method,rp.VERIFICATION_METHOD)
		 and    rp.RECONCILED_PASS_CODE = substr(dda.RECONCILED_PASS_CODE,2)
		 and 	nvl(rp.PROCESS_TYPE, 'M') = 'A'))
         order by DEAL_NUMBER,TRANSACTION_NUMBER;
      --
       CURSOR S_DATE is
        select START_DATE,CURRENCY,DEAL_SUBTYPE
         from XTR_ROLLOVER_TRANSACTIONS_V
         where DEAL_NUMBER = l_deal_no
         and TRANSACTION_NUMBER = l_trans_no;
    -- Created cursor Bug 4226409
       CURSOR SETTLE_DATE(p_rec_ref NUMBER) is
        select VALUE_DATE
        from XTR_PAY_REC_RECONCILIATION_V
        where RECONCILED_REFERENCE = p_rec_ref ;
      --
BEGIN
       -- set parameters
       --
       l_min_rec_nos := p_min_rec_nos;
       l_max_rec_nos := p_max_rec_nos;

       OPEN DDA_REC_ROW;
       l_count := 0;
       LOOP
        FETCH DDA_REC_ROW INTO l_deal_no,l_trans_no,l_amount,l_date,l_rec_ref,l_rec_pass;
        EXIT WHEN DDA_REC_ROW%NOTFOUND;
        l_count := l_count + 1;
        IF l_count <> 1 then
	  IF old_deal_no <> l_deal_no THEN
            -- Reconciled Deal has changed therefore recalc rollover records
            -- using the old deal no, update rows where the start date >=
            -- the lowest start date for this deal
	    XTR_AUTO_RECONCILIATION.RECALC_ROLL_DETAILS(old_deal_no,
				l_subtype,
				l_lowest_start,
				l_ccy,
				old_trans_no,
				old_rec_ref,
				old_rec_pass);
            l_lowest_start := NULL;
         END IF;
        END IF;

        OPEN SETTLE_DATE(l_rec_ref);
        FETCH SETTLE_DATE INTO l_settle_date;
        CLOSE SETTLE_DATE;
-- Modified Bug 4226409
        UPDATE XTR_ROLLOVER_TRANSACTIONS_V
         SET PI_AMOUNT_RECEIVED = l_amount,
             MATURITY_DATE = l_date,
             SETTLE_DATE = l_settle_date
         WHERE DEAL_NUMBER = l_deal_no
         	and TRANSACTION_NUMBER = l_trans_no;

        -- Ensure only record the lowest start date for this deal
        OPEN S_DATE;
         FETCH S_DATE INTO l_start_date,l_ccy,l_subtype;
        CLOSE S_DATE;
        IF l_lowest_start is NULL then
         l_lowest_start := l_start_date;
        ELSIF l_start_date < l_lowest_start then
         l_lowest_start := l_start_date;
        END IF;
        -- Store previous deal to compare with the fetch for the next deal
IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   xtr_debug_pkg.debug('UPDATE_ROLL_TRANS: ' || 'old_rec_ref = ' ||to_char(l_rec_ref));
END IF;
        old_deal_no := l_deal_no;
        old_trans_no := l_trans_no;
        old_rec_ref :=l_rec_ref;
        old_rec_pass :=l_rec_pass;

       END LOOP;
-- add
       IF old_deal_no is not null then
         -- Recalc Rollover Transactions for the Last deal fetched
         -- ie the recalc did not occur within the LOOP
         XTR_AUTO_RECONCILIATION.RECALC_ROLL_DETAILS(   old_deal_no,
				l_subtype,
				l_lowest_start,
				l_ccy,
				old_trans_no,
				old_rec_ref,
				old_rec_pass);

      END IF;
--
      CLOSE DDA_REC_ROW;
EXCEPTION
  WHEN OTHERS THEN
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('EXCEPTION: XTR_AUTO_RECONCILIATION.update_roll_trans');
    END IF;
    RAISE;
END UPDATE_ROLL_TRANS;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       RECALC_ROLL_DETAILS                                             |
|                                                                       |
|  DESCRIPTION                                                          |
|       Recalculate Rollover Transactions                               |
|                                                                       |
|  REQUIRES                                                             |
|       p_deal_no						        |
|       p_subtype							|
|	p_start_date							|
|	p_ccy								|
|	p_trans_no							|
|	p_rec_ref							|
|	p_rec_pass							|
|									|
|  RETURNS                                                              |
|                                                                       |
|  HISTORY                                                              |
 --------------------------------------------------------------------- */
PROCEDURE RECALC_ROLL_DETAILS(p_deal_no		NUMBER,
			      p_subtype		VARCHAR2,
			      p_start_date	DATE,
			      p_ccy		VARCHAR2,
			      p_trans_no	NUMBER,
			      p_rec_ref		NUMBER,
			      p_rec_pass	VARCHAR2) IS
--
 l_deal_no	NUMBER;
 l_subtype	VARCHAR2(7);
 l_start_date	DATE;
 l_ccy	        VARCHAR2(15);
 l_trans_no	NUMBER;
 l_rec_ref	NUMBER;
 l_rec_pass  	VARCHAR2(2);
--
 l_cparty         VARCHAR2(7);
 l_client         VARCHAR2(7);
 l_company        VARCHAR2(7);
 l_cparty_acct    VARCHAR2(20);
 l_dealer         VARCHAR2(10);
 l_product        VARCHAR2(10);
 l_portfolio      VARCHAR2(7);
 l_settle_acct    VARCHAR2(20);
 l_maturity       DATE;
 l_deal_date      DATE;
 l_limit_code     VARCHAR2(7);
--
 cursor DET is
  select MATURITY_DATE,CPARTY_CODE,CLIENT_CODE,PRODUCT_TYPE,
         PORTFOLIO_CODE,SETTLE_ACCOUNT_NO,CPARTY_REF,
         COMPANY_CODE,DEALER_CODE,DEAL_DATE,LIMIT_CODE
   from  XTR_DEALS_V
   where DEAL_NO = l_deal_no
   and deal_type = 'RTMM';
--
begin
 l_deal_no     := p_deal_no;
 l_subtype     := p_subtype;
 l_start_date  := p_start_date;
 l_ccy         := p_ccy;
 l_trans_no    := p_trans_no;
 l_rec_ref     := p_rec_ref;
 l_rec_pass    := p_rec_pass;
 -- Call the procedure to recalc details (This procedure will be a stored
 -- procedure that both this form and pro0235 will use for recalc
 -- of details.
 open DET;
  fetch DET into l_maturity,l_cparty,l_client,l_product,
                 l_portfolio,l_settle_acct,l_cparty_acct,
                 l_company,l_dealer,l_deal_date,l_limit_code;
 close DET;
 --
 if l_deal_no is NOT NULL then
  XTR_AUTO_RECONCILIATION.RECALC_DT_DETAILS
                               (l_deal_no,
				l_deal_date,
				l_company,
				l_subtype,
				l_product,
                          	l_portfolio,
				l_ccy,
				l_maturity,
				l_settle_acct,
				l_cparty,
                          	l_client,
				l_cparty_acct,
				l_dealer,
				'N',
				l_start_date,
                          	l_trans_no,
				l_rec_ref,
				l_rec_pass,
				l_limit_code);
 END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('EXCEPTION: XTR_AUTO_RECONCILIATION.recalc_roll_details');
    END IF;
    RAISE;
END RECALC_ROLL_DETAILS;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       RECALC_DT_DETAILS                                               |
|                                                                       |
|  DESCRIPTION                                                          |
|       Recalculate Details                                             |
|                                                                       |
|  REQUIRES                                                             |
|	p_deal_no							|
|	p_deal_date							|
|	p_company							|
|	p_subtype							|
|	p_product							|
|	p_portfolio							|
|	p_ccy								|
|	p_maturity							|
|	p_settle_acct							|
|	p_cparty							|
|	p_client							|
|	p_cparty_acct							|
|	p_dealer							|
|	p_least_inserted						|
|	p_ref_date							|
|	p_trans_no							|
|	p_rec_ref							|
|	p_rec_pass							|
|	p_limit_code							|
|									|
|  RETURNS                                                              |
|                                                                       |
|  HISTORY                                                              |
 --------------------------------------------------------------------- */
PROCEDURE RECALC_DT_DETAILS (p_deal_no         NUMBER,
                             p_deal_date       DATE,
                             p_company         VARCHAR2,
                             p_subtype         VARCHAR2,
                             p_product         VARCHAR2,
                             p_portfolio       VARCHAR2,
                             p_ccy             VARCHAR2,
                             p_maturity        DATE,
                             p_settle_acct     VARCHAR2,
                             p_cparty          VARCHAR2,
                             p_client          VARCHAR2,
                             p_cparty_acct     VARCHAR2,
                             p_dealer          VARCHAR2,
                             p_least_inserted  VARCHAR2,
                             p_ref_date        DATE,
                             p_trans_no        NUMBER,
                             p_rec_ref         NUMBER,
                             p_rec_pass        VARCHAR2,
                             p_limit_code      VARCHAR2 ) IS
--
 l_deal_no	NUMBER;
 l_deal_date	DATE;
 l_company	VARCHAR2(7);
 l_subtype	VARCHAR2(7);
 l_product	VARCHAR2(10);
 l_portfolio	VARCHAR2(7);
 l_ccy		VARCHAR2(15);
 l_maturity	DATE;
 l_settle_acct	VARCHAR2(20);
 l_cparty	VARCHAR2(7);
 l_client	VARCHAR2(7);
 l_cparty_acct	VARCHAR2(20);
 l_dealer	VARCHAR2(10);
 l_least_inserted VARCHAR2(1);
 l_ref_date	DATE;
 l_trans_no	NUMBER;
 l_rec_ref	NUMBER;
 l_rec_pass	VARCHAR2(2);
 l_limit_code  	VARCHAR2(7);
--
 l_comments       VARCHAR2(30);
 l_nill_date      DATE;
 l_compound       VARCHAR2(7);
 l_prv_row_exists VARCHAR2(1);
 l_start_date     DATE;
 l_prin_decr      NUMBER;
 new_exp_bal      NUMBER;
 new_accum_int    NUMBER;
 new_balbf        NUMBER;
 new_start_date   DATE;
 rounding_fac     NUMBER;
 l_hce_rate       NUMBER;
 hce_interest     NUMBER;
 hce_settled      NUMBER;
 hce_accum_int_bf NUMBER;
 hce_decr         NUMBER;
 hce_accum_int    NUMBER;
 hce_balbf        NUMBER;
 hce_balos        NUMBER;
 hce_princ        NUMBER;
 hce_due          NUMBER;
 l_exp_int        NUMBER;
 l_cum_int        NUMBER;
 l_prin_adj       NUMBER;
 l_no_of_days     NUMBER;
 l_year_basis     NUMBER;
 l_year_calc_type VARCHAR2(20);
 --
 cursor RND_YR is
  select ROUNDING_FACTOR
   from  XTR_MASTER_CURRENCIES_V
   where CURRENCY = l_ccy;
 --
 cursor GET_YEAR_CALC_TYPE is
  select YEAR_CALC_TYPE
   from XTR_DEALS_V
   where DEAL_NO = l_deal_no;
 --
 cursor DT_HOME_RATE is
  select nvl(a.HCE_RATE,1) HCE_RATE
   from  XTR_MASTER_CURRENCIES_V a
   where a.CURRENCY = l_ccy;
 --
 cursor START_ROW is
  select max(START_DATE)
   from XTR_ROLLOVER_TRANSACTIONS_V
   where DEAL_NUMBER = l_deal_no
   and START_DATE <= l_ref_date
   and STATUS_CODE = 'CURRENT';
 --
 cursor LAST_ROW is
  select rowid
   from XTR_ROLLOVER_TRANSACTIONS_V
   where DEAL_NUMBER = l_deal_no
   and START_DATE >= l_start_date
   and STATUS_CODE = 'CURRENT'
   order by START_DATE desc,nvl(SETTLE_DATE,MATURITY_DATE) desc,TRANSACTION_NUMBER desc;
 --
 last_pmt LAST_ROW%ROWTYPE;
 --
 cursor DT_ROW is
  select DEAL_TYPE,START_DATE,MATURITY_DATE,NO_OF_DAYS,BALANCE_OUT_BF,
         BALANCE_OUT,PRINCIPAL_ADJUST,INTEREST_RATE,INTEREST,
         INTEREST_SETTLED,PRINCIPAL_ACTION,TRANSACTION_NUMBER,
         SETTLE_DATE,ACCUM_INTEREST_BF,PI_AMOUNT_DUE,PI_AMOUNT_RECEIVED,
         ACCUM_INTEREST,ROWID,ADJUSTED_BALANCE,COMMENTS,
         EXPECTED_BALANCE_BF,EXPECTED_BALANCE_OUT,PRINCIPAL_AMOUNT_TYPE,ENDORSER_CODE
   from XTR_ROLLOVER_TRANSACTIONS_V
   where DEAL_NUMBER = l_deal_no
   and START_DATE >= l_start_date
   and STATUS_CODE = 'CURRENT'
   order by START_DATE asc,nvl(SETTLE_DATE,MATURITY_DATE) asc,TRANSACTION_NUMBER asc
  for UPDATE OF START_DATE;
 --
 pmt DT_ROW%ROWTYPE;
 --
 cursor COMP is
  select b.INTEREST_ACTION
   from XTR_DEALS_V a,
        XTR_PAYMENT_SCHEDULE_V b
   where a.DEAL_NO = l_deal_no
   and  b.PAYMENT_SCHEDULE_CODE = a.PAYMENT_SCHEDULE_CODE;
 --

  cursor cur_deal is
  select day_count_type, rounding_type
  from xtr_deals
  where deal_no = l_deal_no;

  l_day_count_type xtr_deals.day_count_type%type;
  l_rounding_type xtr_deals.rounding_type%type;
  l_first_trans_flag varchar2(1);
  l_fwd_Adjust number;

  l_exp_bal_adj_amt	number;		-- added for bug 3465496.

--
 -- Bug 4226409
  cursor cur_settle_detail is
  select actual_settlement_date,settlement_number,deal_type,trans_mts
            ,settlement_authorised_by,audit_indicator
  from xtr_deal_date_amounts_v
  where deal_number = l_deal_no
  and transaction_number = pmt.transaction_number
  and amount_type = 'INTSET';

  l_settle_number number;       -- added for bug 4226409.
  l_settle_date     date;       -- added for bug 4226409.
  l_deal_type       xtr_deal_date_amounts.deal_type%TYPE; -- added for bug 4226409.
  l_trans_mts       xtr_deal_date_amounts.trans_mts%TYPE; -- added for bug 4226409.
  l_settle_by       xtr_deal_date_amounts.settlement_authorised_by%TYPE; -- added for bug 4226409.
  l_audit_indicator       xtr_deal_date_amounts.audit_indicator%TYPE; -- added for bug 4226409.


begin

--- add
 l_deal_no     := p_deal_no;
 l_subtype     := p_subtype;
 l_ccy         := p_ccy;
 l_trans_no    := p_trans_no;
 l_rec_ref     := p_rec_ref;
 l_rec_pass    := p_rec_pass;
 l_deal_date   := p_deal_date;
 l_company     := p_company;
 l_product     := p_product;
 l_portfolio   := p_portfolio;
 l_maturity    := p_maturity;
 l_settle_acct := p_settle_acct;
 l_cparty      := p_cparty;
 l_client      := p_client;
 l_cparty_acct := p_cparty_acct;
 l_dealer      := p_dealer;
 l_least_inserted  :=p_least_inserted;
 l_ref_date    := p_ref_date;
 l_limit_code  := p_limit_code;

---
 open DT_HOME_RATE;
  fetch DT_HOME_RATE INTO l_hce_rate;
 close DT_HOME_RATE;

 --
 open RND_YR;
  fetch RND_YR INTO rounding_fac;
 close RND_YR;

 --
 open GET_YEAR_CALC_TYPE;
  fetch GET_YEAR_CALC_TYPE INTO l_year_calc_type;
 close GET_YEAR_CALC_TYPE;

 --
 open COMP;
  fetch COMP INTO l_compound;
 close COMP;
 l_compound := nvl(l_compound,'N');

 --
 l_hce_rate := nvl(l_hce_rate,1);
 rounding_fac := nvl(rounding_fac,2);

 --
 l_comments := NULL;
 l_start_date := NULL;
 open START_ROW;
  fetch START_ROW INTO l_start_date;
 close START_ROW;

 --
 if l_start_date is NULL then
  l_start_date := l_ref_date;
  l_prv_row_exists := 'N';
 else
  l_prv_row_exists := 'Y';
 end if;

 --
 open LAST_ROW;
  fetch LAST_ROW INTO last_pmt;
 close LAST_ROW;

 Open Cur_Deal;
 fetch cur_deal into l_day_count_type, l_rounding_type;
 close cur_deal;

 --
 open DT_ROW;
  l_nill_date := NULL;
  fetch DT_ROW INTO pmt;

  --
  /****** Recalc Each Row ******/
  WHILE DT_ROW%FOUND LOOP
   -- Reset balance bf and start date from previous row information except
   -- for the first row

   if pmt.transaction_number = 1 then
      l_first_trans_flag := 'Y';
   else
      l_first_trans_flag := 'N';
   end if;

   if pmt.PRINCIPAL_ACTION = 'DECRSE' then
    l_prin_adj := (-1) * nvl(pmt.PRINCIPAL_ADJUST,0);
   else
    l_prin_adj := nvl(pmt.PRINCIPAL_ADJUST,0);
   end if;


   if DT_ROW%ROWCOUNT <> 1 then
    pmt.EXPECTED_BALANCE_BF := new_exp_bal;
    pmt.ACCUM_INTEREST_BF   := new_accum_int;
    pmt.BALANCE_OUT_BF      := new_balbf;
    pmt.START_DATE          := new_start_date;
    pmt.COMMENTS            := l_comments;

   elsif DT_ROW%ROWCOUNT = 1 then
    if l_prv_row_exists = 'Y' and pmt.SETTLE_DATE is NULL
     and nvl(l_least_inserted,'N') = 'Y' then
     pmt.MATURITY_DATE := l_ref_date;
     pmt.SETTLE_DATE := l_ref_date;
     pmt.PI_AMOUNT_DUE := 0;
     pmt.PI_AMOUNT_RECEIVED := 0;

     -- AW 1/6/00 Bug 1139396
     XTR_CALC_P.CALC_DAYS_RUN(pmt.START_DATE,
                              pmt.MATURITY_DATE,
                              l_year_calc_type,
                              l_no_of_days,
                              l_year_basis,
                              l_fwd_adjust,
                              l_day_count_type,
                              l_first_trans_flag);
     l_cum_int := (pmt.EXPECTED_BALANCE_BF
                        + l_prin_adj
                        * pmt.INTEREST_RATE / 100
                        * l_no_of_days   -- Bug 1139396 (pmt.MATURITY_DATE - pmt.START_DATE)
                        / l_year_basis);
     l_cum_int := xtr_fps2_p.interest_round(l_cum_int, rounding_fac, l_rounding_type);
     else
      l_cum_int := 0;
     end if;
    end if;
    -- Recalc interest amount
    l_prin_decr := 0;
    pmt.ADJUSTED_BALANCE := nvl(pmt.BALANCE_OUT_BF,0) + l_prin_adj;
     -- AW 1/6/00 Bug 1139396

     XTR_CALC_P.CALC_DAYS_RUN(pmt.START_DATE,
                              nvl(pmt.SETTLE_DATE,pmt.MATURITY_DATE),
                              l_year_calc_type,
                              pmt.NO_OF_DAYS,
                              l_year_basis,
                              l_fwd_adjust,
                              l_day_count_type,
                              l_first_trans_flag);
    if pmt.ADJUSTED_BALANCE >0 then   --- add
      pmt.INTEREST := (pmt.ADJUSTED_BALANCE * pmt.INTEREST_RATE / 100 *
                           pmt.NO_OF_DAYS / l_year_basis);
      pmt.INTEREST := xtr_fps2_p.interest_round(pmt.INTEREST, rounding_fac, l_rounding_type);
    else
      pmt.INTEREST :=0;
    end if;

    pmt.ACCUM_INTEREST := nvl(pmt.ACCUM_INTEREST_BF,0) + nvl(pmt.INTEREST,0);

    if pmt.SETTLE_DATE is NOT NULL then
--- add if 'W' not split for decrese on differnt day.
     if pmt.DEAL_TYPE <> 'RTMM' then
      l_prin_decr := pmt.PI_AMOUNT_RECEIVED;
      pmt.INTEREST_SETTLED :=0;
     else
      if nvl(pmt.PI_AMOUNT_RECEIVED,0) >= nvl(pmt.ACCUM_INTEREST,0) then
       l_prin_decr := nvl(pmt.PI_AMOUNT_RECEIVED,0) - nvl(pmt.ACCUM_INTEREST,0);
       pmt.INTEREST_SETTLED := nvl(pmt.ACCUM_INTEREST,0);
       pmt.ACCUM_INTEREST := 0;
      else
       l_prin_decr := 0;
       pmt.INTEREST_SETTLED := abs(nvl(pmt.PI_AMOUNT_RECEIVED,0));
       pmt.ACCUM_INTEREST := nvl(pmt.ACCUM_INTEREST,0) - nvl(pmt.PI_AMOUNT_RECEIVED,0);
      end if;
     end if;
    else
     NULL;
    end if;

    if l_compound = 'C' then
     pmt.BALANCE_OUT := pmt.ADJUSTED_BALANCE - nvl(l_prin_decr,0) +
                        nvl(pmt.ACCUM_INTEREST,0);
     pmt.ACCUM_INTEREST := 0;
    else
     pmt.BALANCE_OUT := pmt.ADJUSTED_BALANCE - nvl(l_prin_decr,0);
    end if;

    pmt.EXPECTED_BALANCE_OUT := nvl(pmt.EXPECTED_BALANCE_BF,0) + l_prin_adj;
     -- AW 1/6/00 Bug 1139396
     XTR_CALC_P.CALC_DAYS_RUN(pmt.START_DATE,
                              nvl(pmt.SETTLE_DATE,pmt.MATURITY_DATE),
                              l_year_calc_type,
                              l_no_of_days,
                              l_year_basis,
                              l_fwd_adjust,
                              l_day_count_type,
                              l_first_trans_flag);
    l_exp_int := (pmt.EXPECTED_BALANCE_OUT * pmt.INTEREST_RATE / 100
                       * l_no_of_days / l_year_basis);
    l_exp_int := xtr_fps2_p.interest_round(l_exp_int, rounding_fac, l_rounding_type);
    if nvl(l_cum_int,0) <> 0 then
     l_exp_int := l_exp_int + l_cum_int;
     l_cum_int := 0;
    end if;

-- Replaced for bug 3465496.
--    if pmt.PI_AMOUNT_DUE > l_exp_int then
--     pmt.EXPECTED_BALANCE_OUT :=
--           pmt.EXPECTED_BALANCE_OUT - pmt.PI_AMOUNT_DUE + l_exp_int;
--    end if;
-- end replacement

   -- begin bug 3465496.
   -- pmt.SETTLE_DATE is updated at time of reconciliation.

   If (pmt.SETTLE_DATE is not null) then
      l_exp_bal_adj_amt := nvl(pmt.PI_AMOUNT_RECEIVED,0);
   Else
      l_exp_bal_adj_amt := nvl(pmt.PI_AMOUNT_DUE,0);
   End If;

   If (l_exp_bal_adj_amt > l_exp_int) then
      pmt.EXPECTED_BALANCE_OUT := pmt.EXPECTED_BALANCE_OUT - l_exp_bal_adj_amt + l_exp_int;
   End if;

   -- end bug 3465496.

    --add
    if pmt.EXPECTED_BALANCE_OUT < 0 then
       pmt.PI_AMOUNT_DUE := nvl(pmt.PI_AMOUNT_DUE,0) +
           nvl(pmt.EXPECTED_BALANCE_OUT,0);
       pmt.EXPECTED_BALANCE_OUT := 0;
    end if;

    --add
    if pmt.MATURITY_DATE = l_maturity and pmt.ROWID=last_pmt.ROWID then
     -- Last transaction therefore make the repayment = Balance Out +
     -- Interest Due.
     pmt.PI_AMOUNT_DUE :=nvl(pmt.PI_AMOUNT_DUE,0)+nvl(pmt.EXPECTED_BALANCE_OUT,0);
     pmt.EXPECTED_BALANCE_OUT  :=0 ;
    end if;

    -- add 09/23/96
    if pmt.BALANCE_OUT_BF<0 then
     pmt.PI_AMOUNT_DUE :=0;
    end if;
    --
    -- Store balance carried fwd and start date for the next row
    new_exp_bal    := nvl(pmt.EXPECTED_BALANCE_OUT,0);
    new_accum_int  := nvl(pmt.ACCUM_INTEREST,0);
    new_balbf      := pmt.BALANCE_OUT;
    new_start_date := nvl(pmt.SETTLE_DATE,pmt.MATURITY_DATE);

    --
    if nvl(pmt.PI_AMOUNT_RECEIVED,0) <> 0 then
     l_comments := 'RECD SETTLEMENT ON PREV ROLL';
    else
     l_comments := NULL;
    end if;
    --
    l_prin_decr := nvl(l_prin_decr,0);
    pmt.INTEREST_SETTLED := nvl(pmt.INTEREST_SETTLED,0);
    -- Calc HCE amounts
    hce_decr       := round(l_prin_decr / l_hce_rate,rounding_fac);
    hce_balbf      := round(pmt.BALANCE_OUT_BF / l_hce_rate,rounding_fac);
    hce_interest   := (pmt.INTEREST / l_hce_rate);
    hce_interest := xtr_fps2_p.interest_round(hce_interest, rounding_fac, l_rounding_type);
    hce_settled    := round(pmt.INTEREST_SETTLED / l_hce_rate,rounding_fac);
    hce_accum_int_bf := (pmt.ACCUM_INTEREST_BF / l_hce_rate);
    hce_accum_int_bf := xtr_fps2_p.interest_round(hce_accum_int_bf, rounding_fac, l_rounding_type);
    hce_princ      := round(pmt.PRINCIPAL_ADJUST / l_hce_rate,rounding_fac);
    hce_balos      := round(pmt.BALANCE_OUT / l_hce_rate,rounding_fac);
    hce_accum_int  := (pmt.ACCUM_INTEREST / l_hce_rate);
    hce_accum_int := xtr_fps2_p.interest_round(hce_accum_int, rounding_fac, l_rounding_type);
    hce_due        := round(pmt.PI_AMOUNT_DUE / l_hce_rate,rounding_fac);
    --
    update XTR_ROLLOVER_TRANSACTIONS_V
     set  START_DATE            = pmt.START_DATE,
          BALANCE_OUT_BF        = pmt.BALANCE_OUT_BF,
          BALANCE_OUT_BF_HCE    = hce_balbf,
          ACCUM_INTEREST_BF     = pmt.ACCUM_INTEREST_BF,
          ACCUM_INTEREST_BF_HCE = hce_accum_int_bf,
          PI_AMOUNT_DUE         = pmt.PI_AMOUNT_DUE,
          PI_AMOUNT_RECEIVED    = pmt.PI_AMOUNT_RECEIVED,
          ADJUSTED_BALANCE      = pmt.ADJUSTED_BALANCE,
          BALANCE_OUT           = pmt.BALANCE_OUT,
          BALANCE_OUT_HCE       = hce_balos,
          PRINCIPAL_ADJUST_HCE  = hce_princ,
          PRINCIPAL_ADJUST      = pmt.PRINCIPAL_ADJUST,
          INTEREST              = pmt.INTEREST,
          INTEREST_SETTLED      = pmt.INTEREST_SETTLED,
          INTEREST_HCE          = hce_interest,
          ACCUM_INTEREST        = pmt.ACCUM_INTEREST,
          ACCUM_INTEREST_HCE    = hce_accum_int,
          SETTLE_DATE           = pmt.SETTLE_DATE,
          NO_OF_DAYS            = pmt.NO_OF_DAYS,
          MATURITY_DATE         = pmt.MATURITY_DATE,
          EXPECTED_BALANCE_BF   = nvl(pmt.EXPECTED_BALANCE_BF,0),
          EXPECTED_BALANCE_OUT  = pmt.EXPECTED_BALANCE_OUT
    where ROWID = pmt.ROWID;
    If SQL%FOUND then
       null;
    End if;
    --
    -- Update Interest Amounts
    update XTR_DEAL_DATE_AMOUNTS_V
         set  AMOUNT               = round(decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                                       ,0,nvl(pmt.PI_AMOUNT_DUE,0)
                                       ,nvl(pmt.INTEREST_SETTLED,0)),
                                       rounding_fac),
          HCE_AMOUNT           = round(decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                                       ,0,hce_due
                                       ,nvl(hce_settled,
                                        nvl(pmt.INTEREST_SETTLED,0))),
                                        rounding_fac),
          AMOUNT_DATE          = nvl(pmt.SETTLE_DATE,pmt.MATURITY_DATE),
          DATE_TYPE            = decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                                       ,0,'FORCAST','SETTLE'),
          TRANSACTION_RATE     = pmt.INTEREST_RATE,
          CASHFLOW_AMOUNT      = round(decode(l_subtype,
                                      'FUND',(-1),1) *
                                      decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                                        ,0,nvl(pmt.PI_AMOUNT_DUE,0)
                                        ,nvl(pmt.INTEREST_SETTLED,0)),
                                        rounding_fac),
          RECONCILED_PASS_CODE = decode(substr(nvl(RECONCILED_PASS_CODE,'@'),1,1),'^',
					substr(RECONCILED_PASS_CODE,2),RECONCILED_PASS_CODE)
     where DEAL_NUMBER = l_deal_no
     and   TRANSACTION_NUMBER = pmt.TRANSACTION_NUMBER
     and   AMOUNT_TYPE = 'INTSET';
     If SQL%Found then
          null;
     End if;
    --
    -- Principal Repayment has/will ocurr ???
    if nvl(l_prin_decr,0)<>0 then
     update XTR_DEAL_DATE_AMOUNTS_V
      set  AMOUNT               = decode(nvl(AMOUNT,0),0,nvl(l_prin_decr,0),AMOUNT),
           HCE_AMOUNT           = decode(nvl(HCE_AMOUNT,0),0,hce_decr,HCE_AMOUNT),
           AMOUNT_DATE          = nvl(pmt.SETTLE_DATE,pmt.MATURITY_DATE),
           DATE_TYPE            = decode(nvl(pmt.PI_AMOUNT_RECEIVED,0),0,'FORCAST','SETTLE'),
           TRANSACTION_RATE     = pmt.INTEREST_RATE,
	   SETTLE               = 'Y',    -- bug 3045426
           CASHFLOW_AMOUNT      = decode(nvl(CASHFLOW_AMOUNT,0),0,decode(l_subtype
                                       ,'FUND',(-1),1) * l_prin_decr,CASHFLOW_AMOUNT),
           RECONCILED_PASS_CODE = decode(substr(nvl(RECONCILED_PASS_CODE,'@'),1,1),'^',
                                   substr(RECONCILED_PASS_CODE,2),'@',l_rec_pass,RECONCILED_PASS_CODE),
           RECONCILED_REFERENCE = nvl(RECONCILED_REFERENCE,l_rec_ref)
      where DEAL_NUMBER = l_deal_no
      and   TRANSACTION_NUMBER = pmt.TRANSACTION_NUMBER
      and   AMOUNT_TYPE = 'PRINFLW'
      and   ACTION_CODE = 'DECRSE';

-- Start fix for Bug 4226409
      open cur_settle_detail;
      fetch cur_settle_detail into l_settle_date,l_settle_number,l_deal_type
                                    ,l_trans_mts,l_settle_by,l_audit_indicator;
      if(l_deal_type = 'RTMM') then
        close cur_settle_detail;
        update XTR_DEAL_DATE_AMOUNTS_V
        set  SETTLEMENT_NUMBER  = l_settle_number,
             ACTUAL_SETTLEMENT_DATE = l_settle_date,
             TRANS_MTS  = l_trans_mts,
             SETTLEMENT_AUTHORISED_BY = l_settle_by,
             AUDIT_INDICATOR    = l_audit_indicator
        where DEAL_NUMBER = l_deal_no
        and   TRANSACTION_NUMBER = pmt.TRANSACTION_NUMBER
        and   AMOUNT_TYPE = 'PRINFLW'
        and   ACTION_CODE = 'DECRSE';
      end if;
      -- End Fix for Bug 4226409

      If SQL%Found then
           null;
      End if;
     --
    end if;
    if nvl(pmt.PRINCIPAL_ADJUST,0) = 0 then
     delete from XTR_DEAL_DATE_AMOUNTS_V
      where DEAL_NUMBER = l_deal_no
      and TRANSACTION_NUMBER = pmt.TRANSACTION_NUMBER
      and AMOUNT_TYPE in ('PRINFLW')
      and ACTION_CODE = 'INCRSE';
      If SQL%Found then
        null;
      End if;
    end if;
    if pmt.BALANCE_OUT = 0 and pmt.ACCUM_INTEREST = 0 and l_nill_date is null then
        l_nill_date := nvl(pmt.SETTLE_DATE,pmt.MATURITY_DATE);-- :pmt.SETTLE_DATE
    end if;
   fetch DT_ROW INTO pmt;
   END LOOP;
   if l_nill_date is NOT NULL then
    delete from XTR_ROLLOVER_TRANSACTIONS_V
     where DEAL_NUMBER = l_deal_no
     and START_DATE >= l_nill_date;
    If SQL%Found then
        null;
    End if;
   end if;

   -- Update BALOUT Amounts
   UPDATE XTR_DEAL_DATE_AMOUNTS_V
    set AMOUNT     = nvl(pmt.BALANCE_OUT,0),
        HCE_AMOUNT = hce_balos
    where DEAL_NUMBER = l_deal_no
    and   DEAL_TYPE='RTMM'
    and   AMOUNT_TYPE = 'BALOUT';
    If SQL%found then
       null;
    End if;

   if SQL%NOTFOUND then
    -- Add 1 more row to DDA for Balout

    insert into XTR_DEAL_DATE_AMOUNTS_V
              (deal_type,amount_type,date_type,
               deal_number,transaction_number,transaction_date,currency,
               amount,hce_amount,amount_date,transaction_rate,
               cashflow_amount,company_code,account_no,action_code,
               cparty_account_no,deal_subtype,product_type,
               portfolio_code,status_code,cparty_code,dealer_code,
               settle,client_code,limit_code,limit_party)
    values    ('RTMM','BALOUT','COMENCE',
               l_deal_no,pmt.TRANSACTION_NUMBER,
               l_deal_date,l_ccy,nvl(pmt.BALANCE_OUT,0),
               nvl(hce_balos,0),l_maturity,pmt.INTEREST_RATE,0,
               l_company,l_settle_acct,NULL,
               l_cparty_acct,l_subtype,l_product,
               l_portfolio,'CURRENT',l_cparty,
               l_dealer,'N',l_client,nvl(l_limit_code,'NILL'),l_cparty);
   end if;
   if DT_ROW%ISOPEN then
    close DT_ROW;
   end if;
 EXCEPTION
  WHEN OTHERS THEN
   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
      xtr_debug_pkg.debug('EXCEPTION: XTR_AUTO_RECONCILIATION.recalc_dt_details');
   END IF;
   RAISE;
END RECALC_DT_DETAILS;
/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       P_RECONCILE                                                     |
|                                                                       |
|  DESCRIPTION                                                          |
|       Reconciliation                                                  |
|                                                                       |
|  REQUIRES                                                             |
|	p_verification_method						|
|	p_pass_code							|
|	p_import_reference						|
|	p_currency							|
|	p_cgu$sysdate							|
|	p_account_number						|
|	p_record_in_process						|
|	p_party_name							|
|	p_serial_reference						|
|	p_debit_amount							|
|	p_credit_amount 						|
|	p_reconciled_yn							|
|	p_min_rec_nos							|
|	p_max_rec_nos							|
|	p_rec_nos							|
|	p_tot_recon							|
|	p_incl_rtm							|
|									|
|  RETURNS								|
|	p_pass_code                                                     |
|	p_record_in_process						|
|	p_party_name							|
|	p_serial_reference						|
|	p_debit_amount							|
|	p_credit_amount							|
|	p_reconciled_yn							|
|	p_min_reco_nos							|
|	p_max_rec_nos							|
|	p_rec_nos							|
|	p_tot_recon							|
|                                                                       |
|  HISTORY                                                              |
 --------------------------------------------------------------------- */
PROCEDURE  P_RECONCILE(
 P_VERIFICATION_METHOD varchar2,
 P_PASS_CODE IN OUT NOCOPY varchar2,
 P_IMPORT_REFERENCE NUMBER,
 P_CURRENCY varchar2,
 P_CGU$SYSDATE date,
 P_ACCOUNT_NUMBER VARCHAR2,
 P_RECORD_IN_PROCESS IN OUT NOCOPY number,
 P_PARTY_NAME IN OUT NOCOPY varchar2,
 P_SERIAL_REFERENCE IN OUT NOCOPY varchar2,
 P_DEBIT_AMOUNT IN OUT NOCOPY number,
 P_CREDIT_AMOUNT IN OUT NOCOPY NUMBER,
 P_RECONCILED_YN  IN OUT NOCOPY varchar2,
 P_MIN_REC_NOS  IN OUT NOCOPY number,
 P_MAX_REC_NOS  IN OUT NOCOPY number,
 P_REC_NOS     IN OUT NOCOPY number,
 P_tot_recon IN OUT NOCOPY number,
 P_INCL_RTM IN varchar2) IS
--
 l_reset_amt  NUMBER;l_num_recs   NUMBER;l_found      VARCHAR2(1);
 l_tot_record NUMBER;
 l_days       NUMBER;l_one_date   DATE;l_s_date     DATE;l_sum_amt    NUMBER;
 l_count      NUMBER;l_bk_acct    VARCHAR2(1);l_party      VARCHAR2(1);
 l_serial_ref VARCHAR2(1);l_deal_no    VARCHAR2(1);l_amount     VARCHAR2(1);
 l_date       VARCHAR2(1);l_date_range VARCHAR2(1);l_sum_date   VARCHAR2(1);
 l_sum_range  VARCHAR2(1);l_deal_type  VARCHAR2(7);l_subtype    VARCHAR2(7);
 l_product    VARCHAR2(10);l_portfolio  VARCHAR2(7); l_rec_nos number;
 cursor PASSES is
    select RECONCILED_PASS_CODE,nvl(DAYS_ADJUSTMENT,0)
     from XTR_RECONCILIATION_PROCESS
      where VERIFICATION_METHOD = P_VERIFICATION_METHOD
     -- and PROCESS_TYPE = 'A'
      order by SEQUENCE_ORDER asc;
 cursor PASS_DETAILS is
     select RECONCILE_ON_COLUMN,RECONCILE_DETAIL
       from XTR_RECONCILIATION_PASSES
       where RECONCILED_PASS_CODE = P_PASS_CODE;
 p_det PASS_DETAILS%ROWTYPE;
 cursor REC is
    select *
     from XTR_PAY_REC_RECONCILIATION
      where IMPORT_REFERENCE = P_IMPORT_REFERENCE
       and RECONCILED_PASS_CODE is NULL
       and RECONCILED_REFERENCE is NULL
     for UPDATE OF IMPORT_REFERENCE;
 --
 rec_det REC%ROWTYPE;
 v_netoff_number NUMBER;
 --
 cursor REC_NUM is
   select XTR_DEAL_DATE_AMOUNTS_S.NEXTVAL
      from DUAL;
 --

 Cursor C1(p_netoff_number number) is
      select net_id from xtr_settlement_summary
      where settlement_number =
             (select settlement_number
              from xtr_deal_date_amounts
              where netoff_number = p_netoff_number
              and rownum < 2);

 Cursor C2(p_reconciled_reference number) is
      select settlement_number
      from xtr_deal_date_amounts
      where reconciled_reference = p_reconciled_reference;

/************* CE Reconc project ******************/
/* modified the cursor to differentiate non-netted records from netted records.  incase of netted records, we need to
   look at the netted amount.   */
 cursor DDA is
   select sum(round(CASHFLOW_AMOUNT,2)),count(*),AMOUNT_DATE, NETOFF_NUMBER
   from XTR_DEAL_DATE_AMOUNTS_V
     where ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
                    and nvl(l_deal_no,'N') = 'Y')
             or (l_deal_no is NULL )) --- modify
         and ((AMOUNT_DATE between (rec_det.VALUE_DATE - l_days) and
                                   (rec_det.VALUE_DATE + l_days) and
                    nvl(l_date,'N') = 'N') or
               (AMOUNT_DATE = rec_det.VALUE_DATE and nvl(l_date,'N')='Y'))
         and CURRENCY =P_CURRENCY
         and AMOUNT_DATE <= P_CGU$SYSDATE
         and RECONCILED_REFERENCE is NULL
         and RECONCILED_PASS_CODE is NULL
         and NETOFF_NUMBER is NULL
         and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and nvl(l_bk_acct,'N') = 'Y') or
              (nvl(l_bk_acct,'%') = '%'))
         and ((CASHFLOW_AMOUNT < 0 and rec_det.DEBIT_AMOUNT is NOT NULL)
              and ((abs(CASHFLOW_AMOUNT) = rec_det.DEBIT_AMOUNT
                   and nvl(l_amount,'N') = 'Y') or (nvl(l_amount,'N') = 'N'))
              or (nvl(rec_det.DEBIT_AMOUNT,0) = 0))
         and ((CASHFLOW_AMOUNT > 0 and rec_det.CREDIT_AMOUNT is NOT NULL)
              and ((abs(CASHFLOW_AMOUNT) = rec_det.CREDIT_AMOUNT
                   and nvl(l_amount,'N')='Y') or (nvl(l_amount,'N') = 'N'))
              or (nvl(rec_det.CREDIT_AMOUNT,0) = 0))
         and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
              and nvl(l_party,'N') = 'Y') or (l_party is NULL))
         and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
              and nvl(l_serial_ref,'N') = 'Y') or (l_serial_ref is NULL))
         and DEAL_TYPE like nvl(l_deal_type ,'%')
         and DEAL_SUBTYPE like nvl(l_subtype,'%')
         and PRODUCT_TYPE like nvl(l_product,'%')
         and PORTFOLIO_CODE like nvl(l_portfolio,'%')
         and ((date_type <>'FORCAST' and NVL(P_INCL_RTM, 'N')='N') or NVL(P_INCL_RTM, 'N') ='Y')
         group by AMOUNT_DATE, NETOFF_NUMBER
         union all
         select sum(round(CASHFLOW_AMOUNT,2)),count(distinct NETOFF_NUMBER),AMOUNT_DATE, NETOFF_NUMBER
         from XTR_DEAL_DATE_AMOUNTS_V
         where
         /*
         ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
                    and nvl(l_deal_no,'N') = 'Y')
             or (l_deal_no is NULL )) --- modify
         and
         */
        ((AMOUNT_DATE between (rec_det.VALUE_DATE - l_days) and
                                   (rec_det.VALUE_DATE + l_days) and
                    nvl(l_date,'N') = 'N') or
               (AMOUNT_DATE = rec_det.VALUE_DATE and nvl(l_date,'N')='Y'))
         and CURRENCY =P_CURRENCY
         and AMOUNT_DATE <= P_CGU$SYSDATE
         and RECONCILED_REFERENCE is NULL
         and RECONCILED_PASS_CODE is NULL
         and NETOFF_NUMBER is NOT NULL
         and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and nvl(l_bk_acct,'N') = 'Y') or
              (nvl(l_bk_acct,'%') = '%'))
         and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
              and nvl(l_party,'N') = 'Y') or (l_party is NULL))
         and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
              and nvl(l_serial_ref,'N') = 'Y') or (l_serial_ref is NULL))
         and DEAL_TYPE like nvl(l_deal_type ,'%')
         and DEAL_SUBTYPE like nvl(l_subtype,'%')
         and PRODUCT_TYPE like nvl(l_product,'%')
         and PORTFOLIO_CODE like nvl(l_portfolio,'%')
         and ((date_type <>'FORCAST' and NVL(P_INCL_RTM, 'N')='N') or NVL(P_INCL_RTM, 'N') ='Y')
         group by AMOUNT_DATE, NETOFF_NUMBER
         having  ((sum(round(CASHFLOW_AMOUNT,2)) < 0 and rec_det.DEBIT_AMOUNT is NOT NULL)
              and ((abs(sum(round(CASHFLOW_AMOUNT,2))) = rec_det.DEBIT_AMOUNT
                   and nvl(l_amount,'N') = 'Y') or (nvl(l_amount,'N') = 'N'))
              or (nvl(rec_det.DEBIT_AMOUNT,0) = 0))
         and ((sum(round(CASHFLOW_AMOUNT,2)) > 0 and rec_det.CREDIT_AMOUNT is NOT NULL)
              and ((abs(sum(round(CASHFLOW_AMOUNT,2))) = rec_det.CREDIT_AMOUNT
                   and nvl(l_amount,'N')='Y') or (nvl(l_amount,'N') = 'N'))
              or (nvl(rec_det.CREDIT_AMOUNT,0) = 0))
         ;

/***************** CE Recon project **********************/
/* non-netted records are summed up, while netted records are summed by the netoff_number */
  cursor DDA_SUM_DATE is
    select AMOUNT_DATE,sum(round(CASHFLOW_AMOUNT,2)),count(distinct nvl(NETOFF_NUMBER, -1)), NETOFF_NUMBER
     from XTR_DEAL_DATE_AMOUNTS_V
      where ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
                 and nvl(l_deal_no,'N') = 'Y')
             or (l_deal_no is NULL and date_type <> 'FORCAST'))
         and (((AMOUNT_DATE between (rec_det.VALUE_DATE - l_days) and
                                    (rec_det.VALUE_DATE + l_days) and
                  nvl(l_date,'N') = 'N') or
             (AMOUNT_DATE = rec_det.VALUE_DATE and nvl(l_date,'N')='Y'))
             and nvl(l_sum_date,'N') = 'Y')
         and AMOUNT_DATE <= P_CGU$SYSDATE
         and CURRENCY =P_CURRENCY
         and RECONCILED_REFERENCE is NULL
         and RECONCILED_PASS_CODE is NULL
         and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and nvl(l_bk_acct,'N') = 'Y') or
              (nvl(l_bk_acct,'%') = '%'))
         and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
              and nvl(l_party,'N') = 'Y') or (l_party is NULL))
         and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
              and nvl(l_serial_ref,'N') = 'Y') or (l_serial_ref is NULL))
         and DEAL_TYPE like nvl(l_deal_type ,'%')
         and DEAL_SUBTYPE like nvl(l_subtype,'%')
         and PRODUCT_TYPE like nvl(l_product,'%')
         and PORTFOLIO_CODE like nvl(l_portfolio,'%')
         and ((date_type <>'FORCAST' and NVL(P_INCL_RTM, 'N')='N') or NVL(P_INCL_RTM, 'N')='Y')
         group by AMOUNT_DATE, NETOFF_NUMBER
         ;
  --
  /************* CE Recon proejct *************/
  /* netted records and non-netted records are dealt with separately*/
  cursor DDA_SUM_RANGE is
     select sum(round(CASHFLOW_AMOUNT,2)),count(distinct nvl(netoff_number, -1)), Netoff_number
      from XTR_DEAL_DATE_AMOUNTS_V
       where ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
         and nvl(l_deal_no,'N') = 'Y')
         or (l_deal_no is NULL and date_type<>'FORCAST'))
         and (((AMOUNT_DATE between (rec_det.VALUE_DATE - l_days) and
                                  (rec_det.VALUE_DATE + l_days) and
				   nvl(l_date,'N') = 'N') or
             (AMOUNT_DATE = rec_det.VALUE_DATE and nvl(l_date,'N')='Y')) and
                                    nvl(l_sum_range,'N') = 'Y')
         and AMOUNT_DATE <= P_CGU$SYSDATE
         and CURRENCY =P_CURRENCY and RECONCILED_REFERENCE is NULL
         and RECONCILED_PASS_CODE is NULL
         and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and nvl(l_bk_acct,'N') = 'Y') or
              (nvl(l_bk_acct,'%') = '%'))
         and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
              and nvl(l_party,'N') = 'Y') or (l_party is NULL))
         and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
              and nvl(l_serial_ref,'N') = 'Y') or (l_serial_ref is NULL))
         and DEAL_TYPE like nvl(l_deal_type ,'%')
         and DEAL_SUBTYPE like nvl(l_subtype,'%')
         and PRODUCT_TYPE like nvl(l_product,'%')
         and PORTFOLIO_CODE like nvl(l_portfolio,'%')
         and ((date_type <>'FORCAST' and NVL(P_INCL_RTM, 'N')='N') or NVL(P_INCL_RTM, 'N')='Y')
         group by NETOFF_NUMBER
         ;
CURSOR c_file_dir IS
   SELECT SUBSTR(value,1,DECODE(INSTR(value,','),0,LENGTH(value),INSTR(value,',')-1) )
   FROM   v$parameter
   WHERE  name = 'utl_file_dir';
   l_file               utl_file.file_type;
   l_dirname            VARCHAR2(1000);
--
begin

   OPEN  c_file_dir;
   FETCH c_file_dir INTO l_dirname;
   CLOSE c_file_dir;
   l_file := utl_file.fopen(l_dirname,'xtraurec.log','w');

--
-- set parameteres
--
IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   xtr_debug_pkg.debug('>>>XTR_AUTO_RECONCILIATION.p_reconcile ');
   xtr_debug_pkg.debug('P_RECONCILE: ' || '>>> set parameteres ---------------->');
   xtr_debug_pkg.debug('P_RECONCILE: ' || 'p_verification_method = ' || p_verification_method);
   xtr_debug_pkg.debug('P_RECONCILE: ' || 'p_pass_code = ' || p_pass_code);
   xtr_debug_pkg.debug('P_RECONCILE: ' || 'p_import_reference = ' || to_char(p_import_reference));
   xtr_debug_pkg.debug('P_RECONCILE: ' || 'p_currency = ' || p_currency);
   xtr_debug_pkg.debug('P_RECONCILE: ' || 'p_account_number = ' || p_account_number);
   xtr_debug_pkg.debug('P_RECONCILE: ' || 'p_incl_rtm = '|| p_incl_rtm);
END IF;

 P_MIN_REC_NOS := NULL;
 P_MAX_REC_NOS := NULL;
 P_REC_NOS     := NULL;

 IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
    xtr_debug_pkg.debug('P_RECONCILE: ' || '>>> OPEN CURSOR PASSES ');
 END IF;
 open PASSES;
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>> LOOP --2 ');
    END IF;
    LOOP -- 2

     IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
        xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>> FETCH PASSES into P_PASS_CODE, l_days');
     END IF;
     fetch PASSES INTO P_PASS_CODE,l_days;

     IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
        xtr_debug_pkg.debug('P_RECONCILE: ' || 'P_PASS_CODE = ' || P_PASS_CODE);
        xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_days = ' || to_char(l_days));
     END IF;

     EXIT WHEN PASSES%NOTFOUND;
     l_bk_acct    := NULL;l_party      := NULL;l_deal_no    := NULL;l_serial_ref := NULL;
     l_amount     := NULL;l_sum_date   := NULL;l_sum_range  := NULL;l_date :=NULL;
     l_deal_type  := NULL;
     l_subtype    := NULL;l_product    := NULL;l_portfolio  := NULL; v_netoff_number := NULL;
     IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
        xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>> OPEN CURSOR PASS_DETAILS ');
     END IF;
     open PASS_DETAILS;
     LOOP -- 3 (in 2)
      IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
         xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>> LOOP --3 ');
         xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>> FETCH PASS_DETAILS into p_det');
      END IF;
      fetch PASS_DETAILS INTO p_det;

      --xtr_debug_pkg.debug('p_det.RECONCILE_ON_COLUMN = ' || REOCNCILE_ON_COLUMN);
      EXIT WHEN PASS_DETAILS%NOTFOUND;
      if p_det.RECONCILE_ON_COLUMN = 'BANK ACCT' then
       if p_det.RECONCILE_DETAIL = 'MATCH' then
        l_bk_acct := 'Y';   -----FOR BUG 6664952--l_bk_acct := '%';
       else
         l_bk_acct := '%';  -----FOR BUG 6664952 --l_bk_acct := 'Y';
       end if;
      elsif p_det.RECONCILE_ON_COLUMN = 'PARTY' then
            l_party := 'Y';
      elsif p_det.RECONCILE_ON_COLUMN = 'SERIAL NUM' then
            l_serial_ref := 'Y';
      elsif p_det.RECONCILE_ON_COLUMN = 'DEAL NUM' then
            l_deal_no := 'Y';
      elsif p_det.RECONCILE_ON_COLUMN = 'AMOUNT' then
            l_amount := 'Y';
       if p_det.RECONCILE_DETAIL = 'SUM DATE' then
             l_sum_date := 'Y';
       elsif p_det.RECONCILE_DETAIL = 'SUM RANGE' then
             l_sum_range := 'Y';
       end if;
      elsif p_det.RECONCILE_ON_COLUMN = 'DATE' then
            l_date := 'Y';
      elsif p_det.RECONCILE_ON_COLUMN = 'DEAL TYPE' then
            l_deal_type := substr(p_det.RECONCILE_DETAIL,1,7);
      elsif p_det.RECONCILE_ON_COLUMN = 'SUBTYPE' then
            l_subtype := substr(p_det.RECONCILE_DETAIL,1,7);
      elsif p_det.RECONCILE_ON_COLUMN = 'PRODUCT' then
            l_product := substr(p_det.RECONCILE_DETAIL,1,10);
      elsif p_det.RECONCILE_ON_COLUMN = 'SUBTYPE' then
            l_portfolio := substr(p_det.RECONCILE_DETAIL,1,7);
      end if;
	  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'values----------------------');
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_party = ' || l_party);
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_serial_ref = ' || l_serial_ref);
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_deal_no = ' || l_deal_no);
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_amount = ' || l_amount);
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_sum_date = ' || l_sum_date);
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_sum_range = ' || l_sum_range);
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_date = ' || l_date);
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_deal_type = ' || l_deal_type);
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_subtype = ' || l_subtype);
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_product = ' || l_product);
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_portfolio = ' || l_portfolio);
 	     xtr_debug_pkg.debug('P_RECONCILE: ' || '---------------------------');
	     xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>> END LOOP --3 ');
	  END IF;
     END LOOP; -- 3 (in 2)
     close PASS_DETAILS;
     if l_days is NULL then
       l_days := 0;
     end if;

     open REC;

          IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
             xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>> LOOP --4 ');
          END IF;
     LOOP -- 4 (in 2)
	   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	      xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>> FETCH REC into rec_det');
	   END IF;

      fetch REC INTO rec_det;
      EXIT WHEN REC%NOTFOUND;
      P_RECORD_IN_PROCESS := nvl(P_RECORD_IN_PROCESS,0) + 1;
      P_PARTY_NAME        := rec_det.PARTICULARS;
      P_SERIAL_REFERENCE  := rec_det.SERIAL_REFERENCE;
      P_DEBIT_AMOUNT      := rec_det.DEBIT_AMOUNT;
      P_CREDIT_AMOUNT     := rec_det.CREDIT_AMOUNT;
      P_RECONCILED_YN     := NULL;
	   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	      xtr_debug_pkg.debug('P_RECONCILE: ' || 'value--------------------');
	      xtr_debug_pkg.debug('P_RECONCILE: ' || 'P_IMPORT_REFERENCE = ' || to_char(P_IMPORT_REFERENCE));
	      xtr_debug_pkg.debug('P_RECONCILE: ' || 'P_RECORD_IN_PROCESS = ' || to_char(P_RECORD_IN_PROCESS));
	      xtr_debug_pkg.debug('P_RECONCILE: ' || 'P_PARTY_NAME = ' || P_PARTY_NAME);
	      xtr_debug_pkg.debug('P_RECONCILE: ' || 'P_SERIAL_REFERENCE = ' || P_SERIAL_REFERENCE);
	      xtr_debug_pkg.debug('P_RECONCILE: ' || 'P_DEBIT_AMOUNT = ' || to_char(P_DEBIT_AMOUNT));
	      xtr_debug_pkg.debug('P_RECONCILE: ' || 'P_CREDIT_AMOUNT = ' || to_char(P_CREDIT_AMOUNT));
	      xtr_debug_pkg.debug('P_RECONCILED_YN = ' || P_RECONCILED_YN);
	   END IF;

     /*  dda_sum_date */
     if nvl(l_sum_date,'N') = 'Y' then
	    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	       xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>>DDA_SUM_DATE..............');
	    END IF;

      open DDA_SUM_DATE;

      LOOP -- 5 (in 4)
	    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	       xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>>> LOOP --5 ');
                xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>>> FETCH DDA_SUM_DATE into l_s_date, l_sum_amt, l_num_recs');
             END IF;
       fetch DDA_SUM_DATE INTO l_s_date,l_sum_amt,l_num_recs, v_netoff_number;
--dbms_output.put_line(' DDA_SUM_DATE date, amt, no-rec, net# '||l_s_date||' - '||l_sum_amt||' - '||l_num_recs||' - '||v_netoff_number);

       EXIT WHEN DDA_SUM_DATE%NOTFOUND;
/***************/
       utl_file.put_line (l_file,'>>----DDA_SUM_DATE');
       utl_file.put_line (l_file,'>>----net#, date, amt no-recs '||v_netoff_number||' - '||l_s_date||' - '||l_sum_amt||' - '||l_num_Recs);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

       if nvl(rec_det.DEBIT_AMOUNT,0) <> 0 then
        if ((((-1) * rec_det.DEBIT_AMOUNT) = l_sum_amt and l_amount =
            'Y') or (nvl(l_amount,'N') = 'N')) then

	     --- I think it never go to here, because l_amount =Y
         if ((-1) * rec_det.DEBIT_AMOUNT) > l_sum_amt then
                -- amt from reconcile is less than due
          l_reset_amt := abs(rec_det.DEBIT_AMOUNT + l_sum_amt) /
                                  l_num_recs;
         else
          l_reset_amt := (rec_det.DEBIT_AMOUNT - l_sum_amt) / l_num_recs;
         end if;
         p_tot_recon := nvl(p_tot_recon,0) + 1;
         P_RECONCILED_YN :='Y';

         open REC_NUM;
         fetch REC_NUM INTO l_rec_nos;
         close REC_NUM;

         if nvl(P_MIN_REC_NOS,9999999) >= l_rec_nos then
               P_MIN_REC_NOS := l_rec_nos;
         end if;

         if nvl(P_MAX_REC_NOS,0) <= l_rec_nos then
                P_MAX_REC_NOS := l_rec_nos;
         end if;

         if P_REC_NOS is NULL then
                P_REC_NOS := l_rec_nos;
         end if;


         If v_netoff_number is null then
/***************/
       utl_file.put_line (l_file,'>>----DDA_SUM_DATE');
       utl_file.put_line (l_file,'>>---- inside IF ');
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

              update XTR_DEAL_DATE_AMOUNTS
              set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE =
			decode(DATE_TYPE,'FORCAST','^'||P_PASS_CODE,P_PASS_CODE),
                    RECONCILED_DAYS_ADJUST = (trunc(rec_det.VALUE_DATE) -
                                              trunc(l_s_date)),
                    AMOUNT_DATE          =
			decode(DATE_TYPE,'FORCAST',rec_det.VALUE_DATE,AMOUNT_DATE),
                    DATE_TYPE            = decode(DATE_TYPE,'FORCAST','SETTLE',DATE_TYPE),
                    HCE_AMOUNT           =
			decode(DATE_TYPE,'FORCAST',decode(nvl(HCE_AMOUNT,0),0,HCE_AMOUNT,
			(AMOUNT/HCE_AMOUNT)*(nvl(HCE_AMOUNT,0) + nvl(l_reset_amt,0))),HCE_AMOUNT),
                    AMOUNT               =
			decode(DATE_TYPE,'FORCAST',decode(nvl(AMOUNT,0),0,AMOUNT,nvl(AMOUNT,0) +
			nvl(l_reset_amt,0)),AMOUNT),
                    CASHFLOW_AMOUNT      =
			decode(DATE_TYPE,'FORCAST',decode(nvl(CASHFLOW_AMOUNT,0),0,
			CASHFLOW_AMOUNT,nvl(CASHFLOW_AMOUNT,0) + nvl(l_reset_amt,0)),CASHFLOW_AMOUNT)
                where ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
                       and l_deal_no = 'Y') or (l_deal_no is NULL and DATE_TYPE <>'FORCAST'))
                and AMOUNT_DATE = l_s_date
                and NETOFF_NUMBER is NULL
                and AMOUNT_TYPE <> 'FACEVAL'
                and CURRENCY =P_CURRENCY
                and RECONCILED_REFERENCE is NULL and RECONCILED_PASS_CODE is NULL
                and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and l_bk_acct = 'Y') or
                      (nvl(l_bk_acct,'%') = '%'))
                and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
                      and l_party = 'Y') or (l_party is NULL))
                and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
                      and l_serial_ref = 'Y') or (l_serial_ref is NULL))
                and DEAL_TYPE like nvl(l_deal_type ,'%')
                and DEAL_SUBTYPE like nvl(l_subtype,'%')
                and PRODUCT_TYPE like nvl(l_product,'%')
                and PORTFOLIO_CODE like nvl(l_portfolio,'%')
                and ((date_type <>'FORCAST' and NVL(P_INCL_RTM, 'N')='N') or NVL(P_INCL_RTM, 'N')='Y');
                If SQL%FOUND then
/***************/
       utl_file.put_line (l_file,'>>----DDA_SUM_DATE');
       utl_file.put_line (l_file,'>>---- UPD complete deal# '||rtrim(rec_det.particulars));
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                    For C2_Rec in C2(l_Rec_nos)
                    Loop
                        Update Xtr_Settlement_Summary
                        Set status = 'R'
                        Where settlement_number = C2_Rec.settlement_number;
/***************/
         utl_file.put_line(l_file, '>>----DDA_SUM_DATE ------');
         utl_file.put_line(l_file, '>>----UPD settlement_summary complete settle# '||C2_Rec.settlement_number);
         utl_file.put_line(l_file, '>>------------------------------------');
/**************/
                    End Loop;
                End if;
           Else
/***************/
       utl_file.put_line (l_file,'>>----DDA_SUM_DATE');
       utl_file.put_line (l_file,'>>---- inside ELSE ');
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

              update XTR_DEAL_DATE_AMOUNTS
              set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE =
			decode(DATE_TYPE,'FORCAST','^'||P_PASS_CODE,P_PASS_CODE),
                    RECONCILED_DAYS_ADJUST = (trunc(rec_det.VALUE_DATE) -
                                              trunc(l_s_date)),
                    AMOUNT_DATE          =
			decode(DATE_TYPE,'FORCAST',rec_det.VALUE_DATE,AMOUNT_DATE),
                    DATE_TYPE            = decode(DATE_TYPE,'FORCAST','SETTLE',DATE_TYPE),
                    HCE_AMOUNT           =
			decode(DATE_TYPE,'FORCAST',decode(nvl(HCE_AMOUNT,0),0,HCE_AMOUNT,
			(AMOUNT/HCE_AMOUNT)*(nvl(HCE_AMOUNT,0) + nvl(l_reset_amt,0))),HCE_AMOUNT),
                    AMOUNT               =
			decode(DATE_TYPE,'FORCAST',decode(nvl(AMOUNT,0),0,AMOUNT,nvl(AMOUNT,0) +
			nvl(l_reset_amt,0)),AMOUNT),
                    CASHFLOW_AMOUNT      =
			decode(DATE_TYPE,'FORCAST',decode(nvl(CASHFLOW_AMOUNT,0),0,
			CASHFLOW_AMOUNT,nvl(CASHFLOW_AMOUNT,0) + nvl(l_reset_amt,0)),CASHFLOW_AMOUNT)
                where
                /*
                ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
                       and l_deal_no = 'Y') or (l_deal_no is NULL and DATE_TYPE <>'FORCAST'))
                and
                */
                AMOUNT_DATE = l_s_date
                and NETOFF_NUMBER = v_netoff_number
                and AMOUNT_TYPE <> 'FACEVAL'
                and CURRENCY =P_CURRENCY
                and RECONCILED_REFERENCE is NULL and RECONCILED_PASS_CODE is NULL
                and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and l_bk_acct = 'Y') or
                      (nvl(l_bk_acct,'%') = '%'))
                and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
                      and l_party = 'Y') or (l_party is NULL))
                and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
                      and l_serial_ref = 'Y') or (l_serial_ref is NULL))
                and DEAL_TYPE like nvl(l_deal_type ,'%')
                and DEAL_SUBTYPE like nvl(l_subtype,'%')
                and PRODUCT_TYPE like nvl(l_product,'%')
                and PORTFOLIO_CODE like nvl(l_portfolio,'%')
                and ((date_type <>'FORCAST' and NVL(P_INCL_RTM, 'N')='N') or NVL(P_INCL_RTM, 'N')='Y');
                If SQL%FOUND then
/***************/
       utl_file.put_line (l_file,'>>----DDA_SUM_DATE');
       utl_file.put_line (l_file,'>>---- UPD complete deal# '||rtrim(rec_det.particulars));
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                 For C1_Rec in C1(v_netoff_number)
                 Loop
                     Update Xtr_Settlement_Summary
                     Set status = 'R'
                     Where settlement_summary_id = C1_Rec.net_ID;
/***************/
         utl_file.put_line(l_file, '>>----DDA ------');
         utl_file.put_line(l_file, '>>----UPD settlement_summary complete netID '||C1_Rec.net_id);
         utl_file.put_line(l_file, '>>------------------------------------');
/**************/
                 End Loop;
                End if;
           End if;

         update XTR_PAY_REC_RECONCILIATION
                set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE = P_PASS_CODE
                where CURRENT OF REC;
         EXIT;
        end if;
       elsif nvl(rec_det.CREDIT_AMOUNT,0) <> 0 then
        if (((rec_det.CREDIT_AMOUNT) = l_sum_amt and l_amount =
               'Y') or (nvl(l_amount,'N') = 'N')) then
         if rec_det.CREDIT_AMOUNT > l_sum_amt then
                l_reset_amt := (rec_det.CREDIT_AMOUNT - l_sum_amt) /
                                   l_num_recs;
         else
                l_reset_amt := (l_sum_amt - rec_det.CREDIT_AMOUNT) /
                                   l_num_recs;
         end if;
         p_tot_recon := nvl(p_tot_recon,0) + 1;
         P_RECONCILED_YN :='Y';
         open REC_NUM;
                fetch REC_NUM INTO l_rec_nos;
         close REC_NUM;
         if nvl(P_MIN_REC_NOS,9999999) >= l_rec_nos then
                P_MIN_REC_NOS := l_rec_nos;
         end if;
         if nvl(P_MAX_REC_NOS,0) <= l_rec_nos then
                P_MAX_REC_NOS := l_rec_nos;
         end if;
         if P_REC_NOS is NULL then
                P_REC_NOS := l_rec_nos;
         end if;

--dbms_output.put_line('bef UPD ');
         If v_netoff_number is null then
/***************/
       utl_file.put_line (l_file,'>>----not known');
       utl_file.put_line (l_file,'>>---- inside IF '||v_netoff_number);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

                update XTR_DEAL_DATE_AMOUNTS
                set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE =
			decode(DATE_TYPE,'FORCAST','^'||P_PASS_CODE,P_PASS_CODE),
                    RECONCILED_DAYS_ADJUST = (trunc(rec_det.VALUE_DATE) -
                                              trunc(l_s_date)),
                    AMOUNT_DATE          =
			decode(DATE_TYPE,'FORCAST',rec_det.VALUE_DATE,AMOUNT_DATE),
                    DATE_TYPE            = decode(DATE_TYPE,'FORCAST','SETTLE',DATE_TYPE),
                    HCE_AMOUNT           =
			decode(DATE_TYPE,'FORCAST',decode(nvl(HCE_AMOUNT,0),0,HCE_AMOUNT,
			(AMOUNT/HCE_AMOUNT)*(nvl(HCE_AMOUNT,0) + nvl(l_reset_amt,0))),HCE_AMOUNT),
                    AMOUNT               =
			decode(DATE_TYPE,'FORCAST',decode(nvl(AMOUNT,0),0,AMOUNT,nvl(AMOUNT,0) +
			nvl(l_reset_amt,0)),AMOUNT),
                    CASHFLOW_AMOUNT      =
			decode(DATE_TYPE,'FORCAST',decode(nvl(CASHFLOW_AMOUNT,0),0,
			CASHFLOW_AMOUNT,nvl(CASHFLOW_AMOUNT,0) + nvl(l_reset_amt,0)),CASHFLOW_AMOUNT)
                where ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
                       and l_deal_no = 'Y') or (l_deal_no is NULL))
                and AMOUNT_DATE = l_s_date
                and NETOFF_NUMBER is NULL
		and AMOUNT_TYPE <> 'FACEVAL'
                and CURRENCY =P_CURRENCY
                and RECONCILED_REFERENCE is NULL
                and RECONCILED_PASS_CODE is NULL
                and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and l_bk_acct = 'Y') or
                      (nvl(l_bk_acct,'%') = '%'))
                and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
                      and l_party = 'Y') or (l_party is NULL))
                and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
                      and l_serial_ref = 'Y') or (l_serial_ref is NULL))
                and DEAL_TYPE like nvl(l_deal_type ,'%')
                and DEAL_SUBTYPE like nvl(l_subtype,'%')
                and PRODUCT_TYPE like nvl(l_product,'%')
                and PORTFOLIO_CODE like nvl(l_portfolio,'%')
                and ((date_type <>'FORCAST' and NVL(P_INCL_RTM,'N')='N') or NVL(P_INCL_RTM, 'N')='Y');
                If SQL%FOUND then
/***************/
       utl_file.put_line (l_file,'>>----not known');
       utl_file.put_line (l_file,'>>---- UPD complete ');
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                  For C2_Rec in C2(l_rec_nos)
                  Loop
                     Update Xtr_Settlement_Summary
                     Set status = 'R'
                     Where settlement_number = C2_Rec.settlement_number;
/***************/
         utl_file.put_line(l_file, '>>----DDA_SUM_DATE ------');
         utl_file.put_line(l_file, '>>----UPD settlement_summary complete settle# '||C2_Rec.settlement_number);
         utl_file.put_line(l_file, '>>------------------------------------');
/**************/
                  End Loop;
                End if;
           Else
/***************/
       utl_file.put_line (l_file,'>>----not known');
       utl_file.put_line (l_file,'>>---- inside ELSE ');
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

                update XTR_DEAL_DATE_AMOUNTS
                set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE =
			decode(DATE_TYPE,'FORCAST','^'||P_PASS_CODE,P_PASS_CODE),
                    RECONCILED_DAYS_ADJUST = (trunc(rec_det.VALUE_DATE) -
                                              trunc(l_s_date)),
                    AMOUNT_DATE          =
			decode(DATE_TYPE,'FORCAST',rec_det.VALUE_DATE,AMOUNT_DATE),
                    DATE_TYPE            = decode(DATE_TYPE,'FORCAST','SETTLE',DATE_TYPE),
                    HCE_AMOUNT           =
			decode(DATE_TYPE,'FORCAST',decode(nvl(HCE_AMOUNT,0),0,HCE_AMOUNT,
			(AMOUNT/HCE_AMOUNT)*(nvl(HCE_AMOUNT,0) + nvl(l_reset_amt,0))),HCE_AMOUNT),
                    AMOUNT               =
			decode(DATE_TYPE,'FORCAST',decode(nvl(AMOUNT,0),0,AMOUNT,nvl(AMOUNT,0) +
			nvl(l_reset_amt,0)),AMOUNT),
                    CASHFLOW_AMOUNT      =
			decode(DATE_TYPE,'FORCAST',decode(nvl(CASHFLOW_AMOUNT,0),0,
			CASHFLOW_AMOUNT,nvl(CASHFLOW_AMOUNT,0) + nvl(l_reset_amt,0)),CASHFLOW_AMOUNT)
                where
                /*
                ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
                       and l_deal_no = 'Y') or (l_deal_no is NULL))
                and
                */
                AMOUNT_DATE = l_s_date
                and NETOFF_NUMBER = v_netoff_number
		and AMOUNT_TYPE <> 'FACEVAL'
                and CURRENCY =P_CURRENCY
                and RECONCILED_REFERENCE is NULL
                and RECONCILED_PASS_CODE is NULL
                and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and l_bk_acct = 'Y') or
                      (nvl(l_bk_acct,'%') = '%'))
                and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
                      and l_party = 'Y') or (l_party is NULL))
                and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
                      and l_serial_ref = 'Y') or (l_serial_ref is NULL))
                and DEAL_TYPE like nvl(l_deal_type ,'%')
                and DEAL_SUBTYPE like nvl(l_subtype,'%')
                and PRODUCT_TYPE like nvl(l_product,'%')
                and PORTFOLIO_CODE like nvl(l_portfolio,'%')
                and ((date_type <>'FORCAST' and NVL(P_INCL_RTM,'N')='N') or NVL(P_INCL_RTM, 'N')='Y');
                If SQL%FOUND then
/***************/
       utl_file.put_line (l_file,'>>----not known ---');
       utl_file.put_line (l_file,'>>----UPD complete ');
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                 For C1_Rec in C1(v_netoff_number)
                 Loop
                     Update Xtr_Settlement_Summary
                     Set status = 'R'
                     Where settlement_summary_id = C1_Rec.net_ID;
/***************/
         utl_file.put_line(l_file, '>>----DDA ------');
         utl_file.put_line(l_file, '>>----UPD settlement_summary complete netID '||C1_Rec.net_id);
         utl_file.put_line(l_file, '>>------------------------------------');
/**************/
                 End Loop;

                End if;
           End if;

                update XTR_PAY_REC_RECONCILIATION
                set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE = P_PASS_CODE
                where CURRENT OF REC;
         EXIT;
        end if;
       end if;
      END LOOP; -- 5 (in 4)
      close DDA_SUM_DATE;
     elsif nvl(l_sum_range,'N') = 'Y' then
	    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	       xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>> DDA_SUM_RANGE .............');
	    END IF;

      open DDA_SUM_RANGE;
            -- Sum records on Deal Date Amounts ACROSS a Range of Dates
      LOOP -- 6 (in 4)
	    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	       xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>>> LOOP --6 ');
	        xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>>> FETCH DDA_SUM_RANGE into l_sum_amt, l_num_recs');
	     END IF;
       fetch DDA_SUM_RANGE INTO l_sum_amt,l_num_recs, v_netoff_number;
--dbms_output.put_line('DDA_SUM_RANGE amt, no-recs, net# '||l_sum_amt||' - '||l_num_recs||' - '||v_netoff_number);

       EXIT WHEN DDA_SUM_RANGE%NOTFOUND;
/***************/
       utl_file.put_line (l_file,'>>----DDA_SUM_RANGE');
       utl_file.put_line (l_file,'>>----deal#, sumrange, acct, party, curr '||l_deal_no||' - '||l_sum_range||' - '||p_account_number||' - '||rec_det.party_name||' - '||p_currency);
       utl_file.put_line (l_file, '>>--- value-date, l-days '||rec_det.value_date||' - '||l_days);
       utl_file.put_line (l_file,'>>----net#, amt, no-rec '||v_netoff_number||' - '||l_sum_amt||' - '||l_num_recs);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

       if nvl(rec_det.DEBIT_AMOUNT,0) <> 0 then
        if ((((-1) * rec_det.DEBIT_AMOUNT) = l_sum_amt and l_amount =
               'Y') or (nvl(l_amount,'N') = 'N')) then

         if ((-1) * rec_det.DEBIT_AMOUNT) > l_sum_amt then
               -- amt from reconcile is less than due
               l_reset_amt := abs(rec_det.DEBIT_AMOUNT + l_sum_amt) /
                                  l_num_recs;
         else
                l_reset_amt := (rec_det.DEBIT_AMOUNT - l_sum_amt) / l_num_recs;
         end if;

         p_tot_recon := nvl(p_tot_recon,0) + 1;
         P_RECONCILED_YN :='Y';
         open REC_NUM;
         fetch REC_NUM INTO l_rec_nos;
         close REC_NUM;
         if nvl(P_MIN_REC_NOS,9999999) >= l_rec_nos then
                P_MIN_REC_NOS := l_rec_nos;
         end if;
         if nvl(P_MAX_REC_NOS,0) <= l_rec_nos then
                P_MAX_REC_NOS := l_rec_nos;
         end if;
         if P_REC_NOS is NULL then
                P_REC_NOS := l_rec_nos;
         end if;


--dbms_output.put_line('bef UPD');
         If v_netoff_number is null then
/***************/
       utl_file.put_line (l_file,'>>----DDA_SUM_RANGE');
       utl_file.put_line (l_file,'>>---- inside IF ');
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

               update XTR_DEAL_DATE_AMOUNTS
               set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE =
			decode(DATE_TYPE,'FORCAST','^'||P_PASS_CODE,P_PASS_CODE),
                    RECONCILED_DAYS_ADJUST = (trunc(rec_det.VALUE_DATE) -
                                              trunc(l_s_date)),
                    AMOUNT_DATE          =
			decode(DATE_TYPE,'FORCAST',rec_det.VALUE_DATE,AMOUNT_DATE),
                    DATE_TYPE            = decode(DATE_TYPE,'FORCAST','SETTLE',DATE_TYPE),
                    HCE_AMOUNT           =
			decode(DATE_TYPE,'FORCAST',decode(nvl(HCE_AMOUNT,0),0,HCE_AMOUNT,
			(AMOUNT/HCE_AMOUNT)*(nvl(HCE_AMOUNT,0) + nvl(l_reset_amt,0))),HCE_AMOUNT),
                    AMOUNT               =
			decode(DATE_TYPE,'FORCAST',decode(nvl(AMOUNT,0),0,AMOUNT,nvl(AMOUNT,0) +
			nvl(l_reset_amt,0)),AMOUNT),
                    CASHFLOW_AMOUNT      =
			decode(DATE_TYPE,'FORCAST',decode(nvl(CASHFLOW_AMOUNT,0),0,
			CASHFLOW_AMOUNT,nvl(CASHFLOW_AMOUNT,0) + nvl(l_reset_amt,0)),CASHFLOW_AMOUNT)
                where ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
                       and l_deal_no = 'Y') or (l_deal_no is NULL))
                and AMOUNT_DATE between (rec_det.VALUE_DATE - l_days) and
                                         P_CGU$SYSDATE
                and NETOFF_NUMBER is NULL
                and AMOUNT_TYPE <> 'FACEVAL'
                and CURRENCY =P_CURRENCY
                and RECONCILED_REFERENCE is NULL  -- add
                and RECONCILED_PASS_CODE is NULL
                and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and l_bk_acct = 'Y') or
                      (nvl(l_bk_acct,'%') = '%'))
                and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
                      and l_party = 'Y') or (l_party is NULL))
                and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
                      and l_serial_ref = 'Y') or (l_serial_ref is NULL))
                and DEAL_TYPE like nvl(l_deal_type ,'%')
                and DEAL_SUBTYPE like nvl(l_subtype,'%')
                and PRODUCT_TYPE like nvl(l_product,'%')
                and PORTFOLIO_CODE like nvl(l_portfolio,'%')
                and ((date_type <>'FORCAST' and NVL(P_INCL_RTM, 'N')='N') or NVL(P_INCL_RTM, 'N')='Y');
                If SQL%FOUND then
/***************/
       utl_file.put_line (l_file,'>>----DDA_SUM_RANGE');
       utl_file.put_line (l_file,'>>---- UPD complete  rec#, rec-pass '||l_rec_nos||' - '||p_pass_code);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                   For C2_Rec in C2(l_rec_nos)
                   Loop
                     Update Xtr_Settlement_Summary
                     Set status = 'R'
                     Where settlement_number = C2_Rec.Settlement_Number;
/***************/
       utl_file.put_line (l_file,'>>----DDA');
       utl_file.put_line (l_file,'>>---- UPD settlement_summary complete settle# '||c2_rec.settlement_number);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                   End Loop;
                End if;
           Else
/***************/
       utl_file.put_line (l_file,'>>----DDA_SUM_RANGE');
       utl_file.put_line (l_file,'>>---- inside ELSE net# '||v_netoff_number);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

               update XTR_DEAL_DATE_AMOUNTS
               set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE =
			decode(DATE_TYPE,'FORCAST','^'||P_PASS_CODE,P_PASS_CODE),
                    RECONCILED_DAYS_ADJUST = (trunc(rec_det.VALUE_DATE) -
                                              trunc(l_s_date)),
                    AMOUNT_DATE          =
			decode(DATE_TYPE,'FORCAST',rec_det.VALUE_DATE,AMOUNT_DATE),
                    DATE_TYPE            = decode(DATE_TYPE,'FORCAST','SETTLE',DATE_TYPE),
                    HCE_AMOUNT           =
			decode(DATE_TYPE,'FORCAST',decode(nvl(HCE_AMOUNT,0),0,HCE_AMOUNT,
			(AMOUNT/HCE_AMOUNT)*(nvl(HCE_AMOUNT,0) + nvl(l_reset_amt,0))),HCE_AMOUNT),
                    AMOUNT               =
			decode(DATE_TYPE,'FORCAST',decode(nvl(AMOUNT,0),0,AMOUNT,nvl(AMOUNT,0) +
			nvl(l_reset_amt,0)),AMOUNT),
                    CASHFLOW_AMOUNT      =
			decode(DATE_TYPE,'FORCAST',decode(nvl(CASHFLOW_AMOUNT,0),0,
			CASHFLOW_AMOUNT,nvl(CASHFLOW_AMOUNT,0) + nvl(l_reset_amt,0)),CASHFLOW_AMOUNT)
                where
                /*
                ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
                       and l_deal_no = 'Y') or (l_deal_no is NULL))
                and
                */
                AMOUNT_DATE between (rec_det.VALUE_DATE - l_days) and
                                         P_CGU$SYSDATE
                and NETOFF_NUMBER = v_netoff_number
                and AMOUNT_TYPE <> 'FACEVAL'
                and CURRENCY =P_CURRENCY
                and RECONCILED_REFERENCE is NULL  -- add
                and RECONCILED_PASS_CODE is NULL
                and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and l_bk_acct = 'Y') or
                      (nvl(l_bk_acct,'%') = '%'))
                and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
                      and l_party = 'Y') or (l_party is NULL))
                and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
                      and l_serial_ref = 'Y') or (l_serial_ref is NULL))
                and DEAL_TYPE like nvl(l_deal_type ,'%')
                and DEAL_SUBTYPE like nvl(l_subtype,'%')
                and PRODUCT_TYPE like nvl(l_product,'%')
                and PORTFOLIO_CODE like nvl(l_portfolio,'%')
                and ((date_type <>'FORCAST' and NVL(P_INCL_RTM, 'N')='N') or NVL(P_INCL_RTM, 'N')='Y');
                If SQL%FOUND then
/***************/
       utl_file.put_line (l_file,'>>----DDA_SUM_RANGE');
       utl_file.put_line (l_file,'>>---- UPD complete deal# '||rtrim(rec_det.particulars));
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                 For C1_Rec in C1(v_netoff_number)
                 Loop
                     Update Xtr_Settlement_Summary
                     Set status = 'R'
                     Where settlement_summary_id = C1_Rec.net_ID;
/***************/
         utl_file.put_line(l_file, '>>----DDA ------');
         utl_file.put_line(l_file, '>>----UPD settlement_summary complete netID '||C1_Rec.net_id);
         utl_file.put_line(l_file, '>>------------------------------------');
/**************/
                 End Loop;
                End if;
           End if;

         update XTR_PAY_REC_RECONCILIATION
                set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE = P_PASS_CODE
                where CURRENT OF REC;
        end if;
        EXIT;
       elsif nvl(rec_det.CREDIT_AMOUNT,0) <> 0 then
        if (((rec_det.CREDIT_AMOUNT) = l_sum_amt and l_amount =
               'Y') or (nvl(l_amount,'N') = 'N')) then
         if rec_det.CREDIT_AMOUNT > l_sum_amt then
                -- amt from reconcile is less than due
                l_reset_amt := (rec_det.CREDIT_AMOUNT - l_sum_amt) /
                                   l_num_recs;
         else
                l_reset_amt := (l_sum_amt - rec_det.CREDIT_AMOUNT) /
                                   l_num_recs;
         end if;
         p_tot_recon := nvl(p_tot_recon,0) + 1;
         P_RECONCILED_YN :='Y';
         open REC_NUM;
         fetch REC_NUM INTO l_rec_nos;
         close REC_NUM;

         if nvl(P_MIN_REC_NOS,9999999) >= l_rec_nos then
                P_MIN_REC_NOS := l_rec_nos;
         end if;
         if nvl(P_MAX_REC_NOS,0) <= l_rec_nos then
                P_MAX_REC_NOS := l_rec_nos;
         end if;
         if P_REC_NOS is NULL then
                P_REC_NOS := l_rec_nos;
         end if;

--dbms_output.put_line('bef UPD ');
         If v_netoff_number is null then
/***************/
       utl_file.put_line (l_file,'>>----2');
       utl_file.put_line (l_file,'>>----inside IF rec#, rec-pass '||l_rec_nos||' - '||p_pass_code);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

               update XTR_DEAL_DATE_AMOUNTS
                set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE =
			decode(DATE_TYPE,'FORCAST','^'||P_PASS_CODE,P_PASS_CODE),
                    RECONCILED_DAYS_ADJUST = (trunc(rec_det.VALUE_DATE) -
                                              trunc(l_s_date)),
                    AMOUNT_DATE          =
			decode(DATE_TYPE,'FORCAST',rec_det.VALUE_DATE,AMOUNT_DATE),
                    DATE_TYPE            = decode(DATE_TYPE,'FORCAST','SETTLE',DATE_TYPE),
                    HCE_AMOUNT           =
			decode(DATE_TYPE,'FORCAST',decode(nvl(HCE_AMOUNT,0),0,HCE_AMOUNT,
			(AMOUNT/HCE_AMOUNT)*(nvl(HCE_AMOUNT,0) + nvl(l_reset_amt,0))),HCE_AMOUNT),
                    AMOUNT               =
			decode(DATE_TYPE,'FORCAST',decode(nvl(AMOUNT,0),0,AMOUNT,nvl(AMOUNT,0) +
			nvl(l_reset_amt,0)),AMOUNT),
                    CASHFLOW_AMOUNT      =
			decode(DATE_TYPE,'FORCAST',decode(nvl(CASHFLOW_AMOUNT,0),0,
			CASHFLOW_AMOUNT,nvl(CASHFLOW_AMOUNT,0) + nvl(l_reset_amt,0)),CASHFLOW_AMOUNT)
                where AMOUNT_DATE between (rec_det.VALUE_DATE - l_days) and
                      (rec_det.VALUE_DATE - l_days)
                and ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
                      and l_deal_no = 'Y') or (l_deal_no is NULL))
                and AMOUNT_DATE <= P_CGU$SYSDATE
                and NETOFF_NUMBER is NULL
                and AMOUNT_TYPE <> 'FACEVAL'
                and CURRENCY =P_CURRENCY
                and RECONCILED_REFERENCE is NULL  -- add
                and RECONCILED_PASS_CODE is NULL
                and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and l_bk_acct = 'Y') or
                      (nvl(l_bk_acct,'%') = '%'))
                and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
                      and l_party = 'Y') or (l_party is NULL))
                and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
                      and l_serial_ref = 'Y') or (l_serial_ref is NULL))
                and DEAL_TYPE like nvl(l_deal_type ,'%')
                and DEAL_SUBTYPE like nvl(l_subtype,'%')
                and PRODUCT_TYPE like nvl(l_product,'%')
                and PORTFOLIO_CODE like nvl(l_portfolio,'%')
                and ((date_type <>'FORCAST' and NVL(P_INCL_RTM, 'N')='N') or NVL(P_INCL_RTM, 'N')='Y');
                If SQL%FOUND then
/***************/
       utl_file.put_line (l_file,'>>----2');
       utl_file.put_line (l_file,'>>---- UPD complete deal# '||rtrim(rec_det.particulars));
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                    For C2_Rec in C2(l_rec_nos)
                    Loop
                        Update Xtr_Settlement_Summary
                        Set status = 'R'
                        Where settlement_number = C2_Rec.Settlement_Number;
/***************/
       utl_file.put_line (l_file,'>>----DDA_SUM_RANGE');
       utl_file.put_line (l_file,'>>---- UPD settlement_summary complete settle# '||c2_rec.settlement_number);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                    End Loop;
                End if;
           Else
/***************/
       utl_file.put_line (l_file,'>>----2');
       utl_file.put_line (l_file,'>>---- inside ELSE net#, rec#, rec-pass '||v_netoff_number||' - '||l_rec_nos||' - '||p_pass_code);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

               update XTR_DEAL_DATE_AMOUNTS
                set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE =
			decode(DATE_TYPE,'FORCAST','^'||P_PASS_CODE,P_PASS_CODE),
                    RECONCILED_DAYS_ADJUST = (trunc(rec_det.VALUE_DATE) -
                                              trunc(l_s_date)),
                    AMOUNT_DATE          =
			decode(DATE_TYPE,'FORCAST',rec_det.VALUE_DATE,AMOUNT_DATE),
                    DATE_TYPE            = decode(DATE_TYPE,'FORCAST','SETTLE',DATE_TYPE),
                    HCE_AMOUNT           =
			decode(DATE_TYPE,'FORCAST',decode(nvl(HCE_AMOUNT,0),0,HCE_AMOUNT,
			(AMOUNT/HCE_AMOUNT)*(nvl(HCE_AMOUNT,0) + nvl(l_reset_amt,0))),HCE_AMOUNT),
                    AMOUNT               =
			decode(DATE_TYPE,'FORCAST',decode(nvl(AMOUNT,0),0,AMOUNT,nvl(AMOUNT,0) +
			nvl(l_reset_amt,0)),AMOUNT),
                    CASHFLOW_AMOUNT      =
			decode(DATE_TYPE,'FORCAST',decode(nvl(CASHFLOW_AMOUNT,0),0,
			CASHFLOW_AMOUNT,nvl(CASHFLOW_AMOUNT,0) + nvl(l_reset_amt,0)),CASHFLOW_AMOUNT)
                where AMOUNT_DATE between (rec_det.VALUE_DATE - l_days) and
                      (rec_det.VALUE_DATE - l_days)
                /*
                and ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
                      and l_deal_no = 'Y') or (l_deal_no is NULL))
                */
                and AMOUNT_DATE <= P_CGU$SYSDATE
                and NETOFF_NUMBER = v_netoff_number
                and AMOUNT_TYPE <> 'FACEVAL'
                and CURRENCY =P_CURRENCY
                and RECONCILED_REFERENCE is NULL  -- add
                and RECONCILED_PASS_CODE is NULL
                and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and l_bk_acct = 'Y') or
                      (nvl(l_bk_acct,'%') = '%'))
                and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
                      and l_party = 'Y') or (l_party is NULL))
                and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
                      and l_serial_ref = 'Y') or (l_serial_ref is NULL))
                and DEAL_TYPE like nvl(l_deal_type ,'%')
                and DEAL_SUBTYPE like nvl(l_subtype,'%')
                and PRODUCT_TYPE like nvl(l_product,'%')
                and PORTFOLIO_CODE like nvl(l_portfolio,'%')
                and ((date_type <>'FORCAST' and NVL(P_INCL_RTM, 'N')='N') or NVL(P_INCL_RTM, 'N')='Y');
                If SQL%FOUND then
/***************/
       utl_file.put_line (l_file,'>>----2');
       utl_file.put_line (l_file,'>>---- UPD complete deal# '||rtrim(Rec_det.particulars));
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                 For C1_Rec in C1(v_netoff_number)
                 Loop
                     Update Xtr_Settlement_Summary
                     Set status = 'R'
                     Where settlement_summary_id = C1_Rec.net_ID;
/***************/
         utl_file.put_line(l_file, '>>----DDA ------');
         utl_file.put_line(l_file, '>>----UPD settlement_summary complete netID '||C1_Rec.net_id);
         utl_file.put_line(l_file, '>>------------------------------------');
/**************/
                 End Loop;
                End if;
           End if;

         update XTR_PAY_REC_RECONCILIATION
                set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE = P_PASS_CODE
                where CURRENT OF REC;
        end if;
              EXIT;
       end if;
      END LOOP; -- 6 (in 4)
      close DDA_SUM_RANGE;
     else
	 /* else check amount equal to each other --> no sum */
          IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
             xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>> ELSE check amount equal each other, NO SUM! ');
          END IF;
	 -- Check amounts equal each other.Do Not Sum amounts for a date or range of dates.
	 -- The imported amount has to equal a single transaction amount.
      open DDA;
      l_num_recs :=0;

   	 IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   	    xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>> FETCH DDA into l_sum_amt, l_num_recs, l_one_date ');
   	 END IF;
      fetch DDA INTO l_sum_amt,l_num_recs,l_one_date, v_netoff_number;
--dbms_output.put_line('DDA amt, no-recs, date, net# '||l_sum_amt||' - '||l_num_recs||' - '||l_one_date||' - '||v_netoff_number);
/***************/
       utl_file.put_line (l_file,'>>----DDA');
       utl_file.put_line (l_file,'>>----net#, date, amt, no-recs '||v_netoff_number||' - '||l_one_date||' - '||l_sum_amt||' - '||l_num_recs);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

   	 IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   	    xtr_debug_pkg.debug('P_RECONCILE: ' || 'value after fetch -----------------');
	    xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_deal_no = ' || l_deal_no);
	    xtr_debug_pkg.debug('P_RECONCILE: ' || 'rec_det.value_date = ' || to_char(rec_det.value_date));
	    xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_date = ' || l_date);
	 END IF;
	 xtr_debug_pkg.debug('P_CGU$SYSDATE = ' || P_CGU$SYSDATE);
	 IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	    xtr_debug_pkg.debug('P_RECONCILE: ' || 'P_CURRENCY = ' || P_CURRENCY);
	    xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_bk_acct = ' || l_bk_acct);
	    xtr_debug_pkg.debug('P_RECONCILE: ' || 'rec_det.DEBIT_AMOUNT = ' || to_char(rec_det.DEBIT_AMOUNT));
	    xtr_debug_pkg.debug('P_RECONCILE: ' || 'rec_det.CREDIT_AMOUNT = ' || to_char(rec_det.CREDIT_AMOUNT));
   	    xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_sum_amt = '|| to_char(l_sum_amt));
    	    xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_num_recs = '|| to_char(l_num_recs));
  	    xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_one_date = '|| to_char(l_one_date));
  	    xtr_debug_pkg.debug('P_RECONCILE: ' || '-------------------------------');
  	 END IF;

      if nvl(l_num_recs,0) > 0 then  ---  bug 5353780
       p_tot_recon := nvl(p_tot_recon,0) + 1;
       P_RECONCILED_YN :='Y';
       l_sum_amt := nvl(rec_det.DEBIT_AMOUNT,0) +
                                 nvl(rec_det.CREDIT_AMOUNT,0);
       open REC_NUM;
            IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
               xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>> FETCH REC_NUM into l_rec_nos');
            END IF;
       fetch REC_NUM INTO l_rec_nos;
	      IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	         xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_rec_nos = '|| to_char(l_rec_nos));
	      END IF;
       close REC_NUM;
       if nvl(P_MIN_REC_NOS,9999999) >= l_rec_nos then
                P_MIN_REC_NOS := l_rec_nos;
       end if;
       if nvl(P_MAX_REC_NOS,0) <= l_rec_nos then
                P_MAX_REC_NOS := l_rec_nos;
       end if;
       if P_REC_NOS is NULL then
                P_REC_NOS := l_rec_nos;
       end if;
	     IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	        xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>> UPDATE DDA >>>>>>>>>>>>>>');
	     END IF;

--dbms_output.put_line('bef UPD ');
        If v_netoff_number is null then
/***************/
       utl_file.put_line (l_file,'>>----DDA');
       utl_file.put_line (l_file,'>>---- inside IF , rec#, rec-pass '||l_rec_nos||' - '||p_pass_code);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

                update XTR_DEAL_DATE_AMOUNTS
                set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE =
			decode(DATE_TYPE,'FORCAST','^'||P_PASS_CODE,P_PASS_CODE),
                    RECONCILED_DAYS_ADJUST = (trunc(rec_det.VALUE_DATE) -
                                              trunc(l_one_date)),
                    AMOUNT_DATE          =
			decode(DATE_TYPE,'FORCAST',rec_det.VALUE_DATE,AMOUNT_DATE),
                    DATE_TYPE            = decode(DATE_TYPE,'FORCAST','SETTLE',DATE_TYPE),
                    AMOUNT               =
			decode(DATE_TYPE,'FORCAST',decode(nvl(AMOUNT,0),0,AMOUNT,abs(nvl(l_sum_amt,0))),AMOUNT),
                   HCE_AMOUNT           =
			decode(DATE_TYPE,'FORCAST',decode(nvl(HCE_AMOUNT,0),0,HCE_AMOUNT,
			(AMOUNT/HCE_AMOUNT)*abs(nvl(l_sum_amt,0))),HCE_AMOUNT),
                    CASHFLOW_AMOUNT      =
			decode(DATE_TYPE,'FORCAST',decode(nvl(CASHFLOW_AMOUNT,0),0,
			CASHFLOW_AMOUNT,nvl(l_sum_amt,0)),CASHFLOW_AMOUNT)
     	    where ((to_char(DEAL_NUMBER) = ltrim(rtrim(rec_det.PARTICULARS))
            and nvl(l_deal_no,'N') = 'Y')
            or (l_deal_no is NULL )) --- modify
            and AMOUNT_DATE = l_one_date
            and NETOFF_NUMBER is NULL
	    and AMOUNT_TYPE <> 'FACEVAL'
            and CURRENCY =P_CURRENCY
            and AMOUNT_DATE <= P_CGU$SYSDATE
            and RECONCILED_REFERENCE is NULL
            and RECONCILED_PASS_CODE is NULL
            and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and nvl(l_bk_acct,'N') = 'Y') or
              (nvl(l_bk_acct,'%') = '%'))
            and ((CASHFLOW_AMOUNT < 0 and rec_det.DEBIT_AMOUNT is NOT NULL)
                and ((abs(CASHFLOW_AMOUNT) = rec_det.DEBIT_AMOUNT and nvl(l_amount,'N') =
                   'Y') or (nvl(l_amount,'N') = 'N' and date_type='FORCAST'))  -----???
                or (nvl(rec_det.DEBIT_AMOUNT,0) = 0))
            and ((CASHFLOW_AMOUNT > 0 and rec_det.CREDIT_AMOUNT is NOT NULL)
            and ((abs(CASHFLOW_AMOUNT) = rec_det.CREDIT_AMOUNT
            and nvl(l_amount,'N')='Y') or (nvl(l_amount,'N') = 'N'))
                 or (nvl(rec_det.CREDIT_AMOUNT,0) = 0))
            and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
              and nvl(l_party,'N') = 'Y') or (l_party is NULL))
            and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
                and nvl(l_serial_ref,'N') = 'Y') or (l_serial_ref is NULL))
            and DEAL_TYPE like nvl(l_deal_type ,'%')
            and DEAL_SUBTYPE like nvl(l_subtype,'%')
            and PRODUCT_TYPE like nvl(l_product,'%')
            and PORTFOLIO_CODE like nvl(l_portfolio,'%')
            and ((date_type <>'FORCAST' and NVL(P_INCL_RTM, 'N')='N') or NVL(P_INCL_RTM, 'N')='Y')
            and rownum < 2;  -- bug 5353780
            If SQL%FOUND then
/***************/
       utl_file.put_line (l_file,'>>----DDA');
       utl_file.put_line (l_file,'>>---- UPD complete deal# '||rtrim(rec_det.particulars));
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                For C2_Rec in C2(l_rec_nos)
                Loop
                     Update Xtr_Settlement_Summary
                     Set status = 'R'
                     Where settlement_number = C2_Rec.Settlement_Number;
/***************/
       utl_file.put_line (l_file,'>>----DDA');
       utl_file.put_line (l_file,'>>---- UPD settlement_summary complete settle# '||c2_rec.settlement_number);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                End Loop;
            End if;
        Else
/***************/
       utl_file.put_line (l_file,'>>----DDA');
       utl_file.put_line (l_file,'>>---- inside ELSE rec#, rec-pass '||l_rec_nos||' - '||p_pass_code);
       utl_file.put_line (l_file,'>>------------------------------');
/***************/

                update XTR_DEAL_DATE_AMOUNTS
                set RECONCILED_REFERENCE = l_rec_nos,
                    RECONCILED_PASS_CODE =
			decode(DATE_TYPE,'FORCAST','^'||P_PASS_CODE,P_PASS_CODE),
                    RECONCILED_DAYS_ADJUST = (trunc(rec_det.VALUE_DATE) -
                                              trunc(l_one_date)),
                    AMOUNT_DATE          =
			decode(DATE_TYPE,'FORCAST',rec_det.VALUE_DATE,AMOUNT_DATE),
                    DATE_TYPE            = decode(DATE_TYPE,'FORCAST','SETTLE',DATE_TYPE),
                    AMOUNT               =
			decode(DATE_TYPE,'FORCAST',decode(nvl(AMOUNT,0),0,AMOUNT,abs(nvl(l_sum_amt,0))),AMOUNT),
                   HCE_AMOUNT           =
			decode(DATE_TYPE,'FORCAST',decode(nvl(HCE_AMOUNT,0),0,HCE_AMOUNT,
			(AMOUNT/HCE_AMOUNT)*abs(nvl(l_sum_amt,0))),HCE_AMOUNT),
                    CASHFLOW_AMOUNT      =
			decode(DATE_TYPE,'FORCAST',decode(nvl(CASHFLOW_AMOUNT,0),0,
			CASHFLOW_AMOUNT,nvl(l_sum_amt,0)),CASHFLOW_AMOUNT)
     	    where
            /*
            ((to_char(DEAL_NUMBER) = ltrim((rtrim(rec_det.PARTICULARS))
            and nvl(l_deal_no,'N') = 'Y')
            or (l_deal_no is NULL )) --- modify
            and
            */
            AMOUNT_DATE = l_one_date
            and NETOFF_NUMBER = v_netoff_number
	    and AMOUNT_TYPE <> 'FACEVAL'
            and CURRENCY =P_CURRENCY
            and AMOUNT_DATE <= P_CGU$SYSDATE
            and RECONCILED_REFERENCE is NULL
            and RECONCILED_PASS_CODE is NULL
            and ((ACCOUNT_NO = P_ACCOUNT_NUMBER and nvl(l_bk_acct,'N') = 'Y') or
              (nvl(l_bk_acct,'%') = '%'))
            /*
            and ((CASHFLOW_AMOUNT < 0 and rec_det.DEBIT_AMOUNT is NOT NULL)
                and ((abs(CASHFLOW_AMOUNT) = rec_det.DEBIT_AMOUNT and nvl(l_amount,'N') =
                   'Y') or (nvl(l_amount,'N') = 'N' and date_type='FORCAST'))  -----???
                or (nvl(rec_det.DEBIT_AMOUNT,0) = 0))
            and ((CASHFLOW_AMOUNT > 0 and rec_det.CREDIT_AMOUNT is NOT NULL)
            and ((abs(CASHFLOW_AMOUNT) = rec_det.CREDIT_AMOUNT
            and nvl(l_amount,'N')='Y') or (nvl(l_amount,'N') = 'N'))
                 or (nvl(rec_det.CREDIT_AMOUNT,0) = 0))
            */
            and ((CPARTY_CODE = substr(rec_det.PARTY_NAME,1,7)
              and nvl(l_party,'N') = 'Y') or (l_party is NULL))
            and ((SERIAL_REFERENCE = rtrim(rec_det.SERIAL_REFERENCE)
                and nvl(l_serial_ref,'N') = 'Y') or (l_serial_ref is NULL))
            and DEAL_TYPE like nvl(l_deal_type ,'%')
            and DEAL_SUBTYPE like nvl(l_subtype,'%')
            and PRODUCT_TYPE like nvl(l_product,'%')
            and PORTFOLIO_CODE like nvl(l_portfolio,'%')
            and ((date_type <>'FORCAST' and NVL(P_INCL_RTM, 'N')='N') or NVL(P_INCL_RTM, 'N')='Y');
            If SQL%FOUND then
/***************/
       utl_file.put_line (l_file,'>>----DDA -----');
       utl_file.put_line (l_file,'>>---- UPD complete deal# '||rtrim(Rec_det.particulars));
       utl_file.put_line (l_file,'>>------------------------------');
/***************/
                 For C1_Rec in C1(v_netoff_number)
                 Loop
                     Update Xtr_Settlement_Summary
                     Set status = 'R'
                     Where settlement_summary_id = C1_Rec.net_ID;
/***************/
         utl_file.put_line(l_file, '>>----DDA ------');
         utl_file.put_line(l_file, '>>----UPD settlement_summary complete netID '||C1_Rec.net_id);
         utl_file.put_line(l_file, '>>------------------------------------');
/**************/
                 End Loop;
            End if;
        End if;

             IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
                xtr_debug_pkg.debug('P_RECONCILE: ' || '>>>>> UPDATE XTR_PAY_REC_REOCNCILIATION ');
                xtr_debug_pkg.debug('P_RECONCILE: ' || 'l_rec_nos = ' || to_char(l_rec_nos));
             END IF;
       update XTR_PAY_REC_RECONCILIATION
              set RECONCILED_REFERENCE = l_rec_nos,
                  RECONCILED_PASS_CODE = P_PASS_CODE
              where CURRENT OF REC;

      end if;
      close DDA;
     end if;

     END LOOP; -- 4 (in 2)
	  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	     xtr_debug_pkg.debug('P_RECONCILE: ' || 'END LOOP -- 4 ');
	  END IF;
     close REC;
     IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
        xtr_debug_pkg.debug('P_RECONCILE: ' || 'END LOOP -- 2 ');
     END IF;
    END LOOP; -- 2
      close PASSES;
      if PASSES%ISOPEN then close PASSES; end if;
      if PASS_DETAILS%ISOPEN then close PASS_DETAILS; end if;
      if REC%ISOPEN then close REC; end if;
      if REC_NUM%ISOPEN then close REC_NUM; end if;
      if DDA%ISOPEN then close DDA; end if;
      if DDA_SUM_DATE%ISOPEN then close DDA_SUM_DATE; end if;
      if DDA_SUM_RANGE%ISOPEN then close DDA_SUM_RANGE; end if;
IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   xtr_debug_pkg.debug('END P_RECONCILE >>>>>>>>>>');
END IF;

   utl_file.put_line (l_file,' ');
   utl_file.put_line (l_file,'>> Log file is located at '||l_dirname||'/xtraurec.log');
   utl_file.put_line (l_file,'>>----------------------------------------------------------------');
   utl_file.fclose(l_file);

end P_RECONCILE;

END XTR_AUTO_RECONCILIATION;

/
