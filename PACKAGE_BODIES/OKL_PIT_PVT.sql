--------------------------------------------------------
--  DDL for Package Body OKL_PIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PIT_PVT" AS
/* $Header: OKLSPITB.pls 115.13 2002/12/18 13:03:07 kjinger noship $ */
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
  -- FUNCTION get_rec for: OKL_PRD_PRICE_TMPLS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pit_rec                      IN pit_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pit_rec_type IS
    CURSOR pit_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PDT_ID,
            TEMPLATE_NAME,
            -- mvasudev, 05/13/2002
            TEMPLATE_PATH,
            --
            VERSION,
            START_DATE,
            OBJECT_VERSION_NUMBER,
            END_DATE,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Prd_Price_Tmpls
     WHERE okl_prd_price_tmpls.id = p_id;
    l_pit_pk                       pit_pk_csr%ROWTYPE;
    l_pit_rec                      pit_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN pit_pk_csr (p_pit_rec.id);
    FETCH pit_pk_csr INTO
              l_pit_rec.ID,
              l_pit_rec.PDT_ID,
              l_pit_rec.TEMPLATE_NAME,
	      -- mvasudev , 05/13/2002
	      l_pit_rec.TEMPLATE_PATH,
	      --
              l_pit_rec.VERSION,
              l_pit_rec.START_DATE,
              l_pit_rec.OBJECT_VERSION_NUMBER,
              l_pit_rec.END_DATE,
              l_pit_rec.DESCRIPTION,
              l_pit_rec.CREATED_BY,
              l_pit_rec.CREATION_DATE,
              l_pit_rec.LAST_UPDATED_BY,
              l_pit_rec.LAST_UPDATE_DATE,
              l_pit_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := pit_pk_csr%NOTFOUND;
    CLOSE pit_pk_csr;
    RETURN(l_pit_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pit_rec                      IN pit_rec_type
  ) RETURN pit_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pit_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PRD_PRICE_TMPLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pitv_rec                     IN pitv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pitv_rec_type IS
    CURSOR okl_pitv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            PDT_ID,
            TEMPLATE_NAME,
            -- mvasudev , 05/13/2002
	    TEMPLATE_PATH,
	    --
	    VERSION,
            START_DATE,
            END_DATE,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Prd_Price_Tmpls_V
     WHERE okl_prd_price_tmpls_v.id = p_id;
    l_okl_pitv_pk                  okl_pitv_pk_csr%ROWTYPE;
    l_pitv_rec                     pitv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pitv_pk_csr (p_pitv_rec.id);
    FETCH okl_pitv_pk_csr INTO
              l_pitv_rec.ID,
              l_pitv_rec.OBJECT_VERSION_NUMBER,
              l_pitv_rec.PDT_ID,
              l_pitv_rec.TEMPLATE_NAME,
	      -- mvasudev , 05/13/2002
	      l_pitv_rec.TEMPLATE_PATH,
	      --
              l_pitv_rec.VERSION,
              l_pitv_rec.START_DATE,
              l_pitv_rec.END_DATE,
              l_pitv_rec.DESCRIPTION,
              l_pitv_rec.CREATED_BY,
              l_pitv_rec.CREATION_DATE,
              l_pitv_rec.LAST_UPDATED_BY,
              l_pitv_rec.LAST_UPDATE_DATE,
              l_pitv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pitv_pk_csr%NOTFOUND;
    CLOSE okl_pitv_pk_csr;
    RETURN(l_pitv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pitv_rec                     IN pitv_rec_type
  ) RETURN pitv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pitv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_PRD_PRICE_TMPLS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pitv_rec	IN pitv_rec_type
  ) RETURN pitv_rec_type IS
    l_pitv_rec	pitv_rec_type := p_pitv_rec;
  BEGIN
    IF (l_pitv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_pitv_rec.object_version_number := NULL;
    END IF;
    IF (l_pitv_rec.pdt_id = Okc_Api.G_MISS_NUM) THEN
      l_pitv_rec.pdt_id := NULL;
    END IF;
    IF (l_pitv_rec.template_name = Okc_Api.G_MISS_CHAR) THEN
      l_pitv_rec.template_name := NULL;
    END IF;
    -- mvasudev , 05/13/2002
    IF (l_pitv_rec.template_path = Okc_Api.G_MISS_CHAR) THEN
          l_pitv_rec.template_path := NULL;
    END IF;
    --
    IF (l_pitv_rec.version = Okc_Api.G_MISS_CHAR) THEN
      l_pitv_rec.version := NULL;
    END IF;
    IF (l_pitv_rec.start_date = Okc_Api.G_MISS_DATE) THEN
      l_pitv_rec.start_date := NULL;
    END IF;
    IF (l_pitv_rec.end_date = Okc_Api.G_MISS_DATE) THEN
      l_pitv_rec.end_date := NULL;
    END IF;
    IF (l_pitv_rec.description = Okc_Api.G_MISS_CHAR) THEN
      l_pitv_rec.description := NULL;
    END IF;
    IF (l_pitv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_pitv_rec.created_by := NULL;
    END IF;
    IF (l_pitv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_pitv_rec.creation_date := NULL;
    END IF;
    IF (l_pitv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_pitv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pitv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_pitv_rec.last_update_date := NULL;
    END IF;
    IF (l_pitv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_pitv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_pitv_rec);
  END null_out_defaults;


  -- START change : akjain , 05/07/2001
  /*
  -- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_PRD_PRICE_TMPLS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_pitv_rec IN  pitv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    IF p_pitv_rec.id = Okc_Api.G_MISS_NUM OR
       p_pitv_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pitv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
          p_pitv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pitv_rec.pdt_id = Okc_Api.G_MISS_NUM OR
          p_pitv_rec.pdt_id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pdt_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pitv_rec.template_name = Okc_Api.G_MISS_CHAR OR
          p_pitv_rec.template_name IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'template_name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pitv_rec.start_date = Okc_Api.G_MISS_DATE OR
          p_pitv_rec.start_date IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'start_date');
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
    p_pitv_rec      IN   pitv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_pitv_rec.id = Okc_Api.G_MISS_NUM OR
       p_pitv_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

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
  	p_pitv_rec      IN   pitv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_pitv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
       p_pitv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Pdt_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Pdt_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Pdt_Id(
  	p_pitv_rec      IN   pitv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) := '?';
  l_row_not_found             BOOLEAN := FALSE;

  -- Cursor For OKL_PRODUCTS - Foreign Key Constraint
  CURSOR okl_pdt_pk_csr (p_id IN OKL_PRODUCTS_V.id%TYPE) IS
  SELECT '1'
    FROM OKL_PRODUCTS_V
   WHERE OKL_PRODUCTS_V.id = p_id;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_pitv_rec.pdt_id = Okc_Api.G_MISS_NUM OR
       p_pitv_rec.pdt_id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pdt_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_pdt_pk_csr (p_pitv_rec.pdt_id);
    FETCH okl_pdt_pk_csr INTO l_dummy;
    l_row_not_found := okl_pdt_pk_csr%NOTFOUND;
    CLOSE okl_pdt_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'pdt_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_pdt_pk_csr%ISOPEN THEN
        CLOSE okl_pdt_pk_csr;
      END IF;

  END Validate_Pdt_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Template_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Template_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Template_Name(
    p_pitv_rec      IN   pitv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;


  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_pitv_rec.template_name = Okc_Api.G_MISS_CHAR OR
       p_pitv_rec.template_name IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'template_name');
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Template_Name;

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
  PROCEDURE Validate_Version(
    p_pitv_rec      IN   pitv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;


  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_pitv_rec.version = Okc_Api.G_MISS_CHAR OR
       p_pitv_rec.version IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'version');
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Version;


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
  PROCEDURE Validate_Start_Date(
    p_pitv_rec      IN   pitv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2)
  IS
  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pitv_rec.start_date IS NULL) OR
       (p_pitv_rec.start_date = Okc_Api.G_MISS_DATE) THEN
       Okc_Api.SET_MESSAGE( p_app_name       => G_OKC_APP,
                           p_msg_name       => g_required_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'start_date' );
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
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

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Start_Date;



  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Pit_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Pit_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Pit_Record(
    p_pitv_rec      IN   pitv_rec_type,
    x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy		VARCHAR2(1)	:= '?';
  l_row_found		BOOLEAN 	:= FALSE;

  -- Cursor for PIT Unique Key
  CURSOR okl_pit_uk_csr(p_rec pitv_rec_type) IS
  SELECT '1'
  FROM OKL_PRD_PRICE_TMPLS_V
  WHERE  pdt_id =  p_rec.pdt_id
    AND  version = p_rec.version
    AND  id     <> NVL(p_rec.id,-9999);

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    OPEN okl_pit_uk_csr(p_pitv_rec);
    FETCH okl_pit_uk_csr INTO l_dummy;
    l_row_found := okl_pit_uk_csr%FOUND;
    CLOSE okl_pit_uk_csr;
    IF l_row_found THEN
	Okc_Api.set_message(G_APP_NAME,G_OKL_UNQS);
	x_return_status := OKC_API.G_RET_STS_ERROR;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
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
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      -- verify that the cursor was closed
	  IF okl_pit_uk_csr%ISOPEN THEN
        CLOSE okl_pit_uk_csr;
      END IF;
  END Validate_Unique_Pit_Record;


  ------------------------------------------------------------------------------
  -- PROCEDURE Validate_End_Date
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_End_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE Validate_End_Date(
    p_pitv_rec      IN   pitv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_start_date            DATE         := Okc_Api.G_MISS_DATE;
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    l_start_date := p_pitv_rec.start_date;
    -- check for data before processing
	IF   p_pitv_rec.end_date <> OKC_API.G_MISS_DATE AND p_pitv_rec.end_date IS NOT NULL
	THEN
	    IF 	p_pitv_rec.end_date  < l_start_date
	    THEN
	      Okc_Api.SET_MESSAGE( p_app_name   => G_OKC_APP,
                           p_msg_name       => g_invalid_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'end_date' );
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
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

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_End_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Template_Path
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Template_Path
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Template_Path(
    p_pitv_rec      IN   pitv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;


  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_pitv_rec.Template_Path = Okc_Api.G_MISS_CHAR OR
       p_pitv_rec.Template_Path IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Template_Path');
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Template_Path;



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
    p_pitv_rec IN  pitv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    -- Validate_Id
    Validate_Id(p_pitv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;


    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(p_pitv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;



    -- Validate_Template_Name
    Validate_Template_Name(p_pitv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Template_Path
    Validate_Template_Path(p_pitv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;


    -- Validate_Pdt_Id
    Validate_Pdt_Id(p_pitv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Version
    Validate_Version(p_pitv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;


    -- Validate_Start_Date
    Validate_Start_Date(p_pitv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;


	 -- Validate_End_Date
    Validate_End_Date(p_pitv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
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
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

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
    p_pitv_rec IN pitv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Unique_Pit_Record
    Validate_Unique_Pit_Record(p_pitv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
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
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;


  /*
  -- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_PRD_PRICE_TMPLS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_pitv_rec IN pitv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  */

  -- END change : akjain

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN pitv_rec_type,
    p_to	IN OUT NOCOPY pit_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.pdt_id := p_from.pdt_id;
    p_to.template_name := p_from.template_name;
    -- mvasudev , 05/13/2002
    p_to.template_path := p_from.template_path;
    --
    p_to.version := p_from.version;
    p_to.start_date := p_from.start_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.end_date := p_from.end_date;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN pit_rec_type,
    p_to	IN OUT NOCOPY pitv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.pdt_id := p_from.pdt_id;
    p_to.template_name := p_from.template_name;
    -- mvasudev , 05/13/2002
    p_to.template_path := p_from.template_path;
    --
    p_to.version := p_from.version;
    p_to.start_date := p_from.start_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.end_date := p_from.end_date;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKL_PRD_PRICE_TMPLS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN pitv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pitv_rec                     pitv_rec_type := p_pitv_rec;
    l_pit_rec                      pit_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_pitv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pitv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
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
  -- PL/SQL TBL validate_row for:PITV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN pitv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- END change : akjain



  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pitv_tbl.COUNT > 0) THEN
      i := p_pitv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pitv_rec                     => p_pitv_tbl(i));

       -- START change : akjain, 05/15/2001
       -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                 l_overall_status := x_return_status;
                END IF;
          END IF;
       -- END change : akjain
       EXIT WHEN (i = p_pitv_tbl.LAST);
        i := p_pitv_tbl.NEXT(i);
      END LOOP;
      -- START change : akjain, 05/15/2001
            -- return overall status
      x_return_status := l_overall_status;
      -- END change : akjain
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
  ----------------------------------------
  -- insert_row for:OKL_PRD_PRICE_TMPLS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pit_rec                      IN pit_rec_type,
    x_pit_rec                      OUT NOCOPY pit_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TMPLS_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pit_rec                      pit_rec_type := p_pit_rec;
    l_def_pit_rec                  pit_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_PRD_PRICE_TMPLS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_pit_rec IN  pit_rec_type,
      x_pit_rec OUT NOCOPY pit_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_pit_rec := p_pit_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_pit_rec,                         -- IN
      l_pit_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_PRD_PRICE_TMPLS(
        id,
        pdt_id,
        template_name,
        -- mvasudev , 05/13/2002
        template_path,
        --
        version,
        start_date,
        object_version_number,
        end_date,
        description,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_pit_rec.id,
        l_pit_rec.pdt_id,
        l_pit_rec.template_name,
	-- mvasudev , 05/13/2002
	l_pit_rec.template_path,
	--
        l_pit_rec.version,
        l_pit_rec.start_date,
        l_pit_rec.object_version_number,
        l_pit_rec.end_date,
        l_pit_rec.description,
        l_pit_rec.created_by,
        l_pit_rec.creation_date,
        l_pit_rec.last_updated_by,
        l_pit_rec.last_update_date,
        l_pit_rec.last_update_login);
    -- Set OUT values
    x_pit_rec := l_pit_rec;
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
  ------------------------------------------
  -- insert_row for:OKL_PRD_PRICE_TMPLS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN pitv_rec_type,
    x_pitv_rec                     OUT NOCOPY pitv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pitv_rec                     pitv_rec_type;
    l_def_pitv_rec                 pitv_rec_type;
    l_pit_rec                      pit_rec_type;
    lx_pit_rec                     pit_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pitv_rec	IN pitv_rec_type
    ) RETURN pitv_rec_type IS
      l_pitv_rec	pitv_rec_type := p_pitv_rec;
    BEGIN
      l_pitv_rec.CREATION_DATE := SYSDATE;
      l_pitv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pitv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pitv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pitv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pitv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_PRD_PRICE_TMPLS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_pitv_rec IN  pitv_rec_type,
      x_pitv_rec OUT NOCOPY pitv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_pitv_rec := p_pitv_rec;
      x_pitv_rec.OBJECT_VERSION_NUMBER := 1;
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

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    l_pitv_rec := null_out_defaults(p_pitv_rec);
    -- Set primary key value
    l_pitv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_pitv_rec,                        -- IN
      l_def_pitv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_pitv_rec := fill_who_columns(l_def_pitv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pitv_rec);
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_pitv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pitv_rec, l_pit_rec);

    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pit_rec,
      lx_pit_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_pit_rec, l_def_pitv_rec);
    -- Set OUT values
    x_pitv_rec := l_def_pitv_rec;
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
  -- PL/SQL TBL insert_row for:PITV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN pitv_tbl_type,
    x_pitv_tbl                     OUT NOCOPY pitv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- END change : akjain


  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pitv_tbl.COUNT > 0) THEN
      i := p_pitv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pitv_rec                     => p_pitv_tbl(i),
          x_pitv_rec                     => x_pitv_tbl(i));


        -- START change : akjain, 05/15/2001
	-- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain

        EXIT WHEN (i = p_pitv_tbl.LAST);
        i := p_pitv_tbl.NEXT(i);
      END LOOP;

       -- START change : akjain, 05/15/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain
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

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- lock_row for:OKL_PRD_PRICE_TMPLS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pit_rec                      IN pit_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pit_rec IN pit_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PRD_PRICE_TMPLS
     WHERE ID = p_pit_rec.id
       AND OBJECT_VERSION_NUMBER = p_pit_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_pit_rec IN pit_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PRD_PRICE_TMPLS
    WHERE ID = p_pit_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TMPLS_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_PRD_PRICE_TMPLS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_PRD_PRICE_TMPLS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_pit_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_pit_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pit_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pit_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okc_Api.set_message(G_OKC_APP,G_RECORD_LOGICALLY_DELETED);
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
  ----------------------------------------
  -- lock_row for:OKL_PRD_PRICE_TMPLS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN pitv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pit_rec                      pit_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_pitv_rec, l_pit_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pit_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
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
  -- PL/SQL TBL lock_row for:PITV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN pitv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pitv_tbl.COUNT > 0) THEN
      i := p_pitv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pitv_rec                     => p_pitv_tbl(i));
        -- START change : akjain, 05/15/2001
	-- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain

        EXIT WHEN (i = p_pitv_tbl.LAST);
        i := p_pitv_tbl.NEXT(i);
      END LOOP;
      -- START change : akjain, 05/15/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain
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
  ----------------------------------------
  -- update_row for:OKL_PRD_PRICE_TMPLS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pit_rec                      IN pit_rec_type,
    x_pit_rec                      OUT NOCOPY pit_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TMPLS_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pit_rec                      pit_rec_type := p_pit_rec;
    l_def_pit_rec                  pit_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pit_rec	IN pit_rec_type,
      x_pit_rec	OUT NOCOPY pit_rec_type
    ) RETURN VARCHAR2 IS
      l_pit_rec                      pit_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_pit_rec := p_pit_rec;
      -- Get current database values
      l_pit_rec := get_rec(p_pit_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pit_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_pit_rec.id := l_pit_rec.id;
      END IF;
      IF (x_pit_rec.pdt_id = Okc_Api.G_MISS_NUM)
      THEN
        x_pit_rec.pdt_id := l_pit_rec.pdt_id;
      END IF;
      IF (x_pit_rec.template_name = Okc_Api.G_MISS_CHAR)
      THEN
        x_pit_rec.template_name := l_pit_rec.template_name;
      END IF;
      -- mvasudev , 05/13/2002
      IF (x_pit_rec.template_path = Okc_Api.G_MISS_CHAR)
      THEN
              x_pit_rec.template_path := l_pit_rec.template_path;
      END IF;
      --
      IF (x_pit_rec.version = Okc_Api.G_MISS_CHAR)
      THEN
        x_pit_rec.version := l_pit_rec.version;
      END IF;
      IF (x_pit_rec.start_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pit_rec.start_date := l_pit_rec.start_date;
      END IF;
      IF (x_pit_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_pit_rec.object_version_number := l_pit_rec.object_version_number;
      END IF;
      IF (x_pit_rec.end_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pit_rec.end_date := l_pit_rec.end_date;
      END IF;
      IF (x_pit_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_pit_rec.description := l_pit_rec.description;
      END IF;
      IF (x_pit_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_pit_rec.created_by := l_pit_rec.created_by;
      END IF;
      IF (x_pit_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pit_rec.creation_date := l_pit_rec.creation_date;
      END IF;
      IF (x_pit_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_pit_rec.last_updated_by := l_pit_rec.last_updated_by;
      END IF;
      IF (x_pit_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pit_rec.last_update_date := l_pit_rec.last_update_date;
      END IF;
      IF (x_pit_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_pit_rec.last_update_login := l_pit_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_PRD_PRICE_TMPLS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_pit_rec IN  pit_rec_type,
      x_pit_rec OUT NOCOPY pit_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_pit_rec := p_pit_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_pit_rec,                         -- IN
      l_pit_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pit_rec, l_def_pit_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_PRD_PRICE_TMPLS
    SET PDT_ID = l_def_pit_rec.pdt_id,
        TEMPLATE_NAME = l_def_pit_rec.template_name,
        TEMPLATE_PATH = l_def_pit_rec.template_path,
        VERSION = l_def_pit_rec.version,
        START_DATE = l_def_pit_rec.start_date,
        OBJECT_VERSION_NUMBER = l_def_pit_rec.object_version_number,
        END_DATE = l_def_pit_rec.end_date,
        DESCRIPTION = l_def_pit_rec.description,
        CREATED_BY = l_def_pit_rec.created_by,
        CREATION_DATE = l_def_pit_rec.creation_date,
        LAST_UPDATED_BY = l_def_pit_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pit_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pit_rec.last_update_login
    WHERE ID = l_def_pit_rec.id;

    x_pit_rec := l_def_pit_rec;
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
  ------------------------------------------
  -- update_row for:OKL_PRD_PRICE_TMPLS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN pitv_rec_type,
    x_pitv_rec                     OUT NOCOPY pitv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pitv_rec                     pitv_rec_type := p_pitv_rec;
    l_def_pitv_rec                 pitv_rec_type;
    l_pit_rec                      pit_rec_type;
    lx_pit_rec                     pit_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pitv_rec	IN pitv_rec_type
    ) RETURN pitv_rec_type IS
      l_pitv_rec	pitv_rec_type := p_pitv_rec;
    BEGIN
      l_pitv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pitv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pitv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pitv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pitv_rec	IN pitv_rec_type,
      x_pitv_rec	OUT NOCOPY pitv_rec_type
    ) RETURN VARCHAR2 IS
      l_pitv_rec                     pitv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_pitv_rec := p_pitv_rec;
      -- Get current database values
      l_pitv_rec := get_rec(p_pitv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pitv_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_pitv_rec.id := l_pitv_rec.id;
      END IF;
      IF (x_pitv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_pitv_rec.object_version_number := l_pitv_rec.object_version_number;
      END IF;
      IF (x_pitv_rec.pdt_id = Okc_Api.G_MISS_NUM)
      THEN
        x_pitv_rec.pdt_id := l_pitv_rec.pdt_id;
      END IF;
      IF (x_pitv_rec.template_name = Okc_Api.G_MISS_CHAR)
      THEN
        x_pitv_rec.template_name := l_pitv_rec.template_name;
      END IF;
      -- mvasudev , 05/13/2002
      IF (x_pitv_rec.template_path = Okc_Api.G_MISS_CHAR)
      THEN
          x_pitv_rec.template_path := l_pitv_rec.template_path;
      END IF;
      --
      IF (x_pitv_rec.version = Okc_Api.G_MISS_CHAR)
      THEN
        x_pitv_rec.version := l_pitv_rec.version;
      END IF;
      IF (x_pitv_rec.start_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pitv_rec.start_date := l_pitv_rec.start_date;
      END IF;
      IF (x_pitv_rec.end_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pitv_rec.end_date := l_pitv_rec.end_date;
      END IF;
      IF (x_pitv_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_pitv_rec.description := l_pitv_rec.description;
      END IF;
      IF (x_pitv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_pitv_rec.created_by := l_pitv_rec.created_by;
      END IF;
      IF (x_pitv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pitv_rec.creation_date := l_pitv_rec.creation_date;
      END IF;
      IF (x_pitv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_pitv_rec.last_updated_by := l_pitv_rec.last_updated_by;
      END IF;
      IF (x_pitv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pitv_rec.last_update_date := l_pitv_rec.last_update_date;
      END IF;
      IF (x_pitv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_pitv_rec.last_update_login := l_pitv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_PRD_PRICE_TMPLS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_pitv_rec IN  pitv_rec_type,
      x_pitv_rec OUT NOCOPY pitv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_pitv_rec := p_pitv_rec;
      x_pitv_rec.OBJECT_VERSION_NUMBER := NVL(x_pitv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_pitv_rec,                        -- IN
      l_pitv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pitv_rec, l_def_pitv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_pitv_rec := fill_who_columns(l_def_pitv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pitv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pitv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pitv_rec, l_pit_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pit_rec,
      lx_pit_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pit_rec, l_def_pitv_rec);
    x_pitv_rec := l_def_pitv_rec;
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
  -- PL/SQL TBL update_row for:PITV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN pitv_tbl_type,
    x_pitv_tbl                     OUT NOCOPY pitv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pitv_tbl.COUNT > 0) THEN
      i := p_pitv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pitv_rec                     => p_pitv_tbl(i),
          x_pitv_rec                     => x_pitv_tbl(i));
        -- START change : akjain, 05/15/2001
	-- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain

        EXIT WHEN (i = p_pitv_tbl.LAST);
        i := p_pitv_tbl.NEXT(i);
      END LOOP;

       -- START change : akjain, 05/15/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain
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
  ----------------------------------------
  -- delete_row for:OKL_PRD_PRICE_TMPLS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pit_rec                      IN pit_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TMPLS_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pit_rec                      pit_rec_type:= p_pit_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_PRD_PRICE_TMPLS
     WHERE ID = l_pit_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKL_PRD_PRICE_TMPLS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN pitv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pitv_rec                     pitv_rec_type := p_pitv_rec;
    l_pit_rec                      pit_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_pitv_rec, l_pit_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pit_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
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
  -- PL/SQL TBL delete_row for:PITV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN pitv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pitv_tbl.COUNT > 0) THEN
      i := p_pitv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pitv_rec                     => p_pitv_tbl(i));
       -- START change : akjain, 05/15/2001
       -- store the highest degree of error
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                    l_overall_status := x_return_status;
           END IF;
       END IF;
       -- END change : akjain

       EXIT WHEN (i = p_pitv_tbl.LAST);
        i := p_pitv_tbl.NEXT(i);
      END LOOP;

       -- START change : akjain, 05/15/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain
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
END Okl_Pit_Pvt;

/
