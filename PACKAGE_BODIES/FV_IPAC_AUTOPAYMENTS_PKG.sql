--------------------------------------------------------
--  DDL for Package Body FV_IPAC_AUTOPAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_IPAC_AUTOPAYMENTS_PKG" AS
/* $Header: FVIPAPMB.pls 120.10.12000000.3 2007/09/18 20:15:30 sasukuma ship $*/
--  -----------------------------------------------------------------
--                      Global Variable Declarations
-- ------------------------------------------------------------------
--    g_debug_flag       VARCHAR2(1) := NVL(Fnd_Profile.Value('FV_DEBUG_FLAG'),'N');
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_IPAC_AUTOPAYMENTS_PKG.';
    g_errbuf           VARCHAR2(1000);
    g_retcode          NUMBER;
    g_batch_name       Ap_Batches_All.batch_name%TYPE;
--    g_document_id      Ap_Inv_Selection_Criteria_All.check_stock_id%TYPE;
-- TC Obsoletion
--  g_tran_code	       Gl_Ussgl_Transaction_Codes.ussgl_transaction_code%TYPE;
    g_sob_id           Gl_Sets_Of_Books.set_of_books_id%TYPE;
    g_batch_id         Ap_Batches_All.batch_id%TYPE;
    g_payment_bank_acct_id   NUMBER;
    g_payment_profile_id          NUMBER;
    g_payment_document_id         NUMBER;
    g_org_id   NUMBER;
-- ------------------------------------------------------------------
--                      Procedure Main
-- ------------------------------------------------------------------
-- Main procedure that is called from the IPAC Disbursement Process.
-- This procedure calls all the subsequent procedures in the
-- Automatic Payments process.
--
-- Parameters:
--   x_errbuf:  Output variable for error messages from the Main process.
--
--   x_retcode: Output variable for the return code from the Main process.
--
--   p_batch_name: Batch name that is passed to this process.
--                 Used for picking up the invoices for validation.
--
--   p_document_id: The check stock id that needs to be passed to the
--                  pay in full API.
--
-- ------------------------------------------------------------------
PROCEDURE Main( x_errbuf         OUT NOCOPY VARCHAR2,
                x_retcode        OUT NOCOPY NUMBER,
                p_batch_name                VARCHAR2,
                p_payment_bank_acct_id IN  NUMBER,
                p_payment_profile_id        IN  NUMBER,
                p_payment_document_id       IN  NUMBER,
                p_org_id   IN NUMBER,
                p_set_of_books_id IN NUMBER
               -- p_document_id      IN         NUMBER
               ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Main';
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Start Automatic Payments Process.....');
    END IF;

   -- Assign initial values
   g_errbuf  := NULL;
   g_retcode := 0;
   g_batch_name := p_batch_name;
   g_payment_bank_acct_id := p_payment_bank_acct_id;
   g_payment_profile_id   :=     p_payment_profile_id;
   g_payment_document_id  :=     p_payment_document_id;
--   g_document_id := p_document_id;
-- TC Obsoletion
--   g_tran_code := p_tran_code;\
   g_org_id := p_org_id;
   g_sob_id := p_set_of_books_id;
   x_errbuf  := NULL;
   x_retcode := 0;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'The parameters passed to the process are: ');
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Batch Name: '||g_batch_name);
--      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Transaction Code: '||g_tran_code);
    END IF;

   -- Derive the Batch Id and Sob
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Deriving the Batch Id and Set Of Books Id');
    END IF;

   Get_Required_Parameters;

   IF (g_retcode = 0) THEN
      -- Validate the invoices
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Validating the Invoices');
      END IF;
      Validate_Invoices;
   END IF;

   IF g_retcode <> 0 THEN
        -- Check for errors
        x_errbuf := g_errbuf;
        x_retcode := g_retcode;
        ROLLBACK;
   ELSE
        COMMIT;
        x_retcode := 0;
        x_errbuf  := '** Automatic Payments Process completed successfully **';
   END IF;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'End Automatic Payments Process.....');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_errbuf := SQLERRM || ' -- Error in Main Procedure.';
      x_retcode := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_errbuf) ;
