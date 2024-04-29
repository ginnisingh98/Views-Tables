--------------------------------------------------------
--  DDL for Package HZ_DSS_SETUP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DSS_SETUP_PUB_W" AUTHID CURRENT_USER as
  /* $Header: ARHPDSJS.pls 120.2 2005/06/18 04:28:04 jhuang noship $ */
  procedure create_entity_profile_1(p_init_msg_list  VARCHAR2
    , x_entity_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  NUMBER := 0-1962.0724
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_entity_profile_2(p_init_msg_list  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  NUMBER := 0-1962.0724
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure create_scheme_function_3(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_scheme_function_4(p_init_msg_list  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
  );
end hz_dss_setup_pub_w;

 

/
