--------------------------------------------------------
--  DDL for Package Body OKL_CMG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CMG_PVT" AS
/* $Header: OKLSCMGB.pls 115.7 2002/12/18 12:56:51 kjinger noship $ */

  ---------------------------------------------------------------------------
  -- Global Variables
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------
  --GLOBAL MESSAGES
     G_UNEXPECTED_ERROR CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
     G_NO_PARENT_RECORD CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
     G_SQLERRM_TOKEN    CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
     G_SQLCODE_TOKEN    CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
     G_NOT_SAME         CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';

  --GLOBAL VARIABLES
    G_VIEW              CONSTANT   VARCHAR2(30)  := 'OKL_CONDITION_MSSGS_V';
    G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

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
  -- FUNCTION get_rec for: OKL_CONDITION_MSSGS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cmg_rec                      IN cmg_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cmg_rec_type IS
    CURSOR cmg_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            IMS_ID,
            IVM_ID,
            OBJECT_VERSION_NUMBER,
            SEQUENCE_NUMBER,
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
      FROM Okl_Condition_Mssgs
     WHERE okl_condition_mssgs.id = p_id;
    l_cmg_pk                       cmg_pk_csr%ROWTYPE;
    l_cmg_rec                      cmg_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cmg_pk_csr (p_cmg_rec.id);
    FETCH cmg_pk_csr INTO
              l_cmg_rec.ID,
              l_cmg_rec.IMS_ID,
              l_cmg_rec.IVM_ID,
              l_cmg_rec.OBJECT_VERSION_NUMBER,
              l_cmg_rec.SEQUENCE_NUMBER,
              l_cmg_rec.ATTRIBUTE_CATEGORY,
              l_cmg_rec.ATTRIBUTE1,
              l_cmg_rec.ATTRIBUTE2,
              l_cmg_rec.ATTRIBUTE3,
              l_cmg_rec.ATTRIBUTE4,
              l_cmg_rec.ATTRIBUTE5,
              l_cmg_rec.ATTRIBUTE6,
              l_cmg_rec.ATTRIBUTE7,
              l_cmg_rec.ATTRIBUTE8,
              l_cmg_rec.ATTRIBUTE9,
              l_cmg_rec.ATTRIBUTE10,
              l_cmg_rec.ATTRIBUTE11,
              l_cmg_rec.ATTRIBUTE12,
              l_cmg_rec.ATTRIBUTE13,
              l_cmg_rec.ATTRIBUTE14,
              l_cmg_rec.ATTRIBUTE15,
              l_cmg_rec.CREATED_BY,
              l_cmg_rec.CREATION_DATE,
              l_cmg_rec.LAST_UPDATED_BY,
              l_cmg_rec.LAST_UPDATE_DATE,
              l_cmg_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := cmg_pk_csr%NOTFOUND;
    CLOSE cmg_pk_csr;
    RETURN(l_cmg_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cmg_rec                      IN cmg_rec_type
  ) RETURN cmg_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cmg_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CONDITION_MSSGS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cmgv_rec                     IN cmgv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cmgv_rec_type IS
    CURSOR okl_cmgv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            IMS_ID,
            IVM_ID,
            SEQUENCE_NUMBER,
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
      FROM Okl_Condition_Mssgs_V
     WHERE okl_condition_mssgs_v.id = p_id;
    l_okl_cmgv_pk                  okl_cmgv_pk_csr%ROWTYPE;
    l_cmgv_rec                     cmgv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cmgv_pk_csr (p_cmgv_rec.id);
    FETCH okl_cmgv_pk_csr INTO
              l_cmgv_rec.ID,
              l_cmgv_rec.OBJECT_VERSION_NUMBER,
              l_cmgv_rec.IMS_ID,
              l_cmgv_rec.IVM_ID,
              l_cmgv_rec.SEQUENCE_NUMBER,
              l_cmgv_rec.ATTRIBUTE_CATEGORY,
              l_cmgv_rec.ATTRIBUTE1,
              l_cmgv_rec.ATTRIBUTE2,
              l_cmgv_rec.ATTRIBUTE3,
              l_cmgv_rec.ATTRIBUTE4,
              l_cmgv_rec.ATTRIBUTE5,
              l_cmgv_rec.ATTRIBUTE6,
              l_cmgv_rec.ATTRIBUTE7,
              l_cmgv_rec.ATTRIBUTE8,
              l_cmgv_rec.ATTRIBUTE9,
              l_cmgv_rec.ATTRIBUTE10,
              l_cmgv_rec.ATTRIBUTE11,
              l_cmgv_rec.ATTRIBUTE12,
              l_cmgv_rec.ATTRIBUTE13,
              l_cmgv_rec.ATTRIBUTE14,
              l_cmgv_rec.ATTRIBUTE15,
              l_cmgv_rec.CREATED_BY,
              l_cmgv_rec.CREATION_DATE,
              l_cmgv_rec.LAST_UPDATED_BY,
              l_cmgv_rec.LAST_UPDATE_DATE,
              l_cmgv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_cmgv_pk_csr%NOTFOUND;
    CLOSE okl_cmgv_pk_csr;
    RETURN(l_cmgv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cmgv_rec                     IN cmgv_rec_type
  ) RETURN cmgv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cmgv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CONDITION_MSSGS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cmgv_rec	IN cmgv_rec_type
  ) RETURN cmgv_rec_type IS
    l_cmgv_rec	cmgv_rec_type := p_cmgv_rec;
  BEGIN
    IF (l_cmgv_rec.object_version_number = OKL_API.G_MISS_NUM) THEN
      l_cmgv_rec.object_version_number := NULL;
    END IF;
    IF (l_cmgv_rec.ims_id = OKL_API.G_MISS_NUM) THEN
      l_cmgv_rec.ims_id := NULL;
    END IF;
    IF (l_cmgv_rec.ivm_id = OKL_API.G_MISS_NUM) THEN
      l_cmgv_rec.ivm_id := NULL;
    END IF;
    IF (l_cmgv_rec.sequence_number = OKL_API.G_MISS_NUM) THEN
      l_cmgv_rec.sequence_number := NULL;
    END IF;
    IF (l_cmgv_rec.attribute_category = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute_category := NULL;
    END IF;
    IF (l_cmgv_rec.attribute1 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute1 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute2 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute2 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute3 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute3 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute4 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute4 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute5 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute5 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute6 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute6 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute7 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute7 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute8 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute8 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute9 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute9 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute10 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute10 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute11 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute11 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute12 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute12 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute13 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute13 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute14 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute14 := NULL;
    END IF;
    IF (l_cmgv_rec.attribute15 = OKL_API.G_MISS_CHAR) THEN
      l_cmgv_rec.attribute15 := NULL;
    END IF;
    IF (l_cmgv_rec.created_by = OKL_API.G_MISS_NUM) THEN
      l_cmgv_rec.created_by := NULL;
    END IF;
    IF (l_cmgv_rec.creation_date = OKL_API.G_MISS_DATE) THEN
      l_cmgv_rec.creation_date := NULL;
    END IF;
    IF (l_cmgv_rec.last_updated_by = OKL_API.G_MISS_NUM) THEN
      l_cmgv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cmgv_rec.last_update_date = OKL_API.G_MISS_DATE) THEN
      l_cmgv_rec.last_update_date := NULL;
    END IF;
    IF (l_cmgv_rec.last_update_login = OKL_API.G_MISS_NUM) THEN
      l_cmgv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cmgv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_cmgv_rec		  IN  cmgv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_cmgv_rec.id = OKL_API.G_MISS_NUM
    OR p_cmgv_rec.id IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'id');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Object_Version_Number (
    x_return_status OUT NOCOPY VARCHAR2,
    p_cmgv_rec		  IN  cmgv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_cmgv_rec.object_version_number = OKL_API.G_MISS_NUM
    OR p_cmgv_rec.object_version_number IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'object_version_number');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Ims_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Ims_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_cmgv_rec		  IN  cmgv_rec_type) IS

    l_dummy_var             VARCHAR2(1) := '?';

    CURSOR l_imsv_csr IS
		  SELECT 'x'
		  FROM   okl_invoice_mssgs_v
		  WHERE  id = p_cmgv_rec.ims_id;

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_cmgv_rec.ims_id = OKL_API.G_MISS_NUM
    OR p_cmgv_rec.ims_id IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'ims_id');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- enforce foreign key
    OPEN l_imsv_csr;
      FETCH l_imsv_csr INTO l_dummy_var;
    CLOSE l_imsv_csr;

    -- if dummy value is still set to default, data was not found
    IF (l_dummy_var = '?') THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_NO_PARENT_RECORD,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'ims_id',
      	p_token2       => G_CHILD_TABLE_TOKEN,
      	p_token2_value => 'OKL_CONDITION_MSSGS_V',
      	p_token3       => G_PARENT_TABLE_TOKEN,
      	p_token3_value => 'OKL_INVOICE_MSSGS_V');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- verify the cursor is closed
      IF l_imsv_csr%ISOPEN THEN
         CLOSE l_imsv_csr;
      END IF;

  END Validate_Ims_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Ivm_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Ivm_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_cmgv_rec		  IN  cmgv_rec_type) IS

    l_dummy_var             VARCHAR2(1) := '?';

    CURSOR l_ivmv_csr IS
		  SELECT 'x'
		  FROM   okl_invc_mss_prcdrs_v
		  WHERE  id = p_cmgv_rec.ivm_id;

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_cmgv_rec.ivm_id = OKL_API.G_MISS_NUM
    OR p_cmgv_rec.ivm_id IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'ivm_id');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- enforce foreign key
    OPEN l_ivmv_csr;
      FETCH l_ivmv_csr INTO l_dummy_var;
    CLOSE l_ivmv_csr;

    -- if dummy value is still set to default, data was not found
    IF (l_dummy_var = '?') THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_NO_PARENT_RECORD,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'ivm_id',
      	p_token2       => G_CHILD_TABLE_TOKEN,
      	p_token2_value => 'OKL_CONDITION_MSSGS_V',
      	p_token3       => G_PARENT_TABLE_TOKEN,
      	p_token3_value => 'OKL_INVC_MSS_PRCDRS_V');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- verify the cursor is closed
      IF l_ivmv_csr%ISOPEN THEN
         CLOSE l_ivmv_csr;
      END IF;

  END Validate_Ivm_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Is_Unique
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------
  FUNCTION Is_Unique (
    p_cmgv_rec IN cmgv_rec_type
  ) RETURN VARCHAR2 IS

    CURSOR l_cmgv_csr IS
		  SELECT 'x'
		  FROM   okl_condition_mssgs_v
		  WHERE  ims_id   = p_cmgv_rec.ims_id
		  AND    ivm_id   = p_cmgv_rec.ivm_id
		  AND    id       <> nvl (p_cmgv_rec.id, -99999);

    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;

  BEGIN

    -- check for unique IMS_ID + IVM_ID
    OPEN     l_cmgv_csr;
    FETCH    l_cmgv_csr INTO l_dummy;
	  l_found  := l_cmgv_csr%FOUND;
	  CLOSE    l_cmgv_csr;

    IF (l_found) THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_NOT_SAME,
      	p_token1          => 'IMS_ID',
      	p_token1_value    => p_cmgv_rec.ims_id,
      	p_token2          => 'IVM_ID',
      	p_token2_value    => p_cmgv_rec.ivm_id);

      -- notify caller of an error
      l_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

    -- return status to the caller
    RETURN l_return_status;

  EXCEPTION

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- verify the cursor is closed
      IF l_cmgv_csr%ISOPEN THEN
         CLOSE l_cmgv_csr;
      END IF;
      -- return status to the caller
      RETURN l_return_status;

  END Is_Unique;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_CONDITION_MSSGS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cmgv_rec IN  cmgv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- call each column-level validation

    validate_id (
      x_return_status => l_return_status,
      p_cmgv_rec      => p_cmgv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_object_version_number (
      x_return_status => l_return_status,
      p_cmgv_rec      => p_cmgv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_ims_id (
      x_return_status => l_return_status,
      p_cmgv_rec      => p_cmgv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_ivm_id (
      x_return_status => l_return_status,
      p_cmgv_rec      => p_cmgv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN x_return_status;

  EXCEPTION

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- return status to the caller
      RETURN x_return_status;

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_CONDITION_MSSGS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_cmgv_rec IN cmgv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call each record-level validation
    l_return_status := is_unique (p_cmgv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN x_return_status;

  EXCEPTION

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- return status to the caller
      RETURN x_return_status;

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cmgv_rec_type,
    p_to	IN OUT NOCOPY cmg_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ims_id := p_from.ims_id;
    p_to.ivm_id := p_from.ivm_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sequence_number := p_from.sequence_number;
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
    p_from	IN cmg_rec_type,
    p_to	IN OUT NOCOPY cmgv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ims_id := p_from.ims_id;
    p_to.ivm_id := p_from.ivm_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sequence_number := p_from.sequence_number;
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
  -- validate_row for:OKL_CONDITION_MSSGS_V --
  --------------------------------------------
  PROCEDURE validate_row(
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_cmgv_rec        IN              cmgv_rec_type
) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cmgv_rec                     cmgv_rec_type := p_cmgv_rec;
    l_cmg_rec                      cmg_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_cmgv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cmgv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:CMGV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_cmgv_tbl        IN              cmgv_tbl_type
) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cmgv_tbl.COUNT > 0) THEN
      i := p_cmgv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cmgv_rec                     => p_cmgv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_cmgv_tbl.LAST);
        i := p_cmgv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_CONDITION_MSSGS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cmg_rec                      IN cmg_rec_type,
    x_cmg_rec                      OUT NOCOPY cmg_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'MSSGS_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cmg_rec                      cmg_rec_type := p_cmg_rec;
    l_def_cmg_rec                  cmg_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_CONDITION_MSSGS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cmg_rec IN  cmg_rec_type,
      x_cmg_rec OUT NOCOPY cmg_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cmg_rec := p_cmg_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cmg_rec,                         -- IN
      l_cmg_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CONDITION_MSSGS(
        id,
        ims_id,
        ivm_id,
        object_version_number,
        sequence_number,
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
        l_cmg_rec.id,
        l_cmg_rec.ims_id,
        l_cmg_rec.ivm_id,
        l_cmg_rec.object_version_number,
        l_cmg_rec.sequence_number,
        l_cmg_rec.attribute_category,
        l_cmg_rec.attribute1,
        l_cmg_rec.attribute2,
        l_cmg_rec.attribute3,
        l_cmg_rec.attribute4,
        l_cmg_rec.attribute5,
        l_cmg_rec.attribute6,
        l_cmg_rec.attribute7,
        l_cmg_rec.attribute8,
        l_cmg_rec.attribute9,
        l_cmg_rec.attribute10,
        l_cmg_rec.attribute11,
        l_cmg_rec.attribute12,
        l_cmg_rec.attribute13,
        l_cmg_rec.attribute14,
        l_cmg_rec.attribute15,
        l_cmg_rec.created_by,
        l_cmg_rec.creation_date,
        l_cmg_rec.last_updated_by,
        l_cmg_rec.last_update_date,
        l_cmg_rec.last_update_login);
    -- Set OUT values
    x_cmg_rec := l_cmg_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_CONDITION_MSSGS_V --
  ------------------------------------------
  PROCEDURE insert_row(
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_cmgv_rec        IN              cmgv_rec_type,
      x_cmgv_rec        OUT NOCOPY      cmgv_rec_type
   ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cmgv_rec                     cmgv_rec_type;
    l_def_cmgv_rec                 cmgv_rec_type;
    l_cmg_rec                      cmg_rec_type;
    lx_cmg_rec                     cmg_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cmgv_rec	IN cmgv_rec_type
    ) RETURN cmgv_rec_type IS
      l_cmgv_rec	cmgv_rec_type := p_cmgv_rec;
    BEGIN
      l_cmgv_rec.CREATION_DATE := SYSDATE;
      l_cmgv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cmgv_rec.LAST_UPDATE_DATE := l_cmgv_rec.CREATION_DATE;
      l_cmgv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cmgv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cmgv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CONDITION_MSSGS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cmgv_rec IN  cmgv_rec_type,
      x_cmgv_rec OUT NOCOPY cmgv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cmgv_rec := p_cmgv_rec;
      x_cmgv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_cmgv_rec := null_out_defaults(p_cmgv_rec);
    -- Set primary key value
    l_cmgv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cmgv_rec,                        -- IN
      l_def_cmgv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cmgv_rec := fill_who_columns(l_def_cmgv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cmgv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cmgv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cmgv_rec, l_cmg_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cmg_rec,
      lx_cmg_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cmg_rec, l_def_cmgv_rec);
    -- Set OUT values
    x_cmgv_rec := l_def_cmgv_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:CMGV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_cmgv_tbl        IN              cmgv_tbl_type,
      x_cmgv_tbl        OUT NOCOPY      cmgv_tbl_type
) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cmgv_tbl.COUNT > 0) THEN
      i := p_cmgv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cmgv_rec                     => p_cmgv_tbl(i),
          x_cmgv_rec                     => x_cmgv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_cmgv_tbl.LAST);
        i := p_cmgv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_CONDITION_MSSGS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cmg_rec                      IN cmg_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cmg_rec IN cmg_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CONDITION_MSSGS
     WHERE ID = p_cmg_rec.id
       AND OBJECT_VERSION_NUMBER = p_cmg_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cmg_rec IN cmg_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CONDITION_MSSGS
    WHERE ID = p_cmg_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'MSSGS_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_CONDITION_MSSGS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_CONDITION_MSSGS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_cmg_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_cmg_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cmg_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cmg_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_CONDITION_MSSGS_V --
  ----------------------------------------
  PROCEDURE lock_row(
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_cmgv_rec        IN              cmgv_rec_type
) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cmg_rec                      cmg_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_cmgv_rec, l_cmg_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cmg_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:CMGV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_cmgv_tbl        IN              cmgv_tbl_type
) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cmgv_tbl.COUNT > 0) THEN
      i := p_cmgv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cmgv_rec                     => p_cmgv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_cmgv_tbl.LAST);
        i := p_cmgv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_CONDITION_MSSGS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cmg_rec                      IN cmg_rec_type,
    x_cmg_rec                      OUT NOCOPY cmg_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'MSSGS_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cmg_rec                      cmg_rec_type := p_cmg_rec;
    l_def_cmg_rec                  cmg_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cmg_rec	IN cmg_rec_type,
      x_cmg_rec	OUT NOCOPY cmg_rec_type
    ) RETURN VARCHAR2 IS
      l_cmg_rec                      cmg_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cmg_rec := p_cmg_rec;
      -- Get current database values
      l_cmg_rec := get_rec(p_cmg_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cmg_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_cmg_rec.id := l_cmg_rec.id;
      END IF;
      IF (x_cmg_rec.ims_id = OKL_API.G_MISS_NUM)
      THEN
        x_cmg_rec.ims_id := l_cmg_rec.ims_id;
      END IF;
      IF (x_cmg_rec.ivm_id = OKL_API.G_MISS_NUM)
      THEN
        x_cmg_rec.ivm_id := l_cmg_rec.ivm_id;
      END IF;
      IF (x_cmg_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_cmg_rec.object_version_number := l_cmg_rec.object_version_number;
      END IF;
      IF (x_cmg_rec.sequence_number = OKL_API.G_MISS_NUM)
      THEN
        x_cmg_rec.sequence_number := l_cmg_rec.sequence_number;
      END IF;
      IF (x_cmg_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute_category := l_cmg_rec.attribute_category;
      END IF;
      IF (x_cmg_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute1 := l_cmg_rec.attribute1;
      END IF;
      IF (x_cmg_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute2 := l_cmg_rec.attribute2;
      END IF;
      IF (x_cmg_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute3 := l_cmg_rec.attribute3;
      END IF;
      IF (x_cmg_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute4 := l_cmg_rec.attribute4;
      END IF;
      IF (x_cmg_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute5 := l_cmg_rec.attribute5;
      END IF;
      IF (x_cmg_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute6 := l_cmg_rec.attribute6;
      END IF;
      IF (x_cmg_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute7 := l_cmg_rec.attribute7;
      END IF;
      IF (x_cmg_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute8 := l_cmg_rec.attribute8;
      END IF;
      IF (x_cmg_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute9 := l_cmg_rec.attribute9;
      END IF;
      IF (x_cmg_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute10 := l_cmg_rec.attribute10;
      END IF;
      IF (x_cmg_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute11 := l_cmg_rec.attribute11;
      END IF;
      IF (x_cmg_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute12 := l_cmg_rec.attribute12;
      END IF;
      IF (x_cmg_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute13 := l_cmg_rec.attribute13;
      END IF;
      IF (x_cmg_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute14 := l_cmg_rec.attribute14;
      END IF;
      IF (x_cmg_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmg_rec.attribute15 := l_cmg_rec.attribute15;
      END IF;
      IF (x_cmg_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_cmg_rec.created_by := l_cmg_rec.created_by;
      END IF;
      IF (x_cmg_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_cmg_rec.creation_date := l_cmg_rec.creation_date;
      END IF;
      IF (x_cmg_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_cmg_rec.last_updated_by := l_cmg_rec.last_updated_by;
      END IF;
      IF (x_cmg_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_cmg_rec.last_update_date := l_cmg_rec.last_update_date;
      END IF;
      IF (x_cmg_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_cmg_rec.last_update_login := l_cmg_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_CONDITION_MSSGS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cmg_rec IN  cmg_rec_type,
      x_cmg_rec OUT NOCOPY cmg_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cmg_rec := p_cmg_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cmg_rec,                         -- IN
      l_cmg_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cmg_rec, l_def_cmg_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_CONDITION_MSSGS
    SET IMS_ID = l_def_cmg_rec.ims_id,
        IVM_ID = l_def_cmg_rec.ivm_id,
        OBJECT_VERSION_NUMBER = l_def_cmg_rec.object_version_number,
        SEQUENCE_NUMBER = l_def_cmg_rec.sequence_number,
        ATTRIBUTE_CATEGORY = l_def_cmg_rec.attribute_category,
        ATTRIBUTE1 = l_def_cmg_rec.attribute1,
        ATTRIBUTE2 = l_def_cmg_rec.attribute2,
        ATTRIBUTE3 = l_def_cmg_rec.attribute3,
        ATTRIBUTE4 = l_def_cmg_rec.attribute4,
        ATTRIBUTE5 = l_def_cmg_rec.attribute5,
        ATTRIBUTE6 = l_def_cmg_rec.attribute6,
        ATTRIBUTE7 = l_def_cmg_rec.attribute7,
        ATTRIBUTE8 = l_def_cmg_rec.attribute8,
        ATTRIBUTE9 = l_def_cmg_rec.attribute9,
        ATTRIBUTE10 = l_def_cmg_rec.attribute10,
        ATTRIBUTE11 = l_def_cmg_rec.attribute11,
        ATTRIBUTE12 = l_def_cmg_rec.attribute12,
        ATTRIBUTE13 = l_def_cmg_rec.attribute13,
        ATTRIBUTE14 = l_def_cmg_rec.attribute14,
        ATTRIBUTE15 = l_def_cmg_rec.attribute15,
        CREATED_BY = l_def_cmg_rec.created_by,
        CREATION_DATE = l_def_cmg_rec.creation_date,
        LAST_UPDATED_BY = l_def_cmg_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cmg_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cmg_rec.last_update_login
    WHERE ID = l_def_cmg_rec.id;

    x_cmg_rec := l_def_cmg_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_CONDITION_MSSGS_V --
  ------------------------------------------
  PROCEDURE update_row(
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_cmgv_rec        IN              cmgv_rec_type,
      x_cmgv_rec        OUT NOCOPY      cmgv_rec_type
) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cmgv_rec                     cmgv_rec_type := p_cmgv_rec;
    l_def_cmgv_rec                 cmgv_rec_type;
    l_cmg_rec                      cmg_rec_type;
    lx_cmg_rec                     cmg_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cmgv_rec	IN cmgv_rec_type
    ) RETURN cmgv_rec_type IS
      l_cmgv_rec	cmgv_rec_type := p_cmgv_rec;
    BEGIN
      l_cmgv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cmgv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cmgv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cmgv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cmgv_rec	IN cmgv_rec_type,
      x_cmgv_rec	OUT NOCOPY cmgv_rec_type
    ) RETURN VARCHAR2 IS
      l_cmgv_rec                     cmgv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cmgv_rec := p_cmgv_rec;
      -- Get current database values
      l_cmgv_rec := get_rec(p_cmgv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cmgv_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_cmgv_rec.id := l_cmgv_rec.id;
      END IF;
      IF (x_cmgv_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_cmgv_rec.object_version_number := l_cmgv_rec.object_version_number;
      END IF;
      IF (x_cmgv_rec.ims_id = OKL_API.G_MISS_NUM)
      THEN
        x_cmgv_rec.ims_id := l_cmgv_rec.ims_id;
      END IF;
      IF (x_cmgv_rec.ivm_id = OKL_API.G_MISS_NUM)
      THEN
        x_cmgv_rec.ivm_id := l_cmgv_rec.ivm_id;
      END IF;
      IF (x_cmgv_rec.sequence_number = OKL_API.G_MISS_NUM)
      THEN
        x_cmgv_rec.sequence_number := l_cmgv_rec.sequence_number;
      END IF;
      IF (x_cmgv_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute_category := l_cmgv_rec.attribute_category;
      END IF;
      IF (x_cmgv_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute1 := l_cmgv_rec.attribute1;
      END IF;
      IF (x_cmgv_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute2 := l_cmgv_rec.attribute2;
      END IF;
      IF (x_cmgv_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute3 := l_cmgv_rec.attribute3;
      END IF;
      IF (x_cmgv_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute4 := l_cmgv_rec.attribute4;
      END IF;
      IF (x_cmgv_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute5 := l_cmgv_rec.attribute5;
      END IF;
      IF (x_cmgv_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute6 := l_cmgv_rec.attribute6;
      END IF;
      IF (x_cmgv_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute7 := l_cmgv_rec.attribute7;
      END IF;
      IF (x_cmgv_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute8 := l_cmgv_rec.attribute8;
      END IF;
      IF (x_cmgv_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute9 := l_cmgv_rec.attribute9;
      END IF;
      IF (x_cmgv_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute10 := l_cmgv_rec.attribute10;
      END IF;
      IF (x_cmgv_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute11 := l_cmgv_rec.attribute11;
      END IF;
      IF (x_cmgv_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute12 := l_cmgv_rec.attribute12;
      END IF;
      IF (x_cmgv_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute13 := l_cmgv_rec.attribute13;
      END IF;
      IF (x_cmgv_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute14 := l_cmgv_rec.attribute14;
      END IF;
      IF (x_cmgv_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_cmgv_rec.attribute15 := l_cmgv_rec.attribute15;
      END IF;
      IF (x_cmgv_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_cmgv_rec.created_by := l_cmgv_rec.created_by;
      END IF;
      IF (x_cmgv_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_cmgv_rec.creation_date := l_cmgv_rec.creation_date;
      END IF;
      IF (x_cmgv_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_cmgv_rec.last_updated_by := l_cmgv_rec.last_updated_by;
      END IF;
      IF (x_cmgv_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_cmgv_rec.last_update_date := l_cmgv_rec.last_update_date;
      END IF;
      IF (x_cmgv_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_cmgv_rec.last_update_login := l_cmgv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CONDITION_MSSGS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cmgv_rec IN  cmgv_rec_type,
      x_cmgv_rec OUT NOCOPY cmgv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cmgv_rec := p_cmgv_rec;
      x_cmgv_rec.OBJECT_VERSION_NUMBER := NVL(x_cmgv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cmgv_rec,                        -- IN
      l_cmgv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cmgv_rec, l_def_cmgv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cmgv_rec := fill_who_columns(l_def_cmgv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cmgv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cmgv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cmgv_rec, l_cmg_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cmg_rec,
      lx_cmg_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cmg_rec, l_def_cmgv_rec);
    x_cmgv_rec := l_def_cmgv_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:CMGV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_cmgv_tbl        IN              cmgv_tbl_type,
      x_cmgv_tbl        OUT NOCOPY      cmgv_tbl_type
) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cmgv_tbl.COUNT > 0) THEN
      i := p_cmgv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cmgv_rec                     => p_cmgv_tbl(i),
          x_cmgv_rec                     => x_cmgv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_cmgv_tbl.LAST);
        i := p_cmgv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_CONDITION_MSSGS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cmg_rec                      IN cmg_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'MSSGS_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cmg_rec                      cmg_rec_type:= p_cmg_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_CONDITION_MSSGS
     WHERE ID = l_cmg_rec.id;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_CONDITION_MSSGS_V --
  ------------------------------------------
  PROCEDURE delete_row(
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_cmgv_rec        IN              cmgv_rec_type
) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cmgv_rec                     cmgv_rec_type := p_cmgv_rec;
    l_cmg_rec                      cmg_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_cmgv_rec, l_cmg_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cmg_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:CMGV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_cmgv_tbl        IN              cmgv_tbl_type
) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cmgv_tbl.COUNT > 0) THEN
      i := p_cmgv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cmgv_rec                     => p_cmgv_tbl(i));
        EXIT WHEN (i = p_cmgv_tbl.LAST);
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        i := p_cmgv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_CMG_PVT;

/
