--------------------------------------------------------
--  DDL for Package Body OKL_CLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CLS_PVT" AS
/* $Header: OKLSCLSB.pls 115.3 2002/05/10 08:32:29 pkm ship        $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_clsv_rec IN clsv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_clsv_rec.id = Okl_Api.G_MISS_NUM OR
       p_clsv_rec.id IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'id');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number (p_clsv_rec IN clsv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_clsv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_clsv_rec.object_version_number IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'object_version_number');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_object_version_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_crn_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_crn_id (p_clsv_rec IN clsv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_crn_id_csr IS
    SELECT '1'
	FROM OKL_CRITERIA_B
	WHERE id = p_clsv_rec.crn_id;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_clsv_rec.crn_id = Okl_Api.G_MISS_NUM OR
       p_clsv_rec.crn_id IS NULL
    THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'crn_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Validate Foreign Key
 	OPEN l_crn_id_csr;
	FETCH l_crn_id_csr INTO l_dummy_var;
	CLOSE l_crn_id_csr;

	IF (l_dummy_var <> '1') THEN
	 	x_return_status := Okl_Api.G_RET_STS_ERROR;
	    Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
		 				    p_msg_name			=> G_NO_PARENT_RECORD,
							p_token1			=> G_COL_NAME_TOKEN,
							p_token1_value		=> 'CRN_ID_FOR',
							p_token2			=> G_CHILD_TABLE_TOKEN,
							p_token2_value		=> G_VIEW,
							p_token3			=> G_PARENT_TABLE_TOKEN,
							p_token3_value		=> 'OKL_CRTRN_LNSTYLS_V');

		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END validate_crn_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_lse_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_lse_id (p_clsv_rec IN clsv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_lse_id_csr IS
    SELECT '1'
	FROM OKC_LINE_STYLES_B
	WHERE id = p_clsv_rec.crn_id;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_clsv_rec.lse_id = Okl_Api.G_MISS_NUM OR
       p_clsv_rec.lse_id IS NULL
    THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'lse_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Validate Foreign Key
 	OPEN l_lse_id_csr;
	FETCH l_lse_id_csr INTO l_dummy_var;
	CLOSE l_lse_id_csr;

	IF (l_dummy_var <> '1') THEN
	 	x_return_status := Okl_Api.G_RET_STS_ERROR;
	    Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
		 				    p_msg_name			=> G_NO_PARENT_RECORD,
							p_token1			=> G_COL_NAME_TOKEN,
							p_token1_value		=> 'LSE_ID_FOR',
							p_token2			=> G_CHILD_TABLE_TOKEN,
							p_token2_value		=> G_VIEW,
							p_token3			=> G_PARENT_TABLE_TOKEN,
							p_token3_value		=> 'OKL_CRTRN_LNSTYLS_V');

		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END validate_lse_id;


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
  -- FUNCTION get_rec for: OKL_CRTRN_LNSTYLS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cls_rec                      IN cls_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cls_rec_type IS
    CURSOR cls_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CRN_ID,
            LSE_ID,
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
      FROM Okl_Crtrn_Lnstyls
     WHERE okl_crtrn_lnstyls.id = p_id;
    l_cls_pk                       cls_pk_csr%ROWTYPE;
    l_cls_rec                      cls_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cls_pk_csr (p_cls_rec.id);
    FETCH cls_pk_csr INTO
              l_cls_rec.ID,
              l_cls_rec.CRN_ID,
              l_cls_rec.LSE_ID,
              l_cls_rec.OBJECT_VERSION_NUMBER,
              l_cls_rec.ATTRIBUTE_CATEGORY,
              l_cls_rec.ATTRIBUTE1,
              l_cls_rec.ATTRIBUTE2,
              l_cls_rec.ATTRIBUTE3,
              l_cls_rec.ATTRIBUTE4,
              l_cls_rec.ATTRIBUTE5,
              l_cls_rec.ATTRIBUTE6,
              l_cls_rec.ATTRIBUTE7,
              l_cls_rec.ATTRIBUTE8,
              l_cls_rec.ATTRIBUTE9,
              l_cls_rec.ATTRIBUTE10,
              l_cls_rec.ATTRIBUTE11,
              l_cls_rec.ATTRIBUTE12,
              l_cls_rec.ATTRIBUTE13,
              l_cls_rec.ATTRIBUTE14,
              l_cls_rec.ATTRIBUTE15,
              l_cls_rec.CREATED_BY,
              l_cls_rec.CREATION_DATE,
              l_cls_rec.LAST_UPDATED_BY,
              l_cls_rec.LAST_UPDATE_DATE,
              l_cls_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := cls_pk_csr%NOTFOUND;
    CLOSE cls_pk_csr;
    RETURN(l_cls_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cls_rec                      IN cls_rec_type
  ) RETURN cls_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cls_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CRTRN_LNSTYLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_clsv_rec                     IN clsv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN clsv_rec_type IS
    CURSOR okl_clsv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CRN_ID,
            LSE_ID,
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
      FROM Okl_Crtrn_Lnstyls_V
     WHERE okl_crtrn_lnstyls_v.id = p_id;
    l_okl_clsv_pk                  okl_clsv_pk_csr%ROWTYPE;
    l_clsv_rec                     clsv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_clsv_pk_csr (p_clsv_rec.id);
    FETCH okl_clsv_pk_csr INTO
              l_clsv_rec.ID,
              l_clsv_rec.OBJECT_VERSION_NUMBER,
              l_clsv_rec.CRN_ID,
              l_clsv_rec.LSE_ID,
              l_clsv_rec.ATTRIBUTE_CATEGORY,
              l_clsv_rec.ATTRIBUTE1,
              l_clsv_rec.ATTRIBUTE2,
              l_clsv_rec.ATTRIBUTE3,
              l_clsv_rec.ATTRIBUTE4,
              l_clsv_rec.ATTRIBUTE5,
              l_clsv_rec.ATTRIBUTE6,
              l_clsv_rec.ATTRIBUTE7,
              l_clsv_rec.ATTRIBUTE8,
              l_clsv_rec.ATTRIBUTE9,
              l_clsv_rec.ATTRIBUTE10,
              l_clsv_rec.ATTRIBUTE11,
              l_clsv_rec.ATTRIBUTE12,
              l_clsv_rec.ATTRIBUTE13,
              l_clsv_rec.ATTRIBUTE14,
              l_clsv_rec.ATTRIBUTE15,
              l_clsv_rec.CREATED_BY,
              l_clsv_rec.CREATION_DATE,
              l_clsv_rec.LAST_UPDATED_BY,
              l_clsv_rec.LAST_UPDATE_DATE,
              l_clsv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_clsv_pk_csr%NOTFOUND;
    CLOSE okl_clsv_pk_csr;
    RETURN(l_clsv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_clsv_rec                     IN clsv_rec_type
  ) RETURN clsv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_clsv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CRTRN_LNSTYLS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_clsv_rec	IN clsv_rec_type
  ) RETURN clsv_rec_type IS
    l_clsv_rec	clsv_rec_type := p_clsv_rec;
  BEGIN
    IF (l_clsv_rec.object_version_number = okl_api.G_MISS_NUM) THEN
      l_clsv_rec.object_version_number := NULL;
    END IF;
    IF (l_clsv_rec.crn_id = okl_api.G_MISS_NUM) THEN
      l_clsv_rec.crn_id := NULL;
    END IF;
    IF (l_clsv_rec.lse_id = okl_api.G_MISS_NUM) THEN
      l_clsv_rec.lse_id := NULL;
    END IF;
    IF (l_clsv_rec.attribute_category = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute_category := NULL;
    END IF;
    IF (l_clsv_rec.attribute1 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute1 := NULL;
    END IF;
    IF (l_clsv_rec.attribute2 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute2 := NULL;
    END IF;
    IF (l_clsv_rec.attribute3 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute3 := NULL;
    END IF;
    IF (l_clsv_rec.attribute4 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute4 := NULL;
    END IF;
    IF (l_clsv_rec.attribute5 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute5 := NULL;
    END IF;
    IF (l_clsv_rec.attribute6 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute6 := NULL;
    END IF;
    IF (l_clsv_rec.attribute7 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute7 := NULL;
    END IF;
    IF (l_clsv_rec.attribute8 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute8 := NULL;
    END IF;
    IF (l_clsv_rec.attribute9 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute9 := NULL;
    END IF;
    IF (l_clsv_rec.attribute10 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute10 := NULL;
    END IF;
    IF (l_clsv_rec.attribute11 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute11 := NULL;
    END IF;
    IF (l_clsv_rec.attribute12 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute12 := NULL;
    END IF;
    IF (l_clsv_rec.attribute13 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute13 := NULL;
    END IF;
    IF (l_clsv_rec.attribute14 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute14 := NULL;
    END IF;
    IF (l_clsv_rec.attribute15 = okl_api.G_MISS_CHAR) THEN
      l_clsv_rec.attribute15 := NULL;
    END IF;
    IF (l_clsv_rec.created_by = okl_api.G_MISS_NUM) THEN
      l_clsv_rec.created_by := NULL;
    END IF;
    IF (l_clsv_rec.creation_date = okl_api.G_MISS_DATE) THEN
      l_clsv_rec.creation_date := NULL;
    END IF;
    IF (l_clsv_rec.last_updated_by = okl_api.G_MISS_NUM) THEN
      l_clsv_rec.last_updated_by := NULL;
    END IF;
    IF (l_clsv_rec.last_update_date = okl_api.G_MISS_DATE) THEN
      l_clsv_rec.last_update_date := NULL;
    END IF;
    IF (l_clsv_rec.last_update_login = okl_api.G_MISS_NUM) THEN
      l_clsv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_clsv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_CRTRN_LNSTYLS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_clsv_rec IN  clsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
	-- TAPI postgen 05/23/2001
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- End TAPI postgen 05/23/2001
  BEGIN
	-- TAPI postgen 05/23/2001
    validate_id(p_clsv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_object_version_number(p_clsv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_crn_id(p_clsv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_lse_id(p_clsv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
	-- End TAPI postgen 05/23/2001

    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_CRTRN_LNSTYLS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_clsv_rec IN clsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN clsv_rec_type,
    p_to	OUT NOCOPY cls_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.crn_id := p_from.crn_id;
    p_to.lse_id := p_from.lse_id;
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
    p_from	IN cls_rec_type,
    p_to	OUT NOCOPY clsv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.crn_id := p_from.crn_id;
    p_to.lse_id := p_from.lse_id;
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
  ------------------------------------------
  -- validate_row for:OKL_CRTRN_LNSTYLS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_clsv_rec                     clsv_rec_type := p_clsv_rec;
    l_cls_rec                      cls_rec_type;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_clsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_clsv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:CLSV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clsv_tbl.COUNT > 0) THEN
      i := p_clsv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clsv_rec                     => p_clsv_tbl(i));
        EXIT WHEN (i = p_clsv_tbl.LAST);
        i := p_clsv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- insert_row for:OKL_CRTRN_LNSTYLS --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cls_rec                      IN cls_rec_type,
    x_cls_rec                      OUT NOCOPY cls_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNSTYLS_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_cls_rec                      cls_rec_type := p_cls_rec;
    l_def_cls_rec                  cls_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKL_CRTRN_LNSTYLS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_cls_rec IN  cls_rec_type,
      x_cls_rec OUT NOCOPY cls_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_cls_rec := p_cls_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cls_rec,                         -- IN
      l_cls_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CRTRN_LNSTYLS(
        id,
        crn_id,
        lse_id,
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
        l_cls_rec.id,
        l_cls_rec.crn_id,
        l_cls_rec.lse_id,
        l_cls_rec.object_version_number,
        l_cls_rec.attribute_category,
        l_cls_rec.attribute1,
        l_cls_rec.attribute2,
        l_cls_rec.attribute3,
        l_cls_rec.attribute4,
        l_cls_rec.attribute5,
        l_cls_rec.attribute6,
        l_cls_rec.attribute7,
        l_cls_rec.attribute8,
        l_cls_rec.attribute9,
        l_cls_rec.attribute10,
        l_cls_rec.attribute11,
        l_cls_rec.attribute12,
        l_cls_rec.attribute13,
        l_cls_rec.attribute14,
        l_cls_rec.attribute15,
        l_cls_rec.created_by,
        l_cls_rec.creation_date,
        l_cls_rec.last_updated_by,
        l_cls_rec.last_update_date,
        l_cls_rec.last_update_login);
    -- Set OUT values
    x_cls_rec := l_cls_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_CRTRN_LNSTYLS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type,
    x_clsv_rec                     OUT NOCOPY clsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_clsv_rec                     clsv_rec_type;
    l_def_clsv_rec                 clsv_rec_type;
    l_cls_rec                      cls_rec_type;
    lx_cls_rec                     cls_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_clsv_rec	IN clsv_rec_type
    ) RETURN clsv_rec_type IS
      l_clsv_rec	clsv_rec_type := p_clsv_rec;
    BEGIN
      l_clsv_rec.CREATION_DATE := SYSDATE;
      l_clsv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_clsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_clsv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_clsv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_clsv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_CRTRN_LNSTYLS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_clsv_rec IN  clsv_rec_type,
      x_clsv_rec OUT NOCOPY clsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_clsv_rec := p_clsv_rec;
      x_clsv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_clsv_rec := null_out_defaults(p_clsv_rec);
    -- Set primary key value
    l_clsv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_clsv_rec,                        -- IN
      l_def_clsv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_clsv_rec := fill_who_columns(l_def_clsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_clsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_clsv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_clsv_rec, l_cls_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cls_rec,
      lx_cls_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cls_rec, l_def_clsv_rec);
    -- Set OUT values
    x_clsv_rec := l_def_clsv_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:CLSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type,
    x_clsv_tbl                     OUT NOCOPY clsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clsv_tbl.COUNT > 0) THEN
      i := p_clsv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clsv_rec                     => p_clsv_tbl(i),
          x_clsv_rec                     => x_clsv_tbl(i));
        EXIT WHEN (i = p_clsv_tbl.LAST);
        i := p_clsv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- lock_row for:OKL_CRTRN_LNSTYLS --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cls_rec                      IN cls_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cls_rec IN cls_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CRTRN_LNSTYLS
     WHERE ID = p_cls_rec.id
       AND OBJECT_VERSION_NUMBER = p_cls_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cls_rec IN cls_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CRTRN_LNSTYLS
    WHERE ID = p_cls_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNSTYLS_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_CRTRN_LNSTYLS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_CRTRN_LNSTYLS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_cls_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        okl_api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_cls_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cls_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cls_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      okl_api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_CRTRN_LNSTYLS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_cls_rec                      cls_rec_type;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_clsv_rec, l_cls_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cls_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:CLSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clsv_tbl.COUNT > 0) THEN
      i := p_clsv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clsv_rec                     => p_clsv_tbl(i));
        EXIT WHEN (i = p_clsv_tbl.LAST);
        i := p_clsv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- update_row for:OKL_CRTRN_LNSTYLS --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cls_rec                      IN cls_rec_type,
    x_cls_rec                      OUT NOCOPY cls_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNSTYLS_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_cls_rec                      cls_rec_type := p_cls_rec;
    l_def_cls_rec                  cls_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cls_rec	IN cls_rec_type,
      x_cls_rec	OUT NOCOPY cls_rec_type
    ) RETURN VARCHAR2 IS
      l_cls_rec                      cls_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_cls_rec := p_cls_rec;
      -- Get current database values
      l_cls_rec := get_rec(p_cls_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cls_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_cls_rec.id := l_cls_rec.id;
      END IF;
      IF (x_cls_rec.crn_id = okl_api.G_MISS_NUM)
      THEN
        x_cls_rec.crn_id := l_cls_rec.crn_id;
      END IF;
      IF (x_cls_rec.lse_id = okl_api.G_MISS_NUM)
      THEN
        x_cls_rec.lse_id := l_cls_rec.lse_id;
      END IF;
      IF (x_cls_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_cls_rec.object_version_number := l_cls_rec.object_version_number;
      END IF;
      IF (x_cls_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute_category := l_cls_rec.attribute_category;
      END IF;
      IF (x_cls_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute1 := l_cls_rec.attribute1;
      END IF;
      IF (x_cls_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute2 := l_cls_rec.attribute2;
      END IF;
      IF (x_cls_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute3 := l_cls_rec.attribute3;
      END IF;
      IF (x_cls_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute4 := l_cls_rec.attribute4;
      END IF;
      IF (x_cls_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute5 := l_cls_rec.attribute5;
      END IF;
      IF (x_cls_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute6 := l_cls_rec.attribute6;
      END IF;
      IF (x_cls_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute7 := l_cls_rec.attribute7;
      END IF;
      IF (x_cls_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute8 := l_cls_rec.attribute8;
      END IF;
      IF (x_cls_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute9 := l_cls_rec.attribute9;
      END IF;
      IF (x_cls_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute10 := l_cls_rec.attribute10;
      END IF;
      IF (x_cls_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute11 := l_cls_rec.attribute11;
      END IF;
      IF (x_cls_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute12 := l_cls_rec.attribute12;
      END IF;
      IF (x_cls_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute13 := l_cls_rec.attribute13;
      END IF;
      IF (x_cls_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute14 := l_cls_rec.attribute14;
      END IF;
      IF (x_cls_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_cls_rec.attribute15 := l_cls_rec.attribute15;
      END IF;
      IF (x_cls_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_cls_rec.created_by := l_cls_rec.created_by;
      END IF;
      IF (x_cls_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_cls_rec.creation_date := l_cls_rec.creation_date;
      END IF;
      IF (x_cls_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_cls_rec.last_updated_by := l_cls_rec.last_updated_by;
      END IF;
      IF (x_cls_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_cls_rec.last_update_date := l_cls_rec.last_update_date;
      END IF;
      IF (x_cls_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_cls_rec.last_update_login := l_cls_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_CRTRN_LNSTYLS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_cls_rec IN  cls_rec_type,
      x_cls_rec OUT NOCOPY cls_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_cls_rec := p_cls_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cls_rec,                         -- IN
      l_cls_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cls_rec, l_def_cls_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_CRTRN_LNSTYLS
    SET CRN_ID = l_def_cls_rec.crn_id,
        LSE_ID = l_def_cls_rec.lse_id,
        OBJECT_VERSION_NUMBER = l_def_cls_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_cls_rec.attribute_category,
        ATTRIBUTE1 = l_def_cls_rec.attribute1,
        ATTRIBUTE2 = l_def_cls_rec.attribute2,
        ATTRIBUTE3 = l_def_cls_rec.attribute3,
        ATTRIBUTE4 = l_def_cls_rec.attribute4,
        ATTRIBUTE5 = l_def_cls_rec.attribute5,
        ATTRIBUTE6 = l_def_cls_rec.attribute6,
        ATTRIBUTE7 = l_def_cls_rec.attribute7,
        ATTRIBUTE8 = l_def_cls_rec.attribute8,
        ATTRIBUTE9 = l_def_cls_rec.attribute9,
        ATTRIBUTE10 = l_def_cls_rec.attribute10,
        ATTRIBUTE11 = l_def_cls_rec.attribute11,
        ATTRIBUTE12 = l_def_cls_rec.attribute12,
        ATTRIBUTE13 = l_def_cls_rec.attribute13,
        ATTRIBUTE14 = l_def_cls_rec.attribute14,
        ATTRIBUTE15 = l_def_cls_rec.attribute15,
        CREATED_BY = l_def_cls_rec.created_by,
        CREATION_DATE = l_def_cls_rec.creation_date,
        LAST_UPDATED_BY = l_def_cls_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cls_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cls_rec.last_update_login
    WHERE ID = l_def_cls_rec.id;

    x_cls_rec := l_def_cls_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_CRTRN_LNSTYLS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type,
    x_clsv_rec                     OUT NOCOPY clsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_clsv_rec                     clsv_rec_type := p_clsv_rec;
    l_def_clsv_rec                 clsv_rec_type;
    l_cls_rec                      cls_rec_type;
    lx_cls_rec                     cls_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_clsv_rec	IN clsv_rec_type
    ) RETURN clsv_rec_type IS
      l_clsv_rec	clsv_rec_type := p_clsv_rec;
    BEGIN
      l_clsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_clsv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_clsv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_clsv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_clsv_rec	IN clsv_rec_type,
      x_clsv_rec	OUT NOCOPY clsv_rec_type
    ) RETURN VARCHAR2 IS
      l_clsv_rec                     clsv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_clsv_rec := p_clsv_rec;
      -- Get current database values
      l_clsv_rec := get_rec(p_clsv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_clsv_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_clsv_rec.id := l_clsv_rec.id;
      END IF;
      IF (x_clsv_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_clsv_rec.object_version_number := l_clsv_rec.object_version_number;
      END IF;
      IF (x_clsv_rec.crn_id = okl_api.G_MISS_NUM)
      THEN
        x_clsv_rec.crn_id := l_clsv_rec.crn_id;
      END IF;
      IF (x_clsv_rec.lse_id = okl_api.G_MISS_NUM)
      THEN
        x_clsv_rec.lse_id := l_clsv_rec.lse_id;
      END IF;
      IF (x_clsv_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute_category := l_clsv_rec.attribute_category;
      END IF;
      IF (x_clsv_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute1 := l_clsv_rec.attribute1;
      END IF;
      IF (x_clsv_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute2 := l_clsv_rec.attribute2;
      END IF;
      IF (x_clsv_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute3 := l_clsv_rec.attribute3;
      END IF;
      IF (x_clsv_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute4 := l_clsv_rec.attribute4;
      END IF;
      IF (x_clsv_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute5 := l_clsv_rec.attribute5;
      END IF;
      IF (x_clsv_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute6 := l_clsv_rec.attribute6;
      END IF;
      IF (x_clsv_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute7 := l_clsv_rec.attribute7;
      END IF;
      IF (x_clsv_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute8 := l_clsv_rec.attribute8;
      END IF;
      IF (x_clsv_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute9 := l_clsv_rec.attribute9;
      END IF;
      IF (x_clsv_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute10 := l_clsv_rec.attribute10;
      END IF;
      IF (x_clsv_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute11 := l_clsv_rec.attribute11;
      END IF;
      IF (x_clsv_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute12 := l_clsv_rec.attribute12;
      END IF;
      IF (x_clsv_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute13 := l_clsv_rec.attribute13;
      END IF;
      IF (x_clsv_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute14 := l_clsv_rec.attribute14;
      END IF;
      IF (x_clsv_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_clsv_rec.attribute15 := l_clsv_rec.attribute15;
      END IF;
      IF (x_clsv_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_clsv_rec.created_by := l_clsv_rec.created_by;
      END IF;
      IF (x_clsv_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_clsv_rec.creation_date := l_clsv_rec.creation_date;
      END IF;
      IF (x_clsv_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_clsv_rec.last_updated_by := l_clsv_rec.last_updated_by;
      END IF;
      IF (x_clsv_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_clsv_rec.last_update_date := l_clsv_rec.last_update_date;
      END IF;
      IF (x_clsv_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_clsv_rec.last_update_login := l_clsv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_CRTRN_LNSTYLS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_clsv_rec IN  clsv_rec_type,
      x_clsv_rec OUT NOCOPY clsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_clsv_rec := p_clsv_rec;
      x_clsv_rec.OBJECT_VERSION_NUMBER := NVL(x_clsv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_clsv_rec,                        -- IN
      l_clsv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_clsv_rec, l_def_clsv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_clsv_rec := fill_who_columns(l_def_clsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_clsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_clsv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_clsv_rec, l_cls_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cls_rec,
      lx_cls_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cls_rec, l_def_clsv_rec);
    x_clsv_rec := l_def_clsv_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:CLSV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type,
    x_clsv_tbl                     OUT NOCOPY clsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clsv_tbl.COUNT > 0) THEN
      i := p_clsv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clsv_rec                     => p_clsv_tbl(i),
          x_clsv_rec                     => x_clsv_tbl(i));
        EXIT WHEN (i = p_clsv_tbl.LAST);
        i := p_clsv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- delete_row for:OKL_CRTRN_LNSTYLS --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cls_rec                      IN cls_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNSTYLS_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_cls_rec                      cls_rec_type:= p_cls_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_CRTRN_LNSTYLS
     WHERE ID = l_cls_rec.id;

    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_CRTRN_LNSTYLS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_clsv_rec                     clsv_rec_type := p_clsv_rec;
    l_cls_rec                      cls_rec_type;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_clsv_rec, l_cls_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cls_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:CLSV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clsv_tbl.COUNT > 0) THEN
      i := p_clsv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clsv_rec                     => p_clsv_tbl(i));
        EXIT WHEN (i = p_clsv_tbl.LAST);
        i := p_clsv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
END Okl_Cls_Pvt;

/
