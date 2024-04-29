--------------------------------------------------------
--  DDL for Package OKL_SECURITIZATION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SECURITIZATION_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLESZSS.pls 115.2 2003/10/10 21:24:35 mvasudev noship $ */
  procedure rosetta_table_copy_in_p29(t out nocopy okl_securitization_pvt.inv_agmt_chr_id_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_500
    );
  procedure rosetta_table_copy_out_p29(t okl_securitization_pvt.inv_agmt_chr_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    );

  procedure check_khr_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p_effective_date  date
    , p_effective_date_operator  VARCHAR2
    , p_stream_type_subclass  VARCHAR2
    , x_value out nocopy  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_500
  );
  procedure check_kle_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_kle_id  NUMBER
    , p_effective_date  date
    , p_effective_date_operator  VARCHAR2
    , p_stream_type_subclass  VARCHAR2
    , x_value out nocopy  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_500
  );
  procedure check_sty_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p_effective_date  date
    , p_effective_date_operator  VARCHAR2
    , p_sty_id  NUMBER
    , x_value out nocopy  VARCHAR2
    , x_inv_agmt_chr_id out nocopy  NUMBER
  );
  procedure check_stm_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_stm_id  NUMBER
    , p_effective_date  date
    , x_value out nocopy  VARCHAR2
  );
  procedure check_sel_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_sel_id  NUMBER
    , p_effective_date  date
    , x_value out nocopy  VARCHAR2
  );
  procedure buyback_asset(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_kle_id  NUMBER
    , p_effective_date  date
  );
  procedure buyback_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p_effective_date  date
  );
  procedure process_khr_investor_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p_effective_date  date
    , p_rgd_code  VARCHAR2
    , p_rdf_code  VARCHAR2
    , x_process_code out nocopy  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_500
  );
  procedure process_kle_investor_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_kle_id  NUMBER
    , p_effective_date  date
    , p_rgd_code  VARCHAR2
    , p_rdf_code  VARCHAR2
    , x_process_code out nocopy  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_500
  );
  procedure buyback_pool_contents(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_khr_id  NUMBER
    , p_pol_id  NUMBER
    , p_stream_type_subclass  VARCHAR2
    , p_effective_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure modify_pool_contents(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_reason  VARCHAR2
    , p_khr_id  NUMBER
    , p_kle_id  NUMBER
    , p_stream_type_subclass  VARCHAR2
    , p_transaction_date  date
    , p_effective_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure modify_pool_contents(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_reason  VARCHAR2
    , p_khr_id  NUMBER
    , p_kle_id  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p_transaction_date  date
    , p_effective_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end okl_securitization_pvt_w;

 

/
