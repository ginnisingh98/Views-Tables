--------------------------------------------------------
--  DDL for Package Body OKC_AAV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_AAV_PVT" AS
/* $Header: OKCSAAVB.pls 120.0 2005/05/25 22:37:45 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
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
  -- FUNCTION get_rec for: OKC_ACTION_ATT_VALS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aav_rec                      IN aav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aav_rec_type IS
    CURSOR aav_pk_csr (p_aae_id             IN NUMBER,
                       p_coe_id             IN NUMBER) IS
    SELECT
            AAE_ID,
            COE_ID,
            VALUE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Action_Att_Vals
     WHERE okc_action_att_vals.aae_id = p_aae_id
       AND okc_action_att_vals.coe_id = p_coe_id;
    l_aav_pk                       aav_pk_csr%ROWTYPE;
    l_aav_rec                      aav_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN aav_pk_csr (p_aav_rec.aae_id,
                     p_aav_rec.coe_id);
    FETCH aav_pk_csr INTO
              l_aav_rec.AAE_ID,
              l_aav_rec.COE_ID,
              l_aav_rec.VALUE,
              l_aav_rec.OBJECT_VERSION_NUMBER,
              l_aav_rec.CREATED_BY,
              l_aav_rec.CREATION_DATE,
              l_aav_rec.LAST_UPDATED_BY,
              l_aav_rec.LAST_UPDATE_DATE,
              l_aav_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := aav_pk_csr%NOTFOUND;
    CLOSE aav_pk_csr;
    RETURN(l_aav_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aav_rec                      IN aav_rec_type
  ) RETURN aav_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aav_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ACTION_ATT_VALS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aavv_rec                     IN aavv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aavv_rec_type IS
    CURSOR okc_aavv_pk_csr (p_aae_id             IN NUMBER,
                            p_coe_id             IN NUMBER) IS
    SELECT
            AAE_ID,
            COE_ID,
            OBJECT_VERSION_NUMBER,
            VALUE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Action_Att_Vals_V
     WHERE okc_action_att_vals_v.aae_id = p_aae_id
       AND okc_action_att_vals_v.coe_id = p_coe_id;
    l_okc_aavv_pk                  okc_aavv_pk_csr%ROWTYPE;
    l_aavv_rec                     aavv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_aavv_pk_csr (p_aavv_rec.aae_id,
                          p_aavv_rec.coe_id);
    FETCH okc_aavv_pk_csr INTO
              l_aavv_rec.AAE_ID,
              l_aavv_rec.COE_ID,
              l_aavv_rec.OBJECT_VERSION_NUMBER,
              l_aavv_rec.VALUE,
              l_aavv_rec.CREATED_BY,
              l_aavv_rec.CREATION_DATE,
              l_aavv_rec.LAST_UPDATED_BY,
              l_aavv_rec.LAST_UPDATE_DATE,
              l_aavv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_aavv_pk_csr%NOTFOUND;
    CLOSE okc_aavv_pk_csr;
    RETURN(l_aavv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aavv_rec                     IN aavv_rec_type
  ) RETURN aavv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aavv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_ACTION_ATT_VALS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_aavv_rec	IN aavv_rec_type
  ) RETURN aavv_rec_type IS
    l_aavv_rec	aavv_rec_type := p_aavv_rec;
  BEGIN
    IF (l_aavv_rec.aae_id = OKC_API.G_MISS_NUM) THEN
      l_aavv_rec.aae_id := NULL;
    END IF;
    IF (l_aavv_rec.coe_id = OKC_API.G_MISS_NUM) THEN
      l_aavv_rec.coe_id := NULL;
    END IF;
    IF (l_aavv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_aavv_rec.object_version_number := NULL;
    END IF;
    IF (l_aavv_rec.value = OKC_API.G_MISS_CHAR) THEN
      l_aavv_rec.value := NULL;
    END IF;
    IF (l_aavv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_aavv_rec.created_by := NULL;
    END IF;
    IF (l_aavv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_aavv_rec.creation_date := NULL;
    END IF;
    IF (l_aavv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_aavv_rec.last_updated_by := NULL;
    END IF;
    IF (l_aavv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_aavv_rec.last_update_date := NULL;
    END IF;
    IF (l_aavv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_aavv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_aavv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKC_ACTION_ATT_VALS_V --
  ---------------------------------------------------
  /* commenting out nocopy generated code in favor of hand written code
  FUNCTION Validate_Attributes (
    p_aavv_rec IN  aavv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_aavv_rec.aae_id = OKC_API.G_MISS_NUM OR
       p_aavv_rec.aae_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'aae_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aavv_rec.coe_id = OKC_API.G_MISS_NUM OR
          p_aavv_rec.coe_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'coe_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aavv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_aavv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aavv_rec.value = OKC_API.G_MISS_CHAR OR
          p_aavv_rec.value IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'value');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
  */

  /********************* HAND-CODED ****************************************/

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
                                          ,p_aavv_rec      IN   aavv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_aavv_rec.object_version_number IS NULL) OR
       (p_aavv_rec.object_version_Number = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'object_version_number');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Aae_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Aae_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Aae_Id(x_return_status OUT NOCOPY  VARCHAR2
                           ,p_aavv_rec      IN   aavv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_aavv_rec.aae_id IS NULL) OR
       (p_aavv_rec.aae_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'aae_id');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Aae_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Coe_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Coe_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Coe_Id(x_return_status OUT NOCOPY  VARCHAR2
                           ,p_aavv_rec      IN   aavv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_aavv_rec.coe_id IS NULL) OR
       (p_aavv_rec.coe_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'coe_id');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Coe_Id;

  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Aav_Record(x_return_status OUT NOCOPY  VARCHAR2
                                      ,p_aavv_rec      IN   aavv_rec_type)
  IS

  --l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  --l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_dummy                 VARCHAR2(1);
  l_row_found             Boolean := False;
  CURSOR c1(p_aae_id okc_action_att_vals_v.aae_id%TYPE,
		  p_coe_id okc_action_att_vals_v.coe_id%TYPE) is
  SELECT 1
  FROM okc_action_att_vals
  WHERE  aae_id = p_aae_id
  AND    coe_id = p_coe_id;


  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  /*Bug 1636056:The following code commented out nocopy since it was not using bind
	    variables and parsing was taking place.Replaced with explicit cursor
	    as above
    -- initialize columns of unique concatenated key

    l_unq_tbl(1).p_col_name    := 'aae_id';
    l_unq_tbl(1).p_col_val     := p_aavv_rec.aae_id;
    l_unq_tbl(2).p_col_name    := 'coe_id';
    l_unq_tbl(2).p_col_val     := p_aavv_rec.coe_id;
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- call check_comp_unique utility
	  OKC_UTIL.check_comp_unique('OKC_ACTION_ATT_VALS_V'
      				        ,l_unq_tbl
	                            ,l_return_status);
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
	  END IF;
*/
    OPEN c1(p_aavv_rec.aae_id,
		  p_aavv_rec.coe_id);
    FETCH c1 into l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found then
		--OKC_API.set_message(G_APP_NAME,G_UNQS,G_COL_NAME_TOKEN1,'aae_id',G_COL_NAME_TOKEN2,'coe_id');
		OKC_API.set_message(G_APP_NAME,G_UNQS);
		x_return_status := OKC_API.G_RET_STS_ERROR;
     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Aav_Record;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Foreign_Keys
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : Validate_Foreign_Keys
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
    FUNCTION validate_foreign_keys (
      p_aavv_rec IN aavv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_aaev_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM Okc_Action_Attributes_V
       WHERE okc_action_attributes_v.id = p_id;

      l_dummy_var                  VARCHAR2(1);

      CURSOR okc_coev_pk_csr (p_id         IN NUMBER) IS
      SELECT  '1'
        FROM Okc_Condition_Occurs_V
       WHERE okc_condition_occurs_v.id = p_id;

      l_dummy                      VARCHAR2(1);

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_aavv_rec.AAE_ID IS NOT NULL)
      THEN
        OPEN okc_aaev_pk_csr(p_aavv_rec.AAE_ID);
        FETCH okc_aaev_pk_csr INTO l_dummy_var;
        l_row_notfound := okc_aaev_pk_csr%NOTFOUND;
        CLOSE okc_aaev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AAE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_aavv_rec.COE_ID IS NOT NULL)
      THEN
        OPEN okc_coev_pk_csr(p_aavv_rec.COE_ID);
        FETCH okc_coev_pk_csr INTO l_dummy;
        l_row_notfound := okc_coev_pk_csr%NOTFOUND;
        CLOSE okc_coev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'COE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;

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
    p_aavv_rec IN  aavv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    -- call each column-level validation

    -- Validate Object_Version_Number
    Validate_Object_Version_Number(x_return_status,p_aavv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Aae_Id
    Validate_Aae_Id(x_return_status,p_aavv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Coe_Id
    Validate_Coe_Id(x_return_status,p_aavv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    l_return_status := Validate_Foreign_Keys(p_aavv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       -- need to leave
       x_return_status := l_return_status;
       RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
       -- record that there was an error
       x_return_status := l_return_status;
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
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKC_ACTION_ATT_VALS_V --
  -----------------------------------------------
  /* commenting out nocopy generated code in favor of hand written code
  FUNCTION Validate_Record (
    p_aavv_rec IN aavv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_aavv_rec IN aavv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_aaev_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              AAL_ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              ACN_ID,
              ELEMENT_NAME,
              NAME,
              DESCRIPTION,
              DATA_TYPE,
              LIST_YN,
              VISIBLE_YN,
              DATE_OF_INTEREST_YN,
              FORMAT_MASK,
              MINIMUM_VALUE,
              MAXIMUM_VALUE,
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
        FROM Okc_Action_Attributes_V
       WHERE okc_action_attributes_v.id = p_id;
      l_okc_aaev_pk                  okc_aaev_pk_csr%ROWTYPE;
      CURSOR okc_coev_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              CNH_ID,
              OBJECT_VERSION_NUMBER,
              DATETIME,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okc_Condition_Occurs_V
       WHERE okc_condition_occurs_v.id = p_id;
      l_okc_coev_pk                  okc_coev_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_aavv_rec.AAE_ID IS NOT NULL)
      THEN
        OPEN okc_aaev_pk_csr(p_aavv_rec.AAE_ID);
        FETCH okc_aaev_pk_csr INTO l_okc_aaev_pk;
        l_row_notfound := okc_aaev_pk_csr%NOTFOUND;
        CLOSE okc_aaev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AAE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_aavv_rec.COE_ID IS NOT NULL)
      THEN
        OPEN okc_coev_pk_csr(p_aavv_rec.COE_ID);
        FETCH okc_coev_pk_csr INTO l_okc_coev_pk;
        l_row_notfound := okc_coev_pk_csr%NOTFOUND;
        CLOSE okc_coev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'COE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_aavv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  */

  FUNCTION Validate_Record (
    p_aavv_rec IN aavv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
 /******** Commented out nocopy , called in Insert Row ***********
   -- Validate_Unique_Aav_Record;
   Validate_Unique_Aav_Record(x_return_status,p_aavv_rec);
   -- store the highest degree of error
   IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      -- need to leave
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
      -- record that there was an error
      l_return_status := x_return_status;
      END IF;
   END IF;
   */

   RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN aavv_rec_type,
    p_to	OUT NOCOPY aav_rec_type
  ) IS
  BEGIN
    p_to.aae_id := p_from.aae_id;
    p_to.coe_id := p_from.coe_id;
    p_to.value := p_from.value;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  --OUT parameter chamged to IN OUT by Rajesh
  PROCEDURE migrate (
    p_from	IN aav_rec_type,
    p_to	IN OUT NOCOPY aavv_rec_type
  ) IS
  BEGIN
    p_to.aae_id := p_from.aae_id;
    p_to.coe_id := p_from.coe_id;
    p_to.value := p_from.value;
    p_to.object_version_number := p_from.object_version_number;
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
  -- validate_row for:OKC_ACTION_ATT_VALS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_rec                     IN aavv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aavv_rec                     aavv_rec_type := p_aavv_rec;
    l_aav_rec                      aav_rec_type;
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
    l_return_status := Validate_Attributes(l_aavv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_aavv_rec);
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
  -- PL/SQL TBL validate_row for:AAVV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_tbl                     IN aavv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aavv_tbl.COUNT > 0) THEN
      i := p_aavv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aavv_rec                     => p_aavv_tbl(i));
        EXIT WHEN (i = p_aavv_tbl.LAST);
        i := p_aavv_tbl.NEXT(i);
      END LOOP;
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
  -- insert_row for:OKC_ACTION_ATT_VALS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aav_rec                      IN aav_rec_type,
    x_aav_rec                      OUT NOCOPY aav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aav_rec                      aav_rec_type := p_aav_rec;
    l_def_aav_rec                  aav_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATT_VALS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_aav_rec IN  aav_rec_type,
      x_aav_rec OUT NOCOPY aav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aav_rec := p_aav_rec;
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
      p_aav_rec,                         -- IN
      l_aav_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_ACTION_ATT_VALS(
        aae_id,
        coe_id,
        value,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_aav_rec.aae_id,
        l_aav_rec.coe_id,
        l_aav_rec.value,
        l_aav_rec.object_version_number,
        l_aav_rec.created_by,
        l_aav_rec.creation_date,
        l_aav_rec.last_updated_by,
        l_aav_rec.last_update_date,
        l_aav_rec.last_update_login);
    -- Set OUT values
    x_aav_rec := l_aav_rec;
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
  -- insert_row for:OKC_ACTION_ATT_VALS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_rec                     IN aavv_rec_type,
    x_aavv_rec                     OUT NOCOPY aavv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aavv_rec                     aavv_rec_type;
    l_def_aavv_rec                 aavv_rec_type;
    l_aav_rec                      aav_rec_type;
    lx_aav_rec                     aav_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aavv_rec	IN aavv_rec_type
    ) RETURN aavv_rec_type IS
      l_aavv_rec	aavv_rec_type := p_aavv_rec;
    BEGIN
      l_aavv_rec.CREATION_DATE := SYSDATE;
      l_aavv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_aavv_rec.LAST_UPDATE_DATE := l_aavv_rec.CREATION_DATE;
      l_aavv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_aavv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_aavv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATT_VALS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_aavv_rec IN  aavv_rec_type,
      x_aavv_rec OUT NOCOPY aavv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aavv_rec := p_aavv_rec;
      x_aavv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_aavv_rec := null_out_defaults(p_aavv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_aavv_rec,                        -- IN
      l_def_aavv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_aavv_rec := fill_who_columns(l_def_aavv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aavv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aavv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    /************ ADDED TO CHECK THE UNIQUENESS ****************/

    -- Validate_Unique_Aav_Record;
    Validate_Unique_Aav_Record(x_return_status,p_aavv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       -- need to leave
       l_return_status := x_return_status;
       RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
       -- record that there was an error
       l_return_status := x_return_status;
       END IF;
    END IF;

    /************ ADDED TO CHECK THE UNIQUENESS ****************/


    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aavv_rec, l_aav_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aav_rec,
      lx_aav_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aav_rec, l_def_aavv_rec);
    -- Set OUT values
    x_aavv_rec := l_def_aavv_rec;
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
  -- PL/SQL TBL insert_row for:AAVV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_tbl                     IN aavv_tbl_type,
    x_aavv_tbl                     OUT NOCOPY aavv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aavv_tbl.COUNT > 0) THEN
      i := p_aavv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aavv_rec                     => p_aavv_tbl(i),
          x_aavv_rec                     => x_aavv_tbl(i));
        EXIT WHEN (i = p_aavv_tbl.LAST);
        i := p_aavv_tbl.NEXT(i);
      END LOOP;
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
  -- lock_row for:OKC_ACTION_ATT_VALS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aav_rec                      IN aav_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_aav_rec IN aav_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ACTION_ATT_VALS
     WHERE AAE_ID = p_aav_rec.aae_id
       AND COE_ID = p_aav_rec.coe_id
       AND OBJECT_VERSION_NUMBER = p_aav_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_aav_rec IN aav_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ACTION_ATT_VALS
    WHERE AAE_ID = p_aav_rec.aae_id
       AND COE_ID = p_aav_rec.coe_id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_ACTION_ATT_VALS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_ACTION_ATT_VALS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_aav_rec);
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
      OPEN lchk_csr(p_aav_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_aav_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_aav_rec.object_version_number THEN
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
  -- lock_row for:OKC_ACTION_ATT_VALS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_rec                     IN aavv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aav_rec                      aav_rec_type;
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
    migrate(p_aavv_rec, l_aav_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aav_rec
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
  -- PL/SQL TBL lock_row for:AAVV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_tbl                     IN aavv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aavv_tbl.COUNT > 0) THEN
      i := p_aavv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aavv_rec                     => p_aavv_tbl(i));
        EXIT WHEN (i = p_aavv_tbl.LAST);
        i := p_aavv_tbl.NEXT(i);
      END LOOP;
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
  -- update_row for:OKC_ACTION_ATT_VALS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aav_rec                      IN aav_rec_type,
    x_aav_rec                      OUT NOCOPY aav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aav_rec                      aav_rec_type := p_aav_rec;
    l_def_aav_rec                  aav_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aav_rec	IN aav_rec_type,
      x_aav_rec	OUT NOCOPY aav_rec_type
    ) RETURN VARCHAR2 IS
      l_aav_rec                      aav_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aav_rec := p_aav_rec;
      -- Get current database values
      l_aav_rec := get_rec(p_aav_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aav_rec.aae_id = OKC_API.G_MISS_NUM)
      THEN
        x_aav_rec.aae_id := l_aav_rec.aae_id;
      END IF;
      IF (x_aav_rec.coe_id = OKC_API.G_MISS_NUM)
      THEN
        x_aav_rec.coe_id := l_aav_rec.coe_id;
      END IF;
      IF (x_aav_rec.value = OKC_API.G_MISS_CHAR)
      THEN
        x_aav_rec.value := l_aav_rec.value;
      END IF;
      IF (x_aav_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_aav_rec.object_version_number := l_aav_rec.object_version_number;
      END IF;
      IF (x_aav_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_aav_rec.created_by := l_aav_rec.created_by;
      END IF;
      IF (x_aav_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_aav_rec.creation_date := l_aav_rec.creation_date;
      END IF;
      IF (x_aav_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_aav_rec.last_updated_by := l_aav_rec.last_updated_by;
      END IF;
      IF (x_aav_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_aav_rec.last_update_date := l_aav_rec.last_update_date;
      END IF;
      IF (x_aav_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_aav_rec.last_update_login := l_aav_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATT_VALS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_aav_rec IN  aav_rec_type,
      x_aav_rec OUT NOCOPY aav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aav_rec := p_aav_rec;
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
      p_aav_rec,                         -- IN
      l_aav_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aav_rec, l_def_aav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_ACTION_ATT_VALS
    SET VALUE = l_def_aav_rec.value,
        OBJECT_VERSION_NUMBER = l_def_aav_rec.object_version_number,
        CREATED_BY = l_def_aav_rec.created_by,
        CREATION_DATE = l_def_aav_rec.creation_date,
        LAST_UPDATED_BY = l_def_aav_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_aav_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_aav_rec.last_update_login
    WHERE AAE_ID = l_def_aav_rec.aae_id
      AND COE_ID = l_def_aav_rec.coe_id;

    x_aav_rec := l_def_aav_rec;
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
  -- update_row for:OKC_ACTION_ATT_VALS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_rec                     IN aavv_rec_type,
    x_aavv_rec                     OUT NOCOPY aavv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aavv_rec                     aavv_rec_type := p_aavv_rec;
    l_def_aavv_rec                 aavv_rec_type;
    l_aav_rec                      aav_rec_type;
    lx_aav_rec                     aav_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aavv_rec	IN aavv_rec_type
    ) RETURN aavv_rec_type IS
      l_aavv_rec	aavv_rec_type := p_aavv_rec;
    BEGIN
      l_aavv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aavv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_aavv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_aavv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aavv_rec	IN aavv_rec_type,
      x_aavv_rec	OUT NOCOPY aavv_rec_type
    ) RETURN VARCHAR2 IS
      l_aavv_rec                     aavv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aavv_rec := p_aavv_rec;
      -- Get current database values
      l_aavv_rec := get_rec(p_aavv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aavv_rec.aae_id = OKC_API.G_MISS_NUM)
      THEN
        x_aavv_rec.aae_id := l_aavv_rec.aae_id;
      END IF;
      IF (x_aavv_rec.coe_id = OKC_API.G_MISS_NUM)
      THEN
        x_aavv_rec.coe_id := l_aavv_rec.coe_id;
      END IF;
      IF (x_aavv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_aavv_rec.object_version_number := l_aavv_rec.object_version_number;
      END IF;
      IF (x_aavv_rec.value = OKC_API.G_MISS_CHAR)
      THEN
        x_aavv_rec.value := l_aavv_rec.value;
      END IF;
      IF (x_aavv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_aavv_rec.created_by := l_aavv_rec.created_by;
      END IF;
      IF (x_aavv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_aavv_rec.creation_date := l_aavv_rec.creation_date;
      END IF;
      IF (x_aavv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_aavv_rec.last_updated_by := l_aavv_rec.last_updated_by;
      END IF;
      IF (x_aavv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_aavv_rec.last_update_date := l_aavv_rec.last_update_date;
      END IF;
      IF (x_aavv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_aavv_rec.last_update_login := l_aavv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATT_VALS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_aavv_rec IN  aavv_rec_type,
      x_aavv_rec OUT NOCOPY aavv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aavv_rec := p_aavv_rec;
      x_aavv_rec.OBJECT_VERSION_NUMBER := NVL(x_aavv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_aavv_rec,                        -- IN
      l_aavv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aavv_rec, l_def_aavv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_aavv_rec := fill_who_columns(l_def_aavv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aavv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aavv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aavv_rec, l_aav_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aav_rec,
      lx_aav_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aav_rec, l_def_aavv_rec);
    x_aavv_rec := l_def_aavv_rec;
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
  -- PL/SQL TBL update_row for:AAVV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_tbl                     IN aavv_tbl_type,
    x_aavv_tbl                     OUT NOCOPY aavv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aavv_tbl.COUNT > 0) THEN
      i := p_aavv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aavv_rec                     => p_aavv_tbl(i),
          x_aavv_rec                     => x_aavv_tbl(i));
        EXIT WHEN (i = p_aavv_tbl.LAST);
        i := p_aavv_tbl.NEXT(i);
      END LOOP;
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
  -- delete_row for:OKC_ACTION_ATT_VALS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aav_rec                      IN aav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aav_rec                      aav_rec_type:= p_aav_rec;
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
    DELETE FROM OKC_ACTION_ATT_VALS
     WHERE AAE_ID = l_aav_rec.aae_id AND
COE_ID = l_aav_rec.coe_id;

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
  -- delete_row for:OKC_ACTION_ATT_VALS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_rec                     IN aavv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aavv_rec                     aavv_rec_type := p_aavv_rec;
    l_aav_rec                      aav_rec_type;
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
    migrate(l_aavv_rec, l_aav_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aav_rec
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
  -- PL/SQL TBL delete_row for:AAVV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_tbl                     IN aavv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aavv_tbl.COUNT > 0) THEN
      i := p_aavv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aavv_rec                     => p_aavv_tbl(i));
        EXIT WHEN (i = p_aavv_tbl.LAST);
        i := p_aavv_tbl.NEXT(i);
      END LOOP;
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
---------------------------------------------------------------
-- Procedure for mass insert in OKC_ACTION_ATTRIBUTES_VALS _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2, p_aavv_tbl aavv_tbl_type) IS
  l_tabsize NUMBER := p_aavv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_aae_id                        OKC_DATATYPES.NumberTabTyp;
  in_coe_id                        OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_value                         OKC_DATATYPES.Var1995TabTyp; --Changed for Bug 3408604
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  j                                NUMBER := 0;
  i                                NUMBER := p_aavv_tbl.FIRST;
BEGIN
  x_return_status := OKC_API.G_RET_STS_ERROR;
  -- Initializing the Return Status

  while i is not null
  LOOP
    j := j + 1;
    in_aae_id                   (j) := p_aavv_tbl(i).aae_id;
    in_coe_id                   (j) := p_aavv_tbl(i).coe_id;
    in_object_version_number    (j) := p_aavv_tbl(i).object_version_number;
    in_value                    (j) := p_aavv_tbl(i).value;
    in_created_by               (j) := p_aavv_tbl(i).created_by;
    in_creation_date            (j) := p_aavv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_aavv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_aavv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_aavv_tbl(i).last_update_login;
    i := p_aavv_tbl.NEXT(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_ACTION_ATT_VALS
      (
        aae_id,
        coe_id,
        value,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
     )
     VALUES (
        in_aae_id(i),
        in_coe_id(i),
        in_value(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i)
     );

EXCEPTION
  WHEN OTHERS THEN
 -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- RAISE;
END INSERT_ROW_UPG;
END OKC_AAV_PVT;

/
