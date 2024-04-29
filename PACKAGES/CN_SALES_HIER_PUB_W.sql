--------------------------------------------------------
--  DDL for Package CN_SALES_HIER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SALES_HIER_PUB_W" AUTHID CURRENT_USER as
  /* $Header: cnwhiers.pls 115.6 2002/11/25 23:56:59 fting ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_sales_hier_pub.hier_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p1(t cn_sales_hier_pub.hier_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out nocopy cn_sales_hier_pub.grp_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t cn_sales_hier_pub.grp_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_sales_hier(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p_salesrep_id  NUMBER
    , p_comp_group_id  NUMBER
    , p_date  date
    , p_start_record  NUMBER
    , p_increment_count  NUMBER
    , p_start_record_grp  NUMBER
    , p_increment_count_grp  NUMBER
    , p14_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 out nocopy JTF_DATE_TABLE
    , p14_a4 out nocopy JTF_DATE_TABLE
    , x_mgr_count out nocopy  NUMBER
    , p16_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p16_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a3 out nocopy JTF_DATE_TABLE
    , p16_a4 out nocopy JTF_DATE_TABLE
    , x_srp_count out nocopy  NUMBER
    , p18_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a1 out nocopy JTF_NUMBER_TABLE
    , p18_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p18_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , x_grp_count out nocopy  NUMBER
  );
end cn_sales_hier_pub_w;

 

/
