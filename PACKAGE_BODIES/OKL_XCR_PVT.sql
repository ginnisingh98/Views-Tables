--------------------------------------------------------
--  DDL for Package Body OKL_XCR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XCR_PVT" AS
/* $Header: OKLSXCRB.pls 120.4 2007/08/08 12:55:50 arajagop ship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    NULL;
  END api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_EXT_CSH_RCPTS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_EXT_CSH_RCPTS_ALL_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKL_EXT_CSH_RCPTS_TL T SET (
        COMMENTS) = (SELECT
                                  B.COMMENTS
                                FROM OKL_EXT_CSH_RCPTS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_EXT_CSH_RCPTS_TL SUBB, OKL_EXT_CSH_RCPTS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
              ));

    INSERT INTO OKL_EXT_CSH_RCPTS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        COMMENTS,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_EXT_CSH_RCPTS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_EXT_CSH_RCPTS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_CSH_RCPTS_B
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_rec
  -- Description     : To get the record from the Okl_Ext_Csh_Rcpts_B table.
  -- Business Rules  :
  -- Parameters      : p_xcr_rec, x_no_data_found
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the two new
  --                                     columns receipt type and fully applied.
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION get_rec (
    p_xcr_rec                      IN xcr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xcr_rec_type IS
    CURSOR xcr_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            XCB_ID,
            RCT_ID,
            ICR_ID,
            OBJECT_VERSION_NUMBER,
            GL_DATE,
            ITEM_NUMBER,
            REMITTANCE_AMOUNT,
            CURRENCY_CODE,
            RECEIPT_DATE,
            RECEIPT_METHOD,
            CHECK_NUMBER,
            CUSTOMER_NUMBER,
            BILL_TO_LOCATION,
            EXCHANGE_RATE_TYPE,
            EXCHANGE_RATE_DATE,
            EXCHANGE_RATE,
            TRANSIT_ROUTING_NUMBER,
            ACCOUNT,
            CUSTOMER_BANK_NAME,
            CUSTOMER_BANK_BRANCH_NAME,
            REMITTANCE_BANK_NAME,
            REMITTANCE_BANK_BRANCH_NAME,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
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
            LAST_UPDATE_LOGIN,
-- New column receipt type and fully applied added.
     	    RECEIPT_TYPE,
	        FULLY_APPLIED_FLAG,
         EXPIRED_FLAG
      FROM Okl_Ext_Csh_Rcpts_B
     WHERE okl_ext_csh_rcpts_b.id = p_id;
    l_xcr_pk                       xcr_pk_csr%ROWTYPE;
    l_xcr_rec                      xcr_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN xcr_pk_csr (p_xcr_rec.id);
    FETCH xcr_pk_csr INTO
              l_xcr_rec.ID,
              l_xcr_rec.XCB_ID,
              l_xcr_rec.RCT_ID,
              l_xcr_rec.ICR_ID,
              l_xcr_rec.OBJECT_VERSION_NUMBER,
              l_xcr_rec.GL_DATE,
              l_xcr_rec.ITEM_NUMBER,
              l_xcr_rec.REMITTANCE_AMOUNT,
              l_xcr_rec.CURRENCY_CODE,
              l_xcr_rec.RECEIPT_DATE,
              l_xcr_rec.RECEIPT_METHOD,
              l_xcr_rec.CHECK_NUMBER,
              l_xcr_rec.CUSTOMER_NUMBER,
              l_xcr_rec.BILL_TO_LOCATION,
              l_xcr_rec.EXCHANGE_RATE_TYPE,
              l_xcr_rec.EXCHANGE_RATE_DATE,
              l_xcr_rec.EXCHANGE_RATE,
              l_xcr_rec.TRANSIT_ROUTING_NUMBER,
              l_xcr_rec.ACCOUNT,
              l_xcr_rec.CUSTOMER_BANK_NAME,
              l_xcr_rec.CUSTOMER_BANK_BRANCH_NAME,
              l_xcr_rec.REMITTANCE_BANK_NAME,
              l_xcr_rec.REMITTANCE_BANK_BRANCH_NAME,
              l_xcr_rec.REQUEST_ID,
              l_xcr_rec.PROGRAM_APPLICATION_ID,
              l_xcr_rec.PROGRAM_ID,
              l_xcr_rec.PROGRAM_UPDATE_DATE,
              l_xcr_rec.ORG_ID,
              l_xcr_rec.ATTRIBUTE_CATEGORY,
              l_xcr_rec.ATTRIBUTE1,
              l_xcr_rec.ATTRIBUTE2,
              l_xcr_rec.ATTRIBUTE3,
              l_xcr_rec.ATTRIBUTE4,
              l_xcr_rec.ATTRIBUTE5,
              l_xcr_rec.ATTRIBUTE6,
              l_xcr_rec.ATTRIBUTE7,
              l_xcr_rec.ATTRIBUTE8,
              l_xcr_rec.ATTRIBUTE9,
              l_xcr_rec.ATTRIBUTE10,
              l_xcr_rec.ATTRIBUTE11,
              l_xcr_rec.ATTRIBUTE12,
              l_xcr_rec.ATTRIBUTE13,
              l_xcr_rec.ATTRIBUTE14,
              l_xcr_rec.ATTRIBUTE15,
              l_xcr_rec.CREATED_BY,
              l_xcr_rec.CREATION_DATE,
              l_xcr_rec.LAST_UPDATED_BY,
              l_xcr_rec.LAST_UPDATE_DATE,
              l_xcr_rec.LAST_UPDATE_LOGIN,
-- New column receipt type and fully applied added.
	          l_xcr_rec.RECEIPT_TYPE,
    	      l_xcr_rec.FULLY_APPLIED_FLAG,
           l_xcr_rec.EXPIRED_FLAG;
    x_no_data_found := xcr_pk_csr%NOTFOUND;
    CLOSE xcr_pk_csr;
    RETURN(l_xcr_rec);
  END get_rec;

  FUNCTION get_rec (
    p_xcr_rec                      IN xcr_rec_type
  ) RETURN xcr_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xcr_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_CSH_RCPTS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_ext_csh_rcpts_tl_rec     IN okl_ext_csh_rcpts_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_ext_csh_rcpts_tl_rec_type IS
    CURSOR okl_ext_csh_rcpts_tl_pk_csr (p_id                 IN NUMBER,
                                        p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ext_Csh_Rcpts_Tl
     WHERE okl_ext_csh_rcpts_tl.id = p_id
       AND okl_ext_csh_rcpts_tl.LANGUAGE = p_language;
    l_okl_ext_csh_rcpts_tl_pk      okl_ext_csh_rcpts_tl_pk_csr%ROWTYPE;
    l_okl_ext_csh_rcpts_tl_rec     okl_ext_csh_rcpts_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ext_csh_rcpts_tl_pk_csr (p_okl_ext_csh_rcpts_tl_rec.id,
                                      p_okl_ext_csh_rcpts_tl_rec.LANGUAGE);
    FETCH okl_ext_csh_rcpts_tl_pk_csr INTO
              l_okl_ext_csh_rcpts_tl_rec.ID,
              l_okl_ext_csh_rcpts_tl_rec.LANGUAGE,
              l_okl_ext_csh_rcpts_tl_rec.SOURCE_LANG,
              l_okl_ext_csh_rcpts_tl_rec.SFWT_FLAG,
              l_okl_ext_csh_rcpts_tl_rec.COMMENTS,
              l_okl_ext_csh_rcpts_tl_rec.CREATED_BY,
              l_okl_ext_csh_rcpts_tl_rec.CREATION_DATE,
              l_okl_ext_csh_rcpts_tl_rec.LAST_UPDATED_BY,
              l_okl_ext_csh_rcpts_tl_rec.LAST_UPDATE_DATE,
              l_okl_ext_csh_rcpts_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ext_csh_rcpts_tl_pk_csr%NOTFOUND;
    CLOSE okl_ext_csh_rcpts_tl_pk_csr;
    RETURN(l_okl_ext_csh_rcpts_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_ext_csh_rcpts_tl_rec     IN okl_ext_csh_rcpts_tl_rec_type
  ) RETURN okl_ext_csh_rcpts_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_ext_csh_rcpts_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_CSH_RCPTS_V
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_rec
  -- Description     : To get the record from the Okl_Ext_Csh_Rcpts_B table.
  -- Business Rules  :
  -- Parameters      : p_xcrv_rec, x_no_data_found
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the two new
  --                                     columns receipt type and fully applied.
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION get_rec (
    p_xcrv_rec                     IN xcrv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xcrv_rec_type IS
    CURSOR okl_xcrv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            XCB_ID,
            RCT_ID,
            ICR_ID,
            GL_DATE,
            ITEM_NUMBER,
            REMITTANCE_AMOUNT,
            CURRENCY_CODE,
            RECEIPT_DATE,
            RECEIPT_METHOD,
            CHECK_NUMBER,
            COMMENTS,
            CUSTOMER_NUMBER,
            BILL_TO_LOCATION,
            EXCHANGE_RATE_TYPE,
            EXCHANGE_RATE_DATE,
            EXCHANGE_RATE,
            TRANSIT_ROUTING_NUMBER,
            ACCOUNT,
            CUSTOMER_BANK_NAME,
            CUSTOMER_BANK_BRANCH_NAME,
            REMITTANCE_BANK_NAME,
            REMITTANCE_BANK_BRANCH_NAME,
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
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
-- New column receipt type and fully applied added.
	        RECEIPT_TYPE,
	        FULLY_APPLIED_FLAG,
         EXPIRED_FLAG
      FROM Okl_Ext_Csh_Rcpts_V
     WHERE okl_ext_csh_rcpts_v.id = p_id;
    l_okl_xcrv_pk                  okl_xcrv_pk_csr%ROWTYPE;
    l_xcrv_rec                     xcrv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_xcrv_pk_csr (p_xcrv_rec.id);
    FETCH okl_xcrv_pk_csr INTO
              l_xcrv_rec.ID,
              l_xcrv_rec.OBJECT_VERSION_NUMBER,
              l_xcrv_rec.SFWT_FLAG,
              l_xcrv_rec.XCB_ID,
              l_xcrv_rec.RCT_ID,
              l_xcrv_rec.ICR_ID,
              l_xcrv_rec.GL_DATE,
              l_xcrv_rec.ITEM_NUMBER,
              l_xcrv_rec.REMITTANCE_AMOUNT,
              l_xcrv_rec.CURRENCY_CODE,
              l_xcrv_rec.RECEIPT_DATE,
              l_xcrv_rec.RECEIPT_METHOD,
              l_xcrv_rec.CHECK_NUMBER,
              l_xcrv_rec.COMMENTS,
              l_xcrv_rec.CUSTOMER_NUMBER,
              l_xcrv_rec.BILL_TO_LOCATION,
              l_xcrv_rec.EXCHANGE_RATE_TYPE,
              l_xcrv_rec.EXCHANGE_RATE_DATE,
              l_xcrv_rec.EXCHANGE_RATE,
              l_xcrv_rec.TRANSIT_ROUTING_NUMBER,
              l_xcrv_rec.ACCOUNT,
              l_xcrv_rec.CUSTOMER_BANK_NAME,
              l_xcrv_rec.CUSTOMER_BANK_BRANCH_NAME,
              l_xcrv_rec.REMITTANCE_BANK_NAME,
              l_xcrv_rec.REMITTANCE_BANK_BRANCH_NAME,
              l_xcrv_rec.ATTRIBUTE_CATEGORY,
              l_xcrv_rec.ATTRIBUTE1,
              l_xcrv_rec.ATTRIBUTE2,
              l_xcrv_rec.ATTRIBUTE3,
              l_xcrv_rec.ATTRIBUTE4,
              l_xcrv_rec.ATTRIBUTE5,
              l_xcrv_rec.ATTRIBUTE6,
              l_xcrv_rec.ATTRIBUTE7,
              l_xcrv_rec.ATTRIBUTE8,
              l_xcrv_rec.ATTRIBUTE9,
              l_xcrv_rec.ATTRIBUTE10,
              l_xcrv_rec.ATTRIBUTE11,
              l_xcrv_rec.ATTRIBUTE12,
              l_xcrv_rec.ATTRIBUTE13,
              l_xcrv_rec.ATTRIBUTE14,
              l_xcrv_rec.ATTRIBUTE15,
              l_xcrv_rec.REQUEST_ID,
              l_xcrv_rec.PROGRAM_APPLICATION_ID,
              l_xcrv_rec.PROGRAM_ID,
              l_xcrv_rec.PROGRAM_UPDATE_DATE,
              l_xcrv_rec.ORG_ID,
              l_xcrv_rec.CREATED_BY,
              l_xcrv_rec.CREATION_DATE,
              l_xcrv_rec.LAST_UPDATED_BY,
              l_xcrv_rec.LAST_UPDATE_DATE,
              l_xcrv_rec.LAST_UPDATE_LOGIN,
-- New column receipt type and fully applied added.
              l_xcrv_rec.RECEIPT_TYPE,
	             l_xcrv_rec.FULLY_APPLIED_FLAG,
              l_xcrv_rec.EXPIRED_FLAG;
    x_no_data_found := okl_xcrv_pk_csr%NOTFOUND;
    CLOSE okl_xcrv_pk_csr;
    RETURN(l_xcrv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_xcrv_rec                     IN xcrv_rec_type
  ) RETURN xcrv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xcrv_rec, l_row_notfound));  -- removed by bruno 04192001
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_EXT_CSH_RCPTS_V --
  ---------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : null_out_defaults
  -- Description     : If the field has default values then equate it to null.
  -- Business Rules  :
  -- Parameters      : p_xcrv_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the two new
  --                                     columns receipt type and fully applied.
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION null_out_defaults (p_xcrv_rec	IN xcrv_rec_type)
  RETURN xcrv_rec_type IS

  l_xcrv_rec	xcrv_rec_type := p_xcrv_rec;

  BEGIN
    IF (l_xcrv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.object_version_number := NULL;
    END IF;
    IF (l_xcrv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_xcrv_rec.xcb_id = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.xcb_id := NULL;
    END IF;
    IF (l_xcrv_rec.rct_id = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.rct_id := NULL;
    END IF;
    IF (l_xcrv_rec.icr_id = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.icr_id := NULL;
    END IF;
    IF (l_xcrv_rec.gl_date = Okl_Api.G_MISS_DATE) THEN
      l_xcrv_rec.gl_date := NULL;
    END IF;
    IF (l_xcrv_rec.item_number = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.item_number := NULL;
    END IF;
    IF (l_xcrv_rec.remittance_amount = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.remittance_amount := NULL;
    END IF;
    IF (l_xcrv_rec.currency_code = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.currency_code := NULL;
    END IF;
    IF (l_xcrv_rec.receipt_date = Okl_Api.G_MISS_DATE) THEN
      l_xcrv_rec.receipt_date := NULL;
    END IF;
    IF (l_xcrv_rec.receipt_method = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.receipt_method := NULL;
    END IF;
    IF (l_xcrv_rec.check_number = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.check_number := NULL;
    END IF;
    IF (l_xcrv_rec.comments = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.comments := NULL;
    END IF;
    IF (l_xcrv_rec.customer_number = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.customer_number := NULL;
    END IF;
    IF (l_xcrv_rec.bill_to_location = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.bill_to_location := NULL;
    END IF;
    IF (l_xcrv_rec.exchange_rate_type = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.exchange_rate_type := NULL;
    END IF;
    IF (l_xcrv_rec.exchange_rate_date = Okl_Api.G_MISS_DATE) THEN
      l_xcrv_rec.exchange_rate_date := NULL;
    END IF;
    IF (l_xcrv_rec.exchange_rate = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.exchange_rate := NULL;
    END IF;
    IF (l_xcrv_rec.transit_routing_number = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.transit_routing_number := NULL;
    END IF;
    IF (l_xcrv_rec.account = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.account := NULL;
    END IF;
    IF (l_xcrv_rec.customer_bank_name = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.customer_bank_name := NULL;
    END IF;
    IF (l_xcrv_rec.customer_bank_branch_name = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.customer_bank_branch_name := NULL;
    END IF;
    IF (l_xcrv_rec.remittance_bank_name = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.remittance_bank_name := NULL;
    END IF;
    IF (l_xcrv_rec.remittance_bank_branch_name = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.remittance_bank_branch_name := NULL;
    END IF;
    IF (l_xcrv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute_category := NULL;
    END IF;
    IF (l_xcrv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute1 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute2 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute3 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute4 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute5 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute6 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute7 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute8 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute9 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute10 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute11 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute12 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute13 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute14 := NULL;
    END IF;
    IF (l_xcrv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.attribute15 := NULL;
    END IF;
    IF (l_xcrv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.request_id := NULL;
    END IF;
    IF (l_xcrv_rec.program_application_id = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.program_application_id := NULL;
    END IF;
    IF (l_xcrv_rec.program_id = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.program_id := NULL;
    END IF;
    IF (l_xcrv_rec.program_update_date = Okl_Api.G_MISS_DATE) THEN
      l_xcrv_rec.program_update_date := NULL;
    END IF;
    IF (l_xcrv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.org_id := NULL;
    END IF;
    IF (l_xcrv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.created_by := NULL;
    END IF;
    IF (l_xcrv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_xcrv_rec.creation_date := NULL;
    END IF;
    IF (l_xcrv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.last_updated_by := NULL;
    END IF;
    IF (l_xcrv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_xcrv_rec.last_update_date := NULL;
    END IF;
    IF (l_xcrv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_xcrv_rec.last_update_login := NULL;
    END IF;
-- New column receipt type and fully applied added.
    IF (l_xcrv_rec.receipt_type = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.receipt_type := NULL;
    END IF;
    IF (l_xcrv_rec.fully_applied_flag = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.fully_applied_flag := NULL;
    END IF;
    IF (l_xcrv_rec.expired_flag = Okl_Api.G_MISS_CHAR) THEN
      l_xcrv_rec.expired_flag := NULL;
    END IF;

    RETURN(l_xcrv_rec);
  END null_out_defaults;


  ---------------------------------------------------------------------------
  -- POST TAPI CODE  04/17/2001
  ---------------------------------------------------------------------------

-- Start of comments
-- Procedure Name  : validate_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_id(p_xcrv_rec 		IN 	xcrv_rec_type,
                      x_return_status 	OUT NOCOPY VARCHAR2) IS

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
   --check not null
   IF (p_xcrv_rec.id IS NULL) OR (p_xcrv_rec.id = Okl_Api.G_MISS_NUM) THEN
     x_return_status:=Okl_Api.G_RET_STS_ERROR;
     --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_REQUIRED_VALUE,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'ID');
     -- RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END validate_id;

-- Start of comments
-- Procedure Name  : validate_org_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE validate_org_id (p_xcrv_rec IN xcrv_rec_type,

  			                 x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN

      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      x_return_status := Okl_Util.check_org_id(p_xcrv_rec.org_id);

  END validate_org_id;

/*
-- Start of comments
-- Procedure Name  : validate_xcb_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_xcb_id(p_xcrv_rec 		IN 	xcrv_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_xcb_id_csr IS
   SELECT '1'
   FROM   okl_ext_csh_btchs_b
   WHERE  id = p_xcrv_rec.xcb_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;

 IF p_xcrv_rec.xcb_id IS NOT NULL THEN

   --check FK Relation with okl_trx_csh_batch_b
   OPEN l_xcb_id_csr;
   FETCH l_xcb_id_csr INTO l_dummy_var;
   CLOSE l_xcb_id_csr;
   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                        p_msg_name     => G_NO_PARENT_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'XCB_ID',
                        p_token2       => G_CHILD_TABLE_TOKEN,
                        p_token2_value => G_VIEW,
                        p_token3       => G_PARENT_TABLE_TOKEN,
                        p_token3_value => 'OKL_EXT_CSH_BTCHS_B');
  RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

 END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END validate_xcb_id;
*/
-- Start of comments
-- Procedure Name  : validate_rct_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_rct_id(p_xcrv_rec 		IN 	xcrv_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_rct_id_csr IS
   SELECT '1'
   FROM   okl_trx_csh_receipt_b
   WHERE  id = p_xcrv_rec.rct_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;

 IF p_xcrv_rec.rct_id IS NOT NULL THEN

   --check FK Relation with okl_trx_csh_batch_b
   OPEN l_rct_id_csr;
   FETCH l_rct_id_csr INTO l_dummy_var;
   CLOSE l_rct_id_csr;
   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                        p_msg_name     => G_NO_PARENT_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'RCT_ID',
                        p_token2       => G_CHILD_TABLE_TOKEN,
                        p_token2_value => G_VIEW,
                        p_token3       => G_PARENT_TABLE_TOKEN,
                        p_token3_value => 'OKL_TRX_CSH_RECEIPT_B');
  RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

 END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END validate_rct_id;

  ---------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_receipt_type
  -- Description     : Receipt type can have only two values 'ADV and 'REG'.
  -- Business Rules  :
  -- Parameters      : p_xcrv_rec, x_return_status
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal created.
  -- End of comments
