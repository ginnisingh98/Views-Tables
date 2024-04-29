--------------------------------------------------------
--  DDL for Package Body POA_EDW_SUP_PERF_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_SUP_PERF_F_SIZE" AS
/*$Header: poaszspb.pls 120.0 2005/06/01 19:28:26 appldev noship $ */

PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                        p_to_date   IN  DATE,
                        p_num_rows  OUT NOCOPY NUMBER) IS

BEGIN

--    dbms_output.enable(100000);

    select count(*) into p_num_rows
    from
	po_line_locations_all		pll,
	po_lines_all			pol,
	po_headers_all			poh
    WHERE     pll.approved_flag           = 'Y'
      AND     pll.shipment_type in ('BLANKET', 'SCHEDULED', 'STANDARD')
      AND     pll.po_line_id              = pol.po_line_id
      AND     pll.po_header_id            = poh.po_header_id
      and greatest(pol.last_update_date, poh.last_update_date,
                   pll.last_update_date)
           between p_from_date and p_to_date;

--    dbms_output.put_line('The number of rows for supplier performance is: '
--                         || to_char(p_num_rows));

EXCEPTION
    WHEN OTHERS THEN p_num_rows := 0;
END;

-------------------------------------------------------

PROCEDURE est_row_len (p_from_date    IN  DATE,
                       p_to_date      IN  DATE,
                       p_avg_row_len  OUT NOCOPY NUMBER)IS

 x_date                 number := 7;
 x_total                number := 0;
 x_constant             number := 6;
 x_float                number := 11;
 x_int                  number := 6;

 x_SIC_CODE_FK                          NUMBER :=0;
 x_UNSPSC_FK                            NUMBER :=0;
 x_DUNS_FK                              NUMBER :=0;
 x_EDW_UOM_FK                           NUMBER :=0;
 x_EDW_BASE_UOM_FK                      NUMBER :=0;
 x_SUPPLIER_SITE_FK                     NUMBER :=0;
 x_INVOICE_DATE_FK                      NUMBER :=0;
 x_LST_ACCPT_DATE_FK                    NUMBER :=0;
 x_APPROVAL_DATE_FK                     NUMBER :=0;
 x_PROMISED_DATE_FK                     NUMBER :=0;
 x_NEED_BY_DATE_FK                      NUMBER :=0;
 x_FIRST_REC_DATE_FK                    NUMBER :=0;
 x_DATE_DIM_FK                          NUMBER :=0;
 x_CREATION_DATE_FK                     NUMBER :=0;
 x_SUPPLIER_ITEM_FK                     NUMBER :=0;
 x_AP_TERMS_FK                          NUMBER :=0;
 x_BUYER_FK                             NUMBER :=0;
 x_SHIP_TO_ORG_FK                       NUMBER :=0;
 x_PO_LINE_TYPE_FK                      NUMBER :=0;
 x_PURCH_CLASS_FK                       NUMBER :=0;
 x_PRICE_TYPE_FK                        NUMBER :=0;
 x_CLOSED_CODE_FK                       NUMBER :=0;
 x_ITEM_FK                              NUMBER :=0;
 x_INSTANCE_FK                          NUMBER :=0;
 x_SHIP_LOCATION_FK                     NUMBER :=0;
 x_SUP_SITE_GEOG_FK                     NUMBER :=0;
 x_TXN_CUR_CODE_FK                      NUMBER :=0;
 x_TARGET_PRICE_T                           NUMBER :=0;
 x_TARGET_PRICE_G                           NUMBER :=0;
 x_SUP_PERF_PK                              NUMBER :=0;
 x_RELEASE_NUM                              NUMBER :=0;
 x_RCV_CLOSE_TOL                            NUMBER :=0;
 x_QTY_SUBS_RECEIPT_B                       NUMBER :=0;
 x_QTY_SHIPPED_B                            NUMBER :=0;
 x_QTY_REJECTED_B                           NUMBER :=0;
 x_QTY_RECEIVED_TOL                         NUMBER :=0;
 x_QTY_RECEIVED_B                           NUMBER :=0;
 x_QTY_PAST_DUE_B                           NUMBER :=0;
 x_QTY_ORDERED_B                            NUMBER :=0;
 x_QTY_ONTIME_ONDUE_B                       NUMBER :=0;
 x_QTY_ONTIME_BEFDUE_B                      NUMBER :=0;
 x_QTY_ONTIME_AFTDUE_B                      NUMBER :=0;
 x_QTY_LATE_RECEIPT_B                       NUMBER :=0;
 x_QTY_EARLY_RECEIPT_B                      NUMBER :=0;
 x_QTY_DELIVERED_B                          NUMBER :=0;
 x_QTY_CANCELLED_B                          NUMBER :=0;
 x_QTY_ACCEPTED_B                           NUMBER :=0;
 x_PRICE_T                                  NUMBER :=0;
 x_PRICE_G                                  NUMBER :=0;
 x_NUM_SUBS_RECEIPT                         NUMBER :=0;
 x_NUM_RECEIPT_LINES                        NUMBER :=0;
 x_NUM_ONTIME_ONDUE                         NUMBER :=0;
 x_NUM_ONTIME_BEFDUE                        NUMBER :=0;
 x_NUM_ONTIME_AFTDUE                        NUMBER :=0;
 x_NUM_LATE_RECEIPT                         NUMBER :=0;
 x_NUM_EARLY_RECEIPT                        NUMBER :=0;
 x_NUM_DAYS_TO_INVOICE                      NUMBER :=0;
 x_MARKET_PRICE_T                           NUMBER :=0;
 x_MARKET_PRICE_G                           NUMBER :=0;
 x_LIST_PRICE_T                             NUMBER :=0;
 x_LIST_PRICE_G                             NUMBER :=0;
 x_LAST_UPDATE_DATE                         NUMBER :=0;
 x_IPV_T                                    NUMBER :=0;
 x_IPV_G                                    NUMBER :=0;
 x_DAYS_LATE_REC                            NUMBER :=0;
 x_DAYS_EARLY_REC                           NUMBER :=0;
 x_CREATION_DATE                            NUMBER :=0;
 x_AMT_PURCHASED_T                          NUMBER :=0;
 x_AMT_PURCHASED_G                          NUMBER :=0;
 x_PO_NUMBER                                NUMBER :=0;
 x_CONTRACT_NUM                             NUMBER :=0;


 x_category_id                              NUMBER :=0;
 x_item_revision                            NUMBER :=0;
 x_item_description                         NUMBER :=0;
 x_item_id                                  NUMBER :=0;
 x_org_id                                   NUMBER :=0;


  CURSOR c_1 IS
        SELECT  avg(nvl(vsize(vendor_product_num), 0)),
        avg(nvl(vsize(item_id), 0)),
        avg(nvl(vsize(ITEM_REVISION), 0)),
        avg(nvl(vsize(item_description), 0)),
        avg(nvl(vsize(category_id), 0)),
        avg(nvl(vsize(price_type_lookup_code), 0)),
        avg(nvl(vsize(contract_num), 0))
        from po_lines_all
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_2 IS
        SELECT  avg(nvl(vsize(line_location_id), 0)),
        avg(nvl(vsize(ship_to_organization_id), 0)),
        avg(nvl(vsize(ship_to_location_id), 0)),
        avg(nvl(vsize(closed_code), 0)),
        avg(nvl(vsize(receive_close_tolerance), 0))
        from po_line_locations_all
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_3 IS
        SELECT avg(nvl(vsize(agent_id), 0)),
        avg(nvl(vsize(vendor_site_id), 0)),
        avg(nvl(vsize(org_id), 0)),
        avg(nvl(vsize(terms_id), 0)),
        avg(nvl(vsize(currency_code), 0)),
        avg(nvl(vsize(segment1), 0))
        from po_headers_all
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_4 IS
        SELECT  avg(nvl(vsize(uom_code), 0))
        from mtl_units_of_measure
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_5 IS
        SELECT  avg(nvl(vsize(line_type), 0))
        from po_line_types
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_6 IS
        SELECT  avg(nvl(vsize(release_num), 0))
        from po_releases_all
        where last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_7 IS
        SELECT  avg(nvl(vsize(inventory_organization_id), 0))
        from FINANCIALS_SYSTEM_PARAMS_ALL
        where last_update_date between
                   p_from_date  and  p_to_date;

  CURSOR c_8 IS
        SELECT  avg(nvl(vsize(vendor_name), 0))
        from PO_VENDORS
        where last_update_date between
                   p_from_date  and  p_to_date;


  BEGIN

