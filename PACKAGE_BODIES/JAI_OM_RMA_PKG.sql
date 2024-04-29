--------------------------------------------------------
--  DDL for Package Body JAI_OM_RMA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_OM_RMA_PKG" AS
/* $Header: jai_om_rma.plb 120.7.12010000.4 2010/05/10 09:59:34 haoyang ship $ */

procedure default_taxes_onto_line (
                              p_header_id                       NUMBER,
                              p_line_id                         NUMBER,
                              p_inventory_item_id               NUMBER,
                              p_warehouse_id                    NUMBER,
                              p_new_reference_line_id           NUMBER,
                              p_new_ref_customer_trx_line_id    NUMBER,
                              p_line_number                     NUMBER,
                              p_old_return_context              VARCHAR2,
                              pn_delivery_detail_id             NUMBER,
                              pv_allow_excise_flag              VARCHAR2,
                              pv_allow_sales_flag               VARCHAR2,
                              pn_excise_duty_per_unit           NUMBER,
                              pn_excise_duty_rate               NUMBER,
                              p_old_reference_line_id           NUMBER,
                              p_old_ref_customer_trx_line_id     NUMBER,
                              p_old_ordered_quantity            NUMBER,
                              p_old_cancelled_quantity          NUMBER,
                              p_new_return_context              VARCHAR2,
                              p_new_ordered_quantity             NUMBER,
                              p_new_cancelled_quantity          NUMBER,
                              p_uom                             VARCHAR2,
                              p_old_selling_price               NUMBER,
                              p_new_selling_price               NUMBER, -- added by sriram Bug
                              p_item_type_code                  VARCHAR2,
                              p_serviced_quantity               NUMBER,
                              p_creation_date                   DATE,
                              p_created_by                      NUMBER,
                              p_last_update_date                DATE,
                              p_last_updated_by                 NUMBER,
                              p_last_update_login               NUMBER,
                              p_source_document_type_id         NUMBER,
                              p_line_category_code              OE_ORDER_LINES_ALL.LINE_CATEGORY_CODE%TYPE
                             )
IS
  v_category            oe_order_headers_all.order_category_code % TYPE;
  v_order_number        oe_order_headers_all.order_number % TYPE;
  v_ord_inv_quantity    oe_order_lines_all.ordered_quantity % TYPE;
  v_old_quantity        JAI_OM_WSH_LINES_ALL.quantity % TYPE;
  v_new_quantity        JAI_OM_WSH_LINES_ALL.quantity % TYPE;
  v_shipped_quantity    wsh_delivery_details.shipped_quantity % TYPE;
  v_quantity            JAI_OM_WSH_LINES_ALL.quantity % TYPE;
  v_cor_amount          JAI_OM_WSH_LINES_ALL.tax_amount % TYPE;
  v_tax_category_id     JAI_OM_WSH_LINES_ALL.tax_category_id % TYPE;
  v_tax_amount          JAI_OM_WSH_LINES_ALL.tax_amount % TYPE;
  v_delivery_detail_id  JAI_OM_WSH_LINES_ALL.delivery_detail_id % TYPE;
  v_excise_return_days  JAI_CMN_INVENTORY_ORGS.excise_return_days % TYPE;
  v_sales_return_days   JAI_CMN_INVENTORY_ORGS.sales_return_days % TYPE;
  v_vat_return_days   JAI_CMN_INVENTORY_ORGS.vat_return_days % TYPE; -- added, Harshita for bug#4245062
  v_excise_flag         VARCHAR2(1);
  v_sales_flag          VARCHAR2(1);
  v_vat_flag            VARCHAR2(1); -- added, Harshita for bug#4245062
  v_vat_attribute       VARCHAR2(1); -- added, Harshita for bug#4245062
  v_date_ordered        DATE;
  v_date_confirmed      DATE;
  v_paddr               v$session.paddr % TYPE;
  v_chk_form            VARCHAR2(30);
  v_round_tax           NUMBER;
  v_round_base          NUMBER;
  v_round_func          NUMBER;
  v_tax_total           NUMBER;
  v_conf                NUMBER;
  v_test_id             NUMBER;
  v_exist_flag          NUMBER := 0;
  v_excise_duty_rate    JAI_OM_OE_RMA_LINES.excise_duty_rate % TYPE;
  v_rate_per_unit       JAI_OM_OE_RMA_LINES.rate_per_unit % TYPE;
  v_excise_total        NUMBER;
  v_rate_total          NUMBER;
  v_qty_total           NUMBER;
  v_manufacturing       JAI_CMN_INVENTORY_ORGS.manufacturing%type; --Added by Nagaraj.s for Bug3113027
  v_trading             JAI_CMN_INVENTORY_ORGS.trading%type; --Added by Nagaraj.s for Bug3113027
  v_service_type_code   JAI_OM_OE_SO_LINES.service_type_code%type; /* added by ssawant for bug 5879769 */

  -- added by Allen Yang for bug 9666476 28-apr-2010, begin
  lv_shippable_flag     VARCHAR2(1);

  CURSOR c_get_shippable_flag(c_inv_item_id NUMBER, c_organization_id NUMBER)
  IS
  SELECT SHIPPABLE_ITEM_FLAG
  FROM   MTL_SYSTEM_ITEMS
  WHERE  INVENTORY_ITEM_ID = c_inv_item_id
  AND    ORGANIZATION_ID = c_organization_id;
  -- added by Allen Yang for bug 9666476 28-apr-2010, end

  -- modified by Allen Yang for bug 9666476 28-apr-2010, begin
  --CURSOR Localized_Order_Cur(c_delivery_detail_id NUMBER) IS
  --  SELECT 1
  --    FROM JAI_OM_WSH_LINES_ALL
  --    WHERE delivery_detail_id = c_delivery_detail_id; /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
  CURSOR Localized_Order_Cur(c_delivery_detail_id NUMBER, c_order_line_id NUMBER) IS
    SELECT 1
      FROM JAI_OM_WSH_LINES_ALL
      WHERE delivery_detail_id = c_delivery_detail_id
      OR    (SHIPPABLE_FLAG = 'N' AND ORDER_LINE_ID = c_order_line_id);
  -- modified by Allen Yang for bug 9666476 28-apr-2010, end

  -- cbabu for Bug#2523313, Start
  CURSOR requested_qty_uom_cur(p_delivery_detail_id NUMBER) IS
        SELECT requested_quantity_uom FROM wsh_delivery_details
        WHERE delivery_detail_id = p_delivery_detail_id;

  v_conversion_rate             NUMBER  := 0;
  v_requested_quantity_uom VARCHAR2(3);
  v_rma_quantity_uom    VARCHAR2(3); --     := p_uom; --Ramananda for File.Sql.35

  -- cbabu for Bug#2523313, End


  -- added by sriram - bug # 2798596

  cursor c_sales_order_cur is
  select quantity ,service_type_code /* added by ssawant for bug 5879769 */
  from   JAI_OM_OE_SO_LINES
  where  line_id = p_new_reference_line_id;

  Cursor C_SO_TAX_AMOUNT (p_tax_id JAI_CMN_TAXES_ALL.tax_id%type) is
  select tax_amount
  from   JAI_OM_OE_SO_TAXES
  where  line_id = p_new_reference_line_id
  and    tax_id = p_tax_id;

  v_so_tax_amount Number;
  v_orig_ord_qty  Number;


  -- additions by sriram - bug # 2798596 -- ends here