----------------------------------------------------------------------------

PROCEDURE validate_receipt_type(p_xcrv_rec 		IN 	xcrv_rec_type,
                      x_return_status 	OUT NOCOPY VARCHAR2) IS

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
   --check not null
   IF (p_xcrv_rec.receipt_type  <> 'REG') AND  (p_xcrv_rec.receipt_type  <> 'ADV')  THEN
     x_return_status:=Okl_Api.G_RET_STS_ERROR;
     --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_USER_MESSAGE,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'RECEIPT TYPE');
     RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END validate_receipt_type;

  ---------------------------------------------------------------------------
  -- POST TAPI CODE ENDS HERE  04/17/2001
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_EXT_CSH_RCPTS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_xcrv_rec IN  xcrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	   -- Added 04/16/2001 -- Bruno Vaghela
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

  --Added 04/17/2001 Bruno Vaghela ---

    validate_id(p_xcrv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_org_id(p_xcrv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
/*
    validate_xcb_id(p_xcrv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
*/
	validate_rct_id(p_xcrv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


-- end 04/17/2001 Bruno Vaghela ---

-- added 05-AUG-04 abindal--
    validate_receipt_type(p_xcrv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
--end 05-AUG-04 abindal--


    IF p_xcrv_rec.id = Okl_Api.G_MISS_NUM OR
       p_xcrv_rec.id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_xcrv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
          p_xcrv_rec.object_version_number IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_EXT_CSH_RCPTS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_xcrv_rec IN xcrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : migrate
  -- Description     : This procedure is used for copying the record structure.
  -- Business Rules  :
  -- Parameters      : p_from, p_to
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the two new
  --                                     columns receipt type and fully applied.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN xcrv_rec_type,
    p_to	IN OUT NOCOPY xcr_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.xcb_id := p_from.xcb_id;
    p_to.rct_id := p_from.rct_id;
    p_to.icr_id := p_from.icr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.gl_date := p_from.gl_date;
    p_to.item_number := p_from.item_number;
    p_to.remittance_amount := p_from.remittance_amount;
    p_to.currency_code := p_from.currency_code;
    p_to.receipt_date := p_from.receipt_date;
    p_to.receipt_method := p_from.receipt_method;
    p_to.check_number := p_from.check_number;
    p_to.customer_number := p_from.customer_number;
    p_to.bill_to_location := p_from.bill_to_location;
    p_to.exchange_rate_type := p_from.exchange_rate_type;
    p_to.exchange_rate_date := p_from.exchange_rate_date;
    p_to.exchange_rate := p_from.exchange_rate;
    p_to.transit_routing_number := p_from.transit_routing_number;
    p_to.account := p_from.account;
    p_to.customer_bank_name := p_from.customer_bank_name;
    p_to.customer_bank_branch_name := p_from.customer_bank_branch_name;
    p_to.remittance_bank_name := p_from.remittance_bank_name;
    p_to.remittance_bank_branch_name := p_from.remittance_bank_branch_name;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
-- New column receipt type and fully applied added.
    p_to.receipt_type := p_from.receipt_type;
    p_to.fully_applied_flag := p_from.fully_applied_flag;
    p_to.expired_flag := p_from.expired_flag;
  END migrate;
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : migrate
  -- Description     : This procedure is used for copying the record structure.
  -- Business Rules  :
  -- Parameters      : p_from, p_to
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the two new
  --                                     columns receipt type and fully applied.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN xcr_rec_type,
    p_to	IN OUT NOCOPY xcrv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.xcb_id := p_from.xcb_id;
    p_to.rct_id := p_from.rct_id;
    p_to.icr_id := p_from.icr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.gl_date := p_from.gl_date;
    p_to.item_number := p_from.item_number;
    p_to.remittance_amount := p_from.remittance_amount;
    p_to.currency_code := p_from.currency_code;
    p_to.receipt_date := p_from.receipt_date;
    p_to.receipt_method := p_from.receipt_method;
    p_to.check_number := p_from.check_number;
    p_to.customer_number := p_from.customer_number;
    p_to.bill_to_location := p_from.bill_to_location;
    p_to.exchange_rate_type := p_from.exchange_rate_type;
    p_to.exchange_rate_date := p_from.exchange_rate_date;
    p_to.exchange_rate := p_from.exchange_rate;
    p_to.transit_routing_number := p_from.transit_routing_number;
    p_to.account := p_from.account;
    p_to.customer_bank_name := p_from.customer_bank_name;
    p_to.customer_bank_branch_name := p_from.customer_bank_branch_name;
    p_to.remittance_bank_name := p_from.remittance_bank_name;
    p_to.remittance_bank_branch_name := p_from.remittance_bank_branch_name;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
-- New column receipt type and fully applied added.
    p_to.receipt_type := p_from.receipt_type;
    p_to.fully_applied_flag := p_from.fully_applied_flag;
    p_to.expired_flag := p_from.expired_flag;
  END migrate;
  PROCEDURE migrate (
    p_from	IN xcrv_rec_type,
    p_to	IN OUT NOCOPY okl_ext_csh_rcpts_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_ext_csh_rcpts_tl_rec_type,
    p_to	IN OUT NOCOPY xcrv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_EXT_CSH_RCPTS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xcrv_rec                     xcrv_rec_type := p_xcrv_rec;
    l_xcr_rec                      xcr_rec_type;
    l_okl_ext_csh_rcpts_tl_rec     okl_ext_csh_rcpts_tl_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_xcrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
--    l_return_status := Validate_Record(l_xcrv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:XCRV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xcrv_tbl.COUNT > 0) THEN
      i := p_xcrv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xcrv_rec                     => p_xcrv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_xcrv_tbl.LAST);
        i := p_xcrv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- insert_row for:OKL_EXT_CSH_RCPTS_B --
  ----------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
 -- Procedure Name   : insert_row
  -- Description     : Inserts the row in the table Okl_Ext_Csh_Rcpts_B.
  -- Business Rules  :
  -- Parameters      : p_init_msg_list, x_return_status, x_msg_count, x_msg_data,
  --                   p_xcr_rec, x_xcr_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the two new
  --                                     columns receipt type and fully applied.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcr_rec                      IN xcr_rec_type,
    x_xcr_rec                      OUT NOCOPY xcr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xcr_rec                      xcr_rec_type := p_xcr_rec;
    l_def_xcr_rec                  xcr_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_EXT_CSH_RCPTS_B --
    --------------------------------------------

    FUNCTION Set_Attributes (
      p_xcr_rec IN  xcr_rec_type,
      x_xcr_rec OUT NOCOPY xcr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xcr_rec := p_xcr_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_xcr_rec,                         -- IN
      l_xcr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_EXT_CSH_RCPTS_B(
        id,
        xcb_id,
        rct_id,
        icr_id,
        object_version_number,
        gl_date,
        item_number,
        remittance_amount,
        currency_code,
        receipt_date,
        receipt_method,
        check_number,
        customer_number,
        bill_to_location,
        exchange_rate_type,
        exchange_rate_date,
        exchange_rate,
        transit_routing_number,
        account,
        customer_bank_name,
        customer_bank_branch_name,
        remittance_bank_name,
        remittance_bank_branch_name,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
-- New column receipt type and fully applied added.
        receipt_type,
	       fully_applied_flag,
        expired_flag)
      VALUES (
        l_xcr_rec.id,
        l_xcr_rec.xcb_id,
        l_xcr_rec.rct_id,
        l_xcr_rec.icr_id,
        l_xcr_rec.object_version_number,
        l_xcr_rec.gl_date,
        l_xcr_rec.item_number,
        l_xcr_rec.remittance_amount,
        l_xcr_rec.currency_code,
        l_xcr_rec.receipt_date,
        l_xcr_rec.receipt_method,
        l_xcr_rec.check_number,
        l_xcr_rec.customer_number,
        l_xcr_rec.bill_to_location,
        l_xcr_rec.exchange_rate_type,
        l_xcr_rec.exchange_rate_date,
        l_xcr_rec.exchange_rate,
        l_xcr_rec.transit_routing_number,
        l_xcr_rec.account,
        l_xcr_rec.customer_bank_name,
        l_xcr_rec.customer_bank_branch_name,
        l_xcr_rec.remittance_bank_name,
        l_xcr_rec.remittance_bank_branch_name,
        l_xcr_rec.request_id,
        l_xcr_rec.program_application_id,
        l_xcr_rec.program_id,
        l_xcr_rec.program_update_date,
        l_xcr_rec.org_id,
        l_xcr_rec.attribute_category,
        l_xcr_rec.attribute1,
        l_xcr_rec.attribute2,
        l_xcr_rec.attribute3,
        l_xcr_rec.attribute4,
        l_xcr_rec.attribute5,
        l_xcr_rec.attribute6,
        l_xcr_rec.attribute7,
        l_xcr_rec.attribute8,
        l_xcr_rec.attribute9,
        l_xcr_rec.attribute10,
        l_xcr_rec.attribute11,
        l_xcr_rec.attribute12,
        l_xcr_rec.attribute13,
        l_xcr_rec.attribute14,
        l_xcr_rec.attribute15,
        l_xcr_rec.created_by,
        l_xcr_rec.creation_date,
        l_xcr_rec.last_updated_by,
        l_xcr_rec.last_update_date,
        l_xcr_rec.last_update_login,
-- New column receipt type and fully applied added.
    	l_xcr_rec.receipt_type,
    	l_xcr_rec.fully_applied_flag,
     l_xcr_rec.expired_flag);
    -- Set OUT values
    x_xcr_rec := l_xcr_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -----------------------------------------
  -- insert_row for:OKL_EXT_CSH_RCPTS_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ext_csh_rcpts_tl_rec     IN okl_ext_csh_rcpts_tl_rec_type,
    x_okl_ext_csh_rcpts_tl_rec     OUT NOCOPY okl_ext_csh_rcpts_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_ext_csh_rcpts_tl_rec     okl_ext_csh_rcpts_tl_rec_type := p_okl_ext_csh_rcpts_tl_rec;
    ldefoklextcshrcptstlrec        okl_ext_csh_rcpts_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKL_EXT_CSH_RCPTS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_ext_csh_rcpts_tl_rec IN  okl_ext_csh_rcpts_tl_rec_type,
      x_okl_ext_csh_rcpts_tl_rec OUT NOCOPY okl_ext_csh_rcpts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ext_csh_rcpts_tl_rec := p_okl_ext_csh_rcpts_tl_rec;
      x_okl_ext_csh_rcpts_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_ext_csh_rcpts_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_ext_csh_rcpts_tl_rec,        -- IN
      l_okl_ext_csh_rcpts_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_ext_csh_rcpts_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_EXT_CSH_RCPTS_TL(
          id,
          LANGUAGE,
          source_lang,
          sfwt_flag,
          comments,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_ext_csh_rcpts_tl_rec.id,
          l_okl_ext_csh_rcpts_tl_rec.LANGUAGE,
          l_okl_ext_csh_rcpts_tl_rec.source_lang,
          l_okl_ext_csh_rcpts_tl_rec.sfwt_flag,
          l_okl_ext_csh_rcpts_tl_rec.comments,
          l_okl_ext_csh_rcpts_tl_rec.created_by,
          l_okl_ext_csh_rcpts_tl_rec.creation_date,
          l_okl_ext_csh_rcpts_tl_rec.last_updated_by,
          l_okl_ext_csh_rcpts_tl_rec.last_update_date,
          l_okl_ext_csh_rcpts_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_ext_csh_rcpts_tl_rec := l_okl_ext_csh_rcpts_tl_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------
  -- insert_row for:OKL_EXT_CSH_RCPTS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type,
    x_xcrv_rec                     OUT NOCOPY xcrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xcrv_rec                     xcrv_rec_type;
    l_def_xcrv_rec                 xcrv_rec_type;
    l_xcr_rec                      xcr_rec_type;
    lx_xcr_rec                     xcr_rec_type;
    l_okl_ext_csh_rcpts_tl_rec     okl_ext_csh_rcpts_tl_rec_type;
    lx_okl_ext_csh_rcpts_tl_rec    okl_ext_csh_rcpts_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xcrv_rec	IN xcrv_rec_type
    ) RETURN xcrv_rec_type IS
      l_xcrv_rec	xcrv_rec_type := p_xcrv_rec;
    BEGIN
      l_xcrv_rec.CREATION_DATE := SYSDATE;
      l_xcrv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_xcrv_rec.LAST_UPDATE_DATE := l_xcrv_rec.CREATION_DATE;
      l_xcrv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_xcrv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_xcrv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_EXT_CSH_RCPTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xcrv_rec IN  xcrv_rec_type,
      x_xcrv_rec OUT NOCOPY xcrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xcrv_rec := p_xcrv_rec;
      x_xcrv_rec.OBJECT_VERSION_NUMBER := 1;
      x_xcrv_rec.SFWT_FLAG := 'N';
      RETURN(l_return_status);

	  -- POST TAPI GENERATED CODE BEGINS  04/25/2001  Bruno.

	  IF (x_xcrv_rec.request_id IS NULL OR x_xcrv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	     SELECT DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
     	 		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.PROG_APPL_ID),
    			DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
     			DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
   		 INTO
       	 	 	x_xcrv_rec.request_id,
                x_xcrv_rec.program_application_id,
                x_xcrv_rec.program_id,
                x_xcrv_rec.program_update_date
   		 FROM dual;
 	  END IF;

      -- POST TAPI GENERATED CODE ENDS  04/25/2001  Bruno.

    END Set_Attributes;
  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);


    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_xcrv_rec := null_out_defaults(p_xcrv_rec);
    -- Set primary key value
    l_xcrv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_xcrv_rec,                        -- IN
      l_def_xcrv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_xcrv_rec := fill_who_columns(l_def_xcrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xcrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xcrv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_xcrv_rec, l_xcr_rec);
    migrate(l_def_xcrv_rec, l_okl_ext_csh_rcpts_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xcr_rec,
      lx_xcr_rec
    );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xcr_rec, l_def_xcrv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ext_csh_rcpts_tl_rec,
      lx_okl_ext_csh_rcpts_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_ext_csh_rcpts_tl_rec, l_def_xcrv_rec);
    -- Set OUT values
    x_xcrv_rec := l_def_xcrv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:XCRV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type,
    x_xcrv_tbl                     OUT NOCOPY xcrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xcrv_tbl.COUNT > 0) THEN
      i := p_xcrv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xcrv_rec                     => p_xcrv_tbl(i),
          x_xcrv_rec                     => x_xcrv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_xcrv_tbl.LAST);
        i := p_xcrv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- lock_row for:OKL_EXT_CSH_RCPTS_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcr_rec                      IN xcr_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_xcr_rec IN xcr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_EXT_CSH_RCPTS_B
     WHERE ID = p_xcr_rec.id
       AND OBJECT_VERSION_NUMBER = p_xcr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_xcr_rec IN xcr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_EXT_CSH_RCPTS_B
    WHERE ID = p_xcr_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_EXT_CSH_RCPTS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_EXT_CSH_RCPTS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_xcr_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_xcr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_xcr_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_xcr_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okl_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------
  -- lock_row for:OKL_EXT_CSH_RCPTS_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ext_csh_rcpts_tl_rec     IN okl_ext_csh_rcpts_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_ext_csh_rcpts_tl_rec IN okl_ext_csh_rcpts_tl_rec_type) IS
    SELECT *
      FROM OKL_EXT_CSH_RCPTS_TL
     WHERE ID = p_okl_ext_csh_rcpts_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okl_ext_csh_rcpts_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- lock_row for:OKL_EXT_CSH_RCPTS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xcr_rec                      xcr_rec_type;
    l_okl_ext_csh_rcpts_tl_rec     okl_ext_csh_rcpts_tl_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_xcrv_rec, l_xcr_rec);
    migrate(p_xcrv_rec, l_okl_ext_csh_rcpts_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xcr_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ext_csh_rcpts_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:XCRV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xcrv_tbl.COUNT > 0) THEN
      i := p_xcrv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xcrv_rec                     => p_xcrv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_xcrv_tbl.LAST);
        i := p_xcrv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- update_row for:OKL_EXT_CSH_RCPTS_B --
  ----------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
 -- Procedure Name   : update_row
  -- Description     : Updates the row in the table Okl_Ext_Csh_Rcpts_B.
  -- Business Rules  :
  -- Parameters      : p_init_msg_list, x_return_status, x_msg_count, x_msg_data,
  --                   p_xcr_rec, x_xcr_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the two new
  --                                     columns receipt type and fully applied.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcr_rec                      IN xcr_rec_type,
    x_xcr_rec                      OUT NOCOPY xcr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xcr_rec                      xcr_rec_type := p_xcr_rec;
    l_def_xcr_rec                  xcr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------

    FUNCTION populate_new_record (
      p_xcr_rec	IN xcr_rec_type,
      x_xcr_rec	OUT NOCOPY xcr_rec_type
    ) RETURN VARCHAR2 IS
      l_xcr_rec                      xcr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xcr_rec := p_xcr_rec;
      -- Get current database values
      l_xcr_rec := get_rec(p_xcr_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_xcr_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.id := l_xcr_rec.id;
      END IF;
      IF (x_xcr_rec.xcb_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.xcb_id := l_xcr_rec.xcb_id;
      END IF;
      IF (x_xcr_rec.rct_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.rct_id := l_xcr_rec.rct_id;
      END IF;
      IF (x_xcr_rec.icr_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.icr_id := l_xcr_rec.icr_id;
      END IF;
      IF (x_xcr_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.object_version_number := l_xcr_rec.object_version_number;
      END IF;
      IF (x_xcr_rec.gl_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xcr_rec.gl_date := l_xcr_rec.gl_date;
      END IF;
      IF (x_xcr_rec.item_number = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.item_number := l_xcr_rec.item_number;
      END IF;
      IF (x_xcr_rec.remittance_amount = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.remittance_amount := l_xcr_rec.remittance_amount;
      END IF;
      IF (x_xcr_rec.currency_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.currency_code := l_xcr_rec.currency_code;
      END IF;
      IF (x_xcr_rec.receipt_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xcr_rec.receipt_date := l_xcr_rec.receipt_date;
      END IF;
      IF (x_xcr_rec.receipt_method = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.receipt_method := l_xcr_rec.receipt_method;
      END IF;
      IF (x_xcr_rec.check_number = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.check_number := l_xcr_rec.check_number;
      END IF;
      IF (x_xcr_rec.customer_number = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.customer_number := l_xcr_rec.customer_number;
      END IF;
      IF (x_xcr_rec.bill_to_location = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.bill_to_location := l_xcr_rec.bill_to_location;
      END IF;
      IF (x_xcr_rec.exchange_rate_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.exchange_rate_type := l_xcr_rec.exchange_rate_type;
      END IF;
      IF (x_xcr_rec.exchange_rate_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xcr_rec.exchange_rate_date := l_xcr_rec.exchange_rate_date;
      END IF;
      IF (x_xcr_rec.exchange_rate = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.exchange_rate := l_xcr_rec.exchange_rate;
      END IF;
      IF (x_xcr_rec.transit_routing_number = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.transit_routing_number := l_xcr_rec.transit_routing_number;
      END IF;
      IF (x_xcr_rec.account = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.account := l_xcr_rec.account;
      END IF;
      IF (x_xcr_rec.customer_bank_name = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.customer_bank_name := l_xcr_rec.customer_bank_name;
      END IF;
      IF (x_xcr_rec.customer_bank_branch_name = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.customer_bank_branch_name := l_xcr_rec.customer_bank_branch_name;
      END IF;
      IF (x_xcr_rec.remittance_bank_name = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.remittance_bank_name := l_xcr_rec.remittance_bank_name;
      END IF;
      IF (x_xcr_rec.remittance_bank_branch_name = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.remittance_bank_branch_name := l_xcr_rec.remittance_bank_branch_name;
      END IF;
      IF (x_xcr_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.request_id := l_xcr_rec.request_id;
      END IF;
      IF (x_xcr_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.program_application_id := l_xcr_rec.program_application_id;
      END IF;
      IF (x_xcr_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.program_id := l_xcr_rec.program_id;
      END IF;
      IF (x_xcr_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xcr_rec.program_update_date := l_xcr_rec.program_update_date;
      END IF;
      IF (x_xcr_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.org_id := l_xcr_rec.org_id;
      END IF;
      IF (x_xcr_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute_category := l_xcr_rec.attribute_category;
      END IF;
      IF (x_xcr_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute1 := l_xcr_rec.attribute1;
      END IF;
      IF (x_xcr_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute2 := l_xcr_rec.attribute2;
      END IF;
      IF (x_xcr_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute3 := l_xcr_rec.attribute3;
      END IF;
      IF (x_xcr_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute4 := l_xcr_rec.attribute4;
      END IF;
      IF (x_xcr_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute5 := l_xcr_rec.attribute5;
      END IF;
      IF (x_xcr_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute6 := l_xcr_rec.attribute6;
      END IF;
      IF (x_xcr_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute7 := l_xcr_rec.attribute7;
      END IF;
      IF (x_xcr_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute8 := l_xcr_rec.attribute8;
      END IF;
      IF (x_xcr_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute9 := l_xcr_rec.attribute9;
      END IF;
      IF (x_xcr_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute10 := l_xcr_rec.attribute10;
      END IF;
      IF (x_xcr_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute11 := l_xcr_rec.attribute11;
      END IF;
      IF (x_xcr_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute12 := l_xcr_rec.attribute12;
      END IF;
      IF (x_xcr_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute13 := l_xcr_rec.attribute13;
      END IF;
      IF (x_xcr_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute14 := l_xcr_rec.attribute14;
      END IF;
      IF (x_xcr_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.attribute15 := l_xcr_rec.attribute15;
      END IF;
      IF (x_xcr_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.created_by := l_xcr_rec.created_by;
      END IF;
      IF (x_xcr_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xcr_rec.creation_date := l_xcr_rec.creation_date;
      END IF;
      IF (x_xcr_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.last_updated_by := l_xcr_rec.last_updated_by;
      END IF;
      IF (x_xcr_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xcr_rec.last_update_date := l_xcr_rec.last_update_date;
      END IF;
      IF (x_xcr_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_xcr_rec.last_update_login := l_xcr_rec.last_update_login;
      END IF;
-- New column receipt type and fully applied added.
      IF (x_xcr_rec.receipt_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.receipt_type := l_xcr_rec.receipt_type;
      END IF;
      IF (x_xcr_rec.fully_applied_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.fully_applied_flag := l_xcr_rec.fully_applied_flag;
      END IF;
      IF (x_xcr_rec.expired_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcr_rec.expired_flag := l_xcr_rec.expired_flag;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_EXT_CSH_RCPTS_B --
    --------------------------------------------

    FUNCTION Set_Attributes (
      p_xcr_rec IN  xcr_rec_type,
      x_xcr_rec OUT NOCOPY xcr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xcr_rec := p_xcr_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_xcr_rec,                         -- IN
      l_xcr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xcr_rec, l_def_xcr_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_EXT_CSH_RCPTS_B
    SET XCB_ID = l_def_xcr_rec.xcb_id,
        RCT_ID = l_def_xcr_rec.rct_id,
        ICR_ID = l_def_xcr_rec.icr_id,
        OBJECT_VERSION_NUMBER = l_def_xcr_rec.object_version_number,
        GL_DATE = l_def_xcr_rec.gl_date,
        ITEM_NUMBER = l_def_xcr_rec.item_number,
        REMITTANCE_AMOUNT = l_def_xcr_rec.remittance_amount,
        CURRENCY_CODE = l_def_xcr_rec.currency_code,
        RECEIPT_DATE = l_def_xcr_rec.receipt_date,
        RECEIPT_METHOD = l_def_xcr_rec.receipt_method,
        CHECK_NUMBER = l_def_xcr_rec.check_number,
        CUSTOMER_NUMBER = l_def_xcr_rec.customer_number,
        BILL_TO_LOCATION = l_def_xcr_rec.bill_to_location,
        EXCHANGE_RATE_TYPE = l_def_xcr_rec.exchange_rate_type,
        EXCHANGE_RATE_DATE = l_def_xcr_rec.exchange_rate_date,
        EXCHANGE_RATE = l_def_xcr_rec.exchange_rate,
        TRANSIT_ROUTING_NUMBER = l_def_xcr_rec.transit_routing_number,
        ACCOUNT = l_def_xcr_rec.account,
        CUSTOMER_BANK_NAME = l_def_xcr_rec.customer_bank_name,
        CUSTOMER_BANK_BRANCH_NAME = l_def_xcr_rec.customer_bank_branch_name,
        REMITTANCE_BANK_NAME = l_def_xcr_rec.remittance_bank_name,
        REMITTANCE_BANK_BRANCH_NAME = l_def_xcr_rec.remittance_bank_branch_name,
        REQUEST_ID = l_def_xcr_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_xcr_rec.program_application_id,
        PROGRAM_ID = l_def_xcr_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_xcr_rec.program_update_date,
        ORG_ID = l_def_xcr_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_xcr_rec.attribute_category,
        ATTRIBUTE1 = l_def_xcr_rec.attribute1,
        ATTRIBUTE2 = l_def_xcr_rec.attribute2,
        ATTRIBUTE3 = l_def_xcr_rec.attribute3,
        ATTRIBUTE4 = l_def_xcr_rec.attribute4,
        ATTRIBUTE5 = l_def_xcr_rec.attribute5,
        ATTRIBUTE6 = l_def_xcr_rec.attribute6,
        ATTRIBUTE7 = l_def_xcr_rec.attribute7,
        ATTRIBUTE8 = l_def_xcr_rec.attribute8,
        ATTRIBUTE9 = l_def_xcr_rec.attribute9,
        ATTRIBUTE10 = l_def_xcr_rec.attribute10,
        ATTRIBUTE11 = l_def_xcr_rec.attribute11,
        ATTRIBUTE12 = l_def_xcr_rec.attribute12,
        ATTRIBUTE13 = l_def_xcr_rec.attribute13,
        ATTRIBUTE14 = l_def_xcr_rec.attribute14,
        ATTRIBUTE15 = l_def_xcr_rec.attribute15,
        CREATED_BY = l_def_xcr_rec.created_by,
        CREATION_DATE = l_def_xcr_rec.creation_date,
        LAST_UPDATED_BY = l_def_xcr_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_xcr_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_xcr_rec.last_update_login,
-- New column receipt type and fully applied added.
	       RECEIPT_TYPE = l_def_xcr_rec.receipt_type,
       	FULLY_APPLIED_FLAG = l_def_xcr_rec.fully_applied_flag,
        EXPIRED_FLAG = l_def_xcr_rec.expired_flag
    WHERE ID = l_def_xcr_rec.id;

    x_xcr_rec := l_def_xcr_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -----------------------------------------
  -- update_row for:OKL_EXT_CSH_RCPTS_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ext_csh_rcpts_tl_rec     IN okl_ext_csh_rcpts_tl_rec_type,
    x_okl_ext_csh_rcpts_tl_rec     OUT NOCOPY okl_ext_csh_rcpts_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_ext_csh_rcpts_tl_rec     okl_ext_csh_rcpts_tl_rec_type := p_okl_ext_csh_rcpts_tl_rec;
    ldefoklextcshrcptstlrec        okl_ext_csh_rcpts_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_ext_csh_rcpts_tl_rec	IN okl_ext_csh_rcpts_tl_rec_type,
      x_okl_ext_csh_rcpts_tl_rec	OUT NOCOPY okl_ext_csh_rcpts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_ext_csh_rcpts_tl_rec     okl_ext_csh_rcpts_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ext_csh_rcpts_tl_rec := p_okl_ext_csh_rcpts_tl_rec;
      -- Get current database values
      l_okl_ext_csh_rcpts_tl_rec := get_rec(p_okl_ext_csh_rcpts_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_ext_csh_rcpts_tl_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_ext_csh_rcpts_tl_rec.id := l_okl_ext_csh_rcpts_tl_rec.id;
      END IF;
      IF (x_okl_ext_csh_rcpts_tl_rec.LANGUAGE = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_ext_csh_rcpts_tl_rec.LANGUAGE := l_okl_ext_csh_rcpts_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_ext_csh_rcpts_tl_rec.source_lang = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_ext_csh_rcpts_tl_rec.source_lang := l_okl_ext_csh_rcpts_tl_rec.source_lang;
      END IF;
      IF (x_okl_ext_csh_rcpts_tl_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_ext_csh_rcpts_tl_rec.sfwt_flag := l_okl_ext_csh_rcpts_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_ext_csh_rcpts_tl_rec.comments = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_ext_csh_rcpts_tl_rec.comments := l_okl_ext_csh_rcpts_tl_rec.comments;
      END IF;
      IF (x_okl_ext_csh_rcpts_tl_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_ext_csh_rcpts_tl_rec.created_by := l_okl_ext_csh_rcpts_tl_rec.created_by;
      END IF;
      IF (x_okl_ext_csh_rcpts_tl_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_ext_csh_rcpts_tl_rec.creation_date := l_okl_ext_csh_rcpts_tl_rec.creation_date;
      END IF;
      IF (x_okl_ext_csh_rcpts_tl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_ext_csh_rcpts_tl_rec.last_updated_by := l_okl_ext_csh_rcpts_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_ext_csh_rcpts_tl_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_ext_csh_rcpts_tl_rec.last_update_date := l_okl_ext_csh_rcpts_tl_rec.last_update_date;
      END IF;
      IF (x_okl_ext_csh_rcpts_tl_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_ext_csh_rcpts_tl_rec.last_update_login := l_okl_ext_csh_rcpts_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_EXT_CSH_RCPTS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_ext_csh_rcpts_tl_rec IN  okl_ext_csh_rcpts_tl_rec_type,
      x_okl_ext_csh_rcpts_tl_rec OUT NOCOPY okl_ext_csh_rcpts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ext_csh_rcpts_tl_rec := p_okl_ext_csh_rcpts_tl_rec;
      x_okl_ext_csh_rcpts_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_ext_csh_rcpts_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_ext_csh_rcpts_tl_rec,        -- IN
      l_okl_ext_csh_rcpts_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_ext_csh_rcpts_tl_rec, ldefoklextcshrcptstlrec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_EXT_CSH_RCPTS_TL
    SET COMMENTS = ldefoklextcshrcptstlrec.comments,
        SOURCE_LANG = ldefoklextcshrcptstlrec.source_lang,
        CREATED_BY = ldefoklextcshrcptstlrec.created_by,
        CREATION_DATE = ldefoklextcshrcptstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklextcshrcptstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklextcshrcptstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklextcshrcptstlrec.last_update_login
    WHERE ID = ldefoklextcshrcptstlrec.id
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_EXT_CSH_RCPTS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklextcshrcptstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_ext_csh_rcpts_tl_rec := ldefoklextcshrcptstlrec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------
  -- update_row for:OKL_EXT_CSH_RCPTS_V --
  ----------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
 -- Procedure Name   : update_row
  -- Description     : Updates the row in the table Okl_Ext_Csh_Rcpts_B.
  -- Business Rules  :
  -- Parameters      : p_init_msg_list, x_return_status, x_msg_count, x_msg_data,
  --                   p_xcrv_rec, x_xcrv_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the two new
  --                                     columns receipt type and fully applied.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type,
    x_xcrv_rec                     OUT NOCOPY xcrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xcrv_rec                     xcrv_rec_type := p_xcrv_rec;
    l_def_xcrv_rec                 xcrv_rec_type;
    l_okl_ext_csh_rcpts_tl_rec     okl_ext_csh_rcpts_tl_rec_type;
    lx_okl_ext_csh_rcpts_tl_rec    okl_ext_csh_rcpts_tl_rec_type;
    l_xcr_rec                      xcr_rec_type;
    lx_xcr_rec                     xcr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xcrv_rec	IN xcrv_rec_type
    ) RETURN xcrv_rec_type IS
      l_xcrv_rec	xcrv_rec_type := p_xcrv_rec;
    BEGIN
      l_xcrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_xcrv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_xcrv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_xcrv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------

    FUNCTION populate_new_record (
      p_xcrv_rec	IN xcrv_rec_type,
      x_xcrv_rec	OUT NOCOPY xcrv_rec_type
    ) RETURN VARCHAR2 IS
      l_xcrv_rec                     xcrv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xcrv_rec := p_xcrv_rec;
      -- Get current database values
      l_xcrv_rec := get_rec(p_xcrv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_xcrv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.id := l_xcrv_rec.id;
      END IF;
      IF (x_xcrv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.object_version_number := l_xcrv_rec.object_version_number;
      END IF;
      IF (x_xcrv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.sfwt_flag := l_xcrv_rec.sfwt_flag;
      END IF;
      IF (x_xcrv_rec.xcb_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.xcb_id := l_xcrv_rec.xcb_id;
      END IF;
      IF (x_xcrv_rec.rct_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.rct_id := l_xcrv_rec.rct_id;
      END IF;
      IF (x_xcrv_rec.icr_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.icr_id := l_xcrv_rec.icr_id;
      END IF;
      IF (x_xcrv_rec.gl_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xcrv_rec.gl_date := l_xcrv_rec.gl_date;
      END IF;
      IF (x_xcrv_rec.item_number = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.item_number := l_xcrv_rec.item_number;
      END IF;
      IF (x_xcrv_rec.remittance_amount = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.remittance_amount := l_xcrv_rec.remittance_amount;
      END IF;
      IF (x_xcrv_rec.currency_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.currency_code := l_xcrv_rec.currency_code;
      END IF;
      IF (x_xcrv_rec.receipt_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xcrv_rec.receipt_date := l_xcrv_rec.receipt_date;
      END IF;
      IF (x_xcrv_rec.receipt_method = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.receipt_method := l_xcrv_rec.receipt_method;
      END IF;
      IF (x_xcrv_rec.check_number = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.check_number := l_xcrv_rec.check_number;
      END IF;
      IF (x_xcrv_rec.comments = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.comments := l_xcrv_rec.comments;
      END IF;
      IF (x_xcrv_rec.customer_number = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.customer_number := l_xcrv_rec.customer_number;
      END IF;
      IF (x_xcrv_rec.bill_to_location = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.bill_to_location := l_xcrv_rec.bill_to_location;
      END IF;
      IF (x_xcrv_rec.exchange_rate_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.exchange_rate_type := l_xcrv_rec.exchange_rate_type;
      END IF;
      IF (x_xcrv_rec.exchange_rate_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xcrv_rec.exchange_rate_date := l_xcrv_rec.exchange_rate_date;
      END IF;
      IF (x_xcrv_rec.exchange_rate = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.exchange_rate := l_xcrv_rec.exchange_rate;
      END IF;
      IF (x_xcrv_rec.transit_routing_number = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.transit_routing_number := l_xcrv_rec.transit_routing_number;
      END IF;
      IF (x_xcrv_rec.account = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.account := l_xcrv_rec.account;
      END IF;
      IF (x_xcrv_rec.customer_bank_name = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.customer_bank_name := l_xcrv_rec.customer_bank_name;
      END IF;
      IF (x_xcrv_rec.customer_bank_branch_name = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.customer_bank_branch_name := l_xcrv_rec.customer_bank_branch_name;
      END IF;
      IF (x_xcrv_rec.remittance_bank_name = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.remittance_bank_name := l_xcrv_rec.remittance_bank_name;
      END IF;
      IF (x_xcrv_rec.remittance_bank_branch_name = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.remittance_bank_branch_name := l_xcrv_rec.remittance_bank_branch_name;
      END IF;
      IF (x_xcrv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute_category := l_xcrv_rec.attribute_category;
      END IF;
      IF (x_xcrv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute1 := l_xcrv_rec.attribute1;
      END IF;
      IF (x_xcrv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute2 := l_xcrv_rec.attribute2;
      END IF;
      IF (x_xcrv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute3 := l_xcrv_rec.attribute3;
      END IF;
      IF (x_xcrv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute4 := l_xcrv_rec.attribute4;
      END IF;
      IF (x_xcrv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute5 := l_xcrv_rec.attribute5;
      END IF;
      IF (x_xcrv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute6 := l_xcrv_rec.attribute6;
      END IF;
      IF (x_xcrv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute7 := l_xcrv_rec.attribute7;
      END IF;
      IF (x_xcrv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute8 := l_xcrv_rec.attribute8;
      END IF;
      IF (x_xcrv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute9 := l_xcrv_rec.attribute9;
      END IF;
      IF (x_xcrv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute10 := l_xcrv_rec.attribute10;
      END IF;
      IF (x_xcrv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute11 := l_xcrv_rec.attribute11;
      END IF;
      IF (x_xcrv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute12 := l_xcrv_rec.attribute12;
      END IF;
      IF (x_xcrv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute13 := l_xcrv_rec.attribute13;
      END IF;
      IF (x_xcrv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute14 := l_xcrv_rec.attribute14;
      END IF;
      IF (x_xcrv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.attribute15 := l_xcrv_rec.attribute15;
      END IF;
      IF (x_xcrv_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.request_id := l_xcrv_rec.request_id;
      END IF;
      IF (x_xcrv_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.program_application_id := l_xcrv_rec.program_application_id;
      END IF;
      IF (x_xcrv_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.program_id := l_xcrv_rec.program_id;
      END IF;
      IF (x_xcrv_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xcrv_rec.program_update_date := l_xcrv_rec.program_update_date;
      END IF;
      IF (x_xcrv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.org_id := l_xcrv_rec.org_id;
      END IF;
      IF (x_xcrv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.created_by := l_xcrv_rec.created_by;
      END IF;
      IF (x_xcrv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xcrv_rec.creation_date := l_xcrv_rec.creation_date;
      END IF;
      IF (x_xcrv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.last_updated_by := l_xcrv_rec.last_updated_by;
      END IF;
      IF (x_xcrv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xcrv_rec.last_update_date := l_xcrv_rec.last_update_date;
      END IF;
      IF (x_xcrv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_xcrv_rec.last_update_login := l_xcrv_rec.last_update_login;
      END IF;
-- New column receipt type and fully applied added.
      IF (x_xcrv_rec.receipt_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.receipt_type := l_xcrv_rec.receipt_type;
      END IF;
      IF (x_xcrv_rec.fully_applied_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.fully_applied_flag := l_xcrv_rec.fully_applied_flag;
      END IF;
      IF (x_xcrv_rec.expired_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_xcrv_rec.expired_flag := l_xcrv_rec.expired_flag;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_EXT_CSH_RCPTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xcrv_rec IN  xcrv_rec_type,
      x_xcrv_rec OUT NOCOPY xcrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xcrv_rec := p_xcrv_rec;
      x_xcrv_rec.OBJECT_VERSION_NUMBER := NVL(x_xcrv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);

	  -- POST TAPI GENERATED CODE BEGINS  04/25/2001  Bruno.

	  SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_xcrv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_xcrv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_xcrv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_xcrv_rec.program_update_date,SYSDATE)
      INTO
        x_xcrv_rec.request_id,
        x_xcrv_rec.program_application_id,
        x_xcrv_rec.program_id,
        x_xcrv_rec.program_update_date
      FROM   dual;

      -- POST TAPI GENERATED CODE ENDS  04/25/2001  Bruno.

    END Set_Attributes;

  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_xcrv_rec,                        -- IN
      l_xcrv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xcrv_rec, l_def_xcrv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_xcrv_rec := fill_who_columns(l_def_xcrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xcrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xcrv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_xcrv_rec, l_okl_ext_csh_rcpts_tl_rec);
    migrate(l_def_xcrv_rec, l_xcr_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ext_csh_rcpts_tl_rec,
      lx_okl_ext_csh_rcpts_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_ext_csh_rcpts_tl_rec, l_def_xcrv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xcr_rec,
      lx_xcr_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xcr_rec, l_def_xcrv_rec);
    x_xcrv_rec := l_def_xcrv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:XCRV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type,
    x_xcrv_tbl                     OUT NOCOPY xcrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xcrv_tbl.COUNT > 0) THEN
      i := p_xcrv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xcrv_rec                     => p_xcrv_tbl(i),
          x_xcrv_rec                     => x_xcrv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_xcrv_tbl.LAST);
        i := p_xcrv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- delete_row for:OKL_EXT_CSH_RCPTS_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcr_rec                      IN xcr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xcr_rec                      xcr_rec_type:= p_xcr_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_EXT_CSH_RCPTS_B
     WHERE ID = l_xcr_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------------
  -- delete_row for:OKL_EXT_CSH_RCPTS_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ext_csh_rcpts_tl_rec     IN okl_ext_csh_rcpts_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_ext_csh_rcpts_tl_rec     okl_ext_csh_rcpts_tl_rec_type:= p_okl_ext_csh_rcpts_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------------
    -- Set_Attributes for:OKL_EXT_CSH_RCPTS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_ext_csh_rcpts_tl_rec IN  okl_ext_csh_rcpts_tl_rec_type,
      x_okl_ext_csh_rcpts_tl_rec OUT NOCOPY okl_ext_csh_rcpts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ext_csh_rcpts_tl_rec := p_okl_ext_csh_rcpts_tl_rec;
      x_okl_ext_csh_rcpts_tl_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_ext_csh_rcpts_tl_rec,        -- IN
      l_okl_ext_csh_rcpts_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_EXT_CSH_RCPTS_TL
     WHERE ID = l_okl_ext_csh_rcpts_tl_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- delete_row for:OKL_EXT_CSH_RCPTS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xcrv_rec                     xcrv_rec_type := p_xcrv_rec;
    l_okl_ext_csh_rcpts_tl_rec     okl_ext_csh_rcpts_tl_rec_type;
    l_xcr_rec                      xcr_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_xcrv_rec, l_okl_ext_csh_rcpts_tl_rec);
    migrate(l_xcrv_rec, l_xcr_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ext_csh_rcpts_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xcr_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:XCRV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xcrv_tbl.COUNT > 0) THEN
      i := p_xcrv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xcrv_rec                     => p_xcrv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_xcrv_tbl.LAST);
        i := p_xcrv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END Okl_Xcr_Pvt;

/
