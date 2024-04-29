--------------------------------------------------------
--  DDL for Package Body POA_EDW_CONTRACT_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_CONTRACT_F_SIZE" AS
/*$Header: poaszctb.pls 120.0 2005/06/02 02:46:34 appldev noship $ */

PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                        p_to_date   IN  DATE,
                        p_num_rows  OUT NOCOPY NUMBER) IS

BEGIN

--    dbms_output.enable(100000);

    select count(*) into p_num_rows
      from po_headers_all
     WHERE type_lookup_code            in ('CONTRACT', 'BLANKET')
       and approved_flag		= 'Y'
       and last_update_date between p_from_date and p_to_date;

--    dbms_output.put_line('The number of rows for contract is: '
--                         || to_char(p_num_rows));

EXCEPTION
    WHEN OTHERS THEN p_num_rows := 0;
END;

---------------------------------------------------------------

PROCEDURE  est_row_len (p_from_date    IN  DATE,
                        p_to_date      IN  DATE,
                        p_avg_row_len  OUT NOCOPY NUMBER) IS

 x_date                 number := 7;
 x_total                number := 0;
 x_constant             number := 6;
 x_float                number := 11;
 x_int                  number := 6;

 x_SIC_CODE_FK                          NUMBER;
 x_DUNS_FK                              NUMBER;
 x_SUPPLIER_SITE_FK                     NUMBER;
 x_TXN_CUR_DATE_FK                      NUMBER;
 x_PRINTED_DATE_FK                      NUMBER;
 x_END_DATE_FK                          NUMBER;
 x_START_DATE_FK                        NUMBER;
 x_ACCPT_DUE_DATE_FK                    NUMBER;
 x_REVISED_DATE_FK                      NUMBER;
 x_APPROVED_DATE_FK                     NUMBER;
 x_CREATION_DATE_FK                     NUMBER;
 x_APPROVER_FK                          NUMBER;
 x_BUYER_FK                             NUMBER;
 x_AP_TERMS_FK                          NUMBER;
 x_OPERATING_UNIT_FK                    NUMBER;
 x_USER_HOLD_FK                         NUMBER;
 x_CANCELLED_FK                         NUMBER;
 x_FROZEN_FK                            NUMBER;
 x_ACCPT_REQUIRED_FK                    NUMBER;
 x_FREIGHT_TERMS_FK                     NUMBER;
 x_FOB_FK                               NUMBER;
 x_SHIP_VIA_FK                          NUMBER;
 x_PO_TYPE_FK                           NUMBER;
 x_CONTRACT_EFFECTIVE_FK                NUMBER;
 x_EDI_PROCESSED_FK                     NUMBER;
 x_APPROVED_FK                          NUMBER;
 x_CONFIRM_ORDER_FK                     NUMBER;
 x_CLOSED_FK                            NUMBER;
 x_INSTANCE_FK                          NUMBER;
 x_SHIP_LOCATION_FK                     NUMBER;
 x_BILL_LOCATION_FK                     NUMBER;
 x_SUP_SITE_GEOG_FK                     NUMBER;
 x_TXN_CUR_CODE_FK                      NUMBER;
 x_TXN_CUR_RATE                         NUMBER;
 x_REVISION_NUM                         NUMBER;
 x_PO_HEADER_ID                         NUMBER;
 x_NUM_DAYS_CREATE_TO_APP               NUMBER;
 x_NUM_DAYS_APP_TO_SEND                 NUMBER;
 x_NUM_DAYS_APP_SEND_TO_ACCPT           NUMBER;
 x_AMT_RELEASED_T                       NUMBER;
 x_AMT_RELEASED_G                       NUMBER;
 x_AMT_MIN_RELEASE_T                    NUMBER;
 x_AMT_MIN_RELEASE_G                    NUMBER;
 x_AMT_LIMIT_T                          NUMBER;
 x_AMT_LIMIT_G                          NUMBER;
 x_AMT_AGREED_T                         NUMBER;
 x_AMT_AGREED_G                         NUMBER;
 x_CONTRACT_NUM                         NUMBER;
 x_TXN_CUR_RATE_TYPE                    NUMBER;
 x_SUPPLIER_NOTE                        NUMBER;
 x_RECEIVER_NOTE                        NUMBER;
 x_CONTRACT_PK                          NUMBER;
 x_COMMENTS                             NUMBER;
 x_LAST_UPDATE_DATE                     NUMBER;
 x_CREATION_DATE                        NUMBER;

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
        avg(nvl(vsize(revision_num), 0)),
        avg(nvl(vsize(segment1), 0)),
        avg(nvl(vsize(rate), 0)),
        avg(nvl(vsize(confirming_order_flag), 0)),
        avg(nvl(vsize(edi_processed_flag), 0))
        from PO_HEADERS_ALL
        where last_update_date between
                  p_from_date  and  p_to_date;

--------

  CURSOR c_2 IS
        SELECT  avg(nvl(vsize(currency_code), 0))
        from gl_sets_of_books
        where last_update_date between
                   p_from_date  and  p_to_date;

  BEGIN

