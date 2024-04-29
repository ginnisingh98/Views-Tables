--------------------------------------------------------
--  DDL for Package Body FV_FUNDS_AVAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FUNDS_AVAIL_PKG" AS
/* $Header: FVFUNAVB.pls 120.12.12000000.4 2007/08/01 21:19:54 sasukuma ship $  */

 --  ======================================================================
    --                  Variable Naming Conventions
    --  ======================================================================
    --  1. Input/Output Parameter global variables
    --     have the format                           "vp_<Variable Name>"
    --  2. Other Global Variables have the format     "vg_<Variable_Name>"
    --  3. Procedure Level local variables have
    --     the format                                 "vl_<Variable_Name>"
    --  4. PL/SQL Table variables have               "vt_<Variable_Name>"
    --  5. User Defined Excpetions have              "e_<Exception_Name>"
   --  ======================================================================
    --                          Parameter Global Variable Declarations
    --  ======================================================================
    g_module_name VARCHAR2(100);
    vp_errbuf           VARCHAR2(5000)  ;
    vp_retcode          NUMBER := 0 ;
    vp_sob_id           Gl_Sets_Of_Books.set_of_books_id%TYPE   ;
    vp_coa_id           Gl_Sets_Of_Books.chart_of_accounts_id%TYPE       ;
    vp_currency_code    Fnd_Currencies.currency_code%TYPE   ;
    vp_flex_low         VARCHAR2(2000);
    vp_flex_high        VARCHAR2(2000);
    vp_treasury_symbol_id  fv_treasury_symbols.treasury_symbol_id%type  ;
    vp_summary_type     VARCHAR2(1);
    vp_period_name      VARCHAR2(30);
    vp_report_id        NUMBER;
    vp_units			VARCHAR2(30);
    --  ======================================================================
    --                           Other Global Variable Declarations
    --  ======================================================================
    vg_bal_segment  Fnd_Id_Flex_Segments.application_column_name%TYPE;
    vg_acct_segment Fnd_Id_Flex_Segments.application_column_name%TYPE;
    vg_apps_id      Fnd_Id_Flex_Structures.application_id%TYPE;
    vg_id_flex_code Fnd_Id_Flex_Structures.id_flex_code%TYPE;
    vg_delimiter    Fnd_Id_Flex_Structures.concatenated_segment_delimiter%TYPE ;
    vg_flex_value_id fnd_flex_values.flex_value_id%TYPE;
    i           NUMBER          ;

    -- Variable used for dynamic sql in the Populate_CCIDs procedure
    vg_where        VARCHAR2(2000);
    vg_select       VARCHAR2(2000);
    vg_amount           VARCHAR2(1000);

    -- PL/SQL Tables to hold the low and high values,
    -- used in Get_Application_Col_Names proc
    vt_seg_low      Fnd_Flex_Ext.segmentarray;
    vt_seg_high     Fnd_Flex_Ext.segmentarray;
    -- PL/SQL Table to hold the flexfield column names
    TYPE seg_name IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    vt_seg_name seg_name;
    -- Variables needed for the Breakup_Segments API,
    -- used in Get_Application_Col_Names proc
    vg_nsegs_low    NUMBER          ;
    vg_nsegs_high   NUMBER          ;


     -- Variables used in the procedure Get_Bfy_Segment
    vg_bfy_segment      Fnd_Id_Flex_Segments.application_column_name%TYPE;

-- ------------------------------------------------------------------
--                      Procedure Main
-- ------------------------------------------------------------------
--Main procedure is called from concurrent program.
--This procedure calls all the subsequent procedures
--in the funds available process
-- ------------------------------------------------------------------
PROCEDURE Main(
        errbuf          OUT NOCOPY     VARCHAR2,
        retcode         OUT NOCOPY     NUMBER,
        sob_id                  NUMBER,
        coa_id                  NUMBER,
        summary_type            VARCHAR2  ,
        report_id               NUMBER,
        Treasury_symbol_id      NUMBER ,
        flex_low                VARCHAR2,
        flex_high               VARCHAR2,
        period_name             VARCHAR2 ,
        currency_code           VARCHAR2 ,
        units			VARCHAR2)
IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'Main';

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'START OF FUNDS AVAILBILITY MAIN PROCESS ......');
 END IF;

   -- Load the parameter global variables
   vp_sob_id        := sob_id   ;
   vp_coa_id        := coa_id   ;
   vp_currency_code := currency_code ;
   vp_summary_type  := summary_type ;
   vp_report_id     := report_id;
   vp_treasury_symbol_id := treasury_symbol_id ;
   vp_flex_low      := flex_low;
   vp_flex_high     := flex_high;
   vp_period_name   := period_name ;
   vp_units			:=units ;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'	SET OF BOOKS ID IS         '||TO_CHAR(SOB_ID));
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'	CHART OF ACCOUNTS ID IS    ' || TO_CHAR(VP_COA_ID));
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   	RANGE FLEX FIELD LOW VALUE IS    '||VP_FLEX_LOW);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   	RANGE FLEX FIELD HIGH VALUE IS    '||VP_FLEX_HIGH);
 END IF;

    --  Get Qualifier Segments
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'DERIVING THE QUALIFIER SEGMENTS.....') ;
 END IF;
    Get_Qualifier_Segments;
	IF vp_retcode = 0 THEN
   	  IF (vp_summary_type = 'A' )  THEN
     -- User selected  Summary Types as Accounting Flexfield Range
        Get_Application_Col_Names;
       	  ELSIF  (vp_summary_type = 'T' ) THEN
      -- User selected  Summary Types as Treasury symbol
        Treasury_Symbol_attributes ;
      	  END IF;
 	END IF;

   IF vp_retcode = 0 THEN
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SUBMITTING FUNDS AVAILABILITY REPORTS .....');
 END IF;
       Submit_Reports  ;
   END IF;
 -- Checking for any errors
   IF vp_retcode <> 0 THEN
    errbuf := vp_errbuf;
    retcode := vp_retcode;
    ROLLBACK;
   ELSE
    COMMIT;
   END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'END THE FUNDS AVAILABILITY MAIN PROCESS ......');
 END IF;
EXCEPTION
   WHEN OTHERS THEN
        vp_retcode := SQLCODE ;
        vp_errbuf  := SQLERRM  ||' -- Error in Main procedure' ;
    errbuf := vp_errbuf;
    retcode := vp_retcode;

    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',VP_ERRBUF) ;
        RETURN ;
END Main;
-- ------------------------------------------------------------------
--                      Procedure Get_Qualifier_Segments
-- ------------------------------------------------------------------
-- Get_Qualifier_Segments procedure is called from the Main procedure.
-- This procedure gets the accounting and the balancing segments.
-- ------------------------------------------------------------------

PROCEDURE Get_Qualifier_Segments
IS
  l_module_name VARCHAR2(200);
  CURSOR flex_value_id_cur IS
  SELECT flex_value_set_id
    FROM fnd_id_flex_segments
   WHERE application_id = 101
     AND application_column_name =vg_acct_segment
     AND id_flex_code = vg_id_flex_code
     AND id_flex_num = vp_coa_id
     AND enabled_flag = 'Y' ;

  l_ret_val   BOOLEAN;
BEGIN
  l_module_name := g_module_name || 'Get_Qualifier_Segments';

  vp_retcode := 0;

  --Get the Account Segment
  l_ret_val := FND_FLEX_APIS.GET_SEGMENT_COLUMN
               (
                 x_application_id  => vg_apps_id,
                 x_id_flex_code    => vg_id_flex_code,
                 x_id_flex_num     => vp_coa_id,
                 x_seg_attr_type   => 'GL_ACCOUNT',
                 x_app_column_name => vg_acct_segment
               );
  IF (NOT l_ret_val) THEN
    vp_retcode := 2     ;
    vp_errbuf  := 'Cannot read Account Segment Information' ;
    fv_utility.log_mesg(fnd_log.level_error, l_module_name,vp_errbuf) ;
  END IF;

  IF (vp_retcode = 0) THEN
    l_ret_val := FND_FLEX_APIS.GET_SEGMENT_COLUMN
                 (
                   x_application_id  => vg_apps_id,
                   x_id_flex_code    => vg_id_flex_code,
                   x_id_flex_num     => vp_coa_id,
                   x_seg_attr_type   => 'GL_BALANCING',
                   x_app_column_name => vg_bal_segment
                 );

    IF (NOT l_ret_val) THEN
      vp_retcode := 2     ;
      vp_errbuf  := 'Cannot read Balancing Segment Information' ;
      fv_utility.log_mesg(fnd_log.level_error, l_module_name,vp_errbuf) ;
    END IF;
  END IF;


  IF (vp_retcode = 0) THEN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level ) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'       balancing segment is '||vg_bal_segment);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'       natural accounting segment is '||vg_acct_segment);
    END IF;
  END IF;

  IF (vp_retcode = 0) THEN
    -- Get the Delimiter
    vg_delimiter := Fnd_Flex_Ext.get_delimiter
                    (
                      'SQLGL',
                      vg_id_flex_code,
                      vp_coa_id
                    );

    OPEN flex_value_id_cur ;
    FETCH flex_value_id_cur
     INTO vg_flex_value_id ;
    CLOSE flex_value_id_cur ;

    IF (vg_delimiter is NULL) THEN
      vp_retcode := 2     ;
      vp_errbuf  := 'The Flexfield Structure is not found' ;
      fv_utility.log_mesg(fnd_log.level_error, l_module_name,vp_errbuf) ;
    END IF;
  END IF;

  IF (vp_retcode = 0) THEN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level ) then
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'       delimiter is ' ||vg_delimiter) ;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  vp_retcode := SQLCODE;
  vp_errbuf  := SQLERRM;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf) ;
  RAISE;
END Get_Qualifier_Segments ;

