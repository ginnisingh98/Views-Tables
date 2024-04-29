--------------------------------------------------------
--  DDL for Package Body OKL_GTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GTL_PVT" AS
/* $Header: OKLSGTLB.pls 120.4 2006/07/13 12:55:53 adagur noship $ */

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
  END get_seq_id;


 ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ST_GEN_TMPT_LNS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_gtl_rec                      IN  gtl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN gtl_rec_type IS
    CURSOR okl_st_gen_tmpt_lns_pk_csr (p_id IN NUMBER) IS
    SELECT  ID
            ,OBJECT_VERSION_NUMBER
            ,GTT_ID
            ,PRIMARY_YN
            ,PRIMARY_STY_ID
            ,DEPENDENT_STY_ID
            ,PRICING_NAME
            ,ORG_ID
            ,CREATED_BY
            ,CREATION_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATE_LOGIN
    FROM OKL_ST_GEN_TMPT_LNS
    WHERE OKL_ST_GEN_TMPT_LNS.id = p_id;

    l_okl_st_gen_tmpt_lns_pk   okl_st_gen_tmpt_lns_pk_csr%ROWTYPE;
    l_gtl_rec                  gtl_rec_type;
  BEGIN
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_st_gen_tmpt_lns_pk_csr (p_gtl_rec.id);

    FETCH okl_st_gen_tmpt_lns_pk_csr INTO
        l_gtl_rec.id
        ,l_gtl_rec.object_version_number
        ,l_gtl_rec.gtt_id
        ,l_gtl_rec.primary_yn
        ,l_gtl_rec.primary_sty_id
        ,l_gtl_rec.dependent_sty_id
        ,l_gtl_rec.pricing_name
        ,l_gtl_rec.org_id
        ,l_gtl_rec.created_by
        ,l_gtl_rec.creation_date
        ,l_gtl_rec.last_updated_by
        ,l_gtl_rec.last_update_date
        ,l_gtl_rec.last_update_login;

    x_no_data_found := okl_st_gen_tmpt_lns_pk_csr%NOTFOUND;
    CLOSE okl_st_gen_tmpt_lns_pk_csr;

    RETURN(l_gtl_rec);

  END get_rec;

  FUNCTION get_rec (
    p_gtl_rec                      IN gtl_rec_type
  ) RETURN gtl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_gtl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ST_GEN_TMPT_LNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_gtlv_rec                     IN  gtlv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN gtlv_rec_type IS
    CURSOR okl_gtlv_pk_csr (p_id                 IN NUMBER) IS
    SELECT   ID
            ,OBJECT_VERSION_NUMBER
            ,GTT_ID
            ,PRIMARY_YN
            ,PRIMARY_STY_ID
            ,DEPENDENT_STY_ID
            ,PRICING_NAME
            ,ORG_ID
            ,CREATED_BY
            ,CREATION_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATE_LOGIN
    FROM OKL_ST_GEN_TMPT_LNS
    WHERE OKL_ST_GEN_TMPT_LNS.ID = p_id;

    l_okl_gtlv_pk                  okl_gtlv_pk_csr%ROWTYPE;
    l_gtlv_rec                     gtlv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_gtlv_pk_csr (p_gtlv_rec.id);
    FETCH okl_gtlv_pk_csr INTO
        l_gtlv_rec.id
        ,l_gtlv_rec.object_version_number
        ,l_gtlv_rec.gtt_id
        ,l_gtlv_rec.primary_yn
        ,l_gtlv_rec.primary_sty_id
        ,l_gtlv_rec.dependent_sty_id
        ,l_gtlv_rec.pricing_name
        ,l_gtlv_rec.org_id
        ,l_gtlv_rec.created_by
        ,l_gtlv_rec.creation_date
        ,l_gtlv_rec.last_updated_by
        ,l_gtlv_rec.last_update_date
        ,l_gtlv_rec.last_update_login;

        x_no_data_found := okl_gtlv_pk_csr%NOTFOUND;
    CLOSE okl_gtlv_pk_csr;
    RETURN(l_gtlv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_gtlv_rec                     IN gtlv_rec_type
  ) RETURN gtlv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_gtlv_rec, l_row_notfound));
  END get_rec;

 ----------------------------------------------
  -- validate_record for: OKL_ST_GEN_TMPT_LNS_V --
  ----------------------------------------------
  FUNCTION validate_record (
    p_gtlv_rec IN gtlv_rec_type
  ) RETURN VARCHAR2 IS
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_gtt_id      OKL_ST_GEN_TMPT_LNS.GTT_ID%TYPE;
  l_gtlv_rec    gtlv_rec_type := p_gtlv_rec;

  -- Modified by RGOOTY:
  -- Bug 4054596: Issue No. 3: Start
  CURSOR gtl_pri_dup_csr( p_id     OKL_ST_GEN_TMPT_LNS.ID%TYPE
                         ,p_gtt_id OKL_ST_GEN_TMPT_LNS.GTT_ID%TYPE
                         ,p_pri_sty_id OKL_ST_GEN_TMPT_LNS.PRIMARY_STY_ID%TYPE) IS
    SELECT NAME stream_name
    FROM OKL_STRM_TYPE_V
    WHERE ID IN
    (
        SELECT primary_Sty_id
        FROM OKL_ST_GEN_TMPT_LNS GTL
        WHERE GTL.GTT_ID  = p_gtt_id
        AND  GTL.PRIMARY_YN = 'Y'
        AND  GTL.PRIMARY_STY_ID = p_pri_sty_id
        AND  GTL.ID <> p_id
    );

    CURSOR gtl_dep_dup_csr( p_id     OKL_ST_GEN_TMPT_LNS.ID%TYPE
                           ,p_gtt_id OKL_ST_GEN_TMPT_LNS.GTT_ID%TYPE
                           ,p_pri_sty_id OKL_ST_GEN_TMPT_LNS.PRIMARY_STY_ID%TYPE
                           ,p_dep_sty_id OKL_ST_GEN_TMPT_LNS.DEPENDENT_STY_ID%TYPE) IS
    SELECT NAME stream_name
    FROM OKL_STRM_TYPE_V
    WHERE ID IN
    (
        SELECT dependent_sty_id
        FROM OKL_ST_GEN_TMPT_LNS GTL
        WHERE GTL.GTT_ID  = p_gtt_id
        AND  GTL.PRIMARY_YN = 'N'
        AND  GTL.PRIMARY_STY_ID = p_pri_sty_id
        AND  GTL.DEPENDENT_STY_ID = p_dep_sty_id
        AND  GTL.ID <> p_id
    );


  l_found VARCHAR2(1);
  l_strm_name OKL_STRM_TYPE_V.NAME%TYPE;
  BEGIN
    -- Get the gtt_id
    IF( l_gtlv_rec.primary_yn = 'Y' )
    THEN
        -- Check whether the Stream already exists as a Primary Stream Type
        -- or not !
        l_found := Okl_Api.G_FALSE;
        FOR gtl_pri_dup_rec IN gtl_pri_dup_csr(  l_gtlv_rec.id
                                                ,l_gtlv_rec.gtt_id
                                                ,l_gtlv_rec.primary_sty_id )
        LOOP
            l_found := Okl_Api.G_TRUE;
            l_strm_name := gtl_pri_dup_rec.stream_name;
        END LOOP;
        IF (l_found = Okl_Api.G_TRUE) THEN
            Okl_Api.SET_MESSAGE(   p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_ST_SGT_DUP_PRI_STRM',
                                p_token1       => g_col_name_token,
                                p_token1_value => l_strm_name);
            l_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;
    ELSIF( l_gtlv_rec.primary_yn = 'N' )
    THEN
        -- Check whether the Stream already exists as a Dependent Stream Type
        -- or not !
        l_found := Okl_Api.G_FALSE;
        FOR gtl_dep_dup_rec IN gtl_dep_dup_csr( l_gtlv_rec.id
                                               ,l_gtlv_rec.gtt_id
                                               ,l_gtlv_rec.primary_sty_id
                                               ,l_gtlv_rec.dependent_sty_id)
        LOOP
            l_found := Okl_Api.G_TRUE;
            l_strm_name := gtl_dep_dup_rec.stream_name;
        END LOOP;
        IF (l_found = Okl_Api.G_TRUE) THEN
            Okl_Api.SET_MESSAGE(   p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_ST_SGT_DUP_DEP_STRM',
                                p_token1       => g_col_name_token,
                                p_token1_value => l_strm_name);
            l_return_status := Okl_Api.G_RET_STS_ERROR;

        END IF;
    END IF;
    -- Bug 4054596: Issue No. 3: End
    RETURN (l_return_status);
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
    p_gtlv_rec      IN   gtlv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_gtlv_rec.id = Okl_Api.G_MISS_NUM OR
       p_gtlv_rec.id IS NULL
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
    p_gtlv_rec      IN   gtlv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_gtlv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_gtlv_rec.object_version_number IS NULL
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

  PROCEDURE validate_gtt_id (p_gtlv_rec      IN   gtlv_rec_type
                ,x_return_status OUT NOCOPY  VARCHAR2 )
  IS

  l_dummy         VARCHAR2(1)  := Okl_Api.G_FALSE;

  CURSOR gtt_csr(p_gtt_id NUMBER) IS
  SELECT '1'
  FROM OKL_ST_GEN_TEMPLATES
  WHERE OKL_ST_GEN_TEMPLATES.ID  = p_gtt_id;


  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF (p_gtlv_rec.gtt_id  IS NOT NULL) AND (p_gtlv_rec.gtt_id <> Okl_Api.G_MISS_NUM) THEN
       OPEN gtt_csr(p_gtlv_rec.gtt_id);
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

   PROCEDURE Validate_primary_yn(
    p_gtlv_rec      IN   gtlv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF ( (  p_gtlv_rec.primary_yn <> Okl_Api.G_MISS_CHAR AND
            p_gtlv_rec.primary_yn IS NOT NULL ) AND
         ( NOT p_gtlv_rec.primary_yn  IN ( 'Y', 'N' ) ) )
    THEN
      Okl_Api.set_message(G_APP_NAME, G_INVALID_VALUE ,G_COL_NAME_TOKEN,'PRIMARY_YN');
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

  END Validate_primary_yn;
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
    p_gtlv_rec IN  gtlv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
    -- Validate_Id
    Validate_Id(p_gtlv_rec, x_return_status);
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
    validate_object_version_number(p_gtlv_rec, x_return_status);
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
    validate_gtt_id(p_gtlv_rec, x_return_status);
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
    p_gtlv_rec	IN gtlv_rec_type
  ) RETURN gtlv_rec_type IS
    l_gtlv_rec	gtlv_rec_type := p_gtlv_rec;
  BEGIN
    IF (l_gtlv_rec.id = Okl_Api.G_MISS_NUM) THEN
        l_gtlv_rec.id := NULL;
    END IF;
    IF (l_gtlv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
        l_gtlv_rec.object_version_number := NULL;
    END IF;
    IF (l_gtlv_rec.gtt_id = Okl_Api.G_MISS_NUM) THEN
        l_gtlv_rec.gtt_id := NULL;
    END IF;
    IF (l_gtlv_rec.primary_yn = Okl_Api.G_MISS_CHAR) THEN
        l_gtlv_rec.primary_yn := NULL;
    END IF;
    IF (l_gtlv_rec.primary_sty_id = Okl_Api.G_MISS_NUM) THEN
        l_gtlv_rec.primary_sty_id := NULL;
    END IF;
    IF (l_gtlv_rec.dependent_sty_id = Okl_Api.G_MISS_NUM) THEN
        l_gtlv_rec.dependent_sty_id:= NULL;
    END IF;
    IF (l_gtlv_rec.pricing_name= Okl_Api.G_MISS_CHAR) THEN
        l_gtlv_rec.pricing_name:= NULL;
    END IF;
    IF (l_gtlv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_gtlv_rec.org_id := NULL;
    END IF;
    IF (l_gtlv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_gtlv_rec.created_by := NULL;
    END IF;
    IF (l_gtlv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_gtlv_rec.creation_date := NULL;
    END IF;
    IF (l_gtlv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_gtlv_rec.last_updated_by := NULL;
    END IF;
    IF (l_gtlv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_gtlv_rec.last_update_date := NULL;
    END IF;
    IF (l_gtlv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_gtlv_rec.last_update_login := NULL;
    END IF;

    RETURN(l_gtlv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN gtl_rec_type,
    p_to	IN OUT NOCOPY gtlv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.gtt_id := p_from.gtt_id;
    p_to.primary_yn := p_from.primary_yn;
    p_to.primary_sty_id := p_from.primary_sty_id;
    p_to.dependent_sty_id := p_from.dependent_sty_id;
    p_to.pricing_name := p_from.pricing_name;
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
    p_from	IN gtlv_rec_type,
    p_to	IN OUT NOCOPY gtl_rec_type
  ) IS
  BEGIN
  p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.gtt_id := p_from.gtt_id;
    p_to.primary_yn := p_from.primary_yn;
    p_to.primary_sty_id := p_from.primary_sty_id;
    p_to.dependent_sty_id := p_from.dependent_sty_id;
    p_to.pricing_name := p_from.pricing_name;
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
  --                   table OKL_ST_GEN_TMPT_LNS
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
    p_gtl_rec                      IN gtl_rec_type,
    x_gtl_rec                      OUT NOCOPY gtl_rec_type ) AS

    -- Local Variables within the function
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtl_rec                     gtl_rec_type := p_gtl_rec;
    l_def_gtl_rec                 gtl_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_ST_GEN_TMPT_LNS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_gtl_rec IN  gtl_rec_type,
      x_gtl_rec OUT NOCOPY gtl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtl_rec := p_gtl_rec;
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
      p_gtl_rec,    -- IN
      l_gtl_rec     -- OUT
    );
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_ST_GEN_TMPT_LNS(
        ID
        ,OBJECT_VERSION_NUMBER
        ,GTT_ID
        ,PRIMARY_YN
        ,PRIMARY_STY_ID
        ,DEPENDENT_STY_ID
        ,PRICING_NAME
        ,ORG_ID
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        )
    VALUES (
         l_gtl_rec.id
        ,l_gtl_rec.object_version_number
        ,l_gtl_rec.gtt_id
        ,l_gtl_rec.primary_yn
        ,l_gtl_rec.primary_sty_id
        ,l_gtl_rec.dependent_sty_id
        ,l_gtl_rec.pricing_name
        ,l_gtl_rec.org_id
        ,l_gtl_rec.created_by
        ,l_gtl_rec.creation_date
        ,l_gtl_rec.last_updated_by
        ,l_gtl_rec.last_update_date
        ,l_gtl_rec.last_update_login
    );

    -- Set OUT values
    x_gtl_rec := l_gtl_rec;
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
    p_gtlv_rec                     IN  gtlv_rec_type,
    x_gtlv_rec                     OUT NOCOPY gtlv_rec_type ) IS

    -- Local Variables within the function
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtlv_rec                     gtlv_rec_type;
    l_def_gtlv_rec                 gtlv_rec_type;
    l_gtl_rec                      gtl_rec_type;
    lx_gtl_rec                     gtl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_gtlv_rec	IN gtlv_rec_type
    ) RETURN gtlv_rec_type IS
      l_gtlv_rec	gtlv_rec_type := p_gtlv_rec;
    BEGIN
      l_gtlv_rec.CREATION_DATE := SYSDATE;
      l_gtlv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_gtlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_gtlv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_gtlv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_gtlv_rec);
    END fill_who_columns;

    -----------------------------------------------
    -- Set_Attributes for:OKL_ST_GEN_TMPT_LNS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_gtlv_rec IN  gtlv_rec_type,
      x_gtlv_rec OUT NOCOPY gtlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtlv_rec := p_gtlv_rec;
      x_gtlv_rec.OBJECT_VERSION_NUMBER := 1;
      x_gtlv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();

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

    l_gtlv_rec := null_out_defaults(p_gtlv_rec);

    -- Set primary key value
    l_gtlv_rec.ID := get_seq_id;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_gtlv_rec,                        -- IN
      l_def_gtlv_rec);                   -- OUT

    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- fill who columns for the l_def_gtlv_rec
    l_def_gtlv_rec := fill_who_columns(l_def_gtlv_rec);

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_gtlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Perfrom all row level validations
    l_return_status := validate_record(l_def_gtlv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_gtlv_rec, l_gtl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------

    insert_row (
       p_api_version => l_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data
      ,p_gtl_rec => l_gtl_rec
      ,x_gtl_rec => lx_gtl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_gtl_rec, l_def_gtlv_rec);

    -- Set OUT values
    x_gtlv_rec := l_def_gtlv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      -- Modified by RGOOTY
      -- Bug 4054596: Issue No. 5: Start
      x_return_status := l_return_status;
      /*x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      ); */
      -- Bug 4054596: Issue No. 5: End
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
    p_gtlv_tbl                     IN  gtlv_tbl_type,
    x_gtlv_tbl                     OUT NOCOPY gtlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status 		       VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);

    -- Making sure PL/SQL table has records in it before passing
    IF (p_gtlv_tbl.COUNT > 0) THEN
      i := p_gtlv_tbl.FIRST;
      LOOP

        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list, -- Bug 4054596: Issue No. 3
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gtlv_rec                     => p_gtlv_tbl(i),
          x_gtlv_rec                     => x_gtlv_tbl(i));

    	-- store the highest degree of error
    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
        EXIT WHEN (i = p_gtlv_tbl.LAST);
        i := p_gtlv_tbl.NEXT(i);
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
    p_gtl_rec                      IN  gtl_rec_type,
    x_gtl_rec                      OUT NOCOPY gtl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtl_rec                      gtl_rec_type := p_gtl_rec;
    l_def_gtl_rec                  gtl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_gtl_rec	IN  gtl_rec_type,
      x_gtl_rec	OUT NOCOPY gtl_rec_type
    ) RETURN VARCHAR2 IS
      l_gtl_rec                      gtl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtl_rec := p_gtl_rec;

      -- Get current database values
      l_gtl_rec := get_rec( p_gtl_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_gtl_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtl_rec.id := l_gtl_rec.id;
      END IF;
      IF (x_gtl_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_gtl_rec.object_version_number := l_gtl_rec.object_version_number;
      END IF;
      IF (x_gtl_rec.gtt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtl_rec.gtt_id := l_gtl_rec.gtt_id;
      END IF;
      IF ( x_gtl_rec.primary_yn = Okl_Api.G_MISS_CHAR ) THEN
        x_gtl_rec.primary_yn := l_gtl_rec.primary_yn;
      END IF;
      IF ( x_gtl_rec.primary_sty_id = Okl_Api.G_MISS_NUM ) THEN
        x_gtl_rec.primary_sty_id := l_gtl_rec.primary_sty_id;
      END IF;
      IF ( x_gtl_rec.dependent_sty_id = Okl_Api.G_MISS_NUM ) THEN
        x_gtl_rec.dependent_sty_id := l_gtl_rec.dependent_sty_id;
      END IF;
      IF ( x_gtl_rec.pricing_name = Okl_Api.G_MISS_CHAR ) THEN
        x_gtl_rec.pricing_name := l_gtl_rec.pricing_name;
      END IF;
      IF (x_gtl_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtl_rec.org_id := l_gtl_rec.org_id;
      END IF;
      IF (x_gtl_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_gtl_rec.created_by := l_gtl_rec.created_by;
      END IF;
      IF (x_gtl_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_gtl_rec.creation_date := l_gtl_rec.creation_date;
      END IF;
      IF (x_gtl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_gtl_rec.last_updated_by := l_gtl_rec.last_updated_by;
      END IF;
      IF (x_gtl_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_gtl_rec.last_update_date := l_gtl_rec.last_update_date;
      END IF;
      IF (x_gtl_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_gtl_rec.last_update_login := l_gtl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_ST_GEN_TEMPLATES --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_gtl_rec IN  gtl_rec_type,
      x_gtl_rec OUT NOCOPY gtl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtl_rec := p_gtl_rec;
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
      p_gtl_rec,                         -- IN
      l_gtl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_gtl_rec, l_def_gtl_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKL_ST_GEN_TMPT_LNS
    SET ID                     = l_def_gtl_rec.id
        ,OBJECT_VERSION_NUMBER  = l_def_gtl_rec.object_version_number
        ,GTT_ID                 = l_def_gtl_rec.gtt_id
        ,PRIMARY_YN             = l_def_gtl_rec.primary_yn
        ,PRIMARY_STY_ID         = l_def_gtl_rec.primary_sty_id
        ,DEPENDENT_STY_ID       = l_def_gtl_rec.dependent_sty_id
        ,PRICING_NAME           = l_def_gtl_rec.pricing_name
        ,ORG_ID                 = l_def_gtl_rec.org_id
        ,CREATED_BY             = l_def_gtl_rec.created_by
        ,CREATION_DATE          = l_def_gtl_rec.creation_date
        ,LAST_UPDATED_BY        = l_def_gtl_rec.last_updated_by
        ,LAST_UPDATE_DATE       = l_def_gtl_rec.last_update_date
        ,LAST_UPDATE_LOGIN      = l_def_gtl_rec.last_update_login
    WHERE ID = l_def_gtl_rec.id;

    x_gtl_rec := l_def_gtl_rec;
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
    p_gtlv_rec                     IN  gtlv_rec_type,
    x_gtlv_rec                     OUT NOCOPY gtlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtlv_rec                     gtlv_rec_type := p_gtlv_rec;
    l_def_gtlv_rec                 gtlv_rec_type;
    l_gtl_rec                      gtl_rec_type;
    lx_gtl_rec                     gtl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_gtlv_rec	IN gtlv_rec_type
    ) RETURN gtlv_rec_type IS
      l_gtlv_rec	gtlv_rec_type := p_gtlv_rec;
    BEGIN
      l_gtlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_gtlv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_gtlv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_gtlv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_gtlv_rec	IN  gtlv_rec_type,
      x_gtlv_rec	OUT NOCOPY gtlv_rec_type
    ) RETURN VARCHAR2 IS
      l_gtlv_rec                      gtlv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtlv_rec := p_gtlv_rec;

      -- Get current database values
      l_gtlv_rec := get_rec(p_gtlv_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_gtlv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtlv_rec.id := l_gtl_rec.id;
      END IF;
      IF (x_gtlv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_gtlv_rec.object_version_number := l_gtlv_rec.object_version_number;
      END IF;
      IF (x_gtlv_rec.gtt_id = Okl_Api.G_MISS_NUM) THEN
         x_gtlv_rec.gtt_id := l_gtlv_rec.gtt_id;
      END IF;
      IF (x_gtlv_rec.primary_yn = Okl_Api.G_MISS_CHAR) THEN
        x_gtlv_rec.primary_yn := l_gtlv_rec.primary_yn;
      END IF;
      IF (x_gtlv_rec.primary_sty_id = Okl_Api.G_MISS_NUM) THEN
        x_gtlv_rec.primary_sty_id := l_gtlv_rec.primary_sty_id;
      END IF;
      IF (x_gtlv_rec.dependent_sty_id = Okl_Api.G_MISS_NUM) THEN
        x_gtlv_rec.dependent_sty_id := l_gtlv_rec.dependent_sty_id;
      END IF;
      IF (x_gtlv_rec.pricing_name = Okl_Api.G_MISS_CHAR) THEN
        x_gtlv_rec.pricing_name := l_gtlv_rec.pricing_name;
      END IF;
      IF (x_gtlv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_gtlv_rec.org_id := l_gtlv_rec.org_id;
      END IF;
      IF (x_gtlv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_gtlv_rec.created_by := l_gtlv_rec.created_by;
      END IF;
      IF (x_gtlv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_gtlv_rec.creation_date := l_gtlv_rec.creation_date;
      END IF;
      IF (x_gtlv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_gtlv_rec.last_updated_by := l_gtlv_rec.last_updated_by;
      END IF;
      IF (x_gtlv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_gtlv_rec.last_update_date := l_gtlv_rec.last_update_date;
      END IF;
      IF (x_gtlv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_gtlv_rec.last_update_login := l_gtlv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for: OKL_ST_GEN_TEMPLATES --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_gtlv_rec IN  gtlv_rec_type,
      x_gtlv_rec OUT NOCOPY gtlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_gtlv_rec := p_gtlv_rec;
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
      p_gtlv_rec,                        -- IN
      l_gtlv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_gtlv_rec, l_def_gtlv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_gtlv_rec := fill_who_columns(l_def_gtlv_rec);

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_gtlv_rec);

    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_gtlv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_gtlv_rec, l_gtl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_gtl_rec => l_gtl_rec,
      x_gtl_rec => lx_gtl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_gtl_rec, l_def_gtlv_rec);

    x_gtlv_rec := l_def_gtlv_rec;
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

  ----------------------------------------------------
  -- PL/SQL TBL update_row for:OKL_ST_GEN_TEMPLATES --
  ----------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtlv_tbl                     IN  gtlv_tbl_type,
    x_gtlv_tbl                     OUT NOCOPY gtlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    l_overall_status 		  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_gtlv_tbl.COUNT > 0) THEN
      i := p_gtlv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list, -- Bug 4054596: Issue No. 3
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gtlv_rec                     => p_gtlv_tbl(i),
          x_gtlv_rec                     => x_gtlv_tbl(i));

    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;

        EXIT WHEN (i = p_gtlv_tbl.LAST);
        i := p_gtlv_tbl.NEXT(i);
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
  -- delete_row for:OKL_ST_GEN_TMPT_LNS --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtl_rec                      IN  gtl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtl_rec                      gtl_rec_type:= p_gtl_rec;
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
    DELETE FROM OKL_ST_GEN_TMPT_LNS
     WHERE ID = l_gtl_rec.id;

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
  -- delete_row for:OKL_ST_GEN_TMPT_LNS --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtlv_rec                     IN  gtlv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_gtlv_rec                     gtlv_rec_type := p_gtlv_rec;
    l_gtl_rec                      gtl_rec_type;
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
    migrate(l_gtlv_rec, l_gtl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_gtl_rec => l_gtl_rec
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
  -- PL/SQL TBL delete_row for:OKL_ST_GEN_TMPT_LNS --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtlv_tbl                     IN  gtlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status 		  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing
    IF (p_gtlv_tbl.COUNT > 0) THEN
      i := p_gtlv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gtlv_rec                     => p_gtlv_tbl(i));

    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;

        EXIT WHEN (i = p_gtlv_tbl.LAST);
        i := p_gtlv_tbl.NEXT(i);
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
END okl_gtl_pvt;

/
