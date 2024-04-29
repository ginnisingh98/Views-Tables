--------------------------------------------------------
--  DDL for Package OKL_STREAMS_RECON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STREAMS_RECON_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSCRS.pls 120.3 2007/01/09 12:36:04 udhenuko noship $ */

  SUBTYPE FILE_TYPE   IS UTL_FILE.FILE_TYPE;
  TYPE    LOG_MSG_TBL IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_APP_NAME		      CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_STREAMS_RECON_PVT';


  G_MISS_NUM				  CONSTANT NUMBER   	:=  OKL_API.G_MISS_NUM;
  G_MISS_CHAR				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_MISS_CHAR;
  G_MISS_DATE				  CONSTANT DATE   	:=  OKL_API.G_MISS_DATE;
  G_TRUE				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_TRUE;
  G_FALSE				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_FALSE;

  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;

  G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
  G_EXCEPTION_ERROR			EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;

  G_LOG_DIR CONSTANT VARCHAR2(30) := 'ECX_UTL_LOG_DIR';

  -- Variables for XML Publisher Report input parameters
  P_CONTRACT_NUMBER okc_k_headers_b.contract_number%TYPE;
  P_END_DATE        VARCHAR2(120);

--------------------------------------------------------------------------------
-- Start of Commnets
-- Suresh Gorantla
-- Procedure Name       : recon_qry
-- Description          : Generates the streams reconciliation report
-- Business Rules       : we need to reconcile the streams amount
--                        We reconcile the Total streams, Billed streams
--                        cancled streams , Unbilled streams and
--                        then get the differences
--                        If the there is value for unbilled streams
--                        Send we show the amount for each deal type and
--                        associated products for the same.
--                        If the there is value for difference streams
--                        Send we show the amount for total billed amount
--                        unbilled amounts, canceled amount and then difference
--                        Difference amout = total_billed_amount - billed streams
--                        - Canceled streams - Unbilled streams.
-- Parameters           : p_contract_number, p_end_date
-- Version              : 1.0
-- History              : SGORANTL  20-jan-2004 - xxxxxxx created
-- End of Commnets
--------------------------------------------------------------------------------
  PROCEDURE recon_qry (p_errbuf          OUT NOCOPY VARCHAR2,
                       p_retcode         OUT NOCOPY NUMBER,
                       p_contract_number IN okc_k_headers_b.contract_number%TYPE DEFAULT NULL,
                       p_end_date        IN VARCHAR2 DEFAULT NULL);

  -------------------------------------------------------------------------------
    -- FUNCTION xml_recon_qry
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : xml_recon_qry
  -- Description     : Function for Billable Streams reconciliation Report Generation
  --                   in XML Publisher
  -- Business Rules  :
  -- Parameters      : p_contract_number, p_end_date
  -- Version         : 1.0
  -- History         : 03-Jan-2007 UDHENUKO created.
  -- End of comments
  -------------------------------------------------------------------------------
 FUNCTION xml_recon_qry RETURN BOOLEAN;
END OKL_STREAMS_RECON_PVT;

/
