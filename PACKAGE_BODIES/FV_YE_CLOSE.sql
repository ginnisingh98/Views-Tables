--------------------------------------------------------
--  DDL for Package Body FV_YE_CLOSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_YE_CLOSE" AS
--$Header: FVXYECPB.pls 120.47.12010000.13 2010/01/29 18:26:58 snama ship $
    --  ======================================================================
    --                  Variable Naming Conventions
    --  ======================================================================
    --  1. Input/Output Parameter global variables
    --     have the format                                   "vp_<Variable Name>"
    --  2. Other Global Variables have the format            "vg_<Variable_Name>"
    --  3. Procedure Level local variables have
    --     the format                                        "vl_<Variable_Name>"
    --  4. PL/SQL Table variables have                       "vt_<Variable_Name>"
    --  5. User Defined Exceptions have                      "e_<Exception_Name>"
    --  6. Variable Cursors have                             "vc_<Variable_Name>"
    --  ======================================================================
    --                          Parameter Global Variable Declarations
    --  ======================================================================

   g_module_name VARCHAR2(100) ;
    vp_errbuf           VARCHAR2(1000)                          ;
    vp_retcode          NUMBER                             ;
    vp_post_to_gl   VARCHAR2(1)                             ;
    vp_mode VARCHAR2(1)                             ;
    vp_timeframe	Fv_Treasury_Symbols.time_frame%TYPE	;
    vp_fundgroup	Fv_Treasury_Symbols.fund_group_code%TYPE;
    vp_trsymbol		Fv_Treasury_Symbols.treasury_symbol%TYPE;
    vp_closing_fyr 	Gl_Periods.period_year%TYPE		;
    --year end process
    vp_closing_num Gl_Periods.period_num%TYPE		;

    --  ======================================================================
    --                           Other Global Variable Declarations
    --  ======================================================================

    vg_sob_id		Gl_Sets_Of_Books.set_of_books_id%TYPE;
    vg_coa_id		Gl_Sets_Of_Books.chart_of_accounts_id%TYPE;
    vg_currency		Gl_Sets_Of_Books.currency_code%TYPE;
    vg_start_date       Gl_Periods.start_date%TYPE;
    vg_end_date         Gl_Periods.end_date%TYPE;
    vg_closing_period 	Gl_Period_Statuses.period_name%TYPE;
    vg_coy_fyr	 	Gl_Periods.period_year%TYPE;
    vg_coy_start_date   Gl_Periods.start_date%TYPE;
    vg_coy_period 	Gl_Period_Statuses.period_name%TYPE;
    vg_bal_segment      Fnd_Id_Flex_Segments.application_column_name%TYPE;
    vg_acct_segment     Fnd_Id_Flex_Segments.application_column_name%TYPE;
    vg_acct_segnum 	NUMBER(4);
    vg_bal_seg_val_opt_code gl_ledgers_public_v.bal_seg_value_option_code%TYPE;
    vg_trsymbol         Fv_Treasury_Symbols.treasury_symbol%TYPE;
    vg_trsymbol_id      Fv_Treasury_Symbols.treasury_symbol_id%TYPE;
    vg_fund_value	Fv_Fund_Parameters.fund_value%TYPE;
    vg_group_id         Fv_Ye_Groups.group_id%TYPE;
    vg_seq_id           Fv_Ye_Group_Sequences.sequence_id%TYPE;
    vg_seq              Fv_Ye_Group_Sequences.SEQUENCE%TYPE;
    vp_closing_method 	Fv_Ye_Groups.closing_method%TYPE		;
    vg_acct_flag        Fv_Ye_Sequence_Accounts.account_flag%TYPE;
    vg_from_acct        Fv_Ye_Sequence_Accounts.from_account%TYPE;
    vg_child_acct       Fv_Ye_Sequence_Accounts.from_account%TYPE;
    vg_to_acct          Fv_Ye_Sequence_Accounts.to_account%TYPE;
     vg_requisition     Fv_Ye_Sequence_Accounts.requisition%TYPE;
     vg_closing_method  fv_ye_groups.closing_method%TYPE;
     treasury_closing_method fv_treasury_symbols.close_requisitions%TYPE;
    vg_balance_read_flag  Fv_Ye_Seq_Bal_Temp.balance_read_flag%TYPE;
    vg_bal_seq_amt 	NUMBER;
    vg_gl_bal_amt 	NUMBER;
    vg_coy_dr 		NUMBER;
    vg_coy_cr 		NUMBER;
    vt_segments		Fnd_Flex_Ext.SegmentArray;
    vg_jrnl_group_id	NUMBER;
    vg_interface_run_id	NUMBER;

    e_error      	EXCEPTION;
    e_invalid      	EXCEPTION;

    vg_fundgroup	Fv_Treasury_Symbols.fund_group_code%TYPE;
    vg_acct_val_set_id  Fnd_Flex_Values.flex_value_set_id%TYPE;
    vg_num_segs		NUMBER;
    vg_factsi_attr_exists VARCHAR2(1) ;
    vg_factsi_bal_cnt   NUMBER;
    vg_factsi_attribute Fv_System_Parameters.factsi_journal_attribute%TYPE;

    vg_public_law_attribute    fv_system_parameters.factsii_pub_law_code_attribute%TYPE;
    vg_advance_type_attribute  fv_system_parameters.factsii_advance_type_attribute%TYPE;
    vg_trf_dept_id_attribute   fv_system_parameters.factsii_tr_dept_id_attribute%TYPE;
    vg_trf_main_acct_attribute fv_system_parameters.factsii_tr_main_acct_attribute%TYPE;

    vg_facts_attributes_setup  BOOLEAN ;

    vg_closing_period_num      Gl_Period_Statuses.period_num%TYPE;
---------------------------------------------------------------------------------
----------------------------------------------------------------
  PROCEDURE insert_gl_interface_record(l_amount_dr IN NUMBER,
                                       l_amount_cr IN NUMBER,
                                       l_reference_1 IN VARCHAR2,
                                       l_period_name IN VARCHAR2,
                                       l_trading_partner IN VARCHAR2,
				       l_public_law_code IN VARCHAR2 DEFAULT NULL,
				       l_advance_type    IN VARCHAR2 DEFAULT NULL,
				       l_trf_dept_id     IN VARCHAR2 DEFAULT NULL,
				       l_trf_main_acct   IN VARCHAR2 DEFAULT NULL);

-- ------------------------------------------------------------------
--                      Procedure Main
-- ------------------------------------------------------------------
-- Main procedure that is called from the Year End Closing Process
-- request set. This procedure calls all the subsequent procedures in
-- the Year End Closing process.
-- ------------------------------------------------------------------
PROCEDURE Main( errbuf                 OUT NOCOPY VARCHAR2,
    retcode                            OUT NOCOPY NUMBER,
    ledger_id			                     NUMBER,
    closing_method                     VARCHAR2,
    time_frame                         VARCHAR2,
    fund_group                         VARCHAR2,
    treasury_symbol                    VARCHAR2,
    closing_fyr                        NUMBER,
    closing_period                     VARCHAR2,
    mode_value                         VARCHAR2,
    post_gl_enable                     VARCHAR2,
    post_to_gl                     VARCHAR2) is
    l_module_name                      VARCHAR2(200) ;
BEGIN
 l_module_name   :=  g_module_name || 'Main ';

 vg_sob_id := LEDGER_ID;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'START YEAR END CLOSING PROCESS.....');
 END IF;

   -- Assign initial values
   vp_retcode := 0;
   vp_errbuf  := NULL;

   -- Load the parameter global variables
   vp_timeframe   	 := time_frame;
   vp_fundgroup   	 := fund_group;
   vp_trsymbol   	   := treasury_symbol;
   vp_closing_fyr    := closing_fyr;
   vp_post_to_gl     := post_to_gl;
   vp_mode           := mode_value;
   vp_closing_method := closing_method;
   vg_closing_period  := closing_period;

     select period_num   into vp_closing_num
      from gl_period_statuses
      where application_id = 101
      and set_of_books_id =  vg_sob_id
      and period_name = closing_period
      and period_year = closing_fyr;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE PARAMETERS PASSED TO THE YEAR END CLOSING PROCESS ARE: '||
  		'Post to GL = '||vp_post_to_gl);
   END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CLOSING METHOD = ' ||vp_closing_method ||'TIME FRAME = '||VP_TIMEFRAME||
   		', Fund Group = '||vp_fundgroup);
   END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TREASURY SYMBOL = '||VP_TRSYMBOL||
   		', Closing Fiscal Year = '||TO_CHAR(vp_closing_fyr));
   END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TREASURY SYMBOL = '||VP_TRSYMBOL||
   		', Closing Period Number = '||TO_CHAR(vp_closing_num));
   END IF;

   -- Get the Sob, Coa and Currency Code
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'GETTING THE SET OF BOOKS,CHART OF ACCOUNTS AND CURRENCY CODE');
 END IF;
   Get_Required_Parameters;

   IF (vp_retcode = 0) THEN
      -- Get the Start Date, End Date and Last Period for the Closing Fyr
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'GETTING THE START DATE, END DATE AND LAST PERIOD '||
				'of the Closing Fiscal Year');
                 END IF;
      Get_Closing_Fyr_Details;
   END IF;

   IF (vp_retcode = 0) THEN
      -- Check if Dynamic Insertion is on
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CHECKING IF DYNAMIC INSERTION IS ON.');
 END IF;
      Chk_Dynamic_Insertion;
   END IF;

   IF (vp_retcode = 0) THEN
      -- Get the balancing and the natural account segments
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'GETTING THE BALANCING AND THE NATURAL ACCOUNT SEGMENTS.');
 END IF;
      Get_Balance_Account_Segments;
   END IF;

   IF (vp_retcode = 0) THEN
      -- Check if there are any parent account values for the To Account
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CHECKING THE TO ACCOUNT VALUES IN THE SETUP FORM.....');
 END IF;
      Chk_To_Accounts;
   END IF;

   IF (vp_retcode = 0) THEN
      -- Purging the Fv_Ye_Seq_Bal_Temp Table
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PURGING THE FV_YE_SEQ_BAL_TEMP TABLE.');
 END IF;
      Purge_Bal_Temp_Table;
   END IF;

   IF (vp_retcode = 0) THEN
      -- Checking for the Year End Parameters
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CHECKING FOR THE YEAR END PARAMETERS.');
 END IF;
      Check_Year_End_Parameters;
   END IF;

   IF (vp_retcode = 0) THEN
      -- Checking for the data in GL
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CHECKING FOR THE DATA IN General Ledger.');
 END IF;
      Check_Gl_Data;
   END IF;

    IF (vp_retcode = 0) THEN
        if (vp_mode='F' ) then
          -- Populating the GL_Interface table when MODE is F
          -- Process D
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'POPULATING THE GL_INTERFACE TABLE .');
            END IF;
            Populate_Gl_Interface;
        END IF;
    END IF;

   IF (vp_retcode = 0) THEN
    -- Submitting the Execution Report
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SUBMITTING THE EXECUTION REPORT.');
       END IF;
      Submit_Report;
   END IF;

   IF vp_retcode <> 0 THEN
        -- Check for errors
        errbuf := vp_errbuf;
        retcode := vp_retcode;
        ROLLBACK;
    ELSE
      -- If public law code and other attributes are not set up
      -- on the system parameters form, end with a warning.
      IF NOT vg_facts_attributes_setup
         THEN
           retcode := 1;
           errbuf := 'Year End Closing Process completed with warning because the Public Law, Advance,
                      AND Transfer attribute COLUMNS are NOT established ON Define SYSTEM Parameters FORM.';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'Year End Closing Process completed with warning because the Public Law, Advance,
                      AND Transfer attribute COLUMNS are NOT established ON Define SYSTEM Parameters FORM.');
        ELSE
	   retcode := 0;
	   errbuf  := '** Year End Closing Process completed successfully **';
      END IF;
      COMMIT;
   END IF;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ENDING THE YEAR END CLOSING PROCESS ......');
 END IF;

EXCEPTION
   WHEN OTHERS THEN
	ROLLBACK;
        errbuf := '** Year End Closing Process Failed ** '||SQLERRM;
        retcode := 2;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || errbuf );
        END IF;

END Main;

-- ------------------------------------------------------------------
--                      Procedure Get_Required_Parameters
-- ------------------------------------------------------------------
-- Get_Required_Parameters procedure is called from Main procedure.
-- It gets the sob, coa and the currency code. It also checks for
-- the FACTSI Journal Trading Partner attribute for FACTS I processing.
-- ------------------------------------------------------------------
PROCEDURE Get_Required_Parameters IS
  l_module_name         VARCHAR2(200) ;
BEGIN
    l_module_name  :=  g_module_name ||
                      ' Get_Required_Parameters';

   -- Get the Sob
/*   vg_sob_id := TO_NUMBER(Fnd_Profile.Value('GL_SET_OF_BKS_ID'));
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   SET OF BOOKS ID = '||TO_CHAR(VG_SOB_ID));
   END IF;

   -- Get the Coa
   vg_coa_id :=  Sys_Context('FV_CONTEXT','CHART_OF_ACCOUNTS_ID');
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   CHART OF ACCOUNTS ID = '||TO_CHAR(VG_COA_ID));
   END IF;

   -- Get the Currency code
   BEGIN
        SELECT currency_code
        INTO vg_currency
        FROM gl_sets_of_books
        WHERE set_of_books_id = vg_sob_id;

   	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   CURRENCY CODE = '||VG_CURRENCY);
   	END IF;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            vp_errbuf := 'Error in Get_Required_Parameters:'||
	                ' Currency Code is not defined';
            vp_retcode := 1;
            RETURN;
   END;
*/
-- Get if  bal seg value option is enabled  for the ledger
--  BSV's are not always assigned to ledgers. Therefore we should not
--  enforce BSV assignemnt if there is no BSV flex value set
--  is assigned to a ledger.
-- Get the COA AND  Currency code
   BEGIN
        SELECT currency_code ,
                chart_of_accounts_id ,
                BAL_SEG_VALUE_OPTION_CODE
        INTO vg_currency ,
                vg_coa_id,
                vg_bal_seg_val_opt_code
        FROM     gl_ledgers_public_v
      WHERE ledger_id = vg_sob_id;


        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                         l_module_name,
                '   CHART OF ACCOUNTS ID = '||TO_CHAR(VG_COA_ID));
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                 l_module_name,
                '   CURRENCY CODE = '||VG_CURRENCY);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                 l_module_name,
                '   BALANCE SEGMENT OPTION CODE = '|| vg_bal_seg_val_opt_code);
        END IF;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            vp_errbuf := 'Error in Get_Required_Parameters:'||
                        ' Currency Code and Chart of Accounts are not defined';
            vp_retcode := 1;
            RETURN;
  END;



   BEGIN
        SELECT factsi_journal_attribute,
               factsii_pub_law_code_attribute,
	       factsii_advance_type_attribute,
               factsii_tr_dept_id_attribute,
	       factsii_tr_main_acct_attribute
        INTO   vg_factsi_attribute,
               vg_public_law_attribute,
               vg_advance_type_attribute,
               vg_trf_dept_id_attribute,
               vg_trf_main_acct_attribute
        FROM   Fv_System_Parameters;

        IF (vg_factsi_attribute IS NULL) THEN
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   BALANCES WILL NOT BE CLOSED BY '||

                        'the FACTS I F/N and trading partner attributes since the '||
                        'FACTS I Journal Trading Partner field is not populated in '||
                        'the Define Federal System Parameters window.');
                         END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   TO CLOSE BY FACTS I F/N AND '||
                         'trading partner attributes, delete the journal entries '||
                        'created by this process, if any, enter the attribute in '||
                        'the FACTS I Journal Trading Partner field of the Define '||
                        'Federal System Parameters window, and rerun the Year End '||
                        'Close Program.');
                        END IF;
	     vg_factsi_attr_exists := 'N';
        ELSE
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   FACTS I JOURNAL TRADING PARTNER ATTRIBUTE IS '||

					vg_factsi_attribute);
                 END IF;
	     vg_factsi_attr_exists := 'Y';
        END IF;

        -- Set the global variable to false if public law code and other parameters
        -- are not setup in the define system parameters form.
        IF (vg_public_law_attribute IS NULL OR
            vg_advance_type_attribute IS NULL OR
            vg_trf_dept_id_attribute IS NULL OR
            vg_trf_main_acct_attribute IS NULL)
          THEN
            vg_facts_attributes_setup := FALSE;
         ELSE
            vg_facts_attributes_setup := TRUE;
        END IF;

   EXCEPTION
        WHEN OTHERS THEN
            vp_errbuf := 'Error in Get_Required_Parameters:'||
	                ' While determining the FACTS I Journal Attribute.';
            vp_retcode := 2;
   END;

EXCEPTION
     WHEN OTHERS THEN
            vp_retcode := 2 ;
            vp_errbuf  := SQLERRM||' -- Error in Get_Required_Parameters procedure.' ;
            IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
            END IF;
            RETURN ;
END Get_Required_Parameters;


-- ------------------------------------------------------------------
--                      Procedure Get_Closing_Fyr_Details
-- ------------------------------------------------------------------
-- Get_Closing_Fyr_Details procedure is called from Main procedure.
-- It gets the start_date,end_date,last_period of the closing fyr.
-- It also checks to see if there are any records for the last period
-- of the closing year in Fv_Facts1_Period_Balances_v for
-- FACTS I processing.
-- ------------------------------------------------------------------
PROCEDURE Get_Closing_Fyr_Details IS
 l_module_name         VARCHAR2(200) ;

BEGIN
   l_module_name   :=  g_module_name ||
                      ' Get_Closing_Fyr_Details';

   -- Get the Start Date and the End Date of the Closing fiscal year for the chosen closing period
   BEGIN
	SELECT MIN(start_date), MAX(end_date)
	INTO vg_start_date, vg_end_date
	FROM gl_periods glp, gl_sets_of_books gsob
	WHERE glp.period_year = vp_closing_fyr
	AND glp.period_set_name = gsob.period_set_name
	AND gsob.chart_of_accounts_id = vg_coa_id
	AND gsob.set_of_books_id = vg_sob_id
  and glp.period_num = vp_closing_num;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   START DATE OF THE CLOSING FISCAL YEAR = '
				||TO_CHAR(vg_start_date));
	END IF;
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   END DATE OF THE CLOSING FISCAL YEAR = '
				||TO_CHAR(vg_end_date));
	END IF;
  vg_closing_period_num := vp_closing_num;

   EXCEPTION
	WHEN OTHERS THEN
            vp_retcode := 2 ;
            vp_errbuf  := SQLERRM  ||' -- Error in Get_Closing_Fyr_Details '||
		'procedure,while getting the start/end date of closing fiscal year.';
            RETURN ;
   END;

  BEGIN

        SELECT COUNT(*)
        INTO vg_factsi_bal_cnt
        FROM Fv_Facts1_Run
        WHERE period_num = vg_closing_period_num
	AND set_of_books_id = vg_sob_id
	AND fiscal_year = vp_closing_fyr
  and period_num = vp_closing_num;

        IF (vg_factsi_bal_cnt = 0) THEN
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   BALANCES WILL NOT BE CLOSED BY '||
                        'the FACTS I F/N and trading partner attributes since there '||
                        'are no balances in Fv_Facts1_Run table for '||
                        'the period '||vg_closing_period);
                         END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   TO CLOSE BY FACTS I F/N AND '||
                        'trading partner attributes, delete the journal entries '||
                        'created by this process, if any, run the FACTS I Interface '||
                        'program with all edit checks passed by period '||
                        vg_closing_period||' and rerun the Year End Close Program.');
                         END IF;
        ELSE
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   BALANCES MAY EXIST FOR FACTS I '||
                        'for the period '||vg_closing_period);
                         END IF;
        END IF;
   EXCEPTION
        WHEN OTHERS THEN
            vp_errbuf := 'Error in Get_Closing_Fyr_Details:'||
                        ' While determining whether balances exist for FACTS I. ';
            vp_retcode := 2;
   END;
