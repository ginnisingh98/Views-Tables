--------------------------------------------------------
--  DDL for Package OKL_CNTRCT_FIN_EXTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CNTRCT_FIN_EXTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCFES.pls 120.2.12010000.6 2009/09/25 22:03:10 sechawla noship $ */

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CNTRCT_FIN_EXTRACT_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 --G_REQUEST_ID            NUMBER;

 -- Variables for Contract Financial Report XML Publisher Report input parameters
--P_REPORT_DATE           DATE; sechawla 25-sep-09 8890513
P_OPERATING_UNIT        OKC_K_HEADERS_ALL_B.AUTHORING_ORG_ID%TYPE;
P_START_DATE_FROM       DATE;
P_START_DATE_TO         DATE;
P_AR_INFO_YN            VARCHAR2(5);

P_BOOK_CLASS            OKL_K_HEADERS.DEAL_TYPE%TYPE;
P_LEASE_PRODUCT         OKL_PRODUCTS.NAME%TYPE;
P_CONTRACT_STATUS       OKC_K_HEADERS_ALL_B.sts_code%TYPE; -- check
P_CUSTOMER_NUMBER       HZ_PARTIES.PARTY_NUMBER%TYPE;
P_CUSTOMER_NAME         HZ_PARTIES.party_name%TYPE;
P_SIC_CODE              HZ_PARTIES.SIC_CODE%TYPE;
P_VENDOR_NUMBER         po_vendors.segment1%TYPE;
P_VENDOR_NAME           po_vendors.vendor_name%TYPE;
P_SALES_CHANNEL_CODE    HZ_CUST_ACCOUNTS.SALES_CHANNEL_CODE%TYPE;
P_GEN_ACCRUAL           varchar2(240);
P_SALES_TYPE_INDICATOR  OKL_K_HEADERS.SALESTYPE_YN%TYPE;
P_END_DATE_FROM         DATE;
P_END_DATE_TO           DATE;
P_TERMINATE_DATE_FROM   DATE;
P_TERMINATE_DATE_TO     DATE;

P_DELETE_DATA_YN        VARCHAR2(5);
L_REQUEST_ID            NUMBER;
 P_REQUEST_ID            NUMBER;





 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------
PROCEDURE pull_extract_data_conc (
                errbuf  				OUT NOCOPY VARCHAR2,
                retcode 				OUT NOCOPY NUMBER,
                P_OPERATING_UNIT       	IN NUMBER,
               -- P_REPORT_DATE			IN VARCHAR2,  sechawla 25-sep-09 8890513
                P_START_DATE_FROM  	    IN VARCHAR2,
                P_START_DATE_TO    	    IN VARCHAR2,
                P_AR_INFO_YN			IN VARCHAR2,
                P_BOOK_CLASS			IN VARCHAR2,
                P_LEASE_PRODUCT			IN VARCHAR2,
                P_CONTRACT_STATUS		IN VARCHAR2,
                P_CUSTOMER_NUMBER		IN VARCHAR2,
				P_CUSTOMER_NAME			IN VARCHAR2,
				P_SIC_CODE				IN VARCHAR2,
				P_VENDOR_NUMBER			IN VARCHAR2,
				P_VENDOR_NAME			IN VARCHAR2,
				P_SALES_CHANNEL			IN VARCHAR2,
				P_GEN_ACCRUAL			IN VARCHAR2,
				P_END_DATE_FROM		    IN VARCHAR2,
                P_END_DATE_TO			IN VARCHAR2,
                P_TERMINATE_DATE_FROM   IN VARCHAR2,
				P_TERMINATE_DATE_TO		IN VARCHAR2,
                P_DELETE_DATA_YN		IN VARCHAR2,
                p_num_processes    		IN NUMBER,
                p_assigned_process      IN VARCHAR2

                );

PROCEDURE pull_extract_data (
                p_api_version			IN  NUMBER
				,p_init_msg_list		IN  VARCHAR2	DEFAULT Okc_Api.G_FALSE
				,x_return_status		OUT NOCOPY VARCHAR2
				,x_msg_count			OUT NOCOPY NUMBER
				,x_msg_data				OUT NOCOPY VARCHAR2,
				 x_row_count            OUT NOCOPY VARCHAR2,
				P_OPERATING_UNIT       	IN NUMBER,
	     		--P_REPORT_DATE			IN VARCHAR2,  sechawla 25-sep-09 8890513
                P_START_DATE_FROM  	    IN VARCHAR2,
                P_START_DATE_TO    	    IN VARCHAR2,
                P_AR_INFO_YN			IN VARCHAR2,
                P_BOOK_CLASS			IN VARCHAR2,
                P_LEASE_PRODUCT			IN VARCHAR2,
                P_CONTRACT_STATUS		IN VARCHAR2,
                P_CUSTOMER_NUMBER		IN VARCHAR2,
				P_CUSTOMER_NAME			IN VARCHAR2,
				P_SIC_CODE				IN VARCHAR2,
				P_VENDOR_NUMBER			IN VARCHAR2,
				P_VENDOR_NAME			IN VARCHAR2,
				P_SALES_CHANNEL			IN VARCHAR2,
				P_GEN_ACCRUAL			IN VARCHAR2,
				P_END_DATE_FROM		    IN VARCHAR2,
                P_END_DATE_TO			IN VARCHAR2,
                P_TERMINATE_DATE_FROM   IN DATE,
				P_TERMINATE_DATE_TO		IN DATE,
                P_DELETE_DATA_YN		IN VARCHAR2,
                p_num_processes    		IN NUMBER,
                p_assigned_process      IN VARCHAR2

                );


FUNCTION AMOUNT_DUE_REMAINING(
            p_CONTRACT_NUMBER          IN  VARCHAR2,
            p_from_days                IN  number,
            p_to_days                  IN  number)
                                  RETURN NUMBER;


FUNCTION accrual_status_yn  (p_chr_id NUMBER) return VARCHAR2;
FUNCTION delete_report_data  return BOOLEAN;
FUNCTION first_activation_date  (p_chr_id NUMBER) return DATE;

END OKL_CNTRCT_FIN_EXTRACT_PVT;

/
