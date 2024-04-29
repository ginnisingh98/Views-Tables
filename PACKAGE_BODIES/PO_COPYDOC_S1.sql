--------------------------------------------------------
--  DDL for Package Body PO_COPYDOC_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COPYDOC_S1" AS
/* $Header: POXCPO1B.pls 120.25.12010000.17 2012/09/11 13:38:56 inagdeo ship $*/

--< Shared Proc FPJ Start >
-- Debugging booleans used to bypass logging when turned off
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

g_pkg_name CONSTANT VARCHAR2(20) := 'PO_COPYDOC_S1';
g_module_prefix CONSTANT VARCHAR2(30) := 'po.plsql.' || g_pkg_name || '.';
--< Shared Proc FPJ End >

--<Unified Catalog R12: Start>
-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) := PO_LOG.get_package_base(g_pkg_name);

-- The module base for the subprogram.
D_copy_attributes CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'copy_attributes');
--<Unified Catalog R12: End>

--<Enhanced Pricing Start:>
D_copy_line_adjustments CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'copy_line_adjustments');

-- Cursor definitions:

  CURSOR po_line_cursor(x_po_header_id po_lines.po_header_id%TYPE) IS
    SELECT   *
    FROM     PO_LINES
    WHERE    po_header_id = x_po_header_id
    ORDER BY line_num;

  CURSOR po_shipment_cursor(x_po_line_id po_line_locations.po_line_id%TYPE) IS
    SELECT   *
    FROM     PO_LINE_LOCATIONS
    WHERE    po_line_id = x_po_line_id
    AND      SHIPMENT_TYPE NOT IN ('SCHEDULED','BLANKET') --Bug: 1773758 1992096
    ORDER BY shipment_num;

  CURSOR po_distribution_cursor(x_line_location_id po_distributions.line_location_id%TYPE) IS
    SELECT   *
    FROM     PO_DISTRIBUTIONS
    WHERE    line_location_id = x_line_location_id
    AND      distribution_type <> 'AGREEMENT' --bug 3338216: filter BPA dists
    ORDER BY distribution_num;

-- End of Cursor definitions

-- Private function prototypes

PROCEDURE fetch_header(
  x_po_header_record   IN OUT NOCOPY  PO_HEADERS%ROWTYPE,
  x_from_po_header_id  IN      po_headers.po_header_id%TYPE,
  x_online_report_id   IN      po_online_report_text.online_report_id%TYPE,
  x_sequence           IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_return_code        OUT NOCOPY     NUMBER
);
PROCEDURE insert_header(
  x_po_header_record  IN      PO_HEADERS%ROWTYPE,
  x_online_report_id  IN      po_online_report_text.online_report_id%TYPE,
  x_sequence          IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_return_code       OUT NOCOPY     NUMBER,
  x_copy_terms        IN VARCHAR2    --<CONTERMS FPJ>
);
PROCEDURE insert_line(
  x_po_line_record    IN      po_lines%ROWTYPE,
  x_online_report_id  IN      po_online_report_text.online_report_id%TYPE,
  x_sequence          IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_return_code       OUT NOCOPY     NUMBER
);

PROCEDURE insert_shipment(
  x_po_shipment_record  IN      po_line_locations%ROWTYPE,
  x_online_report_id    IN      po_online_report_text.online_report_id%TYPE,
  x_sequence            IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num            IN      po_online_report_text.line_num%TYPE,
  x_accrue_on_receipt_flag IN   VARCHAR2,
  x_inv_org_id          IN      financials_system_parameters.inventory_organization_id%TYPE, -- Bug 2761415
  x_return_code         OUT NOCOPY     NUMBER,
  p_is_complex_work_po  IN BOOLEAN,     -- <Complex Work R12>
  p_orig_line_location_id IN NUMBER     -- <eTax Integration R12>
);

PROCEDURE insert_distribution(
  x_po_distribution_record  IN      po_distributions%ROWTYPE,
  x_online_report_id        IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                IN      po_online_report_text.line_num%TYPE,
  x_shipment_num            IN      po_online_report_text.shipment_num%TYPE,
  x_return_code             OUT NOCOPY     NUMBER
);

PROCEDURE handle_fatal(
  x_return_code  OUT NOCOPY  NUMBER
);

PROCEDURE process_header(
  x_action_code       IN      VARCHAR2,
  x_to_doc_subtype          IN      po_headers.type_lookup_code%TYPE,
  x_to_global_flag      IN      PO_HEADERS_ALL.global_agreement_flag%TYPE,  -- GA
  x_po_header_record        IN OUT NOCOPY  PO_HEADERS%ROWTYPE,
  x_from_po_header_id       IN      po_headers.po_header_id%TYPE,
  x_to_segment1             IN      po_headers.segment1%TYPE,
  x_agent_id                IN      po_headers.agent_id%TYPE,
  x_sob_id                  IN      financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id              IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_copy_attachments        IN      BOOLEAN,
  x_online_report_id        IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_return_code             OUT NOCOPY     NUMBER,
  x_copy_terms              IN VARCHAR2 -- <FPJ CONTERMS>
);

PROCEDURE process_line(
  x_action_code         IN      VARCHAR2,
  x_to_doc_subtype      IN      po_headers.type_lookup_code%TYPE,
  x_po_line_record      IN OUT NOCOPY  po_lines%ROWTYPE,
  x_orig_po_line_id     IN      po_lines.po_line_id%TYPE,
  x_wip_install_status  IN      VARCHAR2,
  x_sob_id              IN      financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id          IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_po_header_id        IN      po_lines.po_header_id%TYPE,
  x_copy_attachments    IN      BOOLEAN,
  x_copy_price          IN      BOOLEAN,
  x_online_report_id    IN      po_online_report_text.online_report_id%TYPE,
  x_sequence            IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_return_code         OUT NOCOPY     NUMBER,
  p_is_complex_work_po  IN      BOOLEAN  -- <Complex Work R12>
);

--< Shared Proc FPJ Start >
PROCEDURE process_shipment
(
    p_action_code           IN     VARCHAR2,
    p_to_doc_subtype        IN     VARCHAR2,
    p_orig_line_location_id IN     NUMBER,
    p_po_header_id          IN     NUMBER,
    p_po_line_id            IN     NUMBER,
    p_item_category_id      IN     NUMBER,         --< Shared Proc FPJ >
    p_copy_attachments      IN     BOOLEAN,
    p_copy_price            IN     BOOLEAN,
    p_online_report_id      IN     NUMBER,
    p_line_num              IN     NUMBER,
    p_inv_org_id            IN     NUMBER,
    p_item_id               IN     NUMBER, -- Bug 3433867
    x_po_shipment_record    IN OUT NOCOPY PO_LINE_LOCATIONS%ROWTYPE,
    x_sequence              IN OUT NOCOPY NUMBER,
    x_return_code           OUT    NOCOPY NUMBER,
    p_is_complex_work_po    IN     BOOLEAN  -- <Complex Work R12>
);

--<Encumbrance FPJ: add sob_id to param list>
PROCEDURE process_distribution
(
    p_action_code                IN     VARCHAR2,
    p_to_doc_subtype             IN     VARCHAR2,
    p_orig_po_distribution_id    IN     NUMBER,
    p_generate_new_accounts      IN     BOOLEAN,
    p_copy_attachments           IN     BOOLEAN,
    p_online_report_id           IN     NUMBER,
    p_po_header_rec              IN     PO_HEADERS%ROWTYPE,
    p_po_line_rec                IN     PO_LINES%ROWTYPE,
    p_po_shipment_rec            IN     PO_LINE_LOCATIONS%ROWTYPE,
    p_sob_id                     IN     FINANCIALS_SYSTEM_PARAMETERS.set_of_books_id%TYPE,
    x_po_distribution_rec        IN OUT NOCOPY PO_DISTRIBUTIONS%ROWTYPE,
    x_sequence                   IN OUT NOCOPY NUMBER,
    x_return_code                OUT    NOCOPY NUMBER
);
--< Shared Proc FPJ End >

-- Global variable declarations

g_debug_flag            BOOLEAN := TRUE;
--<R12 eTax Integration>
g_tax_attribute_update_code PO_HEADERS_ALL.tax_attribute_update_code%TYPE;

-- End of Global variable declarations


PROCEDURE copydoc_debug(
  x_message IN VARCHAR2
) IS
BEGIN
  IF (g_debug_flag) THEN
    --dbms_output.put_line('[Debug] '||x_message);
    null;
  END IF;
END;

--<HTML Agreements R12 Start>
-- Making this procedure a autonomous transaction so that even if copy doc
-- fails we should get the error
--<HTML Agreements R12 End>
PROCEDURE online_report(
  x_online_report_id  IN      po_online_report_text.online_report_id%TYPE,
  x_sequence          IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_message           IN      po_online_report_text.text_line%TYPE,
  x_line_num          IN      po_online_report_text.line_num%TYPE,
  x_shipment_num      IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num  IN      po_online_report_text.distribution_num%TYPE,
  x_message_type      IN      VARCHAR2 -- <PO_PJM_VALIDATION FPI>
) IS
  pragma AUTONOMOUS_TRANSACTION; --<HTML Agreements R12>
  x_text_line             po_online_report_text.text_line%TYPE := NULL;
  x_line_num_msg          VARCHAR2(100) := NULL;
  x_shipment_num_msg      VARCHAR2(100) := NULL;
  x_distribution_num_msg  VARCHAR2(100) := NULL;
-- <PO_PJM_VALIDATION FPI>
-- Increased x_text_line_length to 2000 (length of PO_ONLINE_REPORT_TEXT.text_line);
-- changed substr to substrb below to handle multibyte characters.
  x_text_line_length      NUMBER := 2000;

BEGIN

  IF ((x_online_report_id IS NULL) OR (x_message IS NULL) OR (nvl(x_sequence, 0) < 1)) THEN
    RETURN;
  END IF;

  IF (nvl(x_line_num, 0) >= 1) THEN
    x_line_num_msg := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    x_text_line := substrb(x_line_num_msg || x_line_num || ' ', 1, x_text_line_length);
    IF (nvl(x_shipment_num, 0) >= 1) THEN
      x_shipment_num_msg := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
      x_text_line := substrb(x_text_line || x_shipment_num_msg || x_shipment_num || ' ', 1, x_text_line_length);
      IF (nvl(x_distribution_num, 0) >= 1) THEN
        x_distribution_num_msg := fnd_message.get_string('PO', 'PO_ZMVOR_DISTRIBUTION');
        x_text_line := substrb(x_text_line || x_distribution_num_msg || x_distribution_num || ' ', 1, x_text_line_length);
      END IF;
    END IF;
  END IF;

  x_text_line := substrb(x_text_line || x_message, 1, x_text_line_length);

  BEGIN
    INSERT INTO PO_ONLINE_REPORT_TEXT (
      online_report_id,
      sequence,
      last_updated_by,
      last_update_date,
      created_by,
      creation_date,
      last_update_login,
      text_line,
      message_type -- <PO_PJM_VALIDATION FPI>
    )
    VALUES (
      x_online_report_id,
      x_sequence,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id,
      x_text_line,
      x_message_type -- <PO_PJM_VALIDATION FPI>
    );
  COMMIT;

    x_sequence := x_sequence + 1;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END online_report;

--<HTML AGREEMENTS R12 Start>
------------------------------------------------------------------------
--Start of Comments
--Name: ret_and_del_online_report_rec
--Pre-reqs:
--  None.
--Modifies:
--  po_online_report_text.
--Locks:
--  None.
--Function:
-- This procedure would return the message_text and message_type
-- and would also delete the data from the po_online_report_text.
-- As this procedure is an autonomous transaction we would commit
-- as soon as we delete
--IN:
-- p_online_report_id
-- Online Report Id of the message to be retrieved and deleted
--OUT:
--x_message_type
-- MessageType for online report message if any inserted to the table
-- while procedure execution
--x_text_line
-- Message if any inserted to the online_report_text table while procedure
-- execution.
--Testing:
-- Refer the Unit Test Plan for 'HTML Agreements R12'
--End of Comments
----------------------------------------------------------------------------
PROCEDURE ret_and_del_online_report_rec( p_online_report_id  IN         NUMBER
                                        ,x_message_type      OUT NOCOPY VARCHAR2
                                        ,x_message           OUT NOCOPY VARCHAR2)
IS
  pragma AUTONOMOUS_TRANSACTION;
  d_pos      NUMBER;
  d_module   VARCHAR2(70) := 'po.plsql.PO_COPYDOC_S1.RET_AND_DEL_ONLINE_REPORT_REC';
  d_log_msg  VARCHAR2(200);
   /*Bug:13077836 start */
  TYPE MsgTextLineTab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  TYPE MsgTypeTab IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  l_message_type MsgTypeTab;
  l_message MsgTextLineTab;
  /*Bug:13077836 end */
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
  END IF;
  d_pos := 10;
  DELETE PO_ONLINE_REPORT_TEXT
  WHERE ONLINE_REPORT_ID = p_online_report_id
  RETURNING MESSAGE_TYPE, TEXT_LINE
  BULK COLLECT INTO  l_message_type, l_message;  /*Bug:13077836 delete is returning more than one row*/
  d_pos := 20;
  FOR l_index in 1..l_message.COUNT LOOP
  x_message:=x_message||l_message(l_index)||'~';
  x_message_type:=l_message_type(l_index);
  End Loop;

  IF PO_LOG.d_stmt THEN
   PO_LOG.stmt(d_module,d_pos,'x_message_type',x_message_type);
   PO_LOG.stmt(d_module,d_pos,'x_message',x_message);
  END IF;
  COMMIT;
  d_pos := 30;
  IF PO_LOG.d_event THEN
    PO_LOG.event(d_module,d_pos,'Committed after Deleting Record from PO_Online_Report_Text');
  END IF;
  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_module,'x_message_type',x_message_type);
    PO_LOG.proc_end(d_module,'x_message',x_message);
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    d_log_msg := 'Unhandled Exception in ' || d_module;
    IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_module,d_pos,d_log_msg);
    END IF;
    RAISE;
END ret_and_del_online_report_rec;
--<HTML AGREEMENTS R12 End>

PROCEDURE copydoc_sql_error(
  x_routine           IN      VARCHAR2,
  x_progress          IN      VARCHAR2,
  x_sqlcode           IN      NUMBER,
  x_online_report_id  IN      po_online_report_text.online_report_id%TYPE,
  x_sequence          IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num          IN      po_online_report_text.line_num%TYPE,
  x_shipment_num      IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num  IN      po_online_report_text.distribution_num%TYPE
) IS

  x_message  VARCHAR2(240);

BEGIN

  fnd_message.set_name('PO', 'PO_ALL_SQL_ERROR');
  fnd_message.set_token('ROUTINE', x_routine);
  fnd_message.set_token('ERR_NUMBER', x_progress);
  fnd_message.set_token('SQL_ERR', SQLERRM(x_sqlcode));

  x_message := substr(fnd_message.get, 1, 240);

  online_report(x_online_report_id,
                x_sequence,
                x_message,
                x_line_num,
                x_shipment_num,
                x_distribution_num);

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END copydoc_sql_error;

/*************************************************************
 **  Get all the header info for the document with x_from_po_header_id
 **  and store into x_po_header_record for future processing
*************************************************************/
PROCEDURE fetch_header(
  x_po_header_record   IN OUT NOCOPY  PO_HEADERS%ROWTYPE,
  x_from_po_header_id  IN      po_headers.po_header_id%TYPE,
  x_online_report_id   IN      po_online_report_text.online_report_id%TYPE,
  x_sequence           IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_return_code        OUT NOCOPY     NUMBER
) IS

  x_progress  VARCHAR2(4);

BEGIN

  x_progress := '001';

  SELECT *
  INTO   x_po_header_record
  FROM   PO_HEADERS
  WHERE  po_header_id = x_from_po_header_id;

  x_return_code := 0;

EXCEPTION
  WHEN OTHERS THEN
    copydoc_sql_error('fetch_header', x_progress, sqlcode,
                      x_online_report_id,
                      x_sequence,
                      0, 0, 0);
    x_return_code := -1;
END fetch_header;


/****************************************************************
 ** create new PO record from info. stored in x_po_header_record
****************************************************************/
PROCEDURE insert_header(
  x_po_header_record  IN      PO_HEADERS%ROWTYPE,
  x_online_report_id  IN      po_online_report_text.online_report_id%TYPE,
  x_sequence          IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_return_code       OUT NOCOPY     NUMBER,
  x_copy_terms        IN VARCHAR2    --<CONTERMS FPJ>
) IS

  l_progress  VARCHAR2(4);
-- Bug: 1566075 Declare variable
  tmp_pay_on_code      VARCHAR2(25) := NULL;
  tmp_vendor_site_id   NUMBER := NULL;

    --< Shared Proc FPJ Start >
    l_org_assign_rec PO_GA_ORG_ASSIGNMENTS%ROWTYPE;
    l_org_row_id     ROWID;
    --< Shared Proc FPJ End >

    l_return_status VARCHAR2(1);
    l_msg_data VARCHAR2(2000);
    l_msg_count NUMBER;

    l_ame_approval_id NUMBER; --PO AME Approval Workflow changes
    l_ame_transaction_type po_headers_all.ame_transaction_type%type; --Bug 14605943

