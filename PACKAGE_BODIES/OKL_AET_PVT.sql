--------------------------------------------------------
--  DDL for Package Body OKL_AET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AET_PVT" AS
/* $Header: OKLSAETB.pls 120.3 2006/07/13 12:50:34 adagur noship $ */
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
  -- FUNCTION get_rec for: OKL_ACCOUNTING_EVENTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aet_rec                      IN aet_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aet_rec_type IS
    CURSOR okl_accounting_events_pk_csr (p_accounting_event_id     IN NUMBER) IS
    SELECT
            accounting_event_id,
            ORG_ID,
            EVENT_TYPE_CODE,
            ACCOUNTING_DATE,
            EVENT_NUMBER,
            EVENT_STATUS_CODE,
            SOURCE_ID,
            SOURCE_TABLE,
            OBJECT_VERSION_NUMBER,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Accounting_Events
     WHERE okl_accounting_events.accounting_event_id = p_accounting_event_id;
    l_okl_accounting_events_pk     okl_accounting_events_pk_csr%ROWTYPE;
    l_aet_rec                      aet_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_accounting_events_pk_csr (p_aet_rec.accounting_event_id);
    FETCH okl_accounting_events_pk_csr INTO
              l_aet_rec.accounting_event_id,
              l_aet_rec.ORG_ID,
              l_aet_rec.EVENT_TYPE_CODE,
              l_aet_rec.ACCOUNTING_DATE,
              l_aet_rec.EVENT_NUMBER,
              l_aet_rec.EVENT_STATUS_CODE,
              l_aet_rec.SOURCE_ID,
              l_aet_rec.SOURCE_TABLE,
              l_aet_rec.OBJECT_VERSION_NUMBER,
              l_aet_rec.PROGRAM_ID,
              l_aet_rec.PROGRAM_APPLICATION_ID,
              l_aet_rec.PROGRAM_UPDATE_DATE,
              l_aet_rec.REQUEST_ID,
              l_aet_rec.CREATED_BY,
              l_aet_rec.CREATION_DATE,
              l_aet_rec.LAST_UPDATED_BY,
              l_aet_rec.LAST_UPDATE_DATE,
              l_aet_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_accounting_events_pk_csr%NOTFOUND;
    CLOSE okl_accounting_events_pk_csr;
    RETURN(l_aet_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aet_rec                      IN aet_rec_type
  ) RETURN aet_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aet_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ACCOUNTING_EVENTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aetv_rec                     IN aetv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aetv_rec_type IS
    CURSOR okl_aetv_pk_csr (p_accounting_event_id                 IN NUMBER) IS
    SELECT
            accounting_event_id,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            EVENT_TYPE_CODE,
            ACCOUNTING_DATE,
            EVENT_NUMBER,
            EVENT_STATUS_CODE,
            SOURCE_ID,
            SOURCE_TABLE,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_ACCOUNTING_EVENTS
     WHERE OKL_ACCOUNTING_EVENTS.accounting_event_id = p_accounting_event_id;
    l_okl_aetv_pk                  okl_aetv_pk_csr%ROWTYPE;
    l_aetv_rec                     aetv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_aetv_pk_csr (p_aetv_rec.accounting_event_id);
    FETCH okl_aetv_pk_csr INTO
              l_aetv_rec.accounting_event_id,
              l_aetv_rec.OBJECT_VERSION_NUMBER,
              l_aetv_rec.ORG_ID,
              l_aetv_rec.EVENT_TYPE_CODE,
              l_aetv_rec.ACCOUNTING_DATE,
              l_aetv_rec.EVENT_NUMBER,
              l_aetv_rec.EVENT_STATUS_CODE,
              l_aetv_rec.SOURCE_ID,
              l_aetv_rec.SOURCE_TABLE,
              l_aetv_rec.PROGRAM_ID,
              l_aetv_rec.PROGRAM_APPLICATION_ID,
              l_aetv_rec.PROGRAM_UPDATE_DATE,
              l_aetv_rec.REQUEST_ID,
              l_aetv_rec.CREATED_BY,
              l_aetv_rec.CREATION_DATE,
              l_aetv_rec.LAST_UPDATED_BY,
              l_aetv_rec.LAST_UPDATE_DATE,
              l_aetv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_aetv_pk_csr%NOTFOUND;
    CLOSE okl_aetv_pk_csr;
    RETURN(l_aetv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aetv_rec                     IN aetv_rec_type
  ) RETURN aetv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aetv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_ACCOUNTING_EVENTS_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_aetv_rec	IN aetv_rec_type
  ) RETURN aetv_rec_type IS
    l_aetv_rec	aetv_rec_type := p_aetv_rec;
  BEGIN
    IF (l_aetv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_aetv_rec.object_version_number := NULL;
    END IF;
    IF (l_aetv_rec.org_id = Okc_Api.G_MISS_NUM) THEN
      l_aetv_rec.org_id := NULL;
    END IF;
    IF (l_aetv_rec.event_type_code = Okc_Api.G_MISS_CHAR) THEN
      l_aetv_rec.event_type_code := NULL;
    END IF;
    IF (l_aetv_rec.accounting_date = Okc_Api.G_MISS_DATE) THEN
      l_aetv_rec.accounting_date := NULL;
    END IF;
    IF (l_aetv_rec.event_number = Okc_Api.G_MISS_NUM) THEN
      l_aetv_rec.event_number := NULL;
    END IF;
    IF (l_aetv_rec.event_status_code = Okc_Api.G_MISS_CHAR) THEN
      l_aetv_rec.event_status_code := NULL;
    END IF;
    IF (l_aetv_rec.source_id = Okc_Api.G_MISS_NUM) THEN
      l_aetv_rec.source_id := NULL;
    END IF;
    IF (l_aetv_rec.source_table = Okc_Api.G_MISS_CHAR) THEN
      l_aetv_rec.source_table := NULL;
    END IF;
    IF (l_aetv_rec.program_id = Okc_Api.G_MISS_NUM) THEN
      l_aetv_rec.program_id := NULL;
    END IF;
    IF (l_aetv_rec.program_application_id = Okc_Api.G_MISS_NUM) THEN
      l_aetv_rec.program_application_id := NULL;
    END IF;
    IF (l_aetv_rec.program_update_date = Okc_Api.G_MISS_DATE) THEN
      l_aetv_rec.program_update_date := NULL;
    END IF;
    IF (l_aetv_rec.request_id = Okc_Api.G_MISS_NUM) THEN
      l_aetv_rec.request_id := NULL;
    END IF;
    IF (l_aetv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_aetv_rec.created_by := NULL;
    END IF;
    IF (l_aetv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_aetv_rec.creation_date := NULL;
    END IF;
    IF (l_aetv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_aetv_rec.last_updated_by := NULL;
    END IF;
    IF (l_aetv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_aetv_rec.last_update_date := NULL;
    END IF;
    IF (l_aetv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_aetv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_aetv_rec);
  END null_out_defaults;

/**** Commenting out nocopy generated code in favour of hand written code ********
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKL_ACCOUNTING_EVENTS_V --
  -----------------------------------------------------
  Function Validate_Attributes (
    p_aetv_rec IN  aetv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    IF p_aetv_rec.accounting_event_id = Okc_Api.G_MISS_NUM OR
       p_aetv_rec.accounting_event_id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aetv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
          p_aetv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aetv_rec.event_type_code = Okc_Api.G_MISS_CHAR OR
          p_aetv_rec.event_type_code IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'event_type_code');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aetv_rec.accounting_date = Okc_Api.G_MISS_DATE OR
          p_aetv_rec.accounting_date IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'accounting_date');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aetv_rec.event_number = Okc_Api.G_MISS_NUM OR
          p_aetv_rec.event_number IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'event_number');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aetv_rec.event_status_code = Okc_Api.G_MISS_CHAR OR
          p_aetv_rec.event_status_code IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'event_status_code');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aetv_rec.source_id = Okc_Api.G_MISS_NUM OR
          p_aetv_rec.source_id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'source_id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_aetv_rec.source_table = Okc_Api.G_MISS_CHAR OR
          p_aetv_rec.source_table IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'source_table');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  **************** End Commenting generated code ***************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKL_ACCOUNTING_EVENTS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_aetv_rec IN aetv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;


  /*************************** Hand Coded **********************************/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_accounting_event_id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_accounting_event_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_accounting_event_id (x_return_status OUT NOCOPY  VARCHAR2
  						,p_aetv_rec      IN   aetv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_aetv_rec.accounting_event_id IS NULL) OR
       (p_aetv_rec.accounting_event_id = Okc_Api.G_MISS_NUM) THEN
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

  END Validate_accounting_event_id;

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
  										  ,p_aetv_rec      IN   aetv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_aetv_rec.object_version_number IS NULL) OR
       (p_aetv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
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
  -- PROCEDURE Validate_event_type_code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_event_type_code
  -- Description     : Checks if code exists in FND_COMMON_LOOKUPS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE Validate_event_type_code(
     	x_return_status  OUT NOCOPY VARCHAR2
	,p_aetv_rec          IN aetv_rec_type ) IS

	l_dummy		VARCHAR2(1);

    BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_aetv_rec.event_type_code IS NULL) OR
       (p_aetv_rec.event_type_code = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'event_type_code');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
	l_dummy
          := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(
                      p_lookup_type => 'OKL_ACCOUNTING_EVENT_TYPE',
                      p_lookup_code => p_aetv_rec.event_type_code);


	  IF l_dummy = OKC_API.G_FALSE THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'event_type_code');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;
    END IF;

   EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
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
    END Validate_event_type_code;

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
  PROCEDURE Validate_Accounting_Date(x_return_status OUT NOCOPY  VARCHAR2
  							,p_aetv_rec      IN   aetv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_aetv_rec.accounting_date IS NULL) OR
       (p_aetv_rec.accounting_date = Okc_Api.G_MISS_DATE) THEN
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
  -- PROCEDURE Validate_Event_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Event_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Event_Number(x_return_status OUT NOCOPY  VARCHAR2
  								,p_aetv_rec      IN   aetv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_aetv_rec.event_number IS NULL) OR
       (p_aetv_rec.event_number = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'event_number');
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

  END Validate_Event_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Event_Status_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Event_Status_Code
  -- Description     : Checks if code exists in FND_LOOKUPS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE Validate_Event_Status_Code(
     	x_return_status 	OUT NOCOPY VARCHAR2
	   ,p_aetv_rec          IN aetv_rec_type ) IS

	l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
	l_dummy		        VARCHAR2(1) ;

    BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_aetv_rec.event_status_code IS NULL) OR
       (p_aetv_rec.event_status_code = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'event_status_code');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       l_dummy
        := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(
                    p_lookup_type => 'OKL_ACCOUNTING_EVENT_STATUS',
                    p_lookup_code => p_aetv_rec.event_status_code);

	  IF l_dummy = OKC_API.G_FALSE THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'event_status_code');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;
    END IF;

   EXCEPTION
		WHEN G_EXCEPTION_HALT_VALIDATION THEN
    		-- no processing necessary;  validation can continue
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
    END Validate_Event_Status_Code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Source_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Source_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Source_Id_Tbl(x_return_status OUT NOCOPY  VARCHAR2
  					,p_aetv_rec      IN   aetv_rec_type )
  IS


   l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
   l_dummy VARCHAR2(1) ;

  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF (p_aetv_rec.source_id IS NULL) OR
       (p_aetv_rec.source_id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'source_id');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
    END IF;

    IF (p_aetv_rec.source_table IS NULL) OR
       (p_aetv_rec.source_table = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'source_table');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
    END IF;

    IF (x_return_Status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       l_dummy
        := OKL_ACCOUNTING_UTIL.VALIDATE_SOURCE_ID_TABLE(p_source_id => p_aetv_rec.source_id,
                                                        p_source_table => p_aetv_rec.source_table);
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
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN NO_DATA_FOUND THEN
         Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                       	     p_msg_name     => g_invalid_value,
                             p_token1       => g_col_name_token,
                             p_token1_value => 'source_id');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;

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

  END Validate_Source_Id_Tbl;

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
    p_aetv_rec IN  aetv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN

     -- call each column-level validation
    -- Validate_accounting_event_id
    Validate_accounting_event_id(x_return_status,p_aetv_rec);
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(x_return_status,p_aetv_rec);
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_event_type_code
    Validate_event_type_code(x_return_status,p_aetv_rec);
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_Accounting_Date
       Validate_Accounting_Date(x_return_status,p_aetv_rec);
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_Event_Number
       Validate_Event_Number(x_return_status,p_aetv_rec);
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_Event_Status_Code
       Validate_Event_Status_Code(x_return_status,p_aetv_rec);
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_Source_Id_Tbl
       Validate_Source_Id_tbl(x_return_status,p_aetv_rec);
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
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


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN aetv_rec_type,
    p_to IN OUT NOCOPY aet_rec_type
  ) IS
  BEGIN
    p_to.accounting_event_id := p_from.accounting_event_id;
    p_to.org_id := p_from.org_id;
    p_to.event_type_code := p_from.event_type_code;
    p_to.accounting_date := p_from.accounting_date;
    p_to.event_number := p_from.event_number;
    p_to.event_status_code := p_from.event_status_code;
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    p_to.object_version_number := p_from.object_version_number;
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
    p_from	IN aet_rec_type,
    p_to IN OUT NOCOPY aetv_rec_type
  ) IS
  BEGIN
    p_to.accounting_event_id := p_from.accounting_event_id;
    p_to.org_id := p_from.org_id;
    p_to.event_type_code := p_from.event_type_code;
    p_to.accounting_date := p_from.accounting_date;
    p_to.event_number := p_from.event_number;
    p_to.event_status_code := p_from.event_status_code;
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    p_to.object_version_number := p_from.object_version_number;
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
  ----------------------------------------------
  -- validate_row for:OKL_ACCOUNTING_EVENTS_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_rec                     IN aetv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aetv_rec                     aetv_rec_type := p_aetv_rec;
    l_aet_rec                      aet_rec_type;
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
    l_return_status := Validate_Attributes(l_aetv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_aetv_rec);
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
  -- PL/SQL TBL validate_row for:AETV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_tbl                     IN aetv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status 			   VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aetv_tbl.COUNT > 0) THEN
      i := p_aetv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aetv_rec                     => p_aetv_tbl(i));
  		IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	  IF (x_return_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      	    l_overall_status := x_return_status;
    	  END IF;
  		END IF;

        EXIT WHEN (i = p_aetv_tbl.LAST);
        i := p_aetv_tbl.NEXT(i);
      END LOOP;
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
  ------------------------------------------
  -- insert_row for:OKL_ACCOUNTING_EVENTS --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aet_rec                      IN aet_rec_type,
    x_aet_rec                      OUT NOCOPY aet_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'EVENTS_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aet_rec                      aet_rec_type := p_aet_rec;
    l_def_aet_rec                  aet_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_ACCOUNTING_EVENTS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_aet_rec IN  aet_rec_type,
      x_aet_rec OUT NOCOPY aet_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aet_rec := p_aet_rec;
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
      p_aet_rec,                         -- IN
      l_aet_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_ACCOUNTING_EVENTS(
        accounting_event_id,
        org_id,
        event_type_code,
        accounting_date,
        event_number,
        event_status_code,
        source_id,
        source_table,
        object_version_number,
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
        l_aet_rec.accounting_event_id,
        l_aet_rec.org_id,
        l_aet_rec.event_type_code,
        l_aet_rec.accounting_date,
        l_aet_rec.event_number,
        l_aet_rec.event_status_code,
        l_aet_rec.source_id,
        l_aet_rec.source_table,
        l_aet_rec.object_version_number,
        l_aet_rec.program_id,
        l_aet_rec.program_application_id,
        l_aet_rec.program_update_date,
        l_aet_rec.request_id,
        l_aet_rec.created_by,
        l_aet_rec.creation_date,
        l_aet_rec.last_updated_by,
        l_aet_rec.last_update_date,
        l_aet_rec.last_update_login);
    -- Set OUT values
    x_aet_rec := l_aet_rec;
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
  --------------------------------------------
  -- insert_row for:OKL_ACCOUNTING_EVENTS_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_rec                     IN aetv_rec_type,
    x_aetv_rec                     OUT NOCOPY aetv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aetv_rec                     aetv_rec_type;
    l_def_aetv_rec                 aetv_rec_type;
    l_aet_rec                      aet_rec_type;
    lx_aet_rec                     aet_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aetv_rec	IN aetv_rec_type
    ) RETURN aetv_rec_type IS
      l_aetv_rec	aetv_rec_type := p_aetv_rec;
    BEGIN
      l_aetv_rec.CREATION_DATE := SYSDATE;
      l_aetv_rec.CREATED_BY := Fnd_Global.User_Id;
      l_aetv_rec.LAST_UPDATE_DATE := l_aetv_rec.CREATION_DATE ;
      l_aetv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_aetv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_aetv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKL_ACCOUNTING_EVENTS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_aetv_rec IN  aetv_rec_type,
      x_aetv_rec OUT NOCOPY aetv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aetv_rec := p_aetv_rec;
      x_aetv_rec.OBJECT_VERSION_NUMBER := 1;

      x_aetv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();

	  SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
	  		 DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
			 DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
			 DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
	    INTO  x_aetv_rec.REQUEST_ID
	  	     ,x_aetv_rec.PROGRAM_APPLICATION_ID
		     ,x_aetv_rec.PROGRAM_ID
		     ,x_aetv_rec.PROGRAM_UPDATE_DATE
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
    l_aetv_rec := null_out_defaults(p_aetv_rec);
    -- Set primary key value
    l_aetv_rec.accounting_event_id := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_aetv_rec,                        -- IN
      l_def_aetv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_aetv_rec := fill_who_columns(l_def_aetv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aetv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aetv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aetv_rec, l_aet_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aet_rec,
      lx_aet_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	  RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_aet_rec, l_def_aetv_rec);
    -- Set OUT values
    x_aetv_rec := l_def_aetv_rec;
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
  -- PL/SQL TBL insert_row for:AETV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_tbl                     IN aetv_tbl_type,
    x_aetv_tbl                     OUT NOCOPY aetv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aetv_tbl.COUNT > 0) THEN
      i := p_aetv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aetv_rec                     => p_aetv_tbl(i),
          x_aetv_rec                     => x_aetv_tbl(i));

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              l_overall_status := x_return_status;
          END IF;
       END IF;

        EXIT WHEN (i = p_aetv_tbl.LAST);
        i := p_aetv_tbl.NEXT(i);
      END LOOP;

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

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- lock_row for:OKL_ACCOUNTING_EVENTS --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aet_rec                      IN aet_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_aet_rec IN aet_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ACCOUNTING_EVENTS
     WHERE accounting_event_id = p_aet_rec.accounting_event_id
       AND OBJECT_VERSION_NUMBER = p_aet_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_aet_rec IN aet_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ACCOUNTING_EVENTS
    WHERE accounting_event_id = p_aet_rec.accounting_event_id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'EVENTS_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_ACCOUNTING_EVENTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_ACCOUNTING_EVENTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_aet_rec);
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
      OPEN lchk_csr(p_aet_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_aet_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_aet_rec.object_version_number THEN
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
  ------------------------------------------
  -- lock_row for:OKL_ACCOUNTING_EVENTS_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_rec                     IN aetv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aet_rec                      aet_rec_type;
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
    migrate(p_aetv_rec, l_aet_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aet_rec
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
  -- PL/SQL TBL lock_row for:AETV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_tbl                     IN aetv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status 			   VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aetv_tbl.COUNT > 0) THEN
      i := p_aetv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aetv_rec                     => p_aetv_tbl(i));
  		IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	  IF (x_return_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      	    l_overall_status := x_return_status;
    	  END IF;
  		END IF;

        EXIT WHEN (i = p_aetv_tbl.LAST);
        i := p_aetv_tbl.NEXT(i);
      END LOOP;
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
  ------------------------------------------
  -- update_row for:OKL_ACCOUNTING_EVENTS --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aet_rec                      IN aet_rec_type,
    x_aet_rec                      OUT NOCOPY aet_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'EVENTS_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aet_rec                      aet_rec_type := p_aet_rec;
    l_def_aet_rec                  aet_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aet_rec	IN aet_rec_type,
      x_aet_rec	OUT NOCOPY aet_rec_type
    ) RETURN VARCHAR2 IS
      l_aet_rec                      aet_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aet_rec := p_aet_rec;
      -- Get current database values
      l_aet_rec := get_rec(p_aet_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aet_rec.accounting_event_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aet_rec.accounting_event_id := l_aet_rec.accounting_event_id;
      END IF;
      IF (x_aet_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aet_rec.org_id := l_aet_rec.org_id;
      END IF;
      IF (x_aet_rec.event_type_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_aet_rec.event_type_code := l_aet_rec.event_type_code;
      END IF;
      IF (x_aet_rec.accounting_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aet_rec.accounting_date := l_aet_rec.accounting_date;
      END IF;
      IF (x_aet_rec.event_number = Okc_Api.G_MISS_NUM)
      THEN
        x_aet_rec.event_number := l_aet_rec.event_number;
      END IF;
      IF (x_aet_rec.event_status_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_aet_rec.event_status_code := l_aet_rec.event_status_code;
      END IF;
      IF (x_aet_rec.source_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aet_rec.source_id := l_aet_rec.source_id;
      END IF;
      IF (x_aet_rec.source_table = Okc_Api.G_MISS_CHAR)
      THEN
        x_aet_rec.source_table := l_aet_rec.source_table;
      END IF;
      IF (x_aet_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_aet_rec.object_version_number := l_aet_rec.object_version_number;
      END IF;
      IF (x_aet_rec.program_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aet_rec.program_id := l_aet_rec.program_id;
      END IF;
      IF (x_aet_rec.program_application_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aet_rec.program_application_id := l_aet_rec.program_application_id;
      END IF;
      IF (x_aet_rec.program_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aet_rec.program_update_date := l_aet_rec.program_update_date;
      END IF;
      IF (x_aet_rec.request_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aet_rec.request_id := l_aet_rec.request_id;
      END IF;
      IF (x_aet_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aet_rec.created_by := l_aet_rec.created_by;
      END IF;
      IF (x_aet_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aet_rec.creation_date := l_aet_rec.creation_date;
      END IF;
      IF (x_aet_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aet_rec.last_updated_by := l_aet_rec.last_updated_by;
      END IF;
      IF (x_aet_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aet_rec.last_update_date := l_aet_rec.last_update_date;
      END IF;
      IF (x_aet_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_aet_rec.last_update_login := l_aet_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_ACCOUNTING_EVENTS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_aet_rec IN  aet_rec_type,
      x_aet_rec OUT NOCOPY aet_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aet_rec := p_aet_rec;
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
      p_aet_rec,                         -- IN
      l_aet_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aet_rec, l_def_aet_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_ACCOUNTING_EVENTS
    SET ORG_ID = l_def_aet_rec.org_id,
        EVENT_TYPE_CODE = l_def_aet_rec.event_type_code,
        ACCOUNTING_DATE = l_def_aet_rec.accounting_date,
        EVENT_NUMBER = l_def_aet_rec.event_number,
        EVENT_STATUS_CODE = l_def_aet_rec.event_status_code,
        SOURCE_ID = l_def_aet_rec.source_id,
        SOURCE_TABLE = l_def_aet_rec.source_table,
        OBJECT_VERSION_NUMBER = l_def_aet_rec.object_version_number,
        PROGRAM_ID = l_def_aet_rec.program_id,
        PROGRAM_APPLICATION_ID = l_def_aet_rec.program_application_id,
        PROGRAM_UPDATE_DATE = l_def_aet_rec.program_update_date,
        REQUEST_ID = l_def_aet_rec.request_id,
        CREATED_BY = l_def_aet_rec.created_by,
        CREATION_DATE = l_def_aet_rec.creation_date,
        LAST_UPDATED_BY = l_def_aet_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_aet_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_aet_rec.last_update_login
    WHERE accounting_event_id = l_def_aet_rec.accounting_event_id;

    x_aet_rec := l_def_aet_rec;
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
  --------------------------------------------
  -- update_row for:OKL_ACCOUNTING_EVENTS_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_rec                     IN aetv_rec_type,
    x_aetv_rec                     OUT NOCOPY aetv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aetv_rec                     aetv_rec_type := p_aetv_rec;
    l_def_aetv_rec                 aetv_rec_type;
    l_aet_rec                      aet_rec_type;
    lx_aet_rec                     aet_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aetv_rec	IN aetv_rec_type
    ) RETURN aetv_rec_type IS
      l_aetv_rec	aetv_rec_type := p_aetv_rec;
    BEGIN
      l_aetv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aetv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_aetv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_aetv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aetv_rec	IN aetv_rec_type,
      x_aetv_rec	OUT NOCOPY aetv_rec_type
    ) RETURN VARCHAR2 IS
      l_aetv_rec                     aetv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aetv_rec := p_aetv_rec;
      -- Get current database values
      l_aetv_rec := get_rec(p_aetv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aetv_rec.accounting_event_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aetv_rec.accounting_event_id := l_aetv_rec.accounting_event_id;
      END IF;
      IF (x_aetv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_aetv_rec.object_version_number := l_aetv_rec.object_version_number;
      END IF;
      IF (x_aetv_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aetv_rec.org_id := l_aetv_rec.org_id;
      END IF;
      IF (x_aetv_rec.event_type_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_aetv_rec.event_type_code := l_aetv_rec.event_type_code;
      END IF;
      IF (x_aetv_rec.accounting_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aetv_rec.accounting_date := l_aetv_rec.accounting_date;
      END IF;
      IF (x_aetv_rec.event_number = Okc_Api.G_MISS_NUM)
      THEN
        x_aetv_rec.event_number := l_aetv_rec.event_number;
      END IF;
      IF (x_aetv_rec.event_status_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_aetv_rec.event_status_code := l_aetv_rec.event_status_code;
      END IF;
      IF (x_aetv_rec.source_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aetv_rec.source_id := l_aetv_rec.source_id;
      END IF;
      IF (x_aetv_rec.source_table = Okc_Api.G_MISS_CHAR)
      THEN
        x_aetv_rec.source_table := l_aetv_rec.source_table;
      END IF;
      IF (x_aetv_rec.program_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aetv_rec.program_id := l_aetv_rec.program_id;
      END IF;
      IF (x_aetv_rec.program_application_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aetv_rec.program_application_id := l_aetv_rec.program_application_id;
      END IF;
      IF (x_aetv_rec.program_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aetv_rec.program_update_date := l_aetv_rec.program_update_date;
      END IF;
      IF (x_aetv_rec.request_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aetv_rec.request_id := l_aetv_rec.request_id;
      END IF;
      IF (x_aetv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aetv_rec.created_by := l_aetv_rec.created_by;
      END IF;
      IF (x_aetv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aetv_rec.creation_date := l_aetv_rec.creation_date;
      END IF;
      IF (x_aetv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aetv_rec.last_updated_by := l_aetv_rec.last_updated_by;
      END IF;
      IF (x_aetv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aetv_rec.last_update_date := l_aetv_rec.last_update_date;
      END IF;
      IF (x_aetv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_aetv_rec.last_update_login := l_aetv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKL_ACCOUNTING_EVENTS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_aetv_rec IN  aetv_rec_type,
      x_aetv_rec OUT NOCOPY aetv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aetv_rec := p_aetv_rec;

	  SELECT  NVL(DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID)
	  			 ,p_aetv_rec.REQUEST_ID)
			 ,NVL(DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID)
	  			 ,p_aetv_rec.PROGRAM_APPLICATION_ID)
			 ,NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID)
	  		 	 ,p_aetv_rec.PROGRAM_ID)
			 ,DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
	  		 	 ,NULL,p_aetv_rec.PROGRAM_UPDATE_DATE,SYSDATE)
		INTO x_aetv_rec.REQUEST_ID
			 ,x_aetv_rec.PROGRAM_APPLICATION_ID
			 ,x_aetv_rec.PROGRAM_ID
			 ,x_aetv_rec.PROGRAM_UPDATE_DATE
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
      p_aetv_rec,                        -- IN
      l_aetv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aetv_rec, l_def_aetv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_aetv_rec := fill_who_columns(l_def_aetv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aetv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aetv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aetv_rec, l_aet_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aet_rec,
      lx_aet_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aet_rec, l_def_aetv_rec);
    x_aetv_rec := l_def_aetv_rec;
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
  -- PL/SQL TBL update_row for:AETV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_tbl                     IN aetv_tbl_type,
    x_aetv_tbl                     OUT NOCOPY aetv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status 			   VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aetv_tbl.COUNT > 0) THEN
      i := p_aetv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aetv_rec                     => p_aetv_tbl(i),
          x_aetv_rec                     => x_aetv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                l_overall_status := x_return_status;
            END IF;
          END IF;

        EXIT WHEN (i = p_aetv_tbl.LAST);
        i := p_aetv_tbl.NEXT(i);
      END LOOP;
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
  ------------------------------------------
  -- delete_row for:OKL_ACCOUNTING_EVENTS --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aet_rec                      IN aet_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'EVENTS_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aet_rec                      aet_rec_type:= p_aet_rec;
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
    DELETE FROM OKL_ACCOUNTING_EVENTS
     WHERE accounting_event_id = l_aet_rec.accounting_event_id;

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
  --------------------------------------------
  -- delete_row for:OKL_ACCOUNTING_EVENTS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_rec                     IN aetv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aetv_rec                     aetv_rec_type := p_aetv_rec;
    l_aet_rec                      aet_rec_type;
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
    migrate(l_aetv_rec, l_aet_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aet_rec
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
  -- PL/SQL TBL delete_row for:AETV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_tbl                     IN aetv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status 			   VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aetv_tbl.COUNT > 0) THEN
      i := p_aetv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aetv_rec                     => p_aetv_tbl(i));

  		IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	  IF (x_return_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      	    l_overall_status := x_return_status;
    	  END IF;
  		END IF;

        EXIT WHEN (i = p_aetv_tbl.LAST);
        i := p_aetv_tbl.NEXT(i);

      END LOOP;
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
END Okl_Aet_Pvt;

/
