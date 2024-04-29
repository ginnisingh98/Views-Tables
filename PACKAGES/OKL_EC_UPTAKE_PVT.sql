--------------------------------------------------------
--  DDL for Package OKL_EC_UPTAKE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EC_UPTAKE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRECXS.pls 120.12 2006/03/08 10:20:13 ssdeshpa noship $ */
 --------------------------------------------------------------------------
  --Added by ssdeshpa for EC uptakes on LRS,STR,Products on Lease Quote
  -------------------------------------------------------------------------
   --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200)  := 'OKL_EC_UPTAKE_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(200)  := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_USER_ID              CONSTANT NUMBER        := FND_GLOBAL.USER_ID;
  G_LOGIN_ID             CONSTANT NUMBER        := FND_GLOBAL.LOGIN_ID;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
  G_DB_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_DB_ERROR';
  G_PKG_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'PKG_NAME';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(30)  := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLERRM';

  ---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
--G_PKG_NAME		   CONSTANT VARCHAR2(200) := 'OKL_VALIDATION_SET_PVT';
  G_API_TYPE         CONSTANT varchar2(4) := '_PVT';
  G_QA_CHECKER_ERROR CONSTANT VARCHAR2(30):= 'OKL_EC_CRITERIA_ERROR';
  QA_CHECKER_UNEXP_ERROR  EXCEPTION;
--G_APP_NAME		   CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

  --SUBTYPE okl_ec_rec_type IS okl_ec_evaluate_pvt.okl_ec_rec_type;

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

  TYPE okl_lease_rate_set_rec_type IS RECORD (
    id                    number,
    rate_set_version_id   number,
    version_number        number,
    name                  okl_ls_rt_fctr_sets_v.name%TYPE,
    description           okl_ls_rt_fctr_sets_v.description%TYPE,
    effective_from        DATE,
    effective_to          DATE,
    lrs_rate              okl_fe_rate_set_versions_v.lrs_rate%TYPE,
    sts_code              okl_fe_rate_set_versions_v.sts_code%TYPE,
    frq_code              VARCHAR2(15),
    frq_meaning            VARCHAR2(240)
  );

  TYPE okl_lease_rate_set_tbl_type IS TABLE OF okl_lease_rate_set_rec_type
  INDEX BY BINARY_INTEGER;

  TYPE okl_std_rate_tmpl_rec_type IS RECORD (
    id                    number,
    std_rate_tmpl_ver_id  number,
    version_number        number,
    name                  okl_fe_std_rt_tmp_v.template_name%TYPE,
    description           okl_fe_std_rt_tmp_v.TEMPLATE_DESC%TYPE,
    frq_code              VARCHAR2(15),
    effective_from        DATE,
    effective_to          DATE,
    srt_rate              okl_fe_std_rt_tmp_vers.srt_rate%TYPE,
    sts_code              okl_fe_std_rt_tmp_vers.sts_code%TYPE,
    day_convention_code   okl_fe_std_rt_tmp_vers.day_convention_code%TYPE,
    frq_meaning            VARCHAR2(240)
  );

  TYPE okl_std_rate_tmpl_tbl_type IS TABLE OF okl_std_rate_tmpl_rec_type
    INDEX BY BINARY_INTEGER;


  TYPE okl_prod_rec_type IS RECORD (
    id                  number,
    name                okl_product_parameters_v.name%TYPE,
    product_subclass    okl_product_parameters_v.product_subclass%TYPE,
    version             number,
    description         okl_product_parameters_v.description%TYPE,
    product_status_code okl_product_parameters_v.product_status_code%TYPE,
    deal_type           okl_product_parameters_v.deal_type%TYPE,
    deal_type_meaning   okl_product_parameters_v.deal_type_meaning%TYPE
   );

  TYPE okl_prod_tbl_type IS TABLE OF okl_prod_rec_type
  INDEX BY BINARY_INTEGER;

  TYPE okl_vp_rec_type IS RECORD (
    id                  number,
    contract_number     okc_k_headers_b.contract_number%TYPE,
    start_date          DATE,
    end_date            DATE
   );

  TYPE okl_vp_tbl_type IS TABLE OF okl_vp_rec_type
  INDEX BY BINARY_INTEGER;