EXCEPTION
     WHEN OTHERS THEN
        vp_errbuf := SQLERRM;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;
        RAISE;

END Get_Closing_Fyr_Details;


-- ------------------------------------------------------------------
--                      Procedure Chk_Dynamic_Insertion
-- ------------------------------------------------------------------
-- Chk_Dynamic_Insertion procedure is called from Main procedure.
-- It checks if dynamic insertion is turned on.
-- ------------------------------------------------------------------
PROCEDURE Chk_Dynamic_Insertion IS
        l_module_name         VARCHAR2(200)  ;
        e_nodynamic_insert  EXCEPTION;
        vl_dyn_ins_flag  Fnd_Id_Flexs.dynamic_inserts_feasible_flag%TYPE;
BEGIN
    l_module_name :=  g_module_name
                           || ' Chk_Dynamic_Insertion';

  SELECT dynamic_inserts_feasible_flag
  INTO vl_dyn_ins_flag
  FROM Fnd_Id_Flexs
  WHERE application_id = 101
  AND  id_flex_code    = 'GL#';

  IF (vl_dyn_ins_flag = 'N') THEN
   RAISE e_nodynamic_insert;
  END IF;

EXCEPTION
        WHEN e_nodynamic_insert THEN
          vp_retcode := 1;
          vp_errbuf  := 'Error in Chk_Dynamic_Insertion:Dynamic Inserts '||
		'Feasible Flag is not set to Yes.';
          RETURN;
        WHEN OTHERS THEN
          vp_retcode := 2;
          vp_errbuf  := SQLERRM ||' -- Error in Chk_Dyanmic_Insertionprocedure.';
          IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
          END IF;
          RETURN;
END Chk_Dynamic_Insertion;

-- ------------------------------------------------------------------
--                      Procedure Get_Balance_Account_Segments
-- ------------------------------------------------------------------
-- Get_Balance_Account_Segments procedure is called from Main procedure.
-- It gets the balancing and natural account segments, and the
-- natural accounting segment number.
-- ------------------------------------------------------------------
PROCEDURE Get_Balance_Account_Segments IS
vl_errcode BOOLEAN;
           l_module_name         VARCHAR2(200)  ;
CURSOR flex_fields IS
  SELECT application_column_name
  FROM   fnd_id_flex_segments
  WHERE  id_flex_code = 'GL#'
  AND    id_flex_num = vg_coa_id
  ORDER BY segment_num;

l_n_segments   NUMBER(4) := 0;
vl_acct_segnum number(4);
l_column_name  fnd_id_flex_segments.application_column_name%TYPE;
BEGIN

       l_module_name :=  g_module_name ||
                                        'Get_Balance_Account_Segments ';
  fv_utility.get_segment_col_names
  (
    chart_of_accounts_id	=> vg_coa_id,
		acct_seg_name		      => vg_acct_segment,
		balance_seg_name	    => vg_bal_segment,
		error_code		        => vl_errcode,
		error_message		      => vp_errbuf
  );

  IF (vl_errcode) THEN
    vp_retcode := 2 ;
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
    'Call fv_utility.get_segment_col_names' || vp_errbuf );
    END IF;
    RETURN;
  END IF;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   BALANCING SEGMENT IS '||VG_BAL_SEGMENT);
 END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   NATURAL ACCOUNTING SEGMENT IS '||VG_ACCT_SEGMENT);
 END IF;

     -- Get the Account segment number
     FOR flex_fields_rec IN flex_fields
     LOOP

       l_n_segments := l_n_segments + 1;
       l_column_name := flex_fields_rec.application_column_name;

       --Get the natural account segment column position in array
       IF (l_column_name = vg_acct_segment) THEN
          vl_acct_segnum := l_n_segments;
       END IF;
     END LOOP;

     vg_acct_segnum := vl_acct_segnum;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   NATURAL ACCOUNTING SEGMENT NUMBER IS '	||TO_CHAR(vg_acct_segnum));
   END IF;

   -- Get the Account Flex Value set ID
   BEGIN
	SELECT flex_value_set_id
	INTO vg_acct_val_set_id
	FROM Fnd_Id_Flex_Segments
	WHERE application_column_name = vg_acct_segment
	AND application_id = 101
	AND id_flex_code = 'GL#'
	AND id_flex_num = vg_coa_id
	AND enabled_flag = 'Y';
   EXCEPTION
	WHEN OTHERS THEN
null;
     --       vp_retcode := 2 ;
     --       vp_errbuf  := SQLERRM  ||' -- Error in Get_Balance_Account_Segments '||
     --		'procedure,while getting the Account Flex Value Set Id .';
            RETURN ;

   END;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   ACCOUNT FLEX VALUE SET ID IS '	||TO_CHAR(vg_acct_val_set_id));
   END IF;

   -- Get the Number of segments in the chart of accounts
   BEGIN
	SELECT COUNT(*)
	INTO vg_num_segs
	FROM Fnd_Id_Flex_Segments
	WHERE application_id = 101
	AND id_flex_code = 'GL#'
	AND id_flex_num = vg_coa_id
	AND enabled_flag = 'Y';
   EXCEPTION
	WHEN OTHERS THEN
            vp_retcode := 2 ;
            vp_errbuf  := SQLERRM  ||' -- Error in Get_Balance_Account_Segments '||
		'procedure,while getting the number of segments .';
            RETURN ;
   END;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   NUMBER OF SEGMENTS ARE '  ||TO_CHAR(vg_num_segs));
   END IF;
EXCEPTION
     WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Get_Balance_Account_Segments
		PROCEDURE.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;

        RETURN ;
END Get_Balance_Account_Segments;

-- ------------------------------------------------------------------
--                      Procedure Chk_To_Accounts
-- ------------------------------------------------------------------
-- Chk_To_Accounts procedure is called from Main procedure.
-- It checks if any of the To accounts are parent accounts.
-- ------------------------------------------------------------------
PROCEDURE Chk_To_Accounts IS
   CURSOR get_toaccts_cur IS
	SELECT DISTINCT to_account
	FROM Fv_Ye_Sequence_Accounts
	WHERE set_of_books_id = vg_sob_id
	ORDER BY to_account;

   vl_parent_flag VARCHAR2(1) ;
   vl_acct Fnd_Flex_Values_Vl.flex_value%TYPE;

   CURSOR get_parentflag_cur IS
	SELECT summary_flag
	FROM Fnd_Flex_Values_Vl
	WHERE flex_value_set_id = vg_acct_val_set_id
	AND flex_value = vl_acct;

  l_module_name         VARCHAR2(200)  ;


BEGIN

  l_module_name   :=  g_module_name || ' Chk_To_Accounts ';
  vl_parent_flag  := 'N';


 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   IN CHK_TO_ACCOUNTS PROCEDURE');
 END IF;

   FOR vc_getaccts IN get_toaccts_cur LOOP
	vl_acct := vc_getaccts.to_account;

	FOR vc_getparent IN get_parentflag_cur LOOP
	   IF (vc_getparent.summary_flag = 'Y') THEN
		vp_retcode := 2;
		vp_errbuf := 'Parent accounts have been defined for the '||
		    'To Account on the Year End Closing Setup form. Please '||
		    'define only child accounts for the To Account.';
		RETURN;
	   END IF;
	END LOOP;
   END LOOP;
EXCEPTION
     WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Chk_To_Accounts procedure.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;
        RETURN ;
END Chk_To_Accounts;

-- ------------------------------------------------------------------
--                      Procedure Purge_Bal_Temp_Table
-- ------------------------------------------------------------------
-- Purge_Bal_Temp_Table procedure is called from Main procedure.
-- It deletes from the Temp table.
-- ------------------------------------------------------------------
PROCEDURE Purge_Bal_Temp_Table IS
             l_module_name      VARCHAR2(200)  ;
BEGIN

     l_module_name  :=  g_module_name ||'Purge_Bal_Temp_Table ';

     DELETE FROM Fv_Ye_Seq_Bal_Temp WHERE set_of_books_id = vg_sob_id;

     COMMIT;
EXCEPTION
     WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Purge_Bal_Temp_Table procedure.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;

        RETURN ;
END Purge_Bal_Temp_Table;

-- ------------------------------------------------------------------
--                      Procedure Check_Gl_Data
-- ------------------------------------------------------------------
-- Check_Gl_Data procedure is called from Main procedure.
-- It checks if there are any records in the Temp table.
-- ------------------------------------------------------------------
PROCEDURE Check_Gl_Data IS
   vl_reccnt NUMBER;
   l_module_name   VARCHAR2(200) ;
   e_no_gldata EXCEPTION;

BEGIN

    l_module_name  :=  g_module_name || 'Check_Gl_Data';


     SELECT COUNT(*)
     INTO vl_reccnt
     FROM Fv_Ye_Seq_Bal_Temp
     WHERE set_of_books_id = vg_sob_id;

     IF (vl_reccnt = 0) THEN
	RAISE e_no_gldata;
     END IF;
EXCEPTION
     WHEN e_no_gldata THEN
	vp_retcode := 1;
        vp_errbuf := 'Year End Closing Process has successfully completed,'||
		' but there was no data found in General Ledger, for the Year '||
		'End account definitions. Journal Import has not been submitted.';

     WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Check_Gl_Date procedure.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;
        RETURN ;
END Check_Gl_Data;

-- ------------------------------------------------------------------
--                      Procedure Check_Year_End_Parameters
-- ------------------------------------------------------------------
-- Check_Year_End_Parameters procedure is called from Main procedure.
-- It checks what are the input parameters passed to the Year End
-- Process, specifically whether Trsymbol, timeframe and fundgroup
-- are provided as input parameters.Based on the parameters provided
-- it derives the others and then calls Get_Year_End_Record procedure.
-- ------------------------------------------------------------------
PROCEDURE Check_Year_End_Parameters
        IS
   TYPE t_checkpara IS REF CURSOR;
   vc_checkpara t_checkpara;

   vl_trsymbol	Fv_Treasury_Symbols.treasury_symbol%TYPE;
   vl_timeframe	Fv_Treasury_Symbols.time_frame%TYPE	;
   vl_fundgroup	Fv_Treasury_Symbols.fund_group_code%TYPE;
   vl_exp_date	Fv_Treasury_Symbols.expiration_date%TYPE;
   vl_can_date	Fv_Treasury_Symbols.cancellation_date%TYPE;
   vl_rec_found_flag  VARCHAR2(1) ;
   vl_fundgroup_temp	Fv_Treasury_Symbols.fund_group_code%TYPE;
   l_module_name         VARCHAR2(200)  ;

BEGIN

   l_module_name    :=  g_module_name ||  'Check_Year_End_Parameters  ';
    vl_rec_found_flag := 'N';



   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   IN CHECK_YEAR_END_PARAMETERS PROCEDURE '||
	'with the following Parameters passed to the process:');
   END IF;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' CLOSING_METHOD = '|| vp_closing_method ||' TREASURY SYMBOL = '||VP_TRSYMBOL||
			', Fund Group Code = '||vp_fundgroup||
   			', Time Frame = '||vp_timeframe);
   END IF;

-- check if all fund_values are valid for the General Ledger

Check_bal_seg_value( vp_fundgroup,
                     vp_timeframe,
                     vp_trsymbol   ,
                     vg_sob_id,
                     vg_end_date ) ;


   IF (vp_trsymbol IS NOT NULL ) THEN
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   CASE1: WHEN TREASURY SYMBOL PARAMETER IS PROVIDED.');
	END IF;

	OPEN vc_checkpara FOR
	    'SELECT time_frame,fund_group_code,
		   expiration_date,cancellation_date
	    FROM Fv_Treasury_Symbols
	    WHERE treasury_symbol = :trsymbol
	    AND set_of_books_id   = :sob'
	USING vp_trsymbol,vg_sob_id;

	FETCH vc_checkpara INTO vl_timeframe, vl_fundgroup,
		vl_exp_date, vl_can_date;

	IF ((vl_exp_date > vg_end_date) AND (vl_can_date > vg_end_date)
	  AND (vl_timeframe NOT IN ('MULTIPLE','NO_YEAR'))) THEN
        	vp_retcode := 1 ;
        	vp_errbuf  := 'The Treasury Symbol '||vp_trsymbol
			||' is neither Expired nor Cancelled nor a Multi-Year'||
			' or a No-Year Symbol.';
		vp_errbuf := vp_errbuf || ' Year End Processing is not '||
			'done for this Treasury Symbol. ';

		IF vc_checkpara%ISOPEN THEN
		   CLOSE vc_checkpara;
		END IF;
        	RETURN ;
	ELSE
		-- Process A
		Get_Year_End_Record(vp_trsymbol,vl_fundgroup,vl_timeframe);
		IF (vp_retcode <> 0) THEN
		   RAISE e_error;
		END IF;
	END IF;

	CLOSE vc_checkpara;

   ELSIF (vp_fundgroup IS NOT NULL) THEN  -- vp_trsymbol
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   CASE2: WHEN FUND GROUP CODE PARAMETER IS PROVIDED.');
	END IF;

        -- IF timeframe is one year, then only the treasury symbols which are
 	-- either expired or cancelled are selected for processsing. For multi-year
	-- and no-year timeframes, the unexpired treasury symbols also need to be
	-- processed. Bug 2527452.
	IF (vp_timeframe = 'SINGLE') THEN   	-- timeframe 1
		OPEN vc_checkpara FOR
		   'SELECT treasury_symbol
		    FROM Fv_Treasury_symbols
		    WHERE set_of_books_id = :sob
		    AND time_frame = :timeframe
		    AND fund_group_code = :fundgroup
		    AND ((expiration_date <= :end_date)
				OR (cancellation_date <= :end_date))
    		    ORDER BY treasury_symbol'
		USING vg_sob_id,
                      vp_timeframe,
                      vp_fundgroup,
                      vg_end_date,
                      vg_end_date;

  ELSIF vp_timeframe='ALL' THEN
    OPEN vc_checkpara FOR
		   'SELECT treasury_symbol,fund_group_code
		    FROM Fv_Treasury_symbols
		    WHERE set_of_books_id = :sob_id
		    AND ORDER BY treasury_symbol'
		USING vg_sob_id;

	ELSE					-- timeframe 1
		OPEN vc_checkpara FOR
		   'SELECT treasury_symbol
		    FROM Fv_Treasury_symbols
		    WHERE set_of_books_id = :sob_id
		    AND time_frame = :timeframe
		    AND fund_group_code = :fundgroup
    		    ORDER BY treasury_symbol'
		USING vg_sob_id,vp_timeframe,vp_fundgroup;
	END IF;					-- timeframe 1
   ELSE  -- vp_trsymbol
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   CASE3: WHEN ONLY THE TIME FRAME PARAMETER IS PROVIDED.');
	END IF;

        -- IF timeframe is one year, then only the treasury symbols which are
 	-- either expired or cancelled are selected for processsing. For multi-year
	-- and no-year timeframes, the unexpired treasury symbols also need to be
	-- processed. Bug 2527452.
	IF (vp_timeframe = 'SINGLE') THEN   	-- timeframe 2
		OPEN vc_checkpara FOR
		   'SELECT treasury_symbol,fund_group_code
		    FROM Fv_Treasury_symbols
		    WHERE set_of_books_id = :sob_id
		    AND time_frame = :timeframe
		    AND ((expiration_date <= :end_date)
			OR (cancellation_date <= :end_date))
    		    ORDER BY treasury_symbol'
		USING vg_sob_id,vp_timeframe,vg_end_date,vg_end_date;
  ELSIF vp_timeframe='ALL' THEN

    OPEN vc_checkpara FOR
		   'SELECT treasury_symbol,fund_group_code, time_frame
		    FROM Fv_Treasury_symbols
		    WHERE set_of_books_id = :sob_id
		    ORDER BY treasury_symbol'
		USING vg_sob_id;
	ELSE					-- timeframe 2
		OPEN vc_checkpara FOR
		   'SELECT treasury_symbol,fund_group_code
		    FROM Fv_Treasury_symbols
		    WHERE set_of_books_id = :sob_id
		    AND time_frame = :timeframe
    		    ORDER BY treasury_symbol'
		USING vg_sob_id,vp_timeframe;
	END IF;					-- timeframe 2

   END IF; -- vp_trsymbol


   IF (vp_trsymbol IS NULL) THEN  -- vp_trsymbol NULL
	LOOP
     vl_timeframe := vp_timeframe;
	   IF (vp_fundgroup IS NOT NULL) THEN
	   	FETCH vc_checkpara INTO vl_trsymbol;
	   ELSIF vp_timeframe='ALL' THEN
      FETCH vc_checkpara INTO vl_trsymbol, vl_fundgroup, vl_timeframe;
     ELSE
      FETCH vc_checkpara INTO vl_trsymbol, vl_fundgroup;
	   END IF;


	   IF vc_checkpara%FOUND THEN
		vl_rec_found_flag := 'Y';

		IF (vp_fundgroup IS NULL) THEN
		    vl_fundgroup_temp := vl_fundgroup;
		ELSE
		    vl_fundgroup_temp := vp_fundgroup;
		END IF;

		-- Process A
		Get_Year_End_Record(vl_trsymbol,vl_fundgroup_temp,vl_timeframe);

		IF (vp_retcode <> 0) THEN
		   RAISE e_error;
		END IF;
	   ELSE
		IF (vl_rec_found_flag = 'N') THEN
		    vp_retcode := 1;
		    IF (vp_fundgroup IS NOT NULL) THEN
		       vp_errbuf  := 'No Treasury Symbols found for '||
			    'the given Appropriation Group '||vp_fundgroup||
			    ' and the given Appropriation Time Frame '||vp_timeframe;
		    ELSE
		       vp_errbuf  := 'No Treasury Symbols found for the '||
				'given Appropriation Time Frame '||vp_timeframe;
		    END IF;
		    RETURN;
		ELSE
		    EXIT;
		END IF; -- vl_rec_found_flag
	   END IF; -- vc_checkpara
	END LOOP;

	CLOSE vc_checkpara;

   END IF;  -- vp_trsymbol NULL

EXCEPTION
   WHEN e_error THEN
        IF vc_checkpara%ISOPEN THEN
	      CLOSE vc_checkpara;
        END IF;
	RETURN;

   WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Check_Year_End_Parameters procedure.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;

        RETURN ;
END Check_Year_End_Parameters;

