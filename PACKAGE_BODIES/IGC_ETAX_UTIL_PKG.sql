--------------------------------------------------------
--  DDL for Package Body IGC_ETAX_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_ETAX_UTIL_PKG" AS
/* $Header: IGCETXUB.pls 120.7.12010000.2 2008/11/25 16:07:17 sasukuma ship $ */


  -- Create global variables to maintain the session info
  l_user_id             igc_cc_headers.created_by%TYPE         := FND_GLOBAL.user_id;
  l_login_id            igc_cc_headers.last_update_login%TYPE  := FND_GLOBAL.login_id;
  l_sysdate             DATE := sysdate;

  G_PKG_NAME          CONSTANT VARCHAR2(30)     := 'IGC_ETAX_UTIL_PKG';
  G_MSG_UERROR        CONSTANT NUMBER           := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR         CONSTANT NUMBER           := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER           := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH          CONSTANT NUMBER           := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM        CONSTANT NUMBER           := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW           CONSTANT NUMBER           := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
  G_LINES_PER_FETCH   CONSTANT NUMBER           := 1000;
  g_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(64) := 'IGC.PLSQL.ICETXUB.IGC_ETAX_UTIL_PKG.';
  G_ORG_LOC_ID            HR_ALL_ORGANIZATION_UNITS.location_id%TYPE;

 FUNCTION Populate_Dist_GT(
               P_CC_Header_Rec           IN igc_cc_headers%ROWTYPE,
               P_Line_Id                 IN  igc_cc_acct_lines.cc_acct_line_id%type,
               P_Calling_Mode            IN VARCHAR2,
               P_Error_Code              OUT NOCOPY VARCHAR2,
               P_Calling_Sequence        IN VARCHAR2,
               P_Amount                  IN NUMBER) RETURN VARCHAR2 ;

  PROCEDURE Put_Debug_Msg (
     p_path      IN VARCHAR2,
     p_debug_msg IN VARCHAR2,
     p_sev_level IN VARCHAR2 := G_LEVEL_STATEMENT
  );

  PROCEDURE set_tax_security_context
                                (p_org_id               IN NUMBER,
                                 p_legal_entity_id      IN NUMBER,
                                 p_transaction_date     IN DATE,
                                 p_related_doc_date     IN DATE,
                                 p_adjusted_doc_date    IN DATE,
                                 p_effective_date       OUT NOCOPY DATE,
                                 p_return_status        OUT NOCOPY VARCHAR2,
                                 p_msg_count            OUT NOCOPY NUMBER,
                                 p_msg_data             OUT NOCOPY VARCHAR2) IS

       l_debug_info     VARCHAR2(240);

  BEGIN
        ---------------------------------------------------------------
        l_debug_info := 'Calling zx_api_pub.set_tax_security_context';
        ---------------------------------------------------------------

        IF p_org_id           IS NOT NULL AND
           p_legal_entity_id  IS NOT NULL AND
           p_transaction_date IS NOT NULL THEN

           zx_api_pub.set_tax_security_context
                                (p_api_version          => 1.0,
                                 p_init_msg_list        => FND_API.G_FALSE,
                                 p_commit               => FND_API.G_FALSE,
                                 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                                 x_return_status        => p_return_status,
                                 x_msg_count            => p_msg_count,
                                 x_msg_data             => p_msg_data,
                                 p_internal_org_id      => p_org_id,
                                 p_legal_entity_id      => p_legal_entity_id,
                                 p_transaction_date     => p_transaction_date,
                                 p_related_doc_date     => p_related_doc_date,
                                 p_adjusted_doc_date    => p_adjusted_doc_date,
                                 x_effective_date       => p_effective_date);

        END IF;

  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGC','IGC_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'IGC_ETAX_UTIL_PKG.set_tax_security_context');
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_org_id: '           || p_org_id           ||
                                            'p_legal_entity_id: '  || p_legal_entity_id  ||
                                            'p_transaction_date: ' || p_transaction_date ||
                                            'p_related_doc_date: ' || p_related_doc_date ||
              'p_adjusted_doc_date:' || p_adjusted_doc_date);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     APP_EXCEPTION.RAISE_EXCEPTION;

  END set_tax_security_context;


  FUNCTION Populate_Headers_GT(
             P_CC_Header_Rec             IN igc_cc_headers%ROWTYPE,
             P_Calling_Mode              IN VARCHAR2,
             --P_Event_Class_Code          IN VARCHAR2,
             --P_Event_Type_Code           IN VARCHAR2,
       P_Legal_Entity_Id     IN NUMBER,
             P_Error_Code                OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS


    l_precision                  fnd_currencies.precision%TYPE;
    l_minimum_accountable_unit   fnd_currencies.minimum_accountable_unit%TYPE;

    l_calling_sequence           VARCHAR2(240);
    l_return_status              VARCHAR2(32) := FND_API.G_RET_STS_UNEXP_ERROR;
    l_api_name                   VARCHAR2(30) := 'Populate_Headers_gt';
    l_debug_info                 VARCHAR2(240);
    l_rounding_bill_to_party_id    HR_ALL_ORGANIZATION_UNITS.organization_id%Type;
    l_ledger_currency             fnd_currencies.currency_code%type;

  BEGIN

  l_debug_info := 'Populating zx header table';

  IF P_CC_Header_Rec.cc_header_id   IS NOT NULL AND
           P_Legal_Entity_Id IS NOT NULL then

    /* Modified for bug#6719456.Use ledger currency instead of transaction currency */
    SELECT currency_code
    INTO  l_ledger_currency
    FROM  gl_ledgers
    WHERE ledger_id = P_CC_Header_Rec.set_of_books_id;

    SELECT NVL(precision, 0), NVL(minimum_accountable_unit,(1/power(10,precision)))
    INTO l_precision, l_minimum_accountable_unit
    FROM fnd_currencies
    WHERE currency_code = l_ledger_currency;


    DELETE FROM zx_trx_headers_gt
    WHERE application_id   = IGC_ETAX_UTIL_PKG.IGC_APPLICATION_ID
    AND entity_code      = IGC_ETAX_UTIL_PKG.IGC_ENTITY_CODE
    AND event_class_code = IGC_ETAX_UTIL_PKG.IGC_EVENT_CLASS_CODE
    AND trx_id           = P_CC_Header_Rec.cc_header_id;

    IF g_org_loc_id is NOT NULL THEN -- Bug#6647075
      l_rounding_bill_to_party_id := P_CC_Header_Rec.org_id;
    END IF;


    INSERT INTO zx_trx_headers_gt(
    internal_organization_id,
    internal_org_location_id,
    application_id,
    entity_code,
    event_class_code,
    event_type_code,
    trx_id,
    hdr_trx_user_key1,
    hdr_trx_user_key2,
    hdr_trx_user_key3,
    hdr_trx_user_key4,
    hdr_trx_user_key5,
    hdr_trx_user_key6,
    trx_date,
    trx_doc_revision,
    ledger_id,
    trx_currency_code,
    currency_conversion_date,
    currency_conversion_rate,
    currency_conversion_type,
    minimum_accountable_unit,
    precision,
    legal_entity_id,
    rounding_ship_to_party_id,
    rounding_ship_from_party_id,
    rounding_bill_to_party_id,
    rounding_bill_from_party_id,
    rndg_ship_to_party_site_id,
    rndg_ship_from_party_site_id,
    rndg_bill_to_party_site_id,
    rndg_bill_from_party_site_id,
    establishment_id,
    receivables_trx_type_id,
    related_doc_application_id,
    related_doc_entity_code,
    related_doc_event_class_code,
    related_doc_trx_id,
    rel_doc_hdr_trx_user_key1,
    rel_doc_hdr_trx_user_key2,
    rel_doc_hdr_trx_user_key3,
    rel_doc_hdr_trx_user_key4,
    rel_doc_hdr_trx_user_key5,
    rel_doc_hdr_trx_user_key6,
    related_doc_number,
    related_doc_date,
    default_taxation_country,
    quote_flag,
    ctrl_total_hdr_tx_amt,
    trx_number,
    trx_description,
    trx_communicated_date,
    batch_source_id,
    batch_source_name,
    doc_seq_id,
    doc_seq_name,
    doc_seq_value,
    trx_due_date,
    trx_type_description,
    document_sub_type,
    supplier_tax_invoice_number,
    supplier_tax_invoice_date,
    supplier_exchange_rate,
    tax_invoice_date,
    tax_invoice_number,
    tax_event_class_code,
    tax_event_type_code,
    doc_event_status,
    rdng_ship_to_pty_tx_prof_id,
    rdng_ship_from_pty_tx_prof_id,
    rdng_bill_to_pty_tx_prof_id,
    rdng_bill_from_pty_tx_prof_id,
    rdng_ship_to_pty_tx_p_st_id,
    rdng_ship_from_pty_tx_p_st_id,
    rdng_bill_to_pty_tx_p_st_id,
    rdng_bill_from_pty_tx_p_st_id,
    bill_third_pty_acct_id,
    bill_third_pty_acct_site_id,
    ship_third_pty_acct_id,
    ship_third_pty_acct_site_id,
    icx_session_id)
    VALUES
    (
    P_CC_Header_Rec.org_id,                            --internal_organization_id
    NULL, --P_CC_Header_Rec.location_id,               --internal_org_location_id ^^
    IGC_ETAX_UTIL_PKG.IGC_APPLICATION_ID,              --application_id
    IGC_ETAX_UTIL_PKG.IGC_ENTITY_CODE,                 --entity_code
    IGC_ETAX_UTIL_PKG.IGC_EVENT_CLASS_CODE,            --event_class_code
    IGC_ETAX_UTIL_PKG.IGC_EVENT_TYPE_CODE,             --event_type_code
    P_CC_Header_Rec.cc_header_id,                      --trx_id
    NULL,                                              --hdr_trx_user_key1
    NULL,                                              --hdr_trx_user_key2
    NULL,                                              --hdr_trx_user_key3
    NULL,                                              --hdr_trx_user_key4
    NULL,                                              --hdr_trx_user_key5
    NULL,                                              --hdr_trx_user_key6
    nvl(P_CC_Header_Rec.cc_acct_date,sysdate), -- *check* p_invoice_header_rec.invoice_date,                 --trx_date
    NULL,                                              --trx_doc_revision
    P_CC_Header_Rec.set_of_books_id,                   --ledger_id
    l_ledger_currency,                                 --trx_currency_code
    null,                                              --currency_conversion_date
    null,                                              --currency_conversion_rate
    null,                                              --currency_conversion_type
    l_minimum_accountable_unit,                        --minimum_accountable_unit
    l_precision,                                       --precision
    P_Legal_Entity_Id, --*check* p_invoice_header_rec.legal_entity_id,              --legal_entity_id
    P_CC_Header_Rec.vendor_id,                         --rounding_ship_to_party_id ^^
    NULL,                                              --rounding_ship_from_party_id *CC*
    l_rounding_bill_to_party_id,                       --rounding_bill_to_party_id
    NULL,                                              --rounding_bill_from_party_id *CC*
    NULL,                                              --rndg_ship_to_party_site_id
    NULL,                                              --rndg_ship_from_party_site_id *CC*
    NULL,                                              --rndg_bill_to_party_site_id
    NULL,                                              --rndg_bill_from_party_site_id *CC*
    NULL,                                              --establishment_id
    NULL,                                              --receivables_trx_type_id
    NULL,                                              --related_doc_application_id *CC*
    NULL,                                              --related_doc_entity_code *CC*
    NULL,                                              --related_doc_event_class_code *CC*
    NULL,                                              --related_doc_trx_id *CC*
    NULL,                                              --rel_doc_hdr_trx_user_key1
    NULL,                                              --rel_doc_hdr_trx_user_key2
    NULL,                                              --rel_doc_hdr_trx_user_key3
    NULL,                                              --rel_doc_hdr_trx_user_key4
    NULL,                                              --rel_doc_hdr_trx_user_key5
    NULL,                                              --rel_doc_hdr_trx_user_key6
    NULL,                                              --related_doc_number *CC*
    NULL,                                              --related_doc_date *CC*
    NULL, --*check* p_invoice_header_rec.taxation_country,             --default_taxation_country
    IGC_ETAX_UTIL_PKG.IGC_TAX_QUOTE_FLAG,              --quote_flag
    NULL,                                              --ctrl_total_hdr_tx_amt *CC*
    P_CC_Header_Rec.cc_num,                            --trx_number *CC*
    NULL,                                              --trx_description
    NULL,                                              --trx_communicated_date
    NULL,                                              --batch_source_id
    NULL,                                              --batch_source_name
    NULL,                                              --doc_seq_id *CC*
    NULL,                                              --doc_seq_name *CC*
    NULL,                                              --doc_seq_value *CC*
    NULL,                                              --trx_due_date
    NULL,                                              --trx_type_description *CC*
    NULL,                                              --document_sub_type *CC*
    NULL,                                              --supplier_tax_invoice_number *CC*
    NULL,                                              --supplier_tax_invoice_date *CC*
    NULL,                                              --supplier_exchange_rate *CC*
    NULL,                                              --tax_invoice_date *CC*
    NULL,                                              --tax_invoice_number *CC*
    NULL,                                              --tax_event_class_code
    IGC_ETAX_UTIL_PKG.IGC_TAX_EVENT_TYPE_CODE,         --tax_event_type_code
    NULL,                                              --doc_event_status
    NULL,                                              --rdng_ship_to_pty_tx_prof_id
    NULL,                                              --rdng_ship_from_pty_tx_prof_id
    NULL,                                              --rdng_bill_to_pty_tx_prof_id
    NULL,                                              --rdng_bill_from_pty_tx_prof_id
    NULL,                                              --rdng_ship_to_pty_tx_p_st_id
    NULL,                                              --rdng_ship_from_pty_tx_p_st_id
    NULL,                                              --rdng_bill_to_pty_tx_p_st_id
    NULL,                                              --rdng_bill_from_pty_tx_p_st_id
    P_CC_Header_Rec.vendor_id,         --bill_third_pty_acct_id
    P_CC_Header_Rec.vendor_site_id,        --bill_third_pty_acct_site_id
    P_CC_Header_Rec.vendor_id,                         --ship_third_pty_acct_id
    P_CC_Header_Rec.vendor_site_id,                     --ship_third_pty_acct_site_id
    FND_GLOBAL.session_id                          --icx_session_id
       );

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'zx_trx_headers_gt values ');
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Application_id: '|| IGC_ETAX_UTIL_PKG.IGC_APPLICATION_ID);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Entity_code: ' || IGC_ETAX_UTIL_PKG.IGC_ENTITY_CODE);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Event_class_code: ' || IGC_ETAX_UTIL_PKG.IGC_EVENT_CLASS_CODE);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Event_type_code: ' || IGC_ETAX_UTIL_PKG.IGC_EVENT_TYPE_CODE);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'CC Header Id: '|| P_CC_Header_Rec.cc_header_id);
      END IF;
      l_return_status := FND_API.G_RET_STS_SUCCESS;
  l_debug_info := 'Populating zx header table after insert before retunr';
  RETURN l_return_status;
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGC','IGC_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_CC_Header_Rec = '||P_CC_Header_Rec.cc_header_id||
          ' P_Calling_Mode ='||P_Calling_Mode||
          ' P_Legal_Entity_Id = '||P_Legal_Entity_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Populate_Headers_GT;

  /* Bug 6719456 - Added new parameter P_Line_Id */
  FUNCTION Populate_Lines_GT(
             P_CC_Header_Rec           IN igc_cc_headers%ROWTYPE,
             P_Line_Id                  IN  igc_cc_acct_lines.cc_acct_line_id%type,
             P_Calling_Mode            IN VARCHAR2,
             --P_Event_Class_Code        IN VARCHAR2,
             --P_Line_Number             IN NUMBER DEFAULT NULL,
             P_Error_Code              OUT NOCOPY VARCHAR2,
             P_Calling_Sequence        IN VARCHAR2,
       P_Amount          IN NUMBER) RETURN VARCHAR2 IS


  TYPE Trans_Lines_Tab_Type IS TABLE OF zx_transaction_lines_gt%ROWTYPE;
  TYPE CC_Lines_Tab_Type IS TABLE OF igc_cc_acct_lines%ROWTYPE;
  l_trans_lines                  Trans_Lines_Tab_Type := Trans_Lines_Tab_Type();
  l_cc_line_list                 CC_Lines_Tab_Type := CC_Lines_Tab_Type();
  l_return_status             VARCHAR2(32) := FND_API.G_RET_STS_SUCCESS;
  l_api_name                  VARCHAR2(30) := 'Populate_Lines_GT';
  l_calling_sequence          VARCHAR2(240) := P_Calling_Sequence;
  l_debug_info                VARCHAR2(240);

  /* Bug 6719456 - changed cursor parameter and where clause from cc_header_id to P_Line_Id */

  CURSOR CC_Acct_Lines (c_line_id NUMBER) IS
  SELECT *
  FROM igc_cc_acct_lines
  WHERE cc_acct_line_id = c_line_id;

  BEGIN
    l_calling_sequence := 'IGC_ETAX_UTIL_PKG.Populate_Lines_GT';
    IF (l_cc_line_list.COUNT <> 0) THEN
      l_cc_line_list.DELETE;
    ELSE
      OPEN CC_Acct_Lines (P_Line_Id);
      FETCH CC_Acct_Lines
      BULK COLLECT INTO l_cc_line_list;
      CLOSE CC_Acct_Lines;
    END IF;

    /* Bug 6719456 - Deleting all records instead of just passed line*/
     DELETE FROM zx_transaction_lines_gt
     WHERE application_id   = IGC_ETAX_UTIL_PKG.IGC_APPLICATION_ID
     AND entity_code      = IGC_ETAX_UTIL_PKG.IGC_ENTITY_CODE
     AND event_class_code = IGC_ETAX_UTIL_PKG.IGC_EVENT_CLASS_CODE
     AND trx_id           = P_CC_Header_Rec.cc_header_id
     AND TRX_LEVEL_TYPE   = IGC_ETAX_UTIL_PKG.IGC_TRX_LEVEL_TYPE ;

    /* --*CC* Set l_debug variable across for debug information */
    IF ( l_cc_line_list.COUNT > 0) THEN
      l_trans_lines.EXTEND(l_cc_line_list.COUNT);
      FOR i IN l_cc_line_list.FIRST .. l_cc_line_list.LAST LOOP
        l_trans_lines(i).application_id   := IGC_ETAX_UTIL_PKG.IGC_APPLICATION_ID;
        l_trans_lines(i).entity_code        := IGC_ETAX_UTIL_PKG.IGC_ENTITY_CODE;
        l_trans_lines(i).event_class_code := IGC_ETAX_UTIL_PKG.IGC_EVENT_CLASS_CODE;
        l_trans_lines(i).trx_id            := P_CC_Header_Rec.cc_header_id;
        l_trans_lines(i).trx_line_id       := l_cc_line_list(i).cc_acct_line_id;
        l_trans_lines(i).line_amt          := NVL(P_Amount,0);
        l_trans_lines(i).trx_level_type     := IGC_ETAX_UTIL_PKG.IGC_TRX_LEVEL_TYPE;
        l_trans_lines(i).line_level_action := IGC_ETAX_UTIL_PKG.IGC_LINE_LEVEL_ACTION;
        l_trans_lines(i).line_class         := IGC_ETAX_UTIL_PKG.IGC_LINE_CLASS;
        l_trans_lines(i).line_amt_includes_tax_flag   := 'S';
        l_trans_lines(i).trx_line_date      := P_CC_Header_Rec.cc_acct_date;
        l_trans_lines(i).ship_from_location_id    := P_CC_Header_Rec.location_id;
        l_trans_lines(i).ship_to_location_id    := P_CC_Header_Rec.location_id;
        l_trans_lines(i).input_tax_classification_code  := l_cc_line_list(i).tax_classif_code;
        l_trans_lines(i).bill_to_location_id    := g_org_loc_id; -- Bug#6647075
        /* Will add based on requirement
        trans_lines(i).trx_receipt_date     := l_trx_receipt_date;
        trans_lines(i).trx_line_type      := l_inv_line_list(i).line_type_lookup_code;
        trans_lines(i).trx_line_number    := l_inv_line_list(i).line_number;
        trans_lines(i).trx_line_description     := l_inv_line_list(i).description;
        trans_lines(i).trx_line_gl_date     := l_inv_line_list(i).accounting_date;
        trans_lines(i).account_ccid       := l_inv_line_list(i).default_dist_ccid;

        trans_lines(i).trx_line_quantity    := nvl(l_inv_line_list(i).quantity_invoiced, 1);
        trans_lines(i).unit_price       := nvl(l_inv_line_list(i).unit_price, trans_lines(i).line_amt);
        trans_lines(i).uom_code     := l_uom_code;

        trans_lines(i).trx_business_category    := l_inv_line_list(i).trx_business_category;
        trans_lines(i).line_intended_use    := nvl(l_inv_line_list(i).primary_intended_use,l_intended_use);
        trans_lines(i).user_defined_fisc_class  := nvl(l_inv_line_list(i).user_defined_fisc_class,l_user_defined_fisc_class);
        trans_lines(i).product_fisc_classification  := nvl(l_inv_line_list(i).product_fisc_classification,l_product_fisc_class);
        trans_lines(i).assessable_value     := nvl(l_inv_line_list(i).assessable_value,l_assessable_value);
        trans_lines(i).input_tax_classification_code  := nvl(l_inv_line_list(i).tax_classification_code,l_dflt_tax_class_code);

        trans_lines(i).product_id       := l_inv_line_list(i).inventory_item_id;
        trans_lines(i).product_org_id     := l_product_org_id;
        trans_lines(i).product_category   := nvl(l_inv_line_list(i).product_category,l_product_category);
        trans_lines(i).product_type     := nvl(l_inv_line_list(i).product_type,l_product_type);
        trans_lines(i).product_description    := l_inv_line_list(i).item_description;
        trans_lines(i).fob_point      := l_fob_point;

        trans_lines(i).ship_to_party_id   := l_inv_line_list(i).org_id;
        trans_lines(i).ship_from_party_id   := P_Invoice_Header_Rec.party_id;

        trans_lines(i).bill_to_party_id   := l_inv_line_list(i).org_id;
        trans_lines(i).bill_from_party_id   := P_Invoice_Header_Rec.party_id;

        trans_lines(i).ship_from_party_site_id  := P_Invoice_Header_Rec.party_site_id;
        trans_lines(i).bill_from_party_site_id  := P_Invoice_Header_Rec.party_site_id;

        trans_lines(i).ship_to_location_id    := l_inv_line_list(i).ship_to_location_id;
        trans_lines(i).ship_from_location_id    := l_location_id;

        trans_lines(i).bill_from_location_id          := l_location_id;

        trans_lines(i).ref_doc_application_id   := l_ref_doc_application_id;
        trans_lines(i).ref_doc_entity_code    := l_ref_doc_entity_code;
        trans_lines(i).ref_doc_event_class_code   := l_ref_doc_event_class_code;
        trans_lines(i).ref_doc_trx_id     := l_ref_doc_trx_id;
        trans_lines(i).ref_doc_trx_level_type   := l_ref_doc_trx_level_type;
        trans_lines(i).ref_doc_line_id    := l_inv_line_list(i).po_line_location_id;
        trans_lines(i).ref_doc_line_quantity    := l_ref_doc_line_quantity;

        trans_lines(i).applied_from_application_id  := l_prepay_doc_application_id;
        trans_lines(i).applied_from_entity_code   := l_prepay_doc_entity_code;
        trans_lines(i).applied_from_event_class_code  := l_prepay_doc_event_class_code;
        trans_lines(i).applied_from_trx_id    := l_applied_from_trx_id;
        trans_lines(i).applied_from_trx_level_type  := l_applied_from_trx_level_type;
        trans_lines(i).applied_from_line_id     := l_applied_from_line_id;

        trans_lines(i).adjusted_doc_application_id  := l_adj_doc_application_id;
        trans_lines(i).adjusted_doc_entity_code   := l_adj_doc_entity_code;
        trans_lines(i).adjusted_doc_event_class_code  := l_adj_doc_event_class_code;
        trans_lines(i).adjusted_doc_trx_id    := l_inv_line_list(i).corrected_inv_id;
        trans_lines(i).adjusted_doc_line_id     := l_inv_line_list(i).corrected_line_number;
        trans_lines(i).adjusted_doc_trx_level_type  := l_adj_doc_trx_level_type;
        trans_lines(i).adjusted_doc_number    := l_adj_doc_number;
        trans_lines(i).adjusted_doc_date    := l_adj_doc_date;

        trans_lines(i).applied_to_application_id  := l_applied_to_application_id;
        trans_lines(i).applied_to_entity_code   := l_applied_to_entity_code;
        trans_lines(i).applied_to_event_class_code  := l_applied_to_event_class_code;
        trans_lines(i).applied_to_trx_id    := l_inv_line_list(i).rcv_transaction_id;
        trans_lines(i).applied_to_trx_line_id :=NULL;
        trans_lines(i).source_application_id    := l_inv_line_list(i).source_application_id;
        trans_lines(i).source_entity_code   := l_inv_line_list(i).source_entity_code;
        trans_lines(i).source_event_class_code  := l_inv_line_list(i).source_event_class_code;
        trans_lines(i).source_trx_id      := l_inv_line_list(i).source_trx_id;
        trans_lines(i).source_line_id     := l_inv_line_list(i).source_line_id;
        trans_lines(i).source_trx_level_type    := l_inv_line_list(i).source_trx_level_type;
        trans_lines(i).merchant_party_name    := l_inv_line_list(i).merchant_name;
        trans_lines(i).merchant_party_document_number := l_inv_line_list(i).merchant_document_number;
        trans_lines(i).merchant_party_reference   := l_inv_line_list(i).merchant_reference;
        trans_lines(i).merchant_party_taxpayer_id   := l_inv_line_list(i).merchant_taxpayer_id;
        trans_lines(i).merchant_party_tax_reg_number  := l_inv_line_list(i).merchant_tax_reg_number;
        trans_lines(i).merchant_party_country   := l_inv_line_list(i).country_of_supply;

        trans_lines(i).line_amt_includes_tax_flag   := l_line_amt_includes_tax_flag;
        trans_lines(i).historical_flag    := NVL(P_Invoice_Header_Rec.historical_flag, 'N');
        trans_lines(i).ctrl_hdr_tx_appl_flag    := l_ctrl_hdr_tx_appl_flag;
        trans_lines(i).ctrl_total_line_tx_amt   := l_inv_line_list(i).control_amount;

        */
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'zx_transaction_lines_gt values ');
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'event_class_code: ' || l_trans_lines(i).event_class_code);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'trx_id: '           || l_trans_lines(i).trx_id);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'trx_line_id: '      || l_trans_lines(i).trx_line_id);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'trx_level_type: '   || l_trans_lines(i).trx_level_type);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'trx_line_type: '    || l_trans_lines(i).trx_line_type );
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'line_level_action: '|| l_trans_lines(i).line_level_action);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'line_class: '       || l_trans_lines(i).line_class);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'line_amt: '         || l_trans_lines(i).line_amt);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'unit_price: '       || l_trans_lines(i).unit_price);
        END IF;

      END LOOP;
    END IF;
    -------------------------------------------------------------------
    l_debug_info := 'Bulk Insert into global temp table';
    -------------------------------------------------------------------
                FORALL i IN l_trans_lines.FIRST .. l_trans_lines.LAST
      INSERT INTO zx_transaction_lines_gt
      VALUES l_trans_lines(i);
    RETURN l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGC','IGC_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_CC_Header_Rec = '||P_CC_Header_Rec.cc_header_id||
          ' P_Calling_Mode ='||P_Calling_Mode||
          ' P_Error_Code = '||P_Error_Code||
    ' P_Amount = '||P_Amount||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    APP_EXCEPTION.RAISE_EXCEPTION;

  END Populate_Lines_GT;


  /* New function created for Bug#6719456 */
  FUNCTION Populate_Dist_GT(
               P_CC_Header_Rec           IN igc_cc_headers%ROWTYPE,
               P_Line_Id                 IN  igc_cc_acct_lines.cc_acct_line_id%type,
               P_Calling_Mode            IN VARCHAR2,
               P_Error_Code              OUT NOCOPY VARCHAR2,
               P_Calling_Sequence        IN VARCHAR2,
               P_Amount                  IN NUMBER) RETURN VARCHAR2 IS

    CURSOR c_Acct_Lines (p_acct_line_id IN NUMBER) IS
    SELECT *
    FROM igc_cc_acct_lines
    WHERE cc_acct_line_id = p_acct_line_id;

    l_api_name                  VARCHAR2(30) := 'Populate_dest_GT';
    l_calling_sequence          VARCHAR2(240) := P_Calling_Sequence;
    l_full_path VARCHAR2(500) := G_MODULE_NAME||'Populate_Dist_GT';
    l_return_status             VARCHAR2(32) := FND_API.G_RET_STS_SUCCESS;
    l_debug_info                VARCHAR2(240);
  BEGIN

    /* First Delete from zx_itm_distributions_gt table */
    l_calling_sequence := 'IGC_ETAX_UTIL_PKG.Populate_Dist_GT';
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,p_debug_msg => 'Deleting records from zx_itm_distributions_gt table');
    END IF;

    DELETE FROM zx_itm_distributions_gt
    WHERE application_id   = IGC_ETAX_UTIL_PKG.IGC_APPLICATION_ID
    AND entity_code      = IGC_ETAX_UTIL_PKG.IGC_ENTITY_CODE
    AND event_class_code = IGC_ETAX_UTIL_PKG.IGC_EVENT_CLASS_CODE
    AND trx_id           = P_CC_Header_Rec.cc_header_id
    AND TRX_LEVEL_TYPE   = IGC_ETAX_UTIL_PKG.IGC_TRX_LEVEL_TYPE ;

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,p_debug_msg => 'Deletion from zx_itm_distributions_gt complete');
      Put_Debug_Msg (l_full_path,p_debug_msg => 'Calling insert into zx_itm_distributions_gt');
    END IF;

    FOR l_cc_lines IN c_Acct_Lines (P_Line_Id)
    LOOP
      INSERT INTO zx_itm_distributions_gt(
       application_id
      ,entity_code
      ,event_class_code
      ,trx_id
      ,trx_line_id
      ,trx_level_type
      ,trx_line_dist_id
      ,dist_level_action
      ,trx_line_dist_date
      ,item_dist_number
      ,task_id
      ,award_id
      ,project_id
      ,expenditure_type
      ,expenditure_organization_id
      ,expenditure_item_date
      ,trx_line_dist_amt
      ,trx_line_dist_qty
      ,trx_line_quantity
      ,account_ccid
      ,currency_exchange_rate
      ,overriding_recovery_rate
      )
      Values
      (
       IGC_ETAX_UTIL_PKG.IGC_APPLICATION_ID  --application_id
      ,IGC_ETAX_UTIL_PKG.IGC_ENTITY_CODE  --entity_code
      ,IGC_ETAX_UTIL_PKG.IGC_EVENT_CLASS_CODE --event_class_code
      ,P_CC_Header_Rec.cc_header_id --trx_id
      ,l_cc_lines.cc_acct_line_id --trx_line_id
      ,IGC_ETAX_UTIL_PKG.IGC_TRX_LEVEL_TYPE --trx_level_type
      ,1 --trx_line_dist_id /* We cal always insert trx_line_dist_id as 1. Only one distribution is required for each call */
      ,'CREATE' --dist_level_action
      ,sysdate --trx_line_dist_date
      ,l_cc_lines.cc_acct_line_num --item_dist_number
      ,null --task_id
      ,null --award_id
      ,l_cc_lines.project_id
      ,null --expenditure_type
      ,null --expenditure_organization_id
      ,null --expenditure_item_date
      ,nvl(p_amount,0) --trx_line_dist_amt
      ,1 --trx_line_dist_qty
      ,1 --trx_line_quantity
      ,l_cc_lines.cc_charge_code_combination_id --account_ccid
      ,null --currency_exchange_rate
      ,null --overriding_recovery_rate
      );
    END LOOP;

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,p_debug_msg => 'Insert into zx_itm_distributions_gt complete');
    END IF;
    RETURN l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGC','IGC_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_CC_Header_Rec = '||P_CC_Header_Rec.cc_header_id||
          ' P_Calling_Mode ='||P_Calling_Mode||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Amount = '||P_Amount||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    APP_EXCEPTION.RAISE_EXCEPTION;

  END Populate_Dist_GT;

