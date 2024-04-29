--------------------------------------------------------
--  DDL for Package Body AP_ISP_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_ISP_UTILITIES_PKG" AS
/* $Header: apisputb.pls 120.27.12010000.21 2010/10/27 08:50:09 ppodhiya ship $ */

  --added the below FND_LOG related variables, in order
  --to enable LOGGING for this package.
  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_ISP_UTILITIES_PKG.';

  g_inv_sysdate           CONSTANT DATE         := TRUNC(SYSDATE);


/*==========================================================================
 PROCEDURE: Get_Doc_Sequence
 Note: Method has to be automatic!
       Mode 1: Simple Manual Entry without Audit
               (Use Voucher Num, Seq Num "Not Used")
       Mode 3: Auto voucher numbering with Audit
               (Use doc_sequence_value, Seq Num 'P','A'))
       Mode 3 will override Mode 1
       Mode 2 Audited Manual Entry is not supported

 The following is a brief description of the implementation of Document
 Sequential Numbering in Invoice Open Interface (R11 only)

 The two modes for numbering can be:
   - Simple Manual Entry without Audit: Any value entered in the column
     AP_INVOICES_INTERFACE.VOUCHER_NUM will be inserted in AP_INVOICES.
     VOUCHER_NUM without validation.

   - Auto Voucher Numbering with Audit: A value will be obtained
     automatically for the record being imported and will be populated in
     AP_INVOICES. DOC_SEQUENCE_VALUE. Also audit information would be inserted
     into the audit table.

   If the profile value for the "Sequential Numbering" option is "Not Used"
   there will be no document sequencing generated.

   If the profile value is "Partial" or "Always" then
   document sequencing will be generated???

   If the profile value is "Always" and no document category is specified
   by the user, then "Standard Invoices" category will be used for
   standard invoices and "Credit Memo Invoices" category will be used
   for credits.
   We assume that a valid automatic sequence exists for such categories.

============================================================================*/

PROCEDURE get_doc_sequence(
	      p_invoice_id			        IN	         NUMBER,
          p_sequence_numbering          IN          VARCHAR2,
    	  p_doc_category_code		OUT NOCOPY    VARCHAR,
          p_db_sequence_value           OUT NOCOPY    NUMBER,
          p_db_seq_name                 OUT NOCOPY    VARCHAR2,
          p_db_sequence_id              OUT NOCOPY    NUMBER,
          p_calling_sequence            IN            VARCHAR2)

IS
  get_doc_seq_failure       EXCEPTION;
  l_name                    VARCHAR2(80);
  l_doc_category_code       ap_invoices.doc_category_code%TYPE;
  l_application_id          NUMBER;
  l_doc_seq_ass_id          NUMBER;
  l_invoice_type_lookup_code    ap_invoices.invoice_type_lookup_code%TYPE;
  l_set_of_books_id             ap_invoices.set_of_books_id%TYPE;
  l_gl_date                     ap_invoices.gl_date%TYPE;
  current_calling_sequence  VARCHAR2(2000);
  debug_info                VARCHAR2(500);
  l_return_code             NUMBER;
  l_api_name 		    VARCHAR2(50);

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'get_doc_sequence<-'||P_calling_sequence;

  l_api_name := 'get_doc_sequence';

  BEGIN
    select invoice_type_lookup_code, set_of_books_id, gl_date
    into   l_invoice_type_lookup_code, l_set_of_books_id, l_gl_date
    from   ap_invoices_all
    where  invoice_id = p_invoice_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug_info := 'no data found for the invoice id = '|| p_invoice_id;
      IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name, debug_info);
      END IF;

      -- don't do anything if invoice doesn't exist
      return;
  END;
  debug_info := l_api_name || ': invoice_type = '|| l_invoice_type_lookup_code ||
	', set_of_books_id = ' || l_set_of_books_id ||
	', gl_date = ' || l_gl_date;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
  END IF;


    --------------------------------------------------------------------------
    -- Step 1
    -- p_sequence_numbering should be in ('A','P')
    -- Do not use seq num if N (Not Used)
    --------------------------------------------------------------------------

  IF (p_sequence_numbering IN ('A','P')) THEN

      ---------------------------------------------------------------------
      -- Step 3
      -- Use Default Doc Category
      ---------------------------------------------------------------------
     debug_info := 'Use Default Category, Seq:Always';
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name, debug_info);
     END IF;

      --Contract Payments: Modified the IF condition to look at the invoice_type
      --rather than the sign of the invoice_amount in deciding which category to
      --apply, and also added the logic for 'PREPAYMENT' invoices.

      -- Bug 10206983. Added 'INVOICE REQUEST'.

      IF (l_invoice_type_lookup_code IN ('STANDARD', 'INVOICE REQUEST')) THEN
        l_doc_category_code := 'STD INV';
      ELSIF (l_invoice_type_lookup_code= 'PAYMENT REQUEST') THEN
        l_doc_category_code := 'PAY REQ INV';
      ELSIF (l_invoice_type_lookup_code= 'CREDIT') THEN
        l_doc_category_code := 'CRM INV';
      ELSIF (l_invoice_type_lookup_code= 'PREPAYMENT') THEN
        l_doc_category_code := 'PREPAY INV';
      END IF;

      debug_info := '-----> l_doc_category_code = ' || l_doc_category_code ;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name, debug_info);
      END IF;

    ---------------------------------------------------------------------------
    -- Step 4
    -- Get Doc Sequence Number
    ---------------------------------------------------------------------------

    IF ((l_doc_category_code IS NOT NULL) )THEN

       debug_info := 'Valid Category ->Check if valid Sequence assigned';
       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name, debug_info);
       END IF;

       BEGIN
         SELECT SEQ.DB_SEQUENCE_NAME,
                SEQ.DOC_SEQUENCE_ID,
                SA.doc_sequence_assignment_id
           INTO p_db_seq_name,
                p_db_sequence_id ,
                l_doc_seq_ass_id
           FROM FND_DOCUMENT_SEQUENCES SEQ,
                FND_DOC_SEQUENCE_ASSIGNMENTS SA
          WHERE SEQ.DOC_SEQUENCE_ID        = SA.DOC_SEQUENCE_ID
            AND SA.APPLICATION_ID          = 200
            AND SA.CATEGORY_CODE           = l_doc_category_code
            AND (NVL(SA.METHOD_CODE,'A') = 'A')
            AND (SA.SET_OF_BOOKS_ID = l_set_of_books_id)
            AND NVL(l_gl_date, g_inv_sysdate) between
                  SA.START_DATE and
                  NVL(SA.END_DATE, TO_DATE('31/12/4712','DD/MM/YYYY'));
       EXCEPTION
         WHEN NO_DATA_FOUND Then
             RAISE get_doc_seq_failure;
       END; -- end of the above BEGION

        ----------------------------------------------------------------------
        -- Step 5
        -- Get Doc Sequence Val
        ----------------------------------------------------------------------
        debug_info := 'Get Next Val';
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name, debug_info);
        END IF;

        l_return_code := FND_SEQNUM.GET_SEQ_VAL(
                             200,
                             l_doc_category_code,
                             l_set_of_books_id,
                             'A',
                             NVL(l_gl_date, sysdate),
                             p_db_sequence_value,
                             p_db_sequence_id ,
                             'N',
                             'N');
        debug_info := '-----------> l_doc_category_code = '|| l_doc_category_code
              || ' p_set_of_books_id = '||to_char(l_set_of_books_id)
              || ' p_db_sequence_id  = '||to_char(p_db_sequence_id )
              ||' p_db_seq_name = '||p_db_seq_name
              ||' p_db_sequence_value = '||to_char(p_db_sequence_value);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
        END IF;

    END IF; -- end of check l_current_invoice_status/doc_category_code
  END IF; -- p_sequence_numbering = 'N'

  p_doc_category_code := l_doc_category_code;

EXCEPTION
  WHEN OTHERS THEN

    IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name, debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name, SQLERRM);
      END IF;
    END IF;

END get_doc_sequence;

------------------------------------------------------------------
-- This function is used to get payment terms information.
--
------------------------------------------------------------------
PROCEDURE get_payment_terms (
    p_invoice_id		         IN  NUMBER,
    p_terms_id                   OUT NOCOPY    NUMBER,
    p_terms_date                 OUT NOCOPY    DATE,
    p_calling_sequence           IN            VARCHAR2)
IS

l_po_header_id		  	ap_invoices_all.po_header_id%TYPE;
l_vendor_site_id             	ap_invoices_all.vendor_site_id%TYPE;
l_org_id   			   	ap_invoices_all.org_id%TYPE;
l_invoice_type_lookup_code	ap_invoices_all.invoice_type_lookup_code%TYPE;
l_invoice_date             	ap_invoices_all.invoice_date%TYPE;
l_invoice_received_date   	ap_invoices_all.invoice_received_date%TYPE;
l_goods_received_date   	ap_invoices_all.goods_received_date%TYPE;
l_terms_date_basis	   	ap_system_parameters_all.terms_date_basis%TYPE;
l_term_id_per_name            NUMBER := Null;
l_start_date_active           DATE;
l_end_date_active             DATE;
l_start_date_active_per_name  DATE;
l_end_date_active_per_name    DATE;
current_calling_sequence      VARCHAR2(2000);
debug_info                    VARCHAR2(500);
l_term_name                     VARCHAR2(50);--Bug 4115712
l_no_calendar_exists            VARCHAR2(1); --Bug 4115712
l_api_name 			VARCHAR2(50);


BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
     'AP_IMPORT_VALIDATION_PKG.get_payment_terms<-'
     ||P_calling_sequence;
  l_api_name := 'get_payment_terms';
  --------------------------------------------------------------------------
  -- terms defaulting: if PO exists for the invoice,
  -- use PO terms, otherwise use terms from Supplier Site.
  --------------------------------------------------------------------------
  BEGIN
    select po_header_id, vendor_site_id, org_id,
           invoice_type_lookup_code, invoice_date,
           invoice_received_date, goods_received_date
    into   l_po_header_id, l_vendor_site_id, l_org_id,
           l_invoice_type_lookup_code, l_invoice_date,
           l_invoice_received_date, l_goods_received_date
    from   ap_invoices_all
    where  invoice_id = p_invoice_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug_info := 'no data found for the invoice id = '|| p_invoice_id;
      IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name, debug_info);
      END IF;

      return;
  END;
  debug_info := l_api_name || ': po_header_id = ' || l_po_header_id ||
	', vendor_site_id = ' || l_vendor_site_id || ', org_id = ' ||
	l_org_id || ', invoice_type = '|| l_invoice_type_lookup_code ||
	', invoice_date = ' || l_invoice_date;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
  END IF;

  BEGIN
    -- bug8711412
    select nvl(assi.terms_date_basis, aps.terms_date_basis)
    into   l_terms_date_basis
    from   ap_supplier_sites_all assi,
           ap_product_setup aps
    where  assi.vendor_site_id = l_vendor_site_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug_info := 'no ap options found for the vendor_site_id = '|| l_vendor_site_id;
      IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name, debug_info);
      END IF;

      return;
  END;
  debug_info := l_api_name || ': terms_date_basis = ' || l_terms_date_basis;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
  END IF;

  --------------------------------------------------------------
  -- Step 1
  -- get payment terms from PO or Supplier Site.
  --------------------------------------------------------------
  IF (l_po_header_id is NOT NULL) Then
      debug_info := 'Get term_id from header po_number';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
      END IF;

      SELECT terms_id
        INTO p_terms_id
        FROM po_headers_all
       WHERE po_header_id = l_po_header_id
         AND type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD');

      debug_info := l_api_name || ': p_terms_id  = ' || p_terms_id;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
      END IF;
  END IF;

  -- no term from header level po_number, try lines level po_number
  IF (p_terms_id is null ) THEN
      debug_info := 'Get term_id from lines po_numbers';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
      END IF;
      BEGIN
        SELECT p.terms_id
          INTO p_terms_id
          FROM po_headers_all p, ap_invoice_lines_all l
         WHERE p.type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD')
           AND l.po_header_id = p.po_header_id
           AND l.invoice_id = p_invoice_id
           AND p.terms_id IS NOT NULL
         GROUP BY p.terms_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN TOO_MANY_ROWS THEN
          p_terms_id        := null;
      END;

      -- no term from line level PO, try line level receipt
      IF (p_terms_id is null) THEN
        debug_info := 'Get term_id from lines receipt';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
        END IF;
        BEGIN
          SELECT p.terms_id
            INTO p_terms_id
            FROM rcv_shipment_lines r,
                 po_headers_all p,
                 ap_invoice_lines_all l
           WHERE p.po_header_id = r.po_header_id
             AND r.shipment_line_id = l.rcv_shipment_line_id
             AND l.invoice_id = p_invoice_id
             AND p.terms_id IS NOT NULL
           GROUP BY p.terms_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN TOO_MANY_ROWS THEN
            debug_info := 'too many rows';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
        END IF;
            p_terms_id        := null;
        END;

      END IF; -- end get term from line level receipt

  END IF; -- end get term from line level

  -- no term from header or line level
  IF ( (p_terms_id is null) AND
         (l_invoice_type_lookup_code <> 'PAYMENT REQUEST') ) Then

      debug_info := 'Get term_id from supplier site';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
      END IF;

      SELECT terms_id
      INTO   p_terms_id
      FROM   po_vendor_sites_all
      WHERE  vendor_site_id = l_vendor_site_id;

  ELSIF ( (p_terms_id is null) AND
         (l_invoice_type_lookup_code = 'PAYMENT REQUEST') ) Then

      debug_info := 'Get term_id from financials options';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
      END IF;

      SELECT terms_id
      INTO   p_terms_id
      FROM   financials_system_params_all
      WHERE  org_id = l_org_id;

  END IF;

  debug_info := 'getting term active date';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
  END IF;

  SELECT start_date_active, end_date_active
  INTO l_start_date_active, l_end_date_active
  FROM ap_terms
  WHERE term_id = p_terms_id;

  debug_info := 'terms id derived: '|| p_terms_id;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
  END IF;

  --------------------------------------------------------------------------
  -- Step 2
  -- Derive terms date if possible
  --
  --------------------------------------------------------------------------
  IF ( p_terms_id is not null ) THEN
      IF (l_terms_date_basis = 'Invoice Received') THEN
        p_terms_date := l_invoice_received_date;
      ELSIF (l_terms_date_basis = 'Goods Received') THEN
        p_terms_date := l_goods_received_date;
      ELSIF (l_terms_date_basis = 'Invoice') THEN
        p_terms_date := l_invoice_date;
      ELSIF (l_terms_date_basis = 'Current') THEN
        p_terms_date := g_inv_sysdate;
      ELSE
        p_terms_date := g_inv_sysdate;
      END IF;
  END IF;

  -- Bug 4115712
  ------------------------------------------------------------------------------
  -- Step 4
  -- For calendar based payment terms :
  -- Check if special calendar exists for the period
  -- in which the terms date falls, else fail insert.
  -----------------------------------------------------------------------------
   debug_info := 'Check calendar based payment terms';

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, debug_info);
   END IF;

   --Bug:4115712
   IF (p_terms_id IS NOT NULL)  THEN

      select name
      into l_term_name
      from ap_terms
      where term_id = p_terms_id;

   END IF;

   AP_TERMS_CAL_EXISTS_PKG.Check_For_Calendar(
   P_Terms_Name       =>  l_term_name,
   P_Terms_Date       =>  p_terms_date,
   P_No_Cal           =>  l_no_calendar_exists,
   P_Calling_Sequence =>  'v_check_invalidate_terms');

