--------------------------------------------------------
--  DDL for Package JTF_UM_INDIVIDUAL_USER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_INDIVIDUAL_USER_PVT_W" AUTHID CURRENT_USER as
  /* $Header: JTFWUIRS.pls 120.2 2005/09/02 18:37:05 applrt ship $ */
  procedure registerindividualuser(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_self_service_user  VARCHAR2
    , p4_a0 in out nocopy  VARCHAR2
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end jtf_um_individual_user_pvt_w;

 

/
