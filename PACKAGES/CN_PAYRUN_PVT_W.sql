--------------------------------------------------------
--  DDL for Package CN_PAYRUN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAYRUN_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwpruns.pls 120.4 2005/09/29 19:43 rnagired ship $ */
  procedure create_payrun(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  VARCHAR2
    , p7_a2 in out nocopy  DATE
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  NUMBER
    , p7_a7 in out nocopy  DATE
    , p7_a8 in out nocopy  DATE
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  NUMBER
    , p7_a12 in out nocopy  NUMBER
    , x_loading_status out nocopy  VARCHAR2
    , x_status out nocopy  VARCHAR2
  );
end cn_payrun_pvt_w;

 

/
