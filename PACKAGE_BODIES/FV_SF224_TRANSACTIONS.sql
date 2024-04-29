--------------------------------------------------------
--  DDL for Package Body FV_SF224_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SF224_TRANSACTIONS" AS
--$Header: FVSF224B.pls 120.56.12010000.3 2009/11/24 03:27:11 snama ship $

-- Forward Declarations --
  PROCEDURE check_alc_address(p_alc VARCHAR2);
  FUNCTION get_void_check_obligation_date( p_invoice_id NUMBER,
							  	   p_check_id   NUMBER,
								   p_inv_dist_num NUMBER) RETURN DATE;
  PROCEDURE Check_partial_reporting (
    p_business_activity_code     IN fv_alc_addresses_all.business_activity_code%TYPE,
    p_gwa_reporter_category_code IN fv_alc_gwa_categories.gwa_reporter_category_code%TYPE,
    p_error_code                 OUT NOCOPY NUMBER,
    p_error_desc                 OUT NOCOPY VARCHAR2
   );

--=======================================================================

  g_module_name  VARCHAR2(100);
  g_lo_date      DATE;
  g_FAILURE      NUMBER;
  g_SUCCESS      NUMBER;
  g_WARNING      NUMBER;
  g_request_id   NUMBER;
  g_user_id      NUMBER;
  g_login_id     NUMBER;
  g_org_id       NUMBER;
  g_enter        VARCHAR2(10);
  g_exit         VARCHAR2(10);
  g_sysdate      DATE;

  g_payment_type_flag            ap_checks_all.PAYMENT_TYPE_FLAG%TYPE;
  g_check_void_date              DATE;
  g_invoice_type_lookup_code	 ap_invoices_all.invoice_type_lookup_code%TYPE;

  sob                   NUMBER;
  error_code            NUMBER;
  error_buf             VARCHAR2(2000);
  update_flag           VARCHAR2(10);

  g_partial_or_full       VARCHAR2(11);
  g_business_activity     VARCHAR2(30);
  g_gwa_reporter_category VARCHAR2(30);
  l_reportable        VARCHAR2(1);


  L_SF224_TYPE_CODE     VARCHAR2(30);
  L_NAME		FV_SF224_TEMP.NAME%TYPE;
  L_AMOUNT  	        FV_SF224_TEMP.AMOUNT%TYPE;
  L_D_R_FLAG            FV_SF224_TEMP.D_R_FLAG%TYPE;
  L_ACCOMPLISH_DATE     DATE;

  -- References Teasury confirmation Id
  L_REFERENCE_1       FV_SF224_TEMP.REFERENCE_1%TYPE;
  L_REFERENCE_2	      FV_SF224_TEMP.REFERENCE_2%TYPE;

  -- References Check_id
  L_REFERENCE_3	      FV_SF224_TEMP.REFERENCE_3%TYPE;
  L_REFERENCE_8       GL_JE_LINES.REFERENCE_8%TYPE; -- Invoice Dist Line Num

  -- New Variable added as a part of bug fix #983941
  L_REFERENCE_9	      FV_SF224_TEMP.REFERENCE_9%TYPE ;

  -- A new vaiable added l_accomplish_attribute for Bug 1801069
  l_accomplish_attribute  VARCHAR2( 15);
  L_JE_LINE_NUM       FV_SF224_TEMP.JE_LINE_NUM%TYPE ;
  L_REPORTED_FLAG     FV_SF224_TEMP.REPORTED_FLAG%TYPE ;
  L_EXCEPTION_EXISTS  FV_SF224_TEMP.EXCEPTION_EXISTS%TYPE ;
  L_RECORD_CATEGORY   FV_SF224_TEMP.RECORD_CATEGORY%TYPE ;
  L_JE_HEADER_ID      FV_SF224_TEMP.JE_HEADER_ID%TYPE ;
  L_EXCEPTION_SECTION FV_SF224_TEMP.EXCEPTION_SECTION%TYPE;

  L_GL_PERIOD            GL_PERIODS.PERIOD_NAME%TYPE;
  L_REPORTED_MONTH       FV_SF224_TEMP.REPORTED_MONTH%TYPE;
  L_EXCEPTION_CATEGORY   FV_SF224_TEMP.EXCEPTION_CATEGORY%TYPE;
  L_COLUMN_GROUP         NUMBER;
  L_TXN_CATEGORY         FV_SF224_TEMP.TXN_CATEGORY%TYPE;
  L_BILLING_AGENCY_FUND  FV_INTERAGENCY_FUNDS.BILLING_AGENCY_FUND%TYPE;

  L_BATCH_ID             FV_SF224_TEMP.JE_BATCH_ID%TYPE;
  L_RECORD_TYPE          VARCHAR2(30);
  L_IA_FLAG              VARCHAR2(2);
  L_OBLIGATION_DATE      DATE;

  p_def_org_id   	NUMBER(15) ;
  p_def_alc_code	VARCHAR2(12) ;
  l_treasury_symbol	VARCHAR2(35);
  l_treasury_symbol_id  NUMBER(15);
  l_sign_number 	NUMBER;
  l_type 		VARCHAR2(25);
  l_alc_code		VARCHAR2(12);
  flex_num              NUMBER      ;
  x_name   		VARCHAR2(100);

  l_je_source           GL_JE_HEADERS.JE_SOURCE%TYPE;
  l_je_category         GL_JE_HEADERS.JE_CATEGORY%TYPE;
  l_je_from_sla_flag    FV_SF224_TEMP.JE_FROM_SLA_FLAG%TYPE;
  l_document_number	VARCHAR2(100);

  --Define variable to store the end date for the transaction period
  l_txn_end_date      	GL_PERIODS.END_DATE%TYPE;
  l_txn_start_date      GL_PERIODS.START_DATE%TYPE;


  PROCEDURE process_sf224_transactions;
  PROCEDURE Set_Exception(exp_type VARCHAR2) ;

  PROCEDURE get_alc  ( p_bank_acct_id    IN  NUMBER,
                       p_alc_code        OUT NOCOPY VARCHAR2,
                       p_error_code      OUT NOCOPY NUMBER,
                       p_error_desc      OUT NOCOPY VARCHAR2 );

  PROCEDURE set_transaction_type;
  PROCEDURE Insert_new_transaction(x_amount Number, x_sign_number number);

---------------------------------------------------------------------------------
-----                 INITIALIZE_GLOBAL_VARIABLES
--------------------------------------------------------------------------------
  PROCEDURE initialize_global_variables
  IS
  BEGIN
    g_module_name  := 'fv.plsql.fv_sf224_transactions.';
    g_lo_date      := TO_DATE('01/01/0001', 'DD/MM/YYYY');
    g_FAILURE      := -1;
    g_SUCCESS      := 0;
    g_WARNING      := -2;
    g_request_id   := fnd_global.conc_request_id;
    g_user_id      := fnd_global.user_id;
    g_login_id     := fnd_global.login_id;
    g_org_id       := mo_global.get_current_org_id;
    g_enter        := 'ENTER';
    g_exit         := 'EXIT';
    g_sysdate      := SYSDATE;
  END;

