--------------------------------------------------------
--  DDL for Package IBY_EXT_BANKACCT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_EXT_BANKACCT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: ibyxbnkws.pls 120.4.12010000.5 2010/02/26 06:00:32 svinjamu ship $ */
  procedure create_ext_bank(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  NUMBER
    , x_bank_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  );
  procedure update_ext_bank(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
  );
  procedure set_bank_end_date(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bank_id  NUMBER
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  );
  procedure check_bank_exist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_country_code  VARCHAR2
    , p_bank_name  VARCHAR2
    , p_bank_number  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_bank_id out nocopy  NUMBER
    , x_end_date out nocopy  DATE
    , p10_a0 out nocopy  VARCHAR2
    , p10_a1 out nocopy  VARCHAR2
    , p10_a2 out nocopy  VARCHAR2
  );
  procedure create_ext_bank_branch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  NUMBER
    , p2_a36  NUMBER
    , p2_a37  NUMBER
    , p2_a38  NUMBER
    , x_branch_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  );
  procedure update_ext_bank_branch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 in out nocopy  NUMBER
    , p2_a1 in out nocopy  NUMBER
    , p2_a2 in out nocopy  VARCHAR2
    , p2_a3 in out nocopy  VARCHAR2
    , p2_a4 in out nocopy  VARCHAR2
    , p2_a5 in out nocopy  VARCHAR2
    , p2_a6 in out nocopy  VARCHAR2
    , p2_a7 in out nocopy  VARCHAR2
    , p2_a8 in out nocopy  VARCHAR2
    , p2_a9 in out nocopy  VARCHAR2
    , p2_a10 in out nocopy  VARCHAR2
    , p2_a11 in out nocopy  VARCHAR2
    , p2_a12 in out nocopy  VARCHAR2
    , p2_a13 in out nocopy  VARCHAR2
    , p2_a14 in out nocopy  VARCHAR2
    , p2_a15 in out nocopy  VARCHAR2
    , p2_a16 in out nocopy  VARCHAR2
    , p2_a17 in out nocopy  VARCHAR2
    , p2_a18 in out nocopy  VARCHAR2
    , p2_a19 in out nocopy  VARCHAR2
    , p2_a20 in out nocopy  VARCHAR2
    , p2_a21 in out nocopy  VARCHAR2
    , p2_a22 in out nocopy  VARCHAR2
    , p2_a23 in out nocopy  VARCHAR2
    , p2_a24 in out nocopy  VARCHAR2
    , p2_a25 in out nocopy  VARCHAR2
    , p2_a26 in out nocopy  VARCHAR2
    , p2_a27 in out nocopy  VARCHAR2
    , p2_a28 in out nocopy  VARCHAR2
    , p2_a29 in out nocopy  VARCHAR2
    , p2_a30 in out nocopy  VARCHAR2
    , p2_a31 in out nocopy  VARCHAR2
    , p2_a32 in out nocopy  VARCHAR2
    , p2_a33 in out nocopy  VARCHAR2
    , p2_a34 in out nocopy  VARCHAR2
    , p2_a35 in out nocopy  NUMBER
    , p2_a36 in out nocopy  NUMBER
    , p2_a37 in out nocopy  NUMBER
    , p2_a38 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
  );
  procedure set_ext_bank_branch_end_date(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_branch_id  NUMBER
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  );
  procedure check_ext_bank_branch_exist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bank_id  NUMBER
    , p_branch_name  VARCHAR2
    , p_branch_number  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_branch_id out nocopy  NUMBER
    , x_end_date out nocopy  DATE
    , p10_a0 out nocopy  VARCHAR2
    , p10_a1 out nocopy  VARCHAR2
    , p10_a2 out nocopy  VARCHAR2
  );
  procedure create_ext_bank_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  NUMBER
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  DATE
    , p2_a24  DATE
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  NUMBER
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , x_acct_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  );
  procedure create_ext_bank_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  NUMBER
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  DATE
    , p2_a24  DATE
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  NUMBER
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p_association_level  VARCHAR2
    , p_supplier_site_id  NUMBER
    , p_party_site_id  NUMBER
    , p_org_id  NUMBER
    , p_org_type  VARCHAR2
    , x_acct_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy  VARCHAR2
    , p12_a1 out nocopy  VARCHAR2
    , p12_a2 out nocopy  VARCHAR2
  );
  procedure update_ext_bank_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 in out nocopy  NUMBER
    , p2_a1 in out nocopy  VARCHAR2
    , p2_a2 in out nocopy  NUMBER
    , p2_a3 in out nocopy  NUMBER
    , p2_a4 in out nocopy  NUMBER
    , p2_a5 in out nocopy  VARCHAR2
    , p2_a6 in out nocopy  VARCHAR2
    , p2_a7 in out nocopy  VARCHAR2
    , p2_a8 in out nocopy  VARCHAR2
    , p2_a9 in out nocopy  VARCHAR2
    , p2_a10 in out nocopy  VARCHAR2
    , p2_a11 in out nocopy  VARCHAR2
    , p2_a12 in out nocopy  VARCHAR2
    , p2_a13 in out nocopy  VARCHAR2
    , p2_a14 in out nocopy  VARCHAR2
    , p2_a15 in out nocopy  VARCHAR2
    , p2_a16 in out nocopy  VARCHAR2
    , p2_a17 in out nocopy  VARCHAR2
    , p2_a18 in out nocopy  VARCHAR2
    , p2_a19 in out nocopy  VARCHAR2
    , p2_a20 in out nocopy  NUMBER
    , p2_a21 in out nocopy  VARCHAR2
    , p2_a22 in out nocopy  VARCHAR2
    , p2_a23 in out nocopy  DATE
    , p2_a24 in out nocopy  DATE
    , p2_a25 in out nocopy  VARCHAR2
    , p2_a26 in out nocopy  VARCHAR2
    , p2_a27 in out nocopy  VARCHAR2
    , p2_a28 in out nocopy  VARCHAR2
    , p2_a29 in out nocopy  VARCHAR2
    , p2_a30 in out nocopy  VARCHAR2
    , p2_a31 in out nocopy  VARCHAR2
    , p2_a32 in out nocopy  VARCHAR2
    , p2_a33 in out nocopy  VARCHAR2
    , p2_a34 in out nocopy  VARCHAR2
    , p2_a35 in out nocopy  VARCHAR2
    , p2_a36 in out nocopy  VARCHAR2
    , p2_a37 in out nocopy  VARCHAR2
    , p2_a38 in out nocopy  VARCHAR2
    , p2_a39 in out nocopy  VARCHAR2
    , p2_a40 in out nocopy  VARCHAR2
    , p2_a41 in out nocopy  VARCHAR2
    , p2_a42 in out nocopy  NUMBER
    , p2_a43 in out nocopy  VARCHAR2
    , p2_a44 in out nocopy  VARCHAR2
    , p2_a45 in out nocopy  VARCHAR2
    , p2_a46 in out nocopy  VARCHAR2
    , p2_a47 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
  );
  procedure get_ext_bank_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bankacct_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  );
  procedure get_ext_bank_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bankacct_id  NUMBER
    , p_sec_key  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  NUMBER
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  DATE
    , p7_a24 out nocopy  DATE
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  NUMBER
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  VARCHAR2
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  VARCHAR2
    , p7_a47 out nocopy  VARCHAR2
    , p8_a0 out nocopy  VARCHAR2
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  VARCHAR2
  );
  procedure set_ext_bank_acct_dates(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_acct_id  NUMBER
    , p_start_date  date
    , p_end_date  date
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy  VARCHAR2
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
  );
  procedure check_ext_acct_exist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  NUMBER
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  DATE
    , p2_a24  DATE
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  NUMBER
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , x_acct_id out nocopy  NUMBER
    , x_start_date out nocopy  DATE
    , x_end_date out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy  VARCHAR2
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
  );
  procedure check_ext_acct_exist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bank_id  VARCHAR2
    , p_branch_id  NUMBER
    , p_acct_number  VARCHAR2
    , p_acct_name  VARCHAR2
    , p_currency  VARCHAR2
    , p_country_code  VARCHAR2
    , x_acct_id out nocopy  NUMBER
    , x_start_date out nocopy  DATE
    , x_end_date out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p14_a0 out nocopy  VARCHAR2
    , p14_a1 out nocopy  VARCHAR2
    , p14_a2 out nocopy  VARCHAR2
  );
  procedure create_intermediary_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  NUMBER
    , x_intermediary_acct_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  );
  procedure update_intermediary_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 in out nocopy  NUMBER
    , p2_a1 in out nocopy  NUMBER
    , p2_a2 in out nocopy  VARCHAR2
    , p2_a3 in out nocopy  VARCHAR2
    , p2_a4 in out nocopy  VARCHAR2
    , p2_a5 in out nocopy  VARCHAR2
    , p2_a6 in out nocopy  VARCHAR2
    , p2_a7 in out nocopy  VARCHAR2
    , p2_a8 in out nocopy  VARCHAR2
    , p2_a9 in out nocopy  VARCHAR2
    , p2_a10 in out nocopy  VARCHAR2
    , p2_a11 in out nocopy  VARCHAR2
    , p2_a12 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
  );
  procedure add_joint_account_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bank_account_id  NUMBER
    , p_acct_owner_party_id  NUMBER
    , x_joint_acct_owner_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 out nocopy  VARCHAR2
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  VARCHAR2
  );
  procedure set_joint_acct_owner_end_date(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_acct_owner_id  NUMBER
    , p_end_date  date
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 out nocopy  VARCHAR2
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  VARCHAR2
  );
  procedure change_primary_acct_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bank_acct_id  NUMBER
    , p_acct_owner_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  );
  procedure check_bank_acct_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bank_acct_id  NUMBER
    , p_acct_owner_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  );
end iby_ext_bankacct_pub_w;

/
