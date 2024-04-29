--------------------------------------------------------
--  DDL for Package Body PAAPIMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAAPIMP_PKG" AS
/* $Header: PAAPIMPB.pls 120.81.12010000.22 2010/04/21 07:09:28 jjgeorge ship $ */

/*------------------Main Procedure-------------------------------------------*/
/* Added for Bug # 2138340 */
p_trans_import_failed varchar2(1) := 'N';    /* package level var for detecting if trans import ever failed */
g_body_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
--g_body_debug_mode varchar2(1) := 'Y';

/* 3917045 : This variable holds the value of the request parameter 'Interface Supplier Invoices' */
G_PROCESS_INVOICES VARCHAR2(1) := 'Y';

FUNCTION ReceiptPaAdditionFlag(p_Pa_Addition_Flag      IN VARCHAR2,
                               p_Po_Distribution_Id    IN NUMBER)
                              RETURN VARCHAR2 ;

PROCEDURE PAAPIMP ( errbuf                  OUT NOCOPY VARCHAR2,
                    retcode                 OUT NOCOPY VARCHAR2,
        	    invoice_type            IN  VARCHAR2,
                    project_id              IN  NUMBER,
                    batch_name              IN  VARCHAR2,
                    gl_date_arg             IN  VARCHAR2,
                    transaction_date_arg    IN  VARCHAR2,
                    debug_mode              IN  VARCHAR2,
                    process_invoices        IN  VARCHAR2,
                    process_receipts        IN  VARCHAR2,
                    process_discounts       IN  VARCHAR2,
                    output_type             IN  NUMBER
                    ) IS

     result               NUMBER;
     gl_date              DATE;
     transaction_date     DATE;
     lv_method            VARCHAR2(15);
     completion_status    BOOLEAN; -- Added for Bug # 2114086
     l_process_invoices   VARCHAR2(1);
     l_process_receipts   VARCHAR2(1);
     l_process_discounts  VARCHAR2(1);
     l_run  VARCHAR2(15);


BEGIN

     write_log(LOG, 'Invoice Type: '||invoice_type);
     write_log(LOG, 'Project Id: '||to_char(project_id));
     write_log(LOG, 'GL Date: '||gl_date_arg);
     write_log(LOG, 'TR date: '||transaction_date_arg);
     write_log(LOG, 'Debug Mode: '||debug_mode);
     write_log(LOG, 'Process Invoices: '||process_invoices);
     write_log(LOG, 'Process Receipts: '||process_receipts);
     write_log(LOG, 'Process Discounts: '||process_discounts);

     /* Setting PASSED IN parameters as local variables */
     l_process_invoices := nvl(process_invoices,'Y');
     l_process_receipts := nvl(process_receipts,'N');
     l_process_discounts := nvl(process_discounts,'N');
     G_PROCESS_INVOICES := l_process_invoices; /* 3917045 */

     G_err_stage := 'CHANGING VARCHAR2 TO DATE';
     gl_date := fnd_date.canonical_to_date(gl_date_arg);
     transaction_date := fnd_date.canonical_to_date(transaction_date_arg);

     G_err_stage := 'ASSIGNING LOCK NAME';
     G_LOCK_NAME := 'PAAPIMP';

     /*
     -- VI enhancment Check if we're transferring expense report type invoices or vendor invoices.
     -- Then nitialize global variables accordingly
     */

     IF invoice_type = 'EXPENSE REPORT' THEN

        If g_body_debug_mode = 'Y' Then
        write_log(LOG, 'This process transfers Invoice Type: Expense Report');
        End if;

        Initialize_Global(
                        p_project_id           => project_id,
                        p_batch_name           => batch_name,
                        p_gl_date              => gl_date,
                        p_transaction_date     => transaction_date,
                        p_debug_mode           => debug_mode,
                        p_output               => output_type,
                        p_invoice_source1      => 'XpenseXpress',
                        p_invoice_source2      => 'Manual Invoice Entry',
                        p_invoice_source3      => 'SelfService',
                        p_invoice_type         => 'EXPENSE REPORT',
                        p_system_linkage       => 'ER',
                        p_process_receipts     => l_process_receipts);

     ELSE

        If g_body_debug_mode = 'Y' Then
        write_log(LOG, 'This process transfers Invoice Type: Supplier Invoice');
        End If;

        Initialize_Global(
                         p_project_id => project_id,
                         p_batch_name => batch_name,
                         p_gl_date => gl_date,
                         p_transaction_date => transaction_date,
                         p_debug_mode => debug_mode,
                         p_output => output_type,
                         p_invoice_type => NULL,
                         p_system_linkage => 'VI',
                         p_process_receipts => l_process_receipts);

     END IF; /* expense type = expense report */

     If g_body_debug_mode = 'Y' Then
         write_log(LOG,'Process invoices? : ' || l_process_invoices);
         write_log(LOG,'Process receipts? : ' || l_process_receipts);
         write_log(LOG,'Process discounts? :' || l_process_discounts);
     End If;

     -- Cleanup all the pending transactions in any previous runs.

     If g_body_debug_mode = 'Y' Then
         G_err_stage := 'Before calling cleanup';
         write_log(LOG, G_err_stage);
     End If;

     cleanup();

 --    savepoint paapimp ; /* Added savepoint for 3922679 */

     If g_body_debug_mode = 'Y' Then
           write_log(LOG,'Current Org ID is:'||G_ORG_ID);
     End If;

     IF l_process_receipts = 'Y' THEN
       IF PA_UTILS4.get_ledger_cash_basis_flag = 'N' THEN

        G_err_stage := 'Before calling Net Zero Ad of RCV Transctions';
        If g_body_debug_mode = 'Y' Then
               write_log(LOG, G_err_stage);
        End If;

        -- Net_Zero_Adj_Po(); This logic is now implemented in PO at the time of receipt creation. Bug#4565757.

        If g_body_debug_mode = 'Y' Then
             G_err_stage := 'Before call to mark_RCV_PAflag';
             write_log(LOG, G_err_stage);
        End If;

        Mark_RCV_PAflag();

        IF (G_RCV_TRANSACTIONS_MARKED_O > 0) THEN

            G_err_stage :=  'Before calling transfer receipts to pa procedure';
            If g_body_debug_mode = 'Y' Then
                 write_log(LOG, 'No rcv transctions to be transferred.');
            End If;

            transfer_receipts_to_pa;
        ELSE
            G_err_stage :=  'No rcv transctions to be transferred.';
            If g_body_debug_mode = 'Y' Then
                 write_log(LOG, G_err_stage);
            End If;
            NULL;
        END IF;
       ELSE
        G_err_stage := 'Not pulling Receipts for Cash Basis Accounting ';
        If g_body_debug_mode = 'Y' Then
               write_log(LOG, G_err_stage);
        End If;
       END IF;  -- get_ledger_cash_basis_flag = N
     END IF;  -- l_process_receipts = 'Y'

     --Added for performance improvement. SELECT the value of assets_addition_flag into
     --a global variable that can be used throughout the program

     IF G_PROJECT_ID IS NOT NULL AND
        (l_process_invoices  = 'Y' OR l_process_discounts ='Y') THEN

        If g_body_debug_mode = 'Y' Then
        write_log(LOG,'G_Project_ID is not NULL,:'||G_PROJECT_ID||' getting assets_addition_flag.');
        End If;

        SELECT decode(PTYPE.Project_Type_Class_Code,'CAPITAL','P','X')
          INTO G_Assets_Addition_flag
          FROM pa_project_types_all PTYPE,
               pa_projects_all PROJ
         WHERE PTYPE.Project_Type = PROJ.Project_Type
           AND (PTYPE.org_id = PROJ.org_id OR
                PROJ.org_id is null)
           AND PROJ.Project_Id = G_PROJECT_ID;

     END IF;

     --
     -- Process invoices
     --
     IF l_process_invoices = 'Y' THEN

        /*============================================================*/
        /* BEGIN AMOUNT VARIANCE PROCESSING                           */
        /*============================================================*/
        If g_body_debug_mode = 'Y' Then
              G_err_stage:= 'Callng mark_inv_var_paflag';
              write_log(LOG,   G_err_stage);
        End If;

        -- Procedure MARK_INV_VAR_PAFLAG will update the inv dist status to either G or W values for both CASH (Historical only) and ACCRUAL
          -- This procedure will update invoice dist to status W for processing the amount variance into Oracle Projects

        mark_inv_var_paflag;


        IF G_NUM_AP_VARIANCE_MARKED_W > 0 THEN

           transfer_inv_var_to_pa;

        ELSE
           If g_body_debug_mode = 'Y' Then
           write_log(LOG,'No invoice variances to be processed');
           End If;
        END IF;

        /*=================================================================*/
        /* BEGIN INVOICE PROCESSING FOR CASH (Historical only) AND ACCRUAL */
        /*=================================================================*/
        If g_body_debug_mode = 'Y' Then
        G_err_stage := 'Before calling Net Zero Ad';
        write_log(LOG, G_err_stage);
        End If;

        net_zero_adjustment();

        If g_body_debug_mode = 'Y' Then
        G_err_stage := 'Before call to mark_PAFlag_O';
        write_log(LOG, G_err_stage);
        End If;

        -- Procedure MARK_PAFLAG_O will update the inv dist staus to either G or O values for both CASH (Historical only)  and ACCRUAL
          -- This Procedure will also update valid Invoice Dist to status O for historical invoices for CASH BASED ACCTNG
          -- This procedure will also update valid Invoice Dist to status O for ACCRUAL BASED ACCTNG

        mark_PAflag_O();

        IF (G_DISTRIBUTIONS_MARKED > 0) THEN
            transfer_inv_to_pa();
        ELSE
        If g_body_debug_mode = 'Y' Then
            write_log(LOG, 'No invoice distribution to be transferred.');
        End If;
        END IF;

        --
        /*============================================================*/
        /* BEGIN PAYMENT PROCESSING FOR CASH ACCTNG                   */
        /*============================================================*/
        -- For CAsh BAsis process Payments

        IF G_ACCTNG_METHOD = 'C' THEN

          If g_body_debug_mode = 'Y' Then
          G_err_stage := 'Before calling Net Zero Ad for Payments';
          write_log(LOG, G_err_stage);
          End If;

          net_zero_pay_adjustment();

          If g_body_debug_mode = 'Y' Then
               G_err_stage := 'Before call to mark_PA_Pay_flag_O';
               write_log(LOG, G_err_stage);
          End If;

          mark_PA_Pay_flag_O();

          IF (G_PAY_DISTRIBUTIONS_MARKED > 0) THEN
              transfer_pay_to_pa();
          ELSE
           If g_body_debug_mode = 'Y' Then
              write_log(LOG, 'No Invoice Payment distributions to be transferred.');
           End If;
          END IF;

       END IF;  /* Cash BAsed Acctng */

     END IF; /* process invoices = 'Y' */

     If g_body_debug_mode = 'Y' Then
     G_err_stage := 'after transferring invoices. Begin Discount processing';
     write_log(LOG, G_err_stage);
     End If;

     /*============================================================*/
     /* BEGIN DISCOUNT PROCESSING                                  */
     /*============================================================*/
     -- Process discounts as cost in Cash Basis flow automatically. Bug#5137211.
     IF (l_process_discounts = 'Y' OR G_ACCTNG_METHOD = 'C' ) THEN

           --Modified the to_date to fnd_date.canonical_to_date - Bug 4522045
           G_Profile_Discount_Start_date:=fnd_date.canonical_to_date(return_profile_discount_date);

           -- Get the discount Method.
           G_Discount_Method:=PAAPIMP_PKG.return_discount_method;

           If g_body_debug_mode = 'Y' Then
           write_log(LOG,'the profile discount start date is:'||to_char(G_Profile_Discount_Start_date));
           write_log(LOG,'Only transactions after the profile start date will be pulled.');
           End If;

           mark_PA_disc_flag_O();

           IF (G_DISC_DISTRIBUTIONS_MARKED > 0) THEN
               transfer_disc_to_pa();
           ELSE
            If g_body_debug_mode = 'Y' Then
               write_log(LOG, 'No Discount distributions to be transferred.');
            End If;
           END IF;

           If g_body_debug_mode = 'Y' Then
           G_err_stage:= 'after transferring discounts';
           write_log(LOG, G_err_stage);
           End If;

     END IF;  /* process discounts */

     G_err_stage := 'RELEASING LOCK HANDLE';
     result := dbms_lock.release(G_LOCKHNDL);

     G_err_stage := 'PRINT STAT AND SUBMIT REPORT';
     print_stat_and_submit_report();

     IF p_trans_import_failed = 'Y' THEN
           write_log(LOG, 'p-trans-import-failed');
        completion_status  := fnd_concurrent.set_completion_status('ERROR', SQLERRM);
     END IF;
     COMMIT; /* Added commit: 3922679 removed intermediate commits*/

EXCEPTION
     WHEN E_DIFFERENT_SOB THEN
          write_log(LOG, 'Please check your settings.  AP and PA use different set of books.');
     WHEN OTHERS THEN
          write_log(LOG,'Error occured in stage: ' || G_err_stage || ', PAAPIMP aborted!');
          write_log(LOG, substr(SQLERRM, 1, 200));

          IF (G_err_stage <> 'RELEASING LOCK HANDLE') THEN
                    result := dbms_lock.release(G_LOCKHNDL);
          END IF;
          print_stat_and_submit_report();

          /* Here the return value (TRUE/FALSE) is not being
             checked, as the concurrent request calls this main procedure
             and we are in the when others exception of this procedure. */

            completion_status := fnd_concurrent.set_completion_status('ERROR', SQLERRM);


END PAAPIMP;

/*------------------Init Phase-----------------------------------------------*/
   /* VI enhancements */
PROCEDURE Initialize_Global (
   p_project_id IN NUMBER,
   p_batch_name IN VARCHAR2,
   p_gl_date IN DATE,
   p_transaction_date IN DATE,
   p_debug_mode IN VARCHAR2,
   p_output IN NUMBER,
   /* IC Upgrade: transaction source variables are now initialize after we fetched
      the record from the cursor
   P_transaction_source IN pa_transaction_interface.transaction_source%TYPE,
   p_user_transaction_source IN pa_transaction_interface.user_transaction_source%TYPE,*/
   p_invoice_source1 IN ap_invoices.source%TYPE,
   p_invoice_source2 IN ap_invoices.source%TYPE,
   p_invoice_source3 IN ap_invoices.source%TYPE,
   p_invoice_type IN ap_invoices.invoice_type_lookup_code%TYPE,
   p_system_linkage IN pa_transaction_interface.system_linkage%TYPE,
   p_process_receipts IN VARCHAR2
   ) IS

   v_interface_id    NUMBER;
   v_commit_size    VARCHAR2(20);
   v_old_stack      VARCHAR2(630);
   G_AP_SOB         NUMBER;
   G_PA_SOB         NUMBER;
   G_PO_SOB         NUMBER;
   l_process_receipts VARCHAR2(1);

BEGIN

   /* Initialize the type of output procedure to use.*/
   G_OUTPUT := p_output;

   If p_debug_mode = 'Y' Then
   write_log(LOG, '....Entering Init Phase ....');
   End If;

   /* Initialize all logging and debugging variables */
   v_old_stack := G_err_stack;
   G_err_stack := G_err_stack || '->PAAPIMP_PKG.Initialize_Global';
   G_err_code := 0;

   If p_debug_mode = 'Y' Then
   write_log(LOG, G_err_stack);
   End If;

   /* Initialize debug level */
   IF (p_debug_mode = 'Y') THEN

      pa_debug.debug_level := pa_debug.DEBUG_LEVEL_TIMING;
      --ALTER SESSION SET SQL_TRACE = TRUE;

   END IF;

   /* MC Upgrade */
   /* 1.Check if AP and PA have same set of books.
      2.Get Accounting Currency
    */

    G_err_stage := 'Check AP, PO, and PA set of books';
    SELECT ap.set_of_books_id,
           pa.set_of_books_id
      INTO G_AP_SOB,
           G_PA_SOB
      FROM ap_system_parameters ap,
           pa_implementations pa;

    IF (G_AP_SOB <> G_PA_SOB) THEN

        raise E_DIFFERENT_SOB;

    END IF;

    l_process_receipts:=p_process_receipts;
   If p_debug_mode = 'Y' Then
    write_log(LOG,' process receipts?'||l_process_receipts);
   End If;

    IF l_process_receipts = 'Y' THEN

        G_err_stage := ' Check PO and PA set of books';

        SELECT po.set_of_books_id
          INTO G_PO_SOB
          FROM financials_system_parameters po;

        IF G_PO_SOB <> G_PA_SOB THEN

           RAISE E_DIFFERENT_SOB;

        END IF;

    END IF;

    G_err_stage := 'Calling Get_acct_currency_code API';
    G_ACCT_CURRENCY_CODE := pa_multi_currency.get_acct_currency_code();

   /* ----------------------------------------------------------------------*/

   /* Initialize global variables from parameters */

    G_PROJECT_ID          := p_project_id;
    G_GL_DATE             := p_gl_date;
    G_TRANSACTION_DATE    := p_transaction_date;
    G_DEBUG_MODE          := p_debug_mode;
    G_BODY_DEBUG_MODE     := p_debug_mode;
    G_INVOICE_SOURCE1     := p_invoice_source1;
    G_INVOICE_SOURCE2     := p_invoice_source2;
    G_INVOICE_SOURCE3     := p_invoice_source3;

    IF   PA_UTILS4.get_ledger_cash_basis_flag = 'N' THEN
      G_ACCTNG_METHOD := 'A';
--write_log(LOG,'Accounting Method is Accrual');
    ELSE
      G_ACCTNG_METHOD := 'C';
--write_log(LOG,'Accounting Method is CAsh');
    END IF;



   -- Bug 2242588
   -- Populate value of G_request_ID to create batch names

   G_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID();

   /* Check if user has given a batch name, if yes, use it, otherwise
      create a new batch name */

   IF (p_batch_name IS NULL) THEN

      G_BATCH_NAME := create_new_batch_name();

      G_NRT_BATCH_NAME := 'APNRT-'||G_UNIQUE_ID;

  -- Added for AP discounts
      G_DISC_BATCH_NAME :='APDISC-'||G_UNIQUE_ID;

   --Added for AP Variance
      G_AP_VAR_BATCH_NAME   :='APVAR-'||G_UNIQUE_ID;

   --Added for AP ERV
      G_AP_ERV_BATCH_NAME   :='APERV-'||G_UNIQUE_ID;

   --Added for AP Freight
      G_AP_FRT_BATCH_NAME   :='APFRT-'||G_UNIQUE_ID;  --NEW

   --Added for Prepay
     G_PREPAY_BATCH_NAME   :='APPPAY-'||G_UNIQUE_ID;  --NEW

  -- Added for Receipts
     G_RCV_BATCH_NAME    := 'RCV-'||G_UNIQUE_ID;
     G_RCVTAX_BATCH_NAME := 'RCVNRT-'||G_UNIQUE_ID;

   ELSE

      G_BATCH_NAME        := p_batch_name;
      G_NRT_BATCH_NAME    := p_batch_name;
      G_DISC_BATCH_NAME   := p_batch_name;
      G_AP_VAR_BATCH_NAME := p_batch_name;
      G_AP_ERV_BATCH_NAME := p_batch_name;
      G_AP_FRT_BATCH_NAME := p_batch_name;
      G_PREPAY_BATCH_NAME := p_batch_name;
      G_RCV_BATCH_NAME    := p_batch_name;
      G_RCVTAX_BATCH_NAME := p_batch_name;

   END IF;


   write_validate_param_log();

   /* IC Upgrade
      We will be initializing transaction source
      variables in 'insert_into_trans_intf' API */

   G_INVOICE_TYPE := p_invoice_type;

   If p_debug_mode = 'Y' Then
   write_log(LOG,'The invoice type is:' ||G_INVOICE_TYPE);
   End If;

   G_SYSTEM_LINKAGE := p_system_linkage;

   /* Fetch Profile Variables */
   fetch_pf_var(p_process_receipts => l_process_receipts);

   G_err_stage := 'GET ORGINAZATION ID';
   /* SELECT NVL(org_id, -99) commented for bug#2488576,removed nvl */
     SELECT org_id
     INTO G_ORG_ID
     FROM pa_implementations;

   /* initialize global count variables */
   G_NUM_BATCHES_PROCESSED := 0;
   G_NUM_INVOICES_PROCESSED := 0;
   G_NUM_DISTRIBUTIONS_PROCESSED := 0;
   G_DISTRIBUTIONS_MARKED := 0;
   G_PAY_DISTRIBUTIONS_MARKED := 0;

   -- Added for AP discounts
   G_NUM_DISCOUNTS_PROCESSED :=0;

   --Added for AP Variance
   G_NUM_AP_VARIANCE_MARKED_W    :=0;
   G_NUM_AP_VARIANCE_PROCESSED :=0;

   --Added for PO RECEIPT
   G_RCV_TRANSACTIONS_MARKED_O    :=0;
   G_RCV_TRANSACTIONS_MARKED_J    :=0;
   G_RCV_TRANSACTIONS_MARKED_NULL :=0;
   G_RCV_TRANSACTIONS_MARKED_G    :=0;
   G_NUM_RCV_TXN_PROCESSED        :=0;
   G_NUM_RCVTAX_PROCESSED         :=0;

   /* restore the old G_err_stack */
   G_err_stack := v_old_stack;

EXCEPTION

   WHEN E_DIFFERENT_SOB THEN
      RAISE;

   WHEN Others THEN

      G_err_stack := v_old_stack;
      G_err_code := SQLCODE;
      RAISE;

END Initialize_Global;

PROCEDURE fetch_pf_var(p_process_receipts IN VARCHAR2 ) IS
--PROCEDURE fetch_pf_var IS

   v_old_stack VARCHAR2(630);
   v_commit_size VARCHAR2(30);

BEGIN

   v_old_stack := G_err_stack;
   G_err_stack := G_err_stack || '->PAAPIMP_PKG.fetch_pf_var';
   G_err_stage := 'FETCHING PROFILE VARIABLES';

   If g_body_debug_mode = 'Y' Then
   write_log(LOG, G_err_stack);
   End If;

   G_USER_ID := FND_GLOBAL.USER_ID();
   G_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID();
   G_PROG_APPL_ID := FND_GLOBAL.PROG_APPL_ID();
   G_PROG_ID := FND_GLOBAL.CONC_PROGRAM_ID();
   G_LOGIN_ID := FND_GLOBAL.CONC_LOGIN_ID();

   /* Get commit cycle size */
   /* VI enhancment: Check the G_INVOICE_TYPE variable to see
      which invoice type we're transferring, then initialize
      the profile name global variable accordingly */

   IF G_INVOICE_TYPE = 'EXPENSE REPORT' THEN

      G_PROFILE_NAME := 'PA_NUM_WEB_EXP_PER_SET';

   ELSE

      G_PROFILE_NAME := 'PA_NUM_EXP_ITEMS_PER_SET';

   END IF;

   G_err_stage := 'FETCHING PROFILE OPTION: COMMIT SIZE';
   fnd_profile.get(G_PROFILE_NAME, v_commit_size);

   G_COMMIT_SIZE := to_number(v_commit_size);

   IF (G_COMMIT_SIZE <= 0) THEN

   If g_body_debug_mode = 'Y' Then
      write_log(LOG, 'Please verify the value of profile option PA: Web Expense Invoices Per Set.  Current value is: ' || to_char(G_COMMIT_SIZE));
      write_log(LOG, 'Commit Size set to default value: 500');
G_COMMIT_SIZE := 500;
  End If;
   END IF;

   If g_body_debug_mode = 'Y' Then
    write_log(LOG, 'Expense Invoices Per Set.  Current value is: ' || to_char(G_COMMIT_SIZE));  /* Bug # 2138340 */
   End If;

   /* Get the profile option of whether to transfer DFF from AP */
   G_err_stage := 'FETCHING PROFILE OPTION: TRANS DFF FROM AP';

   G_PROFILE_NAME := 'PA_TRANSFER_DFF_AP';
   fnd_profile.get(G_PROFILE_NAME, G_TRANS_DFF_AP);
   If g_body_debug_mode = 'Y' Then
   write_log(LOG,'Processing DFFs for AP?'||G_TRANS_DFF_AP);
   End If;
   IF p_process_receipts = 'Y' THEN

     G_PROFILE_NAME := 'PA_TRANSFER_DFF_PO';
     fnd_profile.get(G_PROFILE_NAME, G_TRANS_DFF_PO);
   If g_body_debug_mode = 'Y' Then
     write_log(LOG,'Processing DFFs for PO?'||G_TRANS_DFF_PO);
   End if;
   END IF;

   G_err_stack := v_old_stack;

EXCEPTION
   WHEN Others THEN

      G_err_stack := v_old_stack;
      G_err_code := SQLCODE;
      RAISE;

END fetch_pf_var;

FUNCTION create_new_batch_name
   RETURN pa_transaction_interface.batch_name%TYPE IS

   v_old_stack VARCHAR2(630);
   v_new_batch_name pa_transaction_interface.batch_name%TYPE;
   v_interface_id   NUMBER;

BEGIN

   v_old_stack := G_err_stack;
   G_err_stack := G_err_stack || '->PAAPIMP_PKG.create_new_batch_name';
   G_err_stage := 'CREATING NEW BATCHNAME';

   If g_body_debug_mode = 'Y' Then
   write_log(LOG, G_err_stack);
   End If;

   --Getting a unique sequence for batch name from interface_id
   SELECT pa_interface_id_s.nextval
     into v_interface_id
     FROM dual;

   G_UNIQUE_ID := v_interface_id;

   v_new_batch_name :=  'AP-' ||G_UNIQUE_ID;

   If g_body_debug_mode = 'Y' Then
   write_log(LOG, 'New Batch Name: ' || v_new_batch_name);
   End If;

   G_err_stack := v_old_stack;

   RETURN v_new_batch_name;

EXCEPTION

WHEN Others THEN

   G_err_stack := v_old_stack;
   G_err_code := SQLCODE;
   RAISE;


END create_new_batch_name;


PROCEDURE write_validate_param_log IS

   v_old_stack Varchar2(630);

BEGIN

	v_old_stack := G_err_stack;
	G_err_stack := G_err_stack || '->PAAPIMP_PKG.write_validate_param_log';
	G_err_stage := 'WRITE PARAMETERS TO LOG';

   If g_body_debug_mode = 'Y' Then
	pa_debug.debug(G_err_stack);
   End If;

   IF (G_OUTPUT = G_OUTPUT_SQLPLUS) THEN
			NULL;
		ELSIF (G_OUTPUT = G_OUTPUT_SQLPLUS) THEN
	If g_body_debug_mode ='Y' Then
         pa_debug.debug('Validated parameters are as follows:');
         pa_debug.debug('  Parameter1  - Project ID                   : ' || G_PROJECT_ID);
			pa_debug.debug('  Parameter2  - Batch Name                   : ' || G_BATCH_NAME);
         pa_debug.debug('  Parameter3  - GL Date through              : ' || to_char(G_GL_DATE));
         pa_debug.debug('  Parameter4  - Transaction Date through     : ' || to_char(G_TRANSACTION_DATE));
         pa_debug.debug('                     ');
         pa_debug.debug('Other relevant information:');
         pa_debug.debug('  User ID          = ' || to_char(G_USER_ID));
         pa_debug.debug('  Request ID       = ' || to_char(G_REQUEST_ID));
         pa_debug.debug('  Program ID       = ' || to_char(G_PROG_ID));
         pa_debug.debug('  Login ID         = ' || to_char(G_LOGIN_ID));
       End If;
		ELSIF (G_OUTPUT = G_OUTPUT_FND) THEN
	If g_body_debug_mode ='Y' Then
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Validated parameters are as follows:');
         FND_FILE.PUT_LINE(FND_FILE.LOG, '  Parameter1  - Project ID                   : ' || G_PROJECT_ID);
			FND_FILE.PUT_LINE(FND_FILE.LOG, '  Parameter2  - Batch Name                   : ' || G_BATCH_NAME);
         FND_FILE.PUT_LINE(FND_FILE.LOG, '  Parameter3  - GL Date through              : ' || to_char(G_GL_DATE));
         FND_FILE.PUT_LINE(FND_FILE.LOG, '  Parameter4  - Transaction Date through     : ' || to_char(G_TRANSACTION_DATE));
         FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Other relevant information:');
         FND_FILE.PUT_LINE(FND_FILE.LOG, '  User ID          = ' || to_char(G_USER_ID));
         FND_FILE.PUT_LINE(FND_FILE.LOG, '  Request ID       = ' || to_char(G_REQUEST_ID));
         FND_FILE.PUT_LINE(FND_FILE.LOG, '  Program ID       = ' || to_char(G_PROG_ID));
         FND_FILE.PUT_LINE(FND_FILE.LOG, '  Login ID         = ' || to_char(G_LOGIN_ID));
       End If;

      END IF;

	G_err_stack := v_old_stack;

EXCEPTION

   WHEN Others THEN  /* This exception is not fatal, so don't terminate the program. */

	G_err_stack := v_old_stack;
        G_err_code := SQLCODE;
        If g_body_debug_mode = 'Y' Then
        write_log(LOG,'Error occured in stage: ' || G_err_stage);
        write_log(LOG, substr(SQLERRM, 1, 200));
	end if;
END write_validate_param_log;


PROCEDURE write_log (
   p_message_type IN NUMBER,
   p_message IN VARCHAR2) IS

   buffer_overflow EXCEPTION;
   PRAGMA EXCEPTION_INIT(buffer_overflow, -20000);

BEGIN
--          dbms_output.put_line(p_message);
/*
   IF (p_message_type = LOG OR g_body_debug_mode = 'Y') THEN

      IF (G_OUTPUT = G_OUTPUT_SQLPLUS) THEN

         --dbms_output.put_line(p_message);
         NULL;

      ELSIF (G_OUTPUT = G_OUTPUT_PADEBUG) THEN

         pa_debug.debug(p_message);

      ELSIF (G_OUTPUT = G_OUTPUT_FND) THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(sysdate,'HH:MI:SS:   ')|| p_message);
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

      END IF;

   END IF;
*/
      FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(sysdate,'HH:MI:SS:   ')|| p_message);
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
EXCEPTION   /* When exception occurs, program needs to be aborted. */

   WHEN OTHERS THEN

      raise;

END write_log;

/*--------------------------Cleanup Phase--------------------------------------*/

PROCEDURE cleanup IS

        CURSOR paapimp_cur IS
        SELECT 'Y'
        FROM    fnd_concurrent_requests req,
                fnd_concurrent_programs prog,
                fnd_executables exe
        WHERE   req.program_application_id = prog.application_id
          AND   req.concurrent_program_id = prog.concurrent_program_id
          AND   req.phase_code = 'R'
	  AND	req.request_id <> G_REQUEST_ID
          AND   prog.executable_application_id = exe.application_id
          AND   prog.executable_id = exe.executable_id
          AND   exe.executable_name = 'PAAPIMP';

        timeout  integer := 0;
        lockmode integer := 6; /* exclusive lock */
        lrelease boolean := FALSE; /* Do not release on commit */
        lstatus   integer;
        paapimp_running  varchar2(1) := '';
	result integer;
	v_old_stack VARCHAR2(630);

      BEGIN

	v_old_stack := G_err_stack;
	G_err_stack := G_err_stack || '->PAAPIMP_PKG.cleanup';
	G_err_code := 0;
	G_err_stage := 'ALLOCATING LOCK';

        If g_body_debug_mode = 'Y' Then
	write_log(LOG, G_err_stack);
       	write_log(LOG, '......Trying to allocate for a lock');
        end if;
        /* get lock handle for PAAPIMP user lock */
	dbms_lock.allocate_unique(G_LOCK_NAME,G_LOCKHNDL,timeout);

	IF (G_LOCKHNDL IS NOT NULL) THEN
   		If g_body_debug_mode = 'Y' Then
		write_log(LOG, '......Lock created, trying to request for lock.');
		end if;

		G_err_stage := 'REQUESTING LOCK';

		/* Get the lock, do not release the lock on commit */
		lstatus := dbms_lock.request(G_LOCKHNDL, lockmode, timeout, lrelease);

          IF ( lstatus = 0 ) then /* Got the lock */
		G_err_stage := 'CHECKING IF PAAPIMP IS RUNNING';
   		If g_body_debug_mode = 'Y' Then
		write_log(LOG, '.....Request for lock granted, check if PAAPIMP is running.');
		end if;
            	OPEN paapimp_cur; /* Check if PAAPIMP is running */
            	FETCH paapimp_cur INTO paapimp_running;
            	CLOSE paapimp_cur;

            IF ( nvl(paapimp_running,'N') = 'N' ) THEN

              /* PAAPIMP is not running, So Clean up */
		If g_body_debug_mode = 'Y' Then
		write_log(LOG, '......Paapimp is not running, do cleanup');
		end if;
		G_err_stage := 'UPDATING INVOICE DISTRIBUTIONS';

	        UPDATE ap_invoice_distributions_all DIST
              	SET DIST.pa_addition_flag = 'N'
                  , DIST.request_id = G_REQUEST_ID
              	WHERE  DIST.pa_addition_flag IN ('O','W')
              	AND  DIST.posted_flag||''= 'Y'
              	AND  DIST.project_id >0
                AND  NOT EXISTS ( SELECT 'X'
                                   FROM pa_expenditure_items_all ei
				  WHERE ei.document_header_id = dist.invoice_id   /*Added for bug 6327185 */
                                    AND ei.document_distribution_id = dist.invoice_distribution_id
                                    AND ei.transaction_source in ('AP INVOICE','AP VARIANCE','AP NRTAX','AP EXPENSE')) ;

		If g_body_debug_mode = 'Y' Then
		write_log(LOG, 'Number of invoice distributions updated = ' || to_char(SQL%ROWCOUNT));
		end if;

                UPDATE ap_payment_hist_dists dist
                SET    dist.pa_addition_flag = 'N'
                     , DIST.request_id = G_REQUEST_ID
                WHERE  DIST.pa_addition_flag  = 'O'
                AND    dist.pay_dist_lookup_code = 'DISCOUNT'
                AND    EXISTS (SELECT NULL
                             FROM   ap_payment_history_all hist
                             WHERE  hist.payment_history_id = dist.payment_history_id
                             AND    hist.posted_flag = 'Y')
                AND    NOT EXISTS ( SELECT 'X'
                                     FROM pa_expenditure_items_all ei
                                    WHERE ei.document_distribution_id = dist.invoice_distribution_id
                                      AND ei.document_payment_id = dist.invoice_payment_id
                                      AND ei.transaction_source = 'AP DISCOUNTS') ;

                If g_body_debug_mode = 'Y' Then
                write_log(LOG, 'Number of discount distributions updated = ' || to_char(SQL%ROWCOUNT));
                end if;


                IF G_ACCTNG_METHOD = 'A' THEN

                --added the following for PO RECEIPT processing
                UPDATE rcv_receiving_sub_ledger rcv_sub
                   SET rcv_sub.pa_addition_flag = 'N'
                      ,rcv_sub.request_id       = G_REQUEST_ID
                 WHERE rcv_sub.pa_addition_flag = 'O'
                   AND NOT EXISTS (SELECT 'X'
                                    FROM pa_expenditure_items_all ei
                                    WHERE  ei.document_distribution_id = rcv_sub.rcv_transaction_id);

                If g_body_debug_mode = 'Y' Then
		write_log(LOG, 'Number of rcv txn cleaned up from O:' || to_char(SQL%ROWCOUNT));
		end if;

                UPDATE rcv_receiving_sub_ledger rcv_sub
                   SET rcv_sub.pa_addition_flag = 'I'
                 WHERE rcv_sub.pa_addition_flag = 'J';

                If g_body_debug_mode = 'Y' Then
		write_log(LOG, 'Number of rcv txn cleaned up from J:' || to_char(SQL%ROWCOUNT));
		end if;

                ELSE --Accounting method is CASH BASIS

                UPDATE ap_payment_hist_dists dist
                SET    dist.pa_addition_flag = 'N'
                     , DIST.request_id = G_REQUEST_ID
              	WHERE  DIST.pa_addition_flag  = 'O'
                AND    dist.pay_dist_lookup_code = 'CASH'
                AND    EXISTS (SELECT NULL
                             FROM   ap_payment_history_all hist
                             WHERE  hist.payment_history_id = dist.payment_history_id
                             AND    hist.posted_flag = 'Y')
                AND    NOT EXISTS ( SELECT 'X'
                                     FROM pa_expenditure_items_all ei
                                    WHERE ei.document_distribution_id = dist.invoice_distribution_id
                                      AND ei.document_payment_id = dist.invoice_payment_id
                                      AND ei.transaction_source = 'AP INVOICE') ;

		If g_body_debug_mode = 'Y' Then
		write_log(LOG, 'Number of payment distributions updated = ' || to_char(SQL%ROWCOUNT));
		end if;

                UPDATE ap_prepay_app_dists dist
                SET    dist.pa_addition_flag = 'N',
                       request_id = G_REQUEST_ID
                WHERE  dist.pa_addition_flag = 'O'
                AND    NOT EXISTS ( SELECT 'X'
                                     FROM pa_expenditure_items_all ei
                                     WHERE ei.document_distribution_id = dist.invoice_distribution_id
                                       AND ei.document_payment_id = dist.prepay_app_dist_id
                                       AND ei.transaction_source in ('AP INVOICE','AP VARIANCE','AP NRTAX','AP EXPENSE')) ;

		If g_body_debug_mode = 'Y' Then
		write_log(LOG, 'Number of prepayment appl distributions updated = ' || to_char(SQL%ROWCOUNT));
		end if;

                END IF;

		commit;

            ELSE
             	If g_body_debug_mode = 'Y' Then
		write_log(LOG, '......Got Lock,paapimp is running, No Clean Up ');
		end if;
            END IF;
          ELSE
            	If g_body_debug_mode = 'Y' Then
		write_log(LOG, '......Could not get lock, No Clean Up');
		end if;
          END IF;
	ELSE
		If g_body_debug_mode = 'Y' Then
		write_log(LOG, '......Did not create unique lock');
		end if;
        END IF;

	G_err_stack := v_old_stack;

EXCEPTION
        WHEN Others THEN
		G_err_stack := v_old_stack;
        	G_err_code := SQLCODE;
		raise;
END cleanup;


/*-----------------------Populate Transaction Interface Phase---------------------*/

/*---------------------------- get_mrc_flag --------------------------------------*/
/* This function will return 'Y' or 'N' depending upon whether MRC is used or not */
/* and ot will also populate a PL/SQL table with reporting set of books ids and   */
/* Reporting currencies                                                           */
/*--------------------------------------------------------------------------------*/

FUNCTION get_mrc_flag RETURN VARCHAR2 IS

CURSOR c_reporting_sob (p_set_of_books_id IN NUMBER,
                        p_org_id          IN NUMBER) IS
  SELECT ledger_id, currency_code
  FROM   gl_alc_ledger_rships_v
  WHERE  source_ledger_id = p_set_of_books_id
  AND    application_id = 275
  AND    org_id = p_org_id
  AND    relationship_enabled_flag = 'Y';

   l_sob NUMBER;
   l_org_id NUMBER;
   i BINARY_INTEGER := 0;
   v_old_stack VARCHAR2(630);

BEGIN

   v_old_stack := G_err_stack;
   G_err_stack := G_err_stack || '->PAAPIMP_PKG.get_mrc_flag';
   G_err_code := 0;

   If g_body_debug_mode = 'Y' Then
   write_log(LOG, G_err_stack);
   end if;

   G_err_stage := 'CALLING PA_MC_CURRENCY_PKG.SET_OF_BOOKS FUNCTION';
   l_sob      := pa_mc_currency_pkg.set_of_books;

   G_err_stage := 'GET ORG_ID IN GET_MRC_FLAG';
   SELECT NVL(org_id,-99)
     INTO   l_org_id
     FROM pa_implementations;

   If g_body_debug_mode = 'Y' Then
   write_log(LOG,'set of book id is:'||l_sob||'org_id is:'||l_org_id);
   end if;

   FOR v_rsob IN c_reporting_sob (l_sob, l_org_id) LOOP
   BEGIN

    	i := i + 1;
        -- Bug 988355: g_rsob_tab is declared in the PA_MC_CURRENCY_PKG
       PA_MC_CURRENCY_PKG.g_rsob_tab(i).rsob_id := v_rsob.ledger_id;
       	PA_MC_CURRENCY_PKG.g_rsob_tab(i).rcurrency_code := v_rsob.currency_code;

   EXCEPTION
      WHEN OTHERS THEN
	G_err_stack := v_old_stack;
	G_err_code := SQLCODE;
       	RAISE;
   END; -- Cursor END
   END LOOP; -- End of Loop for cursor

   G_err_stack := v_old_stack;

   IF i = 0 then
     RETURN 'N';
   ELSE
     RETURN 'Y';
   END IF;

END get_mrc_flag;


FUNCTION create_new_org_transref (
    p_batch_name IN pa_transaction_interface.batch_name%TYPE,
    p_invoice_id IN ap_invoices.invoice_id%TYPE,
    p_invoice_distribution_id IN ap_invoice_distributions.invoice_distribution_id%TYPE)
      RETURN  pa_transaction_interface.orig_transaction_reference%TYPE IS

BEGIN

    RETURN p_batch_name || '-' || to_char(p_invoice_id) || '-' || to_char(p_invoice_distribution_id, '099');

END create_new_org_transref;

PROCEDURE print_stat_and_submit_report IS

   req_id NUMBER;
   v_err_msg VARCHAR2(1000);
   v_old_stack VARCHAR2(630);

   l_number_of_copies NUMBER;
   l_print_style VARCHAR2(100);
   l_printer VARCHAR2(100);
   l_save_output_flag VARCHAR2(1);
   l_save_op_flag_bool boolean;
   result_print boolean;


BEGIN

   /* Initialize all logging and debugging variables */
   v_old_stack := G_err_stack;
   G_err_stack := G_err_stack || '->PAAPIMP_PKG.print_stat_and_submit_report';
   G_err_code := 0;
   If g_body_debug_mode = 'Y' Then
   write_log(LOG, G_err_stack);

   write_log(LOG, 'TOTAL NUMBER OF BATCHES PROCESSED: ' || to_char(G_NUM_BATCHES_PROCESSED));
   write_log(LOG, 'TOTAL NUMBER OF INVOICES PROCESSED: ' || to_char(G_NUM_INVOICES_PROCESSED));
   write_log(LOG, 'TOTAL NUMBER OF INVOICE DISTRIBUTIONS PROCESSED: ' || to_char(G_NUM_DISTRIBUTIONS_PROCESSED));
   write_log(LOG, 'TOTAL NUMBER OF DISCOUNTS PROCESSED: '|| to_char(G_NUM_DISCOUNTS_PROCESSED));
   write_log(LOG, 'TOTAL NUMBER OF RECEIPTS PROCESSED: '||to_char(G_NUM_RCV_TXN_PROCESSED));
   write_log(LOG, 'TOTAL NUMBER OF RECEIPT TAX PROCESSED:'||to_char(G_NUM_RCVTAX_PROCESSED));
   end if;

   IF (G_OUTPUT = G_OUTPUT_FND) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'TOTAL NUMBER OF INVOICES PROCESSED: ' || to_char(G_NUM_INVOICES_PROCESSED));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'TOTAL NUMBER OF INVOICE DISTRIBUTIONS PROCESSED: ' || to_char(G_NUM_DISTRIBUTIONS_PROCESSED));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'TOTAL NUMBER OF DISCOUNTS PROCESSED: '||to_char(G_NUM_DISCOUNTS_PROCESSED));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'TOTAL NUMBER OF RECEIPTS PROCESSED: '||to_char(G_NUM_RCV_TXN_PROCESSED));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'TOTAL NUMBER OF RECEIPT TAX PROCESSED: '||to_char(G_NUM_RCVTAX_PROCESSED));

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '----------------------------------------------------------------');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'For detail information of this interface, please review the following report.');
   END IF;

      result_print := FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(G_REQUEST_ID,l_number_of_copies,l_print_style,l_printer,
                      l_save_output_flag);
      IF l_save_output_flag = 'Y' THEN
         l_save_op_flag_bool := TRUE;
      ELSE l_save_op_flag_bool := FALSE;
      END IF;
      result_print := FND_REQUEST.SET_PRINT_OPTIONS(l_printer,l_print_style,l_number_of_copies,
                      l_save_op_flag_bool,'N');

      -- MOAC changes for R12
      FND_REQUEST.set_org_id(G_ORG_ID);

      /* submit request to print report */
      /* IC Upgrade: Since we may process mutiple transaction source at once, we can not
            submit the transaction source parameter */
      req_id := FND_REQUEST.SUBMIT_REQUEST('PA', 'PAAPIMPR', '', '', FALSE, '', /*G_TRANSACTION_SOURCE,*/
          G_SYSTEM_LINKAGE, '', G_REQUEST_ID);

     IF (req_id = 0) THEN
         --FND_MESSAGE.RAISE_ERROR;
	fnd_message.retrieve(v_err_msg);
         If g_body_debug_mode = 'Y' Then
        WRITE_LOG (LOG, '......Error in submitting request to print report......');
	WRITE_LOG (LOG, 'Error Message: ' || v_err_msg || ' END of message.');
	End if;
	IF (G_OUTPUT = G_OUTPUT_FND) THEN
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '...An attempt to submit the status report of the process has failed.');
	END IF;
     ELSE
         If g_body_debug_mode = 'Y' Then
	 WRITE_LOG( LOG, '......Request to print report submitted, Request ID: '
                              || to_char(req_id) || '......');
        end if;
		IF (G_OUTPUT = G_OUTPUT_FND) THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'A status report of this process has been submitted.  Request ID: '
					|| to_char(req_id));
		END IF;
      END IF;

      /* restore the old G_err_stack */
      G_err_stack := v_old_stack;

   EXCEPTION
      WHEN Others THEN
         G_err_stack := v_old_stack;
         G_err_code := SQLCODE;
         RAISE;

	END print_stat_and_submit_report;


PROCEDURE trans_import (
  p_transaction_source IN pa_transaction_interface.transaction_source%TYPE,
  p_batch_name  IN pa_transaction_interface.batch_name%TYPE,
  p_interface_id IN pa_transaction_interface.interface_id%TYPE,
  p_user_id IN NUMBER) IS

  v_old_stack VARCHAR2(630);
BEGIN

   v_old_stack := G_err_stack;
   G_err_stack := G_err_stack || '->PAAPIMP_PKG.trans_import';
   G_err_stage := 'TRANSACTION IMPORT';
   G_err_code := 0;

   write_log(LOG, '......Transaction Import Phase For ' || p_transaction_source);
   write_log(LOG, G_err_stack);
   savepoint import; /*savepoint added for bug 2138340. The data inserted into
                     transaction_interface table will be saved for further
                     use even if rollback occurs. */


   write_log(LOG,'log messages from transaction import ---------------------- ');
  -- Changed this to IMPORT from IMPORT1 for bug#
   PA_TRX_IMPORT.IMPORT(X_transaction_source =>p_transaction_source
                        ,X_batch => p_batch_name
                        , X_xface_id => p_interface_id
                        , X_userid =>p_user_id );

   G_err_stack := v_old_stack;
   /* added for bug 2138340 */
   write_log(LOG,'transaction import successful');


   EXCEPTION
      WHEN OTHERS THEN
         G_err_stack := v_old_stack;
         G_err_code := SQLCODE;
         write_log(LOG,'transaction import failed with sqlcode = ');
         write_log(LOG,   G_err_code);
         write_log(LOG, substr(SQLERRM, 1, 200));

        /* start changes for bug 2138340 */

        p_trans_import_failed := 'Y';

        ROLLBACK TO SAVEPOINT import; /* 2138340 - we will rollback whatever has been done by trx import */
        UPDATE pa_transaction_interface
           SET transaction_status_code = 'R',
               transaction_rejection_code = 'TRX_IMPORT_ABORTED'
         WHERE interface_id = p_interface_id
           AND transaction_status_code = 'P'
           AND transaction_source = p_transaction_source
           AND batch_name = p_batch_name;

       /* RAISE;   don't raise so that tieback can continue  */

END trans_import;

/*==========================================================================*/
--The following section contains procedures for Supplier Inovice and Expense
--Reports processing. The codes have compeletely changed for patchset K.
--Starting from patchset K, all the processing will be performed in PL/SQL
--tables within a certain batch size.
--The logic of Invoice processing can be undestood as:
-- 1) Update PA_addition_flag on AP Invoice distribution lines to 'Z' if sum of lines
--    net to zero
-- 2) Update PA_addition_flag on AP Invoice distribution lines to 'O' to lock the record
-- 3) Transfer_inv_to_pa populates PA transaction_interface table and call trx import
-- 4) Tieback procedure called to update invoice distribution lines after trx import

/*----------------------Net Zero Adjustment Phase----------------------*/
/*
--
-- This procedure marks the pa_addition_flag of all the invoice distributions
-- to 'Z' if based on the grouping condition their amount net out to zero.
-- The grouping columns used are
--
--  1. project_id
--  2. task_id
--  3. expenditure_type
--  4. expenditure_organization_id
--  5. expenditure_item_date
--  6. dist_code_combination_id
--  7. invoice_id
--  8. accounting_date
--  9. line_type_lookup_code
--
-- Invoice distributions whose pa_addition_flag is marked with 'Z' will not
-- be pulled to Projects.
--
*/


     /*
     --
     -- VI enhancments Check what type of invoices are we transferring and
     -- then do net zero adjustments accordingly.  If transferring expense
     -- report type invoices, then do net zero adjustment only for expense
     -- report type invoices.  If transferring vendor invoices then do net
     -- zero adjustments for all invoice types, like what PAVVIT has been
     -- doing.
     */

     /*  Bug 4193362
     --  Net Zero logic should not consider a line
     --  where po_distribution_id is populated and another line which does not have
     --  po_distribution_id. When project is enabled for budgetary control, this
     --  scenario will lead project commitment balances data corruption.
     --  So for grouping Net Zeroing lines, po_distribution_id should be considered.
     */

      --
      -- Bug 1594498
      -- Due to performance reasons the single update statement was
      -- broken up into two update statements based on if the program
      -- has the value of project id (If the user has given project number
      -- as one of the parameters).
      --


PROCEDURE net_zero_adjustment IS

   v_old_stack       	VARCHAR2(630);
   l_assets_add_flag 	VARCHAR2(1);
   l_num_dists_updated	NUMBER;

BEGIN

     v_old_stack := G_err_stack;
     G_err_stack := G_err_stack || '->PAAPIMP_PKG.net_zero_adjustment';
     G_err_code := 0;
     G_err_stage := 'Updating the invoices/expense reports to Z if the distributions are encumbered';

    If g_body_debug_mode = 'Y' Then
     write_log(LOG, G_err_stack);
    End If;

     IF G_INVOICE_TYPE = 'EXPENSE REPORT' THEN

         IF G_PROJECT_ID IS NOT NULL THEN

            -- This update is to mark the pa addition flag of all invoice distributions
            -- which have encumbered flag of 'R' .
            -- If the invoice distribution has a encumbered flag value of 'R' then it is
            -- not encumbered and there exist no Budgetery control commitment records
            -- for these in PA

	   If g_body_debug_mode = 'Y' Then
             G_err_stage := 'Updating the expense reports to Z for project ';
             write_log(LOG, G_err_stage);
           End If;
            /* Modified the hint on following update statement for bug 6920705 */
            UPDATE /*+ index(dist AP_INVOICE_DISTRIBUTIONS_N14) */ ap_invoice_distributions dist
                 SET dist.pa_addition_flag 		=	'Z',
                     request_id 				=	G_REQUEST_ID,
                     last_update_date			=	SYSDATE,  --bug 3905111
                     last_updated_by			=	G_USER_ID,
                     last_update_login			=	G_USER_ID,
                     program_id					=	G_PROG_ID,
                     program_application_id		=	G_PROG_APPL_ID,
                     program_update_date		=	SYSDATE, --bug 3905111
                     dist.assets_addition_flag 	=	decode(G_Assets_Addition_flag,'P','P',
                                                   		     dist.assets_addition_flag)
     	       WHERE dist.pa_addition_flag IN ('N', 'S', 'A', 'B', 'C', 'D', 'I', 'J', 'K', 'M', 'P', 'V', 'X', 'W')
                 AND dist.posted_flag||'' = 'Y'
                 AND dist.project_id  = G_PROJECT_ID
                 AND   'N' = (select cost_rate_flag
                                from pa_expenditure_types
                               where expenditure_type = dist.expenditure_type)
                 AND EXISTS (SELECT invoice_id
                               FROM AP_INVOICES inv
                              WHERE inv.invoice_id = DIST.invoice_id
                                AND inv.invoice_type_lookup_code = 'EXPENSE REPORT')
                 AND (( nvl(dist.encumbered_flag,'N') = 'R' )
	           OR (dist.line_type_lookup_code ='NONREC_TAX' AND nvl(dist.base_amount,dist.amount)=0)) /*Added for bug:7622893*/
                 AND NOT EXISTS (SELECT NULL
                              FROM   ap_invoice_distributions dist1
                              WHERE  dist.parent_reversal_id is not null
                              AND    dist.parent_reversal_id = dist1.invoice_distribution_id
                              AND    dist1.pa_addition_flag = 'T'
                              AND    dist1.encumbered_flag = 'R')
                 --Update historical data for Cash Based Acctng
                 AND  (G_ACCTNG_METHOD = 'A' OR (G_ACCTNG_METHOD = 'C' AND dist.historical_flag = 'Y'));

    	   l_num_dists_updated := SQL%ROWCOUNT ;

	   If g_body_debug_mode = 'Y' Then
           	write_log(LOG, 'Updated '||to_char(l_num_dists_updated)|| 'invoice distributions to Z for Encumbrance');
           end if;


         ELSE   /* Project Id is not passed */

            -- This update is to mark the pa addition flag of all invoice distributions
            -- which have encumbered flag of 'R'
            -- If the invoice distribution has a encumbered flag value of 'R' then it is
            -- not encumbered and there exist no Budgetery control commitment records
            -- for these in PA

	   If g_body_debug_mode = 'Y' Then
             G_err_stage := 'Updating the expense reports to Z for all';
             write_log(LOG, G_err_stage);
           End If;


            UPDATE /*+ index(dist AP_INVOICE_DISTRIBUTIONS_N14)*/ ap_invoice_distributions dist /*Added for bug 6327185*/
               SET 	dist.pa_addition_flag 		= 	'Z',
                	request_id 					= 	G_REQUEST_ID,
                	last_update_date			=	SYSDATE,  --bug 3905111
                	last_updated_by				= 	G_USER_ID,
                	last_update_login			= 	G_USER_ID,
                	program_id					= 	G_PROG_ID,
                	program_application_id		= 	G_PROG_APPL_ID,
                	program_update_date			=	SYSDATE, --bug 3905111
                	dist.assets_addition_flag 	= 	(SELECT decode(ptype.project_type_class_code,
                                            				'CAPITAL','P', dist.assets_addition_flag)
                           							   FROM pa_project_types_all ptype, pa_projects_all proj
                           							  WHERE ptype.project_type = proj.project_type
                           								AND (ptype.org_id = proj.org_id
														 OR proj.org_id is null)
                           								AND proj.project_id = dist.project_id)
	    WHERE dist.pa_addition_flag IN ('N', 'S', 'A', 'B', 'C', 'D', 'I', 'J', 'K', 'M', 'P', 'V', 'X', 'W')
              AND dist.posted_flag||'' = 'Y'
              AND dist.project_id > 0
              AND 'N' = (select cost_rate_flag
                           from pa_expenditure_types
                          where expenditure_type = dist.expenditure_type)
              AND EXISTS (SELECT invoice_id
                              FROM AP_INVOICES inv
                             WHERE inv.invoice_id = DIST.invoice_id
                               AND inv.invoice_type_lookup_code = 'EXPENSE REPORT')
                AND (( nvl(dist.encumbered_flag,'N') = 'R' )
	           OR (dist.line_type_lookup_code ='NONREC_TAX' AND nvl(dist.base_amount,dist.amount)=0)) /*Added for bug:7622893*/
              AND NOT EXISTS (SELECT NULL
                              FROM   ap_invoice_distributions dist1
                              WHERE  dist.parent_reversal_id is not null
                              AND    dist.parent_reversal_id = dist1.invoice_distribution_id
                              AND    dist1.pa_addition_flag = 'T'
                              AND    dist1.encumbered_flag = 'R')
              --Update historical data for Cash Based Acctng
              AND  (G_ACCTNG_METHOD = 'A' OR (G_ACCTNG_METHOD = 'C' AND dist.historical_flag = 'Y'));

    	   l_num_dists_updated := SQL%ROWCOUNT ;

	   If g_body_debug_mode = 'Y' Then
           	write_log(LOG, 'Updated '||to_char(l_num_dists_updated)|| 'invoice distributions to Z for Encumbrance');
           end if;

      END IF;
      --
      -- End of If section checking if G_PROJECT_ID is not null
      --

    ELSE
      --
      -- Bug 1594498
      -- Due to performance reasons the single update statement was
      -- broken up into two update statements based on if the program
      -- has the value of project id (If the user has given project number
      -- as one of the parameters).
      --

      IF G_PROJECT_ID IS NOT NULL THEN

/* Restructured the query below for performance bug 3026625 */

        /* Added the following update for bug 3569296 */
        -- The program should update the pa_addition_flag for all encumbered lines marked as R to netzero adj flag.
        -- R indicates a line to be ignored by encumbrance and validation code because neither the original nor the
        -- reversal distributions were looked at and they offset each other so, they can be ignored and marked as Z.
        -- (This is set only if the parent one is not validated as well. Otherwise the reversal one will also be encumbered).
        -- Since these lines have been not encumbered, there exist no Budgetery control commitment records for these in PA

	   If g_body_debug_mode = 'Y' Then
             G_err_stage := 'Updating invoice distributions to Z for project';
             write_log(LOG, G_err_stage);
           End If;
          /* Modified the hint on following update statement for bug 6920705 */
         UPDATE /*+ index(dist AP_INVOICE_DISTRIBUTIONS_N14) */ ap_invoice_distributions dist
            SET dist.pa_addition_flag = 'Z',
                request_id = G_REQUEST_ID,
                last_update_date=SYSDATE, --bug 3905111
                last_updated_by= G_USER_ID,
                last_update_login= G_USER_ID,
                program_id= G_PROG_ID,
                program_application_id= G_PROG_APPL_ID,
                program_update_date=SYSDATE, --bug 3905111
                dist.assets_addition_flag = decode(G_Assets_Addition_flag,'P','P',
                                                   dist.assets_addition_flag)
         WHERE dist.pa_addition_flag IN ('N', 'S', 'A', 'B', 'C', 'D','H', 'I', 'J', 'K', 'L', 'M', 'P','V', 'X', 'W')
           AND dist.posted_flag||'' = 'Y'
           AND dist.project_id = G_PROJECT_ID
           AND (( nvl(dist.encumbered_flag,'N') = 'R' )
	           OR (dist.line_type_lookup_code ='NONREC_TAX' AND nvl(dist.base_amount,dist.amount)=0)) /*Added for bug:7622893*/
           --Update historical data for Cash Based Acctng
           AND  (G_ACCTNG_METHOD = 'A' OR (G_ACCTNG_METHOD = 'C' AND dist.historical_flag = 'Y'))
           AND NOT EXISTS (SELECT NULL
                           FROM   ap_invoice_distributions dist1
                           WHERE  dist.parent_reversal_id is not null
                           AND    dist.parent_reversal_id = dist1.invoice_distribution_id
                           AND    dist1.pa_addition_flag = 'T'
                           AND    dist1.encumbered_flag = 'R')
           AND EXISTS (SELECT invoice_id
                         FROM AP_INVOICES inv
                        WHERE inv.invoice_id = DIST.invoice_id
                          AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT');

      	write_log(LOG, 'Updated '||to_char(SQL%ROWCOUNT)|| 'invoice distributions to Z for Encumbrance');


     ELSE /* G_PROJECT_ID is null */


            -- This update is to mark the pa addition flag of all invoice distributions
            -- which have encumbered flag of 'R' or reversal flag of 'Y' to 'Z'.
            -- Encumbrance flag of 'R' or reversal flag of 'Y' indicates that they are
            -- exact reversal of another invoice distribution.
            -- If the invoice distribution has a encumbered flag value of 'R' then it is
            -- not encumbered and there exist no Budgetery control commitment records
            -- for these in PA

	   If g_body_debug_mode = 'Y' Then
             G_err_stage := 'Updating invoice distributions to Z for all';
             write_log(LOG, G_err_stage);
           End If;

            UPDATE /*+ index(dist AP_INVOICE_DISTRIBUTIONS_N14)*/ ap_invoice_distributions dist /*Added for bug 6327185*/
               SET 	dist.pa_addition_flag 	= 	'Z',
                	request_id 				= 	G_REQUEST_ID,
                	last_update_date		=	SYSDATE,  --bug 3905111
                	last_updated_by			= 	G_USER_ID,
                	last_update_login		= 	G_USER_ID,
                	program_id				= 	G_PROG_ID,
                	program_application_id	= 	G_PROG_APPL_ID,
                	program_update_date		=	SYSDATE,  --bug 3905111
                	dist.assets_addition_flag = (SELECT decode(ptype.project_type_class_code,
                                            			'CAPITAL','P', dist.assets_addition_flag)
                           						   FROM pa_project_types_all ptype, pa_projects_all proj
                           						  WHERE ptype.project_type = proj.project_type
                           						    AND (ptype.org_id = proj.org_id OR
                                   						proj.org_id is null)
                           						    AND proj.project_id = dist.project_id)
             WHERE dist.pa_addition_flag IN ('N', 'S', 'A', 'B', 'C', 'D','H', 'I', 'J', 'K', 'L', 'M', 'P','V', 'X', 'W')
               AND   dist.posted_flag||'' = 'Y'
               AND   dist.project_id > 0
               AND (( nvl(dist.encumbered_flag,'N') = 'R' )
	        OR (dist.line_type_lookup_code ='NONREC_TAX' AND nvl(dist.base_amount,dist.amount)=0)) /*Added for bug:7622893*/
               --Update historical data for Cash Based Acctng
               AND  (G_ACCTNG_METHOD = 'A' OR (G_ACCTNG_METHOD = 'C' AND dist.historical_flag = 'Y'))
               AND NOT EXISTS (SELECT NULL
                              FROM   ap_invoice_distributions dist1
                              WHERE  dist.parent_reversal_id is not null
                              AND    dist.parent_reversal_id = dist1.invoice_distribution_id
                              AND    dist1.pa_addition_flag = 'T'
                              AND    dist1.encumbered_flag = 'R')
           AND EXISTS (SELECT invoice_id
                         FROM AP_INVOICES inv
                        WHERE inv.invoice_id = DIST.invoice_id
                          AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT');

      	write_log(LOG, 'Updated '||to_char(SQL%ROWCOUNT)|| 'invoice distributions to Z for Encumbrance');

     END IF;
      --
      -- End of If section checking if G_PROJECT_ID is not null
      --

     END IF;
G_err_stack := v_old_stack;

EXCEPTION
        WHEN Others THEN
               /*
               --
               -- Exceptions occured in this procedure must be raised by the
               -- UPDATE statement, most likely a fatal error like 'rollback
               -- segment exceeded' error which should cause the program to
               -- terminate
               --
               */

	       G_err_stack := v_old_stack;
               G_err_code := SQLCODE;
	       raise;


END net_zero_adjustment;

FUNCTION check_prepay_fully_applied(p_prepay_dist_id in NUMBER)
   RETURN VARCHAR2 IS

  l_prepay_rem_amt      NUMBER;

BEGIN

       SELECT prepay_amount_remaining
       INTO   l_prepay_rem_amt
       FROM   ap_invoice_distributions_All
       WHERE  invoice_distribution_id = p_prepay_dist_id;

   -- ==================================================================================
   -- Bug: 5393523
   --    : R12.PJ:XB6:QA:APL: STANDARD INVOICES / PREPAYMENTS NOT SHOWN AS COMMITTMENT
   --      Unpaid prepayments invoice has NULL prepay_amount_remaining and it should not
   --      mislead as fully applied prepayment.
   -- ==================================================================================
   IF l_prepay_rem_amt is NULL THEN
      RETURN 'N' ;
   ELSIF l_prepay_rem_amt = 0 THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;

EXCEPTION

WHEN Others THEN

   write_log(LOG, 'Exception in check_prepay_fully_applied');
   G_err_code := SQLCODE;
   RAISE;

END check_prepay_fully_applied;

/*-----------------------Marking Distribution Phase---------------------*/

PROCEDURE mark_PAflag_O IS

        v_old_stack VARCHAR2(630);

BEGIN

     v_old_stack := G_err_stack;
     G_err_stack := G_err_stack || '->PAAPIMP_PKG.mark_PAflag_O';
     G_err_code := 0;
     G_err_stage := 'UPDATING INVOICE DISTRIBUTIONS-Marking Process';

     write_log(LOG, G_err_stack);
      /* VI enhancements */


     IF G_INVOICE_TYPE = 'EXPENSE REPORT' THEN

                   --
                   -- This section is for Expense Reports
                   --

          write_log(LOG, 'Marking Expense Report type invoices for processing...');
                   --
                   -- Due to performance reasons the single update statement was
                   -- broken up into two update statements based on if the program
                   -- has the value of project id (If the user has given project number
                   -- as one of the parameters).
                   --

      IF G_PROJECT_ID IS NOT NULL THEN

        -- In Cash Based Accounting all historical Invoices and their adjustments in AP will continue to be interfaced as Invoice distributions
        -- and NOT Payment lines

        IF G_ACCTNG_METHOD = 'C' THEN --CAsh BAsed Accounting

          write_log(LOG, 'Marking invoices to O for Historical Data interface in Cash Based Acctng');

          UPDATE  AP_Invoice_distributions DIST
             SET  DIST.Pa_Addition_Flag ='O',
                  request_id = G_REQUEST_ID,
                  last_update_date=SYSDATE,
                  last_updated_by=G_USER_ID,
                  last_update_login= G_USER_ID,
                  program_id= G_PROG_ID,
                  program_application_id= G_PROG_APPL_ID,
                  program_update_date=SYSDATE
           WHERE  DIST.Posted_Flag||'' = 'Y'
             AND  DIST.Pa_Addition_Flag IN
                          ('S', 'A', 'B', 'C', 'D', 'I', 'N', 'J', 'K', 'M', 'P','Q', 'V', 'X', 'W')
             AND DIST.project_id > 0
             AND dist.line_type_lookup_code <> 'REC_TAX' -- do not proces recoverable tax
             AND ((
                  exists (SELECT NULL
                           FROM AP_INVOICES inv,
                                AP_Invoice_distributions DIST1,
                                PO_VENDORS vend
                          WHERE inv.invoice_id = DIST1.invoice_id
                            AND DIST1.invoice_distribution_id = DIST.invoice_distribution_id
                            AND INV.payment_status_flag = 'Y'                                   -- Flag indicated FULLY paid inv
                            AND DIST1.historical_flag = 'Y'                                     -- process historical dist as invoices in Cash Based Acctng
                            AND inv.vendor_id = vend.vendor_id
                            AND ((inv.invoice_type_lookup_code = G_INVOICE_TYPE
                                  AND inv.source IN (G_INVOICE_SOURCE1, G_INVOICE_SOURCE2, G_INVOICE_SOURCE3)
                                  AND (vend.employee_id IS NOT NULL or nvl(inv.paid_on_behalf_employee_id,0) > 0))
                                 OR
                                (inv.invoice_type_lookup_code   in ('STANDARD','CREDIT','MIXED')
                                 AND inv.source in ('CREDIT CARD','Both Pay')
                                  /*   AND nvl(inv.PAID_ON_BEHALF_EMPLOYEE_ID,0) > 0 commented for bug#8977795 */))))
                 OR
                  (EXISTS ( SELECT NULL
                           FROM  PO_VENDORS vend1,
                                 ap_invoices inv1,
                                 ap_invoice_distributions dist2
                           WHERE inv1.invoice_id = dist2.invoice_id
                           AND   inv1.invoice_id = dist.invoice_id
                           AND   (dist.reversal_flag = 'Y' or dist.cancellation_flag = 'Y' )
                           AND   dist2.invoice_distribution_id = dist.parent_reversal_id      --Process Historical data reversals as Invoices in Cash based
                           AND   dist2.pa_addition_flag = 'Y'
                           AND   inv1.vendor_id = vend1.vendor_id
                           AND ((inv1.invoice_type_lookup_code = G_INVOICE_TYPE
                                 AND inv1.source IN (G_INVOICE_SOURCE1, G_INVOICE_SOURCE2, G_INVOICE_SOURCE3)
                                 AND (vend1.employee_id IS NOT NULL or nvl(inv1.paid_on_behalf_employee_id,0) > 0))
                                OR
                                (inv1.invoice_type_lookup_code   in ('STANDARD','CREDIT','MIXED')
                                 AND inv1.source  in ('CREDIT CARD','Both Pay')
                                  /*   AND nvl(inv.PAID_ON_BEHALF_EMPLOYEE_ID,0) > 0 commented for bug#8977795 */))))
                 )
             AND DIST.project_id = G_PROJECT_ID
             AND trunc(DIST.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,DIST.expenditure_item_date))
             AND trunc(DIST.accounting_date) <= trunc(nvl(G_GL_DATE,DIST.accounting_date));

        G_DISTRIBUTIONS_MARKED :=  SQL%ROWCOUNT;
        write_log(LOG, 'Number of Historical rows marked to O: ' || to_char(SQL%ROWCOUNT));

        /* Historical Data Processing for Prepayments */
        /* All PREPAY application distributions that relate to PREPAYMENT invoice that was already interfaced into PRojects
           Pre Rel12 Upgrade should also be brought into Projects */

          write_log(LOG, 'Marking Historical Prepayments for processing...');

            UPDATE ap_invoice_distributions_all dist
            SET    dist.pa_addition_flag = 'O',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   DIST.project_id > 0
            AND   dist.posted_flag = 'Y'
            AND   dist.project_id = G_PROJECT_ID
            --AND   dist.line_type_lookup_code = 'PREPAY'
            AND   dist.line_type_lookup_code <> 'REC_TAX'
            AND   dist.prepay_distribution_id is not null
            AND   trunc(dist.Accounting_Date) <= trunc(nvl(G_GL_DATE,dist.Accounting_Date))
            AND   trunc(dist.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,dist.expenditure_item_date))
            AND   exists (SELECT NULL
                           FROM AP_INVOICES inv,
                                PO_VENDORS vend
                          WHERE inv.invoice_id = DIST.invoice_id
                            AND inv.vendor_id = vend.vendor_id
                            AND ((inv.invoice_type_lookup_code = G_INVOICE_TYPE
                                  AND inv.source IN (G_INVOICE_SOURCE1, G_INVOICE_SOURCE2, G_INVOICE_SOURCE3)
                                  AND (vend.employee_id IS NOT NULL or nvl(inv.paid_on_behalf_employee_id,0) > 0))
                                 OR
                                (inv.invoice_type_lookup_code   in ('STANDARD','CREDIT','MIXED') /*Bug# 3373933*/ /*Bug 4099522*/
                                 AND inv.source in ('CREDIT CARD','Both Pay')
                              /*   AND nvl(inv.PAID_ON_BEHALF_EMPLOYEE_ID,0) > 0 commented for bug#8977795 */ )))
            AND   exists(SELECT inv.invoice_id
                         FROM    AP_INVOICES inv,
                                 AP_Invoice_Distributions_all aid
                          WHERE aid.invoice_id = inv.invoice_id
                            AND inv.invoice_type_lookup_code = 'PREPAYMENT'
                            AND aid.historical_flag = 'Y'
                            AND aid.pa_addition_flag = 'Y'
                            AND aid.invoice_distribution_id =  dist.prepay_distribution_id --Prepayment dist id
                 );

            G_DISTRIBUTIONS_MARKED := nvl(G_DISTRIBUTIONS_MARKED,0) + SQL%ROWCOUNT;
            write_log(LOG, 'Number of Historical PREPAY Appl Dist marked to O: ' || to_char(SQL%ROWCOUNT));

          ELSE --Accounting Method is Accrual

          write_log(LOG, 'Marking Expense Report type invoices for processing - Accrual Acct');

             UPDATE  AP_Invoice_distributions DIST
                SET  DIST.Pa_Addition_Flag ='O',
                     request_id = G_REQUEST_ID,
                     last_update_date=SYSDATE,
                     last_updated_by=G_USER_ID,
                     last_update_login= G_USER_ID,
                     program_id= G_PROG_ID,
                     program_application_id= G_PROG_APPL_ID,
                     program_update_date=SYSDATE
              WHERE  DIST.Posted_Flag||'' = 'Y'
                AND  DIST.Pa_Addition_Flag IN
                          ('S', 'A', 'B', 'C', 'D', 'I', 'N', 'J', 'K', 'M', 'P','Q', 'V', 'X', 'W')
                AND DIST.project_id > 0
                AND dist.line_type_lookup_code <> 'REC_TAX' -- do not proces recoverable tax
                AND exists (SELECT NULL
                              FROM AP_INVOICES inv,
                                   PO_VENDORS vend
                             WHERE inv.invoice_id = DIST.invoice_id
                               AND inv.vendor_id = vend.vendor_id
                               AND ((inv.invoice_type_lookup_code = G_INVOICE_TYPE
                                     AND inv.source IN (G_INVOICE_SOURCE1, G_INVOICE_SOURCE2, G_INVOICE_SOURCE3)
                                     AND (vend.employee_id IS NOT NULL or nvl(inv.paid_on_behalf_employee_id,0) > 0))
                                    OR
                                   (inv.invoice_type_lookup_code   in ('STANDARD','CREDIT','MIXED') /*Bug# 3373933*/ /*Bug 4099522*/
                                    AND inv.source   in ('CREDIT CARD','Both Pay')
                                    /*   AND nvl(inv.PAID_ON_BEHALF_EMPLOYEE_ID,0) > 0 commented for bug#8977795 */)))
               AND DIST.project_id = G_PROJECT_ID
               AND trunc(DIST.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,DIST.expenditure_item_date)) /*GSCC*//* added trunc for the bug 6623163 */
               AND trunc(DIST.accounting_date) <= trunc(nvl(G_GL_DATE,DIST.accounting_date));   /*GSCC*//* added trunc for the bug 6623163 */

               G_DISTRIBUTIONS_MARKED :=  SQL%ROWCOUNT;

        End If; --End of CAsh BAsed Accounting

      ELSE /* G_PROJECT_ID IS NULL */

        IF G_ACCTNG_METHOD = 'C' THEN

          write_log(LOG, 'Marking invoices to O for Historical Data interface in Cash Based Acctng');

          UPDATE  AP_Invoice_distributions DIST
             SET  DIST.Pa_Addition_Flag ='O',
                  request_id = G_REQUEST_ID,
                  last_update_date=SYSDATE,
                  last_updated_by=G_USER_ID,
                  last_update_login= G_USER_ID,
                  program_id= G_PROG_ID,
                  program_application_id= G_PROG_APPL_ID,
                  program_update_date=SYSDATE
           WHERE  DIST.Posted_Flag||'' = 'Y'
             AND  DIST.Pa_Addition_Flag IN
                          ('S', 'A', 'B', 'C', 'D', 'I', 'N', 'J', 'K', 'M', 'P','Q', 'V', 'X', 'W')
             AND DIST.project_id > 0
             AND dist.line_type_lookup_code <> 'REC_TAX' -- do not proces recoverable tax
             AND (
                  (exists (SELECT NULL
                           FROM AP_INVOICES inv,
                                AP_Invoice_distributions DIST1,
                                PO_VENDORS vend
                          WHERE inv.invoice_id = DIST1.invoice_id
                            AND DIST1.invoice_distribution_id = DIST.invoice_distribution_id
                            AND INV.payment_status_flag = 'Y'                                   -- Flag indicated FULLY paid inv
                            AND DIST1.historical_flag = 'Y'                                     --process historical dist as invoices in Cash Based Acctng
                            AND inv.vendor_id = vend.vendor_id
                            AND ((inv.invoice_type_lookup_code = G_INVOICE_TYPE
                                  AND inv.source IN (G_INVOICE_SOURCE1, G_INVOICE_SOURCE2, G_INVOICE_SOURCE3)
                                  AND (vend.employee_id IS NOT NULL or nvl(inv.paid_on_behalf_employee_id,0) > 0))
                                 OR
                                (inv.invoice_type_lookup_code   in ('STANDARD','CREDIT','MIXED') /*Bug# 3373933*/ /*Bug 4099522*/
                                 AND inv.source    in ('CREDIT CARD','Both Pay')
                                 /*   AND nvl(inv.PAID_ON_BEHALF_EMPLOYEE_ID,0) > 0 commented for bug#8977795 */))))
                 OR
                  (EXISTS ( SELECT NULL
                           FROM  PO_VENDORS vend1,
                                 ap_invoices inv1, ap_invoice_distributions dist2
                           WHERE inv1.invoice_id = dist2.invoice_id
                           AND   inv1.invoice_id = dist.invoice_id
                           AND   (dist.reversal_flag = 'Y' or dist.cancellation_flag = 'Y' )
                           AND   dist2.invoice_distribution_id = dist.parent_reversal_id      --Process Historical data reversals as Invoices in Cash based
                           AND   dist2.pa_addition_flag = 'Y'
                           AND   inv1.vendor_id = vend1.vendor_id
                           AND ((inv1.invoice_type_lookup_code = G_INVOICE_TYPE
                                 AND inv1.source IN (G_INVOICE_SOURCE1, G_INVOICE_SOURCE2, G_INVOICE_SOURCE3)
                                 AND (vend1.employee_id IS NOT NULL or nvl(inv1.paid_on_behalf_employee_id,0) > 0))
                                OR
                               (inv1.invoice_type_lookup_code   in ('STANDARD','CREDIT','MIXED') /*Bug# 3373933*/ /*Bug 4099522*/
                                AND inv1.source in ('CREDIT CARD','Both Pay')
                                /*   AND nvl(inv.PAID_ON_BEHALF_EMPLOYEE_ID,0) > 0 commented for bug#8977795 */))))
                 )
             AND trunc(DIST.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,DIST.expenditure_item_date)) /*GSCC*/
             AND trunc(DIST.accounting_date) <= trunc(nvl(G_GL_DATE,DIST.accounting_date));   /*GSCC*/ /*Bug 7342936. Right parenthesis were missing on left side of expression*/
        G_DISTRIBUTIONS_MARKED := SQL%ROWCOUNT;
        write_log(LOG, 'Number of Historical rows marked to O: ' || to_char(SQL%ROWCOUNT));

        /* Historical Data Processing for Prepayments */
        /* All PREPAY application distributions that relate to PREPAYMENT invoice that was already interfaced into PRojects
           Pre Rel12 Upgrade should also be brought into Projects */

          write_log(LOG, 'Marking Historical Prepayments for processing...');

            UPDATE ap_invoice_distributions dist
            SET    dist.pa_addition_flag = 'O',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   DIST.project_id > 0
            AND   dist.posted_flag = 'Y'
            --AND   dist.line_type_lookup_code = 'PREPAY'
            AND   dist.line_type_lookup_code <> 'REC_TAX'
            AND   dist.prepay_distribution_id is not null
            AND   trunc(dist.Accounting_Date) <= trunc(nvl(G_GL_DATE,dist.Accounting_Date))
            AND   trunc(dist.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,dist.expenditure_item_date))
            AND   exists (SELECT NULL
                           FROM AP_INVOICES_ALL inv,
                                PO_VENDORS vend
                          WHERE inv.invoice_id = DIST.invoice_id
                            AND inv.vendor_id = vend.vendor_id
                            AND ((inv.invoice_type_lookup_code = G_INVOICE_TYPE
                                  AND inv.source IN (G_INVOICE_SOURCE1, G_INVOICE_SOURCE2, G_INVOICE_SOURCE3)
                                  AND (vend.employee_id IS NOT NULL or nvl(inv.paid_on_behalf_employee_id,0) > 0))
                                 OR
                                (inv.invoice_type_lookup_code   in ('STANDARD','CREDIT','MIXED') /*Bug# 3373933*/ /*Bug 4099522*/
                                 AND inv.source  in ('CREDIT CARD','Both Pay')
                                 /*   AND nvl(inv.PAID_ON_BEHALF_EMPLOYEE_ID,0) > 0 commented for bug#8977795 */)))
            AND   exists(SELECT inv.invoice_id
                         FROM    AP_INVOICES_ALL inv,
                                 AP_Invoice_Distributions_all aid
                          WHERE aid.invoice_id = inv.invoice_id
                            AND inv.invoice_type_lookup_code = 'PREPAYMENT'
                            AND aid.historical_flag = 'Y'
                            AND aid.pa_addition_flag = 'Y'
                            AND aid.invoice_distribution_id =  dist.prepay_distribution_id --Prepayment dist id
                  );

            G_DISTRIBUTIONS_MARKED := nvl(G_DISTRIBUTIONS_MARKED,0) + SQL%ROWCOUNT;
            write_log(LOG, 'Number of Historical PREPAY Appl Dist marked to O: ' || to_char(SQL%ROWCOUNT));

          ELSE --Accounting Method is Accrual

          write_log(LOG, 'Marking Expense Report type invoices for processing - Accrual Acct');

            UPDATE  /*+ index(DIST AP_INVOICE_DISTRIBUTIONS_N14)*/ AP_Invoice_distributions DIST /*Added for bug 6327185*/
               SET  DIST.Pa_Addition_Flag ='O', /*Bug#2168903*/
                    request_id = G_REQUEST_ID,
                    last_update_date=SYSDATE,  --bug 3905111
                    last_updated_by=G_USER_ID,
                    last_update_login= G_USER_ID,
                    program_id= G_PROG_ID,
                    program_application_id= G_PROG_APPL_ID,
                    program_update_date=SYSDATE   --bug 3905111
             WHERE  DIST.Posted_Flag||'' = 'Y'
               AND  DIST.Pa_Addition_Flag IN                           /*Bug#1727504*/
                          ('S', 'A', 'B', 'C', 'D', 'I', 'N', 'J', 'K', 'M', 'P','Q', 'V', 'X', 'W')
               AND DIST.project_id > 0
               AND dist.line_type_lookup_code <> 'REC_TAX' -- do not proces recoverable tax
	       AND exists (SELECT invoice_id
                             FROM AP_INVOICES_ALL inv,
                                  PO_VENDORS vend
                            WHERE inv.invoice_id = DIST.invoice_id
                              AND inv.vendor_id = vend.vendor_id
                              AND ((inv.invoice_type_lookup_code = G_INVOICE_TYPE
                                  AND inv.source IN (G_INVOICE_SOURCE1, G_INVOICE_SOURCE2, G_INVOICE_SOURCE3)
                                    AND (vend.employee_id IS NOT NULL or nvl(inv.paid_on_behalf_employee_id,0) > 0))
                                   OR
                                  (inv.invoice_type_lookup_code    in ('STANDARD','CREDIT','MIXED') /*Bug# 3373933*//*Bug 4099522*/
                                   AND inv.source  in ('CREDIT CARD','Both Pay')
                                  /* AND nvl(inv.paid_on_behalf_employee_id,0) > 0 commented for bug#8977795 */ )))
               AND trunc(DIST.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,DIST.expenditure_item_date)) /*GSCC*//* added trunc for the bug 6623163 */
               AND trunc(DIST.accounting_date) <= trunc(nvl(G_GL_DATE,DIST.accounting_date)); /*GSCC*/

            G_DISTRIBUTIONS_MARKED :=  SQL%ROWCOUNT;
            write_log(LOG, 'Number of rows marked to O: ' || to_char(SQL%ROWCOUNT));

          END IF; --End of CAsh BAsed Accounting

        END IF; /* END IF Project ID */

     ELSE

	   write_log(LOG, 'Marking supplier invoices for processing...');

             --
             -- Due to performance reasons the single update statement was
             -- broken up into two update statements based on if the program
             -- has the value of project id (If the user has given project number
             -- as one of the parameters).
             --

       IF G_PROJECT_ID IS NOT NULL THEN

          -- Update pa-addition-flag to O for all valid ap distributions that should be interfaced to Projects
        If g_body_debug_mode = 'Y' Then
	   write_log(LOG, 'Marking supplier invoices for project = '||G_PROJECT_ID);
	   write_log(LOG, 'Marking supplier invoices for G_GL_DATE = '||G_GL_DATE);
	   write_log(LOG, 'Marking supplier invoices for G_TRANSACTION_DATE = '||G_TRANSACTION_DATE);
        End If;

         -- For CASH based Accntg we will continue to bring Historical data as Invoices and not Payments
         -- Any reversals made to the historical Invoices should also be brought into projects as Invoices and not Payments

         IF G_ACCTNG_METHOD = 'C' THEN

	   write_log(LOG, 'Marking invoices to O for Historical Data interface in Cash Based Acctng');

           UPDATE AP_Invoice_Distributions DIST
              SET DIST.Pa_Addition_Flag = 'O',
                  request_id = G_REQUEST_ID,
                  last_update_date=SYSDATE,
                  last_updated_by=G_USER_ID,
                  last_update_login=G_USER_ID,
                  program_id=G_PROG_ID,
                  program_application_id=G_PROG_APPL_ID,
                  program_update_date=SYSDATE
            WHERE DIST.Posted_Flag = 'Y'
              AND DIST.Pa_Addition_Flag IN
                  ('S', 'A', 'B', 'C', 'D','H', 'I', 'J', 'K', 'L', 'M', 'N', 'P','Q', 'V', 'X')
              AND DIST.project_id > 0
              AND trunc(DIST.Accounting_Date) <= trunc(nvl(G_GL_DATE,DIST.Accounting_Date))   /*GSCC*//* added trunc for the bug 6623163 */
              AND trunc(DIST.Expenditure_Item_Date) <= trunc(NVL(G_TRANSACTION_DATE,DIST.Expenditure_Item_Date))       /*GSCC*/ /* added trunc for the bug 6623163 */
              AND DIST.project_id = G_PROJECT_ID
              AND dist.line_type_lookup_code <> 'REC_TAX' -- do not proces recoverable tax
              AND (
                  EXISTS (
                    SELECT NULL
                    FROM ap_invoices_all inv,
                         po_distributions_all PO,
                         ap_invoice_distributions_all dist2
                    WHERE inv.invoice_id = dist2.invoice_id
                    AND nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'
                    AND dist2.invoice_id = DIST.invoice_id
                    AND dist2.invoice_distribution_id = DIST.invoice_distribution_id
                    AND inv.payment_status_flag = 'Y'                                -- Flag indicates that Invoice has been FULLY paid
                    AND dist2.historical_flag = 'Y'                                    --Process Historical data as Invoices in Cash based
                    AND dist2.po_distribution_id = PO.po_distribution_id(+)
                    AND NVL(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
                    AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                    AND inv.PAID_ON_BEHALF_EMPLOYEE_ID IS NULL
                    AND inv.source not  in ('CREDIT CARD','Both Pay') /* Added for bug 8977795 */
                    AND ( nvl(INV.source, 'xx' ) NOT IN (
                              'PA_IC_INVOICES','PA_COST_ADJUSTMENTS') /* Removed 'Oracle Project Accounting' */
			  or dist2.line_type_lookup_code = 'NONREC_TAX'
			 )
                    )
                  OR
                  EXISTS (
                    SELECT NULL
                    FROM ap_invoices_all inv1,
                         ap_invoice_distributions_all dist3
                    WHERE inv1.invoice_id = dist3.invoice_id
                    AND   inv1.invoice_id = dist.invoice_id
                    AND   inv1.invoice_type_lookup_code <> 'EXPENSE REPORT'
                    AND   (dist.reversal_flag = 'Y' or dist.cancellation_flag = 'Y' )
                    AND   dist3.invoice_distribution_id = dist.parent_reversal_id      --Process Historical data reversals as Invoices in Cash based
                    AND   dist3.pa_addition_flag = 'Y')
                  )
                /* Bug 6353803: Added the following for this bug. */
  	        AND   (pa_nl_installed.is_nl_installed = 'N'
                  OR (    pa_nl_installed.is_nl_installed = 'Y'
		    AND NOT EXISTS (SELECT 'X'
				    FROM  po_distributions_all pod, mtl_system_items si, po_lines_all pol
				    WHERE pod.po_distribution_id = dist.po_distribution_id
				    AND pod.po_line_id = pol.po_line_id
				    AND   si.inventory_item_id = pol.item_id
				    AND   si.comms_nl_trackable_flag = 'Y'
				    AND   si.organization_id = pod.org_id
				    )
		    AND NOT EXISTS (SELECT 'X'
			      FROM
				ap_invoice_distributions apdist,
				po_distributions pod,
				mtl_system_items si,
				po_lines_all pol
			      where DIST.CHARGE_APPLICABLE_TO_DIST_ID
                                    = apdist.INVOICE_DISTRIBUTION_ID
				  and apdist.po_distribution_id = pod.po_distribution_id
				  and pod.po_line_id = pol.po_line_id
				  and si.inventory_item_id = pol.item_id
				  AND   si.comms_nl_trackable_flag = 'Y'
				  AND   si.organization_id = pod.org_id
					     )
		    )
                  );

              G_DISTRIBUTIONS_MARKED := SQL%ROWCOUNT;
              write_log(LOG, 'Number of Historical Invoice Dist marked to O: ' || to_char(SQL%ROWCOUNT));


        /* Historical Data Processing for Prepayments */
        /* All PREPAY application distributions that relate to PREPAYMENT invoice that was already interfaced into PRojects
           Pre Rel12 Upgrade should also be brought into Projects */

	   write_log(LOG, 'Marking PREPAYMENT invoices in Cash Based Acctng');

            UPDATE ap_invoice_distributions_all dist
            SET    dist.pa_addition_flag = 'O',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   DIST.project_id > 0
            AND   dist.posted_flag = 'Y'
            AND   dist.project_id = G_PROJECT_ID
            --AND   dist.line_type_lookup_code = 'PREPAY'
            AND   dist.line_type_lookup_code <> 'REC_TAX'
            AND   dist.prepay_distribution_id is not null
            AND   trunc(dist.Accounting_Date) <= trunc(nvl(G_GL_DATE,dist.Accounting_Date))
            AND   trunc(dist.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,dist.expenditure_item_date))
            AND   EXISTS (
                    SELECT NULL
                    FROM ap_invoices inv
                    WHERE inv.invoice_id = dist.invoice_id
                    AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                    AND inv.PAID_ON_BEHALF_EMPLOYEE_ID IS NULL
                    AND inv.source not  in ('CREDIT CARD','Both Pay') /* Added for bug 8977795 */
                    AND nvl(INV.source, 'xx' ) NOT IN (
                              'PA_IC_INVOICES','PA_COST_ADJUSTMENTS')  ) /* Removed 'Oracle Project Accounting' */
            AND   exists(SELECT inv.invoice_id
                           FROM AP_INVOICES inv,
                                AP_Invoice_Distributions_all aid
                          WHERE aid.invoice_id = inv.invoice_id
                            AND inv.invoice_type_lookup_code = 'PREPAYMENT'
                            AND aid.historical_flag = 'Y'
                            AND aid.pa_addition_flag = 'Y'
                            AND aid.invoice_distribution_id =  dist.prepay_distribution_id --Prepayment dist id
                            AND aid.project_id = G_PROJECT_ID)
                /* Bug 6353803: Added the following for this bug. */
  	        AND   (pa_nl_installed.is_nl_installed = 'N'
                  OR (    pa_nl_installed.is_nl_installed = 'Y'
		    AND NOT EXISTS (SELECT 'X'
				    FROM  po_distributions_all pod, mtl_system_items si, po_lines_all pol
				    WHERE pod.po_distribution_id = dist.po_distribution_id
				    AND pod.po_line_id = pol.po_line_id
				    AND   si.inventory_item_id = pol.item_id
				    AND   si.comms_nl_trackable_flag = 'Y'
				    AND   si.organization_id = pod.org_id
				    )
		    AND NOT EXISTS (SELECT 'X'
			      FROM
				ap_invoice_distributions apdist,
				po_distributions pod,
				mtl_system_items si,
				po_lines_all pol
			      where DIST.CHARGE_APPLICABLE_TO_DIST_ID
                                    = apdist.INVOICE_DISTRIBUTION_ID
				  and apdist.po_distribution_id = pod.po_distribution_id
				  and pod.po_line_id = pol.po_line_id
				  and si.inventory_item_id = pol.item_id
				  AND   si.comms_nl_trackable_flag = 'Y'
				  AND   si.organization_id = pod.org_id
					     )
		    )
                  );

            G_DISTRIBUTIONS_MARKED :=nvl(G_DISTRIBUTIONS_MARKED ,0) +  SQL%ROWCOUNT;
            write_log(LOG, 'Number of Historical PREPAY Appl Dist marked to O: ' || to_char(SQL%ROWCOUNT));


         ELSE -- Accrual BAsed Acctng

	   write_log(LOG, 'Marking invoices in Accrual based Acctng');

           UPDATE AP_Invoice_Distributions DIST
              SET DIST.Pa_Addition_Flag = 'O',
                  request_id = G_REQUEST_ID,
                  last_update_date=SYSDATE,
                  last_updated_by=G_USER_ID,
                  last_update_login=G_USER_ID,
                  program_id=G_PROG_ID,
                  program_application_id=G_PROG_APPL_ID,
                  program_update_date=SYSDATE
            WHERE DIST.Posted_Flag = 'Y'
              AND DIST.Pa_Addition_Flag IN
                   ('S', 'A', 'B', 'C', 'D','H', 'I', 'J', 'K', 'L', 'M', 'N', 'P','Q', 'V', 'X')
              AND DIST.project_id > 0
              AND trunc(DIST.Accounting_Date) <= trunc(nvl(G_GL_DATE,DIST.Accounting_Date))   /*GSCC*/
              AND trunc(DIST.Expenditure_Item_Date) <=
                       trunc(NVL(G_TRANSACTION_DATE,DIST.Expenditure_Item_Date))       /*GSCC*/
              AND DIST.project_id = G_PROJECT_ID
              AND dist.line_type_lookup_code <> 'REC_TAX' -- do not proces recoverable tax
              AND EXISTS (
                  SELECT NULL
                    FROM ap_invoices_all inv,
                         po_distributions_all PO,
                         ap_invoice_distributions_all dist2
                    WHERE inv.invoice_id = dist2.invoice_id
                    AND nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'
                    AND dist2.invoice_id = DIST.invoice_id
                    /*credit card txn enhancement, make sure this update doesn't pick tehm */
                    AND inv.PAID_ON_BEHALF_EMPLOYEE_ID IS NULL
                     AND inv.source not  in ('CREDIT CARD','Both Pay') /* Added for bug 8977795 */
                    AND dist2.invoice_distribution_id = DIST.invoice_distribution_id
                    AND dist2.po_distribution_id = PO.po_distribution_id(+)
                    AND NVL(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
                    AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                    AND  (
			nvl(INV.source, 'xx' ) NOT IN ( 'PA_IC_INVOICES','PA_COST_ADJUSTMENTS')  /* Removed 'Oracle Project Accounting' */
			or
			 dist2.line_type_lookup_code = 'NONREC_TAX'
			 )
                        )
                /* Bug 6353803: Added the following for this bug. */
  	        AND   (pa_nl_installed.is_nl_installed = 'N'
                  OR (    pa_nl_installed.is_nl_installed = 'Y'
		    AND NOT EXISTS (SELECT 'X'
				    FROM  po_distributions_all pod, mtl_system_items si, po_lines_all pol
				    WHERE pod.po_distribution_id = dist.po_distribution_id
				    AND pod.po_line_id = pol.po_line_id
				    AND   si.inventory_item_id = pol.item_id
				    AND   si.comms_nl_trackable_flag = 'Y'
				    AND   si.organization_id = pod.org_id
				    )
		    AND NOT EXISTS (SELECT 'X'
			      FROM
				ap_invoice_distributions apdist,
				po_distributions pod,
				mtl_system_items si,
				po_lines_all pol
			      where DIST.CHARGE_APPLICABLE_TO_DIST_ID
                                    = apdist.INVOICE_DISTRIBUTION_ID
				  and apdist.po_distribution_id = pod.po_distribution_id
				  and pod.po_line_id = pol.po_line_id
				  and si.inventory_item_id = pol.item_id
				  AND   si.comms_nl_trackable_flag = 'Y'
				  AND   si.organization_id = pod.org_id
					     )
		    )
                  );

	      G_DISTRIBUTIONS_MARKED := SQL%ROWCOUNT;
              write_log(LOG, 'Number of rows marked to O: ' || to_char(SQL%ROWCOUNT));

         END IF; -- End of Accntg Method is CASH

       ELSE          /* G_PROJECT_ID IS NULL */


         -- For CASH based Accntg we will continue to bring Historical data as Invoices and not Payments
         -- Any reversals made to the historical Invoices should also be brought into projects as Invoices and not Payments

         IF G_ACCTNG_METHOD = 'C' THEN

	   write_log(LOG, 'Marking invoices to O for Historical Data interface in Cash Based Acctng');

           UPDATE AP_Invoice_Distributions DIST
              SET DIST.Pa_Addition_Flag = 'O',
                  request_id = G_REQUEST_ID,
                  last_update_date=SYSDATE,
                  last_updated_by=G_USER_ID,
                  last_update_login=G_USER_ID,
                  program_id=G_PROG_ID,
                  program_application_id=G_PROG_APPL_ID,
                  program_update_date=SYSDATE
            WHERE DIST.Posted_Flag = 'Y'
              AND DIST.Pa_Addition_Flag IN
                  ('S', 'A', 'B', 'C', 'D','H', 'I', 'J', 'K', 'L', 'M', 'N', 'P','Q', 'V', 'X')
              AND DIST.project_id > 0
              AND trunc(DIST.Accounting_Date) <= trunc(nvl(G_GL_DATE,DIST.Accounting_Date))   /*GSCC*/ /*Added trunc for the bug 6623163 */
              AND trunc(DIST.Expenditure_Item_Date) <=
                     trunc(NVL(G_TRANSACTION_DATE,DIST.Expenditure_Item_Date))       /*GSCC*/  /*Added trunc for the bug 6623163 */
              AND dist.line_type_lookup_code <> 'REC_TAX' -- do not proces recoverable tax
              AND (
                  EXISTS (
                    SELECT NULL
                    FROM ap_invoices_all inv,
                         po_distributions_all PO,
                         ap_invoice_distributions_all dist2
                    WHERE inv.invoice_id = dist2.invoice_id
                    AND nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'
                    AND dist2.invoice_id = DIST.invoice_id
                    AND dist2.invoice_distribution_id = DIST.invoice_distribution_id
                    AND inv.payment_status_flag = 'Y'                                 -- Flag indicates that Invoice has been FULLY paid
                    AND dist2.historical_flag = 'Y'                                     --Process Historical data as Invoices in Cash based
                    AND dist2.po_distribution_id = PO.po_distribution_id(+)
                    AND NVL(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
                    AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                    AND inv.PAID_ON_BEHALF_EMPLOYEE_ID IS NULL
                    AND inv.source not  in ('CREDIT CARD','Both Pay') /* Added for bug 8977795 */
                    AND ( nvl(INV.source, 'xx' ) NOT IN (
                              'PA_IC_INVOICES','PA_COST_ADJUSTMENTS')  /* Removed 'Oracle Project Accounting' */
                        or dist2.line_type_lookup_code = 'NONREC_TAX')
                       )
                  OR
                  EXISTS (
                    SELECT NULL
                    FROM ap_invoices inv1,
                         ap_invoice_distributions dist3
                    WHERE inv1.invoice_id = dist3.invoice_id
                    AND   inv1.invoice_id = dist.invoice_id
                    AND   inv1.invoice_type_lookup_code <> 'EXPENSE REPORT'
                    AND   (dist.reversal_flag = 'Y' or dist.cancellation_flag = 'Y' )
                    AND   dist3.invoice_distribution_id = dist.parent_reversal_id      --Process Historical data reversals as Invoices in Cash based
                    AND   dist3.pa_addition_flag = 'Y')
                  )
                /* Bug 6353803: Added the following for this bug. */
  	        AND   (pa_nl_installed.is_nl_installed = 'N'
                  OR (    pa_nl_installed.is_nl_installed = 'Y'
		    AND NOT EXISTS (SELECT 'X'
				    FROM  po_distributions_all pod, mtl_system_items si, po_lines_all pol
				    WHERE pod.po_distribution_id = dist.po_distribution_id
				    AND pod.po_line_id = pol.po_line_id
				    AND   si.inventory_item_id = pol.item_id
				    AND   si.comms_nl_trackable_flag = 'Y'
				    AND   si.organization_id = pod.org_id
				    )
		    AND NOT EXISTS (SELECT 'X'
			      FROM
				ap_invoice_distributions apdist,
				po_distributions pod,
				mtl_system_items si,
				po_lines_all pol
			      where DIST.CHARGE_APPLICABLE_TO_DIST_ID
                                    = apdist.INVOICE_DISTRIBUTION_ID
				  and apdist.po_distribution_id = pod.po_distribution_id
				  and pod.po_line_id = pol.po_line_id
				  and si.inventory_item_id = pol.item_id
				  AND   si.comms_nl_trackable_flag = 'Y'
				  AND   si.organization_id = pod.org_id
					     )
		    )
                  );


              G_DISTRIBUTIONS_MARKED := SQL%ROWCOUNT;
              write_log(LOG, 'Number of Historical Inv Dist marked to O: ' || to_char(SQL%ROWCOUNT));

           /* Historical Data Processing for Prepayments */
           /* All PREPAY application distributions that relate to PREPAYMENT invoice that was already interfaced into PRojects
              Pre Rel12 Upgrade should also be brought into Projects */

          write_log(LOG, 'Marking Historical Prepayments for processing...');

            UPDATE ap_invoice_distributions_all dist
            SET    dist.pa_addition_flag = 'O',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   dist.posted_flag ='Y'
            AND   dist.project_id > 0
            --AND   dist.line_type_lookup_code = 'PREPAY'
            AND   dist.line_type_lookup_code <> 'REC_TAX'
            AND   dist.prepay_distribution_id is not null
            AND   trunc(dist.Accounting_Date) <= trunc(nvl(G_GL_DATE,dist.Accounting_Date))
            AND   trunc(dist.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,dist.expenditure_item_date))
            AND   EXISTS (
                    SELECT NULL
                    FROM ap_invoices inv
                    WHERE inv.invoice_id = dist.invoice_id
                    AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                    AND inv.PAID_ON_BEHALF_EMPLOYEE_ID IS NULL
                     AND inv.source not  in ('CREDIT CARD','Both Pay') /* Added for bug 8977795 */
                    AND nvl(INV.source, 'xx' ) NOT IN (
                              'PA_IC_INVOICES','PA_COST_ADJUSTMENTS')  ) /* Removed 'Oracle Project Accounting' */
            AND   exists(SELECT inv.invoice_id
                           FROM AP_INVOICES_all inv,
                                AP_Invoice_Distributions_all aid
                          WHERE aid.invoice_id = inv.invoice_id
                            AND inv.invoice_type_lookup_code = 'PREPAYMENT'
                            AND aid.historical_flag = 'Y'
                            AND aid.pa_addition_flag = 'Y'
                            AND aid.invoice_distribution_id =  dist.prepay_distribution_id --Prepayment dist id
                            AND aid.project_id > 0 )
                /* Bug 6353803: Added the following for this bug. */
  	        AND   (pa_nl_installed.is_nl_installed = 'N'
                  OR (    pa_nl_installed.is_nl_installed = 'Y'
		    AND NOT EXISTS (SELECT 'X'
				    FROM  po_distributions_all pod, mtl_system_items si, po_lines_all pol
				    WHERE pod.po_distribution_id = dist.po_distribution_id
				    AND pod.po_line_id = pol.po_line_id
				    AND   si.inventory_item_id = pol.item_id
				    AND   si.comms_nl_trackable_flag = 'Y'
				    AND   si.organization_id = pod.org_id
				    )
		    AND NOT EXISTS (SELECT 'X'
			      FROM
				ap_invoice_distributions apdist,
				po_distributions pod,
				mtl_system_items si,
				po_lines_all pol
			      where DIST.CHARGE_APPLICABLE_TO_DIST_ID
                                    = apdist.INVOICE_DISTRIBUTION_ID
				  and apdist.po_distribution_id = pod.po_distribution_id
				  and pod.po_line_id = pol.po_line_id
				  and si.inventory_item_id = pol.item_id
				  AND   si.comms_nl_trackable_flag = 'Y'
				  AND   si.organization_id = pod.org_id
					     )
		    )
                  );

            G_DISTRIBUTIONS_MARKED := nvl(G_DISTRIBUTIONS_MARKED,0) + SQL%ROWCOUNT;
            write_log(LOG, 'Number of Historical PREPAY Appl Dist marked to O: ' || to_char(SQL%ROWCOUNT));


         ELSE -- Accrual BAsed Acctng

          -- Update pa-addition-flag to O for all valid ap distributions that should be interfaced to Projects
	   write_log(LOG, 'Marking invoices in Accrual based Acctng');

           UPDATE AP_Invoice_Distributions DIST
              SET DIST.Pa_Addition_Flag = 'O',
                  request_id = G_REQUEST_ID,
                  last_update_date=SYSDATE,
                  last_updated_by=G_USER_ID,
                  last_update_login=G_USER_ID,
                  program_id=G_PROG_ID,
                  program_application_id=G_PROG_APPL_ID,
                  program_update_date=SYSDATE
            WHERE DIST.Posted_Flag||'' = 'Y'
              AND DIST.Pa_Addition_Flag IN
                  ('S', 'A', 'B', 'C', 'D','H', 'I', 'J', 'K', 'L', 'M', 'N', 'P','Q', 'V', 'X')
              AND DIST.project_id > 0
              AND trunc(DIST.Accounting_Date )<= trunc(nvl(G_GL_DATE,DIST.Accounting_Date) )  /*GSCC*/
              AND trunc(DIST.Expenditure_Item_Date) <=
                     trunc(NVL(G_TRANSACTION_DATE, DIST.Expenditure_Item_Date))          /*GSCC*/
              AND dist.line_type_lookup_code <> 'REC_TAX' -- do not proces recoverable tax
              AND EXISTS (
                  SELECT NULL
                    FROM ap_invoices_all inv,
                         po_distributions_all PO,
                         ap_invoice_distributions_all dist2
                    WHERE inv.invoice_id = dist2.invoice_id
                    AND nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'
                    AND dist2.invoice_id = DIST.invoice_id
                    /* credit card txn enhancement, make sure this update doesn't pick tehm */
                    AND inv.PAID_ON_BEHALF_EMPLOYEE_ID IS NULL
                    AND inv.source not  in ('CREDIT CARD','Both Pay') /* Added for bug 8977795 */
                    AND dist2.invoice_distribution_id = DIST.invoice_distribution_id
                    AND dist2.po_distribution_id = PO.po_distribution_id(+)
                    AND NVL(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
                    AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                    -- IC Upgrade: Do not get Inter-company invoices
                    AND ( nvl(INV.source, 'xx' ) NOT IN (
                             'PA_IC_INVOICES','PA_COST_ADJUSTMENTS')  /* Removed 'Oracle Project Accounting' */
			    or
			 dist2.line_type_lookup_code = 'NONREC_TAX'
			 )
                        )
                /* Bug 6353803: Added the following for this bug. */
  	        AND   (pa_nl_installed.is_nl_installed = 'N'
                  OR (    pa_nl_installed.is_nl_installed = 'Y'
		    AND NOT EXISTS (SELECT 'X'
				    FROM  po_distributions_all pod, mtl_system_items si, po_lines_all pol
				    WHERE pod.po_distribution_id = dist.po_distribution_id
				    AND pod.po_line_id = pol.po_line_id
				    AND   si.inventory_item_id = pol.item_id
				    AND   si.comms_nl_trackable_flag = 'Y'
				    AND   si.organization_id = pod.org_id
				    )
		    AND NOT EXISTS (SELECT 'X'
			      FROM
				ap_invoice_distributions apdist,
				po_distributions pod,
				mtl_system_items si,
				po_lines_all pol
			      where DIST.CHARGE_APPLICABLE_TO_DIST_ID
                                    = apdist.INVOICE_DISTRIBUTION_ID
				  and apdist.po_distribution_id = pod.po_distribution_id
				  and pod.po_line_id = pol.po_line_id
				  and si.inventory_item_id = pol.item_id
				  AND   si.comms_nl_trackable_flag = 'Y'
				  AND   si.organization_id = pod.org_id
					     )
		    )
                  );


              G_DISTRIBUTIONS_MARKED := SQL%ROWCOUNT;
              write_log(LOG, 'Number of rows marked to O: ' || to_char(SQL%ROWCOUNT));

           END IF; -- End of Acctng method is CASH

         END IF;
         --
         -- End of If section checking if G_PROJECT_ID is not null
         --

     END IF;

     write_log(LOG, 'Total Number of rows marked to O: ' || to_char(G_DISTRIBUTIONS_MARKED));
     G_err_stack := v_old_stack;

EXCEPTION
     WHEN Others THEN
           -- Marking phase failed, raise exception to main program to terminate the program
           --
           G_err_stack := v_old_stack;
           G_err_code := SQLCODE;
           RAISE;

END mark_PAflag_O;

PROCEDURE transfer_inv_to_pa  IS

   v_num_invoices_fetched          NUMBER :=0;
   v_num_distributions_fetched     NUMBER :=0;
   v_prev_invoice_id               NUMBER := 0;
   v_prev_vendor_id                NUMBER := 0;
   v_old_stack                     VARCHAR2(630);
   v_err_message                   VARCHAR2(220);
   v_all_done                      NUMBER := 0;
   v_prev_invoice_source           ap_invoices.source%TYPE := NULL;
   v_prev_transaction_source       pa_transaction_sources.transaction_source%TYPE;
   v_num_tax_lines_fetched         NUMBER:=0;
   v_num_inv_variance_fetched      NUMBER:=0;    --NEW
   v_num_inv_erv_fetched           NUMBER:=0;    --NEW
   v_num_inv_frt_fetched           NUMBER:=0;    --NEW
   v_last_inv_ER_flag              VARCHAR2(1);

   v_status Number := 0;
   v_stage  Number :=0;
   v_business_group_id NUMBER := 0;
   v_attribute_category VARCHAR2(150);
   v_attribute1 VARCHAR2(150);
   v_attribute2 VARCHAR2(150);
   v_attribute3 VARCHAR2(150);
   v_attribute4 VARCHAR2(150);
   v_attribute5 VARCHAR2(150);
   v_attribute6 VARCHAR2(150);
   v_attribute7 VARCHAR2(150);
   v_attribute8 VARCHAR2(150);
   v_attribute9 VARCHAR2(150);
   v_attribute10 VARCHAR2(150);
   v_dff_map_status VARCHAR2(30);
   dff_map_exception EXCEPTION;

   v_num_last_invoice_processed NUMBER := 0;
   v_last_inv_index             NUMBER := 0;
   v_num_dist_marked_O          NUMBER := 0;
   v_num_dist_remain            NUMBER := 0;
   v_max_size                   NUMBER := 0;

   v_inv_batch_size             NUMBER := 0;
   v_tax_batch_size             NUMBER := 0;
   v_var_batch_size             NUMBER := 0;
   v_frt_batch_size             NUMBER := 0;

-- For PA IP Invoices
   L_IP_TRANSACTION_SOURCE         pa_transaction_interface.transaction_source%TYPE;
   l_ap_inv_flag                   VARCHAR2(1):= 'N';
   l_ip_inv_flag                   VARCHAR2(1):= 'N';

   CURSOR Num_Dist_Marked_O (p_invoice_id IN NUMBER) IS
      SELECT count(*)
         FROM ap_invoice_distributions
        WHERE invoice_id       = p_invoice_id
          AND pa_addition_flag = 'O';

   l_prev_cr_ccid NUMBER;
   l_prev_dr_ccid NUMBER;
   l_create_adj_recs  VARCHAR2(1) := 'N';

   /* the following sub-procedure is declared here to save lines of code since deleting
      plsql tables will be done multiple times within the procedure transfer_inv_to_pa */

   PROCEDURE clear_plsql_tables IS

       l_status1 VARCHAR2(30);

   BEGIN

       G_err_stage := 'within clear_plsql_tables of ransfer_inv_to_pa';
       write_log(LOG, G_err_stage);

       l_invoice_id_tbl.delete;
       l_created_by_tbl.delete;
       --l_dist_line_num_tbl.delete;
       l_invoice_dist_id_tbl.delete; --NEW
       l_project_id_tbl.delete;
       l_task_id_tbl.delete;
       l_ln_type_lookup_tbl.delete;
       l_exp_type_tbl.delete;
       l_ei_date_tbl.delete;
       l_amount_tbl.delete;
       l_description_tbl.delete;
       l_justification_tbl.delete;
       l_dist_cc_id_tbl.delete;
       l_exp_org_id_tbl.delete;
       l_quantity_tbl.delete;
       l_acct_pay_cc_id_tbl.delete;
       l_gl_date_tbl.delete;
       l_attribute_cat_tbl.delete;
       l_attribute1_tbl.delete;
       l_attribute2_tbl.delete;
       l_attribute3_tbl.delete;
       l_attribute4_tbl.delete;
       l_attribute5_tbl.delete;
       l_attribute6_tbl.delete;
       l_attribute7_tbl.delete;
       l_attribute8_tbl.delete;
       l_attribute9_tbl.delete;
       l_attribute10_tbl.delete;
       l_rec_cur_amt_tbl.delete;
       l_rec_cur_code_tbl.delete;
       l_rec_conv_rate_tbl.delete;
       l_denom_raw_cost_tbl.delete;
       l_denom_cur_code_tbl.delete;
       l_acct_rate_date_tbl.delete;
       l_acct_rate_type_tbl.delete;
       l_acct_exch_rate_tbl.delete;
       l_job_id_tbl.delete;
       l_employee_id_tbl.delete;
       l_vendor_id_tbl.delete;
       l_inv_type_code_tbl.delete;
       l_source_tbl.delete;
       l_org_id_tbl.delete;
       l_invoice_num_tbl.delete;
       l_cdl_sys_ref4_tbl.delete;
       l_po_dist_id_tbl.delete;
       l_txn_src_tbl.delete;
       l_user_txn_src_tbl.delete;
       l_batch_name_tbl.delete;
       l_interface_id_tbl.delete;
       l_exp_end_date_tbl.delete;
       l_txn_status_code_tbl.delete;
       l_txn_rej_code_tbl.delete;
       l_po_dist_id_tbl.delete;
       l_bus_grp_id_tbl.delete;
       l_paid_emp_id_tbl.delete;
       l_sort_var_tbl.delete;
       l_reversal_flag_tbl.delete; --NEW
       l_cancel_flag_tbl.delete;  --NEW
       l_parent_rev_id_tbl.delete; --NEW
       l_net_zero_flag_tbl.delete; --NEW
       l_sc_xfer_code_tbl.delete; --NEW
       l_adj_exp_item_id_tbl.delete; --NEW
       l_fc_enabled_tbl.delete; --NEW
       l_fc_document_type_tbl.delete; --NEW
       l_insert_flag_tbl.delete;
       l_rev_parent_dist_id_tbl.delete;
       l_rev_child_dist_id_tbl.delete;
       l_rev_parent_dist_ind_tbl.delete;
       l_si_assts_add_flg_tbl.delete;
       l_prepay_dist_id_tbl.delete;
       l_hist_flag_tbl.delete;
       l_rev_index:=0;

    END clear_plsql_tables;

   /* the following sub-procedure is declared here to save lines of code since bulk insert
      will be done multiple times within the procedure transfer_inv_to_pa */

    PROCEDURE bulk_update_trx_intf IS

     BEGIN

       /* The records with INSERT_FLAG = F indicate that they are fully applied prepayments and the pa-addition-flag
          for such records will be updated to G to relieve commitments*/
       /* The records with INSERT_FLAG = P indicate that they are partially applied prepayments and the pa-addition-flag
          for such records will be updated to N */

       write_log(LOG,'Before bulk update  of prepayment invoices');

       FORALL i IN l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST

         UPDATE ap_invoice_distributions_all dist
            SET dist.pa_addition_flag         = decode(l_insert_flag_tbl(i),'F','G','P','N')
          WHERE dist.invoice_id               = l_invoice_id_tbl(i)
            AND dist.invoice_distribution_id  = l_invoice_dist_id_tbl(i)
            AND dist.pa_addition_flag         = 'O'
            AND l_insert_flag_tbl(i)         in ('P','F');

     EXCEPTION
      WHEN OTHERS THEN
          write_log(LOG,'Failed during bulk update for prepayment processing');
          G_err_code   := SQLCODE;
          write_log(LOG, 'Error Code is '||SQLCODE);
          write_log(LOG, substr(SQLERRM, 1, 200));
          write_log(LOG, substr(SQLERRM, 201, 200));
          raise;

    END bulk_update_trx_intf;

    PROCEDURE bulk_insert_trx_intf IS

      l_status2 VARCHAR2(30);


    BEGIN

       write_log(LOG,'Before bulk insert of supplier invoices');

      If g_body_debug_mode = 'Y' Then
       FOR i IN l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST  LOOP
          write_log(LOG,   '1:'||   l_txn_src_tbl(i));
          write_log(LOG,   '2:'||   l_user_txn_src_tbl(i));
          write_log(LOG,   '3:'||   l_batch_name_tbl(i));
          write_log(LOG,      '4:'||to_char(l_exp_end_date_tbl(i)));
          write_log(LOG,      '6:'||to_char(l_ei_date_tbl(i)));
          write_log(LOG,      '7:'||l_exp_type_tbl(i));
          write_log(LOG,      '8:'||to_char(l_quantity_tbl(i)));
          write_log(LOG,      '9:'||l_description_tbl(i));
          write_log(LOG,      '10:'||l_txn_status_code_tbl(i));
          write_log(LOG,      '11:'||l_txn_rej_code_tbl(i));
          write_log(LOG,      '12:'||to_char(l_interface_id_tbl(i)));
          write_log(LOG,      '13:'||to_char(l_dist_cc_id_tbl(i)));
          write_log(LOG,      '14:'||to_char(l_acct_pay_cc_id_tbl(i)));
          write_log(LOG,      '15:'||to_char(l_vendor_id_tbl(i) ));
          write_log(LOG,      '16:'||to_char(l_invoice_id_tbl(i) ));
          write_log(LOG,      '17:'||l_cdl_sys_ref4_tbl(i));
          write_log(LOG,      '18:'||to_char(l_invoice_dist_id_tbl(i) ));
          write_log(LOG,      '19:'||to_char(l_gl_date_tbl(i)));
          write_log(LOG,      '20:'||to_char(l_rec_cur_amt_tbl(i)));
          write_log(LOG,      '21:'||l_rec_cur_code_tbl(i));
          write_log(LOG,      '22:'||l_rec_conv_rate_tbl(i));
          write_log(LOG,      '23:'||to_char(l_denom_raw_cost_tbl(i)));
          write_log(LOG,      '24:'||l_denom_cur_code_tbl(i));
          write_log(LOG,      '25:'||to_char(l_acct_rate_date_tbl(i)));
          write_log(LOG,      '26:'||l_acct_rate_type_tbl(i));
          write_log(LOG,      '27:'||to_char(l_acct_exch_rate_tbl(i)));
          write_log(LOG,      '28:'||to_char(l_amount_tbl(i)));
          write_log(LOG,      '29:'||l_attribute_cat_tbl(i));
          write_log(LOG,      '30:'||l_attribute1_tbl(i));
          write_log(LOG,      '31:'||l_attribute2_tbl(i));
          write_log(LOG,      '32:'||l_attribute3_tbl(i));
          write_log(LOG,      '33:'||l_attribute4_tbl(i));
          write_log(LOG,      '34:'||l_attribute5_tbl(i));
          write_log(LOG,      '35:'||l_attribute6_tbl(i));
          write_log(LOG,      '36:'||l_attribute7_tbl(i));
          write_log(LOG,      '37:'||l_attribute8_tbl(i));
          write_log(LOG,      '38:'||l_attribute9_tbl(i));
          write_log(LOG,      '39:'||l_attribute10_tbl(i));
          write_log(LOG,      '40:'||to_char(l_invoice_id_tbl(i) ));
          write_log(LOG,      '41:'||l_invoice_num_tbl(i));
          write_log(LOG,      '42:'||to_char(l_invoice_id_tbl(i) ));
          write_log(LOG,      '43:'||to_char(l_employee_id_tbl(i)));
          write_log(LOG,      '44:'||to_char(l_org_id_tbl(i)));
          write_log(LOG,      '45:'||to_char(l_project_id_tbl(i)));
          write_log(LOG,      '46:'||to_char(l_task_id_tbl(i)));
          write_log(LOG,      '47:'||to_char(l_vendor_id_tbl(i)));
          write_log(LOG,      '48:'||to_char(l_exp_org_id_tbl(i)));
          write_log(LOG,      '49:'||to_char(l_bus_grp_id_tbl(i)));
          write_log(LOG,      '50:'||to_char(l_adj_exp_item_id_tbl(i) ));
          write_log(LOG,      '51:'||l_fc_document_type_tbl(i) );
          write_log(LOG,      '52:'||l_inv_type_code_tbl(i));
          write_log(LOG,      '53:'||l_ln_type_lookup_tbl(i));
          write_log(LOG,      '54:'||l_net_zero_flag_tbl(i));
          write_log(LOG,      '55:'||l_si_assts_add_flg_tbl(i));
          write_log(LOG,      '56:'||l_cdl_sys_ref3_tbl(i));
          write_log(LOG,      '57:'||l_net_zero_flag_tbl(i));
          write_log(LOG,      '58:'||l_insert_flag_tbl(i));
          write_log(LOG,      '59:'||G_UNIQUE_ID);
       END LOOP;
     End If;

       FORALL i IN l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST

       INSERT INTO pa_transaction_interface_all(
                     transaction_source
                    , user_transaction_source
                    , system_linkage
                    , batch_name
                    , expenditure_ending_date
                    , expenditure_item_date
                    , expenditure_type
                    , quantity
                    , raw_cost_rate
                    , expenditure_comment
                    , transaction_status_code
                    , transaction_rejection_code
                    , orig_transaction_reference
                    , interface_id
                    , dr_code_combination_id
                    , cr_code_combination_id
                    , cdl_system_reference1
                    , cdl_system_reference2
                    , cdl_system_reference3
                    , cdl_system_reference4
                    , cdl_system_reference5 --NEW
                    , gl_date
                    , org_id
                    , unmatched_negative_txn_flag
                    , receipt_currency_amount
                    , receipt_currency_code
                    , receipt_exchange_rate
                    , denom_raw_cost
                    , denom_currency_code
                    , acct_rate_date
                    , acct_rate_type
                    , acct_exchange_rate
                    , acct_raw_cost
                    , acct_exchange_rounding_limit
                    , attribute_category
                    , attribute1
                    , attribute2
                    , attribute3
                    , attribute4
                    , attribute5
                    , attribute6
                    , attribute7
                    , attribute8
                    , attribute9
                    , attribute10
                    , orig_exp_txn_reference1
                    , orig_user_exp_txn_reference
                    , orig_exp_txn_reference2
                    , orig_exp_txn_reference3
                    , last_update_date
                    , last_updated_by
                    , creation_date
                    , created_by
                    , person_id
                    , organization_id
                    , project_id
                    , task_id
                    , Vendor_id
                    , override_to_organization_id
                    , person_business_group_id
                    , adjusted_expenditure_item_id --NEW
                    , fc_document_type  -- NEW
                    , document_type
                    , document_distribution_type
                    , sc_xfer_code
                    , si_assets_addition_flag
                    , net_zero_adjustment_flag
                   )
                  SELECT
                      l_txn_src_tbl(i)
                     ,l_user_txn_src_tbl(i)
                     ,G_SYSTEM_LINKAGE
                     ,l_batch_name_tbl(i)
                     ,l_exp_end_date_tbl(i)
                     ,l_ei_date_tbl(i)
                     ,l_exp_type_tbl(i)
                     ,l_quantity_tbl(i)
                     ,l_amount_tbl(i)/decode(nvl(l_quantity_tbl(i),0),0,1,l_quantity_tbl(i))
                     ,l_description_tbl(i)
                     ,l_txn_status_code_tbl(i)
                     ,l_txn_rej_code_tbl(i)
                     ,G_REQUEST_ID
                     ,l_interface_id_tbl(i)
                     ,l_dist_cc_id_tbl(i)
                     ,l_acct_pay_cc_id_tbl(i)
                     ,l_vendor_id_tbl(i) /*sysref1*/
                     ,l_invoice_id_tbl(i) /*sysref2*/
                     ,l_cdl_sys_ref3_tbl(i)  --NULL /*sysref3*/
                     ,l_cdl_sys_ref4_tbl(i)
                     ,l_invoice_dist_id_tbl(i) /*sysref5*/ --NEW
                     ,l_gl_date_tbl(i)
                     ,G_ORG_ID
                     ,'Y'
                     ,l_rec_cur_amt_tbl(i)
                     ,l_rec_cur_code_tbl(i)
                     ,l_rec_conv_rate_tbl(i)
                     ,l_denom_raw_cost_tbl(i)
                     ,l_denom_cur_code_tbl(i)
                     ,l_acct_rate_date_tbl(i)
                     ,l_acct_rate_type_tbl(i)
                     ,l_acct_exch_rate_tbl(i)
                     ,l_amount_tbl(i)
                     ,1
                     ,l_attribute_cat_tbl(i)
                     ,l_attribute1_tbl(i)
                     ,l_attribute2_tbl(i)
                     ,l_attribute3_tbl(i)
                     ,l_attribute4_tbl(i)
                     ,l_attribute5_tbl(i)
                     ,l_attribute6_tbl(i)
                     ,l_attribute7_tbl(i)
                     ,l_attribute8_tbl(i)
                     ,l_attribute9_tbl(i)
                     ,l_attribute10_tbl(i)
                     ,l_invoice_id_tbl(i)        /*orig_exp_txn_reference1*/
                     ,l_invoice_num_tbl(i)       /*user_exp_txn_reference*/
                     /* bug 2835757*/
                     ,DECODE(G_TRANS_DFF_AP,'N',NULL,l_invoice_id_tbl(i)) /*orig_exp_txn_reference2*/
                     ,NULL                       /*orig_exp_txn_reference3*/
                     ,SYSDATE
                     ,-1
                     ,SYSDATE
                     ,-1
                     ,l_employee_id_tbl(i)
                     ,l_org_id_tbl(i)
                     ,l_project_id_tbl(i)
                     ,l_task_id_tbl(i)
                     ,l_vendor_id_tbl(i)
                     ,l_exp_org_id_tbl(i)
                     ,l_bus_grp_id_tbl(i)
                     ,l_adj_exp_item_id_tbl(i) --NEW for reversals
                     ,l_fc_document_type_tbl(i) --NEW for funds check
                     ,l_inv_type_code_tbl(i)
                     ,l_ln_type_lookup_tbl(i)
                     ,l_sc_xfer_code_tbl(i)
                     ,l_si_assts_add_flg_tbl(i)
                     ,l_net_zero_flag_tbl(i)
                FROM dual
                WHERE l_insert_flag_tbl(i) not in ('F', 'P');

              -- Insert the reversal of reversed/cancelled invoice distribution recs from AP.
    IF l_create_adj_recs = 'Y' THEN

                write_log(LOG, 'Inserting adjustment records..');


       FORALL i IN l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST
       INSERT INTO pa_transaction_interface_all(
                     transaction_source
                    , user_transaction_source
                    , system_linkage
                    , batch_name
                    , expenditure_ending_date
                    , expenditure_item_date
                    , expenditure_type
                    , quantity
                    , raw_cost_rate
                    , expenditure_comment
                    , transaction_status_code
                    , transaction_rejection_code
                    , orig_transaction_reference
                    , interface_id
                    , dr_code_combination_id
                    , cr_code_combination_id
                    , cdl_system_reference1
                    , cdl_system_reference2
                    , cdl_system_reference3
                    , cdl_system_reference4
                    , cdl_system_reference5 --NEW
                    , gl_date
                    , org_id
                    , unmatched_negative_txn_flag
                    , receipt_currency_amount
                    , receipt_currency_code
                    , receipt_exchange_rate
                    , denom_raw_cost
                    , denom_currency_code
                    , acct_rate_date
                    , acct_rate_type
                    , acct_exchange_rate
                    , acct_raw_cost
                    , acct_exchange_rounding_limit
                    , attribute_category
                    , attribute1
                    , attribute2
                    , attribute3
                    , attribute4
                    , attribute5
                    , attribute6
                    , attribute7
                    , attribute8
                    , attribute9
                    , attribute10
                    , orig_exp_txn_reference1
                    , orig_user_exp_txn_reference
                    , orig_exp_txn_reference2
                    , orig_exp_txn_reference3
                    , last_update_date
                    , last_updated_by
                    , creation_date
                    , created_by
                    , person_id
                    , organization_id
                    , project_id
                    , task_id
                    , Vendor_id
                    , override_to_organization_id
                    , person_business_group_id
                    , adjusted_expenditure_item_id --NEW
                    , fc_document_type  -- NEW
                    , document_type
                    , document_distribution_type
                    , adjusted_txn_interface_id
                    , sc_xfer_code
                    , si_assets_addition_flag
                    , net_zero_adjustment_flag
                   )
                  SELECT
                      l_txn_src_tbl(i)
                     ,l_user_txn_src_tbl(i)
                     ,G_SYSTEM_LINKAGE
                     ,l_batch_name_tbl(i)
                     ,l_exp_end_date_tbl(i)
                     ,l_ei_date_tbl(i)
                     ,l_exp_type_tbl(i)
                     ,-l_quantity_tbl(i)
                     ,l_amount_tbl(i)/decode(nvl(l_quantity_tbl(i),0),0,1,l_quantity_tbl(i))
                     ,l_description_tbl(i)
                     ,l_txn_status_code_tbl(i)
                     ,l_txn_rej_code_tbl(i)
                     ,G_REQUEST_ID
                     ,l_interface_id_tbl(i)
                     ,l_dist_cc_id_tbl(i)
                     ,l_acct_pay_cc_id_tbl(i)
                     ,l_vendor_id_tbl(i) /*sysref1*/
                     ,l_invoice_id_tbl(i) /*sysref2*/
                     ,l_cdl_sys_ref3_tbl(i)  --NULL /*sysref3*/
                     ,l_cdl_sys_ref4_tbl(i)
                     ,l_invoice_dist_id_tbl(i) /*sysref5*/ --NEW
                     ,l_gl_date_tbl(i)
                     ,G_ORG_ID
                     ,'Y'
                     ,-l_rec_cur_amt_tbl(i)
                     ,l_rec_cur_code_tbl(i)
                     ,l_rec_conv_rate_tbl(i)
                     ,-l_denom_raw_cost_tbl(i)
                     ,l_denom_cur_code_tbl(i)
                     ,l_acct_rate_date_tbl(i)
                     ,l_acct_rate_type_tbl(i)
                     ,l_acct_exch_rate_tbl(i)
                     ,-l_amount_tbl(i)
                     ,1
                     ,l_attribute_cat_tbl(i)
                     ,l_attribute1_tbl(i)
                     ,l_attribute2_tbl(i)
                     ,l_attribute3_tbl(i)
                     ,l_attribute4_tbl(i)
                     ,l_attribute5_tbl(i)
                     ,l_attribute6_tbl(i)
                     ,l_attribute7_tbl(i)
                     ,l_attribute8_tbl(i)
                     ,l_attribute9_tbl(i)
                     ,l_attribute10_tbl(i)
                     ,l_invoice_id_tbl(i)        /*orig_exp_txn_reference1*/
                     ,l_invoice_num_tbl(i)       /*user_exp_txn_reference*/
                     /* bug 2835757*/
                     ,DECODE(G_TRANS_DFF_AP,'N',NULL,l_invoice_id_tbl(i)) /*orig_exp_txn_reference2*/
                     ,NULL                       /*orig_exp_txn_reference3*/
                     ,SYSDATE
                     ,-1
                     ,SYSDATE
                     ,-1
                     ,l_employee_id_tbl(i)
                     ,l_org_id_tbl(i)
                     ,l_project_id_tbl(i)
                     ,l_task_id_tbl(i)
                     ,l_vendor_id_tbl(i)
                     ,l_exp_org_id_tbl(i)
                     ,l_bus_grp_id_tbl(i)
                     ,l_adj_exp_item_id_tbl(i) --NEW for reversals
                     ,l_fc_document_type_tbl(i) --NEW for funds check
                     ,l_inv_type_code_tbl(i)
                     ,l_ln_type_lookup_tbl(i)
                     ,(select xface.txn_interface_id
                       from   pa_transaction_interface xface
                       where  xface.interface_id = l_interface_id_tbl(i)
                       and    xface.cdl_system_reference2 = l_invoice_id_tbl(i)
                       and    xface.cdl_system_reference5 = l_invoice_dist_id_tbl(i)
		       and    NVL(xface.adjusted_expenditure_item_id,0) = 0 ) -- R12 funds management Uptake
                     ,'P' -- sc_xfer_code
                     ,'T' -- l_si_assts_add_flg_tbl(i)
                     ,l_net_zero_flag_tbl(i)
                FROM dual
                WHERE l_insert_flag_tbl(i)= 'A';

               -- Handle both the parent and the reversal getting interfaced into PA
               -- in the same run.
                write_log(LOG, 'Updating  adjustment records..');

              IF l_rev_child_dist_id_tbl.exists(1) THEN

               FOR i in l_rev_child_dist_id_tbl.FIRST ..l_rev_child_dist_id_tbl.LAST LOOP

                   IF l_rev_child_dist_id_tbl(i) > 0 THEN

                    UPDATE pa_transaction_interface_all xface
                    SET    xface.net_zero_adjustment_flag ='Y',
                           xface.adjusted_txn_interface_id =
                              (select distinct  xface1.txn_interface_id  /*Added Distinct for bug 9266578 */
                               from   pa_transaction_interface xface1
                               where  xface1.interface_id = l_interface_id_tbl(l_rev_parent_dist_ind_tbl(i))
                               and    xface1.cdl_system_reference2 = l_invoice_id_tbl(l_rev_parent_dist_ind_tbl(i))
                               and    xface1.cdl_system_reference5 = l_invoice_dist_id_tbl(l_rev_parent_dist_ind_tbl(i))
                               )
                      WHERE  xface.interface_id = l_interface_id_tbl(l_rev_parent_dist_ind_tbl(i))
                      AND    xface.cdl_system_reference2 = l_invoice_id_tbl(l_rev_parent_dist_ind_tbl(i))
                      AND    xface.cdl_system_reference5 = l_rev_child_dist_id_tbl(i);

                   END IF;

               END LOOP;

              END IF;
    END IF;

   EXCEPTION
      WHEN OTHERS THEN
          write_log(LOG,'Failed during bulk insert for invoice processing');
          G_err_code   := SQLCODE;
          write_log(LOG, 'Error Code is '||SQLCODE);
          write_log(LOG, substr(SQLERRM, 1, 200));
          write_log(LOG, substr(SQLERRM, 201, 200));
          raise;

   END bulk_insert_trx_intf;

   PROCEDURE process_inv_logic IS

       l_status3 VARCHAR2(30);
       j NUMBER := 0; --Index variable for creating reversal EI's --NEW
       l_historical_flag VARCHAR2(1);  --NEW
       l_process_adjustments    Number := 0 ;
       l_prepay_hist_flag VARCHAR2(1);

   BEGIN

       G_err_stage := ('Within Calling process logic of transfer_inv_to_pa');
       write_log(LOG, G_err_stage);

       /* Initializing global variables here to reduce code lines */
       G_NRT_TRANSACTION_SOURCE      := 'AP NRTAX' ;
       G_NRT_USER_TRANSACTION_SOURCE := 'Non-Recoverable Tax From Payables';

       G_AP_VAR_TRANSACTION_SOURCE  := 'AP VARIANCE';                                --NEW
       G_AP_VAR_USER_TXN_SOURCE     := 'Oracle Payables Invoice Variance';           --NEW

       G_AP_ERV_TRANSACTION_SOURCE  := 'AP ERV';                                --NEW
       G_AP_ERV_USER_TXN_SOURCE     := 'Oracle Payables Supplier Cost Exchange Rate Variance';           --NEW

       j := v_last_inv_index; -- initialize j to the total invoice distributions fetched in the PLSQL array

       FOR i IN  l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST  LOOP

           write_log(LOG,'Processing invoice id:  '||l_invoice_id_tbl(i)|| 'dist id:  '||l_invoice_dist_id_tbl(i));  --NEW

           /* We need to lock the corresponding receipts right away for each invoice distribution*/
           IF l_po_dist_id_tbl(i) IS NOT NULL
              -- Below clause added so that rcv trx not updated to status G for variance processing
              and l_ln_type_lookup_tbl(i) IN ('ITEM','ACCRUAL','RETROACCRUAL','NONREC_TAX')  THEN
              lock_rcv_txn(l_po_dist_id_tbl(i));
           END IF;

           G_TRANSACTION_REJECTION_CODE := '';

           IF l_source_tbl(i) in ('CREDIT CARD','Both Pay') THEN

              write_log(LOG,'This is a credit card txn, setting emp id to paid_emp_id.');
              l_employee_id_tbl(i)   := l_paid_emp_id_tbl(i);
              l_inv_type_code_tbl(i) := 'EXPENSE REPORT';

           ELSIF l_inv_type_code_tbl(i) = 'EXPENSE REPORT' and l_employee_id_tbl(i) is null THEN
              write_log(LOG,'This is a CWK Exp Report, setting emp id to paid_emp_id.');
              l_employee_id_tbl(i)   := l_paid_emp_id_tbl(i);

           END IF;

           /* The following will be executed if the distribution being fetched belongs to a new invoice */
           IF (l_invoice_id_tbl(i) <> v_prev_invoice_id) THEN

               G_err_stage := ('New invoice being processed.New invoice _id is:'||l_invoice_id_tbl(i));
               write_log(LOG, G_err_stage);

               /* Update the previous invoice id and vendor id*/
               v_prev_invoice_id := l_invoice_id_tbl(i);
               v_prev_vendor_id  := l_vendor_id_tbl(i);

               /* Increment the counter for invoices */
              v_num_invoices_fetched := v_num_invoices_fetched + 1;  --uncommented for bug:7692973

               IF nvl(v_prev_invoice_source,l_source_tbl(i)||'111') <> l_source_tbl(i) THEN

                  /* First update the v_prev_invoice_source */
                  G_err_stage := 'New source encountered';
                  write_log(LOG, G_err_stage);
                  v_prev_invoice_source := l_source_tbl(i);


                  IF l_source_tbl(i) = 'PA_IP_INVOICES' THEN

                     G_err_stage := 'Invoice source is Inter-Company Invoice';
                     write_log(LOG, G_err_stage);
                     G_TRANSACTION_SOURCE      := 'INTERPROJECT_AP_INVOICES';
                     v_prev_transaction_source := G_TRANSACTION_SOURCE;
                     G_USER_TRANSACTION_SOURCE := 'Oracle Inter-Project Invoices';

                     L_IP_TRANSACTION_SOURCE      := 'INTERPROJECT_AP_INVOICES';
                     l_ip_inv_flag                := 'Y' ;

                  ELSIF (l_source_tbl(i)        = 'XpenseXpress' OR
                         /* if its a Credit card txn, treat like expense report*/
                         l_source_tbl(i) in ('CREDIT CARD','Both Pay') OR
                        (l_source_tbl(i)        = 'Manual Invoice Entry' AND
                         l_inv_type_code_tbl(i) = 'EXPENSE REPORT') OR
                         l_source_tbl(i)        = 'SelfService') THEN

                      G_err_stage := 'Invoice source is Expense Reports';
                      write_log(LOG, G_err_stage);
                      G_TRANSACTION_SOURCE      := 'AP EXPENSE';
                      v_prev_transaction_source := G_TRANSACTION_SOURCE;
                      G_USER_TRANSACTION_SOURCE := 'ORACLE PAYABLES';

                  ELSE

                      G_err_stage := 'Invoice source is AP Invoice';
                      write_log(LOG, G_err_stage);
                      G_TRANSACTION_SOURCE             := 'AP INVOICE';
                      v_prev_transaction_source := G_TRANSACTION_SOURCE;

                      G_USER_TRANSACTION_SOURCE        := 'AP INVOICE';
                      l_ap_inv_flag                    := 'Y' ;

                  END IF;

               END IF; /* invoice source <> v_prev_tranasction_source */

                /* For new invoice, initialize the transaction status code to 'P' */
                G_TRANSACTION_STATUS_CODE := 'P';

                G_err_stage := 'GET MAX EXPENDITURE ENDING DATE';
                write_log(LOG, G_err_stage);
                SELECT pa_utils.getweekending(MAX(expenditure_item_date))
                  INTO G_EXPENDITURE_ENDING_DATE
                  FROM ap_invoice_distributions
                 WHERE invoice_id = l_invoice_id_tbl(i);

                G_err_stage := ('Getting bus group id');
                write_log(LOG, G_err_stage);

                BEGIN

                   IF l_employee_id_tbl(i) <> 0 THEN
		   Begin
                      write_log(LOG,'getting bus group id with emp id of :  '||l_employee_id_tbl(i));

                      SELECT emp.business_group_id
                        INTO G_PER_BUS_GRP_ID
                        FROM per_all_people_f emp
                       WHERE emp.person_id = l_employee_id_tbl(i)
                          AND l_ei_date_tbl(i) between trunc(emp.effective_start_date) and trunc(emp.effective_end_date);

			EXCEPTION
			   WHEN NO_DATA_FOUND THEN
			      l_txn_status_code_tbl(i)     := 'R';
			      G_TRANSACTION_REJECTION_CODE := 'INVALID_EMPLOYEE';
			      write_log(LOG, 'As no data found for Employee, Rejecting invoice'||l_invoice_id_tbl(i)  );
 		    End;
		   Else
		    Begin

			    select org2.business_group_id
			      into G_PER_BUS_GRP_ID
			      from hr_organization_units org1,
				   hr_organization_units org2
			     Where org1.organization_id = l_exp_org_id_tbl(i)
			       and org1.business_group_id = org2.organization_id ;

			    Exception
			      When no_data_found Then
				G_TRANSACTION_STATUS_CODE := 'R';
				G_TRANSACTION_REJECTION_CODE := 'INVALID_ORGANIZATION';
				write_log(LOG,'As no data found for Organization,Rejecting invoice '||l_invoice_id_tbl(i)  );
		     End;
        	END IF;   /* IF l_employee_id_tbl(i) <> 0 THEN  */

                END;

           END IF; /* end of check for different invoice_id from previous invoice_id */


           /* The following will be executed when the distribution belongs to the same
              invoice or not the same invoice */

           v_num_distributions_fetched := v_num_distributions_fetched + 1;
           write_log(LOG,'Num of distributions fetched:'||v_num_distributions_fetched);

           /*Update counter of how many distributions of the last invoice of the batch has been processed*/

           IF l_invoice_id_tbl(i) = l_invoice_id_tbl(v_last_inv_index) THEN
              v_num_last_invoice_processed := v_num_last_invoice_processed +1;

              IF l_inv_type_code_tbl(i) = 'EXPENSE REPORT' THEN
                 v_last_inv_ER_flag := 'Y';
              ELSE
                 v_last_inv_ER_flag := 'N';
              END IF;

           END IF;

           -- FC Doc Type
            IF l_fc_enabled_tbl(i) = 'N' THEN
             l_fc_document_type_tbl(i) := 'NOT';
            END IF;

           /* if the invoice is an expense report from self-service we need to use the column of justification as the description */
           IF (l_inv_type_code_tbl(i) = 'EXPENSE REPORT' AND
               l_source_tbl(i)        in ('SelfService','XpenseXpress') ) THEN
               l_description_tbl(i) := l_justification_tbl(i);
           END IF;

           IF l_ln_type_lookup_tbl(i)  in ('NONREC_TAX','TRV','TIPV') THEN

              /* Update counter for number of tax lines fetched */
              v_num_tax_lines_fetched := v_num_tax_lines_fetched +1;

              l_cdl_sys_ref4_tbl(i) := l_ln_type_lookup_tbl(i);
              l_txn_src_tbl(i)      := G_NRT_TRANSACTION_SOURCE;
              l_user_txn_src_tbl(i) := G_NRT_USER_TRANSACTION_SOURCE;
              l_batch_name_tbl(i)   := G_NRT_BATCH_NAME;
              l_interface_id_tbl(i) := G_NRT_INTERFACE_ID;

           ELSIF l_ln_type_lookup_tbl(i) = 'IPV' THEN

              /* Update counter for number of variance lines fetched */
              v_num_inv_variance_fetched :=  v_num_inv_variance_fetched +1;

              l_quantity_tbl(i)     := l_denom_raw_cost_tbl(i);
              l_cdl_sys_ref4_tbl(i) := l_ln_type_lookup_tbl(i);

              l_txn_src_tbl(i)      := G_AP_VAR_TRANSACTION_SOURCE;
              l_user_txn_src_tbl(i) := G_AP_VAR_USER_TXN_SOURCE;
              l_batch_name_tbl(i)   := G_AP_VAR_BATCH_NAME;
              l_interface_id_tbl(i) := G_AP_VAR_INTERFACE_ID;

           ELSIF l_ln_type_lookup_tbl(i) in ('ERV','TERV') THEN

              /* Update counter for number of variance lines fetched */
              v_num_inv_erv_fetched :=  v_num_inv_erv_fetched +1;

              l_quantity_tbl(i)     := l_denom_raw_cost_tbl(i);
              l_cdl_sys_ref4_tbl(i) := l_ln_type_lookup_tbl(i);

              l_txn_src_tbl(i)      := G_AP_ERV_TRANSACTION_SOURCE;
              l_user_txn_src_tbl(i) := G_AP_ERV_USER_TXN_SOURCE;
              l_batch_name_tbl(i)   := G_AP_ERV_BATCH_NAME;
              l_interface_id_tbl(i) := G_AP_ERV_INTERFACE_ID;


           ELSIF  l_ln_type_lookup_tbl(i) in ('FREIGHT','MISCELLANEOUS') THEN
              /* Update counter for number of frt and misc lines fetched */
              v_num_inv_frt_fetched :=  v_num_inv_frt_fetched +1;

              l_cdl_sys_ref4_tbl(i) := l_ln_type_lookup_tbl(i);
              l_txn_src_tbl(i)      := G_TRANSACTION_SOURCE;
              l_user_txn_src_tbl(i) := G_USER_TRANSACTION_SOURCE;
              l_batch_name_tbl(i)   := G_AP_FRT_BATCH_NAME;
              l_interface_id_tbl(i) := G_AP_FRT_INTERFACE_ID;

           ELSE -- Other distribution types like ITEM,ACCRUAL,PREPAY etc

              l_txn_src_tbl(i)      := G_TRANSACTION_SOURCE;
              l_user_txn_src_tbl(i) := G_USER_TRANSACTION_SOURCE;
              l_batch_name_tbl(i)   := G_BATCH_NAME;
              l_interface_id_tbl(i) := G_INTERFACE_ID;

           END IF ;

           G_TRANSACTION_REJECTION_CODE := '';

           /*Setting values according to global variables*/
           l_bus_grp_id_tbl(i)      := G_PER_BUS_GRP_ID;
           l_exp_end_date_tbl(i)    := G_EXPENDITURE_ENDING_DATE;
           l_txn_rej_code_tbl(i)    := G_TRANSACTION_REJECTION_CODE;
           l_txn_status_code_tbl(i) := G_TRANSACTION_STATUS_CODE;

           write_log(LOG,'Value of l_txn_src_tbl:'||l_txn_src_tbl(i) ||'batch name:'||l_batch_name_tbl(i));

           /*-----------------------------------------------------------------------*/
           /*         PREPAYMENT PROCESSING */
           /*-----------------------------------------------------------------------*/
           /* In Rel12 we will not interface any R12 PREPAYMENT invoice or PREPAY applications to Oracle Projects */
           /* Howver we will still continue to interface reversals or prepayment application related to 11i PREPAYENT invoices */
           --
           /* The records with INSERT_FLAG = F indicate that they are fully applied prepayments and the pa-addition-flag
              for such records will be updated to G to relieve commitments*/
           /* The records with INSERT_FLAG = P indicate that they are partially applied prepayments and the pa-addition-flag
              for such records will be updated to N */

           l_prepay_hist_flag := 'X'; --initialize

           IF nvl(l_hist_flag_tbl(i),'N') = 'Y' THEN

              l_prepay_hist_flag := 'Y';

           ELSE

             IF (l_prepay_dist_id_tbl(i) is not null OR l_ln_type_lookup_tbl(i) = 'PREPAY' OR --Bug#5219683
                 l_inv_type_code_tbl(i) = 'PREPAYMENT' ) THEN --Bug#5444174

              l_prepay_hist_flag := 'N';

               BEGIN

              If g_body_debug_mode = 'Y' Then
                write_log(LOG, 'Checking if the prepay application or prepayment inv reversal belongs to historical prepayment inv');
                write_log(LOG, 'Historical prepayment dist id is '||to_char(l_prepay_dist_id_tbl(i)));
                write_log(LOG, 'Parent Prepayment dist id of reversal dist id is '||to_char(l_parent_rev_id_tbl(i)));
              End If;

              IF l_prepay_dist_id_tbl(i) is not null THEN
                SELECT nvl(historical_flag,'N')
                INTO   l_prepay_hist_flag
                FROM   ap_invoice_distributions_all
                WHERE  invoice_distribution_id = l_prepay_dist_id_tbl(i);

              ELSIF  l_parent_rev_id_tbl(i) is not null THEN --Bug#5444174
                SELECT nvl(historical_flag,'N')
                INTO   l_prepay_hist_flag
                FROM   ap_invoice_distributions_all
                WHERE  invoice_distribution_id = l_parent_rev_id_tbl(i);
              END IF;

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_txn_status_code_tbl(i) := 'R';
                   G_TRANSACTION_REJECTION_CODE := 'INVALID_INVOICE';
                   write_log(LOG, 'As no data found for parent distribution, Rejecting invoice dist Id'||l_invoice_dist_id_tbl(i));
                WHEN OTHERS THEN
                   write_log(LOG, 'Error Code is  '||SQLCODE);
                   write_log(LOG, 'Error Message is  '||SUBSTR(SQLERRM, 1, 200));
                   write_log(LOG, 'Error Message is  '||SUBSTR(SQLERRM, 201, 200));
                   RAISE;

                END;

             END IF;
           END IF;

           /* If the PREPAYMENT invoice was created pre-upgrade then the prepayment invoice and its
              application should be interfaced to PA else both should be prevented from interfacing to PA*/

           IF l_prepay_hist_flag = 'N' THEN
              IF (l_ln_type_lookup_tbl(i) = 'PREPAY' OR l_prepay_dist_id_tbl(i) IS NOT NULL ) THEN -- Bug#5444174

                IF check_prepay_fully_applied(l_prepay_dist_id_tbl(i)) = 'Y' THEN
                   l_insert_flag_tbl(i) := 'F';
                ELSE
                   l_insert_flag_tbl(i) := 'P';
                END IF;

              ELSIF l_inv_type_code_tbl(i) = 'PREPAYMENT' THEN -- bug5444174

                IF check_prepay_fully_applied(l_invoice_dist_id_tbl(i)) = 'Y' THEN
                   l_insert_flag_tbl(i) := 'F';
                ELSE
                   l_insert_flag_tbl(i) := 'P';
                END IF;

              END IF; --End of PREPAY AND PREPAYMENT inv

           ELSE  -- Distribution is historical data which should be interfaced into projects

           -- REVERSED DISTRIBUTIONS INTERFACE LOGIC
           -- If the distribution is a reversal or cancellation then check if the parent reversal distribution
           -- was historical data or not. If so, reversal distribution line will be interfaced as is.
           -- However if the parent reversal distribution is not historical then the following steps happen:
           -- a) Retreive the latest adjusted expenditures from PA against the parent reversal distribution id
           -- b) If any of the above latest EI's are not costed, then the reversed distribution will be rejected by the
           --    TRX import program
           -- c) IF all above adjusted EI's are costed, then insert record into the interface table for each adjusted EI.
           --    The project attributes will be copied from the adjusted EI's instead from the AP reversed
           --    distribution since these could have changed in PA.
           -- d) The interface program will interface the reversed distribution into projects
           -- e) The interface program will also insert a reversal of the reversed distribution into Projects. This is
           --    required for account reconciliation
           --

         -- This logic is to handle both the parent and reversal getting interfaced in the same run.
          -- It's a reversed parent record. Bug#4590527
          -- If both the parent and child reversing each other are interfaced in the same run, they
          -- were not getting interfaced as netzero transactions.

           IF (l_reversal_flag_tbl(i) = 'Y' or l_cancel_flag_tbl(i) = 'Y')
                                 AND l_parent_rev_id_tbl(i) IS NULL THEN

                write_log(LOG, 'Reversal parent record '||l_invoice_dist_id_tbl(i));
              l_rev_index := l_rev_index +1;
              l_rev_parent_dist_id_tbl(l_rev_index) :=  l_invoice_dist_id_tbl(i);
              l_rev_child_dist_id_tbl(l_rev_index) :=  null;
              l_rev_parent_dist_ind_tbl(l_rev_index) :=  i; -- store the index of the parent.

           END IF;

           IF (l_reversal_flag_tbl(i) = 'Y' or l_cancel_flag_tbl(i) = 'Y') AND l_parent_rev_id_tbl(i) IS NOT NULL THEN

                BEGIN

              If g_body_debug_mode = 'Y' Then
                write_log(LOG, 'Checking if the invoice is a historical transaction');
                write_log(LOG, 'Historical Transaction is '||to_char(l_parent_rev_id_tbl(i)));
                write_log(LOG, 'Historical Invoice Id is '||to_char(l_invoice_id_tbl(i)));
              End If;

                SELECT nvl(historical_flag,'N')
                INTO   l_historical_flag
                FROM   ap_invoice_distributions_all
                WHERE  invoice_id = l_invoice_id_tbl(i)
                AND    invoice_distribution_id = l_parent_rev_id_tbl(i); --check the index on this table

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_txn_status_code_tbl(i) := 'R';
                   G_TRANSACTION_REJECTION_CODE := 'INVALID_INVOICE';
                   write_log(LOG, 'As no data found for reversed parent distribution, Rejecting invoice dist Id'||l_invoice_dist_id_tbl(i));
                WHEN OTHERS THEN
                   write_log(LOG, 'Error Code is  '||SQLCODE);
                   write_log(LOG, 'Error Message is  '||SUBSTR(SQLERRM, 1, 200));
                   write_log(LOG, 'Error Message is  '||SUBSTR(SQLERRM, 201, 200));
                   RAISE;

                END;


                IF l_historical_flag = 'N' THEN

                     G_err_stage := 'Calling Process Adjustments';
                     write_log(LOG, G_err_stage);

                     -- Call reversal API
                     Process_Adjustments(p_record_type               => 'AP_INVOICE',
                                         p_document_header_id        => l_invoice_id_tbl(i),/*Added this for 6945767 */
                                         p_document_distribution_id  => l_parent_rev_id_tbl(i),
                                         p_current_index             => i,
					 p_last_index                => j);

                     write_log(LOG, 'After calling Process Adjustments');

                      -- Set the create flag for adjustment records
                         IF l_insert_flag_tbl(i) in ('A','U') THEN
                          l_create_adj_recs := 'Y';
                         END IF;

                   If g_body_debug_mode = 'Y' Then
                     write_log(LOG, 'l_txn_rej_code_tbl = '||l_txn_rej_code_tbl(i));
                     write_log(LOG, 'l_txn_status_code_tbl = '||l_txn_status_code_tbl(i));
                   End If;

                END IF; --End of check for historical Flag

           END IF; --End of check for reversal Distribution

           G_err_stage := ('Value of G_TRANS_DFF_AP:'||G_TRANS_DFF_AP);
           write_log(LOG, G_err_stage);

           IF (G_TRANS_DFF_AP = 'Y') THEN

                v_attribute_category := l_attribute_cat_tbl(i);
                v_attribute1 := l_attribute1_tbl(i);
                v_attribute2 := l_attribute2_tbl(i);
                v_attribute3 := l_attribute3_tbl(i);
                v_attribute4 := l_attribute4_tbl(i);
                v_attribute5 := l_attribute5_tbl(i);
                v_attribute6 := l_attribute6_tbl(i);
                v_attribute7 := l_attribute7_tbl(i);
                v_attribute8 := l_attribute8_tbl(i);
                v_attribute9 := l_attribute9_tbl(i);
                v_attribute10 := l_attribute10_tbl(i);

                v_dff_map_status := NULL;

                PA_CLIENT_EXTN_DFFTRANS.DFF_map_segments_PA_and_AP(
                   p_calling_module            => 'PAAPIMP',
                   p_trx_ref_1                 => l_invoice_id_tbl(i),
                   --p_trx_ref_2                 => l_dist_line_num_tbl(i),
                   p_trx_ref_2                 => l_invoice_dist_id_tbl(i),  --NEW
                   p_trx_type                  => l_inv_type_code_tbl(i),
                   p_system_linkage_function   => G_SYSTEM_LINKAGE,
                   p_submodule                 => l_source_tbl(i),
                   p_expenditure_type          => l_exp_type_tbl(i),
                   p_set_of_books_id           => G_AP_SOB,
                   p_org_id                    => l_org_id_tbl(i),
                   p_attribute_category        => v_attribute_category,
                   p_attribute_1               => v_attribute1,
                   p_attribute_2               => v_attribute2,
                   p_attribute_3               => v_attribute3,
                   p_attribute_4               => v_attribute4,
                   p_attribute_5               => v_attribute5,
                   p_attribute_6               => v_attribute6,
                   p_attribute_7               => v_attribute7,
                   p_attribute_8               => v_attribute8,
                   p_attribute_9               => v_attribute9,
                   p_attribute_10              => v_attribute10,
                   x_status_code               => v_dff_map_status);

                   IF (v_dff_map_status IS NOT NULL) THEN

                       write_log(LOG, 'Error in DFF_map_segments_PA_and_AP, Error Code: ' || v_dff_map_status);
                       raise dff_map_exception;

                   END IF;

                   l_attribute_cat_tbl(i) := v_attribute_category;
                   l_attribute1_tbl(i) := v_attribute1;
                   l_attribute2_tbl(i) := v_attribute2;
                   l_attribute3_tbl(i) := v_attribute3;
                   l_attribute4_tbl(i) := v_attribute4;
                   l_attribute5_tbl(i) := v_attribute5;
                   l_attribute6_tbl(i) := v_attribute6;
                   l_attribute7_tbl(i) := v_attribute7;
                   l_attribute8_tbl(i) := v_attribute8;
                   l_attribute9_tbl(i) := v_attribute9;
                   l_attribute10_tbl(i) := v_attribute10;

	   ElSE /* if DFF profile is No. Added for Bug 3105153*/
                   l_attribute_cat_tbl(i) := NULL;     --Bug#3856390
                   l_attribute1_tbl(i) := NULL;
                   l_attribute2_tbl(i) := NULL;
                   l_attribute3_tbl(i) := NULL;
                   l_attribute4_tbl(i) := NULL;
                   l_attribute5_tbl(i) := NULL;
                   l_attribute6_tbl(i) := NULL;
                   l_attribute7_tbl(i) := NULL;
                   l_attribute8_tbl(i) := NULL;
                   l_attribute9_tbl(i) := NULL;
                   l_attribute10_tbl(i) := NULL;

	   END IF; /* if DFF profile is Yes */

        END IF; /* if prepay is fully applied */

      END LOOP; /* End of looping through each record in plsql table */

   EXCEPTION
      WHEN OTHERS THEN
          write_log(LOG,'Failed during process_inv_logic');
          G_err_code   := SQLCODE;
          raise;

   END process_inv_logic;

   BEGIN
   /* Main Procedure Logic starts here */

   G_err_stage := 'Within main procedure of transfer_inv_to_pa';
   write_log(LOG, G_err_stage);

     write_log(LOG, '......Result of G_TRANSACTION_SOURCE: ' || G_TRANSACTION_SOURCE);

     v_max_size := nvl(G_COMMIT_SIZE,200);

     -- Create a new interface ID for the first session

     OPEN Invoice_Cur;

     G_err_stage := 'After opening Invoice_Cur within transfer_inv_to_pa';
     write_log(LOG, G_err_stage);

     WHILE (v_all_done = 0) LOOP

       clear_plsql_tables;

       --Creating new interface ID every time this is called
       G_err_stage := 'CREATING NEW INTERFACE ID';
       write_log(LOG, G_err_stage);

       SELECT pa_interface_id_s.nextval
         INTO G_INTERFACE_ID
         FROM dual;

       G_err_stage := 'CREATING NEW NRT INTERFACE ID';
       SELECT pa_interface_id_s.nextval
         into G_NRT_INTERFACE_ID
         FROM dual;

--new
       G_err_stage := 'CREATING NEW FRT INTERFACE ID';
       SELECT pa_interface_id_s.nextval
         into G_AP_FRT_INTERFACE_ID
         FROM dual;

--new
       G_err_stage := 'CREATING NEW VARIANCE INTERFACE ID';
       SELECT pa_interface_id_s.nextval
         into G_AP_VAR_INTERFACE_ID
         FROM dual;
--new
       G_err_stage := 'CREATING NEW VARIANCE INTERFACE ID';
       SELECT pa_interface_id_s.nextval
         into G_AP_ERV_INTERFACE_ID
         FROM dual;

          FETCH Invoice_Cur BULK COLLECT INTO
             l_invoice_id_tbl
			,l_created_by_tbl
			,l_invoice_dist_id_tbl --NEW
            ,l_cdl_sys_ref3_tbl
			,l_project_id_tbl
			,l_task_id_tbl
			,l_ln_type_lookup_tbl
			,l_exp_type_tbl
			,l_ei_date_tbl
			,l_amount_tbl
			,l_description_tbl
			,l_justification_tbl
			,l_dist_cc_id_tbl
			,l_exp_org_id_tbl
			,l_quantity_tbl
			,l_acct_pay_cc_id_tbl
			,l_gl_date_tbl
			,l_attribute_cat_tbl
			,l_attribute1_tbl
			,l_attribute2_tbl
			,l_attribute3_tbl
			,l_attribute4_tbl
			,l_attribute5_tbl
			,l_attribute6_tbl
			,l_attribute7_tbl
			,l_attribute8_tbl
			,l_attribute9_tbl
			,l_attribute10_tbl
			,l_rec_cur_amt_tbl
			,l_rec_cur_code_tbl
			,l_rec_conv_rate_tbl
			,l_denom_raw_cost_tbl
			,l_denom_cur_code_tbl
			,l_acct_rate_date_tbl
			,l_acct_rate_type_tbl
			,l_acct_exch_rate_tbl
			,l_job_id_tbl
			,l_employee_id_tbl
			,l_vendor_id_tbl
			,l_inv_type_code_tbl
			,l_source_tbl
			,l_org_id_tbl
			,l_invoice_num_tbl
			,l_cdl_sys_ref4_tbl
			,l_po_dist_id_tbl
            ,l_txn_src_tbl
            ,l_user_txn_src_tbl
            ,l_batch_name_tbl
            ,l_interface_id_tbl
            ,l_exp_end_date_tbl
            ,l_txn_status_code_tbl
            ,l_txn_rej_code_tbl
            ,l_bus_grp_id_tbl
            ,l_paid_emp_id_tbl
            ,l_sort_var_tbl
            ,l_reversal_flag_tbl --NEW
            ,l_cancel_flag_tbl  --NEW
            ,l_parent_rev_id_tbl --NEW
            ,l_net_zero_flag_tbl --NEw
            ,l_sc_xfer_code_tbl
            ,l_adj_exp_item_id_tbl --NEW
            ,l_fc_enabled_tbl  --NEW
            ,l_mrc_exchange_date_tbl
            ,l_fc_document_type_tbl
            ,l_si_assts_add_flg_tbl
            ,l_insert_flag_tbl
            ,l_hist_flag_tbl
            ,l_prepay_dist_id_tbl
            LIMIT v_max_size;

         G_err_stage := 'After fetching Invoice_Cur within transfer_inv_to_pa';
         write_log(LOG, G_err_stage);

         IF l_invoice_id_tbl.COUNT <> 0 THEN

            /* get the index of the last invoice being processed within the batch*/
            v_last_inv_index := l_invoice_id_tbl.LAST;

            G_err_stage := 'calling process_inv_logic within transfer_inv_to_pa';
            write_log(LOG, G_err_stage);

            process_inv_logic;

            -- Added below process to update the inv distributions to either G or N for prepayment procsssing
            G_err_stage := 'calling bulk_update_trx_intf within transfer_inv_to_pa';
            write_log(LOG, G_err_stage);

            bulk_update_trx_intf;

            G_err_stage := 'calling bulk_insert_trx_intf within transfer_inv_to_pa';
            write_log(LOG, G_err_stage);

            bulk_insert_trx_intf;

            G_err_stage := 'After calling bulk_insert_trx_intf within transfer_inv_to_pa';
            write_log(LOG, G_err_stage);

            OPEN Num_Dist_Marked_O(l_invoice_id_tbl(v_last_inv_index));

            G_err_stage := 'After opening cursor Num_Dist_Marked_O within transfer_inv_to_pa';
            write_log(LOG, G_err_stage);

            FETCH Num_Dist_Marked_O INTO
                  v_num_dist_marked_O;

            G_err_stage := 'After fetching cursor Num_Dist_Marked_O within transfer_inv_to_pa';
            write_log(LOG, G_err_stage);

            v_num_dist_remain := v_num_dist_marked_O - v_num_last_invoice_processed;
            write_log(LOG,'Number of last invoice processed:  '||v_num_last_invoice_processed||
                          'Number of last invoice remaining:  '||v_num_dist_remain);

            write_log(LOG,'Is the last invoice an expense report?  '||v_last_inv_ER_flag);

            IF (v_num_dist_remain  > 0 AND
                v_last_inv_ER_flag = 'Y') THEN

               G_err_stage := 'Within condition of v_num_dist_remain>0 of transfer_inv_to_pa';
               write_log(LOG, G_err_stage);

               clear_plsql_tables;

               FETCH Invoice_Cur BULK COLLECT INTO
                  l_invoice_id_tbl,
                  l_created_by_tbl,
                  l_invoice_dist_id_tbl, --NEW
                  l_cdl_sys_ref3_tbl,
                  l_project_id_tbl,
                  l_task_id_tbl,
                  l_ln_type_lookup_tbl,
                  l_exp_type_tbl,
                  l_ei_date_tbl,
                  l_amount_tbl,
                  l_description_tbl,
                  l_justification_tbl,
                  l_dist_cc_id_tbl,
                  l_exp_org_id_tbl,
                  l_quantity_tbl,
                  l_acct_pay_cc_id_tbl,
                  l_gl_date_tbl,
                  l_attribute_cat_tbl,
                  l_attribute1_tbl,
             l_attribute2_tbl,
             l_attribute3_tbl,
             l_attribute4_tbl,
             l_attribute5_tbl,
             l_attribute6_tbl,
             l_attribute7_tbl,
             l_attribute8_tbl,
             l_attribute9_tbl,
             l_attribute10_tbl,
             l_rec_cur_amt_tbl,
             l_rec_cur_code_tbl,
             l_rec_conv_rate_tbl,
             l_denom_raw_cost_tbl,
             l_denom_cur_code_tbl,
             l_acct_rate_date_tbl,
             l_acct_rate_type_tbl,
             l_acct_exch_rate_tbl,
             l_job_id_tbl,
             l_employee_id_tbl,
             l_vendor_id_tbl,
             l_inv_type_code_tbl,
             l_source_tbl,
             l_org_id_tbl,
             l_invoice_num_tbl,
             l_cdl_sys_ref4_tbl,
             l_po_dist_id_tbl
             ,l_txn_src_tbl
             ,l_user_txn_src_tbl
             ,l_batch_name_tbl
             ,l_interface_id_tbl
             ,l_exp_end_date_tbl
              ,l_txn_status_code_tbl
              ,l_txn_rej_code_tbl
              ,l_bus_grp_id_tbl
              ,l_paid_emp_id_tbl
              ,l_sort_var_tbl
              ,l_reversal_flag_tbl --NEW
              ,l_cancel_flag_tbl  --NEW
              ,l_parent_rev_id_tbl --NEW
              ,l_net_zero_flag_tbl --NEW
              ,l_sc_xfer_code_tbl
              ,l_adj_exp_item_id_tbl --NEW
              ,l_fc_enabled_tbl --NEW
              ,l_mrc_exchange_date_tbl
              ,l_fc_document_type_tbl
              ,l_si_assts_add_flg_tbl
              ,l_insert_flag_tbl
              ,l_hist_flag_tbl
              ,l_prepay_dist_id_tbl
            LIMIT v_num_dist_remain;

            G_err_stage := 'After second fetch of Invoice_Cur within transfer_inv_to_pa';
            write_log(LOG, G_err_stage);

               IF l_invoice_id_tbl.COUNT <> 0 THEN

                  G_err_stage := 'Before 2nd call of process_inv_logic  within transfer_inv_to_pa';
                  write_log(LOG, G_err_stage);

                  /* Set the index of the last invoice being processed within the batch*/
                  v_last_inv_index := l_invoice_id_tbl.LAST;

                  process_inv_logic;

                 -- Added below process to update the inv distributions to either G or N for prepayment procsssing
                  G_err_stage := 'calling bulk_update_trx_intf within transfer_inv_to_pa';
                  write_log(LOG, G_err_stage);

                  bulk_update_trx_intf;

                  G_err_stage := 'Before 2nd call of bulk_insert_trx_intf within transfer_inv_to_pa';
                  write_log(LOG, G_err_stage);

                  bulk_insert_trx_intf;

              END IF; /* l_invoice_id_tbl.COUNT = 0 */

           END IF; /* IF v_num_dist_remain > 0 */

           CLOSE Num_Dist_Marked_O;


           G_err_stage := 'Before calling transaction import and tiebacks within transfer_inv_to_pa';
           write_log(LOG, G_err_stage);

           IF (v_num_distributions_fetched > 0) THEN

               v_inv_batch_size           := v_num_distributions_fetched - v_num_tax_lines_fetched -
                                             v_num_inv_variance_fetched - v_num_inv_frt_fetched;

              write_log(LOG,'Before calling trx_import for invoices with interface_id:'||G_INTERFACE_ID);
              --Logic to handle IP and AP INVOICES getting interfaced in the same run.Bug#4764470.

             IF (l_ap_inv_flag ='Y' ) THEN

              write_log(LOG,'Before calling trx_import for AP invoices');
              trans_import('AP INVOICE', G_BATCH_NAME, G_INTERFACE_ID, G_USER_ID);
              tieback_AP_ER('AP INVOICE', G_BATCH_NAME, G_INTERFACE_ID);

             END IF;

             IF (l_ip_inv_flag ='Y' ) THEN

              write_log(LOG,'Before calling trx_import for IP invoices');
              trans_import(L_IP_TRANSACTION_SOURCE, G_BATCH_NAME, G_INTERFACE_ID, G_USER_ID);
              tieback_AP_ER(L_IP_TRANSACTION_SOURCE, G_BATCH_NAME, G_INTERFACE_ID);

             ELSIF (l_ap_inv_flag ='N') THEN

              write_log(LOG,'Before calling trx_import for trx src ='||G_TRANSACTION_SOURCE);
              trans_import(G_TRANSACTION_SOURCE, G_BATCH_NAME, G_INTERFACE_ID, G_USER_ID);
              tieback_AP_ER(G_TRANSACTION_SOURCE, G_BATCH_NAME, G_INTERFACE_ID);

             END IF;
              --End of logic to handle IP and AP INVOICES getting interfaced in the same run.Bug#4764470.


              IF (nvl(v_num_tax_lines_fetched,0) > 0 AND
                     (G_INVOICE_TYPE IS NULL OR G_INVOICE_TYPE = 'EXPENSE REPORT')) THEN

                  write_log(LOG,'Before calling trx_import for NRTAX for interface_id:'||G_NRT_INTERFACE_ID);
                  v_tax_batch_size           := v_num_tax_lines_fetched;

                  trans_import(G_NRT_TRANSACTION_SOURCE, G_NRT_BATCH_NAME, G_NRT_INTERFACE_ID, G_USER_ID);
                  tieback_AP_ER(G_NRT_TRANSACTION_SOURCE, G_NRT_BATCH_NAME, G_NRT_INTERFACE_ID);

              END IF; /* IF (nvl(v_num_tax_lines_fetched,0) > 0*/

              IF nvl(v_num_inv_variance_fetched,0) > 0 THEN

                  write_log(LOG,'Before calling trx_import for Variance for interface_id:'||G_AP_VAR_INTERFACE_ID);
                  v_var_batch_size           := v_num_inv_variance_fetched;

                  trans_import(G_AP_VAR_TRANSACTION_SOURCE, G_AP_VAR_BATCH_NAME, G_AP_VAR_INTERFACE_ID, G_USER_ID);
                  tieback_AP_ER(G_AP_VAR_TRANSACTION_SOURCE, G_AP_VAR_BATCH_NAME, G_AP_VAR_INTERFACE_ID);

              END IF; /* IF (nvl(v_num_inv_variance_lines_fetched,0) > 0*/

              IF nvl(v_num_inv_erv_fetched,0) > 0 THEN

                  write_log(LOG,'Before calling trx_import for AP ERV for interface_id:'||G_AP_ERV_INTERFACE_ID);
                  v_var_batch_size           := v_num_inv_variance_fetched;

                  trans_import(G_AP_ERV_TRANSACTION_SOURCE, G_AP_ERV_BATCH_NAME, G_AP_ERV_INTERFACE_ID, G_USER_ID);
                  tieback_AP_ER(G_AP_ERV_TRANSACTION_SOURCE, G_AP_ERV_BATCH_NAME, G_AP_ERV_INTERFACE_ID);

              END IF; /* IF (nvl(v_num_inv_erv_lines_fetched,0) > 0*/

              IF nvl(v_num_inv_frt_fetched,0) > 0 THEN

                  write_log(LOG,'Before calling trx_import for Frt and Misc for interface_id:'||G_AP_FRT_INTERFACE_ID);
                  v_frt_batch_size           := v_num_inv_frt_fetched;

                  trans_import(G_TRANSACTION_SOURCE, G_AP_FRT_BATCH_NAME, G_AP_FRT_INTERFACE_ID, G_USER_ID);
                  tieback_AP_ER(G_TRANSACTION_SOURCE, G_AP_FRT_BATCH_NAME, G_AP_FRT_INTERFACE_ID);

              END IF; /* IF (nvl(v_num_inv_frt_lines_fetched,0) > 0*/

              write_log(LOG,'Calling tieback for locked RCV transactions');
              tieback_locked_rcvtxn;

/*** Commented 3922679  *
              G_err_stage := 'Before calling commit';
              write_log(LOG, G_err_stage);
              COMMIT;
*** Commented 3922679  End*/

              G_err_stage := 'Before updating the total number of invoices processed';
              write_log(LOG, G_err_stage);

              G_NUM_BATCHES_PROCESSED       := G_NUM_BATCHES_PROCESSED + 1;
              G_NUM_INVOICES_PROCESSED      :=  G_NUM_INVOICES_PROCESSED + v_num_invoices_fetched;
              G_NUM_DISTRIBUTIONS_PROCESSED :=  G_NUM_DISTRIBUTIONS_PROCESSED + v_num_distributions_fetched;
              write_log(LOG,'G_NUM_BATCHES_PROCESSED:'||G_NUM_BATCHES_PROCESSED);
              write_log(LOG,'G_NUM_INVOICES_PROCESSED:'||G_NUM_INVOICES_PROCESSED);
              write_log(LOG,'G_NUM_DISTRIBUTIONS_PROCESSED:'||G_NUM_DISTRIBUTIONS_PROCESSED);

        END IF; /* IF (v_num_distributions_fetched > 0) */

        G_err_stage := 'After calling transaction import and tiebacks within transfer_inv_to_pa';
        write_log(LOG, G_err_stage);

        clear_plsql_tables;

        v_num_invoices_fetched       :=0;
        v_num_distributions_fetched  :=0;
        v_num_tax_lines_fetched      :=0;
        v_inv_batch_size             :=0;
        v_tax_batch_size             :=0;
        v_var_batch_size             :=0;
        v_frt_batch_size             :=0;
        v_num_dist_remain            :=0;
        v_num_dist_marked_O          :=0;
        v_num_last_invoice_processed :=0;
        v_last_inv_ER_flag           := 'N';

        G_err_stage:='Before exiting when Invoice_Cur is NOTFOUND';
        write_log(LOG,   G_err_stage);

      ELSE

          G_err_stage:='Cursor fetched zero rows into plsql tables. Exiting';
          write_log(LOG,   G_err_stage);
          EXIT;
      END IF; /* l_invoice_id_tbl.COUNT = 0 */

      G_err_stage:='Cursor fetched no more rows. Exiting';
      write_log(LOG,   G_err_stage);
      EXIT WHEN Invoice_Cur%NOTFOUND;

   END LOOP; /* While more rows to process is true */

   CLOSE Invoice_Cur;

EXCEPTION
    WHEN OTHERS THEN

         G_err_stack := v_old_stack;
         IF invoice_cur%ISOPEN THEN
           CLOSE Invoice_Cur;
         END IF ;

         G_err_code := SQLCODE;
         RAISE;

END transfer_inv_to_pa;

/*---------------------------Tieback to AP Phase----------------------------*/
PROCEDURE tieback_AP_ER(
   p_transaction_source IN pa_transaction_interface.transaction_source%TYPE,
   p_batch_name  IN pa_transaction_interface.batch_name%TYPE,
   p_interface_id IN pa_transaction_interface.interface_id%TYPE) IS

   l_assets_addflag          VARCHAR2(1):=NULL;
   l_prev_assets_addflag     VARCHAR2(1):=NULL;
   l_project_id             NUMBER :=0;
   l_pa_addflag             VARCHAR2(1):=NULL;
   l_prev_proj_id           NUMBER :=0;

   l_sys_ref1_tbl           PA_PLSQL_DATATYPES.Char15TabTyp;
   l_sys_ref2_tbl           PA_PLSQL_DATATYPES.Char15TabTyp;
--   l_sys_ref3_tbl           PA_PLSQL_DATATYPES.Char15TabTyp; --NEW
--   l_sys_ref4_tbl           PA_PLSQL_DATATYPES.Char15TabTyp;
   l_sys_ref5_tbl           PA_PLSQL_DATATYPES.IdTabTyp;    --NEW --check with Ajay if its declared as number type
   l_txn_src_tbl            PA_PLSQL_DATATYPES.Char30TabTyp;
   l_batch_name_tbl         PA_PLSQL_DATATYPES.Char50TabTyp;
   l_interface_id_tbl       PA_PLSQL_DATATYPES.IdTabTyp;
   l_txn_status_code_tbl    PA_PLSQL_DATATYPES.Char2TabTyp;
   l_project_id_tbl            PA_PLSQL_DATATYPES.IdTabTyp;
   l_pa_addflag_tbl         PA_PLSQL_DATATYPES.CHAR1TabTyp;
   l_assets_addflag_tbl     PA_PLSQL_DATATYPES.CHAR1TabTyp;

   CURSOR txn_intf_rec (p_txn_src       IN VARCHAR2,
                        p_batch_name    IN VARCHAR2,
                        p_interface_id  IN NUMBER) IS
      SELECT cdl_system_reference1
            ,cdl_system_reference2
         --   ,cdl_system_reference3  --NEW
         --   ,cdl_system_reference4
            ,cdl_system_reference5 --NEW
            ,transaction_source
            ,batch_name
            ,interface_id
            ,transaction_status_code
            ,project_id
            ,l_pa_addflag
            ,l_assets_addflag
        FROM pa_transaction_interface_all txnintf
       WHERE txnintf.transaction_source = p_txn_src
         AND txnintf.batch_name         = p_batch_name
         AND txnintf.interface_id       = p_interface_id;

   PROCEDURE clear_plsql_tables IS

      v_status   VARCHAR2(15);

   BEGIN

      G_err_stage:='Clearing PLSQL tables in invoice tieback';
      write_log(LOG,   G_err_stage);

      l_sys_ref1_tbl.delete;
      l_sys_ref2_tbl.delete;
   --   l_sys_ref3_tbl.delete; --NEW
   --   l_sys_ref4_tbl.delete; --NEW
      l_sys_ref5_tbl.delete; --NEW
      l_txn_src_tbl.delete;
      l_batch_name_tbl.delete;
      l_interface_id_tbl.delete;
      l_txn_status_code_tbl.delete;
      l_project_id_tbl.delete;
      l_pa_addflag_tbl.delete;
      l_assets_addflag_tbl.delete;

   END clear_plsql_tables;

   PROCEDURE process_tieback IS

      v_status   VARCHAR2(15);

   BEGIN

      G_err_stage:='Within process_tieback of invoice tieback';
      write_log(LOG,   G_err_stage);

      FOR i IN l_sys_ref1_tbl.FIRST..l_sys_ref1_tbl.LAST LOOP

         /* If transaction import stamps the record to be 'A' then
            update pa_addition_flag of invoice distribution to 'Y'.
            If transaction import leaves the record to be 'P' then
            update pa_addition_flag of invoice distribution to 'N'.
            If transaction import stamps the record to be 'R' then
            update pa_addition_flag of invoice distribution to 'N'.*/

         write_log(LOG,'Tying invoice_id: '||l_sys_ref2_tbl(i)||
                       --'dist num:  '||l_sys_ref3_tbl(i)||  --NEW
                       'dist id:  '||l_sys_ref5_tbl(i)||  --NEW
                       'trc src:   '||l_txn_src_tbl(i));

         IF l_txn_status_code_tbl(i) = 'A' THEN
               l_pa_addflag_tbl(i) := 'Y';
         ELSIF l_txn_status_code_tbl(i) = 'P' THEN
               l_pa_addflag_tbl(i) :='N';
         ELSIF l_txn_status_code_tbl(i) = 'R' THEN
               l_pa_addflag_tbl(i) := 'N';
         END IF;

         IF G_PROJECT_ID IS NOT NULL THEN

            IF G_Assets_Addition_flag = 'P' THEN
               l_assets_addflag_tbl(i) := 'P';
            ELSE
               l_assets_addflag_tbl(i) := 'X';
            END IF;

         ELSIF G_PROJECT_ID IS NULL THEN

            IF l_project_id_tbl(i) <> l_prev_proj_id THEN

               G_err_stage:='Selecting assets addition flag within invoice tieback';
               write_log(LOG,   G_err_stage);

               SELECT decode(PTYPE.Project_Type_Class_Code,'CAPITAL','P','X')
                 INTO l_assets_addflag_tbl(i)
                 FROM pa_project_types_all PTYPE,
                      pa_projects_all PROJ
                WHERE PTYPE.Project_Type = PROJ.Project_Type
                  AND (PTYPE.org_id = PROJ.org_id OR
                       PROJ.org_id is null)
                  AND PROJ.Project_Id = l_project_id_tbl(i);

                l_prev_proj_id := l_project_id_tbl(i);
		l_prev_assets_addflag := l_assets_addflag_tbl(i);

            ELSE
               l_assets_addflag_tbl(i) := l_prev_assets_addflag;
            END IF;

         END IF;

      END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
         G_err_stage:= 'Failed during process tieback of invoice tieback';
         write_log(LOG,   G_err_stage);
         G_err_code   := SQLCODE;
         raise;

   END process_tieback;

   PROCEDURE bulk_update_txn_intf IS

      v_status VARCHAR2(15);

   BEGIN

      G_err_stage:=('Within bulk update of invoice tieback');
      write_log(LOG,   G_err_stage);

      FORALL i IN l_sys_ref1_tbl.FIRST..l_sys_ref1_tbl.LAST

         UPDATE ap_invoice_distributions_all dist
            SET dist.pa_addition_flag         = l_pa_addflag_tbl(i)
               ,dist.assets_addition_flag      = decode(l_assets_addflag_tbl(i),'P','P',dist.assets_addition_flag)
          WHERE dist.invoice_id               = l_sys_ref2_tbl(i)
            AND dist.invoice_distribution_id  = l_sys_ref5_tbl(i)
            AND dist.pa_addition_flag         = 'O';

      /* Bug 5440548 fix to update expenditure data with historical flag for historical AP data */
      FORALL i IN l_sys_ref1_tbl.FIRST..l_sys_ref1_tbl.LAST

         UPDATE pa_expenditure_items_all exp1
            SET historical_flag = 'Y'
         WHERE  document_header_id = l_sys_ref2_tbl(i)
           AND  document_distribution_id = l_sys_ref5_tbl(i)
           AND  exists (select 'exist'
                        from   ap_invoice_distributions_all dist
                        where  dist.invoice_id =l_sys_ref2_tbl(i)
                        and    dist.invoice_distribution_id = l_sys_ref5_tbl(i)
                        and    dist.pa_addition_flag = 'Y'
                        and    dist.historical_flag = 'Y');

         /* If the accounting method is CASH BASIS then the payment lines associated with historical invoices should be updated to G
            since such invoice distributions will be not be interfaced as PAYMENTS but as INVOICES */

         IF G_ACCTNG_METHOD = 'C' THEN

           FORALL i IN l_sys_ref1_tbl.FIRST..l_sys_ref1_tbl.LAST

           UPDATE ap_payment_hist_dists dist
              SET    dist.pa_addition_flag = 'G',
                     request_id = G_REQUEST_ID,
                     last_update_date=SYSDATE,
                     last_updated_by= G_USER_ID,
                     last_update_login= G_USER_ID,
                     program_id= G_PROG_ID,
                     program_application_id= G_PROG_APPL_ID,
                     program_update_date=SYSDATE
              WHERE nvl(dist.pa_addition_flag,'N') = 'N'
              AND   dist.pay_dist_lookup_code = 'CASH'
              AND EXISTS (SELECT NULL
                          FROM   ap_payment_history_all hist
                          WHERE  hist.payment_history_id = dist.payment_history_id
                          AND    hist.posted_flag = 'Y')
              AND   exists(SELECT /*+ no_unnest */ inv.invoice_id
                             FROM AP_INVOICES_ALL inv,
                                  AP_Invoice_Distributions_all aid,
                                  ap_invoice_payments_all aip
                            WHERE inv.invoice_id              = aip.invoice_id
                              AND aid.invoice_id              = inv.invoice_id
                              AND aip.invoice_payment_id      = dist.invoice_payment_id
                              AND aid.invoice_distribution_id = dist.invoice_distribution_id
                              AND inv.org_id = G_ORG_ID
                              AND aip.invoice_id              = l_sys_ref2_tbl(i)
                              AND aid.invoice_distribution_id = l_sys_ref5_tbl(i));

         END IF;
   EXCEPTION
      WHEN OTHERS THEN
         G_err_stage:= 'Failed during bulk update of invoice tieback';
         write_log(LOG,   G_err_stage);
         G_err_code   := SQLCODE;
         raise;

   END bulk_update_txn_intf;

   BEGIN

      /* Main logic of tieback starts here */
      G_err_stage:='Within main logic of tieback';
      write_log(LOG,   G_err_stage);

      clear_plsql_tables;

      G_err_stage:='Opening txn_intf_rec';
      write_log(LOG,   G_err_stage);

      OPEN txn_intf_rec(p_transaction_source
                       ,p_batch_name
                       ,p_interface_id);

      G_err_stage:='Fetching txn_intf_rec';
      write_log(LOG,   G_err_stage);

      FETCH txn_intf_rec BULK COLLECT INTO
          l_sys_ref1_tbl
         ,l_sys_ref2_tbl
         --,l_sys_ref3_tbl --NEW
         --,l_sys_ref4_tbl --NEW
         ,l_sys_ref5_tbl  --NEW
         ,l_txn_src_tbl
         ,l_batch_name_tbl
         ,l_interface_id_tbl
         ,l_txn_status_code_tbl
         ,l_project_id_tbl
         ,l_pa_addflag_tbl
         ,l_assets_addflag_tbl;

      IF l_sys_ref1_tbl.COUNT <> 0 THEN

         process_tieback;

         bulk_update_txn_intf;

         clear_plsql_tables;

      END IF;

      CLOSE txn_intf_rec;

EXCEPTION
   WHEN OTHERS THEN

      IF txn_intf_rec%ISOPEN THEN
         CLOSE txn_intf_rec;
      END IF;

      G_err_code := SQLCODE;
      RAISE;

END tieback_AP_ER;


PROCEDURE lock_rcv_txn (p_po_distribution_id IN ap_invoice_distributions.po_distribution_id%TYPE) IS

   l_num_rows   NUMBER;

BEGIN

   G_err_stage := 'Within calling lock_rcv_txn';
   write_log(LOG, G_err_stage);

--pricing changes, updating sub_ledger instead of rcv_transactions
-- Modified this update for bug 6825742

UPDATE rcv_receiving_sub_ledger rcv_sub
SET rcv_sub.pa_addition_flag = 'L'
WHERE rcv_sub.pa_addition_flag = 'N'
and reference3 = TO_CHAR(p_po_distribution_id) and exists (
select 1 from po_distributions_all pod
where po_distribution_id = TO_NUMBER(rcv_sub.reference3)
and   po_distribution_id = p_po_distribution_id
and code_combination_id = rcv_sub.code_combination_id
and accrue_on_receipt_flag = 'Y');

   /* UPDATE rcv_receiving_sub_ledger rcv_sub
      SET rcv_sub.pa_addition_flag   = 'L'
    WHERE rcv_sub.pa_addition_flag   = 'N'
    AND EXISTS (SELECT transaction_id
		FROM rcv_transactions rcv_txn
		WHERE rcv_txn.transaction_id = rcv_sub.rcv_transaction_id
		AND rcv_txn.po_distribution_id = p_po_distribution_id ); commented for bug 6825742*/

   l_num_rows := SQL%ROWCOUNT;

   write_log(LOG,'number of RCV transactions locked:'||l_num_rows);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;

   WHEN OTHERS THEN
     PA_TRX_IMPORT.Upd_PktSts_Fatal(G_REQUEST_ID);
     G_err_code := SQLCODE;
     RAISE;

END lock_rcv_txn;

PROCEDURE tieback_locked_rcvtxn IS

   l_num_rows NUMBER;

BEGIN

   G_err_stage := 'Within calling tieback_locked_rcvtxn';
   write_log(LOG, G_err_stage);

   UPDATE rcv_receiving_sub_ledger rcv_sub
      SET rcv_sub.pa_addition_flag = 'G'
    WHERE rcv_sub.pa_addition_flag = 'L';

   l_num_rows := SQL%ROWCOUNT;

   write_log(LOG,'number of RCV transactions unlocked:'||l_num_rows);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       NULL;

   WHEN OTHERS THEN

     PA_TRX_IMPORT.Upd_PktSts_Fatal(G_REQUEST_ID);
     G_err_code := SQLCODE;
     RAISE;
END tieback_locked_rcvtxn;

   Function get_cdl_ccid(p_expenditure_item_id IN NUMBER, ccid_flag IN varchar2)
   RETURN NUMBER is

   l_cr_ccid NUMBER;
   l_dr_ccid NUMBER;

   begin

       IF p_expenditure_item_id <> l_prev_exp_item_id THEN

       G_err_stage := 'Selecting Adjustment account: get_cdl_ccid';
       write_log(LOG, G_err_stage);

       SELECT cr_code_combination_id, dr_code_combination_id
       INTO   l_cr_ccid, l_dr_ccid
       FROm   pa_cost_distribution_lines_all cdl
       WHERE  cdl.expenditure_item_id = p_expenditure_item_id
       AND    cdl.line_num in (select max(line_num)
                               from pa_cost_distribution_lines_all cdl2
                               where  cdl2.expenditure_item_id = cdl.expenditure_item_id
                               and    line_type ='R');

       l_prev_exp_item_id := p_expenditure_item_id;
       l_prev_cr_ccid := l_cr_ccid;
       l_prev_dr_ccid := l_dr_ccid;


       END IF;

       IF ccid_flag = 'C' THEN
         return l_prev_cr_ccid;
       ELSE
         return l_prev_dr_ccid;
       END IF;


       EXCEPTION WHEN NO_DATA_FOUND THEN
         return null;
   End;


/*==========================================================================*/
--The following section contains procedures for Supplier Invoice Discounts
--The logic of doscount processing can be undestood as:
-- 1) Update PA_addition_flag on Discount payment lines to 'O' to lock the record
-- 3) Transfer_disc_to_pa populates PA transaction_interface table and call trx import
-- 4) Tieback procedure called to update discount payment lines after trx import
/*==========================================================================*/

/*-----Function checks the profile setup of cutoff date for which discounts to be pulled----*/
FUNCTION return_profile_discount_date
    RETURN VARCHAR2 IS

   v_discount_start_date VARCHAR2(15);

BEGIN

    select nvl(fnd_profile.value_specific('PA_DISC_PULL_START_DATE'),'2051/01/01')  --bug4474213.
      INTO v_discount_start_date
      from DUAL;
    RETURN v_discount_start_date;

END return_profile_discount_date;

/*-----Function checks what method of discount is used by system-----*/
FUNCTION return_discount_method
     RETURN VARCHAR2 IS

     v_method VARCHAR2(15);

BEGIN

     SELECT discount_distribution_method
        INTO v_method
        FROM AP_SYSTEM_PARAMETERS;
      RETURN v_method;

END return_discount_method;

/*-----------------------Marking Distribution Phase---------------------*/

PROCEDURE mark_PA_disc_flag_O IS

        v_old_stack VARCHAR2(630);

BEGIN

     v_old_stack := G_err_stack;
     G_err_stack := G_err_stack || '->PAAPIMP_PKG.mark_PA_Disc_flag_O';
     G_err_code := 0;
     G_err_stage := 'UPDATING DISCOUNT DISTRIBUTIONS-Marking Process';

     write_log(LOG, G_err_stack);

     IF G_PROJECT_ID is not NULL THEN

          -- Mark all Discount lines associated with PREPAYMENT payment to G to prevent interface into Projects
          -- In Rel12, we will only bring in Prepayment application lines (AP_PREPAY_APP_DISTS) into Projects for Cash Based Acctng

            UPDATE ap_payment_hist_dists dist
            SET    dist.pa_addition_flag = 'G',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   dist.pay_dist_lookup_code = 'DISCOUNT'
            AND EXISTS (SELECT NULL
                        FROM   ap_payment_history_all hist
                        WHERE  hist.payment_history_id = dist.payment_history_id
                        AND    hist.posted_flag = 'Y')
            AND   exists(SELECT /*+ no_unnest */ inv.invoice_id
                           FROM AP_INVOICES_ALL inv,
                                AP_Invoice_Distributions_all aid,
                                ap_invoice_payments_all aip
                          WHERE inv.invoice_id = aip.invoice_id
                            AND aid.invoice_id = inv.invoice_id
                            AND aip.invoice_payment_id = dist.invoice_payment_id
                            AND aid.invoice_distribution_id = dist.invoice_distribution_id
                            AND inv.invoice_type_lookup_code = 'PREPAYMENT'         --Prevent prepayment payments from being transferred to Projects
                            AND aid.project_id = G_PROJECT_ID
                            AND aid.invoice_id = aip.invoice_id
                            AND inv.org_id = G_ORG_ID
                            AND trunc(aip.Accounting_Date) <= trunc(nvl(G_GL_DATE,aip.Accounting_Date))
                            AND trunc(aid.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,aid.expenditure_item_date)));

        If g_body_debug_mode = 'Y' Then
          write_log(LOG, 'Number of Discount prepayments  marked to G: ' || to_char(SQL%ROWCOUNT));
          write_log(LOG, 'cash basis: ' || G_ACCTNG_METHOD);
          write_log(LOG, 'cash basis2: ' || to_char(G_Profile_Discount_Start_date,'DD-MON-RR'));
        End If;

          -- Update pa-addition-flag to O for all valid ap distributions that should be interfaced to Projects

            UPDATE ap_payment_hist_dists dist
            SET    dist.pa_addition_flag = 'O',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   dist.pay_dist_lookup_code = 'DISCOUNT'
            AND EXISTS (SELECT NULL
                        FROM   ap_payment_history_all hist
                        WHERE  hist.payment_history_id = dist.payment_history_id
                        AND    hist.posted_flag = 'Y')
            AND   exists(SELECT/*+ no_unnest */  inv.invoice_id
                           FROM AP_INVOICES_ALL inv,
                                PO_Distributions_all PO,
                                AP_Invoice_Distributions_all aid,
                                ap_invoice_payments_all aip
                          WHERE inv.invoice_id = aip.invoice_id
                            AND aid.invoice_id = inv.invoice_id
                            AND aip.invoice_payment_id = dist.invoice_payment_id
                            AND aid.invoice_distribution_id = dist.invoice_distribution_id
                            AND aid.po_distribution_id = PO.po_distribution_id (+)
                            AND aid.line_type_lookup_code not in ('TERV', 'REC_TAX') -- Bug#5441030 to avoid zero dollar lines for TERV
                            AND inv.org_id = G_ORG_ID
                            AND nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'
                            AND inv.paid_on_behalf_employee_id IS NULL
                            AND NVL(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
                            AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                            AND  nvl(INV.source, 'xx' ) NOT IN ('Oracle Project Accounting', 'PA_IC_INVOICES')
                            AND aid.project_id = G_PROJECT_ID
                            AND trunc(aip.Accounting_Date) <= trunc(nvl(G_GL_DATE,aip.Accounting_Date))
                            AND trunc(aid.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,aid.expenditure_item_date))
                            AND ( (aid.expenditure_item_date  >=G_Profile_Discount_Start_date
                                 AND G_ACCTNG_METHOD = 'A'
                                 AND G_discount_Method IN ('TAX','EXPENSE'))
                                OR --CAsh basis
                                (( (G_discount_Method IN ('TAX','EXPENSE') AND aid.expenditure_item_date  < G_Profile_Discount_Start_date
                                    AND nvl(aid.pa_addition_flag,'N') <> 'Y') ---bug 5516855
                                   OR (G_discount_Method IN ('TAX','EXPENSE') AND aid.expenditure_item_date  >=  G_Profile_Discount_Start_date
                                    AND aid.pa_addition_flag = 'Y')  --bug 5516855 Added to allow disounts interface for historical data
                                   OR (G_discount_Method = 'TAX' AND AID.line_type_lookup_code <> 'NONREC_TAX'
                                        AND aid.expenditure_item_date  >=G_Profile_Discount_Start_date )  --Bug#5189187
                                   OR G_Discount_Method = 'SYSTEM') AND G_ACCTNG_METHOD = 'C')
                                ) --See bug#4941454 for logic
                           );


      G_DISC_DISTRIBUTIONS_MARKED := SQL%ROWCOUNT;
      write_log(LOG, 'Number of Discount rows marked to O: ' || to_char(SQL%ROWCOUNT));

     ELSE -- G_PRoject_id is null

          -- Mark all Discount lines associated with PREPAYMENT payment to G to prevent interface into Projects
          -- In Rel12, we will only bring in Prepayment application lines (AP_PREPAY_APP_DISTS) into Projects for Cash Based Acctng

            UPDATE ap_payment_hist_dists dist
            SET    dist.pa_addition_flag = 'G',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   dist.pay_dist_lookup_code = 'DISCOUNT'
            AND EXISTS (SELECT NULL
                        FROM   ap_payment_history_all hist
                        WHERE  hist.payment_history_id = dist.payment_history_id
                        AND    hist.posted_flag = 'Y')
            AND   exists(SELECT /*+ no_unnest */ inv.invoice_id
                           FROM AP_INVOICES_ALL inv,
                                AP_Invoice_Distributions_all aid,
                                ap_invoice_payments_all aip
                          WHERE inv.invoice_id = aip.invoice_id
                            AND aid.invoice_id = inv.invoice_id
                            AND aip.invoice_payment_id = dist.invoice_payment_id
                            AND aid.invoice_distribution_id = dist.invoice_distribution_id
                            AND inv.org_id = G_ORG_ID
                            AND inv.invoice_type_lookup_code = 'PREPAYMENT'         --Prevent prepayment payments from being transferred to Projects
                            AND aid.project_id > 0
                            AND aid.invoice_id = aip.invoice_id
                            AND trunc(aip.Accounting_Date) <= trunc(nvl(G_GL_DATE,aip.Accounting_Date))
                            AND trunc(aid.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,aid.expenditure_item_date)));

          write_log(LOG, 'Number of Discount prepayments  marked to G: ' || to_char(SQL%ROWCOUNT));

          -- Update pa-addition-flag to O for all valid ap distributions that should be interfaced to Projects

            UPDATE ap_payment_hist_dists dist
            SET    dist.pa_addition_flag = 'O',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   dist.pay_dist_lookup_code = 'DISCOUNT'
            AND EXISTS (SELECT NULL
                        FROM   ap_payment_history_all hist
                        WHERE  hist.payment_history_id = dist.payment_history_id
                        AND    hist.posted_flag = 'Y')
            AND   exists(SELECT /*+ no_unnest */ inv.invoice_id
                           FROM AP_INVOICES_ALL inv,
                                PO_Distributions_all PO,
                                AP_Invoice_Distributions_all aid,
                                ap_invoice_payments_all aip
                          WHERE inv.invoice_id = aip.invoice_id
                            AND aid.invoice_id = inv.invoice_id
                            AND aip.invoice_payment_id = dist.invoice_payment_id
                            AND aid.invoice_distribution_id = dist.invoice_distribution_id
                            AND inv.org_id = G_ORG_ID
                            AND aid.po_distribution_id = PO.po_distribution_id (+)
                            AND nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'
                            AND inv.paid_on_behalf_employee_id IS NULL
                            AND NVL(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
                            AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                            AND  nvl(INV.source, 'xx' ) NOT IN ('Oracle Project Accounting', 'PA_IC_INVOICES')
                            AND aid.project_id > 0
                            AND aid.line_type_lookup_code not in ('TERV', 'REC_TAX') -- Bug#5441030 to avoid zero dollar lines for TERV
                            AND trunc(aip.Accounting_Date) <= trunc(nvl(G_GL_DATE,aip.Accounting_Date))
                            AND trunc(aid.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,aid.expenditure_item_date))
                            AND ( (aid.expenditure_item_date  >=G_Profile_Discount_Start_date
                                 AND G_ACCTNG_METHOD = 'A'
                                 AND G_discount_Method IN ('TAX','EXPENSE'))
                                OR --CAsh basis
                                (( (G_discount_Method IN ('TAX','EXPENSE') AND aid.expenditure_item_date  < G_Profile_Discount_Start_date
                                    AND nvl(aid.pa_addition_flag,'N') <> 'Y') ---bug 5516855
                                   OR (G_discount_Method IN ('TAX','EXPENSE') AND aid.expenditure_item_date  >=  G_Profile_Discount_Start_date
                                    AND aid.pa_addition_flag = 'Y')  --bug 5516855 Added to allow disounts interface for historical data
                                   OR (G_discount_Method = 'TAX' AND AID.line_type_lookup_code <> 'NONREC_TAX'
                                        AND aid.expenditure_item_date  >=G_Profile_Discount_Start_date )  --Bug#5189187
                                   OR G_Discount_Method = 'SYSTEM') AND G_ACCTNG_METHOD = 'C')
                                ) --See bug#4941454 for logic
                           );

      G_DISC_DISTRIBUTIONS_MARKED := SQL%ROWCOUNT;
      write_log(LOG, 'Number of Discount rows marked to O: ' || to_char(SQL%ROWCOUNT));

      END IF;  -- End of If section checking if G_PROJECT_ID is not null

      --
      G_err_stack := v_old_stack;

EXCEPTION
     WHEN Others THEN
           -- Marking phase failed, raise exception to main program to terminate the program
           --
           G_err_stack := v_old_stack;
           G_err_code := SQLCODE;
           RAISE;

END mark_PA_disc_flag_O;

/*-------------------------------------*/

PROCEDURE transfer_disc_to_pa IS

   v_old_stack                     VARCHAR2(630);
   v_err_message                   VARCHAR2(220);
   v_all_done                      NUMBER := 0;
   v_status                        VARCHAR2(30);
   v_stage                         Number :=0;
   v_max_size                      NUMBER :=0;

   v_num_discounts_fetched         NUMBER :=0;
   v_num_payments_fetched          NUMBER :=0;

   v_method                        VARCHAR(15);
   v_prev_inv_pay_id               NUMBER:=0;

   v_disc_code_combination_id      NUMBER(15);
   v_denom_raw_cost                NUMBER :=0;
   v_acct_raw_cost                 NUMBER :=0;
   v_denom_currency_code           VARCHAR2(30);
   v_acct_rate_type                VARCHAR2(30);
   v_acct_rate_date                DATE;
   v_acct_exchange_rate            NUMBER(15);
   v_last_disc_index               NUMBER := 0;

   v_attribute_category VARCHAR2(150);
   v_attribute1 VARCHAR2(150);
   v_attribute2 VARCHAR2(150);
   v_attribute3 VARCHAR2(150);
   v_attribute4 VARCHAR2(150);
   v_attribute5 VARCHAR2(150);
   v_attribute6 VARCHAR2(150);
   v_attribute7 VARCHAR2(150);
   v_attribute8 VARCHAR2(150);
   v_attribute9 VARCHAR2(150);
   v_attribute10 VARCHAR2(150);
   v_dff_map_status VARCHAR2(30);
   dff_map_exception EXCEPTION;
   l_create_adj_recs     VARCHAR2(1) := 'N' ;-- NEW
   l_ap_inv_disc_flag    VARCHAR2(1):= 'N'; -- Flag to indicate Discounts exist for ITEM lines in Cash Basis flow.
   l_ap_nrt_disc_flag    VARCHAR2(1):= 'N'; -- Flag to indicate Discounts exist for NRTAX lines in Cash Basis flow.
   l_ap_hist_disc_flag    VARCHAR2(1):= 'N'; -- Flag to indicate Discounts exist for historicqal inv lines in Cash Basis flow.

   PROCEDURE clear_plsql_tables IS

       l_status1 VARCHAR2(30);

   BEGIN

       l_inv_pay_id_tbl.delete;
       l_invoice_id_tbl.delete;
       l_invoice_dist_id_tbl.delete;
       l_project_id_tbl.delete;
       l_task_id_tbl.delete;
       l_employee_id_tbl.delete;
       l_exp_type_tbl.delete;
       l_ei_date_tbl.delete;
       l_vendor_id_tbl.delete;
       l_created_by_tbl.delete;
       l_exp_org_id_tbl.delete;
       l_quantity_tbl.delete;
       l_job_id_tbl.delete;
       l_description_tbl.delete;
       l_dist_cc_id_tbl.delete;
       l_acct_pay_cc_id_tbl.delete;
       l_gl_date_tbl.delete;
       l_attribute_cat_tbl.delete;
       l_attribute1_tbl.delete;
       l_attribute2_tbl.delete;
       l_attribute3_tbl.delete;
       l_attribute4_tbl.delete;
       l_attribute5_tbl.delete;
       l_attribute6_tbl.delete;
       l_attribute7_tbl.delete;
       l_attribute8_tbl.delete;
       l_attribute9_tbl.delete;
       l_attribute10_tbl.delete;
       l_inv_type_code_tbl.delete;
       l_org_id_tbl.delete;
       l_invoice_num_tbl.delete;
       l_ln_type_lookup_tbl.delete;
       l_source_tbl.delete;
       l_denom_raw_cost_tbl.delete;
       l_amount_tbl.delete;
       l_denom_cur_code_tbl.delete;
       l_acct_rate_date_tbl.delete;
       l_acct_rate_type_tbl.delete;
       l_acct_exch_rate_tbl.delete;
       l_cdl_sys_ref4_tbl.delete;
       l_cdl_sys_ref3_tbl.delete;
       l_txn_src_tbl.delete;
       l_user_txn_src_tbl.delete;
       l_batch_name_tbl.delete;
       l_interface_id_tbl.delete;
       l_exp_end_date_tbl.delete;
       l_txn_status_code_tbl.delete;
       l_txn_rej_code_tbl.delete;
       l_bus_grp_id_tbl.delete;
       l_reversal_flag_tbl.delete; --NEW
       l_net_zero_flag_tbl.delete; --NEW
       l_sc_xfer_code_tbl.delete; --NEW
       l_parent_pmt_id_tbl.delete; --NEW
       l_fc_enabled_tbl.delete; --NEW
       l_rev_parent_dist_id_tbl.delete;
       l_rev_child_dist_id_tbl.delete;
       l_rev_parent_dist_ind_tbl.delete;
       l_si_assts_add_flg_tbl.delete;
       l_pay_hist_id_tbl.delete;
       l_pa_add_flag_tbl.delete;
       l_rev_index:=0;

    END clear_plsql_tables;

    PROCEDURE bulk_insert_trx_intf IS

      l_status2 VARCHAR2(30);

    BEGIN

       --FORALL i IN l_inv_pay_id_tbl.FIRST..l_inv_pay_id_tbl.LAST
       FORALL i IN l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST

       INSERT INTO pa_transaction_interface_all(
                     transaction_source
                    , user_transaction_source
                    , system_linkage
                    , batch_name
                    , expenditure_ending_date
                    , expenditure_item_date
                    , expenditure_type
                    , quantity
                    , raw_cost_rate
                    , expenditure_comment
                    , transaction_status_code
                    , transaction_rejection_code
                    , orig_transaction_reference
                    , interface_id
                    , dr_code_combination_id
                    , cr_code_combination_id
                    , cdl_system_reference1
                    , cdl_system_reference2
                    , cdl_system_reference3
                    , cdl_system_reference4
                    , cdl_system_reference5 --NEW
                    , gl_date
                    , org_id
                    , unmatched_negative_txn_flag
                    , denom_raw_cost
                    , denom_currency_code
                    , acct_rate_date
                    , acct_rate_type
                    , acct_exchange_rate
                    , acct_raw_cost
                    , acct_exchange_rounding_limit
                    , attribute_category
                    , attribute1
                    , attribute2
                    , attribute3
                    , attribute4
                    , attribute5
                    , attribute6
                    , attribute7
                    , attribute8
                    , attribute9
                    , attribute10
                    , orig_exp_txn_reference1
                    , orig_user_exp_txn_reference
                    , orig_exp_txn_reference2
                    , orig_exp_txn_reference3
                    , last_update_date
                    , last_updated_by
                    , creation_date
                    , created_by
                    , person_id
                    , organization_id
                    , project_id
                    , task_id
                    , Vendor_id
                    , override_to_organization_id
                    , person_business_group_id
                    , adjusted_expenditure_item_id
                    , fc_document_type
                    , document_type
                    , document_distribution_type
                    , si_assets_addition_flag
                    , sc_xfer_code
                    ,net_zero_adjustment_flag
                   )
             SELECT   l_txn_src_tbl(i)
                     ,l_user_txn_src_tbl(i)
                     ,G_SYSTEM_LINKAGE
                     ,l_batch_name_tbl(i)
                     ,l_exp_end_date_tbl(i)
                     ,l_ei_date_tbl(i)
                     ,l_exp_type_tbl(i)
                     ,l_quantity_tbl(i)
                     ,l_amount_tbl(i)/decode(nvl(l_quantity_tbl(i),0),0,1,l_quantity_tbl(i))
                     ,l_description_tbl(i)
                     ,l_txn_status_code_tbl(i)
                     ,l_txn_rej_code_tbl(i)
                     ,G_REQUEST_ID
                     ,l_interface_id_tbl(i)
                     ,l_dist_cc_id_tbl(i)
                     ,l_acct_pay_cc_id_tbl(i)
                     ,l_pay_hist_id_tbl(i) --cdl_ref1
                     ,l_invoice_id_tbl(i)
                     ,l_cdl_sys_ref3_tbl(i)
                     ,l_inv_pay_id_tbl(i)
                     ,l_invoice_dist_id_tbl(i) --NEW
                     ,l_gl_date_tbl(i)
                     ,G_ORG_ID
                     ,'Y'
                     ,l_denom_raw_cost_tbl(i)
                     ,l_denom_cur_code_tbl(i)
                     ,l_acct_rate_date_tbl(i)
                     ,l_acct_rate_type_tbl(i)
                     ,l_acct_exch_rate_tbl(i)
                     ,l_amount_tbl(i)
                     ,1
                     ,l_attribute_cat_tbl(i)
                     ,l_attribute1_tbl(i)
                     ,l_attribute2_tbl(i)
                     ,l_attribute3_tbl(i)
                     ,l_attribute4_tbl(i)
                     ,l_attribute5_tbl(i)
                     ,l_attribute6_tbl(i)
                     ,l_attribute7_tbl(i)
                     ,l_attribute8_tbl(i)
                     ,l_attribute9_tbl(i)
                     ,l_attribute10_tbl(i)
                     ,l_invoice_id_tbl(i)        /*orig_exp_txn_reference1*/
                     ,l_invoice_num_tbl(i)       /*user_exp_txn_reference*/
                     ,NULL                       /*orig_exp_txn_reference2*/
                     ,NULL                       /*orig_exp_txn_reference3*/
                     ,SYSDATE
                     ,-1
                     ,SYSDATE
                     ,-1
                     ,l_employee_id_tbl(i)
                     ,l_org_id_tbl(i)
                     ,l_project_id_tbl(i)
                     ,l_task_id_tbl(i)
                     ,l_vendor_id_tbl(i)
                     ,l_exp_org_id_tbl(i)
                     ,l_bus_grp_id_tbl(i)
                     ,l_adj_exp_item_id_tbl(i)
                     ,l_fc_document_type_tbl(i)
                     ,l_inv_type_code_tbl(i)
                     ,l_ln_type_lookup_tbl(i)
                     ,l_si_assts_add_flg_tbl(i)
                     ,l_sc_xfer_code_tbl(i)
                     ,l_net_zero_flag_tbl(i)
                  FROM dual;

              -- Insert the reversal of the reversed/cancelled distribution recs from AP.
    IF l_create_adj_recs = 'Y' THEN

                write_log(LOG, 'Inserting adjustment records..');
       --FORALL i IN l_inv_pay_id_tbl.FIRST..l_inv_pay_id_tbl.LAST
       FORALL i IN l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST

       INSERT INTO pa_transaction_interface_all(
                     transaction_source
                    , user_transaction_source
                    , system_linkage
                    , batch_name
                    , expenditure_ending_date
                    , expenditure_item_date
                    , expenditure_type
                    , quantity
                    , raw_cost_rate
                    , expenditure_comment
                    , transaction_status_code
                    , transaction_rejection_code
                    , orig_transaction_reference
                    , interface_id
                    , dr_code_combination_id
                    , cr_code_combination_id
                    , cdl_system_reference1
                    , cdl_system_reference2
                    , cdl_system_reference3
                    , cdl_system_reference4
                    , cdl_system_reference5 --NEW
                    , gl_date
                    , org_id
                    , unmatched_negative_txn_flag
                    , denom_raw_cost
                    , denom_currency_code
                    , acct_rate_date
                    , acct_rate_type
                    , acct_exchange_rate
                    , acct_raw_cost
                    , acct_exchange_rounding_limit
                    , attribute_category
                    , attribute1
                    , attribute2
                    , attribute3
                    , attribute4
                    , attribute5
                    , attribute6
                    , attribute7
                    , attribute8
                    , attribute9
                    , attribute10
                    , orig_exp_txn_reference1
                    , orig_user_exp_txn_reference
                    , orig_exp_txn_reference2
                    , orig_exp_txn_reference3
                    , last_update_date
                    , last_updated_by
                    , creation_date
                    , created_by
                    , person_id
                    , organization_id
                    , project_id
                    , task_id
                    , Vendor_id
                    , override_to_organization_id
                    , person_business_group_id
                    , adjusted_expenditure_item_id
                    , fc_document_type
                    , document_type
                    , document_distribution_type
                    , si_assets_addition_flag
                    , adjusted_txn_interface_id
                    , sc_xfer_code
                    ,net_zero_adjustment_flag
                   )
             SELECT   l_txn_src_tbl(i)
                     ,l_user_txn_src_tbl(i)
                     ,G_SYSTEM_LINKAGE
                     ,l_batch_name_tbl(i)
                     ,l_exp_end_date_tbl(i)
                     ,l_ei_date_tbl(i)
                     ,l_exp_type_tbl(i)
                     ,-l_quantity_tbl(i)
                     ,l_amount_tbl(i)/decode(nvl(l_quantity_tbl(i),0),0,1,l_quantity_tbl(i))
                     ,l_description_tbl(i)
                     ,l_txn_status_code_tbl(i)
                     ,l_txn_rej_code_tbl(i)
                     ,G_REQUEST_ID
                     ,l_interface_id_tbl(i)
                     ,l_dist_cc_id_tbl(i)
                     ,l_acct_pay_cc_id_tbl(i)
                     ,l_pay_hist_id_tbl(i) --cdl_ref1
                     ,l_invoice_id_tbl(i)
                     ,l_cdl_sys_ref3_tbl(i)
                     ,l_inv_pay_id_tbl(i)
                     ,l_invoice_dist_id_tbl(i)
                     ,l_gl_date_tbl(i)
                     ,G_ORG_ID
                     ,'Y'
                     ,-l_denom_raw_cost_tbl(i)
                     ,l_denom_cur_code_tbl(i)
                     ,l_acct_rate_date_tbl(i)
                     ,l_acct_rate_type_tbl(i)
                     ,l_acct_exch_rate_tbl(i)
                     ,-l_amount_tbl(i)
                     ,1
                     ,l_attribute_cat_tbl(i)
                     ,l_attribute1_tbl(i)
                     ,l_attribute2_tbl(i)
                     ,l_attribute3_tbl(i)
                     ,l_attribute4_tbl(i)
                     ,l_attribute5_tbl(i)
                     ,l_attribute6_tbl(i)
                     ,l_attribute7_tbl(i)
                     ,l_attribute8_tbl(i)
                     ,l_attribute9_tbl(i)
                     ,l_attribute10_tbl(i)
                     ,l_invoice_id_tbl(i)        /*orig_exp_txn_reference1*/
                     ,l_invoice_num_tbl(i)       /*user_exp_txn_reference*/
                     ,NULL                       /*orig_exp_txn_reference2*/
                     ,NULL                       /*orig_exp_txn_reference3*/
                     ,SYSDATE
                     ,-1
                     ,SYSDATE
                     ,-1
                     ,l_employee_id_tbl(i)
                     ,l_org_id_tbl(i)
                     ,l_project_id_tbl(i)
                     ,l_task_id_tbl(i)
                     ,l_vendor_id_tbl(i)
                     ,l_exp_org_id_tbl(i)
                     ,l_bus_grp_id_tbl(i)
                     ,l_adj_exp_item_id_tbl(i)
                     ,l_fc_document_type_tbl(i)
                     ,l_inv_type_code_tbl(i)
                     ,l_ln_type_lookup_tbl(i)
                     , 'T' --l_si_assts_add_flg_tbl(i)
                     ,(select xface.txn_interface_id
                       from   pa_transaction_interface xface
                       where  xface.interface_id = l_interface_id_tbl(i)
                       and    xface.cdl_system_reference2 = l_invoice_id_tbl(i)
                       and    xface.cdl_system_reference4 = to_char(l_inv_pay_id_tbl(i))
                       and    xface.cdl_system_reference5 = l_invoice_dist_id_tbl(i)
		       and    NVL(xface.adjusted_expenditure_item_id,0) = 0 ) -- R12 funds management Uptake
                     ,'P' -- sc_xfer_code
                     ,l_net_zero_flag_tbl(i)
                   FROM dual
                   WHERE l_insert_flag_tbl(i)= 'A';
                  --WHERE l_net_zero_flag_tbl(i)= 'Y';

               -- Handle both the parent and the reversal getting interfaced into PA
               -- in the same run.
                write_log(LOG, 'Updating  adjustment records..');

              IF l_rev_child_dist_id_tbl.exists(1) THEN
               FOR i in l_rev_child_dist_id_tbl.FIRST ..l_rev_child_dist_id_tbl.LAST LOOP

                   IF l_rev_child_dist_id_tbl(i) > 0 THEN

                    UPDATE pa_transaction_interface_all xface
                    SET    xface.net_zero_adjustment_flag ='Y',
                           xface.adjusted_txn_interface_id =
                              (select xface1.txn_interface_id
                               from   pa_transaction_interface xface1
                               where  xface1.interface_id = l_interface_id_tbl(l_rev_parent_dist_ind_tbl(i))
                               and    xface1.cdl_system_reference2 = l_invoice_id_tbl(l_rev_parent_dist_ind_tbl(i))
                               and    xface1.cdl_system_reference4 = to_char(l_inv_pay_id_tbl(l_rev_parent_dist_ind_tbl(i)))
                               and    xface1.cdl_system_reference5 = l_invoice_dist_id_tbl(l_rev_parent_dist_ind_tbl(i))
                               )
                      WHERE  xface.interface_id = l_interface_id_tbl(l_rev_parent_dist_ind_tbl(i))
                      AND    xface.cdl_system_reference2 = l_invoice_id_tbl(l_rev_parent_dist_ind_tbl(i))
                      --AND    xface.cdl_system_reference4 = to_char(l_rev_child_dist_id_tbl(i))
                      -- AND    xface.cdl_system_reference5 = l_invoice_dist_id_tbl(l_rev_parent_dist_ind_tbl(i));
                      AND    -- For voided payments l_rev_child_dist_id_tbl stores the reversed payment id Bug# 5408748
                             -- Here the reversal pair will have same inv dist id and diff payment id's
                             ((
                             xface.cdl_system_reference4     = To_char(l_rev_child_dist_id_tbl(i))
                             AND xface.cdl_system_reference5 = l_invoice_dist_id_tbl(l_rev_parent_dist_ind_tbl(i))
                             )
                      OR     -- For invoice reversal l_rev_child_dist_id_tbl stores the reversed invoice dist id Bug# 5408748
                             -- Here the reversal pair will have same payment id and diff inv dist id's
                             (
                             xface.cdl_system_reference4     = to_char(l_inv_pay_id_tbl(l_rev_parent_dist_ind_tbl(i)))
                             AND xface.cdl_system_reference5 = To_char(l_rev_child_dist_id_tbl(i))
                             )) ;
                    END IF;

              END LOOP;
             END IF;
    END IF;

   EXCEPTION
      WHEN OTHERS THEN
          write_log(LOG,'Failed during bulk insert for discount processing');
          G_err_code   := SQLCODE;
          write_log(LOG, 'Error Code is '||SQLCODE);
          write_log(LOG, substr(SQLERRM, 1, 200));
          write_log(LOG, substr(SQLERRM, 201, 200));
          raise;

   END bulk_insert_trx_intf;

   PROCEDURE process_disc_logic IS

       j NUMBER := 0; --Index variable for creating reversal EI's --NEW
       l_status3 VARCHAR2(30);
       L_PP_REJECT_FLAG VARCHAR2(1); --Bug 3664528

   BEGIN


       j :=  v_last_disc_index ;
       FOR i IN  l_inv_pay_id_tbl.FIRST..l_inv_pay_id_tbl.LAST  LOOP

         write_log(LOG,'getting discount attributes for inv_pay_id:'||l_inv_pay_id_tbl(i)
                      ||'invoice_id:'||l_invoice_id_tbl(i)
                      ||'Invoice dist id:'||l_invoice_dist_id_tbl(i));

           l_quantity_tbl(i)       := l_denom_raw_cost_tbl(i);
           l_cdl_sys_ref4_tbl(i)   := l_inv_pay_id_tbl(i);


           G_TRANSACTION_REJECTION_CODE := '';
           G_TRANSACTION_STATUS_CODE := 'P';

           /* For CAsh Basis we process Discounts as SUpplier Invoice */
           IF G_ACCTNG_METHOD = 'C' and nvl(l_pa_add_flag_tbl(i),'N') <> 'Y' THEN --Bug# 5516855
             -- Added the pa-addition-flag logic for bug 5516855 so that discounts on historical records, that are interfaced as
             -- inv dist and have pa-addition-flag as Y , are interfaced as DISCOUNTS source and negitive amount


             --Added this logic for bug#5122922.

           IF l_ln_type_lookup_tbl(i)  = 'NONREC_TAX' THEN
             G_DISC_TRANSACTION_SOURCE      := 'AP NRTAX';
             G_DISC_USER_TRANSACTION_SOURCE := 'AP NRTAX';
             l_ap_nrt_disc_flag  :='Y';
           ELSE
             G_DISC_TRANSACTION_SOURCE      := 'AP INVOICE' ;
             G_DISC_USER_TRANSACTION_SOURCE := 'AP INVOICE';
             l_ap_inv_disc_flag  :='Y';
           END IF;


           ELSE
             IF G_ACCTNG_METHOD = 'C' THEN   --To process discounts against historical inv in rel12 in cash env Bug# 5516855
               l_ap_hist_disc_flag  :='Y';
             END IF;

             G_DISC_TRANSACTION_SOURCE      := 'AP DISCOUNTS' ;
             G_DISC_USER_TRANSACTION_SOURCE := 'Supplier Invoice Discounts from Payables';

             l_denom_raw_cost_tbl(i) := -l_denom_raw_cost_tbl(i);   -- for Discounts, amount is interfaced as negitive amount
             l_amount_tbl(i)         := -l_amount_tbl(i);
             l_quantity_tbl(i)       := -l_quantity_tbl(i);

           END IF;

           /* The following will be executed if discount being fetched belongs to a new payment */
           IF (l_inv_pay_id_tbl(i) <> v_prev_inv_pay_id) THEN

               write_log(LOG,'New payment processed. inv_pay_id is:'||l_inv_pay_id_tbl(i));

               /* Update the previous invoice payment id*/
               v_prev_inv_pay_id := l_inv_pay_id_tbl(i);

               /* Increment the counter for invoices */
               v_num_payments_fetched := v_num_payments_fetched + 1;

               /* For new invoice, initialize the transaction status code to 'P' */
               L_PP_REJECT_FLAG := 'N';

               G_err_stage := 'GET MAX EXPENDITURE ENDING DATE';
               write_log(LOG, G_err_stage);
/* Bug 5051103 - replace expnediture_item_date with l_ei_date_tbl(i) */
               SELECT pa_utils.getweekending(MAX(l_ei_date_tbl(i)))
                 INTO G_EXPENDITURE_ENDING_DATE
                 FROM ap_invoice_distributions
                WHERE invoice_id = l_invoice_id_tbl(i);

               G_err_stage := ('Before getting business group id');
               write_log(LOG, G_err_stage);

               BEGIN

                  IF l_employee_id_tbl(i) <> 0 THEN
			Begin
			     SELECT emp.business_group_id
                               INTO G_PER_BUS_GRP_ID
			       FROM per_all_people_f emp
			      WHERE emp.person_id = l_employee_id_tbl(i)
				  AND l_ei_date_tbl(i) between trunc(emp.effective_start_date) and
							       trunc(emp.effective_end_date);

		       EXCEPTION
			  WHEN NO_DATA_FOUND THEN
                             L_PP_REJECT_FLAG := 'Y' ;
			     G_TRANSACTION_REJECTION_CODE := 'INVALID_EMPLOYEE';
			     write_log(LOG, 'no data found for Employee, Rejecting invoice'||l_invoice_id_tbl(i)  );
			End;
                    Else
                        Begin

                            select org2.business_group_id
                              into G_PER_BUS_GRP_ID
                              from hr_organization_units org1,
                                   hr_organization_units org2
                             Where org1.organization_id = l_exp_org_id_tbl(i)
                               and org1.business_group_id = org2.organization_id;

                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                      L_PP_REJECT_FLAG := 'Y' ;
                                      G_TRANSACTION_REJECTION_CODE := 'INVALID_ORGANIZATION';
                                      write_log(LOG, 'As no data found for Organization, Rejecting discount invoice ' || l_invoice_id_tbl(i) );
                        End;
                  END IF; /* IF l_employee_id_tbl(i) <> 0 THEN  */

               END;

           END IF; /* end of check for new invoice_payment_id*/

           v_num_discounts_fetched := v_num_discounts_fetched + 1;
           write_log(LOG,'Num of discount lines fetched:'||v_num_discounts_fetched);

          IF L_PP_REJECT_FLAG = 'Y' THEN --Bug 3664528 : Reject all the distributions within prepayment --???????
             G_TRANSACTION_STATUS_CODE := 'R';
          END IF;

           /*Setting values according to global variables*/


           l_txn_src_tbl(i)         := G_DISC_TRANSACTION_SOURCE;
           l_user_txn_src_tbl(i)    := G_DISC_USER_TRANSACTION_SOURCE;
           l_batch_name_tbl(i)      := G_DISC_BATCH_NAME;
           l_interface_id_tbl(i)    := G_DISC_INTERFACE_ID;
           l_bus_grp_id_tbl(i)      := G_PER_BUS_GRP_ID;
           l_exp_end_date_tbl(i)    := G_EXPENDITURE_ENDING_DATE;
           l_txn_rej_code_tbl(i)    := G_TRANSACTION_REJECTION_CODE;
           l_txn_status_code_tbl(i) := G_TRANSACTION_STATUS_CODE;

         -- This logic is to handle both the parent and reversal getting interfaced in the same run.
          -- It's a reversed parent record. Bug#4590527
          -- If both the parent and child reversing each other are interfaced in the same run, they
          -- were not getting interfaced as netzero transactions.

           IF (l_reversal_flag_tbl(i) in ('Y','R') or l_cancel_flag_tbl(i) = 'Y')
                                 AND l_parent_pmt_id_tbl(i) IS NULL THEN

              l_rev_index := l_rev_index +1;
              IF l_reversal_flag_tbl(i) = 'Y' THEN
                write_log(LOG, 'Reversal parent record '||l_inv_pay_id_tbl(i));
                l_rev_parent_dist_id_tbl(l_rev_index) :=  l_inv_pay_id_tbl(i);
              ELSE

                -- The Reversal flag with value R indicates that the invoice distribution has been reversed
                -- Refer to Bug#5408748

                write_log(LOG, 'Reversal parent record for Invoice Dist reversals'||l_invoice_dist_id_tbl(i));
                l_rev_parent_dist_id_tbl(l_rev_index) :=  l_invoice_dist_id_tbl(i);
              END IF;

              l_rev_child_dist_id_tbl(l_rev_index) :=  null;
              l_rev_parent_dist_ind_tbl(l_rev_index) :=  i; -- store the index of the parent.

           END IF;

           IF l_reversal_flag_tbl(i) in ('Y','R')  and l_parent_pmt_id_tbl(i) is not null THEN

                     -- Call reversal API
                     Process_Adjustments(p_record_type               => 'AP_DISCOUNTS',
                                         p_document_header_id        => l_invoice_id_tbl(i),/*Added this for 6945767 */
                                         p_document_distribution_id  => l_invoice_dist_id_tbl(i),
                                         p_document_payment_id       => l_parent_pmt_id_tbl(i),
                                         p_current_index             => i,
					 p_last_index		     => j);

                      -- Set the create flag for adjustment records
                         IF l_insert_flag_tbl(i) in ('A','U') THEN
                          l_create_adj_recs := 'Y';
                         END IF;


          END IF; --End of check for reversal Distribution

           -- FC Doc Type
            IF l_fc_enabled_tbl(i) = 'N' THEN
             l_fc_document_type_tbl(i) := 'NOT';
            END IF;

           IF (G_TRANS_DFF_AP = 'Y') THEN

                v_attribute_category := l_attribute_cat_tbl(i);
                v_attribute1 := l_attribute1_tbl(i);
                v_attribute2 := l_attribute2_tbl(i);
                v_attribute3 := l_attribute3_tbl(i);
                v_attribute4 := l_attribute4_tbl(i);
                v_attribute5 := l_attribute5_tbl(i);
                v_attribute6 := l_attribute6_tbl(i);
                v_attribute7 := l_attribute7_tbl(i);
                v_attribute8 := l_attribute8_tbl(i);
                v_attribute9 := l_attribute9_tbl(i);
                v_attribute10 := l_attribute10_tbl(i);

                v_dff_map_status := NULL;

                G_err_stage:='Calling DFF_map_segments_PA_and_AP for discounts';
                write_log(LOG,   G_err_stage);

                PA_CLIENT_EXTN_DFFTRANS.DFF_map_segments_PA_and_AP(
                   p_calling_module            => 'PAAPIMP',
                   p_trx_ref_1                 => l_invoice_id_tbl(i),
                   p_trx_ref_2                 => l_invoice_dist_id_tbl(i),
                   p_trx_type                  => l_inv_type_code_tbl(i),
                   p_system_linkage_function   => G_SYSTEM_LINKAGE,
                   p_submodule                 => l_source_tbl(i),
                   p_expenditure_type          => l_exp_type_tbl(i),
                   p_set_of_books_id           => G_AP_SOB,
                   p_org_id                    => l_org_id_tbl(i),
                   p_attribute_category        => v_attribute_category,
                   p_attribute_1               => v_attribute1,
                   p_attribute_2               => v_attribute2,
                   p_attribute_3               => v_attribute3,
                   p_attribute_4               => v_attribute4,
                   p_attribute_5               => v_attribute5,
                   p_attribute_6               => v_attribute6,
                   p_attribute_7               => v_attribute7,
                   p_attribute_8               => v_attribute8,
                   p_attribute_9               => v_attribute9,
                   p_attribute_10              => v_attribute10,
                   x_status_code               => v_dff_map_status);

                   IF (v_dff_map_status IS NOT NULL) THEN

                       G_err_stage:=('Error in DFF_map_segments_PA_and_AP, Error Code: ' || v_dff_map_status);
                       write_log(LOG,   G_err_stage);
                       raise dff_map_exception;

                   END IF;

                   l_attribute_cat_tbl(i) := v_attribute_category;
                   l_attribute1_tbl(i) := v_attribute1;
                   l_attribute2_tbl(i) := v_attribute2;
                   l_attribute3_tbl(i) := v_attribute3;
                   l_attribute4_tbl(i) := v_attribute4;
                   l_attribute5_tbl(i) := v_attribute5;
                   l_attribute6_tbl(i) := v_attribute6;
                   l_attribute7_tbl(i) := v_attribute7;
                   l_attribute8_tbl(i) := v_attribute8;
                   l_attribute9_tbl(i) := v_attribute9;
                   l_attribute10_tbl(i) := v_attribute10;

	   ElSE /* if DFF profile is No. Added for Bug 3105153*/
                   l_attribute_cat_tbl(i) := NULL;
                   l_attribute1_tbl(i) := NULL;
                   l_attribute2_tbl(i) := NULL;
                   l_attribute3_tbl(i) := NULL;
                   l_attribute4_tbl(i) := NULL;
                   l_attribute5_tbl(i) := NULL;
                   l_attribute6_tbl(i) := NULL;
                   l_attribute7_tbl(i) := NULL;
                   l_attribute8_tbl(i) := NULL;
                   l_attribute9_tbl(i) := NULL;
                   l_attribute10_tbl(i) := NULL;

           END IF; /* if DFF profile is Yes */

      END LOOP; /* End of looping through each record in plsql table */

   EXCEPTION
      WHEN OTHERS THEN
          write_log(LOG,'Failed during process_disc_logic for discount processing');
          G_err_code   := SQLCODE;
          raise;

   END process_disc_logic;

   BEGIN
   /* Main Procedure Logic starts here */

   G_err_stage := 'Entering main processing logic of transfer_disc_to_pa';
   write_log(LOG,   G_err_stage);

     v_max_size := nvl(G_COMMIT_SIZE,200);

      G_err_stage:= 'Opening Discount_cour';
      write_log(LOG, G_err_stage);

      OPEN Discount_Cur;

      WHILE (v_all_done = 0) LOOP

          G_err_stage:='Discount Cursor is opened, looping through batches';
          write_log(LOG,   G_err_stage);

          clear_plsql_tables;

          G_err_stage := 'CREATING NEW INTERFACE ID';
          write_log(LOG, G_err_stage);

          SELECT pa_interface_id_s.nextval
            INTO G_DISC_INTERFACE_ID
            FROM dual;

          G_err_stage := 'Fetching Discount Cursor';
          write_log(LOG, G_err_stage);

          FETCH Discount_Cur BULK COLLECT INTO
              l_inv_pay_id_tbl
             ,l_invoice_id_tbl
             ,l_invoice_dist_id_tbl
             ,l_cdl_sys_ref3_tbl
             ,l_project_id_tbl
             ,l_task_id_tbl
             ,l_employee_id_tbl
             ,l_exp_type_tbl
             ,l_ei_date_tbl
             ,l_vendor_id_tbl
             ,l_created_by_tbl
             ,l_exp_org_id_tbl
             ,l_quantity_tbl
             ,l_job_id_tbl
             ,l_description_tbl
             ,l_dist_cc_id_tbl
             ,l_acct_pay_cc_id_tbl
             ,l_gl_date_tbl
             ,l_attribute_cat_tbl
             ,l_attribute1_tbl
             ,l_attribute2_tbl
             ,l_attribute3_tbl
             ,l_attribute4_tbl
             ,l_attribute5_tbl
             ,l_attribute6_tbl
             ,l_attribute7_tbl
             ,l_attribute8_tbl
             ,l_attribute9_tbl
             ,l_attribute10_tbl
             ,l_inv_type_code_tbl
             ,l_org_id_tbl
             ,l_invoice_num_tbl
             ,l_ln_type_lookup_tbl
             ,l_source_tbl
             ,l_denom_raw_cost_tbl
             ,l_amount_tbl
             ,l_denom_cur_code_tbl
             ,l_acct_rate_date_tbl
             ,l_acct_rate_type_tbl
             ,l_acct_exch_rate_tbl
             ,l_cdl_sys_ref4_tbl
             ,l_txn_src_tbl
             ,l_user_txn_src_tbl
             ,l_batch_name_tbl
             ,l_interface_id_tbl
             ,l_exp_end_date_tbl
             ,l_txn_status_code_tbl
             ,l_txn_rej_code_tbl
             ,l_bus_grp_id_tbl
             ,l_reversal_flag_tbl
             ,l_cancel_flag_tbl
             ,l_parent_pmt_id_tbl
             ,l_net_zero_flag_tbl
             ,l_sc_xfer_code_tbl
             ,l_adj_exp_item_id_tbl
             ,l_fc_enabled_tbl
             ,l_mrc_exchange_date_tbl
             ,l_fc_document_type_tbl
             ,l_si_assts_add_flg_tbl
             ,l_insert_flag_tbl
             ,l_pay_hist_id_tbl
             ,l_pa_add_flag_tbl
            LIMIT v_max_size;

         IF l_inv_pay_id_tbl.COUNT <> 0 THEN

            G_DISC_TRANSACTION_SOURCE      := 'AP DISCOUNTS' ;
            G_DISC_USER_TRANSACTION_SOURCE := 'Supplier Invoice Discounts From Payables';

            v_last_disc_index := l_invoice_id_tbl.LAST;
            G_err_stage := 'Calling process logic for discount processsing';
            write_log(LOG, G_err_stage);

            process_disc_logic;

            G_err_stage := 'Calling Bulk Insert into trx intf for discounts';
            write_log(LOG, G_err_stage);

            bulk_insert_trx_intf;

            IF (v_num_discounts_fetched > 0) THEN

               G_err_stage := 'Calling trans import for discounts';
               write_log(LOG, G_err_stage);

           IF G_ACCTNG_METHOD = 'C' THEN
              IF l_ap_inv_disc_flag = 'Y' THEN
               trans_import('AP INVOICE', G_DISC_BATCH_NAME,G_DISC_INTERFACE_ID, G_USER_ID);
               tieback_payment_AP_ER('AP INVOICE', G_DISC_BATCH_NAME, 'APDISC',G_DISC_INTERFACE_ID);
              END IF;
              IF l_ap_nrt_disc_flag = 'Y' THEN
               trans_import('AP NRTAX', G_DISC_BATCH_NAME,G_DISC_INTERFACE_ID, G_USER_ID);
               tieback_payment_AP_ER('AP NRTAX', G_DISC_BATCH_NAME, 'APDISC',G_DISC_INTERFACE_ID);
              END IF;
              IF l_ap_hist_disc_flag = 'Y' THEN
               trans_import(G_DISC_TRANSACTION_SOURCE, G_DISC_BATCH_NAME,G_DISC_INTERFACE_ID, G_USER_ID);
               tieback_payment_AP_ER(G_DISC_TRANSACTION_SOURCE, G_DISC_BATCH_NAME, 'APDISC',G_DISC_INTERFACE_ID);
              END IF;
           ELSE
               trans_import(G_DISC_TRANSACTION_SOURCE, G_DISC_BATCH_NAME,G_DISC_INTERFACE_ID, G_USER_ID);
               tieback_payment_AP_ER(G_DISC_TRANSACTION_SOURCE, G_DISC_BATCH_NAME, 'APDISC',G_DISC_INTERFACE_ID);
           END IF;

               G_NUM_BATCHES_PROCESSED := G_NUM_BATCHES_PROCESSED + 1;
               G_NUM_DISCOUNTS_PROCESSED := G_NUM_DISCOUNTS_PROCESSED + v_num_discounts_fetched;

            END IF; /* IF (v_num_discounts_fetched > 0) */

            clear_plsql_tables;

        ELSE

          G_err_stage := 'plsql table for discounts is empty. Exiting';
          write_log(LOG, G_err_stage);

          EXIT; /* Exit if /* l_inv_pay_id_tbl.COUNT = 0 */

        END IF; /* l_inv_pay_id_tbl.COUNT = 0 */

        v_num_discounts_fetched :=0;
        v_num_payments_fetched := 0;

        EXIT WHEN Discount_Cur%NOTFOUND;

      END LOOP; /* While v_all_done = 0 */

      G_err_stage := 'Closing Discount cursor';
      write_log(LOG, G_err_stage);

      CLOSE Discount_cur;

EXCEPTION
    WHEN OTHERS THEN

         G_err_stack := v_old_stack;
         IF Discount_Cur%ISOPEN THEN
           CLOSE Discount_Cur;
         END IF ;

         G_err_code := SQLCODE;
         RAISE;

END transfer_disc_to_pa;


PROCEDURE mark_RCV_PAflag IS

   v_status     VARCHAR2(30);

BEGIN

   G_err_stack := G_err_stack || '->PAAPIMP_PKG.mark_RCV_PAflag';
   write_log(LOG, 'UPDATING RCV_TRANSACTIONS -Marking Process');

   /* mark all the rcv sub ledger records pa_addition_flag to NULL for any rcv transactions
      that are non-project related or with a non-EXPENSE destination_type_code,which is not a return or is not actual*/
    -- This update has been moved to pa_po_integration_utils.update_pa_addition_flag.


   /* mark rcv sub ledger records pa_addition_flag to O/J for rcv transactions that are
     project related and fit the criteria to be pulled into Projects.
     Divided into project_ID IS NULL and NOT NULL section for better performance
   */

   IF G_PROJECT_ID IS NOT NULL THEN

   /* Modified the below update statement for better performence bug#7526677
   Not commenting and doing the changes because it has already become a mess with these updates
   */

	   UPDATE rcv_receiving_sub_ledger rcv_sub
	      SET rcv_sub.pa_Addition_Flag       = decode(rcv_sub.pa_addition_flag,'N','O','I','J'),
		  rcv_sub.request_id             = G_REQUEST_ID,
		  rcv_sub.last_update_date       = SYSDATE,
		  rcv_sub.last_updated_by        = G_USER_ID,
		  rcv_sub.last_update_login      = G_USER_ID,
		  rcv_sub.program_id             = G_PROG_ID,
		  rcv_sub.program_application_id = G_PROG_APPL_ID,
		  rcv_sub.program_update_date    = SYSDATE
	    WHERE exists
		(SELECT 1 --rcv_sub1.ROWID --Removed /*+ leading(po_dist) */ for Bug5262594
                 FROM Rcv_Transactions rcv_txn,
                      PO_Distributions po_dist
		WHERE ((rcv_txn.destination_type_code ='EXPENSE' )
		    OR (rcv_txn.destination_type_code = 'RECEIVING'
                    AND (rcv_txn.transaction_type IN ('RETURN TO VENDOR','RETURN TO RECEIVING'))))
		AND trunc(rcv_txn.transaction_date)      <= trunc(nvl(G_GL_DATE,rcv_txn.transaction_date))      /*Added trunc for the bug 6623163 */
		AND rcv_txn.PO_DISTRIBUTION_ID    =  po_dist.po_distribution_id
		AND rcv_sub.code_combination_id   =  po_dist.code_combination_id
                AND nvl(po_dist.distribution_type,'XXX') <> 'PREPAYMENT'   --bug 7192304, added nvl
		AND rcv_sub.rcv_transaction_id    =  rcv_txn.transaction_id
		AND trunc(po_dist.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,po_dist.expenditure_item_date)) /*Added trunc for the bug 6623163 */
		AND po_dist.project_ID  > 0
		AND po_dist.accrue_on_receipt_flag= 'Y'
		AND nvl(rcv_txn.project_id , po_dist.project_id)  = G_PROJECT_ID  /*Added for bug:7046666*/
		/* Start added for bug#6015451 */
		AND ( (rcv_txn.destination_type_code = 'EXPENSE' AND
		        rcv_txn.transaction_type <> 'RETURN TO RECEIVING' AND rcv_sub.entered_dr is NOT NULL
		       ) OR
		       ((rcv_txn.destination_type_code = 'RECEIVING' OR
		         rcv_txn.transaction_type = 'RETURN TO RECEIVING') AND rcv_sub.entered_cr is NOT NULL
                        )
		     )
		/* Ends added for bug#6015451 */
		)
	    AND rcv_sub.pa_addition_flag IN ('N','I')
		AND rcv_sub.actual_flag = 'A';

	     G_RCV_TRANSACTIONS_MARKED_O := SQL%ROWCOUNT;
             write_log(LOG, 'Number of rcvtxn marked to O or J:' || to_char(SQL%ROWCOUNT));


   ELSIF G_PROJECT_ID IS NULL THEN

   /* Modified the below update statement for better performence bug#7526677
   Not commenting and doing the changes because it has already become a mess with these updates
   */

	   UPDATE rcv_receiving_sub_ledger rcv_sub
	      SET rcv_sub.pa_Addition_Flag       = decode(rcv_sub.pa_addition_flag,'N','O','I','J'),
		  rcv_sub.request_id             = G_REQUEST_ID,
		  rcv_sub.last_update_date       = SYSDATE,
		  rcv_sub.last_updated_by        = G_USER_ID,
		  rcv_sub.last_update_login      = G_USER_ID,
		  rcv_sub.program_id             = G_PROG_ID,
		  rcv_sub.program_application_id = G_PROG_APPL_ID,
		  rcv_sub.program_update_date    = SYSDATE
	    WHERE exists
               (SELECT 1 --rcv_sub1.ROWID --Removed /*+ leading(po_dist) */ for Bug5262594
                 FROM Rcv_Transactions rcv_txn,
                      PO_Distributions po_dist
		WHERE ((rcv_txn.destination_type_code ='EXPENSE' )
		    OR (rcv_txn.destination_type_code = 'RECEIVING'
                    AND (rcv_txn.transaction_type IN ('RETURN TO VENDOR','RETURN TO RECEIVING'))))
		AND trunc(rcv_txn.transaction_date)      <= trunc(nvl(G_GL_DATE,rcv_txn.transaction_date))      /*Added trunc for the bug 6623163 */
		AND rcv_txn.PO_DISTRIBUTION_ID    =  po_dist.po_distribution_id
		AND rcv_sub.code_combination_id   =  po_dist.code_combination_id
                AND nvl(po_dist.distribution_type,'XXX') <> 'PREPAYMENT'    -- bug 7192304, added nvl
		AND rcv_sub.rcv_transaction_id    =  rcv_txn.transaction_id
		AND trunc(po_dist.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,po_dist.expenditure_item_date)) /*Added trunc for the bug 6623163 */
		AND po_dist.project_ID  > 0
		AND po_dist.accrue_on_receipt_flag= 'Y'
		/* Starts added for bug#6015451 */
		AND ( (rcv_txn.destination_type_code = 'EXPENSE' AND
		        rcv_txn.transaction_type <> 'RETURN TO RECEIVING' AND rcv_sub.entered_dr is NOT NULL
		       ) OR
		       ((rcv_txn.destination_type_code = 'RECEIVING' OR
		         rcv_txn.transaction_type = 'RETURN TO RECEIVING') AND rcv_sub.entered_cr is NOT NULL
                        )
		     )
		/* Ends added for bug#6015451 */
		)
		AND rcv_sub.pa_addition_flag IN ('N','I')
        AND rcv_sub.actual_flag = 'A';


	     G_RCV_TRANSACTIONS_MARKED_O := SQL%ROWCOUNT;
	     write_log(LOG, 'Number of rcvtxn marked to O or J:' || to_char(SQL%ROWCOUNT));

    END IF;

EXCEPTION
   WHEN Others THEN
      G_err_code := SQLCODE;
      RAISE;

END mark_RCV_PAflag;

PROCEDURE transfer_receipts_to_pa  IS

   v_total_num_receipts            NUMBER := 0;
   v_num_receipts_processed        NUMBER := 0;
   v_num_receipt_tax_processed     NUMBER := 0;
   l_denom_cost                    NUMBER :=0;
   l_acct_cost                     NUMBER :=0;
   l_quantity                      NUMBER :=0;
   l_record_type                   VARCHAR2(20);

   v_max_size                      NUMBER := 0;

   v_old_stack                     VARCHAR2(630);
   v_err_message                   VARCHAR2(220);
   v_all_done                      NUMBER := 0;

   v_status Number := 0;
   v_stage  Number :=0;

   v_last_rcv_index             NUMBER := 0;
   v_prev_po_head_id     NUMBER := 0;
   v_prev_po_dist_id     NUMBER := 0;
   v_business_group_id   NUMBER := 0;
   v_attribute_category  VARCHAR2(150);
   v_attribute1 VARCHAR2(150);
   v_attribute2 VARCHAR2(150);
   v_attribute3 VARCHAR2(150);
   v_attribute4 VARCHAR2(150);
   v_attribute5 VARCHAR2(150);
   v_attribute6 VARCHAR2(150);
   v_attribute7 VARCHAR2(150);
   v_attribute8 VARCHAR2(150);
   v_attribute9 VARCHAR2(150);
   v_attribute10 VARCHAR2(150);
   v_dff_map_status VARCHAR2(30);
   dff_map_exception EXCEPTION;
   l_create_adj_recs     VARCHAR2(1) := 'N';

   /* the following sub-procedure is declared here to save lines of code since deleting
      plsql tables will be done multiple times within the procedure transfer_receipts_to_pa */

   PROCEDURE clear_plsql_tables IS

       l_status1 VARCHAR2(30);

   BEGIN

       G_err_stage := 'within clear_plsql_tables of transfer_receipts_to_pa';
       write_log(LOG, G_err_stage);

   l_rcv_txn_id_tbl.delete;
   l_po_dist_id_tbl.delete;
   l_po_head_id_tbl.delete;
   l_po_num_tbl.delete;
   l_quantity_tbl.delete;
   l_entered_dr_tbl.delete;
   l_entered_cr_tbl.delete;
   l_accounted_dr_tbl.delete;
   l_accounted_cr_tbl.delete;
   l_entered_nr_tax_tbl.delete;
   l_accounted_nr_tax_tbl.delete;
   l_denom_raw_cost_tbl.delete;
   l_acct_raw_cost_tbl.delete;
   l_record_type_tbl.delete;
   l_dist_cc_id_tbl.delete;
   l_denom_cur_code_tbl.delete;
   l_acct_rate_date_tbl.delete;
   l_acct_rate_type_tbl.delete;
   l_acct_exch_rate_tbl.delete;
   l_gl_date_tbl.delete;
   l_dest_typ_code_tbl.delete;
   l_pa_add_flag_tbl.delete;
   l_trx_type_tbl.delete;
   l_project_id_tbl.delete;
   l_task_id_tbl.delete;
   l_employee_id_tbl.delete;
   l_exp_type_tbl.delete;
   l_ei_date_tbl.delete;
   l_vendor_id_tbl.delete;
   l_exp_org_id_tbl.delete;
   l_job_id_tbl.delete;
   l_description_tbl.delete;
   l_attribute_cat_tbl.delete;
   l_attribute1_tbl.delete;
   l_attribute2_tbl.delete;
   l_attribute3_tbl.delete;
   l_attribute4_tbl.delete;
   l_attribute5_tbl.delete;
   l_attribute6_tbl.delete;
   l_attribute7_tbl.delete;
   l_attribute8_tbl.delete;
   l_attribute9_tbl.delete;
   l_attribute10_tbl.delete;
   l_org_id_tbl.delete;
   l_cdl_sys_ref4_tbl.delete;
   l_txn_src_tbl.delete;
   l_user_txn_src_tbl.delete;
   l_batch_name_tbl.delete;
   l_interface_id_tbl.delete;
   l_exp_end_date_tbl.delete;
   l_txn_status_code_tbl.delete;
   l_txn_rej_code_tbl.delete;
   l_bus_grp_id_tbl.delete;
   l_insert_flag_tbl.delete;
   l_rcv_acct_evt_id_tbl.delete; -- pricing changes
   l_rcv_acct_evt_typ_tbl.delete; -- pricing changes
   l_rcv_acct_rec_tax_tbl.delete; -- pricing changes
   l_rcv_ent_rec_tax_tbl.delete; -- pricing changes
   l_parent_rcv_id_tbl.delete;   -- NEW --added for full return reversal logic
   l_net_zero_flag_tbl.delete;
   l_sc_xfer_code_tbl.delete; --NEW
   l_adj_exp_item_id_tbl.delete; --NEW
   l_fc_enabled_tbl.delete; --NEW
   l_fc_document_type_tbl.delete; --NEW
   l_rcv_sub_ledger_id_tbl.delete;
   l_si_assts_add_flg_tbl.delete;
   l_exp_cst_rt_flg_tbl.delete; --NEW
   l_po_tax_qty_tbl.delete;

   END clear_plsql_tables;

   PROCEDURE bulk_insert_trx_intf IS

     l_status2 VARCHAR2(30);

   BEGIN

      FORALL i IN l_rcv_txn_id_tbl.FIRST..l_rcv_txn_id_tbl.LAST

       INSERT INTO pa_transaction_interface_all(
                     transaction_source
                    , user_transaction_source
                    , system_linkage
                    , batch_name
                    , expenditure_ending_date
                    , expenditure_item_date
                    , expenditure_type
                    , quantity
                    , raw_cost_rate
                    , expenditure_comment
                    , transaction_status_code
                    , transaction_rejection_code
                    , orig_transaction_reference
                    , interface_id
                    , dr_code_combination_id
                    , cr_code_combination_id
                    , cdl_system_reference1
                    , cdl_system_reference2
                    , cdl_system_reference3
                    , cdl_system_reference4
                    , cdl_system_reference5
                    , gl_date
                    , org_id
                    , unmatched_negative_txn_flag
                    , denom_raw_cost
                    , denom_currency_code
                    , acct_rate_date
                    , acct_rate_type
                    , acct_exchange_rate
                    , acct_raw_cost
                    , acct_exchange_rounding_limit
                    , attribute_category
                    , attribute1
                    , attribute2
                    , attribute3
                    , attribute4
                    , attribute5
                    , attribute6
                    , attribute7
                    , attribute8
                    , attribute9
                    , attribute10
                    , orig_exp_txn_reference1
                    , orig_user_exp_txn_reference
                    ,  orig_exp_txn_reference2
                    ,  orig_exp_txn_reference3
                    , last_update_date
                    , last_updated_by
                    , creation_date
                    , created_by
                    , person_id
                    , organization_id
                    , project_id
                    , task_id
                    , Vendor_id
                    , override_to_organization_id
                    , person_business_group_id
                    , adjusted_expenditure_item_id --NEW
                    , fc_document_type  -- NEW
                    , document_type
                    , document_distribution_type
                    , sc_xfer_code
                    , si_assets_addition_flag
                    , net_zero_adjustment_flag
                   )
               SELECT l_txn_src_tbl(i)
                     ,l_user_txn_src_tbl(i)
                     ,G_SYSTEM_LINKAGE
                     ,l_batch_name_tbl(i)
                     ,l_exp_end_date_tbl(i)
                     ,l_ei_date_tbl(i)
                     ,l_exp_type_tbl(i)
                     ,l_quantity_tbl(i)
                     ,l_acct_raw_cost_tbl(i)/decode(nvl(l_quantity_tbl(i),0),0,1,l_quantity_tbl(i))
                     ,l_description_tbl(i)
                     ,l_txn_status_code_tbl(i)
                     ,l_txn_rej_code_tbl(i)
                     ,G_REQUEST_ID
                     ,l_interface_id_tbl(i)
                     ,l_dist_cc_id_tbl(i)
                     ,NULL
                     ,l_vendor_id_tbl(i)
                     ,l_po_head_id_tbl(i)
                     ,l_po_dist_id_tbl(i)
                     ,l_rcv_txn_id_tbl(i)
                     ,l_rcv_sub_ledger_id_tbl(i)
                     ,l_gl_date_tbl(i)
                     ,G_ORG_ID
                     ,'Y'
                     ,l_denom_raw_cost_tbl(i)
                     ,l_denom_cur_code_tbl(i)
                     ,l_acct_rate_date_tbl(i)
                     ,l_acct_rate_type_tbl(i)
                     ,l_acct_exch_rate_tbl(i)
                     ,l_acct_raw_cost_tbl(i)
                     ,1
                     ,l_attribute_cat_tbl(i)
                     ,l_attribute1_tbl(i)
                     ,l_attribute2_tbl(i)
                     ,l_attribute3_tbl(i)
                     ,l_attribute4_tbl(i)
                     ,l_attribute5_tbl(i)
                     ,l_attribute6_tbl(i)
                     ,l_attribute7_tbl(i)
                     ,l_attribute8_tbl(i)
                     ,l_attribute9_tbl(i)
                     ,l_attribute10_tbl(i)
                     ,l_po_dist_id_tbl(i)        /*orig_exp_txn_reference1*/
                     ,l_rcv_txn_id_tbl(i)        /*user_exp_txn_reference*/
                     ,l_rcv_acct_evt_id_tbl(i)   /*orig_exp_txn_reference2*/
                     ,NULL                       /*orig_exp_txn_reference3*/
                     ,SYSDATE
                     ,-1
                     ,SYSDATE
                     ,-1
                     ,l_employee_id_tbl(i)
                     ,l_org_id_tbl(i)
                     ,l_project_id_tbl(i)
                     ,l_task_id_tbl(i)
                     ,l_vendor_id_tbl(i)
                     ,l_exp_org_id_tbl(i)
                     ,l_bus_grp_id_tbl(i)
                     ,l_adj_exp_item_id_tbl(i) --NEW for reversals
                     ,l_fc_document_type_tbl(i) --NEW for funds check
                     ,l_dest_typ_code_tbl(i)
                     ,l_trx_type_tbl(i)
                     ,l_sc_xfer_code_tbl(i)
                     ,l_si_assts_add_flg_tbl(i)
                     ,l_net_zero_flag_tbl(i)
                  FROM dual
                 WHERE l_insert_flag_tbl(i) in  ('Y','A');

              -- Insert the adjustment recs from AP.
    IF l_create_adj_recs = 'Y' THEN

                write_log(LOG, 'Inserting adjustment records..');

      FORALL i IN l_rcv_txn_id_tbl.FIRST..l_rcv_txn_id_tbl.LAST

       INSERT INTO pa_transaction_interface_all(
                     transaction_source
                    , user_transaction_source
                    , system_linkage
                    , batch_name
                    , expenditure_ending_date
                    , expenditure_item_date
                    , expenditure_type
                    , quantity
                    , raw_cost_rate
                    , expenditure_comment
                    , transaction_status_code
                    , transaction_rejection_code
                    , orig_transaction_reference
                    , interface_id
                    , dr_code_combination_id
                    , cr_code_combination_id
                    , cdl_system_reference1
                    , cdl_system_reference2
                    , cdl_system_reference3
                    , cdl_system_reference4
                    , cdl_system_reference5
                    , gl_date
                    , org_id
                    , unmatched_negative_txn_flag
                    , denom_raw_cost
                    , denom_currency_code
                    , acct_rate_date
                    , acct_rate_type
                    , acct_exchange_rate
                    , acct_raw_cost
                    , acct_exchange_rounding_limit
                    , attribute_category
                    , attribute1
                    , attribute2
                    , attribute3
                    , attribute4
                    , attribute5
                    , attribute6
                    , attribute7
                    , attribute8
                    , attribute9
                    , attribute10
                    , orig_exp_txn_reference1
                    , orig_user_exp_txn_reference
                    ,  orig_exp_txn_reference2
                    ,  orig_exp_txn_reference3
                    , last_update_date
                    , last_updated_by
                    , creation_date
                    , created_by
                    , person_id
                    , organization_id
                    , project_id
                    , task_id
                    , Vendor_id
                    , override_to_organization_id
                    , person_business_group_id
                    , adjusted_expenditure_item_id --NEW
                    , fc_document_type  -- NEW
                    , document_type
                    , document_distribution_type
                    , adjusted_txn_interface_id
                    , sc_xfer_code
                    , si_assets_addition_flag
                    , net_zero_adjustment_flag
                   )
               SELECT l_txn_src_tbl(i)
                     ,l_user_txn_src_tbl(i)
                     ,G_SYSTEM_LINKAGE
                     ,l_batch_name_tbl(i)
                     ,l_exp_end_date_tbl(i)
                     ,l_ei_date_tbl(i)
                     ,l_exp_type_tbl(i)
                     ,-l_quantity_tbl(i)
                     ,l_acct_raw_cost_tbl(i)/decode(nvl(l_quantity_tbl(i),0),0,1,l_quantity_tbl(i))
                     ,l_description_tbl(i)
                     ,l_txn_status_code_tbl(i)
                     ,l_txn_rej_code_tbl(i)
                     ,G_REQUEST_ID
                     ,l_interface_id_tbl(i)
                     ,l_dist_cc_id_tbl(i)
                     ,NULL
                     ,l_vendor_id_tbl(i)
                     ,l_po_head_id_tbl(i)
                     ,l_po_dist_id_tbl(i)
                     ,l_rcv_txn_id_tbl(i)
                     ,l_rcv_sub_ledger_id_tbl(i)
                     ,l_gl_date_tbl(i)
                     ,G_ORG_ID
                     ,'Y'
                     ,-l_denom_raw_cost_tbl(i)
                     ,l_denom_cur_code_tbl(i)
                     ,l_acct_rate_date_tbl(i)
                     ,l_acct_rate_type_tbl(i)
                     ,l_acct_exch_rate_tbl(i)
                     ,-l_acct_raw_cost_tbl(i)
                     ,1
                     ,l_attribute_cat_tbl(i)
                     ,l_attribute1_tbl(i)
                     ,l_attribute2_tbl(i)
                     ,l_attribute3_tbl(i)
                     ,l_attribute4_tbl(i)
                     ,l_attribute5_tbl(i)
                     ,l_attribute6_tbl(i)
                     ,l_attribute7_tbl(i)
                     ,l_attribute8_tbl(i)
                     ,l_attribute9_tbl(i)
                     ,l_attribute10_tbl(i)
                     ,l_po_dist_id_tbl(i)        /*orig_exp_txn_reference1*/
                     ,l_rcv_txn_id_tbl(i)        /*user_exp_txn_reference*/
                     ,l_rcv_acct_evt_id_tbl(i)   /*orig_exp_txn_reference2*/
                     ,NULL                       /*orig_exp_txn_reference3*/
                     ,SYSDATE
                     ,-1
                     ,SYSDATE
                     ,-1
                     ,l_employee_id_tbl(i)
                     ,l_org_id_tbl(i)
                     ,l_project_id_tbl(i)
                     ,l_task_id_tbl(i)
                     ,l_vendor_id_tbl(i)
                     ,l_exp_org_id_tbl(i)
                     ,l_bus_grp_id_tbl(i)
                     ,l_adj_exp_item_id_tbl(i) --NEW for reversals
                     ,l_fc_document_type_tbl(i) --NEW for funds check
                     ,l_dest_typ_code_tbl(i)
                     ,l_trx_type_tbl(i)
                     ,(select xface.txn_interface_id
                      from   pa_transaction_interface xface
                      where  xface.interface_id =  l_interface_id_tbl(i)
                      and    xface.transaction_source = l_txn_src_tbl(i)
                      and    xface.cdl_system_reference2 = l_po_head_id_tbl(i)
                      and    xface.cdl_system_reference3 = l_po_dist_id_tbl(i)
                      and    xface.cdl_system_reference4 = to_char(l_rcv_txn_id_tbl(i))
		      and    nVL(xface.adjusted_expenditure_item_id,0) = 0 ) -- R12 funds management Uptake
                     ,'P'  -- sc_xfer_code
                     ,'T'  -- Si assets flag
                     ,l_net_zero_flag_tbl(i)
                  FROM dual
                  WHERE l_insert_flag_tbl(i) = 'A';
    END IF;

   EXCEPTION
      WHEN OTHERS THEN
          write_log(LOG,'Failed during bulk insert for receipt processing');
          G_err_code   := SQLCODE;
          raise;

   END bulk_insert_trx_intf;

   PROCEDURE process_receipt_logic IS

       l_status_3 VARCHAR2(30);
       l_evt_typ_name VARCHAR2(30);
       j NUMBER := 0; --Index variable for creating reversal EI's --NEW
       l_historical_flag VARCHAR(1);  --NEW
       l_process_adjustments    Number := 0 ;


                         l_primary_quantity     NUMBER;
                         l_amount               NUMBER;
                         l_exists               VARCHAR2(1);

   BEGIN

      G_err_stage:='Within process_receipt_logic';
      write_log(LOG,   G_err_stage);

      j := v_last_rcv_index; -- initialize j to the total invoice distributions fetched in the PLSQL array
      FOR i IN l_rcv_txn_id_tbl.FIRST..l_rcv_txn_id_tbl.LAST LOOP

          G_err_stage:=('processing receipt of rcvtxn_id:  '||l_rcv_txn_id_tbl(i)||
                       'of po_dist_id:  '||l_po_dist_id_tbl(i));
          write_log(LOG,   G_err_stage);

          G_err_stage := 'Calling lock_ap_invoice within pa_add_flag is O';
          write_log(LOG,   G_err_stage);

          lock_ap_invoice(l_po_dist_id_tbl(i));

          G_TRANSACTION_REJECTION_CODE  :='';
          G_TRANSACTION_STATUS_CODE     := 'P';

          /*
            When the Receipt Amount is NULL, mark status code as R in
            transaction interface table such that the record wont' be interfaceed.
          */
          write_log(LOG, 'Checking if the Receipt Amount is Null...');

          IF (l_entered_dr_tbl(i)     IS NULL AND
              l_entered_nr_tax_tbl(i) IS NULL ) THEN

             G_TRANSACTION_STATUS_CODE := 'R';
             G_TRANSACTION_REJECTION_CODE := 'INVALID_AMOUNT';
             write_log(LOG, 'As PO Receipt Amount is NULL, Rejecting PO Receipt : '||l_rcv_txn_id_tbl(i));

          END IF;

          G_err_stage := ('Before getting business group id');
          write_log(LOG, G_err_stage);

          IF (nvl(l_po_head_id_tbl(i),0)<>v_prev_po_head_id) THEN

             v_prev_po_head_id := l_po_head_id_tbl(i);

             BEGIN

               IF nvl(l_employee_id_tbl(i),0) <> 0 THEN

                 SELECT emp.business_group_id
                   INTO G_PER_BUS_GRP_ID
                   FROM per_all_people_f emp
                  WHERE emp.person_id = l_employee_id_tbl(i)
                          AND l_ei_date_tbl(i) between trunc(emp.effective_start_date) and
                                                       trunc(emp.effective_end_date);

               END IF;

             EXCEPTION
              WHEN NO_DATA_FOUND THEN

                 l_txn_status_code_tbl(i) := 'R';
                 G_TRANSACTION_REJECTION_CODE := 'INVALID_EMPLOYEE';
                 write_log(LOG, 'no data found for Employee, Rejecting receipt'||l_rcv_txn_id_tbl(i)  );

             END;

          END IF;

          IF (nvl(l_po_dist_id_tbl(i),0)<>v_prev_po_dist_id) THEN

             v_prev_po_dist_id := l_po_dist_id_tbl(i);

             G_err_stage := 'GET MAX EXPENDITURE ENDING DATE for Receipt Accruals';
             write_log(LOG,   G_err_stage);

             /* Get the weekending date of the maximum expenditure item date of this PO distribution */

/* Bug 5051103 - replace expnediture_item_date with l_ei_date_tbl(i) */
             SELECT pa_utils.getweekending(MAX(l_ei_date_tbl(i)))
               INTO G_EXPENDITURE_ENDING_DATE
               FROM po_distributions
              WHERE po_distribution_id = l_po_dist_id_tbl(i);

          END IF;

         write_log(LOG,'Fetched a po receipt record of destination type:'||
                        l_dest_typ_code_tbl(i)||
                       'and trx type of:'||l_trx_type_tbl(i));

         v_total_num_receipts := v_total_num_receipts +1 ;
         write_log(LOG,'Number of receipts fetched:  '||v_total_num_receipts);

	     IF (l_rcv_acct_evt_id_tbl(i) IS NULL) THEN

    	        l_txn_src_tbl(i)         := G_RCV_TRANSACTION_SOURCE;
	            l_user_txn_src_tbl(i)    := G_RCV_USER_TRANSACTION_SOURCE;
	     ELSE

        		SELECT event_type_name
	        	INTO l_evt_typ_name
        		FROM rcv_accounting_event_types rcv_acct_evt_typ, rcv_accounting_events rcv_acct_evts
        		WHERE rcv_acct_evt_typ.event_type_id = rcv_acct_evts.event_type_id
        		AND rcv_acct_evts.accounting_event_id = l_rcv_acct_evt_id_tbl(i);

        		IF (l_evt_typ_name in ('ADJUST_DELIVER','ADJUST_RECEIVE')) THEN
        			l_txn_src_tbl(i)         := G_RCV_PRC_ADJ_TRX_SRC;
        			l_user_txn_src_tbl(i)    := G_RCV_PRC_ADJ_USER_TRX_SRC;
                                l_quantity               := 0;
        		ELSE
        			l_txn_src_tbl(i)         := G_RCV_TRANSACTION_SOURCE;
        			l_user_txn_src_tbl(i)    := G_RCV_USER_TRANSACTION_SOURCE;
        		END IF;

	     END IF;

	     l_batch_name_tbl(i)      := G_RCV_BATCH_NAME;
	     l_interface_id_tbl(i)    := G_RCV_INTERFACE_ID;

             l_bus_grp_id_tbl(i)      := G_PER_BUS_GRP_ID;
             l_exp_end_date_tbl(i)    := G_EXPENDITURE_ENDING_DATE;
             l_txn_status_code_tbl(i) := G_TRANSACTION_STATUS_CODE;
             l_txn_rej_code_tbl(i)    := G_TRANSACTION_REJECTION_CODE;


         IF l_pa_add_flag_tbl(i) = 'O' THEN

            write_log(LOG,'PA_addition_flag for this RCV transaction has been marked to O');

            /* If the pa_addition_flag is updated to 'O', then it means we would need
               to break down the amount of the receipt into two portions. One is the
               total minus tax and the other is just the NR Tax portion. This Loop
               will process the total minus tax portion.  After inserting this amount
               , the next loop will insert the tax portion of the receipt into the
               tranasction_interface table */

            v_num_receipts_processed := v_num_receipts_processed + 1;

            /* for the amount that we are selecting, we need to see whether the transaction is an
               EXPENSE or RECEIVING transactions. EXPENSE means we take the positive value of dr column
               minus the tax amount while RECEIVNG transaction means it is a return, so we take the
               negative of the cr column plus the tax amount. If the trasnaction is a RETURN,
               then we want the quantity to be a negative quantity */

         -- call the function to check if the txn got interfaced through AP. If Yes, then set the pa_add_flag to G.
          IF ReceiptPaAdditionFlag(p_Pa_Addition_Flag     => l_pa_add_flag_tbl(i),
                                     p_Po_Distribution_Id   => l_po_dist_id_tbl(i)) = 'G' THEN


             write_log(LOG,'PA_addition_flag for this RCV transaction should be marked to G');

                          l_insert_flag_tbl(i) := 'N';
                          l_pa_add_flag_tbl(i) := 'G';

          ELSE

            l_record_type:= 'RECEIPT';

           /* If the PO Receipt is for Contingent Worker labor type and the CWK timecard is to be processed
              as Labor cost in the Project operating unit, then only the non recoverable tax receipt lines
              should be pulled from PO, otherwise the entire receipt with tax should be processed from PO */

            IF PA_PJC_CWK_UTILS.Is_rate_based_line(null, l_po_dist_id_tbl(i)) = 'Y'
               AND PA_PJC_CWK_UTILS.Is_CWK_TC_Xface_Allowed(l_project_id_tbl(i)) = 'Y' THEN
               l_insert_flag_tbl(i) := 'N';

               write_log(LOG, 'Receipt is for CWK timecard PO - Only NRTAX will be processed');

            ELSE

              IF (l_dest_typ_code_tbl(i) = 'EXPENSE'  AND
                  l_trx_type_tbl(i)  NOT IN ('CORRECT', 'RETURN TO RECEIVING')) THEN

                l_denom_cost := l_entered_dr_tbl(i)   - l_entered_nr_tax_tbl(i);
                l_acct_cost  := l_accounted_dr_tbl(i) - l_accounted_nr_tax_tbl(i);
                l_quantity   := l_quantity_tbl(i);

              ELSIF ((l_dest_typ_code_tbl(i) = 'EXPENSE' AND l_trx_type_tbl(i)  IN ('CORRECT', 'RETURN TO RECEIVING')) OR
                       ( l_dest_typ_code_tbl(i) = 'RECEIVING'  AND l_trx_type_tbl(i) in('RETURN TO VENDOR',
                                                                                        'RETURN TO RECEIVING' ))) THEN
                      --
                      -- Check if the correction is a complete correction
                      --
                      DECLARE
                         l_primary_quantity     NUMBER;
                         l_amount               NUMBER;
                         l_exists               VARCHAR2(1):= 'N';  /*bug7168636*/
                      BEGIN

                            SELECT primary_quantity, amount
                              INTO l_primary_quantity, l_amount
                              FROM rcv_transactions
                             WHERE transaction_id = l_parent_rcv_id_tbl(i) ;

                                IF ((( ( l_quantity_tbl(i) <> 0 AND l_primary_quantity  = l_quantity_tbl(i)) OR
                                      ( l_amount = l_amount_tbl(i)))   AND
                                       (( l_dest_typ_code_tbl(i) = 'EXPENSE' AND l_trx_type_tbl(i) = 'RETURN TO RECEIVING') OR
                                        ( l_dest_typ_code_tbl(i) = 'RECEIVING'  AND l_trx_type_tbl(i) in ('RETURN TO VENDOR',
                                                                                                         'RETURN TO RECEIVING' )))) OR
                                    ((  ( l_quantity_tbl(i) <> 0 AND l_primary_quantity  = -l_quantity_tbl(i)) OR
                                      ( l_amount = l_amount_tbl(i)))   AND
                                       (( l_dest_typ_code_tbl(i) = 'EXPENSE' AND l_trx_type_tbl(i) = 'CORRECT')))) THEN

                                  -- Check if the parent has been interfaced to Projects.
				  /*bug7168636 handling no data found */
				  BEGIN
                                     SELECT 'Y'
                                       INTO l_exists
                                       FROM dual
                                      WHERE EXISTS (
                                                   SELECT pa_addition_flag
                                                     FROM rcv_receiving_sub_ledger
                                                    WHERE rcv_transaction_id = l_parent_rcv_id_tbl(i)
                                                      AND pa_addition_flag in ('Y','I')) ;
                                   EXCEPTION
                                     WHEN NO_DATA_FOUND THEN
                                     NULL;
                                   END;

                                      IF l_exists = 'Y' THEN


                                         -- Call reversal API
                                         Process_Adjustments(p_record_type               => 'PO_RECEIPT',
                                            p_document_header_id => l_po_head_id_tbl(i),/*Added this for 6945767 */
                                            p_document_distribution_id  => l_parent_rcv_id_tbl(i),
                                            p_current_index             => i,
					    p_last_index                => j);

                                         -- Set the create flag for adjustment records
                                         IF l_insert_flag_tbl(i)= 'A' THEN
                                          l_create_adj_recs := 'Y';
                                         END IF;

                                     END IF;

                              END IF ; -- l_primary_quantity  = l_quantity

                            IF ( l_dest_typ_code_tbl(i) = 'RECEIVING'  OR l_trx_type_tbl(i) = 'RETURN TO RECEIVING' ) THEN
                              l_denom_cost := -l_entered_cr_tbl(i)   + l_entered_nr_tax_tbl(i);
                              l_acct_cost  := -l_accounted_cr_tbl(i) + l_accounted_nr_tax_tbl(i);
                              l_quantity   := -l_quantity_tbl(i);
                           ELSE
                              l_denom_cost := l_entered_dr_tbl(i)   - l_entered_nr_tax_tbl(i);
                              l_acct_cost  := l_accounted_dr_tbl(i) - l_accounted_nr_tax_tbl(i);
                              l_quantity   := l_quantity_tbl(i);
                           END IF;

                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                NULL;

                          WHEN OTHERS THEN
                               RAISE ;
                       END ;

              END IF;

               IF l_quantity = 0 THEN   /* for amount based POs setting the pa quantity to be the same as the transaction cost*/
                   l_quantity := l_denom_cost;
               END IF;


            END IF; -- End of check for Contingent worker

       END IF; -- ReceiptPaAdditionFlag
     ELSIF l_pa_add_flag_tbl(i) = 'J' THEN

            write_log(LOG,'pa_addition_flag for this RCV transaction has been marked to J');
               /* If the pa_addition_flag is J, that means we only need to pull in the NR tax portion*/

            IF l_entered_nr_tax_tbl(i) = 0 THEN

               l_insert_flag_tbl(i) := 'N';

            ELSE

               v_num_receipt_tax_processed := v_num_receipt_tax_processed + 1;

               l_record_type:= 'RECEIPT TAX';

               IF (l_dest_typ_code_tbl(i) = 'EXPENSE' AND l_trx_type_tbl(i) NOT IN ('RETURN TO RECEIVING','CORRECT')) THEN

                  l_denom_cost := l_entered_nr_tax_tbl(i);
                  l_acct_cost  := l_accounted_nr_tax_tbl(i);
                  l_quantity   := l_quantity_tbl(i);


               ELSIF ((l_dest_typ_code_tbl(i) = 'EXPENSE' AND l_trx_type_tbl(i)  IN ('CORRECT', 'RETURN TO RECEIVING')) OR
                       ( l_dest_typ_code_tbl(i) = 'RECEIVING'  AND l_trx_type_tbl(i) in('RETURN TO VENDOR',
                                                                                        'RETURN TO RECEIVING' ))) THEN
                      --
                      -- Check if the correction is a complete correction
                      --
                      DECLARE
                         l_primary_quantity     NUMBER;
                         l_amount               NUMBER;
                         l_exists               VARCHAR2(1):= 'N';    /*bug7168636*/
                      BEGIN

                            SELECT primary_quantity, amount
                              INTO l_primary_quantity, l_amount
                              FROM rcv_transactions
                             WHERE transaction_id = l_parent_rcv_id_tbl(i) ;

                                IF ((( ( l_quantity_tbl(i) <> 0 AND l_primary_quantity  = l_quantity_tbl(i)) OR
                                      ( l_amount = l_amount_tbl(i)))   AND
                                       (( l_dest_typ_code_tbl(i) = 'EXPENSE' AND l_trx_type_tbl(i) = 'RETURN TO RECEIVING') OR
                                        ( l_dest_typ_code_tbl(i) = 'RECEIVING'  AND l_trx_type_tbl(i) in('RETURN TO VENDOR',
                                                                                                         'RETURN TO RECEIVING' )))) OR
                                    ((  ( l_quantity_tbl(i) <> 0 AND l_primary_quantity  = -l_quantity_tbl(i)) OR
                                      ( l_amount = l_amount_tbl(i)))   AND
                                       (( l_dest_typ_code_tbl(i) = 'EXPENSE' AND l_trx_type_tbl(i) = 'CORRECT')))) THEN

                                  -- Check if the parent has been interfaced to Projects.
				  /*bug 7168636 handling no data found*/
				  BEGIN
                                     SELECT 'Y'
                                       INTO l_exists
                                       FROM dual
                                      WHERE EXISTS (
                                                   SELECT pa_addition_flag
                                                     FROM rcv_receiving_sub_ledger
                                                    WHERE rcv_transaction_id = l_parent_rcv_id_tbl(i)
                                                      AND pa_addition_flag in ('Y','I')) ;
                                   EXCEPTION
                                     WHEN NO_DATA_FOUND THEN
                                     NULL;
                                   END;

                                      IF l_exists = 'Y' THEN


                                         -- Call reversal API
                                         Process_Adjustments(p_record_type               => 'PO_RECEIPT_TAX',
                                            p_document_header_id  => l_po_head_id_tbl(i),/*Added this for 6945767 */
                                            p_document_distribution_id  => l_parent_rcv_id_tbl(i),
                                            p_current_index             => i,
                                            p_last_index                => j);

                                        -- Set the create flag for adjustment records
                                           IF l_insert_flag_tbl(i) = 'A' THEN
                                            l_create_adj_recs := 'Y';
                                           END IF;


                                      END IF;

                                END IF ; -- l_primary_quantity  = l_quantity
                            IF ( l_dest_typ_code_tbl(i) = 'RECEIVING'  OR l_trx_type_tbl(i) = 'RETURN TO RECEIVING' ) THEN
                              l_denom_cost := -l_entered_nr_tax_tbl(i);
                              l_acct_cost  := -l_accounted_nr_tax_tbl(i);
                              l_quantity   := -l_quantity_tbl(i);
                           ELSE
                              l_denom_cost := l_entered_nr_tax_tbl(i);
                              l_acct_cost  := l_accounted_nr_tax_tbl(i);
                              l_quantity   := l_quantity_tbl(i);
                           END IF;

                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                NULL;
                          WHEN OTHERS THEN
                               RAISE ;
                       END ;

                END IF;

               IF l_quantity = 0 THEN   /*for amount based POs setting the pa quantity to be the same as the transaction cost*/
                   l_quantity := l_denom_cost;
               END IF;

            END IF; /* tax column is zero */

         END IF; /* pa_add_flag O or J*/

         write_log(LOG, 'This is a record type of: '||l_record_type||
                        'denom cost for receipt amount:'||l_denom_cost||
                        'acct cost:'||l_acct_cost||'quantity is:'||l_quantity);

         l_exp_end_date_tbl(i)    := G_EXPENDITURE_ENDING_DATE;
         l_txn_status_code_tbl(i) := G_TRANSACTION_STATUS_CODE;
         l_txn_rej_code_tbl(i)    := G_TRANSACTION_REJECTION_CODE;

         l_record_type_tbl(i)     := l_record_type;
         l_denom_raw_cost_tbl(i)  := l_denom_cost;
         l_acct_raw_cost_tbl(i)   := l_acct_cost;

         IF l_exp_cst_rt_flg_tbl(i) = 'Y' THEN --Exp Cost Rate Required = Y, stamp the quantity. Bug#5138396.
            l_quantity_tbl(i)        := l_quantity;
         ELSE
            l_quantity_tbl(i)        := l_denom_cost;
         END IF;

         IF l_insert_flag_tbl(i) IS NULL THEN
            l_insert_flag_tbl(i)     := 'Y';
         END IF;

           -- FC Doc Type
            IF l_fc_enabled_tbl(i) = 'N' THEN
             l_fc_document_type_tbl(i) := 'NOT';
            END IF;

         write_log(LOG, 'The value for Insert Flag : '||l_insert_flag_tbl(i)  );

         IF (G_TRANS_DFF_PO = 'Y') THEN

                v_attribute_category := l_attribute_cat_tbl(i);
                v_attribute1 := l_attribute1_tbl(i);
                v_attribute2 := l_attribute2_tbl(i);
                v_attribute3 := l_attribute3_tbl(i);
                v_attribute4 := l_attribute4_tbl(i);
                v_attribute5 := l_attribute5_tbl(i);
                v_attribute6 := l_attribute6_tbl(i);
                v_attribute7 := l_attribute7_tbl(i);
                v_attribute8 := l_attribute8_tbl(i);
                v_attribute9 := l_attribute9_tbl(i);
                v_attribute10 := l_attribute10_tbl(i);

                v_dff_map_status := NULL;

                G_err_stage:='Calling PA_CLINET_EXTN_DFFTRANS to map DFF fields';
                write_log(LOG,   G_err_stage);

                PA_CLIENT_EXTN_DFFTRANS.DFF_map_segments_PA_and_AP(
                   p_calling_module            => 'PAAPIMP',
                   p_trx_ref_1                 => l_po_dist_id_tbl(i),
                   p_trx_ref_2                 => l_rcv_txn_id_tbl(i),
                   p_trx_type                  => l_dest_typ_code_tbl(i),
                   p_system_linkage_function   => 'VI',
                   p_submodule                 => NULL,
                   p_expenditure_type          => l_exp_type_tbl(i),
                   p_set_of_books_id           => G_PO_SOB,
                   p_org_id                    => l_org_id_tbl(i),
                   p_attribute_category        => v_attribute_category,
                   p_attribute_1               => v_attribute1,
                   p_attribute_2               => v_attribute2,
                   p_attribute_3               => v_attribute3,
                   p_attribute_4               => v_attribute4,
                   p_attribute_5               => v_attribute5,
                   p_attribute_6               => v_attribute6,
                   p_attribute_7               => v_attribute7,
                   p_attribute_8               => v_attribute8,
                   p_attribute_9               => v_attribute9,
                   p_attribute_10              => v_attribute10,
                   x_status_code               => v_dff_map_status);

                   IF (v_dff_map_status IS NOT NULL) THEN

                       G_err_stage := ('Error in DFF_map_segments_PA_and_AP, Error Code: ' || v_dff_map_status);
                       write_log(LOG,   G_err_stage);
                       raise dff_map_exception;

                   END IF;

                   l_attribute_cat_tbl(i) := v_attribute_category;
                   l_attribute1_tbl(i) := v_attribute1;
                   l_attribute2_tbl(i) := v_attribute2;
                   l_attribute3_tbl(i) := v_attribute3;
                   l_attribute4_tbl(i) := v_attribute4;
                   l_attribute5_tbl(i) := v_attribute5;
                   l_attribute6_tbl(i) := v_attribute6;
                   l_attribute7_tbl(i) := v_attribute7;
                   l_attribute8_tbl(i) := v_attribute8;
                   l_attribute9_tbl(i) := v_attribute9;
                   l_attribute10_tbl(i) := v_attribute10;

	   ElSE /* if DFF profile is No. Added for Bug 3105153*/
                   l_attribute_cat_tbl(i) := NULL;     --Bug#3856390
                   l_attribute1_tbl(i) := NULL;
                   l_attribute2_tbl(i) := NULL;
                   l_attribute3_tbl(i) := NULL;
                   l_attribute4_tbl(i) := NULL;
                   l_attribute5_tbl(i) := NULL;
                   l_attribute6_tbl(i) := NULL;
                   l_attribute7_tbl(i) := NULL;
                   l_attribute8_tbl(i) := NULL;
                   l_attribute9_tbl(i) := NULL;
                   l_attribute10_tbl(i) := NULL;

           END IF; /* if DFF profile is Yes */

      END LOOP; /* End of looping through each record in plsql table */

   -- Update to set all the transactions that got interfaced through AP to 'G'
    FORALL i IN  l_rcv_txn_id_tbl.FIRST..l_rcv_txn_id_tbl.LAST
         UPDATE rcv_receiving_sub_ledger rcv_sub
            SET rcv_sub.pa_addition_flag          = decode(l_pa_add_flag_tbl(i),'G','G',pa_addition_flag)
          WHERE rcv_sub.rcv_transaction_id        = l_rcv_txn_id_tbl(i)
            AND rcv_sub.pa_addition_flag = 'O'
            AND  l_insert_flag_tbl(i) = 'N' ;

   EXCEPTION
      WHEN OTHERS THEN
          write_log(LOG,'Failed during process_receipt_logic for receipt processing');
          G_err_code   := SQLCODE;
          raise;
   END process_receipt_logic;

   PROCEDURE process_receipt_tax_logic IS

     l_status4    VARCHAR2(10);
     l_evt_typ_name VARCHAR2(30); -- pricing changes
     j NUMBER := 0; --Index variable for creating reversal EI's --NEW

   BEGIN

      /* This procedure is only called after process_receipt_logic. ONLY the records
         with pa_addition_flag of 'O' AND the record type of receipt would be
         processed here. The reason for this is because when pa_addition_flag is updated
         to 'O', it means we need to split the receipt into the receipt amount and the tax
         amount. Since we call a bulk insert after calling  process_receipt_logic then
         it means the receipt without tax portion should have been inserted into the
         txn interface table. The only part that we should now process are the tax portion
         of these records. Thus, we will only process these records and nothing else */

      /* Additional Note: Most of the values already stored in the plsql table for these records
         can be reused except for the amount columns. Other columns like bus_group_id and DFF
         fields are the same for either the receipt amount or just the tax amount */

      G_err_stage:= 'Within process_receipt_logic';
      write_log(LOG,   G_err_stage);

      FOR i IN l_rcv_txn_id_tbl.FIRST..l_rcv_txn_id_tbl.LAST LOOP

         j := l_rcv_txn_id_tbl.LAST;  -- initialize j to the total rcv trans retrieved in the PLSQL array

         IF (l_pa_add_flag_tbl(i) = 'J' OR l_record_type_tbl(i) not in ('RECEIPT','RCVTAX')) THEN

            l_insert_flag_tbl(i) := 'N';

         ELSIF (l_pa_add_flag_tbl(i)       = 'O'       AND
                l_record_type_tbl(i)   = 'RECEIPT' AND
                l_entered_nr_tax_tbl(i) = 0
               ) THEN

                l_insert_flag_tbl(i) := 'N';

         ELSIF (l_pa_add_flag_tbl(i)       = 'O'       AND
                l_record_type_tbl(i)   = 'RECEIPT' AND
                l_entered_nr_tax_tbl(i) <> 0
               ) THEN

               v_num_receipt_tax_processed := v_num_receipt_tax_processed + 1;

               G_err_stage := 'Calling lock_ap_invoice within process_receipt_tax_logic';
               write_log(LOG,   G_err_stage);

               lock_ap_invoice(l_po_dist_id_tbl(i));

               l_record_type := 'RECEIPT TAX';

               l_insert_flag_tbl(i)     := 'Y';

               IF (l_dest_typ_code_tbl(i) = 'EXPENSE' AND l_trx_type_tbl(i) NOT IN ( 'RETURN TO RECEIVING','CORRECT')) THEN

                  l_denom_cost := l_entered_nr_tax_tbl(i);
                  l_acct_cost  := l_accounted_nr_tax_tbl(i);
                  l_quantity   := l_quantity_tbl(i);

               ELSIF ((l_dest_typ_code_tbl(i) = 'EXPENSE' AND l_trx_type_tbl(i)  IN ('CORRECT', 'RETURN TO RECEIVING')) OR
                       ( l_dest_typ_code_tbl(i) = 'RECEIVING'  AND l_trx_type_tbl(i) in('RETURN TO VENDOR',
                                                                                        'RETURN TO RECEIVING' ))) THEN
                      --
                      -- Check if the correction is a complete correction
                      --
                      DECLARE
                         l_primary_quantity     NUMBER;
                         l_amount               NUMBER;
                         l_exists               VARCHAR2(1);
                      BEGIN

                            SELECT primary_quantity, nvl(amount,0)
                              INTO l_primary_quantity, l_amount
                              FROM rcv_transactions
                             WHERE transaction_id = l_parent_rcv_id_tbl(i) ;

                                -- Added a new variable l_po_tax_qty_tbl which will store the original po qty since the l_quantity_tbl
                                -- variable gets overwritten by the raw cost

                                IF ((( ( l_quantity_tbl(i) <> 0 AND l_primary_quantity  = l_po_tax_qty_tbl(i)) OR --bug5465098
                                      ( l_amount = l_amount_tbl(i)))   AND
                                       (( l_dest_typ_code_tbl(i) = 'EXPENSE' AND l_trx_type_tbl(i) = 'RETURN TO RECEIVING') OR
                                        ( l_dest_typ_code_tbl(i) = 'RECEIVING'  AND l_trx_type_tbl(i) in('RETURN TO VENDOR',
                                                                                                         'RETURN TO RECEIVING' )))) OR
                                    ((  ( l_quantity_tbl(i) <> 0 AND l_primary_quantity  = -l_po_tax_qty_tbl(i)) OR
                                      ( l_amount = l_amount_tbl(i)))   AND
                                       (( l_dest_typ_code_tbl(i) = 'EXPENSE' AND l_trx_type_tbl(i) = 'CORRECT')))) THEN

                                  -- Check if the parent has been interfaced to Projects.

                                     SELECT 'Y'
                                       INTO l_exists
                                       FROM dual
                                      WHERE EXISTS (
                                                   SELECT pa_addition_flag
                                                     FROM rcv_receiving_sub_ledger
                                                    WHERE rcv_transaction_id = l_parent_rcv_id_tbl(i)
                                                      AND pa_addition_flag in ('Y','I')) ;

                   -- Should we call this api at all? This api processes the records
                    --  where the pa_addition_flag is 'O'- the ones that got processed in
                    --  process_receipt_logic api.
                                      IF l_exists = 'Y' THEN

                                        -- Set the parent record attributes for adjustment record to copy
		                        l_txn_src_tbl(i)         := G_RCVTAX_TRANSACTION_SOURCE;
                           		l_user_txn_src_tbl(i)    := G_RCVTAX_USER_TRX_SOURCE;
                                        l_batch_name_tbl(i)      := G_RCVTAX_BATCH_NAME;
                                        l_interface_id_tbl(i)    := G_RCVNRT_INTERFACE_ID;

                       -- This api call may not be necessary. Need to verify.
                                         -- Call reversal API
                         Process_Adjustments(p_record_type               => 'PO_RECEIPT_TAX',
                                             p_document_header_id  => l_po_head_id_tbl(i),/*Added this for 6945767 */
                                             p_document_distribution_id  => l_parent_rcv_id_tbl(i),
                                             p_current_index             => i,
                                             p_last_index                => j);

                                        -- Set the create flag for adjustment records
                                           IF l_insert_flag_tbl(i) = 'A' THEN
                                            l_create_adj_recs := 'Y';
                                           END IF;

                                      END IF ;
                                END IF ; -- primary_quantity  = l_quantity


                            IF ( l_dest_typ_code_tbl(i) = 'RECEIVING'  OR l_trx_type_tbl(i) = 'RETURN TO RECEIVING' ) THEN
                              l_denom_cost := -l_entered_nr_tax_tbl(i);
                              l_acct_cost  := -l_accounted_nr_tax_tbl(i);
                              l_quantity   := -l_quantity_tbl(i);
                           ELSE
                              l_denom_cost := l_entered_nr_tax_tbl(i);
                              l_acct_cost  := l_accounted_nr_tax_tbl(i);
                              l_quantity   := l_quantity_tbl(i);
                           END IF;

                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                NULL;

                          WHEN OTHERS THEN
                               RAISE ;
                       END ;

               END IF;

               IF l_quantity = 0 THEN   /* bug 3496492 */
                   l_quantity := l_denom_cost;
               END IF;

               write_log(LOG, 'This is a record type of: '||l_record_type||
                        'denom cost for receipt amount:'||l_denom_cost||
                        'acct cost:'||l_acct_cost||'quantity is:'||l_quantity);

               l_record_type_tbl(i)     := l_record_type;
               l_denom_raw_cost_tbl(i)  := l_denom_cost;
               l_acct_raw_cost_tbl(i)   := l_acct_cost;
               l_quantity_tbl(i)        := l_quantity;

               l_txn_status_code_tbl(i) := 'P';
               l_txn_rej_code_tbl(i)    := '';

-- pricing changes start
	       IF (l_rcv_acct_evt_id_tbl(i) is NULL) THEN    /* bug 3475571 */

		l_txn_src_tbl(i)         := G_RCVTAX_TRANSACTION_SOURCE;
		l_user_txn_src_tbl(i)    := G_RCVTAX_USER_TRX_SOURCE;
	       ELSE

		SELECT event_type_name
		INTO l_evt_typ_name
		FROM rcv_accounting_event_types rcv_acct_evt_typ, rcv_accounting_events rcv_acct_evts
		WHERE rcv_acct_evt_typ.event_type_id = rcv_acct_evts.event_type_id
		AND rcv_acct_evts.accounting_event_id = l_rcv_acct_evt_id_tbl(i);

		IF (l_evt_typ_name in ('ADJUST_DELIVER','ADJUST_RECEIVE')) THEN
			l_txn_src_tbl(i)         := G_RCVTAX_PRC_ADJ_TRX_SRC;
			l_user_txn_src_tbl(i)    := G_RCVTAX_PRC_ADJ_USER_TRX_SRC;
                        l_quantity               := 0;
                        l_quantity_tbl(i)        := l_quantity;
		ELSE
			l_txn_src_tbl(i)         := G_RCVTAX_TRANSACTION_SOURCE;
			l_user_txn_src_tbl(i)    := G_RCVTAX_USER_TRX_SOURCE;
		END IF;

	       END IF;
-- pricing changes end
               l_batch_name_tbl(i)      := G_RCVTAX_BATCH_NAME;
               l_interface_id_tbl(i)    := G_RCVNRT_INTERFACE_ID;

              -- FC Doc Type
               IF l_fc_enabled_tbl(i) = 'N' THEN
                l_fc_document_type_tbl(i) := 'NOT';
               END IF;

         END IF; /* pa_add_flag is O or J */

         IF l_exp_cst_rt_flg_tbl(i) = 'Y' THEN --Exp Cost Rate Required = Y, stamp the quantity. Bug#5138396.
            l_quantity_tbl(i)        := l_quantity;
         ELSE
            l_quantity_tbl(i)        := l_denom_cost;
         END IF;

      END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
          write_log(LOG,'Failed during process_receipt_tax_logic for receipt processing');
          G_err_code   := SQLCODE;
          raise;
   END process_receipt_tax_logic;

   BEGIN

      G_err_stage := 'Entering main logic of transfer_receipts_to_pa';
      write_log(LOG, G_err_stage);

      /*Call get_mrc_flag function to see if MRC is set up*/

      --G_DO_MRC_FLAG := get_mrc_flag();
      --write_log(LOG, '......Result of get_mrc_flag: ' || G_DO_MRC_FLAG);

      v_max_size := nvl(G_COMMIT_SIZE,200);

      G_err_stage:='Opening Receipt Cursor';
      write_log(LOG,   G_err_stage);

      G_RCV_TRANSACTION_SOURCE      := 'PO RECEIPT';
      G_RCV_USER_TRANSACTION_SOURCE := 'Oracle Purchasing Receipt Accruals';
      G_RCVTAX_TRANSACTION_SOURCE   := 'PO RECEIPT NRTAX';
      G_RCVTAX_USER_TRX_SOURCE      := 'Non-Recoverable Tax from Purchasing Receipts';

--pricing changes
      G_RCV_PRC_ADJ_TRX_SRC      := 'PO RECEIPT PRICE ADJ';
      G_RCV_PRC_ADJ_USER_TRX_SRC := 'Oracle Purchasing Receipt Accrual Price Adjustments';
      G_RCVTAX_PRC_ADJ_TRX_SRC   := 'PO RECEIPT NRTAX PRICE ADJ';
      G_RCVTAX_PRC_ADJ_USER_TRX_SRC      := 'Non-Recoverable Tax Price Adjustments from Purchasing Receipts';

      OPEN Rcv_Receipts_Cur;

      WHILE (v_all_done = 0) LOOP

         write_log(LOG,'Receipt cursor is opened. Looping through batches.');

         clear_plsql_tables;

         G_err_stage := 'CREATING NEW INTERFACE ID';
         write_log(LOG,   G_err_stage);
         SELECT pa_interface_id_s.nextval
           INTO G_RCV_INTERFACE_ID FROM dual;

         SELECT pa_interface_id_s.nextval
           INTO G_RCVNRT_INTERFACE_ID FROM dual;

         G_err_stage:='Fetching Receipts Cursor';
         write_log(LOG,   G_err_stage);

         FETCH Rcv_Receipts_cur BULK COLLECT INTO
               l_rcv_txn_id_tbl,
               l_po_dist_id_tbl,
               l_po_head_id_tbl,
               l_po_num_tbl,
               l_quantity_tbl,
               l_po_tax_qty_tbl,
               l_entered_dr_tbl,
               l_entered_cr_tbl,
               l_accounted_dr_tbl,
               l_accounted_cr_tbl,
               l_entered_nr_tax_tbl,
               l_accounted_nr_tax_tbl,
               l_denom_raw_cost_tbl,
               l_acct_raw_cost_tbl,
               l_record_type_tbl,
               l_dist_cc_id_tbl,
               l_denom_cur_code_tbl,
               l_acct_rate_date_tbl,
               l_acct_rate_type_tbl,
               l_acct_exch_rate_tbl,
               l_gl_date_tbl,
               l_dest_typ_code_tbl,
               l_pa_add_flag_tbl,
               l_trx_type_tbl,
               l_project_id_tbl,
               l_task_id_tbl,
               l_employee_id_tbl,
               l_exp_type_tbl,
               l_ei_date_tbl,
               l_vendor_id_tbl,
               l_exp_org_id_tbl,
               l_job_id_tbl,
               l_description_tbl,
               l_attribute_cat_tbl,
               l_attribute1_tbl,
               l_attribute2_tbl,
               l_attribute3_tbl,
               l_attribute4_tbl,
               l_attribute5_tbl,
               l_attribute6_tbl,
               l_attribute7_tbl,
               l_attribute8_tbl,
               l_attribute9_tbl,
               l_attribute10_tbl,
               l_org_id_tbl,
               l_cdl_sys_ref4_tbl,
               l_txn_src_tbl,
               l_user_txn_src_tbl,
               l_batch_name_tbl,
               l_interface_id_tbl,
               l_exp_end_date_tbl,
               l_txn_status_code_tbl,
               l_txn_rej_code_tbl,
               l_bus_grp_id_tbl,
               l_insert_flag_tbl,
	       l_rcv_acct_evt_id_tbl, -- pricing changes
	       l_rcv_acct_rec_tax_tbl,
	       l_rcv_ent_rec_tax_tbl,
               l_parent_rcv_id_tbl, --NEW
               l_net_zero_flag_tbl, -- NEW
               l_sc_xfer_code_tbl,
               l_amount_tbl,
               l_adj_exp_item_id_tbl,
               l_fc_enabled_tbl,
               l_mrc_exchange_date_tbl,
               l_fc_document_type_tbl,
               l_si_assts_add_flg_tbl,
               l_insert_flag_tbl,
               l_rcv_sub_ledger_id_tbl,
               l_exp_cst_rt_flg_tbl
         LIMIT v_max_size;

         IF l_rcv_txn_id_tbl.COUNT <> 0 THEN

           /*Start by processing the receipt minus tax records or just the tax record.
             Explanation:
             The Receipt Cursor picks up both records that have  pa_addition_flag updated
             to either 'O' or 'J'. for the ones updated 'O', it means we need to split up
             the record into receipt minus tax portion and just the tax portion. The call
             to process_receipt_logic will insert only the receipt total minus tax portion.
             For records updated to 'J', we will only pull the nr_tax portion and insert
             into transaction_interface_all table for processing */

             G_err_stage:='Begin processing just the receipt records';
             write_log(LOG,   G_err_stage);

             v_last_rcv_index := l_rcv_txn_id_tbl.LAST;

             process_receipt_logic;

             bulk_insert_trx_intf;

            /* The process_receipt_tax_logic applies only to those records that have been updated
             to 'O'. After having the total receipt amount minus tax being inserted into txn
             interface table, we need to insert the tax portion of these records by calling
             process_receipt_tax_logic. The records that have been updated to 'J' would not be
             processed here because the tax amount was taken cared of in proceess_receipt_logic
             above.
            */

            G_err_stage:='Begin processing receipt tax records';
            write_log(LOG,   G_err_stage);

            process_receipt_tax_logic;

            bulk_insert_trx_intf;

            IF v_total_num_receipts > 0 THEN

               IF v_num_receipts_processed > 0 THEN

                  G_err_stage:='Calling trx import for receipts with interface_id:  '||G_RCV_INTERFACE_ID;
                  write_log(LOG,   G_err_stage);

--pricing changes
-- calling import for both transaction sources

 		  trans_import(G_RCV_TRANSACTION_SOURCE, G_RCV_BATCH_NAME,
                               G_RCV_INTERFACE_ID, G_USER_ID);
		  trans_import(G_RCV_PRC_ADJ_TRX_SRC, G_RCV_BATCH_NAME,
                               G_RCV_INTERFACE_ID, G_USER_ID);


                  G_err_stage:='After trx import for receipts, check for failed receipts';
                  write_log(LOG,   G_err_stage);
                  check_failed_receipts(G_RCV_BATCH_NAME, G_RCV_INTERFACE_ID);

               END IF;

               IF v_num_receipt_tax_processed > 0 THEN

                  G_err_stage:='Calling trx import for receipt tax with interface_id:  '||G_RCVNRT_INTERFACE_ID;
                  write_log(LOG,   G_err_stage);
--pricing changes
-- calling import for both transaction sources

                  trans_import(G_RCVTAX_TRANSACTION_SOURCE, G_RCVTAX_BATCH_NAME,
                               G_RCVNRT_INTERFACE_ID,G_USER_ID);

                  trans_import(G_RCVTAX_PRC_ADJ_TRX_SRC, G_RCVTAX_BATCH_NAME,
                               G_RCVNRT_INTERFACE_ID,G_USER_ID);

               END IF;

               G_err_stage:='Calling tieback for receipts';
               write_log(LOG,   G_err_stage);
               tieback_rcv_Txn(G_RCV_TRANSACTION_SOURCE,G_RCV_BATCH_NAME,
                               G_RCV_INTERFACE_ID);
--pricing changes
-- calling tieback for both transaction sources
               tieback_rcv_Txn(G_RCV_PRC_ADJ_TRX_SRC,G_RCV_BATCH_NAME,
                               G_RCV_INTERFACE_ID);

               G_err_stage:='Calling tieback for receipt tax';
               write_log(LOG,   G_err_stage);

               tieback_RCV_Txn(G_RCVTAX_TRANSACTION_SOURCE, G_RCVTAX_BATCH_NAME,
                               G_RCVNRT_INTERFACE_ID);
--pricing changes
-- calling tieback for both transaction sources
               tieback_RCV_Txn(G_RCVTAX_PRC_ADJ_TRX_SRC, G_RCVTAX_BATCH_NAME,
                               G_RCVNRT_INTERFACE_ID);

               write_log(LOG, 'After tying back rcv tax, before calling COMMIT');

               tieback_locked_invoice;
               /** 3922679 removed intermediate commit
               COMMIT;
               3922679 End */

               G_NUM_BATCHES_PROCESSED := G_NUM_BATCHES_PROCESSED + 1;
               G_NUM_RCV_TXN_PROCESSED := G_NUM_RCV_TXN_PROCESSED + v_num_receipts_processed;
               G_NUM_RCVTAX_PROCESSED  := G_NUM_RCVTAX_PROCESSED  + v_num_receipt_tax_processed;

            END IF; /* v_totabl_num_receipts > 0 */

            clear_plsql_tables;

         ELSE

            G_err_stage := 'plsql table for receipts is empty. Exiting';
            write_log(LOG, G_err_stage);

            EXIT; /* Exit if l_rcv_txn_id_tbl.COUNT = 0 */

         END IF; /* l_rcv_txn_id_tbl.COUNT = 0 */

         v_total_num_receipts         := 0;
         v_num_receipts_processed     := 0;
         v_num_receipt_tax_processed  := 0;

         EXIT WHEN Rcv_Receipts_Cur%NOTFOUND;

      END LOOP; /* While v_all_done = 0 */

      G_err_stage := 'Closing Receipts cursor';
      write_log(LOG, G_err_stage);

      CLOSE Rcv_Receipts_cur;

EXCEPTION
    WHEN OTHERS THEN

         G_err_stack := v_old_stack;
         IF Rcv_Receipts_Cur%ISOPEN THEN
           CLOSE Rcv_Receipts_Cur;
         END IF ;

         G_err_code := SQLCODE;
         RAISE;

END transfer_receipts_to_pa;

PROCEDURE tieback_rcv_Txn (
   p_transaction_source IN pa_transaction_interface.transaction_source%TYPE,
   p_batch_name  IN pa_transaction_interface.batch_name%TYPE,
   p_interface_id IN pa_transaction_interface.interface_id%TYPE) IS

   l_pa_addflag             VARCHAR2(1):=NULL;
   l_rows_tiebacked         NUMBER :=0;

   l_sys_ref1_tbl           PA_PLSQL_DATATYPES.Char15TabTyp;
   l_sys_ref2_tbl           PA_PLSQL_DATATYPES.Char15TabTyp;
   l_sys_ref3_tbl           PA_PLSQL_DATATYPES.Char15TabTyp;
   l_sys_ref4_tbl           PA_PLSQL_DATATYPES.Char15TabTyp;
   l_txn_src_tbl            PA_PLSQL_DATATYPES.Char30TabTyp;
   l_batch_name_tbl         PA_PLSQL_DATATYPES.Char50TabTyp;
   l_interface_id_tbl       PA_PLSQL_DATATYPES.IdTabTyp;
   l_txn_status_code_tbl    PA_PLSQL_DATATYPES.Char2TabTyp;
   l_project_id_tbl            PA_PLSQL_DATATYPES.IdTabTyp;
   l_pa_addflag_tbl         PA_PLSQL_DATATYPES.CHAR1TabTyp;
   l_rcv_acct_evt_id_tbl        PA_PLSQL_DATATYPES.IdTabTyp; -- pricing changes
   l_dr_ccid_tbl		PA_PLSQL_DATATYPES.IdTabTyp; -- pricing changes

   CURSOR txn_intf_rec (p_txn_src       IN VARCHAR2,
                        p_batch_name    IN VARCHAR2,
                        p_interface_id  IN NUMBER) IS
      SELECT cdl_system_reference1
            ,cdl_system_reference2
            ,cdl_system_reference3
            ,cdl_system_reference4
            ,transaction_source
            ,batch_name
            ,interface_id
            ,transaction_status_code
            ,project_id
            ,l_pa_addflag
	    ,orig_exp_txn_reference2 -- pricing changes
	    ,dr_code_combination_id
        FROM pa_transaction_interface_all txnintf
       WHERE txnintf.transaction_source = p_txn_src
         AND txnintf.batch_name         = p_batch_name
         AND txnintf.interface_id       = p_interface_id;

  PROCEDURE clear_plsql_tables IS

      v_status   VARCHAR2(15);

   BEGIN

      G_err_stage:='Clearing PLSQL tables in RCV transactions tieback';
      write_log(LOG,   G_err_stage);

      l_sys_ref1_tbl.delete;
      l_sys_ref2_tbl.delete;
      l_sys_ref3_tbl.delete;
      l_sys_ref4_tbl.delete;
      l_txn_src_tbl.delete;
      l_batch_name_tbl.delete;
      l_interface_id_tbl.delete;
      l_txn_status_code_tbl.delete;
      l_project_id_tbl.delete;
      l_pa_addflag_tbl.delete;
      l_rcv_acct_evt_id_tbl.delete; -- pricing changes
      l_dr_ccid_tbl.delete;

   END clear_plsql_tables;

   PROCEDURE process_tieback IS

      v_status   VARCHAR2(15);

   BEGIN

      G_err_stage:='Within process_tieback of RCV Transactions tieback';
      write_log(LOG,   G_err_stage);

      FOR i IN l_sys_ref1_tbl.FIRST..l_sys_ref1_tbl.LAST LOOP

         /* If transaction import stamps the record to be 'A' then
            update pa_addition_flag of RCV transactions to 'Y'.
            If transaction import leaves the record to be 'P' then
            update pa_addition_flag of RCV transactions to 'N' or 'I'.
            If transaction import stamps the record to be 'R' then
            update pa_addition_flag of RCV transactions to 'N' or 'I'.*/

         write_log(LOG,'Tying back transaction ID: '||l_sys_ref4_tbl(i)||
                       'trc src:   '||l_txn_src_tbl(i));

         IF l_txn_src_tbl(i) IN ('PO RECEIPT', 'PO RECEIPT PRICE ADJ') THEN

            IF l_txn_status_code_tbl(i) = 'A' THEN
                  l_pa_addflag_tbl(i) := 'Y';
            ELSIF l_txn_status_code_tbl(i) = 'P' THEN
                  l_pa_addflag_tbl(i) :='N';
            ELSIF l_txn_status_code_tbl(i) = 'R' THEN
                  l_pa_addflag_tbl(i) := 'N';
            END IF;

         ELSIF l_txn_src_tbl(i) IN ('PO RECEIPT NRTAX', 'PO RECEIPT NRTAX PRICE ADJ') THEN

            /* Transaction status code of T is a newly added status to
               denote that the corresponding receipt has been processed
               in the same request but got rejected. Therefore, the pa
               addition_flag of the corresponding receipt should be
               updated to N. If the status code is R then it should be
               updated to I such that the program can pick it up in the
               next run and interface ONLY the tax portion */

            IF l_txn_status_code_tbl(i) = 'A' THEN
                  l_pa_addflag_tbl(i) := 'Y';
            ELSIF l_txn_status_code_tbl(i) = 'T' THEN
                  l_pa_addflag_tbl(i) :='N';
            ELSIF l_txn_status_code_tbl(i) = 'R' THEN
                  l_pa_addflag_tbl(i) := 'I';
            END IF;

        END IF; /* checking txn source to be PO RECEIPT, PO RECEIPT PRICE ADJ,
	         PO RECEIPT NRTAX, PO RECEIPT NRTAX PRICE ADJ */

      END LOOP;

   END process_tieback;

   PROCEDURE bulk_update_txn_intf IS

      v_status VARCHAR2(15);

   BEGIN

      G_err_stage:=('Within bulk update of RCV transactions tieback');
      write_log(LOG,   G_err_stage);

      FORALL i IN l_sys_ref1_tbl.FIRST..l_sys_ref1_tbl.LAST

      /* Code combination Id join is required so that the record whichw as earlier updated to X does nto get updated to Y */

         UPDATE rcv_receiving_sub_ledger rcv_sub -- pricing changes
            SET rcv_sub.pa_addition_flag              = l_pa_addflag_tbl(i)
          WHERE rcv_sub.rcv_transaction_id        = l_sys_ref4_tbl(i)
	  AND (rcv_sub.accounting_event_id = l_rcv_acct_evt_id_tbl(i) OR rcv_sub.accounting_event_id IS NULL)
	  AND rcv_sub.code_combination_id = l_dr_ccid_tbl(i)
           /* Start added for bug#6015451 */
	AND EXISTS
            (SELECT 1 from rcv_transactions rcv_txn WHERE
              rcv_txn.transaction_id = l_sys_ref4_tbl(i)
              AND ( (rcv_txn.destination_type_code = 'EXPENSE' AND
	            rcv_txn.transaction_type <> 'RETURN TO RECEIVING' AND rcv_sub.entered_dr is NOT NULL
	            ) OR
	          ((rcv_txn.destination_type_code = 'RECEIVING' OR
	           rcv_txn.transaction_type = 'RETURN TO RECEIVING') AND rcv_sub.entered_cr is NOT NULL
                  )
                 )
             );
		/* Ends added for bug#6015451 */


      l_rows_tiebacked := SQL%ROWCOUNT;
      write_log(LOG,'Number of RCV transactions tied back:  '||l_rows_tiebacked);

   EXCEPTION
      WHEN OTHERS THEN
         G_err_stage:= 'Failed during bulk update of RCV transactions tieback';
         write_log(LOG,   G_err_stage);
         G_err_code   := SQLCODE;
         raise;

   END bulk_update_txn_intf;

   BEGIN

      /* Main logic of tieback starts here */
      G_err_stage:='Within main logic of tieback';
      write_log(LOG,   G_err_stage);

      G_err_stage:='Opening txn_intf_rec';
      write_log(LOG,   G_err_stage);

      OPEN txn_intf_rec(p_transaction_source
                       ,p_batch_name
                       ,p_interface_id);

      G_err_stage:='Fetching txn_intf_rec';
      write_log(LOG,   G_err_stage);

      clear_plsql_tables;

      FETCH txn_intf_rec BULK COLLECT INTO
          l_sys_ref1_tbl
         ,l_sys_ref2_tbl
         ,l_sys_ref3_tbl
         ,l_sys_ref4_tbl
         ,l_txn_src_tbl
         ,l_batch_name_tbl
         ,l_interface_id_tbl
         ,l_txn_status_code_tbl
         ,l_project_id_tbl
         ,l_pa_addflag_tbl
	 ,l_rcv_acct_evt_id_tbl
	 ,l_dr_ccid_tbl;

      IF l_sys_ref1_tbl.COUNT <> 0 THEN

         process_tieback;

         bulk_update_txn_intf;

         clear_plsql_tables;

      END IF;

      CLOSE txn_intf_rec;

EXCEPTION

  WHEN OTHERS THEN
     PA_TRX_IMPORT.Upd_PktSts_Fatal(G_REQUEST_ID);
     G_err_code := SQLCODE;
     RAISE;

END tieback_rcv_Txn;

PROCEDURE check_failed_receipts (
   p_batch_name  IN pa_transaction_interface.batch_name%TYPE,
   p_interface_id IN pa_transaction_interface.interface_id%TYPE) IS

   v_num_receipts_failed NUMBER:=0;
   v_po_head_id   VARCHAR2(35);
   v_po_dist_id   VARCHAR2(35);
   v_txn_id       VARCHAR2(35);
   v_acct_evt_id  NUMBER; -- pricing changes

   CURSOR Failed_Rec (p_batch_name   IN VARCHAR2,
                      p_interface_id IN NUMBER) IS
      SELECT cdl_system_reference2
            ,cdl_system_reference3
            ,cdl_system_reference4
	    ,orig_exp_txn_reference2 -- pricing changes
       FROM pa_transaction_interface
      WHERE transaction_status_code = 'R'
        AND transaction_source      IN ('PO RECEIPT', 'PO RECEIPT PRICE ADJ')
        AND batch_name              = p_batch_name
        AND interface_id            = p_interface_id;

BEGIN

   G_err_stage := 'Within calling check_failed_receipts';
   write_log(LOG, G_err_stage);

   write_log(LOG,'Checking for failed receipts for batch_name:  '||p_batch_name
                 ||'interface id:  '||p_interface_id);

   OPEN Failed_Rec(p_batch_name
                  ,p_interface_id);

   LOOP

      FETCH Failed_Rec INTO v_po_head_id
                           ,v_po_dist_id
                           ,v_txn_id
			   ,v_acct_evt_id; -- pricing changes
      EXIT WHEN Failed_Rec%NOTFOUND;

      write_log(LOG,'Number of failed receipt fetched:  '||v_num_receipts_failed);

   /* Changed p_batch_name and p_interface_id to G_ globals.
      Cursor fetched the batch name and interface id for RECEIPT and not
      for NRTAX */

      write_log(LOG,'Batch Name and Interface Id is : '||G_RCVTAX_BATCH_NAME||'  '||G_UNIQUE_ID);

      UPDATE pa_transaction_interface_all
        SET transaction_status_code  = 'T'
        WHERE batch_name             =  G_RCVTAX_BATCH_NAME /* p_batch_name changed for #2912545 */
          AND interface_id           =  G_RCVNRT_INTERFACE_ID /* p_interface_id changed for #2912545 */
          AND transaction_source     = 'PO RECEIPT NRTAX' /* PO RECEIPT TAX. changed for #2912545 */
          AND cdl_system_reference2  = v_po_head_id
          AND cdl_system_reference3  = v_po_dist_id
          AND cdl_system_reference4  = v_txn_id;

-- pricing changes
      UPDATE pa_transaction_interface_all
        SET transaction_status_code  = 'T'
        WHERE batch_name             =  G_RCVTAX_BATCH_NAME /* p_batch_name changed for #2912545 */
          AND interface_id           =  G_RCVNRT_INTERFACE_ID /* p_interface_id changed for #2912545 */
          AND transaction_source     = 'PO RECEIPT NRTAX PRICE ADJ' /* PO RECEIPT TAX. changed for #2912545 */
          AND cdl_system_reference2  = v_po_head_id
          AND cdl_system_reference3  = v_po_dist_id
          AND cdl_system_reference4  = v_txn_id
	  AND orig_exp_txn_reference2 = v_acct_evt_id;

      v_num_receipts_failed := v_num_receipts_failed +  SQL%ROWCOUNT;

   END LOOP;

   write_log(LOG,'number of receipts failed: '||v_num_receipts_failed);

   CLOSE Failed_Rec;

EXCEPTION
  WHEN OTHERS THEN
     PA_TRX_IMPORT.Upd_PktSts_Fatal(G_REQUEST_ID);
     CLOSE Failed_Rec;
     G_err_code := SQLCODE;
     RAISE;

END check_failed_receipts;

PROCEDURE lock_ap_invoice (p_po_distribution_id IN ap_invoice_distributions.po_distribution_id%TYPE)  IS

  l_num_rows NUMBER;

BEGIN

   G_err_stage := 'Within calling lock_ap_invoice';
   write_log(LOG, G_err_stage);

    UPDATE ap_invoice_distributions_all dist
       SET dist.pa_addition_flag   = 'L'
     WHERE dist.po_distribution_id = p_po_distribution_id
       AND dist.pa_addition_flag   = 'N';

    l_num_rows := SQL%ROWCOUNT;

    write_log(LOG,'number of ap invoices locked:'||l_num_rows);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       NULL;

   WHEN OTHERS THEN

     PA_TRX_IMPORT.Upd_PktSts_Fatal(G_REQUEST_ID);
     G_err_code := SQLCODE;
     RAISE;
END lock_ap_invoice;

PROCEDURE tieback_locked_invoice IS

  l_num_rows NUMBER;

BEGIN

   G_err_stage := 'Within calling tieback_locked_invoice';
   write_log(LOG, G_err_stage);

   UPDATE ap_invoice_distributions_all dist
      SET dist.pa_addition_flag = 'N'
    WHERE dist.pa_addition_flag = 'L';

    l_num_rows := SQL%ROWCOUNT;

    write_log(LOG,'number of ap invoices unlocked:'||l_num_rows);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;

   WHEN OTHERS THEN

     PA_TRX_IMPORT.Upd_PktSts_Fatal(G_REQUEST_ID);
     G_err_code := SQLCODE;
     RAISE;
END tieback_locked_invoice;

/*==========================================================================*/
--The following section contains procedures for AP Invoice AMount Variance Processing

--Function that increments the W count, and returns the same flag back.

FUNCTION increment_W_count(W_flag IN VARCHAR2)
   RETURN VARCHAR2 IS
BEGIN
   G_NUM_AP_VARIANCE_MARKED_W := G_NUM_AP_VARIANCE_MARKED_W + 1;
   RETURN W_flag;
END;



PROCEDURE mark_inv_var_paflag IS

   v_num_empty_lines    NUMBER;

BEGIN

   G_err_stage:= 'Within mark_inv_var_paflag';
   write_log(LOG,   G_err_stage);

   G_err_stage:= 'Updating empty invoice amount varaince lines pa addtion flag to G or W';
   write_log(LOG,   G_err_stage);


   IF G_PROJECT_ID IS NOT NULL THEN

    --
    -- Update pa-addition-flag to 'G' for item and nrtax lines if the invoice is matched to PO/RCPT that is
    -- accrued-on-rcpt and the PO has never been interfaced as invoice, historically
    -- However, such Invoice lines that have amount variance will be marked as W so that these can be processed
    -- for relieving the variance commitment
    --
    -- In rel12, Receipt Accruals along with NRTAX will be interfaced into Projects only from Purchasing
    -- However Variance and other related costs like Freight/Misc will still be interfaced from Payables
    --
        If g_body_debug_mode = 'Y' Then
        write_log(LOG, 'Updating empty invoice variance lines pa addtion flag to G for a project');
        End if;

   UPDATE ap_invoice_distributions_all apdist
      SET apdist.pa_addition_flag = DECODE(NVL(apdist.amount_variance,0),0,'G',increment_W_count('W')),
          request_id = G_REQUEST_ID,
          last_update_date=SYSDATE,
          last_updated_by=G_USER_ID,
          last_update_login= G_USER_ID,
          program_id= G_PROG_ID,
          program_application_id= G_PROG_APPL_ID,
          program_update_date=SYSDATE
    WHERE rowid IN (
          SELECT dist.rowid
          FROM  ap_invoices inv, ap_invoice_distributions_all dist
          WHERE inv.invoice_id = dist.invoice_id
          AND  (dist.line_type_lookup_code in ('ITEM','ACCRUAL','RETROACCRUAL','NONREC_TAX')
                OR ( pa_nl_installed.is_nl_installed = 'Y'                 --EIB trackable items
                                 AND EXISTS (SELECT 'X'
                                              FROM  mtl_system_items si,
                                                    po_lines_all pol,
                                                    po_distributions_all po_dist1
                                              WHERE po_dist1.po_line_id = pol.po_line_id
                                              AND   po_dist1.po_distribution_id  = dist.po_distribution_id
                                              AND   si.inventory_item_id = pol.item_id
                                              AND   po_dist1.project_id IS NOT NULL
                                              AND   si.comms_nl_trackable_flag = 'Y'
					      AND   si.organization_id = po_dist1.org_id)
                          )
                 ) --Bug#5399352. Added this here to take care of IPV/TIPV records matched to EIB item PO.
          AND   NOT EXISTS (SELECT NULL
                                     FROM ap_invoice_distributions_all apdist2
                                    WHERE apdist2.pa_addition_flag   = 'Y'
                                      AND apdist2.po_distribution_id = dist.po_distribution_id
                                      AND apdist2.line_type_lookup_code = dist.line_type_lookup_code
                                      AND apdist2.line_type_lookup_code in ('ITEM','ACCRUAL','RETROACCRUAL','NONREC_TAX')
                           )
          AND  (  EXISTS (SELECT NULL
                              FROM ap_invoice_distributions_all apdist1,
                                   ap_invoices_all ap1                 /*Changes for bug 7650946 -- Start */
                             WHERE apdist1.pa_addition_flag   IN ('F', 'G')
                               AND ap1.invoice_id = apdist1.invoice_id	/*Added for bug 	7650946 */
                               AND apdist1.po_distribution_id  = dist.po_distribution_id
                                AND ap1.Invoice_Type_lookup_Code <> 'PREPAYMENT'
                               AND apdist1.Line_Type_Lookup_Code <> 'PREPAY'  /*Changes for bug 7650946 -- End */
                          )
                 OR EXISTS (  SELECT rcv_txn.po_distribution_id
                                FROM rcv_transactions rcv_txn
                                   , rcv_receiving_sub_ledger rcv_sub
                               WHERE rcv_txn.po_distribution_id      = dist.po_distribution_id
                                 AND rcv_sub.pa_addition_flag || '' IN ('Y','I')
                                 AND rcv_sub.rcv_transaction_id      = rcv_txn.transaction_id
                           )
                 OR EXISTS (  SELECT  PO.po_distribution_id
                                FROM  po_distributions PO
                               WHERE  PO.po_distribution_id = dist.po_distribution_id
                                 AND  nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'  -- bug 7192304, added nvl
                                 AND  PO.project_id  > 0
                                 AND  NVL(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
                                 AND  PO.accrue_on_receipt_flag= 'Y'
                           )
                )
          AND   inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
          AND   nvl(INV.source, 'xx' ) NOT IN
                 ('Oracle Project Accounting','PA_IC_INVOICES')
          AND   dist.pa_addition_flag = 'N'
          AND   dist.posted_flag = 'Y'
          AND   trunc(dist.accounting_date) <= trunc(nvl(G_GL_DATE,dist.Accounting_Date))
          AND   trunc(dist.Expenditure_Item_Date) <= trunc(NVL(G_TRANSACTION_DATE,dist.Expenditure_Item_Date))
          AND   dist.project_id = G_PROJECT_ID
          -- Process historical distributions for CAsh BAsed Accounting
          AND   (G_ACCTNG_METHOD = 'A' OR (G_ACCTNG_METHOD = 'C' AND dist.historical_flag = 'Y'))
          AND   NVL(dist.po_distribution_id,0) > 0 );

          write_log(LOG,'Number of inv amount variance lines marked to G:  '||to_char(SQL%ROWCOUNT));
          write_log(LOG,'Number of inv amount variance lines marked to W:  '||G_NUM_AP_VARIANCE_MARKED_W);

      /* If the Supplier Invoice is matched to period-end PO for Contingent worker labor fixed rate and the CWK timecard
         is to be processed as Labor cost, only non recoverable tax receipt lines, variances and other allocated costs should be
         pulled from Payables. The pa_addition_flag for such invoice ITEM distribution lines is updated to G to prevent
         further processing into Projects.
         However, if there is an amount variance on such invoice, it needs to be processed as W to releive variance commitment  */

           UPDATE ap_invoice_distributions_all apdist
           SET    apdist.pa_addition_flag = DECODE(NVL(apdist.amount_variance,0),0,'G',increment_W_count('W')),
                  request_id = G_REQUEST_ID,
                  last_update_date=SYSDATE,
                  last_updated_by=G_USER_ID,
                  last_update_login= G_USER_ID,
                  program_id= G_PROG_ID,
                  program_application_id= G_PROG_APPL_ID,
                  program_update_date=SYSDATE
           WHERE  rowid in (
                           SELECT dist.rowid
                           FROM  ap_invoices inv,
                                 po_distributions po,
                                 ap_invoice_distributions_all dist
                           WHERE inv.invoice_id = dist.invoice_id
                           AND   po.po_distribution_id = dist.po_distribution_id
        			       AND   nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'  -- bug 7192304, added nvl
                           AND   NVL(po.destination_type_code, 'EXPENSE') = 'EXPENSE'
                           AND   PA_PJC_CWK_UTILS.Is_cwk_tc_xface_allowed(nvl(dist.project_ID, 0))= 'Y'
                           AND   PA_PJC_CWK_UTILS.Is_rate_based_line(null,nvl(dist.po_distribution_id,0))= 'Y'
                           AND   dist.line_type_lookup_code in ( 'ITEM','ACCRUAL','RETROACCRUAL') --added accrual for historical data
                           AND   dist.pa_addition_flag = 'N'
                           AND   inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                           AND   nvl(INV.source, 'xx' ) NOT IN
                               ('Oracle Project Accounting','PA_IC_INVOICES','PA_COST_ADJUSTMENTS')
                           AND   dist.pa_addition_flag = 'N'
                           AND   dist.project_id > 0
                           AND   dist.posted_flag = 'Y'
                           AND   trunc(dist.accounting_date) <= trunc(nvl(G_GL_DATE,dist.Accounting_Date)) /* Added trunc for the bug 6623163 */
                           AND   trunc(dist.Expenditure_Item_Date) <= trunc(NVL(G_TRANSACTION_DATE,dist.Expenditure_Item_Date))/* Added trunc for the bug 6623163 */
                           AND   dist.project_id = G_PROJECT_ID
                           -- Process historical distributions for CAsh BAsed Accounting
                           AND   (G_ACCTNG_METHOD = 'A' OR (G_ACCTNG_METHOD = 'C' AND dist.historical_flag = 'Y'))
                           AND   inv.paid_on_behalf_employee_id is NULL
AND inv.source not  in ('CREDIT CARD','Both Pay') /* Added for bug 8977795 */ );

           write_log(LOG,'Number of inv amount variance lines for CWK marked to G:  '||to_char(SQL%ROWCOUNT));
           write_log(LOG,'Number of inv amount variance lines for CWK marked to W:  '||G_NUM_AP_VARIANCE_MARKED_W);

   Else  -- G_PROJECT_ID IS NULL

    --
    -- Update pa-addition-flag to 'G' for item and nrtax lines if the invoice is matched to PO/RCPT that is
    -- accrued-on-rcpt and the PO has never been interfaced as invoice, historically
    -- However, such Invoice lines that have amount variance will be marked as W so that these can be processed
    -- for relieving the variance commitment
    --
    -- In rel12, Receipt Accruals along with NRTAX will be interfaced into Projects only from Purchasing
    -- However Variance and other related costs like Freight/Misc will still be interfaced from Payables
    --

        If g_body_debug_mode = 'Y' Then
        write_log(LOG, 'Updating empty invoice variance lines pa addtion flag to G for all');
        End if;

   UPDATE ap_invoice_distributions_all apdist
      SET apdist.pa_addition_flag = DECODE(NVL(apdist.amount_variance,0),0,'G',increment_W_count('W')),
          request_id = G_REQUEST_ID,
          last_update_date=SYSDATE,
          last_updated_by=G_USER_ID,
          last_update_login= G_USER_ID,
          program_id= G_PROG_ID,
          program_application_id= G_PROG_APPL_ID,
          program_update_date=SYSDATE
    WHERE rowid IN (
          SELECT dist.rowid
          FROM  ap_invoices inv, ap_invoice_distributions_all dist
          WHERE inv.invoice_id = dist.invoice_id
          AND  ( dist.line_type_lookup_code in ('ITEM','ACCRUAL','RETROACCRUAL','NONREC_TAX')
                OR ( pa_nl_installed.is_nl_installed = 'Y'                 --EIB trackable items
                                 AND EXISTS (SELECT 'X'
                                              FROM  mtl_system_items si,
                                                    po_lines_all pol,
                                                    po_distributions_all po_dist1
                                              WHERE po_dist1.po_line_id = pol.po_line_id
                                              AND   po_dist1.po_distribution_id  = dist.po_distribution_id
                                              AND   si.inventory_item_id = pol.item_id
                                              AND   po_dist1.project_id IS NOT NULL
                                              AND   si.comms_nl_trackable_flag = 'Y'
					      AND   si.organization_id = po_dist1.org_id)
                          )
                 ) --Bug#5399352. Added this here to take care of IPV/TIPV records matched to EIB item PO.
          AND   NOT EXISTS (SELECT NULL
                                     FROM ap_invoice_distributions_all apdist2
                                    WHERE apdist2.pa_addition_flag   = 'Y'
                                      AND apdist2.po_distribution_id = dist.po_distribution_id
                                      AND apdist2.line_type_lookup_code in ('ITEM','ACCRUAL','RETROACCRUAL','NONREC_TAX')
                           )
          AND  (  EXISTS (SELECT NULL
                              FROM ap_invoice_distributions_all apdist1,
                                   ap_invoices_all ap1                   /*Changes for bug 7650946 -- Start */
                             WHERE apdist1.pa_addition_flag   IN ('F', 'G')
                               AND ap1.invoice_id = apdist1.invoice_id
                               AND apdist1.po_distribution_id  = dist.po_distribution_id
                                AND ap1.Invoice_Type_lookup_Code <> 'PREPAYMENT'
                               AND apdist1.Line_Type_Lookup_Code <> 'PREPAY'  /*Changes for bug 7650946 -- End */
                          )
                 OR EXISTS (  SELECT rcv_txn.po_distribution_id
                                FROM rcv_transactions rcv_txn
                                   , rcv_receiving_sub_ledger rcv_sub
                               WHERE rcv_txn.po_distribution_id      = dist.po_distribution_id
                                 AND rcv_sub.pa_addition_flag || '' IN ('Y','I')
                                 AND rcv_sub.rcv_transaction_id      = rcv_txn.transaction_id
                           )
                 OR EXISTS (  SELECT  PO.po_distribution_id
                                FROM  po_distributions PO
                               WHERE  PO.po_distribution_id = dist.po_distribution_id
                                 AND  nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'  -- bug 7192304, added nvl
                                 AND  PO.project_id  > 0
                                 AND  NVL(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
                                 AND  PO.accrue_on_receipt_flag= 'Y'
                           )
                )
          AND   inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
          AND   nvl(INV.source, 'xx' ) NOT IN
                 ('Oracle Project Accounting','PA_IC_INVOICES','PA_COST_ADJUSTMENTS')
          AND   dist.pa_addition_flag = 'N'
          AND   dist.posted_flag = 'Y'
          AND   trunc(dist.accounting_date) <= trunc(nvl(G_GL_DATE,dist.Accounting_Date))  /* Added trunc for the bug 6623163 */
          AND  trunc(dist.Expenditure_Item_Date) <= trunc(NVL(G_TRANSACTION_DATE,dist.Expenditure_Item_Date)) /* Added trunc for the bug 6623163 */
          AND   dist.project_id > 0
          -- Process historical distributions for CAsh BAsed Accounting
          AND   (G_ACCTNG_METHOD = 'A' OR (G_ACCTNG_METHOD = 'C' AND dist.historical_flag = 'Y'))
          AND   NVL(dist.po_distribution_id,0) > 0 );

          write_log(LOG,'Number of inv amount variance lines marked to G:  '||to_char(SQL%ROWCOUNT));
          write_log(LOG,'Number of inv amount variance lines marked to W:  '||G_NUM_AP_VARIANCE_MARKED_W);

      /* If the Supplier Invoice is matched to period-end PO for Contingent worker labor fixed rate and the CWK timecard
         is to be processed as Labor cost, only non recoverable tax receipt lines, variances and other allocated costs should be
         pulled from Payables. The pa_addition_flag for such invoice ITEM distribution lines is updated to G to prevent
         further processing into Projects.
         However, if there is an amount variance on such invoice, it needs to be processed as W to releive variance commitment  */

           UPDATE ap_invoice_distributions_all apdist
           SET    apdist.pa_addition_flag = DECODE(NVL(apdist.amount_variance,0),0,'G',increment_W_count('W')),
                  request_id = G_REQUEST_ID,
                  last_update_date=SYSDATE,
                  last_updated_by=G_USER_ID,
                  last_update_login= G_USER_ID,
                  program_id= G_PROG_ID,
                  program_application_id= G_PROG_APPL_ID,
                  program_update_date=SYSDATE
           WHERE  rowid in (
                           SELECT dist.rowid
                           FROM  ap_invoices inv,
                                 po_distributions po,
                                 ap_invoice_distributions_all dist
                           WHERE inv.invoice_id = dist.invoice_id
                           AND   po.po_distribution_id = dist.po_distribution_id
                           AND   NVL(po.destination_type_code, 'EXPENSE') = 'EXPENSE'
                           AND   nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'   -- bug 7192304, added nvl
                           AND   PA_PJC_CWK_UTILS.Is_cwk_tc_xface_allowed(nvl(dist.project_ID, 0))= 'Y'
                           AND   PA_PJC_CWK_UTILS.Is_rate_based_line(null,nvl(dist.po_distribution_id,0))= 'Y'
                           AND   dist.line_type_lookup_code in ( 'ITEM','ACCRUAL','RETROACCRUAL') --added accrual for historical data
                           AND   dist.pa_addition_flag = 'N'
                           AND   inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                           AND   nvl(INV.source, 'xx' ) NOT IN
                               ('Oracle Project Accounting','PA_IC_INVOICES','PA_COST_ADJUSTMENTS')
                           AND   dist.pa_addition_flag = 'N'
                           AND   dist.posted_flag = 'Y'
                           AND   trunc(dist.accounting_date) <= trunc(nvl(G_GL_DATE,dist.Accounting_Date)) /* Added trunc for the bug 6623163 */
                           AND   trunc(dist.Expenditure_Item_Date) <= trunc(NVL(G_TRANSACTION_DATE,dist.Expenditure_Item_Date)) /* Added trunc for the bug 6623163 */
                           AND   dist.project_id > 0
                           -- Process historical distributions for CAsh BAsed Accounting
                           AND   (G_ACCTNG_METHOD = 'A' OR (G_ACCTNG_METHOD = 'C' AND dist.historical_flag = 'Y'))
                           AND   inv.paid_on_behalf_employee_id is NULL
                           AND inv.source not  in ('CREDIT CARD','Both Pay') /* Added for bug 8977795 */);

           write_log(LOG,'Number of inv amount variance lines for CWK marked to G:  '||to_char(SQL%ROWCOUNT));
           write_log(LOG,'Number of inv amount variance lines for CWK marked to W:  '||G_NUM_AP_VARIANCE_MARKED_W);

   END IF; /* IF G_PROJECT_ID */

EXCEPTION
   WHEN Others THEN
      write_log(LOG,'Failed during mark_inv_var_paflag');
      G_err_code := SQLCODE;
      RAISE;

END mark_inv_var_paflag;

PROCEDURE transfer_inv_var_to_pa  IS

   v_num_invoices_fetched          NUMBER :=0;
   v_num_distributions_fetched     NUMBER :=0;
   v_prev_invoice_id               NUMBER := 0;
   v_old_stack                     VARCHAR2(630);
   v_err_message                   VARCHAR2(220);
   v_all_done                      NUMBER := 0;
   v_num_inv_variance_fetched      NUMBER :=0;

   v_status Number := 0;
   v_stage  Number :=0;
   v_business_group_id NUMBER := 0;
   v_attribute_category VARCHAR2(150);
   v_attribute1 VARCHAR2(150);
   v_attribute2 VARCHAR2(150);
   v_attribute3 VARCHAR2(150);
   v_attribute4 VARCHAR2(150);
   v_attribute5 VARCHAR2(150);
   v_attribute6 VARCHAR2(150);
   v_attribute7 VARCHAR2(150);
   v_attribute8 VARCHAR2(150);
   v_attribute9 VARCHAR2(150);
   v_attribute10 VARCHAR2(150);
   v_dff_map_status VARCHAR2(30);
   dff_map_exception EXCEPTION;

   v_last_inv_var_index         NUMBER := 0;
   v_max_size                   NUMBER := 0;
   l_prev_cr_ccid NUMBER;
   l_prev_dr_ccid NUMBER;
   l_prev_exp_item_id NUMBER:=0;
   l_create_adj_recs  VARCHAR2(1) := 'N';


   PROCEDURE clear_plsql_tables IS

       l_status1 VARCHAR2(30);

   BEGIN

       G_err_stage := 'within clear_plsql_tables of transfer_inv_var_to_pa';
       write_log(LOG, G_err_stage);

       l_invoice_id_tbl.delete;
       l_invoice_dist_id_tbl.delete;
       l_project_id_tbl.delete;
       l_task_id_tbl.delete;
       l_ln_type_lookup_tbl.delete;
       l_exp_type_tbl.delete;
       l_ei_date_tbl.delete;
       l_amount_tbl.delete;
       l_description_tbl.delete;
       l_dist_cc_id_tbl.delete;
       l_exp_org_id_tbl.delete;
       l_quantity_tbl.delete;
       l_gl_date_tbl.delete;
       l_attribute_cat_tbl.delete;
       l_attribute1_tbl.delete;
       l_attribute2_tbl.delete;
       l_attribute3_tbl.delete;
       l_attribute4_tbl.delete;
       l_attribute5_tbl.delete;
       l_attribute6_tbl.delete;
       l_attribute7_tbl.delete;
       l_attribute8_tbl.delete;
       l_attribute9_tbl.delete;
       l_attribute10_tbl.delete;
       l_denom_raw_cost_tbl.delete;
       l_denom_cur_code_tbl.delete;
       l_acct_rate_date_tbl.delete;
       l_acct_rate_type_tbl.delete;
       l_acct_exch_rate_tbl.delete;
       l_job_id_tbl.delete;
       l_employee_id_tbl.delete;
       l_vendor_id_tbl.delete;
       l_inv_type_code_tbl.delete;
       l_source_tbl.delete;
       l_org_id_tbl.delete;
       l_invoice_num_tbl.delete;
       l_cdl_sys_ref3_tbl.delete;
       l_cdl_sys_ref4_tbl.delete;
       l_txn_src_tbl.delete;
       l_user_txn_src_tbl.delete;
       l_batch_name_tbl.delete;
       l_interface_id_tbl.delete;
       l_exp_end_date_tbl.delete;
       l_txn_status_code_tbl.delete;
       l_txn_rej_code_tbl.delete;
       l_bus_grp_id_tbl.delete;
--       l_insert_flag_tbl.delete;
       l_reversal_flag_tbl.delete; --NEW
       l_net_zero_flag_tbl.delete; --NEW
       l_sc_xfer_code_tbl.delete; --NEW
       l_cancel_flag_tbl.delete;  --NEW
       l_parent_rev_id_tbl.delete; --NEW
       l_adj_exp_item_id_tbl.delete; --NEW
       l_fc_enabled_tbl.delete;
       l_fc_document_type_tbl.delete;

    END clear_plsql_tables;

    PROCEDURE bulk_insert_trx_intf IS

      l_status2 VARCHAR2(30);

    BEGIN

       FORALL i IN l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST

       INSERT INTO pa_transaction_interface_all(
                     transaction_source
                    , user_transaction_source
                    , system_linkage
                    , batch_name
                    , expenditure_ending_date
                    , expenditure_item_date
                    , expenditure_type
                    , quantity
                    , raw_cost_rate
                    , expenditure_comment
                    , transaction_status_code
                    , transaction_rejection_code
                    , orig_transaction_reference
                    , interface_id
                    , dr_code_combination_id
                    , cr_code_combination_id
                    , cdl_system_reference1
                    , cdl_system_reference2
                    , cdl_system_reference3
                    , cdl_system_reference4
                    , cdl_system_reference5 --NEW
                    , gl_date
                    , org_id
                    , unmatched_negative_txn_flag
                    , receipt_currency_amount
                    , receipt_currency_code
                    , receipt_exchange_rate
                    , denom_raw_cost
                    , denom_currency_code
                    , acct_rate_date
                    , acct_rate_type
                    , acct_exchange_rate
                    , acct_raw_cost
                    , acct_exchange_rounding_limit
                    , attribute_category
                    , attribute1
                    , attribute2
                    , attribute3
                    , attribute4
                    , attribute5
                    , attribute6
                    , attribute7
                    , attribute8
                    , attribute9
                    , attribute10
                    , orig_exp_txn_reference1
                    , orig_user_exp_txn_reference
                    ,  orig_exp_txn_reference2
                    ,  orig_exp_txn_reference3
                    , last_update_date
                    , last_updated_by
                    , creation_date
                    , created_by
                    , person_id
                    , organization_id
                    , project_id
                    , task_id
                    , Vendor_id
                    , override_to_organization_id
                    , person_business_group_id
                    , adjusted_expenditure_item_id --NEW
                    , fc_document_type  -- NEW
                    , sc_xfer_code
                    , si_assets_addition_flag
                    , net_zero_adjustment_flag
                    , expenditure_item_id
                   )
             SELECT l_txn_src_tbl(i)
                     ,l_user_txn_src_tbl(i)
                     ,G_SYSTEM_LINKAGE
                     ,l_batch_name_tbl(i)
                     ,l_exp_end_date_tbl(i)
                     ,l_ei_date_tbl(i)
                     ,l_exp_type_tbl(i)
                     ,l_quantity_tbl(i)
                     ,l_amount_tbl(i)/decode(nvl(l_quantity_tbl(i),0),0,1,l_quantity_tbl(i))
                     ,l_description_tbl(i)
                     ,l_txn_status_code_tbl(i)
                     ,l_txn_rej_code_tbl(i)
                     ,G_REQUEST_ID
                     ,l_interface_id_tbl(i)
                     ,l_dist_cc_id_tbl(i)
                     ,NULL
                     ,l_vendor_id_tbl(i)
                     ,l_invoice_id_tbl(i)
                     ,l_cdl_sys_ref3_tbl(i)
                     ,l_cdl_sys_ref4_tbl(i)
                     ,l_invoice_dist_id_tbl(i) --NEW
                     ,l_gl_date_tbl(i)
                     ,G_ORG_ID
                     ,'Y'
                     ,NULL
                     ,NULL
                     ,NULL
                     ,l_denom_raw_cost_tbl(i)
                     ,l_denom_cur_code_tbl(i)
                     ,l_acct_rate_date_tbl(i)
                     ,l_acct_rate_type_tbl(i)
                     ,l_acct_exch_rate_tbl(i)
                     ,l_amount_tbl(i)
                     ,1
                     ,l_attribute_cat_tbl(i)
                     ,l_attribute1_tbl(i)
                     ,l_attribute2_tbl(i)
                     ,l_attribute3_tbl(i)
                     ,l_attribute4_tbl(i)
                     ,l_attribute5_tbl(i)
                     ,l_attribute6_tbl(i)
                     ,l_attribute7_tbl(i)
                     ,l_attribute8_tbl(i)
                     ,l_attribute9_tbl(i)
                     ,l_attribute10_tbl(i)
                     ,l_invoice_id_tbl(i)        /*orig_exp_txn_reference1*/
                     ,l_invoice_num_tbl(i)       /*user_exp_txn_reference*/
                     ,NULL                       /*orig_exp_txn_reference2*/
                     ,NULL                       /*orig_exp_txn_reference3*/
                     ,SYSDATE
                     ,-1
                     ,SYSDATE
                     ,-1
                     ,l_employee_id_tbl(i)
                     ,l_org_id_tbl(i)
                     ,l_project_id_tbl(i)
                     ,l_task_id_tbl(i)
                     ,l_vendor_id_tbl(i)
                     ,l_exp_org_id_tbl(i)
                     ,l_bus_grp_id_tbl(i)
                     ,l_adj_exp_item_id_tbl(i) --NEW for reversals
                     ,l_fc_document_type_tbl(i) --NEW for funds checking
                     ,l_sc_xfer_code_tbl(i)
                     ,l_si_assts_add_flg_tbl(i)
                     ,l_net_zero_flag_tbl(i)
                     ,0 -- To relieve the cmt. It will not be interfaced from xface in trx imp.
                FROM dual;

              -- Insert the reversal of the reversed/cancelled distribution recs from AP.
    IF l_create_adj_recs = 'Y' THEN

        If g_body_debug_mode = 'Y' Then
                write_log(LOG, 'Inserting adjustment records..');
        End if;

                FORALL i IN l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST
       INSERT INTO pa_transaction_interface_all(
                     transaction_source
                    , user_transaction_source
                    , system_linkage
                    , batch_name
                    , expenditure_ending_date
                    , expenditure_item_date
                    , expenditure_type
                    , quantity
                    , raw_cost_rate
                    , expenditure_comment
                    , transaction_status_code
                    , transaction_rejection_code
                    , orig_transaction_reference
                    , interface_id
                    , dr_code_combination_id
                    , cr_code_combination_id
                    , cdl_system_reference1
                    , cdl_system_reference2
                    , cdl_system_reference3
                    , cdl_system_reference4
                    , cdl_system_reference5 --NEW
                    , gl_date
                    , org_id
                    , unmatched_negative_txn_flag
                    , receipt_currency_amount
                    , receipt_currency_code
                    , receipt_exchange_rate
                    , denom_raw_cost
                    , denom_currency_code
                    , acct_rate_date
                    , acct_rate_type
                    , acct_exchange_rate
                    , acct_raw_cost
                    , acct_exchange_rounding_limit
                    , attribute_category
                    , attribute1
                    , attribute2
                    , attribute3
                    , attribute4
                    , attribute5
                    , attribute6
                    , attribute7
                    , attribute8
                    , attribute9
                    , attribute10
                    , orig_exp_txn_reference1
                    , orig_user_exp_txn_reference
                    ,  orig_exp_txn_reference2
                    ,  orig_exp_txn_reference3
                    , last_update_date
                    , last_updated_by
                    , creation_date
                    , created_by
                    , person_id
                    , organization_id
                    , project_id
                    , task_id
                    , Vendor_id
                    , override_to_organization_id
                    , person_business_group_id
                    , adjusted_expenditure_item_id --NEW
                    , fc_document_type  -- NEW
                    , adjusted_txn_interface_id --NEW
                    , sc_xfer_code
                    , si_assets_addition_flag
                    , net_zero_adjustment_flag
                   )
             SELECT l_txn_src_tbl(i)
                     ,l_user_txn_src_tbl(i)
                     ,G_SYSTEM_LINKAGE
                     ,l_batch_name_tbl(i)
                     ,l_exp_end_date_tbl(i)
                     ,l_ei_date_tbl(i)
                     ,l_exp_type_tbl(i)
                     ,-l_quantity_tbl(i)
                     ,l_amount_tbl(i)/decode(nvl(l_quantity_tbl(i),0),0,1,l_quantity_tbl(i))
                     ,l_description_tbl(i)
                     ,l_txn_status_code_tbl(i)
                     ,l_txn_rej_code_tbl(i)
                     ,G_REQUEST_ID
                     ,l_interface_id_tbl(i)
                     ,l_dist_cc_id_tbl(i)
                     ,NULL
                     ,l_vendor_id_tbl(i)
                     ,l_invoice_id_tbl(i)
                     ,l_cdl_sys_ref3_tbl(i)
                     ,l_cdl_sys_ref4_tbl(i)
                     ,l_invoice_dist_id_tbl(i) --NEW
                     ,l_gl_date_tbl(i)
                     ,G_ORG_ID
                     ,'Y'
                     ,NULL
                     ,NULL
                     ,NULL
                     ,-l_denom_raw_cost_tbl(i)
                     ,l_denom_cur_code_tbl(i)
                     ,l_acct_rate_date_tbl(i)
                     ,l_acct_rate_type_tbl(i)
                     ,l_acct_exch_rate_tbl(i)
                     ,-l_amount_tbl(i)
                     ,1
                     ,l_attribute_cat_tbl(i)
                     ,l_attribute1_tbl(i)
                     ,l_attribute2_tbl(i)
                     ,l_attribute3_tbl(i)
                     ,l_attribute4_tbl(i)
                     ,l_attribute5_tbl(i)
                     ,l_attribute6_tbl(i)
                     ,l_attribute7_tbl(i)
                     ,l_attribute8_tbl(i)
                     ,l_attribute9_tbl(i)
                     ,l_attribute10_tbl(i)
                     ,l_invoice_id_tbl(i)        /*orig_exp_txn_reference1*/
                     ,l_invoice_num_tbl(i)       /*user_exp_txn_reference*/
                     ,NULL                       /*orig_exp_txn_reference2*/
                     ,NULL                       /*orig_exp_txn_reference3*/
                     ,SYSDATE
                     ,-1
                     ,SYSDATE
                     ,-1
                     ,l_employee_id_tbl(i)
                     ,l_org_id_tbl(i)
                     ,l_project_id_tbl(i)
                     ,l_task_id_tbl(i)
                     ,l_vendor_id_tbl(i)
                     ,l_exp_org_id_tbl(i)
                     ,l_bus_grp_id_tbl(i)
                     ,l_adj_exp_item_id_tbl(i) --NEW for reversals
                     ,l_fc_document_type_tbl(i) --NEW for funds checking
                     ,(select xface.txn_interface_id
                       from   pa_transaction_interface xface
                       where  xface.interface_id = l_interface_id_tbl(i)
                       and    xface.cdl_system_reference2 = l_invoice_id_tbl(i)
                       and    xface.cdl_system_reference5 = l_invoice_dist_id_tbl(i)
		       and    NVL(xface.adjusted_expenditure_item_id,0) =0 ) -- R12 funds management Uptake
                     ,'P' -- sc_xfer_code
                     ,l_si_assts_add_flg_tbl(i)
                     ,l_net_zero_flag_tbl(i)
                FROM dual
                WHERE l_insert_flag_tbl(i)= 'A';
                --WHERE l_net_zero_flag_tbl(i)= 'Y';
      END IF;

   EXCEPTION
      WHEN Others THEN
         write_log(LOG,'Failed during bulk insert of inv var processing');
         G_err_code := SQLCODE;
         RAISE;

   END bulk_insert_trx_intf;

   PROCEDURE process_inv_var_logic IS

       j   NUMBER := 0;
       l_status3 VARCHAR2(30);
       l_historical_flag VARCHAR(1);  --NEW

   BEGIN

       G_err_stage := ('Within Calling process logic of transfer_inv_var_to_pa');
       write_log(LOG, G_err_stage);

       j := v_last_inv_var_index ;
       FOR i IN  l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST  LOOP

           write_log(LOG,'Processing Invoice Variance for invoice id:  '||l_invoice_id_tbl(i)||
                         'Invoice Dist Id :  '||l_invoice_dist_id_tbl(i));

           G_TRANSACTION_REJECTION_CODE := '';

           /* The following will be executed if the distribution being fetched belongs to a new invoice */
           IF (l_invoice_id_tbl(i) <> v_prev_invoice_id) THEN

               G_err_stage := ('New invoice being processed.New invoice _id is:'||l_invoice_id_tbl(i));
               write_log(LOG, G_err_stage);

               /* Update the previous invoice id and vendor id*/
               v_prev_invoice_id := l_invoice_id_tbl(i);

               /* Increment the counter for invoices */
               v_num_invoices_fetched := v_num_invoices_fetched + 1;

                /* For new invoice, initialize the transaction status code to 'P' */
                G_TRANSACTION_STATUS_CODE := 'P';

                G_err_stage := 'GET MAX EXPENDITURE ENDING DATE';
                write_log(LOG, G_err_stage);
                SELECT pa_utils.getweekending(MAX(expenditure_item_date))
                  INTO G_EXPENDITURE_ENDING_DATE
                  FROM ap_invoice_distributions
                 WHERE invoice_id = l_invoice_id_tbl(i);

              If g_body_debug_mode = 'Y' Then
                G_err_stage := ('Getting bus group id');
                write_log(LOG, G_err_stage);
              End If;

                BEGIN


                    IF l_employee_id_tbl(i) <> 0 THEN
			Begin
			       SELECT emp.business_group_id
                                 INTO G_PER_BUS_GRP_ID
				 FROM per_all_people_f emp
				WHERE emp.person_id = l_employee_id_tbl(i)
				  AND l_ei_date_tbl(i) between trunc(emp.effective_start_date) and
							       trunc(emp.effective_end_date);

			EXCEPTION
			   WHEN NO_DATA_FOUND THEN
			      l_txn_status_code_tbl(i) := 'R';
			      G_TRANSACTION_REJECTION_CODE := 'INVALID_EMPLOYEE';
			      write_log(LOG, 'As no data found for Employee, Rejecting invoice'||l_invoice_id_tbl(i)  );
		        End;
		    Else
			Begin

			    select org2.business_group_id
                            into G_PER_BUS_GRP_ID
			      from hr_organization_units org1,
				   hr_organization_units org2
			     Where org1.organization_id = l_exp_org_id_tbl(i)
			       and org1.business_group_id = org2.organization_id;

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
				      G_TRANSACTION_STATUS_CODE := 'R';
				      G_TRANSACTION_REJECTION_CODE := 'INVALID_ORGANIZATION';
				      write_log(LOG, 'As no data found for Organization, Rejecting discount invoice ' || l_invoice_id_tbl(i) );
			End;
                    END IF; /* IF l_employee_id_tbl(i) <> 0 THEN  */
                END;

           END IF; /* end of check for different invoice_id from previous invoice_id */

           v_num_inv_variance_fetched  := v_num_inv_variance_fetched  + 1;
           v_num_distributions_fetched := v_num_distributions_fetched + 1;
           write_log(LOG,'Num of distributions fetched:'||v_num_distributions_fetched);

               --l_insert_flag_tbl(i)     := 'Y';


        If g_body_debug_mode = 'Y' Then
           write_log(LOG,'This is a record type of Amount Variance : ' ||
                     'denom cost is:  '||l_denom_raw_cost_tbl(i));
        End If;

           /*Setting values according to global variables*/
           l_bus_grp_id_tbl(i)      := G_PER_BUS_GRP_ID;
           l_exp_end_date_tbl(i)    := G_EXPENDITURE_ENDING_DATE;
           l_txn_rej_code_tbl(i)    := G_TRANSACTION_REJECTION_CODE;
           l_txn_status_code_tbl(i) := G_TRANSACTION_STATUS_CODE;

           l_txn_src_tbl(i)         := G_AP_VAR_TRANSACTION_SOURCE;
           l_user_txn_src_tbl(i)    := G_AP_VAR_USER_TXN_SOURCE;
           l_batch_name_tbl(i)      := G_AP_VAR_BATCH_NAME;
           l_interface_id_tbl(i)    := G_AP_VAR_INTERFACE_ID;

           -- FC Doc Type
            IF l_fc_enabled_tbl(i) = 'N' THEN
             l_fc_document_type_tbl(i) := 'NOT';
            END IF;

           -- REVERSED DISTRIBUTIONS INTERFACE LOGIC
           -- If the distribution is a reversal or cancellation then check if the parent reversal distribution
           -- was historical data or not. If so, reversal distribution line will be interfaced as is.
           -- However if the parent reversal distribution is not historical then the following steps happen:
           -- a) Retreive the latest adjusted expenditures from PA against the parent reversal distribution id
           -- b) If any of the above latest EI's are not costed, then the reversed distribution will be rejected by the
           --    TRX import program
           -- c) IF all above adjusted EI's are costed, then insert record into the interface table for each adjusted EI.
           --    The project attributes will be copied from the adjusted EI's instead from the AP reversed
           --    distribution since these could have changed in PA.
           -- d) The interface program will interface the reversed distribution into projects
           -- e) The interface program will also insert a reversal of the reversed distribution into Projects. This is
           --    required for account reconciliation
           --

           IF (l_reversal_flag_tbl(i) = 'Y' or l_cancel_flag_tbl(i) = 'Y') and l_parent_rev_id_tbl(i) is not null THEN

                BEGIN

                SELECT nvl(historical_flag,'N') --check if this flag can be used
                INTO   l_historical_flag
                FROM   ap_invoice_distributions_all
                WHERE  invoice_id = l_invoice_id_tbl(i)
                AND    invoice_distribution_id = l_parent_rev_id_tbl(i); --check the index on this table

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_txn_status_code_tbl(i) := 'R';
                   G_TRANSACTION_REJECTION_CODE := 'INVALID_INVOICE'; --?????????
                   write_log(LOG, 'As no data found for reversed parent distribution, Rejecting invoice dist Id'||l_invoice_dist_id_tbl(i));
                END;


                IF l_historical_flag = 'N' THEN

                     -- Call reversal API
                     Process_Adjustments(p_record_type               => 'AP_INVOICE',
                                         p_document_header_id  => l_invoice_id_tbl(i),/*Added this for 6945767 */
                                         p_document_distribution_id  => l_parent_rev_id_tbl(i),
                                         p_current_index             => i,
				         p_last_index                => j);

                      -- Set the create flag for adjustment records
                         IF l_insert_flag_tbl(i) in ('A','U') THEN
                          l_create_adj_recs := 'Y';
                         END IF;

                END IF; --End of check for historical Flag

           END IF; --End of check for reversal Distribution



      END LOOP; /* End of looping through each record in plsql table */

   EXCEPTION
      WHEN Others THEN
         write_log(LOG,'Failed during process_inv_var_logic of inv amt var processing');
         G_err_code := SQLCODE;
         RAISE;

   END process_inv_var_logic;

   BEGIN
   /* Main Procedure Logic starts here */

   G_err_stage := 'Within main procedure of transfer_inv_var_to_pa';
   write_log(LOG, G_err_stage);

     v_max_size := nvl(G_COMMIT_SIZE,200);

     G_AP_VAR_TRANSACTION_SOURCE  := 'AP VARIANCE';
     G_AP_VAR_USER_TXN_SOURCE     := 'Oracle Payables Invoice Variance';

     OPEN Invoice_Variance_Cur;

     G_err_stage := 'After opening Invoice_Variance_Cur within transfer_inv_var_to_pa';
     write_log(LOG, G_err_stage);

     WHILE (v_all_done = 0) LOOP

       clear_plsql_tables;

       --Creating new interface ID every time this is called
       G_err_stage := 'CREATING NEW INTERFACE ID';
       write_log(LOG, G_err_stage);

       SELECT pa_interface_id_s.nextval
         INTO G_AP_VAR_INTERFACE_ID
         FROM dual;

          FETCH Invoice_Variance_Cur BULK COLLECT INTO
             l_invoice_id_tbl
            ,l_invoice_dist_id_tbl --NEW
            ,l_cdl_sys_ref3_tbl --Invoice_lie_num
            ,l_project_id_tbl
            ,l_task_id_tbl
            ,l_ln_type_lookup_tbl
            ,l_exp_type_tbl
            ,l_ei_date_tbl
            ,l_amount_tbl
            ,l_description_tbl
            ,l_dist_cc_id_tbl
            ,l_exp_org_id_tbl
            ,l_quantity_tbl
            ,l_gl_date_tbl
            ,l_attribute_cat_tbl
            ,l_attribute1_tbl
            ,l_attribute2_tbl
            ,l_attribute3_tbl
            ,l_attribute4_tbl
            ,l_attribute5_tbl
            ,l_attribute6_tbl
            ,l_attribute7_tbl
            ,l_attribute8_tbl
            ,l_attribute9_tbl
            ,l_attribute10_tbl
            ,l_denom_raw_cost_tbl
            ,l_denom_cur_code_tbl
            ,l_acct_rate_date_tbl
            ,l_acct_rate_type_tbl
            ,l_acct_exch_rate_tbl
            ,l_job_id_tbl
            ,l_employee_id_tbl
            ,l_vendor_id_tbl
            ,l_inv_type_code_tbl
            ,l_source_tbl
            ,l_org_id_tbl
            ,l_invoice_num_tbl
            ,l_cdl_sys_ref4_tbl
            ,l_txn_src_tbl
            ,l_user_txn_src_tbl
            ,l_batch_name_tbl
            ,l_interface_id_tbl
            ,l_exp_end_date_tbl
            ,l_txn_status_code_tbl
            ,l_txn_rej_code_tbl
            ,l_bus_grp_id_tbl
            ,l_reversal_flag_tbl
            ,l_cancel_flag_tbl
            ,l_parent_rev_id_tbl
            ,l_net_zero_flag_tbl
            ,l_sc_xfer_code_tbl
            ,l_adj_exp_item_id_tbl
            ,l_fc_enabled_tbl
            ,l_mrc_exchange_date_tbl
            ,l_fc_document_type_tbl
            ,l_si_assts_add_flg_tbl
            ,l_insert_flag_tbl
            LIMIT v_max_size;

         G_err_stage := 'After fetching Cursor within transfer_inv_var_to_pa';
         write_log(LOG, G_err_stage);

         IF l_invoice_id_tbl.COUNT <> 0 THEN

            v_last_inv_var_index := l_invoice_id_tbl.LAST ;

            G_err_stage := 'calling process_inv_logic within transfer_inv_var_to_pa';
            write_log(LOG, G_err_stage);

            process_inv_var_logic;

            G_err_stage := 'calling bulk_insert_trx_intf within transfer_inv_var_to_pa';
            write_log(LOG, G_err_stage);

            bulk_insert_trx_intf;

           G_err_stage := 'Before calling transaction import and tiebacks within transfer_inv_var_to_pa';
           write_log(LOG, G_err_stage);


           IF (v_num_inv_variance_fetched > 0) THEN

              G_err_stage := 'Before calling transaction import and tiebacks within transfer_inv_var_to_pa';
              write_log(LOG, G_err_stage);

              trans_import(G_AP_VAR_TRANSACTION_SOURCE,G_AP_VAR_BATCH_NAME,
                           G_AP_VAR_INTERFACE_ID,G_USER_ID);
              tieback_invoice_variances(G_AP_VAR_TRANSACTION_SOURCE,G_AP_VAR_BATCH_NAME,
                           G_AP_VAR_INTERFACE_ID);

              G_err_stage := 'Before updating the total number of invoices processed';
              write_log(LOG, G_err_stage);

              G_NUM_BATCHES_PROCESSED       := G_NUM_BATCHES_PROCESSED + 1;
              G_NUM_INVOICES_PROCESSED      :=  G_NUM_INVOICES_PROCESSED + v_num_invoices_fetched;
              G_NUM_DISTRIBUTIONS_PROCESSED :=  G_NUM_DISTRIBUTIONS_PROCESSED + v_num_distributions_fetched;
              G_NUM_AP_VARIANCE_PROCESSED   := G_NUM_AP_VARIANCE_PROCESSED + v_num_inv_variance_fetched;

        END IF; /* IF (v_num_distributions_fetched > 0) */

        G_err_stage := 'After calling transaction import and tiebacks within transfer_inv_var_to_pa';
        write_log(LOG, G_err_stage);

        clear_plsql_tables;

        v_num_invoices_fetched       :=0;
        v_num_distributions_fetched  :=0;
        v_num_inv_variance_fetched   :=0;

        G_err_stage:='Before exiting when Invoice_Variance_Cur is NOTFOUND';
        write_log(LOG,   G_err_stage);

      ELSE
          EXIT;
      END IF; /* l_invoice_id_tbl.COUNT = 0 */

      EXIT WHEN Invoice_Variance_Cur%NOTFOUND;

   END LOOP; /* While more rows to process is true */

   CLOSE Invoice_Variance_Cur;

EXCEPTION
    WHEN OTHERS THEN

         G_err_stack := v_old_stack;
         IF Invoice_Variance_Cur%ISOPEN THEN
           CLOSE Invoice_Cur;
         END IF ;

         G_err_code := SQLCODE;
         RAISE;

END transfer_inv_var_to_pa;

PROCEDURE tieback_invoice_variances (
   p_transaction_source IN pa_transaction_interface.transaction_source%TYPE,
   p_batch_name  IN pa_transaction_interface.batch_name%TYPE,
   p_interface_id IN pa_transaction_interface.interface_id%TYPE) IS

   l_assets_addflag          VARCHAR2(1):=NULL;
   l_prev_assets_addflag     VARCHAR2(1):=NULL;
   l_project_id             NUMBER :=0;
   l_pa_addflag             VARCHAR2(1):=NULL;
   l_prev_proj_id           NUMBER :=0;

   l_sys_ref1_tbl           PA_PLSQL_DATATYPES.Char15TabTyp;
   l_sys_ref2_tbl           PA_PLSQL_DATATYPES.Char15TabTyp;
   l_sys_ref5_tbl           PA_PLSQL_DATATYPES.IdTabTyp;    --confirm if this is number type in interface table
   l_txn_src_tbl            PA_PLSQL_DATATYPES.Char30TabTyp;
   l_batch_name_tbl         PA_PLSQL_DATATYPES.Char50TabTyp;
   l_interface_id_tbl       PA_PLSQL_DATATYPES.IdTabTyp;
   l_txn_status_code_tbl    PA_PLSQL_DATATYPES.Char2TabTyp;
   l_project_id_tbl            PA_PLSQL_DATATYPES.IdTabTyp;
   l_pa_addflag_tbl         PA_PLSQL_DATATYPES.CHAR1TabTyp;
   l_assets_addflag_tbl     PA_PLSQL_DATATYPES.CHAR1TabTyp;
   l_exp_item_id_tbl        PA_PLSQL_DATATYPES.IdTabTyp; /* Bug 8709614  */

   CURSOR txn_intf_rec (p_txn_src       IN VARCHAR2,
                        p_batch_name    IN VARCHAR2,
                        p_interface_id  IN NUMBER) IS
      SELECT cdl_system_reference1
            ,cdl_system_reference2
            ,cdl_system_reference5
            ,transaction_source
            ,batch_name
            ,interface_id
            ,transaction_status_code
            ,project_id
            ,l_pa_addflag
            ,l_assets_addflag
	    ,expenditure_item_id /* Bug 8709614  */
        FROM pa_transaction_interface_all txnintf
       WHERE txnintf.transaction_source = p_txn_src
         AND txnintf.batch_name         = p_batch_name
         AND txnintf.interface_id       = p_interface_id;

   PROCEDURE clear_plsql_tables IS

      v_status   VARCHAR2(15);

   BEGIN

      G_err_stage:='Clearing PLSQL tables in invoice variance tieback';
      write_log(LOG,   G_err_stage);

      l_sys_ref1_tbl.delete;
      l_sys_ref2_tbl.delete;
      l_sys_ref5_tbl.delete;
      l_txn_src_tbl.delete;
      l_batch_name_tbl.delete;
      l_interface_id_tbl.delete;
      l_txn_status_code_tbl.delete;
      l_project_id_tbl.delete;
      l_pa_addflag_tbl.delete;
      l_assets_addflag_tbl.delete;
      l_exp_item_id_tbl.delete; /* Bug 8709614  */

   END clear_plsql_tables;

   PROCEDURE process_tieback IS

      v_status   VARCHAR2(15);

   BEGIN

      G_err_stage:='Within process_tieback of invoice variance tieback';
      write_log(LOG,   G_err_stage);

      FOR i IN l_sys_ref1_tbl.FIRST..l_sys_ref1_tbl.LAST LOOP

         /* If transaction import stamps the record to be 'A' then
            update pa_addition_flag of invoice distribution to 'F'.
            If transaction import leaves the record to be 'P' then
            update pa_addition_flag of invoice distribution to 'N'.
            If transaction import stamps the record to be 'R' then
            update pa_addition_flag of invoice distribution to 'N'.*/

         write_log(LOG,'Tying invoice_id: '||l_sys_ref2_tbl(i)||
                       -- 'dist num:  '||l_sys_ref3_tbl(i)||
                       -- 'sys ref 4: '||l_sys_ref4_tbl(i)||
                       'trc src:   '||l_txn_src_tbl(i));

         IF (l_txn_status_code_tbl(i) = 'A' OR l_exp_item_id_tbl(i) = 0) THEN /* Modified for bug 8709614  */
               l_pa_addflag_tbl(i) := 'F';
         ELSIF l_txn_status_code_tbl(i) = 'P' THEN
               l_pa_addflag_tbl(i) :='N';
         ELSIF l_txn_status_code_tbl(i) = 'R' THEN
               l_pa_addflag_tbl(i) := 'N';
         END IF;


         IF G_PROJECT_ID IS NOT NULL THEN

            IF G_Assets_Addition_flag = 'P' THEN
               l_assets_addflag_tbl(i) := 'P';
            ELSE
               l_assets_addflag_tbl(i) := 'X';
            END IF;

         ELSIF G_PROJECT_ID IS NULL THEN

            IF l_project_id_tbl(i) <> l_prev_proj_id THEN

               G_err_stage:='Selecting assets addition flag within invoice variance tieback';
               write_log(LOG,   G_err_stage);

               SELECT decode(PTYPE.Project_Type_Class_Code,'CAPITAL','P','X')
                 INTO l_assets_addflag_tbl(i)
                 FROM pa_project_types_all PTYPE,
                      pa_projects_all PROJ
                WHERE PTYPE.Project_Type = PROJ.Project_Type
                  AND (PTYPE.org_id = PROJ.org_id OR
                       PROJ.org_id is null)
                  AND PROJ.Project_Id = l_project_id_tbl(i);

                l_prev_proj_id := l_project_id_tbl(i);
		l_prev_assets_addflag := l_assets_addflag_tbl(i);      /* Bug 3626038 */

            ELSE
               l_assets_addflag_tbl(i) := l_prev_assets_addflag;
            END IF;

         END IF;

      END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
         G_err_stage:= 'Failed during process tieback of invoice variance tieback';
         write_log(LOG,   G_err_stage);
         G_err_code   := SQLCODE;
         raise;

   END process_tieback;

   PROCEDURE bulk_update_txn_intf IS

      v_status VARCHAR2(15);

   BEGIN

      G_err_stage:=('Within bulk update of invoice variance  tieback');
      write_log(LOG,   G_err_stage);

      FORALL i IN l_sys_ref1_tbl.FIRST..l_sys_ref1_tbl.LAST

         UPDATE ap_invoice_distributions_all dist
            SET dist.pa_addition_flag         = l_pa_addflag_tbl(i)
               ,dist.assets_addition_flag     = decode(l_assets_addflag_tbl(i),'P','P',dist.assets_addition_flag)
          WHERE dist.invoice_id               = l_sys_ref2_tbl(i)
            AND dist.invoice_distribution_id  = l_sys_ref5_tbl(i)
            AND dist.pa_addition_flag         = 'W';

   EXCEPTION
      WHEN OTHERS THEN
         G_err_stage:= 'Failed during bulk update of invoice variance tieback';
         write_log(LOG,   G_err_stage);
         G_err_code   := SQLCODE;
         raise;

   END bulk_update_txn_intf;

   BEGIN

      /* Main logic of tieback starts here */
      G_err_stage:='Within main logic of invoice variance tieback';
      write_log(LOG,   G_err_stage);

      clear_plsql_tables;

      G_err_stage:='Opening txn_intf_rec';
      write_log(LOG,   G_err_stage);

      OPEN txn_intf_rec(p_transaction_source
                       ,p_batch_name
                       ,p_interface_id);

      G_err_stage:='Fetching txn_intf_rec';
      write_log(LOG,   G_err_stage);

      FETCH txn_intf_rec BULK COLLECT INTO
          l_sys_ref1_tbl
         ,l_sys_ref2_tbl
         ,l_sys_ref5_tbl
         ,l_txn_src_tbl
         ,l_batch_name_tbl
         ,l_interface_id_tbl
         ,l_txn_status_code_tbl
         ,l_project_id_tbl
         ,l_pa_addflag_tbl
         ,l_assets_addflag_tbl
	 ,l_exp_item_id_tbl; /* Bug 8709614  */

      IF l_sys_ref1_tbl.COUNT <> 0 THEN

         process_tieback;

         bulk_update_txn_intf;

         clear_plsql_tables;

      END IF;

      CLOSE txn_intf_rec;

EXCEPTION
   WHEN OTHERS THEN

      IF txn_intf_rec%ISOPEN THEN
         CLOSE txn_intf_rec;
      END IF;

      G_err_stage:='Failed during tieback of invoice variances';
      write_log(LOG,   G_err_stage);

      G_err_code := SQLCODE;
      RAISE;

END tieback_invoice_variances;


PROCEDURE net_zero_pay_adjustment IS

   v_old_stack       	VARCHAR2(630);
   l_assets_add_flag 	VARCHAR2(1);
   l_num_dists_updated	NUMBER;

BEGIN

     v_old_stack := G_err_stack;
     G_err_stack := G_err_stack || '->PAAPIMP_PKG.net_zero_pay_adjustment';
     G_err_code := 0;
     G_err_stage := 'Updating the payments to Z if they sum up to zero';

     write_log(LOG, G_err_stage);
     write_log(LOG, G_err_stack);

     IF G_INVOICE_TYPE = 'EXPENSE REPORT' THEN

         -- Marking the expense reports to 'Z' if summing up to zero

         IF G_PROJECT_ID IS NOT NULL THEN

            -- This update is to mark the pa addition flag of all invoice distributions
            -- which have encumbered flag of 'R' or reversal flag of 'Y' to 'Z'.
            -- Encumbrance flag of 'R' or reversal flag of 'Y' indicates that they are
            -- exact reversal of another invoice distribution.
            -- If the invoice distribution has a encumbered flag value of 'R' then it is
            -- not encumbered and there exist no Budgetery control commitment records
            -- for these in PA

            UPDATE ap_payment_hist_dists dist
                SET dist.pa_addition_flag = 'Z',
                    request_id = G_REQUEST_ID,
                    last_update_date=SYSDATE,
                    last_updated_by= G_USER_ID,
                    last_update_login= G_USER_ID,
                    program_id= G_PROG_ID,
                    program_application_id= G_PROG_APPL_ID,
                    program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
               AND EXISTS (SELECT NULL
                           FROM   ap_payment_history_all hist
                           WHERE  hist.payment_history_id = dist.payment_history_id
                           AND    hist.posted_flag = 'Y')
               AND EXISTS (SELECT invoice_id
                             FROM AP_invoice_distributions aid
                            WHERE aid.invoice_distribution_id  = dist.invoice_distribution_id
                              AND aid.project_id = G_PROJECT_ID
                              AND ( nvl(aid.encumbered_flag,'N') = 'R' )) ;

            write_log(LOG, 'Number of distributions marked for encumbered net zero adjustment: ' || to_char(SQL%ROWCOUNT));

            ELSE   /* Project Id is not passed */

            -- This update is to mark the pa addition flag of all invoice distributions
            -- which have encumbered flag of 'R' or reversal flag of 'Y' to 'Z'.
            -- Encumbrance flag of 'R' or reversal flag of 'Y' indicates that they are
            -- exact reversal of another invoice distribution.
            -- If the invoice distribution has a encumbered flag value of 'R' then it is
            -- not encumbered and there exist no Budgetery control commitment records
            -- for these in PA


            UPDATE ap_payment_hist_dists dist
                SET dist.pa_addition_flag = 'Z',
                    request_id = G_REQUEST_ID,
                    last_update_date=SYSDATE,
                    last_updated_by= G_USER_ID,
                    last_update_login= G_USER_ID,
                    program_id= G_PROG_ID,
                    program_application_id= G_PROG_APPL_ID,
                    program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
               AND EXISTS (SELECT NULL
                           FROM   ap_payment_history_all hist
                           WHERE  hist.payment_history_id = dist.payment_history_id
                           AND    hist.posted_flag = 'Y')
               AND EXISTS (SELECT aid.invoice_id
                             FROM AP_invoice_distributions aid
                            WHERE aid.invoice_distribution_id  = dist.invoice_distribution_id
                              AND aid.project_id > 0
                              AND  nvl(aid.encumbered_flag,'N') = 'R' ) ;

            write_log(LOG, 'Number of distributions marked for encumbered net zero adjustment: ' || to_char(SQL%ROWCOUNT));

      END IF;
      --
      -- End of If section checking if G_PROJECT_ID is not null
      --

    ELSE

       -- Process Invoices

      IF G_PROJECT_ID IS NOT NULL THEN

        -- The program should update the pa_addition_flag for all encumbered lines marked as R to netzero adj flag.
        -- R indicates a line to be ignored by encumbrance and validation code because neither the original nor the
        -- reversal distributions were looked at and they offset each other so, they can be ignored and marked as Z.
        -- (This is set only if the parent one is not validated as well. Otherwise the reversal one will also be encumbered).
        -- Since these lines have been not encumbered, there exist no Budgetery control commitment records for these in PA

            UPDATE ap_payment_hist_dists dist
                SET dist.pa_addition_flag = 'Z',
                    request_id = G_REQUEST_ID,
                    last_update_date=SYSDATE,
                    last_updated_by= G_USER_ID,
                    last_update_login= G_USER_ID,
                    program_id= G_PROG_ID,
                    program_application_id= G_PROG_APPL_ID,
                    program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
               AND EXISTS (SELECT NULL
                           FROM   ap_payment_history_all hist
                           WHERE  hist.payment_history_id = dist.payment_history_id
                           AND    hist.posted_flag = 'Y')
               AND EXISTS (SELECT aid.invoice_id
                             FROM AP_invoice_distributions aid
                            WHERE aid.invoice_distribution_id  = dist.invoice_distribution_id
                              AND aid.project_id = G_PROJECT_ID
                              AND ( nvl(aid.encumbered_flag,'N') = 'R' )) ;

            write_log(LOG, 'Number of distributions marked for encumbered net zero adjustment: ' || to_char(SQL%ROWCOUNT));

     ELSE /* G_PROJECT_ID is null */

            -- This update is to mark the pa addition flag of all invoice distributions
            -- which have encumbered flag of 'R' or reversal flag of 'Y' to 'Z'.
            -- Encumbrance flag of 'R' or reversal flag of 'Y' indicates that they are
            -- exact reversal of another invoice distribution.
            -- If the invoice distribution has a encumbered flag value of 'R' then it is
            -- not encumbered and there exist no Budgetery control commitment records
            -- for these in PA

            UPDATE ap_payment_hist_dists dist
                SET dist.pa_addition_flag = 'Z',
                    request_id = G_REQUEST_ID,
                    last_update_date=SYSDATE,
                    last_updated_by= G_USER_ID,
                    last_update_login= G_USER_ID,
                    program_id= G_PROG_ID,
                    program_application_id= G_PROG_APPL_ID,
                    program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
               AND EXISTS (SELECT NULL
                           FROM   ap_payment_history_all hist
                           WHERE  hist.payment_history_id = dist.payment_history_id
                           AND    hist.posted_flag = 'Y')
               AND EXISTS (SELECT aid.invoice_id
                             FROM AP_invoice_distributions aid
                            WHERE aid.invoice_distribution_id  = dist.invoice_distribution_id
                              AND aid.project_id > 0
                              AND ( nvl(aid.encumbered_flag,'N') = 'R' )) ;

     write_log(LOG, 'Number of distributions marked for encumbered net zero adjustment: ' || to_char(SQL%ROWCOUNT));

     END IF;

     END IF;
     G_err_stack := v_old_stack;

EXCEPTION
        WHEN Others THEN
               /*
               --
               -- Exceptions occured in this procedure must be raised by the
               -- UPDATE statement, most likely a fatal error like 'rollback
               -- segment exceeded' error which should cause the program to
               -- terminate
               --
               */

	       G_err_stack := v_old_stack;
               G_err_code := SQLCODE;
	       raise;


END net_zero_pay_adjustment;

/*-----------------------Marking Distribution Phase---------------------*/

PROCEDURE mark_PA_Pay_flag_O IS

        v_old_stack VARCHAR2(630);

BEGIN

     v_old_stack := G_err_stack;
     G_err_stack := G_err_stack || '->PAAPIMP_PKG.mark_PA_Pay_flag_O';
     G_err_code := 0;
     G_err_stage := 'UPDATING PAYMENT DISTRIBUTIONS-Marking Process';

     write_log(LOG, G_err_stack);

     IF G_INVOICE_TYPE = 'EXPENSE REPORT' THEN
                   --
                   -- This section is for Expense Reports
                   --

          write_log(LOG, 'Marking Expense Report type invoices for processing...');
                   --
          IF G_PROJECT_ID IS NOT NULL THEN

            UPDATE ap_payment_hist_dists dist
                SET dist.pa_addition_flag = 'O',
                    request_id = G_REQUEST_ID,
                    last_update_date=SYSDATE,
                    last_updated_by= G_USER_ID,
                    last_update_login= G_USER_ID,
                    program_id= G_PROG_ID,
                    program_application_id= G_PROG_APPL_ID,
                    program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   dist.pay_dist_lookup_code = 'CASH'
            AND EXISTS (SELECT NULL
                        FROM   ap_payment_history_all hist
                        WHERE  hist.payment_history_id = dist.payment_history_id
                        AND    hist.posted_flag = 'Y')
            AND   exists (SELECT inv.invoice_id
                           FROM AP_INVOICES inv,
                                PO_VENDORS vend,
                                AP_Invoice_Distributions_all aid,
                                ap_invoice_payments_all aip
                          WHERE inv.invoice_id = aid.invoice_id
                            AND inv.vendor_id = vend.vendor_id
                            AND aip.invoice_payment_id = dist.invoice_payment_id
                            AND aid.invoice_distribution_id = dist.invoice_distribution_id
                            AND aid.pa_addition_flag  = 'N'                      --to avoid any historical data to be processed as Payments
                            AND nvl(aid.historical_flag,'N') = 'N'
                            AND aid.invoice_id = aip.invoice_id
                            AND aid.project_id = G_PROJECT_ID
                            AND trunc(aip.Accounting_Date) <= trunc(nvl(G_GL_DATE,aip.Accounting_Date))
                            AND trunc(aid.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,aid.expenditure_item_date)) /*GSCC*/
                            AND ((inv.invoice_type_lookup_code = G_INVOICE_TYPE
                                  AND inv.source IN (G_INVOICE_SOURCE1, G_INVOICE_SOURCE2,
                                      G_INVOICE_SOURCE3)
                                  AND (vend.employee_id IS NOT NULL or nvl(inv.paid_on_behalf_employee_id,0) > 0))
                                 OR
                                (inv.invoice_type_lookup_code   in ('STANDARD','CREDIT','MIXED') /*Bug# 3373933*/ /*Bug 4099522*/
                                 AND inv.source  in ('CREDIT CARD','Both Pay')
                                 AND nvl(inv.PAID_ON_BEHALF_EMPLOYEE_ID,0) > 0)));

        G_PAY_DISTRIBUTIONS_MARKED := SQL%ROWCOUNT;
        write_log(LOG, 'Number of Invoice - Payment rows marked to O: ' || to_char(SQL%ROWCOUNT));

        /* For Prepayment Application , we need to interface the prepay application lines created in ap_prepay_app_dists table*/

            UPDATE ap_prepay_app_dists dist
            SET    dist.pa_addition_flag = 'O',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   dist.amount <>0
            AND   exists(SELECT /*+ no_unnest */ inv.invoice_id
                           FROM AP_INVOICES_ALL inv,
                                PO_VENDORS vend,
                                PO_Distributions_all PO,
                                AP_Invoice_Distributions_all aid, --STD INV DIST LINE
                                AP_Invoice_Distributions_all aid2 -- PREPAY APPL DIST LINE
                          WHERE aid.invoice_id = inv.invoice_id
                            AND inv.vendor_id = vend.vendor_id
                            AND inv.org_id = G_ORG_ID
                            AND aid.invoice_distribution_id = dist.invoice_distribution_id  -- Std inv line
                            AND aid2.invoice_id = aid.invoice_id
                            AND aid2.invoice_distribution_id =  dist.prepay_app_distribution_id --Prepay appl line
                            --AND aid2.line_type_lookup_code in ( 'PREPAY', 'NONREC_TAX') -- bug#5514129
                            AND aid.line_type_lookup_code  <> 'REC_TAX' -- bug#5514129
                            and aid2.prepay_distribution_id is not null
                            AND aid2.pa_addition_flag  in ( 'N','E')         --to avoid any historical data to be processed as Payments
                             -- pa-addition-flag E to pull in rec tax across which prepay appl is prorated
                            AND aid2.posted_flag = 'Y'
                            AND aid.project_id = G_PROJECT_ID
                            AND trunc(aid2.Accounting_Date) <= trunc(nvl(G_GL_DATE,aid2.Accounting_Date))
                            AND trunc(aid.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,aid.expenditure_item_date))
                            AND ((inv.invoice_type_lookup_code = G_INVOICE_TYPE
                                  AND inv.source IN (G_INVOICE_SOURCE1, G_INVOICE_SOURCE2, G_INVOICE_SOURCE3)
                                  AND (vend.employee_id IS NOT NULL or nvl(inv.paid_on_behalf_employee_id,0) > 0))
                                 OR
                                (inv.invoice_type_lookup_code   in ('STANDARD','CREDIT','MIXED') /*Bug# 3373933*/ /*Bug 4099522*/
                                 AND inv.source in ('CREDIT CARD','Both Pay')
                                 AND nvl(inv.PAID_ON_BEHALF_EMPLOYEE_ID,0) > 0)));

          G_PAY_DISTRIBUTIONS_MARKED := nvl(G_PAY_DISTRIBUTIONS_MARKED,0) + SQL%ROWCOUNT;
          write_log(LOG, 'Number of Prepayment Application Dist rows marked to O: ' || to_char(SQL%ROWCOUNT));

      ELSE /* G_PROJECT_ID IS NULL */


            UPDATE ap_payment_hist_dists dist
                SET dist.pa_addition_flag = 'O',
                    request_id = G_REQUEST_ID,
                    last_update_date=SYSDATE,
                    last_updated_by= G_USER_ID,
                    last_update_login= G_USER_ID,
                    program_id= G_PROG_ID,
                    program_application_id= G_PROG_APPL_ID,
                    program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   dist.pay_dist_lookup_code = 'CASH'
            AND EXISTS (SELECT NULL
                        FROM   ap_payment_history_all hist
                        WHERE  hist.payment_history_id = dist.payment_history_id
                        AND    hist.posted_flag = 'Y')
            AND  exists (SELECT inv.invoice_id
                           FROM AP_INVOICES_ALL inv,
                                PO_VENDORS vend,
                                AP_Invoice_Distributions_all aid,
                                ap_invoice_payments_all aip
                          WHERE inv.vendor_id = vend.vendor_id
                            AND aid.invoice_id = inv.invoice_id
                            AND inv.org_id = G_ORG_ID
                            AND aip.invoice_payment_id = dist.invoice_payment_id
                            AND aid.invoice_distribution_id = dist.invoice_distribution_id
                            AND aid.invoice_id = aip.invoice_id
                            AND aid.project_id > 0
                            AND aid.pa_addition_flag  = 'N'                      --to avoid any historical data to be processed as Payments
                            AND nvl(aid.historical_flag,'N') = 'N'
                            AND trunc(aip.Accounting_Date) <= trunc(nvl(G_GL_DATE,aip.Accounting_Date))
                            AND trunc(aid.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,aid.expenditure_item_date)) /*GSCC*/
                            AND ((inv.invoice_type_lookup_code = G_INVOICE_TYPE
                                  AND inv.source IN (G_INVOICE_SOURCE1, G_INVOICE_SOURCE2,
                                      G_INVOICE_SOURCE3)
                                  AND (vend.employee_id IS NOT NULL or nvl(inv.paid_on_behalf_employee_id,0) > 0))
                                 OR
                                (inv.invoice_type_lookup_code   in ('STANDARD','CREDIT','MIXED') /*Bug# 3373933*/ /*Bug 4099522*/
                                 AND inv.source  in ('CREDIT CARD','Both Pay')
                                 AND nvl(inv.PAID_ON_BEHALF_EMPLOYEE_ID,0) > 0)));

        G_PAY_DISTRIBUTIONS_MARKED :=  SQL%ROWCOUNT;
        write_log(LOG, 'Number of Invoice - Payment rows marked to O: ' || to_char(SQL%ROWCOUNT));

        /* For Prepayment Application , we need to interface the prepay application lines created in ap_prepay_app_dists table*/

            UPDATE ap_prepay_app_dists dist
            SET    dist.pa_addition_flag = 'O',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   dist.amount <>0
            AND   exists(SELECT /*+ no_unnest */ inv.invoice_id
                           FROM AP_INVOICES_ALL inv,
                                PO_VENDORS vend,
                                PO_Distributions_all PO,
                                AP_Invoice_Distributions_all aid, --STD INV DIST LINE
                                AP_Invoice_Distributions_all aid2 -- PREPAY APPL DIST LINE
                          WHERE aid.invoice_id = inv.invoice_id
                            AND inv.vendor_id = vend.vendor_id
                            AND inv.org_id = G_ORG_ID
                            AND aid.invoice_distribution_id = dist.invoice_distribution_id  -- Std inv line
                            AND aid2.invoice_id = aid.invoice_id
                            AND aid2.invoice_distribution_id =  dist.prepay_app_distribution_id --Prepay appl line
                            --AND aid2.line_type_lookup_code in ( 'PREPAY', 'NONREC_TAX') -- bug#5514129
                            AND aid.line_type_lookup_code  <> 'REC_TAX' -- bug#5514129
                            AND aid2.pa_addition_flag  in ( 'N','E')         --to avoid any historical data to be processed as Payments
                             -- pa-addition-flag E to pull in rec tax across which prepay appl is prorated
                            and aid2.prepay_distribution_id is not null
                            AND aid2.posted_flag = 'Y'
                            AND aid.project_id > 0
                            AND trunc(aid2.Accounting_Date) <= trunc(nvl(G_GL_DATE,aid2.Accounting_Date))
                            AND trunc(aid.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,aid.expenditure_item_date))
                            AND ((inv.invoice_type_lookup_code = G_INVOICE_TYPE
                                  AND inv.source IN (G_INVOICE_SOURCE1, G_INVOICE_SOURCE2, G_INVOICE_SOURCE3)
                                  AND (vend.employee_id IS NOT NULL or nvl(inv.paid_on_behalf_employee_id,0) > 0))
                                 OR
                                (inv.invoice_type_lookup_code   in ('STANDARD','CREDIT','MIXED') /*Bug# 3373933*/ /*Bug 4099522*/
                                 AND inv.source  in ('CREDIT CARD','Both Pay')
                                 AND nvl(inv.PAID_ON_BEHALF_EMPLOYEE_ID,0) > 0)));

          G_PAY_DISTRIBUTIONS_MARKED := nvl(G_PAY_DISTRIBUTIONS_MARKED,0) + SQL%ROWCOUNT;
          write_log(LOG, 'Number of Prepayment Application Dist rows marked to O: ' || to_char(SQL%ROWCOUNT));

        END IF; /* END IF Project ID */

     ELSE

	   write_log(LOG, 'Marking Payments - supplier invoices for processing...');

             --
             -- Due to performance reasons the single update statement was
             -- broken up into two update statements based on if the program
             -- has the value of project id (If the user has given project number
             -- as one of the parameters).
             --

            IF G_PROJECT_ID IS NOT NULL THEN

          -- Update pa-addition-flag to O for all valid ap distributions that should be interfaced to Projects

            UPDATE ap_payment_hist_dists dist
            SET    dist.pa_addition_flag = 'O',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   dist.pay_dist_lookup_code = 'CASH'
            AND EXISTS (SELECT NULL
                        FROM   ap_payment_history_all hist
                        WHERE  hist.payment_history_id = dist.payment_history_id
                        AND    hist.posted_flag = 'Y')
            AND   exists(SELECT /*+ no_unnest */ inv.invoice_id
                           FROM AP_INVOICES_ALL inv,
                                PO_Distributions_all PO,
                                AP_Invoice_Distributions_all aid,
                                ap_invoice_payments_all aip
                          WHERE inv.invoice_id = aip.invoice_id
                            AND aid.invoice_id = inv.invoice_id
                            AND inv.org_id = G_ORG_ID
                            AND aip.invoice_payment_id = dist.invoice_payment_id
                            AND aid.invoice_distribution_id = dist.invoice_distribution_id
                            AND aid.line_type_lookup_code <> 'TERV'             -- Bug#5441030 to avoid zero dollar lines for TERV
                            AND aid.invoice_id = aip.invoice_id
                            AND aid.pa_addition_flag  = 'N'                      --to avoid any historical data to be processed as Payments
                            AND nvl(aid.historical_flag,'N') = 'N'
                            AND aid.po_distribution_id = PO.po_distribution_id (+)
                            AND nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'
                            AND inv.paid_on_behalf_employee_id IS NULL
                            AND NVL(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
                            AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                            AND  nvl(INV.source, 'xx' ) NOT IN ('Oracle Project Accounting', 'PA_IC_INVOICES')
                            AND aid.project_id = G_PROJECT_ID
                            AND aid.line_type_lookup_code <> 'REC_TAX'
                            AND (((
                               PA_PJC_CWK_UTILS.Is_cwk_tc_xface_allowed(nvl(aid.project_ID, 0))= 'N'
                               OR
                               PA_PJC_CWK_UTILS.Is_rate_based_line(null,nvl(aid.po_distribution_id,0))= 'N' )
                            AND aid.line_type_lookup_code IN ('ITEM','ACCRUAL','RETROACCRUAL')) OR
                            (aid.line_type_lookup_code NOT IN ('ITEM','ACCRUAL','RETROACCRUAL')))
                            AND trunc(aip.Accounting_Date) <= trunc(nvl(G_GL_DATE,aip.Accounting_Date))
                            AND trunc(aid.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,aid.expenditure_item_date)));

          G_PAY_DISTRIBUTIONS_MARKED :=  SQL%ROWCOUNT;
        write_log(LOG, 'Number of Invoice - Payment rows marked to O: ' || to_char(SQL%ROWCOUNT));

        /* For Prepayment Application , we need to interface the prepay application lines created in ap_prepay_app_dists table*/

            UPDATE ap_prepay_app_dists dist
            SET    dist.pa_addition_flag = 'O',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   dist.amount <> 0
            AND   exists(SELECT /*+ no_unnest */ inv.invoice_id
                           FROM AP_INVOICES_ALL inv,
                                PO_Distributions_all PO,
                                AP_Invoice_Distributions_all aid, --STD INV DIST LINE
                                AP_Invoice_Distributions_all aid2 -- PREPAY APPL DIST LINE
                          WHERE aid.invoice_id = inv.invoice_id
                            AND aid.invoice_distribution_id = dist.invoice_distribution_id  -- Std inv line
                            AND inv.org_id = G_ORG_ID
                            AND aid2.invoice_id = aid.invoice_id
                            AND aid2.invoice_distribution_id =  dist.prepay_app_distribution_id --Prepay appl line
                            --AND aid2.line_type_lookup_code in ( 'PREPAY', 'NONREC_TAX') -- bug#5514129
                            AND aid.line_type_lookup_code  <> 'REC_TAX' -- bug#5514129
                            AND aid2.pa_addition_flag  in ( 'N','E')         --to avoid any historical data to be processed as Payments
                             -- pa-addition-flag E to pull in rec tax across which prepay appl is prorated
                            and aid2.prepay_distribution_id is not null
                            AND aid2.posted_flag = 'Y'
                            AND aid.po_distribution_id = PO.po_distribution_id (+)
                            AND nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'
                            AND inv.paid_on_behalf_employee_id IS NULL
                            AND NVL(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
                            AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                            AND  nvl(INV.source, 'xx' ) NOT IN ('Oracle Project Accounting', 'PA_IC_INVOICES')
                            AND aid.project_id = G_PROJECT_ID
                            AND (((
                               PA_PJC_CWK_UTILS.Is_cwk_tc_xface_allowed(nvl(aid.project_ID, 0))= 'N'
                               OR
                               PA_PJC_CWK_UTILS.Is_rate_based_line(null,nvl(aid.po_distribution_id,0))= 'N' )
                            AND aid.line_type_lookup_code IN ('ITEM','ACCRUAL','RETROACCRUAL')) OR
                            (aid.line_type_lookup_code NOT IN ('ITEM','ACCRUAL','RETROACCRUAL')))
                            AND trunc(aid2.Accounting_Date) <= trunc(nvl(G_GL_DATE,aid2.Accounting_Date))
                            AND trunc(aid.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,aid.expenditure_item_date)));

          G_PAY_DISTRIBUTIONS_MARKED := nvl(G_PAY_DISTRIBUTIONS_MARKED,0) + SQL%ROWCOUNT;
          write_log(LOG, 'Number of Prepayment Application Dist rows marked to O: ' || to_char(SQL%ROWCOUNT));

        ELSE          /* G_PROJECT_ID IS NULL */


          -- Update pa-addition-flag to O for all valid ap distributions that should be interfaced to Projects

            UPDATE ap_payment_hist_dists dist
            SET    dist.pa_addition_flag = 'O',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE  nvl(dist.pa_addition_flag,'N') = 'N'
            AND    dist.pay_dist_lookup_code = 'CASH'
            AND EXISTS (SELECT NULL
                        FROM   ap_payment_history_all hist
                        WHERE  hist.payment_history_id = dist.payment_history_id
                        AND    hist.posted_flag = 'Y')
            AND    exists(SELECT /*+ no_unnest */ inv.invoice_id
                           FROM AP_INVOICES_ALL inv,
                                PO_Distributions_all PO,
                                AP_Invoice_Distributions_all aid,
                                ap_invoice_payments_all aip
                          WHERE inv.invoice_id = aip.invoice_id
                            AND aid.invoice_id = inv.invoice_id
                            AND inv.org_id = G_ORG_ID
                            AND aip.invoice_payment_id = dist.invoice_payment_id
                            AND aid.invoice_distribution_id = dist.invoice_distribution_id
                            AND aid.line_type_lookup_code <> 'TERV'             -- Bug#5441030 to avoid zero dollar lines for TERV
                            AND aid.invoice_id = aip.invoice_id
                            AND aid.pa_addition_flag  = 'N'                      --to avoid any historical data to be processed as Payments
                            AND nvl(aid.historical_flag,'N') = 'N'
                            AND aid.po_distribution_id = PO.po_distribution_id (+)
                            AND   nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'
                            AND inv.paid_on_behalf_employee_id IS NULL
                            AND NVL(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
                            AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                            AND  nvl(INV.source, 'xx' ) NOT IN ('Oracle Project Accounting', 'PA_IC_INVOICES')
                            AND aid.project_id > 0
                            AND aid.line_type_lookup_code <> 'REC_TAX'
                            AND (((
                               PA_PJC_CWK_UTILS.Is_cwk_tc_xface_allowed(nvl(aid.project_ID, 0))= 'N'
                               OR
                               PA_PJC_CWK_UTILS.Is_rate_based_line(null,nvl(aid.po_distribution_id,0))= 'N' )
                            AND aid.line_type_lookup_code IN ('ITEM','ACCRUAL','RETROACCRUAL')) OR
                            (aid.line_type_lookup_code NOT IN ('ITEM','ACCRUAL','RETROACCRUAL')))
                            AND trunc(aip.Accounting_Date) <= trunc(nvl(G_GL_DATE,aip.Accounting_Date))
                            AND trunc(aid.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,aid.expenditure_item_date)));

        G_PAY_DISTRIBUTIONS_MARKED :=  SQL%ROWCOUNT;
        write_log(LOG, 'Number of Invoice - Payment rows marked to O: ' || to_char(SQL%ROWCOUNT));

        /* For Prepayment Application , we need to interface the prepay application lines created in ap_prepay_app_dists table*/

            UPDATE ap_prepay_app_dists dist
            SET    dist.pa_addition_flag = 'O',
                   request_id = G_REQUEST_ID,
                   last_update_date=SYSDATE,
                   last_updated_by= G_USER_ID,
                   last_update_login= G_USER_ID,
                   program_id= G_PROG_ID,
                   program_application_id= G_PROG_APPL_ID,
                   program_update_date=SYSDATE
            WHERE nvl(dist.pa_addition_flag,'N') = 'N'
            AND   dist.amount <> 0
            AND   exists(SELECT /*+ no_unnest */ inv.invoice_id
                           FROM AP_INVOICES_ALL inv,
                                PO_Distributions_all PO,
                                AP_Invoice_Distributions_all aid, --STD INV DIST LINE
                                AP_Invoice_Distributions_all aid2 -- PREPAY APPL DIST LINE
                          WHERE aid.invoice_id = inv.invoice_id
                            AND inv.org_id = G_ORG_ID
                            AND aid.invoice_distribution_id = dist.invoice_distribution_id  -- Std inv line
                            AND aid2.invoice_id = aid.invoice_id
                            AND aid2.invoice_distribution_id =  dist.prepay_app_distribution_id --Prepay appl line
                            --AND aid2.line_type_lookup_code in ( 'PREPAY', 'NONREC_TAX') -- bug#5514129
                            AND aid.line_type_lookup_code  <> 'REC_TAX' -- bug#5514129
                            AND aid2.pa_addition_flag  in ( 'N','E')         --to avoid any historical data to be processed as Payments
                             -- pa-addition-flag E to pull in rec tax across which prepay appl is prorated
                            and aid2.prepay_distribution_id is not null
                            AND aid2.posted_flag = 'Y'
                            AND aid.po_distribution_id = PO.po_distribution_id (+)
                            AND nvl(po.distribution_type,'XXX') <> 'PREPAYMENT'
                            AND inv.paid_on_behalf_employee_id IS NULL
                            AND NVL(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
                            AND inv.invoice_type_lookup_code <> 'EXPENSE REPORT'
                            AND  nvl(INV.source, 'xx' ) NOT IN ('Oracle Project Accounting', 'PA_IC_INVOICES')
                            AND aid.project_id> 0
                            AND (((
                               PA_PJC_CWK_UTILS.Is_cwk_tc_xface_allowed(nvl(aid.project_ID, 0))= 'N'
                               OR
                               PA_PJC_CWK_UTILS.Is_rate_based_line(null,nvl(aid.po_distribution_id,0))= 'N' )
                            AND aid.line_type_lookup_code IN ('ITEM','ACCRUAL','RETROACCRUAL')) OR
                            (aid.line_type_lookup_code NOT IN ('ITEM','ACCRUAL','RETROACCRUAL')))
                            AND trunc(aid2.Accounting_Date) <= trunc(nvl(G_GL_DATE,aid2.Accounting_Date))
                            AND trunc(aid.expenditure_item_date) <= trunc(nvl(G_TRANSACTION_DATE,aid.expenditure_item_date)));

        G_PAY_DISTRIBUTIONS_MARKED := nvl(G_PAY_DISTRIBUTIONS_MARKED,0) + SQL%ROWCOUNT;
        write_log(LOG, 'Number of Prepayment Application Dist rows marked to O: ' || to_char(SQL%ROWCOUNT));


       END IF;
         -- End of If section checking if G_PROJECT_ID is not null
     END IF; -- End of Invoice Type is Expense Report

     write_log(LOG, 'Total Number of Payment rows marked to O: ' || to_char(G_PAY_DISTRIBUTIONS_MARKED));

     G_err_stack := v_old_stack;

EXCEPTION
     WHEN Others THEN
           -- Marking phase failed, raise exception to main program to terminate the program
           --
           G_err_stack := v_old_stack;
           G_err_code := SQLCODE;
           RAISE;

END mark_PA_Pay_flag_O;

PROCEDURE transfer_pay_to_pa  IS

   v_num_invoices_fetched          NUMBER :=0;
   v_num_distributions_fetched     NUMBER :=0;
   v_prev_invoice_id               NUMBER := 0;
   v_prev_vendor_id                NUMBER := 0;
   v_old_stack                     VARCHAR2(630);
   v_err_message                   VARCHAR2(220);
   v_all_done                      NUMBER := 0;
   v_prev_invoice_source           ap_invoices.source%TYPE := NULL;
   v_prev_transaction_source       pa_transaction_sources.transaction_source%TYPE;
   v_num_tax_lines_fetched         NUMBER:=0;
   v_num_inv_variance_fetched      NUMBER:=0;    --NEW
   v_num_inv_erv_fetched           NUMBER:=0;    --NEW
   v_num_inv_frt_fetched           NUMBER:=0;    --NEW
   v_num_inv_prepay_fetched        NUMBER:=0;    --NEW
   v_last_inv_ER_flag              VARCHAR2(1);

   v_status Number := 0;
   v_stage  Number :=0;
   v_business_group_id NUMBER := 0;
   v_attribute_category VARCHAR2(150);
   v_attribute1 VARCHAR2(150);
   v_attribute2 VARCHAR2(150);
   v_attribute3 VARCHAR2(150);
   v_attribute4 VARCHAR2(150);
   v_attribute5 VARCHAR2(150);
   v_attribute6 VARCHAR2(150);
   v_attribute7 VARCHAR2(150);
   v_attribute8 VARCHAR2(150);
   v_attribute9 VARCHAR2(150);
   v_attribute10 VARCHAR2(150);
   v_dff_map_status VARCHAR2(30);
   dff_map_exception EXCEPTION;

   v_num_last_invoice_processed NUMBER := 0;
   v_last_inv_index             NUMBER := 0;
   v_num_dist_marked_O          NUMBER := 0;
   v_num_dist_remain            NUMBER := 0;
   v_max_size                   NUMBER := 0;

   v_inv_batch_size             NUMBER := 0;
   v_tax_batch_size             NUMBER := 0;
   v_var_batch_size             NUMBER := 0;
   v_frt_batch_size             NUMBER := 0;

-- For PA IP Invoices
   L_IP_TRANSACTION_SOURCE         pa_transaction_interface.transaction_source%TYPE;
   l_ap_inv_flag                   VARCHAR2(1):= 'N';
   l_ip_inv_flag                   VARCHAR2(1):= 'N';

   l_create_adj_recs  VARCHAR2(1) := 'N';
   l_ap_prepay_tax_flag    VARCHAR2(1):= 'N'; -- Flag to indicate tax  exist for prepay appl in Cash Basis flow.
   l_ap_prepay_var_flag    VARCHAR2(1):= 'N'; -- Flag to indicate variance exist for prepay appl lines in Cash Basis flow.
   l_ap_prepay_erv_flag    VARCHAR2(1):= 'N'; -- Flag to indicate erv exist for prepay appl lines in Cash Basis flow.

   /* the following sub-procedure is declared here to save lines of code since deleting
      plsql tables will be done multiple times within the procedure transfer_pay_to_pa */

   PROCEDURE clear_plsql_tables IS

       l_status1 VARCHAR2(30);

   BEGIN

       G_err_stage := 'within clear_plsql_tables of transfer_pay_to_pa';
       write_log(LOG, G_err_stage);

       l_invoice_id_tbl.delete;
       l_created_by_tbl.delete;
       l_invoice_dist_id_tbl.delete; --NEW
       l_project_id_tbl.delete;
       l_task_id_tbl.delete;
       l_ln_type_lookup_tbl.delete;
       l_exp_type_tbl.delete;
       l_ei_date_tbl.delete;
       l_amount_tbl.delete;
       l_description_tbl.delete;
       l_justification_tbl.delete;
       l_dist_cc_id_tbl.delete;
       l_exp_org_id_tbl.delete;
       l_quantity_tbl.delete;
       l_acct_pay_cc_id_tbl.delete;
       l_gl_date_tbl.delete;
       l_attribute_cat_tbl.delete;
       l_attribute1_tbl.delete;
       l_attribute2_tbl.delete;
       l_attribute3_tbl.delete;
       l_attribute4_tbl.delete;
       l_attribute5_tbl.delete;
       l_attribute6_tbl.delete;
       l_attribute7_tbl.delete;
       l_attribute8_tbl.delete;
       l_attribute9_tbl.delete;
       l_attribute10_tbl.delete;
       l_rec_cur_amt_tbl.delete;
       l_rec_cur_code_tbl.delete;
       l_rec_conv_rate_tbl.delete;
       l_denom_raw_cost_tbl.delete;
       l_denom_cur_code_tbl.delete;
       l_acct_rate_date_tbl.delete;
       l_acct_rate_type_tbl.delete;
       l_acct_exch_rate_tbl.delete;
       l_job_id_tbl.delete;
       l_employee_id_tbl.delete;
       l_vendor_id_tbl.delete;
       l_inv_type_code_tbl.delete;
       l_source_tbl.delete;
       l_org_id_tbl.delete;
       l_invoice_num_tbl.delete;
       l_cdl_sys_ref3_tbl.delete;
       l_cdl_sys_ref4_tbl.delete;
       l_po_dist_id_tbl.delete;
       l_txn_src_tbl.delete;
       l_user_txn_src_tbl.delete;
       l_batch_name_tbl.delete;
       l_interface_id_tbl.delete;
       l_exp_end_date_tbl.delete;
       l_txn_status_code_tbl.delete;
       l_txn_rej_code_tbl.delete;
       l_po_dist_id_tbl.delete;
       l_bus_grp_id_tbl.delete;
       l_paid_emp_id_tbl.delete;
       l_sort_var_tbl.delete;
       l_reversal_flag_tbl.delete;
       l_cancel_flag_tbl.delete;
       l_parent_rev_id_tbl.delete;
       l_net_zero_flag_tbl.delete;
       l_sc_xfer_code_tbl.delete;
       l_adj_exp_item_id_tbl.delete;
       l_fc_enabled_tbl.delete;
       l_fc_document_type_tbl.delete;
       l_rev_parent_dist_id_tbl.delete;
       l_rev_child_dist_id_tbl.delete;
       l_rev_parent_dist_ind_tbl.delete;
       l_si_assts_add_flg_tbl.delete;
       l_pay_hist_id_tbl.delete;
       l_prepay_dist_id_tbl.delete;
       l_rev_index:=0;

    END clear_plsql_tables;

   /* the following sub-procedure is declared here to save lines of code since bulk insert
      will be done multiple times within the procedure transfer_pay_to_pa */

    PROCEDURE bulk_update_trx_intf IS

     BEGIN

       /* The records with INSERT_FLAG = F indicate that they are fully applied prepayments and the pa-addition-flag
          for such records will be updated to G to relieve commitments*/
       /* The records with INSERT_FLAG = P indicate that they are partially applied prepayments and the pa-addition-flag
          for such records will be updated to N */

       write_log(LOG,'Before bulk update  of prepayment payments');

       FORALL i IN l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST

         UPDATE ap_payment_hist_dists dist
            SET dist.pa_addition_flag         = decode(l_insert_flag_tbl(i),'F','G','P','N')
          WHERE dist.invoice_payment_id       = l_inv_pay_id_tbl(i)
            AND dist.pay_dist_lookup_code     = 'CASH'
            AND dist.invoice_distribution_id  = l_invoice_dist_id_tbl(i)
            AND dist.pa_addition_flag         = 'O'
            AND l_insert_flag_tbl(i)         in ('P','F');

     EXCEPTION
      WHEN OTHERS THEN
          write_log(LOG,'Failed during bulk update for prepayment processing');
          G_err_code   := SQLCODE;
          write_log(LOG, 'Error Code is '||SQLCODE);
          write_log(LOG, substr(SQLERRM, 1, 200));
          write_log(LOG, substr(SQLERRM, 201, 200));
          raise;

    END bulk_update_trx_intf;


    PROCEDURE bulk_insert_trx_intf IS

      l_status2 VARCHAR2(30);

    BEGIN

       FORALL i IN l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST

       INSERT INTO pa_transaction_interface_all(
                     transaction_source
                    , user_transaction_source
                    , system_linkage
                    , batch_name
                    , expenditure_ending_date
                    , expenditure_item_date
                    , expenditure_type
                    , quantity
                    , raw_cost_rate
                    , expenditure_comment
                    , transaction_status_code
                    , transaction_rejection_code
                    , orig_transaction_reference
                    , interface_id
                    , dr_code_combination_id
                    , cr_code_combination_id
                    , cdl_system_reference1
                    , cdl_system_reference2
                    , cdl_system_reference3
                    , cdl_system_reference4
                    , cdl_system_reference5 --NEW
                    , gl_date
                    , org_id
                    , unmatched_negative_txn_flag
                    , receipt_currency_amount
                    , receipt_currency_code
                    , receipt_exchange_rate
                    , denom_raw_cost
                    , denom_currency_code
                    , acct_rate_date
                    , acct_rate_type
                    , acct_exchange_rate
                    , acct_raw_cost
                    , acct_exchange_rounding_limit
                    , attribute_category
                    , attribute1
                    , attribute2
                    , attribute3
                    , attribute4
                    , attribute5
                    , attribute6
                    , attribute7
                    , attribute8
                    , attribute9
                    , attribute10
                    , orig_exp_txn_reference1
                    , orig_user_exp_txn_reference
                    , orig_exp_txn_reference2
                    , orig_exp_txn_reference3
                    , last_update_date
                    , last_updated_by
                    , creation_date
                    , created_by
                    , person_id
                    , organization_id
                    , project_id
                    , task_id
                    , Vendor_id
                    , override_to_organization_id
                    , person_business_group_id
                    , adjusted_expenditure_item_id --NEW
                    , fc_document_type  -- NEW
                    , document_type
                    , document_distribution_type
                    , sc_xfer_code
                    , si_assets_addition_flag
                    , net_zero_adjustment_flag
                   )
              SELECT  l_txn_src_tbl(i)
                     ,l_user_txn_src_tbl(i)
                     ,G_SYSTEM_LINKAGE
                     ,l_batch_name_tbl(i)
                     ,l_exp_end_date_tbl(i)
                     ,l_ei_date_tbl(i)
                     ,l_exp_type_tbl(i)
                     ,l_quantity_tbl(i)
                     ,l_amount_tbl(i)/decode(nvl(l_quantity_tbl(i),0),0,1,l_quantity_tbl(i))
                     ,l_description_tbl(i)
                     ,l_txn_status_code_tbl(i)
                     ,l_txn_rej_code_tbl(i)
                     ,G_REQUEST_ID
                     ,l_interface_id_tbl(i)
                     ,l_dist_cc_id_tbl(i)
                     ,l_acct_pay_cc_id_tbl(i)
                     ,decode(l_ln_type_lookup_tbl(i),'PREPAY',l_vendor_id_tbl(i),l_pay_hist_id_tbl(i)) /*sysref1*/
                     ,l_invoice_id_tbl(i) /*sysref2*/
                     ,l_cdl_sys_ref3_tbl(i) /*sysref3*/
                     ,l_inv_pay_id_tbl(i) /*sysref4*/
                     ,l_invoice_dist_id_tbl(i) /*sysref5*/
                     ,l_gl_date_tbl(i)
                     ,G_ORG_ID
                     ,'Y'
                     ,l_rec_cur_amt_tbl(i)
                     ,l_rec_cur_code_tbl(i)
                     ,l_rec_conv_rate_tbl(i)
                     ,l_denom_raw_cost_tbl(i)
                     ,l_denom_cur_code_tbl(i)
                     ,l_acct_rate_date_tbl(i)
                     ,l_acct_rate_type_tbl(i)
                     ,l_acct_exch_rate_tbl(i)
                     ,l_amount_tbl(i)
                     ,1
                     ,l_attribute_cat_tbl(i)
                     ,l_attribute1_tbl(i)
                     ,l_attribute2_tbl(i)
                     ,l_attribute3_tbl(i)
                     ,l_attribute4_tbl(i)
                     ,l_attribute5_tbl(i)
                     ,l_attribute6_tbl(i)
                     ,l_attribute7_tbl(i)
                     ,l_attribute8_tbl(i)
                     ,l_attribute9_tbl(i)
                     ,l_attribute10_tbl(i)
                     ,l_invoice_id_tbl(i)        /*orig_exp_txn_reference1*/
                     ,l_invoice_num_tbl(i)       /*user_exp_txn_reference*/
                     ,DECODE(G_TRANS_DFF_AP,'N',NULL,l_invoice_id_tbl(i)) /*orig_exp_txn_reference2*/
                     ,NULL                       /*orig_exp_txn_reference3*/
                     ,SYSDATE
                     ,-1
                     ,SYSDATE
                     ,-1
                     ,l_employee_id_tbl(i)
                     ,l_org_id_tbl(i)
                     ,l_project_id_tbl(i)
                     ,l_task_id_tbl(i)
                     ,l_vendor_id_tbl(i)
                     ,l_exp_org_id_tbl(i)
                     ,l_bus_grp_id_tbl(i)
                     ,l_adj_exp_item_id_tbl(i) --NEW for reversals
                     ,l_fc_document_type_tbl(i) --NEW for funds check
                     ,l_inv_type_code_tbl(i)
                     ,l_ln_type_lookup_tbl(i)
                     ,l_sc_xfer_code_tbl(i)
                     ,l_si_assts_add_flg_tbl(i)
                     ,l_net_zero_flag_tbl(i)
                 FROM DUAL
                WHERE l_insert_flag_tbl(i)     not in ('P','F');

              -- Insert the adjustment recs from AP.
    IF l_create_adj_recs = 'Y' THEN

                write_log(LOG, 'Inserting adjustment records..');

       FORALL i IN l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST

       INSERT INTO pa_transaction_interface_all(
                     transaction_source
                    , user_transaction_source
                    , system_linkage
                    , batch_name
                    , expenditure_ending_date
                    , expenditure_item_date
                    , expenditure_type
                    , quantity
                    , raw_cost_rate
                    , expenditure_comment
                    , transaction_status_code
                    , transaction_rejection_code
                    , orig_transaction_reference
                    , interface_id
                    , dr_code_combination_id
                    , cr_code_combination_id
                    , cdl_system_reference1
                    , cdl_system_reference2
                    , cdl_system_reference3
                    , cdl_system_reference4
                    , cdl_system_reference5 --NEW
                    , gl_date
                    , org_id
                    , unmatched_negative_txn_flag
                    , receipt_currency_amount
                    , receipt_currency_code
                    , receipt_exchange_rate
                    , denom_raw_cost
                    , denom_currency_code
                    , acct_rate_date
                    , acct_rate_type
                    , acct_exchange_rate
                    , acct_raw_cost
                    , acct_exchange_rounding_limit
                    , attribute_category
                    , attribute1
                    , attribute2
                    , attribute3
                    , attribute4
                    , attribute5
                    , attribute6
                    , attribute7
                    , attribute8
                    , attribute9
                    , attribute10
                    , orig_exp_txn_reference1
                    , orig_user_exp_txn_reference
                    , orig_exp_txn_reference2
                    , orig_exp_txn_reference3
                    , last_update_date
                    , last_updated_by
                    , creation_date
                    , created_by
                    , person_id
                    , organization_id
                    , project_id
                    , task_id
                    , Vendor_id
                    , override_to_organization_id
                    , person_business_group_id
                    , adjusted_expenditure_item_id --NEW
                    , fc_document_type  -- NEW
                    , document_type
                    , document_distribution_type
                    , adjusted_txn_interface_id --NEW
                    , sc_xfer_code
                    , si_assets_addition_flag
                    , net_zero_adjustment_flag
                   )
                  SELECT
                      l_txn_src_tbl(i)
                     ,l_user_txn_src_tbl(i)
                     ,G_SYSTEM_LINKAGE
                     ,l_batch_name_tbl(i)
                     ,l_exp_end_date_tbl(i)
                     ,l_ei_date_tbl(i)
                     ,l_exp_type_tbl(i)
                     ,-l_quantity_tbl(i)
                     ,l_amount_tbl(i)/decode(nvl(l_quantity_tbl(i),0),0,1,l_quantity_tbl(i))
                     ,l_description_tbl(i)
                     ,l_txn_status_code_tbl(i)
                     ,l_txn_rej_code_tbl(i)
                     ,G_REQUEST_ID
                     ,l_interface_id_tbl(i)
                     ,l_dist_cc_id_tbl(i)
                     ,l_acct_pay_cc_id_tbl(i)
                     --,l_vendor_id_tbl(i) /*sysref1*/
                     ,decode(l_ln_type_lookup_tbl(i),'PREPAY',l_vendor_id_tbl(i),l_pay_hist_id_tbl(i)) /*sysref1*/
                     ,l_invoice_id_tbl(i) /*sysref2*/
                     ,l_cdl_sys_ref3_tbl(i)/*sysref3*/
                     ,l_inv_pay_id_tbl(i)  /*sysref4*/
                     ,l_invoice_dist_id_tbl(i) /*sysref5*/ --NEW
                     ,l_gl_date_tbl(i)
                     ,G_ORG_ID
                     ,'Y'
                     ,-l_rec_cur_amt_tbl(i)
                     ,l_rec_cur_code_tbl(i)
                     ,l_rec_conv_rate_tbl(i)
                     ,-l_denom_raw_cost_tbl(i)
                     ,l_denom_cur_code_tbl(i)
                     ,l_acct_rate_date_tbl(i)
                     ,l_acct_rate_type_tbl(i)
                     ,l_acct_exch_rate_tbl(i)
                     ,-l_amount_tbl(i)
                     ,1
                     ,l_attribute_cat_tbl(i)
                     ,l_attribute1_tbl(i)
                     ,l_attribute2_tbl(i)
                     ,l_attribute3_tbl(i)
                     ,l_attribute4_tbl(i)
                     ,l_attribute5_tbl(i)
                     ,l_attribute6_tbl(i)
                     ,l_attribute7_tbl(i)
                     ,l_attribute8_tbl(i)
                     ,l_attribute9_tbl(i)
                     ,l_attribute10_tbl(i)
                     ,l_invoice_id_tbl(i)        /*orig_exp_txn_reference1*/
                     ,l_invoice_num_tbl(i)       /*user_exp_txn_reference*/
                     /* bug 2835757*/
                     ,DECODE(G_TRANS_DFF_AP,'N',NULL,l_invoice_id_tbl(i)) /*orig_exp_txn_reference2*/
                     ,NULL                       /*orig_exp_txn_reference3*/
                     ,SYSDATE
                     ,-1
                     ,SYSDATE
                     ,-1
                     ,l_employee_id_tbl(i)
                     ,l_org_id_tbl(i)
                     ,l_project_id_tbl(i)
                     ,l_task_id_tbl(i)
                     ,l_vendor_id_tbl(i)
                     ,l_exp_org_id_tbl(i)
                     ,l_bus_grp_id_tbl(i)
                     ,l_adj_exp_item_id_tbl(i) --NEW for reversals
                     ,l_fc_document_type_tbl(i) --NEW for funds check
                     ,l_inv_type_code_tbl(i)
                     ,l_ln_type_lookup_tbl(i)
                     ,(select xface.txn_interface_id
                       from   pa_transaction_interface xface
                       where  xface.interface_id = l_interface_id_tbl(i)
                       and    xface.cdl_system_reference2 = l_invoice_id_tbl(i)
                       and    xface.cdl_system_reference4 = to_char(l_inv_pay_id_tbl(i))
                       and    xface.cdl_system_reference5 = l_invoice_dist_id_tbl(i)
		       and    NVL(xface.adjusted_expenditure_item_id,0) = 0 ) -- R12 funds management Uptake
                     ,'P'
                     ,'T' -- l_si_assts_add_flg_tbl(i)
                     ,l_net_zero_flag_tbl(i)
                FROM dual
                WHERE l_insert_flag_tbl(i)= 'A';
               -- WHERE l_net_zero_flag_tbl(i)= 'Y';

               -- Handle both the parent and the reversal getting interfaced into PA
               -- in the same run.
                write_log(LOG, 'Updating  adjustment records..');
              IF l_rev_child_dist_id_tbl.exists(1) THEN
               FOR i in l_rev_child_dist_id_tbl.FIRST ..l_rev_child_dist_id_tbl.LAST LOOP
                   IF l_rev_child_dist_id_tbl(i) > 0 THEN
                    UPDATE pa_transaction_interface_all xface
                    SET    xface.net_zero_adjustment_flag ='Y',
                           xface.adjusted_txn_interface_id =
                              (select xface1.txn_interface_id
                               from   pa_transaction_interface xface1
                               where  xface1.interface_id = l_interface_id_tbl(l_rev_parent_dist_ind_tbl(i))
                               and    xface1.cdl_system_reference2 = l_invoice_id_tbl(l_rev_parent_dist_ind_tbl(i))
                               and    xface1.cdl_system_reference4 = to_char(l_inv_pay_id_tbl(l_rev_parent_dist_ind_tbl(i)))
                               and    xface1.cdl_system_reference5 = l_invoice_dist_id_tbl(l_rev_parent_dist_ind_tbl(i))
                               )
                      WHERE  xface.interface_id          = l_interface_id_tbl(l_rev_parent_dist_ind_tbl(i))
                      AND    xface.cdl_system_reference2 = l_invoice_id_tbl(l_rev_parent_dist_ind_tbl(i))
                      AND    -- For voided payments l_rev_child_dist_id_tbl stores the reversed payment id Bug# 5408748
                             -- Here the reversal pair will have same inv dist id and diff payment id's
                             ((
                             xface.cdl_system_reference4     = To_char(l_rev_child_dist_id_tbl(i))
                             AND xface.cdl_system_reference5 = l_invoice_dist_id_tbl(l_rev_parent_dist_ind_tbl(i))
                             )
                      OR     -- For invoice reversal l_rev_child_dist_id_tbl stores the reversed invoice dist id Bug# 5408748
                             -- Here the reversal pair will have same payment id and diff inv dist id's
                             (
                             xface.cdl_system_reference4     = to_char(l_inv_pay_id_tbl(l_rev_parent_dist_ind_tbl(i)))
                             AND xface.cdl_system_reference5 = To_char(l_rev_child_dist_id_tbl(i))
                             )) ;
                   END IF;
               END LOOP;
              END IF;

    END IF;
   EXCEPTION
      WHEN OTHERS THEN
          write_log(LOG,'Failed during bulk insert for payment processing');
          G_err_code   := SQLCODE;
          raise;

   END bulk_insert_trx_intf;

   PROCEDURE process_pay_logic IS

       l_status3 VARCHAR2(30);
       j NUMBER := 0; --Index variable for creating reversal EI's --NEW
       l_historical_flag VARCHAR(1);  --NEW
       l_process_adjustments    Number := 0 ;

   BEGIN

       G_err_stage := ('Within Calling process logic of transfer_pay_to_pa');
       write_log(LOG, G_err_stage);

       /* Initializing global variables here to reduce code lines */
       G_NRT_TRANSACTION_SOURCE      := 'AP NRTAX' ;
       G_NRT_USER_TRANSACTION_SOURCE := 'Non-Recoverable Tax From Payables';

       G_AP_VAR_TRANSACTION_SOURCE  := 'AP VARIANCE';
       G_AP_VAR_USER_TXN_SOURCE     := 'Oracle Payables Invoice Variance';


       G_AP_ERV_TRANSACTION_SOURCE  := 'AP ERV';         --NEW bug 5372603
       G_AP_ERV_USER_TXN_SOURCE     := 'Oracle Payables Supplier Cost Exchange Rate Variance';  --NEW bug 5372603


       j := v_last_inv_index; -- initialize j to the total invoice distributions fetched in the PLSQL array


       FOR i IN  l_invoice_id_tbl.FIRST..l_invoice_id_tbl.LAST  LOOP

           write_log(LOG,'Processing invoice id:  '||l_invoice_id_tbl(i)|| 'dist id:  '||l_invoice_dist_id_tbl(i));

           G_TRANSACTION_REJECTION_CODE := '';

           IF l_source_tbl(i) in ('CREDIT CARD','Both Pay') THEN

              write_log(LOG,'This is a credit card txn, setting emp id to paid_emp_id.');
              l_employee_id_tbl(i)   := l_paid_emp_id_tbl(i);
              l_inv_type_code_tbl(i) := 'EXPENSE REPORT';

           ELSIF l_inv_type_code_tbl(i) = 'EXPENSE REPORT' and l_employee_id_tbl(i) is null THEN
              write_log(LOG,'This is a CWK Exp Report, setting emp id to paid_emp_id.');
              l_employee_id_tbl(i)   := l_paid_emp_id_tbl(i);

           END IF;

           /* The following will be executed if the distribution being fetched belongs to a new invoice */
           IF (l_invoice_id_tbl(i) <> v_prev_invoice_id) THEN

               G_err_stage := ('New invoice being processed.New invoice _id is:'||l_invoice_id_tbl(i));
               write_log(LOG, G_err_stage);

               /* Update the previous invoice id and vendor id*/
               v_prev_invoice_id := l_invoice_id_tbl(i);
               v_prev_vendor_id  := l_vendor_id_tbl(i);

               /* Increment the counter for invoices */
               v_num_invoices_fetched := v_num_invoices_fetched + 1;

               IF nvl(v_prev_invoice_source,l_source_tbl(i)||'111') <> l_source_tbl(i) THEN

                  /* First update the v_prev_invoice_source */
                  G_err_stage := 'New source encountered';
                  write_log(LOG, G_err_stage);
                  v_prev_invoice_source := l_source_tbl(i);


                  IF l_source_tbl(i) = 'PA_IP_INVOICES' THEN

                     G_err_stage := 'Invoice source is Inter-Company Invoice';
                     write_log(LOG, G_err_stage);
                     G_TRANSACTION_SOURCE      := 'INTERPROJECT_AP_INVOICES';
                     v_prev_transaction_source := G_TRANSACTION_SOURCE;
                     G_USER_TRANSACTION_SOURCE := 'Oracle Inter-Project Invoices';

                     L_IP_TRANSACTION_SOURCE      := 'INTERPROJECT_AP_INVOICES';
                     l_ip_inv_flag                    := 'Y' ;

                  ELSIF (l_source_tbl(i)        = 'XpenseXpress' OR
                         /* if its a Credit card txn, treat like expense report*/
                         l_source_tbl(i) in ('CREDIT CARD','Both Pay') OR
                        (l_source_tbl(i)        = 'Manual Invoice Entry' AND
                         l_inv_type_code_tbl(i) = 'EXPENSE REPORT') OR
                         l_source_tbl(i)        = 'SelfService') THEN

                      G_err_stage := 'Invoice source is Expense Reports';
                      write_log(LOG, G_err_stage);
                      G_TRANSACTION_SOURCE      := 'AP EXPENSE';
                      v_prev_transaction_source := G_TRANSACTION_SOURCE;
                      G_USER_TRANSACTION_SOURCE := 'ORACLE PAYABLES';

                  ELSE

                      G_err_stage := 'Invoice source is AP Invoice';
                      write_log(LOG, G_err_stage);
                      G_TRANSACTION_SOURCE             := 'AP INVOICE';
                      v_prev_transaction_source := G_TRANSACTION_SOURCE;

                      G_USER_TRANSACTION_SOURCE        := 'AP INVOICE';
                      l_ap_inv_flag                    := 'Y' ;

                  END IF;

               END IF; /* invoice source <> v_prev_tranasction_source */

                /* For new invoice, initialize the transaction status code to 'P' */
                G_TRANSACTION_STATUS_CODE := 'P';

                G_err_stage := 'GET MAX EXPENDITURE ENDING DATE';
                write_log(LOG, G_err_stage);
/* Bug 5051103 - replace expnediture_item_date with l_ei_date_tbl(i) */
                SELECT pa_utils.getweekending(MAX(l_ei_date_tbl(i)))
                  INTO G_EXPENDITURE_ENDING_DATE
                  FROM ap_invoice_distributions
                 WHERE invoice_id = l_invoice_id_tbl(i);

                G_err_stage := ('Getting bus group id');
                write_log(LOG, G_err_stage);

                BEGIN

                   IF l_employee_id_tbl(i) <> 0 THEN
            		   Begin
                                  write_log(LOG,'getting bus group id with emp id of :  '||l_employee_id_tbl(i));

                                  SELECT emp.business_group_id
                                    INTO G_PER_BUS_GRP_ID
                                    FROM per_all_people_f emp
                                   WHERE emp.person_id = l_employee_id_tbl(i)
                                      AND l_ei_date_tbl(i) between trunc(emp.effective_start_date) and trunc(emp.effective_end_date);

            			EXCEPTION
            			   WHEN NO_DATA_FOUND THEN
            			      l_txn_status_code_tbl(i)     := 'R';
            			      G_TRANSACTION_REJECTION_CODE := 'INVALID_EMPLOYEE';
            			      write_log(LOG, 'As no data found for Employee, Rejecting invoice'||l_invoice_id_tbl(i)  );
             		    End;
		            Else
		    Begin

			    select org2.business_group_id
                              into G_PER_BUS_GRP_ID
			      from hr_organization_units org1,
				   hr_organization_units org2
			     Where org1.organization_id = l_exp_org_id_tbl(i)
			       and org1.business_group_id = org2.organization_id ;

			    Exception
			      When no_data_found Then
				G_TRANSACTION_STATUS_CODE := 'R';
				G_TRANSACTION_REJECTION_CODE := 'INVALID_ORGANIZATION';
				write_log(LOG,'As no data found for Organization,Rejecting invoice '||l_invoice_id_tbl(i)  );
		     End;
        	END IF;   /* IF l_employee_id_tbl(i) <> 0 THEN  */

                END;

           END IF; /* end of check for different invoice_id from previous invoice_id */


           /* The following will be executed when the distribution belongs to the same
              invoice or not the same invoice */

           v_num_distributions_fetched := v_num_distributions_fetched + 1;
           write_log(LOG,'Num of distributions fetched:'||v_num_distributions_fetched);

           /*Update counter of how many distributions of the last invoice of the batch has been processed*/

           IF l_invoice_id_tbl(i) = l_invoice_id_tbl(v_last_inv_index) THEN
              v_num_last_invoice_processed := v_num_last_invoice_processed +1;

              IF l_inv_type_code_tbl(i) = 'EXPENSE REPORT' THEN
                 v_last_inv_ER_flag := 'Y';
              ELSE
                 v_last_inv_ER_flag := 'N';
              END IF;

           END IF;


           -- FC Doc Type
            IF l_fc_enabled_tbl(i) = 'N' THEN
             l_fc_document_type_tbl(i) := 'NOT';
            END IF;

           /* if the invoice is an expense report from self-service we need to use the column of justification as the description */
           IF (l_inv_type_code_tbl(i) = 'EXPENSE REPORT' AND
               l_source_tbl(i)        in ('SelfService','XpenseXpress') ) THEN
               l_description_tbl(i) := l_justification_tbl(i);
           END IF;

           IF l_ln_type_lookup_tbl(i)  in ('NONREC_TAX','TRV','TIPV') THEN

              /* Update counter for number of tax lines fetched */
              v_num_tax_lines_fetched := v_num_tax_lines_fetched +1;

              l_txn_src_tbl(i)      := G_NRT_TRANSACTION_SOURCE;
              l_user_txn_src_tbl(i) := G_NRT_USER_TRANSACTION_SOURCE;

              IF l_prepay_dist_id_tbl(i) is not null THEN -- tax associated with prepay application Bug#5514129
                l_batch_name_tbl(i)   := G_PREPAY_BATCH_NAME;
                l_interface_id_tbl(i) := G_PREPAY_INTERFACE_ID;
                l_ap_prepay_tax_flag := 'Y';
              ELSE
                l_batch_name_tbl(i)   := G_NRT_BATCH_NAME;
                l_interface_id_tbl(i) := G_NRT_INTERFACE_ID;
              END IF;

           ELSIF l_ln_type_lookup_tbl(i) = 'IPV' THEN

              /* Update counter for number of variance lines fetched */
              v_num_inv_variance_fetched :=  v_num_inv_variance_fetched +1;

              l_quantity_tbl(i)     := l_denom_raw_cost_tbl(i);
              l_txn_src_tbl(i)      := G_AP_VAR_TRANSACTION_SOURCE;
              l_user_txn_src_tbl(i) := G_AP_VAR_USER_TXN_SOURCE;

              IF l_prepay_dist_id_tbl(i) is not null THEN -- associated with prepay application Bug#5514129
                l_batch_name_tbl(i)   := G_PREPAY_BATCH_NAME;
                l_interface_id_tbl(i) := G_PREPAY_INTERFACE_ID;
                l_ap_prepay_var_flag := 'Y';
              ELSE
                l_batch_name_tbl(i)   := G_AP_VAR_BATCH_NAME;
                l_interface_id_tbl(i) := G_AP_VAR_INTERFACE_ID;
              END IF;

           ELSIF l_ln_type_lookup_tbl(i) in ('ERV','TERV') THEN
              /* Update counter for number of variance lines fetched */
              v_num_inv_erv_fetched :=  v_num_inv_erv_fetched +1;

              l_quantity_tbl(i)     := l_denom_raw_cost_tbl(i);
              l_txn_src_tbl(i)      := G_AP_ERV_TRANSACTION_SOURCE;
              l_user_txn_src_tbl(i) := G_AP_ERV_USER_TXN_SOURCE;

              IF l_prepay_dist_id_tbl(i) is not null THEN -- associated with prepay application Bug#5514129
                l_batch_name_tbl(i)   := G_PREPAY_BATCH_NAME;
                l_interface_id_tbl(i) := G_PREPAY_INTERFACE_ID;
                l_ap_prepay_erv_flag := 'Y';
              ELSE
                l_batch_name_tbl(i)   := G_AP_ERV_BATCH_NAME;
                l_interface_id_tbl(i) := G_AP_ERV_INTERFACE_ID;
              END IF;

           ELSIF  l_ln_type_lookup_tbl(i) in ('FREIGHT','MISCELLANEOUS') THEN
              /* Update counter for number of frt and misc lines fetched */
              v_num_inv_frt_fetched :=  v_num_inv_frt_fetched +1;

              l_txn_src_tbl(i)      := G_TRANSACTION_SOURCE;
              l_user_txn_src_tbl(i) := G_USER_TRANSACTION_SOURCE;
              IF l_prepay_dist_id_tbl(i) is not null THEN -- associated with prepay application Bug#5514129
                l_batch_name_tbl(i)   := G_PREPAY_BATCH_NAME;
                l_interface_id_tbl(i) := G_PREPAY_INTERFACE_ID;
              ELSE
                l_batch_name_tbl(i)   := G_AP_FRT_BATCH_NAME;
                l_interface_id_tbl(i) := G_AP_FRT_INTERFACE_ID;
              END IF;

           ELSIF  l_ln_type_lookup_tbl(i) in ('PREPAY') THEN

              l_txn_src_tbl(i)      := G_TRANSACTION_SOURCE;
              l_user_txn_src_tbl(i) := G_USER_TRANSACTION_SOURCE;
              l_batch_name_tbl(i)   := G_PREPAY_BATCH_NAME;
              l_interface_id_tbl(i) := G_PREPAY_INTERFACE_ID;

           ELSE -- Other distribution types like ITEM,ACCRUAL etc

              l_txn_src_tbl(i)      := G_TRANSACTION_SOURCE;
              l_user_txn_src_tbl(i) := G_USER_TRANSACTION_SOURCE;
              l_batch_name_tbl(i)   := G_BATCH_NAME;
              l_interface_id_tbl(i) := G_INTERFACE_ID;

           END IF ;

           G_TRANSACTION_REJECTION_CODE := '';

           /*Setting values according to global variables*/
           l_bus_grp_id_tbl(i)      := G_PER_BUS_GRP_ID;
           l_exp_end_date_tbl(i)    := G_EXPENDITURE_ENDING_DATE;
           l_txn_rej_code_tbl(i)    := G_TRANSACTION_REJECTION_CODE;
           l_txn_status_code_tbl(i) := G_TRANSACTION_STATUS_CODE;

           write_log(LOG,'Value of l_txn_src_tbl:'||l_txn_src_tbl(i) ||'batch name:'||l_batch_name_tbl(i));

           /* In Rel12 we will not interface any PREPAYMENT PAYMENTS to Oracle Projects */
           --
           /* The records with INSERT_FLAG = F indicate that they are fully applied prepayments and the pa-addition-flag
              for such records will be updated to G to relieve commitments*/
           /* The records with INSERT_FLAG = P indicate that they are partially applied prepayments and the pa-addition-flag
              for such records will be updated to N */

           IF (l_inv_type_code_tbl(i) = 'PREPAYMENT' ) THEN

              IF check_prepay_fully_applied(l_invoice_dist_id_tbl(i)) = 'Y' THEN
                 l_insert_flag_tbl(i) := 'F';
              ELSE
                 l_insert_flag_tbl(i) := 'P';
              END IF;

           ELSE

           -- REVERSED DISTRIBUTIONS INTERFACE LOGIC
           -- If the distribution is a reversal or cancellation then check if the parent reversal distribution
           -- was historical data or not. If data is historical, reversal distribution line will be interfaced as is.
           --
           -- However if the parent reversal distribution is not historical then the following steps happen:
           -- a) Retreive the latest adjusted expenditures from PA against the parent reversal distribution id
           -- b) If any of the above latest EI's are not costed, then the reversed distribution will be rejected by the
           --    TRX import program
           -- c) IF all above adjusted EI's are costed, then insert record into the interface table for each adjusted EI.
           --    The project attributes will be copied from the adjusted EI's instead from the AP reversed
           --    distribution since these could have changed in PA.
           -- d) The interface program will interface the reversed distribution into projects
           -- e) The interface program will also insert a reversal of the reversed distribution into Projects. This is
           --    required for account reconciliation
           --

         -- This logic is to handle both the parent and reversal getting interfaced in the same run.
          -- It's a reversed parent record. Bug#4590527
          -- If both the parent and child reversing each other are interfaced in the same run, they
          -- were not getting interfaced as netzero transactions.

           IF (l_reversal_flag_tbl(i) in ('Y','R') or l_cancel_flag_tbl(i) = 'Y')
                                 AND l_parent_pmt_id_tbl(i) IS NULL THEN

              l_rev_index := l_rev_index +1;
              IF l_reversal_flag_tbl(i) = 'Y' THEN
                write_log(LOG, 'Reversal parent record '||l_inv_pay_id_tbl(i));
                l_rev_parent_dist_id_tbl(l_rev_index) :=  l_inv_pay_id_tbl(i);
              ELSE

                -- The Reversal flag with value R indicates that the invoice distribution has been reversed
                -- Refer to Bug#5408748

                write_log(LOG, 'Reversal parent record for Invoice Dist reversals'||l_invoice_dist_id_tbl(i));
                l_rev_parent_dist_id_tbl(l_rev_index) :=  l_invoice_dist_id_tbl(i);
              END IF;

              l_rev_child_dist_id_tbl(l_rev_index) :=  null;
              l_rev_parent_dist_ind_tbl(l_rev_index) :=  i; -- store the index of the parent.

           END IF;

           IF l_reversal_flag_tbl(i) in ('Y','R')  and l_parent_pmt_id_tbl(i) is not null THEN

-- check if reversal flag is populated for prepayment appl

                  -- Call reversal API
                  Process_Adjustments(p_record_type  => 'AP_PAYMENT',
                                      p_document_header_id  => l_invoice_id_tbl(i) ,/*Added this for 6945767 */
                                      p_document_distribution_id  => l_invoice_dist_id_tbl(i),
                                      p_document_payment_id       => l_parent_pmt_id_tbl(i),
                                      p_current_index             => i,
				      p_last_index                => j);

                      -- Set the create flag for adjustment records
                         IF l_insert_flag_tbl(i) in ('A','U') THEN
                          l_create_adj_recs := 'Y';
                         END IF;

           END IF; --End of check for reversal Distribution

           G_err_stage := ('Value of G_TRANS_DFF_AP:'||G_TRANS_DFF_AP);
           write_log(LOG, G_err_stage);

           IF (G_TRANS_DFF_AP = 'Y') THEN

                v_attribute_category := l_attribute_cat_tbl(i);
                v_attribute1 := l_attribute1_tbl(i);
                v_attribute2 := l_attribute2_tbl(i);
                v_attribute3 := l_attribute3_tbl(i);
                v_attribute4 := l_attribute4_tbl(i);
                v_attribute5 := l_attribute5_tbl(i);
                v_attribute6 := l_attribute6_tbl(i);
                v_attribute7 := l_attribute7_tbl(i);
                v_attribute8 := l_attribute8_tbl(i);
                v_attribute9 := l_attribute9_tbl(i);
                v_attribute10 := l_attribute10_tbl(i);

                v_dff_map_status := NULL;

                PA_CLIENT_EXTN_DFFTRANS.DFF_map_segments_PA_and_AP(
                   p_calling_module            => 'PAAPIMP',
                   p_trx_ref_1                 => l_invoice_id_tbl(i),
                   --p_trx_ref_2                 => l_dist_line_num_tbl(i),
                   p_trx_ref_2                 => l_invoice_dist_id_tbl(i),  --NEW
                   p_trx_type                  => l_inv_type_code_tbl(i),
                   p_system_linkage_function   => G_SYSTEM_LINKAGE,
                   p_submodule                 => l_source_tbl(i),
                   p_expenditure_type          => l_exp_type_tbl(i),
                   p_set_of_books_id           => G_AP_SOB,
                   p_org_id                    => l_org_id_tbl(i),
                   p_attribute_category        => v_attribute_category,
                   p_attribute_1               => v_attribute1,
                   p_attribute_2               => v_attribute2,
                   p_attribute_3               => v_attribute3,
                   p_attribute_4               => v_attribute4,
                   p_attribute_5               => v_attribute5,
                   p_attribute_6               => v_attribute6,
                   p_attribute_7               => v_attribute7,
                   p_attribute_8               => v_attribute8,
                   p_attribute_9               => v_attribute9,
                   p_attribute_10              => v_attribute10,
                   x_status_code               => v_dff_map_status);

                   IF (v_dff_map_status IS NOT NULL) THEN

                       write_log(LOG, 'Error in DFF_map_segments_PA_and_AP, Error Code: ' || v_dff_map_status);
                       raise dff_map_exception;

                   END IF;

                   l_attribute_cat_tbl(i) := v_attribute_category;
                   l_attribute1_tbl(i) := v_attribute1;
                   l_attribute2_tbl(i) := v_attribute2;
                   l_attribute3_tbl(i) := v_attribute3;
                   l_attribute4_tbl(i) := v_attribute4;
                   l_attribute5_tbl(i) := v_attribute5;
                   l_attribute6_tbl(i) := v_attribute6;
                   l_attribute7_tbl(i) := v_attribute7;
                   l_attribute8_tbl(i) := v_attribute8;
                   l_attribute9_tbl(i) := v_attribute9;
                   l_attribute10_tbl(i) := v_attribute10;

	   ElSE /* if DFF profile is No. Added for Bug 3105153*/
                   l_attribute_cat_tbl(i) := NULL;     --Bug#3856390
                   l_attribute1_tbl(i) := NULL;
                   l_attribute2_tbl(i) := NULL;
                   l_attribute3_tbl(i) := NULL;
                   l_attribute4_tbl(i) := NULL;
                   l_attribute5_tbl(i) := NULL;
                   l_attribute6_tbl(i) := NULL;
                   l_attribute7_tbl(i) := NULL;
                   l_attribute8_tbl(i) := NULL;
                   l_attribute9_tbl(i) := NULL;
                   l_attribute10_tbl(i) := NULL;

	   END IF; /* if DFF profile is Yes */

        END IF; /* if inv type is PREPAYMENT */

      END LOOP; /* End of looping through each record in plsql table */

   EXCEPTION
      WHEN OTHERS THEN
          write_log(LOG,'Failed during process_pay_logic');
          G_err_code   := SQLCODE;
          raise;

   END process_pay_logic;

   BEGIN
   /* Main Procedure Logic starts here */

   G_err_stage := 'Within main procedure of transfer_pay_to_pa';
   write_log(LOG, G_err_stage);

     write_log(LOG, '......Result of G_TRANSACTION_SOURCE: ' || G_TRANSACTION_SOURCE);

     v_max_size := nvl(G_COMMIT_SIZE,200);

     -- Create a new interface ID for the first session

     OPEN Payments_Cur;

     G_err_stage := 'After opening Payments_Cur within transfer_pay_to_pa';
     write_log(LOG, G_err_stage);

     WHILE (v_all_done = 0) LOOP

       clear_plsql_tables;

       --Creating new interface ID every time this is called
       G_err_stage := 'CREATING NEW INTERFACE ID';
       write_log(LOG, G_err_stage);

       SELECT pa_interface_id_s.nextval
         INTO G_INTERFACE_ID
         FROM dual;

       G_err_stage := 'CREATING NEW NRT INTERFACE ID';
       SELECT pa_interface_id_s.nextval
         into G_NRT_INTERFACE_ID
         FROM dual;

       G_err_stage := 'CREATING NEW FRT INTERFACE ID';
       SELECT pa_interface_id_s.nextval
         into G_AP_FRT_INTERFACE_ID
         FROM dual;

       G_err_stage := 'CREATING NEW VARIANCE INTERFACE ID';
       SELECT pa_interface_id_s.nextval
         into G_AP_VAR_INTERFACE_ID
         FROM dual;

       G_err_stage := 'CREATING NEW ERV VARIANCE INTERFACE ID';
       SELECT pa_interface_id_s.nextval
         into G_AP_ERV_INTERFACE_ID
         FROM dual;

          FETCH Payments_Cur BULK COLLECT INTO
             l_inv_pay_id_tbl,
             l_invoice_id_tbl,
             l_created_by_tbl,
             l_invoice_dist_id_tbl,
             l_cdl_sys_ref3_tbl,
             l_project_id_tbl,
             l_task_id_tbl,
             l_ln_type_lookup_tbl,
             l_exp_type_tbl,
             l_ei_date_tbl,
             l_amount_tbl,
             l_description_tbl,
             l_justification_tbl,
             l_dist_cc_id_tbl,
             l_exp_org_id_tbl,
             l_quantity_tbl,
             l_acct_pay_cc_id_tbl,
             l_gl_date_tbl,
             l_attribute_cat_tbl,
             l_attribute1_tbl,
             l_attribute2_tbl,
             l_attribute3_tbl,
             l_attribute4_tbl,
             l_attribute5_tbl,
             l_attribute6_tbl,
             l_attribute7_tbl,
             l_attribute8_tbl,
             l_attribute9_tbl,
             l_attribute10_tbl,
             l_rec_cur_amt_tbl,
             l_rec_cur_code_tbl,
             l_rec_conv_rate_tbl,
             l_denom_raw_cost_tbl,
             l_denom_cur_code_tbl,
             l_acct_rate_date_tbl,
             l_acct_rate_type_tbl,
             l_acct_exch_rate_tbl,
             l_job_id_tbl,
             l_employee_id_tbl,
             l_vendor_id_tbl,
             l_inv_type_code_tbl,
             l_source_tbl,
             l_org_id_tbl,
             l_invoice_num_tbl,
             l_cdl_sys_ref4_tbl,
             l_po_dist_id_tbl
            ,l_txn_src_tbl
            ,l_user_txn_src_tbl
            ,l_batch_name_tbl
            ,l_interface_id_tbl
            ,l_exp_end_date_tbl
            ,l_txn_status_code_tbl
            ,l_txn_rej_code_tbl
            ,l_bus_grp_id_tbl
            ,l_paid_emp_id_tbl
            ,l_sort_var_tbl
            ,l_reversal_flag_tbl --NEW
            ,l_cancel_flag_tbl --NEW
            ,l_parent_pmt_id_tbl --NEW
            ,l_net_zero_flag_tbl  --NEW
            ,l_sc_xfer_code_tbl
            ,l_adj_exp_item_id_tbl --NEW
            ,l_fc_enabled_tbl  --NEW
            ,l_mrc_exchange_date_tbl
            ,l_fc_document_type_tbl
            ,l_payment_status_flag_tbl
            ,l_si_assts_add_flg_tbl
            ,l_insert_flag_tbl
            ,l_pay_hist_id_tbl
            ,l_prepay_dist_id_tbl   --bug#5514129
            LIMIT v_max_size;

         G_err_stage := 'After fetching Payments_Cur within transfer_pay_to_pa';
         write_log(LOG, G_err_stage);

         IF l_invoice_id_tbl.COUNT <> 0 THEN

            /* get the index of the last invoice being processed within the batch*/
            v_last_inv_index := l_invoice_id_tbl.LAST;

            G_err_stage := 'calling process_pay_logic within transfer_pay_to_pa';
            write_log(LOG, G_err_stage);

            process_pay_logic;

            G_err_stage := 'calling bulk_update_trx_intf within transfer_pay_to_pa';
            write_log(LOG, G_err_stage);

            bulk_update_trx_intf; --Update Prepayment trx

            G_err_stage := 'calling bulk_insert_trx_intf within transfer_pay_to_pa';
            write_log(LOG, G_err_stage);

            bulk_insert_trx_intf;

            G_err_stage := 'After calling bulk_insert_trx_intf within transfer_pay_to_pa';
            write_log(LOG, G_err_stage);

            G_err_stage := 'Before calling transaction import and tiebacks within transfer_pay_to_pa';
            write_log(LOG, G_err_stage);

            IF (v_num_distributions_fetched > 0) THEN

               v_inv_batch_size           := v_num_distributions_fetched - v_num_tax_lines_fetched -
                                             v_num_inv_variance_fetched - v_num_inv_frt_fetched;

              write_log(LOG,'Before calling trx_import for invoices with interface_id:'||G_INTERFACE_ID);
              --Logic to handle IP and AP INVOICES getting interfaced in the same run.Bug#4764470.

             IF (l_ap_inv_flag ='Y' ) THEN

              trans_import('AP INVOICE', G_BATCH_NAME, G_INTERFACE_ID, G_USER_ID);
              tieback_payment_AP_ER('AP INVOICE', G_BATCH_NAME,'PAY', G_INTERFACE_ID);

             END IF;

             IF (l_ip_inv_flag ='Y' ) THEN

              trans_import(L_IP_TRANSACTION_SOURCE, G_BATCH_NAME, G_INTERFACE_ID, G_USER_ID);
              tieback_payment_AP_ER(L_IP_TRANSACTION_SOURCE, G_BATCH_NAME,'PAY', G_INTERFACE_ID);

             ELSIF (l_ap_inv_flag ='N') THEN

              trans_import(G_TRANSACTION_SOURCE, G_BATCH_NAME, G_INTERFACE_ID, G_USER_ID);
              tieback_payment_AP_ER(G_TRANSACTION_SOURCE, G_BATCH_NAME,'PAY', G_INTERFACE_ID);

             END IF;
              --End of logic to handle IP and AP INVOICES getting interfaced in the same run.Bug#4764470.

              IF (nvl(v_num_tax_lines_fetched,0) > 0 AND
                     (G_INVOICE_TYPE IS NULL OR G_INVOICE_TYPE = 'EXPENSE REPORT')) THEN

                  write_log(LOG,'Before calling trx_import for NRTAX for interface_id:'||G_NRT_INTERFACE_ID);
                  v_tax_batch_size           := v_num_tax_lines_fetched;

                  trans_import(G_NRT_TRANSACTION_SOURCE, G_NRT_BATCH_NAME, G_NRT_INTERFACE_ID, G_USER_ID);
                  tieback_payment_AP_ER(G_NRT_TRANSACTION_SOURCE, G_NRT_BATCH_NAME,'PAY', G_NRT_INTERFACE_ID);

              END IF; /* IF (nvl(v_num_tax_lines_fetched,0) > 0*/

              IF (nvl(v_num_inv_variance_fetched,0) > 0) THEN

                  write_log(LOG,'Before calling trx_import for Variance for interface_id:'||G_AP_VAR_INTERFACE_ID);
                  v_var_batch_size           := v_num_inv_variance_fetched;

                  trans_import(G_AP_VAR_TRANSACTION_SOURCE, G_AP_VAR_BATCH_NAME, G_AP_VAR_INTERFACE_ID, G_USER_ID);
                  tieback_payment_AP_ER(G_AP_VAR_TRANSACTION_SOURCE, G_AP_VAR_BATCH_NAME,'PAY', G_AP_VAR_INTERFACE_ID);

              END IF; /* IF (nvl(v_num_inv_variance_lines_fetched,0) > 0*/

              IF (nvl(v_num_inv_erv_fetched,0) > 0) THEN

                  write_log(LOG,'Before calling trx_import for ERV for interface_id:'||G_AP_VAR_INTERFACE_ID);
                  v_var_batch_size           := v_num_inv_erv_fetched;

                  trans_import(G_AP_ERV_TRANSACTION_SOURCE, G_AP_ERV_BATCH_NAME, G_AP_ERV_INTERFACE_ID, G_USER_ID);
                  tieback_payment_AP_ER(G_AP_ERV_TRANSACTION_SOURCE, G_AP_ERV_BATCH_NAME,'PAY', G_AP_ERV_INTERFACE_ID);

              END IF; /* IF (nvl(v_num_inv_erv_lines_fetched,0) > 0*/

              IF (nvl(v_num_inv_frt_fetched,0) > 0) THEN

                  write_log(LOG,'Before calling trx_import for Frt and Misc for interface_id:'||G_AP_FRT_INTERFACE_ID);
                  v_frt_batch_size           := v_num_inv_frt_fetched;

                  trans_import(G_TRANSACTION_SOURCE, G_AP_FRT_BATCH_NAME, G_AP_FRT_INTERFACE_ID, G_USER_ID);
                  tieback_payment_AP_ER(G_TRANSACTION_SOURCE, G_AP_FRT_BATCH_NAME, 'PAY',G_AP_FRT_INTERFACE_ID);

              END IF; /* IF (nvl(v_num_inv_frt_lines_fetched,0) > 0*/

              G_err_stage := 'Before updating the total number of payments processed';
              write_log(LOG, G_err_stage);

              G_NUM_BATCHES_PROCESSED       := G_NUM_BATCHES_PROCESSED + 1;
              G_NUM_INVOICES_PROCESSED      :=  G_NUM_INVOICES_PROCESSED + v_num_invoices_fetched;
              G_NUM_DISTRIBUTIONS_PROCESSED :=  G_NUM_DISTRIBUTIONS_PROCESSED + v_num_distributions_fetched;
              write_log(LOG,'G_NUM_BATCHES_PROCESSED:'||G_NUM_BATCHES_PROCESSED);
              write_log(LOG,'G_NUM_INVOICES_PROCESSED:'||G_NUM_INVOICES_PROCESSED);
              write_log(LOG,'G_NUM_DISTRIBUTIONS_PROCESSED:'||G_NUM_DISTRIBUTIONS_PROCESSED);

        END IF; /* IF (v_num_distributions_fetched > 0) */

        G_err_stage := 'After calling transaction import and tiebacks within transfer_pay_to_pa';
        write_log(LOG, G_err_stage);

        clear_plsql_tables;

        v_num_invoices_fetched       :=0;
        v_num_distributions_fetched  :=0;
        v_num_tax_lines_fetched      :=0;
        v_inv_batch_size             :=0;
        v_tax_batch_size             :=0;
        v_var_batch_size             :=0;
        v_frt_batch_size             :=0;
        v_num_dist_remain            :=0;
        v_num_dist_marked_O          :=0;
        v_num_last_invoice_processed :=0;
        v_last_inv_ER_flag           := 'N';

        G_err_stage:='Before exiting when Payments_Cur is NOTFOUND';
        write_log(LOG,   G_err_stage);

      ELSE

          G_err_stage:='Payments Cursor fetched zero rows into plsql tables. Exiting';
          write_log(LOG,   G_err_stage);
          EXIT;
      END IF; /* l_invoice_id_tbl.COUNT = 0 */

      G_err_stage:='Cursor fetched no more rows. Exiting';
      write_log(LOG,   G_err_stage);
      EXIT WHEN Payments_Cur%NOTFOUND;

   END LOOP; /* While more rows to process is true */

   CLOSE Payments_Cur;


     /*=====================================================*/
     /* PRocess Prepayment Application */
     /*=====================================================*/

     -- Create a new interface ID for the first session

     G_err_stage := 'Before  opening Prepay_Cur within transfer_pay_to_pa';
     write_log(LOG, G_err_stage);

     OPEN Prepay_Cur;

     G_err_stage := 'After opening Prepay_Cur within transfer_pay_to_pa';
     write_log(LOG, G_err_stage);

     WHILE (v_all_done = 0) LOOP

       clear_plsql_tables;

       G_err_stage := 'CREATING NEW PREPAYMENT INTERFACE ID';
       SELECT pa_interface_id_s.nextval
         into G_PREPAY_INTERFACE_ID
         FROM dual;

       G_err_stage := 'Before Fetching records for prepayment application within transfer_pay_to_pa';
       write_log(LOG, G_err_stage);

          FETCH Prepay_Cur BULK COLLECT INTO
             l_invoice_id_tbl,
             l_created_by_tbl,
             l_invoice_dist_id_tbl,
             l_cdl_sys_ref3_tbl,
             l_project_id_tbl,
             l_task_id_tbl,
             l_ln_type_lookup_tbl,
             l_exp_type_tbl,
             l_ei_date_tbl,
             l_amount_tbl,
             l_description_tbl,
             l_justification_tbl,
             l_dist_cc_id_tbl,
             l_exp_org_id_tbl,
             l_quantity_tbl,
             l_acct_pay_cc_id_tbl,
             l_gl_date_tbl,
             l_attribute_cat_tbl,
             l_attribute1_tbl,
             l_attribute2_tbl,
             l_attribute3_tbl,
             l_attribute4_tbl,
             l_attribute5_tbl,
             l_attribute6_tbl,
             l_attribute7_tbl,
             l_attribute8_tbl,
             l_attribute9_tbl,
             l_attribute10_tbl,
             l_rec_cur_amt_tbl,
             l_rec_cur_code_tbl,
             l_rec_conv_rate_tbl,
             l_denom_raw_cost_tbl,
             l_denom_cur_code_tbl,
             l_acct_rate_date_tbl,
             l_acct_rate_type_tbl,
             l_acct_exch_rate_tbl,
             l_job_id_tbl,
             l_employee_id_tbl,
             l_vendor_id_tbl,
             l_inv_type_code_tbl,
             l_source_tbl,
             l_org_id_tbl,
             l_invoice_num_tbl,
             l_inv_pay_id_tbl,  --l_cdl_sys_ref4_tbl
             l_po_dist_id_tbl
            ,l_txn_src_tbl
            ,l_user_txn_src_tbl
            ,l_batch_name_tbl
            ,l_interface_id_tbl
            ,l_exp_end_date_tbl
            ,l_txn_status_code_tbl
            ,l_txn_rej_code_tbl
            ,l_bus_grp_id_tbl
            ,l_paid_emp_id_tbl
            ,l_sort_var_tbl
            ,l_reversal_flag_tbl --NEW
            ,l_cancel_flag_tbl --NEW
            ,l_parent_pmt_id_tbl --NEW
            ,l_net_zero_flag_tbl  --NEW
            ,l_sc_xfer_code_tbl
            ,l_adj_exp_item_id_tbl --NEW
            ,l_fc_enabled_tbl  --NEW
            ,l_mrc_exchange_date_tbl
            ,l_fc_document_type_tbl
            ,l_si_assts_add_flg_tbl
            ,l_insert_flag_tbl
            ,l_pay_hist_id_tbl
            ,l_prepay_dist_id_tbl   --bug#5514129
            LIMIT v_max_size;


         G_err_stage := 'After fetching Prepay_Cur within transfer_pay_to_pa';
         write_log(LOG, G_err_stage);

         IF l_invoice_id_tbl.COUNT <> 0 THEN

            /* get the index of the last invoice being processed within the batch*/
            v_last_inv_index := l_invoice_id_tbl.LAST;

            G_err_stage := 'calling process_pay_logic for PREPAYMENTS within transfer_pay_to_pa';
            write_log(LOG, G_err_stage);

            process_pay_logic;

            G_err_stage := 'calling bulk_insert_trx_intf within transfer_pay_to_pa';
            write_log(LOG, G_err_stage);

            bulk_insert_trx_intf;

            G_err_stage := 'After calling bulk_insert_trx_intf within transfer_pay_to_pa';
            write_log(LOG, G_err_stage);

            G_err_stage := 'Before calling transaction import and tiebacks within transfer_pay_to_pa';
            write_log(LOG, G_err_stage);

            IF (v_num_distributions_fetched > 0) THEN

              write_log(LOG,'Before calling trx_import for Prepayment appl inv with interface_id:'||G_PREPAY_INTERFACE_ID);
              trans_import(G_TRANSACTION_SOURCE, G_PREPAY_BATCH_NAME, G_PREPAY_INTERFACE_ID, G_USER_ID);

              IF l_ap_prepay_tax_flag ='Y' THEN
                trans_import(G_NRT_TRANSACTION_SOURCE, G_PREPAY_BATCH_NAME, G_PREPAY_INTERFACE_ID, G_USER_ID);
              END IF;

              IF l_ap_prepay_var_flag ='Y' THEN
                trans_import(G_AP_VAR_TRANSACTION_SOURCE, G_PREPAY_BATCH_NAME, G_PREPAY_INTERFACE_ID, G_USER_ID);
              END IF;
              IF l_ap_prepay_erv_flag ='Y' THEN
                trans_import(G_AP_ERV_TRANSACTION_SOURCE, G_PREPAY_BATCH_NAME, G_PREPAY_INTERFACE_ID, G_USER_ID);
              END IF;

              tieback_payment_AP_ER(G_TRANSACTION_SOURCE, G_PREPAY_BATCH_NAME,'APPPAY', G_PREPAY_INTERFACE_ID);
              IF l_ap_prepay_tax_flag ='Y' THEN
                tieback_payment_AP_ER(G_NRT_TRANSACTION_SOURCE, G_PREPAY_BATCH_NAME,'APPPAY', G_PREPAY_INTERFACE_ID);
              END IF;
              IF l_ap_prepay_var_flag ='Y' THEN
                tieback_payment_AP_ER(G_AP_VAR_TRANSACTION_SOURCE, G_PREPAY_BATCH_NAME,'APPPAY', G_PREPAY_INTERFACE_ID);
              END IF;
              IF l_ap_prepay_erv_flag ='Y' THEN
                tieback_payment_AP_ER(G_AP_ERV_TRANSACTION_SOURCE, G_PREPAY_BATCH_NAME,'APPPAY', G_PREPAY_INTERFACE_ID);
              END IF;

              G_err_stage := 'Before updating the total number of prepayment appl processed';
              write_log(LOG, G_err_stage);

              G_NUM_BATCHES_PROCESSED       := G_NUM_BATCHES_PROCESSED + 1;
              G_NUM_INVOICES_PROCESSED      :=  G_NUM_INVOICES_PROCESSED + v_num_invoices_fetched;
              G_NUM_DISTRIBUTIONS_PROCESSED :=  G_NUM_DISTRIBUTIONS_PROCESSED + v_num_distributions_fetched;
              write_log(LOG,'G_NUM_BATCHES_PROCESSED:'||G_NUM_BATCHES_PROCESSED);
              write_log(LOG,'G_NUM_INVOICES_PROCESSED:'||G_NUM_INVOICES_PROCESSED);
              write_log(LOG,'G_NUM_DISTRIBUTIONS_PROCESSED:'||G_NUM_DISTRIBUTIONS_PROCESSED);

           END IF; /* IF (v_num_distributions_fetched > 0) */

           G_err_stage := 'After calling transaction import and tiebacks within transfer_pay_to_pa';
           write_log(LOG, G_err_stage);

           clear_plsql_tables;

           v_num_invoices_fetched       :=0;
           v_num_distributions_fetched  :=0;

           G_err_stage:='Before exiting when Prepay_Cur is NOTFOUND';
           write_log(LOG,   G_err_stage);

         ELSE

          G_err_stage:='Prepay Cursor fetched zero rows into plsql tables. Exiting';
          write_log(LOG,   G_err_stage);
          EXIT;
         END IF; /* l_invoice_id_tbl.COUNT = 0 */

         G_err_stage:='Cursor fetched no more rows. Exiting';
         write_log(LOG,   G_err_stage);
         EXIT WHEN Prepay_Cur%NOTFOUND;

      END LOOP; /* While more rows to process is true */

      CLOSE Prepay_Cur;


EXCEPTION
    WHEN OTHERS THEN

         G_err_stack := v_old_stack;
         IF Payments_cur%ISOPEN THEN
           CLOSE Invoice_Cur;
         END IF ;

         IF Prepay_cur%ISOPEN THEN
           CLOSE Prepay_Cur;
         END IF ;

         G_err_code := SQLCODE;
         RAISE;

END transfer_pay_to_pa;

/*---------------------------Tieback to AP Phase----------------------------*/
PROCEDURE tieback_payment_AP_ER(
   p_transaction_source IN pa_transaction_interface.transaction_source%TYPE,
   p_batch_name  IN pa_transaction_interface.batch_name%TYPE,
   p_batch_type  IN VARCHAR2,
   p_interface_id IN pa_transaction_interface.interface_id%TYPE) IS

   l_assets_addflag          VARCHAR2(1):=NULL;
   l_prev_assets_addflag     VARCHAR2(1):=NULL;
   l_project_id             NUMBER :=0;
   l_pa_addflag             VARCHAR2(1):=NULL;
   l_prev_proj_id           NUMBER :=0;

   l_sys_ref1_tbl           PA_PLSQL_DATATYPES.Char15TabTyp;
   l_sys_ref2_tbl           PA_PLSQL_DATATYPES.Char15TabTyp;
   l_sys_ref4_tbl           PA_PLSQL_DATATYPES.Char15TabTyp;
   l_sys_ref5_tbl           PA_PLSQL_DATATYPES.IdTabTyp;
   l_txn_src_tbl            PA_PLSQL_DATATYPES.Char30TabTyp;
   l_batch_name_tbl         PA_PLSQL_DATATYPES.Char50TabTyp;
   l_interface_id_tbl       PA_PLSQL_DATATYPES.IdTabTyp;
   l_txn_status_code_tbl    PA_PLSQL_DATATYPES.Char2TabTyp;
   l_project_id_tbl            PA_PLSQL_DATATYPES.IdTabTyp;
   l_pa_addflag_tbl         PA_PLSQL_DATATYPES.CHAR1TabTyp;
   l_assets_addflag_tbl     PA_PLSQL_DATATYPES.CHAR1TabTyp;

   CURSOR txn_intf_rec (p_txn_src       IN VARCHAR2,
                        p_batch_name    IN VARCHAR2,
                        p_interface_id  IN NUMBER) IS
      SELECT cdl_system_reference1
            ,cdl_system_reference2
            ,cdl_system_reference4
            ,cdl_system_reference5
            ,transaction_source
            ,batch_name
            ,interface_id
            ,transaction_status_code
            ,project_id
            ,l_pa_addflag
            ,l_assets_addflag
        FROM pa_transaction_interface_all txnintf
       WHERE txnintf.transaction_source = p_txn_src
         AND txnintf.batch_name         = p_batch_name
         AND txnintf.interface_id       = p_interface_id;

   PROCEDURE clear_plsql_tables IS

      v_status   VARCHAR2(15);

   BEGIN

      G_err_stage:='Clearing PLSQL tables in payment tieback';
      write_log(LOG,   G_err_stage);

      l_sys_ref1_tbl.delete;
      l_sys_ref2_tbl.delete;
      l_sys_ref4_tbl.delete;
      l_sys_ref5_tbl.delete;
      l_txn_src_tbl.delete;
      l_batch_name_tbl.delete;
      l_interface_id_tbl.delete;
      l_txn_status_code_tbl.delete;
      l_project_id_tbl.delete;
      l_pa_addflag_tbl.delete;
      l_assets_addflag_tbl.delete;

   END clear_plsql_tables;

   PROCEDURE process_tieback IS

      v_status   VARCHAR2(15);

   BEGIN

      G_err_stage:='Within process_tieback of payment tieback';
      write_log(LOG,   G_err_stage);

      FOR i IN l_sys_ref1_tbl.FIRST..l_sys_ref1_tbl.LAST LOOP

         /* If transaction import stamps the record to be 'A' then
            update pa_addition_flag of invoice distribution to 'Y'.
            If transaction import leaves the record to be 'P' then
            update pa_addition_flag of invoice distribution to 'N'.
            If transaction import stamps the record to be 'R' then
            update pa_addition_flag of invoice distribution to 'N'.*/

         write_log(LOG,'Tying invoice_id: '||l_sys_ref2_tbl(i)||
                       'Payment Id:  '||l_sys_ref4_tbl(i)||
                       'dist id:  '||l_sys_ref5_tbl(i)||
                       'trc src:   '||l_txn_src_tbl(i));

         IF l_txn_status_code_tbl(i) = 'A' THEN
               l_pa_addflag_tbl(i) := 'Y';
         ELSIF l_txn_status_code_tbl(i) = 'P' THEN
               l_pa_addflag_tbl(i) :='N';
         ELSIF l_txn_status_code_tbl(i) = 'R' THEN
               l_pa_addflag_tbl(i) := 'N';
         END IF;

         IF G_PROJECT_ID IS NOT NULL THEN

            IF G_Assets_Addition_flag = 'P' THEN
               l_assets_addflag_tbl(i) := 'P';
            ELSE
               l_assets_addflag_tbl(i) := 'X';
            END IF;

         ELSIF G_PROJECT_ID IS NULL THEN

            IF l_project_id_tbl(i) <> l_prev_proj_id THEN

               G_err_stage:='Selecting assets addition flag within payment tieback';
               write_log(LOG,   G_err_stage);

               SELECT decode(PTYPE.Project_Type_Class_Code,'CAPITAL','P','X')
                 INTO l_assets_addflag_tbl(i)
                 FROM pa_project_types_all PTYPE,
                      pa_projects_all PROJ
                WHERE PTYPE.Project_Type = PROJ.Project_Type
                  AND (PTYPE.org_id = PROJ.org_id OR
                       PROJ.org_id is null)
                  AND PROJ.Project_Id = l_project_id_tbl(i);

                l_prev_proj_id := l_project_id_tbl(i);
		l_prev_assets_addflag := l_assets_addflag_tbl(i);

            ELSE
               l_assets_addflag_tbl(i) := l_prev_assets_addflag;
            END IF;

         END IF;

      END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
         G_err_stage:= 'Failed during process tieback of payment tieback';
         write_log(LOG,   G_err_stage);
         G_err_code   := SQLCODE;
         raise;

   END process_tieback;


   PROCEDURE bulk_update_txn_intf(l_batch in VARCHAR2) IS

     v_status VARCHAR2(15);

   BEGIN

      G_err_stage:=('Within bulk update of payment tieback');
      write_log(LOG,   G_err_stage);

     IF l_batch = 'APPPAY' THEN --Prepayment Appl batch

      FORALL i IN l_sys_ref1_tbl.FIRST..l_sys_ref1_tbl.LAST
         UPDATE ap_prepay_app_dists dist
            SET dist.pa_addition_flag         = l_pa_addflag_tbl(i)
          WHERE dist.prepay_app_dist_id       = l_sys_ref4_tbl(i)
            AND dist.invoice_distribution_id  = l_sys_ref5_tbl(i)
            AND dist.pa_addition_flag         = 'O';

     ELSE

      FORALL i IN l_sys_ref1_tbl.FIRST..l_sys_ref1_tbl.LAST
         UPDATE ap_payment_hist_dists paydist
            SET paydist.pa_addition_flag         = l_pa_addflag_tbl(i)
          WHERE paydist.invoice_payment_id       = l_sys_ref4_tbl(i)
            AND paydist.invoice_distribution_id  = l_sys_ref5_tbl(i)
            AND paydist.pa_addition_flag         = 'O';


      IF l_batch <> 'APDISC' THEN --Payment Discount batch

        FORALL i IN l_sys_ref1_tbl.FIRST..l_sys_ref1_tbl.LAST
           UPDATE ap_invoice_distributions_all dist
              SET dist.assets_addition_flag      = decode(l_assets_addflag_tbl(i),'P','P',dist.assets_addition_flag)
            WHERE dist.invoice_distribution_id = l_sys_ref5_tbl(i) ;
       END IF;

     END IF;

   EXCEPTION
      WHEN OTHERS THEN
         G_err_stage:= 'Failed during bulk update of payment tieback';
         write_log(LOG,   G_err_stage);
         G_err_code   := SQLCODE;
         raise;

   END bulk_update_txn_intf;

   BEGIN

      /* Main logic of tieback starts here */
      G_err_stage:='Within main logic of tieback';
      write_log(LOG,   G_err_stage);

      clear_plsql_tables;

      G_err_stage:='Opening txn_intf_rec';
      write_log(LOG,   G_err_stage);

      OPEN txn_intf_rec(p_transaction_source
                       ,p_batch_name
                       ,p_interface_id);

      G_err_stage:='Fetching txn_intf_rec';
      write_log(LOG,   G_err_stage);

      FETCH txn_intf_rec BULK COLLECT INTO
          l_sys_ref1_tbl
         ,l_sys_ref2_tbl
         ,l_sys_ref4_tbl
         ,l_sys_ref5_tbl
         ,l_txn_src_tbl
         ,l_batch_name_tbl
         ,l_interface_id_tbl
         ,l_txn_status_code_tbl
         ,l_project_id_tbl
         ,l_pa_addflag_tbl
         ,l_assets_addflag_tbl;

      IF l_sys_ref1_tbl.COUNT <> 0 THEN

         process_tieback;

         bulk_update_txn_intf(p_batch_type);

         clear_plsql_tables;

      END IF;

      CLOSE txn_intf_rec;

EXCEPTION
   WHEN OTHERS THEN

      IF txn_intf_rec%ISOPEN THEN
         CLOSE txn_intf_rec;
      END IF;

      G_err_code := SQLCODE;
      RAISE;

END tieback_payment_AP_ER;


   PROCEDURE process_adjustments (p_record_type                 IN Varchar2,
                                  p_document_header_id          IN number,/*Added this for 6945767 */
                                  p_document_distribution_id    IN number,
                                  p_document_payment_id         IN number DEFAULT NULL,
                                  p_current_index               IN number,
			  	  p_last_index			IN OUT NOCOPY number) IS
       l_status3 VARCHAR2(30);
       j NUMBER := 0; --Index variable for creating reversal EI's --NEW
       l_xface_rec_exists_flg VARCHAR(1):='N';  --NEW
       l_fc_enabled   VARCHAR2(1) ;
       l_process_adjustments    Number := 0 ;
       l_all_reversed_cnt       Number := 0 ;
       l_not_reversed_cnt       Number := 0 ;


       CURSOR c_get_latest_ei IS
              SELECT ei.expenditure_item_id
                    , ei.project_id project_id
                    , ei.task_id  task_id
                    , ei.expenditure_item_date expenditure_item_date
                    , ei.expenditure_type expenditure_type
                    , ei.quantity quantity
                    , ei.raw_cost raw_cost
                    , nvl(ei.cost_distributed_flag,'N') cost_distributed_flag
                    , ei.organization_id organization_id
                    , ei.override_to_organization_id override_to_organization_id
                    , ei.receipt_currency_amount receipt_currency_amount
                    , ei.receipt_currency_code receipt_currency_code
                    , ei.receipt_exchange_rate receipt_exchange_rate
                    , ei.denom_raw_cost denom_raw_cost
                    , ei.denom_currency_code denom_currency_code
                    , ei.acct_rate_date acct_rate_date
                    , ei.acct_rate_type acct_rate_type
                    , ei.acct_exchange_rate acct_exchange_rate
                    , ei.acct_raw_cost acct_raw_cost
                    , ei.acct_exchange_rounding_limit acct_exchange_rounding_limit
                    , ei.attribute_category
                    , ei.attribute1
                    , ei.attribute2
                    , ei.attribute3
                    , ei.attribute4
                    , ei.attribute5
                    , ei.attribute6
                    , ei.attribute7
                    , ei.attribute8
                    , ei.attribute9
                    , ei.attribute10
                    , ei.org_id org_id
                    , get_cdl_ccid(ei.expenditure_item_id,'D') dr_code_combination_id
                    , get_cdl_ccid(ei.expenditure_item_id,'C') cr_code_combination_id
                    , Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(ei.project_id,'STD') orig_fc_enabled
                    , nvl(cdl.transfer_status_code,'P') transfer_status_code
                    ,ei.document_type
                    ,ei.document_distribution_type
                    ,ei.document_header_id
                    ,ei.document_distribution_id
                    ,ei.document_payment_id
                    ,ei.document_line_number
                    ,cdl.system_reference5 cdl_sys_ref5 --to get the rcv_sub_leger_id of parent Rcv txn
              FROM   pa_cost_distribution_lines_all cdl,
                     pa_expenditure_items_all ei
              WHERE  cdl.expenditure_item_id (+) = ei.expenditure_item_id
                AND  nvl(cdl.reversed_flag, 'N') = 'N'
                AND    ei.document_distribution_id = p_document_distribution_id /*Added this for 6945767 */
                AND   ei.system_linkage_function in ('VI','ER')
                AND   ei.document_header_id = p_document_header_id /*Added this for 6945767 */
		AND  nvl(cdl.line_type,'R') = 'R' --Bug 5373272 : 'C' and 'D' lines are incorrectly getting processed
                AND  cdl.line_num_reversed is null
                AND  (( p_record_type  = 'AP_INVOICE'
                AND    ei.transaction_source in ('AP INVOICE','AP VARIANCE','AP EXPENSE','AP NRTAX'))
                 OR  ( p_record_type = 'PO_RECEIPT'
                AND    ei.transaction_source IN ('PO RECEIPT', 'PO RECEIPT PRICE ADJ'))
                 OR  ( p_record_type = 'PO_RECEIPT_TAX'
                AND    ei.transaction_source in ('PO RECEIPT NRTAX'))
                 OR  ( p_record_type = 'AP_DISCOUNTS'
                AND    ei.document_payment_id = p_document_payment_id
                AND    ei.transaction_source in ('AP DISCOUNTS','AP INVOICE','AP NRTAX'))
                 OR  ( p_record_type = 'AP_PAYMENT'
                AND    ei.document_payment_id = p_document_payment_id
                AND    ei.transaction_source in ('AP INVOICE','AP EXPENSE','AP NRTAX','AP VARIANCE')))
              AND    nvl(ei.net_zero_adjustment_flag,'N') <> 'Y'
              ORDER BY  ei.cost_distributed_flag, ei.expenditure_item_id;


   BEGIN

                  write_log(LOG, 'In Process Adjustments');
                  write_log(LOG, 'p_current_index = '||p_current_index);
                  write_log(LOG, 'p_last_index = '||p_last_index);

                  FOR c_latest_ei_rec in c_get_latest_ei LOOP
                      l_xface_rec_exists_flg:= 'Y'; -- Parent is in projects

                      write_log(LOG, 'For each record in the cursor');

                      IF  ( c_latest_ei_rec.cost_distributed_flag = 'N' AND
                           l_process_adjustments = 0) THEN

                              -- Reversal will not be interfaced since adjusted parent EI's have not been cost distributed
                              write_log(LOG, 'Adjustment not cost distributed in Projects');
                              l_txn_status_code_tbl(p_current_index) := 'R';
                              l_txn_rej_code_tbl(p_current_index) := 'PA_EI_NOT_COST_DISTRIBUTED';

                              EXIT;

                      ELSIF  c_latest_ei_rec.transfer_status_code = 'V' THEN

                          l_adj_exp_item_id_tbl(p_current_index):= c_latest_ei_rec.expenditure_item_id;
                          /* Bug 8984546 -- Commented following line
                          l_ei_date_tbl(p_current_index) := c_latest_ei_rec.expenditure_item_date; */ -- copy the source ei date

                              EXIT ;


                     ELSE
                          -- This indicates that there are multiple EI adjustments for the reversed distribution lines
                          -- This could happen if the EI was SPLIT across different projects
                          -- Incase there are multiple EI adjustments for single distribution we will insert multiple
                          -- records in the interface table each corresponding to the adjusted EI.
                          --
                          -- The following section will insert new table records at the end of the fetched table array
                          -- example : If bulk fetch populates 200 rows in PLSQL table array, the following section
                          --           will insert record in the PLSQL array from 201+ onwards

                          write_log(LOG, 'There are many adjustments that needs to be reversed in projects');
                      -- Set the net_zero_flag and the create adj record flag
                         l_net_zero_flag_tbl(p_current_index) := 'Y';
                         l_insert_flag_tbl(p_current_index)   := 'A';
                         l_fc_document_type_tbl(p_current_index) := 'NOT';
                         l_adj_exp_item_id_tbl(p_current_index):= 0; -- Skip the EI Date validation in Trx Imp.
                    -- Set the sc_xfer_code column on the xface table.

                          IF l_process_adjustments = 0 THEN

                                j := p_last_index+1;
                          ELSE

                                j := j + 1;
                          END IF;

                  write_log(LOG, 'j = '||j);
                          l_txn_src_tbl(j)        := l_txn_src_tbl(p_current_index);
                          l_user_txn_src_tbl(j)   := l_user_txn_src_tbl(p_current_index);
                          l_batch_name_tbl(j)     := l_batch_name_tbl(p_current_index);
                          l_project_id_tbl(j)     := c_latest_ei_rec.project_id;
                          l_task_id_tbl(j)        := c_latest_ei_rec.task_id;
                          l_exp_type_tbl(j)       := c_latest_ei_rec.expenditure_type;
                          l_exp_end_date_tbl(j)   := l_exp_end_date_tbl(p_current_index);
                          l_ei_date_tbl(j)        := c_latest_ei_rec.expenditure_item_date;
                          l_amount_tbl(j)         := c_latest_ei_rec.acct_raw_cost * -1;
                          l_quantity_tbl(j)       := nvl(c_latest_ei_rec.quantity,0) * -1;
                          l_description_tbl(j)    := l_description_tbl(p_current_index) ;
                          l_dist_cc_id_tbl(j)     := c_latest_ei_rec.dr_code_combination_id;
                          l_acct_pay_cc_id_tbl(j) := c_latest_ei_rec.cr_code_combination_id;
                          l_rec_cur_amt_tbl(j)    := c_latest_ei_rec.receipt_currency_amount * -1;
                          l_rec_cur_code_tbl(j)   := c_latest_ei_rec.receipt_currency_code;
                          l_rec_conv_rate_tbl(j)  := c_latest_ei_rec.receipt_exchange_rate;
                          l_denom_raw_cost_tbl(j) := c_latest_ei_rec.denom_raw_cost * -1;
                          l_denom_cur_code_tbl(j) := c_latest_ei_rec.denom_currency_code;
                          l_acct_rate_date_tbl(j) := c_latest_ei_rec.acct_rate_date;
                          l_acct_rate_type_tbl(j) := c_latest_ei_rec.acct_rate_type;
                          l_acct_exch_rate_tbl(j) := c_latest_ei_rec.acct_exchange_rate;
                          l_attribute_cat_tbl(j)  := c_latest_ei_rec.attribute_category;
                          l_attribute1_tbl(j)     := c_latest_ei_rec.attribute1;
                          l_attribute2_tbl(j)     := c_latest_ei_rec.attribute2;
                          l_attribute3_tbl(j)     := c_latest_ei_rec.attribute3;
                          l_attribute4_tbl(j)     := c_latest_ei_rec.attribute4;
                          l_attribute5_tbl(j)     := c_latest_ei_rec.attribute5;
                          l_attribute6_tbl(j)     := c_latest_ei_rec.attribute6;
                          l_attribute7_tbl(j)     := c_latest_ei_rec.attribute7;
                          l_attribute8_tbl(j)     := c_latest_ei_rec.attribute8;
                          l_attribute9_tbl(j)     := c_latest_ei_rec.attribute9;
                          l_attribute10_tbl(j)    := c_latest_ei_rec.attribute10;
                          l_org_id_tbl(j)         := nvl(c_latest_ei_rec.organization_id,c_latest_ei_rec.override_to_organization_id);
                          l_exp_org_id_tbl(j)     := c_latest_ei_rec.override_to_organization_id;
                          l_vendor_id_tbl(j)      := l_vendor_id_tbl(p_current_index);

                          IF p_record_type like 'PO_RECEIPT%' THEN
                            l_po_head_id_tbl(j)        := c_latest_ei_rec.document_header_id;
                            l_po_dist_id_tbl(j)        := c_latest_ei_rec.document_line_number;
                            l_rcv_txn_id_tbl(j)        := c_latest_ei_rec.document_distribution_id;
                            l_rcv_sub_ledger_id_tbl(j) := to_number(c_latest_ei_rec.cdl_sys_ref5);
                            l_dest_typ_code_tbl(j)     := c_latest_ei_rec.document_type;
                            l_trx_type_tbl(j)          := c_latest_ei_rec.document_distribution_type;
                            l_rcv_acct_evt_id_tbl(j)   := l_rcv_acct_evt_id_tbl(p_current_index);
                            l_acct_raw_cost_tbl(j)     := c_latest_ei_rec.acct_raw_cost * -1;
                            l_exp_cst_rt_flg_tbl(j)    := l_exp_cst_rt_flg_tbl(p_current_index); -- Was outside if causing 1403 error for Inv.#5351431
                            IF p_record_type =  'PO_RECEIPT' THEN
                              l_record_type_tbl(j)       := 'RECEIPT';
                            ELSE
                              l_record_type_tbl(j)       := 'RCVTAX';
                            END IF;
                              l_entered_nr_tax_tbl(j)    := 0;
                              l_pa_add_flag_tbl(j)       := 'O';
                          ELSE
                            l_invoice_id_tbl(j)     := l_invoice_id_tbl(p_current_index);
                            l_invoice_dist_id_tbl(j):= l_invoice_dist_id_tbl(p_current_index); -- R12 funds management Uptake
                            l_cdl_sys_ref4_tbl(j)   := l_cdl_sys_ref4_tbl(p_current_index);
                            l_cdl_sys_ref3_tbl(j)   := l_cdl_sys_ref3_tbl(p_current_index);
                            l_invoice_num_tbl(j)    := l_invoice_num_tbl(p_current_index);
                            l_inv_type_code_tbl(j)  := c_latest_ei_rec.document_type;
                            l_ln_type_lookup_tbl(j) := c_latest_ei_rec.document_distribution_type;
                          END IF;

                          IF p_record_type in ('AP_DISCOUNTS','AP_PAYMENT')  THEN
                            l_inv_pay_id_tbl(j)     := c_latest_ei_rec.document_payment_id;
                            l_pay_hist_id_tbl(j)    := c_latest_ei_rec.cdl_sys_ref5;
                          END IF;

                          l_gl_date_tbl(j)        := l_gl_date_tbl(p_current_index);
                          l_employee_id_tbl(j)    := l_employee_id_tbl(p_current_index);
                          l_bus_grp_id_tbl(j)     := l_bus_grp_id_tbl(p_current_index);
                          l_txn_status_code_tbl(j):= l_txn_status_code_tbl(p_current_index);
                          l_txn_rej_code_tbl(j)   := l_txn_rej_code_tbl(p_current_index);
                          l_interface_id_tbl(j)   := l_interface_id_tbl(p_current_index);
                          l_adj_exp_item_id_tbl(j):= c_latest_ei_rec.expenditure_item_id;
                          l_net_zero_flag_tbl(j)  := 'N';
                          l_sc_xfer_code_tbl(j)   := 'P';
                          l_si_assts_add_flg_tbl(j) := 'T'; --For Adjustments done in PA
                          l_insert_flag_tbl(j)   := 'Y';

                          write_log(LOG, 'Adjustment records populated into the PL/SQL table');

                          --
                          -- This section is to ensure that the commitments are relieved and actuals
                          -- are funds checked.
                          --
                          If l_fc_enabled_tbl(p_current_index) = 'Y' AND   c_latest_ei_rec.orig_fc_enabled = 'N' THEN
                              l_fc_document_type_tbl(j) := 'CMT';
                          ELSIF l_fc_enabled_tbl(p_current_index) = 'Y' AND   c_latest_ei_rec.orig_fc_enabled = 'Y' THEN
                              l_fc_document_type_tbl(j) := 'ALL';
                          ELSIF l_fc_enabled_tbl(p_current_index) = 'N' AND   c_latest_ei_rec.orig_fc_enabled = 'N' THEN
                              l_fc_document_type_tbl(j) := 'NOT';
                          ELSIF l_fc_enabled_tbl(p_current_index) = 'N' AND   c_latest_ei_rec.orig_fc_enabled = 'Y' THEN
                              l_fc_document_type_tbl(j) := 'ACT';
                          END IF ;

                          l_process_adjustments  := 1 ;

                  write_log(LOG, 'p_current_index = '||p_current_index);
                    END IF; --End of rowcount=0
                    write_log(LOG, 'Done with processing reversals');

                 END LOOP; --End of cursor c_get_latest_ei

                 IF j>= p_last_index THEN

                 -- Some adjustments were created.
                 p_last_index := j;
                 write_log(LOG, 'p_last_index = '||p_last_index);

                 ELSIF l_xface_rec_exists_flg = 'N' THEN --Parent is not in PA/or All the adjustments got reversed.

                write_log(LOG, 'Setting the netzero flag  adjustment records..');
                   -- Logic for interfacing both the parent and the child (netzero) in the same run.

                  IF l_rev_parent_dist_id_tbl.exists(1) THEN
                    FOR i in l_rev_parent_dist_id_tbl.first..l_rev_parent_dist_id_tbl.last LOOP

                      IF (l_rev_parent_dist_id_tbl(i) = p_document_distribution_id OR
                        l_rev_parent_dist_id_tbl(i) = p_document_payment_id) THEN

                       IF l_inv_pay_id_tbl.EXISTS(p_current_index) THEN
                        IF l_reversal_flag_tbl(p_current_index) = 'R' THEN
                        -- If the reversal is for invoice distributions then store the reversed child inv dist id ..Bug# 5408748
                          l_rev_child_dist_id_tbl(i):= l_invoice_dist_id_tbl(p_current_index);
                        ELSE
                        -- If the reversal is for payment distributions then store the reversed child payment id ..Bug# 5408748
                          l_rev_child_dist_id_tbl(i):= l_inv_pay_id_tbl(p_current_index);
                        END IF;

                       ELSE
                        l_rev_child_dist_id_tbl(i):= l_invoice_dist_id_tbl(p_current_index);
                       END IF;
                        l_net_zero_flag_tbl(l_rev_parent_dist_ind_tbl(i)) := 'Y'; -- Set the parent netzero_flag
                        l_insert_flag_tbl(p_current_index)   := 'U';  -- update adjustment record
                        l_ei_date_tbl(p_current_index) := l_ei_date_tbl(l_rev_parent_dist_ind_tbl(i)); -- Set the reversal dist ei date same as parent's.
                        write_log(LOG, 'Parent dist ='||l_rev_parent_dist_id_tbl(i)||' Child dist = '||l_rev_child_dist_id_tbl(i));

                      END IF;

                    END LOOP;
                 END IF;

         -- Handle the corner case where the project adjustments got reversed in an earlier run, but the ap reversal was rejected.
         -- This section brings in the ap reversal as a netzero pair rather than a standalone reversal.Bug#5064930.

            IF l_insert_flag_tbl(p_current_index) <> 'U' THEN

                 write_log(LOG, 'Selecting the count of adjusted expenditures');

                 SELECT  sum(decode(ei.net_zero_adjustment_flag,'N',1,0)),count(*)
                 INTO   l_not_reversed_cnt,l_all_reversed_cnt
                 FROM   pa_expenditure_items_all ei
                 /*Added this for 6945767 */
                 WHERE  ei.document_distribution_id = p_document_distribution_id
                 AND   ei.document_header_id = p_document_header_id /*Added this for 6945767 */
                 AND  (( p_record_type  = 'AP_INVOICE'
                 -- AND    ei.document_distribution_id = p_document_distribution_id
                 AND    ei.transaction_source in ('AP INVOICE','AP VARIANCE','AP EXPENSE','AP NRTAX'))
                  OR  ( p_record_type = 'PO_RECEIPT'
                 --AND    ei.document_distribution_id = p_document_distribution_id
                 AND    ei.transaction_source IN ('PO RECEIPT', 'PO RECEIPT PRICE ADJ'))
                  OR  ( p_record_type = 'PO_RECEIPT_TAX'
                 --AND    ei.document_distribution_id = p_document_distribution_id
                 AND    ei.transaction_source in ('PO RECEIPT NRTAX'))
                  OR  ( p_record_type = 'AP_DISCOUNTS'
                 --AND    ei.document_distribution_id = p_document_distribution_id
                 AND    ei.document_payment_id = p_document_payment_id
                 AND    ei.transaction_source in ('AP DISCOUNTS','AP INVOICE','AP NRTAX'))
                  OR  ( p_record_type = 'AP_PAYMENT'
                 --AND    ei.document_distribution_id = p_document_distribution_id
                 AND    ei.document_payment_id = p_document_payment_id
                 AND    ei.transaction_source in ('AP INVOICE','AP EXPENSE','AP VARIANCE','AP NRTAX'))) ;

               IF (l_all_reversed_cnt > 0 and l_not_reversed_cnt = 0 ) THEN

                 write_log(LOG, 'Setting the netzero pair logic for the reversal distribution ='||p_document_distribution_id);
                      -- Set the net_zero_flag and the create adj record flag
                         l_net_zero_flag_tbl(p_current_index) := 'Y';
                         l_insert_flag_tbl(p_current_index)   := 'A';

               END IF;

            END IF;
          END IF;

   EXCEPTION
      WHEN OTHERS THEN
          write_log(LOG,'Failed reversal processing');
          G_err_code   := SQLCODE;
                   write_log(LOG, 'Error Code is  '||SQLCODE);
                   write_log(LOG, 'Error Message is  '||SUBSTR(SQLERRM, 1, 200));
                   write_log(LOG, 'Error Message is  '||SUBSTR(SQLERRM, 201, 200));
          raise;
   END;

FUNCTION ReceiptPaAdditionFlag(p_Pa_Addition_Flag      IN VARCHAR2,
                               p_Po_Distribution_Id    IN NUMBER)
                              RETURN VARCHAR2 IS

   l_Dummy              VARCHAR2(1);
   l_Pa_Addition_Flag   VARCHAR2(1);

BEGIN
 write_log(LOG,'Inside ReceiptPaAdditionFlag');

l_Pa_Addition_Flag:=p_Pa_Addition_Flag;

  SELECT 'X'
  INTO l_Dummy
  FROM DUAL
  WHERE EXISTS ( SELECT NULL
                 FROM   rcv_transactions rcv_txn2
                       ,rcv_receiving_sub_ledger rcv_sub2
                 WHERE  rcv_sub2.rcv_transaction_id    = rcv_txn2.transaction_id
                 AND    rcv_txn2.po_distribution_id    = P_Po_Distribution_Id
                 AND    rcv_sub2.pa_addition_flag      = 'G'
                  UNION ALL
                 SELECT  null
                 FROM    ap_invoice_distributions apdist
                 WHERE   apdist.po_distribution_id = P_Po_Distribution_Id
                 AND     apdist.line_type_lookup_code in ('ITEM','ACCRUAL','RETROACCRUAL','NONREC_TAX')
                 AND     apdist.pa_addition_flag         = 'Y');

   If l_Dummy = 'X' THEN
       write_log(LOG,'ReceiptPaAdditionFlag:l_Dummy is X');
      RETURN 'G';
   ELSE
       write_log(LOG,'ReceiptPaAdditonFlag:l_pa_addition_flag'||l_Pa_Addition_Flag);
      RETURN l_Pa_Addition_Flag;
   END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    write_log(LOG,'ReceiptPaAdditonFlag NDF:l_pa_addition_flag'||l_Pa_Addition_Flag);
    RETURN l_Pa_Addition_Flag;

WHEN Others THEN
   G_err_code := SQLCODE;
   RAISE;

END ReceiptPaAdditionFlag;

END PAAPIMP_PKG;

/