-- ------------------------------------------------------------------
--                      Procedure Get_Application_Col_Names
-- ------------------------------------------------------------------
-- Get_Application_Col_Names procedure is called from the Main procedure.
-- This procedure gets the application column names of the accounting
-- flexfield for the passed chart of account id.
-- ------------------------------------------------------------------
PROCEDURE Get_Application_Col_Names IS
  l_module_name VARCHAR2(200);
    vl_ctr      NUMBER;

    CURSOR  seg_names_cur IS
      SELECT application_column_name
      FROM   Fnd_Id_Flex_Segments
      WHERE  application_id = vg_apps_id
      AND    id_flex_code   = vg_id_flex_code
      AND    id_flex_num    = vp_coa_id
      ORDER BY segment_num;
BEGIN
  l_module_name := g_module_name || 'Get_Application_Col_Names';

   i := 1;

   -- Get the Flexfield Column Names(Application Column Names)
   -- for the Chart Of Accounts Id passed.
   FOR vc_seg_names IN seg_names_cur LOOP
    vt_seg_name(i) := vc_seg_names.application_column_name;
    i := i + 1;
   END LOOP;

    -- Get the Maximum number of segments
   vl_ctr := vt_seg_name.COUNT;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       NUMBER OF SEGMENTS ARE  '||TO_CHAR(VL_CTR));
 END IF;
    -- Calling Get_Segment_Values procedure
   Get_Segment_Values(vl_ctr);

EXCEPTION
  WHEN OTHERS THEN
    vp_retcode := SQLCODE;
    vp_errbuf  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf) ;
 END  Get_Application_Col_Names ;
-- ------------------------------------------------------------------
--                      Procedure Get_Segment_Values
-- ------------------------------------------------------------------
-- Get_Segment_Values procedure is called from Get_Application_Col_Names
-- procedure.
-- This procedure  builds the where clause based on the segment low
-- and high values entered in SRS window ,to be passed to the
-- Populate_CCIDs procedure to get the CCIDS.
-- ------------------------------------------------------------------

PROCEDURE Get_Segment_Values(
        seg_cnt         NUMBER)

IS
  l_module_name VARCHAR2(200);
CURSOR  seg_num_cur (p_application_column_name VARCHAR2)  IS
      SELECT segment_num
      FROM   Fnd_Id_Flex_Segments
      WHERE  application_id = vg_apps_id
      AND    id_flex_code   = vg_id_flex_code
      AND    id_flex_num    = vp_coa_id
      AND    application_column_name=p_application_column_name ;
vl_acc_seg_num   NUMBER;
vl_bal_seg_num   NUMBER  ;
-- To count the first entered range in the Felxfield window .
vl_first_seg  NUMBER:=0 ;
BEGIN
  l_module_name := g_module_name || 'Get_Segment_Values';
vg_where := '' ;

-- Get low segment values
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       CALLING POPULATE LOW SEGMETNS ' ) ;
 END IF;
        vg_nsegs_low := Fnd_Flex_Ext.breakup_segments
                                (vp_flex_low,
                                 vg_delimiter,
                                 vt_seg_low );
-- Get high segment values
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       CALLING POPULATE HIGH SEGMETNS ' ) ;
 END IF;
        vg_nsegs_high := Fnd_Flex_Ext.breakup_segments
                                (vp_flex_high,
                                 vg_delimiter,
                                 vt_seg_high );

-- Get the Balancing segment  segment number for Flexfield
OPEN   seg_num_cur(vg_bal_segment ) ;
FETCH  seg_num_cur INTO vl_bal_seg_num  ;
CLOSE seg_num_cur ;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' BALANCING SEGMENT NUMBER  IS ' ||VL_BAL_SEG_NUM ) ;
 END IF;
-- Get the Accounting segment number for Flexfield
OPEN   seg_num_cur (vg_acct_segment);
FETCH  seg_num_cur INTO vl_acc_seg_num ;
CLOSE seg_num_cur;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' ACCOUNTING SEGMENT NUMBER  IS ' ||VL_ACC_SEG_NUM ) ;
 END IF;

 -- Verify whether user has entered Fund range "Balancing segment"
 -- when process run by Accounting range
      IF vt_seg_low(vl_bal_seg_num) IS NULL THEN
         vp_retcode := 2 ;
         vp_errbuf  :='Balancing segment - Fund range is mandatory when the process is run with Summary Type as Accounting Flexfield';
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;
         RETURN ;
      END IF;
     IF vt_seg_low(vl_acc_seg_num) IS NOT NULL THEN
         vt_seg_low(i):=NULL ;
         vt_seg_high(i):=NULL ;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  USER HAS GIVEN ACCOUNT RANGE AS PARAMETERS FOR THIS PROCESS.THIS ACCOUNT RANGE WILL BE OVERRIDEN  ');
 END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  WITH ACCOUNT RANGES GIVEN IN THE REPORT DEFINITIONS SET UP FORM  ') ;
 END IF;
      END IF ;
    vg_select:= '' ;
