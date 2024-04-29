--------------------------------------------------------
--  DDL for Package Body JAI_OM_WSH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_OM_WSH_PKG" AS
/* $Header: jai_om_wsh.plb 120.11.12010000.7 2009/11/10 10:28:26 vkaranam ship $ */


PROCEDURE process_delivery
(
  errbuf         OUT NOCOPY VARCHAR2 ,
  retcode        OUT NOCOPY VARCHAR2 ,
  p_delivery_id  IN         NUMBER
)
IS
 /*
 || This procedure is used to Create the Excise Invoice No for each delivery_id,
 || Post the entries into the excise register tables, bond regsiter table
 */
        lv_debug                        CHAR(1); -- := 'Y' ; --Ramananda for File.Sql.35
        lv_block_no                     CHAR(3)                                                 ;
        lv_statement_no                 CHAR(3)                                                 ;
        lv_error_mesg                   VARCHAR2(255)                                           ;
        lv_procedure_name               VARCHAR2(25); -- := 'process_delivery'; --Ramananda for File.Sql.35

--Anuradha Parthasarathy
        v_initial_pickup_date            DATE                                                   ;
        v_actual_shipment_date           DATE                                                   ;
        v_date                           DATE                                                   ;

--Anuradha Parthasarathy
        v_inventory_item_id             NUMBER                                                  ;
        v_order_line_id                 NUMBER                                                  ;
        v_location_id                   NUMBER                                                  ;
        v_register                      JAI_OM_WSH_LINES_ALL.REGISTER%TYPE                    ;
        v_uom_code                      JAI_OM_WSH_LINES_ALL.UNIT_CODE%TYPE                   ;
        v_shp_qty                       NUMBER                                                  ;
        v_item_class                    JAI_INV_ITM_SETUPS.ITEM_CLASS%TYPE                  ;
        v_excise_flag                   VARCHAR2(1)                                             ;
        v_basic_ed_amt                  NUMBER                                                  ;
        v_addl_ed_amt                   NUMBER                                                  ;
        v_oth_ed_amt                    NUMBER                                                  ;
        v_excise_exempt_type            JAI_OM_WSH_LINES_ALL.EXCISE_EXEMPT_TYPE%TYPE          ;
        v_selling_price                 NUMBER                                                  ;
        v_set_of_books_id               NUMBER                                                  ;
        v_currency_code                 OE_ORDER_HEADERS_ALL.TRANSACTIONAL_CURR_CODE%TYPE       ;
        v_conv_type_code                OE_ORDER_HEADERS_ALL.CONVERSION_TYPE_CODE%TYPE          ;
        v_conv_rate                     NUMBER                                                  ;
        v_conv_date                     DATE                                                    ;
        v_customer_id                   NUMBER                                                  ;
        v_ship_to_org_id                NUMBER                                                  ;
        v_receipt_id                    NUMBER                                                  ;
        v_creation_date                 DATE; --   := SYSDATE; --Ramananda for File.Sql.35
        v_created_by                    NUMBER                                                  ;
        v_last_update_date              DATE                                                    ;
        v_last_updated_by               NUMBER                                                  ;
        v_last_update_login             NUMBER                                                  ;
        v_order_type_id                 NUMBER                                                  ;
        v_subinventory                  WSH_DELIVERY_DETAILS.SUBINVENTORY%TYPE                  ;
        v_bonded_flag                   VARCHAR2(1)                                             ;
        v_trading_flag                  VARCHAR2(1)                                             ;
        v_pref_rg23a                    NUMBER                                                  ;
        v_pref_rg23c                    NUMBER                                                  ;
        v_pref_pla                      NUMBER                                                  ;
        v_ssi_unit_flag                 VARCHAR2(1)                                             ;
        v_register_code                 VARCHAR2(30)                                            ;
        v_Trad_register_code            VARCHAR2(30)                                            ;
        v_reg_type                      VARCHAR2(10)                                            ;
        v_modvat_tax_rate               NUMBER                                                  ;
        v_rounding_factor               NUMBER                                                  ;
        v_assessable_value              NUMBER                                                  ;
        v_exempt_bal                    NUMBER                                                  ;
        v_bond_tax_amount               NUMBER                                                  ;
        v_register_balance              NUMBER                                                  ;
        v_order_number                  NUMBER                                                  ;
        v_meaning                       VARCHAR2(80)                                            ;
        v_fin_year                      NUMBER                                                  ;
        v_transaction_type_code         OE_TRANSACTION_TYPES_ALL.TRANSACTION_TYPE_CODE%TYPE     ;
        v_start_number                  NUMBER                                                  ;
        v_end_number                    NUMBER                                                  ;
        v_jump_by                       NUMBER                                                  ;
        v_prefix                        VARCHAR2(50)                                            ;
        V_EXC_INVOICE_NO                JAI_OM_WSH_LINES_ALL.EXCISE_INVOICE_NO%TYPE           ;
        v_excise_check                  NUMBER := 0                                             ; --added by Vijay on 2002/02/07
        v_gp_1                          NUMBER                                                  ;
        v_gp_2                          NUMBER                                                  ;
        v_tax_rate                      NUMBER                                                  ;
        v_qty_reg_type                  VARCHAR2(1)                                             ;
        v_part_i_register_id            NUMBER                                                  ;
        v_source_name                   VARCHAR2(100); -- := 'Register India'                ; --Ramananda for File.Sql.35
        v_category_name                 VARCHAR2(100); -- := 'Register India'              ; --Ramananda for File.Sql.35
        v_remarks                       VARCHAR2(60)                                            ;
        v_rg23_part_i_no                NUMBER                                                  ;
        v_rg23_part_ii_no               NUMBER                                                  ;
        v_pla_register_no               NUMBER                                                  ;
        v_converted_rate                NUMBER                                                  ;
        v_organization_id               NUMBER                                                  ;
        v_rg23a_balance                 NUMBER                                                  ;
        v_rg23c_balance                 NUMBER                                                  ;
        v_excise_amount                 NUMBER                                                  ;
        v_pla_balance                   NUMBER                                                  ;
        v_raise_error_flag              VARCHAR2(1)                                             ;
        v_raise_exempt_flag             VARCHAR2(1)                                             ;
        v_rg_type                       VARCHAR2(1)                                             ;
        v_line_id                       NUMBER                                                  ;
        v_header_no                     NUMBER                                                  ;
        v_quantity_applied              NUMBER                                                  ;
        V_item_trading_flag             VARCHAR2(1)                                             ;
        v_register_id                   NUMBER                                                  ;
        V_QTY_TO_ADJUST                 NUMBER := 0                                             ;
        v_invoice_to_site_use_id        NUMBER                                                  ;
        V_SHIP_TO_SITE_USE_ID           NUMBER                                                  ;
        V_EXCISE_DUTY_RATE              NUMBER                                                  ;
        V_RATE_PER_UNIT                 NUMBER                                                  ;
        V_DUTY_AMOUNT                   NUMBER                                                  ;

        -- Start, cbabu for Bug# 2736191
        v_proportionate_rpu             NUMBER;         -- should contain proportionate Rate Per Unit if detail is matched to multiple receipts
        v_proportionate_edr             NUMBER;         -- should contain proportionate excise duty rate if detail is matched to multiple receipts
        v_total_quantity_applied        NUMBER;         -- should contain the total quantity applied on multiple receipts for the same detail
        v_total_base_duty_amount        NUMBER;         -- should contain the total base duty amount on which the rate per unit is calculated for this detail
        v_total_rate                    NUMBER;         -- should contain accumilated value of rate_per_unit * quantity_applied for all the receipts in which the detail is applied
        -- End, cbabu for Bug# 2736191
 /*Added by nprashar for bug # 5735284 added for bug#6199766 ,start*/
	v_qnty_received                                                   NUMBER;
	v_tot_duty_amt			NUMBER;
	v_tot_cvd_amt			NUMBER;
	v_tot_addl_cvd_amt		NUMBER;
        /*added for bug#6199766 ,end*/

        v_source_header_id              NUMBER                                                  ;
        v_source_line_id                NUMBER                                                  ;
        v_excise_exempt_refno           VARCHAR2(30)                                            ;
        v_old_delivery_id               NUMBER                                                  ;
        v_tot_excise_amt                NUMBER                                                  ;
        v_tot_basic_ed_amt              NUMBER                                                  ;
        v_tot_addl_ed_amt               NUMBER                                                  ;
        v_tot_oth_ed_amt                NUMBER                                                  ;
        v_old_register                  JAI_OM_WSH_LINES_ALL.REGISTER%TYPE                    ;
        v_old_excise_invoice_no         VARCHAR2(200)                                           ;
        v_status_code                   WSH_NEW_DELIVERIES.STATUS_CODE%TYPE                     ;
        v_org_id                        NUMBER                                                  ; --2001/04/01 Vijay
        v_source_line_id_pick           NUMBER                                                  ;
        v_no_records_fetched            NUMBER := 0                                             ;            --28/05/02 cbabu for debug
        v_trans_type_up                 VARCHAR2(3)                                             ;
        v_order_invoice_type_up         VARCHAR2(25)                                            ;---ashish 10june
    v_register_code_up                  VARCHAR2(25)                                            ;---ashish 10june

    --New Variables Declared by Nagaraj.s for Enh2415656
        v_output                        NUMBER                                                  ;-- By Nagaraj.s to get the output of the function ja_in_exc_balance_amt
        v_export_oriented_unit          JAI_CMN_INVENTORY_ORGS.EXPORT_ORIENTED_UNIT%TYPE   ;
        v_basic_pla_balance             NUMBER                                                  ;
        v_additional_pla_balance        NUMBER                                                  ;
        v_other_pla_balance             NUMBER                                                  ;
        v_myfilehandle                  UTL_FILE.FILE_TYPE                                      ; -- This is for File handling
        v_utl_location                  VARCHAR2(512)                                           ;
        v_ret_stat                      BOOLEAN                                                 ; -- 2663211 -- for raising error
        --Ends here for Enh2415656

        v_asst_register_id              NUMBER                                                  ; -- bug # 3021588
        v_register_exp_date             JAI_OM_OE_BOND_REG_HDRS.BOND_EXPIRY_DATE%TYPE                ; -- bug # 3021588
        v_lou_flag                      JAI_OM_OE_BOND_REG_HDRS.LOU_FLAG%TYPE                        ; -- bug # 3021588

-- Cursor to fetch required values for corresponding Delivery_detail_id in
        CURSOR Get_delivery_detail_cur(p_delivery_detail_id NUMBER) IS
                SELECT  A.order_line_id, A.organization_id, A.location_id, A.register,
                        A.inventory_item_id, A.unit_code uom_code, A.quantity,
                        b.item_class, b.excise_flag ,A.basic_excise_duty_amount,
                        A.add_excise_duty_amount, A.oth_excise_duty_amount, A.excise_amount,
                        A.excise_exempt_type, A.selling_price, A.customer_id, A.ship_to_org_id,
                        A.order_type_id, A.subinventory, A.assessable_value,
                        A.EXCISE_EXEMPT_REFNO, A.org_id  -- added a.org_id by vijay for multi org support
                FROM    JAI_OM_WSH_LINES_ALL           A,
                        JAI_INV_ITM_SETUPS           B
                WHERE   A.delivery_detail_id  = p_delivery_detail_id
                AND     A.organization_id     = b.organization_id
                AND     A.inventory_item_id   = b.inventory_item_id
                ORDER   BY b.item_class;

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed the cursor set_of_books_cur and implemented using caching logic.
     */

        /*
        || Code changed by aiyer for the bug #3090371.
        || Modified the cursor to get the actual_shipment_date from oe_order_lines_all instead of the
        || conversion_date from oe_order_headers_all.
        || As a Sales order shipment date can be different from its creation date, hence the conversion rate
        || applicable on the date of shipment should be considerd for all processing rather than the creation
        || date of the Sales order.
        */

        CURSOR get_conv_detail_cur(
                                    cp_order_header_id OE_ORDER_HEADERS_ALL.HEADER_ID%TYPE ,
                                    cp_line_id         OE_ORDER_LINES_ALL.LINE_ID%TYPE
                                  ) IS
                SELECT
                        order_number                                            ,
                        transactional_curr_code                                 ,
                        conversion_type_code                                    ,
                        conversion_rate                                         ,
                        b.actual_shipment_date
                FROM
                        oe_order_headers_all a  ,
                        oe_order_lines_all   b
                WHERE
                        a.header_id = b.header_id       AND
                        b.line_id   = cp_line_id        AND
                        a.header_id = cp_order_header_id ;

        CURSOR bonded_cur(p_organization_id NUMBER, p_subinventory VARCHAR2) IS
                SELECT NVL(A.bonded,'Y') bonded,NVL(A.trading,'Y') trading
                FROM   JAI_INV_SUBINV_DTLS A
                WHERE  A.sub_inventory_name = p_subinventory
                AND    A.organization_id = p_organization_id;

        CURSOR pref_cur(p_organization_id NUMBER, p_location_id NUMBER)IS
        --This is included in the select by Nagaraj.s for Enh2415656
                SELECT pref_rg23a, pref_rg23c, pref_pla,
                NVL(Export_oriented_unit ,'N')
                FROM JAI_CMN_INVENTORY_ORGS
                WHERE organization_id = p_organization_id
                AND location_id = p_location_id ;

    --This is included in the select by Nagaraj.s for Enh2415656
        CURSOR rg_bal_cur(p_organization_id NUMBER, p_location_id NUMBER)IS
                SELECT NVL(rg23a_balance,0) rg23a_balance ,NVL(rg23c_balance,0) rg23c_balance,NVL(pla_balance,0) pla_balance,
                NVL(basic_pla_balance,0) basic_pla_balance,
                NVL(additional_pla_balance,0) additional_pla_balance,
                NVL(other_pla_balance,0) other_pla_balance
                FROM JAI_CMN_RG_BALANCES
                WHERE organization_id = p_organization_id
                AND location_id = p_location_id ;

        CURSOR ssi_unit_flag_cur(p_organization_id IN  NUMBER, p_location_id IN NUMBER) IS
                SELECT ssi_unit_flag
                FROM   JAI_CMN_INVENTORY_ORGS
                WHERE  organization_id = p_organization_id AND
                       location_id     = p_location_id;

        CURSOR register_code_cur(p_organization_id NUMBER, p_location_id NUMBER, p_delivery_detail_id NUMBER, p_order_type_id NUMBER) IS
                SELECT A.register_code
                FROM JAI_OM_OE_BOND_REG_HDRS A, JAI_OM_OE_BOND_REG_DTLS b
                WHERE A.organization_id = p_organization_id
                AND A.location_id = p_location_id
                AND A.register_id = b.register_id
                AND b.order_flag         = 'Y'
                AND b.order_type_id = p_order_type_id ;

        CURSOR for_modvat_tax_rate(p_delivery_detail_id NUMBER) IS
                SELECT A.tax_rate, b.rounding_factor
                FROM   JAI_OM_WSH_LINE_TAXES A, JAI_CMN_TAXES_ALL b
                WHERE  A.tax_id = b.tax_id
                AND    A.delivery_detail_id = p_delivery_detail_id
                AND    b.tax_type =   jai_constants.tax_type_modvat_recovery ; /* --'Modvat Recovery'; Ramananda for removal of SQL LITERALs */

        CURSOR for_modvat_percentage(p_organization_id NUMBER, p_location_id NUMBER) IS
                SELECT MODVAT_REVERSE_PERCENT
                FROM   JAI_CMN_INVENTORY_ORGS
                WHERE  organization_id = p_organization_id
                AND (location_id = p_location_id
                OR
               (location_id is NULL AND  p_location_id  is NULL)); /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
                      --AND NVL(location_id,0) = NVL(p_location_id,0);

        CURSOR  register_balance_cur(p_organization_id IN  NUMBER, p_location_id IN NUMBER) IS
                SELECT  register_balance
                FROM  JAI_OM_OE_BOND_TRXS
                WHERE  transaction_id = (SELECT MAX(A.transaction_id)
                        FROM   JAI_OM_OE_BOND_TRXS A, JAI_OM_OE_BOND_REG_HDRS B
                        WHERE  A.register_id = B.register_id
                        AND    B.organization_id = p_organization_id
                        AND B.location_id = p_location_id);

        CURSOR Register_Code_Meaning_Cur(p_register_code IN VARCHAR2, lv_lookup_type ja_lookups.lookup_type%type) IS
                SELECT meaning
                FROM   ja_lookups
                WHERE  lookup_code = p_register_code
                AND    lookup_type = lv_lookup_type ; /*'JAI_REGISTER_TYPE'; Ramananda for removal of SQL LITERALs */

        CURSOR fin_year_cur(p_organization_id IN NUMBER) IS
                SELECT MAX(A.fin_year)
                FROM   JAI_CMN_FIN_YEARS A
                WHERE  organization_id = p_organization_id
                AND fin_active_flag = 'Y';

        CURSOR Get_transaction_type(p_order_type_id NUMBER) IS
                SELECT name
                FROM oe_transaction_types_tl
                WHERE transaction_type_id = p_order_type_id;

        CURSOR Def_Excise_Invoice_Cur(p_organization_id IN NUMBER, p_location_id IN NUMBER, p_fin_year IN NUMBER,
                        p_batch_name IN VARCHAR2, p_register_code IN VARCHAR2) IS
                SELECT start_number, end_number, jump_by, prefix
                FROM   JAI_CMN_RG_EXC_INV_NOS
                WHERE  organization_id               = p_organization_id
                AND    location_id                   = p_location_id
                AND    fin_year                      = p_fin_year
                AND    order_invoice_type = p_batch_name
                AND    register_code      = p_register_code; /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
                --AND    NVL(order_invoice_type,'###') = p_batch_name
                --AND    NVL(register_code,'###')      = NVL(p_register_code,'***');

        CURSOR excise_invoice_cur(p_organization_id IN NUMBER, p_location_id IN NUMBER, p_fin_year IN NUMBER)  IS
                SELECT NVL(MAX(GP1),0),NVL(MAX(GP2),0)
                FROM   JAI_CMN_RG_EXC_INV_NOS
                WHERE  organization_id = p_organization_id
                AND        location_id     = p_location_id
                AND    fin_year        = p_fin_year
                AND    order_invoice_type IS NULL
                AND    register_code IS NULL;

        CURSOR ec_code_cur(p_organization_id IN NUMBER, p_location_id IN NUMBER) IS
                SELECT A.Organization_Id, A.Location_Id
                FROM   JAI_CMN_INVENTORY_ORGS A
                WHERE  A.Ec_Code IN (SELECT B.Ec_Code
                        FROM   JAI_CMN_INVENTORY_ORGS B
                        WHERE  B.Organization_Id = p_organization_id
                        AND    B.Location_Id     = p_location_id);

