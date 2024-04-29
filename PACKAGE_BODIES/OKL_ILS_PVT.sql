--------------------------------------------------------
--  DDL for Package Body OKL_ILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ILS_PVT" AS
/* $Header: OKLSILSB.pls 120.2.12010000.2 2010/03/22 21:56:47 gkadarka ship $ */


-- Checking Unique Key
  FUNCTION IS_UNIQUE (p_ilsv_rec ilsv_rec_type) RETURN VARCHAR2
  IS
    CURSOR l_ils_csr IS
		 SELECT  strm.name, invf.name
		 FROM OKL_INVC_FRMT_STRMS invstr , OKL_STRM_TYPE_TL strm ,OKL_INVOICE_FORMATS_TL  invf
		 WHERE invstr.sty_id = p_ilsv_rec.sty_id
		 AND   invstr.inf_id = p_ilsv_rec.inf_id
		 AND   invstr.id <> NVL(p_ilsv_rec.id,-99999)
                 AND   invstr.sty_id = strm.id
                 AND   invstr.inf_id = invf.id
                 AND   strm.language =  USERENV('LANG')
                 AND   invf.language =  USERENV('LANG');

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_strm_name         VARCHAR2(50);
    l_inv_name          VARCHAR2(50);
    l_found             BOOLEAN;
  BEGIN

    -- check for unique product and location
        OPEN l_ils_csr;
        FETCH l_ils_csr INTO l_strm_name, l_inv_name;
	   l_found := l_ils_csr%FOUND;
	   CLOSE l_ils_csr;

    IF (l_found) THEN
  	    Okl_Api.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name  	=> 'OKL_ILS_Exists',
					    p_token1		=> 'STRM_NAME',
					    p_token1_value	=> l_strm_name,
					    p_token2		=> 'INV_NAME',
					    p_token2_value	=> l_inv_name);
	  -- notify caller of an error
	  l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN (l_return_status);

  EXCEPTION
    WHEN OTHERS THEN
	 RETURN (l_return_status);
  END IS_UNIQUE;


-- Validate not null value for ID

PROCEDURE validate_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_ilsv_rec 		IN	ilsv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_ilsv_rec.id IS NULL) OR (p_ilsv_rec.id = Okl_Api.G_MISS_NUM) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> 'OKC',
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'id');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
--	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

END validate_id;


-- Validate not null value for Version Number

PROCEDURE validate_object_version_number(x_return_status OUT NOCOPY VARCHAR2,
			 p_ilsv_rec 		IN	ilsv_rec_type) IS

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_ilsv_rec.object_version_number IS NULL) OR (p_ilsv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'object_version_number');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

END validate_object_version_number;




PROCEDURE validate_ilt_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_ilsv_rec 		IN	ilsv_rec_type) IS

l_dummy_var	VARCHAR2(1) := '?';
CURSOR l_ilsv_csr IS
	SELECT 'x'
	FROM OKL_INVC_LINE_TYPES_V
	WHERE id = p_ilsv_rec.ilt_id;

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_ilsv_rec.ilt_id IS NULL) OR (p_ilsv_rec.ilt_id = Okl_Api.G_MISS_NUM) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> 'OKC',
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'ilt_id');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
--	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

-- enforce foreign key
OPEN l_ilsv_csr;
	FETCH l_ilsv_csr INTO l_dummy_var;
CLOSE l_ilsv_csr;

-- if l_dummy_var is still set to default, data was not found
	IF(l_dummy_var = '?') THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_no_parent_record,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'ilt_id',
			    p_token2	=> g_child_table_token,
			    p_token2_value => 'OKL_INVC_FRMT_STRMS_V',
			    p_token3	=> g_parent_table_token,
			    p_token3_value => 'OKL_INVC_LINE_TYPES_V');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;
	END IF;

EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
	NULL;

	WHEN OTHERS THEN
-- 	store SQL error message on message stack for caller
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_unexpected_error,
			    p_token1	=> g_sqlcode_token,
			    p_token1_value => SQLCODE,
			    p_token2	=> g_sqlerrm_token,
			    p_token2_value => SQLERRM);


