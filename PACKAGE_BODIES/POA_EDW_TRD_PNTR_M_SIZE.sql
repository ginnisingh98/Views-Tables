--------------------------------------------------------
--  DDL for Package Body POA_EDW_TRD_PNTR_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_TRD_PNTR_M_SIZE" AS
/*$Header: poasztpb.pls 120.0.12010000.2 2008/08/04 08:43:53 rramasam ship $ */

PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                        p_to_date   IN  DATE,
                        p_num_rows  OUT NOCOPY NUMBER) IS

BEGIN

--    dbms_output.enable(100000);

    select sum(cnt) into p_num_rows
    from (
       select count(*) cnt
       from
          po_vendors vnd,
          po_vendor_sites_all vns
       WHERE vns.vendor_id    = vnd.vendor_id
         and greatest(vns.last_update_date, vnd.last_update_date)
               between p_from_date and p_to_date
       union all
       select count(*) cnt
         from
             HZ_PARTIES              parties,
             HZ_CUST_ACCOUNTS        hzca,
             HZ_CUST_ACCT_SITES_ALL  hcas,
             HZ_CUST_SITE_USES_ALL   hcss
       WHERE hcss.CUST_ACCT_SITE_ID = hcas.CUST_ACCT_SITE_ID
         AND hcas.CUST_ACCOUNT_ID   = hzca.CUST_ACCOUNT_ID
         AND hzca.party_id          = parties.party_id
         and greatest(hcss.last_update_date, hzca.last_update_date,
                      hcas.last_update_date, parties.last_update_date)
               between p_from_date and p_to_date
       union all
       select count(*) cnt
         from
             po_vendors
        where last_update_date between p_from_date and p_to_date
       union all
       select count(*) cnt
         FROM hz_cust_accounts        hzca,
              hz_parties              parties
        WHERE hzca.party_id = parties.party_id
          and greatest(parties.last_update_date, hzca.last_update_date)
                between p_from_date and p_to_date
       union all
       select count(*) cnt
         from hz_parties
        where last_update_date between p_from_date and p_to_date);

--    dbms_output.put_line('The number of rows for trading partner is: '
--                         || to_char(p_num_rows));

EXCEPTION
    WHEN OTHERS THEN p_num_rows := 0;
END;

-------------------------------------------------------

