--------------------------------------------------------
--  DDL for Package Body FV_FACTS_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FACTS_TRANSACTIONS" AS
    /* $Header: FVFCPROB.pls 120.89.12010000.8 2010/03/31 12:25:26 yanasing ship $ */
    --  ========================================================================
    --              Parameters
    --  ========================================================================
    g_module_name       VARCHAR2(100);
    vp_facts_rep_show   VARCHAR2(2);
    vp_errbuf       	VARCHAR2(1000)      ;
    vp_retcode      	NUMBER          ;
    vp_set_of_books_id  gl_sets_of_books.set_of_books_id%TYPE  ;
    vp_report_fiscal_yr NUMBER(4)       ;
    vp_report_qtr       NUMBER(1)       ;
    vp_treasury_symbol  fv_treasury_symbols.treasury_symbol%TYPE ;
    vp_run_mode     	VARCHAR2(1)         ;
    vp_currency_code    VARCHAR2(15)        ;
    vp_contact_fname    VARCHAR2(20)        ;
    vp_contact_lname    VARCHAR2(30)        ;
    vp_contact_phone    VARCHAR2(10)        ;
    vp_contact_extn 	VARCHAR2(5)         ;
    vp_contact_email    VARCHAR2(50)        ;
    vp_contact_fax  	VARCHAR2(10)        ;
    vp_contact_maiden   VARCHAR2(25)        ;
    vp_supervisor_name  VARCHAR2(40)        ;
    vp_supervisor_phone VARCHAR2(10)        ;
    vp_supervisor_extn  VARCHAR2(5)         ;
    vp_agency_name_1    VARCHAR2(40)        ;
    vp_agency_name_2    VARCHAR2(40)        ;
    vp_address_1        VARCHAR2(40)        ;
    vp_address_2        VARCHAR2(40)        ;
    vp_city     	VARCHAR2(25)        ;
    vp_state        	VARCHAR2(2)         ;
    vp_zip      	VARCHAR2(10)        ;
    --  ========================================================================
    --              FACTS Attributes
    --  ========================================================================
    va_cohort               VARCHAR2(2) ;
    va_legis_ind_val        VARCHAR2(1) ;
    -- Newly added for the edit check 13 and 14 enhancement.
    va_pya_ind_val          VARCHAR2(1) ;
    va_balance_type_val     VARCHAR2(1) ;
    va_balance_type_flag    VARCHAR2(1) ;
    va_advance_flag         VARCHAR2(1) ;
    va_transfer_ind         VARCHAR2(1) ;
    va_def_indef_val        VARCHAR2(1) ;
    va_public_law_code_flag VARCHAR2(1) ;
    va_def_indef_flag       VARCHAR2(1) ;
    va_appor_cat_flag       VARCHAR2(1) ;
    va_authority_type_flag  VARCHAR2(1) ;
    va_reimburseable_flag   VARCHAR2(1) ;
    va_public_law_code_val  VARCHAR2(7) ;
    va_appor_cat_val        VARCHAR2(1) ;
    va_appor_cat_b_dtl      VARCHAR2(3)     ;
    va_availability_flag    VARCHAR2(1) ;
    va_authority_type_val   VARCHAR2(1) ;
    va_reimburseable_val    VARCHAR2(1) ;
    va_bea_category_flag    VARCHAR2(1) ;
    va_appor_cat_b_txt      VARCHAR2(25)    ;
    va_transaction_partner_val  VARCHAR2(1) ;
    va_bea_category_val         VARCHAR2(5) ;
    va_function_flag            VARCHAR2(1) ;
    va_borrowing_source_flag    VARCHAR2(1) ;
    va_def_liquid_flag          VARCHAR2(1) ;
    va_deficiency_val           VARCHAR2(1) ;
    va_borrowing_source_val     VARCHAR2(5) ;
    va_legis_ind_flag           VARCHAR2(1) ;
    va_pya_ind_flag             VARCHAR2(1) ;
    va_budget_function          VARCHAR2(3) ;
    va_deficiency_flag          VARCHAR2(1) ;
    va_advance_type_val         VARCHAR2(1) ;
    va_transfer_dept_id         VARCHAR2(2) ;
    va_transfer_main_acct       VARCHAR2(4) ;

    va_pl_code_col		VARCHAR2(25);
    va_advance_type_col		VARCHAR2(25);
    va_tr_dept_id_col		VARCHAR2(25);
    va_tr_main_acct_col		VARCHAR2(25);
    va_prn_num                  VARCHAR2(100);
    va_prn_txt                  VARCHAR2(100);

    --  ========================================================================
    --              Other GLOBAL Variables
    --  ========================================================================
    v_period_num        gl_period_statuses.period_num%TYPE  ;
    --v_debug varchar2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
    v_year_gtn2001      BOOLEAN ;
    v_treasury_symbol_id    fv_treasury_symbols.treasury_symbol_id%TYPE ;
    v_chart_of_accounts_id  gl_code_combinations.chart_of_accounts_id%TYPE ;
    v_acc_val_set_id        fnd_flex_value_sets.flex_value_set_id%TYPE ;
    v_bal_seg_name      VARCHAR2(20);
    v_acc_seg_name      VARCHAR2(20);
    v_fyr_segment_name  VARCHAR2(20);
    v_time_frame        fv_treasury_symbols.time_frame%TYPE ;
    v_financing_acct    fv_facts_federal_accounts.financing_account%TYPE ;
    v_cohort_seg_name   VARCHAR2(20)    ;
    v_period_name       gl_period_statuses.period_name%TYPE ;
    v_period_start_dt       DATE        ;
    v_period_end_dt         DATE        ;
    v_begin_period_name     gl_period_statuses.period_name%TYPE ;
    v_begin_period_start_dt DATE        ;
    v_begin_period_end_dt   DATE        ;
    v_begin_period_num      gl_period_statuses.period_num%TYPE ;
    v_cohort_select         VARCHAR2(20)    ;
    v_fiscal_yr             VARCHAR2(25);
    v_dummy_cohort          VARCHAR2(25);
    v_acct_attr_flag        VARCHAR2(1) ;
    v_record_category       fv_facts_temp.fct_int_record_category%TYPE  ;
    v_sgl_acct_num          fv_facts_ussgl_accounts.ussgl_account%TYPE ;
    v_amount                NUMBER      ;
    v_year_budget_auth      VARCHAR2(3);
    v_tbal_fund_value       fv_fund_parameters.fund_value%TYPE ;
    v_acct_num              fv_Facts_attributes.facts_acct_number%TYPE ;
    v_tbal_indicator        fv_facts_temp.tbal_indicator%TYPE  ;
    v_period_activity       NUMBER;
    v_edit_check_code       NUMBER ;
    --SF 133 enhancement
    --v_g_edit_check_code     NUMBER(15);
    v_cohort_where          VARCHAR2(120)   ;
    v_begin_amount          NUMBER      ;
    v_prn_prg_seg_name      VARCHAR2(20)    ;
    v_catb_prg_seg_name          VARCHAR2(20)    ;

    v_facts_attributes_setup BOOLEAN ;

    v_catb_rc_flag         VARCHAR2(1);
    v_catb_rc_header_id    NUMBER;
    v_funds_count      BINARY_INTEGER;

    v_prn_program_value    VARCHAR2(30);
    v_prn_rc_flag         VARCHAR2(1);
    v_prn_rc_header_id    NUMBER;

   v_catb_program_value    VARCHAR2(30);
 v_catb_prg_val_set_id        fnd_flex_value_sets.flex_value_set_id%TYPE ;
 v_prn_prg_val_set_id        fnd_flex_value_sets.flex_value_set_id%TYPE ;
    error_code           BOOLEAN;
    error_message        VARCHAR2(600);


    TYPE segment_rec IS RECORD
    (
      segment VARCHAR2(10),
      fund_value VARCHAR2(25),
      prc_flag   VARCHAR2(1),
      prc_header_id NUMBER,
      code_type VARCHAR2(1)
    );

    TYPE segment_tab IS TABLE OF segment_rec INDEX BY BINARY_INTEGER;
    v_segs_array    segment_tab;

    --  ========================================================================
    --              FACTS File Constants
    --  ========================================================================
    vc_fiscal_yr              VARCHAR2(4);
    vc_dept_regular           VARCHAR2(2);
    vc_dept_transfer          VARCHAR2(2);
    vc_rpt_fiscal_yr          VARCHAR2(4);
    vc_atb_seq_num            VARCHAR2(3);
    vc_main_account           VARCHAR2(4);
    vc_sub_acct_symbol        VARCHAR2(3);
    vc_maf_seq_num            VARCHAR2(3);
    vc_record_indicator       VARCHAR2(1);
    vc_transfer_to_from       VARCHAR2(1);
    vc_current_permanent_flag VARCHAR2(1);
    vc_rpt_fiscal_month       VARCHAR2(2);

--------------------------------------------------------------------------------
--          Procedures used in the FACTS II Process
--------------------------------------------------------------------------------
PROCEDURE load_treasury_symbol_id;
PROCEDURE purge_facts_transactions;
PROCEDURE get_qualifier_segments;
PROCEDURE get_treasury_symbol_info;
PROCEDURE get_period_info;
PROCEDURE get_ussgl_acct_num (acct_num           IN  VARCHAR2,
             		      sgl_acct_num       OUT NOCOPY VARCHAR2,
                              exception_category OUT NOCOPY VARCHAR2);
PROCEDURE create_facts_record;
PROCEDURE load_facts_attributes (acct_num VARCHAR2,
                 		 fund_val VARCHAR2,
				 ve_amount number);
PROCEDURE get_ussgl_info (ussgl_acct_num  VARCHAR2,
                          enabled_flag   OUT NOCOPY VARCHAR2,
                          reporting_type OUT NOCOPY VARCHAR2);
PROCEDURE get_account_type (acct_num  VARCHAR2,
                             acct_type OUT NOCOPY VARCHAR2);
PROCEDURE get_sgl_parent(acct_num     VARCHAR2,
                         sgl_acct_num OUT NOCOPY VARCHAR2);
PROCEDURE process_facts_transactions;
PROCEDURE calc_balance (fund_value       VARCHAR2,
         		acct_num         VARCHAR2,
         		period_num       NUMBER,
         		period_year      NUMBER,
         		balance_type     VARCHAR2,
         		fiscal_year      VARCHAR2,
         		amount           OUT NOCOPY NUMBER,
         		period_activity  OUT NOCOPY NUMBER);
PROCEDURE get_program_segment(v_fund_value VARCHAR2);
PROCEDURE build_appor_select (acct_number VARCHAR2,
                	      fund_value  VARCHAR2,
                	      fiscal_year VARCHAR2,
                	      appor_period VARCHAR2,
                	      select_stmt OUT NOCOPY VARCHAR2);
PROCEDURE get_segment_text(p_program   VARCHAR2,
                                p_prg_val_set_id IN  NUMBER,
                                p_seg_txt OUT NOCOPY VARCHAR2);
PROCEDURE default_processing(vl_fund_value varchar2,
                 	     vl_acct_num varchar2,
                             rec_cat varchar2 := 'R',
 			     vb_amount number,
 			     ve_amount number);

PROCEDURE facts_rollup_records;
PROCEDURE check_prc_map_seg(p_treasury_symbol_id IN NUMBER,
		            p_sob_id IN NUMBER,
			    p_fund_value OUT NOCOPY VARCHAR2,
		            p_catb_status OUT NOCOPY VARCHAR2,
                            p_prn_status OUT NOCOPY VARCHAR2);
PROCEDURE get_prc_val(p_catb_program_val IN VARCHAR2,
                      p_catb_rc_val OUT NOCOPY VARCHAR2,
                      p_catb_rc_desc OUT NOCOPY VARCHAR2,
                      p_catb_exception OUT NOCOPY NUMBER,
                      p_prn_program_val IN VARCHAR2,
                      p_prn_rc_val OUT NOCOPY VARCHAR2,
                      p_prn_rc_desc OUT NOCOPY VARCHAR2,
                      p_prn_exception OUT NOCOPY NUMBER);
--------------------------------------------------------------------------------
-- FACTS2 SUBMISSION PROCEDURE
--------------------------------------------------------------------------------
PROCEDURE submit(errbuf OUT NOCOPY varchar2,
                 retcode OUT NOCOPY number,
                 p_ledger_id IN NUMBER)  IS

-- Submits concurrent request FVFCTTRC

l_module_name           VARCHAR2(200);
sob 			NUMBER(15);
rphase 		        VARCHAR2(80);
rstatus			VARCHAR2(80);
dphase 			VARCHAR2(80);
dstatus 		VARCHAR2(80);
message 		VARCHAR2(80);
l_call_status 		BOOLEAN;
req_id          	NUMBER;
submitted_TS        	NUMBER := 0;
vl_fiscalyear_count     NUMBER;

vl_prc_map_count        NUMBER := 0;
vl_prc_no_code_count    NUMBER := 0;
vl_catb_rc_map_status       VARCHAR2(15);
vl_prn_rc_map_status        VARCHAR2(15);
vl_fund                 fv_fund_parameters.fund_value%TYPE;

TYPE g_request_ids IS RECORD (request_id NUMBER) ;

TYPE g_request_ids_type IS TABLE OF g_request_ids
                           INDEX BY BINARY_INTEGER;
l_request_ids  g_request_ids_type;
l_counter NUMBER := 1;
l_flag NUMBER;
CURSOR facts_record IS
SELECT  fv_facts_submission.rowid,
    fv_facts_submission.Set_Of_Books_Id  ,
    fv_facts_submission.Run_Mode,
    fv_treasury_symbols.Treasury_Symbol,
    fv_facts_submission.rep_fyr ,
    fv_facts_submission.rep_period_num,
    fv_facts_submission.first_name,
    fv_facts_submission.last_name,
    fv_facts_submission.phone_no,
    fv_facts_submission.phone_ext,
    fv_facts_submission.email_address,
    fv_facts_submission.fax_num ,
    fv_facts_submission.mothers_m_name  ,
    fv_facts_submission.supervisor_name ,
    fv_facts_submission.supervisor_phone,
    fv_facts_submission.supervisor_ext   ,
    fv_facts_submission.agency_name_1   ,
    fv_facts_submission.agency_name_2   ,
    fv_facts_submission.address_1   ,
    fv_facts_submission.address_2   ,
    fv_facts_submission.city        ,
    fv_facts_submission.state       ,
    fv_facts_submission.zip ,
    fv_facts_submission.currency_code,
    fv_facts_submission.treasury_symbol_id
FROM fv_facts_submission ,
     fv_treasury_symbols
WHERE submit_flag = 'Y'
AND fv_treasury_symbols.set_of_books_id = sob
AND fv_facts_submission.set_of_books_id = sob
AND fv_facts_submission.treasury_symbol_id =
		fv_treasury_symbols.treasury_symbol_id;


BEGIN
  retcode := 0;
  l_module_name := g_module_name || 'submit';
  sob 	:= p_ledger_id;

   SELECT count(*)
   INTO   vl_fiscalyear_count
   FROM   fv_pya_fiscalyear_map
   WHERE  set_of_books_id = sob;

   -- Check whether program reporting code mapping has
   -- been done for set of books. If not, then write error
   -- message and exit process.
   SELECT count(*)
   INTO   vl_prc_map_count
   FROM   fv_facts_prc_hdr
   WHERE  set_of_books_id = sob;

  -- Check whether code Type is updated
  -- for the existing data. If not, error out the process.

   SELECT count(1)
    INTO   vl_prc_no_code_count
    FROM   fv_facts_prc_hdr
    WHERE  set_of_books_id = sob
      AND  code_type IS NULL ;

   IF vl_fiscalyear_count > 0 THEN
     IF vl_prc_map_count > 0 THEN
            IF vl_prc_no_code_count > 0 THEN
        errbuf:= 'Reporting Code Type has not been updated for existing ' ||
                'Records. Please update the records and resubmit!';
         retcode := -1;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,errbuf);
        RETURN;
       END IF;

      FOR crec IN facts_record
        LOOP -- 1
          LOOP -- 2

            -- Check whether a segment mapping exists for all
            -- funds of the treasury symbol. If not, then write
            -- a log message and continue processing of the next
	    -- treasury symbol.
            check_prc_map_seg(crec.treasury_symbol_id,
                              crec.set_of_books_id,
			      vl_fund, vl_catb_rc_map_status,vl_prn_rc_map_status);



            IF retcode <> 0 THEN
              RETURN;
            END IF;

            -- If no prc mapping found for the treasury symbol,
            -- then update submission form with the proper status,
            -- skip processing for that treasury symbol and
            -- continue with the next treasury symbol, if any.


           IF vl_catb_rc_map_status = 'FAIL' AND vl_prn_rc_map_status = 'FAIL' THEN

               FV_UTILITY.LOG_MESG(
                        'No program  reporting code mapping found for'||
                         ' Treasury Symbol: '||crec.treasury_symbol||
                         ' and Fund Value: '||vl_fund);

               UPDATE fv_facts_submission
               SET submitted_by = fnd_global.user_name,
                   facts2_status = 'NO PRC MAPPED',
                   submit_flag = 'N'
               WHERE rowid = crec.rowid;
               retcode := -1;
               COMMIT; EXIT;

            ELSIF vl_catb_rc_map_status = 'FAIL' THEN

               FV_UTILITY.LOG_MESG(
                        'No Category B  reporting code mapping found for'||
                         ' Treasury Symbol: '||crec.treasury_symbol||
                         ' and Fund Value: '||vl_fund);

               UPDATE fv_facts_submission
               SET submitted_by = fnd_global.user_name,
                   facts2_status = 'NO CATB PRC MAPPED',
                   submit_flag = 'N'
               WHERE rowid = crec.rowid;
               retcode := -1;
               COMMIT;

               EXIT; -- go to next treasury symbol

            ELSIF vl_prn_rc_map_status = 'FAIL' THEN

               FV_UTILITY.LOG_MESG(
                        'No Program Category Number reporting code mapping found for'||
                         ' Treasury Symbol: '||crec.treasury_symbol||
                         ' and Fund Value: '||vl_fund);

               UPDATE fv_facts_submission
               SET submitted_by = fnd_global.user_name,
                   facts2_status = 'NO PRN PRC MAPPED',
                   submit_flag = 'N'
               WHERE rowid = crec.rowid;
               retcode := -1;
               COMMIT; EXIT;

             ELSE
               req_id := FND_REQUEST.SUBMIT_REQUEST(
               'FV',
               'FVFCTTRC',
               '','',
               FALSE,
               crec.Set_Of_Books_Id,
               crec.Treasury_Symbol,
               crec.rep_fyr    ,
               crec.rep_period_num,
               crec.Run_Mode   ,
               crec.first_name ,
               crec.last_name  ,
               crec.phone_no   ,
               crec.phone_ext  ,
               crec.email_address,
               crec.fax_num    ,
               crec.mothers_m_name,
               crec.supervisor_name,
               crec.supervisor_phone,
               crec.supervisor_ext ,
               crec.agency_name_1,
               crec.agency_name_2,
               crec.address_1  ,
               crec.address_2  ,
               crec.city,
               crec.state,
               crec.zip,
               crec.currency_code );

               UPDATE fv_facts_submission
               SET submitted_by = fnd_global.user_name,
                   submitted_id = req_id,
                   facts2_status = 'IN PROCESS'
               WHERE rowid = crec.rowid;
               submitted_TS := submitted_TS + 1;
               COMMIT;
               l_request_ids(l_counter).request_id := req_id;
	       l_counter := l_counter+1 ;

	       -- Exit the loop and go to the next treasury symbol
               EXIT;

            END IF;
          END LOOP; -- 2
        END LOOP; -- 1

        l_counter := 1;
        l_flag := 0;
        errbuf:= 'No of Treasury Symbol(s) '||
          'Submitted for Facts II processs : ' || to_char(submitted_TS);

        WHILE submitted_TS > 0 AND  l_flag = 0
	  LOOP

	    -- Check status of completed concurrent program
	    --   and if complete exit
            l_call_status := fnd_concurrent.wait_for_request(
                              	l_request_ids(l_counter).request_id,
					0,
					0,
					rphase,
					rstatus,
					dphase,
					dstatus,
					message);

	    IF l_call_status = FALSE THEN
		errbuf := 'Can not wait for the status of the request ID:'||
					l_request_ids(l_counter).request_id ;
		retcode := '2';
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,errbuf);
	      ELSIF dphase= 'COMPLETE' THEN
		   IF l_counter = l_request_ids.COUNT THEN
		       l_flag := 1;
		   END IF;

              l_counter := l_counter+1 ;

    	    END IF;

          END LOOP;

        IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_EVENT, l_module_name,errbuf);
        END IF;

     ELSE -- vl_prc_map_count = 0
       errbuf:= 'Program Reporting Code Mapping has not been done! '||
                'Please map the Program Reporting Code and resubmit!';
       retcode := -1;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,errbuf);
     END IF;

   ELSE --  vl_fiscalyear_count = 0
    errbuf:= 'Budget Fiscal Year Mapping has not been done! '||
             'Please map the Budget Fiscal Year Segments and resubmit!';
    retcode := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,errbuf);
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := -1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.final_exception',errbuf);
    RAISE;


END SUBMIT;
-------------------------------------------------------------------------------
--          PROCEDURE MAIN
--------------------------------------------------------------------------------
-- Main procedure that is called to execute FACTS process.
-- This calls all subsequent procedures that are part of the FACTS
-- process.
--------------------------------------------------------------------------------
PROCEDURE main(
        errbuf      OUT NOCOPY  VARCHAR2,
        retcode     OUT NOCOPY  NUMBER,
        p_ledger_id     	NUMBER,
        treasury_symbol         VARCHAR2,
        report_fiscal_yr        NUMBER  ,
        report_period_num       NUMBER  ,
        run_mode                VARCHAR2,
        contact_fname       	VARCHAR2,
        contact_lname       	VARCHAR2,
        contact_phone       	NUMBER  ,
        contact_extn        	NUMBER  ,
        contact_email       	VARCHAR2,
        contact_fax     	NUMBER,
        contact_maiden      	VARCHAR2,
        supervisor_name     	VARCHAR2,
        supervisor_phone    	NUMBER  ,
        supervisor_extn     	NUMBER  ,
        agency_name_1       	VARCHAR2,
        agency_name_2       	VARCHAR2,
        address_1       	VARCHAR2,
        address_2       	VARCHAR2,
        city            	VARCHAR2,
        state           	VARCHAR2,
        zip         		VARCHAR2,
        currency_code           VARCHAR2,
	p_facts_rep_show  IN VARCHAR2 DEFAULT 'Y' )
IS
  l_module_name VARCHAR2(200);
 vl_facts2_status varchar2(25);

 vl_fund            VARCHAR2(25);
 vl_catb_rc_map_status  VARCHAR2(10);
 vl_prn_rc_map_status  VARCHAR2(10);

BEGIN
    l_module_name := g_module_name || 'main';
    -- Load FACTS Parameters into Global Variables
    vp_set_of_books_id  := p_ledger_id  ;
    vp_treasury_symbol  := treasury_symbol  ;
    vp_report_fiscal_yr := report_fiscal_yr ;
    v_period_num        := report_period_num;
    vp_run_mode     	:= run_mode         ;
    vp_retcode      	:= 0                ;
    vp_currency_code    := currency_code    ;
    vp_facts_rep_show   := NVL(p_facts_rep_show,'Y');


    -- Load FACTS Conacts Information to Global Variables
    vp_contact_fname	:= RPAD(contact_fname,20);
    vp_contact_lname 	:= RPAD(contact_lname,30) ;
    vp_contact_phone	:= LPAD(contact_phone,10);
    vp_contact_extn		:= NVL(LPAD(contact_extn,5),LPAD('',5));
    vp_contact_email	:= RPAD(contact_email,50);
    vp_contact_fax		:= LPAD(contact_fax,10);
    vp_contact_maiden	:= RPAD(contact_maiden,25);
    vp_supervisor_name 	:= RPAD(supervisor_name,40);
    vp_supervisor_phone	:= LPAD(supervisor_phone,10);
    vp_supervisor_extn	:= NVL(LPAD(supervisor_extn,5),LPAD('',5));
    vp_agency_name_1 	:= RPAD(agency_name_1,40);
    vp_agency_name_2	:= NVL(RPAD(agency_name_2,40),RPAD('',40));
    vp_address_1		:= RPAD(address_1,40);
    vp_address_2		:= NVL(RPAD(address_2,40),RPAD('',40));
    vp_city 			:= RPAD(city,25) ;
    vp_state			:= RPAD(state,2);
    vp_zip			:= RPAD(zip,10);



  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
   			'Deriving Treasury Symbol Id .....') ;
  END IF;
    load_treasury_symbol_id ;

  IF vp_retcode <> 0 THEN
    retcode := vp_retcode;
    errbuf := vp_errbuf;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
				 l_module_name,vp_errbuf);
    RETURN;
  END IF;
  check_prc_map_seg(v_treasury_symbol_id,
                    p_ledger_id,
                    vl_fund, vl_catb_rc_map_status,vl_prn_rc_map_status);


FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'vl_catb_rc_map_status ->'||vl_catb_rc_map_status);
FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'vl_prn_rc_map_status ->'||vl_prn_rc_map_status);

	IF vp_retcode <> 0 OR vl_catb_rc_map_status = 'FAIL' OR
		vl_prn_rc_map_status = 'FAIL' THEN
		retcode := vp_retcode;
		errbuf  := vp_errbuf;
		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Error : Either there is no Program Reporting Code mapping found or Category B reporting code mapping found for Treasury Symbol  '||vp_treasury_symbol);
		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,errbuf);
		RETURN;
	END IF;

    IF vp_report_fiscal_yr > 2001
       THEN v_year_gtn2001 := TRUE;
    END IF;


    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
				 'Running FACTSII process');
    END IF;

    vc_fiscal_yr        :=    LPAD(to_char(vp_report_fiscal_yr),4)  ;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
				 'Deriving Treasury Symbol Id .....') ;
    END IF;
    load_treasury_symbol_id ;

    IF vp_retcode = 0 THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
 					'Purging FACTS Transactions.....') ;
      END IF;
       purge_facts_transactions ;
    END IF ;

   IF vp_retcode = 0 THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
		   		'Deriving Qualifier Segments.....') ;
      END IF;
      get_qualifier_segments ;
   END IF ;

   IF vp_retcode = 0 THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
              'Deriving Treasury Symbol information.....');
      END IF;
      get_treasury_symbol_info ;
   END IF ;

   IF vp_retcode = 0 THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
		   		'Deriving Period information.....') ;
      END IF;
    get_period_info ;
   END IF ;

   IF vp_retcode = 0 THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
		   	'Starting FACTS Main Process.....') ;
      END IF;
        process_facts_transactions ;
   END IF ;

   IF vp_retcode = 0 THEN
        retcode := v_edit_check_code ;
        IF v_g_edit_check_code = 1 THEN
           vl_facts2_status := 'SOFT EDIT FAILED';
         ELSIF v_g_edit_check_code = 2 THEN
           vl_facts2_status := 'HARD EDIT CHECK FAILED';
         ELSE
           vl_facts2_status := 'COMPLETED';
        END IF ;
	-- If public law code and other attributes are not setup
        -- on the system parameters form, end the process with a warning.
        IF NOT v_facts_attributes_setup
         THEN
          retcode := 1;
          errbuf := 'Generate FACTS II Reports and Bulk Files Process completed with warning '||
		'because the Public Law, Advance and Transfer attribute '||
			'columns are not established on the '||
			'Define System Parameters Form.';
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,errbuf);
        END IF;

    ELSIF vp_retcode = 1 THEN
        retcode := vp_retcode ;
        errbuf := vp_errbuf ;
        vl_facts2_status := 'NO_TRANSACTION_FOUND';
    ELSE
        retcode := vp_retcode ;
        errbuf := vp_errbuf ;
        vl_facts2_status := 'ERROR';
        ROLLBACK ;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
				 'Stopped FACTS Main Process.....') ;
        END IF;
   END IF ;

   ---- Updating fv_facts_submission with the status and uncheck submit flag
       UPDATE fv_facts_submission
       SET submit_flag = 'N',
           facts2_status = vl_facts2_status
       WHERE submit_flag = 'Y'
       AND treasury_symbol_id = v_treasury_symbol_id ;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        vp_retcode := sqlcode ;
        vp_errbuf := sqlerrm || ' [MAIN] ' ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.final_exception',vp_errbuf);

        ROLLBACK;

        UPDATE fv_facts_submission
        SET submit_flag = 'N',
            facts2_status = 'ERROR'
        WHERE submit_flag = 'Y'
        AND treasury_symbol_id = v_treasury_symbol_id ;

        COMMIT ;
END main ;
--------------------------------------------------------------------------------
PROCEDURE load_treasury_symbol_id
IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'load_treasury_symbol_id';
        SELECT treasury_symbol_id
        INTO v_treasury_symbol_id
        FROM fv_treasury_symbols
        WHERE treasury_symbol = vp_treasury_symbol
        AND set_of_books_id = vp_set_of_books_id ;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
 			' Treasury Symbol ID: ' ||v_treasury_symbol_id);
        END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        vp_retcode := -1 ;
        vp_errbuf := 'Treasury Symbol Id cannot be found for the Treasury
            Symbol - '||vp_treasury_symbol||' [ GET_TREASURY_SYMBOL_ID ] ' ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
				l_module_name||'.exception1',vp_errbuf);
    WHEN TOO_MANY_ROWS Then
        vp_retcode := -1 ;
        vp_errbuf := 'More than one Treasury Symbol Id found for the Treasury
            Symbol - '||vp_treasury_symbol||' [ GET_TREASURY_SYMBOL_ID ] ' ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
			l_module_name||'.exception2',vp_errbuf);
    WHEN OTHERS THEN
      vp_errbuf := SQLERRM;
      vp_retcode := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
	  l_module_name||'.final_exception',vp_errbuf);
      RAISE;
END load_treasury_symbol_id ;
--------------------------------------------------------------------------------------
-- Purges all FACTS transactions from the FV_FACTS_TEMP table for
-- the passed Treasaury Symbol.
--------------------------------------------------------------------------------------
PROCEDURE purge_facts_transactions
IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'purge_facts_transactions';
    -- Delete from the temp table based on the treasury_symbol_id

    DELETE FROM fv_facts_temp
    WHERE treasury_symbol_id = v_treasury_symbol_id ;

    DELETE FROM fv_facts_edit_check_status
    WHERE treasury_symbol_id = v_treasury_symbol_id ;

    COMMIT ;

EXCEPTION
    -- Exception Processing
    When NO_DATA_FOUND Then
        Null ;
    When Others Then
        vp_retcode := sqlcode ;
        vp_errbuf  := sqlerrm ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.final_exception',vp_errbuf);
END purge_facts_transactions ;
--------------------------------------------------------------------------------
-- Gets the Accounting and Balancing segment names for the Chart
-- Of Accounts associated with the passed set of Books.
--------------------------------------------------------------------------------
PROCEDURE get_qualifier_segments
IS
  l_module_name        VARCHAR2(200);
  num_boolean          BOOLEAN          ;
  apps_id              NUMBER;
  flex_code            VARCHAR2(25);
  seg_number           NUMBER           ;
  seg_app_name         VARCHAR2(40)     ;
  seg_prompt           VARCHAR2(25)     ;
  seg_value_set_name   VARCHAR2(40)     ;
  invalid_segment      EXCEPTION        ;
BEGIN

    l_module_name := g_module_name || 'get_qualifier_segments';
    apps_id       := 101  ;
    flex_code     := 'GL#'    ;

    -- Getting the Chart of Accounts Id
    BEGIN
      SELECT chart_of_accounts_id
      INTO   v_chart_of_accounts_id
      FROM   gl_ledgers_public_v
      WHERE  ledger_id = vp_set_of_books_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vp_retcode := -1 ;
        vp_errbuf := 'Error getting Chart of Accounts Id for ledger id '
                        ||vp_set_of_books_id;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf);
        RETURN;
    END;
    -- Getting the Account and Balancing segments' application column names
    BEGIN
      FV_UTILITY.get_segment_col_names(v_chart_of_accounts_id,
                                       v_acc_seg_name,
                                       v_bal_seg_name,
                                       error_code,
                                       error_message);
    EXCEPTION
      WHEN OTHERS THEN
        vp_retcode := -1;
        vp_errbuf := error_message;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf);
        RETURN;
    END;

    -- Getting the Value Set Id for the Account Segment
    BEGIN
        -- Getting the Value set Id for finding hierarchies
        SELECT  flex_value_set_id
        INTO    v_acc_val_set_id
        FROM    fnd_id_flex_segments
        WHERE   application_column_name = v_acc_seg_name
        AND     application_id      = 101
        AND     id_flex_code        = 'GL#'
        AND     id_flex_num         = v_chart_of_accounts_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            vp_retcode := -1 ;
            vp_errbuf := 'Error getting Value Set Id for segment'
                            ||v_acc_seg_name||' [GET_USSGL_ACCOUNT_NUM]' ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
            RETURN;
    END ;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
 					' COA ID: '||v_chart_of_accounts_id);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	  					' ACC SEG: '||v_acc_seg_name);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	  					' BAL SEG: '||v_bal_seg_name);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	  				' ACC Val Set ID: '||v_acc_val_set_id);
    END IF;

    -- Getting Fiscal year segment name from fv_pya_fiscal_year_segment
    SELECT application_column_name
    INTO   v_fyr_segment_name
    FROM   fv_pya_fiscalyear_segment
    WHERE  set_of_books_id = vp_set_of_books_id;
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	  		'Fiscal year segment: '||v_fyr_segment_name);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        vp_retcode := sqlcode;
        vp_errbuf  := sqlerrm ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
	  		l_module_name||'.final_exception',vp_errbuf);
END get_qualifier_segments ;
--------------------------------------------------------------------------------------
-- Gets all the information that remains contant throughout the
-- FACTS output file.
--------------------------------------------------------------------------------------
PROCEDURE get_treasury_symbol_info
IS
  l_module_name VARCHAR2(200);
    vl_fund_category    VARCHAR2(1)     ;
    vl_resource_type    VARCHAR2(80)    ;
    vl_time_frame       VARCHAR2(25)    ;
    vl_established_fy   NUMBER      ;
    vl_financing_acct   VARCHAR2(1) ;
    vl_years_available  NUMBER      ;
    vl_fiscal_month_count NUMBER    ;
BEGIN
  l_module_name := g_module_name || 'get_treasury_symbol_info';
  SELECT
    fts.resource_type,
    RPAD(fffa.treasury_dept_code, 2),
    fts.time_frame,
    fts.established_fiscal_yr,
    fffa.financing_account,
    fffa.cohort_segment_name,
    RPAD(fffa.treasury_acct_code, 4),
    NVL(LPAD(fts.tafs_sub_acct,3, '0'),'000'),
    --NVL(LPAD(fts.tafs_split_code, 3, '0'),'000'),
    fts.years_available,
    NVL(fts.dept_transfer, '  ')
  INTO
    vl_resource_type,
    vc_dept_regular,
    vl_time_frame,
    vl_established_fy,
    vl_financing_acct,
    v_cohort_seg_name,
    vc_main_account,
    vc_sub_acct_symbol,
    --vc_acct_split_seq_num,
    vl_years_available,
    vc_dept_transfer
  FROM
    fv_facts_federal_accounts   fffa,
    fv_treasury_symbols         fts
  WHERE    fffa.federal_acct_symbol_id  = fts.federal_acct_symbol_id
    AND    fts.treasury_symbol      = vp_treasury_symbol
    AND    fts.set_of_books_id      = vp_set_of_books_id
    AND    fffa.set_of_books_id     = vp_set_of_books_id ;

       v_time_frame     := vl_time_frame;
       v_financing_acct := vl_financing_acct;

     /*  IF v_year_gtn2001 THEN
      vc_acct_split_seq_num := '000';
       END IF; */

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
	 		l_module_name, 'Financing Acct >>> - ' ||
        		vl_financing_acct || ' >>>> - Cohort Seg Name - ' ||
        		v_cohort_seg_name) ;
    END IF ;
    ------------------------------------------------
    --  Deriving COHORT Value
    ------------------------------------------------
    IF vl_financing_acct NOT IN ('D', 'G') THEN
    -- Consider COHORT value only for 'D' and 'G' financing Accounts
    v_cohort_seg_name := NULL   ;
    END IF ;

    -- Deriving FISCAL_YEAR
    IF vl_time_frame = 'SINGLE' THEN
      vc_fiscal_yr := '  ' || substr(to_char(vl_established_fy), 3, 2) ;
    ELSIF vl_time_frame IN ('NO_YEAR', 'REVOLVING')  THEN
      vc_fiscal_yr := '   X' ;
    ELSIF vl_time_frame IN ('MULTIPLE')  THEN
      vc_fiscal_yr := SUBSTR(TO_CHAR(vl_established_fy), 3,2) ||
        SUBSTR(TO_CHAR(vl_established_fy + vl_years_available - 1),3,2) ;
    END IF ;


    -- Preparer Id and Certifier Id and rpt_fiscal_yr
    -- are derived from Parameters
    vc_rpt_fiscal_yr    := LPAD(to_char(vp_report_fiscal_yr), 4) ;

    SELECT to_char(count(*) , '09')
    INTO   vl_fiscal_month_count
    FROM   gl_period_statuses
    WHERE  ledger_id = vp_set_of_books_id
    AND    application_id = 101
    AND    period_year = vp_report_fiscal_yr
--    AND    adjustment_period_flag = 'N'
    AND    period_num <= v_period_num  ;

    vc_rpt_fiscal_month := LTRIM(TO_CHAR(vl_fiscal_month_count,'09')) ;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        vp_retcode := -1 ;
        vp_errbuf := 'Error Getting Treasury Symbol related Information'||
        	' for the passed Treasury Symbol [GET_TREASURY_SYMBOL_INFO] ' ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
			l_module_name||'.exception1', vp_errbuf) ;
    WHEN TOO_MANY_ROWS THEN
        vp_retcode := -1 ;
        vp_errbuf := 'More than one set of information returned for the'||
        	  ' passed Treasury Symbol [GET_TREASURY_SYMBOL_INFO]'  ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
				l_module_name||'.exception2', vp_errbuf) ;
    WHEN OTHERS THEN
      vp_errbuf := SQLERRM;
      vp_retcode := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
	  		l_module_name||'.final_exception',vp_errbuf);
      RAISE;
END get_treasury_symbol_info ;
--------------------------------------------------------------------------------
-- Gets the Period infomation like Period Number, Period_year,
-- quarter number and other corresponding period information based on
-- the quarter number passed to the Main Procedure
--------------------------------------------------------------------------------
PROCEDURE get_period_info
IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'get_period_info';

    BEGIN
     -- selecting quarter based on period number as part
     -- of 'FACTS II monthly reporting'
    SELECT  period_name,
            start_date,
            end_date ,
            quarter_num
    INTO    v_period_name,
            v_period_start_dt,
            v_period_end_dt,
            vp_report_qtr
    FROM    gl_period_statuses
    WHERE   ledger_id = vp_set_of_books_id
    AND     application_id = 101
    AND     period_year = vp_report_fiscal_yr
    AND     period_num = v_period_num  ;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
			l_module_name,' Period Name: '||v_period_name);
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
			l_module_name,' Period Start Dt: '||v_period_start_dt);
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
			l_module_name,' Period End Dt: '||v_period_end_dt);
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
			l_module_name,' Quarter Num: '||vp_report_qtr);
    END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        vp_retcode := -1 ;
        vp_errbuf := 'Error Getting Period Information for the passed '||
                     'period [GET_PERIOD_INFO]'  ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
 	RETURN;
    WHEN TOO_MANY_ROWS THEN
        vp_retcode := -1 ;
        vp_errbuf := 'More than one period information returned for the '||
                      'passed Period [GET_PERIOD_INFO]'  ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
 	RETURN;
   END ;

   BEGIN

        -- Select Period Information for Beginning Period
        SELECT  period_name,
                start_date,
                end_date,
                period_num
        INTO    v_begin_period_name,
                v_begin_period_start_dt,
                v_begin_period_end_dt,
                v_begin_period_num
        FROM gl_period_statuses
        WHERE   period_num =
                (SELECT MIN(period_num)
                            FROM gl_period_statuses
                            WHERE period_year = vp_report_fiscal_yr
                            AND ledger_id = vp_set_of_books_id
                            AND application_id = 101
                            AND  adjustment_period_flag = 'N')
        AND application_id = 101
     --   AND adjustment_period_flag = 'N'
        AND ledger_id = vp_set_of_books_id
        AND period_year = vp_report_fiscal_yr ;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
			l_module_name,' Begin Prd Name: '||v_begin_period_name);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
	 			l_module_name,
				' Begin Prd St Dt: '|| v_begin_period_start_dt);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
				' Begin Prd End Dt: '|| v_begin_period_end_dt);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
				 ' Begin Prd Num: '||v_begin_period_num);
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            vp_retcode := -1 ;
            vp_errbuf := 'Error Getting Beginning Period Information ' ||
                         '[GET_PERIOD_INFO]'  ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
					l_module_name, vp_errbuf) ;
 	    RETURN;
        WHEN TOO_MANY_ROWS THEN
            vp_retcode := -1 ;
            vp_errbuf := 'More than one Beginning Period Returned !!'||
                         ' [GET_PERIOD_INFO]'  ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
			  	 l_module_name, vp_errbuf) ;
 	    RETURN;
    END ;
EXCEPTION
    -- Exception Processing
    WHEN OTHERS THEN
        vp_retcode := sqlcode ;
        vp_errbuf  := sqlerrm || ' [GET_PERIOD_INFO] ' ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.final_exception',vp_errbuf);
END get_period_info ;

--------------------------------------------------------------------------------
--       PROCEDURE process_facts_transactions
--------------------------------------------------------------------------------
-- This procedure selects all the transactions that needs to be
-- analyzed for reporting in the FACTS output file. After getting the
-- list of transactions that needs to be reported, it applies all the
-- FACTS attributes for the account number and performs further
-- processing for Legislative Indicator and Apportionment Category.
-- It populates the table FV_FACTS_TEMP for edit check process to
-- perform edit checks.
--------------------------------------------------------------------------------
PROCEDURE process_facts_transactions
IS
  l_module_name VARCHAR2(200);

    vl_main_cursor  INTEGER     ;
    vl_main_select  VARCHAR2(2000)  ;
    vl_fund_value   VARCHAR2(25)    ;
    vl_acct_num     VARCHAR2(25)    ;
    vl_cohort_yr    VARCHAR2(25)    ;
    vl_exec_ret     INTEGER     ;
    vl_row_count    NUMBER := 0 ;
    vl_main_fetch   INTEGER     ;
    vl_old_acct_num  VARCHAR2(25);
    vl_sgl_acct_num  VARCHAR2(25)    ;
    vl_amount        	NUMBER := 0  ;
    ve_amount        	NUMBER := 0  ; -- bug5065974
    vb_amount        	NUMBER := 0  ; -- bug5065974
    vb_balance_amount NUMBER := 0;

    vl_old_exception 	VARCHAR2(30);
    vl_period_activity  NUMBER := 0;
    vl_legis_cursor 	INTEGER         ;
    vl_legis_select 	VARCHAR2(5000)  ;
    vl_legis_ref    	VARCHAR2(240)   ;
    vl_legis_amount 	NUMBER := 0 ;
    vl_effective_date 	DATE;
    vl_period_name    	gl_je_lines.period_name%TYPE;
    vl_exception_cat  	NUMBER := 0;
    vl_sgl_acct_num_bak VARCHAR2(25);
    vl_tran_type        VARCHAR2(25)    ;
    vl_appor_cursor 	INTEGER         ;
    vl_appor_period 	VARCHAR2(500)   ;
    vl_appor_select 	VARCHAR2(2000)  ;
    vl_catb_program  	VARCHAR2(25)    ;
    vl_prn_program      VARCHAR2(25)    ;
    vl_appor_ctr    	NUMBER      ;
    vl_ec_retcode   	NUMBER  := 0    ;
    vl_ec_errbuf    	VARCHAR2(400)   ;
    vl_req_id   	NUMBER      ;
    vl_disbursements_flag VARCHAR2(1);
    vl_fyr_segment_value  fv_pya_fiscalyear_map.fyr_segment_value%TYPE;

    vl_je_source        gl_je_headers.je_source%TYPE;
    vl_pl_code          VARCHAR2(150);
    vl_tr_main_acct     VARCHAR2(150);
    vl_tr_dept_id       VARCHAR2(150);
    vl_advance_type     VARCHAR2(150);
    vl_count		NUMBER;
    l_req_id				NUMBER;

	l_call_status			BOOLEAN ;
	rphase				VARCHAR2(30);
	rstatus				VARCHAR2(30);
	dphase				VARCHAR2(30);
	dstatus				VARCHAR2(30);
	message				VARCHAR2(240);

    footnote_count 	NUMBER := 0;

    vl_par_pgm_val      VARCHAR2(3);
    vl_catb_rc_val          VARCHAR2(3);
    vl_catb_pgm_desc         VARCHAR2(25);
    vl_catb_exception        NUMBER;
    vl_prn_rc_val          VARCHAR2(3);
    vl_prn_pgm_desc         VARCHAR2(25);
    vl_prn_exception        NUMBER;

    -- for data access security
    das_id              NUMBER;
    das_where           VARCHAR2(600);

        CURSOR footnote_select
            (p_tsymbol_id fv_treasury_symbols.treasury_symbol_id%TYPE)
         IS
         SELECT treasury_symbol_id,
                sgl_acct_number
         FROM   fv_facts_temp
         WHERE  fct_int_record_type  = 'BLK_DTL'
         AND  fct_int_record_category  = 'REPORTED_NEW'
         AND  document_number      = 'Y'
         AND  treasury_symbol_id   = p_tsymbol_id ;

