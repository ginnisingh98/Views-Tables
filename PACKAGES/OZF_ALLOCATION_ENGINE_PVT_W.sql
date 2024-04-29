--------------------------------------------------------
--  DDL for Package OZF_ALLOCATION_ENGINE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ALLOCATION_ENGINE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwaegs.pls 115.1 2003/11/19 01:18:43 mkothari noship $ */
  procedure allocate_target(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_error_number out nocopy  NUMBER
    , x_error_message out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , p_fund_id  NUMBER
    , p_old_start_date  date
    , p_new_end_date  date
    , p_addon_fact_id  NUMBER
    , p_addon_amount  NUMBER
  );
end ozf_allocation_engine_pvt_w;

 

/