--Anuradha Parthasarathy 2001/05/26
        CURSOR Tr_ec_code_cur(p_organization_id IN NUMBER, p_location_id IN NUMBER) IS
                SELECT A.Organization_Id, A.Location_Id
                FROM   JAI_CMN_INVENTORY_ORGS A
                WHERE  A.Tr_Ec_Code IN (SELECT B.Tr_Ec_Code
                   FROM   JAI_CMN_INVENTORY_ORGS B
                   WHERE  B.Organization_Id = p_organization_id
                   AND    B.Location_Id     = p_location_id);

-- Related Cursors added by Arun for Trading on 28 oct 2000 at 3:30
        CURSOR Trading_register_code_cur(p_organization_id NUMBER, p_location_id NUMBER,
                        p_delivery_detail_id NUMBER, p_order_type_id NUMBER) IS
                SELECT A.register_code
                FROM JAI_OM_OE_BOND_REG_HDRS A, JAI_OM_OE_BOND_REG_DTLS b
                WHERE A.organization_id = p_organization_id
                AND A.location_id = p_location_id
                AND A.register_id = b.register_id
                AND b.order_flag         = 'Y'
                AND b.order_type_id = p_order_type_id
                AND A.REGISTER_CODE LIKE '23D%';

        CURSOR matched_receipt_cur1(p_reference_line_id  IN NUMBER) IS
                SELECT SUM(A.quantity_applied) quantity_applied, A.subinventory
                FROM   JAI_CMN_MATCH_RECEIPTS A
                WHERE  A.ref_line_id = p_reference_line_id
                AND ORDER_INVOICE = 'O';                -- cbabu for Bug# 2736191
                -- GROUP BY A.subinventory;             -- cbabu for Bug# 2736191

        CURSOR shipped_qty_cur (p_picking_line_id IN NUMBER) IS
                SELECT SUM(quantity) shipped_quantity
                FROM   JAI_OM_WSH_LINES_ALL
                WHERE delivery_detail_id = p_picking_line_id;

        CURSOR Header_id (p_picking_line_id IN NUMBER) IS
                SELECT source_line_id, source_header_id
                FROM wsh_delivery_details
                WHERE delivery_detail_id = p_picking_line_id;

        CURSOR matched_receipt_cur(p_reference_line_id  IN NUMBER) IS
                SELECT A.receipt_id, A.quantity_applied
                FROM   JAI_CMN_MATCH_RECEIPTS A
                WHERE  A.ref_line_id = p_reference_line_id
                AND ORDER_INVOICE = 'O'         -- cbabu for Bug# 2736191
                AND A.quantity_applied > 0;

        CURSOR  ship_bill_cur (p_order_header_id NUMBER) IS
                SELECT  INVOICE_TO_ORG_ID,SHIP_TO_ORG_ID
                FROM    oe_order_headers_all
                WHERE   header_id = p_order_header_id;

        CURSOR qty_to_adjust_cur (p_receipt_id NUMBER) IS
                SELECT qty_to_adjust,excise_duty_rate,rate_per_unit , quantity_received  --added quantity_received for bug#5735284
                FROM   JAI_CMN_RG_23D_TRXS
                WHERE  register_id = p_receipt_id;

 /*added the following cursor for bug#5735284*/
      CURSOR get_duty_amt_cur (p_receipt_id NUMBER) IS
		SELECT duty_amount,basic_ed, additional_ed,other_ed, cvd,additional_cvd
		FROM   JAI_CMN_RG_23D_TRXS
		WHERE  register_id = p_receipt_id;
      rec_get_duty_amt get_duty_amt_cur%rowtype;
-- Till Here
          /*
          || Changed by aiyer for the bug 3139718
          || As in this procedure the values of basic_excise_duty_amount ,add_excise_duty_amount,oth_excise_duty_amount
          || and excise_amount should always be in INR currency hence converting the same and rounding it here instead
          || of doing it at a later point.
          */

           -- Start of bug #3448674
          /*
          || Code modified by Aiyer for the  3448674.
          || changed the cursor get_total_excise_amt to do rounding at a paticualr delivery level rather
          || than the line level.
          || For this , we are first summing the taxes and then rounding  them
          */
          CURSOR get_total_excise_amt(
                                     p_delivery_id      NUMBER ,
                                     cp_conversion_rate NUMBER
                                    ) IS
                SELECT
                        nvl(round(sum(basic_excise_duty_amount * cp_conversion_rate)),0)       ,
                        nvl(round(sum(add_excise_duty_amount   * cp_conversion_rate)),0)       ,
                        nvl(round(sum(oth_excise_duty_amount   * cp_conversion_rate)),0)       ,
                        nvl(round(sum(excise_amount            * cp_conversion_rate)),0)
                FROM
                        JAI_OM_WSH_LINES_ALL
                WHERE
                        delivery_id = p_delivery_id
                        and excise_exempt_type is null; -- sriram - 5th nov - bug # 3207685
            -- End of bug #3448674

          -- following cursor added by sriram - bug # 3207685
          cursor c_get_modvat_records (p_delivery_id      NUMBER) IS
          select delivery_detail_id , quantity , assessable_Value , excise_exempt_type
          from   JAI_OM_WSH_LINES_ALL
          where  delivery_id = p_delivery_id
          and excise_exempt_type is not null;

          v_mod_basic_ed_amt number:=0;

          CURSOR get_prev_del_dtl(p_delivery_id NUMBER) IS
                SELECT register, EXCISE_INVOICE_NO
                FROM JAI_OM_WSH_LINES_ALL
                WHERE delivery_id = p_delivery_id
                AND register IS NOT NULL;

--Anuradha Parthasarathy
        CURSOR get_delivery_status(p_delivery_id NUMBER) IS
                SELECT status_code,initial_pickup_date
                FROM Wsh_New_deliveries
                WHERE delivery_id = p_delivery_id;
        ----------------------------------------------
--Cursor added by Jagdish on 2001/09/13
        CURSOR get_order_line_id(p_delivery_detail_id NUMBER) IS
                SELECT SOURCE_LINE_ID FROM wsh_delivery_details
                WHERE delivery_detail_id = p_delivery_detail_id;
--Anuradha Parthasarathy

        CURSOR get_actual_shipment_date(p_order_line_id NUMBER) IS
                SELECT actual_shipment_date
                FROM     Oe_Order_Lines_All
                WHERE    line_id = p_order_line_id;

-- added by sriram Bug # 2454978
        v_line_amount NUMBER;
        v_tax_amt  NUMBER;


        -- added by sriram -- bug # 2769440

         /* Ramananda for File.Sql.35 */
        v_ref_10  gl_interface.reference10%type; -- := 'India Localization Entry for sales order # '; -- will hold a standard text such as 'India Localization Entry for sales order'
        v_std_text varchar2(50);                 -- := 'India Localization Entry for sales order # '; -- bug # 3158976
        v_ref_23  gl_interface.reference23%type; -- := 'process_delivery'; -- holds the object name -- 'process_delivery'
        v_ref_24  gl_interface.reference24%type; -- := 'wsh_new_deliveries'; -- holds the table name  -- ' wsh_new_deliveries'
        v_ref_25  gl_interface.reference25%type; -- := 'delivery_id'; -- holds the column name -- 'delivery_id'
        /* Ramananda for File.Sql.35 */

        v_ref_26  gl_interface.reference26%type ; -- holds the column value -- eg -- 13645

        v_ord_num oe_order_headers_all.order_number%type;

       CURSOR c_order_num(p_hdr_id number) is
             SELECT order_number
             FROM   oe_order_headers_all
             WHERE  header_id = p_hdr_id;

        -- additions by sriram ends here

       /*
       || Added by aiyer for the bug 3446362.
       || Check whether rows exist in the JAI_OM_WSH_LINES_ALL tables with excise exempt type other than CT3.
       || Even records with null values are fine.
       */
      CURSOR c_ct3_flag_exists
      IS
      SELECT
           count(1)
      FROM
           JAI_OM_WSH_LINES_ALL
      WHERE
           delivery_id                   = p_delivery_id  AND
           nvl(excise_exempt_type,'$$')  <> 'CT3';

      ln_count NUMBER;

      /* added by bgowrava for forward porting - bug# 5554420 */
        lv_exc_inv_gen_for_dlry_flag  varchar2(1);
        ln_excise_tax_cnt         number;
        CURSOR c_excise_tax_cnt(cp_delivery_detail_id JAI_OM_WSH_LINE_TAXES.delivery_detail_id%type) IS
        SELECT count(1)
        FROM   JAI_OM_WSH_LINE_TAXES  JSPTL ,
               JAI_CMN_TAXES_ALL             JTC
        WHERE  JSPTL.TAX_ID   = JTC.TAX_ID
        AND    JSPTL.delivery_detail_id = cp_delivery_detail_id
        AND    upper(jtc.tax_type) like '%EXCISE%';


      /*
      || Added by Ramananda
      || Start of bug#4543424
      */
      CURSOR c_excise_tax_rate(cp_delivery_detail_id JAI_OM_WSH_LINE_TAXES.DELIVERY_DETAIL_ID%TYPE) IS
      SELECT SUM(NVL(JSPTL.tax_rate,0)) , count(1) --NVL(sum(JSPTL.tax_rate),0)
      FROM   JAI_OM_WSH_LINE_TAXES  JSPTL ,
             JAI_CMN_TAXES_ALL      JTC
      WHERE  JSPTL.TAX_ID   = JTC.TAX_ID
      AND    JSPTL.delivery_detail_id = cp_delivery_detail_id
      AND    UPPER(JTC.TAX_TYPE) = 'EXCISE';

      ln_total_tax_rate  JAI_CMN_TAXES_ALL.tax_rate%TYPE;
      ln_number_of_Taxes NUMBER;
      /*
      || Added by Ramananda
      || End of bug#4543424
      */

      CURSOR    c_cess_amount (cp_Delivery_id JAI_OM_WSH_LINES_ALL.delivery_id%type) is
      SELECT    sum(jsptl.func_tax_amount)  tax_amount
      FROM      JAI_OM_WSH_LINE_TAXES jsptl ,
                JAI_CMN_TAXES_ALL            jtc
      WHERE     jtc.tax_id  =  jsptl.tax_id
      AND       delivery_detail_id in
      (SELECT   delivery_detail_id
       FROM     JAI_OM_WSH_LINES_ALL
       WHERE    delivery_id = cp_delivery_id
      )
       AND       upper(jtc.tax_type) in (jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess); /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
     -- AND       upper(jtc.tax_type) in ('CVD_EDUCATION_CESS','EXCISE_EDUCATION_CESS');

  /*Cursor added by ssawant for bug 5989740 */
      CURSOR    c_sh_cess_amount (cp_Delivery_id JAI_OM_WSH_LINES_ALL.delivery_id%type) is
      SELECT    sum(jsptl.func_tax_amount)  tax_amount
      FROM      JAI_OM_WSH_LINE_TAXES jsptl ,
                JAI_CMN_TAXES_ALL            jtc
      WHERE     jtc.tax_id  =  jsptl.tax_id
      AND       delivery_detail_id in
      (SELECT   delivery_detail_id
       FROM     JAI_OM_WSH_LINES_ALL
       WHERE    delivery_id = cp_delivery_id
      )
       AND       upper(jtc.tax_type) in (jai_constants.tax_type_sh_cvd_edu_cess,jai_constants.tax_type_sh_exc_edu_cess);

      ln_cess_amount     number;
      ln_sh_cess_amount     number; /* added by ssawant for bug 5989740 */
      lv_process_flag    varchar2(5);
      lv_process_message varchar2(1996);



    /* ends additions by ssumaith - bug# 4311993 */

    /*
    || Start of bug 4566054
    ||Code added by aiyer for the bug 4566054
    ||Get the total cess amount at the delivery detail level
    ||hence calculate the cess and pass it to the procedure jai_om_rg_pkg.ja_in_rg_i_entry with source as 'WSH'
    */
    CURSOR cur_get_del_det_cess_amt (cp_delivery_detail_id JAI_OM_WSH_LINES_ALL.DELIVERY_DETAIL_ID%TYPE)
    IS
    SELECT
           sum(func_tax_amount) cess_amount
    FROM
           jai_om_wsh_lines_all    jspl ,
           jai_om_wsh_line_taxes   jsptl,
           jai_cmn_taxes_all       jtc
    WHERE
           jspl.delivery_detail_id  = jsptl.delivery_detail_id  AND
           jsptl.tax_id             = jtc.tax_id                AND
           upper(jtc.tax_type)        IN (jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess) AND
           jspl.delivery_detail_id  = cp_delivery_detail_id;

    ln_del_det_totcess_amt JAI_CMN_RG_I_TRXS.CESS_AMT%TYPE;
    /* End of bug 4566054 */

  /*START, Bgowrava for forward porting bug#5989740*/
    CURSOR cur_get_del_det_sh_cess_amt (cp_delivery_detail_id JAI_OM_WSH_LINES_ALL.DELIVERY_DETAIL_ID%TYPE)
    IS
    SELECT
           sum(func_tax_amount) cess_amount
    FROM
           JAI_OM_WSH_LINES_ALL       jspl,
           JAI_OM_WSH_LINE_TAXES   jsptl,
           JAI_CMN_TAXES_ALL              jtc
    WHERE
           jspl.delivery_detail_id  = jsptl.delivery_detail_id  AND
           jsptl.tax_id             = jtc.tax_id                AND
           upper(jtc.tax_type)        IN (jai_constants.tax_type_sh_cvd_edu_cess,
                                          jai_constants.tax_type_sh_exc_edu_cess)
    AND
         jspl.delivery_detail_id  = cp_delivery_detail_id;

         ln_del_det_totshcess_amt JAI_CMN_RG_I_TRXS.SH_CESS_AMT%TYPE;

    /*END, Bgowrava for forward porting bug#5989740*/

      /* Bug4562791. Added by Lakshmi Gopalsami */
      CURSOR c_conc_request_submit_date
             (cp_Request_id FND_CONCURRENT_REQUESTS.REQUEST_ID%TYPE) IS
      SELECT REQUEST_DATE
        FROM FND_CONCURRENT_REQUESTS
       WHERE request_id = cp_Request_id;

      ld_request_submit_Date FND_CONCURRENT_REQUESTS.REQUEST_DATE%TYPE;

     /* Bug 5243532. Added by Lakshmi Gopalsami
      * Define variable for implementing caching logic.
      */
    l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

BEGIN

