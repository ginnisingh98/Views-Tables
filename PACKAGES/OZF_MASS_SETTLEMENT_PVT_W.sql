--------------------------------------------------------
--  DDL for Package OZF_MASS_SETTLEMENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_MASS_SETTLEMENT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwmsts.pls 120.5.12010000.2 2008/08/01 06:23:25 bkunjan ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ozf_mass_settlement_pvt.open_claim_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t ozf_mass_settlement_pvt.open_claim_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p4(t out nocopy ozf_mass_settlement_pvt.open_transaction_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t ozf_mass_settlement_pvt.open_transaction_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p6(t out nocopy ozf_mass_settlement_pvt.claim_payment_method_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t ozf_mass_settlement_pvt.claim_payment_method_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure settle_mass_settlement(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_VARCHAR2_TABLE_100
    , p8_a2 JTF_VARCHAR2_TABLE_100
    , p8_a3 JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_VARCHAR2_TABLE_100
    , p9_a3 JTF_VARCHAR2_TABLE_100
    , p9_a4 JTF_NUMBER_TABLE
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_DATE_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p10_a4 JTF_NUMBER_TABLE
    , x_claim_group_id out nocopy  NUMBER
    , x_claim_group_number out nocopy  VARCHAR2
  );
end ozf_mass_settlement_pvt_w;

/
