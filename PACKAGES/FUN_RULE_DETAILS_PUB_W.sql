--------------------------------------------------------
--  DDL for Package FUN_RULE_DETAILS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_DETAILS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: FUNXTMRULRDTRWS.pls 120.0 2005/06/20 04:30:03 ammishra noship $ */
  procedure create_rule_detail(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  NUMBER
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  DATE
    , p1_a9  NUMBER
    , p1_a10  DATE
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  VARCHAR2
    , x_rule_detail_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_rule_detail(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  NUMBER
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  DATE
    , p1_a9  NUMBER
    , p1_a10  DATE
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_rule_detail_rec(p_init_msg_list  VARCHAR2
    , p_rule_detail_id  NUMBER
    , p_rule_object_id  NUMBER
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  NUMBER
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  DATE
    , p3_a9 out nocopy  NUMBER
    , p3_a10 out nocopy  DATE
    , p3_a11 out nocopy  NUMBER
    , p3_a12 out nocopy  NUMBER
    , p3_a13 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end fun_rule_details_pub_w;

 

/