---------------------------------------------------------------------------------
-----                 POST_PROCESS_FOR_MAIN
---------------------------------------------------------------------------------
  PROCEDURE post_process_for_main
  (
    p_set_of_books_id       IN NUMBER,
    p_gl_period             IN VARCHAR2,
    p_alc                   IN VARCHAR2,
    p_run_mode              IN VARCHAR2,
    p_partial_or_full       IN VARCHAR2,
    p_business_activity     IN VARCHAR2,
    p_gwa_reporter_category IN VARCHAR2,
    p_end_period_date      OUT NOCOPY DATE,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name     VARCHAR2(200);
    l_location        VARCHAR2(200);
    l_exists          VARCHAR2(2);
    l_last_fetch      BOOLEAN;
    l_yr_start_date   DATE;
    l_start_date      gl_periods.start_date%TYPE;
    l_end_date        gl_periods.end_date%TYPE;
    l_start_date_2    gl_periods.start_date%TYPE;
    l_end_date_2      gl_periods.end_date%TYPE;
    l_cash_receipt_id NUMBER;
    l_hi_date         DATE := TO_DATE('12/31/9999', 'MM/DD/YYYY');
    l_business_activity_code fv_alc_addresses_all.business_activity_code%TYPE;
    l_gwa_reporter_category_code fv_alc_gwa_categories.gwa_reporter_category_code%TYPE;
    l_include_in_report fv_sf224_map.trx_category_coll%TYPE;


    CURSOR current_224_cur
    (
      c_set_of_books_id NUMBER,
      c_alc_code        VARCHAR2,
      c_end_date        DATE
    ) IS
    SELECT fst.rowid,
           fst.gl_period,
           fst.accomplish_date,
           UPPER(fst.sf224_type_code),
           fst.record_type,
           fst.inter_agency_flag,
           fst.obligation_date,
           fst.d_r_flag,
           fst.column_group,
           fst.reported_month,
           fst.exception_category,
           fst.exception_section,
           fst.reported_gl_period,
           fst.supplemental_flag,
           fst.alc_code,
           fst.reference_2,
           fst.reference_3,
           fst.processed_flag,
           fst.update_type,
           fst.je_source,
           fst.je_category,
           fst.txn_category,
           fst.sign_number,
           fst.amount,
           fst.actual_amount,
           fst.reclass,
           fst.reported_flag,
           fst.je_from_sla_flag
      FROM fv_sf224_temp fst
     WHERE fst.set_of_books_id = c_set_of_books_id
       AND fst.sf224_processed_flag = 'Y'
       AND fst.alc_code = DECODE (c_alc_code, 'ALL', fst.alc_code, c_alc_code)
       AND fst.end_period_date < c_end_date;

    TYPE alc_supplemental_r IS RECORD
    (
      alc_code VARCHAR2(30),
      supplemental_flag VARCHAR2(1)
    );
    TYPE alc_supplemental_t IS TABLE OF alc_supplemental_r INDEX BY BINARY_INTEGER;
    l_alc_supplemental alc_supplemental_t;
    l_tot_alc_supplemental NUMBER := 0;
    l_tmp_supplemental_flag NUMBER;

    TYPE row_id_t IS TABLE OF rowid;
    TYPE gl_period_t IS TABLE OF fv_sf224_temp.gl_period%TYPE;
    TYPE accomplish_date_t IS TABLE OF fv_sf224_temp.accomplish_date%TYPE;
    TYPE reported_month_t IS TABLE OF fv_sf224_temp.reported_month%TYPE;
    TYPE exception_category_t IS TABLE OF fv_sf224_temp.exception_category%TYPE;
    TYPE sf224_type_code_t IS TABLE OF fv_sf224_temp.sf224_type_code%TYPE;
    TYPE record_type_t IS TABLE OF fv_sf224_temp.record_type%TYPE;
    TYPE column_group_t IS TABLE OF fv_sf224_temp.column_group%TYPE;
    TYPE inter_agency_flag_t IS TABLE OF fv_sf224_temp.inter_agency_flag%TYPE;
    TYPE obligation_date_t IS TABLE OF fv_sf224_temp.obligation_date%TYPE;
    TYPE d_r_flag_t IS TABLE OF fv_sf224_temp.d_r_flag%TYPE;
    TYPE exception_section_t IS TABLE OF fv_sf224_temp.exception_section%TYPE;
    TYPE reported_gl_period_t IS TABLE OF fv_sf224_temp.reported_gl_period%TYPE;
    TYPE supplemental_flag_t IS TABLE OF fv_sf224_temp.supplemental_flag%TYPE;
    TYPE alc_code_t IS TABLE OF fv_sf224_temp.alc_code%TYPE;
    TYPE reference_2_t IS TABLE OF fv_sf224_temp.reference_2%TYPE;
    TYPE reference_3_t IS TABLE OF fv_sf224_temp.reference_3%TYPE;
    TYPE processed_flag_t IS TABLE OF fv_sf224_temp.processed_flag%TYPE;
    TYPE update_type_t IS TABLE OF fv_sf224_temp.update_type%TYPE;
    TYPE je_source_t IS TABLE OF fv_sf224_temp.je_source%TYPE;
    TYPE je_category_t IS TABLE OF fv_sf224_temp.je_category%TYPE;
    TYPE txn_category_t IS TABLE OF fv_sf224_temp.txn_category%TYPE;
    TYPE sign_number_t IS TABLE OF fv_sf224_temp.sign_number%TYPE;
    TYPE amount_t IS TABLE OF fv_sf224_temp.amount%TYPE;
    TYPE actual_amount_t IS TABLE OF fv_sf224_temp.actual_amount%TYPE;
    TYPE reclass_t IS TABLE OF fv_sf224_temp.reclass%TYPE;
    TYPE reported_flag_t IS TABLE OF fv_sf224_temp.reported_flag%TYPE;
    TYPE je_from_sla_flag_t IS TABLE OF fv_sf224_temp.je_from_sla_flag%TYPE;

    l_rowid row_id_t;
    l_gl_period gl_period_t;
    l_accomplish_date accomplish_date_t;
    l_reported_month reported_month_t;
    l_exception_category exception_category_t;
    l_sf224_type_code sf224_type_code_t;
    l_record_type record_type_t;
    l_column_group column_group_t;
    l_inter_agency_flag inter_agency_flag_t;
    l_obligation_date obligation_date_t;
    l_d_r_flag d_r_flag_t;
    l_exception_section exception_section_t;
    l_reported_gl_period reported_gl_period_t;
    l_supplemental_flag supplemental_flag_t;
    l_alc_code alc_code_t;
    l_reference_2 reference_2_t;
    l_reference_3 reference_3_t;
    l_processed_flag processed_flag_t;
    l_update_type update_type_t;
    l_je_source je_source_t;
    l_je_category je_category_t;
    l_txn_category txn_category_t;
    l_sign_number sign_number_t;
    l_amount amount_t;
    l_actual_amount actual_amount_t;
    l_reclass reclass_t;
    l_reported_flag reported_flag_t;
    l_je_from_sla_flag je_from_sla_flag_t;

     -- Bug 9066910
    CURSOR select_fv_sf224_map_cur(g_txn_category varchar2) is
    SELECT DECODE(g_txn_category, 'C', trx_category_coll,
                                                 'P', trx_category_pay,
                                                 'I', trx_category_intra,
                                                 'I')
                  FROM fv_sf224_map
                  WHERE NVL(business_activity_code, 'NULL') = NVL(l_business_activity_code, 'NULL')
                  AND NVL(gwa_reporter_category_code, 'NULL') = NVL(l_gwa_reporter_category_code, 'NULL');

 BEGIN
    l_module_name := g_module_name || '.extract';
    p_error_code := g_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_set_of_books_id = '||p_set_of_books_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_gl_period = '||p_gl_period);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_alc = '||p_alc);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_run_mode = '||p_run_mode);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'SELECT FROM gl_period_statuses');
    END IF;
    BEGIN
      SELECT start_date,
             end_date,
             year_start_date
        INTO l_start_date,
             l_end_date,
             l_yr_start_date
        FROM gl_period_statuses glp
       WHERE glp.period_name = p_gl_period
         AND glp.ledger_id = p_set_of_books_id
         AND glp.application_id = 101;
      p_end_period_date := l_end_date;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_start_date    ='||l_start_date);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_end_date      ='||l_end_date);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_yr_start_date ='||l_yr_start_date);
    END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
        p_error_code := g_FAILURE;
        p_error_desc  := 'No Such Period (' || p_gl_period|| ') exists';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      WHEN OTHERS THEN
        p_error_code := g_FAILURE;
        p_error_desc := SQLERRM;
        l_location   := l_module_name||'select_gl_period_statuses1';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    END ;

    IF (p_error_code = g_SUCCESS) THEN

      l_last_fetch := FALSE;
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'OPEN current_224_cur');
      END IF;
      OPEN current_224_cur (p_set_of_books_id, p_alc, TRUNC(l_end_date)+1);
      LOOP
        FETCH current_224_cur
         BULK COLLECT INTO
           l_rowid,
           l_gl_period,
           l_accomplish_date,
           l_sf224_type_code,
           l_record_type,
           l_inter_agency_flag,
           l_obligation_date,
           l_d_r_flag,
           l_column_group,
           l_reported_month,
           l_exception_category,
           l_exception_section,
           l_reported_gl_period,
           l_supplemental_flag,
           l_alc_code,
           l_reference_2,
           l_reference_3,
           l_processed_flag,
           l_update_type,
           l_je_source,
           l_je_category,
           l_txn_category,
           l_sign_number,
           l_amount,
           l_actual_amount,
           l_reclass,
           l_reported_flag,
           l_je_from_sla_flag;

        IF current_224_cur%NOTFOUND THEN
          l_last_fetch := TRUE;
        END IF;

        IF (l_gl_period.count = 0 AND l_last_fetch) THEN
          EXIT;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'FETCH current_224_cur');
        END IF;
        FOR i IN l_rowid.first .. l_rowid.last LOOP
          BEGIN
            SELECT start_date,
                   end_date
              INTO l_start_date_2,
                   l_end_date_2
              FROM gl_period_statuses glp
             WHERE glp.period_name = l_gl_period(i)
               AND glp.ledger_id = p_set_of_books_id
               AND glp.application_id = 101;
          EXCEPTION
            WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
              p_error_code := g_FAILURE;
              p_error_desc  := 'No Such Period (' || l_gl_period(i)|| ') exists';
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
            WHEN OTHERS THEN
              p_error_code := g_FAILURE;
              p_error_desc := SQLERRM;
              l_location   := l_module_name||'select_gl_period_statuses2';
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
          END;

          IF (p_error_code = g_SUCCESS) THEN
            IF (l_accomplish_date(i) BETWEEN l_start_date AND l_end_date) THEN
              l_reported_month (i) := 'CURRENT';
              l_reported_gl_period(i) := p_gl_period;
              IF(l_end_date_2  = l_end_date) THEN
               l_exception_category(i) := NULL;
                l_exception_section(i) := -1;
              ELSIF  (l_end_date_2 < l_end_date)  THEN
                l_exception_category(i) := 'PRIOR PERIOD';
                l_exception_section(i) := 1;
              ELSIF (l_end_date_2  > l_end_date) THEN
                l_exception_category(i) := 'FUTURE PERIOD';
                l_exception_section(i) := 2;
              END IF;
            ELSIF(l_accomplish_date(i)  < l_start_date) THEN
              l_reported_month(i) := 'CURRENT/PRIOR';
              l_reported_gl_period(i) := p_gl_period;
              IF(l_end_date_2  = l_end_date) THEN
                l_exception_category(i) := NULL;
                l_exception_section(i) := -1;
              ELSIF  (l_end_date_2 < l_end_date)  THEN
                l_exception_category(i) := 'PRIOR PERIOD';
                l_exception_section(i) := 1;
              ELSIF (l_end_date_2  > l_end_date) THEN
                l_exception_category(i) := 'FUTURE PERIOD';
                l_exception_section(i) := 2;
              END IF;
            ELSE
              l_reported_month(i) := 'FUTURE';
              IF (l_end_date_2  = l_end_date) THEN
                l_exception_category(i) := 'FUTURE_ACOMPLISH';
                l_exception_section(i) := 3;
              ELSIF  (l_end_date_2 < l_end_date)  THEN
                l_exception_category(i) := 'FUTURE ACCOMPLISH';
                l_exception_section(i) := 3;
              ELSIF (l_end_date_2  > l_end_date) THEN
                l_exception_category(i) := 'FUTURE PERIOD';
                l_exception_section(i) := 3;
              END IF;
            END IF;

            IF (l_record_type(i) like '%refund%' or l_record_type(i) = 'VOID') THEN
              IF (l_obligation_date(i) < l_yr_start_date) THEN
                l_column_group(i) := 20 ;
                l_txn_category(i) := 'C';
                IF ((l_record_type(i) = 'VOID') OR
                    (l_record_type(i) = 'Receipt_refund' AND l_inter_agency_flag(i) = 'Y')) THEN
                  l_column_group(i) := 21;
                  l_txn_category(i) := 'P';
                END IF;
              ELSE
                l_column_group(i) := 30 ;
                l_txn_category(i) := 'P';
                l_sign_number(i) := -1;
                IF(l_record_type(i) = 'Receipt_refund' AND l_inter_agency_flag(i) = 'N') THEN
                  l_column_group(i) := 31;
                  l_txn_category(i) := 'C';
                END IF;
              END IF;
            ELSIF (l_record_type(i) = 'PAYABLE_REFUND') THEN
              IF l_obligation_date(i) < l_yr_start_date THEN
                l_column_group(i) := 20;
                l_txn_category(i) := 'C';
                l_sign_number(i) := 1;
              ELSE
                l_column_group(i) := 31;
                l_txn_category(i) := 'C';
                l_sign_number(i) := -1;
              END IF;
            END IF;
          END IF;

          IF (p_error_code = g_SUCCESS) THEN
            IF (l_reported_month(i) LIKE 'CURRENT%') THEN
              FOR j IN 1..l_tot_alc_supplemental LOOP
                IF (l_alc_code(i) = l_alc_supplemental(j).alc_code) THEN
                  l_supplemental_flag(i) := l_alc_supplemental(j).supplemental_flag;
                END IF;
              END LOOP;

              IF (l_supplemental_flag(i) IS NULL) THEN
                BEGIN
                  SELECT MAX(supplemental_flag)
                    INTO l_tmp_supplemental_flag
                    FROM fv_sf224_audits
                   WHERE reported_gl_period = p_gl_period
                     AND set_of_books_id = p_set_of_books_id
                     AND alc_code = l_alc_code(i);

                 IF (l_tmp_supplemental_flag IS NULL) THEN
                  l_supplemental_flag(i) := '0';
                  l_tot_alc_supplemental := l_tot_alc_supplemental + 1;
                  l_alc_supplemental(l_tot_alc_supplemental).supplemental_flag := l_supplemental_flag(i);
                  l_alc_supplemental(l_tot_alc_supplemental).alc_code := l_alc_code(i);
                 ELSIF (l_tmp_supplemental_flag < 3) THEN
                    l_supplemental_flag(i) := TO_CHAR(l_tmp_supplemental_flag+1);
                    l_tot_alc_supplemental := l_tot_alc_supplemental + 1;
                    l_alc_supplemental(l_tot_alc_supplemental).supplemental_flag := l_supplemental_flag(i);
                    l_alc_supplemental(l_tot_alc_supplemental).alc_code := l_alc_code(i);
                 ELSE
                    l_supplemental_flag(i) := '3';
                    l_tot_alc_supplemental := l_tot_alc_supplemental + 1;
                    l_alc_supplemental(l_tot_alc_supplemental).supplemental_flag := l_supplemental_flag(i);
                    l_alc_supplemental(l_tot_alc_supplemental).alc_code := l_alc_code(i);
                 END IF;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_supplemental_flag(i) := '0';
                    l_tot_alc_supplemental := l_tot_alc_supplemental + 1;
                    l_alc_supplemental(l_tot_alc_supplemental).supplemental_flag := l_supplemental_flag(i);
                    l_alc_supplemental(l_tot_alc_supplemental).alc_code := l_alc_code(i);
                  WHEN OTHERS THEN
                    p_error_code := g_FAILURE;
                    p_error_desc := SQLERRM;
                    l_location   := l_module_name||'select_fv_sf224_audits';
                    fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
                    fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
                END;
              END IF;
            END IF;
          END IF;

            ---------------------------------- by KS 3-OCT-2006 ------------------------
            -- CHECK whether any cash receipt been entered/deleted in fv_interangy_funds_all
            -- table after  pre process run.User could have added/deleted the records

         IF (l_je_source(i) = 'Receivables') THEN
            IF NVL(l_je_from_sla_flag(i),'N') IN ('N','U') THEN
                IF (l_je_category(i) = 'Misc Receipts') THEN
                  l_cash_receipt_id := l_reference_2(i);
                ELSE
                  l_cash_receipt_id := SUBSTR(l_reference_2(i),0,INSTR(l_reference_2(i),'C')-1);
                END IF;
                BEGIN
                   SELECT 'x'
                   INTO l_exists
                   FROM fv_interagency_funds_all
                   WHERE cash_receipt_id = l_cash_receipt_id;
                   l_inter_agency_flag(i) := 'Y';
                   l_update_type(i) := 'RECEIPT';
                   l_column_group(i) := 21;
                EXCEPTION
                   WHEN no_data_found THEN
                    l_inter_agency_flag(i) := 'N';
                    l_update_type(i) := NULL;
                    l_column_group(i) := 20;
                END;
            ELSE --l_je_from_sla_flag is 'Y'
                l_cash_receipt_id := l_reference_2(i);
                BEGIN
                   SELECT 'x'
                   INTO l_exists
                   FROM fv_interagency_funds_all
                   WHERE cash_receipt_id = l_cash_receipt_id;
                   l_inter_agency_flag(i) := 'Y';
                   l_update_type(i) := 'RECEIPT';
                   l_column_group(i) := 21;
                EXCEPTION
                  WHEN no_data_found THEN
                   l_inter_agency_flag(i) := 'N';
                   l_update_type(i) := NULL;
                   l_column_group(i) := 20;
                END;
            END IF;
         END IF;

           ---------------------------------------------------------------------------

          IF (p_error_code = g_SUCCESS) THEN
            IF (p_run_mode = 'F') THEN

              IF (l_inter_agency_flag(i) = 'Y' and l_reported_month(i) like '%CURRENT%') THEN
                BEGIN
                  UPDATE fv_interagency_funds_all
                     SET processed_flag    = 'Y',
                         period_reported   = p_gl_period,
                         last_updated_by   = g_user_id,
                         last_update_date  = g_sysdate,
                         last_update_login = g_login_id
                   WHERE DECODE(l_update_type(i),'RECEIPT', cash_receipt_id, invoice_id) =
                             DECODE(l_update_type(i),'RECEIPT', to_number(l_cash_receipt_id),to_number(l_reference_2(i)));
                EXCEPTION
                  WHEN OTHERS THEN
                    p_error_code := g_FAILURE;
                    p_error_desc := SQLERRM;
                    l_location   := l_module_name||'update_fv_interagency_funds_all';
                    fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
                    fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
                END;
              END IF;

              IF (l_processed_flag(i) = 'Y' AND l_reported_month(i) like '%CURRENT%') then
                BEGIN
                  UPDATE fv_refunds_voids_all
                     SET processed_flag    = 'Y',
                         period_reported   = p_gl_period,
                         last_updated_by   = g_user_id,
                         last_update_date  = g_sysdate,
                         last_update_login = g_login_id
                   WHERE DECODE(l_update_type(i),'RECEIPT', cash_receipt_id, invoice_id) =
                           DECODE(l_update_type(i),'RECEIPT', TO_NUMBER(l_cash_receipt_id),to_number(l_reference_2(i)))
                     AND type = l_type
                     AND NVL(check_id,0) = DECODE(l_update_type(i),'RECEIPT', NVL(check_id,0), to_number(l_reference_3(i)));
                EXCEPTION
                  WHEN OTHERS THEN
                    p_error_code := g_FAILURE;
                    p_error_desc := SQLERRM;
                    l_location   := l_module_name||'update_fv_refunds_voids_all';
                    fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
                    fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
                END;
              END IF;
            END IF;
          END IF;

          /*
            Adding logic here to restrict the parameters based on Partial reporting.
            Or else there will be massive changes in the reports. So for the time being
            we shall change the reported month to something other than CURRENT% to avoid
            getting picked up by the report. This column always gets populated during the
            pre process.
          */

          IF (p_partial_or_full='Partial') then
            IF (p_error_code = g_SUCCESS) THEN
              BEGIN
                SELECT fa.business_activity_code,
                       fa.gwa_reporter_category_code
                  INTO l_business_activity_code,
                       l_gwa_reporter_category_code
                  FROM fv_alc_business_activity_v fa
                 WHERE fa.set_of_books_id = p_set_of_books_id
                   AND fa.agency_location_code = l_alc_code(i)
                   AND fa.period_name = l_gl_period(i);
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_business_activity_code := NULL;
                  l_gwa_reporter_category_code := NULL;
                WHEN OTHERS THEN
                  p_error_code := g_FAILURE;
                  p_error_desc := SQLERRM;
                  l_location   := l_module_name||'select_fv_alc_business_activity_v';
                  fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
                  fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
              END;
            END IF;

            IF (p_error_code = g_SUCCESS) THEN
              BEGIN
                 -- Bug 9066910: Use cursor instead of a statement to avoid error
                 -- ORA-01422: exact fetch returns more than requested number of rows
                /*SELECT DECODE(l_txn_category(i), 'C', trx_category_coll,
                                                 'P', trx_category_pay,
                                                 'I', trx_category_intra,
                                                 'I')
                  INTO l_include_in_report
                  FROM fv_sf224_map
                 WHERE NVL(business_activity_code, 'NULL') = NVL(l_business_activity_code, 'NULL')
                   AND NVL(gwa_reporter_category_code, 'NULL') = NVL(l_gwa_reporter_category_code, 'NULL');*/

                open  select_fv_sf224_map_cur(l_txn_category(i));
                fetch select_fv_sf224_map_cur into l_include_in_report;
                close select_fv_sf224_map_cur;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  NULL;
                WHEN OTHERS THEN
                  p_error_code := g_FAILURE;
                  p_error_desc := SQLERRM;
                  l_location   := l_module_name||'select_fv_sf224_map';
                  fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
                  fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
              END;
            END IF;

            IF ((p_business_activity <> 'ALL') AND (l_business_activity_code <> p_business_activity)) THEN
              l_include_in_report := 'X';
            END IF;

            IF ((p_gwa_reporter_category <> 'ALL') AND (l_gwa_reporter_category_code <> p_gwa_reporter_category)) THEN
              l_include_in_report := 'X';
            END IF;


            IF (l_include_in_report IN ('X', 'E')) THEN
              l_reported_month(i) := 'NOT REPORTED';
            END IF;

          END IF;



          IF (p_error_code <> g_SUCCESS) THEN
            EXIT;
          END IF;
        END LOOP;

        IF (p_error_code = g_SUCCESS) THEN
          BEGIN
            FORALL i IN l_rowid.first .. l_rowid.last
              UPDATE fv_sf224_temp fst
                 SET fst.column_group = l_column_group(i),
                     fst.exception_category = l_exception_category(i),
                     fst.reported_month = l_reported_month(i),
                     fst.reported_flag = DECODE(l_reported_month(i), 'CURRENT', 'Y', 'CURRENT/PRIOR','Y','N'),
                     fst.exception_section = l_exception_section (i),
                     fst.reported_gl_period = l_reported_gl_period(i),
                     fst.supplemental_flag = l_supplemental_flag(i),
                     fst.txn_category = l_txn_category(i),
                     fst.sign_number = l_sign_number(i),
                     fst.amount = l_actual_amount(i) * l_sign_number(i),
                     fst.last_updated_by = g_user_id,
                     fst.last_update_date = g_sysdate,
                     fst.last_update_login = g_login_id,
                     fst.updated_request_id = g_request_id
               WHERE ROWID = l_rowid(i);

          EXCEPTION
            WHEN OTHERS THEN
              p_error_code := g_FAILURE;
              p_error_desc := SQLERRM;
              l_location   := l_module_name||'update_fv_sf224_temp';
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
          END;
        END IF;
      END LOOP;

      IF (current_224_cur%ISOPEN) THEN
        CLOSE current_224_cur;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (current_224_cur%ISOPEN) THEN
        CLOSE current_224_cur;
      END IF;
  END post_process_for_main;

 ----------------------------------------------------------------------
 --                    UPDATE_AUDIT_INFO
 ----------------------------------------------------------------------
  PROCEDURE  update_audit_info
  (
    p_set_of_books_id IN NUMBER,
    p_alc             IN VARCHAR2,
    p_end_period_date IN DATE,
    p_error_code      OUT NOCOPY NUMBER,
    p_error_desc      OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name VARCHAR2(200) ;
    l_location    VARCHAR2(200);

  BEGIN
    l_module_name := g_module_name || 'Update_audit_info';
    p_error_code := g_SUCCESS;
    -- Updating Audit tables

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'INSERTING INTO THE AUDITS TABLE.');
    END IF;

    BEGIN
      INSERT INTO fv_sf224_audits
      (
        batch_id ,
        sf224_month_reported,
        reported_month,
        column_group,
        treasury_symbol_id,
        created_by,
        creation_date,
        last_update_date,
        last_updated_by,
        last_update_login,
        supplemental_flag,
        exception_category,
        gl_period,
        reported_gl_period,
        set_of_books_id,
        alc_code,
        inter_agency_flag,
        je_header_id,
        je_line_num,
        record_type,
        je_source,
        je_category,
        document_number,
        je_from_sla_flag
      )
      SELECT je_batch_id,
             TO_CHAR(accomplish_date, 'MM-YYYY'),
             reported_month,
             column_group,
             treasury_symbol_id,
             g_user_id,
             g_sysdate,
             g_sysdate,
             g_user_id,
             g_login_id,
             supplemental_flag,
             exception_category,
             gl_period,
             reported_gl_period,
             set_of_books_id,
             alc_code,
             inter_agency_flag,
             je_header_id,
             je_line_num,
             record_type,
             je_source,
             je_category,
             document_number,
             je_from_sla_flag
        FROM fv_sf224_temp fst
       WHERE ((fst.reported_month in ('CURRENT/PRIOR','CURRENT')
               AND   fst.reported_flag = 'Y'
               AND   fst.record_category = 'GLRECORD')
               OR   (exception_category IN ('INVALID_BA_GWA_SEC_COMBO', 'GWA_REPORTABLE')))
         AND fst.set_of_books_id = p_set_of_books_id
         AND fst.alc_code = DECODE (p_alc, 'ALL', alc_code, p_alc)
         AND fst.end_period_date < TRUNC(p_end_period_date)+1;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_code := g_FAILURE;
        p_error_desc := SQLERRM;
        l_location   := l_module_name||'insert_fv_sf224_temp';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    END;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        DELETE fv_sf224_temp fst
         WHERE fst.reported_month in ('CURRENT/PRIOR','CURRENT')
           AND fst.reported_flag = 'Y'
           AND fst.record_category = 'GLRECORD'
           AND fst.set_of_books_id = p_set_of_books_id
           AND fst.alc_code = DECODE (p_alc, 'ALL', alc_code, p_alc)
           AND fst.end_period_date < TRUNC(p_end_period_date)+1;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'delete_fv_sf224_temp';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;

  END update_audit_info;

  --------------------------------------------------------------------
  -----                         SUBMIT_224_REPORT
  --------------------------------------------------------------------
  PROCEDURE submit_224_report
  (
    p_set_of_books_id       IN NUMBER,
    p_gl_period             IN VARCHAR2,
    p_alc                   IN VARCHAR2,
    p_run_mode              IN VARCHAR2,
    p_partial_or_full       IN VARCHAR2,
    p_business_activity     IN VARCHAR2,
    p_gwa_reporter_category IN VARCHAR2,
    p_error_code            OUT NOCOPY NUMBER,
    p_error_desc            OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name   VARCHAR2(200) ;
    l_location      VARCHAR2(200);

    l_req_id1       NUMBER;
    l_req_id2       NUMBER;
    l_req_id3       NUMBER;
    l_req_id4       NUMBER;
    l_req_id5       NUMBER;
    l_call_status   BOOLEAN;
    l_dev_phase     VARCHAR2(80);
    l_phase         VARCHAR2(80);
    l_status        VARCHAR2(80);
    l_dev_status    VARCHAR2(80);
    l_message       VARCHAR2(80);
    l_print_option  BOOLEAN;
    l_copies        NUMBER(15);
    l_printer_name  VARCHAR2(240);
    l_request_id    NUMBER(15);


    CURSOR get_print_options_c(c_request_id NUMBER) is
    SELECT printer,
           number_of_copies
      FROM fnd_concurrent_requests
     WHERE request_id = c_request_id ;

  BEGIN
    l_module_name := g_module_name || 'submit_224_report';
    p_error_code := g_SUCCESS;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'submitting 224  reports .....') ;
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_set_of_books_id='||p_set_of_books_id) ;
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_gl_period='||p_gl_period) ;
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_alc='||p_alc) ;
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_partial_or_full='||p_partial_or_full) ;
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_business_activity='||p_business_activity) ;
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_gwa_reporter_category='||p_gwa_reporter_category) ;
    END IF;

    l_request_id := fnd_global.conc_request_id;

    BEGIN
      OPEN get_print_options_c(l_request_id);
      FETCH get_print_options_c
       INTO l_printer_name,
            l_copies;
      CLOSE get_print_options_c;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_code := g_FAILURE;
        p_error_desc := SQLERRM;
        l_location   := l_module_name||'cursor_get_print_options_c';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    END;

    IF (p_error_code = g_SUCCESS) THEN
      l_print_option := fnd_request.set_print_options
                        (
                          printer => l_printer_name,
                          copies  => l_copies
                        );

      l_req_id1 := fnd_request.submit_request
                   (
                     application => 'FV',
                     program => 'FVSF224R',
                     description => NULL,
                     start_time => NULL,
                     sub_request => FALSE,
                     argument1 => p_gl_period,
                     argument2 => p_set_of_books_id,
                     argument3 => p_alc,
                     argument4 => p_partial_or_full,
                     argument5 => p_business_activity,
                     argument6 => p_gwa_reporter_category

                   );
      IF (l_req_id1 = 0) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'ERROR SUBMITTING 224 REPORT';
        l_location   := 'submit_FVSF224R';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      ELSE
        COMMIT;
      END IF;
    END IF;


    IF (p_error_code = g_SUCCESS) THEN
      l_print_option := fnd_request.set_print_options
                        (
                          printer => l_printer_name,
                          copies  => l_copies
                        );

      l_req_id2 := fnd_request.submit_request
                   (
                     application => 'FV',
                     program => 'FVSF224L',
                     description => NULL,
                     start_time => NULL,
                     sub_request => FALSE,
                     argument1 => p_gl_period,
                     argument2 => p_set_of_books_id,
                     argument3 => p_run_mode,
                     argument4 => p_partial_or_full,
                     argument5 => p_alc
                   );
      IF (l_req_id2 = 0) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'ERROR SUBMITTING 224 LISTING';
        l_location   := 'submit_FVSF224L';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      ELSE
        COMMIT;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      l_print_option := fnd_request.set_print_options
                        (
                          printer => l_printer_name,
                          copies  => l_copies
                        );

      l_req_id3 := fnd_request.submit_request
                   (
                     application => 'FV',
                     program => 'FV224EXR',
                     description => NULL,
                     start_time => NULL,
                     sub_request => FALSE,
                     argument1 => p_gl_period,
                     argument2 => p_set_of_books_id,
                     argument3 => p_partial_or_full,
                     argument4 => p_alc
                   );
      IF (l_req_id3 = 0) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'ERROR SUBMITTING 224 EXCEPTION REPORT';
        l_location   := 'submit_FV224EXR';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      ELSE
        COMMIT;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      l_print_option := fnd_request.set_print_options
                        (
                          printer => l_printer_name,
                          copies  => l_copies
                        );

      l_req_id4 := fnd_request.submit_request
                   (
                     application => 'FV',
                     program => 'FVTI224P',
                     description => NULL,
                     start_time => NULL,
                     sub_request => FALSE,
                     argument1 => p_set_of_books_id,
                     argument2 => p_gl_period,
                     argument3 => p_alc,
                     argument4 => p_partial_or_full,
                     argument5 => p_business_activity,
                     argument6 => p_gwa_reporter_category
                   );
      IF (l_req_id4 = 0) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'ERROR SUBMITTING GOALS 224 PROCESS';
        l_location   := 'submit_FVTI224P';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      ELSE
        COMMIT;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      l_call_status := fnd_concurrent.wait_for_request
                       (
                         request_id => l_req_id1,
                         interval => 20,
                         max_wait => 0,
                         phase => l_phase,
                         status => l_status,
                         dev_phase => l_dev_phase,
                         dev_status => l_dev_status,
                         message => l_message
                       );
      IF (l_call_status = FALSE) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'Cannot wait for the status of 224 Report';
        l_location   := 'wait_req1';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      l_call_status := fnd_concurrent.wait_for_request
                       (
                         request_id => l_req_id2,
                         interval => 20,
                         max_wait => 0,
                         phase => l_phase,
                         status => l_status,
                         dev_phase => l_dev_phase,
                         dev_status => l_dev_status,
                         message => l_message
                       );
      IF (l_call_status = FALSE) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'Cannot wait for the status of 224 Detail Report';
        l_location   := 'wait_req2';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      l_call_status := fnd_concurrent.wait_for_request
                       (
                         request_id => l_req_id3,
                         interval => 20,
                         max_wait => 0,
                         phase => l_phase,
                         status => l_status,
                         dev_phase => l_dev_phase,
                         dev_status => l_dev_status,
                         message => l_message
                       );
      IF (l_call_status = FALSE) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'Cannot wait for the status of 224 Exception Report';
        l_location   := 'wait_req3';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      l_call_status := fnd_concurrent.wait_for_request
                       (
                         request_id => l_req_id4,
                         interval => 20,
                         max_wait => 0,
                         phase => l_phase,
                         status => l_status,
                         dev_phase => l_dev_phase,
                         dev_status => l_dev_status,
                         message => l_message
                       );
      IF (l_call_status = FALSE) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'Cannot wait for the status of GOALS 224 process';
        l_location   := 'wait_req4';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      l_print_option := fnd_request.set_print_options
                        (
                          printer => l_printer_name,
                          copies  => l_copies
                        );

      l_req_id5 := fnd_request.submit_request
                   (
                     application => 'FV',
                     program => 'FVTI224R',
                     description => NULL,
                     start_time => NULL,
                     sub_request => FALSE,
                     argument1 => 'FVTI224R'
                   );
      IF (l_req_id5 = 0) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'ERROR SUBMITTING GOALS 224 REPORT';
        l_location   := 'submit_FVTI224R';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      ELSE
        COMMIT;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      l_call_status := fnd_concurrent.wait_for_request
                       (
                         request_id => l_req_id5,
                         interval => 20,
                         max_wait => 0,
                         phase => l_phase,
                         status => l_status,
                         dev_phase => l_dev_phase,
                         dev_status => l_dev_status,
                         message => l_message
                       );
      IF (l_call_status = FALSE) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'Cannot wait for the status of GOALS 224 report';
        l_location   := 'wait_req5';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;

  END submit_224_report;

  --------------------------------------------------------------------
  -----                         CALL_EXTRACT_PROCESS
  --------------------------------------------------------------------

  PROCEDURE call_extract_process
  (
    p_set_of_books_id IN NUMBER,
    p_error_code      OUT NOCOPY NUMBER,
    p_error_desc      OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name VARCHAR2(200) ;
    l_location    VARCHAR2(200);

    l_req_id NUMBER;
    l_call_status boolean;
    l_dev_phase VARCHAR2(80);
    l_phase VARCHAR2(80);
    l_status VARCHAR2(80);
    l_dev_status VARCHAR2(80);
    l_message VARCHAR2(80);

  BEGIN
    l_module_name := g_module_name || 'call_extract_process';
    p_error_code := g_SUCCESS;
    p_def_org_id := mo_global.get_current_org_id;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fv_utility.debug_mesg(fnd_log.level_statement,l_module_name, 'In call_extact process');
     fv_utility.debug_mesg(fnd_log.level_statement,l_module_name, 'p_set_of_books_id='||p_set_of_books_id) ;
     fv_utility.debug_mesg(fnd_log.level_statement,l_module_name, 'org_id='||p_def_org_id) ;
    END IF;

    l_req_id := fnd_request.submit_request
                (
                  application => 'FV',
                  program => 'FVSF224E',
                  description => NULL,
                  start_time => NULL,
                  sub_request => FALSE,
                  argument1 => p_set_of_books_id
                );
    IF (l_req_id = 0) THEN
      p_error_code := g_FAILURE;
      p_error_desc := 'ERROR SUBMITTING 224 EXTRACT PROCESS';
      l_location   := 'submit_FVSF224E';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    ELSE
      COMMIT;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      l_call_status := fnd_concurrent.wait_for_request
                       (
                         request_id => l_req_id,
                         interval => 20,
                         max_wait => 0,
                         phase => l_phase,
                         status => l_status,
                         dev_phase => l_dev_phase,
                         dev_status => l_dev_status,
                         message => l_message
                       );
      IF (l_call_status = FALSE) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'Cannot wait for the status of 224 Extract Process';
        l_location   := 'wait_req1';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;

  END call_extract_process;


  ----------------------------------------------------------------------
  --                              MAIN
  ----------------------------------------------------------------------
  PROCEDURE main
  (
    p_errbuf                 OUT NOCOPY VARCHAR2,
    p_retcode                OUT NOCOPY NUMBER,
    p_set_of_books_id        IN NUMBER,
    p_gl_period              IN VARCHAR2,
    p_run_mode               IN VARCHAR2,
    p_partial_or_full        IN VARCHAR2,
    p_business_activity      IN VARCHAR2,
    p_gwa_reporter_category  IN VARCHAR2,
    p_alc                    IN VARCHAR2
  )
  IS
    l_module_name VARCHAR2(200);
    l_location    VARCHAR2(200);
    l_end_period_date DATE;
  BEGIN

    l_module_name := g_module_name || 'main';
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'START OF THE 224 MAIN PROCESS.....');
    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'INITIALIZING...');
    END IF;
    p_retcode := g_SUCCESS;

    update_flag         := p_run_mode;
    sob                 := p_set_of_books_id;
    p_def_org_id        := mo_global.get_current_org_id;
    g_partial_or_full   := p_partial_or_full;
    g_business_activity := p_business_activity;
    g_gwa_reporter_category := p_gwa_reporter_category;

    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level ) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'calling call_extract_process procedure       and run with org_id .' || p_def_org_id);
      END IF;

      call_extract_process
      (
        p_set_of_books_id => p_set_of_books_id,
        p_error_code      => p_retcode,
        p_error_desc      => p_errbuf
      );
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level ) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'calling post_process_for_main procedure.....');
      END IF;
      post_process_for_main
      (
        p_set_of_books_id       => p_set_of_books_id,
        p_gl_period             => p_gl_period,
        p_alc                   => p_alc,
        p_run_mode              => p_run_mode,
        p_partial_or_full       => p_partial_or_full,
        p_business_activity     => p_business_activity,
        p_gwa_reporter_category => p_gwa_reporter_category,
        p_end_period_date       => l_end_period_date,
        p_error_code            => p_retcode,
        p_error_desc            => p_errbuf
      );
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level ) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'calling submit_224_report procedure.....');
      END IF;
      submit_224_report
      (
        p_set_of_books_id       => p_set_of_books_id,
        p_gl_period             => p_gl_period,
        p_alc                   => p_alc,
        p_run_mode              => p_run_mode,
        p_partial_or_full       => p_partial_or_full,
        p_business_activity     => p_business_activity,
        p_gwa_reporter_category => p_gwa_reporter_category,
        p_error_code            => p_retcode,
        p_error_desc            => p_errbuf
      );
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      IF (update_flag = 'F') THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level ) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'calling update_audit_info procedure.....');
        END IF;
        update_audit_info
        (
          p_set_of_books_id => p_set_of_books_id,
          p_alc             => p_alc,
          p_end_period_date => l_end_period_date,
          p_error_code      => p_retcode,
          p_error_desc      => p_errbuf
        );
      END IF;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
        IF (p_partial_or_full='Full') THEN
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CALLING CHENCK ALC ADDRESS ROCEDURE.....');
           END IF;
           check_alc_address (p_alc) ;
        END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;

  END main;

----------------------------------------------------------------------
--                              CHECK_REPORT_DEFINTIONS
----------------------------------------------------------------------
  PROCEDURE  check_report_definitions
  (
    p_set_of_books_id   IN  gl_sets_of_books.set_of_books_id%TYPE,
    p_error_code        OUT NOCOPY NUMBER,
    p_error_desc        OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name VARCHAR2(200) ;
    l_cnt       NUMBER;
  BEGIN
    l_module_name := g_module_name || 'check_report_definitions';
    p_error_code := g_SUCCESS;
IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'In ' || l_module_name);
End if;

    SELECT COUNT(*)
      INTO l_cnt
      FROM fv_report_definitions
     WHERE set_of_books_id = p_set_of_books_id
       AND agency_location_code IS NULL
       AND d_r_flag IN ('D','R');

    IF l_cnt > 0 THEN
      p_error_code := g_FAILURE;
      p_error_desc  := 'The agency location code needs to be updated '||
      'for the Disbursement and Receipt records '||
      'in the 224 and Fund Balance with Treasury Form, '||
      'before running the 224 Process';
      fv_utility.log_mesg(fnd_log.level_error, l_module_name||'.error1', p_error_desc) ;
      RETURN;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    p_error_code := g_FAILURE;
    p_error_desc  := SQLERRM || ' -- Error in Check_Report_Defintions procedure.';
    fv_utility.log_mesg(fnd_log.level_unexpected, l_module_name||'.final_exception', p_error_desc) ;
    RETURN;
  END Check_Report_Definitions;

