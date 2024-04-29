--------------------------------------------------------
--  DDL for Package LNS_EXT_LOAN_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_EXT_LOAN_PUB_W" AUTHID CURRENT_USER as
  /* $Header: LNS_EXT_LOAN_PUBJ_S.pls 120.0.12010000.1 2009/03/16 12:08:09 gparuchu noship $ */
  procedure save_loan_extension(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure calc_new_terms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  DATE
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  NUMBER
    , p4_a17 in out nocopy  NUMBER
    , p4_a18 in out nocopy  DATE
    , p4_a19 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end lns_ext_loan_pub_w;

/
