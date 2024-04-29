--------------------------------------------------------
--  DDL for Package CSP_PARTS_ORDER_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PARTS_ORDER_W" AUTHID CURRENT_USER as
  /* $Header: csprqordws.pls 120.0.12010000.4 2012/02/13 17:28:44 htank noship $ */
  procedure process_order(p_api_version  NUMBER
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
    , p_process_type  VARCHAR2
    , p_book_order  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure process_purchase_req(p_api_version  NUMBER
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
  procedure cancel_order(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_VARCHAR2_TABLE_300
    , p1_a5 JTF_VARCHAR2_TABLE_100
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_VARCHAR2_TABLE_100
    , p1_a8 JTF_VARCHAR2_TABLE_100
    , p1_a9 JTF_NUMBER_TABLE
    , p1_a10 JTF_VARCHAR2_TABLE_100
    , p1_a11 JTF_VARCHAR2_TABLE_100
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p1_a13 JTF_NUMBER_TABLE
    , p1_a14 JTF_NUMBER_TABLE
    , p1_a15 JTF_DATE_TABLE
    , p1_a16 JTF_DATE_TABLE
    , p1_a17 JTF_DATE_TABLE
    , p1_a18 JTF_NUMBER_TABLE
    , p1_a19 JTF_NUMBER_TABLE
    , p1_a20 JTF_VARCHAR2_TABLE_100
    , p1_a21 JTF_VARCHAR2_TABLE_100
    , p1_a22 JTF_VARCHAR2_TABLE_100
    , p1_a23 JTF_VARCHAR2_TABLE_100
    , p1_a24 JTF_VARCHAR2_TABLE_100
    , p1_a25 JTF_VARCHAR2_TABLE_100
    , p1_a26 JTF_VARCHAR2_TABLE_200
    , p1_a27 JTF_VARCHAR2_TABLE_200
    , p1_a28 JTF_VARCHAR2_TABLE_200
    , p1_a29 JTF_VARCHAR2_TABLE_200
    , p1_a30 JTF_VARCHAR2_TABLE_200
    , p1_a31 JTF_VARCHAR2_TABLE_200
    , p1_a32 JTF_VARCHAR2_TABLE_200
    , p1_a33 JTF_VARCHAR2_TABLE_200
    , p1_a34 JTF_VARCHAR2_TABLE_200
    , p1_a35 JTF_VARCHAR2_TABLE_200
    , p1_a36 JTF_VARCHAR2_TABLE_200
    , p1_a37 JTF_VARCHAR2_TABLE_200
    , p1_a38 JTF_VARCHAR2_TABLE_200
    , p1_a39 JTF_VARCHAR2_TABLE_200
    , p1_a40 JTF_VARCHAR2_TABLE_200
    , p_process_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end csp_parts_order_w;

/
