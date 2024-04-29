--------------------------------------------------------
--  DDL for Package OKL_REV_LOSS_PROV_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REV_LOSS_PROV_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLURPVS.pls 120.3 2005/10/30 04:49:41 appldev noship $ */
  procedure reverse_loss_provisions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
  );
  procedure reverse_loss_provisions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_DATE_TABLE
  );
end okl_rev_loss_prov_pub_w;

 

/
