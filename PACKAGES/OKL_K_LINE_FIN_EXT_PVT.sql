--------------------------------------------------------
--  DDL for Package OKL_K_LINE_FIN_EXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_K_LINE_FIN_EXT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLFES.pls 120.0.12010000.6 2009/09/25 22:08:47 sechawla noship $ */

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_K_LINE_FIN_EXT_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 --G_REQUEST_ID            NUMBER;


 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------



 -- Variables for Contract Financial Report XML Publisher Report input parameters
--P_REPORT_DATE           DATE; sechawla 25-sep-09 8890513
P_OPERATING_UNIT        OKC_K_HEADERS_ALL_B.AUTHORING_ORG_ID%TYPE;
P_START_DATE_FROM       DATE;
P_START_DATE_TO         DATE;

P_BOOK_CLASS            OKL_K_HEADERS.DEAL_TYPE%TYPE;
P_LEASE_PRODUCT         OKL_PRODUCTS.NAME%TYPE;
P_CONTRACT_NUMBER       OKC_K_HEADERS_ALL_B.CONTRACT_NUMBER%TYPE;
P_CONTRACT_STATUS       OKC_K_HEADERS_ALL_B.sts_code%TYPE; -- check
P_CONTRACT_LINE_STATUS  OKC_K_LINES_B.sts_code%TYPE;
P_CONTRACT_LINE_TYPE    OKC_LINE_STYLES_B.LTY_CODE%TYPE;
P_CUSTOMER_NAME         HZ_PARTIES.party_name%TYPE;
P_CUSTOMER_NUMBER       HZ_PARTIES.PARTY_NUMBER%TYPE;
P_VENDOR_NAME           po_vendors.vendor_name%TYPE;
P_VENDOR_NUMBER         po_vendors.segment1%TYPE;
P_TAX_BOOK              FA_BOOK_CONTROLS.book_type_code%TYPE;
P_FA_INFO_YN            VARCHAR2(5);
P_DELETE_DATA_YN        VARCHAR2(5);
P_REQUEST_ID            NUMBER;


 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------
PROCEDURE pull_extract_data_conc (
                           errbuf                     OUT NOCOPY VARCHAR2,
                             retcode                    OUT NOCOPY NUMBER,
                             P_OPERATING_UNIT           IN NUMBER,
                             --P_REPORT_DATE              IN VARCHAR2, sechawla 25-sep-09 8890513
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
                             P_NUM_PROCESSES            IN NUMBER,
                             P_ASSIGNED_PROCESS      IN VARCHAR2
                );

PROCEDURE pull_extract_data (
                             p_api_version			IN  NUMBER
        	             ,p_init_msg_list		IN  VARCHAR2	DEFAULT Okc_Api.G_FALSE
		            ,x_return_status		OUT NOCOPY VARCHAR2
	                    ,x_msg_count			OUT NOCOPY NUMBER
		            ,x_msg_data				OUT NOCOPY VARCHAR2,
		             x_row_count            OUT NOCOPY VARCHAR2,
		             P_OPERATING_UNIT           IN NUMBER,
                             --P_REPORT_DATE              IN VARCHAR2, sechawla 25-sep-09 8890513

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
                             P_NUM_PROCESSES            IN NUMBER,
                             P_ASSIGNED_PROCESS      IN VARCHAR2
                             );


FUNCTION delete_report_data  return BOOLEAN;


FUNCTION Contract_Active_YN  (p_chr_id IN OKL_K_HEADERS.ID%TYPE,
                            p_deal_type  IN OKL_K_HEADERS.DEAL_TYPE%TYPE,
                            p_sts_code   IN okc_k_headers_all_b.STS_CODE%TYPE)
 return VARCHAR2;


END OKL_K_LINE_FIN_EXT_PVT;

/