/*------------------------------------------------------------------------------------------
CHANGE HISTORY: FILENAME: process_delivery.sql
S.No  Date        Author and Details
------------------------------------------------------------------------------------------
1       2001/04/01      Vijay Added - Org_Id for Multi-Org Support

2       2001/04/09      Manohar Mishra - Changed the cases for Register Codes

3       2001/05/25      Anuradha Parthasarathy -
                        Added arguments v_exc_invoice_no and v_exc_invoice_date to RG23d procedure instead of nulls

4       2001/05/26      Anuradha Parthasarathy
                        Cursor added to ensure incrementation of excise invoice nos for trading Organizations

5       2001/05/30      Anuradha Parthasarathy
                        Condition added to ensure that the registers are hit only when the excise amount
                        is greater than zero.

6       2001/06/15      For Bond Register
7       2001/07/12      Anuradha Parthasarathy
                        Excise Invoice Generation for Trading to go on same lines as Manufacturing.

8       2001/09/13      Jagdish Bhosle - For Split order Cursor added to populate correct order_line_id.

9       2001/08/07      Jagdish Bhosle
                        Initilise v_tax_rate to 0 as excise tax rate was doubling in RGi manual entry screen.

10      2001/10/01      Jagdish Bhosle - To avoid same Excise Invoice No if setup is not done.

11      2001/09/24      Vijay - Rounded amounts for RG23_Partii and PLA

12      2001/10/05      Jagdish Bhosle - Excise Generation after successful Inventory /OM interface.

13      2001/11/01      Anuradha Parthasarathy - Code added to deal with Modvat Recovery for excise exempt types.

14      2002/02/07      Vijay - Added a check to avoid duplication of Excise Invoice Number in RG23PartII

15      2002/02/20      Vijay - Check added to avoid duplication of Excise Invoice Number in PLA, RG23 PartI

16      2002/05/24      cbabu - bug2389773
                        added a check, so that bond register table is hit only once for a delivery_id

17  2002/05/29          asshukla - bug2392099 Added the condition to check for excise flag for a item

18  2002/06/20          ASSHUKLA - Bug 2404190 Code added for generating excise invoice generation at transaction type level.

19  2002/07/03          Nagaraj.s - For Enh#2415656.
                        Cursors pref_cur - Incorporated v_export_oriented_unit also in the select clause
                        RG Bal Cur- Incorporated basic,additional,other pla balance also in the select clause.
                        Functions jai_om_wsh_processing_pkg.excise_balance_check - for preference checks in case of EOU and Non-EOU for total excise amount
                        jai_om_wsh_pkg.get_excise_register_with_bal - for preference checks in case of EOU and Non-EOU
                        for exempted amount.
                        Before sending this patch it has to be taken care that, the alter scripts,functions should also
                        accompany the patch otherwise the patch would certainly fail.

20  2002/07/20  SSUMAITH  Bug # 2454978 Added code for ensuring the tax target amount is not 0 for 0% CST.

21  2002/10/24  SSUMAITH  Bug # 2638797 - Added code to see that the register is gettig hit for a trading organization
                          and  the item a trading item , then the register to be hit is RG23D.

22  2003/01/02  SSUMAITH  Bug # 2731434 - File Version - 615.3
                          Added the (NVL(v_bonded_flag,'Y') = 'Y' to the condition which checks if the exise_flag is 'Y' for the item
                          so that excise invoice number gets generated only if item is excisable and subinventory is bonded.

23  2003/01/13  SSUMAITH Bug # 2746921 . File Version - 615.4
                         Excise invoice number was not getting generated for a trading subinventory.This was reported after the patch
                         associated with the Bug # 2731434 was applied. It was noticed that , an earlier bug Bug # 2392099 was the reason
                         as it was considering only "item being excisable" to be the constraint for excise invoice generation .This has been
                         supplemented by the condition that the subinventory should also be bonded , which caused that for a trading
                         subinventory , excise invoice number not getting generated. This issue has been fixed by adding the following
                         check.
                         Item should be excisable AND (Subinventory is either Bonded or Trading) for excise invoice num to be generated.

23  2003/01/15           cbabu for Bug# 2736191, File Version# 615.5 (Obsoleted with 2803409)
                         When a trading transaction is done with delivery detail matched to multiple receipts, then RG23D register is not being hit properly.
                         Code changes are made to hit the register with proper quantity and reduce the balances of receipts as per the matched quantity

24. 2003/01/27           ssumaith  Bug # 2769436 File version 616.6  (Obsoleted with 2803409)
                         When a transaction is done with the register code as DOM_WITHOUT_EXCISE , still excise invoice number was getting
                         generated based on gp2 instead of gp1.This was because , this transaction type was excluded in the if condition .
                         adding this condition to the if which takes care of this issue.Also taken care of register type '23D_DOM_WITHOUT_EXCISE'
                         which was not handled till now.

25  2003/02/19        cbabu for Bug# 2803409, FileVersion# 615.7
                      DELETE from JAI_OM_OE_GEN_TAXINV_T statement got deleted in file version 615.5(Bug# 2736191) somehow. This statement is
                      reincorporated with his bug. Bugs 2736191 and 2769436 were made obsolete and this bug needs to be send instead of them

26. 2003/02/20       ssumaith - Bug # 2663211 File Version # 615.8
                      Excise invoice generation logic in this procedure has been removed and instead a call to the
                      excise invoice generation procedure has been made.
                      This has dependency on the  jai_cmn_setup_pkg.generate_excise_invoice_no procedure . Hence this bug
                      is a pre-requisite for future bugs.

27. 2003/07/24       Aiyer - Bug #3032569, File Version 616.1
                      The Excise Invoice number is being generated for non excisable RG23D transactions.
                      This needs to be stopped for Trading Domestic Without Excise and Export Without excise scenario's.
                      Modified the IF statment to remove the check that the trading register_codes should be in
                      '23D_DOM_WITHOUT_EXCISE' and '23D_EXPORT_WITHOUT_EXCISE' .
                      Now the excise invoice number would be generated only for orders with Bond register types as Domestic
                      Trading With Excise and Export with Excise.

                      Dependency Introduced Due to this Bug : -
                       None

28.  2003/07/28       Aiyer - Bug#3071342, File Version 616.2
                      As the excise invoice generation should not be done in case Domestic Without Excise for trading and manufacturing
                      organizations and hence modified the if statement to validate that
                      excise invoice generation procedure is called only in case where v_register_code is in '23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE'
                      ,'DOMESTIC_EXCISE', 'EXPORT_EXCISE' ,'BOND_REG'.
                      This would ensure that the excise invoice generation would not happen in case where v_register_code in
                      'DOM_WITHOUT_EXCISE','23D_DOM_WITHOUT_EXCISE' i.e Domestic Without Excise for Trading and manufacturing organizations.

                      Dependency Introduced Due to this Bug : -
                       None

29. 2003/07/31       SSUMAITH Bug # 2769440 File Version 616.3 (GL Link)

                     As part of the GL Link Enhancement , added parameters in call to the jai_om_rg_pkg's procedures ja_in_rg23_part_II_entry ,
                     ja_in_pla_entry and Ja_In_Rg23d_Entry.

                     Dependency Introduced Due to this Bug : -
                       This patch has dependency on all further patches using this object.


30. 2003/08/22 SSUMAITH Bug # 3021588 File Version 616.4 (Bond Register Enhancement)

                For Multiple Bond Register Enhancement,
                Instead of using the cursors for fetching the register associated with the order type , a call has been made to the procedures
                of the jai_cmn_bond_register_pkg package. There enhancement has created dependency because of the
                introduction of 3 new columns in the JAI_OM_OE_BOND_REG_HDRS table and also call to the new package jai_cmn_bond_register_pkg.

                New Validations for checking the bond expiry date and to check the balance based on the call to the jai_cmn_bond_register_pkg has been added

                Provision for letter of undertaking has been incorporated. In the case of the letter of undetaking , its also a type of bond register
                but without validation for the balances.
                This has been done by checking if the LOU_FLAG is 'Y' in the JAI_OM_OE_BOND_REG_HDRS table for the
                associated register id , if yes , then validation is only based on bond expiry date .

                Dependency Introduced Due to this Bug : -
                 This fix has introduced huge dependency . All future changes in this object should have this bug as a prereq


31.  2003/09/24  Aiyer - Bug#3139718, File Version 616.5

                          Modified the cursor get_conv_detail_cur to get the actual_shipment_date from oe_order_lines_all instead of the
                          conversion_date from oe_order_headers_all.
                          As a Sales order shipment date can be different from its creation date, hence the conversion rate
                          applicable on the date of shipment should be considered for all processing rather than the creation
                          date of the Sales order.
                          Added a call to jai_cmn_utils_pkg.currency_conversion procedure to get the conversion rate based on the actual shipment date.

                         Fix of Bug 3158282: -
                          1. The values passed to the parameters p_basic_ed/p_dr_basic_ed,p_additional_ed/p_dr_additional_ed and p_other_ed/p_dr_other_ed
                             in the procedures ja_in_rg_I_entry and ja_in_rg23_part_I_entry of the package
                             jai_om_rg_pkg was rounded off (using a round function to 0 decimal values) so that all values of columns basic,
                             additional and other amounts passed to the tables JAI_CMN_RG_I_TRXS, JAI_CMN_RG_23AC_I_TRXS table
                             get rounded off.

                          2. For the calls to the procedure procedures ja_in_rg23_part_II_entry,ja_in_pla_entry,ja_in_regsiter_txn_entry in the jai_om_rg_pkg
                             the values of fields being passed i.e basic_excise_duty_amount, add_excise_duty_amount, oth_excise_duty_amount and excise_amount
                             have been rounded off at the cursor get_total_excise_amt level itself, as these values should always be in INR.


                          Dependency Due to this bug:-
                          None


32. 11/10/2003     ssumaith - Bug # 3158976 File Version 616.6

                    Sales order number is appended to the variable v_ref_10 which holds a standard text
                    in a loop of delivery details for a particular delivery.
                    If the number of delivery details are huge , the appending is causing the width of the concatenated text
                    to exceed beyond 250 characters.
                    It causes PL/SQL Numeric or value error.

33. 11/10/2003    ssumaith - bug # 3138194 File Version 616.7

                  Population of ST forms related functionality is removed from this procedure and instead moved into a
                  new concurrent program. All other logic remains same , with respect to hitting the RG registers.

34. 4-nov-03     ssumaith - bug # 3207685

                 For excise exempted transactions, modvat entry was happening only for the first line.
                 The reason this happens because the value being fetched was only of the first record.
                 This has been corrected by calculating the excise exempted amount correctly and passing
                 it to the jai_om_rg_pkg .

35. 11-Nov-2003  Aiyer  - Bug #3249375 File Version 617.1
                  References to JA_IN_OE_ST_FORMS_HDR table, which has been obsolete post IN60105D1 patchset, was found
          in this file in some cursors.
          As these tables do not exists in the database any more, post application of the above mentioned patchset
          hence deleting the cursors.

                  Dependency Due to This Bug:-
               Can be applied only post application of IN60105D1.

36.05-Dec-2003  ssumaith - bug #  3229697  version 617.2
                Performance improvement done in 'Excise invoice genration program'

                Dependency Due to This Bug:-
                None

37.30-jan-04    ssumaith  bug# 3368475 file version 618.1

                CENVAT Reversal Entries should not be passed for CT3 Transaction.

                On Shipping goods to an 100% EOU against a CT 3 Form at an exempted rate,
                India Localization reverses the CENVAT at 8% of the Base Amount. This
                        is incorrect. The CENVAT should not be reversed.

                This has been acheived by making code changes:

                1) if CT3 type of excise exemption is chosen in the sales order :
                   only quantity register gets hit
                   amount register does not get hit.
                2) if other than CT3 type of excise exemption is chosen in the sales order
                   both quantity and amount registers get hit.

                3) Please note that in cases where amount registers are not hit because of CT3 excise exemption, the
                register column in the JAI_OM_WSH_LINES_ALL table will show NULL. this is
                        also the change which i have incorporated.

                Dependency Due to This Bug:-
                None

38. 18-Feb-2004  Aiyer Bug #3448674, File Version  618.2
                 Issue:-
                 ======
                 Amount registers are hit with excise amoutns which are getting round at Shipping Line level
                 instead of at a Delivery level.

                 Solution:-
                 ==========
                 Changed the cursor get_total_excise_amt to do rounding at a paticualr delivery level rather
                   than the line level.
                   For this , we are first summing the taxes and then rounding them. This prevents line level
                 rounding and enforces delivery level rounding.

                Dependency Due to This Bug:-
                None

38. 09-Mar-2004  Aiyer Bug #3446362, File Version  618.3(reopened) fixed in 618.4.
                 Issue:-
                 ==========
                          When a Order has multiple lines out of which one line is Excise Exempted and the other are not,
                  then the behaviour expected is that the item which is not excise exempt should hit Excise registers.
                  However, the same is not currently happening.

                 Reason: -
                 ======
                  This was happening as the code that calls the jai_om_rg_pkg package to insert records into any of the amount
                  registers i.e either of JAI_CMN_RG_23AC_II_TRXS or JAI_CMN_RG_PLA_TRXS was bypassed if the first one was found to contain
                  a 'CT3' type of exemption.

                 Fix :-
                 ======
                     Modified the code to check whether any of the delivery details for the given delivery has a excise exemption
                 type other than 'CT3' (this includes null rows also). Only if one or more such records exist, then
                 hit the amount registers, else bypass the call.
                 Cursor c_ct3_flag_exists has been added to the code to take the count of records which do not have excise exemption
                 of type CT3.

38. 19-Mar-2004  Aiyer Bug #3446362, File Version  618.4(reopened) fixed in 619.1
                 Issue:-
                 ========
                 The bug 3446362 version 618.4 of this file did not work correctly on the clients instance.
                 It was still not entering the excise amount line in the amount registers when the order conatined mulitple lines with the first line excise exempted.

                 Reason:-
                 The amount register is hit based on the which amount register needs to be hit.The value of amount register to be hit is stored in the variable  v_reg_type.Now initially the v_reg_type
                would be set to Null for the line which had 'CT3'type of exemption.
                 Now if this line happens to be the first line then and the register are also hit only once, so the code ignores the other lines as v_reg_type is set to null.

                         Fix:-
                 =====
                 The fix done is that instead of setting the v_reg_type to null when a 'CT3' exemption is found and later
                 updating this variable into JAI_OM_WSH_LINES_ALL.register, handled this condition though a decode
                 statement, instead of directly updating the v_reg_type variable.
                     The v_reg_type now still holds the value for the register, where as the table is updated with null when ever the exemption is 'CT3'.
                 This has rectified the problem.

                Dependency Due to This Bug:-
                None

39. 24-Aug-2004  Sanjikum Bug #3849638, File Version  115.1
                 Issue:-
                 ========
                 Excise invoice number is generated even when inventory interface ends in warning

                 Reason:-

                 For selecting the cases where Inventory Interface has failed, the following condition was being used -
                 NVL(wdd.inv_interfaced_flag,'N') = 'N'
                 For the failure there can be one more status - 'P'. Which is being missed in this case.

                         Fix:-
                 =====
                 The fix done is that instead of condition - NVL(wdd.inv_interfaced_flag,'N') = 'N'
                 The new condition is used - NVL(wdd.inv_interfaced_flag,'N') <> 'Y'
                 This has rectified the problem.
                 While updating the JAI_OM_WSH_LINES_ALL, new columns are added -
                 last_update_date, last_updated_by, last_update_login, as these were not previously updated

                 Dependency Due to This Bug:-
                 None

40. 20-JAN-2005 - ssumaith  - Bug#4136981 - Corrected the call to the JAI_OM_OE_BOND_TRXS entry.
                 It was not consistent with the other calls , such as rg1 entry , rg23_part_ii entry , pla entry.
                 This fix introduces no dependency.

41. 2005/02/11    ssumaith - bug# 4171272 - File version 115.3

                 Shipment needs to be stopped if education cess is not available.

                 The basic business logic validation is that both cess and excise should be available as
                 part of the same register type and the register preference setup at the organization additional information
                 needs to be considered for picking up the correct register .

                 This code object calls the functions jai_om_wsh_processing_pkg.excise_balance_check_f and jai_om_wsh_pkg.get_excise_register_with_bal_f
                 which have had changes in their signature and hence the caller also needs to pass the correct
                 parameters.

                 The change done in this object is to pass the additional parameters correctly to the functions.

                 Dependency Due to this Bug:-
                  The current procedure becomes dependent on the functions jai_om_wsh_processing_pkg.excise_balance_check (version 115.1) and
                  jai_om_wsh_pkg.get_excise_register_with_bal (version 115.1) also packaged as part of this bug.

42. 2005/02/16    ssumaith - bug# 4185392 - File version 115.4

                  Excise Duty rate was going in as zero in JAI_CMN_RG_I_TRXS table. This was because the variable
                  corresponding to the excise_duty_rate parameter in the ja_in_rg_i_entry procedure was
                  explicitly set to zero.

                  This has been changed and made as excise_duty_amount divided by (assessable value * shipped quantity).
                  Care has been taken to ensure that zero divide error does not come by checking for non zero values
                  for the elements in the denominator of the fraction.

                  As expected by IL support , rounding the tax_rate to two decimals.

                   Dependency Due to this Bug:-
                    None.

43. 08-Jun-2005   File Version 116.3. Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                  as required for CASE COMPLAINCE.

44. 13-Jun-2005   Ramananda for bug#4428980. File Version: 116.4
                  Removal of SQL LITERALs is done

45. 06-Jul-2005   Ramananda for bug#4477004. File Version: 116.5
                  GL Sources and GL Categories got changed. Refer bug for the details

46. 9-Aug-2005    Ramananda for bug#4543424. File version 120.2
                  Excise Duty rate was going as fractions in JAI_CMN_RG_I_TRXS table.
                  This is because the excise amount is rounded off at the shipment level and when the rate is recalculated
                  it is calculated as excise amount divided by assessable value * 100. This results in rounding issue.

                  This has been resolved by making the following changes.
                  The excise rate is calculated as a sum of total 'EXCISE' tax rates divided by the number of 'EXCISE' taxes.

                  Dependency Due to this Bug:-
                  None.

47. 19-Aug-2005  Bug4562791. Added by Lakshmi Gopalsami Version 120.3
                 The excise invoice date , the date on which rg registers are hit should be the
     date when the concurent request is submitted. This is as per the product
     management requirement.

                 Hence added a cursor that gets the request submitted date and punched that
     date in the calls to the ja_in_rg_pkg.ja_in_rg23_part_ii_entry ,
     ja_in_Rg_pkg.pla_entry and the same gets carried forward
                 to the gl interface as well.

     Also changed the creation_date and last_update_date with v_date.

     Dependencies (Compilation and Functional Dependencies)
     ------------
     jai_om_rg.pls 120.2
     jai_om_rg.plb 120.3

48. 23-Aug-2005 Aiyer - Bug 4566054 (Forward porting for the 11.5 bug 4346220 ),Version 120.4
                  Issue :-
                   Rg does not show correct cess value in case of Shipment transactions.

                  Fix:-
                  Two fields cess_amt and source have been added in JAI_CMN_RG_I_TRXS table.
                  The cess amt and source would be populated from jai_jar_t_aru_t1 (Source -> 'AR' ) and
                  as 'WSH' from jai_om_wsh.plb procedure Shipment.
                  Corresponding changes have been done in the form JAINIRGI.fmb and JAFRMRG1.rdf .
                  For shipment and Ar receivable transaction currently the transaction_id is 33 and in some cases where the jai_cmn_rg_i_trxs.ref_doc_id
                  exactly matches the jai_om_wsh_lines_all.delivery_detail_id and jai_ar_trxs.customer_trx_id the tracking of the source
                  becomes very difficult hence to have a clear demarcation between WSh and AR sources hence the source field has been added.

                  Added 2 new parametes p_cess_amt and p_source to jai_om_rg_pkg.ja_in_rg_i_entry package.
                  This has been populated from this and jai_om_wsh_pkg.process_delivery procedure.

                  A migration script has been provided to migrate the value for cess and source.

                  Dependency due to this bug:-
                  1. Datamodel change in table JAI_CMN_RG_I_TRXS, added the cess_amt and source fields
                  2. Added two new parameters in jai_om_rg_pkg.ja_in_rg_i_entry procedure to insert data into JAI_CMN_RG_I_TRXS table
                  3. Modified the trigger jai_jar_t_aru_t1
                  4. Procedure jai_om_wsh_pkg.process_delivery
                  5. Report JAICMNRG1.rdf
                  6. Created a migration script to populate cess_amt and source for Shipment and Receivable transactions.
                  Both functional and technical dependencies exists


49. 01-DEC-2005 Aiyer - Bug 4765347 ,Version 120.5
                Issue :- Excise invoice program runs into error.
                Fix   :- Changed the form JAIITMCl.fmb to insert into the jai_inv_items_setups form
                         also changed the current procedure to add who column into jai_cmn_errors_t.

              Dependencies introduced due to this bug:-
                Yes, please refer the future dependencies section.

50. 13-Feb-2007   bgowrava for forward porting bug#5554420 (11i bug#5531051). File Version 120.7
                  Issue: Excise invoice/register not getting updated properly in ja_in_so_picking_lines
                      Also observed that if excise invoice is not generated for first line of delivery,
                      then it is not getting generated at all.

                  Resolution: introduced the flag to know whether excise invoice is generated for the delivery.
                  if not generated for 1st line, added the code to execute the generation code again for next lines for delivery
                  - added new cursor c_excise_tax_cnt to know the excise taxes count and generate exc invoice number
                    only if count > 0
                  - Added the logic to execute amount register hitting logic once for every delivery (usually this
                     will be done for the first line that has excise implication)

51. 23/02/07      bduvarag for bug#5403048,File version 120.8
                Forward porting the changes done in 11i bug 5401533

52. 13-April-2007   ssawant for bug 5989740 ,File version 120.9
                    Forward porting Budget07-08 changes of handling secondary and
                   Higher Secondary Education Cess from 11.5( bug no 5907436) to R12 (bug no 5989740).

53. 18/Apr/2007   Bgowrava for forward porting bug#5989740, 11i BUG#5907436 File Version 120.9
                  ENH: Handling Secondary and Higher Education Cess
                  Added the new cess types jai_constants.tax_type_sh_exc_edu_cess, jai_constants.tax_type_sh_cvd_edu_cess

54. 28/05/2007    CSahoo for bug#6077065, File version 120.10
                  Issue: The excise invoice num and excise_invoice_date was not getting updated in the JAI_OM_WSH_LINES_ALL table.
                  Fix:added the following line in the code lv_exc_inv_gen_for_dlry_flag := 'Y'.


55. 05/07/2007    kunkumar for Bug#6121833 File version 120.11
                    Added an if condition  After open-fetch-close in lv_statement_no :=18


56. 20-MAY-2008   JMEENA bug#7043292
      Issue :- Excise Invoice Generation completes with ORA-01476
                  Fix   :- The calculation of v_proportionate_edr was using v_total_base_duty_amount fetched
                            from matched_receipt_cur which was comming as zero.
                            A check is introduced to verify that v_proportionate_edr is calculated
                            only in the case when v_total_base_duty_amount is non-zero.

57. 26-nov-2008   vkaranam for bug#7591616, File Version 115.20.6107.11
                  Issue: EXCISE INVOICE DATE AND AR INVOICE DATE FOR DELIVERY ID NOT IN SYNCHRONIZATION
                  FIX: Modified the code to populate the excise invoice date with the actual shipment date.
                  Further the gl accounting date and the transaction dates for all the register
                  updates is also populated by the actual shipment date.

58. 30-dec-2008   CSahoo for bug#7647742, File Version 120.11.12010000.5
                  Reverted the changes done in the file version 120.11.12010000.4
                  Further removed the nvl condition in IF condition for checking modvat tax rate.
59. 10-nov-2009 vkaranam for bug#8904363
                Issue:
		TST1212 XB1:QA: UNABLE TO GENERATE EXCISABLE INVOICE

		If the subinventory is neither bonded nor tradable ,conncurrent request is not showing the user message.

		Fix:
		Added the user log message
                 "Subinventory is neither bonded nor tradable .henc eexcise invoice number cannot be generated".
		 this will be displayed in the India excise invocie generation log file only if bonded_flag='N' and trading_flag='N'.


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                                        Version   Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
process_delivery.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
616.1                  3032569       IN60104D1             None           --                                   Aiyer   24/07/2003   Row introduces to start dependency tracking


616.3                  2769440       IN60104D1 +        jai_om_rg_pkg.sql                                     Ssumaith  31/07/2003   GL Link Enhancement.
                                     2801751 +          ja_in_gl_interface_new.sql
                                     2769440

616.4                  3021588       IN60104D1 +                                                               ssumaith  22/08/2003   Bond Register Enhancement
                                     2801751   +
                                     2769440

617.1                  3249375       IN60105D1                                                                 Aiyer     11/Nov/2003  Can be applied only after IN60105D1 patchset
                                                                                                                                     has been applied.

619.1                  3446362       IN60105D2             None           --                                   Aiyer     19/03/2004   Row introduces to start dependency tracking


115.3                  4171272      IN60106 +
                                    4147608             jai_om_wsh_pkg.get_excise_register_with_bal_f.sql 115.1 ssumaith  11/02/2005    New parameters added to function.
                                                        jai_om_wsh_processing_pkg.excise_balance_check_f.sql        115.1 ssumaith  11/02/2005    New parameters added to function.

12.0                   4566054                          jai_om_rg.pls                                      120.3   Aiyer     24-Aug-2005
                                                        jai_om_rg.plb                                      120.4
                                                        jai_om_wsh.plb (jai_om_wsh_pkg.process_delivery)   120.4
                                                        JAINIRGI.fmb                                       120.2
                                                        jain14.odf                                         120.3
                                                        jain14reg.ldt                                      120.3
                                                        New migration script to port data into new tables  120.0
                                                        JAICMNRG1.rdf                                      120.3
                                                        jai_jai_t.sql (trigger jai_jar_t_aru_t1)           120.1

120.4                 4765347                           JAIITMCL.fmb                                       120.9
                                                        jai_om_rg.plb                                      120.4

------------------------------------------------------------------------------------------------------------------------------------------------*/
  /* Ramananda for File.Sql.35 */
  lv_debug            := jai_constants.yes ;
  lv_procedure_name   := 'process_delivery';
  v_creation_date     := SYSDATE;
  v_source_name       := 'Register India' ;
  v_category_name     := 'Register India' ;
  v_ref_10            := 'India Localization Entry for sales order # '; -- will hold a standard text such as 'India Localization Entry for sales order'
  v_std_text          := 'India Localization Entry for sales order # '; -- bug # 3158976
  v_ref_23            := 'process_delivery'; -- holds the object name -- 'process_delivery'
  v_ref_24            := 'wsh_new_deliveries'; -- holds the table name  -- ' wsh_new_deliveries'
  v_ref_25            := 'delivery_id'; -- holds the column name -- 'delivery_id';
  /* Ramananda for File.Sql.35 */

  lv_block_no := '0';
  Fnd_File.PUT_LINE(Fnd_File.LOG, ' 1 START Delivery id = ' || p_delivery_id );
  FOR Each_record IN
  (
    SELECT *
    FROM JAI_OM_OE_GEN_TAXINV_T ja_tmp
    WHERE delivery_id = p_delivery_id
    and            /*The idea of putting the exists is to see that do not process a delivery ,if it has
                     at least one delivery detail with inv_interfaced_flag = 'N' */
    not exists
    ( select 1
      FROM
               wsh_delivery_details            wdd     ,
               wsh_new_deliveries              wnd     ,
               wsh_delivery_assignments        wda
        WHERE
               wdd.delivery_detail_id = wda.delivery_detail_id             AND
               wda.Delivery_Id        = wnd.Delivery_Id                    AND
               wnd.Delivery_Id        = ja_tmp.delivery_id                 AND
               wdd.source_code        = 'OE'                               AND
               --NVL(wdd.inv_interfaced_flag,'N') = 'N'
               --Commented the above and added the below for bug #3849638
               NVL(wdd.inv_interfaced_flag,'N') <> 'Y'
      )
  )
  LOOP
    v_ref_26 := p_delivery_id                           ;
    OPEN  c_order_num(each_record.order_header_id)      ;
    FETCH c_order_num into v_ord_num                    ;
    CLOSE c_order_num                                   ;



     /* Bug 4562791. Added by Lakshmi Gopalsami */
    OPEN  c_conc_request_submit_date(FND_GLOBAL.conc_request_id);
    FETCH c_conc_request_submit_date INTO ld_request_submit_Date;
    CLOSE c_conc_request_submit_date;
    /* Ends here  Bug 4562791. Added by Lakshmi Gopalsami */

    v_ref_10 := v_std_text || v_ord_num; -- instead of appending v_ref_10 every time , appending the so# to the standard text instead.-- bug # 3158976
    Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', '||'2 Each_record.Delivery detail id = ' || Each_record.delivery_detail_id );
    v_tax_rate := 0;  --2001/08/07 Jagdish
    lv_statement_no := '1';

    OPEN get_delivery_status(each_record.delivery_id);
    FETCH get_delivery_status INTO v_status_code,v_initial_pickup_date;
    CLOSE get_delivery_status;

    IF v_status_code NOT IN ('CO','IT','CL') THEN
      return;
    END IF;

    -- 2001/10/05  Jagdish Bhosle
    lv_statement_no := '2';

    OPEN  get_order_line_id(Each_record.delivery_detail_id);
    FETCH get_order_line_id INTO v_source_line_id_pick;
    CLOSE get_order_line_id;

    --Anuradha Parthasarathy
    lv_statement_no := '4';
    OPEN  get_actual_shipment_date(v_source_line_id_pick);
    FETCH get_actual_shipment_date INTO v_actual_shipment_date;
    CLOSE get_actual_shipment_date;

    /* Bug 4562791. Added by Lakshmi Gopalsami
       Commented the below and initialised with different value
    v_date := NVL(v_initial_pickup_date,v_actual_shipment_date); */
    v_date := ld_request_submit_Date;

    /* Bug 4562791. Added by Lakshmi Gopalsami
       The concurrent submission date needs to be the excise invoice date and
       transaction date in the rg registers and the same date should be
       the accounting date in gl_interface.
    */
    jai_om_rg_pkg.gl_accounting_date :=v_actual_shipment_date; --replaced v_date for bug#7591616

    --Anuradha Parthasarathy
    v_created_by        := Each_record.created_by ;
    v_last_update_date  := Each_record.last_update_date;
    v_last_updated_by   := Each_record.last_updated_by;
    v_last_update_login := Each_record.last_update_login;

    lv_statement_no := '5';
    OPEN  Get_delivery_detail_cur(each_record.delivery_detail_id);
    FETCH Get_delivery_detail_cur INTO v_order_line_id,
            v_organization_id, v_location_id, v_register, v_inventory_item_id,
            v_uom_code, v_shp_qty, v_item_class, v_excise_flag, v_basic_ed_amt,
            v_addl_ed_amt, v_oth_ed_amt, v_excise_amount, v_excise_exempt_type,
            v_selling_price, v_customer_id, v_ship_to_org_id,
            v_order_type_id, v_subinventory, v_assessable_value,
            v_excise_exempt_refno, v_org_id; --2001/04/01 Vijay
    CLOSE Get_delivery_detail_cur;



    /* following cursor modified from c_excise_tax_rate to c_excise_tax_cnt because this cursor should
        only be used for excise invoice generation. bgowrava for Bug#5554420*/
       ln_excise_tax_cnt := 0;
       OPEN  c_excise_tax_cnt(each_record.delivery_detail_id);
       FETCH c_excise_tax_cnt INTO ln_excise_tax_cnt ;
       CLOSE c_excise_tax_cnt;


    Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', '||'4 v_register = ' || v_register
            ||', v_order_type_id = ' || v_order_type_id ||', v_excise_exempt_type = ' || v_excise_exempt_type
        );

    IF v_register IS NULL THEN    --z999
      lv_statement_no := '6';

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed the cursor set_of_books_cur and implemented using caching logic.
     */
     l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_organization_id );
     v_set_of_books_id := l_func_curr_det.ledger_id;

      Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', '||'7 v_set_of_books_id = ' || v_set_of_books_id);
      lv_statement_no := '7';

      /*
         Code changed by aiyer for the bug #3139718.
         Modified the cursor get_conv_detail_cur to also provide the sales order line_id as input
         Added a call to jai_cmn_utils_pkg.currency_conversion procedure to get the conversion rate based on the actual shipment date.
      */
      -- Start of code for bug #3139718
      OPEN get_conv_detail_cur(
                                      cp_order_header_id => each_record.order_header_id ,
                                      cp_line_id         => v_order_line_id
                                );

      FETCH get_conv_detail_cur INTO  v_order_number  ,
                                      v_currency_code ,
                                      v_conv_type_code,
                                      v_conv_rate     ,
                                      v_conv_date;

      IF get_conv_detail_cur%FOUND THEN
        v_converted_rate := jai_cmn_utils_pkg.currency_conversion (
                                              v_set_of_books_id       ,
                                              v_currency_code         ,
                                              v_conv_date             ,
                                              v_conv_type_code        ,
                                              v_conv_rate
                                         );

        if v_converted_rate is null then
           v_converted_rate := 1;
        end if;
      END IF;
      -- End of code for bug #3139718
      CLOSE get_conv_detail_cur;

      lv_statement_no := '8'                                 ;
      OPEN  bonded_cur(v_organization_id, v_subinventory)    ;
      FETCH bonded_cur INTO v_bonded_flag,v_trading_flag     ;
      CLOSE bonded_cur                                       ;

      fnd_file.put_line(     fnd_file.log,
                             p_delivery_id||', '||'8 v_organization_id = ' || v_organization_id
                             ||', v_subinventory = ' || v_subinventory ||', v_bonded_flag = ' || v_bonded_flag
                             ||', v_trading_flag = ' || v_trading_flag
                       );

      lv_statement_no := '9';

        --start additions for bug#8904363
      if nvl( v_bonded_flag,'X')='N' and nvl(v_trading_flag,'X')='N'
      then
      fnd_file.put_line( fnd_file.log,'Subinventory '||v_subinventory ||' is neither bonded nor Tradable.Hence Excise Invoice Number cannot be generated.');
      end if;
      --end additions for bug#8904363


      /*
        Code modified by sriram - bug # 3021588 - Multiple Bond Registers.
        Calling the package jai_cmn_bond_register_pkg.GET_REGISTER_ID
      */


      jai_cmn_bond_register_pkg.get_register_id (  v_organization_id               ,
                                             v_location_id           ,
                                             v_order_type_id         , -- order type id
                                             'Y'                     , -- order invoice type
                                             v_asst_register_id      , -- out parameter to get the register id
                                             v_register_code
                                          ); -- out parameter to get the register code



      fnd_file.put_line(
                             fnd_file.log,
                             p_delivery_id||', '||', v_register_code = ' || v_register_code
                       );
      lv_statement_no := '10';
      OPEN  fin_year_cur(v_organization_id);
      FETCH fin_year_cur INTO v_fin_year;
      CLOSE fin_year_cur;

      /*
        code added here by sriram for modvat recovery in case of excise exempt transactions
      */
       IF v_item_class NOT IN ('OTIN', 'OTEX') THEN

       IF v_excise_exempt_type IN ('CT2_OTH', 'EXCISE_EXEMPT_CERT_OTH' ) THEN
         lv_statement_no := '17';
         OPEN  for_modvat_tax_rate(each_record.delivery_detail_id);
         FETCH for_modvat_tax_rate INTO v_modvat_tax_rate,v_rounding_factor;
         CLOSE for_modvat_tax_rate;
       ELSE
         IF v_excise_exempt_type IS NOT NULL THEN
            lv_statement_no := '18';
            OPEN  for_modvat_percentage(v_organization_id, v_location_id);
            FETCH for_modvat_percentage INTO v_modvat_tax_rate;
            CLOSE for_modvat_percentage;


