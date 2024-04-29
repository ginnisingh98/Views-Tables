--------------------------------------------------------
--  DDL for Package OKS_COV_ENT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_COV_ENT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKSPCEWS.pls 120.3 2005/12/22 11:14 jvarghes noship $ */
  procedure get_default_react_resolve_by(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  DATE
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  DATE
    , p6_a1 out nocopy  DATE
    , p7_a0 out nocopy  DATE
    , p7_a1 out nocopy  DATE
  );
end oks_cov_ent_pub_w;

 

/
