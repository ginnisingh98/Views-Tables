--------------------------------------------------------
--  DDL for Package AMS_CAL_CRT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CAL_CRT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswccts.pls 115.1 2002/12/03 12:09:37 cgoyal noship $ */
  procedure rosetta_table_copy_in_p2(t OUT NOCOPY ams_cal_crt_pvt.cal_crt_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t ams_cal_crt_pvt.cal_crt_rec_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_DATE_TABLE
    , a9 OUT NOCOPY JTF_DATE_TABLE
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY JTF_DATE_TABLE
    , a13 OUT NOCOPY JTF_NUMBER_TABLE
    , a14 OUT NOCOPY JTF_DATE_TABLE
    , a15 OUT NOCOPY JTF_NUMBER_TABLE
    , a16 OUT NOCOPY JTF_NUMBER_TABLE
    , a17 OUT NOCOPY JTF_NUMBER_TABLE
    );

  procedure create_cal_crt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_criteria_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  DATE
    , p7_a9  DATE
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  DATE
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  DATE
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
  );
  procedure update_cal_crt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  DATE
    , p7_a9  DATE
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  DATE
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  DATE
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
  );
  procedure validate_cal_crt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  VARCHAR2
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  VARCHAR2
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  DATE
    , p3_a9  DATE
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  DATE
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  DATE
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  NUMBER := 0-1962.0724
    , p3_a17  NUMBER := 0-1962.0724
  );
  procedure check_cal_crt_rec_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  DATE
    , p0_a9  DATE
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  DATE
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
  );
  procedure validate_cal_crt_rec_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  DATE
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
  );
end ams_cal_crt_pvt_w;

 

/
