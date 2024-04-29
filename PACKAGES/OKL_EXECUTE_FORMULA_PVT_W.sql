--------------------------------------------------------
--  DDL for Package OKL_EXECUTE_FORMULA_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EXECUTE_FORMULA_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEFMLS.pls 120.1 2005/07/11 12:49:49 dkagrawa noship $ */
  procedure rosetta_table_copy_in_p23(t out nocopy okl_execute_formula_pvt.operand_val_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_800
    , a2 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p23(t okl_execute_formula_pvt.operand_val_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_800
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p25(t out nocopy okl_execute_formula_pvt.ctxt_val_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p25(t okl_execute_formula_pvt.ctxt_val_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure execute(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_formula_name  VARCHAR2
    , p_contract_id  NUMBER
    , p_line_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_200
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , x_value out nocopy  NUMBER
  );
  procedure execute(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_formula_name  VARCHAR2
    , p_contract_id  NUMBER
    , p_line_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_200
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_800
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , x_value out nocopy  NUMBER
  );
end okl_execute_formula_pvt_w;

 

/