EXCEPTION
  WHEN OTHERS THEN
        IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name, debug_info);
        END IF;

    IF (SQLCODE < 0) THEN
        IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name, SQLERRM);
        END IF;
    END IF;

END get_payment_terms;


/*=============================================================================
 |  Function Cancel_Single_Invoice
 |
 |      Cancels one invoice by executing the following sequence of steps.
 |      This is the wrapper procedure based on
 |      ap_cancel_pkg.ap_cancel_single_invoice
 |
 |  PROGRAM FLOW
 |
 |      1. check if invoice cancellable, if yes, proceed otherwise return false
 |      3.(If invoice has had tax withheld, undo withholding) - commented
 |      4. Clear out payment schedules
 |      5. Cancel all the non-discard lines
 |          a. reverse matching
 |          b. fetch the maximum distribution line number
 |          c. Set encumbered flags to 'N'
 |          d. Accounting event generation
 |          e. reverse the distributions
 |          f. update Line level Cancelled information
 |      6. Zero out the Invoice
 |      7. Run AutoApproval for this invoice
 |      8. check posting holds remain on this canncelled invoice
 |          a. if NOT exist - complete the cancellation by updating header
 |             level information set return value to TRUE
 |          b. if exist - no update, set the return valuse to FALSE, NO
 |             DATA rollback.
 |      9. Commit Data
 |      10. Populate the out parameters.
 |
 |  NOTES
 |      1. bug2328225 case of Matching a special charge only invoice to
 |         receipt so we check if the quantity invoiced is not null too
 |      2. Events Project
 |         We no longer need to prevent the cancellation of an invoice
 |         just because the accounting of related payments has not been
 |         created. Therefore, bug fixes 902110 and 2237152 are removed.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

  PROCEDURE Cancel_Single_Invoice(
               P_invoice_id                 IN  NUMBER,
               P_last_updated_by            IN  NUMBER,
               P_last_update_login          IN  NUMBER,
               P_accounting_date            IN  DATE,
               P_message_name               OUT NOCOPY VARCHAR2,
	         P_Token			    OUT NOCOPY VARCHAR2,
               P_calling_sequence           IN  VARCHAR2)
  IS

    l_invoice_amount             NUMBER;
    l_base_amount                NUMBER;
    l_temp_cancelled_amount      NUMBER;
    l_cancelled_by               NUMBER;
    l_cancelled_amount           NUMBER;
    l_pay_curr_invoice_amount    NUMBER;
    l_cancelled_date             DATE;
    l_last_update_date           DATE;
    l_debug_info                 VARCHAR2(240);
    l_original_prepayment_amount NUMBER;
    l_curr_calling_sequence      VARCHAR2(2000);
    l_result                     BOOLEAN;
    l_api_name                   VARCHAR2(50);
    l_org_id                     NUMBER;

  BEGIN
    l_curr_calling_sequence := 'AP_ISP_UTILITIES_PKG.CANCEL_SINGLE_INVOICE<-' ||
                               P_calling_sequence;

    l_api_name := 'cancel_single_invoice';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ISP_UTILITIES_PKG.CANCEL_SINGLE_INVOICE(+)');
    END IF;

    l_debug_info := 'calling ap_cancel_pkg.ap_cancel_single_invoice()...';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


    --5126689, since a supplier can now cancel an invoice we need to set
    --the org and initialize, otherwise the code may not see the invoice on
    --the moac synonyms and po will fail when they try to close the po.
    select org_id
    into l_org_id
    from ap_invoices_all
    where invoice_id = p_invoice_id;

    mo_global.set_policy_context('S',l_org_id);
    fnd_global.apps_initialize (
      user_id =>P_last_updated_by,
      resp_id =>-1,
      resp_appl_id => 200); --ap



    l_result := AP_CANCEL_PKG.AP_Cancel_Single_Invoice(
                       p_invoice_id,
                       p_last_updated_by,
                       p_last_update_login,
                       p_accounting_date,
                       p_message_name,
                       l_invoice_amount,
                       l_base_amount,
                       l_temp_cancelled_amount,
                       l_cancelled_by,
                       l_cancelled_amount,
                       l_cancelled_date,
                       l_last_update_date,
                       l_original_prepayment_amount,
                       l_pay_curr_invoice_amount,
		           p_token,
                       l_curr_calling_sequence);
    l_debug_info := 'ap_cancel_single_invoice() called ';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -- commit
    -- ISP:CodeCleanup Bug 5256954
   -- commit;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        rollback;
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
            ' P_invoice_id = '   || P_invoice_id
          ||' P_last_updated_by = '   || P_last_updated_by
          ||' P_last_update_login = ' || P_last_update_login
          ||' P_accounting_date = '   || P_accounting_date);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;


  END Cancel_Single_Invoice;


/*=============================================================================
 |  public FUNCTION Discard_Inv_Line
 |
 |      This is a wrapper function based on
 |      ap_invoice_lines_pkg.discard_inv_line().
 |
 |      Discard or cancel the invoice line depending on calling mode. If error
 |      occurs, it return 1 and error code will be populated. Otherwise,
 |      It return 0.
 |
 |  Parameters
 |      P_line_rec - Invoice line record
 |      P_calling_mode - either from DISCARD, CANCEL or UNAPPLY_PREPAY
 |      p_inv_cancellable - 'Y' if invoice is canellable.
 |      P_last_updated_by
 |      P_last_update_login
 |      P_error_code - Error code indicates why it is not discardable
 |      P_calling_sequence - For debugging purpose
 |
 *===========================================================================*/
/* Bug 5470344 XBuild11 Code cleanup
   This code is not being used
 PROCEDURE Discard_Inv_Line(
               p_invoice_id        IN  ap_invoice_lines.invoice_id%TYPE,
               p_line_number   	   IN  ap_invoice_lines.line_number%TYPE,
               p_calling_mode      IN  VARCHAR2,
               p_inv_cancellable   IN  VARCHAR2 DEFAULT NULL,
               P_last_updated_by   IN  NUMBER,
               P_last_update_login IN  NUMBER,
               P_error_code        OUT NOCOPY VARCHAR2,
               P_token             OUT NOCOPY VARCHAR2,
               P_calling_sequence  IN  VARCHAR2)
  IS

  l_line_rec 			ap_invoice_lines%ROWTYPE;
  l_curr_calling_sequence 	VARCHAR2(2000);
  l_debug_info 			VARCHAR2(2000);
  l_api_name 			VARCHAR2(50);
  l_result				NUMBER;

  BEGIN

    l_curr_calling_sequence := 'AP_ISP_UTILITIES_PKG.discard_inv_line <- ' ||
	p_calling_sequence;

    l_api_name := 'discard_inv_line';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ISP_UTILITIES_PKG.discard_inv_line(+)');
    END IF;

    l_debug_info := 'get invoice line info...';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    select invoice_id, line_number,
	   po_line_location_id,
	   rcv_transaction_id, accounting_date,
	   amount, unit_price, unit_meas_lookup_code,
	   quantity_invoiced, discarded_flag, cancelled_flag,
	   period_name,
	   line_type_lookup_code, match_type
    into   l_line_rec.invoice_id, l_line_rec.line_number,
	   l_line_rec.po_line_location_id,
	   l_line_rec.rcv_transaction_id,
	   l_line_rec.accounting_date,
 	   l_line_rec.amount, l_line_rec.unit_price,
	   l_line_rec.unit_meas_lookup_code,
	   l_line_rec.quantity_invoiced,
	   l_line_rec.discarded_flag, l_line_rec.cancelled_flag,
	   l_line_rec.period_name,
	   l_line_rec.line_type_lookup_code,
	   l_line_rec.match_type
    from   ap_invoice_lines_all
    where  invoice_id = p_invoice_id
    and    line_number = p_line_number;

    l_debug_info := 'invoice_id = ' || l_line_rec.invoice_id ||
		', line_number = '|| l_line_rec.line_number;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    if ( ap_invoice_lines_pkg.discard_inv_line(p_line_rec => l_line_rec,
			p_calling_mode =>  p_calling_mode,
			p_inv_cancellable => p_inv_cancellable,
			p_last_updated_by => p_last_updated_by,
			p_last_update_login => p_last_update_login,
			p_error_code 	=> p_error_code,
			p_token 	=> p_token,
			p_calling_sequence => p_calling_sequence) ) then
      l_result := 0;
    else
      l_result := 1;
    end if;

    l_debug_info := 'discard_inv_line called ';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    -- return l_result;
    -- commit;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        rollback;
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || p_invoice_id
          ||' P_line_number = '     || p_line_number
          ||' P_last_updated_by = '   || P_last_updated_by
          ||' P_last_update_login = ' || P_last_update_login
          ||' P_calling_mode = ' || p_calling_mode);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Discard_Inv_line;
*/

/*  Bug 5407726 ISP Code cleanup XBuild9
     This code is not being used
 =============================================================================
 |  public procedure invoke_ap_workflow
 |      starts up a workflow process for AP invoice
 |
 |  Parameters
 |      P_invoice_id - invoice id
 |      P_calling_sequence - For debugging purpose
 |
 *===========================================================================
  PROCEDURE invoke_ap_workflow(
               p_item_key	   IN  VARCHAR2,
               p_invoice_id        IN  ap_invoices.invoice_id%TYPE,
               p_org_id            IN  ap_invoices.org_id%TYPE,
               P_calling_sequence  IN  VARCHAR2)
  IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(2000);
  l_api_name                    VARCHAR2(50);
  l_result                      NUMBER;
  l_item_key                    VARCHAR2(100);
  l_iteration             	    NUMBER;
  l_invoice_supplier_name 	    VARCHAR2(80);
  l_invoice_number        	    VARCHAR2(50);
  l_invoice_date          	    DATE;
  l_invoice_description   	    VARCHAR2(240);
  l_supplier_role         	    VARCHAR2(320);
  BEGIN

    l_curr_calling_sequence := 'AP_ISP_UTILITIES_PKG.invoke_ap_workflow <- ' ||
        p_calling_sequence;

    l_api_name := 'invoke_ap_workflow';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ISP_UTILITIES_PKG.invoke_ap_workflow(+)');
    END IF;

    --
    -- Creating a workflow process
    --
    l_debug_info := 'creating a workflow process...';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    WF_ENGINE.createProcess('APINVLDP',p_item_key, 'DISPUTE_MAIN');

    l_debug_info := 'workflow process created. ';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


    --
    -- Initializing attributes
    --
    l_debug_info := 'setting workflow process attributes... ';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    WF_ENGINE.setItemAttrText('APINVLDP',p_item_key, 'INVOICE_ID', p_invoice_id);
    WF_ENGINE.setItemAttrText('APINVLDP',p_item_key, 'ORG_ID', p_org_id);
    l_debug_info := 'invoke_ap_workflow: invoice_id = ' || p_invoice_id ||
	', org_id = ' || p_org_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


    SELECT
                        PV.vendor_name,
                        AI.invoice_num,
                        AI.invoice_date,
                        AI.description,
                        decode(AI.source, 'ISP', u.user_name, null)
    INTO
                        l_invoice_supplier_name,
                        l_invoice_number,
                        l_invoice_date,
                        l_invoice_description,
                        l_supplier_role
    FROM
                        ap_invoices_all AI,
                        po_vendors PV,
                        po_vendor_sites_all PVS,
                        fnd_user u
    WHERE
                        AI.invoice_id = p_invoice_id AND
                        AI.vendor_id = PV.vendor_id AND
                        AI.vendor_site_id = PVS.vendor_site_id(+) and
                        u.user_id = ai.created_by;

    l_debug_info := 'invoke_ap_workflow: iteration = ' || l_iteration ||
	', itemkey = '|| p_item_key ||
	', supplier_name = '|| l_invoice_supplier_name ||
	', invoice_number = '|| l_invoice_number ||
	', invoice_date = '|| l_invoice_date ||
	', supplier_role = '|| l_supplier_role;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    -- l_iteration := substr(p_item_key, instr(p_item_key,'_')+1, length(p_item_key));
    l_iteration := to_number(substr(p_item_key, instr(p_item_key,'_')+1));
    WF_ENGINE.setItemAttrNumber('APINVLDP',p_item_key, 'ITERATION', l_iteration);
    WF_ENGINE.setItemAttrText('APINVLDP',p_item_key, 'INVOICE_SUPPLIER_NAME', l_invoice_supplier_name);
    WF_ENGINE.setItemAttrText('APINVLDP',p_item_key, 'INVOICE_NUMBER', l_invoice_number);
    WF_ENGINE.setItemAttrText('APINVLDP',p_item_key, 'INVOICE_DESCRIPTION', l_invoice_description);
    WF_ENGINE.setItemAttrDate('APINVLDP',p_item_key, 'INVOICE_DATE', l_invoice_date);
    WF_ENGINE.setItemAttrText('APINVLDP',p_item_key, 'SUPPLIER_ROLE', l_supplier_role);

    l_debug_info := 'workflow process attributes set. ';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


    --
    -- Starting the process
    --
    l_debug_info := 'workflow process starting... ';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    WF_ENGINE.startProcess('APINVLDP', p_item_key);
    l_debug_info := 'workflow process started. ';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;



    WF_ENGINE.launchProcess('APINVLDP',p_item_key, 'DISPUTE_MAIN');
    l_debug_info := 'workflow process launched. ';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

   commit;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        rollback;
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || p_invoice_id
          ||' P_org_id = ' || p_org_id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END invoke_ap_workflow;
*/

