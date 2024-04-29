--------------------------------------------------------
--  DDL for Package Body OKL_BKT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BKT_PVT" AS
/* $Header: OKLSBKTB.pls 115.11 2002/12/18 12:55:34 kjinger noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  Function get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  Procedure qc IS
  BEGIN
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  Procedure change_version IS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  Procedure api_copy IS
  BEGIN
    NULL;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_BUCKETS
  ---------------------------------------------------------------------------
  Function get_rec (
    p_bkt_rec                      IN bkt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bkt_rec_type IS
    CURSOR okl_buckets_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            IBC_ID,
            VERSION,
            LOSS_RATE,
            OBJECT_VERSION_NUMBER,
            COMMENTS,
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            START_DATE,
			END_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Buckets
     WHERE okl_buckets.id       = p_id;
    l_okl_buckets_pk               okl_buckets_pk_csr%ROWTYPE;
    l_bkt_rec                      bkt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_buckets_pk_csr (p_bkt_rec.id);
    FETCH okl_buckets_pk_csr INTO
              l_bkt_rec.ID,
              l_bkt_rec.IBC_ID,
              l_bkt_rec.VERSION,
              l_bkt_rec.LOSS_RATE,
              l_bkt_rec.OBJECT_VERSION_NUMBER,
              l_bkt_rec.COMMENTS,
              l_bkt_rec.PROGRAM_ID,
              l_bkt_rec.REQUEST_ID,
              l_bkt_rec.PROGRAM_APPLICATION_ID,
              l_bkt_rec.PROGRAM_UPDATE_DATE,
              l_bkt_rec.START_DATE,
              l_bkt_rec.END_DATE,
              l_bkt_rec.CREATED_BY,
              l_bkt_rec.CREATION_DATE,
              l_bkt_rec.LAST_UPDATED_BY,
              l_bkt_rec.LAST_UPDATE_DATE,
              l_bkt_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_buckets_pk_csr%NOTFOUND;
    CLOSE okl_buckets_pk_csr;
    RETURN(l_bkt_rec);
  END get_rec;

  Function get_rec (
    p_bkt_rec                      IN bkt_rec_type
  ) RETURN bkt_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bkt_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_BUCKETS_V
  ---------------------------------------------------------------------------
  Function get_rec (
    p_bktv_rec                     IN bktv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bktv_rec_type IS
    CURSOR okl_bktv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            IBC_ID,
            VERSION,
            COMMENTS,
            LOSS_RATE,
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            START_DATE,
			END_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Buckets_V
     WHERE okl_buckets_v.id     = p_id;
    l_okl_bktv_pk                  okl_bktv_pk_csr%ROWTYPE;
    l_bktv_rec                     bktv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_bktv_pk_csr (p_bktv_rec.id);
    FETCH okl_bktv_pk_csr INTO
              l_bktv_rec.ID,
              l_bktv_rec.OBJECT_VERSION_NUMBER,
              l_bktv_rec.IBC_ID,
              l_bktv_rec.VERSION,
              l_bktv_rec.COMMENTS,
              l_bktv_rec.LOSS_RATE,
              l_bktv_rec.PROGRAM_ID,
              l_bktv_rec.REQUEST_ID,
              l_bktv_rec.PROGRAM_APPLICATION_ID,
              l_bktv_rec.PROGRAM_UPDATE_DATE,
              l_bktv_rec.START_DATE,
              l_bktv_rec.END_DATE,
              l_bktv_rec.CREATED_BY,
              l_bktv_rec.CREATION_DATE,
              l_bktv_rec.LAST_UPDATED_BY,
              l_bktv_rec.LAST_UPDATE_DATE,
              l_bktv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_bktv_pk_csr%NOTFOUND;
    CLOSE okl_bktv_pk_csr;
    RETURN(l_bktv_rec);
  END get_rec;

  Function get_rec (
    p_bktv_rec                     IN bktv_rec_type
  ) RETURN bktv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bktv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_BUCKETS_V --
  ---------------------------------------------------
  Function null_out_defaults (
    p_bktv_rec	IN bktv_rec_type
  ) RETURN bktv_rec_type IS
    l_bktv_rec	bktv_rec_type := p_bktv_rec;
  BEGIN
    IF (l_bktv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_bktv_rec.object_version_number := NULL;
    END IF;
    IF (l_bktv_rec.ibc_id = Okc_Api.G_MISS_NUM) THEN
      l_bktv_rec.ibc_id := NULL;
    END IF;
    IF (l_bktv_rec.version = Okc_Api.G_MISS_CHAR) THEN
      l_bktv_rec.version := NULL;
    END IF;
    IF (l_bktv_rec.comments = Okc_Api.G_MISS_CHAR) THEN
      l_bktv_rec.comments := NULL;
    END IF;
    IF (l_bktv_rec.loss_rate = Okc_Api.G_MISS_NUM) THEN
      l_bktv_rec.loss_rate := NULL;
    END IF;
    IF (l_bktv_rec.start_date = Okc_Api.G_MISS_DATE) THEN
      l_bktv_rec.start_date := NULL;
    END IF;
    IF (l_bktv_rec.end_date = Okc_Api.G_MISS_DATE) THEN
      l_bktv_rec.end_date := NULL;
    END IF;
/***** Concurrent Manager columns should not be nulled out nocopy **********

    IF (l_bktv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_bktv_rec.program_id := NULL;
    END IF;
    IF (l_bktv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_bktv_rec.request_id := NULL;
    END IF;
    IF (l_bktv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_bktv_rec.program_application_id := NULL;
    END IF;
    IF (l_bktv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_bktv_rec.program_update_date := NULL;
    END IF;

*/
    IF (l_bktv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_bktv_rec.created_by := NULL;
    END IF;
    IF (l_bktv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_bktv_rec.creation_date := NULL;
    END IF;
    IF (l_bktv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_bktv_rec.last_updated_by := NULL;
    END IF;
    IF (l_bktv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_bktv_rec.last_update_date := NULL;
    END IF;
    IF (l_bktv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_bktv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_bktv_rec);
  END null_out_defaults;

/**** Commenting out nocopy generated code in favour of hand written code ********
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate_Attributes for:OKL_BUCKETS_V --
  -------------------------------------------
  FUNCTION Validate_Attributes (
    p_bktv_rec IN  bktv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_bktv_rec.id = OKC_API.G_MISS_NUM OR
       p_bktv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bktv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_bktv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bktv_rec.ibc_id = OKC_API.G_MISS_NUM OR
          p_bktv_rec.ibc_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ibc_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bktv_rec.version = OKC_API.G_MISS_CHAR OR
          p_bktv_rec.version IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'version');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bktv_rec.loss_rate = OKC_API.G_MISS_NUM OR
          p_bktv_rec.loss_rate IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'loss_rate');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- Validate_Record for:OKL_BUCKETS_V --
  ---------------------------------------
  FUNCTION Validate_Record (
    p_bktv_rec IN bktv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  **************** End Commenting generated code ***************************/

  /*************************** Hand Coded **********************************/

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
  Procedure Validate_Id (x_return_status OUT NOCOPY  VARCHAR2
  						,p_bktv_rec      IN   bktv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_bktv_rec.id IS NULL) OR
       (p_bktv_rec.id = Okc_Api.G_MISS_NUM) THEN
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
  Procedure Validate_Object_Version_Number(x_return_status OUT NOCOPY  VARCHAR2
  										  ,p_bktv_rec      IN   bktv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_bktv_rec.object_version_number IS NULL) OR
       (p_bktv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
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
  -- PROCEDURE Validate_Ibc_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Ibc_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  Procedure Validate_Ibc_Id (x_return_status OUT NOCOPY  VARCHAR2
  							,p_bktv_rec      IN   bktv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy_var			  VARCHAR2(1)  := '?';

  CURSOR l_ibcid_csr(p_ibc_id OKL_BUCKETS_V.ibc_id%TYPE) IS
	SELECT '1'
	FROM OKX_AGING_BUCKETS_V
	WHERE aging_bucket_line_id = p_ibc_id;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_bktv_rec.ibc_id IS NULL) OR
       (p_bktv_rec.ibc_id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'ibc_id');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


   -- enforce foreign key
   OPEN l_ibcid_csr(p_bktv_rec.ibc_id);
   FETCH l_ibcid_csr	INTO l_dummy_var;
   CLOSE l_ibcid_csr;

   -- if l_dummy_var is still set to default then data was not found
   IF (l_dummy_var = '?') THEN
     Okc_Api.SET_MESSAGE (p_app_name 		 => g_app_name
	 	,p_msg_name		 => g_no_parent_record
		,p_token1			 => g_col_name_token
		,p_token1_value	 => 'ibc_id'
		,p_token2			 => g_child_table_token
		,p_token2_value	 => 'OKL_BUCKETS_V'
		,p_token3			 => g_parent_table_token
		,p_token3_value	 => 'OKX_AGING_BUCKETS_V');

   -- notify caller of an error
   	  x_return_status := Okc_Api.G_RET_STS_ERROR;
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

  END Validate_Ibc_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Version
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Version
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  Procedure Validate_Version(x_return_status OUT NOCOPY  VARCHAR2
  							,p_bktv_rec      IN   bktv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy_var			  VARCHAR2(1)  := '?';

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_bktv_rec.version IS NULL) OR
       (p_bktv_rec.version = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'version');
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

  END Validate_Version;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Loss_Rate
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Loss_Rate
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  Procedure Validate_Loss_Rate(x_return_status OUT NOCOPY  VARCHAR2
  							  ,p_bktv_rec      IN   bktv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_bktv_rec.loss_rate IS NULL) OR
       (p_bktv_rec.loss_rate = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'loss_rate');
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

  END Validate_Loss_Rate;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Start_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Start_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Start_Date(x_return_status OUT NOCOPY  VARCHAR2
  							,p_bktv_rec      IN   bktv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_bktv_rec.start_date IS NULL) OR
       (p_bktv_rec.start_date = Okc_Api.G_MISS_DATE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'start_date');
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

  END Validate_Start_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_End_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_End_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_End_Date(x_return_status OUT NOCOPY  VARCHAR2
  							,p_bktv_rec      IN   bktv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	IF (p_bktv_rec.end_date IS NOT NULL) AND (p_bktv_rec.end_date <> OKC_API.G_MISS_DATE) THEN
	  IF p_bktv_rec.end_date < p_bktv_rec.start_date THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'end_date');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
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

  END Validate_End_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Bkt_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Bkt_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  Procedure Validate_Unique_Bkt_Record(x_return_status OUT NOCOPY  VARCHAR2
  									  ,p_bktv_rec      IN   bktv_rec_type)
  IS

  l_dummy                 VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;

    CURSOR unique_bkt_csr(p_ibc_id okl_buckets_v.ibc_id%TYPE
		  			     ,p_version okl_buckets_v.version%TYPE
						 ,p_id okl_buckets_v.id%TYPE) IS
    SELECT 1
    FROM okl_buckets_v
    WHERE  ibc_id = p_ibc_id
    AND    version = p_version
	AND    id <> p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    OPEN unique_bkt_csr(p_bktv_rec.ibc_id,
		  p_bktv_rec.version, p_bktv_rec.id);
    FETCH unique_bkt_csr INTO l_dummy;
    l_row_found := unique_bkt_csr%FOUND;
    CLOSE unique_bkt_csr;
    IF l_row_found THEN
		Okc_Api.set_message(G_APP_NAME,G_UNQS);
		x_return_status := Okc_Api.G_RET_STS_ERROR;
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

  END Validate_Unique_Bkt_Record;

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

  Function Validate_Attributes (
    p_bktv_rec IN  bktv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN

     -- call each column-level validation

    -- Validate_Id
    Validate_Id(x_return_status, p_bktv_rec );
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
    Validate_Object_Version_Number(x_return_status, p_bktv_rec );
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

    -- Validate_Ibc_Id
    Validate_Ibc_Id(x_return_status, p_bktv_rec );
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

    -- Validate_Version
       Validate_Version(x_return_status, p_bktv_rec );
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

    -- Validate_Loss_Rate
       Validate_Loss_Rate(x_return_status, p_bktv_rec );
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

    -- Validate_Start_Date
       Validate_Start_Date(x_return_status, p_bktv_rec );
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

    -- Validate_End_Date
       Validate_End_Date(x_return_status, p_bktv_rec );
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
  -- FUNCTION Validate_Record
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

  Function Validate_Record (
    p_bktv_rec IN bktv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN

    -- Validate_Unique_Bkt_Record
      Validate_Unique_Bkt_Record(x_return_status, p_bktv_rec );
      -- store the highest degree of error
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
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
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;
    RETURN (l_return_status);

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

  END Validate_Record;

/************************ END HAND CODING **********************************/


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  Procedure migrate (
    p_from	IN bktv_rec_type,
    p_to	IN OUT NOCOPY bkt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ibc_id := p_from.ibc_id;
    p_to.version := p_from.version;
    p_to.loss_rate := p_from.loss_rate;
    p_to.object_version_number := p_from.object_version_number;
    p_to.comments := p_from.comments;
    p_to.program_id := p_from.program_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  Procedure migrate (
    p_from	IN bkt_rec_type,
    p_to	IN OUT NOCOPY bktv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ibc_id := p_from.ibc_id;
    p_to.version := p_from.version;
    p_to.loss_rate := p_from.loss_rate;
    p_to.object_version_number := p_from.object_version_number;
    p_to.comments := p_from.comments;
    p_to.program_id := p_from.program_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- validate_row for:OKL_BUCKETS_V --
  ------------------------------------
  Procedure validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_rec                     IN bktv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_bktv_rec                     bktv_rec_type := p_bktv_rec;
    l_bkt_rec                      bkt_rec_type;
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
    l_return_status := Validate_Attributes(l_bktv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_bktv_rec);
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
  -- PL/SQL TBL validate_row for:BKTV_TBL --
  ------------------------------------------
  Procedure validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN bktv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bktv_tbl.COUNT > 0) THEN
      i := p_bktv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bktv_rec                     => p_bktv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_bktv_tbl.LAST);
        i := p_bktv_tbl.NEXT(i);
      END LOOP;
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
  --------------------------------
  -- insert_row for:OKL_BUCKETS --
  --------------------------------
  Procedure insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bkt_rec                      IN bkt_rec_type,
    x_bkt_rec                      OUT NOCOPY bkt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'BUCKETS_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_bkt_rec                      bkt_rec_type := p_bkt_rec;
    l_def_bkt_rec                  bkt_rec_type;
    ------------------------------------
    -- Set_Attributes for:OKL_BUCKETS --
    ------------------------------------
    Function Set_Attributes (
      p_bkt_rec IN  bkt_rec_type,
      x_bkt_rec OUT NOCOPY bkt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_bkt_rec := p_bkt_rec;
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
      p_bkt_rec,                         -- IN
      l_bkt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_BUCKETS(
        id,
        ibc_id,
        version,
        loss_rate,
        object_version_number,
        comments,
        program_id,
        request_id,
        program_application_id,
        program_update_date,
        start_date,
		end_date,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_bkt_rec.id,
        l_bkt_rec.ibc_id,
        l_bkt_rec.version,
        l_bkt_rec.loss_rate,
        l_bkt_rec.object_version_number,
        l_bkt_rec.comments,
        l_bkt_rec.program_id,
        l_bkt_rec.request_id,
        l_bkt_rec.program_application_id,
        l_bkt_rec.program_update_date,
        l_bkt_rec.start_date,
        l_bkt_rec.end_date,
        l_bkt_rec.created_by,
        l_bkt_rec.creation_date,
        l_bkt_rec.last_updated_by,
        l_bkt_rec.last_update_date,
        l_bkt_rec.last_update_login);
    -- Set OUT values
    x_bkt_rec := l_bkt_rec;
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
  ----------------------------------
  -- insert_row for:OKL_BUCKETS_V --
  ----------------------------------
  Procedure insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_rec                     IN bktv_rec_type,
    x_bktv_rec                     OUT NOCOPY bktv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_bktv_rec                     bktv_rec_type;
    l_def_bktv_rec                 bktv_rec_type;
    l_bkt_rec                      bkt_rec_type;
    lx_bkt_rec                     bkt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    Function fill_who_columns (
      p_bktv_rec	IN bktv_rec_type
    ) RETURN bktv_rec_type IS
      l_bktv_rec	bktv_rec_type := p_bktv_rec;
    BEGIN
      l_bktv_rec.CREATION_DATE := SYSDATE;
      l_bktv_rec.CREATED_BY := Fnd_Global.User_Id;
      l_bktv_rec.LAST_UPDATE_DATE := l_bktv_rec.CREATION_DATE;
      l_bktv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_bktv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_bktv_rec);
    END fill_who_columns;
    --------------------------------------
    -- Set_Attributes for:OKL_BUCKETS_V --
    --------------------------------------
    Function Set_Attributes (
      p_bktv_rec IN  bktv_rec_type,
      x_bktv_rec OUT NOCOPY bktv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_bktv_rec := p_bktv_rec;
      x_bktv_rec.OBJECT_VERSION_NUMBER := 1;

	SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
		DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
		DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
		DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
	INTO  x_bktv_rec.REQUEST_ID
		,x_bktv_rec.PROGRAM_APPLICATION_ID
		,x_bktv_rec.PROGRAM_ID
		,x_bktv_rec.PROGRAM_UPDATE_DATE
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
    l_bktv_rec := null_out_defaults(p_bktv_rec);
    -- Set primary key value
    l_bktv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_bktv_rec,                        -- IN
      l_def_bktv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_bktv_rec := fill_who_columns(l_def_bktv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_bktv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_bktv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_bktv_rec, l_bkt_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bkt_rec,
      lx_bkt_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bkt_rec, l_def_bktv_rec);
    -- Set OUT values
    x_bktv_rec := l_def_bktv_rec;
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
  ----------------------------------------
  -- PL/SQL TBL insert_row for:BKTV_TBL --
  ----------------------------------------
  Procedure insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN bktv_tbl_type,
    x_bktv_tbl                     OUT NOCOPY bktv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bktv_tbl.COUNT > 0) THEN
      i := p_bktv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bktv_rec                     => p_bktv_tbl(i),
          x_bktv_rec                     => x_bktv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_bktv_tbl.LAST);
        i := p_bktv_tbl.NEXT(i);
      END LOOP;
    END IF;
        x_return_status := l_overall_status;

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

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ------------------------------
  -- lock_row for:OKL_BUCKETS --
  ------------------------------
  Procedure lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bkt_rec                      IN bkt_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_bkt_rec IN bkt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_BUCKETS
     WHERE ID = p_bkt_rec.id
       AND OBJECT_VERSION_NUMBER = p_bkt_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_bkt_rec IN bkt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_BUCKETS
    WHERE ID = p_bkt_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'BUCKETS_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_BUCKETS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_BUCKETS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_bkt_rec);
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
      OPEN lchk_csr(p_bkt_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_bkt_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_bkt_rec.object_version_number THEN
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
  --------------------------------
  -- lock_row for:OKL_BUCKETS_V --
  --------------------------------
  Procedure lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_rec                     IN bktv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_bkt_rec                      bkt_rec_type;
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
    migrate(p_bktv_rec, l_bkt_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bkt_rec
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
  -- PL/SQL TBL lock_row for:BKTV_TBL --
  --------------------------------------
  Procedure lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN bktv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bktv_tbl.COUNT > 0) THEN
      i := p_bktv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bktv_rec                     => p_bktv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_bktv_tbl.LAST);
        i := p_bktv_tbl.NEXT(i);
      END LOOP;
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
  --------------------------------
  -- update_row for:OKL_BUCKETS --
  --------------------------------
  Procedure update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bkt_rec                      IN bkt_rec_type,
    x_bkt_rec                      OUT NOCOPY bkt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'BUCKETS_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_bkt_rec                      bkt_rec_type := p_bkt_rec;
    l_def_bkt_rec                  bkt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    Function populate_new_record (
      p_bkt_rec	IN bkt_rec_type,
      x_bkt_rec	OUT NOCOPY bkt_rec_type
    ) RETURN VARCHAR2 IS
      l_bkt_rec                      bkt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_bkt_rec := p_bkt_rec;
      -- Get current database values
      l_bkt_rec := get_rec(p_bkt_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_bkt_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_bkt_rec.id := l_bkt_rec.id;
      END IF;
      IF (x_bkt_rec.ibc_id = Okc_Api.G_MISS_NUM)
      THEN
        x_bkt_rec.ibc_id := l_bkt_rec.ibc_id;
      END IF;
      IF (x_bkt_rec.version = Okc_Api.G_MISS_CHAR)
      THEN
        x_bkt_rec.version := l_bkt_rec.version;
      END IF;
      IF (x_bkt_rec.loss_rate = Okc_Api.G_MISS_NUM)
      THEN
        x_bkt_rec.loss_rate := l_bkt_rec.loss_rate;
      END IF;
      IF (x_bkt_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_bkt_rec.object_version_number := l_bkt_rec.object_version_number;
      END IF;
      IF (x_bkt_rec.comments = Okc_Api.G_MISS_CHAR)
      THEN
        x_bkt_rec.comments := l_bkt_rec.comments;
      END IF;
      IF (x_bkt_rec.program_id = Okc_Api.G_MISS_NUM)
      THEN
        x_bkt_rec.program_id := l_bkt_rec.program_id;
      END IF;
      IF (x_bkt_rec.request_id = Okc_Api.G_MISS_NUM)
      THEN
        x_bkt_rec.request_id := l_bkt_rec.request_id;
      END IF;
      IF (x_bkt_rec.program_application_id = Okc_Api.G_MISS_NUM)
      THEN
        x_bkt_rec.program_application_id := l_bkt_rec.program_application_id;
      END IF;
      IF (x_bkt_rec.program_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_bkt_rec.program_update_date := l_bkt_rec.program_update_date;
      END IF;
      IF (x_bkt_rec.start_date = Okc_Api.G_MISS_DATE)
      THEN
        x_bkt_rec.start_date := l_bkt_rec.start_date;
      END IF;
      IF (x_bkt_rec.end_date = Okc_Api.G_MISS_DATE)
      THEN
        x_bkt_rec.end_date := l_bkt_rec.end_date;
      END IF;
      IF (x_bkt_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_bkt_rec.created_by := l_bkt_rec.created_by;
      END IF;
      IF (x_bkt_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_bkt_rec.creation_date := l_bkt_rec.creation_date;
      END IF;
      IF (x_bkt_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_bkt_rec.last_updated_by := l_bkt_rec.last_updated_by;
      END IF;
      IF (x_bkt_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_bkt_rec.last_update_date := l_bkt_rec.last_update_date;
      END IF;
      IF (x_bkt_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_bkt_rec.last_update_login := l_bkt_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------
    -- Set_Attributes for:OKL_BUCKETS --
    ------------------------------------
    Function Set_Attributes (
      p_bkt_rec IN  bkt_rec_type,
      x_bkt_rec OUT NOCOPY bkt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_bkt_rec := p_bkt_rec;
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
      p_bkt_rec,                         -- IN
      l_bkt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bkt_rec, l_def_bkt_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_BUCKETS
    SET IBC_ID = l_def_bkt_rec.ibc_id,
        VERSION = l_def_bkt_rec.version,
        LOSS_RATE = l_def_bkt_rec.loss_rate,
        OBJECT_VERSION_NUMBER = l_def_bkt_rec.object_version_number,
        COMMENTS = l_def_bkt_rec.comments,
        PROGRAM_ID = l_def_bkt_rec.program_id,
        REQUEST_ID = l_def_bkt_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_bkt_rec.program_application_id,
        PROGRAM_UPDATE_DATE = l_def_bkt_rec.program_update_date,
        START_DATE = l_def_bkt_rec.start_date,
        END_DATE = l_def_bkt_rec.end_date,
        CREATED_BY = l_def_bkt_rec.created_by,
        CREATION_DATE = l_def_bkt_rec.creation_date,
        LAST_UPDATED_BY = l_def_bkt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_bkt_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_bkt_rec.last_update_login
    WHERE ID = l_def_bkt_rec.id;

    x_bkt_rec := l_def_bkt_rec;
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
  ----------------------------------
  -- update_row for:OKL_BUCKETS_V --
  ----------------------------------
  Procedure update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_rec                     IN bktv_rec_type,
    x_bktv_rec                     OUT NOCOPY bktv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_bktv_rec                     bktv_rec_type := p_bktv_rec;
    l_def_bktv_rec                 bktv_rec_type;
    l_bkt_rec                      bkt_rec_type;
    lx_bkt_rec                     bkt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    Function fill_who_columns (
      p_bktv_rec	IN bktv_rec_type
    ) RETURN bktv_rec_type IS
      l_bktv_rec	bktv_rec_type := p_bktv_rec;
    BEGIN
      l_bktv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_bktv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_bktv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_bktv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    Function populate_new_record (
      p_bktv_rec	IN bktv_rec_type,
      x_bktv_rec	OUT NOCOPY bktv_rec_type
    ) RETURN VARCHAR2 IS
      l_bktv_rec                     bktv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_bktv_rec := p_bktv_rec;
      -- Get current database values
      l_bktv_rec := get_rec(p_bktv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_bktv_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_bktv_rec.id := l_bktv_rec.id;
      END IF;
      IF (x_bktv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_bktv_rec.object_version_number := l_bktv_rec.object_version_number;
      END IF;
      IF (x_bktv_rec.ibc_id = Okc_Api.G_MISS_NUM)
      THEN
        x_bktv_rec.ibc_id := l_bktv_rec.ibc_id;
      END IF;
      IF (x_bktv_rec.version = Okc_Api.G_MISS_CHAR)
      THEN
        x_bktv_rec.version := l_bktv_rec.version;
      END IF;
      IF (x_bktv_rec.comments = Okc_Api.G_MISS_CHAR)
      THEN
        x_bktv_rec.comments := l_bktv_rec.comments;
      END IF;
      IF (x_bktv_rec.loss_rate = Okc_Api.G_MISS_NUM)
      THEN
        x_bktv_rec.loss_rate := l_bktv_rec.loss_rate;
      END IF;
      IF (x_bktv_rec.program_id = Okc_Api.G_MISS_NUM)
      THEN
        x_bktv_rec.program_id := l_bktv_rec.program_id;
      END IF;
      IF (x_bktv_rec.request_id = Okc_Api.G_MISS_NUM)
      THEN
        x_bktv_rec.request_id := l_bktv_rec.request_id;
      END IF;
      IF (x_bktv_rec.program_application_id = Okc_Api.G_MISS_NUM)
      THEN
        x_bktv_rec.program_application_id := l_bktv_rec.program_application_id;
      END IF;
      IF (x_bktv_rec.program_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_bktv_rec.program_update_date := l_bktv_rec.program_update_date;
      END IF;
      IF (x_bktv_rec.start_date = Okc_Api.G_MISS_DATE)
      THEN
        x_bktv_rec.start_date := l_bktv_rec.start_date;
      END IF;
      IF (x_bktv_rec.end_date = Okc_Api.G_MISS_DATE)
      THEN
        x_bktv_rec.end_date := l_bktv_rec.end_date;
      END IF;
      IF (x_bktv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_bktv_rec.created_by := l_bktv_rec.created_by;
      END IF;
      IF (x_bktv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_bktv_rec.creation_date := l_bktv_rec.creation_date;
      END IF;
      IF (x_bktv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_bktv_rec.last_updated_by := l_bktv_rec.last_updated_by;
      END IF;
      IF (x_bktv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_bktv_rec.last_update_date := l_bktv_rec.last_update_date;
      END IF;
      IF (x_bktv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_bktv_rec.last_update_login := l_bktv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKL_BUCKETS_V --
    --------------------------------------
    Function Set_Attributes (
      p_bktv_rec IN  bktv_rec_type,
      x_bktv_rec OUT NOCOPY bktv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_bktv_rec := p_bktv_rec;

/***** Concurrent Manager columns assignement  ************/

      SELECT  NVL(DECODE(FND_GLOBAL.conc_request_id, -1, NULL, fnd_global.conc_request_id) ,p_bktv_rec.REQUEST_ID)
    ,NVL(DECODE(fnd_global.prog_appl_id, -1, NULL, fnd_global.prog_appl_id) ,p_bktv_rec.PROGRAM_APPLICATION_ID)
    ,NVL(DECODE(fnd_global.conc_program_id, -1, NULL, fnd_global.conc_program_id)  ,p_bktv_rec.PROGRAM_ID)
    ,DECODE(DECODE(fnd_global.conc_request_id, -1, NULL, SYSDATE) ,NULL, p_bktv_rec.PROGRAM_UPDATE_DATE,SYSDATE)
        INTO x_bktv_rec.REQUEST_ID
    ,x_bktv_rec.PROGRAM_APPLICATION_ID
    ,x_bktv_rec.PROGRAM_ID
    ,x_bktv_rec.PROGRAM_UPDATE_DATE
    FROM DUAL;


/******* END Concurrent Manager COLUMN Assignment ******************/

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
      p_bktv_rec,                        -- IN
      l_bktv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bktv_rec, l_def_bktv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_bktv_rec := fill_who_columns(l_def_bktv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_bktv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_bktv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_bktv_rec, l_bkt_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bkt_rec,
      lx_bkt_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bkt_rec, l_def_bktv_rec);
    x_bktv_rec := l_def_bktv_rec;
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
  -- PL/SQL TBL update_row for:BKTV_TBL --
  ----------------------------------------
  Procedure update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN bktv_tbl_type,
    x_bktv_tbl                     OUT NOCOPY bktv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bktv_tbl.COUNT > 0) THEN
      i := p_bktv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bktv_rec                     => p_bktv_tbl(i),
          x_bktv_rec                     => x_bktv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_bktv_tbl.LAST);
        i := p_bktv_tbl.NEXT(i);
      END LOOP;
    END IF;
        x_return_status := l_overall_status;

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
  --------------------------------
  -- delete_row for:OKL_BUCKETS --
  --------------------------------
  Procedure delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bkt_rec                      IN bkt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'BUCKETS_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_bkt_rec                      bkt_rec_type:= p_bkt_rec;
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
    DELETE FROM OKL_BUCKETS
     WHERE ID = l_bkt_rec.id;

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
  ----------------------------------
  -- delete_row for:OKL_BUCKETS_V --
  ----------------------------------
  Procedure delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_rec                     IN bktv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_bktv_rec                     bktv_rec_type := p_bktv_rec;
    l_bkt_rec                      bkt_rec_type;
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
    migrate(l_bktv_rec, l_bkt_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bkt_rec
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
  -- PL/SQL TBL delete_row for:BKTV_TBL --
  ----------------------------------------
  Procedure delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN bktv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bktv_tbl.COUNT > 0) THEN
      i := p_bktv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bktv_rec                     => p_bktv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_bktv_tbl.LAST);
        i := p_bktv_tbl.NEXT(i);
      END LOOP;
    END IF;
     x_return_status := l_overall_status;

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
END OKL_BKT_PVT;

/
