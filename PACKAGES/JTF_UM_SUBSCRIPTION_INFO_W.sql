--------------------------------------------------------
--  DDL for Package JTF_UM_SUBSCRIPTION_INFO_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_SUBSCRIPTION_INFO_W" AUTHID CURRENT_USER as
  /* $Header: JTFWSBIS.pls 120.2 2005/09/02 18:36:20 applrt ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy jtf_um_subscription_info.subscription_info_table, a0 JTF_VARCHAR2_TABLE_1000
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p2(t jtf_um_subscription_info.subscription_info_table, a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_300
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p3(t out nocopy jtf_um_subscription_info.subscription_list, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t jtf_um_subscription_info.subscription_list, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure get_usertype_sub_info(p_usertype_id  NUMBER
    , p_user_id  NUMBER
    , p_is_admin  NUMBER
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure get_user_sub_info(p_user_id  NUMBER
    , p_is_admin  NUMBER
    , p_logged_in_user_id  NUMBER
    , p_administrator  NUMBER
    , p_sub_status  VARCHAR2
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure get_conf_sub_info(p_user_id  NUMBER
    , p_usertype_id  NUMBER
    , p_is_admin  NUMBER
    , p_admin_id  NUMBER
    , p_administrator  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure get_usertype_sub(p_usertype_id  NUMBER
    , p_user_id  NUMBER
    , p_is_admin  NUMBER
    , p_admin_id  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_300
  );
end jtf_um_subscription_info_w;

 

/
