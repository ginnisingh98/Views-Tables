--------------------------------------------------------
--  DDL for Package Body POA_EDW_ALINES_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_ALINES_F_SIZE" AS
/* $Header: poaszalb.pls 120.0 2005/06/01 19:22:13 appldev noship $ */

PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                        p_to_date   IN  DATE,
                        p_num_rows  OUT NOCOPY NUMBER) IS

BEGIN

--    dbms_output.enable(100000);

    select count(*) into p_num_rows
      from
           po_lines_all			pol,
           po_headers_all		poh
     WHERE poh.type_lookup_code 		= 'BLANKET'
       and poh.approved_flag		= 'Y'
       and poh.po_header_id		= pol.po_header_id
       and greatest(pol.last_update_date, poh.last_update_date)
             between p_from_date and p_to_date;

--    dbms_output.put_line('The number of rows for agreement lines is: '
--                         || to_char(p_num_rows));

EXCEPTION
    WHEN OTHERS THEN p_num_rows := 0;
END;

-------------------------------------------------------

PROCEDURE  est_row_len (p_from_date    IN  DATE,
                        p_to_date      IN  DATE,
                        p_avg_row_len  OUT NOCOPY NUMBER) IS

 x_date                 number := 7;
 x_total                number := 0;
 x_constant             number := 6;
 x_float                number := 11;
 x_int                  number := 6;

 x_ACCPT_DUE_DATE_FK                    NUMBER;
 x_ACCPT_REQUIRED_FK                    NUMBER;
 x_AGREE_LN_INST_PK                     NUMBER;
 x_AMT_AGREED_G                         NUMBER;
 x_AMT_AGREED_T                         NUMBER;
 x_AMT_MIN_RELEASE_G                    NUMBER;
 x_AMT_MIN_RELEASE_T                    NUMBER;
 x_AMT_RELEASED_G                       NUMBER;
 x_AMT_RELEASED_T                       NUMBER;
 x_APPROVED_DATE_FK                     NUMBER;
 x_APPROVED_FK                          NUMBER;
 x_APPROVER_FK                          NUMBER;
 x_AP_TERMS_FK                          NUMBER;
 x_BASE_UOM_FK                          NUMBER;
 x_BILL_LOCATION_FK                     NUMBER;
 x_BUYER_FK                             NUMBER;
 x_CANCELLED_FK                         NUMBER;
 x_CANCEL_REASON                        NUMBER;
 x_COMMENTS                             NUMBER;
 x_CONFIRM_ORDER_FK                     NUMBER;
 x_CONTRACT_EFFECTIVE_FK                NUMBER;
 x_CREATION_DATE                        NUMBER;
 x_EDI_PROCESSED_FK                     NUMBER;
 x_END_DATE_FK                          NUMBER;
 x_FOB_FK                               NUMBER;
 x_FREIGHT_TERMS_FK                     NUMBER;
 x_FROZEN_FK                            NUMBER;
 x_INSTANCE_FK                          NUMBER;
 x_ITEM_DESCRIPTION                     NUMBER;
 x_ITEM_ID                              NUMBER;
 x_ITEM_REVISION_FK                     NUMBER;
 x_LAST_UPDATE_DATE                     NUMBER;
 x_LIST_PRICE_G                         NUMBER;
 x_LIST_PRICE_T                         NUMBER;
 x_LNE_CLOSED_FK                        NUMBER;
 x_LNE_CREAT_DATE_FK                    NUMBER;
 x_MARKET_PRICE_G                       NUMBER;
 x_MARKET_PRICE_T                       NUMBER;
 x_NEG_BY_PREPARE_FK                    NUMBER;
 x_OPERATING_UNIT_FK                    NUMBER;
 x_PO_CLOSED_FK                         NUMBER;
 x_PO_CREATE_DATE_FK                    NUMBER;
 x_PO_HEADER_ID                         NUMBER;
 x_PO_LINE_ID                           NUMBER;
 x_PO_LINE_TYPE_FK                      NUMBER;
 x_PO_PRINT_DATE_FK                     NUMBER;
 x_PO_SUPPLIER_NOTE                     NUMBER;
 x_PO_TYPE_FK                           NUMBER;
 x_PRICE_BREAK_FK                       NUMBER;
 x_PRICE_LIMIT_G                        NUMBER;
 x_PRICE_LIMIT_T                        NUMBER;
 x_PRICE_TYPE_FK                        NUMBER;
 x_QTY_AGREED_T                         NUMBER;
 x_QTY_MAX_ORDER_T                      NUMBER;
 x_QTY_MIN_ORDER_T                      NUMBER;
 x_QTY_ORDERED_T                        NUMBER;
 x_QTY_RELEASED_T                       NUMBER;
 x_RECEIVER_NOTE                        NUMBER;
 x_USER_HOLD_FK                         NUMBER;
 x_REVISED_DATE_FK                      NUMBER;
 x_SHIP_LOCATION_FK                     NUMBER;
 x_SHIP_VIA_FK                          NUMBER;
 x_START_DATE_FK                        NUMBER;
 x_SUPPLIER_ITEM_NUM_FK                 NUMBER;
 x_SUPPLIER_SITE_FK                     NUMBER;
 x_SUPPLY_AGREE_FK                      NUMBER;
 x_SUP_SITE_GEOG_FK                     NUMBER;
 x_TXN_CUR_CODE_FK                      NUMBER;
 x_TXN_CUR_DATE_FK                      NUMBER;
 x_TXN_REASON_FK                        NUMBER;
 x_TXN_UOM_FK                           NUMBER;
 x_SIC_CODE_FK                          NUMBER;
 x_UNSPSC_FK                            NUMBER;
 x_DUNS_FK                              NUMBER;
 x_UNIT_PRICE_G                         NUMBER;
 x_UNIT_PRICE_T                         NUMBER;
 x_TXN_CUR_RATE_TYPE                    NUMBER;
 x_category_id                          NUMBER;