Procedure Calculate_Tax(
    P_CC_Header_Rec             IN igc_cc_headers%ROWTYPE,
    P_Calling_Mode              IN VARCHAR2,
    P_Error_Code        OUT NOCOPY VARCHAR2,
    P_Amount        IN NUMBER,
    P_Tax_Amount        OUT NOCOPY NUMBER,
    P_Line_Id       IN  igc_cc_acct_lines.cc_acct_line_id%type,
    P_Return_Status       OUT NOCOPY  VARCHAR2) IS


  l_debug_info      VARCHAR2(240);
  l_calling_sequence    VARCHAR2(240);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(10);
  --l_tax_amount      ZX_REC_NREC_DIST_GT.rec_nrec_tax_amt%type;
  l_tax_amount      ZX_DETAIL_TAX_LINES_GT.tax_amt%type;
  l_taxable_amount    ZX_DETAIL_TAX_LINES_GT.taxable_amt%type;
  l_amount_includes_tax_flag  ZX_DETAIL_TAX_LINES_GT.tax_amt_included_flag%type;
  l_tax_value     NUMBER := 0;
  l_return_status     VARCHAR2(32):=FND_API.G_RET_STS_SUCCESS;
  l_effective_date    date;
  l_legal_entity_id   varchar2(32);
  l_full_path VARCHAR2(500) := G_MODULE_NAME||'Calculate_Tax';

  CURSOR get_legal_entity(p_org_id P_CC_Header_Rec.org_id%type)
  is
    select hrop.default_legal_context_id from
    hr_operating_units hrop
    where hrop.organization_id=p_org_id;

  BEGIN

  l_calling_sequence := 'IGC.IGC_ETAX_UTIL_PKG.Calculate_Tax';

  --fetch legal entity
  l_debug_info := 'Fetching legal entity';
  open get_legal_entity(P_CC_Header_Rec.ORG_ID);
  fetch get_legal_entity into l_legal_entity_id;
  close get_legal_entity;

  if l_legal_entity_id is null then
                l_debug_info := 'Legal entity is null';
                p_tax_amount := 0;
                P_Return_Status:=FND_API.G_RET_STS_SUCCESS;
    Return;
    /* Modified for Bug 6609963, legal entity is mandatory to calculate tax, setting the tax amt to zero if legal entity data is not found,
    so that the funds checking completes successfully. Thus maintaining the 11i functionality */
  end if;

  --set security context
  l_debug_info := 'Calling set_tax_security_context';
  set_tax_security_context
                                (p_org_id               =>P_CC_Header_Rec.org_id,
                                 P_Legal_Entity_Id      =>l_legal_entity_id,
                                 p_transaction_date     =>P_CC_Header_Rec.cc_acct_date,
                                 p_related_doc_date     =>NULL,
                                 p_adjusted_doc_date    =>NULL,
                                 p_effective_date       =>l_effective_date,
                                 p_return_status        =>l_return_status,
                                 p_msg_count            =>l_msg_count,
                                 p_msg_data             =>l_msg_data);

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
              P_Return_Status:=FND_API.G_RET_STS_UNEXP_ERROR;
              return;
  end if;
  -- Set G_ORG_LOC_ID if vendor, vendor_site and location is null
  IF P_CC_Header_Rec.vendor_id IS NULL AND P_CC_Header_Rec.vendor_site_id IS NULL
      AND P_CC_Header_Rec.location_id IS NULL THEN
    BEGIN
      SELECT  location_id
      INTO    G_ORG_LOC_ID
      FROM    HR_ALL_ORGANIZATION_UNITS
      WHERE   organization_id = p_cc_header_rec.org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

  END IF;

  -- Populate GT Headers
  l_debug_info := 'Calling Populate_Headers_GT API';
  l_return_status := Populate_Headers_GT
            (P_CC_Header_Rec=>P_CC_Header_Rec,
            P_Calling_Mode=>null,
                                          P_Legal_Entity_Id=>l_legal_entity_id,
                                          P_Error_Code=>P_Error_Code);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    P_Return_Status :=FND_API.G_RET_STS_UNEXP_ERROR;
                RETURN;
        END IF;

  -- Populate GT Lines
        l_debug_info := 'Calling Populate_lines_GT API';
        l_return_status := Populate_Lines_GT
                                        (P_CC_Header_Rec=>P_CC_Header_Rec,
                                        P_Line_Id => P_Line_Id,
                                        P_Calling_Mode=>null,
                                        P_Amount=>P_Amount,
                                        P_Error_Code=>P_Error_Code,
                                        P_Calling_Sequence=>l_calling_sequence);
        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                 P_Return_Status :=FND_API.G_RET_STS_UNEXP_ERROR;
                RETURN;
        END IF;

        -- Calling ZX Calculate Tax API
        l_debug_info := 'Calling ZX Calculate Tax API';

        ZX_API_PUB.calculate_tax(
                                p_api_version           =>  1.0,
                                p_init_msg_list         =>  FND_API.G_FALSE,
                                p_commit                =>  FND_API.G_FALSE,
                                p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
                                x_return_status         =>  l_return_status,
                                x_msg_count             =>  l_msg_count,
                                x_msg_data              =>  l_msg_data);

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                P_Return_Status :=FND_API.G_RET_STS_UNEXP_ERROR;
                Return;
        end if;

        /* Bug#6719456 start */

        /* Update zx_trx_headers_gt to set event code to "DISTRIBUTED" */
        UPDATE zx_trx_headers_gt
        set    event_type_code = 'DISTRIBUTED'
        WHERE application_id   = IGC_ETAX_UTIL_PKG.IGC_APPLICATION_ID
        AND entity_code      = IGC_ETAX_UTIL_PKG.IGC_ENTITY_CODE
        AND event_class_code = IGC_ETAX_UTIL_PKG.IGC_EVENT_CLASS_CODE
        AND trx_id           = P_CC_Header_Rec.cc_header_id;

        l_debug_info := 'Populate Distribution table Tax API';
        l_return_status := Populate_dist_GT
                                        (P_CC_Header_Rec=>P_CC_Header_Rec,
                                        P_Line_Id => P_Line_Id,
                                        P_Calling_Mode=>null,
                                        P_Amount=>P_Amount,
                                        P_Error_Code=>P_Error_Code,
                                        P_Calling_Sequence=>l_calling_sequence);

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                P_Return_Status :=FND_API.G_RET_STS_UNEXP_ERROR;
                Return;
        end if;


        l_debug_info := 'Calling ZX determine_recovery API';

        ZX_API_PUB.determine_recovery(
        p_api_version           =>  1.0,
        p_init_msg_list         =>  FND_API.G_TRUE,
        p_commit                =>  FND_API.G_FALSE,
        p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status         =>  l_return_status,
        x_msg_count             =>  l_msg_count,
        x_msg_data              =>  l_msg_data
        );

        IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg (l_full_path,p_debug_msg => 'After running  : determine_recovery : status : '||l_return_status);
          Put_Debug_Msg (l_full_path,p_debug_msg => 'After running  : determine_recovery'||l_msg_data);
        END IF;

        --fetch tax detail from zx table
        l_debug_info := 'Fetching data from ZX table';

        l_tax_amount := 0;