BEGIN

  l_progress := '000';

  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_stmt
          (p_log_head => g_module_prefix||'insert_header',
           p_token    => 'invoked',
           p_message  => 'header ID: '||x_po_header_record.po_header_id||
                         ' online_report ID: '||x_online_report_id);
  END IF;

   /* PO AME Approval workflow change : Fetch next sequence value of ame_approval_id
    in case AME transaction type is populated in Style Headers page*/
  -- Start : PO AME Approval workflow
  l_ame_approval_id := null;
  l_ame_transaction_type := NULL;
  IF (x_po_header_record.type_lookup_code = 'STANDARD'
     OR (x_po_header_record.type_lookup_code in ('BLANKET','CONTRACT')
         AND nvl(x_po_header_record.global_agreement_flag,'N') = 'Y')) THEN
  BEGIN
		SELECT po_ame_approvals_s.NEXTVAL , ame_transaction_type -- Bug 14605943
		INTO   l_ame_approval_id, l_ame_transaction_type
		FROM   po_doc_style_headers podsh
		WHERE  podsh.style_id= x_po_header_record.style_id
		AND podsh.ame_transaction_type IS NOT NULL;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			l_ame_approval_id := null;
			l_ame_transaction_type := NULL; -- Bug 14605943
  END;
  END IF;
  -- End : PO AME Approval workflow

  -- Bug #2015328, added decode statements to null out start_date and
  -- end_date when a standard purchase order is copied from other type
  -- of docs. This is because the std. purchase order should not have
  -- the start and end date defined in terms and conditions.
  INSERT INTO PO_HEADERS (
    acceptance_due_date,
    acceptance_required_flag,
    agent_id,
    amount_limit,
    approval_required_flag,
    approved_date,
    approved_flag,
    attribute1,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute_category,
    authorization_status,
    bill_to_location_id,
    blanket_total_amount,
    cancel_flag,
    closed_code,
    closed_date,
    comments,
    confirming_order_flag,
    created_by,
    creation_date,
    currency_code,
    edi_processed_flag,
    edi_processed_status,
    enabled_flag,
    end_date,
    end_date_active,
    firm_date,
    firm_status_lookup_code,
    fob_lookup_code,
    freight_terms_lookup_code,
    from_header_id,
    from_type_lookup_code,
    frozen_flag,
    global_agreement_flag,      -- Global Agreements (FP-I)
    global_attribute1,
    global_attribute10,
    global_attribute11,
    global_attribute12,
    global_attribute13,
    global_attribute14,
    global_attribute15,
    global_attribute16,
    global_attribute17,
    global_attribute18,
    global_attribute19,
    global_attribute2,
    global_attribute20,
    global_attribute3,
    global_attribute4,
    global_attribute5,
    global_attribute6,
    global_attribute7,
    global_attribute8,
    global_attribute9,
    global_attribute_category,
    government_context,
    interface_source_code,
    last_updated_by,
    last_update_date,
    last_update_login,
    min_release_amount,
    mrc_rate,
    mrc_rate_date,
    mrc_rate_type,
    note_to_authorizer,
    note_to_receiver,
    note_to_vendor,
    org_id,
    pay_on_code,
    pcard_id,
    po_header_id,
    price_update_tolerance,
    printed_date,
    print_count,
    -- Standard WHO column: program_application_id,
    -- Standard WHO column: program_id,
    -- Standard WHO column: program_update_date,
    quotation_class_code,
    quote_type_lookup_code,
    quote_vendor_quote_number,
    quote_warning_delay,
    quote_warning_delay_unit,
    rate,
    rate_date,
    rate_type,
    reference_num,
    reply_date,
    reply_method_lookup_code,
    -- Standard WHO column:   request_id,
    revised_date,
    revision_num,
    rfq_close_date,
    segment1,
    segment2,
    segment3,
    segment4,
    segment5,
    ship_to_location_id,
    ship_via_lookup_code,
    start_date,
    start_date_active,
    status_lookup_code,
    summary_flag,
    supply_agreement_flag,
    terms_id,
    type_lookup_code,
    user_hold_flag,
    vendor_contact_id,
    vendor_id,
    vendor_order_num,
    vendor_site_id,
    wf_item_key,
    wf_item_type,
    shipping_control,    -- <INBOUND LOGISTICS FPJ>
    conterms_exist_flag,  -- <CONTERMS FPJ>
    encumbrance_required_flag, -- <ENCUMBRANCE FPJ>
    document_creation_method  -- <DBI FPJ>
    ,style_id               --<R12 STYLES PHASE II >
    ,tax_attribute_update_code --<R12 eTax Integration>
    , created_language     -- <Unified Catalog R12>
    , last_updated_program -- <Unified Catalog R12>
    -- Bug 5295179 START
    , supplier_notif_method
    , fax
    , email_address
    -- Bug 5295179 END
    , Enable_All_Sites  -- <R12.1 GCPA >
   ,ame_approval_id -- PO AME Approval Workflow changes
   ,ame_transaction_type -- PO AME Approval Workflow changes
  ) VALUES (
    x_po_header_record.acceptance_due_date,
    x_po_header_record.acceptance_required_flag,
    x_po_header_record.agent_id,
    x_po_header_record.amount_limit,
    x_po_header_record.approval_required_flag,
    x_po_header_record.approved_date,
    x_po_header_record.approved_flag,
    x_po_header_record.attribute1,
    x_po_header_record.attribute10,
    x_po_header_record.attribute11,
    x_po_header_record.attribute12,
    x_po_header_record.attribute13,
    x_po_header_record.attribute14,
    x_po_header_record.attribute15,
    x_po_header_record.attribute2,
    x_po_header_record.attribute3,
    x_po_header_record.attribute4,
    x_po_header_record.attribute5,
    x_po_header_record.attribute6,
    x_po_header_record.attribute7,
    x_po_header_record.attribute8,
    x_po_header_record.attribute9,
    x_po_header_record.attribute_category,
    x_po_header_record.authorization_status,
    x_po_header_record.bill_to_location_id,
    x_po_header_record.blanket_total_amount,
    x_po_header_record.cancel_flag,
    x_po_header_record.closed_code,
    x_po_header_record.closed_date,
    x_po_header_record.comments,
    x_po_header_record.confirming_order_flag,
    x_po_header_record.created_by,
    x_po_header_record.creation_date,
    x_po_header_record.currency_code,
    x_po_header_record.edi_processed_flag,
    x_po_header_record.edi_processed_status,
    x_po_header_record.enabled_flag,
    decode(x_po_header_record.type_lookup_code, 'STANDARD', to_date(NULL),
     x_po_header_record.end_date),  -- Bug #2015328  BUG #5743193
    x_po_header_record.end_date_active,
    x_po_header_record.firm_date,
    x_po_header_record.firm_status_lookup_code,
    x_po_header_record.fob_lookup_code,
    x_po_header_record.freight_terms_lookup_code,
    x_po_header_record.from_header_id,
    x_po_header_record.from_type_lookup_code,
    x_po_header_record.frozen_flag,
    x_po_header_record.global_agreement_flag,   -- Global Agreements (FP-I)
    x_po_header_record.global_attribute1,
    x_po_header_record.global_attribute10,
    x_po_header_record.global_attribute11,
    x_po_header_record.global_attribute12,
    x_po_header_record.global_attribute13,
    x_po_header_record.global_attribute14,
    x_po_header_record.global_attribute15,
    x_po_header_record.global_attribute16,
    x_po_header_record.global_attribute17,
    x_po_header_record.global_attribute18,
    x_po_header_record.global_attribute19,
    x_po_header_record.global_attribute2,
    x_po_header_record.global_attribute20,
    x_po_header_record.global_attribute3,
    x_po_header_record.global_attribute4,
    x_po_header_record.global_attribute5,
    x_po_header_record.global_attribute6,
    x_po_header_record.global_attribute7,
    x_po_header_record.global_attribute8,
    x_po_header_record.global_attribute9,
    x_po_header_record.global_attribute_category,
    x_po_header_record.government_context,
    x_po_header_record.interface_source_code,
    x_po_header_record.last_updated_by,
    x_po_header_record.last_update_date,
    x_po_header_record.last_update_login,
    decode(x_po_header_record.global_agreement_flag , 'Y' , null ,
                        x_po_header_record.min_release_amount) ,
    x_po_header_record.mrc_rate,
    x_po_header_record.mrc_rate_date,
    x_po_header_record.mrc_rate_type,
    x_po_header_record.note_to_authorizer,
    x_po_header_record.note_to_receiver,
    x_po_header_record.note_to_vendor,
    x_po_header_record.org_id,
    x_po_header_record.pay_on_code,         -- <BUG 4766467>
    x_po_header_record.pcard_id,
    x_po_header_record.po_header_id,
    x_po_header_record.price_update_tolerance,
    x_po_header_record.printed_date,
    x_po_header_record.print_count,
    -- Standard WHO column: x_po_header_record.program_application_id,
    -- Standard WHO column: x_po_header_record.program_id,
    -- Standard WHO column: x_po_header_record.program_update_date,
    x_po_header_record.quotation_class_code,
    x_po_header_record.quote_type_lookup_code,
    x_po_header_record.quote_vendor_quote_number,
    x_po_header_record.quote_warning_delay,
    x_po_header_record.quote_warning_delay_unit,
    x_po_header_record.rate,
    x_po_header_record.rate_date,
    x_po_header_record.rate_type,
    x_po_header_record.reference_num,
    x_po_header_record.reply_date,
    x_po_header_record.reply_method_lookup_code,
    -- Standard WHO column: x_po_header_record.request_id,
    x_po_header_record.revised_date,
    x_po_header_record.revision_num,
    x_po_header_record.rfq_close_date,
    x_po_header_record.segment1,
    x_po_header_record.segment2,
    x_po_header_record.segment3,
    x_po_header_record.segment4,
    x_po_header_record.segment5,
    x_po_header_record.ship_to_location_id,
    x_po_header_record.ship_via_lookup_code,
    decode(x_po_header_record.type_lookup_code, 'STANDARD' , to_date(NULL),
     x_po_header_record.start_date), -- Bug #2015328  Bug #5743193
    x_po_header_record.start_date_active,
    x_po_header_record.status_lookup_code,
    x_po_header_record.summary_flag,
    x_po_header_record.supply_agreement_flag,
    x_po_header_record.terms_id,
    x_po_header_record.type_lookup_code,
    x_po_header_record.user_hold_flag,
    x_po_header_record.vendor_contact_id,
    x_po_header_record.vendor_id,
    x_po_header_record.vendor_order_num,
    x_po_header_record.vendor_site_id,
    x_po_header_record.wf_item_key,
    x_po_header_record.wf_item_type,
    x_po_header_record.shipping_control,    -- <INBOUND LOGISTICS FPJ>
    decode(x_copy_terms, 'N', 'N', x_po_header_record.conterms_exist_flag),
                                                        -- <CONTERMS FPJ>
    x_po_header_record.encumbrance_required_flag, -- <ENCUMBRANCE FPJ>
    -- Bug 3648268 Use lookup code instead of hardcoded value
    'COPY_DOCUMENT' --<DBI FPJ>
   ,x_po_header_record.style_id         --<R12 STYLES PHASE II >
   ,g_tax_attribute_update_code --<R12 eTax Integration>
   , x_po_header_record.created_language -- <Unified Catalog R12>
   , 'COPY_DOC'                          -- <Unified Catalog R12>
    -- Bug 5295179 START
    , x_po_header_record.supplier_notif_method
    , x_po_header_record.fax
    , x_po_header_record.email_address
    -- Bug 5295179 END
    , decode(x_po_header_record.type_lookup_code,
             'CONTRACT',x_po_header_record.Enable_All_Sites,
             NULL) -- <R12.1 GCPA>
    ,l_ame_approval_id -- PO AME Approval Workflow changes
	,l_ame_transaction_type -- PO AME Approval Workflow changes --14605943
  );

    l_progress := '030';

    -- Global Agreements (FP-I): If Global Agreement, must also insert
    -- assignment information for Owning Org into PO_GA_ORG_ASSIGNMENTS.
    --
    IF ( x_po_header_record.global_agreement_flag = 'Y' ) THEN

        l_progress := '050';

        --< Shared Proc FPJ Start >
        -- Refactor code to use GA utility procedures and row handlers

        IF (PO_GA_PVT.is_global_agreement
                (p_po_header_id => x_po_header_record.from_header_id))
        THEN
            l_progress := '060';
            -- The original document is a global agreement, so blindly copy all
            -- of its org assignments over for the new GA.

            PO_GA_ORG_ASSIGN_PVT.copy_rows
               (p_init_msg_list     => FND_API.g_false,
                x_return_status     => l_return_status,
                p_from_po_header_id => x_po_header_record.from_header_id,
                p_to_po_header_id   => x_po_header_record.po_header_id,
                p_last_update_date  => x_po_header_record.last_update_date,
                p_last_updated_by   => x_po_header_record.last_updated_by,
                p_creation_date     => x_po_header_record.creation_date,
                p_created_by        => x_po_header_record.created_by,
                p_last_update_login => x_po_header_record.last_update_login);

       ELSE
            l_progress := '070';
            -- The original document is not a global agreement, so just insert
            -- one org assignment for the owning org.

            l_org_assign_rec.po_header_id := x_po_header_record.po_header_id;
            l_org_assign_rec.organization_id := x_po_header_record.org_id;
            l_org_assign_rec.enabled_flag := 'Y';
            l_org_assign_rec.vendor_site_id :=
                                    x_po_header_record.vendor_site_id;
            l_org_assign_rec.last_update_date :=
                                    x_po_header_record.last_update_date;
            l_org_assign_rec.last_updated_by :=
                                    x_po_header_record.last_updated_by;
            l_org_assign_rec.creation_date := x_po_header_record.creation_date;
            l_org_assign_rec.created_by := x_po_header_record.created_by;
            l_org_assign_rec.last_update_login :=
                                    x_po_header_record.last_update_login;
            l_org_assign_rec.purchasing_org_id := x_po_header_record.org_id;

            PO_GA_ORG_ASSIGN_PVT.insert_row
               (p_init_msg_list  => FND_API.g_false,
                x_return_status  => l_return_status,
                p_org_assign_rec => l_org_assign_rec,
                x_row_id         => l_org_row_id);

       END IF;

       -- Check the return status of call to row handler
       IF (l_return_status <> FND_API.g_ret_sts_success) THEN
           RAISE FND_API.g_exc_error;
       END IF;
       --< Shared Proc FPJ End >

    END IF;

    x_return_code := 0;

EXCEPTION
  WHEN OTHERS THEN
    copydoc_sql_error('insert_header', l_progress, sqlcode,
                      x_online_report_id,
                      x_sequence,
                      0, 0, 0);
    x_return_code := -1;
    IF g_debug_unexp THEN            --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_exc
            (p_log_head => g_module_prefix||'insert_header',
             p_progress => l_progress);
    END IF;
END insert_header;


/** create new line record with info from x_po_line_record **/
PROCEDURE insert_line(
  x_po_line_record    IN      po_lines%ROWTYPE,
  x_online_report_id  IN      po_online_report_text.online_report_id%TYPE,
  x_sequence          IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_return_code       OUT NOCOPY     NUMBER
) IS

  l_progress  VARCHAR2(4);

  -- <SERVICES FPJ START>
  l_order_type_lookup_code PO_LINE_TYPES_B.order_type_lookup_code%TYPE;
  l_purchase_basis PO_LINE_TYPES_B.purchase_basis%TYPE;
  l_matching_basis PO_LINE_TYPES_B.matching_basis%TYPE;
  l_category_id PO_LINE_TYPES_B.category_id%TYPE;
  l_unit_meas_lookup_code PO_LINE_TYPES_B.unit_of_measure%TYPE;
  l_unit_price PO_LINE_TYPES_B.unit_price%TYPE;
  l_outside_operation_flag PO_LINE_TYPES_B.outside_operation_flag%TYPE;
  l_receiving_flag PO_LINE_TYPES_B.receiving_flag%TYPE;
  l_receive_close_tolerance PO_LINE_TYPES_B.receive_close_tolerance%TYPE;
  -- <SERVICES FPJ END>

