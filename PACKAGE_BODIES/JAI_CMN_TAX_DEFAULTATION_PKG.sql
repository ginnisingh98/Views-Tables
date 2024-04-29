--------------------------------------------------------
--  DDL for Package Body JAI_CMN_TAX_DEFAULTATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_TAX_DEFAULTATION_PKG" AS
/* $Header: jai_cmn_tax_dflt.plb 120.13.12010000.12 2010/06/11 07:24:14 boboli ship $ */

/*Bug 8371741 - Start*/

PROCEDURE get_created_from
(
p_header_id      IN NUMBER,
p_created_from OUT NOCOPY VARCHAR2
) IS
--PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    select jat.created_from into p_created_from
           from JAI_AR_TRXS jat
           where jat.customer_trx_id = p_header_id;
END;

/*Bug 8371741 - End*/

/*
Bug 8241905 - Added the procedure to get the quantity from the parent requistion
line to split the taxes in the child lines
Used Autonomous transaction as po_requistion_lines_all needs to be queried
*/
PROCEDURE ja_in_po_get_reqline_p
(
    p_req_line_id IN NUMBER,
    p_prev_quantity OUT NOCOPY NUMBER
) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    select quantity into p_prev_quantity
           from po_requisition_lines_all
           where requisition_line_id =  p_req_line_id;
END;

PROCEDURE ja_in_cust_default_taxes (
    p_org_id NUMBER,
    p_customer_id NUMBER,
    p_ship_to_site_use_id NUMBER,
    p_inventory_item_id IN NUMBER,
    p_header_id NUMBER,
    p_line_id NUMBER,
    p_tax_category_id IN OUT NOCOPY NUMBER
)
IS
    v_address_id           NUMBER;
    v_tax_category_list    VARCHAR2(30);
    v_tax_category_id      NUMBER;

   /* Added by Ramananda for bug#4407165 */
   lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_tax_defaultation_pkg.ja_in_cust_default_taxes';

    -- to get address_id
    CURSOR address_cur(p_ship_to_site_use_id IN NUMBER) IS
        SELECT cust_acct_site_id address_id
        FROM hz_cust_site_uses_all  A -- Removed ra_site_uses_all from Bug# 4434287
        WHERE A.site_use_id = p_ship_to_site_use_id;

    -- to get tax_category_list
    CURSOR tax_catg_list_cur(p_customer_id IN NUMBER, p_address_id IN NUMBER DEFAULT 0) IS
        SELECT tax_category_list
        FROM JAI_CMN_CUS_ADDRESSES a
        WHERE A.customer_id = p_customer_id
        AND A.address_id = p_address_id;

    -- to get tax_category_id
    CURSOR tax_catg_id_cur(p_tax_category_list IN VARCHAR2, p_inventory_item_id IN NUMBER) IS
        SELECT tax_category_id
        FROM JAI_INV_ITM_TAXCTG_DTLS a
        WHERE a.tax_category_list = p_tax_category_list
        AND a.inventory_item_id = p_inventory_item_id;

BEGIN

    OPEN address_cur(p_ship_to_site_use_id);
    FETCH address_cur INTO v_address_id;
    CLOSE address_cur;

    IF p_customer_id IS NOT NULL AND v_address_id IS NOT NULL THEN
        OPEN tax_catg_list_cur(p_customer_id , v_address_id);
        FETCH tax_catg_list_cur INTO v_tax_category_list;
        CLOSE tax_catg_list_cur;
    END IF;

    IF  v_tax_category_list IS NULL THEN
        OPEN tax_catg_list_cur(p_customer_id,0);
        FETCH tax_catg_list_cur INTO v_tax_category_list;
        CLOSE tax_catg_list_cur;
    END IF;

    IF v_tax_category_list IS NOT NULL THEN
        OPEN tax_catg_id_cur(v_tax_category_list, p_inventory_item_id);
        FETCH tax_catg_id_cur INTO v_tax_category_id;
        CLOSE tax_catg_id_cur;
    -- ELSE -- redundant
    --  ja_in_org_default_taxes(p_org_id, p_inventory_item_id, v_tax_category_id);
    END IF;

    IF v_tax_category_id IS NULL THEN

    /* redundant code
        OPEN tax_catg_list_cur(p_customer_id,0);
        FETCH tax_catg_list_cur INTO v_tax_category_list;
         CLOSE tax_catg_list_cur;

        IF v_tax_category_list IS NOT NULL THEN
            OPEN tax_catg_id_cur(v_tax_category_list ,p_inventory_item_id );
            FETCH tax_catg_id_cur INTO v_tax_category_id;
            CLOSE tax_catg_id_cur;
        -- ELSE -- redundant
        --  ja_in_org_default_taxes(p_org_id, p_inventory_item_id, v_tax_category_id);
        END IF;

        IF v_tax_category_id IS NULL THEN
            ja_in_org_default_taxes(p_org_id, p_inventory_item_id, v_tax_category_id);
        END IF;
    */
        ja_in_org_default_taxes(p_org_id, p_inventory_item_id, v_tax_category_id);

    END IF;

    p_tax_category_id := v_tax_category_id;


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END ja_in_cust_default_taxes;

/***********************************************************************************************************************/
PROCEDURE ja_in_vendor_default_taxes(
    p_org_id NUMBER,
    p_vendor_id NUMBER,
    p_vendor_site_id NUMBER,
    p_inventory_item_id IN NUMBER,
    p_header_id NUMBER,
    p_line_id NUMBER,
    p_tax_category_id IN OUT NOCOPY NUMBER
) IS

    v_tax_category_list VARCHAR2(30);
    v_tax_category_id   NUMBER;

   /* Added by Ramananda for bug#4407165 */
   lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_tax_defaultation_pkg.ja_in_vendor_default_taxes';

    -- to get tax_category_list
    CURSOR tax_catg_list_cur(p_vendor_id IN NUMBER, p_vendor_site_id  IN NUMBER DEFAULT 0) IS
        SELECT tax_category_list
        FROM JAI_CMN_VENDOR_SITES A
        WHERE a.vendor_id = p_vendor_id
        AND a.vendor_site_id = p_vendor_site_id;

    -- to get tax_category_id
    CURSOR tax_catg_id_cur(p_tax_category_list IN VARCHAR2, p_inventory_item_id IN NUMBER) IS
        SELECT tax_category_id
        FROM JAI_INV_ITM_TAXCTG_DTLS a
        WHERE a.tax_category_list = p_tax_category_list
        AND a.inventory_item_id = p_inventory_item_id;

BEGIN

    IF p_vendor_id IS NOT NULL AND p_vendor_site_id IS NOT NULL THEN
        OPEN tax_catg_list_cur(p_vendor_id, p_vendor_site_id);
        FETCH tax_catg_list_cur INTO v_tax_category_list;
        CLOSE tax_catg_list_cur;
    END IF;

    IF  v_tax_category_list IS NULL THEN
        OPEN tax_catg_list_cur(p_vendor_id,0);
        FETCH tax_catg_list_cur INTO v_tax_category_list;
        CLOSE tax_catg_list_cur;
    END IF;

    IF v_tax_category_list IS NOT NULL THEN
        OPEN tax_catg_id_cur(v_tax_category_list ,p_inventory_item_id );
        FETCH tax_catg_id_cur INTO v_tax_category_id;
        CLOSE tax_catg_id_cur;
    -- ELSE redundant code
    --  ja_in_org_default_taxes(p_org_id, p_inventory_item_id, v_tax_category_id);
    END IF;

    IF NVL(v_tax_category_id,0) = 0 THEN

    /* REDUNDANT CODE
        OPEN tax_catg_list_cur(p_vendor_id,0);
        FETCH tax_catg_list_cur INTO v_tax_category_list;
        CLOSE tax_catg_list_cur;

        IF v_tax_category_list IS NOT NULL THEN
            OPEN tax_catg_id_cur(v_tax_category_list ,p_inventory_item_id );
            FETCH tax_catg_id_cur INTO v_tax_category_id;
            CLOSE tax_catg_id_cur;
        ELSE
            ja_in_org_default_taxes(p_org_id, p_inventory_item_id, v_tax_category_id);
        END IF;

        IF NVL(v_tax_category_id,0) = 0 THEN
            ja_in_org_default_taxes(p_org_id, p_inventory_item_id, v_tax_category_id);
        END IF;
    */

        ja_in_org_default_taxes(p_org_id, p_inventory_item_id, v_tax_category_id);

    END IF;

    p_tax_category_id := v_tax_category_id;

   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END ja_in_vendor_default_taxes;

---------------******************JA_IN_ORG_DEFAULT_TAXES******************---------------------

PROCEDURE ja_in_org_default_taxes(
    p_org_id                    NUMBER,
    p_inventory_item_id IN      NUMBER,
    p_tax_category_id   IN OUT NOCOPY NUMBER
) IS
/*------------------------------------------------------------------------------------------
CHANGE HISTORY:

Sl. YYYY/MM/DD  Author and Details
------------------------------------------------------------------------------------------
1 2004/09/22  Aiyer for bug#3792765. Version#115.2
                Issue
         Warehouse ID is not currently being allowed to be left null from the base apps sales order. When placing a order from 2
         different manufacturing organizations, it is required that customer temporarily leaves the warehouseid as Null and then
         updates the same before pick release. However this is currently not allowed by localization even though base
         apps allows this feature.

        Reason:-
         The trigger ja_in_oe_order_lines_aiu_trg raises an error of warehouse not found when the value of warehouse_id goes as
         null from the form.

                Solution:-
         Removed this part from the trigger ja_in_oe_order_lines_aiu_trg. The procedure jai_cmn_tax_defaultation_pkg.ja_in_org_default_taxes has been modified
         for the same.
         During tax defaultation, if the tax category list is not found in the customer/customer site level then it is being picked up from the
         item class level. Now in cases where the warehouseid is left blank in the base apps sales order form, the tax category id from the
         master organization set for the default operating unit is picked up for further processing

                Dependency Due to this Bug:-
                 Functional dependency with the trigger ja_in_oe_order_lines_aiu_trg.sql version 115.4

2 31/10/2006  SACSETHI for bug 5228046, File version 120.3
              1. Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
                 This bug has datamodel and spec changes.

              2. Forward porting of bug 5219225

3  25/04/2007  cbabu for BUG#6012570 (5876390 )version = 120.5 (115.29 )
                   FP: Project Billing
4 05/06/2007  bduvarag for the bug#6081966 and 5989740, File version 120.8
      forward porting the 11i bugs 6074792 and 5907436

5.  01-08-2007           rchandan for bug#6030615 , Version 120.10
                         Issue : Inter org Forward porting
----------------------------------------------------------------------------------------------------------------------------------------------------*/
/* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_tax_defaultation_pkg.ja_in_org_default_taxes';


    --Code Added on 18-SEP-2000, Srihari and Gsrinivas
    v_operating_unit NUMBER;
  /*
  || Start of bug 3792765
  || Cursor added by aiyer to get the operating unit and master organization id in case the warehouse id is passed
  || as null from the Base apps sales order form.
  */
  CURSOR cur_get_master_org_id
  IS
    SELECT
         org_id                 operating_unit,
       master_organization_id
  FROM
         oe_system_parameters ;
  /*
  || End of bug 3792765
  */


    CURSOR operating_unit_cur(c_org_id NUMBER) IS
        SELECT operating_unit
        FROM org_organization_definitions
        WHERE organization_id = NVL(c_org_id, 0);

    -- to get tax_category_id from Item class
    CURSOR tax_catg_id_cur(v_org_id IN NUMBER, v_inventory_item_id IN NUMBER, v_operating_unit NUMBER) IS
        SELECT b.tax_category_id
        FROM JAI_INV_ITM_SETUPS a , JAI_CMN_TAX_CTGS_ALL b  -- redundant, org_organization_definitions c
        WHERE a.item_class = b.item_class_cd
        AND a.inventory_item_id = v_inventory_item_id
        AND a.organization_id = v_org_id
        AND b.org_id = v_operating_unit;
    --End of Addition , Srihari and Gsrinivas

  rec_cur_get_master_org_id CUR_GET_MASTER_ORG_ID%ROWTYPE;
BEGIN
  /*
  || Start of bug 3792765
  || IF the warehouse id i.e the invemtory organization id is null from the SAles order base apps form
  || then in that case get the operating unit and master organization id from the oe_system_parameters table
  */

  IF p_org_id IS NULL THEN
    OPEN  cur_get_master_org_id;
    FETCH cur_get_master_org_id INTO rec_cur_get_master_org_id ;
    CLOSE cur_get_master_org_id ;
    v_operating_unit := rec_cur_get_master_org_id.operating_unit;
  ELSE
  /*
  || End of bug 3792765
  */

      OPEN operating_unit_cur(p_org_id);
      FETCH operating_unit_cur INTO v_operating_unit;
      CLOSE operating_unit_cur;
    END IF;

    v_operating_unit := NVL(v_operating_unit, 0);

    OPEN tax_catg_id_cur( nvl(p_org_id,rec_cur_get_master_org_id.master_organization_id) , p_inventory_item_id , v_operating_unit);
    FETCH tax_catg_id_cur INTO p_tax_category_id;
    CLOSE tax_catg_id_cur;

  /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END ja_in_org_default_taxes;

/*****************************JA_IN_CALC_PREC_TAXES********************************/

PROCEDURE ja_in_calc_prec_taxes(
        transaction_name        VARCHAR2,
        p_tax_category_id       NUMBER,
        p_header_id             NUMBER,
        p_line_id               NUMBER,
        p_assessable_value  NUMBER DEFAULT 0,
        p_tax_amount    IN OUT NOCOPY NUMBER,
        p_inventory_item_id     NUMBER,
        p_line_quantity         NUMBER,
        p_uom_code              VARCHAR2,
        p_vendor_id             NUMBER,
        p_currency              VARCHAR2,
        p_currency_conv_factor  NUMBER,
        p_creation_date         DATE,
        p_created_by            NUMBER,
        p_last_update_date      DATE,
        p_last_updated_by       NUMBER,
        p_last_update_login     NUMBER,
        p_operation_flag        NUMBER DEFAULT NULL , -- for CRM this is used to hold aso_shipments.shipment_id
        p_vat_assessable_value  NUMBER DEFAULT 0
        /** bgowrava for forward porting bug#5631784,Following parameters are added for TCS enh.*/
  , p_thhold_cat_base_tax_typ JAI_CMN_TAXES_ALL.tax_type%type default null  -- tax type to be considered as base when calculating threshold taxes
  , p_threshold_tax_cat_id    JAI_AP_TDS_THHOLD_TAXES.tax_category_id%type default null
  , p_source_trx_type         jai_cmn_document_taxes.source_doc_type%type default null
  , p_source_table_name       jai_cmn_document_taxes.source_table_name%type default null
  , p_action                  varchar2  default null
        /** End bug 5631784 */
  , pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price 2008/01/13
  , p_modified_by_agent_flag  po_requisition_lines_all.modified_by_agent_flag%type default NULL /*Added for Bug 8241905*/
  , p_parent_req_line_id      po_requisition_lines_all.parent_req_line_id%type default NULL /*Added for Bug 8241905*/
    , p_max_tax_line            NUMBER DEFAULT 0 /*Added for Bug 8371741*/
    , p_max_rgm_tax_line        NUMBER DEFAULT 0 /*Added for Bug 8371741*/
) IS
    --TYPE num_tab IS TABLE OF NUMBER(30,3) INDEX BY BINARY_INTEGER; -- sriram - bug # 2812781 was 14 eaerler changed to 30
    --TYPE tax_amt_num_tab IS TABLE OF NUMBER(30,3) INDEX BY BINARY_INTEGER; -- sriram - bug # 2812781 was 14 eaerler changed to 30


-- Date 02/11/2006 Bug 5228046 added by SACSETHI

      TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE tax_amt_num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE tax_adhoc_flag_tab  IS TABLE OF VARCHAR2(2) INDEX BY BINARY_INTEGER; /* rchandan bug#6030615 */

      --added by Walton for inclusive tax 07-Dev-07
      ---------------------------------------------
      TYPE char_tab IS TABLE OF  VARCHAR2(10)
      INDEX BY BINARY_INTEGER;

      lt_adhoc_tax_tab          CHAR_TAB;
      lt_inclusive_tax_tab      CHAR_TAB;
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
      -----------------------------------------------
      base_tax_amount_nr_tab tax_amt_num_tab; --added by Xiao Lv for bug#8789761

    /* Added by Ramananda for bug#4407165 */
    lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_tax_defaultation_pkg.ja_in_calc_prec_taxes';

    p1          NUM_TAB;
    p2          NUM_TAB;
    p3          NUM_TAB;
    p4          NUM_TAB;
    p5          NUM_TAB;

-- Date 31/10/2006 Bug 5228046 added by SACSETHI
-- start bug 5228046
    p6          NUM_TAB;
    p7          NUM_TAB;
    p8          NUM_TAB;
    p9          NUM_TAB;
    p10         NUM_TAB;
    line_no_tab NUM_TAB;  --added for bug#9214366
-- end bug 5228046

    tax_rate_tab        NUM_TAB;
    /*
    || Aiyer for the fwd ported bug#4691616 . Added tax_rate_zero_tab table
       -------------------------------------------------------------
       tax_rate(i)            tax_rate_tab(i)   tax_rate_zero_tab(i)
       -------------------------------------------------------------
       NULL                       0                 0
       0                          0               -9999
       n (non-zero and not null)  n                 n
       -------------------------------------------------------------
    */
    tax_rate_zero_tab   NUM_TAB;

    tax_type_tab        NUM_TAB;
    tax_target_tab  NUM_TAB;
    tax_amt_tab         TAX_AMT_NUM_TAB;
    round_factor_tab     TAX_AMT_NUM_TAB; --added by csahoo for bug#6077133
    base_tax_amt_tab    TAX_AMT_NUM_TAB;
    func_tax_amt_tab    TAX_AMT_NUM_TAB;
    adhoc_flag_tab      TAX_ADHOC_FLAG_TAB ; /* rchandan bug#6030615 */
    end_date_tab        NUM_TAB;

    bsln_amt            NUMBER;  -- := p_tax_amount; --Ramananda for File.Sql.35

    v_conversion_rate       NUMBER;  -- := 0; --Ramananda for File.Sql.35
    v_currency_conv_factor  NUMBER; -- := p_currency_conv_factor;  --Ramananda for File.Sql.35


-- Date 01/11/2006 Bug 5228046 added by SACSETHI

