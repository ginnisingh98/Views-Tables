--------------------------------------------------------
--  DDL for Package CN_RULESET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULESET_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwrsets.pls 120.2 2005/10/10 01:06 rramakri noship $ */
  procedure create_ruleset(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_ruleset_id out nocopy  NUMBER
    , p9_a0  NUMBER
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  DATE
    , p9_a4  DATE
    , p9_a5  VARCHAR2
    , p9_a6  NUMBER
    , p9_a7  VARCHAR2
    , p9_a8  NUMBER
  );
  procedure update_ruleset(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  VARCHAR2
    , p8_a2 in out nocopy  VARCHAR2
    , p8_a3 in out nocopy  DATE
    , p8_a4 in out nocopy  DATE
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  NUMBER
    , p8_a7 in out nocopy  VARCHAR2
    , p8_a8 in out nocopy  NUMBER
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  VARCHAR2
    , p9_a2 in out nocopy  VARCHAR2
    , p9_a3 in out nocopy  DATE
    , p9_a4 in out nocopy  DATE
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  NUMBER
  );
end cn_ruleset_pvt_w;

 

/
