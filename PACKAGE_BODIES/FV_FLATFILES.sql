--------------------------------------------------------
--  DDL for Package Body FV_FLATFILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FLATFILES" AS
/* $Header: FVFILCRB.pls 120.12.12010000.1 2008/07/28 06:31:04 appldev ship $*/
  g_module_name VARCHAR2(100) ;

vp_errbuf 	VARCHAR2(1000);
vp_retcode	NUMBER;
gbl_count       number(15);

PROCEDURE main (errbuf  OUT NOCOPY VARCHAR2,
	        retcode OUT NOCOPY VARCHAR2,
                conc_prog IN VARCHAR2,
	        parameter1 IN NUMBER,
		parameter2 IN NUMBER,
	        parameter3 IN VARCHAR2,
		parameter4 IN VARCHAR2,
		parameter5 IN VARCHAR2,
		parameter6 IN VARCHAR2,
		parameter7 IN VARCHAR2) IS

l_module_name   VARCHAR2(200);
statement	VARCHAR2(2000);
col1		VARCHAR2(500);
request_id      NUMBER;
sob_id		NUMBER;
entity_code	VARCHAR2(50);
period_year	NUMBER;
v_creditors_tin VARCHAR2(10);
payment_year	NUMBER;
invoice_minimum NUMBER;
tape_indicator  VARCHAR2(2);
transmitter_code VARCHAR2(5);

v_footnote_count VARCHAR2(10);
v_trailer_count  VARCHAR2(10);
v_total_count    VARCHAR2(10);
v_str            varchar2(200);

BEGIN

request_id := parameter1;
sob_id     := parameter2;

g_module_name := 'fv.plsql.FV_FLATFILES.';
l_module_name := g_module_name || 'main';
-- -----------------------------------------------------------------------------------
-- Create Flat File for FV1219BF
-- -----------------------------------------------------------------------------------
	IF conc_prog = 'FV1219BF' THEN
	    IF (parameter3 = 'F')
	    THEN
               FV_1219_TRANSACTIONS.gen_flat_file(parameter4, parameter5, parameter6, parameter7);
	    ELSE
	       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'The GOALS FMS 1219/1220 Program is not created when the FMS Form 1219/1220 Reports ');
	       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'request set is submitted in Preliminary mode.');
	    END IF;

-- -----------------------------------------------------------------------------------
-- Create Flat File for FVFCTHRC
-- -----------------------------------------------------------------------------------
	ELSIF conc_prog = 'FVFCTHRC' THEN
	statement :=
		'SELECT facts_report_info
		FROM fv_facts_temp fft,
     	             fv_facts_submission ffs,
     		     fv_treasury_symbols fts
		WHERE fft.treasury_symbol_id = ffs.treasury_symbol_id
		AND   fts.treasury_symbol_id = fft.treasury_symbol_id
		AND   ffs.bulk_flag = ''Y''
		AND   fct_int_record_category = ''REPORTED_NEW''
		AND   fct_int_record_type = ''CNT_HDR''
		AND   ffs.Bulk_File_Sub_Id = '||request_id||
		' AND   ffs.set_of_books_id = '||sob_id||
		' ORDER BY fts.treasury_symbol';

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Creating Flat File for FVFCTHRC');
    END IF;


	fv_flatfiles.create_flat_file(statement);

	statement :=
		'SELECT ''TRL'' || LPAD(to_char(count(*)), 10, ''0'') || LPAD('' '', 403)
		FROM  fv_facts_submission ffs
		WHERE ffs.bulk_flag = ''Y''
		AND   ffs.Bulk_File_Sub_Id = '||request_id||
		' AND   ffs.set_of_books_id = '||sob_id ;

	fv_flatfiles.create_flat_file(statement);

