--------------------------------------------------------
--  DDL for Package OKL_COPY_CONTRACT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_COPY_CONTRACT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLECOPS.pls 120.1 2005/07/08 12:20:34 dkagrawa noship $ */
  procedure rosetta_table_copy_in_p29(t out nocopy okl_copy_contract_pvt.api_components_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p29(t okl_copy_contract_pvt.api_components_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p31(t out nocopy okl_copy_contract_pvt.api_lines_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p31(t okl_copy_contract_pvt.api_lines_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure is_copy_allowed(p_chr_id  NUMBER
    , p_sts_code  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure is_subcontract_allowed(p_chr_id  NUMBER
    , p_sts_code  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure update_target_contract(p_chr_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure copy_components(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_from_chr_id  NUMBER
    , p_to_chr_id  NUMBER
    , p_contract_number  VARCHAR2
    , p_contract_number_modifier  VARCHAR2
    , p_to_template_yn  VARCHAR2
    , p_copy_reference  VARCHAR2
    , p_copy_line_party_yn  VARCHAR2
    , p_scs_code  VARCHAR2
    , p_intent  VARCHAR2
    , p_prospect  VARCHAR2
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_VARCHAR2_TABLE_100
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p16_a0 JTF_NUMBER_TABLE
    , p16_a1 JTF_NUMBER_TABLE
    , p16_a2 JTF_NUMBER_TABLE
    , p16_a3 JTF_NUMBER_TABLE
    , p16_a4 JTF_VARCHAR2_TABLE_100
    , x_chr_id out nocopy  NUMBER
  );
end okl_copy_contract_pvt_w;

 

/
