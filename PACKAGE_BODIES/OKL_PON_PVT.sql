--------------------------------------------------------
--  DDL for Package Body OKL_PON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PON_PVT" AS
/* $Header: OKLSPONB.pls 115.8 2002/12/18 13:03:54 kjinger noship $ */
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
  -- FUNCTION get_rec for: OKL_PDT_OPTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pon_rec                      IN pon_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pon_rec_type IS
    CURSOR okl_pdt_opts_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OPT_ID,
            PDT_ID,
            OPTIONAL_YN,
            OBJECT_VERSION_NUMBER,
            FROM_DATE,
            TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Pdt_Opts
     WHERE okl_pdt_opts.id      = p_id;
    l_okl_pdt_opts_pk              okl_pdt_opts_pk_csr%ROWTYPE;
    l_pon_rec                      pon_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pdt_opts_pk_csr (p_pon_rec.id);
    FETCH okl_pdt_opts_pk_csr INTO
              l_pon_rec.ID,
              l_pon_rec.OPT_ID,
              l_pon_rec.PDT_ID,
              l_pon_rec.OPTIONAL_YN,
              l_pon_rec.OBJECT_VERSION_NUMBER,
              l_pon_rec.FROM_DATE,
              l_pon_rec.TO_DATE,
              l_pon_rec.CREATED_BY,
              l_pon_rec.CREATION_DATE,
              l_pon_rec.LAST_UPDATED_BY,
              l_pon_rec.LAST_UPDATE_DATE,
              l_pon_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pdt_opts_pk_csr%NOTFOUND;
    CLOSE okl_pdt_opts_pk_csr;
    RETURN(l_pon_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pon_rec                      IN pon_rec_type
  ) RETURN pon_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pon_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PDT_OPTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ponv_rec                     IN ponv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ponv_rec_type IS
    CURSOR okl_ponv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            OPT_ID,
            PDT_ID,
            FROM_DATE,
            TO_DATE,
            OPTIONAL_YN,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Pdt_Opts_V
     WHERE okl_pdt_opts_v.id    = p_id;
    l_okl_ponv_pk                  okl_ponv_pk_csr%ROWTYPE;
    l_ponv_rec                     ponv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ponv_pk_csr (p_ponv_rec.id);
    FETCH okl_ponv_pk_csr INTO
              l_ponv_rec.ID,
              l_ponv_rec.OBJECT_VERSION_NUMBER,
              l_ponv_rec.OPT_ID,
              l_ponv_rec.PDT_ID,
              l_ponv_rec.FROM_DATE,
              l_ponv_rec.TO_DATE,
              l_ponv_rec.OPTIONAL_YN,
              l_ponv_rec.CREATED_BY,
              l_ponv_rec.CREATION_DATE,
              l_ponv_rec.LAST_UPDATED_BY,
              l_ponv_rec.LAST_UPDATE_DATE,
              l_ponv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ponv_pk_csr%NOTFOUND;
    CLOSE okl_ponv_pk_csr;
    RETURN(l_ponv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ponv_rec                     IN ponv_rec_type
  ) RETURN ponv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ponv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_PDT_OPTS_V --
  ----------------------------------------------------
  FUNCTION null_out_defaults (
    p_ponv_rec	IN ponv_rec_type
  ) RETURN ponv_rec_type IS
    l_ponv_rec	ponv_rec_type := p_ponv_rec;
  BEGIN
    IF (l_ponv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_ponv_rec.object_version_number := NULL;
    END IF;
    IF (l_ponv_rec.opt_id = OKC_API.G_MISS_NUM) THEN
      l_ponv_rec.opt_id := NULL;
    END IF;
    IF (l_ponv_rec.pdt_id = OKC_API.G_MISS_NUM) THEN
      l_ponv_rec.pdt_id := NULL;
    END IF;
    IF (l_ponv_rec.from_date = OKC_API.G_MISS_DATE) THEN
      l_ponv_rec.from_date := NULL;
    END IF;
    IF (l_ponv_rec.to_date = OKC_API.G_MISS_DATE) THEN
      l_ponv_rec.to_date := NULL;
    END IF;
    IF (l_ponv_rec.optional_yn = OKC_API.G_MISS_CHAR) THEN
      l_ponv_rec.optional_yn := NULL;
    END IF;
    IF (l_ponv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_ponv_rec.created_by := NULL;
    END IF;
    IF (l_ponv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_ponv_rec.creation_date := NULL;
    END IF;
    IF (l_ponv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_ponv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ponv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_ponv_rec.last_update_date := NULL;
    END IF;
    IF (l_ponv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_ponv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ponv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKL_PDT_OPTS_V --
  --------------------------------------------
----------------TCHGS NEW CHANGS BEGIN --------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Id (
    p_ponv_rec IN  ponv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_ponv_rec.id = OKC_API.G_MISS_NUM OR
       p_ponv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name       =>G_APP_NAME,
                               p_msg_name       =>G_UNEXPECTED_ERROR,
                               p_token1         =>G_SQL_SQLCODE_TOKEN,
                               p_token1_value   =>sqlcode,
                               p_token2         =>G_SQL_SQLERRM_TOKEN,
                               p_token2_value   =>sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;
-----end of Validate_Id------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Object_Version_Number (
    p_ponv_rec IN  ponv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_ponv_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_ponv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;
------end of Validate_Object_Version_Number-----------------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Opt_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Opt_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Opt_Id (
    p_ponv_rec IN  ponv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    CURSOR okl_pdt_opts_foreign1 (p_foreign  OKL_PDT_OPTS.OPT_ID%TYPE) IS
    SELECT ID
       FROM OKL_OPTIONS_V
      WHERE OKL_OPTIONS_V.ID =  p_foreign;

    l_foreign_key                   OKL_PDT_OPTS_V.OPT_ID%TYPE;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_ponv_rec.opt_id = OKC_API.G_MISS_NUM OR
       p_ponv_rec.opt_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'opt_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    IF p_ponv_rec.opt_id IS NOT NULL THEN
    OPEN okl_pdt_opts_foreign1 (p_ponv_rec.opt_id);
    FETCH okl_pdt_opts_foreign1 INTO l_foreign_key;
    IF okl_pdt_opts_foreign1%NOTFOUND THEN
         OKC_API.set_message(G_APP_NAME, G_INVALID_KEY,G_COL_NAME_TOKEN,'opt_id');
         x_return_status := OKC_API.G_RET_STS_ERROR;

      ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
    END IF;
    CLOSE okl_pdt_opts_foreign1;
	END IF;

  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Opt_Id;
------end of Validate_Opt_Id-----------------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Pdt_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Pdt_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Pdt_Id (
    p_ponv_rec IN  ponv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    CURSOR okl_pdt_opts_foreign2 (p_foreign  OKL_PDT_OPTS.PDT_ID%TYPE) IS
    SELECT ID
       FROM OKL_PRODUCTS_V
      WHERE OKL_PRODUCTS_V.ID =  p_foreign;

    l_foreign_key                   OKL_PDT_OPTS_V.PDT_ID%TYPE;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_ponv_rec.pdt_id = OKC_API.G_MISS_NUM OR
       p_ponv_rec.pdt_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pdt_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

	IF p_ponv_rec.pdt_id IS NOT NULL THEN
    OPEN okl_pdt_opts_foreign2 (p_ponv_rec.pdt_id);
    FETCH okl_pdt_opts_foreign2 INTO l_foreign_key;
    IF okl_pdt_opts_foreign2%NOTFOUND THEN
         OKC_API.set_message(G_APP_NAME, G_INVALID_KEY,G_COL_NAME_TOKEN,'pdt_id');
         x_return_status := OKC_API.G_RET_STS_ERROR;

      ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
    END IF;
    CLOSE okl_pdt_opts_foreign2;
	END IF;

  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Pdt_Id;
------end of Validate_Pdt_Id-----------------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Optional_Yn
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Optional_Yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
PROCEDURE Validate_Optional_Yn(
      p_ponv_rec IN  ponv_rec_type,
      x_return_status OUT NOCOPY VARCHAR2

    ) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      -- check from domain values using the generic
      l_return_status :=             OKL_ACCOUNTING_UTIL.validate_lookup_code('YES_NO',p_ponv_rec.Optional_Yn,0,0);

      IF l_return_status = OKC_API.G_FALSE THEN
         l_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;

      IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_invalid_value,
                                  p_token1       => g_col_name_token,
                                  p_token1_value => 'optional_yn');

               -- notify caller of an error
               x_return_status := OKC_API.G_RET_STS_ERROR;

      END IF;

     EXCEPTION
        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sql_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sql_sqlerrm_token,
                          p_token2_value => sqlerrm);

        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
     END Validate_Optional_Yn;
 ------end of Validate_Optional_Yn-----------------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _From_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _From_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_From_Date(
    p_ponv_rec IN  ponv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_ponv_rec.from_date IS NULL OR p_ponv_rec.from_date = OKC_API.G_MISS_DATE
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'from_date');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_From_Date;
------end of Validate_From_Date-----------------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _To_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _To_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_To_Date(p_ponv_rec IN  ponv_rec_type,
                           x_return_status OUT NOCOPY  VARCHAR2)IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_ponv_rec.to_date IS NOT NULL) AND
       (p_ponv_rec.to_date < p_ponv_rec.from_date) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_to_date_error
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'to_date');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sql_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sql_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_To_Date;
------end of Validate_To_Date-----------------------------------


---------------------------------------------------------------------------
  -- PROCEDURE Validate _Unique_key
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Unique_key
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

 PROCEDURE Validate_Unique_Key(
    p_ponv_rec IN  ponv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS

    CURSOR okl_pdt_opts_unique (p_unique1  OKL_PDT_OPTS.OPT_ID%TYPE, p_unique2  OKL_PDT_OPTS.PDT_ID%TYPE) IS
    SELECT '1'
       FROM OKL_PDT_OPTS_V
      WHERE OKL_PDT_OPTS_V.OPT_ID =  p_unique1 AND
            OKL_PDT_OPTS_V.PDT_ID =  p_unique2 AND
            OKL_PDT_OPTS_V.ID <> nvl(p_ponv_rec.id,-9999);

    l_unique_key                   OKL_PDT_OPTS_V.OPT_ID%TYPE;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN okl_pdt_opts_unique (p_ponv_rec.opt_id, p_ponv_rec.pdt_id);
    FETCH okl_pdt_opts_unique INTO l_unique_key;
    IF okl_pdt_opts_unique%FOUND THEN
       OKC_API.set_message(G_APP_NAME,G_DUPLICATE_RECORD,G_COL_NAME_TOKEN,'opt_id');
       OKC_API.set_message(G_APP_NAME,G_DUPLICATE_RECORD,G_COL_NAME_TOKEN,'pdt_id');
       x_return_status := OKC_API.G_RET_STS_ERROR;
      ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
    END IF;
    CLOSE okl_pdt_opts_unique;

  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Key;

-----END OF VALIDATE UNIQUE KEY-------------------------

---------------------------------------------------------------------------
  -- FUNCTION Validate _Attribute
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Attribute
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
FUNCTION Validate_Attributes(
    p_ponv_rec IN  ponv_rec_type
  ) RETURN VARCHAR IS
       x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
       l_return_status	VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;


  BEGIN
    ---- CHECK FOR ID-------------------------
    Validate_Id (p_ponv_rec, x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
       l_return_status := x_return_status;
     END IF;
    END IF;

   --------CHECK FOR VERSION NUMBER------------------
    Validate_Object_Version_Number (p_ponv_rec,x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       l_return_status := x_return_status;
     END IF;
    END IF;

    -----CHECK FOR OPT_ID----------------------------
    Validate_Opt_Id (p_ponv_rec,x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
        l_return_status := x_return_status;
     END IF;
    END IF;

-----CHECK FOR PDT_ID----------------------------
    Validate_Pdt_Id (p_ponv_rec,x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
        l_return_status := x_return_status;
     END IF;
    END IF;

   -----CHECK FOR OPTIONAL_YN----------------------------
    Validate_optional_Yn (p_ponv_rec,x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       l_return_status := x_return_status;
     END IF;

    END IF;

   -----CHECK FOR FROM_DATE----------------------------
    Validate_From_Date (p_ponv_rec,x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
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
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
           l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END Validate_Attributes;

-----END OF VALIDATE ATTRIBUTES-------------------------

---------------------------------------------------------------------------
  -- FUNCTION Validate _Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

 FUNCTION Validate_Record(
    p_ponv_rec IN  ponv_rec_type
  ) RETURN VARCHAR IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


  BEGIN
   --------CHECK FOR UNIQUE KEY------------------
    Validate_Unique_Key (p_ponv_rec,x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       l_return_status := x_return_status;
     END IF;
    END IF;

-----CHECK FOR TO_DATE----------------------------
    Validate_To_Date (p_ponv_rec,x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
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
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RETURN(l_return_status);

  END Validate_Record;

-----END OF VALIDATE RECORD-------------------------

----TCHGS NEW CHANGS END --------------------

----TCHGS OLD CODE COMMENTES BEGIN --------------------
--  FUNCTION Validate_Attributes (
--    p_ponv_rec IN  ponv_rec_type
--  ) RETURN VARCHAR2 IS
--    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
--  BEGIN
--    IF p_ponv_rec.id = OKC_API.G_MISS_NUM OR
--       p_ponv_rec.id IS NULL
--    THEN
--      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
--      l_return_status := OKC_API.G_RET_STS_ERROR;
--    ELSIF p_ponv_rec.object_version_number = OKC_API.G_MISS_NUM OR
--          p_ponv_rec.object_version_number IS NULL
--    THEN
--      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
--      l_return_status := OKC_API.G_RET_STS_ERROR;
--    ELSIF p_ponv_rec.opt_id = OKC_API.G_MISS_NUM OR
--          p_ponv_rec.opt_id IS NULL
--    THEN
--      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'opt_id');
--      l_return_status := OKC_API.G_RET_STS_ERROR;
--    ELSIF p_ponv_rec.pdt_id = OKC_API.G_MISS_NUM OR
--          p_ponv_rec.pdt_id IS NULL
--    THEN
--      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pdt_id');
--      l_return_status := OKC_API.G_RET_STS_ERROR;
--    ELSIF p_ponv_rec.optional_yn = OKC_API.G_MISS_CHAR OR
--          p_ponv_rec.optional_yn IS NULL
--    THEN
--      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'optional_yn');
--      l_return_status := OKC_API.G_RET_STS_ERROR;
--    END IF;
--    RETURN(l_return_status);
--  END Validate_Attributes;
--
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKL_PDT_OPTS_V --
  ----------------------------------------
--  FUNCTION Validate_Record (
--    p_ponv_rec IN ponv_rec_type
--  ) RETURN VARCHAR2 IS
--    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
--  BEGIN
--    RETURN (l_return_status);
--  END Validate_Record;

----------TCHGS OLD CODE COMMENTES END-------------------------------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN ponv_rec_type,
    p_to	IN OUT NOCOPY pon_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.opt_id := p_from.opt_id;
    p_to.pdt_id := p_from.pdt_id;
    p_to.optional_yn := p_from.optional_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.from_date := p_from.from_date;
    p_to.to_date := p_from.to_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN pon_rec_type,
    p_to	IN OUT NOCOPY ponv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.opt_id := p_from.opt_id;
    p_to.pdt_id := p_from.pdt_id;
    p_to.optional_yn := p_from.optional_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.from_date := p_from.from_date;
    p_to.to_date := p_from.to_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- validate_row for:OKL_PDT_OPTS_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ponv_rec                     IN ponv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ponv_rec                     ponv_rec_type := p_ponv_rec;
    l_pon_rec                      pon_rec_type;
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
    l_return_status := Validate_Attributes(l_ponv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ponv_rec);
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
  -- PL/SQL TBL validate_row for:PONV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ponv_tbl                     IN ponv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ponv_tbl.COUNT > 0) THEN
      i := p_ponv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ponv_rec                     => p_ponv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_ponv_tbl.LAST);
        i := p_ponv_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
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
  ---------------------------------
  -- insert_row for:OKL_PDT_OPTS --
  ---------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pon_rec                      IN pon_rec_type,
    x_pon_rec                      OUT NOCOPY pon_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pon_rec                      pon_rec_type := p_pon_rec;
    l_def_pon_rec                  pon_rec_type;
    -------------------------------------
    -- Set_Attributes for:OKL_PDT_OPTS --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_pon_rec IN  pon_rec_type,
      x_pon_rec OUT NOCOPY pon_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pon_rec := p_pon_rec;
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
      p_pon_rec,                         -- IN
      l_pon_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_PDT_OPTS(
        id,
        opt_id,
        pdt_id,
        optional_yn,
        object_version_number,
        from_date,
        to_date,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_pon_rec.id,
        l_pon_rec.opt_id,
        l_pon_rec.pdt_id,
        l_pon_rec.optional_yn,
        l_pon_rec.object_version_number,
        l_pon_rec.from_date,
        l_pon_rec.to_date,
        l_pon_rec.created_by,
        l_pon_rec.creation_date,
        l_pon_rec.last_updated_by,
        l_pon_rec.last_update_date,
        l_pon_rec.last_update_login);
    -- Set OUT values
    x_pon_rec := l_pon_rec;
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
  -----------------------------------
  -- insert_row for:OKL_PDT_OPTS_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ponv_rec                     IN ponv_rec_type,
    x_ponv_rec                     OUT NOCOPY ponv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ponv_rec                     ponv_rec_type;
    l_def_ponv_rec                 ponv_rec_type;
    l_pon_rec                      pon_rec_type;
    lx_pon_rec                     pon_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ponv_rec	IN ponv_rec_type
    ) RETURN ponv_rec_type IS
      l_ponv_rec	ponv_rec_type := p_ponv_rec;
    BEGIN
      l_ponv_rec.CREATION_DATE := SYSDATE;
      l_ponv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ponv_rec.LAST_UPDATE_DATE := l_ponv_rec.CREATION_DATE;
      l_ponv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ponv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ponv_rec);
    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKL_PDT_OPTS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_ponv_rec IN  ponv_rec_type,
      x_ponv_rec OUT NOCOPY ponv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ponv_rec := p_ponv_rec;
      x_ponv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_ponv_rec := null_out_defaults(p_ponv_rec);
    -- Set primary key value
    l_ponv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ponv_rec,                        -- IN
      l_def_ponv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ponv_rec := fill_who_columns(l_def_ponv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ponv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ponv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ponv_rec, l_pon_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pon_rec,
      lx_pon_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pon_rec, l_def_ponv_rec);
    -- Set OUT values
    x_ponv_rec := l_def_ponv_rec;
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
  -- PL/SQL TBL insert_row for:PONV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ponv_tbl                     IN ponv_tbl_type,
    x_ponv_tbl                     OUT NOCOPY ponv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ponv_tbl.COUNT > 0) THEN
      i := p_ponv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ponv_rec                     => p_ponv_tbl(i),
          x_ponv_rec                     => x_ponv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_ponv_tbl.LAST);
        i := p_ponv_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
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
  -------------------------------
  -- lock_row for:OKL_PDT_OPTS --
  -------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pon_rec                      IN pon_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pon_rec IN pon_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PDT_OPTS
     WHERE ID = p_pon_rec.id
       AND OBJECT_VERSION_NUMBER = p_pon_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_pon_rec IN pon_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PDT_OPTS
    WHERE ID = p_pon_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_PDT_OPTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_PDT_OPTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_pon_rec);
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
      OPEN lchk_csr(p_pon_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pon_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pon_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
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
  ---------------------------------
  -- lock_row for:OKL_PDT_OPTS_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ponv_rec                     IN ponv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pon_rec                      pon_rec_type;
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
    migrate(p_ponv_rec, l_pon_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pon_rec
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
  -- PL/SQL TBL lock_row for:PONV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ponv_tbl                     IN ponv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ponv_tbl.COUNT > 0) THEN
      i := p_ponv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ponv_rec                     => p_ponv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_ponv_tbl.LAST);
        i := p_ponv_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
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
  ---------------------------------
  -- update_row for:OKL_PDT_OPTS --
  ---------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pon_rec                      IN pon_rec_type,
    x_pon_rec                      OUT NOCOPY pon_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pon_rec                      pon_rec_type := p_pon_rec;
    l_def_pon_rec                  pon_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pon_rec	IN pon_rec_type,
      x_pon_rec	OUT NOCOPY pon_rec_type
    ) RETURN VARCHAR2 IS
      l_pon_rec                      pon_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pon_rec := p_pon_rec;
      -- Get current database values
      l_pon_rec := get_rec(p_pon_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pon_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pon_rec.id := l_pon_rec.id;
      END IF;
      IF (x_pon_rec.opt_id = OKC_API.G_MISS_NUM)
      THEN
        x_pon_rec.opt_id := l_pon_rec.opt_id;
      END IF;
      IF (x_pon_rec.pdt_id = OKC_API.G_MISS_NUM)
      THEN
        x_pon_rec.pdt_id := l_pon_rec.pdt_id;
      END IF;
      IF (x_pon_rec.optional_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_pon_rec.optional_yn := l_pon_rec.optional_yn;
      END IF;
      IF (x_pon_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pon_rec.object_version_number := l_pon_rec.object_version_number;
      END IF;
      IF (x_pon_rec.from_date = OKC_API.G_MISS_DATE)
      THEN
        x_pon_rec.from_date := l_pon_rec.from_date;
      END IF;
      IF (x_pon_rec.to_date = OKC_API.G_MISS_DATE)
      THEN
        x_pon_rec.to_date := l_pon_rec.to_date;
      END IF;
      IF (x_pon_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pon_rec.created_by := l_pon_rec.created_by;
      END IF;
      IF (x_pon_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pon_rec.creation_date := l_pon_rec.creation_date;
      END IF;
      IF (x_pon_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pon_rec.last_updated_by := l_pon_rec.last_updated_by;
      END IF;
      IF (x_pon_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pon_rec.last_update_date := l_pon_rec.last_update_date;
      END IF;
      IF (x_pon_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pon_rec.last_update_login := l_pon_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------
    -- Set_Attributes for:OKL_PDT_OPTS --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_pon_rec IN  pon_rec_type,
      x_pon_rec OUT NOCOPY pon_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pon_rec := p_pon_rec;
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
      p_pon_rec,                         -- IN
      l_pon_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pon_rec, l_def_pon_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_PDT_OPTS
    SET OPT_ID = l_def_pon_rec.opt_id,
        PDT_ID = l_def_pon_rec.pdt_id,
        OPTIONAL_YN = l_def_pon_rec.optional_yn,
        OBJECT_VERSION_NUMBER = l_def_pon_rec.object_version_number,
        FROM_DATE = l_def_pon_rec.from_date,
        TO_DATE = l_def_pon_rec.to_date,
        CREATED_BY = l_def_pon_rec.created_by,
        CREATION_DATE = l_def_pon_rec.creation_date,
        LAST_UPDATED_BY = l_def_pon_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pon_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pon_rec.last_update_login
    WHERE ID = l_def_pon_rec.id;

    x_pon_rec := l_def_pon_rec;
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
  -----------------------------------
  -- update_row for:OKL_PDT_OPTS_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ponv_rec                     IN ponv_rec_type,
    x_ponv_rec                     OUT NOCOPY ponv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ponv_rec                     ponv_rec_type := p_ponv_rec;
    l_def_ponv_rec                 ponv_rec_type;
    l_pon_rec                      pon_rec_type;
    lx_pon_rec                     pon_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ponv_rec	IN ponv_rec_type
    ) RETURN ponv_rec_type IS
      l_ponv_rec	ponv_rec_type := p_ponv_rec;
    BEGIN
      l_ponv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ponv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ponv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ponv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ponv_rec	IN ponv_rec_type,
      x_ponv_rec	OUT NOCOPY ponv_rec_type
    ) RETURN VARCHAR2 IS
      l_ponv_rec                     ponv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ponv_rec := p_ponv_rec;
      -- Get current database values
      l_ponv_rec := get_rec(p_ponv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ponv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ponv_rec.id := l_ponv_rec.id;
      END IF;
      IF (x_ponv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ponv_rec.object_version_number := l_ponv_rec.object_version_number;
      END IF;
      IF (x_ponv_rec.opt_id = OKC_API.G_MISS_NUM)
      THEN
        x_ponv_rec.opt_id := l_ponv_rec.opt_id;
      END IF;
      IF (x_ponv_rec.pdt_id = OKC_API.G_MISS_NUM)
      THEN
        x_ponv_rec.pdt_id := l_ponv_rec.pdt_id;
      END IF;
      IF (x_ponv_rec.from_date = OKC_API.G_MISS_DATE)
      THEN
        x_ponv_rec.from_date := l_ponv_rec.from_date;
      END IF;
      IF (x_ponv_rec.to_date = OKC_API.G_MISS_DATE)
      THEN
        x_ponv_rec.to_date := l_ponv_rec.to_date;
      END IF;
      IF (x_ponv_rec.optional_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_ponv_rec.optional_yn := l_ponv_rec.optional_yn;
      END IF;
      IF (x_ponv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ponv_rec.created_by := l_ponv_rec.created_by;
      END IF;
      IF (x_ponv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ponv_rec.creation_date := l_ponv_rec.creation_date;
      END IF;
      IF (x_ponv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ponv_rec.last_updated_by := l_ponv_rec.last_updated_by;
      END IF;
      IF (x_ponv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ponv_rec.last_update_date := l_ponv_rec.last_update_date;
      END IF;
      IF (x_ponv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ponv_rec.last_update_login := l_ponv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_PDT_OPTS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_ponv_rec IN  ponv_rec_type,
      x_ponv_rec OUT NOCOPY ponv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ponv_rec := p_ponv_rec;
      x_ponv_rec.OBJECT_VERSION_NUMBER := NVL(x_ponv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_ponv_rec,                        -- IN
      l_ponv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ponv_rec, l_def_ponv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ponv_rec := fill_who_columns(l_def_ponv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ponv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ponv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ponv_rec, l_pon_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pon_rec,
      lx_pon_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pon_rec, l_def_ponv_rec);
    x_ponv_rec := l_def_ponv_rec;
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
  -- PL/SQL TBL update_row for:PONV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ponv_tbl                     IN ponv_tbl_type,
    x_ponv_tbl                     OUT NOCOPY ponv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ponv_tbl.COUNT > 0) THEN
      i := p_ponv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ponv_rec                     => p_ponv_tbl(i),
          x_ponv_rec                     => x_ponv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_ponv_tbl.LAST);
        i := p_ponv_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
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
  ---------------------------------
  -- delete_row for:OKL_PDT_OPTS --
  ---------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pon_rec                      IN pon_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pon_rec                      pon_rec_type:= p_pon_rec;
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
    DELETE FROM OKL_PDT_OPTS
     WHERE ID = l_pon_rec.id;

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
  -----------------------------------
  -- delete_row for:OKL_PDT_OPTS_V --
  -----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ponv_rec                     IN ponv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ponv_rec                     ponv_rec_type := p_ponv_rec;
    l_pon_rec                      pon_rec_type;
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
    migrate(l_ponv_rec, l_pon_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pon_rec
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
  -- PL/SQL TBL delete_row for:PONV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ponv_tbl                     IN ponv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ponv_tbl.COUNT > 0) THEN
      i := p_ponv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ponv_rec                     => p_ponv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_ponv_tbl.LAST);
        i := p_ponv_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
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
END OKL_PON_PVT;

/