BEGIN
  l_module_name := g_module_name || 'process_facts_transactions';
  vl_old_acct_num  := ' '    ;
  vl_old_exception := ' '    ;



    -- Get all the transaction balances for the combinations that have
    -- fund values which are associated with the passed Treasury
    -- Symbol. Sum all the amounts and group the data by Account Number
    -- and Fund Value.
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	  			 'Selecting FACTS Transactions.....') ;
    END IF;
    BEGIN
        vl_main_cursor := DBMS_SQL.OPEN_CURSOR  ;
    EXCEPTION
        WHEN OTHERS THEN
            vp_retcode := sqlcode ;
            vp_errbuf  := sqlerrm ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			 l_module_name||'.vl_main_cursor', vp_errbuf) ;
	    RETURN;
    END ;

    IF v_cohort_seg_name IS NOT NULL THEN
      v_cohort_select := ', GLCC.' || v_cohort_seg_name ;
     ELSE
      v_cohort_select := ' ' ;
    END IF ;


  /* ---------  Comented out for bug5065974
       -- Get the balances for the Account Number and Fund Value
     vl_main_select :=
      'SELECT
            GLCC.' || v_acc_seg_name ||
          ', GLCC.' || v_bal_seg_name ||
          ', GLCC.' || v_fyr_segment_name ||
             v_cohort_select ||
      ' FROM    GL_BALANCES            GLB,
                GL_CODE_COMBINATIONS        GLCC,
                FV_FUND_PARAMETERS      FFP,
                FV_TREASURY_SYMBOLS         FTS
        WHERE   FTS.TREASURY_SYMBOL = :treasury_symbol
          AND   GLB.code_combination_id = GLCC.code_combination_id
          AND   glb.actual_flag = :actual_flag
          AND   FTS.TREASURY_SYMBOL_ID = FFP.TREASURY_SYMBOL_ID
          AND   GLB.TEMPLATE_ID IS NULL
          AND   GLCC.' || v_bal_seg_name || '= FFP.FUND_VALUE
          AND   GLB.SET_OF_BOOKS_ID =  :set_of_books_id
          AND   FFP.SET_OF_BOOKS_ID =  :set_of_books_id
          AND   FTS.SET_OF_BOOKS_ID =  :set_of_books_id
          AND   GLB.PERIOD_YEAR =      :report_fiscal_yr
          AND   glb.currency_code =    :currency_code
          GROUP BY GLCC.' || v_acc_seg_name ||
                   ', GLCC.' || v_bal_seg_name ||
                   ', GLCC.' || v_fyr_segment_name ||v_cohort_select ||
        '  ORDER BY GLCC.' || v_acc_seg_name  ;


	------------------------------------------- > */


 --  added for bug 5065974 by ks
 -- Get the balances for the Account Number and Fund Value and year begin and current
 -- end balances

      vl_main_select :=
       'SELECT
             GLCC.' || v_acc_seg_name ||
           ', GLCC.' || v_bal_seg_name ||
           ', GLCC.' || v_fyr_segment_name ||
              v_cohort_select ||
             ',SUM(decode(glb.period_name,:b_period_name,glb.begin_balance_dr - glb.begin_balance_cr,0)) beg_amt
             ,SUM(decode(glb.period_name,:e_period_name,glb.begin_balance_dr - glb.begin_balance_cr +
             glb.period_net_dr - glb.period_net_cr,0)) end_amount
        FROM    GL_BALANCES            GLB,
                 GL_CODE_COMBINATIONS        GLCC,
                 FV_FUND_PARAMETERS      FFP,
                 FV_TREASURY_SYMBOLS         FTS
             WHERE   FTS.TREASURY_SYMBOL = :treasury_symbol
             AND   FTS.SET_OF_BOOKS_ID =   :set_of_books_id
             AND   FFP.TREASURY_SYMBOL_ID = FTS.TREASURY_SYMBOL_ID
             AND   FFP.SET_OF_BOOKS_ID    = :set_of_books_id
             AND   GLCC.' || v_bal_seg_name || '= FFP.FUND_VALUE
             AND   GLB.code_combination_id = GLCC.code_combination_id
             AND   glb.actual_flag = :actual_flag
             AND   GLB.TEMPLATE_ID IS NULL
             AND   GLB.ledger_id =  :set_of_books_id
             AND   GLB.PERIOD_NAME  in(:b_period_name , :e_period_name)
             AND   glb.currency_code =    :currency_code
           GROUP BY GLCC.' || v_acc_seg_name ||
                    ', GLCC.' || v_bal_seg_name ||
                    ', GLCC.' || v_fyr_segment_name ||v_cohort_select ||
         '  ORDER BY GLCC.' || v_acc_seg_name  ;



    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
				 'Main Select: '||vl_main_select);
    END IF;

    BEGIN
        dbms_sql.parse(vl_main_cursor, vl_main_select, DBMS_SQL.V7) ;
    EXCEPTION
        WHEN OTHERS THEN
            vp_retcode := sqlcode ;
            vp_errbuf  := sqlerrm ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.dbms_sql_parse', vp_errbuf) ;
	    RETURN;
    END ;

    -- Bind the variables
    dbms_sql.bind_variable(vl_main_cursor,':actual_flag', 'A');
    dbms_sql.bind_variable(vl_main_cursor,':treasury_symbol', vp_treasury_symbol);
    dbms_sql.bind_variable(vl_main_cursor,':set_of_books_id', vp_set_of_books_id);
    --dbms_sql.bind_variable(vl_main_cursor,':report_fiscal_yr', vp_report_fiscal_yr);
    dbms_sql.bind_variable(vl_main_cursor,':currency_code', vp_currency_code);
    dbms_sql.bind_variable(vl_main_cursor,':e_period_name', v_period_name); -- added bug5065974
    dbms_sql.bind_variable(vl_main_cursor,':b_period_name', v_begin_period_name); -- added bug5065974

    dbms_sql.define_column(vl_main_cursor, 1, vl_acct_num, 25);
    dbms_sql.define_column(vl_main_cursor, 2, vl_fund_value, 25);
    dbms_sql.define_column(vl_main_cursor, 3, v_fiscal_yr, 25);
    -- dbms_sql.bind_variable(vl_main_cursor,':report_fiscal_yr', vp_report_fiscal_yr); -- removed bug 5065974
    IF v_cohort_seg_name IS NOT NULL THEN
          dbms_sql.define_column(vl_main_cursor, 4, vl_cohort_yr, 25);
           dbms_sql.define_column(vl_main_cursor, 5, vb_amount); -- 5065974
           dbms_sql.define_column(vl_main_cursor, 6, ve_amount); -- 5065974
     else
           dbms_sql.define_column(vl_main_cursor, 4, vb_amount); -- 5065974
           dbms_sql.define_column(vl_main_cursor, 5, ve_amount); -- 5065974
     End if;


    BEGIN
        vl_exec_ret := dbms_sql.execute(vl_main_cursor);
    EXCEPTION
        WHEN OTHERS THEN
            vp_retcode := sqlcode ;
            VP_ERRBUF  := sqlerrm ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
				l_module_name||'.dbms_sql_parse', vp_errbuf) ;
	    RETURN;
    END ;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	 			'Processing FACTS Transactions starts.....');
   END IF;
   LOOP
      -- This is a Dummy Loop since we have no command in PL/SQL to skip
      -- the Loop in the middle and continue with the next iteration.
     LOOP    /* Dummy */
      -- Reseting all the Variables before fetching the Next Row

        va_transaction_partner_val  := ' '      ;
        va_cohort                   := '  '     ;
        va_def_indef_val            := ' '      ;
        va_appor_cat_b_dtl          := '   '        ;
        va_appor_cat_b_txt          := LPAD(' ',25)     ;
        va_public_law_code_val      := '       '        ;
        va_appor_cat_val            := ' '          ;
        va_authority_type_val       := ' '          ;
        va_reimburseable_val        := ' '          ;
        va_bea_category_val         := '     '      ;
        va_borrowing_source_val     := '     '         ;
        va_legis_ind_val            := ' '          ;
        va_pya_ind_val              := ' '          ;
        va_balance_type_val         := ' '          ;
        va_availability_flag        := ' ';
        va_function_flag            := ' ';
        va_budget_function          := '   ';
    	va_advance_type_val         := ' ';
    	va_transfer_dept_id         := '  ';
        va_transfer_main_acct       := '    ';
        v_dummy_cohort 		    := NULL;
    	vl_cohort_yr 		    := NULL;
    	v_cohort_where 		    := NULL;
        vl_disbursements_flag       := NULL;
        va_prn_num                  := '   '        ;
        va_prn_txt                  := LPAD(' ',25)     ;

        v_catb_program_value        := NULL;
        v_prn_program_value         := NULL;

      vl_main_fetch :=  dbms_sql.fetch_rows(vl_main_cursor) ;

      IF (vl_main_fetch = 0) THEN
        IF ( vl_row_count = 0)  THEN
         -- No Rows to process for FACTS II Report !!
                 vp_retcode := 1 ;
                 VP_ERRBUF  := 'No Data found for FACTS II process' ;

  	              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
					   '=======================' ||
                       '===================================================') ;
                  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
		  					 vp_errbuf) ;
                  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
		  				'=======================' ||
                       '===================================================') ;
           RETURN;
         END IF;
       EXIT;
      END IF;

      -- Increase the counter for number of records
      vl_row_count := vl_row_count + 1  ;

      -- Fetch the Records into Variables
      dbms_sql.column_value(vl_main_cursor, 1, vl_acct_num);
      dbms_sql.column_value(vl_main_cursor, 2, vl_fund_value);
      dbms_sql.column_value(vl_main_cursor, 3, v_fiscal_yr);

      IF v_cohort_seg_name IS NOT NULL THEN
         dbms_sql.column_value(vl_main_cursor, 4, vl_cohort_yr);
          dbms_sql.column_value(vl_main_cursor, 5, vb_amount);
          dbms_sql.column_value(vl_main_cursor, 6, ve_amount);
       else
          dbms_sql.column_value(vl_main_cursor, 4, vb_amount);
          dbms_sql.column_value(vl_main_cursor, 5, ve_amount);
      END IF;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
        '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      END IF;

        -- FACTS Account Number Validation Process
        IF vl_acct_num <> vl_old_acct_num THEN

            -- Identify/Validate the SGL parent account number for
            -- the account number fetched
            get_ussgl_acct_num(vl_acct_num     ,
                	       vl_sgl_acct_num ,
                	       v_record_category) ;

            IF vp_retcode <> 0 THEN
                 RETURN ;
            END IF ;
            -- Store the Acct Number to compare with next fetch
            vl_old_acct_num  := vl_acct_num ;
            vl_old_exception := v_record_category ;
        END IF ;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
				'Processing for> Acct-'||vl_acct_num||
              ' > USSGL Acct-'||vl_sgl_acct_num||' > Fund-'||vl_fund_value||
              ' Cohort >-'||vl_cohort_yr|| ' > Category - ' ||
			  								 v_record_category ) ;
        END IF ;

        -- Cohort where clause is set to a global variable to use in
        -- CALC_BALANCE Procedure and futher in the process
        IF v_cohort_seg_name IS NOT NULL THEN
              v_cohort_where := ' AND GLCC.' || v_cohort_seg_name || ' = ' ||
                              '''' || vl_cohort_yr || '''' ;
         ELSE
              v_cohort_where := ' ' ;
        END IF ;

        -- Account Number Validated and Exceptions are processed
        -- proceeding with further processing.
        IF v_record_category IS NOT NULL THEN
            IF v_record_category IN ('NON_BUD_ACCT', 'NON_FACTSII') THEN
               -- No Exception Record Required in Temp Table. Continue with
               -- the main loop.
               EXIT ;
             ELSIF v_record_category IN
			('USSGL_DISABLED', 'BUD_ACCT_NOT_SETUP',
			 'USSGL_MULTIPLE_PARENTS') THEN
                   v_sgl_acct_num := vl_sgl_acct_num ;
		   -- Get the ending balance for the account and create an
		   -- exception record

		  /*  ------------ > commented out for bug#5065974
                   calc_balance (vl_fund_value,
                                 vl_acct_num,
                                 v_period_num,
                                 vp_report_fiscal_yr,
                                 'E',
                                 v_fiscal_yr,
                                 vl_amount,
                                 vl_period_activity);
		   ---v_amount := vl_amount;
	          -------------------------------------------  */
		   v_amount := ve_amount; -- bug 5065974

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	  			'Creating exception: '|| v_record_category);
        END IF;
                   create_facts_record ;
                   IF vp_retcode <> 0 THEN
                    RETURN ;
                   END IF ;
                   -- Exiting the Process Flow (dummy loop)
                   -- after creating Exception Record.
                   EXIT ;
            END IF ;
        END IF ;


      -- Fix for bug 2798371
      IF vl_cohort_yr IS NOT NULL THEN
       BEGIN
        SELECT TO_NUMBER(vl_cohort_yr)
        INTO   v_dummy_cohort
        FROM DUAL;
--Bug#4234865 Changed v_dummy_cohort to vl_cohort_yr
        IF LENGTH(vl_cohort_yr) = 1 THEN
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
		     'Cohort value: '||vl_cohort_yr|| ' is a single digit!');
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'Taking Cohort value from report parameter.');
          END IF;
          v_dummy_cohort := vp_report_fiscal_yr;
--Bug#4234865 Added the ELSE part
        ELSE
          v_dummy_cohort := vl_cohort_yr;
        END IF;

        EXCEPTION WHEN INVALID_NUMBER THEN
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'Cohort value: '||vl_cohort_yr|| ' is non-numeric!');
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'Taking Cohort value from report parameter.');
          END IF;
          v_dummy_cohort := vp_report_fiscal_yr;
       END;
      END IF;

      va_cohort := NVL(LPAD(substr(v_dummy_cohort, LENGTH(v_dummy_cohort)-1, 2),
                                                                2, ' '), '  ') ;

        v_year_budget_auth  := '   ';
        BEGIN
             SELECT disbursements_flag
             INTO   vl_disbursements_flag
             FROM   fv_facts_ussgl_accounts
             WHERE  ussgl_account = vl_sgl_acct_num;

             IF  (v_time_frame             = 'NO_YEAR'
                  AND v_financing_acct      = 'N'
                  AND vl_disbursements_flag = 'Y')
                THEN
                    BEGIN
                    SELECT fyr_segment_value
                    INTO   vl_fyr_segment_value
                    FROM   fv_pya_fiscalyear_map
                    WHERE  period_year = vp_report_fiscal_yr
                    AND    set_of_books_id = vp_set_of_books_id;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                           'Please set up the Budget Fiscal Year Segment Mapping for period year '||vp_report_fiscal_yr);
                        RAISE;
                    END;

                    IF vl_fyr_segment_value IS NOT NULL THEN
                       IF vl_fyr_segment_value = v_fiscal_yr THEN
                          v_year_budget_auth := 'NEW';
                       ELSE
                          v_year_budget_auth := 'BAL';
                       END IF;
                    END IF;
             END IF;

             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
			 	THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	   			'Year bud auth: '||v_year_budget_auth);
             END IF;
         EXCEPTION WHEN OTHERS THEN
            vp_retcode := sqlcode;
            vp_errbuf  := 'Error when processing v_year_budget_auth: '||
                          sqlerrm;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
				l_module_name||'.exception_1',vp_errbuf);
            RETURN;
        END;

        -- Acct Number Passed Validations. Load FACTS attributes
        -- based on the flag v_acct_attr_flag
        -- Move the account number into global variable
        v_sgl_acct_num := vl_sgl_acct_num   ;
        --v_amount       := vl_amount     ;
        v_amount       := ve_amount     ;

        IF v_acct_attr_flag = 'Y' THEN
            load_facts_attributes (vl_acct_num, vl_fund_value,ve_amount)  ;
         ELSE
            load_facts_attributes (vl_sgl_acct_num, vl_fund_value,ve_amount)  ;
        END IF ;
        IF vp_retcode <> 0 THEN
            RETURN ;
        END IF ;

      -- v_tbal_indicator set to 'F' to indicate FACTS transaction
      v_tbal_indicator := 'F' ;

      -------------- Legislation Indicator Processing Starts ----------------
      IF va_legis_Ind_flag = 'Y' OR va_public_law_code_flag = 'Y'
         OR va_advance_flag = 'Y' OR va_transfer_ind = 'Y' THEN
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            IF (va_legis_ind_flag ='Y' AND va_public_law_code_flag ='Y') THEN
              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
			  		THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                  ' ++ Leg Ind and P.Law Processing ++') ;
                END IF;
               ELSIF (va_legis_ind_flag = 'Y' AND va_public_law_code_flag = 'N')
			    THEN
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
				  THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                  ' ++ Leg Ind Processing ++') ;
                END IF;
               ELSIF va_legis_ind_flag = 'N' AND va_public_law_code_flag = 'Y'
			     THEN
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
				   THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                  ' ++ Pub Law Processing ++') ;
                END IF;
              END IF ;

              IF va_advance_flag = 'Y' THEN
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
				  THEN
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
		  			'++ Advance Type Processing ++') ;
                END IF;
              END IF;
              IF va_transfer_ind = 'Y' THEN
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
				 THEN
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
				     '++ Transfer Acct Processing ++') ;
                END IF;
              END IF;
          END IF ;
          BEGIN		-- Legislative processing
              -- Calculate the Beginning balance for the current account
              -- and fund value combination and create record in temp
              -- table for Legislative Indicator 'A' and Balance Type 'B'
              -- Default Public Law Code values for beginning and
              -- ending balances
              IF va_public_law_code_flag = 'Y' THEN
                  --Bug#3219532
                  --va_public_law_code_val := '000-000' ;
                  va_public_law_code_val := '       ' ;
              END IF ;

              -- Legislative Ind values for beginning and ending balances
              IF va_legis_ind_flag = 'Y' THEN
                 va_legis_ind_val := 'A' ;
              END IF ;

              -- Advance Type values for beginning and ending balances
              IF va_advance_flag = 'Y' THEN
                 va_advance_type_val  := 'X'         ;
              END IF ;

              -- Transfer values for beginning and ending balances
              IF  va_transfer_ind       = 'Y' THEN
                  --Bug#3219532
                  --va_transfer_dept_id   := '00'       ;
                  --va_transfer_main_acct := '0000'     ;
                  va_transfer_dept_id   := '  '       ;
                  va_transfer_main_acct := '    '     ;
              END IF ;

              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
			      THEN
     	         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
				       'Period number '||v_begin_period_num) ;
              END IF;

		/* ------- bug 5065974 -------------------
              calc_balance (vl_fund_value,
                            vl_acct_num,
                            v_begin_period_num,
                            vp_report_fiscal_yr,
                            'B',
                            v_fiscal_yr,
                            v_begin_amount,
                            vl_period_activity);
                ------------------------------ > */

              IF vp_retcode <> 0 THEN
                 RETURN ;
              END IF ;

              vb_balance_amount := vb_amount;
              FOR begin_balance_rec IN (SELECT SUM(NVL(f.ending_balance_dr, 0) - NVL(f.ending_balance_cr, 0)) amount,
                                               f.public_law,
                                               f.advance_flag,
                                               f.transfer_dept_id,
                                               f.transfer_main_acct
                                          FROM fv_factsii_ending_balances f
                                         WHERE f.set_of_books_id = vp_set_of_books_id
                                           AND f.fiscal_year = vp_report_fiscal_yr-1
                                           AND f.account = vl_acct_num
                                           AND f.fund = vl_fund_value
                                           AND f.fyr = v_fiscal_yr
                                           AND NVL(f.cohort, '-1') = DECODE (v_cohort_seg_name, NULL, NVL(f.cohort,'-1'), vl_cohort_yr)
                                         GROUP BY f.public_law,
                                                  f.advance_flag,
                                                  f.transfer_dept_id,
                                                  f.transfer_main_acct) LOOP
                v_amount := begin_balance_rec.amount;
                vb_balance_amount := vb_balance_amount - v_amount;
                v_record_category := 'REPORTED';
                va_public_law_code_val := RTRIM(begin_balance_rec.public_law);
                va_advance_type_val := begin_balance_rec.advance_flag;
                va_transfer_dept_id := begin_balance_rec.transfer_dept_id;
                va_transfer_main_acct := begin_balance_rec.transfer_main_acct;
                v_period_activity := 0;
                IF (va_public_law_code_val IS NULL) THEN
                  vl_sgl_acct_num_bak := v_sgl_acct_num;
                  v_sgl_acct_num    := vl_acct_num  ;
                  v_record_category := 'PUBLIC_LAW_NOT_DEFINED';
                  create_facts_record ;

		  -- added KS
                  IF (va_balance_type_flag  IN ('B' , 'S') ) THEN
                    va_balance_type_val  := 'B'          ;
                  elsif (va_balance_type_flag  IN ('E' , 'S') ) THEN
                    va_balance_type_val     := 'E'      ;
                  END IF;

                  v_record_category :=  'REPORTED';
                  v_sgl_acct_num    := vl_sgl_acct_num_bak  ;
                  vl_exception_cat := 1;
                ELSE
                  IF (va_balance_type_flag  IN ('B' , 'S') ) THEN
                    va_balance_type_val  := 'B'          ;
                    create_facts_record;
                  END IF;
                  IF (va_balance_type_flag  IN ('E' , 'S') ) THEN
                    va_balance_type_val     := 'E'      ;
                    create_facts_record;
                  END IF;
                END IF;
              END LOOP;

         IF (vb_balance_amount <> 0) THEN
           va_public_law_code_val := NULL;
           va_legis_ind_val := NULL;
           va_advance_type_val := NULL;
           va_transfer_dept_id := NULL;
           va_transfer_main_acct := NULL;

           IF va_public_law_code_flag = 'Y' THEN
               va_public_law_code_val := '       ' ;
           END IF ;

           IF va_legis_ind_flag = 'Y' THEN
              va_legis_ind_val := 'A' ;
           END IF ;

           IF va_advance_flag = 'Y' THEN
             va_advance_type_val  := 'X'         ;
           END IF ;

           IF  va_transfer_ind       = 'Y' THEN
             va_transfer_dept_id   := '  '       ;
             va_transfer_main_acct := '    '     ;
           END IF ;
           IF (va_balance_type_flag  IN ('B' , 'S') ) THEN

                -- Creating FACTS Record with Beginning Balance
                va_balance_type_val  := 'B'          ;
                v_record_category    := 'REPORTED'       ;
                --v_amount             := v_begin_amount   ;  -- bug 5065974
                v_amount             := vb_balance_amount   ;  -- bug 5065974
                v_period_activity    := 0   ;
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  			      THEN
                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
  'Begin Balance(' || va_balance_type_flag || ')  >>>>  - ' || to_char(v_amount)) ;
                END IF ;

                create_facts_record   ;
                IF vp_retcode <> 0 THEN
                      RETURN ;
                END IF ;
           END IF;

           IF (va_balance_type_flag  IN ('E' , 'S') ) THEN
                -- Creating FACTS Record with Ending Balance
                va_balance_type_val     := 'E'      ;
                v_record_category   := 'REPORTED'   ;
                --v_amount             := v_begin_amount   ;
                v_amount             := vb_balance_amount   ;
                v_period_activity := 0 ;
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  			    THEN
                    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Begin Balance(' ||
                       va_balance_type_flag || ')  >>>>  - ' || to_char(v_amount)) ;
                END IF ;

                create_facts_record ;
                IF vp_retcode <> 0 THEN
                      RETURN ;
                END IF ;
           END IF;
         END IF;

              -- Select the records for other Legislative Indicator values,
              -- derived from Budget Execution tables and store them in a
              -- cursor. Then roll them up and insert the summarized record
              -- into the temp table.
              BEGIN
                  vl_legis_cursor := DBMS_SQL.OPEN_CURSOR  ;
              EXCEPTION
                  WHEN OTHERS THEN
                      vp_retcode := sqlcode ;
                      VP_ERRBUF  := sqlerrm ;
                      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
		        l_module_name||'.vl_legis_cursor', vp_errbuf) ;
                      RETURN ;
              END ;

              IF va_pl_code_col IS NOT NULL THEN
		 va_pl_code_col :=  ', gjl.'||va_pl_code_col;
	      END IF;

              IF va_tr_main_acct_col IS NOT NULL THEN
		 va_tr_main_acct_col := ', gjl.'||va_tr_main_acct_col;
	      END IF;

             IF va_tr_dept_id_col IS NOT NULL THEN
		 va_tr_dept_id_col := ', gjl.'||va_tr_dept_id_col;
	      END IF;

              IF va_advance_type_col IS NOT NULL THEN
		 va_advance_type_col := ', gjl.'||va_advance_type_col;
	      END IF;

               -- Data Access Security:
               das_id := fnd_profile.value('GL_ACCESS_SET_ID');
               das_where := gl_access_set_security_pkg.get_security_clause
                              (das_id,
                               gl_access_set_security_pkg.READ_ONLY_ACCESS,
                               gl_access_set_security_pkg.CHECK_LEDGER_ID,
                               to_char(vp_set_of_books_id), null,
                               gl_access_set_security_pkg.CHECK_SEGVALS,
                               null, 'glcc', null);
              -- Get the transactions for the account Number and Fund (and
              -- cohort segment, if required)
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
		                        'vl_legis_Select') ;
        END IF;

              vl_legis_select :=
              'SELECT gjl.reference_1,
                      NVL(gjl.entered_dr, 0) - NVL(gjl.entered_cr, 0) amout,
                      gjl.effective_date , gjl.period_name, gjh.je_source '||
	      va_pl_code_col || va_tr_main_acct_col || va_tr_dept_id_col ||
		      va_advance_type_col ||
              ' FROM   gl_je_lines         gjl,
                      gl_code_combinations    glcc,
                      gl_je_headers       gjh
               WHERE  gjl.code_combination_id = glcc.code_combination_id
	        AND   gjl.status =  :je_status
                AND   gjl.ledger_id = :set_of_books_id
                AND   glcc.'||v_acc_seg_name|| ' = :acct_num
                AND   NVL(gjl.entered_dr, 0) - NVL(gjl.entered_cr, 0) <> 0
                AND   glcc.'||v_bal_seg_name||' = :fund_value '||
                      v_cohort_where ||
              ' AND   glcc.'||v_fyr_segment_name||' = :fiscal_yr
                AND   gjh.je_header_id = gjl.je_header_id
                AND NVL(gjh.je_from_sla_flag, ''N'') = ''N''
                AND   gjh.currency_code = :currency_code ';

               vl_legis_select :=
                 vl_legis_select || ' AND   gjl.period_name  in '  ||
		   ' ( SELECT period_name
                       FROM gl_period_statuses
                       WHERE application_id = 101
                       AND ledger_id = :set_of_books_id
                       AND period_num  BETWEEN :begin_period_num AND :period_num
                       AND period_year = :report_fiscal_yr) ' ;

               IF (das_where IS NOT NULL) THEN
                 vl_legis_select := vl_legis_select || 'AND ' || das_where;
               END IF;

              vl_legis_select := vl_legis_select || ' UNION ALL ';
	      -- Used TO_CHAR for bug 6332685
              vl_legis_select := vl_legis_select ||
              'SELECT TO_CHAR(SOURCE_DISTRIBUTION_ID_NUM_1),
                      NVL(xl.accounted_dr, 0) - NVL(xl.accounted_cr, 0) amount,
                      gjl.effective_date , gjl.period_name, gjh.je_source '||
	      va_pl_code_col || va_tr_main_acct_col || va_tr_dept_id_col ||
		      va_advance_type_col ||
              ' FROM   gl_je_lines         gjl,
                      gl_code_combinations    glcc,
                      gl_je_headers       gjh,
                      gl_import_references gli,
                      xla_distribution_links xdl,
	              xla_ae_lines xl
               WHERE  gjl.code_combination_id = glcc.code_combination_id
	        AND   gjl.status =  :je_status
                AND NVL(gjh.je_from_sla_flag, ''N'') = ''Y''
                AND   gjl.ledger_id = :set_of_books_id
                AND   glcc.'||v_acc_seg_name|| ' = :acct_num
                AND   NVL(xl.accounted_dr, 0) - NVL(xl.accounted_cr, 0) <> 0
                AND   glcc.'||v_bal_seg_name||' = :fund_value '||
                      v_cohort_where ||
              ' AND   glcc.'||v_fyr_segment_name||' = :fiscal_yr
                AND   gjh.je_header_id = gjl.je_header_id
                AND   gjh.currency_code = :currency_code
                and   gli.je_batch_id = gjh.je_batch_id
                and   gli.je_header_id = gjh.je_header_id
                and   gli.je_line_num = gjl.je_line_num
	        AND   xl.gl_sl_link_id = gli.gl_sl_link_id
                AND   xdl.ae_header_id = xl.ae_header_id
	        AND   xdl.ae_line_num = xl.ae_line_num ';

                --AND xl.code_combination_id = glcc.code_combination_id
               vl_legis_select :=
                 vl_legis_select || ' AND   gjl.period_name  in '  ||
		   ' ( SELECT period_name
                       FROM gl_period_statuses
                       WHERE application_id = 101
                       AND ledger_id = :set_of_books_id
                       AND period_num  BETWEEN :begin_period_num AND :period_num
                       AND period_year = :report_fiscal_yr) ' ;

               IF (das_where IS NOT NULL) THEN
                 vl_legis_select := vl_legis_select || 'AND ' || das_where;
               END IF;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
		                        vl_legis_select) ;
	      END IF;

             BEGIN
               dbms_sql.parse(vl_legis_cursor,vl_legis_select,DBMS_SQL.V7);
              EXCEPTION
               WHEN OTHERS THEN
                     vp_retcode := sqlcode ;
                     vp_errbuf  := sqlerrm ;
                     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
		           l_module_name||'.dbms_sql_parse_vl_legis_cursor',
							    vp_errbuf) ;
                     RETURN ;
             END ;


  	     -- Bind the variables
            dbms_sql.bind_variable(vl_legis_cursor,':je_status', 'P');
            dbms_sql.bind_variable(vl_legis_cursor,':set_of_books_id',
							  vp_set_of_books_id);
            dbms_sql.bind_variable(vl_legis_cursor,':acct_num',
			                        vl_acct_num);
            dbms_sql.bind_variable(vl_legis_cursor,':fund_value',
			                        vl_fund_value);
            dbms_sql.bind_variable(vl_legis_cursor,':fiscal_yr', v_fiscal_yr);
            dbms_sql.bind_variable(vl_legis_cursor,':currency_code',
		                           vp_currency_code);
            dbms_sql.bind_variable(vl_legis_cursor,':begin_period_num',
	     				        v_begin_period_num);
            dbms_sql.bind_variable(vl_legis_cursor,':period_num', v_period_num);
            dbms_sql.bind_variable(vl_legis_cursor,':report_fiscal_yr',
					            vp_report_fiscal_yr);

	     vl_count := 0;

             dbms_sql.define_column(vl_legis_cursor, 1, vl_legis_ref, 240);
             dbms_sql.define_column(vl_legis_cursor, 2, vl_legis_amount   );
             dbms_sql.define_column(vl_legis_cursor, 3, vl_effective_date   );
             dbms_sql.define_column(vl_legis_cursor, 4, vl_period_name, 15  );
             dbms_sql.define_column(vl_legis_cursor, 5, vl_je_source, 25  );

	     vl_count := 6;

           IF va_pl_code_col IS NOT NULL THEN
             dbms_sql.define_column(vl_legis_cursor, vl_count, vl_pl_code, 150);
		     vl_count := vl_count + 1;
           END IF;

           IF va_tr_main_acct_col IS NOT NULL THEN
                   dbms_sql.define_column(vl_legis_cursor, vl_count,
				                          vl_tr_main_acct, 150);
		           vl_count := vl_count + 1;
           END IF;

          IF va_tr_dept_id_col IS NOT NULL THEN
             dbms_sql.define_column(vl_legis_cursor, vl_count,
			                        vl_tr_dept_id, 150);
		       vl_count := vl_count + 1;
          END IF;

             IF va_advance_type_col IS NOT NULL THEN
                dbms_sql.define_column(vl_legis_cursor, vl_count,
				                       vl_advance_type, 150);
             END IF;

             BEGIN
                  vl_exec_ret := dbms_sql.execute(vl_legis_cursor);
              EXCEPTION
                  WHEN OTHERS THEN
                      vp_retcode := sqlcode ;
                      vp_errbuf  := sqlerrm ;
                      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
		        l_module_name||'.dbms_sql_execute_vl_legis_cursor',
							           vp_errbuf) ;
                      RETURN ;
             END ;

             LOOP
                vl_exception_cat   := 0;
                IF dbms_sql.fetch_rows(vl_legis_cursor) = 0 THEN
                    EXIT;
                 ELSE

		    vl_count := 0;
                    -- Fetch the Records into Variables
                    dbms_sql.column_value(vl_legis_cursor,1,vl_legis_ref);
                    dbms_sql.column_value(vl_legis_cursor,2,vl_legis_amount);
                    dbms_sql.column_value(vl_legis_cursor,3,vl_effective_date);
                    dbms_sql.column_value(vl_legis_cursor,4,vl_period_name);
                    dbms_sql.column_value(vl_legis_cursor,5,vl_je_source);

	--fnd_file.put_line(fnd_file.log , 'vl_legis_ref ' || vl_legis_ref);
	--fnd_file.put_line(fnd_file.log , 'vl_je_source ' || vl_je_source);
	--fnd_file.put_line(fnd_file.log , 'vl_legis_amount ' || vl_legis_amount);
		    vl_count := 6;

                    IF va_pl_code_col IS NOT NULL THEN
                       dbms_sql.column_value(vl_legis_cursor,
		                         vl_count, vl_pl_code);
		       vl_count := vl_count + 1;
                    END IF;

                    IF va_tr_main_acct_col IS NOT NULL THEN
                       dbms_sql.column_value(vl_legis_cursor, vl_count,
			                         vl_tr_main_acct);
		       vl_count := vl_count + 1;
                    END IF;

                    IF va_tr_dept_id_col IS NOT NULL THEN
                       dbms_sql.column_value(vl_legis_cursor, vl_count,
			                         vl_tr_dept_id);
		       vl_count := vl_count + 1;
                    END IF;

                    IF va_advance_type_col IS NOT NULL THEN
                       dbms_sql.column_value(vl_legis_cursor, vl_count,
			                         vl_advance_type);
                    END IF;

                    IF ( FND_LOG.LEVEL_STATEMENT >=
			             FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
		     l_module_name,'Ref 1-'||NVL(vl_legis_ref,'Ref Null')) ;
                      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
					            l_module_name,'P Law-'||
                                NVL(va_public_law_code_val, 'P Law Null')) ;
                      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
			             	   l_module_name,'Amt:'||
                                NVL(TO_CHAR(vl_legis_amount), 'Amt Null')) ;
                    END IF ;

                END IF;