-- added, Harshita for bug#4245062
     Cursor c_ordered_date_cur(v_header_id number) is
       select
         ordered_date
       from
         oe_order_headers_all
       where
         header_id = v_header_id;

     -- following cursor is used to get the ship confirm date based on the delivery detail id

     cursor c_confirmed_date (p_delivery_Detail_id Number) is
       select
         confirm_date
       FROM
         wsh_delivery_details     wdd,
         wsh_delivery_assignments wda,
         wsh_new_deliveries       wnd
       WHERE
         wdd.delivery_detail_id = (p_delivery_Detail_id)
       AND
         wda.delivery_detail_id = wdd.delivery_detail_id
       AND
         wnd.delivery_id = wda.delivery_id;

     Cursor c_hr_organizations_cur( v_organization_id number ) is
       SELECT vat_return_days
       FROM   JAI_CMN_INVENTORY_ORGS
       WHERE  organization_id = v_organization_id
       AND location_id = 0;

       v_ordered_date date ;
       v_confirm_date date ;


-- end, Harshita for bug#4245062
/*bduvarag for the bug# 5256498 start*/
     cursor c_check_Vat_type_Tax_exists (cp_tax_type VARCHAR2) IS
     SELECT 1
     FROM   jai_regime_tax_types_v
     WHERE  regime_code = jai_constants.vat_regime
     AND    tax_type    = cp_tax_type;

     lv_check_vat_type_exists VARCHAR2(1);

/*bduvarag for the bug#5256498 end*/
  /* Added for DFF Elimination by Ramananda  */

  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_rma_pkg.default_taxes_onto_line';