END Main;

-- ------------------------------------------------------------------
--                      Procedure Get_Required_Parameters
-- ------------------------------------------------------------------
-- Get_Required_Parameters procedure is called from Main procedure.
-- It gets the sob and the batch_id.
-- ------------------------------------------------------------------
PROCEDURE Get_Required_Parameters IS
  l_module_name VARCHAR2(200) := g_module_name || 'Get_Required_Parameters';
 -- l_operating_unit   NUMBER;
  l_ledger_name      Gl_ledgers_public_v.name%TYPE;
BEGIN
   -- Get the Operating Unit
  -- l_operating_unit := mo_global.get_current_org_id;
   -- Get the Sob

  mo_utils.get_ledger_info(g_org_id, g_sob_id, l_ledger_name);

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, '    Set of Books Id : '||TO_CHAR(g_sob_id));
   END IF;

   -- Get the Batch Id
   BEGIN
      -- Getting the batch id from the multi-org view ap_batches,
      -- since the uniqueness for batch name is enforced thru'
      -- the Invoice workbench.
      SELECT batch_id
      INTO g_batch_id
      FROM Ap_Batches_All
      WHERE batch_name = g_batch_name;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	g_batch_id := NULL;
	RETURN;
      WHEN OTHERS THEN
        g_errbuf := SQLERRM ||
		' -- Error in Get_Required_Parameters Procedure, while deriving
		the batch id.';
        g_retcode := 2;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception1',g_errbuf) ;
   END;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, '    Batch Id : '||TO_CHAR(g_batch_id));
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      g_errbuf := SQLERRM || ' -- Error in Get_Required_Parameters Procedure.';
      g_retcode := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_errbuf) ;
END Get_Required_Parameters;

-- ------------------------------------------------------------------
--                      Procedure Validate_Invoices
-- ------------------------------------------------------------------
-- Validate_Invoices procedure is called from Main procedure.
-- This procedure is used to validate the invoices by calling the
-- call_approval_api procedure.
-- ------------------------------------------------------------------
PROCEDURE Validate_Invoices IS
  l_module_name VARCHAR2(200) := g_module_name || 'Validate_Invoices';

  CURSOR get_invoice_csr IS
    SELECT invoice_id,invoice_num,invoice_date
    FROM Ap_Invoices
    WHERE set_of_books_id = g_sob_id
    AND source = 'IPAC'
    AND batch_id = g_batch_id
    ORDER BY invoice_num;

  CURSOR get_recinv_csr(inv_action VARCHAR2) IS
    SELECT fv.invoice_id, ap.invoice_num,
	   fv.accomplish_date, ap.payment_method_lookup_code
    FROM Fv_Ipac_Recurring_Inv fv, Ap_Invoices ap
    WHERE fv.invoice_id = ap.invoice_id
    AND fv.batch_name = g_batch_name
    AND fv.invoice_action = inv_action
    ORDER BY ap.invoice_num;

  l_invoice_num 	Ap_Invoices_All.invoice_num%TYPE;
  l_inv_action 		Fv_Ipac_Recurring_Inv.invoice_action%TYPE;
  l_validate_flag       VARCHAR2(1);

