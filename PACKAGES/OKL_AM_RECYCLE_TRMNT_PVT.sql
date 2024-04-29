--------------------------------------------------------
--  DDL for Package OKL_AM_RECYCLE_TRMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_RECYCLE_TRMNT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRTXS.pls 115.1 2002/02/06 20:32:49 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP				CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'SQLcode';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AM_RECYCLE_TRMNT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE recy_rec_type IS RECORD (
    p_contract_id              NUMBER         := OKL_API.G_MISS_NUM,
    p_contract_number          VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
    p_contract_status          VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
    p_transaction_id           NUMBER         := OKL_API.G_MISS_NUM,
    p_transaction_status       VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
    p_tmt_recycle_yn           VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
    p_transaction_date         DATE           := OKL_API.G_MISS_DATE);

  TYPE recy_tbl_type IS TABLE OF recy_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------
  PROCEDURE recycle_termination(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_recy_rec					   	IN  recy_rec_type,
    x_recy_rec					   	OUT NOCOPY recy_rec_type);

  PROCEDURE recycle_termination(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_recy_tbl					   	IN  recy_tbl_type,
    x_recy_tbl					   	OUT NOCOPY recy_tbl_type);

END OKL_AM_RECYCLE_TRMNT_PVT;

 

/
