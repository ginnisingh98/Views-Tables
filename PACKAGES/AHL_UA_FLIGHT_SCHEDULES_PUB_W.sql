--------------------------------------------------------
--  DDL for Package AHL_UA_FLIGHT_SCHEDULES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UA_FLIGHT_SCHEDULES_PUB_W" AUTHID CURRENT_USER as
  /* $Header: AHLUFSWS.pls 120.0 2005/05/26 01:38:33 appldev noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ahl_ua_flight_schedules_pub.flight_visit_sch_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t ahl_ua_flight_schedules_pub.flight_visit_sch_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_flight_schedule_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  DATE
    , p9_a10  DATE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_DATE_TABLE
    , p10_a4 out nocopy JTF_DATE_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 out nocopy JTF_DATE_TABLE
    , p10_a10 out nocopy JTF_DATE_TABLE
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_NUMBER_TABLE
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_NUMBER_TABLE
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure process_flight_schedules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 in out nocopy JTF_DATE_TABLE
    , p9_a4 in out nocopy JTF_DATE_TABLE
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_DATE_TABLE
    , p9_a10 in out nocopy JTF_DATE_TABLE
    , p9_a11 in out nocopy JTF_NUMBER_TABLE
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 in out nocopy JTF_NUMBER_TABLE
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 in out nocopy JTF_NUMBER_TABLE
    , p9_a16 in out nocopy JTF_NUMBER_TABLE
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 in out nocopy JTF_NUMBER_TABLE
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a24 in out nocopy JTF_NUMBER_TABLE
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a27 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a44 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure process_flightvisit_sch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 in out nocopy JTF_DATE_TABLE
    , p9_a4 in out nocopy JTF_DATE_TABLE
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_DATE_TABLE
    , p9_a10 in out nocopy JTF_DATE_TABLE
    , p9_a11 in out nocopy JTF_NUMBER_TABLE
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 in out nocopy JTF_NUMBER_TABLE
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 in out nocopy JTF_NUMBER_TABLE
    , p9_a16 in out nocopy JTF_NUMBER_TABLE
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 in out nocopy JTF_NUMBER_TABLE
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a24 in out nocopy JTF_NUMBER_TABLE
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a27 in out nocopy JTF_NUMBER_TABLE
    , p9_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a48 in out nocopy JTF_VARCHAR2_TABLE_100
  );
end ahl_ua_flight_schedules_pub_w;

 

/