-- ------------------------------------------------------------------
--                      Procedure Get_Year_End_Record
-- ------------------------------------------------------------------
-- Get_Year_End_Record procedure is called from
-- Check_Year_End_Parameters procedure.
-- It gets the treasury_symbol_id and then the group_id from
-- fv_ye_groups table. And then calls the Get_Fund_Value procedure.
-- ------------------------------------------------------------------
PROCEDURE Get_Year_End_Record(trsymbol	VARCHAR2,
			      fundgroup VARCHAR2,
			      timeframe VARCHAR2 ) IS
   CURSOR get_trsymid_cur IS
	SELECT treasury_symbol_id
	FROM Fv_Treasury_Symbols
	WHERE treasury_symbol = trsymbol
	AND set_of_books_id = vg_sob_id;

   TYPE t_getgroupid IS REF CURSOR;
   vc_groupid t_getgroupid;
    l_module_name         VARCHAR2(200)  ;

BEGIN

   l_module_name  :=  g_module_name || 'Get_Year_End_Record ';




 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     ******************************************************');
 END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     IN GET_YEAR_END_RECORD PROCEDURE,'||

		'processing the following:');
         END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     TREASURY SYMBOL: '||TRSYMBOL||' FUND GROUP: '||

		fundgroup||' Time Frame: '||timeframe);
         END IF;

   -- Assign the input parameter trsymbol to vg_trsymbol, so that this can be
   -- used in the Log messages.
   vg_trsymbol := trsymbol;
   vg_fundgroup := fundgroup;

   -- Get the Treasury Symbol ID
   OPEN get_trsymid_cur;
   FETCH get_trsymid_cur INTO vg_trsymbol_id;
   CLOSE get_trsymid_cur;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     PROCESSING THE TREASURY_SYMBOL_ID '||
			TO_CHAR(vg_trsymbol_id));
   END IF;

   OPEN vc_groupid FOR
     'SELECT group_id
      FROM Fv_Ye_Groups
      WHERE treasury_symbol_id = :trsymbol_id
      AND fund_group_code = :fundgroup
      AND fund_time_frame = :timeframe
      AND set_of_books_id = :sob_id
      AND closing_method  = :closing_method'
   USING vg_trsymbol_id,fundgroup,timeframe,vg_sob_id, vp_closing_method;

   FETCH vc_groupid INTO vg_group_id;

   IF vc_groupid%FOUND THEN  --vc_groupid(1)
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     GROUP ID AND CLOSING METHOD FOUND FOR TIMEFRAME '||TIMEFRAME||
		' and Fund Group '||fundgroup||' and Treasury Symbol '||
		trsymbol||' is '||TO_CHAR(vg_group_id)|| ' '||vp_closing_method);
      END IF;

   ELSE  --vc_groupid(1)
      CLOSE vc_groupid;

      -- Looking for group_id for timeframe and fundgroup parameters
      OPEN vc_groupid FOR
       'SELECT group_id
        FROM Fv_Ye_Groups
        WHERE treasury_symbol_id IS NULL
        AND fund_group_code = :fundgroup
        AND fund_time_frame = :timeframe
        AND set_of_books_id = :sob_id
        AND closing_method  = :closing_method'
      USING fundgroup,timeframe,vg_sob_id, vp_closing_method;

      FETCH vc_groupid INTO vg_group_id;

      IF vc_groupid%FOUND THEN  --vc_groupid(2)
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     GROUP ID AND CLOSING METHOD FOUND FOR TIME FRAME '||TIMEFRAME||
		' and Fund Group '||fundgroup||' is '||TO_CHAR(vg_group_id)|| ' '||vp_closing_method);
         END IF;

      ELSE  --vc_groupid(2)
         CLOSE vc_groupid;

         -- Looking for group_id for just the timeframe parameter
         OPEN vc_groupid FOR
    	  'SELECT group_id
           FROM Fv_Ye_Groups
           WHERE treasury_symbol_id IS NULL
           AND fund_group_code IS NULL
           AND fund_time_frame = :timeframe
           AND set_of_books_id = :sob_id
           AND closing_method  = :closing_method'
	 USING timeframe,vg_sob_id, vp_closing_method;

         FETCH vc_groupid INTO vg_group_id;

         IF vc_groupid%FOUND THEN  --vc_groupid(3)
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     GROUP ID AND CLOSING METHOD FOUND FOR THE TIME FRAME '||TIMEFRAME||
			' is '||TO_CHAR(vg_group_id)|| ' '||vp_closing_method);
            END IF;

	 ELSE  --vc_groupid(3)
	    CLOSE vc_groupid;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     YEAR END CLOSE RECORD IS NOT DEFINED '||

			'for any of the combination of :');
             END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     TIMEFRAME: '||TIMEFRAME||

			', Fund Group: '||fundgroup||', Treasury Symbol: '||trsymbol||' Closing Method: '||vp_closing_method);
        END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     PROCESSING THE NEXT TREASURY SYMBOL....');
 END IF;

	    -- Process the next treasury symbol
	    RETURN;
	 END IF;  --vc_groupid(3)
      END IF; --vc_groupid(2)
   END IF; --vc_groupid(1)

   CLOSE vc_groupid;

   Get_Fund_Value;

   IF (vp_retcode <> 0) THEN
	RAISE e_error;
   END IF;

EXCEPTION
   WHEN e_error THEN
        IF vc_groupid%ISOPEN THEN
	      CLOSE vc_groupid;
        END IF;
	RETURN;

   WHEN OTHERS THEN
        IF vc_groupid%ISOPEN THEN
	      CLOSE vc_groupid;
        END IF;
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Get_Year_End_Record procedure.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;

        RETURN ;
END Get_Year_End_Record;

-- ------------------------------------------------------------------
--                      Procedure Get_Fund_Value
-- ------------------------------------------------------------------
-- Get_Fund_Value procedure is called from Get_Year_End_Record procedure.
-- It gets all the fund values for the Trsymbol that is processed.
-- It then calls Determine_Acct_Flag procedure. If journal import is 'Y' then,
-- it calls the Update_Closing_Status procedure.
-- ------------------------------------------------------------------
PROCEDURE Get_Fund_Value IS

   CURSOR get_fund_cur IS
	SELECT fund_value
	FROM Fv_Fund_Parameters
	WHERE treasury_symbol_id = vg_trsymbol_id
	AND set_of_books_id = vg_sob_id;

   vl_rec_found_flag VARCHAR2(1) ;
  l_module_name         VARCHAR2(200);

BEGIN
   vl_rec_found_flag  := 'N';

   l_module_name          :=  g_module_name ||'Get_Fund_Value ';
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       IN GET_FUND_VALUE PROC WITH TREASURY SYMBOL ID '||

				TO_CHAR(vg_trsymbol_id));
                 END IF;
  OPEN get_fund_cur;
  LOOP
    FETCH get_fund_cur INTO vg_fund_value;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       --------------------------------------------------');
 END IF;

    IF get_fund_cur%FOUND THEN   -- get_fund_cur%found
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       PROCESSING THE FUND '||VG_FUND_VALUE||

		' for the Treasury Symbol '||vg_trsymbol);
         END IF;

	vl_rec_found_flag := 'Y';

	-- Process B
	Determine_Acct_Flag;

	IF (vp_retcode <> 0) THEN
	   RAISE e_error;
	END IF;

	-- Process C
  if (vp_mode='F') then
	   Update_Closing_Status;

	   IF (vp_retcode <> 0) THEN
	     RAISE e_error;
	   END IF;
	END IF;

    ELSE    -- get_fund_cur%found
	IF (vl_rec_found_flag = 'N') THEN
	   IF (vp_trsymbol IS NOT NULL) THEN
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       NO FUND VALUE FOUND FOR THE TREASURY SYMBOL '

				||vg_trsymbol);
                 END IF;
	      vp_retcode := 1;
	      vp_errbuf := 'No Fund Value found for the Treasury Symbol '||
				vg_trsymbol;
	   ELSE
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       NO FUND VALUE FOUND FOR THE TREASURY SYMBOL '
				||vg_trsymbol);
                 END IF;
	   END IF;
	   RETURN;
        ELSE
	   EXIT;
	END IF;
    END IF; -- get_fund_cur%found

  END LOOP;
  CLOSE get_fund_cur;

EXCEPTION
   WHEN e_error THEN
        IF get_fund_cur%ISOPEN THEN
	      CLOSE get_fund_cur;
        END IF;
	RETURN;

   WHEN OTHERS THEN
        IF get_fund_cur%ISOPEN THEN
	      CLOSE get_fund_cur;
        END IF;
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Get_Fund_Value procedure.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;

        RETURN ;

END Get_Fund_Value;

-- ------------------------------------------------------------------
--                      Procedure Determine_Acct_Flag
-- ------------------------------------------------------------------
-- Determine_Acct_Flag procedure is called from Get_Fund_Value procedure.
-- It determines whether the fund is expired,canceled or carryover.
-- It then calls the Get_Year_End_SeqAcct_Info procedure.
-- ------------------------------------------------------------------
PROCEDURE Determine_Acct_Flag IS
   CURSOR acctflag_cur IS
	SELECT fts.expiration_date,
	       fts.cancellation_date,
	       fts.time_frame
	FROM Fv_Treasury_Symbols fts, Fv_Fund_Parameters ffp
	WHERE fts.treasury_symbol_id = vg_trsymbol_id
	AND fts.treasury_symbol_id = ffp.treasury_symbol_id
	AND ffp.fund_value = vg_fund_value
	AND fts.treasury_symbol_id = ffp.treasury_symbol_id
	AND fts.set_of_books_id = vg_sob_id
	AND ffp.set_of_books_id = fts.set_of_books_id;

  vl_exp_date Fv_Treasury_Symbols.expiration_date%TYPE;
  vl_can_date Fv_Treasury_Symbols.cancellation_date%TYPE;
  vl_timeframe Fv_Treasury_Symbols.time_frame%TYPE;
  vl_status_flag VARCHAR2(1);
  l_module_name         VARCHAR2(200) ;
BEGIN

   l_module_name :=  g_module_name || 'Determine_Acct_Flag '   ;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         IN THE DETERMINE_ACCT_FLAG PROCEDURE:WITH TREASURY '||

		'Symbol = '||vg_trsymbol||' and Fund Value = '||vg_fund_value);
         END IF;

   -- Get the expiration and cancellation date for the treasury symbol
   OPEN acctflag_cur;
   FETCH acctflag_cur INTO vl_exp_date,vl_can_date,vl_timeframe;
   CLOSE acctflag_cur;

   -- Determing whether the fund is expired, cancelled or unexpired
   IF ((vl_exp_date <= vg_end_date) AND (vl_can_date <= vg_end_date)) THEN
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         FUND IS BOTH EXPIRED AND CANCELLED...');
	END IF;
	-- Set status flag to B(both expired and cancelled)
	vl_status_flag := 'B';
   ELSIF ((vl_exp_date <= vg_end_date) AND (vl_can_date > vg_end_date)) THEN
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         FUND IS EXPIRED BUT NOT CANCELLED...');
	END IF;
	-- Set status flag to E(expired)
	vl_status_flag := 'E';
   ELSIF ((vl_exp_date > vg_end_date) AND (vl_can_date <= vg_end_date)) THEN
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         FUND IS CANCELLED BUT NOT EXPIRED...');
	END IF;
	-- Set status flag to C(cancelled)
	vl_status_flag := 'C';
   ELSIF (vl_timeframe IN ('NO_YEAR','MULTIPLE')) THEN
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         FUND IS UNEXPIRED...');
	END IF;
	-- Set status flag to U(unexpired)
	vl_status_flag := 'U';
   END IF;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         VL_STATUS_FLAG '||VL_STATUS_FLAG);
   END IF;

   -- Based on status flag, set vg_acct_flag and call Get_Year_End_SeqAcct_Info proc
   IF (vl_status_flag = 'B') THEN
	-- Process all expired records first and then Cancelled records
        FOR i IN 1..2 LOOP
		SELECT DECODE(i,1,'Expired',2,'Canceled')
		INTO vg_acct_flag
		FROM DUAL;
  		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         VG_ACCT_FLAG '||VG_ACCT_FLAG);
  		END IF;

  		-- Get the Sequence Information
		Get_Year_End_SeqAcct_Info;

  		IF (vp_retcode <> 0) THEN
           		RAISE e_error;
  		END IF;
	END LOOP;
   ELSE
	SELECT DECODE(vl_status_flag,'E','Expired','C','Canceled','U','Unexpired')
	INTO vg_acct_flag
	FROM DUAL;
 	 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         VG_ACCT_FLAG '||VG_ACCT_FLAG);
 	 END IF;

  	-- Get the Sequence Information
	Get_Year_End_SeqAcct_Info;

  	IF (vp_retcode <> 0) THEN
       		RAISE e_error;
  	END IF;
   END IF;

EXCEPTION
   WHEN e_error THEN
	RETURN;

   WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Detemine_Acct_Flag procedure.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;

        RETURN ;
END Determine_Acct_Flag;

-- ------------------------------------------------------------------
--                      Procedure Get_Year_End_SeqAcct_Info
-- ------------------------------------------------------------------
-- Get_Year_End_SeqAcct_Info procedure is called from Determine_Acct_Flag
-- procedure. It gets the sequences, and for each sequence it gets the
-- account entries and processes them.It then calls the procedure
-- Determine_Child_Accounts for each account entry.
-- ------------------------------------------------------------------
PROCEDURE Get_Year_End_SeqAcct_Info IS

   CURSOR get_seq_cur IS
	SELECT sequence_id,SEQUENCE
	FROM Fv_Ye_Group_Sequences
	WHERE group_id = vg_group_id
	AND set_of_books_id = vg_sob_id
	ORDER BY SEQUENCE;

   CURSOR get_acct_cur IS
	SELECT from_account,to_account, requisition
	FROM Fv_Ye_Sequence_Accounts
	WHERE sequence_id = vg_seq_id
	AND account_flag = vg_acct_flag
	AND set_of_books_id = vg_sob_id
  ORDER BY order_by_ctr;

   CURSOR get_count_cur IS
	SELECT COUNT(*)
	FROM Fv_Ye_Sequence_Accounts
	WHERE sequence_id = vg_seq_id
	AND set_of_books_id = vg_sob_id;

   vl_seqrec_flag VARCHAR2(1) ;
   vl_acctrec_flag VARCHAR2(1) ;
   vl_cnt NUMBER ;
   l_module_name         VARCHAR2(200)  ;

BEGIN

  l_module_name :=  g_module_name || '  Get_Year_End_SeqAcct_Info ';
  vl_seqrec_flag  := 'N';
  vl_acctrec_flag :=  'N';
  vl_cnt := 0;



 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'           IN THE GET_YEAR_END_SEQACCT_INFO PROCEDURE...');
 END IF;

   OPEN get_seq_cur;
   LOOP						-- getseq loop
      FETCH get_seq_cur INTO vg_seq_id, vg_seq;

      IF get_seq_cur%FOUND THEN 		-- get_seq_cur
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'             PROCESSING SEQUENCE '||TO_CHAR(VG_SEQ)||
			' and sequence_id '||TO_CHAR(vg_seq_id));
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' Treasury Symbol is '||vg_trsymbol );
        END IF;

	vl_seqrec_flag := 'Y';


  select closing_method into vg_closing_method from fv_ye_groups where group_id = vg_group_id
  AND set_of_books_id = vg_sob_id  ;

  --Process this year end record only if closing method of year end record matched closing method of process
  IF vg_closing_method = vp_closing_method THEN

  SELECT close_requisitions into treasury_closing_method
  FROM  fv_treasury_symbols
  WHERE treasury_symbol = vg_trsymbol and set_of_books_id = vg_sob_id;


	OPEN get_acct_cur;
	LOOP					-- getacct loop
     FETCH get_acct_cur INTO vg_from_acct,vg_to_acct,vg_requisition;
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' Closing method is  '||
        'flag:'||vg_closing_method||', treasury_closing_method:'||treasury_closing_method || 'vg_acct_flag '||vg_acct_flag);
     END IF;

	  IF get_acct_cur%FOUND THEN 		-- get_acct_cur

      --Close the accounts (i)if requisition checkbox is checked and only if the closing method of the treasury symbol matches
      --the closing method of year end record  or (ii)if requisition checkbox is not checked
      -- Bug 9322307
      IF  (vg_requisition = 'Y' and  treasury_closing_method is not null and vg_closing_method = treasury_closing_method) or (vg_requisition = 'N' or vg_requisition is null)   THEN

                   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'             PROCESSING THE RECORD WITH ACCOUNT '||
          'flag:'||vg_acct_flag||', From Account:'||vg_from_acct
          ||', To Account:'|| vg_to_acct);
                   END IF;

             vl_acctrec_flag := 'Y';

             -- Call Determine_Child_Accounts;
             Determine_Child_Accounts;

               IF (vp_retcode <> 0) THEN
                  RAISE e_error;
               END IF;
       END IF;            -- ENDS if vg_requisition = 'Y' and vg_closing_method = treasury_closing_method then

	  ELSE  				-- get_acct_cur
	     IF (vl_acctrec_flag = 'N') THEN
          OPEN get_count_cur;
          FETCH get_count_cur INTO vl_cnt;
          CLOSE get_count_cur;

          IF (vl_cnt > 0) THEN
               IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'             NO ACCOUNT INFORMATION FOUND '||
                    'with '||vg_acct_flag||' appropriation status for '||
                    'the Sequence '||TO_CHAR(vg_seq));
                           END IF;
          ELSE
               IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'             NO ACCOUNT INFORMATION FOUND '||
                    'for the Sequence '||TO_CHAR(vg_seq));
                           END IF;
          END IF;
      ELSE
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
       '             PROCESSING IS DONE FOR THE SEQUENCE '
            ||TO_CHAR(vg_seq));
          END IF;
     END IF;
     EXIT ;
   END IF; 				-- get_acct_cur

	END LOOP;    				-- getacct loop
	CLOSE get_acct_cur;
  END IF;           -- IF vg_closing_method = vp_closing_method THEN
      ELSE 					-- get_seq_cur

	IF (vl_seqrec_flag = 'N') THEN
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'           NO SEQUENCES FOUND FOR THE GROUP ID '
			||TO_CHAR(vg_group_id));
             END IF;
	   RETURN;
	ELSE
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'             PROCESSING IS DONE FOR THE GROUP ID '

			||TO_CHAR(vg_group_id));
             END IF;
	   EXIT;
	END IF;


      END IF; 					-- get_seq_cur
   END LOOP;   					-- getseq loop
   CLOSE get_seq_cur;

EXCEPTION
   WHEN e_error THEN
	IF get_acct_cur%ISOPEN THEN
	   CLOSE get_acct_cur;
	END IF;
	RETURN;

   WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Get_Year_End_SeqAcct_Info procedure.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;
        RETURN ;

END Get_Year_End_SeqAcct_Info;


-- ------------------------------------------------------------------
--                      Procedure Determine_Child_Accounts
-- ------------------------------------------------------------------
-- Determine_Child_Accounts procedure is called from Get_Year_End_SeqAcct_Info
-- procedure. For a record with year_entry= Closing, this procedure
-- gets the balance_read_flag from the Temp table, and then calls
-- Get_Balances procedure. For a record with year_entry = Carryover,
-- it calculates the balances from the previous entry, and then
-- calls the procedure Determine_DrCr.
-- ------------------------------------------------------------------
PROCEDURE Determine_Child_Accounts IS
    vl_parent_cnt NUMBER;
    vl_child_low Fnd_Flex_Values_Vl.flex_value%TYPE;
    vl_child_high Fnd_Flex_Values_Vl.flex_value%TYPE;

    TYPE t_getbal_cnt IS REF CURSOR;
    vc_getbal_cnt t_getbal_cnt;
    vl_select VARCHAR2(2000);
    vl_bal_cnt NUMBER;

    CURSOR get_hierarchies_cur IS
      SELECT child_flex_value_low, child_flex_value_high
      FROM Fnd_Flex_Value_Hierarchies
      WHERE parent_flex_value = vg_from_acct
      AND flex_value_set_id = vg_acct_val_set_id;

    CURSOR get_child_values_cur IS
      SELECT flex_value
      FROM Fnd_Flex_Values_Vl
      WHERE flex_value_set_id = vg_acct_val_set_id
      AND flex_value BETWEEN vl_child_low AND vl_child_high
      ORDER BY flex_value;

  l_module_name         VARCHAR2(200) ;

