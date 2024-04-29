--------------------------------------------------------
--  DDL for Package Body FUN_GL_BATCH_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_GL_BATCH_TRANSFER" AS
/* $Header: FUNGLTRB.pls 120.32.12010000.10 2009/11/10 05:17:40 makansal ship $ */

FUNCTION has_valid_conversion_rate (
    p_from_currency IN varchar2,
    p_to_currency   IN varchar2,
    p_exchange_type IN varchar2,
    p_exchange_date IN date) RETURN number
IS
    l_has_rate  varchar2(5);
BEGIN
   /* IF (p_from_currency = p_to_currency) THEN
        RETURN 1;
    END IF;

    SELECT COUNT(conversion_rate) INTO l_has_rate
    FROM gl_daily_rates
    WHERE from_currency = p_from_currency AND
          to_currency = p_to_currency AND
          conversion_type = p_exchange_type AND
          conversion_date = p_exchange_date;

    IF (l_has_rate = 0) THEN
        RETURN 0;
    END IF;
    RETURN 1;*/

	l_has_rate := GL_CURRENCY_API.rate_exists(p_from_currency, p_to_currency, p_exchange_date, p_exchange_type);
	IF (l_has_rate = 'Y')
	THEN
		RETURN 1;
	END IF;
	RETURN 0;

END has_valid_conversion_rate;

FUNCTION get_conversion_type (
    p_conversion_type IN VARCHAR2) RETURN VARCHAR2
IS
    l_user_conversion_type GL_DAILY_CONVERSION_TYPES.USER_CONVERSION_TYPE%TYPE;
BEGIN

    SELECT USER_CONVERSION_TYPE
    INTO l_user_conversion_type
    from GL_DAILY_CONVERSION_TYPES
    where conversion_type = p_conversion_type;

    return l_user_conversion_type;
END get_conversion_type;

procedure gl_batch_transfer
(
    errbuf                    OUT NOCOPY VARCHAR2,
    retcode                   OUT NOCOPY NUMBER,
    p_date_low                IN varchar2 DEFAULT NULL,
    p_date_high               IN varchar2 DEFAULT NULL,
    p_ledger_low              IN varchar2 DEFAULT NULL,
    p_ledger_high             IN varchar2 DEFAULT NULL,
    p_le_low                  IN varchar2 DEFAULT NULL,
    p_le_high                 IN varchar2 DEFAULT NULL,
    p_ic_org_low              IN varchar2 DEFAULT NULL,
    p_ic_org_high             IN varchar2 DEFAULT NULL,
    p_run_journal_import      IN varchar2 DEFAULT 'N',
    p_create_summary_journals IN varchar2 DEFAULT 'N'

)
IS
p_request_id number;
l_source gl_je_sources_tl.user_je_source_name%TYPE;
l_category gl_je_categories_tl.user_je_category_name%TYPE;
l_date_low date;
l_date_high date;
l_init_sysdate date;
l_parameter_list WF_PARAMETER_LIST_T :=wf_parameter_list_t();
l_event_key    VARCHAR2(240);
v_interface_run_id number;
import_request_id number;
l_run_journal_import varchar2(3);
l_create_summary_journals varchar2(3);
l_cur_select VARCHAR2(1200);
l_cur_where VARCHAR2(2300);
l_cur_main_query VARCHAR2(3500);
-- Bug No. 6894340
l_ic_org_low VARCHAR2(360);
l_ic_org_high VARCHAR2(360);
--journal import cursor to be modified

cursor c_import(p_concreqid number, p_source VARCHAR2, p_category VARCHAR2) is
select distinct ledger_id
from gl_interface
where user_je_category_name = p_category
and user_je_source_name = p_source
and request_id=p_concreqid;


-- Please dont remove the trunc around GL date as the date
-- currently stores a time component.
-- In this case the TRUNC in the query does not affect the performance
-- as there is currently no index on gl_date
-- Also there are transactions in the system with a time
-- component in the gl date. This has been rectified for
-- bug 5172718
-- But there are still some transactions with GL dates that need
-- to be processed.
-- If an index is later added on gl_date, a script may be required
-- to trunc gl and batch date on all exising records.
TYPE c_transfer IS REF CURSOR;
   c_transfer_obj c_transfer;