PROCEDURE  est_row_len (p_from_date    IN  DATE,
                        p_to_date      IN  DATE,
                        p_avg_row_len  OUT NOCOPY NUMBER) IS

 x_total1                number := 0;
 x_total2                number := 0;
 x_total3                number := 0;
 x_total4                number := 0;
 x_total5                number := 0;
 x_total6                number := 0;
 x_total                 number := 0;
 x_date                  number := 7;

 -- Definition for edw_tprt_p1_tpartner_lstg;
 x_TPARTNER_PK                              NUMBER := 0;
 x_PARENT_TPARTNER_FK                       NUMBER := 0;
 x_LAST_UPDATE_DATE                         NUMBER := 0;
 x_CREATION_DATE                            NUMBER := 0;
 x_TPARTNER_DP                              NUMBER := 0;
 x_NAME                                     NUMBER := 0;
 x_ALTERNATE_NAME                           NUMBER := 0;
 x_START_ACTIVE_DATE                        NUMBER := 0;
 x_END_ACTIVE_DATE                          NUMBER := 0;
 x_SIC_CODE                                 NUMBER := 0;
 x_TAX_REG_NUM                              NUMBER := 0;
 x_TAXPAYER_ID                              NUMBER := 0;
 x_PAYMENT_TERMS                            NUMBER := 0;
 x_VENDOR_NUMBER                            NUMBER := 0;
 x_VENDOR_TYPE                              NUMBER := 0;
 x_ONE_TIME_FLAG                            NUMBER := 0;
 x_MINORITY_GROUP                           NUMBER := 0;
 x_WOMEN_OWNED                              NUMBER := 0;
 x_SMALL_BUSINESS                           NUMBER := 0;
 x_HOLD_FLAG                                NUMBER := 0;
 x_INSPECT_REQUIRED                         NUMBER := 0;
 x_RECEIPT_REQUIRED                         NUMBER := 0;
 x_ALLOW_SUB_RECEIPT                        NUMBER := 0;
 x_ALLOW_UNORDER_RCV                        NUMBER := 0;
 x_INSTANCE                                 NUMBER := 0;
 x_VENDOR_ID                                NUMBER := 0;

 x_TRADE_PARTNER_PK                         NUMBER := 0;
 x_TRADE_PARTNER_DP                         NUMBER := 0;
 x_VNDR_NUMBER                              NUMBER := 0;
 x_VNDR_TYPE                                NUMBER := 0;
 x_VNDR_ONE_TIME                            NUMBER := 0;
 x_VNDR_MINORITY_GRP                        NUMBER := 0;
 x_VNDR_WOMEN_OWNED                         NUMBER := 0;
 x_VNDR_SMALL_BUS                           NUMBER := 0;
 x_VNDR_HOLD_FLAG                           NUMBER := 0;
 x_VNDR_INSPECT_REQ                         NUMBER := 0;
 x_VNDR_RECEIPT_REQ                         NUMBER := 0;
 x_VNDR_SUB_RECEIPT                         NUMBER := 0;
 x_VNDR_UNORDER_RCV                         NUMBER := 0;
 x_CUST_NUMBER                              NUMBER := 0;
 x_CUST_ORIG_SYS_REF                        NUMBER := 0;
 x_CUST_STATUS                              NUMBER := 0;
 x_CUST_TYPE                                NUMBER := 0;
 x_CUST_PROSPECT                            NUMBER := 0;
 x_CUST_CLASS                               NUMBER := 0;
 x_CUST_SALES_REP                           NUMBER := 0;
 x_CUST_SALES_CHNL                          NUMBER := 0;
 x_CUST_ORDER_TYPE                          NUMBER := 0;
 x_CUST_PRICE_LIST                          NUMBER := 0;
 x_CUST_ANALYSIS_FY                         NUMBER := 0;
 x_CUST_CAT_CODE                            NUMBER := 0;
 x_CUST_KEY                                 NUMBER := 0;
 x_CUST_FISCAL_END                          NUMBER := 0;
 x_CUST_NUM_EMP                             NUMBER := 0;
 x_CUST_REVENUE_CURR                        NUMBER := 0;
 x_CUST_REVENUE_NEXT                        NUMBER := 0;
 x_CUST_REF_USE_FLAG                        NUMBER := 0;
 x_CUST_TAX_CODE                            NUMBER := 0;
 x_CUST_THIRD_PARTY                         NUMBER := 0;
 x_CUST_ACCESS_TMPL                         NUMBER := 0;
 x_CUST_COMPETITOR                          NUMBER := 0;
 x_CUST_ORIG_SYS                            NUMBER := 0;
 x_CUST_YEAR_EST                            NUMBER := 0;
 x_CUST_COTERM_DATE                         NUMBER := 0;
 x_CUST_FOB_POINT                           NUMBER := 0;
 x_CUST_FREIGHT                             NUMBER := 0;
 x_CUST_GSA_IND                             NUMBER := 0;
 x_CUST_SHIP_PARTIAL                        NUMBER := 0;
 x_CUST_SHIP_VIA                            NUMBER := 0;
 x_CUST_DO_NOT_MAIL                         NUMBER := 0;
 x_CUST_TAX_HDR_FLAG                        NUMBER := 0;
 x_CUST_TAX_ROUND                           NUMBER := 0;
 x_USER_ATTRIBUTE1                          NUMBER := 0;
 x_USER_ATTRIBUTE2                          NUMBER := 0;
 x_USER_ATTRIBUTE3                          NUMBER := 0;
 x_USER_ATTRIBUTE4                          NUMBER := 0;
 x_USER_ATTRIBUTE5                          NUMBER := 0;
 x_CUSTOMER_ID                              NUMBER := 0;

 x_TPARTNER_LOC_PK                          NUMBER := 0;
 x_TRADE_PARTNER_FK                         NUMBER := 0;
 x_ADDRESS_LINE1                            NUMBER := 0;
 x_ADDRESS_LINE2                            NUMBER := 0;
 x_ADDRESS_LINE3                            NUMBER := 0;
 x_ADDRESS_LINE4                            NUMBER := 0;
 x_CITY                                     NUMBER := 0;
 x_COUNTY                                   NUMBER := 0;
 x_STATE                                    NUMBER := 0;
 x_POSTAL_CODE                              NUMBER := 0;
 x_PROVINCE                                 NUMBER := 0;
 x_COUNTRY                                  NUMBER := 0;
 x_BUSINESS_TYPE                            NUMBER := 0;
 x_TPARTNER_LOC_DP                          NUMBER := 0;
 x_DATE_FROM                                NUMBER := 0;
 x_DATE_TO                                  NUMBER := 0;
 x_VNDR_PURCH_SITE                          NUMBER := 0;
 x_VNDR_RFQ_ONLY                            NUMBER := 0;
 x_VNDR_PAY_SITE                            NUMBER := 0;
 x_VNDR_PAY_TERMS                           NUMBER := 0;
 x_CUST_SITE_USE                            NUMBER := 0;
 x_CUST_LOCATION                            NUMBER := 0;
 x_CUST_PRIMARY_FLAG                        NUMBER := 0;
 x_CUST_PAY_TERMS                           NUMBER := 0;
 X_CUST_SIC_CODE                            NUMBER := 0;
 x_CUST_TERRITORY                           NUMBER := 0;
 x_CUST_TAX_REF                             NUMBER := 0;
 x_CUST_SORT_PRTY                           NUMBER := 0;
 x_CUST_DEMAND_CLASS                        NUMBER := 0;
 x_CUST_TAX_CLASSFN                         NUMBER := 0;
 x_TPARTNER_LOC_ID                          NUMBER := 0;
 x_LEVEL_NAME                               NUMBER := 0;