--Added the below by kunkumar for bug#6121833
            IF v_modvat_tax_rate IS NULL THEN --removed the nvl condition for bug#7647742 because even if modvat rate is 0 it gives the error
              fnd_file.put_line(fnd_file.log, p_delivery_id||', '||'ERROR - MODVAT REVERSAL% SHOULD BE DEFINED IN ORGANIZATION ADDITIONAL INFORMATION ');
              errbuf := 'Error - MODVAT Reversal% should be defined in Organization Additional Information';
              retcode := 2; --to signal an error.
              return;
            END IF;
--Ends additions by kunkumar for Bug#6121833
         END IF;
       END IF;

       lv_statement_no := '19';
       fnd_file.put_line(fnd_file.log, p_delivery_id||', '||'8.01 v_exempt_bal = ' || v_exempt_bal);
       v_exempt_bal := NVL(v_exempt_bal, 0) +( v_shp_qty * v_assessable_value * NVL(v_modvat_tax_rate,0))/100;
       fnd_file.put_line(fnd_file.log, p_delivery_id||', '||'8.02 v_exempt_bal = ' || v_exempt_bal);
      end if;

      /* following 3 lines of code added by bgowrava for Bug#5554420 */
      if nvl(v_old_delivery_id,0) <> nvl(each_record.delivery_id,-1)
      then
        lv_exc_inv_gen_for_dlry_flag  := 'N';
        v_old_register := null;
        v_old_excise_invoice_no := null;
      end if;

      /* following code moved here from below by bgowrava for bug#5554420 */
        if v_old_register is null
        then
          OPEN  get_prev_del_dtl(each_record.delivery_id);
          FETCH get_prev_del_dtl INTO v_old_register, v_old_excise_invoice_no;
          CLOSE get_prev_del_dtl;
        end if;


      Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', 9 v_fin_year = ' || v_fin_year
              ||', v_old_delivery_id = ' || v_old_delivery_id );
      IF NVL(v_old_delivery_id,0) <> NVL(each_record.delivery_id,-1)
      or lv_exc_inv_gen_for_dlry_flag = 'N'  /* condition added by bgowrava for bug#5554420 */
      THEN --f999

        lv_statement_no := '11';
        /* commented here and moved out of this if condition. bgowrava for bug#5554420.
        v_old_register := NULL;
        v_old_excise_invoice_no := NULL;
        OPEN  get_prev_del_dtl(each_record.delivery_id);
        FETCH get_prev_del_dtl INTO v_old_register, v_old_excise_invoice_no;
        CLOSE get_prev_del_dtl;
        */

        fnd_file.put_line(
                             fnd_file.log,
                             p_delivery_id||', '||'15 v_old_register = ' || v_old_register
                             ||', v_old_excise_invoice_no = ' || v_old_excise_invoice_no
                         );

        IF v_old_register IS NULL THEN --e999
          v_reg_type       := NULL;
          v_rg_type        := NULL;
          v_exc_invoice_no := NULL;

          lv_statement_no := '12';


          /* modvat recovery was happening for last line only - bug # 3207685
          the following loop added for modvat recovery calculation.
          */
          for modvat_rec in c_get_modvat_records(
                                                               p_delivery_id      => each_record.delivery_id
                                                              )
          loop
             if modvat_rec.excise_Exempt_type in ('CT2_OTH', 'EXCISE_EXEMPT_CERT_OTH') then
                  OPEN  for_modvat_tax_rate(modvat_rec.delivery_detail_id);
                  FETCH for_modvat_tax_rate INTO v_modvat_tax_rate,v_rounding_factor;
                  CLOSE for_modvat_tax_rate;
                  v_mod_basic_ed_amt := nvl(v_mod_basic_ed_amt,0) + ( (modvat_rec.quantity * modvat_rec.assessable_value * v_modvat_tax_rate )/ 100 );
             else
               if modvat_rec.excise_exempt_type is not null then
                  OPEN  for_modvat_percentage(v_organization_id, v_location_id);
                  FETCH for_modvat_percentage INTO v_modvat_tax_rate;
                  CLOSE for_modvat_percentage;
                  v_mod_basic_ed_amt := nvl(v_mod_basic_ed_amt,0) + ( (modvat_rec.quantity * modvat_rec.assessable_value * v_modvat_tax_rate )/ 100 );
               end if;
             end if;
          end loop;



          OPEN get_total_excise_amt(
                                     p_delivery_id      => each_record.delivery_id ,
                                     cp_conversion_rate => v_converted_rate
                                   );

          FETCH get_total_excise_amt INTO v_tot_basic_ed_amt, v_tot_addl_ed_amt, v_tot_oth_ed_amt, v_tot_excise_amt;
          CLOSE get_total_excise_amt;


          fnd_file.put_line(
                                     fnd_file.log,
                                     p_delivery_id||', 17 v_tot_excise_amt = ' || v_tot_excise_amt
                                     ||', v_tot_basic_ed_amt = ' || v_tot_basic_ed_amt ||', v_tot_addl_ed_amt = ' || v_tot_addl_ed_amt
                                     ||', v_tot_oth_ed_amt = ' || v_tot_oth_ed_amt
                                     || ',v_mod_basic_ed_amt =' || v_mod_basic_ed_amt
                          );

          IF NVL(v_bonded_flag,'Y') = 'Y'            AND
            (
              nvl(v_tot_excise_amt,0) > 0            OR
              v_excise_exempt_type IS NOT NULL
            )
          THEN ---b999
            lv_statement_no := '13';
            --Changed by Nagaraj.s for Enh#2415656
            OPEN pref_cur(v_organization_id, v_location_id);
            FETCH pref_cur INTO  v_pref_rg23a, v_pref_rg23c, v_pref_pla,v_export_oriented_unit;
            CLOSE pref_cur;
            Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', '||'18 v_pref_rg23a = ' || v_pref_rg23a ||', v_pref_rg23c = ' || v_pref_rg23c ||', v_pref_pla = ' || v_pref_pla );

            lv_statement_no := '14';
            ----Changed by Nagaraj.s for Enh#2415656
            OPEN rg_bal_cur(v_organization_id, v_location_id);
            FETCH rg_bal_cur INTO v_rg23a_balance, v_rg23c_balance, v_pla_balance,
            v_basic_pla_balance,v_additional_pla_balance,v_other_pla_balance;
            CLOSE rg_bal_cur;

            Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', '||'19 v_rg23a_bala = ' || v_rg23a_balance ||', v_rg23c_bal = '
                || v_rg23c_balance ||', v_pla_balae = ' || v_pla_balance );

            lv_statement_no := '15';
            OPEN  ssi_unit_flag_cur(v_organization_id, v_location_id);
            FETCH ssi_unit_flag_cur INTO v_ssi_unit_flag;
            CLOSE ssi_unit_flag_cur;

            lv_statement_no := '16';

            /*
              Code modified by sriram - bug # 3021588.
              Calling the package jai_cmn_bond_register_pkg.GET_REGISTER_ID
            */

            jai_cmn_bond_register_pkg.GET_REGISTER_ID (    v_organization_id       ,
                                                     v_location_id   ,
                                                     v_order_type_id , -- order type id
                                                     'Y'                     , -- order invoice type
                                                     v_asst_register_id      , -- out parameter to get the register id
                                                     v_register_code
                                                ); -- out parameter for register code


             IF NVL(v_register_code,'N') IN ('DOMESTIC_EXCISE','EXPORT_EXCISE') THEN  ---a999
               IF NVL(v_excise_flag,'N') = 'Y' THEN
                 IF NVL(v_excise_exempt_type, '@@@') NOT IN (
                                                               'CT2',
                                                               'EXCISE_EXEMPT_CERT',
                                                               'CT2_OTH',
                                                               'EXCISE_EXEMPT_CERT_OTH',
                                                               'CT3'
                                                             ) THEN
                     --***************************************************************************************************
                     --Calling the Function by Nagaraj.s for Enh#2415656............................


                   open   c_cess_amount(p_delivery_id);
                   fetch  c_cess_amount into ln_cess_amount;
                   close  c_cess_amount;

       /* added by ssawant for bug 5989740 */
       open   c_sh_cess_amount(p_delivery_id);
                   fetch  c_sh_cess_amount into ln_sh_cess_amount;
                   close  c_sh_cess_amount;

                    v_reg_type:= jai_om_wsh_processing_pkg.excise_balance_check(
                                                             v_pref_rg23a                    ,
                                                             v_pref_rg23c                    ,
                                                             v_pref_pla                      ,
                                                             NVL(v_ssi_unit_flag,'N')        ,
                                                             v_tot_excise_amt                ,
                                                             v_rg23a_balance                 ,
                                                             v_rg23c_balance                 ,
                                                             v_pla_balance                   ,
                                                             v_basic_pla_balance             ,
                                                             v_additional_pla_balance        ,
                                                             v_other_pla_balance             ,
                                                             v_tot_basic_ed_amt              ,
                                                             v_tot_addl_ed_amt               ,
                                                             v_tot_oth_ed_amt                ,
                                                             v_export_oriented_unit          ,
                                                             v_register_code                 ,
                                                             p_delivery_id                   ,
                                                             v_organization_id               ,
                                                             v_location_id                   ,
                                                             ln_cess_amount                  ,
                   ln_sh_cess_amount         ,/* added by ssawant for bug 5989740 */
                                                             lv_process_flag                 ,
                                                             lv_process_message
                                                  );

                    fnd_file.put_line(fnd_file.log, p_delivery_id||', '||'18.1 The Value OF v_reg_type IS '|| v_reg_type);
                   --**************************************************************************************************************************
                 ELSE
                    IF v_item_class NOT IN ('OTIN', 'OTEX') THEN

                    open   c_cess_amount(p_delivery_id);
                    fetch  c_cess_amount into ln_cess_amount;
                    close  c_cess_amount;

         /* added by ssawant for bug 5989740 */
       open   c_sh_cess_amount(p_delivery_id);
                   fetch  c_sh_cess_amount into ln_sh_cess_amount;
                   close  c_sh_cess_amount;


                     v_reg_type := jai_om_wsh_pkg.get_excise_register_with_bal(
                                                                     v_pref_rg23a                    ,
                                                                     v_pref_rg23c                    ,
                                                                     v_pref_pla                      ,
                                                                     NVL(v_ssi_unit_flag,'N')        ,
                                                                     v_exempt_bal                    ,
                                                                     v_rg23a_balance                 ,
                                                                     v_rg23c_balance                 ,
                                                                     v_pla_balance                   ,
                                                                     v_basic_pla_balance             ,
                                                                     v_additional_pla_balance        ,
                                                                     v_other_pla_balance             ,
                                                                     v_tot_basic_ed_amt              ,
                                                                     v_tot_addl_ed_amt               ,
                                                                     v_tot_oth_ed_amt                ,
                                                                     v_export_oriented_unit          ,
                                                                     v_register_code                 ,
                                                                     p_delivery_id                   ,
                                                                     v_organization_id               ,
                                                                     v_location_id                   ,
                                                                     ln_cess_amount                  ,
                     ln_sh_cess_amount         ,/* added by ssawant for bug 5989740 */
                                                                     lv_process_flag                 ,
                                                                     lv_process_message
                               );
                     --Ends here......................................
                     -------------------------------------------------------------------------------------------------------------------
                     Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', '||'23 v_raise_exempt_flag = ' || v_raise_exempt_flag);
                     v_basic_ed_amt := v_exempt_bal;
                     v_tot_basic_ed_amt := NVL(v_tot_basic_ed_amt,0) + nvl(v_mod_basic_ed_amt,0) ; --+ v_exempt_bal; -- bug# 3207685
                     v_remarks := 'Against Modvat Recovery'||'-'||v_excise_exempt_refno;
                     --2001/11/01 Anuradha Parthasarathy
                     END IF;
                   END IF;
                 END IF;
               ELSIF NVL(v_register_code,'N') IN ('BOND_REG') THEN  --a999
                 v_bond_tax_amount := NVL(v_tot_excise_amt,0) + NVL(v_bond_tax_amount,0);
                 lv_statement_no := '20';

                 -- Following code modified by sriram.
                 -- call to the jai_cmn_bond_register_pkg is being done which
                 -- fetches the balances.
                 -- bug # 3021588
                 jai_cmn_bond_register_pkg.get_register_details
                 (v_asst_register_id,
                 v_register_balance,
                 v_register_exp_date,
                 v_lou_flag
                 );

                 if nvl(v_register_exp_date,sysdate) < sysdate then
                    Fnd_File.PUT_LINE(Fnd_File.LOG,'Error Occured - The Validity Period of the Bond Register ' || v_register_exp_date || '  has lapsed');
                    RAISE_APPLICATION_ERROR(-20121,'The Validity Period of the Bond Register has lapsed');
                 end if;


                 Fnd_File.PUT_LINE(Fnd_File.LOG,'LOU FLAG is ' || NVL(v_lou_flag,'N'));

                 Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', '||'24 v_bond_tax_amount = ' || v_bond_tax_amount||' , v_register_balance = ' || v_register_balance );

                 IF ( (nvl(v_lou_flag,'N') = 'N') and (NVL(v_register_balance,0) < NVL(v_tot_excise_amt,0)) )  THEN

                         Fnd_File.PUT_LINE(Fnd_File.LOG,'Error Occured - Bonded Register Has Balance -> ' || TO_CHAR(v_register_balance)
                                 || ' ,which IS less than Excisable Amount -> ' || TO_CHAR(v_tot_excise_amt));

                         RAISE_APPLICATION_ERROR(-20120, 'Bonded Register Has Balance -> ' || TO_CHAR(v_register_balance)
                                 || ' ,which IS less than Excisable Amount -> ' || TO_CHAR(v_tot_excise_amt));


                 END IF;
               END IF; ---a999
             END IF; ---b999

              /*
                Changed by aiyer for the bug #3071342
                As the excise invoice generation should not be done in case Domestic Without Excise for trading and manufacturing
                organizations and hence modified the if statement to call excise invoice generation procedure only in case where
                v_register_code is in   '23D_DOMESTIC_EXCISE'   ,'23D_EXPORT_EXCISE'     ,'DOMESTIC_EXCISE'       ,
               'EXPORT_EXCISE','BOND_REG'
                This would ensure that the excise invoice generation would not happen in case where v_register_code in
                'DOM_WITHOUT_EXCISE','23D_DOM_WITHOUT_EXCISE' i.e Domestic Without Excise for Trading and manufacturing organizations.
              */

             IF  (
                     (
                             NVL(v_bonded_flag,'N') =  'Y'            OR
                             NVL(v_trading_flag,'N') = 'Y'
                     )                                                AND
                     NVL(v_excise_flag,'N') = 'Y'                     AND
                     v_register_code IN(
                                         '23D_DOMESTIC_EXCISE'   ,
                                         '23D_EXPORT_EXCISE'     ,
                                         'DOMESTIC_EXCISE'       ,
                                         'EXPORT_EXCISE'         ,
                                         'BOND_REG'
                                        )
                  )
             THEN

               lv_statement_no := '21';
               OPEN  register_code_meaning_cur(v_register_code,'JAI_REGISTER_TYPE'); /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
               FETCH register_code_meaning_cur INTO v_meaning;
               CLOSE register_code_meaning_cur;
               Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', '||'25 v_meaning = ' || v_meaning);

               lv_statement_no := '22';
               OPEN   fin_year_cur(v_organization_id);
               FETCH  fin_year_cur INTO v_fin_year;
               CLOSE  fin_year_cur;

               /* excise invoice generation logic written in the procedure has been removed and instead a
                 call to the excise invoice generation procedure has been made
               */
    /*Bug 5403048 Start*/
    OPEN  c_excise_tax_rate(each_record.delivery_detail_id);
               FETCH c_excise_tax_rate INTO ln_total_tax_rate , ln_number_of_Taxes ;
               CLOSE c_excise_tax_rate;

               IF NVL(ln_number_of_Taxes,0) > 0 THEN /*Bug 5403048 End*/
               -- procedure call to the excise invoice number generation procedure added  by sriram bug # 2663211

               fnd_file.put_line(fnd_file.log,'Calling the Excise Invoice Generation procedure with following parameters ');
               fnd_file.put_line(fnd_file.log,' Organization_id => ' || v_organization_id || ' Location_id => ' || v_location_id);
               fnd_file.put_line(fnd_file.log,'Order Type id => ' || v_order_type_id || 'Fin Year => ' || v_fin_year);


               jai_cmn_setup_pkg.generate_excise_invoice_no(v_organization_id,v_location_id,'O',v_order_type_id,v_fin_year,v_exc_invoice_no,ERRBUF);

               fnd_file.put_line(fnd_file.log,'After Call to the procedure output values are following');
               fnd_file.put_line(fnd_file.log,'Excise Invoice Number generated => ' || v_exc_invoice_no);

               IF ERRBUF IS NOT NULL THEN
                  Fnd_File.PUT_LINE(Fnd_File.LOG,'Error Message in the excise invoice generation procedure is  => ' || ERRBUF);
                  retcode :=2; --to signal an error.
                  v_ret_stat := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',ERRBUF);
                  return;
               END IF;
               /* excise invoice has been generated for this delivery. hence set the flag to 'Y' */
                 lv_exc_inv_gen_for_dlry_flag := 'Y';  --added by csahoo for bug#6077065

    /*Bug 5403048 Start*/
    ELSE
                 Fnd_File.PUT_LINE(Fnd_File.LOG, 'Excise Invoice Not Generated for delivery_detail_id : ' || each_record.delivery_detail_id || ' since there are no Excise Taxes ');
               END IF;
    /*Bug 5403048 End*/
             END IF; --d999                                                                                  --1
           ELSE
             v_reg_type           := v_old_register;
             v_exc_invoice_no := v_old_excise_invoice_no;
             Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', '||'41  v_reg_type= ' ||v_reg_type);
             Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', '||'41  v_exc_invoice_no= ' ||v_exc_invoice_no);
           END IF; --e999
         END IF; --f999

         lv_statement_no := '29';

         /* if excise invoice has not been generated for this delivery.
                then set the value to null so that amount RG entry will not happen. bgowrava for Bug#5554420  */
                  if v_exc_invoice_no is null then
                     v_reg_type := null;
         end if;

         /*
         following if condition added by Sriram bug#2638797
         The reason is that , for trading organization and trading type of items ,
         the register to be hit is always RG23D , Before this fix , the register
         was not getting hit for a trading organization.
         */
         OPEN  bonded_cur(v_organization_id, v_subinventory);
         FETCH bonded_cur INTO v_bonded_flag,v_trading_flag;
         CLOSE bonded_cur;


         SELECT NVL(Item_Trading_Flag,'N') INTO V_item_trading_flag
                                         FROM JAI_INV_ITM_SETUPS
                                         WHERE organization_id = v_organization_id
                 AND inventory_item_id = v_inventory_item_id;

         if NVL(V_item_trading_flag,'N') = 'Y' and NVL(v_trading_flag,'N') = 'Y' then
                 v_reg_type := 'RG23D';
         end if;

         /* ends here - additional by sriram - bug#2638797 */

         /* Added by bgowrava for bug#5554420 */
         if NVL(ln_excise_tax_cnt,0) > 0
            and lv_exc_inv_gen_for_dlry_flag = 'Y'
         then

         UPDATE
               JAI_OM_WSH_LINES_ALL
         SET
               excise_invoice_no     = v_exc_invoice_no,
                excise_invoice_date   = TRUNC(v_actual_shipment_date), --replaced v_date for bug#7591616
               register              = DECODE(nvl(v_excise_exempt_type,'$$$'), 'CT3',NULL,v_reg_type), /*register should be updated as null incase of CT3 excise exemption  Bug 3446362*/
               order_line_id         = v_source_line_id_pick,  /*2001/09/13 Jagdish */
               --added the next 3 columns for Bug #3849638, as these were not updated previously
               last_update_date      = sysdate,
               last_updated_by       = v_last_updated_by,
               last_update_login     = v_last_update_login
         WHERE
               organization_id       = v_organization_id     AND
               location_id           = v_location_id        AND
               delivery_detail_id    = each_record.delivery_detail_id;
          end if;

          /*
          || Code added for the bug 4566054
          || Initialize the ln_del_det_totcess_amt variable to null;
          */

          ln_del_det_totcess_amt := null;
          ln_del_det_totshcess_amt := null; --added by Bgowrava for forward porting bug#5989740

         --Changed by Nagaraj.s on 21/05/2002 for Bug#2340750
         --Changes Done: In case of an order where Currency is changed apart from
         --Functional currency it is necessary that the excise register balances get
         --Updated with the Functional currency and not with the Currency as changed
         --in order. For this reason it has been taken care of that the excise amounts
         --which are hit will be first converted into Functional currency amount and then
         -- hits the registers.
         --The amounts which are taken care are: v_basic_ed_amt,v_oth_ed_amt,
         --v_addl_ed_amt, v_tot_basic_ed_amt .......................

         Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', '||'42  v_item_class= ' ||v_item_class);
         IF v_register_code IS NOT NULL AND NVL(v_bonded_flag,'N') = 'Y' THEN    --g999                  --1

           /*
           || Start of bug 4566054
           ||Code added by aiyer for the bug 4566054
           ||The cess amount is also being maintained in JAI_CMN_RG_I_TRXS table at a delivery_detail_level
           ||hence calculate the cess and pass it to the procedure jai_om_rg_pkg.ja_in_rg_i_entry with source as 'WSH'
           */

           OPEN  cur_get_del_det_cess_amt (cp_delivery_detail_id => each_record.delivery_detail_id);
           FETCH cur_get_del_det_cess_amt INTO ln_del_det_totcess_amt;
           CLOSE cur_get_del_det_cess_amt ;
           /* End of bug 4566054 */

           /*Bgowrava for forward porting bug#5989740, start*/
                OPEN  cur_get_del_det_sh_cess_amt (cp_delivery_detail_id => each_record.delivery_detail_id);
                FETCH cur_get_del_det_sh_cess_amt INTO ln_del_det_totshcess_amt;
                CLOSE cur_get_del_det_sh_cess_amt ;
            /*Bgowrava for forward porting bug#5989740, end*/

           IF v_item_class IN ('RMIN','RMEX','CGEX','CGIN','FGIN','FGEX','CCIN','CCEX')  THEN
             IF v_item_class IN ('FGIN','FGEX','CCIN','CCEX') THEN
               lv_statement_no := '30';

              /*
              || Code modified by aiyer for the fix of the bug #3158282
              || The basic , additional and others amount in the JAI_CMN_RG_I_TRXS table should be
              || should be rounded off
              */

              /*
              || Added by Ramananda. Start of bug#4543424
              */
               OPEN  c_excise_tax_rate(each_record.delivery_detail_id);
               FETCH c_excise_tax_rate INTO ln_total_tax_rate , ln_number_of_Taxes ;
               CLOSE c_excise_tax_rate;

               if NVL(ln_number_of_Taxes,0) = 0 then
                  ln_number_of_Taxes := 1;
               end if;

               v_tax_rate := ln_total_tax_rate / ln_number_of_Taxes;
              /*
              || Added by Ramananda. End of bug#4543424
              */

              /*
              || Start Additions by ssumaith - bug# 4185392
              */
                if nvl(v_assessable_value,0) <> 0 and nvl(v_shp_qty,0) <> 0 then
                  v_tax_rate := round(nvl(v_basic_ed_amt,0) / (v_assessable_value * v_shp_qty) * 100,2);
                end if;

              /*
              || Ends here additions by ssumaith - bug# 4185392
              */
               jai_om_rg_pkg.ja_in_rg_i_entry(
                                                v_fin_year                                      ,
                                                v_organization_id                               ,
                                                v_location_id                                   ,
                                                v_inventory_item_id                             ,
                                                33                                              ,
                                                  v_actual_shipment_date                          , --replaced v_date for bug#7591616
                                                'I'                                             ,
                                                each_record.delivery_detail_id                  ,
                                                v_shp_qty                                       ,
                                                v_excise_amount                                 ,
                                                v_uom_code                                      ,
                                                v_exc_invoice_no                                ,
                                                TRUNC(    v_actual_shipment_date)                          , --replaced v_date for bug#7591616
                                                v_reg_type                                      ,
                                                ROUND(v_basic_ed_amt * v_converted_rate)        ,
                                                ROUND(v_addl_ed_amt  * v_converted_rate)        ,
                                                ROUND(v_oth_ed_amt   * v_converted_rate)        ,
                                                v_tax_rate                                      ,
                                                v_customer_id                                   ,
                                                v_ship_to_org_id                                ,
                                                v_register_code                                 , /* Bug 4562791. Added by Lakshmi Gopalsami Commented creation_date and last_update_date and passing v_date v_creation_date  ,*/
                                                v_date                                          ,
                                                v_created_by                                    ,
                                                --v_last_update_date                            ,
                                                v_date                                          ,
                                                v_last_updated_by                               ,
                                                v_last_update_login                             ,
                                                v_assessable_value                              ,
                                                ln_del_det_totcess_amt                          , /*Parameters p_cess_amt and p_source added by aiyer for the bug 4566054 */
                                                ln_del_det_totshcess_amt  ,   --Bgowrava for forward porting bug#5989740
                                                jai_constants.source_wsh
                                            );

               lv_statement_no := '31';
               SELECT JAI_CMN_RG_I_TRXS_S.CURRVAL INTO v_part_i_register_id  FROM dual;
               Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', 42.1 ja_in_rg_I_entry is made register_id -> ' || v_part_i_register_id );
             ELSIF v_item_class IN ('CGEX','CGIN') THEN
               v_qty_reg_type := 'C';

             ELSIF v_item_class IN ('RMIN','RMEX') THEN
               v_qty_reg_type := 'A';
             END IF;

             IF v_item_class IN ('RMIN','RMEX','CGIN','CGEX') THEN
               lv_statement_no := '32';

               /*
                 Code modified by aiyer for the fix of the bug #3158282.
                 The basic , additional and others amount in the JAI_CMN_RG_23AC_I_TRXS table should be
                 should be rounded off
               */

                jai_om_rg_pkg.ja_in_rg23_part_i_entry(
                                                           v_qty_reg_type                                  ,
                                                           v_fin_year                                      ,
                                                           v_organization_id                               ,
                                                           v_location_id                                   ,
                                                           v_inventory_item_id                             ,
                                                           33                                              ,
                                                          v_actual_shipment_date                          , --replaced v_date for bug#7591616
                                                           'I'                                             ,
                                                           v_shp_qty                                       ,
                                                           v_uom_code                                      ,
                                                           v_exc_invoice_no                                ,
                                                           TRUNC(v_actual_shipment_date )                         , --replaced v_date for bug#7591616
                                                           ROUND(v_basic_ed_amt* v_converted_rate)         ,
                                                           ROUND(v_addl_ed_amt* v_converted_rate )         ,
                                                           ROUND(v_oth_ed_amt* v_converted_rate  )         ,
                                                           v_customer_id                                   ,
                                                           v_ship_to_org_id                                ,
                                                           each_record.delivery_detail_id                  ,
                                                          v_actual_shipment_date                          , --replaced v_date for bug#7591616
                                                           v_register_code                                 ,
                 /* Bug 4562791. Added by Lakshmi Gopalsami
                 Commented creation_date and last_update_date
                 and passing v_date
                 v_creation_date                                 ,*/
                 v_date                                          ,
                                                           v_created_by                                    ,
                                                           --v_last_update_date                            ,
                 v_date                                          ,
                                                           v_last_updated_by                               ,
                                                           v_last_update_login
                                                   );
                 lv_statement_no := '33';
                 SELECT JAI_CMN_RG_23AC_I_TRXS_S.CURRVAL INTO v_part_i_register_id FROM dual;
                 Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', 42.2 ja_in_rg23_part_I_entry is made, register_id -> ' || v_part_i_register_id );
               END IF;
             END IF;
       -- Start of Bug 3446362
             /*
               Added by aiyer for the bug 3446362.
               Check whether rows exist in the JAI_OM_WSH_LINES_ALL tables with excise exempt type other than CT3.
               Even records with null values are fine.
         If the count of rows with CT3 excise_exemption_type is greater than zero meaning
         some records are present which do not have CT3 excise exemption, then only in such a scenario let the
         amount registers be hit.
             */

       OPEN  c_ct3_flag_exists;
       FETCH c_ct3_flag_exists INTO ln_count;
       CLOSE c_ct3_flag_exists;

       fnd_file.put_line( fnd_file.log, p_delivery_id||', '||'44  v_old_delivery_id = ' ||v_old_delivery_id
                          ||', 45  v_old_register = ' ||v_old_register||', 46  v_reg_type = ' ||v_reg_type
                          ||', 47 value of ln_count '||ln_count
                        );

       IF (NVL(v_old_delivery_id,0) <> NVL(each_record.delivery_id,-1)
            or v_old_register IS NULL    /* added by bgowrava for forward porting Bug#5554420 to hit Amt register + avoid hitting the amount register multiple times*/
          )
       AND ln_count > 0
       AND v_exc_invoice_no is not null  /* added by bgowrava for forward porting Bug#5554420 to make sure that, amt register will be hit only if excise invoice number is not null */
       THEN
       -- End of Bug 3446362

              -- IF v_old_register IS NULL THEN /* commented here bgowrava for forward porting Bug#5554420 and moved to above IF condition*/
                 IF v_reg_type IN ('RG23A', 'RG23C') THEN
                   IF v_reg_type = 'RG23A' THEN
                     v_rg_type := 'A';
                   ELSE
                     v_rg_type := 'C';
                   END IF;
                   lv_statement_no := '34';
                   /*
                       Code modified by aiyer for the fix of the bug #3158282.
                       Shifted the conversion to INR currency and rounding off at the cursor level itself.
                       refer cursor  get_total_excise_amt.
                   */

                   jai_om_rg_pkg.ja_in_rg23_part_II_entry(
                                                               v_register_code                                 ,
                                                               v_rg_type                                       ,
                                                               v_fin_year                                      ,
                                                               v_organization_id                               ,
                                                               v_location_id                                   ,
                                                               v_inventory_item_id                             ,
                                                               33                                              ,
                                                              v_actual_shipment_date                          , --replaced v_date for bug#7591616
                                                               v_part_i_register_id                            ,
                                                               v_exc_invoice_no                                ,
                                                               TRUNC(v_actual_shipment_date)                          , --replaced v_date for bug#7591616
                                                               v_tot_basic_ed_amt                              , --2001/09/24 Vijay
                                                               v_tot_addl_ed_amt                               , --2001/09/24 Vijay
                                                               v_tot_oth_ed_amt                                ,  --2001/09/24 Vijay
                                                               v_customer_id                                   ,
                                                               v_ship_to_org_id                                ,
                                                               v_source_name                                   ,
                                                               v_category_name                                 ,
                     /* Bug 4562791. Added by Lakshmi Gopalsami
                     Commented creation_date and last_update_date
                     and passing v_date
                     v_creation_date                                 ,*/
                     v_date                                          ,
                                                               v_created_by                                    ,
                                                               --v_last_update_date                              ,
                     v_date                                          ,
                                                               v_last_updated_by                               ,
                                                               v_last_update_login                             ,
                                                               each_record.delivery_detail_id                  ,
                                                               v_excise_exempt_type                            ,
                                                               v_remarks                                       ,
                                                               v_ref_10                                        , -- bug # 2769440
                                                               v_ref_23                                        , -- bug # 2769440
                                                               v_ref_24                                        , -- bug # 2769440
                                                               v_ref_25                                        , -- bug # 2769440
                                                               v_ref_26                                          -- bug # 2769440
                                                             );

                   fnd_file.put_line(fnd_file.log, p_delivery_id||', 46.1 ja_in_rg23_part_II_entry is made, v_exc_invoice_no -> ' || v_exc_invoice_no );
                 ELSIF v_reg_type IN ('PLA') THEN
                   lv_statement_no := '35';

                  /*
                       Code modified by aiyer for the fix of the bug #3158282.
                       Shifted the conversion to INR currency and rounding off at the cursor level itself.
                       refer cursor  get_total_excise_amt.
                   */

                    jai_om_rg_pkg.ja_in_pla_entry(
                                                  v_organization_id                        ,
                                                  v_location_id                            ,
                                                  v_inventory_item_id                      ,
                                                  v_fin_year                               ,
                                                  33, each_record.delivery_detail_id       ,
                                                  v_actual_shipment_date                          , --replaced v_date for bug#7591616
                                                  v_exc_invoice_no                         ,
                                                  TRUNC(v_actual_shipment_date)                          , --replaced v_date for bug#7591616
                                                  v_tot_basic_ed_amt                       , --2001/09/24 Vijay
                                                  v_tot_addl_ed_amt                        , --2001/09/24 Vijay
                                                  v_tot_oth_ed_amt                         ,  --2001/09/24 Vijay
                                                  v_customer_id                            ,
                                                  v_ship_to_org_id                         ,
                                                  v_source_name                            ,
                                                  v_category_name                          ,
              /* Bug 4562791. Added by Lakshmi Gopalsami
              Commented creation_date and last_update_date
              and passing v_date
              v_creation_date                                 ,*/
              v_date                                   ,
                                                  v_created_by                             ,
                                                  --v_last_update_date                       ,
              v_date                                   ,
                                                  v_last_updated_by                        ,
                                                  v_last_update_login                      ,
                                                  v_ref_10                                 , -- bug # 2769440
                                                  v_ref_23                                 , -- bug # 2769440
                                                  v_ref_24                                 , -- bug # 2769440
                                                  v_ref_25                                 , -- bug # 2769440
                                                  v_ref_26                                   -- bug # 2769440
                                                 );
                   fnd_file.put_line(fnd_file.log, p_delivery_id||', 46.2 ja_in_pla_entry is made, v_exc_invoice_no -> ' || v_exc_invoice_no );
                 END IF;
             --  END IF; /* commented by bgowrava for forward porting Bug#5554420 */
             END IF;

             IF v_item_class IN ('FGIN','FGEX','CCIN','CCEX') and nvl(v_excise_exempt_type,'$$$') not in ('CT3') THEN -- sriram - bug# 3368475

               SELECT JAI_CMN_RG_I_TRXS_S.CURRVAL INTO v_rg23_part_i_no  FROM dual;
               IF v_reg_type IN( 'RG23A','RG23C') THEN
                 lv_statement_no := '36';
                 SELECT JAI_CMN_RG_23AC_II_TRXS_S.CURRVAL INTO v_rg23_part_ii_no FROM dual;
                 lv_statement_no := '37';
                 UPDATE
                        JAI_CMN_RG_I_TRXS
                 SET
                        register_id_part_ii = v_rg23_part_ii_no,
                        charge_account_id = (SELECT
                                                     charge_account_id
                                             FROM
                                                     JAI_CMN_RG_23AC_II_TRXS
                                             WHERE
                                                     register_id = v_rg23_part_ii_no
                                             )
                  WHERE
                        register_id = v_rg23_part_i_no;
               ELSIF v_reg_type IN( 'PLA') THEN
                 lv_statement_no := '38';
                 SELECT JAI_CMN_RG_PLA_TRXS_S1.CURRVAL INTO v_pla_register_no FROM dual;
                 lv_statement_no := '39';
                 UPDATE
                       JAI_CMN_RG_I_TRXS
                 SET
                       register_id_part_ii = v_pla_register_no,
                       charge_account_id   = (
                                               SELECT CHARGE_ACCOUNT_ID
                                               FROM
                                                     JAI_CMN_RG_PLA_TRXS
                                               WHERE
                                                     register_id = v_pla_register_no
                                             )
                 WHERE
                       register_id = v_rg23_part_i_no;
               END IF;

             ELSIF v_item_class IN ('RMIN','RMEX','CGIN','CGEX') and nvl(v_excise_exempt_type,'$$$') not in ('CT3') THEN -- sriram - bug# 3368475
               lv_statement_no := '40';
               SELECT JAI_CMN_RG_23AC_I_TRXS_S.CURRVAL INTO v_rg23_part_i_no  FROM dual;
               IF v_reg_type  IN( 'RG23A','RG23C')
               THEN
                 lv_statement_no := '41';
                 SELECT JAI_CMN_RG_23AC_II_TRXS_S.CURRVAL INTO v_rg23_part_ii_no FROM dual;
                 lv_statement_no := '42';
                 UPDATE  JAI_CMN_RG_23AC_I_TRXS
                         SET  REGISTER_ID_PART_II = v_rg23_part_ii_no,
                                 CHARGE_ACCOUNT_ID = (SELECT CHARGE_ACCOUNT_ID
                         FROM JAI_CMN_RG_23AC_II_TRXS
                         WHERE  register_id = v_rg23_part_ii_no)
                         WHERE  register_id = v_rg23_part_i_no;
               ELSIF v_reg_type IN( 'PLA') THEN
                 lv_statement_no := '43';
                 SELECT  JAI_CMN_RG_PLA_TRXS_S1.CURRVAL INTO v_pla_register_no FROM dual;
                 lv_statement_no := '44';
                 UPDATE
                           JAI_CMN_RG_23AC_I_TRXS
                 SET
                           REGISTER_ID_PART_II = v_pla_register_no,
                           charge_account_id = (
                                                 SELECT
                                                           charge_account_id
                                                 FROM      JAI_CMN_RG_PLA_TRXS
                                                 WHERE
                                                           register_id = v_pla_register_no
                                               )
                 WHERE  register_id = v_rg23_part_i_no;
               END IF;
             END IF;

             fnd_file.put_line(fnd_file.log, p_delivery_id||', 46.3 v_rg23_part_ii_no -> ' || v_rg23_part_ii_no||', v_pla_register_no -> ' || v_pla_register_no );
             --2001/04/09 Manohar Mishra
             --Changed the cases
           IF NVL(v_register_code,'N') IN ('BOND_REG') AND
              NVL(v_old_delivery_id,0) <> NVL(each_record.delivery_id,-1)  -- bug2389773 cbabu 24/02/2002. new check added
           THEN
             lv_statement_no := '45';

                  /*
                       Code modified by aiyer for the fix of the bug #3158282.
                       Shifted the conversion to INR currency and rounding off at the cursor level itself.
                       refer cursor  get_total_excise_amt.
                   */

             jai_om_rg_pkg.ja_in_register_txn_entry(
                                                     v_organization_id                               ,
                                                     v_location_id                                   ,
                                                     v_exc_invoice_no                                ,
                                                     'BOND SALES'                                    ,
                                                     'Y'                                             ,
                                                     each_record.delivery_id                         , /* changed from order header id to delivery id for CESS bug - SSUMAITH - bug#4136981 */
                                                     v_tot_excise_amt                                ,  --Jagdish 15-Jun-01
                                                     'BOND_REG'                                      ,
                 /* Bug 4562791. Added by Lakshmi Gopalsami
                 Commented creation_date and last_update_date
                 and passing v_date
                 v_creation_date                                 ,*/
                 v_date                                          ,
                 v_created_by                                    ,
                                                     --v_last_update_date                              ,
                 v_Date                                          ,
                                                     v_last_updated_by                               ,
                                                     v_last_update_login
                                                 );
           END IF;
         END IF; --g999          --1

           -- Altered by Arun For Incorporating TRADING CODE ON 31 OCT 2000 at 1:45
           lv_statement_no := '46';
           OPEN  Trading_register_code_cur(v_organization_id, v_location_id, each_record.delivery_detail_id, v_order_type_id);
           FETCH Trading_register_code_cur INTO v_Trad_register_code;
           CLOSE Trading_register_code_cur;

           IF v_Trad_register_code IS NOT NULL THEN        --added by Gaurav.
                   v_register_code := v_Trad_register_code;
           END IF;

           lv_statement_no := '47';
           SELECT NVL(Item_Trading_Flag,'N') INTO V_item_trading_flag
                   FROM JAI_INV_ITM_SETUPS
                   WHERE organization_id = v_organization_id
                   AND inventory_item_id = v_inventory_item_id;

           lv_statement_no := '48';
           OPEN  bonded_cur(v_organization_id, v_subinventory);
           FETCH bonded_cur INTO v_bonded_flag, v_trading_flag;
           CLOSE bonded_cur;

           Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', 48.1 v_register_code -> ' || v_register_code
             ||', v_trading_flag -> ' || v_trading_flag ||', v_item_trading_flag -> ' || v_item_trading_flag
           );

           /*
              Code modified by aiyer for the bug 3032569
              The Excise Invoice number is being generated for non excisable RG23D transactions.
              This needs to be stopped for Trading Domestic Without Excise and Export Without excise scenario's.
              Modified the IF statment to remove the check that the trading register_codes should be in
              '23D_DOM_WITHOUT_EXCISE' and '23D_EXPORT_WITHOUT_EXCISE'.
           */

            -- Start of Bug #3032569
            IF v_register_code IN(
                                   '23D_DOMESTIC_EXCISE'           ,
                                   '23D_EXPORT_EXCISE'
                                 ) THEN  --y999


              IF NVL(v_trading_flag,'N') = 'Y' THEN
                IF NVL(V_item_trading_flag,'N') = 'Y' THEN

                  -- Start, cbabu for Bug# 2736191
                  lv_statement_no := '55';
                  OPEN  header_id (each_record.delivery_detail_id) ;
                  FETCH header_id INTO v_source_line_id, v_source_header_id;
                  CLOSE header_id;

                  lv_statement_no := '56';
                  OPEN  matched_receipt_cur(each_record.delivery_detail_id);
                  FETCH matched_receipt_cur INTO v_receipt_id, v_quantity_applied;
                  CLOSE matched_receipt_cur;

                  lv_statement_no := '57';
                  OPEN  ship_bill_cur(v_source_header_id);
                  FETCH ship_bill_cur INTO v_invoice_to_site_use_id, v_ship_to_site_use_id;
                  CLOSE ship_bill_cur;
                  -- End, cbabu for Bug# 2736191

                  lv_statement_no := '53';
                  UPDATE JAI_CMN_MATCH_RECEIPTS
                          SET ship_status='CLOSED'
                  WHERE ref_line_id = each_record.delivery_detail_id
                  AND ORDER_INVOICE = 'O';                -- cbabu for Bug# 2736191

                  -- cbabu for Bug# 2736191
                  v_proportionate_rpu := 0;
                  v_proportionate_edr := 0;
                  v_total_quantity_applied := 0;
                  v_total_base_duty_amount := 0;
                  v_total_rate := 0;

                  FOR match_rec IN matched_receipt_cur(each_record.delivery_detail_id) LOOP  -- cbabu for Bug# 2736191

                    Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||', 49.1 quantity_applied -> ' || match_rec.quantity_applied
                            ||', receipt_id -> ' || match_rec.receipt_id
                    );

                    lv_statement_no := '58';
                    OPEN  qty_to_adjust_cur(match_rec.receipt_id);
                    FETCH qty_to_adjust_cur INTO v_qty_to_adjust, v_excise_duty_rate, v_rate_per_unit,v_qnty_received; --modified for bug#5735284
                    CLOSE qty_to_adjust_cur ;

                    v_total_rate := v_total_rate + (v_rate_per_unit * match_rec.quantity_applied);
                     /* Added the check for zero excise duty rate by JMEENA, Bug# 7043292 */
                    IF NVL(v_excise_duty_rate,0) <> 0 THEN
                    v_total_base_duty_amount := v_total_base_duty_amount +
                                    ((v_rate_per_unit/v_excise_duty_rate) * match_rec.quantity_applied );
        END IF;
                    --End bug 7043292
                    v_total_quantity_applied := v_total_quantity_applied + match_rec.quantity_applied;

                    fnd_file.put_line(fnd_file.log, p_delivery_id||', 49.2 v_register_id -> ' || v_register_id
                            ||', v_exc_invoice_no -> ' || v_exc_invoice_no||', v_receipt_id -> ' || v_receipt_id
                            ||', v_quantity_applied -> ' || v_quantity_applied||', v_qty_to_adjust -> ' || v_qty_to_adjust
                            ||', v_excise_duty_rate -> ' || v_excise_duty_rate||', v_rate_per_unit -> ' || v_rate_per_unit
                            ||', v_source_line_id -> ' || v_source_line_id||', v_source_header_id -> ' || v_source_header_id
                    );
                    lv_statement_no := '60';

                    jai_cmn_rg_23d_trxs_pkg.upd_receipt_qty_matched(match_rec.receipt_id, match_rec.quantity_applied, v_qty_to_adjust);
                    -- END IF; --2002/02/20 Vijay
                    --added for bug#5735284 ,start
                    OPEN  get_duty_amt_cur(match_rec.receipt_id);
                    FETCH get_duty_amt_cur INTO rec_get_duty_amt;
                    CLOSE get_duty_amt_cur ;
                    v_tot_duty_amt := v_tot_duty_amt + round((nvl(rec_get_duty_amt.duty_amount,0)* match_rec.quantity_applied/v_qnty_received),2);
                    v_tot_cvd_amt := v_tot_cvd_amt + round((nvl(rec_get_duty_amt.cvd,0)* match_rec.quantity_applied/v_qnty_received),2);
                    v_tot_addl_cvd_amt := v_tot_addl_cvd_amt + round((nvl(rec_get_duty_amt.additional_cvd,0)* match_rec.quantity_applied/v_qnty_received),2);
                    v_tot_basic_ed_amt := v_tot_basic_ed_amt + round((nvl(rec_get_duty_amt.basic_ed,0)* match_rec.quantity_applied/v_qnty_received),2);
                    v_tot_addl_ed_amt := v_tot_addl_ed_amt + round((nvl(rec_get_duty_amt.additional_ed,0)* match_rec.quantity_applied/v_qnty_received),2);
                    v_tot_oth_ed_amt := v_tot_oth_ed_amt + round((nvl(rec_get_duty_amt.other_ed,0)* match_rec.quantity_applied/v_qnty_received),2);
                    --added for bug#5735284  ,end
                  END LOOP;

                  -- Start, cbabu for Bug# 2736191
                  /*
      ||  bug#7043292, JMEENA
      ||  if v_total_base_duty_amount is zero then divide by zero exception is raised.
      ||  To avoid this exception a check is made here so that if v_tota_base_duty_amount
      ||  is zero then v_proportionate_edr is not calculated and if v_total_quantity_applied is zero then v_proportionate_rpu is not calculated.
                  */

                  IF v_total_base_duty_amount <> 0 THEN
                    v_proportionate_edr := v_total_rate / v_total_base_duty_amount;
                  END IF;

                  IF v_total_quantity_applied <> 0 THEN
                    v_proportionate_rpu := v_total_rate / v_total_quantity_applied;
      END IF;

      --END 7043292
                  lv_statement_no := '54';
                  SELECT JAI_CMN_RG_23D_TRXS_S.NEXTVAL INTO v_register_id FROM Dual;

                  lv_statement_no := '59';

                  jai_om_rg_pkg.Ja_In_Rg23d_Entry(
                                                         v_register_id                                   ,
                                                         v_organization_id                               ,
                                                         v_location_id                                   ,
                                                         v_fin_year                                      ,
                                                         'I'                                             ,
                                                         v_inventory_item_id                             ,
                                                         each_record.delivery_detail_id                  ,
                                                         v_uom_code                                      ,
                                                         v_uom_code                                      ,
                                                         v_customer_id                                   ,
                                                         v_invoice_to_site_use_id                        ,
                                                         v_ship_to_site_use_id                           ,
                                                         v_total_quantity_applied                        ,
                                                         v_register_code                                 ,
                                                         v_proportionate_rpu                             ,
                                                         v_proportionate_edr                             ,
                                                         v_excise_amount * v_converted_rate              ,
                                                         NULL                                            ,
                                                         v_source_name                                   ,
                                                         v_category_name                                 ,
                                                         NULL                                            ,
                                                         NULL                                            ,
               /* Bug 4562791. Added by Lakshmi Gopalsami
               Commented creation_date and last_update_date
               and passing v_date
               v_creation_date                                 ,*/
               v_date                                          ,
                                                         v_created_by                                    ,
               --v_last_update_date                              ,
               v_date                                          ,
                                                         v_last_update_login                             ,
                                                         v_last_updated_by                               ,
                                                         --added for bug#6199766 ,start
                                                         v_tot_basic_ed_amt                              ,
                                                         v_tot_addl_ed_amt                               ,
                                                         v_tot_oth_ed_amt  ,
                                                       --added for bug#6199766 ,end
                                                         v_exc_invoice_no                                ,
                                                          TRUNC(v_actual_shipment_date)                          ,--replaced v_date for bug#7591616
                                                         v_ref_10                                        , -- bug # 2769440
                                                         v_ref_23                                        , -- bug # 2769440
                                                         v_ref_24                                        , -- bug # 2769440
                                                         v_ref_25                                        , -- bug # 2769440
                                                         v_ref_26,  -- bug # 2769440
                                                         v_tot_cvd_amt,
                                                        - v_tot_addl_cvd_amt  /*Added by nprashar for bug # 5735284 */
                                                    );



                                         -- End , cbabu for Bug# 2736191

                END IF;
              END IF;
            END IF;   --y999
      -- cbabu for Bug# 2803409
      -- This statement got deleted with Bug# 2736191
      lv_statement_no := '61';
      DELETE JAI_OM_OE_GEN_TAXINV_T WHERE delivery_detail_id = each_record.delivery_detail_id;

      v_bonded_flag    := 'N'      ;
      v_trading_flag   := 'N'      ;
      v_rg23a_balance  := 0        ;
      v_rg23c_balance  := 0        ;
      v_pla_balance    := 0        ;

      IF NVL(v_old_delivery_id,0) <> NVL(each_record.delivery_id,-1) THEN
        v_old_delivery_id := each_record.delivery_id;
      END IF;
    END IF;  --z999
    v_no_records_fetched := v_no_records_fetched + 1;

  END LOOP;
           --added by cbabu 27/03/02
           lv_statement_no := '62';
           --COMMIT;
           fnd_file.put_line( fnd_file.log,
                              p_delivery_id||', '||'61  v_no_records_fetched = '||v_no_records_fetched
                              ||',  END OF deliver_id = '||p_delivery_id
                            );