-- -----------------------------------------------------------------------------------
-- Create Flat File for FVXTIVC1
-- -----------------------------------------------------------------------------------
	ELSIF conc_prog = 'FVXTIVC1' THEN
	statement :=
		'SELECT record
		FROM   fv_ecs_ncrpay_temp
		ORDER  by line_no';

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Creating Flat File for FVXTIVC1');
    END IF;


	fv_flatfiles.create_flat_file(statement);

-- -----------------------------------------------------------------------------------
-- Create Flat File for FVTICTXR
-- -----------------------------------------------------------------------------------
/*Enhancement PMC-17 CTX Payment Format.
  The Following Select Statement for FVTICTXR is changed.
  After generating the Output the Temporary table is Purged*/

	ELSIF conc_prog = 'FVTICTXR' THEN
	statement :=
		'SELECT record
		FROM   fv_payment_format_temp
		WHERE  set_of_books_id = '||parameter1||
		' AND    org_id = '||parameter2||
		' AND    checkrun_name = '||''''||parameter3||''''||
		' ORDER  by line_no';

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Creating Flat File for FVTICTXR');
    END IF;

	fv_flatfiles.create_flat_file(statement);
	DELETE FROM fv_payment_format_temp
	WHERE set_of_books_id = parameter1
	AND    org_id = parameter2
	AND    checkrun_name = parameter3 ;
	COMMIT ;

-- -----------------------------------------------------------------------------------
-- Create Flat File for FVTIACHR
-- -----------------------------------------------------------------------------------
	ELSIF conc_prog = 'FVTIACHR' THEN
	statement :=
		'SELECT record
		FROM   fv_ecs_ach_vendor_temp
		ORDER  by line_no';

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Creating Flat File for FVTIACHR');
    END IF;

	fv_flatfiles.create_flat_file(statement);

-- -----------------------------------------------------------------------------------
-- Create Flat File for FVFCTDRC
-- -----------------------------------------------------------------------------------
	ELSIF conc_prog = 'FVFCTDRC' THEN
	statement :=
		'SELECT facts_report_info
		FROM fv_facts_temp  fft,
     		fv_facts_submission ffs,
     		fv_treasury_symbols fts
		WHERE fft.treasury_symbol_id = ffs.treasury_symbol_id
		AND   fts.treasury_symbol_id = fft.treasury_symbol_id
		AND   ffs.bulk_flag = ''Y''
		AND   fct_int_record_category = ''REPORTED_NEW''
		AND   fct_int_record_type = ''BLK_DTL''
		AND   ffs.Bulk_File_Sub_id = '||request_id||
		' AND   ffs.set_of_books_id = '||sob_id||
		' AND   fts.set_of_books_id = '||sob_id||
		' ORDER BY fts.treasury_symbol, fft.sgl_acct_number' ;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Creating Flat File for FVFCTDRC');
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Detail Records...');
    END IF;

	fv_flatfiles.create_flat_file(statement);

