--------------------------------------------------------
--  DDL for Package Body OKL_IVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IVE_PVT" AS
/* $Header: OKLSIVEB.pls 115.14 2002/11/30 09:15:59 spillaip noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  -- 04/18/2001 Inserted Robin edwin for validate attribute
  ---------------------------------------------------------------------------
    G_EXCEPTION_HALT_VALIDATION EXCEPTION;

    PROCEDURE validate_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_ivev_rec IN ivev_rec_type
    ) IS
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_ivev_rec.id = OKC_API.G_MISS_NUM OR
       p_ivev_rec.id IS NULL
    THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'ID');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
        else
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
       END IF;
      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          null;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_datetime_valid
  -- 04/18/2001 Inserted Robin edwin for validate attribute
  ---------------------------------------------------------------------------
    PROCEDURE validate_datetime_valid(
      x_return_status OUT NOCOPY VARCHAR2,
      p_ivev_rec IN ivev_rec_type
    ) IS

    l_token_value ak_attributes_tl.attribute_label_long%TYPE := NULL;

    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_ivev_rec.datetime_valid = OKC_API.G_MISS_DATE OR
       p_ivev_rec.datetime_valid IS NULL
    THEN

-- Changed by Santonyr 27-Aug-2002 Fixed bug 2475283

         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'Effective From');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
        else
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
       END IF;
      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          null;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_datetime_valid;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_idx_id
  -- 04/18/2001 Inserted Robin edwin for validate attribute
  ---------------------------------------------------------------------------
    PROCEDURE validate_idx_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_ivev_rec IN ivev_rec_type
    ) IS

    l_dummy Varchar2(1) ;

    CURSOR idx_csr(v_idx_id NUMBER) IS
    SELECT '1'
    FROM OKL_INDICES_V
    WHERE id = v_idx_id;

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_ivev_rec.idx_id = OKC_API.G_MISS_NUM) OR
       (p_ivev_rec.idx_id IS NULL) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'IDX_ID');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN idx_csr(p_ivev_rec.IDX_ID);
    FETCH idx_csr INTO l_dummy;
    IF (idx_csr%NOTFOUND) THEN
        OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                            p_msg_name => g_invalid_value,
                            p_token1   => g_col_name_token,
                            p_token1_value => 'IDX_ID');
        x_return_status := OKC_API.G_RET_STS_ERROR;
        CLOSE idx_csr;
        raise G_EXCEPTION_HALT_VALIDATION;
   END IF;
   CLOSE idx_csr;

   EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          null;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_idx_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_value
  -- 04/18/2001 Inserted Robin edwin for validate attribute
  ---------------------------------------------------------------------------
    PROCEDURE validate_value(
      x_return_status OUT NOCOPY VARCHAR2,
      p_ivev_rec IN ivev_rec_type
    ) IS

    l_token_value ak_attributes_tl.attribute_label_long%TYPE := NULL;

    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_ivev_rec.value = OKC_API.G_MISS_NUM) OR
       (p_ivev_rec.value IS NULL)
    THEN

-- Changed by Santonyr 30-Jul-2002 Fixed bug 2475283

         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'Rate(%)');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
    END IF;

    EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          null;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_value;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  -- 04/18/2001 Inserted Robin edwin for validate attribute
  ---------------------------------------------------------------------------
    PROCEDURE validate_object_version_number(
      x_return_status OUT NOCOPY VARCHAR2,
      p_ivev_rec IN ivev_rec_type
    ) IS
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_ivev_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_ivev_rec.object_version_number IS NULL
    THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'OBJECT_VERSION_NUMBER');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
        else
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
       END IF;
      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          null;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_object_version_number;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_unique
  -- Insertd by Kanti on 02/19/2002
  ---------------------------------------------------------------------------
    PROCEDURE validate_unique(
      x_return_status OUT NOCOPY VARCHAR2,
      p_ivev_rec IN ivev_rec_type
    )

    IS

    l_dummy  varchar2(1);

    CURSOR ive_csr(v_idx_id NUMBER,
                   v_datetime_valid DATE,
                   v_id NUMBER) IS
    SELECT '1'
    FROM OKL_INDEX_VALUES_V
    WHERE IDX_ID = v_idx_id
    AND   DATETIME_VALID = v_datetime_valid
    AND   ID <> v_id;

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN ive_csr(p_ivev_rec.idx_id,
                 p_ivev_rec.datetime_valid,
                 p_ivev_rec.id);
    FETCH ive_csr into l_dummy;
    IF (ive_csr%FOUND) THEN

         OKC_API.SET_MESSAGE(p_app_name => OKL_API.g_app_name,
                             p_msg_name => 'OKL_IDX_VALUE_UNIQUE');
         CLOSE ive_csr;
         x_return_status := OKC_API.G_RET_STS_ERROR;
         raise G_EXCEPTION_HALT_VALIDATION;

    END IF;
    CLOSE ive_csr;

    EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          null;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_unique;


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
  -- FUNCTION get_rec for: OKL_INDEX_VALUES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ive_rec                      IN ive_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ive_rec_type IS
    CURSOR okl_index_values_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            DATETIME_VALID,
            IDX_ID,
            VALUE,
            OBJECT_VERSION_NUMBER,
            DATETIME_INVALID,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Index_Values
     WHERE okl_index_values.id  = p_id;
    l_okl_index_values_pk          okl_index_values_pk_csr%ROWTYPE;
    l_ive_rec                      ive_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_index_values_pk_csr (p_ive_rec.id);
    FETCH okl_index_values_pk_csr INTO
              l_ive_rec.ID,
              l_ive_rec.DATETIME_VALID,
              l_ive_rec.IDX_ID,
              l_ive_rec.VALUE,
              l_ive_rec.OBJECT_VERSION_NUMBER,
              l_ive_rec.DATETIME_INVALID,
              l_ive_rec.PROGRAM_ID,
              l_ive_rec.PROGRAM_APPLICATION_ID,
              l_ive_rec.REQUEST_ID,
              l_ive_rec.PROGRAM_UPDATE_DATE,
              l_ive_rec.CREATED_BY,
              l_ive_rec.CREATION_DATE,
              l_ive_rec.LAST_UPDATED_BY,
              l_ive_rec.LAST_UPDATE_DATE,
              l_ive_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_index_values_pk_csr%NOTFOUND;
    CLOSE okl_index_values_pk_csr;
    RETURN(l_ive_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ive_rec                      IN ive_rec_type
  ) RETURN ive_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ive_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INDEX_VALUES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ivev_rec                     IN ivev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ivev_rec_type IS
    CURSOR okl_ivev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            IDX_ID,
            VALUE,
            DATETIME_VALID,
            DATETIME_INVALID,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Index_Values_V
     WHERE okl_index_values_v.id = p_id;
    l_okl_ivev_pk                  okl_ivev_pk_csr%ROWTYPE;
    l_ivev_rec                     ivev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ivev_pk_csr (p_ivev_rec.id);
    FETCH okl_ivev_pk_csr INTO
              l_ivev_rec.ID,
              l_ivev_rec.OBJECT_VERSION_NUMBER,
              l_ivev_rec.IDX_ID,
              l_ivev_rec.VALUE,
              l_ivev_rec.DATETIME_VALID,
              l_ivev_rec.DATETIME_INVALID,
              l_ivev_rec.PROGRAM_ID,
              l_ivev_rec.PROGRAM_APPLICATION_ID,
              l_ivev_rec.REQUEST_ID,
              l_ivev_rec.PROGRAM_UPDATE_DATE,
              l_ivev_rec.CREATED_BY,
              l_ivev_rec.CREATION_DATE,
              l_ivev_rec.LAST_UPDATED_BY,
              l_ivev_rec.LAST_UPDATE_DATE,
              l_ivev_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ivev_pk_csr%NOTFOUND;
    CLOSE okl_ivev_pk_csr;
    RETURN(l_ivev_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ivev_rec                     IN ivev_rec_type
  ) RETURN ivev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ivev_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INDEX_VALUES_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ivev_rec	IN ivev_rec_type
  ) RETURN ivev_rec_type IS
    l_ivev_rec	ivev_rec_type := p_ivev_rec;
  BEGIN
    IF (l_ivev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_ivev_rec.object_version_number := NULL;
    END IF;
    IF (l_ivev_rec.idx_id = OKC_API.G_MISS_NUM) THEN
      l_ivev_rec.idx_id := NULL;
    END IF;
    IF (l_ivev_rec.value = OKC_API.G_MISS_NUM) THEN
      l_ivev_rec.value := NULL;
    END IF;
    IF (l_ivev_rec.datetime_valid = OKC_API.G_MISS_DATE) THEN
      l_ivev_rec.datetime_valid := NULL;
    END IF;
    IF (l_ivev_rec.datetime_invalid = OKC_API.G_MISS_DATE) THEN
      l_ivev_rec.datetime_invalid := NULL;
    END IF;
    IF (l_ivev_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_ivev_rec.program_id := NULL;
    END IF;
    IF (l_ivev_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_ivev_rec.program_application_id := NULL;
    END IF;
    IF (l_ivev_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_ivev_rec.request_id := NULL;
    END IF;
    IF (l_ivev_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_ivev_rec.program_update_date := NULL;
    END IF;
    IF (l_ivev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_ivev_rec.created_by := NULL;
    END IF;
    IF (l_ivev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_ivev_rec.creation_date := NULL;
    END IF;
    IF (l_ivev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_ivev_rec.last_updated_by := NULL;
    END IF;
    IF (l_ivev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_ivev_rec.last_update_date := NULL;
    END IF;
    IF (l_ivev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_ivev_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ivev_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_INDEX_VALUES_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_ivev_rec IN  ivev_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -- To validate not null in id column
    validate_id(x_return_status 	=> l_return_status,
			p_ivev_rec 		=> p_ivev_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- To validate not null in datetime_valid column
    validate_datetime_valid(x_return_status 	=> l_return_status,
			    p_ivev_rec 		=> p_ivev_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- To validate not null in idx_id column
    validate_idx_id(x_return_status => l_return_status,
				p_ivev_rec 	=> p_ivev_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- To validate not null in value column
    validate_value(x_return_status 	=> l_return_status,
				p_ivev_rec 	=> p_ivev_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- To validate not null in object_version_number column
    validate_object_version_number(x_return_status 	=> l_return_status,
						p_ivev_rec 		=> p_ivev_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN(x_return_status);

    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.SET_MESSAGE(p_app_name    => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => SQLCODE,
                            p_token2       => g_sqlerrm_token,
                            p_token2_value => SQLERRM);

        --notify caller of an UNEXPECTED error
        x_return_status  := OKC_API.G_RET_STS_UNEXP_ERROR;

        --return status to caller
        return x_return_status;

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_INDEX_VALUES_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_ivev_rec IN ivev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

      validate_unique(l_return_status,
                      p_ivev_rec );

      RETURN l_return_status;

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN ivev_rec_type,
    p_to	IN OUT NOCOPY ive_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.datetime_valid := p_from.datetime_valid;
    p_to.idx_id := p_from.idx_id;
    p_to.value := p_from.value;
    p_to.object_version_number := p_from.object_version_number;
    p_to.datetime_invalid := p_from.datetime_invalid;
    p_to.program_id := p_from.program_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.request_id := p_from.request_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN ive_rec_type,
    p_to	OUT NOCOPY ivev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.datetime_valid := p_from.datetime_valid;
    p_to.idx_id := p_from.idx_id;
    p_to.value := p_from.value;
    p_to.object_version_number := p_from.object_version_number;
    p_to.datetime_invalid := p_from.datetime_invalid;
    p_to.program_id := p_from.program_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.request_id := p_from.request_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_INDEX_VALUES_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivev_rec                     IN ivev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ivev_rec                     ivev_rec_type := p_ivev_rec;
    l_ive_rec                      ive_rec_type;
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
    l_return_status := Validate_Attributes(l_ivev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ivev_rec);
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
  -- PL/SQL TBL validate_row for:IVEV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivev_tbl                     IN ivev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ivev_tbl.COUNT > 0) THEN
      i := p_ivev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ivev_rec                     => p_ivev_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_ivev_tbl.LAST);
        i := p_ivev_tbl.NEXT(i);
      END LOOP;
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
  -------------------------------------
  -- insert_row for:OKL_INDEX_VALUES --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ive_rec                      IN ive_rec_type,
    x_ive_rec                      OUT NOCOPY ive_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALUES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ive_rec                      ive_rec_type := p_ive_rec;
    l_def_ive_rec                  ive_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_INDEX_VALUES --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ive_rec IN  ive_rec_type,
      x_ive_rec OUT NOCOPY ive_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ive_rec := p_ive_rec;
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
      p_ive_rec,                         -- IN
      l_ive_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_INDEX_VALUES(
        id,
        datetime_valid,
        idx_id,
        value,
        object_version_number,
        datetime_invalid,
        program_id,
        program_application_id,
        request_id,
        program_update_date,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_ive_rec.id,
        l_ive_rec.datetime_valid,
        l_ive_rec.idx_id,
        l_ive_rec.value,
        l_ive_rec.object_version_number,
        l_ive_rec.datetime_invalid,
        l_ive_rec.program_id,
        l_ive_rec.program_application_id,
        l_ive_rec.request_id,
        l_ive_rec.program_update_date,
        l_ive_rec.created_by,
        l_ive_rec.creation_date,
        l_ive_rec.last_updated_by,
        l_ive_rec.last_update_date,
        l_ive_rec.last_update_login);
    -- Set OUT values
    x_ive_rec := l_ive_rec;
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
  ---------------------------------------
  -- insert_row for:OKL_INDEX_VALUES_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivev_rec                     IN ivev_rec_type,
    x_ivev_rec                     OUT NOCOPY ivev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ivev_rec                     ivev_rec_type;
    l_def_ivev_rec                 ivev_rec_type;
    l_ive_rec                      ive_rec_type;
    lx_ive_rec                     ive_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ivev_rec	IN ivev_rec_type
    ) RETURN ivev_rec_type IS
      l_ivev_rec	ivev_rec_type := p_ivev_rec;
    BEGIN
      l_ivev_rec.CREATION_DATE := SYSDATE;
      l_ivev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ivev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ivev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ivev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ivev_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_INDEX_VALUES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_ivev_rec IN  ivev_rec_type,
      x_ivev_rec OUT NOCOPY ivev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ivev_rec := p_ivev_rec;
      x_ivev_rec.OBJECT_VERSION_NUMBER := 1;

      SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
           DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
           DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
           DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
      INTO  l_ive_rec.request_id
         ,l_ive_rec.program_application_id
         ,l_ive_rec.program_id
         ,l_ive_rec.program_update_date
      FROM dual;

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
    l_ivev_rec := null_out_defaults(p_ivev_rec);
    -- Set primary key value
    l_ivev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ivev_rec,                        -- IN
      l_def_ivev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ivev_rec := fill_who_columns(l_def_ivev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ivev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ivev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ivev_rec, l_ive_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ive_rec,
      lx_ive_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ive_rec, l_def_ivev_rec);
    -- Set OUT values
    x_ivev_rec := l_def_ivev_rec;
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
  -- PL/SQL TBL insert_row for:IVEV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivev_tbl                     IN ivev_tbl_type,
    x_ivev_tbl                     OUT NOCOPY ivev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ivev_tbl.COUNT > 0) THEN
      i := p_ivev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ivev_rec                     => p_ivev_tbl(i),
          x_ivev_rec                     => x_ivev_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_ivev_tbl.LAST);
        i := p_ivev_tbl.NEXT(i);
      END LOOP;
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
  -----------------------------------
  -- lock_row for:OKL_INDEX_VALUES --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ive_rec                      IN ive_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ive_rec IN ive_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INDEX_VALUES
     WHERE ID = p_ive_rec.id
       AND OBJECT_VERSION_NUMBER = p_ive_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ive_rec IN ive_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INDEX_VALUES
    WHERE ID = p_ive_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALUES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_INDEX_VALUES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_INDEX_VALUES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ive_rec);
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
      OPEN lchk_csr(p_ive_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ive_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ive_rec.object_version_number THEN
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
  -------------------------------------
  -- lock_row for:OKL_INDEX_VALUES_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivev_rec                     IN ivev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ive_rec                      ive_rec_type;
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
    migrate(p_ivev_rec, l_ive_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ive_rec
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
  -- PL/SQL TBL lock_row for:IVEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivev_tbl                     IN ivev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ivev_tbl.COUNT > 0) THEN
      i := p_ivev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ivev_rec                     => p_ivev_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_ivev_tbl.LAST);
        i := p_ivev_tbl.NEXT(i);
      END LOOP;
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
  -------------------------------------
  -- update_row for:OKL_INDEX_VALUES --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ive_rec                      IN ive_rec_type,
    x_ive_rec                      OUT NOCOPY ive_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALUES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ive_rec                      ive_rec_type := p_ive_rec;
    l_def_ive_rec                  ive_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ive_rec	IN ive_rec_type,
      x_ive_rec	OUT NOCOPY ive_rec_type
    ) RETURN VARCHAR2 IS
      l_ive_rec                      ive_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ive_rec := p_ive_rec;
      -- Get current database values
      l_ive_rec := get_rec(p_ive_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ive_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ive_rec.id := l_ive_rec.id;
      END IF;
      IF (x_ive_rec.datetime_valid = OKC_API.G_MISS_DATE)
      THEN
        x_ive_rec.datetime_valid := l_ive_rec.datetime_valid;
      END IF;
      IF (x_ive_rec.idx_id = OKC_API.G_MISS_NUM)
      THEN
        x_ive_rec.idx_id := l_ive_rec.idx_id;
      END IF;
      IF (x_ive_rec.value = OKC_API.G_MISS_NUM)
      THEN
        x_ive_rec.value := l_ive_rec.value;
      END IF;
      IF (x_ive_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ive_rec.object_version_number := l_ive_rec.object_version_number;
      END IF;
      IF (x_ive_rec.datetime_invalid = OKC_API.G_MISS_DATE)
      THEN
        x_ive_rec.datetime_invalid := l_ive_rec.datetime_invalid;
      END IF;
      IF (x_ive_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_ive_rec.program_id := l_ive_rec.program_id;
      END IF;
      IF (x_ive_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_ive_rec.program_application_id := l_ive_rec.program_application_id;
      END IF;
      IF (x_ive_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_ive_rec.request_id := l_ive_rec.request_id;
      END IF;
      IF (x_ive_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ive_rec.program_update_date := l_ive_rec.program_update_date;
      END IF;
      IF (x_ive_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ive_rec.created_by := l_ive_rec.created_by;
      END IF;
      IF (x_ive_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ive_rec.creation_date := l_ive_rec.creation_date;
      END IF;
      IF (x_ive_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ive_rec.last_updated_by := l_ive_rec.last_updated_by;
      END IF;
      IF (x_ive_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ive_rec.last_update_date := l_ive_rec.last_update_date;
      END IF;
      IF (x_ive_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ive_rec.last_update_login := l_ive_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_INDEX_VALUES --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ive_rec IN  ive_rec_type,
      x_ive_rec OUT NOCOPY ive_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ive_rec := p_ive_rec;
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
      p_ive_rec,                         -- IN
      l_ive_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ive_rec, l_def_ive_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKL_INDEX_VALUES
    SET DATETIME_VALID = l_def_ive_rec.datetime_valid,
        IDX_ID = l_def_ive_rec.idx_id,
        VALUE = l_def_ive_rec.value,
        OBJECT_VERSION_NUMBER = l_def_ive_rec.object_version_number,
        DATETIME_INVALID = l_def_ive_rec.datetime_invalid,
        PROGRAM_ID = l_def_ive_rec.program_id,
        PROGRAM_APPLICATION_ID = l_def_ive_rec.program_application_id,
        REQUEST_ID = l_def_ive_rec.request_id,
        PROGRAM_UPDATE_DATE = l_def_ive_rec.program_update_date,
        CREATED_BY = l_def_ive_rec.created_by,
        CREATION_DATE = l_def_ive_rec.creation_date,
        LAST_UPDATED_BY = l_def_ive_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ive_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ive_rec.last_update_login
    WHERE ID = l_def_ive_rec.id;

    x_ive_rec := l_def_ive_rec;
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
  ---------------------------------------
  -- update_row for:OKL_INDEX_VALUES_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivev_rec                     IN ivev_rec_type,
    x_ivev_rec                     OUT NOCOPY ivev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ivev_rec                     ivev_rec_type := p_ivev_rec;
    l_def_ivev_rec                 ivev_rec_type;
    l_ive_rec                      ive_rec_type;
    lx_ive_rec                     ive_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ivev_rec	IN ivev_rec_type
    ) RETURN ivev_rec_type IS
      l_ivev_rec	ivev_rec_type := p_ivev_rec;
    BEGIN
      l_ivev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ivev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ivev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ivev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ivev_rec	IN ivev_rec_type,
      x_ivev_rec	OUT NOCOPY ivev_rec_type
    ) RETURN VARCHAR2 IS
      l_ivev_rec                     ivev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ivev_rec := p_ivev_rec;
      -- Get current database values
      l_ivev_rec := get_rec(p_ivev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ivev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ivev_rec.id := l_ivev_rec.id;
      END IF;
      IF (x_ivev_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ivev_rec.object_version_number := l_ivev_rec.object_version_number;
      END IF;
      IF (x_ivev_rec.idx_id = OKC_API.G_MISS_NUM)
      THEN
        x_ivev_rec.idx_id := l_ivev_rec.idx_id;
      END IF;
      IF (x_ivev_rec.value = OKC_API.G_MISS_NUM)
      THEN
        x_ivev_rec.value := l_ivev_rec.value;
      END IF;
      IF (x_ivev_rec.datetime_valid = OKC_API.G_MISS_DATE)
      THEN
        x_ivev_rec.datetime_valid := l_ivev_rec.datetime_valid;
      END IF;
      IF (x_ivev_rec.datetime_invalid = OKC_API.G_MISS_DATE)
      THEN
        x_ivev_rec.datetime_invalid := l_ivev_rec.datetime_invalid;
      END IF;
      IF (x_ivev_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_ivev_rec.program_id := l_ivev_rec.program_id;
      END IF;
      IF (x_ivev_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_ivev_rec.program_application_id := l_ivev_rec.program_application_id;
      END IF;
      IF (x_ivev_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_ivev_rec.request_id := l_ivev_rec.request_id;
      END IF;
      IF (x_ivev_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ivev_rec.program_update_date := l_ivev_rec.program_update_date;
      END IF;
      IF (x_ivev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ivev_rec.created_by := l_ivev_rec.created_by;
      END IF;
      IF (x_ivev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ivev_rec.creation_date := l_ivev_rec.creation_date;
      END IF;
      IF (x_ivev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ivev_rec.last_updated_by := l_ivev_rec.last_updated_by;
      END IF;
      IF (x_ivev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ivev_rec.last_update_date := l_ivev_rec.last_update_date;
      END IF;
      IF (x_ivev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ivev_rec.last_update_login := l_ivev_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_INDEX_VALUES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_ivev_rec IN  ivev_rec_type,
      x_ivev_rec OUT NOCOPY ivev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN

      x_ivev_rec := p_ivev_rec;

      SELECT  NVL(DECODE(fnd_global.conc_request_id, -1, NULL, fnd_global.conc_request_id), p_ivev_rec.request_id)
            ,NVL(DECODE(fnd_global.prog_appl_id, -1, NULL, fnd_global.prog_appl_id), p_ivev_rec.program_application_id)
            ,NVL(DECODE(fnd_global.conc_program_id, -1, NULL, fnd_global.conc_program_id), p_ivev_rec.program_id)
            ,DECODE(DECODE(fnd_global.conc_request_id, -1, NULL, sysdate),NULL,p_ivev_rec.program_update_date,sysdate)
      INTO	x_ivev_rec.request_id
           	,x_ivev_rec.program_application_id
            ,x_ivev_rec.program_id
            ,x_ivev_rec.program_update_date
      FROM dual;

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
      p_ivev_rec,                        -- IN
      l_ivev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ivev_rec, l_def_ivev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ivev_rec := fill_who_columns(l_def_ivev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ivev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ivev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ivev_rec, l_ive_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ive_rec,
      lx_ive_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ive_rec, l_def_ivev_rec);
    x_ivev_rec := l_def_ivev_rec;
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
  -- PL/SQL TBL update_row for:IVEV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivev_tbl                     IN ivev_tbl_type,
    x_ivev_tbl                     OUT NOCOPY ivev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ivev_tbl.COUNT > 0) THEN
      i := p_ivev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ivev_rec                     => p_ivev_tbl(i),
          x_ivev_rec                     => x_ivev_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_ivev_tbl.LAST);
        i := p_ivev_tbl.NEXT(i);
      END LOOP;
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
  -------------------------------------
  -- delete_row for:OKL_INDEX_VALUES --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ive_rec                      IN ive_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALUES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ive_rec                      ive_rec_type:= p_ive_rec;
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
    DELETE FROM OKL_INDEX_VALUES
     WHERE ID = l_ive_rec.id;

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
  ---------------------------------------
  -- delete_row for:OKL_INDEX_VALUES_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivev_rec                     IN ivev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ivev_rec                     ivev_rec_type := p_ivev_rec;
    l_ive_rec                      ive_rec_type;
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
    migrate(l_ivev_rec, l_ive_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ive_rec
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
  -- PL/SQL TBL delete_row for:IVEV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivev_tbl                     IN ivev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ivev_tbl.COUNT > 0) THEN
      i := p_ivev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ivev_rec                     => p_ivev_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_ivev_tbl.LAST);
        i := p_ivev_tbl.NEXT(i);
      END LOOP;
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
END OKL_IVE_PVT;

/
