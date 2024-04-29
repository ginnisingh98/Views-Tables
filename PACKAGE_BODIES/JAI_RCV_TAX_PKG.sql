--------------------------------------------------------
--  DDL for Package Body JAI_RCV_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_TAX_PKG" AS
/* $Header: jai_rcv_tax.plb 120.27.12010000.9 2010/02/25 06:25:11 vkaranam ship $ */


PROCEDURE default_taxes_onto_line
  (
      p_transaction_id                NUMBER,
      p_parent_transaction_id         NUMBER,
      p_shipment_header_id            NUMBER,
      p_shipment_line_id              NUMBER,
      p_organization_id               NUMBER,
      p_requisition_line_id           NUMBER,
      p_qty_received                  NUMBER,
      p_primary_quantity              NUMBER,
      p_line_location_id              NUMBER,
      p_transaction_type              VARCHAR2,
      p_source_document_code          VARCHAR2,
      p_destination_type_code         VARCHAR2,
      p_subinventory                  VARCHAR2,
      p_vendor_id                     NUMBER,
      p_vendor_site_id                NUMBER,
      p_po_header_id                  NUMBER,
      p_po_line_id                    NUMBER,
      p_location_id                   NUMBER,
      p_transaction_date              DATE,
      p_uom_code                      VARCHAR2,
      --Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_attribute1                    VARCHAR2,
      --p_attribute2                    DATE,
      --p_attribute3                    VARCHAR2,
      --p_attribute4                    VARCHAR2,
      p_attribute15                   VARCHAR2,
      p_currency_code                 VARCHAR2,
      p_currency_conversion_type      VARCHAR2,
      p_currency_conversion_date      DATE,
      p_currency_conversion_rate      NUMBER,
      p_creation_date                 DATE,
      p_created_by                    NUMBER,
      p_last_update_date              DATE,
      p_last_updated_by               NUMBER,
      p_last_update_login             NUMBER,
      p_unit_of_measure               VARCHAR2,
      p_po_distribution_id            NUMBER,
      p_oe_order_header_id            NUMBER,
      p_oe_order_line_id              NUMBER,
      p_routing_header_id             NUMBER,
      -- Vijay Shankar for Bug#3940588 RECEIPTS DEPLUG
      /* R12-PADDR p_chk_form OUT NOCOPY VARCHAR2, */
      -- Vijay Shankar for Bug#4159557
      p_interface_source_code         VARCHAR2,
      p_interface_transaction_id      VARCHAR2,
      p_allow_tax_change_hook         VARCHAR2
     --Reverted the chnage in R12  p_group_id                      IN NUMBER DEFAULT NULL    /*added by nprashar for bug 8566481*/
  ) IS

    /* Added by Ramananda for bug# exc_objects */
    lv_object_name CONSTANT VARCHAR2(61) := 'jai_rcv_tax_pkg.default_taxes_onto_line';

    -- LAST MODIFIED BY SRIHARI on 25-JUN-2000
    v_receipt_num                 rcv_shipment_headers.receipt_num % TYPE;
    v_loc_quantity                po_line_locations_all.quantity % TYPE;
    v_cor_amount                  JAI_PO_LINE_LOCATIONS.tax_amount % TYPE;
--    v_form_id                     VARCHAR2(30); --File.Sql.35 Cbabu  := 'JAINPORE';
    v_chk_form                    VARCHAR2(30);
    -- v_rowid                       JAI_CMN_LOCATORS_T.row_id % TYPE;
    v_conf                        NUMBER;
    v_receipt_modify_flag         JAI_CMN_INVENTORY_ORGS.receipt_modify_flag % TYPE;
    v_cor_quantity                NUMBER;
    v_rg_location_id              JAI_INV_SUBINV_DTLS.location_id % TYPE;
    v_po_header_date              DATE;
    v_vendor_site_id              po_headers_all.vendor_site_id % TYPE;
    v_item_id                     rcv_shipment_lines.item_id % TYPE;
    v_organization_id             rcv_shipment_lines.to_organization_id % TYPE;
    v_item_modvat_flag            JAI_INV_ITM_SETUPS.modvat_flag % TYPE;
    v_item_trading_flag           JAI_INV_ITM_SETUPS.item_trading_flag % TYPE;
    v_receipt_source_code         rcv_shipment_headers.receipt_source_code % TYPE;
--    v_paddr                       v$session.paddr % TYPE;
  --  v_temp_status                 ja_in_temp_receipt.status % TYPE; --Commented by Nagaraj.s for Bug#2692052
      v_paddr                       RAW(32);  /*Bug 4644524 bduvarag*/
    v_modvat_flag                 JAI_INV_ITM_SETUPS.modvat_flag % TYPE; --Changed the %type by Nagaraj.s for Bug#2692052
    v_tax_total                   NUMBER; --File.Sql.35 Cbabu  := 0;
  --  v_line_id                     so_lines_all.line_id % type; --commented by GSri and Jagdish on 5-may-01
    v_line_id                     oe_order_lines_all.line_id % TYPE; --added by GSri and Jagdish on 5-may-01
    v_rg_type                     VARCHAR2(30);
    v_so_currency                 oe_order_headers_all.transactional_curr_code % TYPE; -- added
    v_req_id                      NUMBER;
    v_result                      BOOLEAN;
    v_currency_code               rcv_transactions.currency_code % TYPE;
    v_currency_conversion_rate    rcv_transactions.currency_conversion_rate % TYPE;
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. v_attribute1                  VARCHAR2(150);
    --v_attribute2                  DATE;
    --v_attribute3                  VARCHAR2(150);
    v_range_no                    JAI_CMN_VENDOR_SITES.excise_duty_range % TYPE;
    v_division_no                 JAI_CMN_VENDOR_SITES.excise_duty_division % TYPE;
    v_claim_modvat_flag           JAI_RCV_LINES.claim_modvat_flag % TYPE;
    v_func_currency               gl_sets_of_books.currency_code % TYPE;
    v_gl_set_of_books_id          gl_sets_of_books.set_of_books_id % TYPE;
    v_conv_factor                 NUMBER;
    v_register_type               JAI_CMN_RG_23AC_I_TRXS.register_type % TYPE;
    v_duplicate_ship              VARCHAR2(1); --File.Sql.35 Cbabu  := 'N';
    v_picking_line_id             JAI_OM_WSH_LINES_ALL.delivery_detail_id % TYPE; --added
    v_rsh_organization_id         rcv_shipment_headers.organization_id % TYPE;
    v_internal_vendor             JAI_CMN_TAXES_ALL.vendor_id % TYPE;
    v_current_tax                 NUMBER;
    v_trading                     JAI_CMN_INVENTORY_ORGS.trading % TYPE;
    v_manufacturing               JAI_CMN_INVENTORY_ORGS.manufacturing % TYPE;
    v_bonded                      JAI_INV_SUBINV_DTLS.bonded % TYPE;
    v_claimable_amount            JAI_RCV_LINE_TAXES.claimable_amount % TYPE;
    -- Start of addition by Srihari on 30-NOV-99
    v_uom_rate                    NUMBER;
    v_po_uom                      mtl_units_of_measure.unit_of_measure % TYPE;
    v_po_uom_code                 mtl_units_of_measure.uom_code % TYPE;
    v_rcv_uom_code                mtl_units_of_measure.unit_of_measure % TYPE;
    v_tax_modvat_flag             JAI_RCV_LINE_TAXES.modvat_flag % TYPE;
    v_chk_excise                  NUMBER;
    v_chk_receipt_lines       NUMBER; --File.Sql.35 Cbabu  :=0;
    v_chk_receipt_tax_lines     NUMBER; --File.Sql.35 Cbabu  :=0;
    --v_receipt_routing             NUMBER; --Added by Nagaraj.s for Bug#2499017
    -- Variables added by Aparajita on 17th june for bug#2415767
    v_po_currency           po_headers_all.CURRENCY_CODE%TYPE;
    v_po_rate           po_headers_all.RATE%TYPE;
    v_tax_currency        po_headers_all.CURRENCY_CODE%TYPE;

    v_precedence_0        NUMBER; --File.Sql.35 Cbabu  :=0;
    v_precedence_non_0      NUMBER; --File.Sql.35 Cbabu :=0;

    v_tax_base          NUMBER; --File.Sql.35 Cbabu :=0;
    v_receipt_tax                 NUMBER; -- this has not been assigned intentionally.
    v_debug_flag          varchar2(1); --File.Sql.35 Cbabu  := 'N';
    v_utl_location               VARCHAR2(512); --For Log file.
    v_myfilehandle                UTL_FILE.FILE_TYPE; -- This is for File handling
      -- Variables added by Aparajita on 17th june for bug#2415767
     --Variables added by Nagaraj.s for Bug2991872.
    v_price_override              NUMBER; --File.Sql.35 Cbabu  :=0;
    v_po_quantity               NUMBER; --File.Sql.35 Cbabu  :=0;
    v_assessable_value          NUMBER; --File.Sql.35 Cbabu  :=0;

    /* Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    ln_vat_assess_value             NUMBER; --File.Sql.35 Cbabu  :=0;
    ln_chk_vat                      number ;
    lv_vat_recoverable_for_item     JAI_RGM_ITM_TMPL_ATTRS.ATTRIBUTE_VALUE%TYPE;
    lv_process_flag                 VARCHAR2(2);
    lv_process_msg                  VARCHAR2(1000);
    ln_vat_setup_chk                NUMBER;
    ln_test_delivery_id             JAI_OM_WSH_LINES_ALL.delivery_id%TYPE; --Added by Ramananda for Bug#4533114
    --Added by walton for inclusive tax
    ---------------------------------------------
    TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE tax_amt_num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    tax_amt_tab         TAX_AMT_NUM_TAB;
    round_factor_tab     TAX_AMT_NUM_TAB;
    base_tax_amt_tab    TAX_AMT_NUM_TAB;
    func_tax_amt_tab    TAX_AMT_NUM_TAB;

    TYPE char_tab IS TABLE OF  VARCHAR2(10)
    INDEX BY BINARY_INTEGER;

    lt_adhoc_tax_tab          CHAR_TAB;
    lt_inclusive_tax_tab      CHAR_TAB;
    lt_tax_modvat_flag        CHAR_TAB;
    lt_third_party_flag       CHAR_TAB;
    ln_exclusive_price        NUMBER;
    lt_tax_rate_per_rupee     NUM_TAB;
    lt_cumul_tax_rate_per_rupee NUM_TAB;
    ln_total_non_rate_tax     NUMBER :=0;
    ln_total_inclusive_factor NUMBER;
    lt_tax_amt_rate_tax_tab   TAX_AMT_NUM_TAB;
    lt_tax_amt_non_rate_tab   TAX_AMT_NUM_TAB;
    ln_bsln_amt_nr            NUMBER :=0;
    ln_tax_amt_nr             NUMBER(38,10) :=0;
    ln_vamt_nr                NUMBER(38,10) :=0;
    ln_total_tax_per_rupee    NUMBER;
    ln_assessable_value       NUMBER;
    ln_vat_assessable_value   NUMBER;
    ln_curflag                NUMBER; --Add by Kevin Cheng for bug 6853787 Mar 5, 2008
    lv_valid_date             DATE;

    p1          NUM_TAB;
    p2          NUM_TAB;
    p3          NUM_TAB;
    p4          NUM_TAB;
    p5          NUM_TAB;

    p6          NUM_TAB;
    p7          NUM_TAB;
    p8          NUM_TAB;
    p9          NUM_TAB;
    p10         NUM_TAB;
    end_date_tab        NUM_TAB;
    tax_rate_tab        NUM_TAB;
    tax_type_tab        NUM_TAB;
    tax_rate_zero_tab   NUM_TAB;
    tax_target_tab      NUM_TAB;

    bsln_amt            NUMBER := 0;
    vamt                NUMBER := 0;
    row_count           NUMBER := 1;
    v_tax_amt           NUMBER := 0;
    max_iter            NUMBER := 10;
    v_func_tax_amt      NUMBER := 0;
    v_amt               NUMBER := 0;

    errormsg VARCHAR2(500);

    cursor c_get_inclusive_flag
    ( pn_tax_id number
    )
    is
    select NVL(inclusive_tax_flag,'N'), end_date
    from jai_cmn_taxes_all
    where tax_id=pn_tax_id;
    -----------------------------------------------

    CURSOR c_rgm_setup_for_orgn_loc(cp_regime_code varchar2, cp_organization_type varchar2,
              cp_organization_id number, cp_location_id number) IS
      SELECT 1 FROM jai_rgm_parties a, JAI_RGM_DEFINITIONS b
      WHERE a.regime_id = b.regime_id
      AND b.regime_code=cp_regime_code
      AND a.organization_type = cp_organization_type
      AND a.organization_id = cp_organization_id
      AND (cp_location_id is null or a.location_id=cp_location_id);

    CURSOR c_rcv_rgm_dtl(cp_regime_code VARCHAR2, cp_shipment_line_id NUMBER) IS
      SELECT nvl(process_status_flag, jai_constants.no) process_status_flag,
            regime_item_class,
            invoice_no
      FROM jai_rcv_rgm_lines
      WHERE shipment_line_id = cp_shipment_line_id
      AND regime_code = cp_regime_code;

    r_rcv_rgm_dtl     c_rcv_rgm_dtl%ROWTYPE;
    /* End of VAT Impl. */

    v_tax_vendor_site_id          JAI_CMN_VENDOR_SITES.vendor_site_id%type; --Added by Nagaraj.s for Bug3037075
    v_third_party_flag            JAI_RCV_LINE_TAXES.third_party_flag%type; --Added by Nagaraj.s for Bug3037075
   --Ends over here.
    v_item_class                  JAI_INV_ITM_SETUPS.item_class%type; --3202319

    CURSOR uom_cur(c_uom VARCHAR2) IS
      SELECT uom_code
        FROM mtl_units_of_measure
       WHERE unit_of_measure = c_uom;
    -- End of addition by Srihari on 30-NOV-99.

  -- Added by GSRI on 21-OCT-01
  CURSOR get_paddr IS SELECT paddr
   FROM v$session vs, v$mystat vm
   WHERE vs.sid = vm.sid
    AND ROWNUM = 1;
  -- End of Addition on 21-OCT-01

    -- cbabu for Bug# 3028040
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. CURSOR c_hdr_attribute5(p_shipment_header_id IN NUMBER) IS
    CURSOR c_hdr_dtl(p_shipment_header_id IN NUMBER) IS
      SELECT  -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. attribute5,
        shipment_num
      FROM rcv_shipment_headers
      WHERE shipment_header_id = p_shipment_header_id;

     --Added by Sanjikum for Bug#4533114
    CURSOR c_hdr_attribute5_1(p_delivery_name VARCHAR2)
    IS
    SELECT  delivery_id
    FROM    wsh_new_deliveries
    WHERE   name = p_delivery_name ;

   CURSOR c_fetch_unclaim_cenvat is
   SELECT nvl(unclaim_cenvat_flag,'N'),
          nvl(cenvat_claimed_ptg,0),
    nvl(non_bonded_delivery_flag,'N'), --3655330
    nvl(cenvat_amount,0) -- Bug 4516678. Added by Lakshmi Gopalsami
   FROM   JAI_RCV_CENVAT_CLAIMS
   WHERE  shipment_line_id = p_shipment_line_id;

  v_unclaim_cenvat_flag      JAI_RCV_CENVAT_CLAIMS.unclaim_cenvat_flag%type;
  v_cenvat_claimed_ptg       JAI_RCV_CENVAT_CLAIMS.cenvat_claimed_ptg%type;
  v_non_bonded_delivery_flag JAI_RCV_CENVAT_CLAIMS.non_bonded_delivery_flag%type;
  -- bug 4516678. Added by Lakshmi Gopalsami
  v_cenvat_amount            JAI_RCV_CENVAT_CLAIMS.cenvat_amount%type;

  v_express VARCHAR2(100);
  v_shipment_num  rcv_shipment_headers.shipment_num%type;  -- ssumaith - bug# 3657662
  v_order_header_id oe_order_headers_all.header_id%type;   -- ssumaith - bug# 3657662

  cursor c_order_cur (p_shipment_num rcv_shipment_headers.shipment_num%type) is
  select order_header_id
  from   JAI_OM_WSH_LINES_ALL
  where  delivery_id = p_shipment_num;

  /* bug 4516678. Added by Lakshmi Gopalsami */

  cursor c_fetch_receive_quantity(p_shipment_header_id number,
                                 p_shipment_line_id number) is
   select qty_received
     from JAI_RCV_LINES
    where shipment_header_id = p_shipment_header_id
      and shipment_line_id   = p_shipment_line_id;

  cursor c_fetch_transaction_quantity(p_shipment_header_id number,
                                      p_shipment_line_id number ,
              p_transaction_type varchar2) is
  select sum(quantity)
    from JAI_RCV_TRANSACTIONS
   where shipment_header_id = p_shipment_header_id
     and shipment_line_id   = p_shipment_line_id
     and transaction_type   = p_transaction_type;

  v_receipt_quantity  number;
  v_sum_rtv_quantity  number;

  -- End for bug4516678.

    /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
    cursor c_ja_rcv_interface(cp_interface_trx_id in number) is
      select interface_transaction_id, excise_invoice_no, excise_invoice_date, online_claim_flag
      from jai_rcv_interface_trxs
      where interface_transaction_id = cp_interface_trx_id;

    r_ja_rcv_interface      c_ja_rcv_interface%ROWTYPE;
    lv_excise_invoice_no    JAI_RCV_LINES.excise_invoice_no%TYPE;
    lv_excise_invoice_date  JAI_RCV_LINES.excise_invoice_date%TYPE;
    lv_online_claim_flag    JAI_RCV_LINES.online_claim_flag%TYPE;

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Defined variable for implementing caching logic.
     */
    l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
    -- End for bug 5243532
    /*Bug 4644524 start bduvarag*/
    CURSOR c_rcv_shipment_lines(cp_shipment_line_id rcv_shipment_lines.shipment_line_id%TYPE)
IS
SELECT  item_id
FROM    rcv_shipment_lines
WHERE   shipment_line_id = cp_shipment_line_id;

r_rcv_shipment_lines c_rcv_shipment_lines%ROWTYPE;
/*Bug 4644524 End bduvarag*/

 -- For iSupp Porting
