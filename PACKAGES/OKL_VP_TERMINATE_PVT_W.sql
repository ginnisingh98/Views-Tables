--------------------------------------------------------
--  DDL for Package OKL_VP_TERMINATE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_TERMINATE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLETERS.pls 120.1 2005/07/12 09:11:43 dkagrawa noship $ */
  procedure terminate_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
  );
end okl_vp_terminate_pvt_w;

 

/