TYPE status           IS TABLE OF fun_trx_headers.status%TYPE INDEX BY BINARY_INTEGER;
TYPE party_type_flag  IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE error_mesg       IS TABLE OF fnd_new_messages.message_name%TYPE INDEX BY BINARY_INTEGER;
TYPE trx_id           IS TABLE OF fun_trx_headers.trx_id%TYPE INDEX BY BINARY_INTEGER;
TYPE trx_number       IS TABLE OF fun_trx_headers.trx_number%TYPE INDEX BY BINARY_INTEGER;
TYPE batch_number     IS TABLE OF fun_trx_batches.batch_number%TYPE INDEX BY BINARY_INTEGER;
TYPE batch_id         IS TABLE OF fun_trx_batches.batch_id%TYPE INDEX BY BINARY_INTEGER; -- Bug 6797385.


l_status_tbl           status;
l_party_type_flag_tbl  party_type_flag;
l_error_mesg_tbl       error_mesg;
l_trx_id_tbl           trx_id;
l_trx_num              trx_number;
l_batch_num            batch_number;
l_batch_id_tbl         batch_id; -- Bug 6797385.
where_clause           VARCHAR2(1000) :='';
select_clause          VARCHAR2(2500) :='';
insert_clause          VARCHAR2(800) :='';

gt_insert_clause          VARCHAR2(2500) :='';
gt_where_clause           VARCHAR2(2500) :='';

BEGIN
p_request_id := FND_GLOBAL.CONC_REQUEST_ID;

select user_je_source_name into l_source from gl_je_sources_tl where
je_source_name = 'Global Intercompany' and language = USERENV('LANG');

select user_je_category_name into l_category from gl_je_categories_tl  where
je_category_name = 'Global Intercompany' and language = USERENV('LANG');

