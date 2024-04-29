--------------------------------------------------------
--  DDL for Package Body FV_GOALS_224
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_GOALS_224" as
--$Header: FVTI224B.pls 120.12.12010000.1 2008/07/28 06:32:07 appldev ship $
--	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
  g_module_name VARCHAR2(100) ;

-- ============================================================================

	retcode				varchar2(255);
	errbuf 				varchar2(255);
--	req_id				number;
	var_count			number;
--	var_message			varchar2(200);


--01
	v_receipt_amt_goals		varchar2(14);
	v_receipt_amt			number;
--02
	v_disbursement_amt_goals	varchar2(14);
	v_disbursement_amt		number;
--03
	v_pmt_tran_current_amt_goals	varchar2(14);
	v_pmt_tran_current_amt		number;
--04-13
	v_pmt_tran_prior_amt_goals	varchar2(14);
	v_pmt_tran_prior_amt		number;
--14
	v_collection_rcvd_amt_goals	varchar2(14);
	v_collection_rcvd_amt		number;
--15
	v_deposit_current_amt_goals	varchar2(14);
	v_deposit_current_amt		number;
--16-25
	v_deposit_prior_amt_goals	varchar2(14);
	v_deposit_prior_amt		number;
	v_deposit_prior_amt_record_26       number;
--26
	v_net_total_amt_goals		varchar2(14);
	v_net_total_amt			number;

	v_set_of_books_id		gl_ledgers_public_v.ledger_id%TYPE;

--	v_98				varchar2(14);
--	v_99				varchar2(14);

	v_count				varchar2(14);
	v_count_per_alc			varchar2(14);
--	V_length			number(2);
--	v_org_id			number(15);
--	v_supplemental_ind		varchar2(1);


--	v_goals_224_record_type		varchar2(2);

	v_record_type			varchar2(2);
	v_orig_suppl_ind		varchar2(1);
	v_alc_code			varchar2(8);
	v_treasury_symbol		varchar2(20);
	v_entry_number			varchar2(2);
	v_transaction_date		varchar2(4);
	v_reporting_date		varchar2(6);
        v_end_date			date;

	v_record			varchar2(57);
	v_record_01			varchar2(57);
	v_record_02			varchar2(57);
	v_record_03			varchar2(57);

	v_record_14			varchar2(57);
	v_record_15			varchar2(57);

	v_record_26			varchar2(57);
	v_record_98			varchar2(57);
	v_record_99			varchar2(57);

	gl_period_name			varchar2(30);
	flex_num             		number;
	statuses_period_type 		varchar2(25);
	vp_alc  Ap_Bank_Accounts_All.agency_location_code%TYPE;

-- 01, receipts
	CURSOR		cur_receipts IS
	SELECT	rpad(nvl(substr(replace(fst.treasury_symbol,'-',''),1,20),'                    '),20, ' '), nvl(sum(amount), 0), nvl(supplemental_flag,0)
	FROM       	fv_sf224_temp fst
	WHERE     	column_group in (20,21)
      	AND        	reported_month in ('CURRENT', 'CURRENT/PRIOR')
	AND		alc_code = v_alc_code
        AND fst.sf224_processed_flag = 'Y'
        AND fst.end_period_date < v_end_date
        AND fst.record_category = 'GLRECORD'
	GROUP BY 	fst.treasury_symbol,supplemental_flag;

-- 02, disbursements
	CURSOR		cur_disbursements IS
	SELECT		rpad(nvl(substr(replace(fst.treasury_symbol,'-',''),1,20),'                    '),20, ' '),
			nvl(sum(amount), 0),nvl(supplemental_flag,0)
	FROM       	fv_sf224_temp fst
	WHERE     	column_group in (30,31)
      	AND        	reported_month in ('CURRENT', 'CURRENT/PRIOR')
	AND		alc_code = v_alc_code
        AND fst.sf224_processed_flag = 'Y'
        AND fst.end_period_date < v_end_date
        AND fst.record_category = 'GLRECORD'
	GROUP BY 	fst.treasury_symbol,supplemental_flag;

-- 04 - 13
	CURSOR		cur_pmt_tran_prior_amt IS
	SELECT     	distinct to_char(accomplish_date, 'MMYY'),
			nvl(sum(amount * decode(column_group, 21,-1,1)),0),
			nvl(supplemental_flag,0)
	FROM        	fv_sf224_temp fst
	WHERE      	column_group in (21, 30)
	AND         	reported_month = 'CURRENT/PRIOR'
	AND		alc_code = v_alc_code
        AND fst.sf224_processed_flag = 'Y'
        AND fst.end_period_date < v_end_date
        AND fst.record_category = 'GLRECORD'
	GROUP BY 	to_char(accomplish_date,'MMYY'),supplemental_flag
  HAVING nvl(sum(amount * decode(column_group, 21,-1,1)),0) <> 0
	ORDER BY 	to_char(accomplish_date,'MMYY') desc;