----------------------------------------------------------------------
--                              GET_RUN_DATE
----------------------------------------------------------------------
  PROCEDURE  get_run_date
  (
    p_set_of_books_id      IN  gl_sets_of_books.set_of_books_id%TYPE,
    p_previous_run_date    OUT NOCOPY fv_sf224_run.last_run_date%TYPE,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(400);
  BEGIN
    l_module_name := g_module_name || 'get_previous_run_date';
    p_error_code  := g_SUCCESS;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_set_of_books_id = '||p_set_of_books_id);
    END IF;

    BEGIN
        SELECT last_run_date
        INTO p_previous_run_date
        FROM fv_sf224_run fsr
        WHERE fsr.set_of_books_id = p_set_of_books_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
/* Commented out to get the old data
          SELECT min(start_date)
          INTO g_lo_date
          FROM gl_period_statuses
          WHERE ledger_id = sob
          AND   application_id = 101
          AND   period_year = to_char(sysdate, 'YYYY');
*/

          p_previous_run_date := g_lo_date;

      WHEN OTHERS THEN
        p_error_code := g_FAILURE;
        p_error_desc := SQLERRM;
        l_location   := l_module_name||'select_fv_sf224_run';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    END;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fv_utility.debug_mesg(fnd_log.level_statement,l_module_name,'Last 224 run_date ='||p_previous_run_date);
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
  END get_run_date;

----------------------------------------------------------------------
--                              SET_RUN_DATE
----------------------------------------------------------------------
  PROCEDURE  set_run_date
  (
    p_set_of_books_id      IN  gl_sets_of_books.set_of_books_id%TYPE,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(400);
    l_insert_required     BOOLEAN;
  BEGIN
    l_module_name := g_module_name || 'set_run_date';
    p_error_code  := g_SUCCESS;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_set_of_books_id = '||p_set_of_books_id);
    END IF;

    BEGIN
       UPDATE fv_sf224_run
         SET   last_run_date = g_SYSDATE
         WHERE set_of_books_id = p_set_of_books_id;
        IF (SQL%ROWCOUNT = 0) THEN
          l_insert_required := TRUE;
        ELSE
          l_insert_required := FALSE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'update_fv_sf224_run';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    IF (p_error_code = g_SUCCESS AND l_insert_required) THEN
      BEGIN
        INSERT INTO fv_sf224_run
        (
          set_of_books_id,
          last_run_date
        )
        VALUES
        (
          p_set_of_books_id,
          g_SYSDATE
        );
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'insert_fv_sf224_run';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
  END set_run_date;


----------------------------------------------------------------------
--                              INITIALIZE_PROGRAM_VARIABLES
----------------------------------------------------------------------
  PROCEDURE initialize_program_variables
  (
    p_set_of_books_id              IN  gl_sets_of_books.set_of_books_id%TYPE,
    p_currency_code                OUT NOCOPY gl_sets_of_books.currency_code%TYPE,
    p_chart_of_accounts_id         OUT NOCOPY gl_sets_of_books.chart_of_accounts_id%TYPE,
    p_acct_segment                 OUT NOCOPY fnd_id_flex_segments.application_column_name%TYPE,
    p_acct_value_set_id            OUT NOCOPY fnd_id_flex_segments.flex_value_set_id%TYPE,
    p_bal_segment                  OUT NOCOPY fnd_id_flex_segments.application_column_name%TYPE,
    p_accomplish_attribute         OUT NOCOPY fv_system_parameters.sf224_accomplish_date%TYPE,
    p_error_code                   OUT NOCOPY NUMBER,
    p_error_desc                   OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name          VARCHAR2(200);
    l_location             VARCHAR2(200);
    l_application_id       NUMBER := 101;
    l_id_flex_code         VARCHAR2(25) := 'GL#';
    l_acct_seg_attr_type   VARCHAR2(30) := 'GL_ACCOUNT';
    l_bal_seg_attr_type    VARCHAR2(30) := 'GL_BALANCING';
    l_retval               BOOLEAN;
    l_period_set_name      gl_period_sets.period_set_name%TYPE;

  BEGIN
    l_module_name := g_module_name || 'initialize_program_variables';
    p_error_code  := g_SUCCESS;

    p_chart_of_accounts_id := NULL;
    p_acct_segment         := NULL;
    p_acct_value_set_id    := NULL;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_set_of_books_id   = '||p_set_of_books_id);
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting from gl_sets_of_books');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'g_set_of_books_id='||p_set_of_books_id);
        END IF;
        SELECT gsob.chart_of_accounts_id,
               gsob.currency_code,
               gsob.period_set_name
          INTO p_chart_of_accounts_id,
               p_currency_code,
               l_period_set_name
          FROM gl_sets_of_books gsob
         WHERE set_of_books_id = p_set_of_books_id;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_chart_of_accounts_id='||p_chart_of_accounts_id);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'select_gl_sets_of_books';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling fnd_flex_apis.get_segment_column');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_application_id       ='||l_application_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_id_flex_code         ='||l_id_flex_code);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_chart_of_accounts_id ='||p_chart_of_accounts_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_acct_seg_attr_type   ='||l_acct_seg_attr_type);
      END IF;
      l_retval := fnd_flex_apis.get_segment_column
                  (
                    x_application_id  => l_application_id,
                    x_id_flex_code    => l_id_flex_code,
                    x_id_flex_num     => p_chart_of_accounts_id,
                    x_seg_attr_type   => l_acct_seg_attr_type,
                    x_app_column_name => p_acct_segment
                  );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_acct_segment  ='||p_acct_segment);
      END IF;
      IF (NOT l_retval) THEN
        p_error_code := g_FAILURE;
        p_error_desc := fnd_message.get;
        l_location   := l_module_name||'call_fnd_flex_apis.get_segment_column';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling fnd_flex_apis.get_segment_column');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_application_id       ='||l_application_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_id_flex_code         ='||l_id_flex_code);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_chart_of_accounts_id ='||p_chart_of_accounts_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_acct_seg_attr_type   ='||l_bal_seg_attr_type);
      END IF;
      l_retval := fnd_flex_apis.get_segment_column
                  (
                    x_application_id  => l_application_id,
                    x_id_flex_code    => l_id_flex_code,
                    x_id_flex_num     => p_chart_of_accounts_id,
                    x_seg_attr_type   => l_bal_seg_attr_type,
                    x_app_column_name => p_bal_segment
                  );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_acct_segment  ='||p_acct_segment);
      END IF;
      IF (NOT l_retval) THEN
        p_error_code := g_FAILURE;
        p_error_desc := fnd_message.get;
        l_location   := l_module_name||'call_fnd_flex_apis.get_segment_column';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        SELECT flex_value_set_id
          INTO p_acct_value_set_id
          FROM fnd_id_flex_segments
         WHERE application_column_name = p_acct_segment
           AND application_id = l_application_id
           AND id_flex_code = l_id_flex_code
           AND id_flex_num = p_chart_of_accounts_id
           AND enabled_flag = 'Y';
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'select_fnd_id_flex_segments';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        SELECT sf224_accomplish_date
          INTO p_accomplish_attribute
          FROM fv_system_parameters;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'select_fv_system_parameters';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
  END  initialize_program_variables;

