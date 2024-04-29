--------------------------------------------------------
--  DDL for Package JTF_UM_APPROVAL_REQUESTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_APPROVAL_REQUESTS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: JTFWAPRS.pls 120.2.12010000.3 2013/03/27 08:00:30 anurtrip ship $ */

  procedure rosetta_table_copy_in_p1(t out nocopy jtf_um_approval_requests_pvt.approval_request_table_type, a0 JTF_DATE_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_1000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_out_p1(t jtf_um_approval_requests_pvt.approval_request_table_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_1000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    );

  procedure pending_approval_sysadmin(p_sort_order  VARCHAR2
    , p_number_of_records  NUMBER
    , p2_a0 out nocopy JTF_DATE_TABLE
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_1000
    , p2_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a6 out nocopy JTF_NUMBER_TABLE
    , p2_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a8 out nocopy JTF_NUMBER_TABLE
    , p_sort_option VARCHAR2
  );
  procedure pending_approval_primary(p_sort_order  VARCHAR2
    , p_number_of_records  NUMBER
    , p_approver_user_id  NUMBER
    , p3_a0 out nocopy JTF_DATE_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_1000
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p_sort_option VARCHAR2
  );
  procedure pending_approval_owner(p_sort_order  VARCHAR2
    , p_number_of_records  NUMBER
    , p_approver_user_id  NUMBER
    , p3_a0 out nocopy JTF_DATE_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_1000
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p_sort_option VARCHAR2
  );
end jtf_um_approval_requests_pvt_w;

/
