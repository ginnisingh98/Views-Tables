--------------------------------------------------------
--  DDL for Package OKL_K_RATE_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_K_RATE_PARAMS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRKRPS.pls 120.5.12010000.2 2008/09/30 06:06:06 rpillay ship $ */
  TYPE krpdel_rec_type IS RECORD (
     khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,rate_type                      VARCHAR2(30) := OKC_API.G_MISS_CHAR
    ,effective_from_date            OKL_K_RATE_PARAMS_V.EFFECTIVE_FROM_DATE%TYPE := OKC_API.G_MISS_DATE
  );

  TYPE krpdel_tbl_type IS TABLE OF krpdel_rec_type INDEX BY BINARY_INTEGER;

  TYPE krpr_rec_type IS RECORD (
     khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,parameter_type_code            OKL_K_RATE_PARAMS_V.PARAMETER_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,effective_from_date            OKL_K_RATE_PARAMS_V.EFFECTIVE_FROM_DATE%TYPE := OKC_API.G_MISS_DATE
    ,effective_to_date              OKL_K_RATE_PARAMS_V.EFFECTIVE_TO_DATE%TYPE := OKC_API.G_MISS_DATE
    ,interest_index_id              NUMBER := OKC_API.G_MISS_NUM
    ,base_rate                      NUMBER := OKC_API.G_MISS_NUM
    ,interest_start_date            OKL_K_RATE_PARAMS_V.INTEREST_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,adder_rate                     NUMBER := OKC_API.G_MISS_NUM
    ,maximum_rate                   NUMBER := OKC_API.G_MISS_NUM
    ,minimum_rate                   NUMBER := OKC_API.G_MISS_NUM
    ,principal_basis_code           OKL_K_RATE_PARAMS_V.PRINCIPAL_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,days_in_a_month_code           OKL_K_RATE_PARAMS_V.DAYS_IN_A_MONTH_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,days_in_a_year_code            OKL_K_RATE_PARAMS_V.DAYS_IN_A_YEAR_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,interest_basis_code            OKL_K_RATE_PARAMS_V.INTEREST_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
  );

  TYPE krpar_rec_type IS RECORD (
     khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,parameter_type_code            OKL_K_RATE_PARAMS_V.PARAMETER_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,effective_from_date            OKL_K_RATE_PARAMS_V.EFFECTIVE_FROM_DATE%TYPE := OKC_API.G_MISS_DATE
    ,effective_to_date              OKL_K_RATE_PARAMS_V.EFFECTIVE_TO_DATE%TYPE := OKC_API.G_MISS_DATE
    ,rate_delay_code                OKL_K_RATE_PARAMS_V.RATE_DELAY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_delay_frequency           NUMBER := OKC_API.G_MISS_NUM
    ,compounding_frequency_code     OKL_K_RATE_PARAMS_V.COMPOUNDING_FREQUENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,calculation_formula_id         NUMBER := OKC_API.G_MISS_NUM
    ,catchup_basis_code             OKL_K_RATE_PARAMS_V.CATCHUP_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,catchup_start_date             OKL_K_RATE_PARAMS_V.CATCHUP_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,catchup_settlement_code        OKL_K_RATE_PARAMS_V.CATCHUP_SETTLEMENT_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_change_start_date         OKL_K_RATE_PARAMS_V.RATE_CHANGE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,rate_change_frequency_code     OKL_K_RATE_PARAMS_V.RATE_CHANGE_FREQUENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_change_value              NUMBER := OKC_API.G_MISS_NUM
  );

  TYPE krpc_rec_type IS RECORD (
     khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,parameter_type_code            OKL_K_RATE_PARAMS_V.PARAMETER_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,effective_from_date            OKL_K_RATE_PARAMS_V.EFFECTIVE_FROM_DATE%TYPE := OKC_API.G_MISS_DATE
    ,effective_to_date              OKL_K_RATE_PARAMS_V.EFFECTIVE_TO_DATE%TYPE := OKC_API.G_MISS_DATE
    ,conversion_option_code         OKL_K_RATE_PARAMS_V.CONVERSION_OPTION_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,next_conversion_date           OKL_K_RATE_PARAMS_V.NEXT_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,conversion_type_code           OKL_K_RATE_PARAMS_V.CONVERSION_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
  );

  TYPE var_prm_rec_type is RECORD (
            param_identifier FND_LOOKUPS.LOOKUP_CODE%TYPE,
            param_identifier_meaning FND_LOOKUPS.MEANING%TYPE,
            parameter_type_code OKL_K_RATE_PARAMS.PARAMETER_TYPE_CODE%TYPE,
            interest_index_id   OKL_K_RATE_PARAMS.INTEREST_INDEX_ID%TYPE,
            effective_from_date OKL_K_RATE_PARAMS.EFFECTIVE_FROM_DATE%TYPE,
            effective_to_date   OKL_K_RATE_PARAMS.EFFECTIVE_TO_DATE%TYPE
                                  );

  TYPE var_prm_tbl_type IS TABLE OF var_prm_rec_type INDEX BY BINARY_INTEGER;

  subtype krp_rec_type is OKL_KRP_PVT.krp_rec_type;
  subtype krpv_rec_type is OKL_KRP_PVT.krpv_rec_type;
  subtype krp_tbl_type is OKL_KRP_PVT.krp_tbl_type;
  subtype krpv_tbl_type is OKL_KRP_PVT.krpv_tbl_type;

  -- GLOBAL VARIABLES

  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_K_RATE_PARAMS_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;