/*
        FOR l_zx_rec_nrec_dist_gt in C_ZX_REC_NREC_DIST_GT(P_CC_Header_Rec.cc_header_id, P_Line_Id)
        LOOP
          IF (g_debug_mode = 'Y') THEN
             Put_Debug_Msg (l_full_path,p_debug_msg => 'Value of C_ZX_REC_NREC_DIST_GT.recoverable_flag : '||l_zx_rec_nrec_dist_gt.recoverable_flag);
             Put_Debug_Msg (l_full_path,p_debug_msg => 'Value of C_ZX_REC_NREC_DIST_GT.rec_nrec_tax_amt : '||l_zx_rec_nrec_dist_gt.rec_nrec_tax_amt);
             Put_Debug_Msg (l_full_path,p_debug_msg => 'Value of C_ZX_REC_NREC_DIST_GT.REC_NREC_RATE : '||l_zx_rec_nrec_dist_gt.REC_NREC_RATE);
             Put_Debug_Msg (l_full_path,p_debug_msg => 'Value of C_ZX_REC_NREC_DIST_GT.TAX_ID :'||l_zx_rec_nrec_dist_gt.TAX_ID);
             Put_Debug_Msg (l_full_path,p_debug_msg => 'Value of C_ZX_REC_NREC_DIST_GT.TRX_CURRENCY_CODE : '||l_zx_rec_nrec_dist_gt.TRX_CURRENCY_CODE);
             Put_Debug_Msg (l_full_path,p_debug_msg => 'Value of C_ZX_REC_NREC_DIST_GT.TAX_CURRENCY_CODE : '||l_zx_rec_nrec_dist_gt.TAX_CURRENCY_CODE);
             Put_Debug_Msg (l_full_path,p_debug_msg => 'Value of C_ZX_REC_NREC_DIST_GT.TAX_CURRENCY_CONVERSION_RATE  : '||l_zx_rec_nrec_dist_gt.TAX_CURRENCY_CONVERSION_RATE );
          END IF;
        END LOOP;
*/
        SELECT nvl(SUM(rec_nrec_tax_amt),0)
        INTO  l_tax_amount
        FROM  ZX_REC_NREC_DIST_GT
        WHERE application_id = IGC_ETAX_UTIL_PKG.IGC_APPLICATION_ID            --'8407'
        AND   entity_code =IGC_ETAX_UTIL_PKG.IGC_ENTITY_CODE               --'IGC_CC_HEADERS'
        AND   event_class_code =IGC_ETAX_UTIL_PKG.IGC_EVENT_CLASS_CODE     --'PURCHASE_TRANSACTION_TAX_QUOTE'
        AND   trx_id =  P_CC_Header_Rec.cc_header_id
        AND   trx_line_id = p_line_id
        AND   trx_level_type = IGC_ETAX_UTIL_PKG.IGC_TRX_LEVEL_TYPE   --'LINE'
        AND   recoverable_flag = 'N';

        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'Calculated Tax amount : '||l_tax_amount);
        END IF;
        p_tax_amount := l_tax_amount;
        P_Return_Status:=FND_API.G_RET_STS_SUCCESS;

        /* Bug#6719456 End */

   EXCEPTION
    WHEN OTHERS THEN
      --IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('IGC','IGC_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                ' P_CC_Header_Rec = '||P_CC_Header_Rec.cc_header_id||
                ' P_Calling_Mode ='||P_Calling_Mode||
                  ' P_Amount ='||P_Amount||
                ' P_Line_Id ='||P_Line_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      --END IF;
      P_Error_Code := SQLERRM;
                        P_Return_Status :=FND_API.G_RET_STS_UNEXP_ERROR;
      APP_EXCEPTION.RAISE_EXCEPTION;

END Calculate_Tax;

PROCEDURE get_cc_def_tax_classification(
             p_cc_header_id                 IN  zx_lines_det_factors.ref_doc_trx_id%TYPE,
             p_cc_line_id                   IN  zx_lines_det_factors.ref_doc_line_id%TYPE,
             p_cc_trx_level_type            IN  zx_lines_det_factors.ref_doc_trx_level_type%TYPE,
             p_vendor_id                    IN  po_vendors.vendor_id%TYPE,
             p_vendor_site_id               IN  po_vendor_sites.vendor_site_id%TYPE,
             p_code_combination_id          IN  gl_code_combinations.code_combination_id%TYPE,
             p_concatenated_segments        IN  varchar2,
             p_templ_tax_classification_cd  IN  varchar2,
             p_tax_classification_code      IN  OUT NOCOPY varchar2,
             p_allow_tax_code_override_flag     OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
             p_tax_user_override_flag   IN  VARCHAR2,
             p_user_tax_name            IN  VARCHAR2,
             p_legal_entity_id              IN  zx_lines.legal_entity_id%TYPE,
             p_calling_sequence             IN  VARCHAR2,
             p_internal_organization_id     IN  NUMBER) IS


    l_api_name                  VARCHAR2(64) := 'get_cc_default_tax_classification';
    l_calling_sequence          VARCHAR2(240) := P_Calling_Sequence;
    l_debug_info                VARCHAR2(240);

  BEGIN

     ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification(
               p_ref_doc_application_id       =>  IGC_ETAX_UTIL_PKG.IGC_APPLICATION_ID,
               p_ref_doc_entity_code          =>  IGC_ETAX_UTIL_PKG.IGC_ENTITY_CODE,
               p_ref_doc_event_class_code     =>  IGC_ETAX_UTIL_PKG.IGC_EVENT_CLASS_CODE,
               p_ref_doc_trx_id               =>  p_cc_header_id,
               p_ref_doc_line_id              =>  p_cc_line_id,
               p_ref_doc_trx_level_type       =>  IGC_ETAX_UTIL_PKG.IGC_TRX_LEVEL_TYPE,
               p_vendor_id                    =>  p_vendor_id,
               p_vendor_site_id               =>  p_vendor_site_id,
               p_code_combination_id          =>  p_code_combination_id,
               p_concatenated_segments        =>  p_concatenated_segments,
               p_templ_tax_classification_cd  =>  p_templ_tax_classification_cd,
               p_ship_to_location_id          =>  NULL,
               p_ship_to_loc_org_id           =>  NULL,
               p_inventory_item_id            =>  NULL,
               p_item_org_id                  =>  NULL,
               p_tax_classification_code      =>  p_tax_classification_code,
               p_allow_tax_code_override_flag =>  p_allow_tax_code_override_flag,
               p_tax_user_override_flag       =>  p_tax_user_override_flag,
               p_user_tax_name                =>  p_user_tax_name,
               p_legal_entity_id              =>  p_legal_entity_id,
               APPL_SHORT_NAME                => 'IGC',
               FUNC_SHORT_NAME                => 'NONE',
               p_calling_sequence             =>  p_calling_sequence,
               p_event_class_code             =>  IGC_ETAX_UTIL_PKG.IGC_EVENT_CLASS_CODE,
               p_entity_code                  =>  IGC_ETAX_UTIL_PKG.IGC_ENTITY_CODE,
               p_application_id               =>  IGC_ETAX_UTIL_PKG.IGC_APPLICATION_ID,
               p_internal_organization_id     =>  p_internal_organization_id);


  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGC','IGC_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_CC_Header_Id = '||p_cc_header_id||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

      APP_EXCEPTION.RAISE_EXCEPTION;

  END get_cc_def_tax_classification;

  PROCEDURE Put_Debug_Msg (
     p_path           IN VARCHAR2,
     p_debug_msg      IN VARCHAR2,
     p_sev_level      IN VARCHAR2 := G_LEVEL_STATEMENT
  ) IS
  BEGIN

    IF p_sev_level >= G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(p_sev_level, p_path, p_debug_msg);
    END IF;
  END Put_Debug_Msg;


END IGC_ETAX_UTIL_PKG;

/