/*=============================================================================
 |  public procedure override_tax
 |      this is a wrapper procedure for overriding tax
 |
 |  Parameters
 |      P_invoice_id - invoice id
 |      P_calling_sequence - For debugging purpose
 |
 *===========================================================================*/
PROCEDURE override_tax(
             P_Invoice_id              IN NUMBER,
             P_Calling_Mode            IN VARCHAR2,
             P_Override_Status         IN VARCHAR2,
             P_Event_Id                IN NUMBER,
             P_All_Error_Messages      IN VARCHAR2,
             P_Error_Code              OUT NOCOPY VARCHAR2,
             P_Calling_Sequence        IN VARCHAR2)
  IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(2000);
  l_api_name                    VARCHAR2(50);
  l_result                      BOOLEAN;

  BEGIN

    l_curr_calling_sequence := 'AP_ISP_UTILITIES_PKG.override_tax <- ' ||
        p_calling_sequence;

    l_api_name := 'override_tax';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ISP_UTILITIES_PKG.override_tax(+)');
    END IF;

    l_debug_info := 'calling AP_ETAX_SERVICES_PKG.Override_Tax: '
          ||' P_invoice_id = '     || p_invoice_id
          ||', P_calling_mode = '     || p_calling_mode
          ||', P_override_status = '     || p_override_status
          ||', P_event_id = '   || P_event_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_result := AP_ETAX_SERVICES_PKG.Override_Tax(
             P_Invoice_id              => p_invoice_id,
             P_Calling_Mode            => p_calling_mode,
             P_Override_Status         => p_override_status,
             P_Event_Id                => p_event_id,
             P_All_Error_Messages      => p_all_error_messages,
             P_Error_Code              => p_error_code,
             P_Calling_Sequence        => l_curr_calling_sequence);

    l_debug_info := 'AP_ETAX_SERVICES_PKG.override_tax called: '||
	' error_code = ' || p_error_code;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    -- return l_result;
    -- ISP:CodeCleanup Bug 5256954
    -- commit;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        rollback;
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || p_invoice_id
          ||', P_calling_mode = '     || p_calling_mode
          ||', P_override_status = '     || p_override_status
          ||', P_event_id = '   || P_event_id
          ||', P_calling_sequence = ' || l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END override_tax;

/*=============================================================================
 |  public procedure populate_payment_terms
 |      this procedure populates payment terms id and date to invoice header
 |
 |  Parameters
 |      P_invoice_id - invoice id
 |      P_calling_sequence - For debugging purpose
 |
 *===========================================================================*/
PROCEDURE populate_payment_terms(
             P_Invoice_id              IN NUMBER,
             P_Calling_Sequence        IN VARCHAR2)
  IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(2000);
  l_api_name                    VARCHAR2(50);
  l_terms_Id                    NUMBER;
  l_terms_date	                DATE;

  BEGIN

    l_curr_calling_sequence := 'AP_ISP_UTILITIES_PKG.populate_payment_terms <- ' ||
        p_calling_sequence;

    l_api_name := 'populate_payment_terms';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ISP_UTILITIES_PKG.populate_payment_terms(+)');
    END IF;

    get_payment_terms (p_invoice_id => p_invoice_id,
    		       p_terms_id   => l_terms_id,
    		       p_terms_date => l_terms_date,
    		       p_calling_sequence => l_curr_calling_sequence);

   --bug 9138008, Updating date columns after truncating time-stamp.
   --Also added updates for invoice_date and invoice_received_date as
   --terms_date is derived based on these two fields among others

    update ap_invoices_all
    set terms_id = l_terms_id,
        terms_date = trunc(l_terms_date),
        invoice_date = trunc(invoice_date),
        invoice_received_date = trunc(invoice_received_date)
    where invoice_id = p_invoice_id;

    l_debug_info := 'invoice header record updated with terms id:  '||
	l_terms_id ||', terms_date = '|| l_terms_date;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    -- commit;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        rollback;
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || p_invoice_id
          ||', P_calling_sequence = ' || l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END populate_payment_terms;

/*=============================================================================
 |  public procedure populate_doc_sequence
 |      this procedure populates document sequence to invoice header
 |
 |  Parameters
 |      P_invoice_id - invoice id
 |      P_calling_sequence - For debugging purpose
 |
 *===========================================================================*/
PROCEDURE populate_doc_sequence(
             P_Invoice_id              IN NUMBER,
             p_sequence_numbering      IN VARCHAR2,
             p_calling_sequence        IN VARCHAR2)
  IS

  l_doc_category_code           ap_invoices.doc_category_code%TYPE;
  l_db_sequence_value           ap_invoices.doc_sequence_value%TYPE;
  l_db_sequence_id              ap_invoices.doc_sequence_id%TYPE;
  l_db_sequence_name 		VARCHAR2(1000);
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(2000);
  l_api_name                    VARCHAR2(50);

  BEGIN

    l_curr_calling_sequence := 'AP_ISP_UTILITIES_PKG.populate_doc_sequence<- ' ||
        p_calling_sequence;

    l_api_name := 'populate_doc_sequence';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ISP_UTILITIES_PKG.populate_doc_sequence(+)');
    END IF;

    get_doc_sequence(
          p_invoice_id                  => p_invoice_id,
          p_sequence_numbering          => p_sequence_numbering,
          p_doc_category_code           => l_doc_category_code,
          p_db_sequence_value           => l_db_sequence_value,
          p_db_seq_name                 => l_db_sequence_name,
          p_db_sequence_id              => l_db_sequence_id,
          p_calling_sequence            => l_curr_calling_sequence);

    l_debug_info := 'got the doc category code and sequence: '||
	l_doc_category_code ||', doc_seq_value = '|| l_db_sequence_value
      || ', doc_seq_id = ' || l_db_sequence_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    update ap_invoices_all
    set    doc_category_code = l_doc_category_code,
           doc_sequence_value = l_db_sequence_value,
           doc_sequence_id = l_db_sequence_id
    where invoice_id = p_invoice_id;

    l_debug_info := 'invoice header record updated with doc category code:  '||
	l_doc_category_code ||', doc_seq_value = '|| l_db_sequence_value
      || ', doc_seq_id = ' || l_db_sequence_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        rollback;
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || p_invoice_id
          ||', P_calling_sequence = ' || l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END populate_doc_sequence;

PROCEDURE update_invoice_header(
          p_invoice_id                  IN            NUMBER,
          p_sequence_numbering          IN            VARCHAR2,
          p_calling_sequence            IN            VARCHAR2)

IS
  l_item_sum		        ap_invoices_all.invoice_amount%TYPE;
  l_tax_sum		            ap_invoices_all.invoice_amount%TYPE;
  l_misc_sum		        ap_invoices_all.invoice_amount%TYPE;
  l_frt_sum		            ap_invoices_all.invoice_amount%TYPE;
  l_retained_sum            ap_invoices_all.invoice_amount%TYPE;
  l_curr_calling_sequence   VARCHAR2(2000);
  l_debug_info              VARCHAR2(500);
  l_api_name                VARCHAR2(50);
  l_hold_count              NUMBER;
  l_line_count              NUMBER;
  l_line_total              NUMBER;
  l_Sched_Hold_count        NUMBER;
  l_inv_currency_code           ap_invoices_all.invoice_currency_code%TYPE;
  l_invoice_date                ap_invoices_all.invoice_date%TYPE;
  l_base_currency_code          ap_invoices_all.invoice_currency_code%TYPE;
  l_default_exchange_Rate_type  ap_invoices_all.exchange_rate_type%TYPE;
  l_exchange_rate               ap_invoices_all.exchange_rate%TYPE;
  l_exchange_date               ap_invoices_all.exchange_date%TYPE;
  l_requester_id                ap_invoices_all.requester_id%TYPE;

  --Bug 9239655
  l_exclude_freight_from_disc  VARCHAR2(1) :='N';
  l_exclude_tax_from_disc      VARCHAR2(1) :='N';

BEGIN
  -- Update the calling sequence

  l_curr_calling_sequence := 'update_invoice_header <-'||P_calling_sequence;

  l_api_name := 'update_invoice_header';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ISP_UTILITIES_PKG.update_invoice_header(+)');
  END IF;

  l_debug_info := 'Step 1. update invoice amount: invoice_id = ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  BEGIN
       -- Bug 5407726 ISP Code cleanup XBuild9
       SELECT SUM(DECODE(line_type_lookup_code,'ITEM',NVL(amount, 0) - NVL(included_tax_amount, 0) ,0))  ITEM_SUM,
              --Bug 5345946 XBuild7 Code Cleanup
              SUM(DECODE(line_type_lookup_code,'TAX',amount,0)) + SUM(NVL(included_tax_amount, 0)) TAX_SUM,
	          SUM(DECODE(line_type_lookup_code,'MISCELLANEOUS',NVL(amount, 0) - NVL(included_tax_amount, 0),0)) MISC_SUM,  --Bug
              SUM(DECODE(line_type_lookup_code,'FREIGHT',NVL(amount, 0) - NVL(included_tax_amount, 0),0)) FREIGHT_SUM,
              sum(decode(line_type_lookup_code, 'ITEM', NVL(retained_amount, 0), 0)) RETAINAGE_SUM
       INTO   l_item_sum, l_tax_sum, l_misc_sum, l_frt_sum, l_retained_sum
       FROM   ap_invoice_lines_all
      WHERE  invoice_id = p_invoice_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_debug_info := 'no lines found for the invoice id = '|| p_invoice_id;
      IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name, l_debug_info);
      END IF;
  END;

  --Bug 9239655
  BEGIN
   SELECT decode(assa.exclude_freight_from_discount,NULL,nvl(aps.exclude_freight_from_discount,'N'),assa.exclude_freight_from_discount)
   INTO   l_exclude_freight_from_disc
   FROM  ap_suppliers aps,
         ap_supplier_sites_all assa
   WHERE aps.vendor_id = (select vendor_id from ap_invoices_all where invoice_id = p_invoice_id)
     AND assa.vendor_id = aps.vendor_id
	 AND assa.vendor_site_id  = (select vendor_site_id from ap_invoices_all where invoice_id = p_invoice_id);

   SELECT nvl(asp.disc_is_inv_less_tax_flag,'N')
   INTO  l_exclude_tax_from_disc
   FROM  ap_system_parameters asp
   WHERE asp.org_id = (select org_id from ap_invoices_all where invoice_id = p_invoice_id);

  EXCEPTION
   WHEN OTHERS THEN NULL;
  END;

  -- don't do anything if lines don't exist
  if ( l_item_sum <> 0 ) then
    update ap_invoices_all ai
    set    invoice_amount = l_item_sum + l_tax_sum + l_misc_sum + l_frt_sum + l_retained_sum,
           amount_applicable_to_discount = l_item_sum + l_misc_sum + l_retained_sum
           /* Bug 9239655: Added conditions for adding Freight and Tax lines sum to
              amount_applicable_to_discount */
           /*+ l_tax_sum + l_misc_sum + l_frt_sum + l_retained_sum,*/
            + decode(l_exclude_tax_from_disc,'Y',0,l_tax_sum)
            + decode(l_exclude_freight_from_disc,'Y',0,l_frt_sum),
           net_of_retainage_flag =  DECODE(l_retained_sum, 0, 'N', 'Y')
    where  ai.invoice_id = p_invoice_id;
  end if;



  l_debug_info := 'Step 2. populate document sequence: invoice_id = '||
        p_invoice_id || ', sequence_numbering = ' || p_sequence_numbering;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  populate_doc_sequence(
          p_invoice_id                  => p_invoice_id,
          p_sequence_numbering          => p_sequence_numbering,
          p_calling_sequence            => l_curr_calling_sequence);


  l_debug_info := 'Step 3. populate payment terms';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  populate_payment_terms(
          p_invoice_id                  => p_invoice_id,
          p_calling_sequence            => l_curr_calling_sequence);

  l_debug_info := 'invoice header updated. ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  -- Bug 5470344 XBuild11 Code cleanup
  -- For Foriegn currency invoices, exchange rate is derieved from the
  -- OU settings. However if OU has exchange rate of NULL or 'User'
  -- ISP feature defaults the exchange rate to be of type 'Corporate'
  SELECT ai.invoice_currency_code,
         ai.invoice_date,
         asp.base_currency_code,
          DECODE(asp.default_exchange_rate_type,
                         NULL, 'Corporate',
                         'User', 'Corporate' ,
                         asp.default_exchange_rate_type),
         ap_utilities_pkg.get_exchange_rate(
                         ai.invoice_currency_code,
                         asp.base_currency_code,
                         DECODE(asp.default_exchange_rate_type,
                                NULL, 'Corporate',
                               'User', 'Corporate' ,
                                asp.default_exchange_rate_type),
                         ai.invoice_date,
                         'ISP'),
         ai.invoice_date,
         requester_id
    INTO l_inv_currency_code,
         l_invoice_date,
         l_base_currency_code,
         l_default_exchange_Rate_type,
         l_exchange_rate,
         l_exchange_date,
         l_requester_id
    FROM ap_invoices_all ai,
         ap_system_parameters_all asp
   WHERE ai.org_id = asp.org_id
      and ai.invoice_id = p_invoice_id;

  IF l_base_currency_code <> l_inv_currency_code THEN

    UPDATE ap_invoices_all
       SET exchange_rate_type = l_default_exchange_rate_type,
           exchange_rate     = l_exchange_rate,
           exchange_date     = l_exchange_date
     WHERE invoice_id = p_invoice_id;

    /* Bug 9768308 begin */
    IF (l_default_exchange_rate_type = 'User') THEN

      UPDATE ap_invoices_all
      SET base_amount = ap_utilities_pkg.ap_round_currency(
                          invoice_amount * l_exchange_rate,
                          l_base_currency_code)
      WHERE invoice_id = p_invoice_id ;

    ELSE

      -- euro triangulation
      UPDATE ap_invoices_all
      SET base_amount = gl_currency_api.convert_amount(
                          l_inv_currency_code,
                          l_base_currency_code,
                          l_exchange_date,
                          l_default_exchange_rate_type,
                          invoice_amount)
      WHERE invoice_id = p_invoice_id ;

    END IF;
    /* Bug 9768308 end */
  END IF;

  --Bug 5500186
  UPDATE ap_invoice_lines_all
    SET requester_id = l_requester_id
  WHERE line_type_lookup_code = 'ITEM'
    AND requester_id is NULL
    AND invoice_id = p_invoice_id;


  -- ISP:CodeCleanup Bug 5256954
  -- commit;

EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        rollback;
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || p_invoice_id
          || ', sequence_numbering = ' || p_sequence_numbering
          ||', P_calling_sequence = ' || l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END update_invoice_header;

procedure create_distributions(p_invoice_id IN NUMBER) IS
l_invoice_rec                 ap_approval_pkg.Invoice_Rec;
l_base_currency_code ap_system_parameters_all.base_currency_code%TYPE;

l_invoice_id 			ap_invoices_all.invoice_id%type;
l_invoice_num 			ap_invoices_all.invoice_num%type;
l_org_id 			ap_invoices_all.org_id%type;
l_invoice_amount 		ap_invoices_all.invoice_amount%type;
l_base_amount 			ap_invoices_all.base_amount%type;
l_exchange_rate 		ap_invoices_all.exchange_rate%type;
l_invoice_currency_code 	ap_invoices_all.invoice_currency_code%type;
l_invoice_amount_limit 		ap_supplier_sites_all.invoice_amount_limit%type;
l_hold_future_payments_flag 	ap_supplier_sites_all.hold_future_payments_flag%type;
l_invoice_type_lookup_code 	ap_invoices_all.invoice_type_lookup_code%type;
l_exchange_date 		ap_invoices_all.exchange_date%type;
l_exchange_rate_type 		ap_invoices_all.exchange_rate_type%type;
l_vendor_id 			ap_invoices_all.vendor_id%type;
l_invoice_date 			ap_invoices_all.invoice_date%type;
l_disc_is_inv_less_tax_flag 	ap_invoices_all.disc_is_inv_less_tax_flag%type;
l_exclude_freight_from_disc     ap_invoices_all.exclude_freight_from_discount%type;
l_tolerance_id 			ap_supplier_sites_all.tolerance_id%type;
l_services_tolerance_id 	ap_supplier_sites_all.services_tolerance_id%type;
l_error_code                    VARCHAR2(4000);
l_curr_calling_sequence         VARCHAR2(2000);
  l_debug_info                  VARCHAR2(500);
  CURSOR approve_invoice_cur IS
  SELECT AI.invoice_id,
         AI.invoice_num,
         AI.invoice_amount,
         AI.base_amount,
         AI.exchange_rate,
         AI.invoice_currency_code,
         PVS.invoice_amount_limit,
         nvl(PVS.hold_future_payments_flag,'N'),
         AI.invoice_type_lookup_code,
         AI.exchange_date,
         AI.exchange_rate_type,
         AI.vendor_id,
         AI.invoice_date,
         AI.org_id,
         nvl(AI.disc_is_inv_less_tax_flag,'N'),
         nvl(AI.exclude_freight_from_discount,'N'),
         pvs.tolerance_id,
         pvs.services_tolerance_id
  FROM   ap_invoices_all AI,
         ap_suppliers PV,
         ap_supplier_sites_all PVS
  WHERE  AI.invoice_id = p_invoice_id
  AND    AI.vendor_id = PV.vendor_id
  AND    AI.vendor_site_id = PVS.vendor_site_id;
BEGIN
   l_curr_calling_sequence := 'AP_ISP_UTILITIES_PKG.create_distributions';

   SELECT base_currency_code
   INTO   l_base_currency_code
   FROM   ap_system_parameters_all asp, ap_invoices_all ai
   WHERE  ai.invoice_id = p_invoice_id
   AND    asp.org_id = ai.org_id;

   l_debug_info := 'Before OPEN Approve_Invoice_Cur';
   OPEN Approve_Invoice_Cur;
   l_debug_info := 'Before Fetch Approve_Invoice_Cur';
   FETCH Approve_Invoice_Cur
   INTO l_invoice_id,
        l_invoice_num,
        l_invoice_amount,
        l_base_amount,
        l_exchange_rate,
        l_invoice_currency_code,
        l_invoice_amount_limit,
        l_hold_future_payments_flag,
        l_invoice_type_lookup_code,
        l_exchange_date,
        l_exchange_rate_type,
        l_vendor_id,
        l_invoice_date,
        l_org_id,
        l_disc_is_inv_less_tax_flag,
        l_exclude_freight_from_disc,
        l_tolerance_id,
        l_services_tolerance_id;
   CLOSE Approve_Invoice_Cur;

   l_invoice_rec.invoice_id := l_invoice_id;
   l_invoice_rec.invoice_num := l_invoice_num;
   l_invoice_rec.invoice_amount := l_invoice_amount;
   l_invoice_rec.base_amount := l_base_amount;
   l_invoice_rec.exchange_rate := l_exchange_rate;
   l_invoice_rec.invoice_currency_code := l_invoice_currency_code;
   l_invoice_rec.invoice_amount_limit := l_invoice_amount_limit;
   l_invoice_rec.hold_future_payments_flag := l_hold_future_payments_flag;
   l_invoice_rec.invoice_type_lookup_code := l_invoice_type_lookup_code;
   l_invoice_rec.exchange_date := l_exchange_date;
   l_invoice_rec.exchange_rate_type := l_exchange_rate_type;
   l_invoice_rec.vendor_id := l_vendor_id;
   l_invoice_rec.invoice_date := l_invoice_date;
   l_invoice_rec.org_id := l_org_id;
   l_invoice_rec.disc_is_inv_less_tax_flag := l_disc_is_inv_less_tax_flag;
   l_invoice_rec.exclude_freight_from_discount := l_exclude_freight_from_disc;
   l_invoice_rec.tolerance_id := l_tolerance_id;
   l_invoice_rec.services_tolerance_id := l_services_tolerance_id;

   l_debug_info := 'Before AP_APPROVAL_PKG.Generate_Distributions';
   AP_APPROVAL_PKG.Generate_Distributions
                   (p_invoice_rec        => l_invoice_rec ,
                    p_base_currency_code => l_base_currency_code,
                    p_inv_batch_id       => NULL,
                    p_run_option         => NULL,
                    p_calling_sequence   => l_curr_calling_sequence,
                    x_error_code         => l_error_code)
;


EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        rollback;
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || p_invoice_id
          ||', P_calling_sequence = ' || l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END;

-- Bug 5605359 (Prior to this bug fix Step 5 included Step 7. Once Tax is
-- overridden the Pay Schedules need to be adjusted.
-- ISP Flow is as follows --
-- 1. Creation of Invoice Header
-- 2. Creation of Invoice Lines
-- 3. Updation of Invoice Lines with Retainage amt.
-- 4. Calculate Tax(Call eTax) for Invoice Lines(Invoice Line Amt is Net of Retainage)
-- 5. Updation of the Invoice(update_invoice_header)
-- 6. Override Tax(Update Summary Tax Lines)
-- 7. Updation of the Invoice with the correct Invoice Amt after Tax Override
--    and creation of the Pay Schedules(update_invoice_header2)
-- 8. For PO/RCV Matched Lines (Call PO Shipment/RCV Shipment Line match)
--    Recoupment adjusts already created Pay Schedules.
-- 9. Commit.
PROCEDURE update_invoice_header2(
          p_invoice_id                  IN            NUMBER,
          p_calling_sequence            IN            VARCHAR2)

IS
  l_item_sum		        ap_invoices_all.invoice_amount%TYPE;
  l_tax_sum		            ap_invoices_all.invoice_amount%TYPE;
  l_misc_sum		        ap_invoices_all.invoice_amount%TYPE;
  l_frt_sum		            ap_invoices_all.invoice_amount%TYPE;
  l_retained_sum            ap_invoices_all.invoice_amount%TYPE;
  l_curr_calling_sequence   VARCHAR2(2000);
  l_debug_info              VARCHAR2(500);
  l_api_name                VARCHAR2(50);
  l_hold_count              NUMBER;
  l_line_count              NUMBER;
  l_line_total              NUMBER;
  l_Sched_Hold_count        NUMBER;
  l_inv_currency_code           ap_invoices_all.invoice_currency_code%TYPE;
  l_invoice_date                ap_invoices_all.invoice_date%TYPE;
  l_base_currency_code          ap_invoices_all.invoice_currency_code%TYPE;
  l_default_exchange_Rate_type  ap_invoices_all.exchange_rate_type%TYPE;
  l_exchange_rate               ap_invoices_all.exchange_rate%TYPE;
  l_exchange_date               ap_invoices_all.exchange_date%TYPE;
  l_requester_id                ap_invoices_all.requester_id%TYPE;

  l_wfitemkey                   VARCHAR2(50);
  l_dist_set_id                 ap_supplier_sites_all.distribution_set_id%TYPE;
  -- Bug 6859035
  l_period_name                 ap_invoice_lines_all.period_name%TYPE;
  l_gl_date                     ap_invoice_lines_all.accounting_date%TYPE;
  l_org_id                      ap_invoices_all.org_id%TYPE;

  -- Bug 7706967 : Start
  l_vendor_name                 ap_suppliers.vendor_name%TYPE;
  l_vendor_id                   ap_suppliers.vendor_id%TYPE;
  l_vendor_site_code            ap_supplier_sites_all.vendor_site_code%TYPE;
  l_vendor_site_id              ap_supplier_sites_all.vendor_site_id%TYPE;
  -- Bug 7706967 : End

  l_payment_priority		ap_supplier_sites_all.payment_priority%TYPE ;  -- B# 8649741

  --CARS Project. Bug 8865603.
  l_iter                       number := 0;

    --Bug 9239655
  l_exclude_freight_from_disc  VARCHAR2(1) :='N';
  l_exclude_tax_from_disc      VARCHAR2(1) :='N';

  -- Bug 9531531
  l_type_1099                  ap_invoice_lines_all.type_1099%TYPE;
  -- Bug 10040759
  l_type_1099_po               ap_invoice_lines_all.type_1099%TYPE;

BEGIN
  -- Update the calling sequence

  l_curr_calling_sequence := 'update_invoice_header2 <-'||P_calling_sequence;

  l_api_name := 'update_invoice_header2';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ISP_UTILITIES_PKG.update_invoice_header2(+)');
  END IF;

  -- Bug 6859035. Accounting date and period name are not getting
  -- stamped properly in invoice header and lines. In all the cases
  -- sysdate is being used to calculate the gl date and period name
  -- instead of invoice date and Payables Options setup GL date basis
  -- is not taken into consideration while setting the date and period.
  -- Following updates will stamp the proper gl date and period on invoice
  -- header and lines with regards to the payables options GL date basis
  -- setup. For distributions, date the period will be defaulted
  -- from the line. Following are setting the accounting date: -
  -- Header - InvDetailSvrCmd.defaultHeaderAttributes() using sysdate to
  --          to calculate the accounting date instead of invoice date.
  -- Line   - ApInvoiceLinesAllEOImpl.create() setting accounting date
  --          to sysdate.
  -- Below update will over write the the accounting date and gl date
  -- whatever is set in the java code with the proper values.

  BEGIN
    l_debug_info := 'Updating gl date and period name at header and line level.';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    SELECT ai.invoice_date, org_id
    INTO l_invoice_date, l_org_id
    FROM ap_invoices_all ai
    WHERE ai.invoice_id = p_invoice_id ;

    -- Bug 8405782
    AP_UTILITIES_PKG.Get_gl_date_and_period_1(
         P_Date         => l_invoice_date,
         P_Period_Name  => l_period_name,
         P_GL_Date      => l_gl_date,
         P_Org_Id       => l_org_id) ;

    UPDATE ap_invoices_all
    SET gl_date = l_gl_date
    WHERE invoice_id = p_invoice_id ;

    -- Bug 8345877 commenting out the below fix as
    -- remit_to columsn are no more mandatory.

    -- Bug 7706967 - Start
    /*SELECT nvl(aps.vendor_name, hzp.party_name)
      INTO l_vendor_name
      FROM ap_suppliers aps, hz_parties hzp, ap_invoices_all ai
     WHERE ai.invoice_id = p_invoice_id
       AND aps.vendor_id = ai.vendor_id
       AND hzp.party_id = aps.party_id
       AND ROWNUM = 1;

    SELECT apss.vendor_site_code, ai.vendor_id, ai.vendor_site_id
      INTO l_vendor_site_code, l_vendor_id, l_vendor_site_id
      FROM ap_supplier_sites_all apss, ap_invoices_all ai
     WHERE ai.invoice_id = p_invoice_id
       AND apss.vendor_site_id = ai.vendor_site_id;

    UPDATE ap_invoices_all
       SET remit_to_supplier_id = l_vendor_id,
           remit_to_supplier_name = l_vendor_name,
           remit_to_supplier_site_id = l_vendor_site_id,
           remit_to_supplier_site = l_vendor_site_code,
           relationship_id = -1
     WHERE invoice_id = p_invoice_id;*/ --bug 8345877
    -- Bug 7706967 - End

	-- Bug 9531531 Begin
    SELECT po.type_1099
    INTO   l_type_1099
    FROM   ap_suppliers po,
           ap_invoices_all ai
    WHERE  po.vendor_id  = ai.vendor_id
    AND    ai.invoice_id = p_invoice_id;

    l_debug_info := 'Derived type_1099 from Supplier: ' || l_type_1099;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
	-- Bug 9531531 End

    -- Bug 10040759 Begin
       FOR line in (SELECT * from ap_invoice_lines_all where invoice_id = p_invoice_id)
 	     LOOP
 	      BEGIN
 	        SELECT type_1099
            INTO l_type_1099_po
            FROM po_lines_all
            WHERE po_header_id = line.po_header_id
            AND rownum         = 1;
 	      EXCEPTION
 	        WHEN NO_DATA_FOUND THEN NULL;
 	      END;
            UPDATE ap_invoice_lines_all
            SET type_1099    = NVL(l_type_1099_po, l_type_1099)
            WHERE invoice_id = line.invoice_id
            AND line_number  = line.line_number;
 	     END LOOP;
 	-- Bug 10040759 End

    UPDATE ap_invoice_lines_all
    SET accounting_date = l_gl_date,
      period_name = l_period_name
	  --type_1099 = l_type_1099 -- Bug 9531531
    WHERE invoice_id = p_invoice_id ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_debug_info := 'No invoice found to update gl date and period. type_1099 = ' ||  l_type_1099; -- Bug 9531531 Added type_1099
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
  END ;
  -- End bug 6859035

  l_debug_info := 'Step 1. update invoice amount: invoice_id = ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  BEGIN

       SELECT SUM(DECODE(line_type_lookup_code,'ITEM',NVL(amount, 0) - NVL(included_tax_amount, 0) ,0))  ITEM_SUM,
              SUM(DECODE(line_type_lookup_code,'TAX',amount,0)) + SUM(NVL(included_tax_amount, 0)) TAX_SUM,
	          SUM(DECODE(line_type_lookup_code,'MISCELLANEOUS',NVL(amount, 0) - NVL(included_tax_amount, 0),0)) MISC_SUM,  --Bug
              SUM(DECODE(line_type_lookup_code,'FREIGHT',NVL(amount, 0) - NVL(included_tax_amount, 0),0)) FREIGHT_SUM,
              sum(decode(line_type_lookup_code, 'ITEM', NVL(retained_amount, 0), 0)) RETAINAGE_SUM
       INTO   l_item_sum, l_tax_sum, l_misc_sum, l_frt_sum, l_retained_sum
       FROM   ap_invoice_lines_all
      WHERE  invoice_id = p_invoice_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_debug_info := 'no lines found for the invoice id = '|| p_invoice_id;
      IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name, l_debug_info);
      END IF;
  END;

  --Bug 9239655
  BEGIN
   SELECT decode(assa.exclude_freight_from_discount,NULL,nvl(aps.exclude_freight_from_discount,'N'),assa.exclude_freight_from_discount)
   INTO   l_exclude_freight_from_disc
   FROM  ap_suppliers aps,
         ap_supplier_sites_all assa
   WHERE aps.vendor_id = (select vendor_id from ap_invoices_all where invoice_id = p_invoice_id)
     AND assa.vendor_id = aps.vendor_id
	 AND assa.vendor_site_id  = (select vendor_site_id from ap_invoices_all where invoice_id = p_invoice_id);

   SELECT nvl(asp.disc_is_inv_less_tax_flag,'N')
   INTO  l_exclude_tax_from_disc
   FROM  ap_system_parameters asp
   WHERE asp.org_id = (select org_id from ap_invoices_all where invoice_id = p_invoice_id);

  EXCEPTION
   WHEN OTHERS THEN NULL;
  END;


  -- don't do anything if lines don't exist
  if ( l_item_sum <> 0 ) then
    update ap_invoices_all ai
    set    invoice_amount = l_item_sum + l_tax_sum + l_misc_sum + l_frt_sum + l_retained_sum,
           amount_applicable_to_discount = l_item_sum + l_misc_sum + l_retained_sum
           /* Bug 9239655: Added conditions for adding Freight and Tax lines sum to
              amount_applicable_to_discount */
           /*+ l_tax_sum + l_misc_sum + l_frt_sum + l_retained_sum,*/
            + decode(l_exclude_tax_from_disc,'Y',0,l_tax_sum)
            + decode(l_exclude_freight_from_disc,'Y',0,l_frt_sum),
           net_of_retainage_flag =  DECODE(l_retained_sum, 0, 'N', 'Y'),
           APPROVAL_ITERATION = (nvl(approval_iteration, 0) + 1 ) --Needed for workflow process. Modified for CARS Project. Bug 8865603.
    where  ai.invoice_id = p_invoice_id;

  end if;



  l_debug_info := 'Creating Pay Schedules ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  -- B# 8649741 : get payment_priority from Sites table, do not use 99 as default
  BEGIN

      SELECT nvl(payment_priority,99)
       INTO l_payment_priority
       FROM ap_supplier_sites_all s,
            ap_invoices_all i
      WHERE s.vendor_id = i.vendor_id
        AND s.vendor_site_id = i.vendor_site_id
        AND i.invoice_id =  p_invoice_id ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_payment_priority := 99 ;
      l_debug_info := 'no Site row found for the Invoice_id = '|| p_invoice_id ;
      IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name, l_debug_info);
      END IF;
  END;
  -- B# 8649741 : end


  AP_INVOICES_POST_PROCESS_PKG.insert_children (
            X_invoice_id               => p_invoice_id,
            --X_Payment_Priority         => 99,  		.. B# 8649741
            X_Payment_Priority         => l_payment_priority,	-- B# 8649741
            X_Hold_count               => l_hold_count,
            X_Line_count               => l_line_count,
            X_Line_Total               => l_line_total,
            X_calling_sequence         => l_curr_calling_sequence,
            X_Sched_Hold_count         => l_Sched_Hold_count);

  l_debug_info := 'Call Workflow for Unmatched Invoices ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  IF (AP_ISP_UTILITIES_PKG.get_po_number_switcher(p_invoice_id)  = 'UNMATCHED') THEN
  SELECT asu.distribution_set_id
  INTO   l_dist_set_id
  FROM   ap_supplier_sites_all asu,
         ap_invoices_all ai
  WHERE  ai.vendor_site_id = asu.vendor_site_id
  AND    ai.invoice_id = p_invoice_id;
   --Create Distributions
  IF l_dist_set_id is NOT NULL THEN
     create_distributions(p_invoice_id);
  END IF;

  --CARS Project. Bug 8865603.
  BEGIN

   SELECT nvl(approval_iteration, 0)
   INTO l_iter
   FROM ap_invoices_all
   WHERE invoice_id = p_invoice_id;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

   --Call Workflow API
     AP_WORKFLOW_PKG.create_invapp_process(p_invoice_id,
                       l_iter,
                       l_wfitemkey ) ;

  END IF;


EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        rollback;
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || p_invoice_id
          ||', P_calling_sequence = ' || l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END update_invoice_header2;


/*=============================================================================
 |  public procedure match_invoice_lines
 |    This procedure recursively matches all po/rcv matched item line
 |    to the corresponding po/rcv shipment, given invoice id
 |
 |  Description
 |    When provided with a Invoice Line, based on the
 |    information provided on the line will match the invoice line
 |    appropriately to either PO or Receipt or perform Price/Quantity/Line
 |    correction.
 |
 |  Parameters
 |      P_invoice_id - invoice id
 |      P_calling_sequence - For debugging purpose
 |
 *===========================================================================*/
Procedure Match_Invoice_Lines(
      P_Invoice_Id                IN NUMBER,
      P_Calling_Sequence          IN VARCHAR2) IS

  CURSOR Invoice_Lines_cur IS
    SELECT line_number, quantity_invoiced, amount, po_line_location_id
     FROM ap_invoice_lines_all
    WHERE invoice_id = P_invoice_id
      AND NVL(discarded_flag, 'N' ) <> 'Y'
      AND nvl(generate_dists,'Y') <> 'D' --5090119
      AND line_type_lookup_code = 'ITEM';

  l_invoice_line_number         ap_invoice_lines_all.line_number%TYPE;
  l_po_line_location_id         ap_invoice_lines_all.po_line_location_id%TYPE;
  l_quantity                    ap_invoice_lines_all.quantity_invoiced%TYPE;
  l_amount                      ap_invoice_lines_all.amount%TYPE;
  l_billed                      ap_invoice_lines_all.amount%TYPE;
  l_quantity_ordered            ap_invoice_lines_all.amount%TYPE;
  l_amount_ordered              ap_invoice_lines_all.amount%TYPE;
  l_matching_basis              po_line_locations_all.matching_basis%TYPE;
  l_overbill_flag               VARCHAR2(2);
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(2000);
  l_api_name                    VARCHAR2(50);

  BEGIN

    l_curr_calling_sequence := 'AP_ISP_UTILITIES_PKG.match_invoice_lines<- ' ||
        p_calling_sequence;



    l_api_name := 'match_invoice_lines';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ISP_UTILITIES_PKG.match_invoice_lines(+)');
    END IF;


    OPEN invoice_lines_cur;

    LOOP

        FETCH invoice_lines_cur  INTO
	  l_invoice_line_number, l_quantity, l_amount, l_po_line_location_id;
        EXIT WHEN ( invoice_lines_cur%NOTFOUND );

   	-- check if it's overbilled
        select decode(shipment_type, 'PREPAYMENT', amount_financed,
                      decode(matching_basis, 'AMOUNT', amount_billed, quantity_billed)),
	       matching_basis, quantity, amount
	into   l_billed, l_matching_basis,
	       l_quantity_ordered, l_amount_ordered
        from   po_line_locations_all
        where  line_location_id = l_po_line_location_id;

        if ( l_matching_basis = 'AMOUNT' ) then
          if ( l_amount + l_billed > l_amount_ordered  ) then
            l_overbill_flag := 'Y';
          else
            l_overbill_flag := 'N';
          end if;
   	else  -- quantity based
          if ( l_quantity + l_billed > l_quantity_ordered ) then
            l_overbill_flag := 'Y';
          else
            l_overbill_flag := 'N';
          end if;
	end if;

        AP_MATCHING_UTILS_PKG.match_invoice_line(
	       	P_Invoice_Id   	     => p_invoice_id,
      	 	P_Invoice_Line_Number  => l_invoice_line_number,
      		P_Overbill_Flag        => l_overbill_flag,
      		P_Calling_Sequence     => l_curr_calling_sequence);

    END LOOP;
    CLOSE invoice_lines_cur;

    l_debug_info := 'invoice matched. ';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
  -- ISP:CodeCleanup Bug 5256954
  -- commit;

EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        rollback;
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || p_invoice_id
          || ', invoice_line_number = ' || l_invoice_line_number
          ||', P_calling_sequence = ' || l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      If (Invoice_Lines_Cur%ISOPEN) Then
          CLOSE invoice_lines_cur;
      End if;

      APP_EXCEPTION.RAISE_EXCEPTION;

END match_invoice_lines;





/*=============================================================================
 |  public procedure get_sec_attr_value
 |    This procedure retrieves the securing attribute value if there is ONLY
 |    securing attribute set
 |
 |  Description
 |
 |  Parameters
 |      P_user_id - user id
 |      P_attr_code - ICX_SUPPLIER_ORG_ID, etc.
 |      P_calling_sequence - For debugging purpose
 |
 *===========================================================================*/
Procedure get_sec_attr_value (P_user_id             IN NUMBER,
                              P_attr_code           IN VARCHAR2,
                              P_attr_value          OUT NOCOPY NUMBER,
                              P_attr_value1         OUT NOCOPY VARCHAR2,
                              P_party_id            OUT NOCOPY NUMBER,
                              P_Calling_Sequence    IN VARCHAR2) IS

  l_sec_attr_cnt                NUMBER;
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(2000);
  l_api_name                    VARCHAR2(50);

  BEGIN

    l_curr_calling_sequence := 'AP_ISP_UTILITIES_PKG.get_sec_attr_value <- ' ||
        p_calling_sequence;

    l_api_name := 'get_sec_attr_value';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
	l_api_name,'AP_ISP_UTILITIES_PKG.get_sec_attr_value(+)');
    END IF;

    -- we are assuming the attr_code is ICX_SUPPLIER_ORG_ID
    -- still pass it to allow reusability
    SELECT 	count(1) attr_value_num
    INTO        l_sec_attr_cnt
    FROM   	ak_web_user_sec_attr_values awusav
    WHERE  	awusav.web_user_id = p_user_id
    AND    	awusav.attribute_code = p_attr_code
    AND    	awusav.attribute_application_id = 177;

    l_debug_info := 'securing attribute count = ' || l_sec_attr_cnt;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    IF ( l_sec_attr_cnt = 1 )  THEN
        SELECT nvl(to_char(asav.number_value), nvl(asav.varchar2_value, to_char(asav.date_value)))
        INTO   p_attr_value
        FROM   ak_web_user_sec_attr_values asav
        WHERE  asav.attribute_application_id = 177
        AND    asav.web_user_id = p_user_id
        AND    asav.attribute_code = p_attr_code;
    END IF;

    l_debug_info := 'securing attribute value = '|| p_attr_value;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    IF ( p_attr_value is not null )  THEN
      IF ( p_attr_code = 'ICX_SUPPLIER_ORG_ID' ) THEN

        --5077334, added party_id
        SELECT vendor_name, party_id
        INTO   p_attr_value1, p_party_id
        FROM   ap_suppliers
        WHERE  vendor_id = p_attr_value;
      END IF;
    END IF;
    l_debug_info := 'securing attribute value1 = '|| p_attr_value1;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        rollback;
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_user_id = '     || p_user_id
          || ', p_attr_code = ' || p_attr_code
          ||', P_calling_sequence = ' || l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END get_sec_attr_value;

--  Used by Negotiation
PROCEDURE Release_Hold(p_hold_id IN NUMBER) IS
  l_debug_info varchar2(100);
  l_release_reason ap_lookup_codes.description%type ; -- Bug 10176292
BEGIN

  l_debug_info := 'update ap_holds_all to release hold';

  -- Bug 10176292.
  -- Now deriving release reason from ap_lookup_codes.

  SELECT DESCRIPTION
  INTO   l_release_reason
  FROM   ap_lookup_codes
  WHERE  LOOKUP_TYPE = 'HOLD CODE'
  AND    LOOKUP_CODE = 'SUP/MGR RELEASE' ;

  UPDATE ap_holds_all h
  SET release_lookup_code = 'SUP/MGR RELEASE',
      release_reason = l_release_reason, -- Bug 10176292.
      last_updated_by   =  FND_GLOBAL.user_id,
      last_update_date  =  SYSDATE,
      last_update_login =  FND_GLOBAL.login_id
  WHERE hold_id = p_hold_id
  AND release_lookup_code IS NULL
  AND EXISTS(SELECT 'It is a releasable hold'
             FROM ap_hold_codes ahc
             WHERE ahc.hold_lookup_code = h.hold_lookup_code
             AND   ahc.user_releaseable_flag = 'Y');


EXCEPTION when others then

  IF (SQLCODE <> -20001) THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PARAMETERS', 'P_hold_id = '|| p_hold_id);
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
  END IF;

  APP_EXCEPTION.RAISE_EXCEPTION;
END Release_Hold;

--  Used by Negotiation
--Bug 5595121 redesigned the api as per mswamina
PROCEDURE update_po_matching_columns  (p_line_location_id   in number,
                                       p_po_distribution_id in number,
                                       p_quantity_change    in number,
                                       p_amount_change      in number,
                                       p_ap_uom             in varchar2,
                                       p_invoice_id         in number,
                                       p_line_number        in number,
                                       p_error_code         out nocopy varchar2,
                                       p_return_status      out nocopy varchar2,
                                       p_calling_sequence   in varchar2) is