procedure get_product(
    p_api_version            IN NUMBER,
    p_init_msg_list          IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_khr_id                 IN  okc_k_headers_b.id%type,
    x_pdt_parameter_rec      OUT NOCOPY OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type);

  /* This is to be called from contract import */
  PROCEDURE create_k_rate_params(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_rec                     IN  krpv_rec_type,
    x_krpv_rec                     OUT NOCOPY krpv_rec_type,
    p_validate_flag                IN  VARCHAR2 DEFAULT 'Y');

  PROCEDURE create_k_rate_params(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpr_rec                     IN  krpr_rec_type,
    x_krpr_rec                     OUT NOCOPY krpr_rec_type);

  PROCEDURE create_k_rate_params(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpar_rec                    IN  krpar_rec_type,
    x_krpar_rec                    OUT NOCOPY krpar_rec_type);

  PROCEDURE create_k_rate_params(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpc_rec                     IN  krpc_rec_type,
    x_krpc_rec                     OUT NOCOPY krpc_rec_type);

  /* For both UI and contract import */
  PROCEDURE update_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_krpv_rec                IN krpv_rec_type,
    x_krpv_rec                OUT NOCOPY krpv_rec_type);

  PROCEDURE update_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_krpr_rec                IN krpr_rec_type,
    x_krpr_rec                OUT NOCOPY krpr_rec_type);

  PROCEDURE update_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_krpar_rec               IN krpar_rec_type,
    x_krpar_rec               OUT NOCOPY krpar_rec_type);

  PROCEDURE update_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_krpc_rec                IN krpc_rec_type,
    x_krpc_rec                OUT NOCOPY krpc_rec_type);

  PROCEDURE delete_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_krpdel_tbl              IN krpdel_tbl_type);

  /* For QA checker to call  - stack Error messages and no raise exception*/
  PROCEDURE validate_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_khr_id                  IN  okc_k_headers_b.id%type,
    --Bug# 7440232
    p_validate_flag           IN  VARCHAR2 DEFAULT 'Y');

  /* For contract import to call */
  PROCEDURE validate_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_product_id              IN  okl_products_v.id%type,
    p_k_rate_tbl              IN  krpv_tbl_type,
    p_validate_flag           IN  VARCHAR2 DEFAULT 'Y');

  Procedure generate_rate_summary(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_chr_id               IN  NUMBER,
            x_var_par_tbl          OUT NOCOPY var_prm_tbl_type);

  PROCEDURE default_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_deal_type               IN  okl_product_parameters_v.deal_type%type,
    p_rev_rec_method          IN  okl_product_parameters_v.revenue_recognition_method%type,
    p_int_calc_basis          IN  okl_product_parameters_v.interest_calculation_basis%type,
    p_column_name             IN  VARCHAR2,
    p_krpv_rec                IN OUT NOCOPY krpv_rec_type);

  PROCEDURE cascade_contract_start_date(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_chr_id                  IN OKC_K_HEADERS_B.ID%TYPE,
    p_new_start_date          IN DATE);

PROCEDURE get_rate_rec(p_chr_id IN NUMBER,
                       p_parameter_type_code IN VARCHAR2,
                       p_effective_from_date IN DATE,
                       x_krpv_rec OUT NOCOPY krpv_rec_type,
                       x_no_data_found OUT NOCOPY BOOLEAN
                      );

  -- smadhava Bug#4542290 - 22-Aug-2005 - Added - Start
  PROCEDURE check_rebook_allowed (
    p_api_version             IN         NUMBER,
    p_init_msg_list           IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_chr_id                  IN         OKC_K_HEADERS_B.ID%TYPE,
    p_rebook_date             IN         DATE);
  -- smadhava Bug#4542290 - 22-Aug-2005 - Added - End

  PROCEDURE SYNC_RATE_PARAMS(
                     p_orig_contract_id  IN NUMBER,
                     p_new_contract_id   IN NUMBER);

  PROCEDURE check_base_rate(
                             p_khr_id            IN NUMBER,
                             x_base_rate_defined OUT NOCOPY BOOLEAN,
                             x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE check_principal_payment(
            p_api_version             IN NUMBER,
            p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_chr_id                  IN OKC_K_HEADERS_B.ID%TYPE,
            x_principal_payment_defined OUT NOCOPY BOOLEAN);

  FUNCTION get_formula_id(p_name IN VARCHAR2) RETURN NUMBER ;

  PROCEDURE copy_k_rate_params(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khr_id                       IN  NUMBER,
    p_effective_from_date          IN  DATE,
    p_rate_type                    IN  VARCHAR2,
    x_krpv_rec                     OUT NOCOPY krpv_rec_type);

-- Bug 4917614
  PROCEDURE SYNC_BASE_RATE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khr_id                       IN NUMBER);

END OKL_K_RATE_PARAMS_PVT;

/