--    dbms_output.enable(100000);

-- all date FKs

     x_INVOICE_DATE_FK  := x_date;
     x_LST_ACCPT_DATE_FK  := x_date;
     x_APPROVAL_DATE_FK  := x_date;
     x_PROMISED_DATE_FK  := x_date;
     x_NEED_BY_DATE_FK  := x_date;
     x_FIRST_REC_DATE_FK  := x_date;
     x_DATE_DIM_FK  := x_date;
     x_CREATION_DATE_FK  := x_date;

    x_total := 3 + x_total
         + ceil (x_INVOICE_DATE_FK + 1)
         + ceil (x_LST_ACCPT_DATE_FK + 1)
         + ceil (x_APPROVAL_DATE_FK + 1)
         + ceil (x_PROMISED_DATE_FK + 1)
         + ceil (x_NEED_BY_DATE_FK + 1)
         + ceil (x_FIRST_REC_DATE_FK + 1)
         + ceil (x_DATE_DIM_FK + 1)
         + ceil (x_CREATION_DATE_FK + 1);

-- all calculated numbers

     x_TARGET_PRICE_T        := x_float;
     x_TARGET_PRICE_G        := x_float;
     x_PRICE_G               := x_float;
     x_PRICE_T               := x_float;
     x_MARKET_PRICE_G        := x_float;
     x_MARKET_PRICE_T        := x_float;
     x_LIST_PRICE_T          := x_float;
     x_LIST_PRICE_G          := x_float;
     x_QTY_SUBS_RECEIPT_B    := x_float;
     x_QTY_SHIPPED_B         := x_float;
     x_QTY_REJECTED_B        := x_float;
     x_QTY_RECEIVED_TOL      := x_float;
     x_QTY_RECEIVED_B        := x_float;
     x_QTY_PAST_DUE_B        := x_float;
     x_QTY_ORDERED_B         := x_float;
     x_QTY_ONTIME_ONDUE_B    := x_float;
     x_QTY_ONTIME_BEFDUE_B   := x_float;
     x_QTY_ONTIME_AFTDUE_B   := x_float;
     x_QTY_LATE_RECEIPT_B    := x_float;
     x_QTY_EARLY_RECEIPT_B   := x_float;
     x_QTY_DELIVERED_B       := x_float;
     x_QTY_CANCELLED_B       := x_float;
     x_QTY_ACCEPTED_B        := x_float;
     x_AMT_PURCHASED_T       := x_float;
     x_AMT_PURCHASED_G       := x_float;
     x_IPV_T                 := x_float;
     x_IPV_G                 := x_float;
     x_DAYS_LATE_REC         := x_float;
     x_DAYS_EARLY_REC        := x_float;
     x_NUM_SUBS_RECEIPT      := x_float;
     x_NUM_RECEIPT_LINES     := x_float;
     x_NUM_ONTIME_ONDUE      := x_float;
     x_NUM_ONTIME_BEFDUE     := x_float;
     x_NUM_ONTIME_AFTDUE     := x_float;
     x_NUM_LATE_RECEIPT      := x_float;
     x_NUM_EARLY_RECEIPT     := x_float;
     x_NUM_DAYS_TO_INVOICE   := x_float;

    x_total := x_total
        + ceil (x_TARGET_PRICE_T + 1)
        + ceil (x_TARGET_PRICE_G + 1)
        + ceil (x_PRICE_G + 1)
        + ceil (x_PRICE_T + 1)
        + ceil (x_MARKET_PRICE_G + 1)
        + ceil (x_MARKET_PRICE_T + 1)
        + ceil (x_LIST_PRICE_T + 1)
        + ceil (x_LIST_PRICE_G + 1)
        + ceil (x_QTY_SUBS_RECEIPT_B + 1)
        + ceil (x_QTY_SHIPPED_B + 1)
        + ceil (x_QTY_REJECTED_B + 1)
        + ceil (x_QTY_RECEIVED_TOL + 1)
        + ceil (x_QTY_RECEIVED_B + 1)
        + ceil (x_QTY_PAST_DUE_B + 1)
        + ceil (x_QTY_ORDERED_B + 1)
        + ceil (x_QTY_ONTIME_ONDUE_B + 1)
        + ceil (x_QTY_ONTIME_BEFDUE_B + 1)
        + ceil (x_QTY_ONTIME_AFTDUE_B + 1)
        + ceil (x_QTY_LATE_RECEIPT_B + 1)
        + ceil (x_QTY_EARLY_RECEIPT_B + 1)
        + ceil (x_QTY_DELIVERED_B + 1)
        + ceil (x_QTY_CANCELLED_B + 1)
        + ceil (x_QTY_ACCEPTED_B + 1)
        + ceil (x_AMT_PURCHASED_T + 1)
        + ceil (x_AMT_PURCHASED_G + 1)
        + ceil (x_IPV_T + 1)
        + ceil (x_IPV_G + 1)
        + ceil (x_DAYS_LATE_REC + 1)
        + ceil (x_DAYS_EARLY_REC + 1)
        + ceil (x_NUM_SUBS_RECEIPT + 1)
        + ceil (x_NUM_RECEIPT_LINES + 1)
        + ceil (x_NUM_ONTIME_ONDUE + 1)
        + ceil (x_NUM_ONTIME_BEFDUE + 1)
        + ceil (x_NUM_ONTIME_AFTDUE + 1)
        + ceil (x_NUM_LATE_RECEIPT + 1)
        + ceil (x_NUM_EARLY_RECEIPT + 1)
        + ceil (x_NUM_DAYS_TO_INVOICE + 1);