----------------------------------------------------------------------
--                      INSERT_SF224_BATCHES
----------------------------------------------------------------------
  PROCEDURE insert_sf224_batches
  (
    p_set_of_books_id   IN  gl_sets_of_books.set_of_books_id%TYPE,
    p_previous_run_date IN fv_sf224_run.last_run_date%TYPE,
    p_current_run_date  IN fv_sf224_run.last_run_date%TYPE,
    p_currency_code     IN gl_sets_of_books.currency_code%TYPE,
    p_acct_segment      IN fnd_id_flex_segments.application_column_name%TYPE,
    p_bal_segment       IN fnd_id_flex_segments.application_column_name%TYPE,
    p_error_code        OUT NOCOPY NUMBER,
    p_error_desc        OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name VARCHAR2(200) ;
    l_string    varchar2(10000);
    l_string1    varchar2(10000);
    l_string2    varchar2(10000);
    l_string3    varchar2(1000);

    l_cur       number;
    l_row       number;

  BEGIN
    p_error_code := g_SUCCESS;
    l_module_name := g_module_name || 'insert_sf224_batches';

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'in insert_sf224_batches procedure, before the insert.');
    END IF;
    l_string1 := 'INSERT INTO FV_SF224_TEMP
                 (
                   je_batch_id,
                   fund_code,
                   fund_description,
                   sf224_type_code,
                   name,
                   set_of_books_id,
                   posted_date,
                   amount,
                   actual_amount,
                   d_r_flag,
                   reference_1,
                   reference_2,
                   reference_3,
                   reference_4,
                   reference_5,
                   reference_6,
                   reference_8,
                   reference_9,
                   je_line_num,
                   je_header_id,
                   gl_period,
                   default_period_name,
                   external_reference,
                   treasury_symbol,
                   treasury_symbol_id,
                   record_category,
                   federal_rpt_id,
                   sf224_processed_flag,
                   account,
                   exception_section,
                   gl_date,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   created_request_id,
                   JE_SOURCE,
                   JE_CATEGORY,
                   JE_FROM_SLA_FLAG
                 )';

    l_string3 := ' AND  not exists (select batch_id
                                     from fv_sf224_audits fvs
                                    where fvs.batch_id  = glb.je_batch_id
                                      and fvs.je_header_id = gll.je_header_id
                                      and fvs.je_line_num = gll.je_line_num)';

   /* Start for non-sla, upgraded 11i data */
    l_string2 :=
                 'SELECT glb.je_batch_id,
                      ffp.fund_value,
                      ffp.description,
                      fts.sf224_type_code,
                      glb.name,
                      decode(NVL(glh.je_from_sla_flag, ''N''),''U'', glb.SET_OF_BOOKS_ID_11I, ''N'', gll.ledger_id),
                      glb.posted_date,
                      nvl(gll.Entered_dr,0) - nvl(gll.Entered_cr,0),
                      nvl(gll.Entered_dr,0) - nvl(gll.Entered_cr,0),
                      frd.d_r_flag,
                      LTRIM(RTRIM(gll.reference_1)),
                      LTRIM(RTRIM(gll.reference_2)),
                      LTRIM(RTRIM(gll.reference_3)),
                      LTRIM(RTRIM(gll.reference_4)),
                      LTRIM(RTRIM(gll.reference_5)),
                      LTRIM(RTRIM(gll.reference_6)),
                      LTRIM(RTRIM(gll.reference_8)),
                      LTRIM(RTRIM(gll.reference_9)),
                      gll.je_line_num,
                      gll.je_header_id,
                      gll.period_name,
                      glb.default_period_name,
                      glh.external_reference,
                      fts.treasury_symbol,
                      ffp.treasury_symbol_id,
                      ''GLRECORD'',
                      frd.federal_rpt_id,
                      ''N'',
                      frd.account,
                      NULL,
                      gll.effective_date,
                      :b_user_id,
                      :b_sysdate,
                      :b_user_id,
                      :b_sysdate,
                      :b_login_id,
                      :b_request_id,
                      glh.je_source,
                      glh.je_category,
                      glh.je_from_sla_flag
                 FROM gl_je_batches glb,
                      gl_je_headers glh,
                      gl_je_lines gll,
                      gl_code_combinations gcc,
                      fv_report_definitions frd,
                      fv_fund_parameters ffp,
                      fv_treasury_symbols       fts
                WHERE glb.status = ''P''
                  AND glb.actual_flag = ''A''
                  AND glb.je_batch_id = glh.je_batch_id
                  AND glh.je_header_id = gll.je_header_id
                  AND gll.code_combination_id = gcc.code_combination_id
                  AND fts.treasury_symbol_id = ffp.treasury_symbol_id
                  AND gll.ledger_id    = :b_sob
                  AND frd.set_of_books_id  = :b_sob
                  AND ffp.set_of_books_id  = :b_sob
                  AND gcc.'||p_bal_segment||' = ffp.fund_value
                  AND glh.currency_code = :b_g_currency_code
                  AND glh.posted_date >= :posted_from_date
                  AND glh.posted_date <= :posted_to_date
                  AND gcc.'||p_acct_segment||' = frd.account
                  AND frd.d_r_flag in (''D'',''R'')
                  AND NVL(glh.je_from_sla_flag, ''N'')  IN (''N'', ''U'')';

    --IF (p_previous_run_date = g_lo_date) THEN
      l_string := l_string1 || l_string2 || l_string3 ;
    ---ELSE
      --l_string := l_string1 || l_string2;
    --END IF;

    l_cur:= dbms_sql.open_cursor;
    dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);
    dbms_sql.bind_variable(l_cur,':b_sob',p_set_of_books_id);
    dbms_sql.bind_variable(l_cur,':b_g_currency_code',p_currency_code);
    dbms_sql.bind_variable(l_cur,':posted_from_date',p_previous_run_date);
    dbms_sql.bind_variable(l_cur,':posted_to_date',p_current_run_date);
    dbms_sql.bind_variable(l_cur,':b_user_id',g_user_id);
    dbms_sql.bind_variable(l_cur,':b_sysdate',g_sysdate);
    dbms_sql.bind_variable(l_cur,':b_login_id',g_login_id);
    dbms_sql.bind_variable(l_cur,':b_request_id',g_request_id);
    l_row := dbms_sql.EXECUTE(l_cur);
    dbms_sql.close_cursor(l_cur);
   /* END for non-sla, upgraded 11i data */
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert for upgraded 11i data ');
   /* Start for je_source is payables and je_category is non treasury  */

    l_string2 :=  ' SELECT glb.je_batch_id,
                      ffp.fund_value,
                      ffp.description,
                      fts.sf224_type_code,
                      glb.name,
                      gll.ledger_id,
                      glb.posted_date,
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      frd.d_r_flag,
                      NULL, --LTRIM(RTRIM(gll.reference_1))
                      LTRIM(RTRIM(aid.invoice_id)),                    --Invoice_id  LTRIM(RTRIM(gll.reference_2))
                      LTRIM(RTRIM(aip.check_id)),                      --Check_id  LTRIM(RTRIM(gll.reference_3)),
                      NULL,  --LTRIM(RTRIM(gll.reference_4)),
                      NULL,  --LTRIM(RTRIM(gll.reference_5)),
                      NULL,  --LTRIM(RTRIM(gll.reference_6)),
                      LTRIM(RTRIM(aid.distribution_line_number)),  --  invoice_distributin_line_number LTRIM(RTRIM(gll.reference_8)),
                      LTRIM(RTRIM(aip.invoice_payment_id)),        --   invoice_payment_id   LTRIM(RTRIM(gll.reference_9)),
                      gll.je_line_num,
                      gll.je_header_id,
                      gll.period_name,
                      glb.default_period_name,
                      glh.external_reference,
                      fts.treasury_symbol,
                      ffp.treasury_symbol_id,
                      ''GLRECORD'',
                      frd.federal_rpt_id,
                      ''N'',
                      frd.account,
                      NULL,
                      gll.effective_date,
                      :b_user_id,
                      :b_sysdate,
                      :b_user_id,
                      :b_sysdate,
                      :b_login_id,
                      :b_request_id,
                      glh.je_source,
                      glh.je_category,
                      glh.je_from_sla_flag
                 FROM gl_je_batches glb,
                      gl_je_headers glh,
                      gl_je_lines gll,
                      gl_code_combinations gcc,
                      fv_report_definitions frd,
                      fv_fund_parameters ffp,
                      fv_treasury_symbols       fts,
                      ap_invoices_all ai,
                      ap_invoice_distributions_all aid,
                      ap_invoice_payments_all aip,
                      ap_payment_hist_dists aphd,
                      gl_import_references glir,
                      xla_ae_headers xah,
                      xla_ae_lines xal,
                      xla_events xet,
                      xla_distribution_links xdl
                WHERE glb.status = ''P''
                  AND glb.actual_flag = ''A''
                  AND glb.je_batch_id = glh.je_batch_id
                  AND glh.je_header_id = gll.je_header_id
                  AND gll.code_combination_id = gcc.code_combination_id
                  AND fts.treasury_symbol_id = ffp.treasury_symbol_id
                  AND aip.invoice_payment_id = aphd.invoice_payment_id
                  AND gll.ledger_id    = :b_sob
                  AND frd.set_of_books_id  = :b_sob
                  AND ffp.set_of_books_id  = :b_sob
                  AND gcc.'||p_bal_segment||' = ffp.fund_value
                  AND glh.currency_code = :b_g_currency_code
                  AND glh.posted_date >= :posted_from_date
                  AND glh.posted_date <= :posted_to_date
                  AND gcc.'||p_acct_segment||' = frd.account
                  AND frd.d_r_flag in (''D'',''R'')
                  AND glh.je_source=''Payables''
                  AND glh.je_category <> ''Treasury Confirmation''
                  AND glh.je_from_sla_flag = ''Y''
                  AND ai.invoice_id = aid.invoice_id
                  AND aip.invoice_id = ai.invoice_id
                  AND glir.je_header_id = gll.je_header_id
                  AND glir.je_line_num = gll.je_line_num
                  AND xal.gl_sl_link_id = glir.gl_sl_link_id
                  AND xal.gl_sl_link_table = glir.gl_sl_link_table
                  AND xal.ae_header_id = xah.ae_header_id
	              AND xet.event_id = xah.event_id
	              AND xdl.event_id = xet.event_id
                  AND xdl.ae_header_id = xah.ae_header_id
                  AND xdl.ae_line_num = xal.ae_line_num
                  AND xdl.source_distribution_type IN ( ''AP_PMT_DIST'')
                  AND xdl.source_distribution_id_num_1 = aphd.payment_hist_dist_id
                  AND aphd.invoice_distribution_id = aid.invoice_distribution_id
                  AND xdl.application_id = 200 ';

    --IF (p_previous_run_date = g_lo_date) THEN
      l_string := l_string1 || l_string2 || l_string3 ;
    --ELSE
      --l_string := l_string1 || l_string2;
    --END IF;

    l_cur:= dbms_sql.open_cursor;
    dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);
    dbms_sql.bind_variable(l_cur,':b_sob',p_set_of_books_id);
    dbms_sql.bind_variable(l_cur,':b_g_currency_code',p_currency_code);
    dbms_sql.bind_variable(l_cur,':posted_from_date',p_previous_run_date);
    dbms_sql.bind_variable(l_cur,':posted_to_date',p_current_run_date);
    dbms_sql.bind_variable(l_cur,':b_user_id',g_user_id);
    dbms_sql.bind_variable(l_cur,':b_sysdate',g_sysdate);
    dbms_sql.bind_variable(l_cur,':b_login_id',g_login_id);
    dbms_sql.bind_variable(l_cur,':b_request_id',g_request_id);
    l_row := dbms_sql.EXECUTE(l_cur);
    dbms_sql.close_cursor(l_cur);
   /* END for  je_source is payables and je_category is non treasury*/

   /* Start for je_source is payables and je_category is non treasury  */

    l_string2 :=  ' SELECT glb.je_batch_id,
                      ffp.fund_value,
                      ffp.description,
                      fts.sf224_type_code,
                      glb.name,
                      gll.ledger_id,
                      glb.posted_date,
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      frd.d_r_flag,
                      NULL, --LTRIM(RTRIM(gll.reference_1))
                      LTRIM(RTRIM(aid.invoice_id)),                    --Invoice_id  LTRIM(RTRIM(gll.reference_2))
                      LTRIM(RTRIM(aip.check_id)),                      --Check_id  LTRIM(RTRIM(gll.reference_3)),
                      NULL,  --LTRIM(RTRIM(gll.reference_4)),
                      NULL,  --LTRIM(RTRIM(gll.reference_5)),
                      NULL,  --LTRIM(RTRIM(gll.reference_6)),
                      LTRIM(RTRIM(aid.distribution_line_number)),  --  invoice_distributin_line_number LTRIM(RTRIM(gll.reference_8)),
                      LTRIM(RTRIM(aip.invoice_payment_id)),        --   invoice_payment_id   LTRIM(RTRIM(gll.reference_9)),
                      gll.je_line_num,
                      gll.je_header_id,
                      gll.period_name,
                      glb.default_period_name,
                      glh.external_reference,
                      fts.treasury_symbol,
                      ffp.treasury_symbol_id,
                      ''GLRECORD'',
                      frd.federal_rpt_id,
                      ''N'',
                      frd.account,
                      NULL,
                      gll.effective_date,
                      :b_user_id,
                      :b_sysdate,
                      :b_user_id,
                      :b_sysdate,
                      :b_login_id,
                      :b_request_id,
                      glh.je_source,
                      glh.je_category,
                      glh.je_from_sla_flag
                 FROM gl_je_batches glb,
                      gl_je_headers glh,
                      gl_je_lines gll,
                      gl_code_combinations gcc,
                      fv_report_definitions frd,
                      fv_fund_parameters ffp,
                      fv_treasury_symbols       fts,
                      ap_invoices_all ai,
                      ap_invoice_distributions_all aid,
                      ap_invoice_payments_all aip,
                      gl_import_references glir,
                      xla_ae_headers xah,
                      xla_ae_lines xal,
                      xla_events xet,
                      xla_distribution_links xdl
                WHERE glb.status = ''P''
                  AND glb.actual_flag = ''A''
                  AND glb.je_batch_id = glh.je_batch_id
                  AND glh.je_header_id = gll.je_header_id
                  AND gll.code_combination_id = gcc.code_combination_id
                  AND fts.treasury_symbol_id = ffp.treasury_symbol_id
                  AND gll.ledger_id    = :b_sob
                  AND frd.set_of_books_id  = :b_sob
                  AND ffp.set_of_books_id  = :b_sob
                  AND gcc.'||p_bal_segment||' = ffp.fund_value
                  AND glh.currency_code = :b_g_currency_code
                  AND glh.posted_date >= :posted_from_date
                  AND glh.posted_date <= :posted_to_date
                  AND gcc.'||p_acct_segment||' = frd.account
                  AND frd.d_r_flag in (''D'',''R'')
                  AND glh.je_source=''Payables''
                  AND glh.je_category <> ''Treasury Confirmation''
                  AND glh.je_from_sla_flag = ''Y''
                  AND ai.invoice_id = aid.invoice_id
                  AND aip.invoice_id = ai.invoice_id
                  AND glir.je_header_id = gll.je_header_id
                  AND glir.je_line_num = gll.je_line_num
                  AND xal.gl_sl_link_id = glir.gl_sl_link_id
                  AND xal.gl_sl_link_table = glir.gl_sl_link_table
                  AND xal.ae_header_id = xah.ae_header_id
	              AND xet.event_id = xah.event_id
	              AND xdl.event_id = xet.event_id
                  AND xdl.ae_header_id = xah.ae_header_id
                  AND xdl.ae_line_num = xal.ae_line_num
                  AND xdl.source_distribution_type IN ( ''AP_INV_DIST'', ''AP_PREPAY'')
                  AND xdl.source_distribution_id_num_1 = aid.invoice_distribution_id
                  AND xdl.application_id = 200 ';

    --IF (p_previous_run_date = g_lo_date) THEN
      l_string := l_string1 || l_string2 || l_string3 ;
    --ELSE
      --l_string := l_string1 || l_string2;
    --END IF;

    l_cur:= dbms_sql.open_cursor;
    dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);
    dbms_sql.bind_variable(l_cur,':b_sob',p_set_of_books_id);
    dbms_sql.bind_variable(l_cur,':b_g_currency_code',p_currency_code);
    dbms_sql.bind_variable(l_cur,':posted_from_date',p_previous_run_date);
    dbms_sql.bind_variable(l_cur,':posted_to_date',p_current_run_date);
    dbms_sql.bind_variable(l_cur,':b_user_id',g_user_id);
    dbms_sql.bind_variable(l_cur,':b_sysdate',g_sysdate);
    dbms_sql.bind_variable(l_cur,':b_login_id',g_login_id);
    dbms_sql.bind_variable(l_cur,':b_request_id',g_request_id);
    l_row := dbms_sql.EXECUTE(l_cur);
    dbms_sql.close_cursor(l_cur);
   /* END for  je_source is payables and je_category is non treasury*/
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert for je_source is payables and je_category is non treasury');
   /* Start for je_source is payables and je_category is treasury confirmation */

    l_string2 := ' SELECT glb.je_batch_id,
                      ffp.fund_value,
                      ffp.description,
                      fts.sf224_type_code,
                      DECODE (xle.event_type_code, ''TREASURY_VOID'', REPLACE (glb.name, ''Budget Execution'', ''VOID''), glb.name),
                      gll.ledger_id,
                      glb.posted_date,
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      frd.d_r_flag,
                      LTRIM(RTRIM(xdl.APPLIED_TO_SOURCE_ID_NUM_1)),  -- treasury confirmation id  LTRIM(RTRIM(gll.reference_1)),
                      NULL, --LTRIM(RTRIM(gll.reference_2)),
                      LTRIM(RTRIM(AIP.check_id)),                      --Check_id LTRIM(RTRIM(gll.reference_3)),
                      LTRIM(RTRIM(aid.invoice_id)),                   --invoice_id LTRIM(RTRIM(gll.reference_4)),
                      NULL, --LTRIM(RTRIM(gll.reference_5)),
                      LTRIM(RTRIM(ftc.treasury_doc_date)),                  --Accomplish date LTRIM(RTRIM(gll.reference_6)),
                      NULL, --LTRIM(RTRIM(gll.reference_8)),
                      NULL,--LTRIM(RTRIM(gll.reference_9)),
                      gll.je_line_num,
                      gll.je_header_id,
                      gll.period_name,
                      glb.default_period_name,
                      glh.external_reference,
                      fts.treasury_symbol,
                      ffp.treasury_symbol_id,
                      ''GLRECORD'',
                      frd.federal_rpt_id,
                      ''N'',
                      frd.account,
                      NULL,
                      gll.effective_date,
                      :b_user_id,
                      :b_sysdate,
                      :b_user_id,
                      :b_sysdate,
                      :b_login_id,
                      :b_request_id,
                      glh.je_source,
                      glh.je_category,
                      glh.je_from_sla_flag
                 FROM gl_je_batches glb,
                      gl_je_headers glh,
                      gl_je_lines gll,
                      gl_code_combinations gcc,
                      fv_report_definitions frd,
                      fv_fund_parameters ffp,
                      fv_treasury_symbols       fts,
                      ap_invoice_distributions_all aid,
                      ap_invoice_payments_all aip,
                      ap_payment_hist_dists aphd,
                      gl_import_references glir,
                      xla_ae_headers xah,
                      xla_ae_lines xal,
                      xla_distribution_links xdl,
                      fv_treasury_confirmations_all ftc,
                      xla_events xle
                WHERE glb.status = ''P''
                  AND glb.actual_flag = ''A''
                  AND glb.je_batch_id = glh.je_batch_id
                  AND glh.je_header_id = gll.je_header_id
                  AND gll.code_combination_id = gcc.code_combination_id
                  AND fts.treasury_symbol_id = ffp.treasury_symbol_id
                  AND gll.ledger_id    = :b_sob
                  AND frd.set_of_books_id  = :b_sob
                  AND ffp.set_of_books_id  = :b_sob
                  AND gcc.'||p_bal_segment||' = ffp.fund_value
                  AND glh.currency_code = :b_g_currency_code
                  AND glh.posted_date >= :posted_from_date
                  AND glh.posted_date <= :posted_to_date
                  AND gcc.'||p_acct_segment||' = frd.account
                  AND frd.d_r_flag in (''D'',''R'')
                  AND glh.je_category = ''Treasury Confirmation''
                  AND glh.je_from_sla_flag = ''Y''
                  AND aip.invoice_payment_id = aphd.invoice_payment_id
                  AND glir.je_header_id = gll.je_header_id
                  AND glir.je_line_num = gll.je_line_num
                  AND xal.gl_sl_link_id = glir.gl_sl_link_id
                  AND xal.gl_sl_link_table = glir.gl_sl_link_table
                  AND xal.ae_header_id = xah.ae_header_id
	              AND xdl.event_id = xah.event_id
                AND xle.event_id = xah.event_id
                AND ftc.treasury_confirmation_id = xdl.APPLIED_TO_SOURCE_ID_NUM_1
                  AND xdl.ae_header_id = xah.ae_header_id
                  AND xdl.ae_line_num = xal.ae_line_num
                  AND xdl.source_distribution_type = ''FV_TREASURY_CONFIRMATIONS_ALL''
                  AND xdl.source_distribution_id_num_1 = aphd.payment_hist_dist_id
                  AND aid.invoice_distribution_id = aphd.invoice_distribution_id
                  AND xdl.application_id = 8901 ' ;
    --IF (p_previous_run_date = g_lo_date) THEN
      l_string := l_string1 || l_string2 || l_string3 ;
    --ELSE
      --l_string := l_string1 || l_string2;
    --END IF;

    l_cur:= dbms_sql.open_cursor;
    dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);
    dbms_sql.bind_variable(l_cur,':b_sob',p_set_of_books_id);
    dbms_sql.bind_variable(l_cur,':b_g_currency_code',p_currency_code);
    dbms_sql.bind_variable(l_cur,':posted_from_date',p_previous_run_date);
    dbms_sql.bind_variable(l_cur,':posted_to_date',p_current_run_date);
    dbms_sql.bind_variable(l_cur,':b_user_id',g_user_id);
    dbms_sql.bind_variable(l_cur,':b_sysdate',g_sysdate);
    dbms_sql.bind_variable(l_cur,':b_login_id',g_login_id);
    dbms_sql.bind_variable(l_cur,':b_request_id',g_request_id);
    l_row := dbms_sql.EXECUTE(l_cur);
    dbms_sql.close_cursor(l_cur);
   /* END for je_source is payables and je_category is treasury confirmation  */
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert for je_source is payables and je_category is treasury confirmation');

   /* Start for je_source is project and je_category is labour_cost */

    l_string2 := ' SELECT glb.je_batch_id,
                      ffp.fund_value,
                      ffp.description,
                      fts.sf224_type_code,
                      glb.name,
                      gll.ledger_id,
                      glb.posted_date,
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      frd.d_r_flag,
                      LTRIM(RTRIM(xte.SOURCE_ID_INT_1)),  -- expenditure_item_id  LTRIM(RTRIM(gll.reference_1)),
                      NULL, --LTRIM(RTRIM(gll.reference_2)),
                      NULL, --LTRIM(RTRIM(gll.reference_3)),
                      NULL, --LTRIM(RTRIM(gll.reference_4)),
                      NULL, --LTRIM(RTRIM(gll.reference_5)),
                      NULL, --LTRIM(RTRIM(gll.reference_6)),
                      NULL, --LTRIM(RTRIM(gll.reference_8)),
                      NULL, --LTRIM(RTRIM(gll.reference_9)),
                      gll.je_line_num,
                      gll.je_header_id,
                      gll.period_name,
                      glb.default_period_name,
                      glh.external_reference,
                      fts.treasury_symbol,
                      ffp.treasury_symbol_id,
                      ''GLRECORD'',
                      frd.federal_rpt_id,
                      ''N'',
                      frd.account,
                      NULL,
                      gll.effective_date,
                      :b_user_id,
                      :b_sysdate,
                      :b_user_id,
                      :b_sysdate,
                      :b_login_id,
                      :b_request_id,
                      glh.je_source,
                      glh.je_category,
                      glh.je_from_sla_flag

                 FROM gl_je_batches glb,
                      gl_je_headers glh,
                      gl_je_lines gll,
                      gl_code_combinations gcc,
                      fv_report_definitions frd,
                      fv_fund_parameters ffp,
                      fv_treasury_symbols fts,
                      gl_import_references glir,
                      xla_ae_headers xah,
                      xla_ae_lines xal,
                      xla_events xet,
                      xla_distribution_links xdl,
                      xla_transaction_entities  xte
                WHERE glb.status = ''P''
                  AND glb.actual_flag = ''A''
                  AND glb.je_batch_id = glh.je_batch_id
                  AND glh.je_header_id = gll.je_header_id
                  AND gll.code_combination_id = gcc.code_combination_id
                  AND fts.treasury_symbol_id = ffp.treasury_symbol_id
                  AND gll.ledger_id    = :b_sob
                  AND frd.set_of_books_id  = :b_sob
                  AND ffp.set_of_books_id  = :b_sob
                  AND gcc.'||p_bal_segment||' = ffp.fund_value
                  AND glh.currency_code = :b_g_currency_code
                  AND glh.posted_date >= :posted_from_date
                  AND glh.posted_date <= :posted_to_date
                  AND gcc.'||p_acct_segment||' = frd.account
                  AND frd.d_r_flag in (''D'',''R'')
                  AND glh.je_source=''Project Accounting''
                  AND glh.je_category = ''Labor Cost''
                  AND glh.je_from_sla_flag = ''Y''
                  AND glir.je_header_id = gll.je_header_id
                  AND glir.je_line_num = gll.je_line_num
                  AND xal.gl_sl_link_id = glir.gl_sl_link_id
                  AND xal.gl_sl_link_table = glir.gl_sl_link_table
                  AND xal.ae_header_id = xah.ae_header_id
	              AND xet.event_id = xah.event_id
	              -- AND xte.event_id = xet.event_id
	              AND xdl.event_id = xet.event_id
                  AND xdl.ae_header_id = xah.ae_header_id
                  AND xdl.ae_line_num = xal.ae_line_num
                  AND xte.entity_id = xet.entity_id
                  AND xte.entity_code =''EXPENDITURES''
                  AND xdl.APPLICATION_ID = 275 ';

    --IF (p_previous_run_date = g_lo_date) THEN
      l_string := l_string1 || l_string2 || l_string3 ;
    --ELSE
      --l_string := l_string1 || l_string2;
    --END IF;

    l_cur:= dbms_sql.open_cursor;
    dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);
    dbms_sql.bind_variable(l_cur,':b_sob',p_set_of_books_id);
    dbms_sql.bind_variable(l_cur,':b_g_currency_code',p_currency_code);
    dbms_sql.bind_variable(l_cur,':posted_from_date',p_previous_run_date);
    dbms_sql.bind_variable(l_cur,':posted_to_date',p_current_run_date);
    dbms_sql.bind_variable(l_cur,':b_user_id',g_user_id);
    dbms_sql.bind_variable(l_cur,':b_sysdate',g_sysdate);
    dbms_sql.bind_variable(l_cur,':b_login_id',g_login_id);
    dbms_sql.bind_variable(l_cur,':b_request_id',g_request_id);
    l_row := dbms_sql.EXECUTE(l_cur);
    dbms_sql.close_cursor(l_cur);
   /* END for  je_source is project and je_category is labour_cost */
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert for je_source is project and je_category is labour_cost');
   /* Start for je_source is Receivables, based on ar_cash_receipt_history_all */

    l_string2 := ' SELECT glb.je_batch_id,
                      ffp.fund_value,
                      ffp.description,
                      fts.sf224_type_code,
                      glb.name,
                      gll.ledger_id,
                      glb.posted_date,
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      frd.d_r_flag,
                      NULL, --LTRIM(RTRIM(gll.reference_1)),
                      LTRIM(RTRIM(arch.cash_receipt_id)),  --LTRIM(RTRIM(gll.reference_2)),
                      NULL, --LTRIM(RTRIM(gll.reference_3)),
                      NULL, --LTRIM(RTRIM(gll.reference_4)),
                      LTRIM(RTRIM(arch.CASH_RECEIPT_HISTORY_ID)),  ---cash_receipt_hist_id --LTRIM(RTRIM(gll.reference_5)),
                      NULL, --LTRIM(RTRIM(gll.reference_6)),
                      NULL, --LTRIM(RTRIM(gll.reference_8)),
                      NULL, --LTRIM(RTRIM(gll.reference_9)),
                      gll.je_line_num,
                      gll.je_header_id,
                      gll.period_name,
                      glb.default_period_name,
                      glh.external_reference,
                      fts.treasury_symbol,
                      ffp.treasury_symbol_id,
                      ''GLRECORD'',
                      frd.federal_rpt_id,
                      ''N'',
                      frd.account,
                      NULL,
                      gll.effective_date,
                      :b_user_id,
                      :b_sysdate,
                      :b_user_id,
                      :b_sysdate,
                      :b_login_id,
                      :b_request_id,
                      glh.je_source,
                      glh.je_category,
                      glh.je_from_sla_flag
                 FROM gl_je_batches glb,
                      gl_je_headers glh,
                      gl_je_lines gll,
                      gl_code_combinations gcc,
                      fv_report_definitions frd,
                      fv_fund_parameters ffp,
                      fv_treasury_symbols       fts,
                      ar_distributions_all  ard,
                      ar_cash_receipt_history_all  arch,
                      gl_import_references glir,
                      xla_ae_headers xah,
                      xla_ae_lines xal,
                      xla_events xet,
                      xla_distribution_links xdl,
                      xla_transaction_entities  xte
                WHERE glb.status = ''P''
                  AND glb.actual_flag = ''A''
                  AND glb.je_batch_id = glh.je_batch_id
                  AND glh.je_header_id = gll.je_header_id
                  AND gll.code_combination_id = gcc.code_combination_id
                  AND fts.treasury_symbol_id = ffp.treasury_symbol_id
                  AND gll.ledger_id    = :b_sob
                  AND frd.set_of_books_id  = :b_sob
                  AND ffp.set_of_books_id  = :b_sob
                  AND gcc.'||p_bal_segment||' = ffp.fund_value
                  AND glh.currency_code = :b_g_currency_code
                  AND glh.posted_date >= :posted_from_date
                  AND glh.posted_date <= :posted_to_date
                  AND gcc.'||p_acct_segment||' = frd.account
                  AND frd.d_r_flag in (''D'',''R'')
                  AND glh.je_source=''Receivables''
                  --AND glh.je_category = ''Misc Receipts''
                  AND glh.je_from_sla_flag = ''Y''
                  AND glir.je_header_id = gll.je_header_id
                  AND glir.je_line_num = gll.je_line_num
                  AND xal.gl_sl_link_id = glir.gl_sl_link_id
                  AND xal.gl_sl_link_table = glir.gl_sl_link_table
                  AND xal.ae_header_id = xah.ae_header_id
	              AND xet.event_id = xah.event_id
	              -- AND xte.event_id = xet.event_id
                  AND xte.entity_id = xet.entity_id
	              AND xdl.event_id = xet.event_id
                  AND xdl.ae_header_id = xah.ae_header_id
                  AND xdl.ae_line_num = xal.ae_line_num
                  AND xdl.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
                  AND xdl.source_distribution_id_num_1 =  ard.line_id
                  AND ard.source_table=''CRH''
                  AND ard.source_id = arch.CASH_RECEIPT_HISTORY_ID
                  AND xdl.APPLICATION_ID = 222 ';
    --IF (p_previous_run_date = g_lo_date) THEN
      l_string := l_string1 || l_string2 || l_string3 ;
    --ELSE
      --l_string := l_string1 || l_string2;
    --END IF;


    l_cur:= dbms_sql.open_cursor;
    dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);
    dbms_sql.bind_variable(l_cur,':b_sob',p_set_of_books_id);
    dbms_sql.bind_variable(l_cur,':b_g_currency_code',p_currency_code);
    dbms_sql.bind_variable(l_cur,':posted_from_date',p_previous_run_date);
    dbms_sql.bind_variable(l_cur,':posted_to_date',p_current_run_date);
    dbms_sql.bind_variable(l_cur,':b_user_id',g_user_id);
    dbms_sql.bind_variable(l_cur,':b_sysdate',g_sysdate);
    dbms_sql.bind_variable(l_cur,':b_login_id',g_login_id);
    dbms_sql.bind_variable(l_cur,':b_request_id',g_request_id);
    l_row := dbms_sql.EXECUTE(l_cur);
    dbms_sql.close_cursor(l_cur);
   /* END for  je_source is Receivables, based on ar_cash_receipt_history_all*/
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert for je_source is Receivables, based on ar_cash_receipt_history_all');
  /* Start for je_source is Receivables , based on AR_RECEIVABLE_APPLICATIONS_ALL */

    l_string2 := ' SELECT glb.je_batch_id,
                      ffp.fund_value,
                      ffp.description,
                      fts.sf224_type_code,
                      glb.name,
                      gll.ledger_id,
                      glb.posted_date,
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      frd.d_r_flag,
                      NULL, --LTRIM(RTRIM(gll.reference_1)),
                      LTRIM(RTRIM(arr.cash_receipt_id)),  --LTRIM(RTRIM(gll.reference_2)),
                      NULL, --LTRIM(RTRIM(gll.reference_3)),
                      NULL, --LTRIM(RTRIM(gll.reference_4)),
                      LTRIM(RTRIM(arr.receivable_application_id)),  ---cash_receipt_hist_id --LTRIM(RTRIM(gll.reference_5)),
                      NULL, --LTRIM(RTRIM(gll.reference_6)),
                      NULL, --LTRIM(RTRIM(gll.reference_8)),
                      NULL, --LTRIM(RTRIM(gll.reference_9)),
                      gll.je_line_num,
                      gll.je_header_id,
                      gll.period_name,
                      glb.default_period_name,
                      glh.external_reference,
                      fts.treasury_symbol,
                      ffp.treasury_symbol_id,
                      ''GLRECORD'',
                      frd.federal_rpt_id,
                      ''N'',
                      frd.account,
                      NULL,
                      gll.effective_date,
                      :b_user_id,
                      :b_sysdate,
                      :b_user_id,
                      :b_sysdate,
                      :b_login_id,
                      :b_request_id,
                      glh.je_source,
                      glh.je_category,
                      glh.je_from_sla_flag
                 FROM gl_je_batches glb,
                      gl_je_headers glh,
                      gl_je_lines gll,
                      gl_code_combinations gcc,
                      fv_report_definitions frd,
                      fv_fund_parameters ffp,
                      fv_treasury_symbols       fts,
                      ar_distributions_all ard,
                      AR_RECEIVABLE_APPLICATIONS_ALL arr,
                      gl_import_references glir,
                      xla_ae_headers xah,
                      xla_ae_lines xal,
                      xla_events xet,
                      xla_distribution_links xdl,
                      xla_transaction_entities  xte
                WHERE glb.status = ''P''
                  AND glb.actual_flag = ''A''
                  AND glb.je_batch_id = glh.je_batch_id
                  AND glh.je_header_id = gll.je_header_id
                  AND gll.code_combination_id = gcc.code_combination_id
                  AND fts.treasury_symbol_id = ffp.treasury_symbol_id
                  AND gll.ledger_id    = :b_sob
                  AND frd.set_of_books_id  = :b_sob
                  AND ffp.set_of_books_id  = :b_sob
                  AND gcc.'||p_bal_segment||' = ffp.fund_value
                  AND glh.currency_code = :b_g_currency_code
                  AND glh.posted_date >= :posted_from_date
                  AND glh.posted_date <= :posted_to_date
                  AND gcc.'||p_acct_segment||' = frd.account
                  AND frd.d_r_flag in (''D'',''R'')
                  AND glh.je_source=''Receivables''
                  --AND glh.je_category = ''Misc Receipts''
                  AND glh.je_from_sla_flag = ''Y''
                  AND glir.je_header_id = gll.je_header_id
                  AND glir.je_line_num = gll.je_line_num
                  AND xal.gl_sl_link_id = glir.gl_sl_link_id
                  AND xal.gl_sl_link_table = glir.gl_sl_link_table
                  AND xal.ae_header_id = xah.ae_header_id
	              AND xet.event_id = xah.event_id
	              --AND xte.event_id = xet.event_id
                  AND xte.entity_id = xet.entity_id
	              AND xdl.event_id = xet.event_id
                  AND xdl.ae_header_id = xah.ae_header_id
                  AND xdl.ae_line_num = xal.ae_line_num
                  AND xdl.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
                  AND xdl.source_distribution_id_num_1 =  ard.line_id
                  AND ard.source_table=''RA''
                  AND ard.source_id = arr.receivable_application_id
                  AND xdl.APPLICATION_ID = 222 ';

    --IF (p_previous_run_date = g_lo_date) THEN
      l_string := l_string1 || l_string2 || l_string3 ;
    --ELSE
      --l_string := l_string1 || l_string2;
    --END IF;

    l_cur:= dbms_sql.open_cursor;
    dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);
    dbms_sql.bind_variable(l_cur,':b_sob',p_set_of_books_id);
    dbms_sql.bind_variable(l_cur,':b_g_currency_code',p_currency_code);
    dbms_sql.bind_variable(l_cur,':posted_from_date',p_previous_run_date);
    dbms_sql.bind_variable(l_cur,':posted_to_date',p_current_run_date);
    dbms_sql.bind_variable(l_cur,':b_user_id',g_user_id);
    dbms_sql.bind_variable(l_cur,':b_sysdate',g_sysdate);
    dbms_sql.bind_variable(l_cur,':b_login_id',g_login_id);
    dbms_sql.bind_variable(l_cur,':b_request_id',g_request_id);
    l_row := dbms_sql.EXECUTE(l_cur);
    dbms_sql.close_cursor(l_cur);

   /* END for  je_source is Receivables , based on AR_RECEIVABLE_APPLICATIONS_ALL */
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert for je_source is Receivables , based on AR_RECEIVABLE_APPLICATIONS_ALL ');
  /* Start for for je_source is Receivables , based on AR_MISC_CASH_DISTRIBUTIONS_ALL */

    l_string2 := ' SELECT glb.je_batch_id,
                      ffp.fund_value,
                      ffp.description,
                      fts.sf224_type_code,
                      glb.name,
                      gll.ledger_id,
                      glb.posted_date,
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      nvl(xdl.unrounded_accounted_dr,0) - nvl(xdl.unrounded_accounted_cr,0),
                      frd.d_r_flag,
                      NULL, --LTRIM(RTRIM(gll.reference_1)),
                      LTRIM(RTRIM(arm.cash_receipt_id)),
                      NULL, --LTRIM(RTRIM(gll.reference_3)),
                      NULL, --LTRIM(RTRIM(gll.reference_4)),
                      LTRIM(RTRIM(arm.MISC_CASH_DISTRIBUTION_ID)),  --cash_receipt_hist_id --LTRIM(RTRIM(gll.reference_5)),
                      NULL, --LTRIM(RTRIM(gll.reference_6)),
                      NULL, --LTRIM(RTRIM(gll.reference_8)),
                      NULL, --LTRIM(RTRIM(gll.reference_9)),
                      gll.je_line_num,
                      gll.je_header_id,
                      gll.period_name,
                      glb.default_period_name,
                      glh.external_reference,
                      fts.treasury_symbol,
                      ffp.treasury_symbol_id,
                      ''GLRECORD'',
                      frd.federal_rpt_id,
                      ''N'',
                      frd.account,
                      NULL,
                      gll.effective_date,
                      :b_user_id,
                      :b_sysdate,
                      :b_user_id,
                      :b_sysdate,
                      :b_login_id,
                      :b_request_id,
                      glh.je_source,
                      glh.je_category,
                      glh.je_from_sla_flag
                 FROM gl_je_batches glb,
                      gl_je_headers glh,
                      gl_je_lines gll,
                      gl_code_combinations gcc,
                      fv_report_definitions frd,
                      fv_fund_parameters ffp,
                      fv_treasury_symbols       fts,
                      ar_distributions_all  ard,
                      AR_MISC_CASH_DISTRIBUTIONS_ALL arm,
                      gl_import_references glir,
                      xla_ae_headers xah,
                      xla_ae_lines xal,
                      xla_events xet,
                      xla_distribution_links xdl,
                      xla_transaction_entities  xte
                WHERE glb.status = ''P''
                  AND glb.actual_flag = ''A''
                  AND glb.je_batch_id = glh.je_batch_id
                  AND glh.je_header_id = gll.je_header_id
                  AND gll.code_combination_id = gcc.code_combination_id
                  AND fts.treasury_symbol_id = ffp.treasury_symbol_id
                  AND gll.ledger_id    = :b_sob
                  AND frd.set_of_books_id  = :b_sob
                  AND ffp.set_of_books_id  = :b_sob
                  AND gcc.'||p_bal_segment||' = ffp.fund_value
                  AND glh.currency_code = :b_g_currency_code
                  AND glh.posted_date >= :posted_from_date
                  AND glh.posted_date <= :posted_to_date
                  AND gcc.'||p_acct_segment||' = frd.account
                  AND frd.d_r_flag in (''D'',''R'')
                  AND glh.je_source=''Receivables''
                  --AND glh.je_category = ''Misc Receipts''
                  AND glh.je_from_sla_flag = ''Y''
                  AND glir.je_header_id = gll.je_header_id
                  AND glir.je_line_num = gll.je_line_num
                  AND xal.gl_sl_link_id = glir.gl_sl_link_id
                  AND xal.gl_sl_link_table = glir.gl_sl_link_table
                  AND xal.ae_header_id = xah.ae_header_id
	              AND xet.event_id = xah.event_id
	              --AND xte.event_id = xet.event_id
	              AND xte.entity_id = xet.entity_id
	              AND xdl.event_id = xet.event_id
                  AND xdl.ae_header_id = xah.ae_header_id
                  AND xdl.ae_line_num = xal.ae_line_num
                  AND xdl.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
                  AND xdl.source_distribution_id_num_1 =  ard.line_id
                  AND ard.source_id = arm.MISC_CASH_DISTRIBUTION_ID
                  AND ard.source_table=''MCD''
                  AND xdl.APPLICATION_ID = 222 ';
    --IF (p_previous_run_date = g_lo_date) THEN
      l_string := l_string1 || l_string2 || l_string3 ;
    --ELSE
      --l_string := l_string1 || l_string2;
    --END IF;


    l_cur:= dbms_sql.open_cursor;
    dbms_sql.parse(l_cur, l_string, DBMS_SQL.V7);
    dbms_sql.bind_variable(l_cur,':b_sob',p_set_of_books_id);
    dbms_sql.bind_variable(l_cur,':b_g_currency_code',p_currency_code);
    dbms_sql.bind_variable(l_cur,':posted_from_date',p_previous_run_date);
    dbms_sql.bind_variable(l_cur,':posted_to_date',p_current_run_date);
    dbms_sql.bind_variable(l_cur,':b_user_id',g_user_id);
    dbms_sql.bind_variable(l_cur,':b_sysdate',g_sysdate);
    dbms_sql.bind_variable(l_cur,':b_login_id',g_login_id);
    dbms_sql.bind_variable(l_cur,':b_request_id',g_request_id);
    l_row := dbms_sql.EXECUTE(l_cur);
    dbms_sql.close_cursor(l_cur);
   /* END for  je_source is Receivables , based on AR_MISC_CASH_DISTRIBUTIONS_ALL */
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'End of Insert for je_source is Receivables , based on AR_MISC_CASH_DISTRIBUTIONS_ALL ');

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := sqlcode;
      p_error_desc  := sqlerrm;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_module_name||'.final_exception', p_error_desc) ;
  END  insert_sf224_batches ;


