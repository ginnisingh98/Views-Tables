--------------------------------------------------------
--  DDL for Package OKL_AM_RECYCLE_TRMNT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_RECYCLE_TRMNT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRTXS.pls 115.1 2002/02/06 20:29:17 pkm ship       $ */
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_RECYCLE_TRMNT_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

  SUBTYPE recy_rec_type IS OKL_AM_RECYCLE_TRMNT_PVT.recy_rec_type;
  SUBTYPE recy_tbl_type IS OKL_AM_RECYCLE_TRMNT_PVT.recy_tbl_type;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------
  PROCEDURE recycle_termination(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_recy_rec					   	IN  recy_rec_type,
    x_recy_rec					   	OUT NOCOPY recy_rec_type);

  PROCEDURE recycle_termination(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_recy_tbl					   	IN  recy_tbl_type,
    x_recy_tbl					   	OUT NOCOPY recy_tbl_type);

END OKL_AM_RECYCLE_TRMNT_PUB;

 

/