BEGIN

 l_module_name  :=  g_module_name || 'Determine_Child_Accounts ';


 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               IN DETERMINE_CHILD_ACCOUNTS PROCEDURE...');
 END IF;

     BEGIN
	-- Check to see if the from account is a parent
	SELECT COUNT(*)
	INTO vl_parent_cnt
	FROM Fnd_Flex_Values_Vl
     	WHERE flex_value_set_id = vg_acct_val_set_id
     	AND summary_flag = 'Y'
    	AND flex_value = vg_from_acct;

     EXCEPTION
	WHEN OTHERS THEN
	   vp_retcode := 2;
	   vp_errbuf  := SQLERRM || '-- Error in Determine_Child_Accounts procedure,'||
				 'while deriving the balance_read_flag.';
	   RETURN;
     END;

     IF (vl_parent_cnt = 0) THEN  	-- parent_cnt
       	--  the from account is not a parent
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               FROM ACCOUNT IS NOT A PARENT');
        END IF;
       	vg_child_acct := vg_from_acct;

 	-- Call Determine_Balance_Read_Flag procedure
	Determine_Balance_Read_Flag;

     	IF (vp_retcode <> 0) THEN
		RAISE e_error;
     	END IF;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               BALANCE_READ_FLAG IS '||
			vg_balance_read_flag);
        END IF;

     	-- Call Get_Balances procedure to get balances for the from account
     	Get_Balances;

     	IF (vp_retcode <> 0) THEN
		RAISE e_error;
     	END IF;
     ELSE	  			-- parent_cnt
      	--  the from account is a parent
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               FROM ACCOUNT IS A PARENT');
        END IF;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               CHECKING TO SEE IF THE PARENT HAS '||
		'any balances.');
	END IF;

	vl_select := 'SELECT COUNT(*)
                   FROM Gl_Balances glb,Gl_Code_Combinations gcc
                   WHERE glb.code_combination_id = gcc.code_combination_id
                   AND gcc.'||vg_bal_segment||' = :fund_value'||
                   ' AND gcc.'||vg_acct_segment|| ' = :from_acct'||
                   ' AND gcc.summary_flag = '||''''||'N'||''''||
                   ' AND gcc.template_id IS NULL
                     AND glb.actual_flag = '||''''||'A'||''''||
                   ' AND glb.ledger_id = :sob
                   AND gcc.chart_of_accounts_id = :coa
                   AND glb.period_year = :closing_fyr
                   AND glb.period_name = :closing_period
		   AND glb.currency_code = :currency';

        -- Open thru' native dynamic sql
	EXECUTE IMMEDIATE vl_select INTO vl_bal_cnt USING
		vg_fund_value,vg_from_acct,vg_sob_id,
		vg_coa_id,vp_closing_fyr,vg_closing_period,vg_currency;

	IF (vl_bal_cnt > 0) THEN		-- bal_check
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               PARENT ACCOUNT HAS BALANCES IN '||
		'General Ledger. This is the scenario, when a child account '||
		'has later been defined as a parent account.Getting the balances.');
           END IF;

	   vg_child_acct := vg_from_acct;
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               PROCESSING THE ACCT:'||
                        vg_child_acct);
           END IF;

           -- Call Process_Acct procedure
	   Process_Acct;

	   IF (vp_retcode <> 0) THEN
                    RAISE e_error;
           END IF;

	ELSE					-- bal_check
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               PARENT ACCOUNT HAS NO BALANCES IN '||
    'General Ledger.');
     END IF;
	END IF;					-- bal_check

        -- For each child hierarchy range, get low and high value
     	FOR vc_hierarchies IN get_hierarchies_cur LOOP -- Hierarchies
            vl_child_low := vc_hierarchies.child_flex_value_low;
            vl_child_high := vc_hierarchies.child_flex_value_high;
	    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               PROCESSING HIERARCHY WITH LOW: '||
		 vl_child_low||' and high: '||vl_child_high);
	    END IF;

            -- For each child hierarchy, find the child values
            FOR vc_children IN get_child_values_cur LOOP  -- children
		--  set the child account
      	 	vg_child_acct := vc_children.flex_value;
	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               PROCESSING THE CHILD VALUE: '||
			vg_child_acct);
	        END IF;

     		-- Call Process_Acct procedure
     		Process_Acct;

     		IF (vp_retcode <> 0) THEN
			RAISE e_error;
     		END IF;

            END LOOP;  					-- children
       END LOOP;  					-- Hierarchies
    END IF;				-- parent_cnt

EXCEPTION
   WHEN e_error THEN
     RETURN;

   WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Determine_Child_Accounts procedure.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;
        RETURN ;

END Determine_Child_Accounts;

-- ------------------------------------------------------------------
--                      Procedure Process_Acct
-- ------------------------------------------------------------------
-- Process_Acct procedure is called from
-- Determine_Child_Accounts procedure. This procedure calls the
-- Determine_Balance_Read_Flag and Get_Balances procedures.
-- ------------------------------------------------------------------
PROCEDURE Process_Acct IS
l_module_name         VARCHAR2(200) ;

BEGIN
  l_module_name  :=  g_module_name || 'Process_Acct ';
    -- Call Determine_Balance_Read_Flag procedure
    Determine_Balance_Read_Flag;

    IF (vp_retcode <> 0) THEN
           RAISE e_error;
    END IF;
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               BALANCE_READ_FLAG IS '||
                        vg_balance_read_flag);
    END IF;

    -- Call Get_Balances procedure to get balances for the from account
    Get_Balances;

    IF (vp_retcode <> 0) THEN
           RAISE e_error;
    END IF;

EXCEPTION
   WHEN e_error THEN
     RETURN;

   WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Process_Acct procedure.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;
       RETURN ;
END Process_Acct;

-- ------------------------------------------------------------------
--                      Procedure Determine_Balance_Read_Flag
-- ------------------------------------------------------------------
-- Determine_Balance_Read_Flag procedure is called from
-- Process_Acct procedure. This procedure determines the
-- balance_read_flag from the Temp table.
-- ------------------------------------------------------------------
PROCEDURE Determine_Balance_Read_Flag IS
l_module_name         VARCHAR2(200) ;
BEGIN


       l_module_name  :=  g_module_name ||
			'Determine_Balance_Read_Flag ';
	vg_balance_read_flag := 'N';

	SELECT DISTINCT balance_read_flag
	INTO vg_balance_read_flag
	FROM Fv_Ye_Seq_Bal_Temp
	WHERE account_seg = vg_child_acct
	AND balance_seg = vg_fund_value
	AND set_of_books_id = vg_sob_id
	AND fiscal_year = vp_closing_fyr
	AND balance_read_flag = 'Y'
	AND group_id = vg_group_id;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   vg_balance_read_flag := 'N';
	WHEN OTHERS THEN
	   vp_retcode := 2;
           vp_errbuf  := SQLERRM  ||
		' -- Error in Determine_Balance_Read_Flag procedure.' ;
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
       END IF;
	   RETURN;
END Determine_Balance_Read_Flag;

-- ------------------------------------------------------------------
--                      Procedure Get_Balances
-- ------------------------------------------------------------------
-- Get_Balances procedure is called from Process_Acct
-- procedure. It gets the balances from Gl_Balances , and handles
-- the different scenarios and then calls Determine_DrCr procedure.
-- ------------------------------------------------------------------
PROCEDURE Get_Balances IS
   vl_rec_found_flag VARCHAR2(1) ;

   TYPE t_getbal IS REF CURSOR;
   vc_getbal t_getbal;
   vl_select VARCHAR2(2000);

   vl_ccid Gl_Code_Combinations.code_combination_id%TYPE;

   TYPE t_ccidtable IS TABLE OF Gl_Code_Combinations.code_combination_id%TYPE
	INDEX BY BINARY_INTEGER;
   vt_ccid 	t_ccidtable;
   i	   	BINARY_INTEGER ;
   vl_ccid_cnt 	NUMBER;
   vl_exists    VARCHAR2(1) ;

   CURSOR get_sumtemp_cur IS
	SELECT NVL(SUM(bal_seq_amt),0) amt,code_combination_id
	FROM Fv_Ye_Seq_Bal_Temp
	WHERE account_seg = vg_child_acct
	AND balance_seg = vg_fund_value
	AND set_of_books_id = vg_sob_id
	AND group_id = vg_group_id
	AND fiscal_year = vp_closing_fyr
	AND balance_read_flag = 'N'
	GROUP BY code_combination_id;

   CURSOR get_sumtemp_seqcur IS
	SELECT NVL(SUM(bal_seq_amt),0) amt,code_combination_id
	FROM Fv_Ye_Seq_Bal_Temp
	WHERE account_seg = vg_child_acct
	AND balance_seg = vg_fund_value
	AND set_of_books_id = vg_sob_id
	AND group_id = vg_group_id
	AND fiscal_year = vp_closing_fyr
	AND balance_read_flag = 'Y'
	AND SEQUENCE IN (SELECT MAX(SEQUENCE)
			FROM Fv_Ye_Seq_Bal_Temp g
			WHERE g.account_seg = vg_from_acct
			AND g.balance_seg = vg_fund_value
			AND g.set_of_books_id = vg_sob_id
			AND g.group_id = vg_group_id
			AND g.balance_read_flag = 'Y')
	GROUP BY code_combination_id;

   CURSOR get_addccid_cur IS
	SELECT NVL(SUM(bal_seq_amt),0) amt,code_combination_id
	FROM Fv_Ye_Seq_Bal_Temp
	WHERE account_seg = vg_child_acct
	AND balance_seg = vg_fund_value
	AND set_of_books_id = vg_sob_id
	AND group_id = vg_group_id
	AND fiscal_year = vp_closing_fyr
	AND balance_read_flag = 'N'
	AND SEQUENCE < vg_seq
	GROUP BY code_combination_id;

    l_module_name         VARCHAR2(200) ;

BEGIN
    l_module_name  :=  g_module_name ||
                                ' Get_Balances ';
     vl_rec_found_flag  := 'N';
     i      := 1;
     vl_exists  := 'N';
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               IN THE GET_BALANCES PROCEDURE, '||

	 'processing the account '||vg_child_acct||
         ' with balance_read_flag = '||vg_balance_read_flag);
 END IF;
   -- Purge the Pl/Sql table
   vt_ccid.DELETE;

   /* If there are no records defined in the Fv_Ye_Seq_Bal_Temp table *
    * for the fund and the from acct within the group that is being   *
    * processed. This is the scenario when vg_balance_read_flag = N   */
   IF (vg_balance_read_flag = 'N') THEN         -- vg_balance_read_flag
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               CASE: WHEN BALANCE_READ_FLAG = N');
      END IF;

      vl_select := 'SELECT glb.code_combination_id,
		   NVL(SUM(NVL(begin_balance_dr,0) + NVL(period_net_dr,0)) -
		   SUM(NVL(begin_balance_cr,0) + NVL(period_net_cr,0)),0)
		   FROM Gl_Balances glb,Gl_Code_Combinations gcc
		   WHERE glb.code_combination_id = gcc.code_combination_id
		   AND gcc.'||vg_bal_segment|| ' = :fund_value'||
		   ' AND gcc.'||vg_acct_segment|| ' = :child_acct'||
		   ' AND gcc.summary_flag = '||''''||'N'||''''||
		   ' AND gcc.template_id IS NULL
		     AND glb.actual_flag = '||''''||'A'||''''||
		   ' AND glb.ledger_id = :sob
		   AND gcc.chart_of_accounts_id = :coa
		   AND glb.period_year = :closing_fyr
		   AND glb.period_name = :closing_period
		   AND glb.currency_code = :currency
		   GROUP BY glb.code_combination_id ';

 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,vl_select);
      -- Open thru' native dynamic sql
      OPEN vc_getbal FOR vl_select USING vg_fund_value,
                                         vg_child_acct,
	                        	 vg_sob_id,
                                         vg_coa_id,
                                         vp_closing_fyr,
                                         vg_closing_period,
                                         vg_currency;

      -- Fetch the records
      LOOP  					-- loop for balances
        vg_gl_bal_amt := 0;

	FETCH vc_getbal INTO vl_ccid,vg_gl_bal_amt;

        IF (vc_getbal%FOUND) THEN		-- vc_getbal found
	    vl_rec_found_flag := 'Y';

	    vg_bal_seq_amt := 0;
	    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               PROCESSING THE CCID '
			||TO_CHAR(vl_ccid)||
			' and GL balance amt(vg_gl_bal_amt) is '
			||TO_CHAR(vg_gl_bal_amt));
	    END IF;

	    BEGIN
		SELECT NVL(SUM(bal_seq_amt),0)
		INTO vg_bal_seq_amt
		FROM Fv_Ye_Seq_Bal_Temp
		WHERE account_seg = vg_child_acct
		AND balance_seg   = vg_fund_value
		AND set_of_books_id = vg_sob_id
		AND group_id = vg_group_id
		AND code_combination_id = vl_ccid
		AND fiscal_year = vp_closing_fyr
		AND balance_read_flag = 'N';

	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		   vg_bal_seq_amt := 0;
	    END;
	    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               AMOUNT FROM TEMP TABLE, '||
                     'for the ccid being processed is ' ||TO_CHAR(vg_bal_seq_amt));
	    END IF;

	    -- set the balance_read_flag
	    vg_balance_read_flag := 'Y';

	    -- Sum the amt from the gl_balances and the temp table.
	    vg_bal_seq_amt := vg_bal_seq_amt + vg_gl_bal_amt;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               TOTAL AMOUNT IS '||
                        TO_CHAR(vg_bal_seq_amt));
            END IF;
	    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               CALLING DETERMINE_DRCR PROC.'||
				'Case 1D');
	    END IF;
	    -- Call Determine_DrCr procedure
	    -- Case 1D:
	    Determine_DrCr(vl_ccid);

	    IF (vp_retcode <> 0) THEN
		RAISE e_error;
	    END IF;

	    -- put the ccid into the pl/sql table
	    vt_ccid(i) := vl_ccid;
	    i := i + 1;

 	ELSE 					-- vc_getbal found
       	   /* Case when no balances are found */
	   /* this else is if vc_getbal not found	      */
           /*this code in else part is necessary to handle the*
            *following situation:say group_id 1 has two seq's *
            *say 10 and 20. Sequence 10 has EXP CY 4700 4650  *
            *and EXP CY 4610 4650. Sequence 20 has EXP CY 4650*
            *4800. In this situation to get all the balances  *
            *from the temp table,for 4650 when we are         *
            *processing the 4650 account for sequence 20, we  *
            *need to consider the sum for the to accounts 4650*
            * for sequence 10 in the temp table.              */

 	   IF (vl_rec_found_flag = 'Y') THEN		-- vl_rec_found_flag
		EXIT;
	   ELSE					-- vl_rec_found_flag
	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               NO BALANCES FOUND IN General Ledger.'||
			'Looking for balances in the Temp table');
	        END IF;
		vg_bal_seq_amt := 0;

		FOR vc_getsumtemp IN get_sumtemp_cur LOOP -- getsum loop
	            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               FOUND BALANCES '||
					'in Temp Table.');
	            END IF;

	            -- put the ccid into the pl/sql table
	            vt_ccid(i) := vc_getsumtemp.code_combination_id;
	            i := i + 1;

		    -- Get the amt from the temp table
		    vg_bal_seq_amt := vc_getsumtemp.amt;
		    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               AMOUNT FROM TEMP TABLE '||
				'is '|| TO_CHAR(vg_bal_seq_amt));
		    END IF;

		    -- Set the balance_read_flag
		    vg_balance_read_flag := 'Y';

	    	    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               CALLING DETERMINE_DRCR'||
				' proc. Case 2D');
	    	    END IF;
	    	    -- Call Determine_DrCr procedure
	    	    -- Case 2D:
	    	    Determine_DrCr(vc_getsumtemp.code_combination_id);

	    	    IF (vp_retcode <> 0) THEN
			    RAISE e_error;
	    	    END IF;
		END LOOP;				-- getsum loop
		EXIT;
	   END IF;				-- vl_rec_found_flag
 	END IF; 				-- vc_getbal found

      END LOOP;					-- loop for balances

      -- Get the count of ccids in pl/sql table
      vl_ccid_cnt := vt_ccid.COUNT;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               THE NUMBER OF CCIDS PROCESSED FROM '||
			'gl_balances for the from acct is '||TO_CHAR(vl_ccid_cnt));
      END IF;

      /* The below code is needed to handle the following scenrio: *
       * The sequence are defined as follows: Group id 1 has seq's *
       * 10 and 20. Seq 10 has Exp 4610 4450, Exp 4700 4450. Seq 20*
       * has Exp 4450 4650. In this scenario, say acct 461002 with *
       * ccid 30608 has $1145 which has been moved to 4450 with    *
       * ccid 34650 based on the first entry of the seq 10. There  *
       * was also another ccid 28822 with amt $19M which was moved *
       * to 4450.Now when processing seq 20, for 4450 we find an   *
       * amt $15M with ccid 28822.When the Ye process runs, it is  *
       * just picking up the amount from gl,plus the amt from temp *
       * table only for ccid 28822. The below code is necessary to *
       * this scenario, where the money in the ccid 34650 for acct *
       * 4450 should also be moved to acct 4650.                   */

      FOR vc_addccid IN get_addccid_cur LOOP		-- additional ccid
	vl_ccid := vc_addccid.code_combination_id;
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               PROCESSING THE ADDITIONAL CCID '||
			TO_CHAR(vl_ccid));
	END IF;

	FOR j IN 1..vl_ccid_cnt LOOP
		IF (vt_ccid(j) = vl_ccid) THEN
			vl_exists := 'Y';
			EXIT;
		ELSE
			vl_exists := 'N';
		END IF;
        END LOOP;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               VL_EXISTS = '||VL_EXISTS);
	END IF;

	IF (vl_exists = 'N') THEN
		    -- Get the amt from the temp table
		    vg_bal_seq_amt := vc_addccid.amt;
		    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               AMOUNT FROM TEMP TABLE '||
				'is '|| TO_CHAR(vg_bal_seq_amt)||
				' for the additional ccid '||TO_CHAR(vl_ccid));
		    END IF;

		    -- Set the balance_read_flag
		    vg_balance_read_flag := 'Y';

	    	    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               CALLING DETERMINE_DRCR'||
				' proc. Case 4D');
	    	    END IF;
	    	    -- Call Determine_DrCr procedure
	    	    -- Case 4D:
	    	    Determine_DrCr(vl_ccid);

	    	    IF (vp_retcode <> 0) THEN
			    RAISE e_error;
	    	    END IF;
	END IF;

      END LOOP;						-- additional ccid

   ELSE   					-- vg_balance_read_flag
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               CASE: WHEN BALANCE_READ_FLAG = Y');
      END IF;

      FOR vc_getsumseq IN get_sumtemp_seqcur LOOP -- getsumseq loop
    	-- Get the amt from the temp table
        vg_bal_seq_amt := vc_getsumseq.amt;

	-- Set the balance_read_flag
	vg_balance_read_flag := 'Y';

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'               CALLING DETERMINE_DRCR PROC.'||
				'Case 3D');
	END IF;
	-- Call Determine_DrCr procedure
	-- Case 3D:
	Determine_DrCr(vc_getsumseq.code_combination_id);

	IF (vp_retcode <> 0) THEN
	    RAISE e_error;
	END IF;
      END LOOP;					-- getsumseq loop

   END IF;					-- vg_balance_read_flag