BEGIN

  l_progress := '001';

  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_stmt
          (p_log_head => g_module_prefix||'insert_line',
           p_token    => 'invoked',
           p_message  => 'line ID: '||x_po_line_record.po_line_id||
                         ' online_report ID: '||x_online_report_id);
  END IF;

  -- <SERVICES FPJ START>
  -- Retrieve the values for order_type_lookup_code, purchase_basis
  -- and matching_basis
  PO_LINE_TYPES_SV.get_line_type_def(
                   x_po_line_record.line_type_id,
                   l_order_type_lookup_code,
                   l_purchase_basis,
                   l_matching_basis,
                   l_category_id,
                   l_unit_meas_lookup_code,
                   l_unit_price,
                   l_outside_operation_flag,
                   l_receiving_flag,
                   l_receive_close_tolerance);
  -- <SERVICES FPJ END>

  -- <SERVICES FPJ>
  -- Added order_type_lookup_code, purchase_basis and matching_basis
  -- for PO Line level denormalization
  INSERT INTO PO_LINES (
    allow_price_override_flag,
    attribute1,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute_category,
    base_qty,
    base_uom,
    cancelled_by,
    cancel_date,
    cancel_flag,
    cancel_reason,
    capital_expense_flag,
    category_id,
    closed_by,
    closed_code,
    closed_date,
    closed_flag,
    closed_reason,
    committed_amount,
    -- contract_num,    -- <GC FPJ>
    contract_id,        -- <GC FPJ>
    created_by,
    creation_date,
    expiration_date,
    firm_date,
    firm_status_lookup_code,
    from_header_id,
    from_line_id,
    from_line_location_id,                                    -- <SERVICES FPJ>
    global_attribute1,
    global_attribute10,
    global_attribute11,
    global_attribute12,
    global_attribute13,
    global_attribute14,
    global_attribute15,
    global_attribute16,
    global_attribute17,
    global_attribute18,
    global_attribute19,
    global_attribute2,
    global_attribute20,
    global_attribute3,
    global_attribute4,
    global_attribute5,
    global_attribute6,
    global_attribute7,
    global_attribute8,
    global_attribute9,
    global_attribute_category,
    government_context,
    hazard_class_id,
    item_description,
    item_id,
    item_revision,
    last_updated_by,
    last_update_date,
    last_update_login,
    line_num,
    line_reference_num,
    line_type_id,
    list_price_per_unit,
    market_price,
    max_order_quantity,
    min_order_quantity,
    min_release_amount,
    negotiated_by_preparer_flag,
    note_to_vendor,
    not_to_exceed_price,
    org_id,
    over_tolerance_error_flag,
    po_header_id,
    po_line_id,
    price_break_lookup_code,
    price_type_lookup_code,
    project_id,
    qc_grade,
    qty_rcv_tolerance,
    quantity,
    quantity_committed,
    reference_num,
    secondary_qty,
    secondary_uom,
    task_id,
    taxable_flag,
    tax_code_id,
    transaction_reason_code,
    type_1099,
    unit_meas_lookup_code,
    unit_price,
    base_unit_price,    -- <FPJ Advanced Price>
    unordered_flag,
    un_number_id,
    user_hold_flag,
    vendor_product_num,
    oke_contract_header_id,     --added oke columns
    oke_contract_version_id,    --added oke columns
    secondary_unit_of_measure,  -- 1548597
    secondary_quantity,         -- 1548597
    preferred_grade,            -- 1548597
    job_id,                     -- Services FPJ
    amount,                     -- Services FPJ
    start_date,                 -- Services FPJ
    contractor_first_name,      -- Services FPJ
    contractor_last_name,       -- Services FPJ
    order_type_lookup_code,     -- <SERVICES FPJ>
    purchase_basis,             -- <SERVICES FPJ>
    matching_basis,             -- <SERVICES FPJ>
    manual_price_change_flag    --<MANUAL PRICE OVERRIDE FPJ>
    ,tax_attribute_update_code  --<R12 eTax Integration>
    , retainage_rate            -- <Complex Work R12>
    , max_retainage_amount      -- <Complex Work R12>
    , progress_payment_rate     -- <Complex Work R12>
    , recoupment_rate           -- <Complex Work R12>
    , catalog_name              -- <Unified Catalog R12>
    , supplier_part_auxid       -- <Unified Catalog R12>
    , ip_category_id            -- <Unified Catalog R12>
    , last_updated_program      -- <Unified Catalog R12>
  ) VALUES (
    x_po_line_record.allow_price_override_flag,
    x_po_line_record.attribute1,
    x_po_line_record.attribute10,
    x_po_line_record.attribute11,
    x_po_line_record.attribute12,
    x_po_line_record.attribute13,
    x_po_line_record.attribute14,
    x_po_line_record.attribute15,
    x_po_line_record.attribute2,
    x_po_line_record.attribute3,
    x_po_line_record.attribute4,
    x_po_line_record.attribute5,
    x_po_line_record.attribute6,
    x_po_line_record.attribute7,
    x_po_line_record.attribute8,
    x_po_line_record.attribute9,
    x_po_line_record.attribute_category,
    x_po_line_record.base_qty,
    x_po_line_record.base_uom,
    x_po_line_record.cancelled_by,
    x_po_line_record.cancel_date,
    x_po_line_record.cancel_flag,
    x_po_line_record.cancel_reason,
    x_po_line_record.capital_expense_flag,
    x_po_line_record.category_id,
    x_po_line_record.closed_by,
    x_po_line_record.closed_code,
    x_po_line_record.closed_date,
    x_po_line_record.closed_flag,
    x_po_line_record.closed_reason,
    x_po_line_record.committed_amount,
    -- x_po_line_record.contract_num,   -- <GC FPJ>
    x_po_line_record.contract_id,       -- <GC FPJ>
    x_po_line_record.created_by,
    x_po_line_record.creation_date,
    x_po_line_record.expiration_date,
    x_po_line_record.firm_date,
    x_po_line_record.firm_status_lookup_code,
    x_po_line_record.from_header_id,
    x_po_line_record.from_line_id,
    x_po_line_record.from_line_location_id,                   -- <SERVICES FPJ>
    x_po_line_record.global_attribute1,
    x_po_line_record.global_attribute10,
    x_po_line_record.global_attribute11,
    x_po_line_record.global_attribute12,
    x_po_line_record.global_attribute13,
    x_po_line_record.global_attribute14,
    x_po_line_record.global_attribute15,
    x_po_line_record.global_attribute16,
    x_po_line_record.global_attribute17,
    x_po_line_record.global_attribute18,
    x_po_line_record.global_attribute19,
    x_po_line_record.global_attribute2,
    x_po_line_record.global_attribute20,
    x_po_line_record.global_attribute3,
    x_po_line_record.global_attribute4,
    x_po_line_record.global_attribute5,
    x_po_line_record.global_attribute6,
    x_po_line_record.global_attribute7,
    x_po_line_record.global_attribute8,
    x_po_line_record.global_attribute9,
    x_po_line_record.global_attribute_category,
    x_po_line_record.government_context,
    x_po_line_record.hazard_class_id,
    x_po_line_record.item_description,
    x_po_line_record.item_id,
    x_po_line_record.item_revision,
    x_po_line_record.last_updated_by,
    x_po_line_record.last_update_date,
    x_po_line_record.last_update_login,
    x_po_line_record.line_num,
    x_po_line_record.line_reference_num,
    x_po_line_record.line_type_id,
    x_po_line_record.list_price_per_unit,
    x_po_line_record.market_price,
    x_po_line_record.max_order_quantity,
    x_po_line_record.min_order_quantity,
    x_po_line_record.min_release_amount,
    x_po_line_record.negotiated_by_preparer_flag,
    x_po_line_record.note_to_vendor,
    x_po_line_record.not_to_exceed_price,
    x_po_line_record.org_id,
    x_po_line_record.over_tolerance_error_flag,
    x_po_line_record.po_header_id,
    x_po_line_record.po_line_id,
    x_po_line_record.price_break_lookup_code,
    x_po_line_record.price_type_lookup_code,
    x_po_line_record.project_id,
    x_po_line_record.qc_grade,
    x_po_line_record.qty_rcv_tolerance,
    x_po_line_record.quantity,
    x_po_line_record.quantity_committed,
    x_po_line_record.reference_num,
    x_po_line_record.secondary_qty,
    x_po_line_record.secondary_uom,
    x_po_line_record.task_id,
    x_po_line_record.taxable_flag,
    x_po_line_record.tax_code_id,
    x_po_line_record.transaction_reason_code,
    x_po_line_record.type_1099,
    x_po_line_record.unit_meas_lookup_code,
    x_po_line_record.unit_price,
    x_po_line_record.base_unit_price,   -- <FPJ Advanced Price>
    x_po_line_record.unordered_flag,
    x_po_line_record.un_number_id,
    x_po_line_record.user_hold_flag,
    x_po_line_record.vendor_product_num,
    x_po_line_record.oke_contract_header_id,     -- added oke columns
    x_po_line_record.oke_contract_version_id,    -- added oke columns
    x_po_line_record.secondary_unit_of_measure,  -- 1548597
    x_po_line_record.secondary_quantity,         -- 1548597
    x_po_line_record.preferred_grade,            -- 1548597
    x_po_line_record.job_id,                     -- Services FPJ
    x_po_line_record.amount,                     -- Services FPJ
    x_po_line_record.start_date,                 -- Services FPJ
    x_po_line_record.contractor_first_name,      -- Services FPJ
    x_po_line_record.contractor_last_name,       -- Services FPJ
    l_order_type_lookup_code,                    -- <SERVICES FPJ>
    l_purchase_basis,                            -- <SERVICES FPJ>
    l_matching_basis,                            -- <SERVICES FPJ>
    x_po_line_record.manual_price_change_flag    --<MANUAL PRICE OVERRIDE FPJ>
    ,g_tax_attribute_update_code --<R12 eTax Integration>
    , x_po_line_record.retainage_rate            -- <Complex Work R12>
    , x_po_line_record.max_retainage_amount      -- <Complex Work R12>
    , x_po_line_record.progress_payment_rate     -- <Complex Work R12>
    , x_po_line_record.recoupment_rate           -- <Complex Work R12>
    , x_po_line_record.catalog_name              -- <Unified Catalog R12>
    , x_po_line_record.supplier_part_auxid       -- <Unified Catalog R12>
    , x_po_line_record.ip_category_id            -- <Unified Catalog R12>
    , 'COPY_DOC'                                 -- <Unified Catalog R12>
  );


  x_return_code := 0;

EXCEPTION
  WHEN OTHERS THEN
    copydoc_sql_error('insert_line', l_progress, sqlcode,
                      x_online_report_id,
                      x_sequence,
                      x_po_line_record.line_num, 0, 0);
    x_return_code := -1;
    IF g_debug_unexp THEN            --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_exc
            (p_log_head => g_module_prefix||'insert_line',
             p_progress => l_progress);
    END IF;
END insert_line;


PROCEDURE insert_shipment(
  x_po_shipment_record  IN      po_line_locations%ROWTYPE,
  x_online_report_id    IN      po_online_report_text.online_report_id%TYPE,
  x_sequence            IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num            IN      po_online_report_text.line_num%TYPE,
  x_accrue_on_receipt_flag IN   VARCHAR2,
  x_inv_org_id          IN      financials_system_parameters.inventory_organization_id%TYPE, -- Bug 2761415
  x_return_code         OUT NOCOPY     NUMBER,
  p_is_complex_work_po  IN BOOLEAN,     -- <Complex Work R12>
  p_orig_line_location_id IN NUMBER     -- <eTax Integration R12>
) IS

  l_progress  VARCHAR2(4);

--bug #2717053: changed var names/types to conform to standards
  l_vendor_site_id po_headers.vendor_site_id%TYPE := null;
  l_to_ship_to_location_id po_line_locations.ship_to_location_id%TYPE;
  l_to_ship_to_organization_id po_line_locations.ship_to_organization_id%TYPE;
  l_item_id po_lines.item_id%TYPE := null;
  l_count  number:= 0;
  l_quantity po_line_locations.quantity%TYPE;
  l_quote_type_code po_headers.quote_type_lookup_code%TYPE := null;

  x_sob_id number:= null;

  -- CONSIGNED FPI START
  -- Bug Fix for #2697755: COPY PO WITH CONSIGNED SHIPMENT LINE FAILS
  l_vendor_id
    po_headers.vendor_id%TYPE                           := null;
  l_consigned_flag
    po_line_locations.consigned_flag%TYPE               := null;
  l_consigned_from_supplier_flag
    po_asl_attributes.consigned_from_supplier_flag%TYPE := null;
  l_enable_vmi_flag
    po_asl_attributes.enable_vmi_flag%TYPE              := null;
  l_accrue_on_receipt_flag
    po_line_locations.accrue_on_receipt_flag%TYPE       := null;
  l_closed_code
    po_line_locations.closed_code%TYPE                  := null;
  l_closed_reason
    po_line_locations.closed_reason%TYPE                := null;
  l_inspection_required_flag
    po_line_locations.inspection_required_flag%TYPE     := null;
  l_receipt_required_flag
    po_line_locations.receipt_required_flag%TYPE        := null;
  l_match_option
    po_line_locations.match_option%TYPE                 := null;
  l_last_billing_date       date                        := null;
  l_consigned_billing_cycle number                      := null;
  l_invoice_close_tolerance number                      := null;
  l_item_inv_asset_flag
    mtl_system_items_b.inventory_asset_flag%TYPE        := NULL;
  l_return_status varchar2(1)                           := NULL;
  l_msg_count number                                    := NULL;
  l_msg_data varchar2(2000)                             := NULL;
  -- CONSIGNED FPI END

  --<INVCONV R12 START>
  l_unit_meas_lookup_code       MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE := NULL;
  x_secondary_unit_of_measure   MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE := NULL;
  x_secondary_uom_code          MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE := NULL;
  x_secondary_quantity          PO_LINES_ALL.SECONDARY_QUANTITY%TYPE      := NULL;
  --<INVCONV R12 END>

  --<Complex Work R12 START> Bug 4958300
  l_line_value_basis PO_LINE_LOCATIONS_ALL.value_basis%type;
  l_line_matching_basis PO_LINE_LOCATIONS_ALL.matching_basis%type;
  --<Complex Work R12 END>

