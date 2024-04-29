--------------------------------------------------------
--  DDL for Package Body OKL_TAB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TAB_PVT" AS
/* $Header: OKLSTABB.pls 120.8.12010000.2 2008/08/14 12:13:42 racheruv ship $ */

   l_sysdate DATE := SYSDATE;
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  l_seq NUMBER;
  BEGIN
-- Changed sequence name by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    SELECT OKL_TRNS_ACC_DSTRS_ALL_S.NEXTVAL INTO l_seq FROM DUAL;
    RETURN l_seq;
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
  -- FUNCTION get_rec for: OKL_TRNS_ACC_DSTRS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tab_rec                      IN tab_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tab_rec_type IS
    CURSOR tab_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CURRENCY_CONVERSION_TYPE,
            SET_OF_BOOKS_ID,
            CR_DR_FLAG,
            CODE_COMBINATION_ID,
            ORG_ID,
            CURRENCY_CODE,
            AE_LINE_TYPE,
            TEMPLATE_ID,
            SOURCE_ID,
            SOURCE_TABLE,
            OBJECT_VERSION_NUMBER,
            AMOUNT,
            ACCOUNTED_AMOUNT,
            GL_DATE,
            PERCENTAGE,
            COMMENTS,
            POST_REQUEST_ID,
            CURRENCY_CONVERSION_DATE,
            CURRENCY_CONVERSION_RATE,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
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
            AET_ID,
            POSTED_YN,
            AE_CREATION_ERROR,
            GL_REVERSAL_FLAG,
            REVERSE_EVENT_FLAG,
            DRAFT_YN,
            DRAFT_VERSION,
            ORIGINAL_DIST_ID,
            ACCOUNTING_EVENT_ID,
            POST_TO_GL,
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
            ACCOUNTING_TEMPLATE_NAME,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
            UPGRADE_STATUS_FLAG
-- Changes End
      FROM Okl_Trns_Acc_Dstrs
     WHERE okl_trns_acc_dstrs.id = p_id;
    l_tab_pk                       tab_pk_csr%ROWTYPE;
    l_tab_rec                      tab_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN tab_pk_csr (p_tab_rec.id);
    FETCH tab_pk_csr INTO
              l_tab_rec.ID,
              l_tab_rec.CURRENCY_CONVERSION_TYPE,
              l_tab_rec.SET_OF_BOOKS_ID,
              l_tab_rec.CR_DR_FLAG,
              l_tab_rec.CODE_COMBINATION_ID,
              l_tab_rec.ORG_ID,
              l_tab_rec.CURRENCY_CODE,
              l_tab_rec.AE_LINE_TYPE,
              l_tab_rec.TEMPLATE_ID,
              l_tab_rec.SOURCE_ID,
              l_tab_rec.SOURCE_TABLE,
              l_tab_rec.OBJECT_VERSION_NUMBER,
              l_tab_rec.AMOUNT,
              l_tab_rec.ACCOUNTED_AMOUNT,
              l_tab_rec.GL_DATE,
              l_tab_rec.PERCENTAGE,
              l_tab_rec.COMMENTS,
              l_tab_rec.POST_REQUEST_ID,
              l_tab_rec.CURRENCY_CONVERSION_DATE,
              l_tab_rec.CURRENCY_CONVERSION_RATE,
              l_tab_rec.REQUEST_ID,
              l_tab_rec.PROGRAM_APPLICATION_ID,
              l_tab_rec.PROGRAM_ID,
              l_tab_rec.PROGRAM_UPDATE_DATE,
              l_tab_rec.ATTRIBUTE_CATEGORY,
              l_tab_rec.ATTRIBUTE1,
              l_tab_rec.ATTRIBUTE2,
              l_tab_rec.ATTRIBUTE3,
              l_tab_rec.ATTRIBUTE4,
              l_tab_rec.ATTRIBUTE5,
              l_tab_rec.ATTRIBUTE6,
              l_tab_rec.ATTRIBUTE7,
              l_tab_rec.ATTRIBUTE8,
              l_tab_rec.ATTRIBUTE9,
              l_tab_rec.ATTRIBUTE10,
              l_tab_rec.ATTRIBUTE11,
              l_tab_rec.ATTRIBUTE12,
              l_tab_rec.ATTRIBUTE13,
              l_tab_rec.ATTRIBUTE14,
              l_tab_rec.ATTRIBUTE15,
              l_tab_rec.CREATED_BY,
              l_tab_rec.CREATION_DATE,
              l_tab_rec.LAST_UPDATED_BY,
              l_tab_rec.LAST_UPDATE_DATE,
              l_tab_rec.LAST_UPDATE_LOGIN,
-- The following two fields have been added by Kanti Jinger on 07/12/2001
              l_tab_rec.AET_ID,
              l_tab_rec.POSTED_YN,
              l_tab_rec.AE_CREATION_ERROR,
              l_tab_rec.GL_REVERSAL_FLAG,
              l_tab_rec.REVERSE_EVENT_FLAG,
              l_tab_rec.DRAFT_YN,
              l_tab_rec.DRAFT_VERSION,
              l_tab_rec.ORIGINAL_DIST_ID,
              l_tab_rec.ACCOUNTING_EVENT_ID,
              l_tab_rec.POST_TO_GL,
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
              l_tab_rec.ACCOUNTING_TEMPLATE_NAME,
