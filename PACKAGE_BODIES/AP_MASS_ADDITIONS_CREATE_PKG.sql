--------------------------------------------------------
--  DDL for Package Body AP_MASS_ADDITIONS_CREATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_MASS_ADDITIONS_CREATE_PKG" AS
/* $Header: apmassab.pls 120.22.12010000.25 2010/05/19 09:29:56 mkmeda ship $ */

-- Package global
-- FND_LOG related variables to enable logging for this package
   --
   G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_MASS_ADDITIONS_CREATE_PKG';
   G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
   G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
   G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
   G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
   G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
   G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

   G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
   G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
   G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
   G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
   G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
   G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
   G_MODULE_NAME           CONSTANT VARCHAR2(80) := 'AP.PLSQL.AP_MASS_ADDITIONS_CREATE_PKG.';

-- Procedure to poulate the Global Temp Table for Mass Addition process.
-- Will populate GT for ledger_id (including ALC)
--
PROCEDURE Populate_Mass_Ledger_Gt(
                P_ledger_id                 IN    NUMBER,
                P_calling_sequence          IN    VARCHAR2 DEFAULT NULL) IS

    l_current_calling_sequence   VARCHAR2(2000);
    l_debug_info                 VARCHAR2(240);
    l_count                      NUMBER;
    l_api_name         CONSTANT  VARCHAR2(100) := 'POPULATE_MASS_LEDGER_GT';
    --
BEGIN
    l_current_calling_sequence := P_calling_sequence||'->'||
                    'Populate_Mass_Ledger_Gt';
    --
    l_debug_info := 'Populate AP_ALC_LEDGER_GT';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    INSERT INTO AP_ALC_LEDGER_GT (
                source_ledger_id,
                ledger_id,
                ledger_category_code,
                org_id)
        SELECT  P_ledger_id,
                P_ledger_id,
                'P',
                -99
          FROM  DUAL
         UNION
        SELECT  ALC.source_ledger_id,
                ALC.ledger_id,
                'ALC',
                ALC.org_id
          FROM  gl_alc_ledger_rships_v ALC
         WHERE  ALC.application_id = 200
           AND  ALC.relationship_enabled_flag = 'Y'
           AND  ALC.source_ledger_id = P_ledger_id;
--
EXCEPTION
  WHEN OTHERS THEN
    --
    IF (SQLCODE <> -20001 ) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
    END IF;
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name, SQLERRM);
    END IF;
    --
    APP_EXCEPTION.RAISE_EXCEPTION;
    --
END Populate_Mass_Ledger_Gt;

----------------------------------------------------------------------------
-- Procedure to poulate the Global Temp Table for Mass Addition process.
-- Will populate GT for accounting class code as defined in Post-Accounting
-- Programs
--
PROCEDURE Populate_Mass_Acct_Code_Gt(
                P_ledger_id                 IN    NUMBER,
                P_calling_sequence          IN    VARCHAR2 DEFAULT NULL) IS

    l_current_calling_sequence   VARCHAR2(2000);
    l_debug_info                 VARCHAR2(240);
    l_count                      NUMBER;
    TYPE acct_class_code_tab_type IS TABLE OF
         xla_acct_class_assgns.accounting_class_code%TYPE INDEX BY BINARY_INTEGER;
    TYPE acct_class_code_rec_type IS RECORD (
        l_acct_class_code_t       acct_class_code_tab_type);
    acct_class_code_rec           acct_class_code_rec_type;

    l_api_name         CONSTANT  VARCHAR2(100) := 'POPULATE_MASS_ACCT_CODE_GT';
    --
BEGIN
    l_current_calling_sequence := P_calling_sequence||'->'||
                    'Populate_Mass_Acct_Code_Gt';
    --
    l_debug_info := 'Get Accounting Class Code from SLA';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    SELECT XACA.accounting_class_code
    BULK COLLECT
      INTO acct_class_code_rec.l_acct_class_code_t
      FROM xla_acct_class_assgns XACA,
           xla_assignment_defns_b XAD,
           xla_post_acct_progs_b XPAP
     WHERE XACA.program_code = XAD.program_code
       AND XACA.program_owner_code = XAD.program_owner_code
       AND XAD.program_code = XPAP.program_code
       AND XAD.program_owner_code = XPAP.program_owner_code
       AND XPAP.program_owner_code = 'S'
       AND XPAP.program_code = 'Mass Additions Create'
       AND XPAP.application_id = 140
       AND XACA.assignment_code = XAD.assignment_code
       AND XACA.assignment_owner_code = XAD.assignment_owner_code
       AND XAD.ledger_id = P_ledger_id
       AND XAD.enabled_flag = 'Y';
    --
    l_debug_info := 'Populate AP_ACCT_CLASS_CODE_GT';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    IF acct_class_code_rec.l_acct_class_code_t.COUNT > 0 THEN
    --
      FOR i IN 1..acct_class_code_rec.l_acct_class_code_t.LAST LOOP
      INSERT INTO AP_ACCT_CLASS_CODE_GT (
             accounting_class_code)
      VALUES(acct_class_code_rec.l_acct_class_code_t(i));
      END LOOP;
    --
    ELSE

      INSERT INTO AP_ACCT_CLASS_CODE_GT (
             accounting_class_code)
      SELECT XACA.accounting_class_code
        FROM xla_acct_class_assgns XACA,
             xla_assignment_defns_b XAD,
             xla_post_acct_progs_b XPAP
       WHERE XACA.program_code = XAD.program_code
         AND XACA.program_owner_code = XAD.program_owner_code
         AND XAD.program_code = XPAP.program_code
         AND XAD.program_owner_code = XPAP.program_owner_code
         AND XPAP.program_owner_code = 'S'
         AND XPAP.program_code = 'Mass Additions Create'
         AND XPAP.application_id = 140
         AND XACA.assignment_code = XAD.assignment_code
         AND XACA.assignment_owner_code = XAD.assignment_owner_code
         AND XAD.ledger_id IS NULL
         AND XAD.enabled_flag = 'Y';

    END IF;

EXCEPTION
  WHEN OTHERS THEN
    --
    IF (SQLCODE <> -20001 ) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
    END IF;
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name, SQLERRM);
    END IF;
    --
    APP_EXCEPTION.RAISE_EXCEPTION;
    --
END Populate_Mass_Acct_Code_Gt;

----------------------------------------------------------------------------
-- Function will return accounting method from GL_SETS_OF_BOOKS
-- based on the sla_ledger_cash_basis_flag
--
FUNCTION Derive_Acct_Method (
                P_ledger_id                 IN    NUMBER,
                P_calling_sequence          IN    VARCHAR2 DEFAULT NULL)
                                                  RETURN VARCHAR2 IS

    l_current_calling_sequence   VARCHAR2(200);
    l_debug_info                 VARCHAR2(240);
    l_acct_method                VARCHAR2(30);
    l_api_name         CONSTANT  VARCHAR2(100) := 'DERIVE_ACCT_METHOD';
    --
BEGIN

    l_current_calling_sequence := P_calling_sequence||'->'||
                    'Derive_Acct_Method';
    --
    l_debug_info := 'Get Accounting Method from Gl_Set_Of_Books';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    SELECT DECODE(NVL(sla_ledger_cash_basis_flag, 'N'), 'Y',
                  'Cash', 'Accrual')
      INTO l_acct_method
      FROM gl_sets_of_books
      WHERE set_of_books_id = p_ledger_id;

    RETURN (l_acct_method);

EXCEPTION
  WHEN OTHERS THEN
    --
    IF (SQLCODE <> -20001 ) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
    END IF;
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,SQLERRM);
    END IF;
    --
    APP_EXCEPTION.RAISE_EXCEPTION;
    --
END Derive_Acct_Method;

----------------------------------------------------------------------------
-- Procedure will Insert distributions tarcked as asset in
-- FA_MASS_ADDITIONS_GT table
--
PROCEDURE  Insert_Mass(
                P_acctg_date                IN    DATE,
                P_ledger_id                 IN    NUMBER,
                P_user_id                   IN    NUMBER,
                P_request_id                IN    NUMBER,
                P_bt_code                   IN    VARCHAR2,
                P_count                     OUT NOCOPY   NUMBER,
                P_primary_accounting_method IN    VARCHAR2,
                P_calling_sequence          IN    VARCHAR2 DEFAULT NULL) IS
    --
    l_current_calling_sequence   VARCHAR2(2000);
    l_debug_info                 VARCHAR2(2000);
    l_request_id                 NUMBER;
    l_count                      NUMBER;
    l_api_name         CONSTANT  VARCHAR2(100) := 'INSERT_MASS';
    --
BEGIN
    l_current_calling_sequence := P_calling_sequence||'->'||
                    'Insert_Mass';
    l_count := 0;

    --
    --
    IF p_primary_accounting_method = 'Accrual' THEN
      l_debug_info := 'Insert Mass if Accounting Method Is Accrual';
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      --

--This insert statement below was added for Bug 7284987 / 7392117
-- for bug 9669334 we have spilt the query. first part is for ITEM and ACCRUAL.
-- second one is for other line type lookups.
    INSERT INTO ap_invoice_distributions_gt
           (invoice_distribution_id,
            invoice_id,
            invoice_line_number,
            po_distribution_id,
            org_id,
            accounting_event_id,
            description,
            asset_category_id,
            quantity_invoiced,
            historical_flag ,
            corrected_quantity,
            dist_code_combination_id,
            line_type_lookup_code,
            distribution_line_number,
            accounting_date ,
            corrected_invoice_dist_id,
            related_id,
            charge_applicable_to_dist_id,
            asset_book_type_code,
            set_of_books_id
           )
    SELECT /*+ index(apid AP_INVOICE_DISTRIBUTIONS_N31)*/
           APID.invoice_distribution_id,
           APID.invoice_id,
           APID.invoice_line_number,
           APID.po_distribution_id,
           APID.org_id,
           APID.accounting_event_id,
           APID.description,
           APID.asset_category_id,
           APID.quantity_invoiced,
           APID.historical_flag,
           APID.corrected_quantity,
           APID.dist_code_combination_id,
           APID.line_type_lookup_code,
           APID.distribution_line_number,
           APID.accounting_date,
           APID.corrected_invoice_dist_id,
           APID.related_id,
           APID.charge_applicable_to_dist_id,
           APID.asset_book_type_code,
           APID.set_of_books_id
      FROM ap_invoice_distributions APID
     WHERE APID.accounting_date <=  P_acctg_date
       AND APID.assets_addition_flag = 'U'
       AND APID.line_type_lookup_code IN ('ITEM','ACCRUAL')
       AND  apid.assets_tracking_flag = 'Y'
       AND ( APID.project_id IS NULL
              OR (  SELECT decode(ptype.project_type_class_code,'CAPITAL','P','U')
                      FROM pa_project_types_all ptype,
                           pa_projects_all      proj
                     WHERE proj.project_type = ptype.project_type
                       AND ptype.org_id = proj.org_id
                       AND proj.project_id = APID.project_id
                  ) <> 'P'
           )
       AND APID.posted_flag = 'Y'
       AND APID.set_of_books_id = P_ledger_id