-------------------------------------------------------------------------------------------------
  PROCEDURE rma_insert IS
  BEGIN

    IF v_delivery_detail_id IS NOT NULL
    THEN
      v_ord_inv_quantity := p_new_ordered_quantity;
      IF v_ord_inv_quantity <> 0
      THEN
        FOR pick_rec IN (SELECT quantity,
                                tax_category_id
                           FROM JAI_OM_WSH_LINES_ALL
                          WHERE delivery_detail_id = v_delivery_detail_id)
        LOOP
          v_quantity := pick_rec.quantity;
          v_tax_category_id := pick_rec.tax_category_id;
        END LOOP;

        IF pn_excise_duty_per_unit IS NOT NULL AND
           pn_excise_duty_rate IS NOT NULL
        THEN
          v_excise_duty_rate  := pn_excise_duty_rate;
          v_rate_per_unit     := pn_excise_duty_per_unit;
        ELSE
          FOR duty_rec IN (SELECT rgd.excise_duty_rate,
                                  rgd.rate_per_unit,
                                  rgd.quantity_received
                             FROM JAI_CMN_RG_23D_TRXS rgd,
                                  JAI_CMN_MATCH_RECEIPTS rm
                            WHERE rm.ref_line_id = v_delivery_detail_id
                              AND rgd.register_id = rm.receipt_id)
          LOOP
            v_excise_total := NVL(v_excise_total, 0) + NVL(duty_rec.excise_duty_rate, 0) *
                              NVL(duty_rec.quantity_received, 0);
            v_rate_total := NVL(v_rate_total, 0) + NVL(duty_rec.rate_per_unit, 0) *
                              NVL(duty_rec.quantity_received, 0);
            v_qty_total := NVL(v_qty_total, 0) + NVL(duty_rec.quantity_received, 0);
          END LOOP;
          IF NVL(v_excise_total, 0) <> 0 AND
             NVL(v_qty_total, 0) <> 0
          THEN
            v_excise_duty_rate := ROUND((v_excise_total / v_qty_total), 2);
          END IF;
          IF NVL(v_rate_total, 0) <> 0 AND
             NVL(v_qty_total, 0) <> 0
          THEN
            v_rate_per_unit := ROUND((v_rate_total / v_qty_total), 2);
          END IF;
        END IF;
        ---------------------- For inserting record in JAI_OM_OE_RMA_LINES --------------------


        INSERT INTO JAI_OM_OE_RMA_LINES
               (rma_line_id,
                rma_line_number,
                rma_header_id,
                rma_number,
                delivery_detail_id,
                uom,
                selling_price,
                quantity,
                tax_category_id,
                tax_amount,
                inventory_item_id,
                received_flag,
                assessable_value,
                excise_duty_rate,
                rate_per_unit,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                /* Added for DFF Elimination by Ramananda  */
                allow_excise_credit_flag,
                allow_sales_credit_flag,
    service_type_code /* added by ssawant for bug 5879769 */
                )
        VALUES (p_line_id,
                p_line_number,
                p_header_id,
                v_order_number,
                v_delivery_detail_id,
                P_uom,
                p_new_selling_price,
                v_ord_inv_quantity,
                v_tax_category_id,
                NULL,
                p_inventory_item_id,
                NULL,   --received_flag
                NULL,   --assessable value
                v_excise_duty_rate,
                v_rate_per_unit,
                p_creation_date,
                p_created_by,
                p_last_update_date,
                p_last_updated_by,
                p_last_update_login,
                pv_allow_excise_flag,
                pv_allow_sales_flag,
    v_service_type_code /* added by ssawant for bug 5879769 */
               );

          IF v_quantity <> 0
        THEN
                        -- cbabu for Bug#2523313, Start
                        OPEN requested_qty_uom_cur(v_delivery_detail_id);
                        FETCH requested_qty_uom_cur INTO v_requested_quantity_uom;
                        CLOSE requested_qty_uom_cur;

                        INV_CONVERT.inv_um_conversion(v_requested_quantity_uom,
                                                                                  v_rma_quantity_uom,
                                                                                  p_inventory_item_id,
                                                                                  v_conversion_rate);
                        IF NVL(v_conversion_rate, 0) <= 0 THEN
                          INV_CONVERT.inv_um_conversion(v_requested_quantity_uom,
                                                                                        v_rma_quantity_uom,
                                                                                        0,
                                                                                        v_conversion_rate);
                          IF NVL(v_conversion_rate, 0) <= 0 THEN
                                v_conversion_rate := 0;
                          END IF;
                        END IF;
                        -- cbabu for Bug#2523313, End
          v_cor_amount := (v_ord_inv_quantity / v_quantity)*(1/v_conversion_rate);  -- cbabu for Bug#2523313

        END IF;
        FOR tax_line_rec IN (SELECT tax_line_no,
                                    precedence_1,
                                    precedence_2,
                                    precedence_3,
                                    precedence_4,
                                    precedence_5,
                                    sptl.tax_id,
                                    sptl.tax_rate,
                                    sptl.qty_rate,
                                    uom,
                                    sptl.tax_amount,
            nvl(jtc.rounding_factor,0) rounding_factor,/*Bug 5989740 bduvarag*//*bduvarag for the bug#6071813*/
--                                  interfaced_flag,
                                    base_tax_amount,
                                    func_tax_amount,
                                    jtc.tax_type ,
                                    precedence_6,  -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                                    precedence_7,
                                    precedence_8,
                                    precedence_9,
                                    precedence_10
                               FROM JAI_OM_WSH_LINE_TAXES sptl,
                                    JAI_CMN_TAXES_ALL jtc
                              WHERE delivery_detail_id = v_delivery_detail_id
                                AND jtc.tax_id = sptl.tax_id)
        LOOP


    IF tax_line_rec.tax_type IN ('Excise', 'Addl. Excise', 'Other Excise', 'TDS', 'CVD')
          THEN
            v_round_tax := ROUND((v_cor_amount * tax_line_rec.tax_amount),tax_line_rec.rounding_factor);/*Bug 5989740 bduvarag*/
            v_round_base := ROUND((v_cor_amount * tax_line_rec.base_tax_amount),tax_line_rec.rounding_factor);/*Bug 5989740 bduvarag*/
            v_round_func := ROUND((v_cor_amount * tax_line_rec.func_tax_amount),tax_line_rec.rounding_factor);/*Bug 5989740 bduvarag*/
          ELSE
            v_round_tax := ROUND((v_cor_amount * tax_line_rec.tax_amount), 2);
            v_round_base := ROUND((v_cor_amount * tax_line_rec.base_tax_amount), 2);
            v_round_func := ROUND((v_cor_amount * tax_line_rec.func_tax_amount), 2);
          END IF;


          /*
            code segment added by sriram - bug # 2798596
          */

          open  c_sales_order_cur;
          fetch c_sales_order_cur into v_orig_ord_qty,v_service_type_code;/* added by ssawant for bug 5879769 */
          close c_sales_order_cur;

      /*
       code segment added by sriram - ends here - bug # 2798596
      */
