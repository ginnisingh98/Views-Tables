--------------------------------------------------------
--  DDL for Package PV_PRGM_BENEFITS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PRGM_BENEFITS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: pvxwppbs.pls 115.6 2003/11/07 06:13:59 ktsao ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy pv_prgm_benefits_pvt.program_benefits_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p2(t pv_prgm_benefits_pvt.program_benefits_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    );

  procedure create_prgm_benefits(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  DATE
    , x_program_benefits_id out nocopy  NUMBER
  );
  procedure update_prgm_benefits(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  DATE
  );
  procedure validate_prgm_benefits(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  NUMBER
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  NUMBER
    , p3_a7  NUMBER
    , p3_a8  DATE
    , p3_a9  NUMBER
    , p3_a10  NUMBER
    , p3_a11  DATE
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure check_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  DATE
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure validate_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  DATE
    , p_validation_mode  VARCHAR2
  );
  procedure complete_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  DATE
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  VARCHAR2
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  VARCHAR2
    , p1_a5 out nocopy  VARCHAR2
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  DATE
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  DATE
  );
end pv_prgm_benefits_pvt_w;

 

/