-------------------------------------------------------------

  CURSOR c_1 IS
        SELECT  avg(nvl(vsize(agent_id), 0)),
        avg(nvl(vsize(po_header_id), 0)),
        avg(nvl(vsize(vendor_site_id), 0)),
        avg(nvl(vsize(org_id), 0)),
        avg(nvl(vsize(terms_id), 0)),
        avg(nvl(vsize(closed_code), 0)),
        avg(nvl(vsize(type_lookup_code), 0)),
        avg(nvl(vsize(ship_via_lookup_code), 0)),
        avg(nvl(vsize(fob_lookup_code), 0)),
        avg(nvl(vsize(freight_terms_lookup_code), 0)),
        avg(nvl(vsize(acceptance_required_flag), 0)),
        avg(nvl(vsize(frozen_flag), 0)),
        avg(nvl(vsize(bill_to_location_id), 0)),
        avg(nvl(vsize(ship_to_location_id), 0)),
        avg(nvl(vsize(vendor_site_id), 0)),
        avg(nvl(vsize(currency_code), 0)),
        avg(nvl(vsize(comments), 0)),
        avg(nvl(vsize(note_to_receiver), 0)),
        avg(nvl(vsize(note_to_vendor), 0)),
        avg(nvl(vsize(approved_flag), 0)),
        avg(nvl(vsize(user_hold_flag), 0)),
        avg(nvl(vsize(confirming_order_flag), 0)),
        avg(nvl(vsize(supply_agreement_flag), 0)),
        avg(nvl(vsize(edi_processed_flag), 0))
        from PO_HEADERS_ALL
        where last_update_date between
                  p_from_date  and  p_to_date;

--------

  CURSOR c_2 IS
        SELECT  avg(nvl(vsize(po_line_id), 0)),
        avg(nvl(vsize(ITEM_REVISION), 0)),
        avg(nvl(vsize(item_id), 0)),
        avg(nvl(vsize(item_description), 0)),
        avg(nvl(vsize(category_id), 0)),
        avg(nvl(vsize(transaction_reason_code), 0)),
        avg(nvl(vsize(price_type_lookup_code), 0)),
        avg(nvl(vsize(price_break_lookup_code), 0)),
        avg(nvl(vsize(negotiated_by_preparer_flag), 0)),
        avg(nvl(vsize(cancel_flag), 0)),
        avg(nvl(vsize(closed_flag), 0)),
        avg(nvl(vsize(VENDOR_PRODUCT_NUM), 0)),
        avg(nvl(vsize(po_header_id), 0)),
        avg(nvl(vsize(po_line_id), 0)),
        avg(nvl(vsize(note_to_vendor), 0)),
        avg(nvl(vsize(cancel_reason), 0))
        from PO_LINES_ALL
        where last_update_date between
              p_from_date  and  p_to_date;

--------

  CURSOR c_3 IS
        SELECT  avg(nvl(vsize(line_type), 0))
        from PO_LINE_TYPES
        where last_update_date between
                   p_from_date  and  p_to_date;
--------

  CURSOR c_4 IS
        SELECT  avg(nvl(vsize(vendor_name), 0))
        from PO_VENDORS
        where last_update_date between
                   p_from_date  and  p_to_date;


  CURSOR c_5 IS
        SELECT  avg(nvl(vsize(inventory_organization_id), 0))
        from FINANCIALS_SYSTEM_PARAMS_ALL
        where last_update_date between
                   p_from_date  and  p_to_date;

  CURSOR c_6 IS
        SELECT  avg(nvl(vsize(currency_code), 0))
        from gl_sets_of_books
        where last_update_date between
                   p_from_date  and  p_to_date;

  CURSOR c_7 IS
        SELECT avg(nvl(vsize(uom_code), 0))
        from  mtl_units_of_measure
        where last_update_date between
                   p_from_date  and  p_to_date;

  BEGIN

