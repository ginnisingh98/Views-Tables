--------------------------------------------------------
--  DDL for Package Body OKL_SPLIT_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SPLIT_CONTRACT_PVT" AS
/* $Header: OKLRSKHB.pls 120.19.12010000.2 2008/10/01 22:40:27 rkuttiya ship $ */
-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_NO_MATCHING_RECORD          CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_INVALID_CRITERIA            CONSTANT VARCHAR2(200) := 'OKL_LLA_INVALID_CRITERIA';
  G_COPY_HEADER                 CONSTANT VARCHAR2(200) := 'OKL_LLA_COPY_HEADER';
  G_COPY_LINE                   CONSTANT VARCHAR2(200) := 'OKL_LLA_COPY_LINE';
  G_FND_APP                     CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_TOKEN_K_NUM                 CONSTANT VARCHAR2(200) := 'Contract Number';
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  G_ERROR_NAL_SPK               CONSTANT VARCHAR2(200) := 'OKL_LLA_ERROR_NAL_SPK';
  G_ERROR_QA_CHECK              CONSTANT VARCHAR2(200) := 'OKL_LLA_SPK_QA_CHECK';
  G_ERROR_CLEAN_SPK             CONSTANT VARCHAR2(200) := 'OKL_LLA_CLEANUP_SPK';
  G_ERROR_STR_GEN               CONSTANT VARCHAR2(200) := 'OKL_LLA_STRMS_REQ_FLD';
  G_CNT_REC                     CONSTANT VARCHAR2(200) := 'OKL_LLA_CNT_REC';
  G_INVALID_CONTRACT            CONSTANT VARCHAR2(200) := 'OKL_LLA_CHR_ID';
-------------------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
-------------------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';
-------------------------------------------------------------------------------------------------
-- GLOBAL VARIABLES
-------------------------------------------------------------------------------------------------
  G_PKG_NAME	                CONSTANT  VARCHAR2(200) := 'OKL_SPLIT_CONTRACT_PVT';
  G_APP_NAME		        CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_FIN_LINE_LTY_CODE                     OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_FA_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FIXED_ASSET';
  G_INST_LINE_LTY_CODE                    OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM2';
  G_IB_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'INST_ITEM';
  G_SER_LINE_LTY_CODE                     OKC_LINE_STYLES_B.LTY_CODE%TYPE := 'SOLD_SERVICE';
  G_SRL_LINE_LTY_CODE                     OKC_LINE_STYLES_B.LTY_CODE%TYPE := 'LINK_SERV_ASSET';
  G_FEE_LINE_LTY_CODE                     OKC_LINE_STYLES_B.LTY_CODE%TYPE := 'FEE';
  G_FEL_LINE_LTY_CODE                     OKC_LINE_STYLES_B.LTY_CODE%TYPE := 'LINK_FEE_ASSET';
  G_USG_LINE_LTY_CODE                     OKC_LINE_STYLES_B.LTY_CODE%TYPE := 'USAGE';
  G_USL_LINE_LTY_CODE                     OKC_LINE_STYLES_B.LTY_CODE%TYPE := 'LINK_USAGE_ASSET';

  G_LEASE_SCS_CODE                        OKC_K_HEADERS_V.SCS_CODE%TYPE := 'LEASE';
  G_LOAN_SCS_CODE                         OKC_K_HEADERS_V.SCS_CODE%TYPE := 'LOAN';
  G_TLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'TLS';
  G_DEBUG_SPLIT                           BOOLEAN := FALSE;
----------------------------------------------------------------------------------------------------
    SUBTYPE cimv_rec_type IS OKL_OKC_MIGRATION_PVT.cimv_rec_type;
    SUBTYPE clev_rec_type IS OKL_OKC_MIGRATION_PVT.clev_rec_type;
    SUBTYPE chrv_rec_type IS OKL_OKC_MIGRATION_PVT.CHRV_REC_TYPE;
    SUBTYPE khrv_rec_type IS OKL_CONTRACT_PUB.KHRV_REC_TYPE;
    SUBTYPE klev_rec_type IS OKL_CONTRACT_PUB.klev_rec_type;
    SUBTYPE trxv_rec_type IS OKL_TRX_ASSETS_PUB.thpv_rec_type;
    SUBTYPE trxv_tbl_type IS OKL_TRX_ASSETS_PUB.thpv_tbl_type;
    SUBTYPE talv_rec_type IS OKL_TXL_ASSETS_PUB.tlpv_rec_type;
    SUBTYPE talv_tbl_type IS OKL_TXL_ASSETS_PUB.tlpv_tbl_type;
    SUBTYPE txdv_tbl_type IS OKL_TXD_ASSETS_PUB.adpv_tbl_type;
    SUBTYPE txdv_rec_type IS OKL_TXD_ASSETS_PUB.adpv_rec_type;
    SUBTYPE itiv_rec_type IS OKL_TXL_ITM_INSTS_PUB.iipv_rec_type;
    SUBTYPE itiv_tbl_type IS OKL_TXL_ITM_INSTS_PUB.iipv_tbl_type;
    SUBTYPE rulv_rec_type IS OKL_RULE_PUB.rulv_rec_type;
    TYPE g_chr_sts_rec IS RECORD (chr_id     NUMBER := OKL_API.G_MISS_NUM,
                                  sts_code   OKC_K_LINES_B.STS_CODE%TYPE);
    TYPE g_chr_sts_tbl IS TABLE OF g_chr_sts_rec
          INDEX BY BINARY_INTEGER;

    TYPE g_cle_amt_rec IS RECORD (cle_id      NUMBER := OKL_API.G_MISS_NUM,
                                  amount      NUMBER := OKL_API.G_MISS_NUM,
                                  orig_cle_id NUMBER := OKL_API.G_MISS_NUM);
    TYPE g_cle_amt_tbl IS TABLE OF g_cle_amt_rec
          INDEX BY BINARY_INTEGER;
    lt_chr_sts_tbl        g_chr_sts_tbl;
    lt_new_cle_amt_tbl    g_cle_amt_tbl;
    lt_old_cle_amt_tbl    g_cle_amt_tbl;

   /*
   -- mvasudev, 08/23/2004
   -- Added Constants to enable Business Event
   */
   G_WF_EVT_KHR_SPLIT_COMPLETED CONSTANT VARCHAR2(58) := 'oracle.apps.okl.la.lease_contract.split_contract_completed';

   G_WF_ITM_SRC_CONTRACT_ID CONSTANT VARCHAR2(20)  := 'SOURCE_CONTRACT_ID';
   G_WF_ITM_REVISION_DATE CONSTANT VARCHAR2(15)    := 'REVISION_DATE';
   G_WF_ITM_DEST_CONTRACT_ID_1 CONSTANT VARCHAR2(25) := 'DESTINATION_CONTRACT_ID1';
   G_WF_ITM_DEST_CONTRACT_ID_2 CONSTANT VARCHAR2(25) := 'DESTINATION_CONTRACT_ID2';

-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Function Name        : get_tasv_rec
-- Description          : Get Transaction Header Record
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  FUNCTION  get_tasv_rec(p_tas_id   IN  NUMBER,
                         x_trxv_rec OUT NOCOPY trxv_rec_type)
  RETURN  VARCHAR2
  IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR c_trxv_rec(p_tas_id NUMBER)
    IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           ICA_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           TAS_TYPE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           TSU_CODE,
           TRY_ID,
           DATE_TRANS_OCCURRED,
           TRANS_NUMBER,
           COMMENTS,
           REQ_ASSET_ID,
           TOTAL_MATCH_AMOUNT
    FROM OKL_TRX_ASSETS
    WHERE id = p_tas_id;
  BEGIN
    OPEN c_trxv_rec(p_tas_id);
    FETCH c_trxv_rec INTO
           x_trxv_rec.ID,
           x_trxv_rec.OBJECT_VERSION_NUMBER,
           x_trxv_rec.ICA_ID,
           x_trxv_rec.ATTRIBUTE_CATEGORY,
           x_trxv_rec.ATTRIBUTE1,
           x_trxv_rec.ATTRIBUTE2,
           x_trxv_rec.ATTRIBUTE3,
           x_trxv_rec.ATTRIBUTE4,
           x_trxv_rec.ATTRIBUTE5,
           x_trxv_rec.ATTRIBUTE6,
           x_trxv_rec.ATTRIBUTE7,
           x_trxv_rec.ATTRIBUTE8,
           x_trxv_rec.ATTRIBUTE9,
           x_trxv_rec.ATTRIBUTE10,
           x_trxv_rec.ATTRIBUTE11,
           x_trxv_rec.ATTRIBUTE12,
           x_trxv_rec.ATTRIBUTE13,
           x_trxv_rec.ATTRIBUTE14,
           x_trxv_rec.ATTRIBUTE15,
           x_trxv_rec.TAS_TYPE,
           x_trxv_rec.CREATED_BY,
           x_trxv_rec.CREATION_DATE,
           x_trxv_rec.LAST_UPDATED_BY,
           x_trxv_rec.LAST_UPDATE_DATE,
           x_trxv_rec.LAST_UPDATE_LOGIN,
           x_trxv_rec.TSU_CODE,
           x_trxv_rec.TRY_ID,
           x_trxv_rec.DATE_TRANS_OCCURRED,
           x_trxv_rec.TRANS_NUMBER,
           x_trxv_rec.COMMENTS,
           x_trxv_rec.REQ_ASSET_ID,
           x_trxv_rec.TOTAL_MATCH_AMOUNT;
    IF c_trxv_rec%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c_trxv_rec;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
     IF c_trxv_rec%ISOPEN THEN
        CLOSE c_trxv_rec;
     END IF;
      -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     RETURN(x_return_status);
  END get_tasv_rec;
----------------------------------------------------------------------------
-- FUNCTION get_rec for: OKC_K_ITEMS_V
---------------------------------------------------------------------------
  FUNCTION get_rec_cimv(p_cle_id      IN  OKC_K_ITEMS_V.CLE_ID%TYPE,
                        p_dnz_chr_id  IN  OKC_K_ITEMS_V.DNZ_CHR_ID%TYPE,
                        x_cimv_rec OUT NOCOPY cimv_rec_type)
  RETURN VARCHAR2 IS
    CURSOR okc_cimv_pk_csr(p_cle_id     OKC_K_ITEMS_V.CLE_ID%TYPE,
                           p_dnz_chr_id OKC_K_ITEMS_V.DNZ_CHR_ID%TYPE) IS
    SELECT CIM.ID,
           CIM.OBJECT_VERSION_NUMBER,
           CIM.CLE_ID,
           CIM.CHR_ID,
           CIM.CLE_ID_FOR,
           CIM.DNZ_CHR_ID,
           CIM.OBJECT1_ID1,
           CIM.OBJECT1_ID2,
           CIM.JTOT_OBJECT1_CODE,
           CIM.UOM_CODE,
           CIM.EXCEPTION_YN,
           CIM.NUMBER_OF_ITEMS,
           CIM.UPG_ORIG_SYSTEM_REF,
           CIM.UPG_ORIG_SYSTEM_REF_ID,
           CIM.PRICED_ITEM_YN,
           CIM.CREATED_BY,
           CIM.CREATION_DATE,
           CIM.LAST_UPDATED_BY,
           CIM.LAST_UPDATE_DATE,
           CIM.LAST_UPDATE_LOGIN
    FROM okc_k_items_v cim
    WHERE cim.dnz_chr_id = p_dnz_chr_id
    AND cim.cle_id = p_cle_id;
    l_okc_cimv_pk              okc_cimv_pk_csr%ROWTYPE;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OPEN okc_cimv_pk_csr(p_cle_id,
                         p_dnz_chr_id);
    FETCH okc_cimv_pk_csr INTO
              x_cimv_rec.ID,
              x_cimv_rec.OBJECT_VERSION_NUMBER,
              x_cimv_rec.CLE_ID,
              x_cimv_rec.CHR_ID,
              x_cimv_rec.CLE_ID_FOR,
              x_cimv_rec.DNZ_CHR_ID,
              x_cimv_rec.OBJECT1_ID1,
              x_cimv_rec.OBJECT1_ID2,
              x_cimv_rec.JTOT_OBJECT1_CODE,
              x_cimv_rec.UOM_CODE,
              x_cimv_rec.EXCEPTION_YN,
              x_cimv_rec.NUMBER_OF_ITEMS,
              x_cimv_rec.UPG_ORIG_SYSTEM_REF,
              x_cimv_rec.UPG_ORIG_SYSTEM_REF_ID,
              x_cimv_rec.PRICED_ITEM_YN,
              x_cimv_rec.CREATED_BY,
              x_cimv_rec.CREATION_DATE,
              x_cimv_rec.LAST_UPDATED_BY,
              x_cimv_rec.LAST_UPDATE_DATE,
              x_cimv_rec.LAST_UPDATE_LOGIN;
    IF okc_cimv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    IF (okc_cimv_pk_csr%ROWCOUNT > 1) THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okc_cimv_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF okc_cimv_pk_csr%ISOPEN THEN
        CLOSE okc_cimv_pk_csr;
     END IF;
     RETURN(x_return_status);
  END get_rec_cimv;