cursor c1 is
   select avg(nvl(vsize(vendor_id), 0)),
   avg(nvl(vsize(parent_vendor_id), 0)),
   avg(nvl(vsize(vendor_name), 0)),
   avg(nvl(vsize(vendor_name_alt), 0)),
   avg(nvl(vsize(standard_industry_class), 0)),
   avg(nvl(vsize(vat_registration_num),0)),
   avg(nvl(vsize(num_1099),0)),
   avg(nvl(vsize(terms_id),0)),
   avg(nvl(vsize(segment1),0)),
   avg(nvl(vsize(vendor_type_lookup_code),0)),
   avg(nvl(vsize(one_time_flag),0)),
   avg(nvl(vsize(minority_group_lookup_code),0)),
   avg(nvl(vsize(women_owned_flag),0)),
   avg(nvl(vsize(small_business_flag),0)),
   avg(nvl(vsize(hold_flag),0)),
   avg(nvl(vsize(inspection_required_flag),0)),
   avg(nvl(vsize(receipt_required_flag),0)),
   avg(nvl(vsize(allow_substitute_receipts_flag),0)),
   avg(nvl(vsize(allow_unordered_receipts_flag),0))
   from po_vendors where last_update_date
   between p_from_date and p_to_date;

cursor c2 is
   select avg(nvl(vsize(instance_code),0))
   from edw_local_instance;

cursor c3 is
   select avg(nvl(vsize(cust_account_id),0)),
   avg(nvl(vsize(account_number),0)),
   avg(nvl(vsize(orig_system_reference),0)),
   avg(nvl(vsize(status),0)),
   avg(nvl(vsize(customer_type),0)),
   avg(nvl(vsize(customer_class_code),0)),
   avg(nvl(vsize(sales_channel_code),0)),
   avg(nvl(vsize(tax_code),0)),
   avg(nvl(vsize(coterminate_day_month),0)),
   avg(nvl(vsize(fob_point),0)),
   avg(nvl(vsize(freight_term),0)),
   avg(nvl(vsize(ship_partial),0)),
   avg(nvl(vsize(ship_via),0)),
   avg(nvl(vsize(tax_header_level_flag),0)),
   avg(nvl(vsize(tax_rounding_rule),0)),
   avg(nvl(vsize(party_id),0))
   from hz_cust_accounts where last_update_date
   between p_from_date and p_to_date;

cursor c4 is
   select avg(nvl(vsize(party_name),0)),
   avg(nvl(vsize(organization_name_phonetic),0)),
   avg(nvl(vsize(sic_code),0)),
   avg(nvl(vsize(tax_reference),0)),
   avg(nvl(vsize(jgzz_fiscal_code),0)),
   avg(nvl(vsize(party_number),0)),
   avg(nvl(vsize(party_type),0)),
   avg(nvl(vsize(analysis_fy),0)),
   avg(nvl(vsize(customer_key),0)),
   avg(nvl(vsize(fiscal_yearend_month),0)),
   avg(nvl(vsize(employees_total),0)),
   avg(nvl(vsize(curr_fy_potential_revenue),0)),
   avg(nvl(vsize(next_fy_potential_revenue),0)),
   avg(nvl(vsize(year_established),0)),
   avg(nvl(vsize(gsa_indicator_flag),0)),
   avg(nvl(vsize(do_not_mail_flag),0))
   from hz_parties;