EXCEPTION
   WHEN e_error THEN
	IF vc_getbal%ISOPEN THEN
	   CLOSE vc_getbal;
	END IF;
	RETURN;

   WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Get_Balances procedure.' ;
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
       END IF;
    RETURN;
END Get_Balances;

-- ------------------------------------------------------------------
--                      Procedure Determine_DrCr
-- ------------------------------------------------------------------
-- Determine_DrCr procedure is called from Get_Balances procedure.
-- This determines the debit and credit flag, and then calls the
-- Get_Segment_Values procedure, and then calls Insert_Balances.
-- ------------------------------------------------------------------
PROCEDURE Determine_DrCr(ccid NUMBER) IS
   vl_dbt_flag VARCHAR2(1);
   vl_crt_flag VARCHAR2(1);

   vl_acct 	    Fv_Ye_Sequence_Accounts.from_account%TYPE;
   vl_remaining_bal NUMBER;
   vl_drcr_flag     VARCHAR2(1);
   vl_read_flag     VARCHAR2(1);
   vl_ccid	    Gl_Code_Combinations.code_combination_id%TYPE;
   vl_processing_type Fv_Ye_Seq_Bal_Temp.processing_type%TYPE;
   vl_acct_combi     VARCHAR2(2000);
   vl_delimeter      VARCHAR2(1);
   v_cross_val_msg   VARCHAR2(2000);
   l_ccid_select varchar2(2048);
   l_cursor_id     INTEGER;
   l_counter       NUMBER;
   l_ignore    INTEGER;


  CURSOR flex_cursor
  (
    c_coa_id NUMBER
  ) IS
  SELECT fifs.application_column_name
    FROM fnd_id_flex_segments fifs
   WHERE fifs.application_id = 101
     AND fifs.id_flex_code = 'GL#'
     AND fifs.id_flex_num = c_coa_id
     AND fifs.enabled_flag = 'Y'
   ORDER by fifs.segment_num;
   l_module_name         VARCHAR2(200)  ;
BEGIN

l_module_name  :=  g_module_name ||'Determine_DrCr ';




 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'                 IN DETERMINE_DRCR PROCEDURE,'||

		' processing ccid '||TO_CHAR(ccid));
         END IF;
    -- Determine the debit and credit flag
    -- debit flag is used for the from_acct
    -- credit flag is used for the to_acct
    IF (vg_bal_seq_amt > 0) THEN
	vl_dbt_flag := 'C';
	vl_crt_flag := 'D';
    ELSE
	vl_dbt_flag := 'D';
	vl_crt_flag := 'C';
    END IF;

    -- Get the Segment Values for the ccid
    Get_Segment_Values(ccid);

    IF (vp_retcode <> 0) THEN
	RAISE e_error;
    END IF;

    FOR i IN 1..2 LOOP
	IF (i = 1) THEN
	   -- When this procedure is called from Case 1D, this step is
	   -- redundant, but when called from Case 2D , this is required.
	   -- Overlaying the Natural Acct segment with the child Acct
	   vt_segments(vg_acct_segnum) := vg_child_acct;
	   vl_acct := vg_child_acct;
	   vl_remaining_bal := 0;
	   vl_ccid := ccid;

	   -- Determine the Processing Type(FACTSI or FACTSII or none)
           Determine_Processing_Type(vl_processing_type);

           IF (vp_retcode <> 0) THEN
	       RAISE e_error;
           END IF;
	ELSE
	   -- This step is required for all the Cases.
	   -- Overlaying the Natural Acct segment with the To Acct
	   vt_segments(vg_acct_segnum) := vg_to_acct;
	   vl_acct := vg_to_acct;
	   vl_remaining_bal := vg_bal_seq_amt;
	   vl_processing_type := 0;

    	   IF NOT Fnd_Flex_Ext.Get_Combination_Id('SQLGL', 'GL#',
					vg_coa_id, SYSDATE, vg_num_segs,
					vt_segments, vl_ccid) THEN
		IF (vl_remaining_bal <> 0) THEN
			RAISE e_invalid;
		ELSE
               vl_ccid := NULL;
               l_ccid_select := 'SELECT code_combination_id
                                 FROM gl_code_combinations gcc
                                WHERE gcc.chart_of_accounts_id = :coa_id ';
               FOR flex_rec IN flex_cursor (vg_coa_id) LOOP
                 l_ccid_select := l_ccid_select ||
                                  ' and gcc.'||
                                  flex_rec.application_column_name||
                                  ' = :c_'||
                                  flex_rec.application_column_name;
               END LOOP;

               l_cursor_id := dbms_sql.open_cursor;
               dbms_sql.parse(l_cursor_id, l_ccid_select, dbms_sql.v7);
               dbms_sql.define_column(l_cursor_id, 1, vl_ccid);
               dbms_sql.bind_variable(l_cursor_id, ':coa_id', vg_coa_id);

               l_counter := 0;
               FOR flex_rec IN flex_cursor (vg_coa_id) LOOP
                 l_counter := l_counter + 1;
                 dbms_sql.bind_variable(l_cursor_id, 'c_'||flex_rec.application_column_name, vt_segments(l_counter));
               END LOOP;

               l_ignore := dbms_sql.execute_and_fetch(l_cursor_id);
               dbms_sql.column_value(l_cursor_id, 1, vl_ccid);
               dbms_sql.close_cursor (l_cursor_id);
               IF (vl_ccid IS NULL) THEN
 		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'No CCID Exists for the following Combination');
                l_counter := 0;
                FOR flex_rec IN flex_cursor (vg_coa_id) LOOP
                  l_counter := l_counter + 1;
 		  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,flex_rec.application_column_name||'='|| vt_segments(l_counter));
                END LOOP;
 		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Please Create the CCID');
		RAISE e_invalid;
		END IF;
		END IF;
	   END IF;

	END IF;

	BEGIN
	   SELECT DECODE(i,1,vl_dbt_flag,vl_crt_flag)
	   INTO vl_drcr_flag
	   FROM DUAL;

	   SELECT DECODE(i,1,vg_balance_read_flag,'N')
	   INTO vl_read_flag
	   FROM DUAL;

	EXCEPTION
	   WHEN OTHERS THEN
        	vp_retcode := 2 ;
        	vp_errbuf  := SQLERRM  ||' -- Error in Determine_DrCr procedure,'||
			'while deriving the vl_drcr_flag and vl_read_flag.' ;
		RETURN;
	END;


-- Insert Null values for the Remaining Segments

   FOR i in vt_segments.count+1..30
   LOOP
        vt_segments(i) := NULL;
   END LOOP;


	-- Call the Insert_Balances procedure.
	Insert_Balances(
		vl_ccid,
		vl_acct,
		vg_bal_seq_amt,
		vl_drcr_flag,
		vl_read_flag,
		vl_remaining_bal,
		vl_processing_type,
		vt_segments);

    	IF (vp_retcode <> 0) THEN
		RAISE e_error;
    	END IF;
    END LOOP;

EXCEPTION
   WHEN e_error THEN
	RETURN;

   WHEN e_invalid THEN
      vp_retcode := 2;
      v_cross_val_msg :=  fnd_flex_ext.get_message;
      vl_delimeter := fnd_flex_ext.get_delimiter('SQLGL', 'GL#',vg_coa_id) ;
      vl_acct_combi := fnd_flex_ext.concatenate_segments(vg_num_segs,
				vt_segments, vl_delimeter);

      vp_errbuf := 'The '||'"'||'To Account combination :'|| vl_acct_combi||'"'
		    ||' violates Cross-Validation/Security rule ' ||
                    '"'|| v_cross_val_msg ||'".';

 -- vp_errbuf := 'Unable to determine the CCID of the To Account combination,'||
--		'possibly due to a Cross-Validation/Security rule violation.';
	RETURN;

   WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Determine_DrCr procedure.' ;

       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
       END IF;
     RETURN;

END Determine_DrCr;

-- ------------------------------------------------------------------
--                      Procedure Get_Segment_Values
-- ------------------------------------------------------------------
-- Get_Segment_Values procedure is called from Determine_DrCr procedure.
-- This proc gets all the segments for the ccid passed.
-- ------------------------------------------------------------------
PROCEDURE Get_Segment_Values(ccid NUMBER) IS
   vl_segment_value VARCHAR2(25);
   vl_num_segs		NUMBER;
   l_module_name         VARCHAR2(200);
BEGIN

  l_module_name  :=  g_module_name ||
                                          'Get_Segment_Values ';

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'                   IN GET_SEGMENT_VALUES PROCEDURE,'||

		'determing the segments for the ccid '||TO_CHAR(ccid));
         END IF;


   IF NOT fnd_flex_ext.get_segments('SQLGL','GL#',vg_coa_id,ccid,vl_num_segs,
                vt_segments) THEN
        raise e_invalid;
   END IF;

EXCEPTION
   WHEN e_invalid THEN
      vp_retcode := 2;
      vp_errbuf := 'Error in Get_Segment_Values - Unable to
		determine the segments for the CCID '||TO_CHAR(ccid);
      RETURN;

   WHEN OTHERS THEN
      vp_retcode := 2 ;
      vp_errbuf  := SQLERRM  ||' -- Error in Get_Segment_Values procedure.' ;
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
       END IF;

      RETURN ;

END Get_Segment_Values;

-- ------------------------------------------------------------------
--                      Procedure Determine_Processing_Type
-- ------------------------------------------------------------------
-- Determine_Processing_Type  procedure is called from Determine_DrCr procedure.
-- This proc determines if the Year end process needs to close the
-- balances at the FACTSI or FACTSII attribute level.
-- ------------------------------------------------------------------
PROCEDURE Determine_Processing_Type(p_type OUT NOCOPY NUMBER) IS

   CURSOR get_attrcnt_csr(p_acct VARCHAR2) IS
	SELECT COUNT(*)
	FROM Fv_Facts_Attributes
	WHERE set_of_books_id = vg_sob_id
	AND facts_acct_number = p_acct;

   CURSOR get_attributes_csr(p_acct VARCHAR2) IS
	SELECT public_law_code,
               advance_flag,
               transfer_flag,
               govt_non_govt
	FROM Fv_Facts_Attributes
	WHERE set_of_books_id = vg_sob_id
	AND facts_acct_number = p_acct;

   CURSOR get_parent_csr IS
	SELECT parent_flex_value
	FROM Fnd_Flex_Value_Norm_Hierarchy
	WHERE flex_value_set_id = vg_acct_val_set_id
	AND vg_child_acct BETWEEN child_flex_value_low AND child_flex_value_high
	ORDER BY parent_flex_value;

   vl_plcode	Fv_Facts_Attributes.public_law_code%TYPE;
   vl_advflag	Fv_Facts_Attributes.advance_flag%TYPE;
   vl_transflag	Fv_Facts_Attributes.transfer_flag%TYPE;
   vl_govtflag	Fv_Facts_Attributes.govt_non_govt%TYPE;
   vl_found_flag VARCHAR2(1) ;
   vl_cnt       NUMBER;
   vl_process_type VARCHAR2(10);
   vl_parent    Fnd_Flex_Value_Hierarchies.parent_flex_value%TYPE;

   l_module_name         VARCHAR2(200) ;

BEGIN

l_module_name :=  g_module_name ||
                                      'Determine_Processing_Type ';
vl_found_flag := 'N';



 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'                   IN DETERMINE_PROCESSING_TYPE PROCEDURE'||
		' with acct '||vg_child_acct);
         END IF;

   OPEN get_attrcnt_csr(vg_child_acct);
   FETCH get_attrcnt_csr INTO vl_cnt;
   CLOSE get_attrcnt_csr;

   IF (vl_cnt = 1) THEN				-- child cnt
      -- Case when the processing acct has attributes in Facts Attributes table
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'                   CASE: WHEN PROCESSING ACCT IS IN '||
		'Facts Attributes Table');
         END IF;
      OPEN get_attributes_csr(vg_child_acct);
      FETCH get_attributes_csr INTO
	  vl_plcode,vl_advflag,vl_transflag,vl_govtflag;
      CLOSE get_attributes_csr;

      vl_found_flag := 'Y';
   ELSIF (vl_cnt = 0) THEN			-- child cnt
      -- Case when the child acct has no attributes in Facts Attributes table,
      -- hence looking for the parent.
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'                   CASE: WHEN PROCESSING ACCT IS NOT IN '||
		'Facts Attributes Table, hence looking for the parent');
         END IF;
      vl_cnt := 0;
      FOR vc_parent IN get_parent_csr LOOP
        vl_parent := vc_parent.parent_flex_value;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'                   PROCESSING PARENT '||VL_PARENT);
 END IF;

	OPEN get_attrcnt_csr(vl_parent);
        FETCH get_attrcnt_csr INTO vl_cnt;
        CLOSE get_attrcnt_csr;

	IF (vl_cnt = 1) THEN			-- parent cnt
	   IF (vl_found_flag = 'N') THEN	-- found flag
		-- Case when the parent has attributes, the first parent.
      		OPEN get_attributes_csr(vl_parent);
   	   	FETCH get_attributes_csr INTO
	  		vl_plcode,vl_advflag,vl_transflag,vl_govtflag;
      		CLOSE get_attributes_csr;

      		vl_found_flag := 'Y';
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'                   CASE: WHEN PARENT '||
				'has attributes in FACTS Table');
                 END IF;
	   ELSE					-- found flag
		-- Case when more than one parent is in the Facts Attributes table.
		-- In this case, the processing type should be 0,since we do not
		-- know which acct to consider for getting the attributes.
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'                   CASE: WHEN MORE THAN ONE '||
				'parent has attributes in FACTS table');
                 END IF;
      		vl_found_flag := 'N';
		EXIT;
 	   END IF;				-- found flag
	END IF;					-- parent cnt
      END LOOP;

   END IF;					-- child cnt

   IF (vl_found_flag = 'Y') THEN
      -- Found attributes either for the processing acct or it's parent.
      IF ((vl_plcode = 'Y') OR (vl_advflag = 'Y') OR
	   (vl_transflag = 'Y') ) THEN
   	   p_type := 2;
      ELSIF( (vl_govtflag IN ('F','Y')) AND (vg_factsi_attr_exists = 'Y')) THEN
	   p_type := 1;
      ELSE
	   p_type := 0;
      END IF;
   ELSE
     -- No attributes found for the processing acct or it's parent.
      p_type := 0;
   END IF;

   IF (p_type = 2) THEN
	vl_process_type := 'FACTS II';
   ELSIF (p_type = 1) THEN
	vl_process_type := 'FACTS I';
   ELSE
	vl_process_type := 'Regular';
   END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'                   PROCESSING BY '||VL_PROCESS_TYPE);
 END IF;

EXCEPTION
   WHEN OTHERS THEN
      vp_retcode := 2 ;
      vp_errbuf  := SQLERRM  ||' -- Error in Determine_Processing_Type procedure.' ;
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
       END IF;

      RETURN ;
END Determine_Processing_Type;

-- ------------------------------------------------------------------
--                      Procedure Insert_Balances
-- ------------------------------------------------------------------
-- Insert_Balances procedure is called from Determine_DrCr procedure.
-- This proc inserts into the Fv_Ye_Seq_Bal_Temp table.
-- ------------------------------------------------------------------
PROCEDURE Insert_Balances(ccid 		NUMBER,
			  acct 		VARCHAR2,
			  bal_amt 	NUMBER,
			  dr_cr		VARCHAR2,
			  read_flag 	VARCHAR2,
			  remaining_bal NUMBER,
			  processing_type NUMBER,
			  segs		Fnd_Flex_Ext.SegmentArray) IS

CURSOR flex_fields IS
  SELECT application_column_name
  FROM   fnd_id_flex_segments
  WHERE  id_flex_code = 'GL#'
  AND    id_flex_num = vg_coa_id
  AND  enabled_flag = 'Y'
  ORDER BY segment_num;

   vl_report_seq    NUMBER;
   vl_period_dr     NUMBER;
   vl_period_cr     NUMBER;
   l_module_name    VARCHAR2(200) ;
   vl_segments      Fnd_Flex_Ext.SegmentArray;
   vl_segnum        NUMBER;
   l_column_name    fnd_id_flex_segments.application_column_name%TYPE;
   l_n_segments     NUMBER ;

BEGIN
    l_module_name   :=  g_module_name || 'Insert_Balances ';
   -- Get the period net dr, period net cr
   BEGIN
      SELECT DECODE(dr_cr,'D',ABS(bal_amt),0)
      INTO vl_period_dr
      FROM DUAL;

      SELECT DECODE(dr_cr,'D',0,ABS(bal_amt))
      INTO vl_period_cr
      FROM DUAL;
   EXCEPTION
      WHEN OTHERS THEN
       	vp_retcode := 2 ;
       	vp_errbuf  := SQLERRM  ||' -- Error in Insert_Balances procedure,'||
		'while deriving the period_net_dr and period_net_cr.' ;
	RETURN;

   END;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'                     IN INSERT_BALANCES PROCEDURE,'||
		'inserting the following:');
         END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'                     CCID:'||TO_CHAR(CCID)||' ACCT:'||ACCT||
		' balance read flag: '||read_flag);
         END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'                     PERIOD NET DR:'||TO_CHAR(VL_PERIOD_DR)||
		' period net cr:'|| TO_CHAR(vl_period_cr)||
		' remaining balance:'||TO_CHAR(remaining_bal) );
         END IF;

   -- Get the report sequence
   BEGIN
      SELECT Fv_Ye_Seq_Bal_Temp_S.NEXTVAL
      INTO vl_report_seq
      FROM DUAL;
   EXCEPTION
      WHEN OTHERS THEN
       	vp_retcode := 2 ;
       	vp_errbuf  := SQLERRM  ||' -- Error in Determine_DrCr procedure,'||
		'while deriving the vl_report_seq.' ;
	RETURN;
   END;


  --  map the segment values to the right segments

  -- Insert Null values for the Segments initially

   FOR i in 1..30
   LOOP
        vl_segments(i) := NULL;
   END LOOP;

  l_n_segments := 0;

  FOR flex_fields_rec IN flex_fields
  LOOP

    l_n_segments  := l_n_segments + 1;
    l_column_name := flex_fields_rec.application_column_name;
    vl_segnum     := SUBSTR(l_column_name,8) ;
    vl_segments(vl_segnum) := segs(l_n_segments);

  END LOOP;



   -- Insert into the Temp table.
   INSERT INTO Fv_Ye_Seq_Bal_Temp(
	code_combination_id,
        group_id,
        SEQUENCE,
        account_seg,
        balance_seg,
        period_net_dr,
        period_net_cr,
        bal_seq_amt,
        period_name,
        currency_code,
        fiscal_year,
        balance_read_flag,
        set_of_books_id,
	treasury_symbol_id,
	account_flag,
	report_sequence,
	processing_type,
        segment1,segment2,segment3,segment4,segment5,
        segment6,segment7,segment8,segment9,segment10,
        segment11,segment12,segment13,segment14,
        segment15,segment16,segment17,segment18,
        segment19,segment20,segment21,segment22,
        segment23,segment24,segment25,segment26,
        segment27,segment28,segment29,segment30)
   VALUES
	(ccid,
	vg_group_id,
	vg_seq,
	acct,
	vg_fund_value,
	vl_period_dr,
	vl_period_cr,
	remaining_bal,
	vg_closing_period,
	vg_currency,
	vp_closing_fyr,
	read_flag,
	vg_sob_id,
	vg_trsymbol_id,
	vg_acct_flag,
	vl_report_seq,
	processing_type,
vl_segments(1),vl_segments(2),vl_segments(3),vl_segments(4),vl_segments(5),
vl_segments(6),vl_segments(7),vl_segments(8),vl_segments(9),vl_segments(10),
vl_segments(11),vl_segments(12),vl_segments(13),vl_segments(14),vl_segments(15),
vl_segments(16),vl_segments(17),vl_segments(18),vl_segments(19),vl_segments(20),
vl_segments(21),vl_segments(22),vl_segments(23),vl_segments(24),vl_segments(25),
vl_segments(26),vl_segments(27),vl_segments(28),vl_segments(29),vl_segments(30));
EXCEPTION
   WHEN OTHERS THEN
      vp_retcode := 2 ;
      vp_errbuf  := SQLERRM  ||' -- Error in Insert_Balances procedure.' ;
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
       END IF;

      RETURN ;

