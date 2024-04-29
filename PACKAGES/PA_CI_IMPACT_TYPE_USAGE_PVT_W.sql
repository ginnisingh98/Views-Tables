--------------------------------------------------------
--  DDL for Package PA_CI_IMPACT_TYPE_USAGE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_IMPACT_TYPE_USAGE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: PACIIMUS.pls 120.0.12010000.1 2009/06/08 18:58:25 cklee noship $ */
  procedure rosetta_table_copy_in_p9(t out nocopy pa_ci_impact_type_usage_pvt.impact_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p9(t pa_ci_impact_type_usage_pvt.impact_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure apply_ci_impact_type_usage(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validate_only  VARCHAR2
    , p_max_msg_count  NUMBER
    , p_ui_mode  VARCHAR2
    , p_ci_class_code  VARCHAR2
    , p_ci_type_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end pa_ci_impact_type_usage_pvt_w;

/