-- Modified the foll for Facts II 2002 enhancements
	statement :=
		'SELECT    SUBSTR(fft.facts_report_info,1,50)
       			||''F''||SUBSTR(fft.facts_report_info,52,74)
			||RPAD('' '', 17)||SUBSTR(fft.facts_report_info,143,1)
        		||LPAD(TO_CHAR(ffl.footnote_seq_number),3,''0'')
			||RPAD(ffl.footnote_text,255)
		FROM   	fv_facts_submission ffs,
			fv_facts_temp fft,
       			fv_facts_footnote_hdr ffh,
       			fv_facts_footnote_lines ffl,
			fv_treasury_symbols fts
		WHERE   ffs.set_of_books_id = '||sob_id||
		' AND   ffs.bulk_file_sub_id = '||request_id||
		' AND   ffs.bulk_flag = ''Y''
		AND     ffs.foot_note_flag = ''Y''
		AND	fft.fct_int_record_category = ''REPORTED_NEW''
		AND	fft.document_number = ''Y''
		AND     ffs.treasury_symbol_id = fft.treasury_symbol_id
		AND     ffh.treasury_symbol_id = fft.treasury_symbol_id
		AND     ffh.footnote_header_id = ffl.footnote_header_id
		AND     fft.sgl_acct_number = ffh.sgl_acct_number
		AND     fts.treasury_symbol_id = fft.treasury_symbol_id
		ORDER BY fts.treasury_symbol, ffh.sgl_acct_number,
			 ffl.footnote_seq_number' ;

	fv_flatfiles.create_flat_file(statement);

	-- count the footnotes to print in the trailer record
	SELECT 	LPAD(to_char(count(*)), 10, '0')
	INTO   	v_footnote_count
        FROM   	fv_facts_footnote_hdr ffh,
		fv_facts_footnote_lines ffl,
		fv_facts_submission ffs
	WHERE ffh.footnote_header_id = ffl.footnote_header_id
	AND   ffh.treasury_symbol_id = ffs.treasury_symbol_id
	AND   ffs.Bulk_File_Sub_id = request_id
	AND   ffs.set_of_books_id = sob_id
	AND   ffs.foot_note_flag = 'Y'
	AND   ffs.bulk_flag = 'Y';

	SELECT  LPAD(to_char(count(*)), 10, '0')
	INTO    v_trailer_count
        FROM    fv_facts_submission ffs ,
                fv_facts_temp       fft
        WHERE fft.treasury_symbol_id = ffs.treasury_symbol_id
        AND   ffs.bulk_flag = 'Y'
        AND   fct_int_record_category = 'REPORTED_NEW'
        AND   ffs.Bulk_File_Sub_id = request_id
        AND   ffs.set_of_books_id = sob_id
        AND   fct_int_record_type = 'BLK_DTL';

	v_total_count := v_trailer_count + v_footnote_count;

        statement :=
               'SELECT ''TRL''||LPAD('||v_total_count||',10,''0'')
                        ||'||''''||v_footnote_count||''''||'
                        ||LPAD('' '', 378)
                 FROM   DUAL' ;

	fv_flatfiles.create_flat_file(statement);
-- -----------------------------------------------------------------------------------
-- Create Flat File for FVTI224R
-- -----------------------------------------------------------------------------------
	ELSIF conc_prog = 'FVTI224R' THEN
	statement :=
		'SELECT goals_224_record
		FROM   fv_goals_224_temp
		ORDER BY goals_224_temp_id';

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Creating Flat File for FVTI224R');
    END IF;

	fv_flatfiles.create_flat_file(statement);
-- -----------------------------------------------------------------------------------
-- Create Flat File for FVTIOBUR
-- -----------------------------------------------------------------------------------
	ELSIF conc_prog = 'FVTIOBUR' THEN
	statement :=
	       'SELECT record
		FROM    fv_opac_upload_temp
		ORDER BY line_no';

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Creating Flat File for FVTIOBUR');
    END IF;

	fv_flatfiles.create_flat_file(statement);
-- -----------------------------------------------------------------------------------
-- Create Flat File for FVFACTSR
-- -----------------------------------------------------------------------------------
	ELSIF conc_prog = 'FVFACTSR' THEN

        period_year := parameter1;


	-- statement :=
	--	'SELECT ''ENTITY IS ''' || entity_code ||' From Dual' ;