cursor c5 is
   select avg(nvl(vsize(name),0))
   from ap_terms_tl;

cursor c6 is
   select avg(nvl(vsize(name),0))
   from oe_transaction_types_tl;

cursor c7 is
   select avg(nvl(vsize(name),0))
   from qp_list_headers_tl;


cursor c8 is
   select avg(nvl(vsize(vendor_site_id), 0)),
   avg(nvl(vsize(address_line1),0)),
   avg(nvl(vsize(address_line2),0)),
   avg(nvl(vsize(address_line3),0)),
   avg(nvl(vsize(city),0)),
   avg(nvl(vsize(county),0)),
   avg(nvl(vsize(state),0)),
   avg(nvl(vsize(zip),0)),
   avg(nvl(vsize(province),0)),
   avg(nvl(vsize(country),0)),
   avg(nvl(vsize(vendor_site_code),0)),
   avg(nvl(vsize(purchasing_site_flag),0)),
   avg(nvl(vsize(rfq_only_site_flag),0)),
   avg(nvl(vsize(pay_site_flag),0))
   from po_vendor_sites_all where last_update_date
   between p_from_date and p_to_date;

cursor c9 is
   select avg(nvl(vsize(site_use_code),0)),
   avg(nvl(vsize(location),0)),
   avg(nvl(vsize(primary_flag),0)),
   avg(nvl(vsize(status),0)),
   avg(nvl(vsize(orig_system_reference),0)),
   avg(nvl(vsize(sic_code),0)),
   avg(nvl(vsize(gsa_indicator),0)),
   avg(nvl(vsize(ship_partial),0)),
   avg(nvl(vsize(ship_via),0)),
   avg(nvl(vsize(fob_point),0)),
   avg(nvl(vsize(freight_term),0)),
   avg(nvl(vsize(tax_reference),0)),
   avg(nvl(vsize(sort_priority),0)),
   avg(nvl(vsize(tax_code),0)),
   avg(nvl(vsize(demand_class_code),0)),
   avg(nvl(vsize(tax_header_level_flag),0)),
   avg(nvl(vsize(tax_rounding_rule),0))
   from HZ_CUST_SITE_USES_ALL where last_update_date
   between p_from_date and p_to_date;

cursor c10 is
   select avg(nvl(vsize(name), 0))
   from ra_territories  where last_update_date
   between p_from_date and p_to_date;

cursor c11 is
   select avg(nvl(vsize(name), 0))
   from ra_salesreps_all  where last_update_date
   between p_from_date and p_to_date;


BEGIN
--   dbms_output.enable(100000);

   OPEN c1;
   FETCH c1 into x_tpartner_pk, x_PARENT_TPARTNER_FK,
         x_TPARTNER_DP, x_alternate_name,
         x_SIC_CODE, x_TAX_REG_NUM, x_TAXPAYER_ID, x_PAYMENT_TERMS,
         x_VENDOR_NUMBER, x_VENDOR_TYPE, x_ONE_TIME_FLAG, x_MINORITY_GROUP,
         x_WOMEN_OWNED, x_SMALL_BUSINESS, x_HOLD_FLAG, x_INSPECT_REQUIRED,
         x_RECEIPT_REQUIRED, x_ALLOW_SUB_RECEIPT, x_ALLOW_UNORDER_RCV;
   CLOSE c1;

   x_last_update_date   := x_date;
   x_creation_date      := x_date;
   x_NAME               := x_TPARTNER_DP;
   x_START_ACTIVE_DATE  := x_date;
   x_END_ACTIVE_DATE    := x_date;
   x_VENDOR_ID          := x_tpartner_pk;

   x_total1 := 3 + x_total1 + NVL (ceil(x_tpartner_pk + 1), 0) +
      NVL (ceil(x_TPARTNER_DP + 1), 0) + NVL (ceil(x_alternate_name + 1), 0) +
      NVL (ceil(x_TAXPAYER_ID + 1), 0) +  NVL (ceil(x_PAYMENT_TERMS + 1), 0) +
      NVL (ceil(x_VENDOR_NUMBER + 1), 0) + NVL (ceil(x_VENDOR_TYPE + 1), 0) +
      NVL (ceil(x_ONE_TIME_FLAG + 1), 0) + NVL (ceil(x_VENDOR_ID + 1), 0) +
      NVL (ceil(x_vndr_minority_grp + 1), 0) + NVL (ceil(x_vndr_women_owned + 1), 0) +
      NVL (ceil(x_vndr_small_bus + 1), 0) + NVL (ceil(x_vndr_hold_flag + 1), 0) +
      NVL (ceil(x_vndr_inspect_req + 1), 0) + NVL (ceil(x_vndr_receipt_req + 1), 0) +
      NVL (ceil(x_vndr_sub_receipt + 1), 0) + NVL (ceil(x_vndr_unorder_rcv + 1), 0) +
      NVL (ceil(x_PARENT_TPARTNER_FK + 1), 0) + (x_creation_date + 1) +
      (x_last_update_date + 1) + NVL (ceil(x_NAME + 1), 0) +
      (x_START_ACTIVE_DATE + 1) + (x_END_ACTIVE_DATE + 1);

   OPEN c2;
   FETCH c2 into x_instance;
   CLOSE c2;

   x_total1 := x_total1 + NVL (ceil(x_instance + 1), 0);

