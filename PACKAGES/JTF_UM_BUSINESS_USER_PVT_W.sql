--------------------------------------------------------
--  DDL for Package JTF_UM_BUSINESS_USER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_BUSINESS_USER_PVT_W" AUTHID CURRENT_USER as
  /* $Header: JTFWUBRS.pls 120.4 2005/12/14 06:26 snellepa ship $ */
  procedure registerbusinessuser(p_api_version_number  NUMBER
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
    , p5_a0 in out nocopy  VARCHAR2
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  VARCHAR2
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  NUMBER
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure find_organization(p0_a0 in out nocopy  VARCHAR2
    , p0_a1 in out nocopy  VARCHAR2
    , p0_a2 in out nocopy  VARCHAR2
    , p0_a3 in out nocopy  VARCHAR2
    , p0_a4 in out nocopy  VARCHAR2
    , p0_a5 in out nocopy  VARCHAR2
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  VARCHAR2
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  VARCHAR2
    , p0_a10 in out nocopy  VARCHAR2
    , p0_a11 in out nocopy  VARCHAR2
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  VARCHAR2
    , p0_a16 in out nocopy  VARCHAR2
    , p0_a17 in out nocopy  NUMBER
    , p0_a18 in out nocopy  NUMBER
    , p0_a19 in out nocopy  DATE
    , p_search_value  VARCHAR2
    , p_use_name  number
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure create_organization(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy  VARCHAR2
    , p3_a1 in out nocopy  VARCHAR2
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  VARCHAR2
    , p3_a4 in out nocopy  VARCHAR2
    , p3_a5 in out nocopy  VARCHAR2
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  NUMBER
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  DATE
    , p3_a10 in out nocopy  VARCHAR2
    , p4_a0 in out nocopy  VARCHAR2
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  NUMBER
    , p4_a18 in out nocopy  NUMBER
    , p4_a19 in out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end jtf_um_business_user_pvt_w;

 

/
