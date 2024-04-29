--------------------------------------------------------
--  DDL for Package CN_SRP_PAYGROUP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PAYGROUP_PUB_W" AUTHID CURRENT_USER as
  /* $Header: cnwspgps.pls 115.8 2002/12/08 09:26:43 pramadas ship $ */
  procedure assign_salesreps(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  DATE
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_status out nocopy  VARCHAR2
  );
  procedure update_srp_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  DATE
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p8_a0  VARCHAR2
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  DATE
    , p8_a5  DATE
    , p8_a6  VARCHAR2
    , p8_a7  NUMBER
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p_ovn  NUMBER
    , x_loading_status out nocopy  VARCHAR2
    , x_status out nocopy  VARCHAR2
  );
end cn_srp_paygroup_pub_w;

 

/