--    dbms_output.enable(100000);

-- all date FKs

    x_ACCPT_DUE_DATE_FK := x_date;
    x_APPROVED_DATE_FK  := x_date;
    x_END_DATE_FK       := x_date;
    x_CREATION_DATE_FK  := x_date;
    x_PRINTED_DATE_FK   := x_date;
    x_REVISED_DATE_FK   := x_date;
    x_START_DATE_FK     := x_date;
    x_TXN_CUR_DATE_FK   := x_date;

    x_total := 3 + x_total
                 + ceil (x_ACCPT_DUE_DATE_FK + 1)
                 + ceil (x_APPROVED_DATE_FK  + 1)
                 + ceil (x_END_DATE_FK       + 1)
                 + ceil (x_CREATION_DATE_FK + 1)
                 + ceil (x_PRINTED_DATE_FK  + 1)
                 + ceil (x_REVISED_DATE_FK   + 1)
                 + ceil (x_START_DATE_FK     + 1)
                 + ceil (x_TXN_CUR_DATE_FK   + 1);

-- all calculated numbers

    x_amt_released_t       := x_float;
    x_amt_released_g       := x_float;
    x_amt_agreed_t         := x_float;
    x_amt_agreed_g         := x_float;
    x_amt_limit_t          := x_float;
    x_amt_limit_g          := x_float;
    x_amt_min_release_t    := x_float;
    x_amt_min_release_g    := x_float;
    x_amt_released_t       := x_float;
    x_amt_released_g       := x_float;

    x_num_days_create_to_app     := x_float;
    x_num_days_app_to_send       := x_float;
    x_num_days_app_send_to_accpt := x_float;

    x_total := x_total
         + ceil(x_amt_released_t + 1)
         + ceil(x_amt_released_g + 1)
         + ceil(x_amt_agreed_t + 1)
         + ceil(x_amt_agreed_g + 1)
         + ceil(x_amt_limit_t + 1)
         + ceil(x_amt_limit_g + 1)
         + ceil(x_amt_min_release_t + 1)
         + ceil(x_amt_min_release_g + 1)
         + ceil(x_amt_released_t + 1)
         + ceil(x_amt_released_g + 1)
         + ceil(x_num_days_create_to_app + 1)
         + ceil(x_num_days_app_to_send   + 1)
         + ceil(x_num_days_app_send_to_accpt + 1);

-----------------------------------------------------


    OPEN c_1;
      FETCH c_1 INTO x_buyer_fk, x_PO_HEADER_ID, x_supplier_site_fk,
         x_operating_unit_fk, x_ap_terms_fk, x_closed_fk,
         x_po_type_fk, x_ship_via_fk, x_fob_fk, x_freight_terms_fk,
         x_accpt_required_fk, x_frozen_fk, x_bill_location_fk,
         x_ship_location_fk, x_sup_site_geog_fk, x_txn_cur_code_fk,
         x_comments, x_receiver_note,
         x_supplier_note, x_approved_fk, x_user_hold_fk,
         x_revision_num, x_contract_num, x_txn_cur_rate,
         x_confirm_order_fk, x_edi_processed_fk;
    CLOSE c_1;

    x_approver_fk := x_buyer_fk;
    x_contract_pk := x_PO_HEADER_ID;
    x_supplier_site_fk := x_supplier_site_fk + x_operating_unit_fk;
    x_sup_site_geog_fk := x_sup_site_geog_fk + x_operating_unit_fk;


    x_total := x_total
         + NVL (ceil(x_buyer_fk + 1), 0)
         + NVL (ceil(x_approver_fk + 1), 0)
         + NVL (ceil(x_contract_pk + 1), 0)
         + NVL (ceil(x_PO_HEADER_ID + 1), 0)
         + NVL (ceil(x_supplier_site_fk + 1), 0)
         + NVL (ceil(x_operating_unit_fk + 1), 0)
         + NVL (ceil(x_ap_terms_fk + 1), 0)
         + NVL (ceil(x_closed_fk + 1), 0)
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
         + NVL (ceil(x_supplier_note + 1), 0)
         + NVL (ceil(x_approved_fk + 1), 0)
         + NVL (ceil(x_user_hold_fk + 1), 0)
         + NVL (ceil(x_confirm_order_fk + 1), 0)
         + NVL (ceil(x_revision_num + 1), 0)
         + NVL (ceil(x_contract_num + 1), 0)
         + NVL (ceil(x_txn_cur_rate + 1), 0)
         + NVL (ceil(x_edi_processed_fk + 1), 0);


--------------------------------------------------------------------

    OPEN c_2;
      FETCH c_2 INTO x_txn_cur_code_fk;
    CLOSE c_2;

    x_total := x_total + NVL (ceil(x_txn_cur_code_fk + 1), 0);

------------------------------------------------------------------

--    dbms_output.put_line('     ');
--    dbms_output.put_line('The average row length for contract is: '
--                         || to_char(x_total));

    p_avg_row_len := x_total;

EXCEPTION
    WHEN OTHERS THEN p_avg_row_len := 0;
END;  -- procedure est_row_len.

END;

/
