--------------------------------------------------------
--  DDL for Package OKL_PRCTIMEOUT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PRCTIMEOUT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPTOS.pls 115.2 2002/06/12 12:26:46 pkm ship        $ */
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_PRCTIMEOUT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
  G_EXCEPTION_ERROR		 EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;

  -- list of request statuses
  G_SIS_HDR_INSERTED       CONSTANT VARCHAR2(20) := 'HDR_INSERTED';
  G_SIS_DATA_ENTERED       CONSTANT VARCHAR2(20) := 'DATA_ENTERED';
  G_SIS_PROCESS_COMPLETE   CONSTANT VARCHAR2(20) := 'PROCESS_COMPLETE';
  G_SIS_PROCESSING_FAILED  CONSTANT VARCHAR2(20) := 'PROCESSING_FAILED';
  G_SIS_PROCESSING_REQUEST CONSTANT VARCHAR2(20) := 'PROCESSING_REQUEST';
  G_SIS_RET_DATA_RECEIVED  CONSTANT VARCHAR2(20) := 'RET_DATA_RECEIVED';
  G_SIS_PROCESS_ABORTED    CONSTANT VARCHAR2(20) := 'PROCESS_ABORTED';
  G_SIS_SERVER_NA          CONSTANT VARCHAR2(20) := 'SERVER_NA';
  G_SIS_TIME_OUT           CONSTANT VARCHAR2(20) := 'TIME_OUT';

  SUBTYPE error_message_type IS OKL_ACCOUNTING_UTIL.ERROR_MESSAGE_TYPE;
  SUBTYPE sifv_rec_type      IS OKL_SIF_PVT.sifv_rec_type;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE REQUEST_TIME_OUT(x_errbuf OUT  NOCOPY VARCHAR2,
                             x_retcode OUT NOCOPY NUMBER);

END OKL_PRCTIMEOUT_PVT;

 

/
