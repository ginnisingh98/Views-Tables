--------------------------------------------------------
--  DDL for Package Body OKL_AES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AES_PVT" AS
/* $Header: OKLSAESB.pls 120.6 2007/10/03 13:52:51 prasjain noship $ */
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
  -- FUNCTION get_rec for: OKL_AE_TMPT_SETS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aes_rec                      IN aes_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aes_rec_type IS
    CURSOR okl_ae_tmpt_sets_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            NAME,
            VERSION,
            START_DATE,
            OBJECT_VERSION_NUMBER,
            END_DATE,
            DESCRIPTION,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            GTS_ID
      FROM Okl_Ae_Tmpt_Sets
     WHERE okl_ae_tmpt_sets.id  = p_id;
    l_okl_ae_tmpt_sets_pk          okl_ae_tmpt_sets_pk_csr%ROWTYPE;
    l_aes_rec                      aes_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ae_tmpt_sets_pk_csr (p_aes_rec.id);
    FETCH okl_ae_tmpt_sets_pk_csr INTO
              l_aes_rec.ID,
              l_aes_rec.NAME,
              l_aes_rec.VERSION,
              l_aes_rec.START_DATE,
              l_aes_rec.OBJECT_VERSION_NUMBER,
              l_aes_rec.END_DATE,
              l_aes_rec.DESCRIPTION,
              l_aes_rec.ORG_ID,
              l_aes_rec.CREATED_BY,
              l_aes_rec.CREATION_DATE,
              l_aes_rec.LAST_UPDATED_BY,
              l_aes_rec.LAST_UPDATE_DATE,
              l_aes_rec.LAST_UPDATE_LOGIN,
              l_aes_rec.ORG_ID;
    x_no_data_found := okl_ae_tmpt_sets_pk_csr%NOTFOUND;
    CLOSE okl_ae_tmpt_sets_pk_csr;
    RETURN(l_aes_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aes_rec                      IN aes_rec_type
  ) RETURN aes_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aes_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_AE_TMPT_SETS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aesv_rec                     IN aesv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aesv_rec_type IS
    CURSOR okl_aesv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
            DESCRIPTION,
            VERSION,
            START_DATE,
            END_DATE,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            GTS_ID
      FROM Okl_Ae_Tmpt_Sets_V
     WHERE okl_ae_tmpt_sets_v.id = p_id;
    l_okl_aesv_pk                  okl_aesv_pk_csr%ROWTYPE;
    l_aesv_rec                     aesv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_aesv_pk_csr (p_aesv_rec.id);
    FETCH okl_aesv_pk_csr INTO
              l_aesv_rec.ID,
              l_aesv_rec.OBJECT_VERSION_NUMBER,
              l_aesv_rec.NAME,
              l_aesv_rec.DESCRIPTION,
              l_aesv_rec.VERSION,
              l_aesv_rec.START_DATE,
              l_aesv_rec.END_DATE,
              l_aesv_rec.ORG_ID,
              l_aesv_rec.CREATED_BY,
              l_aesv_rec.CREATION_DATE,
              l_aesv_rec.LAST_UPDATED_BY,
              l_aesv_rec.LAST_UPDATE_DATE,
              l_aesv_rec.LAST_UPDATE_LOGIN,
              l_aesv_rec.GTS_ID;
    x_no_data_found := okl_aesv_pk_csr%NOTFOUND;
    CLOSE okl_aesv_pk_csr;
    RETURN(l_aesv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aesv_rec                     IN aesv_rec_type
  ) RETURN aesv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aesv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_AE_TMPT_SETS_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_aesv_rec	IN aesv_rec_type
  ) RETURN aesv_rec_type IS
    l_aesv_rec	aesv_rec_type := p_aesv_rec;
  BEGIN
    IF (l_aesv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_aesv_rec.object_version_number := NULL;
    END IF;
    IF (l_aesv_rec.name = Okc_Api.G_MISS_CHAR) THEN
      l_aesv_rec.name := NULL;
    END IF;
    IF (l_aesv_rec.description = Okc_Api.G_MISS_CHAR) THEN
      l_aesv_rec.description := NULL;
    END IF;
    IF (l_aesv_rec.version = Okc_Api.G_MISS_CHAR) THEN
      l_aesv_rec.version := NULL;
    END IF;
    IF (l_aesv_rec.start_date = Okc_Api.G_MISS_DATE) THEN
      l_aesv_rec.start_date := NULL;
    END IF;
    IF (l_aesv_rec.end_date = Okc_Api.G_MISS_DATE) THEN
      l_aesv_rec.end_date := NULL;
    END IF;
    IF (l_aesv_rec.org_id = Okc_Api.G_MISS_NUM) THEN
      l_aesv_rec.org_id := NULL;
    END IF;
    IF (l_aesv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_aesv_rec.created_by := NULL;
    END IF;
    IF (l_aesv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_aesv_rec.creation_date := NULL;
    END IF;
    IF (l_aesv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_aesv_rec.last_updated_by := NULL;
    END IF;
    IF (l_aesv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_aesv_rec.last_update_date := NULL;
    END IF;
    IF (l_aesv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_aesv_rec.last_update_login := NULL;
    END IF;
    IF (l_aesv_rec.gts_id = Okc_Api.G_MISS_NUM) THEN
      l_aesv_rec.gts_id := NULL;
    END IF;
    RETURN(l_aesv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  --04-18-2001 HKPATEL PROCEDURE FOR VALIDATING END DATE
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Enddate(p_aesv_rec IN  aesv_rec_type, x_return_status OUT NOCOPY VARCHAR2)
  IS
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_aesv_rec.end_date IS NOT NULL ) AND
       (p_aesv_rec.end_date <> OKC_API.G_MISS_DATE) THEN
    IF(p_aesv_rec.end_date  ) < (p_aesv_rec.start_date )
      THEN
        Okc_Api.set_message(G_APP_NAME,
				    G_INVALID_VALUE,
				    G_COL_NAME_TOKEN,
				    'end_date');

        x_return_status := Okc_Api.G_RET_STS_ERROR;
	  RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    END IF;

  EXCEPTION
    WHEN    G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

    WHEN OTHERS THEN
      Okc_Api.set_message(G_APP_NAME,
			        G_UNEXPECTED_ERROR,
				  G_SQLCODE_TOKEN,
				  SQLCODE,
				  G_SQLERRM_TOKEN,
				  SQLERRM);

      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Enddate;


  ------------------------------------------------
  -- Validate_Attributes for:OKL_AE_TMPT_SETS_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_aesv_rec IN  aesv_rec_type
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

    l_enddate_status	VARCHAR2(1);

  BEGIN
    IF p_aesv_rec.id = Okc_Api.G_MISS_NUM OR
       p_aesv_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

    IF p_aesv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
          p_aesv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

    IF p_aesv_rec.name = Okc_Api.G_MISS_CHAR OR
          p_aesv_rec.name IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

    IF p_aesv_rec.version = Okc_Api.G_MISS_CHAR OR
          p_aesv_rec.version IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'version');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

    IF p_aesv_rec.start_date = Okc_Api.G_MISS_DATE OR
          p_aesv_rec.start_date IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'start_date');
      l_return_status := Okc_Api.G_RET_STS_ERROR;

    END IF;

    VALIDATE_ENDDATE(p_aesv_rec, x_return_status );

    IF (x_return_Status = OKC_API.G_RET_STS_ERROR) THEN
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

    RETURN(l_return_status);

    EXCEPTION
    WHEN    G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
    RETURN (l_return_status);
    WHEN OTHERS THEN
      Okc_Api.set_message(G_APP_NAME,G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
	RETURN(l_return_status);


  END Validate_Attributes;

  ----------------------------------------------------------------------------
  -- 04-17-2001 HKPATEL  UNIQUE KEY VALIDATION
  ----------------------------------------------------------------------------
    FUNCTION Validate_UniqueKey(p_aesv_rec IN  aesv_rec_type)
    RETURN VARCHAR2 IS
    l_return_status   VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

    l_dummy_count NUMBER;
    l_row_found                 BOOLEAN := TRUE;

    CURSOR l_namever_csr
    IS
    SELECT '1'
    FROM Okl_Ae_Tmpt_Sets_V
    WHERE name    = trim(p_aesv_rec.name) -- trim added by prasjain for bug# 6439908
    AND   version = p_aesv_rec.version
    AND   ID <> p_aesv_rec.ID;

    BEGIN
      OPEN l_namever_csr ;
        FETCH l_namever_csr INTO l_dummy_count ;
	  l_row_found := l_namever_csr%FOUND;

      CLOSE l_namever_csr;
	IF (l_row_found) THEN

        Okl_Api.set_message(OKL_API.G_APP_NAME,G_UNQS);
        l_return_status := Okc_Api.G_RET_STS_ERROR;
	  RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    RETURN (l_return_status);

    EXCEPTION
    WHEN    G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
    RETURN (l_return_status);
    WHEN OTHERS THEN
      Okc_Api.set_message(G_APP_NAME,G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      return(l_return_status);


    END Validate_UniqueKey;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_AE_TMPT_SETS_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_aesv_rec IN  aesv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status   VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

    BEGIN
    l_return_status := Validate_UniqueKey(p_aesv_rec);
    RETURN (l_return_status);
    END Validate_Record;



  ---------------------------------------------------------------------------


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN aesv_rec_type,
    p_to	OUT NOCOPY aes_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.version := p_from.version;
    p_to.start_date := p_from.start_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.end_date := p_from.end_date;
    p_to.description := p_from.description;
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.gts_id := p_from.gts_id;
  END migrate;
  PROCEDURE migrate (
    p_from	IN aes_rec_type,
    p_to	OUT NOCOPY aesv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.version := p_from.version;
    p_to.start_date := p_from.start_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.end_date := p_from.end_date;
    p_to.description := p_from.description;
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.gts_id := p_from.gts_id;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_AE_TMPT_SETS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aesv_rec                     aesv_rec_type := p_aesv_rec;
    l_aes_rec                      aes_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_aesv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_aesv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
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
  -- PL/SQL TBL validate_row for:AESV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aesv_tbl.COUNT > 0) THEN
      i := p_aesv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aesv_rec                     => p_aesv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

        EXIT WHEN (i = p_aesv_tbl.LAST);
        i := p_aesv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
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
  -------------------------------------
  -- insert_row for:OKL_AE_TMPT_SETS --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aes_rec                      IN aes_rec_type,
    x_aes_rec                      OUT NOCOPY aes_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SETS_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aes_rec                      aes_rec_type := p_aes_rec;
    l_def_aes_rec                  aes_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_AE_TMPT_SETS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_aes_rec IN  aes_rec_type,
      x_aes_rec OUT NOCOPY aes_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aes_rec := p_aes_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_aes_rec,                         -- IN
      l_aes_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_AE_TMPT_SETS(
        id,
        name,
        version,
        start_date,
        object_version_number,
        end_date,
        description,
        org_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        gts_id)
      VALUES (
        l_aes_rec.id,
        trim(l_aes_rec.name), -- trim added by prasjain for bug# 6439908
        l_aes_rec.version,
        l_aes_rec.start_date,
        l_aes_rec.object_version_number,
        l_aes_rec.end_date,
        l_aes_rec.description,
        l_aes_rec.org_id,
        l_aes_rec.created_by,
        l_aes_rec.creation_date,
        l_aes_rec.last_updated_by,
        l_aes_rec.last_update_date,
        l_aes_rec.last_update_login,
        l_aes_rec.gts_id);
    -- Set OUT values
    x_aes_rec := l_aes_rec;
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
  ---------------------------------------
  -- insert_row for:OKL_AE_TMPT_SETS_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type,
    x_aesv_rec                     OUT NOCOPY aesv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aesv_rec                     aesv_rec_type;
    l_def_aesv_rec                 aesv_rec_type;
    l_aes_rec                      aes_rec_type;
    lx_aes_rec                     aes_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aesv_rec	IN aesv_rec_type
    ) RETURN aesv_rec_type IS
      l_aesv_rec	aesv_rec_type := p_aesv_rec;
    BEGIN
      l_aesv_rec.CREATION_DATE := SYSDATE;
      l_aesv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_aesv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aesv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_aesv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_aesv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_AE_TMPT_SETS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_aesv_rec IN  aesv_rec_type,
      x_aesv_rec OUT NOCOPY aesv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aesv_rec := p_aesv_rec;
      x_aesv_rec.OBJECT_VERSION_NUMBER := 1;
      x_aesv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();
      x_aesv_rec.NAME := upper(x_aesv_rec.NAME);
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
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_aesv_rec := null_out_defaults(p_aesv_rec);
    -- Set primary key value
    l_aesv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_aesv_rec,                        -- IN
      l_def_aesv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_aesv_rec := fill_who_columns(l_def_aesv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aesv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aesv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aesv_rec, l_aes_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aes_rec,
      lx_aes_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aes_rec, l_def_aesv_rec);
    -- Set OUT values
    x_aesv_rec := l_def_aesv_rec;
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
  -- PL/SQL TBL insert_row for:AESV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type,
    x_aesv_tbl                     OUT NOCOPY aesv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aesv_tbl.COUNT > 0) THEN
      i := p_aesv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aesv_rec                     => p_aesv_tbl(i),
          x_aesv_rec                     => x_aesv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_aesv_tbl.LAST);
        i := p_aesv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;

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
  -----------------------------------
  -- lock_row for:OKL_AE_TMPT_SETS --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aes_rec                      IN aes_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_aes_rec IN aes_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AE_TMPT_SETS
     WHERE ID = p_aes_rec.id
       AND OBJECT_VERSION_NUMBER = p_aes_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_aes_rec IN aes_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AE_TMPT_SETS
    WHERE ID = p_aes_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SETS_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_AE_TMPT_SETS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_AE_TMPT_SETS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_aes_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_aes_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_aes_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_aes_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okc_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
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
  -------------------------------------
  -- lock_row for:OKL_AE_TMPT_SETS_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aes_rec                      aes_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_aesv_rec, l_aes_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aes_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
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
  -- PL/SQL TBL lock_row for:AESV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aesv_tbl.COUNT > 0) THEN
      i := p_aesv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aesv_rec                     => p_aesv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_aesv_tbl.LAST);
        i := p_aesv_tbl.NEXT(i);
      END LOOP;
    END IF;
        x_return_status := l_overall_status;

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
  -------------------------------------
  -- update_row for:OKL_AE_TMPT_SETS --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aes_rec                      IN aes_rec_type,
    x_aes_rec                      OUT NOCOPY aes_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SETS_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aes_rec                      aes_rec_type := p_aes_rec;
    l_def_aes_rec                  aes_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aes_rec	IN aes_rec_type,
      x_aes_rec	OUT NOCOPY aes_rec_type
    ) RETURN VARCHAR2 IS
      l_aes_rec                      aes_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aes_rec := p_aes_rec;
      -- Get current database values
      l_aes_rec := get_rec(p_aes_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aes_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_aes_rec.id := l_aes_rec.id;
      END IF;
      IF (x_aes_rec.name = Okc_Api.G_MISS_CHAR)
      THEN
        x_aes_rec.name := l_aes_rec.name;
      END IF;
      IF (x_aes_rec.version = Okc_Api.G_MISS_CHAR)
      THEN
        x_aes_rec.version := l_aes_rec.version;
      END IF;
      IF (x_aes_rec.start_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aes_rec.start_date := l_aes_rec.start_date;
      END IF;
      IF (x_aes_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_aes_rec.object_version_number := l_aes_rec.object_version_number;
      END IF;
      IF (x_aes_rec.end_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aes_rec.end_date := l_aes_rec.end_date;
      END IF;
      IF (x_aes_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_aes_rec.description := l_aes_rec.description;
      END IF;
      IF (x_aes_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aes_rec.org_id := l_aes_rec.org_id;
      END IF;
      IF (x_aes_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aes_rec.created_by := l_aes_rec.created_by;
      END IF;
      IF (x_aes_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aes_rec.creation_date := l_aes_rec.creation_date;
      END IF;
      IF (x_aes_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aes_rec.last_updated_by := l_aes_rec.last_updated_by;
      END IF;
      IF (x_aes_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aes_rec.last_update_date := l_aes_rec.last_update_date;
      END IF;
      IF (x_aes_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_aes_rec.last_update_login := l_aes_rec.last_update_login;
      END IF;
      IF (x_aes_rec.gts_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aes_rec.gts_id := l_aes_rec.gts_id;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_AE_TMPT_SETS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_aes_rec IN  aes_rec_type,
      x_aes_rec OUT NOCOPY aes_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aes_rec := p_aes_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_aes_rec,                         -- IN
      l_aes_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aes_rec, l_def_aes_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_AE_TMPT_SETS
    SET NAME = l_def_aes_rec.name,
        VERSION = l_def_aes_rec.version,
        START_DATE = l_def_aes_rec.start_date,
        OBJECT_VERSION_NUMBER = l_def_aes_rec.object_version_number,
        END_DATE = l_def_aes_rec.end_date,
        DESCRIPTION = l_def_aes_rec.description,
        ORG_ID = l_def_aes_rec.org_id,
        CREATED_BY = l_def_aes_rec.created_by,
        CREATION_DATE = l_def_aes_rec.creation_date,
        LAST_UPDATED_BY = l_def_aes_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_aes_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_aes_rec.last_update_login,
        GTS_ID = l_def_aes_rec.gts_id
    WHERE ID = l_def_aes_rec.id;

    x_aes_rec := l_def_aes_rec;
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
  ---------------------------------------
  -- update_row for:OKL_AE_TMPT_SETS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type,
    x_aesv_rec                     OUT NOCOPY aesv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aesv_rec                     aesv_rec_type := p_aesv_rec;
    l_def_aesv_rec                 aesv_rec_type;
    l_aes_rec                      aes_rec_type;
    lx_aes_rec                     aes_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aesv_rec	IN aesv_rec_type
    ) RETURN aesv_rec_type IS
      l_aesv_rec	aesv_rec_type := p_aesv_rec;
    BEGIN
      l_aesv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aesv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_aesv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_aesv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aesv_rec	IN aesv_rec_type,
      x_aesv_rec	OUT NOCOPY aesv_rec_type
    ) RETURN VARCHAR2 IS
      l_aesv_rec                     aesv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aesv_rec := p_aesv_rec;
      -- Get current database values
      l_aesv_rec := get_rec(p_aesv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aesv_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_aesv_rec.id := l_aesv_rec.id;
      END IF;
      IF (x_aesv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_aesv_rec.object_version_number := l_aesv_rec.object_version_number;
      END IF;
      IF (x_aesv_rec.name = Okc_Api.G_MISS_CHAR)
      THEN
        x_aesv_rec.name := l_aesv_rec.name;
      END IF;
      IF (x_aesv_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_aesv_rec.description := l_aesv_rec.description;
      END IF;
      IF (x_aesv_rec.version = Okc_Api.G_MISS_CHAR)
      THEN
        x_aesv_rec.version := l_aesv_rec.version;
      END IF;
      IF (x_aesv_rec.start_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aesv_rec.start_date := l_aesv_rec.start_date;
      END IF;
      IF (x_aesv_rec.end_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aesv_rec.end_date := l_aesv_rec.end_date;
      END IF;
      IF (x_aesv_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aesv_rec.org_id := l_aesv_rec.org_id;
      END IF;
      IF (x_aesv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aesv_rec.created_by := l_aesv_rec.created_by;
      END IF;
      IF (x_aesv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aesv_rec.creation_date := l_aesv_rec.creation_date;
      END IF;
      IF (x_aesv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_aesv_rec.last_updated_by := l_aesv_rec.last_updated_by;
      END IF;
      IF (x_aesv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_aesv_rec.last_update_date := l_aesv_rec.last_update_date;
      END IF;
      IF (x_aesv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_aesv_rec.last_update_login := l_aesv_rec.last_update_login;
      END IF;
      IF (x_aesv_rec.gts_id = Okc_Api.G_MISS_NUM)
      THEN
        x_aesv_rec.gts_id := l_aesv_rec.gts_id;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_AE_TMPT_SETS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_aesv_rec IN  aesv_rec_type,
      x_aesv_rec OUT NOCOPY aesv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_aesv_rec := p_aesv_rec;
      x_aesv_rec.OBJECT_VERSION_NUMBER := NVL(x_aesv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_aesv_rec,                        -- IN
      l_aesv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aesv_rec, l_def_aesv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_aesv_rec := fill_who_columns(l_def_aesv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aesv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aesv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aesv_rec, l_aes_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aes_rec,
      lx_aes_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aes_rec, l_def_aesv_rec);
    x_aesv_rec := l_def_aesv_rec;
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
  -- PL/SQL TBL update_row for:AESV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type,
    x_aesv_tbl                     OUT NOCOPY aesv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aesv_tbl.COUNT > 0) THEN
      i := p_aesv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aesv_rec                     => p_aesv_tbl(i),
          x_aesv_rec                     => x_aesv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

        EXIT WHEN (i = p_aesv_tbl.LAST);
        i := p_aesv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_overall_status;

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
  -------------------------------------
  -- delete_row for:OKL_AE_TMPT_SETS --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aes_rec                      IN aes_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SETS_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aes_rec                      aes_rec_type:= p_aes_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_AE_TMPT_SETS
     WHERE ID = l_aes_rec.id;

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
  ---------------------------------------
  -- delete_row for:OKL_AE_TMPT_SETS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aesv_rec                     aesv_rec_type := p_aesv_rec;
    l_aes_rec                      aes_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_aesv_rec, l_aes_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aes_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
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
  -- PL/SQL TBL delete_row for:AESV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aesv_tbl.COUNT > 0) THEN
      i := p_aesv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aesv_rec                     => p_aesv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                l_overall_status := x_return_status;
            END IF;
          END IF;

        EXIT WHEN (i = p_aesv_tbl.LAST);
        i := p_aesv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
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
END Okl_Aes_Pvt;

/