BEGIN
   Log_Mesg('O','                   Invoice Approval and Payment Output Report '||
		 'for the Batch '|| g_batch_name);
   Log_Mesg('O','                   ---------------------------------------------'||
            '----------------------------------         ');
   Log_Mesg('O','  ');
   Log_Mesg('O','  ');
   Log_Mesg('O','Invoice Number                                    '||
		'Approval Status          '||
		'Holds Count        '||
		'Payment Status                                    '||
		'Incorrect Interagency Paygroup');
   Log_Mesg('O','--------------                                    '||
		'--------------           '||
                '-----------        '||
		'--------------                                    '||
		'------------------------------                    ');

   FOR l_invoice_csr IN get_invoice_csr LOOP
     l_invoice_num := l_invoice_csr.invoice_num;
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    Validating IPAC Invoice '||l_invoice_num);
     END IF;

     -- Call the approval api
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    Calling the Approval API ');
     END IF;
     Call_Approval_Api(l_invoice_csr.invoice_id,l_invoice_num,
			l_invoice_csr.invoice_date,NULL,'I','Y');

     IF (g_retcode <> 0) THEN
         RETURN;
     END IF;
   END LOOP;

   -- Call the approval api twice.
   -- Once,for recurring invoices which need validation(when i=2).
   -- Second time for recurring invoices which just need to be paid, and not
   -- validated(these are already validated).
   FOR i IN 1..2 LOOP
     IF (i = 1) THEN
	l_inv_action := 'P';
	l_validate_flag := 'N';
     ELSE
	l_inv_action := 'V';
	l_validate_flag := 'Y';
     END IF;

     FOR l_recinv_csr IN get_recinv_csr(l_inv_action) LOOP
       l_invoice_num := l_recinv_csr.invoice_num;
       IF (i = 1) THEN
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       	    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    Validating Recurring Invoice '||l_invoice_num);
          END IF;
       ELSE
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         	  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    Processing Recurring Invoice '||l_invoice_num);
          END IF;
       END IF;

       -- Call the approval api
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'    Calling the Approval API ');
       END IF;
       Call_Approval_Api(l_recinv_csr.invoice_id,l_invoice_num,
			l_recinv_csr.accomplish_date,
			l_recinv_csr.payment_method_lookup_code,
			'R',l_validate_flag);

       IF (g_retcode <> 0) THEN
           RETURN;
       END IF;
     END LOOP;
   END LOOP;

   -- Call the output messages
   Create_Output_Messages;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf := SQLERRM || ' -- Error in Validate_Invoices Procedure.';
      g_retcode := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_errbuf) ;
END Validate_Invoices;


-- ------------------------------------------------------------------
--                      Procedure Call_Approval_Api
-- ------------------------------------------------------------------
-- Call_Approval_Api procedure is called from Validate_Invoices procedure.
-- This procedure calls the ap_approval_pkg to validate.
-- This procedure also updates the invoice_action column in the
-- Fv_Ipac_Recurring_Inv table, to show that the recurring invoice has
-- been validated and is ready to be picked up for payments.
-- Parameters:
--   p_invoice_id: Invoice Id that needs be validated by the approval api.
--
--   p_invoice_num: Invoice number used for the purpose of showing
--                  it in the output report.
--
--   p_invoice_date: Invoice date to be passed to the pay in full api.
--                   This would be the gl_date for payments.
--
--   p_payment_method: Payment method used for the recurring invoices.
--
--   p_invoice_flag: Flag to indicate if the invoice is an IPAC invoice
--                   or a recurring invoice.
--
--   p_validate_flag: Flag to indicate if the recurring invoice is
--                    is to be validated and then paid or just paid.
-- ------------------------------------------------------------------
PROCEDURE Call_Approval_Api(p_invoice_id   	NUMBER,
			    p_invoice_num  	VARCHAR2,
			    p_invoice_date 	DATE,
			    p_payment_method 	VARCHAR2,
			    p_invoice_flag 	VARCHAR2,
			    p_validate_flag 	VARCHAR2) IS

--bnarang
  l_api_version CONSTANT NUMBER := 1.0;
  l_init_msg_list VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(200);
  l_errorIds             IBY_DISBURSE_SINGLE_PMT_PKG.trxnErrorIdsTab;
--bnarang
  l_module_name VARCHAR2(200) := g_module_name || 'Call_Approval_Api';
  l_holds_count 	NUMBER;
  l_approval_status 	VARCHAR2(25);
  l_mesg 		VARCHAR(2000);
  x_paygroup		Ap_Invoices.pay_group_lookup_code%TYPE;
  l_funds_return_code  VARCHAR2(15);

BEGIN
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'        In call approval api with p_invoice_num:'||p_invoice_num||
			', p_invoice_flag: '||p_invoice_flag||', p_validate_flag:'||
			p_validate_flag);
   END IF;

l_init_msg_list := fnd_api.g_true;

   IF (p_validate_flag = 'Y') THEN