END Insert_Balances;

-- ------------------------------------------------------------------
--                      Procedure Update_Closing_Status
-- ------------------------------------------------------------------
-- Update_Closing_Status procedure is called from Get_Fund_Value procedure.
-- When submit journal import is Y, this proc closes all the pending
-- requisitions, if any exists,for the fund that is being processed.
-- ------------------------------------------------------------------
PROCEDURE Update_Closing_Status IS

   CURSOR get_closereq_cur IS
	SELECT ffp.close_requisitions
   	FROM fv_fund_parameters ffp, fv_treasury_symbols fts
   	WHERE fts.treasury_symbol = vg_trsymbol
   	AND ffp.fund_value = vg_fund_value
   	AND ffp.treasury_symbol_id = fts.treasury_symbol_id
   	AND ffp.set_of_books_id = vg_sob_id
    AND fts.close_requisitions = vp_closing_method;

   -- Variable declarations for Native Dynamic SQL
   TYPE t_refcur IS REF CURSOR;
   vl_dist_retcur  t_refcur;
   vl_dist_select  VARCHAR2(2000);

   vl_rec_found_flag   	VARCHAR2(1) ;
   vl_close_req   	Fv_Fund_Parameters.close_requisitions%TYPE;
   vl_distr_id      	Po_Req_Distributions_All.distribution_id%TYPE;
   vl_line_id       	Po_Req_Distributions_All.requisition_line_id%TYPE;
   vl_req_num       	Po_Requisition_Headers_All.segment1%TYPE;
   vl_prev_line_id  	Po_Req_Distributions_All.requisition_line_id%TYPE ;
   vl_prt_line_id  	Po_Req_Distributions_All.requisition_line_id%TYPE ;
   vl_ctr 		NUMBER ;
   vl_index		BINARY_INTEGER;
   vl_no_of_rows	NUMBER;
   vl_last_row		NUMBER;
   vl_lines_count	NUMBER;
   vl_header_id     	Po_Requisition_Headers_All.requisition_header_id%TYPE;
   vl_prev_header_id    Po_Requisition_Headers_All.requisition_header_id%TYPE ;
   vl_prt_hdr_id     	Po_Requisition_Headers_All.requisition_header_id%TYPE;
   vl_head_ctr      	NUMBER ;

   TYPE t_lines_table IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
   vt_lines         t_lines_table;

   TYPE t_headers_table IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
   vt_headers       t_headers_table;

   CURSOR get_lcount_cur IS
	SELECT COUNT(*)
	FROM Po_Req_Distributions_All
	WHERE requisition_line_id = vt_lines(vl_index)
	AND gl_closed_date IS NULL;

   CURSOR get_header_cur IS
	SELECT DISTINCT requisition_header_id
	FROM Po_Requisition_Lines_All
	WHERE requisition_line_id = vt_lines(vl_index);

   CURSOR get_hcount_cur IS
	SELECT COUNT(*)
	FROM Po_Requisition_Lines_All
	WHERE requisition_header_id = vt_headers(vl_index)
	AND (closed_code <> 'FINALLY CLOSED' OR closed_code IS NULL);
	--AND NVL(closed_code, 'XXX') <> 'FINALLY CLOSED';

   l_module_name         VARCHAR2(200)  ;

BEGIN
    l_module_name  := g_module_name || 'Update_Closing_Status  ';
    vl_rec_found_flag  := 'N';
    vl_prev_line_id   := 0;
    vl_ctr  := 0;
    vl_prev_header_id := 0;
    vl_head_ctr := 0;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       IN THE UPDATE_CLOSING_STATUS PROCEDURE.....');
 END IF;

   -- Get the close requisition
   OPEN get_closereq_cur;
   FETCH get_closereq_cur INTO vl_close_req;
   CLOSE get_closereq_cur;

 /* IF (vl_close_req = 'N') THEN				-- vl_close_req
 	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       CLOSE REQUISITIONS = P');
	END IF;
	RETURN;
   ELSE							-- vl_close_req*/
   	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       CLOSE REQUISITIONS = ' || vl_close_req );
	END IF;

   IF (vl_close_req = vp_closing_method)  THEN

        -- Build the select statement to get the distribution details
	vl_dist_select := 'SELECT po.distribution_id,
         		   po.requisition_line_id, ph.segment1
          		FROM Po_Req_Distributions_All po, gl_code_combinations gcc,
		           Po_Requisition_Lines_All pl, Po_Requisition_Headers_All ph
          		WHERE po.gl_closed_date IS NULL
          		AND gcc.code_combination_id = po.code_combination_id
          		AND gcc.chart_of_accounts_id = :coa
          		AND po.set_of_books_id = :sob
          		AND gcc.'||vg_bal_segment|| ' = :fund_value'||
			' AND ph.authorization_status = '||''''||'APPROVED'||''''||
			' AND po.requisition_line_id = pl.requisition_line_id
			AND pl.requisition_header_id = ph.requisition_header_id
			AND pl.line_location_id IS NULL
			AND po.gl_encumbered_date <= :end_date' ;
	--Fv_Utility.Debug_Mesg(vl_dist_select);

	-- Open the ref cursor
	OPEN vl_dist_retcur FOR vl_dist_select USING vg_coa_id,vg_sob_id,
			vg_fund_value,vg_end_date;
	LOOP						-- distrdetails loop
	   FETCH vl_dist_retcur INTO vl_distr_id, vl_line_id,vl_req_num;

	   IF vl_dist_retcur%FOUND THEN		-- details found
	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       PROCESSING THE REQUISITION NUMBER '||
			vl_req_num||' with requisition line id '
			||TO_CHAR(vl_line_id)||' and the distribution id '
			||TO_CHAR(vl_distr_id) );
	        END IF;
		vl_rec_found_flag := 'Y';

	        -- If vl_prev_line_id = vl_line_id, then this is the scenario
		-- when for the same requisition line we have multiple distributions.
		-- In this case,just go ahead and update the Po_Req_Distributions_All table
		-- for the new distribution_id,without inseritng into the table.
		IF (vl_prev_line_id <> vl_line_id) THEN  -- vl_prev_line_id
		    -- insert into vt_lines table
		    vt_lines(vl_ctr) := vl_line_id;
		    vl_ctr := vl_ctr + 1;

		    -- Copy the vl_line_id to vl_prev_line_id
		    vl_prev_line_id  := vl_line_id;

		END IF;					-- vl_prev_line_id

	        -- Update the Po_Req_Distributions_All table
	        UPDATE Po_Req_Distributions_All
	        SET gl_closed_date = vg_end_date
	        WHERE distribution_id = vl_distr_id;
		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       CLOSED THE DISTRIBUTION WITH '||
				'distribution_id '||TO_CHAR(vl_distr_id));
		END IF;

	   ELSE						-- details found
	        IF (vl_rec_found_flag = 'Y') THEN
		    EXIT;
	        ELSE
		    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       NO REQUISITIONS FOUND TO '||
			'be processed, where the balancing segment matches '||
			'the fund value '|| vg_fund_value);
		    END IF;
		    RETURN;
	        END IF;
	   END IF;					-- details found
	END LOOP;					-- distrdetails loop
	CLOSE vl_dist_retcur;
   END IF;						-- vl_close_req

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       BEGININNING PROCESSING FOR THE LINES....');
   END IF;
   vl_no_of_rows := vt_lines.COUNT;
   vl_last_row   := vt_lines.LAST;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       NUMBER OF ROWS:'|| TO_CHAR(VL_NO_OF_ROWS)||
		' Last Row: '||TO_CHAR(vl_Last_row));
   END IF;

   IF (vl_no_of_rows <> 0) THEN				-- vl_no_of_rows lines
      vl_index := vt_lines.FIRST;

      LOOP						-- vl_index
	-- Get the Line count
	OPEN get_lcount_cur;
	FETCH get_lcount_cur INTO vl_lines_count;
	CLOSE get_lcount_cur;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       VL_LINES_COUNT IS '||TO_CHAR(VL_LINES_COUNT));
        END IF;

	IF (vl_lines_count = 0) THEN			-- vl_lines_count
	     -- Update the Po_Requisition_Lines_All table
	     UPDATE Po_Requisition_Lines_All
	     SET closed_code = 'FINALLY CLOSED'
	     WHERE requisition_line_id = vt_lines(vl_index);

	     vl_prt_line_id := vt_lines(vl_index);
             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       CLOSED THE LINE WITH REQUISITION_LINE_ID '||
			TO_CHAR(vl_prt_line_id));
             END IF;

	     OPEN get_header_cur;
	     FETCH get_header_cur INTO vl_header_id;
	     CLOSE get_header_cur;

	     IF (vl_prev_header_id <> vl_header_id) THEN
		   -- insert into the headers table
		   vt_headers(vl_head_ctr) := vl_header_id;
		   vl_head_ctr := vl_head_ctr + 1;

		   -- assign the vl_header_id to vl_prev_header_id
		   vl_prev_header_id := vl_header_id;
	     END IF;
	END IF;						-- vl_lines_count

	IF (vl_index = vl_last_row) THEN
	     EXIT;
	END IF;
	vl_index := vl_index + 1;
      END LOOP;						-- vl_index

   ELSE							-- vl_no_of_rows lines
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       NO REQUISITION LINES FOUND TO BE PROCESSED....');
      END IF;
      RETURN;
   END IF;						-- vl_no_of_rows lines
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       ENDING PROCESSING FOR THE LINES....');
   END IF;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       BEGINNING PROCESSING FOR THE HEADERS....');
   END IF;
   vl_no_of_rows := vt_headers.COUNT;
   vl_last_row   := vt_headers.LAST;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       NUMBER OF ROWS:'|| TO_CHAR(VL_NO_OF_ROWS)||
		' Last Row: '||TO_CHAR(vl_Last_row));
   END IF;

   IF (vl_no_of_rows <> 0) THEN				-- vl_no_of_rows headers
      vl_index := vt_headers.FIRST;

      LOOP						-- headers loop
	-- Get the Header count
	OPEN get_hcount_cur;
	FETCH get_hcount_cur INTO vl_lines_count;
	CLOSE get_hcount_cur;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       VL_LINES_COUNT(HDR) IS '||
		TO_CHAR(vl_lines_count));
        END IF;

	IF (vl_lines_count = 0) THEN			-- vl_lines_count header
	     -- Update the Po_Requisition_Headers_All table
	     UPDATE Po_Requisition_Headers_All
	     SET closed_code = 'FINALLY CLOSED'
	     WHERE requisition_header_id = vt_headers(vl_index);

	     vl_prt_hdr_id := vt_headers(vl_index);
            -- IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 --FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
 --'       CLOSED THE HEADER WITH '|| 'requisition_header_id '|| TO_CHAR(vl_prt_hdr_id));
  --           END IF;
	END IF;						-- vl_lines_count header

	IF (vl_index = vl_last_row) THEN
	     EXIT;
	END IF;
	vl_index := vl_index + 1;
      END LOOP;						-- headers loop
   ELSE							-- vl_no_of_rows headers
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       NO REQUISITION HEADERS FOUND TO BE PROCESSED....');
      END IF;
   END IF;						-- vl_no_of_rows headers
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       ENDING PROCESSING FOR THE HEADERS....');
   END IF;

   vt_lines.DELETE;
   vt_headers.DELETE;
EXCEPTION
   WHEN OTHERS THEN
      vp_retcode := 2 ;
      vp_errbuf  := SQLERRM  ||' -- Error in Update_Closing_Status procedure.' ;
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
       END IF;
     RETURN ;
END Update_Closing_Status;

-- ------------------------------------------------------------------
--                      Procedure Populate_Gl_Interface
-- ------------------------------------------------------------------
-- Populate_Gl_Interface procedure is called from Main procedure.
-- When submit_journal_import =Y, this proc inserts records in gl_interface
-- table, from the temp table and runs the journal import program.
-- ------------------------------------------------------------------
PROCEDURE Populate_Gl_Interface IS
   vl_req_id       NUMBER;
   vl_call_status  BOOLEAN;
   vl_rphase       VARCHAR2(30);
   vl_rstatus      VARCHAR2(30);
   vl_dphase       VARCHAR2(30);
   vl_dstatus      VARCHAR2(30);
   vl_message      VARCHAR2(240);
   vl_period_name  VARCHAR2(50);
  vl_reference_1   VARCHAR2(280);
  vl_running_amount         NUMBER;
  vl_amount         NUMBER;
  vl_amount_dr         NUMBER;
  vl_amount_cr         NUMBER;
  vl_ccid              NUMBER(15);
  vl_ccid_cnt 	   NUMBER;
  vl_ptype   	   Fv_Ye_Seq_Bal_Temp.processing_type%TYPE;
  vl_factsi_amount NUMBER;
  vl_factsi_tempamt NUMBER;
  vl_trading_partner Fv_Facts1_Period_Balances_v.eliminations_dept%TYPE;

  vl_stmt  	   VARCHAR2(5000);
  vl_line_amount   NUMBER;
  vl_attribute_cols  VARCHAR2(2500);
  vl_dummy_cols  VARCHAR2(100);
  vl_group_by_clause VARCHAR2(1024);

  vl_public_law_code VARCHAR2(150);
  vl_advance_type    VARCHAR2(150);
  vl_trf_dept_id     VARCHAR2(150);
  vl_trf_main_acct   VARCHAR2(150);

  c_gl_line_cur      INTEGER;
  vl_fetch_lines     INTEGER;
  vl_exec_cur	     INTEGER;
  vl_column_num	     NUMBER;
  vl_gl_source       VARCHAR2(1024) ;
  posting_run_id     NUMBER;
  L_ledger_id         gl_ledgers.LEDGER_ID%type;
  interface_Ctrl_no  NUMBER;
  l_je_batch_id gl_je_batches.je_batch_id%TYPE;
  single_led_id  NUMBER;
  dummy          NUMBER;

   CURSOR journal_entries_cur IS
	SELECT
	       code_combination_id,
		account_seg,
		balance_seg,
		segment1,segment2,segment3,segment4,segment5,
		segment6,segment7,segment8,segment9,segment10,
	 	segment11,segment12,segment13,segment14,
                segment15,segment16,segment17,segment18,
                segment19,segment20,segment21,segment22,
                segment23,segment24,segment25,segment26,
                segment27,segment28,segment29,segment30,
                period_net_dr,
                period_net_cr,
		period_name ,
                balance_read_flag,
		processing_type
     	FROM Fv_Ye_Seq_Bal_Temp
        WHERE period_net_dr + period_net_cr > 0
        AND set_of_books_id = vg_sob_id
        ORDER BY report_sequence;

	CURSOR ccid_cnt_csr IS
		SELECT COUNT(*),SUM(NVL(amount,0))
		FROM Fv_Facts1_Period_Balances_v
		WHERE set_of_books_id = vg_sob_id
		AND period_num <= vg_closing_period_num
		AND period_year = vp_closing_fyr
		AND ccid = vl_ccid;


	CURSOR factsi_bal_csr IS
		SELECT SUM(NVL(amount,0)) amount,eliminations_dept,g_ng_indicator
		FROM Fv_Facts1_Period_Balances_v
		WHERE set_of_books_id = vg_sob_id
		AND period_num <= vg_closing_period_num
		AND period_year = vp_closing_fyr
		AND ccid = vl_ccid
		GROUP BY eliminations_dept,g_ng_indicator;

  CURSOR CHK_SINGLE_LEDGER_CUR IS
      SELECT max(JEH.ledger_id)
      FROM   GL_JE_HEADERS JEH
      WHERE  JEH.je_batch_id = l_je_batch_id
      GROUP BY JEH.je_batch_id
      HAVING count(distinct JEH.ledger_id) = 1;

   CURSOR CHK_ALC_EXISTS_CUR IS
      SELECT 1
      FROM   GL_JE_HEADERS JEH
      WHERE  JEH.je_batch_id = l_je_batch_id
      AND    JEH.actual_flag <> 'B'
      AND    JEH.reversed_je_header_id IS NULL
      AND EXISTS
          (SELECT 1
           FROM   GL_LEDGER_RELATIONSHIPS LRL
           WHERE  LRL.source_ledger_id = JEH.ledger_id
           AND    LRL.target_ledger_category_code = 'ALC'
           AND    LRL.relationship_type_code IN ('JOURNAL', 'SUBLEDGER')
           AND    LRL.application_id = 101
           AND    LRL.relationship_enabled_flag = 'Y'
           AND    JEH.je_source NOT IN
            (SELECT INC.je_source_name
             FROM   GL_JE_INCLUSION_RULES INC
             WHERE  INC.je_rule_set_id =
                      LRL.gl_je_conversion_set_id
             AND    INC.je_source_name = JEH.je_source
             AND    INC.je_category_name = 'Other'
             AND    INC.include_flag = 'N'
             AND    INC.user_updatable_flag = 'N'));

       l_module_name         VARCHAR2(200) ;