-- Construct the concatenate segments based on the Accounting range entered
  FOR i IN 1..seg_cnt LOOP
    IF  (vt_seg_low(i) IS NOT NULL) AND
        ( i <> vl_acc_seg_num ) THEN
            IF vl_first_seg >=1 THEN
                vg_select:= vg_select||'||'||''''||vg_delimiter
                ||''''||'||'||'glcc.'||vt_seg_name(i);
            ELSE
                vg_select:= vg_select||'glcc.'||vt_seg_name(i);
                vl_first_seg:=vl_first_seg+1 ;
            END IF ;
    END IF ;
  END LOOP ;

vg_select:= vg_select||' , glcc.'||vg_acct_segment||
            ' , glcc.' ||vg_bal_segment  ;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' SELECT STATEMENT IS   ' ||VG_SELECT);
 END IF;

 -- Construct a where condition to be used to select the
 -- transactions from gl_balances and gl_bc_packets
vl_first_seg:=0 ;
FOR i IN 1..seg_cnt LOOP
    IF (vt_seg_low(i) IS NOT NULL) AND
        ( i <> vl_acc_seg_num ) THEN
         IF vl_first_seg >=1 THEN
            vg_where := vg_where ||' AND  '||'glcc.'||
            			vt_seg_name(i) ||' BETWEEN '
                        ||''''||vt_seg_low(i)||''''||'  AND  '
                        ||''''||vt_seg_high(i)||'''' ;
         ELSE
            vg_where := 'glcc.'||vt_seg_name(i) ||' BETWEEN  '
                        ||''''||vt_seg_low(i)||''''||'  AND  '
                        ||''''||vt_seg_high(i)||'''' ;
                    vl_first_seg:=vl_first_seg+1 ;
         END IF ;
    END IF ;
END LOOP;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' WHERE CLAUSE IS   ' ||VG_WHERE );
 END IF;

Populate_CCIDs(vg_select,vg_where);
EXCEPTION
  WHEN OTHERS THEN
    vp_retcode := SQLCODE;
    vp_errbuf  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf) ;
    RAISE;
END Get_Segment_Values ;

-- ------------------------------------------------------------------
--                      Procedure Treasury_Symbol_attributes
-- ------------------------------------------------------------------
-- This procedure finds the fund values attached for the TAS
-- This procedure calls the get BFY segment value procedure
-- Calls the populate_CCID'S procedure to ge the CCID's
-- ------------------------------------------------------------------

PROCEDURE Treasury_Symbol_attributes   IS
  l_module_name VARCHAR2(200);

    vl_fund VARCHAR2(30);

BEGIN
  l_module_name := g_module_name || 'Treasury_Symbol_attributes';
--  Verify IF user entered TAS paramter .
       IF vp_treasury_symbol_id IS NULL THEN
          vp_retcode := -1 ;
          vp_errbuf  := 'Treasury symbol parameter should be entered when the process is run with Summary Type as  Treasury Symbol ';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;
         RETURN ;
       END IF;

--  Verify If Fund values are exists for the Treasury Symbol user entered .
    SELECT COUNT(1) INTO vl_fund  FROM FV_FUND_PARAMETERS
    WHERE TREASURY_SYMBOL_ID = vp_treasury_symbol_id
    AND  set_of_books_id = vp_sob_id ;
    IF vl_fund=0  THEN
        vp_retcode := -1 ;
        vp_errbuf  :='There are no Funds defined for the Treasury Symbol Passed.
        			 Please define Funds for this Treasury Symbol in the Define Parameters Form' ;

        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;
        RETURN ;
    END IF;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       CALLING PROCEDURE GET_BFY_SEGMENT    ' ||VG_WHERE);
 END IF;
 Get_Bfy_Segment ;
IF vp_retcode = 0 THEN

  vg_select:= 'glcc.'||vg_bal_segment||'||'||''''||vg_delimiter||''''||'||'||
            'glcc.'||vg_bfy_segment||' , glcc.'||vg_acct_segment ;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' SELECT STATMENT WHEN PROCESS RUNS FOR TAS ' || VG_SELECT );
 END IF;

  vg_where := 'glcc.'|| vg_bal_segment || ' IN ' ||
            '(SELECT FUND_VALUE FROM FV_FUND_PARAMETERS
            WHERE TREASURY_SYMBOL_ID = '||vp_treasury_symbol_id||
            ' AND FV_FUND_PARAMETERS.set_of_books_id= '||vp_sob_id||')' ;

  Populate_CCIDs(vg_select,vg_where);
END IF ;
EXCEPTION
  WHEN OTHERS THEN
    vp_retcode := SQLCODE;
    vp_errbuf  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf) ;
    RAISE;
END   Treasury_Symbol_attributes ;