/*
 || Start additions by ssumaith - Iprocurement.
 */

   CURSOR check_rcpt_source IS
   SELECT apps_source_code
   FROM   po_requisition_headers_all WHERE requisition_header_id IN
  (SELECT requisition_header_id
   FROM   po_requisition_lines_all
   WHERE  line_location_id = p_line_location_id
  );

   lv_apps_source_code  VARCHAR2(30);

 /*
 || End additions by ssumaith - iprocurement
 */



 /*
 start for ASBN -- ssumaith
 */


 cursor  c_check_asbn is
 SELECT  '1' , shipment_num
 from    rcv_shipment_headers
 where   shipment_header_id = p_shipment_header_id
 And     asn_type           = 'ASBN';


 lv_asbn_type  varchar2(10);
 lv_shipment_num  VARCHAR2(100);
 ln_po_unit_price NUMBER;



   TYPE PO_TAX_CUR IS RECORD(
   tax_line_no   JAI_PO_TAXES.TAX_LINE_NO%TYPE,
   Tax_Id          JAI_PO_TAXES.TAX_ID%TYPE,
   Tax_rate        JAI_PO_TAXES.TAX_RATE%TYPE,
   Qty_Rate        JAI_PO_TAXES.QTY_RATE%TYPE,
   Uom             JAI_PO_TAXES.UOM%TYPE,
   Tax_Amount      JAI_PO_TAXES.TAX_AMOUNT%TYPE,
   tax_type        JAI_PO_TAXES.TAX_TYPE%TYPE,
   tax_name        JAI_CMN_TAXES_ALL.TAX_NAME%TYPE,
   modvat_flag     JAI_PO_TAXES.modvat_flag%TYPE,
   vendor_id       JAI_CMN_TAXES_ALL.vendor_id%type,
   tax_vendor_id   JAI_CMN_TAXES_ALL.vendor_id%type,
   vendor_site_id  JAI_CMN_TAXES_ALL.vendor_site_id%type,
   currency        JAI_PO_TAXES.currency%type,
   rounding_factor JAI_CMN_TAXES_ALL.rounding_factor%type,
   duty            JAI_CMN_TAXES_ALL.duty_drawback_percentage%type,
   Precedence_1   JAI_PO_TAXES.PRECEDENCE_1%TYPE,
   Precedence_2   JAI_PO_TAXES.PRECEDENCE_2%TYPE,
   Precedence_3   JAI_PO_TAXES.PRECEDENCE_3%TYPE,
   Precedence_4   JAI_PO_TAXES.PRECEDENCE_4%TYPE,
   Precedence_5   JAI_PO_TAXES.PRECEDENCE_5%TYPE,
   regime_code    varchar2(30),
   Precedence_6   JAI_PO_TAXES.PRECEDENCE_6%TYPE,
   Precedence_7   JAI_PO_TAXES.PRECEDENCE_7%TYPE,
   Precedence_8   JAI_PO_TAXES.PRECEDENCE_8%TYPE,
   Precedence_9   JAI_PO_TAXES.PRECEDENCE_9%TYPE,
   Precedence_10    JAI_PO_TAXES.PRECEDENCE_10%TYPE
   );
   TYPE tax_cur_type IS REF CURSOR RETURN PO_TAX_CUR;
   c_po_tax_cur TAX_CUR_TYPE;
   po_lines_rec     c_po_tax_cur%rowtype;
   --Added by walton for inclusive tax
   ---------------------------------------
   type tax_table_typ  is
   table of PO_TAX_CUR index by binary_integer;
   lt_tax_table     tax_table_typ;
   -----------------------------------------
 -- end ssumaith - asbn

 -- rchandan start - 6030615(INTERORG_XFER FP )

       Cursor c_rec_ship_txn(cp_ship_line_id IN NUMBER) is
       select  mmt_transaction_id
       from    rcv_shipment_lines
       where   shipment_line_id = cp_ship_line_id;

       r_rec_ship_txn c_rec_ship_txn%rowtype;

       cursor  c_get_inv_trx_info(Cp_transaction_id IN NUMBER) IS
       select  abs(transaction_quantity) , transaction_uom , original_transaction_temp_id , prior_cost
       from    mtl_material_transactions
       where   transaction_id = cp_transaction_id ;

       cursor  c_jai_mtl_Trxs(cp_trx_temp_id NUMBER) IS
       select  *
       from    jai_mtl_trxs
       where   transaction_temp_id = cp_trx_temp_id;

       r_jai_mtl_Trxs   c_jai_mtl_Trxs%rowtype;

       cursor c_jai_cmn_lines(cp_shipment_num VARCHAR2) IS
       SELECT *
       FROM   jai_cmn_lines
       WHERE  po_line_location_id = p_line_location_id
       AND    shipment_number = cp_shipment_num;

       r_jai_cmn_lines  c_jai_cmn_lines%rowtype;

       ln_trx_qty   number;
       lv_trx_uom   varchar2(20);
       ln_orig_id   number;
       ln_item_cost number;

   -- rchandan end - 6030615(INTERORG_XFER FP )

    --------------------------- Procedure For inserting a record in JAI_RCV_LINES ---------
    PROCEDURE insert_receipt_line IS

      lv_mfg_trading JAI_RCV_LINES.mfg_trading%type ;
    BEGIN

  --Added by GSRI on 21-OCT-01
  SELECT COUNT(*) INTO v_chk_receipt_lines
  FROM JAI_RCV_LINES
  WHERE shipment_line_id = p_shipment_line_id AND
  shipment_header_id = p_shipment_header_id;
  IF v_chk_receipt_lines = 0 THEN
  /*DELETE FROM JAI_RCV_LINES
  WHERE shipment_line_id = p_shipment_line_id AND
  shipment_header_id = p_shipment_header_id;*/
  --End Addition by GSRI on 21-OCT-01

  lv_mfg_trading := NVL(v_manufacturing, 'N')|| NVL(v_trading, 'N') ; -- Removed minus sign (-) for bug#4519697

      INSERT INTO JAI_RCV_LINES
             (shipment_line_id,
              shipment_header_id,
              receipt_num,
              qty_received,
              boe_number,
              excise_invoice_no,
              excise_invoice_date,
              online_claim_flag, -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
              tax_modified_flag,
              line_location_id,
              tax_amount,
              MFG_TRADING,
              transaction_id, --Added by Nagaraj.s for Bug#2692052.
              organization_id,--Added by Nagaraj.s for Bug#2692052.
              inventory_item_id, -- added by Aparajita for Bug#2813244
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login)
      VALUES (p_shipment_line_id,
              p_shipment_header_id,
              v_receipt_num,
              p_qty_received,
              NULL,
              -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. v_attribute1,
              -- v_attribute2,
              lv_excise_invoice_no,
              lv_excise_invoice_date,
              lv_online_claim_flag,
             'Y',-- v_receipt_modify_flag,added 'Y' for bug#9045278
              p_line_location_id,
              NULL,
              lv_mfg_trading, --NVL(v_manufacturing, 'N')||NVL(v_trading, 'N'),     /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
              p_transaction_id,  --Added by Nagaraj.s for Bug#2692052.
              p_organization_id, --Added by Nagaraj.s for Bug#2692052. This is made as per RCV_TRANSACTIONS.ORGANIZATION_ID so that Joins can be avoided with RCV_TRANSACTIONS
              v_item_id,-- added by Aparajita for Bug#2813244
              p_creation_date,
              p_created_by,
              p_last_update_date,
              p_last_updated_by,
              p_last_update_login);
  END IF;
END insert_receipt_line;

    --------------------------- Procedure For updating tax amount in JAI_RCV_LINES --------
    PROCEDURE update_receipt_line IS
    BEGIN
      IF v_tax_total <> 0
      THEN
        UPDATE JAI_RCV_LINES
           SET tax_amount = v_tax_total
         WHERE shipment_line_id = p_shipment_line_id;
      END IF;
    END update_receipt_line;

    ------------------------------ For picking po_header_date from po_headers -------------------
    /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
    PROCEDURE pick_po_header_date IS
    BEGIN
      FOR date_rec IN (SELECT creation_date,
                              vendor_site_id
                         FROM po_headers_all
                        WHERE po_header_id = p_po_header_id)
      LOOP
        v_po_header_date := date_rec.creation_date;
        v_vendor_site_id := date_rec.vendor_site_id;
      END LOOP;
      jai_rcv_utils_pkg.get_div_range(p_vendor_id,
                                          v_vendor_site_id,
                                          v_range_no,
                                          v_division_no);
    END pick_po_header_date;
    */

    ------------------ Procedure For updating tax amount in case of internal order ---------------
    PROCEDURE duplicate_shipment_update IS
    BEGIN
      IF p_transaction_type = 'RECEIVE'
      THEN
        FOR conf_rec IN (SELECT shipment_line_id,
                                qty_received
                           FROM JAI_RCV_LINES
                          WHERE shipment_line_id = p_shipment_line_id)
        LOOP
          v_conf := conf_rec.shipment_line_id;
          IF NVL(conf_rec.qty_received, 0) <> 0
          THEN
            v_cor_quantity := 1 + (p_qty_received / conf_rec.qty_received);
          END IF;
        END LOOP;
        IF v_conf IS NOT NULL
        THEN
          v_duplicate_ship := 'Y';
          FOR lines_rec IN (SELECT rtl.tax_amount,
                                   rtl.tax_type,
                                   rtl.tax_line_no,
                                   jtc.rounding_factor
                              FROM JAI_RCV_LINE_TAXES rtl,
                                   JAI_CMN_TAXES_ALL jtc
                             WHERE rtl.shipment_line_id = p_shipment_line_id
                               AND jtc.tax_id = rtl.tax_id)
          LOOP
            v_current_tax := ROUND((lines_rec.tax_amount * v_cor_quantity),
                             NVL(lines_rec.rounding_factor, 0));
            UPDATE JAI_RCV_LINE_TAXES
               SET tax_amount = v_current_tax
             WHERE shipment_line_id = p_shipment_line_id
               AND tax_line_no = lines_rec.tax_line_no;
            IF lines_rec.tax_type NOT IN ('TDS', 'Modvat Recovery')
            THEN
              v_tax_total := NVL(v_tax_total, 0) + NVL(v_current_tax, 0);
            END IF;
          END LOOP;
          UPDATE JAI_RCV_LINES
             SET qty_received = NVL(qty_received, 0) + p_qty_received,
                 tax_amount = v_tax_total
           WHERE shipment_line_id = p_shipment_line_id;
        END IF;
      END IF;
    END duplicate_shipment_update;

    ---------------------------------  rg i entry -----------------------------------------------
    /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
    PROCEDURE rg23_i_entry IS
    BEGIN
      Ja_In_Receipt_Rg_Pkg.rg23_i_entry (p_shipment_line_id,
                                         p_location_id,
                                         p_subinventory,
                                         p_vendor_id,
                                         p_vendor_site_id,
                                         p_po_header_id,
                                         p_created_by,
                                         p_creation_date,
                                         p_last_update_date,
                                         p_last_updated_by,
                                         p_last_update_login,
                                         p_qty_received,
                                         p_transaction_id,
                                         p_transaction_type,
                                         p_transaction_date,
                                         p_po_line_id,
                                         p_line_location_id,
                                         v_attribute1,
                                         v_attribute2,
                                         p_uom_code,
                                         p_primary_quantity,
                                         v_rg_type);
    END rg23_i_entry;
    */
    --------------------------------- Deciding tax modified flag --------------------------------
    PROCEDURE set_receipt_flag IS

      /* Start Vijay Shankar for Bug#4199929 */
      lv_tax_change_on_roi_recpts     JAI_CMN_INVENTORY_ORGS.tax_change_on_open_int_recpts%TYPE;
      lv_tax_change_on_wms_recpts     JAI_CMN_INVENTORY_ORGS.tax_change_on_wms_recpts%TYPE;
      /*lv_mobile_txn_flag              rcv_transactions_interface.mobile_txn%TYPE;
        above declaration fails incase client has a lower BASE VERSION like 11.5.5
        So modified as below so that the procedure gets compiled. 4252036(4245089)
      */
      lv_mobile_txn_flag              VARCHAR2(2);
      lv_open_interace_receipt_flag   rcv_transactions_interface.validation_flag%TYPE;
      lv_dynamic_sql                  VARCHAR2(1000);
    lv_profile_val                  VARCHAR2(10);

      CURSOR c_interface_trx_dtl(cp_interface_transaction_id IN NUMBER) IS
        /*cursor query changed for bug 8486273 - on successful import, rows will be deleted
        * from rcv_transactions_interface. We should check rcv_headers_interface table instead,
        * where data would be retained until being purged. It should be noted that the group_id
        * link between rcv_transactions and rcv_headers_interface is not one-one, but it is enough
        * to establish that the receipt is imported through open interface.
        bug 8594501 - earlier query caused mutating table error, as it hit the rcv_transactions
        * table for the same row which triggered this procedure (not committed yet). For this,
        * group_id is being passed as a procedure parameter from the trigger.*/
        /* Code added from the above bugs needs to be Reverted as they are not supported in R12*/
       --SELECT nvl(validation_flag, 'N') validation_flag     commented by Vijay Shankar for bug#4240265
        SELECT decode(header_interface_id, null, 'N', 'Y') imported_receipt_flag
        FROM rcv_transactions_interface
        WHERE interface_transaction_id = cp_interface_transaction_id;
        /*End Vijay Shankar for Bug#4199929 */
      /* Reverted the change in R12 Query added by nprashar for bug # 8566481
      SELECT 'Y'
      FROM dual
      WHERE EXISTS (SELECT 1
                  FROM RCV_HEADERS_INTERFACE RHI
      WHERE RHI.group_id = p_group_id);*/

       CURSOR c_iproc_profile IS
       SELECT fnd_profile.value('JA_ACCESS_IPROC_TAX')
       FROM   DUAL;

       ln_user_id  NUMBER := fnd_global.user_id;


    BEGIN
      jai_rcv_utils_pkg.get_rg1_location (p_location_id,
                                              p_organization_id,
                                              p_subinventory,
                                              v_rg_location_id);
      FOR rec_upd_rec IN (SELECT  nvl(receipt_modify_flag, 'N') receipt_modify_flag,
                                  nvl(trading, 'N') trading,
                                  nvl(manufacturing, 'N') manufacturing
                                  /* following added by Vijay Shankar for Bug#4199929 */
                                  , nvl(tax_change_on_open_int_recpts, 'N') tax_change_on_open_int_recpts
                                  , nvl(tax_change_on_wms_recpts, 'N')      tax_change_on_wms_recpts
                          FROM  JAI_CMN_INVENTORY_ORGS
                          WHERE organization_id = p_organization_id
                          AND   location_id = v_rg_location_id)
      LOOP
        v_receipt_modify_flag := rec_upd_rec.receipt_modify_flag;
        v_trading := rec_upd_rec.trading;
        v_manufacturing := rec_upd_rec.manufacturing;
        /* following added by Vijay Shankar for Bug#4199929 */
        lv_tax_change_on_roi_recpts := rec_upd_rec.tax_change_on_open_int_recpts;
        lv_tax_change_on_wms_recpts := rec_upd_rec.tax_change_on_wms_recpts;
      END LOOP;

      /* Start, Vijay Shankar for Bug#4199929 */
      /* following is written to give control to clients so that for open interface receipts the value returned is 'Y' */
      lv_dynamic_sql := 'select nvl(mobile_txn, ''N'') mobile_txn FROM rcv_transactions_interface WHERE interface_transaction_id = :1';
      BEGIN
        execute immediate lv_dynamic_sql into lv_mobile_txn_flag using p_interface_transaction_id;
      EXCEPTION
        WHEN OTHERS THEN
          lv_mobile_txn_flag := 'N';
      END;

      OPEN c_interface_trx_dtl(p_interface_transaction_id);
      FETCH c_interface_trx_dtl INTO lv_open_interace_receipt_flag;
      CLOSE c_interface_trx_dtl;

      OPEN  c_iproc_profile;
      FETCH c_iproc_profile INTO lv_profile_val;
      CLOSE c_iproc_profile;

      IF v_debug_flag = 'Y' THEN
        UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of lv_profile_val (profile value) is ' || lv_profile_val);
      END IF;

      lv_profile_val := fnd_profile.value_specific(NAME =>'JA_ACCESS_IPROC_TAX',user_id=>ln_user_id);

      IF v_debug_flag = 'Y' THEN
        UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of lv_profile_val (for userid) is ' || lv_profile_val);
      END IF;

      IF NVL(lv_profile_val,'2') = '2' Then
         lv_profile_val := 'N';
      ELSE
         lv_profile_val :='Y';
      END IF;

      IF v_debug_flag = 'Y' THEN
        UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of lv_profile_val (as Y/N) is ' || lv_profile_val);
      END IF;

      FND_FILE.put_line(fnd_file.log, 'ROI:'|| lv_tax_change_on_roi_recpts
        ||', WMS:'||lv_tax_change_on_wms_recpts
        ||', Receipts:'||v_receipt_modify_flag
        ||', TxnROI Flg:'||lv_open_interace_receipt_flag
        ||', TxnMobile Flg:'||lv_mobile_txn_flag
      );

      /* following if condition is for WMS Receipts */
      IF lv_mobile_txn_flag = 'Y' THEN
        IF lv_tax_change_on_wms_recpts = 'Y' THEN
          v_receipt_modify_flag := 'Y';
        ELSE
          --v_receipt_modify_flag := 'X';
          --commented the above and added the below by Ramananda for Bug#4519697
          v_receipt_modify_flag := 'N';
        END IF;

        IF v_debug_flag = 'Y' THEN
           UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_receipt_modify_flag after WMS Receipts loop is ' || v_receipt_modify_flag);
        END IF;

      /* following if condition is for Open Interface Receipts */
      ELSIF lv_open_interace_receipt_flag = 'Y' THEN
        IF lv_tax_change_on_roi_recpts = 'Y' THEN
          v_receipt_modify_flag := 'Y';
        ELSE
          --v_receipt_modify_flag := 'X';
          --commented the above and added the below by Ramananda for Bug#4519697
          v_receipt_modify_flag := 'N';
        END IF;

        IF v_debug_flag = 'Y' THEN
          UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_receipt_modify_flag after Open Interface Receipts loop is ' || v_receipt_modify_flag);
        END IF;

      ELSE

        IF v_receipt_modify_flag = 'N' THEN
          -- added, CSahoo for Bug 5344225
         -- iSupplier Porting
             /*
             || Start additions by ssumaith for Iprocurement.
             */
            IF lv_apps_source_code = 'POR' AND p_transaction_type = 'RECEIVE'
              AND lv_profile_val = 'N' then
               /* Rcpt Created thru Iproc and user does not have change the taxes on rcpt
               || In such a case setting the receipt_modify_flag to 'N'
               */
               v_receipt_modify_flag := 'N';

            END IF;
            /*
            || End additions by ssumaith - Iprocurement.
            */
         -- iSupplier Porting
       -- v_receipt_modify_flag := 'N';
       /* added by csahoo for bug#6209911 */
             IF v_trading = 'Y' THEN
    v_receipt_modify_flag := 'Y';
       END IF;
        ELSE
           /*
           || Start additions by ssumaith for Iprocurement.
           || user did not navigate from the receipts localised form because
           || the rcpt was created from iproc and user has right to change the taxes
           */

           IF lv_apps_source_code = 'POR' AND p_transaction_type = 'RECEIVE'
           THEN
              IF lv_profile_val = 'Y' then
                 /* iSupplier Porting
                 || End additions by ssumaith - Iprocurement.
                 */
                 v_receipt_modify_flag := 'Y';
              ELSE
                 v_receipt_modify_flag := 'N';
              END IF;
           END IF;
           /* iSupplier Porting
           || End additions by ssumaith - Iprocurement.
           */

          /* R12-PADDR
          IF v_chk_form IS NOT NULL THEN
            v_receipt_modify_flag := 'Y';
          ELSE
            v_receipt_modify_flag := 'N';
          END IF;
           R12-PADDR  */