-- 16 - 25
	CURSOR		cur_deposit_prior_amt IS
	SELECT      	to_char(accomplish_date,'MMYY'),
			nvl(sum(amount * decode(column_group, 31,-1,1)),0),
			nvl(supplemental_flag,0)
	FROM        	fv_sf224_temp fst
	WHERE      	column_group in (20,31)
	AND         	reported_month in ('CURRENT/PRIOR')
	AND		alc_code = v_alc_code
        AND fst.sf224_processed_flag = 'Y'
        AND fst.end_period_date < v_end_date
        AND fst.record_category = 'GLRECORD'
	GROUP BY 	to_char(accomplish_date,'MMYY'),supplemental_flag
  HAVING nvl(sum(amount * decode(column_group, 31,-1,1)),0) <> 0
	ORDER BY 	to_char(accomplish_date,'MMYY') desc;

	CURSOR 	get_alc_cur IS
	SELECT DISTINCT alc_code
	FROM Fv_Sf224_Temp fst
	WHERE set_of_books_id = v_set_of_books_id
	AND fst.sf224_processed_flag = 'Y'
	AND fst.record_category = 'GLRECORD'
	AND fst.end_period_date < v_end_date
	AND fst.alc_code = DECODE (vp_alc, 'ALL', fst.alc_code, vp_alc);


  CURSOR get_zeroalc_cur
  (
    c_set_of_books_id       NUMBER,
    c_gl_period             VARCHAR2,
    c_alc                   VARCHAR2,
    c_partial_or_full       VARCHAR2,
    c_business_activity     VARCHAR2,
    c_gwa_reporter_category VARCHAR2
  )IS
  select fv.agency_location_code
   from fv_alc_business_activity_v fv
  where set_of_books_id = c_set_of_books_id
    and period_name = c_gl_period
    AND c_partial_or_full = 'Partial'
    and c_alc ='ALL'
    and c_business_activity <>'ALL'
    and business_activity_code = c_business_activity
    and c_gwa_reporter_category <> 'ALL'
    and GWA_REPORTER_CATEGORY_CODE =c_gwa_reporter_category
    AND NOT EXISTS(SELECT DISTINCT c.alc_code
                     FROM fv_sf224_temp c
                    WHERE c.set_of_books_id = c_set_of_books_id
                      AND c.alc_code = fv.agency_location_code
	              AND record_category = 'GLRECORD'
                      AND sf224_processed_flag = 'Y'
		      AND alc_code = fv.agency_location_code
                      AND end_period_date < v_end_date)
  UNION
  select agency_location_code
    from fv_alc_business_activity_v fv
   where set_of_books_id=c_set_of_books_id
     and period_name =  c_gl_period
     AND c_partial_or_full = 'Partial'
     and c_alc  ='ALL'
     and c_business_activity='ALL'
     and business_activity_code in (select lookup_code
                                      from fv_lookup_codes
                                     where LOOKUP_TYPE = 'FV_SF224_BUSINESS_ACTIVITY')
     and c_gwa_reporter_category = 'ALL'
     and GWA_REPORTER_CATEGORY_CODE in (select lookup_code
                                          from fv_lookup_codes
                                         where LOOKUP_TYPE = 'FV_SF224_GWA_REPORTER_CATEGORY' )
     AND NOT EXISTS(SELECT DISTINCT c.alc_code
                      FROM fv_sf224_temp c
                     WHERE c.set_of_books_id = c_set_of_books_id
                       AND c.alc_code = fv.agency_location_code
                       AND record_category = 'GLRECORD'
                       AND sf224_processed_flag = 'Y'
		       AND alc_code = fv.agency_location_code
                       AND end_period_date < v_end_date)
  UNION
  select agency_location_code
    from fv_alc_business_activity_v fv
   where set_of_books_id=c_set_of_books_id
     and period_name = c_gl_period
     AND c_partial_or_full = 'Partial'
     and c_alc  ='ALL'
     and c_business_activity ='ALL'
     and business_activity_code in ( select lookup_code
                                       from fv_lookup_codes
                                      where LOOKUP_TYPE = 'FV_SF224_BUSINESS_ACTIVITY')
     and c_gwa_reporter_category  <> 'ALL'
     and GWA_REPORTER_CATEGORY_CODE = c_gwa_reporter_category
     AND NOT EXISTS(SELECT DISTINCT c.alc_code
                      FROM fv_sf224_temp c
                     WHERE c.set_of_books_id = c_set_of_books_id
                       AND c.alc_code = fv.agency_location_code
                       AND record_category = 'GLRECORD'
                       AND sf224_processed_flag = 'Y'
		       AND alc_code = fv.agency_location_code
                       AND end_period_date < v_end_date)
  UNION
  select agency_location_code
    from fv_alc_business_activity_v fv
    where set_of_books_id=c_set_of_books_id
      and period_name =  c_gl_period
      AND c_partial_or_full = 'Partial'
      and c_alc  ='ALL'
      and c_business_activity <>'ALL'
      and business_activity_code =c_business_activity
      and c_gwa_reporter_category  = 'ALL'
      and GWA_REPORTER_CATEGORY_CODE in (select fmap.gwa_reporter_category_code
                                           from fv_sf224_map fmap
                                          where fmap.business_activity_code= c_business_activity )
      AND NOT EXISTS(SELECT DISTINCT c.alc_code
                       FROM fv_sf224_temp c
                      WHERE c.set_of_books_id = c_set_of_books_id
                        AND c.alc_code = fv.agency_location_code
                        AND record_category = 'GLRECORD'
                        AND sf224_processed_flag = 'Y'
			AND alc_code = fv.agency_location_code
                        AND end_period_date < v_end_date)
  UNION
  select distinct fab.agency_location_code
    from fv_alc_business_activity_v fab
    where fab.set_of_books_id=c_set_of_books_id
      AND c_partial_or_full = 'Full'
      and c_alc  ='ALL'
      and fab.agency_location_code not in (select agency_location_code
                                             from fv_alc_business_activity_v fab1
                                             where fab1.period_name =c_gl_period)
      AND NOT EXISTS(SELECT DISTINCT c.alc_code
                       FROM fv_sf224_temp c
                      WHERE c.set_of_books_id = c_set_of_books_id
                        AND c.alc_code = fab.agency_location_code
                        AND record_category = 'GLRECORD'
                        AND sf224_processed_flag = 'Y'
			AND alc_code = fab.agency_location_code
                        AND end_period_date < v_end_date);


