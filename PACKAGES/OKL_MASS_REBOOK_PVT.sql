--------------------------------------------------------
--  DDL for Package OKL_MASS_REBOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MASS_REBOOK_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRMRPS.pls 120.6 2007/09/25 04:34:58 rpillay ship $*/

  G_UNEXPECTED_ERROR         CONSTANT VARCHAR2(1000) := 'OKL_UNEXPECTED_ERROR';
  G_NOT_VALID_REQUEST        CONSTANT VARCHAR2(1000) := 'OKL_LLA_NOT_VALID_RERQUEST';
  G_INVALID_CRITERIA         CONSTANT VARCHAR2(1000) := 'OKL_LLA_INVALID_CRITERIA';
  G_FORMAT_ERROR             CONSTANT VARCHAR2(1000) := 'OKL_LLA_FORMAT_ERROR';
  G_NO_MATCH_FOUND           CONSTANT VARCHAR2(1000) := 'OKL_LLA_NO_MATCH_FOUND';
  G_INVALID_CODE             CONSTANT VARCHAR2(1000) := 'OKL_LLA_INVALID_CODE';
  G_DUPLICATE_REQUEST        CONSTANT VARCHAR2(1000) := 'OKL_LLA_DUPLICATE_REQUEST';
  G_NO_SEL_CONTRACT          CONSTANT VARCHAR2(1000) := 'OKL_LLA_NO_SELECTED_CONTRACT';
  G_INVALID_SET_VALUE        CONSTANT VARCHAR2(1000) := 'OKL_LLA_INVALID_SET_VALUE';
  G_NO_SET_VALUE             CONSTANT VARCHAR2(1000) := 'OKL_LLA_NO_SET_VALUE';
  G_INVALID_OPERAND          CONSTANT VARCHAR2(1000) := 'OKL_LLA_INVALID_OPERAND';
  G_INVALID_MATCH_OPTION     CONSTANT VARCHAR2(1000) := 'OKL_LLA_INVALID_MATCH_OPTION';


  SUBTYPE mrbv_rec_type IS okl_mrb_pvt.mrbv_rec_type;
  SUBTYPE mrbv_tbl_type IS okl_mrb_pvt.mrbv_tbl_type;

  SUBTYPE mstv_rec_type IS okl_mst_pvt.mstv_rec_type;
  SUBTYPE mstv_tbl_type IS okl_mst_pvt.mstv_tbl_type;

  subtype tcnv_rec_type IS OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;

  subtype thpv_rec_type IS OKL_TRX_ASSETS_PUB.thpv_rec_type;
  subtype thpv_tbl_type IS OKL_TRX_ASSETS_PUB.thpv_tbl_type;

  subtype tlpv_rec_type IS OKL_TXL_ASSETS_PUB.tlpv_rec_type;
  subtype tlpv_tbl_type IS OKL_TXL_ASSETS_PUB.tlpv_tbl_type;

  subtype adpv_rec_type IS OKL_TXD_ASSETS_PUB.adpv_rec_type;
  subtype adpv_tbl_type IS OKL_TXD_ASSETS_PUB.adpv_tbl_type;

  subtype khrv_rec_type IS OKL_CONTRACT_PUB.khrv_rec_type;
  subtype chrv_rec_type IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;

  subtype klev_rec_type IS OKL_CONTRACT_PUB.klev_rec_type;
  subtype clev_rec_type IS OKL_OKC_MIGRATION_PVT.clev_rec_type;

  subtype klev_tbl_type IS OKL_CONTRACT_PUB.klev_tbl_type;
  subtype clev_tbl_type IS OKL_OKC_MIGRATION_PVT.clev_tbl_type;

  subtype cvmv_rec_type IS OKL_VERSION_PUB.cvmv_rec_type;

  --
  -- Order of Criteria Code in Table is important
  -- It should be as follows, if present
  --
  -- CONTRACT_NUMBER, START_DATE, BOOK_TYPE_CODE, DEPRN_METHOD_CODE, DATE_PLACED_IN_SERVICE, ASSET_CATEGORY_ID
  --
  TYPE crit_rec_type IS RECORD (
    LINE_NUMBER            NUMBER,
    CRITERIA_CODE          VARCHAR2(30),
    OPERAND                VARCHAR2(150),
    CRITERIA_VALUE1        VARCHAR2(150),
    CRITERIA_VALUE2        VARCHAR2(150),
    SET_VALUE              VARCHAR2(150)
  );

  TYPE crit_tbl_type IS TABLE OF crit_rec_type INDEX BY BINARY_INTEGER;

  TYPE rbk_rec_type IS RECORD (
    KHR_ID          NUMBER := OKL_API.G_MISS_NUM,
    CONTRACT_NUMBER OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE,
    KLE_ID          OKL_K_LINES_V.ID%TYPE,
    DESCRIPTION     OKC_K_HEADERS_V.SHORT_DESCRIPTION%TYPE
  );

  TYPE rbk_tbl_type IS TABLE OF rbk_rec_type INDEX BY BINARY_INTEGER;

  TYPE strm_lalevl_rec_type IS RECORD
  (
     Chr_Id                     NUMBER,
     Cle_Id                     NUMBER,
     Rule_Information1          VARCHAR2 (450),
     Rule_Information2          VARCHAR2 (450),
     Rule_Information3          VARCHAR2 (450),
     Rule_Information4          VARCHAR2 (450),
     Rule_Information5          VARCHAR2 (450),
     Rule_Information6          VARCHAR2 (450),
     Rule_Information7          VARCHAR2 (450),
     Rule_Information8          VARCHAR2 (450),
     Rule_Information9          VARCHAR2 (450),
     Rule_Information10         VARCHAR2 (450),
     Rule_Information11         VARCHAR2 (450),
     Rule_Information12         VARCHAR2 (450),
     Rule_Information13         VARCHAR2 (450),
     Rule_Information14         VARCHAR2 (450),
     Rule_Information15         VARCHAR2 (450),
     Rule_Information_Category  VARCHAR2 (90),
     Object1_Id1                VARCHAR2 (40),
     Object1_Id2                VARCHAR2 (200),
     Object2_Id1                VARCHAR2 (40),
     Object2_Id2                VARCHAR2 (200),
     Object3_Id1                VARCHAR2 (40),
     Object3_Id2                VARCHAR2 (200),
     Jtot_Object1_Code          VARCHAR2 (30),
     Jtot_Object2_Code          VARCHAR2 (30),
     Jtot_Object3_Code          VARCHAR2 (30)
  );

  TYPE strm_lalevl_tbl_type IS TABLE OF strm_lalevl_rec_type INDEX BY BINARY_INTEGER;

  TYPE strm_trx_rec_type IS RECORD (
    CHR_ID     OKC_K_HEADERS_V.ID%TYPE,
    TRX_NUMBER NUMBER
  );

  TYPE strm_trx_tbl_type IS TABLE OF strm_trx_rec_type INDEX BY BINARY_INTEGER;

  TYPE kle_rec_type IS RECORD (
    ID          OKL_K_LINES_V.ID%TYPE
  );

  TYPE kle_tbl_type IS TABLE OF kle_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE build_and_get_contracts(
                                    p_api_version        IN  NUMBER,
                                    p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2,
                                    p_request_name       IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE,
                                    p_mrbv_tbl           IN  mrbv_tbl_type,
                                    x_mstv_tbl           OUT NOCOPY mstv_tbl_type,
                                    x_rbk_count          OUT NOCOPY NUMBER
                                   );

  PROCEDURE build_and_get_contracts(
                                    p_api_version        IN  NUMBER,
                                    p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2,
                                    p_request_name       IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE,
                                    p_transaction_date   IN  OKL_RBK_SELECTED_CONTRACT.TRANSACTION_DATE%TYPE,
                                    p_mrbv_tbl           IN  mrbv_tbl_type,
                                    x_mstv_tbl           OUT NOCOPY mstv_tbl_type,
                                    x_rbk_count          OUT NOCOPY NUMBER
                                   );

  PROCEDURE process_mass_rebook(
                                p_api_version        IN  NUMBER,
                                p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2,
                                p_request_name       IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE
                               );
  PROCEDURE apply_mass_rebook(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rbk_tbl            IN  rbk_tbl_type,
                              p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                              p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                              p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                              p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                              p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                              p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                              p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type
                             );

  PROCEDURE apply_mass_rebook(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rbk_tbl            IN  rbk_tbl_type,
                              p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                              p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                              p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                              p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                              p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                              p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                              p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type,
                              x_stream_trx_tbl     OUT NOCOPY strm_trx_tbl_type
                             );

  PROCEDURE apply_mass_rebook(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rbk_tbl            IN  rbk_tbl_type,
                              p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                              p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                              p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                              p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                              p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                              p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                              p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type,
                              p_transaction_date   IN  OKL_RBK_SELECTED_CONTRACT.TRANSACTION_DATE%TYPE,
                              x_stream_trx_tbl     OUT NOCOPY strm_trx_tbl_type
                             );

  PROCEDURE apply_mass_rebook(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rbk_tbl            IN  rbk_tbl_type,
                              p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                              p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                              p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                              p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                              p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                              p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                              p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type,
                              p_source_trx_id      IN  OKL_TRX_CONTRACTS.SOURCE_TRX_ID%TYPE,
                              p_source_trx_type    IN  OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE,
                              x_mass_rebook_trx_id OUT NOCOPY OKL_TRX_CONTRACTS.ID%TYPE
                             );

  PROCEDURE apply_mass_rebook(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rbk_tbl            IN  rbk_tbl_type,
                              p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                              p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                              p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                              p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                              p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                              p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                              p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type,
                              p_source_trx_id      IN  OKL_TRX_CONTRACTS.SOURCE_TRX_ID%TYPE,
                              p_source_trx_type    IN  OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE,
                              p_transaction_date   IN  OKL_RBK_SELECTED_CONTRACT.TRANSACTION_DATE%TYPE,
                              x_mass_rebook_trx_id OUT NOCOPY OKL_TRX_CONTRACTS.ID%TYPE
                             );

  PROCEDURE apply_mass_rebook(
     p_api_version        IN  NUMBER,
     p_init_msg_list      IN  VARCHAR2,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2,
     p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
     p_kle_tbl            IN  kle_tbl_type,
     p_source_trx_id      IN  OKL_TRX_CONTRACTS.SOURCE_TRX_ID%TYPE,
     p_source_trx_type    IN  OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE,
     p_transaction_date   IN  OKL_TRX_CONTRACTS.DATE_TRANSACTION_OCCURRED%TYPE,
     x_mass_rebook_trx_id OUT NOCOPY OKL_TRX_CONTRACTS.ID%TYPE,
     p_ppd_amount   IN  NUMBER,
     p_ppd_reason_code   IN  FND_LOOKUPS.LOOKUP_CODE%TYPE,
     p_payment_struc   IN  okl_mass_rebook_pvt.strm_lalevl_tbl_type
  );

  PROCEDURE update_mass_rbk_contract(
                                     p_api_version                  IN  NUMBER,
                                     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                     x_return_status                OUT NOCOPY VARCHAR2,
                                     x_msg_count                    OUT NOCOPY NUMBER,
                                     x_msg_data                     OUT NOCOPY VARCHAR2,
                                     p_mstv_tbl                     IN  MSTV_TBL_TYPE,
                                     x_mstv_tbl                     OUT NOCOPY MSTV_TBL_TYPE
                                    );

  PROCEDURE mass_rebook_after_yield(
                                    p_api_version        IN  NUMBER,
                                    p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2,
                                    p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE
                                   );
  /* Added for CR-Bug # 6112560 CR for Mass Rebook Page Flows*/
  PROCEDURE create_mass_rbk_set_values(
                                     p_api_version      IN  NUMBER,
                                     p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2,
                                     p_request_name     IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE,
                                     p_mrbv_tbl         IN  mrbv_tbl_type,
                                     x_mrbv_tbl         OUT NOCOPY mrbv_tbl_type);

  -- Bug# 5038395
  PROCEDURE mass_rebook_activate(
                                    p_api_version        IN  NUMBER,
                                    p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2,
                                    p_chr_id             IN  NUMBER
                                   );

END OKL_MASS_REBOOK_PVT;

/