-- Enh No:1541559
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Creating Flat File for FVFACTSR');
    END IF;
	--fnd_file.put_line(fnd_file.output, 'ENTITY IS '||entity_code);

	-- fv_flatfiles.create_flat_file(statement);

	statement :=
		'SELECT '||parameter1||'||
			RPAD(dept_id, 2,'' '') ||
        		RPAD(bureau_id, 2, '' '') ||
        		LPAD(fund_group, 4, ''0'') ||
        		RPAD(NVL(USSGL_ACCOUNT,'' ''),4,'' '') ||
        		NVL(g_ng_indicator,'' '')||
        		NVL(RPAD(eliminations_dept,2,'' ''),''  '')||
        		d_c_indicator ||
        		LPAD(TO_CHAR(SUBSTR(amount,1,DECODE(INSTR(amount,''.''),0,LENGTH(amount),INSTR(amount,''.'')-1))) ||
    			RPAD(NVL(TO_CHAR(SUBSTR(amount,DECODE(INSTR(amount,''.''),0,LENGTH(amount)+1,INSTR(amount,''.'')+1))),''0''),2,''0''),17,''0'')||
    			''1''||
    			NVL(exch_non_exch,'' '') ||
    			''2''||
    			NVL(RPAD(budget_subfunction,3,'' ''),''   '')||
    			''3''||
    			NVL(cust_non_cust,'' '')
        	 FROM fv_facts_report_t2
		 WHERE set_of_books_id = '||sob_id||
  		 ' AND reported_status in (''F'')
  		 AND amount <> 0
		 ORDER BY
        		DEPT_ID,
        		BUREAU_ID,
        		FUND_GROUP,
        		USSGL_ACCOUNT,
        		ELIMINATIONS_DEPT,
        		g_ng_indicator' ;

--fnd_file.put_line(fnd_file.log,statement );

fv_flatfiles.create_flat_file(statement);

	statement :=
		'SELECT ''TRL'' ||
		        LPAD(TO_CHAR(COUNT(*)),10,''0'')||
		        RPAD('' '',32,'' '')
		 FROM fv_facts_report_t2
		 WHERE set_of_books_id = '||sob_id||
  		 'AND reported_status in (''F'')
  		 AND amount <> 0
  		 ORDER BY
  		   DEPT_ID,
  		   BUREAU_ID,
  		   FUND_GROUP,
  		   USSGL_ACCOUNT,
  		   ELIMINATIONS_DEPT,
  		   g_ng_indicator';
	fv_flatfiles.create_flat_file(statement);

-- -----------------------------------------------------------------------------------
-- Create Flat File for FVFC1ATB
-- -----------------------------------------------------------------------------------
	ELSIF conc_prog = 'FVFC1ATB' THEN

        period_year := parameter1;

        FV_UTILITY.LOG_MESG('Creating Flat File for FVFC1ATB');

        gbl_count := 0;
	statement :=
          'SELECT '||parameter1||'||
                 RPAD(dept_id, 2,'' '') ||
                 RPAD(bureau_id, 2, '' '')||
                 LPAD(fund_group, 4, ''0'')||
                 RPAD(NVL(ussgl_account,'' ''),4,'' '')||
                 NVL(g_ng_indicator,'' '')||
                 NVL(RPAD(eliminations_dept,2,'' ''),''  '')||
                 DECODE(SIGN(SUM(NVL(amount, 0))), 0, ''D'', 1, ''D'', -1, ''C'')||
                 TO_CHAR(ABS(SUM(NVL(amount,0))), ''FM00000000000000V00'')||
                 ''1''||
                 NVL(exch_non_exch,'' '')||
                 ''2''||
                 NVL(RPAD(budget_subfunction,3,'' ''),''   '')||
                 ''3''||
                 NVL(cust_non_cust,'' '')
            FROM fv_facts1_period_balances_v
           WHERE set_of_books_id = '||sob_id||
            ' AND period_year = '||parameter1||
            ' AND period_num <= '||parameter3||
            ' AND amount <> 0
           HAVING SUM(NVL(amount, 0)) <> 0
           GROUP BY LPAD(fund_group, 4, ''0''),
                    RPAD(dept_id, 2,'' ''),
                    RPAD(bureau_id, 2, '' ''),
                    RPAD(NVL(ussgl_account,'' ''),4,'' ''),
                    NVL(g_ng_indicator,'' ''),
                    NVL(RPAD(eliminations_dept,2,'' ''),''  ''),
                    NVL(exch_non_exch,'' ''),
                    NVL(RPAD(budget_subfunction,3,'' ''),''   ''),
                    NVL(cust_non_cust,'' '')
           ORDER BY RPAD(dept_id, 2,'' ''),
                    RPAD(bureau_id, 2, '' ''),
                    LPAD(fund_group, 4, ''0''),
                    RPAD(NVL(ussgl_account,'' ''),4,'' ''),
                    NVL(RPAD(eliminations_dept,2,'' ''),''  ''),
                    NVL(g_ng_indicator,'' '')';

           fv_flatfiles.create_flat_file(statement);


