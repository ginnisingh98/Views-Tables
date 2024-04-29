--------------------------------------------------------
--  DDL for Package CN_JOB_TITLE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_JOB_TITLE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwjobs.pls 115.6 2002/11/25 22:24:29 nkodkani ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_job_title_pvt.job_title_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t cn_job_title_pvt.job_title_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p3(t out nocopy cn_job_title_pvt.job_role_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t cn_job_title_pvt.job_role_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_job_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  DATE
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_job_role_id out nocopy  NUMBER
  );
  procedure update_job_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  DATE
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_job_details(p_job_title_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_NUMBER_TABLE
    , p1_a2 out nocopy JTF_NUMBER_TABLE
    , p1_a3 out nocopy JTF_DATE_TABLE
    , p1_a4 out nocopy JTF_DATE_TABLE
    , p1_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a22 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_job_titles(p_range_low  NUMBER
    , p_range_high  NUMBER
    , p_search_name  VARCHAR2
    , p_search_code  VARCHAR2
    , x_total_rows out nocopy  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_all_job_titles(p0_a0 out nocopy JTF_NUMBER_TABLE
    , p0_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a3 out nocopy JTF_NUMBER_TABLE
    , p0_a4 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_job_roles(p0_a0 out nocopy JTF_NUMBER_TABLE
    , p0_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a3 out nocopy JTF_NUMBER_TABLE
    , p0_a4 out nocopy JTF_VARCHAR2_TABLE_100
  );
end cn_job_title_pvt_w;

 

/
