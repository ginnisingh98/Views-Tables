--------------------------------------------------------
--  DDL for Package OKS_ENTITLEMENTS_WEB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ENTITLEMENTS_WEB_W" AUTHID CURRENT_USER as
  /* $Header: OKSWENWS.pls 120.0 2005/05/25 18:14:51 appldev noship $ */
  procedure rosetta_table_copy_in_p19(t out nocopy oks_entitlements_web.output_tbl_contract, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p19(t oks_entitlements_web.output_tbl_contract, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p21(t out nocopy oks_entitlements_web.account_all_id_tbl_type, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p21(t oks_entitlements_web.account_all_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p23(t out nocopy oks_entitlements_web.party_sites_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p23(t oks_entitlements_web.party_sites_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p25(t out nocopy oks_entitlements_web.party_items_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p25(t oks_entitlements_web.party_items_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p27(t out nocopy oks_entitlements_web.party_systems_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p27(t oks_entitlements_web.party_systems_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p29(t out nocopy oks_entitlements_web.party_products_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p29(t oks_entitlements_web.party_products_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p31(t out nocopy oks_entitlements_web.contract_cat_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p31(t oks_entitlements_web.contract_cat_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p33(t out nocopy oks_entitlements_web.contract_status_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p33(t oks_entitlements_web.contract_status_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p37(t out nocopy oks_entitlements_web.party_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_400
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p37(t oks_entitlements_web.party_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_400
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p39(t out nocopy oks_entitlements_web.line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_500
    , a9 JTF_VARCHAR2_TABLE_500
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_400
    , a12 JTF_VARCHAR2_TABLE_400
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_400
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_400
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p39(t oks_entitlements_web.line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_VARCHAR2_TABLE_400
    , a12 out nocopy JTF_VARCHAR2_TABLE_400
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_400
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_400
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p41(t out nocopy oks_entitlements_web.party_contact_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_400
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p41(t oks_entitlements_web.party_contact_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_400
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p43(t out nocopy oks_entitlements_web.pty_cntct_dtls_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p43(t oks_entitlements_web.pty_cntct_dtls_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p46(t out nocopy oks_entitlements_web.covered_level_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_500
    , a8 JTF_VARCHAR2_TABLE_500
    );
  procedure rosetta_table_copy_out_p46(t oks_entitlements_web.covered_level_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    );

  procedure rosetta_table_copy_in_p48(t out nocopy oks_entitlements_web.cust_contacts_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p48(t oks_entitlements_web.cust_contacts_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p51(t out nocopy oks_entitlements_web.bus_proc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    , a5 JTF_VARCHAR2_TABLE_500
    );
  procedure rosetta_table_copy_out_p51(t oks_entitlements_web.bus_proc_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    );

  procedure rosetta_table_copy_in_p54(t out nocopy oks_entitlements_web.coverage_times_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p54(t oks_entitlements_web.coverage_times_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p56(t out nocopy oks_entitlements_web.reaction_times_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p56(t oks_entitlements_web.reaction_times_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p58(t out nocopy oks_entitlements_web.resolution_times_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p58(t oks_entitlements_web.resolution_times_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p60(t out nocopy oks_entitlements_web.pref_resource_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_400
    );
  procedure rosetta_table_copy_out_p60(t oks_entitlements_web.pref_resource_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    );

  procedure rosetta_table_copy_in_p62(t out nocopy oks_entitlements_web.bus_proc_bil_typ_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_500
    , a6 JTF_VARCHAR2_TABLE_500
    );
  procedure rosetta_table_copy_out_p62(t oks_entitlements_web.bus_proc_bil_typ_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    );

  procedure rosetta_table_copy_in_p65(t out nocopy oks_entitlements_web.covered_prods_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    , a5 JTF_VARCHAR2_TABLE_500
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_500
    , a8 JTF_VARCHAR2_TABLE_500
    , a9 JTF_VARCHAR2_TABLE_500
    , a10 JTF_VARCHAR2_TABLE_500
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p65(t oks_entitlements_web.covered_prods_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , a16 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure rosetta_table_copy_in_p67(t out nocopy oks_entitlements_web.counter_tbl_type, a0 JTF_VARCHAR2_TABLE_500
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    );
  procedure rosetta_table_copy_out_p67(t oks_entitlements_web.counter_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_500
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    );

  procedure simple_srch_rslts(p_contract_party_id  NUMBER
    , p_account_id  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a8 out nocopy JTF_DATE_TABLE
    , p5_a9 out nocopy JTF_DATE_TABLE
    , p5_a10 out nocopy JTF_DATE_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure cntrct_srch_rslts(p_contract_number  VARCHAR2
    , p_contract_status_code  VARCHAR2
    , p_start_date_from  date
    , p_start_date_to  date
    , p_end_date_from  date
    , p_end_date_to  date
    , p_date_terminated_from  date
    , p_date_terminated_to  date
    , p_contract_party_id  NUMBER
    , p_covlvl_site_id  NUMBER
    , p_covlvl_site_name  VARCHAR2
    , p_covlvl_system_id  NUMBER
    , p_covlvl_system_name  VARCHAR2
    , p_covlvl_product_id  NUMBER
    , p_covlvl_product_name  VARCHAR2
    , p_covlvl_item_id  NUMBER
    , p_covlvl_item_name  VARCHAR2
    , p_entitlement_check_yn  VARCHAR2
    , p_account_check_all  VARCHAR2
    , p_account_id  VARCHAR2
    , p_covlvl_party_id  VARCHAR2
    , p21_a0 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p25_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p25_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p25_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p25_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p25_a8 out nocopy JTF_DATE_TABLE
    , p25_a9 out nocopy JTF_DATE_TABLE
    , p25_a10 out nocopy JTF_DATE_TABLE
    , p25_a11 out nocopy JTF_NUMBER_TABLE
    , p25_a12 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure party_sites(p_party_id_arg  VARCHAR2
    , p_site_name_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_300
  );
  function duration_period(p_start_date  date
    , p_end_date  date
  ) return number;
  function duration_unit(p_start_date  date
    , p_end_date  date
  ) return varchar2;
  procedure party_items(p_party_id_arg  VARCHAR2
    , p_item_name_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure party_systems(p_party_id_arg  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p_system_name_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure party_products(p_party_id_arg  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p_product_name_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure adv_search_overview(p_party_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_party_name out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure contract_number_overview(p_contract_number_arg  VARCHAR2
    , p_contract_modifier_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  VARCHAR2
    , p3_a10 out nocopy  VARCHAR2
    , p3_a11 out nocopy  VARCHAR2
    , p3_a12 out nocopy  NUMBER
    , p3_a13 out nocopy  DATE
    , p3_a14 out nocopy  DATE
    , p3_a15 out nocopy  NUMBER
    , p3_a16 out nocopy  VARCHAR2
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  VARCHAR2
    , p4_a2 out nocopy  VARCHAR2
    , p4_a3 out nocopy  VARCHAR2
    , p4_a4 out nocopy  VARCHAR2
    , p4_a5 out nocopy  VARCHAR2
    , p4_a6 out nocopy  VARCHAR2
    , p4_a7 out nocopy  VARCHAR2
    , p4_a8 out nocopy  VARCHAR2
    , p4_a9 out nocopy  VARCHAR2
    , p4_a10 out nocopy  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure contract_overview(p_contract_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  NUMBER
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  NUMBER
    , p2_a13 out nocopy  DATE
    , p2_a14 out nocopy  DATE
    , p2_a15 out nocopy  NUMBER
    , p2_a16 out nocopy  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  VARCHAR2
    , p3_a10 out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_400
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_DATE_TABLE
    , p5_a3 out nocopy JTF_DATE_TABLE
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a11 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a13 out nocopy JTF_NUMBER_TABLE
    , p5_a14 out nocopy JTF_NUMBER_TABLE
    , p5_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a17 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a21 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a23 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure party_overview(p_contract_id_arg  VARCHAR2
    , p_party_rle_code_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_DATE_TABLE
    , p3_a5 out nocopy JTF_DATE_TABLE
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure party_contacts_overview(p_contact_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a7 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure line_overview(p_line_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0 out nocopy  VARCHAR2
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  NUMBER
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  DATE
    , p2_a13 out nocopy  DATE
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  NUMBER
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  DATE
    , p2_a21 out nocopy  DATE
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_DATE_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_DATE_TABLE
  );
  procedure coverage_overview(p_coverage_id_arg  VARCHAR2
    , p_contract_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_500
  );
  procedure bus_proc_overview(p_bus_proc_id_arg  VARCHAR2
    , p_contract_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_500
  );
  procedure usage_overview(p_line_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0 out nocopy  VARCHAR2
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  NUMBER
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a16 out nocopy JTF_VARCHAR2_TABLE_2000
  );
  procedure product_overview(p_covered_prod_id_arg  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_500
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_500
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_500
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_500
  );
end oks_entitlements_web_w;

 

/
