--------------------------------------------------------
--  DDL for Package EAM_CONSTRUCTION_EST_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CONSTRUCTION_EST_PUB_W" AUTHID CURRENT_USER as
  /* $Header: EAMPCEWS.pls 120.0.12010000.3 2009/01/03 00:08:50 devijay noship $ */
  procedure explode_initial_estimate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_estimate_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure insert_all_wo_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_estimate_id  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_NUMBER_TABLE
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , p4_a10 JTF_VARCHAR2_TABLE_300
    , p4_a11 JTF_NUMBER_TABLE
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_DATE_TABLE
    , p4_a16 JTF_DATE_TABLE
    , p4_a17 JTF_NUMBER_TABLE
    , p4_a18 JTF_NUMBER_TABLE
    , p4_a19 JTF_NUMBER_TABLE
    , p4_a20 JTF_NUMBER_TABLE
    , p4_a21 JTF_NUMBER_TABLE
    , p4_a22 JTF_NUMBER_TABLE
    , p4_a23 JTF_NUMBER_TABLE
    , p4_a24 JTF_NUMBER_TABLE
    , p4_a25 JTF_VARCHAR2_TABLE_300
    , p4_a26 JTF_NUMBER_TABLE
    , p4_a27 JTF_NUMBER_TABLE
    , p4_a28 JTF_VARCHAR2_TABLE_4000
    , p4_a29 JTF_NUMBER_TABLE
    , p4_a30 JTF_NUMBER_TABLE
    , p4_a31 JTF_VARCHAR2_TABLE_100
    , p4_a32 JTF_NUMBER_TABLE
    , p4_a33 JTF_NUMBER_TABLE
    , p4_a34 JTF_NUMBER_TABLE
    , p4_a35 JTF_NUMBER_TABLE
    , p4_a36 JTF_NUMBER_TABLE
    , p4_a37 JTF_NUMBER_TABLE
    , p4_a38 JTF_NUMBER_TABLE
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , p4_a40 JTF_NUMBER_TABLE
    , p4_a41 JTF_VARCHAR2_TABLE_300
    , p4_a42 JTF_NUMBER_TABLE
    , p4_a43 JTF_VARCHAR2_TABLE_100
    , p4_a44 JTF_NUMBER_TABLE
    , p4_a45 JTF_NUMBER_TABLE
    , p4_a46 JTF_NUMBER_TABLE
    , p4_a47 JTF_VARCHAR2_TABLE_100
    , p4_a48 JTF_NUMBER_TABLE
    , p4_a49 JTF_NUMBER_TABLE
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_VARCHAR2_TABLE_300
    , p4_a52 JTF_NUMBER_TABLE
    , p4_a53 JTF_VARCHAR2_TABLE_100
    , p4_a54 JTF_DATE_TABLE
    , p4_a55 JTF_NUMBER_TABLE
    , p4_a56 JTF_NUMBER_TABLE
    , p4_a57 JTF_NUMBER_TABLE
    , p4_a58 JTF_NUMBER_TABLE
    , p4_a59 JTF_VARCHAR2_TABLE_300
    , p4_a60 JTF_NUMBER_TABLE
    , p4_a61 JTF_NUMBER_TABLE
    , p4_a62 JTF_NUMBER_TABLE
    , p4_a63 JTF_NUMBER_TABLE
    , p4_a64 JTF_NUMBER_TABLE
    , p4_a65 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure insert_parent_wo_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_estimate_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  DATE := fnd_api.g_miss_date
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  NUMBER := 0-1962.0724
  );
  procedure get_cu_recs(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_org_id  NUMBER
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_DATE_TABLE
    , p5_a5 in out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_cu_activities(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_cu_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_NUMBER_TABLE
    , p5_a13 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_estimate(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_estimate(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure set_activities_for_ce(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_ce_id  NUMBER
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a11 in out nocopy JTF_NUMBER_TABLE
    , p5_a12 in out nocopy JTF_NUMBER_TABLE
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_ce_wo_lns_by_group_opt(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  DATE := fnd_api.g_miss_date
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  NUMBER := 0-1962.0724
  );
end eam_construction_est_pub_w;

/