-------------------------------------------------------------

    OPEN c_1;
      FETCH c_1 INTO x_supplier_item_fk, x_ITEM_ID,
      x_ITEM_REVISION, x_category_id, x_ITEM_DESCRIPTION,
      x_PRICE_TYPE_FK, x_CONTRACT_NUM;
    CLOSE c_1;

    x_item_fk          := x_ITEM_ID + x_ITEM_REVISION +
                          x_category_id + x_ITEM_DESCRIPTION;
    x_edw_base_uom_fk  := x_ITEM_ID;
    x_edw_uom_fk       := x_ITEM_ID;

    x_total := x_total
           + NVL (ceil(x_PRICE_TYPE_FK + 1), 0)
           + NVL (ceil(x_CONTRACT_NUM + 1), 0)
           + NVL (ceil(x_item_fk + 1), 0)
           + NVL (ceil(x_edw_base_uom_fk + 1), 0)
           + NVL (ceil(x_edw_uom_fk + 1), 0)
           + NVL (ceil(x_SUPPLIER_ITEM_FK + 1), 0);

-----------------------------------------------


    OPEN c_2;
      FETCH c_2 INTO  x_sup_perf_pk, x_SHIP_TO_ORG_FK,
        x_SHIP_LOCATION_FK, x_closed_code_fk,
        x_rcv_close_tol;
    CLOSE c_2;

    x_PURCH_CLASS_FK := x_sup_perf_pk;

    x_total := x_total
           + NVL (ceil(x_sup_perf_pk + 1), 0)
           + NVL (ceil(x_PURCH_CLASS_FK + 1), 0)
           + NVL (ceil(x_SHIP_TO_ORG_FK + 1), 0)
           + NVL (ceil(x_SHIP_LOCATION_FK + 1), 0)
           + NVL (ceil(x_CLOSED_CODE_FK + 1), 0)
           + NVL (ceil(x_rcv_close_tol + 1), 0) ;


