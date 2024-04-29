--------------------------------------------------------
--  DDL for Package OKS_EVTREN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_EVTREN_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPERWS.pls 120.2 2005/11/23 16:25:52 skekkar noship $*/

 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
    G_PKG_NAME CONSTANT VARCHAR2(200) := 'OKS_EVTREN_PUB';
    G_APP_NAME CONSTANT VARCHAR2(3) := OKC_API.G_APP_NAME;

  ---------------------------------------------------------------------------

  -- GLOBAL_MESSAGE_CONSTANTS
  ---------------------------------------------------------------------------
    G_FND_APP CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
    G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
    G_FORM_RECORD_DELETED CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
    G_FORM_RECORD_CHANGED CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
    G_RECORD_LOGICALLY_DELETED CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
    G_REQUIRED_VALUE CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
    G_INVALID_VALUE CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
    G_COL_NAME_TOKEN CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
    G_PARENT_TABLE_TOKEN CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
    G_CHILD_TABLE_TOKEN CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
    G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
    G_SQLERRM_TOKEN CONSTANT VARCHAR2(200) := 'SQLerrm';
    G_SQLCODE_TOKEN CONSTANT VARCHAR2(200) := 'SQLcode';
    G_UPPERCASE_REQUIRED CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
  ---------------------------------------------------------------------------

  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
    G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------

    PROCEDURE Renew
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     p_contract_id IN NUMBER,
     p_contract_number IN okc_k_headers_v.contract_number%TYPE DEFAULT NULL,
     p_contract_version IN VARCHAR2 DEFAULT NULL,
     p_contract_modifier IN okc_k_headers_v.contract_number_modifier%TYPE DEFAULT NULL,
     p_object_version_number IN NUMBER DEFAULT NULL,
     p_new_contract_number IN okc_k_headers_v.contract_number%TYPE DEFAULT NULL,
     p_new_contract_modifier IN okc_k_headers_v.contract_number_modifier%TYPE DEFAULT NULL,
     p_start_date IN DATE DEFAULT NULL,
     p_end_date IN DATE DEFAULT NULL,
     p_orig_start_date IN DATE DEFAULT NULL,
     p_orig_end_date IN DATE DEFAULT NULL,
     p_uom_code IN okx_units_of_measure_v.uom_code%TYPE DEFAULT NULL,
     p_duration IN NUMBER DEFAULT NULL,
     p_Renewal_Type IN VARCHAR2 DEFAULT NULL,
     p_Renewal_Pricing_Type IN VARCHAR2 DEFAULT NULL,
     p_Markup_Percent IN NUMBER DEFAULT NULL,
     p_Price_List_Id1 IN VARCHAR2 DEFAULT NULL,
     p_Price_List_Id2 IN VARCHAR2 DEFAULT NULL,
     p_PDF_ID IN NUMBER DEFAULT NULL,
     p_QCL_ID IN NUMBER DEFAULT NULL,
     p_CGP_NEW_ID IN NUMBER DEFAULT NULL,
     p_CGP_RENEW_ID IN NUMBER DEFAULT NULL,
     p_PO_REQUIRED_YN IN VARCHAR2 DEFAULT NULL,
     p_RLE_CODE IN VARCHAR2 DEFAULT NULL,
     p_Function_Name IN VARCHAR2 DEFAULT NULL,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
     );
END OKS_EVTREN_PUB;

 

/