-----------------------------------------------------------------------------------------------------------------------

PROCEDURE main(	errbuf	 OUT NOCOPY VARCHAR2,
			retcode	 OUT NOCOPY VARCHAR2,
                        p_ledger_id     IN      NUMBER,
			p_gl_period   	IN	VARCHAR2,
			p_alc   	IN	VARCHAR2,
			p_partial_or_full IN VARCHAR2,
			p_business_activity IN VARCHAR2,
			p_gwa_reporter_category IN VARCHAR2) IS
  l_module_name VARCHAR2(200) ;

BEGIN
 l_module_name := g_module_name || 'MAIN';
        v_set_of_books_id := p_ledger_id;

        gl_period_name := p_gl_period;
	vp_alc := p_alc;

        SELECT  chart_of_accounts_id
        INTO    flex_num
        FROM    gl_ledgers_public_v
        WHERE   ledger_id = v_set_of_books_id;

        SELECT  distinct period_type
        INTO    statuses_period_type
        FROM    gl_period_statuses
        WHERE   application_id  = '101'
        AND     ledger_id = v_set_of_books_id;

        SELECT  to_char(end_date,'YYMMDD'),
                TRUNC(end_date)+1
        INTO    v_reporting_date,
                v_end_date
        FROM    gl_periods glp,
                gl_ledgers_public_v gsob
        WHERE   glp.period_name                 = gl_period_name
        AND     glp.period_type                 = statuses_period_type
        AND     gsob.ledger_id            = v_set_of_books_id
        AND     gsob.chart_of_accounts_id       = flex_num
        AND     glp.period_set_name             = gsob.period_set_name;


        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE REPORTING DATE IS ' || V_REPORTING_DATE);
        END IF;

	DELETE FROM FV_GOALS_224_TEMP;

	COMMIT;

	OPEN get_alc_cur;
	LOOP
	  FETCH get_alc_cur INTO v_alc_code;
 	  EXIT WHEN get_alc_cur%NOTFOUND;
	  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PROCESSING GOALS FOR ALC = ' ||V_ALC_CODE ||
				' from the Fv_Sf224_Temp table');
	  END IF;

	  SELECT count(*)
      	  INTO	var_count
	  FROM 	fv_sf224_temp fst
	  where	set_of_books_id = v_set_of_books_id
	  and  alc_code = v_alc_code
          AND fst.sf224_processed_flag = 'Y'
          AND fst.end_period_date < v_end_date
          AND fst.record_category = 'GLRECORD';

 	  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VAR_COUNT IS ' || VAR_COUNT);
 	  END IF;

	  if var_count > 0 THEN
		process_record_type_01;
		process_record_type_02;
		process_record_type_03;
		process_record_type_04_13;
		process_record_type_14;
		process_record_type_15;
		process_record_type_16_25;
		process_record_type_26;
		process_record_type_98;
	  else
	        process_record_type_03;
	        process_record_type_26;
	        process_record_type_98;
	  end if;
        END LOOP;

	OPEN get_zeroalc_cur(v_set_of_books_id,p_gl_period, p_alc, p_partial_or_full, p_business_activity, p_gwa_reporter_category);
	LOOP
	  FETCH get_zeroalc_cur INTO v_alc_code;
 	  EXIT WHEN get_zeroalc_cur%NOTFOUND;

	  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PROCESSING GOALS FOR ALC = ' ||V_ALC_CODE ||
		' for the zero activity, for record types 3, 26 and 98.');
	  END IF;

	  process_record_type_03;
	  process_record_type_26;
	  process_record_type_98;
       END LOOP;

       process_record_type_99;

EXCEPTION
   When TOO_MANY_ROWS  then
	if cur_receipts%ISOPEN then
	  close cur_receipts;
	end if;
	if cur_disbursements%ISOPEN then
	  close cur_disbursements;
	end if;
	if cur_pmt_tran_prior_amt%ISOPEN then
	  close cur_pmt_tran_prior_amt;
	end if;
	if cur_deposit_prior_amt%ISOPEN then
	  close cur_deposit_prior_amt;
	end if;
  When OTHERS then
	errbuf:=sqlerrm;
	retcode:= -1;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
	if cur_receipts%ISOPEN then
	  close cur_receipts;
	end if;
	if cur_disbursements%ISOPEN then
	  close cur_disbursements;
	end if;
	if cur_pmt_tran_prior_amt%ISOPEN then
	  close cur_pmt_tran_prior_amt;
	end if;
	if cur_deposit_prior_amt%ISOPEN then
	  close cur_deposit_prior_amt;
	end if;

	return;
