--------------------------------------------------------
--  DDL for Package OKL_VP_STS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_STS_PUB" AUTHID CURRENT_USER AS
/*$Header: OKLPSSCS.pls 115.5 2002/12/18 12:39:48 kjinger noship $*/


TYPE sts_rec_type IS RECORD (
        status               OKC_STATUSES_V.MEANING%TYPE,
        status_code          OKC_STATUSES_V.CODE%TYPE);

TYPE vp_sts_tbl_type IS TABLE OF sts_rec_type
  	INDEX BY BINARY_INTEGER;

SUBTYPE sts_tbl_type IS OKL_VP_STS_PVT.vp_sts_tbl_type;


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------

  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLCODE';


  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_VP_STS_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

PROCEDURE get_listof_new_statuses(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ste_code                     IN  VARCHAR2,
    p_sts_code                     IN  VARCHAR2,
    p_start_date                   IN  DATE,
    p_end_date                     IN  DATE,
    x_sts_tbl                      OUT NOCOPY sts_tbl_type);


PROCEDURE change_agreement_status(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_current_sts_code             IN VARCHAR2,
    p_new_sts_code                 IN VARCHAR2);




END OKL_VP_STS_PUB;

 

/