-----------------------------------------------------------------------------------------------------
--Populate Lease Rate Set For Lease Quote

  PROCEDURE populate_lease_rate_set(p_api_version             IN  NUMBER,
                                    p_init_msg_list           IN  VARCHAR2,
                                    p_target_id                   number,
                                    p_target_type             IN  varchar2,
                                    x_okl_lrs_table           OUT NOCOPY okl_lease_rate_set_tbl_type,
                                    x_return_status           OUT NOCOPY VARCHAR2,
                                    x_msg_count               OUT NOCOPY NUMBER,
                                    x_msg_data                OUT NOCOPY VARCHAR2);
 ------------------------------------------------------------------------------------

    PROCEDURE populate_std_rate_tmpl(p_api_version             IN  NUMBER,
                                    p_init_msg_list           IN  VARCHAR2,
                                    p_target_id                   number,
                                    p_target_type               IN  varchar2,
                                    x_okl_srt_table           OUT NOCOPY okl_std_rate_tmpl_tbl_type,
                                    x_return_status           OUT NOCOPY VARCHAR2,
                                    x_msg_count               OUT NOCOPY NUMBER,
                                    x_msg_data                OUT NOCOPY VARCHAR2);
-------------------------------------------------------------------------------------------
 --Populate Lease Rate Set For Quick Quote

  PROCEDURE populate_lease_rate_set(p_api_version             IN  NUMBER,
                                    p_init_msg_list           IN  VARCHAR2,
                                    p_target_id                   number,
                                    p_target_type               IN  varchar2,
                                    p_target_eff_from             date,
                                    p_term                       NUMBER,
                                    p_territory                  VARCHAR2,
                                    p_deal_size                   number,
                                    p_customer_credit_class       VARCHAR2,
                                    p_down_payment                number,
                                    p_advance_rent                number,
                                    p_trade_in_value              number,
                                    --Bug # 5045505 ssdeshpa start
                                    p_currency_code               VARCHAR2,
                                    --Bug # 5045505 ssdeshpa End
                                    p_item_table                  okl_number_table_type,
                                    p_item_categories_table       okl_number_table_type,
                                    x_okl_lrs_table           OUT NOCOPY okl_lease_rate_set_tbl_type,
                                    x_return_status           OUT NOCOPY VARCHAR2,
                                    x_msg_count               OUT NOCOPY NUMBER,
                                    x_msg_data                OUT NOCOPY VARCHAR2);
--------------------------------------------------------------------------------------------
   PROCEDURE populate_std_rate_tmpl(p_api_version             IN  NUMBER,
                                    p_init_msg_list           IN  VARCHAR2,
                                    p_target_id                   number,
                                    p_target_type               IN  varchar2,
                                    p_target_eff_from             date,
                                    p_term                      NUMBER,
                                    p_territory             VARCHAR2,
                                    p_deal_size                   number,
                                    p_customer_credit_class       VARCHAR2,
                                    p_down_payment                number,
                                    p_advance_rent                number,
                                    p_trade_in_value              number,
                                    --Bug # 5045505 ssdeshpa start
                                    p_currency_code               VARCHAR2,
                                    --Bug # 5045505 ssdeshpa End
                                    p_item_table                  okl_number_table_type,
                                    p_item_categories_table       okl_number_table_type,
                                    x_okl_srt_table           OUT NOCOPY okl_std_rate_tmpl_tbl_type,
                                    x_return_status           OUT NOCOPY VARCHAR2,
                                    x_msg_count               OUT NOCOPY NUMBER,
                                    x_msg_data                OUT NOCOPY VARCHAR2);
 --------------------------------------------------------------------------------------------

 PROCEDURE populate_product(p_api_version             IN  NUMBER,
                            p_init_msg_list           IN  VARCHAR2,
                            p_target_id                     number,
                            p_target_type             IN  varchar2,
                            x_okl_prod_table          OUT NOCOPY okl_prod_tbl_type,
                            x_return_status           OUT NOCOPY VARCHAR2,
                            x_msg_count               OUT NOCOPY NUMBER,
                            x_msg_data                OUT NOCOPY VARCHAR2);
 -------------------------------------------------------------------------------

 PROCEDURE populate_vendor_program(p_api_version             IN  NUMBER,
                                    p_init_msg_list           IN  VARCHAR2,
                                    p_target_id                   number,
                                    p_target_type               IN  varchar2,
                                    p_target_eff_from             date,
                                    p_term                      NUMBER,
                                    p_territory             VARCHAR2,
                                    p_deal_size                   number,
                                    p_customer_credit_class   VARCHAR2,
                                    p_down_payment                number,
                                    p_advance_rent                number,
                                    p_trade_in_value              number,
                                    p_item_table                  okl_number_table_type,
                                    p_item_categories_table       okl_number_table_type,
                                    x_okl_vp_table            OUT NOCOPY okl_vp_tbl_type,
                                    x_return_status           OUT NOCOPY VARCHAR2,
                                    x_msg_count               OUT NOCOPY NUMBER,
                                    x_msg_data                OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------------------------
  function get_vp_id(p_target_id number) RETURN NUMBER;



END OKL_EC_UPTAKE_PVT; -- Package spec

/
