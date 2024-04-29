--------------------------------------------------------
--  DDL for Package Body OKL_IDI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IDI_PVT" AS
/* $Header: OKLSIDIB.pls 115.11 2002/12/18 12:57:58 kjinger noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  -- 04/17/2001 Inserted Robin Ediwn for validate attribute
  ---------------------------------------------------------------------------
    G_EXCEPTION_HALT_VALIDATION EXCEPTION;

    PROCEDURE validate_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_idi_rec IN idiv_rec_type
    ) IS
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_idi_rec.id = OKC_API.G_MISS_NUM OR
       p_idi_rec.id IS NULL
    THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'ID');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
        else
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
       end if;
      exception
       when G_EXCEPTION_HALT_VALIDATION then
          null;
       when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  -- 04/17/2001 Inserted Robin Ediwn for validate attribute
  ---------------------------------------------------------------------------
    PROCEDURE validate_object_version_number(
      x_return_status OUT NOCOPY VARCHAR2,
      p_idi_rec IN idiv_rec_type
    ) IS
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_idi_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_idi_rec.object_version_number IS NULL
    THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'ID');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
        else
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
       end if;
      exception
       when G_EXCEPTION_HALT_VALIDATION then
          null;
       when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_object_version_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_datetime_valid
  -- 04/17/2001 Inserted Robin Ediwn for validate attribute
  ---------------------------------------------------------------------------
    PROCEDURE validate_datetime_valid(
      x_return_status OUT NOCOPY VARCHAR2,
      p_idi_rec IN idiv_rec_type
    ) IS
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_idi_rec.datetime_valid = OKC_API.G_MISS_DATE OR
       p_idi_rec.datetime_valid IS NULL

    THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'datetime_valid');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
        else
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
       end if;
      exception
       when G_EXCEPTION_HALT_VALIDATION then
          null;
       when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_datetime_valid;


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
  -- FUNCTION get_rec for: OKL_INDX_INTERFACES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_idi_rec                      IN idi_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN idi_rec_type IS
    CURSOR okl_indx_interfaces_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            IDI_TYPE,
            PROCESS_FLAG,
            PROPORTION_CONTRIBUTED,
            INDEX_NAME,
            PROGRAM_ID,
            DESCRIPTION,
            VALUE,
            DATETIME_VALID,
            DATETIME_INVALID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
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
      FROM Okl_Indx_Interfaces
     WHERE okl_indx_interfaces.id = p_id;
    l_okl_indx_interfaces_pk       okl_indx_interfaces_pk_csr%ROWTYPE;
    l_idi_rec                      idi_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_indx_interfaces_pk_csr (p_idi_rec.id);
    FETCH okl_indx_interfaces_pk_csr INTO
              l_idi_rec.ID,
              l_idi_rec.OBJECT_VERSION_NUMBER,
              l_idi_rec.IDI_TYPE,
              l_idi_rec.PROCESS_FLAG,
              l_idi_rec.PROPORTION_CONTRIBUTED,
              l_idi_rec.INDEX_NAME,
              l_idi_rec.PROGRAM_ID,
              l_idi_rec.DESCRIPTION,
              l_idi_rec.VALUE,
              l_idi_rec.DATETIME_VALID,
              l_idi_rec.DATETIME_INVALID,
              l_idi_rec.REQUEST_ID,
              l_idi_rec.PROGRAM_APPLICATION_ID,
              l_idi_rec.PROGRAM_UPDATE_DATE,
              l_idi_rec.ATTRIBUTE_CATEGORY,
              l_idi_rec.ATTRIBUTE1,
              l_idi_rec.ATTRIBUTE2,
              l_idi_rec.ATTRIBUTE3,
              l_idi_rec.ATTRIBUTE4,
              l_idi_rec.ATTRIBUTE5,
              l_idi_rec.ATTRIBUTE6,
              l_idi_rec.ATTRIBUTE7,
              l_idi_rec.ATTRIBUTE8,
              l_idi_rec.ATTRIBUTE9,
              l_idi_rec.ATTRIBUTE10,
              l_idi_rec.ATTRIBUTE11,
              l_idi_rec.ATTRIBUTE12,
              l_idi_rec.ATTRIBUTE13,
              l_idi_rec.ATTRIBUTE14,
              l_idi_rec.ATTRIBUTE15,
              l_idi_rec.CREATED_BY,
              l_idi_rec.CREATION_DATE,
              l_idi_rec.LAST_UPDATED_BY,
              l_idi_rec.LAST_UPDATE_DATE,
              l_idi_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_indx_interfaces_pk_csr%NOTFOUND;
    CLOSE okl_indx_interfaces_pk_csr;
    RETURN(l_idi_rec);
  END get_rec;

  FUNCTION get_rec (
    p_idi_rec                      IN idi_rec_type
  ) RETURN idi_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_idi_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INDX_INTERFACES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_idiv_rec                     IN idiv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN idiv_rec_type IS
    CURSOR okl_idiv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            IDI_TYPE,
            PROCESS_FLAG,
            PROPORTION_CONTRIBUTED,
            INDEX_NAME,
            DESCRIPTION,
            VALUE,
            DATETIME_VALID,
            DATETIME_INVALID,
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
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Indx_Interfaces_V
     WHERE okl_indx_interfaces_v.id = p_id;
    l_okl_idiv_pk                  okl_idiv_pk_csr%ROWTYPE;
    l_idiv_rec                     idiv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_idiv_pk_csr (p_idiv_rec.id);
    FETCH okl_idiv_pk_csr INTO
              l_idiv_rec.ID,
              l_idiv_rec.OBJECT_VERSION_NUMBER,
              l_idiv_rec.IDI_TYPE,
              l_idiv_rec.PROCESS_FLAG,
              l_idiv_rec.PROPORTION_CONTRIBUTED,
              l_idiv_rec.INDEX_NAME,
              l_idiv_rec.DESCRIPTION,
              l_idiv_rec.VALUE,
              l_idiv_rec.DATETIME_VALID,
              l_idiv_rec.DATETIME_INVALID,
              l_idiv_rec.ATTRIBUTE_CATEGORY,
              l_idiv_rec.ATTRIBUTE1,
              l_idiv_rec.ATTRIBUTE2,
              l_idiv_rec.ATTRIBUTE3,
              l_idiv_rec.ATTRIBUTE4,
              l_idiv_rec.ATTRIBUTE5,
              l_idiv_rec.ATTRIBUTE6,
              l_idiv_rec.ATTRIBUTE7,
              l_idiv_rec.ATTRIBUTE8,
              l_idiv_rec.ATTRIBUTE9,
              l_idiv_rec.ATTRIBUTE10,
              l_idiv_rec.ATTRIBUTE11,
              l_idiv_rec.ATTRIBUTE12,
              l_idiv_rec.ATTRIBUTE13,
              l_idiv_rec.ATTRIBUTE14,
              l_idiv_rec.ATTRIBUTE15,
              l_idiv_rec.PROGRAM_ID,
              l_idiv_rec.REQUEST_ID,
              l_idiv_rec.PROGRAM_APPLICATION_ID,
              l_idiv_rec.PROGRAM_UPDATE_DATE,
              l_idiv_rec.CREATED_BY,
              l_idiv_rec.CREATION_DATE,
              l_idiv_rec.LAST_UPDATED_BY,
              l_idiv_rec.LAST_UPDATE_DATE,
              l_idiv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_idiv_pk_csr%NOTFOUND;
    CLOSE okl_idiv_pk_csr;
    RETURN(l_idiv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_idiv_rec                     IN idiv_rec_type
  ) RETURN idiv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_idiv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INDX_INTERFACES_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_idiv_rec	IN idiv_rec_type
  ) RETURN idiv_rec_type IS
    l_idiv_rec	idiv_rec_type := p_idiv_rec;
  BEGIN
    IF (l_idiv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_idiv_rec.object_version_number := NULL;
    END IF;
    IF (l_idiv_rec.idi_type = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.idi_type := NULL;
    END IF;
    IF (l_idiv_rec.process_flag = OKC_API.G_MISS_NUM) THEN
      l_idiv_rec.process_flag := NULL;
    END IF;
    IF (l_idiv_rec.proportion_contributed = OKC_API.G_MISS_NUM) THEN
      l_idiv_rec.proportion_contributed := NULL;
    END IF;
    IF (l_idiv_rec.index_name = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.index_name := NULL;
    END IF;
    IF (l_idiv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.description := NULL;
    END IF;
    IF (l_idiv_rec.value = OKC_API.G_MISS_NUM) THEN
      l_idiv_rec.value := NULL;
    END IF;
    IF (l_idiv_rec.datetime_valid = OKC_API.G_MISS_DATE) THEN
      l_idiv_rec.datetime_valid := NULL;
    END IF;
    IF (l_idiv_rec.datetime_invalid = OKC_API.G_MISS_DATE) THEN
      l_idiv_rec.datetime_invalid := NULL;
    END IF;
    IF (l_idiv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute_category := NULL;
    END IF;
    IF (l_idiv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute1 := NULL;
    END IF;
    IF (l_idiv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute2 := NULL;
    END IF;
    IF (l_idiv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute3 := NULL;
    END IF;
    IF (l_idiv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute4 := NULL;
    END IF;
    IF (l_idiv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute5 := NULL;
    END IF;
    IF (l_idiv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute6 := NULL;
    END IF;
    IF (l_idiv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute7 := NULL;
    END IF;
    IF (l_idiv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute8 := NULL;
    END IF;
    IF (l_idiv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute9 := NULL;
    END IF;
    IF (l_idiv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute10 := NULL;
    END IF;
    IF (l_idiv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute11 := NULL;
    END IF;
    IF (l_idiv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute12 := NULL;
    END IF;
    IF (l_idiv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute13 := NULL;
    END IF;
    IF (l_idiv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute14 := NULL;
    END IF;
    IF (l_idiv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_idiv_rec.attribute15 := NULL;
    END IF;
    IF (l_idiv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_idiv_rec.program_id := NULL;
    END IF;
    IF (l_idiv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_idiv_rec.request_id := NULL;
    END IF;
    IF (l_idiv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_idiv_rec.program_application_id := NULL;
    END IF;
    IF (l_idiv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_idiv_rec.program_update_date := NULL;
    END IF;
    IF (l_idiv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_idiv_rec.created_by := NULL;
    END IF;
    IF (l_idiv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_idiv_rec.creation_date := NULL;
    END IF;
    IF (l_idiv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_idiv_rec.last_updated_by := NULL;
    END IF;
    IF (l_idiv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_idiv_rec.last_update_date := NULL;
    END IF;
    IF (l_idiv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_idiv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_idiv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_INDX_INTERFACES_V --
  -- 04/17/2001 Modified Robin Edwin Added code for validation
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_idiv_rec IN  idiv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -- To validate not null in id column

    validate_id(x_return_status => l_return_status, p_idi_rec => p_idiv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    -- To validate not null in object_version_number column

    validate_object_version_number(x_return_status => l_return_status, p_idi_rec => p_idiv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    -- To validate not null in datetime_valid column

    validate_datetime_valid(x_return_status => l_return_status, p_idi_rec => p_idiv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    RETURN(l_return_status);

    exception
      when OTHERS then
        -- store SQL error message on message stack for caller
        OKC_API.SET_MESSAGE(p_app_name    => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_sqlerrm_token,
                            p_token2_value => sqlerrm);

        --notify caller of an UNEXPECTED error
        x_return_status  := OKC_API.G_RET_STS_UNEXP_ERROR;

        --return status to caller
        return x_return_status;

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_INDX_INTERFACES_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_idiv_rec IN idiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN idiv_rec_type,
    p_to	IN OUT NOCOPY idi_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.idi_type := p_from.idi_type;
    p_to.process_flag := p_from.process_flag;
    p_to.proportion_contributed := p_from.proportion_contributed;
    p_to.index_name := p_from.index_name;
    p_to.program_id := p_from.program_id;
    p_to.description := p_from.description;
    p_to.value := p_from.value;
    p_to.datetime_valid := p_from.datetime_valid;
    p_to.datetime_invalid := p_from.datetime_invalid;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_update_date := p_from.program_update_date;
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
    p_from	IN idi_rec_type,
    p_to	OUT NOCOPY idiv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.idi_type := p_from.idi_type;
    p_to.process_flag := p_from.process_flag;
    p_to.proportion_contributed := p_from.proportion_contributed;
    p_to.index_name := p_from.index_name;
    p_to.program_id := p_from.program_id;
    p_to.description := p_from.description;
    p_to.value := p_from.value;
    p_to.datetime_valid := p_from.datetime_valid;
    p_to.datetime_invalid := p_from.datetime_invalid;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_update_date := p_from.program_update_date;
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
  --------------------------------------------
  -- validate_row for:OKL_INDX_INTERFACES_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_rec                     IN idiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idiv_rec                     idiv_rec_type := p_idiv_rec;
    l_idi_rec                      idi_rec_type;
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
    l_return_status := Validate_Attributes(l_idiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_idiv_rec);
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
  -- PL/SQL TBL validate_row for:IDIV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_tbl                     IN idiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_idiv_tbl.COUNT > 0) THEN
      i := p_idiv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_idiv_rec                     => p_idiv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_idiv_tbl.LAST);
        i := p_idiv_tbl.NEXT(i);
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
  ----------------------------------------
  -- insert_row for:OKL_INDX_INTERFACES --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idi_rec                      IN idi_rec_type,
    x_idi_rec                      OUT NOCOPY idi_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INTERFACES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idi_rec                      idi_rec_type := p_idi_rec;
    l_def_idi_rec                  idi_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_INDX_INTERFACES --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_idi_rec IN  idi_rec_type,
      x_idi_rec OUT NOCOPY idi_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_idi_rec := p_idi_rec;
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
      p_idi_rec,                         -- IN
      l_idi_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_INDX_INTERFACES(
        id,
        object_version_number,
        idi_type,
        process_flag,
        proportion_contributed,
        index_name,
        program_id,
        description,
        value,
        datetime_valid,
        datetime_invalid,
        request_id,
        program_application_id,
        program_update_date,
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
        l_idi_rec.id,
        l_idi_rec.object_version_number,
        l_idi_rec.idi_type,
        l_idi_rec.process_flag,
        l_idi_rec.proportion_contributed,
        l_idi_rec.index_name,
        l_idi_rec.program_id,
        l_idi_rec.description,
        l_idi_rec.value,
        l_idi_rec.datetime_valid,
        l_idi_rec.datetime_invalid,
        l_idi_rec.request_id,
        l_idi_rec.program_application_id,
        l_idi_rec.program_update_date,
        l_idi_rec.attribute_category,
        l_idi_rec.attribute1,
        l_idi_rec.attribute2,
        l_idi_rec.attribute3,
        l_idi_rec.attribute4,
        l_idi_rec.attribute5,
        l_idi_rec.attribute6,
        l_idi_rec.attribute7,
        l_idi_rec.attribute8,
        l_idi_rec.attribute9,
        l_idi_rec.attribute10,
        l_idi_rec.attribute11,
        l_idi_rec.attribute12,
        l_idi_rec.attribute13,
        l_idi_rec.attribute14,
        l_idi_rec.attribute15,
        l_idi_rec.created_by,
        l_idi_rec.creation_date,
        l_idi_rec.last_updated_by,
        l_idi_rec.last_update_date,
        l_idi_rec.last_update_login);
    -- Set OUT values
    x_idi_rec := l_idi_rec;
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
  ------------------------------------------
  -- insert_row for:OKL_INDX_INTERFACES_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_rec                     IN idiv_rec_type,
    x_idiv_rec                     OUT NOCOPY idiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idiv_rec                     idiv_rec_type;
    l_def_idiv_rec                 idiv_rec_type;
    l_idi_rec                      idi_rec_type;
    lx_idi_rec                     idi_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_idiv_rec	IN idiv_rec_type
    ) RETURN idiv_rec_type IS
      l_idiv_rec	idiv_rec_type := p_idiv_rec;
    BEGIN
      l_idiv_rec.CREATION_DATE := SYSDATE;
      l_idiv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_idiv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_idiv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_idiv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_idiv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INDX_INTERFACES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_idiv_rec IN  idiv_rec_type,
      x_idiv_rec OUT NOCOPY idiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_idiv_rec := p_idiv_rec;
      x_idiv_rec.OBJECT_VERSION_NUMBER := 1;

	SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
		DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
		DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
		DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
	INTO  x_idiv_rec.REQUEST_ID
		,x_idiv_rec.PROGRAM_APPLICATION_ID
		,x_idiv_rec.PROGRAM_ID
		,x_idiv_rec.PROGRAM_UPDATE_DATE
	FROM DUAL;

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
    l_idiv_rec := null_out_defaults(p_idiv_rec);
    -- Set primary key value
    l_idiv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_idiv_rec,                        -- IN
      l_def_idiv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_idiv_rec := fill_who_columns(l_def_idiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_idiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_idiv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_idiv_rec, l_idi_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_idi_rec,
      lx_idi_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_idi_rec, l_def_idiv_rec);
    -- Set OUT values
    x_idiv_rec := l_def_idiv_rec;
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
  -- PL/SQL TBL insert_row for:IDIV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_tbl                     IN idiv_tbl_type,
    x_idiv_tbl                     OUT NOCOPY idiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_idiv_tbl.COUNT > 0) THEN
      i := p_idiv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_idiv_rec                     => p_idiv_tbl(i),
          x_idiv_rec                     => x_idiv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_idiv_tbl.LAST);
        i := p_idiv_tbl.NEXT(i);
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
  --------------------------------------
  -- lock_row for:OKL_INDX_INTERFACES --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idi_rec                      IN idi_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_idi_rec IN idi_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INDX_INTERFACES
     WHERE ID = p_idi_rec.id
       AND OBJECT_VERSION_NUMBER = p_idi_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_idi_rec IN idi_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INDX_INTERFACES
    WHERE ID = p_idi_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INTERFACES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_INDX_INTERFACES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_INDX_INTERFACES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_idi_rec);
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
      OPEN lchk_csr(p_idi_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_idi_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_idi_rec.object_version_number THEN
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
  ----------------------------------------
  -- lock_row for:OKL_INDX_INTERFACES_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_rec                     IN idiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idi_rec                      idi_rec_type;
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
    migrate(p_idiv_rec, l_idi_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_idi_rec
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
  -- PL/SQL TBL lock_row for:IDIV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_tbl                     IN idiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_idiv_tbl.COUNT > 0) THEN
      i := p_idiv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_idiv_rec                     => p_idiv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_idiv_tbl.LAST);
        i := p_idiv_tbl.NEXT(i);
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
  ----------------------------------------
  -- update_row for:OKL_INDX_INTERFACES --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idi_rec                      IN idi_rec_type,
    x_idi_rec                      OUT NOCOPY idi_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INTERFACES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idi_rec                      idi_rec_type := p_idi_rec;
    l_def_idi_rec                  idi_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_idi_rec	IN idi_rec_type,
      x_idi_rec	OUT NOCOPY idi_rec_type
    ) RETURN VARCHAR2 IS
      l_idi_rec                      idi_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_idi_rec := p_idi_rec;
      -- Get current database values
      l_idi_rec := get_rec(p_idi_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_idi_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_idi_rec.id := l_idi_rec.id;
      END IF;
      IF (x_idi_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_idi_rec.object_version_number := l_idi_rec.object_version_number;
      END IF;
      IF (x_idi_rec.idi_type = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.idi_type := l_idi_rec.idi_type;
      END IF;
      IF (x_idi_rec.process_flag = OKC_API.G_MISS_NUM)
      THEN
        x_idi_rec.process_flag := l_idi_rec.process_flag;
      END IF;
      IF (x_idi_rec.proportion_contributed = OKC_API.G_MISS_NUM)
      THEN
        x_idi_rec.proportion_contributed := l_idi_rec.proportion_contributed;
      END IF;
      IF (x_idi_rec.index_name = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.index_name := l_idi_rec.index_name;
      END IF;
      IF (x_idi_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_idi_rec.program_id := l_idi_rec.program_id;
      END IF;
      IF (x_idi_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.description := l_idi_rec.description;
      END IF;
      IF (x_idi_rec.value = OKC_API.G_MISS_NUM)
      THEN
        x_idi_rec.value := l_idi_rec.value;
      END IF;
      IF (x_idi_rec.datetime_valid = OKC_API.G_MISS_DATE)
      THEN
        x_idi_rec.datetime_valid := l_idi_rec.datetime_valid;
      END IF;
      IF (x_idi_rec.datetime_invalid = OKC_API.G_MISS_DATE)
      THEN
        x_idi_rec.datetime_invalid := l_idi_rec.datetime_invalid;
      END IF;
      IF (x_idi_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_idi_rec.request_id := l_idi_rec.request_id;
      END IF;
      IF (x_idi_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_idi_rec.program_application_id := l_idi_rec.program_application_id;
      END IF;
      IF (x_idi_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_idi_rec.program_update_date := l_idi_rec.program_update_date;
      END IF;
      IF (x_idi_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute_category := l_idi_rec.attribute_category;
      END IF;
      IF (x_idi_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute1 := l_idi_rec.attribute1;
      END IF;
      IF (x_idi_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute2 := l_idi_rec.attribute2;
      END IF;
      IF (x_idi_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute3 := l_idi_rec.attribute3;
      END IF;
      IF (x_idi_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute4 := l_idi_rec.attribute4;
      END IF;
      IF (x_idi_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute5 := l_idi_rec.attribute5;
      END IF;
      IF (x_idi_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute6 := l_idi_rec.attribute6;
      END IF;
      IF (x_idi_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute7 := l_idi_rec.attribute7;
      END IF;
      IF (x_idi_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute8 := l_idi_rec.attribute8;
      END IF;
      IF (x_idi_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute9 := l_idi_rec.attribute9;
      END IF;
      IF (x_idi_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute10 := l_idi_rec.attribute10;
      END IF;
      IF (x_idi_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute11 := l_idi_rec.attribute11;
      END IF;
      IF (x_idi_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute12 := l_idi_rec.attribute12;
      END IF;
      IF (x_idi_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute13 := l_idi_rec.attribute13;
      END IF;
      IF (x_idi_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute14 := l_idi_rec.attribute14;
      END IF;
      IF (x_idi_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_idi_rec.attribute15 := l_idi_rec.attribute15;
      END IF;
      IF (x_idi_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_idi_rec.created_by := l_idi_rec.created_by;
      END IF;
      IF (x_idi_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_idi_rec.creation_date := l_idi_rec.creation_date;
      END IF;
      IF (x_idi_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_idi_rec.last_updated_by := l_idi_rec.last_updated_by;
      END IF;
      IF (x_idi_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_idi_rec.last_update_date := l_idi_rec.last_update_date;
      END IF;
      IF (x_idi_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_idi_rec.last_update_login := l_idi_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_INDX_INTERFACES --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_idi_rec IN  idi_rec_type,
      x_idi_rec OUT NOCOPY idi_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_idi_rec := p_idi_rec;
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
      p_idi_rec,                         -- IN
      l_idi_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_idi_rec, l_def_idi_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INDX_INTERFACES
    SET OBJECT_VERSION_NUMBER = l_def_idi_rec.object_version_number,
        IDI_TYPE = l_def_idi_rec.idi_type,
        PROCESS_FLAG = l_def_idi_rec.process_flag,
        PROPORTION_CONTRIBUTED = l_def_idi_rec.proportion_contributed,
        INDEX_NAME = l_def_idi_rec.index_name,
        PROGRAM_ID = l_def_idi_rec.program_id,
        DESCRIPTION = l_def_idi_rec.description,
        VALUE = l_def_idi_rec.value,
        DATETIME_VALID = l_def_idi_rec.datetime_valid,
        DATETIME_INVALID = l_def_idi_rec.datetime_invalid,
        REQUEST_ID = l_def_idi_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_idi_rec.program_application_id,
        PROGRAM_UPDATE_DATE = l_def_idi_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_idi_rec.attribute_category,
        ATTRIBUTE1 = l_def_idi_rec.attribute1,
        ATTRIBUTE2 = l_def_idi_rec.attribute2,
        ATTRIBUTE3 = l_def_idi_rec.attribute3,
        ATTRIBUTE4 = l_def_idi_rec.attribute4,
        ATTRIBUTE5 = l_def_idi_rec.attribute5,
        ATTRIBUTE6 = l_def_idi_rec.attribute6,
        ATTRIBUTE7 = l_def_idi_rec.attribute7,
        ATTRIBUTE8 = l_def_idi_rec.attribute8,
        ATTRIBUTE9 = l_def_idi_rec.attribute9,
        ATTRIBUTE10 = l_def_idi_rec.attribute10,
        ATTRIBUTE11 = l_def_idi_rec.attribute11,
        ATTRIBUTE12 = l_def_idi_rec.attribute12,
        ATTRIBUTE13 = l_def_idi_rec.attribute13,
        ATTRIBUTE14 = l_def_idi_rec.attribute14,
        ATTRIBUTE15 = l_def_idi_rec.attribute15,
        CREATED_BY = l_def_idi_rec.created_by,
        CREATION_DATE = l_def_idi_rec.creation_date,
        LAST_UPDATED_BY = l_def_idi_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_idi_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_idi_rec.last_update_login
    WHERE ID = l_def_idi_rec.id;

    x_idi_rec := l_def_idi_rec;
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
  ------------------------------------------
  -- update_row for:OKL_INDX_INTERFACES_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_rec                     IN idiv_rec_type,
    x_idiv_rec                     OUT NOCOPY idiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idiv_rec                     idiv_rec_type := p_idiv_rec;
    l_def_idiv_rec                 idiv_rec_type;
    l_idi_rec                      idi_rec_type;
    lx_idi_rec                     idi_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_idiv_rec	IN idiv_rec_type
    ) RETURN idiv_rec_type IS
      l_idiv_rec	idiv_rec_type := p_idiv_rec;
    BEGIN
      l_idiv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_idiv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_idiv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_idiv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_idiv_rec	IN idiv_rec_type,
      x_idiv_rec	OUT NOCOPY idiv_rec_type
    ) RETURN VARCHAR2 IS
      l_idiv_rec                     idiv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_idiv_rec := p_idiv_rec;
      -- Get current database values
      l_idiv_rec := get_rec(p_idiv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_idiv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_idiv_rec.id := l_idiv_rec.id;
      END IF;
      IF (x_idiv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_idiv_rec.object_version_number := l_idiv_rec.object_version_number;
      END IF;
      IF (x_idiv_rec.idi_type = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.idi_type := l_idiv_rec.idi_type;
      END IF;
      IF (x_idiv_rec.process_flag = OKC_API.G_MISS_NUM)
      THEN
        x_idiv_rec.process_flag := l_idiv_rec.process_flag;
      END IF;
      IF (x_idiv_rec.proportion_contributed = OKC_API.G_MISS_NUM)
      THEN
        x_idiv_rec.proportion_contributed := l_idiv_rec.proportion_contributed;
      END IF;
      IF (x_idiv_rec.index_name = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.index_name := l_idiv_rec.index_name;
      END IF;
      IF (x_idiv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.description := l_idiv_rec.description;
      END IF;
      IF (x_idiv_rec.value = OKC_API.G_MISS_NUM)
      THEN
        x_idiv_rec.value := l_idiv_rec.value;
      END IF;
      IF (x_idiv_rec.datetime_valid = OKC_API.G_MISS_DATE)
      THEN
        x_idiv_rec.datetime_valid := l_idiv_rec.datetime_valid;
      END IF;
      IF (x_idiv_rec.datetime_invalid = OKC_API.G_MISS_DATE)
      THEN
        x_idiv_rec.datetime_invalid := l_idiv_rec.datetime_invalid;
      END IF;
      IF (x_idiv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute_category := l_idiv_rec.attribute_category;
      END IF;
      IF (x_idiv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute1 := l_idiv_rec.attribute1;
      END IF;
      IF (x_idiv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute2 := l_idiv_rec.attribute2;
      END IF;
      IF (x_idiv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute3 := l_idiv_rec.attribute3;
      END IF;
      IF (x_idiv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute4 := l_idiv_rec.attribute4;
      END IF;
      IF (x_idiv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute5 := l_idiv_rec.attribute5;
      END IF;
      IF (x_idiv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute6 := l_idiv_rec.attribute6;
      END IF;
      IF (x_idiv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute7 := l_idiv_rec.attribute7;
      END IF;
      IF (x_idiv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute8 := l_idiv_rec.attribute8;
      END IF;
      IF (x_idiv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute9 := l_idiv_rec.attribute9;
      END IF;
      IF (x_idiv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute10 := l_idiv_rec.attribute10;
      END IF;
      IF (x_idiv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute11 := l_idiv_rec.attribute11;
      END IF;
      IF (x_idiv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute12 := l_idiv_rec.attribute12;
      END IF;
      IF (x_idiv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute13 := l_idiv_rec.attribute13;
      END IF;
      IF (x_idiv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute14 := l_idiv_rec.attribute14;
      END IF;
      IF (x_idiv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_idiv_rec.attribute15 := l_idiv_rec.attribute15;
      END IF;
      IF (x_idiv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_idiv_rec.program_id := l_idiv_rec.program_id;
      END IF;
      IF (x_idiv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_idiv_rec.request_id := l_idiv_rec.request_id;
      END IF;
      IF (x_idiv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_idiv_rec.program_application_id := l_idiv_rec.program_application_id;
      END IF;
      IF (x_idiv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_idiv_rec.program_update_date := l_idiv_rec.program_update_date;
      END IF;
      IF (x_idiv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_idiv_rec.created_by := l_idiv_rec.created_by;
      END IF;
      IF (x_idiv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_idiv_rec.creation_date := l_idiv_rec.creation_date;
      END IF;
      IF (x_idiv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_idiv_rec.last_updated_by := l_idiv_rec.last_updated_by;
      END IF;
      IF (x_idiv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_idiv_rec.last_update_date := l_idiv_rec.last_update_date;
      END IF;
      IF (x_idiv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_idiv_rec.last_update_login := l_idiv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INDX_INTERFACES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_idiv_rec IN  idiv_rec_type,
      x_idiv_rec OUT NOCOPY idiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_idiv_rec := p_idiv_rec;

	SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
		DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
		DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
		DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
	INTO  x_idiv_rec.REQUEST_ID
		,x_idiv_rec.PROGRAM_APPLICATION_ID
		,x_idiv_rec.PROGRAM_ID
		,x_idiv_rec.PROGRAM_UPDATE_DATE
	FROM DUAL;

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
      p_idiv_rec,                        -- IN
      l_idiv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_idiv_rec, l_def_idiv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_idiv_rec := fill_who_columns(l_def_idiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_idiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_idiv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_idiv_rec, l_idi_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_idi_rec,
      lx_idi_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_idi_rec, l_def_idiv_rec);
    x_idiv_rec := l_def_idiv_rec;
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
  -- PL/SQL TBL update_row for:IDIV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_tbl                     IN idiv_tbl_type,
    x_idiv_tbl                     OUT NOCOPY idiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_idiv_tbl.COUNT > 0) THEN
      i := p_idiv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_idiv_rec                     => p_idiv_tbl(i),
          x_idiv_rec                     => x_idiv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_idiv_tbl.LAST);
        i := p_idiv_tbl.NEXT(i);
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
  ----------------------------------------
  -- delete_row for:OKL_INDX_INTERFACES --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idi_rec                      IN idi_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INTERFACES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idi_rec                      idi_rec_type:= p_idi_rec;
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
    DELETE FROM OKL_INDX_INTERFACES
     WHERE ID = l_idi_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKL_INDX_INTERFACES_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_rec                     IN idiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idiv_rec                     idiv_rec_type := p_idiv_rec;
    l_idi_rec                      idi_rec_type;
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
    migrate(l_idiv_rec, l_idi_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_idi_rec
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
  -- PL/SQL TBL delete_row for:IDIV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_tbl                     IN idiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_idiv_tbl.COUNT > 0) THEN
      i := p_idiv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_idiv_rec                     => p_idiv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_idiv_tbl.LAST);
        i := p_idiv_tbl.NEXT(i);
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
END OKL_IDI_PVT;

/