--Added parameter names in the call to Ap_Approval_Pkg.Approve

  Ap_Approval_Pkg.Approve(p_run_option => '',
              p_invoice_batch_id    => '',
              p_vendor_id           => '',
              p_pay_group           => '',
              p_invoice_id          => p_invoice_id,
              p_entered_by         => '',
              p_set_of_books_id    =>'',
              p_trace_option        => '',
              p_conc_flag           => 'N',
              p_holds_count        => l_holds_count,
              p_approval_status     =>l_approval_status,
              p_funds_return_code   =>l_funds_return_code,
              p_calling_sequence     =>'FVIPAPMB'
            );

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'        Approval Status: '||l_approval_status||
           ' Hold Count: '||TO_CHAR(l_holds_count));
      END IF;
   END IF;

   IF ( ((p_validate_flag = 'Y') AND (l_holds_count = 0)
	 AND (l_approval_status = 'APPROVED')) OR (p_validate_flag = 'N') ) THEN --cnt

       IF ((p_invoice_flag = 'R') AND (p_validate_flag = 'Y')) THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'        Updating the invoice_action in the '||
       			'Fv_Ipac_Recurring_Inv Table.');
         END IF;

	   UPDATE Fv_Ipac_Recurring_Inv
	   SET invoice_action = 'P'
	   WHERE invoice_id = p_invoice_id;
       END IF;

       BEGIN
	  -- Check the payment method for recurring invoices,
	  -- if it is not 'Clearing', then put in the exception report
	  IF ((p_invoice_flag = 'R') AND (p_payment_method <> 'CLEARING')) THEN
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_EXCEPTION, l_module_name,'        The payment method is not CLEARING '||
			'for the invoice '||p_invoice_num||
			'. Hence payment is not made for this invoice.');
		GOTO end_label;
	  END IF;

          -- Update the Wf Approval Status
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'        Updating the Workflow approval status for '||
				'the invoice '||p_invoice_num);
         END IF;
          Update_WfStatus(p_invoice_id);

         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'        Calling the pay in full API.');
         END IF;


Ap_Pay_Single_Invoice_Pkg.Ap_Pay_Invoice_In_Full(
	p_api_version  => l_api_version,
	p_init_msg_list=> l_init_msg_list,
	p_invoice_id =>         p_invoice_id,
	p_payment_type_flag =>            'M',
	p_internal_bank_acct_id => g_payment_bank_acct_id,
	p_payment_method_code =>  'CLEARING',
	p_payment_profile_id  =>   g_payment_profile_id,
	p_payment_document_id => g_payment_document_id,
	p_take_discount =>                  '',
	p_check_date =>         p_invoice_date,
	p_doc_category_code =>              '',
	p_exchange_rate_type    =>          '',
	p_exchange_rate  =>                 '',
	p_exchange_date  =>                 '',
	x_return_status  => l_return_status   ,
	x_msg_count      => l_msg_count       ,
	x_msg_data       => l_msg_data        ,
    x_errorIds       =>  l_errorIds        );

