--------------------------------------------------------
--  DDL for Package Body FV_REIMB_ACTIVITY_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_REIMB_ACTIVITY_PROCESS" AS
-- $Header: FVREACRB.pls 120.0.12010000.16 2009/12/01 12:44:36 yanasing noship $

g_period_name VARCHAR2(15);
g_period_num NUMBER;
g_period_year NUMBER;
g_ledger_id NUMBER;
g_coa_id NUMBER;
C_STATE_LEVEL CONSTANT NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_log_level   CONSTANT NUMBER         := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_module_name VARCHAR2(50) := 'fv.plsql.fv_reimb_activity_process.';
g_errbuf      VARCHAR2(500);
g_retcode     NUMBER := 0;
g_currency VARCHAR2(3);
g_gl_balancing_segment VARCHAR2(15);
g_gl_nat_acc_segment VARCHAR2(15);
g_reimb_agreement_segment VARCHAR2(50);
g_ussgl_flex_value_set_id NUMBER;
g_apps_id  Fnd_Id_Flex_Structures.application_id%TYPE;
g_id_flex_code Fnd_Id_Flex_Structures.id_flex_code%TYPE;
g_delimiter    Fnd_Id_Flex_Structures.concatenated_segment_delimiter%TYPE;
g_reimb_flex_value_id fnd_flex_values.flex_value_id%TYPE;

-- Variables used for dynamic sql

g_where        VARCHAR2(2000);
g_select       VARCHAR2(2000);
g_flex_low     VARCHAR2(2000);
g_flex_high    VARCHAR2(2000);
g_agree_sql    VARCHAR2(1000);

-- PL/SQL Tables to hold the low and high values,
-- used in Get_Application_Col_Names proc
gt_seg_low      Fnd_Flex_Ext.segmentarray;
gt_seg_high     Fnd_Flex_Ext.segmentarray;
g_nsegs_low    NUMBER;
g_nsegs_high   NUMBER;

-- PL/SQL Table to hold the flexfield column names
TYPE seg_name IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
gt_seg_name seg_name;

TYPE seg_codes IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
gt_seg_codes seg_codes;

i NUMBER;


PROCEDURE log(
      p_level             IN NUMBER,
      p_procedure_name    IN VARCHAR2,
      p_debug_info        IN VARCHAR2);

PROCEDURE get_period_details;
PROCEDURE get_segment_details;
PROCEDURE Get_Application_Col_Names;
PROCEDURE get_segment_values(seg_cnt IN NUMBER);
PROCEDURE populate_amount(p_column_id IN NUMBER,p_agree_num IN VARCHAR2);
PROCEDURE get_agreement_range;
PROCEDURE create_main_query(p_rec_sla_detail IN VARCHAR2,  p_select_mod IN VARCHAR2,
                          p_column_id IN NUMBER, p_main_sql OUT NOCOPY VARCHAR2);

PROCEDURE main
( p_errbuf                 OUT NOCOPY VARCHAR2,
  p_retcode                OUT NOCOPY NUMBER,
  p_ledger_id IN NUMBER,
  p_coa_id in NUMBER,
  p_period_name IN VARCHAR2,
  p_flex_low        IN        VARCHAR2,
  p_flex_high      IN      VARCHAR2,
  p_report_id IN VARCHAR2,
  p_attribute_set IN VARCHAR2,
  p_output_format  IN VARCHAR2
) IS
 l_rec_count NUMBER := 0;
  l_req_id NUMBER;
  l_call_status     BOOLEAN;
  l_rphase          VARCHAR2(30);
  l_rstatus         VARCHAR2(30);
  l_dphase          VARCHAR2(30);
  l_dstatus         VARCHAR2(30);
  l_message         VARCHAR2(240);
  l_module  VARCHAR2(500) := g_module_name||'.Main';
  l_error_message VARCHAR2(600);
  l_error_code BOOLEAN;
  l_seed_count NUMBER;
  l_Acct_count NUMBER;
  l_trx_number ra_customer_trx_all.trx_number%TYPE;
  l_purchase_order ra_customer_trx_all.purchase_order%TYPE;
  l_start_date_commitment ra_customer_trx_all.start_date_commitment%TYPE;
  l_end_date_commitment ra_customer_trx_all.end_date_commitment%TYPE;
  l_extended_amount ra_customer_trx_lines_all.extended_amount%TYPE;
  l_agree_num VARCHAR2(25);
  TYPE ref_type IS REF CURSOR ;
  agree_cur ref_type;
  l_ctr NUMBER;

BEGIN

FOR i IN 1..30 LOOP
gt_seg_codes(i):=null;
end loop;
log(C_STATE_LEVEL, l_module, 'Initialized the seg_codes');


    fv_utility.log_mesg('Parameters: ');
    fv_utility.log_mesg('p_ledger_id: '||p_ledger_id);
    fv_utility.log_mesg('p_flex_low: '||p_flex_low);
    fv_utility.log_mesg('p_flex_high: '||p_flex_high);
    fv_utility.log_mesg('p_period_name: '||p_period_name);
	log(C_STATE_LEVEL, l_module, 'p_report_id: '|| p_report_id);
	log(C_STATE_LEVEL, l_module, 'p_attribute_set: '|| p_attribute_set);
	log(C_STATE_LEVEL, l_module, 'p_output_format: '|| p_output_format);

    g_ledger_id := p_ledger_id;
    g_flex_low      := p_flex_low;
    g_flex_high     := p_flex_high;
    g_currency :=     'USD';
    g_period_name := p_period_name;
    SELECT CHART_OF_ACCOUNTS_ID
    INTO g_coa_id
    FROM gl_ledgers
    where  ledger_id = g_ledger_id;
    fv_utility.log_mesg('g_coa_id: '||g_coa_id);

    SELECT period_year, period_num
    INTO g_period_year, g_period_num
    FROM gl_period_statuses
    WHERE application_id = 101
    AND set_of_books_id = g_ledger_id
    AND period_name = g_period_name;

    fv_utility.log_mesg('g_period_year: '||g_period_year);
    fv_utility.log_mesg('g_period_num: '||g_period_num);


 -- Check whether set up done
 -- Check if Seed process was run

    SELECT COUNT(1) INTO l_seed_count
    FROM  Fv_reimb_definitions_lines
    WHERE set_of_books_id = g_ledger_id;

    IF l_seed_count=0  THEN
        g_retcode := -1 ;
        g_errbuf  :=   '    Please run the Populate Reimbursable Activity Report Definitions Process .'  ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module,g_errbuf) ;
        RETURN ;
    END IF;
-- Check whether Accounts are Defined in the form ,
-- Reimbursable Activity Report Definitions .

    SELECT COUNT(1) INTO l_Acct_count
    FROM   Fv_reimb_definitions_lines  fvrd ,
           Fv_reimb_def_Acct_assign fvda
    WHERE   fvrd.column_id=fvda.column_id
    AND     fvrd.set_of_books_id = g_ledger_id;

    IF l_Acct_count=0  THEN
        g_retcode := -1 ;
        g_errbuf  :=   '    Accounts not defined . Please define Accounts in the Reimbursable Activity Report
                             Definitions Form. '  ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module,g_errbuf) ;
        RETURN ;
    END IF;

----End of set up check

    --Call get_segment_details to populate all the segment names, Natural account Segment
    --Balancing Segment etc

     get_segment_details;

    IF g_retcode = 0 THEN
      log(C_STATE_LEVEL, l_module, 'Calling Get_Application_Col_Names....');
    END IF;

    Get_Application_Col_Names;

    IF g_retcode = 0 THEN
      log(C_STATE_LEVEL, l_module, 'Checking for the agreement numbers range, calling get_agreement_range  .....');
    END IF;

    get_agreement_range;

-- Delete all data from previous run. And populate it afresh.

    IF g_retcode = 0 THEN
      log(C_STATE_LEVEL, l_module, 'Deleting any previous records from FV_REIMB_ACTIVITY_TEMP  .....');
    END IF;

    DELETE FROM FV_REIMB_ACTIVITY_TEMP;


--Check for Reimb Agreement segment values in the flexfield low and high range
--If it is not null then assign v_low_reimb_agree and v_high_reimb_agree
--otherwise for all the values in the the value set and exists in in ra_trx_all

---------------------------Loop for agreement

OPEN agree_cur FOR g_agree_sql USING g_reimb_flex_value_id,g_ledger_id,g_currency;

LOOP

FETCH agree_cur INTO l_agree_num;