-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

-- verfiy that cursor was closed
	IF l_ilsv_csr%ISOPEN THEN
	  CLOSE l_ilsv_csr;
	END IF;

END validate_ilt_id;


PROCEDURE validate_inf_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_ilsv_rec 		IN	ilsv_rec_type) IS

l_dummy_var	VARCHAR2(1) := '?';
CURSOR l_ilsv_csr IS
	SELECT 'x'
	FROM OKL_INVOICE_FORMATS_V
	WHERE id = p_ilsv_rec.inf_id;

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_ilsv_rec.inf_id IS NULL) OR (p_ilsv_rec.inf_id = Okl_Api.G_MISS_NUM) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> 'OKC',
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'inf_id');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
--	RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

-- enforce foreign key
OPEN l_ilsv_csr;
	FETCH l_ilsv_csr INTO l_dummy_var;
CLOSE l_ilsv_csr;

-- if l_dummy_var is still set to default, data was not found
	IF(l_dummy_var = '?') THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_no_parent_record,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'inf_id',
			    p_token2	=> g_child_table_token,
			    p_token2_value => 'OKL_INVC_FRMT_STRMS_V',
			    p_token3	=> g_parent_table_token,
			    p_token3_value => 'OKL_INVOICE_FORMATS_V');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;
	END IF;

EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
	NULL;

	WHEN OTHERS THEN
-- 	store SQL error message on message stack for caller
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_unexpected_error,
			    p_token1	=> g_sqlcode_token,
			    p_token1_value => SQLCODE,
			    p_token2	=> g_sqlerrm_token,
			    p_token2_value => SQLERRM);


-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

-- verfiy that cursor was closed
	IF l_ilsv_csr%ISOPEN THEN
	  CLOSE l_ilsv_csr;
	END IF;

END validate_inf_id;



PROCEDURE validate_sty_id(x_return_status OUT NOCOPY VARCHAR2,
			 p_ilsv_rec 		IN	ilsv_rec_type) IS

l_dummy_var	VARCHAR2(1) := '?';

CURSOR l_ilsv_csr IS
	SELECT 'x'
	FROM OKL_STRM_TYPE_V
	WHERE id = p_ilsv_rec.sty_id;

BEGIN
-- initialize return status
x_return_status := Okl_Api.G_RET_STS_SUCCESS;

-- data is required
IF(p_ilsv_rec.sty_id IS NULL) OR (p_ilsv_rec.sty_id = Okl_Api.G_MISS_NUM) THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> 'OKC',
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'Stream Name');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;

-- halt further validation of this column
	--RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

-- enforce foreign key

OPEN l_ilsv_csr;
	FETCH l_ilsv_csr INTO l_dummy_var;
CLOSE l_ilsv_csr;

-- if l_dummy_var is still set to default, data was not found

	IF(l_dummy_var = '?') THEN
	Okl_Api.SET_MESSAGE(p_app_name	=> 'OKC',
			    p_msg_name	=> g_required_value,
			    p_token1	=> g_col_name_token,
			    p_token1_value => 'Stream Name');

-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_ERROR;
	END IF;

EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
--	no processing necessary validation can continue with the next column
	NULL;

	WHEN OTHERS THEN
-- 	store SQL error message on message stack for caller
	Okl_Api.SET_MESSAGE(p_app_name	=> g_app_name,
			    p_msg_name	=> g_unexpected_error,
			    p_token1	=> g_sqlcode_token,
			    p_token1_value => SQLCODE,
			    p_token2	=> g_sqlerrm_token,
			    p_token2_value => SQLERRM);


-- notify caller of an error
	x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

-- verfiy that cursor was closed

	IF l_ilsv_csr%ISOPEN THEN
	  CLOSE l_ilsv_csr;

	END IF;