--------------------------------------------------------------------------------
	----------- Public Law Specific Processing -----------+
        -- If the public law code is required then check the journal source.
	-- If the journal source is YE Close and Budgetary Transaction then
	-- get the public law code from BE details table.  If the journal
	-- source is not these two, then get the public law code from the
	-- corresponding attribute field on the je line.

                IF va_public_law_code_flag = 'N' THEN
                   va_public_law_code_val := '       ' ;
                 ELSE

                          -- added KS
                        IF (va_balance_type_flag  IN ('B' , 'S') ) THEN
                          va_balance_type_val  := 'B'          ;
                         elsif (va_balance_type_flag  IN ('E' , 'S') ) THEN
                          va_balance_type_val     := 'E'      ;
                         END IF;

		  IF vl_legis_ref IS NOT NULL THEN

                     BEGIN
                       SELECT  public_law_code
                       INTO    va_public_law_code_val
                       FROM    fv_be_trx_dtls
                       WHERE   transaction_id  = vl_legis_ref
                       AND     set_of_books_id = vp_set_of_books_id ;

                       IF va_public_law_code_val is NULL THEN
                          -- Create Exception
                          v_amount          := vl_legis_amount ;
                          v_period_activity := vl_legis_amount ;
                          vl_sgl_acct_num_bak := v_sgl_acct_num;
                          v_sgl_acct_num  := vl_acct_num  ;
                          va_public_law_code_val := NULL;
                          v_record_category := 'PUBLIC_LAW_NOT_DEFINED' ;
                          IF ( FND_LOG.LEVEL_STATEMENT >=
			              FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                	          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
			           l_module_name,'Creating exception :'||
				               v_record_category);
                 	   END IF;

                          create_facts_record ;
                          v_record_category :=  'REPORTED';
                	  v_sgl_acct_num  := vl_sgl_acct_num_bak  ;
                          vl_exception_cat := 1;
            	       END IF ;

                      EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                               v_amount           :=   vl_legis_amount ;
                               v_period_activity  :=   vl_legis_amount ;
                               vl_sgl_acct_num_bak := v_sgl_acct_num;
                               v_sgl_acct_num    := vl_acct_num  ;
                               va_public_law_code_val := NULL;
                               v_record_category := 'PUBLIC_LAW_NOT_DEFINED' ;
                               IF ( FND_LOG.LEVEL_STATEMENT >=
				           FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				        l_module_name,'Creating exception :'||
  				                     v_record_category);
                               END IF;
                               create_facts_record ;
                               v_record_category :=  'REPORTED';
                               v_sgl_acct_num    := vl_sgl_acct_num_bak  ;
                               vl_exception_cat := 1;
                          WHEN INVALID_NUMBER THEN
                               v_amount       :=   vl_legis_amount ;
                               v_period_activity  :=   vl_legis_amount ;
                               vl_sgl_acct_num_bak := v_sgl_acct_num;
                               v_sgl_acct_num    := vl_acct_num  ;
                               va_public_law_code_val := NULL;
                               v_record_category := 'PUBLIC_LAW_NOT_DEFINED' ;
                               IF ( FND_LOG.LEVEL_STATEMENT >=
			            FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				       l_module_name,'Creating exception :'||
				                     v_record_category);
                               END IF;
                	       create_facts_record ;
                               v_record_category :=  'REPORTED';
              		       v_sgl_acct_num    := vl_sgl_acct_num_bak  ;
                      	       vl_exception_cat := 1;
                     END ;

		  ELSE -- vl_legis_ref IS NULL

			-- If an attribute column is setup but
			-- the journal line does not contain a value, then
			-- create an exception.
			IF  va_pl_code_col IS NOT NULL THEN
		            IF vl_pl_code IS NULL THEN
			       v_amount           :=   vl_legis_amount ;
                               v_period_activity  :=   vl_legis_amount ;
                               vl_sgl_acct_num_bak := v_sgl_acct_num;
                               v_sgl_acct_num    := vl_acct_num  ;
                               va_public_law_code_val := NULL;
                               v_record_category := 'PUBLIC_LAW_NOT_DEFINED' ;
                               IF ( FND_LOG.LEVEL_STATEMENT >=
				         FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				     l_module_name,'Creating exception :'||
                                                v_record_category);
                               END IF;
                               create_facts_record ;
                               v_record_category :=  'REPORTED';
                               v_sgl_acct_num    := vl_sgl_acct_num_bak  ;
                               vl_exception_cat := 1;
			     ELSE
                               va_public_law_code_val := SUBSTR(vl_pl_code,1,7);
			   END IF;
			END IF;
		  END IF;

		END IF;
--------------------------------------------------------------------------------
                --- Legislative Indicator specific processing --+
                IF va_legis_ind_flag = 'Y' THEN
                     -- Get the Transaction Type Value
                     BEGIN
                         SELECT  transaction_type_id
                         INTO    vl_tran_type
                         FROM    fv_be_trx_dtls
                         WHERE   transaction_id  = vl_legis_ref
                         AND     set_of_books_id = vp_set_of_books_id ;
                         -- Get the Legislation Indicator Value
                         -- from fv_be_transaction_types table.
                     	 SELECT legislative_indicator
                     	 INTO   va_legis_ind_val
                     	 FROM   fv_be_transaction_types
                     	 WHERE  be_tt_id = vl_tran_type
                         AND    set_of_books_id  = vp_set_of_books_id ;

                         IF ( FND_LOG.LEVEL_STATEMENT >=
				    FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
					        l_module_name,
                                  'Legislation Indicator-'||
                                   NVL(va_legis_ind_val,'Legis Null')) ;
                         END IF ;
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                             -- Cannot derive legislation indicator. Create
                             -- Exception Record
                             vl_sgl_acct_num_bak := v_sgl_acct_num;
                             v_sgl_acct_num  := vl_sgl_acct_num ;
                             v_amount        := vl_legis_amount ;

                             IF NOT v_year_gtn2001 THEN
                                v_record_category := 'NO_LEGIS_INDICATOR' ;
                                IF ( FND_LOG.LEVEL_STATEMENT >=
					  FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
						       l_module_name,
                                    'Creating Exception: '||v_record_category) ;
                                END IF ;
                                create_facts_record ;
                                v_sgl_acct_num    := vl_sgl_acct_num_bak ;
                             END IF;
                             v_record_category :=  'REPORTED';
                             -- Also set the Legislation Indicator to
                             -- default  value 'A'
                             va_legis_ind_val := 'A' ;
                             vl_exception_cat := 1;
                         WHEN INVALID_NUMBER THEN
                             -- Cannot derive legislation indicator. Create
                             -- Exception Record

                             vl_sgl_acct_num_bak := v_sgl_acct_num;
                             v_sgl_acct_num  := vl_sgl_acct_num ;
                             v_amount        := vl_legis_amount ;
                             IF NOT v_year_gtn2001 THEN
                                 v_record_category := 'NO_LEGIS_INDICATOR' ;
                                 IF ( FND_LOG.LEVEL_STATEMENT >=
				     FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
						      l_module_name,
                                    'Creating Exception: '||v_record_category) ;
                                 END IF ;
                                 create_facts_record ;
                                 v_sgl_acct_num   := vl_sgl_acct_num_bak ;
                             END IF;
                             v_record_category :=  'REPORTED';
                             -- Also set the Legislation Indicator to
                    	     -- default  value 'A'
                    	     va_legis_ind_val := 'A' ;
                             vl_exception_cat := 1;
                     END ;
                END IF;
--------------------------------------------------------------------------------
               --- Advance Type specific processing --+
               -- If the advance type is required then check the journal source.
               -- If the journal source is YE Close and Budgetary Transaction
               -- then get the advance type from BE details table. If the
               -- journal source is not these two, then get the advance type
               -- from the corresponding attribute fields on the je line.
                IF va_advance_flag = 'Y' THEN

                  IF vl_legis_ref IS NOT NULL THEN
                    BEGIN
                        SELECT  advance_type
                        INTO    va_advance_type_val
                        FROM    fv_be_trx_dtls
                        WHERE   transaction_id  = vl_legis_ref
                        AND     set_of_books_id = vp_set_of_books_id ;
                        IF ( FND_LOG.LEVEL_STATEMENT >=
			           FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				             l_module_name,'Advance Type - '||
                            NVL(va_advance_type_val, 'Advance Type Null')) ;
                        END IF ;
                        -- If the advance_type value is null then set it to 'X'
                        IF va_advance_type_val IS NULL THEN
                            va_advance_type_val := 'X';
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                            va_advance_type_val := 'X';
                    END;

                  ELSE
                        -- vl_legis_ref is null
                        -- If an attribute column is not set up for advance type
                        -- then report blank.  If a column is setup but
                        -- the journal line does not contain a value, then
                        -- report 'X'
                        IF  va_advance_type_col IS NULL THEN
                            va_advance_type_val := 'X';
                         ELSE
                           IF vl_advance_type IS NULL THEN
                             va_advance_type_val := 'X';
                           ELSE
                             va_advance_type_val := SUBSTR(vl_advance_type,1,1);
                           END IF;
                        END IF;

                  END IF;

                END IF;
--------------------------------------------------------------------------------
             -- Transfer Acct specific processing --+
             -- If the transfer info is required then check the journal source.
             -- If the journal source is YE Close and Budgetary Transaction then
             -- get the transfer info from BE details table.  If the journal
             -- source is not these two, then get the transfer info from the
             -- corresponding attribute fields on the je line.
                IF va_transfer_ind = 'Y' THEN

                  IF vl_legis_ref IS NOT NULL THEN
                    BEGIN
                        SELECT  dept_id,
                                main_account
                        INTO    va_transfer_dept_id,
                        	va_transfer_main_acct
                        FROM    fv_be_trx_dtls
                        WHERE   transaction_id  = vl_legis_ref
                        AND     set_of_books_id = vp_set_of_books_id ;
                        IF ( FND_LOG.LEVEL_STATEMENT >=
				      FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				        l_module_name,'Transfer Dept ID- '||
                            NVL(va_transfer_dept_id, 'Transfer Dept ID Null'));
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				         l_module_name,'Transfer Main Acct-'||
                                      NVL(va_transfer_main_acct,
				             'Transfer Main Acct Null'));
                        END IF ;
                        -- If the Transfer values are null then set default
                        -- values Since both dept_id and main_acct are null
                        -- or both have values, test if one of them is null
                        IF va_transfer_dept_id IS NULL THEN
                               v_amount           :=   vl_legis_amount ;
                               v_period_activity := vl_legis_amount ;
                               vl_sgl_acct_num_bak := v_sgl_acct_num;
                               v_sgl_acct_num    := vl_acct_num  ;
                               va_transfer_dept_id   := NULL;
                               va_transfer_main_acct := NULL;
                              v_record_category := 'TRANSFER_DTLS_NOT_DEFINED' ;
                               IF ( FND_LOG.LEVEL_STATEMENT >=
				         FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				         l_module_name,'Creating exception :'||
                                                v_record_category);
                               END IF;
                               create_facts_record ;
                               v_sgl_acct_num    := vl_sgl_acct_num_bak  ;
                               vl_exception_cat := 1;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                               v_amount           :=   vl_legis_amount ;
                               v_period_activity := vl_legis_amount ;
                               vl_sgl_acct_num_bak := v_sgl_acct_num;
                               v_sgl_acct_num    := vl_acct_num  ;
                               va_transfer_dept_id   := NULL;
                               va_transfer_main_acct := NULL;
                              v_record_category := 'TRANSFER_INFO_NOT_DEFINED' ;
                               IF ( FND_LOG.LEVEL_STATEMENT >=
			           FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				       l_module_name,'Creating exception :'||
                                                v_record_category);
                               END IF;
                               create_facts_record ;
                               v_sgl_acct_num    := vl_sgl_acct_num_bak  ;
                               vl_exception_cat := 1;
                    END;

                  ELSE
			-- vl_legis_ref is null
                        -- If an attribute column is setup but
                        -- the journal line does not contain a value, then
                        -- create an exception.
                        IF  va_tr_main_acct_col IS NOT NULL THEN
                            IF (vl_tr_main_acct IS NULL OR
				vl_tr_dept_id IS NULL)
				THEN
                               v_amount           :=   vl_legis_amount ;
                               v_period_activity  :=   vl_legis_amount ;
                               vl_sgl_acct_num_bak := v_sgl_acct_num;
                               v_sgl_acct_num    := vl_acct_num  ;
                               va_transfer_main_acct := NULL;
			       va_transfer_dept_id := NULL;
                              v_record_category := 'TRANSFER_INFO_NOT_DEFINED' ;
                               IF ( FND_LOG.LEVEL_STATEMENT >=
				        FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				       l_module_name,'Creating exception :'||
                                                v_record_category);
                               END IF;
                               create_facts_record ;
                               v_record_category :=  'REPORTED';
                               v_sgl_acct_num    := vl_sgl_acct_num_bak  ;
                               vl_exception_cat := 1;
                          ELSE
                           va_transfer_main_acct := SUBSTR(vl_tr_main_acct,1,4);
			   va_transfer_dept_id   := SUBSTR(vl_tr_dept_id,1,2);
                           END IF;
                        END IF;
                  END IF;

                END IF;