--          v_receipt_modify_flag := 'Y';
        END IF;

      END IF;
      /* END, Vijay Shankar for Bug#4199929 */

      FND_FILE.put_line(fnd_file.log, 'Final ReceiptModifyFlag:'||v_receipt_modify_flag);

      /* following is commented by Vijay Shankar for Bug#4159557
      Added by Nagaraj.s for Bug2915829.
      IF v_receipt_modify_flag ='N' THEN
        v_receipt_modify_flag :='X'; --To Indicate that the Flag Value is to be Processed.
      END IF;
      */

    END set_receipt_flag;

    ---------------------------------------------------------------------------
     PROCEDURE pick_register_type (p_organization_id number,
                                  p_item_id number,
                                  p_register_type out nocopy varchar2) IS
      v_register_type    JAI_CMN_RG_23AC_I_TRXS.register_type % TYPE;
      v_item_class       JAI_INV_ITM_SETUPS.item_class % type;
    BEGIN
      For reg_rec IN (SELECT item_class
                        FROM JAI_INV_ITM_SETUPS
                       WHERE organization_id = p_organization_id
                         AND inventory_item_id = p_item_id)
      LOOP
        v_item_class := reg_rec.item_class;
      END LOOP;
      IF v_item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX','FGIN','FGEX')
      THEN
        v_register_type := 'A';
      ELSIF v_item_class IN ('CGIN', 'CGEX')
      THEN
        v_register_type := 'C';

      END IF;
      p_register_type := v_register_type;
  END pick_register_type;
    ---------------------------------------------------------------------------

  /* *****************************     MAIN BEGIN ***************************** */

  BEGIN
  /*----------------------------------------------------------------------------------------------------------------------
   FILENAME: ja_in_receipts_p.sql
   CHANGE HISTORY:

  S.No      Date          Author and Details
  -----------------------------------------------------------------------------------------------------------------------
  1       17/06/02        Changed by Nagaraj.s on 17/06/2002 for Bug#2417290...............
                          Previously the Coding was- AND sla.orig_sys_line_ref = prla.line_num)
                          Changed Coding is AND sla.orig_sys_line_ref = to_char(prla.line_num))
                          Since the LHS of the expression was a varchar2 and Right Hand side of the Expression was a Number.
                          Hence the Invalid Number exception would occur when sla.orig_sys_line_ref is not a number........
                          Hence the RHS of the expression is also converted into To_Char before the comparison is made.


  2.      18/06/2002      Aparajita for bug 2415767
                          When currency conversion rate is changes at receipt level from the rate defined at PO,
                          all the taxes that are with precedences need to be recalculated as the tax amount changes.
                          Added the code for recalculation of receipt tax in such situation.

  3.      22/07/2002      Additional documentation for bug # 2415767 by Aparajita on 22/07/2002.
                          This procedure is dependent on the modified structure of table JA_IN_TEMP_RECEIPT. Ensure that
                          SHIPMENT_HEADER_ID  NUMBER (15) and
                          PROCESS_FLAG        VARCHAR2 (1)
                          columns are present in the table  JA_IN_TEMP_RECEIPT in the client instance.

  4.      18/08/2002      In Case of an Direct Delivery, the receipt_routing column in Purchase Order
                          is stored with an Value of 3. The For Passing Accounting Entries will fire
                          and takes care of receiving and delivery entries and hence it is
                          necessary that, the to handle Deliver RTR RTV should not fire
                          when it is a direct delivery and this is handled with the condition(V_RECEIPT_ROUTING<>3)
                          and To handle Deliver RTR RTV should fire only in case
                          of standard and inspection routing(Receipt_routing is 1 or 2).

  5.      21/08/2002      Changed by Sriram for Bug # 2514719 .  In the procedure , changed the else condition that was the else for RMA
                          Because of the Else , if an internal sales order cycle is done , the control flows into the
                          else ,which should happen only in case of a PO cycle. Hence the else was replaced by
                          elsif with PO

  6.      23/08/2002      Changed by Nagaraj.s for Bug#2525910
                          Incorporated an parameter P_ROUTING_HEADER_ID which is referred to before the
                          concurrent call for To Handle Deliver RTR RTV. Also removed the cursor get_receipt_routing
                          as this is referred in parameters and there is no need to fetch the same.


  7       27/08/2002      Changed by Nagaraj.s for Bug2531667
                          The condition for fetching UOM has been incorporated with one more "and" condition
                          AND pla.po_line_id   = p_po_line_id
                          which gets the UOM for that PO Line as previously the join was not proper and hence
                          the UOM conversion was having a value of zero which resulted in tax amounts being
                          calculated as zero.

  8       25/09/2002      Changed by Nagaraj.s for Bug2588096
                          In case of an Unordered Receipt, there was a call to rg23_part_i_entry procedure
                          which in turn makes a call to ja_in_receipt_rg_pkg which had a select statement
                          from RCV_Transactions, which resulted in Mutation Error. Also, according to the URM
                          no RG Entries should happen at the point of Unordered Receipts and hence the coding
                          which was previously calling rg23_part_i_entry is commented and this has resulted in
                          Mutation Trigger being avoided. And also the same coding has been written in
                          the case where Transaction Type is Match. And also previously Tax Lines were inserted
                          for source_document_code='PO' but this can also go into an error as in case of UNORDERED
                          receipt, source_document_code will be PO, but Transaction Type will be Unordered and hence
                          this condition is also incorporated.

  9.      21/11/2002      Changed by Nagaraj.s for Bug # 2659628  Version - 615.8
                          Receipt Taxes are recalculated irrespective of whether
                          there is a currency change or not so that rounding does
                          not happen on the higher side in both PO and Receipt.


  10.    04/03/2003        By Nagaraj.s           Version - 615.9

                          1. For Bug # 2692052
                             Commented the calls to ja_in_temp_receipt
                             Changed the calls to "TO HANDLE DELIVER RTR RTV"
                             Changed the Insert of JAI_RCV_LINES with 2 columns ( organization_id,transaction_id).

                          2. For Bug # 2808110
                             Added an Order by Clause in the Fetching
                             of Tax related Information from JAI_PO_TAXES
                             as this is very critical in the Precedence Logic Incorporated.

                          3. For Bug # 2798999 - Generic Fix for the One Off Patch.
                             Added the call to jai_rcv_utils_pkg.get_organization_id
                             to ensure that Organization Id and Item Id is picked up as this
                             is critical in INV_CONVERT.INV_UM_CONVERSION to calculate the UOM
                             Rate.

  11.    10/03/2003       Aparajita for bug # 2813244. Version 615.11

                          For 'INTERNAL SALES ORDER', if the requisition has lines in uom other than the primary uom, then after the shipment when receipt is made in the destination organization, the taxes are not getting calculated properly.

                          The reason was that the uom conversion was as follows,
                          - uom from requisition and quantity from delivery
                          - uom from receipt and quanitity from receipt.

                          The quantity in delivery is always in primary uom where as the requisition is not in primary uom. The apportionment was hence going wrong.

                          Version 615.10 is obsoleted as wrong file was checked in.

  12.    22/03/2003       Nagaraj.s for Bug # 2915829. Version : 615.12

                          The Tax Modified Flag is set through set_receipt_flag Procedure.
                          This is changed to populate the value as 'X' in case it is 'N'.

                          Hence Now the Tax Modified Flag will have 3 possible Values.

                          1. 'Y' - Which Indicates that Taxes can be changed at Receipt Level.
                             This Value will Invoke For Passing Accounting Entries Program

                          2. 'N' - Which Indicates that Taxes can no longer be changed at Receipt Level.
                             This Value will ensure that For Passing Accounting Entries will not be Invoked.

                          3. 'X' - Which Indicates that Taxes cannot be changed at Receipt Level,
                             But still this Ensures that For Passing Accounting Entries Program is Invoked
                             on Closing the Receipts Localized screen.

                          Hence, For Passing Accounting Entries Concurrent gets Invoked as Long as this Flag
                          has an value of 'X' or 'Y'. And For Passing Procedure Updates this to 'N' after
                          Processing. This Prevents Invoking of For Passing Accounting Entries Concurrent
                          Multiple Times.

   13.    02/05/2003      Aparajita for bug # 2929171. Version#615.13
                          Taxes were not getting calculated properly when,
                          - uom is changed at receipt
                          - taxes have non zero precedences, that is tax on tax.

                          The problem was because of uom conversion being applied to non zero precedence taxes.
                          The tax lines are always calculated in the order of tax line number. When uom is changed,
                          only the tax precedence 0 undergoes the change. This conversion should not be applied to
                          precedence 1 as, when tax line 1 was calculated, that is already taken care of.

  14.     08/05/2003      Nagaraj.s for Bug#2915783. Version#615.14
                          The Initialization of v_item_modvat_flag and v_item_trading_flag was not done at the
                          proper place as a result of which Modvat_flag of JAI_RCV_LINE_TAXES
                          was not populated properly. This has been moved to a location which is proper,
                          so that Proper comparison happens.

  15.     13/05/2003      Vijay Shankar for bug # 2943558. Version#615.15
                          When a Receipt is made against a SCHEDULED Release (partial quantity) of
                          PLANNED PO, then taxes are calculated for whole of the PLANNED PO line quantity
                          instead of SCHEDULED Release quantity.
                          The issue is occuring because, precedence_0 is calculated as unit_price * quantity
                          of PO_LINES_ALL instead of PO_LINE_LOCATIONS_ALL. Code is modified to calculate
                          precedence_0 as PRICE_OVERRIDE * QUANTITY of PO_LINE_LOCATIONS_ALL instead of using
                          PO_LINES_ALL

  16.    06/06/2003       Nagaraj.s for Bug #2991872. Version : 616.1
                          Code is added to ensure that if Assessable price is defined for Excise Taxes, then
                          the Assessable Price is picked up instead of the unit price from po_line_locations_all
                          table.

  17.    21/07/2003       Vijay Shankar for Bug# 3028040, Version : 616.2
                          Code is added to check for EXPRESS transaction and then stop 'For Passing' to fire for every RECEIVE transaction
                          of EXPRESS Receipt.  This change is made as the PADDR concept is removed in RCV_SHIPMENT_HEADERS DFF.

  18.    29/07/2003       Nagaraj.s for Bug #2993865 . Version#:616.3
                          The  two queries which were written earlier to fetch line_id,transaction_curr_code,
                          delivery_detail_id have been merged to form one query.
                          The join is now changed to
                          order. source document id = requisition.requisition header id
                          order line.source document line id = requisition line. requisition line id.

  19.    30/07/2003       Nagaraj.s for Bug#3037075. Version#:616.4
                          The Vendor site id is now fetched in the lines_rec cursor and
                          the same is  populated into JAI_RCV_LINE_TAXES table.
                          This change is applicable for only PO type of Transaction. Huge Dependency

  20.    22/08/2003       Nagaraj.s for Bug#3057752. Version#:616.5
                          The changes are as below:
                          An Raise Application Error is written to ensure that RTR Transactions should not happen
                          if neither claim nor unclaim is done.

  21.    31/10/2003       Nagaraj.s for Bug # 3123778, File Version : 616.6
                          The check for CGIN,CGEX items for 100% claim is removed as per
                          the Functional Requirement.

  22.    03/11/2003       Nagaraj.s for Bug # 3202319  File Version : 616.7
                          In case of FGIN,FGEX Item Classes, the Claim percentage should not hold good.
                          Hence the cursor mod_rec is added with Item class FGIN,FGEX and the same
                          is incorporated in the IF Condition, which validates for 100% cenvat claim.

  23.    05/11/2003       Nagaraj.s for Bug3237536 File Version : 616.8 (IN60105D2)
                          Added the condition v_tax_vendor_site_id := null as this was leading to Vendor
                          site id being populated in all cases irrespective of the type of Tax.

  24.    02/06/2004       ssumaith - bug# 3657662 - File Version 115.1

                          There was a performance problem with a query . The issue was it was taking time because
                          of a full table scan on the oe_order_headers_all table.

                          Issue was resolved by retreiving the order_header_id from the JAI_OM_WSH_LINES_ALL
                          based on delivery id and adding a where clause to qualify the order_header_id.


  25.   04/06/2004        Nagaraj.s - Bug # 3655330 - File Version : 115.1
                          In case of RTR and RTV scenarios, check has been made for either
                          claim or unclaim but in this case neither claim or unclaim happens and hence,
                          added one more condition :v_non_bonded_delivery_flag = 'N'
                          so that RTR and RTV will be done without any problems.

  26.   18/06/2004       ssumaith - bug# 3683666 - File Version 115.2

                         When a RMA receipt is done without navigating from Receipts-localised form and not entering
                         the values in the DFF of RCV_SHIPMENT_HEADERS or RCV_TRANSACTIONS, it was observed that
                         taxes are not defaulted into localization tables (JAI_RCV_LINE_TAXES).
                         The reason this was happening is because the if condition which was checking this to be a
                         RMA receipt was also checking the chk_form to be not null with an "AND" to other required
                         conditions. Hence the problem

                         This issue has been fixed by doing making the v_chk_form check with 'OR' rather than 'AND'

                         Dependecny due to this bug - None

  27.  22/07/2004        ssumaith - bug# 3772135 file version 115.3

                         When two internal internal orders created out of two internal requisitions are
                         merged into a single delivery ,and a receipt created for the delivery, it was
                         causing the taxes only for the first line to be populated.

  28.  28/08/2004        Nagaraj.s for Bug#3858917 File Version : 115.4
                         In valid number error was occuring as the shipment number was entered as
                         alpha numeric and the condition was entering into the ISO route the comparison
                         for the shipment num with the delivery id in the cursor c_order_cur
                         was going into this error.

                         Ideally the condition :
                         ========================================================
                         v_receipt_source_code = 'INTERNAL ORDER' OR -- AND
                         v_chk_form IS NOT NULL  AND
                         ========================================================
                         is wrong as in case of PO and RMA also this enters the code
                         and as the shipment num can be entered as any value the comparison is wrong.
                         In any case, this code should get executed for Internal Order
                         and hence the condition of v_chk_form is not needed.
                         Hence this is commented. This will be fixed as part of the generic
                         fix for the bug3848133 as this object is being changed.

  29.  24/08/2004        Nagaraj.s - Bug# 3848133 (BaseBug# 3496408). File version : 115.4

                         The code now fetches the Precedences from the following points for the following sources:
                         ----------------------------------------------------------------------------------------
                         source type               Source Table
                         RMA                       JAI_OM_OE_RMA_TAXES
                         PO                        JAI_PO_TAXES
                         ISO                       JAI_OM_WSH_LINE_TAXES
                         ----------------------------------------------------------------------------------------
                         In these 3 cases a insert into JAI_RCV_LINE_TAXES is present and this is,
                         changed to incorporate precedences as well as transaction id.

  30.  05/11/2004        Vijay Shankar - Bugs#3949408. File version : 115.5
                          Commented the redundant code for MATCH processing

  31.  14/10/2004        ssumaith - Bug# 3878439  File Version  - 115.6

                         When a delivery which consists of multiple sales orders is split into multiple delivery
                         details at the shipment level only and not at sales order level, for each delivery detail
                         a shipment line is being created at the receipt level.

                         As there is no link available between the receipt line and delivery detail at the delivery
                         detail level, we are unable to exactly apportion the taxes.

                         devised approach to get the delivery detail based on the shipment line id also ini addition
                         to the other clauses.

                         This change has been done in the cursor which fetches the delivery details based on the order and
                         receipt details.

  32    03/01/2005   Vijay Shankar for Bug# 3940588, Version:115.7
                      Modified the code to execute only for RECEIVE, UNORDERED, MATCH and RETURN TO VENDOR transactions.
                      Functionality for all the other transactions will be handled through ja_in_receipt_transaction_pkg, which is
                      coded for Receipts Corrections functionality and from now on will be used for all Localization Receipts
                      functionality as a gateway.
                      - added a new parameter p_chk_form (OUT Variable) to return back a value, if the receipt transaction that is
                      begin processed is created after navigating through Localization form
                      - Instead of submitting the concurrents JAINRVCTP is submitted for processing
                      - JAI_RCV_LINES.tax_modified_flag will be set now from above mentioned package when submitted from JAINPORE
                      - Added Validation at the end of Procedure to error out if this is an RTV and Cenvat is not yet Claimed

                      ** Please refer to Old Version of the Object incase commented code needs to be looked at **

  33    09/02/2005   Vijay Shankar for Bug# 4159557, Version:115.8
                      Modified the code to assign proper value to JAI_RCV_LINES.tax_modified_flag column based on Receipts
                      tax modification Value returned by Localization Hook given to customers. the hook is called in ja_in_receipt_tax_insert_trg
                      trigger and returned value is passed as parameter to this procedure which is used for tax_modified_flag value
                      determination

                      * This is a dependancy for Future Versions of the procedure *

  34    22/02/2005   Vijay Shankar for Bug# 4199929, Version:115.9
                      Changes made in the previous version are modified to use new setup at Organization Addl Information instead of
                      value returned by Hook
                      Changes are made in internal procedure set_receipt_flag

                      * This is a dependancy for Future Versions of the procedure *

  35    12/03/2005   Bug 4210102. resolved by LGOPALSA  Version: 115.10
                     (1) Added CVD, Excise and customs education cess

  36    19/03/2005   Vijay Shankar for Bug#4250236(4245089). FileVersion: 115.12
                      .Implemented VAT Tax Calculation based on VAT Assessable value by making a call to jai_general_pkg.ja_in_vat_assessable_value
                      .JAI_RCV_LINE_TAXES.modvat_flag is set to proper value for VAT Taxes based on RECOVERABLE item attribute
                       of item. If item setup is not done, then Default value is taken as "Y" (meaning, tax is recoverable)
                      .modified the main SQL's to fetch taxes from various sources to use jai_regime_tax_types_v to fetch regime_code
                       against each tax so that the information can be used for MODVAT_FLAG setting of tax
                      .RTV will raise an exception incase recoverable VAT exists in the receipt line and it is neither Claimed or
                       Unclaimed

  37   07/04/2005  Harshita for  Bug #4285064    Version : 116.0(115.13)

                   When a user creates a new receipt against a purchase order, he needs to enter the following information
                   through a DFF : invoice no, invoice_date, Claim Cenvat On Receipt etc.
                   This DFF is provided at two places, header and line.
                   Information from the header DFF is captured into the rcv_shipment_headers table.
                   Information from the lines DFF is captured into the rcv_transactions table.
                   This information is retrieved into our base tables JAI_RCV_TRANSACTIONS and JAI_RCV_LINES.
                   At this time, a facility has been provided for the user to default the information
                   given at the header level DFF to all the lines only if these columns are null at the
                   line level. Else the information in the line level DFF is sustained.
                   For this NVL conditions have been added where this information gets defaulted.

  38. 10/05/2005   Vijay Shankar for Bug#4346453. Version: 116.1
                   Code is modified due to the Impact of Receiving Transactions DFF Elimination

                   * High Dependancy for future Versions of this object *

  39. 08-Jun-2005  File Version 116.2. Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                   as required for CASE COMPLAINCE.

  40 13-Jun-2005   Ramananda for bug#4428980. File Version: 116.3
                   Removal of SQL LITERALs is done

  41  27-Jul-2005  Bug 4516678. Added by Lakshmi Gopalsami, File Version 120.2
                   Issue :
                     a.Whenever a user creates a receipt for a CGIN or
                     CGEX item, 50% cenvat is claimed. If he/she intends to
                     return the entire quantity in the receipt, he/she must
                     claim the remaining 50% cenvat first and then do the
                     RTV. Else, the system should throw an error.

                     b.After creating a receipt for a CGIN or CGEX item,
                     if the user does a partial RTV on that receipt,
                     the system should allow it although the remaining
                     50% CENVAT has not been claimed.

                   Fix :
                    a. Added code to check this in Package jai_rcv_tax_pkg
                      (1) Created new procedure pick_register_type to get the
                      register_type depending on the item_class
                      (2)Created two new cursors  c_fetch_receive_quantity
                      and c_fetch_transaction_Quantity to get the
                      quantity received for the receipt and RTV transactions
                      (3) Added  nvl(cenvat_amount,0) in
                      cursor c_fetch_unclaim_cenvat
                   b. The cenvat receivable accounts were not getting passed
                      in case of a CGIN/CGEX item.
                      Fixed this by passing these values.
                      Commented the generic assignment for cenvat
                      accounting entries and added the condition for
                      CGIN and CGEX item class in procedure
                      accounting_entries.

42  01-Aug-2005    Ramananda for bug#4519697, File Version 120.3
                   Changed the value being assigned to variable - v_receipt_modify_flag from X to N at 2 places
                   As a part of this bug, the minus sign which got introducted during 'Removal of SQL Literals' is removed

                    Dependency due to this Bug
                    --------------------------
                    jai_rcv_trx_prc.plb (120.3)
                    jai_rcv_rt_t1.sql   (120.2)

43  01-Aug-2005  Ramananda for bug#4530112. File Version 120.4
                 Problem
                 -------
                 In case of RTV, if VAT Claim is not done, system is giving error

                 Fix
                 ---
                 1) Commented the Condition -
                    "IF  lv_vat_recoverable_for_item = jai_constants.yes
                       AND NVL(ln_chk_vat, 0) <> 0
                       AND r_rcv_rgm_dtl.process_status_flag <> 'U'  --Not Unclaimed
                       AND r_rcv_rgm_dtl.invoice_no IS NULL"

                 Dependency Due to this Bug -
                 File jai_rcv_rgm_clm.plb (120.2) is changed as part of this Bug,
                 so this object is dependent on current Bug and object jai_rcv_rgm_clm.plb (120.2)

44  05-Aug-2005 Ramananda for Bug#4533114, File Version 120.5

                1) Added a new cursor - c_hdr_attribute5_1
                2) Added a new begin end part and fetched the values from cursor - c_hdr_attribute5_1
                3) In the cursor - line_rec, changed the condition -
                   "and spl.delivery_id = rsh.shipment_num"
                   to
                  "and spl.delivery_id = decode(ltrim(translate(shipment_num,'0123456789','~'),'~'),NULL,
                   rsh.shipment_num,(select delivery_id from wsh_new_deliveries where name=rsh.shipment_num))"

44  19-Aug-2005 Ramananda for Bug#4562844, File Version 120.6
                Problem
                -------
                System is creating receiving accounting entry and generating tax invoice against disable taxes

                Fix
                ---
                1) In the cursor for selecting the taxes from JAI_PO_TAXES,
                   changed the columns tax_rate, qty_rate and tax_amount

                Dependency due to this Bug-
                None

45. 24-Aug-2005  Bug4568090. Added by Lakshmi Gopalsami Version 120.7
                 Added check for trading items to set the modvat_flag
                 For trading items the modvat flag should be set to 'Y'
                 on tax lines if the item_trading_flag at item level is 'Y'
                 and modvat percentage is specified in the taxes

46. 02/11/2006   For Bug 5228046, File version 120.9
                 Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
                 This bug has datamodel and spec changes.

47. 21/02/2007   CSahoo for Bug#5344225, File Version 120.10
                 Forward Porting of 11i Bug#5343848.
                 Issue :
                   India - Receiving Transaction Processor Concurrent Program was called
                   for each transaction on a shipment line.
                 Fix :
                  In the procedure jai_rcv_tax_pkg,
                  Added code to set the Tax Modified Flag based on whether the Call was
                     made from India - Receipts Localized Form or not.
48.  13/04/2007   bduvarag for the Bug#5989740, file version 120.11
      Forward porting the changes done in 11i bug#5907436
49.  13/04/2007   bduvarag for the Bug#4644524, file version 120.11
      Forward porting the changes done in 11i bug#4593273

50.  27/06/2007   CSahoo for bug#6154234, File Version 120.12
                  commmented the line v_receipt_modify_flag = 'N'


                 Dependency Due to this Bug : Yes.
51.  16-07-2007    iSuppleir forward porting
                   Changed shipment_num to shipment_number
                             excise_inv_num to excise_inv_number in jai_cmn_lines table

52.  01-08-2007   rchandan for bug#6030615 , Version 120.17
                  Issue : Inter org Forward porting

53.  09/10/2007   CSahoo for bug#6209911, File Version 120.20
      Added a IF block in the set_receipt_flag procedure.

54. 15/10/2007    bgowrava for Bug#6459894, File Version 120.22
                  Uncommented statements which were wrongly commented.

55. 16/10/2007    rchandan for bug#6504410, File Version 120.23
                  Issue : R12RUP04.I/ORG.QA.ST1:RTP GOING INTO ERROR FOR MFG-MFG INTRANSIT RCPT WITH VAT
                    Fix : Few utl_file debugs were added in previous version without checking for the v_debug_flag
                          Added the check now.

56. 16/10/2007    bgowrava for Bug#6459894, File Version 120.24
                  removed the lv_object_name from the JAI_PROCESS_MESSAGE of JAI_EXCEPTION
                  to avoid truncation of the error message text.
57. 01/01/2007    Walton for Inclusive Tax Computation

58. 05/03/2008    Kevin Cheng for bug 6853787
                  Add a condition to prevent receipt type like RMA from trapping into the tax calculation loop.

59. 08/04/2008    JMEENA for Bug#6917520, File Version 120.27
                  Assigned the error message to variable 'errormsg' and printed the message in exception section.

60. 19/08/2009    JMEENA for bug#8302581
          Changed the v_tax_modvat_flag from No to Yes for RMA order where VAT recoverable flag is No for the Item
          As VAT entries need to reverse for the RMA order.

61. 16/09/2009    Jia for bug#8904043
          Issue: If Error definition's price list is assigned to Supplier, Advanced Pricing Error message is
                 not shown in log during receipt creation process .
           Fix:  Added Item-UOM validation logic before get AV, and catched validation error message handle.
62. 16-10-2009 vkaranam for bug#8880760
              Issue:
        TST1212.XB1.QA VAT TAX IS NOT RIGHT WHEN RECEIVE PART OF INTER-ORG TRANSACTION
        Fix:
        Chnages are done in  default_taxes_onto_line procedure.
        Interorg vat assessable value has been proportioned with the receipt qty.

62. 23/09/2009    Jia for bug#8932471
          Issue: If Error definition's price list is assigned to Supplier null site level, Advanced Pricing
                 Error message is not shown in log during receipt creation process .
           Fix:  Added Item-UOM validation logic for Supplier null site level before get AV, and catched
                 validation error message handle.

63. 29/09/2009    CSahoo for bug#8920186, File Version 120.27.12010000.8
                  Issue: TST1212.XB1.QA DEFAULT TAX IS NOT RIGHT WHEN UPDATE UOM DURING RECEIPT PROCESS
                  FIX: Added a IF condition to calculate the assessable value correctly if the receipt UOM and
                       PO UOM are different.

64. 25/02/2010 vkaranam for bug#9045278
               Issue:
               Not able to account the ISO receipt.
               Fix:
               Jai_rcv_lines.tax_modified_flag has been populated as 'Y' .

  ===============================================================================================================
  Bug Number  Dependency
  3037075   JAI_RCV_LINE_TAXES has been altered.

  3057752   Tables : JAI_RCV_CENVAT_CLAIMS, ja_in_temp_mod_params, ja_in_batch_claim_modvat have been
             altered.

  3123778   JAI_RCV_CENVAT_CLAIMS has been altered to add the column partial_cenvat_claim

  4210102   IN60106 + 4239736 + 4245089
  ==============================================================================================================


  Dependencies For Future Bugs
  -------------------------------------
  IN60104d  + 3037075
  IN60104d  + 3037075 + 3057752
  IN60104d  + 3037075 + 3057752 + 3123778

  IN60105D2 + 3655330 + 3848133

  IN60106   + 3940588 + 4239736 + 4245089 + 4346453

  ----------------------------------------------------------------------------------------------------------------------*/

  --Added by Nagaraj.s for Bug#2499017
  /*OPEN get_receipt_routing;
  FETCH get_receipt_routing into v_receipt_routing;
  CLOSE get_receipt_routing;*/
  --Ends here........

    --File.Sql.35 Cbabu
    -- v_form_id  := 'JAINPORE';
    v_tax_total   := 0;
    v_duplicate_ship  := jai_constants.no;
    v_chk_receipt_lines       :=0;
    v_chk_receipt_tax_lines     :=0;
    v_precedence_0        :=0;
    v_precedence_non_0    :=0;
    v_tax_base            :=0;
    v_debug_flag          := jai_constants.no;
    v_price_override      :=0;
    v_po_quantity         :=0;
    v_assessable_value    :=0;
    ln_vat_assess_value   :=0;


    BEGIN
        SELECT DECODE(SUBSTR (value,1,INSTR(value,',') -1),NULL,
      Value,SUBSTR (value,1,INSTR(value,',') -1))
      INTO v_utl_location
        FROM v$parameter
        WHERE name = 'utl_file_dir';
       EXCEPTION
         WHEN OTHERS THEN
          v_debug_flag := 'N';
      END;


   IF v_debug_flag = 'Y' THEN
      v_myfilehandle := UTL_FILE.FOPEN(v_utl_location,'ja_in_receipts_p3.log','A');
      UTL_FILE.PUT_LINE(v_myfilehandle,'************************Start************************************');
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Time Stamp this Entry is Created is ' ||TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'));
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of p_transaction_type is ' || p_transaction_type);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of p_transaction_id is ' || p_transaction_id);
   END IF;

    IF p_currency_code IS NULL   THEN
     /* Bug 5243532. Added by Lakshmi Gopalsami
      * Removed cursor org_rec and implemented caching logic.
      */
     l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                              (p_org_id  => p_organization_id );
     v_currency_code       := l_func_curr_det.currency_code;

    ELSIF p_transaction_type = 'MATCH'   THEN

      FOR po_rec IN (SELECT currency_code,
                            rate
                       FROM po_headers_all
                      WHERE po_header_id = p_po_header_id)
      LOOP
      v_currency_code := po_rec.currency_code;
      v_currency_conversion_rate := po_rec.rate;
      END LOOP;

    ELSE

      v_currency_code := p_currency_code;

    END IF;

    IF v_debug_flag = 'Y' THEN
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_currency_code is ' || v_currency_code);
    END IF;

    -- iSupplier porting
    If p_line_location_id IS NOT NULL then
       OPEN    check_rcpt_source;
       FETCH   check_rcpt_source INTO  lv_apps_source_code;
       CLOSE   check_rcpt_source;
    END IF;
    -- iSupplier porting

    jai_rcv_utils_pkg.get_func_curr(p_organization_id,
                                        v_func_currency,
                                        v_gl_set_of_books_id);
    IF v_debug_flag = 'Y' THEN
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_func_currency is ' || v_func_currency);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_gl_set_of_books_id is ' || v_gl_set_of_books_id);
    END IF;

    IF v_func_currency <> v_currency_code AND p_transaction_type <> 'MATCH'  THEN
      v_currency_conversion_rate := p_currency_conversion_rate;
    END IF;

    FOR row_rec IN (SELECT ROWID,
                           organization_id
                      FROM rcv_shipment_headers
                     WHERE shipment_header_id = p_shipment_header_id)
    LOOP
      -- v_rowid := row_rec.ROWID;
      v_rsh_organization_id := row_rec.organization_id;
    END LOOP;

    -- added, Harshita for bug #4285064
    /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
    v_attribute1 := p_attribute1;
    v_attribute2 := p_attribute2;
    v_attribute3 := p_attribute3;
    */
    -- ended, Harshita for bug #4285064

    /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
    open c_ja_rcv_interface(p_interface_transaction_id);
    fetch c_ja_rcv_interface into r_ja_rcv_interface;
    close c_ja_rcv_interface;
    if r_ja_rcv_interface.interface_transaction_id is not null then
      lv_excise_invoice_no    := r_ja_rcv_interface.excise_invoice_no;
      lv_excise_invoice_date  := r_ja_rcv_interface.excise_invoice_date;
      lv_online_claim_flag    := r_ja_rcv_interface.online_claim_flag;
    end if;

      /* R12-PADDR
    IF p_transaction_type IN ('RECEIVE', 'DELIVER', 'UNORDERED')  THEN


      -- Vijay Shankar for Bug# 3028040
      -- IF loop added by vijay shankar to add EXPRESS receipt functionality by Removing PADDR
      if p_attribute15 = 'EXPRESS' then
        v_paddr := NULL;
      else
        v_paddr := HEXTORAW(p_attribute15);
      end if;

      IF v_debug_flag = 'Y' THEN
        UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_paddr is ' || v_paddr);
      END IF;

    END IF;

    IF v_rowid IS NOT NULL AND v_paddr IS NOT NULL  THEN
      FOR loc_rec IN (SELECT form_id_drop
                        FROM JAI_CMN_LOCATORS_T
                       WHERE form_id_drop = v_form_id
                         AND paddr = v_paddr)
      LOOP
        v_chk_form := loc_rec.form_id_drop;
      END LOOP;

      IF v_debug_flag = 'Y' THEN
        UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_chk_form is ' || v_chk_form);
      END IF;

    END IF;

    IF v_chk_form IS NOT NULL  THEN
      UPDATE JAI_CMN_LOCATORS_T
      SET row_id = v_rowid
      WHERE FORM_NAME = v_form_id
      AND paddr = v_paddr;
    END IF;


    IF v_debug_flag = 'Y' THEN
     UTL_FILE.PUT_LINE(v_myfilehandle,'VIJAY2 v_express->' || v_express||', v_chk_form->'||v_chk_form);
    END IF;

    -- following if changed by Vijay Shankar for Bug# 3028040
    IF (v_chk_form IS NULL AND nvl(v_express, 'NONEXPRESS') = 'EXPRESS') THEN
      v_chk_form := 'JAINPORE';
    END IF;
       R12-PADDR */

    -- Vijay Shankar for Bug# 3028040
    OPEN c_hdr_dtl(p_shipment_header_id);
    FETCH c_hdr_dtl INTO -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. v_express,
      v_shipment_num ; -- ssumaith - bug# 3657662 v_shipment_num added
    CLOSE c_hdr_dtl;

      --Start Added by Ramananda for Bug#4533114
    BEGIN
      --checking whether the v_shipment_num is number
      ln_test_delivery_id := NULL;
      ln_test_delivery_id := v_shipment_num;
    EXCEPTION
      WHEN VALUE_ERROR THEN
        OPEN c_hdr_attribute5_1(v_shipment_num);
        FETCH c_hdr_attribute5_1 INTO v_shipment_num;
        CLOSE c_hdr_attribute5_1;
    END;
    --End Added by Ramananda for Bug#4533114

   -------------------------------- To retrieve receipt number ---------------------------------
    FOR header_rec IN (SELECT receipt_num
                         FROM rcv_shipment_headers
                        WHERE shipment_header_id = p_shipment_header_id)
    LOOP
      v_receipt_num := header_rec.receipt_num;
    END LOOP;
    ----------------------------- to retrieve receipt_source_code -------------------------------
    IF v_debug_flag = 'Y' THEN
       UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_receipt_num is ' || v_receipt_num);
    END IF;

    IF p_transaction_type = 'RECEIVE'  THEN
      FOR head_rec IN (SELECT receipt_source_code
                         FROM rcv_shipment_headers
                        WHERE shipment_header_id = p_shipment_header_id)
      LOOP
        v_receipt_source_code := head_rec.receipt_source_code;
      END LOOP;
    END IF;
    IF v_debug_flag = 'Y' THEN
     UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_receipt_source_code is ' || v_receipt_source_code);
    END IF;
    -------------------------------------------------------------------------------------------------gsr
    IF p_source_document_code IN ('PO', 'REQ','RMA','INVENTORY') AND /*rchandan for bug#6030615..added INVENTORY*/
       p_destination_type_code IN ('RECEIVING', 'INVENTORY')
    THEN

      -- Start of addition by Srihari on 04-APR-2000


      IF p_transaction_type IN ('RECEIVE', 'UNORDERED') AND
         p_source_document_code = 'PO'
        AND lv_excise_invoice_no IS NOT NULL  -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.. If this condition is satisfied, it means it is a interface receipt
      THEN

         FOR excise_rec IN
             (SELECT rsl.shipment_header_id
              FROM rcv_shipment_lines rsl
              Where rsl.to_organization_id = p_organization_id
              and exists -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. rsl.po_header_id in
              (select pha.po_header_id
               from   po_headers_all pha
               Where pha.vendor_site_id=p_vendor_site_id
               and po_header_id = rsl.po_header_id -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
              )
              and rsl.shipment_line_id in
              (select jrl.shipment_line_id
               from JAI_RCV_LINES jrl
               -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. WHERE jrl.excise_invoice_no = p_attribute1
               -- AND jrl.excise_invoice_date = p_attribute2
               WHERE jrl.excise_invoice_no = lv_excise_invoice_no
               AND jrl.excise_invoice_date = lv_excise_invoice_date
              )
             )
        LOOP
          IF p_shipment_header_id <> excise_rec.shipment_header_id  THEN
            IF v_debug_flag = 'Y' THEN
             UTL_FILE.PUT_LINE(v_myfilehandle,'error 1 dup exc inv  ' );
            END IF;
            errormsg:='Duplicate Excise invoice NUMBER FOR the same supplier site';
            RAISE_APPLICATION_ERROR (-20501, 'Duplicate Excise invoice NUMBER FOR the same supplier site');
          END IF;
        END LOOP;
      END IF; --End if for Transaction Type in RECEIVE, UNORDERED.

    IF v_debug_flag = 'Y' THEN
       UTL_FILE.PUT_LINE(v_myfilehandle,'Before UOM Cursor for Receipt ');
      END IF;
      -- End of addition by Srihari on 04-APR-2000
      -- Start of addition by Srihari on 30-NOV-99
      OPEN uom_cur(p_unit_of_measure);
      FETCH uom_cur INTO v_rcv_uom_code;
      CLOSE uom_cur;

    IF v_debug_flag = 'Y' THEN
     UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_rcv_uom_code is ' || v_rcv_uom_code);
      END IF;

      IF p_source_document_code = 'PO'  THEN
    --Changed by Nagaraj.s for Bug2531667
        FOR ll_rec IN (SELECT plla.unit_meas_lookup_code ll_uom,
                              pla.unit_meas_lookup_code l_uom
                         FROM po_line_locations_all plla,
                              po_lines_all pla
                        WHERE plla.line_location_id = p_line_location_id
                          AND pla.po_header_id = plla.po_header_id
                          AND pla.po_line_id   = p_po_line_id)
        LOOP
          IF ll_rec.ll_uom IS NOT NULL THEN
            v_po_uom := ll_rec.ll_uom;
          ELSE
            v_po_uom := ll_rec.l_uom;
          END IF;

        END LOOP;

      ELSIF p_source_document_code = 'REQ' THEN

        FOR req_rec IN (SELECT unit_meas_lookup_code r_uom
                          FROM po_requisition_lines_all
                         WHERE requisition_line_id = p_requisition_line_id)
        LOOP
          v_po_uom := req_rec.r_uom;
        END LOOP;
      --Gsr
      ELSIF p_source_document_code = 'RMA'  THEN

      FOR rma_rec IN (SELECT order_quantity_uom rma_uom
                FROM oe_order_lines_all
               WHERE HEADER_ID = p_oe_order_header_id)
      LOOP
        v_po_uom := rma_rec.rma_uom;
      END LOOP;

      ELSIF p_source_document_code = 'INVENTORY' THEN /*rchandan for bug#6030615...start*/

         open c_rec_ship_txn(p_shipment_line_id);
         fetch c_rec_ship_txn into r_rec_ship_txn;
         close c_rec_ship_txn;

         OPEN    c_get_inv_trx_info(r_rec_ship_txn.mmt_transaction_id);
         FETCH   c_get_inv_trx_info INTO  ln_trx_qty , lv_trx_uom , ln_orig_id , ln_item_cost;
         CLOSE   c_get_inv_trx_info;

         /*
         ln_orig_id : this field has the original_transaction_Temp_id
         */

         OPEN   c_jai_mtl_Trxs(ln_orig_id);
         FETCH  c_jai_mtl_Trxs INTO r_jai_mtl_Trxs;
         CLOSE  c_jai_mtl_Trxs;

         v_po_uom := lv_trx_uom; /*rchandan for bug#6030615...end*/

      END IF; --End if for p_source_document_code
    --Gsr

      OPEN uom_cur(v_po_uom);
      FETCH uom_cur INTO v_po_uom_code;
      CLOSE uom_cur;

      IF v_debug_flag = 'Y' THEN
     UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_po_uom_code is ' || v_po_uom_code);
      END IF;


      jai_rcv_utils_pkg.get_organization(p_shipment_line_id,
                                           v_organization_id,
                                             v_item_id);
      IF v_debug_flag = 'Y' THEN
     UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_organization_id is ' || v_organization_id);
     UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_item_id is ' || v_item_id);
      END IF;

      --Pick Item Modvat Flag---------------------------------------------------------------------
      --Moved this Piece of Code from the Bottom to Ensure that Item Modvat Flag and Trading Flag
      --are picked well in advance by Nagaraj.s for Bug2915783..................................
      FOR mod_rec IN (SELECT
                      modvat_flag,
                      item_trading_flag,
                      item_class --Added by Nagaraj.s for Bug3202319
                      FROM JAI_INV_ITM_SETUPS
                      WHERE organization_id = v_organization_id
                      AND inventory_item_id = v_item_id)
    LOOP
      v_item_modvat_flag   := NVL(mod_rec.modvat_flag, 'N');
      v_item_trading_flag  := NVL(mod_rec.item_trading_flag, 'N');
      v_item_class         := mod_rec.item_class; --Added by Nagaraj.s for Bug3202319
    END LOOP;

     IF v_debug_flag = 'Y' THEN
       UTL_FILE.PUT_LINE(v_myfilehandle,'The value of v_item_modvat_flag is ' || v_item_modvat_flag);
       UTL_FILE.PUT_LINE(v_myfilehandle,'The value of v_item_trading_flag is ' || v_item_trading_flag);
     END IF;
    v_item_modvat_flag := NVL(v_item_modvat_flag, 'N');
    /* Bug 4568090. Added by Lakshmi Gopalsami
       Value should be 'N' and not 'M' if the value is null */
    v_item_trading_flag := NVL(v_item_trading_flag, 'N');
    --Pick Item Modvat Flag---------------------------------------------------------------------

    /* Start, following call added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    jai_inv_items_pkg.jai_get_attrib(
      p_regime_code       => jai_constants.vat_regime,
      p_organization_id   => p_organization_id,
      p_inventory_item_id => v_item_id,
      p_attribute_code    => jai_constants.rgm_attr_item_recoverable,
      p_attribute_value   => lv_vat_recoverable_for_item,
      p_process_flag      => lv_process_flag,
      p_process_msg       => lv_process_msg
    );

    IF lv_process_flag = jai_constants.unexpected_error THEN
      errormsg:='Error from jai_inv_items_pkg.jai_get_attrib: Error:'||lv_process_msg;
      RAISE_APPLICATION_ERROR( -20099, 'Error from jai_inv_items_pkg.jai_get_attrib: Error:'||lv_process_msg);
    END IF;

      -- Default value for following variable is set as YES
    lv_vat_recoverable_for_item := nvl(lv_vat_recoverable_for_item, jai_constants.yes);   -- CHK
    /* End, Vijay Shankar for Bug#4250236(4245089) */

    IF v_rcv_uom_code <> v_po_uom_code   THEN

        Inv_Convert.inv_um_conversion(v_rcv_uom_code,
                                      v_po_uom_code,
                                      v_item_id,
                                      v_uom_rate);
        IF v_uom_rate = -99999  THEN
          v_uom_rate := 0;
        END IF;

      ELSE

        v_uom_rate := 1;

      END IF;

      v_uom_rate := NVL(v_uom_rate, 1);

      IF v_debug_flag = 'Y' THEN
        UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_uom_rate is ' || v_uom_rate);
      END IF;

      -- End of addition by Srihari on 30-NOV-99
      -- Not an unordered receipt --

      Duplicate_shipment_update;

      IF v_debug_flag = 'Y' THEN
        UTL_FILE.PUT_LINE(v_myfilehandle,'After Duplicate Shipment Update, v_receipt_source_code ->'||v_receipt_source_code);
        UTL_FILE.PUT_LINE(v_myfilehandle,'After Duplicate Shipment Update, p_transaction_type ->'||p_transaction_type);
        UTL_FILE.PUT_LINE(v_myfilehandle,'After Duplicate Shipment Update, v_duplicate_ship ->'||v_duplicate_ship);
      End IF;
          /* R12-PADDR
      IF v_debug_flag = 'Y' THEN
        UTL_FILE.PUT_LINE(v_myfilehandle,'After Duplicate Shipment Update, v_chk_form ->'||v_chk_form);
      END IF;
           R12-PADDR  */
      ---------- First Receipt for this line location ------------

      IF (
            ( v_receipt_source_code IS NOT NULL AND
              p_transaction_type = 'RECEIVE' AND
              v_receipt_source_code in ('VENDOR', 'INVENTORY') -- AND was commented by GSRI on 21-OCT-01 and OR was added
              /* R12-PADDR or v_chk_form IS NOT NULL */
             )
         OR
            ( v_receipt_source_code IS NOT NULL AND
              p_transaction_type = 'RECEIVE' AND
              v_receipt_source_code = 'CUSTOMER'  -- AND changed to OR - ssumaith - bug# 3683666
              /* R12-PADDR or v_chk_form IS NOT NULL */
             )
         OR
            p_transaction_type = 'MATCH'
        )
        AND  nvl(v_duplicate_ship, 'N') = 'N'
      THEN


       IF v_debug_flag = 'Y' THEN
         UTL_FILE.PUT_LINE(v_myfilehandle,'Inside the main If  Condition');
         UTL_FILE.PUT_LINE(v_myfilehandle,'p_source_document_code = ' || p_source_document_code);
       END IF;

        -------------------------- To retrieve po quantity -------------------------------------

        FOR qty_rec IN (SELECT quantity
                          FROM po_line_locations_all
                         WHERE line_location_id = p_line_location_id)
        LOOP
          v_loc_quantity := qty_rec.quantity;
        END LOOP;

        IF p_transaction_type = 'RECEIVE'  -- AND was commented by GSRI on 21-OCT-01 and OR was added
           /* R12-PADDR OR v_chk_form IS NOT NULL */
        THEN
          set_receipt_flag;
          insert_receipt_line;

        ELSIF p_transaction_type = 'MATCH'  THEN
          set_receipt_flag;
          v_receipt_modify_flag := 'N';
        END IF;


      IF p_source_document_code = 'RMA' THEN
      --Gsr
        IF v_debug_flag = 'Y' THEN
         UTL_FILE.PUT_LINE(v_myfilehandle,'Inside the RMA Condition');
          END IF;



  FOR lines_rec IN (SELECT
                            rtl.tax_line_no,
                            rtl.tax_id,
                            rtl.tax_rate,
                            rtl.qty_rate,
                            rtl.uom,
                            rtl.tax_amount,
                            jtc.tax_type,
                            jtc.tax_name,
                            jtc.vendor_id,
                            NVL(jtc.mod_cr_percentage, 0) modcp,
                            NVL(jtc.rounding_factor, 0) rounding_factor,
                            jtc.duty_drawback_percentage duty,
                            --3848133
                            rtl.precedence_1,
                            rtl.precedence_2,
                            rtl.precedence_3,
                            rtl.precedence_4,
                            rtl.precedence_5,
                            rtl.precedence_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                            rtl.precedence_7,
                            rtl.precedence_8,
                            rtl.precedence_9,
                            rtl.precedence_10,
          tax_types.regime_code   regime_code
                            --3848133
                          FROM JAI_OM_OE_RMA_TAXES rtl,
                               JAI_CMN_TAXES_ALL jtc
                               , jai_regime_tax_types_v tax_types
                          WHERE rtl.rma_line_id = p_oe_order_line_id
                          AND  jtc.tax_id = rtl.tax_id
                          AND tax_types.tax_type(+) = jtc.tax_type
                         )
          LOOP

              -- Start of addition by Srihari on 30-NOV-99
          --Gsr
       /* Added by LGOPALSa. Bug 4210102.
        * ADded Excise and CVD education cess */

       /* Bug 4568090. Added by LGOPALSA
          Added check for trading flag to ensure that
          recoverable flag is properly set for trading items*/

              IF v_item_modvat_flag = 'N' AND
                 v_item_trading_flag = 'N' AND
                 upper(lines_rec.tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
                                                JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,jai_constants.tax_type_exc_edu_cess,
                                              JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,jai_constants.tax_type_cvd_edu_cess)/*Bug 5989740 bduvarag*/
              THEN
                v_tax_modvat_flag := 'N';

              /* following elsif added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
              ELSIF lv_vat_recoverable_for_item <> jai_constants.yes
                AND lines_rec.regime_code = jai_constants.vat_regime
              THEN
                v_tax_modvat_flag := jai_constants.yes;  --Changed the constant to yes so that VAT taxes can be recovered in case of recoverable flag is No. For bug#8302581

              ELSIF lines_rec.modcp > 0 THEN
                v_tax_modvat_flag := 'Y';
              END IF;
          --Gsr
              -- End of addition by Srihari on 30-NOV-99
              IF p_currency_code <> v_func_currency  THEN
                v_conv_factor := NVL(v_currency_conversion_rate, 1);
              ELSE
                v_conv_factor := 1;
              END IF;

            FOR pick_rec IN (SELECT quantity
                               FROM JAI_OM_OE_RMA_LINES rel
                               WHERE rel.rma_line_id = p_oe_order_line_id)
              LOOP
                v_loc_quantity := pick_rec.quantity;
              END LOOP;

              IF NVL(v_loc_quantity, 0) <> 0 THEN
                v_cor_amount := ROUND((P_qty_received * lines_rec.tax_amount * v_uom_rate / v_loc_quantity),
                                NVL(lines_rec.rounding_factor, 0));
              END IF;
        /* Added by LGOPALSA. Bug 4210102
         * Added CVD, Excise and Customs edcuation cess */

              IF upper(lines_rec.tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CUSTOMS', 'CVD',
                JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,jai_constants.tax_type_Exc_edu_cess,
              JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,jai_constants.tax_type_cvd_Edu_cess,
              JAI_CONSTANTS.TAX_TYPE_SH_CUSTOMS_EDU_CESS,jai_constants.tax_type_customs_edu_cess)/*Bug5989740 bduvarag*/
              THEN
                v_claimable_amount := NVL(v_cor_amount * v_conv_factor, 0) * NVL(lines_rec.duty, 0) / 100;
              ELSE
                v_claimable_amount := 0;
              END IF;

          --Added by GSRI on 21-OCT-01
          SELECT COUNT(*)
          INTO   v_chk_receipt_tax_lines
          FROM   JAI_RCV_LINE_TAXES
          WHERE  shipment_line_id = p_shipment_line_id
          AND    shipment_header_id = p_shipment_header_id
          AND    tax_id = lines_rec.tax_id;

          IF v_chk_receipt_tax_lines = 0 THEN
            /*
            DELETE FROM JAI_RCV_LINE_TAXES
            WHERE shipment_line_id = p_shipment_line_id AND
            shipment_header_id = p_shipment_header_id AND
            tax_id = lines_rec.tax_id;*/
            --End Addition by on GSRI 21-OCT-01

      v_tax_modvat_flag := NVL(v_tax_modvat_flag,'N') ;
            INSERT INTO JAI_RCV_LINE_TAXES
            (
              shipment_line_id,
              tax_line_no,
              shipment_header_id,
              tax_id,
              tax_name,
              currency,
              tax_rate,
              qty_rate,
              uom,
              tax_amount,
              tax_type,
              modvat_flag,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              vendor_id,
              claimable_amount,
              --3848133
              precedence_1,
              precedence_2,
              precedence_3,
              precedence_4,
              precedence_5,
              precedence_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
              precedence_7,
              precedence_8,
              precedence_9,
              precedence_10,
        transaction_id
              --3848133
            )
           VALUES
            (
              p_shipment_line_id,
              lines_rec.tax_line_no,
              p_shipment_header_id,
              lines_rec.tax_id,
              lines_rec.tax_name,
              p_currency_code,
              lines_rec.tax_rate,
              lines_rec.qty_rate,
              lines_rec.uom,
              v_cor_amount,
              lines_rec.tax_type,
              v_tax_modvat_flag, --NVL(v_tax_modvat_flag,'N'),
              p_creation_date,
              p_created_by,
              p_last_update_date,
              p_last_updated_by,
              p_last_update_login,
              lines_rec.vendor_id,
              v_claimable_amount,
              --3848133
              lines_rec.precedence_1,
              lines_rec.precedence_2,
              lines_rec.precedence_3,
              lines_rec.precedence_4,
              lines_rec.precedence_5,
              lines_rec.precedence_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
              lines_rec.precedence_7,
              lines_rec.precedence_8,
              lines_rec.precedence_9,
              lines_rec.precedence_10,
        p_transaction_id
              --3848133
            );

          END IF;

              IF lines_rec.tax_type NOT IN ('TDS', 'Modvat Recovery') THEN
                v_tax_total := v_tax_total + NVL(v_cor_amount * v_conv_factor, 0);
              END IF;

          END LOOP;
        --Gsr
        --ELSE -- commented by sriram bug # 2514719
             --Changed by Nagaraj.s for Bug # 2588096

         ELSIF p_source_document_code = 'PO' AND p_transaction_type <> 'UNORDERED' THEN

               -- the above elsif added by sriram bug # 2514719 on aug 20th
               -- ISO CYCLE AS the following STATEMENT IS ONLY applicable FOR PO transactions
         -- Start addition by Aparajita for bug#2415767 on 17th june 2002

        BEGIN
             SELECT currency_code,
                              rate
             INTO   v_po_currency,
                  v_po_rate
                       FROM   po_headers_all
                      WHERE   po_header_id = p_po_header_id;
        EXCEPTION
            WHEN OTHERS THEN
                      IF v_debug_flag = 'Y' THEN
                        UTL_FILE.PUT_LINE(v_myfilehandle,'error 2 fetch po curr  ' );
                      END IF;
                      errormsg:='Error while fetching PO currency details :' || SQLERRM;
                      RAISE_APPLICATION_ERROR (-20501, 'Error while fetching PO currency details :' || SQLERRM);
        END;
  /*Bug 4644524 start bduvarag*/
        OPEN c_rcv_shipment_lines(p_shipment_line_id);
      FETCH c_rcv_shipment_lines INTO r_rcv_shipment_lines;
      CLOSE c_rcv_shipment_lines;
  /*Bug 4644524 End bduvarag*/

              IF v_debug_flag = 'Y' THEN
             UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_po_currency is ' || v_po_currency);
             UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_po_rate is ' || v_po_rate);
              END IF;
        -- end addition by Aparajita for bug#2415767 on 17th june 2002


      /*  iSupplier porting
      || start - ssumaith - ASBN
      */
           OPEN  c_check_asbn;
           FETCH c_check_asbn INTO lv_asbn_type , lv_shipment_num;
           CLOSE c_check_asbn;

           IF lv_asbn_type = '1' THEN
             lv_asbn_type := 'TRUE';
           ELSE
             lv_asbn_type := 'FALSE';
           END IF;

               IF p_source_document_code = 'PO' AND p_transaction_type <> 'UNORDERED' AND lv_asbn_type <> 'TRUE'  THEN

                   OPEN c_po_tax_cur FOR
                   SELECT tax_line_no,
                                 llt.tax_id,
                                 DECODE(SIGN(jtc.end_date - SYSDATE), -1, 0, llt.tax_rate) tax_rate,
                                 DECODE(SIGN(jtc.end_date - SYSDATE), -1, 0, llt.qty_rate) qty_rate,
                                 uom,
                                 DECODE(SIGN(jtc.end_date - SYSDATE), -1, 0, llt.tax_amount) tax_amount,
                                 llt.tax_type,
                                 jtc.tax_name,
                                 llt.modvat_flag,
                                 llt.vendor_id,
                                 jtc.vendor_id tax_vendor_id,
                                 jtc.vendor_site_id,
                                 llt.currency,
                                 jtc.rounding_factor,
                                 jtc.duty_drawback_percentage duty,
                                 llt.precedence_1,
                                 llt.precedence_2,
                                 llt.precedence_3,
                                 llt.precedence_4,
                                 llt.precedence_5
                                 , tax_types.regime_code   regime_code,
                                 llt.precedence_6,
                                 llt.precedence_7,
                                 llt.precedence_8,
                                 llt.precedence_9,
                                 llt.precedence_10
                               FROM JAI_PO_TAXES llt,
                                 JAI_CMN_TAXES_ALL jtc
                                 , jai_regime_tax_types_v tax_types
                               WHERE line_location_id = p_line_location_id
                               AND jtc.tax_id = llt.tax_id
                               AND jtc.tax_type = tax_types.tax_type (+)
                    order by tax_line_no;

               ELSIF p_source_document_code = 'PO' AND lv_asbn_type = 'TRUE'  THEN


                      /*
                       Code to populate the excise invoice number and date into the
                       ja_in_Receipt_lines procedure in case of an asbn receipt.
                      */


                      OPEN   c_jai_cmn_lines(v_shipment_num);
                      FETCH  c_jai_cmn_lines INTO r_jai_cmn_lines;
                      CLOSE  c_jai_cmn_lines;

            v_loc_quantity := r_jai_cmn_lines.quantity;

                     update JAI_RCV_LINES
                     set    excise_invoice_no = r_jai_cmn_lines.excise_inv_number,
                            excise_invoice_date=r_jai_cmn_lines.excise_inv_Date
                     where  shipment_line_id = p_shipment_line_id;

                    OPEN c_po_tax_cur FOR
                   SELECT tax_line_no,
                                 llt.tax_id,
                                 DECODE(SIGN(jtc.end_date - SYSDATE), -1, 0, llt.tax_rate) tax_rate,
                                 DECODE(SIGN(jtc.end_date - SYSDATE), -1, 0, llt.qty_rate) qty_rate,
                                 llt.uom,
                                 DECODE(SIGN(jtc.end_date - SYSDATE), -1, 0, llt.tax_amt) tax_amount,
                                 llt.tax_type,
                                 jtc.tax_name,
                                 llt.modvat_flag,
                                 nvl(jtc.vendor_id,p_vendor_id) vendor_id, /*rchandan for bug#6030615*/
                                 jtc.vendor_id tax_vendor_id,
                                 jtc.vendor_site_id,
                                 llt.currency_code currency ,
                                 jtc.rounding_factor,
                                 jtc.duty_drawback_percentage duty,
                                 llt.precedence_1,
                                 llt.precedence_2,
                                 llt.precedence_3,
                                 llt.precedence_4,
                                 llt.precedence_5
                                 , tax_types.regime_code   regime_code,
                                 llt.precedence_6,
                                 llt.precedence_7,
                                 llt.precedence_8,
                                 llt.precedence_9,
                                 llt.precedence_10
                               FROM jai_cmn_document_taxes llt,
                                    jai_cmn_lines          cml,
                                    JAI_CMN_TAXES_ALL jtc ,
                                    jai_regime_tax_types_v tax_types
                               WHERE cml.po_line_location_id = p_line_location_id
                               AND   cml.cmn_line_id  =  llt.source_doc_line_id
                   AND   cml.shipment_number = lv_shipment_num
                               AND   llt.source_doc_type = 'ASBN'
                               AND   jtc.tax_id = llt.tax_id
                               AND   jtc.tax_type = tax_types.tax_type (+)
                    order by tax_line_no;
          --iSupplier porting

               END IF ; /*  end if for
                        p_source_document_code = 'PO' AND p_transaction_type <> 'UNORDERED' AND lv_asbn_type <> 'TRUE'
                    */
           ELSIF p_source_document_code = 'INVENTORY' THEN

                 v_po_currency := 'INR';
                 v_po_rate := 1;

                 open c_rec_ship_txn(p_shipment_line_id);
                 fetch c_rec_ship_txn into r_rec_ship_txn;
                 close c_rec_ship_txn;

                 OPEN c_rcv_shipment_lines(p_shipment_line_id);
     FETCH c_rcv_shipment_lines INTO r_rcv_shipment_lines;
                 CLOSE c_rcv_shipment_lines;

                 OPEN    c_get_inv_trx_info(r_rec_ship_txn.mmt_transaction_id);
                 FETCH   c_get_inv_trx_info INTO  ln_trx_qty , lv_trx_uom , ln_orig_id , ln_item_cost;
                 CLOSE   c_get_inv_trx_info;

                 OPEN   c_jai_mtl_Trxs(ln_orig_id);
                 FETCH  c_jai_mtl_Trxs INTO r_jai_mtl_Trxs;
                 CLOSE  c_jai_mtl_Trxs;

                 v_loc_quantity := ln_trx_qty;

    update jai_rcv_lines
    set excise_invoice_no = r_jai_mtl_trxs.excise_invoice_no ,
    excise_invoice_Date = r_jai_mtl_trxs.creation_Date
    where shipment_line_id = p_shipment_line_id;

                 OPEN c_po_tax_cur FOR
                 SELECT tax_line_no,
                               llt.tax_id,
                               DECODE(SIGN(jtc.end_date - SYSDATE), -1, 0, llt.tax_rate) tax_rate,
                               DECODE(SIGN(jtc.end_date - SYSDATE), -1, 0, llt.qty_rate) qty_rate,
                               llt.uom,
                               DECODE(SIGN(jtc.end_date - SYSDATE), -1, 0, llt.tax_amt) tax_amount,
                               llt.tax_type,
                               jtc.tax_name,
                               llt.modvat_flag,
                               NVL(jtc.vendor_id,r_jai_mtl_Trxs.from_organization) vendor_id,  /* 6030615*/
                               jtc.vendor_id tax_vendor_id,
                               jtc.vendor_site_id,
                               llt.currency_code currency ,
                               jtc.rounding_factor,
                               jtc.duty_drawback_percentage duty,
                               llt.precedence_1,
                               llt.precedence_2,
                               llt.precedence_3,
                               llt.precedence_4,
                               llt.precedence_5,
                               tax_types.regime_code regime_code,
                               llt.precedence_6,
                               llt.precedence_7,
                               llt.precedence_8,
                               llt.precedence_9,
                               llt.precedence_10
                             FROM jai_cmn_document_taxes llt,
                                  JAI_CMN_TAXES_ALL jtc ,
                                  jai_regime_tax_types_v tax_types,
                                  mtl_material_transactions mtl
                             WHERE llt.source_doc_line_id = mtl.original_transaction_temp_id
                             AND   llt.source_doc_type = 'INTERORG_XFER'
                             AND   jtc.tax_id = llt.tax_id
                             AND   mtl.transaction_id = r_rec_ship_txn.MMT_TRANSACTION_ID
                             AND   jtc.tax_type = tax_types.tax_type (+)
                           order by tax_line_no;
 END IF; -- RMA
        --Added/Modified by walton for inclusive tax
        -------------------------------------------------------------
        IF p_source_document_code = 'PO' AND lv_asbn_type <> 'TRUE'
        THEN
          SELECT  price_override , quantity
          INTO    v_price_override,v_po_quantity
          FROM    po_line_locations_all
          WHERE   line_location_id = p_line_location_id;
        ELSIF  p_source_document_code = 'PO' AND  lv_asbn_type = 'TRUE'
        THEN
          v_po_quantity := r_jai_cmn_lines.quantity;
          v_price_override := r_jai_cmn_lines.po_unit_price;
        ELSIF p_source_document_code = 'INVENTORY' THEN
          v_price_override := ln_item_cost; /* currently hard coded  */
          v_po_quantity    := ln_trx_qty;     /* currently hard coded  */
        END IF;

        -- Added by Jia for bug#8904043, Begin
        --------------------------------------------------------------------------------------------
        BEGIN
          Jai_Avlist_Validate_Pkg.Check_AvList_Validation( pn_party_id          => p_vendor_id
                                                         , pn_party_site_id     => p_vendor_site_id
                                                         , pn_inventory_item_id => v_item_id
                                                         , pd_ordered_date      => SYSDATE
                                                         , pv_party_type        => 'V'
                                                         , pn_pricing_list_id  => NULL
                                                         );
        EXCEPTION
        WHEN OTHERS THEN
           errormsg := SQLERRM ;
           app_exception.raise_exception;
        END;
        --------------------------------------------------------------------------------------------
        -- Added by Jia for bug#8904043, Begin

        -- Added by Jia for bug#8932471, Begin
        --------------------------------------------------------------------------------------------
        BEGIN
          Jai_Avlist_Validate_Pkg.Check_AvList_Validation( pn_party_id          => p_vendor_id
                                                         , pn_party_site_id     => 0
                                                         , pn_inventory_item_id => v_item_id
                                                         , pd_ordered_date      => SYSDATE
                                                         , pv_party_type        => 'V'
                                                         , pn_pricing_list_id  => NULL
                                                         );
        EXCEPTION
        WHEN OTHERS THEN
           errormsg := SQLERRM ;
           app_exception.raise_exception;
        END;
        --------------------------------------------------------------------------------------------
        -- Added by Jia for bug#8932471, Begin


        v_assessable_value := NVL(jai_cmn_setup_pkg.get_po_assessable_value
                              ( p_vendor_id, p_vendor_site_id, v_item_id, p_uom_code ),v_price_override);

        IF p_source_document_code = 'INVENTORY'
        THEN
          v_price_override:=r_jai_mtl_Trxs.selling_price;
          v_assessable_value:=NVL(r_jai_mtl_Trxs.assessable_Value,v_price_override);
       END IF;


        OPEN   c_jai_cmn_lines(v_shipment_num);
        FETCH  c_jai_cmn_lines INTO r_jai_cmn_lines;
        CLOSE  c_jai_cmn_lines;

        ln_po_unit_price := 0;
        IF lv_asbn_type = 'TRUE'
        THEN
          ln_po_unit_price := r_jai_cmn_lines.po_unit_price;
        END IF ;
        If p_source_document_code <> 'INVENTORY' THEN /*rchandan - 6030615*/
          ln_vat_assess_value := jai_general_pkg.ja_in_vat_assessable_value (
                                  p_party_id          => p_vendor_id,
                                  p_party_site_id     => p_vendor_site_id,
                                  p_inventory_item_id => v_item_id,
                                  p_uom_code          => p_uom_code,
                                  p_default_price     => ln_po_unit_price * r_jai_cmn_lines.quantity,
                                  p_ass_value_date    => trunc(sysdate) ,
                                  p_party_type        => 'V'
                              );
          IF ln_vat_assess_value=0
          THEN
            ln_vat_assess_value:=v_price_override;
          END IF;

        else /*rchandan - 6030615*/
          v_price_override := r_jai_mtl_Trxs.selling_price;
          ln_vat_assess_value:=NVL(r_jai_mtl_Trxs.vat_assessable_Value/r_jai_mtl_Trxs.quantity,v_price_override);   --added  /r_jai_mtl_Trxs.quantity for bug#8880760
    /*vat assessable value in interorg is stored as vat_assessable_value per qty *shipment qty,hence divided with  r_jai_mtl_Trxs.quantity for bug#8880760*/
    --r_jai_mtl_Trxs.quantity to get the per qty vat asse
        end if;

        --added the IF block for bug#8920186
        IF v_rcv_uom_code <> v_po_uom_code and v_uom_rate > 0   THEN

          ln_vat_assess_value:=ln_vat_assess_value*v_po_quantity/v_uom_rate;
          v_assessable_value:=v_assessable_value*v_po_quantity/v_uom_rate;
        ELSE
          --start additions for bug#8880760
          ln_vat_assess_value:=ln_vat_assess_value*v_po_quantity;
          v_assessable_value:=v_assessable_value*v_po_quantity;
        END IF;

        /* proportionate the assessable value based on transaction quantity and receipt quantity
        here v_loc quantity is the transaction qty */

           ln_vat_assess_value:=(ln_vat_assess_value / v_loc_quantity) * P_qty_received * v_uom_rate;

           v_assessable_value:=(v_assessable_value / v_loc_quantity) * P_qty_received * v_uom_rate;
    v_precedence_0 := v_price_override * v_po_quantity;
    /*v_precedence_0 is the taxable basis on which the tax rate will be applied (i.e line amount /assessable value).*/

     v_precedence_0 :=(v_precedence_0 / v_loc_quantity) * P_qty_received * v_uom_rate;
   --end additions for bug#8880760

        /*commented the code and added whatever is required inside the loop

  If p_source_document_code = 'INVENTORY'/*rchandan - 6030615..start*
           and po_lines_rec.regime_code <> jai_constants.vat_regime
           and  upper(po_lines_rec.tax_type) NOT IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE')
        THEN
          v_price_override := r_jai_mtl_Trxs.selling_price;
        END IF;
                                       -- bug 6488829 uncommented the if condition *
        IF  p_source_document_code = 'INVENTORY' AND po_lines_rec.regime_code = jai_constants.vat_regime THEN
             v_precedence_0 := v_price_override;
        ELSE
          ln_vat_assess_value:=ln_vat_assess_value*v_po_quantity;
          v_assessable_value:=v_assessable_value*v_po_quantity;
          v_precedence_0 := v_price_override * v_po_quantity;
        END IF;  /*rchandan - 6030615 end

          IF v_po_currency <> po_lines_rec.currency THEN
            v_precedence_0 := v_precedence_0 * p_currency_conversion_rate;
            ln_vat_assess_value:=ln_vat_assess_value*p_currency_conversion_rate;
            v_assessable_value:=v_assessable_value*p_currency_conversion_rate;
          END IF;

         -- proportionate the tax amount based on quantity in PO and receipt
          v_precedence_0 :=(v_precedence_0 / v_loc_quantity) * P_qty_received * v_uom_rate;
          -- v_uom_rate is added in the above line by Aparajita for bug#2929171

         ln_vat_assess_value:=(ln_vat_assess_value / v_loc_quantity) * P_qty_received * v_uom_rate;

         v_assessable_value:=(v_assessable_value / v_loc_quantity) * P_qty_received * v_uom_rate;
   */
        -------------------------------------------------------------------------------------------

        ln_curflag := 0;  --Add by Kevin Cheng for bug 6853787 Mar 5, 2008

        IF c_po_tax_cur%ISOPEN THEN /*rchandan for bug#6030615*/
        ln_curflag := 1;  --Add by Kevin Cheng for bug 6853787 Mar 5, 2008
        LOOP
          fetch c_po_tax_cur INTO po_lines_rec;
          exit when c_po_tax_cur%notFOUND;
    --start additions for bug#8880760

                   IF v_po_currency <> po_lines_rec.currency THEN
                      v_precedence_0 := v_precedence_0 * p_currency_conversion_rate;
                      v_assessable_value:=v_assessable_value*p_currency_conversion_rate;
          ln_vat_assess_value:=ln_vat_assess_value*p_currency_conversion_rate;
       end if;
    --end additions for bug#8880760


          --added by walton for inclusive tax on 01-Jan-08
          -----------------------------------------------------------------
          lt_tax_table(lt_tax_table.count+1) := po_lines_rec;
          p1(row_count) := nvl(po_lines_rec.precedence_1,-1);
          p2(row_count) := nvl(po_lines_rec.precedence_2,-1);
          p3(row_count) := nvl(po_lines_rec.precedence_3,-1);
          p4(row_count) := nvl(po_lines_rec.precedence_4,-1);
          p5(row_count) := nvl(po_lines_rec.precedence_5,-1);
          p6(row_count) := nvl(po_lines_rec.precedence_6,-1);
          p7(row_count) := nvl(po_lines_rec.precedence_7,-1);
          p8(row_count) := nvl(po_lines_rec.precedence_8,-1);
          p9(row_count) := nvl(po_lines_rec.precedence_9,-1);
          p10(row_count):= nvl(po_lines_rec.precedence_10,-1);
          tax_rate_tab(row_count) := NVL(po_lines_rec.tax_rate,0);

          IF po_lines_rec.tax_rate is null
          THEN
            tax_rate_zero_tab(row_count) := 0;
          ELSIF po_lines_rec.tax_rate = 0
          THEN
            tax_rate_zero_tab(row_count) := -9999;
          ELSE
            tax_rate_zero_tab(row_count) := po_lines_rec.tax_rate;
          END IF;  --End of po_lines_rec.tax_rate is null

          round_factor_tab(row_count):=NVL(po_lines_rec.rounding_factor,0);

          lt_tax_rate_per_rupee(row_count):=NVL(po_lines_rec.tax_rate,0)/100;
          ln_total_tax_per_rupee:=0;
          tax_amt_tab(row_count) := 0;
          base_tax_amt_tab(row_count) := 0;
          lt_tax_amt_rate_tax_tab(row_count):=0;
          lt_tax_amt_non_rate_tab(row_count):=0;
          OPEN c_get_inclusive_flag ( po_lines_rec.tax_id);
          FETCH c_get_inclusive_flag
          INTO lt_inclusive_tax_tab(row_count),lv_valid_date;
          CLOSE c_get_inclusive_flag;

          IF lv_valid_date IS NULL OR lv_valid_date >= SYSDATE THEN
            end_date_tab(row_count) := 1;
          ELSE
            end_date_tab(row_count) := 0;
          END IF;

          IF upper(po_lines_rec.tax_type) IN('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
               JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,jai_constants.tax_type_exc_edu_cess,
               JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,jai_constants.tax_type_cvd_edu_cess)
          THEN
            tax_type_tab(row_count) := 1;
          ELSIF po_lines_rec.regime_code=jai_constants.vat_regime
          THEN
            tax_type_tab(row_count) := 4;
          ELSE
            tax_type_tab(row_count) := 0;
          END IF;
          ------------------------------------------------------------------

          IF v_item_modvat_flag = 'N' AND
             v_item_trading_flag = 'N' AND
             upper(po_lines_rec.tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
             JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,jai_constants.tax_type_exc_edu_cess,
             JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,jai_constants.tax_type_cvd_edu_cess)/*bug5989740 bduvarag*/
         THEN
             v_tax_modvat_flag := 'N';
              /* following elsif added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
              /*Commented for Bug 4644524 bduvarag*/
