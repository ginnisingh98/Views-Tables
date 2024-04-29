--------------------------------------------------------
--  DDL for Package CAC_VIEW_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_VIEW_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cacvpws.pls 120.3 2006/02/22 07:16:45 sankgupt noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cac_view_pvt.callsttbltype, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t cac_view_pvt.callsttbltype, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out nocopy cac_view_pvt.queryouttab, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_VARCHAR2_TABLE_2000
    , a17 JTF_VARCHAR2_TABLE_4000
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_400
    , a24 JTF_VARCHAR2_TABLE_4000
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t cac_view_pvt.queryouttab, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_400
    , a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure getcalendarlist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_resourceid in out nocopy  NUMBER
    , p_resourcetype in out nocopy  VARCHAR2
    , p_userid  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure getview(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  NUMBER
    , p6_a4  VARCHAR2
    , p6_a5  NUMBER
    , p6_a6  DATE
    , p6_a7  DATE
    , p6_a8  NUMBER
    , p6_a9  CHAR
    , p6_a10  CHAR
    , p6_a11  CHAR
    , p6_a12  CHAR
    , p6_a13  CHAR
    , p6_a14  CHAR
    , p6_a15  CHAR
    , p6_a16  CHAR
    , p6_a17  CHAR
    , p6_a18  CHAR
    , p6_a19  CHAR
    , p6_a20  CHAR
    , p6_a21  CHAR
    , p6_a22  CHAR
    , p6_a23  CHAR
    , p6_a24  CHAR
    , p6_a25  CHAR
    , p6_a26  CHAR
    , p6_a27  CHAR
    , p6_a28  CHAR
    , p6_a29  CHAR
    , p6_a30  CHAR
    , p6_a31  CHAR
    , p6_a32  CHAR
    , p6_a33  NUMBER
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_NUMBER_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_DATE_TABLE
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 out nocopy JTF_DATE_TABLE
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a25 out nocopy JTF_NUMBER_TABLE
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_100
  );
end cac_view_pvt_w;

 

/
