--------------------------------------------------------
--  DDL for Package OKS_TAX_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_TAX_UTIL_PVT" AUTHID CURRENT_USER AS
    /* $Header: OKSTAXUS.pls 120.11.12000000.1 2007/01/16 22:15:12 appldev ship $*/

    --------------------------------------------------------------------------
    -- GLOBAL MESSAGE CONSTANTS
    ---------------------------------------------------------------------------
    G_FND_APP					CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
    G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
    G_REQUIRED_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
    G_INVALID_VALUE				CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
    G_COL_NAME_TOKEN			CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
    G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
    G_CHILD_TABLE_TOKEN			CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
    G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKS_TAX_UTIL_UNEXPECTED_ERROR';
    G_EXPECTED_ERROR          	CONSTANT VARCHAR2(200) := 'OKS_TAX_UTIL_PVT';
    G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'SQLCODE';
    G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'SQLERRM';
    G_NO_TRX_TYPE               CONSTANT VARCHAR2(200) := 'OKS_NO_TRX_TYPE';

    ---------------------------------------------------------------------------
    -- GLOBAL EXCEPTIONS
    ---------------------------------------------------------------------------
    G_EXCEPTION_HALT_VALIDATION EXCEPTION;
    G_EXCEPTION_ROLLBACK        EXCEPTION;
    G_ERROR	                    EXCEPTION;

    ---------------------------------------------------------------------------
    -- GLOBAL VARIABLES
    ---------------------------------------------------------------------------
    G_PKG_NAME			        CONSTANT VARCHAR2(200) := 'OKS_TAX_UTIL_PVT';
    G_APP_NAME			        CONSTANT VARCHAR2(3) := OKC_API.G_APP_NAME;
    G_OKS_APP_NAME              CONSTANT VARCHAR2(3) := 'OKS'; --all new nessages should use this

    TYPE RA_REC_TYPE IS RECORD
    (
     HEADER_ID                       NUMBER,
     LINE_ID                         NUMBER,
     TAX_EXEMPT_FLAG                 VARCHAR2(1),
     TAX_EXEMPT_REASON               VARCHAR2(30),
     TAX_EXEMPT_NUMBER               VARCHAR2(80),
     SALES_TAX_ID                    NUMBER(15),
     ORG_ID                          NUMBER(15),
     ORIG_SYSTEM_SHIP_ADDRESS_ID     NUMBER(15),
     ORIG_SYSTEM_SHIP_CONTACT_ID     NUMBER(15),
     ORIG_SYSTEM_SHIP_CUSTOMER_ID    NUMBER(15),
     SHIP_TO_SITE_USE_ID             NUMBER(15),
     SHIP_TO_POSTAL_CODE             VARCHAR2(60),
     SHIP_TO_LOCATION_ID             NUMBER(15),
     SHIP_TO_CUSTOMER_NUMBER         VARCHAR2(50),
     SHIP_TO_CUSTOMER_NAME           VARCHAR2(200),
     SHIP_TO_ORG_ID                  NUMBER(15),
     WAREHOUSE_ID                    NUMBER,
     ORIG_SYSTEM_SOLD_CUSTOMER_ID    NUMBER(15),
     ORIG_SYSTEM_BILL_CUSTOMER_ID    NUMBER(15),
     ORIG_SYSTEM_BILL_ADDRESS_ID     NUMBER(15),
     ORIG_SYSTEM_BILL_CONTACT_ID     NUMBER(15),
     BILL_TO_SITE_USE_ID             NUMBER(15),
     BILL_TO_POSTAL_CODE             VARCHAR2(60),
     BILL_TO_LOCATION_ID             NUMBER(15),
     BILL_TO_CUSTOMER_NUMBER         VARCHAR2(50),
     BILL_TO_CUSTOMER_NAME           VARCHAR2(200),
     BILL_TO_ORG_ID                  NUMBER(15),
     RECEIPT_METHOD_NAME             VARCHAR2(30),
     RECEIPT_METHOD_ID               NUMBER(15),
     CONVERSION_TYPE                 VARCHAR2(30),
     CONVERSION_DATE                 DATE,
     CONVERSION_RATE                 NUMBER,
     CUSTOMER_TRX_ID                 NUMBER(15),
     TRX_DATE                        DATE,
     GL_DATE                         DATE,
     DOCUMENT_NUMBER                 NUMBER(15),
     TRX_NUMBER                      VARCHAR2(20),
     LINE_NUMBER                     NUMBER(15),
     QUANTITY                        NUMBER,
     QUANTITY_ORDERED                NUMBER,
     UNIT_SELLING_PRICE              NUMBER,
     UNIT_STANDARD_PRICE             NUMBER,
     PRINTING_OPTION                 VARCHAR2(20),
     INVENTORY_ITEM_ID               NUMBER(15),
     INVENTORY_ORG_ID                NUMBER(15),
     UOM_CODE                        VARCHAR2(3),
     UOM_NAME                        VARCHAR2(25),
     RELATED_TRX_NUMBER              VARCHAR2(20),
     RELATED_CUSTOMER_TRX_ID         NUMBER(15),
     PREVIOUS_CUSTOMER_TRX_ID        NUMBER(15),
     REASON_CODE                     VARCHAR2(30),
     TAX_RATE                        NUMBER,
     TAX_CODE                        VARCHAR2(50),
     TAX_PRECEDENCE                  NUMBER,
     INVOICING_RULE_NAME             VARCHAR2(30),
     INVOICING_RULE_ID               NUMBER(15),
     PURCHASE_ORDER                  VARCHAR2(50),
     SET_OF_BOOKS_ID                 NUMBER(15),
     LINE_TYPE                       VARCHAR2(20),
     DESCRIPTION                     VARCHAR2(240),
     CURRENCY_CODE                   VARCHAR2(15),
     AMOUNT                          NUMBER,
     CUST_TRX_TYPE_NAME              VARCHAR2(20),
     CUST_TRX_TYPE_ID                NUMBER(15),
     PAYMENT_TERM_ID                         NUMBER(15),
     AMOUNT_INCLUDES_TAX_FLAG        VARCHAR2(1),
     TAX_CAL_PLSQL_BLOCK             VARCHAR2(3000),
     MINIMUM_ACCOUNTABLE_UNIT        NUMBER,
     PRECISION                       NUMBER,
     FOB_POINT                       VARCHAR2(30),
     TAXABLE_BASIS                   VARCHAR2(30),
     VAT_TAX_ID                      NUMBER,
     TAX_VALUE                       NUMBER,
     TOTAL_PLUS_TAX                  NUMBER,
     --Added in R12 by rsu
     TAX_CLASSIFICATION_CODE         VARCHAR2(30),
     EXEMPT_CERTIFICATE_NUMBER       VARCHAR2(80),
     EXEMPT_REASON_CODE              VARCHAR2(30),
     SHIP_TO_PARTY_ID                HZ_CUST_ACCOUNTS.PARTY_ID%TYPE,
     SHIP_TO_PARTY_SITE_ID           HZ_PARTY_SITES.PARTY_SITE_ID%TYPE,
     SHIP_TO_CUST_ACCT_ID            HZ_CUST_ACCT_SITES_ALL.CUST_ACCOUNT_ID%TYPE,
     SHIP_TO_CUST_ACCT_SITE_ID       HZ_CUST_SITE_USES_ALL.CUST_ACCT_SITE_ID%TYPE,
     SHIP_TO_CUST_ACCT_SITE_USE_ID   OKC_K_LINES_B.SHIP_TO_SITE_USE_ID%TYPE,
     BILL_TO_PARTY_ID                HZ_CUST_ACCOUNTS.PARTY_ID%TYPE,
     BILL_TO_PARTY_SITE_ID           HZ_PARTY_SITES.PARTY_SITE_ID%TYPE,
     BILL_TO_CUST_ACCT_ID            OKC_K_LINES_B.CUST_ACCT_ID%TYPE,
     BILL_TO_CUST_ACCT_SITE_ID       HZ_CUST_SITE_USES_ALL.CUST_ACCT_SITE_ID%TYPE,
     BILL_TO_CUST_ACCT_SITE_USE_ID   OKC_K_LINES_B.BILL_TO_SITE_USE_ID%TYPE,
     PRICE_NEGOTIATED                OKC_K_LINES_B.price_negotiated%TYPE,
     PRODUCT_TYPE                    ZX_PRODUCT_TYPES_DEF_V.CLASSIFICATION_CODE%TYPE
     );
    TYPE RA_REC_TBL IS TABLE OF ra_rec_type INDEX BY BINARY_INTEGER;

    ---------------------------------------------------------------------------
    -- Procedures and Functions
    ---------------------------------------------------------------------------
    /*
        Procedure that calciulates tax for a given contract line and populates the
        results in px_rail_rec

        Parameters
            p_chr_id        :   contract id
            p_cle_id        :   top line or subline id
            px_rail_rec     :   tax record structure

    */
    PROCEDURE GET_TAX
    (
     p_api_version			IN	NUMBER,
     p_init_msg_list		IN	VARCHAR2	DEFAULT OKC_API.G_FALSE,
     p_chr_id			    IN	NUMBER,
     p_cle_id               IN  NUMBER,
     px_rail_rec            IN  OUT NOCOPY ra_rec_type,
     x_msg_count			OUT NOCOPY	NUMBER,
     x_msg_data				OUT NOCOPY	VARCHAR2,
     x_return_status		OUT NOCOPY	VARCHAR2
     );


    /*
        This is a concurrent program to migrate the pre-R12 tax data
        to R12 eBTax.  We do not remove the old values.
            OKS_K_HEADERS_B:
                TAX_EXEMPTION_ID --> EXEMPT_CERTIFICATE_NUMBER and EXEMPT_REASON_CODE

            OKS_K_LINES_B:
                TAX_EXEMPTION_ID --> EXEMPT_CERTIFICATE_NUMBER and EXEMPT_REASON_CODE
                TAX_CODE --> TAX_CLASSIFICATION_CODE
    */
    PROCEDURE TAX_MIGRATION
    (
     ERRBUF OUT NOCOPY VARCHAR2,
     RETCODE OUT NOCOPY NUMBER
     );