-- ------------------------------------------------------------------
--                      Procedure Get_Bfy_Segment
-- ------------------------------------------------------------------
-- Get_Bfy_Segment  procedure is called from the Main procedure If
-- the process is runds for Treasury Symbol
-- This procedure gets the fiscal year segment from the PYA Mapping table .
-- ------------------------------------------------------------------
PROCEDURE Get_Bfy_Segment  IS
  l_module_name VARCHAR2(200);
    vl_segment_id   NUMBER;

    CURSOR Bfa_segment_cur IS
    SELECT  application_column_name
    FROM    Fv_Pya_Fiscalyear_Segment
    WHERE   set_of_books_id = vp_sob_id ;

BEGIN
  l_module_name := g_module_name || 'Get_Bfy_Segment';
 OPEN  Bfa_segment_cur ;
 FETCH Bfa_segment_cur INTO vg_bfy_segment   ;
    IF Bfa_segment_cur%NOTFOUND  THEN
      vp_retcode := 2;
      vp_errbuf  := 'Budget Fiscal Year Segment not defined in PYA set up for the ledger '||to_char(vp_sob_id);
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;
      CLOSE Bfa_segment_cur ;
      RETURN ;
     END IF ;
  CLOSE Bfa_segment_cur ;

   EXCEPTION
        WHEN OTHERS THEN
            vp_retcode := SQLCODE ;
            vp_errbuf  := SQLERRM  ||
                ' -- Error in Get_Bfy_Segment_Details procedure '
                 ||' while getting the BFY Segment Name.' ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf) ;
            RETURN ;
END  Get_Bfy_Segment;

-- ------------------------------------------------------------------
--                      Procedure Populate_CCIDs
-- ------------------------------------------------------------------
-- Populate_CCIDs procedure is called from Get_Segment_Values
-- procedure.This procedure populates the temp table with
-- the concatenate segments based on the where clause passed .
-- ------------------------------------------------------------------

PROCEDURE Populate_CCIDs(   select_cl VARCHAR2,
                            where_cl  VARCHAR2)
 IS
  l_module_name VARCHAR2(200);
    -- Variable declartions for Dynamic SQL
    TYPE t_refcur IS REF CURSOR;
    vl_bal_retcur   t_refcur;
    vl_cursor_id    INTEGER;
    vl_select_stmnt VARCHAR2(4000);
    vl_ret          INTEGER;
    vl_conc_seg     VARCHAR2(2000);
    vl_acc_seg      VARCHAR2(30);
    vl_bal_seg      VARCHAR2(30);
    vl_amount       NUMBER ;
    vl_report_id    NUMBER ;
    vl_column_ID    NUMBER ;
    i               NUMBER := 1;
    vl_seed_count  NUMBER ;
    vl_Acct_count   NUMBER ;
    l_period_year NUMBER;
    l_period_num  NUMBER;


BEGIN
  l_module_name := g_module_name || 'Populate_CCIDs';

-- Check whether seed process was run

    SELECT COUNT(1) INTO vl_seed_count
    FROM  Fv_Funds_Avail_Rep_Def
    WHERE set_of_books_id = vp_sob_id
    AND Report_Id = vp_report_id ;

    IF vl_seed_count=0  THEN
        vp_retcode := -1 ;
        vp_errbuf  :=   '    Please run the Populate Funds Availabiity Report Definitions Process .'  ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;
        RETURN ;
    END IF;
-- Check whether Accounts are Defined in the form ,
-- Funds Availability Report Definitions .

    SELECT COUNT(1) INTO vl_Acct_count
    FROM    Fv_Funds_Avail_Rep_Def  fvd ,
            Fv_Funds_Avail_Acct_Ranges fvr
    WHERE   fvr.column_id=fvd.column_id
    AND     fvr.set_of_books_id = vp_sob_id
    AND     Report_Id = vp_report_id ;

    IF vl_Acct_count=0  THEN
        vp_retcode := -1 ;
        vp_errbuf  :=   '    Accounts not defined . Please define Accounts in the Funds Availiability Report
                             Definitions Form. '  ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;
        RETURN ;
    END IF;

    SELECT period_year,
           period_num
      INTO l_period_year,
           l_period_num
      FROM gl_period_statuses
     WHERE application_id = 101
       AND set_of_books_id = vp_sob_id
       AND period_name = vp_period_name;

 IF vp_report_id = 1 THEN

 -- If the process is run for the Funds Available-Total Resources
 -- If it is a Debit balance Positive ,If credit it is negative .

  vg_amount:=' SUM((nvl(glb.begin_balance_dr,0) - nvl(glb.begin_balance_cr,0))+
            (nvl(glb.period_net_dr,0) - nvl(glb.period_net_cr,0))) amount ' ;
 ELSE

-- If the Process is run for other than Funds Available-Total Resources
-- Accounts with Account Type, "Budgetary Debit", that have
-- Credit Balances will be considered as negative Otherwise,
-- the balances are positive
-- Accounts with Account Type, "Budgetary Credits", that have
-- Debit Balances will be considered as negative amounts.
-- Otherwise, the balances are positive .

  vg_amount :='SUM( DECODE(glcc.account_type , ' ||''''||'C'||''''|| ',
              ((nvl(glb.begin_balance_cr,0) - nvl(glb.begin_balance_dr,0))  +
              (nvl(glb.period_net_cr,0) -  nvl(glB.period_net_dr,0))) ,
              ((nvl(glb.begin_balance_dr,0) - nvl(glb.begin_balance_cr,0)) +
              (nvl(glb.period_net_dr,0) - nvl(glb.period_net_cr,0))))) amount ';
 END IF ;
