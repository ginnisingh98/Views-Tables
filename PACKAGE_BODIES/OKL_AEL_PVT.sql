--------------------------------------------------------
--  DDL for Package Body OKL_AEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AEL_PVT" AS
/* $Header: OKLSAELB.pls 120.3 2006/07/13 12:49:48 adagur noship $ */
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
  -- FUNCTION get_rec for: OKL_AE_LINES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ael_rec                      IN ael_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ael_rec_type IS
    CURSOR okl_ae_lines_pk_csr (p_ae_line_id                 IN NUMBER) IS
    SELECT
            ae_line_id,
            CODE_COMBINATION_ID,
            AE_HEADER_ID,
            CURRENCY_CONVERSION_TYPE,
            ORG_ID,
            AE_LINE_NUMBER,
            AE_LINE_TYPE_CODE,
            SOURCE_TABLE,
            SOURCE_ID,
            OBJECT_VERSION_NUMBER,
            CURRENCY_CODE,
            CURRENCY_CONVERSION_DATE,
            CURRENCY_CONVERSION_RATE,
            ENTERED_DR,
            ENTERED_CR,
            ACCOUNTED_DR,
            ACCOUNTED_CR,
            REFERENCE1,
            REFERENCE2,
            REFERENCE3,
            REFERENCE4,
            REFERENCE5,
            REFERENCE6,
            REFERENCE7,
            REFERENCE8,
            REFERENCE9,
            REFERENCE10,
            DESCRIPTION,
            THIRD_PARTY_ID,
            THIRD_PARTY_SUB_ID,
            STAT_AMOUNT,
            USSGL_TRANSACTION_CODE,
            SUBLEDGER_DOC_SEQUENCE_ID,
            ACCOUNTING_ERROR_CODE,
            GL_TRANSFER_ERROR_CODE,
            GL_SL_LINK_ID,
            TAXABLE_ENTERED_DR,
            TAXABLE_ENTERED_CR,
            TAXABLE_ACCOUNTED_DR,
            TAXABLE_ACCOUNTED_CR,
            APPLIED_FROM_TRX_HDR_TABLE,
            APPLIED_FROM_TRX_HDR_ID,
            APPLIED_TO_TRX_HDR_TABLE,
            APPLIED_TO_TRX_HDR_ID,
            TAX_LINK_ID,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            ACCOUNT_OVERLAY_SOURCE_ID,
            SUBLEDGER_DOC_SEQUENCE_VALUE,
            TAX_CODE_ID
      FROM Okl_Ae_Lines
     WHERE okl_ae_lines.ae_line_id      = p_ae_line_id;
    l_okl_ae_lines_pk              okl_ae_lines_pk_csr%ROWTYPE;
    l_ael_rec                      ael_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ae_lines_pk_csr (p_ael_rec.ae_line_id);
    FETCH okl_ae_lines_pk_csr INTO
              l_ael_rec.ae_line_id,
              l_ael_rec.CODE_COMBINATION_ID,
              l_ael_rec.AE_HEADER_ID,
              l_ael_rec.currency_CONVERSION_TYPE,
              l_ael_rec.ORG_ID,
              l_ael_rec.AE_LINE_NUMBER,
              l_ael_rec.AE_LINE_TYPE_CODE,
              l_ael_rec.SOURCE_TABLE,
              l_ael_rec.SOURCE_ID,
              l_ael_rec.OBJECT_VERSION_NUMBER,
              l_ael_rec.currency_code,
              l_ael_rec.CURRENCY_CONVERSION_DATE,
              l_ael_rec.CURRENCY_CONVERSION_RATE,
              l_ael_rec.ENTERED_DR,
              l_ael_rec.ENTERED_CR,
              l_ael_rec.ACCOUNTED_DR,
              l_ael_rec.ACCOUNTED_CR,
              l_ael_rec.REFERENCE1,
              l_ael_rec.REFERENCE2,
              l_ael_rec.REFERENCE3,
              l_ael_rec.REFERENCE4,
              l_ael_rec.REFERENCE5,
              l_ael_rec.REFERENCE6,
              l_ael_rec.REFERENCE7,
              l_ael_rec.REFERENCE8,
              l_ael_rec.REFERENCE9,
              l_ael_rec.REFERENCE10,
              l_ael_rec.DESCRIPTION,
              l_ael_rec.THIRD_PARTY_ID,
              l_ael_rec.THIRD_PARTY_SUB_ID,
              l_ael_rec.STAT_AMOUNT,
              l_ael_rec.USSGL_TRANSACTION_CODE,
              l_ael_rec.SUBLEDGER_DOC_SEQUENCE_ID,
              l_ael_rec.ACCOUNTING_ERROR_CODE,
              l_ael_rec.GL_TRANSFER_ERROR_CODE,
              l_ael_rec.GL_SL_LINK_ID,
              l_ael_rec.TAXABLE_ENTERED_DR,
              l_ael_rec.TAXABLE_ENTERED_CR,
              l_ael_rec.TAXABLE_ACCOUNTED_DR,
              l_ael_rec.TAXABLE_ACCOUNTED_CR,
              l_ael_rec.APPLIED_FROM_TRX_HDR_TABLE,
              l_ael_rec.APPLIED_FROM_TRX_HDR_ID,
              l_ael_rec.APPLIED_TO_TRX_HDR_TABLE,
              l_ael_rec.APPLIED_TO_TRX_HDR_ID,
              l_ael_rec.TAX_LINK_ID,
              l_ael_rec.PROGRAM_ID,
              l_ael_rec.PROGRAM_APPLICATION_ID,
              l_ael_rec.PROGRAM_UPDATE_DATE,
              l_ael_rec.REQUEST_ID,
              l_ael_rec.CREATED_BY,
              l_ael_rec.CREATION_DATE,
              l_ael_rec.LAST_UPDATED_BY,
              l_ael_rec.LAST_UPDATE_DATE,
              l_ael_rec.LAST_UPDATE_LOGIN,
			  l_ael_rec.ACCOUNT_OVERLAY_SOURCE_ID,
              l_ael_rec.SUBLEDGER_DOC_SEQUENCE_VALUE,
              l_ael_rec.TAX_CODE_ID;
    x_no_data_found := okl_ae_lines_pk_csr%NOTFOUND;
    CLOSE okl_ae_lines_pk_csr;
    RETURN(l_ael_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ael_rec                      IN ael_rec_type
  ) RETURN ael_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ael_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_AE_LINES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aelv_rec                     IN aelv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aelv_rec_type IS
    CURSOR okl_aelv_pk_csr (p_ae_line_id                 IN NUMBER) IS
    SELECT
            ae_line_id,
            OBJECT_VERSION_NUMBER,
            AE_HEADER_ID,
            CURRENCY_CONVERSION_TYPE,
            CODE_COMBINATION_ID,
            ORG_ID,
            AE_LINE_NUMBER,
            AE_LINE_TYPE_CODE,
            CURRENCY_CONVERSION_DATE,
            CURRENCY_CONVERSION_RATE,
            ENTERED_DR,
            ENTERED_CR,
            ACCOUNTED_DR,
            ACCOUNTED_CR,
            SOURCE_TABLE,
            SOURCE_ID,
            REFERENCE1,
            REFERENCE2,
            REFERENCE3,
            REFERENCE4,
            REFERENCE5,
            REFERENCE6,
            REFERENCE7,
            REFERENCE8,
            REFERENCE9,
            REFERENCE10,
            DESCRIPTION,
            THIRD_PARTY_ID,
            THIRD_PARTY_SUB_ID,
            STAT_AMOUNT,
            USSGL_TRANSACTION_CODE,
            SUBLEDGER_DOC_SEQUENCE_ID,
            ACCOUNTING_ERROR_CODE,
            GL_TRANSFER_ERROR_CODE,
            GL_SL_LINK_ID,
            TAXABLE_ENTERED_DR,
            TAXABLE_ENTERED_CR,
            TAXABLE_ACCOUNTED_DR,
            TAXABLE_ACCOUNTED_CR,
            APPLIED_FROM_TRX_HDR_TABLE,
            APPLIED_FROM_TRX_HDR_ID,
            APPLIED_TO_TRX_HDR_TABLE,
            APPLIED_TO_TRX_HDR_ID,
            TAX_LINK_ID,
            CURRENCY_CODE,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            ACCOUNT_OVERLAY_SOURCE_ID,
            SUBLEDGER_DOC_SEQUENCE_VALUE,
            TAX_CODE_ID
      FROM OKL_AE_LINES
     WHERE OKL_AE_LINES.ae_line_id    = p_ae_line_id;
    l_okl_aelv_pk                  okl_aelv_pk_csr%ROWTYPE;
    l_aelv_rec                     aelv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_aelv_pk_csr (p_aelv_rec.ae_line_id);
    FETCH okl_aelv_pk_csr INTO
              l_aelv_rec.ae_line_id,
              l_aelv_rec.OBJECT_VERSION_NUMBER,
              l_aelv_rec.AE_HEADER_ID,
              l_aelv_rec.currency_CONVERSION_TYPE,
              l_aelv_rec.CODE_COMBINATION_ID,
              l_aelv_rec.ORG_ID,
              l_aelv_rec.AE_LINE_NUMBER,
              l_aelv_rec.AE_LINE_TYPE_CODE,
              l_aelv_rec.CURRENCY_CONVERSION_DATE,
              l_aelv_rec.CURRENCY_CONVERSION_RATE,
              l_aelv_rec.ENTERED_DR,
              l_aelv_rec.ENTERED_CR,
              l_aelv_rec.ACCOUNTED_DR,
              l_aelv_rec.ACCOUNTED_CR,
              l_aelv_rec.SOURCE_TABLE,
              l_aelv_rec.SOURCE_ID,
              l_aelv_rec.REFERENCE1,
              l_aelv_rec.REFERENCE2,
              l_aelv_rec.REFERENCE3,
              l_aelv_rec.REFERENCE4,
              l_aelv_rec.REFERENCE5,
              l_aelv_rec.REFERENCE6,
              l_aelv_rec.REFERENCE7,
              l_aelv_rec.REFERENCE8,
              l_aelv_rec.REFERENCE9,
              l_aelv_rec.REFERENCE10,
              l_aelv_rec.DESCRIPTION,
              l_aelv_rec.THIRD_PARTY_ID,
              l_aelv_rec.THIRD_PARTY_SUB_ID,
              l_aelv_rec.STAT_AMOUNT,
              l_aelv_rec.USSGL_TRANSACTION_CODE,
              l_aelv_rec.SUBLEDGER_DOC_SEQUENCE_ID,
              l_aelv_rec.ACCOUNTING_ERROR_CODE,
              l_aelv_rec.GL_TRANSFER_ERROR_CODE,
              l_aelv_rec.GL_SL_LINK_ID,
              l_aelv_rec.TAXABLE_ENTERED_DR,
              l_aelv_rec.TAXABLE_ENTERED_CR,
              l_aelv_rec.TAXABLE_ACCOUNTED_DR,
              l_aelv_rec.TAXABLE_ACCOUNTED_CR,
              l_aelv_rec.APPLIED_FROM_TRX_HDR_TABLE,
              l_aelv_rec.APPLIED_FROM_TRX_HDR_ID,
              l_aelv_rec.APPLIED_TO_TRX_HDR_TABLE,
              l_aelv_rec.APPLIED_TO_TRX_HDR_ID,
              l_aelv_rec.TAX_LINK_ID,
              l_aelv_rec.currency_code,
              l_aelv_rec.PROGRAM_ID,
              l_aelv_rec.PROGRAM_APPLICATION_ID,
              l_aelv_rec.PROGRAM_UPDATE_DATE,
              l_aelv_rec.REQUEST_ID,
              l_aelv_rec.CREATED_BY,
              l_aelv_rec.CREATION_DATE,
              l_aelv_rec.LAST_UPDATED_BY,
              l_aelv_rec.LAST_UPDATE_DATE,
              l_aelv_rec.LAST_UPDATE_LOGIN,
              l_aelv_rec.ACCOUNT_OVERLAY_SOURCE_ID,
              l_aelv_rec.SUBLEDGER_DOC_SEQUENCE_VALUE,
              l_aelv_rec.TAX_CODE_ID;
    x_no_data_found := okl_aelv_pk_csr%NOTFOUND;
    CLOSE okl_aelv_pk_csr;
    RETURN(l_aelv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aelv_rec                     IN aelv_rec_type
  ) RETURN aelv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aelv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_AE_LINES_V --
  ----------------------------------------------------
  FUNCTION null_out_defaults (
    p_aelv_rec	IN aelv_rec_type
  ) RETURN aelv_rec_type IS
    l_aelv_rec	aelv_rec_type := p_aelv_rec;
  BEGIN
    IF (l_aelv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.object_version_number := NULL;
    END IF;
    IF (l_aelv_rec.AE_HEADER_ID = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.AE_HEADER_ID := NULL;
    END IF;
    IF (l_aelv_rec.currency_conversion_type = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_aelv_rec.code_combination_id = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.code_combination_id := NULL;
    END IF;
    IF (l_aelv_rec.org_id = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.org_id := NULL;
    END IF;
    IF (l_aelv_rec.AE_LINE_NUMBER = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.AE_LINE_NUMBER := NULL;
    END IF;
    IF (l_aelv_rec.AE_LINE_TYPE_CODE = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.AE_LINE_TYPE_CODE := NULL;
    END IF;
    IF (l_aelv_rec.currency_conversion_date = Okc_Api.G_MISS_DATE) THEN
      l_aelv_rec.currency_conversion_date := NULL;
    END IF;
    IF (l_aelv_rec.currency_conversion_rate = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.currency_conversion_rate := NULL;
    END IF;
    IF (l_aelv_rec.ENTERED_DR = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.ENTERED_DR := NULL;
    END IF;
    IF (l_aelv_rec.ENTERED_CR = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.ENTERED_CR := NULL;
    END IF;
    IF (l_aelv_rec.ACCOUNTED_DR = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.ACCOUNTED_DR := NULL;
    END IF;
    IF (l_aelv_rec.ACCOUNTED_CR = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.ACCOUNTED_CR := NULL;
    END IF;
    IF (l_aelv_rec.source_table = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.source_table := NULL;
    END IF;
    IF (l_aelv_rec.source_id = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.source_id := NULL;
    END IF;
    IF (l_aelv_rec.reference1 = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.reference1 := NULL;
    END IF;
    IF (l_aelv_rec.reference2 = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.reference2 := NULL;
    END IF;
    IF (l_aelv_rec.reference3 = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.reference3 := NULL;
    END IF;
    IF (l_aelv_rec.reference4 = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.reference4 := NULL;
    END IF;
    IF (l_aelv_rec.reference5 = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.reference5 := NULL;
    END IF;
    IF (l_aelv_rec.reference6 = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.reference6 := NULL;
    END IF;
    IF (l_aelv_rec.reference7 = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.reference7 := NULL;
    END IF;
    IF (l_aelv_rec.reference8 = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.reference8 := NULL;
    END IF;
    IF (l_aelv_rec.reference9 = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.reference9 := NULL;
    END IF;
    IF (l_aelv_rec.reference10 = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.reference10 := NULL;
    END IF;
    IF (l_aelv_rec.description = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.description := NULL;
    END IF;
    IF (l_aelv_rec.third_party_id = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.third_party_id := NULL;
    END IF;
    IF (l_aelv_rec.third_party_sub_id = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.third_party_sub_id := NULL;
    END IF;
    IF (l_aelv_rec.STAT_AMOUNT = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.STAT_AMOUNT := NULL;
    END IF;
    IF (l_aelv_rec.ussgl_transaction_code = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.ussgl_transaction_code := NULL;
    END IF;
    IF (l_aelv_rec.subledger_doc_sequence_id = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.subledger_doc_sequence_id := NULL;
    END IF;
    IF (l_aelv_rec.accounting_error_code = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.accounting_error_code := NULL;
    END IF;
    IF (l_aelv_rec.gl_transfer_error_code = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.gl_transfer_error_code := NULL;
    END IF;
    IF (l_aelv_rec.GL_SL_LINK_ID = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.GL_SL_LINK_ID := NULL;
    END IF;
    IF (l_aelv_rec.taxable_ENTERED_DR = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.taxable_ENTERED_DR := NULL;
    END IF;
    IF (l_aelv_rec.taxable_ENTERED_CR = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.taxable_ENTERED_CR := NULL;
    END IF;
    IF (l_aelv_rec.taxable_ACCOUNTED_DR = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.taxable_ACCOUNTED_DR := NULL;
    END IF;
    IF (l_aelv_rec.taxable_ACCOUNTED_CR = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.taxable_ACCOUNTED_CR := NULL;
    END IF;
    IF (l_aelv_rec.applied_from_trx_hdr_table = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.applied_from_trx_hdr_table := NULL;
    END IF;
    IF (l_aelv_rec.applied_from_trx_hdr_id = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.applied_from_trx_hdr_id := NULL;
    END IF;
    IF (l_aelv_rec.applied_to_trx_hdr_table = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.applied_to_trx_hdr_table := NULL;
    END IF;
    IF (l_aelv_rec.applied_to_trx_hdr_id = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.applied_to_trx_hdr_id := NULL;
    END IF;
    IF (l_aelv_rec.tax_link_id = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.tax_link_id := NULL;
    END IF;
    IF (l_aelv_rec.currency_code = Okc_Api.G_MISS_CHAR) THEN
      l_aelv_rec.currency_code := NULL;
    END IF;
    /* commented to make sure concurrent manager columns are not nulled out nocopy as per pg. 104 in API developer's guide
    IF (l_aelv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_aelv_rec.program_id := NULL;
    END IF;
    IF (l_aelv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_aelv_rec.program_application_id := NULL;
    END IF;
    IF (l_aelv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_aelv_rec.program_update_date := NULL;
    END IF;
    IF (l_aelv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_aelv_rec.request_id := NULL;
    END IF;
    */
    IF (l_aelv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.created_by := NULL;
    END IF;
    IF (l_aelv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_aelv_rec.creation_date := NULL;
    END IF;
    IF (l_aelv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.last_updated_by := NULL;
    END IF;
    IF (l_aelv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_aelv_rec.last_update_date := NULL;
    END IF;
    IF (l_aelv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.last_update_login := NULL;
    END IF;
	IF (l_aelv_rec.ACCOUNT_OVERLAY_SOURCE_ID = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.ACCOUNT_OVERLAY_SOURCE_ID := NULL;
    END IF;
	IF (l_aelv_rec.SUBLEDGER_DOC_SEQUENCE_VALUE = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.SUBLEDGER_DOC_SEQUENCE_VALUE := NULL;
    END IF;
	IF (l_aelv_rec.TAX_CODE_ID = Okc_Api.G_MISS_NUM) THEN
      l_aelv_rec.TAX_CODE_ID := NULL;
    END IF;
    RETURN(l_aelv_rec);
  END null_out_defaults;

/* Renu Gurudev 4/27/2001 - Commented out nocopy generated code in favor of manually written code
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKL_AE_LINES_V --
  --------------------------------------------
  FUNCTION Validate_Attributes (
    p_aelv_rec IN  aelv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_aelv_rec.ae_line_id = OKC_API.G_MISS_NUM OR
       p_aelv_rec.ae_line_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aelv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_aelv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aelv_rec.AE_HEADER_ID = OKC_API.G_MISS_NUM OR
          p_aelv_rec.AE_HEADER_ID IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'AE_HEADER_ID');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aelv_rec.code_combination_id = OKC_API.G_MISS_NUM OR
          p_aelv_rec.code_combination_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'code_combination_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aelv_rec.AE_LINE_NUMBER = OKC_API.G_MISS_NUM OR
          p_aelv_rec.AE_LINE_NUMBER IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'line_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aelv_rec.AE_LINE_TYPE_CODE = OKC_API.G_MISS_CHAR OR
          p_aelv_rec.AE_LINE_TYPE_CODE IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'line_type_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aelv_rec.source_table = OKC_API.G_MISS_CHAR OR
          p_aelv_rec.source_table IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'source_table');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aelv_rec.source_id = OKC_API.G_MISS_NUM OR
          p_aelv_rec.source_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'source_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aelv_rec.curr_code = OKC_API.G_MISS_CHAR OR
          p_aelv_rec.curr_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'curr_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKL_AE_LINES_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_aelv_rec IN aelv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

*/

  /*********** begin manual coding *****************/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_ae_line_id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_ae_line_id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_ae_line_id (p_aelv_rec      IN  aelv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aelv_rec.ae_line_id IS NULL) OR
       (p_aelv_rec.ae_line_id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'id');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_ae_line_id;


  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Object_Version_Number
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number (p_aelv_rec      IN  aelv_rec_type
                                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aelv_rec.object_version_number IS NULL) OR
       (p_aelv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'object_version_number');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_AE_HEADER_ID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_AE_HEADER_ID
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_AE_HEADER_ID (p_aelv_rec      IN  aelv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  item_not_found_error          EXCEPTION;

  l_dummy                    VARCHAR2(1);
  l_row_notfound                 BOOLEAN := TRUE;

  CURSOR okl_aelv_fk_csr (p_ae_header_id IN NUMBER) IS
  SELECT  '1'
  FROM OKL_AE_HEADERS
  WHERE OKL_AE_HEADERS.ae_header_id = p_ae_header_id;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aelv_rec.AE_HEADER_ID IS NULL) OR
       (p_aelv_rec.AE_HEADER_ID = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'AE_HEADER_ID');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       OPEN okl_aelv_fk_csr(p_aelv_rec.AE_HEADER_ID);
       FETCH okl_aelv_fk_csr INTO l_dummy;
       l_row_notfound := okl_aelv_fk_csr%NOTFOUND;
       CLOSE okl_aelv_fk_csr;
       IF (l_row_notfound) THEN
         Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AE_HEADER_ID');
         RAISE item_not_found_error;
       END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
       x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_AE_HEADER_ID;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Code_Combination_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Code_Combination_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Code_Combination_Id (p_aelv_rec      IN  aelv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status              VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  item_not_found_error          EXCEPTION;

  l_dummy                    VARCHAR2(1) := okl_api.g_true;
    BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aelv_rec.code_combination_id IS NULL) OR
       (p_aelv_rec.code_combination_id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'code_combination_id');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
    l_dummy := Okl_Accounting_Util.VALIDATE_GL_CCID (
	p_aelv_rec.code_combination_id);
    IF l_dummy = okl_api.g_false THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'CODE_COMBINATION_ID');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
       x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Code_Combination_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Curr_Cnvrsn_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Curr_Conversion_Type
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Curr_Cnvrsn_Type (p_aelv_rec      IN  aelv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  item_not_found_error          EXCEPTION;

  l_dummy                    VARCHAR2(1);
  l_row_notfound                 BOOLEAN := TRUE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
   IF (p_aelv_rec.currency_conversion_type IS NOT NULL) AND
      (p_aelv_rec.currency_conversion_type  <> Okc_Api.G_MISS_CHAR) THEN
    l_dummy := Okl_Accounting_Util.VALIDATE_CURRENCY_CON_TYPE(p_aelv_rec.currency_conversion_type);
    IF (l_dummy = OKC_API.G_FALSE) THEN
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                       ,p_msg_name      => g_invalid_value
                       ,p_token1        => g_col_name_token
                       ,p_token1_value  => 'CURRENCY_CONVERSION_TYPE');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
       x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Curr_Cnvrsn_Type;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_AE_LINE_NUMBER
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_AE_LINE_NUMBER
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_AE_LINE_NUMBER (p_aelv_rec      IN  aelv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aelv_rec.AE_LINE_NUMBER IS NULL) OR
       (p_aelv_rec.AE_LINE_NUMBER = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'line_number');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_AE_LINE_NUMBER;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_AE_LINE_TYPE_CODE
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_AE_LINE_TYPE_CODE
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_AE_LINE_TYPE_CODE(p_aelv_rec      IN      aelv_rec_type
						  ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy     VARCHAR2(1) := OKC_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aelv_rec.AE_LINE_TYPE_CODE IS NULL) OR
       (p_aelv_rec.AE_LINE_TYPE_CODE = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'line_type_code');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check in fnd_lookups for validity

    l_dummy
          := Okl_Accounting_Util.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_ACCOUNTING_LINE_TYPE',
                                                  p_lookup_code => p_aelv_rec.AE_LINE_TYPE_CODE);

    IF (l_dummy = Okc_Api.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'line_type_code');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_AE_LINE_TYPE_CODE;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Source_ID_Tbl
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Source_ID_Tbl
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Source_ID_Tbl(p_aelv_rec      IN      aelv_rec_type
						  ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy         VARCHAR2(1)  ;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aelv_rec.source_table IS NULL) OR
       (p_aelv_rec.source_table = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'SOURCE_TABLE');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
    END IF;

    IF (p_aelv_rec.source_id IS NULL) OR
       (p_aelv_rec.source_id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'SOURCE_ID');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
    END IF;

    IF (x_return_Status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       l_dummy
        := Okl_Accounting_Util.VALIDATE_SOURCE_ID_TABLE(p_source_id => p_aelv_rec.source_id,
                                                        p_source_table => p_aelv_rec.source_table);
        IF l_dummy = OKC_API.G_FALSE THEN
                Okc_Api.SET_MESSAGE(p_app_name  => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'source_id');
                x_return_status := Okc_Api.G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END IF;



  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Source_ID_Tbl;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Currency_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Currency_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Currency_Code(p_aelv_rec      IN      aelv_rec_type
						  ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy         VARCHAR2(1)  := Okc_Api.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aelv_rec.currency_code IS NULL) OR
       (p_aelv_rec.currency_code = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'currency_code');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      l_dummy := Okl_Accounting_Util.VALIDATE_CURRENCY_CODE (p_aelv_rec.currency_code);

	    IF l_dummy = okc_api.g_false THEN
	      	Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        		p_msg_name     => g_invalid_value,
                        		p_token1       => g_col_name_token,
                        		p_token1_value => 'CURRENCY_CODE');
	          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	    END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Currency_Code;


 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Accounting_error_code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Accounting_Error_code
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Accounting_Error_code (p_aelv_rec      IN  aelv_rec_type
                                           ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_dummy                   VARCHAR2(1)    := Okc_Api.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aelv_rec.Accounting_Error_Code IS NOT NULL) AND
       (p_aelv_rec.Accounting_Error_code <> Okc_Api.G_MISS_CHAR) THEN

        l_dummy
          := Okl_Accounting_Util.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_ACCOUNTING_ERROR_CODE',
                                                p_lookup_code => p_aelv_rec.accounting_error_code);

       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_invalid_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'ACCOUNTING_ERROR_CODE');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Accounting_Error_Code;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_GL_trans_Err_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
 -- Procedure Name   : validate_GL_trans_Err_Code
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE validate_GL_trans_Err_Code (p_aelv_rec      IN  aelv_rec_type
                                 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_dummy                   VARCHAR2(1)    := Okc_Api.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aelv_rec.GL_Transfer_Error_Code IS NOT NULL) AND
       (p_aelv_rec.GL_Transfer_Error_Code <> Okc_Api.G_MISS_CHAR) THEN

        l_dummy
          := Okl_Accounting_Util.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_ACCOUNTING_ERROR_CODE',
                                              p_lookup_code => p_aelv_rec.GL_Transfer_Error_Code);

       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_invalid_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'GL_TRANSFER_ERROR_CODE');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
 EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END validate_GL_trans_Err_Code;


---------------------------------------------------------------------------
  -- PROCEDURE validate_unique_ael_record
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Ael_Record(x_return_status OUT NOCOPY     VARCHAR2,
                                       p_aelv_rec      IN      aelv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_aelv_status           VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;

  CURSOR c1 IS
  SELECT        '1'
  FROM  OKL_AE_LINES
  WHERE AE_HEADER_ID = p_aelv_rec.AE_HEADER_ID
  AND   AE_LINE_NUMBER = p_aelv_rec.AE_LINE_NUMBER
  AND   ae_line_id  <> p_aelv_rec.ae_line_id;

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN c1 ;
    FETCH c1 INTO l_aelv_status;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found THEN
        OKC_API.set_message(G_APP_NAME,G_UNQS);
        x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
     -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Ael_Record;



  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_aelv_rec IN  aelv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN


    -- call each column-level validation

    -- Validate_ae_line_id
    Validate_ae_line_id(p_aelv_rec, x_return_status);
	IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

   -- Validate_Object_Version_Number
    Validate_Object_Version_Number(p_aelv_rec, x_return_status);
		IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_AE_HEADER_ID
    Validate_AE_HEADER_ID(p_aelv_rec, x_return_status);
		IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Code_Combination_Id
/* The following code commented by Kanti. This is because we are doing a validation
   in the accounting entry creation program. We have a requirement to create a line
   even when ccid is invalid. In this case, we update the error flag to say that
   'ACCOUNT INVALID' but neverthless, we allow an invalid CCID to be present in
   the table. Therefore, this check needs to be removed from this place

    Validate_Code_Combination_Id(p_aelv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

*/

    -- Validate_Curr_Cnvrsn_Type
    Validate_Curr_Cnvrsn_Type(p_aelv_rec, x_return_status);
		IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_AE_LINE_NUMBER
    Validate_AE_LINE_NUMBER(p_aelv_rec, x_return_status);
		IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_AE_LINE_TYPE_CODE
    Validate_AE_LINE_TYPE_CODE(p_aelv_rec, x_return_status);
		IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Source_Table and ID
    Validate_Source_ID_TBL(p_aelv_rec, x_return_status);
		IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Curr_Code
    Validate_Currency_Code(p_aelv_rec, x_return_status);
		IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Accounting_Error_Code

/* This code commented by Kanti. We no longer keep a code in the table but we keep the
   actual message. And therefore, this need not be validated against a lookup. This
   lookup will be dropped

    Validate_Accounting_Error_Code(p_aelv_rec, x_return_status);
		IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

*/

/*  This code is also not required since GL populates this error message and it does not
    make sense to validate it here

    -- validate_GL_trans_Err_Code
    validate_GL_trans_Err_Code(p_aelv_rec, x_return_status);
		IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

*/

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;



  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Record (
    p_aelv_rec IN aelv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN

    Validate_Unique_AeL_Record(x_return_status => l_return_Status, p_aelv_rec => p_aelv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          NULL;
       END IF;
    END IF;

    RETURN(l_return_status);

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;

  /*********************** END MANUAL CODE **********************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN aelv_rec_type,
    p_to	IN OUT NOCOPY ael_rec_type
  ) IS
  BEGIN
    p_to.ae_line_id := p_from.ae_line_id;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.AE_HEADER_ID := p_from.AE_HEADER_ID;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.org_id := p_from.org_id;
    p_to.AE_LINE_NUMBER := p_from.AE_LINE_NUMBER;
    p_to.AE_LINE_TYPE_CODE := p_from.AE_LINE_TYPE_CODE;
    p_to.source_table := p_from.source_table;
    p_to.source_id := p_from.source_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.currency_code := p_from.currency_code;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.ENTERED_DR := p_from.ENTERED_DR;
    p_to.ENTERED_CR := p_from.ENTERED_CR;
    p_to.ACCOUNTED_DR := p_from.ACCOUNTED_DR;
    p_to.ACCOUNTED_CR := p_from.ACCOUNTED_CR;
    p_to.reference1 := p_from.reference1;
    p_to.reference2 := p_from.reference2;
    p_to.reference3 := p_from.reference3;
    p_to.reference4 := p_from.reference4;
    p_to.reference5 := p_from.reference5;
    p_to.reference6 := p_from.reference6;
    p_to.reference7 := p_from.reference7;
    p_to.reference8 := p_from.reference8;
    p_to.reference9 := p_from.reference9;
    p_to.reference10 := p_from.reference10;
    p_to.description := p_from.description;
    p_to.third_party_id := p_from.third_party_id;
    p_to.third_party_sub_id := p_from.third_party_sub_id;
    p_to.STAT_AMOUNT := p_from.STAT_AMOUNT;
    p_to.ussgl_transaction_code := p_from.ussgl_transaction_code;
    p_to.subledger_doc_sequence_id := p_from.subledger_doc_sequence_id;
    p_to.accounting_error_code := p_from.accounting_error_code;
    p_to.gl_transfer_error_code := p_from.gl_transfer_error_code;
    p_to.GL_SL_LINK_ID := p_from.GL_SL_LINK_ID;
    p_to.taxable_ENTERED_DR := p_from.taxable_ENTERED_DR;
    p_to.taxable_ENTERED_CR := p_from.taxable_ENTERED_CR;
    p_to.taxable_ACCOUNTED_DR := p_from.taxable_ACCOUNTED_DR;
    p_to.taxable_ACCOUNTED_CR := p_from.taxable_ACCOUNTED_CR;
    p_to.applied_from_trx_hdr_table := p_from.applied_from_trx_hdr_table;
    p_to.applied_from_trx_hdr_id := p_from.applied_from_trx_hdr_id;
    p_to.applied_to_trx_hdr_table := p_from.applied_to_trx_hdr_table;
    p_to.applied_to_trx_hdr_id := p_from.applied_to_trx_hdr_id;
    p_to.tax_link_id := p_from.tax_link_id;
    p_to.program_id := p_from.program_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.request_id := p_from.request_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.ACCOUNT_OVERLAY_SOURCE_ID := p_from.ACCOUNT_OVERLAY_SOURCE_ID;
    p_to.SUBLEDGER_DOC_SEQUENCE_VALUE := p_from.SUBLEDGER_DOC_SEQUENCE_VALUE;
    p_to.TAX_CODE_ID := p_from.TAX_CODE_ID;
  END migrate;
  PROCEDURE migrate (
    p_from	IN ael_rec_type,
    p_to	IN OUT NOCOPY aelv_rec_type
  ) IS
  BEGIN
    p_to.ae_line_id := p_from.ae_line_id;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.AE_HEADER_ID := p_from.AE_HEADER_ID;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.org_id := p_from.org_id;
    p_to.AE_LINE_NUMBER := p_from.AE_LINE_NUMBER;
    p_to.AE_LINE_TYPE_CODE := p_from.AE_LINE_TYPE_CODE;
    p_to.source_table := p_from.source_table;
    p_to.source_id := p_from.source_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.currency_code := p_from.currency_code;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.ENTERED_DR := p_from.ENTERED_DR;
    p_to.ENTERED_CR := p_from.ENTERED_CR;
    p_to.ACCOUNTED_DR := p_from.ACCOUNTED_DR;
    p_to.ACCOUNTED_CR := p_from.ACCOUNTED_CR;
    p_to.reference1 := p_from.reference1;
    p_to.reference2 := p_from.reference2;
    p_to.reference3 := p_from.reference3;
    p_to.reference4 := p_from.reference4;
    p_to.reference5 := p_from.reference5;
    p_to.reference6 := p_from.reference6;
    p_to.reference7 := p_from.reference7;
    p_to.reference8 := p_from.reference8;
    p_to.reference9 := p_from.reference9;
    p_to.reference10 := p_from.reference10;
    p_to.description := p_from.description;
    p_to.third_party_id := p_from.third_party_id;
    p_to.third_party_sub_id := p_from.third_party_sub_id;
    p_to.STAT_AMOUNT := p_from.STAT_AMOUNT;
    p_to.ussgl_transaction_code := p_from.ussgl_transaction_code;
    p_to.subledger_doc_sequence_id := p_from.subledger_doc_sequence_id;
    p_to.accounting_error_code := p_from.accounting_error_code;
    p_to.gl_transfer_error_code := p_from.gl_transfer_error_code;
    p_to.GL_SL_LINK_ID := p_from.GL_SL_LINK_ID;
    p_to.taxable_ENTERED_DR := p_from.taxable_ENTERED_DR;
    p_to.taxable_ENTERED_CR := p_from.taxable_ENTERED_CR;
    p_to.taxable_ACCOUNTED_DR := p_from.taxable_ACCOUNTED_DR;
    p_to.taxable_ACCOUNTED_CR := p_from.taxable_ACCOUNTED_CR;
    p_to.applied_from_trx_hdr_table := p_from.applied_from_trx_hdr_table;
    p_to.applied_from_trx_hdr_id := p_from.applied_from_trx_hdr_id;
    p_to.applied_to_trx_hdr_table := p_from.applied_to_trx_hdr_table;
    p_to.applied_to_trx_hdr_id := p_from.applied_to_trx_hdr_id;
    p_to.tax_link_id := p_from.tax_link_id;
    p_to.program_id := p_from.program_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.request_id := p_from.request_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.ACCOUNT_OVERLAY_SOURCE_ID := p_from.ACCOUNT_OVERLAY_SOURCE_ID;
    p_to.SUBLEDGER_DOC_SEQUENCE_VALUE := p_from.SUBLEDGER_DOC_SEQUENCE_VALUE;
    p_to.TAX_CODE_ID := p_from.TAX_CODE_ID;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- validate_row for:OKL_AE_LINES_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aelv_rec                     aelv_rec_type := p_aelv_rec;
    l_ael_rec                      ael_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_aelv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_aelv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:AELV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aelv_tbl.COUNT > 0) THEN
      i := p_aelv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aelv_rec                     => p_aelv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_aelv_tbl.LAST);
        i := p_aelv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  ---------------------------------
  -- insert_row for:OKL_AE_LINES --
  ---------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ael_rec                      IN ael_rec_type,
    x_ael_rec                      OUT NOCOPY ael_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_ael_rec                      ael_rec_type := p_ael_rec;
    l_def_ael_rec                  ael_rec_type;
    -------------------------------------
    -- Set_Attributes for:OKL_AE_LINES --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_ael_rec IN  ael_rec_type,
      x_ael_rec OUT NOCOPY ael_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ael_rec := p_ael_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
  l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ael_rec,                         -- IN
      l_ael_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_AE_LINES(
        ae_line_id,
        code_combination_id,
        AE_HEADER_ID,
        currency_conversion_type,
        org_id,
        AE_LINE_NUMBER,
        AE_LINE_TYPE_CODE,
        source_table,
        source_id,
        object_version_number,
        currency_code,
        currency_conversion_date,
        currency_conversion_rate,
        ENTERED_DR,
        ENTERED_CR,
        ACCOUNTED_DR,
        ACCOUNTED_CR,
        reference1,
        reference2,
        reference3,
        reference4,
        reference5,
        reference6,
        reference7,
        reference8,
        reference9,
        reference10,
        description,
        third_party_id,
        third_party_sub_id,
        STAT_AMOUNT,
        ussgl_transaction_code,
        subledger_doc_sequence_id,
        accounting_error_code,
        gl_transfer_error_code,
        GL_SL_LINK_ID,
        taxable_ENTERED_DR,
        taxable_ENTERED_CR,
        taxable_ACCOUNTED_DR,
        taxable_ACCOUNTED_CR,
        applied_from_trx_hdr_table,
        applied_from_trx_hdr_id,
        applied_to_trx_hdr_table,
        applied_to_trx_hdr_id,
        tax_link_id,
        program_id,
        program_application_id,
        program_update_date,
        request_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        LAST_UPDATE_LOGIN,
        ACCOUNT_OVERLAY_SOURCE_ID,
        SUBLEDGER_DOC_SEQUENCE_VALUE,
        TAX_CODE_ID)
      VALUES (
        l_ael_rec.ae_line_id,
        l_ael_rec.code_combination_id,
        l_ael_rec.AE_HEADER_ID,
        l_ael_rec.currency_conversion_type,
        l_ael_rec.org_id,
        l_ael_rec.AE_LINE_NUMBER,
        l_ael_rec.AE_LINE_TYPE_CODE,
        l_ael_rec.source_table,
        l_ael_rec.source_id,
        l_ael_rec.object_version_number,
        l_ael_rec.currency_code,
        l_ael_rec.currency_conversion_date,
        l_ael_rec.currency_conversion_rate,
        l_ael_rec.ENTERED_DR,
        l_ael_rec.ENTERED_CR,
        l_ael_rec.ACCOUNTED_DR,
        l_ael_rec.ACCOUNTED_CR,
        l_ael_rec.reference1,
        l_ael_rec.reference2,
        l_ael_rec.reference3,
        l_ael_rec.reference4,
        l_ael_rec.reference5,
        l_ael_rec.reference6,
        l_ael_rec.reference7,
        l_ael_rec.reference8,
        l_ael_rec.reference9,
        l_ael_rec.reference10,
        l_ael_rec.description,
        l_ael_rec.third_party_id,
        l_ael_rec.third_party_sub_id,
        l_ael_rec.STAT_AMOUNT,
        l_ael_rec.ussgl_transaction_code,
        l_ael_rec.subledger_doc_sequence_id,
        l_ael_rec.accounting_error_code,
        l_ael_rec.gl_transfer_error_code,
        l_ael_rec.GL_SL_LINK_ID,
        l_ael_rec.taxable_ENTERED_DR,
        l_ael_rec.taxable_ENTERED_CR,
        l_ael_rec.taxable_ACCOUNTED_DR,
        l_ael_rec.taxable_ACCOUNTED_CR,
        l_ael_rec.applied_from_trx_hdr_table,
        l_ael_rec.applied_from_trx_hdr_id,
        l_ael_rec.applied_to_trx_hdr_table,
        l_ael_rec.applied_to_trx_hdr_id,
        l_ael_rec.tax_link_id,
        l_ael_rec.PROGRAM_ID,
        l_ael_rec.program_application_id,
        l_ael_rec.program_update_date,
        l_ael_rec.request_id,
        l_ael_rec.created_by,
        l_ael_rec.creation_date,
        l_ael_rec.last_updated_by,
        l_ael_rec.last_update_date,
        l_ael_rec.LAST_UPDATE_LOGIN,
		l_ael_rec.ACCOUNT_OVERLAY_SOURCE_ID,
        l_ael_rec.SUBLEDGER_DOC_SEQUENCE_VALUE,
        l_ael_rec.TAX_CODE_ID);
    -- Set OUT values
    x_ael_rec := l_ael_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -----------------------------------
  -- insert_row for:OKL_AE_LINES_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type,
    x_aelv_rec                     OUT NOCOPY aelv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aelv_rec                     aelv_rec_type;
    l_def_aelv_rec                 aelv_rec_type;
    l_ael_rec                      ael_rec_type;
    lx_ael_rec                     ael_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aelv_rec	IN aelv_rec_type
    ) RETURN aelv_rec_type IS
      l_aelv_rec	aelv_rec_type := p_aelv_rec;
    BEGIN
      l_aelv_rec.CREATION_DATE := SYSDATE;
      l_aelv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_aelv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aelv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_aelv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_aelv_rec);
    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKL_AE_LINES_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_aelv_rec IN  aelv_rec_type,
      x_aelv_rec OUT NOCOPY aelv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aelv_rec := p_aelv_rec;
      x_aelv_rec.OBJECT_VERSION_NUMBER := 1;
      x_aelv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();
	  SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
	  		 DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
			 DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
			 DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
	  INTO  x_aelv_rec.REQUEST_ID
	  	     ,x_aelv_rec.PROGRAM_APPLICATION_ID
		     ,x_aelv_rec.PROGRAM_ID
		     ,x_aelv_rec.PROGRAM_UPDATE_DATE
	  FROM DUAL;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_aelv_rec := null_out_defaults(p_aelv_rec);
    -- Set primary key value
    l_aelv_rec.ae_line_id := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_aelv_rec,                        -- IN
      l_def_aelv_rec);                   -- OUT
	  --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_aelv_rec := fill_who_columns(l_def_aelv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aelv_rec);
		 --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aelv_rec);
		  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aelv_rec, l_ael_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ael_rec,
      lx_ael_rec
    );
		  IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ael_rec, l_def_aelv_rec);
    -- Set OUT values
    x_aelv_rec := l_def_aelv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
	NULL;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:AELV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type,
    x_aelv_tbl                     OUT NOCOPY aelv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aelv_tbl.COUNT > 0) THEN
      i := p_aelv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aelv_rec                     => p_aelv_tbl(i),
          x_aelv_rec                     => x_aelv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_aelv_tbl.LAST);
        i := p_aelv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

    --gboomina bug#4648697..changes for perf start
     --added new procedure for bulk insert
     ----------------------------------------
     -- PL/SQL TBL insert_row_perf for:AELV_TBL --
     ----------------------------------------
     PROCEDURE insert_row_perf(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_aelv_tbl                     IN aelv_tbl_type,
       x_aelv_tbl                     OUT NOCOPY aelv_tbl_type) IS

       l_tabsize                       NUMBER := p_aelv_tbl.COUNT;
       ae_line_id_tbl                  ae_line_id_typ;
       account_overlay_source_id_tbl   account_overlay_source_id_typ;
       subledger_doc_seq_value_tbl     subledger_doc_seq_value_typ;
       tax_code_id_tbl                 tax_code_id_typ;
       ae_line_number_tbl              ae_line_number_typ;
       code_combination_id_tbl         code_combination_id_typ;
       ae_header_id_tbl                ae_header_id_typ;
       currency_conversion_type_tbl    currency_conversion_type_typ;
       ae_line_type_code_tbl           ae_line_type_code_typ;
       source_table_tbl                source_table_typ;
       source_id_tbl                   source_id_typ;
       object_version_number_tbl       object_version_number_typ;
       currency_code_tbl               currency_code_typ;
       currency_conversion_date_tbl    currency_conversion_date_typ;
       currency_conversion_rate_tbl    currency_conversion_rate_typ;
       entered_dr_tbl                  entered_dr_typ;
       entered_cr_tbl                  entered_cr_typ;
       accounted_dr_tbl                accounted_dr_typ;
       accounted_cr_tbl                accounted_cr_typ;
       reference1_tbl                  reference1_typ;
       reference2_tbl                  reference2_typ;
       reference3_tbl                  reference3_typ;
       reference4_tbl                  reference4_typ;
       reference5_tbl                  reference5_typ;
       reference6_tbl                  reference6_typ;
       reference7_tbl                  reference7_typ;
       reference8_tbl                  reference8_typ;
       reference9_tbl                  reference9_typ;
       reference10_tbl                 reference10_typ;
       description_tbl                 description_typ;
       third_party_id_tbl              third_party_id_typ;
       third_party_sub_id_tbl          third_party_sub_id_typ;
       stat_amount_tbl                 stat_amount_typ;
       ussgl_transaction_code_tbl      ussgl_transaction_code_typ;
       subledger_doc_sequence_id_tbl   subledger_doc_sequence_id_typ;
       accounting_error_code_tbl       accounting_error_code_typ;
       gl_transfer_error_code_tbl      gl_transfer_error_code_typ;
       gl_sl_link_id_tbl               gl_sl_link_id_typ;
       taxable_entered_dr_tbl          taxable_entered_dr_typ;
       taxable_entered_cr_tbl          taxable_entered_cr_typ;
       taxable_accounted_dr_tbl        taxable_accounted_dr_typ;
       taxable_accounted_cr_tbl        taxable_accounted_cr_typ;
       applied_from_trx_hdr_tab_tbl    applied_from_trx_hdr_tab_typ;
       applied_from_trx_hdr_id_tbl     applied_from_trx_hdr_id_typ;
       applied_to_trx_hdr_table_tbl    applied_to_trx_hdr_table_typ;
       applied_to_trx_hdr_id_tbl       applied_to_trx_hdr_id_typ;
       tax_link_id_tbl                 tax_link_id_typ;
       org_id_tbl                      org_id_typ;
       program_id_tbl                  program_id_typ;
       program_application_id_tbl      program_application_id_typ;
       program_update_date_tbl         program_update_date_typ;
       request_id_tbl                  request_id_typ;
       created_by_tbl                  created_by_typ;
       creation_date_tbl               creation_date_typ;
       last_updated_by_tbl             last_updated_by_typ;
       last_update_date_tbl            last_update_date_typ;
       last_update_login_tbl           last_update_login_typ;
       j                               NUMBER := 0;

     BEGIN
       IF (p_aelv_tbl.COUNT > 0) THEN

         --populate column tables
         FOR i IN p_aelv_tbl.FIRST..p_aelv_tbl.LAST
         LOOP
           j := j+1;

           ae_line_id_tbl(j)                 :=  p_aelv_tbl(i).ae_line_id;
           account_overlay_source_id_tbl(j)  :=  p_aelv_tbl(i).account_overlay_source_id;
           subledger_doc_seq_value_tbl(j)    :=  p_aelv_tbl(i).subledger_doc_sequence_value;
           tax_code_id_tbl(j)                :=  p_aelv_tbl(i).tax_code_id;
           ae_line_number_tbl(j)             :=  p_aelv_tbl(i).ae_line_number;
           code_combination_id_tbl(j)        :=  p_aelv_tbl(i).code_combination_id;
           ae_header_id_tbl(j)               :=  p_aelv_tbl(i).ae_header_id;
           currency_conversion_type_tbl(j)   :=  p_aelv_tbl(i).currency_conversion_type;
           ae_line_type_code_tbl(j)          :=  p_aelv_tbl(i).ae_line_type_code;
           source_table_tbl(j)               :=  p_aelv_tbl(i).source_table;
           source_id_tbl(j)                  :=  p_aelv_tbl(i).source_id;
           object_version_number_tbl(j)      :=  p_aelv_tbl(i).object_version_number;
           currency_code_tbl(j)              :=  p_aelv_tbl(i).currency_code;
           currency_conversion_date_tbl(j)   :=  p_aelv_tbl(i).currency_conversion_date;
           currency_conversion_rate_tbl(j)   :=  p_aelv_tbl(i).currency_conversion_rate;
           entered_dr_tbl(j)                 :=  p_aelv_tbl(i).entered_dr;
           entered_cr_tbl(j)                 :=  p_aelv_tbl(i).entered_cr;
           accounted_dr_tbl(j)               :=  p_aelv_tbl(i).accounted_dr;
           accounted_cr_tbl(j)               :=  p_aelv_tbl(i).accounted_cr;
           reference1_tbl(j)                 :=  p_aelv_tbl(i).reference1;
           reference2_tbl(j)                 :=  p_aelv_tbl(i).reference2;
           reference3_tbl(j)                 :=  p_aelv_tbl(i).reference3;
           reference4_tbl(j)                 :=  p_aelv_tbl(i).reference4;
           reference5_tbl(j)                 :=  p_aelv_tbl(i).reference5;
           reference6_tbl(j)                 :=  p_aelv_tbl(i).reference6;
           reference7_tbl(j)                 :=  p_aelv_tbl(i).reference7;
           reference8_tbl(j)                 :=  p_aelv_tbl(i).reference8;
           reference9_tbl(j)                 :=  p_aelv_tbl(i).reference9;
           reference10_tbl(j)                :=  p_aelv_tbl(i).reference10;
           description_tbl(j)                :=  p_aelv_tbl(i).description;
           third_party_id_tbl(j)             :=  p_aelv_tbl(i).third_party_id;
           third_party_sub_id_tbl(j)         :=  p_aelv_tbl(i).third_party_sub_id;
           stat_amount_tbl(j)                :=  p_aelv_tbl(i).stat_amount;
           ussgl_transaction_code_tbl(j)     :=  p_aelv_tbl(i).ussgl_transaction_code;
           subledger_doc_sequence_id_tbl(j)  :=  p_aelv_tbl(i).subledger_doc_sequence_id;
           accounting_error_code_tbl(j)      :=  p_aelv_tbl(i).accounting_error_code;
           gl_transfer_error_code_tbl(j)     :=  p_aelv_tbl(i).gl_transfer_error_code;
           gl_sl_link_id_tbl(j)              :=  p_aelv_tbl(i).gl_sl_link_id;
           taxable_entered_dr_tbl(j)         :=  p_aelv_tbl(i).taxable_entered_dr;
           taxable_entered_cr_tbl(j)         :=  p_aelv_tbl(i).taxable_entered_cr;
           taxable_accounted_dr_tbl(j)       :=  p_aelv_tbl(i).taxable_accounted_dr;
           taxable_accounted_cr_tbl(j)       :=  p_aelv_tbl(i).taxable_accounted_cr;
           applied_from_trx_hdr_tab_tbl(j)   :=  p_aelv_tbl(i).applied_from_trx_hdr_table;
           applied_from_trx_hdr_id_tbl(j)    :=  p_aelv_tbl(i).applied_from_trx_hdr_id;
           applied_to_trx_hdr_table_tbl(j)   :=  p_aelv_tbl(i).applied_to_trx_hdr_table;
           applied_to_trx_hdr_id_tbl(j)      :=  p_aelv_tbl(i).applied_to_trx_hdr_id;
           tax_link_id_tbl(j)                :=  p_aelv_tbl(i).tax_link_id;
           org_id_tbl(j)                     :=  p_aelv_tbl(i).org_id;
           program_id_tbl(j)                 :=  p_aelv_tbl(i).program_id;
           program_application_id_tbl(j)     :=  p_aelv_tbl(i).program_application_id;
           program_update_date_tbl(j)        :=  p_aelv_tbl(i).program_update_date;
           request_id_tbl(j)                 :=  p_aelv_tbl(i).request_id;
           created_by_tbl(j)                 :=  p_aelv_tbl(i).created_by;
           creation_date_tbl(j)              :=  p_aelv_tbl(i).creation_date;
           last_updated_by_tbl(j)            :=  p_aelv_tbl(i).last_updated_by;
           last_update_date_tbl(j)           :=  p_aelv_tbl(i).last_update_date;
           last_update_login_tbl(j)          :=  p_aelv_tbl(i).last_update_login;

         END LOOP;

         --bulk insert into okl_ae_lines
         FORALL i IN 1..l_tabsize
           INSERT INTO OKL_AE_LINES(
               ae_line_id,
               code_combination_id,
               ae_header_id,
               currency_conversion_type,
               org_id,
               ae_line_number,
               ae_line_type_code,
               source_table,
               source_id,
               object_version_number,
               currency_code,
               currency_conversion_date,
               currency_conversion_rate,
               entered_dr,
               entered_cr,
               accounted_dr,
               accounted_cr,
               reference1,
               reference2,
               reference3,
               reference4,
               reference5,
               reference6,
               reference7,
               reference8,
               reference9,
               reference10,
               description,
               third_party_id,
               third_party_sub_id,
               stat_amount,
               ussgl_transaction_code,
               subledger_doc_sequence_id,
               accounting_error_code,
               gl_transfer_error_code,
               gl_sl_link_id,
               taxable_entered_dr,
               taxable_entered_cr,
               taxable_accounted_dr,
               taxable_accounted_cr,
               applied_from_trx_hdr_table,
               applied_from_trx_hdr_id,
               applied_to_trx_hdr_table,
               applied_to_trx_hdr_id,
               tax_link_id,
               program_id,
               program_application_id,
               program_update_date,
               request_id,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               account_overlay_source_id,
               subledger_doc_sequence_value,
               tax_code_id)
           VALUES (
               ae_line_id_tbl(i),
               code_combination_id_tbl(i),
               ae_header_id_tbl(i),
               currency_conversion_type_tbl(i),
               org_id_tbl(i),
               ae_line_number_tbl(i),
               ae_line_type_code_tbl(i),
               source_table_tbl(i),
               source_id_tbl(i),
               object_version_number_tbl(i),
               currency_code_tbl(i),
               currency_conversion_date_tbl(i),
               currency_conversion_rate_tbl(i),
               entered_dr_tbl(i),
               entered_cr_tbl(i),
               accounted_dr_tbl(i),
               accounted_cr_tbl(i),
               reference1_tbl(i),
               reference2_tbl(i),
               reference3_tbl(i),
               reference4_tbl(i),
               reference5_tbl(i),
               reference6_tbl(i),
               reference7_tbl(i),
               reference8_tbl(i),
               reference9_tbl(i),
               reference10_tbl(i),
               description_tbl(i),
               third_party_id_tbl(i),
               third_party_sub_id_tbl(i),
               stat_amount_tbl(i),
               ussgl_transaction_code_tbl(i),
               subledger_doc_sequence_id_tbl(i),
               accounting_error_code_tbl(i),
               gl_transfer_error_code_tbl(i),
               gl_sl_link_id_tbl(i),
               taxable_entered_dr_tbl(i),
               taxable_entered_cr_tbl(i),
               taxable_accounted_dr_tbl(i),
               taxable_accounted_cr_tbl(i),
               applied_from_trx_hdr_tab_tbl(i),
               applied_from_trx_hdr_id_tbl(i),
               applied_to_trx_hdr_table_tbl(i),
               applied_to_trx_hdr_id_tbl(i),
               tax_link_id_tbl(i),
               program_id_tbl(i),
               program_application_id_tbl(i),
               program_update_date_tbl(i),
               request_id_tbl(i),
               created_by_tbl(i),
               creation_date_tbl(i),
               last_updated_by_tbl(i),
               last_update_date_tbl(i),
               last_update_login_tbl(i),
               account_overlay_source_id_tbl(i),
               subledger_doc_seq_value_tbl(i),
               tax_code_id_tbl(i));

       END IF;
       --set OUT params
       x_aelv_tbl := p_aelv_tbl;

     END insert_row_perf;
     --gboomina bug#4648697..changes for perf end

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  -------------------------------
  -- lock_row for:OKL_AE_LINES --
  -------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ael_rec                      IN ael_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ael_rec IN ael_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AE_LINES
     WHERE ae_line_id = p_ael_rec.ae_line_id
       AND OBJECT_VERSION_NUMBER = p_ael_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ael_rec IN ael_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AE_LINES
    WHERE ae_line_id = p_ael_rec.ae_line_id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_AE_LINES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_AE_LINES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_ael_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_ael_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ael_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ael_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okc_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------
  -- lock_row for:OKL_AE_LINES_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_ael_rec                      ael_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_aelv_rec, l_ael_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ael_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:AELV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aelv_tbl.COUNT > 0) THEN
      i := p_aelv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aelv_rec                     => p_aelv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_aelv_tbl.LAST);
        i := p_aelv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  ---------------------------------
  -- update_row for:OKL_AE_LINES --
  ---------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ael_rec                      IN ael_rec_type,
    x_ael_rec                      OUT NOCOPY ael_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_ael_rec                      ael_rec_type := p_ael_rec;
    l_def_ael_rec                  ael_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ael_rec	IN ael_rec_type,
      x_ael_rec	OUT NOCOPY ael_rec_type
    ) RETURN VARCHAR2 IS
      l_ael_rec                      ael_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ael_rec := p_ael_rec;
      -- Get current database values
      l_ael_rec := get_rec(p_ael_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ael_rec.ae_line_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.ae_line_id := l_ael_rec.ae_line_id;
      END IF;
      IF (x_ael_rec.code_combination_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.code_combination_id := l_ael_rec.code_combination_id;
      END IF;
      IF (x_ael_rec.AE_HEADER_ID = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.AE_HEADER_ID := l_ael_rec.AE_HEADER_ID;
      END IF;
      IF (x_ael_rec.currency_conversion_type = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.currency_conversion_type := l_ael_rec.currency_conversion_type;
      END IF;
      IF (x_ael_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.org_id := l_ael_rec.org_id;
      END IF;
      IF (x_ael_rec.AE_LINE_NUMBER = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.AE_LINE_NUMBER := l_ael_rec.AE_LINE_NUMBER;
      END IF;
      IF (x_ael_rec.AE_LINE_TYPE_CODE = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.AE_LINE_TYPE_CODE := l_ael_rec.AE_LINE_TYPE_CODE;
      END IF;
      IF (x_ael_rec.source_table = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.source_table := l_ael_rec.source_table;
      END IF;
      IF (x_ael_rec.source_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.source_id := l_ael_rec.source_id;
      END IF;
      IF (x_ael_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.object_version_number := l_ael_rec.object_version_number;
      END IF;
      IF (x_ael_rec.currency_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.currency_code := l_ael_rec.currency_code;
      END IF;
      IF (x_ael_rec.currency_conversion_date = Okc_Api.G_MISS_DATE)
      THEN
        x_ael_rec.currency_conversion_date := l_ael_rec.currency_conversion_date;
      END IF;
      IF (x_ael_rec.currency_conversion_rate = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.currency_conversion_rate := l_ael_rec.currency_conversion_rate;
      END IF;
      IF (x_ael_rec.ENTERED_DR = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.ENTERED_DR := l_ael_rec.ENTERED_DR;
      END IF;
      IF (x_ael_rec.ENTERED_CR = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.ENTERED_CR := l_ael_rec.ENTERED_CR;
      END IF;
      IF (x_ael_rec.ACCOUNTED_DR = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.ACCOUNTED_DR := l_ael_rec.ACCOUNTED_DR;
      END IF;
      IF (x_ael_rec.ACCOUNTED_CR = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.ACCOUNTED_CR := l_ael_rec.ACCOUNTED_CR;
      END IF;
      IF (x_ael_rec.reference1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.reference1 := l_ael_rec.reference1;
      END IF;
      IF (x_ael_rec.reference2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.reference2 := l_ael_rec.reference2;
      END IF;
      IF (x_ael_rec.reference3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.reference3 := l_ael_rec.reference3;
      END IF;
      IF (x_ael_rec.reference4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.reference4 := l_ael_rec.reference4;
      END IF;
      IF (x_ael_rec.reference5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.reference5 := l_ael_rec.reference5;
      END IF;
      IF (x_ael_rec.reference6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.reference6 := l_ael_rec.reference6;
      END IF;
      IF (x_ael_rec.reference7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.reference7 := l_ael_rec.reference7;
      END IF;
      IF (x_ael_rec.reference8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.reference8 := l_ael_rec.reference8;
      END IF;
      IF (x_ael_rec.reference9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.reference9 := l_ael_rec.reference9;
      END IF;
      IF (x_ael_rec.reference10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.reference10 := l_ael_rec.reference10;
      END IF;
      IF (x_ael_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.description := l_ael_rec.description;
      END IF;
      IF (x_ael_rec.third_party_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.third_party_id := l_ael_rec.third_party_id;
      END IF;
      IF (x_ael_rec.third_party_sub_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.third_party_sub_id := l_ael_rec.third_party_sub_id;
      END IF;
      IF (x_ael_rec.STAT_AMOUNT = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.STAT_AMOUNT := l_ael_rec.STAT_AMOUNT;
      END IF;
      IF (x_ael_rec.ussgl_transaction_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.ussgl_transaction_code := l_ael_rec.ussgl_transaction_code;
      END IF;
      IF (x_ael_rec.subledger_doc_sequence_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.subledger_doc_sequence_id := l_ael_rec.subledger_doc_sequence_id;
      END IF;
      IF (x_ael_rec.accounting_error_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.accounting_error_code := l_ael_rec.accounting_error_code;
      END IF;
      IF (x_ael_rec.gl_transfer_error_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.gl_transfer_error_code := l_ael_rec.gl_transfer_error_code;
      END IF;
      IF (x_ael_rec.GL_SL_LINK_ID = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.GL_SL_LINK_ID := l_ael_rec.GL_SL_LINK_ID;
      END IF;
      IF (x_ael_rec.taxable_ENTERED_DR = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.taxable_ENTERED_DR := l_ael_rec.taxable_ENTERED_DR;
      END IF;
      IF (x_ael_rec.taxable_ENTERED_CR = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.taxable_ENTERED_CR := l_ael_rec.taxable_ENTERED_CR;
      END IF;
      IF (x_ael_rec.taxable_ACCOUNTED_DR = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.taxable_ACCOUNTED_DR := l_ael_rec.taxable_ACCOUNTED_DR;
      END IF;
      IF (x_ael_rec.taxable_ACCOUNTED_CR = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.taxable_ACCOUNTED_CR := l_ael_rec.taxable_ACCOUNTED_CR;
      END IF;
      IF (x_ael_rec.applied_from_trx_hdr_table = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.applied_from_trx_hdr_table := l_ael_rec.applied_from_trx_hdr_table;
      END IF;
      IF (x_ael_rec.applied_from_trx_hdr_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.applied_from_trx_hdr_id := l_ael_rec.applied_from_trx_hdr_id;
      END IF;
      IF (x_ael_rec.applied_to_trx_hdr_table = Okc_Api.G_MISS_CHAR)
      THEN
        x_ael_rec.applied_to_trx_hdr_table := l_ael_rec.applied_to_trx_hdr_table;
      END IF;
      IF (x_ael_rec.applied_to_trx_hdr_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.applied_to_trx_hdr_id := l_ael_rec.applied_to_trx_hdr_id;
      END IF;
      IF (x_ael_rec.tax_link_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.tax_link_id := l_ael_rec.tax_link_id;
      END IF;
      IF (x_ael_rec.program_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.program_id := l_ael_rec.program_id;
      END IF;
      IF (x_ael_rec.program_application_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.program_application_id := l_ael_rec.program_application_id;
      END IF;
      IF (x_ael_rec.program_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_ael_rec.program_update_date := l_ael_rec.program_update_date;
      END IF;
      IF (x_ael_rec.request_id = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.request_id := l_ael_rec.request_id;
      END IF;
      IF (x_ael_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.created_by := l_ael_rec.created_by;
      END IF;
      IF (x_ael_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_ael_rec.creation_date := l_ael_rec.creation_date;
      END IF;
      IF (x_ael_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.last_updated_by := l_ael_rec.last_updated_by;
      END IF;
      IF (x_ael_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_ael_rec.last_update_date := l_ael_rec.last_update_date;
      END IF;
      IF (x_ael_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.last_update_login := l_ael_rec.last_update_login;
      END IF;
      IF (x_ael_rec.ACCOUNT_OVERLAY_SOURCE_ID = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.ACCOUNT_OVERLAY_SOURCE_ID := l_ael_rec.ACCOUNT_OVERLAY_SOURCE_ID;
      END IF;
      IF (x_ael_rec.SUBLEDGER_DOC_SEQUENCE_VALUE = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.SUBLEDGER_DOC_SEQUENCE_VALUE := l_ael_rec.SUBLEDGER_DOC_SEQUENCE_VALUE;
      END IF;
      IF (x_ael_rec.TAX_CODE_ID = Okc_Api.G_MISS_NUM)
      THEN
        x_ael_rec.TAX_CODE_ID := l_ael_rec.TAX_CODE_ID;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------
    -- Set_Attributes for:OKL_AE_LINES --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_ael_rec IN  ael_rec_type,
      x_ael_rec OUT NOCOPY ael_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ael_rec := p_ael_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ael_rec,                         -- IN
      l_ael_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ael_rec, l_def_ael_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_AE_LINES
    SET CODE_COMBINATION_ID = l_def_ael_rec.code_combination_id,
        AE_HEADER_ID = l_def_ael_rec.AE_HEADER_ID,
        CURRENCY_CONVERSION_TYPE = l_def_ael_rec.currency_conversion_type,
        ORG_ID = l_def_ael_rec.org_id,
        AE_LINE_NUMBER = l_def_ael_rec.AE_LINE_NUMBER,
        AE_LINE_TYPE_CODE = l_def_ael_rec.AE_LINE_TYPE_CODE,
        SOURCE_TABLE = l_def_ael_rec.source_table,
        SOURCE_ID = l_def_ael_rec.source_id,
        OBJECT_VERSION_NUMBER = l_def_ael_rec.object_version_number,
        CURRENCY_CODE = l_def_ael_rec.currency_code,
        CURRENCY_CONVERSION_DATE = l_def_ael_rec.currency_conversion_date,
        CURRENCY_CONVERSION_RATE = l_def_ael_rec.currency_conversion_rate,
        ENTERED_DR = l_def_ael_rec.ENTERED_DR,
        ENTERED_CR = l_def_ael_rec.ENTERED_CR,
        ACCOUNTED_DR = l_def_ael_rec.ACCOUNTED_DR,
        ACCOUNTED_CR = l_def_ael_rec.ACCOUNTED_CR,
        REFERENCE1 = l_def_ael_rec.reference1,
        REFERENCE2 = l_def_ael_rec.reference2,
        REFERENCE3 = l_def_ael_rec.reference3,
        REFERENCE4 = l_def_ael_rec.reference4,
        REFERENCE5 = l_def_ael_rec.reference5,
        REFERENCE6 = l_def_ael_rec.reference6,
        REFERENCE7 = l_def_ael_rec.reference7,
        REFERENCE8 = l_def_ael_rec.reference8,
        REFERENCE9 = l_def_ael_rec.reference9,
        REFERENCE10 = l_def_ael_rec.reference10,
        DESCRIPTION = l_def_ael_rec.description,
        THIRD_PARTY_ID = l_def_ael_rec.third_party_id,
        THIRD_PARTY_SUB_ID = l_def_ael_rec.third_party_sub_id,
        STAT_AMOUNT = l_def_ael_rec.STAT_AMOUNT,
        USSGL_TRANSACTION_CODE = l_def_ael_rec.ussgl_transaction_code,
        SUBLEDGER_DOC_SEQUENCE_ID = l_def_ael_rec.subledger_doc_sequence_id,
        ACCOUNTING_ERROR_CODE = l_def_ael_rec.accounting_error_code,
        GL_TRANSFER_ERROR_CODE = l_def_ael_rec.gl_transfer_error_code,
        GL_SL_LINK_ID = l_def_ael_rec.GL_SL_LINK_ID,
        TAXABLE_ENTERED_DR = l_def_ael_rec.taxable_ENTERED_DR,
        TAXABLE_ENTERED_CR = l_def_ael_rec.taxable_ENTERED_CR,
        TAXABLE_ACCOUNTED_DR = l_def_ael_rec.taxable_ACCOUNTED_DR,
        TAXABLE_ACCOUNTED_CR = l_def_ael_rec.taxable_ACCOUNTED_CR,
        APPLIED_FROM_TRX_HDR_TABLE = l_def_ael_rec.applied_from_trx_hdr_table,
        APPLIED_FROM_TRX_HDR_ID = l_def_ael_rec.applied_from_trx_hdr_id,
        APPLIED_TO_TRX_HDR_TABLE = l_def_ael_rec.applied_to_trx_hdr_table,
        APPLIED_TO_TRX_HDR_ID = l_def_ael_rec.applied_to_trx_hdr_id,
        TAX_LINK_ID = l_def_ael_rec.tax_link_id,
        PROGRAM_ID = l_def_ael_rec.program_id,
        PROGRAM_APPLICATION_ID = l_def_ael_rec.program_application_id,
        PROGRAM_UPDATE_DATE = l_def_ael_rec.program_update_date,
        REQUEST_ID = l_def_ael_rec.request_id,
        CREATED_BY = l_def_ael_rec.created_by,
        CREATION_DATE = l_def_ael_rec.creation_date,
        LAST_UPDATED_BY = l_def_ael_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ael_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ael_rec.last_update_login,
		ACCOUNT_OVERLAY_SOURCE_ID = l_def_ael_rec.ACCOUNT_OVERLAY_SOURCE_ID,
		SUBLEDGER_DOC_SEQUENCE_VALUE = l_def_ael_rec.SUBLEDGER_DOC_SEQUENCE_VALUE,
		TAX_CODE_ID = l_def_ael_rec.TAX_CODE_ID
    WHERE ae_line_id = l_def_ael_rec.ae_line_id;

    x_ael_rec := l_def_ael_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -----------------------------------
  -- update_row for:OKL_AE_LINES_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type,
    x_aelv_rec                     OUT NOCOPY aelv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aelv_rec                     aelv_rec_type := p_aelv_rec;
    l_def_aelv_rec                 aelv_rec_type;
    l_ael_rec                      ael_rec_type;
    lx_ael_rec                     ael_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aelv_rec	IN aelv_rec_type
    ) RETURN aelv_rec_type IS
      l_aelv_rec	aelv_rec_type := p_aelv_rec;
    BEGIN
      l_aelv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aelv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_aelv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_aelv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aelv_rec	IN aelv_rec_type,
      x_aelv_rec	OUT NOCOPY aelv_rec_type
    ) RETURN VARCHAR2 IS
      l_aelv_rec                     aelv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aelv_rec := p_aelv_rec;
      -- Get current database values
      l_aelv_rec := get_rec(p_aelv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aelv_rec.ae_line_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.ae_line_id := l_aelv_rec.ae_line_id;
      END IF;
      IF (x_aelv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.object_version_number := l_aelv_rec.object_version_number;
      END IF;
      IF (x_aelv_rec.AE_HEADER_ID = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.AE_HEADER_ID := l_aelv_rec.AE_HEADER_ID;
      END IF;
      IF (x_aelv_rec.currency_conversion_type = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.currency_conversion_type := l_aelv_rec.currency_conversion_type;
      END IF;
      IF (x_aelv_rec.code_combination_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.code_combination_id := l_aelv_rec.code_combination_id;
      END IF;
      IF (x_aelv_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.org_id := l_aelv_rec.org_id;
      END IF;
      IF (x_aelv_rec.AE_LINE_NUMBER = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.AE_LINE_NUMBER := l_aelv_rec.AE_LINE_NUMBER;
      END IF;
      IF (x_aelv_rec.AE_LINE_TYPE_CODE = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.AE_LINE_TYPE_CODE := l_aelv_rec.AE_LINE_TYPE_CODE;
      END IF;
      IF (x_aelv_rec.currency_conversion_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aelv_rec.currency_conversion_date := l_aelv_rec.currency_conversion_date;
      END IF;
      IF (x_aelv_rec.currency_conversion_rate = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.currency_conversion_rate := l_aelv_rec.currency_conversion_rate;
      END IF;
      IF (x_aelv_rec.ENTERED_DR = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.ENTERED_DR := l_aelv_rec.ENTERED_DR;
      END IF;
      IF (x_aelv_rec.ENTERED_CR = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.ENTERED_CR := l_aelv_rec.ENTERED_CR;
      END IF;
      IF (x_aelv_rec.ACCOUNTED_DR = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.ACCOUNTED_DR := l_aelv_rec.ACCOUNTED_DR;
      END IF;
      IF (x_aelv_rec.ACCOUNTED_CR = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.ACCOUNTED_CR := l_aelv_rec.ACCOUNTED_CR;
      END IF;
      IF (x_aelv_rec.source_table = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.source_table := l_aelv_rec.source_table;
      END IF;
      IF (x_aelv_rec.source_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.source_id := l_aelv_rec.source_id;
      END IF;
      IF (x_aelv_rec.reference1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.reference1 := l_aelv_rec.reference1;
      END IF;
      IF (x_aelv_rec.reference2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.reference2 := l_aelv_rec.reference2;
      END IF;
      IF (x_aelv_rec.reference3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.reference3 := l_aelv_rec.reference3;
      END IF;
      IF (x_aelv_rec.reference4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.reference4 := l_aelv_rec.reference4;
      END IF;
      IF (x_aelv_rec.reference5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.reference5 := l_aelv_rec.reference5;
      END IF;
      IF (x_aelv_rec.reference6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.reference6 := l_aelv_rec.reference6;
      END IF;
      IF (x_aelv_rec.reference7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.reference7 := l_aelv_rec.reference7;
      END IF;
      IF (x_aelv_rec.reference8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.reference8 := l_aelv_rec.reference8;
      END IF;
      IF (x_aelv_rec.reference9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.reference9 := l_aelv_rec.reference9;
      END IF;
      IF (x_aelv_rec.reference10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.reference10 := l_aelv_rec.reference10;
      END IF;
      IF (x_aelv_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.description := l_aelv_rec.description;
      END IF;
      IF (x_aelv_rec.third_party_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.third_party_id := l_aelv_rec.third_party_id;
      END IF;
      IF (x_aelv_rec.third_party_sub_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.third_party_sub_id := l_aelv_rec.third_party_sub_id;
      END IF;
      IF (x_aelv_rec.STAT_AMOUNT = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.STAT_AMOUNT := l_aelv_rec.STAT_AMOUNT;
      END IF;
      IF (x_aelv_rec.ussgl_transaction_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.ussgl_transaction_code := l_aelv_rec.ussgl_transaction_code;
      END IF;
      IF (x_aelv_rec.subledger_doc_sequence_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.subledger_doc_sequence_id := l_aelv_rec.subledger_doc_sequence_id;
      END IF;
      IF (x_aelv_rec.accounting_error_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.accounting_error_code := l_aelv_rec.accounting_error_code;
      END IF;
      IF (x_aelv_rec.gl_transfer_error_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.gl_transfer_error_code := l_aelv_rec.gl_transfer_error_code;
      END IF;
      IF (x_aelv_rec.GL_SL_LINK_ID = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.GL_SL_LINK_ID := l_aelv_rec.GL_SL_LINK_ID;
      END IF;
      IF (x_aelv_rec.taxable_ENTERED_DR = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.taxable_ENTERED_DR := l_aelv_rec.taxable_ENTERED_DR;
      END IF;
      IF (x_aelv_rec.taxable_ENTERED_CR = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.taxable_ENTERED_CR := l_aelv_rec.taxable_ENTERED_CR;
      END IF;
      IF (x_aelv_rec.taxable_ACCOUNTED_DR = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.taxable_ACCOUNTED_DR := l_aelv_rec.taxable_ACCOUNTED_DR;
      END IF;
      IF (x_aelv_rec.taxable_ACCOUNTED_CR = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.taxable_ACCOUNTED_CR := l_aelv_rec.taxable_ACCOUNTED_CR;
      END IF;
      IF (x_aelv_rec.applied_from_trx_hdr_table = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.applied_from_trx_hdr_table := l_aelv_rec.applied_from_trx_hdr_table;
      END IF;
      IF (x_aelv_rec.applied_from_trx_hdr_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.applied_from_trx_hdr_id := l_aelv_rec.applied_from_trx_hdr_id;
      END IF;
      IF (x_aelv_rec.applied_to_trx_hdr_table = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.applied_to_trx_hdr_table := l_aelv_rec.applied_to_trx_hdr_table;
      END IF;
      IF (x_aelv_rec.applied_to_trx_hdr_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.applied_to_trx_hdr_id := l_aelv_rec.applied_to_trx_hdr_id;
      END IF;
      IF (x_aelv_rec.tax_link_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.tax_link_id := l_aelv_rec.tax_link_id;
      END IF;
      IF (x_aelv_rec.currency_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_aelv_rec.currency_code := l_aelv_rec.currency_code;
      END IF;
      IF (x_aelv_rec.program_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.program_id := l_aelv_rec.program_id;
      END IF;
      IF (x_aelv_rec.program_application_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.program_application_id := l_aelv_rec.program_application_id;
      END IF;
      IF (x_aelv_rec.program_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aelv_rec.program_update_date := l_aelv_rec.program_update_date;
      END IF;
      IF (x_aelv_rec.request_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.request_id := l_aelv_rec.request_id;
      END IF;
      IF (x_aelv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.created_by := l_aelv_rec.created_by;
      END IF;
      IF (x_aelv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aelv_rec.creation_date := l_aelv_rec.creation_date;
      END IF;
      IF (x_aelv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.last_updated_by := l_aelv_rec.last_updated_by;
      END IF;
      IF (x_aelv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aelv_rec.last_update_date := l_aelv_rec.last_update_date;
      END IF;
      IF (x_aelv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.last_update_login := l_aelv_rec.last_update_login;
      END IF;
      IF (x_aelv_rec.ACCOUNT_OVERLAY_SOURCE_ID = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.ACCOUNT_OVERLAY_SOURCE_ID := l_aelv_rec.ACCOUNT_OVERLAY_SOURCE_ID;
      END IF;
	  IF (x_aelv_rec.SUBLEDGER_DOC_SEQUENCE_VALUE = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.SUBLEDGER_DOC_SEQUENCE_VALUE := l_aelv_rec.SUBLEDGER_DOC_SEQUENCE_VALUE;
      END IF;
      IF (x_aelv_rec.TAX_CODE_ID = Okc_Api.G_MISS_NUM)
      THEN
        x_aelv_rec.TAX_CODE_ID := l_aelv_rec.TAX_CODE_ID;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_AE_LINES_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_aelv_rec IN  aelv_rec_type,
      x_aelv_rec OUT NOCOPY aelv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aelv_rec := p_aelv_rec;

     SELECT NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
                                           x_aelv_rec.REQUEST_ID),
            NVL(DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.PROG_APPL_ID),
                                           x_aelv_rec.PROGRAM_APPLICATION_ID),
            NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
                                           x_aelv_rec.PROGRAM_ID),
            DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
                                           NULL,x_aelv_rec.PROGRAM_UPDATE_DATE,SYSDATE)
     INTO  x_aelv_rec.REQUEST_ID
          ,x_aelv_rec.PROGRAM_APPLICATION_ID
          ,x_aelv_rec.PROGRAM_ID
          ,x_aelv_rec.PROGRAM_UPDATE_DATE
     FROM DUAL;

      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_aelv_rec,                        -- IN
      l_aelv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aelv_rec, l_def_aelv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_aelv_rec := fill_who_columns(l_def_aelv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aelv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aelv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aelv_rec, l_ael_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ael_rec,
      lx_ael_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ael_rec, l_def_aelv_rec);
    x_aelv_rec := l_def_aelv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:AELV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type,
    x_aelv_tbl                     OUT NOCOPY aelv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aelv_tbl.COUNT > 0) THEN
      i := p_aelv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aelv_rec                     => p_aelv_tbl(i),
          x_aelv_rec                     => x_aelv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_aelv_tbl.LAST);
        i := p_aelv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  ---------------------------------
  -- delete_row for:OKL_AE_LINES --
  ---------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ael_rec                      IN ael_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_ael_rec                      ael_rec_type:= p_ael_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_AE_LINES
     WHERE ae_line_id = l_ael_rec.ae_line_id;

    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------
  -- delete_row for:OKL_AE_LINES_V --
  -----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aelv_rec                     aelv_rec_type := p_aelv_rec;
    l_ael_rec                      ael_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_aelv_rec, l_ael_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ael_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:AELV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aelv_tbl.COUNT > 0) THEN
      i := p_aelv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aelv_rec                     => p_aelv_tbl(i));

        -- store the highest degree of error

	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_aelv_tbl.LAST);
        i := p_aelv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END Okl_Ael_Pvt;

/
