--------------------------------------------------------
--  DDL for Package CN_CREDIT_TYPE_CONV_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CREDIT_TYPE_CONV_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwctcns.pls 115.4 2002/11/25 14:42:28 rarajara ship $ */
  procedure create_conversion(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_from_credit_type  NUMBER
    , p_to_credit_type  NUMBER
    , p_conv_factor  NUMBER
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_conversion(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_object_version  NUMBER
    , p_conv_id  NUMBER
    , p_from_credit_type  NUMBER
    , p_to_credit_type  NUMBER
    , p_conv_factor  NUMBER
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end cn_credit_type_conv_pvt_w;

 

/
