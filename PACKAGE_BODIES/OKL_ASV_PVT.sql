--------------------------------------------------------
--  DDL for Package Body OKL_ASV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ASV_PVT" AS
/* $Header: OKLSASVB.pls 115.3 2002/05/10 08:32:25 pkm ship        $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_asvv_rec IN asvv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_asvv_rec.id = Okl_Api.G_MISS_NUM OR
       p_asvv_rec.id IS NULL
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
  PROCEDURE validate_object_version_number (p_asvv_rec IN asvv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_asvv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_asvv_rec.object_version_number IS NULL
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
  -- PROCEDURE validate_asr_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_asr_id (p_asvv_rec IN asvv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_asr_id_csr IS
    SELECT '1'
	FROM OKL_ANSR_SET_CRTRIA_B
	WHERE id = p_asvv_rec.asr_id;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_asvv_rec.asr_id = Okl_Api.G_MISS_NUM OR
       p_asvv_rec.asr_id IS NULL
    THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'asr_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Validate Foreign Key
 	OPEN l_asr_id_csr;
	FETCH l_asr_id_csr INTO l_dummy_var;
	CLOSE l_asr_id_csr;

	IF (l_dummy_var <> '1') THEN
	 	x_return_status := Okl_Api.G_RET_STS_ERROR;
	    Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
		 				    p_msg_name			=> G_NO_PARENT_RECORD,
							p_token1			=> G_COL_NAME_TOKEN,
							p_token1_value		=> 'ASR_ID_FOR',
							p_token2			=> G_CHILD_TABLE_TOKEN,
							p_token2_value		=> G_VIEW,
							p_token3			=> G_PARENT_TABLE_TOKEN,
							p_token3_value		=> 'OKL_ANSR_SET_CN_VLS_V');

		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END validate_asr_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_asr_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_crn_id (p_asvv_rec IN asvv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_crn_id_csr IS
    SELECT '1'
	FROM OKL_CRITERIA_B
	WHERE id = p_asvv_rec.crn_id;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_asvv_rec.asr_id = Okl_Api.G_MISS_NUM OR
       p_asvv_rec.asr_id IS NULL
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
							p_token3_value		=> 'OKL_ANSR_SET_CN_VLS_V');

		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END validate_crn_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_sequence_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_sequence_number (p_asvv_rec IN asvv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_asvv_rec.sequence_number = Okl_Api.G_MISS_NUM OR
       p_asvv_rec.sequence_number IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'sequence_number');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_sequence_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_asv_type
  ---------------------------------------------------------------------------
  PROCEDURE validate_asv_type (p_asvv_rec IN asvv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_asvv_rec.asv_type = Okl_Api.G_MISS_CHAR OR
       p_asvv_rec.asv_type IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'asv_type');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;

	--Check for valid allowable values
    IF p_asvv_rec.asv_type NOT IN ('CVL','CVM')
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     => G_INVALID_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'asv_type');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;

  END validate_asv_type;

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
  -- FUNCTION get_rec for: OKL_ANSR_SET_CN_VLS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_asv_rec                      IN asv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN asv_rec_type IS
    CURSOR asv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ASR_ID,
            SEQUENCE_NUMBER,
            CRN_ID,
            ASV_TYPE,
            OBJECT_VERSION_NUMBER,
            CVM_FROM,
            CVM_TO,
            FROM_OBJECT_ID1,
            FROM_OBJECT_ID2,
            TO_OBJECT_ID1,
            TO_OBJECT_ID2,
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
      FROM Okl_Ansr_Set_Cn_Vls
     WHERE okl_ansr_set_cn_vls.id = p_id;
    l_asv_pk                       asv_pk_csr%ROWTYPE;
    l_asv_rec                      asv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN asv_pk_csr (p_asv_rec.id);
    FETCH asv_pk_csr INTO
              l_asv_rec.ID,
              l_asv_rec.ASR_ID,
              l_asv_rec.SEQUENCE_NUMBER,
              l_asv_rec.CRN_ID,
              l_asv_rec.ASV_TYPE,
              l_asv_rec.OBJECT_VERSION_NUMBER,
              l_asv_rec.CVM_FROM,
              l_asv_rec.CVM_TO,
              l_asv_rec.FROM_OBJECT_ID1,
              l_asv_rec.FROM_OBJECT_ID2,
              l_asv_rec.TO_OBJECT_ID1,
              l_asv_rec.TO_OBJECT_ID2,
              l_asv_rec.ATTRIBUTE_CATEGORY,
              l_asv_rec.ATTRIBUTE1,
              l_asv_rec.ATTRIBUTE2,
              l_asv_rec.ATTRIBUTE3,
              l_asv_rec.ATTRIBUTE4,
              l_asv_rec.ATTRIBUTE5,
              l_asv_rec.ATTRIBUTE6,
              l_asv_rec.ATTRIBUTE7,
              l_asv_rec.ATTRIBUTE8,
              l_asv_rec.ATTRIBUTE9,
              l_asv_rec.ATTRIBUTE10,
              l_asv_rec.ATTRIBUTE11,
              l_asv_rec.ATTRIBUTE12,
              l_asv_rec.ATTRIBUTE13,
              l_asv_rec.ATTRIBUTE14,
              l_asv_rec.ATTRIBUTE15,
              l_asv_rec.CREATED_BY,
              l_asv_rec.CREATION_DATE,
              l_asv_rec.LAST_UPDATED_BY,
              l_asv_rec.LAST_UPDATE_DATE,
              l_asv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := asv_pk_csr%NOTFOUND;
    CLOSE asv_pk_csr;
    RETURN(l_asv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_asv_rec                      IN asv_rec_type
  ) RETURN asv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_asv_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ANSR_SET_CN_VLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_asvv_rec                     IN asvv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN asvv_rec_type IS
    CURSOR okl_asvv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            ASR_ID,
            CRN_ID,
            FROM_OBJECT_ID1,
            FROM_OBJECT_ID2,
            TO_OBJECT_ID1,
            TO_OBJECT_ID2,
            SEQUENCE_NUMBER,
            CVM_FROM,
            CVM_TO,
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
            ASV_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ansr_Set_Cn_Vls_V
     WHERE okl_ansr_set_cn_vls_v.id = p_id;
    l_okl_asvv_pk                  okl_asvv_pk_csr%ROWTYPE;
    l_asvv_rec                     asvv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_asvv_pk_csr (p_asvv_rec.id);
    FETCH okl_asvv_pk_csr INTO
              l_asvv_rec.ID,
              l_asvv_rec.OBJECT_VERSION_NUMBER,
              l_asvv_rec.ASR_ID,
              l_asvv_rec.CRN_ID,
              l_asvv_rec.FROM_OBJECT_ID1,
              l_asvv_rec.FROM_OBJECT_ID2,
              l_asvv_rec.TO_OBJECT_ID1,
              l_asvv_rec.TO_OBJECT_ID2,
              l_asvv_rec.SEQUENCE_NUMBER,
              l_asvv_rec.CVM_FROM,
              l_asvv_rec.CVM_TO,
              l_asvv_rec.ATTRIBUTE_CATEGORY,
              l_asvv_rec.ATTRIBUTE1,
              l_asvv_rec.ATTRIBUTE2,
              l_asvv_rec.ATTRIBUTE3,
              l_asvv_rec.ATTRIBUTE4,
              l_asvv_rec.ATTRIBUTE5,
              l_asvv_rec.ATTRIBUTE6,
              l_asvv_rec.ATTRIBUTE7,
              l_asvv_rec.ATTRIBUTE8,
              l_asvv_rec.ATTRIBUTE9,
              l_asvv_rec.ATTRIBUTE10,
              l_asvv_rec.ATTRIBUTE11,
              l_asvv_rec.ATTRIBUTE12,
              l_asvv_rec.ATTRIBUTE13,
              l_asvv_rec.ATTRIBUTE14,
              l_asvv_rec.ATTRIBUTE15,
              l_asvv_rec.ASV_TYPE,
              l_asvv_rec.CREATED_BY,
              l_asvv_rec.CREATION_DATE,
              l_asvv_rec.LAST_UPDATED_BY,
              l_asvv_rec.LAST_UPDATE_DATE,
              l_asvv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_asvv_pk_csr%NOTFOUND;
    CLOSE okl_asvv_pk_csr;
    RETURN(l_asvv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_asvv_rec                     IN asvv_rec_type
  ) RETURN asvv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_asvv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_ANSR_SET_CN_VLS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_asvv_rec	IN asvv_rec_type
  ) RETURN asvv_rec_type IS
    l_asvv_rec	asvv_rec_type := p_asvv_rec;
  BEGIN
    IF (l_asvv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_asvv_rec.object_version_number := NULL;
    END IF;
    IF (l_asvv_rec.asr_id = okl_api.G_MISS_NUM) THEN
      l_asvv_rec.asr_id := NULL;
    END IF;
    IF (l_asvv_rec.crn_id = okl_api.G_MISS_NUM) THEN
      l_asvv_rec.crn_id := NULL;
    END IF;
    IF (l_asvv_rec.from_object_id1 = okl_api.G_MISS_NUM) THEN
      l_asvv_rec.from_object_id1 := NULL;
    END IF;
    IF (l_asvv_rec.from_object_id2 = okl_api.G_MISS_NUM) THEN
      l_asvv_rec.from_object_id2 := NULL;
    END IF;
    IF (l_asvv_rec.to_object_id1 = okl_api.G_MISS_NUM) THEN
      l_asvv_rec.to_object_id1 := NULL;
    END IF;
    IF (l_asvv_rec.to_object_id2 = okl_api.G_MISS_NUM) THEN
      l_asvv_rec.to_object_id2 := NULL;
    END IF;
    IF (l_asvv_rec.sequence_number = okl_api.G_MISS_NUM) THEN
      l_asvv_rec.sequence_number := NULL;
    END IF;
    IF (l_asvv_rec.cvm_from = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.cvm_from := NULL;
    END IF;
    IF (l_asvv_rec.cvm_to = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.cvm_to := NULL;
    END IF;
    IF (l_asvv_rec.attribute_category = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute_category := NULL;
    END IF;
    IF (l_asvv_rec.attribute1 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute1 := NULL;
    END IF;
    IF (l_asvv_rec.attribute2 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute2 := NULL;
    END IF;
    IF (l_asvv_rec.attribute3 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute3 := NULL;
    END IF;
    IF (l_asvv_rec.attribute4 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute4 := NULL;
    END IF;
    IF (l_asvv_rec.attribute5 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute5 := NULL;
    END IF;
    IF (l_asvv_rec.attribute6 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute6 := NULL;
    END IF;
    IF (l_asvv_rec.attribute7 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute7 := NULL;
    END IF;
    IF (l_asvv_rec.attribute8 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute8 := NULL;
    END IF;
    IF (l_asvv_rec.attribute9 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute9 := NULL;
    END IF;
    IF (l_asvv_rec.attribute10 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute10 := NULL;
    END IF;
    IF (l_asvv_rec.attribute11 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute11 := NULL;
    END IF;
    IF (l_asvv_rec.attribute12 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute12 := NULL;
    END IF;
    IF (l_asvv_rec.attribute13 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute13 := NULL;
    END IF;
    IF (l_asvv_rec.attribute14 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute14 := NULL;
    END IF;
    IF (l_asvv_rec.attribute15 = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.attribute15 := NULL;
    END IF;
    IF (l_asvv_rec.asv_type = okl_api.G_MISS_CHAR) THEN
      l_asvv_rec.asv_type := NULL;
    END IF;
    IF (l_asvv_rec.created_by = okl_api.G_MISS_NUM) THEN
      l_asvv_rec.created_by := NULL;
    END IF;
    IF (l_asvv_rec.creation_date = okl_api.G_MISS_DATE) THEN
      l_asvv_rec.creation_date := NULL;
    END IF;
    IF (l_asvv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_asvv_rec.last_updated_by := NULL;
    END IF;
    IF (l_asvv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_asvv_rec.last_update_date := NULL;
    END IF;
    IF (l_asvv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_asvv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_asvv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_ANSR_SET_CN_VLS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_asvv_rec IN  asvv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- TAPI postgen 05/23/2001
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- End TAPI postgen 05/23/2001
  BEGIN
	-- TAPI postgen 05/23/2001
    validate_id(p_asvv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_object_version_number(p_asvv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_asr_id(p_asvv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_crn_id(p_asvv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_sequence_number(p_asvv_rec, x_return_status);
  	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_asv_type(p_asvv_rec, x_return_status);
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
  -----------------------------------------------
  -- Validate_Record for:OKL_ANSR_SET_CN_VLS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_asvv_rec IN asvv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN asvv_rec_type,
    p_to	OUT NOCOPY asv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.asr_id := p_from.asr_id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.crn_id := p_from.crn_id;
    p_to.asv_type := p_from.asv_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.cvm_from := p_from.cvm_from;
    p_to.cvm_to := p_from.cvm_to;
    p_to.from_object_id1 := p_from.from_object_id1;
    p_to.from_object_id2 := p_from.from_object_id2;
    p_to.to_object_id1 := p_from.to_object_id1;
    p_to.to_object_id2 := p_from.to_object_id2;
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
    p_from	IN asv_rec_type,
    p_to	OUT NOCOPY asvv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.asr_id := p_from.asr_id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.crn_id := p_from.crn_id;
    p_to.asv_type := p_from.asv_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.cvm_from := p_from.cvm_from;
    p_to.cvm_to := p_from.cvm_to;
    p_to.from_object_id1 := p_from.from_object_id1;
    p_to.from_object_id2 := p_from.from_object_id2;
    p_to.to_object_id1 := p_from.to_object_id1;
    p_to.to_object_id2 := p_from.to_object_id2;
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
  -- validate_row for:OKL_ANSR_SET_CN_VLS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_rec                     IN asvv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_asvv_rec                     asvv_rec_type := p_asvv_rec;
    l_asv_rec                      asv_rec_type;
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
    l_return_status := Validate_Attributes(l_asvv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_asvv_rec);
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
  -- PL/SQL TBL validate_row for:ASVV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_tbl                     IN asvv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_asvv_tbl.COUNT > 0) THEN
      i := p_asvv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_asvv_rec                     => p_asvv_tbl(i));
        EXIT WHEN (i = p_asvv_tbl.LAST);
        i := p_asvv_tbl.NEXT(i);
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
  -- insert_row for:OKL_ANSR_SET_CN_VLS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asv_rec                      IN asv_rec_type,
    x_asv_rec                      OUT NOCOPY asv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VLS_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_asv_rec                      asv_rec_type := p_asv_rec;
    l_def_asv_rec                  asv_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_ANSR_SET_CN_VLS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_asv_rec IN  asv_rec_type,
      x_asv_rec OUT NOCOPY asv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_asv_rec := p_asv_rec;
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
      p_asv_rec,                         -- IN
      l_asv_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_ANSR_SET_CN_VLS(
        id,
        asr_id,
        sequence_number,
        crn_id,
        asv_type,
        object_version_number,
        cvm_from,
        cvm_to,
        from_object_id1,
        from_object_id2,
        to_object_id1,
        to_object_id2,
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
        l_asv_rec.id,
        l_asv_rec.asr_id,
        l_asv_rec.sequence_number,
        l_asv_rec.crn_id,
        l_asv_rec.asv_type,
        l_asv_rec.object_version_number,
        l_asv_rec.cvm_from,
        l_asv_rec.cvm_to,
        l_asv_rec.from_object_id1,
        l_asv_rec.from_object_id2,
        l_asv_rec.to_object_id1,
        l_asv_rec.to_object_id2,
        l_asv_rec.attribute_category,
        l_asv_rec.attribute1,
        l_asv_rec.attribute2,
        l_asv_rec.attribute3,
        l_asv_rec.attribute4,
        l_asv_rec.attribute5,
        l_asv_rec.attribute6,
        l_asv_rec.attribute7,
        l_asv_rec.attribute8,
        l_asv_rec.attribute9,
        l_asv_rec.attribute10,
        l_asv_rec.attribute11,
        l_asv_rec.attribute12,
        l_asv_rec.attribute13,
        l_asv_rec.attribute14,
        l_asv_rec.attribute15,
        l_asv_rec.created_by,
        l_asv_rec.creation_date,
        l_asv_rec.last_updated_by,
        l_asv_rec.last_update_date,
        l_asv_rec.last_update_login);
    -- Set OUT values
    x_asv_rec := l_asv_rec;
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
  -- insert_row for:OKL_ANSR_SET_CN_VLS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_rec                     IN asvv_rec_type,
    x_asvv_rec                     OUT NOCOPY asvv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_asvv_rec                     asvv_rec_type;
    l_def_asvv_rec                 asvv_rec_type;
    l_asv_rec                      asv_rec_type;
    lx_asv_rec                     asv_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_asvv_rec	IN asvv_rec_type
    ) RETURN asvv_rec_type IS
      l_asvv_rec	asvv_rec_type := p_asvv_rec;
    BEGIN
      l_asvv_rec.CREATION_DATE := SYSDATE;
      l_asvv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_asvv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_asvv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_asvv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_asvv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_ANSR_SET_CN_VLS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_asvv_rec IN  asvv_rec_type,
      x_asvv_rec OUT NOCOPY asvv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_asvv_rec := p_asvv_rec;
      x_asvv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_asvv_rec := null_out_defaults(p_asvv_rec);
    -- Set primary key value
    l_asvv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_asvv_rec,                        -- IN
      l_def_asvv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_asvv_rec := fill_who_columns(l_def_asvv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_asvv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_asvv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_asvv_rec, l_asv_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_asv_rec,
      lx_asv_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_asv_rec, l_def_asvv_rec);
    -- Set OUT values
    x_asvv_rec := l_def_asvv_rec;
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
  -- PL/SQL TBL insert_row for:ASVV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_tbl                     IN asvv_tbl_type,
    x_asvv_tbl                     OUT NOCOPY asvv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_asvv_tbl.COUNT > 0) THEN
      i := p_asvv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_asvv_rec                     => p_asvv_tbl(i),
          x_asvv_rec                     => x_asvv_tbl(i));
        EXIT WHEN (i = p_asvv_tbl.LAST);
        i := p_asvv_tbl.NEXT(i);
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
  -- lock_row for:OKL_ANSR_SET_CN_VLS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asv_rec                      IN asv_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_asv_rec IN asv_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ANSR_SET_CN_VLS
     WHERE ID = p_asv_rec.id
       AND OBJECT_VERSION_NUMBER = p_asv_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_asv_rec IN asv_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ANSR_SET_CN_VLS
    WHERE ID = p_asv_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VLS_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_ANSR_SET_CN_VLS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_ANSR_SET_CN_VLS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_asv_rec);
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
      OPEN lchk_csr(p_asv_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_asv_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_asv_rec.object_version_number THEN
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
  -- lock_row for:OKL_ANSR_SET_CN_VLS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_rec                     IN asvv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_asv_rec                      asv_rec_type;
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
    migrate(p_asvv_rec, l_asv_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_asv_rec
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
  -- PL/SQL TBL lock_row for:ASVV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_tbl                     IN asvv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_asvv_tbl.COUNT > 0) THEN
      i := p_asvv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_asvv_rec                     => p_asvv_tbl(i));
        EXIT WHEN (i = p_asvv_tbl.LAST);
        i := p_asvv_tbl.NEXT(i);
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
  -- update_row for:OKL_ANSR_SET_CN_VLS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asv_rec                      IN asv_rec_type,
    x_asv_rec                      OUT NOCOPY asv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VLS_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_asv_rec                      asv_rec_type := p_asv_rec;
    l_def_asv_rec                  asv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_asv_rec	IN asv_rec_type,
      x_asv_rec	OUT NOCOPY asv_rec_type
    ) RETURN VARCHAR2 IS
      l_asv_rec                      asv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_asv_rec := p_asv_rec;
      -- Get current database values
      l_asv_rec := get_rec(p_asv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_asv_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_asv_rec.id := l_asv_rec.id;
      END IF;
      IF (x_asv_rec.asr_id = okl_api.G_MISS_NUM)
      THEN
        x_asv_rec.asr_id := l_asv_rec.asr_id;
      END IF;
      IF (x_asv_rec.sequence_number = okl_api.G_MISS_NUM)
      THEN
        x_asv_rec.sequence_number := l_asv_rec.sequence_number;
      END IF;
      IF (x_asv_rec.crn_id = okl_api.G_MISS_NUM)
      THEN
        x_asv_rec.crn_id := l_asv_rec.crn_id;
      END IF;
      IF (x_asv_rec.asv_type = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.asv_type := l_asv_rec.asv_type;
      END IF;
      IF (x_asv_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_asv_rec.object_version_number := l_asv_rec.object_version_number;
      END IF;
      IF (x_asv_rec.cvm_from = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.cvm_from := l_asv_rec.cvm_from;
      END IF;
      IF (x_asv_rec.cvm_to = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.cvm_to := l_asv_rec.cvm_to;
      END IF;
      IF (x_asv_rec.from_object_id1 = okl_api.G_MISS_NUM)
      THEN
        x_asv_rec.from_object_id1 := l_asv_rec.from_object_id1;
      END IF;
      IF (x_asv_rec.from_object_id2 = okl_api.G_MISS_NUM)
      THEN
        x_asv_rec.from_object_id2 := l_asv_rec.from_object_id2;
      END IF;
      IF (x_asv_rec.to_object_id1 = okl_api.G_MISS_NUM)
      THEN
        x_asv_rec.to_object_id1 := l_asv_rec.to_object_id1;
      END IF;
      IF (x_asv_rec.to_object_id2 = okl_api.G_MISS_NUM)
      THEN
        x_asv_rec.to_object_id2 := l_asv_rec.to_object_id2;
      END IF;
      IF (x_asv_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute_category := l_asv_rec.attribute_category;
      END IF;
      IF (x_asv_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute1 := l_asv_rec.attribute1;
      END IF;
      IF (x_asv_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute2 := l_asv_rec.attribute2;
      END IF;
      IF (x_asv_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute3 := l_asv_rec.attribute3;
      END IF;
      IF (x_asv_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute4 := l_asv_rec.attribute4;
      END IF;
      IF (x_asv_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute5 := l_asv_rec.attribute5;
      END IF;
      IF (x_asv_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute6 := l_asv_rec.attribute6;
      END IF;
      IF (x_asv_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute7 := l_asv_rec.attribute7;
      END IF;
      IF (x_asv_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute8 := l_asv_rec.attribute8;
      END IF;
      IF (x_asv_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute9 := l_asv_rec.attribute9;
      END IF;
      IF (x_asv_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute10 := l_asv_rec.attribute10;
      END IF;
      IF (x_asv_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute11 := l_asv_rec.attribute11;
      END IF;
      IF (x_asv_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute12 := l_asv_rec.attribute12;
      END IF;
      IF (x_asv_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute13 := l_asv_rec.attribute13;
      END IF;
      IF (x_asv_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute14 := l_asv_rec.attribute14;
      END IF;
      IF (x_asv_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_asv_rec.attribute15 := l_asv_rec.attribute15;
      END IF;
      IF (x_asv_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_asv_rec.created_by := l_asv_rec.created_by;
      END IF;
      IF (x_asv_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_asv_rec.creation_date := l_asv_rec.creation_date;
      END IF;
      IF (x_asv_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_asv_rec.last_updated_by := l_asv_rec.last_updated_by;
      END IF;
      IF (x_asv_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_asv_rec.last_update_date := l_asv_rec.last_update_date;
      END IF;
      IF (x_asv_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_asv_rec.last_update_login := l_asv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_ANSR_SET_CN_VLS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_asv_rec IN  asv_rec_type,
      x_asv_rec OUT NOCOPY asv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_asv_rec := p_asv_rec;
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
      p_asv_rec,                         -- IN
      l_asv_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_asv_rec, l_def_asv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_ANSR_SET_CN_VLS
    SET ASR_ID = l_def_asv_rec.asr_id,
        SEQUENCE_NUMBER = l_def_asv_rec.sequence_number,
        CRN_ID = l_def_asv_rec.crn_id,
        ASV_TYPE = l_def_asv_rec.asv_type,
        OBJECT_VERSION_NUMBER = l_def_asv_rec.object_version_number,
        CVM_FROM = l_def_asv_rec.cvm_from,
        CVM_TO = l_def_asv_rec.cvm_to,
        FROM_OBJECT_ID1 = l_def_asv_rec.from_object_id1,
        FROM_OBJECT_ID2 = l_def_asv_rec.from_object_id2,
        TO_OBJECT_ID1 = l_def_asv_rec.to_object_id1,
        TO_OBJECT_ID2 = l_def_asv_rec.to_object_id2,
        ATTRIBUTE_CATEGORY = l_def_asv_rec.attribute_category,
        ATTRIBUTE1 = l_def_asv_rec.attribute1,
        ATTRIBUTE2 = l_def_asv_rec.attribute2,
        ATTRIBUTE3 = l_def_asv_rec.attribute3,
        ATTRIBUTE4 = l_def_asv_rec.attribute4,
        ATTRIBUTE5 = l_def_asv_rec.attribute5,
        ATTRIBUTE6 = l_def_asv_rec.attribute6,
        ATTRIBUTE7 = l_def_asv_rec.attribute7,
        ATTRIBUTE8 = l_def_asv_rec.attribute8,
        ATTRIBUTE9 = l_def_asv_rec.attribute9,
        ATTRIBUTE10 = l_def_asv_rec.attribute10,
        ATTRIBUTE11 = l_def_asv_rec.attribute11,
        ATTRIBUTE12 = l_def_asv_rec.attribute12,
        ATTRIBUTE13 = l_def_asv_rec.attribute13,
        ATTRIBUTE14 = l_def_asv_rec.attribute14,
        ATTRIBUTE15 = l_def_asv_rec.attribute15,
        CREATED_BY = l_def_asv_rec.created_by,
        CREATION_DATE = l_def_asv_rec.creation_date,
        LAST_UPDATED_BY = l_def_asv_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_asv_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_asv_rec.last_update_login
    WHERE ID = l_def_asv_rec.id;

    x_asv_rec := l_def_asv_rec;
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
  -- update_row for:OKL_ANSR_SET_CN_VLS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_rec                     IN asvv_rec_type,
    x_asvv_rec                     OUT NOCOPY asvv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_asvv_rec                     asvv_rec_type := p_asvv_rec;
    l_def_asvv_rec                 asvv_rec_type;
    l_asv_rec                      asv_rec_type;
    lx_asv_rec                     asv_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_asvv_rec	IN asvv_rec_type
    ) RETURN asvv_rec_type IS
      l_asvv_rec	asvv_rec_type := p_asvv_rec;
    BEGIN
      l_asvv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_asvv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_asvv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_asvv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_asvv_rec	IN asvv_rec_type,
      x_asvv_rec	OUT NOCOPY asvv_rec_type
    ) RETURN VARCHAR2 IS
      l_asvv_rec                     asvv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_asvv_rec := p_asvv_rec;
      -- Get current database values
      l_asvv_rec := get_rec(p_asvv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_asvv_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_asvv_rec.id := l_asvv_rec.id;
      END IF;
      IF (x_asvv_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_asvv_rec.object_version_number := l_asvv_rec.object_version_number;
      END IF;
      IF (x_asvv_rec.asr_id = okl_api.G_MISS_NUM)
      THEN
        x_asvv_rec.asr_id := l_asvv_rec.asr_id;
      END IF;
      IF (x_asvv_rec.crn_id = okl_api.G_MISS_NUM)
      THEN
        x_asvv_rec.crn_id := l_asvv_rec.crn_id;
      END IF;
      IF (x_asvv_rec.from_object_id1 = okl_api.G_MISS_NUM)
      THEN
        x_asvv_rec.from_object_id1 := l_asvv_rec.from_object_id1;
      END IF;
      IF (x_asvv_rec.from_object_id2 = okl_api.G_MISS_NUM)
      THEN
        x_asvv_rec.from_object_id2 := l_asvv_rec.from_object_id2;
      END IF;
      IF (x_asvv_rec.to_object_id1 = okl_api.G_MISS_NUM)
      THEN
        x_asvv_rec.to_object_id1 := l_asvv_rec.to_object_id1;
      END IF;
      IF (x_asvv_rec.to_object_id2 = okl_api.G_MISS_NUM)
      THEN
        x_asvv_rec.to_object_id2 := l_asvv_rec.to_object_id2;
      END IF;
      IF (x_asvv_rec.sequence_number = okl_api.G_MISS_NUM)
      THEN
        x_asvv_rec.sequence_number := l_asvv_rec.sequence_number;
      END IF;
      IF (x_asvv_rec.cvm_from = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.cvm_from := l_asvv_rec.cvm_from;
      END IF;
      IF (x_asvv_rec.cvm_to = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.cvm_to := l_asvv_rec.cvm_to;
      END IF;
      IF (x_asvv_rec.attribute_category = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute_category := l_asvv_rec.attribute_category;
      END IF;
      IF (x_asvv_rec.attribute1 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute1 := l_asvv_rec.attribute1;
      END IF;
      IF (x_asvv_rec.attribute2 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute2 := l_asvv_rec.attribute2;
      END IF;
      IF (x_asvv_rec.attribute3 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute3 := l_asvv_rec.attribute3;
      END IF;
      IF (x_asvv_rec.attribute4 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute4 := l_asvv_rec.attribute4;
      END IF;
      IF (x_asvv_rec.attribute5 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute5 := l_asvv_rec.attribute5;
      END IF;
      IF (x_asvv_rec.attribute6 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute6 := l_asvv_rec.attribute6;
      END IF;
      IF (x_asvv_rec.attribute7 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute7 := l_asvv_rec.attribute7;
      END IF;
      IF (x_asvv_rec.attribute8 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute8 := l_asvv_rec.attribute8;
      END IF;
      IF (x_asvv_rec.attribute9 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute9 := l_asvv_rec.attribute9;
      END IF;
      IF (x_asvv_rec.attribute10 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute10 := l_asvv_rec.attribute10;
      END IF;
      IF (x_asvv_rec.attribute11 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute11 := l_asvv_rec.attribute11;
      END IF;
      IF (x_asvv_rec.attribute12 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute12 := l_asvv_rec.attribute12;
      END IF;
      IF (x_asvv_rec.attribute13 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute13 := l_asvv_rec.attribute13;
      END IF;
      IF (x_asvv_rec.attribute14 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute14 := l_asvv_rec.attribute14;
      END IF;
      IF (x_asvv_rec.attribute15 = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.attribute15 := l_asvv_rec.attribute15;
      END IF;
      IF (x_asvv_rec.asv_type = okl_api.G_MISS_CHAR)
      THEN
        x_asvv_rec.asv_type := l_asvv_rec.asv_type;
      END IF;
      IF (x_asvv_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_asvv_rec.created_by := l_asvv_rec.created_by;
      END IF;
      IF (x_asvv_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_asvv_rec.creation_date := l_asvv_rec.creation_date;
      END IF;
      IF (x_asvv_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_asvv_rec.last_updated_by := l_asvv_rec.last_updated_by;
      END IF;
      IF (x_asvv_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_asvv_rec.last_update_date := l_asvv_rec.last_update_date;
      END IF;
      IF (x_asvv_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_asvv_rec.last_update_login := l_asvv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_ANSR_SET_CN_VLS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_asvv_rec IN  asvv_rec_type,
      x_asvv_rec OUT NOCOPY asvv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_asvv_rec := p_asvv_rec;
      x_asvv_rec.OBJECT_VERSION_NUMBER := NVL(x_asvv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_asvv_rec,                        -- IN
      l_asvv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_asvv_rec, l_def_asvv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_asvv_rec := fill_who_columns(l_def_asvv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_asvv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_asvv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_asvv_rec, l_asv_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_asv_rec,
      lx_asv_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_asv_rec, l_def_asvv_rec);
    x_asvv_rec := l_def_asvv_rec;
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
  -- PL/SQL TBL update_row for:ASVV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_tbl                     IN asvv_tbl_type,
    x_asvv_tbl                     OUT NOCOPY asvv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_asvv_tbl.COUNT > 0) THEN
      i := p_asvv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_asvv_rec                     => p_asvv_tbl(i),
          x_asvv_rec                     => x_asvv_tbl(i));
        EXIT WHEN (i = p_asvv_tbl.LAST);
        i := p_asvv_tbl.NEXT(i);
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
  -- delete_row for:OKL_ANSR_SET_CN_VLS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asv_rec                      IN asv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VLS_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_asv_rec                      asv_rec_type:= p_asv_rec;
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
    DELETE FROM OKL_ANSR_SET_CN_VLS
     WHERE ID = l_asv_rec.id;

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
  -- delete_row for:OKL_ANSR_SET_CN_VLS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_rec                     IN asvv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_asvv_rec                     asvv_rec_type := p_asvv_rec;
    l_asv_rec                      asv_rec_type;
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
    migrate(l_asvv_rec, l_asv_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_asv_rec
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
  -- PL/SQL TBL delete_row for:ASVV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_tbl                     IN asvv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_asvv_tbl.COUNT > 0) THEN
      i := p_asvv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_asvv_rec                     => p_asvv_tbl(i));
        EXIT WHEN (i = p_asvv_tbl.LAST);
        i := p_asvv_tbl.NEXT(i);
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
END Okl_Asv_Pvt;

/
