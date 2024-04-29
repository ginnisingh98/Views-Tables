--------------------------------------------------------
--  DDL for Package JTF_RS_JSP_LOV_RECS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_JSP_LOV_RECS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfrsjws.pls 120.0 2005/05/11 08:20:26 appldev ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy jtf_rs_jsp_lov_recs_pub.lov_output_tbl_type, a0 JTF_VARCHAR2_TABLE_2000
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p2(t jtf_rs_jsp_lov_recs_pub.lov_output_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure get_lov_records(p_range_low  NUMBER
    , p_range_high  NUMBER
    , p_record_group_name  VARCHAR2
    , p_in_filter1  VARCHAR2
    , p_in_filter2  VARCHAR2
    , x_total_rows out nocopy  NUMBER
    , x_more_data_flag out nocopy  VARCHAR2
    , x_lov_ak_region out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , x_ext_col_cnt out nocopy  NUMBER
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  );
end jtf_rs_jsp_lov_recs_pub_w;

 

/
