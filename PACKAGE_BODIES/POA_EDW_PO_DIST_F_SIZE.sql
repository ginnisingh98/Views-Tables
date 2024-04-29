--------------------------------------------------------
--  DDL for Package Body POA_EDW_PO_DIST_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_PO_DIST_F_SIZE" AS
/*$Header: poaszpdb.pls 120.0 2005/06/01 19:49:27 appldev noship $ */

PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                        p_to_date   IN  DATE,
                        p_num_rows  OUT NOCOPY NUMBER) IS

BEGIN

--    dbms_output.enable(100000);

    select count(*) into p_num_rows
    from
	po_distributions_all			pod,
	po_line_locations_all			pll,
	po_lines_all				pol,
	po_headers_all				poh
   WHERE pll.shipment_type          in ('BLANKET', 'SCHEDULED', 'STANDARD')
     and pll.approved_flag          = 'Y'
     and pll.line_location_id       = pod.line_location_id
     and pod.po_line_id             = pol.po_line_id
     and pod.po_header_id           = poh.po_header_id
     and greatest(pol.last_update_date, poh.last_update_date,
                  pll.last_update_date, pod.last_update_date)
           between p_from_date and p_to_date;

--    dbms_output.put_line('The number of rows for PO distribution is: '
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

 x_ACCPT_DUE_DATE_FK                        NUMBER;
 x_ACCPT_REQUIRED_FK                        NUMBER;
 x_ACCRUED_FK                               NUMBER;
 x_AMT_BILLED_G                             NUMBER;
 x_AMT_BILLED_T                             NUMBER;
 x_AMT_CONTRACT_G                           NUMBER;
 x_AMT_CONTRACT_T                           NUMBER;
 x_AMT_LEAKAGE_G                            NUMBER;
 x_AMT_LEAKAGE_T                            NUMBER;
 x_AMT_NONCONTRACT_G                        NUMBER;
 x_AMT_NONCONTRACT_T                        NUMBER;
 x_AMT_PURCHASED_G                          NUMBER;
 x_AMT_PURCHASED_T                          NUMBER;
 x_APPROVER_FK                              NUMBER;
 x_AP_TERMS_FK                              NUMBER;
 x_BILL_LOCATION_FK                         NUMBER;
 x_BUYER_FK                                 NUMBER;
 x_COLLECTION_STATUS                        NUMBER;
 x_CONFIRM_ORDER_FK                         NUMBER;
 x_CONTRACT_NUM                             NUMBER;
 x_CONTRACT_TYPE_FK                         NUMBER;
 x_DELIVER_TO_FK                            NUMBER;
 x_DELIV_LOCATION_FK                        NUMBER;
 x_DESTIN_ORG_FK                            NUMBER;
 x_DESTIN_TYPE_FK                           NUMBER;
 x_DISTRIBUTION_ID                          NUMBER;
 x_DST_CREAT_DATE_FK                        NUMBER;
 x_DST_ENCUMB_FK                            NUMBER;
 x_EDI_PROCESSED_FK                         NUMBER;
 x_ERROR_CODE                               NUMBER;
 x_FOB_FK                                   NUMBER;
 x_FREIGHT_TERMS_FK                         NUMBER;
 x_FROZEN_FK                                NUMBER;
 x_INSPECTION_REQ_FK                        NUMBER;
 x_INSTANCE_FK                              NUMBER;
 x_ITEM_DESCRIPTION                         NUMBER;
 x_ITEM_ID                                  NUMBER;
 x_ITEM_FK                                  NUMBER;
 x_LINE_LOCATION_ID                         NUMBER;
 x_LIST_PRC_UNIT_G                          NUMBER;
 x_LIST_PRC_UNIT_T                          NUMBER;
 x_LNE_CREAT_DATE_FK                        NUMBER;
 x_LNE_SUPPLIER_NOTE                        NUMBER;
 x_LST_ACCPT_DATE_FK                        NUMBER;
 x_MARKET_PRICE_G                           NUMBER;
 x_MARKET_PRICE_T                           NUMBER;
 x_NEED_BY_DATE_FK                          NUMBER;
 x_NEG_BY_PREPARE_FK                        NUMBER;
 x_ONLINE_REQ_FK                            NUMBER;
 x_OPERATION_CODE                           NUMBER;
 x_PCARD_PROCESS_FK                         NUMBER;
 x_POTENTIAL_SVG_G                          NUMBER;
 x_POTENTIAL_SVG_T                          NUMBER;
 x_PO_ACCEPT_DATE_FK                        NUMBER;
 x_PO_APP_DATE_FK                           NUMBER;
 x_PO_COMMENTS                              NUMBER;
 x_PO_CREATE_DATE_FK                        NUMBER;
 x_PO_DIST_INST_PK                          NUMBER;
 x_PO_HEADER_ID                             NUMBER;
 x_PO_LINE_ID                               NUMBER;
 x_PO_LINE_TYPE_FK                          NUMBER;
 x_PO_NUMBER                                NUMBER;
 x_PO_RECEIVER_NOTE                         NUMBER;
 x_PO_RELEASE_ID                            NUMBER;
 x_PRICE_BREAK_FK                           NUMBER;
 x_PRICE_G                                  NUMBER;
 x_PRICE_T                                  NUMBER;
 x_PRICE_LIMIT_G                            NUMBER;
 x_PRICE_LIMIT_T                            NUMBER;
 x_PRICE_TYPE_FK                            NUMBER;
 x_PRINTED_DATE_FK                          NUMBER;
 x_PROMISED_DATE_FK                         NUMBER;
 x_PURCH_CLASS_FK                           NUMBER;
 x_QTY_BILLED_B                             NUMBER;
 x_QTY_CANCELLED_B                          NUMBER;
 x_QTY_DELIVERED_B                          NUMBER;
 x_QTY_ORDERED_B                            NUMBER;
 x_RCV_ROUTING_FK                           NUMBER;
 x_RECEIPT_REQ_FK                           NUMBER;
 x_RELEASE_DATE_FK                          NUMBER;
 x_RELEASE_HOLD_FK                          NUMBER;
 x_RELEASE_NUM                              NUMBER;
 x_REQUEST_ID                               NUMBER;
 x_REQ_APPRV_DATE_FK                        NUMBER;
 x_REQ_CREAT_DATE_FK                        NUMBER;
 x_REVISED_DATE_FK                          NUMBER;
 x_REVISION_NUM                             NUMBER;
 x_ROW_ID                                   NUMBER;
 x_SHIPMENT_TYPE_FK                         NUMBER;
 x_SHIP_LOCATION_FK                         NUMBER;
 x_SHIP_TO_ORG_FK                           NUMBER;
 x_SHIP_VIA_FK                              NUMBER;
 x_SHP_APPROVED_FK                          NUMBER;
 x_SHP_APP_DATE_FK                          NUMBER;
 x_SHP_CANCELLED_FK                         NUMBER;
 x_SHP_CANCEL_REASON                        NUMBER;
 x_SHP_CLOSED_FK                            NUMBER;
 x_SHP_CLOSED_REASON                        NUMBER;
 x_SHP_CREAT_DATE_FK                        NUMBER;
 x_SHP_SRC_SHIP_ID                          NUMBER;
 x_SHP_TAXABLE_FK                           NUMBER;
 x_SOB_FK                                   NUMBER;
 x_SOURCE_DIST_ID                           NUMBER;
 x_SUB_RECEIPT_FK                           NUMBER;
 x_SUPPLIER_ITEM_FK                         NUMBER;
 x_SUPPLIER_NOTE                            NUMBER;
 x_SUPPLIER_SITE_FK                         NUMBER;
 x_SUP_SITE_GEOG_FK                         NUMBER;
 x_TXN_CUR_CODE_FK                          NUMBER;
 x_TXN_CUR_DATE_FK                          NUMBER;
 x_TXN_REASON_FK                            NUMBER;
 x_EDW_UOM_FK                               NUMBER;
 x_EDW_BASE_UOM_FK                          NUMBER;
 x_IPV_G                                    NUMBER;
 x_IPV_T                                    NUMBER;
 x_INV_TO_PAY_CYCLE_TIME                    NUMBER;
 x_INV_CREATION_CYCLE_TIME                  NUMBER;
 x_RECEIVE_TO_PAY_CYCL_TIME                 NUMBER;
 x_ORDER_TO_PAY_CYCLE_TIME                  NUMBER;
 x_PO_CREATION_CYCLE_TIME                   NUMBER;
 x_TASK_FK                                  NUMBER;
 x_PROJECT_FK                               NUMBER;
 x_APPRV_SUPPLIER_FK                        NUMBER;
 x_GOODS_RECEIVED_DATE_FK                   NUMBER;
 x_INV_CREATION_DATE_FK                     NUMBER;
 x_INV_RECEIVED_DATE_FK                     NUMBER;
 x_CHECK_CUT_DATE_FK                        NUMBER;
 x_SIC_CODE_FK                              NUMBER;
 x_UNSPSC_FK                                NUMBER;
 x_DUNS_FK                                  NUMBER;

 x_category_id                              NUMBER;
 x_item_revision                            NUMBER;
 x_org_id                                   NUMBER;


  CURSOR c_1 IS
        SELECT  avg(nvl(vsize(po_distribution_id), 0)),
        avg(nvl(vsize(deliver_to_person_id), 0)),
        avg(nvl(vsize(destination_organization_id), 0)),
        avg(nvl(vsize(set_of_books_id), 0)),
        avg(nvl(vsize(deliver_to_location_id), 0)),
        avg(nvl(vsize(task_id), 0)),
        avg(nvl(vsize(project_id), 0)),
        avg(nvl(vsize(destination_type_code), 0)),
        avg(nvl(vsize(accrued_flag), 0)),
        avg(nvl(vsize(encumbered_flag), 0)),
        avg(nvl(vsize(req_distribution_id), 0)),
        avg(nvl(vsize(line_location_id), 0)),
        avg(nvl(vsize(po_header_id), 0)),
        avg(nvl(vsize(po_line_id), 0)),
        avg(nvl(vsize(po_release_id), 0)),
        avg(nvl(vsize(source_distribution_id), 0))
        from po_distributions_all
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_2 IS
        SELECT  avg(nvl(vsize(vendor_product_num), 0)),
        avg(nvl(vsize(item_id), 0)),
        avg(nvl(vsize(ITEM_REVISION), 0)),
        avg(nvl(vsize(category_id), 0)),
        avg(nvl(vsize(transaction_reason_code), 0)),
        avg(nvl(vsize(price_type_lookup_code), 0)),
        avg(nvl(vsize(price_break_lookup_code), 0)),
        avg(nvl(vsize(negotiated_by_preparer_flag), 0)),
        avg(nvl(vsize(item_description), 0)),
        avg(nvl(vsize(note_to_vendor), 0)),
        avg(nvl(vsize(contract_num), 0))
        from po_lines_all
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_3 IS
        SELECT  avg(nvl(vsize(line_location_id), 0)),
        avg(nvl(vsize(ship_to_organization_id), 0)),
        avg(nvl(vsize(ship_to_location_id), 0)),
        avg(nvl(vsize(shipment_type), 0)),
        avg(nvl(vsize(closed_code), 0)),
        avg(nvl(vsize(allow_substitute_receipts_flag), 0)),
        avg(nvl(vsize(approved_flag), 0)),
        avg(nvl(vsize(cancel_flag), 0)),
        avg(nvl(vsize(inspection_required_flag), 0)),
        avg(nvl(vsize(receipt_required_flag), 0)),
        avg(nvl(vsize(taxable_flag), 0)),
        avg(nvl(vsize(cancel_reason), 0)),
        avg(nvl(vsize(closed_reason), 0)),
        avg(nvl(vsize(source_shipment_id), 0))
        from po_line_locations_all
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_4 IS
        SELECT avg(nvl(vsize(agent_id), 0)),
        avg(nvl(vsize(vendor_site_id), 0)),
        avg(nvl(vsize(org_id), 0)),
        avg(nvl(vsize(bill_to_location_id), 0)),
        avg(nvl(vsize(terms_id), 0)),
        avg(nvl(vsize(ship_via_lookup_code), 0)),
        avg(nvl(vsize(fob_lookup_code), 0)),
        avg(nvl(vsize(freight_terms_lookup_code), 0)),
        avg(nvl(vsize(acceptance_required_flag), 0)),
        avg(nvl(vsize(frozen_flag), 0)),
        avg(nvl(vsize(user_hold_flag), 0)),
        avg(nvl(vsize(confirming_order_flag), 0)),
        avg(nvl(vsize(edi_processed_flag), 0)),
        avg(nvl(vsize(pcard_id), 0)),
        avg(nvl(vsize(currency_code), 0)),
        avg(nvl(vsize(note_to_vendor), 0)),
        avg(nvl(vsize(comments), 0)),
        avg(nvl(vsize(note_to_receiver), 0)),
        avg(nvl(vsize(revision_num), 0)),
        avg(nvl(vsize(segment1), 0))
        from po_headers_all
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_5 IS
        SELECT  avg(nvl(vsize(routing_name), 0))
        from rcv_routing_headers;

  CURSOR c_6 IS
        SELECT  avg(nvl(vsize(uom_code), 0))
        from mtl_units_of_measure
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_7 IS
        SELECT  avg(nvl(vsize(line_type), 0))
        from po_line_types
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_8 IS
        SELECT  avg(nvl(vsize(release_num), 0))
        from po_releases_all
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_9 IS
        SELECT  avg(nvl(vsize(inventory_organization_id), 0))
        from FINANCIALS_SYSTEM_PARAMS_ALL
        where last_update_date between
                   p_from_date  and  p_to_date;

  CURSOR c_10 IS
        SELECT  avg(nvl(vsize(vendor_name), 0))
        from PO_VENDORS
        where last_update_date between
                   p_from_date  and  p_to_date;


  BEGIN

--    dbms_output.enable(100000);

-- all date FKs

    x_ACCPT_DUE_DATE_FK       := x_date;
    x_DST_CREAT_DATE_FK       := x_date;
    x_LNE_CREAT_DATE_FK       := x_date;
    x_LST_ACCPT_DATE_FK       := x_date;
    x_NEED_BY_DATE_FK         := x_date;
    x_PO_ACCEPT_DATE_FK       := x_date;
    x_PO_APP_DATE_FK          := x_date;
    x_PO_CREATE_DATE_FK       := x_date;
    x_PRINTED_DATE_FK         := x_date;
    x_PROMISED_DATE_FK        := x_date;
    x_RELEASE_DATE_FK         := x_date;
    x_REQ_APPRV_DATE_FK       := x_date;
    x_REQ_CREAT_DATE_FK       := x_date;
    x_REVISED_DATE_FK         := x_date;
    x_SHP_APP_DATE_FK         := x_date;
    x_SHP_CREAT_DATE_FK       := x_date;
    x_TXN_CUR_DATE_FK         := x_date;
    x_GOODS_RECEIVED_DATE_FK  := x_date;
    x_INV_CREATION_DATE_FK    := x_date;
    x_INV_RECEIVED_DATE_FK    := x_date;
    x_CHECK_CUT_DATE_FK       := x_date;

    x_total := 3 + x_total
                 + ceil (x_ACCPT_DUE_DATE_FK + 1)
                 + ceil (x_DST_CREAT_DATE_FK + 1)
                 + ceil (x_LNE_CREAT_DATE_FK + 1)
                 + ceil (x_LST_ACCPT_DATE_FK + 1)
                 + ceil (x_NEED_BY_DATE_FK + 1)
                 + ceil (x_PO_ACCEPT_DATE_FK + 1)
                 + ceil (x_PO_APP_DATE_FK + 1)
                 + ceil (x_PO_CREATE_DATE_FK + 1)
                 + ceil (x_PRINTED_DATE_FK + 1)
                 + ceil (x_PROMISED_DATE_FK + 1)
                 + ceil (x_RELEASE_DATE_FK + 1)
                 + ceil (x_REQ_APPRV_DATE_FK + 1)
                 + ceil (x_REQ_CREAT_DATE_FK + 1)
                 + ceil (x_REVISED_DATE_FK + 1)
                 + ceil (x_SHP_APP_DATE_FK + 1)
                 + ceil (x_SHP_CREAT_DATE_FK + 1)
                 + ceil (x_TXN_CUR_DATE_FK + 1)
                 + ceil (x_GOODS_RECEIVED_DATE_FK + 1)
                 + ceil (x_INV_CREATION_DATE_FK + 1)
                 + ceil (x_INV_RECEIVED_DATE_FK + 1)
                 + ceil (x_CHECK_CUT_DATE_FK + 1);

-- all calculated numbers

     x_AMT_BILLED_G     := x_float;
     x_AMT_BILLED_T     := x_float;
     x_AMT_CONTRACT_G   := x_float;
     x_AMT_CONTRACT_T   := x_float;
     x_AMT_LEAKAGE_G    := x_float;
     x_AMT_LEAKAGE_T    := x_float;
     x_AMT_NONCONTRACT_G := x_float;
     x_AMT_NONCONTRACT_T := x_float;
     x_AMT_PURCHASED_G  := x_float;
     x_AMT_PURCHASED_T  := x_float;
     x_QTY_BILLED_B     := x_float;
     x_QTY_CANCELLED_B  := x_float;
     x_QTY_DELIVERED_B  := x_float;
     x_QTY_ORDERED_B    := x_float;
     x_MARKET_PRICE_G   := x_float;
     x_MARKET_PRICE_T   := x_float;
     x_LIST_PRC_UNIT_G  := x_float;
     x_LIST_PRC_UNIT_T  := x_float;
     x_POTENTIAL_SVG_G  := x_float;
     x_POTENTIAL_SVG_T  := x_float;
     x_PRICE_G          := x_float;
     x_PRICE_T          := x_float;
     x_PRICE_LIMIT_G    := x_float;
     x_PRICE_LIMIT_T    := x_float;
     x_IPV_G            := x_float;
     x_IPV_T            := x_float;

     x_INV_TO_PAY_CYCLE_TIME    := x_float;
     x_INV_CREATION_CYCLE_TIME  := x_float;
     x_RECEIVE_TO_PAY_CYCL_TIME := x_float;
     x_ORDER_TO_PAY_CYCLE_TIME  := x_float;
     x_PO_CREATION_CYCLE_TIME   := x_float;

    x_total := x_total
                 + ceil (x_AMT_BILLED_G + 1)
                 + ceil (x_AMT_BILLED_T + 1)
                 + ceil (x_AMT_CONTRACT_G + 1)
                 + ceil (x_AMT_CONTRACT_T + 1)
                 + ceil (x_AMT_LEAKAGE_G + 1)
                 + ceil (x_AMT_LEAKAGE_T + 1)
                 + ceil (x_AMT_NONCONTRACT_G + 1)
                 + ceil (x_AMT_NONCONTRACT_T + 1)
                 + ceil (x_AMT_PURCHASED_G + 1)
                 + ceil (x_AMT_PURCHASED_T + 1)
                 + ceil (x_QTY_BILLED_B + 1)
                 + ceil (x_QTY_CANCELLED_B + 1)
                 + ceil (x_QTY_DELIVERED_B + 1)
                 + ceil (x_QTY_ORDERED_B + 1)
                 + ceil (x_MARKET_PRICE_G + 1)
                 + ceil (x_MARKET_PRICE_T + 1)
                 + ceil (x_LIST_PRC_UNIT_G + 1)
                 + ceil (x_LIST_PRC_UNIT_T + 1)
                 + ceil (x_POTENTIAL_SVG_G + 1)
                 + ceil (x_POTENTIAL_SVG_T + 1)
                 + ceil (x_PRICE_G + 1)
                 + ceil (x_PRICE_T + 1)
                 + ceil (x_PRICE_LIMIT_G + 1)
                 + ceil (x_PRICE_LIMIT_T + 1)
                 + ceil (x_IPV_G + 1)
                 + ceil (x_IPV_T + 1)
                 + ceil (x_INV_TO_PAY_CYCLE_TIME + 1)
                 + ceil (x_INV_CREATION_CYCLE_TIME + 1)
                 + ceil (x_RECEIVE_TO_PAY_CYCL_TIME + 1)
                 + ceil (x_ORDER_TO_PAY_CYCLE_TIME + 1)
                 + ceil (x_PO_CREATION_CYCLE_TIME + 1);


-------------------------------------------------------------

    OPEN c_1;
      FETCH c_1 INTO x_PO_DIST_INST_PK, x_DELIVER_TO_FK, x_DESTIN_ORG_FK,
      x_SOB_FK, x_DELIV_LOCATION_FK, x_TASK_FK, x_PROJECT_FK,
      x_DESTIN_TYPE_FK , x_ACCRUED_FK, x_DST_ENCUMB_FK, x_ONLINE_REQ_FK,
      x_LINE_LOCATION_ID, x_PO_HEADER_ID, x_PO_LINE_ID,
      x_PO_RELEASE_ID, x_SOURCE_DIST_ID;
    CLOSE c_1;

    x_APPRV_SUPPLIER_FK := x_PO_DIST_INST_PK;
    x_DISTRIBUTION_ID   := x_PO_DIST_INST_PK;

    x_total := x_total
               + NVL (ceil(x_PO_DIST_INST_PK + 1), 0)
               + NVL (ceil(x_DELIVER_TO_FK + 1), 0)
               + NVL (ceil(x_DESTIN_ORG_FK + 1), 0)
               + NVL (ceil(x_SOB_FK + 1), 0)
               + NVL (ceil(x_DELIV_LOCATION_FK + 1), 0)
               + NVL (ceil(x_TASK_FK + 1), 0)
               + NVL (ceil(x_PROJECT_FK + 1), 0)
               + NVL (ceil(x_DESTIN_TYPE_FK + 1), 0)
               + NVL (ceil(x_ACCRUED_FK + 1), 0)
               + NVL (ceil(x_DST_ENCUMB_FK + 1), 0)
               + NVL (ceil(x_ONLINE_REQ_FK + 1), 0)
               + NVL (ceil(x_LINE_LOCATION_ID + 1), 0)
               + NVL (ceil(x_PO_HEADER_ID + 1), 0)
               + NVL (ceil(x_PO_LINE_ID + 1), 0)
               + NVL (ceil(x_PO_RELEASE_ID + 1), 0)
               + NVL (ceil(x_SOURCE_DIST_ID + 1), 0)
               + NVL (ceil(x_APPRV_SUPPLIER_FK + 1), 0)
               + NVL (ceil(x_DISTRIBUTION_ID + 1), 0);

--------------------------------------------------------

    OPEN c_2;
      FETCH c_2 INTO x_supplier_item_fk, x_ITEM_ID,
      x_ITEM_REVISION, x_category_id, x_TXN_REASON_FK,
      x_PRICE_TYPE_FK, x_PRICE_BREAK_FK,
      x_NEG_BY_PREPARE_FK, x_ITEM_DESCRIPTION,
      x_LNE_SUPPLIER_NOTE, x_CONTRACT_NUM;
    CLOSE c_2;

    x_item_fk          := x_ITEM_ID + x_ITEM_REVISION +
                          x_category_id + x_ITEM_DESCRIPTION;
    x_edw_base_uom_fk  := x_ITEM_ID;
    x_edw_uom_fk       := x_ITEM_ID;
    x_contract_type_fk := x_CONTRACT_NUM;

    x_total := x_total
           + NVL (ceil(x_ITEM_ID + 1), 0)
           + NVL (ceil(x_TXN_REASON_FK + 1), 0)
           + NVL (ceil(x_PRICE_TYPE_FK + 1), 0)
           + NVL (ceil(x_PRICE_BREAK_FK + 1), 0)
           + NVL (ceil(x_NEG_BY_PREPARE_FK + 1), 0)
           + NVL (ceil(x_ITEM_DESCRIPTION + 1), 0)
           + NVL (ceil(x_LNE_SUPPLIER_NOTE + 1), 0)
           + NVL (ceil(x_CONTRACT_NUM + 1), 0)
           + NVL (ceil(x_item_fk + 1), 0)
           + NVL (ceil(x_edw_base_uom_fk + 1), 0)
           + NVL (ceil(x_edw_uom_fk + 1), 0)
           + NVL (ceil(x_SUPPLIER_ITEM_FK + 1), 0)
           + NVL (ceil(x_contract_type_fk + 1), 0);

-----------------------------------------------


    OPEN c_3;
      FETCH c_3 INTO  x_PURCH_CLASS_FK, x_SHIP_TO_ORG_FK,
      x_SHIP_LOCATION_FK, x_SHIPMENT_TYPE_FK, x_SHP_CLOSED_FK,
      x_SUB_RECEIPT_FK, x_SHP_APPROVED_FK, x_SHP_CANCELLED_FK,
      x_INSPECTION_REQ_FK, x_RECEIPT_REQ_FK, x_SHP_TAXABLE_FK,
      x_SHP_CANCEL_REASON, x_SHP_CLOSED_REASON, x_SHP_SRC_SHIP_ID;
    CLOSE c_3;


    x_total := x_total
           + NVL (ceil(x_PURCH_CLASS_FK + 1), 0)
           + NVL (ceil(x_SHIP_TO_ORG_FK + 1), 0)
           + NVL (ceil(x_SHIP_LOCATION_FK + 1), 0)
           + NVL (ceil(x_SHIPMENT_TYPE_FK + 1), 0)
           + NVL (ceil(x_SHP_CLOSED_FK + 1), 0)
           + NVL (ceil(x_SUB_RECEIPT_FK + 1), 0)
           + NVL (ceil(x_SHP_APPROVED_FK + 1), 0)
           + NVL (ceil(x_SHP_CANCELLED_FK + 1), 0)
           + NVL (ceil(x_INSPECTION_REQ_FK + 1), 0)
           + NVL (ceil(x_RECEIPT_REQ_FK + 1), 0)
           + NVL (ceil(x_SHP_TAXABLE_FK + 1), 0)
           + NVL (ceil(x_SHP_CANCEL_REASON + 1), 0)
           + NVL (ceil(x_SHP_CLOSED_REASON + 1), 0)
           + NVL (ceil(x_SHP_SRC_SHIP_ID   + 1), 0);

---------------------------------------------------


    OPEN c_4;
      FETCH c_4 INTO
      x_BUYER_FK, x_SUPPLIER_SITE_FK, x_org_id, x_bill_location_fk,
      x_AP_TERMS_FK, x_SHIP_VIA_FK, x_FOB_FK, x_FREIGHT_TERMS_FK,
      x_ACCPT_REQUIRED_FK, x_FROZEN_FK, x_RELEASE_HOLD_FK,
      x_CONFIRM_ORDER_FK, x_EDI_PROCESSED_FK, x_PCARD_PROCESS_FK,
      x_TXN_CUR_CODE_FK, x_SUPPLIER_NOTE, x_PO_COMMENTS,
      x_PO_RECEIVER_NOTE, x_REVISION_NUM, x_PO_NUMBER;
    CLOSE c_4;

    x_supplier_item_fk := x_SUPPLIER_SITE_FK;
    x_SUPPLIER_SITE_FK := x_SUPPLIER_SITE_FK + x_org_id;
    x_sup_site_geog_fk := x_SUPPLIER_SITE_FK;
    x_APPROVER_FK      := x_BUYER_FK;

    x_total := x_total
           + NVL (ceil(x_BUYER_FK + 1), 0)
           + NVL (ceil(x_APPROVER_FK + 1), 0)
           + NVL (ceil(x_SUPPLIER_SITE_FK + 1), 0)
           + NVL (ceil(x_sup_site_geog_FK + 1), 0)
           + NVL (ceil(x_supplier_item_FK + 1), 0)
           + NVL (ceil(x_bill_location_FK + 1), 0)
           + NVL (ceil(x_AP_TERMS_FK + 1), 0)
           + NVL (ceil(x_SHIP_VIA_FK + 1), 0)
           + NVL (ceil(x_FOB_FK + 1), 0)
           + NVL (ceil(x_FREIGHT_TERMS_FK + 1), 0)
           + NVL (ceil(x_ACCPT_REQUIRED_FK + 1), 0)
           + NVL (ceil(x_FROZEN_FK + 1), 0)
           + NVL (ceil(x_RELEASE_HOLD_FK + 1), 0)
           + NVL (ceil(x_CONFIRM_ORDER_FK + 1), 0)
           + NVL (ceil(x_EDI_PROCESSED_FK + 1), 0)
           + NVL (ceil(x_PCARD_PROCESS_FK + 1), 0)
           + NVL (ceil(x_TXN_CUR_CODE_FK + 1), 0)
           + NVL (ceil(x_SUPPLIER_NOTE + 1), 0)
           + NVL (ceil(x_PO_COMMENTS + 1), 0)
           + NVL (ceil(x_PO_RECEIVER_NOTE + 1), 0)
           + NVL (ceil(x_REVISION_NUM + 1), 0)
           + NVL (ceil(x_PO_NUMBER + 1), 0);


--------------------------------------------------------

    OPEN c_5;
      FETCH c_5 INTO x_RCV_ROUTING_FK;
    CLOSE c_5;
    x_total := x_total + NVL (ceil(x_RCV_ROUTING_FK + 1), 0);

    OPEN c_6;
      FETCH c_6 INTO x_EDW_BASE_UOM_FK;
    CLOSE c_6;

    x_EDW_UOM_FK := x_EDW_BASE_UOM_FK;

    x_total := x_total + NVL (ceil(x_EDW_BASE_UOM_FK + 1), 0)
                       + NVL (ceil(x_EDW_UOM_FK + 1), 0);

    OPEN c_7;
      FETCH c_7 INTO x_PO_LINE_TYPE_FK;
    CLOSE c_7;
    x_total := x_total + NVL (ceil(x_PO_LINE_TYPE_FK + 1), 0);

    OPEN c_8;
      FETCH c_8 INTO x_RELEASE_NUM;
    CLOSE c_8;
    x_total := x_total + NVL (ceil(x_RELEASE_NUM + 1), 0);

    OPEN c_9;
      FETCH c_9 INTO x_item_fk;
    CLOSE c_9;
    x_total := x_total + NVL (ceil(x_item_fk + 1), 0);

    OPEN c_10;
      FETCH c_10 INTO x_supplier_item_fk;
    CLOSE c_10;
    x_total := x_total + NVL (ceil(x_supplier_item_fk + 1), 0);

--------------------------------------------------------

--    dbms_output.put_line('     ');
--    dbms_output.put_line('The average row length for PO distribution is: '
--                        || to_char(x_total));

    p_avg_row_len := x_total;

EXCEPTION
   WHEN OTHERS THEN p_avg_row_len := 0;
END;  -- procedure est_row_len

END;

/