fv_utility.log_mesg('Agreement num: '||l_agree_num);

EXIT WHEN agree_cur%NOTFOUND;
-- call polulate_amount for each column_id

   populate_amount(1,l_agree_num);
   populate_amount(2,l_agree_num);
   populate_amount(3,l_agree_num);
   populate_amount(4,l_agree_num);
   populate_amount(5,l_agree_num);
   populate_amount(6,l_agree_num);
   populate_amount(7,l_agree_num);
   populate_amount(8,l_agree_num);
   populate_amount(9,l_agree_num);
   populate_amount(10,l_agree_num);
   populate_amount(11,l_agree_num);

--Bug8741007
      END LOOP;
CLOSE agree_cur;

            INSERT INTO FV_REIMB_ACTIVITY_TEMP(Reimb_Agreement_Num,
                                               Contract_Number,
                                               Billing_Limit,
                                               start_date,
                                               end_date,
                                               amount_obligation,
                                               amount_expended,
                                               amount_unfilled_order,
                                               amount_advance_collected,
                                               amount_advance_applied,
                                               amount_advance_balance,
                                               amount_earned,
                                               amount_billed,
                                               amount_receivable_collected,
                                               amount_receivable_balance,
                                               amount_agreement,
                                               REQUEST_ID,
                                               LAST_UPDATED_BY,
                                               LAST_UPDATE_LOGIN,
                                               CREATED_BY,
                                               CREATION_DATE,
                                               LAST_UPDATE_DATE,
                                                segment1,
                                                segment2,
                                                segment3,
                                                segment4,
                                                segment5,
                                                segment6,
                                                segment7,
                                                segment8,
                                                segment9,
                                                segment10,
                                                segment11,
                                                segment12,
                                                segment13,
                                                segment14,
                                                segment15,
                                                segment16,
                                                segment17,
                                                segment18,
                                                segment19,
                                                segment20,
                                                segment21,
                                                segment22,
                                                segment23,
                                                segment24,
                                                segment25,
                                                segment26,
                                                segment27,
                                                segment28,
                                                segment29,
                                                segment30,
                                                reported_flag
                                               )
                                        (SELECT Reimb_Agreement_Num,
                                                Contract_Number,
                                                Billing_Limit,
                                                start_date,
                                                end_date,
                                                sum(amount_obligation),
                                                sum(amount_expended),
                                                sum(amount_unfilled_order),
                                                sum(amount_advance_collected),
                                                sum(amount_advance_applied),
                                                sum(amount_advance_balance),
                                                sum(amount_earned),
                                                sum(amount_billed),
                                                sum(amount_receivable_collected),
                                                sum(amount_receivable_balance),
                                                sum(amount_agreement),
                                                REQUEST_ID,
                                                LAST_UPDATED_BY,
                                                LAST_UPDATE_LOGIN,
                                                CREATED_BY,
                                                SYSDATE,
                                                SYSDATE,
                                                segment1,
                                                segment2,
                                                segment3,
                                                segment4,
                                                segment5,
                                                segment6,
                                                segment7,
                                                segment8,
                                                segment9,
                                                segment10,
                                                segment11,
                                                segment12,
                                                segment13,
                                                segment14,
                                                segment15,
                                                segment16,
                                                segment17,
                                                segment18,
                                                segment19,
                                                segment20,
                                                segment21,
                                                segment22,
                                                segment23,
                                                segment24,
                                                segment25,
                                                segment26,
                                                segment27,
                                                segment28,
                                                segment29,
                                                segment30,
                                                'Y'
                                        FROM  FV_REIMB_ACTIVITY_TEMP
                                        WHERE reported_flag = 'N'
                                        GROUP BY
                                                Reimb_Agreement_Num,
                                                Contract_Number,
                                                Billing_Limit,
                                                start_date,
                                                end_date,
                                                REQUEST_ID,
                                                LAST_UPDATED_BY,
                                                LAST_UPDATE_LOGIN,
                                                CREATED_BY,
                                                segment1,
                                                segment2,
                                                segment3,
                                                segment4,
                                                segment5,
                                                segment6,
                                                segment7,
                                                segment8,
                                                segment9,
                                                segment10,
                                                segment11,
                                                segment12,
                                                segment13,
                                                segment14,
                                                segment15,
                                                segment16,
                                                segment17,
                                                segment18,
                                                segment19,
                                                segment20,
                                                segment21,
                                                segment22,
                                                segment23,
                                                segment24,
                                                segment25,
                                                segment26,
                                                segment27,
                                                segment28,
                                                segment29,
                                                segment30
                                                having
                                                  sum(amount_obligation) <> 0 or
                                                  sum(amount_expended)<> 0 or
                                                  sum(amount_unfilled_order)<> 0 or
                                                  sum(amount_advance_collected)<> 0 or
                                                  sum(amount_advance_applied)<> 0 or
                                                  sum(amount_advance_balance)<> 0 or
                                                  sum(amount_earned)<> 0 or
                                                  sum(amount_billed)<> 0 or
                                                  sum(amount_receivable_collected)<> 0 or
                                                  sum(amount_receivable_balance)<> 0 or
                                                  sum(amount_agreement) <> 0
                                                );

--Bug8741007
      --END LOOP;
--CLOSE agree_cur;

 DELETE FROM FV_REIMB_ACTIVITY_TEMP WHERE reported_flag = 'N';

   -- Submit the RXi Report
   BEGIN
      SELECT count(*)
        INTO l_rec_count
        FROM FV_REIMB_ACTIVITY_TEMP;

      IF l_rec_count >0 THEN
         l_req_id :=
         FND_REQUEST.SUBMIT_REQUEST ('FV','RXFVRACR','','',FALSE,
         'DIRECT', p_report_id, p_attribute_set, p_output_format);
         COMMIT;

         IF l_req_id = 0 THEN
            p_errbuf := 'Error submitting RX Report ';
            p_retcode := -1 ;
            RETURN;
          ELSE
           fv_utility.log_mesg('Concurrent Request Id for RX Report - ' ||l_req_id);
         END IF;

         l_call_status := Fnd_Concurrent.Wait_For_Request(
                           l_req_id, 20, 0, l_rphase, l_rstatus,
                           l_dphase, l_dstatus, l_message);

          IF (l_call_status = FALSE) THEN
             p_errbuf := 'Cannot wait for the status of RX Report.';
             p_retcode := 1;
          END IF;

       ELSE
        p_retcode := 1;
        p_errbuf  := '** No Data Found for the Reimbursamble Activity Process **';
        RETURN;
      END IF;
   END;
 END Main;

-------------------------------------------------------------------------------
PROCEDURE log (
      p_level             IN NUMBER,
      p_procedure_name    IN VARCHAR2,
      p_debug_info        IN VARCHAR2)
IS

BEGIN
  IF (p_level >= g_log_level ) THEN
    FND_LOG.STRING(p_level,
                   p_procedure_name,
                   p_debug_info);
  END IF;
END log;
-------------------------------------------------------------------------------
 ----------------------------------------------
PROCEDURE get_period_details IS
    BEGIN
      SELECT period_num, period_year
      INTO   g_period_num, g_period_year
      FROM   gl_period_statuses
      WHERE  period_name = g_period_name
      AND    application_id = 101
      AND    ledger_id = g_ledger_id;
END;
-------------------------------------------------
 PROCEDURE get_segment_details IS

  l_module  VARCHAR2(500) := g_module_name||'.get_segment_details';
  l_error_message VARCHAR2(600);
  l_error_code BOOLEAN;


--This cursor fetches the value_set_id for the natural account segment
  CURSOR flex_value_id_cur IS
  SELECT flex_value_set_id
  FROM fnd_id_flex_segments
  WHERE application_id = 101
     AND application_column_name =g_gl_nat_acc_segment
     AND id_flex_code = g_id_flex_code
     AND id_flex_num = g_coa_id
     AND enabled_flag = 'Y' ;

 BEGIN
   g_retcode := 0;


-- finding the Account and Balancing segments
FV_UTILITY.get_segment_col_names(g_coa_id,
                                 g_gl_nat_acc_segment,
                                 g_gl_balancing_segment,
                                 l_error_code,
                                 l_error_message);

log(C_STATE_LEVEL, l_module, 'g_gl_balancing_segment: '||g_gl_balancing_segment);
log(C_STATE_LEVEL, l_module, 'g_gl_nat_acc_segment: '||g_gl_nat_acc_segment);