----------------------------------------------------------------------
--                      PROCESS_SF224_TRANSACTIONS
----------------------------------------------------------------------
  PROCEDURE Process_sf224_transactions is

  l_module_name          VARCHAR2(200);
  l_org_amount           NUMBER;
  l_reference            NUMBER;
  l_exists               VARCHAR2(1);
  p_def_p_ia_paygroup    VARCHAR2(30);
  l_inv_pay_id           NUMBER(15):= 0;

  --Variables defined for dbms_sql
  l_cursor_id            INTEGER;
  l_ignore               INTEGER;
  l_select               VARCHAR2(2000);

  vl_checkrun_name       Ap_Inv_Selection_Criteria_All.checkrun_name%TYPE;
  vl_treasury_symbol     Fv_Treasury_Symbols.treasury_symbol%TYPE;
  vl_misc_cd_flag        VARCHAR2(1);
  vl_refund_cnt          NUMBER:= 0;

  vg_bank_acct_id        ce_bank_accounts.bank_account_id%TYPE;
  l_temp_cr_hist_id      NUMBER;
  l_cash_receipt_hist_id NUMBER;
  l_federal_rpt_id       Fv_Report_Definitions.federal_rpt_id%TYPE;
  l_rowid                VARCHAR2(25);
  l_vendor_id            AP_INVOICES.VENDOR_ID%TYPE;
  l_INVOICE_ID           AP_INVOICES.invoice_ID%TYPE;
  l_inv_amount           NUMBER;
  l_check_date           DATE;
  l_payables_ia_paygroup FV_system_parameters_v.payables_ia_paygroup%type;

  -- References invoice_id populated by treasury confirmation procedure
  L_REFERENCE_4       FV_SF224_TEMP.REFERENCE_4%TYPE ;
  L_REFERENCE_5       FV_SF224_TEMP.REFERENCE_5%TYPE ;
  L_REFERENCE_6       FV_SF224_TEMP.REFERENCE_6%TYPE ;

  l_fund_code         VARCHAR2(25);
  l_error_stage       NUMBER;
  l_processed_flag    VARCHAR2(1);
  l_cb_flag           VARCHAR2(1);
  l_cash_receipt_id   NUMBER;
  l_dummy             VARCHAR2(1);
  l_invoice_date      DATE;
  l_update_type       VARCHAR2(25);
  l_org_id            NUMBER(15);
  x_amount            NUMBER;
  l_void_date         DATE;

  l_business_activity_code fv_alc_addresses_all.business_activity_code%TYPE;
  l_gwa_reporter_category_code fv_alc_gwa_categories.gwa_reporter_category_code%TYPE;
  l_alc_addresses_id fv_alc_addresses_all.fv_alc_addresses_id%TYPE;

  --Added for reclassification changes
  l_void_check_number             ap_checks_all.void_check_number%TYPE;
  l_voided_reclassified_payment   VARCHAR2(1);
  l_reclass_receipt_number        ar_cash_receipts_all.receipt_number%TYPE;
  l_receipt_reclassified          VARCHAR2(1);
  l_ar_reclass_attribute          VARCHAR2(15);
  sql_stmt                        VARCHAR2(500);
  sql_stmt1                       VARCHAR2(500);
  l_reclass                       VARCHAR2(1) :='N';

  l_invoice_type_lookup_code      VARCHAR2(25);
  l_payment_type_flag             VARCHAR2(25);
  l_check_void_date               DATE;

  CURSOR C1
  (
    c_set_of_books_id NUMBER
  )IS
  SELECT rowid,
         je_batch_id,
         fund_code,
         sf224_type_code,
         name,
         amount,
         actual_amount,
         d_r_flag,
         accomplish_date,
         reference_1,
         reference_2,
         reference_3,
         reference_4,
         reference_5,
         reference_6,
         reference_8,
         reference_9,
         je_line_num,
         je_header_id,
         reported_flag,
         exception_exists,
         record_category,
         gl_period,
         exception_category,
         exception_section,
         reported_month,
         column_group,
         record_type,
         inter_agency_flag,
         obligation_date,
         treasury_symbol,
         treasury_symbol_id,
         federal_rpt_id,
         txn_category,
         je_source,
         je_category,
         je_from_sla_flag
    FROM fv_sf224_temp
   WHERE set_of_books_id = c_set_of_books_id
     AND sf224_processed_flag = 'N';

    CURSOR C2
    (
      c_cash_receipt_id NUMBER,
      c_fund_code     VARCHAR2
    ) IS
    SELECT obligation_date,
           refund_amount
      FROM fv_refunds_voids_all
     WHERE cash_receipt_id = c_cash_receipt_id
       AND type = 'AP_REFUND'
       AND fund_value = c_fund_code;

    CURSOR get_count_csr
    (
      c_batch_id NUMBER,
      c_je_header_id NUMBER,
      c_je_category VARCHAR2,
      c_cash_receipt_id NUMBER,
      c_fund_code VARCHAR2,
      c_je_from_sla_flag VARCHAR2
    )
    IS
    SELECT COUNT(*)
    FROM fv_sf224_temp
    WHERE je_batch_id = c_batch_id
      AND je_header_id = c_je_header_id
      AND DECODE(c_je_from_sla_flag, 'Y', reference_2, DECODE(c_je_category,'Misc Receipts',reference_2, SUBSTR(reference_2,0,INSTR(reference_2,'C')-1)))
          = TO_CHAR(c_cash_receipt_id)
      AND fund_code = c_fund_code
      AND name = 'Refunds_and_Voids'
      AND record_category = 'CREATED'
      AND record_type = 'Receipt_refund';

  BEGIN
   l_module_name := g_module_name || 'Process_sf224_transactions';
   l_exists := 'N' ;
   vl_misc_cd_flag     := 'N';
   error_code := g_SUCCESS;
   OPEN C1 (sob);
   IF(sqlcode < 0) THEN
        error_code := sqlcode;
        error_buf  := sqlerrm;
        RETURN;
   END IF;

   p_def_org_id  := mo_global.get_current_org_id;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Deriving PAYGROUP  for org id '|| p_def_org_id);
   END IF;

    -- Determine the default paygroup based on the org_id
    BEGIN
      SELECT payables_ia_paygroup
      INTO   p_def_p_ia_paygroup
      FROM   FV_Operating_units_all
      WHERE  org_id = p_def_org_id;
    EXCEPTION
      WHEN No_Data_Found THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PAYABLES IA PAYGROUP NOT FOUND,BASED ON THE ORG_ID '
                        ||TO_CHAR(p_def_org_id));
        END IF;
        NULL;
      WHEN OTHERS THEN
        error_code := g_FAILURE;
        error_buf :=SQLERRM || '-- Error in Process_Sf224_Transactions procedure '||
                        'while determining the payables ia paygroup.';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error2', error_buf) ;
    END;

    --Determine the attribute column used in AR Reclass Receipt DFF
    BEGIN
      SELECT AR_RECLASS_ATTRIBUTE
 	  INTO   l_ar_reclass_attribute
 	  FROM   fv_system_parameters;
 	EXCEPTION
 	  WHEN NO_DATA_FOUND THEN
 	    l_ar_reclass_attribute:=NULL;
 	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Receivables Reclassification Field' ||
 	               ' has not set in Define Federal System Parameters Form');
 	    END IF;
 	END;

    /* ----- Populating the C1 Cursor    ------------*/
    LOOP
      FETCH C1  INTO
            l_rowid,
            l_batch_id,
            l_fund_code,
            l_sf224_type_code,
            l_name,
            l_amount,
            l_org_amount,
            l_d_r_flag,
            l_accomplish_date,
            l_reference_1,
            l_reference_2,
            l_reference_3,
            l_reference_4,
            l_reference_5,
            l_reference_6,
            l_reference_8,
            l_reference_9,
            l_je_line_num,
            l_je_header_id,
            l_reported_flag,
            l_exception_exists,
            l_record_category,
            l_gl_period,
            l_exception_category,
            l_exception_section,
            l_reported_month,
            l_column_group,
            l_record_type,
            l_ia_flag,
            l_obligation_date,
            l_treasury_symbol,
            l_treasury_symbol_id,
            l_federal_rpt_id,
            l_txn_category,
            l_je_source,
            l_je_category,
            l_je_from_sla_flag;

        IF (C1%NOTFOUND) THEN
            EXIT;
        END IF;

        IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'---------------------------------');
        END IF;
        -- Determine the default alc
        BEGIN
          SELECT agency_location_code
          INTO p_def_alc_code
          FROM Fv_Report_Definitions
          WHERE federal_rpt_id = l_federal_rpt_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            error_buf := 'The default agency_location_code could not be determined
                           -- Error in Process_Sf224_Transactions procedure.';
            error_code := g_FAILURE;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error3', error_buf) ;
            RETURN;
          WHEN OTHERS THEN
            error_buf := SQLERRM||'-- Error in Process_Sf224_Transactions procedure.';
            error_code := g_FAILURE;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error4', error_buf) ;
            RETURN;
        END;
        IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'DEFAULT ALC IS '||P_DEF_ALC_CODE);
        END IF;
        --Fetch the end date for the period in which txn was entered
        BEGIN
          SELECT   start_date,
                   end_date
          INTO     l_txn_start_date,
                   l_txn_end_date
          FROM     gl_period_statuses glp
          WHERE    glp.period_name   = l_gl_period
          AND      glp.ledger_id  = sob
          AND      glp.application_id = 101;
        EXCEPTION WHEN OTHERS THEN
          error_code := 2;
          error_buf := substr(sqlerrm,1,50) || ' while fetching txn end date';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error5', error_buf) ;
        END;

        IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'END DATE OF THE TRANSACTION PERIOD '||
                               to_char(l_txn_end_date, 'MM/DD/YYYY'));
        END IF;


        -----------------------------------------------------------------------
        --   Initializing variables
        -----------------------------------------------------------------------

        IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PROCESSING TXN WITH SOURCE ='||
                            L_JE_SOURCE||',Category='||l_je_category||',Batch='||l_name||
                            ',Header='||l_je_header_id||',Line='||l_je_line_num );
        END IF;
        l_processed_flag := 'N';
        l_exception_category := NULL;
        l_exception_section := -1;
        l_billing_agency_fund := NULL;
        l_ia_flag     := 'N';
        l_txn_category := NULL;
        l_sign_number := 1;
        l_accomplish_date := NULL;
        l_alc_code := p_def_alc_code;
        l_type := NULL;
        l_update_type := NULL;
        x_amount   :=   ABS(l_amount);
        x_name := 'MANUAL';

        l_void_check_number :=NULL;
        l_voided_reclassified_payment:='N';
        l_reclass_receipt_number :=NULL;
        l_receipt_reclassified :='N';
        sql_stmt:=NULL;
        sql_stmt1:=NULL;
        -----------------------------------------------------------
        --  Assign the transaction type according to Batch Name
        ------------------------------------------------------------
        l_document_number := NULL;

        IF (l_je_category = 'Treasury Confirmation' AND
            ((NVL(l_je_from_sla_flag,'N') IN ('N', 'U') AND upper(l_name) like '%TREASURY%')  OR
             (NVL(l_je_from_sla_flag,'N')='Y' AND upper(l_name) like '%BUDGET EXECUTION%')))  then -- source1
                -- get the document number

                BEGIN
                    SELECT checkrun_name
                    INTO   l_document_number
                    FROM   ap_checks_all
                    WHERE  check_id = TO_NUMBER(l_reference_3);
                 EXCEPTION WHEN NO_DATA_FOUND THEN
                    SELECT SUBSTR(name,1,50)
                    INTO   l_document_number
                    FROM   gl_je_headers
                    WHERE  je_header_id = l_je_header_id;
                END;
            IF l_reference_1 IS NULL AND l_reference_6 IS NULL Then   -- ref1
                x_name := 'Blank Treasury confirmation Id' ;
                Set_Exception('R');
            ELSIF l_reference_1 IS NOT NULL THEN                -- ref1
                BEGIN
                    select 'Y'
                    into   l_exists
                    from   Fv_treasury_confirmations_all
                    Where  treasury_confirmation_id = to_number(l_REFERENCE_1) ;
                EXCEPTION
                    When no_data_found then
                        x_name := 'Invalid Treasury Confirmation Id - '
                                         || l_reference_1 ;
                        Set_Exception('R');
                    When INVALID_NUMBER OR VALUE_ERROR Then
                        x_name := 'Error while converting to number - '
                                        || l_reference_1 ;
                        Set_Exception('R');
                END ;
            END IF;                                                -- ref1
        ELSIF (l_je_source = 'Project Accounting') AND (l_je_category ='Labor Cost') THEN     -- source1
          IF l_accomplish_attribute IS NOT NULL THEN
            IF NVL(l_je_from_sla_flag, 'N') IN ('N','U') THEN
              IF l_reference_1 IS NULL THEN
                 -- PA batch name is null then process as Manual.
                 x_name :='Blank Project Accting Batch Name';
                 Set_Exception('R');
              ELSE
                 BEGIN
                    --go find accomplish date in PA
                    l_select := 'select pei.'||l_accomplish_attribute||
                        ',pei.org_id from pa_cost_distribution_lines_all pcdl,
                         pa_expenditure_items_all pei
                         where pcdl.batch_name =:b_reference_1
                         and pcdl.expenditure_item_id = pei.expenditure_item_id';
                    COMMIT;
                      -- Get document number
                   SELECT SUBSTR(name,1,50)
                   INTO   l_document_number
                   FROM   gl_je_headers
                   WHERE  je_header_id = l_je_header_id;
                   l_cursor_id := dbms_sql.open_cursor;
                   dbms_sql.parse(l_cursor_id, l_select, dbms_sql.v7);
                   dbms_sql.bind_variable(l_cursor_id,':b_reference_1',l_reference_1);
                   dbms_sql.define_column(l_cursor_id, 1, l_accomplish_date);
                   dbms_sql.define_column(l_cursor_id, 2, l_org_id);
                   l_ignore := dbms_sql.execute(l_cursor_id);
                   l_ignore := dbms_sql.fetch_rows(l_cursor_id);
                   IF (l_ignore > 0) THEN
                      dbms_sql.column_value(l_cursor_id, 1, l_accomplish_date);
                      dbms_sql.column_value(l_cursor_id, 2, l_org_id);
                      IF l_accomplish_date IS NULL THEN
                         -- create an exception
                         l_reported_flag :='Y';
                         l_exception_exists :='Y' ;
                         l_record_category :='EXCEPTION';
                         l_exception_category :='NO_PA_ACCOMPLISH_DATE';
                         l_exception_section := 7;
                         l_alc_code := p_def_alc_code;
                         l_accomplish_date := l_txn_end_date ;
                         Insert_new_transaction(l_amount, 1);
                      END IF;
                   ELSE
                      x_name := 'No Project Accting Batch Name Found';
                      Set_Exception('R');
                   END IF;
                 EXCEPTION
                     WHEN others THEN
                        error_buf :='PA Accomplish Date Error'||sqlerrm;
                        error_code := g_FAILURE;
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error7', error_buf) ;
                        RETURN;
                 END;
              END IF;
            ELSE  --l_je_from_sla_flag
              IF l_reference_1 IS NOT NULL THEN
                 -- PA Expenditure Type Id is null.
                 x_name :='Blank Project Expenditure Type Id';
                 Set_Exception('R');
              ELSE
                BEGIN
                  --go find accomplish date in PA
                  l_select := 'select pei.'||l_accomplish_attribute||
                        ',pei.org_id from pa_cost_distribution_lines_all pcdl,
                         pa_expenditure_items_all pei
                         where pcdl.expenditure_item_id =:b_reference_1
                         and pcdl.expenditure_item_id = pei.expenditure_item_id';
                  COMMIT;
                      -- Get document number
                   SELECT SUBSTR(name,1,50)
                   INTO   l_document_number
                   FROM   gl_je_headers
                   WHERE  je_header_id = l_je_header_id;
                   l_cursor_id := dbms_sql.open_cursor;
                   dbms_sql.parse(l_cursor_id, l_select, dbms_sql.v7);
                   dbms_sql.bind_variable(l_cursor_id,':b_reference_1',l_reference_1);
                   dbms_sql.define_column(l_cursor_id, 1, l_accomplish_date);
                   dbms_sql.define_column(l_cursor_id, 2, l_org_id);
                   l_ignore := dbms_sql.execute(l_cursor_id);
                   l_ignore := dbms_sql.fetch_rows(l_cursor_id);
                   IF (l_ignore > 0) THEN
                      dbms_sql.column_value(l_cursor_id, 1, l_accomplish_date);
                      dbms_sql.column_value(l_cursor_id, 2, l_org_id);
                      IF l_accomplish_date IS NULL THEN
                         -- create an exception
                            l_reported_flag :='Y';
                            l_exception_exists :='Y' ;
                            l_record_category :='EXCEPTION';
                            l_exception_category :='NO_PA_ACCOMPLISH_DATE';
                            l_exception_section := 7;
                            l_alc_code := p_def_alc_code;
                            l_accomplish_date := l_txn_end_date ;
                            Insert_new_transaction(l_amount, 1);
                      END IF;
                   ELSE
                      x_name := 'No Project Accting Batch Name Found';
                      Set_Exception('R');
                   END IF;
                EXCEPTION
                   WHEN others THEN
                      error_buf :='PA Accomplish Date Error'||sqlerrm;
                      error_code := g_FAILURE;
                      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error7', error_buf) ;
                      RETURN;
                END;
              END IF;
            END IF;
          ELSE  -- accomplish date attribute in fv_system_parameters is null.
            l_accomplish_date := l_txn_end_date;
          END IF;
          l_record_type := 'Disbursement';
        ELSIF (l_je_source =  'Payables' AND l_je_category <>  'Treasury Confirmation') Then      -- source1
          -- get the document number
          BEGIN
            SELECT invoice_num
            INTO   l_document_number
            FROM   ap_invoices_all
            WHERE  invoice_id = TO_NUMBER(l_reference_2);
          EXCEPTION WHEN NO_DATA_FOUND THEN
            SELECT SUBSTR(name,1,50)
            INTO   l_document_number
            FROM   gl_je_headers
            WHERE  je_header_id = l_je_header_id;
          END;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Document_Num => ' || l_document_number);
 	      END IF;
          IF l_reference_2 IS NULL Then
             x_name          := 'Blank Invoice Id' ;
             Set_Exception('R');
          ELSE
            BEGIN
              SELECT  'Y',  invoice_type_lookup_code
              INTO    l_exists, g_invoice_type_lookup_code
              FROM    ap_invoices_all
              WHERE   invoice_id  = to_number(l_REFERENCE_2) ;
           EXCEPTION
              when no_data_found then
                   x_name := 'Invalid Invoice Id - ' || l_reference_2 ;
                   Set_Exception('R');
              When INVALID_NUMBER OR VALUE_ERROR Then
                   x_name := 'Error while converting to number - '
                              || l_reference_2 ;
                   Set_Exception('R');
           END;
         END IF;
         IF l_reference_3 IS NULL Then
             x_name := 'Blank Check Id' ;
             Set_Exception('R');
         ELSE
           BEGIN
             select 'Y',      payment_type_flag,   void_date
             into   l_exists, g_payment_type_flag, g_check_void_date
             from   ap_checks_all
             Where  check_id  = to_number(l_REFERENCE_3) ;
           EXCEPTION
              when no_data_found then
                   x_name  := 'Invalid Check Id - ' || l_reference_3 ;
                   Set_Exception('R');
              When INVALID_NUMBER OR VALUE_ERROR Then
                   x_name := 'Error while converting to number - '
                                  || l_reference_3 ;
                   Set_Exception('R');
           END;
         END IF;
         IF l_reference_9 IS NULL Then
            x_name               := 'Blank Invoice Payment Id' ;
            Set_Exception('R');
         ELSE
           BEGIN
             select 'Y'
             into   l_exists
             from   ap_invoice_payments_all
             Where  invoice_payment_id  = to_number(l_REFERENCE_9) ;
           EXCEPTION
             when no_data_found then
                  x_name := 'Invalid Invoice Payment Id - '|| l_reference_9 ;
                  Set_Exception('R');
             When INVALID_NUMBER OR VALUE_ERROR Then
                  x_name := 'Error while converting to number - '|| l_reference_9 ;
                  Set_Exception('R');
           END;
         END IF;

        ELSIF (l_je_source =  'Receivables') THEN                -- source1
           vl_misc_cd_flag := 'N';
           IF (NVL(l_je_from_sla_flag,'N') IN ('N', 'U')) THEN
               IF (l_je_category = 'Misc Receipts') THEN             -- rec category
                   IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PROCESSING A MISC RECEIPT');
                   END IF;
                   l_cash_receipt_id := l_reference_2;
                   l_cash_receipt_hist_id := l_reference_5;
               ELSE                                                  -- rec category
                   IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PROCESSING A TRADE RECEIPT OR OTHER');
                   END IF;
                   -- get the cash receipt id, and the cash receipt history id
                   l_cash_receipt_id := SUBSTR(l_reference_2,0,INSTR(l_reference_2,'C')-1);
                   l_cash_receipt_hist_id := SUBSTR(l_reference_2,INSTR(l_reference_2,'C')+1,LENGTH(l_reference_2));
               END IF;
           ELSE --l_je_from_sla_flag is 'Y'
               IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PROCESSING RECEIPT WHEN SOURCE IS SLA');
               END IF;
               l_cash_receipt_id := l_reference_2;
               l_cash_receipt_hist_id := l_reference_5;
           END IF;
           IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CASH RECEIPT ID = '
                        ||TO_NUMBER(l_cash_receipt_id));
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CASH RECEIPT HISTORY ID = '
                        ||TO_NUMBER(l_cash_receipt_hist_id));
           END IF;
           IF ((l_cash_receipt_id IS NULL) OR (l_cash_receipt_hist_id IS NULL)) THEN
              x_name := 'Blank Cash Receipt Id ' ;
              Set_Exception('R');
           ELSIF (l_cash_receipt_id IS NOT NULL) THEN
              BEGIN
                SELECT 'Y'
                INTO   l_exists
                FROM   Ar_Cash_Receipts_All
                WHERE  cash_receipt_id =  to_number(l_cash_receipt_id);
                IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CASH RECEIPT ID EXISTS');
                END IF;
              EXCEPTION
                WHEN no_data_found THEN
                   x_name := 'Invalid Cash Receipt Id - '||TO_NUMBER(l_cash_receipt_id) ;
                   Set_Exception('R');
                WHEN INVALID_NUMBER OR VALUE_ERROR  THEN
                   x_name := 'Error while converting to number - '|| TO_NUMBER(l_cash_receipt_id) ;
                   Set_Exception('R');
              END;
              BEGIN
                SELECT 'Y'
                INTO   l_exists
                FROM   Ar_Cash_Receipt_History_All
                WHERE  cash_receipt_history_id = to_number(l_cash_receipt_hist_id)
                   AND cash_receipt_id = TO_NUMBER(l_cash_receipt_id);
                IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CASH RECEIPT HIST ID EXISTS IN '||
                                'Ar_Cash_Receipt_History_All.');
                END IF;
              EXCEPTION
                WHEN no_data_found THEN
                  IF(l_je_category = 'Misc Receipts') THEN
                    IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FOR MISC RECEIPT: '||
                                'Cash Receipt Hist Id does not '||
                                'exist in Ar_Cash_Receipt_History_All table.'||
                                'Checking in Ar_Misc_Cash_Distributions_All table.');
                    END IF;
                    l_exists := 'M';
                  ELSE
                    IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FOR TRADE RECEIPT: '||
                                'Cash Receipt Hist Id does not '||
                                'exist in Ar_Cash_Receipt_History_All table.'||
                                'Checking in Ar_Receivable_Applications_All table.');
                    END IF;
                    l_exists := 'C';
                  END IF;
                WHEN INVALID_NUMBER OR VALUE_ERROR  Then
                     x_name := 'Error while converting to number - '
                                      || TO_NUMBER(l_cash_receipt_hist_id) ;
                     Set_Exception('R');
              END;
              IF((l_je_category <> 'Misc Receipts') AND (l_exists = 'C')) THEN
                BEGIN
                  SELECT cash_receipt_history_id
                  INTO   l_temp_cr_hist_id
                  FROM   Ar_Receivable_Applications_All
                  WHERE  receivable_application_id = TO_NUMBER(l_cash_receipt_hist_id);
                  l_cash_receipt_hist_id := l_temp_cr_hist_id;
                  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CASH RECEIPT HIST ID EXISTS IN '||
                            'Ar_Receivable_Applications_All table and is '||
                             TO_NUMBER(l_cash_receipt_hist_id)||'.Checking in '||
                            'Ar_Cash_Receipt_History_All to see if it is a valid '||
                            'cash receipt hist id.');
                  END IF;
                  BEGIN
                    SELECT 'Y'
                    INTO l_exists
                    FROM Ar_Cash_Receipt_History_All
                    WHERE cash_receipt_history_id = TO_NUMBER(l_cash_receipt_hist_id)
                      AND cash_receipt_id = TO_NUMBER(l_cash_receipt_id);
                    IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CASH RECEIPT HIST ID EXISTS IN '||
                              'the Ar_Cash_Receipt_History_All table.');
                    END IF;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      x_name := 'Invalid Cash Receipt History Id - '
                                        || TO_NUMBER(l_cash_receipt_hist_id) ;
                      Set_Exception('R');
                    WHEN INVALID_NUMBER OR VALUE_ERROR  Then
                      x_name := 'Error while converting to number - '
                                        || TO_NUMBER(l_cash_receipt_hist_id) ;
                      Set_Exception('R');
                  END;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    x_name := 'Invalid Cash Receipt History Id - '
                                        || TO_NUMBER(l_cash_receipt_hist_id) ;
                    Set_Exception('R');
                  WHEN INVALID_NUMBER OR VALUE_ERROR  Then
                    x_name := 'Error while converting to number - '
                                        || TO_NUMBER(l_cash_receipt_hist_id) ;
                    Set_Exception('R');
                END;
              ELSIF  ((l_je_category = 'Misc Receipts') AND (l_exists = 'M')) THEN
                BEGIN
                  SELECT 'Y'
                  INTO l_exists
                  FROM Ar_Misc_Cash_Distributions_All
                  WHERE misc_cash_distribution_id = TO_NUMBER(l_cash_receipt_hist_id)
                    AND cash_receipt_id = TO_NUMBER(l_cash_receipt_id);
                  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'MISC CASH DISTRIBUTION ID EXISTS IN '||
                            'Ar_Misc_Cash_Distributions_All table and is '|| TO_NUMBER(l_cash_receipt_hist_id));
                  END IF;
                  vl_misc_cd_flag := 'Y';
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    x_name := 'Invalid Misc Cash Distribution Id - '|| TO_NUMBER(l_cash_receipt_hist_id) ;
                    Set_Exception('R');
                  WHEN INVALID_NUMBER OR VALUE_ERROR  Then
                    x_name := 'Error while converting to number - '|| TO_NUMBER(l_cash_receipt_hist_id) ;
                    Set_Exception('R');
                END;
             END IF;  --l_je_category and l_exists
           END IF ;   --l_cash_receipt_id is not null
           -- get the document number
           BEGIN
             SELECT receipt_number
             INTO   l_document_number
             FROM   ar_cash_receipts_all
             WHERE  cash_receipt_id = TO_NUMBER(l_cash_receipt_id);
           EXCEPTION WHEN NO_DATA_FOUND THEN
             SELECT SUBSTR(name,1,50)
             INTO   l_document_number
             FROM   gl_je_headers
             WHERE  je_header_id = l_je_header_id;
           END;

        ELSIF(l_je_category = 'Treasury Confirmation' AND
             l_name LIKE '%VOID%') THEN                          -- source1
                -- get the document number
          BEGIN
            SELECT checkrun_name
            INTO   l_document_number
            FROM   ap_checks_all
            WHERE  check_id = to_number(l_reference_3);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              SELECT SUBSTR(name,1,50)
              INTO   l_document_number
              FROM   gl_je_headers
              WHERE  je_header_id = l_je_header_id;
          END;
          IF l_reference_3 IS NULL then
             x_name          := 'Blank Check Id ' ;
             Set_Exception('R');
          ELSE
            BEGIN
              select 'Y'
              into   l_exists
              from   AP_CHECKS_ALL
              Where  check_id =  to_number(l_reference_3);
            Exception
              when no_data_found then
                x_name := 'Invalid Check Id - ' || l_reference_3 ;
                Set_Exception('R');
              When INVALID_NUMBER OR VALUE_ERROR Then
                x_name := 'Error while converting to number - '|| l_reference_3 ;
                Set_Exception('R');
            End ;
          End If ;
          If l_reference_4 IS NULL then
              x_name          := 'Blank Invoice Id' ;
              Set_Exception('R');
          Else
              Begin
                select 'Y'
                into   l_exists
                from   AP_INVOICES_ALL
                Where  invoice_id =  to_number(l_reference_4);
              Exception
                when no_data_found then
                  x_name := 'Invalid Invoice Id - ' || l_reference_4 ;
                  Set_Exception('R');
                When INVALID_NUMBER OR VALUE_ERROR Then
                  x_name := 'Error while converting to number - '|| l_reference_4 ;
                  Set_Exception('R');
              End ;
          End If ;
        ELSE                                                        -- source1
          -- In case of Manual Transaction, the alc_code will be the default alc.
          x_name := l_name;
          l_name := 'MANUAL';
          SELECT SUBSTR(name,1,50)
          INTO   l_document_number
          FROM   gl_je_headers
          WHERE  je_header_id = l_je_header_id;
        END IF;                                                -- source1

 ---------------------------------------------------------------------------
 --   Re-assign the batch name.  All batches start as MANUAL
 --    THEN get overwritten.
 ---------------------------------------------------------------------------
         x_name := l_name;
         -- Initialising the bank_acct_id
         vg_bank_acct_id := NULL;
         IF (x_name <> 'MANUAL') THEN                     -- manual
             IF (l_je_source  =  'Receivables' ) THEN      -- source2
                l_exists := 'N';
                IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                    'GETTING THE ACCOMPLISH DATE FOR RECEIPTS');
                END IF;
                -- Check IF the cash receipt is a reversal
                IF ((l_je_category = 'Misc Receipts') AND (vl_misc_cd_flag = 'Y')) THEN        -- rev check
                   BEGIN
                     SELECT 'Y'
                     INTO l_exists
                     FROM Ar_Misc_Cash_Distributions_All
                     WHERE misc_cash_distribution_id = l_cash_receipt_hist_id
                       AND cash_receipt_id = l_cash_receipt_id
                       AND created_from = 'ARP_REVERSE_RECEIPT.REVERSE';
                     IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'MISC CASH DIST ID HAS REVERSE VALUE IN '||'created from column....it is a reversal');
                     END IF;
                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                       l_exists := 'N';
                     WHEN OTHERS THEN
                       error_buf := SQLERRM||'- Error while deriving the reversal status'
                                           ||' for the misc cash dist id '||l_cash_receipt_hist_id;
                       error_code := 2;
                       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error10', error_buf) ;
                       RETURN;
                   END;
                ELSE                                                 -- rev check
                   BEGIN
                     SELECT 'Y'
                     INTO l_exists
                     FROM Ar_Cash_Receipt_History_All
                     WHERE cash_receipt_history_id = l_cash_receipt_hist_id
                       AND cash_receipt_id = l_cash_receipt_id
                       AND status='REVERSED';
                     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                 'REVERSAL CASH RECEIPT HIST ID EXISTS..it is a reversal');
                     END IF;
                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                       l_exists := 'N';
                     WHEN OTHERS THEN
                       error_buf := SQLERRM||'- Error while deriving the status'
                                   ||' for the cash receipt hist id '||l_cash_receipt_hist_id;
                      error_code := 2;
                      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error11', error_buf) ;
                      RETURN;
                   END;
                END IF;                                                -- rev check
                BEGIN
                   SELECT DECODE(l_exists,'Y',reversal_date,receipt_date)
                   INTO   l_accomplish_date
                   FROM   ar_cash_receipts_all
                   WHERE  cash_receipt_id = l_cash_receipt_id;
                EXCEPTION
                   WHEN OTHERS THEN
                     error_buf := SQLERRM|| '- Error while deriving the accomplish date'
                                         ||' for the cash receipt id '||l_cash_receipt_id;
                     error_code := 1 ;
                     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error12', error_buf) ;
                     RETURN;
                END;
                IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                              'ACCOMPLISH DATE IS '||TO_CHAR(L_ACCOMPLISH_DATE, 'MM/DD/YYYY'));
                END IF;
                BEGIN
                   SELECT remit_bank_acct_use_id
                   INTO vg_bank_acct_id
                   FROM Ar_Cash_Receipts_All
                   WHERE cash_receipt_id = TO_NUMBER(l_cash_receipt_id);
                   IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FOUND THE BANK ACCOUNT ID');
                   END IF;
                  -- Get the agency location code
                  Get_Alc
                  (
                   p_bank_acct_id    => vg_bank_acct_id,
                   p_alc_code        => l_alc_code,
                   p_error_code      => error_code,
                   p_error_desc      => error_buf
                  );
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    -- Unable to find the remittance_bank_account_id
                    IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                             'UNABLE TO FIND THE BANK ACCT ID');
                    END IF;
                    Set_Exception('D');
                  WHEN OTHERS THEN
                    error_buf := SQLERRM||'- Error while deriving the agency_location_code'
                                        ||' for the cash receipt id '||l_cash_receipt_id;
                    error_code := 2;
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error13', error_buf) ;
                    RETURN;
                END;
                --- Check for Interagency funds
                l_ia_flag     := 'N';
                l_record_type := 'Receipt';
                BEGIN  /* B1 */
                    SELECT 'x'
                    INTO  l_dummy
                    FROM  fv_interagency_funds_all
                    WHERE cash_receipt_id = l_cash_receipt_id;
                    l_ia_flag := 'Y';
                    l_update_type    := 'RECEIPT';
                EXCEPTION
                    WHEN no_data_found THEN
                        l_ia_flag := 'N';
                    WHEN too_many_rows THEN
                        error_buf := 'Too many rows in interagency select';
                        error_code := g_FAILURE;
                        RETURN;
                END ; /* B1 */
                IF (l_ia_flag = 'N' AND l_ar_reclass_attribute IS NOT NULL
                    AND l_cash_receipt_id IS NOT NULL) THEN
                  BEGIN
                     sql_stmt1:= 'SELECT ACR.' || l_ar_reclass_attribute ||
                                 ' FROM  AR_CASH_RECEIPTS_ALL ACR WHERE ACR.cash_receipt_id = '
                                 || l_cash_receipt_id;
                     l_reclass_receipt_number := NULL;
                     EXECUTE IMMEDIATE sql_stmt1 INTO l_reclass_receipt_number ;
                     IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                              'Reclass Receipt Number: '|| l_reclass_receipt_number );
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                       l_reclass_receipt_number:=NULL;
                  END;
                  IF (l_reclass_receipt_number IS NOT NULL) THEN
                     BEGIN  /* B1 */
                       SELECT 'x'
                       INTO l_dummy
                       FROM fv_interagency_funds_all a
                       WHERE cash_receipt_id = (SELECT cash_receipt_id
                                                FROM ar_cash_receipts b
                                                WHERE  b.receipt_number = l_reclass_receipt_number);
                       l_ia_flag := 'Y';
                       l_txn_category := 'I';
                       l_update_type    := 'RECEIPT';
                     EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          l_ia_flag := 'N';
                       WHEN TOO_MANY_ROWS THEN
                          error_buf := 'Too many rows in interagency select';
                          error_code := -1;
                          RETURN;
                     END ; /* B1 */
                  END IF;
                END IF;
                -- Check for Refunded invoice
                --begin /* Receivable Refund */
                OPEN C2 (l_cash_receipt_id, l_fund_code);
                IF (sqlcode < 0) THEN
                    error_code := sqlcode ;
                    error_buf  := sqlerrm ;
                    RETURN ;
                END IF;
                LOOP
                    FETCH C2
                    INTO  l_obligation_date,
                          l_inv_amount ;
                    EXIT WHEN C2%NOTFOUND;
                    vl_refund_cnt := 0;
                    IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                             'BATCH_ID,HEADER_ID,FUND,REF2 ='||L_BATCH_ID||','||
                                              l_je_header_id||','||l_fund_code||','||l_reference_2);
                    END IF;
                    OPEN Get_Count_Csr
                    (
                     l_batch_id,
                     l_je_header_id,
                     l_je_category,
                     l_cash_receipt_id,
                     l_fund_code,
                     l_je_from_sla_flag
                    );
                    FETCH Get_Count_Csr INTO vl_refund_cnt;
                    CLOSE Get_Count_Csr;
                    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                        'THE # OF RECORDS IN FV_SF224_TEMP '||VL_REFUND_CNT);
                    END IF;
                    IF (vl_refund_cnt = 0) THEN
                        l_record_type := 'Receipt_refund';
                        IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                    'RECORD_TYPE AFTER REFUNDS CHECK IS '||L_RECORD_TYPE);
                        END IF;
                        l_type := 'AP_REFUND';
                        l_update_type := 'RECEIPT';
                        l_processed_flag := 'Y';
                        --l_record_type := 'Receipt_refund';
                        x_name := 'Refunds_and_Voids';
                        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                  'BEFORE SET_TRANSACTION_TYPE');
                        END IF;
                        set_transaction_type;
                        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                 'AFTER SET_TRANSACTION_TYPE');
                        END IF;
                        -- Added for WAPA bug fix.
                        -- Bug 1013752
                        l_reported_flag  := 'N';
                        IF(l_reported_month like 'CURRENT%') THEN
                           l_reported_flag     := 'Y' ;
                        END IF;
                        l_exception_exists  := NULL ;
                        l_record_category   := 'CREATED' ;
                        l_billing_agency_fund := l_fund_code;
                        --  Insert the exception transaction
                        insert_new_transaction (l_inv_amount, l_sign_number);
                        l_org_amount := l_org_amount - l_inv_amount;
                    ELSE
                        l_record_type := 'Receipt';
                    END IF;
                END LOOP;
                CLOSE C2;
                IF l_processed_flag = 'Y' THEN
                   l_amount := l_org_amount;
                END IF;
                l_record_type := 'Receipt';
             ELSIF (l_je_category = 'Treasury Confirmation' AND
            ((NVL(l_je_from_sla_flag,'N') IN ('N', 'U') AND upper(l_name) like '%TREASURY%')  OR
             (NVL(l_je_from_sla_flag,'N')='Y' AND upper(l_name) like '%BUDGET EXECUTION%')))  then -- source2

                IF l_reference_1 IS NULL THEN                                -- ref1
                   -- IF the code is executing this IF stmnt, it means that ref6
                   -- is not null. IF ref1 is null and ref6 is null, it would have
                   -- been a Manual entry which is taken care of in the first IF stmnt.
                   -- Hence accomplish date would be ref6.
                   l_accomplish_date := l_reference_6;
                   IF l_reference_3 IS NULL THEN                        -- ref3-0
                      -- Case when ref1 is null, ref3 is null and ref6 is not null
                      IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                               'CASE:REF1,REF3 ARE NULL; REF6 IS NOT NULL');
                      END IF;
                      Set_Exception('D');
                      GOTO end_label;
                   ELSE                                                -- ref3-0
                      -- Case when ref1 is null,ref3 and ref6 are not null
                      IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                              'CASE:REF1 IS NULL, REF3 AND REF6 ARE NOT NULL');
                      END IF;
                      BEGIN
                        SELECT ce_bank_acct_use_id
                        INTO vg_bank_acct_id
                        FROM Ap_Checks_All
                        WHERE check_id = TO_NUMBER(l_reference_3);
                        IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FOUND THE BANK ACCOUNT ID');
                        END IF;
                      EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                          IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                  'UNABLE TO FIND THE BANK ACCOUNT ID');
                          END IF;
                          -- Unable to find the bank_account_id
                          Set_Exception('D');
                          GOTO end_label;
                        WHEN OTHERS THEN
                          error_buf := SQLERRM||'- Error while deriving the '||
                                       'bank_account_id from Ap_Checks_All table.';
                          error_code := 2;
                          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error14', error_buf) ;
                          RETURN;
                      END;
                   END IF;                                                -- ref3-0
                ELSE                                                         -- ref1
                   -- Case when ref1 is not null
                   IF l_reference_3 IS NULL THEN                        -- ref3
                      IF l_reference_6 IS NULL THEN                        -- ref6-1
                         -- Case when ref1 is not null,ref3 and ref6 are null
                         IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                  'CASE:REF1 IS NOT NULL;REF3 AND REF6 ARE NULL');
                         END IF;
                         BEGIN
                           SELECT checkrun_name,treasury_doc_date,org_id
                           INTO   vl_checkrun_name, l_accomplish_date, l_org_id
                           FROM   Fv_Treasury_Confirmations_All
                           WHERE  treasury_confirmation_id = TO_NUMBER(l_reference_1);
                           IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                   'FOUND THE CHECKRUN_NAME,DOC_DATE,ORG_ID');
                           END IF;
                         EXCEPTION
                           WHEN OTHERS THEN
                              error_buf := SQLERRM||'- Error while deriving the '||
                                           'checkrun_name,treasury_doc_date from '||
                                           'Fv_Treasury_Confirmations_All table.';
                              error_code := 2;
                              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error15', error_buf) ;
                              RETURN;
                         END;
                      ELSE                                                -- ref6-1
                         -- Case when ref1 is not null,ref3 is null, and ref6 is not null
                         IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                'CASE:REF1 AND REF6 ARE NOT NULL;REF3 IS NULL');
                         END IF;
                         l_accomplish_date := l_reference_6;
                         BEGIN
                            SELECT checkrun_name,org_id
                            INTO vl_checkrun_name,l_org_id
                            FROM Fv_Treasury_Confirmations_All
                            WHERE treasury_confirmation_id = TO_NUMBER(l_reference_1);
                            IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                    'FOUND THE CHECKRUN_NAME,ORG_ID');
                            END IF;
                         EXCEPTION
                            WHEN OTHERS THEN
                                 error_buf := SQLERRM||'- Error while deriving the '||
                                              'checkrun_name from Fv_Treasury_Confirmations_All table.';
                                 error_code := 2;
                                 FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error16', error_buf);
                                 RETURN;
                         END;
                      END IF;                                                -- ref6-1
                      IF (vl_checkrun_name IS NOT NULL) THEN                -- vl_checkrun
                         BEGIN
                            SELECT ce_bank_acct_use_id
                            INTO vg_bank_acct_id
                            FROM Ap_Inv_Selection_Criteria_All
                            WHERE checkrun_name = vl_checkrun_name
                            AND org_id = l_org_id;
                            IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                    'FOUND THE BANK ACCOUNT ID.');
                            END IF;
                         EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                              IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                       'UNABLE TO FIND BANK ACCOUNT ID');
                              END IF;
                              -- Unable to find the bank_account_id
                              Set_Exception('D');
                              GOTO end_label;
                            WHEN OTHERS THEN
                              error_buf := SQLERRM||'- Error while deriving the '||
                                           'bank_account_id from Ap_Inv_Selection_Criteria_All table.';
                              error_code := 2;
                              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error17', error_buf) ;
                              RETURN;
                         END;
                      END IF;                                                -- vl_checkrun
                   ELSIF l_reference_3 IS NOT NULL THEN                -- ref3
                      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CASE WHEN REF3 IS NOT NULL');
                      END IF;
                      IF l_reference_6 IS NULL THEN                        -- ref6-2
                         -- Case when ref1 and ref3 is not null, and ref6 is null
                         -- In this scenario, we determine the accomplish date,
                         -- based on the reference_1, and alc based on reference_3.
                         IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                 'CASE:REF1 AND REF3 ARE NOT NULL;REF6 IS NULL');
                         END IF;
                         BEGIN
                            SELECT treasury_doc_date
                            INTO l_accomplish_date
                            FROM Fv_Treasury_Confirmations_All
                            WHERE treasury_confirmation_id = TO_NUMBER(l_reference_1);
                            IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FOUND TREASURY_DOC_DATE');
                            END IF;
                         EXCEPTION
                            WHEN OTHERS THEN
                               error_buf := SQLERRM||'- Error while deriving the '||
                                           'treasury_doc_date from Fv_Treasury_Confirmations_All table.';
                               error_code := 2;
                               FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error18', error_buf) ;
                               RETURN;
                         END;
                      ELSE                                                -- ref6-2
                         -- Case when ref3 is not null, and ref6 is not null
                         IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                 'CASE:REF1,REF3 AND REF6 ARE NOT NULL');
                         END IF;
                         l_accomplish_date := l_reference_6;
                      END IF;                                                -- ref6-2
                      BEGIN
                         SELECT ce_bank_acct_use_id
                         INTO vg_bank_acct_id
                         FROM Ap_Checks_All
                         WHERE check_id = TO_NUMBER(l_reference_3);
                         IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FOUND THE BANK ACCOUNT ID');
                         END IF;
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            -- Unable to find the bank_account_id
                            Set_Exception('D');
                            GOTO end_label;
                         WHEN OTHERS THEN
                            error_buf := SQLERRM||'- Error while deriving the '||
                                                  'bank_account_id from Ap_Checks_All table.';
                            error_code := 2;
                            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error19', error_buf) ;
                            RETURN;
                      END;
                   END IF;                                                -- ref3
                END IF;                                                -- ref1
                -- Determine the Alc for the bank_account_id found above.
                IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'GETTING THE ALC..');
                END IF;
                Get_Alc
                (
                 p_bank_acct_id    => vg_bank_acct_id,
                 p_alc_code        => l_alc_code,
                 p_error_code      => error_code,
                 p_error_desc      => error_buf
                );
                l_record_type := 'Disbursement';
            <<end_label>>
               l_record_type := 'Disbursement';
         ELSIF (l_je_source = 'Payables' AND l_je_category <> 'Treasury Confirmation') THEN   -- source2
               BEGIN
                  SELECT  Distinct  org_id
                  INTO    l_org_id
                  FROM    ap_invoice_payments_all
                  WHERE   invoice_id = to_number(l_reference_2) ;
               EXCEPTION
               WHEN OTHERS THEN
                   error_code := 2;
                   error_buf  := SQLERRM||'--Error while deriving the org_id, in the '||
                                          'procedure Process_Sf224_Transactions.';
                   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error20', error_buf) ;
               END;
               IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                       'ORG ID OF THE TXN IS '||TO_CHAR(L_ORG_ID));
               END IF;
               IF l_org_id IS NULL THEN
                  l_payables_ia_paygroup := p_def_p_ia_paygroup ;
               ELSE
                  BEGIN
                    SELECT  payables_ia_paygroup
                    INTO    l_payables_ia_paygroup
                    FROM    fv_operating_units_all
                    WHERE   org_id = l_org_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                        error_code := 2;
                        error_buf := SQLERRM ||'--Error while deriving the '||
                                     'payables_ia_paygroup in the procedure Process_Sf224_Transactions';
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error21', error_buf) ;
                  END;
               END IF ;
               IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                       'PAYBLES PAY GROUP IS '||L_PAYABLES_IA_PAYGROUP);
               END IF;
               l_record_type  := 'Disbursement';
               BEGIN  /* to process DIT payments */
                  l_Error_stage := 0;
                  l_inv_amount  := 0;
                  l_reference := To_Number(l_reference_2) ;
                  BEGIN
                     SELECT api.invoice_id,
                            api.vendor_id,
                            api.invoice_amount,
                            nvl(apc.treasury_pay_date,apc.check_date)
                     INTO   l_invoice_id ,
                            l_vendor_id,
                            l_inv_amount,
                            l_check_date
                     FROM   ap_checks_all apc,
                            ap_invoices_all api
                     WHERE  api.invoice_id = NVL(l_reference, 0)
                       AND  apc.check_id = to_number(l_reference_3)
                       AND  l_payables_ia_paygroup = api.pay_group_lookup_code
                       AND  apc.payment_method_lookup_code = 'CLEARING' ;
                     l_ia_flag := 'Y';
                  EXCEPTION
                     WHEN too_many_rows THEN
                          error_buf := 'Too many rows in invoice info,dit select';
                          error_code := g_FAILURE;
                          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error22', error_buf) ;
                          RETURN;
                     WHEN No_Data_Found THEN
                          l_ia_flag := 'N' ;
                  END;
                  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                         'VENDOR ID,INVOICE AMT,CHECK DATE ARE: '||
                                         TO_CHAR(l_vendor_id)||'  '||TO_CHAR(l_inv_amount)||'  '||
                                         TO_CHAR(l_check_date, 'MM/DD/YYYY'));
                  END IF;
                  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'INTERAGENCY FLAG IS '||L_IA_FLAG);
                  END IF;
                  l_error_stage := 1;
                  BEGIN
                     SELECT ce_bank_acct_use_id
                     INTO vg_bank_acct_id
                     FROM Ap_Checks_All
                     WHERE check_id = TO_NUMBER(l_reference_3);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          -- Unable to find the bank_account_id
                          Set_Exception('D');
                     WHEN OTHERS THEN
                          error_buf := SQLERRM||'- Error while deriving the '||
                                       'bank_account_id from Ap_Checks_All table when '||
                                       'category<>Trea Conf.';
                          error_code := 2;
                          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error24', error_buf) ;
                          RETURN;
                  END;
                  -- Determine the Alc for the bank_account_id found above.
                  Get_Alc
                  (
                   p_bank_acct_id    => vg_bank_acct_id,
                   p_alc_code        => l_alc_code,
                   p_error_code      => error_code,
                   p_error_desc      => error_buf
                  );
                  IF l_ia_flag = 'Y' THEN
                     BEGIN
                        SELECT  chargeback_flag, iaf.billing_agency_fund
                        INTO    l_cb_flag,       l_billing_agency_fund
                        FROM    fv_interagency_funds_all iaf
                        WHERE   iaf.vendor_id   = l_vendor_id
                          AND   iaf.invoice_id   = l_invoice_id ;
                     EXCEPTION
                        WHEN too_many_rows THEN
                             error_buf := 'Too many rows in chargeback flag Prelim select';
                             error_code := g_FAILURE;
                             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error23', error_buf) ;
                             RETURN;
                     END;
                  END IF ;
                  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                           'CHARGEBACK FLAG AND BILLING AGENCY FUND ARE :'
                                           || L_CB_FLAG ||'  '|| L_BILLING_AGENCY_FUND);
                  END IF;
                  BEGIN /* Void Date */
                     SELECT  nvl(apc.treasury_pay_date,apc.check_date),
                             apc.void_date
                     INTO    l_accomplish_date,
                             l_void_date
                     FROM    ap_checks_all apc,
                             ap_invoices_all api
                     WHERE   api.invoice_id = Nvl(l_reference, 0)
                       AND   apc.check_id = nvl(l_reference_3,0);
                     IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                              'CHECK DATE/ACCOM DATE AND VOID DATE ARE '||
                                              TO_CHAR(l_accomplish_date, 'MM/DD/YYYY')||'  '||
                                              TO_CHAR(l_void_date, 'MM/DD/YYYY'));
                     END IF;
                     BEGIN /* VOID */
                        l_inv_pay_id := 0;
                        IF (l_void_date IS NOT NULL AND NVL(g_payment_type_flag,'Q') <> 'R') THEN
                            SELECT NVL(MAX(invoice_payment_id),0)
                            INTO   l_inv_pay_id
                            FROM   ap_invoice_payments
                            WHERE  invoice_id = NVL(l_reference, 0)
                              AND  check_id = NVL(l_reference_3,0)
                              AND  invoice_payment_id >l_reference_9;
                            IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                     'VOID DATE IS NOT NULL AND INVOICE '||
                                                     'payment id is '||TO_CHAR(l_inv_pay_id));
                            END IF;
                            IF (l_inv_pay_id = 0) THEN
                               l_accomplish_date := l_void_date ;
                               l_record_type := 'VOID';
                               BEGIN /* V1 */
                                  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                          'Before Getting the Obligation Date');
                                  END IF;
                                  l_obligation_date :=  get_void_check_obligation_date
                                                        ( TO_NUMBER(l_reference_2),
                                                          TO_NUMBER(l_reference_3),
                                                          TO_NUMBER(l_reference_8)
                                                        );
                                  l_record_type    := 'VOID';
                                  l_processed_flag := 'Y';
                                  l_update_type    := 'VOID_PAYABLE';
                                  l_type           := 'VOID';
                                  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                             'OBLIGATION DATE IS '||TO_CHAR(l_obligation_date, 'MM/DD/YYYY'));
                                  END IF;
                               EXCEPTION
                                  WHEN No_Data_Found THEN
                                    IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                'NO DATE FUND Exception while getting the Obligation Date');
                                    END IF;
                                    error_buf := 'No Data Fund Exception while getting the Obligation Date for VOID';
                                    error_code := g_FAILURE;
                                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error25', error_buf);
                                    RETURN;
                                  WHEN too_many_rows THEN
                                    error_buf := 'Too many rows in obligation_date  select';
                                    error_code := g_FAILURE;
                                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error25', error_buf);
                                    RETURN;
                               END ; /* V1 */
                            END IF;
                        END IF;
                     END ; /* VOID */
                     EXCEPTION
                        WHEN too_many_rows THEN
                             error_buf := 'Too many rows in void_date disbursement select';
                             error_code := g_FAILURE;
                             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error26', error_buf) ;
                             RETURN;
                        WHEN no_data_found THEN
                             NULL;
                        WHEN OTHERS THEN
                             error_Buf  := sqlerrm ;
                             error_Code := g_FAILURE ;
                             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error27', error_buf) ;
                             ROLLBACK ;
                             RETURN;
                     END ; /* Void Date */
                     IF (l_ia_flag = 'Y' AND l_error_stage <> g_FAILURE) THEN
                        IF(l_cb_flag = 'Y') THEN
                            /* charge back flag */
                            l_record_type := 'Receipt';
                        ELSE
                            IF(l_billing_agency_fund IS NOT NULL) THEN
                               vl_treasury_symbol := l_treasury_symbol;
                               l_treasury_symbol := l_billing_agency_fund;
                               x_name := 'Inter agency funds';
                               set_transaction_type;
                               l_column_group := 30;
                               l_txn_category := 'I';
                               l_reported_flag:= 'N';
                               IF(l_reported_month like 'CURRENT%') THEN
                                  l_reported_flag     := 'Y' ;
                               END IF;
                               l_exception_exists  := NULL ;
                               l_record_category   := 'CREATED' ;
                               --  Insert the exception transaction
                               insert_new_transaction(l_org_amount, 1);
                            END IF;
                            IF(l_billing_agency_fund = vl_treasury_symbol) THEN
                               l_billing_agency_fund := 'DUPLICATE';
                               l_exception_category  := 'PAYABLES_DUPLICATE_FUND';
                               l_exception_section   := 5;
                               l_column_group := 0;
                               l_reported_month  := NULL ;
                               l_obligation_date := NULL ;
                               l_accomplish_date := NULL ;
                               l_reported_flag     := 'Y' ;
                               l_exception_exists  := 'Y' ;
                               l_record_category   := 'EXCEPTION' ;
                               --  Insert the exception transaction
                               insert_new_transaction(l_amount, 1);
                               l_accomplish_date := l_check_date ;
                            END IF;
                        END IF; /* charge back flag = 'Y' */
                     END IF;
                     IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                             'RECORD TYPE IS '||L_RECORD_TYPE);
                     END IF;
               EXCEPTION
                     WHEN no_data_found THEN
                        IF (l_error_stage = 1) THEN
                            l_billing_agency_fund := 'UNDEFINED';
                            l_exception_category  := 'PAYABLES_MISSING_IAF';
                            l_exception_section   := 4;
                            l_treasury_symbol     := 'UNDEFINED';
                            l_column_group := 0;
                            l_reported_flag := 'N' ;
                            l_exception_exists := 'Y' ;
                            l_record_category := 'EXCEPTION' ;
                            --  Insert the exception transaction
                           insert_new_transaction(l_amount, 1);
                        END IF;
                     WHEN others THEN
                        error_buf     := sqlerrm;
                        error_code    := g_FAILURE;
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error28', error_buf) ;
                        ROLLBACK;
                        RETURN;
               END ; /* End proces DIT */
               ELSIF (l_je_category = 'Treasury Confirmation' AND
                      upper(x_name) LIKE '%VOID%') THEN                -- source2
                      l_record_type            := 'VOID';
                      BEGIN
                         -- check_id
                         SELECT  void_date
                         INTO    l_accomplish_date
                         FROM    ap_checks_all
                         WHERE   check_id = To_number (nvl(l_reference_3,'0'))  ;
                         IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                 'VOID DATE/ACCOMPLISH DATE IS '||
                                                 TO_CHAR(l_accomplish_date, 'MM/DD/YYYY'));
                         END IF;
                         -- invoice_id
                         SELECT invoice_date
                         INTO   l_invoice_date
                         FROM   ap_invoices_all
                         WHERE  Invoice_id = to_number (nvl(l_reference_4,'0')) ;
                         IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'INVOICE DATE IS '||
                                                 TO_CHAR(l_invoice_date, 'MM/DD/YYYY'));
                         END IF;
                      EXCEPTION
                         WHEN no_data_found THEN
                           IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                    'UNABLE TO FIND EITHER THE VOID '||
                                                    'date or invoice date');
                           END IF;
                           l_billing_agency_fund := 'UNDEFINED';
                           l_exception_category  := 'VOID_INCOMPLETE';
                           l_treasury_symbol     := 'UNDEFINED';
                           l_column_group := 0;
                           l_reported_flag     := 'N' ;
                           l_exception_exists  := 'Y' ;
                           l_record_category   := 'EXCEPTION' ;
                           Insert_New_Transaction(l_org_amount, 1);
                      END ;
                      BEGIN
                          SELECT ce_bank_acct_use_id
                          INTO vg_bank_acct_id
                          FROM Ap_Checks_All
                          WHERE check_id = TO_NUMBER(l_reference_3);
                          IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FOUND THE BANK ACCT ID');
                          END IF;
                      EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                             -- Unable to find the bank_account_id
                             IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                      'UNABLE TO FIND THE BANK ACCT ID');
                             END IF;
                             Set_Exception('D');
                          WHEN OTHERS THEN
                             error_buf := SQLERRM||'- Error while deriving the '||
                                         'bank_account_id from Ap_Checks_All table when name like VOID.';
                             error_code := 2;
                             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error29', error_buf) ;
                             RETURN;
                      END;
                      -- Determine the Alc for the bank_account_id found above.
                     Get_Alc
                     (
                      p_bank_acct_id    => vg_bank_acct_id,
                      p_alc_code        => l_alc_code,
                      p_error_code      => error_code,
                      p_error_desc      => error_buf
                     );
                    /* Reassigning  l_reference_4 to l_reference_2. This is because
                      the process is saving invoice_id in reference_2 column. */
                   l_reference_2 := l_reference_4;
                   BEGIN /* V1 */
                      IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                             'Before Calling the get_void_check_obligation_date Procedure ... ');
                      END IF;
                      l_obligation_date :=get_void_check_obligation_date
                                          ( TO_NUMBER(l_reference_2),
                                            TO_NUMBER(l_reference_3),
                                            TO_NUMBER(l_reference_8)
                                          );
                      IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                'After Calling the get_void_check_obligation_date Procedure l_obligation_date ');
                         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'OBLIGATION DATE IS '||
                                               TO_CHAR(l_obligation_date, 'MM/DD/YYYY'));
                      END IF;
                      l_record_type            := 'VOID';
                      l_processed_flag         := 'Y';
                      l_update_type            := 'VOID_PAYABLE';
                      l_type                   := 'VOID';
                   EXCEPTION
                      WHEN No_Data_Found THEN
                         IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                                  'UNABLE TO FIND OBLIGATION DATE');
                         END IF;
                         error_buf := 'No Data Fund Exception while getting the Obligation Date for VOID';
                         error_code := g_FAILURE;
                         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error25', error_buf) ;
                         RETURN;
                      WHEN too_many_rows THEN
                         error_buf := 'Too many rows in obligation_date select';
                         error_code := g_FAILURE;
                         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error30', error_buf) ;
                         RETURN;
                   END ; /* V1 */
             ELSIF (l_je_source = 'Project Accounting') AND(l_je_category ='Labor Cost') THEN -- source2
                   IF (l_exception_category = 'NO_PA_ACCOMPLISH_DATE') THEN
                       l_accomplish_date := l_txn_end_date ;
                   END IF;
                   Set_Exception('D');
             END IF;                                                 -- source2
         ELSE                                                        -- Manual
             /*  x_name = 'MANUAL' default end_date for accomplish_date
                 and alc code would be default alc. */
             --l_accomplish_date := l_txn_end_date ;
             --l_alc_code := p_def_alc_code;
             l_record_type := 'MANUAL';
             IF (x_name = 'MANUAL') THEN
                 Set_Exception('R');
             END IF;
             IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ACCOMPLISH DATE IS '
                                      ||TO_CHAR(l_accomplish_date, 'MM/DD/YYYY'));
             END IF;
         END IF;                                                        -- Manual
         ------------------------------------------------------------
         --  End of all accomplish date and exception assignments
         ------------------------------------------------------------
         IF l_je_source = 'Payables' AND  l_je_category = 'Payments'
            AND g_payment_type_flag = 'R'
            AND g_invoice_type_lookup_code IN ( 'CREDIT','DEBIT')
            AND l_reference_2  IS NOT NULL AND l_reference_3 IS NOT NULL
            AND l_reference_8 IS NOT NULL  THEN     /*g_payment_type_flag = 'R' */
            IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'g_payment_type_flag = R');
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'g_invoice_type_lookup_code '  ||
                                     g_invoice_type_lookup_code);
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Check Void Date : '||
                                     g_check_void_date );
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_reference_1 : ' || l_reference_1 );
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_reference_2 (INV ID) : ' ||
                                     l_reference_2 );
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_reference_3 (CHECK ID) : ' ||
                                     l_reference_3 );
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_reference_4 : ' || l_reference_4 );
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_reference_5 : ' || l_reference_5 );
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_reference_6 : ' || l_reference_6 );
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_reference_8 (INV DIST NO) : ' ||
                                     l_reference_8 );
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_reference_9 : ' || l_reference_9 );
            END IF;
            BEGIN /*  Refund Checks */
               SELECT obligation_date
               INTO   l_obligation_date
               FROM   fv_refunds_voids_all
               WHERE  set_of_books_id = sob
                 AND  org_id                  = g_org_id
                 AND  TYPE = 'PAYABLE_REFUND'
                 AND  invoice_id      = l_reference_2
                 AND  check_id        = l_reference_3
                 --   AND   invoice_payment_id = l_reference_9
                 AND  distribution_line_number = l_reference_8;
                 IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Obligation Date : ' ||
                                          l_obligation_date );
                 END IF;
                 l_processed_flag    := 'Y';
                 l_update_type       := 'PAYABLE_REFUND';
                 l_type              := 'PAYABLE_REFUND';
                 l_record_type       := 'PAYABLE_REFUND';
                 IF l_obligation_date IS NULL THEN
                    l_exception_category  := 'PAYABLE_REFUND_NULL_EXPN';
                    l_exception_section   := 9;
                    l_treasury_symbol     := 'UNDEFINED';
                    l_column_group        := 0;
                    l_accomplish_date     := NULL;
                    l_reported_flag       := 'N' ;
                    l_exception_exists    := 'Y' ;
                    l_record_category     := 'EXCEPTION' ;
                    Insert_New_Transaction(l_org_amount,1);
                 END IF;
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                         l_exception_category  := 'PAYABLE_REFUND_NDF_EXPN';
                         l_exception_section   := 8;
                         l_treasury_symbol     := 'UNDEFINED';
                         l_column_group        := 0;
                         l_accomplish_date     := NULL;
                         l_reported_flag       := 'N' ;
                         l_exception_exists    := 'Y' ;
                         l_record_category     := 'EXCEPTION' ;
                         Insert_New_Transaction(l_org_amount,1);
                 END; /*  Refund Checks */
         END IF;   /* g_payment_type_flag = 'R' */
         IF (l_accomplish_date is not null) then    -- if accomplish_date
            IF ((l_alc_code IS NOT NULL) OR (l_exception_category IS NULL)) THEN
                set_transaction_type;
            END IF;

        /* Reclassification start :-
           Payables: The Payment Form has been updated to include a Void Payment field.
           If the Void Payment field is populated for a payment, then that payment and the cancelled payment it references
           will be considered as reclassified transactions and  will be included in Section I of the partial 224.
           Receivables: A new DFF has been introduced in AR Receipt form. This DFF allows to replace the receipt for any existing
           receipts. Both receipts will be treated as reclassified and inludeded in Partial 224. */

           IF l_je_source = 'Payables' AND  l_je_category = 'Payments' AND g_payment_type_flag = 'M'
              AND l_reference_2 IS NOT NULL AND l_reference_3 IS NOT NULL  AND l_reference_9 IS NOT NULL  THEN
              BEGIN
                SELECT  apc.void_check_number /* replace attribute1 with new field name */
                INTO    l_void_check_number
                FROM ap_checks_all apc
                WHERE apc.check_id = to_number(l_reference_3);
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,    l_module_name,'Void Check Number : '|| l_void_check_number );
                END IF;
              EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     l_void_check_number:=NULL;
              END;
              BEGIN
                SELECT 'Y'
                INTO  l_voided_reclassified_payment
                FROM  AP_INVOICE_PAYMENTS_ALL APP
                WHERE APP.CHECK_ID =  TO_NUMBER(L_REFERENCE_3)
                  AND APP.invoice_payment_id = TO_NUMBER(L_REFERENCE_9)
                  AND APP.reversal_inv_pmt_id IS NOT NULL
                  AND APP.reversal_flag ='Y';
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Voided Reclassified Payment: '||l_voided_reclassified_payment);
                END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_voided_reclassified_payment:='N';
              END;
           ELSIF l_je_source = 'Receivables' AND l_cash_receipt_id IS NOT NULL AND l_ar_reclass_attribute IS NOT NULL THEN
              BEGIN
                 sql_stmt1:= 'SELECT ACR.' || l_ar_reclass_attribute ||
                             ' FROM AR_CASH_RECEIPTS_ALL ACR WHERE ACR.cash_receipt_id = '||l_cash_receipt_id;
                 EXECUTE IMMEDIATE sql_stmt1 INTO l_reclass_receipt_number ;
                 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,        l_module_name,'Reclass Receipt Number: '|| l_reclass_receipt_number );
                 END IF;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   l_reclass_receipt_number:=NULL;
               END;
               BEGIN
                 sql_stmt:='SELECT ''Y'' FROM  AR_CASH_RECEIPTS_ALL ac, Ar_Cash_Receipt_History_All ah
                           where ac.cash_receipt_id = ah.cash_receipt_id
                           and ah.cash_receipt_history_id = '|| l_cash_receipt_hist_id ||
                           ' and ah.STATUS= ''REVERSED'' '||
                           ' AND ah.CURRENT_RECORD_FLAG = ''Y'' '||
                           ' and exists (SELECT ''Y''  FROM  AR_CASH_RECEIPTS_ALL AC2 '||
                           ' WHERE AC2.' || l_ar_reclass_attribute ||
                           ' = ' || '''' || l_document_number || '''' || ' )' ;
                 EXECUTE IMMEDIATE sql_stmt INTO l_receipt_reclassified ;
                 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Receipt Reclassified: '|| l_receipt_reclassified );
                 END IF;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   l_receipt_reclassified:='N';
                   l_exists := 'M';
               END;
               IF(l_exists = 'M') AND (l_je_category = 'Misc Receipts') THEN
                 BEGIN
                   sql_stmt:='SELECT ''Y''  FROM  AR_CASH_RECEIPTS_ALL ac, Ar_Misc_Cash_Distributions_All ah
                              where ac.cash_receipt_id = ah.cash_receipt_id
                              and ah.misc_cash_distribution_id = '|| l_cash_receipt_hist_id ||
                              ' and ah.cash_receipt_id = '||l_cash_receipt_id||
                              ' and ah.created_from= ''ARP_REVERSE_RECEIPT.REVERSE'' '||
                              ' and exists (SELECT ''Y''  FROM  AR_CASH_RECEIPTS_ALL AC2 '||
                              ' WHERE AC2.' || l_ar_reclass_attribute ||
                              ' = ' || '''' || l_document_number || '''' || ' )' ;
                   EXECUTE IMMEDIATE sql_stmt INTO l_receipt_reclassified ;
                   IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Receipt Reclassified: '|| l_receipt_reclassified );
                   END IF;
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     l_receipt_reclassified:='N';
                 END;
               END IF;
           END IF; /*Reclassification end */

           l_reclass    := 'N';
           IF (l_je_category=fnd_profile.value('FV_RECLASSIFICATION_JOURNAL_CATEGORY') OR     -- Journal reclassified
              (l_void_check_number IS NOT NULL OR  l_voided_reclassified_payment = 'Y')OR     -- payable reclassified
              (l_reclass_receipt_number IS NOT NULL OR l_receipt_reclassified = 'Y'))  THEN   -- Receivables reclassified

              l_reclass    := 'Y';
              l_reportable := 'I';

           ELSIF  g_partial_or_full ='Partial'   THEN
              BEGIN
                SELECT fv.fv_alc_addresses_id ,fv.business_activity_code, fv.gwa_reporter_category_code
                INTO   l_alc_addresses_id,      l_business_activity_code, l_gwa_reporter_category_code
                FROM   fv_alc_business_activity_v fv
                WHERE  fv.agency_location_code = l_alc_code
                  AND  fv.PERIOD_NAME = l_gl_period
                  AND  fv.SET_OF_BOOKS_ID = sob;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_gwa_reporter_category_code:= NULL;
                     l_alc_addresses_id:= NULL;
                     l_business_activity_code:= NULL;
              END;
              IF l_gwa_reporter_category_code IS NOT NULL  THEN
                   check_partial_reporting
                     (
                      p_business_activity_code     => l_business_activity_code,
                      p_gwa_reporter_category_code => l_gwa_reporter_category_code,
                      p_error_code                 => error_code,
                      p_error_desc                 => error_buf
                      );
                     IF error_code <> g_SUCCESS THEN
                        RETURN;
                     END IF;
              ELSE
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' No GWA Reporter Category found for the ALC: ' || l_alc_code ||
                                                                                ' for the  selected period: '|| l_gl_period);
                 l_reportable:='E';
              END IF;
           ELSE
              l_reportable :='I';
           END IF;

           IF l_reportable='X' or l_reportable='E' THEN
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'deleting the section VI, VII exception ');
                END IF;
                DELETE fv_sf224_temp fv
                WHERE fv.je_line_num = L_JE_LINE_NUM
                AND fv.je_header_id  = L_JE_HEADER_ID
                AND fv.exception_category IN ('DEFAULT_ALC','REPORTED_AS_MANUAL','NO_PA_ACCOMPLISH_DATE');

                IF l_reportable='X' THEN
                   l_exception_category  := 'INVALID_BA_GWA_SEC_COMBO';
                   l_exception_section   := 10;
                ELSIF l_reportable='E' THEN
                   l_exception_category  := 'GWA_REPORTABLE';
                   l_exception_section   := 0;
                END IF;
                l_column_group        := 0;
                l_reported_flag       := 'N';
                l_exception_exists    := 'Y';
                l_record_category     := 'EXCEPTION' ;
                Insert_New_Transaction(l_org_amount, 1);

           END IF;
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'UPDATING FV_SF224_TEMP WITH THE ALC_CODE');
           END IF;


           Update fv_sf224_temp
             set reported_month      = l_reported_month,
                 accomplish_date     = l_accomplish_date,
                 exception_category  = l_exception_category,
                 exception_section   = l_exception_section,
                 column_group        = l_column_group,
                 inter_agency_flag   = l_ia_flag,
                 obligation_date     = l_obligation_date,
                 record_type         = l_record_type,
                 reference_2         = l_reference_2,
                 reference_3         = l_reference_3,
                 amount              = l_org_amount * l_sign_number,
                 actual_amount       = l_org_amount,
                 sign_number         = l_sign_number,
                 alc_code            = l_alc_code,
                 reported_flag       = DECODE ( l_reportable, 'I', DECODE(l_reported_month, 'CURRENT', 'Y',
                                                 'CURRENT/PRIOR','Y','N'),'N'),
                 EXCEPTION_EXISTS    = L_EXCEPTION_EXISTS,
                 SF224_PROCESSED_FLAG= 'Y',
                 je_source           = l_je_source,
                 je_category         = l_je_category,
                 document_number     = l_document_number,
                 txn_category        = l_txn_category,
                 reclass             = NVL(l_reclass, 'N'),
                 start_period_date   = l_txn_start_date,
                 end_period_date     = l_txn_end_date,
                 update_type         = l_update_type,
                 last_updated_by     = g_user_id,
                 last_update_date    = g_sysdate,
                 last_update_login   = g_login_id,
                 updated_request_id  = g_request_id
            where rowid = l_rowid;

        ELSE   -- if accomplish_date
            update  fv_sf224_temp
              set   reported_flag    = 'N',
                    sf224_Processed_flag   = 'Y',
                    exception_exists = l_exception_exists,
                    last_updated_by     = g_user_id,
                    last_update_date    = g_sysdate,
                    last_update_login   = g_login_id,
                    updated_request_id  = g_request_id
            where   rowid = l_rowid ;
        END IF;   -- if accomplish_date

        IF (sqlcode < 0) THEN
            error_buf := 'fv_sf224_temp table Update failed ';
            error_code := g_FAILURE;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error31', error_buf) ;
            RETURN;
        END IF;
    END LOOP;    -- end c1
    CLOSE  c1;
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'-----------------------------------------------');
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        error_code := sqlcode ;
        error_buf  := sqlerrm ;
        IF C1%ISOPEN THEN
            CLOSE C1;
        END IF ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', error_buf) ;
       ROLLBACK ;
       RETURN ;