--------------------------------------------------------------------------------
                -- Update the Temp table
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
				   THEN
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				        l_module_name,' Acct - '||vl_acct_num) ;
                END IF;

                IF  vl_exception_cat = 0  THEN
            	    v_record_category := 'REPORTED'     ;
            	    v_amount      := vl_legis_amount    ;
                    v_period_activity := vl_legis_amount;
                    IF ( FND_LOG.LEVEL_STATEMENT >=
			               FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
			                        l_module_name,
			         'Created facts record  in ' || vl_period_name);
                    END IF;
	             --Added for bug 9190256.
                     IF (va_balance_type_flag  IN ('B' , 'S') ) THEN
                          va_balance_type_val  := 'B'          ;
                         elsif (va_balance_type_flag  IN ('E' , 'S') ) THEN
                          va_balance_type_val     := 'E'      ;
                     END IF;

                    create_facts_record ;
                    IF vp_retcode <> 0 THEN
                       RETURN ;
                    END IF ;
                END IF;

             END LOOP;
             -- Close the Legislative Indicator Cursor
             BEGIN
                dbms_sql.close_cursor(vl_legis_cursor);
              EXCEPTION
                WHEN OTHERS THEN
                    vp_retcode := sqlcode ;
                    VP_ERRBUF  := sqlerrm ;
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
		                l_module_name||'.close_cursor_vl_legis_cursor',
				 vp_errbuf);
                    RETURN ;
             END ;
             -- Once the Legislative Indicator or Public Law code
             -- is processesed, no need to proceed further for this
             -- acct/fund combination. Going to the Next Account
             EXIT ;

           EXCEPTION
              -- Process any Exceptions in Legislative Indicator
              -- Processing
              WHEN OTHERS THEN
                   vp_retcode := sqlcode ;
                   vp_errbuf := sqlerrm ||
                   ' [ PROCESS_FACTS_TRANSCTIONS-LEGIS IND  ] ' ;
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			              l_module_name||'message1', vp_errbuf) ;
                   RETURN ;
          END;		-- Legislative processing

      -------------- Apportionment Category Processing Starts ----------------
      ELSIF (va_appor_cat_flag = 'Y' ) THEN
            -- Derive the Apportionment Category
            -- Apportionment Category Processing done only for FACTS II
            --Bug3376230 to include va_appor_cat_val = 'A' too
            -- 2005 FACTS II Enhancemnt to include category C

            IF va_appor_cat_val = 'C'  THEN
                    va_appor_cat_b_dtl := '000';
                    va_appor_cat_b_txt :=  '';
                    va_prn_num         := '000';
                    va_prn_txt         := '';

            END IF;

            IF va_appor_cat_val IN ('A', 'B') THEN
                 IF ( FND_LOG.LEVEL_STATEMENT
			             >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
			           '++ Apportionment Category Processing ++') ;
                 END IF ;

                 -- Get the Program segment name for the current fund value
                 get_program_segment (vl_fund_value) ;

                 IF ( FND_LOG.LEVEL_STATEMENT >=
		       FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
			l_module_name, 'Fund: '||vl_fund_value||
				       ' Cat B Prog Seg: ' ||v_catb_prg_seg_name||
                                       ' PRN Prog Seg: ' || v_prn_prg_seg_name) ;
                 End If ;


                 IF ((v_catb_prg_seg_name IS NOT NULL AND
                     va_appor_cat_val = 'B' ) OR
                     (v_catb_prg_seg_name IS  NULL
                          AND va_appor_cat_val = 'A')) AND
                          V_PRN_PRG_SEG_NAME IS not null THEN
                     BEGIN
                         vl_appor_cursor := DBMS_SQL.OPEN_CURSOR  ;
                      EXCEPTION
                         WHEN OTHERS THEN
                              vp_retcode := sqlcode ;
                              vp_errbuf  := sqlerrm ;
                              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			            l_module_name||'.open_vl_appor_cursor',
				    vp_errbuf) ;
                              RETURN ;
                     END ;
            	     -- Dynamic SQL to group the amount by Fund, Acct
            	     -- and Program for the Beginning Balance
            	     -- Processing Apportionment Category for Beginning Balance
                     va_balance_type_val := 'B' ;

            	     vl_appor_period := ' AND glb.period_num = :begin_period_num
                    	     AND glb.period_year = :report_fiscal_yr ';

            	     build_appor_select(vl_acct_num,
                    	     		vl_fund_value,
                    	     		v_fiscal_yr,
                    	     		vl_appor_period,
                    	     		vl_appor_select) ;
                     BEGIN
                    	  dbms_sql.parse(vl_appor_cursor,vl_appor_select,
						                 DBMS_SQL.V7);
                      EXCEPTION
                    	  WHEN OTHERS THEN
                        	vp_retcode := sqlcode              ;
                        	vp_errbuf  := sqlerrm || ' [MAIN - APPOR]' ;
                          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			   l_module_name||'.parse_vl_appor_cursor', vp_errbuf) ;
                            	RETURN ;
                     END ;

		     -- Bind the variables
     		   dbms_sql.bind_variable(vl_appor_cursor, ':actual_flag', 'A');
     		   dbms_sql.bind_variable(vl_appor_cursor, ':fund_value',
				                        vl_fund_value);
     		   dbms_sql.bind_variable(vl_appor_cursor, ':acct_number',
							vl_acct_num);
         	   dbms_sql.bind_variable(vl_appor_cursor, ':fiscal_year',
								v_fiscal_yr);
     		   dbms_sql.bind_variable(vl_appor_cursor, ':begin_period_num',
						      v_begin_period_num);
     		   dbms_sql.bind_variable(vl_appor_cursor, ':report_fiscal_yr',
						     vp_report_fiscal_yr);
     		   dbms_sql.bind_variable(vl_appor_cursor, ':set_of_books_id',
						      vp_set_of_books_id);
     		   dbms_sql.bind_variable(vl_appor_cursor, ':currency_code',
						      vp_currency_code);


                  dbms_sql.define_column(vl_appor_cursor,1,vl_acct_num,25);
                  dbms_sql.define_column(vl_appor_cursor,2,vl_fund_value,25);
                  vl_count := 3;
         IF v_catb_prg_seg_name IS NOT NULL THEN
            dbms_sql.define_column(vl_appor_cursor,vl_count,vl_catb_program,25);
            vl_count := vl_count+1 ;
         END IF;

           dbms_sql.define_column(vl_appor_cursor,vl_count,vl_prn_program,25);
             vl_count := vl_count+1 ;

           dbms_sql.define_column(vl_appor_cursor,vl_count,v_amount);

          IF v_cohort_Seg_name IS NOT NULL THEN
             vl_count := vl_count+1 ;
              dbms_sql.define_column(vl_appor_cursor,vl_count,vl_cohort_yr,25);
          END IF ;

                  BEGIN
                         vl_exec_ret := dbms_sql.execute(vl_appor_cursor);
                   EXCEPTION
                        WHEN OTHERS THEN
                             vp_retcode := sqlcode ;
                             vp_errbuf  := sqlerrm ;
                             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
		 		l_module_name||'.execute_vl_appor_cursor',
		 			vp_errbuf) ;
                             RETURN ;
                  END ;
                     -- Reset the counter for apportionment cat b Dtl
                     -- vl_appor_ctr := 0 ;
                     LOOP
                          IF dbms_sql.fetch_rows(vl_appor_cursor) = 0 THEN
                              EXIT;
                           ELSE
                          -- Fetch the Records into Variables
                              dbms_sql.column_value(vl_appor_cursor,1,
						    vl_acct_num);
                              dbms_sql.column_value(vl_appor_cursor,2,
						    vl_fund_value);
                               vl_count := 3;

         IF v_catb_prg_seg_name IS NOT NULL THEN
                              dbms_sql.column_value(vl_appor_cursor,vl_count,
		 				    vl_catb_program);
                               vl_count := vl_count+1 ;
         END IF;
                              dbms_sql.column_value(vl_appor_cursor,vl_count,
                                                    vl_prn_program);
                               vl_count := vl_count+1 ;
                              -- v_amount holds beginning balance.
                              dbms_sql.column_value(vl_appor_cursor,vl_count,
		 				    v_amount);
                              IF v_cohort_Seg_name IS NOT NULL THEN
                                 vl_count := vl_count+1 ;
                                 dbms_sql.column_value(vl_appor_cursor,vl_count,
				                   vl_cohort_yr);
                              END IF ;

                              -- vl_appor_ctr := vl_appor_ctr + 1 ;
                 	      -- get_appor_cat_b_text(vl_program) ;
                              IF ( FND_LOG.LEVEL_STATEMENT >=
				FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              	                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				 l_module_name,'Appor Beg-->
                                 Acct: '||vl_acct_num||
              	                ' Fund: '||vl_fund_value||
                                ' Cat B Prgm: '||vl_catb_program ||
                                ' PRN Prgm: '||vl_prn_program ||
              	                ' Amt: '||v_amount) ;
                	      END IF ;
                              IF vp_retcode <> 0 THEN
                                    RETURN ;
                              END IF ;

                              --Bug#3376230
                  	      v_record_category := 'REPORTED' ;
                             -- IF va_appor_cat_val = 'A' THEN
			      get_prc_val(vl_catb_program,
					  vl_catb_rc_val, vl_catb_pgm_desc,
					  vl_catb_exception,
			                  vl_prn_program,
                                          vl_prn_rc_val, vl_prn_pgm_desc,
                                          vl_prn_exception);

                              IF vp_retcode <> 0 THEN
                                 RETURN ;
                              END IF ;

                              va_appor_cat_b_dtl := vl_catb_rc_val;
                              va_appor_cat_b_txt := vl_catb_pgm_desc;

                              IF ( FND_LOG.LEVEL_STATEMENT >=
                                FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                 l_module_name,
                                 'Cat B RC Val: '||vl_catb_rc_val||
                                 'Cat B PGM Desc: '||vl_catb_pgm_desc||
                                 'PRN RC Val: '||vl_prn_rc_val||
                                 'PRN PGM Desc: '||vl_prn_pgm_desc);
			      END IF;

                                 IF vl_catb_exception = 1 THEN
                                    v_record_category := 'VALID_CATB_CODE_NOT_FOUND';
				    vp_errbuf := 'Valid Category B Code not found '||
				    	         'for program value: '||vl_catb_program;
                                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                                      l_module_name||'.VALID_CAT_CODE_NOT_FOUND', vp_errbuf) ;

                                 va_appor_cat_b_txt := vl_catb_program;
                                 v_tbal_fund_value := vl_fund_value;

                                 create_facts_record     ;
                                 IF vp_retcode <> 0 THEN
                                    RETURN ;
                                 END IF ;
                           END IF;
 			IF vl_prn_exception = 1 THEN
                            v_record_category := 'VALID_PRN_CODE_NOT_FOUND';
                            vp_errbuf := 'Valid Program Reporting Number code '
                                      ||'not found '||
                               'for program value: '||vl_prn_program;
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                               l_module_name||'.VALID_PRN_CODE_NOT_FOUND'
                                 , vp_errbuf) ;

                                 va_appor_cat_b_txt := NULL;
                                 va_prn_txt := vl_prn_program;
                                 v_tbal_fund_value := vl_fund_value;

                                 create_facts_record     ;
                                 IF vp_retcode <> 0 THEN
                                    RETURN ;
                                 END IF ;
                              END IF;

                     -- for bug 5065974 by Adi
                     --  Moved AND to OR  Condition

                              IF (vl_catb_exception = 0 OR
                                     vl_prn_exception = 0 ) THEN
                                v_record_category := 'REPORTED' ;
                                va_appor_cat_b_dtl := vl_catb_rc_val;
                                va_appor_cat_b_txt := vl_catb_pgm_desc;
                                va_prn_num        := vl_prn_rc_val;
                                va_prn_txt         := vl_prn_pgm_desc;
                                v_tbal_fund_value := vl_fund_value;
                                v_catb_program_value    := vl_catb_program;
                                v_prn_program_value := vl_prn_program;
                                create_facts_record     ;
                                IF vp_retcode <> 0 THEN
                                   RETURN ;
                                END IF ;
                              END IF;

                	  END IF ;

            	     END LOOP ;
                     -- Close the Apportionment Category Cursor
                     BEGIN
                        dbms_sql.close_cursor(vl_appor_cursor);
                      EXCEPTION
                         WHEN OTHERS THEN
                            vp_retcode := sqlcode ;
                            vp_errbuf  := sqlerrm ;
                           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.close_vl_appor_cursor',vp_errbuf) ;
                            RETURN ;
                     END ;

             	     -- Processing Apportionment Category for Ending Balance
                     BEGIN
                        vl_appor_cursor := DBMS_SQL.OPEN_CURSOR  ;
                      EXCEPTION
                         WHEN OTHERS THEN
                              vp_retcode := sqlcode ;
                              vp_errbuf  := sqlerrm ;
                              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			           l_module_name||'.open_vl_appor_cursor',
				           vp_errbuf) ;
                              RETURN ;
                     END ;

                     va_balance_type_val := 'E' ;

            	     vl_appor_period := ' AND  GLB.PERIOD_NUM = :period_num
            	      AND GLB.PERIOD_YEAR = :report_fiscal_yr ' ;

            	     build_appor_select(vl_acct_num,
                    	     	        vl_fund_value,
                        	        v_fiscal_yr,
                    	     		vl_appor_period,
                    	     		vl_appor_select) ;

                     BEGIN
                         dbms_sql.parse(vl_appor_cursor,vl_appor_select,
			 				DBMS_SQL.V7);
                      EXCEPTION
                         WHEN OTHERS THEN
                             vp_retcode := sqlcode                      ;
                             vp_errbuf  := sqlerrm || ' [MAIN - APPOR]' ;
                             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
					l_module_name||'.parse_vl_appor_cursor',
						  vp_errbuf) ;
                             RETURN ;
                     END ;

                     -- Bind the variables
                   dbms_sql.bind_variable(vl_appor_cursor, ':actual_flag', 'A');
                   dbms_sql.bind_variable(vl_appor_cursor, ':fund_value',
						vl_fund_value);
                   dbms_sql.bind_variable(vl_appor_cursor, ':acct_number',
						vl_acct_num);
                   dbms_sql.bind_variable(vl_appor_cursor, ':fiscal_year',
						v_fiscal_yr);
                   dbms_sql.bind_variable(vl_appor_cursor, ':period_num',
 						v_period_num);
                   dbms_sql.bind_variable(vl_appor_cursor,':report_fiscal_yr',
				                vp_report_fiscal_yr);
                   dbms_sql.bind_variable(vl_appor_cursor,':set_of_books_id',
                                            vp_set_of_books_id);
                   dbms_sql.bind_variable(vl_appor_cursor, ':currency_code',
                                          vp_currency_code);


                     dbms_sql.define_column(vl_appor_cursor,1,vl_acct_num,25);
                     dbms_sql.define_column(vl_appor_cursor,2,vl_fund_value,25);
                     vl_count := 3;
              IF v_catb_prg_seg_name IS NOT NULL THEN
                   dbms_sql.define_column(vl_appor_cursor,3,vl_catb_program,25);
                 vl_count := vl_count+1 ;
              END IF ;
             dbms_sql.define_column(vl_appor_cursor,vl_count,vl_prn_program,25);
                      vl_count := vl_count+1 ;
                     dbms_sql.define_column(vl_appor_cursor,vl_count,v_amount);
                     IF v_cohort_seg_name IS NOT NULL THEN
                        vl_count := vl_count+1 ;
                         dbms_sql.define_column(vl_appor_cursor,vl_count,vl_cohort_yr, 25);
                     END IF ;
                     BEGIN
                         vl_exec_ret := dbms_sql.execute(vl_appor_cursor);
                      EXCEPTION
                         WHEN OTHERS THEN
                             vp_retcode := sqlcode ;
                             vp_errbuf  := sqlerrm ;
                             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
					l_module_name||
					'.execute_vl_appor_cursor',
					vp_errbuf) ;
                             RETURN ;
                     END ;

                     -- Reset the counter for apportionment cat b Dtl
                     -- vl_appor_ctr := 0 ;
                     LOOP
                         IF dbms_sql.fetch_rows(vl_appor_cursor) = 0 THEN
                            EXIT;
                          ELSE
                              -- Fetch the Records into Variables
                              dbms_sql.column_value(vl_appor_cursor,1,
  						vl_acct_num);
                              dbms_sql.column_value(vl_appor_cursor,2,
	  						vl_fund_value);
                       vl_count := 3;
                IF v_catb_prg_seg_name IS NOT NULL THEN
                       dbms_sql.column_value(vl_appor_cursor,vl_count,
	  						vl_catb_program);
                       vl_count := vl_count+1 ;
                END IF;
                              dbms_sql.column_value(vl_appor_cursor,vl_count,
                                                        vl_prn_program);
                          vl_count := vl_count+1 ;
                              -- v_amount holds Balance of the transaction
                       dbms_sql.column_value(vl_appor_cursor,vl_count,v_amount);
                              IF v_cohort_Seg_name IS NOT NULL THEN
                           vl_count := vl_count+1 ;
                             dbms_sql.column_value(vl_appor_cursor, vl_count,
					                          vl_cohort_yr);
                              END IF ;
                	      -- vl_appor_ctr := vl_appor_ctr + 1 ;

                	      -- get_appor_cat_b_text(vl_program) ;

                	      IF vp_retcode <> 0 THEN
                	         RETURN ;
                	      END IF ;
                              IF ( FND_LOG.LEVEL_STATEMENT >=
				FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              	                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
              	                 'Appor End --> Acct - '||vl_acct_num||
              	                 ' Fund >>>> - '||vl_fund_value||
              	                 ' Cat B Prgm >>>> - '||vl_catb_program||
                                 ' PRN  Prgm >>>> - '||vl_prn_program||
              	                 ' Amt >>>> - '||v_amount) ;
                	      END IF ;


                              v_record_category := 'REPORTED' ;
                              get_prc_val(vl_catb_program,
                                          vl_catb_rc_val, vl_catb_pgm_desc,
                                          vl_catb_exception,
					  vl_prn_program,
                                          vl_prn_rc_val, vl_prn_pgm_desc,
                                          vl_prn_exception);

                              IF vp_retcode <> 0 THEN
                                 RETURN ;
                              END IF ;

                              va_appor_cat_b_dtl := vl_catb_rc_val;
                              va_appor_cat_b_txt := vl_catb_pgm_desc;
                                 va_prn_num      := vl_prn_rc_val;
                                 va_prn_txt      := vl_prn_pgm_desc;
                              IF ( FND_LOG.LEVEL_STATEMENT >=
                                FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                 l_module_name,
                                 'Cat B RC Val: '||vl_catb_rc_val||
                                 'Cat B  PGM Desc: '||vl_catb_pgm_desc ||
				 'PRN RC Val: '||vl_catb_rc_val||
                                 'PRN PGM Desc: '||vl_catb_pgm_desc);
                              END IF;

                              IF vl_catb_exception <> 0 THEN

                                 IF vl_catb_exception = 1 THEN
                                    v_record_category := 'VALID_CATB_CODE_NOT_FOUND';
                                    vp_errbuf := 'Valid Category B Code not found '||
                                                 'for program value: '||vl_catb_program;
                                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                                     l_module_name||'.VALID_CAT_CODE_NOT_FOUND', vp_errbuf) ;


			         va_appor_cat_b_txt := vl_catb_program;
                                 v_tbal_fund_value := vl_fund_value;
                                 create_facts_record     ;
                                 IF vp_retcode <> 0 THEN
                                    RETURN ;
                                 END IF ;
                               END IF;
                              END IF;

                           IF vl_prn_exception <> 0 THEN
                              IF vl_prn_exception = 1 THEN
                                  v_record_category := 'VALID_PRN_CODE_NOT_FOUND';
                                  vp_errbuf := 'Valid Program Reporting Number Code not found '||
                                                'for program value: '||vl_prn_program;
                                   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                                   l_module_name||'.VALID_PRN_CODE_NOT_FOUND', vp_errbuf) ;


                                 va_prn_txt := vl_prn_program;
                                 v_tbal_fund_value := vl_fund_value;
                                 create_facts_record     ;
                                 IF vp_retcode <> 0 THEN
                                    RETURN ;
                                 END IF ;
                               END IF;
                              END IF;


                              IF (vl_catb_exception = 0 OR
                                  vl_prn_exception = 0) THEN
                                v_record_category := 'REPORTED' ;
                                va_appor_cat_b_dtl := vl_catb_rc_val;
                                va_appor_cat_b_txt := vl_catb_pgm_desc;
                                v_tbal_fund_value := vl_fund_value;
				v_catb_program_value   := vl_catb_program;
                                    va_prn_num := vl_prn_rc_val;
                                    va_prn_txt := vl_prn_pgm_desc;
                                v_prn_program_value := vl_prn_program;
                                create_facts_record     ;
                                IF vp_retcode <> 0 THEN
                                   RETURN ;
                                END IF ;
                              END IF;

                        END IF ;
                    END LOOP ;
                    -- Close the Apportionment Category Cursor
                    BEGIN
                        dbms_sql.close_cursor(vl_appor_cursor);
                     EXCEPTION
                        WHEN OTHERS THEN
                            vp_retcode := sqlcode ;
                            vp_errbuf  := sqlerrm ;
                            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
				l_module_name||'.close_vl_appor_cursor',
						 vp_errbuf) ;
                            RETURN ;
                    END ;
                    -- Apportionment Category B processing completed
                    -- successfully, no need to proceed further for this
                    -- acct/fund combination. Going to the Next Account
                    EXIT ;

                  ELSE -- if program segment is null
                       -- do default processing
                     -- v_amount        := vl_amount ;
                      v_amount        := ve_amount ; -- bug 5065974
                      v_sgl_acct_num  := vl_acct_num  ;

                      IF ( FND_LOG.LEVEL_EXCEPTION >=
				FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_EXCEPTION,
			     l_module_name, 'Program segment Not '||
			     'defined Or null,so doing the default processing');
                      END IF;

                      default_processing (vl_fund_value,vl_acct_num,'E',vb_amount,ve_amount);

                      EXIT; -- continue with the next account
                 END IF ; /* Program segment not null */

            END IF ;  /* Apportionment Category B */
      END IF ; /* va_apportionment_category_flag */

      --- If neither legislative nor apportionment processing
      --- is done then do default processing
      --default_processing (vl_fund_value,vl_acct_num);
      default_processing (vl_fund_value,vl_acct_num,NULL,vb_amount,ve_amount);

      -- Exit to end the Dummy Loop
      EXIT ;
     END LOOP ; /* for dummy Loop */
      -- Exit the Main loop in case no end of the cursor is reached
     IF vl_main_fetch = 0  THEN
        EXIT ;
     END IF ;
   END LOOP ; /* For the Main Cursor */

   -- Close the Main Cursor
   BEGIN
        dbms_sql.Close_Cursor(vl_main_cursor);
    EXCEPTION
        WHEN OTHERS THEN
            vp_retcode := sqlcode ;
            vp_errbuf  := sqlerrm ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
		  l_module_name||'.close_vl_main_cursor', vp_errbuf) ;
            RETURN ;
   END ;
    -- Rolling up the Inserted Data into Account Number
    -- Fund Value is also added in the roll up to accomodate ATB Process.
    -- tbal_Fund_value column will be blank for FACTS II processing.
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	                    'Rolling up to Account Number');
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	                     'tbal fund value '||v_tbal_fund_value);
    END IF ;

     /* Procedure to rollup the records */
    facts_rollup_records;

    -- Submit edit check process
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	  				 'Submitting Edit Check Process.....') ;
    END IF;

    fv_facts_edit_check.perform_edit_checks
    			(p_treasury_symbol_id => v_treasury_symbol_id ,
     			 p_facts_run_quarter  => vp_report_qtr    ,
     			 p_rep_fiscal_yr      => vp_report_fiscal_yr  ,
     			 retcode              => vl_ec_retcode    ,
     			 errbuf               => vl_ec_errbuf,
           p_period_num         => v_period_num,
           p_ledger_id          => vp_set_of_books_id)   ;


    -- Deleting zero amount records after edit check process
    DELETE FROM FV_FACTS_TEMP
    WHERE (fct_int_record_category = 'REPORTED' OR
           fct_int_record_category = 'REPORTED_NEW')
    AND amount = 0
    AND sgl_acct_number like '4%'
    AND treasury_symbol_id = v_treasury_symbol_id    ;


    -- Setting the Error Code based on the Edit Check Process
    v_g_edit_check_code := vl_ec_retcode;
    IF vl_ec_retcode IN (1, 2) THEN
        -- Set the Edit check return code to 'Warning' status for errors
        -- in edit check process (Soft errors - 1, Hard Errors - 2)
        v_edit_check_code := 1  ;
    END IF ;

  if upper(vp_facts_rep_show)='Y' then
	-- Submitting Edit Check Report
	vl_req_id := FND_REQUEST.SUBMIT_REQUEST
	('FV','FVFCCHKR','','',FALSE, vp_set_of_books_id, v_treasury_symbol_id, v_period_name,
					vp_currency_code ) ;

					commit;
	IF vl_req_id = 0 THEN
	vp_errbuf := 'Error Priniting Edit Check Report' ;
	 FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
	END IF;

	l_call_status := fnd_concurrent.wait_for_request(
						vl_req_id,
						0,
						0,
						rphase,
						rstatus,
						dphase,
						dstatus,
						message);

	IF l_call_status = FALSE THEN
		vp_errbuf := 'Can not wait for the status of Edit Check Report';
		vp_retcode := '2';
	 END IF;
  end if;



    -- Generate other files only when edit check succeeds
    IF vl_ec_retcode IN (0, 1) THEN
        /* Process only if Edit Check is valid or run mode is Final */
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Edit Check Process Completed Succesfully ');
       END IF;
       -- Generate the MAF_Sequence_Number based on the Run Mode
       DECLARE
           CURSOR c_maf_seq IS
               SELECT TO_CHAR(DECODE(vp_run_mode,'F',
                 (DECODE(MAX(maf_seq_num), NULL, 0,MAX(maf_seq_num)+1)),'P',
                 (NVL(MAX(maf_seq_num), 0))))
        	FROM fv_facts_run
        	WHERE treasury_symbol  = vp_treasury_symbol
        	AND treasury_symbol_id = v_treasury_symbol_id
        	AND facts_run_period   = v_period_num
        	AND facts_run_year     = vp_report_fiscal_yr ;
       BEGIN
          OPEN c_maf_seq;
          FETCH c_maf_seq INTO vc_maf_seq_num;
          IF c_maf_seq%NOTFOUND THEN
             vc_maf_seq_num := 1;
          END IF;
          CLOSE c_maf_seq;
       END;
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
		    'Creating FACTS Detail Record.....');
       END IF;

       -- Create Concatenated FACTS Record in the Temp table Column

       UPDATE fv_facts_temp
       SET    facts_report_info =
       	      vc_dept_regular || vc_dept_transfer || vc_fiscal_yr ||
              vc_main_account|| vc_sub_acct_symbol||lpad(vc_maf_seq_num,3,'0')||
              RPAD(NVL(program_rpt_cat_num, ' '), 3, ' ') ||
              RPAD(NVL(program_rpt_cat_txt, ' '), 25, ' ') ||
              LPAD(sgl_acct_number,4) || vc_record_indicator ||
              cohort || begin_end || indef_def_flag ||
              RPAD(NVL(appor_cat_b_dtl,' '),3,' ') ||
             RPAD(NVL(appor_cat_b_txt, ' '), 25, ' ')  ||
               rpad(NVL(public_law, ' '),7,' ') ||
              appor_cat_code ||
              authority_type || transaction_partner || transfer_dept_id ||
              transfer_main_acct || vc_transfer_to_from || reimburseable_flag||
              RPAD(year_budget_auth,4) || bea_category || borrowing_source || pya_flag || -- display PYA in 116 column on Bulk File ; FACTS II Edit Check ER
              advance_flag ||vc_current_permanent_flag|| def_liquid_flag||
              ' ' || availability_flag || ' ' || -- display blank for deficiency flag and legislation indicator ; FACTS II Edit Check ER
              RPAD(NVL(budget_function,' '),3)  ||
              LPAD(DECODE(INSTR(TO_CHAR(ABS(amount)),'.',1,1), 0,
                   TO_CHAR(ABS(amount))||'00',(SUBSTR(TO_CHAR(ABS(amount))
                   , 1, instr(to_char(abs(amount)),'.',1,1) - 1) ||
              RPAD(substr(to_char(abs(amount)), instr(to_char(abs
                  (amount)), '.',1,1) + 1, 2),2,'0'))), 17, '0') ||
              debit_credit || RPAD(' ', 258)
       WHERE fct_int_record_category = 'REPORTED_NEW'
       AND treasury_symbol_id = v_treasury_symbol_id ;

       -- Create Contact Information and Request Record Header
       -- and its concatenated output format in the Temp table
       -- Record Category is set to CNT_HDR to distinguish from
       -- detail records
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
              'Creating Contact Header Record.....FACTS II ') ;
       END IF;
       INSERT INTO FV_FACTS_TEMP
       (treasury_symbol_id,
       fct_int_record_category,
       fct_int_record_type,
       facts_report_info)
       VALUES ( v_treasury_symbol_id ,
       'REPORTED_NEW',
       'CNT_HDR',
       vc_rpt_fiscal_yr || vc_rpt_fiscal_month ||
       vp_contact_fname || vp_contact_lname || vp_contact_phone  ||
       vp_contact_extn || vp_agency_name_1 || vp_agency_name_2 ||
       vp_address_1 || vp_address_2 || vp_city || vp_state || vp_zip||
       vp_supervisor_name || vp_supervisor_phone||vp_supervisor_extn||
       vp_contact_email || vp_contact_fax || vp_contact_maiden ) ;

        -- Insert a new row in FV_FACTS_RUN Table based on the run mode
        IF vp_run_mode = 'F' Then
            UPDATE fv_facts_run
            SET    maf_seq_num = to_number(vc_maf_seq_num),
                   last_run_date = sysdate
            WHERE  treasury_symbol_id = v_treasury_symbol_id ;
            IF SQL%NOTFOUND THEN
               BEGIN
                    INSERT INTO fv_facts_run
                           (treasury_symbol_id,
                            treasury_symbol,
                            facts_run_period,
                            facts_run_year,
                            maf_seq_num,
                            last_run_date)
                     VALUES
                           (v_treasury_symbol_id,
                            vp_treasury_symbol,
                            v_period_num,
                            vp_report_fiscal_yr,
                            to_number(vc_maf_seq_num),
                            sysdate) ;
                EXCEPTION
                   WHEN OTHERS THEN
                       vp_retcode := sqlcode ;
                       vp_errbuf := sqlerrm || '[FACTS RUN UPDATE]' ;
                       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			     l_module_name||'.insert_fv_facts_run', vp_errbuf) ;
                       RETURN ;
               END ;
            END IF ;
        END IF ;
    END IF;  -- vl_ec_retcode IN (0, 1) THEN

    -- Create Detail Footnote Records
    FOR footnote_rec IN footnote_select(v_treasury_symbol_id)
            LOOP
                SELECT count(*)
                INTO   footnote_count
                FROM   fv_facts_footnote_hdr ffh,
                fv_facts_footnote_lines  ffl
                WHERE  ffh.treasury_symbol_id = footnote_rec.treasury_symbol_id
                AND    ffh.sgl_acct_number    = footnote_rec.sgl_acct_number
                AND    ffh.footnote_header_id = ffl.footnote_header_id ;
                IF footnote_count = 0 THEN
                  IF ( FND_LOG.LEVEL_STATEMENT >=
				          FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
		                            l_module_name,
                                              'Creating Footnote Records.....');
                  END IF;
                     INSERT INTO fv_facts_footnote_hdr
                            (footnote_header_id,
                             treasury_symbol_id,
                             sgl_acct_number)
                     VALUES
                            (fv_facts_footnote_hdr_s.nextval,
                             footnote_rec.treasury_symbol_id,
                             footnote_rec.sgl_acct_number);

                     INSERT INTO fv_facts_footnote_lines
                            (footnote_header_id,
                             footnote_line_id,
                             footnote_seq_number,
                             footnote_text)
                      VALUES
                            (fv_facts_footnote_hdr_s.currval,
                             fv_facts_footnote_lines_s.nextval,
                             1,
                             'Footnotes should be entered in FACTS II '||
							 'Online system');
                END IF;
            END LOOP;

	if upper(vp_facts_rep_show)='Y' then
		-- Submitting FACTS Adjusted Trial Balance Report
		vl_req_id := FND_REQUEST.SUBMIT_REQUEST ('FV','FVFCTRBR','','',FALSE,
			vp_set_of_books_id, v_acc_val_set_id, v_period_num, vp_report_fiscal_yr,
		vp_treasury_symbol, v_treasury_symbol_id,
		vp_currency_code ) ;
		commit;
		-- if concurrent request submission failed then abort process
		IF vl_req_id = 0 THEN
		vp_errbuf := 'Error submitting FACTS ATB Report ';
		vp_retcode := -1 ;
		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
		ELSE
		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
			  THEN
		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
		'Concurrent Request Id For FACTS ATB Report - ' || vl_req_id);
		END IF;

		l_call_status := fnd_concurrent.wait_for_request(
						vl_req_id,
						0,
						0,
						rphase,
						rstatus,
						dphase,
						dstatus,
						message);

		IF l_call_status = FALSE THEN
			vp_errbuf := 'Can not wait for the status of FACTS ATB Report';
			vp_retcode := '2';
			END IF;
		END IF ;

		-- Submitting FACTS Exception Report
		vl_req_id := FND_REQUEST.SUBMIT_REQUEST ('FV','FVFCTEXR','','',FALSE,
			vp_set_of_books_id, v_period_num, vp_report_fiscal_yr,
		vp_treasury_symbol, v_treasury_symbol_id,
		vp_currency_code ) ;
		commit;
		-- if concurrent request submission failed then abort process
		IF vl_req_id = 0 THEN
			vp_errbuf := 'Error submitting FACTS Exception Report Process';
			vp_retcode := -1 ;
			FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
								vp_errbuf) ;
		ELSE
			IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
					THEN
			FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'Concurrent Request Id for FACTS Exception Report - '||vl_req_id);
			END IF;
			l_call_status := fnd_concurrent.wait_for_request(
							vl_req_id,
								0,
								0,
							rphase,
							rstatus,
							dphase,
							dstatus,
							message);

			     IF l_call_status = FALSE THEN
				      vp_errbuf := 'Can not wait for the status of '||
							'FACTS Exception Report';
				      vp_retcode := '2';
			     END IF;

		END IF;
	end if;
