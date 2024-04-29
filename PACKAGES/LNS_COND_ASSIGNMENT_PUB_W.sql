--------------------------------------------------------
--  DDL for Package LNS_COND_ASSIGNMENT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_COND_ASSIGNMENT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: LNS_CASGM_PUBJ_S.pls 120.2.12010000.2 2010/03/19 08:32:20 gparuchu ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy lns_cond_assignment_pub.cond_assignment_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t lns_cond_assignment_pub.cond_assignment_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_cond_assignment(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  NUMBER
    , p1_a11  DATE
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  VARCHAR2
    , x_cond_assignment_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_cond_assignment(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  NUMBER
    , p1_a11  DATE
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end lns_cond_assignment_pub_w;

/