--   dbms_output.put_line('     ');
--   dbms_output.put_line('input_m from source tables for the following staging tables are: ');
--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_TPRT_P1_TPARTNER_LSTG   : ' || to_char(x_total1));

   x_total2 := x_total1;

--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_TPRT_P2_TPARTNER_LSTG   : ' || to_char(x_total2));

   x_total3 := x_total1;

--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_TPRT_P3_TPARTNER_LSTG   : ' || to_char(x_total3));

   x_total4 := x_total1 - NVL (ceil(x_PARENT_TPARTNER_FK),0);

--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_TPRT_P4_TPARTNER_LSTG   : ' || to_char(x_total4));

---------------- For TP ----------------------------

   x_total5 := x_total1;  -- vendors' part

   OPEN c3;
   FETCH c3 into x_trade_partner_pk, x_cust_number,
      x_cust_orig_sys_ref, x_cust_status, x_cust_type, x_cust_class,
      x_cust_sales_chnl, x_cust_tax_code,
      x_cust_coterm_date, x_cust_fob_point, x_cust_freight,
      x_cust_ship_partial, x_cust_ship_via, x_cust_tax_hdr_flag,
      x_cust_tax_round, x_vendor_id;
   CLOSE c3;

   x_start_active_date := x_date;
   x_end_active_date   := x_date;
   x_last_update_date  := x_date;
   x_creation_date     := x_date;
   x_customer_id       := x_trade_partner_pk;

   OPEN c4;
   FETCH c4 into x_trade_partner_dp, x_alternate_name, x_sic_code,
      x_tax_reg_num, x_taxpayer_id, x_vndr_number, x_vndr_type,
      x_cust_analysis_fy, x_cust_key, x_cust_fiscal_end,
      x_cust_num_emp, x_cust_revenue_curr, x_cust_revenue_next,
      x_cust_year_est, x_cust_gsa_ind, x_cust_do_not_mail;
   CLOSE c4;

   x_cust_prospect := 8;
   x_name          := x_trade_partner_dp;

   x_total5 := greatest(x_total5, 3 + NVL (ceil(x_PARENT_TPARTNER_FK + 1), 0) +
      NVL (ceil(x_trade_partner_pk + 1), 0) +
        (x_start_active_date + 1) + (x_end_active_date + 1) +
      NVL (ceil(x_cust_number + 1), 0) +
      NVL (ceil(x_cust_orig_sys_ref + 1), 0) + NVL (ceil(x_cust_status + 1), 0) +
      NVL (ceil(x_cust_type + 1), 0) + NVL (ceil(x_cust_class + 1), 0) +
      NVL (ceil(x_cust_sales_chnl + 1), 0) + NVL (ceil(x_cust_cat_code + 1), 0) +
      NVL (ceil(x_cust_ref_use_flag + 1), 0) + NVL (ceil(x_cust_tax_code + 1), 0) +
      NVL (ceil(x_cust_third_party + 1), 0) + NVL (ceil(x_cust_competitor + 1), 0) +
      NVL (ceil(x_cust_coterm_date + 1), 0) + NVL (ceil(x_cust_fob_point + 1), 0) +
      NVL (ceil(x_cust_freight + 1), 0) + NVL (ceil(x_cust_ship_partial + 1), 0) +
      NVL (ceil(x_cust_ship_via + 1), 0) + NVL (ceil(x_cust_tax_hdr_flag + 1), 0) +
      NVL (ceil(x_cust_tax_round + 1), 0) + (x_last_update_date + 1) +
      (x_creation_date + 1) + NVL (ceil(x_customer_id + 1), 0)
    + NVL (ceil(x_trade_partner_dp + 1), 0) +
      NVL (ceil(x_alternate_name + 1), 0) +
      NVL (ceil(x_sic_code + 1), 0) + NVL (ceil(x_tax_reg_num + 1), 0) +
      NVL (ceil(x_taxpayer_id + 1), 0) +
      NVL (ceil(x_cust_prospect + 1), 0) +
      NVL (ceil(x_cust_analysis_fy + 1), 0) + NVL (ceil(x_cust_key + 1), 0) +
      NVL (ceil(x_cust_fiscal_end + 1), 0) + NVL (ceil(x_cust_num_emp + 1), 0) +
      NVL (ceil(x_cust_revenue_curr + 1), 0) + NVL (ceil(x_cust_revenue_next + 1), 0) +
      NVL (ceil(x_cust_year_est + 1), 0) + NVL (ceil(x_cust_gsa_ind + 1), 0) +
      NVL (ceil(x_cust_do_not_mail + 1), 0) + NVL (ceil(x_name + 1), 0));

   OPEN c5;
   FETCH c5 into x_payment_terms;
   CLOSE c5;

   x_total5 := x_total5 + NVL (ceil(x_payment_terms + 1), 0);

   OPEN c6;
   FETCH c6 into x_cust_order_type;
   CLOSE c6;

   x_total5 := x_total5 + NVL (ceil(x_cust_order_type + 1), 0);

   OPEN c7;
   FETCH c7 into x_cust_price_list;
   CLOSE c7;

   x_total5 := x_total5 + NVL (ceil(x_cust_price_list + 1), 0);