END validate_sty_id;



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
  -- FUNCTION get_rec for: OKL_INVC_FRMT_STRMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ils_rec                      IN ils_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ils_rec_type IS
    CURSOR ils_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            STY_ID,
            inf_id,
            ILT_ID,
            OBJECT_VERSION_NUMBER,
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
      FROM OKL_INVC_FRMT_STRMS
     WHERE OKL_INVC_FRMT_STRMS.id = p_id;
    l_ils_pk                       ils_pk_csr%ROWTYPE;
    l_ils_rec                      ils_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ils_pk_csr (p_ils_rec.id);
    FETCH ils_pk_csr INTO
              l_ils_rec.ID,
              l_ils_rec.STY_ID,
              l_ils_rec.inf_id,
              l_ils_rec.ILT_ID,
              l_ils_rec.OBJECT_VERSION_NUMBER,
              l_ils_rec.ATTRIBUTE_CATEGORY,
              l_ils_rec.ATTRIBUTE1,
              l_ils_rec.ATTRIBUTE2,
              l_ils_rec.ATTRIBUTE3,
              l_ils_rec.ATTRIBUTE4,
              l_ils_rec.ATTRIBUTE5,
              l_ils_rec.ATTRIBUTE6,
              l_ils_rec.ATTRIBUTE7,
              l_ils_rec.ATTRIBUTE8,
              l_ils_rec.ATTRIBUTE9,
              l_ils_rec.ATTRIBUTE10,
              l_ils_rec.ATTRIBUTE11,
              l_ils_rec.ATTRIBUTE12,
              l_ils_rec.ATTRIBUTE13,
              l_ils_rec.ATTRIBUTE14,
              l_ils_rec.ATTRIBUTE15,
              l_ils_rec.CREATED_BY,
              l_ils_rec.CREATION_DATE,
              l_ils_rec.LAST_UPDATED_BY,
              l_ils_rec.LAST_UPDATE_DATE,
              l_ils_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := ils_pk_csr%NOTFOUND;
    CLOSE ils_pk_csr;
    RETURN(l_ils_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ils_rec                      IN ils_rec_type
  ) RETURN ils_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ils_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVC_FRMT_STRMS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ilsv_rec                     IN ilsv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ilsv_rec_type IS
    CURSOR okl_ilsv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            STY_ID,
            inf_id,
            ILT_ID,
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
      FROM OKL_INVC_FRMT_STRMS_V
     WHERE OKL_INVC_FRMT_STRMS_v.id = p_id;
    l_okl_ilsv_pk                  okl_ilsv_pk_csr%ROWTYPE;
    l_ilsv_rec                     ilsv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ilsv_pk_csr (p_ilsv_rec.id);
    FETCH okl_ilsv_pk_csr INTO
              l_ilsv_rec.ID,
              l_ilsv_rec.OBJECT_VERSION_NUMBER,
              l_ilsv_rec.STY_ID,
              l_ilsv_rec.inf_id,
              l_ilsv_rec.ILT_ID,
              l_ilsv_rec.ATTRIBUTE_CATEGORY,
              l_ilsv_rec.ATTRIBUTE1,
              l_ilsv_rec.ATTRIBUTE2,
              l_ilsv_rec.ATTRIBUTE3,
              l_ilsv_rec.ATTRIBUTE4,
              l_ilsv_rec.ATTRIBUTE5,
              l_ilsv_rec.ATTRIBUTE6,
              l_ilsv_rec.ATTRIBUTE7,
              l_ilsv_rec.ATTRIBUTE8,
              l_ilsv_rec.ATTRIBUTE9,
              l_ilsv_rec.ATTRIBUTE10,
              l_ilsv_rec.ATTRIBUTE11,
              l_ilsv_rec.ATTRIBUTE12,
              l_ilsv_rec.ATTRIBUTE13,
              l_ilsv_rec.ATTRIBUTE14,
              l_ilsv_rec.ATTRIBUTE15,
              l_ilsv_rec.CREATED_BY,
              l_ilsv_rec.CREATION_DATE,
              l_ilsv_rec.LAST_UPDATED_BY,
              l_ilsv_rec.LAST_UPDATE_DATE,
              l_ilsv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ilsv_pk_csr%NOTFOUND;
    CLOSE okl_ilsv_pk_csr;
    RETURN(l_ilsv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ilsv_rec                     IN ilsv_rec_type
  ) RETURN ilsv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ilsv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INVC_FRMT_STRMS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ilsv_rec	IN ilsv_rec_type
  ) RETURN ilsv_rec_type IS
    l_ilsv_rec	ilsv_rec_type := p_ilsv_rec;
  BEGIN
    IF (l_ilsv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_ilsv_rec.object_version_number := NULL;
    END IF;
    IF (l_ilsv_rec.sty_id = Okl_Api.G_MISS_NUM) THEN
      l_ilsv_rec.sty_id := NULL;
    END IF;
    IF (l_ilsv_rec.inf_id = Okl_Api.G_MISS_NUM) THEN
      l_ilsv_rec.inf_id := NULL;
    END IF;
    IF (l_ilsv_rec.ilt_id = Okl_Api.G_MISS_NUM) THEN
      l_ilsv_rec.ilt_id := NULL;
    END IF;
    IF (l_ilsv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute_category := NULL;
    END IF;
    IF (l_ilsv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute1 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute2 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute3 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute4 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute5 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute6 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute7 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute8 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute9 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute10 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute11 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute12 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute13 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute14 := NULL;
    END IF;
    IF (l_ilsv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_ilsv_rec.attribute15 := NULL;
    END IF;
    IF (l_ilsv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_ilsv_rec.created_by := NULL;
    END IF;
    IF (l_ilsv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_ilsv_rec.creation_date := NULL;
    END IF;
    IF (l_ilsv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_ilsv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ilsv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_ilsv_rec.last_update_date := NULL;
    END IF;
    IF (l_ilsv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_ilsv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ilsv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_INVC_FRMT_STRMS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_ilsv_rec IN  ilsv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status VARCHAR2(1)	:= Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
     -- Call each column level validation

  validate_id(x_return_status => l_return_status,
			 	p_ilsv_rec =>	p_ilsv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_object_version_number(x_return_status => l_return_status,
			 	p_ilsv_rec =>	p_ilsv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_sty_id(x_return_status => l_return_status,
			 	p_ilsv_rec =>	p_ilsv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_inf_id(x_return_status => l_return_status,
			 	p_ilsv_rec =>	p_ilsv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

  validate_ilt_id(x_return_status => l_return_status,
			 	p_ilsv_rec =>	p_ilsv_rec);

  -- Store the highest degree of error
  IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
  	IF(x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status;
	END IF;
  END IF;

    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_INVC_FRMT_STRMS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_ilsv_rec IN ilsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
      l_return_status := IS_UNIQUE(p_ilsv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN ilsv_rec_type,
    p_to	OUT NOCOPY ils_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sty_id := p_from.sty_id;
    p_to.inf_id := p_from.inf_id;
    p_to.ilt_id := p_from.ilt_id;
    p_to.object_version_number := p_from.object_version_number;
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
    p_from	IN ils_rec_type,
    p_to	OUT NOCOPY ilsv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sty_id := p_from.sty_id;
    p_to.inf_id := p_from.inf_id;
    p_to.ilt_id := p_from.ilt_id;
    p_to.object_version_number := p_from.object_version_number;
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
  -- validate_row for:OKL_INVC_FRMT_STRMS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilsv_rec                     IN ilsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ilsv_rec                     ilsv_rec_type := p_ilsv_rec;
    l_ils_rec                      ils_rec_type;
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
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_ilsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ilsv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
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
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:ILSV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilsv_tbl                     IN ilsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ilsv_tbl.COUNT > 0) THEN
      i := p_ilsv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ilsv_rec                     => p_ilsv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;

        EXIT WHEN (i = p_ilsv_tbl.LAST OR x_return_status <> OKL_API.G_RET_STS_SUCCESS); -- added OR condition for bug 9482832
        i := p_ilsv_tbl.NEXT(i);
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
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
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
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- insert_row for:OKL_INVC_FRMT_STRMS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ils_rec                      IN ils_rec_type,
    x_ils_rec                      OUT NOCOPY ils_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'STRMS_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ils_rec                      ils_rec_type := p_ils_rec;
    l_def_ils_rec                  ils_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_INVC_FRMT_STRMS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_ils_rec IN  ils_rec_type,
      x_ils_rec OUT NOCOPY ils_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ils_rec := p_ils_rec;
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
      p_ils_rec,                         -- IN
      l_ils_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_INVC_FRMT_STRMS(
        id,
        sty_id,
        inf_id,
        ilt_id,
        object_version_number,
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
        l_ils_rec.id,
        l_ils_rec.sty_id,
        l_ils_rec.inf_id,
        l_ils_rec.ilt_id,
        l_ils_rec.object_version_number,
        l_ils_rec.attribute_category,
        l_ils_rec.attribute1,
        l_ils_rec.attribute2,
        l_ils_rec.attribute3,
        l_ils_rec.attribute4,
        l_ils_rec.attribute5,
        l_ils_rec.attribute6,
        l_ils_rec.attribute7,
        l_ils_rec.attribute8,
        l_ils_rec.attribute9,
        l_ils_rec.attribute10,
        l_ils_rec.attribute11,
        l_ils_rec.attribute12,
        l_ils_rec.attribute13,
        l_ils_rec.attribute14,
        l_ils_rec.attribute15,
        l_ils_rec.created_by,
        l_ils_rec.creation_date,
        l_ils_rec.last_updated_by,
        l_ils_rec.last_update_date,
        l_ils_rec.last_update_login);
    -- Set OUT values
    x_ils_rec := l_ils_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := 'U';
      /*
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := 'U';
      /*
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN OTHERS THEN
      x_return_status := 'U';
      /*
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
  END insert_row;
  ------------------------------------------
  -- insert_row for:OKL_INVC_FRMT_STRMS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilsv_rec                     IN ilsv_rec_type,
    x_ilsv_rec                     OUT NOCOPY ilsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ilsv_rec                     ilsv_rec_type;
    l_def_ilsv_rec                 ilsv_rec_type;
    l_ils_rec                      ils_rec_type;
    lx_ils_rec                     ils_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ilsv_rec	IN ilsv_rec_type
    ) RETURN ilsv_rec_type IS
      l_ilsv_rec	ilsv_rec_type := p_ilsv_rec;
    BEGIN
      l_ilsv_rec.CREATION_DATE := SYSDATE;
      l_ilsv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_ilsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ilsv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_ilsv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_ilsv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INVC_FRMT_STRMS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_ilsv_rec IN  ilsv_rec_type,
      x_ilsv_rec OUT NOCOPY ilsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ilsv_rec := p_ilsv_rec;
      x_ilsv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_ilsv_rec := null_out_defaults(p_ilsv_rec);
    -- Set primary key value
    l_ilsv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ilsv_rec,                        -- IN
      l_def_ilsv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_ilsv_rec := fill_who_columns(l_def_ilsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ilsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ilsv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ilsv_rec, l_ils_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ils_rec,
      lx_ils_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ils_rec, l_def_ilsv_rec);
    -- Set OUT values
    x_ilsv_rec := l_def_ilsv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := 'U';
      /*
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := 'U';
      /*
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN OTHERS THEN
      x_return_status := 'U';
      /*
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:ILSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilsv_tbl                     IN ilsv_tbl_type,
    x_ilsv_tbl                     OUT NOCOPY ilsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ilsv_tbl.COUNT > 0) THEN
      i := p_ilsv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ilsv_rec                     => p_ilsv_tbl(i),
          x_ilsv_rec                     => x_ilsv_tbl(i));
    -- Store the highest degree of error
	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_ilsv_tbl.LAST OR x_return_status <> Okl_Api.G_RET_STS_SUCCESS); -- Added for bug 9482832
        i := p_ilsv_tbl.NEXT(i);
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
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- lock_row for:OKL_INVC_FRMT_STRMS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ils_rec                      IN ils_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ils_rec IN ils_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INVC_FRMT_STRMS
     WHERE ID = p_ils_rec.id
       AND OBJECT_VERSION_NUMBER = p_ils_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ils_rec IN ils_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INVC_FRMT_STRMS
    WHERE ID = p_ils_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'STRMS_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_INVC_FRMT_STRMS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_INVC_FRMT_STRMS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
    BEGIN
      OPEN lock_csr(p_ils_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_ils_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ils_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ils_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okl_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
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
  END lock_row;
  ----------------------------------------
  -- lock_row for:OKL_INVC_FRMT_STRMS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilsv_rec                     IN ilsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ils_rec                      ils_rec_type;
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
    migrate(p_ilsv_rec, l_ils_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ils_rec
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
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
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
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:ILSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilsv_tbl                     IN ilsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ilsv_tbl.COUNT > 0) THEN
      i := p_ilsv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ilsv_rec                     => p_ilsv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_ilsv_tbl.LAST);
        i := p_ilsv_tbl.NEXT(i);
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
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
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
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- update_row for:OKL_INVC_FRMT_STRMS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ils_rec                      IN ils_rec_type,
    x_ils_rec                      OUT NOCOPY ils_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'STRMS_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ils_rec                      ils_rec_type := p_ils_rec;
    l_def_ils_rec                  ils_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ils_rec	IN ils_rec_type,
      x_ils_rec	OUT NOCOPY ils_rec_type
    ) RETURN VARCHAR2 IS
      l_ils_rec                      ils_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ils_rec := p_ils_rec;
      -- Get current database values
      l_ils_rec := get_rec(p_ils_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ils_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_ils_rec.id := l_ils_rec.id;
      END IF;
      IF (x_ils_rec.sty_id = Okl_Api.G_MISS_NUM)
      THEN
        x_ils_rec.sty_id := l_ils_rec.sty_id;
      END IF;
      IF (x_ils_rec.inf_id = Okl_Api.G_MISS_NUM)
      THEN
        x_ils_rec.inf_id := l_ils_rec.inf_id;
      END IF;
      IF (x_ils_rec.ilt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_ils_rec.ilt_id := l_ils_rec.ilt_id;
      END IF;
      IF (x_ils_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_ils_rec.object_version_number := l_ils_rec.object_version_number;
      END IF;
      IF (x_ils_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute_category := l_ils_rec.attribute_category;
      END IF;
      IF (x_ils_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute1 := l_ils_rec.attribute1;
      END IF;
      IF (x_ils_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute2 := l_ils_rec.attribute2;
      END IF;
      IF (x_ils_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute3 := l_ils_rec.attribute3;
      END IF;
      IF (x_ils_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute4 := l_ils_rec.attribute4;
      END IF;
      IF (x_ils_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute5 := l_ils_rec.attribute5;
      END IF;
      IF (x_ils_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute6 := l_ils_rec.attribute6;
      END IF;
      IF (x_ils_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute7 := l_ils_rec.attribute7;
      END IF;
      IF (x_ils_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute8 := l_ils_rec.attribute8;
      END IF;
      IF (x_ils_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute9 := l_ils_rec.attribute9;
      END IF;
      IF (x_ils_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute10 := l_ils_rec.attribute10;
      END IF;
      IF (x_ils_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute11 := l_ils_rec.attribute11;
      END IF;
      IF (x_ils_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute12 := l_ils_rec.attribute12;
      END IF;
      IF (x_ils_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute13 := l_ils_rec.attribute13;
      END IF;
      IF (x_ils_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute14 := l_ils_rec.attribute14;
      END IF;
      IF (x_ils_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ils_rec.attribute15 := l_ils_rec.attribute15;
      END IF;
      IF (x_ils_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_ils_rec.created_by := l_ils_rec.created_by;
      END IF;
      IF (x_ils_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_ils_rec.creation_date := l_ils_rec.creation_date;
      END IF;
      IF (x_ils_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_ils_rec.last_updated_by := l_ils_rec.last_updated_by;
      END IF;
      IF (x_ils_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_ils_rec.last_update_date := l_ils_rec.last_update_date;
      END IF;
      IF (x_ils_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_ils_rec.last_update_login := l_ils_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_INVC_FRMT_STRMS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_ils_rec IN  ils_rec_type,
      x_ils_rec OUT NOCOPY ils_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ils_rec := p_ils_rec;
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
      p_ils_rec,                         -- IN
      l_ils_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ils_rec, l_def_ils_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INVC_FRMT_STRMS
    SET STY_ID = l_def_ils_rec.sty_id,
        inf_id = l_def_ils_rec.inf_id,
        ILT_ID = l_def_ils_rec.ilt_id,
        OBJECT_VERSION_NUMBER = l_def_ils_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_ils_rec.attribute_category,
        ATTRIBUTE1 = l_def_ils_rec.attribute1,
        ATTRIBUTE2 = l_def_ils_rec.attribute2,
        ATTRIBUTE3 = l_def_ils_rec.attribute3,
        ATTRIBUTE4 = l_def_ils_rec.attribute4,
        ATTRIBUTE5 = l_def_ils_rec.attribute5,
        ATTRIBUTE6 = l_def_ils_rec.attribute6,
        ATTRIBUTE7 = l_def_ils_rec.attribute7,
        ATTRIBUTE8 = l_def_ils_rec.attribute8,
        ATTRIBUTE9 = l_def_ils_rec.attribute9,
        ATTRIBUTE10 = l_def_ils_rec.attribute10,
        ATTRIBUTE11 = l_def_ils_rec.attribute11,
        ATTRIBUTE12 = l_def_ils_rec.attribute12,
        ATTRIBUTE13 = l_def_ils_rec.attribute13,
        ATTRIBUTE14 = l_def_ils_rec.attribute14,
        ATTRIBUTE15 = l_def_ils_rec.attribute15,
        CREATED_BY = l_def_ils_rec.created_by,
        CREATION_DATE = l_def_ils_rec.creation_date,
        LAST_UPDATED_BY = l_def_ils_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ils_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ils_rec.last_update_login
    WHERE ID = l_def_ils_rec.id;

    x_ils_rec := l_def_ils_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
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
  ------------------------------------------
  -- update_row for:OKL_INVC_FRMT_STRMS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilsv_rec                     IN ilsv_rec_type,
    x_ilsv_rec                     OUT NOCOPY ilsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ilsv_rec                     ilsv_rec_type := p_ilsv_rec;
    l_def_ilsv_rec                 ilsv_rec_type;
    l_ils_rec                      ils_rec_type;
    lx_ils_rec                     ils_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ilsv_rec	IN ilsv_rec_type
    ) RETURN ilsv_rec_type IS
      l_ilsv_rec	ilsv_rec_type := p_ilsv_rec;
    BEGIN
      l_ilsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ilsv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_ilsv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_ilsv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ilsv_rec	IN ilsv_rec_type,
      x_ilsv_rec	OUT NOCOPY ilsv_rec_type
    ) RETURN VARCHAR2 IS
      l_ilsv_rec                     ilsv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ilsv_rec := p_ilsv_rec;
      -- Get current database values
      l_ilsv_rec := get_rec(p_ilsv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ilsv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_ilsv_rec.id := l_ilsv_rec.id;
      END IF;
      IF (x_ilsv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_ilsv_rec.object_version_number := l_ilsv_rec.object_version_number;
      END IF;
      IF (x_ilsv_rec.sty_id = Okl_Api.G_MISS_NUM)
      THEN
        x_ilsv_rec.sty_id := l_ilsv_rec.sty_id;
      END IF;
      IF (x_ilsv_rec.inf_id = Okl_Api.G_MISS_NUM)
      THEN
        x_ilsv_rec.inf_id := l_ilsv_rec.inf_id;
      END IF;
      IF (x_ilsv_rec.ilt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_ilsv_rec.ilt_id := l_ilsv_rec.ilt_id;
      END IF;
      IF (x_ilsv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute_category := l_ilsv_rec.attribute_category;
      END IF;
      IF (x_ilsv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute1 := l_ilsv_rec.attribute1;
      END IF;
      IF (x_ilsv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute2 := l_ilsv_rec.attribute2;
      END IF;
      IF (x_ilsv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute3 := l_ilsv_rec.attribute3;
      END IF;
      IF (x_ilsv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute4 := l_ilsv_rec.attribute4;
      END IF;
      IF (x_ilsv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute5 := l_ilsv_rec.attribute5;
      END IF;
      IF (x_ilsv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute6 := l_ilsv_rec.attribute6;
      END IF;
      IF (x_ilsv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute7 := l_ilsv_rec.attribute7;
      END IF;
      IF (x_ilsv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute8 := l_ilsv_rec.attribute8;
      END IF;
      IF (x_ilsv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute9 := l_ilsv_rec.attribute9;
      END IF;
      IF (x_ilsv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute10 := l_ilsv_rec.attribute10;
      END IF;
      IF (x_ilsv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute11 := l_ilsv_rec.attribute11;
      END IF;
      IF (x_ilsv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute12 := l_ilsv_rec.attribute12;
      END IF;
      IF (x_ilsv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute13 := l_ilsv_rec.attribute13;
      END IF;
      IF (x_ilsv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute14 := l_ilsv_rec.attribute14;
      END IF;
      IF (x_ilsv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_ilsv_rec.attribute15 := l_ilsv_rec.attribute15;
      END IF;
      IF (x_ilsv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_ilsv_rec.created_by := l_ilsv_rec.created_by;
      END IF;
      IF (x_ilsv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_ilsv_rec.creation_date := l_ilsv_rec.creation_date;
      END IF;
      IF (x_ilsv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_ilsv_rec.last_updated_by := l_ilsv_rec.last_updated_by;
      END IF;
      IF (x_ilsv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_ilsv_rec.last_update_date := l_ilsv_rec.last_update_date;
      END IF;
      IF (x_ilsv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_ilsv_rec.last_update_login := l_ilsv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INVC_FRMT_STRMS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_ilsv_rec IN  ilsv_rec_type,
      x_ilsv_rec OUT NOCOPY ilsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_ilsv_rec := p_ilsv_rec;
      x_ilsv_rec.OBJECT_VERSION_NUMBER := NVL(x_ilsv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_ilsv_rec,                        -- IN
      l_ilsv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ilsv_rec, l_def_ilsv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_ilsv_rec := fill_who_columns(l_def_ilsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ilsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ilsv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ilsv_rec, l_ils_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ils_rec,
      lx_ils_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ils_rec, l_def_ilsv_rec);
    x_ilsv_rec := l_def_ilsv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
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
  ----------------------------------------
  -- PL/SQL TBL update_row for:ILSV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilsv_tbl                     IN ilsv_tbl_type,
    x_ilsv_tbl                     OUT NOCOPY ilsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ilsv_tbl.COUNT > 0) THEN
      i := p_ilsv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ilsv_rec                     => p_ilsv_tbl(i),
          x_ilsv_rec                     => x_ilsv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_ilsv_tbl.LAST OR x_return_status <> Okl_Api.G_RET_STS_SUCCESS ); -- Added or conditon for bug 9482832
        i := p_ilsv_tbl.NEXT(i);
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
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
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
  ----------------------------------------
  -- delete_row for:OKL_INVC_FRMT_STRMS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ils_rec                      IN ils_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'STRMS_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ils_rec                      ils_rec_type:= p_ils_rec;
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
    DELETE FROM OKL_INVC_FRMT_STRMS
     WHERE ID = l_ils_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- delete_row for:OKL_INVC_FRMT_STRMS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilsv_rec                     IN ilsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_ilsv_rec                     ilsv_rec_type := p_ilsv_rec;
    l_ils_rec                      ils_rec_type;
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
    migrate(l_ilsv_rec, l_ils_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ils_rec
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
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
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
  ----------------------------------------
  -- PL/SQL TBL delete_row for:ILSV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilsv_tbl                     IN ilsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ilsv_tbl.COUNT > 0) THEN
      i := p_ilsv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ilsv_rec                     => p_ilsv_tbl(i));
	-- Store the highest degree of error
	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
	   IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   	  l_overall_status := x_return_status;
	   END IF;
	END IF;
        EXIT WHEN (i = p_ilsv_tbl.LAST);
        i := p_ilsv_tbl.NEXT(i);
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
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
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
END Okl_Ils_Pvt;

/
