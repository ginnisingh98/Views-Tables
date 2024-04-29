--------------------------------------------------------
--  DDL for Package OKL_VP_EXTEND_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_EXTEND_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEEXTS.pls 120.1 2005/07/11 12:49:34 dkagrawa noship $ */
  procedure extend_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
  );
end okl_vp_extend_pvt_w;

 

/