END MAIN;

------------------------------------------------------------------------------------------------
PROCEDURE process_record_type_01 IS
  l_module_name VARCHAR2(200) ;
BEGIN
 l_module_name := g_module_name || 'process_record_type_01';
--- Getting amount for record type = 01, receipts

	OPEN 		cur_receipts;
	LOOP
	FETCH		cur_receipts INTO v_treasury_symbol, v_receipt_amt,
				v_orig_suppl_ind;
			EXIT when cur_receipts%NOTFOUND;

	IF		v_receipt_amt >= 0 THEN
			v_receipt_amt_goals := replace(replace(to_char(v_receipt_amt,'000000000000.00'),'.',''), ' ', '');
	ELSE
			v_receipt_amt_goals := replace(replace(to_char(v_receipt_amt,'00000000000.00'),'.',''), ' ', '');
	END IF;


	v_record_type	:= '01';
	v_entry_number 	:= '01';

	v_transaction_date := '    ';

	v_record_01	:= 	v_record_type		||
				v_orig_suppl_ind		||
				v_alc_code 			||
				v_treasury_symbol		||
				v_entry_number		||
				v_receipt_amt_goals	||
				v_transaction_date	||
				v_reporting_date;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V RECORD TYPE IS ' || V_RECORD_TYPE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V ORIG_SUPPL_IND IS ' || V_ORIG_SUPPL_IND);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE TREASURY SYMBOL IS ' || V_TREASURY_SYMBOL);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE RECEIPT AMOUNT IS ' || V_RECEIPT_AMT_GOALS);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE ENTRY NUMBER FOR RECEIPT 01 IS '|| V_ENTRY_NUMBER);
	END IF;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECORD 01 IS '|| V_RECORD_01);
	END IF;

	IF (v_alc_code IS NOT NULL) AND (v_receipt_amt <> 0)THEN
	  insert into fv_goals_224_temp(goals_224_temp_id, goals_224_record_type, alc_code, goals_224_record, supplemental_flag)
	  values(fv_goals_224_temp_id_s.nextval, v_record_type, v_alc_code, v_record_01, v_orig_suppl_ind);
      END IF;

	v_treasury_symbol	:= 	NULL;

	END LOOP;
	close cur_receipts;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := -1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RAISE;
END process_record_type_01;
------------------------------------------------------------------------------------------------
PROCEDURE process_record_type_02 IS
  l_module_name VARCHAR2(200) ;
BEGIN
 l_module_name := g_module_name || 'process_record_type_02';
-- Getting amount for record type = 02, disbursements

	OPEN 			cur_disbursements;
	LOOP
	FETCH			cur_disbursements INTO v_treasury_symbol,
			v_disbursement_amt, v_orig_suppl_ind;
				EXIT when cur_disbursements%NOTFOUND;

	IF		v_disbursement_amt >= 0 THEN
			v_disbursement_amt_goals := replace(replace(to_char(v_disbursement_amt,'000000000000.00'),'.',''), ' ', '');
	ELSE
			v_disbursement_amt_goals := replace(replace(to_char(v_disbursement_amt,'00000000000.00'),'.',''), ' ', '');
	END IF;

	v_record_type	:= '02';
	v_entry_number 	:= '01';

	v_transaction_date := '    ';

	BEGIN
	SELECT	distinct '02'
	INTO		v_entry_number
	FROM		fv_sf224_temp fst
	WHERE		rpad(substr(replace(treasury_symbol,'-',''),1,20),20,' ') IN
                  (SELECT substr(goals_224_record, 12,20)
                   FROM fv_goals_224_temp where alc_code = v_alc_code)
	AND		rpad(substr(replace(treasury_symbol,'-',''),1,20),20,' ') = v_treasury_symbol
	and		alc_code IN
                  (SELECT substr(goals_224_record, 4,8)
                   FROM fv_goals_224_temp where alc_code = v_alc_code)
	AND		alc_code = v_alc_code
        AND fst.sf224_processed_flag = 'Y'
        AND fst.end_period_date < v_end_date
        AND fst.record_category = 'GLRECORD';
	EXCEPTION	WHEN NO_DATA_FOUND THEN
			null;
			WHEN OTHERS THEN
			errbuf := SQLERRM;
			retcode := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.message1',errbuf);
			return;
	END;

	v_record_02	:= 	v_record_type			||
				v_orig_suppl_ind			||
				v_alc_code 				||
				v_treasury_symbol			||
				v_entry_number			||
				v_disbursement_amt_goals	||
				v_transaction_date		||
				v_reporting_date;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V RECORD TYPE IS ' || V_RECORD_TYPE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V ORIG_SUPPL_IND IS ' || V_ORIG_SUPPL_IND);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE TREASURY SYMBOL IS ' ||V_TREASURY_SYMBOL);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE DISBURSEMENT AMOUNT IS ' || V_DISBURSEMENT_AMT_GOALS);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE ENTRY NUMBER FOR DISBURSEMENT 02 IS '|| V_ENTRY_NUMBER);
	END IF;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECORD 02 IS '|| V_RECORD_02);
	END IF;

	IF v_alc_code IS NOT NULL THEN
	  insert into fv_goals_224_temp(goals_224_temp_id, goals_224_record_type, alc_code, goals_224_record, supplemental_flag)
	  values(fv_goals_224_temp_id_s.nextval, v_record_type, v_alc_code, v_record_02, v_orig_suppl_ind);
	END IF;

	END LOOP;
	close cur_disbursements;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := -1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RAISE;