l_po_ap_dist_rec               PO_AP_DIST_REC_TYPE;
l_po_ap_line_loc_rec           PO_AP_LINE_LOC_REC_TYPE;

TYPE r_dist_info IS RECORD
  (po_distribution_id           PO_DISTRIBUTIONS.po_distribution_id%TYPE,   --Index Column
   invoice_distribution_id      AP_INVOICE_DISTRIBUTIONS.invoice_distribution_id%TYPE,
   rcv_transaction_id		RCV_TRANSACTIONS.transaction_id%TYPE,
   match_amount			AP_INVOICE_DISTRIBUTIONS.amount%TYPE,
   match_quantity               AP_INVOICE_DISTRIBUTIONS.quantity_invoiced%TYPE,
   pa_quantity			AP_INVOICE_DISTRIBUTIONS.pa_quantity%TYPE,
   update_amount		AP_INVOICE_DISTRIBUTIONS.amount%TYPE,
   update_quantity		AP_INVOICE_DISTRIBUTIONS.quantity_invoiced%TYPE,
   update_pa_quantity		AP_INVOICE_DISTRIBUTIONS.pa_quantity%TYPE
   );
TYPE Dist_Tab_Type IS TABLE OF r_dist_info INDEX BY BINARY_INTEGER;
x_dist_tab	DIST_TAB_TYPE;

CURSOR po_dists IS
SELECT po_distribution_id,
       invoice_distribution_id,
       rcv_transaction_id,
       amount,
       quantity_invoiced,
       pa_quantity
FROM ap_invoice_distributions_all
WHERE invoice_id = p_invoice_id
AND invoice_line_number = p_line_number;

l_po_distribution_id      PO_DISTRIBUTIONS.PO_DISTRIBUTION_ID%TYPE;
l_invoice_distribution_id AP_INVOICE_DISTRIBUTIONS.INVOICE_DISTRIBUTION_ID%TYPE;
l_rcv_transaction_id      RCV_TRANSACTIONS.TRANSACTION_ID%TYPE;
l_match_amount		  AP_INVOICE_DISTRIBUTIONS.AMOUNT%TYPE;
l_match_quantity          AP_INVOICE_LINES.QUANTITY_INVOICED%TYPE;
l_total_quantity_billed   AP_INVOICE_LINES.QUANTITY_INVOICED%TYPE;
l_total_amount_billed     AP_INVOICE_LINES.AMOUNT%TYPE;
l_rounding_index          PO_DISTRIBUTIONS.PO_DISTRIBUTION_ID%TYPE;
l_sum_prorated_amount     AP_INVOICE_LINES.AMOUNT%TYPE;
l_sum_prorated_quantity   AP_INVOICE_LINES.QUANTITY_INVOICED%TYPE;
l_max_dist_amount	  AP_INVOICE_DISTRIBUTIONS.AMOUNT%TYPE;
l_unit_meas_lookup_code   AP_INVOICE_LINES.UNIT_MEAS_LOOKUP_CODE%TYPE;
l_api_name  		  VARCHAR2(32);
l_msg_data		  VARCHAR2(4000);
l_return_status 	  VARCHAR2(100);
l_debug_info		  VARCHAR2(1000);
l_matching_basis	  VARCHAR2(30);
l_pa_quantity		  AP_INVOICE_DISTRIBUTIONS.PA_QUANTITY%TYPE;
current_calling_sequence  VARCHAR2(1000);
api_call_failed		  EXCEPTION;

begin

  l_api_name := 'update_po_matching_columns';
  current_calling_sequence := 'Update_Po_Matching_Columns<-'||p_calling_sequence;

  l_sum_prorated_amount := 0;
  l_sum_prorated_quantity := 0;
  l_max_dist_amount := 0;

  l_debug_info := 'Get PO Matched info from the invoice distributions';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  SELECT sum(quantity_invoiced),sum(amount)
  INTO l_total_quantity_billed,l_total_amount_billed
  FROM ap_invoice_distributions_all
  WHERE invoice_id = p_invoice_id
  AND invoice_line_number = p_line_number;

  SELECT matching_basis
  INTO l_matching_basis
  FROM po_line_locations_all
  WHERE line_location_id = p_line_location_id;

  l_debug_info := 'Populate the pl/sql table with proration data';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  OPEN po_dists;

  LOOP

    FETCH po_dists INTO l_po_distribution_id,
    		        l_invoice_distribution_id,
			l_rcv_transaction_id,
			l_match_amount,
			l_match_quantity,
			l_pa_quantity;

    EXIT WHEN po_dists%NOTFOUND;

    x_dist_tab(l_po_distribution_id).po_distribution_id := l_po_distribution_id;
    x_dist_tab(l_po_distribution_id).invoice_distribution_id := l_invoice_distribution_id;
    x_dist_tab(l_po_distribution_id).rcv_transaction_id := l_rcv_transaction_id;
    x_dist_tab(l_po_distribution_id).match_amount := l_match_amount;
    x_dist_tab(l_po_distribution_id).match_quantity := l_match_quantity;
    x_dist_tab(l_po_distribution_id).pa_quantity := l_pa_quantity;

    x_dist_tab(l_po_distribution_id).update_amount := nvl(x_dist_tab(l_po_distribution_id).match_amount,0) *
    										p_amount_change/l_total_amount_billed;
    l_sum_prorated_amount := l_sum_prorated_amount + x_dist_tab(l_po_distribution_id).update_amount;
    x_dist_tab(l_po_distribution_id).update_quantity := nvl(x_dist_tab(l_po_distribution_id).match_quantity ,0) *
    									p_quantity_change/l_total_quantity_billed;
    IF (x_dist_tab(l_po_distribution_id).pa_quantity is not null) THEN
       x_dist_tab(l_po_distribution_id).update_pa_quantity := x_dist_tab(l_po_distribution_id).update_quantity;
    ELSE
       x_dist_tab(l_po_distribution_id).update_pa_quantity := null;
    END IF;

    l_sum_prorated_quantity := l_sum_prorated_quantity + x_dist_tab(l_po_distribution_id).update_quantity;

    IF (l_max_dist_amount < x_dist_tab(l_po_distribution_id).match_amount ) THEN
       l_max_dist_amount := x_dist_tab(l_po_distribution_id).match_amount;
       l_rounding_index := l_po_distribution_id;
    END IF;

  END LOOP;

  CLOSE po_dists;

  l_debug_info := 'Correct proration rounding error';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  IF ((l_sum_prorated_quantity <> p_quantity_change OR l_sum_prorated_amount <> p_amount_change)
  								and l_rounding_index is not null) THEN

     x_dist_tab(l_rounding_index).update_quantity := x_dist_tab(l_rounding_index).update_quantity +
     								(p_quantity_change - l_sum_prorated_quantity);
     IF(x_dist_tab(l_rounding_index).update_pa_quantity IS NOT NULL) THEN
        x_dist_tab(l_rounding_index).update_pa_quantity := x_dist_tab(l_rounding_index).update_quantity;
     END IF;

     x_dist_tab(l_rounding_index).update_amount := x_dist_tab(l_rounding_index).update_amount +
     								(p_amount_change - l_sum_prorated_amount);

  END IF;

  l_debug_info := 'Create l_po_ap_line_loc_rec object and populate the data';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  l_po_ap_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
                                p_po_line_location_id => p_line_location_id,
                                p_uom_code            => p_ap_uom,
                                p_quantity_billed     => (-1) * p_quantity_change,
                                p_amount_billed       => (-1) * p_amount_change,
                                p_quantity_financed  => NULL,
                                p_amount_financed    => NULL,
                                p_quantity_recouped  => NULL,
                                p_amount_recouped    => NULL,
                                p_retainage_withheld_amt => NULL,
                                p_retainage_released_amt => NULL);


  l_debug_info := 'Create l_po_ap_dist_rec object';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  l_po_ap_dist_rec := PO_AP_DIST_REC_TYPE.create_object();

  FOR i in nvl(x_dist_tab.first,0)..nvl(x_dist_tab.last,0) LOOP

     IF (x_dist_tab.exists(i)) THEN

        l_po_ap_dist_rec.add_change(p_po_distribution_id => x_dist_tab(i).po_distribution_id,
                                p_uom_code           => p_ap_uom,
                                p_quantity_billed    => (-1) * x_dist_tab(i).update_quantity,
                                p_amount_billed      => (-1) * x_dist_tab(i).update_amount,
                                p_quantity_financed  => NULL,
                                p_amount_financed    => NULL,
                                p_quantity_recouped  => NULL,
                                p_amount_recouped    => NULL,
                                p_retainage_withheld_amt => NULL,
                                p_retainage_released_amt => NULL);

        UPDATE ap_invoice_distributions_all
	SET amount = amount - nvl(x_dist_tab(i).update_amount,0),
	    quantity_invoiced = quantity_invoiced - nvl(x_dist_tab(i).update_quantity,0),
	    pa_quantity = pa_quantity - nvl(x_dist_tab(i).update_pa_quantity,0)
        WHERE invoice_distribution_id = x_dist_tab(i).invoice_distribution_id;


	IF (x_dist_tab(i).rcv_transaction_id IS NOT NULL) THEN

	    IF (l_matching_basis = 'QUANTITY') THEN

                RCV_BILL_UPDATING_SV.ap_update_rcv_transactions(
	                            X_rcv_transaction_id  => x_dist_tab(i).rcv_transaction_id,
				    X_quantity_billed     => (-1)*x_dist_tab(i).update_quantity,
				    X_uom_lookup_code     => p_ap_uom,
				    X_amount_billed       => (-1)*x_dist_tab(i).update_amount,
				    X_matching_basis      => 'QUANTITY');

            ELSE

	        RCV_BILL_UPDATING_SV.ap_update_rcv_transactions(
	                            X_rcv_transaction_id  => x_dist_tab(i).rcv_transaction_id,
	                            X_quantity_billed     => NULL,
	                            X_uom_lookup_code     => p_ap_uom,
	                            X_amount_billed       => (-1)*x_dist_tab(i).update_amount,
	                            X_matching_basis      => 'AMOUNT');

	    END IF;

	END IF;

     END IF;

  END LOOP;


  l_debug_info := 'Call the PO_AP_INVOICE_MATCH_GRP to update the Po Distributions and Po Line Locations';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  PO_AP_INVOICE_MATCH_GRP.Update_Document_Ap_Values(
                             P_Api_Version => 1.0,
                             P_Line_Loc_Changes_Rec => l_po_ap_line_loc_rec,
                             P_Dist_Changes_Rec     => l_po_ap_dist_rec,
                             X_Return_Status        => p_return_status,
                             X_Msg_Data             => l_msg_data);

  IF (p_return_status <> 'S') THEN
    l_debug_info := 'PO API returned unsuccessfully, raise the exception';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    l_debug_info := l_msg_data;
    RAISE api_call_failed;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     END IF;

     APP_EXCEPTION.RAISE_EXCEPTION;

end update_po_matching_columns;