END Process_Sf224_Transactions; /* of procedure */

---------------------------------------------------------------------------------
-----                 CHECK_PARTIAL_REPORTING
---------------------------------------------------------------------------------


  PROCEDURE Check_partial_reporting
   (
    p_business_activity_code     IN fv_alc_addresses_all.business_activity_code%TYPE,
    p_gwa_reporter_category_code IN fv_alc_gwa_categories.gwa_reporter_category_code%TYPE,
    p_error_code                 OUT NOCOPY NUMBER,
    p_error_desc                 OUT NOCOPY VARCHAR2
   )
  IS
     l_module_name VARCHAR2(200) ;
  BEGIN
     p_error_code := g_SUCCESS;
     l_module_name := g_module_name || 'Check_partial_reporting';
     IF l_ia_flag = 'Y' THEN /*CHECK FOR INTER GOVERENMENTAL TRANSACTION */
        BEGIN
          SELECT mp.trx_category_intra
          INTO   l_reportable
          FROM   fv_sf224_map mp
          WHERE  mp.business_activity_code = p_business_activity_code
             AND mp.GWA_REPORTER_CATEGORY_CODE = p_gwa_reporter_category_code;
        EXCEPTION
          WHEN no_data_found THEN
             l_reportable:='E';
        END;
     ELSE
       /*CHECK FOR PAYMENTS AND COLLECTION BASED ON COLUMN_GROUP */
       IF (l_column_group = 20 OR l_column_group = 31 ) THEN
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'column group is 20 or 31 ');
           END IF;
           BEGIN
              SELECT mp.trx_category_coll
              INTO   l_reportable
              FROM   fv_sf224_map mp
              WHERE  mp.business_activity_code = p_business_activity_code
                 AND mp.GWA_REPORTER_CATEGORY_CODE = p_gwa_reporter_category_code;
           EXCEPTION
              WHEN no_data_found THEN
                l_reportable:='E';
           END;
       ELSIF (l_column_group = 21 OR l_column_group = 30 ) THEN
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'column group is 21 or 30 ');
          END IF;
          BEGIN
            SELECT mp.trx_category_pay
            INTO   l_reportable
            FROM   fv_sf224_map mp
            WHERE  mp.business_activity_code = p_business_activity_code
               AND mp.GWA_REPORTER_CATEGORY_CODE = p_gwa_reporter_category_code;
          EXCEPTION
            WHEN no_data_found THEN
               l_reportable:='E';
          END;
       END IF;
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM || '-- Error in procedure Check_partial_reporting.';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_module_name||'.final_exception', p_error_desc) ;
      RETURN;
  END Check_partial_reporting;



