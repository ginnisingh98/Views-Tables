--------------------------------------------------------
--  DDL for Package CSI_TRANSACTIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_TRANSACTIONS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: csivtxws.pls 120.12 2008/01/15 03:31:55 devijay ship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy csi_transactions_pvt.util_order_by_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t csi_transactions_pvt.util_order_by_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_transactions(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_rec_requested  NUMBER
    , p_start_rec_prt  NUMBER
    , p_return_tot_count  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_DATE_TABLE
    , p12_a2 out nocopy JTF_DATE_TABLE
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_NUMBER_TABLE
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a7 out nocopy JTF_NUMBER_TABLE
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a9 out nocopy JTF_NUMBER_TABLE
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a11 out nocopy JTF_NUMBER_TABLE
    , p12_a12 out nocopy JTF_NUMBER_TABLE
    , p12_a13 out nocopy JTF_NUMBER_TABLE
    , p12_a14 out nocopy JTF_NUMBER_TABLE
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a16 out nocopy JTF_NUMBER_TABLE
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a19 out nocopy JTF_NUMBER_TABLE
    , p12_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a36 out nocopy JTF_NUMBER_TABLE
    , p12_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a38 out nocopy JTF_NUMBER_TABLE
    , p12_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , x_returned_rec_count out nocopy  NUMBER
    , x_next_rec_ptr out nocopy  NUMBER
    , x_tot_rec_count out nocopy  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  DATE := fnd_api.g_miss_date
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  DATE := fnd_api.g_miss_date
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a0  VARCHAR2 := fnd_api.g_miss_char
    , p8_a1  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure create_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_success_if_exists_flag  VARCHAR2
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
  );
  procedure update_transactions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  DATE := fnd_api.g_miss_date
    , p4_a39  NUMBER := 0-1962.0724
  );
  procedure create_txn_error(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_transaction_error_id out nocopy  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  DATE := fnd_api.g_miss_date
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  NUMBER := 0-1962.0724
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  NUMBER := 0-1962.0724
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  NUMBER := 0-1962.0724
    , p4_a21  NUMBER := 0-1962.0724
    , p4_a22  NUMBER := 0-1962.0724
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  NUMBER := 0-1962.0724
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  DATE := fnd_api.g_miss_date
    , p4_a30  NUMBER := 0-1962.0724
    , p4_a31  NUMBER := 0-1962.0724
    , p4_a32  NUMBER := 0-1962.0724
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  NUMBER := 0-1962.0724
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  NUMBER := 0-1962.0724
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
  );
end csi_transactions_pvt_w;

/