BEGIN

    l_progress := '000';

    IF g_debug_stmt THEN             --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'insert_shipment',
             p_token    => 'invoked',
             p_message  => 'ship ID: '||x_po_shipment_record.line_location_id||
                    ' inv_org ID: '||x_inv_org_id||' accrue_on_receipt_flag: '||
                    x_accrue_on_receipt_flag||' online_report ID: '||
                    x_online_report_id);
    END IF;

    --bug #2717053: reorganized the defaulting logic for RFQs/Quotations
    --In FPI Timephased, we changed the structure of BPA price breaks so
    --that org, loc and qty could all be null.  Now, when copying these
    --price breaks, we have to make sure we don't copy in org/loc or qty
    --values that couldn't be entered that way on the forms themselves.

    l_to_ship_to_organization_id := x_po_shipment_record.ship_to_organization_id;
    l_to_ship_to_location_id := x_po_shipment_record.ship_to_location_id;
    l_quantity := x_po_shipment_record.quantity;

    l_progress := '010';

    --<INVCONV R12>:added UOM to select below
    --<Complex Work R12> bug 4958300: added value basis/matching basis
    select item_id, unit_meas_lookup_code,
           order_type_lookup_code, matching_basis
    into l_item_id, l_unit_meas_lookup_code,
         l_line_value_basis, l_line_matching_basis
    from po_lines_all
    where po_line_id=x_po_shipment_record.po_line_id;

    -- CONSIGNED FPI START
    -- Bug Fix for #2697755: COPY PO WITH CONSIGNED SHIPMENT LINE FAILS
    -- initialize local variables for shipment attributes with values
    -- passed in from the IN parameters
    l_accrue_on_receipt_flag := x_accrue_on_receipt_flag;
    l_invoice_close_tolerance := x_po_shipment_record.invoice_close_tolerance;
    l_closed_code := x_po_shipment_record.closed_code;
    l_closed_reason := x_po_shipment_record.closed_reason;
    l_inspection_required_flag := x_po_shipment_record.inspection_required_flag;
    l_receipt_required_flag := x_po_shipment_record.receipt_required_flag;
    l_match_option := x_po_shipment_record.match_option;
    -- CONSIGNED FPI END

    IF (x_po_shipment_record.shipment_type IN ('QUOTATION', 'RFQ')) THEN

      l_progress := '020';

      Begin
         SELECT ph.quote_type_lookup_code
         INTO l_quote_type_code
         FROM po_headers ph
         WHERE ph.po_header_id = x_po_shipment_record.po_header_id;
      Exception
         When others then
           l_quote_type_code := NULL;
      End;

      IF (l_quote_type_code IN ('CATALOG', 'STANDARD')) THEN
      --note: we don't do any defaulting for Bid RFQs/Quotes.
      --since we can not copy a document INTO a Bid RFQ, we
      --dont' have to worry about consistency with Forms entry

        IF ((l_to_ship_to_organization_id IS NULL) AND
            (l_to_ship_to_location_id IS NOT NULL)) THEN

          l_progress := '030';

          -- try to infer org if org is null, but loc is not.
          -- (you can not specify a loc w/o an org in the forms)
          -- first check against the hr_locations table
          begin
            select inventory_organization_id
                into l_to_ship_to_organization_id
                from hr_locations_v
                where location_id = l_to_ship_to_location_id
                and ship_to_site_flag = 'Y';
          exception
            when no_data_found then
                l_to_ship_to_organization_id := NULL;
          end;

          l_progress := '040';

          -- check the org value from hr_locations to ensure
          -- that the item is defined in this org
          if (l_to_ship_to_organization_id is NOT NULL) then
              select count(*) into l_count from
                  mtl_system_items where
                  inventory_item_id=l_item_id and
                  organization_id=l_to_ship_to_organization_id ;
              if (l_count=0) then
                  l_to_ship_to_organization_id:=NULL;
              end if;
          end if;

          l_progress := '050';

          -- if there was a null org from hr tables, or if
          -- the item was not valid, use the inv_org from
          -- financials_system_parameters (x_inv_org_id)
          -- if the item is not defined for the FSP org, then
          -- leave the org null.
          if (l_to_ship_to_organization_id is NULL) then
              select count(*) into l_count from
                  mtl_system_items where
                  inventory_item_id=l_item_id and
                  organization_id=x_inv_org_id;
              if (l_count <> 0) then
                  l_to_ship_to_organization_id := x_inv_org_id;
              end if;
          end if;

        END IF; --end of org null/loc not null check

        IF (l_quantity IS NULL) THEN
          --pb qty can not be NULL in RFQ/Quote form: use zero instead
          l_quantity := 0;
        END IF; --end of qty check

      END IF;  --end of l_quote_type_code check

    -- <Complex Work R12>: Also skip complex work POs.
    ELSIF ((NOT p_is_complex_work_po) AND
            (x_po_shipment_record.shipment_type <> 'PRICE BREAK')) THEN
      -- shipment is not a BPA, Quote or RFQ price break

      l_progress := '060';

      IF (l_to_ship_to_organization_id IS NULL) THEN
        l_progress := '070';

        begin
        select vendor_site_id into l_vendor_site_id from
               po_headers where
               po_header_id=x_po_shipment_record.po_header_id;

        select ship_to_location_id into l_to_ship_to_location_id
               from po_vendor_sites where
               vendor_site_id=l_vendor_site_id;

        if (l_to_ship_to_location_id is null) then
        select fsp.ship_to_location_id
        into l_to_ship_to_location_id
        from financials_system_parameters fsp;
        end if;
        SELECT inventory_organization_id
                   INTO l_to_ship_to_organization_id
                   FROM hr_locations_v
                   WHERE location_id = l_to_ship_to_location_id
                   AND ship_to_site_flag = 'Y';
        exception
        when no_data_found then
           l_to_ship_to_organization_id:=null;
        end;

        l_progress := '080';

        select count(*) into l_count from
               mtl_system_items where
               inventory_item_id=l_item_id and
               organization_id=l_to_ship_to_organization_id ;

        if (l_count=0) then
           l_to_ship_to_organization_id:=null;
        end if;

        if l_to_ship_to_organization_id is null then
            return;
        end if;

      END IF; --end check if org_id is NULL

      l_progress := '090';

      -- CONSIGNED FPI START
      -- Bug Fix for #2697755: COPY PO WITH CONSIGNED SHIPMENT LINE FAILS
      IF (x_po_shipment_record.shipment_type = 'STANDARD') THEN

        IF(l_to_ship_to_organization_id IS NOT NULL AND
           l_item_id IS NOT NULL)
        THEN
         l_progress := '100';

         PO_THIRD_PARTY_STOCK_GRP.Get_Item_Inv_Asset_Flag
         (p_api_version          => 1.0                         ,
          p_init_msg_list        => NULL                        ,
          x_return_status        => l_return_status             ,
          x_msg_count            => l_msg_count                 ,
          x_msg_data             => l_msg_data                  ,
          p_organization_id      => l_to_ship_to_organization_id,
          p_inventory_item_id    => l_item_id                   ,
          x_inventory_asset_flag => l_item_inv_asset_flag       );
        END IF;

        IF(l_item_inv_asset_flag = 'Y')
        THEN
          l_progress := '110';

          select vendor_id, vendor_site_id
          into   l_vendor_id, l_vendor_site_id
          from   po_headers
          where  po_header_id = x_po_shipment_record.po_header_id;

          l_progress := '120';

          PO_THIRD_PARTY_STOCK_GRP.get_asl_attributes
          (p_api_version                  => 1.0                           ,
           p_init_msg_list                => NULL                          ,
           x_return_status                => l_return_status               ,
           x_msg_count                    => l_msg_count                   ,
           x_msg_data                     => l_msg_data                    ,
           p_inventory_item_id            => l_item_id                     ,
           p_vendor_id                    => l_vendor_id                   ,
           p_vendor_site_id               => l_vendor_site_id              ,
           p_using_organization_id        => l_to_ship_to_organization_id  ,
           x_consigned_from_supplier_flag => l_consigned_from_supplier_flag,
           x_enable_vmi_flag              => l_enable_vmi_flag             ,
           x_last_billing_date            => l_last_billing_date           ,
           x_consigned_billing_cycle      => l_consigned_billing_cycle     );

          IF(l_consigned_from_supplier_flag = 'Y')
          THEN
            l_consigned_flag := 'Y';
            l_accrue_on_receipt_flag := 'N';
            l_invoice_close_tolerance := 100;
            l_closed_code := 'CLOSED FOR INVOICE';
            FND_MESSAGE.SET_NAME('PO', 'PO_SUP_CONS_CLOSED_REASON');
            l_closed_reason := FND_MESSAGE.GET;
            l_inspection_required_flag := 'N';
            l_receipt_required_flag := 'N';
            l_match_option := 'P';
          END IF;
        END IF;
      END IF; --end if shipment_type is STANDARD
      -- CONSIGNED FPI END

    END IF; --end check of shipment_type
    --bug #2717053: end of reorganized defaulting logic for RFQs/Quotations

  -- Bug 2761415 In 115.35, moved the receipt/invoice close tolerance
  -- defaulting logic (Bug 2473335) to PO_COPYDOC_S4.validate_shipment,
  -- since it should only apply when copying from RFQ's and quotations.

  l_progress := '130';

   --<INVCONV R12 START>
   -- if item is dual uom control , derive shipment secondary quantity and
   -- secondary uom if it is null
   x_secondary_unit_of_measure  := x_po_shipment_record.secondary_unit_of_measure ;
   x_secondary_quantity         := x_po_shipment_record.secondary_quantity ;

   -- <Complex Work R12>: Default null for secondary fields on complex work po

   IF ((NOT p_is_complex_work_po) AND
      (x_po_shipment_record.shipment_type IN ('STANDARD','PLANNED'))) THEN
       IF x_secondary_quantity IS NULL and l_item_id IS NOT NULL THEN

           po_uom_s.get_secondary_uom(l_item_id,
                                      l_to_ship_to_organization_id,
                                      x_secondary_uom_code,
                                      x_secondary_unit_of_measure);

           IF x_secondary_unit_of_measure IS NOT NULL THEN
              PO_UOM_S.uom_convert ( l_quantity,l_unit_meas_lookup_code,l_item_id,
              x_secondary_unit_of_measure ,x_secondary_quantity) ;
           ELSE
              x_secondary_quantity := null ;
              x_secondary_unit_of_measure := null ;
           END IF;
       END IF;
   ELSE
       x_secondary_quantity := null ;
       x_secondary_unit_of_measure := null ;
   END IF;

   --<INVCONV R12 END>

  INSERT INTO PO_LINE_LOCATIONS (
    accrue_on_receipt_flag,
    allow_substitute_receipts_flag,
    approved_date,
    approved_flag,
    attribute1,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute_category,
    calculate_tax_flag,
    cancelled_by,
    cancel_date,
    cancel_flag,
    cancel_reason,
    closed_by,
    closed_code,
    closed_date,
    closed_flag,
    closed_reason,
    country_of_origin_code,
    created_by,
    creation_date,
    days_early_receipt_allowed,
    days_late_receipt_allowed,
    encumbered_date,
    encumbered_flag,
    encumber_now,
    end_date,
    enforce_ship_to_location_code,
    estimated_tax_amount,
    firm_date,
    firm_status_lookup_code,
    fob_lookup_code,
    freight_terms_lookup_code,
    from_header_id,
    from_line_id,
    from_line_location_id,
    global_attribute1,
    global_attribute10,
    global_attribute11,
    global_attribute12,
    global_attribute13,
    global_attribute14,
    global_attribute15,
    global_attribute16,
    global_attribute17,
    global_attribute18,
    global_attribute19,
    global_attribute2,
    global_attribute20,
    global_attribute3,
    global_attribute4,
    global_attribute5,
    global_attribute6,
    global_attribute7,
    global_attribute8,
    global_attribute9,
    global_attribute_category,
    government_context,
    inspection_required_flag,
    invoice_close_tolerance,
    last_accept_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    lead_time,
    lead_time_unit,
    line_location_id,
    match_option,
    need_by_date,
    org_id,
    po_header_id,
    po_line_id,
    po_release_id,
    price_discount,
    price_override,
    -- Standard WHO column: program_application_id
    -- Standard WHO column: program_id
    -- Standard WHO column: program_update_date
    promised_date,
    qty_rcv_exception_code,
    qty_rcv_tolerance,
    quantity,
    quantity_accepted,
    quantity_billed,
    quantity_cancelled,
    quantity_received,
    quantity_rejected,
    quantity_shipped,
    receipt_days_exception_code,
    receipt_required_flag,
    receive_close_tolerance,
    receiving_routing_id,
    -- Standard WHO column: request_id
    shipment_num,
    shipment_type,
    ship_to_location_id,
    ship_to_organization_id,
    ship_via_lookup_code,
    source_shipment_id,
    start_date,
    taxable_flag,
    tax_code_id,
    tax_name, --<R12 eTax Integration>
    tax_user_override_flag,
    terms_id,
    --    unencumbered_quantity, -- <Removed Encumbrance FPJ>
    unit_meas_lookup_code,
    unit_of_measure_class,
    --togeorge 10/05/2000
    --added note to receiver
    note_to_receiver,
-- start of 1548597
    secondary_unit_of_measure,
    secondary_quantity,
    preferred_grade,
    secondary_quantity_received,
    secondary_quantity_accepted,
    secondary_quantity_rejected,
    secondary_quantity_cancelled,
-- end of 1548597
    consigned_flag,                        -- CONSIGNED FPI
    amount,                                -- Services FPJ
    amount_accepted,                       -- Services FPJ
    amount_billed,                         -- Services FPJ
    amount_cancelled,                      -- Services FPJ
    amount_received,                       -- Services FPJ
    amount_rejected,                       -- Services FPJ
    transaction_flow_header_id,            --< Shared Proc FPJ >
    manual_price_change_flag               --<MANUAL PRICE OVERRIDE FPJ>
    --<DBI Req Fulfillment 11.5.11 Start >
     , shipment_closed_date
     , closed_for_receiving_date
     , closed_for_invoice_date
     --<DBI Req Fulfillment 11.5.11 End >
     ,outsourced_assembly --<SHIKYU R12>
     ,tax_attribute_update_code --<R12 eTax Integration>
    , value_basis         -- <Complex Work R12>
    , matching_basis      -- <Complex Work R12>
    , payment_type        -- <Complex Work R12>
    , description         -- <Complex Work R12>
    , work_approver_id    -- <Complex Work R12>
    , original_shipment_id --<eTax Integration R12>
  ) VALUES (
    l_accrue_on_receipt_flag,             -- CONSIGNED FPI
    -- x_accrue_on_receipt_flag,                   -- Bug: 1402128
    -- x_po_shipment_record.accrue_on_receipt_flag,
    x_po_shipment_record.allow_substitute_receipts_flag,
    x_po_shipment_record.approved_date,
    x_po_shipment_record.approved_flag,
    x_po_shipment_record.attribute1,
    x_po_shipment_record.attribute10,
    x_po_shipment_record.attribute11,
    x_po_shipment_record.attribute12,
    x_po_shipment_record.attribute13,
    x_po_shipment_record.attribute14,
    x_po_shipment_record.attribute15,
    x_po_shipment_record.attribute2,
    x_po_shipment_record.attribute3,
    x_po_shipment_record.attribute4,
    x_po_shipment_record.attribute5,
    x_po_shipment_record.attribute6,
    x_po_shipment_record.attribute7,
    x_po_shipment_record.attribute8,
    x_po_shipment_record.attribute9,
    x_po_shipment_record.attribute_category,
    x_po_shipment_record.calculate_tax_flag,
    x_po_shipment_record.cancelled_by,
    x_po_shipment_record.cancel_date,
    x_po_shipment_record.cancel_flag,
    x_po_shipment_record.cancel_reason,
    x_po_shipment_record.closed_by,
    --x_po_shipment_record.closed_code,
    l_closed_code,                        -- CONSIGNED FPI
    x_po_shipment_record.closed_date,
    x_po_shipment_record.closed_flag,
    --x_po_shipment_record.closed_reason,
    l_closed_reason,                      -- CONSIGNED FPI
    x_po_shipment_record.country_of_origin_code,
    x_po_shipment_record.created_by,
    x_po_shipment_record.creation_date,
    x_po_shipment_record.days_early_receipt_allowed,
    x_po_shipment_record.days_late_receipt_allowed,
    x_po_shipment_record.encumbered_date,
    x_po_shipment_record.encumbered_flag,
    x_po_shipment_record.encumber_now,
    x_po_shipment_record.end_date,
    x_po_shipment_record.enforce_ship_to_location_code,
    x_po_shipment_record.estimated_tax_amount,
    x_po_shipment_record.firm_date,
    x_po_shipment_record.firm_status_lookup_code,
    x_po_shipment_record.fob_lookup_code,
    x_po_shipment_record.freight_terms_lookup_code,
    x_po_shipment_record.from_header_id,
    x_po_shipment_record.from_line_id,
    x_po_shipment_record.from_line_location_id,
    x_po_shipment_record.global_attribute1,
    x_po_shipment_record.global_attribute10,
    x_po_shipment_record.global_attribute11,
    x_po_shipment_record.global_attribute12,
    x_po_shipment_record.global_attribute13,
    x_po_shipment_record.global_attribute14,
    x_po_shipment_record.global_attribute15,
    x_po_shipment_record.global_attribute16,
    x_po_shipment_record.global_attribute17,
    x_po_shipment_record.global_attribute18,
    x_po_shipment_record.global_attribute19,
    x_po_shipment_record.global_attribute2,
    x_po_shipment_record.global_attribute20,
    x_po_shipment_record.global_attribute3,
    x_po_shipment_record.global_attribute4,
    x_po_shipment_record.global_attribute5,
    x_po_shipment_record.global_attribute6,
    x_po_shipment_record.global_attribute7,
    x_po_shipment_record.global_attribute8,
    x_po_shipment_record.global_attribute9,
    x_po_shipment_record.global_attribute_category,
    x_po_shipment_record.government_context,
    --x_po_shipment_record.inspection_required_flag,
    l_inspection_required_flag,           -- CONSIGNED FPI
    --x_po_shipment_record.invoice_close_tolerance, -- Bug 2761415
    l_invoice_close_tolerance,            -- CONSIGNED FPI
    x_po_shipment_record.last_accept_date,
    x_po_shipment_record.last_updated_by,
    x_po_shipment_record.last_update_date,
    x_po_shipment_record.last_update_login,
    x_po_shipment_record.lead_time,
    x_po_shipment_record.lead_time_unit,
    x_po_shipment_record.line_location_id,
    --x_po_shipment_record.match_option,
    l_match_option,                       -- CONSIGNED FPI
    x_po_shipment_record.need_by_date,
    x_po_shipment_record.org_id,
    x_po_shipment_record.po_header_id,
    x_po_shipment_record.po_line_id,
    x_po_shipment_record.po_release_id,
    x_po_shipment_record.price_discount,
    x_po_shipment_record.price_override,
    -- Standard WHO column: x_po_shipment_record.program_application_id
    -- Standard WHO column: x_po_shipment_record.program_id
    -- Standard WHO column: x_po_shipment_record.program_update_date
    x_po_shipment_record.promised_date,
    x_po_shipment_record.qty_rcv_exception_code,
    x_po_shipment_record.qty_rcv_tolerance,
    l_quantity,                         --bug#2717053
    x_po_shipment_record.quantity_accepted,
    x_po_shipment_record.quantity_billed,
    x_po_shipment_record.quantity_cancelled,
    x_po_shipment_record.quantity_received,
    x_po_shipment_record.quantity_rejected,
    x_po_shipment_record.quantity_shipped,
    x_po_shipment_record.receipt_days_exception_code,
    --x_po_shipment_record.receipt_required_flag,
    l_receipt_required_flag,              -- CONSIGNED FPI
    x_po_shipment_record.receive_close_tolerance, -- Bug 2761415
    x_po_shipment_record.receiving_routing_id,
    -- Standard WHO column: x_po_shipment_record.request_id
    x_po_shipment_record.shipment_num,
    x_po_shipment_record.shipment_type,
    l_to_ship_to_location_id,            --bug#2717053
    l_to_ship_to_organization_id,        --bug#2717053
    x_po_shipment_record.ship_via_lookup_code,
    x_po_shipment_record.source_shipment_id,
    x_po_shipment_record.start_date,
    x_po_shipment_record.taxable_flag,
    x_po_shipment_record.tax_code_id,
    x_po_shipment_record.tax_name, --<R12 eTax Integration>
    x_po_shipment_record.tax_user_override_flag,
    x_po_shipment_record.terms_id,
    -- <Removed Encumbrance FPJ>
    -- x_po_shipment_record.unencumbered_quantity,
    x_po_shipment_record.unit_meas_lookup_code,
    x_po_shipment_record.unit_of_measure_class,
    --togeorge 10/05/2000
    --added note to receiver
    x_po_shipment_record.note_to_receiver,
    x_secondary_unit_of_measure,
    x_secondary_quantity,
    x_po_shipment_record.preferred_grade,
    decode(x_secondary_unit_of_measure,NULL,NULL,0),
    decode(x_secondary_unit_of_measure,NULL,NULL,0),
    decode(x_secondary_unit_of_measure,NULL,NULL,0),
    decode(x_secondary_unit_of_measure,NULL,NULL,0),
    --<INVCONV R12 END>
    l_consigned_flag ,                     -- CONSIGNED FPI
    x_po_shipment_record.amount,           -- Services FPJ  (Except for ordered amt all other amts are 0)
    0,                                     -- Services FPJ
    0,                                     -- Services FPJ
    0,                                     -- Services FPJ
    0,                                     -- Services FPJ
    0,                                     -- Services FPJ
    x_po_shipment_record.transaction_flow_header_id,        --< Shared Proc FPJ >
    x_po_shipment_record.manual_price_change_flag --<MANUAL PRICE OVERRIDE FPJ>
    --<DBI Req Fulfillment 11.5.11 Start >
   , decode(l_closed_code,'CLOSED',
             nvl(x_po_shipment_record.closed_date,sysdate), null)           ---shipment closed date
   , decode(l_closed_code,'CLOSED',nvl(x_po_shipment_record.closed_date,sysdate),
             'CLOSED FOR RECEIVING',sysdate,null)  --closed for receiving date
   , decode(l_closed_code,'CLOSED',nvl(x_po_shipment_record.closed_date,sysdate),
             'CLOSED FOR INVOICE',sysdate,null)  ---closed for invoice date
   --<DBI Req Fulfillment 11.5.11 End >
   , x_po_shipment_record.outsourced_assembly -- <SHIKYU R12>
   ,g_tax_attribute_update_code --<R12 eTax Integration>
   -- <Complex Work R12 START> bug 4958300: added nvl for basis columns
   , nvl(x_po_shipment_record.value_basis, l_line_value_basis)
   , nvl(x_po_shipment_record.matching_basis, l_line_matching_basis)
   , x_po_shipment_record.payment_type
   , x_po_shipment_record.description
   , x_po_shipment_record.work_approver_id
   -- <Complex Work R12 END>
   , NVL2(g_tax_attribute_update_code, p_orig_line_location_id, null) --<eTax Integration R12>
  );

  x_return_code := 0;

EXCEPTION
  WHEN OTHERS THEN
    copydoc_sql_error('insert_shipment', l_progress, sqlcode,
                      x_online_report_id,
                      x_sequence,
                      x_line_num, x_po_shipment_record.shipment_num, 0);
    x_return_code := -1;
    IF g_debug_unexp THEN            --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_exc
            (p_log_head => g_module_prefix||'insert_shipment',
             p_progress => l_progress);
    END IF;
END insert_shipment;



PROCEDURE insert_distribution(
  x_po_distribution_record  IN      po_distributions%ROWTYPE,
  x_online_report_id        IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                IN      po_online_report_text.line_num%TYPE,
  x_shipment_num            IN      po_online_report_text.shipment_num%TYPE,
  x_return_code             OUT NOCOPY     NUMBER
) IS

  l_progress  VARCHAR2(4);

    l_return_status VARCHAR2(1);
    l_msg_data VARCHAR2(2000);
    l_msg_count NUMBER;

  --<GRANTS FPJ START>
  l_msg_buf              VARCHAR2(2000);
  l_gms_po_interface_obj     gms_po_interface_type;
  l_award_id                 PO_DISTRIBUTIONS_ALL.award_id%TYPE := NULL;
  --<GRANTS FPJ END>

BEGIN

  l_progress := '000';
  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_stmt
          (p_log_head => g_module_prefix||'insert_distribution',
           p_token    => 'invoked',
           p_message  => 'dist ID: '||
                         x_po_distribution_record.po_distribution_id||
                         ' online_report ID: '||x_online_report_id);
  END IF;

  --<GRANTS FPJ START>
  SAVEPOINT insert_distribution_savepoint;

  --If this distribution references an award_id, then
  --create new award distribution lines.

  IF x_po_distribution_record.award_id IS NOT NULL THEN

    l_progress := '010';

    l_gms_po_interface_obj := gms_po_interface_type(
            gms_type_number(x_po_distribution_record.po_distribution_id),
            gms_type_number(x_po_distribution_record.distribution_num),
            gms_type_number(x_po_distribution_record.project_id),
            gms_type_number(x_po_distribution_record.task_id),
            gms_type_number(x_po_distribution_record.award_id),
            gms_type_number(NULL));

    l_progress := '020';

    PO_GMS_INTEGRATION_PVT.maintain_adl (
          p_api_version           => 1.0,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data,
          p_caller                => 'COPYDOC',
          x_po_gms_interface_obj  => l_gms_po_interface_obj);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      l_progress := '030';
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_award_id := l_gms_po_interface_obj.award_set_id_out(1);

  END IF;

  l_progress := '040';

  --<GRANTS FPJ END>