----------------------------------------------------------------------
--                      SET_EXCEPTION
----------------------------------------------------------------------
PROCEDURE Set_Exception(exp_type VARCHAR2) IS
    l_module_name VARCHAR2(200) ;
 BEGIN
  l_module_name := g_module_name || 'Set_Exception';
  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'IN SET_EXCEPTION PROC WITH EXP_TYPE = '||EXP_TYPE);
  END IF;
  IF (exp_type = 'R') THEN
      -- Reported as Manual exception
      l_name := 'MANUAL';
      l_exception_category := 'REPORTED_AS_MANUAL';
      l_exception_section := 6;
      l_accomplish_date := l_txn_end_date ;
  ELSE
      -- Default ALC exception
      l_exception_category := 'DEFAULT_ALC';
      l_exception_section := 6;
      --l_alc_code := p_def_alc_code;
  END IF;
  l_alc_code := p_def_alc_code;
  l_reported_flag := 'Y';
  l_exception_exists := 'Y';
  l_record_category := 'EXCEPTION';
  Insert_New_Transaction(l_amount, 1);
  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TXN INSERTED');
  END IF;
 EXCEPTION
    WHEN OTHERS THEN
      error_code := 2;
      error_buf  := SQLERRM || '-- Error in procedure Set_Exception.';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', error_buf) ;
      RETURN;
END Set_Exception;


----------------------------------------------------------------------
--                      GET_ALC
----------------------------------------------------------------------

  PROCEDURE get_alc
  (
    p_bank_acct_id    IN  NUMBER,
    p_alc_code        OUT NOCOPY VARCHAR2,
    p_error_code      OUT NOCOPY NUMBER,
    p_error_desc      OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name VARCHAR2(200) ;
    l_location    VARCHAR2(200);

    CURSOR get_alc_cur
    (
      c_bank_acct_id NUMBER
    ) IS
      SELECT ceba.agency_location_code
      FROM   ce_Bank_Accounts ceba,
             ce_bank_acct_uses_all cebu
      WHERE  cebu.org_id = g_org_id
        AND  cebu.org_id = ceba.account_owner_org_id
        AND  cebu.bank_acct_use_id = c_bank_acct_id
        AND  ceba.bank_account_id = cebu.bank_account_id;

  BEGIN
    l_module_name := g_module_name || 'get_alc';
    p_error_code := g_SUCCESS;

    OPEN get_alc_cur(p_bank_acct_id);
    FETCH get_alc_cur INTO p_alc_code;
    CLOSE get_alc_cur;

    IF (p_alc_code IS NULL) THEN
      set_exception('D');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
  END Get_Alc;



  ----------------------------------------------------------------------
  --                    INSERT_NEW_TRANSACTION
  ----------------------------------------------------------------------
  PROCEDURE insert_new_transaction(x_amount number, x_sign_number number) is
    l_module_name VARCHAR2(200) ;

  BEGIN
    l_module_name := g_module_name || 'Insert_new_transaction';
    INSERT INTO fv_sf224_temp
    (
      je_batch_id,
      fund_code,
      name,
      amount,
      actual_amount,
      sign_number,
      reported_month,
      column_group,
      record_type,
      inter_agency_flag,
      obligation_date,
      exception_category,
      accomplish_date,
      treasury_symbol,
      treasury_symbol_id,
      je_line_num,
      reported_flag,
      exception_exists,
      record_category,
      reference_1,
      reference_2,
      reference_3,
      reference_9,
      je_header_id,
      alc_code,
      gl_period,
      set_of_books_id,
      je_source,
      je_category,
      document_number,
      txn_category,
      start_period_date,
      end_period_date,
      exception_section,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      created_request_id
    )
    VALUES
    (
      l_batch_id,
      l_billing_agency_fund,
      x_name,
      x_amount*x_sign_number,
      x_amount,
      x_sign_number,
      l_reported_month,
      l_column_group,
      l_record_type,
      l_ia_flag,
      l_obligation_date,
      l_exception_category,
      l_accomplish_date,
      l_treasury_symbol,
      l_treasury_symbol_id,
      l_je_line_num,
      DECODE(l_record_category, 'EXCEPTION', NULL, l_reported_flag),
      DECODE(l_record_category, 'EXCEPTION', NULL, l_exception_exists),
      l_record_category,
      l_reference_1,
      l_reference_2,
      l_reference_3,
      l_reference_9,
      l_je_header_id,
      l_alc_code,
      l_gl_period,
      sob,
      l_je_source,
      l_je_category,
      l_document_number,
      l_txn_category,
      l_txn_start_date,
      l_txn_end_date,
      l_exception_section,
      g_user_id,
      g_sysdate,
      g_user_id,
      g_sysdate,
      g_login_id,
      g_request_id
    );
  EXCEPTION
    WHEN OTHERS THEN
    error_code := sqlcode ;
    error_buf  := sqlerrm ;
    RollBack ;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', error_buf) ;
    Return ;
  END Insert_new_transaction;

  ----------------------------------------------------------------------
  --                      SET_TRANSACTION_TYPE
  ----------------------------------------------------------------------
  Procedure set_transaction_type is
    l_module_name VARCHAR2(200) ;
  BEGIN
    l_module_name := g_module_name || 'set_transaction_type';
    IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'IN SET_TRANSACTION_TYPE PROC');
    END IF;
    IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'EXCEPTION CATEGORY IS '||L_EXCEPTION_CATEGORY);
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECORD TYPE IS '||L_RECORD_TYPE);
    END IF;
    l_sf224_type_code := upper(l_sf224_type_code);
    l_sign_number := 1;
    IF(l_record_type = 'Receipt') THEN
        l_column_group := 20;
        l_txn_category := 'C';
        IF(l_ia_flag = 'Y') THEN
            l_column_group := 21;
            l_txn_category := 'I';
        END IF;
    ELSIF (l_record_type = 'Disbursement') THEN
        l_column_group := 30;
        l_txn_category := 'P';
        l_sign_number := -1;
    ELSIF(l_record_type LIKE '%refund%' OR l_record_type = 'VOID') THEN
        NULL;
    ELSIF(l_record_type = 'MANUAL') THEN
        IF (l_sf224_type_code = 'RECEIPT') THEN
            l_column_group := 20;
            l_txn_category := 'C';
        ELSIF  (l_sf224_type_code = 'DISBURSEMENT') THEN
            l_column_group := 30;
            l_txn_category := 'P';
            l_sign_number := -1;
        ELSIF(l_sf224_type_code  = 'REVOLVING') THEN
            IF(l_d_r_flag = 'R') THEN
                l_column_group := 20;
                l_txn_category := 'C';
            ELSE
                l_column_group := 30;
                l_txn_category := 'P';
                l_sign_number := -1;
            END IF;
        END IF; /* fund_type */
    END IF; /* Record type */