EXCEPTION
  WHEN OTHERS THEN
    DECLARE
      ln_created_by           NUMBER ; /* added by aiyer for the bug 4765347*/
      ln_last_update_login    NUMBER ; /* added by aiyer for the bug 4765347*/

    BEGIN
      /*
      ||added by aiyer for the bug 4765347
      */
      ln_created_by         :=  fnd_global.user_id       ;
      ln_last_update_login  :=  fnd_global.conc_login_id ;

    ROLLBACK;
      lv_error_mesg := SQLERRM;
      ERRBUF := lv_error_mesg;
      RETCODE := '2';
      Fnd_File.PUT_LINE(Fnd_File.LOG, p_delivery_id||' Error occured =  ' || lv_error_mesg);
      INSERT INTO JAI_CMN_ERRORS_T (
                                                APPLICATION_SOURCE          ,
                                                error_message           ,
                                                additional_error_mesg   ,
                                                creation_date           ,
                                                created_by              ,
                                                last_updated_by         ,
                                                last_update_date        ,
                                                last_update_login
                                          )
                                  VALUES  (
                                                lv_procedure_name       ,
                                                lv_error_mesg           ,
                                                'EXCEPTION captured BY WHEN OTHERS IN the PROCEDURE. BLOCK No/STATEMENT No:' || lv_block_no || '/' || lv_statement_no,
                                                v_date                 ,
                                                ln_created_by          ,
                                                ln_created_by          , /* added by aiyer for the bug 4765347*/
                                                v_date                 ,/* added by aiyer for the bug 4765347*/
                                                ln_last_update_login    /* added by aiyer for the bug 4765347*/
                                          );
      COMMIT;
    END ;