--   dbms_output.put_line('for EDW_TPRT_TRADE_PARTNER_LSTG : ' || to_char(x_total5));


----------------- For TP_LOC -----------------

   -- extra part for tp_loc from hz_customer_accounts, hz_parties, etc...

   x_total6 := x_total6 + 3
               + NVL (ceil(x_TPARTNER_DP + 1), 0)
               + NVL (ceil(x_cust_ship_partial + 1), 0)
               + NVL (ceil(x_cust_ship_via + 1), 0)
               + NVL (ceil(x_cust_fob_point + 1), 0)
               + NVL (ceil(x_cust_freight + 1), 0)
               + NVL (ceil(x_cust_tax_hdr_flag + 1), 0)
               + NVL (ceil(x_cust_tax_round + 1), 0)
               + NVL (ceil(x_cust_tax_code + 1), 0)
               + NVL (ceil(x_cust_gsa_ind + 1), 0)
               + NVL (ceil(x_trade_partner_dp + 1), 0) * 2;


   OPEN c8;
   FETCH c8 into  x_TPARTNER_LOC_PK, x_ADDRESS_LINE1, x_ADDRESS_LINE2,
         x_ADDRESS_LINE3, x_CITY, x_COUNTY, x_STATE, x_POSTAL_CODE,
         x_PROVINCE, x_COUNTRY, x_TPARTNER_LOC_DP, x_VNDR_PURCH_SITE,
         x_VNDR_RFQ_ONLY, x_VNDR_PAY_SITE;
   CLOSE c8;

   x_TRADE_PARTNER_FK := x_tpartner_pk;
   x_BUSINESS_TYPE    := 11;
   x_NAME             := x_TPARTNER_LOC_DP;
   x_DATE_FROM        := x_date;
   x_DATE_TO          := x_date;
   x_VNDR_PAY_TERMS   := x_payment_terms;
   x_TPARTNER_LOC_ID  := x_TPARTNER_LOC_PK;
   x_LAST_UPDATE_DATE := x_date;
   x_CREATION_DATE    := x_date;
   x_LEVEL_NAME       := 8;

   x_total6 := greatest(x_total6, 3 + NVL (ceil(x_TPARTNER_LOC_PK + 1), 0) +
               NVL (ceil(x_ADDRESS_LINE1 + 1), 0) + NVL (ceil(x_ADDRESS_LINE2 + 1), 0) +
               NVL (ceil(x_ADDRESS_LINE3 + 1), 0) + NVL (ceil(x_CITY + 1), 0) +
               NVL (ceil(x_COUNTY + 1), 0) + NVL (ceil(x_STATE + 1), 0) +
               NVL (ceil(x_POSTAL_CODE + 1), 0) + NVL (ceil(x_PROVINCE + 1), 0) +
               NVL (ceil(x_COUNTRY + 1), 0) + NVL (ceil(x_TPARTNER_LOC_DP + 1), 0) +
               NVL (ceil(x_VNDR_PURCH_SITE + 1), 0) + NVL (ceil(x_VNDR_RFQ_ONLY + 1), 0) +
               NVL (ceil(x_VNDR_PAY_SITE + 1), 0) + NVL (ceil(x_TRADE_PARTNER_FK + 1), 0) +
               NVL (ceil(x_BUSINESS_TYPE + 1), 0) + NVL (ceil(x_NAME + 1), 0) +
               NVL (ceil(x_DATE_TO + 1), 0) + NVL (ceil(x_VNDR_PAY_TERMS + 1), 0) +
               NVL (ceil(x_TPARTNER_LOC_ID + 1), 0) + NVL (ceil(x_DATE_FROM + 1), 0) +
               NVL (ceil(x_LAST_UPDATE_DATE + 1), 0) + NVL (ceil(x_CREATION_DATE + 1), 0) +
               NVL (ceil(x_LEVEL_NAME + 1), 0));

   open c9;
   fetch c9 into x_CUST_SITE_USE, x_CUST_LOCATION, x_CUST_PRIMARY_FLAG,
               x_cust_status, x_cust_orig_sys_ref, x_cust_sic_code,
               x_cust_gsa_ind, x_cust_ship_partial, x_cust_ship_via,
               x_cust_fob_point, x_cust_freight,  x_cust_tax_ref,
               x_cust_sort_prty, x_cust_tax_code,
               x_cust_demand_class, x_cust_tax_hdr_flag,
               x_cust_tax_round;
   close c9;

   x_total6 := greatest(x_total6, 3
               + NVL (ceil(x_CUST_SITE_USE + 1), 0)
               + NVL (ceil(x_CUST_LOCATION + 1), 0)
               + NVL (ceil(x_CUST_PRIMARY_FLAG + 1), 0)
               + NVL (ceil(x_cust_status + 1), 0)
               + NVL (ceil(x_cust_orig_sys_ref + 1), 0)
               + NVL (ceil(x_cust_sic_code + 1), 0)
               + NVL (ceil(x_cust_gsa_ind + 1), 0)
               + NVL (ceil(x_cust_ship_partial + 1), 0)
               + NVL (ceil(x_cust_ship_via + 1), 0)
               + NVL (ceil(x_cust_fob_point + 1), 0)
               + NVL (ceil(x_cust_freight + 1), 0)
               + NVL (ceil(x_cust_tax_ref + 1), 0)
               + NVL (ceil(x_cust_sort_prty + 1), 0)
               + NVL (ceil(x_cust_tax_code + 1), 0)
               + NVL (ceil(x_cust_demand_class + 1), 0)
               + NVL (ceil(x_cust_tax_hdr_flag + 1), 0)
               + NVL (ceil(x_cust_tax_round + 1), 0)
               + NVL (ceil(x_cust_pay_terms + 1), 0)
               + NVL (ceil(x_cust_order_type + 1), 0)
               + NVL (ceil(x_cust_price_list + 1), 0));


   open c10;
   fetch c10 into x_cust_territory;
   close c10;

   open c11;
   fetch c11 into x_cust_sales_rep;
   close c11;

   x_total6 := x_total6
               + NVL (ceil(x_cust_territory + 1), 0)
               + NVL (ceil(x_cust_sales_rep + 1), 0);

--   dbms_output.put_line('for EDW_TPRT_TPARTNER_LOC_LSTG  : ' || to_char(x_total6));

---------------------------------------------------------------

   x_total := x_total1 + x_total2 + x_total3 + x_total4 + x_total5 + x_total6;

--   dbms_output.put_line('-------------------------------------');
--   dbms_output.put_line('(total) input_m for trade partner dimension is: ' || to_char(x_total));

    p_avg_row_len := x_total;

EXCEPTION
    WHEN OTHERS THEN p_avg_row_len := 0;

END;  -- procedure est_row_len.

END;

/
