--------------------------------------------------------
--  DDL for Package OKL_LA_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_ASSET_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRLAAS.pls 120.4 2007/05/24 11:44:42 gboomina ship $ */
-------------------------------------------------------------------------------------------------
-- COMPOSITE VARIABLES
-------------------------------------------------------------------------------------------------
  TYPE las_rec_type IS RECORD (asset_number          FA_ADDITIONS_B.ASSET_NUMBER%TYPE,
                               year_manufactured     NUMBER := OKL_API.G_MISS_NUM,
                               manufacturer_name     FA_ADDITIONS_B.MANUFACTURER_NAME%TYPE,
                               description           FA_ADDITIONS_TL.DESCRIPTION%TYPE,
                               current_units         NUMBER := OKL_API.G_MISS_NUM,
                               from_oec              NUMBER := OKL_API.G_MISS_NUM,
                               to_oec                NUMBER := OKL_API.G_MISS_NUM,
                               vendor_name           PO_VENDORS.VENDOR_NAME%TYPE,
                               from_residual_value   NUMBER := OKL_API.G_MISS_NUM,
                               to_residual_value     NUMBER := OKL_API.G_MISS_NUM,
                               from_start_date       OKC_K_LINES_B.START_DATE%TYPE,
                               from_end_date         OKC_K_LINES_B.END_DATE%TYPE,
                               from_date_terminated  OKC_K_LINES_B.DATE_TERMINATED%TYPE,
                               to_start_date         OKC_K_LINES_B.START_DATE%TYPE,
                               to_end_date           OKC_K_LINES_B.END_DATE%TYPE,
                               to_date_terminated    OKC_K_LINES_B.DATE_TERMINATED%TYPE,
                               sts_code              OKC_K_LINES_B.STS_CODE%TYPE,
                               location_id           VARCHAR(1995),
                               parent_line_id        NUMBER := OKL_API.G_MISS_NUM,
                               dnz_chr_id            NUMBER := OKL_API.G_MISS_NUM,
                               p_order_by            VARCHAR2(10) := 'AST',
                               p_sort_by             VARCHAR2(10) := 'DESC',
                               include_split_yn      VARCHAR2(1) := 'N');

-----------------------------------------------------------------------------------------------------
-- Financial Adjustment Record
-----------------------------------------------------------------------------------------------------
 TYPE fin_adj_rec_type IS RECORD(p_top_line_id                    NUMBER,
                                 p_asset_number                   VARCHAR2(50),
				 p_new_yn                         VARCHAR2(10),
                                 p_dnz_chr_id                     NUMBER,
                                 p_capital_reduction              NUMBER,
                                 p_capital_reduction_percent      NUMBER,
                                 p_oec                            NUMBER,
                                 p_cap_down_pay_yn                VARCHAR2(10),
                                 p_down_payment_receiver          VARCHAR2(10));

------------------------------------------------------------------------------------------------------
-- Financial Adjustment Table
------------------------------------------------------------------------------------------------------
TYPE fin_adj_tbl_type IS TABLE OF fin_adj_rec_type INDEX BY BINARY_INTEGER;

/*
  TYPE las_rec_type IS RECORD (asset_number       FA_ADDITIONS_B.ASSET_NUMBER%TYPE,
                               year_manufactured  NUMBER := OKL_API.G_MISS_NUM,
                               manufacturer_name  FA_ADDITIONS_B.MANUFACTURER_NAME%TYPE,
                               description        FA_ADDITIONS_TL.DESCRIPTION%TYPE,
                               current_units      NUMBER := OKL_API.G_MISS_NUM,
                               oec                NUMBER := OKL_API.G_MISS_NUM,
                               vendor_name        PO_VENDORS.VENDOR_NAME%TYPE,
                               residual_value     NUMBER := OKL_API.G_MISS_NUM,
                               start_date         OKC_K_LINES_B.START_DATE%TYPE,
                               end_date           OKC_K_LINES_B.END_DATE%TYPE,
                               date_terminated    OKC_K_LINES_B.DATE_TERMINATED%TYPE,
                               sts_code           OKC_K_LINES_B.STS_CODE%TYPE,
                               location_id        VARCHAR(1995),
                               parent_line_id     NUMBER := OKL_API.G_MISS_NUM,
                               dnz_chr_id         NUMBER := OKL_API.G_MISS_NUM,
                               p_order_by         VARCHAR2(10) := 'AST',
                               p_sort_by          VARCHAR2(10) := 'DESC');
*/

  TYPE las_tbl_type IS TABLE OF las_rec_type
        INDEX BY BINARY_INTEGER;

  Procedure generate_asset_summary(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_las_rec              IN  las_rec_type,
            x_las_tbl              OUT NOCOPY las_tbl_type);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                           IN  NUMBER,
    p_date_delivery_expected       IN  DATE,
    p_date_funding_expected        IN  DATE,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                           IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    p_manufacturer_name            IN  VARCHAR2,
    p_model_number                 IN  VARCHAR2,
    p_year_of_manufacture          IN  VARCHAR2,
    p_vendor_name                  IN  VARCHAR2,
    p_vendor_id                    IN  VARCHAR2,
    p_cpl_id                       IN  NUMBER,
    p_notes                        IN  VARCHAR2
    );

  PROCEDURE update_fin_cap_cost(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    P_new_yn                       IN  VARCHAR2,
    p_asset_number                 IN  VARCHAR2,
    p_top_line_id                  IN  NUMBER,
    p_dnz_chr_id                   IN  NUMBER,
    p_capital_reduction            IN  NUMBER,
    p_capital_reduction_percent    IN  NUMBER,
    p_oec                          IN  NUMBER,
    p_cap_down_pay_yn              IN  VARCHAR2,
    p_down_payment_receiver        IN  VARCHAR2);

  PROCEDURE update_fin_cap_cost(
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    p_fin_adj_tbl		    IN  fin_adj_tbl_type);

  -- gboomina added - Start
  -- making isContractActive function public which is called from okl_deal_asset_pvt
  FUNCTION isContractActive(p_dnz_chr_id IN OKL_K_HEADERS_FULL_V.ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                            p_deal_type  IN OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE,
                            p_sts_code   IN OKL_K_HEADERS_FULL_V.STS_CODE%TYPE)
  RETURN BOOLEAN;
  -- gboomina added - End

End OKL_LA_ASSET_PVT;

/
