--------------------------------------------------------
--  DDL for Package OKL_SETUPPRODUCTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPPRODUCTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSPDS.pls 120.5 2007/05/11 10:55:49 dpsingh ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_VERSION_OVERLAPS		  CONSTANT VARCHAR2(200) := 'OKL_VERSION_OVERLAPS';
  G_DATES_MISMATCH			  CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_UNQS	                  CONSTANT VARCHAR2(200) := 'OKL_NOT_UNIQUE';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		  CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPPRODUCTS_PVT';

  G_INIT_VERSION			  CONSTANT NUMBER := 1.0;
  G_VERSION_MAJOR_INCREMENT	  CONSTANT NUMBER := 1.0;
  G_VERSION_MINOR_INCREMENT	  CONSTANT NUMBER := 0.1;
  G_VERSION_FORMAT			  CONSTANT VARCHAR2(100) := 'FM999.0999';
  G_COPY                      CONSTANT VARCHAR2(10) := 'COPY';
  G_UPDATE                    CONSTANT VARCHAR2(10) := 'UPDATE';

  -- multi gaap
  G_SEC_VALUES_MISS           CONSTANT VARCHAR2(200) := 'OKL_SEC_VALUES_MISS';
  G_LEASE_VALUES_MISS	      CONSTANT VARCHAR2(200) := 'OKL_LEASE_VALUES_MISS';
  G_TAXOWN_VALUES_MISS        CONSTANT VARCHAR2(200) := 'OKL_TAXOWN_VALUES_MISS';
  G_LEASE_SEC_TAXOWN_MISS	  CONSTANT VARCHAR2(200) := 'OKL_LEASE_SEC_TAXOWN_MISS';
  G_PRODUCT_SETUP_INCOMPLETE  CONSTANT VARCHAR2(200) := 'OKL_PRODUCT_SETUP_INCOMPLETE';
  G_INVALID_PDT	              CONSTANT VARCHAR2(200) := 'OKL_INVALID_PDT';

  -- user defined streams
  G_BOOK_CLASS_MISMATCH			  CONSTANT VARCHAR2(200) := 'OKL_BOOK_CLASS_MISMATCH';

  G_PDT_STS_NEW                CONSTANT VARCHAR2(10) := 'NEW';
  G_PDT_STS_PASSED             CONSTANT VARCHAR2(10) := 'PASSED';
  G_PDT_STS_INVALID            CONSTANT VARCHAR2(15) := 'INVALID';
  G_PDT_STS_APPROVED           CONSTANT VARCHAR2(15) := 'APPROVED';
  G_PDT_STS_PENDING_APPROVAL   CONSTANT VARCHAR2(20) := 'PENDING APPROVAL';

  G_WF_ITM_APPLICATION_ID      CONSTANT VARCHAR2(20) := 'APPLICATION_ID';
  G_WF_ITM_TRANSACTION_TYPE_ID CONSTANT VARCHAR2(20) := 'TRX_TYPE_ID';
  G_WF_ITM_TRANSACTION_ID      CONSTANT VARCHAR2(20) := 'TRANSACTION_ID';
  G_WF_ITM_REQUESTER           CONSTANT VARCHAR2(20) := 'REQUESTER';
  G_WF_ITM_REQUESTER_ID        CONSTANT VARCHAR2(20) := 'REQUESTER_ID';
  G_WF_ITM_APPROVER            CONSTANT VARCHAR2(20) := 'APPROVER';
  G_WF_ITM_APPROVAL_REQ_MSG    CONSTANT VARCHAR2(30) := 'APPROVAL_REQUEST_MESSAGE';
  G_WF_ITM_PRODUCT_ID          CONSTANT VARCHAR2(20) := 'PRODUCT_ID';
  G_WF_ITM_PRODUCT_NAME        CONSTANT VARCHAR2(20) := 'PRODUCT_NAME';
  G_WF_ITM_APPROVED_YN         CONSTANT VARCHAR2(15) := 'APPROVED_YN';
  G_WF_ITM_MESSAGE_DESCRIPTION CONSTANT VARCHAR2(30) := 'MESSAGE_DESCRIPTION';
  G_WF_USER_ORIG_SYSTEM_HR CONSTANT VARCHAR2(5) := 'PER';
  G_DEFAULT_USER_DESC CONSTANT VARCHAR2(30) := 'System Administrator';
  G_WF_ITM_APPROVED_YN_YES     CONSTANT VARCHAR2(1)  := 'Y';
  G_WF_ITM_APPROVED_YN_NO      CONSTANT VARCHAR2(1)  := 'N';

  --Tax enhancement project
  G_TAX_STYID_MISMATCH  CONSTANT VARCHAR2(200) := 'OKL_TAX_STYID_MISMATCH';