-- bug 8690407: add start
     AND (APID.asset_book_type_code = P_bt_code
     OR  APID.asset_book_type_code IS NULL)
-- bug 8690407: add end
     UNION ALL
    SELECT /*+ index(apid AP_INVOICE_DISTRIBUTIONS_N31)*/
           APID.invoice_distribution_id,
           APID.invoice_id,
           APID.invoice_line_number,
           APID.po_distribution_id,
           APID.org_id,
           APID.accounting_event_id,
           APID.description,
           APID.asset_category_id,
           APID.quantity_invoiced,
           APID.historical_flag,
           APID.corrected_quantity,
           APID.dist_code_combination_id,
           APID.line_type_lookup_code,
           APID.distribution_line_number,
           APID.accounting_date,
           APID.corrected_invoice_dist_id,
           APID.related_id,
           APID.charge_applicable_to_dist_id,
           nvl(APID.asset_book_type_code,item.asset_book_type_code),
           APID.set_of_books_id
      FROM ap_invoice_distributions APID,
           ap_invoice_distributions_all item
     WHERE APID.accounting_date <=  P_acctg_date
       AND APID.assets_addition_flag = 'U'
       AND APID.line_type_lookup_code NOT IN ('ITEM','ACCRUAL')
       AND item.assets_tracking_flag = 'Y'
       AND item.assets_addition_flag IN ('Y', 'U')
       AND nvl(nvl(apid.charge_applicable_to_dist_id, apid.related_id),
               apid.corrected_invoice_dist_id) IS NOT NULL
       AND nvl(nvl(apid.charge_applicable_to_dist_id, apid.related_id),
               apid.corrected_invoice_dist_id) =
                       item.invoice_distribution_id
       AND ( APID.project_id IS NULL
                 OR (  SELECT decode(ptype.project_type_class_code,'CAPITAL','P','U')
                         FROM pa_project_types_all ptype,
                              pa_projects_all      proj
                        WHERE proj.project_type = ptype.project_type
                          AND ptype.org_id = proj.org_id
                          AND proj.project_id = APID.project_id
                     ) <> 'P'
            )
       AND APID.posted_flag = 'Y'
       AND APID.set_of_books_id = P_ledger_id
-- bug 8690407: add start
     AND (APID.asset_book_type_code = P_bt_code
     OR  APID.asset_book_type_code IS NULL)
-- bug 8690407: add end
-- bug 7215835: add start
     UNION ALL
    SELECT satx.invoice_distribution_id,
           satx.invoice_id,
           satx.invoice_line_number,
           satx.po_distribution_id,
           satx.org_id,
           satx.accounting_event_id,
           satx.description,
           satx.asset_category_id,
           satx.quantity_invoiced,
           'N',  -- no historical flag in self assessed table
           satx.corrected_quantity,
           satx.dist_code_combination_id,
           satx.line_type_lookup_code,
           satx.distribution_line_number,
           satx.accounting_date,
           satx.corrected_invoice_dist_id,
           satx.related_id,
           satx.charge_applicable_to_dist_id,
           nvl(satx.asset_book_type_code, item.asset_book_type_code),
           satx.set_of_books_id
      FROM ap_invoice_distributions_all item,
           ap_self_assessed_tax_dist satx
     WHERE satx.accounting_date <=  P_acctg_date
       AND satx.assets_addition_flag = 'U'
       AND item.assets_tracking_flag = 'Y'
       AND item.assets_addition_flag IN ('Y', 'U')
       AND satx.charge_applicable_to_dist_id IS NOT NULL
       AND satx.charge_applicable_to_dist_id = item.invoice_distribution_id
       AND ( satx.project_id IS NULL
             OR ( SELECT decode(ptype.project_type_class_code,'CAPITAL','P','U')
                    FROM pa_project_types_all ptype,
                         pa_projects_all      proj
                   WHERE proj.project_type = ptype.project_type
                     AND ptype.org_id = proj.org_id
                     AND proj.project_id   = satx.project_id
                ) <> 'P' )
       AND satx.posted_flag = 'Y'
       AND satx.set_of_books_id = P_ledger_id
       AND (satx.asset_book_type_code = P_bt_code OR
            satx.asset_book_type_code IS NULL);

      INSERT INTO FA_MASS_ADDITIONS_GT(
                    mass_addition_id,
                    asset_number,
                    tag_number,
                    description,
                    asset_category_id,
                    inventorial,
                    manufacturer_name,
                    serial_number,
                    model_number,
                    book_type_code,
                    date_placed_in_service,
                    transaction_type_code,
                    transaction_date,
                    fixed_assets_cost,
                    payables_units,
                    fixed_assets_units,
                    payables_code_combination_id,
                    expense_code_combination_id,
                    location_id,
                    assigned_to,
                    feeder_system_name,
                    create_batch_date,
                    create_batch_id,
                    last_update_date,
                    last_updated_by,
                    reviewer_comments,
                    invoice_number,
                    vendor_number,
                    po_vendor_id,
                    po_number,
                    posting_status,
                    queue_name,
                    invoice_date,
                    invoice_created_by,
                    invoice_updated_by,
                    payables_cost,
                    invoice_id,
                    payables_batch_name,
                    depreciate_flag,
                    parent_mass_addition_id,
                    parent_asset_id,
                    split_merged_code,
                    ap_distribution_line_number,
                    post_batch_id,
                    add_to_asset_id,
                    amortize_flag,
                    new_master_flag,
                    asset_key_ccid,
                    asset_type,
                    deprn_reserve,
                    ytd_deprn,
                    beginning_nbv,
                    accounting_date,
                    created_by,
                    creation_date,
                    last_update_login,
                    salvage_value,
                    merge_invoice_number,
                    merge_vendor_number,
                    invoice_distribution_id,
                    invoice_line_number,
                    parent_invoice_dist_id,
                    ledger_id,
                    ledger_category_code,
                    warranty_number,
                    line_type_lookup_code,
                    po_distribution_id,
                    line_status
                    )
      -- changed hint for bug 9669334
      SELECT    /*+  ordered use_hash(algt,aagt,polt,fsp) use_nl(pov,pod,pol,poh,xdl,xal,xah)
                     swap_join_inputs(algt) swap_join_inputs(fsp)
                     swap_join_inputs(polt) swap_join_inputs(aagt)  */
		NULL,
                NULL,
                NULL,
		--bugfix:5686771 added the NVL
                RTRIM(SUBSTRB(NVL(APIDG.description,APIL.description),1,80)), -- Bug#6768121
		-- changed the NVL into DECODE to replace the MTLSI table for bug 9669334
                DECODE(APIDG.ASSET_CATEGORY_ID , NULL,
                       DECODE(POL.ITEM_ID,
                              NULL, NULL,
                              (SELECT MTLSI.ASSET_CATEGORY_ID
                                 FROM MTL_SYSTEM_ITEMS MTLSI
                                WHERE POL.ITEM_ID = MTLSI.INVENTORY_ITEM_ID
                                  AND MTLSI.ORGANIZATION_ID = FSP.INVENTORY_ORGANIZATION_ID )),
                      APIDG.ASSET_CATEGORY_ID),
                NULL,
                APIL.manufacturer,
                APIL.serial_number,
                APIL.model_number,
                APIDG.asset_book_type_code,
                NULL,
                NULL,
                API.invoice_date,
                (NVL(XDL.unrounded_accounted_dr,0) - NVL(XDL.unrounded_accounted_cr,0)),/*fixed_assets_cost*/
                 decode(APIL.match_type,                       /* payables_units */
                  'ITEM_TO_PO', decode(APIDG.quantity_invoiced,
                                  round(APIDG.quantity_invoiced),
                                  APIDG.quantity_invoiced, 1),
                  'ITEM_TO_RECEIPT', decode(APIDG.quantity_invoiced,
                                  round(APIDG.quantity_invoiced),
                                  APIDG.quantity_invoiced, 1),
                  'OTHER_TO_RECEIPT', decode(APIDG.quantity_invoiced,
                                  round(APIDG.quantity_invoiced),
                                  APIDG.quantity_invoiced, 1),
                  'QTY_CORRECTION', decode(APIDG.historical_flag,
                                       'Y',
                                       decode(APIDG.quantity_invoiced,
                                             round(APIDG.quantity_invoiced),
                                             APIDG.quantity_invoiced, 1),
                                       decode(APIDG.corrected_quantity,
                                             round(APIDG.corrected_quantity),
                                             APIDG.corrected_quantity, 1)),
                  'PRICE_CORRECTION', decode(APIDG.historical_flag,
                                         'Y',
                                          1,
                                         decode(APIDG.corrected_quantity,
                                                round(APIDG.corrected_quantity),
                                                APIDG.corrected_quantity, 1)),
                  'ITEM_TO_SERVICE_PO', 1,
                  'ITEM_TO_SERVICE_RECEIPT', 1,
                  'AMOUNT_CORRECTION', 1,
                  decode(APIDG.quantity_invoiced,
                     Null,1,
                     decode(APIDG.quantity_invoiced,
                            round(APIDG.quantity_invoiced),
                            APIDG.quantity_invoiced, 1))),
                decode(APIL.match_type,                    /* fixed_assets_units */
                  'ITEM_TO_PO', decode(APIDG.quantity_invoiced,
                                  round(APIDG.quantity_invoiced),
                                  APIDG.quantity_invoiced, 1),
                  'ITEM_TO_RECEIPT', decode(APIDG.quantity_invoiced,
                                  round(APIDG.quantity_invoiced),
                                  APIDG.quantity_invoiced, 1),
                  'OTHER_TO_RECEIPT', decode(APIDG.quantity_invoiced,
                                  round(APIDG.quantity_invoiced),
                                  APIDG.quantity_invoiced, 1),
                  'QTY_CORRECTION', decode(APIDG.historical_flag,
                                       'Y',
                                       decode(APIDG.quantity_invoiced,
                                             round(APIDG.quantity_invoiced),
                                             APIDG.quantity_invoiced, 1),
                                       decode(APIDG.corrected_quantity,
                                             round(APIDG.corrected_quantity),
                                             APIDG.corrected_quantity, 1)),
                  'PRICE_CORRECTION', decode(APIDG.historical_flag,
                                         'Y',
                                          1,
                                         decode(APIDG.corrected_quantity,
                                                round(APIDG.corrected_quantity),
                                                APIDG.corrected_quantity, 1)),
                  'ITEM_TO_SERVICE_PO', 1,
                  'ITEM_TO_SERVICE_RECEIPT', 1,
                  'AMOUNT_CORRECTION', 1,
                  decode(APIDG.quantity_invoiced,
                     Null,1,
                     decode(APIDG.quantity_invoiced,
                            round(APIDG.quantity_invoiced),
                            APIDG.quantity_invoiced, 1))),
                decode(API.source, 'Intercompany',       /* payables_code_combination_id */
                       Inv_Fa_Interface_Pvt.Get_Ic_Ccid(
                              APIDG.invoice_distribution_id,
                              APIDG.dist_code_combination_id,
                              APIDG.line_type_lookup_code),
                       decode(APIDG.po_distribution_id, NULL,
                              XAL.code_combination_id,
                              decode(POD.accrue_on_receipt_flag, 'Y',
                                     POD.code_combination_id,
                                     XAL.code_combination_id)
                              )
                      ),
                NULL,
                NULL,
                POD.deliver_to_person_id,
                'ORACLE PAYABLES',
                SYSDATE,        -- Bug 5504510
                P_request_id,
                SYSDATE,        -- Bug 5504510
                P_user_id,
                NULL,
                rtrim(API.invoice_num),
                rtrim(POV.segment1),
                API.vendor_id,
                rtrim(upper(POH.segment1)),
                'NEW',
                'NEW',
                API.invoice_date,
                API.created_by,
                API.last_updated_by,
                (NVL(XDL.unrounded_accounted_dr,0) - NVL(XDL.unrounded_accounted_cr,0)),/*payabless_cost*/
                API.invoice_id,
                APB.batch_name,
                NULL,
                NULL,
                NULL,
                NULL,
                APIDG.distribution_line_number,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                APIDG.accounting_date,
                P_user_id,
                SYSDATE,        -- Bug 5504510
                P_user_id,
                NULL,
                rtrim(API.invoice_num),
                rtrim(POV.segment1),
                APIDG.invoice_distribution_id,
                APIL.line_number,
                DECODE(APIDG.line_type_lookup_code,
                       'ITEM', decode(APIDG.corrected_invoice_dist_id, NULL,
                                      APIDG.invoice_distribution_id, APIDG.corrected_invoice_dist_id),
                       'ACCRUAL', decode(APIDG.corrected_invoice_dist_id, NULL,
                                      APIDG.invoice_distribution_id, APIDG.corrected_invoice_dist_id), -- bug 9001504
                       'IPV', decode(APIDG.related_id, NULL,
                                     APIDG.corrected_invoice_dist_id, APIDG.related_id),               -- bug 9001504
                       'ERV', APIDG.related_id,
                       APIDG.charge_applicable_to_dist_id
                      ),
                ALGT.ledger_id,
                ALGT.ledger_category_code,
                APIL.warranty_number,
                APIDG.line_type_lookup_code,
                POD.po_distribution_id,
                'NEW'
      FROM      ap_invoice_distributions_gt           APIDG,
                ap_invoice_lines_all                  APIL,
                ap_invoices_all                       API,
                financials_system_params_all          FSP, -- changed table order # 9669334
                ap_batches_all                        APB,
                po_distributions_all                  POD,
                po_headers_all                        POH,
                po_lines_all                          POL,
                po_vendors                            POV,
                po_line_types_b                       POLT,
               -- mtl_system_items                      MTLSI,
                xla_distribution_links                XDL,
                xla_ae_lines                          XAL,
                ap_acct_class_code_gt                 AAGT ,
                xla_ae_headers                        XAH,
                ap_alc_ledger_gt                      ALGT
      WHERE   APIDG.po_distribution_id = POD.po_distribution_id(+)
      AND     API.invoice_id = APIL.invoice_id
      AND     APIL.invoice_id = APIDG.invoice_id
      AND     APIL.line_number = APIDG.invoice_line_number
      AND     POD.po_header_id = POH.po_header_id(+)
      AND     POD.po_line_id = POL.po_line_id(+)
      AND     POV.vendor_id = API.vendor_id
      AND     API.batch_id = APB.batch_id(+)
      AND     POL.line_type_id = POLT.line_type_id(+)
     -- commented for bug 9669334
     -- AND     POL.item_id = MTLSI.inventory_item_id(+)
      -- Bug 5483612. Added the NVL condition
     -- AND     NVL(MTLSI.organization_id, FSP.inventory_organization_id)
      --                 = FSP.inventory_organization_id
      AND     API.org_id = FSP.org_id
      AND     XDL.application_id = 200
      AND     XAH.application_id = 200 --bug5703586
      -- bug5941716 starts
      AND     XAL.application_id = 200
      AND     XAH.accounting_entry_status_code='F'
      AND     APIDG.accounting_event_id = XAH.event_id
      -- bug5941716 ends
      AND XAH.ae_header_id = XAL.ae_header_id	        -- Bug 7284987 / 7392117
      AND XDL.source_distribution_type = 'AP_INV_DIST'	-- Bug 7284987 / 7392117
      AND     XDL.source_distribution_id_num_1 = APIDG.invoice_distribution_id
      AND     XAL.ae_header_id = XDL.ae_header_id
      AND     XAL.ae_line_num = XDL.ae_line_num
      -- Bug 7284987 / 7392117
      -- AND     XDL.ae_header_id = XAH.ae_header_id
      AND     XAH.balance_type_code = 'A'
      AND     XAH.ledger_id = ALGT.ledger_id
      AND     (APIDG.org_id = ALGT.org_id OR
               ALGT.org_id = -99)
      AND     XAL.accounting_class_code = AAGT.accounting_class_code;
      --      AND     (APIDG.asset_book_type_code = P_bt_code -- bug 8690407
      --      OR  APIDG.asset_book_type_code IS NULL);        -- bug 8690407


  ELSE

      l_debug_info := 'Insert Mass if Accounting Method Is Cash';
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      --

