--------------------------------------------------------
--  DDL for Package Body OKL_GTP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GTP_PVT" AS
/* $Header: OKLSGTPB.pls 120.3 2006/07/13 12:56:15 adagur noship $ */

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
  END get_seq_id;


 ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ST_GEN_PRC_PARAMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_gtp_rec                      IN  gtp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN gtp_rec_type IS
    CURSOR okl_st_gen_prc_params_pk_csr (p_id IN NUMBER) IS
    SELECT  ID
            ,OBJECT_VERSION_NUMBER
            ,NAME
            ,DESCRIPTION
            ,DISPLAY_YN
            ,UPDATE_YN
            ,PRC_ENG_IDENT
            ,DEFAULT_VALUE
            ,ORG_ID
            ,CREATED_BY
            ,CREATION_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATE_LOGIN
            ,GTT_ID
    FROM OKL_ST_GEN_PRC_PARAMS
    WHERE OKL_ST_GEN_PRC_PARAMS.id = p_id;

    l_okl_st_gen_prc_params_pk okl_st_gen_prc_params_pk_csr%ROWTYPE;
    l_gtp_rec                  gtp_rec_type;
  BEGIN
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_st_gen_prc_params_pk_csr (p_gtp_rec.id);

    FETCH okl_st_gen_prc_params_pk_csr INTO
         l_gtp_rec.id
        ,l_gtp_rec.object_version_number
        ,l_gtp_rec.name
        ,l_gtp_rec.description
        ,l_gtp_rec.display_yn
        ,l_gtp_rec.update_yn
        ,l_gtp_rec.prc_eng_ident
        ,l_gtp_rec.default_value
        ,l_gtp_rec.org_id
        ,l_gtp_rec.created_by
        ,l_gtp_rec.creation_date
        ,l_gtp_rec.last_updated_by
        ,l_gtp_rec.last_update_date
        ,l_gtp_rec.last_update_login
        ,l_gtp_rec.gtt_id;

    x_no_data_found := okl_st_gen_prc_params_pk_csr%NOTFOUND;
    CLOSE okl_st_gen_prc_params_pk_csr;

    RETURN(l_gtp_rec);

  END get_rec;

  FUNCTION get_rec (
    p_gtp_rec                      IN gtp_rec_type
  ) RETURN gtp_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_gtp_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ST_GEN_PRC_PARAMS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_gtpv_rec                     IN  gtpv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN gtpv_rec_type IS
    CURSOR okl_gtpv_pk_csr (p_id                 IN NUMBER) IS
    SELECT   ID
            ,OBJECT_VERSION_NUMBER
            ,NAME
            ,DESCRIPTION
            ,DISPLAY_YN
            ,UPDATE_YN
            ,PRC_ENG_IDENT
            ,DEFAULT_VALUE
            ,ORG_ID
            ,CREATED_BY
            ,CREATION_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATE_LOGIN
            ,GTT_ID
    FROM OKL_ST_GEN_PRC_PARAMS
    WHERE OKL_ST_GEN_PRC_PARAMS.ID = p_id;

    l_okl_gtpv_pk                  okl_gtpv_pk_csr%ROWTYPE;
    l_gtpv_rec                     gtpv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_gtpv_pk_csr (p_gtpv_rec.id);
    FETCH okl_gtpv_pk_csr INTO
        l_gtpv_rec.id
        ,l_gtpv_rec.object_version_number
        ,l_gtpv_rec.name
        ,l_gtpv_rec.description
        ,l_gtpv_rec.display_yn
        ,l_gtpv_rec.update_yn
        ,l_gtpv_rec.prc_eng_ident
        ,l_gtpv_rec.default_value
        ,l_gtpv_rec.org_id
        ,l_gtpv_rec.created_by
        ,l_gtpv_rec.creation_date
        ,l_gtpv_rec.last_updated_by
        ,l_gtpv_rec.last_update_date
        ,l_gtpv_rec.last_update_login
        ,l_gtpv_rec.gtt_id;

        x_no_data_found := okl_gtpv_pk_csr%NOTFOUND;
    CLOSE okl_gtpv_pk_csr;
    RETURN(l_gtpv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_gtpv_rec                     IN gtpv_rec_type
  ) RETURN gtpv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_gtpv_rec, l_row_notfound));
  END get_rec;

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



  ----------------------------------------------
  -- validate_record for: OKL_ST_GEN_TMPT_LNS_V --
  ----------------------------------------------
  FUNCTION validate_record (
    p_gtpv_rec IN gtpv_rec_type
  ) RETURN VARCHAR2 IS
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

    IF ( p_gtpv_rec.display_yn = 'Y' AND ( p_gtpv_rec.update_yn NOT IN  ( 'Y' , 'N' ) ) )
    THEN
     okl_api.SET_MESSAGE(   p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_DUMMY_MESSAGE',
                                p_token1       => 'TOKEN1',
                                p_token1_value => 'UPDATE_YN cannot have a value with out a value in DISPLAY_YN');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN (l_return_status);
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
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

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
    p_gtpv_rec      IN   gtpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_gtpv_rec.id = Okl_Api.G_MISS_NUM OR
       p_gtpv_rec.id IS NULL
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
    p_gtpv_rec      IN   gtpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_gtpv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_gtpv_rec.object_version_number IS NULL
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

  PROCEDURE Validate_name(
    p_gtpv_rec      IN   gtpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

    CURSOR okl_st_gen_prc_params_csr(p_name OKL_ST_GEN_PRC_PARAMS.name%type,
                                     p_gtt_id OKL_ST_GEN_PRC_PARAMS.gtt_id%TYPE ) IS
    SELECT  ID,
            NAME PRC_PARAM_NAME
    FROM OKL_ST_GEN_PRC_PARAMS gtp
    WHERE UPPER(gtp.name) = upper( p_name )
     AND  gtp.gtt_id = p_gtt_id;
    l_name_in_use VARCHAR2(1) := okl_api.G_FALSE;
  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    IF p_gtpv_rec.name = Okl_Api.G_MISS_CHAR OR
       p_gtpv_rec.name IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'PRICING_PARAM_NAME');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
        -- Check for the pricing parameter within this template and with the same name
        -- and with different ID. Because in Update you may update the existing pricing param name.
        FOR gtpv_temp_rec In okl_st_gen_prc_params_csr(p_gtpv_rec.name,p_gtpv_rec.gtt_id)
        LOOP
            IF( gtpv_temp_rec.id <> p_gtpv_rec.id )
            THEN
                l_name_in_use := Okl_Api.G_TRUE;
            END IF;
        END LOOP;
        IF ( l_name_in_use = Okl_Api.G_TRUE )
        THEN
            okl_api.set_message(G_APP_NAME,
                                G_INVALID_VALUE,
                                G_COL_NAME_TOKEN,
                                'PRICING_PARAM_NAME');
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
      Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_name;

  PROCEDURE validate_gtt_id (p_gtpv_rec      IN   gtpv_rec_type
                ,x_return_status OUT NOCOPY  VARCHAR2 )
  IS

  l_dummy         VARCHAR2(1)  := Okl_Api.G_FALSE;

  CURSOR gtt_csr(p_gtt_id NUMBER) IS
  SELECT '1'
  FROM OKL_ST_GEN_TEMPLATES
  WHERE OKL_ST_GEN_TEMPLATES.ID  = p_gtt_id;


  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF (p_gtpv_rec.gtt_id  IS NOT NULL) AND (p_gtpv_rec.gtt_id <> Okl_Api.G_MISS_NUM) THEN
       OPEN gtt_csr(p_gtpv_rec.gtt_id);
       FETCH gtt_csr INTO l_dummy;
       IF (gtt_csr%NOTFOUND) THEN
           Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'GTT_ID');
           x_return_status    := Okl_Api.G_RET_STS_ERROR;
           CLOSE gtt_csr;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE gtt_csr;
    ELSE
        Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'GTT_ID');
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

  END validate_gtt_id;

  PROCEDURE Validate_prc_eng_ident(
    p_gtpv_rec      IN   gtpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_gtpv_rec.prc_eng_ident = Okl_Api.G_MISS_CHAR OR
       p_gtpv_rec.prc_eng_ident IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'PRC_ENG_IDENT');
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
  END Validate_prc_eng_ident;

  PROCEDURE Validate_default_value(
    p_gtpv_rec      IN   gtpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_gtpv_rec.default_value = Okl_Api.G_MISS_CHAR OR
       p_gtpv_rec.default_value IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'DEFAULT_VALUE');
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
  END Validate_default_value;

  PROCEDURE Validate_update_yn(
    p_gtpv_rec      IN   gtpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_gtpv_rec.update_yn IS NOT NULL AND p_gtpv_rec.update_yn NOT IN ( 'Y', 'N' )
       AND p_gtpv_rec.update_yn <> Okl_Api.G_MISS_CHAR    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'UPDATE_YN');
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

  END Validate_update_yn;

  PROCEDURE Validate_display_yn(
    p_gtpv_rec      IN   gtpv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_gtpv_rec.display_yn IS NOT NULL AND p_gtpv_rec.display_yn NOT IN ( 'Y', 'N' )
       AND p_gtpv_rec.display_yn <> Okl_Api.G_MISS_CHAR    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'DISPLAY_YN');
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

  END Validate_display_yn;

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
    p_gtpv_rec IN  gtpv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation


     -- Validate_Id
    Validate_Id(p_gtpv_rec, x_return_status);
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
    validate_object_version_number(p_gtpv_rec, x_return_status);
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
     -- validate_name
    validate_name(p_gtpv_rec, x_return_status);
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
    -- Validate_display_yn
    Validate_display_yn(p_gtpv_rec, x_return_status);
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
    -- Validate_update_yn
    Validate_update_yn(p_gtpv_rec, x_return_status);
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

    -- validate_gtt_id
    validate_gtt_id(p_gtpv_rec, x_return_status);
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
    p_gtpv_rec	IN gtpv_rec_type
  ) RETURN gtpv_rec_type IS
    l_gtpv_rec	gtpv_rec_type := p_gtpv_rec;
  BEGIN
    IF (l_gtpv_rec.id = Okl_Api.G_MISS_NUM) THEN
        l_gtpv_rec.id := NULL;
    END IF;
    IF (l_gtpv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
        l_gtpv_rec.object_version_number := NULL;
    END IF;
    IF (l_gtpv_rec.name = Okl_Api.G_MISS_CHAR) THEN
        l_gtpv_rec.name := NULL;
    END IF;
    IF (l_gtpv_rec.description = Okl_Api.G_MISS_CHAR) THEN
        l_gtpv_rec.description := NULL;
    END IF;
    IF (l_gtpv_rec.display_yn = Okl_Api.G_MISS_CHAR) THEN
        l_gtpv_rec.display_yn := NULL;
    END IF;
    IF (l_gtpv_rec.update_yn = Okl_Api.G_MISS_CHAR) THEN
        l_gtpv_rec.update_yn := NULL;
    END IF;
    IF (l_gtpv_rec.prc_eng_ident = Okl_Api.G_MISS_CHAR) THEN
        l_gtpv_rec.prc_eng_ident := NULL;
    END IF;
    IF (l_gtpv_rec.default_value = Okl_Api.G_MISS_CHAR) THEN
        l_gtpv_rec.default_value := NULL;
    END IF;
    IF (l_gtpv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_gtpv_rec.org_id := NULL;
    END IF;
    IF (l_gtpv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_gtpv_rec.created_by := NULL;
    END IF;
    IF (l_gtpv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_gtpv_rec.creation_date := NULL;
    END IF;
    IF (l_gtpv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_gtpv_rec.last_updated_by := NULL;
    END IF;
    IF (l_gtpv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_gtpv_rec.last_update_date := NULL;
    END IF;
    IF (l_gtpv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_gtpv_rec.last_update_login := NULL;
    END IF;
    IF (l_gtpv_rec.gtt_id = Okl_Api.G_MISS_NUM) THEN
      l_gtpv_rec.gtt_id := NULL;
    END IF;

    RETURN(l_gtpv_rec);
  END null_out_defaults;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN gtp_rec_type,
    p_to	IN OUT NOCOPY gtpv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.display_yn := p_from.display_yn;
    p_to.update_yn := p_from.update_yn;
    p_to.prc_eng_ident := p_from.prc_eng_ident;
    p_to.default_value := p_from.default_value;
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.gtt_id := p_from.gtt_id;
  END;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN gtpv_rec_type,
    p_to	IN OUT NOCOPY gtp_rec_type
  ) IS
  BEGIN
   p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.display_yn := p_from.display_yn;
    p_to.update_yn := p_from.update_yn;
    p_to.prc_eng_ident := p_from.prc_eng_ident;
    p_to.default_value := p_from.default_value;
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.gtt_id := p_from.gtt_id;
  END;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_row
  -- Description     : procedure for inserting the records in
  --                   table OKL_ST_GEN_PRC_PARAMS
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
    p_gtp_rec                      IN gtp_rec_type,
    x_gtp_rec                      OUT NOCOPY gtp_rec_type ) AS

    -- Local Variables within the function
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtp_rec                     gtp_rec_type := p_gtp_rec;
    l_def_gtp_rec                 gtp_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_ST_GEN_PRC_PARAMS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_gtp_rec IN  gtp_rec_type,
      x_gtp_rec OUT NOCOPY gtp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtp_rec := p_gtp_rec;
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
      p_gtp_rec,    -- IN
      l_gtp_rec     -- OUT
    );
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_ST_GEN_PRC_PARAMS(
        ID
        ,OBJECT_VERSION_NUMBER
        ,NAME
        ,DESCRIPTION
        ,DISPLAY_YN
        ,UPDATE_YN
        ,PRC_ENG_IDENT
        ,DEFAULT_VALUE
        ,ORG_ID
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,GTT_ID
        )
    VALUES (
         l_gtp_rec.id
        ,l_gtp_rec.object_version_number
        ,l_gtp_rec.name
        ,l_gtp_rec.description
        ,l_gtp_rec.display_yn
        ,l_gtp_rec.update_yn
        ,l_gtp_rec.prc_eng_ident
        ,l_gtp_rec.default_value
        ,l_gtp_rec.org_id
        ,l_gtp_rec.created_by
        ,l_gtp_rec.creation_date
        ,l_gtp_rec.last_updated_by
        ,l_gtp_rec.last_update_date
        ,l_gtp_rec.last_update_login
        ,l_gtp_rec.gtt_id
    );

    -- Set OUT values
    x_gtp_rec := l_gtp_rec;
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
    p_gtpv_rec                     IN  gtpv_rec_type,
    x_gtpv_rec                     OUT NOCOPY gtpv_rec_type ) IS

    -- Local Variables within the function
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtpv_rec                     gtpv_rec_type;
    l_def_gtpv_rec                 gtpv_rec_type;
    l_gtp_rec                      gtp_rec_type;
    lx_gtp_rec                     gtp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_gtpv_rec	IN gtpv_rec_type
    ) RETURN gtpv_rec_type IS
      l_gtpv_rec	gtpv_rec_type := p_gtpv_rec;
    BEGIN
      l_gtpv_rec.CREATION_DATE := SYSDATE;
      l_gtpv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_gtpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_gtpv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_gtpv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_gtpv_rec);
    END fill_who_columns;

    -----------------------------------------------
    -- Set_Attributes for:OKL_ST_GEN_TEMPLATES_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_gtpv_rec IN  gtpv_rec_type,
      x_gtpv_rec OUT NOCOPY gtpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtpv_rec := p_gtpv_rec;
      x_gtpv_rec.OBJECT_VERSION_NUMBER := 1;
      x_gtpv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();

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

    l_gtpv_rec := null_out_defaults(p_gtpv_rec);

    -- Set primary key value
    l_gtpv_rec.ID := get_seq_id;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_gtpv_rec,                        -- IN
      l_def_gtpv_rec);                   -- OUT

    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- fill who columns for the l_def_gtpv_rec
    l_def_gtpv_rec := fill_who_columns(l_def_gtpv_rec);

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_gtpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    -- Perfrom all row level validations
    l_return_status := validate_record(l_def_gtpv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_gtpv_rec, l_gtp_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------

    insert_row (
       p_api_version => l_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data
      ,p_gtp_rec => l_gtp_rec
      ,x_gtp_rec => lx_gtp_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_gtp_rec, l_def_gtpv_rec);

    -- Set OUT values
    x_gtpv_rec := l_def_gtpv_rec;
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
  -- PL/SQL TBL insert_row for:GTLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtpv_tbl                     IN  gtpv_tbl_type,
    x_gtpv_tbl                     OUT NOCOPY gtpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status 		       VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);

    -- Making sure PL/SQL table has records in it before passing
    IF (p_gtpv_tbl.COUNT > 0) THEN
      i := p_gtpv_tbl.FIRST;
      LOOP

        insert_row (
          p_api_version                  => l_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gtpv_rec                     => p_gtpv_tbl(i),
          x_gtpv_rec                     => x_gtpv_tbl(i));

    	-- store the highest degree of error
    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
        EXIT WHEN (i = p_gtpv_tbl.LAST);
        i := p_gtpv_tbl.NEXT(i);
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
  --                   table OKL_ST_GEN_PRC_PARAMS
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
    p_gtp_rec                      IN  gtp_rec_type,
    x_gtp_rec                      OUT NOCOPY gtp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtp_rec                      gtp_rec_type := p_gtp_rec;
    l_def_gtp_rec                  gtp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_gtp_rec	IN  gtp_rec_type,
      x_gtp_rec	OUT NOCOPY gtp_rec_type
    ) RETURN VARCHAR2 IS
      l_gtp_rec                      gtp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtp_rec := p_gtp_rec;

      -- Get current database values
      l_gtp_rec := get_rec( p_gtp_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_gtp_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtp_rec.id := l_gtp_rec.id;
      END IF;
      IF (x_gtp_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_gtp_rec.object_version_number := l_gtp_rec.object_version_number;
      END IF;
      IF (x_gtp_rec.name = Okl_Api.G_MISS_CHAR) THEN
        x_gtp_rec.name := l_gtp_rec.name;
      END IF;
      IF (x_gtp_rec.description = Okl_Api.G_MISS_CHAR) THEN
        x_gtp_rec.description := l_gtp_rec.description;
      END IF;
            IF (x_gtp_rec.display_yn = Okl_Api.G_MISS_CHAR) THEN
        x_gtp_rec.display_yn := l_gtp_rec.display_yn;
      END IF;
            IF (x_gtp_rec.update_yn = Okl_Api.G_MISS_CHAR) THEN
        x_gtp_rec.update_yn := l_gtp_rec.update_yn;
      END IF;
      IF (x_gtp_rec.prc_eng_ident = Okl_Api.G_MISS_CHAR) THEN
        x_gtp_rec.prc_eng_ident := l_gtp_rec.prc_eng_ident;
      END IF;
      IF (x_gtp_rec.default_value = Okl_Api.G_MISS_CHAR) THEN
        x_gtp_rec.default_value := l_gtp_rec.default_value;
      END IF;
      IF (x_gtp_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtp_rec.org_id := l_gtp_rec.org_id;
      END IF;
      IF (x_gtp_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_gtp_rec.created_by := l_gtp_rec.created_by;
      END IF;
      IF (x_gtp_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_gtp_rec.creation_date := l_gtp_rec.creation_date;
      END IF;
      IF (x_gtp_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_gtp_rec.last_updated_by := l_gtp_rec.last_updated_by;
      END IF;
      IF (x_gtp_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_gtp_rec.last_update_date := l_gtp_rec.last_update_date;
      END IF;
      IF (x_gtp_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_gtp_rec.last_update_login := l_gtp_rec.last_update_login;
      END IF;
      IF (x_gtp_rec.gtt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtp_rec.gtt_id := l_gtp_rec.gtt_id;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_ST_GEN_PRC_PARAMS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_gtp_rec IN  gtp_rec_type,
      x_gtp_rec OUT NOCOPY gtp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtp_rec := p_gtp_rec;
      RETURN(l_return_status);
    END Set_Attributes;
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

    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_gtp_rec,                         -- IN
      l_gtp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_gtp_rec, l_def_gtp_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKL_ST_GEN_PRC_PARAMS
    SET ID                      = l_def_gtp_rec.id
        ,OBJECT_VERSION_NUMBER  = l_def_gtp_rec.object_version_number
        ,NAME                   = l_def_gtp_rec.name
        ,DESCRIPTION            = l_def_gtp_rec.description
        ,DISPLAY_YN             = l_def_gtp_rec.display_yn
        ,UPDATE_YN              = l_def_gtp_rec.update_yn
        ,PRC_ENG_IDENT          = l_def_gtp_rec.prc_eng_ident
        ,DEFAULT_VALUE          = l_def_gtp_rec.default_value
        ,ORG_ID                 = l_def_gtp_rec.org_id
        ,CREATED_BY             = l_def_gtp_rec.created_by
        ,CREATION_DATE          = l_def_gtp_rec.creation_date
        ,LAST_UPDATED_BY        = l_def_gtp_rec.last_updated_by
        ,LAST_UPDATE_DATE       = l_def_gtp_rec.last_update_date
        ,LAST_UPDATE_LOGIN      = l_def_gtp_rec.last_update_login
        ,GTT_ID                 = l_def_gtp_rec.gtt_id
    WHERE ID = l_def_gtp_rec.id;

    x_gtp_rec := l_def_gtp_rec;
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
  END update_row;


  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtpv_rec                     IN  gtpv_rec_type,
    x_gtpv_rec                     OUT NOCOPY gtpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtpv_rec                     gtpv_rec_type := p_gtpv_rec;
    l_def_gtpv_rec                 gtpv_rec_type;
    l_gtp_rec                      gtp_rec_type;
    lx_gtp_rec                     gtp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_gtpv_rec	IN gtpv_rec_type
    ) RETURN gtpv_rec_type IS
      l_gtpv_rec	gtpv_rec_type := p_gtpv_rec;
    BEGIN
      l_gtpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_gtpv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_gtpv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_gtpv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_gtpv_rec	IN  gtpv_rec_type,
      x_gtpv_rec	OUT NOCOPY gtpv_rec_type
    ) RETURN VARCHAR2 IS
      l_gtpv_rec                      gtpv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtpv_rec := p_gtpv_rec;
      -- Get current database values
      l_gtpv_rec := get_rec(p_gtpv_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;

      IF (x_gtpv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtpv_rec.id := l_gtp_rec.id;
      END IF;
      IF (x_gtpv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_gtpv_rec.object_version_number := l_gtpv_rec.object_version_number;
      END IF;
      IF (x_gtpv_rec.name = Okl_Api.G_MISS_CHAR) THEN
        x_gtpv_rec.name := l_gtpv_rec.name;
      END IF;
      IF (x_gtpv_rec.description = Okl_Api.G_MISS_CHAR) THEN
        x_gtpv_rec.description := l_gtpv_rec.description;
      END IF;
            IF (x_gtpv_rec.display_yn = Okl_Api.G_MISS_CHAR) THEN
        x_gtpv_rec.display_yn := l_gtpv_rec.display_yn;
      END IF;
            IF (x_gtpv_rec.update_yn = Okl_Api.G_MISS_CHAR) THEN
        x_gtpv_rec.update_yn := l_gtpv_rec.update_yn;
      END IF;
      IF (x_gtpv_rec.prc_eng_ident = Okl_Api.G_MISS_CHAR) THEN
        x_gtpv_rec.prc_eng_ident := l_gtpv_rec.prc_eng_ident;
      END IF;
      IF (x_gtpv_rec.default_value = Okl_Api.G_MISS_CHAR) THEN
        x_gtpv_rec.default_value := l_gtpv_rec.default_value;
      END IF;

      IF (x_gtpv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtpv_rec.org_id := l_gtpv_rec.org_id;
      END IF;
      IF (x_gtpv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_gtpv_rec.created_by := l_gtpv_rec.created_by;
      END IF;
      IF (x_gtpv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_gtpv_rec.creation_date := l_gtpv_rec.creation_date;
      END IF;
      IF (x_gtpv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_gtpv_rec.last_updated_by := l_gtpv_rec.last_updated_by;
      END IF;
      IF (x_gtpv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_gtpv_rec.last_update_date := l_gtpv_rec.last_update_date;
      END IF;
      IF (x_gtpv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_gtpv_rec.last_update_login := l_gtpv_rec.last_update_login;
      END IF;
      IF (x_gtpv_rec.gtt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtpv_rec.gtt_id := l_gtpv_rec.gtt_id;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for: OKL_ST_GEN_PRC_PARAMS_v --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_gtpv_rec IN  gtpv_rec_type,
      x_gtpv_rec OUT NOCOPY gtpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtpv_rec := p_gtpv_rec;
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
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_gtpv_rec,                        -- IN
      l_gtpv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_gtpv_rec, l_def_gtpv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_gtpv_rec := fill_who_columns(l_def_gtpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_gtpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_gtpv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_gtpv_rec, l_gtp_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_gtp_rec => l_gtp_rec,
      x_gtp_rec => lx_gtp_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_gtp_rec, l_def_gtpv_rec);

    x_gtpv_rec := l_def_gtpv_rec;
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
  END;

  -------------------------------------------------------
  -- PL/SQL TBL update_row for:OKL_ST_GEN_PRC_PARAMS_V --
  -------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtpv_tbl                     IN  gtpv_tbl_type,
    x_gtpv_tbl                     OUT NOCOPY gtpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    l_overall_status 		  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_gtpv_tbl.COUNT > 0) THEN
      i := p_gtpv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => l_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gtpv_rec                     => p_gtpv_tbl(i),
          x_gtpv_rec                     => x_gtpv_tbl(i));

    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;

        EXIT WHEN (i = p_gtpv_tbl.LAST);
        i := p_gtpv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKL_ST_GEN_PRC_PARAMS --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtp_rec                      IN  gtp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtp_rec                      gtp_rec_type:= p_gtp_rec;
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
    DELETE FROM OKL_ST_GEN_PRC_PARAMS
     WHERE ID = l_gtp_rec.id;

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

  --------------------------------------------
  -- delete_row for:OKL_ST_GEN_PRC_PARAMS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtpv_rec                     IN  gtpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtpv_rec                     gtpv_rec_type := p_gtpv_rec;
    l_gtp_rec                      gtp_rec_type;
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
    migrate(l_gtpv_rec, l_gtp_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_gtp_rec => l_gtp_rec
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



  --------------------------------------------------------
  -- PL/SQL TBL delete_row for: OKL_ST_GEN_PRC_PARAMS_V --
  --------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtpv_tbl                     IN  gtpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status 		  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing
    IF (p_gtpv_tbl.COUNT > 0) THEN
      i := p_gtpv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => l_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gtpv_rec                     => p_gtpv_tbl(i));

    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;

        EXIT WHEN (i = p_gtpv_tbl.LAST);
        i := p_gtpv_tbl.NEXT(i);
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


END okl_gtp_pvt;

/
