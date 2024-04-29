--------------------------------------------------------
--  DDL for Package Body POA_EDW_RCV_TXNS_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_RCV_TXNS_F_SIZE" AS
/*$Header: poaszrtb.pls 120.0 2005/06/01 17:20:20 appldev noship $ */

PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                        p_to_date   IN  DATE,
                        p_num_rows  OUT NOCOPY NUMBER) IS
BEGIN

--    dbms_output.enable(100000);

    select count(*) into p_num_rows
      from
           PO_HEADERS_ALL               POH,
           PO_LINES_ALL                 POL,
           PO_LINE_LOCATIONS_ALL        PLL,
           RCV_SHIPMENT_HEADERS         RSH,
           RCV_SHIPMENT_LINES           RSL,
           RCV_TRANSACTIONS             RCV
     WHERE
           RCV.SHIPMENT_HEADER_ID = RSH.SHIPMENT_HEADER_ID
       AND RCV.SHIPMENT_LINE_ID   = RSL.SHIPMENT_LINE_ID
       AND RCV.PO_LINE_LOCATION_ID   = PLL.LINE_LOCATION_ID
       AND PLL.PO_HEADER_ID = POH.PO_HEADER_ID
       AND PLL.PO_LINE_ID   = POL.PO_LINE_ID
       and greatest(pol.last_update_date, poh.last_update_date,
                    pll.last_update_date, rsh.last_update_date,
                    rsl.last_update_date, rcv.last_update_date)
             between p_from_date and p_to_date;

