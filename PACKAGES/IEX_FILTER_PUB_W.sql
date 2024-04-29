--------------------------------------------------------
--  DDL for Package IEX_FILTER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_FILTER_PUB_W" AUTHID CURRENT_USER as
  /* $Header: iexwfils.pls 120.1 2005/07/05 19:55:13 ctlee noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy iex_filter_pub.universe_ids, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p2(t iex_filter_pub.universe_ids, a0 out nocopy JTF_NUMBER_TABLE);

  procedure validate_filter(p_init_msg_list  VARCHAR2
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  DATE := fnd_api.g_miss_date
    , p1_a12  DATE := fnd_api.g_miss_date
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  DATE := fnd_api.g_miss_date
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  NUMBER := 0-1962.0724
  );
  procedure create_object_filter(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_filter_id out nocopy  NUMBER
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  DATE := fnd_api.g_miss_date
    , p3_a12  DATE := fnd_api.g_miss_date
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  DATE := fnd_api.g_miss_date
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  NUMBER := 0-1962.0724
  );
  procedure update_object_filter(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  DATE := fnd_api.g_miss_date
    , p3_a12  DATE := fnd_api.g_miss_date
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  DATE := fnd_api.g_miss_date
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  NUMBER := 0-1962.0724
  );
end iex_filter_pub_w;

 

/