END process_record_type_02;
------------------------------------------------------------------------------------------------
PROCEDURE process_record_type_03 IS
  l_module_name VARCHAR2(200) ;
BEGIN
 l_module_name := g_module_name || 'process_record_type_03';
--- Getting amount for record type = 03, payment transaction current

		BEGIN
      		SELECT 	nvl(sum(amount * decode(column_group, 21,-1,1)),0),
			nvl(supplemental_flag,0)
		INTO    v_pmt_tran_current_amt,v_orig_suppl_ind
		FROM    fv_sf224_temp fst
		WHERE   column_group in (30,21)
		AND     reported_month = 'CURRENT'
	        AND	alc_code = v_alc_code
                AND fst.sf224_processed_flag = 'Y'
                AND fst.end_period_date < v_end_date
                AND fst.record_category = 'GLRECORD'
		GROUP BY supplemental_flag
    HAVING nvl(sum(amount * decode(column_group, 21,-1,1)),0) <> 0;
		EXCEPTION	WHEN NO_DATA_FOUND THEN
				v_pmt_tran_current_amt	:= '00000000000000';
				v_orig_suppl_ind := 0;
				WHEN OTHERS THEN
				errbuf := SQLERRM;
				retcode := -1;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.message1',errbuf);
				return;
		END;

		IF 	v_pmt_tran_current_amt >= 0 THEN
			v_pmt_tran_current_amt_goals := replace(replace(to_char(v_pmt_tran_current_amt,'000000000000.00'),'.',''), ' ', '');
		ELSE
			v_pmt_tran_current_amt_goals := replace(replace(to_char(v_pmt_tran_current_amt,'00000000000.00'),'.',''), ' ', '');
		END IF;

	v_record_type	:= '03';

	v_treasury_symbol 	:= '                    ';
	v_entry_number 		:= '  ';
	v_transaction_date	:= '    ';

	v_record_03	:= 	v_record_type			||
				v_orig_suppl_ind			||
				v_alc_code 				||
				v_treasury_symbol			||
				v_entry_number			||
				v_pmt_tran_current_amt_goals	||
				v_transaction_date		||
				v_reporting_date;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V RECORD TYPE IS ' || V_RECORD_TYPE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V ORIG_SUPPL_IND IS ' || V_ORIG_SUPPL_IND);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE PMT TRAN CURRENT AMOUNT IS ' || V_PMT_TRAN_CURRENT_AMT_GOALS);
	END IF;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECORD 03 IS '|| V_RECORD_03);
	END IF;

	IF ((v_alc_code IS NOT NULL) AND (TO_NUMBER(v_pmt_tran_current_amt) <> 0)) THEN
	  insert into fv_goals_224_temp(goals_224_temp_id, goals_224_record_type, alc_code, goals_224_record, supplemental_flag)
	  values(fv_goals_224_temp_id_s.nextval, v_record_type, v_alc_code, v_record_03, v_orig_suppl_ind);
	END IF;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := -1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RAISE;
END process_record_type_03;
-----------------------------------------------------------------------------------------------
PROCEDURE process_record_type_04_13 IS
  l_module_name VARCHAR2(200) ;
BEGIN
 l_module_name := g_module_name || 'process_record_type_04-13';
--- Getting amount for record type = 04 - 13, payment transaction prior

	OPEN		cur_pmt_tran_prior_amt;
	v_record_type := '04';
	LOOP

	FETCH 	cur_pmt_tran_prior_amt into v_transaction_date, v_pmt_tran_prior_amt,
				v_orig_suppl_ind;
			EXIT WHEN cur_pmt_tran_prior_amt%notfound;

	IF 	v_pmt_tran_prior_amt >= 0 THEN
		v_pmt_tran_prior_amt_goals := replace(replace(to_char(v_pmt_tran_prior_amt,'000000000000.00'),'.',''), ' ', '');
	ELSE
		v_pmt_tran_prior_amt_goals := replace(replace(to_char(v_pmt_tran_prior_amt,'00000000000.00'),'.',''), ' ', '');
	END IF;

	v_treasury_symbol 	:= '                    ';
	v_entry_number 		:= '  ';

	v_record	:= 	v_record_type			||
				v_orig_suppl_ind			||
				v_alc_code 				||
				v_treasury_symbol			||
				v_entry_number			||
				v_pmt_tran_prior_amt_goals	||
				v_transaction_date		||
				v_reporting_date;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V RECORD TYPE IS ' || V_RECORD_TYPE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V ORIG_SUPPL_IND IS ' || V_ORIG_SUPPL_IND);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE TRANSACTION DATE IS ' || V_TRANSACTION_DATE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE PAYMENT TRANSACTION PRIOR AMOUNT IS ' || V_PMT_TRAN_PRIOR_AMT_GOALS);
	END IF;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECORD XX IS '|| V_RECORD);
	END IF;

	IF (v_alc_code IS NOT NULL) AND (v_pmt_tran_prior_amt <> 0)THEN
	  insert into fv_goals_224_temp(goals_224_temp_id, goals_224_record_type, alc_code, goals_224_record, supplemental_flag)
	  values(fv_goals_224_temp_id_s.nextval, v_record_type, v_alc_code, v_record, v_orig_suppl_ind);
	END IF;

	v_record_type := to_number(v_record_type);
	v_record_type := v_record_type + 1;

