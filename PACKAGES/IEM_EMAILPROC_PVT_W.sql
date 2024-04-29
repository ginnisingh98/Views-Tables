--------------------------------------------------------
--  DDL for Package IEM_EMAILPROC_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_EMAILPROC_PVT_W" AUTHID CURRENT_USER as
  /* $Header: iemvepcs.pls 115.4 2003/08/19 20:44:38 liangxia noship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy iem_emailproc_pvt.emailproc_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t iem_emailproc_pvt.emailproc_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p7(t out nocopy iem_emailproc_pvt.acctemailproc_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p7(t iem_emailproc_pvt.acctemailproc_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure loademailproc(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure loadacctemailproc(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_acct_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end iem_emailproc_pvt_w;

 

/
