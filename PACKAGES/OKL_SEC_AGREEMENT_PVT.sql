--------------------------------------------------------
--  DDL for Package OKL_SEC_AGREEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SEC_AGREEMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSZAS.pls 120.4 2008/01/04 13:04:15 sosharma noship $ */
 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_SEC_AGREEMENT_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

 G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
 G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
 G_RET_STS_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
 G_EXCEPTION_ERROR		 EXCEPTION;
 G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;

 G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
 G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------

  TYPE secAgreement_rec_type IS RECORD (
 ID                                OKC_K_HEADERS_B.ID%TYPE := OKL_API.G_MISS_NUM --NUMBER
,CONTRACT_NUMBER                   OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE := OKL_API.G_MISS_CHAR --VARCHAR2(120)
,PDT_ID                            OKL_K_HEADERS.PDT_ID%TYPE := OKL_API.G_MISS_NUM--NUMBER
,POL_ID                            OKL_POOLS.ID%TYPE := OKL_API.G_MISS_NUM --NUMBER
,SHORT_DESCRIPTION                 OKC_K_HEADERS_V.SHORT_DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR --VARCHAR2(600)
,START_DATE                        OKC_K_HEADERS_B.START_DATE%TYPE := OKL_API.G_MISS_DATE --DATE
,END_DATE                          OKC_K_HEADERS_B.END_DATE%TYPE := OKL_API.G_MISS_DATE --DATE
,DATE_APPROVED                     OKC_K_HEADERS_B.DATE_APPROVED%TYPE := OKL_API.G_MISS_DATE --DATE
,SECURITIZATION_TYPE               OKL_K_HEADERS.SECURITIZATION_TYPE%TYPE := OKL_API.G_MISS_CHAR --VARCHAR2(30)
,LESSOR_SERV_ORG_CODE              OKL_K_HEADERS.LESSOR_SERV_ORG_CODE%TYPE := OKL_API.G_MISS_CHAR --VARCHAR2(30)
,RECOURSE_CODE                     OKL_K_HEADERS.RECOURSE_CODE%TYPE := OKL_API.G_MISS_CHAR --VARCHAR2(30)
-- defualt to 'NEW'
,STS_CODE                          OKC_K_HEADERS_B.STS_CODE%TYPE := OKL_API.G_MISS_CHAR --VARCHAR2(30)
-- default currency code from okl_pools.currency_code
,CURRENCY_CODE                     OKC_K_HEADERS_B.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR --VARCHAR2(15)
,CURRENCY_CONVERSION_TYPE          OKL_K_HEADERS.CURRENCY_CONVERSION_TYPE%TYPE := OKL_API.G_MISS_CHAR --VARCHAR2(30)
,CURRENCY_CONVERSION_RATE          OKL_K_HEADERS.CURRENCY_CONVERSION_RATE%TYPE := OKL_API.G_MISS_NUM--NUMBER
,CURRENCY_CONVERSION_DATE          OKL_K_HEADERS.CURRENCY_CONVERSION_DATE%TYPE := OKL_API.G_MISS_DATE--DATE
,trustee_party_roles_id            okc_k_party_roles_b.id%type := OKL_API.G_MISS_NUM -- NUMBER
,trustee_object1_id1               okc_k_party_roles_b.object1_id1%type := OKL_API.G_MISS_CHAR -- VARCHAR2(40)
,trustee_object1_id2               okc_k_party_roles_b.object1_id1%type := OKL_API.G_MISS_CHAR -- VARCHAR2(200)
,trustee_jtot_object1_code         okc_k_party_roles_b.jtot_object1_code%type := OKL_API.G_MISS_CHAR -- VARCHAR2(30)
-- akjain,v115.6
,AFTER_TAX_YIELD                   OKL_K_HEADERS.AFTER_TAX_YIELD%TYPE := OKL_API.G_MISS_NUM --NUMBER
-- arajagop Begin added for Flexfield Support
,ATTRIBUTE_CATEGORY                OKL_K_HEADERS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE1                        OKL_K_HEADERS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE2                        OKL_K_HEADERS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE3                        OKL_K_HEADERS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE4                        OKL_K_HEADERS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE5                        OKL_K_HEADERS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE6                        OKL_K_HEADERS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE7                        OKL_K_HEADERS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE8                        OKL_K_HEADERS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE9                        OKL_K_HEADERS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE10                       OKL_K_HEADERS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE11                       OKL_K_HEADERS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE12                       OKL_K_HEADERS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE13                       OKL_K_HEADERS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE14                       OKL_K_HEADERS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
,ATTRIBUTE15                       OKL_K_HEADERS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
-- arajagop End added for Flexfield Support
--added abhsaxen for Legal Entity Uptake
,legal_entity_id                   OKL_K_HEADERS.LEGAL_ENTITY_ID%TYPE := OKL_API.G_MISS_NUM
);

  TYPE secAgreement_tbl_type IS TABLE OF secAgreement_rec_type
        INDEX BY BINARY_INTEGER;

 ----------------------------------------------------------------------------
 -- Global Exception
 ----------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ----------------------------------------------------------------------------
 -- Procedures and Functions
 ------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_sec_agreement