--Finding the Reimbursable Segment name from the reimb segment defined
-- in the Federal Financial Options
BEGIN
      SELECT application_column_name
      INTO   g_reimb_agreement_segment
      FROM   FND_ID_FLEX_SEGMENTS_VL
      WHERE  application_id         = 101
      AND    id_flex_code           = 'GL#'
      AND    id_flex_num            = g_coa_id
      AND    enabled_flag           = 'Y'
      AND    segment_name like
        (Select REIMB_AGREEMENT_SEGMENT_VALUE
         FROM fv_reimb_segment
         where set_of_books_id = g_ledger_id);

--      'Reimbursable Agreement';
EXCEPTION
WHEN no_data_found THEN
log(C_STATE_LEVEL, l_module, 'Error deriving the Reimbursable Agreement Segment ');
END;

log(C_STATE_LEVEL, l_module, 'g_reimb_agreement_segment: '||g_reimb_agreement_segment);

    g_delimiter := Fnd_Flex_Ext.get_delimiter
                    (
                      'SQLGL',
                      g_id_flex_code,
                      g_coa_id
                    );
--finding the flex_value_set_id for the Natural Account segment
    OPEN flex_value_id_cur ;
    FETCH flex_value_id_cur
     INTO g_ussgl_flex_value_set_id ;
    CLOSE flex_value_id_cur ;

    log(C_STATE_LEVEL, l_module, 'g_ussgl_flex_value_set_id: '||g_ussgl_flex_value_set_id);

    IF (g_delimiter IS NULL) THEN
      g_retcode := 2     ;
      g_errbuf  := 'The Flexfield Structure is not found' ;
      fv_utility.log_mesg(fnd_log.level_error, l_module,g_errbuf) ;
    END IF;

  IF (g_retcode = 0) THEN
    log(C_STATE_LEVEL, l_module, ' delimiter is ' ||g_delimiter);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  g_retcode := SQLCODE;
  g_errbuf  := SQLERRM;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module||'.final_exception',g_errbuf) ;
  RAISE;
END get_segment_details;
-----------------------------------------------------------------

PROCEDURE Get_Application_Col_Names IS
  l_module VARCHAR2(200);
    l_ctr      NUMBER;


    CURSOR  seg_names_cur IS
      SELECT application_column_name
      FROM   Fnd_Id_Flex_Segments
      WHERE  application_id = g_apps_id
      AND    id_flex_code   = g_id_flex_code
      AND    id_flex_num    = g_coa_id
      ORDER BY segment_num;
BEGIN
  l_module := g_module_name || 'Get_Application_Col_Names';

   i := 1;

   -- Get the Flexfield Column Names(Application Column Names)
   -- for the Chart Of Accounts Id passed.
   FOR v_seg_names IN seg_names_cur LOOP
    gt_seg_name(i) := v_seg_names.application_column_name;
    i := i + 1;
   END LOOP;

    -- Get the Maximum number of segments
   l_ctr := gt_seg_name.COUNT;
   log(C_STATE_LEVEL, l_module, 'NUMBER OF SEGMENTS ARE  '||TO_CHAR(l_CTR));
    -- Calling Get_Segment_Values procedure
   Get_Segment_Values(l_ctr);

EXCEPTION
  WHEN OTHERS THEN
    g_retcode := SQLCODE;
    g_errbuf  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module||'.final_exception',g_errbuf) ;
 END  Get_Application_Col_Names;
 ---------------------------------------------------------------------
 -- ------------------------------------------------------------------
--                      Procedure Get_Segment_Values
-- ------------------------------------------------------------------
-- Get_Segment_Values procedure is called from Get_Application_Col_Names
-- procedure.
-- This procedure  builds the where clause based on the segment low
-- and high values entered in SRS window ,which will be used in
-- building the cursor query in main()
-- ------------------------------------------------------------------


PROCEDURE get_segment_values(seg_cnt NUMBER)
IS

  l_module VARCHAR2(200);

-- Variables needed for the Breakup_Segments API,
-- used in Get_Application_Col_Names proc
--l_nsegs_low    NUMBER;
--l_nsegs_high   NUMBER;

CURSOR  seg_num_cur (p_application_column_name VARCHAR2)  IS
      SELECT segment_num
      FROM   Fnd_Id_Flex_Segments
      WHERE  application_id = g_apps_id
      AND    id_flex_code   = g_id_flex_code
      AND    id_flex_num    = g_coa_id
      AND    application_column_name=p_application_column_name ;
l_acc_seg_num   NUMBER;
l_bal_seg_num   NUMBER  ;
l_agree_seg_num  NUMBER  ;
-- To count the first entered range in the Felxfield window .
l_first_seg  NUMBER:=0 ;
BEGIN
  l_module := g_module_name || 'Get_Segment_Values';
g_where := '' ;

-- Get low segment values

    log(C_STATE_LEVEL, l_module, ' Calling populate low segments');

        g_nsegs_low := Fnd_Flex_Ext.breakup_segments
                                (g_flex_low,
                                 g_delimiter,
                                 gt_seg_low );
        log(C_STATE_LEVEL, l_module, ' Clow segments: '|| g_nsegs_low);
-- Get high segment values

    log(C_STATE_LEVEL, l_module, ' Calling populate high segments');

        g_nsegs_high := Fnd_Flex_Ext.breakup_segments
                                (g_flex_high,
                                 g_delimiter,
                                 gt_seg_high );
  log(C_STATE_LEVEL, l_module, ' High segments: '|| g_nsegs_high);

-- Get the Balancing segment  segment number for Flexfield
OPEN   seg_num_cur(g_gl_balancing_segment ) ;
FETCH  seg_num_cur INTO l_bal_seg_num  ;
CLOSE seg_num_cur ;

  log(C_STATE_LEVEL, l_module, ' BALANCING SEGMENT NUMBER  IS ' ||l_BAL_SEG_NUM );

-- Get the Accounting segment number for Flexfield
OPEN   seg_num_cur (g_gl_nat_acc_segment);
FETCH  seg_num_cur INTO l_acc_seg_num ;
CLOSE seg_num_cur;
    log(C_STATE_LEVEL, l_module, ' Accounting segment number  is ' ||l_ACC_SEG_NUM );
-- Get the Reimburabale Agreement Segment number for Flexfield
OPEN   seg_num_cur (g_reimb_agreement_segment);
FETCH  seg_num_cur INTO l_agree_seg_num ;
CLOSE seg_num_cur;
  log(C_STATE_LEVEL, l_module, 'Reimburabale agreement segment number  is ' ||l_agree_seg_num ) ;
--Checking if user has entered the account range in the natural account segment
  IF  g_nsegs_low >1 THEN
    IF gt_seg_low(l_acc_seg_num) IS NOT NULL THEN

           gt_seg_low(i):=NULL ;
           gt_seg_high(i):=NULL ;

            log(C_STATE_LEVEL, l_module, 'User has given account range as parameters for this process.this account range will be overriden  ');
            log(C_STATE_LEVEL, l_module, 'With account ranges given in the report definitions set up form  ') ;
    END IF ;
  END IF;

g_select := '';
FOR i IN 1..30 LOOP
  IF (i <> l_acc_seg_num AND i <> l_agree_seg_num) THEN
    IF l_first_seg >=1 THEN
      g_select := g_select||' , glcc.segment'||i;
    ELSE
      g_select := g_select||'glcc.segment'||i;
      l_first_seg:=l_first_seg+1 ;
    END IF;
  END IF;
END LOOP;
/*
-- Construct the concatenate segments based on the Accounting range entered
  FOR i IN 1..seg_cnt LOOP
    IF  (gt_seg_low(i) IS NOT NULL) AND
        ( i <> l_acc_seg_num AND i <> l_agree_seg_num) THEN
            IF l_first_seg >=1 THEN
               g_select:= g_select||' , glcc.'||gt_seg_name(i);
            ELSE
                g_select:= g_select||'glcc.'||gt_seg_name(i);
                l_first_seg:=l_first_seg+1 ;
            END IF ;
    END IF ;
  END LOOP ;
 */
       log(C_STATE_LEVEL, l_module, 'Select statement is   ' ||g_select);
 -- Construct a where condition to be used to select the
 -- transactions from gl_balances and gl_bc_packets