-- v_tax_amt               NUMBER(25,3) := 0;  -- cbabu for EnhancementBug# 2427465
-- v_func_tax_amt          NUMBER(25,3) := 0;
-- vamt                    NUMBER(25,3) := 0;

   v_tax_amt               NUMBER := 0;
   v_func_tax_amt          NUMBER := 0;
   vamt                    NUMBER := 0;

    v_amt                   NUMBER;
    row_count               NUMBER := 1;
    counter                 NUMBER;
    max_iter                NUMBER := 10;
    v_excise_jb             NUMBER;

    v_line_focus_id_holder JAI_PO_LINE_LOCATIONS.line_focus_id%TYPE;  -- cbabu for EnhancementBug# 2427465


    /** bgowrava, Begin forward porting bug#5631784 */
          refc_tax_cur          ref_cur_typ;
          rec                   tax_rec_typ;
          type tax_table_typ  is
          table of tax_rec_typ index by binary_integer;
          lt_tax_table          tax_table_typ;

          ln_max_tax_line       number;
          ln_max_rgm_tax_line   number;
          ln_base               number  ;
          ln_dup_tax_exists     number;

          v_modvat_flag         varchar2(1);  -- moved from prev location to here
          lv_recalculation_sql  varchar2 (4000);
          ln_exists             number  (2);

          ln_prev_quantity      NUMBER;       /*Bug 8241905*/
          ln_tax_modified_flag  VARCHAR2(1);  /*Bug 8241905*/
          ln_rounding_factor    NUMBER;       /*Bug 8241905*/
      l_created_from        VARCHAR2(10); /*Bug 8371741*/

          /*
          || Cursor will check if the given tax_categories have common taxes
          */
          cursor c_chk_tax_duplication
          is
            select 1
            from JAI_CMN_TAX_CTG_LINES
            where tax_category_id in (p_tax_category_id, nvl(p_threshold_tax_cat_id,-1))
            group by tax_id
            having count(tax_id) > 1;

          cursor c_get_max_tax_line
          is
            select max(line_no) max_tax_line
            from   JAI_CMN_TAX_CTG_LINES cat
            where  cat.tax_category_id = p_tax_category_id;

          cursor c_get_max_rgm_tax_line
          is
            select max(line_no) max_rgm_tax_line
            from   JAI_CMN_TAX_CTG_LINES cat, JAI_CMN_TAXES_ALL taxes
            where  cat.tax_category_id = p_tax_category_id
            and    taxes.tax_id = cat.tax_id
            and    taxes.tax_type = p_thhold_cat_base_tax_typ;

          /** End Bug#5631784*/


    CURSOR tax_cur(p_tax_category_id IN NUMBER) IS
        SELECT a.tax_category_id, a.tax_id, a.line_no lno,
            a.precedence_1 p_1, a.precedence_2 p_2,
      a.precedence_3 p_3, a.precedence_4 p_4,
      a.precedence_5 p_5, a.precedence_6 p_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI
      a.precedence_7 p_7, a.precedence_8 p_8,
      a.precedence_9 p_9, a.precedence_10 p_10,
            b.tax_rate, b.tax_amount, b.uom_code, b.end_date valid_date,
            DECODE(rgm_tax_types.regime_Code,jai_constants.vat_regime, 4,  /* added by ssumaith - bug# 4245053*/
                   DECODE(UPPER(b.tax_type),
                          'EXCISE',                 1,
                          'ADDL. EXCISE',           1,
                          'OTHER EXCISE',           1,
                          'TDS',                    2,
                          'EXCISE_EDUCATION_CESS'  ,1,
                          'CVD_EDUCATION_CESS'     ,1,
                          0
                         )
                  ) tax_type_val,
            b.mod_cr_percentage, b.vendor_id, b.tax_type,nvl(b.rounding_factor,0) rounding_factor
      , inclusive_tax_flag --added by walton for inclusive tax 08-Dev-07
        FROM JAI_CMN_TAX_CTG_LINES a, JAI_CMN_TAXES_ALL b  ,
             jai_regime_tax_types_v rgm_tax_types   /* added by ssumaith - bug# 4245053*/
        WHERE a.tax_category_id = p_tax_category_id
        AND   rgm_tax_types.tax_type (+) = b.tax_type /* added by ssumaith - bug# 4245053*/
        AND a.tax_id = b.tax_id
        -- AND (b.end_date >= sysdate OR b.end_date IS NULL)
        ORDER BY A.line_no;

    CURSOR uom_class_cur(p_line_uom_code IN VARCHAR2, p_tax_line_uom_code IN VARCHAR2) IS
        SELECT a.uom_class
        FROM mtl_units_of_measure A, mtl_units_of_measure B
        WHERE a.uom_code = p_line_uom_code
        AND b.uom_code = p_tax_line_uom_code
        AND a.uom_class = b.uom_class;

    --2001/03/30 Manohar Mishra
    /*Start of Addition*/
    v_organization_id   NUMBER;
    v_location_id       NUMBER;
    v_batch_source_id   NUMBER;
    v_register_code     JAI_OM_OE_BOND_REG_HDRS.register_code%TYPE;

    CURSOR get_header_info_cur IS
        SELECT organization_id, location_id, batch_source_id
        FROM JAI_AR_TRXS
        WHERE customer_trx_id = p_header_id;

    CURSOR get_register_code_cur(p_organization_id NUMBER, p_location_id NUMBER, p_batch_source_id NUMBER) IS
        SELECT register_code
        FROM JAI_OM_OE_BOND_REG_HDRS
        WHERE organization_id = p_organization_id
        AND location_id     = p_location_id
        AND register_id IN (SELECT register_id
            FROM JAI_OM_OE_BOND_REG_DTLS
            WHERE order_type_id = p_batch_source_id
            AND order_flag = 'N');

    v_debug boolean := true;        -- Vijay Shankar for Bug# 2837970
    v_line_num number:=1 ;--added by rchandan for bug#6030615
    ln_reg_id   number;

    /*End of Addition*/
    uom_cls UOM_CLASS_CUR%ROWTYPE;

lv_tax_remain_flag        VARCHAR2(1);  --Added by Kevin Cheng for Retroactive Price 2008/01/13
lv_transaction_name       VARCHAR2(30); --Added by Kevin Cheng for Retroactive Price 2008/01/13
lv_start                  NUMBER;       --Added by Kevin Cheng for Retroactive Price 2008/01/13
lv_line_loc_id            NUMBER;       --Added by Kevin Cheng for Retroactive Price 2008/01/13
lv_process_flag           VARCHAR2(10);   --Added by Kevin Cheng for Retroactive Price 2008/01/13
lv_process_message        VARCHAR2(2000); --Added by Kevin Cheng for Retroactive Price 2008/01/13

