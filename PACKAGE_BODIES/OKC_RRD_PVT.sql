--------------------------------------------------------
--  DDL for Package Body OKC_RRD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RRD_PVT" AS
/* $Header: OKCSRRDB.pls 120.0 2005/05/25 18:42:01 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
    l_id Number;
-- for customer's data (for non-seeded date id should be 50000 or above)
    cursor nonseed_c is
      select
         OKC_RG_ROLE_DEFS_S1.nextval
      from
         dual;
-- for datamerge's data (for seeded date id should be greater than or equal to 11000 and less than 50000)
    cursor seed_c is
      select
	 nvl(max(id), 11000) + 1
      from
         OKC_RG_ROLE_DEFS_V
      where
         id >= 11000 AND id < 50000;
  BEGIN
   if fnd_global.user_id = 1 then
      open seed_c;
      fetch seed_c into l_id;
      close seed_c;
   else
      open nonseed_c;
      fetch nonseed_c into l_id;
      close nonseed_c;
   end if;
/*
    SELECT OKC_RG_ROLE_DEFS_S1.nextval
      INTO l_id
      FROM DUAL;
*/
    RETURN(l_id);
    -- RETURN(okc_p_util.raw_to_number(sys_guid()));
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
  -- FUNCTION get_rec for: OKC_RG_ROLE_DEFS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rrd_rec                      IN rrd_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rrd_rec_type IS
    CURSOR rrd_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SRD_ID,
            SRE_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            SUBJECT_OBJECT_FLAG,
            OPTIONAL_YN,
            LAST_UPDATE_LOGIN,
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
            ACCESS_LEVEL
      FROM Okc_Rg_Role_Defs
     WHERE okc_rg_role_defs.id  = p_id;
    l_rrd_pk                       rrd_pk_csr%ROWTYPE;
    l_rrd_rec                      rrd_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN rrd_pk_csr (p_rrd_rec.id);
    FETCH rrd_pk_csr INTO
              l_rrd_rec.ID,
              l_rrd_rec.SRD_ID,
              l_rrd_rec.SRE_ID,
              l_rrd_rec.OBJECT_VERSION_NUMBER,
              l_rrd_rec.CREATED_BY,
              l_rrd_rec.CREATION_DATE,
              l_rrd_rec.LAST_UPDATED_BY,
              l_rrd_rec.LAST_UPDATE_DATE,
              l_rrd_rec.SUBJECT_OBJECT_FLAG,
              l_rrd_rec.OPTIONAL_YN,
              l_rrd_rec.LAST_UPDATE_LOGIN,
              l_rrd_rec.ATTRIBUTE_CATEGORY,
              l_rrd_rec.ATTRIBUTE1,
              l_rrd_rec.ATTRIBUTE2,
              l_rrd_rec.ATTRIBUTE3,
              l_rrd_rec.ATTRIBUTE4,
              l_rrd_rec.ATTRIBUTE5,
              l_rrd_rec.ATTRIBUTE6,
              l_rrd_rec.ATTRIBUTE7,
              l_rrd_rec.ATTRIBUTE8,
              l_rrd_rec.ATTRIBUTE9,
              l_rrd_rec.ATTRIBUTE10,
              l_rrd_rec.ATTRIBUTE11,
              l_rrd_rec.ATTRIBUTE12,
              l_rrd_rec.ATTRIBUTE13,
              l_rrd_rec.ATTRIBUTE14,
              l_rrd_rec.ATTRIBUTE15,
              l_rrd_rec.ACCESS_LEVEL;
    x_no_data_found := rrd_pk_csr%NOTFOUND;
    CLOSE rrd_pk_csr;
    RETURN(l_rrd_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rrd_rec                      IN rrd_rec_type
  ) RETURN rrd_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rrd_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RG_ROLE_DEFS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rrdv_rec                     IN rrdv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rrdv_rec_type IS
    CURSOR okc_rrdv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SRD_ID,
            SRE_ID,
            OPTIONAL_YN,
            SUBJECT_OBJECT_FLAG,
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
            LAST_UPDATE_LOGIN,
            ACCESS_LEVEL
      FROM Okc_Rg_Role_Defs_V
     WHERE okc_rg_role_defs_v.id = p_id;
    l_okc_rrdv_pk                  okc_rrdv_pk_csr%ROWTYPE;
    l_rrdv_rec                     rrdv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_rrdv_pk_csr (p_rrdv_rec.id);
    FETCH okc_rrdv_pk_csr INTO
              l_rrdv_rec.ID,
              l_rrdv_rec.OBJECT_VERSION_NUMBER,
              l_rrdv_rec.SRD_ID,
              l_rrdv_rec.SRE_ID,
              l_rrdv_rec.OPTIONAL_YN,
              l_rrdv_rec.SUBJECT_OBJECT_FLAG,
              l_rrdv_rec.ATTRIBUTE_CATEGORY,
              l_rrdv_rec.ATTRIBUTE1,
              l_rrdv_rec.ATTRIBUTE2,
              l_rrdv_rec.ATTRIBUTE3,
              l_rrdv_rec.ATTRIBUTE4,
              l_rrdv_rec.ATTRIBUTE5,
              l_rrdv_rec.ATTRIBUTE6,
              l_rrdv_rec.ATTRIBUTE7,
              l_rrdv_rec.ATTRIBUTE8,
              l_rrdv_rec.ATTRIBUTE9,
              l_rrdv_rec.ATTRIBUTE10,
              l_rrdv_rec.ATTRIBUTE11,
              l_rrdv_rec.ATTRIBUTE12,
              l_rrdv_rec.ATTRIBUTE13,
              l_rrdv_rec.ATTRIBUTE14,
              l_rrdv_rec.ATTRIBUTE15,
              l_rrdv_rec.CREATED_BY,
              l_rrdv_rec.CREATION_DATE,
              l_rrdv_rec.LAST_UPDATED_BY,
              l_rrdv_rec.LAST_UPDATE_DATE,
              l_rrdv_rec.LAST_UPDATE_LOGIN,
              l_rrdv_rec.ACCESS_LEVEL;
    x_no_data_found := okc_rrdv_pk_csr%NOTFOUND;
    CLOSE okc_rrdv_pk_csr;
    RETURN(l_rrdv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rrdv_rec                     IN rrdv_rec_type
  ) RETURN rrdv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rrdv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_RG_ROLE_DEFS_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_rrdv_rec	IN rrdv_rec_type
  ) RETURN rrdv_rec_type IS
    l_rrdv_rec	rrdv_rec_type := p_rrdv_rec;
  BEGIN
    IF (l_rrdv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_rrdv_rec.object_version_number := NULL;
    END IF;
    IF (l_rrdv_rec.srd_id = OKC_API.G_MISS_NUM) THEN
      l_rrdv_rec.srd_id := NULL;
    END IF;
    IF (l_rrdv_rec.sre_id = OKC_API.G_MISS_NUM) THEN
      l_rrdv_rec.sre_id := NULL;
    END IF;
    IF (l_rrdv_rec.optional_yn = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.optional_yn := NULL;
    END IF;
    IF (l_rrdv_rec.subject_object_flag = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.subject_object_flag := NULL;
    END IF;
    IF (l_rrdv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute_category := NULL;
    END IF;
    IF (l_rrdv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute1 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute2 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute3 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute4 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute5 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute6 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute7 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute8 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute9 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute10 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute11 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute12 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute13 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute14 := NULL;
    END IF;
    IF (l_rrdv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.attribute15 := NULL;
    END IF;
    IF (l_rrdv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_rrdv_rec.created_by := NULL;
    END IF;
    IF (l_rrdv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_rrdv_rec.creation_date := NULL;
    END IF;
    IF (l_rrdv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_rrdv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rrdv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_rrdv_rec.last_update_date := NULL;
    END IF;
    IF (l_rrdv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_rrdv_rec.last_update_login := NULL;
    END IF;
    IF (l_rrdv_rec.access_level = OKC_API.G_MISS_CHAR) THEN
      l_rrdv_rec.access_level := NULL;
    END IF;
    RETURN(l_rrdv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------------------
  --Attribute Level Validattion Procedures Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id(
    p_rrdv_rec          IN rrdv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_rrdv_rec.id = OKC_API.G_MISS_NUM OR
       p_rrdv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number(
    p_rrdv_rec          IN rrdv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_rrdv_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_rrdv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_srd_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_srd_id(
    p_rrdv_rec          IN rrdv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_rrdv_rec.srd_id = OKC_API.G_MISS_NUM OR
       p_rrdv_rec.srd_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'srd_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_srd_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_sre_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_sre_id(
    p_rrdv_rec          IN rrdv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_rrdv_rec.sre_id = OKC_API.G_MISS_NUM OR
       p_rrdv_rec.sre_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sre_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_sre_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_optional_yn
  ---------------------------------------------------------------------------
  PROCEDURE validate_optional_yn(
    p_rrdv_rec          IN rrdv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_rrdv_rec.optional_yn = OKC_API.G_MISS_CHAR OR
       p_rrdv_rec.optional_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'optional_yn');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF UPPER(p_rrdv_rec.optional_yn) IN ('Y', 'N') Then
      IF p_rrdv_rec.optional_yn <> UPPER(p_rrdv_rec.optional_yn) Then
        OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED, G_COL_NAME_TOKEN, 'optional_yn');
        x_return_status := OKC_API.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'optional_yn');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_optional_yn;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_subject_object_flag
  ---------------------------------------------------------------------------
  PROCEDURE validate_subject_object_flag(
    p_rrdv_rec          IN rrdv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_rrdv_rec.subject_object_flag = OKC_API.G_MISS_CHAR OR
       p_rrdv_rec.subject_object_flag IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'subject_object_flag');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF UPPER(p_rrdv_rec.subject_object_flag) IN ('S', 'O') Then
      IF p_rrdv_rec.subject_object_flag <> UPPER(p_rrdv_rec.subject_object_flag) Then
        OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED, G_COL_NAME_TOKEN, 'subject_object_flag');
        x_return_status := OKC_API.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'subject_object_flag');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_subject_object_flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_ACCESS_LEVEL
  ---------------------------------------------------------------------------
  PROCEDURE validate_access_level(
          p_rrdv_rec      IN    rrdv_rec_type,
          x_return_status 	OUT NOCOPY VARCHAR2) IS
  Begin

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_rrdv_rec.access_level <> OKC_API.G_MISS_CHAR and
  	   p_rrdv_rec.access_level IS NOT NULL)
    Then
       If p_rrdv_rec.access_level NOT IN ('S','E', 'U') Then
  	     OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
				 p_msg_name	=> g_invalid_value,
				 p_token1	=> g_col_name_token,
				 p_token1_value	=> 'access_level');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

	     -- halt validation
	     raise G_EXCEPTION_HALT_VALIDATION;
	end if;
    End If;
  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
			      p_msg_name	=> g_unexpected_error,
			      p_token1		=> g_sqlcode_token,
			      p_token1_value	=> sqlcode,
			      p_token2		=> g_sqlerrm_token,
			      p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End validate_access_level;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKC_RG_ROLE_DEFS_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_rrdv_rec IN  rrdv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Starts(Modification on TAPI generated Code.
  ---------------------------------------------------------------------------------------

    VALIDATE_id(p_rrdv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_object_version_number(p_rrdv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_srd_id(p_rrdv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_sre_id(p_rrdv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_optional_yn(p_rrdv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_subject_object_flag(p_rrdv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_access_level(p_rrdv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

      return(x_return_status);
  ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Ends(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKC_RG_ROLE_DEFS_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_rrdv_rec IN rrdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_rrdv_rec IN rrdv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_srev_pk_csr (p_id                 IN NUMBER) IS
      SELECT 'x'
        FROM Okc_Subclass_Roles_V
       WHERE okc_subclass_roles_v.id = p_id;
      CURSOR okc_srdv_pk_csr (p_id                 IN NUMBER) IS
      SELECT 'x'
        FROM Okc_Subclass_Rg_Defs_V
       WHERE okc_subclass_rg_defs_v.id = p_id;
      l_dummy                        VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_rrdv_rec.SRE_ID IS NOT NULL)
      THEN
        OPEN okc_srev_pk_csr(p_rrdv_rec.SRE_ID);
        FETCH okc_srev_pk_csr INTO l_dummy;
        l_row_notfound := okc_srev_pk_csr%NOTFOUND;
        CLOSE okc_srev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SRE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_rrdv_rec.SRD_ID IS NOT NULL)
      THEN
        OPEN okc_srdv_pk_csr(p_rrdv_rec.SRD_ID);
        FETCH okc_srdv_pk_csr INTO l_dummy;
        l_row_notfound := okc_srdv_pk_csr%NOTFOUND;
        CLOSE okc_srdv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SRD_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
    ----------------------------------------------------
    FUNCTION validate_unique_keys (
      p_rrdv_rec IN rrdv_rec_type
    ) RETURN VARCHAR2 IS
      unique_key_error          EXCEPTION;
      CURSOR c1 (p_id IN okc_rg_role_defs_v.id%TYPE,
                 p_srd_id IN okc_rg_role_defs_v.srd_id%TYPE,
                 p_sre_id IN okc_rg_role_defs_v.sre_id%TYPE) IS
      SELECT 'x'
        FROM Okc_Rg_Role_Defs_V
       WHERE srd_id = p_srd_id
         AND sre_id = p_sre_id
         AND ((p_id IS NULL)
          OR  (p_id IS NOT NULL
         AND   id <> p_id));
      l_dummy                        VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_found                    BOOLEAN := FALSE;
    BEGIN
      IF (p_rrdv_rec.SRD_ID IS NOT NULL AND
          p_rrdv_rec.SRE_ID IS NOT NULL) THEN
        OPEN c1(p_rrdv_rec.ID,
                p_rrdv_rec.SRD_ID,
                p_rrdv_rec.SRE_ID);
        FETCH c1 INTO l_dummy;
        l_row_found := c1%FOUND;
        CLOSE c1;
        IF (l_row_found) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'SRD_ID');
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'SRE_ID');
          RAISE unique_key_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN unique_key_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_unique_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_rrdv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_return_status := validate_unique_keys (p_rrdv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    RETURN (l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN rrdv_rec_type,
    p_to	OUT NOCOPY rrd_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.srd_id := p_from.srd_id;
    p_to.sre_id := p_from.sre_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.subject_object_flag := p_from.subject_object_flag;
    p_to.optional_yn := p_from.optional_yn;
    p_to.last_update_login := p_from.last_update_login;
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
    p_to.access_level := p_from.access_level;
  END migrate;
  PROCEDURE migrate (
    p_from	IN rrd_rec_type,
    p_to	IN OUT NOCOPY rrdv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.srd_id := p_from.srd_id;
    p_to.sre_id := p_from.sre_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.subject_object_flag := p_from.subject_object_flag;
    p_to.optional_yn := p_from.optional_yn;
    p_to.last_update_login := p_from.last_update_login;
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
    p_to.access_level := p_from.access_level;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKC_RG_ROLE_DEFS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rrdv_rec                     rrdv_rec_type := p_rrdv_rec;
    l_rrd_rec                      rrd_rec_type;
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
    l_return_status := Validate_Attributes(l_rrdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rrdv_rec);
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
  -- PL/SQL TBL validate_row for:RRDV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN rrdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rrdv_tbl.COUNT > 0) THEN
      i := p_rrdv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rrdv_rec                     => p_rrdv_tbl(i));
        EXIT WHEN (i = p_rrdv_tbl.LAST);
        i := p_rrdv_tbl.NEXT(i);
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
  -------------------------------------
  -- insert_row for:OKC_RG_ROLE_DEFS --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrd_rec                      IN rrd_rec_type,
    x_rrd_rec                      OUT NOCOPY rrd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DEFS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rrd_rec                      rrd_rec_type := p_rrd_rec;
    l_def_rrd_rec                  rrd_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKC_RG_ROLE_DEFS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_rrd_rec IN  rrd_rec_type,
      x_rrd_rec OUT NOCOPY rrd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rrd_rec := p_rrd_rec;
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
      p_rrd_rec,                         -- IN
      l_rrd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_RG_ROLE_DEFS(
        id,
        srd_id,
        sre_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        subject_object_flag,
        optional_yn,
        last_update_login,
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
        access_level)
      VALUES (
        l_rrd_rec.id,
        l_rrd_rec.srd_id,
        l_rrd_rec.sre_id,
        l_rrd_rec.object_version_number,
        l_rrd_rec.created_by,
        l_rrd_rec.creation_date,
        l_rrd_rec.last_updated_by,
        l_rrd_rec.last_update_date,
        l_rrd_rec.subject_object_flag,
        l_rrd_rec.optional_yn,
        l_rrd_rec.last_update_login,
        l_rrd_rec.attribute_category,
        l_rrd_rec.attribute1,
        l_rrd_rec.attribute2,
        l_rrd_rec.attribute3,
        l_rrd_rec.attribute4,
        l_rrd_rec.attribute5,
        l_rrd_rec.attribute6,
        l_rrd_rec.attribute7,
        l_rrd_rec.attribute8,
        l_rrd_rec.attribute9,
        l_rrd_rec.attribute10,
        l_rrd_rec.attribute11,
        l_rrd_rec.attribute12,
        l_rrd_rec.attribute13,
        l_rrd_rec.attribute14,
        l_rrd_rec.attribute15,
        l_rrd_rec.access_level);
    -- Set OUT values
    x_rrd_rec := l_rrd_rec;
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
  ---------------------------------------
  -- insert_row for:OKC_RG_ROLE_DEFS_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type,
    x_rrdv_rec                     OUT NOCOPY rrdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rrdv_rec                     rrdv_rec_type;
    l_def_rrdv_rec                 rrdv_rec_type;
    l_rrd_rec                      rrd_rec_type;
    lx_rrd_rec                     rrd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rrdv_rec	IN rrdv_rec_type
    ) RETURN rrdv_rec_type IS
      l_rrdv_rec	rrdv_rec_type := p_rrdv_rec;
    BEGIN
      l_rrdv_rec.CREATION_DATE := SYSDATE;
      l_rrdv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rrdv_rec.LAST_UPDATE_DATE := l_rrdv_rec.CREATION_DATE;
      l_rrdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rrdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rrdv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKC_RG_ROLE_DEFS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_rrdv_rec IN  rrdv_rec_type,
      x_rrdv_rec OUT NOCOPY rrdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rrdv_rec := p_rrdv_rec;
      x_rrdv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_rrdv_rec := null_out_defaults(p_rrdv_rec);
    -- Set primary key value
    l_rrdv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rrdv_rec,                        -- IN
      l_def_rrdv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rrdv_rec := fill_who_columns(l_def_rrdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rrdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rrdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rrdv_rec, l_rrd_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rrd_rec,
      lx_rrd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rrd_rec, l_def_rrdv_rec);
    -- Set OUT values
    x_rrdv_rec := l_def_rrdv_rec;
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
  -- PL/SQL TBL insert_row for:RRDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN rrdv_tbl_type,
    x_rrdv_tbl                     OUT NOCOPY rrdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rrdv_tbl.COUNT > 0) THEN
      i := p_rrdv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rrdv_rec                     => p_rrdv_tbl(i),
          x_rrdv_rec                     => x_rrdv_tbl(i));
        EXIT WHEN (i = p_rrdv_tbl.LAST);
        i := p_rrdv_tbl.NEXT(i);
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
  -----------------------------------
  -- lock_row for:OKC_RG_ROLE_DEFS --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrd_rec                      IN rrd_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rrd_rec IN rrd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RG_ROLE_DEFS
     WHERE ID = p_rrd_rec.id
       AND OBJECT_VERSION_NUMBER = p_rrd_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_rrd_rec IN rrd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RG_ROLE_DEFS
    WHERE ID = p_rrd_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DEFS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_RG_ROLE_DEFS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_RG_ROLE_DEFS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_rrd_rec);
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
      OPEN lchk_csr(p_rrd_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rrd_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rrd_rec.object_version_number THEN
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
  -------------------------------------
  -- lock_row for:OKC_RG_ROLE_DEFS_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rrd_rec                      rrd_rec_type;
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
    migrate(p_rrdv_rec, l_rrd_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rrd_rec
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
  -- PL/SQL TBL lock_row for:RRDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN rrdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rrdv_tbl.COUNT > 0) THEN
      i := p_rrdv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rrdv_rec                     => p_rrdv_tbl(i));
        EXIT WHEN (i = p_rrdv_tbl.LAST);
        i := p_rrdv_tbl.NEXT(i);
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
  -------------------------------------
  -- update_row for:OKC_RG_ROLE_DEFS --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrd_rec                      IN rrd_rec_type,
    x_rrd_rec                      OUT NOCOPY rrd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DEFS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rrd_rec                      rrd_rec_type := p_rrd_rec;
    l_def_rrd_rec                  rrd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rrd_rec	IN rrd_rec_type,
      x_rrd_rec	OUT NOCOPY rrd_rec_type
    ) RETURN VARCHAR2 IS
      l_rrd_rec                      rrd_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rrd_rec := p_rrd_rec;
      -- Get current database values
      l_rrd_rec := get_rec(p_rrd_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rrd_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rrd_rec.id := l_rrd_rec.id;
      END IF;
      IF (x_rrd_rec.srd_id = OKC_API.G_MISS_NUM)
      THEN
        x_rrd_rec.srd_id := l_rrd_rec.srd_id;
      END IF;
      IF (x_rrd_rec.sre_id = OKC_API.G_MISS_NUM)
      THEN
        x_rrd_rec.sre_id := l_rrd_rec.sre_id;
      END IF;
      IF (x_rrd_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rrd_rec.object_version_number := l_rrd_rec.object_version_number;
      END IF;
      IF (x_rrd_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rrd_rec.created_by := l_rrd_rec.created_by;
      END IF;
      IF (x_rrd_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rrd_rec.creation_date := l_rrd_rec.creation_date;
      END IF;
      IF (x_rrd_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rrd_rec.last_updated_by := l_rrd_rec.last_updated_by;
      END IF;
      IF (x_rrd_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rrd_rec.last_update_date := l_rrd_rec.last_update_date;
      END IF;
      IF (x_rrd_rec.subject_object_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.subject_object_flag := l_rrd_rec.subject_object_flag;
      END IF;
      IF (x_rrd_rec.optional_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.optional_yn := l_rrd_rec.optional_yn;
      END IF;
      IF (x_rrd_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rrd_rec.last_update_login := l_rrd_rec.last_update_login;
      END IF;
      IF (x_rrd_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute_category := l_rrd_rec.attribute_category;
      END IF;
      IF (x_rrd_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute1 := l_rrd_rec.attribute1;
      END IF;
      IF (x_rrd_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute2 := l_rrd_rec.attribute2;
      END IF;
      IF (x_rrd_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute3 := l_rrd_rec.attribute3;
      END IF;
      IF (x_rrd_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute4 := l_rrd_rec.attribute4;
      END IF;
      IF (x_rrd_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute5 := l_rrd_rec.attribute5;
      END IF;
      IF (x_rrd_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute6 := l_rrd_rec.attribute6;
      END IF;
      IF (x_rrd_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute7 := l_rrd_rec.attribute7;
      END IF;
      IF (x_rrd_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute8 := l_rrd_rec.attribute8;
      END IF;
      IF (x_rrd_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute9 := l_rrd_rec.attribute9;
      END IF;
      IF (x_rrd_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute10 := l_rrd_rec.attribute10;
      END IF;
      IF (x_rrd_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute11 := l_rrd_rec.attribute11;
      END IF;
      IF (x_rrd_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute12 := l_rrd_rec.attribute12;
      END IF;
      IF (x_rrd_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute13 := l_rrd_rec.attribute13;
      END IF;
      IF (x_rrd_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute14 := l_rrd_rec.attribute14;
      END IF;
      IF (x_rrd_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.attribute15 := l_rrd_rec.attribute15;
      END IF;
      IF (x_rrd_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_rrd_rec.access_level := l_rrd_rec.access_level;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_RG_ROLE_DEFS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_rrd_rec IN  rrd_rec_type,
      x_rrd_rec OUT NOCOPY rrd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rrd_rec := p_rrd_rec;
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
      p_rrd_rec,                         -- IN
      l_rrd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rrd_rec, l_def_rrd_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_RG_ROLE_DEFS
    SET SRD_ID = l_def_rrd_rec.srd_id,
        SRE_ID = l_def_rrd_rec.sre_id,
        OBJECT_VERSION_NUMBER = l_def_rrd_rec.object_version_number,
        CREATED_BY = l_def_rrd_rec.created_by,
        CREATION_DATE = l_def_rrd_rec.creation_date,
        LAST_UPDATED_BY = l_def_rrd_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rrd_rec.last_update_date,
        SUBJECT_OBJECT_FLAG = l_def_rrd_rec.subject_object_flag,
        OPTIONAL_YN = l_def_rrd_rec.optional_yn,
        LAST_UPDATE_LOGIN = l_def_rrd_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_rrd_rec.attribute_category,
        ATTRIBUTE1 = l_def_rrd_rec.attribute1,
        ATTRIBUTE2 = l_def_rrd_rec.attribute2,
        ATTRIBUTE3 = l_def_rrd_rec.attribute3,
        ATTRIBUTE4 = l_def_rrd_rec.attribute4,
        ATTRIBUTE5 = l_def_rrd_rec.attribute5,
        ATTRIBUTE6 = l_def_rrd_rec.attribute6,
        ATTRIBUTE7 = l_def_rrd_rec.attribute7,
        ATTRIBUTE8 = l_def_rrd_rec.attribute8,
        ATTRIBUTE9 = l_def_rrd_rec.attribute9,
        ATTRIBUTE10 = l_def_rrd_rec.attribute10,
        ATTRIBUTE11 = l_def_rrd_rec.attribute11,
        ATTRIBUTE12 = l_def_rrd_rec.attribute12,
        ATTRIBUTE13 = l_def_rrd_rec.attribute13,
        ATTRIBUTE14 = l_def_rrd_rec.attribute14,
        ATTRIBUTE15 = l_def_rrd_rec.attribute15,
        ACCESS_LEVEL = l_def_rrd_rec.access_level
    WHERE ID = l_def_rrd_rec.id;

    x_rrd_rec := l_def_rrd_rec;
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
  ---------------------------------------
  -- update_row for:OKC_RG_ROLE_DEFS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type,
    x_rrdv_rec                     OUT NOCOPY rrdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rrdv_rec                     rrdv_rec_type := p_rrdv_rec;
    l_def_rrdv_rec                 rrdv_rec_type;
    l_rrd_rec                      rrd_rec_type;
    lx_rrd_rec                     rrd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rrdv_rec	IN rrdv_rec_type
    ) RETURN rrdv_rec_type IS
      l_rrdv_rec	rrdv_rec_type := p_rrdv_rec;
    BEGIN
      l_rrdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rrdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rrdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rrdv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rrdv_rec	IN rrdv_rec_type,
      x_rrdv_rec	OUT NOCOPY rrdv_rec_type
    ) RETURN VARCHAR2 IS
      l_rrdv_rec                     rrdv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rrdv_rec := p_rrdv_rec;
      -- Get current database values
      l_rrdv_rec := get_rec(p_rrdv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rrdv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rrdv_rec.id := l_rrdv_rec.id;
      END IF;
      IF (x_rrdv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rrdv_rec.object_version_number := l_rrdv_rec.object_version_number;
      END IF;
      IF (x_rrdv_rec.srd_id = OKC_API.G_MISS_NUM)
      THEN
        x_rrdv_rec.srd_id := l_rrdv_rec.srd_id;
      END IF;
      IF (x_rrdv_rec.sre_id = OKC_API.G_MISS_NUM)
      THEN
        x_rrdv_rec.sre_id := l_rrdv_rec.sre_id;
      END IF;
      IF (x_rrdv_rec.optional_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.optional_yn := l_rrdv_rec.optional_yn;
      END IF;
      IF (x_rrdv_rec.subject_object_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.subject_object_flag := l_rrdv_rec.subject_object_flag;
      END IF;
      IF (x_rrdv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute_category := l_rrdv_rec.attribute_category;
      END IF;
      IF (x_rrdv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute1 := l_rrdv_rec.attribute1;
      END IF;
      IF (x_rrdv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute2 := l_rrdv_rec.attribute2;
      END IF;
      IF (x_rrdv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute3 := l_rrdv_rec.attribute3;
      END IF;
      IF (x_rrdv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute4 := l_rrdv_rec.attribute4;
      END IF;
      IF (x_rrdv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute5 := l_rrdv_rec.attribute5;
      END IF;
      IF (x_rrdv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute6 := l_rrdv_rec.attribute6;
      END IF;
      IF (x_rrdv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute7 := l_rrdv_rec.attribute7;
      END IF;
      IF (x_rrdv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute8 := l_rrdv_rec.attribute8;
      END IF;
      IF (x_rrdv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute9 := l_rrdv_rec.attribute9;
      END IF;
      IF (x_rrdv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute10 := l_rrdv_rec.attribute10;
      END IF;
      IF (x_rrdv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute11 := l_rrdv_rec.attribute11;
      END IF;
      IF (x_rrdv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute12 := l_rrdv_rec.attribute12;
      END IF;
      IF (x_rrdv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute13 := l_rrdv_rec.attribute13;
      END IF;
      IF (x_rrdv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute14 := l_rrdv_rec.attribute14;
      END IF;
      IF (x_rrdv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.attribute15 := l_rrdv_rec.attribute15;
      END IF;
      IF (x_rrdv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rrdv_rec.created_by := l_rrdv_rec.created_by;
      END IF;
      IF (x_rrdv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rrdv_rec.creation_date := l_rrdv_rec.creation_date;
      END IF;
      IF (x_rrdv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rrdv_rec.last_updated_by := l_rrdv_rec.last_updated_by;
      END IF;
      IF (x_rrdv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rrdv_rec.last_update_date := l_rrdv_rec.last_update_date;
      END IF;
      IF (x_rrdv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rrdv_rec.last_update_login := l_rrdv_rec.last_update_login;
      END IF;
      IF (x_rrdv_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_rrdv_rec.access_level := l_rrdv_rec.access_level;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_RG_ROLE_DEFS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_rrdv_rec IN  rrdv_rec_type,
      x_rrdv_rec OUT NOCOPY rrdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rrdv_rec := p_rrdv_rec;
      x_rrdv_rec.OBJECT_VERSION_NUMBER := NVL(x_rrdv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_rrdv_rec,                        -- IN
      l_rrdv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rrdv_rec, l_def_rrdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rrdv_rec := fill_who_columns(l_def_rrdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rrdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rrdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rrdv_rec, l_rrd_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rrd_rec,
      lx_rrd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rrd_rec, l_def_rrdv_rec);
    x_rrdv_rec := l_def_rrdv_rec;
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
  -- PL/SQL TBL update_row for:RRDV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN rrdv_tbl_type,
    x_rrdv_tbl                     OUT NOCOPY rrdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rrdv_tbl.COUNT > 0) THEN
      i := p_rrdv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rrdv_rec                     => p_rrdv_tbl(i),
          x_rrdv_rec                     => x_rrdv_tbl(i));
        EXIT WHEN (i = p_rrdv_tbl.LAST);
        i := p_rrdv_tbl.NEXT(i);
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
  -------------------------------------
  -- delete_row for:OKC_RG_ROLE_DEFS --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrd_rec                      IN rrd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DEFS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rrd_rec                      rrd_rec_type:= p_rrd_rec;
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
    DELETE FROM OKC_RG_ROLE_DEFS
     WHERE ID = l_rrd_rec.id;

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
  ---------------------------------------
  -- delete_row for:OKC_RG_ROLE_DEFS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rrdv_rec                     rrdv_rec_type := p_rrdv_rec;
    l_rrd_rec                      rrd_rec_type;
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
    migrate(l_rrdv_rec, l_rrd_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rrd_rec
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
  -- PL/SQL TBL delete_row for:RRDV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN rrdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rrdv_tbl.COUNT > 0) THEN
      i := p_rrdv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rrdv_rec                     => p_rrdv_tbl(i));
        EXIT WHEN (i = p_rrdv_tbl.LAST);
        i := p_rrdv_tbl.NEXT(i);
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
END OKC_RRD_PVT;

/
