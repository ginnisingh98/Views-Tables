--------------------------------------------------------
--  DDL for Package IEX_SCORE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_SCORE_PUB_W" AUTHID CURRENT_USER as
  /* $Header: iexwscrs.pls 120.6 2004/11/08 19:20:19 clchang ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy iex_score_pub.score_eng_comp_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p1(t iex_score_pub.score_eng_comp_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure rosetta_table_copy_in_p3(t out nocopy iex_score_pub.score_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_1000
    , a23 JTF_VARCHAR2_TABLE_1000
    , a24 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t iex_score_pub.score_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_1000
    , a23 out nocopy JTF_VARCHAR2_TABLE_1000
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p7(t out nocopy iex_score_pub.score_comp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t iex_score_pub.score_comp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p11(t out nocopy iex_score_pub.score_comp_det_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p11(t iex_score_pub.score_comp_det_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p15(t out nocopy iex_score_pub.score_comp_type_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p15(t iex_score_pub.score_comp_type_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p18(t out nocopy iex_score_pub.score_id_tbl, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p18(t iex_score_pub.score_id_tbl, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p19(t out nocopy iex_score_pub.score_comp_id_tbl, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p19(t iex_score_pub.score_comp_id_tbl, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p20(t out nocopy iex_score_pub.score_comp_det_id_tbl, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p20(t iex_score_pub.score_comp_det_id_tbl, a0 out nocopy JTF_NUMBER_TABLE);

  procedure create_score(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  VARCHAR2
    , p3_a2  DATE
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  DATE
    , p3_a10  DATE
    , p3_a11  NUMBER
    , p3_a12  VARCHAR2
    , p3_a13  NUMBER
    , p3_a14  VARCHAR2
    , p3_a15  NUMBER
    , p3_a16  NUMBER
    , p3_a17  NUMBER
    , p3_a18  NUMBER
    , p3_a19  DATE
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_score_id out nocopy  NUMBER
  );
  procedure update_score(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_300
    , p3_a2 JTF_DATE_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_DATE_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_VARCHAR2_TABLE_200
    , p3_a8 JTF_VARCHAR2_TABLE_100
    , p3_a9 JTF_DATE_TABLE
    , p3_a10 JTF_DATE_TABLE
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_VARCHAR2_TABLE_100
    , p3_a13 JTF_NUMBER_TABLE
    , p3_a14 JTF_VARCHAR2_TABLE_100
    , p3_a15 JTF_NUMBER_TABLE
    , p3_a16 JTF_NUMBER_TABLE
    , p3_a17 JTF_NUMBER_TABLE
    , p3_a18 JTF_NUMBER_TABLE
    , p3_a19 JTF_DATE_TABLE
    , p3_a20 JTF_VARCHAR2_TABLE_100
    , p3_a21 JTF_VARCHAR2_TABLE_100
    , p3_a22 JTF_VARCHAR2_TABLE_1000
    , p3_a23 JTF_VARCHAR2_TABLE_1000
    , p3_a24 JTF_VARCHAR2_TABLE_100
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_score(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_score_id_tbl JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_score_comp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  NUMBER
    , p3_a3  VARCHAR2
    , p3_a4  NUMBER
    , p3_a5  DATE
    , p3_a6  NUMBER
    , p3_a7  DATE
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_score_comp_id out nocopy  NUMBER
  );
  procedure update_score_comp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_DATE_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_DATE_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_score_comp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_score_id  NUMBER
    , p_score_comp_id_tbl JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_score_comp_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  NUMBER
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  DATE
    , p3_a8  NUMBER
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  NUMBER
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_score_comp_type_id out nocopy  NUMBER
  );
  procedure update_score_comp_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_DATE_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_DATE_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_VARCHAR2_TABLE_2000
    , p3_a10 JTF_VARCHAR2_TABLE_100
    , p3_a11 JTF_VARCHAR2_TABLE_100
    , p3_a12 JTF_VARCHAR2_TABLE_100
    , p3_a13 JTF_VARCHAR2_TABLE_100
    , p3_a14 JTF_VARCHAR2_TABLE_100
    , p3_a15 JTF_VARCHAR2_TABLE_100
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , p3_a17 JTF_NUMBER_TABLE
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_score_comp_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_DATE_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_DATE_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_VARCHAR2_TABLE_2000
    , p3_a10 JTF_VARCHAR2_TABLE_100
    , p3_a11 JTF_VARCHAR2_TABLE_100
    , p3_a12 JTF_VARCHAR2_TABLE_100
    , p3_a13 JTF_VARCHAR2_TABLE_100
    , p3_a14 JTF_VARCHAR2_TABLE_100
    , p3_a15 JTF_VARCHAR2_TABLE_100
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , p3_a17 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_score_comp_det(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_NUMBER_TABLE
    , p3_a2 in out nocopy JTF_NUMBER_TABLE
    , p3_a3 in out nocopy JTF_NUMBER_TABLE
    , p3_a4 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a5 in out nocopy JTF_NUMBER_TABLE
    , p3_a6 in out nocopy JTF_NUMBER_TABLE
    , p3_a7 in out nocopy JTF_NUMBER_TABLE
    , p3_a8 in out nocopy JTF_DATE_TABLE
    , p3_a9 in out nocopy JTF_NUMBER_TABLE
    , p3_a10 in out nocopy JTF_DATE_TABLE
    , p3_a11 in out nocopy JTF_NUMBER_TABLE
    , p3_a12 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_score_comp_det(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_VARCHAR2_TABLE_2000
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_DATE_TABLE
    , p3_a9 JTF_NUMBER_TABLE
    , p3_a10 JTF_DATE_TABLE
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_score_comp_det(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_score_comp_id  NUMBER
    , p_score_comp_det_id_tbl JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end iex_score_pub_w;

 

/