/*
           statement :=
                'SELECT ''TRL'' ||
                        LPAD(TO_CHAR(COUNT(*)),10,''0'')||
                        RPAD('' '',32,'' '')
                  FROM (
          	  SELECT COUNT(*)
            	  FROM fv_facts1_period_balances_v
           	  WHERE set_of_books_id = '||sob_id||
            	  ' AND period_year = '||parameter1||
            	  ' AND period_num <= '||parameter3||
            	  ' AND amount <> 0
                  HAVING SUM(NVL(amount,0)) <> 0
           	  GROUP BY fund_group,
                    	  dept_id,
                    	  bureau_id,
                    	  ussgl_account,
                    	  g_ng_indicator,
                    	  eliminations_dept,
                    	  exch_non_exch,
                    	  budget_subfunction,
                    	  cust_non_cust)';

*/
	 /* ------  Trail records printing ---------------- */

	  v_str := 'TRL' || LPAD(TO_CHAR(gbl_count),10,'0')|| RPAD(' ',32,' ');
           statement := 'SELECT ''' || v_str  || ''' FROM  dual ';

fnd_file.put_line (fnd_file.log, statement);
	   fv_flatfiles.create_flat_file(statement);

-- -----------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------
-- Create Flat File for FVTI133R
-- -----------------------------------------------------------------------------------
	ELSIF conc_prog = 'FVTI133R' THEN
	statement :=
		'SELECT substr(goals_133_record,1,75)
		FROM   fv_goals_133_temp
		ORDER BY goals_133_record_type, goals_133_temp_id';

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Creating Flat File for FVTI133R');
    END IF;

	fv_flatfiles.create_flat_file(statement);
-- -----------------------------------------------------------------------------------
-- Create Flat File for FVTI133R
-- -----------------------------------------------------------------------------------
	ELSIF conc_prog = 'FVTI133R' THEN

	  payment_year := parameter1;
	  invoice_minimum := parameter3;
	  tape_indicator := parameter4;
	  transmitter_code := parameter5;


	 -- ---------------------------------------------------
	 -- Select creditors tin
	 -- ---------------------------------------------------
		SELECT distinct rpad(replace(creditors_tin,'-',''),9) ct
		INTO   v_creditors_tin
  		FROM   fv_1099c;

	 -- ---------------------------------------------------
	 -- Create Creditor/Transmitter 'A' Record
	 -- ---------------------------------------------------
	statement :=
		'SELECT ''A''
       		||payment_year
       		||''   ''
       		||rpad(v_creditors_tin,9)
       		||''    ''
       		||'' ''
       		||'' ''
       		||''5''
       		||''23       ''
       		||'' ''
       		||'' ''
       		||''        ''
       		||rpad(tape_indicator,2)
       		||rpad(transmitter_code,5)
       		||'' ''
       		||rpad(substr(hou.name,1,40),40)
       		||rpad(nvl(substr(hou.name,41,60),'' ''),40)
       		||'' ''
       		||rpad(substr(address_line_1||address_line_2||address_line_3,1,40),40)
       		||rpad(substr(town_or_city||'',''||substr(region_2,1,2)||'' ''||postal_code,1,40),40)
       		||''                                                                                ''
       		||''                                        ''
       		||''                                        ''
       		||''                                                  ''
  		FROM hr_locations hl,
       		hr_organization_units hou,
       		fv_operating_units fou
 		WHERE hou.organization_id = fou.organization_id
   		AND hl.location_id      = hou.location_id
   		AND fou.set_of_books_id = sob_id';

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Creating Flat File for FVTI133R');
    END IF;

	  fv_flatfiles.create_flat_file(statement);
	 -- ---------------------------------------------------
	 -- Create Debtor 'B' Record
	 -- ---------------------------------------------------
	statement :=
		'SELECT ''B''
       		||payment_year
		||fvr_1099t
		FROM fv_1099t_v
		WHERE amount >= invoice_minimum
		AND   reportable_flag = ''Y''
		AND   set_of_books_id = sob_id';

	  fv_flatfiles.create_flat_file(statement);
	 -- ---------------------------------------------------
	 -- Create Debtor 'C' Record
	 -- ---------------------------------------------------
	statement :=
		'SELECT ''C''
       		||lpad(count(*),6,0)
       		||''   ''
       		||''000000000000000''
       		||to_char(sum(amount),''S000000000000V99'')
       		||to_char(sum(finance_charge_amount),''S000000000000V99'')
       		||''000000000000000''
       		||''000000000000000''
       		||''000000000000000''
       		||''000000000000000''
       		||''000000000000000''
       		||''000000000000000''
       		||lpad('' '',275)
  		FROM fv_1099c
 		WHERE amount > invoice_minimum
   		AND reportable_flag = ''Y''
   		AND set_of_books_id = sob_id';

	  fv_flatfiles.create_flat_file(statement);
	 -- ---------------------------------------------------
	 -- Create Debtor 'F' Record
	 -- ---------------------------------------------------
	statement :=
		'SELECT ''F''
       		||''0001''
       		||''0000000000000000000000000''
       		||lpad('' '',390)
  		FROM dual';

	  fv_flatfiles.create_flat_file(statement);
-- -----------------------------------------------------------------------------------
END IF;
  EXCEPTION
    WHEN OTHERS THEN
    vp_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
    RAISE;
end main;
-- ----------------------------------------------------------------------------
PROCEDURE create_flat_file(v_statement VARCHAR2) IS
  l_module_name VARCHAR2(200) ;
v_cursor	integer;
l_fetch_count   integer;
col1		VARCHAR2(2000);

BEGIN
  l_module_name := g_module_name || 'create_flat_file';

    BEGIN
	v_cursor := DBMS_SQL.OPEN_CURSOR;
    EXCEPTION WHEN OTHERS THEN
      vp_errbuf   := sqlerrm;
      vp_retcode  := sqlcode;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.open_v_cursor',vp_errbuf);
	RETURN;
    END;

    BEGIN
        DBMS_SQL.PARSE(v_cursor, v_statement, DBMS_SQL.V7);
    EXCEPTION WHEN OTHERS THEN
        vp_retcode := sqlcode ;
        VP_ERRBUF  := sqlerrm ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.parse_v_cursor',vp_errbuf);
        RETURN ;
    END ;

    DBMS_SQL.DEFINE_COLUMN(v_cursor, 1, col1, 2000);

    BEGIN
        l_fetch_count := DBMS_SQL.EXECUTE(v_cursor);
    EXCEPTION WHEN OTHERS THEN
        vp_retcode := sqlcode ;
        VP_ERRBUF  := sqlerrm ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.execute_v_cursor',vp_errbuf);
        RETURN ;
    END;

   gbl_count := 0;

   LOOP
       l_fetch_count := DBMS_SQL.FETCH_ROWS(v_cursor);
       IF l_fetch_count = 0
	THEN return;
       END IF;
       gbl_count := gbl_count + 1;
       DBMS_SQL.COLUMN_VALUE(v_cursor, 1, col1);
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,col1);
   END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
    vp_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
    RAISE;
end create_flat_file;
-- ----------------------------------------------------------------------------
end fv_flatfiles;

/
