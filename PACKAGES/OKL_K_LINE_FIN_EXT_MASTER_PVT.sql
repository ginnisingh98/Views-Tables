--------------------------------------------------------
--  DDL for Package OKL_K_LINE_FIN_EXT_MASTER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_K_LINE_FIN_EXT_MASTER_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLEMS.pls 120.0.12010000.7 2009/09/25 22:06:09 sechawla noship $ */

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_K_LINE_FIN_EXT_MASTER_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_API_TYPE             CONSTANT VARCHAR2(4)   := '_PVT';
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 --G_REQUEST_ID            NUMBER;

 -- Variables for Contract Line Financial Report XML Publisher Report input parameters



 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


  ---------------------------------------------------------------------------
  -- GLOBAL DEBUG VARIABLES
  ---------------------------------------------------------------------------
  G_DEBUG_LEVEL_PROCEDURE     		CONSTANT	NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  G_DEBUG_CURRENT_RUNTIME_LEVEL		CONSTANT 	NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_DEBUG_LEVEL_STATEMENT		CONSTANT	NUMBER  := FND_LOG.LEVEL_STATEMENT;
  G_DEBUG_LEVEL_EXCEPTION		CONSTANT	NUMBER  := FND_LOG.LEVEL_EXCEPTION;
  ---------------------------------------------------------------------------



  G_NO_DATA_FOUND 		CONSTANT VARCHAR2(200) := 'NO_DATA_FOUND';
  G_TOO_MANY_ROWS 		CONSTANT VARCHAR2(200) := 'TOO_MANY_ROWS';
  G_OTHERS        		CONSTANT VARCHAR2(200) := 'OTHERS';


  PROCEDURE Process_Spawner (
    						 errbuf                     OUT NOCOPY VARCHAR2,
                             retcode                    OUT NOCOPY NUMBER,
                             P_OPERATING_UNIT           IN NUMBER,
                             --P_REPORT_DATE              IN VARCHAR2, sechawla 25-sep-09 8890513
                             P_DATA_SOURCE_CODE         IN VARCHAR2,
                             P_REPORT_TEMPLATE_NAME     IN VARCHAR2,
                             --P_TEMPLATE_CODE			IN VARCHAR2, --sechawla 7628766
                             P_REPORT_LANGUAGE			IN VARCHAR2,
                             P_REPORT_FORMAT			IN VARCHAR2,
                             P_START_DATE_FROM          IN VARCHAR2,
                             P_START_DATE_TO            IN VARCHAR2,
                             P_BOOK_CLASS               IN VARCHAR2,
                             P_LEASE_PRODUCT            IN VARCHAR2,
                             P_CONTRACT_NUMBER          IN VARCHAR2,
                             P_CONTRACT_STATUS          IN VARCHAR2,
                             P_CONTRACT_LINE_STATUS     IN VARCHAR2,
                             P_CONTRACT_LINE_TYPE       IN VARCHAR2,
                             P_CUSTOMER_NAME            IN VARCHAR2,
                             P_CUSTOMER_NUMBER          IN VARCHAR2,
                             P_VENDOR_NAME              IN VARCHAR2,
                             P_VENDOR_NUMBER            IN VARCHAR2,
                             P_FA_INFO_YN               IN VARCHAR2,
                             P_TAX_BOOK                 IN VARCHAR2,
                             P_DELETE_DATA_YN           IN VARCHAR2,
                             P_NUM_PROCESSES            IN NUMBER

                             );


END OKL_K_LINE_FIN_EXT_MASTER_PVT;

/
