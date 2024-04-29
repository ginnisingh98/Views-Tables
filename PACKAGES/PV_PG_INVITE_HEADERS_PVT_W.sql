--------------------------------------------------------
--  DDL for Package PV_PG_INVITE_HEADERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PG_INVITE_HEADERS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: pvxwpihs.pls 120.1 2005/08/29 14:19 appldev ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy pv_pg_invite_headers_pvt.invite_headers_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p2(t pv_pg_invite_headers_pvt.invite_headers_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_4000
    );

  procedure create_invite_headers(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  DATE
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , x_invite_header_id out nocopy  NUMBER
  );
  procedure update_invite_headers(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  DATE
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
  );
  procedure validate_invite_headers(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  NUMBER
    , p3_a5  NUMBER
    , p3_a6  DATE
    , p3_a7  NUMBER
    , p3_a8  DATE
    , p3_a9  NUMBER
    , p3_a10  NUMBER
    , p3_a11  DATE
    , p3_a12  NUMBER
    , p3_a13  NUMBER
    , p3_a14  NUMBER
    , p3_a15  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure check_invite_headers_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  NUMBER
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  DATE
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure validate_invite_headers_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  VARCHAR2
  );
end pv_pg_invite_headers_pvt_w;

 

/
