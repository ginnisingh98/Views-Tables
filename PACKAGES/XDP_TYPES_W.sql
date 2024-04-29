--------------------------------------------------------
--  DDL for Package XDP_TYPES_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_TYPES_W" AUTHID CURRENT_USER as
  /* $Header: XDPTYPWS.pls 120.1 2005/06/22 07:00:11 appldev ship $ */
  procedure rosetta_table_copy_in_p1(t OUT NOCOPY xdp_types.order_header_list, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t xdp_types.order_header_list, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_DATE_TABLE
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_DATE_TABLE
    , a5 OUT NOCOPY JTF_DATE_TABLE
    , a6 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a8 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY JTF_NUMBER_TABLE
    , a13 OUT NOCOPY JTF_NUMBER_TABLE
    , a14 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a15 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a16 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a17 OUT NOCOPY JTF_DATE_TABLE
    , a18 OUT NOCOPY JTF_DATE_TABLE
    , a19 OUT NOCOPY JTF_NUMBER_TABLE
    , a20 OUT NOCOPY JTF_NUMBER_TABLE
    , a21 OUT NOCOPY JTF_NUMBER_TABLE
    , a22 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a23 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a24 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a25 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a26 OUT NOCOPY JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY xdp_types.order_parameter_list, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p3(t xdp_types.order_parameter_list, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    );

  procedure rosetta_table_copy_in_p5(t OUT NOCOPY xdp_types.order_line_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t xdp_types.order_line_list, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY JTF_DATE_TABLE
    , a6 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_DATE_TABLE
    , a12 OUT NOCOPY JTF_DATE_TABLE
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a14 OUT NOCOPY JTF_DATE_TABLE
    , a15 OUT NOCOPY JTF_NUMBER_TABLE
    , a16 OUT NOCOPY JTF_NUMBER_TABLE
    , a17 OUT NOCOPY JTF_NUMBER_TABLE
    , a18 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a19 OUT NOCOPY JTF_NUMBER_TABLE
    , a20 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a21 OUT NOCOPY JTF_NUMBER_TABLE
    , a22 OUT NOCOPY JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t OUT NOCOPY xdp_types.line_param_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p7(t xdp_types.line_param_list, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    );

  procedure rosetta_table_copy_in_p11(t OUT NOCOPY xdp_types.service_order_line_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_DATE_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p11(t xdp_types.service_order_line_list, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a6 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_DATE_TABLE
    , a12 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a14 OUT NOCOPY JTF_NUMBER_TABLE
    , a15 OUT NOCOPY JTF_NUMBER_TABLE
    , a16 OUT NOCOPY JTF_NUMBER_TABLE
    , a17 OUT NOCOPY JTF_NUMBER_TABLE
    , a18 OUT NOCOPY JTF_DATE_TABLE
    , a19 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a20 OUT NOCOPY JTF_DATE_TABLE
    , a21 OUT NOCOPY JTF_NUMBER_TABLE
    , a22 OUT NOCOPY JTF_NUMBER_TABLE
    , a23 OUT NOCOPY JTF_NUMBER_TABLE
    , a24 OUT NOCOPY JTF_NUMBER_TABLE
    , a25 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a26 OUT NOCOPY JTF_DATE_TABLE
    , a27 OUT NOCOPY JTF_DATE_TABLE
    , a28 OUT NOCOPY JTF_NUMBER_TABLE
    , a29 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a30 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a31 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a32 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a33 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a34 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a35 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a36 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a37 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a38 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a39 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a40 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a41 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a42 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a43 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a44 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a45 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a46 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a47 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a48 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a49 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a50 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p15(t OUT NOCOPY xdp_types.service_order_param_list, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p15(t xdp_types.service_order_param_list, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    );

  procedure rosetta_table_copy_in_p19(t OUT NOCOPY xdp_types.service_line_param_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p19(t xdp_types.service_line_param_list, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    );

end xdp_types_w;

 

/