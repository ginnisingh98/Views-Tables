--------------------------------------------------------
--  DDL for Package PVX_CHANNEL_TYPE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_CHANNEL_TYPE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: pvwchnls.pls 115.6 2002/12/26 16:05:32 vansub ship $ */
  procedure create_channel_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_channel_type_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  DATE := fnd_api.g_miss_date
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
  );
  procedure update_channel_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  DATE := fnd_api.g_miss_date
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
  );
  procedure complete_channel_type_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  VARCHAR2
    , p1_a2 out nocopy  VARCHAR2
    , p1_a3 out nocopy  VARCHAR2
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  DATE
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
  );
end pvx_channel_type_pvt_w;

 

/
