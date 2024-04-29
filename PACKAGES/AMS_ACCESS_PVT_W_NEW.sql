--------------------------------------------------------
--  DDL for Package AMS_ACCESS_PVT_W_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACCESS_PVT_W_NEW" AUTHID CURRENT_USER as
  /* $Header: amsacess.pls 120.1 2005/08/29 06:01 anskumar noship $ */
  procedure create_access(p_api_version  NUMBER
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
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  DATE
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , x_access_id out nocopy  NUMBER
  );
  procedure update_access(p_api_version  NUMBER
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
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  DATE
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
  );
  procedure validate_access(p_api_version  NUMBER
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
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  NUMBER
    , p6_a10  VARCHAR2
    , p6_a11  DATE
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  DATE
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
  );
  procedure check_access_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  DATE
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  DATE
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure check_access_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  DATE
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  DATE
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  VARCHAR2
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  DATE
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  DATE
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure init_access_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  VARCHAR2
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  DATE
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  DATE
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  VARCHAR2
  );
  procedure complete_access_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  DATE
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  DATE
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  DATE
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  DATE
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
  );
  procedure check_admin_access(p_resource_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
end ams_access_pvt_w_new;

 

/