EXCEPTION
    WHEN OTHERS THEN
        error_code := sqlcode ;
        error_buf  := sqlerrm ;
        ROLLBACK ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', error_buf) ;
        RETURN;
END set_transaction_type;


  ----------------------------------------------------------------------
  --                      PRE_PRECESS
  ----------------------------------------------------------------------

PROCEDURE pre_process
  (
    p_set_of_books_id IN NUMBER,
    p_error_code      OUT NOCOPY NUMBER,
    p_error_desc      OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name VARCHAR2(200);
    l_location    VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || '.extract';
    p_error_code := g_SUCCESS;

    BEGIN
        /* Delete all exceptions */
        DELETE fv_sf224_temp fst
         WHERE fst.set_of_books_id = p_set_of_books_id
           AND fst.exception_exists IS NULL
           AND fst.record_category = 'EXCEPTION';
    EXCEPTION
      WHEN OTHERS THEN
        p_error_code := g_FAILURE;
        p_error_desc := SQLERRM;
        l_location   := l_module_name||'delete_fv_sf224_temp';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    END;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        /* Reprocess all exceptions */
        UPDATE fv_sf224_temp fst
           SET fst.sf224_processed_flag = 'N',
               last_updated_by     = g_user_id,
               last_update_date    = g_sysdate,
               last_update_login   = g_login_id,
               updated_request_id  = g_request_id
         WHERE fst.set_of_books_id = p_set_of_books_id
           AND fst.exception_exists = 'Y';
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'update_fv_sf224_temp';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
  END pre_process;




-- End addition

--  ==============================================================================================
--  This procedure check is the ALC address for each ALC code in the FV_ALC_ADDRESSES_ALL Table
--  If atleast address for one ALC code does not exist the status of the Concurrent program is set
--  as Warning and all the ALCs with out address are displayed in the Con Log
--  ==============================================================================================
    PROCEDURE check_alc_address
    (
      p_alc IN VARCHAR2
    )
    IS
	l_module_name 		VARCHAR2(100);
	l_count			NUMBER;
	l_alc_add_missing_count NUMBER := 0;
	CURSOR alc_code_csr IS
		 SELECT DISTINCT tmp.alc_code
		 FROM  fv_sf224_temp tmp
		 WHERE tmp.set_of_books_id = sob
		   AND tmp.alc_code IS NOT NULL;
    BEGIN
	l_module_name := g_module_name || 'check_alc_address';
	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Start of check_alc_address p_alc_code => ' || p_alc) ;
   	END IF;
	IF p_alc = 'ALL' THEN /* p_alc = 'ALL' */
	     FOR alc_code_rec IN alc_code_csr LOOP
 		 BEGIN
		   SELECT 1
		   INTO  l_count
		   FROM  fv_alc_addresses_all
		   WHERE AGENCY_LOCATION_CODE  = alc_code_rec.alc_code
		   AND   set_of_books_id  = sob;
      	 EXCEPTION
		   WHEN NO_DATA_FOUND THEN
		     IF l_alc_add_missing_count = 0 THEN
		   	 fv_utility.log_mesg(fnd_log.LEVEL_ERROR, l_module_name,'ALC address not found for the following ALC(s)');
   			 error_buf := SUBSTR(error_buf,1,40) || ' WITH WARNING **' ||
		   	  		  fnd_global.newline() || 'ALC Address Not Found For The ALC(s)' ;
     		     END IF;
	   	     l_alc_add_missing_count := l_alc_add_missing_count+1;
		     fv_utility.log_mesg(fnd_log.LEVEL_ERROR, l_module_name,l_alc_add_missing_count || ' : ' || alc_code_rec.alc_code);
 		     error_buf := error_buf || fnd_global.newline() || l_alc_add_missing_count ||' : ' || alc_code_rec.alc_code ;
	 	 END;
	    END LOOP;
	ELSE /* when  p_alc is not 'ALL' */
	    BEGIN
		SELECT 1
		INTO l_count
		FROM fv_alc_addresses_all
		WHERE AGENCY_LOCATION_CODE 	= p_alc
		AND   set_of_books_id 		= sob;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		  l_alc_add_missing_count := l_alc_add_missing_count+1;
		  fv_utility.LOG_MESG(Fnd_Log.LEVEL_ERROR, l_module_name,'ALC address not found for the following ALC ' || p_alc);
   		  error_buf := SUBSTR(error_buf,1,40) || ' WITH WARNING **' || fnd_global.newline() ||
		    						'ALC Address Not Found For The ALC ' || p_alc ;
	    END;
	END IF; /* p_alc = 'ALL' */
	IF l_alc_add_missing_count > 0 THEN /* l_alc_add_missing_count > 0 */
	   IF FND_CONCURRENT.SET_COMPLETION_STATUS ('WARNING','ALC address not found for the ALC(s)') THEN
	   	 --	error_buf := SUBSTR(error_buf,1,40) || ' WITH WARNING **' || fnd_global.newline() ||
	   	 --				'ALC address not found for the ALC(s)' ;
	      NULL;
	   ELSE
		fv_utility.LOG_MESG(Fnd_Log.LEVEL_ERROR, l_module_name,'Error in seting the Concurent Program Status as Waring');
		error_code := SQLCODE ;
    		error_buf  := SQLERRM;
    	   END IF;
	END IF; /* l_alc_add_missing_count > 0 */
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'End of check_alc_address ') ;
   	END IF;
    EXCEPTION
      WHEN OTHERS THEN
    	  error_code := SQLCODE;
    	  error_buf  := SQLERRM;
    	  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', error_buf) ;
	  RAISE;
    END check_alc_address;

  ----------------------------------------------------------------------
  --                      EXTRACT
  ----------------------------------------------------------------------

    PROCEDURE extract
  (
    p_errbuf          OUT NOCOPY VARCHAR2,
    p_retcode         OUT NOCOPY NUMBER,
    p_set_of_books_id IN NUMBER
  )
  IS
    l_module_name VARCHAR2(200);
    l_location    VARCHAR2(200);
    l_currency_code        gl_sets_of_books.currency_code%TYPE;
    l_chart_of_accounts_id gl_sets_of_books.chart_of_accounts_id%TYPE;
    l_acct_segment         fnd_id_flex_segments.application_column_name%TYPE;
    l_acct_value_set_id    fnd_id_flex_segments.flex_value_set_id%TYPE;
    l_bal_segment          fnd_id_flex_segments.application_column_name%TYPE;
    l_previous_run_date    DATE;
  BEGIN
    l_module_name := g_module_name || '.extract';
    p_retcode := g_SUCCESS;
    sob := p_set_of_books_id;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'In extrac procdure ');
    End if;


    check_report_definitions
    (
      p_set_of_books_id => p_set_of_books_id,
      p_error_code      => p_retcode,
      p_error_desc      => p_errbuf
    );

    IF (p_retcode = g_SUCCESS) THEN
      initialize_program_variables
      (
        p_set_of_books_id      => p_set_of_books_id,
        p_currency_code        => l_currency_code,
        p_chart_of_accounts_id => l_chart_of_accounts_id,
        p_acct_segment         => l_acct_segment,
        p_acct_value_set_id    => l_acct_value_set_id,
        p_bal_segment          => l_bal_segment,
        p_accomplish_attribute => l_accomplish_attribute,
        p_error_code           => p_retcode,
        p_error_desc           => p_errbuf
      );
    END IF;

    flex_num := l_chart_of_accounts_id;

    IF (p_retcode = g_SUCCESS) THEN
      get_run_date
      (
        p_set_of_books_id   => p_set_of_books_id,
        p_previous_run_date => l_previous_run_date,
        p_error_code        => p_retcode,
        p_error_desc        => p_errbuf
      );
    END IF;
    IF (p_retcode = g_SUCCESS) THEN
      insert_sf224_batches
      (
        p_set_of_books_id   => p_set_of_books_id,
        p_previous_run_date => l_previous_run_date,
        p_current_run_date  => g_SYSDATE,
        p_currency_code     => l_currency_code,
        p_acct_segment      => l_acct_segment,
        p_bal_segment       => l_bal_segment,
        p_error_code        => p_retcode,
        p_error_desc        => p_errbuf
      );
    END IF;
    IF (p_retcode = g_SUCCESS) THEN
      set_run_date
      (
        p_set_of_books_id   => p_set_of_books_id,
        p_error_code        => p_retcode,
        p_error_desc        => p_errbuf
      );
    END IF;
    IF (p_retcode = g_SUCCESS) THEN
      pre_process
      (
        p_set_of_books_id => p_set_of_books_id,
        p_error_code      => p_retcode,
        p_error_desc      => p_errbuf
      );
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      process_sf224_transactions;
      p_retcode := error_code;
      p_errbuf := error_buf;
    END IF;


    IF (p_retcode <> g_SUCCESS) THEN
      ROLLBACK;
    ELSE
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
  END extract;



--  ==============================================================================================
--  This procedure get the obligation Date of the Void Payment.
--  If the Distibution is derived from a PO, the PO date is considered as obligation Date
--  Else If the Distibution is derived from an Invoice, the Invocie date is considered as obligation Date
--  Else that is the distribution is manual entry then the Invoice Date is taken as the Obligation date
--  If a NO_DATA_FOUND Exception Happen during the calculation the NO_DATA_FOUND raised
--  back to the calling Procedure
--  ==============================================================================================

FUNCTION get_void_check_obligation_date( p_invoice_id NUMBER,
										 p_check_id   NUMBER,
										 P_inv_dist_num NUMBER)

RETURN DATE  IS
	l_obligation_date 		DATE;
	l_module_name 			VARCHAR2(100);
	l_po_dist_id			ap_invoice_distributions_all.po_distribution_id%TYPE;
	l_parent_invoice_id		ap_invoices_all.invoice_id%TYPE;
BEGIN
	l_module_name := g_module_name || 'get_void_check_obligation_date';
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Start of get_void_check_obligation_date') ;
 		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, ' p_invoice_id => ' ||  p_invoice_id  ||
 																	  ' p_check_id  => ' || p_check_id ||
 																	  ' P_inv_dist_num => ' || P_inv_dist_num) ;
   	END IF;

       ------------- modified for bug 5454445
            SELECT    NVL(max(po_distribution_id),0),
                        NVL(max(parent_invoice_id),0)
                INTO    l_po_dist_id, l_parent_invoice_id
                FROM    ap_invoice_distributions_all
                WHERE   invoice_id = p_invoice_id ;
                --AND           distribution_line_number = p_inv_dist_num;
       --------------
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
 					' l_po_dist_id => ' || l_po_dist_id || '  l_parent_invoice_id => ' || l_parent_invoice_id) ;
   	END IF;
	 	IF   l_po_dist_id <> 0 THEN
	 		SELECT 		NVL(gl_encumbered_date,creation_date)
	 			INTO  	l_obligation_date
	 			FROM 	po_distributions
	 			WHERE  	po_distribution_id =l_po_dist_id;
	 		    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 				FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	 									'Obligation Date is PO Date => ' || l_obligation_date);
 			   	END IF;
	 	ELSIF l_parent_invoice_id <> 0 THEN
	 		SELECT INVOICE_DATE
	 			INTO  l_obligation_date
	 			FROM  ap_invoices_all
	 			WHERE invoice_id = 	l_parent_invoice_id;
	 			IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 				FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	 							 'Obligation Date is Parent Invoice Date => ' || l_obligation_date);
 			   	END IF;
	 	ELSE
	 		SELECT INVOICE_DATE
	 			INTO  l_obligation_date
	 			FROM  ap_invoices_all
	 			WHERE invoice_id = 	p_invoice_id;
	 			IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 				FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	 							'Obligation Date is Invoice Date => ' || l_obligation_date);
 			   	END IF;
		END IF;


   	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
				'End of get_void_check_obligation_date l_obligation_date  NEW CODE  =>  ' || l_obligation_date) ;
	END IF;
 	RETURN l_obligation_date;
EXCEPTION
		WHEN NO_DATA_FOUND THEN
			IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 				FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'NO DATA FOUND EXCEPTION');
		  	END IF;
			RAISE;
		WHEN OTHERS THEN
		    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 				FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'WHEN OTHERS EXCEPTION');
		  	END IF;
		  	error_code := SQLCODE;
   		 	error_buf  := SQLERRM;
			RAISE ;
END get_void_check_obligation_date;

--  ==============================================================================================
--  This procedure populate all the Refunds information from AP to FV table.
--  This procedure is called from FMS224 Populate Payables Refunds Process.
--  And this process takes mainly two parameters GL Period Low and GL period high
--  And this process submit the Report which lists all the imported data from AP to FV table (FV_REFUNDS_VOIDS_all)
--  with con request Id as the parameter
--  Logic :
--	This process takes all the posted Refunds (ie, Payment Type Flag = 'R' (Refund) and
--	Posted Flag = Y (Accounted) and Entry exist in GL_JE_LINES (Posted in GL),
--	which are not in the FV table (ie INVOICE PAYMNET ID does not exist in FV table )
--	and GL date with in the GL Period.
--	If the Distibution is derived from a PO, the PO date is populated as obligation Date
--	and PO Number as Obligation Number
-- 	Else If the Distibution is derived from an Invoice, the Invocie date is populated as
--	obligation Date and parent Invoice Number as Obligation Nuber
--      Else that is the distribution is manual entry then NULL is populated for
--	Obligation date and Obligation Number
--      The dist_code_combination_id is joined with gl_je_lines code_combination_id is to
--	imporve the performance
--  ==============================================================================================
PROCEDURE fv_ap_refund_populate(    errbuf           	OUT NOCOPY VARCHAR2,
                    				retcode          	OUT NOCOPY NUMBER,
                   					p_set_of_books_id   IN  NUMBER,
                    				p_org_id 	     	IN  NUMBER,
                    				P_gl_period_low  	IN  VARCHAR2,
                    				p_gl_period_high 	IN  VARCHAR2)
IS
	 l_module_name   		VARCHAR2(100);
	 l_gl_start_date		DATE;
	 l_gl_end_date   		DATE;
	 l_user_id       		NUMBER(15);
	 l_conc_request_id 		NUMBER(15);
 	 l_set_of_books_id      NUMBER(15);
 	 l_org_id				NUMBER(15);
 	 l_no_copies	        NUMBER(15);
	 l_printer_name 		VARCHAR2(240);
	 l_print_option 		BOOLEAN;
     	 l_report_conc_request_id  NUMBER(15);
     	 l_call_status 			BOOLEAN;
	 l_dphase 				VARCHAR2(80);
	 l_rphase 				VARCHAR2(80);
      	 l_dstatus 				VARCHAR2(80);
	 l_rstatus 				VARCHAR2(80);
         l_message 				VARCHAR2(80);

	 l_error_code 			NUMBER;
	 l_error_buf			VARCHAR2(1000);
BEGIN
    l_module_name 		:= g_module_name  || '.fv_ap_refund_populate';
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,		'Strat of the fv_ap_refund_populate Process');
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'p_set_of_books_id : ' || p_set_of_books_id) ;
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'p_org_id : ' 			|| p_org_id ) ;
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'p_gl_period_low : '   || p_gl_period_low) ;
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'p_gl_period_high : '  || p_gl_period_high) ;
    END IF;
    l_user_id     		:= fnd_global.user_id;
    l_conc_request_id 	:= fnd_global.conc_request_id;
    l_set_of_books_id   := p_set_of_books_id;
    l_org_id            := p_org_id;
    -- Get the start Date GL_PERIOD_LOW and End Date of GL_PERIOD_HIGH
    BEGIN
    	SELECT 		start_date
    	    INTO 	l_gl_start_date
    		FROM 	gl_period_statuses
    		WHERE   ledger_id = l_set_of_books_id
    		AND 	application_id  = 101
    		AND     period_name     = p_gl_period_low;
		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   	 	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Start Date for the period low is : ' ||
	   	 							 l_gl_start_date ) ;
  	  	END IF;
    EXCEPTION
    	WHEN NO_DATA_FOUND THEN
    		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
    					'Error in getting Start Date for the period Low ' ) ;
    		RAISE;
    END;
    BEGIN
    	SELECT 		end_date
    	    INTO 	l_gl_end_date
    		FROM 	gl_period_statuses
    		WHERE   ledger_id  = l_set_of_books_id
    		AND 	application_id  = 101
    		AND     period_name     = p_gl_period_high;
		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'End Date for the period low is : ' ||
	    						 l_gl_end_date ) ;
  	  	END IF;
    EXCEPTION
    	WHEN NO_DATA_FOUND THEN
    		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
    					'Error in getting End Date for the Period High ' ) ;
    		RAISE;
    END;

    -- Populate the the data from AP tables to FV table
    INSERT INTO FV_REFUNDS_VOIDS_ALL
  			  ( refunds_voids_id,
			    TYPE ,
			    invoice_id,
			    processed_flag,
			    set_of_books_id,
			    org_id,
			    conc_request_id,
			    last_update_date,
			    last_updated_by,
			    created_by,
			    creation_date,
			    last_update_login,
			    vendor_id,
			    vendor_site_id,
			    invoice_distribution_id,
			    distribution_line_number,
			    dist_code_combination_id ,
			    dist_amount,
			    check_id,
			    invoice_payment_id,
			    refund_amount,
			    refund_gl_date  ,
			    invoice_gl_date,
	   		    invoice_num,
			    vendor_name ,
			    vendor_site_code,
			    check_number,
			    refund_gl_period,
			    invoice_amount,
	   		    vendor_number,
			    obligation_date,
			    obligation_number
  		   	)
  			(
	SELECT  fv_refunds_voids_s.NEXTVAL,
	        'PAYABLE_REFUND',
	        api.invoice_id,
	        'N',
	        l_set_of_books_id,
	        l_org_id,
	        l_conc_request_id,
	        SYSDATE,
	        l_user_id,
	        l_user_id,
	        SYSDATE,
	        l_user_id,
	        api.vendor_id,
	 	api.vendor_site_id,
	        apid.invoice_distribution_id,
	 	apid.distribution_line_number ,
	        apid.dist_code_combination_id,
	        apid.amount,
	        apc.check_id,
	        apip.invoice_payment_id,
	        apip.amount refund_amount,
	        apc.check_date ,
	        api.gl_date,
	        api.invoice_num,
	        apc.vendor_name ,
	        apc.vendor_site_code,
	        apc.check_number,
	        apip.period_name,
	        api.invoice_amount,
	        (SELECT segment1   FROM po_vendors WHERE vendor_id = apc.vendor_id),
	        DECODE(apid.po_distribution_id,
	                                    NULL,
	                                    DECODE(apid.parent_invoice_id,
	                                                                NULL,
	                                                                NULL,
	                                                                (SELECT invoice_date
		 			                                                     FROM  ap_invoices_all
	                                                                     WHERE invoice_id = apid.parent_invoice_id)),
	                                    (SELECT	 NVL(gl_encumbered_date,creation_date)
	                                         FROM  po_distributions
	                                         WHERE po_distribution_id = apid.po_distribution_id))
	                                                                  obligation_date,
	        DECODE(apid.po_distribution_id,
	                                    NULL,
	                                    DECODE(apid.parent_invoice_id,
	                                                                NULL,
	                                                                NULL,
	                                                                (SELECT invoice_num
		 			                                                     FROM  ap_invoices_all
	                                                                     WHERE invoice_id = apid.parent_invoice_id)),
	                                    (SELECT	 segment1
	                                         FROM  po_headers
	                                         WHERE po_header_id = (SELECT po_header_id
	                                         					   	FROM po_distributions
	                                         					WHERE po_distribution_id = apid.po_distribution_id)))
	                                                                  obligation_number
	FROM
	      ap_checks_all apc,
	      ap_invoice_payments_all  apip,
	      ap_invoices_all api,
	      ap_invoice_distributions_all apid
	WHERE apip.set_of_books_id 	= l_set_of_books_id
	AND   apip.set_of_books_id 	= api.set_of_books_id
	AND   api.set_of_books_id  	= apid.set_of_books_id
	AND   apc.org_id			= l_org_id
	AND   apc.org_id 			= apip.org_id
	AND   apip.org_id			= api.org_id
	AND   api.org_id			= apid.org_id
	AND   apc.check_id 			= apip.check_id
	AND   apip.invoice_id 		= api.invoice_id
	AND   api.invoice_id 		= apid.invoice_id
    	AND   api.invoice_type_lookup_code IN ( 'CREDIT','DEBIT')
	AND   apc.payment_type_flag = 'R'
	AND   apip.posted_flag 		= 'Y'
	AND   reversal_inv_pmt_id IS  NULL
	AND   ap_checks_pkg.get_posting_status(apc.check_id) IN ('Y','P')
	AND   TRUNC(apc.check_date) BETWEEN TRUNC(l_gl_start_date) AND TRUNC(l_gl_end_date)
	AND   NOT EXISTS
					( SELECT 1  FROM  fv_refunds_voids_all
								WHERE invoice_payment_id = apip.invoice_payment_id)
	AND   EXISTS (SELECT 1
                      FROM gl_je_lines gljl,
                           gl_je_headers gljh,
                           ap_invoice_distributions_all apid
                      WHERE gljl.ledger_id = apid.set_of_books_id
                        AND gljl.status = 'P'
                        AND gljh.je_header_id = gljl.je_header_id
                        AND gljh.je_from_sla_flag = 'N'
                        AND gljl.code_combination_id = apid.DIST_CODE_COMBINATION_ID
                        AND apid.invoice_id = api.invoice_id
                        AND gljl.reference_2 = TO_CHAR(api.invoice_id)
                      UNION
                      SELECT 1
                      FROM gl_je_lines gljl,
                           gl_je_headers gljh,
                           gl_import_references glir,
                           xla_ae_lines xal,
                           xla_distribution_links xdl,
                           ap_invoice_distributions_all apid
                      WHERE gljl.ledger_id = apid.set_of_books_id
                        AND glir.je_batch_id = gljh.je_batch_id
                        AND glir.je_header_id = gljh.je_header_id
                        AND glir.je_line_num = gljl.je_line_num
                        AND gljl.status = 'P'
                        AND gljh.je_header_id = gljl.je_header_id
                        AND gljh.je_from_sla_flag = 'Y'
                        AND gljh.je_source = 'Payables'
                        AND xal.gl_sl_link_id = glir.gl_sl_link_id
                        AND xal.gl_sl_link_table = glir.gl_sl_link_table
                        AND xdl.ae_header_id = xal.ae_header_id
                        AND xdl.ae_line_num = xal.ae_line_num
                        AND xdl.source_distribution_id_num_1 = apid.invoice_distribution_id
                        AND gljl.code_combination_id = apid.DIST_CODE_COMBINATION_ID
                        AND apid.invoice_id = api.invoice_id
                       )

	);
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'No of Rows inserted into the FV table : '
								||		 SQL%ROWCOUNT ) ;
    END IF;
    COMMIT;
    -- Call the report to display the data populated by the process
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
 							'SUBMITTING FMS 224 Populate Payables Refunds Process  Report .....') ;
    END IF;
    SELECT printer,
           number_of_copies
    INTO   l_printer_name,
           l_no_copies
    FROM   fnd_concurrent_requests
    WHERE  request_id = l_conc_request_id  ;

    l_print_option := FND_REQUEST.SET_PRINT_OPTIONS(printer => l_printer_name, copies  => l_no_copies) ;
    -- Submit the Report
    l_report_conc_request_id :=	FND_REQUEST.SUBMIT_REQUEST ('FV','FVAPRFPR','','',FALSE,
    															l_conc_request_id,l_set_of_books_id,
    															l_org_id,p_gl_period_low,p_gl_period_high);
    	IF l_report_conc_request_id  = 0 THEN
	    	retcode := -1 ;
      		errbuf  := 'ERROR SUBMITTING FMS 224 Populate Payables Refunds Process  Report. ';
		    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
		    			'ERROR SUBMITTING FMS 224 Populate Payables Refunds Process  Report. ') ;
		    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 				FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
 						 'Deleting all the Data from FV table inserted by the current process') ;
		    END IF;
		    DELETE  FROM fv_refunds_voids_all
		    		WHERE TYPE = 'PAYABLE_REFUND' AND conc_request_id = l_conc_request_id;
		    		COMMIT;
		    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 				FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
 						'No of Rows Deleted from FV table : ' || SQL%ROWCOUNT ) ;
		    END IF;
		END IF;
EXCEPTION
	WHEN OTHERS THEN
		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception','When Others Exception') ;
    		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception','Error Code : ' ||
    					 SQLCODE) ;
	    	FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception','Error Mesg : ' ||
	    				 SQLERRM) ;
		errbuf    := SQLERRM;
    		retcode   := SQLCODE;
END fv_ap_refund_populate;

----------------------------------------------------------------------
--				END OF PACKAGE BODY
----------------------------------------------------------------------
BEGIN
   initialize_global_variables;
END FV_SF224_TRANSACTIONS;

/
