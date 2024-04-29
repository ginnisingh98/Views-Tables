--------------------------------------------------------
--  DDL for Package CSP_PARTS_REQUIREMENT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PARTS_REQUIREMENT_W" AUTHID CURRENT_USER as
  /* $Header: cspwprqs.pls 120.0.12010000.4 2012/02/13 17:30:55 htank ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy csp_parts_requirement.line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p2(t csp_parts_requirement.line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure rosetta_table_copy_in_p4(t out nocopy csp_parts_requirement.line_detail_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t csp_parts_requirement.line_detail_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p6(t out nocopy csp_parts_requirement.rqmt_line_tbl_type, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t csp_parts_requirement.rqmt_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p8(t out nocopy csp_parts_requirement.order_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p8(t csp_parts_requirement.order_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure process_requirement(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy  NUMBER
    , p3_a1 in out nocopy  VARCHAR2
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  NUMBER
    , p3_a4 in out nocopy  NUMBER
    , p3_a5 in out nocopy  NUMBER
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  NUMBER
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  DATE
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  VARCHAR2
    , p3_a12 in out nocopy  VARCHAR2
    , p3_a13 in out nocopy  NUMBER
    , p3_a14 in out nocopy  VARCHAR2
    , p3_a15 in out nocopy  VARCHAR2
    , p3_a16 in out nocopy  VARCHAR2
    , p3_a17 in out nocopy  NUMBER
    , p3_a18 in out nocopy  NUMBER
    , p3_a19 in out nocopy  VARCHAR2
    , p3_a20 in out nocopy  VARCHAR2
    , p3_a21 in out nocopy  VARCHAR2
    , p3_a22 in out nocopy  NUMBER
    , p3_a23 in out nocopy  VARCHAR2
    , p3_a24 in out nocopy  VARCHAR2
    , p3_a25 in out nocopy  NUMBER
    , p3_a26 in out nocopy  VARCHAR2
    , p3_a27 in out nocopy  VARCHAR2
    , p3_a28 in out nocopy  VARCHAR2
    , p3_a29 in out nocopy  VARCHAR2
    , p3_a30 in out nocopy  VARCHAR2
    , p3_a31 in out nocopy  VARCHAR2
    , p3_a32 in out nocopy  VARCHAR2
    , p3_a33 in out nocopy  VARCHAR2
    , p3_a34 in out nocopy  VARCHAR2
    , p3_a35 in out nocopy  VARCHAR2
    , p3_a36 in out nocopy  VARCHAR2
    , p3_a37 in out nocopy  VARCHAR2
    , p3_a38 in out nocopy  VARCHAR2
    , p3_a39 in out nocopy  VARCHAR2
    , p3_a40 in out nocopy  VARCHAR2
    , p3_a41 in out nocopy  VARCHAR2
    , p3_a42 in out nocopy  VARCHAR2
    , p3_a43 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_NUMBER_TABLE
    , p4_a15 in out nocopy JTF_DATE_TABLE
    , p4_a16 in out nocopy JTF_DATE_TABLE
    , p4_a17 in out nocopy JTF_DATE_TABLE
    , p4_a18 in out nocopy JTF_NUMBER_TABLE
    , p4_a19 in out nocopy JTF_NUMBER_TABLE
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p_create_order_flag  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure csptrreq_fm_order(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy  NUMBER
    , p3_a1 in out nocopy  VARCHAR2
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  NUMBER
    , p3_a4 in out nocopy  NUMBER
    , p3_a5 in out nocopy  NUMBER
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  NUMBER
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  DATE
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  VARCHAR2
    , p3_a12 in out nocopy  VARCHAR2
    , p3_a13 in out nocopy  NUMBER
    , p3_a14 in out nocopy  VARCHAR2
    , p3_a15 in out nocopy  VARCHAR2
    , p3_a16 in out nocopy  VARCHAR2
    , p3_a17 in out nocopy  NUMBER
    , p3_a18 in out nocopy  NUMBER
    , p3_a19 in out nocopy  VARCHAR2
    , p3_a20 in out nocopy  VARCHAR2
    , p3_a21 in out nocopy  VARCHAR2
    , p3_a22 in out nocopy  NUMBER
    , p3_a23 in out nocopy  VARCHAR2
    , p3_a24 in out nocopy  VARCHAR2
    , p3_a25 in out nocopy  NUMBER
    , p3_a26 in out nocopy  VARCHAR2
    , p3_a27 in out nocopy  VARCHAR2
    , p3_a28 in out nocopy  VARCHAR2
    , p3_a29 in out nocopy  VARCHAR2
    , p3_a30 in out nocopy  VARCHAR2
    , p3_a31 in out nocopy  VARCHAR2
    , p3_a32 in out nocopy  VARCHAR2
    , p3_a33 in out nocopy  VARCHAR2
    , p3_a34 in out nocopy  VARCHAR2
    , p3_a35 in out nocopy  VARCHAR2
    , p3_a36 in out nocopy  VARCHAR2
    , p3_a37 in out nocopy  VARCHAR2
    , p3_a38 in out nocopy  VARCHAR2
    , p3_a39 in out nocopy  VARCHAR2
    , p3_a40 in out nocopy  VARCHAR2
    , p3_a41 in out nocopy  VARCHAR2
    , p3_a42 in out nocopy  VARCHAR2
    , p3_a43 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_NUMBER_TABLE
    , p4_a15 in out nocopy JTF_DATE_TABLE
    , p4_a16 in out nocopy JTF_DATE_TABLE
    , p4_a17 in out nocopy JTF_DATE_TABLE
    , p4_a18 in out nocopy JTF_NUMBER_TABLE
    , p4_a19 in out nocopy JTF_NUMBER_TABLE
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure csptrreq_order_res(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy  NUMBER
    , p3_a1 in out nocopy  VARCHAR2
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  NUMBER
    , p3_a4 in out nocopy  NUMBER
    , p3_a5 in out nocopy  NUMBER
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  NUMBER
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  DATE
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  VARCHAR2
    , p3_a12 in out nocopy  VARCHAR2
    , p3_a13 in out nocopy  NUMBER
    , p3_a14 in out nocopy  VARCHAR2
    , p3_a15 in out nocopy  VARCHAR2
    , p3_a16 in out nocopy  VARCHAR2
    , p3_a17 in out nocopy  NUMBER
    , p3_a18 in out nocopy  NUMBER
    , p3_a19 in out nocopy  VARCHAR2
    , p3_a20 in out nocopy  VARCHAR2
    , p3_a21 in out nocopy  VARCHAR2
    , p3_a22 in out nocopy  NUMBER
    , p3_a23 in out nocopy  VARCHAR2
    , p3_a24 in out nocopy  VARCHAR2
    , p3_a25 in out nocopy  NUMBER
    , p3_a26 in out nocopy  VARCHAR2
    , p3_a27 in out nocopy  VARCHAR2
    , p3_a28 in out nocopy  VARCHAR2
    , p3_a29 in out nocopy  VARCHAR2
    , p3_a30 in out nocopy  VARCHAR2
    , p3_a31 in out nocopy  VARCHAR2
    , p3_a32 in out nocopy  VARCHAR2
    , p3_a33 in out nocopy  VARCHAR2
    , p3_a34 in out nocopy  VARCHAR2
    , p3_a35 in out nocopy  VARCHAR2
    , p3_a36 in out nocopy  VARCHAR2
    , p3_a37 in out nocopy  VARCHAR2
    , p3_a38 in out nocopy  VARCHAR2
    , p3_a39 in out nocopy  VARCHAR2
    , p3_a40 in out nocopy  VARCHAR2
    , p3_a41 in out nocopy  VARCHAR2
    , p3_a42 in out nocopy  VARCHAR2
    , p3_a43 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_NUMBER_TABLE
    , p4_a15 in out nocopy JTF_DATE_TABLE
    , p4_a16 in out nocopy JTF_DATE_TABLE
    , p4_a17 in out nocopy JTF_DATE_TABLE
    , p4_a18 in out nocopy JTF_NUMBER_TABLE
    , p4_a19 in out nocopy JTF_NUMBER_TABLE
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure save_rqmt_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy  NUMBER
    , p3_a1 in out nocopy  VARCHAR2
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  NUMBER
    , p3_a4 in out nocopy  NUMBER
    , p3_a5 in out nocopy  NUMBER
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  NUMBER
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  DATE
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  VARCHAR2
    , p3_a12 in out nocopy  VARCHAR2
    , p3_a13 in out nocopy  NUMBER
    , p3_a14 in out nocopy  VARCHAR2
    , p3_a15 in out nocopy  VARCHAR2
    , p3_a16 in out nocopy  VARCHAR2
    , p3_a17 in out nocopy  NUMBER
    , p3_a18 in out nocopy  NUMBER
    , p3_a19 in out nocopy  VARCHAR2
    , p3_a20 in out nocopy  VARCHAR2
    , p3_a21 in out nocopy  VARCHAR2
    , p3_a22 in out nocopy  NUMBER
    , p3_a23 in out nocopy  VARCHAR2
    , p3_a24 in out nocopy  VARCHAR2
    , p3_a25 in out nocopy  NUMBER
    , p3_a26 in out nocopy  VARCHAR2
    , p3_a27 in out nocopy  VARCHAR2
    , p3_a28 in out nocopy  VARCHAR2
    , p3_a29 in out nocopy  VARCHAR2
    , p3_a30 in out nocopy  VARCHAR2
    , p3_a31 in out nocopy  VARCHAR2
    , p3_a32 in out nocopy  VARCHAR2
    , p3_a33 in out nocopy  VARCHAR2
    , p3_a34 in out nocopy  VARCHAR2
    , p3_a35 in out nocopy  VARCHAR2
    , p3_a36 in out nocopy  VARCHAR2
    , p3_a37 in out nocopy  VARCHAR2
    , p3_a38 in out nocopy  VARCHAR2
    , p3_a39 in out nocopy  VARCHAR2
    , p3_a40 in out nocopy  VARCHAR2
    , p3_a41 in out nocopy  VARCHAR2
    , p3_a42 in out nocopy  VARCHAR2
    , p3_a43 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_NUMBER_TABLE
    , p4_a15 in out nocopy JTF_DATE_TABLE
    , p4_a16 in out nocopy JTF_DATE_TABLE
    , p4_a17 in out nocopy JTF_DATE_TABLE
    , p4_a18 in out nocopy JTF_NUMBER_TABLE
    , p4_a19 in out nocopy JTF_NUMBER_TABLE
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_rqmt_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure check_availability(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_header_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 out nocopy JTF_NUMBER_TABLE
    , p4_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 out nocopy JTF_NUMBER_TABLE
    , p4_a14 out nocopy JTF_NUMBER_TABLE
    , p4_a15 out nocopy JTF_DATE_TABLE
    , p4_a16 out nocopy JTF_DATE_TABLE
    , p4_a17 out nocopy JTF_DATE_TABLE
    , p4_a18 out nocopy JTF_NUMBER_TABLE
    , p4_a19 out nocopy JTF_NUMBER_TABLE
    , p4_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , x_avail_flag out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_order(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_header_id  NUMBER
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end csp_parts_requirement_w;

/