/** Bug 1003635
 *  bgu, Oct. 06, 1999
 *  Should not copy encumberance reserve related fields.
 */

  INSERT INTO PO_DISTRIBUTIONS (
    accrual_account_id,
    accrued_flag,
    accrue_on_receipt_flag,
    amount_billed,
    attribute1,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute_category,
    award_id,
--    base_amount_billed,    -- June 07, 1999,   bgu
    bom_resource_id,
    budget_account_id,
    code_combination_id,
    created_by,
    creation_date,
    deliver_to_location_id,
    deliver_to_person_id,
    destination_context,
    destination_organization_id,
    destination_subinventory,
    destination_type_code,
    distribution_num,
--    encumbered_amount,  -- Oct. 06, 1999,   bgu
    encumbered_flag,
    end_item_unit_number,
    expenditure_item_date,
    expenditure_organization_id,
    expenditure_type,
    failed_funds_lookup_code,
--    gl_cancelled_date,
    gl_closed_date,
    gl_encumbered_date,
    gl_encumbered_period_name,
    government_context,
    kanban_card_id,
    last_updated_by,
    last_update_date,
    last_update_login,
    line_location_id,
    -- <Removed Encumbrance FPJ>
    -- mrc_encumbered_amount,
    mrc_rate,
    mrc_rate_date,
    -- <Removed Encumbrance FPJ>
    -- mrc_unencumbered_amount,
    nonrecoverable_tax,
    org_id,
    po_distribution_id,
    po_header_id,
    po_line_id,
    po_release_id,
    prevent_encumbrance_flag,
    -- Standard WHO column: program_application_id
    -- Standard WHO column: program_id
    -- Standard WHO column: program_update_date
    project_accounting_context,
    project_id,
    quantity_billed,
    quantity_cancelled,
    quantity_delivered,
    quantity_ordered,
    rate,
    rate_date,
    recoverable_tax,
    recovery_rate,
    -- Standard WHO column: request_id
    req_distribution_id,
    req_header_reference_num,
    req_line_reference_num,
    set_of_books_id,
    source_distribution_id,
    task_id,
    tax_recovery_override_flag,
    -- <Removed Encumbrance FPJ>
    --    unencumbered_amount,
    --    unencumbered_quantity,
    variance_account_id,
    wip_entity_id,
    wip_line_id,
    wip_operation_seq_num,
    wip_repetitive_schedule_id,
    wip_resource_seq_num,
    --togeorge 10/05/2000
    --added oke columns
    oke_contract_line_id,
    oke_contract_deliverable_id,
    amount_ordered,                        -- Services FPJ
    amount_delivered,                      -- Services FPJ
    amount_cancelled,                      -- Services FPJ
    distribution_type,                     -- <Encumbrance FPJ>
    amount_to_encumber,                    -- Bug 3309589
    dest_charge_account_id,                --< Shared Proc FPJ >
    dest_variance_account_id               --< Shared Proc FPJ >
   ,tax_attribute_update_code, --<R12 eTax Integration>
    global_attribute_category ,
    global_attribute1  ,
    global_attribute2  ,
    global_attribute3  ,
    global_attribute4  ,
    global_attribute5  ,
    global_attribute6  ,
    global_attribute7  ,
    global_attribute8  ,
    global_attribute9  ,
    global_attribute10 ,
    global_attribute11 ,
    global_attribute12 ,
    global_attribute13 ,
    global_attribute14 ,
    global_attribute15 ,
    global_attribute16 ,
    global_attribute17 ,
    global_attribute18 ,
    global_attribute19 ,
    global_attribute20
  ) VALUES (
    x_po_distribution_record.accrual_account_id,
 --   x_po_distribution_record.accrued_flag, 2861250
    null,
    x_po_distribution_record.accrue_on_receipt_flag,
    x_po_distribution_record.amount_billed,
    x_po_distribution_record.attribute1,
    x_po_distribution_record.attribute10,
    x_po_distribution_record.attribute11,
    x_po_distribution_record.attribute12,
    x_po_distribution_record.attribute13,
    x_po_distribution_record.attribute14,
    x_po_distribution_record.attribute15,
    x_po_distribution_record.attribute2,
    x_po_distribution_record.attribute3,
    x_po_distribution_record.attribute4,
    x_po_distribution_record.attribute5,
    x_po_distribution_record.attribute6,
    x_po_distribution_record.attribute7,
    x_po_distribution_record.attribute8,
    x_po_distribution_record.attribute9,
    x_po_distribution_record.attribute_category,
    l_award_id, --<GRANTS FPJ>
--    x_po_distribution_record.base_amount_billed,
    x_po_distribution_record.bom_resource_id,
    x_po_distribution_record.budget_account_id,
    x_po_distribution_record.code_combination_id,
    x_po_distribution_record.created_by,
    x_po_distribution_record.creation_date,
    x_po_distribution_record.deliver_to_location_id,
    x_po_distribution_record.deliver_to_person_id,
    x_po_distribution_record.destination_context,
    x_po_distribution_record.destination_organization_id,
    x_po_distribution_record.destination_subinventory,
    x_po_distribution_record.destination_type_code,
    x_po_distribution_record.distribution_num,
--    x_po_distribution_record.encumbered_amount,
--    x_po_distribution_record.encumbered_flag,
    'N',
    x_po_distribution_record.end_item_unit_number,
    x_po_distribution_record.expenditure_item_date,
    x_po_distribution_record.expenditure_organization_id,
    x_po_distribution_record.expenditure_type,
    x_po_distribution_record.failed_funds_lookup_code,
--    x_po_distribution_record.gl_cancelled_date,
    x_po_distribution_record.gl_closed_date,
    x_po_distribution_record.gl_encumbered_date,
    x_po_distribution_record.gl_encumbered_period_name,
    x_po_distribution_record.government_context,
    x_po_distribution_record.kanban_card_id,
    x_po_distribution_record.last_updated_by,
    x_po_distribution_record.last_update_date,
    x_po_distribution_record.last_update_login,
    x_po_distribution_record.line_location_id,
    -- <Removed Encumbrance FPJ>
    -- x_po_distribution_record.mrc_encumbered_amount,
    x_po_distribution_record.mrc_rate,
    x_po_distribution_record.mrc_rate_date,
    -- <Removed Encumbrance FPJ>
    -- x_po_distribution_record.mrc_unencumbered_amount,
    x_po_distribution_record.nonrecoverable_tax,
    x_po_distribution_record.org_id,
    x_po_distribution_record.po_distribution_id,
    x_po_distribution_record.po_header_id,
    x_po_distribution_record.po_line_id,
    x_po_distribution_record.po_release_id,
    x_po_distribution_record.prevent_encumbrance_flag,
    -- Standard WHO column: x_po_distribution_record.program_application_id
    -- Standard WHO column: x_po_distribution_record.program_id
    -- Standard WHO column: x_po_distribution_record.program_update_date
    x_po_distribution_record.project_accounting_context,
    x_po_distribution_record.project_id,
    x_po_distribution_record.quantity_billed,
    x_po_distribution_record.quantity_cancelled,
    x_po_distribution_record.quantity_delivered,
    x_po_distribution_record.quantity_ordered,
    x_po_distribution_record.rate,
    x_po_distribution_record.rate_date,
    x_po_distribution_record.recoverable_tax,
    x_po_distribution_record.recovery_rate,
    -- Standard WHO column: x_po_distribution_record.request_id
    x_po_distribution_record.req_distribution_id,
    x_po_distribution_record.req_header_reference_num,
    x_po_distribution_record.req_line_reference_num,
    x_po_distribution_record.set_of_books_id,
    x_po_distribution_record.source_distribution_id,
    x_po_distribution_record.task_id,
    x_po_distribution_record.tax_recovery_override_flag,
    -- <Removed Encumbrance FPJ>
    -- x_po_distribution_record.unencumbered_amount,
    -- x_po_distribution_record.unencumbered_quantity,
    x_po_distribution_record.variance_account_id,
    x_po_distribution_record.wip_entity_id,
    x_po_distribution_record.wip_line_id,
    x_po_distribution_record.wip_operation_seq_num,
    x_po_distribution_record.wip_repetitive_schedule_id,
    x_po_distribution_record.wip_resource_seq_num,
    --togeorge 10/05/2000
    --added oke columns
    x_po_distribution_record.oke_contract_line_id,
    x_po_distribution_record.oke_contract_deliverable_id,
    x_po_distribution_record.amount_ordered,       -- Services FPJ
    0,                                             -- Services FPJ
    0,                                             -- Services FPJ
    x_po_distribution_record.distribution_type,    -- <Encumbrance FPJ>
    x_po_distribution_record.amount_to_encumber,   -- Bug 3309589
    x_po_distribution_record.dest_charge_account_id,   --< Shared Proc FPJ >
    x_po_distribution_record.dest_variance_account_id  --< Shared Proc FPJ >
   ,NVL2(g_tax_attribute_update_code,'CREATE',NULL), --<R12 eTax Integration>
    x_po_distribution_record.GLOBAL_ATTRIBUTE_CATEGORY ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE1  ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE2  ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE3  ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE4  ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE5  ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE6  ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE7  ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE8  ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE9  ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE10 ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE11 ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE12 ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE13 ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE14 ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE15 ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE16 ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE17 ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE18 ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE19 ,
    x_po_distribution_record.GLOBAL_ATTRIBUTE20
  );

  x_return_code := 0;

  l_progress := '050';


EXCEPTION

  --<GRANTS FPJ START>
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO SAVEPOINT insert_distribution_savepoint;
    FOR i in 1..FND_MSG_PUB.count_msg LOOP
      BEGIN
        l_msg_buf := SUBSTRB(FND_MSG_PUB.get(p_msg_index=>i,
                                             p_encoded=>FND_API.G_FALSE),
                             1, 2000);
        online_report(x_online_report_id,
                      x_sequence,
                      l_msg_buf,
                      x_line_num,
                      x_shipment_num,
                      x_po_distribution_record.distribution_num);
      END;
   END LOOP;
   x_return_code := -1;
  --<GRANTS FPJ END>
    IF g_debug_stmt THEN             --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'insert_distribution',
             p_token    => l_progress,
             p_message  => 'FND_API.g_exc_error exception caught.');
    END IF;

      IF g_debug_unexp THEN          --< Shared Proc FPJ > Add correct debugging
          PO_DEBUG.debug_exc
              (p_log_head => g_module_prefix||'insert_distribution',
               p_progress => l_progress);
      END IF;

  WHEN OTHERS THEN
    ROLLBACK TO SAVEPOINT insert_distribution_savepoint; --<GRANTS FPJ>
    copydoc_sql_error('insert_distribution', l_progress, sqlcode,
                      x_online_report_id,
                      x_sequence,
                      x_line_num, x_shipment_num, x_po_distribution_record.distribution_num);
    x_return_code := -1;
    IF g_debug_unexp THEN            --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_exc
            (p_log_head => g_module_prefix||'insert_distribution',
             p_progress => l_progress);
    END IF;
END insert_distribution;


PROCEDURE handle_fatal(
  x_return_code  OUT NOCOPY  NUMBER
) IS
BEGIN

    x_return_code := -1;

    IF (po_line_cursor%ISOPEN) THEN
      CLOSE po_line_cursor;
    END IF;
    IF (po_shipment_cursor%ISOPEN) THEN
      CLOSE po_shipment_cursor;
    END IF;
    IF (po_distribution_cursor%ISOPEN) THEN
      CLOSE po_distribution_cursor;
    END IF;

END handle_fatal;

/**************************************************************
 ** Fetch header info from FROM PO header
 ** Validate header with new info if there's any
 ** Insert header with old and new info to the new header
 ** Copy attachment if necessary
***************************************************************/
PROCEDURE process_header(
  x_action_code             IN      VARCHAR2,
  x_to_doc_subtype          IN      po_headers.type_lookup_code%TYPE,
  x_to_global_flag      IN      PO_HEADERS_ALL.global_agreement_flag%TYPE,  -- GA
  x_po_header_record        IN OUT NOCOPY  PO_HEADERS%ROWTYPE,
  x_from_po_header_id       IN      po_headers.po_header_id%TYPE,
  x_to_segment1             IN      po_headers.segment1%TYPE,
  x_agent_id                IN      po_headers.agent_id%TYPE,
  x_sob_id                  IN      financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id              IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_copy_attachments        IN      BOOLEAN,
  x_online_report_id        IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_return_code             OUT NOCOPY     NUMBER,
  x_copy_terms              IN VARCHAR2
) IS

  l_progress                 VARCHAR2(4);
  x_internal_return_code     NUMBER := NULL;

  /* FPJ CONTERMS START */
  l_po_from_document_type        po_headers.type_lookup_code%TYPE;
  l_contracts_from_document_type VARCHAR2(150); --Change this in 11iX
  l_contracts_to_document_type   VARCHAR2(150); --Change this in 11iX

  l_return_status                VARCHAR2(1);
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_conterms_exist_flag          VARCHAR2(1);
  l_temp_copy_terms              VARCHAR2(1);
  l_internal_party_id            po_headers_all.org_id%TYPE;
  l_internal_contact_id          po_headers_all.agent_id%TYPE;
  l_external_party_id            po_headers_all.vendor_id%TYPE;
  l_external_party_site_id       po_headers_all.vendor_site_id%TYPE;
  l_external_contact_id    po_headers_all.vendor_contact_id%TYPE;
  l_copy_contracts_attachments   VARCHAR2(1) := 'N';
  /* FPJ CONTERMS END */

BEGIN

  l_progress := '000';
  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_stmt
          (p_log_head => g_module_prefix||'process_header',
           p_token    => 'invoked',
           p_message  => 'action_code: ' ||x_action_code||' to_doc_subtype: '||
                   x_to_doc_subtype||' from header ID: '||x_from_po_header_id||
                   ' to segment1: '||x_to_segment1||' header ID: '||
                   x_po_header_record.po_header_id||' agent ID: '||x_agent_id||
                   ' sob ID: '||x_sob_id||' inv_org ID: '||x_inv_org_id||
                   ' online_report ID: '||x_online_report_id);
  END IF;

  l_progress := '010';

  fetch_header(x_po_header_record,
               x_from_po_header_id,
               x_online_report_id,
               x_sequence,
               x_internal_return_code);

  -- <FPJ CONTERMS> store the source document document type
  l_po_from_document_type := x_po_header_record.type_lookup_code;

--COMMIT; < HTML Agreements R12>

  l_progress := '020';

  IF (x_internal_return_code = 0) THEN
    l_progress := '020';

    /** New po_header_id and segment1 are created and stored in
        x_po_header_record ****/
    po_copydoc_s2.validate_header(x_action_code,
                                  x_to_doc_subtype,
          x_to_global_flag, -- Global Agreements (FP-I)
                                  x_po_header_record,
                                  x_to_segment1,
          x_agent_id,
          x_sob_id,
          x_inv_org_id,
                                  x_online_report_id,
                                  x_sequence,
                                  x_internal_return_code);
-- COMMIT; < HTML Agreements R12>
    IF (x_internal_return_code = 0) THEN
      l_progress := '030';

      insert_header(x_po_header_record,
                    x_online_report_id,
                    x_sequence,
                    x_internal_return_code,
                    x_copy_terms);
--    COMMIT; < HTML Agreements R12>
      IF (x_internal_return_code = 0) THEN
        l_progress := '040';

        /* FPJ CONTERMS START */

        -- process user choice, proceed only if choice to copy is made
        IF NVL(x_copy_terms, 'N') IN ('L', 'D') THEN

           l_progress := '050';

           -- Additional check to see if source document has terms attached
           -- SQL what: select conterms_exist_flag among other columns
           -- SQL why: need to check if source document has terms
           -- SQL join: po_header_id
           SELECT conterms_exist_flag
            ,org_id
      ,agent_id
      ,vendor_id
      ,vendor_site_id
      ,vendor_contact_id
           INTO   l_conterms_exist_flag
            ,l_internal_party_id
      ,l_internal_contact_id
      ,l_external_party_id
      ,l_external_party_site_id
      ,l_external_contact_id
           FROM po_headers
           WHERE po_header_id = x_from_po_header_id;

           -- contract terms exist and user has chosen to copy
           IF (UPPER(l_conterms_exist_flag) = 'Y') THEN

             l_progress := '060';

             -- decode so that Y/N could be passed to Contracts API
             IF (x_copy_terms = 'L') THEN
               l_temp_copy_terms := 'N';
             ELSIF (x_copy_terms = 'D') THEN
               l_temp_copy_terms := 'Y';
             END IF;

             /* <Bug3365562 Start>. Commented out the following piece of code.
                            Whether or not to attach Contract Attachments needs to
                            determined on basis of 'Contract Terms' radio buttons
                            on Copy Doc form rather than the 'Copy Attachments'
                            checkbox. 'Copy Attachments' checkbox will only
                            determine whether PO Attachments are copied or not.
       -- check to see if attachments need to be copied
             IF (x_copy_attachments) THEN
               l_copy_contracts_attachments := 'Y';
             ELSE
               l_copy_contracts_attachments := 'N';
             END IF;*/
             -- l_copy_contracts_attachments can be put directly to 'Y' because
             -- this part is entered only when x_copy_terms is 'L' or 'D' in both
             -- of which cases we need to copy Contract Articles.
             l_copy_contracts_attachments := 'Y';
             -- <Bug3365562 End>

       -- decode source document type for contracts
             IF (l_po_from_document_type IN ('CONTRACT', 'BLANKET')) THEN
               l_contracts_from_document_type := 'PA_'||l_po_from_document_type;
             ELSIF (l_po_from_document_type = 'STANDARD') THEN
               l_contracts_from_document_type := 'PO_'||l_po_from_document_type;
             END IF;

             -- x_po_header_record now contains new po header
             -- decode target document type for contracts
             IF (x_po_header_record.type_lookup_code IN ( 'CONTRACT', 'BLANKET')) THEN
               l_contracts_to_document_type := 'PA_'|| x_po_header_record.type_lookup_code;
             ELSIF (x_po_header_record.type_lookup_code = 'STANDARD') THEN
               l_contracts_to_document_type := 'PO_'|| x_po_header_record.type_lookup_code;
             END IF;

             -- call contracts API to copy terms and deliverables
             OKC_TERMS_COPY_GRP.copy_doc (
                        p_api_version             => 1.0,
                        p_init_msg_list     => FND_API.G_FALSE,
                        p_commit            => FND_API.G_FALSE,
                        p_source_doc_type   => l_contracts_from_document_type,
                        p_source_doc_id           => x_from_po_header_id,
                        p_target_doc_type   => l_contracts_to_document_type,
                        p_target_doc_id           => x_po_header_record.po_header_id,
                        p_keep_version            => l_temp_copy_terms,
                        p_article_effective_date  => SYSDATE,
                        -- Bug 3365562. Passing this parameter as 'N' so that
                        --              deliverable attachments do not get copied.
                        p_copy_del_attachments_yn => 'N',
      p_copy_deliverables   => 'Y',
                        p_copy_doc_attachments    => l_copy_contracts_attachments,
                        p_document_number   => x_po_header_record.segment1,
      p_internal_party_id       => to_char(l_internal_party_id),
      p_internal_contact_id     => to_char(l_internal_contact_id),
      p_external_party_id       => to_char(l_external_party_id),
      p_external_party_site_id  => to_char(l_external_party_site_id),
      p_external_contact_id     => to_char(l_external_contact_id),
                        x_return_status           => l_return_status,
                        x_msg_data            => l_msg_data,
                        x_msg_count           => l_msg_count
                        );

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               l_progress := '070';

               -- terms copying failed , set conterms exist flag on the new doc to N
               UPDATE po_headers_all
               SET conterms_exist_flag = 'N'
               WHERE po_header_id = x_po_header_record.po_header_id;
             END IF; -- return status is error

--          COMMIT; < HTML Agreements R12>
           END IF; -- conterms exist flag

         END IF; -- if chosen to copy

        l_progress := '080';

        IF (x_copy_attachments) THEN
          l_progress := '090';
          fnd_attached_documents2_pkg.copy_attachments('PO_HEADERS',
                                                       x_from_po_header_id,
                                                       '',
                                                       '',
                                                       '',
                                                       '',
                                                       'PO_HEADERS',
                                                       x_po_header_record.po_header_id,
                                                       '',
                                                       '',
                                                       '',
                                                       '',
                                                       fnd_global.user_id,
                                                       fnd_global.login_id,
                                                       '',
                                                       '',
                                                       '');
--      COMMIT; < HTML Agreements R12>
        END IF;
      END IF;
    END IF;
  END IF;

  x_return_code := x_internal_return_code;

EXCEPTION
  WHEN OTHERS THEN
    x_return_code := -1;
    copydoc_sql_error('process_header', l_progress, sqlcode,
                      x_online_report_id,
                      x_sequence,
                      0, 0, 0);
    IF g_debug_unexp THEN            --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_exc
            (p_log_head => g_module_prefix||'process_header',
             p_progress => l_progress);
    END IF;
END process_header;

