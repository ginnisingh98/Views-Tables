--------------------------------------------------------
--  DDL for Package OKL_PURGE_STRM_INTF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PURGE_STRM_INTF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPSIS.pls 115.2 2002/11/30 08:55:29 spillaip noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- Record type which holds the account generator rule lines.
  G_FND_APP			CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_PURGE_STRM_INTF_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
  G_EXCEPTION_ERROR		 EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;
  SUBTYPE error_message_type IS OKL_ACCOUNTING_UTIL.ERROR_MESSAGE_TYPE;
  SUBTYPE sifv_rec_type IS okl_sif_pvt.sifv_rec_type;
  SUBTYPE sitv_rec_type IS okl_sit_pvt.sitv_rec_type;
  SUBTYPE sfev_rec_type IS okl_sfe_pvt.sfev_rec_type;
  SUBTYPE silv_rec_type IS okl_sil_pvt.silv_rec_type;
  SUBTYPE sxpv_rec_type IS okl_sxp_pvt.sxpv_rec_type;
  SUBTYPE siyv_rec_type IS okl_siy_pvt.siyv_rec_type;
  SUBTYPE sirv_rec_type IS okl_sir_pvt.sirv_rec_type;
  SUBTYPE srsv_rec_type IS okl_srs_pvt.srsv_rec_type;
  SUBTYPE srlv_rec_type IS okl_srl_pvt.okl_sif_ret_levels_v_rec_type;
  SUBTYPE srmv_rec_type IS okl_srm_pvt.srmv_rec_type;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE PURGE_INTERFACE_TABLES(
                                   x_errbuf OUT NOCOPY VARCHAR2
                                  ,x_retcode OUT NOCOPY NUMBER
                                  ,p_end_date IN VARCHAR2);

END OKL_PURGE_STRM_INTF_PVT;

 

/