END process_delivery;


FUNCTION get_excise_register_with_bal
(
  p_pref_rg23a                NUMBER    ,
  p_pref_rg23c                NUMBER    ,
  p_pref_pla in               NUMBER    ,
  p_ssi_unit_flag             VARCHAR2  ,
  p_exempt_amt                NUMBER    ,
  p_rg23a_balance             NUMBER    ,
  p_rg23c_balance             NUMBER    ,
  p_pla_balance               NUMBER    ,
  p_basic_pla_balance         NUMBER    ,
  p_additional_pla_balance    NUMBER    ,
  p_other_pla_balance         NUMBER    ,
  p_basic_excise_duty_amount  NUMBER    ,
  p_add_excise_duty_amount    NUMBER    ,
  p_oth_excise_duty_amount    NUMBER    ,
  p_export_oriented_unit      VARCHAR2  ,
  p_register_code             VARCHAR2  ,
  p_delivery_id               NUMBER    ,
  p_organization_id           NUMBER    ,
  p_location_id               NUMBER    ,
  p_cess_amount               NUMBER    ,
  p_sh_cess_amount            NUMBER,  /* added by ssawant for bug 5989740 */
  p_process_flag   OUT NOCOPY VARCHAR2  ,
  p_process_msg    OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2
is

    --Variable Declaration starts here................
    v_pref_rg23a               JAI_CMN_INVENTORY_ORGS.pref_rg23a%type;
    v_pref_rg23c               JAI_CMN_INVENTORY_ORGS.pref_rg23c%type;
    v_pref_pla                 JAI_CMN_INVENTORY_ORGS.pref_pla%type;
    v_ssi_unit_flag            JAI_CMN_INVENTORY_ORGS.ssi_unit_flag%type;
    v_reg_type                 varchar2(10);
    v_exempt_amt               number;
    v_rg23a_balance            number;
    v_rg23c_balance            number;
    v_pla_balance              number;
    v_output                   number;
    v_basic_pla_balance        number;
    v_additional_pla_balance   number;
    v_other_pla_balance        number;
    v_basic_excise_duty_amount number;
    v_add_excise_duty_amount   number;
    v_oth_excise_duty_amount   number;
    v_export_oriented_unit     JAI_CMN_INVENTORY_ORGS.export_oriented_unit%type;
    v_register_code            JAI_OM_OE_BOND_REG_HDRS.register_code%type;
    v_debug_flag               varchar2(1); --  := 'N'; --Ramananda for File.Sql.35
    v_utl_location             VARCHAR2(512); --For Log file.
    v_myfilehandle             UTL_FILE.FILE_TYPE; -- This is for File handling
    v_trip_id                  wsh_delivery_trips_v.trip_id%type;
    lv_process_flag            VARCHAR2(2);
    lv_process_message         VARCHAR2(1996);
    lv_register_type           VARCHAR2(5);
    lv_rg23a_cess_avlbl        VARCHAR2(10);
    lv_rg23c_cess_avlbl        VARCHAR2(10);
    lv_pla_cess_avlbl          VARCHAR2(10);
    lv_rg23a_sh_cess_avlbl        VARCHAR2(10); /* added by ssawant for bug 5989740 */
    lv_rg23c_sh_cess_avlbl        VARCHAR2(10); /* added by ssawant for bug 5989740 */
    lv_pla_sh_cess_avlbl          VARCHAR2(10); /* added by ssawant for bug 5989740 */

    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_wsh_pkg.get_excise_register_with_bal';


    --Variable Declaration Ends here......................

BEGIN
/*------------------------------------------------------------------------------------------
   FILENAME: get_excise_register_with_bal_F.sql
   CHANGE HISTORY:

    1.  2002/07/03   Nagaraj.s - For Enh#2415656.
                     Function created for checking the register preferences in case of an Non-
                     Export Oriented Unit and in case of an Export Oriented Unit, the component
                     balances are checked and if balances does not exist, the function will raise an
                     application error and if balances exists, then the function will return the register
                     type. This Function is called from ja_in_wsh_dlry_dtls_au_trg.sql and jai_om_wsh_pkg.process_delivery.sql.
                     This Function is a prerequisite patch with the above mentioned trigger and procedure.
                     Also Alter table scripts with this patch should be available before sending this patch.
                     Otherwise the patch would certainly fail.

    2.  2003/03/13   Sriram . Bug # 2796717
                     Cenvat Reversal Accounting was not happening correctly.The reason was that if PLA is the
                     preference , the call to the ja_in_pla_entry procedure of the jai_om_rg_pkg is being called.
                     The PLA Entry does not consider different accounting for Excise Exempted transaction.
                     This is the desired functionality . Hence added code to see that , if balance is available in
                     the RG23A register , then hit the register and the accounting happens correctly for
                     excise exempted transactions.If balances are not available for RG23A register , then
                     take the normal code path , if PLA is hit , then accounting for exempted transaction does not
                     happen as it is documented.

   3.  2005/02/11    ssumaith - bug# 4171272 - File version 115.1

                        Shipment needs to be stopped if education cess is not available. This has been
                        coded in this function. Five new parameters have been added to the function , hence it introduces
                        dependency.

                        The basic business logic validation is that both cess and excise should be available as
                        part of the same register type and the precedence setup at the organization additional information
                        needs to be considered for picking up the correct register order.

                        These functions returns the register only if excise balance and cess balance is enough to
                        cover the current transaction.
                        Signature of the function has been changed because we needed to pass the additional
                        parameters fo comparision.

                        Dependency Due to this bug:
                          Please include all objects of the patch 4171272 along with this object whenever changed,
                          because of change in object signature.

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version                     Current Bug    Dependent           Files                               Version          Author   Date         Remarks
Of File                                            On Bug/Patchset     Dependent On
get_excise_register_with_bal_f.sql
----------------------------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------*/
    v_pref_rg23a                 := p_pref_rg23a;
    v_pref_rg23c                 := p_pref_rg23c;
    v_pref_pla                   := p_pref_pla;
    v_ssi_unit_flag              := p_ssi_unit_flag;
    v_exempt_amt                 := p_exempt_amt;
    v_rg23a_balance              := p_rg23a_balance;
    v_rg23c_balance              := p_rg23c_balance;
    v_pla_balance                := p_pla_balance;
    v_basic_pla_balance          := p_basic_pla_balance;
    v_additional_pla_balance     := p_additional_pla_balance;
    v_other_pla_balance          := p_other_pla_balance;
    v_basic_excise_duty_amount   := p_basic_excise_duty_amount;
    v_add_excise_duty_amount     := p_add_excise_duty_amount;
    v_oth_excise_duty_amount     := p_oth_excise_duty_amount;
    v_export_oriented_unit       := p_export_oriented_unit;
    v_register_code              := p_register_code;

    v_debug_flag               := jai_constants.no; --Ramananda for File.Sql.35

    If v_debug_flag = 'Y' THEN
      --For Fetching UTIL File.......
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
    END IF;

    IF v_debug_flag = 'Y' THEN
      v_myfilehandle := UTL_FILE.FOPEN(v_utl_location,'get_excise_register_with_bal_f.log','A');
      UTL_FILE.PUT_LINE(v_myfilehandle,'************************Start************************************');
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Time Stamp this Entry is Created is ' ||TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'));
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_pref_rg23a is ' || v_pref_rg23a);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_pref_rg23c is ' || v_pref_rg23c);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_pref_pla is ' || v_pref_pla);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_rg23a_balance is ' ||v_rg23a_balance);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_rg23c_balance is ' ||v_rg23c_balance);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_pla_balance is ' ||v_pla_balance);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_ssi_unit_flag is ' ||v_ssi_unit_flag);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_exempt_amt is ' ||v_exempt_amt);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_basic_pla_balance is ' ||v_basic_pla_balance);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_additional_pla_balance is ' ||v_additional_pla_balance);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_other_pla_balance is ' ||v_other_pla_balance);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_basic_excise_duty_amount is ' ||v_basic_excise_duty_amount);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_add_excise_duty_amount is ' ||v_add_excise_duty_amount);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_oth_excise_duty_amount is ' ||v_oth_excise_duty_amount);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_export_oriented_unit is '   || v_export_oriented_unit);
      UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_register_code is '   || v_register_code);
    END IF;