/*bduvarag for the bug#5256498 start*/
          lv_check_vat_type_exists := NULL;

          OPEN   c_check_Vat_type_Tax_exists (tax_line_rec.tax_type);
          FETCH  c_check_Vat_type_Tax_exists INTO lv_check_vat_type_exists;
          CLOSE  c_check_Vat_type_Tax_exists;
/*bduvarag for the bug#5256498 end*/

          IF (tax_line_rec.tax_type IN ('Excise', 'Addl. Excise', 'Other Excise', JAI_CONSTANTS.TAX_TYPE_EXC_EDU_CESS, JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS) AND /*Bug 5989740 bduvarag*/
             v_excise_flag = 'N') OR
             (tax_line_rec.tax_type IN ('Sales Tax', 'CST') AND
             v_sales_flag = 'N') OR  -- added, Harshita for bug#4245062
/*bduvarag for the bug#5256498 start*/
     /*  (tax_line_rec.tax_type IN ('TURNOVER TAX', 'VAT', 'ENTRY TAX', 'Octrai', 'PURCHASE TAX') AND
             v_vat_flag = 'N') */
                    ( lv_check_vat_type_exists = 1 AND v_vat_flag = 'N')
/*bduvarag for the bug#5256498 end*/
          THEN
            v_round_tax := 0;
            v_round_base := 0;
            v_round_func := 0;
          END IF;


          INSERT INTO JAI_OM_OE_RMA_TAXES
                 (rma_line_id,
                  delivery_detail_id,
                  tax_line_no,
                  precedence_1,
                  precedence_2,
                  precedence_3,
                  precedence_4,
                  precedence_5,
                  tax_id,
                  tax_rate,
                  qty_rate,
                  uom,
                  tax_amount,
                  base_tax_amount,
                  func_tax_amount,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login ,
                  precedence_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                  precedence_7,
                  precedence_8,
                  precedence_9,
                  precedence_10)
          VALUES (p_line_id,
                  v_delivery_detail_id,
                  tax_line_rec.tax_line_no,
                  tax_line_rec.precedence_1,
                  tax_line_rec.precedence_2,
                  tax_line_rec.precedence_3,
                  tax_line_rec.precedence_4,
                  tax_line_rec.precedence_5,
                  tax_line_rec.tax_id,
                  tax_line_rec.tax_rate,
                  tax_line_rec.qty_rate,
                  tax_line_rec.uom,
                  v_round_tax,
                  v_round_base,
                  v_round_func,
                  p_creation_date,
                  p_created_by,
                  p_last_update_date,
                  p_last_updated_by,
                  p_last_update_login ,
                  tax_line_rec.precedence_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                  tax_line_rec.precedence_7,
                  tax_line_rec.precedence_8,
                  tax_line_rec.precedence_9,
                  tax_line_rec.precedence_10
      );
          IF tax_line_rec.tax_type <> 'TDS'
          THEN
            v_tax_total := NVL(v_tax_total, 0) + v_round_tax;
          END IF;
        END LOOP;
        UPDATE JAI_OM_OE_RMA_LINES
           SET tax_amount = NVL(tax_amount, 0) + v_tax_total
         WHERE rma_line_id = p_line_id;
      END IF;

    -- modified by Allen Yang for bug 9666476 28-apr-2010, begin
    --END IF;
    -- need to do RMA insert for non-shippable lines (whose delivery_detail_id IS NULL)
    ELSIF NVL(lv_shippable_flag, 'Y') = 'N'
    THEN
      -- added by Allen Yang for bug 9691880 10-May-2010, begin
      FOR hr_rec IN (SELECT vat_return_days
                       FROM JAI_CMN_INVENTORY_ORGS
                      WHERE organization_id = p_warehouse_id
                        AND location_id = 0)
      LOOP
       v_vat_return_days   := hr_rec.vat_return_days ;
      END LOOP; -- hr_rec IN ......

      FOR date_rec IN (SELECT ordered_date
                         FROM oe_order_headers_all
                        WHERE header_id = p_header_id)
      LOOP
        v_date_ordered := date_rec.ordered_date;
      END LOOP; -- date_rec IN ......

      -- added by Allen Yang for bug 9691880 10-May-2010, end

      IF p_new_ordered_quantity <> 0
      THEN
        FOR pick_rec IN (SELECT tax_category_id
                                -- added by Allen Yang for bug 9691880 10-May-2010, begin
                               ,creation_date
                                -- added by Allen Yang for bug 9691880 10-May-2010, end
                           FROM JAI_OM_WSH_LINES_ALL
                          WHERE shippable_flag = 'N'
                            AND order_line_id = p_new_reference_line_id)
        LOOP
          v_tax_category_id := pick_rec.tax_category_id;
          -- added by Allen Yang for bug 9691880 10-May-2010, begin
          v_date_confirmed  := pick_rec.creation_date;
          -- added by Allen Yang for bug 9691880 10-May-2010, end
        END LOOP; -- pick_rec IN ......

        -- added by Allen Yang for bug 9691880 10-May-2010, begin
        IF (v_vat_return_days IS NULL
          OR
           (v_date_ordered - v_date_confirmed) <= v_vat_return_days)
        THEN
          v_vat_flag := 'Y';
        ELSE
          v_vat_flag := 'N';
        END IF; -- v_vat_return_days IS NULL OR ......
        -- added by Allen Yang for bug 9691880 10-May-2010, end

        ---------------------- For inserting record in JAI_OM_OE_RMA_LINES --------------------
        INSERT INTO JAI_OM_OE_RMA_LINES
               (rma_line_id,
                rma_line_number,
                rma_header_id,
                rma_number,
                delivery_detail_id,
                uom,
                selling_price,
                quantity,
                tax_category_id,
                tax_amount,
                inventory_item_id,
                received_flag,
                assessable_value,
                excise_duty_rate,
                rate_per_unit,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                allow_excise_credit_flag,
                allow_sales_credit_flag,
                service_type_code
                )
        VALUES (p_line_id,
                p_line_number,
                p_header_id,
                v_order_number,
                NULL, -- delivery_detail_id
                P_uom,
                p_new_selling_price,
                p_new_ordered_quantity,
                v_tax_category_id,
                NULL, -- tax_amount
                p_inventory_item_id,
                NULL,   --received_flag
                NULL,   --assessable value
                NULL,   -- excise_duty_rate
                NULL,   -- rate_per_unit,
                p_creation_date,
                p_created_by,
                p_last_update_date,
                p_last_updated_by,
                p_last_update_login,
                pv_allow_excise_flag,
                pv_allow_sales_flag,
                v_service_type_code
               );

        FOR tax_line_rec IN (SELECT tax_line_no,
                                    precedence_1,
                                    precedence_2,
                                    precedence_3,
                                    precedence_4,
                                    precedence_5,
                                    sptl.tax_id,
                                    sptl.tax_rate,
                                    sptl.qty_rate,
                                    uom,
                                    sptl.tax_amount,
                                    nvl(jtc.rounding_factor,0) rounding_factor,
                                    base_tax_amount,
                                    func_tax_amount,
                                    jtc.tax_type ,
                                    precedence_6,
                                    precedence_7,
                                    precedence_8,
                                    precedence_9,
                                    precedence_10
                               FROM JAI_OM_WSH_LINE_TAXES sptl,
                                    JAI_CMN_TAXES_ALL jtc
                              WHERE order_line_id = p_new_reference_line_id
                                AND jtc.tax_id = sptl.tax_id)
        LOOP
          -- added by Allen Yang for bug 9691880 10-May-2010, begin
          lv_check_vat_type_exists := NULL;

          OPEN   c_check_Vat_type_Tax_exists (tax_line_rec.tax_type);
          FETCH  c_check_Vat_type_Tax_exists INTO lv_check_vat_type_exists;
          CLOSE  c_check_Vat_type_Tax_exists;

          IF ( lv_check_vat_type_exists = 1 AND v_vat_flag = 'N')
          THEN
            v_round_tax := 0;
            v_round_base := 0;
            v_round_func := 0;
          ELSE
            v_round_tax := tax_line_rec.tax_amount;
            v_round_base := tax_line_rec.base_tax_amount;
            v_round_func := tax_line_rec.func_tax_amount;
          END IF; -- lv_check_vat_type_exists = 1 AND v_vat_flag = 'N'
          -- added by Allen Yang for bug 9691880 10-May-2010, end

          open  c_sales_order_cur;
          fetch c_sales_order_cur into v_orig_ord_qty,v_service_type_code;
          close c_sales_order_cur;

          INSERT INTO JAI_OM_OE_RMA_TAXES
                 (rma_line_id,
                  delivery_detail_id,
                  tax_line_no,
                  precedence_1,
                  precedence_2,
                  precedence_3,
                  precedence_4,
                  precedence_5,
                  tax_id,
                  tax_rate,
                  qty_rate,
                  uom,
                  tax_amount,
                  base_tax_amount,
                  func_tax_amount,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login ,
                  precedence_6,
                  precedence_7,
                  precedence_8,
                  precedence_9,
                  precedence_10)
          VALUES (p_line_id,
                  NULL,  -- delivery_detail_id
                  tax_line_rec.tax_line_no,
                  tax_line_rec.precedence_1,
                  tax_line_rec.precedence_2,
                  tax_line_rec.precedence_3,
                  tax_line_rec.precedence_4,
                  tax_line_rec.precedence_5,
                  tax_line_rec.tax_id,
                  tax_line_rec.tax_rate,
                  tax_line_rec.qty_rate,
                  tax_line_rec.uom,
                  -- modified by Allen Yang for bug 9691880 10-May-2010, begin
                  v_round_tax, --tax_line_rec.tax_amount,
                  v_round_base, --tax_line_rec.base_tax_amount,
                  v_round_func, --tax_line_rec.func_tax_amount,
                  -- modified by Allen Yang for bug 9691880 10-May-2010, end
                  p_creation_date,
                  p_created_by,
                  p_last_update_date,
                  p_last_updated_by,
                  p_last_update_login ,
                  tax_line_rec.precedence_6,
                  tax_line_rec.precedence_7,
                  tax_line_rec.precedence_8,
                  tax_line_rec.precedence_9,
                  tax_line_rec.precedence_10
          );
          IF tax_line_rec.tax_type <> 'TDS'
          THEN
            -- modified by Allen Yang for bug 9691880 10-May-2010, begin
            --v_tax_total := NVL(v_tax_total, 0) + tax_line_rec.tax_amount;
            v_tax_total := NVL(v_tax_total, 0) + v_round_tax;
            -- modified by Allen Yang for bug 9691880 10-May-2010, end
          END IF; --tax_line_rec.tax_type <> 'TDS'
        END LOOP; --tax_line_rec IN (SELECT tax_line_no ......

        UPDATE JAI_OM_OE_RMA_LINES
           SET tax_amount = NVL(tax_amount, 0) + v_tax_total
         WHERE rma_line_id = p_line_id;
      END IF; -- p_new_ordered_quantity <> 0
    END IF; -- v_delivery_detail_id IS NOT NULL
    -- modified by Allen Yang for bug 9666476 28-apr-2010, end

  END rma_insert;
  -----------------------------------------------------------------------------------------------
  PROCEDURE check_dff IS
  BEGIN
/*
   IF ( (p_new_return_context IS NOT NULL) OR (p_new_return_context <> 'LEGACY') )  THEN    --2001/05/08 Anuradha Parthasarathy
*/
   /*
   || Added by aiyer for the bug 5401180,
   || Removed check for LEGACY as Dff context LEGACY has been removed
   */
    IF  (p_new_return_context IS NOT NULL) THEN
     -- legacy condition added by Aparajita on 31-may-2002 for bug 2381492
     IF pn_delivery_detail_id IS NULL    THEN
       RAISE_APPLICATION_ERROR(-20401,'Delivery Detail id IS NOT entered');
     END IF;

     IF p_new_reference_line_id IS NOT NULL  THEN

       FOR conf_rec IN (SELECT NVL(wdd.delivery_detail_id, 0) pic
                         FROM wsh_delivery_details wdd
                        WHERE wdd.delivery_detail_id = TO_NUMBER(pn_delivery_detail_id)
                          AND (wdd.inventory_item_id IN
                                    (SELECT inventory_item_id
                                       FROM mtl_system_items
                                      WHERE base_item_id = p_inventory_item_id
                                        AND bom_item_type = 4) OR
                              wdd.inventory_item_id = p_inventory_item_id)
                          AND wdd.shipped_quantity IS NOT NULL)
       LOOP
         v_conf := conf_rec.pic;
       END LOOP;

     ELSIF p_new_ref_customer_trx_line_id IS NOT NULL THEN

      FOR conf_rec IN (SELECT NVL(wdd.delivery_detail_id, 0) pic
                         FROM wsh_delivery_details wdd,
                              ra_customer_trx_lines_all rctla
                        WHERE wdd.delivery_detail_id = TO_NUMBER(pn_delivery_detail_id)
                          AND rctla.customer_trx_line_id = p_new_ref_customer_trx_line_id
                          AND rctla.inventory_item_id = p_inventory_item_id
                          AND wdd.delivery_detail_id = TO_NUMBER(rctla.interface_line_attribute3)
                          AND (wdd.inventory_item_id IN
                                    (SELECT inventory_item_id
                                       FROM mtl_system_items
                                      WHERE base_item_id = p_inventory_item_id
                                        AND bom_item_type = 4) OR
                              wdd.inventory_item_id = p_inventory_item_id)
                          AND wdd.shipped_quantity IS NOT NULL)
      LOOP
        v_conf := conf_rec.pic;
      END LOOP;

     END IF; -- p_new_reference_line_id

     IF v_conf IS NULL   THEN
       RAISE_APPLICATION_ERROR(-20401, 'Delivery detail id IN the DFF IS NOT matching WITH the related delivery detail id FOR the entered ORDER NUMBER');
     END IF;

     FOR hr_rec IN (SELECT excise_return_days,
                           sales_return_days,
                           vat_return_days ,  -- added, Harshita for bug#4245062
                           nvl(manufacturing,'N') manufacturing, --Added Manufacturing and Trading by Nagaraj.s for bug3113027
                           nvl(trading,'N') trading
                     FROM JAI_CMN_INVENTORY_ORGS
                    WHERE organization_id = p_warehouse_id
                      AND location_id = 0)
     LOOP
       v_excise_return_days := hr_rec.excise_return_days;
       v_sales_return_days := hr_rec.sales_return_days;
       v_vat_return_days   := hr_rec.vat_return_days ;  -- added, Harshita for bug#4245062
       --Added Manufacturing and Trading by Nagaraj.s for bug3113027
       v_manufacturing     := hr_rec.manufacturing;
       v_trading                   := hr_rec.trading;

     END LOOP;

     FOR date_rec IN (SELECT ordered_date
                       FROM oe_order_headers_all
                      WHERE header_id = p_header_id)
     LOOP
       v_date_ordered := date_rec.ordered_date;
     END LOOP;
     --2001/07/03 Anuradha Parthasarathy
     ---modified the IF condition for bug#7316234
     IF NVL(pv_allow_excise_flag, 'Y') = 'Y' AND
        (v_excise_return_days IS NULL
        OR
        (v_date_ordered - v_date_confirmed) <= v_excise_return_days) -- 0 replaced with 180 by sriram in the nvl comparison. - bug # 2993645
     THEN
        v_excise_flag := 'Y';
     ELSE
        v_excise_flag := 'N';
     END IF;

     ---modified the IF condition for bug#7316234
     IF NVL(pv_allow_sales_flag, 'Y') = 'Y' AND
      (v_sales_return_days IS NULL
      OR
      (v_date_ordered - v_date_confirmed) <= v_sales_return_days) -- 0 replaced with 180 by sriram in the nvl comparison. - bug # 2993645
     THEN
        v_sales_flag := 'Y';
     ELSE
        v_sales_flag := 'N';
     END IF;

     -- added, Harshita for bug#4245062
     ---modified the IF condition for bug#7316234
     IF (v_vat_return_days IS NULL
        OR
        (v_date_ordered - v_date_confirmed) <= v_vat_return_days) -- 0 replaced with 180 by sriram in the nvl comparison. - bug # 2993645
     THEN
        v_vat_flag := 'Y';
     ELSE
        v_vat_flag := 'N';
     END IF;
     -- ended, Harshita for bug#4245062


    --2001/07/03 Anuradha Parthasarathy


    FOR pick_rec IN (SELECT SUM(wdd.shipped_quantity) qty
                       FROM wsh_delivery_details wdd
                      WHERE wdd.delivery_detail_id = v_delivery_detail_id
                        AND wdd.inventory_item_id = p_inventory_item_id)
    LOOP
      v_shipped_quantity := pick_rec.qty;
    END LOOP;

    IF v_shipped_quantity < v_ord_inv_quantity    THEN
      RAISE_APPLICATION_ERROR(-20401, 'RMA quantity can NOT be more than shipped quantity');
    END IF;

  END IF;

END check_dff;

 -----------------------------------------------------------------------------------------------
  PROCEDURE delete_data IS
  BEGIN

    DELETE FROM JAI_OM_OE_RMA_LINES
     WHERE rma_line_id = p_line_id;
    DELETE FROM JAI_OM_OE_RMA_TAXES
     WHERE rma_line_id = p_line_id;
  END delete_data;

BEGIN
  v_rma_quantity_uom    := p_uom;      --Ramananda for File.Sql.35

  ----------------------------- For picking order category from oe_order_headers_all ------------------
  IF p_header_id IS NOT NULL
  THEN
    FOR order_rec IN(SELECT order_category_code,
                            order_number,
                            ROWID
                       FROM oe_order_headers_all
                      WHERE header_id = P_header_id)
    LOOP
      v_category := order_rec.order_category_code;
      v_order_number := order_rec.order_number;
     /* v_rowid := order_rec.ROWID;*/
    END LOOP;
  END IF;
  -------------------------------- For updating JAI_CMN_LOCATORS_T -----------------------------------
-- Start of bug #3306419
 /*
   The following if condition has been modified by aiyer for the bug #3306419
   Added the clause p_line_category_code = 'RETURN' so that this piece of code would always
   execute in case of an RMA irrespective of how the return order has been created.
 */

  IF NVL(p_source_document_type_id,0) <> 2 OR
     p_line_category_code = 'RETURN'
  THEN
  -- End OF Bug #3306419

  IF (v_category IS NOT NULL AND v_category = 'RETURN')
     OR (p_new_reference_line_id IS NOT NULL)
  THEN


     v_chk_form := NVL(v_chk_form, 'JAINRCRT');

    --- For picking shipped quantity, tax amount and tax category from JAI_OM_WSH_LINES_ALL ---

        FOR pick_lrec IN (SELECT wdd.delivery_detail_id,
                             wnd.confirm_date
                        FROM wsh_delivery_details wdd,
                             wsh_delivery_assignments wda,
                             wsh_new_deliveries wnd
                       WHERE wdd.delivery_detail_id = TO_NUMBER(pn_delivery_detail_id)
                         AND wda.delivery_detail_id = wdd.delivery_detail_id
                         AND wnd.delivery_id = wda.delivery_id)
         LOOP
            v_delivery_detail_id := pick_lrec.delivery_detail_id;
            v_date_confirmed := pick_lrec.confirm_date;
         END LOOP;

    -- modified by Allen Yang for bug 9666476 28-apr-2010, begin
    --OPEN  Localized_Order_Cur(v_delivery_detail_id);
    OPEN  Localized_Order_Cur(v_delivery_detail_id, p_new_reference_line_id);
    -- modified by Allen Yang for bug 9666476 28-apr-2010, end
      FETCH Localized_Order_Cur INTO v_exist_flag;
    CLOSE Localized_Order_Cur;

    -- added by Allen Yang for bug 9666476 28-apr-2010, begin
    OPEN  c_get_shippable_flag(p_inventory_item_id, p_warehouse_id);
    FETCH c_get_shippable_flag INTO lv_shippable_flag;
    CLOSE c_get_shippable_flag;
    -- added by Allen Yang for bug 9666476 28-apr-2010, end

    IF p_item_type_code = 'STANDARD' AND
       p_serviced_quantity IS NULL AND
       p_new_reference_line_id IS NOT NULL AND
       v_chk_form IS NULL AND
       NVL(v_exist_Flag,0) <> 1
    THEN
      RETURN;
    END IF;

    if UPDATING then

      v_old_quantity := p_old_ordered_quantity - NVL(p_old_cancelled_quantity, 0);
      v_new_quantity := p_new_ordered_quantity - NVL(p_new_cancelled_quantity, 0);
      IF (
            p_old_return_context <> p_new_return_context
            OR (NVL(p_old_selling_price,0) <> NVL(P_new_selling_price,0)) -- added by sriram
            OR NVL(p_old_reference_line_id, -99) <> NVL(p_new_reference_line_id, -99)
            OR NVL(p_new_ref_customer_trx_line_id, -99) <> NVL(p_old_ref_customer_trx_line_id, -99)
            OR v_old_quantity <> v_new_quantity
         )
         AND
         (
          v_chk_form IS NOT NULL
          OR (
                p_item_type_code = 'STANDARD' AND
                p_serviced_quantity IS NULL AND
                p_new_reference_line_id IS NOT NULL AND
                v_chk_form IS NULL
              )
         )
      THEN
        -- modified by Allen Yang for bug 9666476 28-apr-2010, begin
        --check_dff;
        IF NVL(lv_shippable_flag, 'Y') <> 'N'
        THEN
          check_dff;
        END IF;
        -- modified by Allen Yang for bug 9666476 28-apr-2010, end
        delete_data;
        rma_insert;
      ELSIF p_old_cancelled_quantity <> p_new_cancelled_quantity
      THEN

        FOR rma_rec IN (SELECT rma_line_id
                          FROM JAI_OM_OE_RMA_LINES
                         WHERE rma_line_id = p_line_id)
        LOOP
          v_test_id := rma_rec.rma_line_id;
        END LOOP;
        IF v_test_id IS NOT NULL
        THEN

          delete_data;
          rma_insert;
        END IF;
      END IF;

    elsif
      inserting
      and (
            v_chk_form IS NOT NULL
            OR (
                 p_item_type_code = 'STANDARD' AND
                 p_serviced_quantity IS NULL AND
                 p_new_reference_line_id IS NOT NULL
                )
           )
    then
      -- modified by Allen Yang for bug 9666476 28-apr-2010, begin
      --check_dff;
      IF NVL(lv_shippable_flag, 'Y') <> 'N'
      THEN
        check_dff;
      END IF;
      -- modified by Allen Yang for bug 9666476 28-apr-2010, end
      rma_insert;

    end if;

  end if;

end if;

EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END default_taxes_onto_line;


FUNCTION cal_excise_duty
( p_rma_line_id  IN NUMBER,
  p_transaction_quantity  IN NUMBER
) RETURN NUMBER
IS

v_rma_camount                   jai_om_oe_rma_lines.tax_amount % type;
v_basic_ed                      jai_cmn_rg_23ac_ii_trxs.cr_basic_ed % type;
v_additional_ed                 jai_cmn_rg_23ac_ii_trxs.cr_additional_ed % type;
v_other_ed                      jai_cmn_rg_23ac_ii_trxs.cr_other_ed % type;
v_excise                        number;
ln_rma_amt                      number ;


CURSOR c_get_quantity(p_rma_line_id IN NUMBER) IS
SELECT
  NVL(quantity, 0) quantity
FROM JAI_OM_OE_RMA_LINES
WHERE rma_line_id = p_rma_line_id ;

v_rma_quantity                  jai_om_oe_rma_lines.quantity % type;

BEGIN

v_basic_ed        := 0 ;
v_additional_ed   := 0 ;
v_other_ed        := 0 ;
v_excise          := 0 ;


 OPEN c_get_quantity(p_rma_line_id) ;
 FETCH c_get_quantity INTO v_rma_quantity ;
 CLOSE c_get_quantity ;

    For tax_line_rec IN (SELECT rtl.tax_line_no,
                                rtl.precedence_1,
                                rtl.precedence_2,
                                rtl.precedence_3,
                                rtl.precedence_4,
                                rtl.precedence_5,
                                rtl.tax_id,
                                rtl.tax_rate,
                                rtl.qty_rate,
                                rtl.uom,
                                rtl.tax_amount,
                                jtc.tax_type,
                                NVL(jtc.mod_cr_percentage, 0) modcp,
                                NVL(jtc.rounding_factor, 0) rounding_factor ,
                                rtl.precedence_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                                rtl.precedence_7,
                                rtl.precedence_8,
                                rtl.precedence_9,
                                rtl.precedence_10
                           FROM JAI_OM_OE_RMA_TAXES rtl,
                                JAI_CMN_TAXES_ALL jtc
                          WHERE rtl.rma_line_id = p_rma_line_id
                            AND jtc.tax_id = rtl.tax_id)
    LOOP
      ln_rma_amt :=  0 ;
      v_rma_camount := 0 ;

      IF v_rma_quantity <> 0
      THEN
        v_rma_camount := ROUND(( tax_line_rec.tax_amount * p_transaction_quantity / v_rma_quantity ), tax_line_rec.rounding_factor);
        ln_rma_amt    := v_rma_camount * NVL(tax_line_rec.modcp, 0) / 100 ;
      END IF;

      IF tax_line_rec.tax_type = 'Excise'
      THEN
        v_basic_ed := NVL(v_basic_ed, 0) + ln_rma_amt;

      ELSIF tax_line_rec.tax_type IN ('Addl. Excise', 'CVD' )
      THEN
        v_additional_ed := NVL(v_additional_ed, 0) + ln_rma_amt;

      ELSIF tax_line_rec.tax_type = 'Other Excise'
      THEN
        v_other_ed := NVL(v_other_ed, 0) + ln_rma_amt;
      END IF;
    END LOOP ;

     v_excise := NVL(v_basic_ed, 0) + NVL(v_additional_ed, 0) + NVL(v_other_ed, 0);

     RETURN NVL(v_excise,0) ;

END ;


END jai_om_rma_pkg;

/
