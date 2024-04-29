--------------------------------------------------------
--  DDL for Package CUG_INCIDNT_ATTR_VALS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUG_INCIDNT_ATTR_VALS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: CUGRINWS.pls 115.4 2003/12/30 19:50:38 aneemuch ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cug_incidnt_attr_vals_pvt.sr_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
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
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t cug_incidnt_attr_vals_pvt.sr_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
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
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_runtime_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_NUMBER_TABLE
    , p3_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a5 in out nocopy JTF_DATE_TABLE
    , p3_a6 in out nocopy JTF_DATE_TABLE
    , p3_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a23 in out nocopy JTF_NUMBER_TABLE
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
end cug_incidnt_attr_vals_pvt_w;

 

/
