--------------------------------------------------------
--  DDL for Package OKL_MASS_REBOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MASS_REBOOK_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPMRPS.pls 115.5 2003/01/28 22:54:45 dedey noship $*/

  G_UNEXPECTED_ERROR         CONSTANT VARCHAR2(1000) := 'OKL_UNEXPECTED_ERROR';
  G_NOT_VALID_REQUEST        CONSTANT VARCHAR2(1000) := 'OKL_LLA_NOT_VALID_RERQUEST';
  G_INVALID_CRITERIA         CONSTANT VARCHAR2(1000) := 'OKL_LLA_INVALID_CRITERIA';
  G_FORMAT_ERROR             CONSTANT VARCHAR2(1000) := 'OKL_LLA_FORMAT_ERROR';
  G_NO_MATCH_FOUND           CONSTANT VARCHAR2(1000) := 'OKL_LLA_NO_MATCH_FOUND';
  G_INVALID_CODE             CONSTANT VARCHAR2(1000) := 'OKL_LLA_INVALID_CODE';
  G_DUPLICATE_REQUEST        CONSTANT VARCHAR2(1000) := 'OKL_LLA_DUPLICATE_REQUEST';
  G_NO_SEL_CONTRACT          CONSTANT VARCHAR2(1000) := 'OKL_LLA_NO_SELECTED_CONTRACT';


  SUBTYPE mrbv_rec_type IS okl_mass_rebook_pvt.mrbv_rec_type;
  SUBTYPE mrbv_tbl_type IS okl_mass_rebook_pvt.mrbv_tbl_type;

  SUBTYPE mstv_rec_type IS okl_mass_rebook_pvt.mstv_rec_type;
  SUBTYPE mstv_tbl_type IS okl_mass_rebook_pvt.mstv_tbl_type;

  subtype tcnv_rec_type IS okl_mass_rebook_pvt.tcnv_rec_type;

  subtype thpv_rec_type IS okl_mass_rebook_pvt.thpv_rec_type;
  subtype thpv_tbl_type IS okl_mass_rebook_pvt.thpv_tbl_type;

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

  SUBTYPE rbk_rec_type IS OKL_MASS_REBOOK_PVT.rbk_rec_type;
  SUBTYPE rbk_tbl_type IS OKL_MASS_REBOOK_PVT.rbk_tbl_type;

  SUBTYPE strm_lalevl_rec_type IS OKL_MASS_REBOOK_PVT.strm_lalevl_rec_type;
  SUBTYPE strm_lalevl_tbl_type IS OKL_MASS_REBOOK_PVT.strm_lalevl_tbl_type;

  SUBTYPE strm_trx_tbl_type IS OKL_MASS_REBOOK_PVT.strm_trx_tbl_type;

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

END OKL_MASS_REBOOK_PUB;

 

/