l_first_seg:=0 ;
IF  g_nsegs_low >1 THEN

    FOR i IN 1..seg_cnt LOOP

            IF (gt_seg_low(i) IS NOT NULL) AND ( i <> l_acc_seg_num AND i <> l_agree_seg_num) THEN

                 IF l_first_seg >=1 THEN
                    g_where := g_where ||' AND  '||'glcc.'||
                          gt_seg_name(i) ||'  BETWEEN '
                                ||''''||gt_seg_low(i)||''''||'  AND  '
                                ||''''||gt_seg_high(i)||'''' ;
                 ELSE
                    g_where := ' AND glcc.'||gt_seg_name(i) ||'  BETWEEN  '
                                ||''''||gt_seg_low(i)||''''||'  AND  '
                                ||''''||gt_seg_high(i)||'''' ;
                            l_first_seg:=l_first_seg+1 ;
                 END IF ;
            END IF ;
    END LOOP;
END IF;
    log(C_STATE_LEVEL, l_module, 'WHERE clause is   ' ||g_where );
--Populate_CCIDs(g_select,g_where);
EXCEPTION
  WHEN OTHERS THEN
    g_retcode := SQLCODE;
    g_ERRBUF  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module||'.final_exception',g_ERRBUF) ;
    RAISE;
END Get_Segment_Values ;
------------------------------------
--    Procedure to poulate the gt table for all the columns

PROCEDURE populate_amount(p_column_id IN NUMBER,
                          p_agree_num IN VARCHAR2) IS

-- Variables used for fetching values from XLA table
l_sla_amount       VARCHAR2(1000);

--Variables used for GL_BALANCES and GL_BC_PACKETS tables
l_bal_amount       VARCHAR2(1000);
l_bc_amount        VARCHAR2(1000);
l_glbal_sql        VARCHAR2(3000);
l_glbc_sql         VARCHAR2(3000);
l_trx_sql          VARCHAR2(1000);
l_column_id NUMBER;
l_rec_sla_detail VARCHAR2(1);
l_module  VARCHAR2(500) := g_module_name||'.populate_amount';
l_main_sql        VARCHAR2(25000);
l_main_cursor     INTEGER;
--declare cursors
TYPE ref_type IS REF CURSOR ;
segment_cur ref_type;
l_trx_number ra_customer_trx_all.trx_number%TYPE;
l_purchase_order ra_customer_trx_all.purchase_order%TYPE;
l_start_date_commitment ra_customer_trx_all.start_date_commitment%TYPE;
l_end_date_commitment ra_customer_trx_all.end_date_commitment%TYPE;
l_extended_amount ra_customer_trx_lines_all.extended_amount%TYPE;
l_agree_num VARCHAR2(25);
l_amount VARCHAR2(50);
l_select_mod   VARCHAR2(2000);
l_exec_ret     INTEGER     ;
l_count NUMBER(2);
l_activity_rec FV_REIMB_ACTIVITY_TEMP%ROWTYPE;
l_temp_segnumber VARCHAR2(10);
l_natural_balance_type VARCHAR2(10);
l_segment1 VARCHAR2(30);
l_segment2 VARCHAR2(30);
l_segment3 VARCHAR2(30);
l_segment4 VARCHAR2(30);
l_segment5 VARCHAR2(30);
l_segment6 VARCHAR2(30);
l_segment7 VARCHAR2(30);
l_segment8 VARCHAR2(30);
l_segment9 VARCHAR2(30);
l_segment10 VARCHAR2(30);
l_segment11 VARCHAR2(30);
l_segment12 VARCHAR2(30);
l_segment13 VARCHAR2(30);
l_segment14 VARCHAR2(30);
l_segment15 VARCHAR2(30);
l_segment16 VARCHAR2(30);
l_segment17 VARCHAR2(30);
l_segment18 VARCHAR2(30);
l_segment19 VARCHAR2(30);
l_segment20 VARCHAR2(30);
l_segment21 VARCHAR2(30);
l_segment22 VARCHAR2(30);
l_segment23 VARCHAR2(30);
l_segment24 VARCHAR2(30);
l_segment25 VARCHAR2(30);
l_segment26 VARCHAR2(30);
l_segment27 VARCHAR2(30);
l_segment28 VARCHAR2(30);
l_segment29 VARCHAR2(30);
l_segment30 VARCHAR2(30);

BEGIN

l_column_id := p_column_id;
l_agree_num := p_agree_num;

BEGIN
-- Bug 8992292
--Added condition to check set_of_books_id to avoid  multiple rows
SELECT rec_sla_detail, natural_balance_type
INTO l_rec_sla_detail, l_natural_balance_type
FROM fv_reimb_definitions_lines
WHERE column_id = l_column_id and set_of_books_id=g_ledger_id;
  EXCEPTION
    WHEN NO_DATA_FOUND then
    g_retcode := SQLCODE;
    g_ERRBUF  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module||'Incomplete Report Definition Setup',g_ERRBUF) ;
    RAISE;
END;
-- Remove 'glcc.' from g_select
SELECT REPLACE(g_select, 'glcc.', '') INTO l_select_mod FROM dual;

log(C_STATE_LEVEL, l_module, 'l_select_mod : '||l_select_mod);
log(C_STATE_LEVEL, l_module, 'l_column_id : '||l_column_id);

create_main_query(l_rec_sla_detail, l_select_mod, l_column_id, l_main_sql);


  -- Fetch the segments into the binary table gt_seg_codes.
  -- If l_select_mod = SEGMENT1 , SEGMENT13 , SEGMENT15 THEN
  -- gt_seg_codes(1) = SEGMENT1 , gt_seg_codes(13) = SEGMENT13 , gt_seg_codes(15) = SEGMENT15
--
  WHILE LENGTH(l_select_mod)>9 LOOP
    SELECT substr(l_select_mod,1, instr(l_select_mod, ' , ')) INTO l_temp_segnumber FROM dual;
    gt_seg_codes((to_number((substr(l_temp_segnumber,8))))) := l_temp_segnumber;
    SELECT substr(l_select_mod, instr(l_select_mod, ' , ')+3) INTO l_select_mod FROM dual;
  END LOOP;
  gt_seg_codes((to_number((substr(l_select_mod,8))))) := l_select_mod;

  FOR counter IN 1..30
  LOOP
    IF (gt_seg_codes(counter) IS not null) then
      log(C_STATE_LEVEL, l_module, 'gt_seg_codes( '|| counter ||'):  '||gt_seg_codes(counter));
    END IF;
  END LOOP;

--  FOR counter IN 1..30
--  LOOP
--    gt_seg_codes(counter) := 'segment'||counter;
--    log(C_STATE_LEVEL, l_module, 'gt_seg_codes( '|| counter ||'):  '||gt_seg_codes(counter));
--  END LOOP;


  BEGIN
  l_main_cursor := DBMS_SQL.OPEN_CURSOR  ;
  EXCEPTION
    WHEN OTHERS THEN
      g_retcode := SQLCODE;
      g_ERRBUF  := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module||'.dbms_sql_l_main_cursor',g_ERRBUF) ;
      RAISE;
  END ;

  BEGIN
    dbms_sql.parse(l_main_cursor,l_main_sql,DBMS_SQL.V7);
    EXCEPTION
      WHEN OTHERS THEN
        g_retcode := SQLCODE;
        g_ERRBUF  := SQLERRM;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module||'.dbms_sql_parse_l_main_cursor',g_ERRBUF) ;
        RAISE;
  END ;

