--------------------------------------------------------
--  DDL for Package AMS_OA_CUST_SETUP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_OA_CUST_SETUP_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amsacuss.pls 115.0 2003/09/15 16:21:20 vanbukum noship $ */
  procedure create_cust_setup(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , x_cust_setup_id out nocopy  NUMBER
  );
  procedure update_cust_setup(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
  );
  procedure validate_cust_setup(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  NUMBER
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  NUMBER
  );
  procedure check_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  DATE
    , p2_a4  NUMBER
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  VARCHAR2
    , p2_a8  NUMBER
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  NUMBER
  );
  procedure check_cust_setup_req_items(p_validation_mode  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  VARCHAR2
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , x_return_status out nocopy  VARCHAR2
  );
  procedure check_cust_setup_uk_items(p_validation_mode  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  VARCHAR2
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , x_return_status out nocopy  VARCHAR2
  );
  procedure check_cust_setup_fk_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , x_return_status out nocopy  VARCHAR2
  );
  procedure check_cust_setup_flag_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , x_return_status out nocopy  VARCHAR2
  );
  procedure complete_cust_setup_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  VARCHAR2
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  NUMBER
  );
  procedure init_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  VARCHAR2
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  NUMBER
  );
end ams_oa_cust_setup_pvt_w;

 

/