-- Fix for bug 1483366
	-- v_record_type := '0'||v_record_type;

	IF length(v_record_type) <= 1 THEN
	  v_record_type := '0' || v_record_type;
	END IF;

	-- End fix for bug 1483366


	END LOOP;
      CLOSE cur_pmt_tran_prior_amt;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := -1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RAISE;
END process_record_type_04_13;
------------------------------------------------------------------------------------------------
PROCEDURE process_record_type_14 IS
  l_module_name VARCHAR2(200) ;
BEGIN
 l_module_name :=  g_module_name || 'process_record_type_14';
--- Getting amount for record type = 14, collections received

		BEGIN
		SELECT	nvl(sum(amount*decode(column_group, 31,-1,1)),0),
			nvl(supplemental_flag,0)
		INTO        v_collection_rcvd_amt,v_orig_suppl_ind
		FROM        fv_sf224_temp fst
		WHERE     	column_group in (20,31)
		AND         reported_month in ('CURRENT','CURRENT/PRIOR')
	        AND	alc_code = v_alc_code
                AND fst.sf224_processed_flag = 'Y'
                AND fst.end_period_date < v_end_date
                AND fst.record_category = 'GLRECORD'
		GROUP BY supplemental_flag
    HAVING nvl(sum(amount*decode(column_group, 31,-1,1)),0) <> 0;
		EXCEPTION	WHEN NO_DATA_FOUND THEN
				v_collection_rcvd_amt	:= '00000000000000';
				WHEN OTHERS THEN
				errbuf := SQLERRM;
				retcode := -1;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.message1',errbuf);
				return;
		END;

	IF 	v_collection_rcvd_amt >= 0 THEN
		v_collection_rcvd_amt_goals := replace(replace(to_char(v_collection_rcvd_amt,'000000000000.00'),'.',''), ' ', '');
	ELSE
		v_collection_rcvd_amt_goals := replace(replace(to_char(v_collection_rcvd_amt,'00000000000.00'),'.',''), ' ', '');
	END IF;

	v_record_type	:= '14';
	v_treasury_symbol 	:= '                    ';
	v_entry_number 		:= '  ';
	v_transaction_date	:= '    ';

	v_record_14	:= 	v_record_type			||
				v_orig_suppl_ind			||
				v_alc_code 				||
				v_treasury_symbol			||
				v_entry_number			||
				v_collection_rcvd_amt_goals	||
				v_transaction_date		||
				v_reporting_date;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V RECORD TYPE IS ' || V_RECORD_TYPE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V ORIG_SUPPL_IND IS ' || V_ORIG_SUPPL_IND);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE COLLECTIONS RECEIVED AMOUNT IS ' || V_COLLECTION_RCVD_AMT_GOALS);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECORD 14 IS '|| V_RECORD_14);
	END IF;

        IF v_alc_code IS NOT NULL AND v_collection_rcvd_amt_goals <> 0 THEN
	  insert into fv_goals_224_temp(goals_224_temp_id, goals_224_record_type, alc_code, goals_224_record, supplemental_flag)
	  values(fv_goals_224_temp_id_s.nextval, v_record_type, v_alc_code, v_record_14, v_orig_suppl_ind);
	END IF;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := -1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RAISE;
END process_record_type_14;
------------------------------------------------------------------------------------------------
PROCEDURE process_record_type_15 IS
  l_module_name VARCHAR2(200) ;
BEGIN
 l_module_name := g_module_name || 'process_record_type_15';
--- Getting amount for record type = 15, deposit current amount

	BEGIN
	SELECT	nvl(sum(amount*decode(column_group, 31,-1,1)),0),
		nvl(supplemental_flag,0)
	INTO        v_deposit_current_amt,v_orig_suppl_ind
	FROM        fv_sf224_temp fst
	WHERE      	column_group in (20,31)
	AND         reported_month = ('CURRENT')
	AND	alc_code = v_alc_code
        AND fst.sf224_processed_flag = 'Y'
        AND fst.end_period_date < v_end_date
        AND fst.record_category = 'GLRECORD'
	GROUP BY 	to_char(accomplish_date,'MM-YYYY'),supplemental_flag
  HAVING nvl(sum(amount*decode(column_group, 31,-1,1)),0) <> 0;
	EXCEPTION	WHEN NO_DATA_FOUND THEN
			v_deposit_current_amt	:= '00000000000000';
	END;

	IF 	v_deposit_current_amt >= 0 THEN
		v_deposit_current_amt_goals := replace(replace(to_char(v_deposit_current_amt,'000000000000.00'),'.',''), ' ', '');
	ELSE
		v_deposit_current_amt_goals := replace(replace(to_char(v_deposit_current_amt,'00000000000.00'),'.',''), ' ', '');
	END IF;


	v_record_type		:= '15';
	v_treasury_symbol 	:= '                    ';
	v_entry_number 		:= '  ';
	v_transaction_date	:= '    ';

	v_record_15	:= 	v_record_type			||
				v_orig_suppl_ind			||
				v_alc_code 				||
				v_treasury_symbol			||
				v_entry_number			||
				v_deposit_current_amt_goals	||
				v_transaction_date		||
				v_reporting_date;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V RECORD TYPE IS ' || V_RECORD_TYPE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V ORIG_SUPPL_IND IS ' || V_ORIG_SUPPL_IND);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE DEPOSIT CURRENT AMOUNT IS ' || V_DEPOSIT_CURRENT_AMT_GOALS);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECORD 15 IS '|| V_RECORD_15);
	END IF;

	IF v_alc_code IS NOT NULL AND v_deposit_current_amt <> 0 THEN
	  insert into fv_goals_224_temp(goals_224_temp_id, goals_224_record_type, alc_code, goals_224_record, supplemental_flag)
	  values(fv_goals_224_temp_id_s.nextval, v_record_type, v_alc_code, v_record_15, v_orig_suppl_ind);
	END IF;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := -1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RAISE;