log(C_STATE_LEVEL, l_module, 'g_period_name: '|| g_period_name );
log(C_STATE_LEVEL, l_module, 'g_ledger_id: '|| g_ledger_id );
log(C_STATE_LEVEL, l_module, 'g_ussgl_flex_value_set_id: '|| g_ussgl_flex_value_set_id );
log(C_STATE_LEVEL, l_module, 'g_coa_id: '|| g_coa_id );
log(C_STATE_LEVEL, l_module, 'l_column_id: '|| l_column_id );

  IF (l_rec_sla_detail = 'N') THEN
      --dbms_sql.bind_variable(l_main_cursor,':g_period_year',g_period_year);
      --dbms_sql.bind_variable(l_main_cursor,':g_period_num',g_period_num);
      dbms_sql.bind_variable(l_main_cursor,':g_ledger_id',g_ledger_id);
      dbms_sql.bind_variable(l_main_cursor,':g_ussgl_flex_value_set_id',g_ussgl_flex_value_set_id);
      dbms_sql.bind_variable(l_main_cursor,':g_coa_id',g_coa_id);
      dbms_sql.bind_variable(l_main_cursor,':l_agree_num',p_agree_num);
      dbms_sql.bind_variable(l_main_cursor,':l_column_id',l_column_id);
      --dbms_sql.bind_variable(l_main_cursor,':g_period_year',g_period_year);
      --dbms_sql.bind_variable(l_main_cursor,':g_period_num',g_period_num);
      dbms_sql.bind_variable(l_main_cursor,':g_ledger_id',g_ledger_id);
      dbms_sql.bind_variable(l_main_cursor,':g_ussgl_flex_value_set_id',g_ussgl_flex_value_set_id);
      dbms_sql.bind_variable(l_main_cursor,':g_coa_id',g_coa_id);
      dbms_sql.bind_variable(l_main_cursor,':l_agree_num',p_agree_num);
      dbms_sql.bind_variable(l_main_cursor,':l_column_id',l_column_id);
  ELSE
      --dbms_sql.bind_variable(l_main_cursor,':g_period_name',g_period_name);
      dbms_sql.bind_variable(l_main_cursor,':g_ledger_id',g_ledger_id);
      dbms_sql.bind_variable(l_main_cursor,':g_ussgl_flex_value_set_id',g_ussgl_flex_value_set_id);
      dbms_sql.bind_variable(l_main_cursor,':g_coa_id',g_coa_id);
      dbms_sql.bind_variable(l_main_cursor,':l_agree_num',p_agree_num);
      dbms_sql.bind_variable(l_main_cursor,':l_column_id',l_column_id);
  END IF;

	log(C_STATE_LEVEL, l_module, 'completed dbms_sql.bind_variable' );

  l_count :=0;
  IF gt_seg_codes(1) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment1,25);
  END IF;
  IF gt_seg_codes(2) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment2,25);
  END IF;
  IF gt_seg_codes(3) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment3,25);
  END IF;
  IF gt_seg_codes(4) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment4,25);
  END IF;
  IF gt_seg_codes(5) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment5,25);
  END IF;
  IF gt_seg_codes(6) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment6,25);
  END IF;
  IF gt_seg_codes(7) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment7,25);
  END IF;
  IF gt_seg_codes(8) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment8,25);
  END IF;
  IF gt_seg_codes(9) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment9,25);
  END IF;
  IF gt_seg_codes(10) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment10,25);
  END IF;
  IF gt_seg_codes(11) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment11,25);
  END IF;
  IF gt_seg_codes(12) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment12,25);
  END IF;
  IF gt_seg_codes(13) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment13,25);
  END IF;
  IF gt_seg_codes(14) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment14,25);
  END IF;
  IF gt_seg_codes(15) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment15,25);
  END IF;
  IF gt_seg_codes(16) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment16,25);
  END IF;
  IF gt_seg_codes(17) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment17,25);
  END IF;
  IF gt_seg_codes(18) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment18,25);
  END IF;
  IF gt_seg_codes(19) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment19,25);
  END IF;
  IF gt_seg_codes(20) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment20,25);
  END IF;
  IF gt_seg_codes(21) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment21,25);
  END IF;
  IF gt_seg_codes(22) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment22,25);
  END IF;
  IF gt_seg_codes(23) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment23,25);
  END IF;
  IF gt_seg_codes(24) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment24,25);
  END IF;
  IF gt_seg_codes(25) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment25,25);
  END IF;
  IF gt_seg_codes(26) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment26,25);
  END IF;
  IF gt_seg_codes(27) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment27,25);
  END IF;
  IF gt_seg_codes(28) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment28,25);
  END IF;
  IF gt_seg_codes(29) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment29,25);
  END IF;
  IF gt_seg_codes(30) IS NOT NULL THEN
            l_count := l_count+1 ;
            dbms_sql.define_column(l_main_cursor,l_count,l_segment30,25);
  END IF;
          l_count := l_count+1 ;
          dbms_sql.define_column(l_main_cursor,l_count,l_amount,25);

	log(C_STATE_LEVEL, l_module, 'completed dbms_sql.define_column' );

  BEGIN
    l_exec_ret := dbms_sql.execute(l_main_cursor);
    EXCEPTION
      WHEN OTHERS THEN
        g_retcode := SQLCODE;
        g_ERRBUF  := SQLERRM;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module||'.dbms_sql_execute_l_main_cursor',g_ERRBUF) ;
        RAISE;
  END ;

	log(C_STATE_LEVEL, l_module, 'completed dbms_sql.execute' );

l_trx_sql:='SELECT h.trx_number, h.purchase_order,
            h.start_date_commitment,
            h.end_date_commitment,
            l.extended_amount
     FROM   ra_customer_trx_all h,
            ra_customer_trx_lines_all l
     WHERE  h.set_of_books_id = :g_ledger_id
     AND    h.trx_number = :g_agree_num
     AND    h.customer_trx_id = l.customer_trx_id';

