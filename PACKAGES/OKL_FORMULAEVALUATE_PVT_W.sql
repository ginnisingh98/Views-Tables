--------------------------------------------------------
--  DDL for Package OKL_FORMULAEVALUATE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FORMULAEVALUATE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEEVAS.pls 120.1 2005/07/11 12:49:20 dkagrawa noship $ */
  procedure rosetta_table_copy_in_p24(t out nocopy okl_formulaevaluate_pvt.ctxparameter_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p24(t okl_formulaevaluate_pvt.ctxparameter_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p26(t out nocopy okl_formulaevaluate_pvt.function_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_800
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p26(t okl_formulaevaluate_pvt.function_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_800
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  function eva_getparameterids(p_fma_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a2 out nocopy JTF_NUMBER_TABLE
  ) return number;
  procedure eva_getparametervalues(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_fma_id  NUMBER
    , p_contract_id  NUMBER
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p_line_id  NUMBER
  );
  procedure eva_getfunctionvalue(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_fma_id  NUMBER
    , p_contract_id  NUMBER
    , p_line_id  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_VARCHAR2_TABLE_200
    , p8_a2 JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_800
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_NUMBER_TABLE
  );
end okl_formulaevaluate_pvt_w;

 

/
