--------------------------------------------------------
--  DDL for Package LNS_FEE_ASSIGNMENT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_FEE_ASSIGNMENT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: LNS_FASGM_PUBJ_S.pls 120.2.12010000.3 2010/02/24 01:51:57 mbolli ship $ */
  procedure create_fee_assignment(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p1_a9  NUMBER
    , p1_a10  NUMBER
    , p1_a11  NUMBER
    , p1_a12  VARCHAR2
    , p1_a13  NUMBER
    , p1_a14  DATE
    , p1_a15  NUMBER
    , p1_a16  DATE
    , p1_a17  NUMBER
    , p1_a18  NUMBER
    , p1_a19  DATE
    , p1_a20  DATE
    , p1_a21  NUMBER
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , x_fee_assignment_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_fee_assignment(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p1_a9  NUMBER
    , p1_a10  NUMBER
    , p1_a11  NUMBER
    , p1_a12  VARCHAR2
    , p1_a13  NUMBER
    , p1_a14  DATE
    , p1_a15  NUMBER
    , p1_a16  DATE
    , p1_a17  NUMBER
    , p1_a18  NUMBER
    , p1_a19  DATE
    , p1_a20  DATE
    , p1_a21  NUMBER
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end lns_fee_assignment_pub_w;

/