EXECUTE IMMEDIATE l_trx_sql INTO l_trx_number, l_purchase_order,
    l_start_date_commitment,
    l_end_date_commitment,
    l_extended_amount
    USING
    g_ledger_id, l_agree_num;

	log(C_STATE_LEVEL, l_module, 'proceeding with dbms_sql.fetch_rows ' );

  WHILE dbms_sql.fetch_rows(l_main_cursor)>0 LOOP

    log(C_STATE_LEVEL, l_module, 'In side while loop: ');

    l_count:=0;
    IF gt_seg_codes(1) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment1);
      log(C_STATE_LEVEL, l_module, ' l_segment1 '|| l_segment1);
      l_activity_rec.segment1 := l_segment1;
    END IF;
    IF gt_seg_codes(2) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment2);
      log(C_STATE_LEVEL, l_module, ' l_segment2 '|| l_segment2);
      l_activity_rec.segment2 := l_segment2;
    END IF;
    IF gt_seg_codes(3) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment3);
      log(C_STATE_LEVEL, l_module, ' l_segment3 '|| l_segment3);
      l_activity_rec.segment3 := l_segment3;
    END IF;
    IF gt_seg_codes(4) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment4);
      log(C_STATE_LEVEL, l_module, ' l_segment4 '|| l_segment4);
      l_activity_rec.segment4 := l_segment4;
    END IF;
    IF gt_seg_codes(5) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment5);
      log(C_STATE_LEVEL, l_module, ' l_segment5 '|| l_segment5);
      l_activity_rec.segment5 := l_segment5;
    END IF;
    IF gt_seg_codes(6) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment6);
      log(C_STATE_LEVEL, l_module, ' l_segment6 '|| l_segment6);
      l_activity_rec.segment6 := l_segment6;
    END IF;
    IF gt_seg_codes(7) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment7);
      log(C_STATE_LEVEL, l_module, ' l_segment7 '|| l_segment7);
      l_activity_rec.segment7 := l_segment7;
    END IF;
    IF gt_seg_codes(8) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment8);
      log(C_STATE_LEVEL, l_module, ' l_segment8 '|| l_segment8);
      l_activity_rec.segment8 := l_segment8;
    END IF;
    IF gt_seg_codes(9) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment9);
      log(C_STATE_LEVEL, l_module, ' l_segment9 '|| l_segment9);
      l_activity_rec.segment9 := l_segment9;
    END IF;
    IF gt_seg_codes(10) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment10);
      log(C_STATE_LEVEL, l_module, ' l_segment10 '|| l_segment10);
      l_activity_rec.segment10 := l_segment10;
    END IF;
    IF gt_seg_codes(11) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment11);
      log(C_STATE_LEVEL, l_module, ' l_segment11 '|| l_segment11);
      l_activity_rec.segment11 := l_segment11;
    END IF;
    IF gt_seg_codes(12) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment12);
      log(C_STATE_LEVEL, l_module, ' l_segment12 '|| l_segment12);
      l_activity_rec.segment12 := l_segment12;
    END IF;
    IF gt_seg_codes(13) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment13);
      log(C_STATE_LEVEL, l_module, ' l_segment13 '|| l_segment13);
      l_activity_rec.segment13 := l_segment13;
    END IF;
        IF gt_seg_codes(14) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment14);
      log(C_STATE_LEVEL, l_module, ' l_segment14 '|| l_segment14);
      l_activity_rec.segment14 := l_segment14;
    END IF;
    IF gt_seg_codes(15) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment15);
      log(C_STATE_LEVEL, l_module, ' l_segment15 '|| l_segment15);
      l_activity_rec.segment15 := l_segment15;
    END IF;
    IF gt_seg_codes(16) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment16);
      log(C_STATE_LEVEL, l_module, ' l_segment16 '|| l_segment16);
      l_activity_rec.segment16 := l_segment16;
    END IF;
    IF gt_seg_codes(17) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment17);
      log(C_STATE_LEVEL, l_module, ' l_segment17 '|| l_segment17);
      l_activity_rec.segment17 := l_segment17;
    END IF;
    IF gt_seg_codes(18) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment18);
      log(C_STATE_LEVEL, l_module, ' l_segment18 '|| l_segment18);
      l_activity_rec.segment18 := l_segment18;
    END IF;
    IF gt_seg_codes(19) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment19);
      log(C_STATE_LEVEL, l_module, ' l_segment19 '|| l_segment19);
      l_activity_rec.segment19 := l_segment19;
    END IF;
    IF gt_seg_codes(20) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment20);
      log(C_STATE_LEVEL, l_module, ' l_segment20 '|| l_segment20);
      l_activity_rec.segment20 := l_segment20;
    END IF;
    IF gt_seg_codes(21) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment21);
      log(C_STATE_LEVEL, l_module, ' l_segment21 '|| l_segment21);
      l_activity_rec.segment21 := l_segment21;
    END IF;
    IF gt_seg_codes(22) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment22);
      log(C_STATE_LEVEL, l_module, ' l_segment22 '|| l_segment22);
      l_activity_rec.segment22 := l_segment22;
    END IF;
    IF gt_seg_codes(23) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment23);
      log(C_STATE_LEVEL, l_module, ' l_segment23 '|| l_segment23);
      l_activity_rec.segment23 := l_segment23;
    END IF;
        IF gt_seg_codes(24) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment24);
      log(C_STATE_LEVEL, l_module, ' l_segment24 '|| l_segment24);
      l_activity_rec.segment24 := l_segment24;
    END IF;
    IF gt_seg_codes(25) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment25);
      log(C_STATE_LEVEL, l_module, ' l_segment25 '|| l_segment25);
      l_activity_rec.segment25 := l_segment25;
    END IF;
    IF gt_seg_codes(26) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment26);
      log(C_STATE_LEVEL, l_module, ' l_segment26 '|| l_segment26);
      l_activity_rec.segment26 := l_segment26;
    END IF;
    IF gt_seg_codes(27) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment27);
      log(C_STATE_LEVEL, l_module, ' l_segment27 '|| l_segment27);
      l_activity_rec.segment27 := l_segment27;
    END IF;
    IF gt_seg_codes(28) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment28);
      log(C_STATE_LEVEL, l_module, ' l_segment28 '|| l_segment28);
      l_activity_rec.segment28 := l_segment28;
    END IF;
    IF gt_seg_codes(29) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment29);
      log(C_STATE_LEVEL, l_module, ' l_segment29 '|| l_segment29);
      l_activity_rec.segment29 := l_segment29;
    END IF;
    IF gt_seg_codes(30) IS NOT NULL THEN
      l_count := l_count+1 ;
      dbms_sql.column_value(l_main_cursor, l_count, l_segment30);
      log(C_STATE_LEVEL, l_module, ' l_segment30 '|| l_segment30);
      l_activity_rec.segment30 := l_segment30;
    END IF;
    l_count := l_count+1 ;
    dbms_sql.column_value(l_main_cursor, l_count, l_amount);
    log(C_STATE_LEVEL, l_module, 'l_amount '|| l_amount);


   IF (l_natural_balance_type = 'Credit') then
        l_amount := l_amount * -1;
    END IF;

   CASE l_column_id
      WHEN 1 THEN l_activity_rec.amount_agreement := l_amount;
      WHEN 2 THEN l_activity_rec.amount_obligation := l_amount;
      WHEN 3 THEN l_activity_rec.amount_expended := l_amount;
      WHEN 4 THEN l_activity_rec.amount_unfilled_order := l_amount;
      WHEN 5 THEN l_activity_rec.amount_advance_collected  := l_amount;
      WHEN 6 THEN l_activity_rec.amount_advance_applied := l_amount;
      WHEN 7 THEN l_activity_rec.amount_advance_balance := l_amount;
      WHEN 8 THEN l_activity_rec.amount_earned := l_amount;
      WHEN 9 THEN l_activity_rec.amount_billed := l_amount;
      WHEN 10 THEN l_activity_rec.amount_receivable_collected := l_amount;
      WHEN 11 THEN l_activity_rec.amount_receivable_balance := l_amount;
    END CASE;

    log(C_STATE_LEVEL, l_module, '************************************************');
    log(C_STATE_LEVEL, l_module, 'Inserting values to FV_REIMB_ACTIVITY_TEMP with reported_flag = N ');
    log(C_STATE_LEVEL, l_module, 'Reimb_Agreement_Num: '||l_trx_number);
    log(C_STATE_LEVEL, l_module, 'amount_obligation: '||nvl(l_activity_rec.amount_obligation,0));
    log(C_STATE_LEVEL, l_module, 'amount_expended: '||nvl(l_activity_rec.amount_expended,0));
    log(C_STATE_LEVEL, l_module, 'amount_unfilled_order: '||nvl(l_activity_rec.amount_unfilled_order,0));
    log(C_STATE_LEVEL, l_module, 'amount_advance_collected: '||nvl(l_activity_rec.amount_advance_collected,0));
    log(C_STATE_LEVEL, l_module, 'amount_advance_applied: '||nvl(l_activity_rec.amount_advance_applied,0));
    log(C_STATE_LEVEL, l_module, 'amount_advance_balance: '||nvl(l_activity_rec.amount_advance_balance,0));
    log(C_STATE_LEVEL, l_module, 'amount_earned: '||nvl(l_activity_rec.amount_earned,0));
    log(C_STATE_LEVEL, l_module, 'amount_billed: '||nvl(l_activity_rec.amount_billed,0));
    log(C_STATE_LEVEL, l_module, 'amount_receivable_collected: '||nvl(l_activity_rec.amount_receivable_collected,0));
    log(C_STATE_LEVEL, l_module, 'amount_receivable_balance: '||nvl(l_activity_rec.amount_receivable_balance,0));
    log(C_STATE_LEVEL, l_module, 'amount_agreement: '||nvl(l_activity_rec.amount_agreement,0));
    log(C_STATE_LEVEL, l_module, 'segment1: '||l_activity_rec.segment1);
    log(C_STATE_LEVEL, l_module, 'segment2: '||l_activity_rec.segment2);
    log(C_STATE_LEVEL, l_module, 'segment3: '||l_activity_rec.segment3);
    log(C_STATE_LEVEL, l_module, 'segment4: '||l_activity_rec.segment4);
    log(C_STATE_LEVEL, l_module, 'segment5: '||l_activity_rec.segment5);
    log(C_STATE_LEVEL, l_module, 'segment6: '||l_activity_rec.segment6);
    log(C_STATE_LEVEL, l_module, 'segment7: '||l_activity_rec.segment7);
    log(C_STATE_LEVEL, l_module, 'segment8: '||l_activity_rec.segment8);
    log(C_STATE_LEVEL, l_module, 'segment9: '||l_activity_rec.segment9);
    log(C_STATE_LEVEL, l_module, 'segment10: '||l_activity_rec.segment10);
    log(C_STATE_LEVEL, l_module, 'segment11: '||l_activity_rec.segment11);
    log(C_STATE_LEVEL, l_module, 'segment12: '||l_activity_rec.segment12);
    log(C_STATE_LEVEL, l_module, 'segment13: '||l_activity_rec.segment13);
    log(C_STATE_LEVEL, l_module, 'segment14: '||l_activity_rec.segment14);
    log(C_STATE_LEVEL, l_module, 'segment15: '||l_activity_rec.segment15);
    log(C_STATE_LEVEL, l_module, 'segment16: '||l_activity_rec.segment16);
    log(C_STATE_LEVEL, l_module, 'segment17: '||l_activity_rec.segment17);
    log(C_STATE_LEVEL, l_module, 'segment18: '||l_activity_rec.segment18);
    log(C_STATE_LEVEL, l_module, 'segment19: '||l_activity_rec.segment19);
    log(C_STATE_LEVEL, l_module, 'segment20: '||l_activity_rec.segment20);
    log(C_STATE_LEVEL, l_module, 'segment21: '||l_activity_rec.segment21);
    log(C_STATE_LEVEL, l_module, 'segment22: '||l_activity_rec.segment22);
    log(C_STATE_LEVEL, l_module, 'segment23: '||l_activity_rec.segment23);
    log(C_STATE_LEVEL, l_module, 'segment24: '||l_activity_rec.segment24);
    log(C_STATE_LEVEL, l_module, 'segment25: '||l_activity_rec.segment25);
    log(C_STATE_LEVEL, l_module, 'segment26: '||l_activity_rec.segment26);
    log(C_STATE_LEVEL, l_module, 'segment27: '||l_activity_rec.segment27);
    log(C_STATE_LEVEL, l_module, 'segment28: '||l_activity_rec.segment28);
    log(C_STATE_LEVEL, l_module, 'segment29: '||l_activity_rec.segment29);
    log(C_STATE_LEVEL, l_module, 'segment30: '||l_activity_rec.segment30);
    log(C_STATE_LEVEL, l_module, '************************************************');

    INSERT INTO FV_REIMB_ACTIVITY_TEMP        (Reimb_Agreement_Num,
                                               Contract_Number,
                                               Billing_Limit,
                                               start_date,
                                               end_date,
                                               amount_obligation,
                                               amount_expended,
                                               amount_unfilled_order,
                                               amount_advance_collected,
                                               amount_advance_applied,
                                               amount_advance_balance,
                                               amount_earned,
                                               amount_billed,
                                               amount_receivable_collected,
                                               amount_receivable_balance,
                                               amount_agreement,
                                               REQUEST_ID,
                                               LAST_UPDATED_BY,
                                               LAST_UPDATE_LOGIN,
                                               CREATED_BY,
                                               CREATION_DATE,
                                               LAST_UPDATE_DATE,
                                               segment1,
                                               segment2,
                                               segment3,
                                               segment4,
                                               segment5,
                                               segment6,
                                               segment7,
                                               segment8,
                                               segment9,
                                               segment10,
                                               segment11,
                                               segment12,
                                               segment13,
                                               segment14,
                                               segment15,
                                               segment16,
                                               segment17,
                                               segment18,
                                               segment19,
                                               segment20,
                                               segment21,
                                               segment22,
                                               segment23,
                                               segment24,
                                               segment25,
                                               segment26,
                                               segment27,
                                               segment28,
                                               segment29,
                                               segment30,
                                               reported_flag)
                                        values(l_trx_number,
                                               l_purchase_order,
                                               l_extended_amount,
                                               l_start_date_commitment,
                                               l_end_date_commitment,
                                               nvl(l_activity_rec.amount_obligation,0),
                                               nvl(l_activity_rec.amount_expended,0),
                                               nvl(l_activity_rec.amount_unfilled_order,0),
                                               nvl(l_activity_rec.amount_advance_collected,0),
                                               nvl(l_activity_rec.amount_advance_applied,0),
                                               nvl(l_activity_rec.amount_advance_balance,0),
                                               nvl(l_activity_rec.amount_earned,0),
                                               nvl(l_activity_rec.amount_billed,0),
                                               nvl(l_activity_rec.amount_receivable_collected,0),
                                               nvl(l_activity_rec.amount_receivable_balance,0),
                                               nvl(l_activity_rec.amount_agreement,0),
                                               fnd_global.conc_request_id,
                                               fnd_global.user_id,
                                               fnd_global.login_id,
                                               fnd_global.user_id,
                                               SYSDATE,
                                               SYSDATE,
                                               l_activity_rec.segment1,
                                               l_activity_rec.segment2,
                                               l_activity_rec.segment3,
                                               l_activity_rec.segment4,
                                               l_activity_rec.segment5,
                                               l_activity_rec.segment6,
                                               l_activity_rec.segment7,
                                               l_activity_rec.segment8,
                                               l_activity_rec.segment9,
                                               l_activity_rec.segment10,
                                               l_activity_rec.segment11,
                                               l_activity_rec.segment12,
                                               l_activity_rec.segment13,
                                               l_activity_rec.segment14,
                                               l_activity_rec.segment15,
                                               l_activity_rec.segment16,
                                               l_activity_rec.segment17,
                                               l_activity_rec.segment18,
                                               l_activity_rec.segment19,
                                               l_activity_rec.segment20,
                                               l_activity_rec.segment21,
                                               l_activity_rec.segment22,
                                               l_activity_rec.segment23,
                                               l_activity_rec.segment24,
                                               l_activity_rec.segment25,
                                               l_activity_rec.segment26,
                                               l_activity_rec.segment27,
                                               l_activity_rec.segment28,
                                               l_activity_rec.segment29,
                                               l_activity_rec.segment30,
                                               'N'
                                              );