vl_select_stmnt :=
                  'SELECT  '||select_cl||
                  ' , fvd.report_id,  '||
                  ' fvr.column_id , '||
                    vg_amount ||
                  ' FROM  Fv_Funds_Avail_Rep_Def  fvd ,
                  Fv_Funds_Avail_Acct_Ranges fvr,
                  Gl_Code_Combinations glcc , Gl_Balances  glb
                  WHERE glcc.code_combination_id =
                  glb.code_combination_id  '||
                  '  AND  fvr.column_id=fvd.column_id '||
                  '  AND  fvr.set_of_books_id = :b_vp_sob_id ' ||
                  '  AND  fvd.set_of_books_id = :b_vp_sob_id ' ||
                  '  AND  glcc.template_id IS NULL ' ||
	          '  AND ( glcc.'||vg_acct_segment ||
                  '  BETWEEN  '|| ' fvr.account_from  ' ||
                  ' AND  '|| ' fvr.account_to  OR EXISTS '||
                  ' (SELECT 1 FROM fnd_flex_value_hierarchies h '||
                  ' WHERE  glcc.'||vg_acct_segment ||'  BETWEEN'  ||
                  ' child_flex_value_low AND child_flex_value_high '||
                  ' AND  h.flex_value_set_id = :b_vg_flex_value_id' ||
                  ' AND  h.PARENT_FLEX_VALUE BETWEEN  fvr.account_from '||
                  '  AND fvr.account_to )) '||
                  '  AND glcc.chart_of_accounts_id = :b_vp_coa_id'||
                  '  AND glb.ledger_id  = :b_vp_sob_id ' ||
                  '  AND glb.currency_code = :b_vp_currency_code '||
                  '  AND glb.period_name  = :b_vp_period_name'||
                  '  AND glb.actual_flag = '||''''||'A'||'''' ||
                  '  AND glcc.enabled_flag ='||''''||'Y'||'''' ||
                  '  AND  fvd.report_id  = :b_vp_report_id'   ||
                  '   AND  '||
                   where_cl || '   GROUP BY '||
                   select_cl ||
                   ' , fvd.report_id,  '||
                   ' fvr.column_id  '      ;


 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SELECT STATEMENT TO GET DATA FROM GL BALANCES TABLE   ' ||VL_SELECT_STMNT);
 END IF;

-- Fetch the Transactions from GL balances

OPEN vl_bal_retcur FOR vl_select_stmnt USING vp_sob_id,vp_sob_id,vg_flex_value_id,
vp_coa_id,vp_sob_id,vp_currency_code,vp_period_name,vp_report_id;

IF vp_summary_type = 'A' THEN
  LOOP
        -- Fetch the rows
    FETCH vl_bal_retcur INTO  vl_conc_seg ,  vl_acc_seg ,vl_bal_seg ,
                            vl_report_id , vl_column_id , vl_amount  ;
    EXIT WHEN vl_bal_retcur%NOTFOUND ;

         Create_Transactions(vl_conc_seg,
                            vl_bal_seg ,
                            vl_report_id ,
                            vl_column_id ,
                            vl_amount  ,
                            vp_sob_id );
                            i:=i+1 ;
  END LOOP ;

ELSIF  vp_summary_type = 'T' THEN
  LOOP

      FETCH vl_bal_retcur INTO  vl_conc_seg ,  vl_acc_seg , vl_report_id ,
                                vl_column_id , vl_amount  ;
      EXIT WHEN vl_bal_retcur%NOTFOUND ;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' INSERTING INTO TEMP TABLE FROM GL GL_BALANCES  '|| I);
 END IF;

    Create_Transactions(vl_conc_seg,
                                NULL ,
                                vl_report_id ,
                                vl_column_id ,
                                vl_amount  ,
                                vp_sob_id );
                                    i:=i+1 ;
   END LOOP ;
END IF ;
CLOSE vl_bal_retcur;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       CREATED ALL THE TRANSACTIONS FROM GL BALANCES TABLE ');
 END IF;

-- Fetch Transactions from GL BC packets table .
i:=1 ;
vl_select_stmnt := ' ' ;
vg_amount := ' ' ;
IF vp_report_id = 1 THEN

 -- If the process is run for the Funds Available-Total Resources
 -- If it is a Debit balance Positive ,If credit it is negative .

   vg_amount :=    ' Sum (Nvl(accounted_dr,0) - nvl(accounted_cr,0) ) amount ' ;
 ELSE