--<Unified Catalog R12: Start>
--------------------------------------------------------------------------------
--Start of Comments
--Name: copy_attributes
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  To copy the Attribute Values and TLP rows from a given document to a new
--  document.
--
--Parameters:
--IN:
--p_orig_po_line_id
--  The PO_LINE_ID of the document from which the data has to be copied.
--p_new_po_line_id
--  The PO_LINE_ID of the new document.
--p_line_num
--  The line number in the document which is being ccopied.
--p_online_report_id
--  The key to PO_ONLINE_REPORT_TEXT where error messages will be added in case
--  of error
--OUT:
--x_sequence
--  The sequence number of the error for this document. It will be incremented
--  by 1 inside the procedure copydoc_sql_error()
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE copy_attributes
(
  p_orig_po_line_id  IN PO_LINES.po_line_id%TYPE
, p_new_po_line_id   IN PO_LINES.po_line_id%TYPE
, p_line_num         IN PO_LINES.line_num%TYPE
, p_online_report_id IN PO_ONLINE_REPORT_TEXT.online_report_id%TYPE
, x_sequence         IN OUT NOCOPY PO_ONLINE_REPORT_TEXT.sequence%TYPE
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_copy_attributes;
  l_progress     VARCHAR2(4);

BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_orig_po_line_id',p_orig_po_line_id);
    PO_LOG.proc_begin(d_mod,'p_new_po_line_id',p_new_po_line_id);
    PO_LOG.proc_begin(d_mod,'p_line_num',p_line_num);
    PO_LOG.proc_begin(d_mod,'p_online_report_id',p_online_report_id);
    PO_LOG.proc_begin(d_mod,'x_sequence',x_sequence);
  END IF;

  PO_ATTRIBUTE_VALUES_PVT.copy_attributes
  (
    p_orig_po_line_id => p_orig_po_line_id
  , p_new_po_line_id  => p_new_po_line_id
  );

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    copydoc_sql_error(x_routine          => d_mod,
                      x_progress         => l_progress,
                      x_sqlcode          => SQLCODE,
                      x_online_report_id => p_online_report_id,
                      x_sequence         => x_sequence,
                      x_line_num         => p_line_num,
                      x_shipment_num     => 0,
                      x_distribution_num => 0);
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END copy_attributes;
--<Unified Catalog R12: End>

--<Enhanced Pricing Start:>
--------------------------------------------------------------------------------
--Start of Comments
--Name: copy_line_adjustments
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  To copy the adjustments from a given document line to a new
--  document line
--
--Parameters:
--IN:
--p_orig_po_line_id
--  The PO_LINE_ID of the document from which the data has to be copied.
--p_new_po_header_id
--  The PO_HEADER_ID of the new document
--p_new_po_line_id
--  The PO_LINE_ID of the new document.
--p_line_num
--  The line number in the document which is being ccopied.
--p_online_report_id
--  The key to PO_ONLINE_REPORT_TEXT where error messages will be added in case
--  of error
--OUT:
--x_sequence
--  The sequence number of the error for this document. It will be incremented
--  by 1 inside the procedure copydoc_sql_error()
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE copy_line_adjustments
(
  p_orig_po_line_id  IN PO_LINES.po_line_id%TYPE
, p_new_po_header_id IN PO_HEADERS.po_header_id%TYPE
, p_new_po_line_id   IN PO_LINES.po_line_id%TYPE
, p_line_num         IN PO_LINES.line_num%TYPE
, p_online_report_id IN PO_ONLINE_REPORT_TEXT.online_report_id%TYPE
, x_sequence         IN OUT NOCOPY PO_ONLINE_REPORT_TEXT.sequence%TYPE
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_copy_line_adjustments;
  l_api_name CONSTANT varchar2(30)  := 'copy_line_adjustments';
  l_log_head CONSTANT varchar2(100) := g_module_prefix || l_api_name;
  l_progress     VARCHAR2(4);

  l_return_status VARCHAR2(1);
  l_return_status_text VARCHAR2(2000);

BEGIN
  l_progress := '010';

  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_orig_po_line_id',p_orig_po_line_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_po_header_id',p_new_po_header_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_po_line_id',p_new_po_line_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_line_num',p_line_num);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_online_report_id',p_online_report_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_sequence',x_sequence);
  END IF;

  l_progress := '020';
  PO_PRICE_ADJUSTMENTS_PKG.copy_line_adjustments
    (p_src_po_line_id     => p_orig_po_line_id,
     p_dest_po_header_id  => p_new_po_header_id,
     p_dest_po_line_id    => p_new_po_line_id,
     p_mode               => PO_PRICE_ADJUSTMENTS_PKG.G_COPY_ALL_MOD,
     x_return_status_text => l_return_status_text,
     x_return_status      => l_return_status);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    online_report(p_online_report_id,
                  x_sequence,
                  l_return_status_text,
                  p_line_num,
                  0,
                  0);
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,l_return_status_text);
    END IF;
  END IF;

  IF g_debug_stmt THEN
    PO_DEBUG.debug_end(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_sequence',x_sequence);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    copydoc_sql_error(x_routine          => d_mod,
                      x_progress         => l_progress,
                      x_sqlcode          => SQLCODE,
                      x_online_report_id => p_online_report_id,
                      x_sequence         => x_sequence,
                      x_line_num         => p_line_num,
                      x_shipment_num     => 0,
                      x_distribution_num => 0);
    IF g_debug_unexp THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Unhandled exception');
    END IF;
    RAISE;
END copy_line_adjustments;
--<Enhanced Pricing End>

PROCEDURE process_line(
  x_action_code         IN      VARCHAR2,
  x_to_doc_subtype      IN      po_headers.type_lookup_code%TYPE,
  x_po_line_record      IN OUT NOCOPY  po_lines%ROWTYPE,
  x_orig_po_line_id     IN      po_lines.po_line_id%TYPE,
  x_wip_install_status  IN      VARCHAR2,
  x_sob_id              IN      financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id          IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_po_header_id        IN      po_lines.po_header_id%TYPE,
  x_copy_attachments    IN      BOOLEAN,
  x_copy_price          IN      BOOLEAN,
  x_online_report_id    IN      po_online_report_text.online_report_id%TYPE,
  x_sequence            IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_return_code         OUT NOCOPY     NUMBER,
  p_is_complex_work_po  IN      BOOLEAN  -- <Complex Work R12>
) IS

  l_progress                 VARCHAR2(4);
  x_internal_return_code     NUMBER := NULL;

  l_entity_type              po_price_differentials.entity_type%TYPE;  -- SERVICES FPJ

BEGIN

  l_progress := '000';
  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_stmt
          (p_log_head => g_module_prefix||'process_line',
           p_token    => 'invoked',
           p_message  => 'action_code: ' ||x_action_code||' to_doc_subtype: '||
                   x_to_doc_subtype||' header ID: '||x_po_header_id||
                   ' orig_line ID: '||x_orig_po_line_id||' line ID: '||
                   x_po_line_record.po_line_id||' sob ID: '||x_sob_id||
                   ' inv_org ID: '||x_inv_org_id||' online_report ID: '||
                   x_online_report_id);
  END IF;

  l_progress := '010';

  /*  Functionality for PA->RFQ Copy : dreddy
    new parameter copy_price is added */
  po_copydoc_s3.validate_line(x_action_code,
                              x_to_doc_subtype,
                              x_po_line_record,
                              x_orig_po_line_id,
                              x_wip_install_status,
                              x_sob_id,
                              x_inv_org_id,
                              x_po_header_id,
                              x_online_report_id,
                              x_sequence,
                              x_copy_price,
                              x_internal_return_code,
                              p_is_complex_work_po);  -- <Complex Work R12>
--COMMIT; < HTML Agreements R12>

  IF (x_internal_return_code = 0) THEN
    l_progress := '020';

    insert_line(x_po_line_record,
                x_online_report_id,
                x_sequence,
                x_internal_return_code);
--  COMMIT; < HTML Agreements R12>

    IF (x_internal_return_code = 0) THEN
      IF (x_copy_attachments) THEN
        l_progress := '030';

        fnd_attached_documents2_pkg.copy_attachments('PO_LINES',
                                                     x_orig_po_line_id,
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     'PO_LINES',
                                                     x_po_line_record.po_line_id,
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     fnd_global.user_id,
                                                     fnd_global.login_id,
                                                     '',
                                                     '',
                                                     '');
--     COMMIT; < HTML Agreements R12>
      END IF;
    END IF;

     -- Services FPJ Start
     -- After line insertion copy the price differentials related to the new line
     -- if any price differentials exist.

     if x_to_doc_subtype = 'STANDARD' then
           l_entity_type := 'PO LINE';
     else
           l_entity_type := 'BLANKET LINE';
     end if;

    l_progress := '040';

    IF  PO_PRICE_DIFFERENTIALS_PVT.has_price_differentials(p_entity_type => l_entity_type,
                                                           p_entity_id   => x_orig_po_line_id)   THEN
        l_progress := '050';

        PO_PRICE_DIFFERENTIALS_PVT.copy_price_differentials (p_to_entity_id     => x_po_line_record.po_line_id,
                                                             p_to_entity_type   => l_entity_type,
                                                             p_from_entity_id   => x_orig_po_line_id,
                                                             p_from_entity_type => l_entity_type );
--      COMMIT; < HTML Agreements R12>

    END IF;

    -- Services FPJ End

    -- <Unified Catalog R12 Start>
    IF x_to_doc_subtype IN ('BLANKET', 'QUOTATION') THEN
      copy_attributes(p_orig_po_line_id  => x_orig_po_line_id,
                      p_new_po_line_id   => x_po_line_record.po_line_id,
                      p_line_num         => x_po_line_record.line_num,
                      p_online_report_id => x_online_report_id,
                      x_sequence         => x_sequence);
    END IF;
    -- <Unified Catalog R12 End>

   --<Enhanced Pricing Start>
   copy_line_adjustments(p_orig_po_line_id  => x_orig_po_line_id,
                         p_new_po_header_id => x_po_header_id,
                         p_new_po_line_id   => x_po_line_record.po_line_id,
                         p_line_num         => x_po_line_record.line_num,
                         p_online_report_id => x_online_report_id,
                         x_sequence         => x_sequence);
   --<Enhanced Pricing End>
  END IF; -- IF (x_internal_return_code = 0)

  x_return_code := x_internal_return_code;

EXCEPTION
  WHEN OTHERS THEN
    x_return_code := -1;
    copydoc_sql_error('process_line', l_progress, sqlcode,
                      x_online_report_id,
                      x_sequence,
                      x_po_line_record.line_num, 0, 0);
    IF g_debug_unexp THEN            --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_exc
            (p_log_head => g_module_prefix||'process_line',
             p_progress => l_progress);
    END IF;
END process_line;

--< Shared Proc FPJ Start >
--
PROCEDURE process_shipment
(
    p_action_code           IN     VARCHAR2,
    p_to_doc_subtype        IN     VARCHAR2,
    p_orig_line_location_id IN     NUMBER,
    p_po_header_id          IN     NUMBER,
    p_po_line_id            IN     NUMBER,
    p_item_category_id      IN     NUMBER,         --< Shared Proc FPJ >
    p_copy_attachments      IN     BOOLEAN,
    p_copy_price            IN     BOOLEAN,
    p_online_report_id      IN     NUMBER,
    p_line_num              IN     NUMBER,
    p_inv_org_id            IN     NUMBER,
    p_item_id               IN     NUMBER, -- Bug 3433867
    x_po_shipment_record    IN OUT NOCOPY PO_LINE_LOCATIONS%ROWTYPE,
    x_sequence              IN OUT NOCOPY NUMBER,
    x_return_code           OUT    NOCOPY NUMBER,
    p_is_complex_work_po    IN     BOOLEAN  -- <Complex Work R12>
) IS

  l_progress                 VARCHAR2(4);
  l_internal_return_code     NUMBER := NULL;

-- Bug: 1402128  Declare the variables

   l_item_id        number;
   l_inventory_organization_id  number;
   l_planned_item_flag    varchar2(1);
   l_outside_op_flag      varchar2(1);
   l_outside_op_uom_type  varchar2(25);
   l_invoice_close_tolerance  number;
   l_receive_close_tolerance  number;
   l_receipt_required_flag      varchar2(1);
   l_stock_enabled_flag       varchar2(1);
   l_item_status              varchar2(1);
   l_internal_orderable       varchar2(1);
   l_purchasing_enabled       varchar2(1);
   l_inventory_asset_flag     varchar2(1);

   l_expense_accrual_code     varchar2(100);
   l_accrue_on_receipt_flag   varchar2(1);
   l_poll_receipt_required_flag varchar2(1);

   --<INVCONV R12 START>
   l_secondary_default_ind      MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND%TYPE ;
   l_grade_control_flag         MTL_SYSTEM_ITEMS.GRADE_CONTROL_FLAG%TYPE ;
   l_secondary_unit_of_measure  MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;
   --<INVCONV R12 END>

BEGIN

  l_progress := '000';
  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_stmt
          (p_log_head => g_module_prefix||'process_shipment',
           p_token    => 'invoked',
           p_message  => 'action_code: ' ||p_action_code||' to_doc_subtype: '||
                   p_to_doc_subtype||' header ID: '||p_po_header_id||
                   ' line ID: '||p_po_line_id||' orig_ship ID: '||
                   p_orig_line_location_id||' item_cat ID: '||p_item_category_id
                   ||' inv_org ID: '||p_inv_org_id||' online_report ID: '||
                   p_online_report_id);
  END IF;

  l_progress := '020';

  /*  Functionality for PA->RFQ Copy : dreddy
    new parameter copy_price is added */
  po_copydoc_s4.validate_shipment
       (p_action_code           => p_action_code,
        p_to_doc_subtype        => p_to_doc_subtype,
        x_po_shipment_record    => x_po_shipment_record,
        p_orig_line_location_id => p_orig_line_location_id,
        p_po_header_id          => p_po_header_id,
        p_po_line_id            => p_po_line_id,
        p_item_category_id      => p_item_category_id,     --< Shared Proc FPJ >
        p_item_id               => p_item_id, -- Bug 3433867
        p_online_report_id      => p_online_report_id,
        x_sequence              => x_sequence,
        p_line_num              => p_line_num,
        p_copy_price            => p_copy_price,
        p_inv_org_id            => p_inv_org_id,             -- Bug 2761415
        x_return_code           => l_internal_return_code,
        p_is_complex_work_po    => p_is_complex_work_po);  -- <Complex Work R12>
--COMMIT; < HTML Agreements R12>

  l_progress := '030';

 /* Bug 1715229 : We need to initialize the accrue flag with whatever we got
  * back from the validate shipment procedure because if we do not go into the
  * if condition below , a null will be passed to the insert_shipment proc. */

     l_accrue_on_receipt_flag := x_po_shipment_record.accrue_on_receipt_flag;

/* Bug: 1402128 get the accrue on receipt flag, since same code is used for
   copy of the PO to PO so we are restricting this for quotation only */

IF  (p_action_code = 'QUOTATION') Then

  l_progress := '040';

/* Get the item_id, accrue on receipt flag, and expense accrual code */

  select receipt_required_flag
        into l_poll_receipt_required_flag
        from po_line_locations
        where line_location_id = p_orig_line_location_id;

   l_progress := '050';

  select expense_accrual_code into l_expense_accrual_code
        from po_system_parameters;

   l_progress := '060';

  select item_id into l_item_id from po_lines
        where po_line_id = p_po_line_id;


     if l_item_id is not NULL then

      l_progress := '070';

  --  Get the status of item and discard other values

      po_items_sv2.get_item_details(l_item_id,
                                        p_inv_org_id,
                                        l_planned_item_flag,
                                        l_outside_op_flag,
                                        l_outside_op_uom_type,
                                        l_invoice_close_tolerance,
                                        l_receive_close_tolerance,
                                        l_receipt_required_flag,
                                        l_stock_enabled_flag,
                                        l_internal_orderable,
                                        l_purchasing_enabled,
                                        l_inventory_asset_flag,
                                        --<INVCONV R12 START>
                                        l_secondary_default_ind,
                                        l_grade_control_flag,
                                        l_secondary_unit_of_measure ) ;
                                        --<INVCONV R12 END>

    IF (l_outside_op_flag = 'Y') THEN
          l_item_status := 'O'; -- Outside Processing
    ELSE
        IF (l_stock_enabled_flag = 'Y') THEN
                l_item_status := 'E'; -- Inventory
        ELSE
                l_item_status := 'D'; -- Expense
        END IF;

    END IF;

  --  Get the Accrue on receipt flag

    IF (l_item_status = 'O') THEN
    l_accrue_on_receipt_flag := 'Y';

    ELSIF   (l_item_status = 'E') THEN
    l_accrue_on_receipt_flag := 'Y';
    ELSE
            IF (l_expense_accrual_code = 'PERIOD END') THEN
      l_accrue_on_receipt_flag := 'N';
              ELSE
            l_accrue_on_receipt_flag  := l_poll_receipt_required_flag ;
              End IF;
    END IF;

    ELSE
            IF (l_expense_accrual_code = 'PERIOD END') THEN
      l_accrue_on_receipt_flag := 'N';
              ELSE
            l_accrue_on_receipt_flag  := l_poll_receipt_required_flag ;
              End IF;

    End if;      -- End of item_id condition

END IF;          -- End if Action code condition

l_progress := '080';

-- Pass the accrue on receipt flag as a parameter

  IF (l_internal_return_code = 0) THEN
    l_progress := '090';
    insert_shipment(x_po_shipment_record,
                    p_online_report_id,
                    x_sequence,
                    p_line_num,
                    l_accrue_on_receipt_flag,   -- Bug: 1402128
                    p_inv_org_id, -- Bug 2761415
                    l_internal_return_code,
                    p_is_complex_work_po,  -- <Complex Work R12>
                    p_orig_line_location_id); --<eTax Integration R12>

-- End bug fix : 1402128

-- COMMIT; < HTML Agreements R12>

    IF (l_internal_return_code = 0) THEN
      IF (p_copy_attachments) THEN
        l_progress := '100';
        fnd_attached_documents2_pkg.copy_attachments('PO_SHIPMENTS',
                                                     p_orig_line_location_id,
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     'PO_SHIPMENTS',
                                                     x_po_shipment_record.line_location_id,
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     fnd_global.user_id,
                                                     fnd_global.login_id,
                                                     '',
                                                     '',
                                                     '');
--     COMMIT; < HTML Agreements R12>
      END IF;

      l_progress := '110';

      -- Services FPJ Start
      -- After line insertion copy the price differentials related to the new shipment
      -- if the shipment has any price differentials

      IF  PO_PRICE_DIFFERENTIALS_PVT.has_price_differentials(p_entity_type => 'PRICE BREAK',
                                                             p_entity_id   => p_orig_line_location_id) THEN

         l_progress := '120';

         PO_PRICE_DIFFERENTIALS_PVT.copy_price_differentials (p_to_entity_id     => x_po_shipment_record.line_location_id,
                                                              p_to_entity_type   => 'PRICE BREAK',
                                                              p_from_entity_id   => p_orig_line_location_id,
                                                              p_from_entity_type => 'PRICE BREAK' );
--       COMMIT; < HTML Agreements R12>

      END IF;

      -- Services FPJ End

    END IF;
  END IF;

  x_return_code := l_internal_return_code;

