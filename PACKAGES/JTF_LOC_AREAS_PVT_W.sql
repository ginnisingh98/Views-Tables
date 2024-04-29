--------------------------------------------------------
--  DDL for Package JTF_LOC_AREAS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_LOC_AREAS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: jtfwloas.pls 120.2 2005/08/18 22:55:57 stopiwal ship $ */
  procedure create_loc_area(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_loc_area_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_loc_area(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_remove_flag  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_loc_area(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  DATE := fnd_api.g_miss_date
    , p6_a13  DATE := fnd_api.g_miss_date
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure check_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  DATE := fnd_api.g_miss_date
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  DATE := fnd_api.g_miss_date
    , p2_a4  NUMBER := 0-1962.0724
    , p2_a5  NUMBER := 0-1962.0724
    , p2_a6  NUMBER := 0-1962.0724
    , p2_a7  NUMBER := 0-1962.0724
    , p2_a8  NUMBER := 0-1962.0724
    , p2_a9  NUMBER := 0-1962.0724
    , p2_a10  DATE := fnd_api.g_miss_date
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  DATE := fnd_api.g_miss_date
    , p2_a13  DATE := fnd_api.g_miss_date
    , p2_a14  VARCHAR2 := fnd_api.g_miss_char
    , p2_a15  NUMBER := 0-1962.0724
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  NUMBER := 0-1962.0724
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure check_loc_area_req_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  DATE := fnd_api.g_miss_date
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  DATE := fnd_api.g_miss_date
    , p1_a13  DATE := fnd_api.g_miss_date
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  NUMBER := 0-1962.0724
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure check_loc_area_uk_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  DATE := fnd_api.g_miss_date
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  DATE := fnd_api.g_miss_date
    , p1_a13  DATE := fnd_api.g_miss_date
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  NUMBER := 0-1962.0724
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure check_loc_area_fk_items(x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure check_record(x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  DATE := fnd_api.g_miss_date
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  DATE := fnd_api.g_miss_date
    , p1_a13  DATE := fnd_api.g_miss_date
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  NUMBER := 0-1962.0724
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure complete_loc_area_rec(p1_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a1 OUT NOCOPY /* file.sql.39 change */  DATE
    , p1_a2 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a3 OUT NOCOPY /* file.sql.39 change */  DATE
    , p1_a4 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a5 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a6 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a7 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a8 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a9 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a10 OUT NOCOPY /* file.sql.39 change */  DATE
    , p1_a11 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a12 OUT NOCOPY /* file.sql.39 change */  DATE
    , p1_a13 OUT NOCOPY /* file.sql.39 change */  DATE
    , p1_a14 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a15 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a16 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a17 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a18 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a19 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure init_rec(p0_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a1 OUT NOCOPY /* file.sql.39 change */  DATE
    , p0_a2 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a3 OUT NOCOPY /* file.sql.39 change */  DATE
    , p0_a4 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a5 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a6 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a7 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a8 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a9 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a10 OUT NOCOPY /* file.sql.39 change */  DATE
    , p0_a11 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a12 OUT NOCOPY /* file.sql.39 change */  DATE
    , p0_a13 OUT NOCOPY /* file.sql.39 change */  DATE
    , p0_a14 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a15 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a16 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a17 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a18 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a19 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
end jtf_loc_areas_pvt_w;

 

/