--*** copied form lla need to create own later
  G_NO_MATCHING_RECORD          CONSTANT VARCHAR2(200)  := 'OKL_LLA_NO_MATCHING_RECORD';
  G_KHR_STATUS_NOT_COMPLETE               VARCHAR2(200)  := 'OKL_LLA_NOT_COMPLETE';
  G_TRANS_APP_NAME              CONSTANT VARCHAR2(200)  := 'OKL LP Product Approval Process';
  G_EVENT_APPROVE_AME           CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.approve_lease_contract';
  G_INVALID_APP                          VARCHAR2(200)  := 'OKL_LLA_INVALID_APPLICATION';
  G_API_TYPE                    CONSTANT VARCHAR2(200)  := '_PVT';


  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  TYPE pdt_parameters_rec_type IS RECORD (
    id                         NUMBER := okl_api.G_MISS_NUM,
	name                       OKL_PRODUCTS_V.NAME%TYPE := okl_api.G_MISS_CHAR,
	from_date                  OKL_PRODUCTS.FROM_DATE%TYPE := okl_api.G_MISS_DATE,
    to_date                    OKL_PRODUCTS.TO_DATE%TYPE := okl_api.G_MISS_DATE,
	version                    OKL_PRODUCTS_V.VERSION%TYPE := okl_api.G_MISS_CHAR,
	object_version_number      NUMBER := okl_api.G_MISS_NUM,
    aes_id                     NUMBER := okl_api.G_MISS_NUM,
    ptl_id                     NUMBER := okl_api.G_MISS_NUM,
    legacy_product_yn          OKL_PRODUCTS.LEGACY_PRODUCT_YN%TYPE := okl_api.G_MISS_CHAR,
	attribute_category         OKL_PRODUCTS.ATTRIBUTE_CATEGORY%TYPE := okl_api.G_MISS_CHAR,
    attribute1                 OKL_PRODUCTS.ATTRIBUTE1%TYPE := okl_api.G_MISS_CHAR,
    attribute2                 OKL_PRODUCTS.ATTRIBUTE2%TYPE := okl_api.G_MISS_CHAR,
    attribute3                 OKL_PRODUCTS.ATTRIBUTE3%TYPE := okl_api.G_MISS_CHAR,
    attribute4                 OKL_PRODUCTS.ATTRIBUTE4%TYPE := okl_api.G_MISS_CHAR,
    attribute5                 OKL_PRODUCTS.ATTRIBUTE5%TYPE := okl_api.G_MISS_CHAR,
    attribute6                 OKL_PRODUCTS.ATTRIBUTE6%TYPE := okl_api.G_MISS_CHAR,
    attribute7                 OKL_PRODUCTS.ATTRIBUTE7%TYPE := okl_api.G_MISS_CHAR,
    attribute8                 OKL_PRODUCTS.ATTRIBUTE8%TYPE := okl_api.G_MISS_CHAR,
    attribute9                 OKL_PRODUCTS.ATTRIBUTE9%TYPE := okl_api.G_MISS_CHAR,
    attribute10                OKL_PRODUCTS.ATTRIBUTE10%TYPE := okl_api.G_MISS_CHAR,
    attribute11                OKL_PRODUCTS.ATTRIBUTE11%TYPE := okl_api.G_MISS_CHAR,
    attribute12                OKL_PRODUCTS.ATTRIBUTE12%TYPE := okl_api.G_MISS_CHAR,
    attribute13                OKL_PRODUCTS.ATTRIBUTE13%TYPE := okl_api.G_MISS_CHAR,
    attribute14                OKL_PRODUCTS.ATTRIBUTE14%TYPE := okl_api.G_MISS_CHAR,
    attribute15                OKL_PRODUCTS.ATTRIBUTE15%TYPE := okl_api.G_MISS_CHAR,
	Product_subclass           OKL_PDT_QUALITYS_V.NAME%TYPE  := okl_api.G_MISS_CHAR,
    Deal_Type                  OKL_PQY_VALUES_V.VALUE%TYPE  := okl_api.G_MISS_CHAR,
    Tax_Owner                  OKL_PQY_VALUES_V.VALUE%TYPE  := okl_api.G_MISS_CHAR,
    Revenue_Recognition_Method OKL_PQY_VALUES_V.VALUE%TYPE  := okl_api.G_MISS_CHAR,
    Interest_Calculation_Basis OKL_PQY_VALUES_V.VALUE%TYPE  := okl_api.G_MISS_CHAR,
    reporting_pdt_id           NUMBER := okl_api.G_MISS_NUM,
	reporting_product          OKL_PRODUCTS_V.NAME%TYPE := okl_api.G_MISS_CHAR
	);

  g_miss_pdt_parameters_rec            pdt_parameters_rec_type;

  TYPE pdt_parameters_tbl_type IS TABLE OF pdt_parameters_rec_type
        INDEX BY BINARY_INTEGER;

  SUBTYPE pdtv_rec_type IS okl_products_pub.pdtv_rec_type;
  SUBTYPE pdtv_tbl_type IS okl_products_pub.pdtv_tbl_type;

  SUBTYPE pqvv_rec_type IS okl_pqy_values_pub.pqvv_rec_type;
  SUBTYPE pqvv_tbl_type IS okl_pqy_values_pub.pqvv_tbl_type;

  SUBTYPE ponv_rec_type IS okl_product_options_pub.ponv_rec_type;
  SUBTYPE ponv_tbl_type IS okl_product_options_pub.ponv_tbl_type;

  SUBTYPE povv_rec_type IS okl_pdt_opt_vals_pub.povv_rec_type;
  SUBTYPE povv_tbl_type IS okl_pdt_opt_vals_pub.povv_tbl_type;

  PROCEDURE get_rec(
  	p_pdtv_rec					   IN pdtv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_pdtv_rec					   OUT NOCOPY pdtv_rec_type);

  PROCEDURE insert_products(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
    x_pdtv_rec                     OUT NOCOPY pdtv_rec_type);

  PROCEDURE update_products(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
    x_pdtv_rec                     OUT NOCOPY pdtv_rec_type);


  ---  Submit for Approval
  PROCEDURE product_approval_process
			(   p_api_version                  IN  NUMBER,
			    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
			    x_return_status                OUT NOCOPY VARCHAR2,
			    x_msg_count                    OUT NOCOPY NUMBER,
			    x_msg_data                     OUT NOCOPY VARCHAR2,
			    p_pdtv_rec                     IN  pdtv_rec_type);

  -- set addtional product parameters and parameters for AME approval process
  PROCEDURE set_additionalparameters(
			   itemtype	IN  VARCHAR2,
		           itemkey  	IN  VARCHAR2,
		           actid	IN  NUMBER,
			   funcmode	IN  VARCHAR2,
			   resultout OUT NOCOPY VARCHAR2);

  ---  procedure called from workflow returning approval status
  PROCEDURE get_approval_status(itemtype  IN VARCHAR2,
                              itemkey   IN VARCHAR2,
                              actid     IN NUMBER,
                              funcmode  IN VARCHAR2,
                              resultout OUT NOCOPY VARCHAR2);

  ---  procedure to update product status
  PROCEDURE update_product_status(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT okl_api.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_pdt_status      IN  VARCHAR2,
            p_pdt_id          IN  VARCHAR2);

  --procedure to validate_product
  PROCEDURE validate_product(
	    p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT okl_api.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
   	    p_pdtv_rec IN      pdtv_rec_type,
	    x_pdtv_rec        OUT NOCOPY pdtv_rec_type
  	);




  PROCEDURE Getpdt_parameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
	x_no_data_found                OUT NOCOPY BOOLEAN,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
	p_product_date                 IN  DATE DEFAULT SYSDATE,
    p_pdt_parameter_rec            OUT NOCOPY pdt_parameters_rec_type);

END OKL_SETUPPRODUCTS_PVT;

/