--This insert statement below was added for Bug 7284987 / 7392117
-- for bug 9669334 we have spilt the query. first part is for ITEM and ACCRUAL.
-- second one is for other line type lookups.
    INSERT INTO ap_invoice_distributions_gt
           (invoice_distribution_id,
            invoice_id,
            invoice_line_number,
            po_distribution_id,
            org_id,
            accounting_event_id,
            description,
            asset_category_id,
            quantity_invoiced,
            historical_flag ,
            corrected_quantity,
            dist_code_combination_id,
            line_type_lookup_code,
            distribution_line_number,
            accounting_date ,
            corrected_invoice_dist_id,
            related_id,
            charge_applicable_to_dist_id,
            asset_book_type_code,
            set_of_books_id
           )
    SELECT /*+ index(apid AP_INVOICE_DISTRIBUTIONS_N31)*/
           APID.invoice_distribution_id,
           APID.invoice_id,
           APID.invoice_line_number,
           APID.po_distribution_id,
           APID.org_id,
           APID.accounting_event_id,
           APID.description,
           APID.asset_category_id,
           APID.quantity_invoiced,
           APID.historical_flag,
           APID.corrected_quantity,
           APID.dist_code_combination_id,
           APID.line_type_lookup_code,
           APID.distribution_line_number,
           APID.accounting_date,
           APID.corrected_invoice_dist_id,
           APID.related_id,
           APID.charge_applicable_to_dist_id,
           APID.asset_book_type_code,
           APID.set_of_books_id
      FROM ap_invoice_distributions APID
     WHERE APID.accounting_date <=  P_acctg_date
       AND APID.assets_addition_flag = 'U'
       AND APID.line_type_lookup_code IN ('ITEM','ACCRUAL')
       AND  apid.assets_tracking_flag = 'Y'
       AND ( APID.project_id IS NULL
              OR (  SELECT decode(ptype.project_type_class_code,'CAPITAL','P','U')
                      FROM pa_project_types_all ptype,
                           pa_projects_all      proj
                     WHERE proj.project_type = ptype.project_type
                       AND ptype.org_id = proj.org_id
                       AND proj.project_id = APID.project_id
                  ) <> 'P'
           )
       AND APID.posted_flag = 'Y'
       AND APID.cash_posted_flag = 'Y'
       AND APID.set_of_books_id = P_ledger_id
       AND (APID.asset_book_type_code = P_bt_code OR
            APID.asset_book_type_code IS NULL)
     UNION ALL
    SELECT /*+ index(apid AP_INVOICE_DISTRIBUTIONS_N31)*/
           APID.invoice_distribution_id,
           APID.invoice_id,
           APID.invoice_line_number,
           APID.po_distribution_id,
           APID.org_id,
           APID.accounting_event_id,
           APID.description,
           APID.asset_category_id,
           APID.quantity_invoiced,
           APID.historical_flag,
           APID.corrected_quantity,
           APID.dist_code_combination_id,
           APID.line_type_lookup_code,
           APID.distribution_line_number,
           APID.accounting_date,
           APID.corrected_invoice_dist_id,
           APID.related_id,
           APID.charge_applicable_to_dist_id,
           nvl(APID.asset_book_type_code,item.asset_book_type_code),
           APID.set_of_books_id
      FROM ap_invoice_distributions APID,
           ap_invoice_distributions_all item
     WHERE APID.accounting_date <=  P_acctg_date
       AND APID.assets_addition_flag = 'U'
       AND APID.line_type_lookup_code NOT IN ('ITEM','ACCRUAL')
       AND item.assets_tracking_flag = 'Y'
       AND item.assets_addition_flag IN ('Y', 'U')
       AND nvl(nvl(apid.charge_applicable_to_dist_id, apid.related_id),
               apid.corrected_invoice_dist_id) IS NOT NULL
       AND nvl(nvl(apid.charge_applicable_to_dist_id, apid.related_id),
               apid.corrected_invoice_dist_id) =
                       item.invoice_distribution_id
       AND ( APID.project_id IS NULL
                 OR (  SELECT decode(ptype.project_type_class_code,'CAPITAL','P','U')
                         FROM pa_project_types_all ptype,
                              pa_projects_all      proj
                        WHERE proj.project_type = ptype.project_type
                          AND ptype.org_id = proj.org_id
                          AND proj.project_id = APID.project_id
                     ) <> 'P'
            )
       AND APID.posted_flag = 'Y'
       AND APID.cash_posted_flag = 'Y'
       AND APID.set_of_books_id = P_ledger_id