END LOOP;



END populate_amount;
--------------------------------------------------------------------------
--This procedure checks if there is a range of Agreement Numbers provided
--in the Accounting Flexfield Low and High parameters.
--If the range is not provided then we fetch all the values from the
--Reimbursable Agreement value Set and check if the transaction exists with
--that Transaction number and class of 'Guarantee' in the ra_customer_trx
--This procedure will form the sql statement to fetch the agreement numbers
---------------------------------------------------------------------------

PROCEDURE get_agreement_range IS

  CURSOR flex_reimb_value_id_cur IS
  SELECT flex_value_set_id
  FROM fnd_id_flex_segments
  WHERE application_id = 101
     AND application_column_name =g_reimb_agreement_segment
     AND id_flex_code = g_id_flex_code
     AND id_flex_num = g_coa_id
     AND enabled_flag = 'Y' ;

  CURSOR  reimb_segment_num_cur (p_application_column_name VARCHAR2)  IS
      SELECT segment_num
      FROM   Fnd_Id_Flex_Segments
      WHERE  application_id = g_apps_id
      AND    id_flex_code   = g_id_flex_code
      AND    id_flex_num    = g_coa_id
      AND    application_column_name=p_application_column_name ;

l_module  VARCHAR2(500) := g_module_name||'.get_agreemnt_range';
l_low_reimb VARCHAR2(50);
l_high_reimb VARCHAR2(50);
l_reim_agreement_segment_num NUMBER;

BEGIN

--Get the value_set_id for the reimbursable Agreement
 OPEN flex_reimb_value_id_cur ;
 FETCH flex_reimb_value_id_cur
 INTO g_reimb_flex_value_id ;
 CLOSE flex_reimb_value_id_cur ;
 log(C_STATE_LEVEL, l_module, ' Reimb agree val set id: '||g_reimb_flex_value_id);


--Get the Segment Number for the reimbursable Agreement Segment
 OPEN reimb_segment_num_cur(g_reimb_agreement_segment);
 FETCH  reimb_segment_num_cur INTO l_reim_agreement_segment_num;
 CLOSE reimb_segment_num_cur;

   IF g_nsegs_low >1 AND gt_seg_low(l_reim_agreement_segment_num) IS NOT NULL THEN
     l_low_reimb := gt_seg_low(l_reim_agreement_segment_num);
     l_high_reimb:= gt_seg_high(l_reim_agreement_segment_num);

  log(C_STATE_LEVEL, l_module, ' l_low_reimb:   ' ||l_low_reimb);
  log(C_STATE_LEVEL, l_module, ' l_high_reimb   ' ||l_high_reimb);

        g_agree_sql:='SELECT f.flex_value
         FROM  fnd_flex_values_vl f
         where flex_value_set_id = :g_flex_reimb_value_id
         AND flex_value BETWEEN '||''''||l_low_reimb||''''||' AND '||''''||l_high_reimb||''''||'
          AND f.flex_value in (SELECT r.trx_number
         FROM ra_customer_trx_all r,
         ra_cust_trx_types_all t
         WHERE r.set_of_books_id = :g_ledger_id
         AND r.invoice_currency_code = :g_currency
         AND r.cust_trx_type_id = t.cust_trx_type_id
         AND t.type = ''GUAR'' )';

  log(C_STATE_LEVEL, l_module, 'User has given reimbursable agreement range as parameters for this process.  ');
 ELSE

 g_agree_sql:= 'SELECT f.flex_value
         FROM  fnd_flex_values_vl f
         where flex_value_set_id = :g_flex_reimb_value_id
         AND f.flex_value in(SELECT r.trx_number
         FROM ra_customer_trx_all r,
         ra_cust_trx_types_all t
         WHERE r.set_of_books_id = :g_ledger_id
         AND r.invoice_currency_code = :g_currency
         AND r.cust_trx_type_id = t.cust_trx_type_id
         AND t.type = ''GUAR'' )';

  log(C_STATE_LEVEL, l_module, 'User has not given reimbursable agreement range as parameters for this process.all values in value set   ') ;
   log(C_STATE_LEVEL, l_module, 'Will be picked which exist as transactions with class guarantee   ') ;
 END IF ;

