--------------------------------------------------------
--  DDL for Package OKL_SEC_INVESTOR_REVENUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SEC_INVESTOR_REVENUE_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKLRSZRS.pls 120.2 2005/10/30 04:38:37 appldev noship $ */

TYPE szr_rec_type IS RECORD (
     id                                 NUMBER := OKC_API.G_MISS_NUM
    ,top_line_id                        NUMBER := OKC_API.G_MISS_NUM
    -- mvasudev, 10/12/2004, Bug#3909240
    -- ,kle_sty_id                         NUMBER := OKL_API.G_MISS_NUM
    ,kle_sty_subclass                   OKL_K_LINES.STREAM_TYPE_SUBCLASS%TYPE := OKC_API.G_MISS_CHAR
    -- END,mvasudev, 10/12/2004, Bug#3909240
    ,kle_percent_stake                  NUMBER := OKL_API.G_MISS_NUM
    ,dnz_chr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,kle_amount_stake                   NUMBER := OKL_API.G_MISS_NUM
    ,cle_lse_id                         NUMBER := OKC_API.G_MISS_NUM
    ,cle_date_terminated                OKC_K_LINES_V.DATE_TERMINATED%TYPE := OKC_API.G_MISS_DATE
    ,cle_start_date                     OKC_K_LINES_V.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,cle_end_date                       OKC_K_LINES_V.END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,cle_currency_code                  OKC_K_LINES_V.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,cle_sts_code                       OKC_K_LINES_V.STS_CODE%TYPE := OKC_API.G_MISS_CHAR
 );

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------


  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_APP_NAME			CONSTANT   VARCHAR2(3)   := 'OKL';
  G_PKG_NAME			CONSTANT   VARCHAR2(30)  := 'OKL_SEC_INVESTOR_REVENUE_PVT';
  G_API_TYPE                    CONSTANT   VARCHAR2(4)   := '_PVT';
  G_API_VERSION                 CONSTANT   NUMBER        := 1;
  G_UNEXPECTED_ERROR            CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN               CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_COMMIT                      CONSTANT   VARCHAR2(1)   := FND_API.G_TRUE;
  G_INIT_MSG_LIST               CONSTANT   VARCHAR2(1)   := FND_API.G_TRUE;
  G_VALIDATION_LEVEL            CONSTANT   NUMBER        := FND_API.G_VALID_LEVEL_FULL;

 -- Global Variables
  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;

  G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
  G_EXCEPTION_ERROR			EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;

  G_AK_REGION_NAME VARCHAR2(25) := 'OKL_LA_INV_REVENUE_SHARE';

  TYPE szr_tbl_type IS TABLE OF szr_rec_type INDEX BY BINARY_INTEGER;

  SUBTYPE clev_rec_type IS OKL_OKC_MIGRATION_PVT.clev_rec_type;
  SUBTYPE klev_rec_type IS OKL_CONTRACT_PUB.klev_rec_type;

  PROCEDURE create_investor_revenue(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_szr_rec                      IN  szr_rec_type,
                            x_szr_rec                      OUT NOCOPY szr_rec_type);

  PROCEDURE update_investor_revenue(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_szr_rec                      IN  szr_rec_type,
                            x_szr_rec                      OUT NOCOPY szr_rec_type);

  PROCEDURE delete_investor_revenue(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_szr_rec                      IN  szr_rec_type);

  PROCEDURE create_investor_revenue(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_szr_tbl                      IN  szr_tbl_type,
                            x_szr_tbl                      OUT NOCOPY szr_tbl_type);

  PROCEDURE update_investor_revenue(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_szr_tbl                      IN  szr_tbl_type,
                            x_szr_tbl                      OUT NOCOPY szr_tbl_type);

  PROCEDURE delete_investor_revenue(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_szr_tbl                      IN  szr_tbl_type);

END Okl_Sec_Investor_Revenue_Pvt;

 

/
