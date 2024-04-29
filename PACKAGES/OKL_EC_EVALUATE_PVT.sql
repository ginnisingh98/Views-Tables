--------------------------------------------------------
--  DDL for Package OKL_EC_EVALUATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EC_EVALUATE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRECUS.pls 120.2 2005/08/23 05:37:52 asawanka noship $ */

  ------------------------------------------------------------------------------
  -- data structures  declaration
  ------------------------------------------------------------------------------

  SUBTYPE okl_ech_rec IS okl_ech_pvt.okl_ech_rec;

  SUBTYPE okl_ecl_rec IS okl_ecl_pvt.okl_ecl_rec;

  SUBTYPE okl_ecv_rec IS okl_ecv_pvt.okl_ecv_rec;

  SUBTYPE okl_ecl_tbl IS okl_ecl_pvt.okl_ecl_tbl;

  SUBTYPE okl_ecv_tbl IS okl_ecv_pvt.okl_ecv_tbl;

  TYPE okl_number_table_type IS TABLE OF number INDEX BY BINARY_INTEGER;

  TYPE okl_varchar2_table_type IS TABLE OF varchar2(240)
    INDEX BY BINARY_INTEGER;

  TYPE okl_date_tabe_type IS TABLE OF date INDEX BY BINARY_INTEGER;

  TYPE okl_qa_result_rec_type IS RECORD (
    message varchar2(240),
    status  varchar2(30)
  );

  TYPE okl_qa_result_tbl_type IS TABLE OF okl_qa_result_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE okl_ec_rec_type IS RECORD (
    src_id                      number,
    source_name                 varchar2(240),
    target_id                   number,
    src_type                    varchar2(30),
    target_type                 varchar2(30),
    target_eff_from             date,
    term                        number,
    territory                   varchar2(240),
    deal_size                   number,
    customer_credit_class       varchar2(240),
    down_payment                number,
    advance_rent                number,
    trade_in_value              number,
    item_table                  okl_number_table_type,
    item_categories_table       okl_number_table_type,
    validation_mode             varchar2(30),
    consolidated_status         varchar2(30),
    qa_result_tbl               okl_qa_result_tbl_type,
    currency_code               varchar2(30)
  );
  g_ec_rec okl_ec_rec_type;

  TYPE okl_ac_rec_type IS RECORD (
    src_id                number,
    source_name           varchar2(240),
    target_id             number,
    src_type              varchar2(30),
    target_type           varchar2(30),
    target_eff_from       date,
    term                  number,
    territory             varchar2(240),
    deal_size             number,
    customer_credit_class varchar2(240)
  );
  g_ac_rec okl_ac_rec_type;

  TYPE okl_ec_values_rec_type IS RECORD (
    operator_code       varchar2(30),
    value1              varchar2(240),
    value2              varchar2(240),
    match_criteria_code varchar2(30)
  );

  TYPE okl_ec_values_tbl_type IS TABLE OF okl_ec_values_rec_type
    INDEX BY BINARY_INTEGER;
  g_ec_values_tbl okl_ec_values_tbl_type;
  g_ac_values_tbl okl_ec_values_tbl_type;

  ------------------------------------------------------------------------------
  -- Global Variables
  ------------------------------------------------------------------------------
  g_pkg_name         CONSTANT varchar2(200) := 'OKL_EC_EVALUATE_PVT';
  g_app_name         CONSTANT varchar2(3)   := okl_api.g_app_name;
  g_unexpected_error CONSTANT varchar2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token    CONSTANT varchar2(200) := 'SQLERRM';
  g_sqlcode_token    CONSTANT varchar2(200) := 'SQLCODE';

  --------------------------------------------------------------------------------
  -- Procedures and Functions
  --------------------------------------------------------------------------------

  PROCEDURE validate(
                    p_api_version                  IN              number
                   ,p_init_msg_list                IN              varchar2 DEFAULT okl_api.g_false
                   ,x_return_status                     OUT nocopy varchar2
                   ,x_msg_count                         OUT nocopy number
                   ,x_msg_data                          OUT nocopy varchar2
                   ,p_okl_ec_rec                   IN   OUT nocopy okl_ec_rec_type
                   ,x_eligible                          OUT nocopy boolean
                   );

  PROCEDURE get_adjustment_factor(
                                  p_api_version                  In              number
                                 ,p_init_msg_list                In              varchar2 Default Okl_api.G_false
                                 ,x_return_status                     Out Nocopy varchar2
                                 ,x_msg_count                         Out Nocopy number
                                 ,x_msg_data                          Out Nocopy varchar2
                                 ,p_okl_ac_rec                   In              okl_ac_rec_type
                                 ,x_adjustment_factor                 Out Nocopy number
                                 );

  FUNCTION compare_eligibility_criteria(p_source_id1    IN  number
                                       ,p_source_type1  IN  varchar2
                                       ,p_source_id2    IN  number
                                       ,p_source_type2  IN  varchar2) RETURN boolean;

END okl_ec_evaluate_pvt;

 

/
