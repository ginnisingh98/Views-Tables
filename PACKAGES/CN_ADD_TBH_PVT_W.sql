--------------------------------------------------------
--  DDL for Package CN_ADD_TBH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ADD_TBH_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwatbhs.pls 115.5 2002/11/25 22:22:17 nkodkani ship $ */
  procedure create_tbh(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_mgr_srp_id  NUMBER
    , p_name  VARCHAR2
    , p_emp_num  VARCHAR2
    , p_comp_group_id  NUMBER
    , p_start_date_active  date
    , p_end_date_active  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_srp_id out nocopy  NUMBER
  );
end cn_add_tbh_pvt_w;

 

/
