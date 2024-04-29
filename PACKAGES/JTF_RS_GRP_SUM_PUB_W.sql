--------------------------------------------------------
--  DDL for Package JTF_RS_GRP_SUM_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GRP_SUM_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfrsrgs.pls 120.0 2005/05/11 08:21:37 appldev ship $ */
  procedure rosetta_table_copy_in_p1(t out NOCOPY jtf_rs_grp_sum_pub.grp_sum_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t jtf_rs_grp_sum_pub.grp_sum_tbl_type, a0 out NOCOPY JTF_NUMBER_TABLE
    , a1 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 out NOCOPY JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY JTF_DATE_TABLE
    , a5 out NOCOPY JTF_DATE_TABLE
    , a6 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a7 out NOCOPY JTF_NUMBER_TABLE
    , a8 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a9 out NOCOPY JTF_NUMBER_TABLE
    );

  procedure get_group(p_range_low  NUMBER
    , p_range_high  NUMBER
    , p_called_from  VARCHAR2
    , p_user_id  NUMBER
    , p_group_name  VARCHAR2
    , p_group_number  VARCHAR2
    , p_group_desc  VARCHAR2
    , p_group_email  VARCHAR2
    , p_from_date  VARCHAR2
    , p_to_date  VARCHAR2
    , p_date_format  VARCHAR2
    , p_group_id  NUMBER
    , p_group_usage  VARCHAR2
    , x_total_rows out NOCOPY  NUMBER
    , p14_a0 out NOCOPY JTF_NUMBER_TABLE
    , p14_a1 out NOCOPY JTF_VARCHAR2_TABLE_100
    , p14_a2 out NOCOPY JTF_VARCHAR2_TABLE_300
    , p14_a3 out NOCOPY JTF_VARCHAR2_TABLE_100
    , p14_a4 out NOCOPY JTF_DATE_TABLE
    , p14_a5 out NOCOPY JTF_DATE_TABLE
    , p14_a6 out NOCOPY JTF_VARCHAR2_TABLE_100
    , p14_a7 out NOCOPY JTF_NUMBER_TABLE
    , p14_a8 out NOCOPY JTF_VARCHAR2_TABLE_100
    , p14_a9 out NOCOPY JTF_NUMBER_TABLE
  );
end jtf_rs_grp_sum_pub_w;

 

/
