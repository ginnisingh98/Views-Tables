--------------------------------------------------------
--  DDL for Package OKL_CS_CREATE_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CS_CREATE_QUOTE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCTQS.pls 115.3 2003/01/02 19:13:41 rvaduri noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_APP_NAME                    CONSTANT VARCHAR2(3)   := 'OKL';
  G_PKG_NAME                    CONSTANT VARCHAR2(30)  := 'OKL_CS_CREATE_QUOTE_PUB';
  G_API_NAME                    CONSTANT VARCHAR2(30)  := 'OKL_CS_CREATE_QUOTE';
  G_API_VERSION                 CONSTANT NUMBER        := 1;
  G_COMMIT                      CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_INIT_MSG_LIST               CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_VALIDATION_LEVEL            CONSTANT NUMBER        := FND_API.G_VALID_LEVEL_FULL;


  SUBTYPE  quot_tbl_type IS okl_qte_pvt.qtev_tbl_type;
  SUBTYPE  qpyv_tbl_type IS OKL_QUOTE_PARTIES_PUB.qpyv_tbl_type;

  G_EMPTY_QPYV_TBL      qpyv_tbl_type;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  PROCEDURE create_terminate_quote(
    p_api_version                  IN   NUMBER,
    p_init_msg_list                IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT  NOCOPY VARCHAR2,
    x_msg_count                    OUT  NOCOPY NUMBER,
    x_msg_data                     OUT  NOCOPY VARCHAR2,
    p_quot_tbl                     IN   quot_tbl_type,
    p_assn_tbl                     IN   OKL_AM_CREATE_QUOTE_PUB.assn_tbl_type,
    p_qpyv_tbl			   IN   qpyv_tbl_type DEFAULT G_EMPTY_QPYV_TBL,
    x_quot_tbl                     OUT  NOCOPY quot_tbl_type,
    x_tqlv_tbl                     OUT  NOCOPY OKL_AM_CREATE_QUOTE_PUB.tqlv_tbl_type,
    x_assn_tbl                     OUT  NOCOPY OKL_AM_CREATE_QUOTE_PUB.assn_tbl_type);

END OKL_CS_CREATE_QUOTE_PUB;

 

/