EXCEPTION
  WHEN OTHERS THEN
    x_return_code := -1;
    copydoc_sql_error('process_shipment', l_progress, sqlcode,
                      p_online_report_id,
                      x_sequence,
                      p_line_num, x_po_shipment_record.shipment_num, 0);
    IF g_debug_unexp THEN            --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_exc
            (p_log_head => g_module_prefix||'process_shipment',
             p_progress => l_progress);
    END IF;
END process_shipment;


--< Shared Proc FPJ > Added header, line, shipment records as parameters.  Also
-- added generate accounts boolean
--<Encumbrance FPJ: add sob_id to param list>
PROCEDURE process_distribution
(
    p_action_code                IN     VARCHAR2,
    p_to_doc_subtype             IN     VARCHAR2,
    p_orig_po_distribution_id    IN     NUMBER,
    p_generate_new_accounts      IN     BOOLEAN,
    p_copy_attachments           IN     BOOLEAN,
    p_online_report_id           IN     NUMBER,
    p_po_header_rec              IN     PO_HEADERS%ROWTYPE,
    p_po_line_rec                IN     PO_LINES%ROWTYPE,
    p_po_shipment_rec            IN     PO_LINE_LOCATIONS%ROWTYPE,
    p_sob_id                     IN     FINANCIALS_SYSTEM_PARAMETERS.set_of_books_id%TYPE,
    x_po_distribution_rec        IN OUT NOCOPY PO_DISTRIBUTIONS%ROWTYPE,
    x_sequence                   IN OUT NOCOPY NUMBER,
    x_return_code                OUT    NOCOPY NUMBER
)
IS

  l_progress                 VARCHAR2(4);
  l_internal_return_code     NUMBER := NULL;
  l_return_status            VARCHAR2(1);

  --<ENCUMBRANCE FPJ>: use local vars for this to handle BPA case
  l_line_id           PO_LINES_ALL.po_line_id%TYPE;
  l_line_num          PO_LINES_ALL.line_num%TYPE;
  l_line_location_id  PO_LINE_LOCATIONS_ALL.line_location_id%TYPE;
  l_shipment_num      PO_LINE_LOCATIONS_ALL.shipment_num%TYPE;
  l_distribution_type PO_DISTRIBUTIONS_ALL.distribution_type%TYPE;

BEGIN

  l_progress := '000';

  --<ENCUMBRANCE FPJ START> Encumbered BPA dists do not have line/shipment
  IF nvl(p_po_header_rec.encumbrance_required_flag, 'N') = 'Y' THEN
     l_line_id := NULL;
     l_line_num := NULL;
     l_line_location_id := NULL;
     l_shipment_num := NULL;
     l_distribution_type := 'AGREEMENT';

  ELSE
     l_line_id := p_po_line_rec.po_line_id;
     l_line_num := p_po_line_rec.line_num;
     l_line_location_id := p_po_shipment_rec.line_location_id;
     l_shipment_num := p_po_shipment_rec.shipment_num;
     l_distribution_type := p_po_shipment_rec.shipment_type;

  END IF;
  --<ENCUMBRANCE FPJ END>

  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_stmt
          (p_log_head => g_module_prefix||'process_distribution',
           p_token    => 'invoked',
           p_message  => 'action_code: '||p_action_code||' to_doc_subtype: '||
                   p_to_doc_subtype||' header ID: '||
                   p_po_header_rec.po_header_id||' line ID: '||
                   l_line_id||' ship ID: '||
                   l_line_location_id||' orig_dist ID: '||
                   p_orig_po_distribution_id||' dist ID: '||
                   x_po_distribution_rec.po_distribution_id||
                   ' online_report ID: '||p_online_report_id);
  END IF;

  IF (p_action_code = 'PO') THEN
	    --< Shared Proc FPJ Start >
    IF p_generate_new_accounts THEN

        l_progress := '020';

        PO_COPYDOC_S5.generate_accounts
            (x_return_status              => l_return_status,
             p_online_report_id           => p_online_report_id,
             p_po_header_rec              => p_po_header_rec,
             p_po_line_rec                => p_po_line_rec,
             p_po_shipment_rec            => p_po_shipment_rec,
             x_po_distribution_rec        => x_po_distribution_rec,
             x_sequence                   => x_sequence);

        IF (l_return_status <> FND_API.g_ret_sts_success) THEN
            l_progress := '030';
            RAISE FND_API.g_exc_error;
        END IF;

    END IF;
    --< Shared Proc FPJ End >

    l_progress := '040';

    po_copydoc_s5.validate_distribution(p_action_code,
                                        p_to_doc_subtype,
                                        x_po_distribution_rec,
                                        p_po_header_rec.po_header_id,
                                        l_line_id,
                                        l_line_location_id,
                                        p_online_report_id,
                                        x_sequence,
                                        l_line_num,
                                        l_shipment_num,
                                        p_sob_id,
                                        l_internal_return_code);
--  COMMIT; < HTML Agreements R12>

    IF (l_internal_return_code = 0) THEN

      l_progress := '050';

/* Bug#1562540: kagarwal
** Desc: When copying POs we should not be copying the Requisition reference
** in the target PO Distribution from the distribution of the source PO.
** Setting the Req reference columns as null in the source distribution record.
*/
      x_po_distribution_rec.req_distribution_id := NULL;
      x_po_distribution_rec.req_header_reference_num := NULL;
      x_po_distribution_rec.req_line_reference_num := NULL;

      --<ENCUMBRANCE FPJ: add distribution type>
      x_po_distribution_rec.distribution_type := l_distribution_type;

      insert_distribution(x_po_distribution_rec,
                          p_online_report_id,
                          x_sequence,
                          l_line_num,
                          l_shipment_num,
                          l_internal_return_code);
--    COMMIT; < HTML Agreements R12>

      IF (l_internal_return_code = 0) THEN
        IF (p_copy_attachments) THEN
          l_progress := '060';

          fnd_attached_documents2_pkg.copy_attachments('PO_DISTRIBUTIONS',
                                                     p_orig_po_distribution_id,
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     'PO_DISTRIBUTIONS',
                                                     x_po_distribution_rec.po_distribution_id,
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     fnd_global.user_id,
                                                     fnd_global.login_id,
                                                     '',
                                                     '',
                                                     '');
--       COMMIT; < HTML Agreements R12>
        END IF;
      END IF;
    END IF;
  END IF;

  x_return_code := l_internal_return_code;

EXCEPTION
  --< Shared Proc FPJ Start >
  WHEN FND_API.g_exc_error THEN
    x_return_code := -1;
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'process_distribution',
             p_token    => l_progress,
             p_message  => 'FND_API.g_exc_error exception caught.');
    END IF;
  --< Shared Proc FPJ End >
  WHEN OTHERS THEN
    x_return_code := -1;
    copydoc_sql_error('process_distribution', l_progress, sqlcode,
                      p_online_report_id,
                      x_sequence,
                      l_line_num,
                      l_shipment_num,
                      x_po_distribution_rec.distribution_num);
    IF g_debug_unexp THEN            --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_exc
            (p_log_head => g_module_prefix||'process_distribution',
             p_progress => l_progress);
    END IF;
END process_distribution;
--
--< Shared Proc FPJ End >


/***************************************************************
 Copy header, line, shipment and distribution separately.
 for each, process and then copy
***************************************************************/
--<HTML Agreements R12 Start>
-- Added p_commit parameter so that we can control whether the api should
-- commit and return the control or return without commiting the data.
-- We are defaulting the value to Y so that if the code is called from FORMS
-- we would mantain the existing behavior
--<HTML Agreements R12 End>
PROCEDURE copy_document(
  x_action_code             IN      VARCHAR2,
  x_to_doc_subtype          IN      po_headers.type_lookup_code%TYPE,
  x_to_global_flag      IN      PO_HEADERS_ALL.global_agreement_flag%TYPE,  -- GA
  x_copy_attachments        IN      BOOLEAN,
  x_copy_price              IN      BOOLEAN,
  x_from_po_header_id       IN      po_headers.po_header_id%TYPE,
  x_to_po_header_id         OUT NOCOPY     po_headers.po_header_id%TYPE,
  x_online_report_id        OUT NOCOPY     po_online_report_text.online_report_id%TYPE,
  x_to_segment1             IN OUT NOCOPY  po_headers.segment1%TYPE,
  x_agent_id                IN      po_headers.agent_id%TYPE,
  x_sob_id                  IN      financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id              IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_wip_install_status      IN      VARCHAR2,
  x_return_code             OUT NOCOPY     NUMBER,
  x_copy_terms              IN VARCHAR2, -- <FPJ CONTERMS>
  p_api_commit              IN BOOLEAN,  --<HTML Agreements R12>
  p_from_doc_type           IN VARCHAR2  --<R12 eTax Integration>
) IS

  COPYDOC_FATAL              EXCEPTION;

  x_po_header_record         PO_HEADERS%ROWTYPE;
  x_po_line_record           po_lines%ROWTYPE;
  x_po_shipment_record       po_line_locations%ROWTYPE;
  x_po_distribution_record   po_distributions%ROWTYPE;

  x_orig_po_line_id          po_lines.po_line_id%TYPE;
  x_orig_line_location_id    po_line_locations.line_location_id%TYPE;
  x_orig_po_distribution_id  po_distributions.po_distribution_id%TYPE;

  x_line_num                 po_online_report_text.line_num%TYPE := NULL;
  x_shipment_num             po_online_report_text.shipment_num%TYPE := NULL;
  x_distribution_num         po_online_report_text.distribution_num%TYPE := NULL;

  x_progress                 VARCHAR2(4);
  x_internal_return_code     NUMBER;

  x_sequence                 po_online_report_text.sequence%TYPE := 1;
  /* this is used only for BID quotation to calculate quantity at the line
     level from shipments. */
  x_line_quantity            NUMBER;
  x_orig_quotation_class_code  po_headers.quotation_class_code%TYPE := NULL;

  --< Shared Proc FPJ Start >
  l_orig_txn_flow_header_id
      PO_LINE_LOCATIONS_ALL.transaction_flow_header_id%TYPE;
  l_generate_new_accounts BOOLEAN := FALSE;
  --< Shared Proc FPJ End >

  l_calling_program VARCHAR2(30); --<eTax Integration R12>
  l_return_status   VARCHAR2(1);  --<eTax Integration R12>

  l_is_complex_work_po  BOOLEAN;  -- <Complex Work R12>
  l_is_complex_finance_po  BOOLEAN; -- Bug # 13060566



BEGIN
  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_stmt
          (p_log_head => g_module_prefix||'copy_document',
           p_token    => 'invoked',
           p_message  => 'action_code: ' ||x_action_code||' to_doc_subtype: '||
                   x_to_doc_subtype||' from header ID: '||x_from_po_header_id||
                   ' to segment1: '||x_to_segment1||' agent ID: '||x_agent_id||
                   ' sob ID: '||x_sob_id);
  END IF;
  -- Standard start of API savepoint
  SAVEPOINT COPY_DOCUMENT_PVT;
  x_to_po_header_id := NULL;

  x_progress := '000';
  BEGIN
    SELECT po_online_report_text_s.nextval
    INTO   x_online_report_id
    FROM   SYS.DUAL;
  EXCEPTION
    WHEN OTHERS THEN
      x_online_report_id := NULL;
      po_copydoc_s1.COPYDOC_sql_error('copy_documents', x_progress, sqlcode,
                                      x_online_report_id,
                                      x_sequence,
                                      0, 0, 0);
  END;

  x_progress := '010';

  IF (x_action_code = NULL OR x_from_po_header_id = NULL) THEN
    RAISE COPYDOC_FATAL;
  END IF;

  -- <Complex Work R12 Start.
  x_progress := '015';

  l_is_complex_work_po :=
    PO_COMPLEX_WORK_PVT.is_complex_work_po(p_po_header_id => x_from_po_header_id);

  -- Bug#5159320 : Added a condition for x_to_doc_subtype=CONTRACT
  -- to allow Complex work style CPAs also to be duplicated.
  IF (l_is_complex_work_po AND
       ( NOT(
             (x_action_code = 'PO')
             AND
             ((x_to_doc_subtype = 'STANDARD') OR (x_to_doc_subtype = 'CONTRACT')))
        ))
  THEN
    RAISE COPYDOC_FATAL;
  END IF;

  -- <Complex Work R12 End>


  x_progress := '020';
  -- <R12 eTax Integration Start>
  -- Initialize global variable for tax. It will
  -- be used for insertion into header, line, shipment and distribution
  IF (x_to_doc_subtype IN ('STANDARD', 'PLANNED')) THEN
      IF (p_from_doc_type = 'QUOTATION') THEN
          g_tax_attribute_update_code := 'CREATE';
          l_calling_program :='COPY_QUOTE';
      ELSE
          g_tax_attribute_update_code := 'COPY_AND_CREATE';
          l_calling_program :='COPY_DOCUMENT';
      END IF;
  END IF;
  -- <R12 eTax Integration End>
  -- lpo, 06/04/98
  -- Note the following conditions for validate_(header|line|shipment|distribution)():
  -- Precondition : x_po_(header|line|shipment|distribution)_record contains
  --                the record we want to copy FROM.
  -- Postcondition: x_po_(header|line|shipment_location|distribution)_record contains
  --                the NEW record ready to be inserted.
  -- I intend to make most of the complexity reside in the validation phase; thus leaving
  -- the fetch and insert phases fairly simple.
  process_header(x_action_code,
                 x_to_doc_subtype,
     x_to_global_flag,      -- Global Agreements (FP-I)
                 x_po_header_record,
                 x_from_po_header_id,
                 x_to_segment1,
                 x_agent_id,
                 x_sob_id,
                 x_inv_org_id,
                 x_copy_attachments,
                 x_online_report_id,
                 x_sequence,
                 x_internal_return_code,
                 x_copy_terms); -- <FPJ CONTERMS>

  x_progress := '030';

  IF (x_internal_return_code <> 0) THEN
    RAISE COPYDOC_FATAL;
  END IF;

/**** during processing header, new po_header_id and segment1 are created **/
  x_to_po_header_id := x_po_header_record.po_header_id;
  IF (x_to_segment1 IS NULL) THEN
    x_to_segment1 := x_po_header_record.segment1;
  END IF;

  x_progress := '040';

  --<ENCUMBRANCE FPJ START>
  --Encumbrance required flag in the x_po_header_record is set in the
  --validate_header procedure during the header processing

  IF nvl(x_po_header_record.encumbrance_required_flag, 'N') = 'Y' THEN

     --Since there will be a one-one mapping between header and distribution
     --for an Encumbered blanket agreement to be copied to another blanket
     --agreement, just after the completion of headers processing, we copy
     --the distribution from the encumbered blanket agreement to the new
     --blanket agreement
     x_progress := '042';

     BEGIN
  SELECT * INTO x_po_distribution_record
        FROM PO_DISTRIBUTIONS POD
        WHERE POD.PO_HEADER_ID = x_from_po_header_id
        AND   POD.distribution_type = 'AGREEMENT';

     EXCEPTION
        WHEN TOO_MANY_ROWS THEN
           po_copydoc_s1.COPYDOC_sql_error('copy_documents', x_progress, sqlcode,
                                   x_online_report_id,
                                   x_sequence,
                                   0, 0, 1);
           x_internal_return_code := -1;
           RAISE COPYDOC_FATAL;
     END;


     x_progress := '044';
     x_orig_po_distribution_id := x_po_distribution_record.po_distribution_id;

     process_distribution(
        p_action_code             => x_action_code
     ,  p_to_doc_subtype          => x_to_doc_subtype
     ,  p_orig_po_distribution_id => x_orig_po_distribution_id
     ,  p_generate_new_accounts   => FALSE
     ,  p_copy_attachments        => x_copy_attachments
     ,  p_online_report_id        => x_online_report_id
     ,  p_po_header_rec           => x_po_header_record
     ,  p_po_line_rec             => NULL
     ,  p_po_shipment_rec         => NULL
     ,  p_sob_id                  => x_sob_id
     ,  x_po_distribution_rec     => x_po_distribution_record
     ,  x_sequence                => x_sequence
     ,  x_return_code             => x_internal_return_code);

     x_progress := '046';

  END IF; --bug 3338216: changed this from an 'else' to 'end if'
  --<ENCUMBRANCE FPJ END>

  x_progress := '048';

  SELECT quotation_class_code
  INTO   x_orig_quotation_class_code
  FROM   po_headers
  WHERE  po_header_id = x_from_po_header_id;

  OPEN po_line_cursor(x_from_po_header_id);

  /** for every line in the PO, fetch and store in x_po_line_record,
      then process line.
   Repeat above steps until all lines have been fetched and processed **/
  <<LINES>>
  LOOP

    FETCH po_line_cursor INTO x_po_line_record;
    EXIT LINES WHEN po_line_cursor%NOTFOUND;

    x_progress := '050';

    x_orig_po_line_id := x_po_line_record.po_line_id;
    x_line_num        := x_po_line_record.line_num;


    /*  Functionality for PA->RFQ Copy : dreddy
    new parameter copy_price is added */
    process_line(x_action_code,
     x_to_doc_subtype,
     x_po_line_record,
     x_orig_po_line_id,
     x_wip_install_status,
     x_sob_id,
     x_inv_org_id,
     x_to_po_header_id,
     x_copy_attachments,
     x_copy_price,
     x_online_report_id,
     x_sequence,
     x_internal_return_code,
     l_is_complex_work_po);  -- <Complex Work R12>

    IF (x_internal_return_code = 0) THEN

      OPEN po_shipment_cursor(x_orig_po_line_id);
      x_line_quantity := 0;  -- initialize for each line

  <<SHIPMENTS>>
  LOOP

    FETCH po_shipment_cursor INTO x_po_shipment_record;
    EXIT SHIPMENTS WHEN po_shipment_cursor%NOTFOUND;

  /** Bug 940844
   *  bgu, July 21, 1999
   *  For blanket agreement, only its shipment of type 'PRICE BREAK'
   *  should be copied. We should not copy shipment of type 'BLANKET',
   *  i.e., the shipment of BA's release.
   */
  IF (x_po_header_record.type_lookup_code='BLANKET'
     and (x_po_shipment_record.shipment_type='BLANKET')) then
    x_progress := '060';
  ELSE
    x_progress := '070';

    x_orig_line_location_id := x_po_shipment_record.line_location_id;
    x_shipment_num          := x_po_shipment_record.shipment_num;

    --< Shared Proc FPJ Start >
    l_orig_txn_flow_header_id :=
        x_po_shipment_record.transaction_flow_header_id;

    process_shipment(p_action_code           => x_action_code,
         p_to_doc_subtype        => x_to_doc_subtype,
         p_orig_line_location_id => x_orig_line_location_id,
         p_po_header_id          => x_to_po_header_id,
         p_po_line_id            => x_po_line_record.po_line_id,
         p_item_category_id      => x_po_line_record.category_id,
                           p_item_id               => x_po_line_record.item_id,--Bug 3433867
         p_copy_attachments      => x_copy_attachments,
         p_copy_price            => x_copy_price,
         p_online_report_id      => x_online_report_id,
         p_line_num              => x_line_num,
         p_inv_org_id            => x_inv_org_id,
         x_po_shipment_record    => x_po_shipment_record,
         x_sequence              => x_sequence,
         x_return_code           => x_internal_return_code,
         p_is_complex_work_po    => l_is_complex_work_po); -- <Complex Work R12>;

    -- Need to generate new accounts if the txn flow processed is now
    -- different than the original txn flow
    IF (NVL(l_orig_txn_flow_header_id, -99) <>
        NVL(x_po_shipment_record.transaction_flow_header_id, -99))
    THEN
        l_generate_new_accounts := TRUE;
    END IF;
    --< Shared Proc FPJ End >

    /* only do this for BID quotation */
    -- Modified the condition for Bug 9754725 ,now this block is for BID, Std PO and Planned PO
     IF(x_internal_return_code = 0 AND (x_orig_quotation_class_code = 'BID' OR (x_action_code='PO' AND (x_to_doc_subtype = 'STANDARD' OR x_to_doc_subtype = 'PLANNED') AND NOT l_is_complex_work_po))) THEN
       x_line_quantity := x_line_quantity + nvl(x_po_shipment_record.quantity, 0);
    END IF;
    --Bug 13060566
     IF l_is_complex_work_po  THEN

       l_is_complex_finance_po:=PO_COMPLEX_WORK_PVT.is_financing_po(x_from_po_header_id);


        IF( l_is_complex_finance_po AND x_po_shipment_record.shipment_type LIKE 'STANDARD') THEN

             x_line_quantity := x_line_quantity + Nvl(x_po_shipment_record.quantity,0); --Add the shipment quantities of STANDARD type for Complex Services (Finance) PO.

        ELSIF NOT l_is_complex_finance_po THEN

             x_line_quantity  := Nvl(x_po_shipment_record.quantity,0);    -- Copy any one of the shipment quantities for Complex Services (Actuals) PO.

        END IF ;


     END IF ;

     --Enf of Bug 13060566

    IF (x_internal_return_code = 0) THEN
      OPEN po_distribution_cursor(x_orig_line_location_id);

      <<DISTRIBUTIONS>>
      LOOP

        FETCH po_distribution_cursor INTO x_po_distribution_record;
        EXIT DISTRIBUTIONS WHEN po_distribution_cursor%NOTFOUND;


        x_progress := '080';

        x_orig_po_distribution_id := x_po_distribution_record.po_distribution_id;
        x_distribution_num        := x_po_distribution_record.distribution_num;

        --< Shared Proc FPJ Start >
        process_distribution
     (p_action_code             => x_action_code,
      p_to_doc_subtype          => x_to_doc_subtype,
      p_orig_po_distribution_id => x_orig_po_distribution_id,
      p_generate_new_accounts   => l_generate_new_accounts,
      p_copy_attachments        => x_copy_attachments,
      p_online_report_id        => x_online_report_id,
      p_po_header_rec           => x_po_header_record,
      p_po_line_rec             => x_po_line_record,
      p_po_shipment_rec         => x_po_shipment_record,
                  p_sob_id                  => x_sob_id,
      x_po_distribution_rec     => x_po_distribution_record,
      x_sequence                => x_sequence,
      x_return_code             => x_internal_return_code);
        --< Shared Proc FPJ End >

      END LOOP DISTRIBUTIONS;
      CLOSE po_distribution_cursor;
    END IF;
  END IF; -- For testing whether the shipment is for a blanket release
      END LOOP SHIPMENTS;
      CLOSE po_shipment_cursor;

      /*  got total quantity from all shipments under the line */
       -- Modified the condition for Bug 9754725 ,now this block is for BID, Std PO and Planned PO
    IF (x_orig_quotation_class_code = 'BID' OR (x_action_code='PO' AND (x_to_doc_subtype = 'STANDARD' OR x_to_doc_subtype = 'PLANNED'))) THEN
   x_progress := '090';

   UPDATE PO_LINES
   SET quantity = x_line_quantity
   WHERE po_header_id = x_to_po_header_id
   AND po_line_id = x_po_line_record.po_line_id;

