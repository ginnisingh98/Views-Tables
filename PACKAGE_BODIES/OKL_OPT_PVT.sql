--------------------------------------------------------
--  DDL for Package Body OKL_OPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OPT_PVT" AS
/* $Header: OKLSOPTB.pls 115.11 2002/12/18 13:00:55 kjinger noship $ */
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
  -- FUNCTION get_rec for: OKL_OPTIONS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_opt_rec                      IN opt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN opt_rec_type IS
    CURSOR okl_options_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            NAME,
            OBJECT_VERSION_NUMBER,
            DESCRIPTION,
            FROM_DATE,
            TO_DATE,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Options
     WHERE okl_options.id       = p_id;
    l_okl_options_pk               okl_options_pk_csr%ROWTYPE;
    l_opt_rec                      opt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_options_pk_csr (p_opt_rec.id);
    FETCH okl_options_pk_csr INTO
              l_opt_rec.ID,
              l_opt_rec.NAME,
              l_opt_rec.OBJECT_VERSION_NUMBER,
              l_opt_rec.DESCRIPTION,
              l_opt_rec.FROM_DATE,
              l_opt_rec.TO_DATE,
              l_opt_rec.ATTRIBUTE_CATEGORY,
              l_opt_rec.ATTRIBUTE1,
              l_opt_rec.ATTRIBUTE2,
              l_opt_rec.ATTRIBUTE3,
              l_opt_rec.ATTRIBUTE4,
              l_opt_rec.ATTRIBUTE5,
              l_opt_rec.ATTRIBUTE6,
              l_opt_rec.ATTRIBUTE7,
              l_opt_rec.ATTRIBUTE8,
              l_opt_rec.ATTRIBUTE9,
              l_opt_rec.ATTRIBUTE10,
              l_opt_rec.ATTRIBUTE11,
              l_opt_rec.ATTRIBUTE12,
              l_opt_rec.ATTRIBUTE13,
              l_opt_rec.ATTRIBUTE14,
              l_opt_rec.ATTRIBUTE15,
              l_opt_rec.CREATED_BY,
              l_opt_rec.CREATION_DATE,
              l_opt_rec.LAST_UPDATED_BY,
              l_opt_rec.LAST_UPDATE_DATE,
              l_opt_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_options_pk_csr%NOTFOUND;
    CLOSE okl_options_pk_csr;
    RETURN(l_opt_rec);
  END get_rec;

  FUNCTION get_rec (
    p_opt_rec                      IN opt_rec_type
  ) RETURN opt_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_opt_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_OPTIONS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_optv_rec                     IN optv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN optv_rec_type IS
    CURSOR okl_optv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
            DESCRIPTION,
            FROM_DATE,
            TO_DATE,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Options_V
     WHERE okl_options_v.id     = p_id;
    l_okl_optv_pk                  okl_optv_pk_csr%ROWTYPE;
    l_optv_rec                     optv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_optv_pk_csr (p_optv_rec.id);
    FETCH okl_optv_pk_csr INTO
              l_optv_rec.ID,
              l_optv_rec.OBJECT_VERSION_NUMBER,
              l_optv_rec.NAME,
              l_optv_rec.DESCRIPTION,
              l_optv_rec.FROM_DATE,
              l_optv_rec.TO_DATE,
              l_optv_rec.ATTRIBUTE_CATEGORY,
              l_optv_rec.ATTRIBUTE1,
              l_optv_rec.ATTRIBUTE2,
              l_optv_rec.ATTRIBUTE3,
              l_optv_rec.ATTRIBUTE4,
              l_optv_rec.ATTRIBUTE5,
              l_optv_rec.ATTRIBUTE6,
              l_optv_rec.ATTRIBUTE7,
              l_optv_rec.ATTRIBUTE8,
              l_optv_rec.ATTRIBUTE9,
              l_optv_rec.ATTRIBUTE10,
              l_optv_rec.ATTRIBUTE11,
              l_optv_rec.ATTRIBUTE12,
              l_optv_rec.ATTRIBUTE13,
              l_optv_rec.ATTRIBUTE14,
              l_optv_rec.ATTRIBUTE15,
              l_optv_rec.CREATED_BY,
              l_optv_rec.CREATION_DATE,
              l_optv_rec.LAST_UPDATED_BY,
              l_optv_rec.LAST_UPDATE_DATE,
              l_optv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_optv_pk_csr%NOTFOUND;
    CLOSE okl_optv_pk_csr;
    RETURN(l_optv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_optv_rec                     IN optv_rec_type
  ) RETURN optv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_optv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_OPTIONS_V --
  ---------------------------------------------------
  FUNCTION null_out_defaults (
    p_optv_rec	IN optv_rec_type
  ) RETURN optv_rec_type IS
    l_optv_rec	optv_rec_type := p_optv_rec;
  BEGIN
    IF (l_optv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_optv_rec.object_version_number := NULL;
    END IF;
    IF (l_optv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.name := NULL;
    END IF;
    IF (l_optv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.description := NULL;
    END IF;
    IF (l_optv_rec.from_date = OKC_API.G_MISS_DATE) THEN
      l_optv_rec.from_date := NULL;
    END IF;
    IF (l_optv_rec.TO_DATE = OKC_API.G_MISS_DATE) THEN
      l_optv_rec.TO_DATE := NULL;
    END IF;
    IF (l_optv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute_category := NULL;
    END IF;
    IF (l_optv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute1 := NULL;
    END IF;
    IF (l_optv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute2 := NULL;
    END IF;
    IF (l_optv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute3 := NULL;
    END IF;
    IF (l_optv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute4 := NULL;
    END IF;
    IF (l_optv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute5 := NULL;
    END IF;
    IF (l_optv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute6 := NULL;
    END IF;
    IF (l_optv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute7 := NULL;
    END IF;
    IF (l_optv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute8 := NULL;
    END IF;
    IF (l_optv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute9 := NULL;
    END IF;
    IF (l_optv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute10 := NULL;
    END IF;
    IF (l_optv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute11 := NULL;
    END IF;
    IF (l_optv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute12 := NULL;
    END IF;
    IF (l_optv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute13 := NULL;
    END IF;
    IF (l_optv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute14 := NULL;
    END IF;
    IF (l_optv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_optv_rec.attribute15 := NULL;
    END IF;
    IF (l_optv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_optv_rec.created_by := NULL;
    END IF;
    IF (l_optv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_optv_rec.creation_date := NULL;
    END IF;
    IF (l_optv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_optv_rec.last_updated_by := NULL;
    END IF;
    IF (l_optv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_optv_rec.last_update_date := NULL;
    END IF;
    IF (l_optv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_optv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_optv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate_Attributes for:OKL_OPTIONS_V --
  -------------------------------------------
----------------TCHGS NEW CHANGES BEGIN --------------------------
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
  PROCEDURE Validate_Id (
    p_optv_rec IN  optv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_optv_rec.id = OKC_API.G_MISS_NUM OR
       p_optv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name       =>G_APP_NAME,
                               p_msg_name       =>G_UNEXPECTED_ERROR,
                               p_token1         =>G_SQL_SQLCODE_TOKEN,
                               p_token1_value   =>SQLCODE,
                               p_token2         =>G_SQL_SQLERRM_TOKEN,
                               p_token2_value   =>SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;
-----end of Validate_Id------------------------

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
PROCEDURE Validate_Object_Version_Number (
    p_optv_rec IN  optv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_optv_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_optv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name       =>G_APP_NAME,
                               p_msg_name       =>G_UNEXPECTED_ERROR,
                               p_token1         =>G_SQL_SQLCODE_TOKEN,
                               p_token1_value   =>SQLCODE,
                               p_token2         =>G_SQL_SQLERRM_TOKEN,
                               p_token2_value   =>SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;
------end of Validate_Object_Version_Number-----------------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Name(
    p_optv_rec IN OUT NOCOPY optv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_optv_rec.name = OKC_API.G_MISS_CHAR OR
       p_optv_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    p_optv_rec.name := Okl_Accounting_Util.okl_upper(p_optv_rec.name);
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name       =>G_APP_NAME,
                               p_msg_name       =>G_UNEXPECTED_ERROR,
                               p_token1         =>G_SQL_SQLCODE_TOKEN,
                               p_token1_value   =>SQLCODE,
                               p_token2         =>G_SQL_SQLERRM_TOKEN,
                               p_token2_value   =>SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Name;
------end of Validate_Name-----------------------------------

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
    p_optv_rec IN  optv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_optv_rec.from_date IS NULL OR p_optv_rec.from_date = OKC_API.G_MISS_DATE
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'from_date');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name       =>G_APP_NAME,
                               p_msg_name       =>G_UNEXPECTED_ERROR,
                               p_token1         =>G_SQL_SQLCODE_TOKEN,
                               p_token1_value   =>SQLCODE,
                               p_token2         =>G_SQL_SQLERRM_TOKEN,
                               p_token2_value   =>SQLERRM);
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

PROCEDURE Validate_To_Date(p_optv_rec IN  optv_rec_type,
                           x_return_status OUT NOCOPY  VARCHAR2)IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_optv_rec.TO_DATE IS NOT NULL) AND
       (p_optv_rec.TO_DATE < p_optv_rec.from_date) THEN
       OKC_API.SET_MESSAGE(p_app_name       => 'OKL'
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
                          p_token1_value => SQLCODE,
                          p_token2       => g_sql_sqlerrm_token,
                          p_token2_value => SQLERRM);

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
    p_optv_rec IN  optv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS

    CURSOR okl_options_unique (p_unique  OKL_OPTIONS_V.NAME%TYPE) IS
    SELECT '1'
       FROM OKL_OPTIONS_V
      WHERE OKL_OPTIONS_V.NAME =  p_unique AND
            OKL_OPTIONS_V.ID <> NVL(p_optv_rec.id,-9999);

    l_unique_key                   OKL_OPTIONS_V.NAME%TYPE;


  BEGIN
    OPEN okl_options_unique (p_optv_rec.name);
    FETCH okl_options_unique INTO l_unique_key;
    IF okl_options_unique%FOUND THEN
		  OKC_API.set_message('OKL','OKL_NOT_UNIQUE', 'OKL_TABLE_NAME','Okl_Options_V');
          x_return_status := OKC_API.G_RET_STS_ERROR;
      ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
    END IF;
    CLOSE okl_options_unique;

  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name       =>G_APP_NAME,
                               p_msg_name       =>G_UNEXPECTED_ERROR,
                               p_token1         =>G_SQL_SQLCODE_TOKEN,
                               p_token1_value   =>SQLCODE,
                               p_token2         =>G_SQL_SQLERRM_TOKEN,
                               p_token2_value   =>SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Key;

-----END OF VALIDATE UNIQUE KEY-------------------------

---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

FUNCTION Validate_Attributes(
    p_optv_rec IN OUT NOCOPY optv_rec_type
  ) RETURN VARCHAR IS
       x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
       l_return_status	VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;


  BEGIN
    ---- CHECK FOR ID-------------------------
    Validate_Id (p_optv_rec, x_return_status);
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
    Validate_Object_Version_Number (p_optv_rec, x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       l_return_status := x_return_status;
     END IF;
    END IF;

--------CHECK FOR NAME------------------
    Validate_Name (p_optv_rec, x_return_status);
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
    Validate_From_Date (p_optv_rec, x_return_status);
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
                          p_msg_name  =>G_UNEXPECTED_ERROR,
                          p_token1    =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value  =>SQLCODE,
                          p_token2    =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value  =>SQLERRM);
           l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END Validate_Attributes;

-----END OF VALIDATE ATTRIBUTES-------------------------

---------------------------------------------------------------------------
  -- FUNCTION Validate _Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : Validate _Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

 FUNCTION Validate_Record(
    p_optv_rec IN  optv_rec_type
  ) RETURN VARCHAR IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


  BEGIN

   --------CHECK FOR UNIQUE KEY------------------
    Validate_Unique_Key (p_optv_rec, x_return_status);
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
    Validate_To_Date (p_optv_rec, x_return_status);
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
                          p_token1_value   =>SQLCODE,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RETURN(l_return_status);

  END Validate_Record;

-----TCHGS NEW CHANGES END-----------------

-----TCHGS OLD CODE COMMENTED--------------------

 -- FUNCTION Validate_Attributes (
 --   p_optv_rec IN  p_optv_rec_type
 -- ) RETURN VARCHAR2 IS
 --   l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 -- BEGIN
 --   IF p_optv_rec.id = OKC_API.G_MISS_NUM OR
 --      p_optv_rec.id IS NULL
 --   THEN
 --     OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
 --     l_return_status := OKC_API.G_RET_STS_ERROR;
 --   ELSIF p_optv_rec.object_version_number = OKC_API.G_MISS_NUM OR
 --         p_optv_rec.object_version_number IS NULL
 --   THEN
 --     OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
 --     l_return_status := OKC_API.G_RET_STS_ERROR;
 --   ELSIF p_optv_rec.name = OKC_API.G_MISS_CHAR OR
 --         p_optv_rec.name IS NULL
 --   THEN
 --     OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
 --     l_return_status := OKC_API.G_RET_STS_ERROR;
 --   END IF;
 --   RETURN(l_return_status);
 -- END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- Validate_Record for:OKL_OPTIONS_V --
  ---------------------------------------
 -- FUNCTION Validate_Record (
 --   p_optv_rec IN optv_rec_type
 -- ) RETURN VARCHAR2 IS
 --   l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 --   l_primary_key OKL_OPTIONS.ID%TYPE;
 --   l_unique_key  OKL_OPTIONS.NAME%TYPE;
 --   RETURN (l_return_status);
 -- END Validate_Record;
-----END OF TCHGS OLD CODE COMMENTS--------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN optv_rec_type,
    p_to	IN OUT NOCOPY opt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
    p_to.from_date := p_from.from_date;
    p_to.TO_DATE := p_from.TO_DATE;
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
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN opt_rec_type,
    p_to	IN OUT NOCOPY optv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
    p_to.from_date := p_from.from_date;
    p_to.TO_DATE := p_from.TO_DATE;
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
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- validate_row for:OKL_OPTIONS_V --
  ------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_rec                     IN optv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_optv_rec                     optv_rec_type := p_optv_rec;
    l_opt_rec                      opt_rec_type;
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
    l_return_status := Validate_Attributes(l_optv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_optv_rec);
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
  -- PL/SQL TBL validate_row for:OPTV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_tbl                     IN optv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_optv_tbl.COUNT > 0) THEN
      i := p_optv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_optv_rec                     => p_optv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_optv_tbl.LAST);
        i := p_optv_tbl.NEXT(i);
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
  --------------------------------
  -- insert_row for:OKL_OPTIONS --
  --------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opt_rec                      IN opt_rec_type,
    x_opt_rec                      OUT NOCOPY opt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTIONS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_opt_rec                      opt_rec_type := p_opt_rec;
    l_def_opt_rec                  opt_rec_type;
    ------------------------------------
    -- Set_Attributes for:OKL_OPTIONS --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_opt_rec IN  opt_rec_type,
      x_opt_rec OUT NOCOPY opt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_opt_rec := p_opt_rec;
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
      p_opt_rec,                         -- IN
      l_opt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_OPTIONS(
        id,
        name,
        object_version_number,
        description,
        from_date,
        TO_DATE,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_opt_rec.id,
        UPPER(l_opt_rec.name),
        l_opt_rec.object_version_number,
        l_opt_rec.description,
        l_opt_rec.from_date,
        l_opt_rec.TO_DATE,
        l_opt_rec.attribute_category,
        l_opt_rec.attribute1,
        l_opt_rec.attribute2,
        l_opt_rec.attribute3,
        l_opt_rec.attribute4,
        l_opt_rec.attribute5,
        l_opt_rec.attribute6,
        l_opt_rec.attribute7,
        l_opt_rec.attribute8,
        l_opt_rec.attribute9,
        l_opt_rec.attribute10,
        l_opt_rec.attribute11,
        l_opt_rec.attribute12,
        l_opt_rec.attribute13,
        l_opt_rec.attribute14,
        l_opt_rec.attribute15,
        l_opt_rec.created_by,
        l_opt_rec.creation_date,
        l_opt_rec.last_updated_by,
        l_opt_rec.last_update_date,
        l_opt_rec.last_update_login);
    -- Set OUT values
    x_opt_rec := l_opt_rec;
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
  -- insert_row for:OKL_OPTIONS_V --
  ----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_rec                     IN optv_rec_type,
    x_optv_rec                     OUT NOCOPY optv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_optv_rec                     optv_rec_type;
    l_def_optv_rec                 optv_rec_type;
    l_opt_rec                      opt_rec_type;
    lx_opt_rec                     opt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_optv_rec	IN optv_rec_type
    ) RETURN optv_rec_type IS
      l_optv_rec	optv_rec_type := p_optv_rec;
    BEGIN
      l_optv_rec.CREATION_DATE := SYSDATE;
      l_optv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_optv_rec.LAST_UPDATE_DATE := l_optv_rec.CREATION_DATE;
      l_optv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_optv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_optv_rec);
    END fill_who_columns;
    --------------------------------------
    -- Set_Attributes for:OKL_OPTIONS_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_optv_rec IN  optv_rec_type,
      x_optv_rec OUT NOCOPY optv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_optv_rec := p_optv_rec;
      x_optv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_optv_rec := null_out_defaults(p_optv_rec);
    -- Set primary key value
    l_optv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_optv_rec,                        -- IN
      l_def_optv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_optv_rec := fill_who_columns(l_def_optv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_optv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_optv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_optv_rec, l_opt_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_opt_rec,
      lx_opt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_opt_rec, l_def_optv_rec);
    -- Set OUT values
    x_optv_rec := l_def_optv_rec;
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
  -- PL/SQL TBL insert_row for:OPTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_tbl                     IN optv_tbl_type,
    x_optv_tbl                     OUT NOCOPY optv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_optv_tbl.COUNT > 0) THEN
      i := p_optv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_optv_rec                     => p_optv_tbl(i),
          x_optv_rec                     => x_optv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_optv_tbl.LAST);
        i := p_optv_tbl.NEXT(i);
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
  ------------------------------
  -- lock_row for:OKL_OPTIONS --
  ------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opt_rec                      IN opt_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_opt_rec IN opt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPTIONS
     WHERE ID = p_opt_rec.id
       AND OBJECT_VERSION_NUMBER = p_opt_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_opt_rec IN opt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPTIONS
    WHERE ID = p_opt_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTIONS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_OPTIONS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_OPTIONS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_opt_rec);
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
      OPEN lchk_csr(p_opt_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_opt_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_opt_rec.object_version_number THEN
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
  --------------------------------
  -- lock_row for:OKL_OPTIONS_V --
  --------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_rec                     IN optv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_opt_rec                      opt_rec_type;
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
    migrate(p_optv_rec, l_opt_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_opt_rec
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
  -- PL/SQL TBL lock_row for:OPTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_tbl                     IN optv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_optv_tbl.COUNT > 0) THEN
      i := p_optv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_optv_rec                     => p_optv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_optv_tbl.LAST);
        i := p_optv_tbl.NEXT(i);
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
  --------------------------------
  -- update_row for:OKL_OPTIONS --
  --------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opt_rec                      IN opt_rec_type,
    x_opt_rec                      OUT NOCOPY opt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTIONS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_opt_rec                      opt_rec_type := p_opt_rec;
    l_def_opt_rec                  opt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_opt_rec	IN opt_rec_type,
      x_opt_rec	OUT NOCOPY opt_rec_type
    ) RETURN VARCHAR2 IS
      l_opt_rec                      opt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_opt_rec := p_opt_rec;
      -- Get current database values
      l_opt_rec := get_rec(p_opt_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_opt_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_opt_rec.id := l_opt_rec.id;
      END IF;
      IF (x_opt_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.name := l_opt_rec.name;
      END IF;
      IF (x_opt_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_opt_rec.object_version_number := l_opt_rec.object_version_number;
      END IF;
      IF (x_opt_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.description := l_opt_rec.description;
      END IF;
      IF (x_opt_rec.from_date = OKC_API.G_MISS_DATE)
      THEN
        x_opt_rec.from_date := l_opt_rec.from_date;
      END IF;
      IF (x_opt_rec.TO_DATE = OKC_API.G_MISS_DATE)
      THEN
        x_opt_rec.TO_DATE := l_opt_rec.TO_DATE;
      END IF;
      IF (x_opt_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute_category := l_opt_rec.attribute_category;
      END IF;
      IF (x_opt_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute1 := l_opt_rec.attribute1;
      END IF;
      IF (x_opt_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute2 := l_opt_rec.attribute2;
      END IF;
      IF (x_opt_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute3 := l_opt_rec.attribute3;
      END IF;
      IF (x_opt_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute4 := l_opt_rec.attribute4;
      END IF;
      IF (x_opt_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute5 := l_opt_rec.attribute5;
      END IF;
      IF (x_opt_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute6 := l_opt_rec.attribute6;
      END IF;
      IF (x_opt_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute7 := l_opt_rec.attribute7;
      END IF;
      IF (x_opt_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute8 := l_opt_rec.attribute8;
      END IF;
      IF (x_opt_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute9 := l_opt_rec.attribute9;
      END IF;
      IF (x_opt_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute10 := l_opt_rec.attribute10;
      END IF;
      IF (x_opt_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute11 := l_opt_rec.attribute11;
      END IF;
      IF (x_opt_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute12 := l_opt_rec.attribute12;
      END IF;
      IF (x_opt_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute13 := l_opt_rec.attribute13;
      END IF;
      IF (x_opt_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute14 := l_opt_rec.attribute14;
      END IF;
      IF (x_opt_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_opt_rec.attribute15 := l_opt_rec.attribute15;
      END IF;
      IF (x_opt_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_opt_rec.created_by := l_opt_rec.created_by;
      END IF;
      IF (x_opt_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_opt_rec.creation_date := l_opt_rec.creation_date;
      END IF;
      IF (x_opt_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_opt_rec.last_updated_by := l_opt_rec.last_updated_by;
      END IF;
      IF (x_opt_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_opt_rec.last_update_date := l_opt_rec.last_update_date;
      END IF;
      IF (x_opt_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_opt_rec.last_update_login := l_opt_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------
    -- Set_Attributes for:OKL_OPTIONS --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_opt_rec IN  opt_rec_type,
      x_opt_rec OUT NOCOPY opt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_opt_rec := p_opt_rec;
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
      p_opt_rec,                         -- IN
      l_opt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_opt_rec, l_def_opt_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_OPTIONS
    SET NAME = l_def_opt_rec.name,
        OBJECT_VERSION_NUMBER = l_def_opt_rec.object_version_number,
        DESCRIPTION = l_def_opt_rec.description,
        FROM_DATE = l_def_opt_rec.from_date,
        TO_DATE = l_def_opt_rec.TO_DATE,
        ATTRIBUTE_CATEGORY = l_def_opt_rec.attribute_category,
        ATTRIBUTE1 = l_def_opt_rec.attribute1,
        ATTRIBUTE2 = l_def_opt_rec.attribute2,
        ATTRIBUTE3 = l_def_opt_rec.attribute3,
        ATTRIBUTE4 = l_def_opt_rec.attribute4,
        ATTRIBUTE5 = l_def_opt_rec.attribute5,
        ATTRIBUTE6 = l_def_opt_rec.attribute6,
        ATTRIBUTE7 = l_def_opt_rec.attribute7,
        ATTRIBUTE8 = l_def_opt_rec.attribute8,
        ATTRIBUTE9 = l_def_opt_rec.attribute9,
        ATTRIBUTE10 = l_def_opt_rec.attribute10,
        ATTRIBUTE11 = l_def_opt_rec.attribute11,
        ATTRIBUTE12 = l_def_opt_rec.attribute12,
        ATTRIBUTE13 = l_def_opt_rec.attribute13,
        ATTRIBUTE14 = l_def_opt_rec.attribute14,
        ATTRIBUTE15 = l_def_opt_rec.attribute15,
        CREATED_BY = l_def_opt_rec.created_by,
        CREATION_DATE = l_def_opt_rec.creation_date,
        LAST_UPDATED_BY = l_def_opt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_opt_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_opt_rec.last_update_login
    WHERE ID = l_def_opt_rec.id;

    x_opt_rec := l_def_opt_rec;
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
  -- update_row for:OKL_OPTIONS_V --
  ----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_rec                     IN optv_rec_type,
    x_optv_rec                     OUT NOCOPY optv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_optv_rec                     optv_rec_type := p_optv_rec;
    l_def_optv_rec                 optv_rec_type;
    l_opt_rec                      opt_rec_type;
    lx_opt_rec                     opt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_optv_rec	IN optv_rec_type
    ) RETURN optv_rec_type IS
      l_optv_rec	optv_rec_type := p_optv_rec;
    BEGIN
      l_optv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_optv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_optv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_optv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_optv_rec	IN optv_rec_type,
      x_optv_rec	OUT NOCOPY optv_rec_type
    ) RETURN VARCHAR2 IS
      l_optv_rec                     optv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_optv_rec := p_optv_rec;
      -- Get current database values
      l_optv_rec := get_rec(p_optv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_optv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_optv_rec.id := l_optv_rec.id;
      END IF;
      IF (x_optv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_optv_rec.object_version_number := l_optv_rec.object_version_number;
      END IF;
      IF (x_optv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.name := l_optv_rec.name;
      END IF;
      IF (x_optv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.description := l_optv_rec.description;
      END IF;
      IF (x_optv_rec.from_date = OKC_API.G_MISS_DATE)
      THEN
        x_optv_rec.from_date := l_optv_rec.from_date;
      END IF;
      IF (x_optv_rec.TO_DATE = OKC_API.G_MISS_DATE)
      THEN
        x_optv_rec.TO_DATE := l_optv_rec.TO_DATE;
      END IF;
      IF (x_optv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute_category := l_optv_rec.attribute_category;
      END IF;
      IF (x_optv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute1 := l_optv_rec.attribute1;
      END IF;
      IF (x_optv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute2 := l_optv_rec.attribute2;
      END IF;
      IF (x_optv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute3 := l_optv_rec.attribute3;
      END IF;
      IF (x_optv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute4 := l_optv_rec.attribute4;
      END IF;
      IF (x_optv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute5 := l_optv_rec.attribute5;
      END IF;
      IF (x_optv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute6 := l_optv_rec.attribute6;
      END IF;
      IF (x_optv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute7 := l_optv_rec.attribute7;
      END IF;
      IF (x_optv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute8 := l_optv_rec.attribute8;
      END IF;
      IF (x_optv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute9 := l_optv_rec.attribute9;
      END IF;
      IF (x_optv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute10 := l_optv_rec.attribute10;
      END IF;
      IF (x_optv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute11 := l_optv_rec.attribute11;
      END IF;
      IF (x_optv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute12 := l_optv_rec.attribute12;
      END IF;
      IF (x_optv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute13 := l_optv_rec.attribute13;
      END IF;
      IF (x_optv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute14 := l_optv_rec.attribute14;
      END IF;
      IF (x_optv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_optv_rec.attribute15 := l_optv_rec.attribute15;
      END IF;
      IF (x_optv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_optv_rec.created_by := l_optv_rec.created_by;
      END IF;
      IF (x_optv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_optv_rec.creation_date := l_optv_rec.creation_date;
      END IF;
      IF (x_optv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_optv_rec.last_updated_by := l_optv_rec.last_updated_by;
      END IF;
      IF (x_optv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_optv_rec.last_update_date := l_optv_rec.last_update_date;
      END IF;
      IF (x_optv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_optv_rec.last_update_login := l_optv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKL_OPTIONS_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_optv_rec IN  optv_rec_type,
      x_optv_rec OUT NOCOPY optv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_optv_rec := p_optv_rec;
      x_optv_rec.OBJECT_VERSION_NUMBER := NVL(x_optv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_optv_rec,                        -- IN
      l_optv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_optv_rec, l_def_optv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_optv_rec := fill_who_columns(l_def_optv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_optv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_optv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_optv_rec, l_opt_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_opt_rec,
      lx_opt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_opt_rec, l_def_optv_rec);
    x_optv_rec := l_def_optv_rec;
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
  -- PL/SQL TBL update_row for:OPTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_tbl                     IN optv_tbl_type,
    x_optv_tbl                     OUT NOCOPY optv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_optv_tbl.COUNT > 0) THEN
      i := p_optv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_optv_rec                     => p_optv_tbl(i),
          x_optv_rec                     => x_optv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_optv_tbl.LAST);
        i := p_optv_tbl.NEXT(i);
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
  --------------------------------
  -- delete_row for:OKL_OPTIONS --
  --------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opt_rec                      IN opt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTIONS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_opt_rec                      opt_rec_type:= p_opt_rec;
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
    DELETE FROM OKL_OPTIONS
     WHERE ID = l_opt_rec.id;

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
  -- delete_row for:OKL_OPTIONS_V --
  ----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_rec                     IN optv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_optv_rec                     optv_rec_type := p_optv_rec;
    l_opt_rec                      opt_rec_type;
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
    migrate(l_optv_rec, l_opt_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_opt_rec
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
  -- PL/SQL TBL delete_row for:OPTV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_tbl                     IN optv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_optv_tbl.COUNT > 0) THEN
      i := p_optv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_optv_rec                     => p_optv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_optv_tbl.LAST);
        i := p_optv_tbl.NEXT(i);
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
END OKL_OPT_PVT;

/
