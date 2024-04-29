--------------------------------------------------------
--  DDL for Package Body OKL_STM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STM_PVT" AS
/* $Header: OKLSSTMB.pls 120.4 2007/12/20 08:59:04 veramach ship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
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
  -- FUNCTION get_rec for: OKL_STREAMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_stm_rec                      IN stm_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN stm_rec_type IS
    CURSOR okl_streams_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            STY_ID,
            KHR_ID,
            KLE_ID,
            SGN_CODE,
            SAY_CODE,
		TRANSACTION_NUMBER,
            ACTIVE_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            DATE_CURRENT,
            DATE_WORKING,
            DATE_HISTORY,
            COMMENTS,
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
	    -- mvasudev, Bug#2650599
	    PURPOSE_CODE,
	    --STY_CODE
	    -- end, mvasudev, Bug#2650599
            stm_id ,
        -- Added by Keerthi for Bug No 3166890
            SOURCE_ID,
            SOURCE_TABLE,
        -- Added by rgooty: 4212626
            TRX_ID,
            LINK_HIST_STREAM_ID
          FROM Okl_Streams
     WHERE okl_streams.id       = p_id;
    l_okl_streams_pk               okl_streams_pk_csr%ROWTYPE;
    l_stm_rec                      stm_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_streams_pk_csr (p_stm_rec.id);
    FETCH okl_streams_pk_csr INTO
              l_stm_rec.ID,
              l_stm_rec.STY_ID,
              l_stm_rec.KHR_ID,
              l_stm_rec.KLE_ID,
              l_stm_rec.SGN_CODE,
              l_stm_rec.SAY_CODE,
              l_stm_rec.TRANSACTION_NUMBER,
              l_stm_rec.ACTIVE_YN,
              l_stm_rec.OBJECT_VERSION_NUMBER,
              l_stm_rec.CREATED_BY,
              l_stm_rec.CREATION_DATE,
              l_stm_rec.LAST_UPDATED_BY,
              l_stm_rec.LAST_UPDATE_DATE,
              l_stm_rec.DATE_CURRENT,
              l_stm_rec.DATE_WORKING,
              l_stm_rec.DATE_HISTORY,
              l_stm_rec.COMMENTS,
              l_stm_rec.PROGRAM_ID,
              l_stm_rec.REQUEST_ID,
              l_stm_rec.PROGRAM_APPLICATION_ID,
              l_stm_rec.PROGRAM_UPDATE_DATE,
              l_stm_rec.LAST_UPDATE_LOGIN,
	      -- mvasudev, Bug#2650599
	        l_stm_rec.PURPOSE_CODE,
            --l_stm_rec.STY_CODE;
	      -- end, mvasudev, Bug#2650599
              l_stm_rec.stm_id,
           -- Added by Keerthi for Bug No 3166890
              l_stm_rec.SOURCE_ID,
              l_stm_rec.SOURCE_TABLE,
              -- Added by rgooty: 4212626
              l_stm_rec.TRX_ID,
              l_stm_rec.LINK_HIST_STREAM_ID;
    x_no_data_found := okl_streams_pk_csr%NOTFOUND;
    CLOSE okl_streams_pk_csr;
    RETURN(l_stm_rec);
  END get_rec;

  FUNCTION get_rec (
    p_stm_rec                      IN stm_rec_type
  ) RETURN stm_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_stm_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_STREAMS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_stmv_rec                     IN stmv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN stmv_rec_type IS
    CURSOR okl_stmv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SGN_CODE,
            SAY_CODE,
            STY_ID,
            KLE_ID,
            KHR_ID,
		TRANSACTION_NUMBER,
            ACTIVE_YN,
            DATE_CURRENT,
            DATE_WORKING,
            DATE_HISTORY,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            -- mvasudev, Bug#2650599
            PURPOSE_CODE,
            --STY_CODE
             -- end, mvasudev, Bug#2650599
            STM_ID,
            -- Added by Keerthi for 3166890
            SOURCE_ID,
            SOURCE_TABLE,
            -- Added by rgooty: 4212626
            TRX_ID,
            LINK_HIST_STREAM_ID
      FROM Okl_Streams_V
     WHERE okl_streams_v.id     = p_id;
    l_okl_stmv_pk                  okl_stmv_pk_csr%ROWTYPE;
    l_stmv_rec                     stmv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_stmv_pk_csr (p_stmv_rec.id);
    FETCH okl_stmv_pk_csr INTO
              l_stmv_rec.ID,
              l_stmv_rec.OBJECT_VERSION_NUMBER,
              l_stmv_rec.SGN_CODE,
              l_stmv_rec.SAY_CODE,
              l_stmv_rec.STY_ID,
              l_stmv_rec.KLE_ID,
              l_stmv_rec.KHR_ID,
              l_stmv_rec.TRANSACTION_NUMBER,
              l_stmv_rec.ACTIVE_YN,
              l_stmv_rec.DATE_CURRENT,
              l_stmv_rec.DATE_WORKING,
              l_stmv_rec.DATE_HISTORY,
              l_stmv_rec.COMMENTS,
              l_stmv_rec.CREATED_BY,
              l_stmv_rec.CREATION_DATE,
              l_stmv_rec.LAST_UPDATED_BY,
              l_stmv_rec.LAST_UPDATE_DATE,
              l_stmv_rec.PROGRAM_ID,
              l_stmv_rec.REQUEST_ID,
              l_stmv_rec.PROGRAM_APPLICATION_ID,
              l_stmv_rec.PROGRAM_UPDATE_DATE,
              l_stmv_rec.LAST_UPDATE_LOGIN,
	      -- mvasudev, Bug#2650599
	        l_stmv_rec.PURPOSE_CODE,
              --l_stmv_rec.STY_CODE;
	      -- end, mvasudev, Bug#2650599
              l_stmv_rec.stm_id,
          -- Added by Keerthi for 3166890
              l_stmv_rec.SOURCE_ID,
              l_stmv_rec.SOURCE_TABLE,
              -- Added by rgooty: 4212626
              l_stmv_rec.TRX_ID,
              l_stmv_rec.LINK_HIST_STREAM_ID;
    x_no_data_found := okl_stmv_pk_csr%NOTFOUND;
    CLOSE okl_stmv_pk_csr;
    RETURN(l_stmv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_stmv_rec                     IN stmv_rec_type
  ) RETURN stmv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_stmv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_STREAMS_V --
  ---------------------------------------------------
  FUNCTION null_out_defaults (
    p_stmv_rec	IN stmv_rec_type
  ) RETURN stmv_rec_type IS
    l_stmv_rec	stmv_rec_type := p_stmv_rec;
  BEGIN
    IF (l_stmv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.object_version_number := NULL;
    END IF;
    IF (l_stmv_rec.sgn_code = OKC_API.G_MISS_CHAR) THEN
      l_stmv_rec.sgn_code := NULL;
    END IF;
    IF (l_stmv_rec.say_code = OKC_API.G_MISS_CHAR) THEN
      l_stmv_rec.say_code := NULL;
    END IF;
    IF (l_stmv_rec.sty_id = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.sty_id := NULL;
    END IF;
    IF (l_stmv_rec.kle_id = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.kle_id := NULL;
    END IF;
    IF (l_stmv_rec.khr_id = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.khr_id := NULL;
    END IF;
    IF (l_stmv_rec.transaction_number = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.transaction_number := NULL;
    END IF;
    IF (l_stmv_rec.active_yn = OKC_API.G_MISS_CHAR) THEN
      l_stmv_rec.active_yn := NULL;
    END IF;
    IF (l_stmv_rec.date_current = OKC_API.G_MISS_DATE) THEN
      l_stmv_rec.date_current := NULL;
    END IF;
    IF (l_stmv_rec.date_working = OKC_API.G_MISS_DATE) THEN
      l_stmv_rec.date_working := NULL;
    END IF;
    IF (l_stmv_rec.date_history = OKC_API.G_MISS_DATE) THEN
      l_stmv_rec.date_history := NULL;
    END IF;
    IF (l_stmv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_stmv_rec.comments := NULL;
    END IF;
    IF (l_stmv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.created_by := NULL;
    END IF;
    IF (l_stmv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_stmv_rec.creation_date := NULL;
    END IF;
    IF (l_stmv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.last_updated_by := NULL;
    END IF;
    IF (l_stmv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_stmv_rec.last_update_date := NULL;
    END IF;
    /*
    IF (l_stmv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.program_id := NULL;
    END IF;
    IF (l_stmv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.request_id := NULL;
    END IF;
    IF (l_stmv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.program_application_id := NULL;
    END IF;
    IF (l_stmv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_stmv_rec.program_update_date := NULL;
    END IF;
    */
    IF (l_stmv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.last_update_login := NULL;
    END IF;

    -- mvasudev, Bug#2650599
    IF (l_stmv_rec.purpose_code = OKC_API.G_MISS_CHAR) THEN
      l_stmv_rec.purpose_code := NULL;
    END IF;
    --IF (l_stmv_rec.sty_code = OKC_API.G_MISS_CHAR) THEN
      --l_stmv_rec.sty_code := NULL;
    --END IF;
    -- end, mvasudev, Bug#2650599
    IF (l_stmv_rec.stm_id = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.stm_id := NULL;
    END IF;

    -- Added by Keerthi for Bug 3166890
    IF (l_stmv_rec.source_id = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.source_id := NULL;
    END IF;

    IF (l_stmv_rec.source_table = OKC_API.G_MISS_CHAR) THEN
      l_stmv_rec.source_table := NULL;
    END IF;
    -- Added by rgooty: 4212626
    IF (l_stmv_rec.trx_id = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.trx_id := NULL;
    END IF;
    IF (l_stmv_rec.link_hist_stream_id = OKC_API.G_MISS_NUM) THEN
      l_stmv_rec.link_hist_stream_id := NULL;
    END IF;

    RETURN(l_stmv_rec);
  END null_out_defaults;

/*
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate_Attributes for:OKL_STREAMS_V --
  -------------------------------------------
  FUNCTION Validate_Attributes (
    p_stmv_rec IN  stmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_stmv_rec.id = OKC_API.G_MISS_NUM OR
       p_stmv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_stmv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_stmv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_stmv_rec.sgn_code = OKC_API.G_MISS_CHAR OR
          p_stmv_rec.sgn_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sgn_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_stmv_rec.say_code = OKC_API.G_MISS_CHAR OR
          p_stmv_rec.say_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'say_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_stmv_rec.sty_id = OKC_API.G_MISS_NUM OR
          p_stmv_rec.sty_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sty_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_stmv_rec.active_yn = OKC_API.G_MISS_CHAR OR
          p_stmv_rec.active_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'active_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- Validate_Record for:OKL_STREAMS_V --
  ---------------------------------------
  FUNCTION Validate_Record (
    p_stmv_rec IN stmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

*/


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  -- Author          : Ajay
  -- Procedure Name  : Validate_Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Object_Version_Number(p_stmv_rec IN  stmv_rec_type,x_return_status OUT  NOCOPY VARCHAR2)

    IS

    l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

    BEGIN
      -- initialize return status
      x_return_status := Okc_Api.G_RET_STS_SUCCESS;
      -- check for data before processing
      IF (p_stmv_rec.object_version_number IS NULL)  THEN
         Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
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
                            p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                            p_token1       => G_OKL_SQLCODE_TOKEN,
                            p_token1_value => SQLCODE,
                            p_token2       => G_OKL_SQLERRM_TOKEN,
                            p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error

        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Object_Version_Number;


   ------------------------------------------------------------------------
   -- PROCEDURE Validate_Id
   ---------------------------------------------------------------------------
   -- Start of comments
   -- Author          :Ajay
   -- Procedure Name  : Validate_Id
   -- Description     :
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   ---------------------------------------------------------------------------

    PROCEDURE Validate_Id(p_stmv_rec IN  stmv_rec_type,x_return_status OUT  NOCOPY VARCHAR2)

      IS

      l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

      BEGIN
        -- initialize return status
        x_return_status := Okc_Api.G_RET_STS_SUCCESS;
        -- check for data before processing
        IF (p_stmv_rec.id IS NULL)      THEN

            Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
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
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);

          -- notify caller of an UNEXPECTED error
          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Id;

   ------------------------------------------------------------------------
   -- PROCEDURE Validate_Transaction_Number
   ---------------------------------------------------------------------------
   -- Start of comments
   -- Author          : mvasudev
   -- Procedure Name  : Validate_Transaction_Number
   -- Description     :
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   ---------------------------------------------------------------------------

    PROCEDURE Validate_Transaction_Number(p_stmv_rec IN  stmv_rec_type,x_return_status OUT  NOCOPY VARCHAR2)
    IS
     l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
        -- initialize return status
        x_return_status := Okc_Api.G_RET_STS_SUCCESS;
        -- check for data before processing
        IF (p_stmv_rec.transaction_number IS NULL)      THEN
            Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
                               ,p_msg_name       => g_required_value
                               ,p_token1         => g_col_name_token
                               ,p_token1_value   => 'Transaction_Number');
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
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);

          -- notify caller of an UNEXPECTED error
          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Transaction_Number;

  ---------------------------------------------------------------------
  -- PROCEDURE Validate_ActiveYN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Activeyn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Active_yn(p_stmv_rec IN  stmv_rec_type,
                              x_return_status OUT  NOCOPY VARCHAR2)

	 IS

    l_found  VARCHAR2(1);

    BEGIN
	    	-- initialize return status
	       	x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       	     -- check for data before processing
	 IF (p_stmv_rec .active_yn IS NULL) THEN
	      Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	    	                 ,p_msg_name       => g_required_value
	    	                 ,p_token1         => g_col_name_token
	    	                 ,p_token1_value   => 'active_yn');
	     x_return_status    := Okc_Api.G_RET_STS_ERROR;
	     RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSIF p_stmv_rec.active_yn IS NOT NULL THEN
	    --Check if active_yn exists in the fnd_common_lookups or not
	        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'YES_NO',
								  p_lookup_code => p_stmv_rec.active_yn,
								  p_app_id 		=> 0,
								  p_view_app_id => 0);


			IF (l_found <> OKL_API.G_TRUE ) THEN
	             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Active_YN');
			     x_return_status := Okc_Api.G_RET_STS_ERROR;
				 -- raise the exception as there's no matching foreign key value
				 RAISE G_EXCEPTION_HALT_VALIDATION;
			END IF;    END IF;

   EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
	            -- no processing necessary; validation can continue
	            -- with the next column
	            NULL;
        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                          p_token1       => G_OKL_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_OKL_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

   END Validate_Active_yn;


   ---------------------------------------------------------------------------
   -- PROCEDURE Validate_Styid
   ---------------------------------------------------------------------------
   -- Start of comments
   --
   -- Procedure Name  : Validate_Sty_Id
   -- Description     :
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   ---------------------------------------------------------------------------

  PROCEDURE Validate_Sty_Id(
	      	p_stmv_rec IN  stmv_rec_type
	 	   ,x_return_status OUT  NOCOPY VARCHAR2 ) IS

	CURSOR l_styid_csr IS
		        SELECT '1'
		        FROM  okl_strm_type_v
		        WHERE id=p_stmv_rec.sty_id;

              l_dummy_sty_id  VARCHAR2(1);
              l_row_notfound  BOOLEAN :=TRUE;
	BEGIN
	 	-- initialize return status
	   	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	     -- check for data before processing
	   IF (p_stmv_rec.sty_id IS NULL)THEN
	        Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	                           ,p_msg_name       => g_required_value
	                           ,p_token1         => g_col_name_token
	                           ,p_token1_value   => 'sty_id');
	        x_return_status    := Okc_Api.G_RET_STS_ERROR;
	        RAISE G_EXCEPTION_HALT_VALIDATION;

	   ELSIF p_stmv_rec.sty_id IS NOT NULL THEN
	 	--Check if sty_id exists in the stream type or not
	 	   OPEN l_styid_csr;
		   FETCH l_styid_csr INTO l_dummy_sty_id;
		   l_row_notfound :=l_styid_csr%NOTFOUND;
           CLOSE l_styid_csr;

              IF(l_row_notfound ) THEN
		       OKC_API.SET_MESSAGE(G_APP_NAME,G_OKL_STM_NO_PARENT_RECORD,G_COL_NAME_TOKEN,'STY_ID',G_PARENT_TABLE_TOKEN,'OKL_STRM_TYPE_V');
		       x_return_status := Okc_Api.G_RET_STS_ERROR;
		       -- raise the exception as there's no matching foreign key value

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
	                         	    p_msg_name     => G_OKL_UNEXPECTED_ERROR,
	                         	    p_token1       => G_OKL_SQLCODE_TOKEN,
	                         	    p_token1_value => SQLCODE,
	                         	    p_token2       => G_OKL_SQLERRM_TOKEN,
	                         	    p_token2_value => SQLERRM);
	     		-- notify caller of an UNEXPECTED error

	     		x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END Validate_Sty_Id;


   ---------------------------------------------------------------------------
   -- PROCEDURE Validate_Khr_Id
   ---------------------------------------------------------------------------
   -- Start of comments
   --
   -- Procedure Name  : Validate_Khr_Id
   -- Description     :
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
     ---------------------------------------------------------------------------

   PROCEDURE Validate_Khr_Id(
    	      	p_stmv_rec IN  stmv_rec_type
    	 	   ,x_return_status OUT  NOCOPY VARCHAR2 ) IS

    	CURSOR l_khrid_csr IS
		       SELECT '1'
		       FROM okl_k_headers_v
		       WHERE id=p_stmv_rec.khr_id;

         l_dummy_khr_id  VARCHAR2(1);
         l_row_notfound  BOOLEAN :=TRUE;
    	BEGIN
    	 	-- initialize return status
    	 x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    	     -- check for data before processing
    	  IF (p_stmv_rec.khr_id IS NULL) THEN
                     	        Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
    	                           ,p_msg_name       => g_required_value
    	                           ,p_token1         => g_col_name_token
    	                           ,p_token1_value   => 'khr_id');
    	        x_return_status    := Okc_Api.G_RET_STS_ERROR;
    	        RAISE G_EXCEPTION_HALT_VALIDATION;

    	  ELSIF p_stmv_rec.khr_id IS NOT NULL THEN
    	 	--Check if khr_id exists in the okl_k_headers or not
    	 	   OPEN l_khrid_csr;
		       FETCH l_khrid_csr INTO l_dummy_khr_id;
		       l_row_notfound :=l_khrid_csr%NOTFOUND;
	           CLOSE l_khrid_csr;

                IF(l_row_notfound ) THEN
                   		     OKC_API.SET_MESSAGE(G_APP_NAME,G_OKL_NO_PARENT_RECORD,G_COL_NAME_TOKEN,'KHR_ID',G_CHILD_TABLE_TOKEN,'OKL_STREAMS',G_PARENT_TABLE_TOKEN,'OKL_K_HEADERS_V');

    		      x_return_status := Okc_Api.G_RET_STS_ERROR;
    		      -- raise the exception as there's no matching foreign key value

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
    	                     p_msg_name     => G_OKL_UNEXPECTED_ERROR,
    	                     p_token1       => G_OKL_SQLCODE_TOKEN,
    	                     p_token1_value => SQLCODE,
    	                     p_token2       => G_OKL_SQLERRM_TOKEN,
    	                     p_token2_value => SQLERRM);
    	 -- notify caller of an UNEXPECTED error
    	x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END Validate_Khr_Id;



  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Kle_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --Author           :Ajay
  -- Procedure Name  : Validate_Kle_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE Validate_Kle_Id(
	    	      	p_stmv_rec IN  stmv_rec_type
	    	 	   ,x_return_status OUT  NOCOPY VARCHAR2 ) IS

	  CURSOR l_kleid_csr IS
			    SELECT '1'
			    FROM OKL_K_LINES_V
			    WHERE id=p_stmv_rec.kle_id;

         l_dummy_kle_id  VARCHAR2(1);
         l_row_notfound  BOOLEAN :=TRUE;


	  BEGIN
	  	-- initialize return status
	  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	   -- check for data before processing
	     IF (p_stmv_rec.kle_id IS NULL) THEN
	    	Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	    	                   ,p_msg_name       => g_required_value
	    	                   ,p_token1         => g_col_name_token
	    	                   ,p_token1_value   => 'kle_id');
	    	 x_return_status    := Okc_Api.G_RET_STS_ERROR;
	    	 RAISE G_EXCEPTION_HALT_VALIDATION;

	     ELSIF p_stmv_rec.kle_id IS NOT NULL THEN
	    	--Check if kle_id exists in the okl_k_lines or not
	    	OPEN l_kleid_csr;
			FETCH l_kleid_csr INTO l_dummy_kle_id;
			l_row_notfound :=l_kleid_csr%NOTFOUND;
	  	    CLOSE l_kleid_csr;

	         IF(l_row_notfound ) THEN

	           OKC_API.SET_MESSAGE(G_APP_NAME,G_OKL_NO_PARENT_RECORD,G_COL_NAME_TOKEN,'KLE_ID',G_CHILD_TABLE_TOKEN,'OKL_STREAMS',G_PARENT_TABLE_TOKEN,'OKL_K_LINES_V');

	    		x_return_status := Okc_Api.G_RET_STS_ERROR;
	    		-- raise the exception as there's no matching foreign key value

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
	    	                p_msg_name     => G_OKL_UNEXPECTED_ERROR,
	    	                p_token1       => G_OKL_SQLCODE_TOKEN,
	    	                p_token1_value => SQLCODE,
	    	                p_token2       => G_OKL_SQLERRM_TOKEN,
	    	                p_token2_value => SQLERRM);
	    -- notify caller of an UNEXPECTED error
	    x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END Validate_Kle_Id;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sgn_Code
  ---------------------------------------------------------------------------
   -- Start of comments
   --
   -- Procedure Name  : Validate_Sgn_Code
   -- Description     :
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
  ---------------------------------------------------------------------------

	PROCEDURE Validate_Sgn_Code(
	    	      	p_stmv_rec IN  stmv_rec_type
	    	 	   ,x_return_status OUT  NOCOPY VARCHAR2 ) IS
	  -- changes on 15th to add lookup_type in the cursor

    l_found  VARCHAR2(1);

	  BEGIN
	 	-- initialize return status
	 	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	     -- check for data before processing
	     IF (p_stmv_rec.sgn_code IS NULL)THEN
	        Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	    	                    ,p_msg_name       => g_required_value
	    	                    ,p_token1         => g_col_name_token
	    	                    ,p_token1_value   => 'sgn_code');
	    	x_return_status    := Okc_Api.G_RET_STS_ERROR;
	        RAISE G_EXCEPTION_HALT_VALIDATION;

	    ELSE
	        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_STREAM_GENERATOR',
																p_lookup_code => p_stmv_rec.sgn_code);


			IF (l_found <> OKL_API.G_TRUE ) THEN
	             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SPS_CODE');
			     x_return_status := Okc_Api.G_RET_STS_ERROR;
				 -- raise the exception as there's no matching foreign key value
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
	    	                    p_msg_name     => G_OKL_UNEXPECTED_ERROR,
	    	                    p_token1       => G_OKL_SQLCODE_TOKEN,
	    	                    p_token1_value => SQLCODE,
	    	                    p_token2       => G_OKL_SQLERRM_TOKEN,
	    	                    p_token2_value => SQLERRM);

	    	  -- notify caller of an UNEXPECTED error
	    	  x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END Validate_Sgn_Code;


  -----------------------------------------------------------------------------
  -- PROCEDURE Validate_Say_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Say_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE Validate_Say_Code(
	    	      	p_stmv_rec IN  stmv_rec_type
	    	 	   ,x_return_status OUT  NOCOPY VARCHAR2 ) IS
	l_found VARCHAR2(1);

	BEGIN
	  -- initialize return status
	  x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	     -- check for data before processing
	  IF (p_stmv_rec.say_code IS NULL)THEN
	    Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	    	                ,p_msg_name       => g_required_value
	    	                ,p_token1         => g_col_name_token
	    	                ,p_token1_value   => 'say_code');
	    x_return_status    := Okc_Api.G_RET_STS_ERROR;
	    RAISE G_EXCEPTION_HALT_VALIDATION;

	 ELSIF p_stmv_rec.say_code IS NOT NULL THEN
	     --Check if say_code exists in the fnd_common_lookups or not
        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_STREAM_ACTIVITY',
															p_lookup_code => p_stmv_rec.say_code);


		IF (l_found <> OKL_API.G_TRUE ) THEN
             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SPS_CODE');
		     x_return_status := Okc_Api.G_RET_STS_ERROR;
			 -- raise the exception as there's no matching foreign key value
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
	    	                    p_msg_name     => G_OKL_UNEXPECTED_ERROR,
	    	                    p_token1       => G_OKL_SQLCODE_TOKEN,
	    	                    p_token1_value => SQLCODE,
	    	                    p_token2       => G_OKL_SQLERRM_TOKEN,
	    	                    p_token2_value => SQLERRM);

	    	 -- notify caller of an UNEXPECTED error
	    	 x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
   END Validate_Say_Code;


   ------------------------------------------------------------------------
   -- PROCEDURE Validate_STM_Id
   ---------------------------------------------------------------------------
   -- Start of comments
   -- Author          : Kanti
   -- Procedure Name  : Validate_Stm_Id
   -- Description     :
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   ---------------------------------------------------------------------------

    PROCEDURE Validate_STM_Id(p_stmv_rec IN  stmv_rec_type,
                              x_return_status OUT  NOCOPY VARCHAR2)

      IS

      l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

      CURSOR stm_csr (p_stm_id NUMBER)
      IS
      SELECT ID
      FROM okl_streams
      WHERE id = p_stm_id;

      l_stm_id NUMBER := NULL;

      BEGIN

        x_return_status := Okc_Api.G_RET_STS_SUCCESS;

        IF (p_stmv_rec.stm_id <> OKC_API.G_MISS_NUM) AND (p_stmv_rec.stm_id IS NOT NULL)      THEN

            OPEN stm_csr(p_stmv_rec.stm_id);
            FETCH stm_csr INTO l_stm_id;
            CLOSE stm_csr;

            IF (l_stm_id IS NULL) THEN

                   Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
                                      ,p_msg_name       => g_invalid_value
                                      ,p_token1         => g_col_name_token
                                     ,p_token1_value   => 'stm_id');
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
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);

          -- notify caller of an UNEXPECTED error
          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_stm_Id;


 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Source_Id_Table
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Source_Id_table
  -- Description     :
  -- Business Rules  : If Source Id Exists then Source Table cannot be null.
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE Validate_Source_Id_Table(p_stmv_rec IN  stmv_rec_type,x_return_status OUT NOCOPY  VARCHAR2)

                  IS

                  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
                  l_dummy    VARCHAR2(1) := OKC_API.G_FALSE;

                  BEGIN
                    -- initialize return status
                    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
                    -- check for data before processing


                 IF (p_stmv_rec.source_id IS NOT NULL) THEN

        		    IF  (p_stmv_rec.source_table IS NULL) THEN
        	   	       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                	                      ,p_msg_name       => g_invalid_value
                                          ,p_token1         => g_col_name_token
                               	          ,p_token1_value   => 'SOURCE_TABLE');
          		       x_return_status    := Okc_Api.G_RET_STS_ERROR;
 		               RAISE G_EXCEPTION_HALT_VALIDATION;
                    ELSE
		              l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_STM_SOURCE',
                                                                           p_lookup_code => p_stmv_rec.source_table);

      			      IF (l_dummy = Okc_Api.G_FALSE) THEN
          			      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                                             ,p_msg_name       => g_invalid_value
                                             ,p_token1         => g_col_name_token
                                             ,p_token1_value   => 'SOURCE_TABLE');
                           x_return_status    := Okc_Api.G_RET_STS_ERROR;
         			       RAISE G_EXCEPTION_HALT_VALIDATION;
       			       END IF;
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
                                          p_msg_name     => g_okl_unexpected_error,
                                          p_token1       => g_okl_sqlcode_token,
                                          p_token1_value => SQLCODE,
                                          p_token2       => g_okl_sqlerrm_token,
                                          p_token2_value => SQLERRM);

                      -- notify caller of an UNEXPECTED error
                      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

              END Validate_Source_Id_Table;









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
	    p_stmv_rec IN  stmv_rec_type
	  ) RETURN VARCHAR2 IS

	    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	  BEGIN

	     -- call each column-level validation

	    -- Validate_Id
            Validate_Id(p_stmv_rec, x_return_status);
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
	    Validate_Object_Version_Number(p_stmv_rec, x_return_status);
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

	    -- Validate_Sty_Id
	    Validate_Sty_Id(p_stmv_rec, x_return_status);
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

        IF (p_stmv_rec.khr_id IS NULL) THEN
           -- Validate_Kle_Id
	       Validate_Kle_Id(p_stmv_rec, x_return_status);
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
       ELSIF (p_stmv_rec.kle_id IS NULL) THEN
              Validate_Khr_Id(p_stmv_rec, x_return_status);
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

      ELSE
      -- Validate_Khr_Id
	       Validate_Khr_Id(p_stmv_rec, x_return_status);
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
	    -- Validate_Kle_Id
	       Validate_Kle_Id(p_stmv_rec, x_return_status);
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