EXCEPTION
    WHEN OTHERS THEN
        vp_retcode := sqlcode ;
        vp_errbuf := sqlerrm ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.final_exception', vp_errbuf) ;

END process_facts_transactions;
--------------------------------------------------------------------------------
--    Processes exception records based on the exception category.
--------------------------------------------------------------------------------
PROCEDURE get_ussgl_acct_num
            (acct_num           IN  VARCHAR2,
             sgl_acct_num       OUT NOCOPY VARCHAR2,
             exception_category OUT NOCOPY VARCHAR2)
IS
  l_module_name VARCHAR2(200);
    vl_ussgl_acct_num   Varchar2(25)    ;
    vl_acct_type        Varchar2(1)     ;
    vl_parent           Varchar2(60)    ;
    vl_ussgl_enabled    Varchar2(1)     ;
    vl_reporting_type   Varchar2(1)     ;
    vl_exists           Varchar2(1)     ;
BEGIN
  l_module_name := g_module_name || 'get_ussgl_acct_num';
    -- Validate the Account number and return the corresponding SGL
    -- number or parent for getting attributes.
    -- Verify whether the account number exists in FV_FACTS_ATTRIBUTES table
    -- Validate the USSGL Account Number
    -- Reset Account Attributes Flag
    v_acct_attr_flag := 'N' ;
    get_ussgl_info(acct_num,
        vl_ussgl_enabled,
        vl_reporting_type) ;
    IF vp_retcode <> 0 THEN
        RETURN ;
    END IF ;
    IF vl_ussgl_enabled IS NOT NULL THEN    -- Main acct No Validation
       IF vl_ussgl_enabled = 'N' THEN
          -- Generate the Exception 'USSGL_DISABLED'
          sgl_acct_num    := acct_num     ;
          exception_category  := 'USSGL_DISABLED'     ;
          RETURN ;
       END IF ;
       IF vl_reporting_type = '1'  THEN
          -- Account Number is not a valid FACTS II Account
          -- skip the transaction and go ahead with the next.
          sgl_acct_num    := acct_num     ;
          exception_category  := 'NON_FACTSII'    ;
          RETURN ;
       END IF ;
       BEGIN   -- checking Account in fv_facts_attributes table
            SELECT 'X'
            INTO vl_exists
            FROM fv_facts_attributes
            WHERE facts_acct_number = acct_num
            AND set_of_books_id = vp_set_of_books_id ;
            -- Account is a valid USSGL account and exists
            -- in Attributes table. It is a valid account
            -- and no further validation is done to find
            -- its account type.
            exception_category      := NULL                 ;
            sgl_acct_num            := acct_num    ;
            RETURN                                          ;
        EXCEPTION   -- checking Account in Fv_Facts_attributes table
            WHEN NO_DATA_FOUND THEN
                -- Account doesn't exist in Attributes table
                -- Exceptions will be raised based on the Account
                -- type.
                get_account_type(acct_num, vl_acct_type) ;
                IF vp_retcode <> 0 THEN
                    RETURN ;
                END IF ;
                IF vl_acct_type IN ('D', 'C') THEN
                    -- Budgetary Acct for with no attributes
                    sgl_acct_num       := acct_num   ;
                    exception_category :='BUD_ACCT_NOT_SETUP' ;
                    RETURN;
                 ELSE
                    -- Account is a Proprietary acct and no
                    -- reportable exception or further processing
                    -- is required.
                    sgl_acct_num        :=  acct_num             ;
                    exception_category  := 'NON_BUD_ACCT'       ;
                    RETURN ;
                END IF ;
        END ;  -- checking Account in fv_facts_attributes table
    ELSE      -- Main acct No Validation -- when vl_ussgl_enabled is null
       -- Reset the holder variable
       vl_exists := NULL ;
       BEGIN
          SELECT  'X'
          INTO    vl_exists
          FROM    FV_FACTS_ATTRIBUTES
          WHERE   facts_acct_number = acct_num
          AND set_of_books_id = vp_set_of_books_id ;
          v_acct_attr_flag  := 'Y' ;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          NULL ;
       END ;
       -- Finding the parent of the Account Number in GL
       BEGIN   -- Finding Parent From GL
        -- Finding the parent
            SELECT parent_flex_value
            INTO   vl_ussgl_acct_num
            FROM   fnd_flex_value_hierarchies
            WHERE  (acct_num Between child_flex_value_low
                      AND child_flex_value_high)
            AND    flex_value_set_id = v_acc_val_set_id
            AND parent_flex_value <> 'T'
            AND parent_flex_value in
            	    (SELECT  ussgl_account
                     FROM fv_facts_ussgl_accounts
                     WHERE ussgl_account = parent_flex_value) ;
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
               'Parent in GL - ' || vl_ussgl_acct_num) ;
           END IF ;
            -- Parent Found. Perform Validations
            get_ussgl_info( vl_ussgl_acct_num,
                            vl_ussgl_enabled,
                            vl_reporting_type) ;
            IF vp_retcode <> 0 THEN
                RETURN ;
            END IF ;
            IF vl_ussgl_enabled IS NOT NULL THEN
                IF vl_ussgl_enabled = 'N' THEN
                    -- Generate the Exception 'USSGL_DISABLED'
                    sgl_acct_num        := vl_ussgl_acct_num    ;
                    exception_category  := 'USSGL_DISABLED'     ;
                    RETURN ;
                END IF ;
                IF vl_reporting_type = '1'  THEN
                    -- Account Number is not a valid candidate for FACTS II
                    -- reporting. Transaction is skipped with no Exception
                    sgl_acct_num        := vl_ussgl_acct_num    ;
                    exception_category  := 'NON_FACTSII' ;
                    RETURN ;
                END IF ;
                IF vl_exists IS NOT NULL THEN
                    IF ( FND_LOG.LEVEL_STATEMENT >=
			        FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				                       l_module_name,
                				  'Valid Parent [vl_exists] ') ;
                    END IF ;
                    -- Parent is a Valid USSGL Account
                   exception_category  := NULL ;
                   sgl_acct_num    := vl_ussgl_acct_num ;
                   RETURN ;
                ELSE
                   BEGIN
                       SELECT 'X'
                       INTO vl_exists
                       FROM fv_facts_attributes
                       WHERE facts_acct_number = vl_ussgl_acct_num
                       AND set_of_books_id = vp_set_of_books_id ;
                       -- Parent is a valid USSGL account and exists
                       -- in Attributes table. It is a valid account
                       -- and no further validation is done to find
                       -- its account type.
                             exception_category      := NULL         ;
                             SGL_ACCT_NUM            := vl_ussgl_acct_num    ;
                       RETURN                      ;
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                       -- Parent doesn't exist in Attributes table
                       -- Exceptions will be raised based on the Account
                       -- type.
                       get_account_type(vl_ussgl_acct_num, vl_acct_type) ;
                       IF vp_retcode <> 0 THEN
                          RETURN ;
                       END IF ;
                       IF vl_acct_type IN ('D', 'C') THEN
                          -- Budgetary Acct for with no attributes
                          sgl_acct_num       := vl_ussgl_acct_num   ;
                          exception_category :='BUD_ACCT_NOT_SETUP' ;
                          RETURN ;
                       ELSE
                          -- Account is a Proprietary acct and no
                          -- reportable exception or further processing
                          -- is required.
                          sgl_acct_num        :=  vl_ussgl_acct_num     ;
                          exception_category  := 'NON_BUD_ACCT'       ;
                          RETURN  ;
                       END IF ;
                   END ;
                END IF ;
            ELSE
                -- Parent not exist in FV_FACTS_USSGL_ACCOUNTS table.
                   get_account_type(vl_ussgl_acct_num, vl_acct_type) ;
                   IF vp_retcode <> 0 THEN
                      RETURN ;
                   END IF ;
                   IF vl_acct_type IN ('D', 'C') THEN
                      -- Budgetary Acct for with no attributes
                      sgl_acct_num       := vl_ussgl_acct_num   ;
                      exception_category :='BUD_ACCT_NOT_SETUP' ;
                      RETURN ;
                   ELSE
                     -- Account is a Proprietary acct and no
                     -- reportable exception or further processing
                     -- is required.
                     sgl_acct_num        :=  vl_ussgl_acct_num     ;
                     Exception_category  := 'NON_BUD_ACCT'       ;
                     RETURN  ;
                  END IF ;
            END IF ;
       EXCEPTION   /* Finding Parent From GL */
            WHEN NO_DATA_FOUND THEN
                get_account_type(acct_num, vl_acct_type) ;
                IF vp_retcode <> 0 THEN
                      RETURN ;
                END IF ;
                IF vl_acct_type IN ('D', 'C') THEN
                       -- Budgetary Acct for with no attributes
                       sgl_acct_num       := acct_num   ;
                       exception_category :='BUD_ACCT_NOT_SETUP' ;
                       RETURN ;
                 ELSE
                       -- Account is a Proprietary acct and no
                       -- reportable exception or further processing
                       -- is required.
                       sgl_acct_num        := acct_num     ;
                       exception_category  := 'NON_BUD_ACCT'       ;
                       RETURN                                      ;
                END IF ;
            WHEN TOO_MANY_ROWS THEN
                     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
                    'More then one Parent for '||acct_num) ;
                -- Too Many Parents. Process Exception
                sgl_acct_num        :=  acct_num                ;
                exception_category  := 'USSGL_MULTIPLE_PARENTS' ;
                RETURN ;
       END ;   /* Finding Parent From GL */
    END IF ; /* Main acct No Validation */
EXCEPTION
    WHEN OTHERS THEN
        vp_retcode  := sqlcode ;
        vp_errbuf   := sqlerrm || ' [GET_USSGL_ACCOUNT_NUM] ' ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.final_exception', vp_errbuf) ;
        RETURN;
END get_ussgl_acct_num ;
--------------------------------------------------------------------------------
-- Inserts a new record into FV_FACTS_TEMP table with the current
-- values from the  global variables.
--------------------------------------------------------------------------------
PROCEDURE create_facts_record
IS
  l_module_name VARCHAR2(200);
   vl_parent_sgl_acct_num fv_facts_temp.parent_sgl_acct_number%TYPE;
  l_year_budget_auth VARCHAR2(3);
BEGIN
  l_module_name := g_module_name || 'create_facts_record';
    IF v_year_gtn2001
        THEN va_legis_ind_val := ' ';
    END IF;

   IF v_amount = 0 THEN
      l_year_budget_auth  := '   ';
    ELSE
      l_year_budget_auth := v_year_budget_auth;
   END IF;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	 				'Creating FACTS Record') ;
   END IF ;

   IF va_pya_ind_flag IS NOT NULL AND va_pya_ind_flag = 'Y' THEN
      va_pya_ind_val :='X';
   ELSE
      va_pya_ind_val:=' ';
   END IF;

   INSERT INTO FV_FACTS_TEMP
          (SGL_ACCT_NUMBER ,
          COHORT          ,
          BEGIN_END           ,
          INDEF_DEF_FLAG      ,
          APPOR_CAT_B_DTL     ,
          APPOR_CAT_B_TXT     ,
          PUBLIC_LAW          ,
          APPOR_CAT_CODE      ,
          AUTHORITY_TYPE      ,
          TRANSACTION_PARTNER     ,
          REIMBURSEABLE_FLAG      ,
          BEA_CATEGORY            ,
          BORROWING_SOURCE    ,
          DEF_LIQUID_FLAG     ,
          DEFICIENCY_FLAG     ,
          AVAILABILITY_FLAG   ,
          LEGISLATION_FLAG    ,
          AMOUNT              ,
          DEBIT_CREDIT        ,
          TREASURY_SYMBOL_ID      ,
          FCT_INT_RECORD_CATEGORY ,
          FCT_INT_RECORD_TYPE ,
          FACTS_REPORT_INFO       ,
          TBAL_FUND_VALUE     ,
          TBAL_INDICATOR      ,
          BUDGET_FUNCTION     ,
          ADVANCE_FLAG        ,
          TRANSFER_DEPT_ID    ,
          TRANSFER_MAIN_ACCT  ,
          YEAR_BUDGET_AUTH    ,
          period_activity     ,
          parent_sgl_acct_number,
          PROGRAM_RPT_CAT_NUM,
	  PROGRAM_RPT_CAT_TXT,
          SEGMENT1,
          SEGMENT2,
          PYA_FLAG)
    VALUES (v_sgl_acct_num      ,
            va_cohort       ,
            va_balance_type_val ,
            va_def_indef_val    ,
            va_appor_cat_b_dtl  ,
            va_appor_cat_b_txt      ,
            va_public_law_code_val  ,
            va_appor_cat_val    ,
            va_authority_type_val   ,
            va_transaction_partner_val,
            va_reimburseable_val    ,
            va_bea_category_val     ,
            va_borrowing_source_val ,
            va_def_liquid_flag  ,
            va_deficiency_val   ,
            va_availability_flag    ,
            va_legis_ind_val    ,
            v_amount        ,
            NULL            ,
            v_treasury_symbol_id    ,
            v_record_category   ,
            'BLK_DTL'       ,
            NULL            ,
            v_tbal_fund_value   ,
            v_tbal_indicator    ,
            va_budget_function  ,
            va_advance_type_val ,
            va_transfer_dept_id ,
            va_transfer_main_acct   ,
            l_year_budget_auth  ,
            v_period_activity   ,
            vl_parent_sgl_acct_num,
            va_prn_num,
            va_prn_txt,
            v_catb_program_value,
            v_prn_program_value,
            va_pya_ind_val) ;
EXCEPTION
    WHEN OTHERS THEN
    vp_retcode  :=  sqlcode ;
    vp_errbuf   :=  sqlerrm || ' [CREATE_FACTS_RECORD] ' ;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.final_exception', vp_errbuf) ;
    RETURN;
END create_facts_record ;
--------------------------------------------------------------------------------
-- This procedure selects the attributes for the Account number
-- segment from FV_FACTS_ATTRIBUTES table and load them into global
-- variables for usage in the FACTS Main process. It also calculates
-- one time pull up values for the account number that does not
-- require drill down into GL transactions.
--------------------------------------------------------------------------------
PROCEDURE load_facts_attributes (acct_num Varchar2,
                 		 fund_val Varchar2,
				 ve_amount number)
IS
  l_module_name VARCHAR2(200);
    vl_financing_acct_flag  VARCHAR2(1)     ;
    vl_established_fy       NUMBER      ;
    vl_resource_type        VARCHAR2(80)    ;
    vl_fund_category        VARCHAR2(1) ;
    -- Back up for the global variabe v_sgl_acct_num
    vl_sgl_acct_num         VARCHAR2(25)    ;
    vl_dummy		    NUMBER;
BEGIN
  l_module_name := g_module_name || 'load_facts_attributes';
    BEGIN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
					'LOAD - Acct Num -> '||acct_num) ;
      END IF;
        SELECT  balance_type,
        	public_law_code,
        	reimburseable_flag,
        	DECODE(availability_time, 'N', ' ', availability_time),
        	bea_category,
        	apportionment_category,
        	DECODE(substr(transaction_partner,1,1),'N',' ',
            	substr(transaction_partner,1,1)),
        	borrowing_source,
        	definite_indefinite_flag,
        	legislative_indicator,
        	authority_type,
        	deficiency_flag,
        	function_flag,
        	advance_flag,
        	transfer_flag,
          pya_flag
        INTO    va_balance_type_flag,
        	va_public_law_code_flag,
        	va_reimburseable_flag,
        	va_availability_flag,
        	va_bea_category_flag,
        	va_appor_cat_flag,
        	va_transaction_partner_val,
        	va_borrowing_source_flag,
        	va_def_indef_flag,
        	va_legis_ind_flag,
        	va_authority_type_flag,
        	va_deficiency_flag,
        	va_function_flag,
        	va_advance_flag,
        	va_transfer_ind,
          va_pya_ind_flag
        FROM    fv_facts_attributes
        WHERE   facts_acct_number = acct_num
        AND     set_of_books_id = vp_set_of_books_id ;
        IF NOT v_year_gtn2001 THEN
            va_advance_flag  := ' ';
            va_transfer_ind  := ' ';
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             vp_retcode := -1 ;
             vp_errbuf := 'Error! No Attributes Definied for the Account - ' ||
             v_acct_num || ' [LOAD_FACTS_ATTRIBURES]' ;
               FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
	   					    vp_errbuf) ;
             RETURN;
        WHEN OTHERS THEN
             vp_retcode := sqlcode ;
             vp_errbuf  := sqlerrm ;
               FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	 						vp_errbuf) ;
             RETURN;
    END ;

--------------------------------------------------------------------------------
    -- Get the attribute column names for public_law_code and other
    -- values

    BEGIN

       SELECT  factsII_pub_law_code_attribute,
               factsII_advance_type_attribute,
               factsII_tr_main_acct_attribute,
               factsII_tr_dept_id_attribute
       INTO    va_pl_code_col, va_advance_type_col,
               va_tr_main_acct_col, va_tr_dept_id_col
       FROM    fv_system_parameters;


       IF (va_pl_code_col IS NULL OR
           va_advance_type_col IS NULL OR
           va_tr_main_acct_col IS NULL OR
           va_tr_dept_id_col IS NULL)
         THEN
           v_facts_attributes_setup := FALSE;
        ELSE
           v_facts_attributes_setup := TRUE;
       END IF;

     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
               WHEN OTHERS THEN
                 vp_retcode := sqlcode ;
                 vp_errbuf  := sqlerrm ;
                 FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
	 			l_module_name||'.select1', vp_errbuf) ;
                 RETURN;
    END;
