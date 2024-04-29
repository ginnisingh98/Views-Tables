--------------------------------------------------------
--  DDL for Package OKL_VP_COPY_CONTRACT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_COPY_CONTRACT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLECPXS.pls 120.2 2005/08/03 07:58:30 sjalasut noship $ */
  procedure copy_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , x_new_contract_id out nocopy  NUMBER
  );
end okl_vp_copy_contract_pvt_w;

 

/
