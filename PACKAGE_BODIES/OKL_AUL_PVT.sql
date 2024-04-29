--------------------------------------------------------
--  DDL for Package Body OKL_AUL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AUL_PVT" AS
/* $Header: OKLSAULB.pls 120.2 2007/02/27 07:07:47 dpsingh ship $ */
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
  -- FUNCTION get_rec for: OKL_ACC_GEN_RUL_LNS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aul_rec                      IN aul_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aul_rec_type IS
    CURSOR aul_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SEGMENT,
            SEGMENT_NUMBER,
            AGR_ID,
            SOURCE,
            OBJECT_VERSION_NUMBER,
            CONSTANTS,
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
      FROM Okl_Acc_Gen_Rul_Lns
     WHERE okl_acc_gen_rul_lns.id = p_id;
    l_aul_pk                       aul_pk_csr%ROWTYPE;
    l_aul_rec                      aul_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN aul_pk_csr (p_aul_rec.id);
    FETCH aul_pk_csr INTO
              l_aul_rec.ID,
              l_aul_rec.SEGMENT,
              l_aul_rec.SEGMENT_NUMBER,
              l_aul_rec.AGR_ID,
              l_aul_rec.SOURCE,
              l_aul_rec.OBJECT_VERSION_NUMBER,
              l_aul_rec.CONSTANTS,
              l_aul_rec.ATTRIBUTE_CATEGORY,
              l_aul_rec.ATTRIBUTE1,
              l_aul_rec.ATTRIBUTE2,
              l_aul_rec.ATTRIBUTE3,
              l_aul_rec.ATTRIBUTE4,
              l_aul_rec.ATTRIBUTE5,
              l_aul_rec.ATTRIBUTE6,
              l_aul_rec.ATTRIBUTE7,
              l_aul_rec.ATTRIBUTE8,
              l_aul_rec.ATTRIBUTE9,
              l_aul_rec.ATTRIBUTE10,
              l_aul_rec.ATTRIBUTE11,
              l_aul_rec.ATTRIBUTE12,
              l_aul_rec.ATTRIBUTE13,
              l_aul_rec.ATTRIBUTE14,
              l_aul_rec.ATTRIBUTE15,
              l_aul_rec.CREATED_BY,
              l_aul_rec.CREATION_DATE,
              l_aul_rec.LAST_UPDATED_BY,
              l_aul_rec.LAST_UPDATE_DATE,
              l_aul_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := aul_pk_csr%NOTFOUND;
    CLOSE aul_pk_csr;
    RETURN(l_aul_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aul_rec                      IN aul_rec_type
  ) RETURN aul_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aul_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ACC_GEN_RUL_LNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aulv_rec                     IN aulv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aulv_rec_type IS
    CURSOR okl_aulv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SEGMENT,
            SEGMENT_NUMBER,
            AGR_ID,
            SOURCE,
            OBJECT_VERSION_NUMBER,
            CONSTANTS,
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
      FROM Okl_Acc_Gen_Rul_Lns_V
     WHERE okl_acc_gen_rul_lns_v.id = p_id;
    l_okl_aulv_pk                  okl_aulv_pk_csr%ROWTYPE;
    l_aulv_rec                     aulv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_aulv_pk_csr (p_aulv_rec.id);
    FETCH okl_aulv_pk_csr INTO
              l_aulv_rec.ID,
              l_aulv_rec.SEGMENT,
              l_aulv_rec.SEGMENT_NUMBER,
              l_aulv_rec.AGR_ID,
              l_aulv_rec.SOURCE,
              l_aulv_rec.OBJECT_VERSION_NUMBER,
              l_aulv_rec.CONSTANTS,
              l_aulv_rec.ATTRIBUTE_CATEGORY,
              l_aulv_rec.ATTRIBUTE1,
              l_aulv_rec.ATTRIBUTE2,
              l_aulv_rec.ATTRIBUTE3,
              l_aulv_rec.ATTRIBUTE4,
              l_aulv_rec.ATTRIBUTE5,
              l_aulv_rec.ATTRIBUTE6,
              l_aulv_rec.ATTRIBUTE7,
              l_aulv_rec.ATTRIBUTE8,
              l_aulv_rec.ATTRIBUTE9,
              l_aulv_rec.ATTRIBUTE10,
              l_aulv_rec.ATTRIBUTE11,
              l_aulv_rec.ATTRIBUTE12,
              l_aulv_rec.ATTRIBUTE13,
              l_aulv_rec.ATTRIBUTE14,
              l_aulv_rec.ATTRIBUTE15,
              l_aulv_rec.CREATED_BY,
              l_aulv_rec.CREATION_DATE,
              l_aulv_rec.LAST_UPDATED_BY,
              l_aulv_rec.LAST_UPDATE_DATE,
              l_aulv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_aulv_pk_csr%NOTFOUND;
    CLOSE okl_aulv_pk_csr;
    RETURN(l_aulv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aulv_rec                     IN aulv_rec_type
  ) RETURN aulv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aulv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_ACC_GEN_RUL_LNS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_aulv_rec	IN aulv_rec_type
  ) RETURN aulv_rec_type IS
    l_aulv_rec	aulv_rec_type := p_aulv_rec;
  BEGIN
    IF (l_aulv_rec.object_version_number = okl_API.G_MISS_NUM) THEN
      l_aulv_rec.object_version_number := NULL;
    END IF;
    IF (l_aulv_rec.source = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.source := NULL;
    END IF;
    IF (l_aulv_rec.SEGMENT = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.SEGMENT := NULL;
    END IF;
    IF (l_aulv_rec.segment_number = okl_API.G_MISS_NUM) THEN
      l_aulv_rec.segment_number := NULL;
    END IF;
    IF (l_aulv_rec.constants = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.constants := NULL;
    END IF;
    IF (l_aulv_rec.attribute_category = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute_category := NULL;
    END IF;
    IF (l_aulv_rec.attribute1 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute1 := NULL;
    END IF;
    IF (l_aulv_rec.attribute2 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute2 := NULL;
    END IF;
    IF (l_aulv_rec.attribute3 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute3 := NULL;
    END IF;
    IF (l_aulv_rec.attribute4 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute4 := NULL;
    END IF;
    IF (l_aulv_rec.attribute5 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute5 := NULL;
    END IF;
    IF (l_aulv_rec.attribute6 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute6 := NULL;
    END IF;
    IF (l_aulv_rec.attribute7 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute7 := NULL;
    END IF;
    IF (l_aulv_rec.attribute8 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute8 := NULL;
    END IF;
    IF (l_aulv_rec.attribute9 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute9 := NULL;
    END IF;
    IF (l_aulv_rec.attribute10 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute10 := NULL;
    END IF;
    IF (l_aulv_rec.attribute11 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute11 := NULL;
    END IF;
    IF (l_aulv_rec.attribute12 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute12 := NULL;
    END IF;
    IF (l_aulv_rec.attribute13 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute13 := NULL;
    END IF;
    IF (l_aulv_rec.attribute14 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute14 := NULL;
    END IF;
    IF (l_aulv_rec.attribute15 = okl_API.G_MISS_CHAR) THEN
      l_aulv_rec.attribute15 := NULL;
    END IF;
    IF (l_aulv_rec.agr_id = okl_API.G_MISS_NUM) THEN
      l_aulv_rec.agr_id := NULL;
    END IF;
    IF (l_aulv_rec.created_by = okl_API.G_MISS_NUM) THEN
      l_aulv_rec.created_by := NULL;
    END IF;
    IF (l_aulv_rec.creation_date = okl_API.G_MISS_DATE) THEN
      l_aulv_rec.creation_date := NULL;
    END IF;
    IF (l_aulv_rec.last_updated_by = okl_API.G_MISS_NUM) THEN
      l_aulv_rec.last_updated_by := NULL;
    END IF;
    IF (l_aulv_rec.last_update_date = okl_API.G_MISS_DATE) THEN
      l_aulv_rec.last_update_date := NULL;
    END IF;
    IF (l_aulv_rec.last_update_login = okl_API.G_MISS_NUM) THEN
      l_aulv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_aulv_rec);
  END null_out_defaults;

/*****************************************************
 05-10-01 : spalod : start - commented out nocopy tapi code

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_ACC_GEN_RUL_LNS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_aulv_rec IN  aulv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_aulv_rec.id = okl_API.G_MISS_NUM OR
       p_aulv_rec.id IS NULL
    THEN
      okl_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := okl_API.G_RET_STS_ERROR;
    ELSIF p_aulv_rec.object_version_number = okl_API.G_MISS_NUM OR
          p_aulv_rec.object_version_number IS NULL
    THEN
      okl_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := okl_API.G_RET_STS_ERROR;
    ELSIF p_aulv_rec.source = okl_API.G_MISS_CHAR OR
          p_aulv_rec.source IS NULL
    THEN
      okl_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'source');
      l_return_status := okl_API.G_RET_STS_ERROR;
    ELSIF p_aulv_rec.segment = okl_API.G_MISS_CHAR OR
          p_aulv_rec.segment IS NULL
    THEN
      okl_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'segment');
      l_return_status := okl_API.G_RET_STS_ERROR;
    ELSIF p_aulv_rec.segment_number = okl_API.G_MISS_NUM OR
          p_aulv_rec.segment_number IS NULL
    THEN
      okl_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'segment_number');
      l_return_status := okl_API.G_RET_STS_ERROR;
    ELSIF p_aulv_rec.agr_id = okl_API.G_MISS_NUM OR
          p_aulv_rec.agr_id IS NULL
    THEN
      okl_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'agr_id');
      l_return_status := okl_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

 05-10-01 : spalod : end - commented out nocopy tapi code
****************************************************/

-- 05-10-01 : spalod : start - procedures for validateing attributes

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
				,p_aulv_rec      IN   aulv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := okl_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_aulv_rec.id IS NULL) OR
       (p_aulv_rec.id = okl_Api.G_MISS_NUM) THEN
       okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'id');
       x_return_status    := okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(x_return_status OUT NOCOPY  VARCHAR2
					  ,p_aulv_rec      IN   aulv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := okl_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_aulv_rec.object_version_number IS NULL) OR
       (p_aulv_rec.object_version_number = okl_Api.G_MISS_NUM) THEN
       okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'object_version_number');
       x_return_status    := okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Segment
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Segment
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Segment(x_return_status OUT NOCOPY  VARCHAR2
				    ,p_aulv_rec      IN   aulv_rec_type )
  IS

  l_return_status VARCHAR2(1)  := okl_Api.G_RET_STS_SUCCESS;
  l_fetch_rec VARCHAR2(1);


  BEGIN

    x_return_status := okl_Api.G_RET_STS_SUCCESS;

    IF (p_aulv_rec.SEGMENT IS NULL) OR
       (p_aulv_rec.SEGMENT = okl_Api.G_MISS_CHAR) THEN
       okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'SEGMENT');
       x_return_status    := okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Segment;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Segment_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Segment_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Segment_Number(x_return_status OUT NOCOPY  VARCHAR2
				    ,p_aulv_rec      IN   aulv_rec_type )
  IS

  l_return_status VARCHAR2(1)  := okl_Api.G_RET_STS_SUCCESS;
  l_fetch_rec VARCHAR2(1);


  BEGIN

    x_return_status := okl_Api.G_RET_STS_SUCCESS;

    IF (p_aulv_rec.SEGMENT_NUMBER IS NULL) OR
       (p_aulv_rec.SEGMENT_NUMBER = okl_Api.G_MISS_NUM) THEN
       okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'SEGMENT_NUMBER');
       x_return_status    := okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Segment_Number;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_agr_id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_agr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_agr_id(x_return_status OUT NOCOPY  VARCHAR2
				    ,p_aulv_rec      IN   aulv_rec_type )
  IS

  CURSOR agr_csr(p_agr_id IN NUMBER)
  IS
  SELECT '1'
  FROM okl_acc_gen_rules_v
  WHERE id = p_agr_id;

  l_return_status VARCHAR2(1)  := okl_Api.G_RET_STS_SUCCESS;
  l_fetch_rec VARCHAR2(1);

  BEGIN
    -- initialize return status
    x_return_status := okl_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_aulv_rec.agr_id IS NULL) OR
       (p_aulv_rec.agr_id = okl_Api.G_MISS_NUM) THEN
       okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'agr_id');
       x_return_status    := okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN agr_csr(p_aulv_rec.agr_id);

	FETCH agr_csr INTO l_fetch_rec;

	IF (agr_csr%NOTFOUND) THEN
		okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'agr_id');
          	x_return_status := okl_Api.G_RET_STS_ERROR;
                CLOSE agr_csr;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	    END IF;
	CLOSE agr_csr;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_agr_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_source
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_source
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_source(x_return_status OUT NOCOPY  VARCHAR2
			   ,p_aulv_rec      IN   aulv_rec_type )
  IS

  l_return_status VARCHAR2(1)  := okl_Api.G_RET_STS_SUCCESS;
  l_dummy VARCHAR2(1) := okl_API.G_FALSE;
  l_ae_line_type VARCHAR2(30);


  BEGIN

    x_return_status := okl_Api.G_RET_STS_SUCCESS;

    IF (p_aulv_rec.source IS NOT NULL) AND
       (p_aulv_rec.source <> okl_Api.G_MISS_CHAR) THEN

        l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                                  (p_lookup_type => 'OKL_ACC_GEN_SOURCE_TABLE',
                                   p_lookup_code =>  p_aulv_rec.source);

        IF (l_dummy = okl_API.G_FALSE) THEN
		okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'source');
          	x_return_status := okl_Api.G_RET_STS_ERROR;
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
      okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_source;



  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_ACC_GEN_RUL_LNS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_aulv_rec IN  aulv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;

   BEGIN

    -- Validate_Id
    Validate_Id(x_return_status, p_aulv_rec);
    -- store the highest degree of error
       IF (x_return_status <> okl_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = okl_Api.G_RET_STS_UNEXP_ERROR) THEN
             l_return_Status := x_return_Status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             l_return_Status := x_return_Status;
          END IF;
       END IF;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(x_return_status, p_aulv_rec);
       IF (x_return_status <> okl_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = okl_Api.G_RET_STS_UNEXP_ERROR) THEN
             l_return_Status := x_return_Status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             l_return_Status := x_return_Status;
          END IF;
       END IF;


    -- Validate_Segment
    Validate_Segment(x_return_status, p_aulv_rec);
       IF (x_return_status <> okl_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = okl_Api.G_RET_STS_UNEXP_ERROR) THEN
             l_return_Status := x_return_Status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             l_return_Status := x_return_Status;
          END IF;
       END IF;

    -- Validate_Segment_NUMBER
    Validate_Segment_Number(x_return_status, p_aulv_rec);
       IF (x_return_status <> okl_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = okl_Api.G_RET_STS_UNEXP_ERROR) THEN
             l_return_Status := x_return_Status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             l_return_Status := x_return_Status;
          END IF;
       END IF;


    -- Validate_agr_id
       validate_agr_id(x_return_status,p_aulv_rec);
       IF (x_return_status <> okl_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = okl_Api.G_RET_STS_UNEXP_ERROR) THEN
             l_return_Status := x_return_Status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             l_return_Status := x_return_Status;
          END IF;
       END IF;

    -- Validate_source
    Validate_source(x_return_status, p_aulv_rec);
       IF (x_return_status <> okl_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = okl_Api.G_RET_STS_UNEXP_ERROR) THEN
             l_return_Status := x_return_Status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             l_return_Status := x_return_Status;
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
       okl_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := okl_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);


  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_source_constant
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_source_constant
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_source_constant(x_return_status OUT NOCOPY  VARCHAR2
				    ,p_aulv_rec      IN   aulv_rec_type )
  IS

  l_return_status VARCHAR2(1)  := okl_Api.G_RET_STS_SUCCESS;
  l_fetch_rec VARCHAR2(1);

  BEGIN
    -- initialize return status
    x_return_status := okl_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF ((p_aulv_rec.source IS NULL) OR (p_aulv_rec.source = okl_Api.G_MISS_CHAR))
       AND
       ((p_aulv_rec.constants IS NULL) OR (p_aulv_rec.constants = okl_Api.G_MISS_CHAR))
    THEN
       okl_Api.SET_MESSAGE(p_app_name   => OKL_API.G_APP_NAME,
                           p_msg_name   => 'OKL_NONE_SRC_CONST');
       x_return_status    := okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  IF ((p_aulv_rec.source IS NOT NULL) AND (p_aulv_rec.source <> okl_Api.G_MISS_CHAR)) AND
     ((p_aulv_rec.constants IS NOT NULL) AND (p_aulv_rec.constants <> okl_Api.G_MISS_CHAR))  THEN

         OKL_API.SET_MESSAGE(p_app_name     =>  OKL_API.G_APP_NAME,
                             p_msg_name     => 'OKL_BOTH_SRC_CONST');

         x_return_status := okl_Api.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_source_constant;


-- 05-10-01 : spalod : end - procedures for validateing attributes

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_ACC_GEN_RUL_LNS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_aulv_rec IN aulv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
  BEGIN

    validate_source_constant(l_return_status, p_aulv_rec);

    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN aulv_rec_type,
    p_to	OUT NOCOPY aul_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.SEGMENT := p_from.SEGMENT;
    p_to.agr_id := p_from.agr_id;
    p_to.source := p_from.source;
    p_to.segment_number := p_from.segment_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.constants := p_from.constants;
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
    p_from	IN aul_rec_type,
    p_to	OUT NOCOPY aulv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.SEGMENT := p_from.SEGMENT;
    p_to.agr_id := p_from.agr_id;
    p_to.source := p_from.source;
    p_to.segment_number := p_from.segment_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.constants := p_from.constants;
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
  -- validate_row for:OKL_ACC_GEN_RUL_LNS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_aulv_rec                     aulv_rec_type := p_aulv_rec;
    l_aul_rec                      aul_rec_type;
  BEGIN
    l_return_status := okl_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_aulv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_aulv_rec);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    okl_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:AULV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aulv_tbl.COUNT > 0) THEN
      i := p_aulv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aulv_rec                     => p_aulv_tbl(i));

          IF (x_return_status <> okl_Api.G_RET_STS_SUCCESS) THEN
           IF (l_overall_status <> okl_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;

          END IF;
        EXIT WHEN (i = p_aulv_tbl.LAST);
        i := p_aulv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;

  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_ACC_GEN_RUL_LNS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aul_rec                      IN aul_rec_type,
    x_aul_rec                      OUT NOCOPY aul_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNS_insert_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_aul_rec                      aul_rec_type := p_aul_rec;
    l_def_aul_rec                  aul_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_ACC_GEN_RUL_LNS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_aul_rec IN  aul_rec_type,
      x_aul_rec OUT NOCOPY aul_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aul_rec := p_aul_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_aul_rec,                         -- IN
      l_aul_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_ACC_GEN_RUL_LNS(
        id,
        SEGMENT,
        segment_number,
        agr_id,
        source,
        object_version_number,
        constants,
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
        l_aul_rec.id,
        l_aul_rec.SEGMENT,
        l_aul_rec.segment_number,
        l_aul_rec.agr_id,
        l_aul_rec.source,
        l_aul_rec.object_version_number,
        l_aul_rec.constants,
        l_aul_rec.attribute_category,
        l_aul_rec.attribute1,
        l_aul_rec.attribute2,
        l_aul_rec.attribute3,
        l_aul_rec.attribute4,
        l_aul_rec.attribute5,
        l_aul_rec.attribute6,
        l_aul_rec.attribute7,
        l_aul_rec.attribute8,
        l_aul_rec.attribute9,
        l_aul_rec.attribute10,
        l_aul_rec.attribute11,
        l_aul_rec.attribute12,
        l_aul_rec.attribute13,
        l_aul_rec.attribute14,
        l_aul_rec.attribute15,
        l_aul_rec.created_by,
        l_aul_rec.creation_date,
        l_aul_rec.last_updated_by,
        l_aul_rec.last_update_date,
        l_aul_rec.last_update_login);
    -- Set OUT values
    x_aul_rec := l_aul_rec;
    okl_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_ACC_GEN_RUL_LNS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type,
    x_aulv_rec                     OUT NOCOPY aulv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_aulv_rec                     aulv_rec_type;
    l_def_aulv_rec                 aulv_rec_type;
    l_aul_rec                      aul_rec_type;
    lx_aul_rec                     aul_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aulv_rec	IN aulv_rec_type
    ) RETURN aulv_rec_type IS
      l_aulv_rec	aulv_rec_type := p_aulv_rec;
    BEGIN
      l_aulv_rec.CREATION_DATE := SYSDATE;
      l_aulv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_aulv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aulv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_aulv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_aulv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_ACC_GEN_RUL_LNS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_aulv_rec IN  aulv_rec_type,
      x_aulv_rec OUT NOCOPY aulv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aulv_rec := p_aulv_rec;
      x_aulv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    l_aulv_rec := null_out_defaults(p_aulv_rec);
    -- Set primary key value
    l_aulv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_aulv_rec,                        -- IN
      l_def_aulv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_aulv_rec := fill_who_columns(l_def_aulv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aulv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aulv_rec);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aulv_rec, l_aul_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aul_rec,
      lx_aul_rec
    );
    IF (x_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aul_rec, l_def_aulv_rec);
    -- Set OUT values
    x_aulv_rec := l_def_aulv_rec;
    okl_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:AULV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type,
    x_aulv_tbl                     OUT NOCOPY aulv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aulv_tbl.COUNT > 0) THEN
      i := p_aulv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aulv_rec                     => p_aulv_tbl(i),
          x_aulv_rec                     => x_aulv_tbl(i));

          IF (x_return_status <> okl_Api.G_RET_STS_SUCCESS) THEN

           IF (l_overall_status <> okl_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;

	  END IF;


        EXIT WHEN (i = p_aulv_tbl.LAST);
        i := p_aulv_tbl.NEXT(i);
      END LOOP;

    END IF;

    x_return_status := l_overall_status;
  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_ACC_GEN_RUL_LNS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aul_rec                      IN aul_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_aul_rec IN aul_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ACC_GEN_RUL_LNS
     WHERE ID = p_aul_rec.id
       AND OBJECT_VERSION_NUMBER = p_aul_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_aul_rec IN aul_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ACC_GEN_RUL_LNS
    WHERE ID = p_aul_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNS_lock_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_ACC_GEN_RUL_LNS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_ACC_GEN_RUL_LNS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := okl_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_aul_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        okl_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_aul_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      okl_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE okl_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_aul_rec.object_version_number THEN
      okl_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_aul_rec.object_version_number THEN
      okl_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      okl_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    okl_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_ACC_GEN_RUL_LNS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_aul_rec                      aul_rec_type;
  BEGIN
    l_return_status := okl_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_aulv_rec, l_aul_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aul_rec
    );
    IF (x_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    okl_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:AULV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_overall_Status               VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aulv_tbl.COUNT > 0) THEN
      i := p_aulv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aulv_rec                     => p_aulv_tbl(i));
 IF (x_return_status <> okl_Api.G_RET_STS_SUCCESS) THEN

           IF (l_overall_status <> okl_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;

          END IF;
        EXIT WHEN (i = p_aulv_tbl.LAST);
        i := p_aulv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_Status;
  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_ACC_GEN_RUL_LNS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aul_rec                      IN aul_rec_type,
    x_aul_rec                      OUT NOCOPY aul_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNS_update_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_aul_rec                      aul_rec_type := p_aul_rec;
    l_def_aul_rec                  aul_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aul_rec	IN aul_rec_type,
      x_aul_rec	OUT NOCOPY aul_rec_type
    ) RETURN VARCHAR2 IS
      l_aul_rec                      aul_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aul_rec := p_aul_rec;
      -- Get current database values
      l_aul_rec := get_rec(p_aul_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aul_rec.id = okl_API.G_MISS_NUM)
      THEN
        x_aul_rec.id := l_aul_rec.id;
      END IF;
      IF (x_aul_rec.SEGMENT = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.SEGMENT := l_aul_rec.SEGMENT;
      END IF;
      IF (x_aul_rec.agr_id = okl_API.G_MISS_NUM)
      THEN
        x_aul_rec.agr_id := l_aul_rec.agr_id;
      END IF;
      IF (x_aul_rec.source = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.source := l_aul_rec.source;
      END IF;
      IF (x_aul_rec.segment_number = okl_API.G_MISS_NUM)
      THEN
        x_aul_rec.segment_number := l_aul_rec.segment_number;
      END IF;
      IF (x_aul_rec.object_version_number = okl_API.G_MISS_NUM)
      THEN
        x_aul_rec.object_version_number := l_aul_rec.object_version_number;
      END IF;
      IF (x_aul_rec.constants = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.constants := l_aul_rec.constants;
      END IF;
      IF (x_aul_rec.attribute_category = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute_category := l_aul_rec.attribute_category;
      END IF;
      IF (x_aul_rec.attribute1 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute1 := l_aul_rec.attribute1;
      END IF;
      IF (x_aul_rec.attribute2 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute2 := l_aul_rec.attribute2;
      END IF;
      IF (x_aul_rec.attribute3 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute3 := l_aul_rec.attribute3;
      END IF;
      IF (x_aul_rec.attribute4 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute4 := l_aul_rec.attribute4;
      END IF;
      IF (x_aul_rec.attribute5 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute5 := l_aul_rec.attribute5;
      END IF;
      IF (x_aul_rec.attribute6 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute6 := l_aul_rec.attribute6;
      END IF;
      IF (x_aul_rec.attribute7 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute7 := l_aul_rec.attribute7;
      END IF;
      IF (x_aul_rec.attribute8 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute8 := l_aul_rec.attribute8;
      END IF;
      IF (x_aul_rec.attribute9 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute9 := l_aul_rec.attribute9;
      END IF;
      IF (x_aul_rec.attribute10 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute10 := l_aul_rec.attribute10;
      END IF;
      IF (x_aul_rec.attribute11 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute11 := l_aul_rec.attribute11;
      END IF;
      IF (x_aul_rec.attribute12 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute12 := l_aul_rec.attribute12;
      END IF;
      IF (x_aul_rec.attribute13 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute13 := l_aul_rec.attribute13;
      END IF;
      IF (x_aul_rec.attribute14 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute14 := l_aul_rec.attribute14;
      END IF;
      IF (x_aul_rec.attribute15 = okl_API.G_MISS_CHAR)
      THEN
        x_aul_rec.attribute15 := l_aul_rec.attribute15;
      END IF;
      IF (x_aul_rec.created_by = okl_API.G_MISS_NUM)
      THEN
        x_aul_rec.created_by := l_aul_rec.created_by;
      END IF;
      IF (x_aul_rec.creation_date = okl_API.G_MISS_DATE)
      THEN
        x_aul_rec.creation_date := l_aul_rec.creation_date;
      END IF;
      IF (x_aul_rec.last_updated_by = okl_API.G_MISS_NUM)
      THEN
        x_aul_rec.last_updated_by := l_aul_rec.last_updated_by;
      END IF;
      IF (x_aul_rec.last_update_date = okl_API.G_MISS_DATE)
      THEN
        x_aul_rec.last_update_date := l_aul_rec.last_update_date;
      END IF;
      IF (x_aul_rec.last_update_login = okl_API.G_MISS_NUM)
      THEN
        x_aul_rec.last_update_login := l_aul_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_ACC_GEN_RUL_LNS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_aul_rec IN  aul_rec_type,
      x_aul_rec OUT NOCOPY aul_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aul_rec := p_aul_rec;
      x_aul_rec.OBJECT_VERSION_NUMBER := NVL(x_aul_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_aul_rec,                         -- IN
      l_aul_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aul_rec, l_def_aul_rec);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_ACC_GEN_RUL_LNS
    SET SEGMENT = l_def_aul_rec.SEGMENT,
        SEGMENT_NUMBER = l_def_aul_rec.segment_number,
        AGR_ID = l_def_aul_rec.agr_id,
        SOURCE = l_def_aul_rec.source,
        OBJECT_VERSION_NUMBER = l_def_aul_rec.object_version_number,
        constants = l_def_aul_rec.constants,
        ATTRIBUTE_CATEGORY = l_def_aul_rec.attribute_category,
        ATTRIBUTE1 = l_def_aul_rec.attribute1,
        ATTRIBUTE2 = l_def_aul_rec.attribute2,
        ATTRIBUTE3 = l_def_aul_rec.attribute3,
        ATTRIBUTE4 = l_def_aul_rec.attribute4,
        ATTRIBUTE5 = l_def_aul_rec.attribute5,
        ATTRIBUTE6 = l_def_aul_rec.attribute6,
        ATTRIBUTE7 = l_def_aul_rec.attribute7,
        ATTRIBUTE8 = l_def_aul_rec.attribute8,
        ATTRIBUTE9 = l_def_aul_rec.attribute9,
        ATTRIBUTE10 = l_def_aul_rec.attribute10,
        ATTRIBUTE11 = l_def_aul_rec.attribute11,
        ATTRIBUTE12 = l_def_aul_rec.attribute12,
        ATTRIBUTE13 = l_def_aul_rec.attribute13,
        ATTRIBUTE14 = l_def_aul_rec.attribute14,
        ATTRIBUTE15 = l_def_aul_rec.attribute15,
        CREATED_BY = l_def_aul_rec.created_by,
        CREATION_DATE = l_def_aul_rec.creation_date,
        LAST_UPDATED_BY = l_def_aul_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_aul_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_aul_rec.last_update_login
    WHERE ID = l_def_aul_rec.id;

    x_aul_rec := l_def_aul_rec;
    okl_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_ACC_GEN_RUL_LNS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type,
    x_aulv_rec                     OUT NOCOPY aulv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_aulv_rec                     aulv_rec_type := p_aulv_rec;
    l_def_aulv_rec                 aulv_rec_type;
    l_aul_rec                      aul_rec_type;
    lx_aul_rec                     aul_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aulv_rec	IN aulv_rec_type
    ) RETURN aulv_rec_type IS
      l_aulv_rec	aulv_rec_type := p_aulv_rec;
    BEGIN
      l_aulv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aulv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_aulv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_aulv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aulv_rec	IN aulv_rec_type,
      x_aulv_rec	OUT NOCOPY aulv_rec_type
    ) RETURN VARCHAR2 IS
      l_aulv_rec                     aulv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aulv_rec := p_aulv_rec;
      -- Get current database values
      l_aulv_rec := get_rec(p_aulv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aulv_rec.id = okl_API.G_MISS_NUM)
      THEN
        x_aulv_rec.id := l_aulv_rec.id;
      END IF;
      IF (x_aulv_rec.object_version_number = okl_API.G_MISS_NUM)
      THEN
        x_aulv_rec.object_version_number := l_aulv_rec.object_version_number;
      END IF;
      IF (x_aulv_rec.source = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.source := l_aulv_rec.source;
      END IF;

      IF (x_aulv_rec.SEGMENT = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.SEGMENT := l_aulv_rec.SEGMENT;
      END IF;
      IF (x_aulv_rec.segment_number = okl_API.G_MISS_NUM)
      THEN
        x_aulv_rec.segment_number := l_aulv_rec.segment_number;
      END IF;
      IF (x_aulv_rec.constants = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.CONSTANTs := l_aulv_rec.CONSTANTs;
      END IF;
      IF (x_aulv_rec.attribute_category = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute_category := l_aulv_rec.attribute_category;
      END IF;
      IF (x_aulv_rec.attribute1 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute1 := l_aulv_rec.attribute1;
      END IF;
      IF (x_aulv_rec.attribute2 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute2 := l_aulv_rec.attribute2;
      END IF;
      IF (x_aulv_rec.attribute3 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute3 := l_aulv_rec.attribute3;
      END IF;
      IF (x_aulv_rec.attribute4 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute4 := l_aulv_rec.attribute4;
      END IF;
      IF (x_aulv_rec.attribute5 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute5 := l_aulv_rec.attribute5;
      END IF;
      IF (x_aulv_rec.attribute6 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute6 := l_aulv_rec.attribute6;
      END IF;
      IF (x_aulv_rec.attribute7 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute7 := l_aulv_rec.attribute7;
      END IF;
      IF (x_aulv_rec.attribute8 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute8 := l_aulv_rec.attribute8;
      END IF;
      IF (x_aulv_rec.attribute9 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute9 := l_aulv_rec.attribute9;
      END IF;
      IF (x_aulv_rec.attribute10 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute10 := l_aulv_rec.attribute10;
      END IF;
      IF (x_aulv_rec.attribute11 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute11 := l_aulv_rec.attribute11;
      END IF;
      IF (x_aulv_rec.attribute12 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute12 := l_aulv_rec.attribute12;
      END IF;
      IF (x_aulv_rec.attribute13 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute13 := l_aulv_rec.attribute13;
      END IF;
      IF (x_aulv_rec.attribute14 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute14 := l_aulv_rec.attribute14;
      END IF;
      IF (x_aulv_rec.attribute15 = okl_API.G_MISS_CHAR)
      THEN
        x_aulv_rec.attribute15 := l_aulv_rec.attribute15;
      END IF;
      IF (x_aulv_rec.agr_id = okl_API.G_MISS_NUM)
      THEN
        x_aulv_rec.agr_id := l_aulv_rec.agr_id;
      END IF;
      IF (x_aulv_rec.created_by = okl_API.G_MISS_NUM)
      THEN
        x_aulv_rec.created_by := l_aulv_rec.created_by;
      END IF;
      IF (x_aulv_rec.creation_date = okl_API.G_MISS_DATE)
      THEN
        x_aulv_rec.creation_date := l_aulv_rec.creation_date;
      END IF;
      IF (x_aulv_rec.last_updated_by = okl_API.G_MISS_NUM)
      THEN
        x_aulv_rec.last_updated_by := l_aulv_rec.last_updated_by;
      END IF;
      IF (x_aulv_rec.last_update_date = okl_API.G_MISS_DATE)
      THEN
        x_aulv_rec.last_update_date := l_aulv_rec.last_update_date;
      END IF;
      IF (x_aulv_rec.last_update_login = okl_API.G_MISS_NUM)
      THEN
        x_aulv_rec.last_update_login := l_aulv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_ACC_GEN_RUL_LNS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_aulv_rec IN  aulv_rec_type,
      x_aulv_rec OUT NOCOPY aulv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aulv_rec := p_aulv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_aulv_rec,                        -- IN
      l_aulv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aulv_rec, l_def_aulv_rec);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_aulv_rec := fill_who_columns(l_def_aulv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aulv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aulv_rec);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aulv_rec, l_aul_rec);

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_aulv_rec                      => l_aulv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aul_rec,
      lx_aul_rec
    );
    IF (x_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aul_rec, l_def_aulv_rec);
    x_aulv_rec := l_def_aulv_rec;
    okl_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      x_return_status :=OKL_API.G_RET_STS_ERROR;
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:AULV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type,
    x_aulv_tbl                     OUT NOCOPY aulv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aulv_tbl.COUNT > 0) THEN
      i := p_aulv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aulv_rec                     => p_aulv_tbl(i),
          x_aulv_rec                     => x_aulv_tbl(i));

          IF (x_return_status <> okl_Api.G_RET_STS_SUCCESS) THEN

           IF (l_overall_status <> okl_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;

	  END IF;

        EXIT WHEN (i = p_aulv_tbl.LAST);
        i := p_aulv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_Status;

  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_ACC_GEN_RUL_LNS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aul_rec                      IN aul_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNS_delete_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_aul_rec                      aul_rec_type:= p_aul_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := okl_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_ACC_GEN_RUL_LNS
     WHERE ID = l_aul_rec.id;

    okl_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_ACC_GEN_RUL_LNS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    l_aulv_rec                     aulv_rec_type := p_aulv_rec;
    l_aul_rec                      aul_rec_type;
  BEGIN
    l_return_status := okl_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_aulv_rec, l_aul_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aul_rec
    );
    IF (x_return_status = okl_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_API.G_RET_STS_ERROR) THEN
      RAISE okl_API.G_EXCEPTION_ERROR;
    END IF;
    okl_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:AULV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status               VARCHAR2(1) := okl_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aulv_tbl.COUNT > 0) THEN
      i := p_aulv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aulv_rec                     => p_aulv_tbl(i));

         IF (x_return_status <> okl_Api.G_RET_STS_SUCCESS) THEN
           IF (l_overall_status <> okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_overall_status := x_return_status;
           END IF;
	 END IF;

        EXIT WHEN (i = p_aulv_tbl.LAST);
        i := p_aulv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_Status := l_overall_status;
  EXCEPTION
    WHEN okl_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_AUL_PVT;


/