--------------------------------------------------------------------------------
    -- Getting the One time Pull up Values
    BEGIN
        SELECT  UPPER(fts.resource_type),
        	def_indef_flag,
        	ffp.fund_category
        INTO    vl_resource_type,
        	va_def_indef_val,
        	vl_fund_category
        FROM    fv_treasury_symbols   fts,
        	fv_fund_parameters    ffp
        WHERE   ffp.treasury_symbol_id  = fts.treasury_symbol_id
        AND     ffp.fund_value      = fund_val
    	AND     fts.treasury_symbol = vp_treasury_symbol
        AND     fts.set_of_books_id     = vp_set_of_books_id
        AND     ffp.set_of_books_id     = vp_set_of_books_id  ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             vp_retcode := -1 ;
             vp_errbuf := 'Error getting Fund Category value for the fund - '||
             fund_val || ' [LOAD_FACTS_ATTRIBURES]' ;
               FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
				l_module_name||'.select2', vp_errbuf) ;
             RETURN;
        WHEN OTHERS THEN
             vp_retcode := sqlcode ;
             vp_errbuf  := sqlerrm  || ' [LOAD_FACTS_ATTRIBURES]' ;
             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
					l_module_name||'.select2', vp_errbuf) ;
             RETURN;
    END ;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	  				'Get ending balance to report amount '||
		                  'for exception records.');
    END IF;

  /* ---- for bug 5065974
   calc_balance (fund_val,
                 acct_num,
                 v_period_num,
                 vp_report_fiscal_yr,
                 'E',
                 v_fiscal_yr,
                 v_amount,
                 vl_dummy);

   -----------------------------------------  */

    v_amount := ve_amount;   -- now amount passed as parameter , bug 5065974

    -- Deriving Indefinite Definite Flag
    IF va_def_indef_flag <> 'Y' THEN
       va_def_indef_val := ' ' ;
     ELSE
       IF va_def_indef_val is NULL OR
          LTRIM(RTRIM(va_def_indef_val)) = '' THEN
          -- Create Exception
          vl_sgl_acct_num := v_sgl_acct_num ;
          v_sgl_acct_num      := acct_num  ;
          v_record_category   := 'INDEF_DEF_NOT_DEFINED' ;
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
				'Creating Exception: '||v_record_category);
          END IF;
          create_facts_record ;
          -- Reset the value back to v_sgl_acct_number
          v_sgl_acct_num  := vl_sgl_acct_num ;
       END IF ;
    END IF ;

    -- Deriving Public Law Code Flag
    IF va_public_law_code_flag = 'N' THEN
       va_public_law_code_val := '       ' ;
    END IF ;

    -- Deriving Apportionment Category Code
    IF va_appor_cat_flag = 'Y' THEN
       IF vl_fund_category IN ('A','S') THEN
           va_appor_cat_val := 'A' ;
        ELSIF vl_fund_category IN ('B','T') THEN
           va_appor_cat_val := 'B' ;
        ELSIF vl_fund_category IN ('C','R') THEN
           va_appor_cat_val := 'C' ;
        ELSE
           va_appor_cat_val := ' ' ;
       END IF ;
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
						'Acct - ' || acct_num ||
           ' Fund cat - ' || vl_fund_category || ' Appr Cat - ' ||
           va_appor_cat_val || ' Flag - ' || va_appor_cat_flag)  ;
       END IF ;
    ELSE
        va_appor_cat_val := ' ' ;
    END IF ;
    -- Default the Reporting Codes when the
    -- Apportionment Category is unchecked

    IF NVL(va_appor_cat_flag,'N') = 'N' THEN
       IF vl_fund_category IN ('A','B','C','R','S','T') THEN
            va_appor_cat_b_dtl := '000';
            va_appor_cat_b_txt :=  '';
            va_prn_num         := '000';
            va_prn_txt         := '';

       END IF;

       IF ( FND_LOG.LEVEL_STATEMENT >=
         FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                    l_module_name, 'Defaulting the Reporting'
                               ||'codes as the apportionment '
                                   ||'Category flag is N ') ;
       End If ;
    END IF;


    -- Deriving Authority Type
    IF va_authority_type_flag = 'N' THEN
       va_authority_type_val := ' ' ;
    ELSE
       va_authority_type_val := va_authority_type_flag  ;
    END IF ;

    -- Deriving Reimburseable Flag Value
    IF va_reimburseable_flag = 'Y' THEN
        IF vl_fund_category IN ('A', 'B', 'C') THEN
           va_reimburseable_val := 'D' ;
         ELSIF vl_fund_category IN ('R', 'S', 'T') THEN
           va_reimburseable_val := 'R' ;
         ELSE
           va_reimburseable_val := ' ' ;
        END IF ;
     ELSE
       va_reimburseable_val := ' ' ;
    END IF ;

    -- Deriving BEA Category
    IF va_bea_category_flag = 'Y'  THEN

	 -- by ks for bug 6409180
       BEGIN
           SELECT RPAD(substr(bea_category,1,5), 5)
           INTO   va_bea_category_val
           from fv_fund_parameters
           where fund_value =  fund_val
           AND    set_of_books_id   = vp_set_of_books_id;

         /*
           FROM   fv_facts_budget_accounts ffba,
                  fv_facts_federal_accounts    fffa,
                  fv_treasury_symbols      fts ,
                  fv_facts_bud_fed_accts   ffbfa
           WHERE  fts.federal_acct_symbol_id  = fffa.federal_acct_symbol_id
           AND    fffa.federal_acct_symbol_id = ffbfa.federal_acct_symbol_id
           AND    ffbfa.budget_acct_code_id   = ffba.budget_acct_code_id
           AND    fts.treasury_symbol         = vp_treasury_symbol
           AND    fts.set_of_books_id         = vp_set_of_books_id
           AND    fffa.set_of_books_id        = vp_set_of_books_id
           AND    ffbfa.set_of_books_id       = vp_set_of_books_id
           AND    ffba.set_of_books_id        = vp_set_of_books_id ;
          */

           IF va_bea_category_val IS NULL THEN
              -- Create Exception Record for BEA Category
                 v_record_category := 'BEA_CATEGORY_NOT_DEFINED' ;
             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
			 	 THEN
	           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
						'Creating Exception: '||
				   		v_record_category);
             END IF;
                 create_facts_record ;
           END IF ;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              -- Create Exception Record for BEA Category
              v_record_category := 'BEA_CATEGORY_NOT_DEFINED' ;
              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
			  	THEN
	          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
							'Creating Exception: '||
				                       v_record_category);
              END IF;
              create_facts_record ;
       END ;
     ELSE
       va_bea_category_val     := RPAD(' ', 5);
    END IF ;

    -- Deriving Budget Function
    IF va_function_flag = 'Y'  THEN
       BEGIN
           SELECT RPAD(substr(ffba.budget_function,1,3), 3)
           INTO   va_budget_function
           FROM   fv_facts_budget_accounts ffba,
                  fv_facts_federal_accounts    fffa,
                  fv_treasury_symbols      fts ,
                  fv_facts_bud_fed_accts   ffbfa
           WHERE  fts.federal_acct_symbol_id  = fffa.federal_acct_symbol_id
           AND    fffa.federal_acct_symbol_id = ffbfa.federal_acct_symbol_id
           AND    ffbfa.budget_acct_code_id   = ffba.budget_acct_code_id
           AND    fts.treasury_symbol         = vp_treasury_symbol
           AND    fts.set_of_books_id         = vp_set_of_books_id
           AND    fffa.set_of_books_id        = vp_set_of_books_id
           AND    ffbfa.set_of_books_id       = vp_set_of_books_id
           AND    ffba.set_of_books_id        = vp_set_of_books_id ;

           IF va_budget_function IS NULL THEN
               -- Create Exception Record for Budget Function
                  v_record_category := 'BUDGET_FNCTN_NOT_DEFINED' ;
             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
			 	THEN
	           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	 				'Creating Exception: '||
				   v_record_category);
             END IF;
                  create_facts_record ;
           END IF ;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                -- Create Exception Record for Budget Function
                v_record_category := 'BUDGET_FNCTN_NOT_DEFINED' ;
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
					THEN
	                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
					l_module_name,'Creating Exception: '||
					      v_record_category);
                END IF;
                create_facts_record ;
       END ;
    ELSE
        va_budget_function  := RPAD(' ', 3);
    END IF ;

    -- Deriving  Borrowing Source
    IF va_borrowing_source_flag = 'Y' THEN
        BEGIN
            SELECT RPAD(substr(ffba.borrowing_source,1,5), 5)
            INTO   va_borrowing_source_val
            FROM   fv_facts_budget_accounts     ffba,
                   fv_facts_federal_accounts    fffa,
                   fv_treasury_symbols          fts ,
                   fv_facts_bud_fed_accts       ffbfa
            WHERE  fts.federal_acct_symbol_id  = fffa.federal_acct_symbol_id
            AND    fffa.federal_acct_symbol_id = ffbfa.federal_acct_symbol_id
            AND    ffbfa.budget_acct_code_id   = ffba.budget_acct_code_id
            AND    fts.treasury_symbol         = vp_treasury_symbol
            AND    fts.set_of_books_id         = vp_set_of_books_id
            AND    fffa.set_of_books_id        = vp_set_of_books_id
            AND    ffbfa.set_of_books_id       = vp_set_of_books_id
            AND    ffba.set_of_books_id        = vp_set_of_books_id ;

            IF va_borrowing_source_val IS NULL THEN
                -- Create Exception Record for Borrowing Source
                v_record_category := 'B_SOURCE_NOT_DEFINED'    ;
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
					 THEN
	                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				l_module_name,'Creating Exception: '||
				      v_record_category);
                END IF;
                create_facts_record                             ;
            END IF ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- Create Exception Record for Borrowing Source
                v_record_category := 'B_SOURCE_NOT_DEFINED'     ;
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
					 THEN
        	         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
		 		l_module_name,'Creating Exception: '||
        				v_record_category);
                END IF;
                create_facts_record                             ;
        END ;
    ELSE
        va_borrowing_source_val := RPAD(' ', 5);
    END IF ;
    va_def_liquid_flag := ' ' ;
    va_deficiency_val := ' ' ;
    -- reset amount
    v_amount := 0;
EXCEPTION
    WHEN OTHERS THEN
       vp_retcode := sqlcode ;
       vp_errbuf := sqlerrm || ' [LOAD_FACTS_ATTRIBUTES]' ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
	   		'.final_exception', vp_errbuf) ;
END load_facts_attributes ;
--------------------------------------------------------------------------------
--    Gets the information like enabled flag and reporting type
--    for the passed account number.
--------------------------------------------------------------------------------
PROCEDURE  get_ussgl_info (ussgl_acct_num   Varchar2,
                enabled_flag   OUT NOCOPY   Varchar2,
                reporting_type OUT NOCOPY Varchar2)
IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'get_ussgl_info';
    SELECT ussgl_enabled_flag,
           reporting_type
    INTO   enabled_flag,
           reporting_type
    FROM   fv_facts_ussgl_accounts
    WHERE  ussgl_account = ussgl_acct_num ;
EXCEPTION
    WHEN NO_DATA_FOUND Then
        -- Account Number not found in FV_FACTS_USSGL_ACCOUNTS table.
        -- Return Nulls.
        enabled_flag    := NULL ;
        reporting_type  := NULL ;
    WHEN OTHERS THEN
        vp_retcode := sqlcode ;
        vp_errbuf  := sqlerrm ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
					'.final_exception', vp_errbuf) ;
        RETURN ;
END get_ussgl_info ;
--------------------------------------------------------------------------------
-- Gets the Account Type Value for the passed Account Number.
--------------------------------------------------------------------------------
PROCEDURE  get_account_type (acct_num  VARCHAR2,
                             acct_type OUT NOCOPY VARCHAR2)
IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'get_account_type';
    -- Get the Account Type from fnd Tables
    SELECT substr(compiled_value_attributes, 5, 1)
    INTO   acct_type
    FROM   fnd_flex_values
    WHERE  flex_value_set_id = v_acc_val_set_id
    AND    flex_value = acct_num ;
    IF acct_type IS NULL THEN
       -- Process Null Account Types
       vp_retcode := -1 ;
       vp_errbuf := 'Account Type found null for the for the
               Account Number - ' || acct_num ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',
		 						vp_errbuf) ;
       RETURN ;
    END IF ;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         vp_retcode := -1 ;
         vp_errbuf := 'Account Type Cannot be derived for the Account Number - '
            || acct_num ;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
		   	l_module_name||'.exception1', vp_errbuf) ;
        RETURN ;
    WHEN OTHERS THEN
      vp_errbuf := SQLERRM;
      vp_retcode := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
      RAISE;
END get_account_type ;
--------------------------------------------------------------------------------
--    Gets the SGL Parent Account for the passed account number
--------------------------------------------------------------------------------
PROCEDURE get_sgl_parent(acct_num     VARCHAR2,
                         sgl_acct_num OUT NOCOPY VARCHAR2)
IS
  l_module_name VARCHAR2(200);
  l_errbuf      VARCHAR2(1024);
    vl_exists           VARCHAR2(1)             ;
BEGIN
  l_module_name := g_module_name || 'get_sgl_parent';
    -- Finding the parent of the Account Number in GL
    BEGIN   /* Finding Parent From GL */
        SELECT parent_flex_value
        INTO   sgl_acct_num
        FROM   fnd_flex_value_hierarchies
        WHERE  (acct_num Between child_flex_value_low
                AND child_flex_value_high)
        AND    flex_value_set_id = v_acc_val_set_id
        AND parent_flex_value <> 'T'
        AND parent_flex_value IN
                   (SELECT  ussgl_account
                    FROM fv_facts_ussgl_accounts
                    WHERE ussgl_account = parent_flex_value) ;
        BEGIN
            -- Look for parent in FV_FACTS_ATTRIBUTES table
            SELECT 'X'
            INTO vl_exists
            FROM fv_facts_attributes
            WHERE facts_acct_number = sgl_acct_num
            AND set_of_books_id = vp_set_of_books_id ;
            -- Return the account Number
            RETURN ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
			'Look for parent in FV_FACTS_ATTRIBUTES');
                sgl_acct_num := NULL    ;
                RETURN                  ;
        END ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
					'No Parent Exists ' );
          --Fix for bug # 2450918 . Included the 'RETURN' statement below
          RETURN;
         WHEN TOO_MANY_ROWS Then
            -- Too Many Parents. Return Nulls
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
			  		'Too Many Parents');
           RETURN ;
    END ;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.final_exception',l_errbuf);
    RAISE;
END get_sgl_parent ;
--------------------------------------------------------------------------------
-- This procedure Calculates the balance for the passed
-- Acct_segment, Fund Value and Period Nnumber .
--------------------------------------------------------------------------------
PROCEDURE calc_balance (fund_value       VARCHAR2,
         		acct_num         VARCHAR2,
         		period_num       NUMBER,
         		period_year      NUMBER,
         		balance_type     VARCHAR2,
         		fiscal_year      VARCHAR2,
         		amount           OUT NOCOPY NUMBER,
         		period_activity  OUT NOCOPY NUMBER)
IS
  l_module_name VARCHAR2(200);
    -- Variables for Dynamic SQL
    vl_ret_val      BOOLEAN := TRUE ;
    vl_exec_ret     INTEGER     ;
    vl_bal_cursor   INTEGER         ;
    vl_bal_select   VARCHAR2(2000)  ;
BEGIN
  l_module_name := g_module_name || 'calc_balance';
    BEGIN
        vl_bal_cursor := DBMS_SQL.OPEN_CURSOR  ;
     EXCEPTION
        WHEN OTHERS THEN
            vp_retcode := sqlcode ;
            vp_errbuf  := sqlerrm || ' [CALC_BALANCE - Open Cursor] ' ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.open_vl_bal_cursor', vp_errbuf) ;
            RETURN;
    END ;

    vl_bal_select :=
    'SELECT NVL(DECODE(' || '''' || balance_type || '''' ||
            ',' || '''' || 'B' || '''' ||
            ', SUM(glb.begin_balance_dr - glb.begin_balance_cr), ' ||
            '''' || 'E' || '''' || ', SUM((glb.begin_balance_dr -
            glb.begin_balance_cr) + (glb.period_net_dr - period_net_cr ))),0),
            SUM(glb.period_net_dr - glb.period_net_cr)
     FROM   gl_balances  glb,
            gl_code_combinations glcc
     WHERE  glb.code_combination_id = glcc.code_combination_id  ';

    vl_bal_select :=
     vl_bal_select ||' AND glb.actual_flag = :actual_flag
          AND     GLCC.' || v_bal_seg_name || ' = :fund_value
          AND   GLCC.' || v_acc_seg_name || '   = :acct_num
          AND   GLCC.' || v_fyr_segment_name || ' = :fiscal_year '||
        v_cohort_where ||' AND GLB.ledger_id  = :set_of_books_id
          AND   GLB.PERIOD_NUM = :period_num
          AND   GLB.PERIOD_YEAR = :period_year
          AND   glb.currency_code = :currency_code ';

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
				'Calc bal: '||vl_bal_select) ;
    END IF;

    BEGIN
        dbms_sql.parse(vl_bal_cursor, vl_bal_select, DBMS_SQL.V7) ;
      EXCEPTION
        WHEN OTHERS THEN
            vp_retcode := sqlcode ;
            vp_errbuf  := sqlerrm || ' [CALC_BALANCE - Parse] ' ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			 l_module_name||'.parse_vl_bal_cursor', vp_errbuf) ;
            RETURN;
     END ;

     -- Bind the variables
     dbms_sql.bind_variable(vl_bal_cursor,':actual_flag', 'A');
     dbms_sql.bind_variable(vl_bal_cursor,':fund_value', fund_value);
     dbms_sql.bind_variable(vl_bal_cursor,':acct_num', acct_num);
     dbms_sql.bind_variable(vl_bal_cursor,':fiscal_year', fiscal_year);
     dbms_sql.bind_variable(vl_bal_cursor,':set_of_books_id',
	 						vp_set_of_books_id);
     dbms_sql.bind_variable(vl_bal_cursor,':period_num', period_num);
     dbms_sql.bind_variable(vl_bal_cursor,':period_year', period_year);
     dbms_sql.bind_variable(vl_bal_cursor,':currency_code', vp_currency_code);

     dbms_sql.define_column(vl_bal_cursor, 1, amount);
     dbms_sql.define_column(vl_bal_cursor, 2, period_activity);
     BEGIN
        vl_exec_ret := dbms_sql.execute(vl_bal_cursor);
      EXCEPTION
        WHEN OTHERS THEN
            vp_retcode := sqlcode ;
            vp_errbuf  := sqlerrm || ' [CALC_BALANCE - Execute Cursor] ' ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.execute_vl_bal_cursor', vp_errbuf) ;
     END ;
     LOOP
        IF dbms_sql.fetch_rows(vl_bal_cursor) = 0 THEN
            EXIT;
         ELSE
            -- Fetch the Records into Variables
            dbms_sql.column_value(vl_bal_cursor, 1, amount);
            dbms_sql.column_value(vl_bal_cursor, 2, period_activity);
        END IF;
    END LOOP ;
    -- Close the Balance Cursor
    BEGIN
        dbms_sql.Close_Cursor(vl_bal_cursor);
     EXCEPTION
        WHEN OTHERS THEN
            vp_retcode := sqlcode ;
            vp_errbuf  := sqlerrm ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.close_vl_bal_cursor', vp_errbuf) ;
            RETURN ;
    END ;
EXCEPTION
    WHEN OTHERS THEN
        vp_retcode := sqlcode ;
        vp_errbuf  := sqlerrm || ' [CALC_BALANCE - Others]' ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name, vp_errbuf);
        RETURN;
END calc_balance;
--------------------------------------------------------------------------------
-- Gets the Program segment name and prc_mapping_flag from v_segs_array and
-- v_prc_flag_array respectively, which in turn is derived from
-- FV_FACTS_PRC_HDR table.
--------------------------------------------------------------------------------
PROCEDURE  get_program_segment(v_fund_value VARCHAR2)
IS
  l_module_name VARCHAR2(200);
  vl_prg_seg_name VARCHAR2(30);
  vl_prg_val_set_id NUMBER(15);

BEGIN
  l_module_name := g_module_name || '.get_program_segment';

--Initialize both the segments with null
         v_prn_prg_seg_name := NULL ;
         v_catb_prg_seg_name := NULL;

  FOR i IN 1..v_funds_count
   LOOP

     IF v_segs_array(i).fund_value = v_fund_value THEN

       -- Get the value set id for the program segment
       BEGIN
          -- Getting the Value set Id for finding hierarchies
          SELECT  flex_value_set_id
          INTO    vl_prg_val_set_id
          FROM    fnd_id_flex_segments
          WHERE   application_column_name = v_segs_array(i).segment
          AND application_id      = 101
          AND     id_flex_code    = 'GL#'
          AND     id_flex_num     = v_chart_of_accounts_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
             vp_retcode := -1 ;
             vp_errbuf := 'Error getting Value Set Id for segment'
                         ||v_segs_array(i).segment||' [GET_PROGRAM_SEGMENT]' ;
             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
         WHEN TOO_MANY_ROWS THEN
            -- Too many value set ids returned for the program segment.
             vp_retcode  := -1 ;
            vp_errbuf   := 'Program Segment - ' || v_segs_array(i).segment || ' returned
                more than one Value Sets !! '||'[ GET_PROGRAM_SEGMENT ]' ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
        END ;

           IF  v_segs_array(i).code_type = 'B' THEN
                    v_catb_prg_seg_name :=  v_segs_array(i).segment;
                    v_catb_rc_flag := v_segs_array(i).prc_flag;
                    v_catb_rc_header_id := v_segs_array(i).prc_header_id;
                    v_catb_prg_val_set_id := vl_prg_val_set_id;

           ELSIF  v_segs_array(i).code_type = 'N' THEN
	          v_prn_prg_seg_name :=  v_segs_array(i).segment;
                  v_prn_rc_flag := v_segs_array(i).prc_flag;
                  v_prn_rc_header_id := v_segs_array(i).prc_header_id;
                  v_prn_prg_val_set_id := vl_prg_val_set_id;
            END IF;

     END IF;

   END LOOP;
--   ADI
   IF v_catb_prg_seg_name is NULL AND v_prn_prg_seg_name IS NULL THEN
       RETURN ;
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         -- Fund Value not found in FV_BUDGET_DISTRIBUTION_HDR table.
         v_prn_prg_seg_name := NULL ;
         v_catb_prg_seg_name := NULL;
    WHEN TOO_MANY_ROWS THEN
         -- Fund Value not found in FV_BUDGET_DISTRIBUTION_HDR table.
         vp_retcode  := -1 ;
         vp_errbuf   := 'Fund Value - ' || v_fund_value || '  returned more
            than one program segment value !! '||'[GET_PROGRAM_SEGMENT]' ;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
		   		 l_module_name||'.exception1', vp_errbuf) ;
        RETURN;
    WHEN OTHERS THEN
      vp_errbuf := SQLERRM;
      vp_retcode := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
	  			'.final_exception',vp_errbuf);
      RAISE;

END get_program_segment ;
--------------------------------------------------------------------------------
-- Builds the SQL Statement for the apportionment Category B Processing.
--------------------------------------------------------------------------------
PROCEDURE build_appor_select (acct_number VARCHAR2,
                	      fund_value  VARCHAR2,
                	      fiscal_year VARCHAR2,
                	      appor_period VARCHAR2,
                	      select_stmt OUT NOCOPY VARCHAR2)
IS
  l_module_name VARCHAR2(200);
  l_errbuf      VARCHAR2(1024);
BEGIN
  l_module_name := g_module_name || 'build_appor_select';

    select_stmt :=
    'Select GLCC.' || v_acc_seg_name ||
          ', GLCC.' || v_bal_seg_name ;

    IF v_catb_prg_seg_name IS NOT NULL THEN
       select_stmt := select_stmt ||
          ', GLCC.' || v_catb_prg_seg_name ;
    END IF;

    IF v_prn_prg_seg_name IS NOT NULL THEN
       select_stmt := select_stmt ||
          ', GLCC.' || v_prn_prg_seg_name ;
    END IF;

          select_stmt := select_stmt  ||
                   ', nvl(DECODE(' || '''' || va_balance_type_val || '''' ||
          ',' || '''' || 'B' || '''' ||
          ', SUM(glb.begin_balance_dr - glb.begin_balance_cr), ' ||
          '''' || 'E' || '''' || ', SUM((glb.begin_balance_dr -
          glb.begin_balance_cr) + (glb.period_net_dr - period_net_cr ))),0) '||
          v_cohort_select ||
         ' FROM gl_balances   glb,
                gl_code_combinations glcc
           WHERE  glb.code_combination_id  = GLCC.code_combination_id
           AND '||'glb.actual_flag = :actual_flag
           AND GLCC.'|| v_bal_seg_name ||' = :fund_value
           AND GLCC.' || v_acc_seg_name ||' = :acct_number
           AND GLCC.' || v_fyr_segment_name ||' = :fiscal_year '||
                        appor_period || v_cohort_where ||
         ' AND glb.ledger_id = :set_of_books_id
           AND   glb.currency_code = :currency_code
           GROUP BY GLCC.' || v_acc_seg_name ||
                 ', GLCC.' || v_bal_seg_name ;

    IF v_catb_prg_seg_name IS NOT NULL THEN
       select_stmt := select_stmt ||
          ', GLCC.' || v_catb_prg_seg_name ;
    END IF;

    IF v_prn_prg_seg_name IS NOT NULL THEN
       select_stmt := select_stmt ||
          ', GLCC.' || v_prn_prg_seg_name ;
    END IF;

        select_stmt := select_stmt ||
                      ', GLCC.' || v_fyr_segment_name || v_cohort_select;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
				l_module_name||'.final_exception',l_errbuf);
    RAISE;
END build_appor_select ;
--------------------------------------------------------------------------------
-- Gets the Apportionment Category B Detail and Text Information. Program
-- segment value is passed to get the Text information and Counter value
-- passed to get the converted text value (For Example when the appor_cnt
-- value passed is 3 then the value returned is '003'
--------------------------------------------------------------------------------
PROCEDURE  get_segment_text(p_program IN   VARCHAR2,
                                p_prg_val_set_id IN  NUMBER,
                                p_seg_txt OUT NOCOPY VARCHAR2)
IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'get_segment_text';
    -- Get the Apportionment Category B Text
    -- SELECT DECODE(ffvl.description,NULL,RPAD(' ',25,' '),
    -- RPAD(ffvl.description,25,' '))
    SELECT DECODE(ffvl.description,NULL,RPAD(' ',25,' '),
           RPAD(SUBSTR(ffvl.description,1,25),25,' '))
    INTO  p_seg_txt
    FROM  fnd_flex_values_tl ffvl,
          fnd_flex_values    ffv
    WHERE ffvl.flex_value_id    = ffv.flex_value_id
    AND   ffv.flex_value_set_id = p_prg_val_set_id
    AND   ffv.flex_value        = p_program
    AND   ffvl.language         = userenv('LANG');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        vp_retcode := -1 ;
        vp_errbuf  := 'Cannot Find Apportionment Category B Text for
               the Program ' || p_program||' [GET_SEGMENT_TEXT] ';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
	    l_module_name||'.exception1', vp_errbuf) ;
        RETURN;
    WHEN TOO_MANY_ROWS THEN
        vp_retcode := -1 ;
        vp_errbuf  := 'More then one Apportionment Category B Text found for
               the Program '||p_program||' [GET_SEGMENT_TEXT]';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
	       l_module_name||'.exception2', vp_errbuf) ;
        RETURN;
    WHEN OTHERS THEN
      vp_errbuf := SQLERRM;
      vp_retcode := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
	       l_module_name||'.final_exception3',vp_errbuf);
      RAISE;
END ;
--------------------------------------------------------------------------------
PROCEDURE default_processing(vl_fund_value varchar2,
                 	     vl_acct_num varchar2,
                             rec_cat varchar2 := 'R',
			     vb_amount number,
			     ve_amount number)
IS
  l_module_name VARCHAR2(200);
  l_errbuf      VARCHAR2(1024);
     vl_amount            number(25,2);
     vl_period_activity   number(25,2);
