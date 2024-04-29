--------------------------------------------------------
--  DDL for Package Body OKL_IDX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IDX_PVT" AS
/* $Header: OKLSIDXB.pls 115.16 2002/11/30 09:13:22 spillaip noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  -- 04/20/2001 Inserted Robin Edwin for validate attribute
  ---------------------------------------------------------------------------
    G_EXCEPTION_HALT_VALIDATION EXCEPTION;

    PROCEDURE validate_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_idxv_rec IN idxv_rec_type
    ) IS
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_idxv_rec.id = OKC_API.G_MISS_NUM OR
       p_idxv_rec.id IS NULL
    THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'ID');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
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
  -- PROCEDURE validate_name
  -- 04/20/2001 Inserted Robin Edwin for validate attribute
  ---------------------------------------------------------------------------

    PROCEDURE validate_name(
      x_return_status OUT NOCOPY VARCHAR2,
      p_idxv_rec IN idxv_rec_type
    ) IS


    l_token_value ak_attributes_tl.attribute_label_long%TYPE := NULL;

    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_idxv_rec.name = OKC_API.G_MISS_CHAR OR
       p_idxv_rec.name IS NULL
    THEN

-- Changed by Santonyr 28-Aug-2002 Fixed bug 2475283

         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'Interest Rate');


          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
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
    END validate_name;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_idx_type
  -- 04/20/2001 Inserted Robin Edwin for validate attribute
  ---------------------------------------------------------------------------

    PROCEDURE validate_idx_type(
      x_return_status OUT NOCOPY VARCHAR2,
      p_idxv_rec IN idxv_rec_type
    ) IS

    l_dummy                   VARCHAR2(1)    := OKL_API.G_FALSE;

    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_idxv_rec.idx_type = OKC_API.G_MISS_CHAR OR
       p_idxv_rec.idx_type IS NULL

    THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'IDX_TYPE');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_IDX_TYPE',
                               p_lookup_code => p_idxv_rec.idx_type);

    IF (l_dummy = OKL_API.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'IDX_TYPE');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
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
    END validate_idx_type;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_idx_frequency
  -- Changes Done by Kanti 03/01/2002
  ---------------------------------------------------------------------------

    PROCEDURE validate_idx_frequency(
      x_return_status OUT NOCOPY VARCHAR2,
      p_idxv_rec IN idxv_rec_type
    ) IS

    l_dummy                   VARCHAR2(1)    := OKL_API.G_FALSE;
    l_token_value ak_attributes_tl.attribute_label_long%TYPE := NULL;

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_idxv_rec.idx_frequency = OKC_API.G_MISS_CHAR OR
       p_idxv_rec.idx_frequency IS NULL

    THEN

-- Changed by Santonyr 28-Aug-2002 Fixed bug 2475283

         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'Index Frequency');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_IDX_FREQUENCY',
                               p_lookup_code =>  p_idxv_rec.idx_frequency);

    IF (l_dummy = OKL_API.G_FALSE) THEN
-- Changed by Santonyr 28-Aug-2002 Fixed bug 2475283

       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'Index Frequency');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
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

    END validate_idx_frequency;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  -- 04/20/2001 Inserted Robin Edwin for validate attribute
  ---------------------------------------------------------------------------

    PROCEDURE validate_object_version_number(
      x_return_status OUT NOCOPY VARCHAR2,
      p_idxv_rec IN idxv_rec_type
    ) IS
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_idxv_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_idxv_rec.object_version_number IS NULL
    THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'OBJECT_VERSION_NUMBER');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
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
  -- Procedure Name  : Validate_Unique_idxv_Record
  -- History         : 04/18/2001 Inserted Robin edwin for validate Unique
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_idxv_Record(
					    x_return_status OUT NOCOPY     VARCHAR2,
                                  p_idxv_rec      IN      idxv_rec_type)

  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_idxv_status           VARCHAR2(1);
  l_row_found             Boolean := False;

  CURSOR c_idx(v_name OKL_INDICES_V.NAME%TYPE,
            v_id   OKL_INDICES_V.ID%TYPE) is
  SELECT 	'1'
  FROM 	okl_indices_v
  WHERE name = v_name
  AND   ID <> v_id;

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN c_idx(v_id => p_idxv_rec.id,
		v_name => p_idxv_rec.name);
    FETCH c_idx into l_idxv_status;
    l_row_found := c_idx%FOUND;
    CLOSE c_idx;
    IF l_row_found THEN
	OKC_API.set_message(p_app_name => OKL_API.G_APP_NAME,
                            p_msg_name => 'OKL_IDX_NAME_UNIQUE');
	x_return_status := OKC_API.G_RET_STS_ERROR;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_idxv_Record;

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
  -- FUNCTION get_rec for: OKL_INDICES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_idx_rec                      IN idx_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN idx_rec_type IS
    CURSOR okl_indices_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            NAME,
            IDX_TYPE,
            IDX_FREQUENCY,
            OBJECT_VERSION_NUMBER,
            DESCRIPTION,
            PROGRAM_ID,
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
      FROM Okl_Indices
     WHERE okl_indices.id       = p_id;
    l_okl_indices_pk               okl_indices_pk_csr%ROWTYPE;
    l_idx_rec                      idx_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_indices_pk_csr (p_idx_rec.id);
    FETCH okl_indices_pk_csr INTO
              l_idx_rec.ID,
              l_idx_rec.NAME,
              l_idx_rec.IDX_TYPE,
              l_idx_rec.IDX_FREQUENCY,
              l_idx_rec.OBJECT_VERSION_NUMBER,
              l_idx_rec.DESCRIPTION,
              l_idx_rec.PROGRAM_ID,
              l_idx_rec.REQUEST_ID,
              l_idx_rec.PROGRAM_APPLICATION_ID,
              l_idx_rec.PROGRAM_UPDATE_DATE,
              l_idx_rec.ATTRIBUTE_CATEGORY,
              l_idx_rec.ATTRIBUTE1,
              l_idx_rec.ATTRIBUTE2,
              l_idx_rec.ATTRIBUTE3,
              l_idx_rec.ATTRIBUTE4,
              l_idx_rec.ATTRIBUTE5,
              l_idx_rec.ATTRIBUTE6,
              l_idx_rec.ATTRIBUTE7,
              l_idx_rec.ATTRIBUTE8,
              l_idx_rec.ATTRIBUTE9,
              l_idx_rec.ATTRIBUTE10,
              l_idx_rec.ATTRIBUTE11,
              l_idx_rec.ATTRIBUTE12,
              l_idx_rec.ATTRIBUTE13,
              l_idx_rec.ATTRIBUTE14,
              l_idx_rec.ATTRIBUTE15,
              l_idx_rec.CREATED_BY,
              l_idx_rec.CREATION_DATE,
              l_idx_rec.LAST_UPDATED_BY,
              l_idx_rec.LAST_UPDATE_DATE,
              l_idx_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_indices_pk_csr%NOTFOUND;
    CLOSE okl_indices_pk_csr;
    RETURN(l_idx_rec);
  END get_rec;

  FUNCTION get_rec (
    p_idx_rec                      IN idx_rec_type
  ) RETURN idx_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_idx_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INDICES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_idxv_rec                     IN idxv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN idxv_rec_type IS
    CURSOR okl_idxv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
            DESCRIPTION,
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
            IDX_TYPE,
            IDX_FREQUENCY,
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Indices_V
     WHERE okl_indices_v.id     = p_id;
    l_okl_idxv_pk                  okl_idxv_pk_csr%ROWTYPE;
    l_idxv_rec                     idxv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_idxv_pk_csr (p_idxv_rec.id);
    FETCH okl_idxv_pk_csr INTO
              l_idxv_rec.ID,
              l_idxv_rec.OBJECT_VERSION_NUMBER,
              l_idxv_rec.NAME,
              l_idxv_rec.DESCRIPTION,
              l_idxv_rec.ATTRIBUTE_CATEGORY,
              l_idxv_rec.ATTRIBUTE1,
              l_idxv_rec.ATTRIBUTE2,
              l_idxv_rec.ATTRIBUTE3,
              l_idxv_rec.ATTRIBUTE4,
              l_idxv_rec.ATTRIBUTE5,
              l_idxv_rec.ATTRIBUTE6,
              l_idxv_rec.ATTRIBUTE7,
              l_idxv_rec.ATTRIBUTE8,
              l_idxv_rec.ATTRIBUTE9,
              l_idxv_rec.ATTRIBUTE10,
              l_idxv_rec.ATTRIBUTE11,
              l_idxv_rec.ATTRIBUTE12,
              l_idxv_rec.ATTRIBUTE13,
              l_idxv_rec.ATTRIBUTE14,
              l_idxv_rec.ATTRIBUTE15,
              l_idxv_rec.IDX_TYPE,
              l_idxv_rec.IDX_FREQUENCY,
              l_idxv_rec.PROGRAM_ID,
              l_idxv_rec.REQUEST_ID,
              l_idxv_rec.PROGRAM_APPLICATION_ID,
              l_idxv_rec.PROGRAM_UPDATE_DATE,
              l_idxv_rec.CREATED_BY,
              l_idxv_rec.CREATION_DATE,
              l_idxv_rec.LAST_UPDATED_BY,
              l_idxv_rec.LAST_UPDATE_DATE,
              l_idxv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_idxv_pk_csr%NOTFOUND;
    CLOSE okl_idxv_pk_csr;
    RETURN(l_idxv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_idxv_rec                     IN idxv_rec_type
  ) RETURN idxv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_idxv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INDICES_V --
  ---------------------------------------------------
  FUNCTION null_out_defaults (
    p_idxv_rec	IN idxv_rec_type
  ) RETURN idxv_rec_type IS
    l_idxv_rec	idxv_rec_type := p_idxv_rec;
  BEGIN
    IF (l_idxv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_idxv_rec.object_version_number := NULL;
    END IF;
    IF (l_idxv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.name := NULL;
    END IF;
    IF (l_idxv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.description := NULL;
    END IF;
    IF (l_idxv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute_category := NULL;
    END IF;
    IF (l_idxv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute1 := NULL;
    END IF;
    IF (l_idxv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute2 := NULL;
    END IF;
    IF (l_idxv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute3 := NULL;
    END IF;
    IF (l_idxv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute4 := NULL;
    END IF;
    IF (l_idxv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute5 := NULL;
    END IF;
    IF (l_idxv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute6 := NULL;
    END IF;
    IF (l_idxv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute7 := NULL;
    END IF;
    IF (l_idxv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute8 := NULL;
    END IF;
    IF (l_idxv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute9 := NULL;
    END IF;
    IF (l_idxv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute10 := NULL;
    END IF;
    IF (l_idxv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute11 := NULL;
    END IF;
    IF (l_idxv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute12 := NULL;
    END IF;
    IF (l_idxv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute13 := NULL;
    END IF;
    IF (l_idxv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute14 := NULL;
    END IF;
    IF (l_idxv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.attribute15 := NULL;
    END IF;
    IF (l_idxv_rec.idx_type = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.idx_type := NULL;
    END IF;
    IF (l_idxv_rec.idx_frequency = OKC_API.G_MISS_CHAR) THEN
      l_idxv_rec.idx_frequency := NULL;
    END IF;
    IF (l_idxv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_idxv_rec.program_id := NULL;
    END IF;
    IF (l_idxv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_idxv_rec.request_id := NULL;
    END IF;
    IF (l_idxv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_idxv_rec.program_application_id := NULL;
    END IF;
    IF (l_idxv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_idxv_rec.program_update_date := NULL;
    END IF;
    IF (l_idxv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_idxv_rec.created_by := NULL;
    END IF;
    IF (l_idxv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_idxv_rec.creation_date := NULL;
    END IF;
    IF (l_idxv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_idxv_rec.last_updated_by := NULL;
    END IF;
    IF (l_idxv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_idxv_rec.last_update_date := NULL;
    END IF;
    IF (l_idxv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_idxv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_idxv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate_Attributes for:OKL_INDICES_V --
  -------------------------------------------
  FUNCTION Validate_Attributes (
    p_idxv_rec IN  idxv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -- To validate not null in id column
    validate_id(x_return_status 	=> l_return_status,
		p_idxv_rec 		=> p_idxv_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- To validate not null in name column
    validate_name(x_return_status 	=> l_return_status,
		  p_idxv_rec 		=> p_idxv_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- To validate not null in idx_type column
    validate_idx_type(x_return_status 	=> l_return_status,
		      p_idxv_rec 	=> p_idxv_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;


    -- To validate not null in idx_frequency  column
    validate_idx_frequency(x_return_status 	=> l_return_status,
		           p_idxv_rec 	        => p_idxv_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    -- To validate not null in object_version_number column
    validate_object_version_number(x_return_status 	=> l_return_status,
				   p_idxv_rec 		=> p_idxv_rec);

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
  -- Validate_Record for:OKL_INDICES_V --
  -- History         : 04/20/2001 Inserted Robin Edwin for validate Unique
  ---------------------------------------------------------------------------

  FUNCTION Validate_Record (
    p_idxv_rec IN idxv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Unique_ivev_Record
      Validate_Unique_idxv_Record(x_return_status, p_idxv_rec);
      -- store the highest degree of error
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            -- need to leave
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
            -- record that there was an error
            l_return_status := x_return_status;

        END IF;
      END IF;

-- This function was not returning any value in case of success. The following line has been
-- added by kanti on 07.05.2001.

  RETURN (l_return_status);

-- Changes end

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;
    RETURN (l_return_status);

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,

                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
-- This function was not returning any value in case of this error. The following line has been
-- added by kanti on 07.05.2001.
      RETURN (x_return_status);
-- Changes end

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN idxv_rec_type,
    p_to	IN OUT NOCOPY idx_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.idx_type := p_from.idx_type;
    p_to.idx_frequency := p_from.idx_frequency;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
    p_to.program_id := p_from.program_id;
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
    p_from	IN idx_rec_type,
    p_to	OUT NOCOPY idxv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.idx_type := p_from.idx_type;
    p_to.idx_frequency := p_from.idx_frequency;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
    p_to.program_id := p_from.program_id;
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
  ------------------------------------
  -- validate_row for:OKL_INDICES_V --
  ------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idxv_rec                     IN idxv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idxv_rec                     idxv_rec_type := p_idxv_rec;
    l_idx_rec                      idx_rec_type;
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
    l_return_status := Validate_Attributes(l_idxv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_idxv_rec);
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
  -- PL/SQL TBL validate_row for:IDXV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idxv_tbl                     IN idxv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_idxv_tbl.COUNT > 0) THEN
      i := p_idxv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_idxv_rec                     => p_idxv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_idxv_tbl.LAST);
        i := p_idxv_tbl.NEXT(i);
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
  --------------------------------
  -- insert_row for:OKL_INDICES --
  --------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idx_rec                      IN idx_rec_type,
    x_idx_rec                      OUT NOCOPY idx_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INDICES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idx_rec                      idx_rec_type := p_idx_rec;
    l_def_idx_rec                  idx_rec_type;
    ------------------------------------
    -- Set_Attributes for:OKL_INDICES --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_idx_rec IN  idx_rec_type,
      x_idx_rec OUT NOCOPY idx_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_idx_rec := p_idx_rec;
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
      p_idx_rec,                         -- IN
      l_idx_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_INDICES(
        id,
        name,
        idx_type,
        idx_frequency,
        object_version_number,
        description,
        program_id,
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
        l_idx_rec.id,
        l_idx_rec.name,
        l_idx_rec.idx_type,
        l_idx_rec.idx_frequency,
        l_idx_rec.object_version_number,
        l_idx_rec.description,
        l_idx_rec.program_id,
        l_idx_rec.request_id,
        l_idx_rec.program_application_id,
        l_idx_rec.program_update_date,
        l_idx_rec.attribute_category,
        l_idx_rec.attribute1,
        l_idx_rec.attribute2,
        l_idx_rec.attribute3,
        l_idx_rec.attribute4,
        l_idx_rec.attribute5,
        l_idx_rec.attribute6,
        l_idx_rec.attribute7,
        l_idx_rec.attribute8,
        l_idx_rec.attribute9,
        l_idx_rec.attribute10,
        l_idx_rec.attribute11,
        l_idx_rec.attribute12,
        l_idx_rec.attribute13,
        l_idx_rec.attribute14,
        l_idx_rec.attribute15,
        l_idx_rec.created_by,
        l_idx_rec.creation_date,
        l_idx_rec.last_updated_by,
        l_idx_rec.last_update_date,
        l_idx_rec.last_update_login);
    -- Set OUT values
    x_idx_rec := l_idx_rec;
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
  -- insert_row for:OKL_INDICES_V --
  ----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idxv_rec                     IN idxv_rec_type,
    x_idxv_rec                     OUT NOCOPY idxv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idxv_rec                     idxv_rec_type;
    l_def_idxv_rec                 idxv_rec_type;
    l_idx_rec                      idx_rec_type;
    lx_idx_rec                     idx_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_idxv_rec	IN idxv_rec_type
    ) RETURN idxv_rec_type IS
      l_idxv_rec	idxv_rec_type := p_idxv_rec;
    BEGIN
      l_idxv_rec.CREATION_DATE := SYSDATE;
      l_idxv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_idxv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_idxv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_idxv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_idxv_rec);
    END fill_who_columns;
    --------------------------------------
    -- Set_Attributes for:OKL_INDICES_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_idxv_rec IN  idxv_rec_type,
      x_idxv_rec OUT NOCOPY idxv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_idxv_rec := p_idxv_rec;
      x_idxv_rec.OBJECT_VERSION_NUMBER := 1;

	SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
		DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
		DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
		DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
	INTO  x_idxv_rec.REQUEST_ID
		,x_idxv_rec.PROGRAM_APPLICATION_ID
		,x_idxv_rec.PROGRAM_ID
		,x_idxv_rec.PROGRAM_UPDATE_DATE
	FROM DUAL;

      x_idxv_rec.IDX_TYPE := 'BASE';

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
    l_idxv_rec := null_out_defaults(p_idxv_rec);
    -- Set primary key value
    l_idxv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_idxv_rec,                        -- IN
      l_def_idxv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_idxv_rec := fill_who_columns(l_def_idxv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_idxv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_idxv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_idxv_rec, l_idx_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_idx_rec,
      lx_idx_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_idx_rec, l_def_idxv_rec);
    -- Set OUT values
    x_idxv_rec := l_def_idxv_rec;
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
  -- PL/SQL TBL insert_row for:IDXV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idxv_tbl                     IN idxv_tbl_type,
    x_idxv_tbl                     OUT NOCOPY idxv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_idxv_tbl.COUNT > 0) THEN
      i := p_idxv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_idxv_rec                     => p_idxv_tbl(i),
          x_idxv_rec                     => x_idxv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_idxv_tbl.LAST);
        i := p_idxv_tbl.NEXT(i);
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
  ------------------------------
  -- lock_row for:OKL_INDICES --
  ------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idx_rec                      IN idx_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_idx_rec IN idx_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INDICES
     WHERE ID = p_idx_rec.id
       AND OBJECT_VERSION_NUMBER = p_idx_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_idx_rec IN idx_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INDICES
    WHERE ID = p_idx_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INDICES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_INDICES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_INDICES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_idx_rec);
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
      OPEN lchk_csr(p_idx_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_idx_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_idx_rec.object_version_number THEN
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
  -- lock_row for:OKL_INDICES_V --
  --------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idxv_rec                     IN idxv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idx_rec                      idx_rec_type;
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
    migrate(p_idxv_rec, l_idx_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_idx_rec
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
  -- PL/SQL TBL lock_row for:IDXV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idxv_tbl                     IN idxv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_idxv_tbl.COUNT > 0) THEN
      i := p_idxv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_idxv_rec                     => p_idxv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_idxv_tbl.LAST);
        i := p_idxv_tbl.NEXT(i);
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
  --------------------------------
  -- update_row for:OKL_INDICES --
  --------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idx_rec                      IN idx_rec_type,
    x_idx_rec                      OUT NOCOPY idx_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INDICES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idx_rec                      idx_rec_type := p_idx_rec;
    l_def_idx_rec                  idx_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_idx_rec	IN idx_rec_type,
      x_idx_rec	OUT NOCOPY idx_rec_type
    ) RETURN VARCHAR2 IS
      l_idx_rec                      idx_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_idx_rec := p_idx_rec;
      -- Get current database values
      l_idx_rec := get_rec(p_idx_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_idx_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_idx_rec.id := l_idx_rec.id;
      END IF;
      IF (x_idx_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.name := l_idx_rec.name;
      END IF;
      IF (x_idx_rec.idx_type = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.idx_type := l_idx_rec.idx_type;
      END IF;
      IF (x_idx_rec.idx_frequency = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.idx_frequency := l_idx_rec.idx_frequency;
      END IF;
      IF (x_idx_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_idx_rec.object_version_number := l_idx_rec.object_version_number;
      END IF;
      IF (x_idx_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.description := l_idx_rec.description;
      END IF;
      IF (x_idx_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_idx_rec.program_id := l_idx_rec.program_id;
      END IF;
      IF (x_idx_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_idx_rec.request_id := l_idx_rec.request_id;
      END IF;
      IF (x_idx_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_idx_rec.program_application_id := l_idx_rec.program_application_id;
      END IF;
      IF (x_idx_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_idx_rec.program_update_date := l_idx_rec.program_update_date;
      END IF;
      IF (x_idx_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute_category := l_idx_rec.attribute_category;
      END IF;
      IF (x_idx_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute1 := l_idx_rec.attribute1;
      END IF;
      IF (x_idx_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute2 := l_idx_rec.attribute2;
      END IF;
      IF (x_idx_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute3 := l_idx_rec.attribute3;
      END IF;
      IF (x_idx_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute4 := l_idx_rec.attribute4;
      END IF;
      IF (x_idx_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute5 := l_idx_rec.attribute5;
      END IF;
      IF (x_idx_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute6 := l_idx_rec.attribute6;
      END IF;
      IF (x_idx_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute7 := l_idx_rec.attribute7;
      END IF;
      IF (x_idx_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute8 := l_idx_rec.attribute8;
      END IF;
      IF (x_idx_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute9 := l_idx_rec.attribute9;
      END IF;
      IF (x_idx_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute10 := l_idx_rec.attribute10;
      END IF;
      IF (x_idx_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute11 := l_idx_rec.attribute11;
      END IF;
      IF (x_idx_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute12 := l_idx_rec.attribute12;
      END IF;
      IF (x_idx_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute13 := l_idx_rec.attribute13;
      END IF;
      IF (x_idx_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute14 := l_idx_rec.attribute14;
      END IF;
      IF (x_idx_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_idx_rec.attribute15 := l_idx_rec.attribute15;
      END IF;
      IF (x_idx_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_idx_rec.created_by := l_idx_rec.created_by;
      END IF;
      IF (x_idx_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_idx_rec.creation_date := l_idx_rec.creation_date;
      END IF;
      IF (x_idx_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_idx_rec.last_updated_by := l_idx_rec.last_updated_by;
      END IF;
      IF (x_idx_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_idx_rec.last_update_date := l_idx_rec.last_update_date;
      END IF;
      IF (x_idx_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_idx_rec.last_update_login := l_idx_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------
    -- Set_Attributes for:OKL_INDICES --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_idx_rec IN  idx_rec_type,
      x_idx_rec OUT NOCOPY idx_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_idx_rec := p_idx_rec;
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
      p_idx_rec,                         -- IN
      l_idx_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_idx_rec, l_def_idx_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKL_INDICES
    SET NAME = l_def_idx_rec.name,
        IDX_TYPE = l_def_idx_rec.idx_type,
        IDX_FREQUENCY = l_def_idx_rec.idx_frequency,
        OBJECT_VERSION_NUMBER = l_def_idx_rec.object_version_number,
        DESCRIPTION = l_def_idx_rec.description,
        PROGRAM_ID = l_def_idx_rec.program_id,
        REQUEST_ID = l_def_idx_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_idx_rec.program_application_id,
        PROGRAM_UPDATE_DATE = l_def_idx_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_idx_rec.attribute_category,
        ATTRIBUTE1 = l_def_idx_rec.attribute1,
        ATTRIBUTE2 = l_def_idx_rec.attribute2,
        ATTRIBUTE3 = l_def_idx_rec.attribute3,
        ATTRIBUTE4 = l_def_idx_rec.attribute4,
        ATTRIBUTE5 = l_def_idx_rec.attribute5,
        ATTRIBUTE6 = l_def_idx_rec.attribute6,
        ATTRIBUTE7 = l_def_idx_rec.attribute7,
        ATTRIBUTE8 = l_def_idx_rec.attribute8,
        ATTRIBUTE9 = l_def_idx_rec.attribute9,
        ATTRIBUTE10 = l_def_idx_rec.attribute10,
        ATTRIBUTE11 = l_def_idx_rec.attribute11,
        ATTRIBUTE12 = l_def_idx_rec.attribute12,
        ATTRIBUTE13 = l_def_idx_rec.attribute13,
        ATTRIBUTE14 = l_def_idx_rec.attribute14,
        ATTRIBUTE15 = l_def_idx_rec.attribute15,
        CREATED_BY = l_def_idx_rec.created_by,
        CREATION_DATE = l_def_idx_rec.creation_date,
        LAST_UPDATED_BY = l_def_idx_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_idx_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_idx_rec.last_update_login
    WHERE ID = l_def_idx_rec.id;

    x_idx_rec := l_def_idx_rec;
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
  -- update_row for:OKL_INDICES_V --
  ----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idxv_rec                     IN idxv_rec_type,
    x_idxv_rec                     OUT NOCOPY idxv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idxv_rec                     idxv_rec_type := p_idxv_rec;
    l_def_idxv_rec                 idxv_rec_type;
    l_idx_rec                      idx_rec_type;
    lx_idx_rec                     idx_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_idxv_rec	IN idxv_rec_type
    ) RETURN idxv_rec_type IS
      l_idxv_rec	idxv_rec_type := p_idxv_rec;
    BEGIN
      l_idxv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_idxv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_idxv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_idxv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_idxv_rec	IN idxv_rec_type,
      x_idxv_rec	OUT NOCOPY idxv_rec_type
    ) RETURN VARCHAR2 IS
      l_idxv_rec                     idxv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_idxv_rec := p_idxv_rec;
      -- Get current database values
      l_idxv_rec := get_rec(p_idxv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_idxv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_idxv_rec.id := l_idxv_rec.id;
      END IF;
      IF (x_idxv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_idxv_rec.object_version_number := l_idxv_rec.object_version_number;
      END IF;
      IF (x_idxv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.name := l_idxv_rec.name;
      END IF;
      IF (x_idxv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.description := l_idxv_rec.description;
      END IF;
      IF (x_idxv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute_category := l_idxv_rec.attribute_category;
      END IF;
      IF (x_idxv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute1 := l_idxv_rec.attribute1;
      END IF;
      IF (x_idxv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute2 := l_idxv_rec.attribute2;
      END IF;
      IF (x_idxv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute3 := l_idxv_rec.attribute3;
      END IF;
      IF (x_idxv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute4 := l_idxv_rec.attribute4;
      END IF;
      IF (x_idxv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute5 := l_idxv_rec.attribute5;
      END IF;
      IF (x_idxv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute6 := l_idxv_rec.attribute6;
      END IF;
      IF (x_idxv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute7 := l_idxv_rec.attribute7;
      END IF;
      IF (x_idxv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute8 := l_idxv_rec.attribute8;
      END IF;
      IF (x_idxv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute9 := l_idxv_rec.attribute9;
      END IF;
      IF (x_idxv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute10 := l_idxv_rec.attribute10;
      END IF;
      IF (x_idxv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute11 := l_idxv_rec.attribute11;
      END IF;
      IF (x_idxv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute12 := l_idxv_rec.attribute12;
      END IF;
      IF (x_idxv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute13 := l_idxv_rec.attribute13;
      END IF;
      IF (x_idxv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute14 := l_idxv_rec.attribute14;
      END IF;
      IF (x_idxv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.attribute15 := l_idxv_rec.attribute15;
      END IF;
      IF (x_idxv_rec.idx_type = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.idx_type := l_idxv_rec.idx_type;
      END IF;
      IF (x_idxv_rec.idx_frequency = OKC_API.G_MISS_CHAR)
      THEN
        x_idxv_rec.idx_frequency := l_idxv_rec.idx_frequency;
      END IF;
      IF (x_idxv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_idxv_rec.program_id := l_idxv_rec.program_id;
      END IF;
      IF (x_idxv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_idxv_rec.request_id := l_idxv_rec.request_id;
      END IF;
      IF (x_idxv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_idxv_rec.program_application_id := l_idxv_rec.program_application_id;
      END IF;
      IF (x_idxv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_idxv_rec.program_update_date := l_idxv_rec.program_update_date;
      END IF;
      IF (x_idxv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_idxv_rec.created_by := l_idxv_rec.created_by;
      END IF;
      IF (x_idxv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_idxv_rec.creation_date := l_idxv_rec.creation_date;
      END IF;
      IF (x_idxv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_idxv_rec.last_updated_by := l_idxv_rec.last_updated_by;
      END IF;
      IF (x_idxv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_idxv_rec.last_update_date := l_idxv_rec.last_update_date;
      END IF;
      IF (x_idxv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_idxv_rec.last_update_login := l_idxv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKL_INDICES_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_idxv_rec IN  idxv_rec_type,
      x_idxv_rec OUT NOCOPY idxv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_idxv_rec := p_idxv_rec;

      SELECT NVL(DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
                               x_idxv_rec.request_id),
	     NVL(DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
		        x_idxv_rec.PROGRAM_APPLICATION_ID),
	     NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
		        x_idxv_rec.PROGRAM_ID),
		DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE),NULL,
		             x_idxv_rec.PROGRAM_UPDATE_DATE,SYSDATE)
	INTO  x_idxv_rec.REQUEST_ID
		,x_idxv_rec.PROGRAM_APPLICATION_ID
		,x_idxv_rec.PROGRAM_ID
		,x_idxv_rec.PROGRAM_UPDATE_DATE
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
      p_idxv_rec,                        -- IN
      l_idxv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_idxv_rec, l_def_idxv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_idxv_rec := fill_who_columns(l_def_idxv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_idxv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_idxv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

-- Changes Ends

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_idxv_rec, l_idx_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_idx_rec,
      lx_idx_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_idx_rec, l_def_idxv_rec);
    x_idxv_rec := l_def_idxv_rec;
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
  -- PL/SQL TBL update_row for:IDXV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idxv_tbl                     IN idxv_tbl_type,
    x_idxv_tbl                     OUT NOCOPY idxv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_idxv_tbl.COUNT > 0) THEN
      i := p_idxv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_idxv_rec                     => p_idxv_tbl(i),
          x_idxv_rec                     => x_idxv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_idxv_tbl.LAST);
        i := p_idxv_tbl.NEXT(i);
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
  --------------------------------
  -- delete_row for:OKL_INDICES --
  --------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idx_rec                      IN idx_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INDICES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idx_rec                      idx_rec_type:= p_idx_rec;
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
    DELETE FROM OKL_INDICES
     WHERE ID = l_idx_rec.id;

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
  -- delete_row for:OKL_INDICES_V --
  ----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idxv_rec                     IN idxv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_idxv_rec                     idxv_rec_type := p_idxv_rec;
    l_idx_rec                      idx_rec_type;
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
    migrate(l_idxv_rec, l_idx_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_idx_rec
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
  -- PL/SQL TBL delete_row for:IDXV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idxv_tbl                     IN idxv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_idxv_tbl.COUNT > 0) THEN
      i := p_idxv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_idxv_rec                     => p_idxv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_idxv_tbl.LAST);
        i := p_idxv_tbl.NEXT(i);
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
END OKL_IDX_PVT;

/