---------------------------------------------------


    OPEN c_3;
      FETCH c_3 INTO
      x_BUYER_FK, x_SUPPLIER_SITE_FK, x_org_id,
      x_AP_TERMS_FK, x_TXN_CUR_CODE_FK, x_PO_NUMBER;
    CLOSE c_3;

    x_supplier_item_fk := x_SUPPLIER_SITE_FK;
    x_SUPPLIER_SITE_FK := x_SUPPLIER_SITE_FK + x_org_id;
    x_sup_site_geog_fk := x_SUPPLIER_SITE_FK;

    x_total := x_total
           + NVL (ceil(x_BUYER_FK + 1), 0)
           + NVL (ceil(x_SUPPLIER_SITE_FK + 1), 0)
           + NVL (ceil(x_sup_site_geog_FK + 1), 0)
           + NVL (ceil(x_supplier_item_FK + 1), 0)
           + NVL (ceil(x_AP_TERMS_FK + 1), 0)
           + NVL (ceil(x_TXN_CUR_CODE_FK + 1), 0)
           + NVL (ceil(x_PO_NUMBER + 1), 0);


--------------------------------------------------------

    OPEN c_4;
      FETCH c_4 INTO x_EDW_BASE_UOM_FK;
    CLOSE c_4;

    x_EDW_UOM_FK := x_EDW_BASE_UOM_FK;

    x_total := x_total + NVL (ceil(x_EDW_BASE_UOM_FK + 1), 0)
                       + NVL (ceil(x_EDW_UOM_FK + 1), 0);

    OPEN c_5;
      FETCH c_5 INTO x_PO_LINE_TYPE_FK;
    CLOSE c_5;
    x_total := x_total + NVL (ceil(x_PO_LINE_TYPE_FK + 1), 0);

    OPEN c_6;
      FETCH c_6 INTO x_RELEASE_NUM;
    CLOSE c_6;
    x_total := x_total + NVL (ceil(x_RELEASE_NUM + 1), 0);

    OPEN c_7;
      FETCH c_7 INTO x_item_fk;
    CLOSE c_7;
    x_total := x_total + NVL (ceil(x_item_fk + 1), 0);

    OPEN c_8;
      FETCH c_8 INTO x_supplier_item_fk;
    CLOSE c_8;
    x_total := x_total + NVL (ceil(x_supplier_item_fk + 1), 0);

--------------------------------------------------------

--    dbms_output.put_line('     ');
--    dbms_output.put_line('The average row length for Supplier Performance is: '
--                        || to_char(x_total));

    p_avg_row_len := x_total;

EXCEPTION
   WHEN OTHERS THEN p_avg_row_len := 0;
END;  -- procedure est_row_len.

END;

/
