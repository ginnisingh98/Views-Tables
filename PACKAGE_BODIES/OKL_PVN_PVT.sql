--------------------------------------------------------
--  DDL for Package Body OKL_PVN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PVN_PVT" AS
/* $Header: OKLSPVNB.pls 115.13 2002/12/18 13:06:11 kjinger noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
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
  -- FUNCTION get_rec for: OKL_PROVISIONS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pvn_rec                      IN pvn_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pvn_rec_type IS
    CURSOR okl_provisions_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            NAME,
            app_debit_ccid,
            rev_credit_ccid,
            rev_debit_ccid,
            app_credit_ccid,
            SET_OF_BOOKS_ID,
            OBJECT_VERSION_NUMBER,
            VERSION,
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
      FROM Okl_Provisions
     WHERE okl_provisions.id    = p_id;
    l_okl_provisions_pk            okl_provisions_pk_csr%ROWTYPE;
    l_pvn_rec                      pvn_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_provisions_pk_csr (p_pvn_rec.id);
    FETCH okl_provisions_pk_csr INTO
              l_pvn_rec.ID,
              l_pvn_rec.NAME,
              l_pvn_rec.app_debit_ccid,
              l_pvn_rec.rev_credit_ccid,
              l_pvn_rec.rev_debit_ccid,
              l_pvn_rec.app_credit_ccid,
              l_pvn_rec.SET_OF_BOOKS_ID,
              l_pvn_rec.OBJECT_VERSION_NUMBER,
              l_pvn_rec.VERSION,
              l_pvn_rec.DESCRIPTION,
              l_pvn_rec.FROM_DATE,
              l_pvn_rec.TO_DATE,
              l_pvn_rec.ATTRIBUTE_CATEGORY,
              l_pvn_rec.ATTRIBUTE1,
              l_pvn_rec.ATTRIBUTE2,
              l_pvn_rec.ATTRIBUTE3,
              l_pvn_rec.ATTRIBUTE4,
              l_pvn_rec.ATTRIBUTE5,
              l_pvn_rec.ATTRIBUTE6,
              l_pvn_rec.ATTRIBUTE7,
              l_pvn_rec.ATTRIBUTE8,
              l_pvn_rec.ATTRIBUTE9,
              l_pvn_rec.ATTRIBUTE10,
              l_pvn_rec.ATTRIBUTE11,
              l_pvn_rec.ATTRIBUTE12,
              l_pvn_rec.ATTRIBUTE13,
              l_pvn_rec.ATTRIBUTE14,
              l_pvn_rec.ATTRIBUTE15,
              l_pvn_rec.CREATED_BY,
              l_pvn_rec.CREATION_DATE,
              l_pvn_rec.LAST_UPDATED_BY,
              l_pvn_rec.LAST_UPDATE_DATE,
              l_pvn_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_provisions_pk_csr%NOTFOUND;
    CLOSE okl_provisions_pk_csr;
    RETURN(l_pvn_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pvn_rec                      IN pvn_rec_type
  ) RETURN pvn_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pvn_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PROVISIONS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pvnv_rec                     IN pvnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pvnv_rec_type IS
    CURSOR okl_pvnv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            app_debit_ccid,
            rev_credit_ccid,
            rev_debit_ccid,
            SET_OF_BOOKS_ID,
            app_credit_ccid,
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
            VERSION,
            FROM_DATE,
            TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Provisions_V
     WHERE okl_provisions_v.id  = p_id;
    l_okl_pvnv_pk                  okl_pvnv_pk_csr%ROWTYPE;
    l_pvnv_rec                     pvnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pvnv_pk_csr (p_pvnv_rec.id);
    FETCH okl_pvnv_pk_csr INTO
              l_pvnv_rec.ID,
              l_pvnv_rec.OBJECT_VERSION_NUMBER,
              l_pvnv_rec.app_debit_ccid,
              l_pvnv_rec.rev_credit_ccid,
              l_pvnv_rec.rev_debit_ccid,
              l_pvnv_rec.SET_OF_BOOKS_ID,
              l_pvnv_rec.app_credit_ccid,
              l_pvnv_rec.NAME,
              l_pvnv_rec.DESCRIPTION,
              l_pvnv_rec.ATTRIBUTE_CATEGORY,
              l_pvnv_rec.ATTRIBUTE1,
              l_pvnv_rec.ATTRIBUTE2,
              l_pvnv_rec.ATTRIBUTE3,
              l_pvnv_rec.ATTRIBUTE4,
              l_pvnv_rec.ATTRIBUTE5,
              l_pvnv_rec.ATTRIBUTE6,
              l_pvnv_rec.ATTRIBUTE7,
              l_pvnv_rec.ATTRIBUTE8,
              l_pvnv_rec.ATTRIBUTE9,
              l_pvnv_rec.ATTRIBUTE10,
              l_pvnv_rec.ATTRIBUTE11,
              l_pvnv_rec.ATTRIBUTE12,
              l_pvnv_rec.ATTRIBUTE13,
              l_pvnv_rec.ATTRIBUTE14,
              l_pvnv_rec.ATTRIBUTE15,
              l_pvnv_rec.VERSION,
              l_pvnv_rec.FROM_DATE,
              l_pvnv_rec.TO_DATE,
              l_pvnv_rec.CREATED_BY,
              l_pvnv_rec.CREATION_DATE,
              l_pvnv_rec.LAST_UPDATED_BY,
              l_pvnv_rec.LAST_UPDATE_DATE,
              l_pvnv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pvnv_pk_csr%NOTFOUND;
    CLOSE okl_pvnv_pk_csr;
    RETURN(l_pvnv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pvnv_rec                     IN pvnv_rec_type
  ) RETURN pvnv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pvnv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_PROVISIONS_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pvnv_rec	IN pvnv_rec_type
  ) RETURN pvnv_rec_type IS
    l_pvnv_rec	pvnv_rec_type := p_pvnv_rec;
  BEGIN
    IF (l_pvnv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_pvnv_rec.object_version_number := NULL;
    END IF;
    IF (l_pvnv_rec.app_debit_ccid = Okc_Api.G_MISS_NUM) THEN
      l_pvnv_rec.app_debit_ccid := NULL;
    END IF;
    IF (l_pvnv_rec.rev_credit_ccid = Okc_Api.G_MISS_NUM) THEN
      l_pvnv_rec.rev_credit_ccid := NULL;
    END IF;
    IF (l_pvnv_rec.rev_debit_ccid = Okc_Api.G_MISS_NUM) THEN
      l_pvnv_rec.rev_debit_ccid := NULL;
    END IF;
    IF (l_pvnv_rec.set_of_books_id = Okc_Api.G_MISS_NUM) THEN
      l_pvnv_rec.set_of_books_id := NULL;
    END IF;
    IF (l_pvnv_rec.app_credit_ccid = Okc_Api.G_MISS_NUM) THEN
      l_pvnv_rec.app_credit_ccid := NULL;
    END IF;
    IF (l_pvnv_rec.name = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.name := NULL;
    END IF;
    IF (l_pvnv_rec.description = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.description := NULL;
    END IF;
    IF (l_pvnv_rec.attribute_category = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute_category := NULL;
    END IF;
    IF (l_pvnv_rec.attribute1 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute1 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute2 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute2 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute3 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute3 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute4 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute4 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute5 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute5 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute6 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute6 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute7 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute7 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute8 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute8 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute9 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute9 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute10 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute10 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute11 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute11 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute12 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute12 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute13 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute13 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute14 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute14 := NULL;
    END IF;
    IF (l_pvnv_rec.attribute15 = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.attribute15 := NULL;
    END IF;
    IF (l_pvnv_rec.version = Okc_Api.G_MISS_CHAR) THEN
      l_pvnv_rec.version := NULL;
    END IF;
    IF (l_pvnv_rec.from_date = Okc_Api.G_MISS_DATE) THEN
      l_pvnv_rec.from_date := NULL;
    END IF;
    IF (l_pvnv_rec.TO_DATE = Okc_Api.G_MISS_DATE) THEN
      l_pvnv_rec.TO_DATE := NULL;
    END IF;
    IF (l_pvnv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_pvnv_rec.created_by := NULL;
    END IF;
    IF (l_pvnv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_pvnv_rec.creation_date := NULL;
    END IF;
    IF (l_pvnv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_pvnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pvnv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_pvnv_rec.last_update_date := NULL;
    END IF;
    IF (l_pvnv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_pvnv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_pvnv_rec);
  END null_out_defaults;
  /**** Commenting out nocopy generated code in favour of hand written code ********
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_PROVISIONS_V --
  ----------------------------------------------
  Function Validate_Attributes (
    p_pvnv_rec IN  pvnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    IF p_pvnv_rec.id = Okc_Api.G_MISS_NUM OR
       p_pvnv_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_pvnv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
          p_pvnv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_pvnv_rec.app_debit_ccid = Okc_Api.G_MISS_NUM OR
          p_pvnv_rec.app_debit_ccid IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'app_debit_ccid');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_pvnv_rec.rev_credit_ccid = Okc_Api.G_MISS_NUM OR
          p_pvnv_rec.rev_credit_ccid IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rev_credit_ccid');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_pvnv_rec.rev_debit_ccid = Okc_Api.G_MISS_NUM OR
          p_pvnv_rec.rev_debit_ccid IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rev_debit_ccid');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_pvnv_rec.set_of_books_id = Okc_Api.G_MISS_NUM OR
          p_pvnv_rec.set_of_books_id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'set_of_books_id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_pvnv_rec.app_credit_ccid = Okc_Api.G_MISS_NUM OR
          p_pvnv_rec.app_credit_ccid IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'app_credit_ccid');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_pvnv_rec.name = Okc_Api.G_MISS_CHAR OR
          p_pvnv_rec.name IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_pvnv_rec.version = Okc_Api.G_MISS_CHAR OR
          p_pvnv_rec.version IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'version');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_pvnv_rec.from_date = Okc_Api.G_MISS_DATE OR
          p_pvnv_rec.from_date IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'from_date');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKL_PROVISIONS_V --
  ------------------------------------------
  Function Validate_Record (
    p_pvnv_rec IN pvnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  **************** End Commenting generated code ***************************/

  /*************************** Hand Coded **********************************/

    ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Object_Version_Number
  -- Description     : Validates the object version number for null
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(x_return_status OUT NOCOPY  VARCHAR2
  										  ,p_pvnv_rec      IN   pvnv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_pvnv_rec.object_version_number IS NULL) OR
       (p_pvnv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'object_version_number');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

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
  PROCEDURE Validate_Id (x_return_status OUT NOCOPY  VARCHAR2
  						,p_pvnv_rec      IN   pvnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_pvnv_rec.id IS NULL) OR
       (p_pvnv_rec.id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'id');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Version
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Version
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Version(x_return_status OUT NOCOPY  VARCHAR2
  							,p_pvnv_rec      IN   pvnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_pvnv_rec.version IS NULL) OR
       (p_pvnv_rec.version = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'version');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Version;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Set_Of_Books_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Set_Of_Books_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Set_Of_Books_Id(x_return_status OUT NOCOPY  VARCHAR2
  							,p_pvnv_rec      IN   pvnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_pvnv_rec.set_of_books_id IS NULL) OR
       (p_pvnv_rec.set_of_books_id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'set_of_books_id');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Set_Of_Books_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Name(x_return_status OUT NOCOPY  VARCHAR2
  						 ,p_pvnv_rec      IN   pvnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;


  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_pvnv_rec.name IS NULL) OR
       (p_pvnv_rec.name = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'name');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_App_Debit_CCID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_App_Debit_CCID
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_App_Debit_CCID
  			(x_return_status OUT NOCOPY  VARCHAR2
  			,p_pvnv_rec      IN   pvnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy			  VARCHAR2(1)  := OKC_API.G_FALSE;

  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pvnv_rec.app_debit_ccid IS NULL) OR
       (p_pvnv_rec.app_debit_ccid = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'app_debit_ccid');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

	-- check if ccid is a valid ccid
    IF (p_pvnv_rec.app_debit_CCID IS NOT NULL) AND
       (p_pvnv_rec.app_debit_CCID <> Okc_Api.G_MISS_NUM) THEN

        l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_pvnv_rec.app_debit_CCID);
        IF (l_dummy = OKC_API.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'app_debit_ccid' );
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
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
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_App_Debit_CCID;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_App_Credit_CCID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_App_Credit_CCID
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_App_Credit_CCID
  			(x_return_status OUT NOCOPY  VARCHAR2
  			,p_pvnv_rec      IN   pvnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy			  VARCHAR2(1)  := OKC_API.G_FALSE;

  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pvnv_rec.app_credit_ccid IS NULL) OR
       (p_pvnv_rec.app_credit_ccid = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'app_credit_ccid');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

	-- check if ccid is valid
    IF (p_pvnv_rec.app_credit_CCID IS NOT NULL) AND
       (p_pvnv_rec.app_credit_CCID <> Okc_Api.G_MISS_NUM) THEN

        l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_pvnv_rec.app_credit_CCID);
        IF (l_dummy = OKC_API.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'app_credit_ccid' );
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
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
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_App_credit_CCID;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Rev_Credit_CCID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Rev_Credit_CCID
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Rev_Credit_CCID
  			(x_return_status OUT NOCOPY  VARCHAR2
  			,p_pvnv_rec      IN   pvnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy			  VARCHAR2(1)  := OKC_API.G_FALSE;

  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pvnv_rec.rev_credit_ccid IS NULL) OR
       (p_pvnv_rec.rev_credit_ccid = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'rev_credit_ccid');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

	--check if ccid is valid
    IF (p_pvnv_rec.Rev_credit_CCID IS NOT NULL) AND
       (p_pvnv_rec.Rev_credit_CCID <> Okc_Api.G_MISS_NUM) THEN

        l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_pvnv_rec.Rev_credit_CCID);
        IF (l_dummy = OKC_API.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'Rev_credit_ccid' );
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
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
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Rev_credit_CCID;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Rev_Debit_CCID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Rev_Debit_CCID
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Rev_Debit_CCID
  			(x_return_status OUT NOCOPY  VARCHAR2
  			,p_pvnv_rec      IN   pvnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy			  VARCHAR2(1)  :=  OKC_API.G_FALSE;

  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pvnv_rec.rev_debit_ccid IS NULL) OR
       (p_pvnv_rec.rev_debit_ccid = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'rev_debit_ccid');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    --check if ccid is valid
    IF (p_pvnv_rec.rev_Debit_CCID IS NOT NULL) AND
       (p_pvnv_rec.rev_Debit_CCID <> Okc_Api.G_MISS_NUM) THEN

        l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_pvnv_rec.rev_Debit_CCID);
        IF (l_dummy = OKC_API.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'rev_Debit_CCID' );
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
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
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_rev_Debit_CCID;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_From_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_From_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_From_Date(x_return_status OUT NOCOPY  VARCHAR2
  							,p_pvnv_rec      IN   pvnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_pvnv_rec.from_date IS NULL) OR
       (p_pvnv_rec.from_date = Okc_Api.G_MISS_DATE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'from_date');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_From_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_To_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_To_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_To_Date(x_return_status OUT NOCOPY  VARCHAR2
  							,p_pvnv_rec      IN   pvnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	IF (p_pvnv_rec.TO_DATE IS NOT NULL) AND (p_pvnv_rec.TO_DATE <> OKC_API.G_MISS_DATE) THEN
	  IF p_pvnv_rec.TO_DATE < p_pvnv_rec.from_date THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'to_date');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
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
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_To_Date;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Pvn_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Pvn_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Unique_Pvn_Record(x_return_status OUT NOCOPY  VARCHAR2
  									  ,p_pvnv_rec      IN   pvnv_rec_type)
  IS

  l_dummy                 VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;

    CURSOR unique_pvn_csr(p_name okl_provisions_v.name%TYPE
		  			     ,p_version okl_provisions_v.version%TYPE
						 ,p_id okl_provisions_v.id%TYPE) IS
    SELECT 1
    FROM okl_provisions_v
    WHERE  name = p_name
    AND    version = p_version
	AND    id <> p_id;


  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    OPEN unique_pvn_csr(p_pvnv_rec.name,
		  p_pvnv_rec.version, p_pvnv_rec.id);
    FETCH unique_pvn_csr INTO l_dummy;
    l_row_found := unique_pvn_csr%FOUND;
    CLOSE unique_pvn_csr;
    IF l_row_found THEN
		Okc_Api.set_message(G_APP_NAME,G_UNQS);
		x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Pvn_Record;

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
    p_pvnv_rec IN  pvnv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN

     -- call each column-level validation

    -- Validate_Id
    Validate_Id(x_return_status,p_pvnv_rec );
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(x_return_status,p_pvnv_rec );
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_Name
    Validate_Name(x_return_status,p_pvnv_rec );
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;


    -- Validate_Version
       Validate_Version(x_return_status,p_pvnv_rec );
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_Set_Of_Books_Id
       Validate_Set_Of_Books_Id(x_return_status,p_pvnv_rec );
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_App_Debit_CCID
       Validate_App_Debit_CCID(x_return_status,p_pvnv_rec );
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_App_Credit_CCID
       Validate_App_Credit_CCID(x_return_status,p_pvnv_rec );
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_Rev_Debit_CCID
       Validate_Rev_Debit_CCID(x_return_status,p_pvnv_rec );
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_Rev_Credit_CCID
       Validate_Rev_Credit_CCID(x_return_status,p_pvnv_rec );
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_From_Date
       Validate_From_Date(x_return_status,p_pvnv_rec );
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
          END IF;
       END IF;

    -- Validate_To_Date
       Validate_To_Date(x_return_status,p_pvnv_rec );
    -- store the highest degree of error
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
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

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Record (
    p_pvnv_rec IN pvnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN

    -- Validate_Unique_Pvn_Record
      Validate_Unique_Pvn_Record(x_return_status,p_pvnv_rec );
      -- store the highest degree of error
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to leave
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
            -- record that there was an error
            l_return_status := x_return_status;
        END IF;
      END IF;

  RETURN(l_return_status);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;
    RETURN (l_return_status);

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Record;

/************************ END HAND CODING **********************************/


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN pvnv_rec_type,
    p_to	IN OUT NOCOPY pvn_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.app_debit_ccid := p_from.app_debit_ccid;
    p_to.rev_credit_ccid := p_from.rev_credit_ccid;
    p_to.rev_debit_ccid := p_from.rev_debit_ccid;
    p_to.app_credit_ccid := p_from.app_credit_ccid;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.version := p_from.version;
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
    p_from	IN pvn_rec_type,
    p_to	IN OUT NOCOPY pvnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.app_debit_ccid := p_from.app_debit_ccid;
    p_to.rev_credit_ccid := p_from.rev_credit_ccid;
    p_to.rev_debit_ccid := p_from.rev_debit_ccid;
    p_to.app_credit_ccid := p_from.app_credit_ccid;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.version := p_from.version;
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
  ---------------------------------------
  -- validate_row for:OKL_PROVISIONS_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN pvnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pvnv_rec                     pvnv_rec_type := p_pvnv_rec;
    l_pvn_rec                      pvn_rec_type;
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
    l_return_status := Validate_Attributes(l_pvnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pvnv_rec);
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL validate_row for:PVNV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN pvnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pvnv_tbl.COUNT > 0) THEN
      i := p_pvnv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pvnv_rec                     => p_pvnv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_pvnv_tbl.LAST);
        i := p_pvnv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -----------------------------------
  -- insert_row for:OKL_PROVISIONS --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvn_rec                      IN pvn_rec_type,
    x_pvn_rec                      OUT NOCOPY pvn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PROVISIONS_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pvn_rec                      pvn_rec_type := p_pvn_rec;
    l_def_pvn_rec                  pvn_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKL_PROVISIONS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_pvn_rec IN  pvn_rec_type,
      x_pvn_rec OUT NOCOPY pvn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_pvn_rec := p_pvn_rec;
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
      p_pvn_rec,                         -- IN
      l_pvn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_PROVISIONS(
        id,
        name,
        app_debit_ccid,
        rev_credit_ccid,
        rev_debit_ccid,
        app_credit_ccid,
        set_of_books_id,
        object_version_number,
        version,
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
        l_pvn_rec.id,
        l_pvn_rec.name,
        l_pvn_rec.app_debit_ccid,
        l_pvn_rec.rev_credit_ccid,
        l_pvn_rec.rev_debit_ccid,
        l_pvn_rec.app_credit_ccid,
        l_pvn_rec.set_of_books_id,
        l_pvn_rec.object_version_number,
        l_pvn_rec.version,
        l_pvn_rec.description,
        l_pvn_rec.from_date,
        l_pvn_rec.TO_DATE,
        l_pvn_rec.attribute_category,
        l_pvn_rec.attribute1,
        l_pvn_rec.attribute2,
        l_pvn_rec.attribute3,
        l_pvn_rec.attribute4,
        l_pvn_rec.attribute5,
        l_pvn_rec.attribute6,
        l_pvn_rec.attribute7,
        l_pvn_rec.attribute8,
        l_pvn_rec.attribute9,
        l_pvn_rec.attribute10,
        l_pvn_rec.attribute11,
        l_pvn_rec.attribute12,
        l_pvn_rec.attribute13,
        l_pvn_rec.attribute14,
        l_pvn_rec.attribute15,
        l_pvn_rec.created_by,
        l_pvn_rec.creation_date,
        l_pvn_rec.last_updated_by,
        l_pvn_rec.last_update_date,
        l_pvn_rec.last_update_login);
    -- Set OUT values
    x_pvn_rec := l_pvn_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -------------------------------------
  -- insert_row for:OKL_PROVISIONS_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN pvnv_rec_type,
    x_pvnv_rec                     OUT NOCOPY pvnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pvnv_rec                     pvnv_rec_type;
    l_def_pvnv_rec                 pvnv_rec_type;
    l_pvn_rec                      pvn_rec_type;
    lx_pvn_rec                     pvn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pvnv_rec	IN pvnv_rec_type
    ) RETURN pvnv_rec_type IS
      l_pvnv_rec	pvnv_rec_type := p_pvnv_rec;
    BEGIN
      l_pvnv_rec.CREATION_DATE := SYSDATE;
      l_pvnv_rec.CREATED_BY := Fnd_Global.User_Id;
      l_pvnv_rec.LAST_UPDATE_DATE := l_pvnv_rec.CREATION_DATE;
      l_pvnv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_pvnv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_pvnv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKL_PROVISIONS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_pvnv_rec IN  pvnv_rec_type,
      x_pvnv_rec OUT NOCOPY pvnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_pvnv_rec := p_pvnv_rec;
      x_pvnv_rec.OBJECT_VERSION_NUMBER := 1;
      x_pvnv_rec.set_of_books_id := OKL_ACCOUNTING_UTIL.GET_SET_OF_BOOKS_ID;
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
    l_pvnv_rec := null_out_defaults(p_pvnv_rec);
    -- Set primary key value
    l_pvnv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_pvnv_rec,                        -- IN
      l_def_pvnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_pvnv_rec := fill_who_columns(l_def_pvnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pvnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pvnv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pvnv_rec, l_pvn_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pvn_rec,
      lx_pvn_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pvn_rec, l_def_pvnv_rec);
    -- Set OUT values
    x_pvnv_rec := l_def_pvnv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL insert_row for:PVNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pvnv_tbl.COUNT > 0) THEN
      i := p_pvnv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pvnv_rec                     => p_pvnv_tbl(i),
          x_pvnv_rec                     => x_pvnv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_pvnv_tbl.LAST);
        i := p_pvnv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_Return_status := l_overall_status;

  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  ---------------------------------
  -- lock_row for:OKL_PROVISIONS --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvn_rec                      IN pvn_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pvn_rec IN pvn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PROVISIONS
     WHERE ID = p_pvn_rec.id
       AND OBJECT_VERSION_NUMBER = p_pvn_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_pvn_rec IN pvn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PROVISIONS
    WHERE ID = p_pvn_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PROVISIONS_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_PROVISIONS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_PROVISIONS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_pvn_rec);
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
      OPEN lchk_csr(p_pvn_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pvn_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pvn_rec.object_version_number THEN
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -----------------------------------
  -- lock_row for:OKL_PROVISIONS_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN pvnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pvn_rec                      pvn_rec_type;
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
    migrate(p_pvnv_rec, l_pvn_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pvn_rec
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL lock_row for:PVNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN pvnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pvnv_tbl.COUNT > 0) THEN
      i := p_pvnv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pvnv_rec                     => p_pvnv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_pvnv_tbl.LAST);
        i := p_pvnv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -----------------------------------
  -- update_row for:OKL_PROVISIONS --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvn_rec                      IN pvn_rec_type,
    x_pvn_rec                      OUT NOCOPY pvn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PROVISIONS_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pvn_rec                      pvn_rec_type := p_pvn_rec;
    l_def_pvn_rec                  pvn_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pvn_rec	IN pvn_rec_type,
      x_pvn_rec	OUT NOCOPY pvn_rec_type
    ) RETURN VARCHAR2 IS
      l_pvn_rec                      pvn_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_pvn_rec := p_pvn_rec;
      -- Get current database values
      l_pvn_rec := get_rec(p_pvn_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pvn_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_pvn_rec.id := l_pvn_rec.id;
      END IF;
      IF (x_pvn_rec.name = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.name := l_pvn_rec.name;
      END IF;
      IF (x_pvn_rec.app_debit_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_pvn_rec.app_debit_ccid := l_pvn_rec.app_debit_ccid;
      END IF;
      IF (x_pvn_rec.rev_credit_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_pvn_rec.rev_credit_ccid := l_pvn_rec.rev_credit_ccid;
      END IF;
      IF (x_pvn_rec.rev_debit_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_pvn_rec.rev_debit_ccid := l_pvn_rec.rev_debit_ccid;
      END IF;
      IF (x_pvn_rec.app_credit_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_pvn_rec.app_credit_ccid := l_pvn_rec.app_credit_ccid;
      END IF;
      IF (x_pvn_rec.set_of_books_id = Okc_Api.G_MISS_NUM)
      THEN
        x_pvn_rec.set_of_books_id := l_pvn_rec.set_of_books_id;
      END IF;
      IF (x_pvn_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_pvn_rec.object_version_number := l_pvn_rec.object_version_number;
      END IF;
      IF (x_pvn_rec.version = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.version := l_pvn_rec.version;
      END IF;
      IF (x_pvn_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.description := l_pvn_rec.description;
      END IF;
      IF (x_pvn_rec.from_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pvn_rec.from_date := l_pvn_rec.from_date;
      END IF;
      IF (x_pvn_rec.TO_DATE = Okc_Api.G_MISS_DATE)
      THEN
        x_pvn_rec.TO_DATE := l_pvn_rec.TO_DATE;
      END IF;
      IF (x_pvn_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute_category := l_pvn_rec.attribute_category;
      END IF;
      IF (x_pvn_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute1 := l_pvn_rec.attribute1;
      END IF;
      IF (x_pvn_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute2 := l_pvn_rec.attribute2;
      END IF;
      IF (x_pvn_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute3 := l_pvn_rec.attribute3;
      END IF;
      IF (x_pvn_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute4 := l_pvn_rec.attribute4;
      END IF;
      IF (x_pvn_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute5 := l_pvn_rec.attribute5;
      END IF;
      IF (x_pvn_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute6 := l_pvn_rec.attribute6;
      END IF;
      IF (x_pvn_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute7 := l_pvn_rec.attribute7;
      END IF;
      IF (x_pvn_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute8 := l_pvn_rec.attribute8;
      END IF;
      IF (x_pvn_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute9 := l_pvn_rec.attribute9;
      END IF;
      IF (x_pvn_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute10 := l_pvn_rec.attribute10;
      END IF;
      IF (x_pvn_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute11 := l_pvn_rec.attribute11;
      END IF;
      IF (x_pvn_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute12 := l_pvn_rec.attribute12;
      END IF;
      IF (x_pvn_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute13 := l_pvn_rec.attribute13;
      END IF;
      IF (x_pvn_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute14 := l_pvn_rec.attribute14;
      END IF;
      IF (x_pvn_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvn_rec.attribute15 := l_pvn_rec.attribute15;
      END IF;
      IF (x_pvn_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_pvn_rec.created_by := l_pvn_rec.created_by;
      END IF;
      IF (x_pvn_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pvn_rec.creation_date := l_pvn_rec.creation_date;
      END IF;
      IF (x_pvn_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_pvn_rec.last_updated_by := l_pvn_rec.last_updated_by;
      END IF;
      IF (x_pvn_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pvn_rec.last_update_date := l_pvn_rec.last_update_date;
      END IF;
      IF (x_pvn_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_pvn_rec.last_update_login := l_pvn_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_PROVISIONS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_pvn_rec IN  pvn_rec_type,
      x_pvn_rec OUT NOCOPY pvn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_pvn_rec := p_pvn_rec;
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
      p_pvn_rec,                         -- IN
      l_pvn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pvn_rec, l_def_pvn_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_PROVISIONS
    SET NAME = l_def_pvn_rec.name,
        app_debit_ccid = l_def_pvn_rec.app_debit_ccid,
        rev_credit_ccid = l_def_pvn_rec.rev_credit_ccid,
        rev_debit_ccid = l_def_pvn_rec.rev_debit_ccid,
        app_credit_ccid = l_def_pvn_rec.app_credit_ccid,
        SET_OF_BOOKS_ID = l_def_pvn_rec.set_of_books_id,
        OBJECT_VERSION_NUMBER = l_def_pvn_rec.object_version_number,
        VERSION = l_def_pvn_rec.version,
        DESCRIPTION = l_def_pvn_rec.description,
        FROM_DATE = l_def_pvn_rec.from_date,
        TO_DATE = l_def_pvn_rec.TO_DATE,
        ATTRIBUTE_CATEGORY = l_def_pvn_rec.attribute_category,
        ATTRIBUTE1 = l_def_pvn_rec.attribute1,
        ATTRIBUTE2 = l_def_pvn_rec.attribute2,
        ATTRIBUTE3 = l_def_pvn_rec.attribute3,
        ATTRIBUTE4 = l_def_pvn_rec.attribute4,
        ATTRIBUTE5 = l_def_pvn_rec.attribute5,
        ATTRIBUTE6 = l_def_pvn_rec.attribute6,
        ATTRIBUTE7 = l_def_pvn_rec.attribute7,
        ATTRIBUTE8 = l_def_pvn_rec.attribute8,
        ATTRIBUTE9 = l_def_pvn_rec.attribute9,
        ATTRIBUTE10 = l_def_pvn_rec.attribute10,
        ATTRIBUTE11 = l_def_pvn_rec.attribute11,
        ATTRIBUTE12 = l_def_pvn_rec.attribute12,
        ATTRIBUTE13 = l_def_pvn_rec.attribute13,
        ATTRIBUTE14 = l_def_pvn_rec.attribute14,
        ATTRIBUTE15 = l_def_pvn_rec.attribute15,
        CREATED_BY = l_def_pvn_rec.created_by,
        CREATION_DATE = l_def_pvn_rec.creation_date,
        LAST_UPDATED_BY = l_def_pvn_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pvn_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pvn_rec.last_update_login
    WHERE ID = l_def_pvn_rec.id;

    x_pvn_rec := l_def_pvn_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -------------------------------------
  -- update_row for:OKL_PROVISIONS_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN pvnv_rec_type,
    x_pvnv_rec                     OUT NOCOPY pvnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pvnv_rec                     pvnv_rec_type := p_pvnv_rec;
    l_def_pvnv_rec                 pvnv_rec_type;
    l_pvn_rec                      pvn_rec_type;
    lx_pvn_rec                     pvn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pvnv_rec	IN pvnv_rec_type
    ) RETURN pvnv_rec_type IS
      l_pvnv_rec	pvnv_rec_type := p_pvnv_rec;
    BEGIN
      l_pvnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pvnv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_pvnv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_pvnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pvnv_rec	IN pvnv_rec_type,
      x_pvnv_rec	OUT NOCOPY pvnv_rec_type
    ) RETURN VARCHAR2 IS
      l_pvnv_rec                     pvnv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_pvnv_rec := p_pvnv_rec;
      -- Get current database values
      l_pvnv_rec := get_rec(p_pvnv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pvnv_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_pvnv_rec.id := l_pvnv_rec.id;
      END IF;
      IF (x_pvnv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_pvnv_rec.object_version_number := l_pvnv_rec.object_version_number;
      END IF;
      IF (x_pvnv_rec.app_debit_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_pvnv_rec.app_debit_ccid := l_pvnv_rec.app_debit_ccid;
      END IF;
      IF (x_pvnv_rec.rev_credit_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_pvnv_rec.rev_credit_ccid := l_pvnv_rec.rev_credit_ccid;
      END IF;
      IF (x_pvnv_rec.rev_debit_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_pvnv_rec.rev_debit_ccid := l_pvnv_rec.rev_debit_ccid;
      END IF;
      IF (x_pvnv_rec.set_of_books_id = Okc_Api.G_MISS_NUM)
      THEN
        x_pvnv_rec.set_of_books_id := l_pvnv_rec.set_of_books_id;
      END IF;
      IF (x_pvnv_rec.app_credit_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_pvnv_rec.app_credit_ccid := l_pvnv_rec.app_credit_ccid;
      END IF;
      IF (x_pvnv_rec.name = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.name := l_pvnv_rec.name;
      END IF;
      IF (x_pvnv_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.description := l_pvnv_rec.description;
      END IF;
      IF (x_pvnv_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute_category := l_pvnv_rec.attribute_category;
      END IF;
      IF (x_pvnv_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute1 := l_pvnv_rec.attribute1;
      END IF;
      IF (x_pvnv_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute2 := l_pvnv_rec.attribute2;
      END IF;
      IF (x_pvnv_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute3 := l_pvnv_rec.attribute3;
      END IF;
      IF (x_pvnv_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute4 := l_pvnv_rec.attribute4;
      END IF;
      IF (x_pvnv_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute5 := l_pvnv_rec.attribute5;
      END IF;
      IF (x_pvnv_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute6 := l_pvnv_rec.attribute6;
      END IF;
      IF (x_pvnv_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute7 := l_pvnv_rec.attribute7;
      END IF;
      IF (x_pvnv_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute8 := l_pvnv_rec.attribute8;
      END IF;
      IF (x_pvnv_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute9 := l_pvnv_rec.attribute9;
      END IF;
      IF (x_pvnv_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute10 := l_pvnv_rec.attribute10;
      END IF;
      IF (x_pvnv_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute11 := l_pvnv_rec.attribute11;
      END IF;
      IF (x_pvnv_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute12 := l_pvnv_rec.attribute12;
      END IF;
      IF (x_pvnv_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute13 := l_pvnv_rec.attribute13;
      END IF;
      IF (x_pvnv_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute14 := l_pvnv_rec.attribute14;
      END IF;
      IF (x_pvnv_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.attribute15 := l_pvnv_rec.attribute15;
      END IF;
      IF (x_pvnv_rec.version = Okc_Api.G_MISS_CHAR)
      THEN
        x_pvnv_rec.version := l_pvnv_rec.version;
      END IF;
      IF (x_pvnv_rec.from_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pvnv_rec.from_date := l_pvnv_rec.from_date;
      END IF;
      IF (x_pvnv_rec.TO_DATE = Okc_Api.G_MISS_DATE)
      THEN
        x_pvnv_rec.TO_DATE := l_pvnv_rec.TO_DATE;
      END IF;
      IF (x_pvnv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_pvnv_rec.created_by := l_pvnv_rec.created_by;
      END IF;
      IF (x_pvnv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pvnv_rec.creation_date := l_pvnv_rec.creation_date;
      END IF;
      IF (x_pvnv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_pvnv_rec.last_updated_by := l_pvnv_rec.last_updated_by;
      END IF;
      IF (x_pvnv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_pvnv_rec.last_update_date := l_pvnv_rec.last_update_date;
      END IF;
      IF (x_pvnv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_pvnv_rec.last_update_login := l_pvnv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_PROVISIONS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_pvnv_rec IN  pvnv_rec_type,
      x_pvnv_rec OUT NOCOPY pvnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_pvnv_rec := p_pvnv_rec;
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
      p_pvnv_rec,                        -- IN
      l_pvnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pvnv_rec, l_def_pvnv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_pvnv_rec := fill_who_columns(l_def_pvnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pvnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pvnv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pvnv_rec, l_pvn_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pvn_rec,
      lx_pvn_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pvn_rec, l_def_pvnv_rec);
    x_pvnv_rec := l_def_pvnv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL update_row for:PVNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pvnv_tbl.COUNT > 0) THEN
      i := p_pvnv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pvnv_rec                     => p_pvnv_tbl(i),
          x_pvnv_rec                     => x_pvnv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_pvnv_tbl.LAST);
        i := p_pvnv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_Status;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -----------------------------------
  -- delete_row for:OKL_PROVISIONS --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvn_rec                      IN pvn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PROVISIONS_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pvn_rec                      pvn_rec_type:= p_pvn_rec;
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
    DELETE FROM OKL_PROVISIONS
     WHERE ID = l_pvn_rec.id;

    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -------------------------------------
  -- delete_row for:OKL_PROVISIONS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN pvnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_pvnv_rec                     pvnv_rec_type := p_pvnv_rec;
    l_pvn_rec                      pvn_rec_type;
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
    migrate(l_pvnv_rec, l_pvn_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pvn_rec
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
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL delete_row for:PVNV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN pvnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pvnv_tbl.COUNT > 0) THEN
      i := p_pvnv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pvnv_rec                     => p_pvnv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_pvnv_tbl.LAST);
        i := p_pvnv_tbl.NEXT(i);
      END LOOP;
    END IF;
     x_return_status := l_overall_Status;

  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
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
END Okl_Pvn_Pvt;

/
