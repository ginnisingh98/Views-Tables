--------------------------------------------------------
--  DDL for Package Body OKL_GTT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GTT_PVT" AS
/* $Header: OKLSGTTB.pls 120.4 2006/07/13 12:56:58 adagur noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
  END get_seq_id;


 ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ST_GEN_TEMPLATES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_gtt_rec                      IN  gtt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN gtt_rec_type IS
    CURSOR okl_st_gen_templates_pk_csr (p_id IN NUMBER) IS
    SELECT  ID
            ,OBJECT_VERSION_NUMBER
            ,GTS_ID
            ,VERSION
            ,START_DATE
            ,END_DATE
            ,TMPT_STATUS
            ,ATTRIBUTE_CATEGORY
            ,ATTRIBUTE1
            ,ATTRIBUTE2
            ,ATTRIBUTE3
            ,ATTRIBUTE4
            ,ATTRIBUTE5
            ,ATTRIBUTE6
            ,ATTRIBUTE7
            ,ATTRIBUTE8
            ,ATTRIBUTE9
            ,ATTRIBUTE10
            ,ATTRIBUTE11
            ,ATTRIBUTE12
            ,ATTRIBUTE13
            ,ATTRIBUTE14
            ,ATTRIBUTE15
            ,ORG_ID
            ,CREATED_BY
            ,CREATION_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATE_LOGIN
    FROM OKL_ST_GEN_TEMPLATES
    WHERE OKL_ST_GEN_TEMPLATES.id = p_id;

    l_okl_st_gen_templates_pk   okl_st_gen_templates_pk_csr%ROWTYPE;
    l_gtt_rec                   gtt_rec_type;
  BEGIN
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_st_gen_templates_pk_csr (p_gtt_rec.id);

    FETCH okl_st_gen_templates_pk_csr INTO
        l_gtt_rec.id
        ,l_gtt_rec.object_version_number
        ,l_gtt_rec.gts_id
        ,l_gtt_rec.version
        ,l_gtt_rec.start_date
        ,l_gtt_rec.end_date
        ,l_gtt_rec.tmpt_status
        ,l_gtt_rec.attribute_category
        ,l_gtt_rec.attribute1
        ,l_gtt_rec.attribute2
        ,l_gtt_rec.attribute3
        ,l_gtt_rec.attribute4
        ,l_gtt_rec.attribute5
        ,l_gtt_rec.attribute6
        ,l_gtt_rec.attribute7
        ,l_gtt_rec.attribute8
        ,l_gtt_rec.attribute9
        ,l_gtt_rec.attribute10
        ,l_gtt_rec.attribute11
        ,l_gtt_rec.attribute12
        ,l_gtt_rec.attribute13
        ,l_gtt_rec.attribute14
        ,l_gtt_rec.attribute15
        ,l_gtt_rec.org_id
        ,l_gtt_rec.created_by
        ,l_gtt_rec.creation_date
        ,l_gtt_rec.last_updated_by
        ,l_gtt_rec.last_update_date
        ,l_gtt_rec.last_update_login;

    x_no_data_found := okl_st_gen_templates_pk_csr%NOTFOUND;
    CLOSE okl_st_gen_templates_pk_csr;

    RETURN(l_gtt_rec);

  END get_rec;

  FUNCTION get_rec (
    p_gtt_rec                      IN gtt_rec_type
  ) RETURN gtt_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_gtt_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SYS_ACCT_OPTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_gttv_rec                     IN  gttv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN gttv_rec_type IS
    CURSOR okl_gttv_pk_csr (p_id                 IN NUMBER) IS
    SELECT   ID
            ,OBJECT_VERSION_NUMBER
            ,GTS_ID
            ,VERSION
            ,START_DATE
            ,END_DATE
            ,TMPT_STATUS
            ,ATTRIBUTE_CATEGORY
            ,ATTRIBUTE1
            ,ATTRIBUTE2
            ,ATTRIBUTE3
            ,ATTRIBUTE4
            ,ATTRIBUTE5
            ,ATTRIBUTE6
            ,ATTRIBUTE7
            ,ATTRIBUTE8
            ,ATTRIBUTE9
            ,ATTRIBUTE10
            ,ATTRIBUTE11
            ,ATTRIBUTE12
            ,ATTRIBUTE13
            ,ATTRIBUTE14
            ,ATTRIBUTE15
            ,ORG_ID
            ,CREATED_BY
            ,CREATION_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATE_LOGIN
    FROM OKL_ST_GEN_TEMPLATES
    WHERE OKL_ST_GEN_TEMPLATES.ID = p_id;

    l_okl_gttv_pk                  okl_gttv_pk_csr%ROWTYPE;
    l_gttv_rec                     gttv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_gttv_pk_csr (p_gttv_rec.id);
    FETCH okl_gttv_pk_csr INTO
        l_gttv_rec.id
        ,l_gttv_rec.object_version_number
        ,l_gttv_rec.gts_id
        ,l_gttv_rec.version
        ,l_gttv_rec.start_date
        ,l_gttv_rec.end_date
        ,l_gttv_rec.tmpt_status
        ,l_gttv_rec.attribute_category
        ,l_gttv_rec.attribute1
        ,l_gttv_rec.attribute2
        ,l_gttv_rec.attribute3
        ,l_gttv_rec.attribute4
        ,l_gttv_rec.attribute5
        ,l_gttv_rec.attribute6
        ,l_gttv_rec.attribute7
        ,l_gttv_rec.attribute8
        ,l_gttv_rec.attribute9
        ,l_gttv_rec.attribute10
        ,l_gttv_rec.attribute11
        ,l_gttv_rec.attribute12
        ,l_gttv_rec.attribute13
        ,l_gttv_rec.attribute14
        ,l_gttv_rec.attribute15
        ,l_gttv_rec.org_id
        ,l_gttv_rec.created_by
        ,l_gttv_rec.creation_date
        ,l_gttv_rec.last_updated_by
        ,l_gttv_rec.last_update_date
        ,l_gttv_rec.last_update_login;

    x_no_data_found := okl_gttv_pk_csr%NOTFOUND;
    CLOSE okl_gttv_pk_csr;
    RETURN(l_gttv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_gttv_rec                     IN gttv_rec_type
  ) RETURN gttv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_gttv_rec, l_row_notfound));
  END get_rec;


  ----------------------------------------------
  -- validate_record for:OKL_ST_GEN_TEMPLATES --
  ----------------------------------------------
   FUNCTION validate_record (
    p_gttv_rec IN gttv_rec_type
   ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
    -- End_date should be greater than or equal to start_date
    IF ( p_gttv_rec.end_date IS NOT NULL OR p_gttv_rec.end_date <> Okl_Api.G_MISS_DATE )
    THEN
        IF ( p_gttv_rec.end_date >= p_gttv_rec.start_date )
        THEN
            -- Do Nothing.
            NULL;
        ELSE
            Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_INVALID_END_DATE);
            x_return_status := Okl_Api.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END IF;

    RETURN (l_return_status);
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
  END validate_record;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
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
    p_gttv_rec      IN   gttv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_gttv_rec.id = Okl_Api.G_MISS_NUM OR
       p_gttv_rec.id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_object_version_number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(
    p_gttv_rec      IN   gttv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_gttv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_gttv_rec.object_version_number IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_start_date
  ---------------------------------------------------------------------------
  PROCEDURE validate_start_date(
    p_gttv_Rec          IN gttv_Rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status		VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_gttv_Rec.start_date = OKL_API.G_MISS_DATE OR p_gttv_Rec.start_date IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'START_FROM');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_start_date;

  ---------------------------------------------------------------------------
    -- PROCEDURE validate_tmpt_status
  ---------------------------------------------------------------------------
  PROCEDURE validate_tmpt_status(
      p_gttv_rec      IN   gttv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    ) IS
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    BEGIN
      -- initialize return status
      x_return_status := okl_api.G_RET_STS_SUCCESS;

      -- check for data before processing
      IF (p_gttv_rec.tmpt_status IS NOT NULL) AND
         (p_gttv_rec.tmpt_status  <> okl_api.G_MISS_CHAR) THEN

      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_STREAM_GEN_TMPT_STATUS',
                                     p_lookup_code => p_gttv_rec.tmpt_status);


      IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'TMPT_STATUS');
         x_return_status := okl_api.G_RET_STS_ERROR;
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
        okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

    END validate_tmpt_status;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_gts_id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_gts_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE validate_gts_id (p_gttv_rec      IN   gttv_rec_type
                ,x_return_status OUT NOCOPY  VARCHAR2 )
  IS

  l_dummy         VARCHAR2(1)  := Okl_Api.G_FALSE;

  CURSOR gts_csr(p_gts_id NUMBER) IS
  SELECT '1'
  FROM OKL_ST_GEN_TMPT_SETS
  WHERE OKL_ST_GEN_TMPT_SETS.ID  = p_gts_id;


  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF (p_gttv_rec.gts_id  IS NOT NULL) AND (p_gttv_rec.gts_id <> Okl_Api.G_MISS_NUM) THEN
       OPEN gts_csr(p_gttv_rec.gts_id);
       FETCH gts_csr INTO l_dummy;
       IF (gts_csr%NOTFOUND) THEN
           Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'GTS_ID');
           x_return_status    := Okl_Api.G_RET_STS_ERROR;
           CLOSE gts_csr;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE gts_csr;
    ELSE
        Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'GTS_ID');
        x_return_status    := Okl_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END validate_gts_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_version
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_version
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE validate_version (p_gttv_rec      IN   gttv_rec_type
                ,x_return_status OUT NOCOPY  VARCHAR2 )
  IS

  l_dummy         VARCHAR2(1)  := Okl_Api.G_FALSE;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF (p_gttv_rec.version  IS NULL) OR
        (p_gttv_rec.version <> Okl_Api.G_MISS_NUM)
    THEN
           Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'VERSION');
           x_return_status    := Okl_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
        NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END validate_version;


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
    p_gttv_rec IN  gttv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation


     -- Validate_Id
    Validate_Id(p_gttv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Object_Version_Number
    validate_object_version_number(p_gttv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

     -- validate_start_date
    validate_start_date(p_gttv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

     -- validate_tmpt_status
    validate_tmpt_status(p_gttv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- validate_gts_id
    validate_gts_id(p_gttv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
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
  END; --Validate_Attributes

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
  -- FUNCTION null_out_defaults
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : null_out_defaults
  -- Description     : nulling out the defaults
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_gttv_rec	IN gttv_rec_type
  ) RETURN gttv_rec_type IS
    l_gttv_rec	gttv_rec_type := p_gttv_rec;
  BEGIN
    IF (l_gttv_rec.id = Okl_Api.G_MISS_NUM) THEN
        l_gttv_rec.id := NULL;
    END IF;
    IF (l_gttv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
        l_gttv_rec.object_version_number := NULL;
    END IF;
    IF (l_gttv_rec.version = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.version := NULL;
    END IF;
    IF (l_gttv_rec.start_date = Okl_Api.G_MISS_DATE ) THEN
        l_gttv_rec.start_date := NULL;
    END IF;
    IF (l_gttv_rec.end_date = Okl_Api.G_MISS_DATE ) THEN
        l_gttv_rec.end_date := NULL;
    END IF;
    IF (l_gttv_rec.tmpt_status = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.tmpt_status := NULL;
    END IF;
    IF (l_gttv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute_category := NULL;
    END IF;
    IF (l_gttv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute1 := NULL;
    END IF;
    IF (l_gttv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute2 := NULL;
    END IF;
    IF (l_gttv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute3 := NULL;
    END IF;
    IF (l_gttv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute4 := NULL;
    END IF;
    IF (l_gttv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute5 := NULL;
    END IF;
    IF (l_gttv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute6 := NULL;
    END IF;
    IF (l_gttv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute7 := NULL;
    END IF;
    IF (l_gttv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute8 := NULL;
    END IF;
    IF (l_gttv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute9 := NULL;
    END IF;
    IF (l_gttv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute10 := NULL;
    END IF;
    IF (l_gttv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute11 := NULL;
    END IF;
    IF (l_gttv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute12 := NULL;
    END IF;
    IF (l_gttv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute13 := NULL;
    END IF;
    IF (l_gttv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute14 := NULL;
    END IF;
    IF (l_gttv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
        l_gttv_rec.attribute15 := NULL;
    END IF;
    IF (l_gttv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_gttv_rec.org_id := NULL;
    END IF;
    IF (l_gttv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_gttv_rec.created_by := NULL;
    END IF;
    IF (l_gttv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_gttv_rec.creation_date := NULL;
    END IF;
    IF (l_gttv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_gttv_rec.last_updated_by := NULL;
    END IF;
    IF (l_gttv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_gttv_rec.last_update_date := NULL;
    END IF;
    IF (l_gttv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_gttv_rec.last_update_login := NULL;
    END IF;

    RETURN(l_gttv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN gtt_rec_type,
    p_to	IN OUT NOCOPY gttv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.gts_id := p_from.gts_id;
    p_to.version := p_from.version;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.tmpt_status := p_from.tmpt_status;
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
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN gttv_rec_type,
    p_to	IN OUT NOCOPY gtt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.gts_id := p_from.gts_id;
    p_to.version := p_from.version;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.tmpt_status := p_from.tmpt_status;
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
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END;

 ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : procedure for inserting the records in
  --                   table OKL_ST_GEN_TEMPLATES
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtt_rec                      IN gtt_rec_type,
    x_gtt_rec                      OUT NOCOPY gtt_rec_type ) AS

    -- Local Variables within the function
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtt_rec                     gtt_rec_type := p_gtt_rec;
    l_def_gtt_rec                 gtt_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_ST_GEN_TEMPLATES --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_gtt_rec IN  gtt_rec_type,
      x_gtt_rec OUT NOCOPY gtt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtt_rec := p_gtt_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_gtt_rec,    -- IN
      l_gtt_rec     -- OUT
    );
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_ST_GEN_TEMPLATES(
         id
        ,object_version_number
        ,gts_id
        ,version
        ,start_date
        ,end_date
        ,tmpt_status
        ,attribute_category
        ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
        ,org_id
        ,created_by
        ,creation_date
        ,last_updated_by
        ,last_update_date
        ,last_update_login
    )
    VALUES (
         l_gtt_rec.id
        ,l_gtt_rec.object_version_number
        ,l_gtt_rec.gts_id
        ,l_gtt_rec.version
        ,l_gtt_rec.start_date
        ,l_gtt_rec.end_date
        ,l_gtt_rec.tmpt_status
        ,l_gtt_rec.attribute_category
        ,l_gtt_rec.attribute1
        ,l_gtt_rec.attribute2
        ,l_gtt_rec.attribute3
        ,l_gtt_rec.attribute4
        ,l_gtt_rec.attribute5
        ,l_gtt_rec.attribute6
        ,l_gtt_rec.attribute7
        ,l_gtt_rec.attribute8
        ,l_gtt_rec.attribute9
        ,l_gtt_rec.attribute10
        ,l_gtt_rec.attribute11
        ,l_gtt_rec.attribute12
        ,l_gtt_rec.attribute13
        ,l_gtt_rec.attribute14
        ,l_gtt_rec.attribute15
        ,l_gtt_rec.org_id
        ,l_gtt_rec.created_by
        ,l_gtt_rec.creation_date
        ,l_gtt_rec.last_updated_by
        ,l_gtt_rec.last_update_date
        ,l_gtt_rec.last_update_login
    );

    -- Set OUT values
    x_gtt_rec := l_gtt_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gttv_rec                     IN  gttv_rec_type,
    x_gttv_rec                     OUT NOCOPY gttv_rec_type ) IS

    -- Local Variables within the function
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gttv_rec                     gttv_rec_type;
    l_def_gttv_rec                 gttv_rec_type;
    l_gtt_rec                      gtt_rec_type;
    lx_gtt_rec                     gtt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_gttv_rec	IN gttv_rec_type
    ) RETURN gttv_rec_type IS
      l_gttv_rec	gttv_rec_type := p_gttv_rec;
    BEGIN
      l_gttv_rec.CREATION_DATE := SYSDATE;
      l_gttv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_gttv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_gttv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_gttv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_gttv_rec);
    END fill_who_columns;

    -----------------------------------------------
    -- Set_Attributes for:OKL_ST_GEN_TEMPLATES_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_gttv_rec IN  gttv_rec_type,
      x_gttv_rec OUT NOCOPY gttv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gttv_rec := p_gttv_rec;
      x_gttv_rec.OBJECT_VERSION_NUMBER := 1;
      x_gttv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();

      RETURN(l_return_status);
    END Set_Attributes;

   BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_gttv_rec := null_out_defaults(p_gttv_rec);

    -- Set primary key value
    l_gttv_rec.ID := get_seq_id;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_gttv_rec,                        -- IN
      l_def_gttv_rec);                   -- OUT

    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- fill who columns for the l_def_gttv_rec
    l_def_gttv_rec := fill_who_columns(l_def_gttv_rec);

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_gttv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Perfrom all row level validations
    l_return_status := validate_record(l_def_gttv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_gttv_rec, l_gtt_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------

    insert_row (
       p_api_version => l_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data
      ,p_gtt_rec => l_gtt_rec
      ,x_gtt_rec => lx_gtt_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_gtt_rec, l_def_gttv_rec);

    -- Set OUT values
    x_gttv_rec := l_def_gttv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END; -- insert_row

  ----------------------------------------
  -- PL/SQL TBL insert_row for:GTTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gttv_tbl                     IN  gttv_tbl_type,
    x_gttv_tbl                     OUT NOCOPY gttv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status 		       VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);

    -- Making sure PL/SQL table has records in it before passing
    IF (p_gttv_tbl.COUNT > 0) THEN
      i := p_gttv_tbl.FIRST;
      LOOP

        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gttv_rec                     => p_gttv_tbl(i),
          x_gttv_rec                     => x_gttv_tbl(i));

    	-- store the highest degree of error
    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
        EXIT WHEN (i = p_gttv_tbl.LAST);
        i := p_gttv_tbl.NEXT(i);
      END LOOP;

      -- return overall status
      x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_row
  -- Description     : procedure for updating the records in
  --                   table OKL_ST_GEN_TEMPLATES
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  --------------------------------------------------------------------------

  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtt_rec                      IN  gtt_rec_type,
    x_gtt_rec                      OUT NOCOPY gtt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtt_rec                      gtt_rec_type := p_gtt_rec;
    l_def_gtt_rec                  gtt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_gtt_rec	IN  gtt_rec_type,
      x_gtt_rec	OUT NOCOPY gtt_rec_type
    ) RETURN VARCHAR2 IS
      l_gtt_rec                      gtt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtt_rec := p_gtt_rec;

      -- Get current database values
      l_gtt_rec := get_rec( p_gtt_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_gtt_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtt_rec.id := l_gtt_rec.id;
      END IF;
      IF (x_gtt_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_gtt_rec.object_version_number := l_gtt_rec.object_version_number;
      END IF;
      IF (x_gtt_rec.version = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.version := l_gtt_rec.version;
      END IF;
      IF (x_gtt_rec.start_date = Okl_Api.G_MISS_DATE ) THEN
        x_gtt_rec.start_date := l_gtt_rec.start_date;
      END IF;
      IF (x_gtt_rec.end_date = Okl_Api.G_MISS_DATE ) THEN
        x_gtt_rec.end_date := l_gtt_rec.end_date;
      END IF;
      IF (x_gtt_rec.tmpt_status = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.tmpt_status := l_gtt_rec.tmpt_status;
      END IF;
      IF (x_gtt_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute_category := l_gtt_rec.attribute_category;
      END IF;
      IF (x_gtt_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute1 := l_gtt_rec.attribute1;
      END IF;
      IF (x_gtt_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute2 := l_gtt_rec.attribute2;
      END IF;
      IF (x_gtt_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute3 := l_gtt_rec.attribute3;
      END IF;
      IF (x_gtt_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute4 := l_gtt_rec.attribute4;
      END IF;
      IF (x_gtt_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute5 := l_gtt_rec.attribute5;
      END IF;
      IF (x_gtt_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute6 := l_gtt_rec.attribute6;
      END IF;
      IF (x_gtt_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute7 := l_gtt_rec.attribute7;
      END IF;
      IF (x_gtt_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute8 := l_gtt_rec.attribute8;
      END IF;
      IF (x_gtt_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute9 := l_gtt_rec.attribute9;
      END IF;
      IF (x_gtt_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute10 := l_gtt_rec.attribute10;
      END IF;
      IF (x_gtt_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute11 := l_gtt_rec.attribute11;
      END IF;
      IF (x_gtt_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute12 := l_gtt_rec.attribute12;
      END IF;
      IF (x_gtt_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute13 := l_gtt_rec.attribute13;
      END IF;
      IF (x_gtt_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute14 := l_gtt_rec.attribute14;
      END IF;
      IF (x_gtt_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
        x_gtt_rec.attribute15 := l_gtt_rec.attribute15;
      END IF;
      IF (x_gtt_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtt_rec.org_id := l_gtt_rec.org_id;
      END IF;
      IF (x_gtt_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_gtt_rec.created_by := l_gtt_rec.created_by;
      END IF;
      IF (x_gtt_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_gtt_rec.creation_date := l_gtt_rec.creation_date;
      END IF;
      IF (x_gtt_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_gtt_rec.last_updated_by := l_gtt_rec.last_updated_by;
      END IF;
      IF (x_gtt_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_gtt_rec.last_update_date := l_gtt_rec.last_update_date;
      END IF;
      IF (x_gtt_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_gtt_rec.last_update_login := l_gtt_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_ST_GEN_TEMPLATES --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_gtt_rec IN  gtt_rec_type,
      x_gtt_rec OUT NOCOPY gtt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtt_rec := p_gtt_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
   /* l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF; */
    l_return_status := Okl_Api.G_RET_STS_SUCCESS;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_gtt_rec,                         -- IN
      l_gtt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_gtt_rec, l_def_gtt_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKL_ST_GEN_TEMPLATES
    SET ID                     = l_def_gtt_rec.id
        ,OBJECT_VERSION_NUMBER  = l_def_gtt_rec.object_version_number
        ,GTS_ID                = l_def_gtt_rec.gts_id
        ,VERSION               = l_def_gtt_rec.version
        ,START_DATE            = l_def_gtt_rec.start_date
        ,END_DATE              = l_def_gtt_rec.end_date
        ,TMPT_STATUS           = l_def_gtt_rec.tmpt_status
        ,ATTRIBUTE_CATEGORY    = l_def_gtt_rec.attribute_category
        ,ATTRIBUTE1            = l_def_gtt_rec.attribute1
        ,ATTRIBUTE2            = l_def_gtt_rec.attribute2
        ,ATTRIBUTE3            = l_def_gtt_rec.attribute3
        ,ATTRIBUTE4            = l_def_gtt_rec.attribute4
        ,ATTRIBUTE5            = l_def_gtt_rec.attribute5
        ,ATTRIBUTE6            = l_def_gtt_rec.attribute6
        ,ATTRIBUTE7            = l_def_gtt_rec.attribute7
        ,ATTRIBUTE8            = l_def_gtt_rec.attribute8
        ,ATTRIBUTE9            = l_def_gtt_rec.attribute9
        ,ATTRIBUTE10           = l_def_gtt_rec.attribute10
        ,ATTRIBUTE11           = l_def_gtt_rec.attribute11
        ,ATTRIBUTE12           = l_def_gtt_rec.attribute12
        ,ATTRIBUTE13           = l_def_gtt_rec.attribute13
        ,ATTRIBUTE14           = l_def_gtt_rec.attribute14
        ,ATTRIBUTE15           = l_def_gtt_rec.attribute15
        ,ORG_ID                = l_def_gtt_rec.org_id
        ,CREATED_BY            = l_def_gtt_rec.created_by
        ,CREATION_DATE         = l_def_gtt_rec.creation_date
        ,LAST_UPDATED_BY       = l_def_gtt_rec.last_updated_by
        ,LAST_UPDATE_DATE      = l_def_gtt_rec.last_update_date
        ,LAST_UPDATE_LOGIN     = l_def_gtt_rec.last_update_login
    WHERE ID = l_def_gtt_rec.id;

    x_gtt_rec := l_def_gtt_rec;
    x_return_status := l_return_Status;
   -- Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

    PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gttv_rec                      IN  gttv_rec_type,
    x_gttv_rec                      OUT NOCOPY gttv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gttv_rec                     gttv_rec_type := p_gttv_rec;
    l_def_gttv_rec                 gttv_rec_type;
    l_gtt_rec                      gtt_rec_type;
    lx_gtt_rec                     gtt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_gttv_rec	IN gttv_rec_type
    ) RETURN gttv_rec_type IS
      l_gttv_rec	gttv_rec_type := p_gttv_rec;
    BEGIN
      l_gttv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_gttv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_gttv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_gttv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_gttv_rec	IN  gttv_rec_type,
      x_gttv_rec	OUT NOCOPY gttv_rec_type
    ) RETURN VARCHAR2 IS
      l_gttv_rec                      gttv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gttv_rec := p_gttv_rec;

      -- Get current database values
      l_gttv_rec := get_rec(p_gttv_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_gttv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_gttv_rec.id := l_gtt_rec.id;
      END IF;
      IF (x_gttv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_gttv_rec.object_version_number := l_gttv_rec.object_version_number;
      END IF;
      IF (x_gttv_rec.version = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.version := l_gttv_rec.version;
      END IF;
      IF (x_gttv_rec.start_date = Okl_Api.G_MISS_DATE ) THEN
        x_gttv_rec.start_date := l_gttv_rec.start_date;
      END IF;
      IF (x_gttv_rec.end_date = Okl_Api.G_MISS_DATE ) THEN
        x_gttv_rec.end_date := l_gttv_rec.end_date;
      END IF;
      IF (x_gttv_rec.tmpt_status = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.tmpt_status := l_gttv_rec.tmpt_status;
      END IF;
      IF (x_gttv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute_category := l_gttv_rec.attribute_category;
      END IF;
      IF (x_gttv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute1 := l_gttv_rec.attribute1;
      END IF;
      IF (x_gttv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute2 := l_gttv_rec.attribute2;
      END IF;
      IF (x_gttv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute3 := l_gttv_rec.attribute3;
      END IF;
      IF (x_gttv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute4 := l_gttv_rec.attribute4;
      END IF;
      IF (x_gttv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute5 := l_gttv_rec.attribute5;
      END IF;
      IF (x_gttv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute6 := l_gttv_rec.attribute6;
      END IF;
      IF (x_gttv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute7 := l_gttv_rec.attribute7;
      END IF;
      IF (x_gttv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute8 := l_gttv_rec.attribute8;
      END IF;
      IF (x_gttv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute9 := l_gttv_rec.attribute9;
      END IF;
      IF (x_gttv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute10 := l_gttv_rec.attribute10;
      END IF;
      IF (x_gttv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute11 := l_gttv_rec.attribute11;
      END IF;
      IF (x_gttv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute12 := l_gttv_rec.attribute12;
      END IF;
      IF (x_gttv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute13 := l_gttv_rec.attribute13;
      END IF;
      IF (x_gttv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute14 := l_gttv_rec.attribute14;
      END IF;
      IF (x_gttv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
        x_gttv_rec.attribute15 := l_gttv_rec.attribute15;
      END IF;
      IF (x_gttv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_gttv_rec.org_id := l_gttv_rec.org_id;
      END IF;
      IF (x_gttv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_gttv_rec.created_by := l_gttv_rec.created_by;
      END IF;
      IF (x_gttv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_gttv_rec.creation_date := l_gttv_rec.creation_date;
      END IF;
      IF (x_gttv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_gttv_rec.last_updated_by := l_gttv_rec.last_updated_by;
      END IF;
      IF (x_gttv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_gttv_rec.last_update_date := l_gttv_rec.last_update_date;
      END IF;
      IF (x_gttv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_gttv_rec.last_update_login := l_gttv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for: OKL_ST_GEN_TEMPLATES --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_gttv_rec IN  gttv_rec_type,
      x_gttv_rec OUT NOCOPY gttv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gttv_rec := p_gttv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
 /*   l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF; */
    l_return_status := Okl_Api.G_RET_STS_SUCCESS;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_gttv_rec,                        -- IN
      l_gttv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_gttv_rec, l_def_gttv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_gttv_rec := fill_who_columns(l_def_gttv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_gttv_rec);

    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_gttv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_gttv_rec, l_gtt_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_gtt_rec => l_gtt_rec,
      x_gtt_rec => lx_gtt_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_gtt_rec, l_def_gttv_rec);

    x_gttv_rec := l_def_gttv_rec;
    x_return_status := l_return_status;
    --Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END;


  ----------------------------------------------------
  -- PL/SQL TBL update_row for:OKL_ST_GEN_TEMPLATES --
  ----------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gttv_tbl                     IN  gttv_tbl_type,
    x_gttv_tbl                     OUT NOCOPY gttv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    l_overall_status 		  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_gttv_tbl.COUNT > 0) THEN
      i := p_gttv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gttv_rec                     => p_gttv_tbl(i),
          x_gttv_rec                     => x_gttv_tbl(i));

    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;

        EXIT WHEN (i = p_gttv_tbl.LAST);
        i := p_gttv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_ST_GEN_TEMPLATES --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtt_rec                      IN  gtt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtt_rec                      gtt_rec_type:= p_gtt_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Actual deletion of the row
    DELETE FROM OKL_ST_GEN_TEMPLATES
     WHERE ID = l_gtt_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_ST_GEN_TEMPLATES --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gttv_rec                     IN  gttv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gttv_rec                     gttv_rec_type := p_gttv_rec;
    l_gtt_rec                      gtt_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_gttv_rec, l_gtt_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_gtt_rec => l_gtt_rec
    );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  ----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_ST_GEN_TEMPLATES --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gttv_tbl                     IN  gttv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    l_overall_status 		  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing
    IF (p_gttv_tbl.COUNT > 0) THEN
      i := p_gttv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gttv_rec                     => p_gttv_tbl(i));

    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;

        EXIT WHEN (i = p_gttv_tbl.LAST);
        i := p_gttv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END okl_gtt_pvt;

/