-----------------------------------------------------------------------------------------------------------------
    BEGIN
       --Balance Validations if Eou is No.....
       -- code written by sriram - for cenvat reversals in case of excise exempted transaction  bug # 2796717

       lv_register_type := 'RG23A';

           /*
            Check Balances procedure returns 'SS' if balance is available for organization + location + register type
            combination for the input cess amount.
           */
           jai_cmn_rg_others_pkg.check_balances(
                                            p_organization_id   =>  p_organization_id ,
                                            p_location_id       =>  p_location_id     ,
                                            p_register_type     =>  lv_register_type  ,
                                            p_trx_amount        =>  p_cess_amount     ,
                                            p_process_flag      =>  lv_process_flag   ,
                                            p_process_message   =>  lv_process_message
                                           );

          if  lv_process_flag <> jai_constants.successful then
              lv_rg23a_cess_avlbl := 'FALSE';
          else
              lv_rg23a_cess_avlbl := 'TRUE';
          end if;
    /* added by ssawant for bug 5989740 */
    jai_cmn_rg_others_pkg .check_sh_balances(
                                            p_organization_id   =>  p_organization_id ,
                                            p_location_id       =>  p_location_id     ,
                                            p_register_type     =>  lv_register_type  ,
                                            p_trx_amount        =>  p_sh_cess_amount     ,
                                            p_process_flag      =>  lv_process_flag   ,
                                            p_process_message   =>  lv_process_message
                                           );

          if  lv_process_flag <> jai_constants.successful then
              lv_rg23a_sh_cess_avlbl := 'FALSE';
          else
              lv_rg23a_sh_cess_avlbl := 'TRUE';
          end if;


          lv_register_type := 'RG23C';
          jai_cmn_rg_others_pkg.check_balances(
                                           p_organization_id   =>  p_organization_id ,
                                           p_location_id       =>  p_location_id     ,
                                           p_register_type     =>  lv_register_type  ,
                                           p_trx_amount        =>  p_cess_amount     ,
                                           p_process_flag      =>  lv_process_flag   ,
                                           p_process_message   =>  lv_process_message
                                          );

          if  lv_process_flag <> jai_constants.successful then
              lv_rg23c_cess_avlbl := 'FALSE';
          else
              lv_rg23c_cess_avlbl := 'TRUE';
          end if;

      /* added by ssawant for bug 5989740 */
               jai_cmn_rg_others_pkg .check_sh_balances(
                                            p_organization_id   =>  p_organization_id ,
                                            p_location_id       =>  p_location_id     ,
                                            p_register_type     =>  lv_register_type  ,
                                            p_trx_amount        =>  p_sh_cess_amount     ,
                                            p_process_flag      =>  lv_process_flag   ,
                                            p_process_message   =>  lv_process_message
                                           );

          if  lv_process_flag <> jai_constants.successful then
              lv_rg23a_sh_cess_avlbl := 'FALSE';
          else
              lv_rg23a_sh_cess_avlbl := 'TRUE';
          end if;


         lv_register_type := 'PLA';
         jai_cmn_rg_others_pkg.check_balances(
                                          p_organization_id   =>  p_organization_id ,
                                          p_location_id       =>  p_location_id     ,
                                          p_register_type     =>  lv_register_type  ,
                                          p_trx_amount        =>  p_cess_amount     ,
                                          p_process_flag      =>  lv_process_flag   ,
                                          p_process_message   =>  lv_process_message
                                         );

        if  lv_process_flag <> jai_constants.successful then
            lv_pla_cess_avlbl := 'FALSE';
        else
            lv_pla_cess_avlbl := 'TRUE';
        end if;
      /* added by ssawant for bug 5989740 */
             jai_cmn_rg_others_pkg .check_sh_balances(
                                            p_organization_id   =>  p_organization_id ,
                                            p_location_id       =>  p_location_id     ,
                                            p_register_type     =>  lv_register_type  ,
                                            p_trx_amount        =>  p_sh_cess_amount     ,
                                            p_process_flag      =>  lv_process_flag   ,
                                            p_process_message   =>  lv_process_message
                                           );

          if  lv_process_flag <> jai_constants.successful then
              lv_rg23a_sh_cess_avlbl := 'FALSE';
          else
              lv_rg23a_sh_cess_avlbl := 'TRUE';
          end if;

       IF v_rg23a_balance >= NVL(v_exempt_amt,0) THEN
          if lv_rg23a_cess_avlbl = 'TRUE' and lv_rg23a_sh_cess_avlbl = 'TRUE' then
             v_reg_type := 'RG23A';
             RETURN(v_reg_type);
          end if;
       END IF;

       -- ends here code by added by sriram .- bug # 2796717
       IF v_export_oriented_unit = 'N' Then
          IF v_pref_rg23a = 1   THEN    -------------------------------------------------------7
             IF v_rg23a_balance >= NVL(v_exempt_amt,0) AND lv_rg23a_cess_avlbl = 'TRUE' AND lv_rg23a_sh_cess_avlbl = 'TRUE' THEN ---------------------------8/* added by ssawant for bug 5989740 */
                   v_reg_type := 'RG23A';
             ELSIF v_pref_rg23c = 2 THEN
                IF v_rg23c_balance >= NVL(v_exempt_amt,0) AND lv_rg23c_cess_avlbl = 'TRUE' and lv_rg23c_sh_cess_avlbl='TRUE'  THEN ------------------9/* added by ssawant for bug 5989740 */
                   v_reg_type := 'RG23C';
                ELSIF v_pref_pla =3 THEN
                   IF v_pla_balance >= NVL(v_exempt_amt,0) AND lv_pla_cess_avlbl = 'TRUE'  AND lv_pla_sh_cess_avlbl = 'TRUE'  THEN --------------10/* added by ssawant for bug 5989740 */
                      v_reg_type := 'PLA';
                   ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN
                      v_reg_type  := 'PLA';
                   ELSE
                      v_reg_type := 'ERROR';
                   END IF;--------------------------------------------------------10
                ELSE
                   v_reg_type := 'ERROR';
                END IF;---------------------------------------------------------------9
             ELSIF v_pref_pla = 2 THEN
               IF v_pla_balance >= NVL(v_exempt_amt,0) AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl = 'TRUE'  THEN -------------------11/* added by ssawant for bug 5989740 */
                  v_reg_type := 'PLA';
               ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN
                  v_reg_type  := 'PLA';
               ELSIF v_pref_rg23c = 3 THEN
                  IF v_rg23c_balance >= NVL(v_exempt_amt,0) AND lv_rg23c_cess_avlbl = 'TRUE' AND lv_rg23c_sh_cess_avlbl = 'TRUE' THEN  ----------12/* added by ssawant for bug 5989740 */
                     v_reg_type := 'RG23C';
                  ELSE
                     v_reg_type := 'ERROR';
                  END IF;--------------------------------------------------------12
               ELSE
                  v_reg_type    := 'ERROR';
               END IF;------------------------------------------------------------ 11
             ELSE
               v_reg_type           :='ERROR';
             END IF;------------------------------------------------------------------8