---------------------------------------------------------------------------------------
  FUNCTION get_rec_chrv (p_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                         x_chrv_rec  OUT NOCOPY chrv_rec_type)
  RETURN VARCHAR2 IS
    CURSOR okc_chrv_pk_csr(p_id OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           SFWT_FLAG,
           CHR_ID_RESPONSE,
           CHR_ID_AWARD,
           INV_ORGANIZATION_ID,
           STS_CODE,
           QCL_ID,
           SCS_CODE,
           CONTRACT_NUMBER,
           CURRENCY_CODE,
           CONTRACT_NUMBER_MODIFIER,
           ARCHIVED_YN,
           DELETED_YN,
           CUST_PO_NUMBER_REQ_YN,
           PRE_PAY_REQ_YN,
           CUST_PO_NUMBER,
           SHORT_DESCRIPTION,
           COMMENTS,
           DESCRIPTION,
           DPAS_RATING,
           COGNOMEN,
           TEMPLATE_YN,
           TEMPLATE_USED,
           DATE_APPROVED,
           DATETIME_CANCELLED,
           AUTO_RENEW_DAYS,
           DATE_ISSUED,
           DATETIME_RESPONDED,
           NON_RESPONSE_REASON,
           NON_RESPONSE_EXPLAIN,
           RFP_TYPE,
           CHR_TYPE,
           KEEP_ON_MAIL_LIST,
           SET_ASIDE_REASON,
           SET_ASIDE_PERCENT,
           RESPONSE_COPIES_REQ,
           DATE_CLOSE_PROJECTED,
           DATETIME_PROPOSED,
           DATE_SIGNED,
           DATE_TERMINATED,
           DATE_RENEWED,
           TRN_CODE,
           START_DATE,
           END_DATE,
           AUTHORING_ORG_ID,
           BUY_OR_SELL,
           ISSUE_OR_RECEIVE,
           ESTIMATED_AMOUNT,
           ESTIMATED_AMOUNT_RENEWED,
           CURRENCY_CODE_RENEWED,
	   UPG_ORIG_SYSTEM_REF,
           UPG_ORIG_SYSTEM_REF_ID,
           APPLICATION_ID,
           ORIG_SYSTEM_SOURCE_CODE,
           ORIG_SYSTEM_ID1,
           ORIG_SYSTEM_REFERENCE1,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
     FROM okc_k_headers_v chrv
     WHERE chrv.id = p_id;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OPEN okc_chrv_pk_csr (p_id);
    FETCH okc_chrv_pk_csr INTO
          x_chrv_rec.ID,
          x_chrv_rec.OBJECT_VERSION_NUMBER,
          x_chrv_rec.SFWT_FLAG,
          x_chrv_rec.CHR_ID_RESPONSE,
          x_chrv_rec.CHR_ID_AWARD,
          x_chrv_rec.INV_ORGANIZATION_ID,
          x_chrv_rec.STS_CODE,
          x_chrv_rec.QCL_ID,
          x_chrv_rec.SCS_CODE,
          x_chrv_rec.CONTRACT_NUMBER,
          x_chrv_rec.CURRENCY_CODE,
          x_chrv_rec.CONTRACT_NUMBER_MODIFIER,
          x_chrv_rec.ARCHIVED_YN,
          x_chrv_rec.DELETED_YN,
          x_chrv_rec.CUST_PO_NUMBER_REQ_YN,
          x_chrv_rec.PRE_PAY_REQ_YN,
          x_chrv_rec.CUST_PO_NUMBER,
          x_chrv_rec.SHORT_DESCRIPTION,
          x_chrv_rec.COMMENTS,
          x_chrv_rec.DESCRIPTION,
          x_chrv_rec.DPAS_RATING,
          x_chrv_rec.COGNOMEN,
          x_chrv_rec.TEMPLATE_YN,
          x_chrv_rec.TEMPLATE_USED,
          x_chrv_rec.DATE_APPROVED,
          x_chrv_rec.DATETIME_CANCELLED,
          x_chrv_rec.AUTO_RENEW_DAYS,
          x_chrv_rec.DATE_ISSUED,
          x_chrv_rec.DATETIME_RESPONDED,
          x_chrv_rec.NON_RESPONSE_REASON,
          x_chrv_rec.NON_RESPONSE_EXPLAIN,
          x_chrv_rec.RFP_TYPE,
          x_chrv_rec.CHR_TYPE,
          x_chrv_rec.KEEP_ON_MAIL_LIST,
          x_chrv_rec.SET_ASIDE_REASON,
          x_chrv_rec.SET_ASIDE_PERCENT,
          x_chrv_rec.RESPONSE_COPIES_REQ,
          x_chrv_rec.DATE_CLOSE_PROJECTED,
          x_chrv_rec.DATETIME_PROPOSED,
          x_chrv_rec.DATE_SIGNED,
          x_chrv_rec.DATE_TERMINATED,
          x_chrv_rec.DATE_RENEWED,
          x_chrv_rec.TRN_CODE,
          x_chrv_rec.START_DATE,
          x_chrv_rec.END_DATE,
          x_chrv_rec.AUTHORING_ORG_ID,
          x_chrv_rec.BUY_OR_SELL,
          x_chrv_rec.ISSUE_OR_RECEIVE,
          x_chrv_rec.ESTIMATED_AMOUNT,
          x_chrv_rec.ESTIMATED_AMOUNT_RENEWED,
          x_chrv_rec.CURRENCY_CODE_RENEWED,
          x_chrv_rec.UPG_ORIG_SYSTEM_REF,
          x_chrv_rec.UPG_ORIG_SYSTEM_REF_ID,
          x_chrv_rec.APPLICATION_ID,
          x_chrv_rec.ORIG_SYSTEM_SOURCE_CODE,
          x_chrv_rec.ORIG_SYSTEM_ID1,
          x_chrv_rec.ORIG_SYSTEM_REFERENCE1,
          x_chrv_rec.ATTRIBUTE_CATEGORY,
          x_chrv_rec.ATTRIBUTE1,
          x_chrv_rec.ATTRIBUTE2,
          x_chrv_rec.ATTRIBUTE3,
          x_chrv_rec.ATTRIBUTE4,
          x_chrv_rec.ATTRIBUTE5,
          x_chrv_rec.ATTRIBUTE6,
          x_chrv_rec.ATTRIBUTE7,
          x_chrv_rec.ATTRIBUTE8,
          x_chrv_rec.ATTRIBUTE9,
          x_chrv_rec.ATTRIBUTE10,
          x_chrv_rec.ATTRIBUTE11,
          x_chrv_rec.ATTRIBUTE12,
          x_chrv_rec.ATTRIBUTE13,
          x_chrv_rec.ATTRIBUTE14,
          x_chrv_rec.ATTRIBUTE15,
          x_chrv_rec.CREATED_BY,
          x_chrv_rec.CREATION_DATE,
          x_chrv_rec.LAST_UPDATED_BY,
          x_chrv_rec.LAST_UPDATE_DATE,
          x_chrv_rec.LAST_UPDATE_LOGIN;
    IF okc_chrv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okc_chrv_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- if the cursor is open
      IF okc_chrv_pk_csr%ISOPEN THEN
         CLOSE okc_chrv_pk_csr;
      END IF;
      RETURN(x_return_status);
  END get_rec_chrv;
------------------------------------------------------------------------------------------------
  FUNCTION get_rec_clev(p_id       IN OKC_K_LINES_V.ID%TYPE,
                        x_clev_rec OUT NOCOPY clev_rec_type)
  RETURN VARCHAR2 IS
    CURSOR okc_clev_pk_csr (p_cle_id NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           SFWT_FLAG,
           CHR_ID,
           CLE_ID,
           LSE_ID,
           LINE_NUMBER,
           STS_CODE,
           DISPLAY_SEQUENCE,
           TRN_CODE,
           DNZ_CHR_ID,
           COMMENTS,
           ITEM_DESCRIPTION,
           OKE_BOE_DESCRIPTION,
           COGNOMEN,
           HIDDEN_IND,
           PRICE_UNIT,
           PRICE_UNIT_PERCENT,
           PRICE_NEGOTIATED,
           PRICE_NEGOTIATED_RENEWED,
           PRICE_LEVEL_IND,
           INVOICE_LINE_LEVEL_IND,
           DPAS_RATING,
           BLOCK23TEXT,
           EXCEPTION_YN,
           TEMPLATE_USED,
           DATE_TERMINATED,
           NAME,
           START_DATE,
           END_DATE,
           DATE_RENEWED,
           UPG_ORIG_SYSTEM_REF,
           UPG_ORIG_SYSTEM_REF_ID,
           ORIG_SYSTEM_SOURCE_CODE,
           ORIG_SYSTEM_ID1,
           ORIG_SYSTEM_REFERENCE1,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           PRICE_LIST_ID,
           PRICING_DATE,
           PRICE_LIST_LINE_ID,
           LINE_LIST_PRICE,
           ITEM_TO_PRICE_YN,
           PRICE_BASIS_YN,
           CONFIG_HEADER_ID,
           CONFIG_REVISION_NUMBER,
           CONFIG_COMPLETE_YN,
           CONFIG_VALID_YN,
           CONFIG_TOP_MODEL_LINE_ID,
           CONFIG_ITEM_TYPE,
           CONFIG_ITEM_ID ,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           PRICE_TYPE,
           CURRENCY_CODE,
	   CURRENCY_CODE_RENEWED,
           LAST_UPDATE_LOGIN
    FROM Okc_K_Lines_V
    WHERE okc_k_lines_v.id  = p_cle_id;
    l_okc_clev_pk              okc_clev_pk_csr%ROWTYPE;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Get current database values
    OPEN okc_clev_pk_csr (p_id);
    FETCH okc_clev_pk_csr INTO
              x_clev_rec.ID,
              x_clev_rec.OBJECT_VERSION_NUMBER,
              x_clev_rec.SFWT_FLAG,
              x_clev_rec.CHR_ID,
              x_clev_rec.CLE_ID,
              x_clev_rec.LSE_ID,
              x_clev_rec.LINE_NUMBER,
              x_clev_rec.STS_CODE,
              x_clev_rec.DISPLAY_SEQUENCE,
              x_clev_rec.TRN_CODE,
              x_clev_rec.DNZ_CHR_ID,
              x_clev_rec.COMMENTS,
              x_clev_rec.ITEM_DESCRIPTION,
              x_clev_rec.OKE_BOE_DESCRIPTION,
	      x_clev_rec.COGNOMEN,
              x_clev_rec.HIDDEN_IND,
	      x_clev_rec.PRICE_UNIT,
	      x_clev_rec.PRICE_UNIT_PERCENT,
              x_clev_rec.PRICE_NEGOTIATED,
	      x_clev_rec.PRICE_NEGOTIATED_RENEWED,
              x_clev_rec.PRICE_LEVEL_IND,
              x_clev_rec.INVOICE_LINE_LEVEL_IND,
              x_clev_rec.DPAS_RATING,
              x_clev_rec.BLOCK23TEXT,
              x_clev_rec.EXCEPTION_YN,
              x_clev_rec.TEMPLATE_USED,
              x_clev_rec.DATE_TERMINATED,
              x_clev_rec.NAME,
              x_clev_rec.START_DATE,
              x_clev_rec.END_DATE,
	          x_clev_rec.DATE_RENEWED,
              x_clev_rec.UPG_ORIG_SYSTEM_REF,
              x_clev_rec.UPG_ORIG_SYSTEM_REF_ID,
              x_clev_rec.ORIG_SYSTEM_SOURCE_CODE,
              x_clev_rec.ORIG_SYSTEM_ID1,
              x_clev_rec.ORIG_SYSTEM_REFERENCE1,
              x_clev_rec.request_id,
              x_clev_rec.program_application_id,
              x_clev_rec.program_id,
              x_clev_rec.program_update_date,
              x_clev_rec.price_list_id,
              x_clev_rec.pricing_date,
              x_clev_rec.price_list_line_id,
              x_clev_rec.line_list_price,
              x_clev_rec.item_to_price_yn,
              x_clev_rec.price_basis_yn,
              x_clev_rec.config_header_id,
              x_clev_rec.config_revision_number,
              x_clev_rec.config_complete_yn,
              x_clev_rec.config_valid_yn,
              x_clev_rec.config_top_model_line_id,
              x_clev_rec.config_item_type,
              x_clev_rec.CONFIG_ITEM_ID ,
              x_clev_rec.ATTRIBUTE_CATEGORY,
              x_clev_rec.ATTRIBUTE1,
              x_clev_rec.ATTRIBUTE2,
              x_clev_rec.ATTRIBUTE3,
              x_clev_rec.ATTRIBUTE4,
              x_clev_rec.ATTRIBUTE5,
              x_clev_rec.ATTRIBUTE6,
              x_clev_rec.ATTRIBUTE7,
              x_clev_rec.ATTRIBUTE8,
              x_clev_rec.ATTRIBUTE9,
              x_clev_rec.ATTRIBUTE10,
              x_clev_rec.ATTRIBUTE11,
              x_clev_rec.ATTRIBUTE12,
              x_clev_rec.ATTRIBUTE13,
              x_clev_rec.ATTRIBUTE14,
              x_clev_rec.ATTRIBUTE15,
              x_clev_rec.CREATED_BY,
              x_clev_rec.CREATION_DATE,
              x_clev_rec.LAST_UPDATED_BY,
              x_clev_rec.LAST_UPDATE_DATE,
              x_clev_rec.PRICE_TYPE,
              x_clev_rec.CURRENCY_CODE,
	      x_clev_rec.CURRENCY_CODE_RENEWED,
              x_clev_rec.LAST_UPDATE_LOGIN;
    IF  okc_clev_pk_csr%NOTFOUND THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okc_clev_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF okc_clev_pk_csr%ISOPEN THEN
        CLOSE okc_clev_pk_csr;
     END IF;
     RETURN(x_return_status);
  END get_rec_clev;
-----------------------------------------------------------------------------------------------
  FUNCTION get_rec_klev(p_id       IN  OKL_K_LINES_V.ID%TYPE,
                        x_klev_rec OUT NOCOPY klev_rec_type)
  RETURN VARCHAR2 IS
    CURSOR okl_k_lines_v_pk_csr (p_kle_id  OKL_K_LINES_V.ID%TYPE) IS
      SELECT ID,
             OBJECT_VERSION_NUMBER,
             KLE_ID,
             STY_ID,
             PRC_CODE,
             FCG_CODE,
             NTY_CODE,
             ESTIMATED_OEC,
             LAO_AMOUNT,
             TITLE_DATE,
             FEE_CHARGE,
             LRS_PERCENT,
             INITIAL_DIRECT_COST,
             PERCENT_STAKE,
             PERCENT,
             EVERGREEN_PERCENT,
             AMOUNT_STAKE,
             OCCUPANCY,
             COVERAGE,
             RESIDUAL_PERCENTAGE,
             DATE_LAST_INSPECTION,
             DATE_SOLD,
             LRV_AMOUNT,
             CAPITAL_REDUCTION,
             DATE_NEXT_INSPECTION_DUE,
             DATE_RESIDUAL_LAST_REVIEW,
             DATE_LAST_REAMORTISATION,
             VENDOR_ADVANCE_PAID,
             WEIGHTED_AVERAGE_LIFE,
             TRADEIN_AMOUNT,
             BOND_EQUIVALENT_YIELD,
             TERMINATION_PURCHASE_AMOUNT,
             REFINANCE_AMOUNT,
             YEAR_BUILT,
             DELIVERED_DATE,
             CREDIT_TENANT_YN,
             DATE_LAST_CLEANUP,
             YEAR_OF_MANUFACTURE,
             COVERAGE_RATIO,
             REMARKETED_AMOUNT,
             GROSS_SQUARE_FOOTAGE,
             PRESCRIBED_ASSET_YN,
             DATE_REMARKETED,
             NET_RENTABLE,
             REMARKET_MARGIN,
             DATE_LETTER_ACCEPTANCE,
             REPURCHASED_AMOUNT,
             DATE_COMMITMENT_EXPIRATION,
             DATE_REPURCHASED,
             DATE_APPRAISAL,
             RESIDUAL_VALUE,
             APPRAISAL_VALUE,
             SECURED_DEAL_YN,
             GAIN_LOSS,
             FLOOR_AMOUNT,
             RE_LEASE_YN,
             PREVIOUS_CONTRACT,
             TRACKED_RESIDUAL,
             DATE_TITLE_RECEIVED,
             AMOUNT,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             STY_ID_FOR,
             CLG_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             DATE_FUNDING,
             DATE_FUNDING_REQUIRED,
             DATE_ACCEPTED,
             DATE_DELIVERY_EXPECTED,
             OEC,
             CAPITAL_AMOUNT,
             RESIDUAL_GRNTY_AMOUNT,
             RESIDUAL_CODE,
             RVI_PREMIUM,
             CREDIT_NATURE,
             CAPITALIZED_INTEREST,
             CAPITAL_REDUCTION_PERCENT,
             FEE_TYPE
    FROM OKL_K_LINES_V
    WHERE OKL_K_LINES_V.id     = p_kle_id;
    l_okl_k_lines_v_pk         okl_k_lines_v_pk_csr%ROWTYPE;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Get current database values
    OPEN okl_k_lines_v_pk_csr (p_id);
    FETCH okl_k_lines_v_pk_csr INTO
        x_klev_rec.ID,
        x_klev_rec.OBJECT_VERSION_NUMBER,
        x_klev_rec.KLE_ID,
        x_klev_rec.STY_ID,
        x_klev_rec.PRC_CODE,
        x_klev_rec.FCG_CODE,
        x_klev_rec.NTY_CODE,
        x_klev_rec.ESTIMATED_OEC,
        x_klev_rec.LAO_AMOUNT,
        x_klev_rec.TITLE_DATE,
        x_klev_rec.FEE_CHARGE,
        x_klev_rec.LRS_PERCENT,
        x_klev_rec.INITIAL_DIRECT_COST,
        x_klev_rec.PERCENT_STAKE,
        x_klev_rec.PERCENT,
        x_klev_rec.EVERGREEN_PERCENT,
        x_klev_rec.AMOUNT_STAKE,
        x_klev_rec.OCCUPANCY,
        x_klev_rec.COVERAGE,
        x_klev_rec.RESIDUAL_PERCENTAGE,
        x_klev_rec.DATE_LAST_INSPECTION,
        x_klev_rec.DATE_SOLD,
        x_klev_rec.LRV_AMOUNT,
        x_klev_rec.CAPITAL_REDUCTION,
        x_klev_rec.DATE_NEXT_INSPECTION_DUE,
        x_klev_rec.DATE_RESIDUAL_LAST_REVIEW,
        x_klev_rec.DATE_LAST_REAMORTISATION,
        x_klev_rec.VENDOR_ADVANCE_PAID,
        x_klev_rec.WEIGHTED_AVERAGE_LIFE,
        x_klev_rec.TRADEIN_AMOUNT,
        x_klev_rec.BOND_EQUIVALENT_YIELD,
        x_klev_rec.TERMINATION_PURCHASE_AMOUNT,
        x_klev_rec.REFINANCE_AMOUNT,
        x_klev_rec.YEAR_BUILT,
        x_klev_rec.DELIVERED_DATE,
        x_klev_rec.CREDIT_TENANT_YN,
        x_klev_rec.DATE_LAST_CLEANUP,
        x_klev_rec.YEAR_OF_MANUFACTURE,
        x_klev_rec.COVERAGE_RATIO,
        x_klev_rec.REMARKETED_AMOUNT,
        x_klev_rec.GROSS_SQUARE_FOOTAGE,
        x_klev_rec.PRESCRIBED_ASSET_YN,
        x_klev_rec.DATE_REMARKETED,
        x_klev_rec.NET_RENTABLE,
        x_klev_rec.REMARKET_MARGIN,
        x_klev_rec.DATE_LETTER_ACCEPTANCE,
        x_klev_rec.REPURCHASED_AMOUNT,
        x_klev_rec.DATE_COMMITMENT_EXPIRATION,
        x_klev_rec.DATE_REPURCHASED,
        x_klev_rec.DATE_APPRAISAL,
        x_klev_rec.RESIDUAL_VALUE,
        x_klev_rec.APPRAISAL_VALUE,
        x_klev_rec.SECURED_DEAL_YN,
        x_klev_rec.GAIN_LOSS,
        x_klev_rec.FLOOR_AMOUNT,
        x_klev_rec.RE_LEASE_YN,
        x_klev_rec.PREVIOUS_CONTRACT,
        x_klev_rec.TRACKED_RESIDUAL,
        x_klev_rec.DATE_TITLE_RECEIVED,
        x_klev_rec.AMOUNT,
        x_klev_rec.ATTRIBUTE_CATEGORY,
        x_klev_rec.ATTRIBUTE1,
        x_klev_rec.ATTRIBUTE2,
        x_klev_rec.ATTRIBUTE3,
        x_klev_rec.ATTRIBUTE4,
        x_klev_rec.ATTRIBUTE5,
        x_klev_rec.ATTRIBUTE6,
        x_klev_rec.ATTRIBUTE7,
        x_klev_rec.ATTRIBUTE8,
        x_klev_rec.ATTRIBUTE9,
        x_klev_rec.ATTRIBUTE10,
        x_klev_rec.ATTRIBUTE11,
        x_klev_rec.ATTRIBUTE12,
        x_klev_rec.ATTRIBUTE13,
        x_klev_rec.ATTRIBUTE14,
        x_klev_rec.ATTRIBUTE15,
        x_klev_rec.STY_ID_FOR,
        x_klev_rec.CLG_ID,
        x_klev_rec.CREATED_BY,
        x_klev_rec.CREATION_DATE,
        x_klev_rec.LAST_UPDATED_BY,
        x_klev_rec.LAST_UPDATE_DATE,
        x_klev_rec.LAST_UPDATE_LOGIN,
        x_klev_rec.DATE_FUNDING,
        x_klev_rec.DATE_FUNDING_REQUIRED,
        x_klev_rec.DATE_ACCEPTED,
        x_klev_rec.DATE_DELIVERY_EXPECTED,
        x_klev_rec.OEC,
        x_klev_rec.CAPITAL_AMOUNT,
        x_klev_rec.RESIDUAL_GRNTY_AMOUNT,
        x_klev_rec.RESIDUAL_CODE,
        x_klev_rec.RVI_PREMIUM,
        x_klev_rec.CREDIT_NATURE,
        x_klev_rec.CAPITALIZED_INTEREST,
        x_klev_rec.CAPITAL_REDUCTION_PERCENT,
        x_klev_rec.FEE_TYPE;
    IF  okl_k_lines_v_pk_csr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okl_k_lines_v_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF okl_k_lines_v_pk_csr%ISOPEN THEN
        CLOSE okl_k_lines_v_pk_csr;
     END IF;
     RETURN(x_return_status);
  END get_rec_klev;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- RaviKiran Addanki
-- Procedure Name       : check_split_process
-- Description          : Check the completion state of Split Contract.
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE check_split_process (p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2,
                                 x_process_action   OUT NOCOPY VARCHAR2,
                                 x_transaction_id   OUT NOCOPY OKL_TRX_CONTRACTS.ID%TYPE,
                                 x_child_chrid1     OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE,
                                 x_child_chrid2     OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE,
                                 p_contract_id      IN  OKC_K_HEADERS_V.ID%TYPE) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'check_split_process';
    ln_split_contract1       OKC_K_HEADERS_B.ID%TYPE := NULL;
    ln_split_contract2       OKC_K_HEADERS_B.ID%TYPE := NULL;
    ln_transaction_id        OKL_TRX_CONTRACTS.ID%TYPE;
    ln_contract_id           NUMBER := 0;
    lb_value                 BOOLEAN := FALSE;


    -- To check the existence of the contract.
    CURSOR c_get_contract(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKC_K_HEADERS_B
                  WHERE ID = p_chr_id);

    -- To get the transaction created for the contract.
    CURSOR c_get_transaction_id(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT id
    FROM okl_trx_contracts
    WHERE khr_id = p_chr_id
    AND tcn_type = 'SPLC'
   --rkuttiya added for 12.1.1 Multi GAAP
    AND representation_type = 'PRIMARY'
  --
    AND tsu_code IN ('ENTERED','WORKING','WAITING','SUBMITTED');

    -- To get the contracts created during Split process
    CURSOR c_get_split_contracts(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT id
    FROM  okc_k_headers_b
    WHERE orig_system_id1 = p_chr_id
    AND   orig_system_source_code = 'OKL_SPLIT'
    ORDER BY CREATION_DATE;

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;

    IF (p_contract_id = OKL_API.G_MISS_NUM OR p_contract_id IS NULL) THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_HEADERS_B.ID');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;

    -- Validate the Contract ID.
    OPEN  c_get_contract(p_contract_id);
    FETCH c_get_contract INTO ln_contract_id;
    IF c_get_contract%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_INVALID_CONTRACT);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE c_get_contract;

    -- Get the Split transaction Id.
    OPEN  c_get_transaction_id(p_chr_id => p_contract_id);
    FETCH c_get_transaction_id INTO ln_transaction_id;
    IF c_get_transaction_id%FOUND THEN
      FOR r_get_split_contracts IN c_get_split_contracts(p_chr_id => p_contract_id) LOOP
        IF (NOT lb_value) THEN
          ln_split_contract1 := r_get_split_contracts.id;
        END IF;
        IF (lb_value) THEN
          ln_split_contract2 := r_get_split_contracts.id;
        END IF;
        lb_value := TRUE;
      END LOOP;

      IF (ln_split_contract1 IS NULL OR ln_split_contract1 = OKL_API.G_MISS_NUM) AND
         (ln_split_contract2 IS NULL OR ln_split_contract2 = OKL_API.G_MISS_NUM) THEN
        -- Split transaction created with no contracts. Creation of both Split
        -- contracts should be possible.
        x_process_action := 'PROCESS_BOTH';
        x_transaction_id := ln_transaction_id;
        x_return_status := OKL_API.G_RET_STS_SUCCESS;
      ELSIF (ln_split_contract1 IS NOT NULL OR ln_split_contract1 <> OKL_API.G_MISS_NUM) AND
            (ln_split_contract2 IS NULL OR ln_split_contract2 = OKL_API.G_MISS_NUM) THEN
        -- One split contract already got created. Split contract process should
        -- proceed from there.
        x_process_action := 'PROCESS_SECOND';
        x_transaction_id := ln_transaction_id;
        x_child_chrid1 := ln_split_contract1;
        x_return_status := OKL_API.G_RET_STS_SUCCESS;
      ELSIF (ln_split_contract1 IS NOT NULL OR ln_split_contract1 <> OKL_API.G_MISS_NUM) AND
            (ln_split_contract2 IS NOT NULL OR ln_split_contract2 <> OKL_API.G_MISS_NUM) THEN
        -- Both split contracts are created, direct the user to Summary screen.
        x_process_action := 'PROCESS_REVIEW';
        x_transaction_id := ln_transaction_id;
        x_child_chrid1 := ln_split_contract1;
        x_child_chrid2 := ln_split_contract2;
        x_return_status := OKL_API.G_RET_STS_SUCCESS;
      END IF;
    ELSIF c_get_transaction_id%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_TRX_CONTRACTS.ID');
      -- halt validation as it is a required field
      RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    CLOSE c_get_transaction_id;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    IF c_get_transaction_id%ISOPEN THEN
      CLOSE c_get_transaction_id;
    END IF;
    IF c_get_split_contracts%ISOPEN THEN
      CLOSE c_get_split_contracts;
    END IF;
    IF c_get_contract%ISOPEN THEN
      CLOSE c_get_contract;
    END IF;
    x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
    IF c_get_transaction_id%ISOPEN THEN
      CLOSE c_get_transaction_id;
    END IF;
    IF c_get_split_contracts%ISOPEN THEN
      CLOSE c_get_split_contracts;
    END IF;
    IF c_get_contract%ISOPEN THEN
      CLOSE c_get_contract;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END check_split_process;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : l_update_contract_header
-- Description          : Update Contract Header
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE l_update_contract_header(p_api_version        IN  NUMBER,
                                      p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                      x_return_status     OUT NOCOPY VARCHAR2,
                                      x_msg_count         OUT NOCOPY NUMBER,
                                      x_msg_data          OUT NOCOPY VARCHAR2,
                                      p_restricted_update IN  VARCHAR2 DEFAULT 'F',
                                      p_chrv_rec          IN  chrv_rec_type,
                                      p_khrv_rec          IN  khrv_rec_type,
                                      x_chrv_rec          OUT NOCOPY chrv_rec_type,
                                      x_khrv_rec          OUT NOCOPY khrv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'L_UPDATE_CONTRACT_HEADER';
    l_chrv_rec               chrv_rec_type;
    l_khrv_rec               khrv_rec_type;
  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- get rec for Contract Header
    x_return_status := get_rec_chrv(p_id        => p_chrv_rec.id,
                                    x_chrv_rec  => l_chrv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_chrv_rec.orig_system_source_code := 'OKL_SPLIT';
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_CONTRACT_PUB.update_contract_header(p_api_version        => p_api_version,
                                            p_init_msg_list      => p_init_msg_list,
                                            x_return_status      => x_return_status,
                                            x_msg_count          => x_msg_count,
                                            x_msg_data           => x_msg_data,
                                            p_restricted_update  => p_restricted_update,
                                            p_chrv_rec           => l_chrv_rec,
                                            p_khrv_rec           => l_khrv_rec,
                                            x_chrv_rec           => x_chrv_rec,
                                            x_khrv_rec           => x_khrv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END l_update_contract_header;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_chr_cle_id
-- Description          : validation with OKC_K_LINES_V
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_chr_cle_id(p_dnz_chr_id  IN OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                                p_top_line_id IN OKC_K_LINES_V.ID%TYPE,
                                x_return_status OUT NOCOPY VARCHAR2) IS
    ln_dummy      NUMBER := 0;
    CURSOR c_chr_cle_id_validate(p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                                 p_top_line_id OKC_K_LINES_V.ID%TYPE) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT 1
                  FROM OKC_SUBCLASS_TOP_LINE stl,
                       OKC_LINE_STYLES_V lse,
                       OKC_K_LINES_V cle
                  WHERE cle.id = p_top_line_id
                  AND cle.dnz_chr_id = p_dnz_chr_id
                  AND cle.cle_id IS NULL
                  AND cle.chr_id = cle.dnz_chr_id
                  AND cle.lse_id = lse.id
                  AND lse.lty_code = G_FIN_LINE_LTY_CODE
                  AND lse.lse_type = G_TLS_TYPE
                  AND lse.lse_parent_id IS NULL
                  AND lse.id = stl.lse_id
                  AND stl.scs_code IN (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE));
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_dnz_chr_id = OKL_API.G_MISS_NUM OR
       p_dnz_chr_id IS NULL) AND
       (p_top_line_id = OKL_API.G_MISS_NUM OR
       p_top_line_id IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_dnz_chr_id and p_top_line_id');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    ELSIF (p_dnz_chr_id = OKL_API.G_MISS_NUM OR
       p_dnz_chr_id IS NULL) OR
       (p_top_line_id = OKL_API.G_MISS_NUM OR
       p_top_line_id IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_dnz_chr_id and p_top_line_id');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Combination of dnz_chr_id and Top line id should be valid one
    OPEN  c_chr_cle_id_validate(p_dnz_chr_id  => p_dnz_chr_id,
                                p_top_line_id => p_top_line_id);
    IF c_chr_cle_id_validate%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_dnz_chr_id and p_top_line_id');
      -- halt validation as it has no parent record
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_chr_cle_id_validate INTO ln_dummy;
    CLOSE c_chr_cle_id_validate;
    IF (ln_dummy = 0) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_dnz_chr_id and p_top_line_id');
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- If the cursor is open then it has to be closed
    IF c_chr_cle_id_validate%ISOPEN THEN
       CLOSE c_chr_cle_id_validate;
    END IF;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_chr_cle_id_validate%ISOPEN THEN
       CLOSE c_chr_cle_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_chr_cle_id;
----------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_chr_id
-- Description          : validation with OKC_K_LINES_V
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_chr_id(p_chr_id          IN OKC_K_HEADERS_B.ID%TYPE,
                            x_contract_number OUT NOCOPY OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE,
                            x_return_status   OUT NOCOPY VARCHAR2)
  IS
    CURSOR get_k_number(p_chr_id IN OKC_K_HEADERS_B.ID%TYPE)
    IS
    SELECT CHR.contract_number
    FROM OKC_K_HEADERS_B CHR
    WHERE CHR.id = p_chr_id;
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_chr_id = OKL_API.G_MISS_NUM) OR
       (p_chr_id IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_HEADERS_V.ID');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    OPEN  get_k_number(p_chr_id);
    FETCH get_k_number INTO x_contract_number;
    IF get_k_number%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_chr_id');
      -- halt validation as it has no parent record
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE get_k_number;
    IF (x_contract_number IS NULL) OR
       (x_contract_number = OKL_API.G_MISS_CHAR)THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_chr_id');
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- If the cursor is open then it has to be closed
    IF get_k_number%ISOPEN THEN
       CLOSE get_k_number;
    END IF;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF get_k_number%ISOPEN THEN
       CLOSE get_k_number;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_chr_id;
--------------------------------------------------------------------------------------------------
  FUNCTION get_qcl_id(p_chr_id IN  OKC_K_HEADERS_B.ID%TYPE,
                      x_qcl_id OUT NOCOPY NUMBER)
  RETURN  VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    ln_qcl_id   OKC_K_HEADERS_B.QCL_ID%TYPE;
    ln_chr_id   OKC_K_HEADERS_B.ID%TYPE;
    CURSOR get_qcl_id_name(p_qcl_name VARCHAR2) IS
    SELECT id
    FROM okc_qa_check_lists_v
    WHERE name = p_qcl_name;

    CURSOR get_qcl_id_chr (p_chr_id NUMBER) IS
    SELECT NVL(qcl_id,0)
    FROM okc_k_headers_b
    WHERE id  = p_chr_id;
  BEGIN
    OPEN  get_qcl_id_chr(p_chr_id => p_chr_id);
    FETCH get_qcl_id_chr INTO ln_qcl_id;
    IF (get_qcl_id_chr%NOTFOUND) OR
       (ln_qcl_id = 0) THEN
       OPEN  get_qcl_id_name(p_qcl_name => 'OKL LA QA CHECK LIST');
       FETCH get_qcl_id_name INTO ln_qcl_id;
       CLOSE get_qcl_id_name;
    END IF;
    CLOSE get_qcl_id_chr;
    x_qcl_id := ln_qcl_id;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
      IF get_qcl_id_name%ISOPEN THEN
        CLOSE get_qcl_id_name;
      END IF;
      IF get_qcl_id_chr%ISOPEN THEN
        CLOSE get_qcl_id_chr;
      END IF;
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
   END get_qcl_id;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : l_copy_contract_header
-- Description          : Copy of the contract Header
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE l_copy_contract_header(p_api_version          IN  NUMBER,
                                   p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                   x_return_status        OUT NOCOPY VARCHAR2,
                                   x_msg_count            OUT NOCOPY NUMBER,
                                   x_msg_data             OUT NOCOPY VARCHAR2,
                                   p_commit        	  IN  VARCHAR2 DEFAULT 'F',
                                   p_old_chr_id           IN  NUMBER,
                                   p_new_contract_number  IN  VARCHAR2 DEFAULT NULL,
                                   x_new_header_id        OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'LOCAL_COPY_CONTRACT';
  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- TO copy the Copy the contract first
    OKL_COPY_CONTRACT_PUB.copy_contract(p_api_version              => p_api_version,
                                        p_init_msg_list            => p_init_msg_list,
                                        x_return_status            => x_return_status,
                                        x_msg_count                => x_msg_count,
                                        x_msg_data                 => x_msg_data,
                                        p_commit                   => OKL_API.G_FALSE,
                                        p_chr_id                   => p_old_chr_id,
                                        p_contract_number          => p_new_contract_number,
                                        p_contract_number_modifier => NULL,
                                        p_to_template_yn           => 'N',
                                        p_renew_ref_yn             => 'N',
                                        p_copy_lines_yn            => 'N',
                                        p_override_org             => 'N',
                                        x_chr_id                   => x_new_header_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_COPY_HEADER);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_COPY_HEADER);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END l_copy_contract_header;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : l_copy_contract_line
-- Description          : Copy of the contract Line
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE l_copy_contract_line(p_api_version     IN  NUMBER,
                                 p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 p_commit          IN  VARCHAR2 DEFAULT 'F',
                                 p_old_k_top_line  IN  NUMBER,
                                 p_new_header_id   IN  VARCHAR2,
                                 x_new_k_top_id    OUT NOCOPY NUMBER) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'LOCAL_COPY_CONTRACT';
  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now the Copy the Asset lines
    OKL_COPY_ASSET_PUB.COPY_ASSET_LINES(p_api_version        => p_api_version,
                                        p_init_msg_list      => p_init_msg_list,
                                        x_return_status      => x_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data,
                                        P_from_cle_id        => p_old_k_top_line,
                                        p_to_cle_id          => NULL,
                                        p_to_chr_id          => p_new_header_id,
                                        p_to_template_yn     => 'N',
                                        p_copy_reference     => 'COPY',
                                        p_trans_type         => 'CSP',
                                        p_copy_line_party_yn => 'Y',
                                        p_renew_ref_yn       => 'N',
                                        x_cle_id             => x_new_k_top_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END l_copy_contract_line;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : l_delete_contract_line
-- Description          : delete of the contract Line
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE l_delete_contract_line(p_api_version      IN  NUMBER,
                                   p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                   x_return_status    OUT NOCOPY VARCHAR2,
                                   x_msg_count        OUT NOCOPY NUMBER,
                                   x_msg_data         OUT NOCOPY VARCHAR2,
                                   p_contract_id      IN  OKC_K_HEADERS_V.ID%TYPE) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'LOCAL_DEL_CONTRACT_LINE';
    l_chrv_rec               chrv_rec_type;
    l_khrv_rec               khrv_rec_type;
    l_tcnv_rec               OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
    lx_tcnv_rec              OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
    ln_orig_system_id1       OKC_K_HEADERS_B.ORIG_SYSTEM_ID1%TYPE;
    l_stmv_rec               OKL_STREAMS_PUB.stmv_rec_type;
    r_tcnv_rec               OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;

    CURSOR c_get_k_stream(p_khr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT id stm_id
    FROM OKL_STREAMS
    WHERE khr_id = p_khr_id;

    CURSOR c_get_je_trans(p_khr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT id trx_id
    FROM OKL_TRX_CONTRACTS
    WHERE khr_id = p_khr_id
  --rkuttiya added for 12.1.1 Multi GAAP
    AND   representation_type = 'PRIMARY';

    CURSOR c_get_source_id(p_khr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT id
    FROM OKL_TXL_CNTRCT_LNS
    WHERE khr_id = p_khr_id;

    CURSOR c_get_k_top_line(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id top_line
    FROM okc_line_styles_b lse,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.cle_id IS NULL
    AND cle.chr_id = cle.dnz_chr_id
    AND cle.lse_id = lse.id
    AND lse.lse_parent_id IS NULL
    AND lse.lse_type = G_TLS_TYPE;

    -- To get the orig system id for p_chr_id
    CURSOR get_orig_sys_id1(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT orig_system_id1
    FROM okc_k_headers_b
    WHERE id = p_chr_id;

    -- To get status of splited transaction Chr id
    CURSOR get_trx_id(p_org_sys_id OKC_K_HEADERS_B.ORIG_SYSTEM_ID1%TYPE) IS
    SELECT trx.id trx_id
    FROM okl_trx_contracts trx,
         okl_trx_types_tl  try,
         okc_k_headers_b CHR
    WHERE try.name = 'Split Contract'
    AND try.LANGUAGE = 'US'
    AND trx.try_id = try.id
    AND trx.tsu_code = 'ENTERED'
    AND trx.khr_id = CHR.orig_system_id1
    --rkuttiya added for 12.1.1 Multi GAAP Project
    AND trx.representation_type = 'PRIMARY'
    --
    AND CHR.orig_system_source_code = 'OKL_SPLIT'
    AND CHR.orig_system_id1= p_org_sys_id;

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Get the Orig system id1
    OPEN  get_orig_sys_id1(p_chr_id => p_contract_id);
    FETCH get_orig_sys_id1 INTO ln_orig_system_id1;
    IF get_orig_sys_id1%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_chr_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_orig_sys_id1;
    -- get Trx id
    OPEN  get_trx_id(p_org_sys_id => ln_orig_system_id1);
    FETCH get_trx_id INTO l_tcnv_rec.id;
    IF get_trx_id%FOUND THEN
      -- Process the okl_trx_contracts
      l_tcnv_rec.tsu_code := 'CANCELED';
      Okl_Trx_Contracts_Pub.update_trx_contracts(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_tcnv_rec      => l_tcnv_rec,
                            x_tcnv_rec      => lx_tcnv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    CLOSE get_trx_id;
    -- Since we cannot delete contract line which is already booked
    -- So We need to change the status of the contract to INCOMPLETE
    OKL_CONTRACT_STATUS_PUB.update_contract_status(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_khr_status    => 'INCOMPLETE',
                            p_chr_id        => p_contract_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We need to change the status of the Lines for the contract
    OKL_CONTRACT_STATUS_PUB.cascade_lease_status(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_chr_id        => p_contract_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Deleting the Draft journal Entries
    FOR r_get_source_id IN c_get_source_id(p_khr_id => p_contract_id) LOOP
      OKL_ACCOUNT_DIST_PUB.DELETE_ACCT_ENTRIES(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_source_id     => r_get_source_id.id,
                            p_source_table  => 'OKL_TXL_CNTRCT_LNS');
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Deleting the transctions of the journal Entries
    FOR r_get_je_trans IN c_get_je_trans(p_khr_id => p_contract_id) LOOP
      r_tcnv_rec.id := r_get_je_trans.trx_id;
      OKL_TRX_CONTRACTS_PUB.delete_trx_contracts(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_tcnv_rec      => r_tcnv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Delete the streams for the contract
    FOR r_get_k_stream IN c_get_k_stream(p_khr_id => p_contract_id) LOOP
      l_stmv_rec.id := r_get_k_stream.stm_id;
      OKL_STREAMS_PUB.delete_streams(
                              p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_stmv_rec      => l_stmv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Delete the contract lines
    FOR r_get_k_top_line IN c_get_k_top_line(p_dnz_chr_id => p_contract_id) LOOP
      OKL_CONTRACT_PUB.delete_contract_line(
                       p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       p_line_id            => r_get_k_top_line.top_line);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now the Delete the Header
    l_chrv_rec.id := p_contract_id;
    l_khrv_rec.id := p_contract_id;
    OKL_CONTRACT_PUB.delete_contract_header(
                     p_api_version        => p_api_version,
                     p_init_msg_list      => p_init_msg_list,
                     x_return_status      => x_return_status,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     p_chrv_rec           => l_chrv_rec,
                     p_khrv_rec           => l_khrv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    -- since we need to do this beacuse we need to delete to the contract
    COMMIT;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF c_get_k_top_line%ISOPEN THEN
      CLOSE c_get_k_top_line;
    END IF;
    IF get_orig_sys_id1%ISOPEN THEN
      CLOSE get_orig_sys_id1;
    END IF;
    IF get_trx_id%ISOPEN THEN
      CLOSE get_trx_id;
    END IF;
    IF c_get_k_stream%ISOPEN THEN
      CLOSE c_get_k_stream;
    END IF;
    IF c_get_je_trans%ISOPEN THEN
      CLOSE c_get_je_trans;
    END IF;
    IF c_get_source_id%ISOPEN THEN
      CLOSE c_get_source_id;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF c_get_k_top_line%ISOPEN THEN
      CLOSE c_get_k_top_line;
    END IF;
    IF get_orig_sys_id1%ISOPEN THEN
      CLOSE get_orig_sys_id1;
    END IF;
    IF get_trx_id%ISOPEN THEN
      CLOSE get_trx_id;
    END IF;
    IF c_get_k_stream%ISOPEN THEN
      CLOSE c_get_k_stream;
    END IF;
    IF c_get_je_trans%ISOPEN THEN
      CLOSE c_get_je_trans;
    END IF;
    IF c_get_source_id%ISOPEN THEN
      CLOSE c_get_source_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF c_get_k_top_line%ISOPEN THEN
      CLOSE c_get_k_top_line;
    END IF;
    IF get_orig_sys_id1%ISOPEN THEN
      CLOSE get_orig_sys_id1;
    END IF;
    IF get_trx_id%ISOPEN THEN
      CLOSE get_trx_id;
    END IF;
    IF c_get_k_stream%ISOPEN THEN
      CLOSE c_get_k_stream;
    END IF;
    IF c_get_je_trans%ISOPEN THEN
      CLOSE c_get_je_trans;
    END IF;
    IF c_get_source_id%ISOPEN THEN
      CLOSE c_get_source_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END l_delete_contract_line;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- RaviKiran Addanki
-- Procedure Name       : cancel_split_process
-- Description          : Cancel the Split Contract process.
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE cancel_split_process (p_api_version      IN  NUMBER,
                                  p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  x_return_status    OUT NOCOPY VARCHAR2,
                                  x_msg_count        OUT NOCOPY NUMBER,
                                  x_msg_data         OUT NOCOPY VARCHAR2,
                                  p_contract_id      IN  OKC_K_HEADERS_V.ID%TYPE) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'cancel_split_process';
    ln_split_contract1       OKC_K_HEADERS_B.ID%TYPE := NULL;
    ln_split_contract2       OKC_K_HEADERS_B.ID%TYPE := NULL;
    ln_transaction_id        OKL_TRX_CONTRACTS.ID%TYPE;
    ln_contract_id           NUMBER := 0;
    lb_value                 BOOLEAN := FALSE;
    l_tcnv_rec               OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
    lx_tcnv_rec              OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;

    -- To check the existence of the contract.
    CURSOR c_get_contract(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKC_K_HEADERS_B
                  WHERE ID = p_chr_id);

    -- To get the transaction created for the contract.
    CURSOR c_get_trx_id(p_chr_id OKC_K_HEADERS_B.ORIG_SYSTEM_ID1%TYPE) IS
    SELECT trx.id trx_id
    FROM okl_trx_contracts trx,
         okl_trx_types_tl  try
    WHERE try.name = 'Split Contract'
    AND try.LANGUAGE = 'US'
    AND trx.try_id = try.id
    AND trx.tsu_code IN ('ENTERED','WORKING','WAITING','SUBMITTED')
    AND trx.tcn_type = 'SPLC'
   --rkuttiya added for 12.1.1 Multi GAAP
    AND trx.representation_type = 'PRIMARY'
   --
    AND trx.khr_id = p_chr_id;

    -- To get the contracts created during Split process
    CURSOR c_get_split_contracts(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT id
    FROM  okc_k_headers_b
    WHERE orig_system_id1 = p_chr_id
    AND   orig_system_source_code = 'OKL_SPLIT';

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (p_contract_id = OKL_API.G_MISS_NUM OR p_contract_id IS NULL) THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_HEADERS_B.ID');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;

    -- Validate the Contract ID.
    OPEN  c_get_contract(p_contract_id);
    FETCH c_get_contract INTO ln_contract_id;
    IF c_get_contract%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_INVALID_CONTRACT);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE c_get_contract;

    -- Obtain the Split contracts, if they were created during the process.
    FOR r_get_split_contracts IN c_get_split_contracts(p_chr_id => p_contract_id) LOOP
      IF (NOT lb_value) THEN
        ln_split_contract1 := r_get_split_contracts.id;
      END IF;
      IF (lb_value) THEN
        ln_split_contract2 := r_get_split_contracts.id;
      END IF;
      lb_value := TRUE;
    END LOOP;

    IF (ln_split_contract1 IS NULL OR ln_split_contract1 = OKL_API.G_MISS_NUM) AND
       (ln_split_contract2 IS NULL OR ln_split_contract2 = OKL_API.G_MISS_NUM) THEN
      -- Split transaction created with no contracts. Cancel the transaction for
      -- the parent contract
      OPEN  c_get_trx_id(p_chr_id => p_contract_id);
      FETCH c_get_trx_id INTO l_tcnv_rec.id;
      IF c_get_trx_id%FOUND THEN
        -- Cancel the transaction for Split Conntract.
        l_tcnv_rec.tsu_code := 'CANCELED';
        Okl_Trx_Contracts_Pub.update_trx_contracts(
                              p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_tcnv_rec      => l_tcnv_rec,
                              x_tcnv_rec      => lx_tcnv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      CLOSE c_get_trx_id;

    ELSIF (ln_split_contract1 IS NOT NULL OR ln_split_contract1 <> OKL_API.G_MISS_NUM) AND
          (ln_split_contract2 IS NULL OR ln_split_contract2 = OKL_API.G_MISS_NUM) THEN
      -- One split contract already got created. Cancel the transaction and
      -- delete the created split contract.
      l_delete_contract_line(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_contract_id    => ln_split_contract1);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF c_get_trx_id%ISOPEN THEN
      CLOSE c_get_trx_id;
    END IF;
    IF c_get_split_contracts%ISOPEN THEN
      CLOSE c_get_split_contracts;
    END IF;
    IF c_get_contract%ISOPEN THEN
      CLOSE c_get_contract;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF c_get_trx_id%ISOPEN THEN
      CLOSE c_get_trx_id;
    END IF;
    IF c_get_split_contracts%ISOPEN THEN
      CLOSE c_get_split_contracts;
    END IF;
    IF c_get_contract%ISOPEN THEN
      CLOSE c_get_contract;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    IF c_get_trx_id%ISOPEN THEN
      CLOSE c_get_trx_id;
    END IF;
    IF c_get_split_contracts%ISOPEN THEN
      CLOSE c_get_split_contracts;
    END IF;
    IF c_get_contract%ISOPEN THEN
      CLOSE c_get_contract;
    END IF;
    x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
    IF c_get_trx_id%ISOPEN THEN
      CLOSE c_get_trx_id;
    END IF;
    IF c_get_split_contracts%ISOPEN THEN
      CLOSE c_get_split_contracts;
    END IF;
    IF c_get_contract%ISOPEN THEN
      CLOSE c_get_contract;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END cancel_split_process;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- RaviKiran Addanki
-- Procedure Name       : l_delete_fee_service_lines
-- Description          : Deletes service and fee lines not having linked assets
-- Added this as a fix for Bug 3608423
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE l_delete_fee_service_lines(p_api_version      IN  NUMBER,
                                       p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                       x_return_status    OUT NOCOPY VARCHAR2,
                                       x_msg_count        OUT NOCOPY NUMBER,
                                       x_msg_data         OUT NOCOPY VARCHAR2,
                                       p_contract_id      IN  OKC_K_HEADERS_V.ID%TYPE) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'L_DEL_FEE_SERV_LINES';
    l_clev_rec               clev_rec_type;
    l_klev_rec               klev_rec_type;
    lx_clev_rec              clev_rec_type;
    lx_klev_rec              klev_rec_type;

    CURSOR get_fee_service_lines(p_chr_id  OKC_K_HEADERS_B.ID%TYPE)
    IS
    SELECT cle.id id
    FROM   okl_k_lines_v kle,
           okc_k_lines_v cle,
           okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.id = kle.id
    AND cle.lse_id = lse.id
    AND lse.lty_code IN (G_FEE_LINE_LTY_CODE, G_SER_LINE_LTY_CODE)
    AND lse.lse_type = 'TLS'
    AND cle.cle_id IS NULL
    AND cle.id NOT IN (SELECT DISTINCT(cle_sl.cle_id) cle_id
                       FROM okl_k_lines_v kle_sl,
                            okc_k_lines_v cle_sl,
                            okc_line_styles_b lse_sl
                       WHERE cle_sl.dnz_chr_id = p_chr_id
                       AND cle_sl.id = kle_sl.id
                       AND cle_sl.lse_id = lse_sl.id
                       AND lse_sl.lty_code IN (G_FEL_LINE_LTY_CODE, G_SRL_LINE_LTY_CODE));

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Delete all service and fee lines not having linked assets.
    FOR r_get_fee_service_lines IN get_fee_service_lines(p_chr_id => p_contract_id) LOOP
      OKL_CONTRACT_PUB.delete_contract_line(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_line_id       => r_get_fee_service_lines.id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF get_fee_service_lines%ISOPEN THEN
      CLOSE get_fee_service_lines;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF get_fee_service_lines%ISOPEN THEN
      CLOSE get_fee_service_lines;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF get_fee_service_lines%ISOPEN THEN
      CLOSE get_fee_service_lines;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END l_delete_fee_service_lines;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : l_process_split_contract
-- Description          : Process Split Contract
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE l_process_split_contract(p_api_version      IN  NUMBER,
                                     p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2,
                                     p_contract_id      IN  OKC_K_HEADERS_V.ID%TYPE) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'LOCAL_PROCESS_SPLIT_K';
    ln_old_chr_id            OKC_K_HEADERS_B.ID%TYPE;
    ln_dummy                 NUMBER := 0;
    i                        NUMBER := 0;
    j                        NUMBER := 0;
    k                        NUMBER := 0;
    ln_calc_amt              OKL_K_LINES_V.AMOUNT%TYPE := 0;
    ln_old_cap_amt           OKL_K_LINES_V.CAPITAL_AMOUNT%TYPE := 0;
    ln_new_cap_amt           OKL_K_LINES_V.CAPITAL_AMOUNT%TYPE := 0;
    ln_new_service_amt       OKL_K_LINES_V.AMOUNT%TYPE := 0;
    ln_old_service_amt       OKL_K_LINES_V.AMOUNT%TYPE := 0;
    ln_new_init_cost         OKL_K_LINES_V.INITIAL_DIRECT_COST%TYPE := 0;
    ln_period                NUMBER :=0;
    ln_payment_amount        NUMBER :=0;
    ln_sls_payment_amount    NUMBER :=0;
    l_clev_rec               clev_rec_type;
    l_klev_rec               klev_rec_type;
    lx_clev_rec              clev_rec_type;
    lx_klev_rec              klev_rec_type;
    l_rulv_rec               rulv_rec_type;
    lp_rulv_rec              rulv_rec_type;
    lx_rulv_rec              rulv_rec_type;
    r_rulv_rec               rulv_rec_type;
    rx_rulv_rec              rulv_rec_type;

    -- We need to find out weahter we have fee, service, and Usage lines first
    -- so that we can process further

    CURSOR check_other_line(p_chr_id OKC_K_HEADERS_B.ID%TYPE)
    IS
    SELECT '1'
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKC_K_LINES_B cle,
                       OKC_LINE_STYLES_b lse
                  WHERE cle.dnz_chr_id = p_chr_id
                  AND lse.id = cle.lse_id
                  AND lse.lty_code IN (G_SER_LINE_LTY_CODE,
                                       G_SRL_LINE_LTY_CODE,
                                       G_FEE_LINE_LTY_CODE,
                                       G_FEL_LINE_LTY_CODE,
                                       G_USG_LINE_LTY_CODE,
                                       G_USL_LINE_LTY_CODE));

    -- To get the orig system id for p_chr_id
    CURSOR get_orig_sys_id1(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT orig_system_id1
    FROM okc_k_headers_b
    WHERE id = p_chr_id;

    /*CURSOR get_asset_info(p_chr_id  OKC_K_HEADERS_B.ID%TYPE)
    IS
    SELECT sum(cle.capital_amount) total_capital_amount
    FROM okl_k_lines_full_v cle,
         okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_FIN_LINE_LTY_CODE
    AND lse.lse_type = G_TLS_TYPE;*/

    -- rravikir added for bug 3504415
    -- Get the top fee lines which are not having any assets link attached to it
    CURSOR get_item_info_tls(p_dnz_chr_Id   OKC_K_HEADERS_V.ID%TYPE)
    IS
    select tcle.id id
    from okc_k_items tcim,
         okc_k_lines_b tcle,
         okc_line_styles_b lse
    where tcim.dnz_chr_id = p_dnz_chr_id
    and tcle.lse_id = lse.id
    and tcim.cle_id = tcle.id
    and tcim.dnz_chr_id = tcle.dnz_chr_id
    and lse.lty_code in (G_FEE_LINE_LTY_CODE, G_SER_LINE_LTY_CODE)
    and exists (select 1
                from okc_k_items cim,
                     okc_k_lines_b cle
                where cim.dnz_chr_id = p_dnz_chr_id
                and cle.cle_id = tcle.id
                and cim.cle_id = cle.id
                and cim.jtot_object1_code = 'OKX_COVASST'
                and not exists
                    (select 1
                     from okc_k_lines_b cle,
                          okc_line_styles_b lse
                     where cle.dnz_chr_id = p_dnz_chr_id
                     and cle.lse_id = lse.id
                     and lse.lty_code in (G_FIN_LINE_LTY_CODE, G_SER_LINE_LTY_CODE)
                     and lse.lse_type = G_TLS_TYPE
                     and cle.id = cim.object1_id1))
    and not exists
    (select 1
     from okc_k_lines_b cle,
          okc_line_styles_b lse
     where cle.dnz_chr_id = p_dnz_chr_id
     and cle.lse_id = lse.id
     and lse.lty_code in (G_FIN_LINE_LTY_CODE, G_SER_LINE_LTY_CODE)
     and lse.lse_type = G_TLS_TYPE
     and exists(select 1
                from okc_k_lines_b scle,
                     okc_k_items scim
                where scle.id = scim.cle_id -- sub line join with item
                and scim.dnz_chr_id = p_dnz_chr_id
                and scim.dnz_chr_id = tcle.dnz_chr_id
                and scle.cle_id = tcle.id -- fee top line join
                and scim.object1_id1 = cle.id));

    -- Get the fee links which are not corresponding to this contract
    CURSOR get_item_info(p_dnz_chr_Id   OKC_K_HEADERS_V.ID%TYPE)
    IS
    SELECT DISTINCT(cle.id) id
    FROM okl_k_lines_full_v cle,
         okc_k_items cim
    WHERE cle.dnz_chr_id = p_dnz_chr_Id
    AND cle.id = cim.cle_id
    AND cim.jtot_object1_code = 'OKX_COVASST'
    AND cim.object1_id1 NOT IN (SELECT cle.id
                                FROM okc_k_lines_b cle,
                                     okc_line_styles_b lse
                                WHERE cle.dnz_chr_id = p_dnz_chr_Id
                                AND cle.lse_id = lse.id
                                AND lse.lty_code IN (G_FIN_LINE_LTY_CODE, G_SER_LINE_LTY_CODE)
                                AND lse.lse_type = G_TLS_TYPE);
    -- end rravikir added for bug 3504415

    -- rravikir commented for bug 3504415
/*    CURSOR get_item_info_tls(p_dnz_chr_Id   OKC_K_HEADERS_V.ID%TYPE)
    IS
    SELECT cle.cle_id fee_top_line_id, cim.cle_id linked_asset_id
    FROM okc_k_items cim,
         okc_k_lines_b cle
    WHERE cim.dnz_chr_id = p_dnz_chr_Id
    AND cim.cle_id = cle.id
    AND cim.dnz_chr_id = cle.dnz_chr_id
    AND cim.jtot_object1_code = 'OKX_COVASST'
    AND cim.object1_id1 not in (SELECT cle.id
                                FROM okc_k_lines_b cle,
                                     okc_line_styles_b lse
                                WHERE cle.dnz_chr_id = p_dnz_chr_Id
                                AND cle.lse_id = lse.id
                                AND lse.lty_code = G_FIN_LINE_LTY_CODE
                                AND lse.lse_type = G_TLS_TYPE);

    CURSOR get_item_info(p_dnz_chr_Id   OKC_K_HEADERS_V.ID%TYPE)
    IS
    SELECT cim.cle_id cle_id
    FROM okc_k_items cim
    WHERE cim.dnz_chr_id = p_dnz_chr_Id
    AND cim.jtot_object1_code = 'OKX_COVASST'
    AND cim.object1_id1 not in (SELECT cle.id
                                FROM okc_k_lines_b cle,
                                     okc_line_styles_b lse
                                WHERE cle.dnz_chr_id = p_dnz_chr_Id
                                AND cle.lse_id = lse.id
                                AND lse.lty_code = G_FIN_LINE_LTY_CODE
                                AND lse.lse_type = G_TLS_TYPE);*/
    -- end rravikir commented for bug 3504415

    -- rravikir commented for bug
    /*CURSOR get_amt(p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT nvl(kle.amount,0) amount,
           nvl(kle.initial_direct_cost,0) initial_direct_cost,
           cle.id id
    FROM okl_k_lines_v kle,
         okc_k_lines_v cle,
         okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.id = kle.id
    AND cle.lse_id = lse.id
    AND lse.lty_code in (G_SER_LINE_LTY_CODE,G_FEE_LINE_LTY_CODE)
    AND lse.lse_type  = G_TLS_TYPE
    AND cle.cle_id IS NULL;*/
    -- end rravikir commented for bug

    -- New Cursor for Bug 3608423
    CURSOR get_amt(p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT DISTINCT(cle.id) id,
           NVL(kle.amount,0) amount,
           NVL(kle.initial_direct_cost,0) initial_direct_cost
    FROM okl_k_lines_v kle_sl,
         okc_k_lines_v cle_sl,
         okc_line_styles_b lse_sl,
         okl_k_lines_v kle,
         okc_k_lines_v cle,
         okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.id = kle.id
    AND cle.lse_id = lse.id
    AND lse.lty_code IN (G_SER_LINE_LTY_CODE,G_FEE_LINE_LTY_CODE)
    AND lse.lse_type  = G_TLS_TYPE
    AND cle.cle_id IS NULL
    AND cle.id = cle_sl.cle_id
    AND cle_sl.id = kle_sl.id
    AND cle_sl.lse_id = lse_sl.id
    AND lse_sl.lty_code IN (G_SRL_LINE_LTY_CODE,G_FEL_LINE_LTY_CODE);
    -- End New Cursor for Bug 3608423

    -- New Cursor to get the sum of capital amount of all capitalized link assets
    CURSOR get_cap_link_asset_amount(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE)
    IS
    SELECT SUM(kle.CAPITAL_AMOUNT)
    FROM   okl_k_lines_v kle,
           okc_line_styles_b lse,
           okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND cle.id = kle.id
    AND cle.lse_id = lse.id
    AND lse.lty_code IN (G_SRL_LINE_LTY_CODE,G_FEL_LINE_LTY_CODE);
    -- End New Cursor for Bug 3608423

    /*CURSOR get_sls_amt(p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT sum(nvl(kle_sl.capital_amount,0)) amount,
           cle.id id,
           cle.orig_system_id1 orig_system_id1
    FROM okl_k_lines_v kle_sl,
         okc_k_lines_v cle_sl,
         okc_line_styles_b lse_sl,
         okl_k_lines_v kle,
         okc_k_lines_v cle,
         okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.id = kle.id
    AND cle.lse_id = lse.id
    AND lse.lty_code in (G_SER_LINE_LTY_CODE,G_FEE_LINE_LTY_CODE)
    AND lse.lse_type  = G_TLS_TYPE
    AND cle.cle_id IS NULL
    AND cle.id = cle_sl.cle_id
    and cle_sl.id = kle_sl.id
    AND cle_sl.lse_id = lse_sl.id
    AND lse_sl.lty_code in (G_SRL_LINE_LTY_CODE,G_FEL_LINE_LTY_CODE)
    group by cle.id,
             cle.orig_system_id1;*/

    /*CURSOR get_rule_pymt(p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                         p_cle_id OKC_K_LINES_V.ID%TYPE)
    IS
    SELECT rl.id,
           rl.rule_information6 payment_amount,
           rl.rule_information2 rl_date
    FROM okc_rule_groups_b rg,
         okc_rules_b rl,
         okc_k_lines_v cle,
         okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.id = p_cle_id
    AND cle.lse_id = lse.id
    AND lse.lty_code in (G_SER_LINE_LTY_CODE,G_FEE_LINE_LTY_CODE)
    AND lse.lse_type  = G_TLS_TYPE
    AND cle.cle_id IS NULL
    AND rg.dnz_chr_id = cle.dnz_chr_id
    AND rg.cle_id = cle.id
    AND rg.chr_id IS NULL
    AND rg.id = rl.rgp_id
    AND rg.rgd_code = 'LALEVL'
    AND rl.rule_information_category = 'LASLL'
    AND not exists (SELECT '1'
                    FROM okc_k_lines_v cle_sl,
                         okc_line_styles_b lse_sl
                    WHERE cle_sl.dnz_chr_id = p_chr_id
                    AND cle_sl.cle_id  = cle.id
                    AND cle_sl.lse_id = lse_sl.id
                    AND lse_sl.lty_code in (G_SRL_LINE_LTY_CODE,G_FEL_LINE_LTY_CODE));*/

    /*CURSOR get_sls_rule_pymt(p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                             p_cle_id OKC_K_LINES_V.ID%TYPE)
    IS
    SELECT rl.id,
           rl.rule_information6 payment_amount
    FROM okc_rule_groups_b rg,
         okc_rules_b rl,
         okc_k_lines_v cle,
         okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.id = p_cle_id
    AND cle.lse_id = lse.id
    AND lse.lty_code in (G_SER_LINE_LTY_CODE,G_FEE_LINE_LTY_CODE)
    AND lse.lse_type  = G_TLS_TYPE
    AND cle.cle_id IS NULL
    AND rg.dnz_chr_id = cle.dnz_chr_id
    AND rg.cle_id = cle.id
    AND rg.chr_id IS NULL
    AND rg.id = rl.rgp_id
    AND rg.rgd_code = 'LALEVL'
    AND rl.rule_information_category = 'LASLL'
    AND exists (SELECT '1'
                    FROM okc_k_lines_v cle_sl,
                         okc_line_styles_b lse_sl
                    WHERE cle_sl.dnz_chr_id = p_chr_id
                    AND cle_sl.cle_id  = cle.id
                    AND cle_sl.lse_id = lse_sl.id
                    AND lse_sl.lty_code in (G_SRL_LINE_LTY_CODE,G_FEL_LINE_LTY_CODE));*/

    -- Get the rule that applies to service line
    CURSOR get_service_rule_info(p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                                 p_cle_id OKC_K_LINES_V.ID%TYPE)
    IS
    SELECT  rl.id,
            cle.currency_code
    FROM okc_rule_groups_b rg,
         okc_rules_b rl,
         okc_k_lines_v cle,
         okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.id = p_cle_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_SER_LINE_LTY_CODE
    AND lse.lse_type  = G_TLS_TYPE
    AND cle.cle_id IS NULL
    AND rg.dnz_chr_id = cle.dnz_chr_id
    AND rg.cle_id = cle.id
    AND rg.chr_id IS NULL
    AND rg.id = rl.rgp_id
    AND rg.rgd_code = 'LAFEXP'
    AND rl.rule_information_category = 'LAFEXP';

    CURSOR get_expense_service_rule_info( p_rgd_code OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                                          p_rgp_cat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                                          p_chr_id NUMBER,
                                          p_cle_id NUMBER ) IS
    SELECT crl.RULE_INFORMATION1,
           crl.RULE_INFORMATION2
    FROM   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl
    WHERE  crl.rgp_id = crg.id
           AND crg.RGD_CODE = p_rgd_code
           AND crl.RULE_INFORMATION_CATEGORY = p_rgp_cat
           AND crg.dnz_chr_id = p_chr_id
           AND NVL(crg.cle_id,-1) = p_cle_id;

    CURSOR get_service_lines(p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT cle.id id,
           NVL(kle.amount,0) amount
    FROM okl_k_lines_v kle,
         okc_k_lines_v cle,
         okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.id = kle.id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_SER_LINE_LTY_CODE
    AND lse.lse_type  = G_TLS_TYPE
    AND cle.cle_id IS NULL;

    CURSOR get_old_service_lines(p_new_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                                 p_old_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                                 p_new_cle_id OKL_K_LINES_V.ID%TYPE)
    IS
    SELECT cle.id id,
           NVL(kle.amount,0) amount
    FROM okl_k_lines_v kle,
         okc_k_lines_v cle,
         okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_old_chr_id
    AND cle.id = kle.id
    AND cle.lse_id = lse.id
    AND lse.lty_code = 'SOLD_SERVICE'
    AND lse.lse_type  = 'TLS'
    AND cle.cle_id IS NULL
    AND cle.id = (SELECT klfv.ORIG_SYSTEM_ID1
                  FROM okl_k_lines_full_v klfv
                  WHERE klfv.id = p_new_cle_id
                  AND klfv.dnz_chr_id = p_new_chr_id);


    CURSOR get_service_line_payments( p_rgd_code OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                                      p_rgp_cat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                                      p_chr_id NUMBER,
                                      p_cle_id NUMBER ) IS
    SELECT  rl.id,
            rl.rule_information2,
            rl.rule_information3,
            rl.rule_information6,
            rl.rule_information7,
            rl.rule_information8,
            cle.currency_code
    FROM okc_rule_groups_b rg,
         okc_rules_b rl,
         okc_k_lines_v cle,
         okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.id = p_cle_id
    AND cle.lse_id = lse.id
    AND cle.cle_id IS NULL
    AND rg.dnz_chr_id = cle.dnz_chr_id
    AND rg.cle_id = cle.id
    AND rg.id = rl.rgp_id
    AND rg.rgd_code = p_rgd_code
    AND rl.rule_information_category = p_rgp_cat;

    /*SELECT crl.id,
           crl.RULE_INFORMATION3,
           crl.RULE_INFORMATION6
    FROM   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl
    WHERE  crl.rgp_id = crg.id
           and crg.RGD_CODE = p_rgd_code
           and crl.RULE_INFORMATION_CATEGORY = p_rgp_cat
           and crg.dnz_chr_id = p_chr_id
           and nvl(crg.cle_id,-1) = p_cle_id;  */

    ln_old_line_id OKL_K_LINES_V.ID%TYPE;
    ln_service_line_id OKL_K_LINES_V.ID%TYPE;
    ln_rule_amount OKC_RULES_V.RULE_INFORMATION2%TYPE;
    ln_rule_id      OKC_RULES_V.ID%TYPE;
    lv_num_periods  OKC_RULES_V.RULE_INFORMATION1%TYPE;
    lv_currency_code  OKC_K_LINES_V.CURRENCY_CODE%TYPE;
    ln_rule_info_3  OKC_RULES_V.RULE_INFORMATION3%TYPE;
    ln_rule_info_6  OKC_RULES_V.RULE_INFORMATION6%TYPE;
    ln_rule_info_2  OKC_RULES_V.RULE_INFORMATION2%TYPE;
    ln_rule_info_7  OKC_RULES_V.RULE_INFORMATION7%TYPE;
    ln_rule_info_8  OKC_RULES_V.RULE_INFORMATION8%TYPE;
    -- end rravikir added for bug 3504415

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN  check_other_line(p_chr_id => p_contract_id);
    FETCH check_other_line INTO ln_dummy;
    CLOSE check_other_line;

    IF ln_dummy = 1 THEN
      OPEN  get_orig_sys_id1(p_contract_id);
      FETCH get_orig_sys_id1 INTO ln_old_chr_id;
      CLOSE get_orig_sys_id1;

      -- get the new information
      /*OPEN  get_asset_info(p_chr_id => p_contract_id);
      FETCH get_asset_info INTO ln_new_cap_amt;
      CLOSE get_asset_info;*/

      -- rravikir modified for bug 3504415
      -- Top lines which are not having associated asset links for this contract
      -- are deleted first and then the actual links are deleted

      -- Delete the Top lines which do have any assets linked to that
      FOR r_get_item_info_tls IN get_item_info_tls(p_dnz_chr_id => p_contract_id) LOOP
        OKL_CONTRACT_PUB.delete_contract_line(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_line_id       => r_get_item_info_tls.id);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
      END LOOP;

      IF (G_DEBUG_SPLIT) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Fee/Service Top lines deletion when
            assets not linked finished with ' || x_return_status || ' in
            l_process_split_contract procedure');
        IF (x_return_status <> 'S') THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Information : ' || x_msg_data);
        END IF;
      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Delete links which are not needed since the assets do not belong this contract
      FOR r_get_item_info IN get_item_info(p_dnz_chr_id => p_contract_id) LOOP
        OKL_CONTRACT_PUB.delete_contract_line(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_line_id       => r_get_item_info.id);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
      END LOOP;

      IF (G_DEBUG_SPLIT) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Fee/Service child links deletion
            finished with ' || x_return_status || ' in
            l_process_split_contract procedure');
        IF (x_return_status <> 'S') THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Information : ' || x_msg_data);
        END IF;
      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- end rravikir modified for bug 3504415

      FOR r_get_amt IN get_amt(p_chr_id => p_contract_id) LOOP
        ln_new_cap_amt := NULL;

      -- Commented for Bug 3608423
      /*  IF r_get_amt.amount <> 0 AND
           ln_new_cap_amt <> 0 AND
           ln_old_cap_amt <> 0 THEN
          ln_new_amt := ln_new_cap_amt * r_get_amt.amount/ln_old_cap_amt;
        END IF;
        IF r_get_amt.initial_direct_cost <> 0 AND
           ln_new_cap_amt <> 0 AND
           ln_old_cap_amt <> 0  THEN
           ln_new_init_cost := ln_new_cap_amt * r_get_amt.initial_direct_cost/ln_old_cap_amt;
        END IF;*/

        -- To Get the cle addon Line Record
        x_return_status := get_rec_clev(r_get_amt.id,
                                        l_clev_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        -- To Get the kle Model Line Record
        x_return_status := get_rec_klev(r_get_amt.id,
                                        l_klev_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        IF l_klev_rec.id <> l_clev_rec.id THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

        -- Added for Bug 3608423
        OPEN  get_cap_link_asset_amount(p_cle_id => l_clev_rec.id);
        FETCH get_cap_link_asset_amount INTO ln_new_cap_amt;
        CLOSE get_cap_link_asset_amount;

        l_klev_rec.amount := ln_new_cap_amt;
        l_klev_rec.capital_amount := ln_new_cap_amt;
        -- End for Bug 3608423

        OKL_CONTRACT_PUB.update_contract_line(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_clev_rec      => l_clev_rec,
                         p_klev_rec      => l_klev_rec,
                         x_clev_rec      => lx_clev_rec,
                         x_klev_rec      => lx_klev_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
      END LOOP;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Get all the service lines having both expense and associated assets
      -- Proportionate the amount in the expense rule
      FOR r_get_service_lines IN get_service_lines(p_chr_id => p_contract_id) LOOP

        -- Get the old service line amount to proporationate the amounts
        OPEN  get_old_service_lines(p_new_chr_id => p_contract_id,
                                    p_old_chr_id => ln_old_chr_id,
                                    p_new_cle_id => r_get_service_lines.id);
        FETCH get_old_service_lines INTO ln_old_line_id, ln_old_service_amt;
        CLOSE get_old_service_lines;

        FOR r_get_service_rule_info IN get_service_rule_info(p_chr_id => p_contract_id,
                                                             p_cle_id => r_get_service_lines.id) LOOP
          ln_rule_id := r_get_service_rule_info.id;
          lv_currency_code := r_get_service_rule_info.currency_code;
          ln_service_line_id := r_get_service_lines.id;
          ln_new_service_amt := r_get_service_lines.amount;

          IF (ln_rule_id <> OKL_API.G_MISS_NUM) AND
             (ln_rule_id IS NOT NULL) THEN

            OPEN  get_expense_service_rule_info(p_rgd_code => 'LAFEXP',
                                                p_rgp_cat  => 'LAFEXP',
                                                p_chr_id => p_contract_id,
                                                p_cle_id => ln_service_line_id);
            FETCH get_expense_service_rule_info INTO lv_num_periods, ln_rule_amount;
            CLOSE get_expense_service_rule_info;

            /*IF (lv_num_periods <> OKL_API.G_MISS_CHAR) AND
               (lv_num_periods IS NOT NULL) THEN
              ln_new_amt := ln_new_amt / lv_num_periods;
            END IF;*/

            ln_calc_amt := (ln_new_service_amt/ln_old_service_amt) * ln_rule_amount;

            -- Get the correct rounding amount
            ln_calc_amt := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(ln_calc_amt,
                                                            lv_currency_code);

            l_rulv_rec.id := ln_rule_id;
            l_rulv_rec.rule_information2 := ln_calc_amt;

            OKL_RULE_PUB.update_rule(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_rulv_rec      => l_rulv_rec,
                         x_rulv_rec      => lx_rulv_rec);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
            END IF;
          END IF;
        END LOOP;
      END LOOP;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Get the payments defined for service line
      -- Proportionate the amount
      FOR r_get_service_lines IN get_service_lines(p_chr_id => p_contract_id) LOOP

        -- Get the old service line amount to proporationate the amounts
        OPEN  get_old_service_lines(p_new_chr_id => p_contract_id,
                                    p_old_chr_id => ln_old_chr_id,
                                    p_new_cle_id => r_get_service_lines.id);
        FETCH get_old_service_lines INTO ln_old_line_id, ln_old_service_amt;
        CLOSE get_old_service_lines;

        FOR r_get_service_line_payments IN get_service_line_payments(p_rgd_code => 'LALEVL',
                                                                     p_rgp_cat  => 'LASLL',
                                                                     p_chr_id => p_contract_id,
                                                                     p_cle_id => r_get_service_lines.id) LOOP
          ln_rule_id := r_get_service_line_payments.id;
          lv_currency_code := r_get_service_line_payments.currency_code;
          ln_service_line_id := r_get_service_lines.id;
          ln_new_service_amt := r_get_service_lines.amount;
          ln_rule_info_3 := r_get_service_line_payments.rule_information3;
          ln_rule_info_6 := r_get_service_line_payments.rule_information6;
          ln_rule_info_2 := r_get_service_line_payments.rule_information2;
          ln_rule_info_7 := r_get_service_line_payments.rule_information7;
          ln_rule_info_8 := r_get_service_line_payments.rule_information8;

          IF (ln_rule_id <> OKL_API.G_MISS_NUM) AND
             (ln_rule_id IS NOT NULL) THEN

            IF (ln_rule_info_6 <> OKL_API.G_MISS_CHAR) AND
               (ln_rule_info_6 IS NOT NULL) THEN

              ln_calc_amt := (ln_new_service_amt/ln_old_service_amt) * ln_rule_info_6;
              -- Get the correct rounding amount
              ln_calc_amt := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(ln_calc_amt,
                                                            lv_currency_code);

              lp_rulv_rec.id := ln_rule_id;
              lp_rulv_rec.rule_information6 := ln_calc_amt;
              lp_rulv_rec.rule_information2 := ln_rule_info_2;
              lp_rulv_rec.rule_information8 := NULL;
            ELSIF (ln_rule_info_8 <> OKL_API.G_MISS_CHAR) AND
                  (ln_rule_info_8 IS NOT NULL) THEN

              ln_calc_amt := (ln_new_service_amt/ln_old_service_amt) * ln_rule_info_8;
              -- Get the correct rounding amount
              ln_calc_amt := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(ln_calc_amt,
                                                            lv_currency_code);

              lp_rulv_rec.id := ln_rule_id;
              lp_rulv_rec.rule_information8 := ln_calc_amt;
              lp_rulv_rec.rule_information2 := ln_rule_info_2;
              lp_rulv_rec.rule_information6 := NULL;
            END IF;

            OKL_RULE_PUB.update_rule(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_rulv_rec      => lp_rulv_rec,
                         x_rulv_rec      => lx_rulv_rec);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
            END IF;
          END IF;
        END LOOP;
      END LOOP;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;


       -- Commented for Bug 3608423
        -- rravikir added for bug 3504415
        -- Get the rule (applies to 'EXPENSE', 'MISCLLANEOUS' 'FINANCE' fee types)
        -- id and update the amount
      /*  OPEN  get_rule_pymt1(p_chr_id => p_contract_id,
                             p_cle_id => l_clev_rec.id);
        FETCH get_rule_pymt1 INTO ln_rule_id, lv_currency_code;
        CLOSE get_rule_pymt1;

        IF (ln_rule_id <> OKL_API.G_MISS_NUM) AND
           (ln_rule_id IS NOT NULL) THEN

          OPEN  get_rule_periods(p_rgd_code => 'LAFEXP',
                                 p_rgp_cat  => 'LAFEXP',
                                 p_chr_id => p_contract_id,
                                 p_cle_id => l_clev_rec.id);
          FETCH get_rule_periods INTO lv_num_periods;
          CLOSE get_rule_periods;

          IF (lv_num_periods <> OKL_API.G_MISS_CHAR) AND
             (lv_num_periods IS NOT NULL) THEN
            ln_new_amt := ln_new_amt / lv_num_periods;
          END IF;

          -- Get the correct rounding amount
          ln_new_amt := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(ln_new_amt,
                                                            lv_currency_code);

          l_rulv_rec.id := ln_rule_id;
          l_rulv_rec.rule_information2 := ln_new_amt;

          OKL_RULE_PUB.update_rule(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_rulv_rec      => l_rulv_rec,
                         x_rulv_rec      => lx_rulv_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
        END IF;
        -- end rravikir added for bug 3504415

        -- We need to pro-rate the payment amount of top service or fee line
        FOR r_get_rule_pymt IN get_rule_pymt(p_chr_id => p_contract_id,
                                             p_cle_id => r_get_amt.id) LOOP
          ln_payment_amount := r_get_rule_pymt.payment_amount * ln_new_cap_amt/ln_old_cap_amt;
          l_rulv_rec.id := r_get_rule_pymt.id;
          l_rulv_rec.rule_information6 := ln_payment_amount;
          l_rulv_rec.rule_information2 := r_get_rule_pymt.rl_date;
          OKL_RULE_PUB.update_rule(
                       p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_rulv_rec      => l_rulv_rec,
                       x_rulv_rec      => lx_rulv_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
        END LOOP;
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

      -- Get the amount of the old contract
      FOR r_get_sls_amt IN get_sls_amt(p_chr_id => ln_old_chr_id) LOOP
        -- we need the fee or service lines id.
        lt_old_cle_amt_tbl(k).cle_id      := r_get_sls_amt.id;
        lt_old_cle_amt_tbl(k).amount      := r_get_sls_amt.amount;
        lt_old_cle_amt_tbl(k).orig_cle_id := r_get_sls_amt.orig_system_id1;
        k := k + 1;
      END LOOP;
      -- Summing up amount of the sub lines populating Amount and Capital amount
      FOR r_get_sls_amt IN get_sls_amt(p_chr_id => p_contract_id) LOOP
        -- To Get the cle Line Record
        x_return_status := get_rec_clev(r_get_sls_amt.id,
                                        l_clev_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        -- To Get the kle Model Line Record
        x_return_status := get_rec_klev(r_get_sls_amt.id,
                                        l_klev_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        IF l_klev_rec.id <> l_clev_rec.id THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        l_klev_rec.amount := r_get_sls_amt.amount;
        l_klev_rec.capital_amount := r_get_sls_amt.amount;

        OKL_CONTRACT_PUB.update_contract_line(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_clev_rec      => l_clev_rec,
                         p_klev_rec      => l_klev_rec,
                         x_clev_rec      => lx_clev_rec,
                         x_klev_rec      => lx_klev_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        -- We need to pro-rate the payment amount of sub service or fee line
        IF lt_old_cle_amt_tbl.COUNT > 0 THEN
          k := lt_old_cle_amt_tbl.FIRST;
          LOOP
            IF lt_old_cle_amt_tbl(k).cle_id = l_clev_rec.orig_system_id1 THEN
              FOR r_get_sls_rule_pymt IN get_sls_rule_pymt(p_chr_id => p_contract_id,
                                                           p_cle_id => l_clev_rec.id) LOOP
                ln_sls_payment_amount := r_get_sls_rule_pymt.payment_amount * l_klev_rec.amount/lt_old_cle_amt_tbl(k).amount;
                r_rulv_rec.id := r_get_sls_rule_pymt.id;
                r_rulv_rec.rule_information6 := ln_sls_payment_amount;
                OKL_RULE_PUB.update_rule(
                             p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_rulv_rec      => r_rulv_rec,
                             x_rulv_rec      => rx_rulv_rec);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
                END IF;
              END LOOP;
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
              END IF;
            END IF;
            EXIT WHEN (k = lt_old_cle_amt_tbl.LAST);
            k := lt_old_cle_amt_tbl.NEXT(k);
          END LOOP;
        END IF;
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;*/
    -- End Commented for Bug 3608423

    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF get_amt%ISOPEN THEN
      CLOSE get_amt;
    END IF;
    IF get_item_info%ISOPEN THEN
      CLOSE get_item_info;
    END IF;
    /*IF get_asset_info%ISOPEN THEN
      CLOSE get_asset_info;
    END IF;*/
    IF get_orig_sys_id1%ISOPEN THEN
      CLOSE get_orig_sys_id1;
    END IF;
    IF check_other_line%ISOPEN THEN
      CLOSE check_other_line;
    END IF;
    /*IF get_sls_rule_pymt%ISOPEN THEN
      CLOSE get_sls_rule_pymt;
    END IF;*/
    /*IF get_rule_pymt%ISOPEN THEN
      CLOSE get_rule_pymt;
    END IF;*/
    /*IF get_sls_amt%ISOPEN THEN
      CLOSE get_sls_amt;
    END IF;*/
    IF get_item_info_tls%ISOPEN THEN
      CLOSE get_item_info_tls;
    END IF;
    IF get_service_rule_info%ISOPEN THEN
      CLOSE get_service_rule_info;
    END IF;
    IF get_expense_service_rule_info%ISOPEN THEN
      CLOSE get_expense_service_rule_info;
    END IF;
    IF get_cap_link_asset_amount%ISOPEN THEN
      CLOSE get_cap_link_asset_amount;
    END IF;
    IF get_service_lines%ISOPEN THEN
      CLOSE get_service_lines;
    END IF;
    IF get_service_line_payments%ISOPEN THEN
      CLOSE get_service_line_payments;
    END IF;
    IF get_old_service_lines%ISOPEN THEN
      CLOSE get_old_service_lines;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF get_amt%ISOPEN THEN
      CLOSE get_amt;
    END IF;
    IF get_item_info%ISOPEN THEN
      CLOSE get_item_info;
    END IF;
    /*IF get_asset_info%ISOPEN THEN
      CLOSE get_asset_info;
    END IF;*/
    IF get_orig_sys_id1%ISOPEN THEN
      CLOSE get_orig_sys_id1;
    END IF;
    IF check_other_line%ISOPEN THEN
      CLOSE check_other_line;
    END IF;
    /*IF get_sls_rule_pymt%ISOPEN THEN
      CLOSE get_sls_rule_pymt;
    END IF;*/
    /*IF get_rule_pymt%ISOPEN THEN
      CLOSE get_rule_pymt;
    END IF;*/
    /*IF get_sls_amt%ISOPEN THEN
      CLOSE get_sls_amt;
    END IF;*/
    IF get_item_info_tls%ISOPEN THEN
      CLOSE get_item_info_tls;
    END IF;
    IF get_service_rule_info%ISOPEN THEN
      CLOSE get_service_rule_info;
    END IF;
    IF get_expense_service_rule_info%ISOPEN THEN
      CLOSE get_expense_service_rule_info;
    END IF;
    IF get_cap_link_asset_amount%ISOPEN THEN
      CLOSE get_cap_link_asset_amount;
    END IF;
    IF get_service_lines%ISOPEN THEN
      CLOSE get_service_lines;
    END IF;
    IF get_service_line_payments%ISOPEN THEN
      CLOSE get_service_line_payments;
    END IF;
    IF get_old_service_lines%ISOPEN THEN
      CLOSE get_old_service_lines;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF get_amt%ISOPEN THEN
      CLOSE get_amt;
    END IF;
    IF get_item_info%ISOPEN THEN
      CLOSE get_item_info;
    END IF;
    /*IF get_asset_info%ISOPEN THEN
      CLOSE get_asset_info;
    END IF;*/
    IF get_orig_sys_id1%ISOPEN THEN
      CLOSE get_orig_sys_id1;
    END IF;
    IF check_other_line%ISOPEN THEN
      CLOSE check_other_line;
    END IF;
    /*IF get_sls_rule_pymt%ISOPEN THEN
      CLOSE get_sls_rule_pymt;
    END IF;*/
    /*IF get_rule_pymt%ISOPEN THEN
      CLOSE get_rule_pymt;
    END IF;*/
    /*IF get_sls_amt%ISOPEN THEN
      CLOSE get_sls_amt;
    END IF;*/
    IF get_item_info_tls%ISOPEN THEN
      CLOSE get_item_info_tls;
    END IF;
    IF get_service_rule_info%ISOPEN THEN
      CLOSE get_service_rule_info;
    END IF;
    IF get_expense_service_rule_info%ISOPEN THEN
      CLOSE get_expense_service_rule_info;
    END IF;
    IF get_cap_link_asset_amount%ISOPEN THEN
      CLOSE get_cap_link_asset_amount;
    END IF;
    IF get_service_lines%ISOPEN THEN
      CLOSE get_service_lines;
    END IF;
    IF get_service_line_payments%ISOPEN THEN
      CLOSE get_service_line_payments;
    END IF;
    IF get_old_service_lines%ISOPEN THEN
      CLOSE get_old_service_lines;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END l_process_split_contract;
-----------------------------------------------------------------------------------------------
--------------------------------- split Contract after yield ----------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE split_contract_after_yield(p_api_version        IN  NUMBER,
                                       p_init_msg_list      IN  VARCHAR2,
                                       x_return_status      OUT NOCOPY VARCHAR2,
                                       x_msg_count          OUT NOCOPY NUMBER,
                                       x_msg_data           OUT NOCOPY VARCHAR2,
                                       p_chr_id             IN  OKC_K_HEADERS_B.ID%TYPE) IS
    l_api_name                    VARCHAR2(35)    := 'SPLIT_CONTRACT_AFTER_YIELD';
    l_proc_name                   VARCHAR2(35)    := 'SPLIT_CONTRACT_AFTER_YIELD';

    REPORTING_EXCEPTION           EXCEPTION;
    ln_dummy                      NUMBER :=0;
    ln1_dummy                     NUMBER :=0;
    ln_orig_system_id1            OKC_K_HEADERS_B.ORIG_SYSTEM_ID1%TYPE;
    lv_ok_to_terminate_orig_K     VARCHAR2(3):= 'N';
    i                             NUMBER := 0;
    j                             NUMBER := 0;
    k                             NUMBER := 0;
    l_cimv_rec                    cimv_rec_type;
    lx_cimv_rec                   cimv_rec_type;
    l_trxv_rec                    trxv_rec_type;
    lx_trxv_rec                   trxv_rec_type;
    l_tcnv_rec                    OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
    lx_tcnv_rec                   OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;

    -- rravikir added for Bug 2927173, 2901442
    lprv_rec                      OKL_REV_LOSS_PROV_PVT.lprv_rec_type;
    ln_orig_contract_id           OKC_K_HEADERS_B.ID%TYPE;
    lv_contract_number            OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    ld_contract_start_date        OKC_K_HEADERS_B.START_DATE%TYPE;
    ld_split_date                 OKL_TRX_CONTRACTS.DATE_TRANSACTION_OCCURRED%TYPE;
    -- end for Bug 2927173, 2901442

    -- rravikir added for Bug 3487162
    l_gl_date                     DATE;
    -- end for Bug 3487162

    ln_chr_id                 OKC_K_HEADERS_V.ID%TYPE;
    ln_service_id             OKC_K_HEADERS_V.ID%TYPE;

    CURSOR get_old_service_id(p_chr_id OKC_K_HEADERS_B.ID%TYPE)
    IS
    SELECT object1_id1 service_contract_id
    FROM okc_k_rel_objs_v rel
    WHERE rel.chr_id = P_chr_id;

    CURSOR check_other_line(p_chr_id OKC_K_HEADERS_B.ID%TYPE)
    IS
    SELECT '1'
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKC_K_LINES_B cle,
                       OKC_LINE_STYLES_b lse
                  WHERE cle.dnz_chr_id = p_chr_id
                  AND lse.id = cle.lse_id
                  AND lse.lty_code IN (G_USG_LINE_LTY_CODE,
                                       G_USL_LINE_LTY_CODE));

    -- to check weather the given Chr id belongs to a Split Contract process
    CURSOR check_split_k_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT 1
    FROM dual
    WHERE EXISTS (SELECT 1
                  FROM okl_trx_contracts trx,
                       okl_trx_types_tl  try,
                       okl_k_headers khr
                  WHERE try.name = 'Split Contract'
                  AND try.LANGUAGE = 'US'
                  AND trx.try_id = try.id
                --rkuttiya added for 12.1.1 Multi GAAP
                  AND trx.representation_type = 'PRIMARY'
                --
                  AND trx.tsu_code = 'ENTERED'
                  AND khr.id = trx.khr_id
                  AND trx.khr_id = p_chr_id);

    -- To get the orig system id for p_chr_id
    CURSOR get_orig_sys_id1(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT orig_system_id1
    FROM okc_k_headers_b
    WHERE id = p_chr_id
    AND orig_system_source_code = 'OKL_SPLIT';

    -- To get status of splited transaction Chr id
    CURSOR check_ctrct_status(p_chr_id OKC_K_HEADERS_B.ORIG_SYSTEM_ID1%TYPE) IS
    SELECT CHR.id chr_id,
           sts_code sts_code,
           trx.id trx_id
    FROM okl_trx_contracts trx,
         okl_trx_types_tl  try,
         okc_k_headers_b CHR
    WHERE try.name = 'Split Contract'
    AND try.LANGUAGE = 'US'
    AND trx.try_id = try.id
    AND trx.tsu_code = 'ENTERED'
    AND trx.khr_id = CHR.orig_system_id1
  --rkuttiya added for 12.1.1 Multi GAAP
    AND trx.representation_type = 'PRIMARY'
 --
    AND CHR.orig_system_source_code = 'OKL_SPLIT'
    AND CHR.orig_system_id1= p_chr_id;

    -- To get the orig system id for Fixed Asset lines of p_chr_id
    CURSOR get_orig_fa(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT orig_system_id1 orig_cle_fa,
           txl.tas_id tas_id_fa,
           cle.id id
    FROM OKC_K_LINES_V cle,
         OKC_LINE_STYLES_V lse,
         OKL_TXL_ASSETS_B txl
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_FA_LINE_LTY_CODE
    AND cle.id = txl.kle_id;

    -- To get the orig system id for Install Base lines of p_chr_id
    CURSOR get_orig_ib(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT orig_system_id1 orig_cle_ib,
           iti.tas_id tas_id_ib,
           cle.id id
    FROM OKC_K_LINES_V cle,
         OKC_LINE_STYLES_V lse,
         OKL_TXL_ITM_INSTS iti
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_IB_LINE_LTY_CODE
    AND cle.id = iti.kle_id;

    -- To get the item information from original line id and original contract id
    CURSOR get_item_info(p_orig_chr_id OKC_K_HEADERS_B.ID%TYPE,
                         p_orig_cle_id OKC_K_LINES_B.ID%TYPE) IS
    SELECT object1_id1,
           object1_id2
    FROM  okc_k_items
    WHERE cle_id = p_orig_cle_id
    AND dnz_chr_Id = p_orig_chr_id;

    -- To get the Contract number and Split contract transaction date
    -- rravikir added - Bug 2927173, 2901442
    CURSOR get_split_info(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT KHR.ID, KHR.CONTRACT_NUMBER, KHR.START_DATE, TRX.DATE_TRANSACTION_OCCURRED
    FROM   OKC_K_HEADERS_B KHR,
           OKL_TRX_CONTRACTS TRX
    WHERE  TRX.KHR_ID = KHR.ID
    AND    TRX.TSU_CODE = 'PROCESSED'
    AND    TRX.TCN_TYPE = 'SPLC'
   --rkuttiya added for 12.1.1 Multi GAAP
    AND    TRX.REPRESENTATION_TYPE = 'PRIMARY'
   --
    AND    KHR.ID = p_chr_id;
    -- End Bug 2927173, 2901442

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To get the orig system id for
    OPEN  get_orig_sys_id1(p_chr_id => p_chr_id);
    FETCH get_orig_sys_id1 INTO ln_orig_system_id1;
    IF get_orig_sys_id1%NOTFOUND THEN
      ln_dummy := 0;
    ELSE
      ln_dummy := 1;
    END IF;
    CLOSE get_orig_sys_id1;

    IF ln_dummy = 1 THEN
      -- we need to Make sure that the contract that we are finishing up is
      -- a split contract.
      OPEN  check_split_k_csr(p_chr_id => ln_orig_system_id1);
      FETCH check_split_k_csr INTO ln_dummy;
      IF check_split_k_csr%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'OKC_K_HEADERS_B.ORIG_SYSTEM_ID1');

         IF (G_DEBUG_SPLIT) THEN
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Contract used in the Split process
            is not of the type "Split Contract"');
         END IF;

         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE check_split_k_csr;

      -- We have to call the journal Entries for the same
      OKL_LA_JE_PUB.generate_journal_entries(
                  p_api_version      => p_api_version,
                  p_init_msg_list    => p_init_msg_list,
                  p_commit           => OKL_API.G_FALSE,
                  p_contract_id      => p_chr_id,
                  p_transaction_type => 'Split Contract',
                  p_draft_yn         => OKL_API.G_TRUE,
                  p_memo_yn          => OKL_API.G_FALSE,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data);

      IF (G_DEBUG_SPLIT) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'OKL_LA_JE_PUB.generate_journal_entries
            procedure finished with status ' || x_return_status || ' in
            split_contract_after_yield procedure');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Information : ' || x_msg_data);
      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- To get all the assets for the p_chr_id
      FOR r_get_orig_fa IN get_orig_fa(p_chr_id => p_chr_id) LOOP
        IF get_orig_fa%NOTFOUND THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'p_chr_id');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        -- to get all the new line item information
        x_return_status := get_rec_cimv(r_get_orig_fa.id,
                                        p_chr_id,
                                        l_cimv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_ITEMS_V record');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'OKC_K_ITEMS_V record');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

        -- To get the old information of the old asset
        OPEN get_item_info(p_orig_chr_id => ln_orig_system_id1,
                           p_orig_cle_id => r_get_orig_fa.orig_cle_fa);
        IF get_item_info%NOTFOUND THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'p_chr_id');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        FETCH get_item_info INTO l_cimv_rec.object1_id1,
                                 l_cimv_rec.object1_id2;
        CLOSE get_item_info;
        OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                   p_init_msg_list => p_init_msg_list,
                                                   x_return_status => x_return_status,
                                                   x_msg_count     => x_msg_count,
                                                   x_msg_data      => x_msg_data,
                                                   p_cimv_rec      => l_cimv_rec,
                                                   x_cimv_rec      => lx_cimv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

        -- We need to make the changes to Transaction asset information as processed
        x_return_status := get_tasv_rec(r_get_orig_fa.tas_id_fa,
                                        l_trxv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'TAS Rec');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'TAS Rec');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        l_trxv_rec.tsu_code := 'PROCESSED';
        OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                           p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_thpv_rec       => l_trxv_rec,
                           x_thpv_rec       => lx_trxv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
      END LOOP;

      IF (G_DEBUG_SPLIT) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Switching Assets process
          finished with status ' || x_return_status || ' in
          split_contract_after_yield procedure');
      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- To get the Install Base information for the p_chr_id
      FOR r_get_orig_ib IN get_orig_ib(p_chr_id => p_chr_id) LOOP
        IF get_orig_ib%NOTFOUND THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        -- to get all the new line item information
        x_return_status := get_rec_cimv(r_get_orig_ib.id,
                                        p_chr_id,
                                        l_cimv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_ITEMS_V record');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'OKC_K_ITEMS_V record');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        -- To get the old information of the old asset
        OPEN get_item_info(p_orig_chr_id => ln_orig_system_id1,
                           p_orig_cle_id => r_get_orig_ib.orig_cle_ib);
        IF get_item_info%NOTFOUND THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'Orig system id1');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        FETCH get_item_info INTO l_cimv_rec.object1_id1,
                                 l_cimv_rec.object1_id2;
        CLOSE get_item_info;
        OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                   p_init_msg_list => p_init_msg_list,
                                                   x_return_status => x_return_status,
                                                   x_msg_count     => x_msg_count,
                                                   x_msg_data      => x_msg_data,
                                                   p_cimv_rec      => l_cimv_rec,
                                                   x_cimv_rec      => lx_cimv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

        -- We need to make the changes to Transaction asset information as processed
        x_return_status := get_tasv_rec(r_get_orig_ib.tas_id_ib,
                                        l_trxv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'TAS Rec');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'TAS Rec');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        l_trxv_rec.tsu_code := 'PROCESSED';
        OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                           p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_thpv_rec       => l_trxv_rec,
                           x_thpv_rec       => lx_trxv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
      END LOOP;

      IF (G_DEBUG_SPLIT) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Obtaining Install Base information
          finished with status ' || x_return_status || ' in
          split_contract_after_yield procedure');
        IF (x_return_status <> 'S') THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
        END IF;
      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Activating the Usage lines also if exits
      OPEN  check_other_line(p_chr_id => p_chr_id);
      FETCH check_other_line INTO ln1_dummy;
      CLOSE check_other_line;
      IF ln1_dummy <> 0 THEN
        --Process the Usage header
        OKL_UBB_INTEGRATION_PUB.create_ubb_contract (
                                p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => p_chr_id,
                                x_chr_id        => ln_chr_id);

        IF (G_DEBUG_SPLIT) THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'OKL_UBB_INTEGRATION_PUB.create_ubb_contract
            procedure finished with status ' || x_return_status || ' in
            split_contract_after_yield procedure');
          IF (x_return_status <> 'S') THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
          END IF;
        END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      -- We need to change the status of the contract
      OKL_CONTRACT_STATUS_PUB.update_contract_status(
                              p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_khr_status    => 'BOOKED',
                              p_chr_id        => p_chr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF (G_DEBUG_SPLIT) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'OKL_CONTRACT_STATUS_PUB.update_contract_status
          procedure finished with status ' || x_return_status || ' in
          split_contract_after_yield procedure');
      END IF;

      -- We need to change the status of the Lines for the contract
      OKL_CONTRACT_STATUS_PUB.cascade_lease_status(
                              p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_chr_id        => p_chr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- To get status of splited transaction Chr id
      FOR r_check_ctrct_status IN check_ctrct_status(p_chr_id => ln_orig_system_id1) LOOP
        lt_chr_sts_tbl(i).chr_id   := r_check_ctrct_status.chr_id;
        lt_chr_sts_tbl(i).sts_code := r_check_ctrct_status.sts_code;
        l_tcnv_rec.id              := r_check_ctrct_status.trx_id;

        IF check_ctrct_status%NOTFOUND THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKL_TRX_CONTRACTS.ID');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        i := i + 1;
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF lt_chr_sts_tbl.COUNT = 2 THEN
        j := lt_chr_sts_tbl.FIRST;

        IF lt_chr_sts_tbl(j+1).sts_code = 'BOOKED' AND
           lt_chr_sts_tbl(j).sts_code = 'BOOKED' THEN
          lv_ok_to_terminate_orig_K := 'Y';
        END IF;
      ELSE
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_CNT_REC);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF lv_ok_to_terminate_orig_K = 'Y' THEN
        -- Now since both the contract booked we can safely update the
        -- Transaction to PROCESSED
        l_tcnv_rec.tsu_code := 'PROCESSED';
        Okl_Trx_Contracts_Pub.update_trx_contracts(
                                p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_tcnv_rec      => l_tcnv_rec,
                                x_tcnv_rec      => lx_tcnv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        /**
         * sjalasut, added API call to process subsidy pool transactions
         * before the contract is ammended. this api will reverse the transactions
         * on the old contract and add transactions from the split copies of the
         * contract. No change in the pool balance is expected. START.
         */

        IF (G_DEBUG_SPLIT) THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Start Processing Subsidy Pool Transactions '|| x_return_status || ' in
            split_contract_after_yield procedure');
          IF (x_return_status <> 'S') THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
          END IF;
        END IF;

        okl_subsidy_pool_auth_trx_pvt.create_pool_trx_khr_split(p_api_version   => p_api_version
                                                               ,p_init_msg_list => p_init_msg_list
                                                               ,x_return_status => x_return_status
                                                               ,x_msg_count     => x_msg_count
                                                               ,x_msg_data      => x_msg_data
                                                               ,p_new1_chr_id   => lt_chr_sts_tbl(j).chr_id
                                                               ,p_new2_chr_id   => lt_chr_sts_tbl(j+1).chr_id
                                                               );
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF (G_DEBUG_SPLIT) THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Completed Processing Subsidy Pool Transactions '|| x_return_status || ' in
            split_contract_after_yield procedure');
          IF (x_return_status <> 'S') THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
          END IF;
        END IF;

        /**
         * sjalasut, added API call to process subsidy pool transactions. END
         */

        -- We need to change the status of the contract
        OKL_CONTRACT_STATUS_PUB.update_contract_status(
                                p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_khr_status    => 'AMENDED',
                                p_chr_id        => ln_orig_system_id1);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- We need to change the status of the Lines for the contract
        OKL_CONTRACT_STATUS_PUB.cascade_lease_status(
                                p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => ln_orig_system_id1);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- We can update the old servic contract also
        OPEN  get_old_service_id(p_chr_id =>ln_orig_system_id1);
        FETCH get_old_service_id INTO ln_service_id;
        CLOSE get_old_service_id;
        IF ln_service_id IS NOT NULL OR
           ln_service_id <> OKL_API.G_MISS_NUM THEN
          -- We need to change the status of the contract
          OKL_CONTRACT_STATUS_PUB.update_contract_status(
                                  p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_khr_status    => 'AMENDED',
                                  p_chr_id        => ln_service_id);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- We need to change the status of the Lines for the contract
          OKL_CONTRACT_STATUS_PUB.cascade_lease_status(
                                  p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_chr_id        => ln_service_id);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        -- rravikir added for Bug 2927173, 2901442
        -- Reverse Loss provision transactions for the 'AMENDED' contract

        -- Get Contract number and Split contract date
        OPEN  get_split_info(p_chr_id =>ln_orig_system_id1);
        FETCH get_split_info INTO ln_orig_contract_id, lv_contract_number,
                                  ld_contract_start_date, ld_split_date;
        CLOSE get_split_info;

        lprv_rec.cntrct_num := lv_contract_number;
        lprv_rec.reversal_date := ld_split_date;
        lprv_rec.reversal_type := NULL;

        OKL_REV_LOSS_PROV_PUB.reverse_loss_provisions(
                                  p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  x_return_status => x_return_status,
                                  p_lprv_rec      => lprv_rec);

        IF (G_DEBUG_SPLIT) THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Completed Reversal Loss provisions
            for the original Contract with Status ' || x_return_status || ' in
            split_contract_after_yield procedure');
          IF (x_return_status <> 'S') THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
          END IF;
        END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- rravikir added for Bug 3487162
        -- Get valid open period date by calling accounting util with split
        -- contract transaction date.
        l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_gl_date => ld_split_date);
        -- end for Bug 3487162

        -- Reverse Accrual Accounting for the 'AMENDED' contract
        OKL_GENERATE_ACCRUALS_PUB.reverse_all_accruals(
                                  p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  p_khr_id        => ln_orig_contract_id,
                                  p_reverse_date  => l_gl_date,
                                  p_description   => 'Call from Split Contract API',
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data);

        IF (G_DEBUG_SPLIT) THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Completed Reversal Accruals
            for the original Contract with Status ' || x_return_status || ' in
            split_contract_after_yield procedure');
          IF (x_return_status <> 'S') THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
          END IF;
        END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- end for Bug 2927173, 2901442

      END IF;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);

  EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF check_split_k_csr%ISOPEN THEN
          CLOSE check_split_k_csr;
        END IF;
        IF get_orig_sys_id1%ISOPEN THEN
          CLOSE get_orig_sys_id1;
        END IF;
        IF check_ctrct_status%ISOPEN THEN
          CLOSE check_ctrct_status;
        END IF;
        IF get_orig_fa%ISOPEN THEN
          CLOSE get_orig_fa;
        END IF;
        IF get_orig_ib%ISOPEN THEN
          CLOSE get_orig_ib;
        END IF;
        IF get_item_info%ISOPEN THEN
          CLOSE get_item_info;
        END IF;
        IF get_old_service_id%ISOPEN THEN
          CLOSE get_old_service_id;
        END IF;
        IF check_other_line%ISOPEN THEN
          CLOSE check_other_line;
        END IF;
        IF get_split_info%ISOPEN THEN
          CLOSE get_split_info;
        END IF;
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF check_split_k_csr%ISOPEN THEN
          CLOSE check_split_k_csr;
        END IF;
        IF get_orig_sys_id1%ISOPEN THEN
          CLOSE get_orig_sys_id1;
        END IF;
        IF get_old_service_id%ISOPEN THEN
          CLOSE get_old_service_id;
        END IF;
        IF check_ctrct_status%ISOPEN THEN
          CLOSE check_ctrct_status;
        END IF;
        IF get_orig_fa%ISOPEN THEN
          CLOSE get_orig_fa;
        END IF;
        IF get_orig_ib%ISOPEN THEN
          CLOSE get_orig_ib;
        END IF;
        IF get_item_info%ISOPEN THEN
          CLOSE get_item_info;
        END IF;
        IF check_other_line%ISOPEN THEN
          CLOSE check_other_line;
        END IF;
        IF get_split_info%ISOPEN THEN
          CLOSE get_split_info;
        END IF;
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
        IF check_split_k_csr%ISOPEN THEN
          CLOSE check_split_k_csr;
        END IF;
        IF get_orig_sys_id1%ISOPEN THEN
          CLOSE get_orig_sys_id1;
        END IF;
        IF check_ctrct_status%ISOPEN THEN
          CLOSE check_ctrct_status;
        END IF;
        IF get_old_service_id%ISOPEN THEN
          CLOSE get_old_service_id;
        END IF;
        IF get_orig_fa%ISOPEN THEN
          CLOSE get_orig_fa;
        END IF;
        IF get_orig_ib%ISOPEN THEN
          CLOSE get_orig_ib;
        END IF;
        IF check_other_line%ISOPEN THEN
          CLOSE check_other_line;
        END IF;
        IF get_item_info%ISOPEN THEN
          CLOSE get_item_info;
        END IF;
        IF get_split_info%ISOPEN THEN
          CLOSE get_split_info;
        END IF;
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END split_contract_after_yield;

-----------------------------------------------------------------------------------------------
---------------------------- Main Process for split of Contract -------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE create_split_contract(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_old_contract_number  IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE,
            p_new_khr_top_line     IN  ktl_tbl_type,
            x_new_khr_top_line     OUT NOCOPY ktl_tbl_type)
  IS
    l_api_name      CONSTANT VARCHAR2(30) := 'OKL_SPLIT_CONTRACT_PVT';
    lr_ktl_rec               ktl_rec_type;
    lrx_ktl_rec              ktl_rec_type;
    lt_ktl_tbl               ktl_tbl_type;
    ltx_ktl_tbl              ktl_tbl_type;
    i                        NUMBER := 0;
    l_pre_line               NUMBER := -1;
    ln_old_top_line_cnt      NUMBER := 0;
    ln_old_chr_id            OKC_K_HEADERS_V.ID%TYPE := 0;
    lx_new_header_id         OKC_K_HEADERS_V.ID%TYPE := 0;

    l_chrv_rec               chrv_rec_type;
    l_khrv_rec               khrv_rec_type;
    lx_chrv_rec               chrv_rec_type;
    lx_khrv_rec               khrv_rec_type;

    CURSOR c_old_header_id(p_contract_number OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE) IS
    SELECT id
    FROM OKC_K_HEADERS_V
    WHERE contract_number = p_contract_number;

    CURSOR get_new_contract_number(p_header_id OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT contract_number
    FROM OKC_K_HEADERS_V
    WHERE id = p_header_id;

    CURSOR c_old_top_line_cnt(p_contract_number OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE) IS
    SELECT COUNT(cle.id)
    FROM OKC_SUBCLASS_TOP_LINE stl,
         OKC_LINE_STYLES_V lse,
         OKC_K_LINES_V cle,
         OKC_K_HEADERS_V chrv
    WHERE chrv.contract_number = p_contract_number
    AND chrv.id = cle.dnz_chr_id
    AND cle.cle_id IS NULL
    AND cle.chr_id = chrv.id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_FIN_LINE_LTY_CODE
    AND lse.lse_type = G_TLS_TYPE
    AND lse.lse_parent_id IS NULL
    AND lse.id = stl.lse_id
    AND stl.scs_code IN (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Count of the top for the old contract
    -- Should match the imput parameter p_new_khr_top_line.COUNT
    OPEN  c_old_top_line_cnt(p_contract_number => p_old_contract_number);
    IF c_old_top_line_cnt%NOTFOUND THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_LLA_CHR_ID');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_old_top_line_cnt INTO ln_old_top_line_cnt;
    CLOSE c_old_top_line_cnt;
    IF ln_old_top_line_cnt = 0 THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_LLA_CHR_ID');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF ln_old_top_line_cnt <> p_new_khr_top_line.COUNT THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_LLA_LINE_RECORD');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- to get the old contract Header id
    OPEN  c_old_header_id(p_contract_number => p_old_contract_number);
    IF c_old_header_id%NOTFOUND THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_LLA_CHR_ID');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH  c_old_header_id INTO ln_old_chr_id;
    CLOSE  c_old_header_id;
    lt_ktl_tbl := p_new_khr_top_line;
    IF lt_ktl_tbl.COUNT > 0 THEN
      i := lt_ktl_tbl.FIRST;
      LOOP
        IF lt_ktl_tbl(i).line_number <> l_pre_line THEN
          -- Validate the top line for the Old Contract
          validate_chr_cle_id(p_dnz_chr_id    => ln_old_chr_id,
                              p_top_line_id   => lt_ktl_tbl(i).kle_id,
                              x_return_status => x_return_status);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          l_copy_contract_header(p_api_version         => p_api_version,
                                 p_init_msg_list       => p_init_msg_list,
                                 x_return_status       => x_return_status,
                                 x_msg_count           => x_msg_count,
                                 x_msg_data            => x_msg_data,
                                 p_old_chr_id          => ln_old_chr_id,
                                 p_new_contract_number => lt_ktl_tbl(i).contract_number,
                                 x_new_header_id       => lx_new_header_id);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          -- To Change the orig_system_source_code to OKL_SPLIT
          l_chrv_rec.id := lx_new_header_id;
          l_khrv_rec.id := lx_new_header_id;
          l_update_contract_header(p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_chrv_rec      => l_chrv_rec,
                                   p_khrv_rec      => l_khrv_rec,
                                   x_chrv_rec      => lx_chrv_rec,
                                   x_khrv_rec      => lx_khrv_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          l_copy_contract_line(p_api_version     => p_api_version,
                               p_init_msg_list   => p_init_msg_list,
                               x_return_status   => x_return_status,
                               x_msg_count       => x_msg_count,
                               x_msg_data        => x_msg_data,
                               p_old_k_top_line  => lt_ktl_tbl(i).kle_id,
                               p_new_header_id   => lx_new_header_id,
                               x_new_k_top_id    => x_new_khr_top_line(i).kle_id);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          -- To build the output information
          OPEN  get_new_contract_number(lx_new_header_id);
          IF get_new_contract_number%NOTFOUND THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_NO_MATCHING_RECORD,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'New contract header id');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          FETCH get_new_contract_number INTO x_new_khr_top_line(i).contract_number;
          CLOSE get_new_contract_number;
          x_new_khr_top_line(i).line_number := lt_ktl_tbl(i).line_number;
        ELSIF lt_ktl_tbl(i).line_number = l_pre_line THEN
          -- Validate the top line for the Old Contract
          validate_chr_cle_id(p_dnz_chr_id    => ln_old_chr_id,
                              p_top_line_id   => lt_ktl_tbl(i).kle_id,
                              x_return_status => x_return_status);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          l_copy_contract_line(p_api_version     => p_api_version,
                               p_init_msg_list   => p_init_msg_list,
                               x_return_status   => x_return_status,
                               x_msg_count       => x_msg_count,
                               x_msg_data        => x_msg_data,
                               p_old_k_top_line  => lt_ktl_tbl(i).kle_id,
                               p_new_header_id   => lx_new_header_id,
                               x_new_k_top_id    => x_new_khr_top_line(i).kle_id);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          -- To build the output information
          OPEN  get_new_contract_number(lx_new_header_id);
          IF get_new_contract_number%NOTFOUND THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_NO_MATCHING_RECORD,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'New contract header id');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          FETCH get_new_contract_number INTO x_new_khr_top_line(i).contract_number;
          CLOSE get_new_contract_number;
          x_new_khr_top_line(i).line_number := lt_ktl_tbl(i).line_number;
        ELSE
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_CRITERIA,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'Line Number of KTL_TBL_TYPE');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        l_pre_line := lt_ktl_tbl(i).line_number;
        EXIT WHEN (i = lt_ktl_tbl.LAST);
        i := lt_ktl_tbl.NEXT(i);
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
   END IF;
   OKL_API.END_ACTIVITY (x_msg_count,
                         x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF c_old_header_id%ISOPEN THEN
         CLOSE c_old_header_id;
      END IF;
      IF get_new_contract_number%ISOPEN THEN
         CLOSE get_new_contract_number;
      END IF;
      IF c_old_top_line_cnt%ISOPEN THEN
         CLOSE c_old_top_line_cnt;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF c_old_header_id%ISOPEN THEN
         CLOSE c_old_header_id;
      END IF;
      IF get_new_contract_number%ISOPEN THEN
         CLOSE get_new_contract_number;
      END IF;
      IF c_old_top_line_cnt%ISOPEN THEN
         CLOSE c_old_top_line_cnt;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      IF c_old_header_id%ISOPEN THEN
         CLOSE c_old_header_id;
      END IF;
      IF get_new_contract_number%ISOPEN THEN
         CLOSE get_new_contract_number;
      END IF;
      IF c_old_top_line_cnt%ISOPEN THEN
         CLOSE c_old_top_line_cnt;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END create_split_contract;
-----------------------------------------------------------------------------------------------
------------------------- Set the context to Split process  -----------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE set_context(
            p_api_version          IN  NUMBER,
            p_init_msg_list    IN  VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_resp_id          IN  NUMBER,
            p_appl_id          IN  NUMBER,
            p_user_id          IN  NUMBER,
            x_return_status    OUT NOCOPY VARCHAR2) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'set_context';
  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (p_resp_id = OKL_API.G_MISS_NUM OR
        p_resp_id IS NULL) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_resp_id');
      RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    IF (p_appl_id = OKL_API.G_MISS_NUM OR
        p_appl_id IS NULL) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_appl_id');
      RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    IF (p_user_id = OKL_API.G_MISS_NUM OR
        p_user_id IS NULL) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_user_id');
      RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;

    -- Set the context
    FND_GLOBAL.apps_initialize(user_id       => p_user_id,
                               resp_id       => p_resp_id,
                               resp_appl_id  => p_appl_id);

    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END set_context;
-----------------------------------------------------------------------------------------------
------------------------- Main Process for post split of Contract -----------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE post_split_contract(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_commit               IN  VARCHAR2,
            p_new1_contract_id     IN  OKC_K_HEADERS_V.ID%TYPE,
            p_new2_contract_id     IN  OKC_K_HEADERS_V.ID%TYPE,
            x_trx1_number          OUT NOCOPY NUMBER,
            x_trx1_status          OUT NOCOPY VARCHAR2,
            x_trx2_number          OUT NOCOPY NUMBER,
            x_trx2_status          OUT NOCOPY VARCHAR2)
  IS
    l_api_name      CONSTANT VARCHAR2(30) := 'OKL_POST_SPLIT_CONTRACT';
    i                        NUMBER := 0;
    ln_qcl_id1               NUMBER;
    ln_qcl_id2               NUMBER;
    lt1_msg_tbl              OKL_QA_CHECK_PUB.msg_tbl_type;
    lt2_msg_tbl              OKL_QA_CHECK_PUB.msg_tbl_type;
    lv_severity              OKC_QA_LIST_PROCESSES_V.SEVERITY%TYPE;
    lv1_contract_number      OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    lv2_contract_number      OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    lv_data                  VARCHAR2(2000);
    lv1_stream_id             OKL_STREAM_INTERFACES.ID%TYPE;
    lv2_stream_id             OKL_STREAM_INTERFACES.ID%TYPE;
    lv1_sis_code             OKL_STREAM_INTERFACES.SIS_CODE%TYPE;
    lv2_sis_code             OKL_STREAM_INTERFACES.SIS_CODE%TYPE;
    lv1_sts_code             OKC_K_HEADERS_B.STS_CODE%TYPE;
    lv2_sts_code             OKC_K_HEADERS_B.STS_CODE%TYPE;
    lv_contract_number       OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    l_stream_path            OKL_ST_GEN_TMPT_SETS.PRICING_ENGINE%TYPE;

    -- Log Directory Path variable
    l_temp_dir               VARCHAR2(1000);

    -- To check if the stream generation of the contract went thru good.
    CURSOR c_ok_stream(p_khr_id OKL_STREAM_INTERFACES.KHR_ID%TYPE) IS
    SELECT a.id,
           a.sis_code,
           h.sts_code
    FROM  okl_stream_interfaces a,
          okc_k_headers_b h
    WHERE a.khr_id = p_khr_id
    AND h.id = a.khr_id
    AND TRUNC(a.date_processed) IN (SELECT MAX(TRUNC(b.date_processed))
                                   FROM okl_stream_interfaces b
                                   WHERE b.khr_id = p_khr_id);

    CURSOR get_dir IS
    SELECT NVL(SUBSTRB(TRANSLATE(LTRIM(value),',',' '), 1,
               INSTR(TRANSLATE(LTRIM(value),',',' '),' ') - 1),value)
    FROM v$parameter
    WHERE name = 'utl_file_dir';

    CURSOR c_get_sts_code(p_khr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT sts_code
    FROM  okc_k_headers_b
    WHERE id = p_khr_id;

    CURSOR c_get_contract_number(p_khr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT contract_number
    FROM okc_k_headers_b
    WHERE id = (SELECT ORIG_SYSTEM_ID1
                FROM okc_k_headers_b
                WHERE id = p_khr_id);

    CURSOR c_ok_stream_loop(p_khr_id     OKL_STREAM_INTERFACES.KHR_ID%TYPE,
                            p_stream_id  OKL_STREAM_INTERFACES.ID%TYPE) IS
    SELECT a.sis_code,
           h.sts_code
    FROM  okl_stream_interfaces a,
          okc_k_headers_b h
    WHERE a.id = p_stream_id
    AND a.khr_id = p_khr_id
    AND h.id = a.khr_id
    AND TRUNC(a.date_processed) IN (SELECT MAX(TRUNC(b.date_processed))
                                   FROM okl_stream_interfaces b
                                   WHERE b.khr_id = p_khr_id);

    CURSOR c_get_source_id(p_khr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT id
    FROM OKL_TXL_CNTRCT_LNS
    WHERE khr_id = p_khr_id;

    CURSOR c_org_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT authoring_org_id
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    l_org_id okc_k_headers_b.authoring_org_id%TYPE;

    /*
    -- mvasudev, 08/23/2004
    -- Added PROCEDURE to enable Business Event
    */
	PROCEDURE raise_business_event(
	   x_return_status OUT NOCOPY VARCHAR2
    )
	IS
	  -- Cursor to get the old chr id
	  /*
	CURSOR l_old_chr_csr (p_khr_id OKC_K_HEADERS_B.ID%TYPE) IS
      SELECT chrb.orig_system_id1 old_chr_id
     		,trxb.date_transaction_occurred date_transaction_occurred
      FROM   okc_k_headers_b chrb
       	   ,okl_trx_contracts trxb
 		  ,okl_trx_types_b tryv
      WHERE  chrb.id = p_khr_id
      -- AND    trxb.khr_id_old = chrb.orig_system_id1
     AND trxb.khr_id = chrb.id
      AND    trxb.tsu_code = 'PROCESSED'
      AND    trxb.try_id = tryv.id;
      */

      CURSOR l_old_chr_csr (p_khr_id OKC_K_HEADERS_B.ID%TYPE) IS
      SELECT chrb.orig_system_id1 old_chr_id
                     ,trxb2.date_transaction_occurred date_transaction_occurred
      FROM   okc_k_headers_b chrb
                    ,okl_trx_contracts trxb1
                    ,okl_trx_types_b tryv
                    ,okl_trx_contracts trxb2
      WHERE  chrb.id = p_khr_id
      AND trxb1.khr_id = chrb.id
      AND    trxb1.tsu_code = 'PROCESSED'
      --rkuttiya added for 12.1.1 MUlti GAAP
      AND    trxb1.representation_type = 'PRIMARY'
      --
      AND    trxb1.try_id = tryv.id
      AND    trxb2.khr_id = chrb.orig_system_id1
      AND    trxb2.TCN_TYPE = 'SPLC'
      AND    trxb2.tsu_code = 'PROCESSED'
      AND    trxb2.try_id = tryv.id;


      l_parameter_list           wf_parameter_list_t;
	BEGIN
	  FOR l_old_chr_rec IN l_old_chr_csr(p_new1_contract_id)
	  LOOP

  		 wf_event.AddParameterToList(G_WF_ITM_SRC_CONTRACT_ID,l_old_chr_rec.old_chr_id,l_parameter_list);
  		 wf_event.AddParameterToList(G_WF_ITM_REVISION_DATE,fnd_date.date_to_canonical(l_old_chr_rec.date_transaction_occurred),l_parameter_list);
  		 wf_event.AddParameterToList(G_WF_ITM_DEST_CONTRACT_ID_1,p_new1_contract_id,l_parameter_list);
  		 wf_event.AddParameterToList(G_WF_ITM_DEST_CONTRACT_ID_2,p_new2_contract_id,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_KHR_SPLIT_COMPLETED,
								 p_parameters     => l_parameter_list);


	  END LOOP;

     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;


    /*
    -- mvasudev, 08/23/2004
    -- END, PROCEDURE to enable Business Event
    */


  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Get the output file directory to put log of Split Contract.
    /*IF (FND_PROFILE.VALUE('OKL_SPLIT_CONTRACT_DEBUG') = 'Y') THEN
      G_DEBUG_SPLIT := TRUE;
    END IF;*/
    -- Debugging Split Contract always set to True
    G_DEBUG_SPLIT := TRUE;

    IF (G_DEBUG_SPLIT) THEN
      OPEN get_dir;
      FETCH get_dir INTO l_temp_dir;
      IF get_dir%NOTFOUND THEN
        NULL;
      END IF;
      CLOSE get_dir;
    END IF;

    OPEN  c_get_contract_number(p_khr_id => p_new1_contract_id);
    FETCH c_get_contract_number INTO lv_contract_number;
    CLOSE c_get_contract_number;

    IF (G_DEBUG_SPLIT) THEN
      -- Setting file name and db writeable path for logging the process
      FND_FILE.PUT_NAMES('SPLIT_CONTRACT_'||lv_contract_number||'.log',
                         'SPLIT_CONTRACT_'||lv_contract_number||'.out',
                         l_temp_dir);

      -- Split Contract process flow
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '+--- Start Split Contract Process Flow ---+');

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Responsibilty ID ---> ' || FND_GLOBAL.resp_id);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Application ID ---> ' || FND_GLOBAL.resp_appl_id);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'User ID ---> ' || FND_GLOBAL.user_id);

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Oracle Lease Managment: Version :
                                          11.5.10 - Development');
    END IF;

    -- Set Context
    OPEN  c_org_csr(p_new1_contract_id);
    FETCH c_org_csr INTO l_org_id;
    CLOSE c_org_csr;

    -- End

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Client Info Set for Contract-1 - ' || l_org_id);
    END IF;

    -- Validate the Chr_id
    validate_chr_id(p_chr_id          => p_new1_contract_id,
                    x_contract_number => lv1_contract_number,
                    x_return_status   => x_return_status);

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'First Split Contract Validation Completed with ' || x_return_status);
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Chr_id
    validate_chr_id(p_chr_id          => p_new2_contract_id,
                    x_contract_number => lv2_contract_number,
                    x_return_status   => x_return_status);

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Second Split Contract Validation Completed with ' || x_return_status);
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Process first split contract for fees and service lines having linked
    -- assets
    l_process_split_contract(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_contract_id    => p_new1_contract_id);

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'l_process_split_contract procedure completed with '
                                         || x_return_status || ' for first Split contract');
      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
      END IF;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ERROR_NAL_SPK);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ERROR_NAL_SPK);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Delete all the service and fee lines of second split contract not having
    -- linked asset(s) attached to them.
    l_delete_fee_service_lines(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_contract_id    => p_new2_contract_id);
    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'l_delete_fee_service_lines procedure completed with '
                                         || x_return_status || ' for second Split contract');
      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
      END IF;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ERROR_NAL_SPK);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ERROR_NAL_SPK);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Process second split contract for fees and service lines having linked
    -- assets
    l_process_split_contract(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_contract_id    => p_new2_contract_id);

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'l_process_split_contract procedure completed with '
                                         || x_return_status || ' for second Split contract');
      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
      END IF;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ERROR_NAL_SPK);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ERROR_NAL_SPK);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To run the QA checker we need to get the QCL_ID for the first contract
    -- since we assume for now the split contract will be split into Two contracts
    -- only.If the source contract do not have QCL_ID(which is never the case)
    -- Then QCL_ID can be fetched from table okc_qa_check_lists_v using hard coded
    -- name as 'OKL LA QA CHECK LIST'.
    x_return_status :=  get_qcl_id(p_chr_id => p_new1_contract_id,
                                   x_qcl_id => ln_qcl_id1);

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'get_qcl_id procedure completed with '
                                         || x_return_status || ' for first Split contract');
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'qcl_id');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'qcl_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To run the QA checker we need to get the QCL_ID for the first Second
    -- since we assume for now the split contract will be split into Two contracts
    -- only.If the source contract do not have QCL_ID(which is never the case)
    -- Then QCL_ID can be fetched from table okc_qa_check_lists_v using hard coded
    -- name as 'OKL LA QA CHECK LIST'.
    x_return_status :=  get_qcl_id(p_chr_id => p_new2_contract_id,
                                   x_qcl_id => ln_qcl_id2);

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'get_qcl_id procedure completed with '
                                         || x_return_status || ' for second Split contract');
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'qcl_id');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'qcl_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now we run the QA checker for the First Contract
    okl_contract_book_pub.execute_qa_check_list(p_api_version    => p_api_version,
                                                p_init_msg_list  => p_init_msg_list,
                                                x_return_status  => x_return_status,
                                                x_msg_count      => x_msg_count,
                                                x_msg_data       => x_msg_data,
                                                p_qcl_id         => ln_qcl_id1,
                                                p_chr_id         => p_new1_contract_id,
                                                x_msg_tbl        => lt1_msg_tbl);

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'okl_contract_book_pub.execute_qa_check_list procedure completed with '
                                         || x_return_status || ' for first Split contract');
      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
      END IF;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We need the handle the error so we run thru the message table to check if there
    -- is error severity out there.
    IF (lt1_msg_tbl.COUNT > 0) THEN
      i := lt1_msg_tbl.FIRST;
      LOOP
        lv_severity  := lt1_msg_tbl(i).error_status;
        IF lv_severity = 'E' THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ERROR_QA_CHECK);
          x_return_status := OKL_API.G_RET_STS_ERROR;

          IF (G_DEBUG_SPLIT) THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Severity in QA processing
                                                for first Split contract ' || x_return_status);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Name -> ' || lt1_msg_tbl(i).name);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Description -> ' || lt1_msg_tbl(i).description);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Package Name -> ' || lt1_msg_tbl(i).package_name);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Procedure Name -> ' || lt1_msg_tbl(i).procedure_name);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Error Status -> ' || lt1_msg_tbl(i).error_status);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Error Severity -> ' || lt1_msg_tbl(i).severity);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Data -> ' || lt1_msg_tbl(i).data);
          END IF;

          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = lt1_msg_tbl.LAST);
        i := lt1_msg_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       -- halt validation as it has no parent record
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Now we are submitting the the first contract for stream Generation.
    OKL_LA_STREAM_PUB.GEN_INTR_EXTR_STREAM(p_api_version         => p_api_version,
                                              p_init_msg_list       => p_init_msg_list,
                                              x_return_status       => x_return_status,
                                              x_msg_count           => x_msg_count,
                                              x_msg_data            => x_msg_data,
                                              p_khr_id              => p_new1_contract_id,
                                              p_generation_ctx_code => 'AUTH',
                                              x_trx_number          => x_trx1_number,
                                              x_trx_status          => x_trx1_status);


    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'OKL_LA_STREAM_PUB.GEN_INTR_EXTR_STREAM procedure completed with '
                                         || x_return_status || ' for first Split contract');
      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
      END IF;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We need to commit this transaction also since we have to get the
    -- Stream generation Kicked off
    --l_stream_path := okl_streams_util.get_pricing_engine (p_khr_id => p_new1_contract_id);
    okl_streams_util.get_pricing_engine
                         (p_khr_id => p_new1_contract_id,
                          x_pricing_engine => l_stream_path,
                          x_return_status => x_return_status
                         );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --IF (p_commit = OKL_API.G_TRUE AND (FND_PROFILE.VALUE('OKL_STREAMS_GEN_PATH') = 'EXTERNAL')) THEN
    IF (p_commit = OKL_API.G_TRUE AND (l_stream_path = 'EXTERNAL')) THEN
       COMMIT;
    END IF;

    -- Need to make sure that the stream generation process has actually completed successfully
    -- for that first contract
    --IF (FND_PROFILE.VALUE('OKL_STREAMS_GEN_PATH') = 'EXTERNAL') THEN
    IF (l_stream_path = 'EXTERNAL') THEN

      IF (G_DEBUG_SPLIT) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'External Stream Generation in progress
                                            for first Split contract ..');
      END IF;
      FOR r_ok_stream IN c_ok_stream(p_khr_id => p_new1_contract_id) LOOP
        LOOP
          OPEN  c_ok_stream_loop(p_khr_id    => p_new1_contract_id,
                                 p_stream_id => r_ok_stream.id);
          FETCH c_ok_stream_loop INTO lv1_sis_code, lv1_sts_code;
          IF c_ok_stream_loop%NOTFOUND THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_NO_MATCHING_RECORD,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'OKL_STREAM_INTERFACES.SIS_CODE');
            x_return_status := OKL_API.G_RET_STS_ERROR;

            IF (G_DEBUG_SPLIT) THEN
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'External Stream Generation information missing
                                         for first Split contract ' || x_return_status);
            END IF;

            EXIT WHEN(x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          CLOSE c_ok_stream_loop;

          IF lv1_sis_code = 'PROCESS_COMPLETE' AND
             lv1_sts_code = 'COMPLETE' THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
            EXIT WHEN(lv1_sis_code = 'PROCESS_COMPLETE');
          ELSIF lv1_sis_code NOT IN ('PROCESSING_REQUEST', 'PROCESS_COMPLETE', 'RET_DATA_RECEIVED') THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_ERROR_STR_GEN);
            x_return_status := OKL_API.G_RET_STS_ERROR;
            EXIT WHEN(x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          -- need below because of performance issue
          dbms_lock.sleep(5);
        END LOOP;

        IF x_return_status = OKL_API.G_RET_STS_ERROR THEN

          IF (G_DEBUG_SPLIT) THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'External Stream Generation completion status
                                         for first Split contract :' || x_return_status);
          END IF;

          EXIT WHEN(x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
      END LOOP;
    END IF;


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN  c_get_sts_code(p_khr_id => p_new1_contract_id);
    FETCH c_get_sts_code INTO lv1_sts_code;
    IF c_get_sts_code%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_HEADERS_B.STS_CODE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c_get_sts_code;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Post Stream generation Contract status for first
                                        Split contract : ' || lv1_sts_code);

    IF lv1_sts_code <> 'COMPLETE' THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ERROR_STR_GEN);
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- We are now doing post stream generation process for first contract
    -- Like the Journal entries and Booking of the contract
    split_contract_after_yield(p_api_version    => p_api_version,
                               p_init_msg_list  => p_init_msg_list,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_chr_id         => p_new1_contract_id);

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'split_contract_after_yield procedure
                                        completed for first contract with status ' || x_return_status);
      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
      END IF;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Set Context
    OPEN  c_org_csr(p_new2_contract_id);
    FETCH c_org_csr INTO l_org_id;
    CLOSE c_org_csr;

    -- End

    -- We need the handle the error so we run thru the message table to check if there
    -- is error severity out there.
    -- Now we run the QA checker for the second Contract
    okl_contract_book_pub.execute_qa_check_list(p_api_version    => p_api_version,
                                                p_init_msg_list  => p_init_msg_list,
                                                x_return_status  => x_return_status,
                                                x_msg_count      => x_msg_count,
                                                x_msg_data       => x_msg_data,
                                                p_qcl_id         => ln_qcl_id2,
                                                p_chr_id         => p_new2_contract_id,
                                                x_msg_tbl        => lt2_msg_tbl);


    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'okl_contract_book_pub.execute_qa_check_list procedure completed with '
                                         || x_return_status || ' for second Split contract');
      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
      END IF;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (lt2_msg_tbl.COUNT > 0) THEN
      i := lt2_msg_tbl.FIRST;
      LOOP
        lv_severity  := lt2_msg_tbl(i).error_status;
        IF lv_severity = 'E' THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ERROR_QA_CHECK);
          x_return_status := OKL_API.G_RET_STS_ERROR;

          IF (G_DEBUG_SPLIT) THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Severity in QA processing
                                                for second Split contract ' || x_return_status);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Name -> ' || lt2_msg_tbl(i).name);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Description -> ' || lt2_msg_tbl(i).description);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Package Name -> ' || lt2_msg_tbl(i).package_name);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Procedure Name -> ' || lt2_msg_tbl(i).procedure_name);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Error Status -> ' || lt2_msg_tbl(i).error_status);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Error Severity -> ' || lt2_msg_tbl(i).severity);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error data : Data -> ' || lt2_msg_tbl(i).data);
          END IF;

          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = lt2_msg_tbl.LAST);
        i := lt2_msg_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       -- halt validation as it has no parent record
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- Now we are submitting the the second contract for stream Generation.
    OKL_LA_STREAM_PUB.GEN_INTR_EXTR_STREAM(p_api_version         => p_api_version,
                                              p_init_msg_list       => p_init_msg_list,
                                              x_return_status       => x_return_status,
                                              x_msg_count           => x_msg_count,
                                              x_msg_data            => x_msg_data,
                                              p_khr_id              => p_new2_contract_id,
                                              p_generation_ctx_code => 'AUTH',
                                              x_trx_number          => x_trx2_number,
                                              x_trx_status          => x_trx2_status);


    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'OKL_LA_STREAM_PUB.GEN_INTR_EXTR_STREAM procedure completed with '
                                         || x_return_status || ' for second Split contract');
      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
      END IF;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We are using the below since we have commit the workflow
    -- Of generating the Streams
    --l_stream_path := okl_streams_util.get_pricing_engine (p_khr_id => p_new2_contract_id);
    okl_streams_util.get_pricing_engine
                         (p_khr_id => p_new2_contract_id,
                          x_pricing_engine => l_stream_path,
                          x_return_status => x_return_status
                         );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --IF (p_commit = OKL_API.G_TRUE AND (FND_PROFILE.VALUE('OKL_STREAMS_GEN_PATH') = 'EXTERNAL')) THEN
    IF (p_commit = OKL_API.G_TRUE AND (l_stream_path = 'EXTERNAL')) THEN
       COMMIT;
    END IF;

    -- Need to make sure that the stream generation process has actually completed successfully
    -- for that second contract
    --IF (FND_PROFILE.VALUE('OKL_STREAMS_GEN_PATH') = 'EXTERNAL') THEN
    IF (l_stream_path = 'EXTERNAL') THEN
      IF (G_DEBUG_SPLIT) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'External Stream Generation in progress
                                            for second Split contract ..');
      END IF;
      FOR r_ok_stream IN c_ok_stream(p_khr_id => p_new2_contract_id) LOOP
        LOOP
          OPEN  c_ok_stream_loop(p_khr_id    => p_new2_contract_id,
                                 p_stream_id => r_ok_stream.id);
          FETCH c_ok_stream_loop INTO lv2_sis_code, lv2_sts_code;
          IF c_ok_stream_loop%NOTFOUND THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_NO_MATCHING_RECORD,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'OKL_STREAM_INTERFACES.SIS_CODE');
            x_return_status := OKL_API.G_RET_STS_ERROR;

            IF (G_DEBUG_SPLIT) THEN
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'External Stream Generation information missing
                                         for second Split contract ' || x_return_status);
            END IF;

            EXIT WHEN(x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          CLOSE c_ok_stream_loop;

          IF lv2_sis_code = 'PROCESS_COMPLETE'AND
             lv2_sts_code = 'COMPLETE' THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
            EXIT WHEN(lv2_sis_code = 'PROCESS_COMPLETE');
          ELSIF lv2_sis_code NOT IN ('PROCESSING_REQUEST', 'PROCESS_COMPLETE', 'RET_DATA_RECEIVED') THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_ERROR_STR_GEN);
            x_return_status := OKL_API.G_RET_STS_ERROR;
            EXIT WHEN(x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          -- need below because of performance issue
          dbms_lock.sleep(5);
        END LOOP;
        IF x_return_status = OKL_API.G_RET_STS_ERROR THEN

          IF (G_DEBUG_SPLIT) THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'External Stream Generation completion status
                                         for second Split contract :' || x_return_status);
          END IF;

          EXIT WHEN(x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
      END LOOP;
    END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN  c_get_sts_code(p_khr_id => p_new2_contract_id);
    FETCH c_get_sts_code INTO lv2_sts_code;
    IF c_get_sts_code%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_HEADERS_B.STS_CODE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c_get_sts_code;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Post Stream generation Contract status for second
                                        Split contract : ' || lv2_sts_code);

    IF lv2_sts_code <> 'COMPLETE' THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ERROR_STR_GEN);
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- We are now doing post stream generation process for second contract
    -- Like the Journal entries and Booking of the contract
    split_contract_after_yield(p_api_version    => p_api_version,
                               p_init_msg_list  => p_init_msg_list,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_chr_id         => p_new2_contract_id);

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'split_contract_after_yield procedure
          completed for second contract with status ' || x_return_status);
      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
      END IF;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now post the Journal Entries into GL for the first contract
    FOR r_get_source_id IN c_get_source_id(p_khr_id => p_new1_contract_id) LOOP
      OKL_ACCOUNT_DIST_PUB.UPDATE_POST_TO_GL(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_source_id     => r_get_source_id.id,
                            p_source_table  => 'OKL_TXL_CNTRCT_LNS');
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'OKL_ACCOUNT_DIST_PUB.UPDATE_POST_TO_GL
       procedure completed for first contract with status ' || x_return_status);
      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
      END IF;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now post the Journal Entries into GL for the second contract
    FOR r_get_source_id IN c_get_source_id(p_khr_id => p_new2_contract_id) LOOP
      OKL_ACCOUNT_DIST_PUB.UPDATE_POST_TO_GL(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_source_id     => r_get_source_id.id,
                            p_source_table  => 'OKL_TXL_CNTRCT_LNS');
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'OKL_ACCOUNT_DIST_PUB.UPDATE_POST_TO_GL
       procedure completed for second contract with status ' || x_return_status);
      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message : ' || x_msg_data);
      END IF;
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*
   -- mvasudev, 08/23/2004
   -- Code change to enable Business Event
   */
	raise_business_event(x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*
   -- mvasudev, 08/23/2004
   -- END, Code change to enable Business Event
   */
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );

    IF (G_DEBUG_SPLIT) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '+--- End Split Contract Process Flow ---+');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF c_ok_stream%ISOPEN THEN
        CLOSE c_ok_stream;
      END IF;
      IF c_get_source_id%ISOPEN THEN
        CLOSE c_get_source_id;
      END IF;
      IF c_ok_stream_loop%ISOPEN THEN
        CLOSE c_ok_stream_loop;
      END IF;
      IF c_org_csr%ISOPEN THEN
        CLOSE c_org_csr;
      END IF;
      l_delete_contract_line(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_contract_id    => p_new1_contract_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ERROR_CLEAN_SPK);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ERROR_CLEAN_SPK);
      END IF;
      l_delete_contract_line(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_contract_id    => p_new2_contract_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ERROR_CLEAN_SPK);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ERROR_CLEAN_SPK);
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF c_ok_stream%ISOPEN THEN
        CLOSE c_ok_stream;
      END IF;
      IF c_get_sts_code%ISOPEN THEN
        CLOSE c_get_sts_code;
      END IF;
      IF c_get_source_id%ISOPEN THEN
        CLOSE c_get_source_id;
      END IF;
      IF c_ok_stream_loop%ISOPEN THEN
        CLOSE c_ok_stream_loop;
      END IF;
      IF c_org_csr%ISOPEN THEN
        CLOSE c_org_csr;
      END IF;
      l_delete_contract_line(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_contract_id    => p_new1_contract_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ERROR_CLEAN_SPK);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ERROR_CLEAN_SPK);
      END IF;
      l_delete_contract_line(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_contract_id    => p_new2_contract_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ERROR_CLEAN_SPK);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ERROR_CLEAN_SPK);
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      IF c_ok_stream%ISOPEN THEN
        CLOSE c_ok_stream;
      END IF;
      IF c_get_sts_code%ISOPEN THEN
        CLOSE c_get_sts_code;
      END IF;
      IF c_get_source_id%ISOPEN THEN
        CLOSE c_get_source_id;
      END IF;
      IF c_ok_stream_loop%ISOPEN THEN
        CLOSE c_ok_stream_loop;
      END IF;
      IF c_org_csr%ISOPEN THEN
        CLOSE c_org_csr;
      END IF;
      l_delete_contract_line(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_contract_id    => p_new1_contract_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ERROR_CLEAN_SPK);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ERROR_CLEAN_SPK);
      END IF;
      l_delete_contract_line(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_contract_id    => p_new2_contract_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ERROR_CLEAN_SPK);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ERROR_CLEAN_SPK);
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END post_split_contract;
END OKL_SPLIT_CONTRACT_PVT;

/