log(C_STATE_LEVEL, l_module, 'g_agree_sql: '||g_agree_sql);

END get_agreement_range;

-- Constructs the main sql query depending on the status of
-- Receivables SLA Detail check box. If it is not checked the query
-- is constructed based on gl_balances and gl_bc_packets tables.
--  Else the the query is constructed based on xla_ae_lines table.


PROCEDURE create_main_query(p_rec_sla_detail IN VARCHAR2, p_select_mod IN VARCHAR2,
                        p_column_id IN NUMBER, p_main_sql OUT NOCOPY VARCHAR2) IS


  l_bal_amount_sql       VARCHAR2(1000);
  l_bc_amount_sql        VARCHAR2(1000);
  l_glbal_sql        VARCHAR2(6000);
  l_glbc_sql         VARCHAR2(6000);
  l_sla_amount_sql       VARCHAR2(1000);
  l_main_sql        VARCHAR2(25000);
  l_module  VARCHAR2(500) := g_module_name||'.create_main_query';

  BEGIN

   IF (p_rec_sla_detail = 'N') THEN
    log(C_STATE_LEVEL, l_module, 'p_rec_sla_detail is Not checked: '||p_rec_sla_detail);

    l_bal_amount_sql:=' SUM(nvl(glb.period_net_dr,0) - nvl(glb.period_net_cr,0)) amount ' ;

    l_glbal_sql := 'SELECT  '||g_select||' , '||l_bal_amount_sql||'
      FROM gl_balances glb,
         gl_code_combinations_kfv glcc,
         fv_reimb_definitions_lines frd,
         fv_reimb_def_acct_assign fva
    WHERE
      frd.column_id = fva.column_id
      and glb.actual_flag =''A''
      --and glb.period_year = :g_period_year
      --and glb.period_num = :g_period_num
      and glb.ledger_id = :g_ledger_id
      AND glb.template_id IS NULL
      AND glb.currency_code = ''USD''
      AND glb.code_combination_id = glcc.code_combination_id
      AND ( glcc.'||g_gl_nat_acc_segment ||
                    '  BETWEEN  '|| ' fva.account_from  ' ||
                    ' AND  '|| ' fva.account_to  OR EXISTS '||
                    ' (SELECT 1 FROM fnd_flex_value_hierarchies h '||
                    ' WHERE  glcc.'||g_gl_nat_acc_segment ||'  BETWEEN'  ||
                    ' child_flex_value_low AND child_flex_value_high '||
                    ' AND  h.flex_value_set_id = :g_ussgl_flex_value_set_id' ||
                    ' AND  h.PARENT_FLEX_VALUE BETWEEN  fva.account_from '||
                    '  AND fva.account_to ))
      AND frd.set_of_books_id= :g_ledger_id
      AND frd.set_of_books_id =fva.set_of_books_id
      AND glcc.chart_of_accounts_id = :g_coa_id
      AND glcc.' || g_reimb_agreement_segment ||' = :l_agree_num
      and frd.column_id = :l_column_id'||
      g_where ||' GROUP BY '||g_select;

      log(C_STATE_LEVEL, l_module, 'l_glbal_sql: '|| l_glbal_sql);

      l_bc_amount_sql :=    ' SUM (Nvl(glbc.accounted_dr,0) - nvl(glbc.accounted_cr,0) ) amount';

      l_glbc_sql:= 'SELECT '||g_select||' , '||l_bc_amount_sql||'
                     FROM gl_bc_packets glbc,
                       gl_code_combinations_kfv glcc,
                       fv_reimb_definitions_lines frd,
                       fv_reimb_def_acct_assign fva
                    WHERE
                      frd.column_id = fva.column_id
                      and glbc.actual_flag =''A''
                      --and glbc.period_year = :g_period_year
                      --and glbc.period_num = :g_period_num
                      and glbc.ledger_id = :g_ledger_id
                      AND glbc.template_id IS NULL
                      AND glbc.status_code = ''A''
                      AND glbc.currency_code = ''USD''
                      AND glbc.code_combination_id = glcc.code_combination_id
                      AND ( glcc.'||g_gl_nat_acc_segment ||
                                    '  BETWEEN  '|| ' fva.account_from  ' ||
                                    ' AND  '|| ' fva.account_to  OR EXISTS '||
                                    ' (SELECT 1 FROM fnd_flex_value_hierarchies h '||
                                    ' WHERE  glcc.'||g_gl_nat_acc_segment ||'  BETWEEN '||
                                    ' child_flex_value_low AND child_flex_value_high '||
                                    ' AND  h.flex_value_set_id = :g_ussgl_flex_value_set_id' ||
                                    ' AND  h.PARENT_FLEX_VALUE BETWEEN  fva.account_from '||
                                    '  AND fva.account_to ))
  		      AND frd.set_of_books_id= :g_ledger_id
 		      AND frd.set_of_books_id =fva.set_of_books_id
                      and glcc.chart_of_accounts_id = :g_coa_id
                      AND glcc.' || g_reimb_agreement_segment ||' = :l_agree_num
                      and frd.column_id = :l_column_id'||
                      g_where ||' GROUP BY '||g_select;

      log(C_STATE_LEVEL, l_module, 'l_glbc_sql: '|| l_glbc_sql);

      l_main_sql := 'SELECT '||p_select_mod||' , SUM(amount) net_amount FROM ( '
                        || l_glbal_sql ||' UNION ALL ' || l_glbc_sql || ' ) GROUP BY ' ||p_select_mod;

      log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,1,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,1001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,2001,1000));
      log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,3001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,4001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,5001,1000));
      log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,6001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,7001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,8001,1000));
      log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,9001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,10001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,11001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,12001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,13001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,14001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,15001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,16001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,17001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,18001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,19001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,20001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,21001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,22001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,23001,1000));
	  log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| substr(l_main_sql,24001,1000));

  ELSE
--Modified for bug 8849465
      l_sla_amount_sql := 'DECODE (fva.journal_side,
                            ''Debit'',
                            SUM(NVL(ACCOUNTED_DR,0)),
                            ''Credit'',
                            (SUM(NVL(ACCOUNTED_CR,0)) * -1),
                            SUM (NVL(ACCOUNTED_DR,0)- NVL(ACCOUNTED_CR,0))
                            ) amount	' ;

      l_main_sql :=
              'SELECT '||g_select||' , '||l_sla_amount_sql||'
                  FROM gl_code_combinations_kfv glcc,
                       fv_reimb_definitions_lines frd,
                       fv_reimb_def_acct_assign fva,
                       xla_ae_headers xah,
                       xla_ae_lines xal
                  WHERE
                      frd.column_id = fva.column_id
                      AND xah.ACCOUNTING_ENTRY_STATUS_CODE = ''F''
                      --AND xah.period_name = :g_period_name
                      AND xal.ledger_id = :g_ledger_id
                      AND xal.CURRENCY_CODE = ''USD''
                      AND xal.ae_header_id = xah.ae_header_id
                      AND xal.code_combination_id = glcc.code_combination_id
                      AND xal.application_id = xah.application_id
                      AND xal.ledger_id = xah.ledger_id
                      AND ( glcc.'||g_gl_nat_acc_segment ||
                                 '  BETWEEN  '|| ' fva.account_from  ' ||
                                 ' AND  '|| ' fva.account_to  OR EXISTS '||
                                 ' (SELECT 1 FROM fnd_flex_value_hierarchies h '||
                                    ' WHERE  glcc.'||g_gl_nat_acc_segment
                               ||' BETWEEN '|| ' child_flex_value_low AND child_flex_value_high '||
                                    ' AND  h.flex_value_set_id = :g_ussgl_flex_value_set_id' ||
                                    ' AND  h.PARENT_FLEX_VALUE BETWEEN fva.account_from '
                                      || '  AND fva.account_to ))
		      AND frd.set_of_books_id= :g_ledger_id
	 	      AND frd.set_of_books_id =fva.set_of_books_id
                      and glcc.chart_of_accounts_id = :g_coa_id
                      AND glcc.' || g_reimb_agreement_segment ||' = :l_agree_num
                      and frd.column_id = :l_column_id'
                      ||g_where ||' GROUP BY fva.journal_side , '||g_select;

            log(C_STATE_LEVEL, l_module, 'l_main_sql: '|| l_main_sql);



  END IF;
  p_main_sql := l_main_sql ;


END create_main_query;



BEGIN
 g_apps_id      := 101;
 g_id_flex_code := 'GL#';

END fv_reimb_activity_process;

/
