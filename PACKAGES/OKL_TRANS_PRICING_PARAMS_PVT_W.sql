--------------------------------------------------------
--  DDL for Package OKL_TRANS_PRICING_PARAMS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRANS_PRICING_PARAMS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLESPMS.pls 120.2 2005/10/30 03:16:49 appldev noship $ */
  procedure rosetta_table_copy_in_p36(t out nocopy okl_trans_pricing_params_pvt.tpp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_500
    );
  procedure rosetta_table_copy_out_p36(t okl_trans_pricing_params_pvt.tpp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    );

  procedure create_trans_pricing_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_gts_id  NUMBER
    , p_sif_id  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure create_trans_pricing_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_500
    , p_chr_id  NUMBER
    , p_gts_id  NUMBER
    , p_sif_id  NUMBER
  );
end okl_trans_pricing_params_pvt_w;

 

/
