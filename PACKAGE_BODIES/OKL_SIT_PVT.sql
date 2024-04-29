--------------------------------------------------------
--  DDL for Package Body OKL_SIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SIT_PVT" AS
/* $Header: OKLSSITB.pls 120.2 2005/10/30 03:47:28 appldev noship $ */
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
  -- FUNCTION get_rec for: OKL_SIF_STREAM_TYPES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sit_rec                      IN sit_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sit_rec_type IS
    CURSOR sit_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SIF_ID,
            STY_ID,
            SIL_ID,
            SFE_ID,
			PRICING_NAME,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Sif_Stream_Types
     WHERE okl_sif_stream_types.id = p_id;
    l_sit_pk                       sit_pk_csr%ROWTYPE;
    l_sit_rec                      sit_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sit_pk_csr (p_sit_rec.id);
    FETCH sit_pk_csr INTO
              l_sit_rec.ID,
              l_sit_rec.OBJECT_VERSION_NUMBER,
              l_sit_rec.SIF_ID,
              l_sit_rec.STY_ID,
              l_sit_rec.SIL_ID,
              l_sit_rec.SFE_ID,
              l_sit_rec.SFE_ID,
              l_sit_rec.CREATED_BY,
              l_sit_rec.CREATION_DATE,
              l_sit_rec.LAST_UPDATED_BY,
              l_sit_rec.LAST_UPDATE_DATE,
              l_sit_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := sit_pk_csr%NOTFOUND;
    CLOSE sit_pk_csr;
    RETURN(l_sit_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sit_rec                      IN sit_rec_type
  ) RETURN sit_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sit_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_STREAM_TYPES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sitv_rec                     IN sitv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sitv_rec_type IS
    CURSOR sitv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SIF_ID,
            STY_ID,
            SIL_ID,
            SFE_ID,
			PRICING_NAME,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Sif_Stream_Types_V
     WHERE okl_sif_stream_types_v.id = p_id;
    l_sitv_pk                      sitv_pk_csr%ROWTYPE;
    l_sitv_rec                     sitv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sitv_pk_csr (p_sitv_rec.id);
    FETCH sitv_pk_csr INTO
              l_sitv_rec.ID,
              l_sitv_rec.OBJECT_VERSION_NUMBER,
              l_sitv_rec.SIF_ID,
              l_sitv_rec.STY_ID,
              l_sitv_rec.SIL_ID,
              l_sitv_rec.SFE_ID,
			  l_sitv_rec.PRICING_NAME,
              l_sitv_rec.CREATED_BY,
              l_sitv_rec.CREATION_DATE,
              l_sitv_rec.LAST_UPDATED_BY,
              l_sitv_rec.LAST_UPDATE_DATE,
              l_sitv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := sitv_pk_csr%NOTFOUND;
    CLOSE sitv_pk_csr;
    RETURN(l_sitv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sitv_rec                     IN sitv_rec_type
  ) RETURN sitv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sitv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SIF_STREAM_TYPES_V --
  ------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_sitv_rec	IN sitv_rec_type
  ) RETURN sitv_rec_type IS
    l_sitv_rec	sitv_rec_type := p_sitv_rec;
  BEGIN
    IF (l_sitv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_sitv_rec.object_version_number := NULL;
    END IF;
    IF (l_sitv_rec.sif_id = OKC_API.G_MISS_NUM) THEN
      l_sitv_rec.sif_id := NULL;
    END IF;
    IF (l_sitv_rec.sty_id = OKC_API.G_MISS_NUM) THEN
      l_sitv_rec.sty_id := NULL;
    END IF;
    IF (l_sitv_rec.sil_id = OKC_API.G_MISS_NUM) THEN
      l_sitv_rec.sil_id := NULL;
    END IF;
    IF (l_sitv_rec.sfe_id = OKC_API.G_MISS_NUM) THEN
      l_sitv_rec.sfe_id := NULL;
    END IF;
	IF (l_sitv_rec.pricing_name = OKC_API.G_MISS_CHAR) THEN
      l_sitv_rec.pricing_name := NULL;
    END IF;
    IF (l_sitv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_sitv_rec.created_by := NULL;
    END IF;
    IF (l_sitv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_sitv_rec.creation_date := NULL;
    END IF;
    IF (l_sitv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_sitv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sitv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_sitv_rec.last_update_date := NULL;
    END IF;
    IF (l_sitv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_sitv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_sitv_rec);
  END null_out_defaults;

  /* mvasudev - 12/20/2001
  * Commenting out nocopy generated validated_attributes in favour of using individual functions for
  * each Column
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKL_SIF_STREAM_TYPES_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_sitv_rec IN  sitv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_sitv_rec.id = OKC_API.G_MISS_NUM OR
       p_sitv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sitv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_sitv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sitv_rec.sif_id = OKC_API.G_MISS_NUM OR
          p_sitv_rec.sif_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sif_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sitv_rec.sty_id = OKC_API.G_MISS_NUM OR
          p_sitv_rec.sty_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sty_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
  */

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Id
    ---------------------------------------------------------------------------
          -- Start of comments
          -- Author          : mvasudev
          -- Procedure Name  : Validate_Id
          -- Description     :
          -- Business Rules  :
          -- Parameters      :
          -- Version         : 1.0
          -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Id(p_sitv_rec IN  sitv_rec_type,
                          x_return_status OUT NOCOPY  VARCHAR2)

      IS

      l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

      BEGIN
        -- initialize return status
        x_return_status := Okc_Api.G_RET_STS_SUCCESS;
        -- check for data before processing
        IF (p_sitv_rec.id = OKC_API.G_MISS_NUM) OR
	           (p_sitv_rec.id IS NULL)      THEN

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
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
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

PROCEDURE Validate_Object_Version_Number(p_sitv_rec IN  sitv_rec_type,x_return_status OUT NOCOPY  VARCHAR2)

    IS

    l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

    BEGIN
      -- initialize return status
      x_return_status := Okc_Api.G_RET_STS_SUCCESS;
      -- check for data before processing
      IF (p_sitv_rec.object_version_number IS NULL) OR
	 (p_sitv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
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
    p_sitv_rec      IN   sitv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SIL_SIF_FK;
  CURSOR okl_sifv_pk_csr (p_id IN OKL_SIF_LINES_V.sif_id%TYPE) IS
  SELECT '1'
    FROM OKL_STREAM_INTERFACES_V
   WHERE OKL_STREAM_INTERFACES_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sitv_rec.sif_id = Okc_Api.G_MISS_NUM OR
       p_sitv_rec.sif_id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Sif_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_sifv_pk_csr(p_sitv_rec.Sif_id);
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
  -- PROCEDURE Validate_Sty_Id
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
    p_sitv_rec      IN   sitv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SIt_STY_FK;
  CURSOR okl_styv_pk_csr (p_id IN OKL_SIF_STREAM_TYPES_V.sty_id%TYPE) IS
  SELECT '1'
    FROM OKL_STRM_TYPE_V
   WHERE OKL_STRM_TYPE_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sitv_rec.sty_id = Okc_Api.G_MISS_NUM OR
       p_sitv_rec.sty_id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Sty_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_styv_pk_csr(p_sitv_rec.Sty_id);
    FETCH okl_styv_pk_csr INTO l_dummy;
    l_row_not_found := okl_styv_pk_csr%NOTFOUND;
    CLOSE okl_styv_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'sty_id');
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
      IF okl_styv_pk_csr%ISOPEN THEN
        CLOSE okl_styv_pk_csr;
      END IF;

  END Validate_Sty_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sil_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sil_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sil_Id(
    p_sitv_rec      IN   sitv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SIT_SIL_FK;
  CURSOR okl_silv_pk_csr (p_id IN OKL_SIF_STREAM_TYPES_V.Sil_id%TYPE) IS
  SELECT '1'
    FROM OKL_SIF_LINES_V
   WHERE OKL_SIF_LINES_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sitv_rec.Sil_id <> Okc_Api.G_MISS_NUM AND p_sitv_rec.Sil_id IS NOT NULL
    THEN
	    OPEN okl_silv_pk_csr(p_sitv_rec.Sil_id);
	    FETCH okl_silv_pk_csr INTO l_dummy;
	    l_row_not_found := okl_silv_pk_csr%NOTFOUND;
	    CLOSE okl_silv_pk_csr;

	    IF l_row_not_found THEN
	      Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Sil_id');
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
      IF okl_silv_pk_csr%ISOPEN THEN
        CLOSE okl_silv_pk_csr;
      END IF;

  END Validate_Sil_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sfe_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sfe_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sfe_Id(
    p_sitv_rec      IN   sitv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SIT_Sfe_FK;
  CURSOR okl_sfev_pk_csr (p_id IN OKL_SIF_STREAM_TYPES_V.sfe_id%TYPE) IS
  SELECT '1'
    FROM OKL_SIF_FEES_V
   WHERE OKL_SIF_FEES_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sitv_rec.sfe_id <> Okc_Api.G_MISS_NUM AND p_sitv_rec.sfe_id IS NOT NULL
    THEN
	    OPEN okl_sfev_pk_csr(p_sitv_rec.sfe_id);
	    FETCH okl_sfev_pk_csr INTO l_dummy;
	    l_row_not_found := okl_sfev_pk_csr%NOTFOUND;
	    CLOSE okl_sfev_pk_csr;

	    IF l_row_not_found THEN
	      Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'sfe_id');
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
      IF okl_sfev_pk_csr%ISOPEN THEN
        CLOSE okl_sfev_pk_csr;
      END IF;

  END Validate_Sfe_Id;

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
    p_sitv_rec IN  sitv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    -- Validate_Id
    Validate_Id(p_sitv_rec, x_return_status);
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
    Validate_Object_Version_Number(p_sitv_rec, x_return_status);
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
    Validate_Sif_id(p_sitv_rec, x_return_status);
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

    -- Validate_Sty_Id
    Validate_Sty_Id(p_sitv_rec, x_return_status);
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

    -- Validate_Sil_Id
    Validate_Sil_Id(p_sitv_rec, x_return_status);
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

    -- Validate_Sfe_Id
    Validate_Sfe_Id(p_sitv_rec, x_return_status);
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
                           p_msg_name         => G_OKL_UNEXPECTED_ERROR,
                           p_token1           => G_OKL_SQLCODE_TOKEN,
                           p_token1_value     => SQLCODE,
                           p_token2           => G_OKL_SQLERRM_TOKEN,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    RETURN(l_return_status);
  END Validate_Attributes;
  -- END change : mvasudev

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Record for:OKL_SIF_STREAM_TYPES_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_sitv_rec IN sitv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN sitv_rec_type,
    --p_to	OUT NOCOPY sit_rec_type
    p_to	IN OUT NOCOPY sit_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sif_id := p_from.sif_id;
    p_to.sty_id := p_from.sty_id;
    p_to.sil_id := p_from.sil_id;
    p_to.sfe_id := p_from.sfe_id;
    p_to.pricing_name := p_from.pricing_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN sit_rec_type,
    --p_to	OUT NOCOPY sitv_rec_type
    p_to	IN OUT NOCOPY sitv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sif_id := p_from.sif_id;
    p_to.sty_id := p_from.sty_id;
    p_to.sil_id := p_from.sil_id;
    p_to.sfe_id := p_from.sfe_id;
    p_to.pricing_name := p_from.pricing_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- validate_row for:OKL_SIF_STREAM_TYPES_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_rec                     IN sitv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sitv_rec                     sitv_rec_type := p_sitv_rec;
    l_sit_rec                      sit_rec_type;
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
    l_return_status := Validate_Attributes(l_sitv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sitv_rec);
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
  -- PL/SQL TBL validate_row for:SITV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_tbl                     IN sitv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 12/20/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sitv_tbl.COUNT > 0) THEN
      i := p_sitv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sitv_rec                     => p_sitv_tbl(i));
    	-- START change : mvasudev, 12/20/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_sitv_tbl.LAST);
        i := p_sitv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 12/20/2001
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
  -----------------------------------------
  -- insert_row for:OKL_SIF_STREAM_TYPES --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sit_rec                      IN sit_rec_type,
    x_sit_rec                      OUT NOCOPY sit_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TYPES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sit_rec                      sit_rec_type := p_sit_rec;
    l_def_sit_rec                  sit_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SIF_STREAM_TYPES --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_sit_rec IN  sit_rec_type,
      x_sit_rec OUT NOCOPY sit_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sit_rec := p_sit_rec;
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
      p_sit_rec,                         -- IN
      l_sit_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SIF_STREAM_TYPES(
        id,
        object_version_number,
        sif_id,
        sty_id,
        sil_id,
        sfe_id,
		pricing_name,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_sit_rec.id,
        l_sit_rec.object_version_number,
        l_sit_rec.sif_id,
        l_sit_rec.sty_id,
        l_sit_rec.sil_id,
        l_sit_rec.sfe_id,
        l_sit_rec.pricing_name,
        l_sit_rec.created_by,
        l_sit_rec.creation_date,
        l_sit_rec.last_updated_by,
        l_sit_rec.last_update_date,
        l_sit_rec.last_update_login);
    -- Set OUT values
    x_sit_rec := l_sit_rec;
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
  -------------------------------------------
  -- insert_row for:OKL_SIF_STREAM_TYPES_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_rec                     IN sitv_rec_type,
    x_sitv_rec                     OUT NOCOPY sitv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sitv_rec                     sitv_rec_type;
    l_def_sitv_rec                 sitv_rec_type;
    l_sit_rec                      sit_rec_type;
    lx_sit_rec                     sit_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sitv_rec	IN sitv_rec_type
    ) RETURN sitv_rec_type IS
      l_sitv_rec	sitv_rec_type := p_sitv_rec;
    BEGIN
      l_sitv_rec.CREATION_DATE := SYSDATE;
      l_sitv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sitv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sitv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sitv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sitv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKL_SIF_STREAM_TYPES_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_sitv_rec IN  sitv_rec_type,
      x_sitv_rec OUT NOCOPY sitv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sitv_rec := p_sitv_rec;
      x_sitv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_sitv_rec := null_out_defaults(p_sitv_rec);
    -- Set primary key value
    l_sitv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_sitv_rec,                        -- IN
      l_def_sitv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sitv_rec := fill_who_columns(l_def_sitv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sitv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sitv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sitv_rec, l_sit_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sit_rec,
      lx_sit_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sit_rec, l_def_sitv_rec);
    -- Set OUT values
    x_sitv_rec := l_def_sitv_rec;
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
  -- PL/SQL TBL insert_row for:SITV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_tbl                     IN sitv_tbl_type,
    x_sitv_tbl                     OUT NOCOPY sitv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 12/20/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sitv_tbl.COUNT > 0) THEN
      i := p_sitv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sitv_rec                     => p_sitv_tbl(i),
          x_sitv_rec                     => x_sitv_tbl(i));
        	-- START change : mvasudev, 12/20/2001
        	-- store the highest degree of error
        	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
        	    	l_overall_status := x_return_status;
        	    END IF;
        	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_sitv_tbl.LAST);
        i := p_sitv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 12/20/2001
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
  ---------------------------------------
  -- lock_row for:OKL_SIF_STREAM_TYPES --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sit_rec                      IN sit_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sit_rec IN sit_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_STREAM_TYPES
     WHERE ID = p_sit_rec.id
       AND OBJECT_VERSION_NUMBER = p_sit_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sit_rec IN sit_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_STREAM_TYPES
    WHERE ID = p_sit_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TYPES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SIF_STREAM_TYPES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SIF_STREAM_TYPES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sit_rec);
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
      OPEN lchk_csr(p_sit_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sit_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sit_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for:OKL_SIF_STREAM_TYPES_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_rec                     IN sitv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sit_rec                      sit_rec_type;
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
    migrate(p_sitv_rec, l_sit_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sit_rec
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
  -- PL/SQL TBL lock_row for:SITV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_tbl                     IN sitv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 12/20/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sitv_tbl.COUNT > 0) THEN
      i := p_sitv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sitv_rec                     => p_sitv_tbl(i));
        	-- START change : mvasudev, 12/20/2001
        	-- store the highest degree of error
        	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
        	    	l_overall_status := x_return_status;
        	    END IF;
        	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_sitv_tbl.LAST);
        i := p_sitv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 12/20/2001
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
  -----------------------------------------
  -- update_row for:OKL_SIF_STREAM_TYPES --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sit_rec                      IN sit_rec_type,
    x_sit_rec                      OUT NOCOPY sit_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TYPES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sit_rec                      sit_rec_type := p_sit_rec;
    l_def_sit_rec                  sit_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sit_rec	IN sit_rec_type,
      x_sit_rec	OUT NOCOPY sit_rec_type
    ) RETURN VARCHAR2 IS
      l_sit_rec                      sit_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sit_rec := p_sit_rec;
      -- Get current database values
      l_sit_rec := get_rec(p_sit_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sit_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sit_rec.id := l_sit_rec.id;
      END IF;
      IF (x_sit_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sit_rec.object_version_number := l_sit_rec.object_version_number;
      END IF;
      IF (x_sit_rec.sif_id = OKC_API.G_MISS_NUM)
      THEN
        x_sit_rec.sif_id := l_sit_rec.sif_id;
      END IF;
      IF (x_sit_rec.sty_id = OKC_API.G_MISS_NUM)
      THEN
        x_sit_rec.sty_id := l_sit_rec.sty_id;
      END IF;
      IF (x_sit_rec.sil_id = OKC_API.G_MISS_NUM)
      THEN
        x_sit_rec.sil_id := l_sit_rec.sil_id;
      END IF;
      IF (x_sit_rec.sfe_id = OKC_API.G_MISS_NUM)
      THEN
        x_sit_rec.sfe_id := l_sit_rec.sfe_id;
      END IF;
      IF (x_sit_rec.pricing_name = OKC_API.G_MISS_CHAR)
      THEN
        x_sit_rec.pricing_name := l_sit_rec.pricing_name;
      END IF;
      IF (x_sit_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sit_rec.created_by := l_sit_rec.created_by;
      END IF;
      IF (x_sit_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sit_rec.creation_date := l_sit_rec.creation_date;
      END IF;
      IF (x_sit_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sit_rec.last_updated_by := l_sit_rec.last_updated_by;
      END IF;
      IF (x_sit_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sit_rec.last_update_date := l_sit_rec.last_update_date;
      END IF;
      IF (x_sit_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sit_rec.last_update_login := l_sit_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SIF_STREAM_TYPES --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_sit_rec IN  sit_rec_type,
      x_sit_rec OUT NOCOPY sit_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sit_rec := p_sit_rec;
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
      p_sit_rec,                         -- IN
      l_sit_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sit_rec, l_def_sit_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SIF_STREAM_TYPES
    SET OBJECT_VERSION_NUMBER = l_def_sit_rec.object_version_number,
        SIF_ID = l_def_sit_rec.sif_id,
        STY_ID = l_def_sit_rec.sty_id,
        SIL_ID = l_def_sit_rec.sil_id,
        SFE_ID = l_def_sit_rec.sfe_id,
		PRICING_NAME = l_def_sit_rec.pricing_name,
        CREATED_BY = l_def_sit_rec.created_by,
        CREATION_DATE = l_def_sit_rec.creation_date,
		LAST_UPDATED_BY = l_def_sit_rec.last_updated_by,
		LAST_UPDATE_DATE = l_def_sit_rec.last_update_date,
		LAST_UPDATE_LOGIN = l_def_sit_rec.last_update_login
    WHERE ID = l_def_sit_rec.id;

    x_sit_rec := l_def_sit_rec;
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
  -------------------------------------------
  -- update_row for:OKL_SIF_STREAM_TYPES_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_rec                     IN sitv_rec_type,
    x_sitv_rec                     OUT NOCOPY sitv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sitv_rec                     sitv_rec_type := p_sitv_rec;
    l_def_sitv_rec                 sitv_rec_type;
    l_sit_rec                      sit_rec_type;
    lx_sit_rec                     sit_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sitv_rec	IN sitv_rec_type
    ) RETURN sitv_rec_type IS
      l_sitv_rec	sitv_rec_type := p_sitv_rec;
    BEGIN
      l_sitv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sitv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sitv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sitv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sitv_rec	IN sitv_rec_type,
      x_sitv_rec	OUT NOCOPY sitv_rec_type
    ) RETURN VARCHAR2 IS
      l_sitv_rec                     sitv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sitv_rec := p_sitv_rec;
      -- Get current database values
      l_sitv_rec := get_rec(p_sitv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sitv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sitv_rec.id := l_sitv_rec.id;
      END IF;
      IF (x_sitv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sitv_rec.object_version_number := l_sitv_rec.object_version_number;
      END IF;
      IF (x_sitv_rec.sif_id = OKC_API.G_MISS_NUM)
      THEN
        x_sitv_rec.sif_id := l_sitv_rec.sif_id;
      END IF;
      IF (x_sitv_rec.sty_id = OKC_API.G_MISS_NUM)
      THEN
        x_sitv_rec.sty_id := l_sitv_rec.sty_id;
      END IF;
      IF (x_sitv_rec.sil_id = OKC_API.G_MISS_NUM)
      THEN
        x_sitv_rec.sil_id := l_sitv_rec.sil_id;
      END IF;
      IF (x_sitv_rec.sfe_id = OKC_API.G_MISS_NUM)
      THEN
        x_sitv_rec.sfe_id := l_sitv_rec.sfe_id;
      END IF;
      IF (x_sitv_rec.pricing_name = OKC_API.G_MISS_CHAR)
      THEN
        x_sitv_rec.pricing_name := l_sitv_rec.pricing_name;
      END IF;
      IF (x_sitv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sitv_rec.created_by := l_sitv_rec.created_by;
      END IF;
      IF (x_sitv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sitv_rec.creation_date := l_sitv_rec.creation_date;
      END IF;
      IF (x_sitv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sitv_rec.last_updated_by := l_sitv_rec.last_updated_by;
      END IF;
      IF (x_sitv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sitv_rec.last_update_date := l_sitv_rec.last_update_date;
      END IF;
      IF (x_sitv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sitv_rec.last_update_login := l_sitv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_SIF_STREAM_TYPES_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_sitv_rec IN  sitv_rec_type,
      x_sitv_rec OUT NOCOPY sitv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sitv_rec := p_sitv_rec;
      x_sitv_rec.OBJECT_VERSION_NUMBER := NVL(x_sitv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_sitv_rec,                        -- IN
      l_sitv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sitv_rec, l_def_sitv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sitv_rec := fill_who_columns(l_def_sitv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sitv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sitv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sitv_rec, l_sit_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sit_rec,
      lx_sit_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sit_rec, l_def_sitv_rec);
    x_sitv_rec := l_def_sitv_rec;
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
  -- PL/SQL TBL update_row for:SITV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_tbl                     IN sitv_tbl_type,
    x_sitv_tbl                     OUT NOCOPY sitv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 12/20/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sitv_tbl.COUNT > 0) THEN
      i := p_sitv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sitv_rec                     => p_sitv_tbl(i),
          x_sitv_rec                     => x_sitv_tbl(i));
        	-- START change : mvasudev, 12/20/2001
        	-- store the highest degree of error
        	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
        	    	l_overall_status := x_return_status;
        	    END IF;
        	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_sitv_tbl.LAST);
        i := p_sitv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 12/20/2001
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
  -----------------------------------------
  -- delete_row for:OKL_SIF_STREAM_TYPES --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sit_rec                      IN sit_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TYPES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sit_rec                      sit_rec_type:= p_sit_rec;
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
    DELETE FROM OKL_SIF_STREAM_TYPES
     WHERE ID = l_sit_rec.id;

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
  -------------------------------------------
  -- delete_row for:OKL_SIF_STREAM_TYPES_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_rec                     IN sitv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sitv_rec                     sitv_rec_type := p_sitv_rec;
    l_sit_rec                      sit_rec_type;
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
    migrate(l_sitv_rec, l_sit_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sit_rec
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
  -- PL/SQL TBL delete_row for:SITV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_tbl                     IN sitv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 12/20/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sitv_tbl.COUNT > 0) THEN
      i := p_sitv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sitv_rec                     => p_sitv_tbl(i));
        	-- START change : mvasudev, 12/20/2001
        	-- store the highest degree of error
        	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
        	    	l_overall_status := x_return_status;
        	    END IF;
        	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_sitv_tbl.LAST);
        i := p_sitv_tbl.NEXT(i);

      END LOOP;
      -- START change : mvasudev, 12/20/2001
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
  END delete_row;
END OKL_SIT_PVT;

/