--              ELSIF lv_vat_recoverable_for_item <> jai_constants.yes
         ELSIF (lv_vat_recoverable_for_item <> jai_constants.yes  OR r_rcv_shipment_lines.item_id IS NULL)
                AND po_lines_rec.regime_code = jai_constants.vat_regime
         THEN
                v_tax_modvat_flag := jai_constants.no;

         ELSE
                  v_tax_modvat_flag := po_lines_rec.modvat_flag;
         END IF;
         -- End of addition by Srihari on 30-NOV-99

         IF v_debug_flag = 'Y' THEN
             UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_tax_modvat_flag is ' || v_tax_modvat_flag);
         END IF;
          lt_tax_modvat_flag(row_count):=v_tax_modvat_flag; --Added by walton for inclusive

          IF po_lines_rec.currency <> v_func_currency  THEN
              v_conv_factor := NVL(v_currency_conversion_rate, 1);
          ELSE
              v_conv_factor := 1;
          END IF;

          --Added by Nagaraj.s for Bug3037075
          --This is to set the Third Party Flag for proper value.
          if po_lines_rec.vendor_id <> p_vendor_id
             and upper(po_lines_rec.tax_type) not in ('TDS', 'MODVAT RECOVERY')
             and po_lines_rec.vendor_id > 0
          then
            v_third_party_flag := 'Y';
            --To ensure that proper vendor site id is populated into default_taxes_onto_line
            if po_lines_rec.vendor_id = po_lines_rec.tax_vendor_id then
                v_tax_vendor_site_id := po_lines_rec.vendor_site_id;
            else
               v_tax_vendor_site_id := null;
            end if;
          else
             v_third_party_flag := 'N';
             v_tax_vendor_site_id := null; --Added by Nagaraj.s for Bug3237536.
             --This was to be done as a part of Bug3037075
             --And as this variable was not reinitialized, hence in case of Receipts
             --where Excise was present after Adhoc, the Vendor site id was populated
             --for the Non Third Party line also.

           end if; -- End of po_lines_rec.vendor_id <> p_vendor_id

          lt_third_party_flag(row_count):=v_third_party_flag;--Added by walton for inclusive


          IF  po_lines_rec.precedence_1 IS NOT NULL OR
              po_lines_rec.precedence_2 IS NOT NULL OR
              po_lines_rec.precedence_3 IS NOT NULL OR
              po_lines_rec.precedence_4 IS NOT NULL OR
              po_lines_rec.precedence_5 IS NOT NULL OR
            po_lines_rec.precedence_6 IS NOT NULL OR -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
              po_lines_rec.precedence_7 IS NOT NULL OR
              po_lines_rec.precedence_8 IS NOT NULL OR
              po_lines_rec.precedence_9 IS NOT NULL OR
              po_lines_rec.precedence_10 IS NOT NULL
          THEN
            lt_tax_amt_non_rate_tab(row_count):=0;
          ELSE
            lt_tax_amt_non_rate_tab(row_count) := (po_lines_rec.tax_amount / v_loc_quantity) * P_qty_received * v_uom_rate ;
          END IF; --End of po_lines_rec.precedence_1 IS NOT NULL OR

          row_count := row_count + 1;
        END LOOP;
        CLOSE c_po_tax_cur; /*rchandan for bug#6030615*/
        row_count := row_count - 1;
      END IF; /* OF if ISOPEN*/

    IF ln_curflag = 1 THEN--Add by Kevin Cheng for bug 6853787 Mar 5, 2008
      IF ln_vat_assess_value<>v_precedence_0
      THEN
        ln_vat_assessable_value:=ln_vat_assess_value;
      ELSE
        ln_vat_assessable_value:=1;
      END IF; --End p_vat_assessable_value<>p_tax_amount

      IF v_assessable_value<>v_precedence_0
      THEN
        ln_assessable_value:=v_assessable_value;
      ELSE
        ln_assessable_value:=1;
      END IF; --End p_assessable_value<>p_tax_amount
     --Added by walton for inclusive tax computation
     -----------------------------------------------
      FOR I IN 1..row_count LOOP
        IF end_date_tab(I) <> 0 THEN
            IF tax_type_tab(I) = 1 THEN
                IF ln_assessable_value =1
                THEN
                  bsln_amt:=1;
                  ln_bsln_amt_nr :=0;
                ELSE
                  bsln_amt :=0;
                  ln_bsln_amt_nr :=ln_assessable_value;
                END IF;
            ELSIF tax_type_tab(I) = 4 THEN
                IF ln_vat_assessable_value =1
                THEN
                  bsln_amt:=1;
                  ln_bsln_amt_nr :=0;
                ELSE
                  bsln_amt :=0;
                  ln_bsln_amt_nr :=ln_vat_assessable_value;
                END IF;
            ELSIF tax_type_tab(I) = 6 THEN
                bsln_amt:=0;
                ln_bsln_amt_nr :=0;
            ELSE
                bsln_amt:=1;
                ln_bsln_amt_nr :=0;
            END IF;

            IF tax_rate_tab(I) <> 0 THEN
              IF P1(I) < I AND P1(I) NOT IN (-1,0) THEN
                vamt := vamt + NVL(tax_amt_tab(P1(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0);
              ELSIF P1(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                  ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
              IF p2(I) < I AND p2(I) NOT IN (-1,0) THEN
                vamt := vamt + NVL(tax_amt_tab(p2(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0);
              ELSIF p2(I) = 0 THEN
                vamt := vamt + bsln_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
              IF p3(I) < I AND p3(I) NOT IN (-1,0) THEN
                vamt := vamt + NVL(tax_amt_tab(p3(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0);
              ELSIF p3(I) = 0 THEN
                vamt := vamt + bsln_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
              IF p4(I) < I AND p4(I) NOT IN (-1,0) THEN
                vamt := vamt + NVL(tax_amt_tab(p4(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0);
              ELSIF p4(I) = 0 THEN
                vamt := vamt + bsln_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
              IF p5(I) < I AND p5(I) NOT IN (-1,0) THEN
                vamt := vamt + NVL(tax_amt_tab(p5(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0);
              ELSIF p5(I) = 0 THEN
                vamt := vamt + bsln_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
              IF P6(I) < I AND P6(I) NOT IN (-1,0) THEN
                vamt := vamt + NVL(tax_amt_tab(P6(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0);
              ELSIF P6(I) = 0 THEN
                vamt := vamt + bsln_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
              IF p7(I) < I AND p7(I) NOT IN (-1,0) THEN
                vamt := vamt + NVL(tax_amt_tab(p7(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0);
              ELSIF p7(I) = 0 THEN
                vamt := vamt + bsln_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
              IF p8(I) < I AND p8(I) NOT IN (-1,0) THEN
                vamt := vamt + NVL(tax_amt_tab(p8(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0);
              ELSIF p8(I) = 0 THEN
                vamt := vamt + bsln_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
              IF p9(I) < I AND p9(I) NOT IN (-1,0) THEN
                vamt := vamt + NVL(tax_amt_tab(p9(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0);
              ELSIF p9(I) = 0 THEN
                vamt := vamt + bsln_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
              IF p10(I) < I AND p10(I) NOT IN (-1,0) THEN
                vamt := vamt + NVL(tax_amt_tab(p10(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0);
              ELSIF p10(I) = 0 THEN
                vamt := vamt + bsln_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
              v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
              ln_tax_amt_nr:=ln_tax_amt_nr+(ln_vamt_nr*(tax_rate_tab(I)/100));
              base_tax_amt_tab(I) := vamt;
              tax_amt_tab(I) := NVL(tax_amt_tab(I),0) + v_tax_amt;
              lt_tax_amt_non_rate_tab(I):=NVL(lt_tax_amt_non_rate_tab(I),0)+ln_tax_amt_nr;
              lt_tax_amt_rate_tax_tab(I):= tax_amt_tab(I);
              vamt := 0;
              v_tax_amt := 0;
              ln_tax_amt_nr:=0; --added by walton for inclusive tax
              ln_vamt_nr:=0; --added by walton for inclusive tax
            END IF;

        ELSE

            tax_amt_tab(I) := 0;
            base_tax_amt_tab(I) := 0;

        END IF;

    END LOOP;
    FOR I IN 1..row_count LOOP
        IF end_date_tab( I ) <> 0 THEN
          IF tax_rate_tab(I) <> 0 THEN
              IF P1(I) > I THEN
                  vamt := vamt + NVL(tax_amt_tab(P1(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0);
              END IF;
              IF p2(I) > I  THEN
                  vamt := vamt + NVL(tax_amt_tab(p2(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0);
              END IF;
              IF p3(I) > I  THEN
                  vamt := vamt + NVL(tax_amt_tab(p3(I)),0);
                  ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0);
              END IF;
              IF p4(I) > I THEN
                  vamt := vamt + NVL(tax_amt_tab(p4(I)),0);
                  ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0);
              END IF;
              IF p5(I) > I THEN
                  vamt := vamt + NVL(tax_amt_tab(p5(I)),0);
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0);
              END IF;
              IF P6(I) > I THEN
                  vamt := vamt + NVL(tax_amt_tab(P6(I)),0);
                 ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0);
              END IF;
              IF p7(I) > I  THEN
                  vamt := vamt + NVL(tax_amt_tab(p7(I)),0);
                  ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0);
              END IF;
              IF p8(I) > I  THEN
                  vamt := vamt + NVL(tax_amt_tab(p8(I)),0);
                  ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0);
              END IF;
              IF p9(I) > I THEN
                  vamt := vamt + NVL(tax_amt_tab(p9(I)),0);
                  ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0);
              END IF;
              IF p10(I) > I THEN
                  vamt := vamt + NVL(tax_amt_tab(p10(I)),0);
                  ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0);
              END IF;
              base_tax_amt_tab(I) := vamt;
              v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
              ln_tax_amt_nr:=ln_tax_amt_nr+(ln_vamt_nr * (tax_rate_tab(I)/100));
              IF vamt <> 0 THEN
                  base_tax_amt_tab(I) := base_tax_amt_tab(I) + vamt;
              END IF;
              tax_amt_tab(I) := NVL(tax_amt_tab(I),0) + v_tax_amt;
              lt_tax_amt_non_rate_tab(I):=NVL(lt_tax_amt_non_rate_tab(I),0)+ln_tax_amt_nr;  --added by walton for inclusive tax
              lt_tax_amt_rate_tax_tab(I):= tax_amt_tab(I);   --added by walton for inclusive tax
              tax_amt_tab(I) :=  round(tax_amt_tab(I)  ,round_factor_tab(I)); --added by csahoo for bug#6077133
              vamt := 0;
              v_tax_amt := 0;
              ln_vamt_nr :=0;    --added by walton for inclusive tax
              ln_tax_amt_nr :=0; --added by walton for inclusive tax
          END IF; --End of tax_rate_tab(I) <> 0
        ELSE
            base_tax_amt_tab(I) := vamt;
            tax_amt_tab(I) := 0;
        END IF; --End of end_date_tab( I ) <> 0
    END LOOP;

    FOR counter IN 1 .. max_iter LOOP
        vamt := 0;
        v_tax_amt := 0;
        ln_vamt_nr:= 0;   --added by walton for inclusive tax
        ln_tax_amt_nr:=0; --added by walton for inclusive tax

        FOR i IN 1 .. row_count LOOP

          /*
          || Modified by aiyer for the fwd porting bug 4691616.
          || The following if clause will restrict the taxes whose tax_rate is null
          || i.e when tax_rate is null, tax_rate_tab(i) is 0.
          */
          IF ( tax_rate_tab( i )    <> 0           OR
               tax_rate_zero_tab(I) = -9999
              )                                    AND
            end_date_tab( I ) <> 0
          THEN

            IF tax_type_tab( I ) = 1 THEN
                IF ln_assessable_value =1
                THEN
                  v_amt:=1;
                  ln_bsln_amt_nr :=0;
                ELSE
                  v_amt :=0;
                  ln_bsln_amt_nr :=ln_assessable_value;
                END IF;
            ELSIF tax_type_tab(I) = 4 THEN
                IF ln_vat_assessable_value =1
                THEN
                  v_amt:=1;
                  ln_bsln_amt_nr :=0;
                ELSE
                  v_amt :=0;
                  ln_bsln_amt_nr :=ln_vat_assessable_value;
                END IF;
            ELSIF tax_type_tab(I) = 6 THEN
                v_amt:=0;
                ln_bsln_amt_nr :=0;
            ELSE
              IF ln_assessable_value IN ( 0, -1 ) OR tax_type_tab( I ) <> 1 THEN
                 /* v_amt := p_tax_amount;*/
                 v_amt:=1;                --Added by walton for inclusive tax
                 ln_bsln_amt_nr :=0;      --Added by walton for inclusive tax
              ELSIF ln_vat_assessable_value IN ( 0, -1 ) OR tax_type_tab( I ) <> 4 THEN
                 /* v_amt := p_tax_amount;*/
                 v_amt:=1;                --Added by walton for inclusive tax
                 ln_bsln_amt_nr :=0;      --Added by walton for inclusive tax
              END IF;
            END IF;  --End of tax_type_tab( I ) = 1

            IF P1( i ) <> -1 THEN
              IF P1( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( P1( I ) );
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0);
              ELSIF P1(i) = 0 THEN
                  vamt := vamt + v_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
            END IF;

            IF p2( i ) <> -1 THEN
              IF p2( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( p2( I ) );
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0);
              ELSIF p2(i) = 0 THEN
                  vamt := vamt + v_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
            END IF;
            IF p3( i ) <> -1 THEN
              IF p3( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( p3( I ) );
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0);
              ELSIF p3(i) = 0 THEN
                  vamt := vamt + v_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
            END IF;

            IF p4( i ) <> -1 THEN
              IF p4( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p4( i ) );
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0);
              ELSIF p4(i) = 0 THEN
                vamt := vamt + v_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
            END IF;

            IF p5( i ) <> -1 THEN
              IF p5( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p5( i ) );
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0);
              ELSIF p5(i) = 0 THEN
                vamt := vamt + v_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
            END IF;

           IF P6( i ) <> -1 THEN
              IF P6( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( P6( I ) );
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0);
              ELSIF P6(i) = 0 THEN
                  vamt := vamt + v_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
            END IF;

            IF p7( i ) <> -1 THEN
              IF p7( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( p7( I ) );
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0);
              ELSIF p7(i) = 0 THEN
                  vamt := vamt + v_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
            END IF;
            IF p8( i ) <> -1 THEN
              IF p8( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( p8( I ) );
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0);
              ELSIF p8(i) = 0 THEN
                  vamt := vamt + v_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
            END IF;

            IF p9( i ) <> -1 THEN
              IF p9( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p9( i ) );
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0);
              ELSIF p9(i) = 0 THEN
                vamt := vamt + v_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
            END IF;

            IF p10( i ) <> -1 THEN
              IF p10( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p10( i ) );
                ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0);
              ELSIF p10(i) = 0 THEN
                vamt := vamt + v_amt;
                ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
              END IF;
            END IF;

            base_tax_amt_tab(I) := vamt;
            tax_target_tab(I) := vamt;
            v_func_tax_amt := v_tax_amt +  ( vamt * ( tax_rate_tab( i )/100));
            v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));

            ELSIF tax_rate_tab(I) = 0 THEN
              base_tax_amt_tab(I) := tax_amt_tab(i);
              v_tax_amt := tax_amt_tab( i );
              tax_target_tab(I) := v_tax_amt;
            ELSIF end_date_tab( I ) = 0 THEN
              tax_amt_tab(I) := 0;
              base_tax_amt_tab(I) := 0;
              tax_target_tab(I) := 0;
            END IF;

            tax_amt_tab( I ) := NVL( v_tax_amt, 0 );
            lt_tax_amt_rate_tax_tab(I) := tax_amt_tab(I);
            func_tax_amt_tab(I) := NVL(v_func_tax_amt,0);

            IF counter = max_iter THEN
              IF end_date_tab(I) = 0 THEN
                tax_amt_tab( i ) := 0;
                func_tax_amt_tab(i) := 0;
              END IF;
            END IF;

            vamt := 0;
            v_amt := 0;
            v_tax_amt := 0;
            v_func_tax_amt := 0;
            ln_vamt_nr :=0;    --added by walton for inclusive tax
            ln_tax_amt_nr:=0;   --added by walton for inclusive tax

        END LOOP;

    END LOOP;

    FOR I IN 1 .. ROW_COUNT --Compute Factor
    LOOP
    jai_cmn_utils_pkg.print_log('utils.log','lt_tax_amt_rate_tax_tab(I) = ' || lt_tax_amt_rate_tax_tab(I));
    jai_cmn_utils_pkg.print_log('utils.log','lt_tax_amt_non_rate_tab(I) = ' || lt_tax_amt_non_rate_tab(I));
    jai_cmn_utils_pkg.print_log('utils.log','inclu flag = ' || lt_inclusive_tax_tab(I));
      IF lt_inclusive_tax_tab(I) = 'Y'
      THEN
        ln_total_tax_per_rupee := ln_total_tax_per_rupee + nvl(lt_tax_amt_rate_tax_tab(I),0) ;
        ln_total_non_rate_tax := ln_total_non_rate_tax + nvl(lt_tax_amt_non_rate_tab(I),0);
      END IF;
    END LOOP; --End Compute Factor

    ln_total_tax_per_rupee := ln_total_tax_per_rupee + 1;

    IF ln_total_tax_per_rupee <> 0
    THEN
      ln_exclusive_price := (NVL(v_precedence_0,0)  -  ln_total_non_rate_tax ) / ln_total_tax_per_rupee;
    END If;
    jai_cmn_utils_pkg.print_log('utils.log','tot tax per rupee = ' ||  ln_total_tax_per_rupee
                                              || 'totl non tax = ' || ln_total_non_rate_tax );
    jai_cmn_utils_pkg.print_log('utils.log','incl sp = ' || v_precedence_0 || 'excl price = ' || ln_exclusive_price);

    FOR i in 1 .. row_count  --Compute Tax Amount
    Loop
       tax_amt_tab (i) := (lt_tax_amt_rate_tax_tab(I) * ln_exclusive_price ) + lt_tax_amt_non_rate_tab(I);
       tax_amt_tab(I) :=  round(tax_amt_tab(I)  ,round_factor_tab(I));
       jai_cmn_utils_pkg.print_log('utils.log','in final loop , tax amt is ' ||tax_amt_tab(I));
    END LOOP; --End Compute Tax Amount
    --------------------------------------------------------------------------------------------------------
    FOR i in 1.. lt_tax_table.count LOOP
         po_lines_rec := lt_tax_table(i);
             v_cor_amount := nvl(tax_amt_tab(i), 0);
              /* Added by LGOPLASA. Bug 4210102.
         * Added CVD, Excise and customs education cess */
              IF upper(po_lines_rec.tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CUSTOMS', 'CVD',
               JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,jai_constants.tax_type_exc_edu_cess,
               JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,jai_constants.tax_type_cvd_edu_cess,
               JAI_CONSTANTS.TAX_TYPE_SH_CUSTOMS_EDU_CESS,jai_constants.tax_type_customs_edu_cess)/*Bug5904736 bduvarag*/               THEN
                  -- v_claimable_amount := NVL(v_cor_amount * v_conv_factor, 0) * NVL(lines_rec.duty, 0) / 100;
                  -- above line commented by Aparajita for bug#2929171
                  v_claimable_amount := NVL(v_cor_amount, 0) * NVL(po_lines_rec.duty, 0) / 100;
              ELSE
                  v_claimable_amount := 0;
              END IF;

    --Added by GSRI on 21-OCT-01
          SELECT COUNT(*)
          INTO   v_chk_receipt_tax_lines
          FROM   JAI_RCV_LINE_TAXES
          WHERE  shipment_line_id = p_shipment_line_id
          AND    shipment_header_id = p_shipment_header_id
          AND    tax_id = po_lines_rec.tax_id;

                IF v_chk_receipt_tax_lines = 0 THEN
            /*DELETE FROM JAI_RCV_LINE_TAXES
            WHERE shipment_line_id = p_shipment_line_id AND
            shipment_header_id = p_shipment_header_id AND
            tax_id = tax_rec.tax_id;*/
            --End Addition by on GSRI 21-OCT-01

                INSERT INTO JAI_RCV_LINE_TAXES
                (
                  shipment_line_id,
                  tax_line_no,
                  shipment_header_id,
                  tax_id,
                  tax_name,
                  currency,
                  tax_rate,
                  qty_rate,
                  uom,
                  tax_amount,
                  tax_type,
                  modvat_flag,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  vendor_id,
                  claimable_amount,
                  vendor_site_id, --Added by Nagaraj.s for Bug3037075
                  third_party_flag,
                  --3848133
                  precedence_1,
                  precedence_2,
                  precedence_3,
                  precedence_4,
                  precedence_5,
                  precedence_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                  precedence_7,
                  precedence_8,
                  precedence_9,
                  precedence_10,
      transaction_id
                --3848133
                )
                VALUES
                (
                  p_shipment_line_id,
                  po_lines_rec.tax_line_no,
                  p_shipment_header_id,
                  po_lines_rec.tax_id,
                  po_lines_rec.tax_name,
                  po_lines_rec.currency,
                  po_lines_rec.tax_rate,
                  po_lines_rec.qty_rate,
                  po_lines_rec.uom,
                  tax_amt_tab(i),
                  po_lines_rec.tax_type,
                  lt_tax_modvat_flag(i),
                  p_creation_date,
                  p_created_by,
                  p_last_update_date,
                  p_last_updated_by,
                  p_last_update_login,
                  po_lines_rec.vendor_id,
                  v_claimable_amount,
                  v_tax_vendor_site_id, --Added by Nagaraj.s for Bug3037075
                  lt_third_party_flag(i),
                  --3848133
                  po_lines_rec.precedence_1,
                  po_lines_rec.precedence_2,
                  po_lines_rec.precedence_3,
                  po_lines_rec.precedence_4,
                  po_lines_rec.precedence_5,
                  po_lines_rec.precedence_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                  po_lines_rec.precedence_7,
                  po_lines_rec.precedence_8,
                  po_lines_rec.precedence_9,
                  po_lines_rec.precedence_10,
      p_transaction_id
                --3848133
              );
              END IF;

              IF po_lines_rec.tax_type NOT IN ('TDS', 'Modvat Recovery')  THEN
                 v_tax_total := v_tax_total + NVL(v_cor_amount * v_conv_factor, 0);
              END IF;
                IF v_debug_flag = 'Y' THEN
                 UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_tax_total is ' ||v_tax_total);
                END IF;
          END LOOP;
     END IF; ----Add by Kevin Cheng for bug 6853787 Mar 5, 2008

        IF p_transaction_type = 'RECEIVE'  -- AND was commented by GSRI on 21-OCT-01 and OR was added
           /* R12-PADDR OR v_chk_form IS NOT NULL */
        THEN
          update_receipt_line;
        END IF;


        IF p_transaction_type = 'MATCH'    THEN

          UPDATE JAI_RCV_LINES
             SET -- tax_modified_flag = 'N', /* Vijay Shankar for Bug#3940588 RECEIPTS DEPLUG*/
                 line_location_id = p_line_location_id,
                 tax_amount = NVL(tax_amount, 0) + v_tax_total,
                 last_update_date = p_last_update_date,
                 last_updated_by = p_last_updated_by,
                 last_update_login = p_last_update_login
           WHERE shipment_line_id = p_shipment_line_id;
        END IF;


      END IF;
    -- ADDED FOR BAR-CODING BY GSri 21-OCT-01


    /* R12-PADDR p_chk_form  := v_chk_form;    -- Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
    */

    -- END FOR BAR-CODING BY GSri and on 21-OCT-01
      IF v_receipt_source_code IS NOT NULL AND
         p_transaction_type = 'RECEIVE' AND
         v_receipt_source_code = 'INTERNAL ORDER' AND
         NVL(v_duplicate_ship, 'N') = 'N'
      THEN
        set_receipt_flag;
       -- v_receipt_modify_flag := 'N';   --commented by csahoo for bug#6154234
        insert_receipt_line;

        -- ssumaith - bug# 3657662
        open  c_order_cur(v_shipment_num);
        fetch c_order_cur into v_order_header_id;
        close c_order_cur;

        if v_debug_flag = 'Y' THEN
           UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_order_header_id is ' || v_order_header_id);
        end if;
        -- ssumaith - bug# 3657662

        --Changed by Nagaraj.s on 30/07/2003 for Bug#2993865
        FOR line_rec IN (
                          SELECT
                 line_id,
                 sha.transactional_curr_code,
                 spl.delivery_detail_id,
                 spl.quantity,
                 spl.unit_code

                FROM

                 oe_order_lines_all sla,
                 oe_order_headers_all sha,
                 po_requisition_headers_all prha,
                 po_requisition_lines_all prla,
                 JAI_OM_WSH_LINES_ALL spl,
                 rcv_shipment_headers rsh

                WHERE

                prha.requisition_header_id = prla.requisition_header_id
                and sha.source_document_id = prha.requisition_header_id
                AND sla.header_id = sha.header_id
                AND sha.header_id  in /* following subquery added by ssumaith - 3772135*/
                (
                 select order_header_id
                 from   JAI_OM_WSH_LINES_ALL
                 where  delivery_id = v_shipment_num
                )
                /* = v_order_header_id  -- ssumaith - bug# 3657662*/
                and sla.source_document_line_id = prla.requisition_line_id
                /*and to_char(spl.delivery_id) = rsh.shipment_num*/
                --and spl.delivery_id = rsh.shipment_num
              --commented the above and added the below by Ramananda for Bug#4533114
               and spl.delivery_id = decode(ltrim(translate(shipment_num,'0123456789','~'),'~'),NULL,rsh.shipment_num,
                            (select delivery_id from wsh_new_deliveries where name=rsh.shipment_num))
                and spl.order_line_id = sla.line_id
                and prla.requisition_line_id = p_requisition_line_id
                AND rsh.shipment_header_id = p_shipment_header_id
                and rownum <= (select line_num from rcv_shipment_lines where shipment_line_id = p_shipment_line_id) -- bug#3878439
            )


        LOOP
            v_line_id           := line_rec.line_id;
            v_so_currency       := line_rec.transactional_curr_code;
            v_loc_quantity      := line_rec.quantity;
            v_picking_line_id   := line_rec.delivery_detail_id;

          -- start adding by Aparajita for bug # 2813244 on 05/03/2003
          IF v_rcv_uom_code <> line_rec.unit_code   THEN

            Inv_Convert.inv_um_conversion
            (
             v_rcv_uom_code,
             line_rec.unit_code,
             v_item_id,
             v_uom_rate
            );

            IF v_uom_rate = -99999  THEN
             v_uom_rate := 0;
            END IF;

          ELSE

            v_uom_rate := 1;

          END IF; --End if for v_rcv_uom_code


          v_uom_rate := NVL(v_uom_rate, 1);

          IF v_debug_flag = 'Y' THEN
            UTL_FILE.PUT_LINE(v_myfilehandle, ' v_uom_rate:' || v_uom_rate
              ||', v_line_id:' || v_line_id|| ', v_so_currency:' || v_so_currency
              ||', v_loc_quantity:' || v_loc_quantity||', delivery_detail_id:' || v_picking_line_id
            );
          END IF;
          -- end adding by Aparajita for bug # 2813244 on 05/03/2003

        END LOOP;  --Added by Jagdish 13-sep-01

        IF v_currency_code <> v_func_currency  THEN
          v_conv_factor := NVL(v_currency_conversion_rate, 1);
        ELSE
          v_conv_factor := 1;
        END IF;

        FOR tax_rec IN
        (
          SELECT tax_line_no,
          stl.tax_id,
          stl.tax_rate,
          stl.qty_rate,
          uom,
          stl.tax_amount,
          base_tax_amount,
          func_tax_amount,
          jtc.tax_name,
          jtc.tax_type,
          jtc.vendor_id,
          jtc.mod_cr_percentage,
          jtc.rounding_factor,
          jtc.duty_drawback_percentage duty,
          --3848133
          stl.precedence_1,
          stl.precedence_2,
          stl.precedence_3,
          stl.precedence_4,
          stl.precedence_5,
          stl.precedence_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
          stl.precedence_7,
          stl.precedence_8,
          stl.precedence_9,
          stl.precedence_10,
    tax_types.regime_code   regime_code
          --3848133
          FROM JAI_OM_WSH_LINE_TAXES stl,
              JAI_CMN_TAXES_ALL jtc,
              jai_regime_tax_types_v    tax_types
          WHERE delivery_detail_id = v_picking_line_id --added by GSri and Jagdish on 5-may-01
          AND jtc.tax_id = stl.tax_id
          AND tax_types.tax_type(+) = jtc.tax_type
        )
        LOOP

          IF NVL(v_loc_quantity, 0) <> 0 THEN
            v_cor_amount := ROUND(( P_qty_received * tax_rec.tax_amount * v_uom_rate / v_loc_quantity),
                            NVL(tax_rec.rounding_factor, 0));
          END IF;

          -- Start of addition by Srihari on 30-NOV-99

          IF v_item_modvat_flag = 'N' AND    upper(tax_rec.tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE',
              'CVD', JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,jai_constants.tax_type_exc_edu_cess, JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,jai_constants.tax_type_cvd_edu_cess)/*Bug5989740 bduvarag*/
          THEN
            v_tax_modvat_flag := 'N';
            -- End of addition by Srihari on 30-NOV-99

          /* following elsif added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
          ELSIF lv_vat_recoverable_for_item <> jai_constants.yes
            AND tax_rec.regime_code = jai_constants.vat_regime
          THEN
            v_tax_modvat_flag := jai_constants.no;

          ELSIF tax_rec.mod_cr_percentage > 0 THEN
            v_tax_modvat_flag := 'Y';
          ELSE
            v_tax_modvat_flag := 'N';
          END IF;

          IF tax_rec.vendor_id IS NULL  THEN
            v_internal_vendor := - v_rsh_organization_id;
          ELSE
            v_internal_vendor := tax_rec.vendor_id;
          END IF;

          /* Added by LGOPALSa. Bug 4210102.
     * ADded Excise, Customs and CVD education cess */

          IF upper(tax_rec.tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CUSTOMS', 'CVD',
                JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,jai_constants.tax_type_exc_edu_cess,
                JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,jai_constants.tax_type_cvd_edu_cess,
                JAI_CONSTANTS.TAX_TYPE_SH_CUSTOMS_EDU_CESS,jai_constants.tax_type_customs_edu_cess/*Bug5989740 bduvarag*/
                )
          THEN
            v_claimable_amount := NVL(v_cor_amount * v_conv_factor, 0) * NVL(tax_rec.duty, 0) / 100;
          ELSE
            v_claimable_amount := 0;
          END IF;

          -- Added by GSRI on 21-OCT-01
          SELECT COUNT(*)
          INTO   v_chk_receipt_tax_lines
          FROM JAI_RCV_LINE_TAXES
          WHERE shipment_line_id = p_shipment_line_id
          AND   shipment_header_id = p_shipment_header_id
          AND   tax_id = tax_rec.tax_id;

          -- END of Addition by GSRI on 21-OCT-01
          IF v_chk_receipt_tax_lines = 0 THEN

            INSERT INTO JAI_RCV_LINE_TAXES
            (
              shipment_line_id,
              tax_line_no,
              shipment_header_id,
              tax_id,
              tax_name,
              currency,
              tax_rate,
              qty_rate,
              uom,
              tax_amount,
              tax_type,
              modvat_flag,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              vendor_id,
              --3848133
              precedence_1,
              precedence_2,
              precedence_3,
              precedence_4,
              precedence_5,
              precedence_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
              precedence_7,
              precedence_8,
              precedence_9,
              precedence_10,
        transaction_id
              --3848133
            )
            VALUES
            (
              p_shipment_line_id,
              tax_rec.tax_line_no,
              p_shipment_header_id,
              tax_rec.tax_id,
              tax_rec.tax_name,
              p_currency_code,
              tax_rec.tax_rate,
              tax_rec.qty_rate,
              tax_rec.uom,
              v_cor_amount,
              tax_rec.tax_type,
              v_tax_modvat_flag,
              p_creation_date,
              p_created_by,
              p_last_update_date,
              p_last_updated_by,
              p_last_update_login,
              v_internal_vendor,
              --3848133
              tax_rec.precedence_1,
              tax_rec.precedence_2,
              tax_rec.precedence_3,
              tax_rec.precedence_4,
              tax_rec.precedence_5,
              tax_rec.precedence_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
              tax_rec.precedence_7,
              tax_rec.precedence_8,
              tax_rec.precedence_9,
              tax_rec.precedence_10,
        p_transaction_id
              --3848133
            );
          END IF;

          IF tax_rec.tax_type NOT IN ('TDS', 'Modvat Recovery') THEN
            v_tax_total := v_tax_total + NVL(v_cor_amount * v_conv_factor, 0);
          END IF;

        END LOOP;

        update_receipt_line;

      END IF;

      IF v_debug_flag = 'Y' THEN
        UTL_FILE.PUT_LINE(v_myfilehandle,'Before the condition if p_transaction_type is UNORDERED ');
      END IF;

      IF p_transaction_type = 'UNORDERED'
        /* R12-PADDR AND  v_chk_form IS NOT NULL   */
      THEN

        IF v_debug_flag = 'Y' THEN
          UTL_FILE.PUT_LINE(v_myfilehandle,'Before set receipt flag');
        END IF;

        set_receipt_flag;

        IF v_debug_flag = 'Y' THEN
          UTL_FILE.PUT_LINE(v_myfilehandle,'After set receipt flag');
        END IF;

        v_receipt_modify_flag := 'N';

        IF v_debug_flag = 'Y' THEN
          UTL_FILE.PUT_LINE(v_myfilehandle,'Before Insert Receipt Line Procedure');
        END IF;

        insert_receipt_line;

        IF v_debug_flag = 'Y' THEN
          UTL_FILE.PUT_LINE(v_myfilehandle,'After Insert Receipt Line Procedure');
        END IF;

      END IF;

    END IF;


    -- Vijay Shankar for Bug#3940588. no more processing is required. so return back
  --  GOTO end_of_procedure;
  --  NULL;

    /* A lot of Code is COMMENTED by Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
    Please refer to Old Version of the Object incase commented code needs to be looked at
    */

  --  <<end_of_procedure>>

    /* Validation for RETURN TO VENDOR transactions. following check is not required for Correct transactions because
     RTV creation should have taken care of this check
     Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG */
    FOR exc_rec IN (SELECT jrtl.tax_amount, jrtl.tax_type tax_type, nvl(mod_cr_percentage, 0) mod_cr_percentage
              , nvl(tax_types.regime_code, 'XXXX') regime_code
            FROM JAI_RCV_LINE_TAXES jrtl, JAI_CMN_TAXES_ALL jtc, jai_regime_tax_types_v tax_types
            WHERE shipment_line_id = p_shipment_line_id
            AND NVL(modvat_flag, 'N') = 'Y'
            AND jtc.tax_type = tax_types.tax_type(+)
            AND jrtl.tax_id = jtc.tax_id)
    LOOP

      if upper(exc_rec.tax_type) IN ('EXCISE', 'CVD', 'ADDL. EXCISE', 'OTHER EXCISE',
                JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,jai_constants.tax_type_exc_edu_cess, JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,jai_constants.tax_type_cvd_edu_cess)/*Bug5989740 bduvarag*/
      then
        v_chk_excise := NVL(v_chk_excise, 0) + (exc_rec.tax_amount * exc_rec.mod_cr_percentage / 100);

      /* following added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
      elsif exc_rec.regime_code = jai_constants.vat_regime then
        ln_chk_vat := nvl(ln_chk_vat, 0) + (exc_rec.tax_amount * exc_rec.mod_cr_percentage / 100);
      end if;

    END LOOP;

    /* following if condition for receive and match added by Vijay shankar for Bug#4250236(4245089) VAT Impl. */
    IF p_transaction_type in ('RECEIVE', 'MATCH') THEN

      IF v_rg_location_id = 0 THEN
        v_rg_location_id := null;
      END IF;

      open c_rgm_setup_for_orgn_loc(jai_constants.vat_regime, jai_constants.orgn_type_io,
              p_organization_id, v_rg_location_id);
      fetch c_rgm_setup_for_orgn_loc into ln_vat_setup_chk;
      close c_rgm_setup_for_orgn_loc;

      fnd_file.put_line( fnd_file.log, 'VAT SetupChkforOrgnLoc:'||ln_vat_setup_chk
        ||', ChkVat:'||nvl(ln_chk_vat, -999999)
        ||', Orgn:'||p_organization_id||', Loc:'||v_rg_location_id
      );

      IF nvl(ln_vat_setup_chk,0) = 0 and nvl(ln_chk_vat,0) <> 0 THEN
        errormsg:='Organization and Location is not attached to VAT Regime';
        RAISE_APPLICATION_ERROR (-20502, 'Organization and Location is not attached to VAT Regime');
      END IF;

    ELSIF p_transaction_type = 'RETURN TO VENDOR' THEN

     -- NULL;   --commented by bgowrava for Bug#6459894
      /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.*/
      /* Uncommented below statements by bgowrava for Bug#6459894*/
      open c_fetch_unclaim_cenvat;
      fetch c_fetch_unclaim_cenvat into v_unclaim_cenvat_flag,
                                        v_cenvat_claimed_ptg,
          v_non_bonded_delivery_flag,
          v_cenvat_amount;
      close c_fetch_unclaim_cenvat;

   /*   IF v_debug_flag = 'Y' THEN
        UTL_FILE.PUT_LINE(v_myfilehandle,' ABC1. v_register_type:' || v_register_type
          || ', v_chk_excise:' || v_chk_excise||', v_item_modvat_flag:' || v_item_modvat_flag
          ||', v_item_class:' || v_item_class||', chkVat:'||ln_chk_vat );
        UTL_FILE.PUT_LINE(v_myfilehandle,' ABC2. v_cenvat_claimed_ptg:' || v_cenvat_claimed_ptg
          ||', v_manufacturing:' || v_manufacturing ||', v_non_bonded_flag:' || v_non_bonded_delivery_flag
          ||', unclaim_flag:'||v_unclaim_cenvat_flag);
      END IF;*/

      FOR i IN (select manufacturing from JAI_CMN_INVENTORY_ORGS where organization_id=p_organization_id) loop
        v_manufacturing := i.manufacturing;
        EXIT WHEN v_manufacturing IS NOT NULL;
      END LOOP;

      open c_rcv_rgm_dtl(jai_constants.vat_regime, p_shipment_line_id);
      fetch c_rcv_rgm_dtl into r_rcv_rgm_dtl;
      close c_rcv_rgm_dtl;

      /* Bug 4516678. Added by Lakshmi Gopalsami */
      pick_register_type(p_organization_id,
                         v_item_id,
       v_register_type );

      IF  NVL(v_item_modvat_flag, 'N') = 'Y'
        AND NVL(v_chk_excise, 0) <> 0
        AND v_item_class in ('RMIN','RMEX','CGIN', 'CGEX','CCIN','CCEX')
        AND nvl(v_cenvat_claimed_ptg,0) = 0
        AND nvl(v_manufacturing, 'N') = 'Y'
        AND nvl(v_non_bonded_delivery_flag,'N') = 'N'
        AND nvl(v_unclaim_cenvat_flag,'N') = 'N'
      THEN
        errormsg:='RTV not allowed as the CENVAT has not been claimed';
        RAISE_APPLICATION_ERROR (-20501, 'RTV not allowed as the CENVAT has not been claimed');
      --END IF; commented for bug4516678

      /* Bug 4516678. Added by Lakshmi Gopalsami
         Added the following code
      */
      ELSIF v_register_type ='C'  -- implies item is CGIN /CGEX
          and v_cenvat_amount > 0
          and v_cenvat_claimed_ptg  < 100 then

        -- fetch the receipt quantity
  open  c_fetch_receive_quantity(p_shipment_header_id,
         p_shipment_line_id);
  fetch c_fetch_receive_quantity into v_receipt_quantity;
  close c_fetch_receive_quantity;

  -- fetch the total quantity returned

  open  c_fetch_transaction_quantity(p_shipment_header_id,
       p_shipment_line_id,'RETURN TO VENDOR');
  fetch c_fetch_transaction_quantity into v_sum_rtv_quantity;
  close c_fetch_transaction_quantity;

  if v_receipt_quantity = v_sum_rtv_quantity and nvl(v_non_bonded_delivery_flag,'N') ='N' then --3456636,3273075
   FND_FILE.PUT_LINE(FND_FILE.LOG, ' 6_30 The RTV Quantity is Equal to Receipt Quantity and the Remaining 50% Cenvat is not availed ');
   FND_FILE.PUT_LINE(FND_FILE.LOG, ' 6_31 Please avail the remaining Cenvat credit and then proceed with  RTV ' );
   errormsg:='RETURN TO VENDOR not allowed.Please claim remaining 50% cenvat' ;
   raise_application_error(-20110,'RETURN TO VENDOR not allowed.Please claim remaining 50% cenvat' );
  end if;
      End if; -- End for bug 4516678


      fnd_file.put_line( fnd_file.log, 'ItmModFlg:'||v_item_modvat_flag
        ||', ChkVat:'||nvl(ln_chk_vat, -999999)
        ||', procStaFlg:'||r_rcv_rgm_dtl.process_status_flag
        ||', invNo:'||nvl(r_rcv_rgm_dtl.invoice_no,'ABCDEF')
      );

      -- following added by Vijay Shankar for Bug#4250236(4245089). VAT Impl.
      -- Before VAT is fully Claimed if RTV is being done, then we should error out the transaction
     /* IF  lv_vat_recoverable_for_item = jai_constants.yes
        AND NVL(ln_chk_vat, 0) <> 0
        AND r_rcv_rgm_dtl.process_status_flag <> 'U'  -- Not Unclaimed
        AND r_rcv_rgm_dtl.invoice_no IS NULL          -- if this is given it means then VAT is eligible for claim
      THEN
        RAISE_APPLICATION_ERROR (-20502, 'RETURN TO VENDOR not allowed as VAT Amount is not Claimed');
      END IF;
      */ --commented by Ramananda for Bug #4530112
    END IF;

    IF v_debug_flag = 'Y' THEN
      UTL_FILE.PUT_LINE(v_myfilehandle,'*********End of the Receipt taxes procedure********');
      UTL_FILE.FCLOSE(v_myfileHandle);
    END IF;


   /* Added by Ramananda for bug# exc_objects */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', '. Err:'||sqlerrm ); --bgowrava for bug#6459894
            app_exception.raise_exception (
                    EXCEPTION_TYPE  => 'APP',
                    EXCEPTION_CODE  => -20110 ,
                    EXCEPTION_TEXT  => errormsg
                                    );


  END default_taxes_onto_line;

END jai_rcv_tax_pkg;

/