BEGIN
       l_module_name  := g_module_name ||
                           'Populate_Gl_Interface ';

    vl_gl_source  := '(''Budgetary Transaction'',''Year End Close'', ''Manual'')';

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   IN POPULATE_GL_INTERFACE PROCEDURE....');
 END IF;

   -- Get the interface_run_id
   vg_interface_run_id := Gl_Interface_Control_Pkg.Get_Unique_Run_Id;

   -- Get the journal group_id
   SELECT Gl_Interface_Control_S.NEXTVAL
   INTO vg_jrnl_group_id
   FROM DUAL;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   INTERFACE RUN ID: '||TO_CHAR(VG_INTERFACE_RUN_ID));
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   JOURNAL GROUP ID: '||TO_CHAR(VG_JRNL_GROUP_ID));
   END IF;

   --Insert a control record in gl_interface_control for gl_import to work
   INSERT INTO Gl_Interface_Control
        (je_source_name,
        status,
        interface_run_id,
        group_id,
        set_of_books_id)
   VALUES ('Year End Close',
        'S',
        vg_interface_run_id,
        vg_jrnl_group_id,
        vg_sob_id);

   FOR vc_journals IN journal_entries_cur
   LOOP		-- journal_entries loop
     vl_ptype := vc_journals.processing_type;
     vl_trading_partner := NULL;
     vl_ccid := vc_journals.code_combination_id;
     vl_period_name := vc_journals.period_name;
     vl_reference_1 := NULL;
     vt_segments(1) := vc_journals.segment1;
     vt_segments(2) := vc_journals.segment2;
     vt_segments(3) := vc_journals.segment3;
     vt_segments(4) := vc_journals.segment4;
     vt_segments(5) := vc_journals.segment5;
     vt_segments(6) := vc_journals.segment6;
     vt_segments(7) := vc_journals.segment7;
     vt_segments(8) := vc_journals.segment8;
     vt_segments(9) := vc_journals.segment9;
     vt_segments(10) := vc_journals.segment10;
     vt_segments(11) := vc_journals.segment11;
     vt_segments(12) := vc_journals.segment12;
     vt_segments(13) := vc_journals.segment13;
     vt_segments(14) := vc_journals.segment14;
     vt_segments(15) := vc_journals.segment15;
     vt_segments(16) := vc_journals.segment16;
     vt_segments(17) := vc_journals.segment17;
     vt_segments(18) := vc_journals.segment18;
     vt_segments(19) := vc_journals.segment19;
     vt_segments(20) := vc_journals.segment20;
     vt_segments(21) := vc_journals.segment21;
     vt_segments(22) := vc_journals.segment22;
     vt_segments(23) := vc_journals.segment23;
     vt_segments(24) := vc_journals.segment24;
     vt_segments(25) := vc_journals.segment25;
     vt_segments(26) := vc_journals.segment26;
     vt_segments(27) := vc_journals.segment27;
     vt_segments(28) := vc_journals.segment28;
     vt_segments(29) := vc_journals.segment29;
     vt_segments(30) := vc_journals.segment30;

     vl_line_amount  := 0;


     IF (vc_journals.balance_read_flag = 'N') THEN	-- balance_read_flag
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PROCESSING TO ACCOUNT ' || VC_JOURNALS.ACCOUNT_SEG);
    END IF;
        Insert_Gl_Interface_Record(vc_journals.period_net_dr,
                       vc_journals.period_net_cr, vl_reference_1,
		       vl_period_name,vl_trading_partner);

     ELSE						-- balance_read_flag
	-- If it is a from account, then check which processing to be done.
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PROCESSING FROM ACCOUNT: ' || VC_JOURNALS.ACCOUNT_SEG||
			' CCID: '||vl_ccid);
            END IF;

       IF (vl_ptype = 1) THEN		-- vl_ptype
	  -- FACTS I processing
	  -- Check if the attribute exits and there are balances in the Facts table
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FACTS I PROCESSING');
 END IF;

          vl_amount := (NVL(vc_journals.period_net_cr,0)
				- NVL(vc_journals.period_net_dr,0) );
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'AMOUNT TO BE MATCHED ' || VL_AMOUNT);
 END IF;

	  IF ((vg_factsi_attr_exists = 'Y')
			AND (vg_factsi_bal_cnt > 0)) THEN 	-- facts attr
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FACTS I ATTRIBUTE EXISTS AND THERE ARE '||
			'balances in FACTS table.');
             END IF;

		OPEN ccid_cnt_csr;
		FETCH ccid_cnt_csr INTO vl_ccid_cnt,vl_factsi_amount;
		CLOSE ccid_cnt_csr;

		IF (vl_ccid_cnt = 0) THEN			-- ccid cnt
		   -- ccid does not exist in facts table
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BALANCES WILL NOT BE CLOSED BY '||

                        'the FACTS I F/N and trading partner attributes for the '||
                        'code combination id '||vl_ccid||', since the code '||
			'combination id does not exist in Fv_Facts1_Period_Balances_v.');
                         END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TO CLOSE BY FACTS I F/N AND '||

                        'trading partner attributes for this code combination id, '||
			'delete the journal entries created by this process, '||
			'if any, run the FACTS I Interface Program with all edit '||
                        'checks passed by period '||vg_closing_period||
                        'and rerun the Year End Close Program.');
 END IF;
                   Insert_Gl_Interface_Record(vc_journals.period_net_dr,
                       vc_journals.period_net_cr, vl_reference_1,
		       vl_period_name,vl_trading_partner);
		ELSE						-- ccid cnt
		  -- ccid exists in facts table
		  IF (vl_amount <> vl_factsi_amount) THEN	-- amt matching
		      -- amount from year end table does not match with amt from
		      -- facts table.
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BALANCES WILL NOT BE CLOSED BY '||
                        'the FACTS I F/N and trading partner attributes for the '||
                        'code combination id '||vl_ccid||', since the balances '||
			'in GL does not equal to the balances in '||
			'Fv_Facts1_Period_Balances_v.');
             END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TO CLOSE BY FACTS I F/N AND '||    'trading partner attributes for this code combination id, '||
			'delete the journal entries created by this process, '||
			'if any, run the FACTS I Interface Program with all edit '||
                        'checks passed by period '||vg_closing_period||
                        'and rerun the Year End Close Program.');
                         END IF;

                      Insert_Gl_Interface_Record(vc_journals.period_net_dr,
                          vc_journals.period_net_cr, vl_reference_1,
			  vl_period_name,vl_trading_partner);
		  ELSE						-- amt matching
		      -- amount from year end table matches with amt from
		      -- facts table.
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'AMOUNT MATCHED');
 END IF;
		      FOR vc_factsi IN factsi_bal_csr LOOP		-- bal loop
			 vl_factsi_tempamt := vc_factsi.amount;
			 IF (vl_factsi_tempamt > 0) THEN
				vl_amount_dr := 0;
				vl_amount_cr := vl_factsi_tempamt;
			 ELSE
				vl_amount_dr := (-1) * vl_factsi_tempamt;
				vl_amount_cr := 0;
			 END IF;

			 vl_trading_partner := vc_factsi.eliminations_dept;

                         Insert_Gl_Interface_Record(vl_amount_dr,vl_amount_cr,
                              vl_reference_1,vl_period_name,vl_trading_partner);
		      END LOOP;						-- bal loop

		  END IF;					-- amt matching

		END IF;						-- ccid cnt

	  ELSE 							-- facts attr
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' EITHER FACTS I ATTRIBUTE DOES NOT EXISTS '||
			'or there are no balances in FACTS table.');
             END IF;
	    Insert_Gl_Interface_Record(vc_journals.period_net_dr,
			vc_journals.period_net_cr, vl_reference_1,
			vl_period_name,vl_trading_partner);
	  END IF; 						-- facts attr

       ELSIF (vl_ptype = 2) THEN		-- vl_ptype
	  -- FACTS II processing
          fv_utility.log_mesg('FACTS II processing');

          vl_amount := (NVL(vc_journals.period_net_dr,0)
				- NVL(vc_journals.period_net_cr,0) );

          -- POPULATE REFERENCE_1 column for all budgetary_transaction ccid
          vl_running_amount := 0;

	---------------------------------------------------------------------------------------
	vl_attribute_cols := NULL;
	vl_dummy_cols     := NULL;

	-- Populate attribute columns for FACTS II records
	-- Build the attribute columns clause

        IF vg_public_law_attribute IS NOT NULL
          THEN
           vl_attribute_cols := vl_attribute_cols||', NVL(b.public_law_code, l.'||vg_public_law_attribute||') ';
   	END IF;

        IF vg_advance_type_attribute IS NOT NULL
          THEN
           vl_attribute_cols := vl_attribute_cols||', NVL(b.advance_type, l.'||vg_advance_type_attribute||') ';
        END IF;

        IF vg_trf_dept_id_attribute IS NOT NULL
          THEN
           vl_attribute_cols := vl_attribute_cols||', NVL(b.dept_id, l.'||vg_trf_dept_id_attribute||') ';
        END IF;

        IF vg_trf_main_acct_attribute IS NOT NULL
          THEN
           vl_attribute_cols  := vl_attribute_cols||', NVL(b.main_account, l.'|| vg_trf_main_acct_attribute ||') ';
        END IF;

	IF vl_attribute_cols IS NOT NULL THEN
	  vl_group_by_clause := ' GROUP BY ' || SUBSTR(vl_attribute_cols, 2);
	END IF;
	---------------------------------------------------------------------------------------
	BEGIN
           c_gl_line_cur := DBMS_SQL.OPEN_CURSOR  ;
         EXCEPTION
         WHEN OTHERS THEN
            vp_retcode := 2;
            vp_errbuf  := SQLERRM||
			  ' Open cursor error in Populate_Gl_Interface procedure.';
            RETURN;
        END ;

vl_stmt :=
' SELECT MAX(Fv_Ye_Carryforward.Convert_To_Num (l.reference_1)) reference_1 ,
                     SUM( NVL(entered_dr, 0) - NVL(entered_cr,0) ) line_amount ' ||
                     vl_attribute_cols ||
            ' FROM  gl_je_lines   l , fv_be_trx_dtls B, gl_je_headers h
              WHERE l.code_combination_id = :ccid
              AND l.je_header_id = h.je_header_id
              AND  NVL(h.je_from_sla_flag, ''N'') IN (''N'',''U'')
-- AND l.gl_sl_link_id is null
              AND  EXISTS (SELECT 1
                           FROM   gl_period_statuses glp
                           WHERE  glp.application_id = 101
                           AND    glp.set_of_books_id = :sob_id
                           AND    glp.ledger_id = :sob_id
                           AND    glp.period_year = :closing_fyr
                           AND    glp.period_name = l.period_name)
              AND  NVL(l.reference_1, ''-99'')  = TO_CHAR(b.transaction_id (+))
              AND l.status = :je_status
              AND b.set_of_books_id(+) = :sob_id
              AND h.ledger_id = :sob_id
              AND b.set_of_books_id = h.ledger_id
              '|| vl_group_by_clause ||
' UNION
SELECT MAX(xdl.SOURCE_DISTRIBUTION_ID_NUM_1) reference_1 ,
SUM( NVL(xl.entered_dr, 0) - NVL(xl.entered_cr,0) ) line_amount '
||vl_attribute_cols ||
' FROM  fv_be_trx_dtls B, xla_ae_lines xl , xla_distribution_links xdl,
gl_je_lines   l,  gl_je_headers h, gl_import_references gli
WHERE  xl.code_combination_id = :ccid
AND  xl.ae_header_id = xdl.ae_header_id
AND  xl.ae_line_num = xdl.ae_line_num
AND  xl.gl_sl_link_id = gli.gl_sl_link_id
and gli.je_batch_id = h.je_batch_id
and gli.je_header_id = h.je_header_id
and gli.je_line_num = l.je_line_num
AND  NVL(h.je_from_sla_flag, ''N'') = ''Y''
--l.gl_sl_link_id is not null
AND  l.je_header_id = h.je_header_id
AND  EXISTS (SELECT 1
FROM  gl_period_statuses glp
WHERE  glp.application_id = 101
AND  glp.set_of_books_id = :sob_id
AND  glp.period_year = :closing_fyr
AND   glp.period_name = l.period_name)
AND   NVL(xdl.SOURCE_DISTRIBUTION_ID_NUM_1, '||''''||'-99'||''''||')
= b.transaction_id (+)
AND   l.status = :je_status
AND   h.ledger_id = :sob_id
AND   b.set_of_books_id = h.LEDGER_id'
||vl_group_by_clause;



    	BEGIN
        	dbms_sql.parse(c_gl_line_cur, vl_stmt, DBMS_SQL.V7) ;
      	  EXCEPTION
          WHEN OTHERS THEN
            vp_retcode := 2;
            vp_errbuf  := SQLERRM||
                          ' Parse cursor error in Populate_Gl_Interface procedure.';
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name, vp_errbuf) ;
            RETURN;
    	END ;

        -- Bind the variables
        dbms_sql.bind_variable(c_gl_line_cur,':ccid', vl_ccid);
        dbms_sql.bind_variable(c_gl_line_cur,':sob_id', vg_sob_id);
        dbms_sql.bind_variable(c_gl_line_cur,':closing_fyr', vp_closing_fyr);
        dbms_sql.bind_variable(c_gl_line_cur,':je_status', 'P');
        dbms_sql.bind_variable(c_gl_line_cur,':sob_id', vg_sob_id);

        dbms_sql.define_column(c_gl_line_cur, 1, vl_reference_1, 280);
        dbms_sql.define_column(c_gl_line_cur, 2, vl_line_amount);

	vl_column_num := 3;

	IF vg_public_law_attribute IS NOT NULL THEN
           dbms_sql.define_column(c_gl_line_cur, vl_column_num, vl_public_law_code, 150);
	   vl_column_num := vl_column_num + 1;
	END IF;

	IF vg_advance_type_attribute IS NOT NULL THEN
           dbms_sql.define_column(c_gl_line_cur, vl_column_num, vl_advance_type, 150);
	   vl_column_num := vl_column_num + 1;
	END IF;

	IF vg_trf_dept_id_attribute IS NOT NULL THEN
           dbms_sql.define_column(c_gl_line_cur, vl_column_num, vl_trf_dept_id, 150);
	   vl_column_num := vl_column_num + 1;
           dbms_sql.define_column(c_gl_line_cur, vl_column_num, vl_trf_main_acct, 150);
	END IF;

     	BEGIN
        	vl_exec_cur := dbms_sql.EXECUTE(c_gl_line_cur);
      	 EXCEPTION
            WHEN OTHERS THEN
            vp_retcode := 2 ;
            vp_errbuf  := SQLERRM||
                          ' Execute cursor error in Populate_Gl_Interface procedure.';
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name, vp_errbuf) ;
        END ;

        LOOP

	     vl_public_law_code := NULL;
	     vl_advance_type    := NULL;
	     vl_trf_dept_id     := NULL;
	     vl_trf_main_acct   := NULL;

	     IF dbms_sql.fetch_rows(c_gl_line_cur) = 0 THEN
                EXIT;
              ELSE

                dbms_sql.column_value(c_gl_line_cur, 1, vl_reference_1);
                dbms_sql.column_value(c_gl_line_cur, 2, vl_line_amount);

	        vl_column_num := 3;

              	IF vg_public_law_attribute IS NOT NULL THEN
                 	dbms_sql.column_value(c_gl_line_cur, vl_column_num, vl_public_law_code);
	   		vl_column_num := vl_column_num + 1;
              	END IF;

              	IF vg_advance_type_attribute IS NOT NULL THEN
                 	dbms_sql.column_value(c_gl_line_cur, vl_column_num, vl_advance_type);
	   		vl_column_num := vl_column_num + 1;
              	END IF;

              	IF vg_trf_dept_id_attribute IS NOT NULL THEN
                 	dbms_sql.column_value(c_gl_line_cur, vl_column_num, vl_trf_dept_id);
	   	 	vl_column_num := vl_column_num + 1;
                 	dbms_sql.column_value(c_gl_line_cur, vl_column_num, vl_trf_main_acct);
              	END IF;

                -- vl_reference_1 := gl_record.reference_1;
                IF vl_line_amount <> 0 THEN  -- consider only non zero balance lines
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' LINE AMOUNT ' || VL_LINE_AMOUNT);
            END IF;
                    vl_running_amount := vl_running_amount + vl_line_amount;

                    vl_amount_dr := 0;
                    vl_amount_cr := 0;

                    IF vl_line_amount > 0 THEN
                         vl_amount_cr := ABS(vl_line_amount);
                     ELSE
                         vl_amount_dr := ABS(vl_line_amount);
                    END IF;

                   Insert_gl_interface_record(vl_amount_dr,vl_amount_cr,vl_reference_1,
                                  vl_period_name,vl_trading_partner, vl_public_law_code,
				  vl_advance_type, vl_trf_dept_id, vl_trf_main_acct);
                END IF;
	     END IF;
        END LOOP;

          BEGIN
                dbms_sql.close_cursor(c_gl_line_cur);
           EXCEPTION
                WHEN OTHERS THEN
                    vp_retcode := SQLCODE ;
                    VP_ERRBUF  := SQLERRM ;
                      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name, vp_errbuf) ;
                    RETURN ;
          END ;

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'AMOUNT MATCHED ' || VL_RUNNING_AMOUNT);
END IF;

         FOR facts2_ending_balance_rec IN (SELECT ffeb.ending_balance_cr,
                                                   ffeb.ending_balance_dr,
                                                   ffeb.transfer_dept_id,
                                                   ffeb.public_law,
                                                   ffeb.advance_flag,
                                                   ffeb.transfer_main_acct
                                              FROM fv_factsii_ending_balances ffeb
                                             WHERE ffeb.set_of_books_id = vg_sob_id
                                               AND ffeb.fiscal_year = vp_closing_fyr-1
                                               AND ffeb.ccid = vl_ccid) LOOP

            vl_running_amount := vl_running_amount + NVL(facts2_ending_balance_rec.ending_balance_dr, 0) - NVL(facts2_ending_balance_rec.ending_balance_cr, 0);
            Insert_gl_interface_record(facts2_ending_balance_rec.ending_balance_cr,facts2_ending_balance_rec.ending_balance_dr,
                                       NULL,
                                       vl_period_name,vl_trading_partner,
                                       facts2_ending_balance_rec.public_law,
                                       facts2_ending_balance_rec.advance_flag,
                                       facts2_ending_balance_rec.transfer_dept_id,
                                       facts2_ending_balance_rec.transfer_main_acct);
          END LOOP;


                  vl_amount_dr := 0;
                  vl_amount_cr := 0;

	  IF ABS(vl_amount) <> ABS(vl_running_amount) THEN
	    -- Bug 4546827
            -- IF (vl_amount < 0) THEN

            IF (vl_amount + vl_running_amount < 0) THEN
                vl_amount_cr := ABS(vl_amount + vl_running_amount);
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'DIFFERENCE CR AMOUNT ADDED  ' || VL_AMOUNT_CR);
END IF;
             ELSE
                 vl_amount_dr := ABS(vl_amount + vl_running_amount);
                 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'DIFFERENCE DR AMOUNT ADDED  ' || VL_AMOUNT_DR);
END IF;
             END IF;
            -- Bug 7150443. Added vl_public_law_code to the call below.
            -- Reverted the change made for above.
            Insert_gl_interface_record(vl_amount_dr , vl_amount_cr, NULL,
				       vl_period_name,vl_trading_partner);
          END IF;
    ELSE					-- vl_ptype
       Insert_Gl_Interface_Record(vc_journals.period_net_dr,
			vc_journals.period_net_cr, vl_reference_1,
			vl_period_name,vl_trading_partner);

    END IF;					-- vl_ptype
  END IF;					-- balance_read_flag
