--------------------------------------------------------
--  DDL for Package Body OKL_SRM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SRM_PVT" AS
/* $Header: OKLSSRMB.pls 115.5 2002/12/18 13:09:41 kjinger noship $ */
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
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_RET_ERRORS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_srm_rec                      IN srm_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN srm_rec_type IS
    CURSOR srm_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SIR_ID,
            ERROR_CODE,
            ERROR_MESSAGE,
            TAG_NAME,
            TAG_ATTRIBUTE_NAME,
            TAG_ATTRIBUTE_VALUE,
            DESCRIPTION,
			STREAM_INTERFACE_ATTRIBUTE01,
			STREAM_INTERFACE_ATTRIBUTE02,
			STREAM_INTERFACE_ATTRIBUTE03,
			STREAM_INTERFACE_ATTRIBUTE04,
			STREAM_INTERFACE_ATTRIBUTE05,
			STREAM_INTERFACE_ATTRIBUTE06,
			STREAM_INTERFACE_ATTRIBUTE07,
			STREAM_INTERFACE_ATTRIBUTE08,
			STREAM_INTERFACE_ATTRIBUTE09,
			STREAM_INTERFACE_ATTRIBUTE10,
			STREAM_INTERFACE_ATTRIBUTE11,
			STREAM_INTERFACE_ATTRIBUTE12,
			STREAM_INTERFACE_ATTRIBUTE13,
			STREAM_INTERFACE_ATTRIBUTE14,
   			STREAM_INTERFACE_ATTRIBUTE15,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Sif_Ret_Errors
     WHERE okl_sif_ret_errors.id = p_id;
    l_srm_pk                       srm_pk_csr%ROWTYPE;
    l_srm_rec                      srm_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN srm_pk_csr (p_srm_rec.id);
    FETCH srm_pk_csr INTO
              l_srm_rec.ID,
              l_srm_rec.SIR_ID,
              l_srm_rec.ERROR_CODE,
              l_srm_rec.ERROR_MESSAGE,
              l_srm_rec.TAG_NAME,
              l_srm_rec.TAG_ATTRIBUTE_NAME,
              l_srm_rec.TAG_ATTRIBUTE_VALUE,
              l_srm_rec.DESCRIPTION,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE01,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE02,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE03,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE04,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE05,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE06,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE07,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE08,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE09,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE10,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE11,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE12,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE13,
			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE14,
   			  l_srm_rec.STREAM_INTERFACE_ATTRIBUTE15,
              l_srm_rec.OBJECT_VERSION_NUMBER,
              l_srm_rec.CREATED_BY,
              l_srm_rec.LAST_UPDATED_BY,
              l_srm_rec.CREATION_DATE,
              l_srm_rec.LAST_UPDATE_DATE,
              l_srm_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := srm_pk_csr%NOTFOUND;
    CLOSE srm_pk_csr;
    RETURN(l_srm_rec);
  END get_rec;

  FUNCTION get_rec (
    p_srm_rec                      IN srm_rec_type
  ) RETURN srm_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_srm_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_RET_ERRORS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_srmv_rec                     IN srmv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN srmv_rec_type IS
    CURSOR srmv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SIR_ID,
            ERROR_CODE,
            ERROR_MESSAGE,
            TAG_NAME,
            TAG_ATTRIBUTE_NAME,
            TAG_ATTRIBUTE_VALUE,
            DESCRIPTION,
			STREAM_INTERFACE_ATTRIBUTE01,
			STREAM_INTERFACE_ATTRIBUTE02,
			STREAM_INTERFACE_ATTRIBUTE03,
			STREAM_INTERFACE_ATTRIBUTE04,
			STREAM_INTERFACE_ATTRIBUTE05,
			STREAM_INTERFACE_ATTRIBUTE06,
			STREAM_INTERFACE_ATTRIBUTE07,
			STREAM_INTERFACE_ATTRIBUTE08,
			STREAM_INTERFACE_ATTRIBUTE09,
			STREAM_INTERFACE_ATTRIBUTE10,
			STREAM_INTERFACE_ATTRIBUTE11,
			STREAM_INTERFACE_ATTRIBUTE12,
			STREAM_INTERFACE_ATTRIBUTE13,
			STREAM_INTERFACE_ATTRIBUTE14,
   			STREAM_INTERFACE_ATTRIBUTE15,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_SIF_RET_ERRORS_V
     WHERE OKL_SIF_RET_ERRORS_V.id = p_id;
    l_srmv_pk                      srmv_pk_csr%ROWTYPE;
    l_srmv_rec                     srmv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN srmv_pk_csr (p_srmv_rec.id);
    FETCH srmv_pk_csr INTO
              l_srmv_rec.ID,
              l_srmv_rec.SIR_ID,
              l_srmv_rec.ERROR_CODE,
              l_srmv_rec.ERROR_MESSAGE,
              l_srmv_rec.TAG_NAME,
              l_srmv_rec.TAG_ATTRIBUTE_NAME,
              l_srmv_rec.TAG_ATTRIBUTE_VALUE,
              l_srmv_rec.DESCRIPTION,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE01,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE02,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE03,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE04,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE05,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE06,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE07,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE08,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE09,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE10,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE11,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE12,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE13,
			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE14,
   			  l_srmv_rec.STREAM_INTERFACE_ATTRIBUTE15,
              l_srmv_rec.OBJECT_VERSION_NUMBER,
              l_srmv_rec.CREATED_BY,
              l_srmv_rec.LAST_UPDATED_BY,
              l_srmv_rec.CREATION_DATE,
              l_srmv_rec.LAST_UPDATE_DATE,
              l_srmv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := srmv_pk_csr%NOTFOUND;
    CLOSE srmv_pk_csr;
    RETURN(l_srmv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_srmv_rec                     IN srmv_rec_type
  ) RETURN srmv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_srmv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SIF_RET_ERRORS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_srmv_rec	IN srmv_rec_type
  ) RETURN srmv_rec_type IS
    l_srmv_rec	srmv_rec_type := p_srmv_rec;
  BEGIN
    IF (l_srmv_rec.id = OKC_API.G_MISS_NUM) THEN
      l_srmv_rec.id := NULL;
    END IF;
    IF (l_srmv_rec.error_code = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.error_code := NULL;
    END IF;
    IF (l_srmv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.description := NULL;
    END IF;
    IF (l_srmv_rec.tag_attribute_name = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.tag_attribute_name := NULL;
    END IF;
    IF (l_srmv_rec.tag_name = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.tag_name := NULL;
    END IF;
    IF (l_srmv_rec.sir_id = OKC_API.G_MISS_NUM) THEN
      l_srmv_rec.sir_id := NULL;
    END IF;
    IF (l_srmv_rec.error_message = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.error_message := NULL;
    END IF;
    IF (l_srmv_rec.tag_attribute_value = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.tag_attribute_value := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute01 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute02 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute03 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute04 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute05 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute06 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute07 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute08 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute09 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute10 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute11 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute12 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute13 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute14 := NULL;
    END IF;
    IF (l_srmv_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_srmv_rec.stream_interface_attribute15 := NULL;
    END IF;
    IF (l_srmv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_srmv_rec.object_version_number := NULL;
    END IF;
    IF (l_srmv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_srmv_rec.created_by := NULL;
    END IF;
    IF (l_srmv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_srmv_rec.last_updated_by := NULL;
    END IF;
    IF (l_srmv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_srmv_rec.creation_date := NULL;
    END IF;
    IF (l_srmv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_srmv_rec.last_update_date := NULL;
    END IF;
    IF (l_srmv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_srmv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_srmv_rec);
  END null_out_defaults;

  -- START CHANGE AKJAIN
  -- commented the tapi generated code in favour of hand coded validate methods
  /*
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKL_SIF_RET_ERRORS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_srmv_rec IN  srmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_srmv_rec.id = OKC_API.G_MISS_NUM OR
       p_srmv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_srmv_rec.sir_id = OKC_API.G_MISS_NUM OR
          p_srmv_rec.sir_id IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sir_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  */


--------------------------------------------------------------------------
-- PROCEDURE Validate_Id
--------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : Validate_Id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
 ---------------------------------------------------------------------------

  PROCEDURE Validate_Id(p_srmv_rec IN  srmv_rec_type,x_return_status OUT NOCOPY  VARCHAR2)

          IS

          l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

          BEGIN
            -- initialize return status
            x_return_status := Okc_Api.G_RET_STS_SUCCESS;
            -- check for data before processing
            IF (p_srmv_rec.id = Okc_Api.G_MISS_NUM) OR
    	           (p_srmv_rec.id IS NULL)      THEN

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

  --------------------------------------------------------------------------
  -- PROCEDURE Validate_Sir_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sir_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Sir_Id( p_srmv_rec IN  srmv_rec_type
		 	   ,x_return_status OUT NOCOPY  VARCHAR2 ) IS

    CURSOR l_sirid_csr IS
            SELECT '1'
            FROM OKL_SIF_RETS
            WHERE ID = p_srmv_rec.sir_id;

     l_dummy_sir_id  VARCHAR2(1);
     l_row_notfound  BOOLEAN :=TRUE;
   BEGIN
   -- initialize return status
     x_return_status := Okc_Api.G_RET_STS_SUCCESS;
   -- check for data before processing
     IF (p_srmv_rec.sir_id IS NULL) OR
        (p_srmv_rec.sir_id  = Okc_Api.G_MISS_NUM)
     THEN
       Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
  	                  ,p_msg_name       => g_required_value
  	                  ,p_token1         => g_col_name_token
  	                  ,p_token1_value   => 'sir_id');
  	  	           x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;

     ELSIF p_srmv_rec.sir_id IS NOT NULL THEN
     --Check if sir_id exists in the stream level table or not
       OPEN l_sirid_csr;
       FETCH l_sirid_csr INTO l_dummy_sir_id;
       l_row_notfound :=l_sirid_csr%NOTFOUND;
       CLOSE l_sirid_csr;
       IF(l_row_notfound ) THEN
         OKC_API.SET_MESSAGE(G_APP_NAME,G_OKL_NO_PARENT_RECORD,G_COL_NAME_TOKEN,'SIR_ID',G_CHILD_TABLE_TOKEN,'OKL_STRM_ELEMENTS_V',G_PARENT_TABLE_TOKEN,'OKL_STREAM_LEVELS_V');
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

       IF l_sirid_csr%ISOPEN
       THEN
	   CLOSE l_sirid_csr;
       END IF;
  END Validate_sir_Id;

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

PROCEDURE Validate_Object_Version_Number(p_srmv_rec IN  srmv_rec_type,x_return_status OUT NOCOPY  VARCHAR2)

    IS

    l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

    BEGIN
      -- initialize return status
      x_return_status := Okc_Api.G_RET_STS_SUCCESS;
      -- check for data before processing
      IF (p_srmv_rec.object_version_number IS NULL) OR
	 (p_srmv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
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
    	    	    p_srmv_rec IN  srmv_rec_type
    	    	  ) RETURN VARCHAR2 IS

    	    	    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    	    	    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    	    	  BEGIN

    	    	     -- call each column-level validation


    	    	    -- Validate_Id
    	    	    Validate_Id(p_srmv_rec, x_return_status);
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
    	    	    Validate_Object_Version_Number(p_srmv_rec, x_return_status);
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

    	    	    -- Validate_Sir_Id
    	    	       Validate_Sir_Id(p_srmv_rec, x_return_status);

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



  -- END CHANGE AKJAIN


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKL_SIF_RET_ERRORS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_srmv_rec IN srmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN  srmv_rec_type,
    p_to	IN OUT NOCOPY srm_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sir_id := p_from.sir_id;
    p_to.error_code := p_from.error_code;
    p_to.error_message := p_from.error_message;
    p_to.tag_name := p_from.tag_name;
    p_to.tag_attribute_name := p_from.tag_attribute_name;
    p_to.tag_attribute_value := p_from.tag_attribute_value;
    p_to.description := p_from.description;
    p_to.stream_interface_attribute01 := p_from.stream_interface_attribute01;
    p_to.stream_interface_attribute02 := p_from.stream_interface_attribute02;
    p_to.stream_interface_attribute03 := p_from.stream_interface_attribute03;
    p_to.stream_interface_attribute04 := p_from.stream_interface_attribute04;
    p_to.stream_interface_attribute05 := p_from.stream_interface_attribute05;
    p_to.stream_interface_attribute06 := p_from.stream_interface_attribute06;
    p_to.stream_interface_attribute07 := p_from.stream_interface_attribute07;
    p_to.stream_interface_attribute08 := p_from.stream_interface_attribute08;
    p_to.stream_interface_attribute09 := p_from.stream_interface_attribute09;
    p_to.stream_interface_attribute10 := p_from.stream_interface_attribute10;
    p_to.stream_interface_attribute11 := p_from.stream_interface_attribute11;
    p_to.stream_interface_attribute12 := p_from.stream_interface_attribute12;
    p_to.stream_interface_attribute13 := p_from.stream_interface_attribute13;
    p_to.stream_interface_attribute14 := p_from.stream_interface_attribute14;
    p_to.stream_interface_attribute15 := p_from.stream_interface_attribute15;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN  srm_rec_type,
    p_to	IN OUT NOCOPY srmv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sir_id := p_from.sir_id;
    p_to.error_code := p_from.error_code;
    p_to.error_message := p_from.error_message;
    p_to.tag_name := p_from.tag_name;
    p_to.tag_attribute_name := p_from.tag_attribute_name;
    p_to.tag_attribute_value := p_from.tag_attribute_value;
    p_to.description := p_from.description;
    p_to.stream_interface_attribute01 := p_from.stream_interface_attribute01;
    p_to.stream_interface_attribute02 := p_from.stream_interface_attribute02;
    p_to.stream_interface_attribute03 := p_from.stream_interface_attribute03;
    p_to.stream_interface_attribute04 := p_from.stream_interface_attribute04;
    p_to.stream_interface_attribute05 := p_from.stream_interface_attribute05;
    p_to.stream_interface_attribute06 := p_from.stream_interface_attribute06;
    p_to.stream_interface_attribute07 := p_from.stream_interface_attribute07;
    p_to.stream_interface_attribute08 := p_from.stream_interface_attribute08;
    p_to.stream_interface_attribute09 := p_from.stream_interface_attribute09;
    p_to.stream_interface_attribute10 := p_from.stream_interface_attribute10;
    p_to.stream_interface_attribute11 := p_from.stream_interface_attribute11;
    p_to.stream_interface_attribute12 := p_from.stream_interface_attribute12;
    p_to.stream_interface_attribute13 := p_from.stream_interface_attribute13;
    p_to.stream_interface_attribute14 := p_from.stream_interface_attribute14;
    p_to.stream_interface_attribute15 := p_from.stream_interface_attribute15;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for:OKL_SIF_RET_ERRORS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_rec                     IN srmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srmv_rec                     srmv_rec_type := p_srmv_rec;
    l_srm_rec                      srm_rec_type;
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
    l_return_status := Validate_Attributes(l_srmv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_srmv_rec);
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
  -- PL/SQL TBL validate_row for:SRMV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_tbl                     IN srmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 11/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srmv_tbl.COUNT > 0) THEN
      i := p_srmv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srmv_rec                     => p_srmv_tbl(i));
        -- START change : akjain, 11/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain

        EXIT WHEN (i = p_srmv_tbl.LAST);
        i := p_srmv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 11/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain

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
  ---------------------------------------
  -- insert_row for:OKL_SIF_RET_ERRORS --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srm_rec                      IN srm_rec_type,
    x_srm_rec                      OUT NOCOPY srm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ERRORS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srm_rec                      srm_rec_type := p_srm_rec;
    l_def_srm_rec                  srm_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_ERRORS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_srm_rec IN  srm_rec_type,
      x_srm_rec OUT NOCOPY srm_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srm_rec := p_srm_rec;
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
      p_srm_rec,                         -- IN
      l_srm_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SIF_RET_ERRORS(
        id,
        sir_id,
        error_code,
        error_message,
        tag_name,
        tag_attribute_name,
        tag_attribute_value,
        description,
		stream_interface_attribute01,
		stream_interface_attribute02,
		stream_interface_attribute03,
		stream_interface_attribute04,
		stream_interface_attribute05,
		stream_interface_attribute06,
		stream_interface_attribute07,
		stream_interface_attribute08,
		stream_interface_attribute09,
		stream_interface_attribute10,
		stream_interface_attribute11,
		stream_interface_attribute12,
		stream_interface_attribute13,
		stream_interface_attribute14,
     	stream_interface_attribute15,
        object_version_number,
        created_by,
        last_updated_by,
        creation_date,
        last_update_date,
        last_update_login)
      VALUES (
        l_srm_rec.id,
        l_srm_rec.sir_id,
        l_srm_rec.error_code,
        l_srm_rec.error_message,
        l_srm_rec.tag_name,
        l_srm_rec.tag_attribute_name,
        l_srm_rec.tag_attribute_value,
        l_srm_rec.description,
		l_srm_rec.stream_interface_attribute01,
		l_srm_rec.stream_interface_attribute02,
		l_srm_rec.stream_interface_attribute03,
		l_srm_rec.stream_interface_attribute04,
		l_srm_rec.stream_interface_attribute05,
		l_srm_rec.stream_interface_attribute06,
		l_srm_rec.stream_interface_attribute07,
		l_srm_rec.stream_interface_attribute08,
		l_srm_rec.stream_interface_attribute09,
		l_srm_rec.stream_interface_attribute10,
		l_srm_rec.stream_interface_attribute11,
		l_srm_rec.stream_interface_attribute12,
		l_srm_rec.stream_interface_attribute13,
		l_srm_rec.stream_interface_attribute14,
		l_srm_rec.stream_interface_attribute15,
        l_srm_rec.object_version_number,
        l_srm_rec.created_by,
        l_srm_rec.last_updated_by,
        l_srm_rec.creation_date,
        l_srm_rec.last_update_date,
        l_srm_rec.last_update_login);
    -- Set OUT values
    x_srm_rec := l_srm_rec;
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
  -- insert_row for:OKL_SIF_RET_ERRORS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_rec                     IN srmv_rec_type,
    x_srmv_rec                     OUT NOCOPY srmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srmv_rec                     srmv_rec_type;
    l_def_srmv_rec                 srmv_rec_type;
    l_srm_rec                      srm_rec_type;
    lx_srm_rec                     srm_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_srmv_rec	IN srmv_rec_type
    ) RETURN srmv_rec_type IS
      l_srmv_rec	srmv_rec_type := p_srmv_rec;
    BEGIN
      l_srmv_rec.CREATION_DATE := SYSDATE;
      l_srmv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_srmv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_srmv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_srmv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_srmv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_ERRORS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_srmv_rec IN  srmv_rec_type,
      x_srmv_rec OUT NOCOPY srmv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srmv_rec := p_srmv_rec;
      x_srmv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_srmv_rec := null_out_defaults(p_srmv_rec);
    -- Set primary key value
    l_srmv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_srmv_rec,                        -- IN
      l_def_srmv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_srmv_rec := fill_who_columns(l_def_srmv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_srmv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_srmv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_srmv_rec, l_srm_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_srm_rec,
      lx_srm_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_srm_rec, l_def_srmv_rec);
    -- Set OUT values
    x_srmv_rec := l_def_srmv_rec;
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
  -- PL/SQL TBL insert_row for:SRMV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_tbl                     IN srmv_tbl_type,
    x_srmv_tbl                     OUT NOCOPY srmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 11/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srmv_tbl.COUNT > 0) THEN
      i := p_srmv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srmv_rec                     => p_srmv_tbl(i),
          x_srmv_rec                     => x_srmv_tbl(i));
        -- START change : akjain, 11/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain

        EXIT WHEN (i = p_srmv_tbl.LAST);
        i := p_srmv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 11/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain

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

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- lock_row for:OKL_SIF_RET_ERRORS --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srm_rec                      IN srm_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_srm_rec IN srm_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_RET_ERRORS
     WHERE ID = p_srm_rec.id
       AND OBJECT_VERSION_NUMBER = p_srm_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_srm_rec IN srm_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_RET_ERRORS
    WHERE ID = p_srm_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ERRORS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SIF_RET_ERRORS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SIF_RET_ERRORS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_srm_rec);
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
      OPEN lchk_csr(p_srm_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_srm_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_srm_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for:OKL_SIF_RET_ERRORS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_rec                     IN srmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srm_rec                      srm_rec_type;
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
    migrate(p_srmv_rec, l_srm_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_srm_rec
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
  -- PL/SQL TBL lock_row for:SRMV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_tbl                     IN srmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 11/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srmv_tbl.COUNT > 0) THEN
      i := p_srmv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srmv_rec                     => p_srmv_tbl(i));
        -- START change : akjain, 11/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain

        EXIT WHEN (i = p_srmv_tbl.LAST);
        i := p_srmv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 11/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain

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
  ---------------------------------------
  -- update_row for:OKL_SIF_RET_ERRORS --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srm_rec                      IN srm_rec_type,
    x_srm_rec                      OUT NOCOPY srm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ERRORS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srm_rec                      srm_rec_type := p_srm_rec;
    l_def_srm_rec                  srm_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_srm_rec	IN srm_rec_type,
      x_srm_rec	OUT NOCOPY srm_rec_type
    ) RETURN VARCHAR2 IS
      l_srm_rec                      srm_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srm_rec := p_srm_rec;
      -- Get current database values
      l_srm_rec := get_rec(p_srm_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_srm_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_srm_rec.id := l_srm_rec.id;
      END IF;
      IF (x_srm_rec.sir_id = OKC_API.G_MISS_NUM)
      THEN
        x_srm_rec.sir_id := l_srm_rec.sir_id;
      END IF;
      IF (x_srm_rec.error_code = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.error_code := l_srm_rec.error_code;
      END IF;
      IF (x_srm_rec.error_message = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.error_message := l_srm_rec.error_message;
      END IF;
      IF (x_srm_rec.tag_name = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.tag_name := l_srm_rec.tag_name;
      END IF;
      IF (x_srm_rec.tag_attribute_name = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.tag_attribute_name := l_srm_rec.tag_attribute_name;
      END IF;
      IF (x_srm_rec.tag_attribute_value = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.tag_attribute_value := l_srm_rec.tag_attribute_value;
      END IF;
      IF (x_srm_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.description := l_srm_rec.description;
      END IF;
      IF (x_srm_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute01 := l_srm_rec.stream_interface_attribute01;
      END IF;
      IF (x_srm_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute02 := l_srm_rec.stream_interface_attribute02;
      END IF;
      IF (x_srm_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute03 := l_srm_rec.stream_interface_attribute03;
      END IF;
      IF (x_srm_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute04 := l_srm_rec.stream_interface_attribute04;
      END IF;
      IF (x_srm_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute05 := l_srm_rec.stream_interface_attribute05;
      END IF;
      IF (x_srm_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute06 := l_srm_rec.stream_interface_attribute06;
      END IF;
      IF (x_srm_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute07 := l_srm_rec.stream_interface_attribute07;
      END IF;
      IF (x_srm_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute08 := l_srm_rec.stream_interface_attribute08;
      END IF;
      IF (x_srm_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute09 := l_srm_rec.stream_interface_attribute09;
      END IF;
      IF (x_srm_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute10 := l_srm_rec.stream_interface_attribute10;
      END IF;
      IF (x_srm_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute11 := l_srm_rec.stream_interface_attribute11;
      END IF;
      IF (x_srm_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute12 := l_srm_rec.stream_interface_attribute12;
      END IF;
      IF (x_srm_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute13 := l_srm_rec.stream_interface_attribute13;
      END IF;
      IF (x_srm_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute14 := l_srm_rec.stream_interface_attribute14;
      END IF;
      IF (x_srm_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_srm_rec.stream_interface_attribute15 := l_srm_rec.stream_interface_attribute15;
      END IF;
      IF (x_srm_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_srm_rec.object_version_number := l_srm_rec.object_version_number;
      END IF;
      IF (x_srm_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_srm_rec.created_by := l_srm_rec.created_by;
      END IF;
      IF (x_srm_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_srm_rec.last_updated_by := l_srm_rec.last_updated_by;
      END IF;
      IF (x_srm_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_srm_rec.creation_date := l_srm_rec.creation_date;
      END IF;
      IF (x_srm_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_srm_rec.last_update_date := l_srm_rec.last_update_date;
      END IF;
      IF (x_srm_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_srm_rec.last_update_login := l_srm_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_ERRORS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_srm_rec IN  srm_rec_type,
      x_srm_rec OUT NOCOPY srm_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srm_rec := p_srm_rec;
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
      p_srm_rec,                         -- IN
      l_srm_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_srm_rec, l_def_srm_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SIF_RET_ERRORS
    SET SIR_ID = l_def_srm_rec.sir_id,
        ERROR_CODE = l_def_srm_rec.error_code,
        ERROR_MESSAGE = l_def_srm_rec.error_message,
        TAG_NAME = l_def_srm_rec.tag_name,
        TAG_ATTRIBUTE_NAME = l_def_srm_rec.tag_attribute_name,
        TAG_ATTRIBUTE_VALUE = l_def_srm_rec.tag_attribute_value,
        DESCRIPTION = l_def_srm_rec.description,
		STREAM_INTERFACE_ATTRIBUTE01 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE01,
		STREAM_INTERFACE_ATTRIBUTE02 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE02,
		STREAM_INTERFACE_ATTRIBUTE03 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE03,
		STREAM_INTERFACE_ATTRIBUTE04 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE04,
		STREAM_INTERFACE_ATTRIBUTE05 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE05,
		STREAM_INTERFACE_ATTRIBUTE06 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE06,
		STREAM_INTERFACE_ATTRIBUTE07 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE07,
		STREAM_INTERFACE_ATTRIBUTE08 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE08,
		STREAM_INTERFACE_ATTRIBUTE09 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE09,
		STREAM_INTERFACE_ATTRIBUTE10 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE10,
		STREAM_INTERFACE_ATTRIBUTE11 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE11,
		STREAM_INTERFACE_ATTRIBUTE12 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE12,
		STREAM_INTERFACE_ATTRIBUTE13 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE13,
		STREAM_INTERFACE_ATTRIBUTE14 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE14,
		STREAM_INTERFACE_ATTRIBUTE15 = l_def_srm_rec.STREAM_INTERFACE_ATTRIBUTE15,
        OBJECT_VERSION_NUMBER = l_def_srm_rec.object_version_number,
        CREATED_BY = l_def_srm_rec.created_by,
        LAST_UPDATED_BY = l_def_srm_rec.last_updated_by,
        CREATION_DATE = l_def_srm_rec.creation_date,
        LAST_UPDATE_DATE = l_def_srm_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_srm_rec.last_update_login
    WHERE ID = l_def_srm_rec.id;

    x_srm_rec := l_def_srm_rec;
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
  -- update_row for:OKL_SIF_RET_ERRORS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_rec                     IN srmv_rec_type,
    x_srmv_rec                     OUT NOCOPY srmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srmv_rec                     srmv_rec_type := p_srmv_rec;
    l_def_srmv_rec                 srmv_rec_type;
    l_srm_rec                      srm_rec_type;
    lx_srm_rec                     srm_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_srmv_rec	IN srmv_rec_type
    ) RETURN srmv_rec_type IS
      l_srmv_rec	srmv_rec_type := p_srmv_rec;
    BEGIN
      l_srmv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_srmv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_srmv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_srmv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_srmv_rec	IN srmv_rec_type,
      x_srmv_rec	OUT NOCOPY srmv_rec_type
    ) RETURN VARCHAR2 IS
      l_srmv_rec                     srmv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srmv_rec := p_srmv_rec;
      -- Get current database values
      l_srmv_rec := get_rec(p_srmv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_srmv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_srmv_rec.id := l_srmv_rec.id;
      END IF;
      IF (x_srmv_rec.error_code = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.error_code := l_srmv_rec.error_code;
      END IF;
      IF (x_srmv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.description := l_srmv_rec.description;
      END IF;
      IF (x_srmv_rec.tag_attribute_name = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.tag_attribute_name := l_srmv_rec.tag_attribute_name;
      END IF;
      IF (x_srmv_rec.tag_name = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.tag_name := l_srmv_rec.tag_name;
      END IF;
      IF (x_srmv_rec.sir_id = OKC_API.G_MISS_NUM)
      THEN
        x_srmv_rec.sir_id := l_srmv_rec.sir_id;
      END IF;
      IF (x_srmv_rec.error_message = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.error_message := l_srmv_rec.error_message;
      END IF;
      IF (x_srmv_rec.tag_attribute_value = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.tag_attribute_value := l_srmv_rec.tag_attribute_value;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute01 := l_srmv_rec.stream_interface_attribute01;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute02 := l_srmv_rec.stream_interface_attribute02;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute03 := l_srmv_rec.stream_interface_attribute03;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute04 := l_srmv_rec.stream_interface_attribute04;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute05 := l_srmv_rec.stream_interface_attribute05;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute06 := l_srmv_rec.stream_interface_attribute06;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute07 := l_srmv_rec.stream_interface_attribute07;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute08 := l_srmv_rec.stream_interface_attribute08;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute09 := l_srmv_rec.stream_interface_attribute09;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute10 := l_srmv_rec.stream_interface_attribute10;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute11 := l_srmv_rec.stream_interface_attribute11;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute12 := l_srmv_rec.stream_interface_attribute12;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute13 := l_srmv_rec.stream_interface_attribute13;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute14 := l_srmv_rec.stream_interface_attribute14;
      END IF;
      IF (x_srmv_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_srmv_rec.stream_interface_attribute15 := l_srmv_rec.stream_interface_attribute15;
      END IF;
      IF (x_srmv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_srmv_rec.object_version_number := l_srmv_rec.object_version_number;
      END IF;
      IF (x_srmv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_srmv_rec.created_by := l_srmv_rec.created_by;
      END IF;
      IF (x_srmv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_srmv_rec.last_updated_by := l_srmv_rec.last_updated_by;
      END IF;
      IF (x_srmv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_srmv_rec.creation_date := l_srmv_rec.creation_date;
      END IF;
      IF (x_srmv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_srmv_rec.last_update_date := l_srmv_rec.last_update_date;
      END IF;
      IF (x_srmv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_srmv_rec.last_update_login := l_srmv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_ERRORS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_srmv_rec IN  srmv_rec_type,
      x_srmv_rec OUT NOCOPY srmv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srmv_rec := p_srmv_rec;
      x_srmv_rec.OBJECT_VERSION_NUMBER := NVL(x_srmv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_srmv_rec,                        -- IN
      l_srmv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_srmv_rec, l_def_srmv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_srmv_rec := fill_who_columns(l_def_srmv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_srmv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_srmv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_srmv_rec, l_srm_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_srm_rec,
      lx_srm_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_srm_rec, l_def_srmv_rec);
    x_srmv_rec := l_def_srmv_rec;
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
  -- PL/SQL TBL update_row for:SRMV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_tbl                     IN srmv_tbl_type,
    x_srmv_tbl                     OUT NOCOPY srmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 11/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srmv_tbl.COUNT > 0) THEN
      i := p_srmv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srmv_rec                     => p_srmv_tbl(i),
          x_srmv_rec                     => x_srmv_tbl(i));
        -- START change : akjain, 11/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain

        EXIT WHEN (i = p_srmv_tbl.LAST);
        i := p_srmv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 11/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain

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
  ---------------------------------------
  -- delete_row for:OKL_SIF_RET_ERRORS --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srm_rec                      IN srm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ERRORS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srm_rec                      srm_rec_type:= p_srm_rec;
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
    DELETE FROM OKL_SIF_RET_ERRORS
     WHERE ID = l_srm_rec.id;

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
  -- delete_row for:OKL_SIF_RET_ERRORS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_rec                     IN srmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srmv_rec                     srmv_rec_type := p_srmv_rec;
    l_srm_rec                      srm_rec_type;
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
    migrate(l_srmv_rec, l_srm_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_srm_rec
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
  -- PL/SQL TBL delete_row for:SRMV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_tbl                     IN srmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 11/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srmv_tbl.COUNT > 0) THEN
      i := p_srmv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srmv_rec                     => p_srmv_tbl(i));
        -- START change : akjain, 11/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain

        EXIT WHEN (i = p_srmv_tbl.LAST);
        i := p_srmv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 11/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain

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
END OKL_SRM_PVT;

/