--       COMMIT; < HTML Agreements R12>
      END IF;

    END IF;

  END LOOP LINES;
  CLOSE po_line_cursor;

  --Call PO Tax API to calculate tax
      PO_TAX_INTERFACE_PVT.calculate_tax(
                        p_po_header_id_tbl  => PO_TBL_NUMBER(x_to_po_header_id),
                        p_po_release_id_tbl => PO_TBL_NUMBER(),
                        p_calling_program =>l_calling_program,
                        x_return_status => l_return_status);
  --<eTax Integration R12 End>
  x_progress := '100';

  IF (x_sequence > 1) THEN
    --< Shared Proc FPJ > Corrected calculation of return code so that it will
    -- be negative if any records were inserted into online report table.
    x_return_code := 1 - x_sequence;
  ELSE
    x_return_code := 0;
    --< HTML Agreements R12 Start>
     x_progress := '110';
    -- We only commit if p_commit is true
    IF p_api_commit THEN
      COMMIT WORK;
    END IF;
    --< HTML Agreements R12 End>
  END IF;

  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_stmt
          (p_log_head => g_module_prefix||'copy_document',
           p_token    => 'end',
           p_message  => 'x_return_code = '||x_return_code||
                         ' x_sequence = '||x_sequence);
  END IF;

EXCEPTION
  WHEN COPYDOC_FATAL THEN
    ROLLBACK TO SAVEPOINT COPY_DOCUMENT_PVT; --< HTML Agreements R12>
    IF g_debug_stmt THEN             --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'copy_document',
             p_token    => x_progress,
             p_message  => 'COPYDOC_FATAL exception caught.');
    END IF;
    handle_fatal(x_return_code);
    RAISE;
  WHEN OTHERS THEN
    ROLLBACK TO SAVEPOINT COPY_DOCUMENT_PVT; --< HTML Agreements R12>
    IF g_debug_unexp THEN            --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_exc
            (p_log_head => g_module_prefix||'copy_document',
             p_progress => x_progress);
    END IF;
    copydoc_sql_error('copy_document', x_progress, sqlcode,
                      x_online_report_id,
                      x_sequence,
                      x_line_num,
                      x_shipment_num,
                      x_distribution_num);
--  COMMIT; < HTML Agreements R12>
    handle_fatal(x_return_code);
    RAISE;
END copy_document;

-- Bug 2744363 START
/**
* Function: po_is_dropship
* Requires: none
* Modifies: none
* Effects: Checks whether the given PO is drop ship
* Returns: TRUE if any of the shipments in the given PO are drop ship,
*   FALSE otherwise.
**/
FUNCTION po_is_dropship (
  p_po_header_id PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN IS

CURSOR l_po_shipment_csr(p_po_header_id PO_HEADERS_ALL.po_header_id%TYPE) IS
SELECT line_location_id
FROM PO_LINE_LOCATIONS
WHERE po_header_id = p_po_header_id
AND SHIPMENT_TYPE NOT IN ('SCHEDULED','BLANKET');

l_line_location_id PO_LINE_LOCATIONS.line_location_id%TYPE;

BEGIN
  OPEN l_po_shipment_csr(p_po_header_id);

  LOOP
    FETCH l_po_shipment_csr INTO l_line_location_id;
    EXIT WHEN l_po_shipment_csr%NOTFOUND;

    IF (OE_DROP_SHIP_GRP.po_line_location_is_drop_ship(l_line_location_id)
        IS NOT NULL) THEN
      CLOSE l_po_shipment_csr;
      RETURN TRUE;
    END IF;
  END LOOP;

  CLOSE l_po_shipment_csr;
  RETURN FALSE;
EXCEPTION
  WHEN OTHERS THEN
    CLOSE l_po_shipment_csr;
    RAISE;
END;
-- Bug 2744363 END

-- <CONFIG_ID FPJ START>

----------------------------------------------------------------------------
--Start of Comments
--Name: po_has_config_id
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Checks whether any lines on the given PO have a config ID.
--Parameters:
--IN:
--p_po_header_id
--  header ID of the PO to check
--Returns:
--  TRUE if any of the lines on the given PO have a config ID,
--  FALSE otherwise.
--Testing:
--  None
--End of Comments
----------------------------------------------------------------------------

FUNCTION po_has_config_id(
  p_po_header_id IN PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN IS

  l_has_config_id NUMBER;

BEGIN

  SELECT count(*) INTO l_has_config_id
  FROM po_lines
  WHERE po_header_id = p_po_header_id AND
        supplier_ref_number IS NOT NULL;

  IF (l_has_config_id = 0) THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    PO_MESSAGE_S.sql_error('PO_HAS_CONFIG_ID', '000', sqlcode);
    RAISE;

END po_has_config_id;

----------------------------------------------------------------------------
--Start of Comments
--Name: req_has_config_id
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Checks whether any lines on the given requisition have a config ID.
--Parameters:
--IN:
--p_requisition_header_id
--  header ID of the requisition to check
--Returns: TRUE if any of the lines on the given requisition have a config ID,
--         FALSE otherwise.
--Testing:
--  None
--End of Comments
----------------------------------------------------------------------------

FUNCTION req_has_config_id(
  p_requisition_header_id IN PO_REQUISITION_HEADERS_ALL.requisition_header_id%TYPE
) RETURN BOOLEAN IS

  l_has_config_id NUMBER;

BEGIN

  SELECT count(*) INTO l_has_config_id
  FROM po_requisition_lines
  WHERE requisition_header_id = p_requisition_header_id AND
        supplier_ref_number IS NOT NULL;

  IF (l_has_config_id = 0) THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    PO_MESSAGE_S.sql_error('REQ_HAS_CONFIG_ID', '000', sqlcode);
    RAISE;

END req_has_config_id;

-- <CONFIG_ID FPJ END>
--<HTML Agreements R12 Start>
------------------------------------------------------------------------
--Start of Comments
--Name: val_params_and_duplicate_doc
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None Directly.
--Function:
-- It will act as a wrapper to the copy_document procedure. It will get
-- all the required parameters for invoking copy_document procedure and
-- invoke it. This procedure only supports PO/PA copy
--IN:
-- p_po_header_id
-- Document Header Id of The Existing Document to be copied
--p_copy_attachment
-- Flag determining whether attachment can be copied or not
--p_copy_terms
-- Flag determining whether terms can be copied or not
--OUT:
--x_new_po_header_id
-- Document Header Id of The New Document created
--x_errmsg_code
-- Contains the message name of the error to be shown in case of an
-- expected error due to validation failure
--x_message_type
-- MessageType for online report message if any inserted to the table
-- while procedure execution
--x_text_line
-- Message if any inserted to the online_report_text table while procedure
-- execution.
--x_return_status
-- Return Status of API .
--x_exception_msg
-- Message in case of Unhandled Exception.
--IN OUT:
--x_new_segment1
-- In case Numbering is manual user provides a value else if automatic
-- the generated value is returned to the user
--Testing:
-- Refer the Unit Test Plan for 'HTML Agreements R12'
--End of Comments
----------------------------------------------------------------------------

procedure val_params_and_duplicate_doc( p_po_header_id     IN            NUMBER
                                       ,p_copy_attachment  IN            VARCHAR2
                                       ,p_copy_terms       IN            VARCHAR2
                                       ,x_new_segment1     IN OUT NOCOPY VARCHAR2
                                       ,x_new_po_header_id    OUT NOCOPY NUMBER
                                       ,x_errmsg_code         OUT NOCOPY VARCHAR2
                                       ,x_message_type        OUT NOCOPY VARCHAR2
                                       ,x_text_line           OUT NOCOPY VARCHAR2
                                       ,x_return_status       OUT NOCOPY VARCHAR2
                                       ,x_exception_msg       OUT NOCOPY VARCHAR2)
IS
  l_doc_org_id                PO_HEADERS_ALL.ORG_ID%type;
  l_type_lookup_code      PO_HEADERS_ALL.type_lookup_code%type;
  l_global_agreement_flag PO_HEADERS_ALL.global_agreement_flag%type;
  l_inv_org_id            FINANCIALS_SYSTEM_PARAMS_ALL.inventory_organization_id%type;
  l_sob_id                FINANCIALS_SYSTEM_PARAMS_ALL.set_of_books_id%type;
  l_return_code           NUMBER;
  l_online_report_id      PO_ONLINE_REPORT_TEXT.online_report_id%type;
  d_pos     NUMBER;
  d_module       VARCHAR2(70) := 'po.plsql.PO_COPYDOC_S1.VAL_PARAMS_AND_DUPLICATE_DOC';
  d_log_msg      VARCHAR2(200);
BEGIN
  --Initialise the variables
  d_pos := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
    PO_LOG.proc_begin(d_module, 'p_copy_attachment', p_copy_attachment);
    PO_LOG.proc_begin(d_module, 'p_copy_terms', p_copy_terms);
    PO_LOG.proc_begin(d_module, 'x_new_segment1', x_new_segment1);
  END IF;
  d_pos := 10;
  x_return_status := FND_API.g_ret_sts_success;
  x_errmsg_code := NULL;
  l_return_code := NULL;
  l_online_report_id := NULL;
  x_exception_msg := NULL;

  d_pos := 15;
  --Get the required header attributes for the PO/PA
  SELECT POH.ORG_ID,POH.TYPE_LOOKUP_CODE,
         POH.GLOBAL_AGREEMENT_FLAG,
         FSP.INVENTORY_ORGANIZATION_ID,
         FSP.SET_OF_BOOKS_ID
  INTO   l_doc_org_id, l_type_lookup_code,
         l_global_agreement_flag,
         l_inv_org_id, l_sob_id
  FROM   po_headers_all POH, financials_system_params_all FSP
  WHERE  po_header_id = p_po_header_id
  AND    poh.org_id = fsp.org_id;

  IF PO_LOG.d_stmt THEN
   PO_LOG.stmt(d_module,d_pos,'l_doc_org_id',l_doc_org_id);
   PO_LOG.stmt(d_module,d_pos,'l_type_lookup_code',l_type_lookup_code);
   PO_LOG.stmt(d_module,d_pos,'l_global_agreement_flag',l_global_agreement_flag);
   PO_LOG.stmt(d_module,d_pos,'l_inv_org_id',l_inv_org_id);
   PO_LOG.stmt(d_module,d_pos,'l_sob_id',l_sob_id);
  END IF;

  d_pos := 20;
  --Check if the PO Number Provided by the user is unique
  IF (x_new_segment1 IS NOT NULL) THEN
      d_pos := 25;
    IF(NOT  PO_CORE_S.Check_Doc_Number_Unique(x_new_segment1,
                                              l_doc_org_id,
                                              l_type_lookup_code)) THEN
      x_errmsg_code := 'PO_ALL_ENTER_UNIQUE_VAL';
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_module,d_pos,'Segment1 value not unique');
      END IF;
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;
  d_pos := 30;
  --Check if the PO is a drop ship PO
  IF(PO_COPYDOC_S1.po_is_dropship(p_po_header_id)) THEN
    d_pos := 35;
    x_errmsg_code := 'PO_NOT_SUPPORT_COPY_DROPSHIPPO';
    IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_module,d_pos,'Duplicate Document not supported for DropShip PO');
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  d_pos := 40;
  --Check if the PO has a config id associated with it
  IF(PO_COPYDOC_S1.po_has_config_id(p_po_header_id)) THEN
    d_pos := 45;
    x_errmsg_code := 'PO_CANNOT_COPY_CONFIG_ID_DOC';
    IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_module,d_pos,'Duplicate Document not supported for PO with Config ID');
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  d_pos := 50;
  --If validations go thru fine invoke the copy_document procedure
  IF PO_LOG.d_event THEN
      PO_LOG.event(d_module,d_pos,'Invoking PO_COPYDOC_S1.Copy Document Procedure');
  END IF;

  copy_document (
   x_action_code        => 'PO',
   x_to_doc_subtype     =>  l_type_lookup_code,
   x_to_global_flag     =>  l_global_agreement_flag,
   x_copy_attachments   =>  PO_CORE_S.flag_to_boolean(p_copy_attachment),
   x_copy_price         =>  PO_CORE_S.flag_to_boolean('N'),
   x_from_po_header_id  =>  p_po_header_id,
   x_to_po_header_id    =>  x_new_po_header_id,
   x_online_report_id   =>  l_online_report_id,
   x_to_segment1        =>  x_new_segment1,
   x_agent_id           =>  fnd_global.employee_id,
   x_sob_id             =>  l_sob_id,
   x_inv_org_id         =>  l_inv_org_id,
   x_wip_install_status =>  PO_CORE_S.get_product_install_status('WIP'),
   x_return_code        =>  l_return_code,
   x_copy_terms         =>  p_copy_terms,
   p_api_commit         =>  FALSE); --Do not Commit

  IF PO_LOG.d_event THEN
    PO_LOG.event(d_module,d_pos,'PO_COPYDOC_S1.Copy Document Procedure call completed');
  END IF;
  d_pos := 60;
   --If online_report_id is not null get the message
  IF (l_online_report_id is NOT NULL) THEN
    d_pos := 65;
    PO_COPYDOC_S1.ret_and_del_online_report_rec( l_online_report_id
                                                ,x_message_type
                                                ,x_text_line);
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module,d_pos,'l_online_report_id',l_online_report_id);
      PO_LOG.stmt(d_module,d_pos,'x_message_type',x_message_type);
      PO_LOG.stmt(d_module,d_pos,'x_text_line',x_text_line);
    END IF;
  END IF;
  d_pos := 70;
  IF(l_return_code < 0) THEN
    d_pos := 75;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_module,'x_new_segment1',x_new_segment1);
    PO_LOG.proc_end(d_module,'x_new_po_header_id',x_new_po_header_id);
    PO_LOG.proc_end(d_module,'x_errmsg_code',x_errmsg_code);
    PO_LOG.proc_end(d_module,'x_message_type',x_message_type);
    PO_LOG.proc_end(d_module,'x_text_line',x_text_line);
    PO_LOG.proc_end(d_module,'x_return_status',x_return_status);
    PO_LOG.proc_end(d_module,'x_exception_msg',x_exception_msg);
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF(x_text_line is not null) THEN
      x_exception_msg := x_text_line;
	  x_return_status := FND_API.g_ret_sts_error; /*Bug:13077836 */
    ELSE
      x_exception_msg := 'Unexpected Error in ' || d_module||'-'||d_pos;
    END IF;
    IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_module,d_pos,x_exception_msg);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF (l_online_report_id is NOT NULL) THEN
      PO_COPYDOC_S1.ret_and_del_online_report_rec( l_online_report_id
                                                  ,x_message_type
                                                  ,x_text_line);
    END IF;
    IF(x_text_line is not null) THEN
      x_exception_msg := x_text_line;
    ELSE
      x_exception_msg := 'Unhandled Exception in ' || d_module||'-'||d_pos;
    END IF;
    IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_module,d_pos,x_exception_msg);
    END IF;
END val_params_and_duplicate_doc;
--<HTML Agreements R12 End>
END po_copydoc_s1;

/
