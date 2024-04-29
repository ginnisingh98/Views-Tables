--------------------------------------------------------
--  DDL for Package CN_SFP_GROUP_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SFP_GROUP_UTIL_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwsfgrs.pls 115.0 2003/08/19 20:47:36 sbadami noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_sfp_group_util_pvt.srprole_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t cn_sfp_group_util_pvt.srprole_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p3(t out nocopy cn_sfp_group_util_pvt.grporg_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t cn_sfp_group_util_pvt.grporg_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out nocopy cn_sfp_group_util_pvt.grpnum_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p4(t cn_sfp_group_util_pvt.grpnum_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure get_descendant_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_selected_groups JTF_NUMBER_TABLE
    , p_effective_date  date
    , x_descendant_groups out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_salesrep_roles(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_selected_groups JTF_NUMBER_TABLE
    , p_status  VARCHAR2
    , p_effective_date  date
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_grp_organization_access(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_comp_group_id  NUMBER
    , p_effective_date  date
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end cn_sfp_group_util_pvt_w;

 

/