-- If the Process is run for other than Funds Available-Total Resources
-- Accounts with Account Type, "Budgetary Debit", that have
-- Credit Balances will be considered as negative Otherwise,
-- the balances are positive
-- Accounts with Account Type, "Budgetary Credits", that have
-- Debit Balances will be considered as negative amounts.
-- Otherwise, the balances are positive .

        vg_amount := ' Sum(Decode(glcc.account_type ,' ||''''||'C'||''''|| ',
                      (Nvl(accounted_cr,0) - nvl(accounted_dr,0) ) ,
                       (Nvl(accounted_dr,0) - nvl(accounted_cr,0)))) amount ';
 END IF ;
vl_select_stmnt :=
				'SELECT  '||select_cl||
                ' , fvd.report_id,  '||
                ' fvr.column_id , '||
                vg_amount ||
                ' FROM  Fv_Funds_Avail_Rep_Def  fvd ,
                Fv_Funds_Avail_Acct_Ranges fvr,
                Gl_Code_Combinations glcc , Gl_Bc_Packets glbc
                WHERE glcc.code_combination_id =
                glbc.code_combination_id  '||
                '  AND  fvr.column_id=fvd.column_id '||
                '  AND  fvr.set_of_books_id = :b_vp_sob_id ' ||
                '  AND  fvd.set_of_books_id = :b_vp_sob_id ' ||
	        '  AND ( glcc.'||vg_acct_segment ||
                  '  BETWEEN  '|| ' fvr.account_from  ' ||
                  ' AND  '|| ' fvr.account_to  OR EXISTS '||
                  ' (SELECT 1 FROM fnd_flex_value_hierarchies h '||
                  ' WHERE  glcc.'||vg_acct_segment ||'  BETWEEN'  ||
                  ' child_flex_value_low AND child_flex_value_high '||
                  ' AND  h.flex_value_set_id = :b_vg_flex_value_id' ||
                  ' AND  h.PARENT_FLEX_VALUE BETWEEN  fvr.account_from '||
                  '  AND fvr.account_to )) '||
                '  AND glcc.chart_of_accounts_id = :b_vp_coa_id'||
                '  AND glbc.ledger_id = :b_vp_sob_id ' ||
                '  AND glbc.currency_code = :b_vp_currency_code '||
                '  AND glbc.period_year  <=  :b_vp_period_year'||
                '  AND glbc.period_num  <=  :b_vp_period_num'||
                '  AND glbc.actual_flag  =  '||''''||'A'||'''' ||
                '  AND glcc.enabled_flag ='||''''||'Y'||'''' ||
                '  AND glbc.status_code = '||''''||'A'||'''' ||
                '  AND glbc.template_id  IS NULL  '||
                '  AND  fvd.report_id  = :b_vp_report_id'  ||
                '   AND  '||
                where_cl || '   GROUP BY '||
                select_cl ||
                ' , fvd.report_id,  '||
                ' fvr.column_id  '      ;


 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SELECT STATEMENT TO GET DATA FROM GL BC PACKETS TABLE   ' ||VL_SELECT_STMNT);
 END IF;

OPEN vl_bal_retcur FOR vl_select_stmnt USING vp_sob_id,vp_sob_id,vg_flex_value_id,
vp_coa_id,vp_sob_id,vp_currency_code,l_period_year, l_period_num, vp_report_id;

IF vp_summary_type = 'A' THEN
  LOOP
        -- Fetch the rows
       FETCH vl_bal_retcur INTO  vl_conc_seg ,  vl_acc_seg ,vl_bal_seg ,
       		 vl_report_id ,vl_column_id , vl_amount  ;
       EXIT WHEN vl_bal_retcur%NOTFOUND ;

     -- Popualte Fund_value in the temp table Fv_Funds_Avail_Temp
        Create_Transactions(vl_conc_seg,
                            vl_bal_seg ,
                            vl_report_id ,
                            vl_column_id ,
                            vl_amount  ,
                            vp_sob_id );
                            i:=i+1 ;
  END LOOP ;

ELSIF  vp_summary_type = 'T' THEN
  LOOP

      FETCH vl_bal_retcur INTO  vl_conc_seg ,  vl_acc_seg , vl_report_id ,
                                vl_column_id , vl_amount  ;
      EXIT WHEN vl_bal_retcur%NOTFOUND ;
       -- Popualte Fund_value as NULL in the temp table Fv_Funds_Avail_Temp
            Create_Transactions(vl_conc_seg,
                                NULL ,
                                vl_report_id ,
                                vl_column_id ,
                                vl_amount  ,
                                vp_sob_id );
                                    i:=i+1 ;
   END LOOP ;
END IF ;
CLOSE vl_bal_retcur;
EXCEPTION
  WHEN OTHERS THEN
    vp_retcode := SQLCODE;
    vp_errbuf  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf) ;
    RAISE;

END  Populate_CCIDs ;

-- ------------------------------------------------------------------
--                      Procedure Submit_Reports
-- ------------------------------------------------------------------
-- Submit_Reports procedure is called from the Main Procedure.
-- This procedure submits the Funds Availability Reports
-- ------------------------------------------------------------------
PROCEDURE Submit_Reports  IS
  l_module_name VARCHAR2(200);