-- bug 8690407: add start
     AND (APID.asset_book_type_code = P_bt_code
     OR  APID.asset_book_type_code IS NULL)
-- bug 8690407: add end
     UNION ALL
    SELECT satx.invoice_distribution_id,
           satx.invoice_id,
           satx.invoice_line_number,
           satx.po_distribution_id,
           satx.org_id,
           satx.accounting_event_id,
           satx.description,
           satx.asset_category_id,
           satx.quantity_invoiced,
           'N',
           satx.corrected_quantity,
           satx.dist_code_combination_id,
           satx.line_type_lookup_code,
           satx.distribution_line_number,
           satx.accounting_date,
           satx.corrected_invoice_dist_id,
           satx.related_id,
           satx.charge_applicable_to_dist_id,
           nvl(satx.asset_book_type_code, item.asset_book_type_code),
           satx.set_of_books_id
      FROM ap_invoice_distributions_all item,
           ap_self_assessed_tax_dist satx
     WHERE satx.accounting_date <=  P_acctg_date
       AND satx.assets_addition_flag = 'U'
       AND item.assets_tracking_flag = 'Y'
       AND item.assets_addition_flag IN ('Y', 'U')
       AND satx.charge_applicable_to_dist_id IS NOT NULL
       AND satx.charge_applicable_to_dist_id = item.invoice_distribution_id
       AND ( satx.project_id IS NULL
             OR ( SELECT decode(ptype.project_type_class_code,'CAPITAL','P','U')
                    FROM pa_project_types_all ptype,
                         pa_projects_all      proj
                   WHERE proj.project_type = ptype.project_type
                     AND ptype.org_id = proj.org_id
                     AND proj.project_id   = satx.project_id
                ) <> 'P' )
       AND satx.posted_flag = 'Y'
       AND satx.cash_posted_flag = 'Y'
       AND satx.set_of_books_id = P_ledger_id
       AND (satx.asset_book_type_code = P_bt_code OR
            satx.asset_book_type_code IS NULL);

      INSERT INTO FA_MASS_ADDITIONS_GT(
                    mass_addition_id,
                    asset_number,
                    tag_number,
                    description,
                    asset_category_id,
                    inventorial,
                    manufacturer_name,
                    serial_number,
                    model_number,
                    book_type_code,
                    date_placed_in_service,
                    transaction_type_code,
                    transaction_date,
                    fixed_assets_cost,
                    payables_units,
                    fixed_assets_units,
                    payables_code_combination_id,
                    expense_code_combination_id,
                    location_id,
                    assigned_to,
                    feeder_system_name,
                    create_batch_date,
                    create_batch_id,
                    last_update_date,
                    last_updated_by,
                    reviewer_comments,
                    invoice_number,
                    vendor_number,
                    po_vendor_id,
                    po_number,
                    posting_status,
                    queue_name,
                    invoice_date,
                    invoice_created_by,
                    invoice_updated_by,
                    payables_cost,
                    invoice_id,
                    payables_batch_name,
                    depreciate_flag,
                    parent_mass_addition_id,
                    parent_asset_id,
                    split_merged_code,
                    ap_distribution_line_number,
                    post_batch_id,
                    add_to_asset_id,
                    amortize_flag,
                    new_master_flag,
                    asset_key_ccid,
                    asset_type,
                    deprn_reserve,
                    ytd_deprn,
                    beginning_nbv,
                    accounting_date,
                    created_by,
                    creation_date,
                    last_update_login,
                    salvage_value,
                    merge_invoice_number,
                    merge_vendor_number,
                    invoice_distribution_id,
                    invoice_line_number,
                    parent_invoice_dist_id,
                    ledger_id,
                    ledger_category_code,
                    warranty_number,
                    line_type_lookup_code,
                    po_distribution_id,
                    line_status
                    )
      -- changed hint for bug 9669334
      SELECT    /*+  ordered use_hash(algt,aagt,polt,fsp) use_nl(pov,pod,pol,poh,xdl,xal,xah)
                     swap_join_inputs(algt) swap_join_inputs(fsp)
                     swap_join_inputs(polt) swap_join_inputs(aagt)  */
		NULL,
                NULL,
                NULL,
		--bugfix:5686771 added the NVL
                RTRIM(SUBSTRB(NVL(APIDG.description,APIL.description),1,80)), -- Bug#6768121
		-- changed the NVL into DECODE to replace the MTLSI table for bug 9669334
                DECODE(APIDG.ASSET_CATEGORY_ID , NULL,
                       DECODE(POL.ITEM_ID,
                              NULL, NULL,
                              (SELECT MTLSI.ASSET_CATEGORY_ID
                                 FROM MTL_SYSTEM_ITEMS MTLSI
                                WHERE POL.ITEM_ID = MTLSI.INVENTORY_ITEM_ID
                                  AND MTLSI.ORGANIZATION_ID = FSP.INVENTORY_ORGANIZATION_ID )),
                      APIDG.ASSET_CATEGORY_ID),
                NULL,
                APIL.manufacturer,
                APIL.serial_number,
                APIL.model_number,
                APIDG.asset_book_type_code,
                NULL,
                NULL,
                API.invoice_date,
                (NVL(XDL.unrounded_accounted_dr,0) - NVL(XDL.unrounded_accounted_cr,0)),/*fixed_assets_cost*/
                 decode(APIL.match_type,                       /* payables_units */
                  'ITEM_TO_PO', decode(APIDG.quantity_invoiced,
                                  round(APIDG.quantity_invoiced),
                                  APIDG.quantity_invoiced, 1),
                  'ITEM_TO_RECEIPT', decode(APIDG.quantity_invoiced,
                                  round(APIDG.quantity_invoiced),
                                  APIDG.quantity_invoiced, 1),
                  'OTHER_TO_RECEIPT', decode(APIDG.quantity_invoiced,
                                  round(APIDG.quantity_invoiced),
                                  APIDG.quantity_invoiced, 1),
                  'QTY_CORRECTION', decode(APIDG.historical_flag,
                                       'Y',
                                       decode(APIDG.quantity_invoiced,
                                             round(APIDG.quantity_invoiced),
                                             APIDG.quantity_invoiced, 1),
                                       decode(APIDG.corrected_quantity,
                                             round(APIDG.corrected_quantity),
                                             APIDG.corrected_quantity, 1)),
                  'PRICE_CORRECTION', decode(APIDG.historical_flag,
                                         'Y',
                                          1,
                                         decode(APIDG.corrected_quantity,
                                                round(APIDG.corrected_quantity),
                                                APIDG.corrected_quantity, 1)),
                  'ITEM_TO_SERVICE_PO', 1,
                  'ITEM_TO_SERVICE_RECEIPT', 1,
                  'AMOUNT_CORRECTION', 1,
                  decode(APIDG.quantity_invoiced,
                     Null,1,
                     decode(APIDG.quantity_invoiced,
                            round(APIDG.quantity_invoiced),
                            APIDG.quantity_invoiced, 1))),
                decode(APIL.match_type,                    /* fixed_assets_units */
                  'ITEM_TO_PO', decode(APIDG.quantity_invoiced,
                                  round(APIDG.quantity_invoiced),
                                  APIDG.quantity_invoiced, 1),
                  'ITEM_TO_RECEIPT', decode(APIDG.quantity_invoiced,
                                  round(APIDG.quantity_invoiced),
                                  APIDG.quantity_invoiced, 1),
                  'OTHER_TO_RECEIPT', decode(APIDG.quantity_invoiced,
                                  round(APIDG.quantity_invoiced),
                                  APIDG.quantity_invoiced, 1),
                  'QTY_CORRECTION', decode(APIDG.historical_flag,
                                       'Y',
                                       decode(APIDG.quantity_invoiced,
                                             round(APIDG.quantity_invoiced),
                                             APIDG.quantity_invoiced, 1),
                                       decode(APIDG.corrected_quantity,
                                             round(APIDG.corrected_quantity),
                                             APIDG.corrected_quantity, 1)),
                  'PRICE_CORRECTION', decode(APIDG.historical_flag,
                                         'Y',
                                          1,
                                         decode(APIDG.corrected_quantity,
                                                round(APIDG.corrected_quantity),
                                                APIDG.corrected_quantity, 1)),
                  'ITEM_TO_SERVICE_PO', 1,
                  'ITEM_TO_SERVICE_RECEIPT', 1,
                  'AMOUNT_CORRECTION', 1,
                  decode(APIDG.quantity_invoiced,
                     Null,1,
                     decode(APIDG.quantity_invoiced,
                            round(APIDG.quantity_invoiced),
                            APIDG.quantity_invoiced, 1))),
                decode(API.source, 'Intercompany',       /* payables_code_combination_id */
                       Inv_Fa_Interface_Pvt.Get_Ic_Ccid(
                              APIDG.invoice_distribution_id,
                              APIDG.dist_code_combination_id,
                              APIDG.line_type_lookup_code),
                       decode(APIDG.po_distribution_id, NULL,
                              XAL.code_combination_id,
                              decode(POD.accrue_on_receipt_flag, 'Y',
                                     POD.code_combination_id,
                                     XAL.code_combination_id)
                              )
                      ),
                NULL,
                NULL,
                POD.deliver_to_person_id,
                'ORACLE PAYABLES',
                SYSDATE,        -- Bug 5504510
                P_request_id,
                SYSDATE,        -- Bug 5504510
                P_user_id,
                NULL,
                rtrim(API.invoice_num),
                rtrim(POV.segment1),
                API.vendor_id,
                rtrim(upper(POH.segment1)),
                'NEW',
                'NEW',
                API.invoice_date,
                API.created_by,
                API.last_updated_by,
                (NVL(XDL.unrounded_accounted_dr,0) - NVL(XDL.unrounded_accounted_cr,0)),/*payabless_cost*/
                API.invoice_id,
                APB.batch_name,
                NULL,
                NULL,
                NULL,
                NULL,
                APIDG.distribution_line_number,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                APIDG.accounting_date,
                P_user_id,
                SYSDATE,        -- Bug 5504510
                P_user_id,
                NULL,
                rtrim(API.invoice_num),
                rtrim(POV.segment1),
                APIDG.invoice_distribution_id,
                APIL.line_number,
                DECODE(APIDG.line_type_lookup_code,
                       'ITEM', decode(APIDG.corrected_invoice_dist_id, NULL,
                                      APIDG.invoice_distribution_id, APIDG.corrected_invoice_dist_id),
                       'ACCRUAL', decode(APIDG.corrected_invoice_dist_id, NULL,
                                      APIDG.invoice_distribution_id, APIDG.corrected_invoice_dist_id), -- bug 9001504
                       'IPV', decode(APIDG.related_id, NULL,
                                     APIDG.corrected_invoice_dist_id, APIDG.related_id),               -- bug 9001504
                       'ERV', APIDG.related_id,
                       APIDG.charge_applicable_to_dist_id
                      ),
                ALGT.ledger_id,
                ALGT.ledger_category_code,
                APIL.warranty_number,
                APIDG.line_type_lookup_code,
                POD.po_distribution_id,
                'NEW'
      FROM      ap_invoice_distributions_gt           APIDG,
                ap_invoice_lines_all                  APIL,
                ap_invoices_all                       API,
                financials_system_params_all          FSP,  -- changed table order # 9669334
                ap_batches_all                        APB,
                po_distributions_all                  POD,
                po_headers_all                        POH,
                po_lines_all                          POL,
                po_vendors                            POV,
                po_line_types_b                       POLT,
               -- mtl_system_items                      MTLSI,
                xla_distribution_links                XDL,
                xla_ae_lines                          XAL,
                ap_acct_class_code_gt                 AAGT ,
                xla_ae_headers                        XAH,
                ap_alc_ledger_gt                      ALGT
      WHERE   APIDG.po_distribution_id = POD.po_distribution_id(+)
      AND     API.invoice_id = APIL.invoice_id
      AND     APIL.invoice_id = APIDG.invoice_id
      AND     APIL.line_number = APIDG.invoice_line_number
      AND     POD.po_header_id = POH.po_header_id(+)
      AND     POD.po_line_id = POL.po_line_id(+)
      AND     POV.vendor_id = API.vendor_id
      AND     API.batch_id = APB.batch_id(+)
      AND     POL.line_type_id = POLT.line_type_id(+)
 -- commented for bug 9669334
     -- AND     POL.item_id = MTLSI.inventory_item_id(+)
      -- Bug 5483612. Added the NVL condition
     -- AND     NVL(MTLSI.organization_id, FSP.inventory_organization_id)
      --                 = FSP.inventory_organization_id
      AND     API.org_id = FSP.org_id
      AND     XDL.application_id = 200
      AND     XAH.application_id = 200 --bug5703586
      -- bug5941716 starts
      AND     XAL.application_id = 200
      AND     XAH.accounting_entry_status_code='F'
      AND     APIDG.accounting_event_id = XAH.event_id
      -- bug5941716 ends
      AND XAH.ae_header_id = XAL.ae_header_id	        -- Bug 7284987 / 7392117
      AND XDL.source_distribution_type = 'AP_INV_DIST'	-- Bug 7284987 / 7392117
      AND     XDL.source_distribution_id_num_1 = APIDG.invoice_distribution_id
      AND     XAL.ae_header_id = XDL.ae_header_id
      AND     XAL.ae_line_num = XDL.ae_line_num
      -- Bug 7284987 / 7392117
      -- AND     XDL.ae_header_id = XAH.ae_header_id
      AND     XAH.balance_type_code = 'A'
      AND     XAH.ledger_id = ALGT.ledger_id
      AND     (APIDG.org_id = ALGT.org_id OR
               ALGT.org_id = -99)
      AND     XAL.accounting_class_code = AAGT.accounting_class_code;
      --      AND     (APIDG.asset_book_type_code = P_bt_code -- bug 8690407
      --      OR  APIDG.asset_book_type_code IS NULL);        -- bug 8690407


    END IF;

    P_count := SQL%ROWCOUNT;