BEGIN
  l_module_name := g_module_name || 'default_processing';
    -------------- Normal Processing ----------------
    -- Only done on the following conditions:
    -- No Apportionment category B Processing or
    -- Legislation Indicator processing is done.
    -- Program segment cannot be found for Apportionment
    -- Category B Processing
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
		 		'Normal Processing ') ;
    END IF ;
    IF va_balance_type_flag IN ('S', 'E') THEN
           va_balance_type_val := 'E'  ;
           v_record_category := 'REPORTED' ;
         /*  ---------------- commtned out for  bug 5065974
           calc_balance (vl_fund_value,
                         vl_acct_num,
                         v_period_num,
            	         vp_report_fiscal_yr,
                         'E',
                         v_fiscal_yr,
                         vl_amount,
                         vl_period_activity) ;
           v_amount        := vl_amount    ;
           v_period_activity       := vl_period_activity;
          ------------------------------------------------- */
          v_amount := ve_amount;
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                            'Ending Balance(Normal) -> '||v_amount);
           END IF;

           create_facts_record         ;

           IF vp_retcode <> 0 THEN
                RETURN ;
           END IF ;
     	   IF (rec_cat = 'E' ) THEN
              v_record_category := 'PROGRAM_SEGMENT_NOT_DEF' ;
              v_tbal_fund_value := vl_fund_value ;
              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
			  	THEN
	           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
					'Creating Exception: '||
				    v_record_category);
              END IF;
              create_facts_record ;
           END IF ;
    END IF;

    IF va_balance_type_flag IN ('S', 'B') THEN

	  /* ----- Commted out for bug 5065974
          calc_balance (vl_fund_value,
                 	vl_acct_num,
             		v_begin_period_num,
             		vp_report_fiscal_yr,
                 	'B',
                        v_fiscal_yr,
             		v_begin_amount,
             		vl_period_activity)  ;

            ---------------------------------------- */

	    v_begin_amount := vb_amount;

            IF vp_retcode <> 0 THEN
                RETURN ;
            END IF ;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
				THEN
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'Beginning Balance(Normal) -> '||v_begin_amount);
            END IF ;
            va_balance_type_val := 'B'      ;
            v_record_category := 'REPORTED'     ;
            v_amount      := v_begin_amount     ;
            v_period_activity := 0;  -- vl_period_activity;

            create_facts_record  ;

            IF vp_retcode <> 0 THEN
                RETURN ;
            END IF ;
    END IF ;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
				l_module_name||'.final_exception',l_errbuf);
    RAISE;
END default_processing;
--------------------------------------------------------------------------------------
PROCEDURE facts_rollup_records
IS
  l_module_name VARCHAR2(200);
  l_errbuf      VARCHAR2(1024);

  l_count NUMBER;

CURSOR facts_temp IS
SELECT rowid, sgl_acct_number, tbal_fund_value,
       fct_int_record_category, begin_end,
       treasury_symbol_id
FROM   fv_facts_temp
WHERE (fct_int_record_category = 'REPORTED'
             OR fct_int_record_category = 'REPORTED_NEW')
    AND AMOUNT = 0
    AND NVL(PERIOD_ACTIVITY,0) = 0
    AND    treasury_symbol_id = v_treasury_symbol_id  ;

l_account_type VARCHAR2(1);

BEGIN
  l_module_name := g_module_name || 'facts_rollup_records';
     INSERT INTO FV_FACTS_TEMP
               (TREASURY_SYMBOL_ID ,
                SGL_ACCT_NUMBER     ,
                PARENT_SGL_ACCT_NUMBER  ,
    		COHORT              ,
    		BEGIN_END           ,
    		INDEF_DEF_FLAG      ,
    		APPOR_CAT_B_DTL     ,
    		APPOR_CAT_B_TXT     ,
    		PUBLIC_LAW          ,
    		APPOR_CAT_CODE      ,
    		AUTHORITY_TYPE      ,
    		TRANSACTION_PARTNER     ,
    		REIMBURSEABLE_FLAG      ,
    		BEA_CATEGORY            ,
    		BORROWING_SOURCE        ,
    		DEF_LIQUID_FLAG         ,
    		DEFICIENCY_FLAG         ,
    		AVAILABILITY_FLAG       ,
    		LEGISLATION_FLAG        ,
    		AMOUNT                  ,
    		DEBIT_CREDIT            ,
    		FCT_INT_RECORD_CATEGORY ,
    		FCT_INT_RECORD_TYPE     ,
    		FACTS_REPORT_INFO       ,
    		--TBAL_FUND_VALUE         , --Bug#4515907
    		TBAL_ACCT_NUM           ,
    		TBAL_INDICATOR      ,
    		YEAR_BUDGET_AUTH    ,
    		BUDGET_FUNCTION     ,
    		ADVANCE_FLAG        ,
    		TRANSFER_DEPT_ID    ,
    		TRANSFER_MAIN_ACCT  ,
    		PERIOD_ACTIVITY ,
		PROGRAM_RPT_CAT_NUM,
                PROGRAM_RPT_CAT_TXT,
                PYA_FLAG
             --   SEGMENT1,
            --    SEGMENT2
)
    SELECT
    		TREASURY_SYMBOL_ID,
        	SGL_ACCT_NUMBER,
        	PARENT_SGL_ACCT_NUMBER,
    		COHORT,
    		BEGIN_END,
    		INDEF_DEF_FLAG,
    		APPOR_CAT_B_DTL,
    		APPOR_CAT_B_TXT,
    		PUBLIC_LAW,
    		APPOR_CAT_CODE,
    		AUTHORITY_TYPE,
    		TRANSACTION_PARTNER,
    		REIMBURSEABLE_FLAG,
    		BEA_CATEGORY,
    		BORROWING_SOURCE,
    		DEF_LIQUID_FLAG,
    		DEFICIENCY_FLAG,
    		AVAILABILITY_FLAG,
    		LEGISLATION_FLAG,
    		SUM(AMOUNT),
    		NULL,
    		'REPORTED_NEW',
    		'BLK_DTL',
    		NULL        ,
    		-- DECODE(v_tbal_run_flag, 'Y', v_tbal_fund_value, NULL),
    		--tbal_fund_value, --Bug#4515907
    		NULL        ,
    		TBAL_INDICATOR  ,
    		YEAR_BUDGET_AUTH,
    		BUDGET_FUNCTION ,
    		ADVANCE_FLAG    ,
    		TRANSFER_DEPT_ID,
    		TRANSFER_MAIN_ACCT,
        	--SUM(period_activity),
                0,  -- bug 5065974  (as period acitivity not needed for ATB)
     		PROGRAM_RPT_CAT_NUM,
     		PROGRAM_RPT_CAT_TXT,
        PYA_FLAG
             --   SEGMENT1,
             --   SEGMENT2
    FROM  fv_facts_temp
    WHERE fct_int_record_category    = 'REPORTED'
    AND   fct_int_record_type        = 'BLK_DTL'
    AND   treasury_symbol_id         = v_treasury_symbol_id
    GROUP BY    TREASURY_SYMBOL_ID,
                SGL_ACCT_NUMBER,
                PARENT_SGL_ACCT_NUMBER,
                COHORT,
                BEGIN_END,
                INDEF_DEF_FLAG,
                APPOR_CAT_B_DTL,
                APPOR_CAT_B_TXT,
                PUBLIC_LAW,
                APPOR_CAT_CODE,
                AUTHORITY_TYPE,
                TRANSACTION_PARTNER,
                REIMBURSEABLE_FLAG,
                BEA_CATEGORY,
                BORROWING_SOURCE,
                DEF_LIQUID_FLAG,
                DEFICIENCY_FLAG,
                AVAILABILITY_FLAG,
                LEGISLATION_FLAG ,
        	--TBAL_FUND_VALUE , --Bug#4515907
        	TBAL_INDICATOR  ,
        	YEAR_BUDGET_AUTH,
        	BUDGET_FUNCTION ,
        	ADVANCE_FLAG    ,
        	TRANSFER_DEPT_ID,
        	TRANSFER_MAIN_ACCT,
     		PROGRAM_RPT_CAT_NUM,
                PROGRAM_RPT_CAT_TXT,
                PYA_FLAG;
          --      SEGMENT1,
           --     SEGMENT2;


/*
    FOR facts_temp_rec IN facts_temp
     LOOP
        get_account_type(facts_temp_rec.sgl_acct_number,
                         l_account_type);
        IF l_account_type IN ('D', 'C')
          THEN
             IF (facts_temp_rec.fct_int_record_category = 'REPORTED_NEW'
                      AND facts_temp_rec.begin_end = 'E') THEN
                SELECT count(*) INTO l_count
                FROM   fv_facts_temp
                WHERE  begin_end = 'B'
                AND    sgl_acct_number = facts_temp_rec.sgl_acct_number
                AND    tbal_fund_value = facts_temp_rec.tbal_fund_value
                AND    treasury_symbol_id = facts_temp_rec.treasury_symbol_id
                AND    fct_int_record_category = 'REPORTED_NEW'
                AND    amount <> 0;

                IF l_count = 0 THEN
                   DELETE FROM fv_facts_temp
                   WHERE  rowid = facts_temp_rec.rowid;
                END IF;
             END IF;

        END IF;
     END LOOP;
*/

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	  			'Setting up Debit/Credit Indicator') ;
    END IF;

    UPDATE fv_facts_temp
    SET debit_credit = 'C'
    WHERE amount < 0
    AND fct_int_record_category = 'REPORTED_NEW'
    AND treasury_symbol_id = v_treasury_symbol_id ;

    UPDATE fv_facts_temp
    SET debit_credit = 'D'
    WHERE amount >= 0
    AND fct_int_record_category = 'REPORTED_NEW'
    AND treasury_symbol_id = v_treasury_symbol_id ;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.final_exception',l_errbuf);
    RAISE;


 END facts_rollup_records;
--------------------------------------------------------------------------------
PROCEDURE check_prc_map_seg(p_treasury_symbol_id IN NUMBER,
	                p_sob_id IN NUMBER,
			p_fund_value OUT NOCOPY VARCHAR2,
		        p_catb_status OUT NOCOPY VARCHAR2,
		        p_prn_status OUT NOCOPY VARCHAR2)
IS

l_module_name VARCHAR2(200);

CURSOR fund_cur(cv_ts_id IN NUMBER,
                cv_sob_id IN NUMBER) IS
     SELECT fund_value,
	    DECODE(fund_category,'S','A','T','B',fund_category) fund_category
     FROM   fv_fund_parameters ffp
     WHERE  ffp.treasury_symbol_id = cv_ts_id
     AND    ffp.set_of_books_id = cv_sob_id
     AND    ffp.fund_category IN ('A', 'B', 'S', 'T');

vl_ts_id      NUMBER;
vl_fund_value fv_fund_parameters.fund_value%TYPE;
vl_prg_seg    fv_facts_prc_hdr.program_segment%TYPE;
vl_prc_header_id    NUMBER;
vl_prc_flag   fv_facts_prc_hdr.prc_mapping_flag%TYPE;
vl_code_type fv_facts_prc_hdr.code_type%TYPE;
vl_status   VARCHAR2(15);

BEGIN
l_module_name := g_module_name || 'check_prc_map_seg';

  v_funds_count := 0;

  FOR fund_rec IN fund_cur(p_treasury_symbol_id,
                           p_sob_id)
    LOOP

  FOR type in 1..2
  LOOP
    	IF type = 1 THEN
         vl_code_type := 'B';
        ELSE
         vl_code_type := 'N';
        END IF;
      vl_status := '';
      LOOP

       vl_prg_seg := NULL;
       vl_prc_flag := NULL;
       vl_prc_header_id := NULL;
       p_fund_value := fund_rec.fund_value;

       BEGIN
        SELECT program_segment,
               prc_mapping_flag, prc_header_id
        INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
        FROM   fv_facts_prc_hdr ffh
        WHERE  ffh.treasury_symbol_id = p_treasury_symbol_id
        AND    ffh.code_type = vl_code_type
	AND    ffh.set_of_books_id = p_sob_id
        AND    ffh.fund_value = fund_rec.fund_value;
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
       END;

        IF vl_prg_seg IS NOT NULL THEN
                vl_status := 'pass'; EXIT; END IF;

	BEGIN
          SELECT program_segment,
                 prc_mapping_flag, prc_header_id
          INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
	  FROM   fv_facts_prc_hdr ffh
	  WHERE  ffh.treasury_symbol_id = p_treasury_symbol_id
          AND    ffh.code_type = vl_code_type
	  AND    ffh.set_of_books_id = p_sob_id
	  AND    ffh.fund_value = 'ALL-A'
	  AND    fund_rec.fund_category = 'A';
	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        IF vl_prg_seg IS NOT NULL THEN
              vl_status := 'pass';EXIT; END IF;

	BEGIN
          SELECT program_segment,
                 prc_mapping_flag, prc_header_id
          INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
	  FROM   fv_facts_prc_hdr ffh
	  WHERE  ffh.treasury_symbol_id = p_treasury_symbol_id
          AND    ffh.code_type = vl_code_type
	  AND    ffh.set_of_books_id = p_sob_id
	  AND    ffh.fund_value = 'ALL-B'
	  AND    fund_rec.fund_category = 'B';
	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        IF vl_prg_seg IS NOT NULL THEN
                      vl_status := 'pass'; EXIT; END IF;

	BEGIN
          SELECT program_segment,
                 prc_mapping_flag, prc_header_id
          INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
          FROM   fv_facts_prc_hdr ffh
          WHERE  ffh.treasury_symbol_id = p_treasury_symbol_id
          AND    ffh.code_type = vl_code_type
          AND    ffh.set_of_books_id = p_sob_id
          AND    ffh.fund_value = 'ALL-FUNDS';
	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        IF vl_prg_seg IS NOT NULL THEN
               vl_status := 'pass'; EXIT; END IF;

	BEGIN
          SELECT program_segment,
                 prc_mapping_flag, prc_header_id
          INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
          FROM   fv_facts_prc_hdr ffh
          WHERE  ffh.treasury_symbol_id = -1
          AND    ffh.code_type = vl_code_type
          AND    ffh.set_of_books_id = p_sob_id
          AND    ffh.fund_value = 'ALL-A'
          AND    fund_rec.fund_category = 'A';
	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;
        IF vl_prg_seg IS NOT NULL THEN
          vl_status := 'pass';
          EXIT;
        END IF;

	BEGIN
          SELECT program_segment,
                 prc_mapping_flag, prc_header_id
          INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
          FROM   fv_facts_prc_hdr ffh
          WHERE  ffh.treasury_symbol_id = -1
          AND    ffh.code_type = vl_code_type
          AND    ffh.set_of_books_id = p_sob_id
          AND    ffh.fund_value = 'ALL-B'
          AND    fund_rec.fund_category = 'B';
	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        IF vl_prg_seg IS NOT NULL THEN
              vl_status := 'pass'; EXIT; END IF;

	BEGIN
          SELECT program_segment,
                 prc_mapping_flag, prc_header_id
          INTO   vl_prg_seg, vl_prc_flag, vl_prc_header_id
          FROM   fv_facts_prc_hdr ffh
          WHERE  ffh.treasury_symbol_id = -1
          AND    ffh.set_of_books_id = p_sob_id
          AND    ffh.code_type = vl_code_type
          AND    ffh.fund_value = 'ALL-FUNDS';
	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;


        IF vl_prg_seg IS NOT NULL THEN
        vl_status := 'pass'; EXIT; END IF;

        vl_status := 'FAIL';

      IF vl_code_type = 'B' AND fund_rec.fund_category = 'B' THEN
            p_catb_status := 'FAIL' ;
         EXIT;
       ELSIF vl_code_type = 'N' THEN
            p_prn_status := 'FAIL'  ;
            EXIT;
      ELSE
        EXIT;
       END IF;

      END LOOP;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'fund_value :'|| fund_rec.fund_value);
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'prg segment :'|| vl_prg_seg);
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'prc flag :'|| vl_prc_flag);
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'prc header id :'||vl_prc_header_id);
      END IF;


      IF vl_status = 'pass' THEN

      v_funds_count := v_funds_count + 1;
      v_segs_array(v_funds_count).fund_value := fund_rec.fund_value;
      v_segs_array(v_funds_count).segment := vl_prg_seg;
      v_segs_array(v_funds_count).prc_flag := vl_prc_flag;
      v_segs_array(v_funds_count).prc_header_id := vl_prc_header_id;
      v_segs_array(v_funds_count).code_type := vl_code_type;
     END IF;
     END LOOP;
    END LOOP;

 EXCEPTION
    WHEN OTHERS THEN
      vp_errbuf :=  SQLERRM;
      vp_retcode := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
          l_module_name||'.final_exception',vp_errbuf);

END check_prc_map_seg;
--------------------------------------------------------------------------------
PROCEDURE get_prc_val(p_catb_program_val IN VARCHAR2,
		      p_catb_rc_val OUT NOCOPY VARCHAR2,
		      p_catb_rc_desc OUT NOCOPY VARCHAR2,
                      p_catb_exception OUT NOCOPY NUMBER,
                      p_prn_program_val IN VARCHAR2,
                      p_prn_rc_val OUT NOCOPY VARCHAR2,
                      p_prn_rc_desc OUT NOCOPY VARCHAR2,
                      p_prn_exception OUT NOCOPY NUMBER)
IS

l_module_name VARCHAR2(200);

vl_prc_found VARCHAR2(1);
vl_prc_val VARCHAR2(10);
vl_prc_desc VARCHAR2(100);
vl_program_val VARCHAR2(50);
vl_prc_header_id NUMBER(15);
vl_prc_flag  VARCHAR2(1);
l_prc_count NUMBER;
vl_exception NUMBER;
vl_seg_txt VARCHAR2(100);
vl_prg_val_set_id NUMBER(15);
vl_segment   VARCHAR2(50);
BEGIN

      l_module_name := g_module_name || 'get_prc_val';

     For I in 1..2
      Loop
        IF I = 1 	THEN
                vl_prc_header_id := v_catb_rc_header_id ;
                vl_program_val   := p_catb_program_val;
                vl_prc_flag      := v_catb_rc_flag;
                vl_prg_val_set_id := v_catb_prg_val_set_id;
                vl_segment       := v_catb_prg_seg_name;
        ELSE
                vl_prc_header_id := v_prn_rc_header_id ;
                vl_program_val   := p_prn_program_val;
                vl_prc_flag      := v_prn_rc_flag;
                vl_prg_val_set_id := v_prn_prg_val_set_id;
                vl_segment     := v_prn_prg_seg_name;


       END IF;

       vl_prc_found := 'N';
       vl_exception := 0;

      IF vl_prc_flag = 'Y' THEN

         BEGIN

            SELECT LPAD(TO_CHAR(reporting_code), 3, '0'), reporting_desc
            INTO   vl_prc_val, vl_prc_desc
            FROM   fv_facts_prc_dtl
            WHERE  prc_header_id = vl_prc_header_id
            AND    program_value = vl_program_val
            AND    set_of_books_id = vp_set_of_books_id;

            vl_prc_found := 'Y';

          EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
         END;

         IF vl_prc_found = 'N' THEN
          BEGIN

            SELECT LPAD(TO_CHAR(reporting_code), 3, '0'), reporting_desc
            INTO  vl_prc_val, vl_prc_desc
            FROM   fv_facts_prc_dtl
            WHERE  prc_header_id = vl_prc_header_id
            AND    program_value = 'ALL'
            AND    set_of_books_id = vp_set_of_books_id;

            vl_prc_found := 'Y';

           EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
          END;
         END IF;

      END IF;



  IF ((I = 1  AND  va_appor_cat_val = 'B' ) OR
          i = 2 ) THEN
      IF (vl_prc_flag = 'N'  OR
          vl_prc_found = 'N') THEN
         BEGIN
           IF  LENGTH(vl_program_val) > 3 THEN
              vl_exception := 1;
              vl_prc_val := NULL;
              vl_prc_desc := NULL;

           ELSIF
               (vl_prc_flag = 'Y' AND
                  vl_prc_found = 'N' AND I = 2 ) THEN
                  vl_exception := 1;
                  vl_prc_val := NULL;
                  vl_prc_desc := NULL;

           ELSE
              vl_prc_val := LPAD(TO_CHAR(TO_NUMBER(vl_program_val)),3,'0');
              get_segment_text(vl_program_val,
                               vl_prg_val_set_id,
			       vl_seg_txt  );
              IF vp_retcode <> 0 THEN
                RETURN ;
              END IF ;
              vl_prc_desc := vl_seg_txt;
              -- If no prc found in the mapping table, then an exception
              -- is created.
           END IF;

          EXCEPTION
            WHEN OTHERS THEN
             -- If p_program_val is non-numeric, an exception is created.
             vl_exception := 1;
           END;
      END IF;
  END IF;



  IF I = 1 THEN
   IF va_appor_cat_val = 'B' THEN
     p_catb_exception := vl_exception;
     IF  vl_prc_found = 'Y' THEN
        p_catb_rc_desc := vl_prc_desc;
        p_catb_rc_val := vl_prc_val;
      ELSIF  (vl_prc_flag = 'N' OR
          vl_prc_found = 'N') THEN
        p_catb_rc_desc := vl_seg_txt;
        p_catb_rc_val := vl_prc_val;
      END IF;
   ELSE
        p_catb_rc_desc := '';
        p_catb_rc_val := '000';

   END IF;
   ELSE
    p_prn_exception := vl_exception;
    IF  vl_prc_found = 'Y' THEN
        p_prn_rc_desc := vl_prc_desc;
        p_prn_rc_val := vl_prc_val;
    ELSIF  (vl_prc_flag = 'N' AND
           vl_prc_found = 'N') THEN
        p_prn_rc_desc := vl_seg_txt;
        p_prn_rc_val := vl_prc_val;
    ELSIF  (vl_prc_flag = 'Y' AND
           vl_prc_found = 'N') THEN
         p_prn_exception := 0;
        p_prn_rc_desc := 'PRC not Assigned';
        p_prn_rc_val := '099';
    END IF;
   END IF;


END LOOP;

 EXCEPTION
    WHEN OTHERS THEN
      vp_errbuf := 'GET_PRC_VAL.'||SQLERRM;
      vp_retcode := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
          l_module_name||'.final_exception',vp_errbuf);
      RAISE;

END get_prc_val;
--------------------------------------------------------------------------------
PROCEDURE create_bulk_file(errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY NUMBER,
                           p_ledger_id IN NUMBER)
IS

-- Submits concurrent request FVFCTTRC
  l_module_name VARCHAR2(200);
rphase    VARCHAR2(80);
rstatus   VARCHAR2(80);
dphase    VARCHAR2(80);
dstatus   VARCHAR2(80);
message   VARCHAR2(80);
call_status BOOLEAN;
v1_req_id NUMBER(15);
v2_req_id NUMBER(15);
v3_req_id NUMBER(15);
sob       NUMBER(15);

BEGIN
  l_module_name := g_module_name || 'create_bulk_file';
  sob   := p_ledger_id;
    -- get the sequence number
    SELECT fv_facts_submission_s.nextval
    INTO   v3_req_id
    FROM   DUAL;

    UPDATE fv_facts_submission
    SET    bulk_file_sub_id = v3_req_id,
           submitted_by = fnd_global.user_name,
           facts2_status = 'CREATING BULK FILE'
    WHERE bulk_flag = 'Y';
--  Commented as part of the 2005 FACTS II Enhancement
/*
    -- Submitting Contact File Generation Process
    v1_req_id := FND_REQUEST.SUBMIT_REQUEST(
                       'FV','FVFCTHRC','','',FALSE,
		   	 'FVFCTHRC', v3_req_id ,SOB) ;
    COMMIT;

    call_status := Fnd_concurrent.Wait_for_request(v1_req_id, 20, 0, rphase,
             rstatus, dphase, dstatus, message);
*/
    -- Submitting FACTS Bulk Detail file Generation Process
 --   IF dstatus <> 'ERROR' THEN
            v2_req_id := fnd_request.submit_request
        ('FV','FVFCTDRC','','',FALSE, 'FVFCTDRC', v3_req_id,SOB) ;
       COMMIT;
       call_status := fnd_concurrent.wait_for_request(v2_req_id, 0, 0, rphase,
                rstatus, dphase, dstatus, message);
       IF (upper(dstatus) <> 'ERROR') THEN
          UPDATE fv_facts_submission
          SET    run_mode = 'P',
                 submitted_by = NULL,
                 submitted_id = NULL,
                 facts2_status = NULL,
                 bulk_flag = 'N'
          WHERE  bulk_file_sub_id =  v3_req_id ;
          COMMIT;
       END IF;
--    END IF;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := -1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
			l_module_name||'.final_exception',errbuf);
    RAISE;


END create_bulk_file;


--------------------------------------------------------------------------------
BEGIN
  g_module_name             := 'fv.plsql.FV_FACTS_TRANSACTIONS.';
  vc_dept_transfer          := '  ' ;
  vc_atb_seq_num            := '000'    ;
  vc_record_indicator       := 'D'  ;
  vc_transfer_to_from       := ' '  ;
  vc_current_permanent_flag := ' '  ;
END;

/
