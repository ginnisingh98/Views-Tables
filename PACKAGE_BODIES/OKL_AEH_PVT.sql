--------------------------------------------------------
--  DDL for Package Body OKL_AEH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AEH_PVT" AS
/* $Header: OKLSAEHB.pls 120.3 2006/07/13 12:49:24 adagur noship $ */
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
  -- FUNCTION get_rec for: OKL_AE_HEADERS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aeh_rec                      IN aeh_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aeh_rec_type IS
    CURSOR okl_ae_headers_pk_csr (p_AE_HEADER_ID            IN NUMBER) IS
    SELECT
            AE_HEADER_ID ,
            POST_TO_GL_FLAG,
            SET_OF_BOOKS_ID,
            ORG_ID,
            ACCOUNTING_EVENT_ID,
            AE_CATEGORY,
            PERIOD_NAME,
            ACCOUNTING_DATE,
            CROSS_CURRENCY_FLAG,
            GL_TRANSFER_FLAG,
            GL_TRANSFER_RUN_ID,
            OBJECT_VERSION_NUMBER,
            SEQUENCE_ID,
            SEQUENCE_VALUE,
            DESCRIPTION,
            ACCOUNTING_ERROR_CODE,
            GL_TRANSFER_ERROR_CODE,
            GL_REVERSAL_FLAG,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ae_Headers
     WHERE okl_ae_headers.AE_HEADER_ID     = p_AE_HEADER_ID ;
    l_okl_ae_headers_pk            okl_ae_headers_pk_csr%ROWTYPE;
    l_aeh_rec                      aeh_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ae_headers_pk_csr (p_aeh_rec.AE_HEADER_ID );
    FETCH okl_ae_headers_pk_csr INTO
              l_aeh_rec.AE_HEADER_ID ,
              l_aeh_rec.POST_TO_GL_FLAG,
              l_aeh_rec.SET_OF_BOOKS_ID,
              l_aeh_rec.ORG_ID,
              l_aeh_rec.ACCOUNTING_EVENT_ID,
              l_aeh_rec.AE_CATEGORY,
              l_aeh_rec.PERIOD_NAME,
              l_aeh_rec.ACCOUNTING_DATE,
              l_aeh_rec.CROSS_CURRENCY_FLAG,
              l_aeh_rec.GL_TRANSFER_FLAG,
              l_aeh_rec.GL_TRANSFER_RUN_ID,
              l_aeh_rec.OBJECT_VERSION_NUMBER,
              l_aeh_rec.SEQUENCE_ID,
              l_aeh_rec.SEQUENCE_VALUE,
              l_aeh_rec.DESCRIPTION,
              l_aeh_rec.ACCOUNTING_ERROR_CODE,
              l_aeh_rec.GL_TRANSFER_ERROR_CODE,
              l_aeh_rec.GL_REVERSAL_FLAG,
              l_aeh_rec.PROGRAM_ID,
              l_aeh_rec.PROGRAM_APPLICATION_ID,
              l_aeh_rec.PROGRAM_UPDATE_DATE,
              l_aeh_rec.REQUEST_ID,
              l_aeh_rec.CREATED_BY,
              l_aeh_rec.CREATION_DATE,
              l_aeh_rec.LAST_UPDATED_BY,
              l_aeh_rec.LAST_UPDATE_DATE,
              l_aeh_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ae_headers_pk_csr%NOTFOUND;
    CLOSE okl_ae_headers_pk_csr;
    RETURN(l_aeh_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aeh_rec                      IN aeh_rec_type
  ) RETURN aeh_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aeh_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_AE_HEADERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aehv_rec                     IN aehv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aehv_rec_type IS
    CURSOR okl_aehv_pk_csr (p_AE_HEADER_ID                  IN NUMBER) IS
    SELECT
            POST_TO_GL_FLAG,
            AE_HEADER_ID,
            OBJECT_VERSION_NUMBER,
            ACCOUNTING_EVENT_ID,
            SET_OF_BOOKS_ID,
            ORG_ID,
            AE_CATEGORY,
            SEQUENCE_ID,
            SEQUENCE_VALUE,
            PERIOD_NAME,
            ACCOUNTING_DATE,
            DESCRIPTION,
            ACCOUNTING_ERROR_CODE,
            CROSS_CURRENCY_FLAG,
            GL_TRANSFER_FLAG,
            GL_TRANSFER_ERROR_CODE,
            GL_TRANSFER_RUN_ID,
            GL_REVERSAL_FLAG,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_AE_HEADERS
     WHERE OKL_AE_HEADERS.AE_HEADER_ID   = p_AE_HEADER_ID ;
    l_okl_aehv_pk                  okl_aehv_pk_csr%ROWTYPE;
    l_aehv_rec                     aehv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_aehv_pk_csr (p_aehv_rec.AE_HEADER_ID);
    FETCH okl_aehv_pk_csr INTO
              l_aehv_rec.POST_TO_GL_FLAG,
              l_aehv_rec.AE_HEADER_ID ,
              l_aehv_rec.OBJECT_VERSION_NUMBER,
              l_aehv_rec.ACCOUNTING_EVENT_ID,
              l_aehv_rec.SET_OF_BOOKS_ID,
              l_aehv_rec.ORG_ID,
              l_aehv_rec.AE_CATEGORY,
              l_aehv_rec.SEQUENCE_ID,
              l_aehv_rec.SEQUENCE_VALUE,
              l_aehv_rec.PERIOD_NAME,
              l_aehv_rec.ACCOUNTING_DATE,
              l_aehv_rec.DESCRIPTION,
              l_aehv_rec.ACCOUNTING_ERROR_CODE,
              l_aehv_rec.CROSS_CURRENCY_FLAG,
              l_aehv_rec.GL_TRANSFER_FLAG,
              l_aehv_rec.GL_TRANSFER_ERROR_CODE,
              l_aehv_rec.GL_TRANSFER_RUN_ID,
              l_aehv_rec.GL_REVERSAL_FLAG,
              l_aehv_rec.PROGRAM_ID,
              l_aehv_rec.PROGRAM_APPLICATION_ID,
              l_aehv_rec.PROGRAM_UPDATE_DATE,
              l_aehv_rec.REQUEST_ID,
              l_aehv_rec.CREATED_BY,
              l_aehv_rec.CREATION_DATE,
              l_aehv_rec.LAST_UPDATED_BY,
              l_aehv_rec.LAST_UPDATE_DATE,
              l_aehv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_aehv_pk_csr%NOTFOUND;
    CLOSE okl_aehv_pk_csr;
    RETURN(l_aehv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aehv_rec                     IN aehv_rec_type
  ) RETURN aehv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aehv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_AE_HEADERS_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_aehv_rec	IN aehv_rec_type
  ) RETURN aehv_rec_type IS
    l_aehv_rec	aehv_rec_type := p_aehv_rec;
  BEGIN
    IF (l_aehv_rec.post_to_gl_flag = Okc_Api.G_MISS_CHAR) THEN
      l_aehv_rec.post_to_gl_flag := NULL;
    END IF;
    IF (l_aehv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.object_version_number := NULL;
    END IF;
    IF (l_aehv_rec.ACCOUNTING_EVENT_ID = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.ACCOUNTING_EVENT_ID  := NULL;
    END IF;
    IF (l_aehv_rec.set_of_books_id = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.set_of_books_id := NULL;
    END IF;
    IF (l_aehv_rec.org_id = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.org_id := NULL;
    END IF;
    IF (l_aehv_rec.AE_CATEGORY = Okc_Api.G_MISS_CHAR) THEN
      l_aehv_rec.AE_CATEGORY := NULL;
    END IF;
    IF (l_aehv_rec.sequence_id = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.sequence_id := NULL;
    END IF;
    IF (l_aehv_rec.sequence_value = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.sequence_value := NULL;
    END IF;
    IF (l_aehv_rec.period_name = Okc_Api.G_MISS_CHAR) THEN
      l_aehv_rec.period_name := NULL;
    END IF;
    IF (l_aehv_rec.accounting_date = Okc_Api.G_MISS_DATE) THEN
      l_aehv_rec.accounting_date := NULL;
    END IF;
    IF (l_aehv_rec.description = Okc_Api.G_MISS_CHAR) THEN
      l_aehv_rec.description := NULL;
    END IF;
    IF (l_aehv_rec.accounting_error_code = Okc_Api.G_MISS_CHAR) THEN
      l_aehv_rec.accounting_error_code := NULL;
    END IF;
    IF (l_aehv_rec.cross_currency_flag = Okc_Api.G_MISS_CHAR) THEN
      l_aehv_rec.cross_currency_flag := NULL;
    END IF;
    IF (l_aehv_rec.gl_transfer_flag = Okc_Api.G_MISS_CHAR) THEN
      l_aehv_rec.gl_transfer_flag := NULL;
    END IF;
    IF (l_aehv_rec.gl_transfer_error_code = Okc_Api.G_MISS_CHAR) THEN
      l_aehv_rec.gl_transfer_error_code := NULL;
    END IF;
    IF (l_aehv_rec.gl_transfer_run_id = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.gl_transfer_run_id := NULL;
    END IF;
    IF (l_aehv_rec.gl_reversal_flag = Okc_Api.G_MISS_CHAR) THEN
      l_aehv_rec.gl_reversal_flag := NULL;
    END IF;

    IF (l_aehv_rec.program_id = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.program_id := NULL;
    END IF;
    IF (l_aehv_rec.program_application_id = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.program_application_id := NULL;
    END IF;
    IF (l_aehv_rec.program_update_date = Okc_Api.G_MISS_DATE) THEN
      l_aehv_rec.program_update_date := NULL;
    END IF;
    IF (l_aehv_rec.request_id = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.request_id := NULL;
    END IF;

    IF (l_aehv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.created_by := NULL;
    END IF;
    IF (l_aehv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_aehv_rec.creation_date := NULL;
    END IF;
    IF (l_aehv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.last_updated_by := NULL;
    END IF;

    IF (l_aehv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_aehv_rec.last_update_date := NULL;
    END IF;

    IF (l_aehv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_aehv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_aehv_rec);

  END null_out_defaults;

 /*--- Renu Gurudev 4/26/2001 - Commented OUT generated code IN favor OF manually written code
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_AE_HEADERS_V --
  ----------------------------------------------

  Function Validate_Attributes (
    p_aehv_rec IN  aehv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    IF p_aehv_rec.AE_HEADER_ID  = Okc_Api.G_MISS_NUM OR
       p_aehv_rec.AE_HEADER_ID  IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aehv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
          p_aehv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aehv_rec.ACCOUNTING_EVENT_ID  = Okc_Api.G_MISS_NUM OR
          p_aehv_rec.ACCOUNTING_EVENT_ID  IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'accounting_event_id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aehv_rec.set_of_books_id = Okc_Api.G_MISS_NUM OR
          p_aehv_rec.set_of_books_id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'set_of_books_id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aehv_rec.AE_CATEGORY = Okc_Api.G_MISS_CHAR OR
          p_aehv_rec.AE_CATEGORY IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'journal_category');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aehv_rec.period_name = Okc_Api.G_MISS_CHAR OR
          p_aehv_rec.period_name IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'period_name');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aehv_rec.accounting_date = Okc_Api.G_MISS_DATE OR
          p_aehv_rec.accounting_date IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'accounting_date');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aehv_rec.cross_currency_flag = Okc_Api.G_MISS_CHAR OR
          p_aehv_rec.cross_currency_flag IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cross_currency_flag');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aehv_rec.gl_transfer_flag = Okc_Api.G_MISS_CHAR OR
          p_aehv_rec.gl_transfer_flag IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'gl_transfer_flag');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aehv_rec.gl_transfer_run_id = Okc_Api.G_MISS_NUM OR
          p_aehv_rec.gl_transfer_run_id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'gl_transfer_run_id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKL_AE_HEADERS_V --
  ------------------------------------------
  Function Validate_Record (
    p_aehv_rec IN aehv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;


*/
  /*********** begin manual coding *****************/
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
  PROCEDURE Validate_AE_HEADER_ID (p_aehv_rec      IN  aehv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aehv_rec.AE_HEADER_ID  IS NULL) OR
       (p_aehv_rec.AE_HEADER_ID  = Okc_Api.G_MISS_NUM) THEN
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

  END Validate_AE_HEADER_ID ;

  ---------------------------------------------------------------------------
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

  PROCEDURE Validate_Object_Version_Number (p_aehv_rec      IN  aehv_rec_type
                                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aehv_rec.object_version_number IS NULL) OR
       (p_aehv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
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
  -- PROCEDURE Validate_ACCOUNTING_EVENT_ID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_ACCOUNTING_EVENT_ID
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_ACCOUNTING_EVENT_ID  (p_aehv_rec      IN  aehv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  item_not_found_error              EXCEPTION;
  l_dummy_var                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;

  CURSOR okl_aehv_fk_csr (p_accounting_event_id IN NUMBER) IS
  SELECT  '1'
  FROM OKL_ACCOUNTING_EVENTS
  WHERE OKL_ACCOUNTING_EVENTS.accounting_event_id = p_accounting_event_id;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aehv_rec.ACCOUNTING_EVENT_ID  IS NULL) OR
       (p_aehv_rec.ACCOUNTING_EVENT_ID  = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'accounting_event_id');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_aehv_fk_csr(p_aehv_rec.ACCOUNTING_EVENT_ID );
    FETCH okl_aehv_fk_csr INTO l_dummy_var;
    l_row_notfound := okl_aehv_fk_csr%NOTFOUND;
    CLOSE okl_aehv_fk_csr;
    IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'accounting_event_id');
          RAISE item_not_found_error;
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

  END Validate_ACCOUNTING_EVENT_ID ;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Set_Of_Books_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Set_Of_Books_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Set_Of_Books_Id (p_aehv_rec      IN  aehv_rec_type
				      ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy_var                       VARCHAR2(1);
  item_not_found_error	 		EXCEPTION;
  l_row_notfound                    BOOLEAN := TRUE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aehv_rec.set_of_books_id IS NULL) OR
       (p_aehv_rec.set_of_books_id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'set_of_books_id');
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

  END Validate_Set_Of_Books_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_AE_CATEGORY
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_AE_CATEGORY
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_AE_CATEGORY (p_aehv_rec      IN  aehv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                           VARCHAR2(1) := OKC_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
  IF (p_aehv_rec.AE_CATEGORY IS NULL) OR
       (p_aehv_rec.AE_CATEGORY = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'journal_category');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
  l_dummy := OKL_ACCOUNTING_UTIL.validate_journal_CATEGORY(p_aehv_rec.AE_CATEGORY);

  IF (l_dummy = OKC_API.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_invalid_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'journal_category');
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

  END Validate_AE_CATEGORY;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Period_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Period_Name
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Period_Name (p_aehv_rec      IN  aehv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aehv_rec.period_name IS NULL) OR
       (p_aehv_rec.period_name = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'period_name');
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

  END Validate_Period_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Accounting_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Accounting_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Accounting_Date(p_aehv_rec      IN   aehv_rec_type
                                     ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aehv_rec.accounting_date IS NULL) OR
       (p_aehv_rec.accounting_date = Okc_Api.G_MISS_DATE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'accounting_date');
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

  END Validate_Accounting_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Cross_Currency_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Cross_Currency_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Cross_Currency_Flag(p_aehv_rec      IN      aehv_rec_type
						  ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy         VARCHAR2(1)  := Okc_Api.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aehv_rec.cross_currency_flag IS NULL) OR
       (p_aehv_rec.cross_currency_flag = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'cross_currency_flag');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check in fnd_lookups for validity

    l_dummy
       := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'YES_NO',
                                                   p_lookup_code => p_aehv_rec.cross_currency_flag,
                                                   p_app_id => 0,
                                                   p_view_app_id => 0);

    IF (l_dummy = Okc_Api.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'CROSS_CURRENCY_FLAG');
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

  END Validate_Cross_Currency_Flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_GL_Transfer_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_GL_Transfer_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_GL_Transfer_Flag(p_aehv_rec      IN      aehv_rec_type
						  ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_DUMMY         VARCHAR2(1)  := Okc_Api.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aehv_rec.gl_transfer_flag IS NULL) OR
       (p_aehv_rec.gl_transfer_flag = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'gl_transfer_flag');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check in fnd_lookups for validity
    l_dummy
       := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'YES_NO',
                                                   p_lookup_code => p_aehv_rec.gl_transfer_flag,
                                                   p_app_id => 0,
                                                   p_view_app_id => 0);

    IF (l_dummy = Okc_Api.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'GL_TRANSFER_FLAG');
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

  END Validate_GL_Transfer_Flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_GL_Reversal_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_GL_Reversal_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_GL_Reversal_Flag(p_aehv_rec      IN      aehv_rec_type
						  ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy         VARCHAR2(1)  := Okc_Api.G_FALSE;

  BEGIN
    -- initialize return status

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check in fnd_lookups for validity
    IF (p_aehv_rec.gl_reversal_flag IS NOT NULL) AND
       (p_aehv_rec.gl_reversal_flag <> Okc_Api.G_MISS_CHAR) THEN
        l_dummy
          := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'YES_NO',
                                                      p_lookup_code => p_aehv_rec.gl_reversal_flag,
                                                      p_app_id => 0,
                                                      p_view_app_id => 0);

       IF (l_dummy = Okc_Api.G_FALSE) THEN
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

  END Validate_GL_Reversal_Flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Post_To_GL_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Post_To_GL_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Post_To_GL_Flag(p_aehv_rec      IN      aehv_rec_type
						  ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy         VARCHAR2(1)  := Okc_Api.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_aehv_rec.post_to_gl_flag IS NOT NULL) AND
       (p_aehv_rec.post_to_gl_flag <> Okc_Api.G_MISS_CHAR) THEN
        l_dummy
          := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'YES_NO',
                                                      p_lookup_code => p_aehv_rec.post_to_gl_flag,
                                                      p_app_id => 0,
                                                      p_view_app_id => 0);


       IF (l_dummy = Okc_Api.G_FALSE) THEN
           Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'POST_TO_GL_FLAG');
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

  END Validate_Post_To_GL_Flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_GL_Transfer_Run_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_GL_Transfer_Run_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_GL_Transfer_Run_Id (p_aehv_rec      IN  aehv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aehv_rec.gl_transfer_run_id IS NULL) OR
       (p_aehv_rec.gl_transfer_run_id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'gl_transfer_run_id');
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

  END Validate_GL_Transfer_Run_Id;

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
  PROCEDURE Validate_Accounting_Error_code (p_aehv_rec      IN  aehv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_dummy                   VARCHAR2(1)    := Okc_Api.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aehv_rec.Accounting_Error_Code IS NOT NULL) AND
       (p_aehv_rec.Accounting_Error_code <> Okc_Api.G_MISS_CHAR) THEN

        l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(
                  p_lookup_type => 'OKL_ACCOUNTING_ERROR_CODE',
                  p_lookup_code => p_aehv_rec.accounting_error_code);

       IF (l_dummy = OKC_API.G_FALSE) THEN

            Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                                ,p_msg_name      => g_invalid_value
                                ,p_token1        => g_col_name_token
                                ,p_token1_value  => 'ACCOUNTING_ERROR_CODE');
            x_return_status     := Okc_Api.G_RET_STS_ERROR;

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
  -- PROCEDURE Validate_GL_Transfer_Err_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : validate_gl_transfer_err_code
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE validate_gl_transfer_err_code (p_aehv_rec      IN  aehv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_dummy                   VARCHAR2(1)    := Okc_Api.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aehv_rec.GL_Transfer_Error_Code IS NOT NULL) AND
       (p_aehv_rec.GL_Transfer_Error_Code <> Okc_Api.G_MISS_CHAR) THEN

        l_dummy
          := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(
               p_lookup_type => 'OKL_ACCOUNTING_ERROR_CODE',
               p_lookup_code => p_aehv_rec.GL_Transfer_Error_Code);

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

  END validate_gl_transfer_err_code;


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
    p_aehv_rec IN  aehv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN

    -- call each column-level validation

    -- Validate_AE_HEADER_ID
    Validate_AE_HEADER_ID (p_aehv_rec, x_return_status);
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
    Validate_Object_Version_Number(p_aehv_rec, x_return_status);
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

    -- Validate_ACCOUNTING_EVENT_ID
    Validate_ACCOUNTING_EVENT_ID (p_aehv_rec, x_return_status);
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

    -- Validate_Set_Of_Books_Id
    Validate_Set_Of_Books_Id(p_aehv_rec, x_return_status);
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

    -- Validate_AE_CATEGORY
    Validate_AE_CATEGORY(p_aehv_rec, x_return_status);
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

    -- Validate_Period_Name
    Validate_Period_Name(p_aehv_rec, x_return_status);
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

    -- Validate_Accounting_Date
    Validate_Accounting_Date(p_aehv_rec, x_return_status);
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

    -- Validate_Cross_Currency_Flag
    Validate_Cross_Currency_Flag(p_aehv_rec, x_return_status);
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

    -- Validate_GL_Transfer_Flag
    Validate_GL_Transfer_Flag(p_aehv_rec, x_return_status);
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

    -- Validate_Post_To_GL_Flag
    Validate_Post_To_GL_Flag(p_aehv_rec, x_return_status);
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

    -- Validate_GL_Reversal_Flag
    Validate_GL_Reversal_Flag(p_aehv_rec, x_return_status);
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

    -- Validate_GL_Transfer_Run_Id
    Validate_GL_Transfer_Run_Id(p_aehv_rec, x_return_status);
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
    Validate_Accounting_Error_Code(p_aehv_rec, x_return_status);
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

    -- validate_gl_transfer_err_code
    validate_gl_transfer_err_code(p_aehv_rec, x_return_status);
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
    p_aehv_rec IN aehv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN(l_return_status);
  END Validate_Record;

  /*********************** END MANUAL CODE **********************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN aehv_rec_type,
    p_to	IN OUT NOCOPY aeh_rec_type
  ) IS
  BEGIN
    p_to.AE_HEADER_ID  := p_from.AE_HEADER_ID ;
    p_to.post_to_gl_flag := p_from.post_to_gl_flag;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.org_id := p_from.org_id;
    p_to.ACCOUNTING_EVENT_ID  := p_from.ACCOUNTING_EVENT_ID ;
    p_to.AE_CATEGORY := p_from.AE_CATEGORY;
    p_to.period_name := p_from.period_name;
    p_to.accounting_date := p_from.accounting_date;
    p_to.cross_currency_flag := p_from.cross_currency_flag;
    p_to.gl_transfer_flag := p_from.gl_transfer_flag;
    p_to.gl_transfer_run_id := p_from.gl_transfer_run_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sequence_id := p_from.sequence_id;
    p_to.sequence_value := p_from.sequence_value;
    p_to.description := p_from.description;
    p_to.accounting_error_code := p_from.accounting_error_code;
    p_to.gl_transfer_error_code := p_from.gl_transfer_error_code;
    p_to.gl_reversal_flag := p_from.gl_reversal_flag;
    p_to.program_id := p_from.program_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.request_id := p_from.request_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN aeh_rec_type,
    p_to	IN OUT NOCOPY aehv_rec_type
  ) IS
  BEGIN
    p_to.AE_HEADER_ID  := p_from.AE_HEADER_ID ;
    p_to.post_to_gl_flag := p_from.post_to_gl_flag;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.org_id := p_from.org_id;
    p_to.ACCOUNTING_EVENT_ID  := p_from.ACCOUNTING_EVENT_ID ;
    p_to.AE_CATEGORY := p_from.AE_CATEGORY;
    p_to.period_name := p_from.period_name;
    p_to.accounting_date := p_from.accounting_date;
    p_to.cross_currency_flag := p_from.cross_currency_flag;
    p_to.gl_transfer_flag := p_from.gl_transfer_flag;
    p_to.gl_transfer_run_id := p_from.gl_transfer_run_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sequence_id := p_from.sequence_id;
    p_to.sequence_value := p_from.sequence_value;
    p_to.description := p_from.description;
    p_to.accounting_error_code := p_from.accounting_error_code;
    p_to.gl_transfer_error_code := p_from.gl_transfer_error_code;
    p_to.gl_reversal_flag := p_from.gl_reversal_flag;
    p_to.program_id := p_from.program_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.request_id := p_from.request_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKL_AE_HEADERS_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aehv_rec                     aehv_rec_type := p_aehv_rec;
    l_aeh_rec                      aeh_rec_type;
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
    l_return_status := Validate_Attributes(l_aehv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_aehv_rec);
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL validate_row for:AEHV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aehv_tbl.COUNT > 0) THEN
      i := p_aehv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aehv_rec                     => p_aehv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_aehv_tbl.LAST);
        i := p_aehv_tbl.NEXT(i);
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -----------------------------------
  -- insert_row for:OKL_AE_HEADERS --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aeh_rec                      IN aeh_rec_type,
    x_aeh_rec                      OUT NOCOPY aeh_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'HEADERS_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aeh_rec                      aeh_rec_type := p_aeh_rec;
    l_def_aeh_rec                  aeh_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKL_AE_HEADERS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_aeh_rec IN  aeh_rec_type,
      x_aeh_rec OUT NOCOPY aeh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aeh_rec := p_aeh_rec;
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
      p_aeh_rec,                         -- IN
      l_aeh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_AE_HEADERS(
        AE_HEADER_ID ,
        post_to_gl_flag,
        set_of_books_id,
        org_id,
        ACCOUNTING_EVENT_ID ,
        AE_CATEGORY,
        period_name,
        accounting_date,
        cross_currency_flag,
        gl_transfer_flag,
        gl_transfer_run_id,
        object_version_number,
        sequence_id,
        sequence_value,
        description,
        accounting_error_code,
        gl_transfer_error_code,
        gl_reversal_flag,
        program_id,
        program_application_id,
        program_update_date,
        request_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_aeh_rec.AE_HEADER_ID ,
        l_aeh_rec.post_to_gl_flag,
        l_aeh_rec.set_of_books_id,
        l_aeh_rec.org_id,
        l_aeh_rec.ACCOUNTING_EVENT_ID ,
        l_aeh_rec.AE_CATEGORY,
        l_aeh_rec.period_name,
        l_aeh_rec.accounting_date,
        l_aeh_rec.cross_currency_flag,
        l_aeh_rec.gl_transfer_flag,
        l_aeh_rec.gl_transfer_run_id,
        l_aeh_rec.object_version_number,
        l_aeh_rec.sequence_id,
        l_aeh_rec.sequence_value,
        l_aeh_rec.description,
        l_aeh_rec.accounting_error_code,
        l_aeh_rec.gl_transfer_error_code,
        l_aeh_rec.gl_reversal_flag,
        l_aeh_rec.PROGRAM_ID,
        l_aeh_rec.program_application_id,
        l_aeh_rec.program_update_date,
        l_aeh_rec.request_id,
        l_aeh_rec.created_by,
        l_aeh_rec.creation_date,
        l_aeh_rec.last_updated_by,
        l_aeh_rec.last_update_date,
        l_aeh_rec.last_update_login);
    -- Set OUT values
    x_aeh_rec := l_aeh_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -------------------------------------
  -- insert_row for:OKL_AE_HEADERS_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type,
    x_aehv_rec                     OUT NOCOPY aehv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aehv_rec                     aehv_rec_type;
    l_def_aehv_rec                 aehv_rec_type;
    l_aeh_rec                      aeh_rec_type;
    lx_aeh_rec                     aeh_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aehv_rec	IN aehv_rec_type
    ) RETURN aehv_rec_type IS
      l_aehv_rec	aehv_rec_type := p_aehv_rec;
    BEGIN
      l_aehv_rec.CREATION_DATE := SYSDATE;
      l_aehv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_aehv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aehv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_aehv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_aehv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKL_AE_HEADERS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_aehv_rec IN  aehv_rec_type,
      x_aehv_rec OUT NOCOPY aehv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
	  x_aehv_rec := p_aehv_rec;
      x_aehv_rec.OBJECT_VERSION_NUMBER := 1;
      x_aehv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();
	  x_aehv_rec.set_of_books_id := okl_accounting_util.get_set_of_books_id;
	  SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
	  		 DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
			 DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
			 DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
	  INTO  x_aehv_rec.REQUEST_ID
	  	     ,x_aehv_rec.PROGRAM_APPLICATION_ID
		     ,x_aehv_rec.PROGRAM_ID
		     ,x_aehv_rec.PROGRAM_UPDATE_DATE
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
    l_aehv_rec := null_out_defaults(p_aehv_rec);
    -- Set primary key value
    l_aehv_rec.AE_HEADER_ID  := get_seq_ID ;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_aehv_rec,                        -- IN
      l_def_aehv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_aehv_rec := fill_who_columns(l_def_aehv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aehv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aehv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aehv_rec, l_aeh_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aeh_rec,
      lx_aeh_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aeh_rec, l_def_aehv_rec);
    -- Set OUT values
    x_aehv_rec := l_def_aehv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
	  x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
	  x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL insert_row for:AEHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type,
    x_aehv_tbl                     OUT NOCOPY aehv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aehv_tbl.COUNT > 0) THEN
      i := p_aehv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aehv_rec                     => p_aehv_tbl(i),
          x_aehv_rec                     => x_aehv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_aehv_tbl.LAST);
        i := p_aehv_tbl.NEXT(i);
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
     -- PL/SQL TBL insert_row_perf for:AEHV_TBL --
     ----------------------------------------
     PROCEDURE insert_row_perf(
       p_api_version               IN NUMBER,
       p_init_msg_list             IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
       x_return_status             OUT NOCOPY VARCHAR2,
       x_msg_count                 OUT NOCOPY NUMBER,
       x_msg_data                  OUT NOCOPY VARCHAR2,
       p_aehv_tbl                  IN aehv_tbl_type,
       x_aehv_tbl                  OUT NOCOPY aehv_tbl_type) IS

       l_tabsize                   NUMBER := p_aehv_tbl.COUNT;
       ae_header_id_tbl            ae_header_id_typ;
       post_to_gl_flag_tbl         post_to_gl_flag_typ;
       set_of_books_id_tbl         set_of_books_id_typ;
       accounting_event_id_tbl     accounting_event_id_typ;
       object_version_number_tbl   object_version_number_typ;
       ae_category_tbl             ae_category_typ;
       period_name_tbl             period_name_typ;
       accounting_date_tbl         accounting_date_typ;
       gl_transfer_run_id_tbl      gl_transfer_run_id_typ;
       cross_currency_flag_tbl     cross_currency_flag_typ;
       gl_transfer_flag_tbl        gl_transfer_flag_typ;
       sequence_id_tbl             sequence_id_typ;
       sequence_value_tbl          sequence_value_typ;
       description_tbl             description_typ;
       accounting_error_code_tbl   accounting_error_code_typ;
       gl_transfer_error_code_tbl  gl_transfer_error_code_typ;
       gl_reversal_flag_tbl        gl_reversal_flag_typ;
       org_id_tbl                  org_id_typ;
       program_id_tbl              program_id_typ;
       program_application_id_tbl  program_application_id_typ;
       program_update_date_tbl     program_update_date_typ;
       request_id_tbl              request_id_typ;
       created_by_tbl              created_by_typ;
       creation_date_tbl           creation_date_typ;
       last_updated_by_tbl         last_updated_by_typ;
       last_update_date_tbl        last_update_date_typ;
       last_update_login_tbl       last_update_login_typ;
       j                           NUMBER := 0;

     BEGIN
       IF (p_aehv_tbl.COUNT > 0) THEN

         --populate column tables
         FOR i IN p_aehv_tbl.FIRST..p_aehv_tbl.LAST
         LOOP
           j := j+1;

           ae_header_id_tbl(j)           :=  p_aehv_tbl(i).ae_header_id;
           post_to_gl_flag_tbl(j)        :=  p_aehv_tbl(i).post_to_gl_flag;
           set_of_books_id_tbl(j)        :=  p_aehv_tbl(i).set_of_books_id;
           accounting_event_id_tbl(j)    :=  p_aehv_tbl(i).accounting_event_id;
           object_version_number_tbl(j)  :=  p_aehv_tbl(i).object_version_number;
           ae_category_tbl(j)            :=  p_aehv_tbl(i).ae_category;
           period_name_tbl(j)            :=  p_aehv_tbl(i).period_name;
           accounting_date_tbl(j)        :=  p_aehv_tbl(i).accounting_date;
           gl_transfer_run_id_tbl(j)     :=  p_aehv_tbl(i).gl_transfer_run_id;
           cross_currency_flag_tbl(j)    :=  p_aehv_tbl(i).cross_currency_flag;
           gl_transfer_flag_tbl(j)       :=  p_aehv_tbl(i).gl_transfer_flag;
           sequence_id_tbl(j)            :=  p_aehv_tbl(i).sequence_id;
           sequence_value_tbl(j)         :=  p_aehv_tbl(i).sequence_value;
           description_tbl(j)            :=  p_aehv_tbl(i).description;
           accounting_error_code_tbl(j)  :=  p_aehv_tbl(i).accounting_error_code;
           gl_transfer_error_code_tbl(j) :=  p_aehv_tbl(i).gl_transfer_error_code;
           gl_reversal_flag_tbl(j)       :=  p_aehv_tbl(i).gl_reversal_flag;
           org_id_tbl(j)                 :=  p_aehv_tbl(i).org_id;
           program_id_tbl(j)             :=  p_aehv_tbl(i).program_id;
           program_application_id_tbl(j) :=  p_aehv_tbl(i).program_application_id;
           program_update_date_tbl(j)    :=  p_aehv_tbl(i).program_update_date;
           request_id_tbl(j)             :=  p_aehv_tbl(i).request_id;
           created_by_tbl(j)             :=  p_aehv_tbl(i).created_by;
           creation_date_tbl(j)          :=  p_aehv_tbl(i).creation_date;
           last_updated_by_tbl(j)        :=  p_aehv_tbl(i).last_updated_by;
           last_update_date_tbl(j)       :=  p_aehv_tbl(i).last_update_date;
           last_update_login_tbl(j)      :=  p_aehv_tbl(i).last_update_login;

         END LOOP;

         --bulk insert into okl_ae_headers
         FORALL i IN 1..l_tabsize
           INSERT INTO OKL_AE_HEADERS(
               ae_header_id,
               post_to_gl_flag,
               set_of_books_id,
               org_id,
               accounting_event_id,
               ae_category,
               period_name,
               accounting_date,
               cross_currency_flag,
               gl_transfer_flag,
               gl_transfer_run_id,
               object_version_number,
               sequence_id,
               sequence_value,
               description,
               accounting_error_code,
               gl_transfer_error_code,
               gl_reversal_flag,
               program_id,
               program_application_id,
               program_update_date,
               request_id,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login)
           VALUES (
               ae_header_id_tbl(i),
               post_to_gl_flag_tbl(i),
               set_of_books_id_tbl(i),
               org_id_tbl(i),
               accounting_event_id_tbl(i),
               ae_category_tbl(i),
               period_name_tbl(i),
               accounting_date_tbl(i),
               cross_currency_flag_tbl(i),
               gl_transfer_flag_tbl(i),
               gl_transfer_run_id_tbl(i),
               object_version_number_tbl(i),
               sequence_id_tbl(i),
               sequence_value_tbl(i),
               description_tbl(i),
               accounting_error_code_tbl(i),
               gl_transfer_error_code_tbl(i),
               gl_reversal_flag_tbl(i),
               program_id_tbl(i),
               program_application_id_tbl(i),
               program_update_date_tbl(i),
               request_id_tbl(i),
               created_by_tbl(i),
               creation_date_tbl(i),
               last_updated_by_tbl(i),
               last_update_date_tbl(i),
               last_update_login_tbl(i));

       END IF;
       --set OUT params
       x_aehv_tbl := p_aehv_tbl;

     END insert_row_perf;
     --gboomina bug#4648697..changes for perf end


  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ---------------------------------
  -- lock_row for:OKL_AE_HEADERS --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aeh_rec                      IN aeh_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_aeh_rec IN aeh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AE_HEADERS
     WHERE AE_HEADER_ID  = p_aeh_rec.AE_HEADER_ID
       AND OBJECT_VERSION_NUMBER = p_aeh_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_aeh_rec IN aeh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AE_HEADERS
    WHERE AE_HEADER_ID  = p_aeh_rec.AE_HEADER_ID ;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'HEADERS_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_AE_HEADERS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_AE_HEADERS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_aeh_rec);
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
      OPEN lchk_csr(p_aeh_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_aeh_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_aeh_rec.object_version_number THEN
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -----------------------------------
  -- lock_row for:OKL_AE_HEADERS_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aeh_rec                      aeh_rec_type;
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
    migrate(p_aehv_rec, l_aeh_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aeh_rec
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL lock_row for:AEHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aehv_tbl.COUNT > 0) THEN
      i := p_aehv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aehv_rec                     => p_aehv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_aehv_tbl.LAST);
        i := p_aehv_tbl.NEXT(i);
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -----------------------------------
  -- update_row for:OKL_AE_HEADERS --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aeh_rec                      IN aeh_rec_type,
    x_aeh_rec                      OUT NOCOPY aeh_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'HEADERS_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aeh_rec                      aeh_rec_type := p_aeh_rec;
    l_def_aeh_rec                  aeh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aeh_rec	IN aeh_rec_type,
      x_aeh_rec	OUT NOCOPY aeh_rec_type
    ) RETURN VARCHAR2 IS
      l_aeh_rec                      aeh_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aeh_rec := p_aeh_rec;
      -- Get current database values
      l_aeh_rec := get_rec(p_aeh_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aeh_rec.AE_HEADER_ID  = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.AE_HEADER_ID  := l_aeh_rec.AE_HEADER_ID ;
      END IF;
      IF (x_aeh_rec.post_to_gl_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_aeh_rec.post_to_gl_flag := l_aeh_rec.post_to_gl_flag;
      END IF;
      IF (x_aeh_rec.set_of_books_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.set_of_books_id := l_aeh_rec.set_of_books_id;
      END IF;
      IF (x_aeh_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.org_id := l_aeh_rec.org_id;
      END IF;
      IF (x_aeh_rec.ACCOUNTING_EVENT_ID  = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.ACCOUNTING_EVENT_ID  := l_aeh_rec.ACCOUNTING_EVENT_ID ;
      END IF;
      IF (x_aeh_rec.AE_CATEGORY = Okc_Api.G_MISS_CHAR)
      THEN
        x_aeh_rec.AE_CATEGORY := l_aeh_rec.AE_CATEGORY;
      END IF;
      IF (x_aeh_rec.period_name = Okc_Api.G_MISS_CHAR)
      THEN
        x_aeh_rec.period_name := l_aeh_rec.period_name;
      END IF;
      IF (x_aeh_rec.accounting_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aeh_rec.accounting_date := l_aeh_rec.accounting_date;
      END IF;
      IF (x_aeh_rec.cross_currency_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_aeh_rec.cross_currency_flag := l_aeh_rec.cross_currency_flag;
      END IF;
      IF (x_aeh_rec.gl_transfer_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_aeh_rec.gl_transfer_flag := l_aeh_rec.gl_transfer_flag;
      END IF;
      IF (x_aeh_rec.gl_transfer_run_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.gl_transfer_run_id := l_aeh_rec.gl_transfer_run_id;
      END IF;
      IF (x_aeh_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.object_version_number := l_aeh_rec.object_version_number;
      END IF;
      IF (x_aeh_rec.sequence_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.sequence_id := l_aeh_rec.sequence_id;
      END IF;
      IF (x_aeh_rec.sequence_value = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.sequence_value := l_aeh_rec.sequence_value;
      END IF;
      IF (x_aeh_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_aeh_rec.description := l_aeh_rec.description;
      END IF;
      IF (x_aeh_rec.accounting_error_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_aeh_rec.accounting_error_code := l_aeh_rec.accounting_error_code;
      END IF;
      IF (x_aeh_rec.gl_transfer_error_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_aeh_rec.gl_transfer_error_code := l_aeh_rec.gl_transfer_error_code;
      END IF;
      IF (x_aeh_rec.gl_reversal_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_aeh_rec.gl_reversal_flag := l_aeh_rec.gl_reversal_flag;
      END IF;
      IF (x_aeh_rec.program_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.program_id := l_aeh_rec.program_id;
      END IF;
      IF (x_aeh_rec.program_application_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.program_application_id := l_aeh_rec.program_application_id;
      END IF;
      IF (x_aeh_rec.program_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aeh_rec.program_update_date := l_aeh_rec.program_update_date;
      END IF;
      IF (x_aeh_rec.request_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.request_id := l_aeh_rec.request_id;
      END IF;
      IF (x_aeh_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.created_by := l_aeh_rec.created_by;
      END IF;
      IF (x_aeh_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aeh_rec.creation_date := l_aeh_rec.creation_date;
      END IF;
      IF (x_aeh_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.last_updated_by := l_aeh_rec.last_updated_by;
      END IF;
      IF (x_aeh_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aeh_rec.last_update_date := l_aeh_rec.last_update_date;
      END IF;
      IF (x_aeh_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_aeh_rec.last_update_login := l_aeh_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_AE_HEADERS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_aeh_rec IN  aeh_rec_type,
      x_aeh_rec OUT NOCOPY aeh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aeh_rec := p_aeh_rec;
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
      p_aeh_rec,                         -- IN
      l_aeh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aeh_rec, l_def_aeh_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_AE_HEADERS
    SET POST_TO_GL_FLAG = l_def_aeh_rec.post_to_gl_flag,
        SET_OF_BOOKS_ID = l_def_aeh_rec.set_of_books_id,
        ORG_ID = l_def_aeh_rec.org_id,
        ACCOUNTING_EVENT_ID  = l_def_aeh_rec.ACCOUNTING_EVENT_ID ,
        AE_CATEGORY = l_def_aeh_rec.AE_CATEGORY,
        PERIOD_NAME = l_def_aeh_rec.period_name,
        ACCOUNTING_DATE = l_def_aeh_rec.accounting_date,
        CROSS_CURRENCY_FLAG = l_def_aeh_rec.cross_currency_flag,
        GL_TRANSFER_FLAG = l_def_aeh_rec.gl_transfer_flag,
        GL_TRANSFER_RUN_ID = l_def_aeh_rec.gl_transfer_run_id,
        OBJECT_VERSION_NUMBER = l_def_aeh_rec.object_version_number,
        SEQUENCE_ID = l_def_aeh_rec.sequence_id,
        SEQUENCE_VALUE = l_def_aeh_rec.sequence_value,
        DESCRIPTION = l_def_aeh_rec.description,
        ACCOUNTING_ERROR_CODE = l_def_aeh_rec.accounting_error_code,
        GL_TRANSFER_ERROR_CODE = l_def_aeh_rec.gl_transfer_error_code,
        GL_REVERSAL_FLAG = l_def_aeh_rec.gl_reversal_flag,
        PROGRAM_ID = l_def_aeh_rec.program_id,
        PROGRAM_APPLICATION_ID = l_def_aeh_rec.program_application_id,
        PROGRAM_UPDATE_DATE = l_def_aeh_rec.program_update_date,
        REQUEST_ID = l_def_aeh_rec.request_id,
        CREATED_BY = l_def_aeh_rec.created_by,
        CREATION_DATE = l_def_aeh_rec.creation_date,
        LAST_UPDATED_BY = l_def_aeh_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_aeh_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_aeh_rec.last_update_login
    WHERE AE_HEADER_ID  = l_def_aeh_rec.AE_HEADER_ID ;

    x_aeh_rec := l_def_aeh_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -------------------------------------
  -- update_row for:OKL_AE_HEADERS_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type,
    x_aehv_rec                     OUT NOCOPY aehv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aehv_rec                     aehv_rec_type := p_aehv_rec;
    l_def_aehv_rec                 aehv_rec_type;
    l_aeh_rec                      aeh_rec_type;
    lx_aeh_rec                     aeh_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aehv_rec	IN aehv_rec_type
    ) RETURN aehv_rec_type IS
      l_aehv_rec	aehv_rec_type := p_aehv_rec;
    BEGIN
      l_aehv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aehv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_aehv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_aehv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aehv_rec	IN aehv_rec_type,
      x_aehv_rec	OUT NOCOPY aehv_rec_type
    ) RETURN VARCHAR2 IS
      l_aehv_rec                     aehv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aehv_rec := p_aehv_rec;
      -- Get current database values
      l_aehv_rec := get_rec(p_aehv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aehv_rec.post_to_gl_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_aehv_rec.post_to_gl_flag := l_aehv_rec.post_to_gl_flag;
      END IF;
      IF (x_aehv_rec.AE_HEADER_ID  = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.AE_HEADER_ID  := l_aehv_rec.AE_HEADER_ID ;
      END IF;
      IF (x_aehv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.object_version_number := l_aehv_rec.object_version_number;
      END IF;
      IF (x_aehv_rec.ACCOUNTING_EVENT_ID  = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.ACCOUNTING_EVENT_ID  := l_aehv_rec.ACCOUNTING_EVENT_ID ;
      END IF;
      IF (x_aehv_rec.set_of_books_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.set_of_books_id := l_aehv_rec.set_of_books_id;
      END IF;
      IF (x_aehv_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.org_id := l_aehv_rec.org_id;
      END IF;
      IF (x_aehv_rec.AE_CATEGORY = Okc_Api.G_MISS_CHAR)
      THEN
        x_aehv_rec.AE_CATEGORY := l_aehv_rec.AE_CATEGORY;
      END IF;
      IF (x_aehv_rec.sequence_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.sequence_id := l_aehv_rec.sequence_id;
      END IF;
      IF (x_aehv_rec.sequence_value = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.sequence_value := l_aehv_rec.sequence_value;
      END IF;
      IF (x_aehv_rec.period_name = Okc_Api.G_MISS_CHAR)
      THEN
        x_aehv_rec.period_name := l_aehv_rec.period_name;
      END IF;
      IF (x_aehv_rec.accounting_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aehv_rec.accounting_date := l_aehv_rec.accounting_date;
      END IF;
      IF (x_aehv_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_aehv_rec.description := l_aehv_rec.description;
      END IF;
      IF (x_aehv_rec.accounting_error_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_aehv_rec.accounting_error_code := l_aehv_rec.accounting_error_code;
      END IF;
      IF (x_aehv_rec.cross_currency_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_aehv_rec.cross_currency_flag := l_aehv_rec.cross_currency_flag;
      END IF;
      IF (x_aehv_rec.gl_transfer_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_aehv_rec.gl_transfer_flag := l_aehv_rec.gl_transfer_flag;
      END IF;
      IF (x_aehv_rec.gl_transfer_error_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_aehv_rec.gl_transfer_error_code := l_aehv_rec.gl_transfer_error_code;
      END IF;
      IF (x_aehv_rec.gl_transfer_run_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.gl_transfer_run_id := l_aehv_rec.gl_transfer_run_id;
      END IF;
      IF (x_aehv_rec.gl_reversal_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_aehv_rec.gl_reversal_flag := l_aehv_rec.gl_reversal_flag;
      END IF;
      IF (x_aehv_rec.program_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.program_id := l_aehv_rec.program_id;
      END IF;
      IF (x_aehv_rec.program_application_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.program_application_id := l_aehv_rec.program_application_id;
      END IF;
      IF (x_aehv_rec.program_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aehv_rec.program_update_date := l_aehv_rec.program_update_date;
      END IF;
      IF (x_aehv_rec.request_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.request_id := l_aehv_rec.request_id;
      END IF;
      IF (x_aehv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.created_by := l_aehv_rec.created_by;
      END IF;
      IF (x_aehv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aehv_rec.creation_date := l_aehv_rec.creation_date;
      END IF;
      IF (x_aehv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.last_updated_by := l_aehv_rec.last_updated_by;
      END IF;
      IF (x_aehv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aehv_rec.last_update_date := l_aehv_rec.last_update_date;
      END IF;
      IF (x_aehv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_aehv_rec.last_update_login := l_aehv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_AE_HEADERS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_aehv_rec IN  aehv_rec_type,
      x_aehv_rec OUT NOCOPY aehv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aehv_rec := p_aehv_rec;
	  SELECT NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),x_aehv_rec.REQUEST_ID),
	  		 NVL(DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.PROG_APPL_ID),x_aehv_rec.PROGRAM_APPLICATION_ID),
			 NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),x_aehv_rec.PROGRAM_ID),
			 DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,x_aehv_rec.PROGRAM_UPDATE_DATE,SYSDATE)
	  INTO  x_aehv_rec.REQUEST_ID
	  	     ,x_aehv_rec.PROGRAM_APPLICATION_ID
		     ,x_aehv_rec.PROGRAM_ID
		     ,x_aehv_rec.PROGRAM_UPDATE_DATE
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
      p_aehv_rec,                        -- IN
      l_aehv_rec);                       -- OUT
	    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aehv_rec, l_def_aehv_rec);
	 IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_aehv_rec := fill_who_columns(l_def_aehv_rec);

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aehv_rec);
	--- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aehv_rec);
	IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aehv_rec, l_aeh_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aeh_rec,
      lx_aeh_rec
    );
	IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aeh_rec, l_def_aehv_rec);
    x_aehv_rec := l_def_aehv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL update_row for:AEHV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type,
    x_aehv_tbl                     OUT NOCOPY aehv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aehv_tbl.COUNT > 0) THEN
      i := p_aehv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aehv_rec                     => p_aehv_tbl(i),
          x_aehv_rec                     => x_aehv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_aehv_tbl.LAST);
        i := p_aehv_tbl.NEXT(i);
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -----------------------------------
  -- delete_row for:OKL_AE_HEADERS --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aeh_rec                      IN aeh_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'HEADERS_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aeh_rec                      aeh_rec_type:= p_aeh_rec;
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
    DELETE FROM OKL_AE_HEADERS
     WHERE AE_HEADER_ID  = l_aeh_rec.AE_HEADER_ID ;

    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -------------------------------------
  -- delete_row for:OKL_AE_HEADERS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aehv_rec                     aehv_rec_type := p_aehv_rec;
    l_aeh_rec                      aeh_rec_type;
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
    migrate(l_aehv_rec, l_aeh_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aeh_rec
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL delete_row for:AEHV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aehv_tbl.COUNT > 0) THEN
      i := p_aehv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aehv_rec                     => p_aehv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_aehv_tbl.LAST);
        i := p_aehv_tbl.NEXT(i);
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
END Okl_Aeh_Pvt;

/