-- Changes ends
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
              l_tab_rec.UPGRADE_STATUS_FLAG;

    x_no_data_found := tab_pk_csr%NOTFOUND;
    CLOSE tab_pk_csr;
    RETURN(l_tab_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tab_rec                      IN tab_rec_type
  ) RETURN tab_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tab_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRNS_ACC_DSTRS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tabv_rec                     IN tabv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tabv_rec_type IS
    l_tabv_rec                     tabv_rec_type;

    CURSOR tabv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CURRENCY_CONVERSION_TYPE,
            SET_OF_BOOKS_ID,
            CR_DR_FLAG,
            CODE_COMBINATION_ID,
            ORG_ID,
            CURRENCY_CODE,
            AE_LINE_TYPE,
            TEMPLATE_ID,
            SOURCE_ID,
            SOURCE_TABLE,
            OBJECT_VERSION_NUMBER,
            AMOUNT,
            ACCOUNTED_AMOUNT,
            GL_DATE,
            PERCENTAGE,
            COMMENTS,
            POST_REQUEST_ID,
            CURRENCY_CONVERSION_DATE,
            CURRENCY_CONVERSION_RATE,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
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
            AET_ID,
            POSTED_YN,
            AE_CREATION_ERROR,
            GL_REVERSAL_FLAG,
            REVERSE_EVENT_FLAG,
            DRAFT_YN,
            DRAFT_VERSION,
            ORIGINAL_DIST_ID,
            ACCOUNTING_EVENT_ID,
            POST_TO_GL,
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
            ACCOUNTING_TEMPLATE_NAME,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
            UPGRADE_STATUS_FLAG
      FROM OKL_TRNS_ACC_DSTRS
     WHERE OKL_TRNS_ACC_DSTRS.id = p_id;
    l_tabv_pk                       tabv_pk_csr%ROWTYPE;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN tabv_pk_csr (p_tabv_rec.id);
    FETCH tabv_pk_csr INTO
              l_tabv_rec.ID,
              l_tabv_rec.CURRENCY_CONVERSION_TYPE,
              l_tabv_rec.SET_OF_BOOKS_ID,
              l_tabv_rec.CR_DR_FLAG,
              l_tabv_rec.CODE_COMBINATION_ID,
              l_tabv_rec.ORG_ID,
              l_tabv_rec.CURRENCY_CODE,
              l_tabv_rec.AE_LINE_TYPE,
              l_tabv_rec.TEMPLATE_ID,
              l_tabv_rec.SOURCE_ID,
              l_tabv_rec.SOURCE_TABLE,
              l_tabv_rec.OBJECT_VERSION_NUMBER,
              l_tabv_rec.AMOUNT,
              l_tabv_rec.ACCOUNTED_AMOUNT,
              l_tabv_rec.GL_DATE,
              l_tabv_rec.PERCENTAGE,
              l_tabv_rec.COMMENTS,
              l_tabv_rec.POST_REQUEST_ID,
              l_tabv_rec.CURRENCY_CONVERSION_DATE,
              l_tabv_rec.CURRENCY_CONVERSION_RATE,
              l_tabv_rec.REQUEST_ID,
              l_tabv_rec.PROGRAM_APPLICATION_ID,
              l_tabv_rec.PROGRAM_ID,
              l_tabv_rec.PROGRAM_UPDATE_DATE,
              l_tabv_rec.ATTRIBUTE_CATEGORY,
              l_tabv_rec.ATTRIBUTE1,
              l_tabv_rec.ATTRIBUTE2,
              l_tabv_rec.ATTRIBUTE3,
              l_tabv_rec.ATTRIBUTE4,
              l_tabv_rec.ATTRIBUTE5,
              l_tabv_rec.ATTRIBUTE6,
              l_tabv_rec.ATTRIBUTE7,
              l_tabv_rec.ATTRIBUTE8,
              l_tabv_rec.ATTRIBUTE9,
              l_tabv_rec.ATTRIBUTE10,
              l_tabv_rec.ATTRIBUTE11,
              l_tabv_rec.ATTRIBUTE12,
              l_tabv_rec.ATTRIBUTE13,
              l_tabv_rec.ATTRIBUTE14,
              l_tabv_rec.ATTRIBUTE15,
              l_tabv_rec.CREATED_BY,
              l_tabv_rec.CREATION_DATE,
              l_tabv_rec.LAST_UPDATED_BY,
              l_tabv_rec.LAST_UPDATE_DATE,
              l_tabv_rec.LAST_UPDATE_LOGIN,
              l_tabv_rec.AET_ID,
              l_tabv_rec.POSTED_YN,
              l_tabv_rec.AE_CREATION_ERROR,
              l_tabv_rec.GL_REVERSAL_FLAG,
              l_tabv_rec.REVERSE_EVENT_FLAG,
              l_tabv_rec.DRAFT_YN,
              l_tabv_rec.DRAFT_VERSION,
              l_tabv_rec.ORIGINAL_DIST_ID,
              l_tabv_rec.ACCOUNTING_EVENT_ID,
              l_tabv_rec.POST_TO_GL,
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
              l_tabv_rec.ACCOUNTING_TEMPLATE_NAME,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
              l_tabv_rec.UPGRADE_STATUS_FLAG;

    x_no_data_found := tabv_pk_csr%NOTFOUND;
    CLOSE tabv_pk_csr;
    RETURN(l_tabv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tabv_rec                     IN tabv_rec_type
  ) RETURN tabv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tabv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRNS_ACC_DSTRS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_tabv_rec	IN tabv_rec_type
  ) RETURN tabv_rec_type IS
    l_tabv_rec	tabv_rec_type := p_tabv_rec;
  BEGIN
    IF (l_tabv_rec.id = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.id := NULL;
    END IF;
    IF (l_tabv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.object_version_number := NULL;
    END IF;
    IF (l_tabv_rec.template_id = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.template_id := NULL;
    END IF;
    IF (l_tabv_rec.cr_dr_flag = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.cr_dr_flag := NULL;
    END IF;
    IF (l_tabv_rec.ae_line_type = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.ae_line_type := NULL;
    END IF;
-- Line changed by Kanti on 07.05.2001. MISS_CHAR replaced by MISS_NUM.
    IF (l_tabv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.org_id := NULL;
    END IF;
    IF (l_tabv_rec.set_of_books_id = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.set_of_books_id := NULL;
    END IF;
    IF (l_tabv_rec.code_combination_id = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.code_combination_id := NULL;
    END IF;
-- Changes End here
    IF (l_tabv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.currency_code := NULL;
    END IF;
    IF (l_tabv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_tabv_rec.source_id = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.source_id := NULL;
    END IF;
    IF (l_tabv_rec.source_table = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.source_table := NULL;
    END IF;
    IF (l_tabv_rec.amount = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.amount := NULL;
    END IF;
    IF (l_tabv_rec.accounted_amount = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.accounted_amount := NULL;
    END IF;
    IF (l_tabv_rec.gl_date = OKC_API.G_MISS_DATE) THEN
      l_tabv_rec.gl_date := NULL;
    END IF;
    IF (l_tabv_rec.percentage = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.percentage := NULL;
    END IF;
    IF (l_tabv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.comments := NULL;
    END IF;
    IF (l_tabv_rec.post_request_id = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.post_request_id := NULL;
    END IF;
    IF (l_tabv_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
      l_tabv_rec.currency_conversion_date := NULL;
    END IF;
    IF (l_tabv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.currency_conversion_rate := NULL;
    END IF;

-- The following lines have been changed by Kanti on 07.05.2001. The comparison for all
-- the attribute fields was being done by G_MISS_NUM and not by G_MISS_CHAR. This has been
-- corrected.

    IF (l_tabv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute_category := NULL;
    END IF;
    IF (l_tabv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute1 := NULL;
    END IF;
    IF (l_tabv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute2 := NULL;
    END IF;
    IF (l_tabv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute3 := NULL;
    END IF;
    IF (l_tabv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute4 := NULL;
    END IF;
    IF (l_tabv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute5 := NULL;
    END IF;
    IF (l_tabv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute6 := NULL;
    END IF;
    IF (l_tabv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute7 := NULL;
    END IF;
    IF (l_tabv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute8 := NULL;
    END IF;
    IF (l_tabv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute9 := NULL;
    END IF;
    IF (l_tabv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute10 := NULL;
    END IF;
    IF (l_tabv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute11 := NULL;
    END IF;
    IF (l_tabv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute12 := NULL;
    END IF;
    IF (l_tabv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute13 := NULL;
    END IF;
    IF (l_tabv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute14 := NULL;
    END IF;
    IF (l_tabv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.attribute15 := NULL;
    END IF;
-- Changes End here

    IF (l_tabv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.request_id := NULL;
    END IF;
    IF (l_tabv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.program_application_id := NULL;
    END IF;
    IF (l_tabv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.program_id := NULL;
    END IF;
    IF (l_tabv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_tabv_rec.program_update_date := NULL;
    END IF;
    IF (l_tabv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.created_by := NULL;
    END IF;
    IF (l_tabv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_tabv_rec.creation_date := NULL;
    END IF;
    IF (l_tabv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.last_updated_by := NULL;
    END IF;
    IF (l_tabv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_tabv_rec.last_update_date := NULL;
    END IF;
    IF (l_tabv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.last_update_login := NULL;
    END IF;
-- The following two fields have been added by Kanti Jinger on 07/12/2001
    IF (l_tabv_rec.AET_ID = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.AET_ID := NULL;
    END IF;
    IF (l_tabv_rec.posted_yn  = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.posted_yn  := NULL;
    END IF;
    IF (l_tabv_rec.ae_creation_error  = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.ae_creation_error  := NULL;
    END IF;
    IF (l_tabv_rec.gl_reversal_flag  = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.gl_reversal_flag  := NULL;
    END IF;
    IF (l_tabv_rec.reverse_event_flag  = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.reverse_event_flag  := NULL;
    END IF;
    IF (l_tabv_rec.draft_yn  = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.draft_yn  := NULL;
    END IF;
    IF (l_tabv_rec.draft_version  = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.draft_yn  := NULL;
    END IF;
    IF (l_tabv_rec.original_dist_id  = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.original_dist_id  := NULL;
    END IF;
    IF (l_tabv_rec.accounting_Event_id  = OKC_API.G_MISS_NUM) THEN
      l_tabv_rec.accounting_Event_id  := NULL;
    END IF;
    IF (l_tabv_rec.post_to_gl  = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.post_to_gl  := NULL;
    END IF;
-- Changes ends
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
    IF (l_tabv_rec.accounting_template_name  = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.accounting_template_name  := NULL;
    END IF;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    IF (l_tabv_rec.UPGRADE_STATUS_FLAG  = OKC_API.G_MISS_CHAR) THEN
      l_tabv_rec.UPGRADE_STATUS_FLAG  := NULL;
    END IF;
    RETURN(l_tabv_rec);
  END null_out_defaults;

  /*****************************************************
 05-10-01 : spalod : start - commented out tapi code


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKL_TRNS_ACC_DSTRS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_tabv_rec IN  tabv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_tabv_rec.id = OKC_API.G_MISS_NUM OR
       p_tabv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tabv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_tabv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tabv_rec.template_id = OKC_API.G_MISS_NUM OR
          p_tabv_rec.template_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'template_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tabv_rec.cr_dr_flag = OKC_API.G_MISS_CHAR OR
          p_tabv_rec.cr_dr_flag IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cr_dr_flag');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tabv_rec.ae_line_type = OKC_API.G_MISS_CHAR OR
          p_tabv_rec.ae_line_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ae_line_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
-- Changed by Kanti on 07.05.2001. Changed from G_MISS_CHAR to G_MISS_NUM
    ELSIF p_tabv_rec.org_id = OKC_API.G_MISS_NUM OR
-- changes end here
          p_tabv_rec.org_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'org_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
-- Changed by Kanti on 07.05.2001. Changed from G_MISS_CHAR to G_MISS_NUM
    ELSIF p_tabv_rec.set_of_books_id = OKC_API.G_MISS_NUM OR
-- changes end here
          p_tabv_rec.set_of_books_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'set_of_books_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
-- Changed by Kanti on 07.05.2001. Changed from G_MISS_CHAR to G_MISS_NUM
    ELSIF p_tabv_rec.code_combination_id = OKC_API.G_MISS_NUM OR
-- changes end here
          p_tabv_rec.code_combination_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'code_combination_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tabv_rec.currency_code = OKC_API.G_MISS_CHAR OR
          p_tabv_rec.currency_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'currency_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tabv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR OR
          p_tabv_rec.currency_conversion_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'currency_conversion_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tabv_rec.source_id = OKC_API.G_MISS_NUM OR
          p_tabv_rec.source_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'source_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tabv_rec.source_table = OKC_API.G_MISS_CHAR OR
          p_tabv_rec.source_table IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'source_table');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

 05-10-01 : spalod : end - commented out tapi code
****************************************************/

-- 05-10-01 : spalod : start - procedures for validateing attributes

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Id (x_return_status OUT NOCOPY  VARCHAR2
				,p_tabv_rec      IN   tabv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_tabv_rec.id IS NULL) OR
       (p_tabv_rec.id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'id');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(x_return_status OUT NOCOPY  VARCHAR2
					  ,p_tabv_rec      IN   tabv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_tabv_rec.object_version_number IS NULL) OR
       (p_tabv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'object_version_number');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_curr_conv_type
  ---------------------------------------------------------------------------
    PROCEDURE validate_curr_conv_type(
      x_return_status OUT NOCOPY VARCHAR2,
      p_tabv_rec IN  tabv_rec_type
    ) IS

    l_dummy			      VARCHAR2(1) := OKC_API.G_FALSE;

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- Added by Santonyr on 26-Nov-2002.
-- The conversion type 'USER' is also allowed.

    IF (p_tabv_rec.currency_conversion_type IS NOT NULL) AND
    (p_tabv_rec.currency_conversion_type <> OKC_API.G_MISS_CHAR)AND
    (UPPER(p_tabv_rec.currency_conversion_type) <> 'USER') THEN
        l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_CURRENCY_CON_TYPE
                            (p_tabv_rec.currency_conversion_type);
        IF (l_dummy = OKC_API.G_FALSE) THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'Currency Conversion Type');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

   END IF;


      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_curr_conv_type;

/* Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 --start
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_cr_dr_flag
  ---------------------------------------------------------------------------
    PROCEDURE validate_cr_dr_flag(
      x_return_status OUT NOCOPY VARCHAR2,
      p_tabv_rec IN  tabv_rec_type
    ) IS

    l_dummy			      VARCHAR2(1) := OKC_API.G_FALSE;
    l_app_id  NUMBER := 101;
    l_view_app_id NUMBER := 101;

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_tabv_rec.cr_dr_flag IS NULL) OR (p_tabv_rec.cr_dr_flag = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'cr_dr_flag');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                        (p_lookup_type => 'CR_DR',
                         p_lookup_code => p_tabv_rec.cr_dr_flag,
                         p_app_id      => l_app_id,
                         p_view_app_id => l_view_app_id);

    IF (l_dummy  = okc_api.G_FALSE) THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'cr_dr_flag');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_cr_dr_flag;

  Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 -- end */
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Amount
  ---------------------------------------------------------------------------
    PROCEDURE Validate_Amount(
      x_return_status OUT NOCOPY VARCHAR2,
      p_tabv_rec IN  tabv_rec_type
    ) IS

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_tabv_rec.amount IS NULL) OR (p_tabv_rec.amount = OKC_API.G_MISS_NUM) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'Amount');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Amount;

/* Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 --start
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_ccid
  ---------------------------------------------------------------------------
    PROCEDURE validate_ccid(
      x_return_status OUT NOCOPY VARCHAR2,
      p_tabv_rec IN  tabv_rec_type
    ) IS

    l_dummy			      VARCHAR2(1) := okl_api.g_false;

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_tabv_rec.code_combination_id IS NULL) OR (p_tabv_rec.code_combination_id = OKC_API.G_MISS_NUM) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'ACCOUNT');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;
 Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 -- end */
/*  Commented by Kanti. We want a not null validation but not the CCID validation from
    GL Code combination table for the time being.

    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_tabv_rec.code_combination_id);

    IF (l_dummy = okc_api.g_false) THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'CODE_COMBINATION_ID');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

*/
/* Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 -- start
    EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_ccid;
 Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 -- end */


	  ---------------------------------------------------------------------------
  -- PROCEDURE validate_curr_code
  ---------------------------------------------------------------------------
    PROCEDURE validate_curr_code(
      x_return_status OUT NOCOPY VARCHAR2,
      p_tabv_rec IN  tabv_rec_type
    ) IS
    l_dummy	      VARCHAR2(1)	:= OKC_API.G_FALSE;

    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_tabv_rec.currency_code IS NULL) OR (p_tabv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'CURRENCY_CODE');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_CURRENCY_CODE (p_tabv_rec.currency_code);

    IF (l_dummy = okl_api.g_false) THEN
	    Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'CURRENCY_CODE');

	    x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_curr_code;

/* Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 --start
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_ae_line_type
  ---------------------------------------------------------------------------
    PROCEDURE validate_ae_line_type(
      x_return_status OUT NOCOPY VARCHAR2,
      p_tabv_rec IN  tabv_rec_type
    ) IS
    l_dummy			      VARCHAR2(1) ;

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_tabv_rec.ae_line_type IS NULL) OR (p_tabv_rec.ae_line_type = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'AE_LINE_TYPE');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                   (p_lookup_type => 'OKL_ACCOUNTING_LINE_TYPE',
                    p_lookup_code => p_tabv_rec.ae_line_type);

    IF l_dummy = okl_api.g_false THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'ae_line_type');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_ae_line_type;
 Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 -- end */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_template_id
  ---------------------------------------------------------------------------
    PROCEDURE validate_template_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_tabv_rec IN  tabv_rec_type
    ) IS
    l_dummy			      VARCHAR2(1) ;

      CURSOR tmpl_csr(v_template_id IN NUMBER)
	  IS
	  SELECT '1'
	  FROM OKL_AE_TEMPLATES
	  WHERE id = v_template_id;

	   l_fetch_flag VARCHAR2(1);

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_tabv_rec.template_id IS NOT NULL) AND (p_tabv_rec.template_id <> OKC_API.G_MISS_NUM) THEN
	  OPEN tmpl_csr(p_tabv_rec.template_id);
	  FETCH tmpl_csr INTO l_dummy;

          IF (tmpl_csr%NOTFOUND) THEN

		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'TEMPLATE_ID');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
                CLOSE tmpl_csr;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;

         CLOSE tmpl_csr;

    END IF;


      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_template_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_source_id_tbl
  ---------------------------------------------------------------------------
    PROCEDURE validate_source_id_tbl(
      x_return_status OUT NOCOPY VARCHAR2,
      p_tabv_rec IN  tabv_rec_type
    ) IS

    l_dummy			      VARCHAR2(1) := OKC_API.G_FALSE;

    BEGIN

       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF (p_tabv_rec.source_id IS NULL) OR (p_tabv_rec.source_id = OKC_API.G_MISS_NUM) THEN
           OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                               p_msg_name => g_required_value,
                               p_token1   => g_col_name_token,
                               p_token1_value => 'SOURCE_ID');

           x_return_status := OKC_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

       IF (p_tabv_rec.source_table IS NULL) OR (p_tabv_rec.source_table = OKC_API.G_MISS_CHAR) THEN
           OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                               p_msg_name => g_required_value,
                               p_token1   => g_col_name_token,
                               p_token1_value => 'SOURCE_TABLE');

           x_return_status := OKC_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_SOURCE_ID_TABLE
                                 (p_source_id => p_tabv_rec.source_id,
                                  p_source_table => p_tabv_rec.source_table);

       IF (l_dummy = OKC_API.G_FALSE) THEN
	   Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => g_invalid_value,
                               p_token1       => g_col_name_token,
                               p_token1_value => 'source_id_src_table');
           x_return_status := Okc_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_source_id_tbl;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_AET_ID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_AET_ID
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_AET_ID (x_return_status OUT NOCOPY  VARCHAR2
			    ,p_tabv_rec      IN   tabv_rec_type )
  IS

  l_dummy         VARCHAR2(1)  := Okc_Api.G_FALSE;

  CURSOR aet_csr(v_id NUMBER) IS
  SELECT '1'
  FROM OKL_ACCOUNTING_EVENTS
  WHERE accounting_event_id  = v_id;


  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tabv_rec.AET_ID IS NOT NULL) AND (p_tabv_rec.AET_ID <> OKC_API.G_MISS_NUM) THEN
       OPEN aet_csr(p_tabv_rec.aet_id);
       FETCH aet_csr INTO l_dummy;
       IF (aet_csr%NOTFOUND) THEN
           Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'AET_ID');
           x_return_status    := Okc_Api.G_RET_STS_ERROR;
           CLOSE aet_csr;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE aet_csr;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_AET_Id;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_POSTED_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_POSTED_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_posted_YN (x_return_status OUT NOCOPY  VARCHAR2
				,p_tabv_rec      IN   tabv_rec_type )
  IS

  l_dummy         VARCHAR2(1)  := Okc_Api.G_FALSE;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tabv_rec.posted_yn IS NOT NULL) AND (p_tabv_rec.posted_yn <> OKC_API.G_MISS_CHAR) THEN
        l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                           (p_lookup_type => 'OKL_ACC_DIST_POSTED',
                            p_lookup_code => p_tabv_rec.posted_yn);

        IF (l_dummy = OKC_API.G_FALSE) THEN
           Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'POSTED_YN');
           x_return_status    := Okc_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_POSTED_YN;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_gl_reversal_flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_GL_REVERSAL_FLAG
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_GL_REVERSAL_FLAG (x_return_status OUT NOCOPY  VARCHAR2
				      ,p_tabv_rec      IN   tabv_rec_type )
  IS

  l_dummy         VARCHAR2(1)  := Okc_Api.G_FALSE;
  l_app_id        NUMBER := 0;
  l_view_app_id   NUMBER := 0;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tabv_rec.GL_REVERSAL_FLAG IS NOT NULL) AND (p_tabv_rec.GL_REVERSAL_FLAG <> OKC_API.G_MISS_CHAR) THEN
        l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                           (p_lookup_type => 'YES_NO',
                            p_lookup_code => p_tabv_rec.gl_reversal_flag,
                            p_app_id      => l_app_id,
                            p_view_app_id => l_view_app_id);

        IF (l_dummy = OKC_API.G_FALSE) THEN
           Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'GL_REVERSAL_FLAG');
           x_return_status    := Okc_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_GL_REVERSAL_FLAG;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_post_to_gl
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_post_to_gl
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_POST_TO_GL (x_return_status OUT NOCOPY  VARCHAR2
			        ,p_tabv_rec      IN   tabv_rec_type )
  IS

  l_dummy         VARCHAR2(1)  := Okc_Api.G_FALSE;
  l_app_id        NUMBER := 0;
  l_view_app_id   NUMBER := 0;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tabv_rec.POST_TO_GL IS NOT NULL) AND (p_tabv_rec.POST_TO_GL <> OKC_API.G_MISS_CHAR) THEN
        l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                           (p_lookup_type => 'YES_NO',
                            p_lookup_code => p_tabv_rec.POST_TO_GL,
                            p_app_id      => l_app_id,
                            p_view_app_id => l_view_app_id);

        IF (l_dummy = OKC_API.G_FALSE) THEN
           Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'POST_TO_GL');
           x_return_status    := Okc_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

  END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_POST_TO_GL;

  ---------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_GL_DATE
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_GL_DATE
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE VALIDATE_GL_DATE(x_return_status OUT NOCOPY  VARCHAR2
		            ,p_tabv_rec      IN   tabv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_tabv_rec.gl_date IS NULL) OR
       (p_tabv_rec.gl_date = Okc_Api.G_MISS_DATE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'GL_DATE');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END VALIDATE_GL_DATE;

-- Added by nikshah for SLA project (Bug 5707866) 17-Apr-2007
---------------------------------------------------------------------------
  -- PROCEDURE Validate_Upgrade_Status_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Upgrade_Status_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Upgrade_Status_Flag (x_return_status OUT NOCOPY VARCHAR2, p_tabv_rec IN  tabv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tabv_rec.UPGRADE_STATUS_FLAG IS NOT NULL) AND
       (p_tabv_rec.UPGRADE_STATUS_FLAG <> Okc_Api.G_MISS_CHAR) THEN
       -- check in fnd_lookups for validity
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_YES_NO',
                               p_lookup_code => p_tabv_rec.UPGRADE_STATUS_FLAG);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'UPGRADE_STATUS_FLAG');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;
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

  END Validate_Upgrade_Status_Flag;


  ---------------------------------------------------------------------------
  -- Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_ACC_GEN_RULES_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_tabv_rec IN  tabv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

       Validate_Id (x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

  Validate_Object_Version_Number(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;



    validate_curr_conv_type(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;


   /* Commented as part of SLA Uptake Bug#5707866 --start
     validate_cr_dr_flag(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
      Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 -- end */



-- The following validation removed by Kanti. This was done because we are already
-- doing validation of ccid during accounting process. Further, distibution will be
-- called by transaction and we do not want transaction to stop just because one of
-- the ccid has become invalid in the template setup. This error will anyway be caught
-- in the accounting process.

-- Comment removed by Kanti 05/22/2002.

    /* Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 --start
    validate_ccid(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
    Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 -- end */

    validate_curr_code(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

/* Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 --start
    validate_ae_line_type(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
 Commented as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 -- end */
-- Added by Saravanan

    Validate_Amount(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

    validate_template_id(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;


    validate_source_id_Tbl(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

    validate_aet_id(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

    validate_posted_yn(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

    validate_gl_reversal_flag(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;


    validate_post_to_gl(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

    VALIDATE_GL_DATE(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

-- Added by nikshah for SLA project (Bug 5707866) 17-Apr-2007
    Validate_Upgrade_Status_Flag(x_return_status, p_tabv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;


    RETURN(l_return_status);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- just come out with return status
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

-- 05-10-01 : spalod : end - procedures for validateing attributes

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKL_TRNS_ACC_DSTRS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_tabv_rec IN tabv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN tabv_rec_type,
    p_to	OUT NOCOPY tab_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.cr_dr_flag := p_from.cr_dr_flag;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.org_id := p_from.org_id;
    p_to.currency_code := p_from.currency_code;
    p_to.ae_line_type := p_from.ae_line_type;
    p_to.template_id := p_from.template_id;
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    p_to.object_version_number := p_from.object_version_number;
    p_to.amount := p_from.amount;
    p_to.accounted_amount := p_from.accounted_amount;
    p_to.gl_date := p_from.gl_date;
    p_to.percentage := p_from.percentage;
    p_to.comments := p_from.comments;
    p_to.post_request_id := p_from.post_request_id;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
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
-- The following two fields have been added by Kanti Jinger on 07/12/2001
    p_to.aet_id := p_from.aet_id;
    p_to.posted_yn := p_from.posted_yn;
    p_to.ae_creation_error := p_from.ae_creation_error;
    p_to.gl_reversal_flag := p_from.gl_reversal_flag;
    p_to.reverse_event_flag := p_from.reverse_event_flag;
    p_to.draft_yn := p_from.draft_yn;
    p_to.draft_version := p_from.draft_version;
    p_to.original_dist_id := p_from.original_dist_id;
    p_to.accounting_Event_id := p_from.accounting_Event_id;
    p_to.post_to_gl := p_from.post_to_gl;
-- Changes ends
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
    p_to.accounting_template_name := p_from.accounting_template_name;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    p_to.UPGRADE_STATUS_FLAG := p_from.UPGRADE_STATUS_FLAG;
  END migrate;
  PROCEDURE migrate (
    p_from	IN tab_rec_type,
    p_to	OUT NOCOPY tabv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.cr_dr_flag := p_from.cr_dr_flag;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.org_id := p_from.org_id;
    p_to.currency_code := p_from.currency_code;
    p_to.ae_line_type := p_from.ae_line_type;
    p_to.template_id := p_from.template_id;
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    p_to.object_version_number := p_from.object_version_number;
    p_to.amount := p_from.amount;
    p_to.accounted_amount := p_from.accounted_amount;
    p_to.gl_date := p_from.gl_date;
    p_to.percentage := p_from.percentage;
    p_to.comments := p_from.comments;
    p_to.post_request_id := p_from.post_request_id;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
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
-- The following two fields have been added by Kanti Jinger on 07/12/2001
    p_to.aet_id := p_from.aet_id;
    p_to.posted_yn := p_from.posted_yn;
    p_to.ae_Creation_error := p_from.ae_Creation_error;
    p_to.gl_reversal_flag := p_from.gl_reversal_flag;
    p_to.reverse_event_flag := p_from.reverse_event_flag;
    p_to.draft_yn := p_from.draft_yn;
    p_to.draft_version := p_from.draft_version;
    p_to.original_dist_id := p_from.original_dist_id;
    p_to.accounting_event_id := p_from.accounting_event_id;
    p_to.post_to_gl := p_from.post_to_gl;

-- Changes ends
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
    p_to.accounting_template_name := p_from.accounting_template_name;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    p_to.UPGRADE_STATUS_FLAG := p_from.UPGRADE_STATUS_FLAG;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for:OKL_TRNS_ACC_DSTRS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN tabv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tabv_rec                     tabv_rec_type := p_tabv_rec;
    l_tab_rec                      tab_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_tabv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_tabv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:TABV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN tabv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tabv_tbl.COUNT > 0) THEN
      i := p_tabv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tabv_rec                     => p_tabv_tbl(i));

        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_tabv_tbl.LAST);
        i := p_tabv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------
  -- insert_row for:OKL_TRNS_ACC_DSTRS --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tab_rec                      IN tab_rec_type,
    x_tab_rec                      OUT NOCOPY tab_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DSTRS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tab_rec                      tab_rec_type := p_tab_rec;
    l_def_tab_rec                  tab_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKL_TRNS_ACC_DSTRS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_tab_rec IN  tab_rec_type,
      x_tab_rec OUT NOCOPY tab_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tab_rec := p_tab_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tab_rec,                         -- IN
      l_tab_rec);                    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TRNS_ACC_DSTRS(
        id,
        currency_conversion_type,
        set_of_books_id,
        cr_dr_flag,
        code_combination_id,
        org_id,
        currency_code,
        ae_line_type,
        template_id,
        source_id,
        source_table,
        object_version_number,
        amount,
        accounted_amount,
        gl_date,
        percentage,
        comments,
        post_request_id,
        currency_conversion_date,
        currency_conversion_rate,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
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
-- The following two fields have been added by Kanti Jinger on 07/12/2001
        aet_id,
        posted_yn,
        ae_creation_error,
        gl_reversal_flag,
        reverse_Event_flag,
        draft_yn,
        draft_version,
        original_dist_id,
        accounting_event_id,
        post_to_gl,
-- Changes ends
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
        accounting_template_name,
-- Added by nikshah for SLA project (Bug 5707866) 13-Apr-2007
        UPGRADE_STATUS_FLAG)

      VALUES (
        l_tab_rec.id,
        l_tab_rec.currency_conversion_type,
        l_tab_rec.set_of_books_id,
        l_tab_rec.cr_dr_flag,
        l_tab_rec.code_combination_id,
        l_tab_rec.org_id,
        l_tab_rec.currency_code,
        l_tab_rec.ae_line_type,
        l_tab_rec.template_id,
        l_tab_rec.source_id,
        l_tab_rec.source_table,
        l_tab_rec.object_version_number,
        l_tab_rec.amount,
        l_tab_rec.accounted_amount,
        l_tab_rec.gl_date,
        l_tab_rec.percentage,
        l_tab_rec.comments,
        l_tab_rec.post_request_id,
        l_tab_rec.currency_conversion_date,
        l_tab_rec.currency_conversion_rate,
        l_tab_rec.request_id,
        l_tab_rec.program_application_id,
        l_tab_rec.program_id,
        l_tab_rec.program_update_date,
        l_tab_rec.attribute_category,
        l_tab_rec.attribute1,
        l_tab_rec.attribute2,
        l_tab_rec.attribute3,
        l_tab_rec.attribute4,
        l_tab_rec.attribute5,
        l_tab_rec.attribute6,
        l_tab_rec.attribute7,
        l_tab_rec.attribute8,
        l_tab_rec.attribute9,
        l_tab_rec.attribute10,
        l_tab_rec.attribute11,
        l_tab_rec.attribute12,
        l_tab_rec.attribute13,
        l_tab_rec.attribute14,
        l_tab_rec.attribute15,
        l_tab_rec.created_by,
        l_tab_rec.creation_date,
        l_tab_rec.last_updated_by,
        l_tab_rec.last_update_date,
        l_tab_rec.last_update_login,
-- The following two fields have been added by Kanti Jinger on 07/12/2001
        l_tab_rec.aet_id,
        l_tab_rec.posted_yn,
        l_tab_rec.ae_creation_error,
        l_tab_rec.gl_reversal_flag,
        l_tab_rec.reverse_Event_flag,
        l_tab_rec.draft_yn,
        l_tab_rec.draft_version,
        l_tab_rec.original_dist_id,
        l_tab_rec.accounting_event_id,
        l_tab_rec.post_to_gl,
-- Changes ends
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
	l_tab_rec.accounting_template_name,
-- Added by nikshah for SLA project (Bug 5707866) 13-Apr-2007
        l_tab_rec.UPGRADE_STATUS_FLAG);

    -- Set OUT values
    x_tab_rec := l_tab_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_TRNS_ACC_DSTRS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN tabv_rec_type,
    x_tabv_rec                     OUT NOCOPY tabv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tabv_rec                     tabv_rec_type;
    l_def_tabv_rec                 tabv_rec_type;
    l_tab_rec                      tab_rec_type;
    lx_tab_rec                     tab_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tabv_rec	IN tabv_rec_type
    ) RETURN tabv_rec_type IS
      l_tabv_rec	tabv_rec_type := p_tabv_rec;
    BEGIN
      l_tabv_rec.CREATION_DATE := SYSDATE;
      l_tabv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_tabv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tabv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tabv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tabv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TRNS_ACC_DSTRS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tabv_rec IN  tabv_rec_type,
      x_tabv_rec OUT NOCOPY tabv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

-- 05-10-01 - spalod  - start - get and set org id and set of book id, concurrent program fields

	  l_request_id NUMBER := Fnd_Global.CONC_REQUEST_ID;
	  l_prog_app_id NUMBER := Fnd_Global.PROG_APPL_ID;
	  l_program_id NUMBER := Fnd_Global.CONC_PROGRAM_ID;

-- 05-10-01 - spalod  - end - get and set org id and set of book id, concurrent program fields

    BEGIN

      x_tabv_rec := p_tabv_rec;
      x_tabv_rec.OBJECT_VERSION_NUMBER := 1;

-- 05-10-01 - spalod  - start - get and set org id and set of book id, concurrent program fields

      SELECT DECODE(l_request_id, -1, NULL, l_request_id),
      DECODE(l_prog_app_id, -1, NULL, l_prog_app_id),
      DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
      DECODE(l_request_id, -1, NULL, SYSDATE)
     INTO  x_tabv_rec.REQUEST_ID
          ,x_tabv_rec.PROGRAM_APPLICATION_ID
          ,x_tabv_rec.PROGRAM_ID
          ,x_tabv_rec.PROGRAM_UPDATE_DATE
     FROM DUAL;

        x_tabv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();

		-- MG uptake, if sob is not sent in take primary ledger.
		if x_tabv_rec.set_of_books_id is null then
	      x_tabv_rec.set_of_books_id := okl_accounting_util.get_set_of_books_id;
        end if;

-- 05-10-01 - spalod  - end - get and set org id and set of book id, concurrent program fields

--    The following fields are not being used anywhere. Therefore, we are setting them
--    to some junk values. Ideally, these fields should be dropped.

      x_tabv_rec.draft_yn      := 'N';
      x_tabv_rec.draft_version :=  0;

------Ends

-- Added by nikshah for SLA project (Bug 5707866) 17-Apr-2007
      x_tabv_rec.UPGRADE_STATUS_FLAG := 'N';
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_tabv_rec := null_out_defaults(p_tabv_rec);
    -- Set primary key value
    l_tabv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_tabv_rec,                        -- IN
      l_def_tabv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tabv_rec := fill_who_columns(l_def_tabv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tabv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tabv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tabv_rec, l_tab_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tab_rec,
      lx_tab_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tab_rec, l_def_tabv_rec);
    -- Set OUT values
    x_tabv_rec := l_def_tabv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:TABV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN tabv_tbl_type,
    x_tabv_tbl                     OUT NOCOPY tabv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_Status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tabv_tbl.COUNT > 0) THEN
      i := p_tabv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tabv_rec                     => p_tabv_tbl(i),
          x_tabv_rec                     => x_tabv_tbl(i));

         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                l_overall_status := x_return_status;
            END IF;
          END IF;

        EXIT WHEN (i = p_tabv_tbl.LAST);
        i := p_tabv_tbl.NEXT(i);
      END LOOP;
    END IF;
        x_return_status := l_overall_Status;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- lock_row for:OKL_TRNS_ACC_DSTRS --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tab_rec                      IN tab_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tab_rec IN tab_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRNS_ACC_DSTRS
     WHERE ID = p_tab_rec.id
       AND OBJECT_VERSION_NUMBER = p_tab_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tab_rec IN tab_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRNS_ACC_DSTRS
    WHERE ID = p_tab_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DSTRS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TRNS_ACC_DSTRS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TRNS_ACC_DSTRS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_tab_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_tab_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tab_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tab_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_TRNS_ACC_DSTRS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN tabv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tab_rec                      tab_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_tabv_rec, l_tab_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tab_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:TABV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN tabv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tabv_tbl.COUNT > 0) THEN
      i := p_tabv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tabv_rec                     => p_tabv_tbl(i));
   IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_tabv_tbl.LAST);
        i := p_tabv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------
  -- update_row for:OKL_TRNS_ACC_DSTRS --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tab_rec                      IN tab_rec_type,
    x_tab_rec                      OUT NOCOPY tab_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DSTRS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tab_rec                      tab_rec_type := p_tab_rec;
    l_def_tab_rec                  tab_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tab_rec	IN tab_rec_type,
      x_tab_rec	OUT NOCOPY tab_rec_type
    ) RETURN VARCHAR2 IS
      l_tab_rec                      tab_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tab_rec := p_tab_rec;
      -- Get current database values
      l_tab_rec := get_rec(p_tab_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tab_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.id := l_tab_rec.id;
      END IF;
      IF (x_tab_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.currency_conversion_type := l_tab_rec.currency_conversion_type;
      END IF;
-- Line changed by Kanti on 07.05.2001. MISS_CHAR replaced by MISS_NUM.
      IF (x_tab_rec.set_of_books_id = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.set_of_books_id := l_tab_rec.set_of_books_id;
      END IF;
      IF (x_tab_rec.cr_dr_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.cr_dr_flag := l_tab_rec.cr_dr_flag;
      END IF;
-- Line changed by Kanti on 07.05.2001. MISS_CHAR replaced by MISS_NUM.
      IF (x_tab_rec.code_combination_id = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.code_combination_id := l_tab_rec.code_combination_id;
      END IF;
-- Line changed by Kanti on 07.05.2001. MISS_CHAR replaced by MISS_NUM.
      IF (x_tab_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.org_id := l_tab_rec.org_id;
      END IF;
      IF (x_tab_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.currency_code := l_tab_rec.currency_code;
      END IF;
      IF (x_tab_rec.ae_line_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.ae_line_type := l_tab_rec.ae_line_type;
      END IF;
      IF (x_tab_rec.template_id = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.template_id := l_tab_rec.template_id;
      END IF;
      IF (x_tab_rec.source_id = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.source_id := l_tab_rec.source_id;
      END IF;
      IF (x_tab_rec.source_table = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.source_table := l_tab_rec.source_table;
      END IF;
      IF (x_tab_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.object_version_number := l_tab_rec.object_version_number;
      END IF;
      IF (x_tab_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.amount := l_tab_rec.amount;
      END IF;
      IF (x_tab_rec.accounted_amount = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.accounted_amount := l_tab_rec.accounted_amount;
      END IF;
      IF (x_tab_rec.gl_date = OKC_API.G_MISS_DATE)
      THEN
        x_tab_rec.gl_date := l_tab_rec.gl_date;
      END IF;
      IF (x_tab_rec.percentage = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.percentage := l_tab_rec.percentage;
      END IF;
      IF (x_tab_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.comments := l_tab_rec.comments;
      END IF;
      IF (x_tab_rec.post_request_id = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.post_request_id := l_tab_rec.post_request_id;
      END IF;
      IF (x_tab_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_tab_rec.currency_conversion_date := l_tab_rec.currency_conversion_date;
      END IF;
      IF (x_tab_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.currency_conversion_rate := l_tab_rec.currency_conversion_rate;
      END IF;
      IF (x_tab_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.request_id := l_tab_rec.request_id;
      END IF;
      IF (x_tab_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.program_application_id := l_tab_rec.program_application_id;
      END IF;
      IF (x_tab_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.program_id := l_tab_rec.program_id;
      END IF;
      IF (x_tab_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tab_rec.program_update_date := l_tab_rec.program_update_date;
      END IF;
-- The following lines changed by Kanti on 07.05.2001. The comparison was being done
-- with G_MISS_DATE instead of G_MISS_CHAR.
      IF (x_tab_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute_category := l_tab_rec.attribute_category;
      END IF;
      IF (x_tab_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute1 := l_tab_rec.attribute1;
      END IF;
      IF (x_tab_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute2 := l_tab_rec.attribute2;
      END IF;
      IF (x_tab_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute3 := l_tab_rec.attribute3;
      END IF;
      IF (x_tab_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute4 := l_tab_rec.attribute4;
      END IF;
      IF (x_tab_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute5 := l_tab_rec.attribute5;
      END IF;
      IF (x_tab_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute6 := l_tab_rec.attribute6;
      END IF;
      IF (x_tab_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute7 := l_tab_rec.attribute7;
      END IF;
      IF (x_tab_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute8 := l_tab_rec.attribute8;
      END IF;
      IF (x_tab_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute9 := l_tab_rec.attribute9;
      END IF;
      IF (x_tab_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute10 := l_tab_rec.attribute10;
      END IF;
      IF (x_tab_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute11 := l_tab_rec.attribute11;
      END IF;
      IF (x_tab_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute12 := l_tab_rec.attribute12;
      END IF;
      IF (x_tab_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute13 := l_tab_rec.attribute13;
      END IF;
      IF (x_tab_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute14 := l_tab_rec.attribute14;
      END IF;
      IF (x_tab_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.attribute15 := l_tab_rec.attribute15;
      END IF;
-- Changes End
      IF (x_tab_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.created_by := l_tab_rec.created_by;
      END IF;
      IF (x_tab_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_tab_rec.creation_date := l_tab_rec.creation_date;
      END IF;
      IF (x_tab_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.last_updated_by := l_tab_rec.last_updated_by;
      END IF;
      IF (x_tab_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tab_rec.last_update_date := l_tab_rec.last_update_date;
      END IF;
      IF (x_tab_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.last_update_login := l_tab_rec.last_update_login;
      END IF;
-- The following two fields have been added by Kanti Jinger on 07/12/2001
      IF (x_tab_rec.aet_id = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.aet_id := l_tab_rec.aet_id;
      END IF;
      IF (x_tab_rec.posted_yn  = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.posted_yn  := l_tab_rec.posted_yn ;
      END IF;
      IF (x_tab_rec.ae_creation_error  = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.ae_creation_error  := l_tab_rec.ae_creation_error ;
      END IF;
      IF (x_tab_rec.gl_reversal_flag  = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.gl_reversal_flag  := l_tab_rec.gl_reversal_flag ;
      END IF;
      IF (x_tab_rec.reverse_event_flag  = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.reverse_event_flag  := l_tab_rec.reverse_event_flag ;
      END IF;
      IF (x_tab_rec.draft_yn  = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.draft_yn  := l_tab_rec.draft_yn ;
      END IF;
      IF (x_tab_rec.draft_version  = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.draft_version  := l_tab_rec.draft_version ;
      END IF;
      IF (x_tab_rec.post_to_gl  = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.post_to_gl  := l_tab_rec.post_to_gl ;
      END IF;
      IF (x_tab_rec.original_dist_id  = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.original_dist_id  := l_tab_rec.original_dist_id ;
      END IF;
      IF (x_tab_rec.accounting_event_id  = OKC_API.G_MISS_NUM)
      THEN
        x_tab_rec.accounting_event_id  := l_tab_rec.accounting_event_id ;
      END IF;
-- Changes ends
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
      IF (x_tab_rec.accounting_template_name  = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.accounting_template_name  := l_tab_rec.accounting_template_name ;
      END IF;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
      IF (x_tab_rec.UPGRADE_STATUS_FLAG  = OKC_API.G_MISS_CHAR)
      THEN
        x_tab_rec.UPGRADE_STATUS_FLAG  := l_tab_rec.UPGRADE_STATUS_FLAG ;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_TRNS_ACC_DSTRS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_tab_rec IN  tab_rec_type,
      x_tab_rec OUT NOCOPY tab_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tab_rec := p_tab_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tab_rec,                         -- IN
      l_tab_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tab_rec, l_def_tab_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRNS_ACC_DSTRS
    SET CURRENCY_CONVERSION_TYPE = l_def_tab_rec.currency_conversion_type,
        SET_OF_BOOKS_ID = l_def_tab_rec.set_of_books_id,
        CR_DR_FLAG = l_def_tab_rec.cr_dr_flag,
        CODE_COMBINATION_ID = l_def_tab_rec.code_combination_id,
        ORG_ID = l_def_tab_rec.org_id,
        CURRENCY_CODE = l_def_tab_rec.currency_code,
        AE_LINE_TYPE = l_def_tab_rec.ae_line_type,
        TEMPLATE_ID = l_def_tab_rec.template_id,
        SOURCE_ID = l_def_tab_rec.source_id,
        SOURCE_TABLE = l_def_tab_rec.source_table,
        OBJECT_VERSION_NUMBER = l_def_tab_rec.object_version_number,
        AMOUNT = l_def_tab_rec.amount,
        ACCOUNTED_AMOUNT = l_def_tab_rec.accounted_amount,
        GL_DATE = l_def_tab_rec.gl_date,
        PERCENTAGE = l_def_tab_rec.percentage,
        COMMENTS = l_def_tab_rec.comments,
        POST_REQUEST_ID = l_def_tab_rec.post_request_id,
        CURRENCY_CONVERSION_DATE = l_def_tab_rec.currency_conversion_date,
        CURRENCY_CONVERSION_RATE = l_def_tab_rec.currency_conversion_rate,
        REQUEST_ID = l_def_tab_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_tab_rec.program_application_id,
        PROGRAM_ID = l_def_tab_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_tab_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_tab_rec.attribute_category,
        ATTRIBUTE1 = l_def_tab_rec.attribute1,
        ATTRIBUTE2 = l_def_tab_rec.attribute2,
        ATTRIBUTE3 = l_def_tab_rec.attribute3,
        ATTRIBUTE4 = l_def_tab_rec.attribute4,
        ATTRIBUTE5 = l_def_tab_rec.attribute5,
        ATTRIBUTE6 = l_def_tab_rec.attribute6,
        ATTRIBUTE7 = l_def_tab_rec.attribute7,
        ATTRIBUTE8 = l_def_tab_rec.attribute8,
        ATTRIBUTE9 = l_def_tab_rec.attribute9,
        ATTRIBUTE10 = l_def_tab_rec.attribute10,
        ATTRIBUTE11 = l_def_tab_rec.attribute11,
        ATTRIBUTE12 = l_def_tab_rec.attribute12,
        ATTRIBUTE13 = l_def_tab_rec.attribute13,
        ATTRIBUTE14 = l_def_tab_rec.attribute14,
        ATTRIBUTE15 = l_def_tab_rec.attribute15,
        CREATED_BY = l_def_tab_rec.created_by,
        CREATION_DATE = l_def_tab_rec.creation_date,
        LAST_UPDATED_BY = l_def_tab_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tab_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tab_rec.last_update_login,
-- The following two fields have been added by Kanti Jinger on 07/12/2001
        aet_id = l_def_tab_rec.aet_id ,
        POSTED_YN = l_def_tab_rec.posted_yn,
        AE_CREATION_ERROR = l_def_tab_rec.AE_CREATION_ERROR,
        GL_REVERSAL_FLAG = l_def_tab_rec.GL_REVERSAL_FLAG,
        Reverse_event_flag = l_def_tab_rec.Reverse_event_flag,
        draft_yn = l_def_tab_rec.draft_yn,
        draft_version = l_def_tab_rec.draft_version,
        original_dist_id = l_def_tab_rec.original_dist_id,
        accounting_event_id = l_def_tab_rec.accounting_event_id,
        POST_TO_GL = l_def_tab_rec.POST_TO_GL,
-- Changes ends
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
        ACCOUNTING_TEMPLATE_NAME = l_def_tab_rec.ACCOUNTING_TEMPLATE_NAME,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
        UPGRADE_STATUS_FLAG = l_def_tab_rec.UPGRADE_STATUS_FLAG
    WHERE ID = l_def_tab_rec.id;

    x_tab_rec := l_def_tab_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_TRNS_ACC_DSTRS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN tabv_rec_type,
    x_tabv_rec                     OUT NOCOPY tabv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tabv_rec                     tabv_rec_type := p_tabv_rec;
    l_def_tabv_rec                 tabv_rec_type;
    l_tab_rec                      tab_rec_type;
    lx_tab_rec                     tab_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tabv_rec	IN tabv_rec_type
    ) RETURN tabv_rec_type IS
      l_tabv_rec	tabv_rec_type := p_tabv_rec;
    BEGIN
      l_tabv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tabv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tabv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tabv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tabv_rec	IN tabv_rec_type,
      x_tabv_rec	OUT NOCOPY tabv_rec_type
    ) RETURN VARCHAR2 IS
      l_tabv_rec                     tabv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tabv_rec := p_tabv_rec;
      -- Get current database values
      l_tabv_rec := get_rec(p_tabv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tabv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.id := l_tabv_rec.id;
      END IF;
      IF (x_tabv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.object_version_number := l_tabv_rec.object_version_number;
      END IF;
      IF (x_tabv_rec.template_id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.template_id := l_tabv_rec.template_id;
      END IF;
      IF (x_tabv_rec.cr_dr_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.cr_dr_flag := l_tabv_rec.cr_dr_flag;
      END IF;
      IF (x_tabv_rec.ae_line_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.ae_line_type := l_tabv_rec.ae_line_type;
      END IF;
-- Line changed by Kanti on 07.05.2001. MISS_CHAR replaced by MISS_NUM.
      IF (x_tabv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.org_id := l_tabv_rec.org_id;
      END IF;
-- Line changed by Kanti on 07.05.2001. MISS_CHAR replaced by MISS_NUM.
      IF (x_tabv_rec.set_of_books_id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.set_of_books_id := l_tabv_rec.set_of_books_id;
      END IF;
-- Line changed by Kanti on 07.05.2001. MISS_CHAR replaced by MISS_NUM.
      IF (x_tabv_rec.code_combination_id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.code_combination_id := l_tabv_rec.code_combination_id;
      END IF;
      IF (x_tabv_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.currency_code := l_tabv_rec.currency_code;
      END IF;
      IF (x_tabv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.currency_conversion_type := l_tabv_rec.currency_conversion_type;
      END IF;
      IF (x_tabv_rec.source_id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.source_id := l_tabv_rec.source_id;
      END IF;
      IF (x_tabv_rec.source_table = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.source_table := l_tabv_rec.source_table;
      END IF;
      IF (x_tabv_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.amount := l_tabv_rec.amount;
      END IF;
      IF (x_tabv_rec.accounted_amount = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.accounted_amount := l_tabv_rec.accounted_amount;
      END IF;
      IF (x_tabv_rec.gl_date = OKC_API.G_MISS_DATE)
      THEN
        x_tabv_rec.gl_date := l_tabv_rec.gl_date;
      END IF;
      IF (x_tabv_rec.percentage = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.percentage := l_tabv_rec.percentage;
      END IF;
      IF (x_tabv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.comments := l_tabv_rec.comments;
      END IF;
      IF (x_tabv_rec.post_request_id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.post_request_id := l_tabv_rec.post_request_id;
      END IF;
      IF (x_tabv_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_tabv_rec.currency_conversion_date := l_tabv_rec.currency_conversion_date;
      END IF;
      IF (x_tabv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.currency_conversion_rate := l_tabv_rec.currency_conversion_rate;
      END IF;
-- The following lines changed by Kanti on 07.05.2001. Comparison was being done
-- with G_MISS_NUM instead of G_MISS_CHAR
      IF (x_tabv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute_category := l_tabv_rec.attribute_category;
      END IF;
      IF (x_tabv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute1 := l_tabv_rec.attribute1;
      END IF;
      IF (x_tabv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute2 := l_tabv_rec.attribute2;
      END IF;
      IF (x_tabv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute3 := l_tabv_rec.attribute3;
      END IF;
      IF (x_tabv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute4 := l_tabv_rec.attribute4;
      END IF;
      IF (x_tabv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute5 := l_tabv_rec.attribute5;
      END IF;
      IF (x_tabv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute6 := l_tabv_rec.attribute6;
      END IF;
      IF (x_tabv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute7 := l_tabv_rec.attribute7;
      END IF;
      IF (x_tabv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute8 := l_tabv_rec.attribute8;
      END IF;
      IF (x_tabv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute9 := l_tabv_rec.attribute9;
      END IF;
      IF (x_tabv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute10 := l_tabv_rec.attribute10;
      END IF;
      IF (x_tabv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute11 := l_tabv_rec.attribute11;
      END IF;
      IF (x_tabv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute12 := l_tabv_rec.attribute12;
      END IF;
      IF (x_tabv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute13 := l_tabv_rec.attribute13;
      END IF;
      IF (x_tabv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute14 := l_tabv_rec.attribute14;
      END IF;
      IF (x_tabv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.attribute15 := l_tabv_rec.attribute15;
      END IF;
-- Changes End here
      IF (x_tabv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.request_id := l_tabv_rec.request_id;
      END IF;
      IF (x_tabv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.program_application_id := l_tabv_rec.program_application_id;
      END IF;
      IF (x_tabv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.program_id := l_tabv_rec.program_id;
      END IF;
      IF (x_tabv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tabv_rec.program_update_date := l_tabv_rec.program_update_date;
      END IF;
      IF (x_tabv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.created_by := l_tabv_rec.created_by;
      END IF;
      IF (x_tabv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_tabv_rec.creation_date := l_tabv_rec.creation_date;
      END IF;
      IF (x_tabv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.last_updated_by := l_tabv_rec.last_updated_by;
      END IF;
      IF (x_tabv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tabv_rec.last_update_date := l_tabv_rec.last_update_date;
      END IF;
      IF (x_tabv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.last_update_login := l_tabv_rec.last_update_login;
      END IF;
-- The following two fields have been added by Kanti Jinger on 07/12/2001
      IF (x_tabv_rec.aet_id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.aet_id := l_tabv_rec.aet_id;
      END IF;
      IF (x_tabv_rec.posted_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.posted_yn := l_tabv_rec.posted_yn;
      END IF;
      IF (x_tabv_rec.ae_Creation_error = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.ae_Creation_error := l_tabv_rec.ae_Creation_error;
      END IF;
      IF (x_tabv_rec.gl_reversal_flag  = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.gl_reversal_flag  := l_tabv_rec.gl_reversal_flag ;
      END IF;
      IF (x_tabv_rec.reverse_event_flag  = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.reverse_event_flag  := l_tabv_rec.reverse_event_flag ;
      END IF;
      IF (x_tabv_rec.draft_yn  = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.draft_yn  := l_tabv_rec.draft_yn ;
      END IF;
      IF (x_tabv_rec.draft_version  = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.draft_version  := l_tabv_rec.draft_version ;
      END IF;
      IF (x_tabv_rec.post_to_gl = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.post_to_gl := l_tabv_rec.post_to_gl;
      END IF;
      IF (x_tabv_rec.original_dist_id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.original_dist_id := l_tabv_rec.original_dist_id;
      END IF;
      IF (x_tabv_rec.accounting_event_id = OKC_API.G_MISS_NUM)
      THEN
        x_tabv_rec.accounting_event_id := l_tabv_rec.accounting_event_id;
      END IF;
-- Changes ends
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
      IF (x_tabv_rec.accounting_template_name = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.accounting_template_name := l_tabv_rec.accounting_template_name;
      END IF;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
      IF (x_tabv_rec.UPGRADE_STATUS_FLAG = OKC_API.G_MISS_CHAR)
      THEN
        x_tabv_rec.UPGRADE_STATUS_FLAG := l_tabv_rec.UPGRADE_STATUS_FLAG;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TRNS_ACC_DSTRS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tabv_rec IN  tabv_rec_type,
      x_tabv_rec OUT NOCOPY tabv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

-- 05-10-01 - spalod  - start - get and set org id and set of book id, concurrent program fields
	  l_request_id NUMBER := Fnd_Global.CONC_REQUEST_ID;
	  l_prog_app_id NUMBER := Fnd_Global.PROG_APPL_ID;
	  l_program_id NUMBER := Fnd_Global.CONC_PROGRAM_ID;
-- 05-10-01 - spalod  - end - get and set org id and set of book id, concurrent program fields

    BEGIN
      x_tabv_rec := p_tabv_rec;

-- 05-10-01 - spalod  - start - get and set org id and set of book id, concurrent program fields

	 SELECT  NVL(DECODE(l_request_id, -1, NULL, l_request_id) ,p_tabv_rec.REQUEST_ID)
    ,NVL(DECODE(l_prog_app_id, -1, NULL, l_prog_app_id) ,p_tabv_rec.PROGRAM_APPLICATION_ID)
    ,NVL(DECODE(l_program_id, -1, NULL, l_program_id)  ,p_tabv_rec.PROGRAM_ID)
    ,DECODE(DECODE(l_request_id, -1, NULL, SYSDATE) ,NULL, p_tabv_rec.PROGRAM_UPDATE_DATE,SYSDATE)
  	INTO x_tabv_rec.REQUEST_ID
    ,x_tabv_rec.PROGRAM_APPLICATION_ID
    ,x_tabv_rec.PROGRAM_ID
    ,x_tabv_rec.PROGRAM_UPDATE_DATE
    FROM DUAL;

-- 05-10-01 - spalod  - end - get and set org id and set of book id, concurrent program fields

      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tabv_rec,                        -- IN
      l_tabv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tabv_rec, l_def_tabv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tabv_rec := fill_who_columns(l_def_tabv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tabv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tabv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tabv_rec, l_tab_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tab_rec,
      lx_tab_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tab_rec, l_def_tabv_rec);
    x_tabv_rec := l_def_tabv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:TABV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN tabv_tbl_type,
    x_tabv_tbl                     OUT NOCOPY tabv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tabv_tbl.COUNT > 0) THEN
      i := p_tabv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tabv_rec                     => p_tabv_tbl(i),
          x_tabv_rec                     => x_tabv_tbl(i));

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                l_overall_status := x_return_status;
            END IF;
          END IF;

        EXIT WHEN (i = p_tabv_tbl.LAST);
        i := p_tabv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_Status := l_overall_Status;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------
  -- delete_row for:OKL_TRNS_ACC_DSTRS --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tab_rec                      IN tab_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DSTRS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tab_rec                      tab_rec_type:= p_tab_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TRNS_ACC_DSTRS
     WHERE ID = l_tab_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_TRNS_ACC_DSTRS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN tabv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tabv_rec                     tabv_rec_type := p_tabv_rec;
    l_tab_rec                      tab_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_tabv_rec, l_tab_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tab_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:TABV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN tabv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tabv_tbl.COUNT > 0) THEN
      i := p_tabv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tabv_rec                     => p_tabv_tbl(i));
   IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_tabv_tbl.LAST);
        i := p_tabv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_TAB_PVT;

/
