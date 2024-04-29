--------------------------------------------------------
--  DDL for Package Body OKL_SXP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SXP_PVT" AS
/* $Header: OKLSSXPB.pls 115.7 2002/12/18 13:10:31 kjinger noship $ */
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
  -- FUNCTION get_rec for: OKL_SIF_TRX_PARMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sxp_rec                      IN sxp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sxp_rec_type IS
    CURSOR sxp_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            INDEX_NUMBER1,
            INDEX_NUMBER2,
            VALUE,
            KHR_ID,
            KLE_ID,
            SIF_ID,
            SPP_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Sif_Trx_Parms
     WHERE okl_sif_trx_parms.id = p_id;
    l_sxp_pk                       sxp_pk_csr%ROWTYPE;
    l_sxp_rec                      sxp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sxp_pk_csr (p_sxp_rec.id);
    FETCH sxp_pk_csr INTO
              l_sxp_rec.ID,
              l_sxp_rec.INDEX_NUMBER1,
              l_sxp_rec.INDEX_NUMBER2,
              l_sxp_rec.VALUE,
              l_sxp_rec.KHR_ID,
              l_sxp_rec.KLE_ID,
              l_sxp_rec.SIF_ID,
              l_sxp_rec.SPP_ID,
              l_sxp_rec.OBJECT_VERSION_NUMBER,
              l_sxp_rec.CREATED_BY,
              l_sxp_rec.LAST_UPDATED_BY,
              l_sxp_rec.CREATION_DATE,
              l_sxp_rec.LAST_UPDATE_DATE,
              l_sxp_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := sxp_pk_csr%NOTFOUND;
    CLOSE sxp_pk_csr;
    RETURN(l_sxp_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sxp_rec                      IN sxp_rec_type
  ) RETURN sxp_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sxp_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_TRX_PARMS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sxpv_rec                     IN sxpv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sxpv_rec_type IS
    CURSOR sxpv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            INDEX_NUMBER1,
            INDEX_NUMBER2,
            VALUE,
            KHR_ID,
            KLE_ID,
            SIF_ID,
            SPP_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_SIF_TRX_PARMS_V
     WHERE OKL_SIF_TRX_PARMS_V.id = p_id;
    l_sxpv_pk                      sxpv_pk_csr%ROWTYPE;
    l_sxpv_rec                     sxpv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values

    OPEN  sxpv_pk_csr (p_sxpv_rec.id);
    FETCH sxpv_pk_csr INTO
              l_sxpv_rec.ID,
              l_sxpv_rec.INDEX_NUMBER1,
              l_sxpv_rec.INDEX_NUMBER2,
              l_sxpv_rec.VALUE,
              l_sxpv_rec.KHR_ID,
              l_sxpv_rec.KLE_ID,
              l_sxpv_rec.SIF_ID,
              l_sxpv_rec.SPP_ID,
              l_sxpv_rec.OBJECT_VERSION_NUMBER,
              l_sxpv_rec.CREATED_BY,
              l_sxpv_rec.LAST_UPDATED_BY,
              l_sxpv_rec.CREATION_DATE,
              l_sxpv_rec.LAST_UPDATE_DATE,
              l_sxpv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := sxpv_pk_csr%NOTFOUND;
    CLOSE sxpv_pk_csr;
    RETURN(l_sxpv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sxpv_rec                     IN sxpv_rec_type
  ) RETURN sxpv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sxpv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SIF_TRX_PARMS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_sxpv_rec	IN sxpv_rec_type
  ) RETURN sxpv_rec_type IS
    l_sxpv_rec	sxpv_rec_type := p_sxpv_rec;
  BEGIN
    IF (l_sxpv_rec.id = OKC_API.G_MISS_NUM) THEN
      l_sxpv_rec.id := NULL;
    END IF;
    IF (l_sxpv_rec.index_number1 = OKC_API.G_MISS_NUM) THEN
      l_sxpv_rec.index_number1 := NULL;
    END IF;
    IF (l_sxpv_rec.index_number2 = OKC_API.G_MISS_NUM) THEN
      l_sxpv_rec.index_number2 := NULL;
    END IF;
    IF (l_sxpv_rec.value = OKC_API.G_MISS_CHAR) THEN
      l_sxpv_rec.value := NULL;
    END IF;
    IF (l_sxpv_rec.khr_id = OKC_API.G_MISS_NUM) THEN
      l_sxpv_rec.khr_id := NULL;
    END IF;
    IF (l_sxpv_rec.kle_id = OKC_API.G_MISS_NUM) THEN
      l_sxpv_rec.kle_id := NULL;
    END IF;
    IF (l_sxpv_rec.sif_id = OKC_API.G_MISS_NUM) THEN
      l_sxpv_rec.sif_id := NULL;
    END IF;
    IF (l_sxpv_rec.spp_id = OKC_API.G_MISS_NUM) THEN
      l_sxpv_rec.spp_id := NULL;
    END IF;
    IF (l_sxpv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_sxpv_rec.object_version_number := NULL;
    END IF;
    IF (l_sxpv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_sxpv_rec.created_by := NULL;
    END IF;
    IF (l_sxpv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_sxpv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sxpv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_sxpv_rec.creation_date := NULL;
    END IF;
    IF (l_sxpv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_sxpv_rec.last_update_date := NULL;
    END IF;
    IF (l_sxpv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_sxpv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_sxpv_rec);
  END null_out_defaults;

    -- START change : akjain , 09/05/2001
    /*
    -- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_SIF_TRX_PARMS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_sxpv_rec IN  sxpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_sxpv_rec.id = OKC_API.G_MISS_NUM OR
       p_sxpv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sxpv_rec.sif_id = OKC_API.G_MISS_NUM OR
          p_sxpv_rec.sif_id IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sif_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sxpv_rec.spp_id = OKC_API.G_MISS_NUM OR
          p_sxpv_rec.spp_id IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'spp_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sxpv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_sxpv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  */
  -- END CHANGE akjain

  -- START CHANGE akjain

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
    p_sxpv_rec      IN   sxpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sxpv_rec.id = Okc_Api.G_MISS_NUM OR
      p_sxpv_rec.id IS NULL
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
    p_sxpv_rec      IN   sxpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sxpv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
       p_sxpv_rec.object_version_number IS NULL
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
  -- PROCEDURE Validate_Value
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Value
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Value(
    p_sxpv_rec      IN   sxpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sxpv_rec.Value = Okc_Api.G_MISS_CHAR OR
       p_sxpv_rec.Value IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Value');
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

  END Validate_Value;


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
    p_sxpv_rec      IN   sxpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SIL_SIF_FK;
  CURSOR okl_sifv_pk_csr (p_id IN OKL_STREAM_INTERFACES_V.id%TYPE) IS
  SELECT '1'
    FROM OKL_STREAM_INTERFACES_V
   WHERE OKL_STREAM_INTERFACES_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sxpv_rec.sif_id = Okc_Api.G_MISS_NUM OR
       p_sxpv_rec.sif_id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Sif_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_sifv_pk_csr(p_sxpv_rec.sif_id);
    FETCH okl_sifv_pk_csr INTO l_dummy;
    l_row_not_found := okl_sifv_pk_csr%NOTFOUND;
    CLOSE okl_sifv_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'sif_id');
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
  -- PROCEDURE Validate_Spp_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Spp_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Spp_Id(
    p_sxpv_rec      IN   sxpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SPP_FK;
  CURSOR okl_sppv_pk_csr (p_id IN OKL_SIF_PRICE_PARMS_V.id%TYPE) IS
  SELECT '1'
    FROM OKL_SIF_PRICE_PARMS_V
   WHERE OKL_SIF_PRICE_PARMS_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sxpv_rec.spp_id = Okc_Api.G_MISS_NUM OR
       p_sxpv_rec.spp_id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Spp_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_sppv_pk_csr(p_sxpv_rec.Spp_id);
    FETCH okl_sppv_pk_csr INTO l_dummy;
    l_row_not_found := okl_sppv_pk_csr%NOTFOUND;
    CLOSE okl_sppv_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'spp_id');
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
      IF okl_sppv_pk_csr%ISOPEN THEN
        CLOSE okl_sppv_pk_csr;
      END IF;

  END Validate_Spp_Id;



---------------------------------------------------------------------------
  -- PROCEDURE Validate_Kle_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Kle_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Kle_Id(
    p_sxpv_rec      IN   sxpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  /*
  -- Cursor For OKL_K_LINES_V_FK;
  CURSOR okl_kle_pk_csr(p_id IN OKL_K_LINES_V.id%TYPE) IS
  SELECT '1'
    FROM OKL_K_LINES_V
   WHERE OKL_K_LINES_V.id = p_id;
  */
  -- Cursor For OKL_K_LINES_B_FK;
  CURSOR okl_kle_pk_csr(p_id IN OKC_K_LINES_B.id%TYPE) IS
  SELECT '1'
    FROM OKC_K_LINES_B
   WHERE OKC_K_LINES_B.id = p_id;

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sxpv_rec.kle_id <> Okc_Api.G_MISS_NUM AND
              p_sxpv_rec.kle_id IS NOT NULL
    THEN

        OPEN okl_kle_pk_csr(p_sxpv_rec.Kle_id);
        FETCH okl_kle_pk_csr INTO l_dummy;
        l_row_not_found := okl_kle_pk_csr%NOTFOUND;
        CLOSE okl_kle_pk_csr;

        IF l_row_not_found THEN
	  Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Kle_id');
          x_return_status := Okc_Api.G_RET_STS_ERROR;
        END IF;
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
      IF okl_kle_pk_csr%ISOPEN THEN
        CLOSE okl_kle_pk_csr;
      END IF;

  END Validate_Kle_Id;



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
    p_sxpv_rec      IN   sxpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_K_LINES_V_FK;
  CURSOR okl_khr_pk_csr (p_id IN OKL_K_HEADERS_V.id%TYPE) IS
  SELECT '1'
    FROM OKL_K_HEADERS_V
   WHERE OKL_K_HEADERS_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sxpv_rec.khr_id = Okc_Api.G_MISS_NUM OR
       p_sxpv_rec.khr_id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Khr_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_khr_pk_csr(p_sxpv_rec.Khr_id);
    FETCH okl_khr_pk_csr INTO l_dummy;
    l_row_not_found := okl_khr_pk_csr%NOTFOUND;
    CLOSE okl_khr_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Khr_id');
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
      IF okl_khr_pk_csr%ISOPEN THEN
        CLOSE okl_khr_pk_csr;
      END IF;

  END Validate_Khr_Id;


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
    p_sxpv_rec IN  sxpv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    -- Validate_Id
    Validate_Id(p_sxpv_rec, x_return_status);
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
    Validate_Object_Version_Number(p_sxpv_rec, x_return_status);
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

    -- Validate_Value
    Validate_Value(p_sxpv_rec, x_return_status);
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

    -- Validate_Sif_id
    Validate_Sif_id(p_sxpv_rec, x_return_status);
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

 -- Khr Id is a NULLABLE coloumn but enforced that it should always be present
 -- Need to validate it : akjain 09-05-2001

   -- Validate_Khr_Id
      Validate_Khr_Id(p_sxpv_rec, x_return_status);
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

	-- Validate_Kle_Id
    Validate_Kle_Id(p_sxpv_rec, x_return_status);
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
    -- Validate_Spp_Id
    Validate_Spp_Id(p_sxpv_rec, x_return_status);
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
       Okc_Api.SET_MESSAGE(p_app_name         => G_APP_NAME,
                           p_msg_name         => G_OKL_UNEXPECTED_ERROR,
                           p_token1           => G_OKL_SQLCODE_TOKEN,
                           p_token1_value     => SQLCODE,
                           p_token2           => G_OKL_SQLERRM_TOKEN,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    RETURN(l_return_status);
  END Validate_Attributes;

  -- END change : akjain


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_SIF_TRX_PARMS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_sxpv_rec IN sxpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN sxpv_rec_type,
    p_to	IN OUT NOCOPY sxp_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.index_number1 := p_from.index_number1;
    p_to.index_number2 := p_from.index_number2;
    p_to.value := p_from.value;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.sif_id := p_from.sif_id;
    p_to.spp_id := p_from.spp_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN sxp_rec_type,
    p_to	IN OUT NOCOPY sxpv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.index_number1 := p_from.index_number1;
    p_to.index_number2 := p_from.index_number2;
    p_to.value := p_from.value;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.sif_id := p_from.sif_id;
    p_to.spp_id := p_from.spp_id;
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
  ------------------------------------------
  -- validate_row for:OKL_SIF_TRX_PARMS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxpv_rec                     IN sxpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sxpv_rec                     sxpv_rec_type := p_sxpv_rec;
    l_sxp_rec                      sxp_rec_type;
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
    l_return_status := Validate_Attributes(l_sxpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sxpv_rec);
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
  -- PL/SQL TBL validate_row for:SXPV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxpv_tbl                     IN sxpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sxpv_tbl.COUNT > 0) THEN
      i := p_sxpv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sxpv_rec                     => p_sxpv_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sxpv_tbl.LAST);
        i := p_sxpv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
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
  --------------------------------------
  -- insert_row for:OKL_SIF_TRX_PARMS --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxp_rec                      IN sxp_rec_type,
    x_sxp_rec                      OUT NOCOPY sxp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARMS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sxp_rec                      sxp_rec_type := p_sxp_rec;
    l_def_sxp_rec                  sxp_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKL_SIF_TRX_PARMS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_sxp_rec IN  sxp_rec_type,
      x_sxp_rec OUT NOCOPY sxp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sxp_rec := p_sxp_rec;
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
      p_sxp_rec,                         -- IN
      l_sxp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SIF_TRX_PARMS(
        id,
        index_number1,
        index_number2,
        value,
        khr_id,
        kle_id,
        sif_id,
        spp_id,
        object_version_number,
        created_by,
        last_updated_by,
        creation_date,
        last_update_date,
        last_update_login)
      VALUES (
        l_sxp_rec.id,
        l_sxp_rec.index_number1,
        l_sxp_rec.index_number2,
        l_sxp_rec.value,
        l_sxp_rec.khr_id,
        l_sxp_rec.kle_id,
        l_sxp_rec.sif_id,
        l_sxp_rec.spp_id,
        l_sxp_rec.object_version_number,
        l_sxp_rec.created_by,
        l_sxp_rec.last_updated_by,
        l_sxp_rec.creation_date,
        l_sxp_rec.last_update_date,
        l_sxp_rec.last_update_login);
    -- Set OUT values
    x_sxp_rec := l_sxp_rec;
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
  -- insert_row for:OKL_SIF_TRX_PARMS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxpv_rec                     IN sxpv_rec_type,
    x_sxpv_rec                     OUT NOCOPY sxpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sxpv_rec                     sxpv_rec_type;
    l_def_sxpv_rec                 sxpv_rec_type;
    l_sxp_rec                      sxp_rec_type;
    lx_sxp_rec                     sxp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sxpv_rec	IN sxpv_rec_type
    ) RETURN sxpv_rec_type IS
      l_sxpv_rec	sxpv_rec_type := p_sxpv_rec;
    BEGIN
      l_sxpv_rec.CREATION_DATE := SYSDATE;
      l_sxpv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sxpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sxpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sxpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sxpv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_SIF_TRX_PARMS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_sxpv_rec IN  sxpv_rec_type,
      x_sxpv_rec OUT NOCOPY sxpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sxpv_rec := p_sxpv_rec;
      x_sxpv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_sxpv_rec := null_out_defaults(p_sxpv_rec);

    -- Set primary key value
    l_sxpv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_sxpv_rec,                        -- IN
      l_def_sxpv_rec);                   -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sxpv_rec := fill_who_columns(l_def_sxpv_rec);

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sxpv_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sxpv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sxpv_rec, l_sxp_rec);

    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sxp_rec,
      lx_sxp_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sxp_rec, l_def_sxpv_rec);
    -- Set OUT values
    x_sxpv_rec := l_def_sxpv_rec;

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
  -- PL/SQL TBL insert_row for:SXPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxpv_tbl                     IN sxpv_tbl_type,
    x_sxpv_tbl                     OUT NOCOPY sxpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sxpv_tbl.COUNT > 0) THEN
      i := p_sxpv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sxpv_rec                     => p_sxpv_tbl(i),
          x_sxpv_rec                     => x_sxpv_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sxpv_tbl.LAST);
        i := p_sxpv_tbl.NEXT(i);
      END LOOP;
 -- START change : akjain, 09/05/2001
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
  ------------------------------------
  -- lock_row for:OKL_SIF_TRX_PARMS --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxp_rec                      IN sxp_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sxp_rec IN sxp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_TRX_PARMS
     WHERE ID = p_sxp_rec.id
       AND OBJECT_VERSION_NUMBER = p_sxp_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sxp_rec IN sxp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_TRX_PARMS
    WHERE ID = p_sxp_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARMS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SIF_TRX_PARMS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SIF_TRX_PARMS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sxp_rec);
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
      OPEN lchk_csr(p_sxp_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sxp_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sxp_rec.object_version_number THEN
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
  --------------------------------------
  -- lock_row for:OKL_SIF_TRX_PARMS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxpv_rec                     IN sxpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sxp_rec                      sxp_rec_type;
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
    migrate(p_sxpv_rec, l_sxp_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sxp_rec
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
  -- PL/SQL TBL lock_row for:SXPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxpv_tbl                     IN sxpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sxpv_tbl.COUNT > 0) THEN
      i := p_sxpv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sxpv_rec                     => p_sxpv_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sxpv_tbl.LAST);
        i := p_sxpv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
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
  --------------------------------------
  -- update_row for:OKL_SIF_TRX_PARMS --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxp_rec                      IN sxp_rec_type,
    x_sxp_rec                      OUT NOCOPY sxp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARMS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sxp_rec                      sxp_rec_type := p_sxp_rec;
    l_def_sxp_rec                  sxp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sxp_rec	IN sxp_rec_type,
      x_sxp_rec	OUT NOCOPY sxp_rec_type
    ) RETURN VARCHAR2 IS
      l_sxp_rec                      sxp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sxp_rec := p_sxp_rec;
      -- Get current database values
      l_sxp_rec := get_rec(p_sxp_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;

      IF (x_sxp_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sxp_rec.id := l_sxp_rec.id;
      END IF;
      IF (x_sxp_rec.index_number1 = OKC_API.G_MISS_NUM)
      THEN
        x_sxp_rec.index_number1 := l_sxp_rec.index_number1;
      END IF;
      IF (x_sxp_rec.index_number2 = OKC_API.G_MISS_NUM)
      THEN
        x_sxp_rec.index_number2 := l_sxp_rec.index_number2;
      END IF;
      IF (x_sxp_rec.value = OKC_API.G_MISS_CHAR)
      THEN
        x_sxp_rec.value := l_sxp_rec.value;
      END IF;
      IF (x_sxp_rec.khr_id = OKC_API.G_MISS_NUM)
      THEN
        x_sxp_rec.khr_id := l_sxp_rec.khr_id;
      END IF;
      IF (x_sxp_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_sxp_rec.kle_id := l_sxp_rec.kle_id;
      END IF;
      IF (x_sxp_rec.sif_id = OKC_API.G_MISS_NUM)
      THEN
        x_sxp_rec.sif_id := l_sxp_rec.sif_id;
      END IF;
      IF (x_sxp_rec.spp_id = OKC_API.G_MISS_NUM)
      THEN
        x_sxp_rec.spp_id := l_sxp_rec.spp_id;
      END IF;
      IF (x_sxp_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sxp_rec.object_version_number := l_sxp_rec.object_version_number;
      END IF;
      IF (x_sxp_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sxp_rec.created_by := l_sxp_rec.created_by;
      END IF;
      IF (x_sxp_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sxp_rec.last_updated_by := l_sxp_rec.last_updated_by;
      END IF;
      IF (x_sxp_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sxp_rec.creation_date := l_sxp_rec.creation_date;
      END IF;
      IF (x_sxp_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sxp_rec.last_update_date := l_sxp_rec.last_update_date;
      END IF;
      IF (x_sxp_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sxp_rec.last_update_login := l_sxp_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_SIF_TRX_PARMS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_sxp_rec IN  sxp_rec_type,
      x_sxp_rec OUT NOCOPY sxp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sxp_rec := p_sxp_rec;
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
      p_sxp_rec,                         -- IN
      l_sxp_rec);                        -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sxp_rec, l_def_sxp_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SIF_TRX_PARMS
    SET INDEX_NUMBER1 = l_def_sxp_rec.index_number1,
        INDEX_NUMBER2 = l_def_sxp_rec.index_number2,
        VALUE = l_def_sxp_rec.value,
        KHR_ID = l_def_sxp_rec.khr_id,
        KLE_ID = l_def_sxp_rec.kle_id,
        SIF_ID = l_def_sxp_rec.sif_id,
        SPP_ID = l_def_sxp_rec.spp_id,
        OBJECT_VERSION_NUMBER = l_def_sxp_rec.object_version_number,
        CREATED_BY = l_def_sxp_rec.created_by,
        LAST_UPDATED_BY = l_def_sxp_rec.last_updated_by,
        CREATION_DATE = l_def_sxp_rec.creation_date,
        LAST_UPDATE_DATE = l_def_sxp_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sxp_rec.last_update_login
    WHERE ID = l_def_sxp_rec.id;

    x_sxp_rec := l_def_sxp_rec;
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
  -- update_row for:OKL_SIF_TRX_PARMS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxpv_rec                     IN sxpv_rec_type,
    x_sxpv_rec                     OUT NOCOPY sxpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sxpv_rec                     sxpv_rec_type := p_sxpv_rec;
    l_def_sxpv_rec                 sxpv_rec_type;
    l_sxp_rec                      sxp_rec_type;
    lx_sxp_rec                     sxp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sxpv_rec	IN sxpv_rec_type
    ) RETURN sxpv_rec_type IS
      l_sxpv_rec	sxpv_rec_type := p_sxpv_rec;
    BEGIN
      l_sxpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sxpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sxpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sxpv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sxpv_rec	IN sxpv_rec_type,
      x_sxpv_rec	OUT NOCOPY sxpv_rec_type
    ) RETURN VARCHAR2 IS
      l_sxpv_rec                     sxpv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_sxpv_rec := p_sxpv_rec;
      -- Get current database values
      l_sxpv_rec := get_rec(p_sxpv_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;

      IF (x_sxpv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sxpv_rec.id := l_sxpv_rec.id;
      END IF;
      IF (x_sxpv_rec.index_number1 = OKC_API.G_MISS_NUM)
      THEN
        x_sxpv_rec.index_number1 := l_sxpv_rec.index_number1;
      END IF;
      IF (x_sxpv_rec.index_number2 = OKC_API.G_MISS_NUM)
      THEN
        x_sxpv_rec.index_number2 := l_sxpv_rec.index_number2;
      END IF;
      IF (x_sxpv_rec.value = OKC_API.G_MISS_CHAR)
      THEN
        x_sxpv_rec.value := l_sxpv_rec.value;
      END IF;
      IF (x_sxpv_rec.khr_id = OKC_API.G_MISS_NUM)
      THEN
        x_sxpv_rec.khr_id := l_sxpv_rec.khr_id;
      END IF;
      IF (x_sxpv_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_sxpv_rec.kle_id := l_sxpv_rec.kle_id;
      END IF;
      IF (x_sxpv_rec.sif_id = OKC_API.G_MISS_NUM)
      THEN
        x_sxpv_rec.sif_id := l_sxpv_rec.sif_id;
      END IF;
      IF (x_sxpv_rec.spp_id = OKC_API.G_MISS_NUM)
      THEN
        x_sxpv_rec.spp_id := l_sxpv_rec.spp_id;
      END IF;
      IF (x_sxpv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sxpv_rec.object_version_number := l_sxpv_rec.object_version_number;
      END IF;
      IF (x_sxpv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sxpv_rec.created_by := l_sxpv_rec.created_by;
      END IF;
      IF (x_sxpv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sxpv_rec.last_updated_by := l_sxpv_rec.last_updated_by;
      END IF;
      IF (x_sxpv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sxpv_rec.creation_date := l_sxpv_rec.creation_date;
      END IF;
      IF (x_sxpv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sxpv_rec.last_update_date := l_sxpv_rec.last_update_date;
      END IF;
      IF (x_sxpv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sxpv_rec.last_update_login := l_sxpv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_SIF_TRX_PARMS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_sxpv_rec IN  sxpv_rec_type,
      x_sxpv_rec OUT NOCOPY sxpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sxpv_rec := p_sxpv_rec;
      x_sxpv_rec.OBJECT_VERSION_NUMBER := NVL(x_sxpv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_sxpv_rec,                        -- IN
      l_sxpv_rec);                       -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sxpv_rec, l_def_sxpv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sxpv_rec := fill_who_columns(l_def_sxpv_rec);

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sxpv_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sxpv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sxpv_rec, l_sxp_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sxp_rec,
      lx_sxp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sxp_rec, l_def_sxpv_rec);
    x_sxpv_rec := l_def_sxpv_rec;
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
  -- PL/SQL TBL update_row for:SXPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxpv_tbl                     IN sxpv_tbl_type,
    x_sxpv_tbl                     OUT NOCOPY sxpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sxpv_tbl.COUNT > 0) THEN
      i := p_sxpv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sxpv_rec                     => p_sxpv_tbl(i),
          x_sxpv_rec                     => x_sxpv_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sxpv_tbl.LAST);
        i := p_sxpv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
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
  --------------------------------------
  -- delete_row for:OKL_SIF_TRX_PARMS --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxp_rec                      IN sxp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARMS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sxp_rec                      sxp_rec_type:= p_sxp_rec;
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
    DELETE FROM OKL_SIF_TRX_PARMS
     WHERE ID = l_sxp_rec.id;

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
  -- delete_row for:OKL_SIF_TRX_PARMS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxpv_rec                     IN sxpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sxpv_rec                     sxpv_rec_type := p_sxpv_rec;
    l_sxp_rec                      sxp_rec_type;
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
    migrate(l_sxpv_rec, l_sxp_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sxp_rec
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
  -- PL/SQL TBL delete_row for:SXPV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sxpv_tbl                     IN sxpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sxpv_tbl.COUNT > 0) THEN
      i := p_sxpv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sxpv_rec                     => p_sxpv_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sxpv_tbl.LAST);
        i := p_sxpv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
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
END OKL_SXP_PVT;

/