/* Bug 5407726 ISP Code cleanup XBuild9
     This code is not being used
PROCEDURE discard_and_rematch (p_invoice_id  in number,
                               p_line_number in number,
                               p_error_code  out nocopy varchar2,
                               p_token       out nocopy varchar2) is
  l_line_rec ap_invoice_lines%rowtype;
  l_error_code varchar2(100);
  l_token varchar2(100);

begin

  select *
  into l_line_rec
  from ap_invoice_lines_all
  where invoice_id = p_invoice_id
  and line_number = p_line_number;


  if ap_invoice_lines_pkg.Discard_Inv_Line(
               P_line_rec          => l_line_rec,
               P_calling_mode      => 'DISCARD',
               P_last_updated_by   => l_line_rec.last_updated_by,
               P_last_update_login => l_line_rec.last_update_login,
               P_error_code        => l_error_code,
	             P_token		         => l_token,
               P_calling_sequence  => 'NEGOTIATION')<> true then
    p_error_code := l_error_code;
    p_token := l_token;
    return;
  end if;


  select max(line_number)+1
  into l_line_rec.line_number
  from ap_invoice_lines_all
  where invoice_id = p_invoice_id;

  INSERT INTO AP_INVOICE_LINES (
              INVOICE_ID,
              LINE_NUMBER,
              LINE_TYPE_LOOKUP_CODE,
              REQUESTER_ID,
              DESCRIPTION,
              LINE_SOURCE,
              ORG_ID,
              INVENTORY_ITEM_ID,
              ITEM_DESCRIPTION,
              SERIAL_NUMBER,
              MANUFACTURER,
              MODEL_NUMBER,
              GENERATE_DISTS,
              MATCH_TYPE,
              DISTRIBUTION_SET_ID,
              ACCOUNT_SEGMENT,
              BALANCING_SEGMENT,
              COST_CENTER_SEGMENT,
              OVERLAY_DIST_CODE_CONCAT,
              DEFAULT_DIST_CCID,
              PRORATE_ACROSS_ALL_ITEMS,
              LINE_GROUP_NUMBER,
              ACCOUNTING_DATE,
              PERIOD_NAME,
              DEFERRED_ACCTG_FLAG,
              DEF_ACCTG_START_DATE,
              DEF_ACCTG_END_DATE,
              DEF_ACCTG_NUMBER_OF_PERIODS,
              DEF_ACCTG_PERIOD_TYPE,
              SET_OF_BOOKS_ID,
              AMOUNT,
              BASE_AMOUNT,
              ROUNDING_AMT,
              QUANTITY_INVOICED,
              UNIT_MEAS_LOOKUP_CODE,
              UNIT_PRICE,
              WFAPPROVAL_STATUS,
              DISCARDED_FLAG,
              ORIGINAL_AMOUNT,
              ORIGINAL_BASE_AMOUNT,
              ORIGINAL_ROUNDING_AMT,
              CANCELLED_FLAG,
              INCOME_TAX_REGION,
              TYPE_1099,
              STAT_AMOUNT,
              PREPAY_INVOICE_ID,
              PREPAY_LINE_NUMBER,
              INVOICE_INCLUDES_PREPAY_FLAG,
              CORRECTED_INV_ID,
              CORRECTED_LINE_NUMBER,
              PO_HEADER_ID,
              PO_LINE_ID,
              PO_RELEASE_ID,
              PO_LINE_LOCATION_ID,
              PO_DISTRIBUTION_ID,
              RCV_TRANSACTION_ID,
              FINAL_MATCH_FLAG,
              ASSETS_TRACKING_FLAG,
              ASSET_BOOK_TYPE_CODE,
              ASSET_CATEGORY_ID,
              PROJECT_ID,
              TASK_ID,
              EXPENDITURE_TYPE,
              EXPENDITURE_ITEM_DATE,
              EXPENDITURE_ORGANIZATION_ID,
              PA_QUANTITY,
              PA_CC_AR_INVOICE_ID,
              PA_CC_AR_INVOICE_LINE_NUM,
              PA_CC_PROCESSED_CODE,
              AWARD_ID,
              AWT_GROUP_ID,
              REFERENCE_1,
              REFERENCE_2,
              RECEIPT_VERIFIED_FLAG,
              RECEIPT_REQUIRED_FLAG,
              RECEIPT_MISSING_FLAG,
              JUSTIFICATION,
              EXPENSE_GROUP,
              START_EXPENSE_DATE,
              END_EXPENSE_DATE,
              RECEIPT_CURRENCY_CODE,
              RECEIPT_CONVERSION_RATE,
              RECEIPT_CURRENCY_AMOUNT,
              DAILY_AMOUNT,
              WEB_PARAMETER_ID,
              ADJUSTMENT_REASON,
              MERCHANT_DOCUMENT_NUMBER,
              MERCHANT_NAME,
              MERCHANT_REFERENCE,
              MERCHANT_TAX_REG_NUMBER,
              MERCHANT_TAXPAYER_ID,
              COUNTRY_OF_SUPPLY,
              CREDIT_CARD_TRX_ID,
              COMPANY_PREPAID_INVOICE_ID,
              CC_REVERSAL_FLAG,
              ATTRIBUTE_CATEGORY,
              ATTRIBUTE1,
              ATTRIBUTE2,
              ATTRIBUTE3,
              ATTRIBUTE4,
              ATTRIBUTE5,
              ATTRIBUTE6,
              ATTRIBUTE7,
              ATTRIBUTE8,
              ATTRIBUTE9,
              ATTRIBUTE10,
              ATTRIBUTE11,
              ATTRIBUTE12,
              ATTRIBUTE13,
              ATTRIBUTE14,
              ATTRIBUTE15,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN,
              PROGRAM_APPLICATION_ID,
              PROGRAM_ID,
              PROGRAM_UPDATE_DATE,
              REQUEST_ID,
              SHIP_TO_LOCATION_ID,
              PRIMARY_INTENDED_USE,
              PRODUCT_FISC_CLASSIFICATION,
              TRX_BUSINESS_CATEGORY,
              PRODUCT_TYPE,
              PRODUCT_CATEGORY,
              USER_DEFINED_FISC_CLASS,
              PURCHASING_CATEGORY_ID)
  values(     l_line_rec.INVOICE_ID,
              l_line_rec.LINE_NUMBER,
              l_line_rec.LINE_TYPE_LOOKUP_CODE,
              l_line_rec.REQUESTER_ID,
              l_line_rec.DESCRIPTION,
              l_line_rec.LINE_SOURCE,
              l_line_rec.ORG_ID,
              l_line_rec.INVENTORY_ITEM_ID,
              l_line_rec.ITEM_DESCRIPTION,
              l_line_rec.SERIAL_NUMBER,
              l_line_rec.MANUFACTURER,
              l_line_rec.MODEL_NUMBER,
              l_line_rec.GENERATE_DISTS,
              l_line_rec.MATCH_TYPE,
              l_line_rec.DISTRIBUTION_SET_ID,
              l_line_rec.ACCOUNT_SEGMENT,
              l_line_rec.BALANCING_SEGMENT,
              l_line_rec.COST_CENTER_SEGMENT,
              l_line_rec.OVERLAY_DIST_CODE_CONCAT,
              l_line_rec.DEFAULT_DIST_CCID,
              l_line_rec.PRORATE_ACROSS_ALL_ITEMS,
              l_line_rec.LINE_GROUP_NUMBER,
              l_line_rec.ACCOUNTING_DATE,
              l_line_rec.PERIOD_NAME,
              l_line_rec.DEFERRED_ACCTG_FLAG,
              l_line_rec.DEF_ACCTG_START_DATE,
              l_line_rec.DEF_ACCTG_END_DATE,
              l_line_rec.DEF_ACCTG_NUMBER_OF_PERIODS,
              l_line_rec.DEF_ACCTG_PERIOD_TYPE,
              l_line_rec.SET_OF_BOOKS_ID,
              l_line_rec.AMOUNT,
              l_line_rec.BASE_AMOUNT,
              l_line_rec.ROUNDING_AMT,
              l_line_rec.QUANTITY_INVOICED,
              l_line_rec.UNIT_MEAS_LOOKUP_CODE,
              l_line_rec.UNIT_PRICE,
              l_line_rec.WFAPPROVAL_STATUS,
              l_line_rec.DISCARDED_FLAG,
              l_line_rec.ORIGINAL_AMOUNT,
              l_line_rec.ORIGINAL_BASE_AMOUNT,
              l_line_rec.ORIGINAL_ROUNDING_AMT,
              l_line_rec.CANCELLED_FLAG,
              l_line_rec.INCOME_TAX_REGION,
              l_line_rec.TYPE_1099,
              l_line_rec.STAT_AMOUNT,
              l_line_rec.PREPAY_INVOICE_ID,
              l_line_rec.PREPAY_LINE_NUMBER,
              l_line_rec.INVOICE_INCLUDES_PREPAY_FLAG,
              l_line_rec.CORRECTED_INV_ID,
              l_line_rec.CORRECTED_LINE_NUMBER,
              l_line_rec.PO_HEADER_ID,
              l_line_rec.PO_LINE_ID,
              l_line_rec.PO_RELEASE_ID,
              l_line_rec.PO_LINE_LOCATION_ID,
              l_line_rec.PO_DISTRIBUTION_ID,
              l_line_rec.RCV_TRANSACTION_ID,
              l_line_rec.FINAL_MATCH_FLAG,
              l_line_rec.ASSETS_TRACKING_FLAG,
              l_line_rec.ASSET_BOOK_TYPE_CODE,
              l_line_rec.ASSET_CATEGORY_ID,
              l_line_rec.PROJECT_ID,
              l_line_rec.TASK_ID,
              l_line_rec.EXPENDITURE_TYPE,
              l_line_rec.EXPENDITURE_ITEM_DATE,
              l_line_rec.EXPENDITURE_ORGANIZATION_ID,
              l_line_rec.PA_QUANTITY,
              l_line_rec.PA_CC_AR_INVOICE_ID,
              l_line_rec.PA_CC_AR_INVOICE_LINE_NUM,
              l_line_rec.PA_CC_PROCESSED_CODE,
              l_line_rec.AWARD_ID,
              l_line_rec.AWT_GROUP_ID,
              l_line_rec.REFERENCE_1,
              l_line_rec.REFERENCE_2,
              l_line_rec.RECEIPT_VERIFIED_FLAG,
              l_line_rec.RECEIPT_REQUIRED_FLAG,
              l_line_rec.RECEIPT_MISSING_FLAG,
              l_line_rec.JUSTIFICATION,
              l_line_rec.EXPENSE_GROUP,
              l_line_rec.START_EXPENSE_DATE,
              l_line_rec.END_EXPENSE_DATE,
              l_line_rec.RECEIPT_CURRENCY_CODE,
              l_line_rec.RECEIPT_CONVERSION_RATE,
              l_line_rec.RECEIPT_CURRENCY_AMOUNT,
              l_line_rec.DAILY_AMOUNT,
              l_line_rec.WEB_PARAMETER_ID,
              l_line_rec.ADJUSTMENT_REASON,
              l_line_rec.MERCHANT_DOCUMENT_NUMBER,
              l_line_rec.MERCHANT_NAME,
              l_line_rec.MERCHANT_REFERENCE,
              l_line_rec.MERCHANT_TAX_REG_NUMBER,
              l_line_rec.MERCHANT_TAXPAYER_ID,
              l_line_rec.COUNTRY_OF_SUPPLY,
              l_line_rec.CREDIT_CARD_TRX_ID,
              l_line_rec.COMPANY_PREPAID_INVOICE_ID,
              l_line_rec.CC_REVERSAL_FLAG,
              l_line_rec.ATTRIBUTE_CATEGORY,
              l_line_rec.ATTRIBUTE1,
              l_line_rec.ATTRIBUTE2,
              l_line_rec.ATTRIBUTE3,
              l_line_rec.ATTRIBUTE4,
              l_line_rec.ATTRIBUTE5,
              l_line_rec.ATTRIBUTE6,
              l_line_rec.ATTRIBUTE7,
              l_line_rec.ATTRIBUTE8,
              l_line_rec.ATTRIBUTE9,
              l_line_rec.ATTRIBUTE10,
              l_line_rec.ATTRIBUTE11,
              l_line_rec.ATTRIBUTE12,
              l_line_rec.ATTRIBUTE13,
              l_line_rec.ATTRIBUTE14,
              l_line_rec.ATTRIBUTE15,
              l_line_rec.CREATION_DATE,
              l_line_rec.CREATED_BY,
              l_line_rec.LAST_UPDATED_BY,
              l_line_rec.LAST_UPDATE_DATE,
              l_line_rec.LAST_UPDATE_LOGIN,
              l_line_rec.PROGRAM_APPLICATION_ID,
              l_line_rec.PROGRAM_ID,
              l_line_rec.PROGRAM_UPDATE_DATE,
              l_line_rec.REQUEST_ID,
              l_line_rec.SHIP_TO_LOCATION_ID,
              l_line_rec.PRIMARY_INTENDED_USE,
              l_line_rec.PRODUCT_FISC_CLASSIFICATION,
              l_line_rec.TRX_BUSINESS_CATEGORY,
              l_line_rec.PRODUCT_TYPE,
              l_line_rec.PRODUCT_CATEGORY,
              l_line_rec.USER_DEFINED_FISC_CLASS,
              l_line_rec.PURCHASING_CATEGORY_ID);



  ap_matching_utils_pkg.Match_Invoice_Line(
      P_Invoice_Id 	  	    => p_invoice_id,
      P_Invoice_Line_Number => l_line_rec.line_number,
      P_Overbill_Flag		    => 'N',
      P_Calling_Sequence 	  => 'AP_ISP_UTILITIES_PKG.DISCARD_AND_REMATCH');


end discard_and_rematch;

*/

--Bug 5500186 --For Non-Po invoices, user should provide the Customer
-- Contact Info.
PROCEDURE populate_requester(p_first_name    IN VARCHAR2,
                             p_last_name     IN VARCHAR2,
                             p_email_address IN VARCHAR2,
                             p_requester_id  IN OUT  NOCOPY NUMBER) IS

requester_id               NUMBER;
Type requestercur          is REF CURSOR;
requester_cur              requestercur;
TYPE req_id_list_type   IS TABLE OF NUMBER(15)  INDEX BY BINARY_INTEGER;

req_id_list              req_id_list_type;
sql_stmt                varchar2(4000);

BEGIN

 sql_stmt := 'SELECT person_id '||
             'FROM per_all_people_f '||
             'WHERE  NVL(effective_end_date, SYSDATE) >= SYSDATE ';

    ----Bug 9074429 added uppper statements to make the query case insensitive.
  IF ( p_first_name is NOT NULL) then
      sql_stmt := sql_stmt ||' AND upper(first_name) =' || 'upper(' || '''' || p_first_name || '''' ||' )' ;
  END IF;
  IF ( p_last_name is NOT NULL) then
      sql_stmt := sql_stmt ||' AND upper(last_name) =' || 'upper(' || '''' ||p_last_name || '''' ||' )' ;
  END IF;
  IF ( p_email_address is NOT NULL) then
      sql_stmt := sql_stmt ||' AND upper(email_address) =' || 'upper(' || '''' || p_email_address || '''' ||' )' ;
  END IF;


  OPEN requester_cur for sql_stmt;

  FETCH requester_cur   BULK COLLECT INTO req_id_list;

  CLOSE requester_cur;

  IF req_id_list.COUNT = 0 THEN
     requester_id := NULL;
  ELSIF  req_id_list.COUNT = 1 THEN
     requester_id :=  req_id_list(1);
  ELSIF  req_id_list.COUNT > 1  THEN
       requester_id := NULL;
  END IF;

  p_requester_id := requester_id;

END;

-- Bug 5659917 PO Number shows incorrect info on the Invoice
-- Search Page
FUNCTION get_po_number_switcher(p_invoice_id    IN NUMBER)
RETURN VARCHAR2 IS

l_po_number       VARCHAR2(50); -- for CLM Bug 9503239
l_count           NUMBER;
l_po_count        NUMBER;
l_release_count   NUMBER;

BEGIN
    --
    SELECT COUNT(*)
      INTO l_count
      FROM ap_invoice_lines_all
     WHERE po_header_id IS NOT NULL
       AND invoice_id = p_invoice_id;

     IF  l_count = 0  THEN
        RETURN 'UNMATCHED';
     ELSE
        SELECT count(*)
         INTO  l_po_count
         FROM  po_headers_all
        WHERE po_header_id IN (SELECT  po_header_id
                                FROM   ap_invoice_lines_All
                                WHERE  invoice_id = p_invoice_id);

	     IF l_po_count = 1   THEN
	        --
	        SELECT COUNT(*)
	          INTO l_release_count
              FROM po_releases_all pr
             WHERE  po_header_id IN (SELECT po_header_id
                                      FROM  ap_invoice_lines_All
                                     WHERE  invoice_id = p_invoice_id);
             --
             IF (l_release_count = 0 OR l_release_count = 1) THEN
               RETURN 'SINGLE';
             ELSE
               RETURN 'MULTIPLE';
             END IF;
             --
	     ELSE
	        RETURN 'MULTIPLE';
	     END IF;
     END IF;

END;

FUNCTION get_po_number(p_invoice_id    IN NUMBER)
RETURN VARCHAR2 IS

l_po_number           VARCHAR2(50); -- for CLM Bug 9503239
l_po_header_id        NUMBER;
l_po_count            NUMBER;
l_release_count       NUMBER;
l_po_switcher         VARCHAR2(10);
l_release_num         NUMBER;