--    dbms_output.put_line('The number of rows for receiving txns is: '
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

 x_SIC_CODE_FK                          NUMBER := 0;
 x_UNSPSC_FK                            NUMBER := 0;
 x_DUNS_FK                              NUMBER := 0;
 x_EDW_UOM_FK                           NUMBER := 0;
 x_EDW_BASE_UOM_FK                      NUMBER := 0;
 x_SUPPLIER_SITE_FK                     NUMBER := 0;
 x_TXN_DATE_FK                          NUMBER := 0;
 x_PARNT_TXN_DATE_FK                    NUMBER := 0;
 x_SRC_CREAT_DATE_FK                    NUMBER := 0;
 x_LST_ACCPT_DATE_FK                    NUMBER := 0;
 x_NEED_BY_DATE_FK                      NUMBER := 0;
 x_PROMISED_DATE_FK                     NUMBER := 0;
 x_EXPCT_RCV_DATE_FK                    NUMBER := 0;
 x_SHIPPED_TO_DATE_FK                   NUMBER := 0;
 x_TXN_CREAT_FK                         NUMBER := 0;
 x_SUPPLIER_ITEM_NUM_FK                 NUMBER := 0;
 x_DELIVER_TO_FK                        NUMBER := 0;
 x_BUYER_FK                             NUMBER := 0;
 x_AP_TERMS_FK                          NUMBER := 0;
 x_RCV_DEL_TO_ORG_FK                    NUMBER := 0;
 x_INSPECT_QUAL_FK                      NUMBER := 0;
 x_INSPECT_STATUS_FK                    NUMBER := 0;
 x_FREIGHT_TERMS_FK                     NUMBER := 0;
 x_PARNT_TXN_TYPE_FK                    NUMBER := 0;
 x_SUBST_UNORD_FK                       NUMBER := 0;
 x_RCV_ROUTING_FK                       NUMBER := 0;
 x_DESTIN_TYPE_FK                       NUMBER := 0;
 x_RECEIPT_SOURCE_FK                    NUMBER := 0;
 x_PURCHASE_CLASS_CODE_FK               NUMBER := 0;
 x_TXN_REASON_FK                        NUMBER := 0;
 x_USER_ENTERED_FK                      NUMBER := 0;
 x_RECEIVE_EXCEP_FK                     NUMBER := 0;
 x_TXN_TYPE_FK                          NUMBER := 0;
 x_LOCATOR_FK                           NUMBER := 0;
 x_PO_LINE_TYPE_FK                      NUMBER := 0;
 x_ITEM_REVISION_FK                     NUMBER := 0;
 x_INSTANCE_FK                          NUMBER := 0;
 x_DELIV_LOCATION_FK                    NUMBER := 0;
 x_RCV_LOCATION_FK                      NUMBER := 0;
 x_SUP_SITE_GEOG_FK                     NUMBER := 0;
 x_TXN_CUR_CODE_FK                      NUMBER := 0;
 x_QTY_RETURN_TO_RECEIVING                  NUMBER := 0;
 x_QTY_REJECT                               NUMBER := 0;
 x_QTY_RECEIVED                             NUMBER := 0;
 x_QTY_DELIVER                              NUMBER := 0;
 x_QTY_ACCEPT                               NUMBER := 0;
 x_PRICE_T                                  NUMBER := 0;
 x_PRICE_G                                  NUMBER := 0;
 x_NUM_DAYS_TO_FULL_DEL                     NUMBER := 0;
 x_QTY_TXN_NET                              NUMBER := 0;
 x_QTY_TXN                                  NUMBER := 0;
 x_QTY_TRANSFER                             NUMBER := 0;
 x_QTY_RETURN_TO_VENDOR                     NUMBER := 0;
 x_RCV_TXN_PK_KEY                           NUMBER := 0;
 x_WAY_AIRBILL_NUM                          NUMBER := 0;
 x_VENDOR_LOT_NUM                           NUMBER := 0;
 x_PACKING_SLIP                             NUMBER := 0;
 x_INVOICE_NUM                              NUMBER := 0;
 x_BILL_OF_LADING                           NUMBER := 0;
 x_RCV_TXN_PK                               NUMBER := 0;
 x_TXN_COMMENTS                             NUMBER := 0;
 x_SOURCE_TXN_NUMBER                        NUMBER := 0;
 x_SHIP_HDR_COMMENTS                        NUMBER := 0;
 x_SHIPMENT_NUM                             NUMBER := 0;
 x_RMA_REFERENCE                            NUMBER := 0;
 x_RECEIPT_NUM_INST                         NUMBER := 0;
 x_LAST_UPDATE_DATE                         NUMBER := 0;
 x_CREATION_DATE                            NUMBER := 0;

 x_organization_id                          NUMBER := 0;
 x_subinventory                             NUMBER := 0;
 x_category_id                              NUMBER := 0;
 X_ITEM_DESCRIPTION                         NUMBER := 0;
 x_item_id                                  NUMBER := 0;
-----------------------------------

  CURSOR c_1 IS
        SELECT  avg(nvl(vsize(TRANSACTION_ID), 0)),
        avg(nvl(vsize(TRANSACTION_TYPE), 0)),
        avg(nvl(vsize(DESTINATION_TYPE_CODE), 0)),
        avg(nvl(vsize(location_id), 0)),
        avg(nvl(vsize(deliver_to_location_id), 0)),
        avg(nvl(vsize(locator_id), 0)),
        avg(nvl(vsize(organization_id), 0)),
        avg(nvl(vsize(subinventory), 0)),
        avg(nvl(vsize(DELIVER_TO_PERSON_ID), 0)),
        avg(nvl(vsize(SUBSTITUTE_UNORDERED_CODE), 0)),
        avg(nvl(vsize(INSPECTION_STATUS_CODE), 0)),
        avg(nvl(vsize(INSPECTION_QUALITY_CODE), 0)),
        avg(nvl(vsize(RECEIPT_EXCEPTION_FLAG), 0)),
        avg(nvl(vsize(USER_ENTERED_FLAG), 0)),
        avg(nvl(vsize(REASON_ID), 0)),
        avg(nvl(vsize(VENDOR_LOT_NUM), 0)),
        avg(nvl(vsize(RMA_REFERENCE), 0)),
        avg(nvl(vsize(COMMENTS), 0))
        from RCV_TRANSACTIONS
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_1A IS
        SELECT avg(nvl(vsize(ITEM_REVISION), 0)),
        avg(nvl(vsize(PACKING_SLIP), 0))
        from RCV_SHIPMENT_LINES
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_1B IS
        SELECT avg(nvl(vsize(RECEIPT_SOURCE_CODE), 0)),
        avg(nvl(vsize(PAYMENT_TERMS_ID), 0)),
        avg(nvl(vsize(FREIGHT_CARRIER_CODE), 0)),
        avg(nvl(vsize(SHIPMENT_NUM), 0)),
        avg(nvl(vsize(RECEIPT_NUM), 0)),
        avg(nvl(vsize(COMMENTS), 0)),
        avg(nvl(vsize(WAYBILL_AIRBILL_NUM), 0)),
        avg(nvl(vsize(BILL_OF_LADING), 0))
        from RCV_SHIPMENT_HEADERS
        where last_update_date between
        p_from_date  and  p_to_date;


  CURSOR c_2 IS
        SELECT avg(nvl(vsize(item_id), 0)),
        avg(nvl(vsize(item_description), 0)),
        avg(nvl(vsize(category_id), 0)),
        avg(nvl(vsize(vendor_product_num), 0))
        from po_lines_all
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_3 IS
        SELECT avg(nvl(vsize(ship_to_organization_id), 0))
        from po_line_locations_all
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_4 IS
        SELECT avg(nvl(vsize(vendor_site_id), 0)),
        avg(nvl(vsize(org_id), 0)),
        avg(nvl(vsize(agent_id), 0)),
        avg(nvl(vsize(currency_code), 0)),
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
        SELECT  avg(nvl(vsize(INVOICE_NUM), 0))
        from AP_INVOICES_ALL
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

    x_TXN_DATE_FK              := x_date;
    x_PARNT_TXN_DATE_FK        := x_date;
    x_SRC_CREAT_DATE_FK        := x_date;
    x_LST_ACCPT_DATE_FK        := x_date;
    x_NEED_BY_DATE_FK          := x_date;
    x_PROMISED_DATE_FK         := x_date;
    x_EXPCT_RCV_DATE_FK        := x_date;
    x_SHIPPED_TO_DATE_FK       := x_date;

    x_total := 3 + x_total
             + ceil (x_TXN_DATE_FK + 1)
             + ceil (x_PARNT_TXN_DATE_FK + 1)
             + ceil (x_SRC_CREAT_DATE_FK + 1)
             + ceil (x_LST_ACCPT_DATE_FK + 1)
             + ceil (x_NEED_BY_DATE_FK + 1)
             + ceil (x_PROMISED_DATE_FK + 1)
             + ceil (x_EXPCT_RCV_DATE_FK + 1)
             + ceil (x_SHIPPED_TO_DATE_FK + 1);

-- all calculated numbers

    x_QTY_RETURN_TO_RECEIVING  := x_float;
    x_QTY_REJECT               := x_float;
    x_QTY_RECEIVED             := x_float;
    x_QTY_DELIVER              := x_float;
    x_QTY_ACCEPT               := x_float;
    x_PRICE_T                  := x_float;
    x_PRICE_G                  := x_float;
    x_NUM_DAYS_TO_FULL_DEL     := x_float;
    x_QTY_TXN_NET              := x_float;
    x_QTY_TXN                  := x_float;
    x_QTY_TRANSFER             := x_float;
    x_QTY_RETURN_TO_VENDOR     := x_float;

    x_total := x_total
         + ceil (x_QTY_RETURN_TO_RECEIVING + 1)
         + ceil (x_QTY_REJECT  + 1)
         + ceil (x_QTY_RECEIVED  + 1)
         + ceil (x_QTY_DELIVER + 1)
         + ceil (x_QTY_ACCEPT + 1)
         + ceil (x_PRICE_T + 1)
         + ceil (x_PRICE_G + 1)
         + ceil (x_NUM_DAYS_TO_FULL_DEL + 1)
         + ceil (x_QTY_TXN_NET + 1)
         + ceil (x_QTY_TXN + 1)
         + ceil (x_QTY_TRANSFER + 1)
         + ceil (x_QTY_RETURN_TO_VENDOR + 1);

-------------------------------------------------------------

    OPEN c_1;
      FETCH c_1 INTO x_RCV_TXN_PK, x_TXN_TYPE_FK,
       x_DESTIN_TYPE_FK, x_RCV_LOCATION_FK, x_DELIV_LOCATION_FK,
       x_LOCATOR_FK, x_organization_id, x_subinventory,
       x_DELIVER_TO_FK, x_SUBST_UNORD_FK, x_INSPECT_STATUS_FK,
       x_INSPECT_QUAL_FK, x_RECEIVE_EXCEP_FK, x_USER_ENTERED_FK,
       x_TXN_REASON_FK, x_VENDOR_LOT_NUM, x_RMA_REFERENCE,
       x_TXN_COMMENTS;
    CLOSE c_1;

    x_LOCATOR_FK := x_LOCATOR_FK + x_organization_id + x_subinventory;

    x_total := x_total
              + NVL (ceil(x_RCV_TXN_PK + 1), 0)
              + NVL (ceil(x_TXN_TYPE_FK + 1), 0)
              + NVL (ceil(x_DESTIN_TYPE_FK + 1), 0)
              + NVL (ceil(x_RCV_LOCATION_FK + 1), 0)
              + NVL (ceil(x_DELIV_LOCATION_FK + 1), 0)
              + NVL (ceil(x_LOCATOR_FK + 1), 0)
              + NVL (ceil(x_DELIVER_TO_FK + 1), 0)
              + NVL (ceil(x_SUBST_UNORD_FK + 1), 0)
              + NVL (ceil(x_INSPECT_STATUS_FK + 1), 0)
              + NVL (ceil(x_INSPECT_QUAL_FK + 1), 0)
              + NVL (ceil(x_RECEIVE_EXCEP_FK + 1), 0)
              + NVL (ceil(x_USER_ENTERED_FK + 1), 0)
              + NVL (ceil(x_TXN_REASON_FK + 1), 0)
              + NVL (ceil(x_VENDOR_LOT_NUM + 1), 0)
              + NVL (ceil(x_RMA_REFERENCE + 1), 0)
              + NVL (ceil(x_TXN_COMMENTS + 1), 0);


    OPEN c_1A;
      FETCH c_1A INTO x_ITEM_REVISION_FK, x_PACKING_SLIP;
    CLOSE c_1A;

    x_total := x_total
              + NVL (ceil(x_ITEM_REVISION_FK + 1), 0)
              + NVL (ceil(x_PACKING_SLIP + 1), 0);


    OPEN c_1B;
      FETCH c_1B INTO x_RECEIPT_SOURCE_FK, x_AP_TERMS_FK,
       x_FREIGHT_TERMS_FK, x_SHIPMENT_NUM, x_RECEIPT_NUM_INST,
       x_SHIP_HDR_COMMENTS, x_WAY_AIRBILL_NUM, x_BILL_OF_LADING;
    CLOSE c_1B;

    x_total := x_total
             + NVL (ceil(x_RECEIPT_SOURCE_FK + 1), 0)
             + NVL (ceil(x_AP_TERMS_FK + 1), 0)
             + NVL (ceil(x_FREIGHT_TERMS_FK + 1), 0)
             + NVL (ceil(x_SHIPMENT_NUM + 1), 0)
             + NVL (ceil(x_RECEIPT_NUM_INST + 1), 0)
             + NVL (ceil(x_SHIP_HDR_COMMENTS + 1), 0)
             + NVL (ceil(x_WAY_AIRBILL_NUM + 1), 0)
             + NVL (ceil(x_BILL_OF_LADING + 1), 0);

--------------------------------------------------------

    OPEN c_2;
      FETCH c_2 INTO x_ITEM_ID, x_ITEM_DESCRIPTION,
       x_category_id, x_supplier_item_num_fk;
    CLOSE c_2;

    x_ITEM_REVISION_FK := x_ITEM_ID + x_category_id +
                          x_ITEM_DESCRIPTION;
    x_edw_base_uom_fk  := x_ITEM_ID;
    x_edw_uom_fk       := x_ITEM_ID;

    x_total := x_total
           + NVL (ceil(x_ITEM_REVISION_FK + 1), 0)
           + NVL (ceil(x_edw_base_uom_fk + 1), 0)
           + NVL (ceil(x_edw_uom_fk + 1), 0)
           + NVL (ceil(x_SUPPLIER_ITEM_NUM_FK + 1), 0);

-----------------------------------------------


    OPEN c_3;
      FETCH c_3 INTO x_RCV_DEL_TO_ORG_FK;
    CLOSE c_3;

    x_total := x_total + NVL (ceil(x_RCV_DEL_TO_ORG_FK + 1), 0);

---------------------------------------------------


    OPEN c_4;
      FETCH c_4 INTO x_SUPPLIER_SITE_FK, x_organization_id,
       x_BUYER_FK, x_TXN_CUR_CODE_FK, x_SOURCE_TXN_NUMBER;
    CLOSE c_4;

    x_supplier_item_num_fk := x_SUPPLIER_SITE_FK;
    x_SUPPLIER_SITE_FK     := x_SUPPLIER_SITE_FK + x_organization_id;
    x_sup_site_geog_fk     := x_SUPPLIER_SITE_FK;

    x_total := x_total
           + NVL (ceil(x_BUYER_FK + 1), 0)
           + NVL (ceil(x_SUPPLIER_SITE_FK + 1), 0)
           + NVL (ceil(x_sup_site_geog_FK + 1), 0)
           + NVL (ceil(x_supplier_item_num_FK + 1), 0)
           + NVL (ceil(x_TXN_CUR_CODE_FK  + 1), 0)
           + NVL (ceil(x_SOURCE_TXN_NUMBER + 1), 0);

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
      FETCH c_8 INTO x_INVOICE_NUM;
    CLOSE c_8;
    x_total := x_total + NVL (ceil(x_INVOICE_NUM + 1), 0);

    OPEN c_9;
      FETCH c_9 INTO x_ITEM_REVISION_FK;
    CLOSE c_9;
    x_total := x_total + NVL (ceil(x_ITEM_REVISION_FK + 1), 0);

    OPEN c_10;
      FETCH c_10 INTO x_supplier_item_num_fk;
    CLOSE c_10;
    x_total := x_total + NVL (ceil(x_supplier_item_num_fk + 1), 0);

--------------------------------------------------------

--    dbms_output.put_line('     ');
--    dbms_output.put_line('The average row length for RCV from source tables is: '
--                        || to_char(x_total));

    p_avg_row_len := x_total;

EXCEPTION
   WHEN OTHERS THEN p_avg_row_len := 0;
END;  -- procedure est_row_len.

END;

/