END IF;

            -- Validate_Sgn_Code
	       Validate_Sgn_Code(p_stmv_rec, x_return_status);
	    -- store the highest degree of error
	       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
	          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	          -- need to leave
	          l_return_status := x_return_status;
	          RAISE G_EXCEPTION_HALT_VALIDATION;
	          ELSE
	          -- record that there was an error
	          l_return_status := x_return_status;
	          END IF;
	       END IF;

	    -- Validate_Say_Code
	       Validate_Say_Code(p_stmv_rec, x_return_status);
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


	    -- Validate_Transaction_Number
	       Validate_Transaction_Number(p_stmv_rec, x_return_status);
	    -- store the highest degree of error
	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		          l_return_status := x_return_status;
	          RAISE G_EXCEPTION_HALT_VALIDATION;
	          ELSE
		          l_return_status := x_return_status;
	          END IF;
	       END IF;



	    -- Validate_active_yn
	       Validate_Active_yn(p_stmv_rec, x_return_status);
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

	    -- Validate_stm_id
	       Validate_stm_id(p_stmv_rec, x_return_status);
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

           -- Added by Keerthi for Bug 3166890
           -- Validate_source_id_table
	       Validate_Source_Id_Table(p_stmv_rec, x_return_status);
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
	                           p_msg_name         => G_OKL_UNEXPECTED_ERROR,
	                           p_token1           => G_OKL_SQLCODE_TOKEN,
	                           p_token1_value     => SQLCODE,
	                           p_token2           => G_OKL_SQLERRM_TOKEN,
	                           p_token2_value     => SQLERRM);


	       -- notify caller of an UNEXPECTED error
	       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
	       RETURN(l_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Stm_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Stm_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Stm_Record(p_stmv_rec      IN      stmv_rec_type
                                       ,x_return_status OUT     NOCOPY VARCHAR2)
  IS

  l_dummy		VARCHAR2(1)	:= '?';
  l_row_found		BOOLEAN 	:= FALSE;

  -- Cursor for stm Unique Key
  CURSOR okl_stm_uk_csr(p_rec stmv_rec_type) IS
  SELECT '1'
  FROM okl_streams_v
  WHERE sty_id				= p_rec.sty_id
  AND   khr_id				= p_rec.khr_id
  AND   kle_id				= p_rec.kle_id
  AND   transaction_number	= p_rec.transaction_number
  AND   id     <> NVL(p_rec.id,-9999);

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    OPEN okl_stm_uk_csr(p_stmv_rec);
    FETCH okl_stm_uk_csr INTO l_dummy;
    l_row_found := okl_stm_uk_csr%FOUND;
    CLOSE okl_stm_uk_csr;
    IF l_row_found THEN
	Okc_Api.set_message(G_APP_NAME,G_OKL_UNQS);
	x_return_status := Okc_Api.G_RET_STS_ERROR;
     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                          p_token1       => G_OKL_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_OKL_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Stm_Record;

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
    p_stmv_rec IN stmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Unique_stm_Record
    Validate_Unique_Stm_Record(p_stmv_rec, x_return_status);
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
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => G_OKL_UNEXPECTED_ERROR,
                           p_token1           => G_OKL_SQLCODE_TOKEN,
                           p_token1_value     => SQLCODE,
                           p_token2           => G_OKL_SQLERRM_TOKEN,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;
  -- END change : mvasudev


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN stmv_rec_type,
    p_to	IN OUT NOCOPY stm_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sty_id := p_from.sty_id;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.sgn_code := p_from.sgn_code;
    p_to.say_code := p_from.say_code;
    p_to.transaction_number := p_from.transaction_number;
    p_to.active_yn := p_from.active_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.date_current := p_from.date_current;
    p_to.date_working := p_from.date_working;
    p_to.date_history := p_from.date_history;
    p_to.comments := p_from.comments;
    p_to.program_id := p_from.program_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.last_update_login := p_from.last_update_login;
    -- mvasudev, Bug#2650599
    p_to.purpose_code := p_from.purpose_code;
    --p_to.sty_code := p_from.sty_code;
    -- end, mvasudev, Bug#2650599
    p_to.stm_id := p_from.stm_id;
    -- Added by Keerthi for Bug 3166890
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    -- Added by rgooty: 4212626
    p_to.trx_id := p_from.trx_id;
    p_to.link_hist_stream_id := p_from.link_hist_stream_id;
  END migrate;
  PROCEDURE migrate (
    p_from	IN stm_rec_type,
    p_to	IN OUT NOCOPY stmv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sty_id := p_from.sty_id;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.sgn_code := p_from.sgn_code;
    p_to.say_code := p_from.say_code;
    p_to.say_code := p_from.transaction_number;
    p_to.active_yn := p_from.active_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.date_current := p_from.date_current;
    p_to.date_working := p_from.date_working;
    p_to.date_history := p_from.date_history;
    p_to.comments := p_from.comments;
    p_to.program_id := p_from.program_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.last_update_login := p_from.last_update_login;
    -- mvasudev, Bug#2650599
    p_to.purpose_code := p_from.purpose_code;
    --p_to.sty_code := p_from.sty_code;
    -- end, mvasudev, Bug#2650599
    p_to.stm_id := p_from.stm_id;
    -- Added by Keerthi for Bug 3166890
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    -- Added by rgooty: 4212626
    p_to.trx_id := p_from.trx_id;
    p_to.link_hist_stream_id := p_from.link_hist_stream_id;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- validate_row for:OKL_STREAMS_V --
  ------------------------------------

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_rec                     IN stmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stmv_rec                     stmv_rec_type := p_stmv_rec;
    l_stm_rec                      stm_rec_type;
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
        l_return_status := Validate_Attributes(l_stmv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN


      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_stmv_rec);

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
  -- PL/SQL TBL validate_row for:STMV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_tbl                     IN stmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_stmv_tbl.COUNT > 0) THEN
      i := p_stmv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stmv_rec                     => p_stmv_tbl(i));
        /* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */

        EXIT WHEN (i = p_stmv_tbl.LAST);
        i := p_stmv_tbl.NEXT(i);
      END LOOP;
    -- return overall status
   x_return_status :=l_overall_status;
    END IF;
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
  --------------------------------
  -- insert_row for:OKL_STREAMS --
  --------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stm_rec                      IN stm_rec_type,
    x_stm_rec                      OUT NOCOPY stm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'STREAMS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stm_rec                      stm_rec_type := p_stm_rec;
    l_def_stm_rec                  stm_rec_type;
    ------------------------------------
    -- Set_Attributes for:OKL_STREAMS --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_stm_rec IN  stm_rec_type,
      x_stm_rec OUT NOCOPY stm_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_stm_rec := p_stm_rec;
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
      p_stm_rec,                         -- IN
      l_stm_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN


      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_STREAMS(
        id,
        sty_id,
        khr_id,
        kle_id,
        sgn_code,
        say_code,
		transaction_number,
        active_yn,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        date_current,
        date_working,
        date_history,
        comments,
        program_id,
        request_id,
        program_application_id,
        program_update_date,
        last_update_login,
        -- mvasudev, Bug#2650599
        purpose_code,
        --sty_code
        -- end, mvasudev, Bug#2650599
        stm_id,
        -- Added by Keerthi for Bug 3166890
        source_id,
        source_table,
        -- Added by rgooty: 4212626
        trx_id,
        link_hist_stream_id
        )
      VALUES (
        l_stm_rec.id,
        l_stm_rec.sty_id,
        l_stm_rec.khr_id,
        l_stm_rec.kle_id,
        l_stm_rec.sgn_code,
        l_stm_rec.say_code,
        l_stm_rec.transaction_number,
        l_stm_rec.active_yn,
        l_stm_rec.object_version_number,
        l_stm_rec.created_by,
        l_stm_rec.creation_date,
        l_stm_rec.last_updated_by,
        l_stm_rec.last_update_date,
        l_stm_rec.date_current,
        l_stm_rec.date_working,
        l_stm_rec.date_history,
        l_stm_rec.comments,
        l_stm_rec.program_id,
        l_stm_rec.request_id,
        l_stm_rec.program_application_id,
        l_stm_rec.program_update_date,
        l_stm_rec.last_update_login,
        -- mvasudev, Bug#2650599
        l_stm_rec.purpose_code,
        --l_stm_rec.sty_code
        -- end, mvasudev, Bug#2650599
        l_stm_rec.stm_id,
        -- Added by Keerthi for Bug 3166890
        l_stm_rec.source_id,
        l_stm_rec.source_table,
        l_stm_rec.trx_id,
        l_stm_rec.link_hist_stream_id
        );

    -- Set OUT values
    x_stm_rec := l_stm_rec;
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
  ----------------------------------
  -- insert_row for:OKL_STREAMS_V --
  ----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_rec                     IN stmv_rec_type,
    x_stmv_rec                     OUT NOCOPY stmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stmv_rec                     stmv_rec_type;
    l_def_stmv_rec                 stmv_rec_type;
    l_stm_rec                      stm_rec_type;
    lx_stm_rec                     stm_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_stmv_rec	IN stmv_rec_type
    ) RETURN stmv_rec_type IS
      l_stmv_rec	stmv_rec_type := p_stmv_rec;
    BEGIN
      l_stmv_rec.CREATION_DATE := SYSDATE;
      l_stmv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_stmv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_stmv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_stmv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_stmv_rec);
    END fill_who_columns;
    --------------------------------------
    -- Set_Attributes for:OKL_STREAMS_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_stmv_rec IN  stmv_rec_type,
      x_stmv_rec OUT NOCOPY stmv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_stmv_rec := p_stmv_rec;
      x_stmv_rec.OBJECT_VERSION_NUMBER := 1;
       SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
	  		 DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
			 DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
			 DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
	    INTO  x_stmv_rec.REQUEST_ID
	  	     ,x_stmv_rec.PROGRAM_APPLICATION_ID
		     ,x_stmv_rec.PROGRAM_ID
		     ,x_stmv_rec.PROGRAM_UPDATE_DATE
		   FROM DUAL;

      /*
       * veramach 19-Dec-2007 bug 6691567 - set values for date_history/date_current/date_working based on say_code
      */
      IF p_stmv_rec.say_code = 'CURR' AND p_stmv_rec.date_current = OKL_API.G_MISS_DATE THEN
        x_stmv_rec.date_current := SYSDATE;
      END IF;
      IF p_stmv_rec.say_code = 'HIST' AND p_stmv_rec.date_history = OKL_API.G_MISS_DATE THEN
        x_stmv_rec.date_history := SYSDATE;
      END IF;
      IF p_stmv_rec.say_code = 'WORK' AND p_stmv_rec.date_working = OKL_API.G_MISS_DATE THEN
        x_stmv_rec.date_working := SYSDATE;
      END IF;
      /*
       * veramach 19-Dec-2007 bug 6691567 - set values for date_history/date_current/date_working based on say_code
      */

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
    l_stmv_rec := null_out_defaults(p_stmv_rec);
    -- Set primary key value
    l_stmv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_stmv_rec,                        -- IN
      l_def_stmv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_stmv_rec := fill_who_columns(l_def_stmv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_stmv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_stmv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_stmv_rec, l_stm_rec);

    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_stm_rec,
      lx_stm_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_stm_rec, l_def_stmv_rec);
    -- Set OUT values
    x_stmv_rec := l_def_stmv_rec;
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
  -- PL/SQL TBL insert_row for:STMV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_tbl                     IN stmv_tbl_type,
    x_stmv_tbl                     OUT NOCOPY stmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_stmv_tbl.COUNT > 0) THEN
      i := p_stmv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stmv_rec                     => p_stmv_tbl(i),
          x_stmv_rec                     => x_stmv_tbl(i));
        /* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */


        EXIT WHEN (i = p_stmv_tbl.LAST);
        i := p_stmv_tbl.NEXT(i);
      END LOOP;
      -- return overall status
     x_return_status :=l_overall_status;
    END IF;
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

  --Added by kthiruva on 12-May-2005 for Streams Performance
  --Introducing a new procedure that accepts a table of stream headers
  --and does a bulk update.
  --Bug 4346646- Start of Changes
  ----------------------------------------
  -- PL/SQL TBL insert_row for:STMV_TBL --
  ----------------------------------------
  PROCEDURE insert_row_perf(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_tbl                     IN stmv_tbl_type,
    x_stmv_tbl                     OUT NOCOPY stmv_tbl_type) IS

    l_tabsize                         NUMBER := p_stmv_tbl.COUNT;
    in_id                             Okl_Streams_Util.NumberTabTyp;
    in_sty_id                         Okl_Streams_Util.NumberTabTyp;
    in_khr_id                         Okl_Streams_Util.NumberTabTyp;
    in_kle_id                         Okl_Streams_Util.NumberTabTyp;
    in_sgn_code                       Okl_Streams_Util.Var30TabTyp;
    in_say_code                       Okl_Streams_Util.Var30TabTyp;
    in_transaction_number             Okl_Streams_Util.NumberTabTyp;
    in_active_yn                      Okl_Streams_Util.Var3TabTyp;
    in_object_version_number          Okl_Streams_Util.Number9TabTyp;
    in_created_by                     Okl_Streams_Util.Number15TabTyp;
    in_creation_date                  Okl_Streams_Util.DateTabTyp;
    in_last_updated_by                Okl_Streams_Util.Number15TabTyp;
    in_last_update_date               Okl_Streams_Util.DateTabTyp;
    in_date_current                   Okl_Streams_Util.DateTabTyp;
    in_date_working                   Okl_Streams_Util.DateTabTyp;
    in_date_history                   Okl_Streams_Util.DateTabTyp;
    in_comments                       Okl_Streams_Util.Var1995TabTyp;
    in_program_id                     Okl_Streams_Util.Number15TabTyp;
    in_request_id                     Okl_Streams_Util.Number15TabTyp;
    in_program_application_id         Okl_Streams_Util.Number15TabTyp;
    in_program_update_date            Okl_Streams_Util.DateTabTyp;
    in_last_update_login              Okl_Streams_Util.Number15TabTyp;
    in_purpose_code                   Okl_Streams_Util.Var30TabTyp;
    in_stm_id                         Okl_Streams_Util.NumberTabTyp;
    in_source_id                      Okl_Streams_Util.NumberTabTyp;
    in_source_table                   Okl_Streams_Util.Var30TabTyp;
    in_trx_id                         Okl_Streams_Util.NumberTabTyp;
    in_link_hist_stream_id            Okl_Streams_Util.NumberTabTyp;
    --Declaring the local variables used
    l_created_by                     NUMBER;
    l_last_updated_by                NUMBER;
    l_creation_date                  DATE;
    l_last_update_date               DATE;
    l_last_update_login              NUMBER;
    i                                INTEGER;
    j                                INTEGER;

  BEGIN
      x_return_Status := OKC_API.G_RET_STS_SUCCESS;
      i := p_stmv_tbl.FIRST; j:=0;
     --Assigning the values for the who columns
      l_created_by := FND_GLOBAL.USER_ID;
      l_last_updated_by := FND_GLOBAL.USER_ID;
      l_creation_date := SYSDATE;
      l_last_update_date := SYSDATE;
      l_last_update_login := FND_GLOBAL.LOGIN_ID;
    --Bug -End of Changes

    WHILE i is not null LOOP
      j:=j+1;
      in_id(j) := get_seq_id;
      --Assigning the id to the return table
      x_stmv_tbl(j).id := in_id(j);

      in_sty_id(j) := p_stmv_tbl(i).sty_id;
      in_khr_id(j) := p_stmv_tbl(i).khr_id;
      in_kle_id(j) := p_stmv_tbl(i).kle_id;
      in_sgn_code(j) := p_stmv_tbl(i).sgn_code;
      in_say_code(j) := p_stmv_tbl(i).say_code;
      in_transaction_number(j) := p_stmv_tbl(i).transaction_number;
      in_active_yn(j) := p_stmv_tbl(i).active_yn;
      in_date_current(j) := p_stmv_tbl(i).date_current;
      in_date_working(j) := p_stmv_tbl(i).date_working;
      in_date_history(j) := p_stmv_tbl(i).date_history;
      in_comments(j) := p_stmv_tbl(i).comments;
      in_program_id(j) := p_stmv_tbl(i).program_id;
      in_request_id(j) := p_stmv_tbl(i).request_id;
      in_program_application_id(j) := p_stmv_tbl(i).program_application_id;
      in_program_update_date(j) := p_stmv_tbl(i).program_update_date;
      in_purpose_code(j) := p_stmv_tbl(i).purpose_code;
      in_stm_id(j) := p_stmv_tbl(i).stm_id;
      in_source_id(j):= p_stmv_tbl(i).source_id;
      in_source_table(j) := p_stmv_tbl(i).source_table;
      in_trx_id(j) := p_stmv_tbl(i).trx_id;
      in_link_hist_stream_id(j) := p_stmv_tbl(i).link_hist_stream_id;

      in_object_version_number(i) := 1;
      --Assiging the who columns
      in_created_by(i) := l_created_by;
      in_creation_date(i) := l_creation_date;
      in_last_updated_by(i) := l_last_updated_by;
      in_last_update_date(i) := l_last_update_date;
      in_last_update_login(i) := l_last_update_login;

      /*
       * veramach 19-Dec-2007 bug 6691567 - set values for date_history/date_current/date_working based on say_code
      */
      IF p_stmv_tbl(i).say_code = 'CURR' AND p_stmv_tbl(i).date_current = OKL_API.G_MISS_DATE THEN
        in_date_current(j) := SYSDATE;
      END IF;
      IF p_stmv_tbl(i).say_code = 'HIST' AND p_stmv_tbl(i).date_history = OKL_API.G_MISS_DATE THEN
        in_date_history(j) := SYSDATE;
      END IF;
      IF p_stmv_tbl(i).say_code = 'WORK' AND p_stmv_tbl(i).date_working = OKL_API.G_MISS_DATE THEN
        in_date_working(j) := SYSDATE;
      END IF;
      /*
       * veramach 19-Dec-2007 bug 6691567 - set values for date_history/date_current/date_working based on say_code
      */

      i:= p_stmv_tbl.next(i);
    END LOOP;

      FORALL i in 1..l_tabsize
        INSERT INTO okl_streams(id,
                                sty_id,
                                khr_id,
                                kle_id,
                                sgn_code,
                                say_code,
                                transaction_number,
                                active_yn,
                                object_version_number,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                date_current,
                                date_working,
                                date_history,
                                comments,
                                program_id,
                                request_id,
                                program_application_id,
                                program_update_date,
                                last_update_login,
                                purpose_code,
                                stm_id,
                                source_id,
                                source_table,
                                trx_id,
                                link_hist_stream_id)
                         VALUES(in_id(i),
                                in_sty_id(i),
                                in_khr_id(i),
                                in_kle_id(i),
                                in_sgn_code(i),
                                in_say_code(i),
                                in_transaction_number(i),
                                in_active_yn(i),
                                in_object_version_number(i),
                                in_created_by(i),
                                in_creation_date(i),
                                in_last_updated_by(i),
                                in_last_update_date(i),
                                in_date_current(i),
                                in_date_working(i),
                                in_date_history(i),
                                in_comments(i),
                                in_program_id(i),
                                in_request_id(i),
                                in_program_application_id(i),
                                in_program_update_date(i),
                                in_last_update_login(i),
                                in_purpose_code(i),
                                in_stm_id(i),
                                in_source_id(i),
                                in_source_table(i),
                                in_trx_id(i),
                                in_link_hist_stream_id(i));

  END insert_row_perf;
  --Bug  4346646- End of Chagnes



  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ------------------------------
  -- lock_row for:OKL_STREAMS --
  ------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stm_rec                      IN stm_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_stm_rec IN stm_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_STREAMS
     WHERE ID = p_stm_rec.id
       AND OBJECT_VERSION_NUMBER = p_stm_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_stm_rec IN stm_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_STREAMS
    WHERE ID = p_stm_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'STREAMS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_STREAMS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_STREAMS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_stm_rec);
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
      OPEN lchk_csr(p_stm_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_stm_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_stm_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_OKC_APP,G_RECORD_LOGICALLY_DELETED);
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
  --------------------------------
  -- lock_row for:OKL_STREAMS_V --
  --------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_rec                     IN stmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stm_rec                      stm_rec_type;
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
    migrate(p_stmv_rec, l_stm_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_stm_rec
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
  -- PL/SQL TBL lock_row for:STMV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_tbl                     IN stmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_stmv_tbl.COUNT > 0) THEN
      i := p_stmv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stmv_rec                     => p_stmv_tbl(i));

     /* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */

        EXIT WHEN (i = p_stmv_tbl.LAST);
        i := p_stmv_tbl.NEXT(i);
      END LOOP;
  -- return the overall status
  x_return_status :=l_overall_status;
    END IF;
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
  --------------------------------
  -- update_row for:OKL_STREAMS --
  --------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stm_rec                      IN stm_rec_type,
    x_stm_rec                      OUT NOCOPY stm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'STREAMS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stm_rec                      stm_rec_type := p_stm_rec;
    l_def_stm_rec                  stm_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_stm_rec	IN stm_rec_type,
      x_stm_rec	OUT NOCOPY stm_rec_type
    ) RETURN VARCHAR2 IS
      l_stm_rec                      stm_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_stm_rec := p_stm_rec;
      -- Get current database values
      l_stm_rec := get_rec(p_stm_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_stm_rec.id IS NULL) THEN
        x_stm_rec.id := l_stm_rec.id;
      ELSIF (x_stm_rec.id = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.id := NULL;
      END IF;
      IF (x_stm_rec.sty_id IS NULL) THEN
        x_stm_rec.sty_id := l_stm_rec.sty_id;
      ELSIF (x_stm_rec.sty_id = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.sty_id := NULL;
      END IF;
      IF (x_stm_rec.khr_id IS NULL) THEN
        x_stm_rec.khr_id := l_stm_rec.khr_id;
      ELSIF (x_stm_rec.khr_id = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.khr_id := NULL;
      END IF;
      IF (x_stm_rec.kle_id IS NULL)THEN
        x_stm_rec.kle_id := l_stm_rec.kle_id;
      ELSIF (x_stm_rec.kle_id = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.kle_id := NULL;
      END IF;
      IF (x_stm_rec.sgn_code IS NULL) THEN
        x_stm_rec.sgn_code := l_stm_rec.sgn_code;
      ELSIF (x_stm_rec.sgn_code = OKC_API.G_MISS_CHAR) THEN
        x_stm_rec.sgn_code := NULL;
      END IF;
      IF (x_stm_rec.say_code IS NULL) THEN
        x_stm_rec.say_code := l_stm_rec.say_code;
      ELSIF (x_stm_rec.say_code = OKC_API.G_MISS_CHAR) THEN
        x_stm_rec.say_code := NULL;
      END IF;
      IF (x_stm_rec.transaction_number IS NULL) THEN
        x_stm_rec.transaction_number := l_stm_rec.transaction_number;
      ELSIF (x_stm_rec.transaction_number = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.transaction_number := NULL;
      END IF;
      IF (x_stm_rec.active_yn IS NULL) THEN
        x_stm_rec.active_yn := l_stm_rec.active_yn;
      ELSIF (x_stm_rec.active_yn = OKC_API.G_MISS_CHAR) THEN
        x_stm_rec.active_yn := NULL;
      END IF;
      IF (x_stm_rec.object_version_number IS NULL) THEN
        x_stm_rec.object_version_number := l_stm_rec.object_version_number;
      ELSIF (x_stm_rec.object_version_number = OKC_API.G_MISS_NUM)THEN
        x_stm_rec.object_version_number := NULL;
      END IF;
      IF (x_stm_rec.created_by IS NULL)THEN
        x_stm_rec.created_by := l_stm_rec.created_by;
      ELSIF (x_stm_rec.created_by = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.created_by := NULL;
      END IF;
      IF (x_stm_rec.creation_date IS NULL)THEN
        x_stm_rec.creation_date := l_stm_rec.creation_date;
      ELSIF (x_stm_rec.creation_date = OKC_API.G_MISS_DATE) THEN
        x_stm_rec.creation_date := NULL;
      END IF;
      IF (x_stm_rec.last_updated_by IS NULL) THEN
        x_stm_rec.last_updated_by := l_stm_rec.last_updated_by;
      ELSIF (x_stm_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.last_updated_by := NULL;
      END IF;
      IF (x_stm_rec.last_update_date IS NULL) THEN
        x_stm_rec.last_update_date := l_stm_rec.last_update_date;
      ELSIF (x_stm_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
        x_stm_rec.last_update_date := NULL;
      END IF;
      IF (x_stm_rec.date_current IS NULL)THEN
        x_stm_rec.date_current := l_stm_rec.date_current;
      ELSIF (x_stm_rec.date_current = OKC_API.G_MISS_DATE) THEN
        x_stm_rec.date_current := NULL;
      END IF;
      IF (x_stm_rec.date_working IS NULL ) THEN
        x_stm_rec.date_working := l_stm_rec.date_working;
      ELSIF (x_stm_rec.date_working = OKC_API.G_MISS_DATE) THEN
        x_stm_rec.date_working := NULL;
      END IF;
      IF (x_stm_rec.date_history IS NULL) THEN
        x_stm_rec.date_history := l_stm_rec.date_history;
      ELSIF (x_stm_rec.date_history = OKC_API.G_MISS_DATE) THEN
        x_stm_rec.date_history := NULL;
      END IF;
      IF (x_stm_rec.comments IS NULL) THEN
        x_stm_rec.comments := l_stm_rec.comments;
      ELSIF (x_stm_rec.comments = OKC_API.G_MISS_CHAR) THEN
        x_stm_rec.comments := NULL;
      END IF;
      IF (x_stm_rec.program_id IS NULL) THEN
        x_stm_rec.program_id := l_stm_rec.program_id;
      ELSIF (x_stm_rec.program_id = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.program_id := NULL ;
      END IF;
      IF (x_stm_rec.request_id IS NULL) THEN
        x_stm_rec.request_id := l_stm_rec.request_id;
      ELSIF (x_stm_rec.request_id = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.request_id := NULL;
      END IF;
      IF (x_stm_rec.program_application_id IS NULL) THEN
        x_stm_rec.program_application_id := l_stm_rec.program_application_id;
      ELSIF(x_stm_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.program_application_id := NULL;
      END IF;
      IF (x_stm_rec.program_update_date IS NULL )THEN
        x_stm_rec.program_update_date := l_stm_rec.program_update_date;
      ELSIF (x_stm_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
        x_stm_rec.program_update_date := NULL;
      END IF;
      IF (x_stm_rec.last_update_login IS NULL)THEN
        x_stm_rec.last_update_login := l_stm_rec.last_update_login;
      ELSIF(x_stm_rec.last_update_login = OKC_API.G_MISS_NUM)THEN
        x_stm_rec.last_update_login := NULL;
      END IF;

      -- mvasudev, Bug#2650599
      IF (x_stm_rec.purpose_code IS NULL) THEN
        x_stm_rec.purpose_code := l_stm_rec.purpose_code;
      ELSIF (x_stm_rec.purpose_code = OKC_API.G_MISS_CHAR) THEN
        x_stm_rec.purpose_code := NULL;
      END IF;
      --IF (x_stm_rec.sty_code = OKC_API.G_MISS_CHAR)
      --THEN
       -- x_stm_rec.sty_code := l_stm_rec.sty_code;
      --END IF;
      -- end, mvasudev, Bug#2650599

      IF (x_stm_rec.stm_id IS NULL)THEN
        x_stm_rec.stm_id := l_stm_rec.stm_id;
      ELSIF (x_stm_rec.stm_id = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.stm_id := NULL;
      END IF;

      -- Added by Keerthi for Bug 3166890

      IF (x_stm_rec.source_id IS NULL)THEN
        x_stm_rec.source_id := l_stm_rec.source_id;
      ELSIF (x_stm_rec.source_id = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.source_id := NULL;
      END IF;

      IF (x_stm_rec.source_table IS NULL)THEN
        x_stm_rec.source_table := l_stm_rec.source_table;
      ELSIF (x_stm_rec.source_table = OKC_API.G_MISS_CHAR) THEN
        x_stm_rec.source_table := NULL;
      END IF;
      -- Added by rgooty: 4212626
      IF (x_stm_rec.trx_id IS NULL)THEN
        x_stm_rec.trx_id := l_stm_rec.trx_id;
      ELSIF (x_stm_rec.trx_id = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.trx_id := NULL;
      END IF;

      IF (x_stm_rec.link_hist_stream_id IS NULL)THEN
        x_stm_rec.link_hist_stream_id := l_stm_rec.link_hist_stream_id;
      ELSIF (x_stm_rec.link_hist_stream_id = OKC_API.G_MISS_NUM) THEN
        x_stm_rec.link_hist_stream_id := NULL;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------
    -- Set_Attributes for:OKL_STREAMS --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_stm_rec IN  stm_rec_type,
      x_stm_rec OUT NOCOPY stm_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_stm_rec := p_stm_rec;
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
      p_stm_rec,                         -- IN
      l_stm_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN


      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_stm_rec, l_def_stm_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN


      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_STREAMS
    SET STY_ID = l_def_stm_rec.sty_id,
        KHR_ID = l_def_stm_rec.khr_id,
        KLE_ID = l_def_stm_rec.kle_id,
        SGN_CODE = l_def_stm_rec.sgn_code,
        SAY_CODE = l_def_stm_rec.say_code,
        TRANSACTION_NUMBER = l_def_stm_rec.transaction_number,
        ACTIVE_YN = l_def_stm_rec.active_yn,
        OBJECT_VERSION_NUMBER = l_def_stm_rec.object_version_number,
        CREATED_BY = l_def_stm_rec.created_by,
        CREATION_DATE = l_def_stm_rec.creation_date,
        LAST_UPDATED_BY = l_def_stm_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_stm_rec.last_update_date,
        DATE_CURRENT = l_def_stm_rec.date_current,
        DATE_WORKING = l_def_stm_rec.date_working,
        DATE_HISTORY = l_def_stm_rec.date_history,
        COMMENTS = l_def_stm_rec.comments,
        PROGRAM_ID = l_def_stm_rec.program_id,
        REQUEST_ID = l_def_stm_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_stm_rec.program_application_id,
        PROGRAM_UPDATE_DATE = l_def_stm_rec.program_update_date,
        LAST_UPDATE_LOGIN = l_def_stm_rec.last_update_login,
        -- mvasudev, Bug#2650599
        PURPOSE_CODE = l_def_stm_rec.purpose_code,
        --STY_CODE = l_def_stm_rec.sty_code
        -- end, mvasudev, Bug#2650599
        stm_id  = l_def_stm_rec.stm_id,
        -- Added by Keerthi for Bug 3166890
        source_id  = l_def_stm_rec.source_id,
        source_table  = l_def_stm_rec.source_table,
        -- Added by rgooty: 4212626
        trx_id = l_def_stm_rec.trx_id,
        link_hist_stream_id = l_def_stm_rec.link_hist_stream_id
    WHERE ID = l_def_stm_rec.id;

    x_stm_rec := l_def_stm_rec;
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
  ----------------------------------
  -- update_row for:OKL_STREAMS_V --
  ----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_rec                     IN stmv_rec_type,
    x_stmv_rec                     OUT NOCOPY stmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stmv_rec                     stmv_rec_type := p_stmv_rec;
    l_def_stmv_rec                 stmv_rec_type;
    l_stm_rec                      stm_rec_type;
    lx_stm_rec                     stm_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_stmv_rec	IN stmv_rec_type
    ) RETURN stmv_rec_type IS
      l_stmv_rec	stmv_rec_type := p_stmv_rec;
    BEGIN
      l_stmv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_stmv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_stmv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_stmv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_stmv_rec	IN stmv_rec_type,
      x_stmv_rec	OUT NOCOPY stmv_rec_type
    ) RETURN VARCHAR2 IS
      l_stmv_rec                     stmv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_stmv_rec := p_stmv_rec;
      -- Get current database values
      l_stmv_rec := get_rec(p_stmv_rec, l_row_notfound);
      IF (l_row_notfound) THEN


        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_stmv_rec.id IS NULL)THEN
        x_stmv_rec.id := l_stmv_rec.id;
      ELSIF (x_stmv_rec.id = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.id := NULL;
      END IF;
      IF (x_stmv_rec.object_version_number IS NULL) THEN
        x_stmv_rec.object_version_number := l_stmv_rec.object_version_number;
      ELSIF (x_stmv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.object_version_number := NULL;
      END IF;
      IF (x_stmv_rec.sgn_code IS NULL)THEN
        x_stmv_rec.sgn_code := l_stmv_rec.sgn_code;
      ELSIF (x_stmv_rec.sgn_code = OKC_API.G_MISS_CHAR) THEN
        x_stmv_rec.sgn_code := NULL;
      END IF;
      IF (x_stmv_rec.say_code IS NULL)THEN
        x_stmv_rec.say_code := l_stmv_rec.say_code;
      ELSIF (x_stmv_rec.say_code = OKC_API.G_MISS_CHAR) THEN
        x_stmv_rec.say_code := NULL;
      END IF;
      IF (x_stmv_rec.sty_id IS NULL)THEN
        x_stmv_rec.sty_id := l_stmv_rec.sty_id;
      ELSIF (x_stmv_rec.sty_id = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.sty_id := NULL;
      END IF;
      IF (x_stmv_rec.kle_id IS NULL)THEN
        x_stmv_rec.kle_id := l_stmv_rec.kle_id;
      ELSIF (x_stmv_rec.kle_id = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.kle_id := NULL;
      END IF;
      IF (x_stmv_rec.khr_id IS NULL)THEN
        x_stmv_rec.khr_id := l_stmv_rec.khr_id;
      ELSIF (x_stmv_rec.khr_id = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.khr_id := NULL;
      END IF;
      IF (x_stmv_rec.transaction_number IS NULL)THEN
        x_stmv_rec.transaction_number := l_stmv_rec.transaction_number;
      ELSIF (x_stmv_rec.transaction_number = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.transaction_number := NULL;
      END IF;
      IF (x_stmv_rec.active_yn IS NULL) THEN
        x_stmv_rec.active_yn := l_stmv_rec.active_yn;
      ELSIF (x_stmv_rec.active_yn = OKC_API.G_MISS_CHAR) THEN
        x_stmv_rec.active_yn := NULL;
      END IF;
      IF (x_stmv_rec.date_current IS NULL)THEN
        x_stmv_rec.date_current := l_stmv_rec.date_current;
      ELSIF (x_stmv_rec.date_current = OKC_API.G_MISS_DATE) THEN
        x_stmv_rec.date_current := NULL;
      END IF;
      IF (x_stmv_rec.date_working IS NULL)THEN
        x_stmv_rec.date_working := l_stmv_rec.date_working;
      ELSIF (x_stmv_rec.date_working = OKC_API.G_MISS_DATE) THEN
        x_stmv_rec.date_working := NULL;
      END IF;
      IF (x_stmv_rec.date_history IS NULL)THEN
        x_stmv_rec.date_history := l_stmv_rec.date_history;
      ELSIF (x_stmv_rec.date_history = OKC_API.G_MISS_DATE) THEN
        x_stmv_rec.date_history := NULL;
      END IF;
      IF (x_stmv_rec.comments IS NULL)THEN
        x_stmv_rec.comments := l_stmv_rec.comments;
      ELSIF (x_stmv_rec.comments = OKC_API.G_MISS_CHAR) THEN
        x_stmv_rec.comments := NULL;
      END IF;
      IF (x_stmv_rec.created_by IS NULL)THEN
        x_stmv_rec.created_by := l_stmv_rec.created_by;
      ELSIF (x_stmv_rec.created_by = OKC_API.G_MISS_NUM)THEN
        x_stmv_rec.created_by := NULL;
      END IF;
      IF (x_stmv_rec.creation_date IS NULL)THEN
        x_stmv_rec.creation_date := l_stmv_rec.creation_date;
      ELSIF (x_stmv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
        x_stmv_rec.creation_date := NULL;
      END IF;
      IF (x_stmv_rec.last_updated_by IS NULL)THEN
        x_stmv_rec.last_updated_by := l_stmv_rec.last_updated_by;
      ELSIF (x_stmv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.last_updated_by := NULL ;
      END IF;
      IF (x_stmv_rec.last_update_date IS NULL)THEN
        x_stmv_rec.last_update_date := l_stmv_rec.last_update_date;
      ELSIF(x_stmv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
        x_stmv_rec.last_update_date := NULL;
      END IF;
      IF (x_stmv_rec.program_id IS NULL)THEN
        x_stmv_rec.program_id := l_stmv_rec.program_id;
      ELSIF (x_stmv_rec.program_id = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.program_id := NULL;
      END IF;
      IF (x_stmv_rec.request_id IS NULL)THEN
        x_stmv_rec.request_id := l_stmv_rec.request_id;
      ELSIF (x_stmv_rec.request_id = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.request_id := NULL;
      END IF;
      IF (x_stmv_rec.program_application_id IS NULL)THEN
        x_stmv_rec.program_application_id := l_stmv_rec.program_application_id;
      ELSIF (x_stmv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.program_application_id := NULL;
      END IF;
      IF (x_stmv_rec.program_update_date IS NULL )THEN
        x_stmv_rec.program_update_date := l_stmv_rec.program_update_date;
      ELSIF (x_stmv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
        x_stmv_rec.program_update_date := NULL;
      END IF;
      IF (x_stmv_rec.last_update_login IS NULL)THEN
        x_stmv_rec.last_update_login := l_stmv_rec.last_update_login;
      ELSIF (x_stmv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.last_update_login := NULL;
      END IF;

      -- mvasudev, Bug#2650599
      IF (x_stmv_rec.purpose_code IS NULL)THEN
        x_stmv_rec.purpose_code := l_stmv_rec.purpose_code;
      ELSIF (x_stmv_rec.purpose_code = OKC_API.G_MISS_CHAR) THEN
        x_stmv_rec.purpose_code := NULL;
      END IF;


      --IF (x_stmv_rec.sty_code = OKC_API.G_MISS_CHAR)
      --THEN
        --x_stmv_rec.sty_code := l_stmv_rec.sty_code;
      --END IF;
      -- end, mvasudev, Bug#2650599

      IF (x_stmv_rec.stm_id IS NULL) THEN
        x_stmv_rec.stm_id := l_stmv_rec.stm_id;
      ELSIF (x_stmv_rec.stm_id = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.stm_id := NULL;
      END IF;

      -- Added by Keerthi for Bug 3166890

      IF (x_stmv_rec.source_id IS NULL) THEN
        x_stmv_rec.source_id := l_stmv_rec.source_id;
      ELSIF (x_stmv_rec.source_id = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.source_id := NULL;
      END IF;

      IF (x_stmv_rec.source_table IS NULL) THEN
        x_stmv_rec.source_table := l_stmv_rec.source_table;
      ELSIF (x_stmv_rec.source_table = OKC_API.G_MISS_CHAR) THEN
        x_stmv_rec.source_table := NULL;
      END IF;
      -- Added by rgooty: 4212626
      IF (x_stmv_rec.trx_id IS NULL) THEN
        x_stmv_rec.trx_id := l_stmv_rec.trx_id;
      ELSIF (x_stmv_rec.trx_id = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.trx_id := NULL;
      END IF;
      IF (x_stmv_rec.link_hist_stream_id IS NULL) THEN
        x_stmv_rec.link_hist_stream_id := l_stmv_rec.link_hist_stream_id;
      ELSIF (x_stmv_rec.link_hist_stream_id = OKC_API.G_MISS_NUM) THEN
        x_stmv_rec.link_hist_stream_id := NULL;
      END IF;

      RETURN(l_return_status);

    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKL_STREAMS_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_stmv_rec IN  stmv_rec_type,
      x_stmv_rec OUT NOCOPY stmv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_stmv_rec := p_stmv_rec;
      x_stmv_rec.OBJECT_VERSION_NUMBER := NVL(x_stmv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

       /***** Concurrent Manager columns assignement  ************/
	  SELECT  NVL(DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID)
	  			 ,p_stmv_rec.REQUEST_ID)
			 ,NVL(DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID)
	  			 ,p_stmv_rec.PROGRAM_APPLICATION_ID)
			 ,NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID)
	  		 	 ,p_stmv_rec.PROGRAM_ID)
			 ,DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
	  		 	 ,NULL,p_stmv_rec.PROGRAM_UPDATE_DATE,SYSDATE)
		INTO x_stmv_rec.REQUEST_ID
			 ,x_stmv_rec.PROGRAM_APPLICATION_ID
			 ,x_stmv_rec.PROGRAM_ID
			 ,x_stmv_rec.PROGRAM_UPDATE_DATE
		  FROM DUAL;
/******* END Concurrent Manager COLUMN Assignment ******************/

      /*
       * veramach 19-Dec-2007 bug 6691567 - set values for date_history/date_current/date_working based on say_code
      */
      IF p_stmv_rec.say_code = 'CURR' AND (p_stmv_rec.date_current IS NULL OR p_stmv_rec.date_current = OKL_API.G_MISS_DATE) THEN
        x_stmv_rec.date_current := SYSDATE;
      END IF;
      IF p_stmv_rec.say_code = 'HIST' AND (p_stmv_rec.date_history IS NULL OR p_stmv_rec.date_history = OKL_API.G_MISS_DATE) THEN
        x_stmv_rec.date_history := SYSDATE;
      END IF;
      IF p_stmv_rec.say_code = 'WORK' AND (p_stmv_rec.date_working IS NULL OR p_stmv_rec.date_working = OKL_API.G_MISS_DATE) THEN
        x_stmv_rec.date_working := SYSDATE;
      END IF;
      /*
       * veramach 19-Dec-2007 bug 6691567 - set values for date_history/date_current/date_working based on say_code
      */

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
      p_stmv_rec,                        -- IN
      l_stmv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN


      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_stmv_rec, l_def_stmv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN


      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_stmv_rec := fill_who_columns(l_def_stmv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_stmv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN


      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_stmv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN


      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_stmv_rec, l_stm_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_stm_rec,
      lx_stm_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_stm_rec, l_def_stmv_rec);
    x_stmv_rec := l_def_stmv_rec;
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
  -- PL/SQL TBL update_row for:STMV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_tbl                     IN stmv_tbl_type,
    x_stmv_tbl                     OUT NOCOPY stmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_stmv_tbl.COUNT > 0) THEN
      i := p_stmv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stmv_rec                     => p_stmv_tbl(i),
          x_stmv_rec                     => x_stmv_tbl(i));
        /* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_stmv_tbl.LAST);
        i := p_stmv_tbl.NEXT(i);
      END LOOP;
    -- return the overall status
  x_return_status :=l_overall_status;
    END IF;
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
  --------------------------------
  -- delete_row for:OKL_STREAMS --
  --------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stm_rec                      IN stm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'STREAMS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stm_rec                      stm_rec_type:= p_stm_rec;
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
    DELETE FROM OKL_STREAMS
     WHERE ID = l_stm_rec.id;

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
  ----------------------------------
  -- delete_row for:OKL_STREAMS_V --
  ----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_rec                     IN stmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stmv_rec                     stmv_rec_type := p_stmv_rec;
    l_stm_rec                      stm_rec_type;
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
    migrate(l_stmv_rec, l_stm_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_stm_rec
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
  -- PL/SQL TBL delete_row for:STMV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_tbl                     IN stmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_stmv_tbl.COUNT > 0) THEN
      i := p_stmv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stmv_rec                     => p_stmv_tbl(i));

         /* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_stmv_tbl.LAST);
        i := p_stmv_tbl.NEXT(i);
      END LOOP;
   -- return the overall status
  x_return_status :=l_overall_status;

    END IF;
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
END Okl_Stm_Pvt;

/