END process_record_type_15;
------------------------------------------------------------------------------------------------
PROCEDURE process_record_type_16_25 IS
  l_module_name VARCHAR2(200) ;
BEGIN
 l_module_name := g_module_name || 'process_record_type_16-25';
--- Getting amount for record type = 16 - 25, deposits presented or mailed to bank

	v_deposit_prior_amt_record_26 := 0;

	OPEN		cur_deposit_prior_amt;
	v_record_type := '16';
	LOOP
	FETCH 	cur_deposit_prior_amt into v_transaction_date,
		v_deposit_prior_amt,v_orig_suppl_ind;
   	  EXIT WHEN cur_deposit_prior_amt%notfound;

	  --  Keep a running total of the deposit prior amount to be used in
	  --  record 26
	   v_deposit_prior_amt_record_26 :=
			v_deposit_prior_amt_record_26 + v_deposit_prior_amt;
	IF  v_deposit_prior_amt >= 0 THEN

	  --  Keep a running total of the deposit prior amount to be used in
	  --  record 26
	  --   v_deposit_prior_amt_record_26 :=
          --		v_deposit_prior_amt_record_26 + v_deposit_prior_amt;

	   v_deposit_prior_amt_goals := replace(replace(to_char(v_deposit_prior_amt,'000000000000.00'),'.',''), ' ', '');
	ELSE
	   v_deposit_prior_amt_goals := replace(replace(to_char(v_deposit_prior_amt,'00000000000.00'),'.',''), ' ', '');
	END IF;


	v_treasury_symbol 	:= '                    ';
	v_entry_number 		:= '  ';

	v_record	:= 	v_record_type			||
				v_orig_suppl_ind			||
				v_alc_code 				||
				v_treasury_symbol			||
				v_entry_number			||
				v_deposit_prior_amt_goals	||
				v_transaction_date		||
				v_reporting_date;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V RECORD TYPE IS ' || V_RECORD_TYPE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V ORIG_SUPPL_IND IS ' || V_ORIG_SUPPL_IND);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE TRANSACTION DATE IS ' || V_TRANSACTION_DATE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE DEPOSIT PRIOR AMOUNT IS ' || V_DEPOSIT_PRIOR_AMT_GOALS);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECORD XX IS '|| V_RECORD);
	END IF;

	IF v_alc_code IS NOT NULL AND v_deposit_prior_amt <> 0 THEN
	  insert into fv_goals_224_temp(goals_224_temp_id, goals_224_record_type, alc_code, goals_224_record, supplemental_flag)
	  values(fv_goals_224_temp_id_s.nextval, v_record_type, v_alc_code, v_record, v_orig_suppl_ind);
	END IF;

	v_record_type := to_number(v_record_type);
	v_record_type := v_record_type + 1;

	END LOOP;
      CLOSE cur_deposit_prior_amt;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := -1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RAISE;
END process_record_type_16_25;
------------------------------------------------------------------------------------------------
PROCEDURE process_record_type_26 IS
  l_module_name VARCHAR2(200) ;
  l_count_non_reclass NUMBER;
BEGIN
 l_module_name := g_module_name || 'process_record_type_26';