/* BUG # 7648502. Added the update statement to
   update the assets addition flag to N which are
   not picked up by fass addition gt table but picked by
   distributions gt table. by stamping these to N will
   avoid from picking up again while loading distributions gt
*/
/*  Modified the query for performance bug 8729684: start */
     UPDATE ap_invoice_distributions_all AID
     SET AID.assets_addition_flag = 'N'
     WHERE AID.invoice_distribution_id IN
      (SELECT APIDG.invoice_distribution_id
	  FROM ap_invoice_distributions_gt APIDG
      where charge_applicable_to_dist_id is null
      AND NOT EXISTS
         (SELECT 1
          FROM fa_mass_additions_gt FAGT
		  WHERE APIDG.INVOICE_DISTRIBUTION_ID = FAGT.INVOICE_DISTRIBUTION_ID
		 )
	  );
/*  Modified the query for performance bug 8729684: end */
-- bug 8690407: add start
/*  Modified the query for performance bug8983726 */

UPDATE /*+ index(AID AP_INVOICE_DISTRIBUTIONS_U2) */
 AP_INVOICE_DISTRIBUTIONS_ALL AID
 SET AID.ASSETS_ADDITION_FLAG = 'N'
 WHERE
  AID.INVOICE_DISTRIBUTION_ID IN
  ( SELECT APIDG.INVOICE_DISTRIBUTION_ID
    FROM AP_INVOICE_DISTRIBUTIONS_GT APIDG
    WHERE
         CHARGE_APPLICABLE_TO_DIST_ID IS NOT NULL
         AND NOT EXISTS
         (
	    SELECT  1  FROM FA_MASS_ADDITIONS_GT FAGT
	    where APIDG.INVOICE_DISTRIBUTION_ID=FAGT.INVOICE_DISTRIBUTION_ID
         )
   )
 AND EXISTS
	(
	   SELECT /*+ index(AP_INVOICE_DISTRIBUTIONS_ALL AP_INVOICE_DISTRIBUTIONS_U2)*/ 1 FROM AP_INVOICE_DISTRIBUTIONS_ALL
	   WHERE INVOICE_DISTRIBUTION_ID = AID.CHARGE_APPLICABLE_TO_DIST_ID
	   AND ASSETS_ADDITION_FLAG = 'N'
        );

/*  Modified the query for performance bug8983726 */
-- bug 8690407: add end

-- bug 7215835: add start : update self assessed table also
    UPDATE AP_SELF_ASSESSED_TAX_DIST_ALL AID
    SET AID.assets_addition_flag = 'N'
    WHERE AID.invoice_distribution_id IN
       (SELECT APIDG.invoice_distribution_id
        FROM ap_invoice_distributions_gt APIDG)
    AND AID.invoice_distribution_id NOT IN
       (SELECT FAGT.invoice_distribution_id
        FROM fa_mass_additions_gt FAGT)
-- bug 7215835: add end
-- bug 8690407: add start
     and exists (select 1 from ap_invoice_distributions_all
          where invoice_distribution_id = aid.charge_applicable_to_dist_id
          and nvl(assets_addition_flag, 'N') = 'N');
-- bug 8690407: add end

    --
EXCEPTION
  WHEN OTHERS THEN
    --
    IF (SQLCODE <> -20001 ) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
    END IF;
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,SQLERRM);
    END IF;
    --
    APP_EXCEPTION.RAISE_EXCEPTION;
    --
END Insert_Mass;

----------------------------------------------------------------------------
-- Procedure will Insert Discount related to distributions that are tracked
-- as asset in FA_MASS_ADDITIONS_GT table
--

PROCEDURE Insert_Discount(
                P_acctg_date         IN    DATE,
                P_ledger_id          IN    NUMBER,
                P_user_id            IN    NUMBER,
                P_request_id         IN    NUMBER,
                P_bt_code            IN    VARCHAR2,
                P_count              OUT NOCOPY   NUMBER,
                P_calling_sequence   IN    VARCHAR2   DEFAULT NULL) IS
--
    l_current_calling_sequence   VARCHAR2(2000);
    l_debug_info                 VARCHAR2(2000);
    l_invoice_pay_id   AP_INVOICE_PAYMENTS.INVOICE_PAYMENT_ID%TYPE;
    l_count                      INTEGER;
    l_dis_total                  INTEGER;
    l_api_name         CONSTANT  VARCHAR2(100) := 'INSERT_DISCOUNT';
    /*----------------------------------------------------------------
    Inv Dist for the Invoice which this Invoice Payment is paying,
    should have related discount lines. Also the Invoice Distribution
    should already be transferred as asset line.
    ----------------------------------------------------------------*/
    --
    CURSOR    C_Discount(
                P_acctg_date             IN    DATE,
                P_ledger_id              IN    NUMBER,
                P_calling_sequence       IN    VARCHAR2)   IS
    SELECT  invoice_payment_id
    FROM    ap_invoice_payments APIP
    WHERE   APIP.assets_addition_flag = 'U'
    AND     APIP.posted_flag = 'Y'
    AND     APIP.accounting_date <= P_acctg_date
    AND     APIP.set_of_books_id = P_ledger_id
    AND     APIP.invoice_payment_id  IN (
            SELECT    /*+ INDEX(aphd ap_payment_hist_dists_n5) */ -- Bug 8305129
                      APHD.invoice_payment_id
            FROM      ap_payment_hist_dists    APHD,
                      ap_invoice_distributions_all APID
            WHERE     APIP.invoice_payment_id = APHD.invoice_payment_id
            AND       APIP.ACCOUNTING_EVENT_ID=APHD.ACCOUNTING_EVENT_ID --bug5461146
            AND       APHD.invoice_distribution_id = APID.invoice_distribution_id
	    AND       APHD.pay_dist_lookup_code = 'DISCOUNT'
            AND       NVL(APID.assets_addition_flag,'N') <> 'N' -- bug 9001504
            AND       (APID.asset_book_type_code = P_bt_code  -- Bug 5581999
	               OR APID.asset_book_type_code IS NULL)
             /* bug 4475705 */
            AND (  (APID.line_type_lookup_code IN ('ITEM', 'ACCRUAL')
                    AND APID.assets_tracking_flag = 'Y')
               OR EXISTS  -- Bug 8305129 : Replaced 2 EXISTS clause with 1
                   ( SELECT 'X'
                     FROM   ap_invoice_distributions_all APIDV
                     WHERE  NVL(APID.related_id,APID.charge_applicable_to_dist_id)  =
                                                              APIDV.invoice_distribution_id
                     AND    APIDV.invoice_distribution_id <>  NVL(APIDV.related_id, -1)
                     AND    APIDV.assets_tracking_flag = 'Y'
                   )
                )
            );
    --