END LOOP;						-- journal_entries loop


   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   AFTER INSERTING INTO GL_INTERFACE....');
   END IF;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   CALLING THE JOURNAL IMPORT PROGRAM....');
   END IF;
   -- Submit a Concurrent request to invoke journal import

   vl_req_id := FND_REQUEST.SUBMIT_REQUEST('SQLGL',
                                    'GLLEZL',
                                     '',
                                     '',
                                     FALSE,
                                     TO_CHAR(vg_interface_run_id),
                                     TO_CHAR(vg_sob_id),
                                     'N', '', '', 'N', 'W');

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   THE REQUEST_ID IS '||VL_REQ_ID);
   END IF;

   -- if concurrent request submission failed then abort process
   IF (vl_req_id = 0) THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   JOURNAL IMPORT REQUEST NOT SUBMITTED.');
        END IF;
        vp_errbuf := 'Cannot submit journal import program';
        vp_retcode := 1;
        ROLLBACK;
        RETURN;
   ELSE
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   JOURNAL IMPORT REQUEST SUBMITTED SUCCESSFULLY.');
        END IF;
        COMMIT;
   END IF;

   -- Check status of completed concurrent program
   -- and if complete exit
   vl_call_status := Fnd_Concurrent.Wait_For_Request(
                vl_req_id, 20, 0, vl_rphase, vl_rstatus,
                vl_dphase, vl_dstatus, vl_message);

   IF (vl_call_status = FALSE) THEN
        vp_errbuf := 'Cannot wait for the status of journal import';
        vp_retcode := 1;
   END IF;

   --code to call Posting:Single Ledger program
   -- Submit a Concurrent request to invoke journal post
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   THE vp_retcode IS '||vp_retcode);
   IF (vp_post_to_gl='Y' and vp_retcode <> 1) then
begin

select je_batch_id into l_je_batch_id from gl_je_batches where group_id = vg_jrnl_group_id ;



 Update gl_je_batches
set status = 'S', posting_run_id = je_batch_id  where je_batch_id = l_je_batch_id;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    Batch ID IS '||l_je_batch_id);
  END IF;


  -- Set single_ledger_id to the journal ledger id if the batch
  -- has journals only for a single ledger which has no enabled
  -- journal or subledger RCs.
  OPEN CHK_SINGLE_LEDGER_CUR;
  FETCH CHK_SINGLE_LEDGER_CUR INTO single_led_id;
  IF CHK_SINGLE_LEDGER_CUR%NOTFOUND THEN
    single_led_id := -99;
  END IF;
  CLOSE CHK_SINGLE_LEDGER_CUR;

  IF (single_led_id <> -99) THEN
      OPEN CHK_ALC_EXISTS_CUR;
      FETCH CHK_ALC_EXISTS_CUR INTO dummy;
      IF CHK_ALC_EXISTS_CUR%FOUND THEN
        single_led_id := -99;
      END IF;
      CLOSE CHK_ALC_EXISTS_CUR;
    END IF;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   Single Ledger ID is '||single_led_id);
  END IF;

  IF (single_led_id = -99) THEN
    vl_req_id := Fnd_Request.submit_request(
    application => 'SQLGL'
    , program => 'GLPPOSS'
    , description => ''
    , sub_request => FALSE
    , argument1 => TO_CHAR(single_led_id)
    , argument2 => TO_CHAR(fnd_profile.value('GL_ACCESS_SET_ID'))
    , argument3 => vg_coa_id
    , argument4 => l_je_batch_id
    , argument5 => chr(0));

  ELSE
    vl_req_id := Fnd_Request.submit_request(
    application => 'SQLGL'
    , program => 'GLPPOSS'
    , description => ''
    , sub_request => FALSE
    , argument1 => TO_CHAR(single_led_id)
    , argument2 => TO_CHAR(fnd_profile.value('GL_ACCESS_SET_ID'))
    , argument3 => vg_coa_id
    , argument4 => l_je_batch_id
    , argument5 => chr(0));
  END IF;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   THE REQUEST_ID IS '||VL_REQ_ID);
   END IF;

   -- if concurrent request submission failed then abort process
   IF (vl_req_id = 0) THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  POSTING: SINGLE JOURNAL REQUEST NOT SUBMITTED.');
        END IF;
        vp_errbuf := 'Cannot submit posting: single journal program';
        vp_retcode := 1;
        ROLLBACK;
        RETURN;
   ELSE
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    POSTING: SINGLE JOURNAL REQUEST SUBMITTED SUCCESSFULLY.');
        END IF;
        COMMIT;
   END IF;

   -- Check status of completed concurrent program
   -- and if complete exit
   vl_call_status := Fnd_Concurrent.Wait_For_Request(
                vl_req_id, 20, 0, vl_rphase, vl_rstatus,
                vl_dphase, vl_dstatus, vl_message);

   IF (vl_call_status = FALSE) THEN
        vp_errbuf := 'Cannot wait for the status of posting: single ledger';
        vp_retcode := 1;
   END IF;
   exception
   when no_Data_found then
   null;
   when others then
   null;
   end;
   END IF; -- end IF (vp_journal_import='Y') then


   -- Clean up gl_interface table
   Cleanup_Gl_Interface;

   IF (vp_retcode <> 0) THEN
	RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
	vp_retcode := 2;
	vp_errbuf  := SQLERRM || '--Error in Populate_Gl_Interface procedure.';
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
       END IF;
	RETURN;
END Populate_Gl_Interface;

-- ------------------------------------------------------------------
--                      Procedure Cleanup_Gl_Interface
-- ------------------------------------------------------------------
-- Cleanup_Gl_Interface procedure is called from Populate_Gl_interface
-- procedure. This cleans up the gl_interface table.
-- ------------------------------------------------------------------
PROCEDURE Cleanup_Gl_Interface IS
 l_module_name         VARCHAR2(200) ;
BEGIN

  l_module_name :=  g_module_name || 'Cleanup_Gl_Interface ';

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     IN THE CLEANUP_GL_INTERFACE PROCEDURE....');
 END IF;

   -- Delete from Gl_Interface table
   DELETE FROM Gl_Interface
   WHERE user_je_source_name = 'Year End Close'
   AND ledger_id = vg_sob_id
   AND group_id = vg_jrnl_group_id;

EXCEPTION
   WHEN OTHERS THEN
	vp_retcode := 2;
	vp_errbuf  := SQLERRM || '--Error in Cleanup_Gl_Interface procedure.';
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
       END IF;

	RETURN;
END Cleanup_Gl_Interface;

-- ------------------------------------------------------------------
--                      Procedure Submit_Report
-- ------------------------------------------------------------------
-- Submit_Report procedure is called from Main procedure.
-- This procedure submits the execution report.
-- ------------------------------------------------------------------
PROCEDURE Submit_Report IS
   vl_req_id  NUMBER;
   vl_call_status  BOOLEAN;
   vl_rphase       VARCHAR2(30);
   vl_rstatus      VARCHAR2(30);
   vl_dphase       VARCHAR2(30);
   vl_dstatus      VARCHAR2(30);
   vl_message      VARCHAR2(240);
  l_module_name         VARCHAR2(200) ;

BEGIN
   l_module_name  :=  g_module_name || 'Submit_Report ';

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     IN THE SUBMIT_REPORT PROCEDURE....');
   END IF;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Parameters: LEDGER_ID: '||vg_sob_id || ', CLOSING_METHOD: '
    ||vp_closing_method||', APPROPRIATION_TIME_FRAME: '||vp_timeframe||
    ', APPROPRIATION_GROUP: '||vp_fundgroup ||', TREASURY_SYMBOL: '||vp_trsymbol||', CLOSING_FYR: '||
    vp_closing_fyr ||', CLOSING_PERIOD: '||vp_closing_num||', MODE: '||vp_mode||', POST_IN_GL: '||vp_post_to_gl);
   END IF;
   vl_req_id := Fnd_Request.Submit_Request('FV','FVXYECER','','',FALSE,
                                vg_sob_id,vp_closing_method,vp_timeframe,
                                vp_fundgroup,vp_trsymbol,vp_closing_fyr,
                                vp_closing_num,vp_mode,vp_post_to_gl);

   IF (vl_req_id = 0) THEN
	vp_retcode := 2;
	vp_errbuf  := 'Error in Submit_Report procedure while submitting the '||
			' Year End Execution Report';
	RETURN;
   ELSE
	COMMIT;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'     YEAR END EXECUTION REPORT IS SUCCESSFULLY '||
			'submitted.....');
        END IF;
   END IF;

   -- Check status of completed concurrent program
   -- and if complete exit
   vl_call_status := Fnd_Concurrent.Wait_For_Request(
                vl_req_id, 20, 0, vl_rphase, vl_rstatus,
                vl_dphase, vl_dstatus, vl_message);

   IF (vl_call_status = FALSE) THEN
        vp_errbuf := 'Cannot wait for the status of Year End Execution Report';
        vp_retcode := 1;
	RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        vp_retcode := 2;
        vp_errbuf  := SQLERRM || '--Error in Submit_Report procedure.';
        RETURN;
END Submit_Report;
---------------------------------------------------------------
  PROCEDURE insert_gl_interface_record(l_amount_dr IN NUMBER,
                                       l_amount_cr IN NUMBER,
                                       l_reference_1 IN VARCHAR2,
                                       l_period_name IN VARCHAR2,
				       l_trading_partner IN VARCHAR2,
				       l_public_law_code IN VARCHAR2,
				       l_advance_type IN VARCHAR2,
				       l_trf_dept_id IN VARCHAR2,
				       l_trf_main_acct IN VARCHAR2)

 IS

   TYPE attribtable IS TABLE OF gl_je_lines.attribute1%TYPE
      INDEX BY BINARY_INTEGER;
   vl_attribtable   attribtable ;

  vl_str VARCHAR2(3000);
  l_module_name         VARCHAR2(200) ;
  BEGIN
     l_module_name   :=  g_module_name || 'insert_gl_interface_record ';

       FOR i IN 1..20
        LOOP
          vl_attribtable(i) := NULL;
	END LOOP;

       IF vg_factsi_attribute IS NOT NULL THEN
          vl_attribtable(SUBSTR(vg_factsi_attribute, 10)) := l_trading_partner;
       END IF;

       IF vg_public_law_attribute IS NOT NULL THEN
          vl_attribtable(SUBSTR(vg_public_law_attribute, 10)) := l_public_law_code;
       END IF;

       IF vg_advance_type_attribute IS NOT NULL THEN
          vl_attribtable(SUBSTR(vg_advance_type_attribute, 10)) := l_advance_type;
       END IF;

       IF vg_trf_dept_id_attribute IS NOT NULL THEN
          vl_attribtable(SUBSTR(vg_trf_dept_id_attribute, 10))   := l_trf_dept_id;
          vl_attribtable(SUBSTR(vg_trf_main_acct_attribute, 10)) := l_trf_main_acct;
       END IF;

   vl_str := 'INSERT INTO Gl_Interface
	       (
		status, ledger_id, accounting_date, currency_code,
		date_created, created_by, actual_flag, user_je_category_name,
		user_je_source_name, entered_dr, entered_cr, group_id,
		period_name, chart_of_accounts_id,
                segment1,segment2,segment3,
		segment4,segment5,segment6,
		segment7,segment8,segment9,
		segment10,segment11,segment12,
		segment13,segment14,segment15,
		segment16,segment17,segment18,
                segment19,segment20,segment21,
		segment22,segment23,segment24,
		segment25,segment26,segment27,
		segment28,segment29,segment30,
		reference21,context,
	        attribute1, attribute2, attribute3, attribute4, attribute5,
		attribute6, attribute7, attribute8, attribute9, attribute10,
		attribute11, attribute12, attribute13, attribute14, attribute15,
		attribute16, attribute17, attribute18, attribute19, attribute20
	       )
	   VALUES
	       (
		:status, :sob_id, :end_date, :currency,
		:current_date, :user_id, :actual_flag, :user_je_category,
		:user_je_source, :amount_dr, :amount_cr, :jrnl_group_id,
		:period_name, :coa_id,
                :vt_segments_1,:vt_segments_2,:vt_segments_3,
                :vt_segments_4,:vt_segments_5,:vt_segments_6,
                :vt_segments_7,:vt_segments_8,:vt_segments_9,
		:vt_segments_10, :vt_segments_11,:vt_segments_12,
		:vt_segments_13, :vt_segments_14,:vt_segments_15,
		:vt_segments_16, :vt_segments_17,:vt_segments_18,
		:vt_segments_19, :vt_segments_20, :vt_segments_21,
		:vt_segments_22,:vt_segments_23, :vt_segments_24,
		:vt_segments_25,:vt_segments_26, :vt_segments_27,
		:vt_segments_28,:vt_segments_29, :vt_segments_30,
		:reference_1,:context,
		:attribute1, :attribute2, :attribute3, :attribute4, :attribute5,
		:attribute6, :attribute7, :attribute8, :attribute9, :attribute10,
		:attribute11, :attribute12, :attribute13, :attribute14, :attribute15,
		:attribute16, :attribute17, :attribute18, :attribute19, :attribute20
	       ) ' ;

    EXECUTE IMMEDIATE vl_str USING
		'NEW', vg_sob_id, vg_end_date, vg_currency,
		SYSDATE, Fnd_Global.user_id, 'A', 'Year End Close',
		'Year End Close', l_amount_dr, l_amount_cr, vg_jrnl_group_id,
		l_period_name, vg_coa_id,
                vt_segments(1),vt_segments(2),vt_segments(3),
                vt_segments(4),vt_segments(5),vt_segments(6),
                vt_segments(7),vt_segments(8),vt_segments(9),
		vt_segments(10),
                vt_segments(11),vt_segments(12),vt_segments(13),
                vt_segments(14),vt_segments(15),vt_segments(16),
                vt_segments(17),vt_segments(18),vt_segments(19),
		vt_segments(20),
                vt_segments(21),vt_segments(22),vt_segments(23),
                vt_segments(24),vt_segments(25),vt_segments(26),
                vt_segments(27),vt_segments(28),vt_segments(29),
		vt_segments(30),
		l_reference_1,'Global Data Elements',
		vl_attribtable(1), vl_attribtable(2), vl_attribtable(3),
		vl_attribtable(4), vl_attribtable(5), vl_attribtable(6),
		vl_attribtable(7), vl_attribtable(8), vl_attribtable(9),
		vl_attribtable(10), vl_attribtable(11), vl_attribtable(12),
	        vl_attribtable(13), vl_attribtable(14), vl_attribtable(15),
		vl_attribtable(16), vl_attribtable(17), vl_attribtable(18),
		vl_attribtable(19), vl_attribtable(20);



EXCEPTION
   WHEN OTHERS THEN
        vp_retcode := 2;
        vp_errbuf  := SQLERRM || '--Error in Insert_Gl_Interface_Record procedure.';
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         'When Others Exception ' || vp_errbuf );
       END IF;
END insert_gl_interface_record;
-----------------------------------------------------------------------------
-- ------------------------------------------------------------------
--              Procedure Check_bal_seg_value
-- ------------------------------------------------------------------
--  BSV's are not always assigned to ledgers. Therefore we should not
--  enforce BSV assignemnt if there is no BSV flex value set
--  is assigned to a ledger.
--  IF bal_seg_value_option_code column value in GL_LEDGER table is
--  'A' that means all BSV's are valid. If the column is 'I',
--   then some BSV's are valid.
--  ------------------------------------------------------------------

PROCEDURE Check_bal_seg_value( vp_fund_grp VARCHAR2,
                                   vp_time_frame VARCHAR,
                                 vp_tsymbol_id VARCHAR  ,
                                vp_sob_id NUMBER ,
                               vp_end_date DATE )
        IS
TYPE v_fund_val_blk IS TABLE OF fv_fund_parameters.fund_value%TYPE
 index by binary_integer;

V_fund_blk_tbl  v_fund_val_blk;
l_select_stmt varchar2(2500);
l_module_name         VARCHAR2(200)  ;
   vl_valid_value     VARCHAR2(1);
Type v_ref_cursor is  REF CURSOR;
v_fund_val_cursor  v_ref_cursor;
vl_invalid_fund varchar2(1);
BEGIN
  l_module_name    :=  g_module_name ||  'Check_bal_seg_value  ';
vl_invalid_fund := 'Y';
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                         l_module_name,
                        '   IN CHECK_BAL_SEG_VALUE PROCEDURE '||
        'with the following Parameters passed to the process:');
   END IF;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                         l_module_name,
                '   FUND GROUP= '||VP_FUND_GRP);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                         l_module_name,
                        '   TIME FRAME= '||VP_TIME_FRAME);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                        l_module_name,
                '   TREASURY SYMBOL ID= '||VP_TSYMBOL_ID);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                 l_module_name,
                '   SET OF BOOKS ID= '||VP_SOB_ID);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                         l_module_name,
                        '   END DATE= '||VP_END_DATE);
   END IF;

L_select_stmt :=  '  SELECT ffp.fund_value
      FROM fv_fund_parameters ffp,
               Fv_Ye_Groups fyg ,
               fv_treasury_symbols fts
    WHERE  fyg.fund_group_code    = fts.fund_group_code
         AND   fts.time_frame         = fyg.fund_time_frame
         AND   fts.treasury_symbol_id = fyg.treasury_symbol_id
         AND   fts.treasury_symbol_id = ffp.treasury_symbol_id
         AND   fyg.fund_group_code    = NVL(:fundgroup, fyg.fund_group_code)
         AND   fyg.fund_time_frame    = NVL(decode(:timeframe,''ALL'',fyg.fund_time_frame,:timeframe), fyg.fund_time_frame)
         AND   fyg.treasury_symbol = NVL(:TSYMBOLID, fyg.treasury_symbol_id)
         AND   fts.set_of_books_id    = :sob_id
         AND   fts.set_of_books_id    = fyg.set_of_books_id
               AND   fts.set_of_books_id    = ffp.set_of_books_id
               AND ((fts.expiration_date <= :end_date)
                        OR (fts.cancellation_date <= :end_date))';

EXECUTE IMMEDIATE L_SELECT_STMT BULK COLLECT INTO v_fund_blk_tbl
USING vp_fund_grp,
        vp_time_frame,
        vp_time_frame,
        vp_tsymbol_id ,
        vp_sob_id,
        vp_end_date,
         vp_end_date;

FOR I in  1 .. v_fund_blk_tbl.count
LOOP
BEGIN
      SELECT  'N'
      INTO    vl_invalid_fund
      FROM    gl_ledger_segment_values glsv
      WHERE   glsv.ledger_id = vp_sob_id
       AND     glsv.segment_type_code (+) = 'B'
      AND     NVL(glsv.status_code (+), 'X') <> 'I'
      AND     NVL(glsv.start_date (+),TO_DATE('1950/01/01','YYYY/MM/DD'))
               <= NVL(sysdate,TO_DATE('9999/12/31','YYYY/MM/DD'))
      AND     NVL(glsv.end_date (+),TO_DATE('9999/12/31','YYYY/MM/DD'))
               >= NVL(sysdate, TO_DATE('1950/01/01','YYYY/MM/DD'))
      AND     glsv.segment_value (+)  = v_fund_blk_tbl(i);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF vl_invalid_fund = 'Y' THEN
FV_UTILITY.LOG_MESG('The  below fund values are not valid balance  segment
values for the Ledger:');
  End if;
        vl_invalid_fund := 'W' ;
        FV_UTILITY.LOG_MESG('');
         FV_UTILITY.LOG_MESG(v_fund_blk_tbl(i));
END;
END LOOP;
EXCEPTION
   WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||' -- Error in Check Check_bal_seg_value procedure.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                                 l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;
        RETURN ;
END Check_bal_seg_value;

BEGIN
  g_module_name  := 'fv.plsql.Fv_Ye_Close.';
 vg_factsi_attr_exists := 'N';
 vp_retcode := 0   ;


END Fv_Ye_Close;


/
