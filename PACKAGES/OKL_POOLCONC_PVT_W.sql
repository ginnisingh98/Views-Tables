--------------------------------------------------------
--  DDL for Package OKL_POOLCONC_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_POOLCONC_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLESZCS.pls 120.2 2007/12/18 06:50:48 ssdeshpa ship $ */
  procedure rosetta_table_copy_in_p74(t out nocopy okl_poolconc_pvt.error_message_type, a0 JTF_VARCHAR2_TABLE_2000);
  procedure rosetta_table_copy_out_p74(t okl_poolconc_pvt.error_message_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000);

  procedure add_pool_contents_ui(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_request_id out nocopy  NUMBER
    , p_sty_id1  NUMBER
    , p_sty_id2  NUMBER
    , p_stream_type_subclass  VARCHAR2
    , p_multi_org  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  VARCHAR2 := fnd_api.g_miss_char
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  DATE := fnd_api.g_miss_date
    , p6_a12  DATE := fnd_api.g_miss_date
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  NUMBER := 0-1962.0724
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  DATE := fnd_api.g_miss_date
    , p6_a33  DATE := fnd_api.g_miss_date
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  DATE := fnd_api.g_miss_date
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure cleanup_pool_contents_ui(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_request_id out nocopy  NUMBER
    , p_stream_type_subclass  VARCHAR2
    , p_multi_org  VARCHAR2
    , p_action_code  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  VARCHAR2 := fnd_api.g_miss_char
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  DATE := fnd_api.g_miss_date
    , p6_a12  DATE := fnd_api.g_miss_date
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  NUMBER := 0-1962.0724
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  DATE := fnd_api.g_miss_date
    , p6_a33  DATE := fnd_api.g_miss_date
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  DATE := fnd_api.g_miss_date
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
  );
end okl_poolconc_pvt_w;

/