BEGIN
    ---
    l_current_calling_sequence := P_calling_sequence||'->'||
                    'Insert_Discount';
    ---
    l_count      := 0;
    l_dis_total  := 0;
    ---
    l_debug_info := 'Open cursor c_discount';
    OPEN  C_Discount(P_acctg_date,
                     P_ledger_id,
                     l_current_calling_sequence);
    --
      LOOP
      --
      FETCH   C_Discount
      INTO    l_invoice_pay_id;
      EXIT    WHEN C_Discount%NOTFOUND;
      --
      l_debug_info := 'Insert into FA_MASS_ADDITIONS_GT';
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Invoice Payment_Id: '
                               ||TO_CHAR(l_invoice_pay_id));
      END IF;
      --
      INSERT INTO FA_MASS_ADDITIONS_GT(
                mass_addition_id,
                asset_number,
                tag_number,
                description,
                asset_category_id,
                inventorial,
                manufacturer_name,
                serial_number,
                model_number,
                book_type_code,
                date_placed_in_service,
                transaction_type_code,
                transaction_date,
                fixed_assets_cost,
                payables_units,
                fixed_assets_units,
                payables_code_combination_id,
                expense_code_combination_id,
                location_id,
                assigned_to,
                feeder_system_name,
                create_batch_date,
                create_batch_id,
                last_update_date,
                last_updated_by,
                reviewer_comments,
                invoice_number,
                vendor_number,
                po_vendor_id,
                po_number,
                posting_status,
                queue_name,
                invoice_date,
                invoice_created_by,
                invoice_updated_by,
                payables_cost,
                invoice_id,
                payables_batch_name,
                depreciate_flag,
                parent_mass_addition_id,
                parent_asset_id,
                split_merged_code,
                ap_distribution_line_number,
                post_batch_id,
                add_to_asset_id,
                amortize_flag,
                new_master_flag,
                asset_key_ccid,
                asset_type,
                deprn_reserve,
                ytd_deprn,
                beginning_nbv,
                accounting_date,
                created_by,
                creation_date,
                last_update_login,
                salvage_value,
                merge_invoice_number,
                merge_vendor_number,
                invoice_distribution_id,
                invoice_line_number,
                parent_invoice_dist_id,
                ledger_id,
                ledger_category_code,
                warranty_number,
                line_type_lookup_code,
                po_distribution_id,
                line_status,
		invoice_payment_id  --bug5485118
      ) --8393259 xdl is removed from leading hint
      SELECT        /*+ leading ( apip aphd ) use_hash ( algt ) use_hash ( aagt ) swap_join_inputs ( algt ) swap_join_inputs ( aagt ) */ NULL,  --bug5941716
                    NULL,
                    NULL,
                    APL.displayed_field, -- bug 8927096: modify
                    NULL,
                    'YES',
                    NULL,
                    NULL,
                    NULL,
                    DECODE(APID.asset_book_type_code, P_bt_code,
                           P_bt_code, APID.asset_book_type_code),
                    NULL,
                    NULL,
                    API.invoice_date,
                    (NVL(XDL.unrounded_accounted_dr,0) - NVL(XDL.unrounded_accounted_cr,0)),/*fixed_assets_cost*/
                    decode(APIL.match_type,                       /* payables_units */
                      'ITEM_TO_PO', decode(APID.quantity_invoiced,
                                  round(APID.quantity_invoiced),
                                  APID.quantity_invoiced, 1),
                      'ITEM_TO_RECEIPT', decode(APID.quantity_invoiced,
                                  round(APID.quantity_invoiced),
                                  APID.quantity_invoiced, 1),
                      'OTHER_TO_RECEIPT', decode(APID.quantity_invoiced,
                                  round(APID.quantity_invoiced),
                                  APID.quantity_invoiced, 1),
                      'QTY_CORRECTION', decode(APID.historical_flag,
                                       'Y',
                                       decode(APID.quantity_invoiced,
                                             round(APID.quantity_invoiced),
                                             APID.quantity_invoiced, 1),
                                       decode(APID.corrected_quantity,
                                             round(APID.corrected_quantity),
                                             APID.corrected_quantity, 1)),
                      'PRICE_CORRECTION', decode(APID.historical_flag,
                                         'Y',
                                          1,
                                         decode(APID.corrected_quantity,
                                                round(APID.corrected_quantity),
                                                APID.corrected_quantity, 1)),
                      'ITEM_TO_SERVICE_PO', 1,
                      'ITEM_TO_SERVICE_RECEIPT', 1,
                      'AMOUNT_CORRECTION', 1,
                      decode(APID.quantity_invoiced,
                        Null,1,
                        decode(APID.quantity_invoiced,
                            round(APID.quantity_invoiced),
                            APID.quantity_invoiced, 1))),
                    decode(APIL.match_type,                    /* fixed_assets_units */
                      'ITEM_TO_PO', decode(APID.quantity_invoiced,
                                  round(APID.quantity_invoiced),
                                  APID.quantity_invoiced, 1),
                      'ITEM_TO_RECEIPT', decode(APID.quantity_invoiced,
                                  round(APID.quantity_invoiced),
                                  APID.quantity_invoiced, 1),
                      'OTHER_TO_RECEIPT', decode(APID.quantity_invoiced,
                                  round(APID.quantity_invoiced),
                                  APID.quantity_invoiced, 1),
                      'QTY_CORRECTION', decode(APID.historical_flag,
                                       'Y',
                                       decode(APID.quantity_invoiced,
                                             round(APID.quantity_invoiced),
                                             APID.quantity_invoiced, 1),
                                       decode(APID.corrected_quantity,
                                             round(APID.corrected_quantity),
                                             APID.corrected_quantity, 1)),
                      'PRICE_CORRECTION', decode(APID.historical_flag,
                                         'Y',
                                          1,
                                         decode(APID.corrected_quantity,
                                                round(APID.corrected_quantity),
                                                APID.corrected_quantity, 1)),
                      'ITEM_TO_SERVICE_PO', 1,
                      'ITEM_TO_SERVICE_RECEIPT', 1,
                      'AMOUNT_CORRECTION', 1,
                      decode(APID.quantity_invoiced,
                        Null,1,
                        decode(APID.quantity_invoiced,
                            round(APID.quantity_invoiced),
                            APID.quantity_invoiced, 1))),
                    decode(APID.po_distribution_id, NULL,    /* payables_code_combination_id */
                              XAL.code_combination_id,
                              decode(POD.accrue_on_receipt_flag, 'Y',
                                     POD.code_combination_id,
                                     XAL.code_combination_id)
                          ),
                    NULL,
                    NULL,
                    POD.deliver_to_person_id,
                    'ORACLE PAYABLES',
                    SYSDATE,         -- Bug 5504510
                    P_request_id,
                    SYSDATE,         -- Bug 5504510
                    P_user_id,
                    NULL,
                    rtrim(API.invoice_num),
                    rtrim(POV.segment1),
                    API.vendor_id,
                    rtrim(upper(POH.segment1)),
                    'NEW',
                    'NEW',
                    API.invoice_date,
                    API.created_by,
                    API.last_updated_by,
                    (NVL(XDL.unrounded_accounted_dr,0) - NVL(XDL.unrounded_accounted_cr,0)),/*payabless_cost*/
                    API.invoice_id,
                    APB.batch_name,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    APID.distribution_line_number,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    APID.accounting_date,
                    P_user_id,
                    SYSDATE,       -- Bug 5504510
                    P_user_id,
                    NULL,
                    rtrim(API.invoice_num),
                    rtrim(POV.segment1),
                    APID.invoice_distribution_id,  -- Bug 5648304.
                    APIL.line_number,
                    DECODE(APID.line_type_lookup_code,
                           'ITEM', decode(APID.corrected_invoice_dist_id, NULL,
                                      APID.invoice_distribution_id, APID.corrected_invoice_dist_id),
                           'ACCRUAL', decode(APID.corrected_invoice_dist_id, NULL,
                                      APID.invoice_distribution_id, APID.corrected_invoice_dist_id),
                           APID.charge_applicable_to_dist_id),
                    ALGT.ledger_id,
                    ALGT.ledger_category_code,
                    APIL.warranty_number,
                    'DISCOUNT',
                    POD.po_distribution_id,
                    'NEW',
		    APIP.invoice_payment_id
      FROM          ap_invoice_distributions_all  APID,
                    ap_invoice_lines_all      APIL,
                    ap_invoice_payments_all   APIP,
                    ap_payment_hist_dists     APHD,
                    ap_invoices_all           API,
                    ap_batches_all            APB,
                    po_distributions_all      POD,
                    po_headers_all            POH,
                    po_lines_all              POL,
                    po_vendors                POV,
                    --po_line_types_b           POLT,
                    xla_distribution_links    XDL,
                    xla_ae_headers            XAH,
                    xla_ae_lines              XAL,
                    ap_alc_ledger_gt          ALGT,
                    ap_acct_class_code_gt     AAGT,
                    ap_lookup_codes           APL -- bug 8927096: add
      WHERE  APIP.invoice_payment_id = l_invoice_pay_id
      AND    APIP.invoice_payment_id = APHD.invoice_payment_id
      AND    APHD.invoice_distribution_id = APID.invoice_distribution_id
      AND    APHD.pay_dist_lookup_code = 'DISCOUNT'
      AND    APIP.assets_addition_flag = 'U'
      AND    APIP.posted_flag = 'Y'
      AND    APIP.accounting_date <= P_acctg_date
      AND    APIP.set_of_books_id = P_ledger_id
      AND    APID.assets_addition_flag <> 'N' -- bug 9001504
-- bug 8927096: add start
      AND    APL.lookup_code='DISCOUNT'
      AND    APL.lookup_type='AE LINE TYPE'
-- bug 8927096: add end
       /* bug 4475705 */
      AND     (  (APID.line_type_lookup_code IN ('ITEM', 'ACCRUAL')
                  AND APID.assets_tracking_flag = 'Y')
              OR EXISTS
                   ( SELECT 'X'
                     FROM ap_invoice_distributions_all APIDV
                     WHERE APID.related_id =
                     APIDV.invoice_distribution_id
                     AND  APID.invoice_distribution_id <>  APID.related_id   --bug6415366
                     AND APIDV.assets_tracking_flag = 'Y')
              OR EXISTS
                   ( SELECT 'X'
                     FROM ap_invoice_distributions_all APIDC
                     WHERE APID.charge_applicable_to_dist_id =
                     APIDC.invoice_distribution_id
                     AND APIDC.assets_tracking_flag = 'Y')
              )
      AND    APID.po_distribution_id = POD.po_distribution_id(+)
      AND    API.invoice_id = APIL.invoice_id
      AND    APIL.invoice_id = APID.invoice_id
      AND    APIL.line_number = APID.invoice_line_number
      AND    POD.po_header_id = POH.po_header_id(+)
      AND    POD.po_line_id = POL.po_line_id(+)
      AND    POV.vendor_id = API.vendor_id
      AND    API.batch_id = APB.batch_id(+)
     -- AND    POL.line_type_id = POLT.line_type_id(+)
      AND    XDL.source_distribution_id_num_1 = APHD.payment_hist_dist_id
      AND    XAL.ae_header_id = XDL.ae_header_id
      AND    XAL.ae_line_num = XDL.ae_line_num
      AND    XDL.ae_header_id = XAH.ae_header_id
      AND    XAH.balance_type_code = 'A'
      AND    XAH.ledger_id = ALGT.ledger_id
      AND     XDL.application_id = 200 --bug5703586
      AND     XAH.application_id = 200 --bug5703586
      --bug5941716 starts
      AND     XAL.application_id = 200
      AND     XAH.accounting_entry_status_code='F'
      AND     APIP.accounting_event_id = XAH.event_id /*for bug#6932371 attached discounts to APIP table
                                                      instead of APID table*/
      --bug5941716 ends
       AND    (APID.org_id = ALGT.org_id OR
              ALGT.org_id = -99)
      AND    XAL.accounting_class_code = AAGT.accounting_class_code;
     /*Bug 5493488
      AND    APIP.invoice_id = 125104; */
      l_count := SQL%ROWCOUNT;
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'No of Records Inserted: '
                               ||TO_CHAR(l_count));
      END IF;
      --
      l_dis_total := l_count +  l_dis_total;
      --
      END LOOP;
      --
    CLOSE C_Discount;
    --
    P_count := l_dis_total;
    --

