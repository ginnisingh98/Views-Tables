--------------------------------------------------------
--  DDL for Package CSP_REQUIREMENT_LINES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REQUIREMENT_LINES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: csprqlpvtws.pls 120.0.12010000.1 2009/08/29 10:39:57 htank noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy csp_requirement_lines_pvt.requirement_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_DATE_TABLE
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t csp_requirement_lines_pvt.requirement_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_requirement_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_DATE_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_DATE_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_NUMBER_TABLE
    , p4_a12 JTF_VARCHAR2_TABLE_100
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_NUMBER_TABLE
    , p4_a17 JTF_NUMBER_TABLE
    , p4_a18 JTF_DATE_TABLE
    , p4_a19 JTF_VARCHAR2_TABLE_100
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_VARCHAR2_TABLE_200
    , p4_a24 JTF_VARCHAR2_TABLE_200
    , p4_a25 JTF_VARCHAR2_TABLE_200
    , p4_a26 JTF_VARCHAR2_TABLE_200
    , p4_a27 JTF_VARCHAR2_TABLE_200
    , p4_a28 JTF_VARCHAR2_TABLE_200
    , p4_a29 JTF_VARCHAR2_TABLE_200
    , p4_a30 JTF_VARCHAR2_TABLE_200
    , p4_a31 JTF_VARCHAR2_TABLE_200
    , p4_a32 JTF_VARCHAR2_TABLE_200
    , p4_a33 JTF_VARCHAR2_TABLE_200
    , p4_a34 JTF_VARCHAR2_TABLE_200
    , p4_a35 JTF_DATE_TABLE
    , p4_a36 JTF_VARCHAR2_TABLE_300
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_NUMBER_TABLE
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_DATE_TABLE
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_DATE_TABLE
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 out nocopy JTF_NUMBER_TABLE
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a15 out nocopy JTF_NUMBER_TABLE
    , p5_a16 out nocopy JTF_NUMBER_TABLE
    , p5_a17 out nocopy JTF_NUMBER_TABLE
    , p5_a18 out nocopy JTF_DATE_TABLE
    , p5_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a35 out nocopy JTF_DATE_TABLE
    , p5_a36 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 out nocopy JTF_NUMBER_TABLE
    , p5_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_requirement_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_DATE_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_DATE_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_NUMBER_TABLE
    , p4_a12 JTF_VARCHAR2_TABLE_100
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_NUMBER_TABLE
    , p4_a17 JTF_NUMBER_TABLE
    , p4_a18 JTF_DATE_TABLE
    , p4_a19 JTF_VARCHAR2_TABLE_100
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_VARCHAR2_TABLE_200
    , p4_a24 JTF_VARCHAR2_TABLE_200
    , p4_a25 JTF_VARCHAR2_TABLE_200
    , p4_a26 JTF_VARCHAR2_TABLE_200
    , p4_a27 JTF_VARCHAR2_TABLE_200
    , p4_a28 JTF_VARCHAR2_TABLE_200
    , p4_a29 JTF_VARCHAR2_TABLE_200
    , p4_a30 JTF_VARCHAR2_TABLE_200
    , p4_a31 JTF_VARCHAR2_TABLE_200
    , p4_a32 JTF_VARCHAR2_TABLE_200
    , p4_a33 JTF_VARCHAR2_TABLE_200
    , p4_a34 JTF_VARCHAR2_TABLE_200
    , p4_a35 JTF_DATE_TABLE
    , p4_a36 JTF_VARCHAR2_TABLE_300
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_NUMBER_TABLE
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_requirement_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_DATE_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_DATE_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_NUMBER_TABLE
    , p4_a12 JTF_VARCHAR2_TABLE_100
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_NUMBER_TABLE
    , p4_a17 JTF_NUMBER_TABLE
    , p4_a18 JTF_DATE_TABLE
    , p4_a19 JTF_VARCHAR2_TABLE_100
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_VARCHAR2_TABLE_200
    , p4_a24 JTF_VARCHAR2_TABLE_200
    , p4_a25 JTF_VARCHAR2_TABLE_200
    , p4_a26 JTF_VARCHAR2_TABLE_200
    , p4_a27 JTF_VARCHAR2_TABLE_200
    , p4_a28 JTF_VARCHAR2_TABLE_200
    , p4_a29 JTF_VARCHAR2_TABLE_200
    , p4_a30 JTF_VARCHAR2_TABLE_200
    , p4_a31 JTF_VARCHAR2_TABLE_200
    , p4_a32 JTF_VARCHAR2_TABLE_200
    , p4_a33 JTF_VARCHAR2_TABLE_200
    , p4_a34 JTF_VARCHAR2_TABLE_200
    , p4_a35 JTF_DATE_TABLE
    , p4_a36 JTF_VARCHAR2_TABLE_300
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_NUMBER_TABLE
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end csp_requirement_lines_pvt_w;

/
