--------------------------------------------------------
--  DDL for Package FTE_SERVICES_UI_WRAPPER_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_SERVICES_UI_WRAPPER_W" AUTHID CURRENT_USER as
  /* $Header: FTESEWPS.pls 120.0 2005/06/29 18:57 jishen noship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy fte_services_ui_wrapper.lane_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t fte_services_ui_wrapper.lane_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy fte_services_ui_wrapper.rate_chart_header_table, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p6(t fte_services_ui_wrapper.rate_chart_header_table, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure rosetta_table_copy_in_p9(t out nocopy fte_services_ui_wrapper.rate_chart_line_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p9(t fte_services_ui_wrapper.rate_chart_line_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure rosetta_table_copy_in_p11(t out nocopy fte_services_ui_wrapper.rate_chart_break_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p11(t fte_services_ui_wrapper.rate_chart_break_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p13(t out nocopy fte_services_ui_wrapper.tl_line_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p13(t fte_services_ui_wrapper.tl_line_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    );

  procedure edit_tl_services(p_init_msg_list  VARCHAR2
    , p_transaction_type  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_DATE_TABLE
    , p2_a5 JTF_DATE_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_VARCHAR2_TABLE_100
    , p2_a8 JTF_NUMBER_TABLE
    , p2_a9 JTF_NUMBER_TABLE
    , p2_a10 JTF_VARCHAR2_TABLE_100
    , p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_DATE_TABLE
    , p3_a6 JTF_DATE_TABLE
    , p3_a7 JTF_VARCHAR2_TABLE_2000
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , p4_a12 JTF_VARCHAR2_TABLE_100
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_NUMBER_TABLE
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_DATE_TABLE
    , p4_a17 JTF_DATE_TABLE
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , x_status out nocopy  NUMBER
    , x_error_msg out nocopy  VARCHAR2
  );
  procedure rate_chart_wrapper(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_DATE_TABLE
    , p0_a7 JTF_VARCHAR2_TABLE_2000
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
    , p1_a3 JTF_VARCHAR2_TABLE_100
    , p1_a4 JTF_VARCHAR2_TABLE_100
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_NUMBER_TABLE
    , p1_a8 JTF_VARCHAR2_TABLE_100
    , p1_a9 JTF_VARCHAR2_TABLE_100
    , p1_a10 JTF_VARCHAR2_TABLE_100
    , p1_a11 JTF_VARCHAR2_TABLE_100
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p1_a13 JTF_NUMBER_TABLE
    , p1_a14 JTF_NUMBER_TABLE
    , p1_a15 JTF_NUMBER_TABLE
    , p1_a16 JTF_DATE_TABLE
    , p1_a17 JTF_DATE_TABLE
    , p1_a18 JTF_VARCHAR2_TABLE_200
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_NUMBER_TABLE
    , p_chart_type  VARCHAR2
    , x_status out nocopy  NUMBER
    , x_error_msg out nocopy  VARCHAR2
  );
  procedure tl_surcharge_wrapper(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_DATE_TABLE
    , p0_a7 JTF_VARCHAR2_TABLE_2000
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_VARCHAR2_TABLE_100
    , p1_a4 JTF_VARCHAR2_TABLE_100
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_DATE_TABLE
    , p1_a8 JTF_DATE_TABLE
    , p1_a9 JTF_NUMBER_TABLE
    , p1_a10 JTF_NUMBER_TABLE
    , p1_a11 JTF_NUMBER_TABLE
    , p1_a12 JTF_NUMBER_TABLE
    , p1_a13 JTF_NUMBER_TABLE
    , p1_a14 JTF_NUMBER_TABLE
    , p1_a15 JTF_NUMBER_TABLE
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_NUMBER_TABLE
    , p_action  VARCHAR2
    , x_status out nocopy  NUMBER
    , x_error_msg out nocopy  VARCHAR2
  );
end fte_services_ui_wrapper_w;

 

/
