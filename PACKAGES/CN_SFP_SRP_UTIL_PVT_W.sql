--------------------------------------------------------
--  DDL for Package CN_SFP_SRP_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SFP_SRP_UTIL_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwsfsrs.pls 115.0 2002/12/12 02:42:23 sbadami noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy cn_sfp_srp_util_pvt.string_tabletype, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p0(t cn_sfp_srp_util_pvt.string_tabletype, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure get_valid_plan_statuses(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default_all  VARCHAR2
    , p_type  VARCHAR2
    , x_values_tab out nocopy JTF_VARCHAR2_TABLE_100
    , x_meanings_tab out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end cn_sfp_srp_util_pvt_w;

 

/