BEGIN
     --
     l_po_switcher := get_po_number_switcher(p_invoice_id);

     IF l_po_switcher = 'SINGLE' THEN
       --
        SELECT NVL(CLM_DOCUMENT_NUMBER, SEGMENT1), -- for CLM Bug 9503239
               po_header_id
	      INTO l_po_number,
	           l_po_header_id
	      FROM po_headers_all POH
	     WHERE po_header_id IN  ( SELECT po_header_id
                                    FROM ap_invoice_lines_All
                                   WHERE invoice_id = p_invoice_id);

	    SELECT COUNT(*)
	      INTO l_release_count
          FROM po_releases_all pr
         WHERE  po_header_id = l_po_header_id;
		--
		IF l_release_count = 1 THEN
		 --
		  SELECT release_num
		    INTO l_release_num
		    FROM po_releases_all
		   WHERE po_header_id =  l_po_header_id;

		   l_po_number := l_po_number||'-'|| l_release_num;
        END IF;
       --
     END IF;


     RETURN l_po_number;
     --
END;

--Bug 5704381
FUNCTION get_po_header_id(p_invoice_id    IN NUMBER)
RETURN NUMBER IS

l_po_header_id   NUMBER;
l_count       NUMBER;
l_po_count    NUMBER;

BEGIN
     --
     SELECT COUNT(*)
      INTO l_count
      FROM ap_invoice_lines_all
     WHERE po_header_id IS NOT NULL
       AND invoice_id = p_invoice_id;

     IF  l_count <> 0  THEN

        SELECT count(*)
         INTO  l_po_count
         FROM  po_headers_all
        WHERE po_header_id IN (SELECT  po_header_id
                                FROM   ap_invoice_lines_All
                                WHERE  invoice_id = p_invoice_id);

	     IF l_po_count = 1   THEN
		    SELECT po_header_id
		      INTO l_po_header_id
		      FROM po_headers_all POH
		     WHERE po_header_id IN  ( SELECT  po_header_id
                                        FROM   ap_invoice_lines_All
                                       WHERE  invoice_id = p_invoice_id);
          END IF;
     END IF;
     --
     RETURN l_po_header_id;
     --
END;

FUNCTION get_po_release(p_invoice_id    IN NUMBER,
                        p_ret_value     IN VARCHAR2)
RETURN NUMBER IS

l_po_header_id        NUMBER;
l_release_count       NUMBER;
l_po_release_id       NUMBER;
l_release_num         NUMBER;



BEGIN
    --
    l_po_header_id := get_po_header_id(p_invoice_id);
    --
    IF l_po_header_id is NOT NULL   THEN
      SELECT COUNT(*)
	    INTO l_release_count
        FROM po_releases_all pr
       WHERE  po_header_id IN (SELECT po_header_id
                                 FROM  ap_invoice_lines_All
                                WHERE  invoice_id = p_invoice_id);
       --
       IF l_release_count = 1 THEN
          --
           SELECT po_release_id,
                  release_num
             INTO l_po_release_id,
                  l_release_num
             FROM po_releases_all
            WHERE po_header_id =  l_po_header_id;
       END IF;
       --
     END IF;
     --
     IF p_ret_value ='NUM' THEN
        RETURN  l_release_num;
     ELSE
        RETURN l_po_release_id;
     END IF;
     --
END;

--Bug 8865603

    PROCEDURE stop_approval(p_invoice_id NUMBER) IS

        dummy                     BOOLEAN;
        l_hist_rec                AP_INV_APRVL_HIST%ROWTYPE;
        l_approval_iteration       AP_INVOICES_ALL.approval_iteration%TYPE;

    BEGIN

      BEGIN

        SELECT nvl(approval_iteration, 1)
         INTO l_approval_iteration
         FROM ap_invoices_all ai
        WHERE invoice_id = p_invoice_id;

        SELECT history_type,
               invoice_id,
               iteration,
               'WITHDRAWN',
               FND_PROFILE.VALUE('USER_ID'),
               FND_PROFILE.VALUE('USERNAME'),
               FND_PROFILE.VALUE('USER_ID'),
               sysdate,
               sysdate,
               FND_PROFILE.VALUE('USER_ID'),
               FND_PROFILE.VALUE('LOGIN_ID'),
               org_id,
               null,
               null,
               null,
               null,
               notification_order
          INTO l_hist_rec.history_type,
               l_hist_rec.invoice_id,
               l_hist_rec.iteration,
               l_hist_rec.response,
               l_hist_rec.approver_id,
               l_hist_rec.approver_name,
               l_hist_rec.created_by,
               l_hist_rec.creation_date,
               l_hist_rec.last_update_date,
               l_hist_rec.last_updated_by,
               l_hist_rec.last_update_login,
               l_hist_rec.org_id,
               l_hist_rec.amount_approved,
               l_hist_rec.hold_id,
               l_hist_rec.line_number,
               l_hist_rec.approver_comments,
               l_hist_rec.notification_order
	  FROM ap_inv_aprvl_hist_all
	 WHERE invoice_id = p_invoice_id
	   AND iteration = l_approval_iteration
	   AND response = 'SENT'
	   AND rownum = 1;

         AP_WORKFLOW_PKG.insert_history_table(l_hist_rec);

       EXCEPTION
         WHEN OTHERS THEN
	    NULL;
       END;

        DUMMY := ap_workflow_pkg.stop_approval(
            p_invoice_id, NULL, 'AP_ISP_UTILITIES_PKG.stop_approval.stop_approval');

    END;

    FUNCTION unsubmit_switcher(
        p_wfapproval_status VARCHAR2,
        p_approval_ready_flag VARCHAR2,
        p_cancel_date DATE,
        p_invoice_type VARCHAR2) RETURN VARCHAR2 IS

    BEGIN
        IF p_approval_ready_flag <> 'S' AND
            p_invoice_type = 'INVOICE REQUEST' AND
            p_cancel_date IS NULL AND
            p_wfapproval_status NOT IN
                ('REJECTED', 'MANUALLY APPROVED', 'WFAPPROVED', 'NOT REQUIRED') THEN
            RETURN 'UnsubmitEnabled';
        ELSE
            RETURN 'UnsubmitDisabled';
        END IF;
    END;

--Bug 8865603

  -- Bug 9095733.
  -- Wrapper API created to invoke pa_acc_gen_wf_pkg.ap_inv_generate_account
  -- from java layer. pa_acc_gen_wf_pkg.ap_inv_generate_account can not be
  -- invoked directly as the PAI returns boolean which is not supported
  -- from java.

  FUNCTION ap_inv_generate_account_wrap
  (
	p_project_id			IN  pa_projects_all.project_id%TYPE,
	p_task_id			IN  pa_tasks.task_id%TYPE,
	p_expenditure_type		IN  pa_expenditure_types.expenditure_type%TYPE,
	p_vendor_id 			IN  po_vendors.vendor_id%type,
	p_expenditure_organization_id	IN  hr_organization_units.organization_id%TYPE,
	p_expenditure_item_date 	IN  pa_expenditure_items_all.expenditure_item_date%TYPE,
	p_billable_flag			IN  pa_tasks.billable_flag%TYPE,
	p_chart_of_accounts_id		IN  NUMBER,
	p_attribute_category		IN  ap_invoices_all.attribute_category%TYPE,
	p_attribute1			IN  ap_invoices_all.attribute1%TYPE,
	p_attribute2			IN  ap_invoices_all.attribute2%TYPE,
	p_attribute3			IN  ap_invoices_all.attribute3%TYPE,
	p_attribute4			IN  ap_invoices_all.attribute4%TYPE,
	p_attribute5			IN  ap_invoices_all.attribute5%TYPE,
	p_attribute6			IN  ap_invoices_all.attribute6%TYPE,
	p_attribute7			IN  ap_invoices_all.attribute7%TYPE,
	p_attribute8			IN  ap_invoices_all.attribute8%TYPE,
	p_attribute9			IN  ap_invoices_all.attribute9%TYPE,
	p_attribute10			IN  ap_invoices_all.attribute10%TYPE,
	p_attribute11			IN  ap_invoices_all.attribute11%TYPE,
	p_attribute12			IN  ap_invoices_all.attribute12%TYPE,
	p_attribute13			IN  ap_invoices_all.attribute13%TYPE,
	p_attribute14			IN  ap_invoices_all.attribute14%TYPE,
	p_attribute15			IN  ap_invoices_all.attribute15%TYPE,
	p_dist_attribute_category	IN  ap_invoice_distributions_all.attribute_category%TYPE,
	p_dist_attribute1		IN  ap_invoice_distributions_all.attribute1%TYPE,
	p_dist_attribute2		IN  ap_invoice_distributions_all.attribute2%TYPE,
	p_dist_attribute3		IN  ap_invoice_distributions_all.attribute3%TYPE,
	p_dist_attribute4		IN  ap_invoice_distributions_all.attribute4%TYPE,
	p_dist_attribute5		IN  ap_invoice_distributions_all.attribute5%TYPE,
	p_dist_attribute6		IN  ap_invoice_distributions_all.attribute6%TYPE,
	p_dist_attribute7		IN  ap_invoice_distributions_all.attribute7%TYPE,
	p_dist_attribute8		IN  ap_invoice_distributions_all.attribute8%TYPE,
	p_dist_attribute9		IN  ap_invoice_distributions_all.attribute9%TYPE,
	p_dist_attribute10		IN  ap_invoice_distributions_all.attribute10%TYPE,
	p_dist_attribute11		IN  ap_invoice_distributions_all.attribute11%TYPE,
	p_dist_attribute12		IN  ap_invoice_distributions_all.attribute12%TYPE,
	p_dist_attribute13		IN  ap_invoice_distributions_all.attribute13%TYPE,
	p_dist_attribute14		IN  ap_invoice_distributions_all.attribute14%TYPE,
	p_dist_attribute15		IN  ap_invoice_distributions_all.attribute15%TYPE,
	p_input_ccid			IN gl_code_combinations.code_combination_id%TYPE default null,
	x_return_ccid			OUT NOCOPY gl_code_combinations.code_combination_id%TYPE,
	x_concat_segs			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_concat_ids			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_concat_descrs			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_error_message			OUT NOCOPY VARCHAR2,
	X_award_set_id			IN  NUMBER DEFAULT NULL,
        p_accounting_date               IN  ap_invoice_distributions_all.accounting_date%TYPE default NULL,
        p_award_id                      IN  NUMBER DEFAULT NULL,
        p_expenditure_item_id           IN  NUMBER DEFAULT NULL ) RETURN NUMBER IS

    l_result                     BOOLEAN;

BEGIN

   l_result := pa_acc_gen_wf_pkg.ap_inv_generate_account (
	     p_project_id  => p_project_id,
	     p_task_id     => p_task_id,
	     p_expenditure_type  => p_expenditure_type,
	     p_vendor_id         => p_vendor_id,
	     p_expenditure_organization_id  => p_expenditure_organization_id,
	     p_expenditure_item_date  => p_expenditure_item_date,
	     p_billable_flag        => p_billable_flag,
	     p_chart_of_accounts_id => p_chart_of_accounts_id,
             p_accounting_date      => p_accounting_date,
             P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
             P_ATTRIBUTE1  => P_ATTRIBUTE1,
             P_ATTRIBUTE2  => P_ATTRIBUTE2,
             P_ATTRIBUTE3  => P_ATTRIBUTE3,
             P_ATTRIBUTE4  => P_ATTRIBUTE4,
             P_ATTRIBUTE5  => P_ATTRIBUTE5,
             P_ATTRIBUTE6  => P_ATTRIBUTE6,
             P_ATTRIBUTE7  => P_ATTRIBUTE7,
             P_ATTRIBUTE8  => P_ATTRIBUTE8,
             P_ATTRIBUTE9  => P_ATTRIBUTE9,
             P_ATTRIBUTE10 => P_ATTRIBUTE10,
             P_ATTRIBUTE11 => P_ATTRIBUTE11,
             P_ATTRIBUTE12 => P_ATTRIBUTE12,
             P_ATTRIBUTE13 => P_ATTRIBUTE13,
             P_ATTRIBUTE14 => P_ATTRIBUTE14,
             P_ATTRIBUTE15 => P_ATTRIBUTE15,
	     P_DIST_ATTRIBUTE_CATEGORY => P_DIST_ATTRIBUTE_CATEGORY,
	     P_DIST_ATTRIBUTE1 => P_DIST_ATTRIBUTE1,
	     P_DIST_ATTRIBUTE2 => P_DIST_ATTRIBUTE2,
	     P_DIST_ATTRIBUTE3 => P_DIST_ATTRIBUTE3,
	     P_DIST_ATTRIBUTE4 => P_DIST_ATTRIBUTE4,
	     P_DIST_ATTRIBUTE5 => P_DIST_ATTRIBUTE5,
	     P_DIST_ATTRIBUTE6 => P_DIST_ATTRIBUTE6,
	     P_DIST_ATTRIBUTE7 => P_DIST_ATTRIBUTE7,
	     P_DIST_ATTRIBUTE8 => P_DIST_ATTRIBUTE8,
	     P_DIST_ATTRIBUTE9 => P_DIST_ATTRIBUTE9,
	     P_DIST_ATTRIBUTE10 => P_DIST_ATTRIBUTE10,
	     P_DIST_ATTRIBUTE11 => P_DIST_ATTRIBUTE11,
	     P_DIST_ATTRIBUTE12 => P_DIST_ATTRIBUTE12,
	     P_DIST_ATTRIBUTE13 => P_DIST_ATTRIBUTE13,
	     P_DIST_ATTRIBUTE14 => P_DIST_ATTRIBUTE14,
	     P_DIST_ATTRIBUTE15 => P_DIST_ATTRIBUTE15,
             p_input_ccid => p_input_ccid,
	     x_return_ccid => x_return_ccid,
	     x_concat_segs => x_concat_segs,
	     x_concat_ids  => x_concat_ids,
	     x_concat_descrs => x_concat_descrs,
	     x_error_message	=> x_error_message,
             X_award_set_id => X_award_set_id,
	     p_award_id  => p_award_id,
             p_expenditure_item_id  => p_expenditure_item_id) ;

   IF (l_result = true) THEN
     RETURN 1 ;
   ELSE
     RETURN 0 ;
   END IF;

END ap_inv_generate_account_wrap;

END AP_ISP_UTILITIES_PKG;

/