-- Description     : creates a securitization agreement
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_sec_agreement(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_secAgreement_rec             IN secAgreement_rec_type
   ,x_secAgreement_rec             OUT NOCOPY secAgreement_rec_type);

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_sec_agreement
-- Description     : updates a securitization agreement
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_sec_agreement(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_secAgreement_rec             IN secAgreement_rec_type
   ,x_secAgreement_rec             OUT NOCOPY secAgreement_rec_type);

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : activate_sec_agreement
-- Description     : activate a securitization agreement
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE activate_sec_agreement(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_khr_id                       IN OKC_K_HEADERS_B.ID%TYPE);

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_sec_agreement_sts
-- Description     : updates a securitization agreement header, all lines status,
--                   and pool header status
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_sec_agreement_sts(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_sec_agreement_status         IN okc_k_headers_b.sts_code%TYPE
   ,p_sec_agreement_id             IN okc_k_headers_b.id%TYPE)
;

  --Added by kthiruva on 18-Dec-2007
  -- New method to validate an add request on an active investor agreement
  --Bug 6691554 - Start of Changes
  Procedure validate_add_request(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  NUMBER);

  Procedure activate_add_request (
    		p_api_version         IN NUMBER
     		,p_init_msg_list      IN VARCHAR2
    		,x_return_status      OUT NOCOPY VARCHAR2
    		,x_msg_count          OUT NOCOPY NUMBER
   	    	,x_msg_data           OUT NOCOPY VARCHAR2
   		    ,p_khr_id             IN OKC_K_HEADERS_B.ID%TYPE);

  -- Bug 6691554 - End of Changes

  /*
   19-Dec-2007, ankushar Bug# 6691554
   start changes, added new method to invoke Worklow Approval for the Add Contract Request
  */
  --------------------------------------------------------------------------------------------------
  ----------------------------------Rasing Business Event ----------------------------------------
  ------------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------------
 -- PROCEDURE submit_add_khr_request
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : submit_add_khr_request
  -- Description     :
  -- Business Rules  : Submit the Add Contracts Request for Approval.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_agreement_id, p_pool_id, x_pool_trx_status.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE submit_add_khr_request (p_api_version    IN  NUMBER,
                                    p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                    x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count      OUT NOCOPY NUMBER,
                                    x_msg_data       OUT NOCOPY VARCHAR2,
                                    p_agreement_id   IN  OKC_K_HEADERS_V.ID%TYPE,
                                    p_pool_id        IN  OKL_POOLS.ID%TYPE,
                                    x_pool_trx_status OUT NOCOPY OKL_POOL_TRANSACTIONS.TRANSACTION_STATUS%TYPE);
  /*
   19-Dec-2007, ankushar Bug# 6691554
   end changes
  */
/* sosharma 03-01-2008
Added procedure to cancel the add request on active Investor Agreement
Start changes*/


  Procedure cancel_add_request (
         p_api_version         IN NUMBER
         ,p_init_msg_list      IN VARCHAR2
         ,x_return_status      OUT NOCOPY VARCHAR2
         ,x_msg_count          OUT NOCOPY NUMBER
         ,x_msg_data           OUT NOCOPY VARCHAR2
         ,p_chr_id             IN OKC_K_HEADERS_B.ID%TYPE);

/* sosharma end changes */


END OKL_SEC_AGREEMENT_PVT;

/
