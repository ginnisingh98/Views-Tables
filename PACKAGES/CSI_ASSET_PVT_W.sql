--------------------------------------------------------
--  DDL for Package CSI_ASSET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ASSET_PVT_W" AUTHID CURRENT_USER as
  /* $Header: csivasws.pls 120.10 2008/01/15 03:33:11 devijay ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy csi_asset_pvt.lookup_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t csi_asset_pvt.lookup_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out nocopy csi_asset_pvt.asset_id_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t csi_asset_pvt.asset_id_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy csi_asset_pvt.asset_loc_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p6(t csi_asset_pvt.asset_loc_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p8(t out nocopy csi_asset_pvt.instance_asset_sync_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p8(t csi_asset_pvt.instance_asset_sync_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p10(t out nocopy csi_asset_pvt.fa_asset_sync_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p10(t csi_asset_pvt.fa_asset_sync_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p12(t out nocopy csi_asset_pvt.instance_sync_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p12(t csi_asset_pvt.instance_sync_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure initialize_asset_rec(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  NUMBER
    , p0_a3 in out nocopy  VARCHAR2
    , p0_a4 in out nocopy  NUMBER
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  DATE
    , p0_a8 in out nocopy  DATE
    , p0_a9 in out nocopy  NUMBER
    , p0_a10 in out nocopy  VARCHAR2
    , p0_a11 in out nocopy  VARCHAR2
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  VARCHAR2
    , p0_a16 in out nocopy  VARCHAR2
    , p0_a17 in out nocopy  VARCHAR2
    , p0_a18 in out nocopy  VARCHAR2
    , p0_a19 in out nocopy  VARCHAR2
    , p0_a20 in out nocopy  VARCHAR2
    , p0_a21 in out nocopy  DATE
    , p0_a22 in out nocopy  VARCHAR2
    , p0_a23 in out nocopy  VARCHAR2
    , p0_a24 in out nocopy  VARCHAR2
    , p0_a25 in out nocopy  NUMBER
    , p0_a26 in out nocopy  VARCHAR2
    , p_inst_asset_hist_id  NUMBER
    , x_nearest_full_dump in out nocopy  date
  );
  procedure construct_asset_from_hist(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a4 in out nocopy JTF_NUMBER_TABLE
    , p0_a5 in out nocopy JTF_NUMBER_TABLE
    , p0_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a7 in out nocopy JTF_DATE_TABLE
    , p0_a8 in out nocopy JTF_DATE_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a21 in out nocopy JTF_DATE_TABLE
    , p0_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a23 in out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a25 in out nocopy JTF_NUMBER_TABLE
    , p0_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_time_stamp  date
  );
  procedure get_asset_column_values(p_get_asset_cursor_id  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  VARCHAR2
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  VARCHAR2
    , p1_a7 out nocopy  DATE
    , p1_a8 out nocopy  DATE
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  DATE
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  NUMBER
    , p1_a26 out nocopy  VARCHAR2
  );
  procedure bind_asset_variable(p_get_asset_cursor_id  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  NUMBER := 0-1962.0724
  );
  procedure resolve_id_columns(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a4 in out nocopy JTF_NUMBER_TABLE
    , p0_a5 in out nocopy JTF_NUMBER_TABLE
    , p0_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a7 in out nocopy JTF_DATE_TABLE
    , p0_a8 in out nocopy JTF_DATE_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a21 in out nocopy JTF_DATE_TABLE
    , p0_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a23 in out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a25 in out nocopy JTF_NUMBER_TABLE
    , p0_a26 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure gen_asset_where_clause(x_where_clause out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  NUMBER := 0-1962.0724
  );
  procedure get_instance_assets(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_resolve_id_columns  VARCHAR2
    , p_time_stamp  date
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_DATE_TABLE
    , p7_a8 out nocopy JTF_DATE_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a21 out nocopy JTF_DATE_TABLE
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a25 out nocopy JTF_NUMBER_TABLE
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  NUMBER := 0-1962.0724
  );
  procedure create_instance_asset(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  DATE
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a0 in out nocopy  NUMBER
    , p10_a1 in out nocopy  NUMBER
    , p10_a2 in out nocopy  NUMBER
    , p11_a0 in out nocopy JTF_NUMBER_TABLE
    , p11_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a0 in out nocopy JTF_NUMBER_TABLE
    , p12_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_called_from_grp  VARCHAR2
  );
  procedure update_instance_asset(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  DATE
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a0 in out nocopy  NUMBER
    , p10_a1 in out nocopy  NUMBER
    , p10_a2 in out nocopy  NUMBER
    , p11_a0 in out nocopy JTF_NUMBER_TABLE
    , p11_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a0 in out nocopy JTF_NUMBER_TABLE
    , p12_a1 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_instance_asset_hist(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_transaction_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 out nocopy JTF_DATE_TABLE
    , p5_a14 out nocopy JTF_DATE_TABLE
    , p5_a15 out nocopy JTF_DATE_TABLE
    , p5_a16 out nocopy JTF_DATE_TABLE
    , p5_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a39 out nocopy JTF_DATE_TABLE
    , p5_a40 out nocopy JTF_DATE_TABLE
    , p5_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a47 out nocopy JTF_NUMBER_TABLE
    , p5_a48 out nocopy JTF_NUMBER_TABLE
    , p5_a49 out nocopy JTF_NUMBER_TABLE
    , p5_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a52 out nocopy JTF_NUMBER_TABLE
    , p5_a53 out nocopy JTF_NUMBER_TABLE
    , p5_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure asset_syncup_validation(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_NUMBER_TABLE
    , p0_a6 in out nocopy JTF_NUMBER_TABLE
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_NUMBER_TABLE
    , p1_a2 in out nocopy JTF_NUMBER_TABLE
    , p1_a3 in out nocopy JTF_NUMBER_TABLE
    , p1_a4 in out nocopy JTF_NUMBER_TABLE
    , p2_a0 in out nocopy JTF_NUMBER_TABLE
    , p2_a1 in out nocopy JTF_NUMBER_TABLE
    , p2_a2 in out nocopy JTF_NUMBER_TABLE
    , p2_a3 in out nocopy JTF_NUMBER_TABLE
    , x_error_msg out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure get_attached_item_instances(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_system_name  VARCHAR2
    , p_called_from_grp  VARCHAR2
  );
  procedure get_attached_asset_links(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_VARCHAR2_TABLE_100
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_system_name  VARCHAR2
    , p_called_from_grp  VARCHAR2
  );
  procedure get_fa_asset_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_system_name  VARCHAR2
    , p_called_from_grp  VARCHAR2
  );
  procedure get_syncup_tree(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_NUMBER_TABLE
    , p0_a6 in out nocopy JTF_NUMBER_TABLE
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_NUMBER_TABLE
    , p1_a2 in out nocopy JTF_NUMBER_TABLE
    , p1_a3 in out nocopy JTF_NUMBER_TABLE
    , p1_a4 in out nocopy JTF_NUMBER_TABLE
    , p2_a0 in out nocopy JTF_NUMBER_TABLE
    , p2_a1 in out nocopy JTF_NUMBER_TABLE
    , p2_a2 in out nocopy JTF_NUMBER_TABLE
    , p2_a3 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_error_msg out nocopy  VARCHAR2
    , p_source_system_name  VARCHAR2
    , p_called_from_grp  VARCHAR2
  );
  procedure create_instance_assets(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 in out nocopy JTF_NUMBER_TABLE
    , p4_a5 in out nocopy JTF_NUMBER_TABLE
    , p4_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 in out nocopy JTF_DATE_TABLE
    , p4_a8 in out nocopy JTF_DATE_TABLE
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_NUMBER_TABLE
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , p6_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure set_fa_sync_flag(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  NUMBER
    , p0_a3 in out nocopy  VARCHAR2
    , p0_a4 in out nocopy  NUMBER
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  DATE
    , p0_a8 in out nocopy  DATE
    , p0_a9 in out nocopy  NUMBER
    , p0_a10 in out nocopy  VARCHAR2
    , p0_a11 in out nocopy  NUMBER
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  NUMBER
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  VARCHAR2
    , p_location_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_error_msg out nocopy  VARCHAR2
  );
end csi_asset_pvt_w;

/