/*          Ap_Pay_Single_Invoice_Pkg.Ap_Pay_Invoice_In_Full(
           		p_invoice_id,
			'M',
			g_document_id,
			'',
			--g_tran_code, --Bug#4574367
			--'', --Bug#4574367
			p_invoice_date,
			'',
			'',
			'',
			'',
			'',
			'FVIPAPMB');
*/
       EXCEPTION
          WHEN OTHERS THEN
	     l_mesg := Fnd_Message.Get||SQLERRM;
	     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'        In the exception of the pay in full API with '||
			'the mesg '||l_mesg);
             Log_Mesg('O',RPAD(NVL(p_invoice_num,' '),50,' ')
			||RPAD(NVL(l_approval_status,' '),25,' ')
	       		||RPAD(NVL(TO_CHAR(l_holds_count),' '),19,' ')
			||l_mesg);
	     RETURN;
       END;

       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'        Inserting the transaction into the '||
	  		'Fv_Interagency_Funds Table.');
       END IF;
       -- Call Insert_IA_Txns Procedure
       Insert_IA_Txns(p_invoice_id,p_invoice_num,x_paygroup);
       Log_Mesg('O',RPAD(NVL(p_invoice_num,' '),50,' ')
			||RPAD(NVL(l_approval_status,' '),25,' ')
	       		||RPAD(NVL(TO_CHAR(l_holds_count),' '),19,' ')
			||RPAD('Payment Successfully Created',50,' ')
			||NVL(x_paygroup,' '));

       IF (g_retcode <> 0) THEN
           RETURN;
       END IF;
   ELSE										--cnt
       -- When an invoice has a hold placed on it
       Log_Mesg('O',RPAD(NVL(p_invoice_num,' '),50,' ')
                        ||RPAD(NVL(l_approval_status,' '),25,' ')
                        ||RPAD(NVL(TO_CHAR(l_holds_count),' '),19,' ')
                        ||'INVOICE_NOT_APPROVED');
   END IF;									--cnt
   GOTO end_label1;

   <<end_label>>
   Log_Mesg('O',RPAD(NVL(p_invoice_num,' '),50,' ')
			||RPAD(NVL(l_approval_status,' '),25,' ')
	       		||RPAD(NVL(TO_CHAR(l_holds_count),' '),19,' ')
			||'PAYMENT_METHOD_NOT_CLEARING');

   <<end_label1>>
   NULL;
EXCEPTION
   WHEN OTHERS THEN
      g_errbuf := SQLERRM || ' -- Error in Call_Approval_Api Procedure.';
      g_retcode := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_errbuf) ;
END Call_Approval_Api;

-- ------------------------------------------------------------------
--                      Procedure Insert_IA_Txns
-- ------------------------------------------------------------------
-- Insert_IA_Txns procedure is called from Call_Approval_Api procedure.
-- This procedure inserts a record in Fv_Interagency_Funds table
-- for all the IPAC txn's and recurring txn's.
-- Parameters:
--   p_invoice_id: Invoice Id that needs be inserted into the table.
--
--   p_invoice_num: Invoice number that needs be inserted into the table.
--
--   x_paygroup: This is an out variable which holds the paygroup of
--               a recurring invoice that is different from Interagency
--               paygroup. It is shown in the exception report as an
--               incorrect paygroup.
-- ------------------------------------------------------------------
PROCEDURE Insert_IA_Txns(p_invoice_id   NUMBER,
                            p_invoice_num  VARCHAR2,
			    x_paygroup OUT NOCOPY VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Insert_IA_Txns';
   l_vendor_id		Ap_Invoices.vendor_id%TYPE;
   l_vendor_name	Po_Vendors.vendor_name%TYPE;
   l_date		Ap_Invoices.creation_date%TYPE;
   l_count 		NUMBER := 0;
BEGIN
   -- Check if the paygroup matches with the paygroup in Federal options.
   BEGIN
     SELECT COUNT(*)
     INTO l_count
     FROM Fv_Operating_Units fo,Ap_Invoices ai
     WHERE ai.invoice_id = p_invoice_id
     AND fo.set_of_books_id = g_sob_id
     AND fo.payables_ia_paygroup = ai.pay_group_lookup_code;
   EXCEPTION
     WHEN OTHERS THEN
       g_errbuf := SQLERRM ||
	   ' -- Error in Insert_IA_Txns Procedure'||
	   ' while checking for the paygroup for the invoice '||p_invoice_num;
       g_retcode := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception7',g_errbuf) ;
   END;

   -- Get the vendor and creation date information for the invoice.
   -- If the paygroup matches, then get the vendor info,
   -- otherwise send that paygroup as an out variable to be shown in the
   -- exception report.
   IF (l_count > 0) THEN		-- count

      BEGIN
        SELECT ai.vendor_id, pv.vendor_name, ai.creation_date
        INTO l_vendor_id, l_vendor_name, l_date
        FROM Ap_Invoices ai, Po_Vendors pv
        WHERE ai.invoice_id = p_invoice_id
        AND ai.vendor_id = pv.vendor_id
        AND NOT EXISTS (SELECT 'X'
                 FROM Fv_Interagency_Funds
                 WHERE set_of_books_id = g_sob_id
                 AND invoice_id IS NOT NULL
                 AND invoice_id = ai.invoice_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           g_errbuf := SQLERRM ||
                   ' -- Error in Insert_IA_Txns Procedure (no data found)'||
                   ' while getting the vendor information for the invoice '||
			p_invoice_num;
           g_retcode := 2;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception8',g_errbuf) ;
        WHEN OTHERS THEN
           g_errbuf := SQLERRM ||
                   ' -- Error in Insert_IA_Txns Procedure'||
                   ' while getting the vendor information for the invoice '
			||p_invoice_num;
           g_retcode := 2;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception9',g_errbuf) ;
      END;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'            The invoice '||p_invoice_num||' has been inserted '||
  			'into the interagency table.');
      END IF;
   ELSE					-- count
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_EXCEPTION, l_module_name,'            The paygroup on the invoice '||p_invoice_num||
		  ' does not match to the Interagency paygroup defined '||
		  'on the Federal Options Form.');
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_EXCEPTION, l_module_name,'            The invoice '||p_invoice_num||
			' has not been inserted '|| 'into the interagency table.');
      BEGIN
	SELECT pay_group_lookup_code
	INTO x_paygroup
	FROM Ap_Invoices
	WHERE invoice_id = p_invoice_id;

      EXCEPTION
	WHEN OTHERS THEN
           g_errbuf := SQLERRM ||
                   ' -- Error in Insert_IA_Txns Procedure'||
                   ' while deriving the paygroup for the invoice '||p_invoice_num;
           g_retcode := 2;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception10',g_errbuf) ;
      END;
      RETURN;
   END IF;  				-- count

   -- Inserting into the table.
   INSERT INTO Fv_Interagency_Funds
        (interagency_fund_id,
        set_of_books_id,
        processed_flag,
        chargeback_flag,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        vendor_id,
        vendor_name,
        invoice_id,
        invoice_number,
        org_id)
        VALUES
        (Fv_Interagency_Funds_S.NEXTVAL,
        g_sob_id,
        'N',
        'N',
        SYSDATE,
        Fnd_Global.user_id,
        Fnd_Global.user_id,
        SYSDATE,
        l_vendor_id,
        l_vendor_name,
        p_invoice_id,
        p_invoice_num,
        g_org_id
        );

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf := SQLERRM || ' -- Error in Insert_IA_Txns Procedure.';
      g_retcode := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_errbuf) ;