-------------------------------------------------------------------------------------------------------------------
       ELSIF v_pref_rg23c = 1   THEN    -------------------------------------------------------7
         IF v_rg23c_balance >= NVL(v_exempt_amt,0) AND lv_rg23c_cess_avlbl = 'TRUE' AND lv_rg23c_sh_cess_avlbl = 'TRUE'  THEN ---------------------------8/* added by ssawant for bug 5989740 */
            v_reg_type := 'RG23C';
         ELSIF v_pref_rg23a = 2 THEN
            IF v_rg23a_balance >= NVL(v_exempt_amt,0) AND lv_rg23a_cess_avlbl = 'TRUE'  AND lv_rg23a_sh_cess_avlbl = 'TRUE' THEN ------------------9/* added by ssawant for bug 5989740 */
               v_reg_type := 'RG23A';
            ELSIF v_pref_pla =3 THEN
               IF v_pla_balance >= NVL(v_exempt_amt,0) AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl = 'TRUE' THEN --------------10/* added by ssawant for bug 5989740 */
                     v_reg_type := 'PLA';
               ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN
                  v_reg_type  := 'PLA';
               ELSE
                  v_reg_type := 'ERROR';
               END IF;--------------------------------------------------------10
            ELSE
               v_reg_type := 'ERROR';
            END IF;---------------------------------------------------------------9
         ELSIF v_pref_pla = 2 THEN
            IF v_pla_balance >= NVL(v_exempt_amt,0) AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl = 'TRUE'  THEN -------------------11/* added by ssawant for bug 5989740 */
               v_reg_type := 'PLA';
            ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN
               v_reg_type  := 'PLA';
            ELSIF v_pref_rg23a = 3 THEN
               IF v_rg23a_balance >= NVL(v_exempt_amt,0) AND lv_rg23a_cess_avlbl = 'TRUE' AND lv_rg23a_sh_cess_avlbl = 'TRUE' THEN  ----------12/* added by ssawant for bug 5989740 */
                  v_reg_type := 'RG23A';
               ELSE
                  v_reg_type := 'ERROR';
               END IF;--------------------------------------------------------12
            ELSE v_reg_type    := 'ERROR';
         END IF;------------------------------------------------------------ 11
     ELSE
       v_reg_type           :='ERROR';
     END IF;------------------------------------------------------------------8
-------------------------------------------------------------------------------------------------------------------
  ELSIF v_pref_pla = 1 THEN
     IF v_pla_balance >= NVL(v_exempt_amt,0) AND lv_pla_cess_avlbl = 'TRUE'  AND lv_pla_sh_cess_avlbl = 'TRUE'  THEN ---------------------------13/* added by ssawant for bug 5989740 */
        v_reg_type := 'PLA';
     ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN
        v_reg_type  := 'PLA';
     ELSIF v_pref_rg23a = 2 THEN
      IF v_rg23a_balance >= NVL(v_exempt_amt,0) AND lv_rg23a_cess_avlbl = 'TRUE' AND lv_rg23a_sh_cess_avlbl = 'TRUE' THEN ------------------14/* added by ssawant for bug 5989740 */
            v_reg_type := 'RG23A';
    ELSIF v_pref_rg23c =3 THEN
       IF v_rg23c_balance >= NVL(v_exempt_amt,0) AND lv_rg23c_cess_avlbl = 'TRUE' AND lv_rg23c_sh_cess_avlbl = 'TRUE' THEN --------------15/* added by ssawant for bug 5989740 */
           v_reg_type := 'RG23C';
       ELSE
           v_reg_type := 'ERROR';
     END IF;--------------------------------------------------------15
    ELSE
     v_reg_type := 'ERROR';
    END IF;---------------------------------------------------------------14
    ELSIF v_pref_rg23c = 2 THEN
     IF v_rg23c_balance >= NVL(v_exempt_amt,0) AND lv_rg23c_cess_avlbl = 'TRUE' AND lv_rg23c_sh_cess_avlbl = 'TRUE' THEN -------------------16/* added by ssawant for bug 5989740 */
        v_reg_type := 'RG23C';
     ELSIF v_pref_rg23a = 3 THEN
      IF v_rg23a_balance >= NVL(v_exempt_amt,0) AND lv_rg23a_cess_avlbl = 'TRUE' AND lv_rg23a_sh_cess_avlbl = 'TRUE' THEN  ----------17/* added by ssawant for bug 5989740 */
         v_reg_type := 'RG23A';
      ELSE
       v_reg_type := 'ERROR';
      END IF;--------------------------------------------------------17
     ELSE
       v_reg_type    := 'ERROR';
     END IF;------------------------------------------------------------ 16
    ELSE
     v_reg_type           :='ERROR';
    END IF;------------------------------------------------------------------13
  ELSE
     v_reg_type         :='ERROR';
  END IF;---------------------------------------------------------------------------7

--Balance Validations if EOU is Yes.....
   ELSIF v_export_oriented_unit ='Y' and v_register_code='EXPORT_EXCISE' THEN

     --Validation for Basic Excise Duty Amount.
     IF  nvl(v_basic_excise_duty_amount,0) >0 THEN
       IF  v_basic_pla_balance >= v_basic_excise_duty_amount AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl = 'TRUE'  THEN/* added by ssawant for bug 5989740 */
         v_reg_type := 'PLA';
       ELSE
         v_reg_type := 'ERROR';
       END IF;
     END IF;


     --Validation for Additional Excise Duty Amount.
     IF v_reg_type<>'ERROR' THEN
       IF  nvl(v_add_excise_duty_amount,0) >0 THEN
          IF  v_additional_pla_balance >= v_add_excise_duty_amount AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl ='TRUE'  THEN/* added by ssawant for bug 5989740 */
              v_reg_type := 'PLA';
          ELSE
              v_reg_type := 'ERROR';
          END IF;
       END IF;
     END IF;

      --Validation for Other Excise Duty Amount.
      IF v_reg_type<>'ERROR' THEN
        IF  nvl(v_oth_excise_duty_amount,0) >0 THEN
          IF  v_other_pla_balance >= v_oth_excise_duty_amount  AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl ='TRUE' THEN/* added by ssawant for bug 5989740 */
              v_reg_type := 'PLA';
          ELSE
              v_reg_type := 'ERROR';
          END IF;
        END IF;
      END IF;
    END IF; --End of Export Oriented Check......
  -----------------------------------------------------------------------------------------------------------------
EXCEPTION
      WHEN others THEN
      RAISE_APPLICATION_ERROR(-20001,'Error Raised in get_excise_register_with_bal function');
 END;

 --To Raise an Application Error in the Function only rather than in the Trigger or Procedure........
 IF v_reg_type='ERROR' THEN
  BEGIN
   SELECT trip_id
   INTO v_trip_id
   FROM wsh_delivery_trips_v
   WHERE delivery_id=p_delivery_id;
  EXCEPTION
   WHEN OTHERS THEN
  NULL;
  END;

  IF v_debug_flag = 'Y' THEN
     UTL_FILE.PUT_LINE(v_myfilehandle,'Transaction failed as balances are not sufficient');
     UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_trip_id for which transaction failed is ' || v_trip_id);
     UTL_FILE.PUT_LINE(v_myfilehandle,'************************END************************************');
     UTL_FILE.FCLOSE(v_myfileHandle);
  END IF;
  IF v_export_oriented_unit ='N' THEN
   RAISE_APPLICATION_ERROR(-20120, 'None of the Register Have Balances Greater OR Equal TO the Excisable Amount ->'
      || TO_CHAR(v_exempt_amt) || ' OR Cess Amount => ' || to_char(p_cess_amount) );
  ELSIF v_export_oriented_unit ='Y' THEN
   RAISE_APPLICATION_ERROR(-20120, 'The Excise Component Balances are not sufficient');
  END IF;
 END IF;
 --p_reg_type := v_reg_type;
 RETURN(v_reg_type);

EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;

END get_excise_register_with_bal;

PROCEDURE process_deliveries
(
  errbuf         OUT NOCOPY VARCHAR2 ,
  retcode        OUT NOCOPY VARCHAR2 ,
  pn_delivery_id IN   NUMBER
)
IS
ln_error_occured number := 0;
ln_success       number := 0;

/**********************************************************************
CREATED BY       : ssumaith
CREATED DATE     : 11-JAN-2005
ENHANCEMENT BUG  : 4136981
PURPOSE          : To Pass Excise Entries when called from Excise Invoice Generation Program
CALLED FROM      : Called from the Concurrent - India Excise Invoice Generation Program.

**********************************************************************/

BEGIN

  /** begin processing
      A delivery id was passed , So just call the procedure once , ascertain the return status and signal completion
  **/

  IF pn_delivery_id IS NOT NULL THEN
    jai_om_wsh_pkg.process_delivery ( errbuf    ,
                        retcode   ,
                        pn_delivery_id
                       ) ;
    fnd_file.put_line ( fnd_file.log , ' After call to jai_om_wsh_pkg.process_delivery with delivery id => ' || pn_delivery_id || ' return code => ' || retcode);
    IF nvl(retcode,'0') <> '0' THEN
      ln_error_occured := 1;
      ln_success := 0;
      Rollback;
      fnd_file.put_line ( fnd_file.log , 'delivery_id => ' || pn_delivery_id || 'Error is ' ||  errbuf ) ;
    else

      commit;
      ln_success := 1;

    END IF ;

  ELSE
    FOR temp_rec IN ( Select distinct delivery_id
                      From   JAI_OM_OE_GEN_TAXINV_T
                     )
    LOOP
      BEGIN
        fnd_file.put_line ( fnd_file.log , ' Calling jai_om_wsh_pkg.process_delivery with delivery id => ' || temp_rec.delivery_id );
        jai_om_wsh_pkg.process_delivery(errbuf   ,
                          retcode  ,
                          temp_rec.delivery_id
                         ) ;
        fnd_file.put_line ( fnd_file.log , ' After call to jai_om_wsh_pkg.process_delivery with delivery id => ' || temp_rec.delivery_id || ' return code => ' || retcode);
        IF nvl(retcode,'0') <> '0' THEN
           /* An Error has occured - rollback the changes done by the changes and proceed with the next one*/
           fnd_file.put_line ( fnd_file.log , ' After call to jai_om_wsh_pkg.process_delivery with delivery id => ' || temp_rec.delivery_id || ' Error is  => ' || errbuf);
           ln_error_occured := 1;
           Rollback;
        else
           ln_success := 1; /* It will hold the status whether atleast one delivery was successfully processed*/
           commit;

        END IF ;
      EXCEPTION
        WHEN OTHERS THEN
           ln_error_occured := 1;  /* It will hold the status whether atleast one delivery was errored */
      END;
    END LOOP ;
  END IF ;


  /* Final Concurent program Completion status setting */
  if ln_error_occured = 1  and ln_success = 1 then
     retcode := '1'; /* Signal a warning , Atleast one delivery went into exception and atleast one delivery was processed successfully*/
  elsif ln_error_occured = 1  and ln_success = 0 then
     retcode := '2'; /* Signal an errror , Atleast one delivery went into exception and no delivery was processed successfully*/
  elsif ln_error_occured = 0  and ln_success = 1 then
     retcode := '0'; /* Signal success , All deliveries was processed successfully and none errored out*/

  end if;

EXCEPTION
WHEN others THEN
 if ln_success = 1 then
  retcode := '1';
 else
  retcode := '2';
 end if;
  errbuf  := substr(sqlerrm,1,1999);
END process_deliveries;

END jai_om_wsh_pkg;

/
