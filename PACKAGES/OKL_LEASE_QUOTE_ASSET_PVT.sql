--------------------------------------------------------
--  DDL for Package OKL_LEASE_QUOTE_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_QUOTE_ASSET_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRQUAS.pls 120.12 2008/02/08 07:07:43 veramach noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LEASE_QUOTE_ASSET_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(30)  := OKL_API.G_APP_NAME;
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
  ------------------
  -- DATA STRUCTURES
  ------------------
  subtype asset_rec_type is okl_ass_pvt.assv_rec_type;
  subtype asset_tbl_type is okl_ass_pvt.assv_tbl_type;
  subtype component_tbl_type is okl_aso_pvt.asov_tbl_type;
  subtype cashflow_hdr_rec_type is okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
  subtype cashflow_level_tbl_type is okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;
  subtype cf_object_rec_type is okl_cfo_pvt.cfov_rec_type;
  subtype cf_header_rec_type is okl_caf_pvt.cafv_rec_type;
  subtype cf_level_tbl_type is okl_cfl_pvt.cflv_tbl_type;

  subtype cdj_tbl_type is okl_cdj_pvt.cdjv_tbl_type;

  subtype asset_adj_tbl_type is okl_cdj_pvt.cdjv_tbl_type;

  TYPE asset_component_rec_type IS RECORD (
     id                             okl_asset_components_b.id%TYPE
    ,object_version_number          okl_asset_components_b.object_version_number%TYPE
    ,asset_id                       okl_asset_components_b.asset_id%TYPE
    ,inv_item_id                    okl_asset_components_b.inv_item_id%TYPE
    ,supplier_id                    okl_asset_components_b.supplier_id%TYPE
    ,primary_component              okl_asset_components_b.primary_component%TYPE
    ,unit_cost                      okl_asset_components_b.unit_cost%TYPE
    ,number_of_units                okl_asset_components_b.number_of_units%TYPE
    ,manufacturer_name              okl_asset_components_b.manufacturer_name%TYPE
    ,year_manufactured              okl_asset_components_b.year_manufactured%TYPE
    ,model_number                   okl_asset_components_b.model_number%TYPE
    ,short_description              okl_asset_components_tl.short_description%TYPE
    ,description                    okl_asset_components_tl.description%TYPE
    ,comments                       okl_asset_components_tl.comments%TYPE
    ,record_mode		            varchar2(10));
  TYPE asset_component_tbl_type IS TABLE OF asset_component_rec_type INDEX BY PLS_INTEGER;

  TYPE asset_adjustment_rec_type IS RECORD (
     id                             okl_cost_adjustments_b.id%TYPE
    ,object_version_number          okl_cost_adjustments_b.object_version_number%TYPE
    ,parent_object_code             okl_cost_adjustments_b.parent_object_code%TYPE
    ,parent_object_id               okl_cost_adjustments_b.parent_object_id%TYPE
    ,adjustment_source_type         okl_cost_adjustments_b.adjustment_source_type%TYPE
    ,adjustment_source_id           okl_cost_adjustments_b.adjustment_source_id%TYPE
    ,basis                          okl_cost_adjustments_b.basis%TYPE
    ,value                          okl_cost_adjustments_b.value%TYPE
    ,default_subsidy_amount         okl_cost_adjustments_b.value%TYPE
    ,processing_type                okl_cost_adjustments_b.processing_type%TYPE
    ,supplier_id                    okl_cost_adjustments_b.supplier_id%TYPE
    ,short_description              okl_cost_adjustments_tl.short_description%TYPE
    ,description                    okl_cost_adjustments_tl.description%TYPE
    ,comments                       okl_cost_adjustments_tl.comments%TYPE
    ,quote_id                       okl_lease_quotes_b.id%TYPE
    ,record_mode		                varchar2(10)
    ,adjustment_amount              okl_cost_adjustments_b.value%TYPE
    ,percent_basis_value            okl_cost_adjustments_b.percent_basis_value%TYPE
    --Bug # 5142940 ssdeshpa start
    ,stream_type_id                 okl_cost_adjustments_b.stream_type_id%TYPE);
    --Bug # 5142940 ssdeshpa end;

  TYPE asset_adjustment_tbl_type IS TABLE OF asset_adjustment_rec_type INDEX BY PLS_INTEGER;

  ----------------
  -- PROGRAM UNITS
  ----------------
  PROCEDURE create_asset (p_api_version             IN  NUMBER,
                          p_init_msg_list           IN  VARCHAR2,
                          p_transaction_control     IN  VARCHAR2,
                          p_asset_rec               IN  asset_rec_type,
                          p_component_tbl           IN  asset_component_tbl_type,
                          p_cf_hdr_rec              IN  cashflow_hdr_rec_type,
                          p_cf_level_tbl            IN  cashflow_level_tbl_type,
                          x_return_status           OUT NOCOPY VARCHAR2,
                          x_msg_count               OUT NOCOPY NUMBER,
                          x_msg_data                OUT NOCOPY VARCHAR2);
  PROCEDURE duplicate_asset (p_api_version             IN  NUMBER,
                             p_init_msg_list           IN  VARCHAR2,
                             p_transaction_control     IN  VARCHAR2,
                             p_source_asset_id         IN  NUMBER,
                             p_asset_rec               IN  asset_rec_type,
                             p_component_tbl           IN  asset_component_tbl_type,
                             p_cf_hdr_rec              IN  cashflow_hdr_rec_type,
                             p_cf_level_tbl            IN  cashflow_level_tbl_type,
                             x_return_status           OUT NOCOPY VARCHAR2,
                             x_msg_count               OUT NOCOPY NUMBER,
                             x_msg_data                OUT NOCOPY VARCHAR2);
  PROCEDURE duplicate_asset ( p_api_version             IN  NUMBER
                             ,p_init_msg_list           IN  VARCHAR2
                             ,p_transaction_control     IN  VARCHAR2
                             ,p_source_asset_id         IN  NUMBER
                             ,p_target_quote_id         IN  NUMBER
                             ,x_target_asset_id         OUT NOCOPY NUMBER
                             ,x_return_status           OUT NOCOPY VARCHAR2
                             ,x_msg_count               OUT NOCOPY NUMBER
                             ,x_msg_data                OUT NOCOPY VARCHAR2);
  PROCEDURE delete_asset (p_api_version             IN  NUMBER,
                          p_init_msg_list           IN  VARCHAR2,
                          p_transaction_control     IN  VARCHAR2,
                          p_asset_id                IN  NUMBER,
                          x_return_status           OUT NOCOPY VARCHAR2,
                          x_msg_count               OUT NOCOPY NUMBER,
                          x_msg_data                OUT NOCOPY VARCHAR2);
  PROCEDURE update_asset (p_api_version             IN  NUMBER,
                          p_init_msg_list           IN  VARCHAR2,
                          p_transaction_control     IN  VARCHAR2,
                          p_asset_rec               IN  asset_rec_type,
                          p_component_tbl           IN  asset_component_tbl_type,
                          p_cf_hdr_rec              IN  cashflow_hdr_rec_type,
                          p_cf_level_tbl            IN  cashflow_level_tbl_type,
                          x_return_status           OUT NOCOPY VARCHAR2,
                          x_msg_count               OUT NOCOPY NUMBER,
                          x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE create_adjustment (p_api_version             IN  NUMBER,
                               p_init_msg_list           IN  VARCHAR2,
                               p_transaction_control     IN  VARCHAR2,
                               p_asset_adj_tbl           IN  asset_adjustment_tbl_type,
                               x_return_status           OUT NOCOPY VARCHAR2,
                               x_msg_count               OUT NOCOPY NUMBER,
                               x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE update_adjustment (p_api_version             IN  NUMBER,
                               p_init_msg_list           IN  VARCHAR2,
                               p_transaction_control     IN  VARCHAR2,
                               p_asset_adj_tbl           IN  asset_adjustment_tbl_type,
                               x_return_status           OUT NOCOPY VARCHAR2,
                               x_msg_count               OUT NOCOPY NUMBER,
                               x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE delete_adjustment (p_api_version             IN  NUMBER,
                               p_init_msg_list           IN  VARCHAR2,
                               p_transaction_control     IN  VARCHAR2,
                               p_adjustment_type         IN  VARCHAR2,
                               p_adjustment_id           IN  NUMBER,
                               p_quote_id                IN  NUMBER,
                               x_return_status           OUT NOCOPY VARCHAR2,
                               x_msg_count               OUT NOCOPY NUMBER,
                               x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE create_assets_with_adjustments (p_api_version             IN  NUMBER,
                                            p_init_msg_list           IN  VARCHAR2,
                                            p_transaction_control     IN  VARCHAR2,
                                            p_asset_tbl               IN  asset_tbl_type,
                                            p_component_tbl           IN  asset_component_tbl_type,
                                            p_asset_adj_tbl           IN  asset_adjustment_tbl_type,
                                            x_return_status           OUT NOCOPY VARCHAR2,
                                            x_msg_count               OUT NOCOPY NUMBER,
                                            x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE duplicate_adjustments(p_api_version             IN  NUMBER,
                              	  p_init_msg_list           IN  VARCHAR2,
								  p_source_quote_id		    IN  NUMBER,
								  p_target_quote_id		    IN  NUMBER,
								  x_msg_count               OUT NOCOPY NUMBER,
                              	  x_msg_data                OUT NOCOPY VARCHAR2,
                              	  x_return_status           OUT NOCOPY VARCHAR2);

  FUNCTION validate_subsidy_applicability(p_asset_id  IN  NUMBER,
                                          p_subsidy_id  IN NUMBER)
    RETURN VARCHAR2;

  FUNCTION validate_subsidy_applicability(p_inv_item_id     IN NUMBER,
                                          p_subsidy_id      IN NUMBER,
                                          p_exp_start_date  IN DATE,
                                          p_inv_org_id      IN NUMBER,
                                          p_currency_code   IN VARCHAR2,
                                          p_authoring_org_id  IN NUMBER,
                                          p_cust_acct_id    IN NUMBER,
                                          p_product_id      IN NUMBER,
                                          p_sales_rep_id    IN NUMBER)
  RETURN VARCHAR2;

  --Fixing Bug # 4735811 ssdeshpa Start
  PROCEDURE process_link_assets(p_api_version            IN  NUMBER,
                                 p_init_msg_list           IN  VARCHAR2,
                                 p_transaction_control     IN  VARCHAR2,
                                 p_asset_adj_tbl           IN  asset_adjustment_tbl_type,
                                 x_asset_adj_tbl           OUT NOCOPY  asset_adjustment_tbl_type,
                                 x_return_status           OUT NOCOPY VARCHAR2,
                                 x_msg_count               OUT NOCOPY NUMBER,
                                 x_msg_data                OUT NOCOPY VARCHAR2);
 --Fixing Bug # 4735811 End

  FUNCTION validate_subsidy(p_quote_id  IN  NUMBER,
                            p_subsidy_id  IN NUMBER)  RETURN VARCHAR2;
--veramach added for bug 6622178
  PROCEDURE calculate_subsidy_amount(p_api_version         IN NUMBER,
                                     p_init_msg_list        IN VARCHAR2,
                                     x_return_status        OUT NOCOPY VARCHAR2,
                                     x_msg_count            OUT NOCOPY NUMBER,
                                     x_msg_data             OUT NOCOPY VARCHAR2,
                                     p_asset_id             IN  NUMBER,
                                     p_subsidy_id           IN  NUMBER,
                                     x_subsidy_amount      OUT NOCOPY NUMBER) ;
--veramach bug 6622178 end

END OKL_LEASE_QUOTE_ASSET_PVT;

/
