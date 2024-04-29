--------------------------------------------------------
--  DDL for Package Body OKL_QCN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QCN_PVT" AS
/* $Header: OKLSQCNB.pls 115.3 2002/05/10 08:32:43 pkm ship        $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_qcnv_rec IN qcnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_qcnv_rec.id = Okl_Api.G_MISS_NUM OR
       p_qcnv_rec.id IS NULL
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
  PROCEDURE validate_object_version_number (p_qcnv_rec IN qcnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_qcnv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_qcnv_rec.object_version_number IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     => G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'object_version_number');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_object_version_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_crn_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_crn_id (p_qcnv_rec IN qcnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_crn_id_csr IS
    SELECT '1'
	FROM OKL_CRITERIA_B
	WHERE id = p_qcnv_rec.crn_id;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_qcnv_rec.crn_id = Okl_Api.G_MISS_NUM OR
       p_qcnv_rec.crn_id IS NULL
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
							p_token3_value		=> 'OKL_QUESTION_CRTRNS_V');

		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END validate_crn_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_qty_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_qty_id (p_qcnv_rec IN qcnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_qty_id_csr IS
    SELECT '1'
	FROM OKL_QUESTION_TYPES_B
	WHERE id = p_qcnv_rec.qty_id;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_qcnv_rec.qty_id = Okl_Api.G_MISS_NUM OR
       p_qcnv_rec.qty_id IS NULL
    THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'qty_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Validate Foreign Key
 	OPEN l_qty_id_csr;
	FETCH l_qty_id_csr INTO l_dummy_var;
	CLOSE l_qty_id_csr;

	IF (l_dummy_var <> '1') THEN
	 	x_return_status := Okl_Api.G_RET_STS_ERROR;
	    Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
		 				    p_msg_name			=> G_NO_PARENT_RECORD,
							p_token1			=> G_COL_NAME_TOKEN,
							p_token1_value		=> 'QTY_ID_FOR',
							p_token2			=> G_CHILD_TABLE_TOKEN,
							p_token2_value		=> G_VIEW,
							p_token3			=> G_PARENT_TABLE_TOKEN,
							p_token3_value		=> 'OKL_QUESTION_CRTRNS_V');

		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END validate_qty_id;

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
  -- FUNCTION get_rec for: OKL_QUESTION_CRTRNS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qcn_rec                      IN qcn_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qcn_rec_type IS
    CURSOR qcn_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CRN_ID,
            QTY_ID,
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
      FROM Okl_Question_Crtrns
     WHERE okl_question_crtrns.id = p_id;
    l_qcn_pk                       qcn_pk_csr%ROWTYPE;
    l_qcn_rec                      qcn_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN qcn_pk_csr (p_qcn_rec.id);
    FETCH qcn_pk_csr INTO
              l_qcn_rec.ID,
              l_qcn_rec.CRN_ID,
              l_qcn_rec.QTY_ID,
              l_qcn_rec.OBJECT_VERSION_NUMBER,
              l_qcn_rec.ATTRIBUTE_CATEGORY,
              l_qcn_rec.ATTRIBUTE1,
              l_qcn_rec.ATTRIBUTE2,
              l_qcn_rec.ATTRIBUTE3,
              l_qcn_rec.ATTRIBUTE4,
              l_qcn_rec.ATTRIBUTE5,
              l_qcn_rec.ATTRIBUTE6,
              l_qcn_rec.ATTRIBUTE7,
              l_qcn_rec.ATTRIBUTE8,
              l_qcn_rec.ATTRIBUTE9,
              l_qcn_rec.ATTRIBUTE10,
              l_qcn_rec.ATTRIBUTE11,
              l_qcn_rec.ATTRIBUTE12,
              l_qcn_rec.ATTRIBUTE13,
              l_qcn_rec.ATTRIBUTE14,
              l_qcn_rec.ATTRIBUTE15,
              l_qcn_rec.CREATED_BY,
              l_qcn_rec.CREATION_DATE,
              l_qcn_rec.LAST_UPDATED_BY,
              l_qcn_rec.LAST_UPDATE_DATE,
              l_qcn_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := qcn_pk_csr%NOTFOUND;
    CLOSE qcn_pk_csr;
    RETURN(l_qcn_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qcn_rec                      IN qcn_rec_type
  ) RETURN qcn_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qcn_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_QUESTION_CRTRNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qcnv_rec                     IN qcnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qcnv_rec_type IS
    CURSOR okl_qcnv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CRN_ID,
            QTY_ID,
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
      FROM Okl_Question_Crtrns_V
     WHERE okl_question_crtrns_v.id = p_id;
    l_okl_qcnv_pk                  okl_qcnv_pk_csr%ROWTYPE;
    l_qcnv_rec                     qcnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_qcnv_pk_csr (p_qcnv_rec.id);
    FETCH okl_qcnv_pk_csr INTO
              l_qcnv_rec.ID,
              l_qcnv_rec.OBJECT_VERSION_NUMBER,
              l_qcnv_rec.CRN_ID,
              l_qcnv_rec.QTY_ID,
              l_qcnv_rec.ATTRIBUTE_CATEGORY,
              l_qcnv_rec.ATTRIBUTE1,
              l_qcnv_rec.ATTRIBUTE2,
              l_qcnv_rec.ATTRIBUTE3,
              l_qcnv_rec.ATTRIBUTE4,
              l_qcnv_rec.ATTRIBUTE5,
              l_qcnv_rec.ATTRIBUTE6,
              l_qcnv_rec.ATTRIBUTE7,
              l_qcnv_rec.ATTRIBUTE8,
              l_qcnv_rec.ATTRIBUTE9,
              l_qcnv_rec.ATTRIBUTE10,
              l_qcnv_rec.ATTRIBUTE11,
              l_qcnv_rec.ATTRIBUTE12,
              l_qcnv_rec.ATTRIBUTE13,
              l_qcnv_rec.ATTRIBUTE14,
              l_qcnv_rec.ATTRIBUTE15,
              l_qcnv_rec.CREATED_BY,
              l_qcnv_rec.CREATION_DATE,
              l_qcnv_rec.LAST_UPDATED_BY,
              l_qcnv_rec.LAST_UPDATE_DATE,
              l_qcnv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_qcnv_pk_csr%NOTFOUND;
    CLOSE okl_qcnv_pk_csr;
    RETURN(l_qcnv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qcnv_rec                     IN qcnv_rec_type
  ) RETURN qcnv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qcnv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_QUESTION_CRTRNS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_qcnv_rec	IN qcnv_rec_type
  ) RETURN qcnv_rec_type IS
    l_qcnv_rec	qcnv_rec_type := p_qcnv_rec;
  BEGIN
    IF (l_qcnv_rec.object_version_number = okl_api.G_MISS_NUM) THEN
      l_qcnv_rec.object_version_number := NULL;
    END IF;
    IF (l_qcnv_rec.crn_id = okl_api.G_MISS_NUM) THEN
      l_qcnv_rec.crn_id := NULL;
    END IF;
    IF (l_qcnv_rec.qty_id = okl_api.G_MISS_NUM) THEN
      l_qcnv_rec.qty_id := NULL;
    END IF;
    IF (l_qcnv_rec.attribute_category = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute_category := NULL;
    END IF;
    IF (l_qcnv_rec.attribute1 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute1 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute2 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute2 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute3 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute3 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute4 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute4 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute5 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute5 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute6 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute6 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute7 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute7 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute8 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute8 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute9 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute9 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute10 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute10 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute11 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute11 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute12 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute12 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute13 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute13 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute14 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute14 := NULL;
    END IF;
    IF (l_qcnv_rec.attribute15 = okl_api.G_MISS_CHAR) THEN
      l_qcnv_rec.attribute15 := NULL;
    END IF;
    IF (l_qcnv_rec.created_by = okl_api.G_MISS_NUM) THEN
      l_qcnv_rec.created_by := NULL;
    END IF;
    IF (l_qcnv_rec.creation_date = okl_api.G_MISS_DATE) THEN
      l_qcnv_rec.creation_date := NULL;
    END IF;
    IF (l_qcnv_rec.last_updated_by = okl_api.G_MISS_NUM) THEN
      l_qcnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_qcnv_rec.last_update_date = okl_api.G_MISS_DATE) THEN
      l_qcnv_rec.last_update_date := NULL;
    END IF;
    IF (l_qcnv_rec.last_update_login = okl_api.G_MISS_NUM) THEN
      l_qcnv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_qcnv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_QUESTION_CRTRNS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_qcnv_rec IN  qcnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
	-- TAPI postgen 05/23/2001
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- End TAPI postgen 05/23/2001
  BEGIN
	-- TAPI postgen 05/23/2001
    validate_id(p_qcnv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_object_version_number(p_qcnv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_crn_id(p_qcnv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_qty_id(p_qcnv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	-- End TAPI postgen 05/23/2001

    IF p_qcnv_rec.id = okl_api.G_MISS_NUM OR
       p_qcnv_rec.id IS NULL
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := okl_api.G_RET_STS_ERROR;
    ELSIF p_qcnv_rec.object_version_number = okl_api.G_MISS_NUM OR
          p_qcnv_rec.object_version_number IS NULL
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := okl_api.G_RET_STS_ERROR;
    ELSIF p_qcnv_rec.crn_id = okl_api.G_MISS_NUM OR
          p_qcnv_rec.crn_id IS NULL
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'crn_id');
      l_return_status := okl_api.G_RET_STS_ERROR;
    ELSIF p_qcnv_rec.qty_id = okl_api.G_MISS_NUM OR
          p_qcnv_rec.qty_id IS NULL
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'qty_id');
      l_return_status := okl_api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_QUESTION_CRTRNS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_qcnv_rec IN qcnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN qcnv_rec_type,
    p_to	OUT NOCOPY qcn_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.crn_id := p_from.crn_id;
    p_to.qty_id := p_from.qty_id;
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
    p_from	IN qcn_rec_type,
    p_to	OUT NOCOPY qcnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.crn_id := p_from.crn_id;
    p_to.qty_id := p_from.qty_id;
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
  -- validate_row for:OKL_QUESTION_CRTRNS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_rec                     IN qcnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_qcnv_rec                     qcnv_rec_type := p_qcnv_rec;
    l_qcn_rec                      qcn_rec_type;
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
    l_return_status := Validate_Attributes(l_qcnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_qcnv_rec);
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
  -- PL/SQL TBL validate_row for:QCNV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_tbl                     IN qcnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcnv_tbl.COUNT > 0) THEN
      i := p_qcnv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qcnv_rec                     => p_qcnv_tbl(i));
        EXIT WHEN (i = p_qcnv_tbl.LAST);
        i := p_qcnv_tbl.NEXT(i);
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
  ----------------------------------------
  -- insert_row for:OKL_QUESTION_CRTRNS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcn_rec                      IN qcn_rec_type,
    x_qcn_rec                      OUT NOCOPY qcn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CRTRNS_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_qcn_rec                      qcn_rec_type := p_qcn_rec;
    l_def_qcn_rec                  qcn_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_QUESTION_CRTRNS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_qcn_rec IN  qcn_rec_type,
      x_qcn_rec OUT NOCOPY qcn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_qcn_rec := p_qcn_rec;
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
      p_qcn_rec,                         -- IN
      l_qcn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_QUESTION_CRTRNS(
        id,
        crn_id,
        qty_id,
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
        l_qcn_rec.id,
        l_qcn_rec.crn_id,
        l_qcn_rec.qty_id,
        l_qcn_rec.object_version_number,
        l_qcn_rec.attribute_category,
        l_qcn_rec.attribute1,
        l_qcn_rec.attribute2,
        l_qcn_rec.attribute3,
        l_qcn_rec.attribute4,
        l_qcn_rec.attribute5,
        l_qcn_rec.attribute6,
        l_qcn_rec.attribute7,
        l_qcn_rec.attribute8,
        l_qcn_rec.attribute9,
        l_qcn_rec.attribute10,
        l_qcn_rec.attribute11,
        l_qcn_rec.attribute12,
        l_qcn_rec.attribute13,
        l_qcn_rec.attribute14,
        l_qcn_rec.attribute15,
        l_qcn_rec.created_by,
        l_qcn_rec.creation_date,
        l_qcn_rec.last_updated_by,
        l_qcn_rec.last_update_date,
        l_qcn_rec.last_update_login);
    -- Set OUT values
    x_qcn_rec := l_qcn_rec;
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
  ------------------------------------------
  -- insert_row for:OKL_QUESTION_CRTRNS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_rec                     IN qcnv_rec_type,
    x_qcnv_rec                     OUT NOCOPY qcnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_qcnv_rec                     qcnv_rec_type;
    l_def_qcnv_rec                 qcnv_rec_type;
    l_qcn_rec                      qcn_rec_type;
    lx_qcn_rec                     qcn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qcnv_rec	IN qcnv_rec_type
    ) RETURN qcnv_rec_type IS
      l_qcnv_rec	qcnv_rec_type := p_qcnv_rec;
    BEGIN
      l_qcnv_rec.CREATION_DATE := SYSDATE;
      l_qcnv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_qcnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qcnv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_qcnv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_qcnv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_QUESTION_CRTRNS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_qcnv_rec IN  qcnv_rec_type,
      x_qcnv_rec OUT NOCOPY qcnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_qcnv_rec := p_qcnv_rec;
      x_qcnv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_qcnv_rec := null_out_defaults(p_qcnv_rec);
    -- Set primary key value
    l_qcnv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_qcnv_rec,                        -- IN
      l_def_qcnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_qcnv_rec := fill_who_columns(l_def_qcnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qcnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qcnv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qcnv_rec, l_qcn_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qcn_rec,
      lx_qcn_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qcn_rec, l_def_qcnv_rec);
    -- Set OUT values
    x_qcnv_rec := l_def_qcnv_rec;
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
  -- PL/SQL TBL insert_row for:QCNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_tbl                     IN qcnv_tbl_type,
    x_qcnv_tbl                     OUT NOCOPY qcnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcnv_tbl.COUNT > 0) THEN
      i := p_qcnv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qcnv_rec                     => p_qcnv_tbl(i),
          x_qcnv_rec                     => x_qcnv_tbl(i));
        EXIT WHEN (i = p_qcnv_tbl.LAST);
        i := p_qcnv_tbl.NEXT(i);
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
  --------------------------------------
  -- lock_row for:OKL_QUESTION_CRTRNS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcn_rec                      IN qcn_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_qcn_rec IN qcn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_QUESTION_CRTRNS
     WHERE ID = p_qcn_rec.id
       AND OBJECT_VERSION_NUMBER = p_qcn_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_qcn_rec IN qcn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_QUESTION_CRTRNS
    WHERE ID = p_qcn_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CRTRNS_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_QUESTION_CRTRNS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_QUESTION_CRTRNS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_qcn_rec);
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
      OPEN lchk_csr(p_qcn_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_qcn_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_qcn_rec.object_version_number THEN
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
  ----------------------------------------
  -- lock_row for:OKL_QUESTION_CRTRNS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_rec                     IN qcnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_qcn_rec                      qcn_rec_type;
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
    migrate(p_qcnv_rec, l_qcn_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qcn_rec
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
  -- PL/SQL TBL lock_row for:QCNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_tbl                     IN qcnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcnv_tbl.COUNT > 0) THEN
      i := p_qcnv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qcnv_rec                     => p_qcnv_tbl(i));
        EXIT WHEN (i = p_qcnv_tbl.LAST);
        i := p_qcnv_tbl.NEXT(i);
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
  ----------------------------------------
  -- update_row for:OKL_QUESTION_CRTRNS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcn_rec                      IN qcn_rec_type,
    x_qcn_rec                      OUT NOCOPY qcn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CRTRNS_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_qcn_rec                      qcn_rec_type := p_qcn_rec;
    l_def_qcn_rec                  qcn_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qcn_rec	IN qcn_rec_type,
      x_qcn_rec	OUT NOCOPY qcn_rec_type
    ) RETURN VARCHAR2 IS
      l_qcn_rec                      qcn_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_qcn_rec := p_qcn_rec;
      -- Get current database values
      l_qcn_rec := get_rec(p_qcn_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qcn_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_qcn_rec.id := l_qcn_rec.id;
      END IF;
      IF (x_qcn_rec.crn_id = okl_api.G_MISS_NUM)
      THEN
        x_qcn_rec.crn_id := l_qcn_rec.crn_id;
      END IF;
      IF (x_qcn_rec.qty_id = okl_api.G_MISS_NUM)
      THEN
        x_qcn_rec.qty_id := l_qcn_rec.qty_id;
      END IF;
      IF (x_qcn_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_qcn_rec.object_version_number := l_qcn_rec.object_version_number;
      END IF;
      IF (x_qcn_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute_category := l_qcn_rec.attribute_category;
      END IF;
      IF (x_qcn_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute1 := l_qcn_rec.attribute1;
      END IF;
      IF (x_qcn_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute2 := l_qcn_rec.attribute2;
      END IF;
      IF (x_qcn_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute3 := l_qcn_rec.attribute3;
      END IF;
      IF (x_qcn_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute4 := l_qcn_rec.attribute4;
      END IF;
      IF (x_qcn_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute5 := l_qcn_rec.attribute5;
      END IF;
      IF (x_qcn_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute6 := l_qcn_rec.attribute6;
      END IF;
      IF (x_qcn_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute7 := l_qcn_rec.attribute7;
      END IF;
      IF (x_qcn_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute8 := l_qcn_rec.attribute8;
      END IF;
      IF (x_qcn_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute9 := l_qcn_rec.attribute9;
      END IF;
      IF (x_qcn_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute10 := l_qcn_rec.attribute10;
      END IF;
      IF (x_qcn_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute11 := l_qcn_rec.attribute11;
      END IF;
      IF (x_qcn_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute12 := l_qcn_rec.attribute12;
      END IF;
      IF (x_qcn_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute13 := l_qcn_rec.attribute13;
      END IF;
      IF (x_qcn_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute14 := l_qcn_rec.attribute14;
      END IF;
      IF (x_qcn_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_qcn_rec.attribute15 := l_qcn_rec.attribute15;
      END IF;
      IF (x_qcn_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_qcn_rec.created_by := l_qcn_rec.created_by;
      END IF;
      IF (x_qcn_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_qcn_rec.creation_date := l_qcn_rec.creation_date;
      END IF;
      IF (x_qcn_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_qcn_rec.last_updated_by := l_qcn_rec.last_updated_by;
      END IF;
      IF (x_qcn_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_qcn_rec.last_update_date := l_qcn_rec.last_update_date;
      END IF;
      IF (x_qcn_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_qcn_rec.last_update_login := l_qcn_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_QUESTION_CRTRNS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_qcn_rec IN  qcn_rec_type,
      x_qcn_rec OUT NOCOPY qcn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_qcn_rec := p_qcn_rec;
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
      p_qcn_rec,                         -- IN
      l_qcn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qcn_rec, l_def_qcn_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_QUESTION_CRTRNS
    SET CRN_ID = l_def_qcn_rec.crn_id,
        QTY_ID = l_def_qcn_rec.qty_id,
        OBJECT_VERSION_NUMBER = l_def_qcn_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_qcn_rec.attribute_category,
        ATTRIBUTE1 = l_def_qcn_rec.attribute1,
        ATTRIBUTE2 = l_def_qcn_rec.attribute2,
        ATTRIBUTE3 = l_def_qcn_rec.attribute3,
        ATTRIBUTE4 = l_def_qcn_rec.attribute4,
        ATTRIBUTE5 = l_def_qcn_rec.attribute5,
        ATTRIBUTE6 = l_def_qcn_rec.attribute6,
        ATTRIBUTE7 = l_def_qcn_rec.attribute7,
        ATTRIBUTE8 = l_def_qcn_rec.attribute8,
        ATTRIBUTE9 = l_def_qcn_rec.attribute9,
        ATTRIBUTE10 = l_def_qcn_rec.attribute10,
        ATTRIBUTE11 = l_def_qcn_rec.attribute11,
        ATTRIBUTE12 = l_def_qcn_rec.attribute12,
        ATTRIBUTE13 = l_def_qcn_rec.attribute13,
        ATTRIBUTE14 = l_def_qcn_rec.attribute14,
        ATTRIBUTE15 = l_def_qcn_rec.attribute15,
        CREATED_BY = l_def_qcn_rec.created_by,
        CREATION_DATE = l_def_qcn_rec.creation_date,
        LAST_UPDATED_BY = l_def_qcn_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_qcn_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_qcn_rec.last_update_login
    WHERE ID = l_def_qcn_rec.id;

    x_qcn_rec := l_def_qcn_rec;
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
  ------------------------------------------
  -- update_row for:OKL_QUESTION_CRTRNS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_rec                     IN qcnv_rec_type,
    x_qcnv_rec                     OUT NOCOPY qcnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_qcnv_rec                     qcnv_rec_type := p_qcnv_rec;
    l_def_qcnv_rec                 qcnv_rec_type;
    l_qcn_rec                      qcn_rec_type;
    lx_qcn_rec                     qcn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qcnv_rec	IN qcnv_rec_type
    ) RETURN qcnv_rec_type IS
      l_qcnv_rec	qcnv_rec_type := p_qcnv_rec;
    BEGIN
      l_qcnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qcnv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_qcnv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_qcnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qcnv_rec	IN qcnv_rec_type,
      x_qcnv_rec	OUT NOCOPY qcnv_rec_type
    ) RETURN VARCHAR2 IS
      l_qcnv_rec                     qcnv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_qcnv_rec := p_qcnv_rec;
      -- Get current database values
      l_qcnv_rec := get_rec(p_qcnv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qcnv_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_qcnv_rec.id := l_qcnv_rec.id;
      END IF;
      IF (x_qcnv_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_qcnv_rec.object_version_number := l_qcnv_rec.object_version_number;
      END IF;
      IF (x_qcnv_rec.crn_id = okl_api.G_MISS_NUM)
      THEN
        x_qcnv_rec.crn_id := l_qcnv_rec.crn_id;
      END IF;
      IF (x_qcnv_rec.qty_id = okl_api.G_MISS_NUM)
      THEN
        x_qcnv_rec.qty_id := l_qcnv_rec.qty_id;
      END IF;
      IF (x_qcnv_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute_category := l_qcnv_rec.attribute_category;
      END IF;
      IF (x_qcnv_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute1 := l_qcnv_rec.attribute1;
      END IF;
      IF (x_qcnv_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute2 := l_qcnv_rec.attribute2;
      END IF;
      IF (x_qcnv_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute3 := l_qcnv_rec.attribute3;
      END IF;
      IF (x_qcnv_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute4 := l_qcnv_rec.attribute4;
      END IF;
      IF (x_qcnv_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute5 := l_qcnv_rec.attribute5;
      END IF;
      IF (x_qcnv_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute6 := l_qcnv_rec.attribute6;
      END IF;
      IF (x_qcnv_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute7 := l_qcnv_rec.attribute7;
      END IF;
      IF (x_qcnv_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute8 := l_qcnv_rec.attribute8;
      END IF;
      IF (x_qcnv_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute9 := l_qcnv_rec.attribute9;
      END IF;
      IF (x_qcnv_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute10 := l_qcnv_rec.attribute10;
      END IF;
      IF (x_qcnv_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute11 := l_qcnv_rec.attribute11;
      END IF;
      IF (x_qcnv_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute12 := l_qcnv_rec.attribute12;
      END IF;
      IF (x_qcnv_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute13 := l_qcnv_rec.attribute13;
      END IF;
      IF (x_qcnv_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute14 := l_qcnv_rec.attribute14;
      END IF;
      IF (x_qcnv_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_qcnv_rec.attribute15 := l_qcnv_rec.attribute15;
      END IF;
      IF (x_qcnv_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_qcnv_rec.created_by := l_qcnv_rec.created_by;
      END IF;
      IF (x_qcnv_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_qcnv_rec.creation_date := l_qcnv_rec.creation_date;
      END IF;
      IF (x_qcnv_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_qcnv_rec.last_updated_by := l_qcnv_rec.last_updated_by;
      END IF;
      IF (x_qcnv_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_qcnv_rec.last_update_date := l_qcnv_rec.last_update_date;
      END IF;
      IF (x_qcnv_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_qcnv_rec.last_update_login := l_qcnv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_QUESTION_CRTRNS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_qcnv_rec IN  qcnv_rec_type,
      x_qcnv_rec OUT NOCOPY qcnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_qcnv_rec := p_qcnv_rec;
      x_qcnv_rec.OBJECT_VERSION_NUMBER := NVL(x_qcnv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_qcnv_rec,                        -- IN
      l_qcnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qcnv_rec, l_def_qcnv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_qcnv_rec := fill_who_columns(l_def_qcnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qcnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qcnv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qcnv_rec, l_qcn_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qcn_rec,
      lx_qcn_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qcn_rec, l_def_qcnv_rec);
    x_qcnv_rec := l_def_qcnv_rec;
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
  -- PL/SQL TBL update_row for:QCNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_tbl                     IN qcnv_tbl_type,
    x_qcnv_tbl                     OUT NOCOPY qcnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcnv_tbl.COUNT > 0) THEN
      i := p_qcnv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qcnv_rec                     => p_qcnv_tbl(i),
          x_qcnv_rec                     => x_qcnv_tbl(i));
        EXIT WHEN (i = p_qcnv_tbl.LAST);
        i := p_qcnv_tbl.NEXT(i);
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
  ----------------------------------------
  -- delete_row for:OKL_QUESTION_CRTRNS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcn_rec                      IN qcn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CRTRNS_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_qcn_rec                      qcn_rec_type:= p_qcn_rec;
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
    DELETE FROM OKL_QUESTION_CRTRNS
     WHERE ID = l_qcn_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKL_QUESTION_CRTRNS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_rec                     IN qcnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_qcnv_rec                     qcnv_rec_type := p_qcnv_rec;
    l_qcn_rec                      qcn_rec_type;
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
    migrate(l_qcnv_rec, l_qcn_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qcn_rec
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
  -- PL/SQL TBL delete_row for:QCNV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_tbl                     IN qcnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcnv_tbl.COUNT > 0) THEN
      i := p_qcnv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qcnv_rec                     => p_qcnv_tbl(i));
        EXIT WHEN (i = p_qcnv_tbl.LAST);
        i := p_qcnv_tbl.NEXT(i);
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
END Okl_Qcn_Pvt;

/