END Insert_IA_Txns;


-- ------------------------------------------------------------------
--                      Procedure Update_WfStatus
-- ------------------------------------------------------------------
-- Update_WfStatus procedure is called from Call_Approval_Api procedure.
-- This procedure is used to manually update the wfapproval_status
-- to be not required, so even if workflow is turned on, then we
-- would be able to create payments.
-- ------------------------------------------------------------------
PROCEDURE Update_WfStatus(p_invoice_id NUMBER) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Update_WfStatus';
BEGIN
   UPDATE Ap_Invoices
   SET wfapproval_status = 'NOT REQUIRED'
   WHERE invoice_id = p_invoice_id;
EXCEPTION
   WHEN OTHERS THEN
      g_errbuf := SQLERRM || ' -- Error in Update_WfStatus Procedure.';
      g_retcode := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_errbuf) ;
END Update_WfStatus;


-- ------------------------------------------------------------------
--                      Procedure Create_Output_Messages
-- ------------------------------------------------------------------
-- Create_Output_Messages procedure is used for creating the output
-- message codes and thier descriptions.
-- ------------------------------------------------------------------
PROCEDURE Create_Output_Messages IS
  l_module_name VARCHAR2(200) := g_module_name || 'Create_Output_Messages';
BEGIN
   FOR i IN 1..5 LOOP
     Log_Mesg('O','  ');
   END LOOP;

   Log_Mesg('O','Note: The invoices which are placed on hold will need to be '||
                'manually approved.');
   Log_Mesg('O','      Payments for these invoices will need to be '||
                'manually created.');

   FOR i IN 1..3 LOOP
     Log_Mesg('O','  ');
   END LOOP;

   Log_Mesg('O','The following is the list of the descriptions of the '||
		'Payment Status codes : ');
   Log_Mesg('O','  ');
   Log_Mesg('O','INVOICE_NOT_APPROVED            - '||
			'The invoice cannot be paid as it has holds placed '||
			'on it and is not approved');
   Log_Mesg('O','PAYMENT_METHOD_NOT_CLEARING     - '||
			'The Payment Method for this invoice is not CLEARING');
   Log_Mesg('O','AP_PERIOD_NOT_OPEN              - '||
			'The GL Period is not Open');
   Log_Mesg('O','AP_NO_USER_XRATE                - '||
		'Exchange Rate is needed if Exchange Type is USER');
   Log_Mesg('O','AP_NO_XRATE                     - '||
		'No Exchange Rate found for the Exchange Type and Date');
   Log_Mesg('O','AP_INVOICE_CANNOT_BE_PAID       - '||
		'The invoice cannot be paid');
   Log_Mesg('O','AP_MISMATCHED_PAYMENT_SCHEDS    - '||
		'The Payment Schedules for this '||
		'invoice may have different payment methods');
   Log_Mesg('O','AP_PAY_FAIL_SEL_BY_BATCH        - '||
		'The invoice is being paid by a Payment Batch');
   Log_Mesg('O','AP_NO_VENDOR_SITE               - '||
		'The Vendor Site that was on the invoice '||
		'does not exist or invoices cannot be paid for this Vendor or '||
		'the Vendor has no active Pay Sites');
   Log_Mesg('O','AP_PAY_DOCUMENT_ALREADY_IN_USE  - '||
		'The Payment Document is already '||
		'in use and cannot be used by this invoice');
   Log_Mesg('O','AP_PAY_DOCUMENT_BANK_INACTIVE   - '||
		'The Bank Account, Bank Branch or '||
		'Payables Document is inactive or does not exist');
   Log_Mesg('O','AP_PAY_NO_VENDOR                - '||
		'Cannot find the Vendor Name');
   Log_Mesg('O','AP_SEQ_DOC_CAT_NOT_REQ          - '||
		'Cannot have a user specified Sequence '||
		'when Sequential Numbering is not used');
   Log_Mesg('O','AP_SEQ_NO_DOC_CAT               - '||
		'Document Category that is passed by the user '||
		'does not exist');
   Log_Mesg('O','AP_SEQ_DOC_NO_REQ               - '||
		'The user has passed in a Category Code when '||
		'Payment Document Category Code override is not allowed');
   Log_Mesg('O','AP_SEQ_DOC_CAT_NO_FOUND         - '||
		'Document Category Code is not found');
   Log_Mesg('O','AP_SEQ_CREATE_ERROR             - '||
		'Cannot get a valid Document Sequence value');
   Log_Mesg('O','AP_DEBUG                        - Generic Error Message');