EXCEPTION
    WHEN OTHERS THEN
    IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
    END IF;
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,SQLERRM);
    END IF;
    --
    APP_EXCEPTION.RAISE_EXCEPTION;
--
END Insert_Discount;
----------------------------------------------------------------------------
--Main Procedure

PROCEDURE Mass_Additions_Create(
            errbuf             OUT NOCOPY VARCHAR2,
            retcode            OUT NOCOPY NUMBER,
            P_acctg_date       IN  VARCHAR2,
            P_bt_code          IN  VARCHAR2,
            P_calling_sequence IN  VARCHAR2 DEFAULT NULL) IS
    --
    --local variables
    --
    l_request_id                NUMBER;
    l_login_id                  NUMBER;
    l_debug_info                VARCHAR2(2000);
    l_acctg_date                DATE;
    l_ledger_id                 FA_BOOK_CONTROLS.SET_OF_BOOKS_ID%TYPE;
    l_asset_type                INTEGER;
    l_user_id                   NUMBER;
    l_count                     INTEGER;
    l_total                     INTEGER := 0;
    l_count1                    INTEGER := 0;
    l_total1                    INTEGER := 0;
    l_current_calling_sequence  VARCHAR2(2000);
    l_primary_accounting_method VARCHAR2(30);
    l_org_id                    NUMBER(15);
    l_return_status             VARCHAR2(1);
    l_pa_return_status          VARCHAR2(1);
    l_msg_count                 NUMBER(15);
    l_pa_msg_count              NUMBER(15);
    l_msg_data                  VARCHAR2(2000);
    l_pa_msg_data               VARCHAR2(2000);
    l_api_name         CONSTANT VARCHAR2(100) := 'MASS_ADDITIONS_CREATE';
    l_error_msg                 VARCHAR2(2000);
    l_pa_error_msg              VARCHAR2(2000);
    --
    FA_API_ERROR                EXCEPTION;

--
BEGIN
    --
    l_current_calling_sequence := P_calling_sequence||'->'||
           'AP_MASS_ADDITIONS_CREATE_PKG.MASS_ADDITIONS_CREATE';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' Book Type Code: '|| P_bt_code
                     ||', Accounting Date: '||P_acctg_date);
    END IF;
    --
    l_acctg_date := FND_DATE.CANONICAL_TO_DATE(P_acctg_date);
    --
    l_debug_info := 'Get Profiles';

    l_user_id :=    FND_GLOBAL.user_id;
    l_request_id := FND_GLOBAL.conc_request_id;
    l_login_id   := FND_GLOBAL.login_id;
    --
    l_debug_info := 'Get FA Book ledger id based on FA API';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    /* l_ledger_id :=
      FA_MASSADD_CREATE_PKG.Get_Ledger_Id (
         P_bt_code,
         'Oracle Payables.'||l_api_name);  */
	--8236268 changes
	If NOT fa_cache_pkg.fazcbc(X_book => p_bt_code) then
         APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

      l_ledger_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
    --
    l_debug_info := 'Populate Global Temp Table for All Related Ledgers ';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    Populate_Mass_Ledger_Gt(
                     l_ledger_id,
                     l_current_calling_sequence);
    --
    l_debug_info := 'Populate Global Temp Table for Accounting Class Code ';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    Populate_Mass_Acct_Code_Gt(
                     l_ledger_id,
                     l_current_calling_sequence);
    --
    l_debug_info := 'Derive Accounting Method from Gl Sets Of Books ';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    l_primary_accounting_method := Derive_Acct_Method(
                                     l_ledger_id,
                                     l_current_calling_sequence);
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                     'Primary Acct Method: '||l_primary_accounting_method||
                     ' , Ledger_Id: '||TO_CHAR(l_ledger_id));
    END IF;
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                     'Request Id: '||TO_CHAR(l_request_id)||
                     ' , User Id: '||TO_CHAR(l_user_id)||
                     ' , Login Id: '||TO_CHAR(l_login_id));
    END IF;
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                             'Updating AID records to N which EIB sends to FA ');
    END IF;
    --
    UPDATE   /*+ INDEX(apid ap_invoice_distributions_n6) */ -- Bug 8305129
             ap_invoice_distributions_all APID
    SET      APID.assets_addition_flag = 'N',
             APID.program_update_date = SYSDATE,
             APID.program_application_id = FND_GLOBAL.prog_appl_id,
             APID.program_id = FND_GLOBAL.conc_program_id,
             APID.request_id = l_request_id
    WHERE    APID.assets_addition_flag = 'U'
    AND      APID.org_id IN (SELECT org_id
                             FROM ap_system_parameters)
    AND      APID.set_of_books_id = l_ledger_id
    AND      APID.posted_flag = 'Y'
    AND      APID.assets_tracking_flag = 'Y'
    AND      EXISTS    -- Added EXISTS for bug 9669334
             (SELECT 'X'
              FROM   mtl_system_items MTLSI,
	             po_distributions_all POD,
                     po_line_locations_all PLL,
		     po_lines_all POL
              WHERE  POD.po_distribution_id = APID.po_distribution_id
              AND    PLL.line_location_id = POD.line_location_id
              AND    POL.po_line_id = PLL.po_line_id
              AND    POL.item_id = MTLSI.inventory_item_id
              AND    MTLSI.organization_id = POD.destination_organization_id
	      AND    MTLSI.comms_nl_trackable_flag = 'Y'
	      AND    MTLSI.asset_creation_code = 1);
    --
    l_count := SQL%ROWCOUNT;
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'No of Records Updated: '                               ||TO_CHAR(l_count));
    END IF;
    --
-- bug 7215835: add start : update self assessed table also
    UPDATE   ap_self_assessed_tax_dist_all APID
    SET      APID.assets_addition_flag = 'N',
             APID.program_update_date = SYSDATE,
             APID.program_application_id = FND_GLOBAL.prog_appl_id,
             APID.program_id = FND_GLOBAL.conc_program_id,
             APID.request_id = l_request_id
    WHERE    APID.assets_addition_flag = 'U'
    AND      APID.org_id IN (SELECT org_id
                             FROM ap_system_parameters)
    AND      APID.set_of_books_id = l_ledger_id
    AND      APID.posted_flag = 'Y'
    AND      APID.assets_tracking_flag = 'Y'
    AND      EXISTS    -- Added EXISTS for bug 9669334
             (SELECT 'X'
              FROM   mtl_system_items MTLSI,
	             po_distributions_all POD,
                     po_line_locations_all PLL,
		     po_lines_all POL
              WHERE  POD.po_distribution_id = APID.po_distribution_id
              AND    PLL.line_location_id = POD.line_location_id
              AND    POL.po_line_id = PLL.po_line_id
              AND    POL.item_id = MTLSI.inventory_item_id
              AND    MTLSI.organization_id = POD.destination_organization_id
	      AND    MTLSI.comms_nl_trackable_flag = 'Y'
	      AND    MTLSI.asset_creation_code = 1);

    l_count := SQL%ROWCOUNT + l_count;