--npalepu added on 19-jun-2006 for bug # 4908543
PROCEDURE Update_Tax_BMGR(X_errbuf     out NOCOPY varchar2,
                          X_retcode    out NOCOPY varchar2,
                          P_batch_size  in number,
                          P_Num_Workers in number);

PROCEDURE Update_Tax_HMGR(X_errbuf     out NOCOPY varchar2,
                          X_retcode    out NOCOPY varchar2,
                          P_batch_size  in number,
                          P_Num_Workers in number);

    /*
        This is a concurrent program to migrate the pre-R12 tax data
        to R12 eBTax.  We do not remove the old values.
            OKS_K_LINES_B:
                TAX_EXEMPTION_ID --> EXEMPT_CERTIFICATE_NUMBER and EXEMPT_REASON_CODE
                TAX_CODE --> TAX_CLASSIFICATION_CODE
    */
PROCEDURE Update_Tax_BWKR(X_errbuf     out NOCOPY varchar2,
                          X_retcode    out NOCOPY varchar2,
                          P_batch_size  in number,
                          P_Worker_Id   in number,
                          P_Num_Workers in number);

    /*
        This is a concurrent program to migrate the pre-R12 tax data
        to R12 eBTax.  We do not remove the old values.
            OKS_K_LINES_BH:
                TAX_EXEMPTION_ID --> EXEMPT_CERTIFICATE_NUMBER and EXEMPT_REASON_CODE
                TAX_CODE --> TAX_CLASSIFICATION_CODE
    */
PROCEDURE Update_Tax_HWKR(X_errbuf     out NOCOPY varchar2,
                          X_retcode    out NOCOPY varchar2,
                          P_batch_size  in number,
                          P_Worker_Id   in number,
                          P_Num_Workers in number);
--end npalepu


    --Added in R12 by rsu
    FUNCTION GET_CUST_TRX_TYPE_ID
    (
     p_org_id IN NUMBER,
     p_inv_trx_type IN VARCHAR2
    )
    RETURN NUMBER;


    --Added in R12 by rsu
    FUNCTION GET_LEGAL_ENTITY_ID
    (
     p_bill_to_cust_acct_id IN NUMBER,
     p_cust_trx_type_id IN NUMBER,
     p_org_id IN NUMBER
    )
    RETURN NUMBER;


    --Added in R12 by rsu
    --Overloaded Get_Legal_Entity_Id
    --For UI use
    FUNCTION GET_LEGAL_ENTITY_ID
    (
     p_chr_id IN NUMBER
    )
    RETURN NUMBER;

END OKS_TAX_UTIL_PVT;

 

/