--    dbms_output.enable(100000);

-- all date FKs

    x_ACCPT_DUE_DATE_FK := x_date;
    x_APPROVED_DATE_FK  := x_date;
    x_END_DATE_FK       := x_date;
    x_LNE_CREAT_DATE_FK := x_date;
    x_PO_CREATE_DATE_FK := x_date;
    x_PO_PRINT_DATE_FK  := x_date;
    x_REVISED_DATE_FK   := x_date;
    x_START_DATE_FK     := x_date;
    x_TXN_CUR_DATE_FK   := x_date;

    x_total := 3 + x_total
                 + ceil (x_ACCPT_DUE_DATE_FK + 1)
                 + ceil (x_APPROVED_DATE_FK  + 1)
                 + ceil (x_END_DATE_FK       + 1)
                 + ceil (x_LNE_CREAT_DATE_FK + 1)
                 + ceil (x_PO_CREATE_DATE_FK + 1)
                 + ceil (x_PO_PRINT_DATE_FK  + 1)
                 + ceil (x_REVISED_DATE_FK   + 1)
                 + ceil (x_START_DATE_FK     + 1)
                 + ceil (x_TXN_CUR_DATE_FK   + 1);

-- all calculated numbers

    x_qty_released_t       := x_float;
    x_qty_ordered_t        := x_float;
    x_qty_min_order_t      := x_float;
    x_qty_max_order_t      := x_float;
    x_qty_agreed_t         := x_float;

    x_amt_released_t       := x_float;
    x_amt_released_g       := x_float;
    x_amt_agreed_t         := x_float;
    x_amt_agreed_g         := x_float;
    x_amt_min_release_t    := x_float;
    x_amt_min_release_g    := x_float;
    x_amt_released_t       := x_float;
    x_amt_released_g       := x_float;

    x_market_price_t       := x_float;
    x_market_price_g       := x_float;
    x_price_limit_t        := x_float;
    x_price_limit_g        := x_float;
    x_list_price_t         := x_float;
    x_list_price_g         := x_float;
    x_unit_price_t         := x_float;
    x_unit_price_g         := x_float;


    x_total := x_total
         + ceil(x_qty_released_t + 1)
         + ceil(x_qty_ordered_t + 1)
         + ceil(x_qty_min_order_t + 1)
         + ceil(x_qty_max_order_t + 1)
         + ceil(x_qty_agreed_t + 1)
         + ceil(x_amt_released_t + 1)
         + ceil(x_amt_released_g + 1)
         + ceil(x_amt_agreed_t + 1)
         + ceil(x_amt_agreed_g + 1)
         + ceil(x_amt_min_release_t + 1)
         + ceil(x_amt_min_release_g + 1)
         + ceil(x_amt_released_t + 1)
         + ceil(x_amt_released_g + 1)
         + ceil(x_market_price_t + 1)
         + ceil(x_market_price_g + 1)
         + ceil(x_price_limit_t + 1)
         + ceil(x_price_limit_g + 1)
         + ceil(x_list_price_t + 1)
         + ceil(x_list_price_g + 1)
         + ceil(x_unit_price_t + 1)
         + ceil(x_unit_price_g + 1);

-----------------------------------------------------


    OPEN c_1;
      FETCH c_1 INTO x_buyer_fk, x_PO_HEADER_ID, x_supplier_site_fk,
         x_operating_unit_fk, x_ap_terms_fk, x_po_closed_fk,
         x_po_type_fk, x_ship_via_fk, x_fob_fk, x_freight_terms_fk,
         x_accpt_required_fk, x_frozen_fk, x_bill_location_fk,
         x_ship_location_fk, x_sup_site_geog_fk, x_txn_cur_code_fk,
         x_comments, x_receiver_note,
         x_po_supplier_note, x_approved_fk, x_user_hold_fk,
         x_confirm_order_fk, x_supply_agree_fk, x_edi_processed_fk;
    CLOSE c_1;

    x_approver_fk := x_buyer_fk;
    x_supplier_item_num_fk := x_supplier_site_fk;
    x_supplier_site_fk := x_supplier_site_fk + x_operating_unit_fk;
    x_sup_site_geog_fk := x_sup_site_geog_fk + x_operating_unit_fk;


    x_total := x_total
         + NVL (ceil(x_buyer_fk + 1), 0)
         + NVL (ceil(x_approver_fk + 1), 0)
         + NVL (ceil(x_PO_HEADER_ID + 1), 0)
         + NVL (ceil(x_supplier_site_fk + 1), 0)
         + NVL (ceil(x_operating_unit_fk + 1), 0)
         + NVL (ceil(x_ap_terms_fk + 1), 0)
         + NVL (ceil(x_po_closed_fk + 1), 0)
         + NVL (ceil(x_po_type_fk + 1), 0)
         + NVL (ceil(x_ship_via_fk + 1), 0)
         + NVL (ceil(x_fob_fk + 1), 0)
         + NVL (ceil(x_freight_terms_fk + 1), 0)
         + NVL (ceil(x_accpt_required_fk + 1), 0)
         + NVL (ceil(x_frozen_fk + 1), 0)
         + NVL (ceil(x_bill_location_fk + 1), 0)
         + NVL (ceil(x_ship_location_fk + 1), 0)
         + NVL (ceil(x_sup_site_geog_fk + 1), 0)
         + NVL (ceil(x_txn_cur_code_fk + 1), 0)
         + NVL (ceil(x_comments + 1), 0)
         + NVL (ceil(x_receiver_note + 1), 0)
         + NVL (ceil(x_po_supplier_note + 1), 0)
         + NVL (ceil(x_approved_fk + 1), 0)
         + NVL (ceil(x_user_hold_fk + 1), 0)
         + NVL (ceil(x_confirm_order_fk + 1), 0)
         + NVL (ceil(x_supply_agree_fk + 1), 0)
         + NVL (ceil(x_edi_processed_fk + 1), 0)
         + NVL (ceil(x_supplier_item_num_fk + 1), 0);

