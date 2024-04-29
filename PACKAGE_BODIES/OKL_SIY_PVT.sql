--------------------------------------------------------
--  DDL for Package Body OKL_SIY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SIY_PVT" AS
/* $Header: OKLSSIYB.pls 115.8 2002/12/18 13:08:44 kjinger noship $ */
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
  -- FUNCTION get_rec for: OKL_SIF_YIELDS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_siy_rec                      IN siy_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN siy_rec_type IS
    CURSOR siy_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            YIELD_NAME,
            OBJECT_VERSION_NUMBER,
            SIF_ID,
            METHOD,
            ARRAY_TYPE,
            ROE_TYPE,
            ROE_BASE,
            COMPOUNDED_METHOD,
            TARGET_VALUE,
            INDEX_NUMBER,
            NOMINAL_YN,
            PRE_TAX_YN,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Sif_Yields
     WHERE okl_sif_yields.id    = p_id ;
    l_siy_pk                       siy_pk_csr%ROWTYPE;
    l_siy_rec                      siy_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN siy_pk_csr (p_siy_rec.id);
    FETCH siy_pk_csr INTO
            l_siy_rec.ID,
            l_siy_rec.YIELD_NAME,
            l_siy_rec.OBJECT_VERSION_NUMBER,
            l_siy_rec.SIF_ID,
            l_siy_rec.METHOD,
            l_siy_rec.ARRAY_TYPE,
            l_siy_rec.ROE_TYPE,
            l_siy_rec.ROE_BASE,
            l_siy_rec.COMPOUNDED_METHOD,
            l_siy_rec.TARGET_VALUE,
            l_siy_rec.INDEX_NUMBER,
            l_siy_rec.NOMINAL_YN,
            l_siy_rec.PRE_TAX_YN,
            l_siy_rec.CREATED_BY,
            l_siy_rec.LAST_UPDATED_BY,
            l_siy_rec.CREATION_DATE,
            l_siy_rec.LAST_UPDATE_DATE,
            l_siy_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := siy_pk_csr%NOTFOUND;
    CLOSE siy_pk_csr;
    RETURN(l_siy_rec);
  END get_rec;

  FUNCTION get_rec (
    p_siy_rec                      IN siy_rec_type
  ) RETURN siy_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_siy_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_YIELDS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_siyv_rec                     IN siyv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN siyv_rec_type IS
    CURSOR siyv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            YIELD_NAME,
            OBJECT_VERSION_NUMBER,
            SIF_ID,
            METHOD,
            ARRAY_TYPE,
            ROE_TYPE,
            ROE_BASE,
            COMPOUNDED_METHOD,
            TARGET_VALUE,
            INDEX_NUMBER,
            NOMINAL_YN,
            PRE_TAX_YN,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Sif_Yields_V
     WHERE okl_sif_yields_v.id  = p_id;
    l_siyv_pk                      siyv_pk_csr%ROWTYPE;
    l_siyv_rec                     siyv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN siyv_pk_csr (p_siyv_rec.id);
    FETCH siyv_pk_csr INTO
              l_siyv_rec.ID,
              l_siyv_rec.YIELD_NAME,
              l_siyv_rec.OBJECT_VERSION_NUMBER,
              l_siyv_rec.SIF_ID,
              l_siyv_rec.METHOD,
              l_siyv_rec.ARRAY_TYPE,
              l_siyv_rec.ROE_TYPE,
              l_siyv_rec.ROE_BASE,
              l_siyv_rec.COMPOUNDED_METHOD,
              l_siyv_rec.TARGET_VALUE,
              l_siyv_rec.INDEX_NUMBER,
              l_siyv_rec.NOMINAL_YN,
              l_siyv_rec.PRE_TAX_YN,
              l_siyv_rec.CREATED_BY,
              l_siyv_rec.LAST_UPDATED_BY,
              l_siyv_rec.CREATION_DATE,
              l_siyv_rec.LAST_UPDATE_DATE,
              l_siyv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := siyv_pk_csr%NOTFOUND;
    CLOSE siyv_pk_csr;
    RETURN(l_siyv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_siyv_rec                     IN siyv_rec_type
  ) RETURN siyv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_siyv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SIF_YIELDS_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_siyv_rec	IN siyv_rec_type
  ) RETURN siyv_rec_type IS
    l_siyv_rec	siyv_rec_type := p_siyv_rec;
  BEGIN
    IF (l_siyv_rec.yield_name = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.yield_name := NULL;
    END IF;
    IF (l_siyv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_siyv_rec.object_version_number := NULL;
    END IF;
    IF (l_siyv_rec.sif_id = OKC_API.G_MISS_NUM) THEN
      l_siyv_rec.sif_id := NULL;
    END IF;
    IF (l_siyv_rec.method = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.method := NULL;
    END IF;
    IF (l_siyv_rec.array_type = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.array_type := NULL;
    END IF;
    IF (l_siyv_rec.roe_type = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.roe_type := NULL;
    END IF;
    IF (l_siyv_rec.roe_base = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.roe_base := NULL;
    END IF;
    IF (l_siyv_rec.compounded_method = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.compounded_method := NULL;
    END IF;
    IF (l_siyv_rec.target_value = OKC_API.G_MISS_NUM) THEN
      l_siyv_rec.target_value := NULL;
    END IF;
    IF (l_siyv_rec.index_number = OKC_API.G_MISS_NUM) THEN
      l_siyv_rec.index_number := NULL;
    END IF;
    IF (l_siyv_rec.nominal_yn = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.nominal_yn := NULL;
    END IF;
    IF (l_siyv_rec.pre_tax_yn = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.pre_tax_yn := NULL;
    END IF;
    IF (l_siyv_rec.siy_type = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.siy_type := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute01 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute02 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute03 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute04 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute05 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute06 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute07 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute08 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute09 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute10 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute11 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute12 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute13 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute14 := NULL;
    END IF;
    IF (l_siyv_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_siyv_rec.stream_interface_attribute15 := NULL;
    END IF;
    IF (l_siyv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_siyv_rec.created_by := NULL;
    END IF;
    IF (l_siyv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_siyv_rec.last_updated_by := NULL;
    END IF;
    IF (l_siyv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_siyv_rec.creation_date := NULL;
    END IF;
    IF (l_siyv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_siyv_rec.last_update_date := NULL;
    END IF;
    IF (l_siyv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_siyv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_siyv_rec);
  END null_out_defaults;

  /* -- mvasudev -- 12/28/2001
  -- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_SIF_YIELDS_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_siyv_rec IN  siyv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_siyv_rec.id = OKC_API.G_MISS_NUM OR
       p_siyv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_siyv_rec.yield_name = OKC_API.G_MISS_CHAR OR
          p_siyv_rec.yield_name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'yield_name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_siyv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_siyv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_siyv_rec.sif_id = OKC_API.G_MISS_NUM OR
          p_siyv_rec.sif_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sif_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_siyv_rec.index_number = OKC_API.G_MISS_NUM OR
          p_siyv_rec.index_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'index_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
  */

   /**
  * Adding Individual Procedures for each Attribute that
  * needs to be validated
  */
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
  PROCEDURE Validate_Id(
    p_siyv_rec      IN   siyv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_siyv_rec.id = Okc_Api.G_MISS_NUM OR
       p_siyv_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
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
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

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
  PROCEDURE Validate_Object_Version_Number(
  	p_siyv_rec      IN   siyv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_siyv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
       p_siyv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
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
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Yield_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Yield_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Yield_Name(
    p_siyv_rec      IN   siyv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;


  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_siyv_rec.Yield_Name = Okc_Api.G_MISS_CHAR OR
       p_siyv_rec.Yield_Name IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Yield_Name');
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
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END Validate_Yield_Name;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sif_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sif_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sif_Id(
    p_siyv_rec      IN   siyv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SIF_FK;
  CURSOR okl_sifv_pk_csr (p_id IN OKL_SIF_YIELDS_V.sif_id%TYPE) IS
  SELECT '1'
    FROM OKL_STREAM_INTERFACES_V
   WHERE OKL_STREAM_INTERFACES_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_siyv_rec.sif_id = Okc_Api.G_MISS_NUM OR
       p_siyv_rec.sif_id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Sif_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_sifv_pk_csr(p_siyv_rec.Sif_id);
    FETCH okl_sifv_pk_csr INTO l_dummy;
    l_row_not_found := okl_sifv_pk_csr%NOTFOUND;
    CLOSE okl_sifv_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_APP_NAME,G_OKL_UNQS);
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_sifv_pk_csr%ISOPEN THEN
        CLOSE okl_sifv_pk_csr;
      END IF;

  END Validate_Sif_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Index_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Index_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Index_Number(
    p_siyv_rec      IN   siyv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_siyv_rec.Index_Number = Okc_Api.G_MISS_NUM OR
       p_siyv_rec.Index_Number IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Index_Number');
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
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Index_Number;

  /*
  -- Commented Validation as the expected valueset will not be
  -- in consistent with FND values but rather with Pricing_Engine Values
    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Nominal_Yn
    --------------------------------------------------------------------------
    -- Start of comments
    --Author           : mvasudev
    -- Procedure Name  : Validate_Nominal_Yn
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    Procedure Validate_Nominal_Yn( p_siyv_rec IN  siyv_rec_type,
                                           x_return_status OUT NOCOPY  VARCHAR2)

    IS
	  l_found VARCHAR2(1);

	  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      -- check for data before processing
	   	IF (p_siyv_rec.Nominal_Yn IS NOT NULL) AND
	    	        (p_siyv_rec.Nominal_Yn  <> Okc_Api.G_MISS_CHAR) THEN
			--Check if Nominal_Yn exists in the fnd_common_lookups or not
	        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'YES_NO',
   															  p_lookup_code => p_siyv_rec.Nominal_Yn,
															  p_app_id 		=> 0,
															  p_view_app_id => 0);


			IF (l_found <> OKL_API.G_TRUE ) THEN
	             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Nominal_Yn');
			     x_return_status := Okc_Api.G_RET_STS_ERROR;
				 -- raise the exception as there's no matching foreign key value
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
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Nominal_Yn;
  */

      ---------------------------------------------------------------------------
      -- PROCEDURE Validate_Pre_Tax_Yn
      --------------------------------------------------------------------------
      -- Start of comments
      --Author           : mvasudev
      -- Procedure Name  : Validate_Pre_Tax_Yn
      -- Description     :
      -- Business Rules  :
      -- Parameters      :
      -- Version         : 1.0
      -- End of comments
      ---------------------------------------------------------------------------

      PROCEDURE Validate_Pre_Tax_Yn( p_siyv_rec IN  siyv_rec_type,
                                             x_return_status OUT NOCOPY  VARCHAR2)

      IS
  	  l_found VARCHAR2(1);

  	  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        -- check for data before processing
  	   	IF (p_siyv_rec.pre_tax_yn IS NOT NULL) AND
  	    	        (p_siyv_rec.pre_tax_yn  <> Okc_Api.G_MISS_CHAR) THEN
  			--Check if pre_tax_yn exists in the fnd_common_lookups or not
  	        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'YES_NO',
     															  p_lookup_code => p_siyv_rec.pre_tax_yn,
  															  p_app_id 		=> 0,
  															  p_view_app_id => 0);


  			IF (l_found <> OKL_API.G_TRUE ) THEN
  	             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Pre_Tax_Yn');
  			     x_return_status := Okc_Api.G_RET_STS_ERROR;
  				 -- raise the exception as there's no matching foreign key value
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
            Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                                p_token1       => G_OKL_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2       => G_OKL_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);

          -- notify caller of an UNEXPECTED error
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Pre_Tax_Yn;

     -- mvasudev, 06/26/2002
      ---------------------------------------------------------------------------
      -- PROCEDURE Validate_Siy_Type
      --------------------------------------------------------------------------
      -- Start of comments
      --Author           : mvasudev
      -- Procedure Name  : Validate_Siy_Type
      -- Description     :
      -- Business Rules  :
      -- Parameters      :
      -- Version         : 1.0
      -- End of comments
      ---------------------------------------------------------------------------

      PROCEDURE Validate_Siy_Type( p_siyv_rec IN  siyv_rec_type,
                                             x_return_status OUT NOCOPY  VARCHAR2)

      IS
  	  l_found VARCHAR2(1);

  	  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

	    IF p_siyv_rec.Siy_Type = Okc_Api.G_MISS_CHAR OR
	       p_siyv_rec.Siy_Type IS NULL
	    THEN
	      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Siy_Type');
	      x_return_status := Okc_Api.G_RET_STS_ERROR;
	      RAISE G_EXCEPTION_HALT_VALIDATION;
	    ELSE
			--Check if Sfe_Type exists in the fnd_common_lookups or not
			l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_SIY_TYPE',
							    p_lookup_code => p_siyv_rec.siy_type);


			IF (l_found <> OKL_API.G_TRUE ) THEN
		            OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Siy_Type');
			    x_return_status := Okc_Api.G_RET_STS_ERROR;
				 -- raise the exception as there's no matching foreign key value
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
            Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                                p_token1       => G_OKL_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2       => G_OKL_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);

          -- notify caller of an UNEXPECTED error
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Siy_Type;


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
    p_siyv_rec IN  siyv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    -- Validate_Id
    Validate_Id(p_siyv_rec, x_return_status);
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
    Validate_Object_Version_Number(p_siyv_rec, x_return_status);
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



    -- Validate_Yield_Name
    Validate_Yield_Name(p_siyv_rec, x_return_status);
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


    -- Validate_Sif_Id
    Validate_Sif_Id(p_siyv_rec, x_return_status);
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

    -- Validate_Index_Number
    Validate_Index_Number(p_siyv_rec, x_return_status);
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

    /*
    -- Commented Validation as the expected valueset will not be
    -- in consistent with FND values but rather with Pricing_Engine Values
    -- Validate_Nominal_Yn
    Validate_Nominal_Yn(p_siyv_rec, x_return_status);
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

    -- Validate_Pre_Tax_Yn
    Validate_Pre_Tax_Yn(p_siyv_rec, x_return_status);
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

    -- Validate_Siy_Type
    Validate_Siy_Type(p_siyv_rec, x_return_status);
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

    RETURN (l_return_status);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    RETURN(l_return_status);
  END Validate_Attributes;
 /* -- END CHANGE -- mvasudev */

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKL_SIF_YIELDS_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_siyv_rec IN siyv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN siyv_rec_type,
	-- mvasudev , 12/28/2001
    --p_to	OUT NOCOPY siy_rec_type
    p_to	IN OUT NOCOPY siy_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.yield_name := p_from.yield_name;
    p_to.nominal_yn := p_from.nominal_yn;
    p_to.pre_tax_yn := p_from.pre_tax_yn;
    p_to.siy_type := p_from.siy_type;
    p_to.index_number := p_from.index_number;
    p_to.compounded_method := p_from.compounded_method;
    p_to.method := p_from.method;
    p_to.array_type := p_from.array_type;
    p_to.roe_base := p_from.roe_base;
    p_to.target_value := p_from.target_value;
    p_to.roe_type := p_from.roe_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sif_id := p_from.sif_id;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

    p_to.siy_type := p_from.siy_type;
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

  END migrate;
  PROCEDURE migrate (
    p_from	IN siy_rec_type,
	-- mvasudev , 12/28/2001
    --p_to	OUT NOCOPY siyv_rec_type
    p_to	IN OUT NOCOPY siyv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.yield_name := p_from.yield_name;
    p_to.nominal_yn := p_from.nominal_yn;
    p_to.pre_tax_yn := p_from.pre_tax_yn;
    p_to.index_number := p_from.index_number;
    p_to.compounded_method := p_from.compounded_method;
    p_to.method := p_from.method;
    p_to.array_type := p_from.array_type;
    p_to.roe_base := p_from.roe_base;
    p_to.target_value := p_from.target_value;
    p_to.roe_type := p_from.roe_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sif_id := p_from.sif_id;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

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

  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKL_SIF_YIELDS_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN siyv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_siyv_rec                     siyv_rec_type := p_siyv_rec;
    l_siy_rec                      siy_rec_type;
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
    l_return_status := Validate_Attributes(l_siyv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_siyv_rec);
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
  -- PL/SQL TBL validate_row for:SIYV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN siyv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 12/28/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_siyv_tbl.COUNT > 0) THEN
      i := p_siyv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_siyv_rec                     => p_siyv_tbl(i));
        -- START change : mvasudev, 12/28/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_siyv_tbl.LAST);
        i := p_siyv_tbl.NEXT(i);
      END LOOP;
       -- START change : mvasudev, 12/28/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : mvasudev
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
  -----------------------------------
  -- insert_row for:OKL_SIF_YIELDS --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siy_rec                      IN siy_rec_type,
    x_siy_rec                      OUT NOCOPY siy_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'YIELDS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_siy_rec                      siy_rec_type := p_siy_rec;
    l_def_siy_rec                  siy_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKL_SIF_YIELDS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_siy_rec IN  siy_rec_type,
      x_siy_rec OUT NOCOPY siy_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_siy_rec := p_siy_rec;
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
      p_siy_rec,                         -- IN
      l_siy_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SIF_YIELDS(
        id,
        yield_name,
        object_version_number,
        sif_id,
        method,
        array_type,
        roe_type,
        roe_base,
        compounded_method,
        target_value,
        index_number,
        nominal_yn,
        pre_tax_yn,
        siy_type,
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
        created_by,
        last_updated_by,
        creation_date,
        last_update_date,
        last_update_login)
      VALUES (
        l_siy_rec.id,
        l_siy_rec.yield_name,
        l_siy_rec.object_version_number,
        l_siy_rec.sif_id,
        l_siy_rec.method,
        l_siy_rec.array_type,
        l_siy_rec.roe_type,
        l_siy_rec.roe_base,
        l_siy_rec.compounded_method,
        l_siy_rec.target_value,
        l_siy_rec.index_number,
        l_siy_rec.nominal_yn,
        l_siy_rec.pre_tax_yn,
        l_siy_rec.siy_type,
        l_siy_rec.stream_interface_attribute01,
        l_siy_rec.stream_interface_attribute02,
        l_siy_rec.stream_interface_attribute03,
        l_siy_rec.stream_interface_attribute04,
        l_siy_rec.stream_interface_attribute05,
        l_siy_rec.stream_interface_attribute06,
        l_siy_rec.stream_interface_attribute07,
        l_siy_rec.stream_interface_attribute08,
        l_siy_rec.stream_interface_attribute09,
        l_siy_rec.stream_interface_attribute10,
        l_siy_rec.stream_interface_attribute11,
        l_siy_rec.stream_interface_attribute12,
        l_siy_rec.stream_interface_attribute13,
        l_siy_rec.stream_interface_attribute14,
        l_siy_rec.stream_interface_attribute15,
        l_siy_rec.created_by,
        l_siy_rec.last_updated_by,
        l_siy_rec.creation_date,
        l_siy_rec.last_update_date,
        l_siy_rec.last_update_login);
    -- Set OUT values
    x_siy_rec := l_siy_rec;
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
  -------------------------------------
  -- insert_row for:OKL_SIF_YIELDS_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN siyv_rec_type,
    x_siyv_rec                     OUT NOCOPY siyv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_siyv_rec                     siyv_rec_type;
    l_def_siyv_rec                 siyv_rec_type;
    l_siy_rec                      siy_rec_type;
    lx_siy_rec                     siy_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_siyv_rec	IN siyv_rec_type
    ) RETURN siyv_rec_type IS
      l_siyv_rec	siyv_rec_type := p_siyv_rec;
    BEGIN
      l_siyv_rec.CREATION_DATE := SYSDATE;
      l_siyv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_siyv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_siyv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_siyv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_siyv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKL_SIF_YIELDS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_siyv_rec IN  siyv_rec_type,
      x_siyv_rec OUT NOCOPY siyv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_siyv_rec := p_siyv_rec;
      x_siyv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_siyv_rec := null_out_defaults(p_siyv_rec);
    -- Set primary key value
    l_siyv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_siyv_rec,                        -- IN
      l_def_siyv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_siyv_rec := fill_who_columns(l_def_siyv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_siyv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_siyv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_siyv_rec, l_siy_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_siy_rec,
      lx_siy_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_siy_rec, l_def_siyv_rec);
    -- Set OUT values
    x_siyv_rec := l_def_siyv_rec;
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
  -- PL/SQL TBL insert_row for:SIYV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN siyv_tbl_type,
    x_siyv_tbl                     OUT NOCOPY siyv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    -- START change : mvasudev, 12/28/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_siyv_tbl.COUNT > 0) THEN
      i := p_siyv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_siyv_rec                     => p_siyv_tbl(i),
          x_siyv_rec                     => x_siyv_tbl(i));
        -- START change : mvasudev, 12/28/2001
			-- store the highest degree of error
		IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
			    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    		END IF;
		END IF;
			-- END change : mvasudev
        EXIT WHEN (i = p_siyv_tbl.LAST);
        i := p_siyv_tbl.NEXT(i);
      END LOOP;
       -- START change : mvasudev, 12/28/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : mvasudev
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
  ---------------------------------
  -- lock_row for:OKL_SIF_YIELDS --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siy_rec                      IN siy_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_siy_rec IN siy_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_YIELDS
     WHERE ID = p_siy_rec.id
       AND OBJECT_VERSION_NUMBER = p_siy_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_siy_rec IN siy_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_YIELDS
    WHERE ID = p_siy_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'YIELDS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SIF_YIELDS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SIF_YIELDS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_siy_rec);
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
      OPEN lchk_csr(p_siy_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_siy_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_siy_rec.object_version_number THEN
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
  -----------------------------------
  -- lock_row for:OKL_SIF_YIELDS_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN siyv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_siy_rec                      siy_rec_type;
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
    migrate(p_siyv_rec, l_siy_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_siy_rec
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
  -- PL/SQL TBL lock_row for:SIYV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN siyv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 12/28/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_siyv_tbl.COUNT > 0) THEN
      i := p_siyv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_siyv_rec                     => p_siyv_tbl(i));
        -- START change : mvasudev, 12/28/2001
			-- store the highest degree of error
		IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
			    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    		END IF;
		END IF;
			-- END change : mvasudev
        EXIT WHEN (i = p_siyv_tbl.LAST);
        i := p_siyv_tbl.NEXT(i);
      END LOOP;
       -- START change : mvasudev, 12/28/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : mvasudev
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
  -----------------------------------
  -- update_row for:OKL_SIF_YIELDS --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siy_rec                      IN siy_rec_type,
    x_siy_rec                      OUT NOCOPY siy_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'YIELDS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_siy_rec                      siy_rec_type := p_siy_rec;
    l_def_siy_rec                  siy_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_siy_rec	IN siy_rec_type,
      x_siy_rec	OUT NOCOPY siy_rec_type
    ) RETURN VARCHAR2 IS
      l_siy_rec                      siy_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_siy_rec := p_siy_rec;
      -- Get current database values
      l_siy_rec := get_rec(p_siy_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_siy_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_siy_rec.id := l_siy_rec.id;
      END IF;
      IF (x_siy_rec.yield_name = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.yield_name := l_siy_rec.yield_name;
      END IF;
      IF (x_siy_rec.nominal_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.nominal_yn := l_siy_rec.nominal_yn;
      END IF;
      IF (x_siy_rec.pre_tax_yn = OKC_API.G_MISS_CHAR)
            THEN
              x_siy_rec.pre_tax_yn := l_siy_rec.pre_tax_yn;
      END IF;
      IF (x_siy_rec.siy_type = OKC_API.G_MISS_CHAR)
      THEN
         x_siy_rec.siy_type := l_siy_rec.siy_type;
      END IF;
      IF (x_siy_rec.siy_type = OKC_API.G_MISS_CHAR)
      THEN
         x_siy_rec.siy_type := l_siy_rec.siy_type;
      END IF;
      IF (x_siy_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute01 := l_siy_rec.stream_interface_attribute01;
      END IF;
      IF (x_siy_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute02 := l_siy_rec.stream_interface_attribute02;
      END IF;
      IF (x_siy_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute03 := l_siy_rec.stream_interface_attribute03;
      END IF;
      IF (x_siy_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute04 := l_siy_rec.stream_interface_attribute04;
      END IF;
      IF (x_siy_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute05 := l_siy_rec.stream_interface_attribute05;
      END IF;
      IF (x_siy_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute06 := l_siy_rec.stream_interface_attribute06;
      END IF;
      IF (x_siy_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute07 := l_siy_rec.stream_interface_attribute07;
      END IF;
      IF (x_siy_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute08 := l_siy_rec.stream_interface_attribute08;
      END IF;
      IF (x_siy_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute09 := l_siy_rec.stream_interface_attribute09;
      END IF;
      IF (x_siy_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute10 := l_siy_rec.stream_interface_attribute10;
      END IF;
      IF (x_siy_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute11 := l_siy_rec.stream_interface_attribute11;
      END IF;
      IF (x_siy_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute12 := l_siy_rec.stream_interface_attribute12;
      END IF;
      IF (x_siy_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute13 := l_siy_rec.stream_interface_attribute13;
      END IF;
      IF (x_siy_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute14 := l_siy_rec.stream_interface_attribute14;
      END IF;
      IF (x_siy_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.stream_interface_attribute15 := l_siy_rec.stream_interface_attribute15;
      END IF;
      IF (x_siy_rec.index_number = OKC_API.G_MISS_NUM)
      THEN
        x_siy_rec.index_number := l_siy_rec.index_number;
      END IF;
      IF (x_siy_rec.compounded_method = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.compounded_method := l_siy_rec.compounded_method;
      END IF;
      IF (x_siy_rec.method = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.method := l_siy_rec.method;
      END IF;
      IF (x_siy_rec.array_type = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.array_type := l_siy_rec.array_type;
      END IF;
      IF (x_siy_rec.roe_base = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.roe_base := l_siy_rec.roe_base;
      END IF;
      IF (x_siy_rec.target_value = OKC_API.G_MISS_NUM)
      THEN
        x_siy_rec.target_value := l_siy_rec.target_value;
      END IF;
      IF (x_siy_rec.roe_type = OKC_API.G_MISS_CHAR)
      THEN
        x_siy_rec.roe_type := l_siy_rec.roe_type;
      END IF;
      IF (x_siy_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_siy_rec.object_version_number := l_siy_rec.object_version_number;
      END IF;
      IF (x_siy_rec.sif_id = OKC_API.G_MISS_NUM)
      THEN
        x_siy_rec.sif_id := l_siy_rec.sif_id;
      END IF;
      IF (x_siy_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_siy_rec.created_by := l_siy_rec.created_by;
      END IF;
      IF (x_siy_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_siy_rec.last_updated_by := l_siy_rec.last_updated_by;
      END IF;
      IF (x_siy_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_siy_rec.creation_date := l_siy_rec.creation_date;
      END IF;
      IF (x_siy_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_siy_rec.last_update_date := l_siy_rec.last_update_date;
      END IF;
      IF (x_siy_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_siy_rec.last_update_login := l_siy_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_SIF_YIELDS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_siy_rec IN  siy_rec_type,
      x_siy_rec OUT NOCOPY siy_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_siy_rec := p_siy_rec;
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
      p_siy_rec,                         -- IN
      l_siy_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_siy_rec, l_def_siy_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SIF_YIELDS
    SET YIELD_NAME = l_def_siy_rec.yield_name,
        NOMINAL_YN = l_def_siy_rec.nominal_yn,
        PRE_TAX_YN = l_def_siy_rec.pre_tax_yn,
        SIY_TYPE = l_def_siy_rec.siy_type,
        STREAM_INTERFACE_ATTRIBUTE01 = l_def_siy_rec.stream_interface_attribute01,
        STREAM_INTERFACE_ATTRIBUTE02 = l_def_siy_rec.stream_interface_attribute02,
        STREAM_INTERFACE_ATTRIBUTE03 = l_def_siy_rec.stream_interface_attribute03,
        STREAM_INTERFACE_ATTRIBUTE04 = l_def_siy_rec.stream_interface_attribute04,
        STREAM_INTERFACE_ATTRIBUTE05 = l_def_siy_rec.stream_interface_attribute05,
        STREAM_INTERFACE_ATTRIBUTE06 = l_def_siy_rec.stream_interface_attribute06,
        STREAM_INTERFACE_ATTRIBUTE07 = l_def_siy_rec.stream_interface_attribute07,
        STREAM_INTERFACE_ATTRIBUTE08 = l_def_siy_rec.stream_interface_attribute08,
        STREAM_INTERFACE_ATTRIBUTE09 = l_def_siy_rec.stream_interface_attribute09,
        STREAM_INTERFACE_ATTRIBUTE10 = l_def_siy_rec.stream_interface_attribute10,
        STREAM_INTERFACE_ATTRIBUTE11 = l_def_siy_rec.stream_interface_attribute11,
        STREAM_INTERFACE_ATTRIBUTE12 = l_def_siy_rec.stream_interface_attribute12,
        STREAM_INTERFACE_ATTRIBUTE13 = l_def_siy_rec.stream_interface_attribute13,
        STREAM_INTERFACE_ATTRIBUTE14 = l_def_siy_rec.stream_interface_attribute14,
        STREAM_INTERFACE_ATTRIBUTE15 = l_def_siy_rec.stream_interface_attribute15,
        INDEX_NUMBER = l_def_siy_rec.index_number,
        COMPOUNDED_METHOD = l_def_siy_rec.compounded_method,
        METHOD = l_def_siy_rec.method,
        ARRAY_TYPE = l_def_siy_rec.array_type,
        ROE_BASE = l_def_siy_rec.roe_base,
        TARGET_VALUE = l_def_siy_rec.target_value,
        ROE_TYPE = l_def_siy_rec.roe_type,
        OBJECT_VERSION_NUMBER = l_def_siy_rec.object_version_number,
        SIF_ID = l_def_siy_rec.sif_id,
        CREATED_BY = l_def_siy_rec.created_by,
        LAST_UPDATED_BY = l_def_siy_rec.last_updated_by,
        CREATION_DATE = l_def_siy_rec.creation_date,
        LAST_UPDATE_DATE = l_def_siy_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_siy_rec.last_update_login
    WHERE ID = l_def_siy_rec.id ;

    x_siy_rec := l_def_siy_rec;
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
  -------------------------------------
  -- update_row for:OKL_SIF_YIELDS_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN siyv_rec_type,
    x_siyv_rec                     OUT NOCOPY siyv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_siyv_rec                     siyv_rec_type := p_siyv_rec;
    l_def_siyv_rec                 siyv_rec_type;
    l_siy_rec                      siy_rec_type;
    lx_siy_rec                     siy_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_siyv_rec	IN siyv_rec_type
    ) RETURN siyv_rec_type IS
      l_siyv_rec	siyv_rec_type := p_siyv_rec;
    BEGIN
      l_siyv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_siyv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_siyv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_siyv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_siyv_rec	IN siyv_rec_type,
      x_siyv_rec	OUT NOCOPY siyv_rec_type
    ) RETURN VARCHAR2 IS
      l_siyv_rec                     siyv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_siyv_rec := p_siyv_rec;
      -- Get current database values
      l_siyv_rec := get_rec(p_siyv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_siyv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_siyv_rec.id := l_siyv_rec.id;
      END IF;
      IF (x_siyv_rec.yield_name = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.yield_name := l_siyv_rec.yield_name;
      END IF;
      IF (x_siyv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_siyv_rec.object_version_number := l_siyv_rec.object_version_number;
      END IF;
      IF (x_siyv_rec.sif_id = OKC_API.G_MISS_NUM)
      THEN
        x_siyv_rec.sif_id := l_siyv_rec.sif_id;
      END IF;
      IF (x_siyv_rec.method = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.method := l_siyv_rec.method;
      END IF;
      IF (x_siyv_rec.array_type = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.array_type := l_siyv_rec.array_type;
      END IF;
      IF (x_siyv_rec.roe_type = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.roe_type := l_siyv_rec.roe_type;
      END IF;
      IF (x_siyv_rec.roe_base = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.roe_base := l_siyv_rec.roe_base;
      END IF;
      IF (x_siyv_rec.compounded_method = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.compounded_method := l_siyv_rec.compounded_method;
      END IF;
      IF (x_siyv_rec.target_value = OKC_API.G_MISS_NUM)
      THEN
        x_siyv_rec.target_value := l_siyv_rec.target_value;
      END IF;
      IF (x_siyv_rec.index_number = OKC_API.G_MISS_NUM)
      THEN
        x_siyv_rec.index_number := l_siyv_rec.index_number;
      END IF;
      IF (x_siyv_rec.nominal_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.nominal_yn := l_siyv_rec.nominal_yn;
      END IF;
      IF (x_siyv_rec.pre_tax_yn = OKC_API.G_MISS_CHAR)
            THEN
              x_siyv_rec.pre_tax_yn := l_siyv_rec.pre_tax_yn;
      END IF;
      IF (x_siyv_rec.siy_type = OKC_API.G_MISS_CHAR)
            THEN
              x_siyv_rec.siy_type := l_siyv_rec.siy_type;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute01 := l_siyv_rec.stream_interface_attribute01;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute02 := l_siyv_rec.stream_interface_attribute02;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute03 := l_siyv_rec.stream_interface_attribute03;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute04 := l_siyv_rec.stream_interface_attribute04;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute05 := l_siyv_rec.stream_interface_attribute05;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute06 := l_siyv_rec.stream_interface_attribute06;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute07 := l_siyv_rec.stream_interface_attribute07;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute08 := l_siyv_rec.stream_interface_attribute08;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute09 := l_siyv_rec.stream_interface_attribute09;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute10 := l_siyv_rec.stream_interface_attribute10;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute11 := l_siyv_rec.stream_interface_attribute11;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute12 := l_siyv_rec.stream_interface_attribute12;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute13 := l_siyv_rec.stream_interface_attribute13;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute14 := l_siyv_rec.stream_interface_attribute14;
      END IF;
      IF (x_siyv_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_siyv_rec.stream_interface_attribute15 := l_siyv_rec.stream_interface_attribute15;
      END IF;
      IF (x_siyv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_siyv_rec.created_by := l_siyv_rec.created_by;
      END IF;
      IF (x_siyv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_siyv_rec.last_updated_by := l_siyv_rec.last_updated_by;
      END IF;
      IF (x_siyv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_siyv_rec.creation_date := l_siyv_rec.creation_date;
      END IF;
      IF (x_siyv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_siyv_rec.last_update_date := l_siyv_rec.last_update_date;
      END IF;
      IF (x_siyv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_siyv_rec.last_update_login := l_siyv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_SIF_YIELDS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_siyv_rec IN  siyv_rec_type,
      x_siyv_rec OUT NOCOPY siyv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_siyv_rec := p_siyv_rec;
      x_siyv_rec.OBJECT_VERSION_NUMBER := NVL(x_siyv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_siyv_rec,                        -- IN
      l_siyv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_siyv_rec, l_def_siyv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_siyv_rec := fill_who_columns(l_def_siyv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_siyv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_siyv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_siyv_rec, l_siy_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_siy_rec,
      lx_siy_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_siy_rec, l_def_siyv_rec);
    x_siyv_rec := l_def_siyv_rec;
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
  -- PL/SQL TBL update_row for:SIYV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN siyv_tbl_type,
    x_siyv_tbl                     OUT NOCOPY siyv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 12/28/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_siyv_tbl.COUNT > 0) THEN
      i := p_siyv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_siyv_rec                     => p_siyv_tbl(i),
          x_siyv_rec                     => x_siyv_tbl(i));
        -- START change : mvasudev, 12/28/2001
			-- store the highest degree of error
		IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
			    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    		END IF;
		END IF;
			-- END change : mvasudev
        EXIT WHEN (i = p_siyv_tbl.LAST);
        i := p_siyv_tbl.NEXT(i);
      END LOOP;
       -- START change : mvasudev, 12/28/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : mvasudev
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
  -----------------------------------
  -- delete_row for:OKL_SIF_YIELDS --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siy_rec                      IN siy_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'YIELDS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_siy_rec                      siy_rec_type:= p_siy_rec;
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
    DELETE FROM OKL_SIF_YIELDS
     WHERE ID = l_siy_rec.id;


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
  -------------------------------------
  -- delete_row for:OKL_SIF_YIELDS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN siyv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_siyv_rec                     siyv_rec_type := p_siyv_rec;
    l_siy_rec                      siy_rec_type;
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
    migrate(l_siyv_rec, l_siy_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_siy_rec
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
  -- PL/SQL TBL delete_row for:SIYV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN siyv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 12/28/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_siyv_tbl.COUNT > 0) THEN
      i := p_siyv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_siyv_rec                     => p_siyv_tbl(i));
        -- START change : mvasudev, 12/28/2001
			-- store the highest degree of error
		IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
			    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    		END IF;
		END IF;
			-- END change : mvasudev
        EXIT WHEN (i = p_siyv_tbl.LAST);
        i := p_siyv_tbl.NEXT(i);
       -- START change : mvasudev, 12/28/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : mvasudev
      END LOOP;
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
END OKL_SIY_PVT;

/
