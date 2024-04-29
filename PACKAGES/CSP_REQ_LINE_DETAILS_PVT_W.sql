--------------------------------------------------------
--  DDL for Package CSP_REQ_LINE_DETAILS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REQ_LINE_DETAILS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: csprqldpvtws.pls 120.0.12010000.1 2009/08/29 10:41:33 htank noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy csp_req_line_details_pvt.req_line_details_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t csp_req_line_details_pvt.req_line_details_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_req_line_details(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_DATE_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_NUMBER_TABLE
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_DATE_TABLE
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_DATE_TABLE
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_req_line_details(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_DATE_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_req_line_details(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_DATE_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end csp_req_line_details_pvt_w;

/