--------------------------------------------------------------------

    OPEN c_2;
      FETCH c_2 INTO x_agree_ln_inst_pk, x_item_revision_fk,
          x_item_id, x_item_description, x_category_id,
          x_txn_reason_fk, x_price_type_fk,
          x_price_break_fk, x_neg_by_prepare_fk,
          x_cancelled_fk, x_lne_closed_fk,
          x_supplier_item_num_fk, x_po_header_id, x_po_line_id,
          x_po_supplier_note, x_cancel_reason;
    CLOSE c_2;

    x_item_revision_fk := x_item_revision_fk + x_item_id +
                          x_item_description + x_category_id;
    x_base_uom_fk    := x_item_id;
    x_txn_uom_fk     := x_item_id;

    x_total := x_total
            + NVL (ceil(x_agree_ln_inst_pk + 1), 0)
            + NVL (ceil(x_item_revision_fk + 1), 0)
            + NVL (ceil(x_item_id + 1), 0)
            + NVL (ceil(x_item_description + 1), 0)
            + NVL (ceil(x_txn_reason_fk + 1), 0)
            + NVL (ceil(x_price_type_fk + 1), 0)
            + NVL (ceil(x_price_break_fk + 1), 0)
            + NVL (ceil(x_neg_by_prepare_fk + 1), 0)
            + NVL (ceil(x_cancelled_fk + 1), 0)
            + NVL (ceil(x_lne_closed_fk + 1), 0)
            + NVL (ceil(x_supplier_item_num_fk + 1), 0)
            + NVL (ceil(x_po_header_id + 1), 0)
            + NVL (ceil(x_po_line_id + 1), 0)
            + NVL (ceil(x_po_supplier_note + 1), 0)
            + NVL (ceil(x_cancel_reason + 1), 0)
            + NVL (ceil(x_base_uom_fk + 1), 0)
            + NVL (ceil(x_txn_uom_fk + 1), 0);

---------------------------------------------------------------------

    OPEN c_3;
      FETCH c_3 INTO x_po_line_type_fk;
    CLOSE c_3;

    x_total := x_total + NVL (ceil(x_po_line_type_fk + 1), 0);



    OPEN c_4;
      FETCH c_4 INTO x_supplier_item_num_fk;
    CLOSE c_4;

    x_total := x_total + NVL (ceil(x_supplier_item_num_fk + 1), 0);



    OPEN c_5;
      FETCH c_5 INTO x_item_revision_fk;
    CLOSE c_5;

    x_total := x_total + NVL (ceil(x_item_revision_fk + 1), 0);


    OPEN c_6;
      FETCH c_6 INTO x_txn_cur_code_fk;
    CLOSE c_6;

    x_total := x_total + NVL (ceil(x_txn_cur_code_fk + 1), 0);


    OPEN c_7;
      FETCH c_7 INTO x_base_uom_fk;
    CLOSE c_7;

    x_txn_uom_fk := x_base_uom_fk;

    x_total := x_total
         + NVL (ceil(x_txn_uom_fk + 1), 0)
         + NVL (ceil(x_base_uom_fk + 1), 0);
------------------------------------------------------------------

--    dbms_output.put_line('     ');
--    dbms_output.put_line('The average row length for agreement lines is: '
--                        || to_char(x_total));

    p_avg_row_len := x_total;

EXCEPTION
    WHEN OTHERS THEN p_avg_row_len := 0;
END;  -- procedure est_row_len.

END;

/