--- Getting amount for record type = 26, net total

  l_count_non_reclass := 0;
  SELECT COUNT(*)
    INTO l_count_non_reclass
    FROM fv_sf224_temp fst
   WHERE column_group in (20,21, 30, 31)
     AND reported_month in ('CURRENT', 'CURRENT/PRIOR')
	   AND alc_code = v_alc_code
     AND fst.sf224_processed_flag = 'Y'
     AND fst.end_period_date < v_end_date
     AND fst.record_category = 'GLRECORD'
     AND NVL(reclass, 'N') = 'N';

	v_net_total_amt := (NVL(v_deposit_prior_amt_record_26,0) +
				NVL(v_deposit_current_amt,0)) -
				NVL(v_collection_rcvd_amt,0);

	IF 	v_net_total_amt >= 0 THEN
		v_net_total_amt_goals := replace(replace(to_char(v_net_total_amt,'000000000000.00'),'.',''), ' ', '');
	ELSE
		v_net_total_amt_goals := replace(replace(to_char(v_net_total_amt,'00000000000.00'),'.',''), ' ', '');
	END IF;

	v_record_type	:= '26';
	v_treasury_symbol 	:= '                    ';
	v_entry_number 		:= '  ';
	v_transaction_date	:= '    ';

	v_record_26	:= 	v_record_type		||
				v_orig_suppl_ind		||
				v_alc_code 			||
				v_treasury_symbol		||
				v_entry_number		||
				v_net_total_amt_goals		||
				v_transaction_date	||
				v_reporting_date;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECORD 26 ************ ');
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_DEPOSIT_PRIOR_AMT IS ' || V_DEPOSIT_PRIOR_AMT);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_DEPOSIT_CURRENT_AMT IS ' || V_DEPOSIT_CURRENT_AMT);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_COLLECTION_RCVD_AMT IS ' || V_COLLECTION_RCVD_AMT);
        END IF;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V RECORD TYPE IS ' || V_RECORD_TYPE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V ORIG_SUPPL_IND IS ' || V_ORIG_SUPPL_IND);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NET TOTAL IS ' || V_NET_TOTAL_AMT);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECORD 26 IS '|| V_RECORD_26);
	END IF;

	IF ((v_alc_code IS NOT NULL) AND ((v_net_total_amt <> 0) OR ((v_net_total_amt = 0) AND (l_count_non_reclass > 0)))) THEN
	  insert into fv_goals_224_temp(goals_224_temp_id, goals_224_record_type, alc_code, goals_224_record, supplemental_flag)
	  values(fv_goals_224_temp_id_s.nextval, v_record_type, v_alc_code, v_record_26, v_orig_suppl_ind);
	END IF;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := -1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RAISE;

END process_record_type_26;
------------------------------------------------------------------------------------------------
PROCEDURE process_record_type_98 IS
  l_module_name VARCHAR2(200) ;
BEGIN
 l_module_name  := g_module_name || 'process_record_type_98';
--- Getting amount for record type = 98, subtotal for the number of records for each alc of the bulk file

	SELECT	lpad(count(*), 14, '0'), max(supplemental_flag)
	INTO		v_count_per_alc, v_orig_suppl_ind
	FROM		fv_goals_224_temp
	WHERE alc_code = v_alc_code;

	v_record_type	:= '98';

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V RECORD TYPE IS ' || V_RECORD_TYPE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V COUNT PER ALC IS ' || V_COUNT_PER_ALC);
	END IF;

	v_treasury_symbol 	:= '                    ';
	v_entry_number 		:= '  ';
	v_transaction_date	:= '    ';

	v_record_98	:= 	v_record_type		||
				v_orig_suppl_ind		||
				v_alc_code 			||
				v_treasury_symbol		||
				v_entry_number		||
				v_count_per_alc		||
				v_transaction_date	||
				v_reporting_date;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECORD 98 IS '|| V_RECORD_98);
	END IF;

	IF ((v_alc_code IS NOT NULL) AND (v_count_per_alc <> 0)) THEN
	  insert into fv_goals_224_temp(goals_224_temp_id, goals_224_record_type, alc_code, goals_224_record, supplemental_flag)
	  values(fv_goals_224_temp_id_s.nextval, v_record_type, v_alc_code, v_record_98, v_orig_suppl_ind);
	END IF;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V ORIG_SUPPL_IND IS ' || V_ORIG_SUPPL_IND);
	END IF;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := -1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RAISE;

END process_record_type_98;
------------------------------------------------------------------------------------------------
PROCEDURE process_record_type_99 IS
  l_module_name VARCHAR2(200) ;
BEGIN
  l_module_name := g_module_name || 'process_record_type_99';
--- Getting count for all records, record type = 99, last record

	SELECT	lpad(count(*), 14, '0')
	INTO		v_count
	FROM		fv_goals_224_temp
	WHERE 	goals_224_record_type not in ('98','99');

	v_record_type	:= '99';
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V RECORD TYPE IS ' || V_RECORD_TYPE);
	END IF;
	v_orig_suppl_ind 		:= ' ';
	v_alc_code			:= '        ';
	v_treasury_symbol 	:= '                    ';
	v_entry_number 		:= '  ';
	v_transaction_date	:= '    ';

	v_record_99	:= 	v_record_type  		||
				v_orig_suppl_ind		||
				v_alc_code 			||
				v_treasury_symbol		||
				v_entry_number		||
				v_count			||
				v_transaction_date	||
				v_reporting_date;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECORD 99 IS '|| V_RECORD_99);
	END IF;

--if the only value that gets inserted into the temp table with amount of 0, it is a
-- zero activity 224
  if (v_count <> 0) THEN
  	insert into fv_goals_224_temp(goals_224_temp_id, goals_224_record_type, goals_224_record, supplemental_flag)
  	values(fv_goals_224_temp_id_s.nextval, v_record_type, v_record_99, v_orig_suppl_ind);
  end if;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := -1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RAISE;

END process_record_type_99;
------------------------------------------------------------------------------------------------
BEGIN
 g_module_name := 'fv.plsql.FV_GOALS_224.';

END FV_GOALS_224;

/