EXCEPTION
   WHEN OTHERS THEN
      g_errbuf := SQLERRM || ' -- Error in Create_Output_Messages Procedure.';
      g_retcode := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_errbuf) ;
END Create_Output_Messages;


-- ------------------------------------------------------------------
--                      Procedure Log_Mesg
-- ------------------------------------------------------------------
-- Log_Mesg procedure is used for logging a debug or a log message
-- in the log file.
-- Parameters:
--
-- p_debug_flag: Indicates whether the message is a log message(L),
--               a debug message(D) or a output message(O).
-- p_message: The message that needs to be printed in the log/output.
-- ------------------------------------------------------------------
PROCEDURE Log_Mesg(p_debug_flag VARCHAR2,
		   p_message    VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Log_Mesg';
BEGIN
--   IF ((p_debug_flag = 'L') OR (p_debug_flag = 'D' AND g_debug_flag = 'Y')) THEN
--      Fnd_File.Put_Line(FND_FILE.LOG, p_message);
   IF (p_debug_flag = 'O') THEN
      Fnd_File.Put_Line(FND_FILE.OUTPUT, p_message);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      g_errbuf := SQLERRM || ' -- Error in Log_Mesg Procedure.';
      g_retcode := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_errbuf) ;
END Log_Mesg;

END Fv_Ipac_AutoPayments_Pkg;

/