l_date_low := TRUNC(fnd_date.canonical_to_date(p_date_low));
l_date_high:= TRUNC(fnd_date.canonical_to_date(p_date_high));
--Bug No. 6894340
l_ic_org_high:=REPLACE(p_ic_org_high, '''', '''''');
l_ic_org_low:=REPLACE(p_ic_org_low, '''', '''''');
IF p_create_summary_journals = 'Y'  THEN
   l_create_summary_journals:='Yes';
ELSE
   l_create_summary_journals:='No';
END IF;

IF p_run_journal_import = 'Y' THEN
  l_run_journal_import:= 'Yes';
ELSE
  l_run_journal_import:= 'No';
END IF;

BEGIN
  -- Build the query for cursor
  l_cur_select := 'SELECT
                    trxH.status status,
                    gt.party_type_flag party_type_flag,
                    Nvl(nvl(decode(glps.closing_status,''O'','''',''F'','''', ''GL_PERIOD_NOT_OPEN''),
                           decode(FUN_GL_BATCH_TRANSFER.has_valid_conversion_rate(trxB.currency_code,ledgers.currency_code,
                              trxB.exchange_rate_type,TRUNC(trxB.GL_DATE)),1,'''',0,''FUN_API_CONV_RATE_NOT_FOUND'')),
                                     ''FUN_API_TRX_TRANSFERRED'') error_mesg,
                    gt.trx_id trx_id,
                    trxH.trx_number trx_number,
                    trxB.batch_number batch_number,
                    trxB.batch_id     batch_id
                    from
                    fun_trx_batches trxB,
		    fun_trx_headers trxH,
                    gl_periods periods,
                    gl_ledgers ledgers,
                    gl_period_statuses glps,
                    fun_transfers gt';

  l_cur_where := ' WHERE trxH.trx_id = gt.trx_id AND
		      trxB.batch_id = gt.batch_id AND
                      GT.request_id = '''||p_request_id||''' AND
                      ledgers.ledger_id = gt.ledger_id AND
                      periods.period_set_name = ledgers.period_set_name AND
                      TRUNC(trxB.gl_date) BETWEEN periods.start_date
                                               AND periods.end_date AND
                      periods.adjustment_period_flag <> ''Y'' AND
                      glps.period_name = periods.period_name AND
                      glps.application_id = 101 AND
                      glps.set_of_books_id = ledgers.ledger_id';

   select sysdate into l_init_sysdate from dual;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '                   Transfer Intercompany Transactions to General Ledger Report        Date:'||to_char(sysdate,'DD-MON-YYYY HH:MM'));
   FND_FILE.NEW_LINE(FND_FILE.OUTPUT,2 );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                  GL Date From: ' || to_char(l_date_low, 'DD-MON-YYYY'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                    GL Date To: ' || to_char(l_date_high,'DD-MON-YYYY'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                   Ledger From: ' || p_ledger_low);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                     Ledger To: ' || p_ledger_high);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'             Legal Entity From: ' || p_le_low);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'               Legal Entity To: ' || p_le_high);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Intercompany Organization From: ' || p_ic_org_low);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  Intercompany Organization To: ' || p_ic_org_high);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'            Run Journal Import: ' || l_run_journal_import);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'       Create Summary Journals: ' || l_create_summary_journals);
   FND_FILE.NEW_LINE(FND_FILE.OUTPUT,2 );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Batch Number        Transaction Number  Transfer Status' );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'------------        ------------------  ----------------');

   /* Insert data into temp table */
  begin
  gt_insert_clause :='INSERT INTO fun_transfers(BATCH_ID, trx_id, org_name, org_id, le_id,
                            ledger_id, party_type_flag,
                            request_id, trx_status, description)
		  select gt.BATCH_ID, gt.TRX_ID, P.PARTY_NAME,
		  GT.PARTY_ID, GT.LE_ID, gt.LEDGER_ID,  gt.party_type_flag,
		  gt.p_request_id,
		  gt.STATUS,  gt.description
		  from fun_trx_batches trxb, gl_ledgers ledgers,
		  HZ_PARTIES P,
		     (
		       SELECT TB.BATCH_ID , TH.INITIATOR_ID party_id, TH.TRX_ID, ''I''
		       party_type_flag, '''||p_request_id||''' p_request_id, tB.description Description,
		       TB.FROM_LE_ID LE_ID, TH.STATUS, tB.from_ledger_id LEDGER_ID
		       FROM FUN_TRX_HEADERS TH, FUN_TRX_BATCHES TB
		       WHERE TH.INVOICE_FLAG = ''N''
		       AND NOT EXISTS ( SELECT TRX_ID FROM
				     FUN_TRANSFERS FT WHERE FT.TRX_ID = TH.TRX_ID AND
				     FT.PARTY_TYPE_FLAG = ''I'')
				     AND TH.STATUS IN (''APPROVED'',''XFER_RECI_GL'')
		       AND TH.BATCH_ID = TB.BATCH_ID
		       UNION ALL
		       SELECT TB.BATCH_ID, TH.RECIPIENT_ID party_id, TH.TRX_ID, ''R''
		       party_type_flag, '''||p_request_id||''' p_request_id, tH.description Description,
		       TH.TO_LE_ID LE_ID, TH.STATUS, TH.TO_LEDGER_ID LEDGER_ID
		       FROM FUN_TRX_HEADERS TH, FUN_TRX_BATCHES TB
		       WHERE TH.INVOICE_FLAG = ''N''
		       AND NOT EXISTS ( SELECT TRX_ID FROM
				     FUN_TRANSFERS FT WHERE FT.TRX_ID = TH.TRX_ID AND
				     FT.PARTY_TYPE_FLAG = ''R'')
				     AND TH.STATUS IN (''APPROVED'',''XFER_INI_GL'')
		       AND TH.BATCH_ID = TB.BATCH_ID
		     )gt
		     where trxb.batch_id = gt.batch_id
		     and ledgers.ledger_id = gt.ledger_id
		     AND P.PARTY_ID = GT.party_id ';


	IF (l_date_low IS NULL AND l_date_high IS NOT NULL) THEN
			gt_where_clause := gt_where_clause||' AND TRXB.GL_DATE BETWEEN TRUNC(to_date(trxB.gl_date,''dd-mon-yy''))
					  AND TRUNC(to_date('''||l_date_high||''',''dd-mon-yy'')) +0.99999';

		ELSE
			IF (l_date_low IS NOT NULL AND l_date_high IS NULL) THEN
				gt_where_clause := gt_where_clause||' AND TRXB.GL_DATE BETWEEN TRUNC(to_date('''||l_date_low||''',''dd-mon-yy''))
						  AND TRUNC(to_date(trxB.gl_date,''dd-mon-yy'')) +0.99999';

			ELSE
			    IF (l_date_low IS NOT NULL AND l_date_high IS NOT NULL) THEN
				gt_where_clause := gt_where_clause||' AND TRXB.GL_DATE BETWEEN TRUNC(to_date('''||l_date_low||''',''dd-mon-yy''))
						  AND TRUNC(to_date('''||l_date_high||''',''dd-mon-yy'')) +0.99999';

			    END IF;
			END IF;
	END IF;

	IF (p_ledger_low IS NULL AND p_ledger_high IS NOT NULL) THEN
		gt_where_clause := gt_where_clause || ' AND LEDGERS.NAME BETWEEN  ledgers.name and '''||p_ledger_high||'''';
        ELSE
		IF (p_ledger_low IS NOT NULL AND p_ledger_high IS NULL) THEN
			gt_where_clause := gt_where_clause || ' AND LEDGERS.NAME BETWEEN  '''||p_ledger_low||''' and ledgers.name';
               ELSE
		    IF (p_ledger_low IS NOT NULL AND p_ledger_high IS NOT NULL) THEN
			gt_where_clause := gt_where_clause || ' AND LEDGERS.NAME BETWEEN  '''||p_ledger_low||''' and '''||p_ledger_high||'''';
                    END IF;
                END IF;
	END IF;

	IF (p_ic_org_low IS NULL AND p_ic_org_high IS NOT NULL) THEN
		gt_where_clause := gt_where_clause || ' AND P.PARTY_NAME BETWEEN P.PARTY_NAME and '''||l_ic_org_high||'''';

        ELSE
		IF (p_ic_org_low IS NOT NULL AND p_ic_org_high IS NULL) THEN
			gt_where_clause := gt_where_clause || ' AND P.PARTY_NAME BETWEEN '''||l_ic_org_low||''' and P.PARTY_NAME';

		ELSE
		    IF (p_ic_org_low IS NOT NULL AND p_ic_org_high IS NOT NULL) THEN
			gt_where_clause := gt_where_clause || ' AND P.PARTY_NAME BETWEEN '''||l_ic_org_low||''' and '''||l_ic_org_high||'''';

                    END IF;
                END IF;
	END IF;

	IF (p_le_low IS NULL AND p_le_high IS NOT NULL) THEN
		gt_where_clause := gt_where_clause || ' AND EXISTS (SELECT NULL
                                                                  FROM XLE_ENTITY_PROFILES
                                                                  WHERE LEGAL_ENTITY_ID = gt.LE_ID
                                                                        AND NAME BETWEEN NAME and '''||p_le_high||''')';
        ELSE
		IF (p_le_low IS NOT NULL AND p_le_high IS NULL) THEN
		     gt_where_clause := gt_where_clause || ' AND EXISTS (SELECT NULL
                                                                      FROM XLE_ENTITY_PROFILES
                                                                      WHERE  LEGAL_ENTITY_ID = gt.LE_ID
                                                                             AND NAME BETWEEN '''||p_le_low||''' and NAME)';
		ELSE
		    IF (p_le_low IS NOT NULL AND p_le_high IS NOT NULL) THEN
			gt_where_clause := gt_where_clause || ' AND EXISTS (SELECT NULL
                                                                        FROM XLE_ENTITY_PROFILES
                                                                        WHERE LEGAL_ENTITY_ID = gt.LE_ID
                                                                              AND NAME BETWEEN '''||p_le_low||''' and '''||p_le_high||''')';
                    END IF;
                END IF;
	END IF;

	EXECUTE IMMEDIATE gt_insert_clause||gt_where_clause;
        commit;

	END;

	-- Bug 7173185. Changed the query to populate the REFERENCE4 column also.
   /*  Insert data into temp table ends here */
   insert_clause := 'INSERT INTO GL_INTERFACE
           (STATUS,
	    GROUP_ID,
            SET_OF_BOOKS_ID,
            ACCOUNTING_DATE,
            CURRENCY_CODE,
            DATE_CREATED,
            CREATED_BY,
            ACTUAL_FLAG,
            USER_JE_CATEGORY_NAME,
            USER_JE_SOURCE_NAME,
            CURRENCY_CONVERSION_DATE,
            USER_CURRENCY_CONVERSION_TYPE,
            ENTERED_DR,
            ENTERED_CR,
            REFERENCE10,
            CODE_COMBINATION_ID,
            LEDGER_ID,
            REFERENCE21,
            REFERENCE22,
            REFERENCE23,
            REFERENCE24,
            REFERENCE25,
            PERIOD_NAME,
            CHART_OF_ACCOUNTS_ID,
            REQUEST_ID,
	    REFERENCE4)';
   select_clause := ' SELECT ''NEW'','''||
        p_request_id||''',
        LEDGERS.LEDGER_ID,
        TRUNC(TRXB.GL_DATE),
        TRXB.CURRENCY_CODE,
        SYSDATE,
        D.CREATED_BY,
        ''A'','''||
        l_category||''','''||
        l_source||''',
        TRUNC(TRXB.GL_DATE),
        FUN_GL_BATCH_TRANSFER.GET_CONVERSION_TYPE(TRXB.EXCHANGE_RATE_TYPE),
        D.AMOUNT_DR,
        D.AMOUNT_CR,
	GT.DESCRIPTION,
        D.CCID,
        LEDGERS.LEDGER_ID,
        ''Intercompany Transaction'',
        TRXB.BATCH_ID,
        GT.TRX_ID,
        T.LINE_ID,
        D.DIST_ID,
        PERIODS.PERIOD_NAME,
        LEDGERS.CHART_OF_ACCOUNTS_ID,'''||
        p_request_id||''',
	TRXB.BATCH_NUMBER
 FROM
        GL_LEDGERS LEDGERS,
        GL_PERIOD_STATUSES GLPS,
	GL_PERIODS PERIODS,
        FUN_TRX_BATCHES TRXB,
        FUN_TRX_LINES T,
        FUN_DIST_LINES D,
	fun_transfers gt
 WHERE 	TRXB.BATCH_ID = GT.BATCH_ID
	AND GT.request_id = '''||p_request_id||'''
        AND LEDGERS.LEDGER_ID = gt.LEDGER_ID
        AND PERIODS.PERIOD_SET_NAME = LEDGERS.PERIOD_SET_NAME
        AND TRUNC(TRXB.GL_DATE) BETWEEN PERIODS.START_DATE AND PERIODS.END_DATE
        AND PERIODS.ADJUSTMENT_PERIOD_FLAG <> ''Y''
        AND GLPS.PERIOD_NAME = PERIODS.PERIOD_NAME
        AND GLPS.APPLICATION_ID = 101
        AND GLPS.SET_OF_BOOKS_ID = LEDGERS.LEDGER_ID
        AND T.TRX_ID =  GT.TRX_ID
        AND D.TRX_ID = T.TRX_ID
        AND D.PARTY_TYPE_FLAG = GT.PARTY_TYPE_FLAG
        AND GLPS.CLOSING_STATUS IN (''O'',''F'')
        AND FUN_GL_BATCH_TRANSFER.HAS_VALID_CONVERSION_RATE(TRXB.CURRENCY_CODE,LEDGERS.CURRENCY_CODE,
                                                            TRXB.EXCHANGE_RATE_TYPE,TRUNC(TRXB.GL_DATE)) = 1';

   l_cur_main_query := l_cur_select||l_cur_where;

   --Insert into GL_INTERFACE table.
   EXECUTE IMMEDIATE insert_clause || select_clause || where_clause;

   WF_EVENT.AddParameterToList(p_name=>'INIT_SYS_DATE',
                                            p_value=>l_init_sysdate,
                                            p_parameterlist =>l_parameter_list);

   WF_EVENT.AddParameterToList(p_name=>'TRX_TYPE',
                                            p_value=>'Intercompany Transaction',
                                            p_parameterlist=>l_parameter_list);

   l_event_key:=FUN_INITIATOR_WF_PKG.GENERATE_KEY(p_batch_id=>p_request_id,
                                                               p_trx_id => 0
                                                              );

   WF_EVENT.RAISE(p_event_name =>'oracle.apps.fun.batch.gl.transfer',
                                              p_event_key  =>l_event_key,
                                              p_parameters=>l_parameter_list);


   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		-- Bug # 6842245
	--	null
        	FND_FILE.PUT_LINE(FND_FILE.LOG,'INSERT BLOCK: No Data Found');
		raise;


	WHEN DUP_VAL_ON_INDEX THEN
		FND_FILE.NEW_LINE(FND_FILE.OUTPUT,2 );
        	FND_FILE.PUT_LINE(fnd_file.output,'  *****Another GL Transfer process is running with same set of transactions.*****');
		FND_FILE.PUT_LINE(FND_FILE.LOG,'Another GL Transfer process is running with same set of transactions.');
		rollback;
		raise;
	WHEN OTHERS THEN
		-- Bug # 6842245
		FND_FILE.PUT_LINE(FND_FILE.LOG,'INSERT BLOCK: Unexpected error:' || sqlcode || sqlerrm);
		 retcode := 2;
		raise;
   END;


-- add journal import code

   if p_run_journal_import = 'Y' then

  -- run journal import for each ledger id

	For o in c_import(p_request_id, l_source, l_category)
	loop
    		-- get interface run id
    		select gl_journal_import_s.nextval into v_interface_run_id from dual;

	    	insert into gl_interface_control (je_source_name,
                                      status,
                                      set_of_books_id,
                                      group_id,
                                      interface_run_id)
    		values ( 'Global Intercompany',
             		'S',
             		o.ledger_id,
             		p_request_id,       -- Bug No : 7215571
             		v_interface_run_id);


    /* Launch Concurrent Request to do journal import*/

     		import_request_id := fnd_request.submit_request(
 		        application => 'SQLGL',                  -- application short name
         		program => 'GLLEZL',                     -- program short name
         		description => null,                     -- program name
		        start_time => null,                      -- start date
		        sub_request=>FALSE,                      -- sub-request
         		argument1 => to_char(v_interface_run_id),           -- interface run id
		        argument2 => fnd_profile.value('GL_ACCESS_SET_ID'), -- set of books id
		        argument3 => 'N',                                   -- error to suspense flag
		        argument4 => to_char(l_date_low,'YYYY/MM/DD'),       -- from accounting date
		        argument5 => to_char(l_date_high,'YYYY/MM/DD'),      -- to accounting date
		        argument6 => p_create_summary_journals,   -- create summary flag
		        argument7 => 'Y',                         -- import desc flex flag
		        argument8 => 'Y');

  	end loop;
	--commit; Bug No: 6731040.
   end if;

-- do status updates
-- Need the decodes here because for each transaction, the IF condition
-- executes twice - once for Party Type R and once for 'I'
-- so the value of the status in the cursor variable is not really
-- the latest value. Prior iteration of the IF condition could have
-- set it to a value different to the value in the cursor
   OPEN c_transfer_obj for l_cur_main_query;
   FETCH c_transfer_obj BULK COLLECT INTO l_status_tbl,
                                   l_party_type_flag_tbl,
                                   l_error_mesg_tbl,
                                   l_trx_id_tbl,
                                   l_trx_num,
                                   l_batch_num,
                                   l_batch_id_tbl ; -- Bug 6797385.
   CLOSE c_transfer_obj;

   IF l_trx_id_tbl.COUNT > 0
   THEN
     FORALL l_index IN l_trx_id_tbl.FIRST .. l_trx_id_tbl.LAST
     UPDATE fun_trx_headers
           SET    status = DECODE (l_party_type_flag_tbl(l_index),
                           'I',DECODE (status,
                                       'APPROVED','XFER_INI_GL',
                                       'XFER_RECI_GL', 'COMPLETE'),
                           'R',DECODE (status,
                                       'APPROVED','XFER_RECI_GL',
                                       'XFER_INI_GL', 'COMPLETE'))
          WHERE  trx_id = l_trx_id_tbl(l_index)
          AND    l_error_mesg_tbl(l_index) = 'FUN_API_TRX_TRANSFERRED';
   END IF;
-- Bug 6797385. Update the status in fun_trx_batches starts here.
   IF l_batch_id_tbl.COUNT > 0
   THEN
       FORALL l_index IN l_batch_id_tbl.FIRST .. l_batch_id_tbl.LAST
       UPDATE fun_trx_batches b
       SET b.status = 'COMPLETE'
       WHERE NOT EXISTS ( SELECT trx_id
                   FROM   fun_trx_headers
                   WHERE  fun_trx_headers.batch_id = b.batch_id
                   AND    status NOT IN ('COMPLETE', 'REJECTED'))
       AND b.batch_id = l_batch_id_tbl(l_index)
       AND b.status <> 'COMPLETE';
   END IF;
-- Bug 6797385. Update the status in fun_trx_batches Ends here.
   IF l_trx_id_tbl.COUNT > 0  THEN
   	FOR l_index  IN l_trx_id_tbl.FIRST .. l_trx_id_tbl.LAST
	LOOP
          IF (l_error_mesg_tbl(l_index) like 'GL_PERIOD_NOT_OPEN%') THEN
              fnd_message.set_name('FUN','GL_PERIOD_NOT_OPEN');
              fnd_file.put_line(fnd_file.output, rpad(substr(l_batch_num(l_index), 1,20),20)||rpad(substr(l_trx_num(l_index),1,15),20)||fnd_message.get);
          ELSIF (l_error_mesg_tbl(l_index) like 'FUN_API_CONV_RATE_NOT_FOUND') THEN
              fnd_message.set_name('FUN','FUN_API_CONV_RATE_NOT_FOUND');
              fnd_file.put_line(fnd_file.output, rpad(substr(l_batch_num(l_index), 1,20),20)||rpad(substr(l_trx_num(l_index),1,15),20)||fnd_message.get);
          ELSE
              fnd_message.set_name('FUN','FUN_API_TRX_TRANSFERRED');
              fnd_file.put_line(fnd_file.output, rpad(substr(l_batch_num(l_index), 1,20),20)||rpad(substr(l_trx_num(l_index),1,15),20)||fnd_message.get);
          END IF;
       END LOOP;
       FND_FILE.NEW_LINE(FND_FILE.OUTPUT,2 );
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                   *****End Of Report*****');
   ELSE
       FND_FILE.NEW_LINE(FND_FILE.OUTPUT,2 );
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                   *****No Data Found*****');
   END IF;

/* Bug 6797385.
   UPDATE fun_trx_batches
   SET status = 'COMPLETE'
   WHERE status <> 'COMPLETE'
   AND NOT EXISTS ( SELECT trx_id
                   FROM   fun_trx_headers
                   WHERE  fun_trx_headers.batch_id = fun_trx_batches.batch_id
                   AND    status NOT IN ('COMPLETE', 'REJECTED'));
*/
    DELETE fun_transfers
    WHERE REQUEST_ID = P_REQUEST_ID;
    commit;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'No Data Found');
       -- Bug # 6842245
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Rolling Back All The Transactions');
       rollback;

       DELETE fun_transfers
       WHERE REQUEST_ID = P_REQUEST_ID;
       commit;

   WHEN OTHERS THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error:' || sqlcode || sqlerrm);
       retcode := 2;
       -- Bug # 6842245
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Rolling Back All The Transactions');
       rollback;

       DELETE fun_transfers
       WHERE REQUEST_ID = P_REQUEST_ID;
       commit;

   END GL_BATCH_TRANSFER;

END FUN_GL_BATCH_TRANSFER;



/