CURSOR treasury_symbol_c IS
   SELECT treasury_symbol
   FROM fv_treasury_symbols
   WHERE treasury_symbol_id = vp_treasury_symbol_id ;

vl_req_id   NUMBER;
vl_count NUMBER ;
treasury_symbol VARCHAR2(35);


BEGIN
  l_module_name := g_module_name || 'Submit_Reports';
  SELECT COUNT(*) INTO vl_count FROM
  Fv_Funds_Avail_Temp WHERE
  report_id =vp_report_id ;
  IF vl_count = 0  THEN
  	vp_retcode := 1 ;
   	IF vp_summary_type='T' THEN
		OPEN treasury_symbol_c;
		FETCH treasury_symbol_c  into treasury_symbol;
		CLOSE treasury_symbol_c;
		  vp_errbuf := 'No Data Found for treasury symbol ' || treasury_symbol ||
			  ' in the period ' || vp_period_name || '.' ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;
  	ELSE
		  vp_errbuf := 'No Data Found for accounts between ' || vp_flex_low ||
       		    ' and '|| vp_flex_high || ' in the period ' || vp_period_name || '.' ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;
	END IF;

        RETURN ;
  END IF;

--    Check if available balances for all funds equal zero
--    If so, dont kick off reports.
  SELECT COUNT(*) INTO vl_count FROM
  Fv_Funds_Avail_Temp WHERE
  report_id = vp_report_id AND
  amount <> 0;

  IF vl_count = 0 THEN
        vp_retcode := 1 ;
        IF vp_summary_type='T' THEN
                OPEN treasury_symbol_c;
                FETCH treasury_symbol_c  into treasury_symbol;
                CLOSE treasury_symbol_c;
                vp_errbuf:= 'Zero balances available for treasury symbol ' || treasury_symbol ||
                         ' in the period ' || vp_period_name || '.' ;
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;
        ELSE
                vp_errbuf := 'Zero balances available for accounts between ' || vp_flex_low ||
                   ' and ' || vp_flex_high || ' in the period ' || vp_period_name || '.' ;
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;
        END IF;
        RETURN ;
     END IF;


 vl_req_id:= Fnd_Request.Submit_Request ('FV','FVFUNAVR','','',FALSE,
    			vp_sob_id,vp_coa_id,VP_SUMMARY_TYPE,VP_REPORT_ID,
    			VP_TREASURY_SYMBOL_ID,VP_FLEX_LOW,VP_FLEX_HIGH,
    			VP_PERIOD_NAME,VP_CURRENCY_CODE,vp_units ) ;
    IF (vl_req_id = 0) THEN
      vp_retcode := 2 ;
      vp_errbuf  := 'Error in Submit_Reports procedure, while submitting Funds Available Report .' ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;

      RETURN ;
    END IF;

 EXCEPTION
   WHEN OTHERS THEN
      vp_retcode := SQLCODE ;
      vp_errbuf  := SQLERRM  ||' -- Error in Submit_Reports procedure.' ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf) ;
      RETURN ;
END Submit_Reports;

-- ------------------------------------------------------------------
--                      Procedure Create_Transactions
-- ------------------------------------------------------------------
-- Create_Transactions procedure is called from the populate_ccid procedure.
-- This procedure creates the data in the Fv_Funds_Avail_temp Table.
--
-- ------------------------------------------------------------------
PROCEDURE Create_Transactions
            (  CONCAT_SEGMENTS VARCHAR2,
                                FUND_VALUE      VARCHAR2 ,
                                REPORT_ID  NUMBER ,
                                COLUMN_ID NUMBER ,
                                AMOUNT   NUMBER ,
                                SET_OF_BOOKS_ID NUMBER

                                ) IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'Create_Transactions';

     INSERT INTO Fv_Funds_Avail_temp (CONCAT_SEGMENTS,
                                     FUND_VALUE ,
                                     REPORT_ID  ,
                                     COLUMN_ID,
                                     AMOUNT ,
                                     SET_OF_BOOKS_ID)
        VALUES  (
                    CONCAT_SEGMENTS ,
                    FUND_VALUE ,
                    REPORT_ID   ,
                    COLUMN_ID   ,
                    AMOUNT  ,
                    SET_OF_BOOKS_ID );
                    EXCEPTION
   WHEN OTHERS THEN
      vp_retcode := SQLCODE ;
      vp_errbuf  := SQLERRM  ||' -- Error in Submit_Reports procedure.' ;

      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf) ;
      RETURN ;

END ;
BEGIN
  g_module_name   := 'fv.plsql.FV_FUNDS_AVAIL_PKG.';
  vg_apps_id      := 101;
  vg_id_flex_code := 'GL#';

----------------------------------------------------------------------
--				END OF PACKAGE BODY
----------------------------------------------------------------------
END FV_FUNDS_AVAIL_PKG;

/