-- bug 7215835: add end
    --
    l_debug_info := ' Calling Insert_Mass';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    Insert_Mass(
               l_acctg_date,
               l_ledger_id,
               l_user_id,
               l_request_id,
               P_bt_code,
               l_count,
               l_primary_accounting_method,
               l_current_calling_sequence);
    --
    l_total  := nvl(l_count,0) + l_total;
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                           'Total Non-Discount Records Inserted into FA Temp Table: '
                            ||TO_CHAR(l_total));
    END IF;
    --
    l_debug_info := 'Calling Project API for Inserting PA Adjustments';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --

    PA_MASS_ADDITIONS_CREATE_PKG.Insert_Mass(
      p_api_version     => 1.0,
      p_init_msg_list   => FND_API.G_TRUE,
      p_commit          => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      x_return_status   => l_pa_return_status,
      x_msg_count       => l_pa_msg_count,
      x_msg_data        => l_pa_msg_data,
      x_count           => l_count1,
      p_acctg_date      => l_acctg_date,
      p_ledger_id       => l_ledger_id,
      p_user_id         => l_user_id,
      p_request_id      => l_request_id,
      p_bt_code         => P_bt_code,
      p_primary_accounting_method => l_primary_accounting_method,
      p_calling_sequence => 'Oracle Payables Mass Addition Process');
    --
    IF l_pa_return_status = FND_API.G_RET_STS_SUCCESS THEN
    --
      l_total1 := l_total + nvl(l_count1, 0);
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                           'Total Non-Discount Records Inserted into FA Temp Table '
                            ||'including PA Adjustment Lines: '
                            ||TO_CHAR(l_total1));
      END IF;

    ELSE
    --
      l_total1 := l_total;
      IF (NVL(l_pa_msg_count, 0) > 1) THEN
        FOR I IN 1..l_pa_msg_count
        LOOP
          l_pa_error_msg := FND_MSG_PUB.Get(p_msg_index => I,
                                         p_encoded   => 'T');
          FND_MESSAGE.Set_Encoded(l_pa_error_msg);
        END LOOP;
      END IF;
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'PA_API_ERROR');
      END IF;
      --
    END IF;

    --
    l_debug_info := ' Calling Insert_Discount';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    Insert_Discount(
                l_acctg_date,
                l_ledger_id,
                l_user_id,
                l_request_id,
                P_bt_code,
                l_count,
                l_current_calling_sequence);
    --
    l_total := nvl(l_count,0);
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                           'Total Discount Records Inserted into FA Temp Table: '
                            ||TO_CHAR(l_total));
    END IF;
    --
    l_debug_info := 'Calling Project API for Inserting PA Discount Adjustments';
    --
    PA_MASS_ADDITIONS_CREATE_PKG.Insert_Discounts(
      p_api_version     => 1.0,
      p_init_msg_list   => FND_API.G_TRUE,
      p_commit          => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      x_return_status   => l_pa_return_status,
      x_msg_count       => l_pa_msg_count,
      x_msg_data        => l_pa_msg_data,
      x_count           => l_count1,
      p_acctg_date      => l_acctg_date,
      p_ledger_id       => l_ledger_id,
      p_user_id         => l_user_id,
      p_request_id      => l_request_id,
      p_bt_code         => P_bt_code,
      p_primary_accounting_method => l_primary_accounting_method,
      p_calling_sequence => 'Oracle Payables Mass Addition Process');
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    IF l_pa_return_status = FND_API.G_RET_STS_SUCCESS THEN
    --
      l_total  :=  l_total + nvl(l_count1,0);
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                           'Total Discount Records Inserted into FA Temp Table '
                            ||'including PA Adjustment Lines: '
                            ||TO_CHAR(l_total));
      END IF;

    ELSE
    --
      IF (NVL(l_pa_msg_count, 0) > 1) THEN
        FOR I IN 1..l_pa_msg_count
        LOOP
          l_pa_error_msg := FND_MSG_PUB.Get(p_msg_index => I,
                                         p_encoded   => 'T');
          FND_MESSAGE.Set_Encoded(l_pa_error_msg);
        END LOOP;
      END IF;
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'PA_API_ERROR');
      END IF;
      --
    END IF;


    l_total1 := l_total1 + l_total;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                           'Grand Total of  Records Inserted into FA Temp Table: '
                            ||TO_CHAR(l_total1));
    END IF;
    --
    l_debug_info := 'Calling FA API for inserting Discount Assets ';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    -- Some Discount record is inserted
    IF l_total1 > 0 THEN -- bug 9001504
      --
      FA_MASSADD_CREATE_PKG.Create_Lines (
         p_book_type_code  => P_bt_code,
         p_api_version     => 1.0,
         p_init_msg_list   => FND_API.G_TRUE,
         p_commit          => FND_API.G_FALSE,
         p_validation_level => FND_API.G_VALID_LEVEL_FULL,
         p_calling_fn      => 'Oracle Payables.'||l_api_name,
         x_return_status   => l_return_status,
         x_msg_count       => l_msg_count,
         x_msg_data        => l_msg_data );

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
-- bug 9001504
        l_debug_info  := 'Update Invoice Distributions which are transferred to Asset ';
        --
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        --
        MERGE INTO ap_invoice_distributions_all apid
        USING fa_mass_additions_gt fmag
          ON (apid.invoice_distribution_id = fmag.invoice_distribution_id
          AND fmag.line_status = 'PROCESSED'
          AND fmag.ledger_id = l_ledger_id
          AND fmag.line_type_lookup_code <> 'DISCOUNT')
        WHEN MATCHED THEN UPDATE SET apid.assets_addition_flag = 'Y',
              apid.program_update_date = sysdate,
              apid.program_application_id = fnd_global.prog_appl_id,
              apid.program_id = fnd_global.conc_program_id,
              apid.request_id = fnd_global.conc_request_id,
              apid.asset_book_type_code = fmag.book_type_code;
        --
        l_count := SQL%ROWCOUNT;
        --
        MERGE INTO ap_self_assessed_tax_dist_all apid
        USING fa_mass_additions_gt fmag
          ON (apid.invoice_distribution_id = fmag.invoice_distribution_id
          AND fmag.line_status = 'PROCESSED'
          AND fmag.ledger_id = l_ledger_id
          AND fmag.line_type_lookup_code <> 'DISCOUNT')
        WHEN MATCHED THEN UPDATE SET apid.assets_addition_flag = 'Y',
              apid.program_update_date = sysdate,
              apid.program_application_id = fnd_global.prog_appl_id,
              apid.program_id = fnd_global.conc_program_id,
              apid.request_id = fnd_global.conc_request_id,
              apid.asset_book_type_code = fmag.book_type_code;

        l_debug_info  := 'Update Invoice Distributions which are not transferred to Asset ';
        --
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        --
        UPDATE  ap_invoice_distributions_all APID
        SET     APID.assets_addition_flag = 'N',
              APID.program_update_date = SYSDATE,
              APID.program_application_id = FND_GLOBAL.prog_appl_id,
              APID.program_id = FND_GLOBAL.conc_program_id,
              APID.request_id = FND_GLOBAL.conc_request_id,
              APID.asset_book_type_code = P_bt_code
        WHERE   APID.invoice_distribution_id IN
              (SELECT  FMAG.invoice_distribution_id
                 FROM  fa_mass_additions_gt FMAG
                WHERE  FMAG.line_status  = 'REJECTED'
                  AND  FMAG.ledger_id = l_ledger_id
                  AND  fmag.line_type_lookup_code <> 'DISCOUNT')
        AND     APID.assets_addition_flag = 'U';
        --
        l_count := SQL%ROWCOUNT;
        --
        UPDATE  ap_self_assessed_tax_dist_all APID
        SET     APID.assets_addition_flag = 'N',
              APID.program_update_date = SYSDATE,
              APID.program_application_id = FND_GLOBAL.prog_appl_id,
              APID.program_id = FND_GLOBAL.conc_program_id,
              APID.request_id = FND_GLOBAL.conc_request_id,
              APID.asset_book_type_code = P_bt_code
        WHERE   APID.invoice_distribution_id IN
              (SELECT  FMAG.invoice_distribution_id
                 FROM  fa_mass_additions_gt FMAG
                WHERE  FMAG.line_status  = 'REJECTED'
                  AND  FMAG.ledger_id = l_ledger_id
                  AND  fmag.line_type_lookup_code <> 'DISCOUNT')
        AND     APID.assets_addition_flag = 'U';
        --
-- bug 9001504

        l_debug_info  := 'Update Invoice Payments which are transferred to Asset ';
        --
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        --
        UPDATE ap_invoice_payments_all APIP
        SET    APIP.assets_addition_flag = 'Y'
        WHERE   APIP.assets_addition_flag = 'U'
        AND     APIP.posted_flag = 'Y'
        AND     APIP.set_of_books_id = l_ledger_id
        AND     APIP.invoice_payment_id  IN (
            SELECT    APHD.invoice_payment_id
            FROM      ap_payment_hist_dists    APHD,
                      ap_invoice_distributions_all APID,
                      fa_mass_additions_gt     FMAG
            WHERE     APIP.invoice_payment_id = APHD.invoice_payment_id
            AND       APHD.invoice_distribution_id =
                      APID.invoice_distribution_id
            AND       APID.invoice_distribution_id =
                      FMAG.parent_invoice_dist_id
            AND       FMAG.line_type_lookup_code = 'DISCOUNT'
            AND       FMAG.line_status = 'PROCESSED'
            AND       FMAG.ledger_id = l_ledger_id);
        --
        l_count := SQL%ROWCOUNT;
        --
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                           'No of Invoice Payment Record Updated '
                            ||'after successfully transferred to Asset: '
                            ||TO_CHAR(l_count));
        END IF;
        --
        UPDATE ap_invoice_payments_all APIP
        SET    APIP.assets_addition_flag = 'N'
        WHERE   APIP.assets_addition_flag = 'U'
        AND     APIP.posted_flag = 'Y'
        AND     APIP.set_of_books_id = l_ledger_id
        AND     APIP.invoice_payment_id  IN (
            SELECT    APHD.invoice_payment_id
            FROM      ap_payment_hist_dists    APHD,
                      ap_invoice_distributions_all APID,
                      fa_mass_additions_gt     FMAG
            WHERE     APIP.invoice_payment_id = APHD.invoice_payment_id
            AND       APHD.invoice_distribution_id =
                      APID.invoice_distribution_id
            AND       APID.invoice_distribution_id =
                      FMAG.parent_invoice_dist_id
            AND       FMAG.line_status = 'REJECTED'
            AND       FMAG.line_type_lookup_code = 'DISCOUNT'
            AND       FMAG.ledger_id = l_ledger_id);
        --
        l_count := SQL%ROWCOUNT;
        --
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                           'No of Invoice Payment Record Updated '
                            ||'after failed to transfer to Asset: '
                            ||TO_CHAR(l_count));
        END IF;
        --
        l_debug_info  := 'Update PA Adjustments which are processed
                          or rejected by FA API ';
        --
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        --
        PA_MASS_ADDITIONS_CREATE_PKG.Update_Mass(
          p_api_version     => 1.0,
          p_init_msg_list   => FND_API.G_TRUE,
          p_commit          => FND_API.G_FALSE,
          p_validation_level => FND_API.G_VALID_LEVEL_FULL,
          x_return_status   => l_pa_return_status,
          x_msg_count       => l_pa_msg_count,
          x_msg_data        => l_pa_msg_data,
          p_request_id      => l_request_id);
        --
        IF l_pa_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        --
          IF (NVL(l_pa_msg_count, 0) > 1) THEN
            FOR I IN 1..l_pa_msg_count
            LOOP
              l_pa_error_msg := FND_MSG_PUB.Get(p_msg_index => I,
                                                p_encoded   => 'T');
              FND_MESSAGE.Set_Encoded(l_pa_error_msg);
            END LOOP;
          END IF;
          --
          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'PA_API_ERROR');
          END IF;
          --
        END IF;

      ELSE

        l_debug_info := 'FA API returned with error';
        --
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        --
        RAISE FA_API_ERROR;

      END IF;
      --
    END IF;  -- Discount record inserted
EXCEPTION
    --
    WHEN FA_API_ERROR THEN
      IF (NVL(l_msg_count, 0) > 1) THEN
        FOR I IN 1..l_msg_count
        LOOP
          l_error_msg := FND_MSG_PUB.Get(p_msg_index => I,
                                         p_encoded   => 'T');
          FND_MESSAGE.Set_Encoded(l_error_msg);
        END LOOP;
      END IF;
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('PARAMETERS','P_acctg_date: '||P_acctg_date
                              ||',P_bt_code: '||P_bt_code);
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'FA_API_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM );
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
        FND_MESSAGE.SET_TOKEN('PARAMETERS','P_acctg_date: '||P_acctg_date
                              ||',P_bt_code: '||P_bt_code);
      END IF;
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
    --
    errbuf := FND_MESSAGE.GET;
    retcode := 2;
    --
END Mass_Additions_Create;
--
END Ap_Mass_Additions_Create_Pkg;

/
