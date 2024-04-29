--------------------------------------------------------
--  DDL for Package Body OKL_SPM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SPM_PVT" AS
/* $Header: OKLSSPMB.pls 120.3 2005/10/30 03:18:10 appldev noship $*/

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
  END get_seq_id;

 ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_PRICING_PARAMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_spm_rec                      IN  spm_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN spm_rec_type IS
    CURSOR okl_sif_pricing_params_pk_csr (p_id IN NUMBER) IS
    SELECT  ID
            ,OBJECT_VERSION_NUMBER
            ,SIF_ID
            ,khr_id
            ,NAME
            ,DISPLAY_YN
            ,UPDATE_YN
            ,DEFAULT_VALUE
            ,PARAMETER_VALUE
            ,PRC_ENG_IDENT
            ,DESCRIPTION
            ,CREATED_BY
            ,CREATION_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATE_LOGIN
    FROM OKL_SIF_PRICING_PARAMS
    WHERE OKL_SIF_PRICING_PARAMS.id = p_id;

    l_okl_sif_pricing_params_pk  okl_sif_pricing_params_pk_csr%ROWTYPE;
    l_spm_rec                  spm_rec_type;
  BEGIN
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_sif_pricing_params_pk_csr (p_spm_rec.id);

    FETCH okl_sif_pricing_params_pk_csr INTO
         l_spm_rec.id
        ,l_spm_rec.object_version_number
        ,l_spm_rec.sif_id
        ,l_spm_rec.khr_id
        ,l_spm_rec.name
        ,l_spm_rec.display_yn
        ,l_spm_rec.update_yn
        ,l_spm_rec.default_value
        ,l_spm_rec.parameter_value
        ,l_spm_rec.prc_eng_ident
        ,l_spm_rec.description
        ,l_spm_rec.created_by
        ,l_spm_rec.creation_date
        ,l_spm_rec.last_updated_by
        ,l_spm_rec.last_update_date
        ,l_spm_rec.last_update_login;

    x_no_data_found := okl_sif_pricing_params_pk_csr%NOTFOUND;
    CLOSE okl_sif_pricing_params_pk_csr;

    RETURN(l_spm_rec);

  END get_rec;

  FUNCTION get_rec (
    p_spm_rec                      IN spm_rec_type
  ) RETURN spm_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_spm_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_PRICING_PARAMS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_spmv_rec                     IN  spmv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN spmv_rec_type IS
    CURSOR okl_spmv_pk_csr (p_id                 IN NUMBER) IS
    SELECT   ID
            ,OBJECT_VERSION_NUMBER
            ,SIF_ID
            ,KHR_ID
            ,NAME
            ,DISPLAY_YN
            ,UPDATE_YN

            ,DEFAULT_VALUE
            ,PARAMETER_VALUE
            ,PRC_ENG_IDENT
            ,DESCRIPTION
            ,CREATED_BY
            ,CREATION_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATE_LOGIN
    FROM  OKL_SIF_PRICING_PARAMS_V
    WHERE OKL_SIF_PRICING_PARAMS_V.ID = p_id;

    l_okl_spmv_pk                  okl_spmv_pk_csr%ROWTYPE;
    l_spmv_rec                     spmv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_spmv_pk_csr (p_spmv_rec.id);
    FETCH okl_spmv_pk_csr INTO
        l_spmv_rec.id
        ,l_spmv_rec.object_version_number
        ,l_spmv_rec.sif_id
        ,l_spmv_rec.khr_id
        ,l_spmv_rec.name
        ,l_spmv_rec.display_yn
        ,l_spmv_rec.update_yn
        ,l_spmv_rec.default_value
        ,l_spmv_rec.parameter_value
        ,l_spmv_rec.prc_eng_ident
        ,l_spmv_rec.description
        ,l_spmv_rec.created_by
        ,l_spmv_rec.creation_date
        ,l_spmv_rec.last_updated_by
        ,l_spmv_rec.last_update_date
        ,l_spmv_rec.last_update_login;

        x_no_data_found := okl_spmv_pk_csr%NOTFOUND;
    CLOSE okl_spmv_pk_csr;
    RETURN(l_spmv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_spmv_rec                     IN spmv_rec_type
  ) RETURN spmv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_spmv_rec, l_row_notfound));
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
    p_spmv_rec IN spmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status              VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
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
    p_spmv_rec      IN   spmv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS


  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_spmv_rec.id = Okl_Api.G_MISS_NUM OR
       p_spmv_rec.id IS NULL
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
    p_spmv_rec      IN   spmv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_spmv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_spmv_rec.object_version_number IS NULL
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
  -- PROCEDURE validate_khr_id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_khr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE validate_khr_id(
    p_spmv_rec      IN   spmv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_spmv_rec.khr_id = Okl_Api.G_MISS_NUM OR
       p_spmv_rec.khr_id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'khr_id');
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

  END validate_khr_id;

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
    p_spmv_rec IN  spmv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
    -- Validate_Id
    Validate_Id(p_spmv_rec, x_return_status);
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
    validate_object_version_number(p_spmv_rec, x_return_status);
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

    -- Validate_khr_id
    validate_khr_id(p_spmv_rec, x_return_status);
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
    p_spmv_rec	IN spmv_rec_type
  ) RETURN spmv_rec_type IS
    l_spmv_rec	spmv_rec_type := p_spmv_rec;
  BEGIN
    IF (l_spmv_rec.id = Okl_Api.G_MISS_NUM) THEN
        l_spmv_rec.id := NULL;
    END IF;
    IF (l_spmv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
        l_spmv_rec.object_version_number := NULL;
    END IF;
    IF (l_spmv_rec.khr_id = Okl_Api.G_MISS_NUM) THEN
        l_spmv_rec.khr_id := NULL;
    END IF;
    IF (l_spmv_rec.sif_id = Okl_Api.G_MISS_NUM) THEN
        l_spmv_rec.sif_id := NULL;
    END IF;
    IF (l_spmv_rec.name = Okl_Api.G_MISS_CHAR) THEN
        l_spmv_rec.name := NULL;
    END IF;
    IF (l_spmv_rec.display_yn = Okl_Api.G_MISS_CHAR) THEN
        l_spmv_rec.display_yn := NULL;
    END IF;
    IF (l_spmv_rec.update_yn = Okl_Api.G_MISS_CHAR) THEN
        l_spmv_rec.update_yn := NULL;
    END IF;
    IF (l_spmv_rec.default_value = Okl_Api.G_MISS_CHAR) THEN
        l_spmv_rec.default_value := NULL;
    END IF;
    IF (l_spmv_rec.parameter_value = Okl_Api.G_MISS_CHAR) THEN
        l_spmv_rec.parameter_value := NULL;
    END IF;
    IF (l_spmv_rec.prc_eng_ident = Okl_Api.G_MISS_CHAR) THEN
        l_spmv_rec.prc_eng_ident := NULL;
    END IF;
    IF (l_spmv_rec.description = Okl_Api.G_MISS_CHAR) THEN
        l_spmv_rec.description := NULL;
    END IF;
    IF (l_spmv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
        l_spmv_rec.created_by := NULL;
    END IF;
    IF (l_spmv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
        l_spmv_rec.creation_date := NULL;
    END IF;
    IF (l_spmv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
        l_spmv_rec.last_updated_by := NULL;
    END IF;
    IF (l_spmv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
        l_spmv_rec.last_update_date := NULL;
    END IF;
    IF (l_spmv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
        l_spmv_rec.last_update_login := NULL;
    END IF;

    RETURN(l_spmv_rec);
  END null_out_defaults;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN spm_rec_type,
    p_to	IN OUT NOCOPY spmv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.khr_id := p_from.khr_id;
    p_to.sif_id := p_from.sif_id;
    p_to.name := p_from.name;
    p_to.display_yn := p_from.display_yn;
    p_to.update_yn := p_from.update_yn;
    p_to.default_value := p_from.default_value;
    p_to.parameter_value := p_from.parameter_value;
    p_to.prc_eng_ident := p_from.prc_eng_ident;
    p_to.description := p_from.description;
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
    p_from	IN spmv_rec_type,
    p_to	IN OUT NOCOPY spm_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.khr_id := p_from.khr_id;
    p_to.sif_id := p_from.sif_id;
    p_to.name := p_from.name;
    p_to.display_yn := p_from.display_yn;
    p_to.update_yn := p_from.update_yn;
    p_to.default_value := p_from.default_value;
    p_to.parameter_value := p_from.parameter_value;
    p_to.prc_eng_ident := p_from.prc_eng_ident;
    p_to.description := p_from.description;
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
  --                   table OKL_SIF_PRICING_PARAMS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spm_rec                      IN spm_rec_type) AS

    -- Local Variables within the function
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_spm_rec                     spm_rec_type := p_spm_rec;
    l_def_spm_rec                 spm_rec_type;

    ---------------------------------------------
    -- Set_Attributes for:OKL_SIF_PRICING_PARAMS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_spm_rec IN  spm_rec_type,
      x_spm_rec OUT NOCOPY spm_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_spm_rec := p_spm_rec;
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
      p_spm_rec,    -- IN
      l_spm_rec     -- OUT
    );
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_SIF_PRICING_PARAMS(
        ID
        ,OBJECT_VERSION_NUMBER
        ,SIF_ID
        ,KHR_ID
        ,NAME
        ,DISPLAY_YN
        ,UPDATE_YN
        ,DEFAULT_VALUE
        ,PARAMETER_VALUE
        ,PRC_ENG_IDENT
        ,DESCRIPTION
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        )
    VALUES (
         l_spm_rec.id
        ,l_spm_rec.object_version_number
        ,l_spm_rec.sif_id
        ,l_spm_rec.khr_id
        ,l_spm_rec.name
        ,l_spm_rec.display_yn
        ,l_spm_rec.update_yn
        ,l_spm_rec.default_value
        ,l_spm_rec.parameter_value
        ,l_spm_rec.prc_eng_ident
        ,l_spm_rec.description
        ,l_spm_rec.created_by
        ,l_spm_rec.creation_date
        ,l_spm_rec.last_updated_by
        ,l_spm_rec.last_update_date
        ,l_spm_rec.last_update_login
    );

    -- Set OUT values
    --x_spm_rec := l_spm_rec;
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

  ----------------------------------------
  -- PL/SQL TBL insert_row for: SPMV_REC --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spmv_rec                     IN  spmv_rec_type) AS


    -- Local Variables within the function
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_spmv_rec                     spmv_rec_type;
    l_def_spmv_rec                 spmv_rec_type;
    l_spm_rec                      spm_rec_type;
    lx_spm_rec                     spm_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_spmv_rec	IN spmv_rec_type
    ) RETURN spmv_rec_type IS
      l_spmv_rec	spmv_rec_type := p_spmv_rec;
    BEGIN
      l_spmv_rec.CREATION_DATE := SYSDATE;
      l_spmv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_spmv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_spmv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_spmv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_spmv_rec);
    END fill_who_columns;

    -----------------------------------------------
    -- Set_Attributes for:OKL_SIF_PRICING_PARAMS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_spmv_rec IN  spmv_rec_type,
      x_spmv_rec OUT NOCOPY spmv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_spmv_rec := p_spmv_rec;
      x_spmv_rec.OBJECT_VERSION_NUMBER := 1;

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

    l_spmv_rec := null_out_defaults(p_spmv_rec);

    -- Set primary key value
    l_spmv_rec.ID := get_seq_id;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_spmv_rec,                        -- IN
      l_def_spmv_rec);                   -- OUT


    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- fill who columns for the l_def_spmv_rec
    l_def_spmv_rec := fill_who_columns(l_def_spmv_rec);

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_spmv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Perfrom all row level validations
    l_return_status := validate_record(l_def_spmv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_spmv_rec, l_spm_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------


    insert_row (
      p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data
      ,p_spm_rec => l_spm_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_spm_rec, l_def_spmv_rec);

    -- Set OUT values
    --x_spmv_rec := l_def_spmv_rec;
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
  -- PL/SQL TBL insert_row for: SPMV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spmv_tbl                     IN  spmv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status 		       VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);

    -- Making sure PL/SQL table has records in it before passing
    IF (p_spmv_tbl.COUNT > 0) THEN
      i := p_spmv_tbl.FIRST;
      LOOP

        insert_row (
          p_api_version                  => l_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_spmv_rec                     => p_spmv_tbl(i));

    	-- store the highest degree of error
    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
        EXIT WHEN (i = p_spmv_tbl.LAST);
        i := p_spmv_tbl.NEXT(i);
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
  --                   table OKL_SIF_PRICING_PARAMS
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
    p_spm_rec                      IN  spm_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_spm_rec                      spm_rec_type := p_spm_rec;
    l_def_spm_rec                  spm_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_spm_rec	IN  spm_rec_type,
      x_spm_rec	OUT NOCOPY spm_rec_type
    ) RETURN VARCHAR2 IS
      l_spm_rec                      spm_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_spm_rec := p_spm_rec;

      -- Get current database values
      l_spm_rec := get_rec( p_spm_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_spm_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_spm_rec.id := l_spm_rec.id;
      END IF;
      IF (x_spm_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_spm_rec.object_version_number := l_spm_rec.object_version_number;
      END IF;
      IF (x_spm_rec.khr_id = Okl_Api.G_MISS_NUM)
      THEN
        x_spm_rec.khr_id := l_spm_rec.khr_id;
      END IF;
      IF (x_spm_rec.sif_id = Okl_Api.G_MISS_NUM)
      THEN
        x_spm_rec.sif_id := l_spm_rec.sif_id;
      END IF;
      IF (x_spm_rec.name = Okl_Api.G_MISS_CHAR) THEN
        x_spm_rec.name := l_spm_rec.name;
      END IF;
      IF (x_spm_rec.display_yn = Okl_Api.G_MISS_CHAR) THEN
        x_spm_rec.display_yn := l_spm_rec.display_yn;
      END IF;
      IF (x_spm_rec.update_yn = Okl_Api.G_MISS_CHAR) THEN
        x_spm_rec.update_yn := l_spm_rec.update_yn;
      END IF;
      IF (x_spm_rec.default_value = Okl_Api.G_MISS_CHAR) THEN

        x_spm_rec.default_value := l_spm_rec.default_value;
      END IF;
      IF (x_spm_rec.parameter_value = Okl_Api.G_MISS_CHAR) THEN
        x_spm_rec.parameter_value := l_spm_rec.parameter_value;
      END IF;
      IF (x_spm_rec.prc_eng_ident = Okl_Api.G_MISS_CHAR) THEN
        x_spm_rec.prc_eng_ident := l_spm_rec.prc_eng_ident;
      END IF;
      IF (x_spm_rec.description = Okl_Api.G_MISS_CHAR) THEN
        x_spm_rec.description := l_spm_rec.description;
      END IF;
      IF (x_spm_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_spm_rec.created_by := l_spm_rec.created_by;
      END IF;
      IF (x_spm_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_spm_rec.creation_date := l_spm_rec.creation_date;
      END IF;
      IF (x_spm_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_spm_rec.last_updated_by := l_spm_rec.last_updated_by;
      END IF;
      IF (x_spm_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_spm_rec.last_update_date := l_spm_rec.last_update_date;
      END IF;
      IF (x_spm_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_spm_rec.last_update_login := l_spm_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;

    ---------------------------------------------
    -- Set_Attributes for:OKL_SIF_PRICING_PARAMS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_spm_rec IN  spm_rec_type,
      x_spm_rec OUT NOCOPY spm_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_spm_rec := p_spm_rec;
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
      p_spm_rec,                         -- IN
      l_spm_rec);                        -- OUT

    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_spm_rec, l_def_spm_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    UPDATE OKL_SIF_PRICING_PARAMS
    SET ID                      = l_def_spm_rec.id
        ,OBJECT_VERSION_NUMBER  = l_def_spm_rec.object_version_number
        ,SIF_ID                 = l_def_spm_rec.sif_id
        ,KHR_ID                 = l_def_spm_rec.khr_id
        ,NAME                   = l_def_spm_rec.name
        ,DISPLAY_YN             = l_def_spm_rec.display_yn
        ,UPDATE_YN              = l_def_spm_rec.update_yn
        ,DEFAULT_VALUE          = l_def_spm_rec.default_value
        ,PARAMETER_VALUE        = l_def_spm_rec.parameter_value
        ,PRC_ENG_IDENT          = l_def_spm_rec.prc_eng_ident
        ,DESCRIPTION            = l_def_spm_rec.description
        ,CREATED_BY             = l_def_spm_rec.created_by
        ,CREATION_DATE          = l_def_spm_rec.creation_date
        ,LAST_UPDATED_BY        = l_def_spm_rec.last_updated_by
        ,LAST_UPDATE_DATE       = l_def_spm_rec.last_update_date
        ,LAST_UPDATE_LOGIN      = l_def_spm_rec.last_update_login
    WHERE ID = l_def_spm_rec.id;

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

  -------------------------------------------------------
  -- PL/SQL TBL update_row for: OKL_SIF_PRICING_PARAMS --
  -------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spmv_rec                     IN  spmv_rec_type)  IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_spmv_rec                     spmv_rec_type := p_spmv_rec;
    l_def_spmv_rec                 spmv_rec_type;
    l_spm_rec                      spm_rec_type;
    lx_spm_rec                     spm_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_spmv_rec	IN spmv_rec_type
    ) RETURN spmv_rec_type IS
      l_spmv_rec	spmv_rec_type := p_spmv_rec;
    BEGIN
      l_spmv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_spmv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_spmv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_spmv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_spmv_rec	IN  spmv_rec_type,
      x_spmv_rec	OUT NOCOPY spmv_rec_type
    ) RETURN VARCHAR2 IS
      l_spmv_rec                      spmv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_spmv_rec := p_spmv_rec;

      -- Get current database values
      l_spmv_rec := get_rec(p_spmv_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_spmv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_spmv_rec.id := l_spm_rec.id;
      END IF;
      IF (x_spmv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_spmv_rec.object_version_number := l_spmv_rec.object_version_number;
      END IF;
      IF (x_spmv_rec.khr_id = Okl_Api.G_MISS_NUM)
      THEN
        x_spmv_rec.khr_id := l_spmv_rec.khr_id;
      END IF;
      IF (x_spmv_rec.sif_id = Okl_Api.G_MISS_NUM)
      THEN
        x_spmv_rec.sif_id := l_spm_rec.sif_id;
      END IF;
      IF (x_spmv_rec.name = Okl_Api.G_MISS_CHAR) THEN
        x_spmv_rec.name := l_spmv_rec.name;
      END IF;
      IF (x_spmv_rec.display_yn = Okl_Api.G_MISS_CHAR) THEN
        x_spmv_rec.display_yn := l_spmv_rec.display_yn;
      END IF;
            IF (x_spmv_rec.update_yn = Okl_Api.G_MISS_CHAR) THEN

        x_spmv_rec.update_yn := l_spmv_rec.update_yn;
      END IF;
      IF (x_spmv_rec.default_value = Okl_Api.G_MISS_CHAR) THEN
        x_spmv_rec.default_value := l_spmv_rec.default_value;
      END IF;
      IF (x_spmv_rec.parameter_value = Okl_Api.G_MISS_CHAR) THEN
        x_spmv_rec.parameter_value := l_spmv_rec.parameter_value;
      END IF;
      IF (x_spmv_rec.prc_eng_ident = Okl_Api.G_MISS_CHAR) THEN
        x_spmv_rec.prc_eng_ident := l_spmv_rec.prc_eng_ident;
      END IF;
      IF (x_spmv_rec.description = Okl_Api.G_MISS_CHAR) THEN
        x_spmv_rec.description := l_spmv_rec.description;
      END IF;
      IF (x_spmv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_spmv_rec.created_by := l_spmv_rec.created_by;
      END IF;
      IF (x_spmv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_spmv_rec.creation_date := l_spmv_rec.creation_date;
      END IF;
      IF (x_spmv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_spmv_rec.last_updated_by := l_spmv_rec.last_updated_by;
      END IF;
      IF (x_spmv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_spmv_rec.last_update_date := l_spmv_rec.last_update_date;
      END IF;
      IF (x_spmv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_spmv_rec.last_update_login := l_spmv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for: OKL_ST_GEN_PRC_PARAMS_v --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_spmv_rec IN  spmv_rec_type,
      x_spmv_rec OUT NOCOPY spmv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_spmv_rec := p_spmv_rec;
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
      p_spmv_rec,                        -- IN
      l_spmv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_spmv_rec, l_def_spmv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_spmv_rec := fill_who_columns(l_def_spmv_rec);

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_spmv_rec);

    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_spmv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records

    --------------------------------------
    migrate(l_def_spmv_rec, l_spm_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_spm_rec => l_spm_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_spm_rec, l_def_spmv_rec);

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
  -- PL/SQL TBL update_row for:OKL_SIF_PRICING_PARAMS_V --
  -------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spmv_tbl                     IN  spmv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    l_overall_status 		  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_spmv_tbl.COUNT > 0) THEN
      i := p_spmv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => l_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_spmv_rec                     => p_spmv_tbl(i));

    	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;

        EXIT WHEN (i = p_spmv_tbl.LAST);
        i := p_spmv_tbl.NEXT(i);
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

END;  -- Package OKL_spm_PVT

/
