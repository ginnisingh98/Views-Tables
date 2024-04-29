--------------------------------------------------------
--  DDL for Package PVX_MDF_OWNERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_MDF_OWNERS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: pvxwmdfs.pls 115.9 2002/12/11 12:22:16 anubhavk ship $ */
  procedure create_mdf_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_mdf_owner_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  DATE := fnd_api.g_miss_date
  );
  procedure update_mdf_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  DATE := fnd_api.g_miss_date
  );
  procedure validate_mdf_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  VARCHAR2 := fnd_api.g_miss_char
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  DATE := fnd_api.g_miss_date
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  DATE := fnd_api.g_miss_date
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  DATE := fnd_api.g_miss_date
  );
  procedure check_mdf_owner_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  VARCHAR2 := fnd_api.g_miss_char
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  VARCHAR2 := fnd_api.g_miss_char
    , p2_a4  NUMBER := 0-1962.0724
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  NUMBER := 0-1962.0724
    , p2_a7  DATE := fnd_api.g_miss_date
    , p2_a8  NUMBER := 0-1962.0724
    , p2_a9  NUMBER := 0-1962.0724
    , p2_a10  NUMBER := 0-1962.0724
    , p2_a11  NUMBER := 0-1962.0724
    , p2_a12  NUMBER := 0-1962.0724
    , p2_a13  NUMBER := 0-1962.0724
    , p2_a14  DATE := fnd_api.g_miss_date
  );
  procedure check_mdf_owner_rec(p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  DATE := fnd_api.g_miss_date
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  DATE := fnd_api.g_miss_date
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  NUMBER := 0-1962.0724
    , p1_a12  NUMBER := 0-1962.0724
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  DATE := fnd_api.g_miss_date
  );
  procedure init_mdf_owner_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  VARCHAR2
    , p0_a2 out nocopy  VARCHAR2
    , p0_a3 out nocopy  VARCHAR2
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  DATE
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  DATE
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  NUMBER
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  DATE
  );
  procedure complete_mdf_owner_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  VARCHAR2
    , p1_a2 out nocopy  VARCHAR2
    , p1_a3 out nocopy  VARCHAR2
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  DATE
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  DATE
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  NUMBER
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  DATE
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
  );
end pvx_mdf_owners_pvt_w;

 

/