BEGIN
/*************************************************************************************************************************
/*----------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY:          Procedure ja_in_calc_prec_taxes
S.No    Date        Author and Details
------------------------------------------------------------------------------------------------------------------------

1.    12/07/2003    Aiyer - Bug #3749294 File Version 115.1
                    Issue:-
                    Uom based taxes do not get calculated correctly if the transaction UOM is different from the
                    UOM setup in the tax definitions India Localization (JAI_CMN_TAXES_ALL table).

                    Reason:-
                    --------
                    This was happening because the UOM calculation was previously happening only for cases of exact match
                    between transaction uom and setup UOM.

                    Fix:-
                    ----
                    Modified the procedure ja_in_calc_prec_taxes.The exact match condition was removed. Now if an exact match
                    is not found then the conversion rate between the two uom's is determined and tax amounts are calculated for
                    defaultation.

                    Dependency Due to This Bug:-
                    ----------------------------
                    None

2.  27/01/2005      ssumaith - bug#4136981 - Version 115.2

                    In case of Bond Register scenario , in addition to excise taxes , Excise Cess (EXCISE_EDUCATION_CESS,CVD_EDUCATION_CESS)
                    should also not flow to AR

3. 2005/03/10       ssumaith - bug# 4245053 - File version 115.3

                    Taxes under the vat regime needs to be calculated based on the vat assessable value setup done.
                    In the vendor additional information screen and supplier additional information screen, a place
                    has been given to capture the vat assessable value.

                    This needs to be used for the calculation of the taxes registered under vat regime.

                    This  change has been done by using the view jai_regime_tax_types_v - and outer joining it with the
                    JAI_CMN_TAXES_ALL table based on the tax type column.

                    Parameter - p_vat_assessable_value  NUMBER DEFAULT 0 has been added

                    Dependency due to this bug - Huge
                    This patch should always be accompanied by the VAT consolidated patch - 4245089


4.  01-Jun-2006     Aiyer for bug# 4691616. File Version 120.2
                     Issue:-
                       UOM based taxes do not get calculated correctly.

                     Solution:-
                      Fwd ported the fix for the bug 4729742.
                      Changed the files JAINTAX1.pld, jai_cmn_tax_dflt.plb and jai_om_tax.plb.

5.  24-Jan-2007     bgowrava for forward porting bug#5631784, File Version 120.3  - TCS Enhancement

                      Issue:
                      1.  As a part of TCS enh. there was a requirement to default taxes using the tax category attached to
                      threshold setup for TCS regime in the India-Threshold setup UI.
                      2.  Package should provide an API for inserting taxes in to new table jai_cmn_document_taxes

                      Fix:
                       To support above functionalities the following approach is used.
                        1.  New parameters are added to this procedure to get the tax category defined for threshold limit.
                            (Please refer the procedure signature)
                        2.  Whenever p_threshold_tax_cat_id is not NULL then it means taxes from two categories needs to be merged.
                            one using p_tax_category_id and other is p_threshold_tax_cat_id
                        3.  current driving cursor (tax_cur) is modified to handle multiple tax categories.
                            3.1  For all the tax lines defined in the p_tax_category_id there is no change
                            3.2  For all the tax lines defined in the p_threshold_tax_cat_id, line_no will be changed
                                 to ln_max_tax_line + line_no where ln_max_tax_line is the maximum  of line numbers for
                                 tax lines defined in p_tax_category_id
                            3.3  All the precedences defined in p_threshold_tax_cat_id will be changed as following
                                 -  If precedence refers to base precedence (i.e. 0) it will be changed to ln_max_rgm_tax_line
                                    where ln_max_rgm_tax_line is maximum of the line numbers of taxes having
                                    tax_type = p_thhold_cat_base_tax_typ (i.e. tax type to be considered as a base tax
                                    when calculating threshold taxes defined using p_threshold_tax_cat_id)
                                 -  All other precedences will be changed to precedence_N + ln_max_tax_line


6  04/june/2007    ssumaith - bug#6109941 - review comments for TCS .
                              TCS enhancement forward porting has some minor issues that were resolved.

7.  05-Jun-2007  CSahoo for bug#6077133, File version- 120.7
                              Issue: The Taxes at header and the Line level does not
                                         tally for the Manually created AR Transaction.
                               Fix: added a rounding factor round_factor_tab.

8.  16-Oct-2007   CSahoo for bug#6498072, File Version 120.12
                  R12RUP04-ST1: TCS TAXES ARE WRONG ON ADDING SURCHARGE
                  On creating a sales order and after delivery the taxes are taken only for a Single Quantity which is wrong.
                  so made changes in the code so that the taxes are taken for the whole quantity
9   01-Dev-2007   Walton for Inclusive Tax

10. 20-Nov-2008   JMEENA for bug#6488296( FP of 6475430)
                  Added OR condition in procedure ja_in_calc_prec_taxes as  we are passing p_action null in case of 'CASH' Receipt.

11.  14-Sep-2009  JMEENA for bug#8905076
                  Modified the update statement of table JAI_OM_WSH_LINE_TAXES and used base_tax_amt_tab instead of
                  tax_amt_tab to update the column base_tax_amount.

12. 4-Nov-2009    Xiao Lv for bug#8789761
                  Added variable base_tax_amount_nr_tab with type of tax_amt_num_tab to calculate base tax amount.
                  base_tax_amt_tab(I) := ln_exclusive_price*base_tax_amt_tab(I) + base_tax_amount_nr_tab.

13. 22-Dec-2009   CSahoo for bug#9214366, File Version 120.13.12010000.9
                  Issue: UNABLE TO SAVE AR TRANSACTION WITH VAT + TCS OR CST +TCS TYPE OF TAXES
                  Fix: Modified the code in the procedure ja_in_calc_prec_taxes. Added a new table type variable line_no_tab
                       to store the line number of the tax lines. Further added a code to initialize the tax_amt_tab table
                       for surcharge taxes.
14. 19-Mar-2010   Walton for bug#9288016, File Version 120.13.12010000.10
                  Issue: Function tax amount column is not populated correctly
                  Fix: in the old code, function tax amount only cover rate amount, when the taxes is computed based on assessable
                       value, non-rate amount is not getting summed, so the fix is to re-assign function base amount once tax amount
                       is computed.
15. 19-Mar-2010	JMEENA for bug#9489492
		 Modified the dynamic query lv_recalculation_sql and changed the order of columns $$EXTRA_SELECT_COLUMN_LIST$$ and inclusive_tax_flag
		 as inclusive_tax_flag is last column in the record type.

16  10-JUN-2010 Bo Li for Bug#9780751
    Issue - Round factor of vat tax is 0. But the accounting entry amount inserted into gl_interface table has 2 bit demical.
    Fix   - Set the same round factor to the functional tax amount which is used in the gl_interface table

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                    Version   Author   Date         Remarks
Of File                              On Bug/Patchset     Dependent On
jai_cmn_tax_defaultation_pkg.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
115.1                 2977185       IN60105D2             None                    --       Aiyer   13/07/2004   Row introduces to start dependency tracking

115.3                 4245053       IN60106 +                                              ssumaith             Service Tax and VAT Infrastructure are created
                                    4146708 +                                                                   based on the bugs - 4146708 and 4545089 respectively.
                                    4245089
*************************************************************************************************************************/
--Added by Kevin Cheng for Retroactive Price 2008/01/13
--=====================================================
IF pv_retroprice_changed = 'N'
THEN
--=====================================================
   --Ramananda for File.Sql.35
   bsln_amt := p_tax_amount ;
   v_conversion_rate := 0;
   v_currency_conv_factor  := p_currency_conv_factor;
   ln_base :=  0 ;

    IF transaction_name <> 'CRM_QUOTE' THEN     -- Vijay Shankar for Bug# 2837970
        IF v_debug THEN fnd_file.put_line(fnd_file.log, ' transaction_name -> '||transaction_name); END IF;

        --2001/03/30 Manohar Mishra
        /*Start of Addition*/
        OPEN get_header_info_cur;
        FETCH get_header_info_cur INTO v_organization_id, v_location_id, v_batch_source_id;
        CLOSE get_header_info_cur;

        OPEN get_register_code_cur(v_organization_id, v_location_id, v_batch_source_id);
        FETCH get_register_code_cur INTO v_register_code;
        CLOSE get_register_code_cur;

    -- Vijay Shankar for Bug# 2837970
    ELSE    -- this should get executed when tax defaultation is for CRM_QUOTE
        v_register_code := null;
    END IF;
    --2001/03/30 Manohar Mishra

    /*End of Addition*/

            /*Bug 8241905 - Start*/
      /*
           Fetch Tax modified flag of the parent line to check if taxes defaulted based on
           Tax Category attached to Vendor or Item have been modified. If 'Y' then the new
           taxes need to be used to calculate taxes of child lines else the normal defaultation
           logic can be used
      */
      BEGIN
             select tax_modified_flag into ln_tax_modified_flag
             from JAI_PO_REQ_LINES
             where requisition_line_id = p_parent_req_line_id;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
                  ln_tax_modified_flag := 'N';
      END;

      /*
           The line is split using Tools->Modify option in AutoCreate when p_parent_req_line_id is NOT NULL
           p_modified_by_agent_flag is set to 'Y' if it is parent line
      */
      if (transaction_name = 'PO_REQN' and (p_tax_category_id is null or ln_tax_modified_flag = 'Y')
           and p_modified_by_agent_flag is NULL and p_parent_req_line_id is NOT NULL) then

         for c_req_tax_lines in (select * from JAI_PO_REQ_LINE_TAXES
                                 where requisition_line_id = p_parent_req_line_id) loop

              /*Fetch quantity of parent line to populate taxes in child lines*/
              ja_in_po_get_reqline_p(p_parent_req_line_id, ln_prev_quantity);

              select rounding_factor into ln_rounding_factor
              from JAI_CMN_TAXES_ALL
              where tax_id = c_req_tax_lines.tax_id;

              /*Insert Tax Lines for child lines based on Tax lines of the parent*/
              insert into JAI_PO_REQ_LINE_TAXES(
                         requisition_line_id, requisition_header_id, tax_line_no,
                         precedence_1, precedence_2, precedence_3,
                         precedence_4, precedence_5,
                         precedence_6, precedence_7, precedence_8,
                         precedence_9, precedence_10,
                         tax_id, tax_rate, qty_rate, uom, tax_amount, Tax_Target_Amount,
                         tax_type, modvat_flag, vendor_id, currency,
                         creation_date, created_by, last_update_date,
                         last_updated_by, last_update_login,
                         tax_category_id
              ) VALUES (
                         p_line_id, c_req_tax_lines.requisition_header_id, c_req_tax_lines.tax_line_no,
                         c_req_tax_lines.precedence_1, c_req_tax_lines.precedence_2, c_req_tax_lines.precedence_3,
                         c_req_tax_lines.precedence_4, c_req_tax_lines.precedence_5,
                         c_req_tax_lines.precedence_6, c_req_tax_lines.precedence_7, c_req_tax_lines.precedence_8,
                         c_req_tax_lines.precedence_9, c_req_tax_lines.precedence_10,
                         c_req_tax_lines.tax_id, c_req_tax_lines.tax_rate, c_req_tax_lines.qty_rate,
                         c_req_tax_lines.uom,
                         round((c_req_tax_lines.tax_amount * p_line_quantity)/ln_prev_quantity, ln_rounding_factor),
                         round((c_req_tax_lines.Tax_Target_Amount * p_line_quantity)/ln_prev_quantity, ln_rounding_factor),
                         c_req_tax_lines.tax_type, c_req_tax_lines.modvat_flag, c_req_tax_lines.vendor_id,
                         c_req_tax_lines.currency,
                         c_req_tax_lines.creation_date, c_req_tax_lines.created_by, c_req_tax_lines.last_update_date,
                         c_req_tax_lines.last_updated_by, c_req_tax_lines.last_update_login,
                         c_req_tax_lines.tax_category_id
              );

          end loop;
       end if;

      /*Bug 8241905 - End*/


        /** bgowrava for forward porting bug#5631784*/
        if    ((p_tax_category_id is null
        and   (p_threshold_tax_cat_id is null or p_threshold_tax_cat_id <0)) or ln_tax_modified_flag = 'Y') then
            /*
           Bug 8241905 - Added ln_tax_modified_flag = 'Y' to prevent taxes defaulting in child lines from parent tax_category_id
           when the taxes are modified in the parent line. The modified taxes need to used to calculate
           taxes in child lines
      */
            /** Both driving parameter tax_category_id and threshol_tax_category_id are invalid hence no need to do anything */
          return;
        end if;

        if    nvl(p_action, jai_constants.default_taxes) = jai_constants.default_taxes then
          /** Assign tax defaultation cursor object to refc_tax_cur reference by using. Call to get_tax_cat_taxes_cur will return
          a reference cursor */

          if p_threshold_tax_cat_id is not null and p_threshold_tax_cat_id > 0 then
            /*
            ||  Cursor to check if same taxes exists in both tax categories
            */
            ln_dup_tax_exists := null;
     /*       jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Close/Fetch cursor c_chk_tax_duplication');*/ --commented by bgowrava for bug#5631784
            open   c_chk_tax_duplication;
            fetch  c_chk_tax_duplication into ln_dup_tax_exists;
            close  c_chk_tax_duplication;

     /*       jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'ln_dup_tax_exists='||ln_dup_tax_exists);*/ --commented by bgowrava for bug#5631784

            if ln_dup_tax_exists is not null
            or (nvl(p_threshold_tax_cat_id,-1) = p_tax_category_id)
            then

              fnd_message.set_name('JA', 'JAI_DUP_TAX_IN_TAX_CAT');
              app_exception.raise_exception ;

            end if;

     /*       jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Close/Fetch cursor c_get_max_tax_line');*/ --commented by bgowrava for bug#5631784
            open   c_get_max_tax_line;
            fetch  c_get_max_tax_line into ln_max_tax_line;
            close  c_get_max_tax_line ;

     /*       jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Close/Fetch cursor c_get_max_rgm_tax_line');*/ --commented by bgowrava for bug#5631784
            open   c_get_max_rgm_tax_line;
            fetch  c_get_max_rgm_tax_line into ln_max_rgm_tax_line;
            close  c_get_max_rgm_tax_line ;

      /*      jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'ln_max_tax_line='||ln_max_tax_line||', ln_max_rgm_tax_line='||ln_max_rgm_tax_line);*/ --commented by bgowrava for bug#5631784

          end if;
      /*Bug 8371741 - Start*/
      if ln_max_rgm_tax_line IS NULL then
         ln_max_rgm_tax_line := p_max_rgm_tax_line;
       ln_max_tax_line := p_max_tax_line;
      end if;
      /*Bug 8371741 - End*/

      /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Opening ref cursor');*/ --commented by bgowrava for bug#5631784
          get_tax_cat_taxes_cur ( p_tax_category_id        =>  p_tax_category_id
                                , p_threshold_tax_cat_id   =>  p_threshold_tax_cat_id
                                , p_max_tax_line           =>  ln_max_tax_line
                                , p_max_rgm_tax_line       =>  ln_max_rgm_tax_line
                                , p_refc_tax_cat_taxes_cur => refc_tax_cur
                                );

       /*   jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Cursor is opened');*/ --commented by bgowrava for bug#5631784

        elsif p_action = jai_constants.recalculate_taxes then
        /**
            Following is a dynamic sql string which can be modifed as per requirement

            The sql has four place holders defined as below
            $$EXTRA_SELECT_COLUMN_LIST$$    -  Use this place holder to select additional columns in the sql.
                                               You must also change corrosponding fetch statements and the record being used for fetch.
                                               SELECT statement above should also be changed to include the newly added columns
                                               as they are sharing a common cursor and fetch record.

            $$TAX_SOURCE_TABLE$$            -  At runtime this placeholder must be replaced with name of
                                               source table to be used for recalculation
            $$SOURCE_TABLE_FILTER$$         -  At runtime, this place holder must represent a boolean condition
                                               which can filter required rows from the source table
                                               for recalculation.  It must be the first condition and should never
                                               start with either AND or OR
            $$ADDITIONAL_WHERE_CLAUSE$$     -  Replace the placeholder with additional conditions if any.
                                               The condition must start with either AND or OR keyword
            $$ADDITIONAL_ORDER_BY$$         -  Replace the placeholder with list of columns and order sequence, if required.
                                               Column list must start with comma (,)
            If any of this placeholder is not required to be used it must be replaced with a null value as below
                replace ( lv_recalculation_sql
                        , '$$EXTRA_SELECT_COLUMN_LIST$$'
                        , ''
                        );
        */
        lv_recalculation_sql :=
           '  select  a.tax_id
                    , a.tax_line_no     lno
                    , a.precedence_1    p_1
                    , a.precedence_2    p_2
                    , a.precedence_3    p_3
                    , a.precedence_4    p_4
                    , a.precedence_5    p_5
                    , a.precedence_6    p_6
                    , a.precedence_7    p_7
                    , a.precedence_8    p_8
                    , a.precedence_9    p_9
                    , a.precedence_10   p_10
                    , a.tax_rate
                    , a.tax_amount
                    , b.uom_code
                    , b.end_date        valid_date
                    , DECODE(rttv.regime_code, '''||jai_constants.vat_regime||''', 4,  /* added by ssumaith - bug# 4245053*/
                                              DECODE(UPPER(b.tax_type), ''EXCISE''      , 1
                                                                      , ''ADDL. EXCISE'', 1
                                                                      , ''OTHER EXCISE'', 1
                                                                      , ''TDS''         , 2
                                                                      , ''EXCISE_EDUCATION_CESS'',6 --modified by walton for inclusive tax
                                                                      , '''||JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS||''' , 6 /*bduvarag for the bug#5989740*/ --modified by walton for inclusive tax
                                                                      , ''CVD_EDUCATION_CESS''   ,6 --modified by walton for inclusive tax
                                                                      , '''||JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS||''' , 6  /*bduvarag for the bug#5989740*/ --modified by walton for inclusive tax
                                                                      , 0
                                                    )
                            )           tax_type_val
                   , b.mod_cr_percentage
                   , b.vendor_id
                   , b.tax_type
                   , nvl(b.rounding_factor,0) rounding_factor
                  , b.adhoc_flag
                  $$EXTRA_SELECT_COLUMN_LIST$$
		  ,b.inclusive_tax_flag  --added by walton for inclusive tax on 08-Dev-07,--Added inclusive_tax_flag in end as it is last column in record type. by JMEENA for bug#9489492
              from  $$TAX_SOURCE_TABLE$$        a
                    , JAI_CMN_TAXES_ALL           b
                    , jai_regime_tax_types_v   rttv
              where $$SOURCE_TABLE_FILTER$$
              and   rttv.tax_type (+) = b.tax_type
              and   a.tax_id = b.tax_id   $$ADDITIONAL_WHERE_CLAUSE$$
              order by  a.tax_line_no   $$ADDITIONAL_ORDER_BY$$';


           /** No extra columns required. Dummy column (NULL) tax_category_id needs to be added in the last as same record (rec) is being used
               when fetching the cursor.  If there is a need to override this default behaviour then please replace these place holder with
               desired strings which can be evaluated at runtime by sql-engine
            */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$EXTRA_SELECT_COLUMN_LIST$$'
                    , ',null   tax_category_id'
                    );

            /** No additional filtering required */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$ADDITIONAL_WHERE_CLAUSE$$'
                    , ''
                    );

            /** No additional sorting required */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$ADDITIONAL_ORDER_BY$$'
                    , ''
                    );

        if  upper(p_source_trx_type) = jai_constants.source_ttype_delivery then

            /** replace the correct tax source table */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$TAX_SOURCE_TABLE$$'
                    , 'JAI_OM_WSH_LINE_TAXES'
                    );
            /** replace join condition */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$SOURCE_TABLE_FILTER$$'
                    , 'a.delivery_detail_id = ' || p_line_id
                    );
        elsif  upper(p_source_trx_type) = jai_constants.bill_only_invoice then

            /** For bill_only_invoice tax source table is ja_in_ra_cust_trx_tax_lines*/
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$TAX_SOURCE_TABLE$$'
                    , 'JAI_AR_TRX_TAX_LINES'
                    );
            /** replace join condition */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$SOURCE_TABLE_FILTER$$'
                    , 'a.link_to_cust_trx_line_id = ' || p_line_id
                    );
          /*
          elsif upper(pv_tax_source_table) = '<some tax table>' then
            ...
            ...
          */

        -- Date 24-Apr-2007  Added by SACSETHI for bug 6012570 (5876390)
        -- in This , Recalculation will be happen in Draft invoice
        ---------------------------------------------------------
        elsif  upper(p_source_trx_type) = jai_constants.PA_DRAFT_INVOICE then

            lv_recalculation_sql :=
                replace ( lv_recalculation_sql
                    , 'a.tax_amount'
                    , 'a.tax_amt'
                    );

            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$TAX_SOURCE_TABLE$$'
                    , 'JAI_CMN_DOCUMENT_TAXES'
                    );
            /** replace join condition */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$SOURCE_TABLE_FILTER$$'
                    , 'a.SOURCE_DOC_LINE_ID = ' || p_line_id || ' and SOURCE_DOC_TYPE ='''|| jai_constants.PA_DRAFT_INVOICE || ''''
                    );

        -- Added by Jason Liu for standalone invoice on 2007/08/23
        ----------------------------------------------------------------------
        ELSIF  upper(p_source_trx_type) =
                 jai_constants.G_AP_STANDALONE_INVOICE
        THEN

          lv_recalculation_sql :=
            REPLACE( lv_recalculation_sql
                   , 'a.tax_amount'
                   , 'a.tax_amt'
                   );

          lv_recalculation_sql :=
            REPLACE( lv_recalculation_sql
                   , '$$TAX_SOURCE_TABLE$$'
                   , 'JAI_CMN_DOCUMENT_TAXES'
                   );
          -- replace join condition
          lv_recalculation_sql :=
            REPLACE( lv_recalculation_sql
                   , '$$SOURCE_TABLE_FILTER$$'
                   , 'a.SOURCE_DOC_LINE_ID = ' || p_line_id ||
                   ' and SOURCE_DOC_TYPE ='''||
                   jai_constants.G_AP_STANDALONE_INVOICE || ''''
                   );
        ----------------------------------------------------------------------
          end if; /*pv_tax_source_table*/

          /**
              When control comes here, a valid sql statement hold by variable lv_recalculate_sql
              must be ready to execute.

              open a dynamic select statement using OPEN-FOR statement
          */
          /* jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'TAX RECALCULATION SQL STATEMENT');
          jai_cmn_debug_contexts_pkg.print (ln_reg_id, lv_recalculation_sql);
          jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Opening ref cursor with dynamic sql'); */--commented by bgowrava for bug#5631784

          open refc_tax_cur for lv_recalculation_sql;

          /* jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Cursor is opened with lv_recalculation_sql');*/ --commented by bgowrava for bug#5631784

        end if; /** RECALCULATE */

        /** Clear the tax table */
    /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Before fetching cursor rows and starting loop');*/ --commented by bgowrava for bug#5631784
        lt_tax_table.delete;

        loop
      /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'In Loop, row_count='||row_count||', lt_tax_table.count='||lt_tax_table.count);*/ --commented by bgowrava for bug#5631784
          fetch refc_tax_cur into rec;
      /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Post Fetch refc_tax_cur, rec.tax_id='||rec.tax_id||', rec.tax_rate='||rec.tax_rate);*/ --commented by bgowrava for bug#5631784
          exit when refc_tax_cur%notfound;

      /** End of bug 5631784*/



    /** Add current record in the lt_tax_table for future use at the time of either UPDATE or INSERT into the tables*/

    --FOR rec IN tax_cur(p_tax_category_id) LOOP
    lt_tax_table(lt_tax_table.count+1) := rec;
        p1(row_count) := nvl(rec.p_1,-1);
        p2(row_count) := nvl(rec.p_2,-1);
        p3(row_count) := nvl(rec.p_3,-1);
        p4(row_count) := nvl(rec.p_4,-1);
        p5(row_count) := nvl(rec.p_5,-1);
        p6(row_count) := nvl(rec.p_6,-1); -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
        p7(row_count) := nvl(rec.p_7,-1);
        p8(row_count) := nvl(rec.p_8,-1);
        p9(row_count) := nvl(rec.p_9,-1);
        p10(row_count) := nvl(rec.p_10,-1);
        tax_rate_tab(row_count) := NVL(rec.tax_rate,0);
        line_no_tab(row_count)  := rec.lno; --added for bug#9214366

        --added by walton for inclusive tax on 08-Dev-07
        -----------------------------------------------------------------
        lt_tax_rate_per_rupee(row_count):=NVL(rec.tax_rate,0)/100;
        ln_total_tax_per_rupee:=0;
        lt_inclusive_tax_tab(row_count):=NVL(rec.inclusive_tax_flag,'N');
        lt_tax_amt_rate_tax_tab(row_count):=0;
        lt_tax_amt_non_rate_tab(row_count):=0;
        ------------------------------------------------------------------

        /*
        || The following code added by aiyer for the bug 4691616
        || Purpose:
        || rec.tax_rate = 0 means that tax_rate for such a tax line is actually zero (i.e it is not a replacement of null value)
        || So, when rec.tax_rate = 0, tax_rate_zero_tab is populated with -9999 to identify that this tax_line actually has tax_rate = 0
        || To calculate the BASE_TAX_AMOUNT of the taxes whose tax_rate is zero
        */

        IF rec.tax_rate is null THEN
          /*
          ||Indicates qty based taxes
          */
          tax_rate_zero_tab(row_count) := 0;

        ELSIF rec.tax_rate = 0 THEN
          /*
          ||Indicates 0% tax rate becasue a tax can have a rate as 0%.
          */
          tax_rate_zero_tab(row_count) := -9999;

        ELSE
          tax_rate_zero_tab(row_count) := rec.tax_rate;

        END IF;

        tax_type_tab(row_count) := rec.tax_type_val;
        /*End of bug 4691616 */
       -- tax_amt_tab(row_count) := 0;
       /*added for bug#6498072, start*/
       IF p_action = jai_constants.recalculate_taxes AND  --recalculate_taxes
             NVL(rec.adhoc_flag,'N') = 'Y'                   --adhoc_flag='Y'
          THEN
    tax_amt_tab(row_count) := nvl(rec.tax_amount,0) ;
          ELSE
           tax_amt_tab(row_count) := 0;
          END IF ;
  /*bug#6498072, end*/
        round_factor_tab(row_count):=rec.rounding_factor;  --added by csahoo for bug#6077133
        base_tax_amt_tab(row_count) := 0;
        adhoc_flag_tab(row_count):=rec.adhoc_flag ; /* rchandan bug#6030615 */

        IF tax_rate_tab(row_count) = 0
  AND rec.uom_code is not null  --added by csahoo for bug#6498072
  THEN
          -- Start of bug 3749294
          /*
          Code added by aiyer for the bug 3749294
          Check whether an exact match exists between the transaction uom and the setup uom (obtained through the tax_category list).
          IF an exact match is found then the conversion rate is equal to 1  else the conversion rate between the two uom's would be
          determined and tax amounts,base_tax_amounts are calculated for defaultation.
          */
          Inv_Convert.inv_um_conversion( p_uom_code, rec.uom_code, p_inventory_item_id, v_conversion_rate);
          IF NVL(v_conversion_rate, 0) <= 0 THEN
              -- pramasub start FP
            /*4281841 ..rchandan..start*/
              OPEN  uom_class_cur(p_uom_code, rec.uom_code);
              FETCH uom_class_cur INTO uom_cls;
              IF uom_class_cur%FOUND THEN
                Inv_Convert.inv_um_conversion( p_uom_code, rec.uom_code, 0, v_conversion_rate);
              ELSE
                v_conversion_rate := 0;
              END IF;
              CLOSE uom_class_cur;
              /*4281841 ..rchandan..end*/
             -- pramasub end FP
            --Inv_Convert.inv_um_conversion( p_uom_code, rec.uom_code, 0, v_conversion_rate); commented by pramasub
            IF NVL(v_conversion_rate, 0) <= 0 THEN

              /* for cash receipt there will be no lines. sacsethi for 6012570 (5876390) */
              if (p_uom_code is null and p_inventory_item_id is null )
                and p_source_trx_type = jai_constants.ar_cash
              then --
                v_conversion_rate := 1;

              /*
              Date 22-feb-2007  Added by SACSETHI for bug 6012570 (5876390)
              in This , Recalculation will be happen in Draft invoice
              */
              elsif (p_uom_code is null and p_inventory_item_id is null )
                and p_source_trx_type in (jai_constants.pa_draft_invoice
                ,jai_constants.G_AP_STANDALONE_INVOICE)
              then
                v_conversion_rate := 0;

              else
                v_conversion_rate := 0;
              end if;

            END IF;
          END IF;
          --tax_amt_tab(rec.lno) := nvl(rec.tax_amount * v_conversion_rate, 0) * p_line_quantity;   -- cbabu for EnhancementBug# 2427465, compact code
    /*added for bug#6498072, start*/
    IF p_action = jai_constants.recalculate_taxes THEN
              /*tax_amt_tab(rec.lno) := nvl(rec.tax_amount * v_conversion_rate, 0) ;*/  --commented out by walton for inclusive tax
              lt_tax_amt_non_rate_tab(rec.lno):=NVL(rec.tax_amount * v_conversion_rate, 0);  --added by walton for inclusive tax
            ELSE
              /*tax_amt_tab(rec.lno) := nvl(rec.tax_amount * v_conversion_rate, 0) * p_line_quantity ;*/  --commented out by walton for inclusive tax
        --added by walton for inclusive tax
              lt_tax_amt_non_rate_tab(rec.lno):=NVL(rec.tax_amount * v_conversion_rate, 0) * p_line_quantity;
            END IF ;
      /*added for bug#6498072, end*/
    /*commented out by walton for inclusive tax
    tax_amt_tab(rec.lno):=round(tax_amt_tab(rec.lno),round_factor_tab(rec.lno));  --added by csahoo for bug#6077133
          base_tax_amt_tab(rec.lno) := tax_amt_tab(rec.lno);
    */
          base_tax_amt_tab(rec.lno)       := lt_tax_amt_non_rate_tab(rec.lno); --added by walton for inclusive tax
          -- End of bug 3749294
          END IF;

        IF rec.valid_date IS NULL OR rec.valid_date >= SYSDATE THEN
            end_date_tab(row_count) := 1;
        ELSE
            tax_amt_tab(row_count)  := 0;
            end_date_tab(row_count) := 0;
        END IF;
        row_count := row_count + 1;

        --added for bug#9214366, start
        IF p_action = jai_constants.default_taxes
           and p_thhold_cat_base_tax_typ = jai_constants.tax_type_tcs
        THEN
          tax_amt_tab(rec.lno) := 0;
        END IF;
        --bug#9214366, end

    END LOOP;

    row_count := row_count - 1;

    --added by walton for inclusive tax 08-Dev-07
    -------------------------------------------------
    IF p_vat_assessable_value<>p_tax_amount
    THEN
      ln_vat_assessable_value:=p_vat_assessable_value;
    ELSE
      ln_vat_assessable_value:=1;
    END IF; --End p_vat_assessable_value<>p_tax_amount

    IF p_assessable_value<>p_tax_amount
    THEN
      ln_assessable_value:=p_assessable_value;
    ELSE
      ln_assessable_value:=1;
    END IF; --End p_assessable_value<>p_tax_amount
    ---------------------------------------------------

    FOR I IN 1..row_count LOOP
        IF end_date_tab(I) <> 0 THEN
            IF tax_type_tab(I) = 1 THEN
                --Added by walton for inclusive tax on 08-Dec-07
                ------------------------------------------------
                IF ln_assessable_value =1
                THEN
                  bsln_amt:=1;
                  ln_bsln_amt_nr :=0;
                ELSE
                  bsln_amt :=0;
                  ln_bsln_amt_nr :=ln_assessable_value;
                END IF;
                ------------------------------------------------
                /*bsln_amt := p_assessable_value;*/ --commented out by walton for inclusive tax
            ELSIF tax_type_tab(I) = 4 THEN
                --Added by walton for inclusive tax on 08-Dec-07
                ------------------------------------------------
                IF ln_vat_assessable_value =1
                THEN
                  bsln_amt:=1;
                  ln_bsln_amt_nr :=0;
                ELSE
                  bsln_amt :=0;
                  ln_bsln_amt_nr :=ln_vat_assessable_value;
                END IF;
                ------------------------------------------------
                /*bsln_amt := p_vat_assessable_value;*/ --commented out by walton for inclusive tax

            --Added by walton for inclusive tax
            -------------------------------------
            ELSIF tax_type_tab(I) = 6 THEN
                bsln_amt:=0;
                ln_bsln_amt_nr :=0;
            -------------------------------------
            ELSE
                bsln_amt:=1;                --Added by walton for inclusive tax
                ln_bsln_amt_nr :=0;         --Added by walton for inclusive tax
                /*bsln_amt := p_tax_amount;*/ --commented out by walton for inclusive tax
            END IF;

            IF tax_rate_tab(I) <> 0 THEN
                IF P1(I) < line_no_tab(I) AND P1(I) NOT IN (-1,0) THEN --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(P1(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0); --added by walton for inclusive tax
                ELSIF P1(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
                END IF;
                IF p2(I) < line_no_tab(I) AND p2(I) NOT IN (-1,0) THEN --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p2(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0); --added by walton for inclusive tax
                ELSIF p2(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
                END IF;
                IF p3(I) < line_no_tab(I) AND p3(I) NOT IN (-1,0) THEN --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p3(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0); --added by walton for inclusive tax
                ELSIF p3(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
                END IF;
                IF p4(I) < line_no_tab(I) AND p4(I) NOT IN (-1,0) THEN --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p4(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0); --added by walton for inclusive tax
                ELSIF p4(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
                END IF;
                IF p5(I) < line_no_tab(I) AND p5(I) NOT IN (-1,0) THEN --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p5(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0); --added by walton for inclusive tax
                ELSIF p5(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
                END IF;
                -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                -- start bug 5228046
                IF P6(I) < line_no_tab(I) AND P6(I) NOT IN (-1,0) THEN --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(P6(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0); --added by walton for inclusive tax
                ELSIF P6(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
                END IF;
                IF p7(I) < line_no_tab(I) AND p7(I) NOT IN (-1,0) THEN --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p7(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0); --added by walton for inclusive tax
                ELSIF p7(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
                END IF;
                IF p8(I) < line_no_tab(I) AND p8(I) NOT IN (-1,0) THEN --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p8(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0); --added by walton for inclusive tax
                ELSIF p8(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
                END IF;
                IF p9(I) < line_no_tab(I) AND p9(I) NOT IN (-1,0) THEN --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p9(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0); --added by walton for inclusive tax
                ELSIF p9(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
                END IF;
                IF p10(I) < line_no_tab(I) AND p10(I) NOT IN (-1,0) THEN --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p10(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0); --added by walton for inclusive tax
                ELSIF p10(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
                END IF;
                -- end bug 5228046
                v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
                ln_tax_amt_nr:=ln_tax_amt_nr+(ln_vamt_nr*(tax_rate_tab(I)/100)); --added by walton for inclusive tax
                base_tax_amt_tab(I) := vamt;
                tax_amt_tab(I) := NVL(tax_amt_tab(I),0) + v_tax_amt;
                lt_tax_amt_non_rate_tab(I):=NVL(lt_tax_amt_non_rate_tab(I),0)+ln_tax_amt_nr;  --added by walton for inclusive tax
                lt_tax_amt_rate_tax_tab(I):= tax_amt_tab(I);   --added by walton for inclusive tax
                /*tax_amt_tab(I) :=  round(tax_amt_tab(I)  ,round_factor_tab(I)); --added by csahoo for bug#6077133*/ --commented by walton for inclusive tax
                base_tax_amount_nr_tab(I):=ln_vamt_nr; --added by Xiao Lv for bug#8789761 on 30-Oct-09
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
                IF P1(I) > line_no_tab(I) THEN  --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(P1(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0); --added by walton for inclusive tax
                END IF;
                IF p2(I) > line_no_tab(I)  THEN  --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p2(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0); --added by walton for inclusive tax
                END IF;
                IF p3(I) > line_no_tab(I)  THEN  --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p3(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0); --added by walton for inclusive tax
                END IF;
                IF p4(I) > line_no_tab(I) THEN  --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p4(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0); --added by walton for inclusive tax
                END IF;
                IF p5(I) > line_no_tab(I) THEN  --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p5(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0); --added by walton for inclusive tax
                END IF;
                -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                -- start bug 5228046
                IF P6(I) > line_no_tab(I) THEN  --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(P6(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0); --added by walton for inclusive tax
                END IF;
                IF p7(I) > line_no_tab(I)  THEN  --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p7(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0); --added by walton for inclusive tax
                END IF;
                IF p8(I) > line_no_tab(I)  THEN  --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p8(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0); --added by walton for inclusive tax
                END IF;
                IF p9(I) > line_no_tab(I) THEN  --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p9(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0); --added by walton for inclusive tax
                END IF;
                IF p10(I) > line_no_tab(I) THEN  --replaced I by line_no_tab(I) for bug#9214366
                    vamt := vamt + NVL(tax_amt_tab(p10(I)),0);
                    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0); --added by walton for inclusive tax
                END IF;
                -- end bug 5228046
                base_tax_amt_tab(I) := vamt;
                v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
                ln_tax_amt_nr:=ln_tax_amt_nr+(ln_vamt_nr * (tax_rate_tab(I)/100)); --added by walton for inclusive tax
                IF vamt <> 0 THEN
                    base_tax_amt_tab(I) := base_tax_amt_tab(I) + vamt;
                END IF;
                tax_amt_tab(I) := NVL(tax_amt_tab(I),0) + v_tax_amt;
                lt_tax_amt_non_rate_tab(I):=NVL(lt_tax_amt_non_rate_tab(I),0)+ln_tax_amt_nr;  --added by walton for inclusive tax
                lt_tax_amt_rate_tax_tab(I):= tax_amt_tab(I);   --added by walton for inclusive tax
                base_tax_amount_nr_tab(I):=ln_vamt_nr; --added by Xiao Lv for bug#8789761 on 30-Oct-09
                vamt := 0;
                v_tax_amt := 0;
                ln_vamt_nr :=0;    --added by walton for inclusive tax
                ln_tax_amt_nr :=0; --added by walton for inclusive tax
            END IF;

        ELSE

            base_tax_amt_tab(I) := vamt;
            tax_amt_tab(I) := 0;
        END IF;

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
                --Added by walton for inclusive tax on 08-Dec-07
                ------------------------------------------------
                IF ln_assessable_value =1
                THEN
                  v_amt:=1;
                  ln_bsln_amt_nr :=0;
                ELSE
                  v_amt :=0;
                  ln_bsln_amt_nr :=ln_assessable_value;
                END IF;
                ------------------------------------------------
                /*v_amt := p_assessable_value;*/ --commented out by walton for inclusive tax
            ELSIF tax_type_tab(I) = 4 THEN
                --Added by walton for inclusive tax on 08-Dec-07
                ------------------------------------------------
                IF ln_vat_assessable_value =1
                THEN
                  v_amt:=1;
                  ln_bsln_amt_nr :=0;
                ELSE
                  v_amt :=0;
                  ln_bsln_amt_nr :=ln_vat_assessable_value;
                END IF;
                ------------------------------------------------
                /*v_amt := p_vat_assessable_value;*/ --commented out by walton for inclusive tax

            --Added by walton for inclusive tax
            -------------------------------------
            ELSIF tax_type_tab(I) = 6 THEN
                v_amt:=0;
                ln_bsln_amt_nr :=0;
            -------------------------------------
            ELSE
              IF p_assessable_value IN ( 0, -1 ) OR tax_type_tab( I ) <> 1 THEN
                 /* v_amt := p_tax_amount;*/
                 v_amt:=1;                --Added by walton for inclusive tax
                 ln_bsln_amt_nr :=0;      --Added by walton for inclusive tax
              ELSIF p_vat_assessable_value IN ( 0, -1 ) OR tax_type_tab( I ) <> 4 THEN
                 /* v_amt := p_tax_amount;*/
                 v_amt:=1;                --Added by walton for inclusive tax
                 ln_bsln_amt_nr :=0;      --Added by walton for inclusive tax
              END IF;
            END IF;

            IF P1( i ) <> -1 THEN
              IF P1( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( P1( I ) );
    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0); --added by walton for inclusive tax
              ELSIF P1(i) = 0 THEN
                  vamt := vamt + v_amt;
    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
              END IF;
            END IF;

            IF p2( i ) <> -1 THEN
              IF p2( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( p2( I ) );
    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0); --added by walton for inclusive tax
              ELSIF p2(i) = 0 THEN
                  vamt := vamt + v_amt;
    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
              END IF;
            END IF;
            IF p3( i ) <> -1 THEN
              IF p3( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( p3( I ) );
    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0); --added by walton for inclusive tax
              ELSIF p3(i) = 0 THEN
                  vamt := vamt + v_amt;
    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
              END IF;
            END IF;

            IF p4( i ) <> -1 THEN
              IF p4( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p4( i ) );
    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0); --added by walton for inclusive tax
              ELSIF p4(i) = 0 THEN
                vamt := vamt + v_amt;
    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
              END IF;
            END IF;

            IF p5( i ) <> -1 THEN
              IF p5( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p5( i ) );
    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0); --added by walton for inclusive tax
              ELSIF p5(i) = 0 THEN
                vamt := vamt + v_amt;
    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
              END IF;
            END IF;

-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    -- start bug 5228046
      IF P6( i ) <> -1 THEN
              IF P6( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( P6( I ) );
    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0); --added by walton for inclusive tax
              ELSIF P6(i) = 0 THEN
                  vamt := vamt + v_amt;
    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
              END IF;
            END IF;

            IF p7( i ) <> -1 THEN
              IF p7( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( p7( I ) );
    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0); --added by walton for inclusive tax
              ELSIF p7(i) = 0 THEN
                  vamt := vamt + v_amt;
    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
              END IF;
            END IF;
            IF p8( i ) <> -1 THEN
              IF p8( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( p8( I ) );
    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0); --added by walton for inclusive tax
              ELSIF p8(i) = 0 THEN
                  vamt := vamt + v_amt;
    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
              END IF;
            END IF;

            IF p9( i ) <> -1 THEN
              IF p9( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p9( i ) );
    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0); --added by walton for inclusive tax
              ELSIF p9(i) = 0 THEN
                vamt := vamt + v_amt;
    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
              END IF;
            END IF;

            IF p10( i ) <> -1 THEN
              IF p10( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p10( i ) );
    ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0); --added by walton for inclusive tax
              ELSIF p10(i) = 0 THEN
                vamt := vamt + v_amt;
    ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by walton for inclusive tax
              END IF;
            END IF;

   -- end bug 5228046


            base_tax_amt_tab(I) := vamt;
            tax_target_tab(I) := vamt;

            --------------------------------------------------------------------------------------
            /*Change History: jai_cmn_tax_defaultation_pkg
            Last Modified By Jagdish Bhosle.  2001/04/05
            The follow check will ensure that for Bond reg. Txns
            excise duty will not be added to original Line amount. */
            --------------------------------------------------------------------------------------
            IF (v_register_code='BOND_REG') THEN            --- Added By Jagdish    2001/04/05
              IF  counter = max_iter AND tax_type_tab( I ) NOT IN ( 1, 2 ) THEN
                v_func_tax_amt := v_tax_amt +  ( vamt * ( tax_rate_tab( i )/100));
                v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
    ln_tax_amt_nr:=ln_tax_amt_nr+(ln_vamt_nr*(tax_rate_tab(i)/100)); --added by walton for inclusive
              END IF;

            ELSE
              v_func_tax_amt := v_tax_amt +  ( vamt * ( tax_rate_tab( i )/100));
              v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
        ln_tax_amt_nr:=ln_tax_amt_nr+(ln_vamt_nr*(tax_rate_tab(i)/100)); --added by walton for inclusive
            END IF;  -- End of Addition Jagdish 2001/04/05

            ELSIF tax_rate_tab(I) = 0 THEN
              base_tax_amt_tab(I) := tax_amt_tab(i);
              v_tax_amt := tax_amt_tab( i );
        ln_tax_amt_nr:=lt_tax_amt_non_rate_tab(i);
              tax_target_tab(I) := v_tax_amt;
            ELSIF end_date_tab( I ) = 0 THEN
              tax_amt_tab(I) := 0;
              base_tax_amt_tab(I) := 0;
              tax_target_tab(I) := 0;
            END IF;

            tax_amt_tab( I ) := NVL( v_tax_amt, 0 );
      lt_tax_amt_rate_tax_tab(I) := tax_amt_tab(I); --added by walton for inclusive tax
      lt_tax_amt_non_rate_tab(I):=ln_tax_amt_nr;  --added by walton for inclusive tax
      /*tax_amt_tab(I) :=  round(tax_amt_tab(I)  ,round_factor_tab(I));  --added by csahoo for bug#6077133*/--commented by walton for inclusive tax
            --func_tax_amt_tab(I) := NVL(v_func_tax_amt,0);  --Commented by walton for bug#9288016
            base_tax_amount_nr_tab(I):=ln_vamt_nr; --added by Xiao Lv for bug#8789761 on 30-Oct-09

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

    --Added by walton for inclusive tax
    ---------------------------------------------------------------------------------------
    FOR I IN 1 .. ROW_COUNT --Compute Factor
    LOOP
      IF lt_inclusive_tax_tab(I) = 'Y'
      THEN
        ln_total_tax_per_rupee := ln_total_tax_per_rupee + nvl(lt_tax_amt_rate_tax_tab(I),0) ;
  ln_total_non_rate_tax := ln_total_non_rate_tax + nvl(lt_tax_amt_non_rate_tab(I),0);
      END IF;
    END LOOP; --End Compute Factor

    ln_total_tax_per_rupee := ln_total_tax_per_rupee + 1;

    IF ln_total_tax_per_rupee <> 0
    THEN
      ln_exclusive_price := (NVL(p_tax_amount,0)  -  ln_total_non_rate_tax ) / ln_total_tax_per_rupee;
    END If;

    FOR i in 1 .. row_count  --Compute Tax Amount
    Loop
       tax_amt_tab (i) := (lt_tax_amt_rate_tax_tab(I) * ln_exclusive_price ) + lt_tax_amt_non_rate_tab(I);
       func_tax_amt_tab(i):=tax_amt_tab (i); --Added by walton for bug#9288016
       tax_amt_tab(I) :=  round(tax_amt_tab(I)  ,round_factor_tab(I));
       base_tax_amt_tab(I):= ln_exclusive_price * base_tax_amt_tab(I)
                           + base_tax_amount_nr_tab(I);  --added by Xiao Lv for bug#8789761 on 30-Oct-09
    END LOOP; --End Compute Tax Amount
    --------------------------------------------------------------------------------------------------------

--Added by Kevin Cheng for Retroactive Price 2008/01/13
--===========================================================================================================
ELSIF pv_retroprice_changed = 'Y'
THEN

   --Ramananda for File.Sql.35
   bsln_amt := p_tax_amount ;
   v_conversion_rate := 0;
   v_currency_conv_factor  := p_currency_conv_factor;
   ln_base :=  0 ;

    IF transaction_name <> 'CRM_QUOTE' THEN     -- Vijay Shankar for Bug# 2837970
        IF v_debug THEN fnd_file.put_line(fnd_file.log, ' transaction_name -> '||transaction_name); END IF;

        --2001/03/30 Manohar Mishra
        /*Start of Addition*/
        OPEN get_header_info_cur;
        FETCH get_header_info_cur INTO v_organization_id, v_location_id, v_batch_source_id;
        CLOSE get_header_info_cur;

        OPEN get_register_code_cur(v_organization_id, v_location_id, v_batch_source_id);
        FETCH get_register_code_cur INTO v_register_code;
        CLOSE get_register_code_cur;

    -- Vijay Shankar for Bug# 2837970
    ELSE    -- this should get executed when tax defaultation is for CRM_QUOTE
        v_register_code := null;
    END IF;
    --2001/03/30 Manohar Mishra

    /*End of Addition*/


        /** bgowrava for forward porting bug#5631784*/
        if    p_tax_category_id is null
        and   (p_threshold_tax_cat_id is null or p_threshold_tax_cat_id <0) then
        /** Both driving parameter tax_category_id and threshol_tax_category_id are invalid hence no need to do anything */
          return;
        end if;

        if    nvl(p_action, jai_constants.default_taxes) = jai_constants.default_taxes then
          /** Assign tax defaultation cursor object to refc_tax_cur reference by using. Call to get_tax_cat_taxes_cur will return
          a reference cursor */

          if p_threshold_tax_cat_id is not null and p_threshold_tax_cat_id > 0 then
            /*
            ||  Cursor to check if same taxes exists in both tax categories
            */
            ln_dup_tax_exists := null;
     /*       jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Close/Fetch cursor c_chk_tax_duplication');*/ --commented by bgowrava for bug#5631784
            open   c_chk_tax_duplication;
            fetch  c_chk_tax_duplication into ln_dup_tax_exists;
            close  c_chk_tax_duplication;

     /*       jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'ln_dup_tax_exists='||ln_dup_tax_exists);*/ --commented by bgowrava for bug#5631784

            if ln_dup_tax_exists is not null
            or (nvl(p_threshold_tax_cat_id,-1) = p_tax_category_id)
            then

              fnd_message.set_name('JA', 'JAI_DUP_TAX_IN_TAX_CAT');
              app_exception.raise_exception ;

            end if;

     /*       jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Close/Fetch cursor c_get_max_tax_line');*/ --commented by bgowrava for bug#5631784
            open   c_get_max_tax_line;
            fetch  c_get_max_tax_line into ln_max_tax_line;
            close  c_get_max_tax_line ;

     /*       jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Close/Fetch cursor c_get_max_rgm_tax_line');*/ --commented by bgowrava for bug#5631784
            open   c_get_max_rgm_tax_line;
            fetch  c_get_max_rgm_tax_line into ln_max_rgm_tax_line;
            close  c_get_max_rgm_tax_line ;

      /*      jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'ln_max_tax_line='||ln_max_tax_line||', ln_max_rgm_tax_line='||ln_max_rgm_tax_line);*/ --commented by bgowrava for bug#5631784

          end if;

      /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Opening ref cursor');*/ --commented by bgowrava for bug#5631784
          get_tax_cat_taxes_cur ( p_tax_category_id        =>  p_tax_category_id
                                , p_threshold_tax_cat_id   =>  p_threshold_tax_cat_id
                                , p_max_tax_line           =>  ln_max_tax_line
                                , p_max_rgm_tax_line       =>  ln_max_rgm_tax_line
                                , p_refc_tax_cat_taxes_cur => refc_tax_cur
                                , pv_retroprice_changed    => pv_retroprice_changed --Added by Kevin Cheng for Retroactive Price 2008/01/14
                                );

       /*   jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Cursor is opened');*/ --commented by bgowrava for bug#5631784

        elsif p_action = jai_constants.recalculate_taxes then
        /**
            Following is a dynamic sql string which can be modifed as per requirement

            The sql has four place holders defined as below
            $$EXTRA_SELECT_COLUMN_LIST$$    -  Use this place holder to select additional columns in the sql.
                                               You must also change corrosponding fetch statements and the record being used for fetch.
                                               SELECT statement above should also be changed to include the newly added columns
                                               as they are sharing a common cursor and fetch record.

            $$TAX_SOURCE_TABLE$$            -  At runtime this placeholder must be replaced with name of
                                               source table to be used for recalculation
            $$SOURCE_TABLE_FILTER$$         -  At runtime, this place holder must represent a boolean condition
                                               which can filter required rows from the source table
                                               for recalculation.  It must be the first condition and should never
                                               start with either AND or OR
            $$ADDITIONAL_WHERE_CLAUSE$$     -  Replace the placeholder with additional conditions if any.
                                               The condition must start with either AND or OR keyword
            $$ADDITIONAL_ORDER_BY$$         -  Replace the placeholder with list of columns and order sequence, if required.
                                               Column list must start with comma (,)
            If any of this placeholder is not required to be used it must be replaced with a null value as below
                replace ( lv_recalculation_sql
                        , '$$EXTRA_SELECT_COLUMN_LIST$$'
                        , ''
                        );
        */
        lv_recalculation_sql :=
           '  select  a.tax_id
                    , a.tax_line_no     lno
                    , a.precedence_1    p_1
                    , a.precedence_2    p_2
                    , a.precedence_3    p_3
                    , a.precedence_4    p_4
                    , a.precedence_5    p_5
                    , a.precedence_6    p_6
                    , a.precedence_7    p_7
                    , a.precedence_8    p_8
                    , a.precedence_9    p_9
                    , a.precedence_10   p_10
                    , a.tax_rate
                    , a.tax_amount
                    , b.uom_code
                    , b.end_date        valid_date
                    , DECODE(rttv.regime_code, '''||jai_constants.vat_regime||''', 4,  /* added by ssumaith - bug# 4245053*/
                                              DECODE(UPPER(b.tax_type), ''EXCISE''      , 1
                                                                      , ''ADDL. EXCISE'', 1
                                                                      , ''OTHER EXCISE'', 1
                                                                      , ''TDS''         , 2
                                                                      , ''EXCISE_EDUCATION_CESS'',1
                                                                      , '''||JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS||''' , 1 /*bduvarag for the bug#5989740*/
                                                                      , ''CVD_EDUCATION_CESS''   ,1
                                                                      , '''||JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS||''' , 1  /*bduvarag for the bug#5989740*/
                                                                      , 0
                                                    )
                            )           tax_type_val
                   , b.mod_cr_percentage
                   , b.vendor_id
                   , b.tax_type
                   , nvl(b.rounding_factor,0) rounding_factor
                  , b.adhoc_flag
                   $$EXTRA_SELECT_COLUMN_LIST$$
              from  $$TAX_SOURCE_TABLE$$        a
                    , JAI_CMN_TAXES_ALL           b
                    , jai_regime_tax_types_v   rttv
              where $$SOURCE_TABLE_FILTER$$
              and   rttv.tax_type (+) = b.tax_type
              and   a.tax_id = b.tax_id   $$ADDITIONAL_WHERE_CLAUSE$$
              order by  a.tax_line_no   $$ADDITIONAL_ORDER_BY$$';


           /** No extra columns required. Dummy column (NULL) tax_category_id needs to be added in the last as same record (rec) is being used
               when fetching the cursor.  If there is a need to override this default behaviour then please replace these place holder with
               desired strings which can be evaluated at runtime by sql-engine
            */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$EXTRA_SELECT_COLUMN_LIST$$'
                    , ',null   tax_category_id'
                    );

            /** No additional filtering required */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$ADDITIONAL_WHERE_CLAUSE$$'
                    , ''
                    );

            /** No additional sorting required */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$ADDITIONAL_ORDER_BY$$'
                    , ''
                    );

        if  upper(p_source_trx_type) = jai_constants.source_ttype_delivery then

            /** replace the correct tax source table */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$TAX_SOURCE_TABLE$$'
                    , 'JAI_OM_WSH_LINE_TAXES'
                    );
            /** replace join condition */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$SOURCE_TABLE_FILTER$$'
                    , 'a.delivery_detail_id = ' || p_line_id
                    );
        elsif  upper(p_source_trx_type) = jai_constants.bill_only_invoice then

            /** For bill_only_invoice tax source table is ja_in_ra_cust_trx_tax_lines*/
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$TAX_SOURCE_TABLE$$'
                    , 'JAI_AR_TRX_TAX_LINES'
                    );
            /** replace join condition */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$SOURCE_TABLE_FILTER$$'
                    , 'a.link_to_cust_trx_line_id = ' || p_line_id
                    );
          /*
          elsif upper(pv_tax_source_table) = '<some tax table>' then
            ...
            ...
          */

        -- Date 24-Apr-2007  Added by SACSETHI for bug 6012570 (5876390)
        -- in This , Recalculation will be happen in Draft invoice
        ---------------------------------------------------------
        elsif  upper(p_source_trx_type) = jai_constants.PA_DRAFT_INVOICE then

            lv_recalculation_sql :=
                replace ( lv_recalculation_sql
                    , 'a.tax_amount'
                    , 'a.tax_amt'
                    );

            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$TAX_SOURCE_TABLE$$'
                    , 'JAI_CMN_DOCUMENT_TAXES'
                    );
            /** replace join condition */
            lv_recalculation_sql :=
            replace ( lv_recalculation_sql
                    , '$$SOURCE_TABLE_FILTER$$'
                    , 'a.SOURCE_DOC_LINE_ID = ' || p_line_id || ' and SOURCE_DOC_TYPE ='''|| jai_constants.PA_DRAFT_INVOICE || ''''
                    );

        -- Added by Jason Liu for standalone invoice on 2007/08/23
        ----------------------------------------------------------------------
        ELSIF  upper(p_source_trx_type) =
                 jai_constants.G_AP_STANDALONE_INVOICE
        THEN

          lv_recalculation_sql :=
            REPLACE( lv_recalculation_sql
                   , 'a.tax_amount'
                   , 'a.tax_amt'
                   );

          lv_recalculation_sql :=
            REPLACE( lv_recalculation_sql
                   , '$$TAX_SOURCE_TABLE$$'
                   , 'JAI_CMN_DOCUMENT_TAXES'
                   );
          -- replace join condition
          lv_recalculation_sql :=
            REPLACE( lv_recalculation_sql
                   , '$$SOURCE_TABLE_FILTER$$'
                   , 'a.SOURCE_DOC_LINE_ID = ' || p_line_id ||
                   ' and SOURCE_DOC_TYPE ='''||
                   jai_constants.G_AP_STANDALONE_INVOICE || ''''
                   );
        ----------------------------------------------------------------------
          end if; /*pv_tax_source_table*/

          /**
              When control comes here, a valid sql statement hold by variable lv_recalculate_sql
              must be ready to execute.

              open a dynamic select statement using OPEN-FOR statement
          */
          /* jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'TAX RECALCULATION SQL STATEMENT');
          jai_cmn_debug_contexts_pkg.print (ln_reg_id, lv_recalculation_sql);
          jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Opening ref cursor with dynamic sql'); */--commented by bgowrava for bug#5631784

          open refc_tax_cur for lv_recalculation_sql;

          /* jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Cursor is opened with lv_recalculation_sql');*/ --commented by bgowrava for bug#5631784

        end if; /** RECALCULATE */

        /** Clear the tax table */
    /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Before fetching cursor rows and starting loop');*/ --commented by bgowrava for bug#5631784
        lt_tax_table.delete;

        loop
      /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'In Loop, row_count='||row_count||', lt_tax_table.count='||lt_tax_table.count);*/ --commented by bgowrava for bug#5631784
          fetch refc_tax_cur into rec;
      /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Post Fetch refc_tax_cur, rec.tax_id='||rec.tax_id||', rec.tax_rate='||rec.tax_rate);*/ --commented by bgowrava for bug#5631784
          exit when refc_tax_cur%notfound;

      /** End of bug 5631784*/



    /** Add current record in the lt_tax_table for future use at the time of either UPDATE or INSERT into the tables*/

    --FOR rec IN tax_cur(p_tax_category_id) LOOP
    lt_tax_table(lt_tax_table.count+1) := rec;
        p1(row_count) := nvl(rec.p_1,-1);
        p2(row_count) := nvl(rec.p_2,-1);
        p3(row_count) := nvl(rec.p_3,-1);
        p4(row_count) := nvl(rec.p_4,-1);
        p5(row_count) := nvl(rec.p_5,-1);
        p6(row_count) := nvl(rec.p_6,-1); -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
        p7(row_count) := nvl(rec.p_7,-1);
        p8(row_count) := nvl(rec.p_8,-1);
        p9(row_count) := nvl(rec.p_9,-1);
        p10(row_count) := nvl(rec.p_10,-1);
        tax_rate_tab(row_count) := NVL(rec.tax_rate,0);


        /*
        || The following code added by aiyer for the bug 4691616
        || Purpose:
        || rec.tax_rate = 0 means that tax_rate for such a tax line is actually zero (i.e it is not a replacement of null value)
        || So, when rec.tax_rate = 0, tax_rate_zero_tab is populated with -9999 to identify that this tax_line actually has tax_rate = 0
        || To calculate the BASE_TAX_AMOUNT of the taxes whose tax_rate is zero
        */

        IF rec.tax_rate is null THEN
          /*
          ||Indicates qty based taxes
          */
          tax_rate_zero_tab(row_count) := 0;

        ELSIF rec.tax_rate = 0 THEN
          /*
          ||Indicates 0% tax rate becasue a tax can have a rate as 0%.
          */
          tax_rate_zero_tab(row_count) := -9999;

        ELSE
          tax_rate_zero_tab(row_count) := rec.tax_rate;

        END IF;

        tax_type_tab(row_count) := rec.tax_type_val;
        /*End of bug 4691616 */
       -- tax_amt_tab(row_count) := 0;
       /*added for bug#6498072, start*/
       --Comment out by Kevin Cheng
       /*IF p_action = jai_constants.recalculate_taxes AND  --recalculate_taxes
             NVL(rec.adhoc_flag,'N') = 'Y'                   --adhoc_flag='Y'
          THEN
    tax_amt_tab(row_count) := nvl(rec.tax_amount,0) ;
          ELSE
           tax_amt_tab(row_count) := 0;
          END IF ;*/
  /*bug#6498072, end*/

  --Added by Kevin Cheng -- for remain unchanged taxes
  --1, Ad hoc taxes
  --2, UOM based taxes
  --3, Assessable value base taxes (Excise/VAT)
  --4, Third party taxes
  --=================================================================================
  IF NVL(rec.adhoc_flag,'N') = 'Y' --Ad hoc
  THEN
    lv_tax_remain_flag := 'Y';
  ELSIF tax_rate_tab(row_count) = 0 AND rec.uom_code IS NOT NULL --UOM based
  THEN
    lv_tax_remain_flag := 'Y';
  ELSIF rec.tax_type_val = 1 AND p_assessable_value <> p_tax_amount --Excise assessable value based
  THEN
     lv_tax_remain_flag := 'Y';
  ELSIF rec.tax_type_val = 4 AND p_vat_assessable_value <> p_tax_amount --VAT assessable value based
  THEN
    lv_tax_remain_flag := 'Y';
  ELSIF rec.vendor_id <> p_vendor_id --Third party
  THEN
    lv_tax_remain_flag := 'Y';
  ELSE
    lv_tax_remain_flag := 'N';
  END IF;

  IF lv_tax_remain_flag = 'Y'
  THEN
    --Get line location id from transaction_name
    IF SUBSTR( transaction_name, 1, 1 ) = 'R' THEN
      lv_transaction_name := 'RFQ';
      lv_start := 4;
    ELSIF SUBSTR( transaction_name, 1, 1 ) = 'S' THEN
      lv_transaction_name := 'RFQ';
      lv_start := 10;
    ELSIF SUBSTR( transaction_name, 1, 1 ) = 'Q' THEN
      lv_transaction_name := 'QUOTATION';
      lv_start := 10;
    ELSIF SUBSTR( transaction_name, 1, 1 ) = 'B' AND SUBSTR( transaction_name, 1, 8 ) <> 'BLANKETR' THEN
      lv_transaction_name := 'BLANKET';
      lv_start := 8;
    ELSIF SUBSTR( transaction_name, 1, 8 ) = 'BLANKETR' THEN
      lv_transaction_name := 'RFQ';
      lv_start := 9;
    ELSIF SUBSTR( transaction_name, 1, 1 ) = 'O' THEN
      lv_transaction_name := 'OTHERS';
      lv_start := 7;
    END IF;

    lv_line_loc_id := TO_NUMBER( SUBSTR( transaction_name, lv_start, LENGTH( transaction_name )-( lv_start + 1 )));
    SELECT
      original_tax_amount
    INTO
      tax_amt_tab(row_count)
    FROM
      Jai_Retro_Tax_Changes jrtc
    WHERE jrtc.tax_id = rec.tax_id
      AND jrtc.line_change_id = (SELECT
                                   line_change_id
                                 FROM
                                   Jai_Retro_Line_Changes jrlc
                                 WHERE jrlc.line_location_id = lv_line_loc_id
                                   AND jrlc.doc_type IN ( 'RELEASE'
                                                        , 'RECEIPT'
                                                        , 'STANDARD PO'
                                                        )
                                   AND jrlc.doc_version_number = (SELECT
                                                                    MAX(jrlc1.doc_version_number)
                                                                  FROM
                                                                    Jai_Retro_Line_Changes jrlc1
                                                                  WHERE jrlc1.line_location_id = lv_line_loc_id
                                                                    AND jrlc1.doc_type IN ( 'RELEASE'
                                                                                          , 'RECEIPT'
                                                                                          , 'STANDARD PO'
                                                                                          )
                                                                 )
                                );

    tax_rate_tab(row_count)      := 0;
    tax_rate_zero_tab(row_count) := 0;
    adhoc_flag_tab(row_count)    := 'Y';

  ELSIF lv_tax_remain_flag = 'N'
  THEN
    tax_amt_tab(row_count)   := 0;
    adhoc_flag_tab(row_count):= rec.adhoc_flag ; /* rchandan bug#6030615 */
  END IF;
  --=================================================================================

        round_factor_tab(row_count):=rec.rounding_factor;  --added by csahoo for bug#6077133
        base_tax_amt_tab(row_count) := 0;
        --Comment out by Kevin Cheng
        --adhoc_flag_tab(row_count):=rec.adhoc_flag ; /* rchandan bug#6030615 */

--Comment out by Kevin Cheng
        /*IF tax_rate_tab(row_count) = 0
  AND rec.uom_code is not null  --added by csahoo for bug#6498072
  THEN
          -- Start of bug 3749294
          \*
          Code added by aiyer for the bug 3749294
          Check whether an exact match exists between the transaction uom and the setup uom (obtained through the tax_category list).
          IF an exact match is found then the conversion rate is equal to 1  else the conversion rate between the two uom's would be
          determined and tax amounts,base_tax_amounts are calculated for defaultation.
          *\
          Inv_Convert.inv_um_conversion( p_uom_code, rec.uom_code, p_inventory_item_id, v_conversion_rate);
          IF NVL(v_conversion_rate, 0) <= 0 THEN
              -- pramasub start FP
            \*4281841 ..rchandan..start*\
              OPEN  uom_class_cur(p_uom_code, rec.uom_code);
              FETCH uom_class_cur INTO uom_cls;
              IF uom_class_cur%FOUND THEN
                Inv_Convert.inv_um_conversion( p_uom_code, rec.uom_code, 0, v_conversion_rate);
              ELSE
                v_conversion_rate := 0;
              END IF;
              CLOSE uom_class_cur;
              \*4281841 ..rchandan..end*\
             -- pramasub end FP
            --Inv_Convert.inv_um_conversion( p_uom_code, rec.uom_code, 0, v_conversion_rate); commented by pramasub
            IF NVL(v_conversion_rate, 0) <= 0 THEN

              \* for cash receipt there will be no lines. sacsethi for 6012570 (5876390) *\
              if (p_uom_code is null and p_inventory_item_id is null )
                and p_source_trx_type = jai_constants.ar_cash
              then --
                v_conversion_rate := 1;

              \*
              Date 22-feb-2007  Added by SACSETHI for bug 6012570 (5876390)
              in This , Recalculation will be happen in Draft invoice
              *\
              elsif (p_uom_code is null and p_inventory_item_id is null )
                and p_source_trx_type= jai_constants.pa_draft_invoice
              then
                v_conversion_rate := 0;

              else
                v_conversion_rate := 0;
              end if;

            END IF;
          END IF;
          --tax_amt_tab(rec.lno) := nvl(rec.tax_amount * v_conversion_rate, 0) * p_line_quantity;   -- cbabu for EnhancementBug# 2427465, compact code
    \*added for bug#6498072, start*\
    IF p_action = jai_constants.recalculate_taxes THEN
              tax_amt_tab(rec.lno) := nvl(rec.tax_amount * v_conversion_rate, 0) ;
            ELSE
              tax_amt_tab(rec.lno) := nvl(rec.tax_amount * v_conversion_rate, 0) * p_line_quantity ;
            END IF ;
      \*added for bug#6498072, end*\
    tax_amt_tab(rec.lno):=round(tax_amt_tab(rec.lno),round_factor_tab(rec.lno));  --added by csahoo for bug#6077133
          base_tax_amt_tab(rec.lno) := tax_amt_tab(rec.lno);
          -- End of bug 3749294
          END IF;*/

        IF rec.valid_date IS NULL OR rec.valid_date >= SYSDATE THEN
            end_date_tab(row_count) := 1;
        ELSE
            tax_amt_tab(row_count)  := 0;
            end_date_tab(row_count) := 0;
        END IF;
        row_count := row_count + 1;
    END LOOP;

    row_count := row_count - 1;

    FOR I IN 1..row_count LOOP
        IF end_date_tab(I) <> 0 THEN
            IF tax_type_tab(I) = 1 THEN
                bsln_amt := p_assessable_value;
            ELSIF tax_type_tab(I) = 4 THEN
                bsln_amt := p_vat_assessable_value;
            ELSE
                bsln_amt := p_tax_amount;
            END IF;

            IF tax_rate_tab(I) <> 0 THEN
                IF P1(I) < I AND P1(I) NOT IN (-1,0) THEN
                    vamt := vamt + NVL(tax_amt_tab(P1(I)),0);
                ELSIF P1(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                END IF;
                IF p2(I) < I AND p2(I) NOT IN (-1,0) THEN
                    vamt := vamt + NVL(tax_amt_tab(p2(I)),0);
                ELSIF p2(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                END IF;
                IF p3(I) < I AND p3(I) NOT IN (-1,0) THEN
                    vamt := vamt + NVL(tax_amt_tab(p3(I)),0);
                ELSIF p3(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                END IF;
                IF p4(I) < I AND p4(I) NOT IN (-1,0) THEN
                    vamt := vamt + NVL(tax_amt_tab(p4(I)),0);
                ELSIF p4(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                END IF;
                IF p5(I) < I AND p5(I) NOT IN (-1,0) THEN
                    vamt := vamt + NVL(tax_amt_tab(p5(I)),0);
                ELSIF p5(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                END IF;
-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    -- start bug 5228046
                IF P6(I) < I AND P6(I) NOT IN (-1,0) THEN
                    vamt := vamt + NVL(tax_amt_tab(P6(I)),0);
                ELSIF P6(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                END IF;
                IF p7(I) < I AND p7(I) NOT IN (-1,0) THEN
                    vamt := vamt + NVL(tax_amt_tab(p7(I)),0);
                ELSIF p7(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                END IF;
                IF p8(I) < I AND p8(I) NOT IN (-1,0) THEN
                    vamt := vamt + NVL(tax_amt_tab(p8(I)),0);
                ELSIF p8(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                END IF;
                IF p9(I) < I AND p9(I) NOT IN (-1,0) THEN
                    vamt := vamt + NVL(tax_amt_tab(p9(I)),0);
                ELSIF p9(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                END IF;
                IF p10(I) < I AND p10(I) NOT IN (-1,0) THEN
                    vamt := vamt + NVL(tax_amt_tab(p10(I)),0);
                ELSIF p10(I) = 0 THEN
                    vamt := vamt + bsln_amt;
                END IF;
      -- end bug 5228046
                v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
                base_tax_amt_tab(I) := vamt;
                tax_amt_tab(I) := NVL(tax_amt_tab(I),0) + v_tax_amt;
    tax_amt_tab(I) :=  round(tax_amt_tab(I)  ,round_factor_tab(I)); --added by csahoo for bug#6077133
                vamt := 0;
                v_tax_amt := 0;
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
                END IF;
                IF p2(I) > I  THEN
                    vamt := vamt + NVL(tax_amt_tab(p2(I)),0);
                END IF;
                IF p3(I) > I  THEN
                    vamt := vamt + NVL(tax_amt_tab(p3(I)),0);
                END IF;
                IF p4(I) > I THEN
                    vamt := vamt + NVL(tax_amt_tab(p4(I)),0);
                END IF;
                IF p5(I) > I THEN
                    vamt := vamt + NVL(tax_amt_tab(p5(I)),0);
                END IF;
-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    -- start bug 5228046
    IF P6(I) > I THEN
                    vamt := vamt + NVL(tax_amt_tab(P6(I)),0);
                END IF;
                IF p7(I) > I  THEN
                    vamt := vamt + NVL(tax_amt_tab(p7(I)),0);
                END IF;
                IF p8(I) > I  THEN
                    vamt := vamt + NVL(tax_amt_tab(p8(I)),0);
                END IF;
                IF p9(I) > I THEN
                    vamt := vamt + NVL(tax_amt_tab(p9(I)),0);
                END IF;
                IF p10(I) > I THEN
                    vamt := vamt + NVL(tax_amt_tab(p10(I)),0);
                END IF;
   -- end bug 5228046
                base_tax_amt_tab(I) := vamt;
                v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
                IF vamt <> 0 THEN
                    base_tax_amt_tab(I) := base_tax_amt_tab(I) + vamt;
                END IF;
                tax_amt_tab(I) := NVL(tax_amt_tab(I),0) + v_tax_amt;
    tax_amt_tab(I) :=  round(tax_amt_tab(I)  ,round_factor_tab(I)); --added by csahoo for bug#6077133
                vamt := 0;
                v_tax_amt := 0;
            END IF;

        ELSE

            base_tax_amt_tab(I) := vamt;
            tax_amt_tab(I) := 0;
        END IF;

    END LOOP;

    FOR counter IN 1 .. max_iter LOOP
        vamt := 0;
        v_tax_amt := 0;

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
                v_amt := p_assessable_value;
            ELSIF tax_type_tab(I) = 4 THEN
                v_amt := p_vat_assessable_value;
            ELSE
              IF p_assessable_value IN ( 0, -1 ) OR tax_type_tab( I ) <> 1 THEN
                  v_amt := p_tax_amount;
              ELSIF p_vat_assessable_value IN ( 0, -1 ) OR tax_type_tab( I ) <> 4 THEN
                  v_amt := p_tax_amount;
              END IF;
            END IF;

            IF P1( i ) <> -1 THEN
              IF P1( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( P1( I ) );
              ELSIF P1(i) = 0 THEN
                  vamt := vamt + v_amt;
              END IF;
            END IF;

            IF p2( i ) <> -1 THEN
              IF p2( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( p2( I ) );
              ELSIF p2(i) = 0 THEN
                  vamt := vamt + v_amt;
              END IF;
            END IF;
            IF p3( i ) <> -1 THEN
              IF p3( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( p3( I ) );
              ELSIF p3(i) = 0 THEN
                  vamt := vamt + v_amt;
              END IF;
            END IF;

            IF p4( i ) <> -1 THEN
              IF p4( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p4( i ) );
              ELSIF p4(i) = 0 THEN
                vamt := vamt + v_amt;
              END IF;
            END IF;

            IF p5( i ) <> -1 THEN
              IF p5( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p5( i ) );
              ELSIF p5(i) = 0 THEN
                vamt := vamt + v_amt;
              END IF;
            END IF;

-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    -- start bug 5228046
      IF P6( i ) <> -1 THEN
              IF P6( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( P6( I ) );
              ELSIF P6(i) = 0 THEN
                  vamt := vamt + v_amt;
              END IF;
            END IF;

            IF p7( i ) <> -1 THEN
              IF p7( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( p7( I ) );
              ELSIF p7(i) = 0 THEN
                  vamt := vamt + v_amt;
              END IF;
            END IF;
            IF p8( i ) <> -1 THEN
              IF p8( i ) <> 0 THEN
                  vamt := vamt + tax_amt_tab( p8( I ) );
              ELSIF p8(i) = 0 THEN
                  vamt := vamt + v_amt;
              END IF;
            END IF;

            IF p9( i ) <> -1 THEN
              IF p9( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p9( i ) );
              ELSIF p9(i) = 0 THEN
                vamt := vamt + v_amt;
              END IF;
            END IF;

            IF p10( i ) <> -1 THEN
              IF p10( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p10( i ) );
              ELSIF p10(i) = 0 THEN
                vamt := vamt + v_amt;
              END IF;
            END IF;

   -- end bug 5228046


            base_tax_amt_tab(I) := vamt;
            tax_target_tab(I) := vamt;

            --------------------------------------------------------------------------------------
            /*Change History: jai_cmn_tax_defaultation_pkg
            Last Modified By Jagdish Bhosle.  2001/04/05
            The follow check will ensure that for Bond reg. Txns
            excise duty will not be added to original Line amount. */
            --------------------------------------------------------------------------------------
            IF (v_register_code='BOND_REG') THEN            --- Added By Jagdish    2001/04/05
              IF  counter = max_iter AND tax_type_tab( I ) NOT IN ( 1, 2) THEN
                v_func_tax_amt := v_tax_amt +  ( vamt * ( tax_rate_tab( i )/100));
                v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
              END IF;

            ELSE
              v_func_tax_amt := v_tax_amt +  ( vamt * ( tax_rate_tab( i )/100));
              v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
            END IF;  -- End of Addition Jagdish 2001/04/05

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
      tax_amt_tab(I) :=  round(tax_amt_tab(I)  ,round_factor_tab(I));  --added by csahoo for bug#6077133
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

        END LOOP;

    END LOOP;

END IF;
--===========================================================================================================

    row_count := 1;

    -- this is the place where you hv to add your insert statements for transaction specific tables
    rec := null ; -- added by ssumaith - code review comments for TCS buG#6109941
    FOR i in 1.. lt_tax_table.count LOOP
        rec := lt_tax_table(i);
    -- ends additions by ssumaith - code review comments for TCS bug# 6109941
        IF tax_type_tab(row_count) <> 2 THEN
            v_tax_amt := v_tax_amt + NVL(tax_amt_tab(row_count),0);
        END IF;


        /** bgowrava for forward porting bug# 5631784  */
          if rec.mod_cr_percentage is not null and rec.mod_cr_percentage > 0 then
            v_modvat_flag := 'Y';
            elsif rec.mod_cr_percentage is null then
            v_modvat_flag := 'N';
        end if;
        /*end  bug# 5631784  */

    if v_debug then fnd_file.put_line(fnd_file.log, 'Before tr_name -> '||transaction_name); end if;

    -- Vijay Shankar for Bug# 2837970
    IF transaction_name = 'CRM_QUOTE' THEN

        if v_debug then fnd_file.put_line(fnd_file.log, 'Before insert into of tr_name -> '||transaction_name); end if;

        INSERT INTO JAI_CRM_QUOTE_TAXES(quote_line_id, quote_header_id, shipment_id, tax_line_no,
            precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
            precedence_6, precedence_7, precedence_8, precedence_9, precedence_10, -- Date 31/10/2006 Bug 5228046 added by SACSETHI
            tax_id, tax_amount,
            base_tax_amount,
            func_tax_amount,
            creation_date, created_by, last_update_date,
            last_updated_by, last_update_login)
        VALUES ( p_line_id, p_header_id, p_operation_flag, row_count,
            rec.p_1, rec.p_2, rec.p_3, rec.p_4, rec.p_5,
            rec.p_6, rec.p_7, rec.p_8, rec.p_9, rec.p_10,
            rec.tax_id, ROUND(nvl(tax_amt_tab(row_count),0),REC.ROUNDING_FACTOR),
            decode(nvl(base_tax_amt_tab(row_count), 0), 0, nvl(tax_amt_tab(row_count),0), nvl(base_tax_amt_tab(row_count), 0)),
            (nvl(func_tax_amt_tab(row_count),0) *  v_currency_conv_factor),
            nvl(p_creation_date, SYSDATE), nvl(p_created_by,1), nvl(p_last_update_date,SYSDATE) ,
            nvl(p_last_updated_by,1), nvl(p_last_update_login,1) );

    -- end, Vijay Shankar for Bug# 2837970
    ELSIF transaction_name = 'SALES_ORDER' THEN
            INSERT INTO JAI_OM_OE_SO_TAXES(
                line_id, header_id, tax_line_no,
                precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
                precedence_6, precedence_7, precedence_8, precedence_9, precedence_10, -- Date 31/10/2006 Bug 5228046 added by SACSETHI
    tax_id, tax_rate, qty_rate, uom,
                tax_amount,
                base_tax_amount,
                func_tax_amount,
                creation_date, created_by, last_update_date,
                last_updated_by, last_update_login,
                tax_category_id         -- cbabu for EnhancementBug# 2427465
            ) VALUES (
                p_line_id, p_header_id, row_count,
                rec.p_1, rec.p_2, rec.p_3, rec.p_4, rec.p_5,
                rec.p_6, rec.p_7, rec.p_8, rec.p_9, rec.p_10,
    rec.tax_id, rec.tax_rate, rec.tax_amount, rec.uom_code,
                ROUND(NVL(tax_amt_tab(row_count),0),REC.ROUNDING_FACTOR),
                DECODE(NVL(base_tax_amt_tab(row_count), 0), 0, NVL(tax_amt_tab(row_count),0), NVL(base_tax_amt_tab(row_count), 0)),
                (NVL(func_tax_amt_tab(row_count),0) *  v_currency_conv_factor),
                p_creation_date, p_created_by, p_last_update_date,
                p_last_updated_by, p_last_update_login,
                p_tax_category_id       -- cbabu for EnhancementBug# 2427465
            );

     ELSIF transaction_name='INTERORG_XFER' THEN
           /*added by rchandan for bug#6030615*/
         BEGIN
                 DECLARE
                 v_modvat_flag   VARCHAR2(1);
                 BEGIN
                         IF rec.mod_cr_percentage IS NOT NULL AND rec.mod_cr_percentage > 0 THEN
                                 v_modvat_flag := 'Y';
                         ELSIF rec.mod_cr_percentage IS NULL THEN
                                 v_modvat_flag := 'N';
                         END IF;
                         -- bug 6436825
                         IF REC.TAX_TYPE NOT IN ('Service',  JAI_CONSTANTS.TAX_TYPE_SH_SERVICE_EDU_CESS,
                              JAI_CONSTANTS.TAX_TYPE_SERVICE_EDU_CESS,
                              JAI_CONSTANTS.TAX_TYPE_SH_CUSTOMS_EDU_CESS,
                              JAI_CONSTANTS.TAX_TYPE_CUSTOMS_EDU_CESS,
                               'CVD_EDUCATION_CESS', JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,
                               'Customs', 'CVD', 'ADDITIONAL_CVD' ,'TDS' , 'Modvat Recovery') THEN

                                 INSERT INTO jai_cmn_document_taxes(
                                 DOC_TAX_ID,
                                 tax_line_no,
                                 tax_id ,
                                 tax_type,
                                 currency_code ,
                                 tax_rate  ,
                                 qty_rate ,
                                 uom      ,
                                 tax_amt  ,
                                 func_tax_amt,
                                 modvat_flag,
                                 tax_category_id,
                                 source_doc_type ,
                                 source_doc_id ,
                                 source_doc_line_id ,
                                 source_table_name  ,
                                 TAX_MODIFIED_BY  ,
                                 adhoc_flag   ,
                                 precedence_1  ,
                                 precedence_2  ,
                                 precedence_3  ,
                                 precedence_4  ,
                                 precedence_5  ,
                                 precedence_6  ,
                                 precedence_7  ,
                                 precedence_8  ,
                                 precedence_9   ,
                                 precedence_10  ,
                                 creation_date  ,
                                 created_by      ,
                                 last_update_date  ,
                                 last_updated_by   ,
                                 last_update_login )
                                 VALUES (
                                 jai_cmn_document_taxes_s.nextval ,
                                 v_line_num,
                                 rec.tax_id,
                                 rec.tax_type,
                                 p_currency,
                                 rec.tax_rate,
                                 rec.tax_amount,
                                 rec.uom_code,
                                 round(nvl(tax_amt_tab(row_count),0),rec.rounding_factor),
                                 round(NVL(func_tax_amt_tab(row_count),0) * v_currency_conv_factor,rec.rounding_factor),
                                 v_modvat_flag,
                                 p_tax_category_id ,
                                 'INTERORG_XFER',
                                 p_header_id,
                                 p_line_id,
                                 'MTL_MATERIAL_TRANSACTIONS_TEMP',
                                 NULL,
                                 rec.adhoc_flag,
                                 rec.p_1,
                                 rec.p_2,
                                 rec.p_3,
                                 rec.p_4,
                                 rec.p_5,
                                 rec.p_6,
                                 rec.p_7,
                                 rec.p_8,
                                 rec.p_9,
                                 rec.p_10,
                                 p_creation_date,
                                 p_created_by,
                                 p_last_update_date,
                                 p_last_updated_by,
                                 p_last_update_login
                                 );
                                 v_line_num:=nvl(v_line_num,1)+1;
                         END IF;
                 END;
         END;

        ELSIF transaction_name = 'RMA_LEGACY_INSERT' THEN

            -- This elsif added by Aparajita on 31-may-2002 for bug 2381492
            INSERT INTO JAI_OM_OE_RMA_TAXES (
                rma_line_id, tax_line_no,
    precedence_1, precedence_2, precedence_3,  precedence_4,precedence_5,
    precedence_6, precedence_7, precedence_8,  precedence_9,precedence_10, -- Date 31/10/2006 Bug 5228046 added by SACSETHI
    tax_id,  tax_rate,
                qty_rate, uom, tax_amount,
                base_tax_amount,
                func_tax_amount, creation_date, created_by,
                last_update_date, last_updated_by,  last_update_login
            ) VALUES (
                p_line_id, row_count,
    rec.p_1,rec.p_2, rec.p_3,rec.p_4,   rec.p_5,
    rec.p_6,rec.p_7, rec.p_8,rec.p_9,   rec.p_10,
    rec.tax_id,  rec.tax_rate,
                rec.tax_amount, rec.uom_code, ROUND(nvl(tax_amt_tab(row_count),0), rec.rounding_factor),
                DECODE( NVL(base_tax_amt_tab(row_count), 0), 0, NVL(tax_amt_tab(row_count),0), NVL(base_tax_amt_tab(row_count), 0) ),
                nvl(func_tax_amt_tab(row_count),0) * v_currency_conv_factor, p_creation_date, p_created_by,
                p_last_update_date, p_last_updated_by,  p_last_update_login
            );

        ELSIF transaction_name = 'SO_LINES_UPDATE'  THEN

            UPDATE JAI_OM_OE_SO_TAXES
            SET tax_amount = ROUND(NVL(tax_amt_tab(row_count),0), REC.ROUNDING_FACTOR),
                base_tax_amount = DECODE(NVL(base_tax_amt_tab(row_count), 0), 0, NVL(tax_amt_tab(row_count),0), NVL(base_tax_amt_tab(row_count), 0)),
                func_tax_amount = NVL(func_tax_amt_tab(row_count),0) * v_currency_conv_factor,
                last_update_date = p_last_update_date,
                last_updated_by = p_last_updated_by,
                last_update_login = p_last_update_login
            WHERE line_id = P_line_id
            AND header_id = p_header_id
            AND tax_line_no = row_count;

        ELSIF transaction_name = 'AR_LINES' THEN

            --2001/03/30 Manohar Mishra
            -- Added the following IF condition
            --if (v_register_code='BOND_REG') --and (rec.tax_type_val<>1))
            --then
            --if (rec.tax_type_val<>1) then

      /*Bug 8371741 - Start*/

                        get_created_from(p_header_id, l_created_from);

                        if (l_created_from = 'ARXTWMAI' and p_max_rgm_tax_line>0) then

      INSERT INTO JAI_AR_TRX_TAX_LINES(
                customer_trx_line_id, link_to_cust_trx_line_id, tax_line_no,
                precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
                precedence_6, precedence_7, precedence_8, precedence_9, precedence_10, -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                tax_id, tax_rate, qty_rate, uom,
                tax_amount,
                base_tax_amount,
                func_tax_amount,
                creation_date, created_by, last_update_date,
                last_updated_by, last_update_login
            ) VALUES(
                ra_customer_trx_lines_s.NEXTVAL, p_line_id, rec.lno,
                rec.p_1, rec.p_2, rec.p_3, rec.p_4, rec.p_5,
                rec.p_6, rec.p_7, rec.p_8, rec.p_9, rec.p_10,
    rec.tax_id, rec.tax_rate, rec.tax_amount, rec.uom_code,
                ROUND(NVL(tax_amt_tab(row_count), 0), REC.ROUNDING_FACTOR),
                DECODE(NVL(base_tax_amt_tab(row_count), 0), 0, NVL(tax_amt_tab(row_count),0), NVL(base_tax_amt_tab(row_count), 0)),
                ROUND(NVL(func_tax_amt_tab(row_count),0), REC.ROUNDING_FACTOR) * v_currency_conv_factor, --Modified by Bo Li for Bug#9780751 on 11-JUN-2010
                p_creation_date, p_created_by, p_last_update_date,
                p_last_updated_by, p_last_update_login
            );

      else

            INSERT INTO JAI_AR_TRX_TAX_LINES(
                customer_trx_line_id, link_to_cust_trx_line_id, tax_line_no,
                precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
                precedence_6, precedence_7, precedence_8, precedence_9, precedence_10, -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                tax_id, tax_rate, qty_rate, uom,
                tax_amount,
                base_tax_amount,
                func_tax_amount,
                creation_date, created_by, last_update_date,
                last_updated_by, last_update_login
            ) VALUES(
                ra_customer_trx_lines_s.NEXTVAL, p_line_id, row_count,
                rec.p_1, rec.p_2, rec.p_3, rec.p_4, rec.p_5,
                rec.p_6, rec.p_7, rec.p_8, rec.p_9, rec.p_10,
    rec.tax_id, rec.tax_rate, rec.tax_amount, rec.uom_code,
                ROUND(NVL(tax_amt_tab(row_count), 0), REC.ROUNDING_FACTOR),
                DECODE(NVL(base_tax_amt_tab(row_count), 0), 0, NVL(tax_amt_tab(row_count),0), NVL(base_tax_amt_tab(row_count), 0)),
                ROUND(NVL(func_tax_amt_tab(row_count),0), REC.ROUNDING_FACTOR) * v_currency_conv_factor, --Modified by Bo Li for Bug#9780751 on 11-JUN-2010D:\Workplace\Source\BUG\bug9780751\jai_cmn_tax_dflt.plb
                p_creation_date, p_created_by, p_last_update_date,
                p_last_updated_by, p_last_update_login
            );

      end if;

      /*Bug 8371741 - End*/

            /*
                end if;
            else
                INSERT INTO JAI_AR_TRX_TAX_LINES(customer_trx_line_id,
                    link_to_cust_trx_line_id,
                    tax_line_no,
                    precedence_1,precedence_2, precedence_3, precedence_4,precedence_5,
                    precedence_6,precedence_7, precedence_8, precedence_9,precedence_10, -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                    tax_id, tax_rate, qty_rate, uom,
                    tax_amount,
                    base_tax_amount,
                    func_tax_amount,
                    creation_date, created_by, last_update_date,
                    last_updated_by, last_update_login)
                VALUES(ra_customer_trx_lines_s.nextval, p_line_id, row_count,
                    rec.p_1, rec.p_2, rec.p_3, rec.p_4, rec.p_5,
                    rec.p_6, rec.p_7, rec.p_8, rec.p_9, rec.p_10,
        rec.tax_id, rec.tax_rate, rec.tax_amount, rec.uom_code,
                    ROUND(nvl(tax_amt_tab(row_count), 0), REC.ROUNDING_FACTOR),
                    decode(nvl(base_tax_amt_tab(row_count), 0), 0, nvl(tax_amt_tab(row_count),0), nvl(base_tax_amt_tab(row_count), 0)),
                    (nvl(func_tax_amt_tab(row_count),0) *  v_currency_conv_factor),
                    p_creation_date, p_created_by, p_last_update_date,
                    p_last_updated_by, p_last_update_login);
            end if;
            */

        ELSIF transaction_name = 'AR_LINES_UPDATE' THEN

            --2001/03/30 Manohar Mishra
            -- Added the following IF condition
            --if ((v_register_code<>'BOND_REG') and (rec.tax_type_val<>1)) then
            UPDATE JAI_AR_TRX_TAX_LINES
            SET tax_amount      = ROUND(NVL(tax_amt_tab(row_count), 0), REC.ROUNDING_FACTOR),
                base_tax_amount   = DECODE(NVL(base_tax_amt_tab(row_count), 0), 0, NVL(tax_amt_tab(row_count),0), NVL(base_tax_amt_tab(row_count), 0)),
                func_tax_amount   = NVL(func_tax_amt_tab(row_count),0) *  v_currency_conv_factor,
                last_update_date  = p_last_update_date,
                last_updated_by   = p_last_updated_by,
                last_update_login = p_last_update_login
            WHERE link_to_cust_trx_line_id = P_line_id
            AND     tax_line_no = row_count;

            --end if;

        ELSIF SUBSTR( transaction_name, 1, 3 ) = 'RFQ' OR
            SUBSTR( transaction_name, 1, 9 ) = 'QUOTATION' OR
            SUBSTR( transaction_name, 1, 7 ) = 'BLANKET' OR
            SUBSTR( transaction_name, 1, 8 ) = 'BLANKETR' OR
            SUBSTR( transaction_name, 1, 6 ) = 'OTHERS' OR
            SUBSTR( transaction_name, 1, 9 ) = 'SCHEDULED' THEN

            /*
            Since there is no provision of line location id as one of the parameter,
            Line location Id is passed in place of line id, Line Id is concatinated
            to transaction name.
            If proportioning has to be done, then operation variable takes value U
            else takes I. This is also concatenated with transaction name with a preceding $.
            */

            BEGIN       -- MBEGIN

            DECLARE     -- NDECLARE

                v_seq_val           NUMBER;
                v_modvat_flag   VARCHAR2(1);
                v_vendor_id     NUMBER;
                v_vendor1_id    NUMBER;
                v_vendor2_id    NUMBER;
                v_currency      VARCHAR2(15);
                v_transaction_name  VARCHAR2(100);
                v_mod_cr            NUMBER;
                v_tax_type      VARCHAR2(30);
                v_start             NUMBER;
                v_line_id           NUMBER;
                operation           VARCHAR2(2);

                CURSOR fetch_mod_cr_cur( taxid IN NUMBER ) IS
                    SELECT Tax_Type, Mod_Cr_Percentage, Vendor_Id
                    FROM JAI_CMN_TAXES_ALL
                    WHERE Tax_Id = taxid;

                CURSOR fetch_vendor2_cur IS
                    SELECT vendor_id
                    FROM JAI_PO_REQ_LINE_TAXES
                    WHERE Requisition_Line_Id = ( SELECT Requisition_Line_Id
                    FROM Po_Requisition_Lines_All
                    WHERE Line_Location_Id = p_line_id );

                CURSOR fetch_focus_id IS
                    SELECT Line_Focus_Id
                    FROM JAI_PO_LINE_LOCATIONS
                    WHERE Po_Line_Id = p_line_id
                    AND Po_Header_Id = p_header_id
                    AND Line_Location_Id IS NULL;

                CURSOR fetch_focus1_id( line_id IN NUMBER ) IS
                    SELECT Line_Focus_Id
                    FROM JAI_PO_LINE_LOCATIONS
                    WHERE Po_Line_Id = p_line_id
                    AND Po_Header_Id = p_header_id
                    AND Line_Location_Id = line_id;

            BEGIN       -- NBEGIN

                IF SUBSTR( transaction_name, 1, 1 ) = 'R' THEN
                    v_transaction_name := 'RFQ';
                    v_start := 4;
                ELSIF SUBSTR( transaction_name, 1, 1 ) = 'S' THEN
                    v_transaction_name := 'RFQ';
                    v_start := 10;
                ELSIF SUBSTR( transaction_name, 1, 1 ) = 'Q' THEN
                    v_transaction_name := 'QUOTATION';
                    v_start := 10;
                ELSIF SUBSTR( transaction_name, 1, 1 ) = 'B' AND SUBSTR( transaction_name, 1, 8 ) <> 'BLANKETR' THEN
                    v_transaction_name := 'BLANKET';
                    v_start := 8;
                ELSIF SUBSTR( transaction_name, 1, 8 ) = 'BLANKETR' THEN
                    v_transaction_name := 'RFQ';
                    v_start := 9;
                ELSIF SUBSTR( transaction_name, 1, 1 ) = 'O' THEN
                    v_transaction_name := 'OTHERS';
                    v_start := 7;
                END IF;

                operation := SUBSTR( transaction_name, INSTR(transaction_name, '$' )+1, 1 );
                v_line_id := TO_NUMBER( SUBSTR( transaction_name, v_start, LENGTH( transaction_name )-( v_start + 1 )));

                IF NVL( v_line_id, 0 ) = 0  THEN

                    OPEN  Fetch_Focus_Id;
                    FETCH Fetch_Focus_Id INTO v_seq_val;
                    CLOSE Fetch_Focus_Id;

                    v_line_focus_id_holder := v_seq_val;    -- cbabu for EnhancementBug# 2427465

                ELSE
                    OPEN  Fetch_Focus1_Id( v_line_id );
                    FETCH Fetch_Focus1_Id INTO v_seq_val;
                    CLOSE Fetch_Focus1_Id;

                    v_line_focus_id_holder := v_seq_val;    -- cbabu for EnhancementBug# 2427465

                END IF;

                OPEN Fetch_Mod_Cr_Cur( rec.tax_id );
                FETCH Fetch_Mod_Cr_Cur INTO v_tax_type, v_mod_cr, v_vendor1_id;
                CLOSE Fetch_Mod_Cr_Cur;

                IF rec.mod_cr_percentage IS NOT NULL AND rec.mod_cr_percentage > 0 THEN
                    v_modvat_flag := 'Y';
                ELSIF rec.mod_cr_percentage IS NULL THEN
                    v_modvat_flag := 'N';
                END IF;

                IF v_transaction_name IN ( 'OTHERS', 'QUOTATION', 'BLANKET' ) THEN
                    IF upper(rec.tax_type) IN ( 'CVD',
                                     jai_constants.tax_type_add_cvd ,      -- Date 31/10/2006 Bug 5228046 added by SACSETHI
             'CUSTOMS' ,
             JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,/*bduvarag for the bug#5989740*/
             jai_constants.tax_type_cvd_edu_cess ,
             JAI_CONSTANTS.TAX_TYPE_SH_CUSTOMS_EDU_CESS,/*bduvarag for the bug#5989740*/
             jai_constants.tax_type_customs_edu_cess
               ) THEN
                       v_vendor_id := NULL;
                    ELSIF UPPER( rec.tax_type ) LIKE UPPER( '%EXCISE%' ) THEN
                        v_vendor_id := p_vendor_id;
                    ELSE
                        v_vendor_id := NVL( v_vendor1_id, p_vendor_id );
                    END IF;
                END IF;

                IF rec.tax_type = 'TDS' THEN
                    v_vendor_id := v_vendor1_id;
                END IF;

                IF operation = 'I' THEN
                    IF p_operation_flag <> -1 THEN
                        INSERT INTO JAI_PO_TAXES(
                            line_focus_id, line_location_id,  po_line_id, po_header_id,
                            tax_line_no,
          precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
          precedence_6, precedence_7, precedence_8, precedence_9, precedence_10, -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                            tax_id, tax_type, tax_rate, qty_rate, uom, tax_amount, tax_target_amount,
                            currency, modvat_flag, vendor_id,
                            creation_date, created_by,
                            last_update_date, last_updated_by, last_update_login,
                            tax_category_id     -- cbabu for EnhancementBug# 2427465
                        ) VALUES (
                            v_seq_val, v_line_id, p_line_id, p_header_id,
                            row_count,
          rec.p_1, rec.p_2,rec.p_3, rec.p_4, rec.p_5,
          rec.p_6, rec.p_7,rec.p_8, rec.p_9, rec.p_10,
                            rec.tax_id,  rec.tax_type, rec.tax_rate, rec.tax_amount, rec.uom_code,
                            ROUND(NVL(tax_amt_tab(row_count),0), REC.ROUNDING_FACTOR),
                            DECODE(NVL(base_tax_amt_tab(row_count), 0), 0, NVL(tax_amt_tab(row_count),0),
                            NVL(base_tax_amt_tab(row_count), 0)) * p_currency_conv_factor ,
                            p_currency, v_modvat_flag, v_vendor_id,
                            p_creation_date, p_created_by,
                            p_last_update_date, p_last_updated_by, p_last_update_login,
                            p_tax_category_id   -- cbabu for EnhancementBug# 2427465
                        );

                        --Added by Kevin Cheng for Retroactive Price 2008/01/13
                        --=====================================================
                        IF pv_retroprice_changed = 'Y'
                        THEN
                          JAI_RETRO_PRC_PKG.Update_Price_Changes( pn_tax_amt         => ROUND(NVL(tax_amt_tab(row_count),0), REC.ROUNDING_FACTOR)
                                                                , pn_line_no         => row_count
                                                                , pn_line_loc_id     => v_line_id
                                                                , pv_process_flag    => lv_process_flag
                                                                , pv_process_message => lv_process_message
                                                                );

                          IF lv_process_flag IN ('EE', 'UE')
                          THEN
                            FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
                            FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG','JAI_CMN_TAX_DEFAULTATION_PKG.JA_IN_CALC_PREC_TAXES.Err:'||lv_process_message);
                            app_exception.raise_exception;
                          END IF;
                        END IF;
                        --=====================================================

                    ELSE

                        INSERT INTO JAI_PO_TAXES(
                            Line_Focus_Id, Line_Location_Id,  Po_Line_Id, Po_Header_Id,
                            Tax_Line_No,
          Precedence_1, Precedence_2, Precedence_3, Precedence_4, Precedence_5,
          Precedence_6, Precedence_7, Precedence_8, Precedence_9, Precedence_10, -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                            Tax_Id, Tax_Type, Tax_Rate, Qty_Rate, UOM, Tax_Amount,
                            Tax_Target_Amount,
                            Currency, Modvat_Flag, Vendor_Id,
                            Creation_Date, Created_By,
                            Last_Update_Date, Last_Updated_By, Last_Update_Login,
                            tax_category_id     -- cbabu for EnhancementBug# 2427465
                        ) VALUES (
                            v_seq_val, NULL, p_line_id, p_header_id,
                            row_count,
          rec.p_1, rec.p_2, rec.p_3, rec.p_4, rec.p_5,
          rec.p_6, rec.p_7, rec.p_8, rec.p_9, rec.p_10,
                            rec.tax_id,  rec.tax_type, rec.tax_rate, rec.tax_amount, rec.uom_code, NULL,
                            DECODE( NVL(base_tax_amt_tab(row_count), 0), 0, NVL(tax_amt_tab(row_count),0),
                                NVL(base_tax_amt_tab(row_count), 0)) * p_currency_conv_factor ,
                            p_currency, v_modvat_flag, v_vendor_id,
                            p_creation_date, p_created_by,
                            p_last_update_date, p_last_updated_by, p_last_update_login,
                            p_tax_category_id   -- cbabu for EnhancementBug# 2427465
                        );
                    END IF;

                ELSIF operation = 'U' THEN

                    IF v_line_id IS NOT NULL THEN
                        UPDATE JAI_PO_TAXES
                        SET Tax_Amount = ROUND(NVL( tax_amt_tab(row_count), 0 ),REC.ROUNDING_FACTOR),
                            tax_target_amount = DECODE(NVL(base_tax_amt_tab(row_count), 0), 0, NVL(tax_amt_tab(row_count),0),
                                NVL(base_tax_amt_tab(row_count), 0)) * p_currency_conv_factor ,
                            last_updated_by = p_last_updated_by,
                            last_update_date = p_last_update_date,
                            last_update_login = p_last_update_login
                        WHERE po_line_id = p_line_id
                        AND line_location_id = v_line_id;
                    ELSE
                        UPDATE JAI_PO_TAXES
                        SET Tax_Amount = ROUND(NVL( tax_amt_tab(row_count), 0 ), REC.ROUNDING_FACTOR),
                            tax_target_amount = DECODE(NVL(base_tax_amt_tab(row_count), 0), 0, NVL(tax_amt_tab(row_count),0),
                                NVL(base_tax_amt_tab(row_count), 0)) * p_currency_conv_factor ,
                            last_updated_by = p_last_updated_by,
                            last_update_date = p_last_update_date,
                            last_update_login = p_last_update_login
                        WHERE Po_Line_Id = p_line_id
                        AND Line_Location_Id IS NULL;
                    END IF;

                END IF;
                v_vendor_id := NULL;

            END;    -- NDECLARE, NBEGIN

            END;    -- MBEGIN   -- transaction_name = RFQ/QUOTATION/PURCHASE ORDER/RELEASES

        ELSIF transaction_name = 'PO_REQN' THEN

            BEGIN

            DECLARE

                v_modvat_flag   VARCHAR2(1);
                v_vendor_id     NUMBER;
                v_currency      VARCHAR2(15);

            BEGIN

                IF rec.mod_cr_percentage IS NOT NULL AND rec.mod_cr_percentage > 0 THEN
                    v_modvat_flag := 'Y';
                ELSIF rec.mod_cr_percentage IS NULL THEN
                    v_modvat_flag := 'N';
                END IF;
                IF rec.tax_type = 'TDS' THEN
                    v_vendor_id := rec.vendor_id;
                ELSIF UPPER(rec.tax_type) IN ('CVD',
                                  jai_constants.tax_type_add_cvd ,  -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                'CUSTOMS',
    JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,/*bduvarag for the bug#5989740*/
                jai_constants.tax_type_cvd_edu_cess ,
    JAI_CONSTANTS.TAX_TYPE_SH_CUSTOMS_EDU_CESS,/*bduvarag for the bug#5989740*/
                jai_constants.tax_type_customs_edu_cess
               ) THEN
                    v_vendor_id := NULL;
                ELSIF UPPER( rec.tax_type ) LIKE '%EXCISE%' THEN
                    v_vendor_id := p_vendor_id;
                ELSE
                    v_vendor_id := NVL( rec.vendor_id, p_vendor_id );
                END IF;

                IF p_currency IS NOT NULL THEN
                    v_currency := p_currency;
                END IF;
                IF NVL( p_operation_flag, 0 ) <  0 AND ( UPPER( rec.tax_type ) LIKE '%EXCISE%' OR UPPER(rec.tax_type)
       NOT IN ( 'CVD',
                jai_constants.tax_type_add_cvd,      -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                'CUSTOMS',
    JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,/*bduvarag for the bug#5989740*/
      jai_constants.tax_type_cvd_edu_cess ,
    JAI_CONSTANTS.TAX_TYPE_SH_CUSTOMS_EDU_CESS,/*bduvarag for the bug#5989740*/
      jai_constants.tax_type_customs_edu_cess
        ) )
       THEN /* Indiactes an Internal Requisition */
                    v_vendor_id := p_operation_flag;
                END IF;

                INSERT INTO JAI_PO_REQ_LINE_TAXES(
                    requisition_line_id, requisition_header_id, tax_line_no,
                    precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
                    precedence_6, precedence_7, precedence_8, precedence_9, precedence_10, -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                    tax_id, tax_rate, qty_rate, uom, tax_amount, Tax_Target_Amount,
                    tax_type, modvat_flag, vendor_id, currency,
                    creation_date, created_by, last_update_date,
                    last_updated_by, last_update_login,
                    tax_category_id     -- cbabu for EnhancementBug# 2427465
                ) VALUES (
                    p_line_id, p_header_id, row_count,
                    rec.p_1, rec.p_2, rec.p_3,rec.p_4, rec.p_5,
                    rec.p_6, rec.p_7, rec.p_8,rec.p_9, rec.p_10,
                    rec.tax_id, rec.tax_rate, rec.tax_amount, rec.uom_code,
                    ROUND( NVL(tax_amt_tab(row_count),0), rec.rounding_factor), -- v_currency_conv_factor ),
                    NVL( base_tax_amt_tab(row_count), 0) * ( v_currency_conv_factor),  rec.tax_type, v_modvat_flag, v_vendor_id, v_currency,
                    p_creation_date, p_created_by, p_last_update_date,
                    p_last_updated_by, p_last_update_login,
                    p_tax_category_id       -- cbabu for EnhancementBug# 2427465
                );

            END;

            END;




          /* bgowrava for forward porting bug#5631784 */
    /* Added OR condition as we are passing p_action as null in case of 'CASH' Receipt. by JMEENA */
        elsif (p_source_trx_type in  (
                                        jai_constants.pa_draft_invoice    /* 6012570 (5876390) */
                                      , jai_constants.G_AP_STANDALONE_INVOICE
                                     -- Added by Jason Liu on 2007/08/23
                                    )
          and p_action = jai_constants.default_taxes )
    OR (p_source_trx_type =  jai_constants.ar_cash)
        then
        -- Added by Jason Liu for standalone invoice on 2007/08/23
        ----------------------------------------------------------------------
          IF p_source_trx_type = jai_constants.G_AP_STANDALONE_INVOICE
            AND rec.tax_type IN ( jai_constants.tax_type_value_added
                                , jai_constants.tax_type_sales
                                , jai_constants.tax_type_cst
                                , jai_constants.tax_type_other)
          THEN
      v_modvat_flag := 'N';
    END IF;  --p_source_trx_type = jai_constants.AP_STANDALONE_INVOICE
        ----------------------------------------------------------------------

            /*
            || When currency conversion rate is null it means the transaction is in the INR only
            */
            if v_currency_conv_factor is null then
              v_currency_conv_factor := 1;
            end if;

        /*   jai_cmn_debug_contexts_pkg.print
              (ln_reg_id
              ,'Values before insert into jai_cmn_document_taxes'                                                   ||chr(10)
               || ',tax_line_no            -> '||row_count                                                      ||CHR(10)
               || ',tax_id                 -> '||rec.tax_id                                                     ||CHR(10)
               || ',tax_type               -> '||rec.tax_type                                                   ||CHR(10)
               || ',currency_code          -> '||p_currency                                                     ||CHR(10)
               || ',tax_rate               -> '||rec.tax_rate                                                   ||CHR(10)
               || ',qty_rate               -> '||rec.tax_amount                                                 ||CHR(10)
               || ',uom                    -> '||rec.uom_code                                                   ||CHR(10)
               || ',tax_amt                -> '||round( nvl(tax_amt_tab(row_count),0) , rec.rounding_factor  )  ||CHR(10)
               || ',func_tax_amt           -> '||nvl(func_tax_amt_tab(row_count),0) * v_currency_conv_factor    ||CHR(10)
               || ',modvat_flag            -> '||v_modvat_flag                                                  ||CHR(10)
               || ',adhoc_flag             -> '||rec.adhoc_flag                                                 ||CHR(10)
               || ',tax_category_id        -> '||rec.tax_category_id                                            ||CHR(10)
               || ',source_doc_type        -> '||p_source_trx_type                                              ||CHR(10)
               || ',source_doc_id          -> '||p_header_id                                                    ||CHR(10)
               || ',source_doc_line_id     -> '||p_line_id                                                      ||CHR(10)
               || ',source_table_name      -> '||p_source_table_name                                            ||CHR(10)
               || ',tax_modified_by        -> '||jai_constants.tax_modified_by_system                           ||CHR(10)
               || ',precedence_1           -> '||rec.p_1                                                        ||CHR(10)
               || ',precedence_2           -> '||rec.p_2                                                        ||CHR(10)
               || ',precedence_3           -> '||rec.p_3                                                        ||CHR(10)
               || ',precedence_4           -> '||rec.p_4                                                        ||CHR(10)
               || ',precedence_5           -> '||rec.p_5                                                        ||CHR(10)
               || ',precedence_6           -> '||rec.p_6                                                        ||CHR(10)
               || ',precedence_7           -> '||rec.p_7                                                        ||CHR(10)
               || ',precedence_8           -> '||rec.p_8                                                        ||CHR(10)
               || ',precedence_9           -> '||rec.p_9                                                        ||CHR(10)
               || ',precedence_10          -> '||rec.p_10                                                       ||CHR(10)
               || ',creation_date          -> '||p_creation_date                                                ||CHR(10)
               || ',created_by             -> '||p_created_by                                                   ||CHR(10)
               || ',last_update_date       -> '||p_last_update_date                                             ||CHR(10)
               || ',last_updated_by        -> '||p_last_updated_by                                              ||CHR(10)
               || ',last_update_login      -> '||p_last_update_login                                            ||CHR(10)
              );   */ --commented by bgowrava for bug#5631784
            -- Added by Eric Ma for standalone invoice on 2007/09/27
            ----------------------------------------------------------------------
            IF (p_source_trx_type = jai_constants.G_AP_STANDALONE_INVOICE )
            THEN
              INSERT INTO jai_cmn_document_taxes
              ( doc_tax_id
              , tax_line_no
              , tax_id
              , tax_type
              , currency_code
              , tax_rate
              , qty_rate
              , uom
              , tax_amt
              , func_tax_amt
              , modvat_flag
              , adhoc_flag
              , tax_category_id
              , source_doc_type
              , source_doc_id
              , source_doc_line_id
              , source_doc_parent_line_no --added by Eric Ma,Sep 27,2007
              , source_table_name
              , tax_modified_by
              , precedence_1
              , precedence_2
              , precedence_3
              , precedence_4
              , precedence_5
              , precedence_6
              , precedence_7
              , precedence_8
              , precedence_9
              , precedence_10
              , creation_date
              , created_by
              , last_update_date
              , last_updated_by
              , last_update_login
              )
              VALUES
              ( jai_cmn_document_taxes_s.nextval        -- doc_tax_id
              , row_count                               -- tax_line_no
              , rec.tax_id                              -- tax_id
              , rec.tax_type                            -- tax_type
              , p_currency                              -- currency
              , rec.tax_rate                            -- tax_rate
              , rec.tax_amount                          -- qty_rate
              , rec.uom_code                            -- uom
              , round( nvl(tax_amt_tab(row_count),0)    -- tax_amount
                     , rec.rounding_factor
                     )
              , nvl(func_tax_amt_tab(row_count),0)
                   * v_currency_conv_factor             -- func_tax_amount
              , v_modvat_flag                           -- modvat_flag
              , rec.adhoc_flag                          -- adhoc_flag
              , rec.tax_category_id                     -- tax_category_id
              , p_source_trx_type                       -- source_doc_type
              , p_header_id                             -- source_doc_id
              , p_line_id                               -- source_doc_line_id
              , p_line_id       -- source_doc_parent_line_no,added by Eric Ma
              , p_source_table_name                      -- source_table_name
              , jai_constants.tax_modified_by_system
              --tax_modified_by(SYSTEM=system defaulted, MANUAL=User Modified)
              , rec.p_1                                  -- precedence_1
              , rec.p_2                                  -- precedence_2
              , rec.p_3                                  -- precedence_3
              , rec.p_4                                  -- precedence_4
              , rec.p_5                                  -- precedence_5
              , rec.p_6                                  -- precedence_6
              , rec.p_7                                  -- precedence_7
              , rec.p_8                                  -- precedence_8
              , rec.p_9                                  -- precedence_9
              , rec.p_10                                 -- precedence_10
              , p_creation_date                          -- creation_date
              , p_created_by                             -- created_by
              , p_last_update_date                       -- last_update_date
              , p_last_updated_by                        -- last_updated_by
              , p_last_update_login                      -- last_update_login
              );
            ELSE --(p_source_trx_type <>jai_constants.G_AP_STANDALONE_INVOICE );
            ------------------------------------------------------------------
            insert into jai_cmn_document_taxes
            (              doc_tax_id
                        ,  tax_line_no
                        ,  tax_id
                        ,  tax_type
                        ,  currency_code
                        ,  tax_rate
                        ,  qty_rate
                        ,  uom
                        ,  tax_amt
                        ,  func_tax_amt
                        ,  modvat_flag
                        ,  adhoc_flag
                        ,  tax_category_id
                        ,  source_doc_type
                        ,  source_doc_id
                        ,  source_doc_line_id
                        ,  source_table_name
                        ,  tax_modified_by
                        ,  precedence_1
                        ,  precedence_2
                        ,  precedence_3
                        ,  precedence_4
                        ,  precedence_5
                        ,  precedence_6
                        ,  precedence_7
                        ,  precedence_8
                        ,  precedence_9
                        ,  precedence_10
                        ,  creation_date
                        ,  created_by
                        ,  last_update_date
                        ,  last_updated_by
                        ,  last_update_login
            )
             values
             (
                             jai_cmn_document_taxes_s.nextval               -- doc_tax_id
                        ,    row_count                                  -- tax_line_no
                        ,    rec.tax_id                                 -- tax_id
                        ,    rec.tax_type                               -- tax_type
                        ,    p_currency                                 -- currency
                        ,    rec.tax_rate                               -- tax_rate
                        ,    rec.tax_amount                             -- qty_rate
                        ,    rec.uom_code                               -- uom
                        ,    round( nvl(tax_amt_tab(row_count),0)       -- tax_amount
                                  , rec.rounding_factor
                                  )
                        ,    nvl(func_tax_amt_tab(row_count),0)
                                * v_currency_conv_factor                -- func_tax_amount
                        ,    v_modvat_flag                              -- modvat_flag
                        ,    rec.adhoc_flag                             -- adhoc_flag
                        ,    rec.tax_category_id                        -- tax_category_id
                        ,    p_source_trx_type                          -- source_doc_type
                        ,    p_header_id                                -- source_doc_id
                        ,    p_line_id                                  -- source_doc_line_id
                        ,    p_source_table_name                        -- source_table_name
                        ,    jai_constants.tax_modified_by_system       -- tax_modified_by (SYSTEM=system defaulted, MANUAL=User Modified)
                        ,    rec.p_1                                    -- precedence_1
                        ,    rec.p_2                                    -- precedence_2
                        ,    rec.p_3                                    -- precedence_3
                        ,    rec.p_4                                    -- precedence_4
                        ,    rec.p_5                                    -- precedence_5
                        ,    rec.p_6                                    -- precedence_6
                        ,    rec.p_7                                    -- precedence_7
                        ,    rec.p_8                                    -- precedence_8
                        ,    rec.p_9                                    -- precedence_9
                        ,    rec.p_10                                   -- precedence_10
                        ,    p_creation_date                            -- creation_date
                        ,    p_created_by                               -- created_by
                        ,    p_last_update_date                         -- last_update_date
                        ,    p_last_updated_by                          -- last_updated_by
                        ,    p_last_update_login                        -- last_update_login
             );
            END IF; --(p_source_trx_type = jai_constants.G_AP_STANDALONE_INVOICE )
       /*      jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Record inserted into jai_cmn_document_taxes');*/ --commented by bgowrava for bug#5631784

      /* Date 22-feb-2007  Added by SACSETHI for bug 6012570 (5876390)
         in This , Recalculation will be happen in Draft invoice    */
      elsif
            p_source_trx_type = jai_constants.pa_draft_invoice
        and p_action = jai_constants.recalculate_taxes
      then

           update   jai_cmn_document_taxes
           set      tax_amt        = tax_amt_tab(row_count)
                   ,func_tax_amt   = nvl(func_tax_amt_tab(row_count),0) * nvl(v_currency_conv_factor ,1)
                   ,last_update_date  = p_last_update_date
                   ,last_updated_by   = p_last_updated_by
                   ,last_update_login = p_last_update_login
           where   source_doc_line_id = p_line_id
           and     tax_id             = rec.tax_id
           and     source_doc_type    = jai_constants.pa_draft_invoice;

      elsif p_source_trx_type = jai_constants.source_ttype_delivery
      then

    /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                ,'Value of variables used for updating ja_in_so_picking_tax_lines'||chr(10)
                                ||'tax_amount        = '|| tax_amt_tab(row_count)                                     ||chr(10)
                                ||'func_tax_amount   = '||nvl(func_tax_amt_tab(row_count),0) * v_currency_conv_factor ||chr(10)
                                ||'base_tax_amount   = '||round( nvl(tax_amt_tab(row_count),0), rec.rounding_factor)  ||chr(10)
                                ||'tax_id            = '||rec.tax_id
                                );   */ --commented by bgowrava for bug#5631784

        if  p_action = jai_constants.recalculate_taxes then
--Used base_tax_amt_tab instead of tax_amt_tab to update column base_tax_amount for bug#8905076 by JMEENA
            update   JAI_OM_WSH_LINE_TAXES
            set      tax_amount        = tax_amt_tab(row_count)
                    ,func_tax_amount   = nvl(func_tax_amt_tab(row_count),0) * nvl(v_currency_conv_factor ,1)
                    ,base_tax_amount   = round( nvl(base_tax_amt_tab(row_count),0), rec.rounding_factor)
                    ,last_update_date  = p_last_update_date
                    ,last_updated_by   = p_last_updated_by
                    ,last_update_login = p_last_update_login
            where   delivery_detail_id = p_line_id
            and     tax_id             = rec.tax_id;

        end if;

      elsif p_source_trx_type = jai_constants.bill_only_invoice then

            /*
            || When currency conversion rate is null it means the transaction is in the INR only
            */
            if v_currency_conv_factor is null then
              v_currency_conv_factor := 1;
            end if;

      /*     jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                  ,'Value of variables used for updating JA_IN_RA_CUST_TRX_TAX_LINES'||chr(10)
                                  ||'tax_amount        = '|| tax_amt_tab(row_count)                                     ||chr(10)
                                  ||'func_tax_amount   = '||nvl(func_tax_amt_tab(row_count),0) * v_currency_conv_factor ||chr(10)
                                  ||'base_tax_amount   = '||round( nvl(tax_amt_tab(row_count),0), rec.rounding_factor)  ||chr(10)
                                  ||'tax_id            = '||rec.tax_id
                                  );   */ --commented by bgowrava for bug#5631784

           if  p_action = jai_constants.recalculate_taxes then

                update   JAI_AR_TRX_TAX_LINES
                set      tax_amount              = tax_amt_tab(row_count)
                        ,func_tax_amount         = nvl(func_tax_amt_tab(row_count),0) * nvl(v_currency_conv_factor ,1)
                        ,base_tax_amount         = round( nvl(tax_amt_tab(row_count),0), rec.rounding_factor)
                        ,last_update_date        = p_last_update_date
                        ,last_updated_by         = p_last_updated_by
                        ,last_update_login       = p_last_update_login
                where   link_to_cust_trx_line_id = p_line_id
                and     tax_id                   = rec.tax_id;

            end if;

      /** End Bug 5631784 */



        END IF;     -- p_transaction_type
        row_count := row_count + 1;

    END LOOP;

    -- Start, cbabu for EnhancementBug# 2427465
    IF SUBSTR( transaction_name, 1, 3 ) = 'RFQ'       OR
        SUBSTR( transaction_name, 1, 9 ) = 'QUOTATION' OR
        SUBSTR( transaction_name, 1, 7 ) = 'BLANKET'   OR
        SUBSTR( transaction_name, 1, 8 ) = 'BLANKETR'  OR
        SUBSTR( transaction_name, 1, 6 ) = 'OTHERS'    OR
        SUBSTR( transaction_name, 1, 9 ) = 'SCHEDULED'
    THEN

        BEGIN
            UPDATE JAI_PO_LINE_LOCATIONS
            SET tax_category_id = p_tax_category_id
            WHERE line_focus_id = v_line_focus_id_holder;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR( -20101, '1 Exception raised in jai_cmn_tax_defaultation_pkg:JIPLL '||SQLERRM, TRUE);
        END;

    ELSIF transaction_name = 'PO_REQN' THEN

        BEGIN
            UPDATE JAI_PO_REQ_LINES
            SET tax_category_id = p_tax_category_id
            WHERE requisition_line_id = p_line_id;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR( -20101, '2 Exception raised in jai_cmn_tax_defaultation_pkg:JIRL '||SQLERRM, TRUE);
        END;


    /* End, cbabu for EnhancementBug# 2427465 */

    END IF;

    p_tax_amount := nvl(v_tax_amt,0);

 /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;


END ja_in_calc_prec_taxes;

/* Added by bgowrava for Forward porting bug#5631784 */

/*------------------------------------------------------------------------------------------------------------*/
  procedure get_tax_cat_taxes_cur (p_tax_category_id        number
                                  ,p_threshold_tax_cat_id   number default null
                                  ,p_max_tax_line           number default 0
                                  ,p_max_rgm_tax_line       number default 0
                                  ,p_base                   number default 0
                                  ,p_refc_tax_cat_taxes_cur out nocopy  ref_cur_typ
                                  , pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price 2008/01/13
                                  )
/***************************************************************************************************************
||Purpose :-
||   1.  Whenever p_threshold_tax_cat_id is not NULL then it means taxes from two categories needs to be merged.
||       one using p_tax_category_id and other is p_threshold_tax_cat_id
||   2. current driving cursor (tax_cur) is modified to handle multiple tax categories.
||       2.1  For all the tax lines defined in the p_tax_category_id there is no change
||       2.2  For all the tax lines defined in the p_threshold_tax_cat_id, line_no will be changed
||            to p_max_tax_line + line_no where p_max_tax_line is the maximum  of line numbers for
||            tax lines defined in p_tax_category_id
||       2.3  All the precedences defined in p_threshold_tax_cat_id will be changed as following
||            -  If precedence refers to base precedence (i.e. 0) it will be changed to p_max_rgm_tax_line
||               where p_max_rgm_tax_line is maximum of the line numbers of taxes having
||               tax_type = p_thhold_cat_base_tax_typ (i.e. tax type to be considered as a base tax
||               when calculating threshold taxes defined using p_threshold_tax_cat_id)
||            -  All other precedences will be changed to precedence_N + p_max_tax_line
***************************************************************************************************************/

  is
   ref_tax_cur  ref_cur_typ;
  begin
    /*
    ||
    */

    --Added by Kevin Cheng for Retroactive Price 2008/01/13
    --=====================================================
    IF pv_retroprice_changed = 'N'
    THEN
    --=====================================================
    open ref_tax_cur
                       for     select a.tax_id
                             , decode (a.tax_category_id, p_tax_category_id, a.line_no
                                                        , (p_max_tax_line + a.line_no)
                                      )       lno
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_1
                                                        , decode (a.precedence_1, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_1))
                                      )       p_1
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_2
                                                        , decode (a.precedence_2, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_2))
                                      )       p_2
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_3
                                                        , decode (a.precedence_3, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_3))
                                      )       p_3
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_4
                                                        , decode (a.precedence_4, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_4))
                                      )       p_4
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_5
                                                        , decode (a.precedence_5, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_5))
                                      )       p_5
                            /* Bug 5094130. Added by Lakshmi Gopalsami Included precedences 6 to 10*/
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_6
                                                        , decode (a.precedence_6, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_6))
                                      )       p_6
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_7
                                                        , decode (a.precedence_7, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_7))
                                      )       p_7
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_8
                                                        , decode (a.precedence_8, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_8))
                                      )       p_8
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_9
                                                        , decode (a.precedence_9, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_9))
                                      )       p_9
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_10
                                                        , decode (a.precedence_10, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_10))
                                      )       p_10
                             , b.tax_rate
                             , b.tax_amount
                             , b.uom_code
                             , b.end_date valid_date
                             , DECODE(rgm_tax_types.regime_Code,jai_constants.vat_regime, 4,  /* added by ssumaith - bug# 4245053*/
                                   DECODE(UPPER(b.tax_type),
                                          'EXCISE',                 1,
                                          'ADDL. EXCISE',           1,
                                          'OTHER EXCISE',           1,
                                          'TDS',                    2,
                                          'EXCISE_EDUCATION_CESS'  ,6, --modified by walton for inclusive tax
                   JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS , 6 , /*bduvarag for the bug#5989740*/ --modified by walton for inclusive tax
                                          'CVD_EDUCATION_CESS'     ,6, --modified by walton for inclusive tax
                    JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS, 6 ,  /*bduvarag for the bug#5989740*/--modified by walton for inclusive tax
                                          0
                                         )
                                      ) tax_type_val
                             , b.mod_cr_percentage
                             , b.vendor_id
                             , b.tax_type
                             , nvl(b.rounding_factor,0) rounding_factor
                             , b.adhoc_flag
                             , a.tax_category_id
           , b.inclusive_tax_flag  --added by walton for inclusive tax on 08-Dev-07
                        from JAI_CMN_TAX_CTG_LINES a
                           , JAI_CMN_TAXES_ALL b
                           , jai_regime_tax_types_v rgm_tax_types   /* added by ssumaith - bug# 4245053*/
                        where a.tax_category_id in (p_tax_category_id, nvl(p_threshold_tax_cat_id,-1))
                        and   rgm_tax_types.tax_type (+) = b.tax_type /* added by ssumaith - bug# 4245053*/
                        and   a.tax_id = b.tax_id
                        order by   decode (a.tax_category_id, p_tax_category_id, a.line_no
                                                        , (p_max_tax_line + a.line_no)
                                          );
  --Added by Kevin Cheng for Retroactive Price 2008/01/13
  --=====================================================
  ELSIF pv_retroprice_changed = 'Y'
  THEN
  open ref_tax_cur
                       for     select a.tax_id
                             , decode (a.tax_category_id, p_tax_category_id, a.line_no
                                                        , (p_max_tax_line + a.line_no)
                                      )       lno
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_1
                                                        , decode (a.precedence_1, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_1))
                                      )       p_1
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_2
                                                        , decode (a.precedence_2, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_2))
                                      )       p_2
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_3
                                                        , decode (a.precedence_3, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_3))
                                      )       p_3
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_4
                                                        , decode (a.precedence_4, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_4))
                                      )       p_4
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_5
                                                        , decode (a.precedence_5, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_5))
                                      )       p_5
                            /* Bug 5094130. Added by Lakshmi Gopalsami Included precedences 6 to 10*/
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_6
                                                        , decode (a.precedence_6, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_6))
                                      )       p_6
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_7
                                                        , decode (a.precedence_7, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_7))
                                      )       p_7
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_8
                                                        , decode (a.precedence_8, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_8))
                                      )       p_8
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_9
                                                        , decode (a.precedence_9, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_9))
                                      )       p_9
                             , decode (a.tax_category_id, p_tax_category_id, a.precedence_10
                                                        , decode (a.precedence_10, p_base,  p_max_rgm_tax_line,  (p_max_tax_line + a.precedence_10))
                                      )       p_10
                             , b.tax_rate
                             , b.tax_amount
                             , b.uom_code
                             , b.end_date valid_date
                             , DECODE(rgm_tax_types.regime_Code,jai_constants.vat_regime, 4,  /* added by ssumaith - bug# 4245053*/
                                   DECODE(UPPER(b.tax_type),
                                          'EXCISE',                 1,
                                          'ADDL. EXCISE',           1,
                                          'OTHER EXCISE',           1,
                                          'TDS',                    2,
                                          'EXCISE_EDUCATION_CESS'  ,1,
                   JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS , 1 , /*bduvarag for the bug#5989740*/
                                          'CVD_EDUCATION_CESS'     ,1,
                    JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS, 1 ,  /*bduvarag for the bug#5989740*/
                                          0
                                         )
                                      ) tax_type_val
                             , b.mod_cr_percentage
                             , b.vendor_id
                             , b.tax_type
                             , nvl(b.rounding_factor,0) rounding_factor
                             , b.adhoc_flag
                             , a.tax_category_id
                             , b.inclusive_tax_flag  --Add by Kevin Cheng
                        from JAI_CMN_TAX_CTG_LINES a
                           , JAI_CMN_TAXES_ALL b
                           , jai_regime_tax_types_v rgm_tax_types   /* added by ssumaith - bug# 4245053*/
                        where a.tax_category_id in (p_tax_category_id, nvl(p_threshold_tax_cat_id,-1))
                        and   rgm_tax_types.tax_type (+) = b.tax_type /* added by ssumaith - bug# 4245053*/
                        and   a.tax_id = b.tax_id
                        order by   decode (a.tax_category_id, p_tax_category_id, a.line_no
                                                        , (p_max_tax_line + a.line_no)
                                          );
  END IF;
  --=====================================================
  p_refc_tax_cat_taxes_cur := ref_tax_cur;
  end get_tax_cat_taxes_cur;
/* end of bug#5631784 */

END jai_cmn_tax_defaultation_pkg;

/
